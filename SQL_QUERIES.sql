use walmart_db;
select * from walmart;

#1.Find different payment method and no of transactions and no of quantity sold?
select payment_method, count(*) as no_of_transactions, sum(quantity) as total_quantity_sold
from walmart
group by payment_method;

#2.Identify the highest rated category in the branch, displaying the branch, category and avg rating.
select * from(
select branch,category as highest_rated_category , avg(rating) as avg_rating,
Rank() over(partition by branch order by avg(rating) desc) as Rank_
from walmart
group by branch,category
) as avg_rating
where rank_=1
;

#3.Identify the busiest day for each branch based on the number of transactions?
select * 
From(
select branch,
date_format(str_to_date(date,'%d/%m/%y'),'%W') as busiest_day,
count(*) as no_transactions,
rank() over (partition by branch order by count(*) desc) as rank_
from walmart
group by branch,busiest_day
) as busiest_day
where rank_=1
;

#4.calculate tho total quantity of items sold per payment method. List payment_method and total_quantity.
select payment_method , sum(quantity) as total_quantity
from walmart
group by payment_method;

#5.Determine the average, mimimum and maximum of category for each city.List the city, avg_rating,min_rating, max_rating
select category,city ,min(rating) as min_rating, max(rating) as max_rating, avg(rating) as avg_rating
from walmart
group by city,category;

#6.calculate the totalprofit for each category by considering total_profit as (unit_price*quantity*profit_margin).
#List category and total_profit, ordered from highest to lowest profit.
select category , (unit_price*quantity*profit_margin) as total_profit
from walmart
group by category
order by total_profit desc;

#7.Determine the most common payment method of each branch. Display Branch and the preferred_payment_method
with cte
 as(
select branch,payment_method,count(*) as total_trans,
rank() over (partition by branch order by count(*) desc) as rank_
from walmart
group by branch, payment_method
)
select * from cte
where rank_=1;

#8.categorize the sales into 3 groups morning, afternoon,evening
#find out ecch of the shift and no of invoices
select branch,
case
 when hour(time) < 12 then 'Morning'
 when hour(time) between 12  and 17 then 'Afternoon'
 else 'Evening'
end  as day_time,
count(*) as count
from walmart
group by branch,day_time
order by branch,count desc;

#9.Identify 5 branch with highest decrease ratio in revenue 
#compare to last year(current year 2023 and last year 2022).
#rdr==last_rev-cr_rev/ls_rev*100

with revenue_2022 as(
select branch,sum(total) as revenue
from walmart
where year(str_to_date(date,'%d/%m/%y'))=2022
group by branch),
revenue_2023 as (
select branch,sum(total) as revenue
from walmart
where year(str_to_date(date, '%d/%m/%Y')) = 2023
 group by branch )
 select 
    r2022.branch,
    r2022.revenue AS last_year_revenue,
    r2023.revenue AS current_year_revenue,
    round(((r2022.revenue - r2023.revenue) / r2022.revenue) * 100, 2) AS revenue_decrease_ratio
from revenue_2022 as r2022
join revenue_2023 as r2023 on r2022.branch = r2023.branch
where r2022.revenue > r2023.revenue
order by revenue_decrease_ratio desc
limit 5;