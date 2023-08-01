Welcome to my Super case study!

### Question 1

Creating models to track:
GMV (Gross Merchandise Value), Average Order Value, Average Basket Size, and Active Customers

I created one model for all of these metrics. As most of them will likely want to be tracked on a month over month basis.
Running the following query: 

`select * from super_analytics.metrics_by_month;` 

Will result in a monthly row and columns for each metric that is being tracked. 

<img width="621" alt="image" src="https://github.com/antoun91/super_dbt/assets/59941580/7c3feb1f-c1c0-44cb-a55d-a134334efffe">

Modeling the data this way allows an analyst to easily get the metrics/kpis they are looking for, on a monthly basis. It allows them to trend over time how gmv or active customers changes and provide tactical advice to the business on how to improve their numbers.

### Question 2

Creating models to track:
Customer Lifetime Value and Customer Retention Rate

I created two new models in the `super_analytics` schema for these two kpis.

Running:

`select * from super_analytics.customer_lifetime_value;`

Will result in a model that is broken out by customer_id. It will have total revenue from a customer, lifetime of days if they have made more than once purchase, avg value per day, and first and last months of purchases.

<img width="761" alt="image" src="https://github.com/antoun91/super_dbt/assets/59941580/ee8d8af7-ffbc-4ba9-98d7-54465b875b0b">

Modeling the customer lifetime value this way does two things:

- It allows a quick view of all customers and their lifetime value
- Adding in the `first_month_purchase easily` allows an anlayst to create monthly cohorts to look a trends over time 


For the Customer Retention Rate
