# Banco de pruebas emulado — motor de sincronización

Estado: pasos 1–3 del handoff (renombrado, modo naive, ledger de verdad de campo) + runner con escenarios `none` y `E1`. E2–E4, tablero y README final: pendientes.

## Qué prueba / qué NO prueba
- Prueba la LÓGICA: pérdida, duplicados y recuperación ante fallos inyectados.
- NO prueba: rendimiento de flash/fsync, durabilidad ante corte real de energía, comportamiento de un ISP real.
- El contenedor `edge` es una emulación del gateway (linux/arm64, 4 CPU, 4 GB). En este host (Apple Silicon) arm64 es nativo: no hay QEMU.

## Componentes
- `edge/` — gateway emulado. `MODE=naive`: publica directo (MQTT QoS 1), sin copia local, sin dedup. `MODE=engine`: outbox SQLite transaccional (`readings_log` + `pending`), drenado con confirmación, backfill desde el log de 24 h.
- `consumer/` — `naive`: inserta todo lo que llega. `engine`: consolidación idempotente por `(site_id, edge_seq)`.
- `reconciler/` — solo en `engine`: detecta huecos y pide backfill.
- Ledger: `runs/<run_id>/ledger.csv`, escrito y `fsync`-eado por el generador ANTES del camino de datos. El motor nunca lo lee.

## Métricas (contra el ledger)
- generated = filas del ledger; consolidated = claves con ≥1 fila en el almacén; lost = claves con 0 filas; duplicates = filas extra (n−1) por clave.
- recovery_time_s = desde la última restauración hasta que el almacén tiene todas las claves del ledger.

## Reproducir
```bash
python3 runner.py --scenarios none,E1 --modes naive,engine --reps 3 --cycles 90
```
Resultados en `results/results.csv`; cada corrida guarda ledger, logs y `result.json` en `runs/<run_id>/`. Misma semilla = misma carga y mismo calendario de fallos.

## Uso de IA (para Anexo D)
- 2026-11-18, Claude Code (Claude Opus 5.5): creó `bench/` adaptando el prototipo de origen con ids genéricos; escribió `edge/edge.py` (modos naive/engine, ledger), añadió `enqueue`/`pending_batch` a `edge/buffer.py`, adaptó `consumer/consumer.py` (modo naive) y `reconciler/reconciler.py` (renombrado), y escribió `schema.sql`, `docker-compose.yml`, `runner.py` y este README.
