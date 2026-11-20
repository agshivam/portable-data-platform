select {{ month_start('order_date') }} as month,
       category_region.region,
       sum(line_amount) as revenue,
       count(distinct order_id) as orders,
       {{ portable_shop.safe_divide('sum(line_amount)', 'count(distinct order_id)') }} as avg_order_value
from {{ ref('fct_order_items') }} f
join (select customer_id, region from {{ ref('stg_customers') }}) category_region using (customer_id)
where status <> 'returned'
group by 1, 2
