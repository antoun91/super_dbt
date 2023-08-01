select
    customer_id,
    round(sum(total_price),2) as total_revenue,
    extract(day from max(created_at) - min(created_at)) as customer_lifetime_days,
    round(sum(total_price) / greatest(extract(day from max(created_at) - min(created_at)),1),2) as clv_per_day,
    date_trunc('month', min(created_at)) as first_purchase_month,
    date_trunc('month', max(created_at)) as last_purchase_month
from
    {{ref ('order')}}
group by
    customer_id