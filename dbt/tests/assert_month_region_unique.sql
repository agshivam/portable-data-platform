select month, region, count(*) from {{ ref('agg_monthly_revenue') }} group by 1, 2 having count(*) > 1
