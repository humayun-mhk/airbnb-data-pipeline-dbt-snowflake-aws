# 🏠 airbnb-data-pipeline-dbt-snowflake-aws

> End-to-end data engineering pipeline for Airbnb data using AWS S3, Snowflake, and dbt — featuring medallion architecture, incremental loading, SCD Type 2, and analytics-ready gold layer models.

---

## 📌 Recommended GitHub Repo Name

```
airbnb-data-pipeline-dbt-snowflake-aws
```

---

## 📋 Overview

This project implements a complete **end-to-end ELT data engineering pipeline** for Airbnb data using modern cloud-native technologies. It demonstrates production-grade practices including data warehousing, transformation, testing, and documentation.

The pipeline processes Airbnb **listings**, **bookings**, and **hosts** data through a **Medallion Architecture** (Bronze → Silver → Gold), implementing incremental loading, Slowly Changing Dimensions (SCD Type 2), and analytics-ready datasets.

---

## 🏗️ Architecture

```
Source Data (CSV)
      │
      ▼
  AWS S3 (Data Lake)
      │
      ▼
Snowflake Staging
      │
      ├──► 🥉 Bronze Layer  →  Raw ingestion
      │
      ├──► 🥈 Silver Layer  →  Cleaned & standardized
      │
      └──► 🥇 Gold Layer    →  Analytics-ready (OBT + Fact Tables)
```

### Technology Stack

| Tool | Purpose |
|------|---------|
| **Snowflake** | Cloud data warehouse |
| **dbt (Data Build Tool)** | Transformation layer (ELT) |
| **AWS S3** | Raw data / data lake storage |
| **Python 3.12+** | Orchestration & scripting |
| **Git / GitHub** | Version control |

---

## 📊 Data Model — Medallion Architecture

### 🥉 Bronze Layer — Raw Ingestion
Minimal transformations; data loaded as-is from staging:

- `bronze_bookings` — Raw booking transactions
- `bronze_hosts` — Raw host information
- `bronze_listings` — Raw property listings

### 🥈 Silver Layer — Cleaned & Standardized
Validated, deduplicated, and enriched data:

- `silver_bookings` — Validated booking records
- `silver_hosts` — Enhanced host profiles with quality metrics
- `silver_listings` — Standardized listings with price categorization

### 🥇 Gold Layer — Analytics-Ready
Business-ready, optimized for BI and reporting:

- `obt` — One Big Table (denormalized: bookings + listings + hosts)
- `fact` — Fact table for dimensional modeling
- `ephemeral/` — Intermediate transformation models (no storage)

### 📸 Snapshots — SCD Type 2
Track historical changes with automatic valid-from/valid-to timestamps:

- `dim_bookings` — Historical booking changes
- `dim_hosts` — Historical host profile changes
- `dim_listings` — Historical listing changes

---

## 📁 Project Structure

```
airbnb-data-pipeline-dbt-snowflake-aws/
├── README.md
├── pyproject.toml
├── main.py
│
├── SourceData/
│   ├── bookings.csv
│   ├── hosts.csv
│   └── listings.csv
│
├── DDL/
│   ├── ddl.sql
│   └── resources.sql
│
└── aws_dbt_snowflake_project/
    ├── dbt_project.yml
    ├── ExampleProfiles.yml
    │
    ├── models/
    │   ├── sources/
    │   │   └── sources.yml
    │   ├── bronze/
    │   │   ├── bronze_bookings.sql
    │   │   ├── bronze_hosts.sql
    │   │   └── bronze_listings.sql
    │   ├── silver/
    │   │   ├── silver_bookings.sql
    │   │   ├── silver_hosts.sql
    │   │   └── silver_listings.sql
    │   └── gold/
    │       ├── fact.sql
    │       ├── obt.sql
    │       └── ephemeral/
    │           ├── bookings.sql
    │           ├── hosts.sql
    │           └── listings.sql
    │
    ├── macros/
    │   ├── generate_schema_name.sql
    │   ├── multiply.sql
    │   ├── tag.sql
    │   └── trimmer.sql
    │
    ├── analyses/
    │   ├── explore.sql
    │   ├── if_else.sql
    │   └── loop.sql
    │
    ├── snapshots/
    │   ├── dim_bookings.yml
    │   ├── dim_hosts.yml
    │   └── dim_listings.yml
    │
    ├── tests/
    │   └── source_tests.sql
    │
    └── seeds/
```

---

## 🚀 Getting Started

### Prerequisites

- **Snowflake** account
- **AWS** account (for S3 storage)
- **Python 3.12+**
- **pip** or **uv** package manager

### 1. Clone the Repository

```bash
git clone https://github.com/<your-username>/airbnb-data-pipeline-dbt-snowflake-aws.git
cd airbnb-data-pipeline-dbt-snowflake-aws
```

### 2. Create a Virtual Environment

```bash
python -m venv .venv

# Windows
.venv\Scripts\Activate.ps1

# macOS / Linux
source .venv/bin/activate
```

### 3. Install Dependencies

```bash
pip install -e .
```

Core dependencies: `dbt-core>=1.11.2`, `dbt-snowflake>=1.11.0`, `sqlfmt`

### 4. Configure Snowflake Connection

Create `~/.dbt/profiles.yml`:

```yaml
aws_dbt_snowflake_project:
  outputs:
    dev:
      type: snowflake
      account: <your-account-identifier>
      user: <your-username>
      password: <your-password>
      role: ACCOUNTADMIN
      database: AIRBNB
      warehouse: COMPUTE_WH
      schema: dbt_schema
      threads: 4
  target: dev
```

> ⚠️ **Never commit `profiles.yml`** — add it to `.gitignore`.

### 5. Initialize the Database

Run `DDL/ddl.sql` in Snowflake to create staging tables, then load CSV source files:

```
bookings.csv  →  AIRBNB.STAGING.BOOKINGS
hosts.csv     →  AIRBNB.STAGING.HOSTS
listings.csv  →  AIRBNB.STAGING.LISTINGS
```

---

## 🔧 Running dbt

```bash
cd aws_dbt_snowflake_project

# Verify connection
dbt debug

# Install packages
dbt deps

# Run all models
dbt run

# Run by layer
dbt run --select bronze.*
dbt run --select silver.*
dbt run --select gold.*

# Run data quality tests
dbt test

# Run SCD Type 2 snapshots
dbt snapshot

# Generate & serve documentation
dbt docs generate
dbt docs serve

# Full build (models + tests + snapshots)
dbt build
```

---

## 🎯 Key Features

### ⚡ Incremental Loading

Bronze and silver models process only new/changed records:

```sql
{{ config(materialized='incremental') }}

{% if is_incremental() %}
WHERE CREATED_AT > (SELECT COALESCE(MAX(CREATED_AT), '1900-01-01') FROM {{ this }})
{% endif %}
```

### 🏷️ Custom Macros

Reusable business logic via Jinja macros:

```sql
-- Categorize price into 'low', 'medium', 'high'
{{ tag('CAST(PRICE_PER_NIGHT AS INT)') }} AS PRICE_PER_NIGHT_TAG
```

### 🔄 Slowly Changing Dimensions (SCD Type 2)

Snapshots automatically maintain `valid_from` / `valid_to` timestamps, preserving full history for point-in-time analysis.

### 🗂️ Schema Organization

Models are automatically deployed to isolated schemas:

| Layer | Snowflake Schema |
|-------|-----------------|
| Bronze | `AIRBNB.BRONZE.*` |
| Silver | `AIRBNB.SILVER.*` |
| Gold | `AIRBNB.GOLD.*` |

---

## ✅ Data Quality & Testing

- Source data freshness and availability checks
- Unique key constraints on primary identifiers
- Not-null validation on critical columns
- Referential integrity between layers
- Custom business rule tests

---

## 🔐 Security Best Practices

- Store credentials in `~/.dbt/profiles.yml` (never committed)
- Use environment variables for CI/CD pipelines
- Apply role-based access control (RBAC) in Snowflake
- SQL formatting enforced via `sqlfmt`

---

## 📚 Resources

- [dbt Documentation](https://docs.getdbt.com/)
- [Snowflake Documentation](https://docs.snowflake.com/)
- [dbt Best Practices](https://docs.getdbt.com/guides/best-practices)

---

## 🗺️ Roadmap

- [ ] Data quality dashboards
- [ ] CI/CD pipeline integration
- [ ] Advanced business KPIs in gold layer
- [ ] BI tool integration (Tableau / Power BI)
- [ ] Alerting and monitoring
- [ ] PII data masking
- [ ] Expanded test coverage

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Commit your changes: `git commit -m 'Add your feature'`
4. Push to the branch: `git push origin feature/your-feature`
5. Open a Pull Request

---

## 👤 Author

**Ansh Lamba**  
Data Engineering Portfolio Project  
Stack: Snowflake · dbt · AWS S3 · Python

---

## 📝 License

This project is part of a data engineering portfolio demonstration.