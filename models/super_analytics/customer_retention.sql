select
  date_trunc('month', o.created_at) as year_month, 
  count(distinct o.customer_id) as active_customers_this_month, 
  count(distinct future_order.customer_id) as retained_customers_following_month,
  round(count(distinct future_order.customer_id)::decimal / count(distinct o.customer_id)::decimal, 2) as retention_rate
from {{ref ('order')}} as o
left join {{ref ('order')}} as future_order on
  o.customer_id = future_order.customer_id
  and date_trunc('month', o.created_at) = date_trunc('month', future_order.created_at) - interval '1 month'
group by 1