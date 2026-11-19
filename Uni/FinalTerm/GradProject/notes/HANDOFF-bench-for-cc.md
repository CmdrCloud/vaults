# HANDOFF para el chat de Claude Code: construir el banco de pruebas emulado

Fecha: 2026-11-18. Complementa `HANDOFF-perfil-y-prototipo.md`. El chat de investigación/Google Docs ya produjo `Perfil_TFG_Garufalias_v6.docx` (Drive, carpeta del Perfil). No toques el Perfil; tu trabajo es SOLO lo que vive en esta computadora.

## 0. Decisión de diseño (ya tomada con Andreas)
- El banco **emulado** es la validación principal. El gateway físico (RevPi Connect 5) es validación complementaria OPCIONAL (*).
- El banco prueba la LÓGICA (pérdida, duplicados, recuperación). NO prueba: rendimiento flash/fsync, durabilidad ante corte real de energía, comportamiento de un ISP real. Nunca escribas resultados que afirmen eso.
- Tres tipos de cifras que NO se mezclan: publicadas (contexto), medidas en el banco (línea base/resultados), de campo del sitio (opcional, hoy no hay).

## 1. NDA (obligatorio)
- Nunca aparecen: DeepBlue, el cliente, el sitio piloto, nombres de personal (p. ej. Vega), ni nombres reales de sitios ("amarket", "produccion", "cafe", "farmacia").
- Usar ids genéricos: `site-01`, `site-02`, `site-03`; dispositivos `dev-01`…; contenedores/BD/redes/usuarios sin la palabra "deepblue".
- Construir en una carpeta NUEVA: `GradProject/bench/`. No copies archivos con nombres reales; copia el código y renombra. No modifiques `DeepBlue/prototypes/` (solo lectura, es fuente).
- Si dudas si un término es sensible, trátalo como sensible y pregúntale a Andreas.

## 2. Fuente de código
`DeepBlue/prototypes/mqtt-to-timescale/` (README, docker-compose.yml, simulator/simulator.py y buffer.py, consumer/consumer.py, reconciler/reconciler.py, schema.sql, config.json, auto-outage.sh, sim-outage.sh, demo.sh).
Contrato de telemetría: topic `sites/{site_id}/devices/{device_id}/telemetry/raw`, JSON con `site_id, device_id, edge_seq, metric, unit, value, captured_at`. Identificador estable `(site_id, edge_seq)`.
Stack estándar del banco: TimescaleDB + verificación por SQL. El Perfil no nombra base de datos; el motor se declara agnóstico al almacén.

## 3. Qué construir (en orden)
1. **Renombrado y limpieza** a ids genéricos (ver §1). Verifica con `grep -ri -E "deepblue|amarket|farmacia|cafe|produccion|vega"` que no queda nada.
2. **Modo ingenuo (naive)**: la arquitectura ACTUAL del cliente = publicación directa, sin copia local, sin dedup, sin reconciliación. No existe hoy; hay que crearlo como modo seleccionable (`MODE=naive|engine`). Es la línea base.
3. **Ledger de verdad de campo (ground truth) SEPARADO**: el generador escribe cada lectura emitida (site_id, edge_seq, valor, ts) en un archivo/tabla independiente del camino de datos. No uses `sum(last_edge_seq)` como verdad: es un proxy. Pérdida = en ledger y no en el almacén; duplicado = más de una fila consolidada para la misma clave; consolidada = exactamente una.
4. **Escenarios con fallos realistas y semillas fijas**:
   - E1 corte de enlace: `tc netem` (loss 100 %) o desconexión de red del contenedor, ciclos de corte/restauración con duración configurable.
   - E2 caída del proceso de envío: `kill -9` durante el envío.
   - E3 reinicio con lecturas pendientes: parada abrupta del contenedor (`docker kill`), sin cierre limpio.
   - E4 almacenamiento agotado: volumen/tmpfs de tamaño limitado durante corte prolongado. Criterio: sin corrupción ni duplicados; toda lectura no conservada queda contabilizada y señalizada (la pérdida debe ser explícita, no silenciosa).
5. **Contenedor ARM64 con límites de CPU y RAM** equivalentes al gateway de referencia (4 núcleos, 4 GB; cuando exista el RevPi se ajusta). Documentar que es emulación (QEMU/buildx si el host es x86).
6. **Runner** que ejecuta N repeticiones por escenario × modo y escribe `results.csv`: `run_id, scenario, mode, seed, generated, consolidated, lost, duplicates, recovery_time_s, started_at, git_hash`. Cada corrida reproducible con la misma semilla.
7. **Tablero de verificación** simple (Grafana o HTML estático) que muestre por escenario: generadas, consolidadas, perdidas, duplicadas, con y sin motor.
8. **Ejecutar** línea base (naive) y motor, dejar los CSV, y un `README.md` del banco (cómo reproducir, parámetros, límites de lo que prueba).

## 4. Lo que el Perfil v6 ya promete (no contradecir)
- Iteraciones: I1 outbox (SQLite `pending`), I2 reconciliación idempotente (ON CONFLICT, watermarks, backfill desde log de 24 h), I3 integración + pruebas + tablero.
- Entrega "efectivamente exactamente una vez" = al-menos-una-vez + idempotencia (el exactly-once estricto de red es imposible).
- Censo de nodos y ciclos del banco (sin muestreo). Parámetros a registrar: nº nodos, cadencia, nº y duración de cortes.
- Cronograma: M3 (Capítulo II: banco, línea base, requisitos) EN CURSO; M4 cierra 28/11/2026 (arquitectura, diseño, I1 e I2); M5 26/12/2026.

## 5. Datos y CSV
`DeepBlue/prototypes/DATASET/KwhConsumptionBlower78_*.csv`: procedencia y permiso desconocidos (Andreas lo consultará con su antiguo jefe). NO usarlos como evidencia de pérdida ni como carga del banco. El banco genera su propia carga sintética.

## 6. Declaración de uso de IA (Anexo D del Perfil)
Anota en el README del banco qué partes escribió o modificó Claude Code (fecha, archivos, qué hizo) para que Andreas pueda declararlo.

## 7. Reglas de trabajo
- No sobrescribir archivos de Andreas; crear nuevos. No commits salvo que lo pida.
- No inventar datos ni resultados: todo número sale de una corrida con run_id.
- Al terminar, resumen corto: qué corrió, CSVs generados, límites conocidos, y preguntas abiertas.
