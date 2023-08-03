## Welcome to my Super case study!

### My Approach

I designed my data architecture in layers. 
I have a raw layer, prep layer, and analytics layer.

The raw layer is to hold the raw data pulled off of the google sheet of sample data. There is a 1:1 relationship between the tables in `super_raw` and the tabs on the google sheet. I have a table for `customer`, `order`, `order_line`, `product`, and `vendor`. There is no transformation in this layer. It simply holds the data from our source systems.

The prep layer has a 1:1 relationship with the raw layer, but with some minor transformations. These are views, instead of tables so that as more data gets added from source systems into the raw layer, there is no need to remodel the data or run additional dbt scripts to keep the prep layer up to date. The transformations that take place in `super_prep` are minor, but important. Things are renamed to be more verbose, such as `id` to `customer_id`. And I added a column on the `order` table to be a boolean for `is_refunded`. These small changes make it much easier for analysts downstream to understand what is happening in the data and takes significantly less mental overhead to follow.

There are other transformations as well, date strings are casted to timestamps and price and cost fields are cast to decimals. This simply makes the mathmatical computations in the analytics layer easier and cleaner to write, rather than casting everything when you have to do the math itself. ie `round(sum(ol.total_price),2) as revenue` vs `round(sum(ol.total_price::decimal),2) as revenue`

Lastly, there is the analytics layer. `super_analytics` holds the imporant business objects and kpis that Beth is looking for. These are modeled as tables but could also be modeled as views depending on business use cases and freshness requirements. There are pros and cons to both, the main ones being that tables will load faster and be more performant as data grows and dashboards are built on top and views being better when it comes to up to date or live data.

### Question 1

Creating models to track:
GMV (Gross Merchandise Value), Average Order Value, Average Basket Size, and Active Customers

I created one model for all of these metrics. As most of them will likely want to be tracked on a month over month basis.
Running the following query: 

`select * from super_analytics.metrics_by_month;` 

Will result in a monthly row and columns for each metric that is being tracked. 

<img width="618" alt="image" src="https://github.com/antoun91/super_dbt/assets/59941580/9ba57d08-a3e2-4f9b-bd9e-fbe494deda7b">

Modeling the data this way allows an analyst to easily get the metrics/kpis they are looking for, on a monthly basis. It allows them to trend over time how gmv or active customers changes and provide tactical advice to the business on how to improve their numbers.

The way this is modeled makes it incredibliy easily to create line charts or bar charts in a visualization tool and easily have all 4 kpis in the same dashbboard to see trends and how they all relate over time. 

### Question 2

Creating models to track:
Customer Lifetime Value and Customer Retention Rate

I created three new models in the `super_analytics` schema for these two kpis.

### Customer Order Log

This model is a superset of the `order_line` data. It allows a single pane to view all customer transations, running totals, if an order was refunded, etc. As the business grew, I would make this model and incremental dbt model in order to make it a more performant table. This model allows a variety of kpis and metrics to be run from it, and as more metrics are likely wanted in the future, it creates a good base for analysts and data scientists to build from. I have added columns such as `net_profit`, `running_total`, and `is_refunded` to give Beth and her analysts easy access to various cuts of data she may want. 

`select * from super_analytics.customer_order_log;`

<img width="1690" alt="image" src="https://github.com/antoun91/super_dbt/assets/59941580/87e9584f-9ff5-43e0-85a2-5d76ebf6d991">



#### Customer Lifetime Value
Running:

`select * from super_analytics.customer_lifetime_value;`

Will result in a model that is broken out by customer_id / customer name. It will have total revenue from a customer, lifetime of days if they have made more than once purchase, avg value per day, and first and last months of purchases. If a customer was refunded for an order, that total is not included in the `total_revenue` column.

<img width="1001" alt="image" src="https://github.com/antoun91/super_dbt/assets/59941580/8565840b-6a5b-4005-aebe-315fb71988cc">

Modeling the customer lifetime value this way does two things:

- It allows a quick view of all customers and their lifetime value
- Adding in the `first_month_purchase` easily allows an anlayst to create monthly cohorts to look a trends over time.

#### Customer Retention Rate

For the Customer Retention Rate, I built a model on top of the order data by self joining it in order to get a future look forward. 

The table is broken out by month, where it has active customers in the current month and a second column for customers who were active in the current month and the following month. Lastly it has a retention rate column. 

Since there was only 3 months of data, I was only able to compute retention rates for Jan and Feb. March shows a 0 for retained_customers and retention rate but as soon as more data is inserted for April, that data would populate. 

This data can be seen by running:

`select * from super_analytics.customer_retention;`


<img width="717" alt="image" src="https://github.com/antoun91/super_dbt/assets/59941580/320e72ae-1ec8-43e3-8d96-7a7e34e65501">

Continuing to run the business and add more data, we are able to see trends like retention growth. Just from Jan -> Feb we saw and increase from 33% to 75% retention. 


When Beth asks for cuts of data like user demographics and first purchase attributes, demographics like location or gender can be easily queried from the customer_lifetime_value model.

```
select 
  state, 
  sum(total_revenue)
from super_analytics.customer_lifetime_value
  group by state
  order by sum(total_revenue) desc;
```

We can see that Florida customers spend signifcantly more than all the other states. Insights like this can provide direction on marketing campaign locations and how to target future customers.

<img width="253" alt="image" src="https://github.com/antoun91/super_dbt/assets/59941580/21d9246d-9f77-4a4e-8bdd-30e167fc8ae3">

You could also very easily swap out gender for state

```
select
  gender, 
  sum(total_revenue)
from super_analytics.customer_lifetime_value
  group by gender
  order by sum(total_revenue) desc;
```

But what we find out is that both men and woment shop at _YouGrow_ almost equally 

<img width="191" alt="image" src="https://github.com/antoun91/super_dbt/assets/59941580/9ad85d88-4472-4ba1-91ab-0a3bcd031c99">


When it comes to first purchase attributes, again, the customer_lifetime_value model is built in such a way to answer this question as well.

Running a query like:

```
select 
  state, 
  first_purchase_month, 
  sum(total_revenue) over (partition by state, first_purchase_month) as val
from super_analytics.customer_lifetime_value
  order by first_purchase_month, val desc;
```

<img width="344" alt="image" src="https://github.com/antoun91/super_dbt/assets/59941580/809ac775-ae8e-4ebf-906f-3dad9af51853">


This allows you to easily first_purchase demographics over time. Beth can use this data to anticipate demand year over year as different states will have different seasonal needs for _YouGrow_ products. 


Another query I thought would be helpful is to understand what the best selling products are at _YouGrow_. This query could be added as a model, either for all time, or month over month in order to see what products are or are not selling as well as calculated net profit on each product.

```
select 
  p.product_name, 
  ol.product_id, 
  p.price, 
  p.cost, 
  round(sum(ol.total_price),2) as revenue, 
  sum(quantity) as quantity
from super_prep.order_line as ol 
left join super_prep.product as p 
  on p.product_id = ol.product_id
group by ol.product_id, p.product_name, p.cost, p.price
order by revenue desc;
```

Returns results as:

<img width="497" alt="image" src="https://github.com/antoun91/super_dbt/assets/59941580/3ecfe50a-df65-48d9-9f25-e1f98386ecc6">


I've tried to set up all these models in a way that is easy to bring into a visualization tool and not have to do very much data manipulation in the tool itself. 
For example: the demographics data could easily be a quick bar chart comparing different states by revenue. Or you could put it on a graph chart to plot the states revenue over time/seasonality over the year. 


### Question 3

In order to drive more repeat customers, Beth has decided to launch a subscription product. How would you integrate this into your data model? What, if anything, from questions 1-2 would you update to account for this new revenue model?

In order to track a subscription model I would add a flag column to the order table that told me if a customer was a subscriber at the time of order. It would be as simple as a boolean column `subscriber` that was a true/false flag that indictated a customer subscription status. 

I would also add a new model for `customer_subscriptions` where I would keep track of converstion rates of new customers -> new subscribers on a month over month basis. It could also track subscription retention rates as well. 
This would be similar to the `customer_retention` model. Schema would be something like 
```
year_month | active_subscribers | retained_subscribers | new_subscribers | subscription_rate | canceled_subscriptions | churn_rate
```

`active_subscribers` would be the count of customers who had a subscription in a given month

`retained_subscribers` would be the count of customers who had a subscription in a given month and continued that subscription into the following month

`new_subscribers` would be the count of customers who signed up for subscription service in a given month 

`subscription_rate` would be a ratio of subscribers to total customers in a given month 

`canceled_subscriptions` would be the count of customers who ended their subscription in a given month

`churn_rate` would be a ratio of new subscribers to canceled subscribers in a given month 


I think adding a `subscriber` flag to the `order` table and adding in a `customer_subscriptions` model would allow _YouGrow_ to answer the questions posed here, as well as several others given the added subscription offering of the business 
