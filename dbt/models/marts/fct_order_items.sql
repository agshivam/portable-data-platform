select
    i.item_id, i.order_id, o.customer_id, i.product_id, o.order_date, o.status,
    i.quantity, p.unit_price, i.quantity * p.unit_price as line_amount
from {{ ref('stg_order_items') }} i
join {{ ref('stg_orders') }} o using (order_id)
join {{ ref('stg_products') }} p using (product_id)
