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

The way this is modeled makes it incredibliy easily to create line charts or bar charts in a visualization tool and easily have all 4 kpis in the same dashbboard to see trends and how they all relate over time. 

### Question 2

Creating models to track:
Customer Lifetime Value and Customer Retention Rate

I created two new models in the `super_analytics` schema for these two kpis.


#### Customer Lifetime Value
Running:

`select * from super_analytics.customer_lifetime_value;`

Will result in a model that is broken out by customer_id / customer name. It will have total revenue from a customer, lifetime of days if they have made more than once purchase, avg value per day, and first and last months of purchases.

<img width="1006" alt="image" src="https://github.com/antoun91/super_dbt/assets/59941580/3bccf8e2-1c22-4309-8dcc-23242c4b5c83">

Modeling the customer lifetime value this way does two things:

- It allows a quick view of all customers and their lifetime value
- Adding in the `first_month_purchase` easily allows an anlayst to create monthly cohorts to look a trends over time.

#### Customer Retention Rate

For the Customer Retention Rate, I built a model on top of the order data by self joining it in order to get a future look forward. 

The table is broken out by month, where it has active customers in the current month and a second column for customers who were active in the current month and the following month. Lastly it has a retention rate column. 

Since there was only 3 months of data, I was only able to compute retention rates for Jan and Feb. March shows a 0 for retained_customers and retention rate but as soon as more data was inserted for April, that data would populate. 

This data can be seen by running:

`select * from super_analytics.customer_retention;`


<img width="732" alt="image" src="https://github.com/antoun91/super_dbt/assets/59941580/16efca48-179c-4d09-9d66-b4a44111cadc">

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

<img width="219" alt="image" src="https://github.com/antoun91/super_dbt/assets/59941580/49d05daf-ec92-460d-95b6-3210f33a4fe8">

You could also very easily swap out gender for state

```
select
  gender, 
  sum(total_revenue)
from super_analytics.customer_lifetime_value
  group by gender
  order by sum(total_revenue) desc;
```

But what we find out is that both men and woment shop at you grow almost equally 

<img width="194" alt="image" src="https://github.com/antoun91/super_dbt/assets/59941580/b9dc758a-ddbc-4533-b446-171c45008c74">


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

<img width="386" alt="image" src="https://github.com/antoun91/super_dbt/assets/59941580/52b17879-25d6-48d4-80da-7bdb9ad5496b">


This allows you to easily first_purchase demographics over time. Beth can use this data to anticipate demand year over year as different states will have different seasonal needs for you grow products. 


I've tried to set up all these models in a way that is easy to bring into a visualization tool and not have to do very much data manipulation in the tool itself. 
For example: the demographics data could easily be a quick bar chart comparing different states by revenue. Or you could put it on a graph chart to plot the states revenue over time/seasonality over the year. 


### Question 3

In order to drive more repeat customers, Beth has decided to launch a subscription product. How would you integrate this into your data model? What, if anything, from questions 1-2 would you update to account for this new revenue model?

In order to track a subscription model I would add a flag column to the order table that told me if a customer was a subscriber at the time of order. It would be as simple as a boolean flag that indictated a customer subscription status. 

I would also add a new model for `customer_subscriptions` where I would keep track of converstion rates of new customers -> new subscribors on a month over month basis. It could also track subscription retention rates as well. 
This would be similar to the `customer_retention` model. Schema would be something like 
```
year_month | active_subscribers | active_subscribers | new_subscribers | subscription_rate | canceled_subscriptions | churn_rate


```
