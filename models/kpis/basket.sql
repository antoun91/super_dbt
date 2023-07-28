
SELECT AVG(quantity) AS avg_basket_size
FROM super.order_line_data
JOIN super.order_data ON order_line_data.order_id = order_data.id