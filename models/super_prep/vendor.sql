select
	id as vendor_id,
	title as vendor_name,
	created_at::timestamp as created_at
from {{source ('super', 'vendor')}}