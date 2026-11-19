"""Emulated edge gateway for the test bench.

MODE=naive  -> baseline: publish directly (MQTT QoS 1), no local copy, no outbox,
               no backfill. Whatever the MQTT client keeps in RAM is all there is.
MODE=engine -> the synchronization engine: transactional outbox in SQLite
               (readings_log + pending), drain-on-ack, backfill from the rolling log.

Independently of MODE, every generated reading is appended to a GROUND-TRUTH
LEDGER (/ledger/ledger.csv) and fsync'ed BEFORE it enters the data path. The
ledger is instrumentation, not part of the engine: the engine never reads it.
"""

from __future__ import annotations

import csv
import json
import logging
import os
import queue
import random
import signal
import sqlite3
import threading
import time
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

import paho.mqtt.client as mqtt

from buffer import BufferStore, LoggedReading

LOG = logging.getLogger("edge")
MODE = os.environ.get("MODE", "engine")
SEED = int(os.environ.get("SEED", "1"))
CYCLES = int(os.environ.get("CYCLES", "120"))
INTERVAL = float(os.environ.get("INTERVAL_SECONDS", "1"))
CONFIG_PATH = Path(os.environ.get("CONFIG_PATH", "/app/config.json"))
BUFFER_PATH = Path(os.environ.get("BUFFER_PATH", "/data/buffer.db"))
LEDGER_DIR = Path(os.environ.get("LEDGER_DIR", "/ledger"))
DRAIN_BATCH = int(os.environ.get("DRAIN_BATCH", "200"))
PUBACK_TIMEOUT = 2.0
BACKFILL_TOPIC = "reconciler/+/backfill/request"
LEDGER_FIELDS = ["cycle", "site_id", "device_id", "metric", "edge_seq", "value", "captured_at"]

POWER = {"cash_register": (0.04, 0.15), "refrigerator": (0.10, 0.35), "oven": (1.2, 4.5),
         "coffee_machine": (0.6, 1.8), "light": (0.03, 0.12)}
TEMP = {"refrigerator": (2.0, 6.0), "oven": (160.0, 220.0), "coffee_machine": (82.0, 96.0)}
UNITS = {"power_kw": "kW", "temperature_c": "C", "operating_hours": "h", "energy_kwh": "kWh", "status": "bool"}


def devices() -> list[tuple[str, str, str]]:
    cfg = json.loads(CONFIG_PATH.read_text())
    return [(s["id"], d["id"], d["type"]) for s in cfg["sites"] for d in s["devices"]]


def cycle_values(cycle: int, dtype: str, rng: random.Random) -> list[tuple[str, float]]:
    status = 1.0 if rng.random() < 0.92 else 0.0
    power = rng.uniform(*POWER[dtype]) if status else 0.0
    out = [("power_kw", power)]
    if dtype in TEMP:
        out.append(("temperature_c", rng.uniform(*TEMP[dtype])))
    out += [("operating_hours", 100.0 + cycle * INTERVAL / 3600), ("energy_kwh", power * INTERVAL / 3600),
            ("status", status)]
    return out


class Ledger:
    """Append-only ground truth, fsync'ed per cycle. Survives kill -9 / docker kill."""

    def __init__(self, directory: Path) -> None:
        directory.mkdir(parents=True, exist_ok=True)
        self.path = directory / "ledger.csv"
        self.cycles_done = 0
        self.max_seq: dict[str, int] = {}
        if self.path.exists():
            with self.path.open() as f:
                for row in csv.DictReader(f):
                    self.cycles_done = max(self.cycles_done, int(row["cycle"]) + 1)
                    self.max_seq[row["site_id"]] = max(self.max_seq.get(row["site_id"], 0), int(row["edge_seq"]))
        new = not self.path.exists()
        self.file = self.path.open("a", newline="")
        self.writer = csv.writer(self.file)
        if new:
            self.writer.writerow(LEDGER_FIELDS)

    def append(self, rows: list[list[Any]]) -> None:
        self.writer.writerows(rows)
        self.file.flush()
        os.fsync(self.file.fileno())


class Edge:
    def __init__(self) -> None:
        self.devs = devices()
        self.ledger = Ledger(LEDGER_DIR)
        self.buffer = BufferStore(BUFFER_PATH) if MODE == "engine" else None
        # Sequence allocation. Engine: durable in SQLite (site_sequences). Naive: the
        # baseline has no ids; the bench still stamps a counter so readings can be
        # matched to the ledger (instrumentation only, never used for dedup).
        self.seq: dict[str, int] = dict(self.ledger.max_seq) if MODE == "naive" else {}
        self.connected = False
        self.stop = threading.Event()
        self.backfill: queue.Queue[tuple[str, str, int, int]] = queue.Queue()
        self.client = mqtt.Client(mqtt.CallbackAPIVersion.VERSION2, client_id=f"bench-edge-{MODE}",
                                  clean_session=True)
        self.client.reconnect_delay_set(min_delay=1, max_delay=2)
        self.client.on_connect = self.on_connect
        self.client.on_disconnect = lambda *a: self._set_conn(False)
        self.client.on_message = self.on_message

    def _set_conn(self, value: bool) -> None:
        if self.connected != value:
            LOG.warning("MQTT %s", "CONNECTED" if value else "DISCONNECTED")
        self.connected = value

    def on_connect(self, client, userdata, flags, rc, props) -> None:
        if rc.is_failure:
            return
        self._set_conn(True)
        if MODE == "engine":
            client.subscribe(BACKFILL_TOPIC, qos=1)

    def on_message(self, client, userdata, msg) -> None:
        try:
            r = json.loads(msg.payload)
            self.backfill.put((r["site_id"], r["request_id"], int(r["min_seq"]), int(r["max_seq"])))
        except Exception:  # noqa: BLE001
            LOG.warning("bad backfill request on %s", msg.topic)

    # ---- generation -------------------------------------------------------
    def next_seq(self, site: str) -> int:
        if MODE == "engine":
            return self.buffer.next_edge_seq(site)
        self.seq[site] = self.seq.get(site, 0) + 1
        return self.seq[site]

    def generate(self, cycle: int) -> list[LoggedReading]:
        rng = random.Random(f"{SEED}:{cycle}")
        ts = datetime.now(timezone.utc).isoformat(timespec="milliseconds").replace("+00:00", "Z")
        readings, rows = [], []
        for site, dev, dtype in self.devs:
            for metric, value in cycle_values(cycle, dtype, rng):
                seq = self.next_seq(site)
                value = round(value, 6)
                payload = json.dumps({"schema_version": "1.0", "site_id": site, "device_id": dev, "edge_seq": seq,
                                      "metric": metric, "unit": UNITS[metric], "value": value, "captured_at": ts},
                                     separators=(",", ":"))
                readings.append(LoggedReading(site, dev, metric, seq, payload, ts))
                rows.append([cycle, site, dev, metric, seq, value, ts])
        self.ledger.append(rows)  # ground truth first
        return readings

    # ---- data path ----------------------------------------------------------
    def publish(self, r) -> bool:
        info = self.client.publish(f"sites/{r.site_id}/devices/{r.device_id}/telemetry/raw", r.payload, qos=1)
        if MODE == "naive":
            return True  # fire and forget
        if info.rc != mqtt.MQTT_ERR_SUCCESS:
            return False
        try:
            info.wait_for_publish(timeout=PUBACK_TIMEOUT)
        except (RuntimeError, ValueError):
            return False
        return info.is_published()

    def handle_cycle(self, readings: list[LoggedReading]) -> None:
        if MODE == "naive":
            for r in readings:
                if self.connected:
                    self.publish(r)
            return
        try:
            self.buffer.enqueue(readings)  # outbox: durable before any send
        except sqlite3.OperationalError as err:
            LOG.error("OUTBOX WRITE FAILED (%s): %s readings not retained", err, len(readings))
            raise

    def drain(self, deadline: float) -> int:
        sent = 0
        while self.connected and not self.stop.is_set() and time.monotonic() < deadline:
            batch = self.buffer.pending_batch(DRAIN_BATCH)
            if not batch:
                break
            for r in batch:
                if time.monotonic() >= deadline or not self.publish(r):
                    return sent
                self.buffer.remove_pending(r.site_id, r.edge_seq)
                sent += 1
        return sent

    def serve_backfill(self) -> None:
        while self.connected:
            try:
                site, req, lo, hi = self.backfill.get_nowait()
            except queue.Empty:
                return
            rows = self.buffer.log_readings_in_range(site, lo, hi)
            done = sum(1 for r in rows if self.publish(r))
            self.client.publish(f"reconciler/{site}/backfill/response",
                                json.dumps({"request_id": req, "site_id": site, "requested": len(rows),
                                            "replayed": done}), qos=1)
            LOG.info("backfill %s %s..%s: %s/%s", site, lo, hi, done, len(rows))

    def write_status(self, cycle: int) -> None:
        status = {"mode": MODE, "cycles_done": cycle, "cycles_target": CYCLES,
                  "pending": self.buffer.pending_count() if self.buffer else 0, "connected": self.connected,
                  "at": time.time()}
        tmp = LEDGER_DIR / "status.json.tmp"
        tmp.write_text(json.dumps(status))
        tmp.replace(LEDGER_DIR / "status.json")

    def run(self) -> None:
        self.client.connect_async(os.environ.get("MQTT_HOST", "broker"), int(os.environ.get("MQTT_PORT", "1883")), 10)
        self.client.loop_start()
        # Fresh start (not a resume): wait for the first connection so a no-fault
        # baseline is not polluted by a startup race. Resumes after a crash do NOT wait.
        if self.ledger.cycles_done == 0:
            for _ in range(300):
                if self.connected:
                    break
                time.sleep(0.1)
        cycle = self.ledger.cycles_done
        LOG.info("start mode=%s seed=%s resuming at cycle %s/%s", MODE, SEED, cycle, CYCLES)
        next_tick = time.monotonic()
        while not self.stop.is_set():
            if cycle < CYCLES:
                self.handle_cycle(self.generate(cycle))
                cycle += 1
            if MODE == "engine" and self.connected:
                self.drain(next_tick + 0.8 * INTERVAL)
                self.serve_backfill()
            self.write_status(cycle)
            next_tick += INTERVAL
            self.stop.wait(max(0.0, next_tick - time.monotonic()))
        self.client.loop_stop()


def main() -> None:
    logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
    edge = Edge()
    signal.signal(signal.SIGTERM, lambda *a: edge.stop.set())
    signal.signal(signal.SIGINT, lambda *a: edge.stop.set())
    edge.run()


if __name__ == "__main__":
    main()
