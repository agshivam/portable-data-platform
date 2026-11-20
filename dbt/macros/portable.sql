{# Cross-warehouse helpers. adapter.dispatch picks the right version for the target. Most needs are covered by
   dbt's own cross-database macros (dbt.date_trunc, dbt.datediff, dbt.listagg); these show the pattern for the rest. #}

{% macro safe_divide(numerator, denominator) -%}
  {{ return(adapter.dispatch('safe_divide', 'portable_shop')(numerator, denominator)) }}
{%- endmacro %}

{% macro default__safe_divide(numerator, denominator) -%}
  case when {{ denominator }} = 0 or {{ denominator }} is null then null else {{ numerator }} * 1.0 / {{ denominator }} end
{%- endmacro %}

{% macro snowflake__safe_divide(numerator, denominator) -%}
  div0null({{ numerator }}, {{ denominator }})
{%- endmacro %}

{% macro duckdb__safe_divide(numerator, denominator) -%}
  {{ numerator }} / nullif({{ denominator }}, 0)
{%- endmacro %}

{% macro month_start(date_col) -%}
  cast({{ dbt.date_trunc('month', date_col) }} as date)
{%- endmacro %}
