"""Cloud Reconciler: detects missing edge_seq gaps in TimescaleDB and requests paced
backfill from the edge (edge) over MQTT.

Mirrors the real the platform Reconciler: periodic gap scan per site -> Gap-free
Watermark -> backfill request -> verify zero gaps.
"""

from __future__ import annotations

import argparse
import json
import logging
import os
import time
import uuid
from datetime import datetime, timedelta, timezone
from typing import Any

import paho.mqtt.client as mqtt
import psycopg

LOGGER = logging.getLogger("reconciler")
REQUEST_TOPIC = "reconciler/{site_id}/backfill/request"
RESPONSE_PATTERN = "reconciler/+/backfill/response"
MAX_BACKFILL_RANGE = 500


def env_float(name: str, default: float) -> float:
    return float(os.environ.get(name, str(default)))


def postgres_connection() -> psycopg.Connection[Any]:
    return psycopg.connect(
        host=os.environ.get("POSTGRES_HOST", "timescaledb"),
        port=int(os.environ.get("POSTGRES_PORT", "5432")),
        dbname=os.environ.get("POSTGRES_DB", "bench"),
        user=os.environ.get("POSTGRES_USER", "bench"),
        password=os.environ.get("POSTGRES_PASSWORD", "bench-dev-password"),
    )


def connect_with_retry() -> psycopg.Connection[Any]:
    while True:
        try:
            connection = postgres_connection()
            LOGGER.info("Connected to TimescaleDB")
            return connection
        except psycopg.OperationalError as error:
            LOGGER.warning("TimescaleDB unavailable, retrying in 2 seconds: %s", error)
            time.sleep(2)


def contiguous_runs(sequences: list[int]) -> list[tuple[int, int]]:
    runs: list[tuple[int, int]] = []
    for seq in sequences:
        if runs and seq == runs[-1][1] + 1:
            runs[-1] = (runs[-1][0], seq)
        else:
            runs.append((seq, seq))
    return runs


def split_runs(runs: list[tuple[int, int]]) -> list[tuple[int, int]]:
    chunks: list[tuple[int, int]] = []
    for start, end in runs:
        while start <= end:
            slice_end = min(start + MAX_BACKFILL_RANGE - 1, end)
            chunks.append((start, slice_end))
            start = slice_end + 1
    return chunks


class Reconciler:
    def __init__(self, window_hours: float, tolerance_seconds: float) -> None:
        self.window_hours = window_hours
        self.tolerance_seconds = tolerance_seconds
        self.outstanding_ttl_seconds = env_float("BACKFILL_REQUEST_TTL_SECONDS", 180.0)
        self.max_outstanding_per_site = int(env_float("MAX_OUTSTANDING_PER_SITE", 50.0))
        self.connection = connect_with_retry()
        self.outstanding: dict[str, dict[str, Any]] = {}
        self.client = mqtt.Client(mqtt.CallbackAPIVersion.VERSION2, client_id="bench-reconciler")
        self.client.reconnect_delay_set(min_delay=1, max_delay=5)
        self.client.on_connect = self.on_connect
        self.client.on_message = self.on_message

    def on_connect(
        self,
        client: mqtt.Client,
        userdata: Any,
        flags: mqtt.ConnectFlags,
        reason_code: mqtt.ReasonCode,
        properties: mqtt.Properties | None,
    ) -> None:
        if reason_code.is_failure:
            LOGGER.warning("MQTT connection rejected: %s", reason_code)
            return
        client.subscribe(RESPONSE_PATTERN, qos=1)
        LOGGER.info("MQTT connected, subscribed to backfill responses")

    def on_message(self, client: mqtt.Client, userdata: Any, message: mqtt.MQTTMessage) -> None:
        try:
            response = json.loads(message.payload.decode("utf-8"))
            request_id = response["request_id"]
        except (KeyError, TypeError, ValueError, json.JSONDecodeError, UnicodeDecodeError):
            return
        entry = self.outstanding.pop(request_id, None)
        if entry is None:
            LOGGER.info("Ignored unknown backfill response %s", request_id)
            return
        if response.get("requested", 0) != response.get("replayed", 0):
            LOGGER.warning(
                "Backfill %s for site %s incomplete: replayed %s/%s",
                request_id,
                response.get("site_id"),
                response.get("replayed"),
                response.get("requested"),
            )
        else:
            LOGGER.info("Backfill %s for site %s complete: replayed %s", request_id, response.get("site_id"), response.get("replayed"))

    def scan_site(self, site_id: str) -> tuple[int, list[tuple[int, int]]]:
        cutoff = datetime.now(timezone.utc) - timedelta(hours=self.window_hours)
        tolerance_cutoff = datetime.now(timezone.utc) - timedelta(seconds=self.tolerance_seconds)
        with self.connection.cursor() as cursor:
            cursor.execute(
                """
                SELECT edge_seq FROM telemetry
                WHERE site_id = %s AND captured_at >= %s AND captured_at <= %s
                ORDER BY edge_seq
                """,
                (site_id, cutoff, tolerance_cutoff),
            )
            present = [row[0] for row in cursor.fetchall()]
        if not present:
            return 0, []
        expected = set(range(present[0], present[-1] + 1))
        missing = sorted(expected.difference(present))
        gap_free = present[0] - 1
        for seq in present:
            if seq == gap_free + 1:
                gap_free = seq
            else:
                break
        return gap_free, contiguous_runs(missing)

    def outstanding_for(self, site_id: str) -> int:
        return sum(1 for entry in self.outstanding.values() if entry["site_id"] == site_id)

    def request_backfill(self, site_id: str, runs: list[tuple[int, int]], limit: int | None = None) -> None:
        for start, end in split_runs(runs):
            if limit is not None and limit <= 0:
                break
            request_id = str(uuid.uuid4())
            payload = json.dumps(
                {"request_id": request_id, "site_id": site_id, "min_seq": start, "max_seq": end},
                separators=(",", ":"),
            )
            self.outstanding[request_id] = {"site_id": site_id, "issued_at": time.monotonic()}
            info = self.client.publish(REQUEST_TOPIC.format(site_id=site_id), payload, qos=1)
            if info.rc == mqtt.MQTT_ERR_SUCCESS:
                LOGGER.info("Requested backfill %s site=%s seqs=%s..%s", request_id, site_id, start, end)
                if limit is not None:
                    limit -= 1
            else:
                LOGGER.warning("Failed to publish backfill request for site %s: %s", site_id, info.rc)
                self.outstanding.pop(request_id, None)

    def drop_expired_outstanding(self) -> None:
        now = time.monotonic()
        expired = [
            request_id
            for request_id, entry in self.outstanding.items()
            if now - entry["issued_at"] > self.outstanding_ttl_seconds
        ]
        for request_id in expired:
            entry = self.outstanding.pop(request_id, None)
            if entry:
                LOGGER.warning(
                    "Expired outstanding backfill %s for site %s (no response within %ss)",
                    request_id,
                    entry["site_id"],
                    self.outstanding_ttl_seconds,
                )

    def reconcile_once(self) -> None:
        with self.connection.cursor() as cursor:
            cursor.execute("SELECT DISTINCT site_id FROM telemetry")
            sites = [row[0] for row in cursor.fetchall()]
        if not sites:
            LOGGER.info("No sites with data yet; skipping")
            return
        for site_id in sites:
            self.drop_expired_outstanding()
            inflight = self.outstanding_for(site_id)
            if inflight >= self.max_outstanding_per_site:
                LOGGER.info("Site %s at in-flight cap (%s); skipping", site_id, inflight)
                continue
            gap_free, runs = self.scan_site(site_id)
            missing_count = sum(end - start + 1 for start, end in runs)
            if missing_count:
                LOGGER.warning(
                    "Site %s: gap-free watermark=%s, %s missing sequence(s) in %s run(s)",
                    site_id,
                    gap_free,
                    missing_count,
                    len(runs),
                )
                self.request_backfill(site_id, runs, limit=self.max_outstanding_per_site - inflight)
            else:
                LOGGER.info("Site %s: gap-free watermark=%s, no gaps", site_id, gap_free)
            time.sleep(0.2)

    def run(self, once: bool) -> None:
        self.client.connect_async(
            os.environ.get("MQTT_HOST", "broker"), int(os.environ.get("MQTT_PORT", "1883")), 60
        )
        self.client.loop_start()
        while True:
            try:
                self.reconcile_once()
            except psycopg.OperationalError as error:
                LOGGER.warning("TimescaleDB scan failed, reconnecting: %s", error)
                self.connection.rollback()
                self.connection.close()
                self.connection = connect_with_retry()
            if once:
                LOGGER.info("One-shot reconciliation pass complete")
                break
            time.sleep(env_float("RECONCILE_INTERVAL_SECONDS", 30.0))
        self.client.loop_stop()
        self.connection.close()


def main() -> None:
    logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
    parser = argparse.ArgumentParser(description="Cloud reconciler for the platform telemetry gaps.")
    parser.add_argument("--once", action="store_true", help="run a single reconciliation pass and exit")
    args = parser.parse_args()
    reconciler = Reconciler(
        window_hours=env_float("ROLLING_LOG_HOURS", 24.0),
        tolerance_seconds=env_float("RECONCILE_TOLERANCE_SECONDS", 120.0),
    )
    reconciler.run(once=args.once)


if __name__ == "__main__":
    main()