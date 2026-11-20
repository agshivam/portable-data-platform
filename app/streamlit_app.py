from pathlib import Path

import altair as alt
import pandas as pd
import streamlit as st

st.set_page_config(page_title="Portable data platform", layout="wide")
D = Path(__file__).resolve().parent.parent / "app_data"
st.title("Portable data platform")
st.caption("One dbt project, two warehouses. The same models and tests run on DuckDB (free, every pull request) "
           "and Snowflake (daily). Data is synthetic.")

hist = pd.read_parquet(D / "run_history.parquet")
st.subheader("Run history")
latest = hist.iloc[-1]
a, b, c, d = st.columns(4)
a.metric("Last run", latest["target"])
b.metric("Passed", int(latest["passed"]))
c.metric("Failed", int(latest["failed"]))
d.metric("Seconds", f"{latest['seconds']:.1f}")
st.dataframe(hist.sort_values("run_at", ascending=False), hide_index=True, width="stretch")

rev = pd.read_parquet(D / "agg_monthly_revenue.parquet")
ret = pd.read_parquet(D / "agg_category_returns.parquet")
for col in ["revenue", "avg_order_value"]:
    rev[col] = rev[col].astype(float)
ret["return_rate"] = ret["return_rate"].astype(float)
t1, t2 = st.tabs(["Revenue", "Returns"])
with t1:
    regions = st.multiselect("Region", sorted(rev["region"].unique()), default=sorted(rev["region"].unique()))
    v = rev[rev["region"].isin(regions)]
    st.altair_chart(alt.Chart(v).mark_bar().encode(x="month:T", y="revenue:Q", color="region:N",
                    tooltip=["month", "region", "revenue", "orders"]), width="stretch")
with t2:
    st.altair_chart(alt.Chart(ret).mark_bar().encode(x="category:N", y=alt.Y("return_rate:Q", axis=alt.Axis(format="%")),
                    tooltip=["category", "lines", "returned_lines", "return_rate"]), width="stretch")
