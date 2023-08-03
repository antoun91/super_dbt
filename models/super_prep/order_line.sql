select
	id as order_line_id,
	order_id,
	product_id,
	quantity::decimal as quantity,
	total_price::decimal as total_price
from {{source ('super', 'order_line')}}