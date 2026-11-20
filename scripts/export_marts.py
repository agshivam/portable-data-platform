"""Export mart tables to Parquet for the Streamlit report.  python scripts/export_marts.py"""
from pathlib import Path

import duckdb

ROOT = Path(__file__).resolve().parent.parent
con = duckdb.connect(str(ROOT / "data" / "shop.duckdb"), read_only=True)
out = ROOT / "app_data"
for t in ["agg_monthly_revenue", "agg_category_returns", "dim_customer"]:
    con.execute(f"copy (select * from marts.{t}) to '{out / (t + '.parquet')}' (format parquet)")
    print("exported", t)
