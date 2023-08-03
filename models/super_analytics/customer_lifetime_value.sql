select
    o.customer_id,
    o.name,
    c.gender,
    c.state,
    round(max(running_total),2) as total_revenue,
    extract(day from max(ordered_at) - min(customer_created_at)) as customer_lifetime_days,
    round(max(o.running_total) / greatest(extract(day from max(ordered_at) - min(ordered_at)),1),2) as clv_per_day,
    date_trunc('month', min(o.ordered_at)) as first_purchase_month,
    date_trunc('month', max(o.ordered_at)) as last_purchase_month
from {{ref ('customer_order_log')}} as o
left join {{ref ('customer')}} as c
    on c.customer_id = o.customer_id
group by
    o.customer_id, o.name, c.gender, c.state
    