select
  date_trunc('month', o.created_at::timestamp) as year_month, 
  count(distinct o.customer_id) as active_users, 
  count(distinct future_order.customer_id) as retained_users,
  round(count(distinct future_order.customer_id)::decimal / count(distinct o.customer_id)::decimal, 2) as retention
from super.order_data as o
left join super.order_data as future_order on
  o.customer_id = future_order.customer_id
  and date_trunc('month', o.created_at::timestamp) = date_trunc('month', future_order.created_at::timestamp) - interval '1 month'
group by 1