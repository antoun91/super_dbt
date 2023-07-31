with basket as (
    select 
        date_trunc('month', o.created_at::timestamp) as year_month,
	    avg(quantity) as avg_basket_size
    from super.order_line_data as ol
    inner join super.order_data as o
        on ol.order_id = o.id
    group by 1
),
gmv as (
    select
        date_trunc('month', created_at::timestamp) as year_month,
        sum(total_price) as gmv
    from super.order_data
    group by 1
),
avg_order_value as (
    select 
        date_trunc('month', created_at::timestamp) as year_month,
        round(avg (total_price::decimal), 2) as avg_order_value
    from super.order_data
    group by 1
),
active_customers as (
    select 
        date_trunc('month', created_at::timestamp) as year_month,
        count(distinct customer_id) as active_customers
    from super.order_data
    group by 1
)

select 
    g.year_month,
    g.gmv,
    b.avg_basket_size,
    v.avg_order_value,
    c.active_customers
from gmv as g 
left join basket as b
on b.year_month = g.year_month
left join avg_order_value as v
on v.year_month = g.year_month
left join active_customers as c
on c.year_month = g.year_month
