select 
	id::int as customer_id,
	name,
	gender,
	email,
	"state",
	country,
	created_at::timestamp as created_at
 from {{source ('super', 'customer')}}