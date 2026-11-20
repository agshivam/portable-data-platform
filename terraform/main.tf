# Snowflake objects the dbt project needs: a database, three schemas, a small warehouse that suspends fast,
# a transformer role, a CI user that signs in with a key pair, and a resource monitor so a mistake cannot burn credits.
# NOT applied from here: needs your Snowflake account (see HOW_TO_RUN.md). Review with `terraform plan` first.
terraform {
  required_providers {
    snowflake = { source = "Snowflake-Labs/snowflake", version = "~> 1.0" }
  }
}

variable "organization_name" { type = string }
variable "account_name" { type = string }
variable "admin_user" { type = string }
variable "ci_public_key" {
  type        = string
  description = "Public half of the CI key pair, without the BEGIN/END lines"
}

provider "snowflake" {
  organization_name = var.organization_name
  account_name      = var.account_name
  user              = var.admin_user
  role              = "ACCOUNTADMIN"
  authenticator     = "SNOWFLAKE_JWT"
  private_key       = file(pathexpand("~/.snowflake/admin_key.p8"))
}

resource "snowflake_database" "portable" { name = "PORTABLE" }

resource "snowflake_schema" "layers" {
  for_each = toset(["RAW", "STAGING", "MARTS", "DBT"])
  database = snowflake_database.portable.name
  name     = each.value
}

resource "snowflake_resource_monitor" "cap" {
  name            = "PORTABLE_MONITOR"
  credit_quota    = 5
  frequency       = "MONTHLY"
  start_timestamp = "IMMEDIATELY"
  notify_triggers = [75, 90]
  suspend_trigger = 100
}

resource "snowflake_warehouse" "wh" {
  name                = "PORTABLE_WH"
  warehouse_size      = "XSMALL"
  auto_suspend        = 60
  auto_resume         = "true"
  initially_suspended = true
  resource_monitor    = snowflake_resource_monitor.cap.name
}

resource "snowflake_account_role" "transformer" { name = "TRANSFORMER" }

resource "snowflake_grant_privileges_to_account_role" "wh_usage" {
  account_role_name = snowflake_account_role.transformer.name
  privileges        = ["USAGE"]
  on_account_object {
    object_type = "WAREHOUSE"
    object_name = snowflake_warehouse.wh.name
  }
}

resource "snowflake_grant_privileges_to_account_role" "db_all" {
  account_role_name = snowflake_account_role.transformer.name
  privileges        = ["USAGE", "CREATE SCHEMA"]
  on_account_object {
    object_type = "DATABASE"
    object_name = snowflake_database.portable.name
  }
}

resource "snowflake_grant_privileges_to_account_role" "schema_all" {
  for_each          = snowflake_schema.layers
  account_role_name = snowflake_account_role.transformer.name
  all_privileges    = true
  on_schema {
    schema_name = "\"${snowflake_database.portable.name}\".\"${each.value.name}\""
  }
}

resource "snowflake_user" "ci" {
  name              = "PORTABLE_CI"
  default_role      = snowflake_account_role.transformer.name
  default_warehouse = snowflake_warehouse.wh.name
  rsa_public_key    = var.ci_public_key
}

resource "snowflake_grant_account_role" "ci_role" {
  role_name = snowflake_account_role.transformer.name
  user_name = snowflake_user.ci.name
}
