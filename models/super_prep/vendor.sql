select
	id as vendor_id,
	title,
	created_at::timestamp as created_at
from {{source ('super', 'vendor')}}