select

	ol.order_line_id,
	o.customer_id,
	ol.order_id,
	c.name,
	c.state,
	c.email,
	c.created_at as customer_created_at,
	ol.product_id,
	ol.quantity,
	p.price,
	p.cost,
	(p.price-p.cost)*ol.quantity as net_profit,
    
	sum(p.price*case when o.is_refunded then 0 else ol.quantity end ) over (partition by o.customer_id order by ol.order_id) as running_total,

	p.product_name,
	o.created_at as ordered_at,
	case when o.refunded_at is null then false else true end as is_refunded,
	v.vendor_name
	
from super_prep.order_line as ol
left join super_prep.order as o
	on o.order_id = ol.order_id
left join super_prep.customer as c
	on o.customer_id = c.customer_id
left join super_prep.product as p
	on ol.product_id = p.product_id
left join super_prep.vendor as v
	on p.vendor_id = v.vendor_id
	
order by order_id, ordered_at