select p.category,
       count(*) as lines,
       sum(case when f.status = 'returned' then 1 else 0 end) as returned_lines,
       {{ portable_shop.safe_divide("sum(case when f.status = 'returned' then 1 else 0 end)", 'count(*)') }} as return_rate
from {{ ref('fct_order_items') }} f join {{ ref('stg_products') }} p using (product_id)
group by 1
