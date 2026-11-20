"""Append the latest dbt run (dbt/target/run_results.json) to app_data/run_history.parquet, tagged with the target.
Run after dbt build:  python scripts/record_run.py duckdb"""
import json
import sys
from datetime import datetime, timezone
from pathlib import Path

import pandas as pd

ROOT = Path(__file__).resolve().parent.parent
target = sys.argv[1] if len(sys.argv) > 1 else "duckdb"
res = json.load(open(ROOT / "dbt" / "target" / "run_results.json"))
rows = res["results"]
ok = {"success", "pass"}
rec = {
    "run_at": datetime.now(timezone.utc).replace(tzinfo=None),
    "target": target,
    "dbt_version": res["metadata"]["dbt_version"],
    "nodes": len(rows),
    "passed": sum(r["status"] in ok for r in rows),
    "failed": sum(r["status"] in {"error", "fail"} for r in rows),
    "skipped": sum(r["status"] == "skipped" for r in rows),
    "seconds": round(res["elapsed_time"], 2),
}
out = ROOT / "app_data" / "run_history.parquet"
df = pd.DataFrame([rec])
if out.exists():
    df = pd.concat([pd.read_parquet(out), df], ignore_index=True)
df.tail(200).to_parquet(out, index=False)
print(rec)
