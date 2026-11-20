# How to run Portable data platform

## 1. DuckDB (no account, 2 minutes)
```bash
git clone https://github.com/agshivam/portable-data-platform && cd portable-data-platform
pip install -r requirements-dev.txt -r requirements.txt
mkdir -p data && cd dbt && dbt build --target duckdb --profiles-dir . && cd ..
# expect: PASS=34 WARN=0 ERROR=0
python scripts/record_run.py duckdb
python scripts/export_marts.py
streamlit run app/streamlit_app.py
```
To change the data: `python scripts/make_seeds.py`, then rebuild.

## 2. Snowflake (week 2, after you start the free trial)
1. Make a key pair: `openssl genrsa 2048 | openssl pkcs8 -topk8 -inform PEM -out ~/.snowflake/admin_key.p8 -nocrypt` then `openssl rsa -in ~/.snowflake/admin_key.p8 -pubout -out admin_key.pub`.
   Do the same for a second pair for CI (`ci_key.p8`, `ci_key.pub`). Never commit `.p8` files.
2. In Snowflake, set the public key on your admin user (`ALTER USER <you> SET RSA_PUBLIC_KEY='...'`).
3. Create everything: `cd terraform && terraform init && terraform plan`, read the plan, then `terraform apply`. Variables: `organization_name`, `account_name`, `admin_user`, `ci_public_key` (contents of `ci_key.pub` without the BEGIN/END lines).
4. Run dbt on Snowflake from your machine:
```bash
pip install dbt-snowflake
export SNOWFLAKE_ACCOUNT=<org>-<account> SNOWFLAKE_USER=PORTABLE_CI SNOWFLAKE_PRIVATE_KEY_PATH=/path/ci_key.p8
cd dbt && dbt build --target snowflake --profiles-dir .
```
5. Turn on the daily run: in GitHub, Settings, Secrets and variables, Actions: add secrets `SNOWFLAKE_ACCOUNT`, `SNOWFLAKE_USER`, `SNOWFLAKE_PRIVATE_KEY` (the text of `ci_key.p8`), and a variable `SNOWFLAKE_ENABLED` = `true`.
6. When finished experimenting: `terraform destroy`.

## Deploy the report
share.streamlit.io, New app, this repo, main file `app/streamlit_app.py`.

## Troubleshooting
- `Could not find profile`: add `--profiles-dir .` and run from the `dbt` folder.
- DuckDB file locked: close any other process using `data/shop.duckdb`.
- Snowflake `JWT token is invalid`: the public key on the user does not match the private key file.
