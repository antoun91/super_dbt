select
    o.customer_id,
    c.name,
    c.gender,
    c.state,
    round(sum(o.total_price),2) as total_revenue,
    extract(day from max(o.created_at) - min(o.created_at)) as customer_lifetime_days,
    round(sum(o.total_price) / greatest(extract(day from max(o.created_at) - min(o.created_at)),1),2) as clv_per_day,
    date_trunc('month', min(o.created_at)) as first_purchase_month,
    date_trunc('month', max(o.created_at)) as last_purchase_month
from {{ref ('order')}} as o
left join {{ref ('customer')}} as c
    on c.customer_id = o.customer_id
group by
    o.customer_id, c.name, c.gender, c.state