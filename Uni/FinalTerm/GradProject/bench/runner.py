#!/usr/bin/env python3
"""Bench runner: N repetitions per scenario x mode -> results/results.csv.

Usage: python3 runner.py --scenarios none,E1 --modes naive,engine --reps 3 --cycles 120
Every number in results.csv comes from a run with a run_id whose ledger and logs
are kept under runs/<run_id>/.
"""

from __future__ import annotations

import argparse
import csv
import json
import os
import random
import subprocess
import threading
import time
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parent
RESULTS = ROOT / "results" / "results.csv"
FIELDS = ["run_id", "scenario", "mode", "seed", "generated", "consolidated", "lost", "duplicates",
          "explicit_loss", "recovery_time_s", "faults", "fault_seconds", "cycles", "interval_s",
          "started_at", "git_hash"]


def sh(*args: str, env: dict | None = None, check: bool = True, capture: bool = True) -> str:
    res = subprocess.run(args, cwd=ROOT, env={**os.environ, **(env or {})}, text=True,
                         capture_output=capture, check=False)
    if check and res.returncode != 0:
        raise RuntimeError(f"{' '.join(args)}\n{res.stdout}\n{res.stderr}")
    return (res.stdout or "").strip()


def compose(env: dict, *args: str, check: bool = True) -> str:
    prof = ["--profile", "engine"] if env["MODE"] == "engine" else []
    return sh("docker", "compose", *prof, *args, env=env, check=check)


def psql(env: dict, sql: str) -> str:
    return compose(env, "exec", "-T", "db", "psql", "-U", "bench", "-d", "bench", "-At", "-F", ",", "-c", sql)


def container(env: dict, svc: str) -> str:
    return compose(env, "ps", "-q", svc)


def status(run_dir: Path) -> dict:
    try:
        return json.loads((run_dir / "status.json").read_text())
    except (FileNotFoundError, json.JSONDecodeError):
        return {}


def ledger_rows(run_dir: Path) -> int:
    try:
        with (run_dir / "ledger.csv").open() as f:
            return max(0, sum(1 for _ in f) - 1)
    except FileNotFoundError:
        return 0


def stored_keys(env: dict) -> int:
    return int(psql(env, "SELECT count(DISTINCT (site_id, edge_seq)) FROM telemetry") or 0)


# ---------------------------------------------------------------- fault injection
class Faults:
    """Seeded fault schedule. Each scenario cuts/kills `n` times with seeded timing."""

    def __init__(self, scenario: str, env: dict, rng: random.Random, cycles: int, interval: float) -> None:
        self.scenario, self.env, self.rng = scenario, env, rng
        self.span = cycles * interval
        self.count = 0
        self.seconds = 0.0
        self.last_restore: float | None = None

    def schedule(self, n: int, min_len: float, max_len: float) -> list[tuple[float, float]]:
        # n outages spread over the generation window, seeded start and duration.
        slot = self.span / n
        return [(i * slot + self.rng.uniform(0.1, 0.4) * slot, self.rng.uniform(min_len, max_len)) for i in range(n)]

    def run(self, t0: float) -> None:
        if self.scenario == "none":
            return
        if self.scenario == "E1":
            net = "tfg-bench_uplink"
            for start, length in self.schedule(3, 5, 15):
                time.sleep(max(0, t0 + start - time.time()))
                edge = container(self.env, "edge")
                sh("docker", "network", "disconnect", net, edge)
                time.sleep(length)
                sh("docker", "network", "connect", net, edge)
                self.count += 1
                self.seconds += length
                self.last_restore = time.time()
            return
        raise ValueError(f"scenario {self.scenario} not implemented yet")


# ---------------------------------------------------------------- one run
def one_run(scenario: str, mode: str, seed: int, cycles: int, interval: float, git_hash: str) -> dict:
    run_id = f"{datetime.now(timezone.utc):%Y%m%dT%H%M%SZ}-{scenario}-{mode}-s{seed}"
    run_dir = ROOT / "runs" / run_id
    run_dir.mkdir(parents=True)
    env = {"MODE": mode, "SEED": str(seed), "CYCLES": str(cycles), "INTERVAL_SECONDS": str(interval),
           "LEDGER_HOST_DIR": str(run_dir)}
    print(f"== {run_id}", flush=True)
    compose(env, "down", "-v", "--remove-orphans", check=False)
    started_at = datetime.now(timezone.utc).isoformat(timespec="seconds")
    compose(env, "up", "-d", "--build", "--wait")
    t0 = time.time()

    faults = Faults(scenario, env, random.Random(f"fault:{scenario}:{seed}"), cycles, interval)
    th = threading.Thread(target=faults.run, args=(t0,))
    th.start()
    th.join()

    # Wait for generation to finish, then for the store to settle (no change for `quiet` s).
    deadline = time.time() + cycles * interval + 300
    while time.time() < deadline and status(run_dir).get("cycles_done", 0) < cycles:
        time.sleep(1)
    quiet = 15 if mode == "engine" else 6
    last, stable_since, recovered_at = -1, time.time(), None
    while time.time() < deadline:
        n = stored_keys(env)
        if recovered_at is None and n >= ledger_rows(run_dir) > 0:
            recovered_at = time.time()
        if n != last:
            last, stable_since = n, time.time()
        elif time.time() - stable_since >= quiet:
            break
        time.sleep(1)

    compose(env, "logs", "--no-color", check=False)  # warm
    (run_dir / "compose.log").write_text(compose(env, "logs", "--no-color", "--timestamps", check=False))
    compose(env, "stop", "edge", check=False)
    psql(env, f"COPY ledger FROM '/runs/{run_id}/ledger.csv' WITH (FORMAT csv, HEADER true)")
    row = psql(env, """
        WITH c AS (SELECT l.site_id, l.edge_seq, count(t.edge_seq) AS n
                   FROM ledger l LEFT JOIN telemetry t USING (site_id, edge_seq)
                   GROUP BY 1, 2)
        SELECT count(*), count(*) FILTER (WHERE n >= 1), count(*) FILTER (WHERE n = 0),
               COALESCE(sum(n - 1) FILTER (WHERE n > 1), 0)
        FROM c""").split(",")
    generated, consolidated, lost, dups = map(int, row)
    rec = ""
    if faults.last_restore and recovered_at and recovered_at >= faults.last_restore:
        rec = f"{recovered_at - faults.last_restore:.1f}"
    elif scenario != "none" and lost == 0 and faults.last_restore:
        rec = "0.0"
    result = {"run_id": run_id, "scenario": scenario, "mode": mode, "seed": seed, "generated": generated,
              "consolidated": consolidated, "lost": lost, "duplicates": dups, "explicit_loss": 0,
              "recovery_time_s": rec, "faults": faults.count, "fault_seconds": f"{faults.seconds:.1f}",
              "cycles": cycles, "interval_s": interval, "started_at": started_at, "git_hash": git_hash}
    (run_dir / "result.json").write_text(json.dumps(result, indent=2))
    compose(env, "down", "-v", check=False)
    print(f"   generated={generated} consolidated={consolidated} lost={lost} dups={dups} rec={rec}", flush=True)
    return result


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--scenarios", default="none,E1")
    ap.add_argument("--modes", default="naive,engine")
    ap.add_argument("--reps", type=int, default=3)
    ap.add_argument("--seed0", type=int, default=1)
    ap.add_argument("--cycles", type=int, default=120)
    ap.add_argument("--interval", type=float, default=1.0)
    a = ap.parse_args()
    git_hash = sh("git", "rev-parse", "--short", "HEAD", check=False) or "nogit"
    if sh("git", "status", "--porcelain", ".", check=False):
        git_hash += "-dirty"
    RESULTS.parent.mkdir(exist_ok=True)
    new = not RESULTS.exists()
    with RESULTS.open("a", newline="") as f:
        w = csv.DictWriter(f, fieldnames=FIELDS)
        if new:
            w.writeheader()
        for scenario in a.scenarios.split(","):
            for mode in a.modes.split(","):
                for rep in range(a.reps):
                    w.writerow(one_run(scenario, mode, a.seed0 + rep, a.cycles, a.interval, git_hash))
                    f.flush()


if __name__ == "__main__":
    main()
