"""Durable per-site sequence allocation, pending telemetry storage, and a rolling log."""

from __future__ import annotations

import sqlite3
import threading
from dataclasses import dataclass
from datetime import datetime, timedelta, timezone
from pathlib import Path


def _utc_now_iso(hours_ago: float) -> str:
    stamp = datetime.now(timezone.utc) - timedelta(hours=hours_ago)
    return stamp.isoformat(timespec="milliseconds").replace("+00:00", "Z")


@dataclass(frozen=True)
class PendingReading:
    site_id: str
    device_id: str
    edge_seq: int
    payload: str
    captured_at: str


@dataclass(frozen=True)
class LoggedReading:
    site_id: str
    device_id: str
    metric: str
    edge_seq: int
    payload: str
    captured_at: str


class BufferStore:
    def __init__(self, path: Path) -> None:
        path.parent.mkdir(parents=True, exist_ok=True)
        self.connection = sqlite3.connect(path, check_same_thread=False)
        self.lock = threading.RLock()
        self.connection.execute("PRAGMA journal_mode=WAL")
        self.connection.executescript(
            """
            CREATE TABLE IF NOT EXISTS site_sequences (
              site_id TEXT PRIMARY KEY,
              last_edge_seq INTEGER NOT NULL
            );
            CREATE TABLE IF NOT EXISTS pending (
              site_id TEXT NOT NULL,
              device_id TEXT NOT NULL,
              edge_seq INTEGER NOT NULL,
              payload TEXT NOT NULL,
              captured_at TEXT NOT NULL,
              PRIMARY KEY (site_id, edge_seq)
            );
            CREATE INDEX IF NOT EXISTS idx_pending_order
              ON pending (site_id, edge_seq);
            CREATE TABLE IF NOT EXISTS readings_log (
              site_id TEXT NOT NULL,
              device_id TEXT NOT NULL,
              metric TEXT NOT NULL,
              edge_seq INTEGER NOT NULL,
              payload TEXT NOT NULL,
              captured_at TEXT NOT NULL,
              PRIMARY KEY (site_id, edge_seq)
            );
            CREATE INDEX IF NOT EXISTS idx_log_captured
              ON readings_log (captured_at);
            """
        )
        self.connection.commit()

    def next_edge_seq(self, site_id: str) -> int:
        with self.lock, self.connection:
            row = self.connection.execute(
                "SELECT last_edge_seq FROM site_sequences WHERE site_id = ?", (site_id,)
            ).fetchone()
            edge_seq = (int(row[0]) if row else 0) + 1
            self.connection.execute(
                """
                INSERT INTO site_sequences (site_id, last_edge_seq) VALUES (?, ?)
                ON CONFLICT(site_id) DO UPDATE SET last_edge_seq = excluded.last_edge_seq
                """,
                (site_id, edge_seq),
            )
        return edge_seq

    def add_pending(self, reading: PendingReading) -> None:
        with self.lock, self.connection:
            self.connection.execute(
                """
                INSERT INTO pending (site_id, device_id, edge_seq, payload, captured_at)
                VALUES (?, ?, ?, ?, ?)
                ON CONFLICT(site_id, edge_seq) DO NOTHING
                """,
                (
                    reading.site_id,
                    reading.device_id,
                    reading.edge_seq,
                    reading.payload,
                    reading.captured_at,
                ),
            )

    def pending_readings(self) -> list[PendingReading]:
        with self.lock:
            rows = self.connection.execute(
                """
                SELECT site_id, device_id, edge_seq, payload, captured_at
                FROM pending ORDER BY site_id, edge_seq
                """
            ).fetchall()
        return [PendingReading(*row) for row in rows]

    def remove_pending(self, site_id: str, edge_seq: int) -> None:
        with self.lock, self.connection:
            self.connection.execute(
                "DELETE FROM pending WHERE site_id = ? AND edge_seq = ?",
                (site_id, edge_seq),
            )

    def pending_count(self) -> int:
        with self.lock:
            return int(self.connection.execute("SELECT COUNT(*) FROM pending").fetchone()[0])

    def log_reading(self, reading: LoggedReading) -> None:
        with self.lock, self.connection:
            self.connection.execute(
                """
                INSERT INTO readings_log (site_id, device_id, metric, edge_seq, payload, captured_at)
                VALUES (?, ?, ?, ?, ?, ?)
                ON CONFLICT(site_id, edge_seq) DO NOTHING
                """,
                (
                    reading.site_id,
                    reading.device_id,
                    reading.metric,
                    reading.edge_seq,
                    reading.payload,
                    reading.captured_at,
                ),
            )

    def log_readings_in_range(self, site_id: str, min_seq: int, max_seq: int) -> list[LoggedReading]:
        with self.lock:
            rows = self.connection.execute(
                """
                SELECT site_id, device_id, metric, edge_seq, payload, captured_at
                FROM readings_log
                WHERE site_id = ? AND edge_seq BETWEEN ? AND ?
                ORDER BY edge_seq
                """,
                (site_id, min_seq, max_seq),
            ).fetchall()
        return [LoggedReading(*row) for row in rows]

    def trim_log(self, hours: float) -> int:
        cutoff = _utc_now_iso(hours)
        with self.lock, self.connection:
            cursor = self.connection.execute(
                "DELETE FROM readings_log WHERE captured_at < ?", (cutoff,)
            )
        return cursor.rowcount

    def generated_count(self) -> int:
        with self.lock:
            return int(
                self.connection.execute(
                    "SELECT COALESCE(SUM(last_edge_seq), 0) FROM site_sequences"
                ).fetchone()[0]
            )

    def highest_edge_seq(self) -> int:
        with self.lock:
            return int(
                self.connection.execute(
                    "SELECT COALESCE(MAX(last_edge_seq), 0) FROM site_sequences"
                ).fetchone()[0]
            )

    def enqueue(self, readings: list[LoggedReading]) -> None:
        """Transactional outbox: rolling log + pending queue written in ONE transaction.

        Raises sqlite3.OperationalError (e.g. 'database or disk is full') so the
        caller can account for the loss explicitly instead of silently.
        """
        with self.lock, self.connection:
            self.connection.executemany(
                """
                INSERT INTO readings_log (site_id, device_id, metric, edge_seq, payload, captured_at)
                VALUES (?, ?, ?, ?, ?, ?) ON CONFLICT(site_id, edge_seq) DO NOTHING
                """,
                [(r.site_id, r.device_id, r.metric, r.edge_seq, r.payload, r.captured_at) for r in readings],
            )
            self.connection.executemany(
                """
                INSERT INTO pending (site_id, device_id, edge_seq, payload, captured_at)
                VALUES (?, ?, ?, ?, ?) ON CONFLICT(site_id, edge_seq) DO NOTHING
                """,
                [(r.site_id, r.device_id, r.edge_seq, r.payload, r.captured_at) for r in readings],
            )

    def pending_batch(self, limit: int) -> list[PendingReading]:
        with self.lock:
            rows = self.connection.execute(
                "SELECT site_id, device_id, edge_seq, payload, captured_at FROM pending "
                "ORDER BY captured_at, site_id, edge_seq LIMIT ?",
                (limit,),
            ).fetchall()
        return [PendingReading(*row) for row in rows]

    def close(self) -> None:
        with self.lock:
            self.connection.close()
