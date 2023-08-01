select
	id as order_id,
	customer_id,
	currency,
	total_price::decimal as total_price,
	created_at::timestamp as created_at,
	(nullif(refunded_at, '')::timestamp) as refunded_at
from {{source ('super', 'order')}}