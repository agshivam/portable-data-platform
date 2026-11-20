# Portable platform layer

One dbt project that runs on Snowflake and DuckDB, with Terraform and a daily automated run.

**Status:** planned, build starts in week 5. All data is public or synthetic. No employer data is used.

## Plan

1. Write dbt models with cross-database macros.
2. Run the same tests on DuckDB and Snowflake and compare results.
3. Manage Snowflake objects with Terraform.
4. Run a daily GitHub Actions job and show run history in Streamlit.

## Part of a series

This is one of six portfolio projects. The first one, [patient-360](https://github.com/agshivam/patient-360), is already live with a [running report](https://patient-360.streamlit.app/). Portfolio: https://agshivam.github.io
