select
    customer_id,
    round(sum(total_price::decimal),2) as total_revenue,
    extract(day from max(created_at::timestamp) - min(created_at::timestamp)) as customer_lifetime_days,
    round(sum(total_price::decimal) / greatest(extract(day from max(created_at::timestamp) - min(created_at::timestamp)),1),2) as clv_per_day,
    max(created_at::timestamp) as last_purchase_date
from
    super.order_data
group by
    customer_id