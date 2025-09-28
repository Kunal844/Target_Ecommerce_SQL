#import the dataset and do the exploratory analysis steps like checking the structure of the dataset.
#Datatype of the columns in the customers table 
#Get the time range between which the orders were placed.
select * from 
Target_SQL.customers limit 10;

#Get the time range between which the orders were placed.
select 
min(order_purchase_timestamp) as minstamp
,max(order_purchase_timestamp) as maxstamp
from Target_SQL.orders;

#Count the Cities and States of customers who ordered during the given period
select c.customer_city,c.customer_state 
from Target_SQL.customers as c
join Target_SQL.orders as o on c.customer_id=o.customer_id
Where Extract(year from o.order_purchase_timestamp)=2018
AND Extract(month from o.order_purchase_timestamp) between 1 and 3;

#Is there a growing trend over the number of orders over the years 
select 
extract (month from order_purchase_timestamp) as month ,
count(order_id) as order_num
from Target_SQL.orders 
group by extract(month from order_purchase_timestamp)
order by order_num desc;

#During which time of the day do the Brazillian customers place their orders(Dawn, morning , afternoon , Night)
#0-6hrs :Dawn   7-12hrs:Morning    13-18hrs:Afternoon   19-23hrs:Night

select 
extract (hour from order_purchase_timestamp) as time ,
count(order_id) as order_num
from Target_SQL.orders 
group by extract(hour from order_purchase_timestamp)
order by order_num desc;
--Get the month on month no of orders placed in each state
select
extract(month from order_purchase_timestamp) as month,
extract(year from order_purchase_timestamp) as year,
count(*) as num_orders 
from Target_SQL.orders
group by month,year;

--Districbution of Customers Across the States of Brazil...
SELECT customer_state ,
count(distinct customer_id) as customer_count
from Target_SQL.customers
group by customer_state;

--% increase in the cost of orders from year 2017-18 , (months included are Jan to Aug)only..
WITH yearly_total as(
SELECT
extract(year from o.order_purchase_timestamp)as year,
Sum(p.payment_value) as total_payment
from `Target_SQL.payments` as p
join `Target_SQL.orders` as o
on p.order_id=o.order_id
where extract(year from o.order_purchase_timestamp) in (2017,2018)
and extract(month from o.order_purchase_timestamp) between 1 and 8
Group by extract(year from o.order_purchase_timestamp) 
),

yearly_comparison AS(
  SELECT
  year, total_payment,
  LEAD(total_payment) over(order by year desc) as prev_year_payment
  from yearly_total
)

SELECT round((total_payment - prev_year_payment/prev_year_payment)*100,2)
from yearly_comparison;

#Mean and SUm of the price and frieght value by customer state--
SELECT 
c.customer_state,
AVG(price) as avg_price,
SUM(price) as sum_price,
AVG(freight_value) as avg_freight,
SUM(freight_value) as sum_freight 
FROM `Target_SQL.orders` AS o
JOIN `Target_SQL.order_items` AS oi
  ON o.order_id = oi.order_id
JOIN `Target_SQL.customers` AS c
  ON o.customer_id = c.customer_id
  GROUP BY c.customer_state;

#Calculate days between purchasing , delivering and estimated delivery..
Select order_id,
DATE_DIFF(DATE(order_delivered_customer_date),DATE(order_purchase_timestamp),DAY) as days_to_delivery,
DATE_DIFF(DATE(order_delivered_customer_date),DATE(order_estimated_delivery_date),DAY) as diff_estimated_delivery
from`Target_SQL.orders`;

#Find out top 5 states with highest and lowest freight value
select c.customer_state,
AVG(freight_value) as avg_freight_value
from `Target_SQL.orders` as o
JOIN `Target_SQL.order_items` as oi
on o.order_id=oi.order_id
JOIN `Target_SQL.customers` as c
on o.customer_id=c.customer_id
group by customer_state
order by avg_freight_value desc
LIMIT 5;


#Find out top 5 states with highest and lowest average delivery time 
select c.customer_state,
AVG(Extract (DATE from o.order_delivered_customer_date)-Extract(DATE from o.order_purchase_timestamp)) as avg_time_to_delivery
from `Target_SQL.orders` as o
JOIN `Target_SQL.order_items` as oi
on o.order_id=oi.order_id
JOIN `Target_SQL.customers` as c
on o.customer_id=c.customer_id
group by customer_state
order by avg_time_to_delivery desc
LIMIT 5;

#Find the month on month no of orders placed using different payment types.
Select 
payment_type,
extract(year from order_purchase_timestamp) as year,
extract(month from order_purchase_timestamp) as month,
COUNT(distinct o.order_id)as order_count
From `Target_SQL.orders` as o
inner join `Target_SQL.payments` as p 
on o.order_id=p.order_id
group by payment_type,year,month
order by payment_type,year,month;
