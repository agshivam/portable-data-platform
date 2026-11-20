with orders as (
    select customer_id, count(distinct order_id) as order_count, sum(line_amount) as lifetime_value,
           min(order_date) as first_order_date, max(order_date) as last_order_date
    from {{ ref('fct_order_items') }} where status <> 'returned' group by 1
)
select c.customer_id, c.customer_name, c.region, c.signup_date,
       coalesce(o.order_count, 0) as order_count, coalesce(o.lifetime_value, 0) as lifetime_value,
       o.first_order_date, o.last_order_date,
       {{ dbt.datediff('c.signup_date', 'o.first_order_date', 'day') }} as days_to_first_order
from {{ ref('stg_customers') }} c left join orders o using (customer_id)
