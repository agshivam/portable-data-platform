select * from {{ ref('agg_category_returns') }} where return_rate < 0 or return_rate > 1
