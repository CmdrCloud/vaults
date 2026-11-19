# Anclaje metodológico

Sincronización de datos edge-to-cloud: buffer local y reconciliación por marcas para evitar pérdida y duplicación de registros en plataformas IIoT de monitoreo energético.

| Elemento | Decisión propuesta | Por qué / observaciones |
|---|---|---|
| **Tipo de investigación** | Aplicada y proyectiva | No se genera teoría nueva: se construye un artefacto (el motor de sincronización) que resuelve un problema operativo concreto de DeepBlue. |
| **Enfoque** | Mixto | Cuantitativo en la evidencia (% pérdida, % duplicación, conteos del ensayo de inyección de fallos) y cualitativo/conceptual en la fundamentación (CAP theorem, Two Generals Problem, trade-offs de diseño del motor). *Confirmar si la matriz de consistencia ya lo declara explícitamente.* |
| **Diseño** | No experimental (diagnóstico); cuasi-experimental pre-post (validación) | Se diagnostica el problema de pérdida/duplicación tal como ocurre hoy (no experimental), y luego se valida el motor comparando el comportamiento *sin* watermarks vs. *con* watermarks bajo el mismo banco de pruebas (cuasi-experimental, sin asignación aleatoria, sobre banco simulado). |
| **Corte** | Transversal | El ensayo de inyección de fallos se ejecuta en una ventana de tiempo acotada; no es un seguimiento longitudinal. |
| **Método** | Analítico y sintético | Se descompone el problema de consistencia distribuida (análisis) y se construye el mecanismo que lo resuelve (síntesis). |
| **Población y muestra** | **Pendiente de confirmar.** Propuesta: lecturas de consumo energético generadas por nodos edge simulados en el banco de pruebas; muestreo por diseño (ciclos de corte/restauración controlados), no probabilístico. | No hay administradores como unidad de muestreo — la "población" son los eventos/lecturas que atraviesan el pipeline. Precisar con los parámetros finales del ensayo (número de nodos, cadencia de lectura, duración de interrupción). |
| **Unidad de análisis** | La transacción de sincronización de una lectura individual entre el buffer local (edge) y el almacén central (TimescaleDB) | Es la unidad mínima que se mide como perdida, duplicada o consolidada. |
| **Metodología de desarrollo** | **Pendiente de confirmar.** Cascada si los objetivos (OE1–OE4) están fijos y no cambian durante el desarrollo; iterativo-incremental si el motor se construyó en fases con retroalimentación. | Depende de cómo se trabajó realmente, no de cuál "suena mejor" — definir antes de llevarlo a la diapositiva final. |

---

**Pendientes antes de cerrar esta tabla:**

1. Confirmar enfoque (mixto) con lo ya declarado en la matriz de consistencia.
2. Definir población y muestra con los parámetros finales del ensayo (nodos, cadencia, `OUTAGE_SECONDS`).
3. Confirmar metodología de desarrollo (cascada vs. iterativo-incremental) según cómo se desarrolló el proyecto en la práctica.
