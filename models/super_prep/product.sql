select 
    product as product_id,
    title as product_name,
    category::int as category_id,
    price::decimal as price,
    cost::decimal as cost,
    vendor as vendor_id,
    created_at::timestamp as created_at
from {{source ('super', 'product')}}