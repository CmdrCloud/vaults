erDiagram

    FACT_CHURN {
        int churn_id PK
        int cliente_id FK
        int municipio_id FK
        int fecha_id FK
        int churn_flag
        float revenue
        int tenure_dias
        int num_tickets
        int uso_producto
    }

    DIM_CLIENTE {
        int cliente_id PK
        string nombre
        string genero
        int edad
        string segmento
        date fecha_alta
        string tipo_cliente
    }

    DIM_MUNICIPIO {
        int municipio_id PK
        string municipio
        string region
        float ingreso_promedio
        int poblacion
    }

    DIM_FECHA {
        int fecha_id PK
        date fecha
        int dia
        int mes
        int anio
        int semana
        string dia_semana
        boolean es_fin_semana
    }

    DIM_PLAN {
        int plan_id PK
        string nombre_plan
        float precio
        string tipo_plan
        string duracion
    }

    DIM_CLIENTE ||--o{ FACT_CHURN : tiene
    DIM_MUNICIPIO ||--o{ FACT_CHURN : ocurre_en
    DIM_FECHA ||--o{ FACT_CHURN : en_fecha
    DIM_PLAN ||--o{ FACT_CHURN
