CREATE EXTENSION IF NOT EXISTS timescaledb;

-- Consolidated store. Deliberately NO unique key on (site_id, edge_seq):
-- in naive mode duplicates must be observable; in engine mode the consumer
-- enforces idempotency through telemetry_deduplication.
CREATE TABLE telemetry (
  site_id     TEXT NOT NULL,
  device_id   TEXT NOT NULL,
  edge_seq    BIGINT NOT NULL,
  metric      TEXT NOT NULL,
  unit        TEXT NOT NULL,
  value       DOUBLE PRECISION NOT NULL,
  captured_at TIMESTAMPTZ NOT NULL,
  received_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
SELECT create_hypertable('telemetry', 'captured_at');
CREATE INDEX idx_seq ON telemetry (site_id, edge_seq);

CREATE TABLE telemetry_deduplication (
  site_id  TEXT NOT NULL,
  edge_seq BIGINT NOT NULL,
  PRIMARY KEY (site_id, edge_seq)
);

-- Ground truth, loaded by the runner from the edge ledger after each run.
CREATE TABLE ledger (
  cycle INT, site_id TEXT, device_id TEXT, metric TEXT, edge_seq BIGINT,
  value DOUBLE PRECISION, captured_at TIMESTAMPTZ,
  PRIMARY KEY (site_id, edge_seq)
);
