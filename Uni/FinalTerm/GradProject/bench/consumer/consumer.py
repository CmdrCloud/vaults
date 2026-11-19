"""MQTT consumer. MODE=engine stores idempotently; MODE=naive inserts every message as received."""

from __future__ import annotations

import json
import logging
import os
import time
from datetime import datetime
from pathlib import Path
from typing import Any

import paho.mqtt.client as mqtt
import psycopg

LOGGER = logging.getLogger("consumer")
REQUIRED_FIELDS = {
    "schema_version",
    "site_id",
    "device_id",
    "edge_seq",
    "metric",
    "unit",
    "value",
    "captured_at",
}
METRIC_UNITS = {
    "power_kw": "kW",
    "energy_kwh": "kWh",
    "temperature_c": "C",
    "operating_hours": "h",
    "status": "bool",
}
READY_PATH = Path("/tmp/consumer-ready")
MODE = os.environ.get("MODE", "engine")


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


def validate(payload: Any) -> dict[str, Any]:
    if not isinstance(payload, dict) or set(payload) != REQUIRED_FIELDS:
        raise ValueError("payload must contain exactly the telemetry contract fields")
    if payload["schema_version"] != "1.0":
        raise ValueError("unsupported schema_version")
    if not all(isinstance(payload[field], str) and payload[field] for field in ("site_id", "device_id", "metric", "unit", "captured_at")):
        raise ValueError("text fields must be non-empty strings")
    if isinstance(payload["edge_seq"], bool) or not isinstance(payload["edge_seq"], int) or payload["edge_seq"] < 1:
        raise ValueError("edge_seq must be a positive integer")
    if isinstance(payload["value"], bool) or not isinstance(payload["value"], (int, float)):
        raise ValueError("value must be numeric")
    if METRIC_UNITS.get(payload["metric"]) != payload["unit"]:
        raise ValueError("metric and unit are not valid")
    try:
        captured_at = datetime.fromisoformat(payload["captured_at"].replace("Z", "+00:00"))
    except ValueError as error:
        raise ValueError("captured_at must be ISO-8601") from error
    if captured_at.tzinfo is None:
        raise ValueError("captured_at must include a UTC offset")
    return payload


INSERT_SQL = """
    INSERT INTO telemetry (site_id, device_id, edge_seq, metric, unit, value, captured_at)
    VALUES (%(site_id)s, %(device_id)s, %(edge_seq)s, %(metric)s, %(unit)s, %(value)s, %(captured_at)s)
"""


def save_telemetry(connection: psycopg.Connection[Any], payload: dict[str, Any]) -> bool:
    with connection.cursor() as cursor:
        if MODE == "naive":
            cursor.execute(INSERT_SQL, payload)
            connection.commit()
            return True
        cursor.execute(
            """
            INSERT INTO telemetry_deduplication (site_id, edge_seq)
            VALUES (%(site_id)s, %(edge_seq)s)
            ON CONFLICT (site_id, edge_seq) DO NOTHING
            RETURNING site_id
            """,
            payload,
        )
        accepted = cursor.fetchone() is not None
        if accepted:
            cursor.execute(INSERT_SQL, payload)
    connection.commit()
    return accepted


class TelemetryConsumer:
    def __init__(self) -> None:
        self.connection = connect_with_retry()
        self.client = mqtt.Client(
            mqtt.CallbackAPIVersion.VERSION2,
            client_id="bench-consumer",
            clean_session=False,
        )
        self.client.reconnect_delay_set(min_delay=1, max_delay=5)
        self.client.on_connect = self.on_connect
        self.client.on_subscribe = self.on_subscribe
        self.client.on_message = self.on_message
        self.client.on_disconnect = self.on_disconnect

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
        client.subscribe("sites/+/devices/+/telemetry/raw", qos=1)

    def on_subscribe(
        self,
        client: mqtt.Client,
        userdata: Any,
        mid: int,
        reason_codes: list[mqtt.ReasonCode],
        properties: mqtt.Properties | None,
    ) -> None:
        if any(reason_code.is_failure for reason_code in reason_codes):
            LOGGER.warning("MQTT subscription rejected: %s", reason_codes)
            return
        READY_PATH.touch()
        LOGGER.info("Subscribed to telemetry topics")

    def on_disconnect(
        self,
        client: mqtt.Client,
        userdata: Any,
        disconnect_flags: mqtt.DisconnectFlags,
        reason_code: mqtt.ReasonCode,
        properties: mqtt.Properties | None,
    ) -> None:
        LOGGER.warning("MQTT disconnected: %s", reason_code)

    def on_message(self, client: mqtt.Client, userdata: Any, message: mqtt.MQTTMessage) -> None:
        try:
            payload = validate(json.loads(message.payload.decode("utf-8")))
        except (UnicodeDecodeError, json.JSONDecodeError, ValueError) as error:
            LOGGER.warning("Skipped invalid message on %s: %s", message.topic, error)
            return
        while True:
            try:
                if save_telemetry(self.connection, payload):
                    pass
                else:
                    LOGGER.info("Ignored duplicate %s/%s", payload["site_id"], payload["edge_seq"])
                return
            except psycopg.OperationalError as error:
                LOGGER.warning("TimescaleDB write failed, reconnecting: %s", error)
                self.connection.rollback()
                self.connection.close()
                self.connection = connect_with_retry()

    def run(self) -> None:
        self.client.connect_async(
            os.environ.get("MQTT_HOST", "broker"), int(os.environ.get("MQTT_PORT", "1883")), 30
        )
        self.client.loop_forever(retry_first_connection=True)


def main() -> None:
    logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
    TelemetryConsumer().run()


if __name__ == "__main__":
    main()
