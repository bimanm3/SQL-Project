select * from orders;
select * from order_details;
select * from pizza_types;
select * from pizzas;

select count(*) from orders;
select count(*) from order_details;
select count(*) from pizza_types;
select count(*) from pizzas;

#calculate total revenue generated from all sales 

select 
sum(p.price * od.quantity) as total_revenue
from pizzas as p
join
order_details as od 
on p.pizza_id = od.pizza_id;

#Rounded of to 2 numbers
select 
round(sum(p.price * od.quantity),2) as total_revenue
from pizzas as p
join
order_details as od 
on p.pizza_id = od.pizza_id;

#select first and last date of orders (with casting)

select min(cast(date as date)),max(cast(date as date)) from orders;

#identify highest price pizza and its price
select pt.name,p.price 
from
pizza_types as pt
join
pizzas as p
on pt.pizza_type_id = p.pizza_type_id
order by p.price desc limit 1;

#identify lowest price pizza and its price
select pt.name,p.price 
from
pizza_types as pt
join
pizzas as p
on pt.pizza_type_id = p.pizza_type_id
order by p.price asc limit 1;

#Find most common pizza size ordered --all the sizes and order_count sort it by order count

select size,
count(order_id) 
from pizzas as p
join
order_details as od
on p.pizza_id = od.pizza_id 
group by p.size 
order by count(order_id) desc;

#list the top 5 most ordered pizza types(Name) alongwith the quantities 

select pt.name, sum(od.quantity) as qty
from
pizza_types as pt
join
pizzas as p
on 
pt.pizza_type_id = p.pizza_type_id
join
order_details as od
on
od.pizza_id = p.pizza_id
group by name
order by qty desc 
limit 5;

#Determine the distribution of orders per use of the day 

select hour(time) as hour_day,count(order_id)
from orders
group by hour_day
order by hour_day;

#determine the top 5 pizzas based on Qty

select pt.name, sum(od.quantity) as qty
from
pizza_types as pt
join
pizzas as p
on 
pt.pizza_type_id = p.pizza_type_id
join
order_details as od
on
od.pizza_id = p.pizza_id
group by name
order by qty desc 
limit 5;

#determine the top 5 pizzas based on revenue 

select pt.name, sum(od.quantity) as qty, sum(od.quantity * p.price) as revenue
from
pizza_types as pt
join
pizzas as p
on 
pt.pizza_type_id = p.pizza_type_id
join
order_details as od
on
od.pizza_id = p.pizza_id
group by name
order by qty desc 
limit 5;

# % contribution of each pizza category to total revenue
select pt.category,
sum(od.quantity * p.price) / (select 
sum(od.quantity * p.price)
from
order_details as od
join
pizzas as p
on od.pizza_id =p.pizza_id) * 100 as percent
from 
order_details as od 
join
pizzas as p
on od.pizza_id =p.pizza_id
join
pizza_types as pt
on p.pizza_type_id = pt.pizza_type_id
group by  pt.category;

#give month on month revenue generated  #month order date 
with cte_rev as (
  select 
    extract(month from o.date) as month_rev, 
    sum(p.price * od.quantity) as revenue
  from order_details as od
  join orders as o on od.order_id = o.order_id
  join pizzas as p on p.pizza_id = od.pizza_id
  group by extract(month from o.date)
)
select 
  month_rev, 
  round(sum(revenue) over (order by month_rev), 2) as cumulative_rev
from cte_rev;

#give month on month revenue generated
select 
    extract(month from o.date) as month_rev, 
    sum(p.price * od.quantity) as revenue
  from order_details as od
  join orders as o on od.order_id = o.order_id
  join pizzas as p on p.pizza_id = od.pizza_id
  group by extract(month from o.date);
  
  -- Determine the top 3 most ordered pizzas(revenue wise) for each category
  
  with cte as (
  select pt.name, pt.category, sum(p.price* od.quantity) as total_revenue
  from pizza_types as pt
  join pizzas as p
  on pt.pizza_type_id = p.pizza_type_id
  join order_details as od
  on od.pizza_id = p.pizza_id
  group by pt.name, pt.category
  order by total_revenue desc),
cte1 as (
  select *,
  dense_rank() over (partition by category order by total_revenue desc) as rnk
  from cte)
select name, category, total_revenue from cte1
where rnk<4;

#write categorywise number of pizzas

select category , count(name) from pizza_types 
group by category;

#calculate average number of orders in a day

select round(avg(qty),2)
from
(
  select o.date, sum(od.quantity) as qty
  from
  orders as o
  join
  order_details as od
  on o.order_id = od.order_id
  group by o.date
) as oq













