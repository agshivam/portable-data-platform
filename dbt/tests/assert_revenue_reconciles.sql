-- Monthly revenue must add up to the fact table (non-returned lines). Returns a row only if they differ by more than a cent.
select a.total, b.total from
 (select sum(revenue) as total from {{ ref('agg_monthly_revenue') }}) a,
 (select sum(line_amount) as total from {{ ref('fct_order_items') }} where status <> 'returned') b
where abs(a.total - b.total) > 0.01
