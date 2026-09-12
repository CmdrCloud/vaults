# Cloud Data Architecture

A complete, production-grade data architecture running in the cloud.

---

## Layers

### 1. Ingestion

| Mode | Tools |
| ------ | ------- |
| Real-time | Kafka, Kinesis, Event Hubs |
| Batch | Cloud Storage (S3/GCS/ADLS), Airflow |
| CDC | Debezium, DMS, Striim |

### 2. Storage (Medallion)

| Layer | Format | Purpose |
| ------- | -------- | --------- |
| **Bronze** | Raw (JSON/CSV/Avro) | Immutable, schema-on-read, full fidelity |
| **Silver** | Parquet / Delta Lake / Iceberg | Cleaned, deduped, validated |
| **Gold** | Star-schema fact/dimension tables | Aggregated, business-ready |

### 3. Processing

- **Batch** — Spark, Trino, dbt (SQL transformations)
- **Streaming** — Flink, Spark Streaming, ksqlDB
- **Orchestration** — Airflow, Dagster, Prefect

### 4. Catalog & Governance

- **Catalog** — Unity Catalog, DataHub, Amundsen, Atlan
- **Quality** — Great Expectations, dbt tests, Soda
- **Lineage** — OpenLineage, Marquez
- **Schema** — Confluent Schema Registry

### 5. Compute & Serving

- **Query engine** — Trino, Presto, Athena, Redshift, BigQuery, Snowflake
- **BI** — Superset, Metabase, Looker, Power BI
- **Feature store** — Feast, Tecton (ML features)

### 6. Infrastructure

- **IaC** — Terraform, Pulumi
- **Container orchestration** — Kubernetes, Helm
- **CI/CD** — GitHub Actions, GitLab CI

### 7. Security

- IAM roles with least privilege
- KMS for encryption at rest / in transit
- VPC isolation, private endpoints
- Column / row-level access policies (via catalog)

### 8. Observability

- CloudWatch / Stackdriver / Azure Monitor
- Prometheus + Grafana (custom metrics)
- ELK / Loki (log aggregation)

---

## Implementation Order

1. **Terraform** object store + networking
2. **Kafka / Kinesis** + Schema Registry
3. **Spark + Trino** with Iceberg or Delta Lake
4. **Airflow + dbt** for orchestrated transforms
5. **Data catalog** with lineage tracking
6. **Quality gates** (Great Expectations)
7. **BI tool** wired to Trino / Snowflake
8. **Monitoring + alerts** (Prometheus / Grafana)

---

## Key Decisions

| Decision | Options |
| ---------- | --------- |
| Real-time vs batch | Both via dual pipeline (Kafka + Airflow) |
| Multi-cloud vs single | Single is simpler; multi adds abstraction cost |
| Managed vs open-source | Snowflake / BigQuery vs Trino / Iceberg / Spark |
| Table format | Delta Lake (Databricks), Iceberg, Hudi |
