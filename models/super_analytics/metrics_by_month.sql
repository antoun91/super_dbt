with b1 as (
    select 
        order_id,
        date_trunc('month', ordered_at) as year_month,
        sum(quantity)  as basket_size
    from {{ref ('customer_order_log')}} 
    group by 1,2
),

basket as (
    select
        year_month,
        round(avg(basket_size),2) as avg_basket_size
    from b1
    group by 1
),

gmv as (
    select
        date_trunc('month', ordered_at) as year_month,
        sum(quantity*price) as gmv
    from {{ref ('customer_order_log')}}  
    group by 1
),
avg_order_value as (
    select 
        date_trunc('month', created_at) as year_month,
        round(avg (total_price::decimal), 2) as avg_order_value
    from {{ref ('order')}} 
    group by 1
),
active_customers as (
    select 
        date_trunc('month', created_at) as year_month,
        count(distinct customer_id) as active_customers
    from {{ref ('order')}} 
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
