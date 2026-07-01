"""
dag_banking_etl.py
===================
ETL pipeline for Star Schema Data Warehouse.

Task flow:
    create_tables (SQLExecuteQueryOperator) : DDL for staging, dimensions, and facts.
    extract_*     (@task Python)            : read CSVs -> staging (or directly to dim_date).
    transform_dim (SQLExecuteQueryOperator) : stg_* -> dim_*
    transform_fact(SQLExecuteQueryOperator) : stg_transaction + stg_fraud_labels -> fact_transaction

Airflow Connection:
    conn_id = "postgres_etl"
"""

import os
from datetime import datetime, timedelta

import pandas as pd
from sqlalchemy import create_engine, text

from airflow.decorators import dag, task
from airflow.providers.common.sql.operators.sql import SQLExecuteQueryOperator

# ─── Konstanta ────────────────────────────────────────────────────────────────
CONN_ID = "postgres_etl"
DATASET_DIR = os.path.join(
    os.path.dirname(__file__), "..", "include", "dataset"
)

# Helper function to extract and load
def load_csv_to_table(filename: str, table_name: str, chunksize: int = 1000):
    from airflow.hooks.base import BaseHook
    
    source_file = os.path.join(DATASET_DIR, filename)
    conn = BaseHook.get_connection(CONN_ID)
    conn_str = (
        f"postgresql+psycopg2://{conn.login}:{conn.password}"
        f"@{conn.host}:{conn.port}/{conn.schema}"
    )
    engine = create_engine(conn_str)
    
    df = pd.read_csv(source_file)
    
    with engine.connect() as c:
        c.execute(text(f"TRUNCATE TABLE {table_name}"))
        c.commit()
        
    df.to_sql(
        name      = table_name,
        con       = engine,
        if_exists = "append",
        index     = False,
        method    = "multi",
        chunksize = chunksize,
    )
    engine.dispose()
    return len(df)


# ─── DAG ──────────────────────────────────────────────────────────────────────
@dag(
    dag_id              = "dag_banking_etl",
    description         = "ETL pipeline for Banking Star Schema",
    default_args        = {
        "owner"           : "airflow",
        "retries"         : 1,
        "retry_delay"     : timedelta(minutes=5),
        "email_on_failure": False,
    },
    start_date          = datetime(2025, 1, 1),
    schedule            = None,
    catchup             = False,
    tags                = ["etl", "banking", "data-warehouse", "star-schema"],
    template_searchpath = ["/opt/airflow/include/sql/banking_dw"],
)
def dag_banking_etl():

    # ── Task 1: DDL ───────────────────────────────────────────────────────────
    create_tables = SQLExecuteQueryOperator(
        task_id = "create_tables",
        conn_id = CONN_ID,
        sql     = "01_create_tables.sql",
    )

    # ── Task 2: Extracts ──────────────────────────────────────────────────────
    @task()
    def extract_branches():
        return load_csv_to_table("branches.csv", "stg_branches")

    @task()
    def extract_channels():
        return load_csv_to_table("channels.csv", "stg_channels")

    @task()
    def extract_accounts():
        return load_csv_to_table("accounts.csv", "stg_accounts")
        
    @task()
    def extract_dim_date():
        return load_csv_to_table("dim_date.csv", "dim_date")

    @task()
    def extract_transactions():
        return load_csv_to_table("transactions.csv", "stg_transaction", chunksize=5000)

    @task()
    def extract_fraud_labels():
        return load_csv_to_table("fraud_labels.csv", "stg_fraud_labels")

    # ── Task 3: Transforms ────────────────────────────────────────────────────
    transform_dimensions = SQLExecuteQueryOperator(
        task_id = "transform_dimensions",
        conn_id = CONN_ID,
        sql     = "02_transform_dimensions.sql",
    )

    transform_fact = SQLExecuteQueryOperator(
        task_id = "transform_fact",
        conn_id = CONN_ID,
        sql     = "03_transform_fact.sql",
    )

    # ── Dependencies ──────────────────────────────────────────────────────────
    extracts = [
        extract_branches(),
        extract_channels(),
        extract_accounts(),
        extract_dim_date(),
        extract_transactions(),
        extract_fraud_labels()
    ]
    
    create_tables >> extracts
    
    # After extracting, run dimension transforms, then fact transform
    extracts >> transform_dimensions >> transform_fact


dag_banking_etl()
