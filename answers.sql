-- Monday Coffee -- Data Analysis

SELECT * FROM city;
SELECT * FROM products;
SELECT * FROM customers;
SELECT * FROM sales;

-- Reports & Data Analysis
-- Q1. Coffee Consumers Count
-- How many people in each city are estimated to consume coffee given that 25% of the population does?
	select 
		city_name,
		round((population* 0.25)/1000000,2) as coffee_consumers_in_millions
	from city;
    
-- Total Revenue from Coffee Sales
-- Q2.What is the total revenue generated from coffee sales across all cities in the last quarter of 2023?
	select 
		ci.city_name,
		sum(s.total) as total_revenue
	from sales as s
    join customers as c
    on s.customer_id=c.customer_id
	join city as ci
    on ci.city_id=c.city_id
	where 
		year(s.sale_date) = 2023
		and
		quarter(s.sale_date) =4
    group by ci.city_name
    order by total_revenue desc;
    
-- Sales Count for Each Product
-- Q3.How many units of each coffee product have been sold?
	select 
		p.product_name,
		count(s.sale_id) as total_orders
    from products as p
    left join
    sales as s 
    on p.product_id=s.product_id
    group by p.product_name
    order by total_orders desc;

-- Average Sales Amount per City
-- Q4.What is the average sales amount per customer in each city?
	select 
		ci.city_name,
		sum(s.total) as total_revenue,
        count(distinct s.customer_id) as total_cx,
        round(
				sum(s.total)/
					count(distinct s.customer_id)
				,2) as avg_sale_per_cust
	from sales as s
    join customers as c
    on s.customer_id=c.customer_id
	join city as ci
    on ci.city_id=c.city_id
    group by ci.city_name
    order by total_revenue desc;


-- City Population and Coffee Consumers(25%)
-- Q5.Provide a list of cities along with their populations and estimated coffee consumers.
-- return city_name,total current cx, estimated coffee consumers(25%)
	with city_table as
    (
		select 
			city_name,
			round(population * 0.25/1000000,2) as coffee_consumers_in_millions
		from city
    ),
    customers_table as
    (
		select 
			city.city_name,
			count(distinct customers.customer_id) as unique_cx
		from sales 
		join customers 
		on customers.customer_id=sales.customer_id
		join city 
		on city.city_id=customers.city_id
		group by city.city_name
	)
	select customers_table.city_name,
		city_table.coffee_consumers_in_millions,
		customers_table.unique_cx
    from city_table 
    join customers_table 
    on city_table.city_name=customers_table.city_name;
    
-- Top Selling Products by City
-- Q6.What are the top 3 selling products in each city based on sales volume?
	select * 
    from
    (
    select 
		ci.city_name,
        p.product_name,
        count(s.sale_id) as total_orders,
        dense_rank() over(partition by ci.city_name order by count(s.sale_id) desc) as ranks
    from sales as s
    join 
    products as p
    on s.product_id=p.product_id
    join customers as c
    on c.customer_id=s.customer_id
    join city as ci
    on ci.city_id=c.city_id
	group by 1,2
    ) as t1
    where ranks<=3;
    
-- Customer Segmentation by City
-- Q7.How many unique customers are there in each city who have purchased coffee products?
	select 
		ci.city_name,
        count(distinct c.customer_id) as unique_cx
	from city as ci
    left join 
    customers as c
    on c.city_id= ci.city_id
    join sales as s
    on s.customer_id= c.customer_id
    where
		s.product_id in (1,2,3,4,5,6,7,8,9,10,11,12,13,14)
    group by ci.city_name;
	
-- Average Sale vs Rent
-- Q8.Find each city and their average sale per customer and avg rent per customer
	with city_table
    as
    (
		select 
			ci.city_name,
			count(distinct s.customer_id) as total_cx,
			round(
					sum(s.total)/
						count(distinct s.customer_id)
					,2) as avg_sale_per_cust
		from sales as s
		join customers as c
		on s.customer_id=c.customer_id
		join city as ci
		on ci.city_id=c.city_id
		group by ci.city_name
	),
    city_rent 
    as
    (select 
		city_name,
        estimated_rent
	from city
    )
    select 
		cr.city_name,
        cr.estimated_rent,
        ct.total_cx,
        ct.avg_sale_per_cust,
        round(cr.estimated_rent/ct.total_cx,2) as avg_rent_per_cust
    from city_rent as cr
    join city_table as ct
    on cr.city_name=ct.city_name
    order by 5 desc;
    
-- Monthly Sales Growth
-- Q9.Sales growth rate: Calculate the percentage growth (or decline) in sales over different time periods (monthly) by each city.
	with
    monthly_sales
    as
	(	select 
			ci.city_name,
			month(sale_date) as month,
			year(sale_date) as year,
			sum(s.total) as total_sale
		from sales as s
		join customers as c
		on c.customer_id=s.customer_id
		join city as ci
		on ci.city_id=c.city_id
		group by 1,2,3
		order by 1,3,2
	),
    growth_ratio 
    as
	(	select 	
			city_name,
			month,
			year,
			total_sale as cr_month_sale,
			lag(total_sale,1) over(partition by city_name order by year,month) as last_month_sale
		from monthly_sales
	)
    select 
		city_name,
		month,
		year,
        cr_month_sale,
        last_month_sale,
        round((cr_month_sale-last_month_sale)/last_month_sale *100,2) 
        as growth_ratio
	from growth_ratio;
    
    
-- Market Potential Analysis
-- Q10.Identify top 3 city based on highest sales, return city name, total sale, total rent, total customers, estimated coffee consumer
	with city_table
    as
    (
		select 
			ci.city_name,
            sum(s.total) as total_revenue,
			count(distinct s.customer_id) as total_cx,
			round(
					sum(s.total)/
						count(distinct s.customer_id)
					,2) as avg_sale_per_cust
		from sales as s
		join customers as c
		on s.customer_id=c.customer_id
		join city as ci
		on ci.city_id=c.city_id
		group by ci.city_name
	),
    city_rent 
    as
    (	
		select 
			city_name,
			estimated_rent,
			round((population * 0.25)/1000000,3) as estimated_coffee_consumer_in_millions
		from city
    )
    select 
		cr.city_name,
        total_revenue,
        cr.estimated_rent as total_rent,
        ct.total_cx,
        cr.estimated_coffee_consumer_in_millions,
        ct.avg_sale_per_cust,
        round(cr.estimated_rent/ct.total_cx,2) as avg_rent_per_cust
    from city_rent as cr
    join city_table as ct
    on cr.city_name=ct.city_name
    order by 2 desc;
/*
 Recomendation

City1: Pune
-- Average Rent Per Customer is very less which is 294.
-- Average sale per customer is also high which is 24197.. 
-- Total Revenue is also high which is 1258290.
-- There are 1.875 millions Coffee Consumers in Pune City.
City2: Delhi
-- Delhi has the highest Coffee Consumers among all cities.
-- The Average Rent Per Customer is less which is 330.
-- Delhi has total 68 Customers which is high.
City3: Jaipur
-- Jaipur has the highest total Number of Customers which is 69.
-- Avgerage Rent Per Customer is very less among all the cities, which is 156.
-- Total Revenue and Average Sale Per Customer is better in jaipur.
*/
-- END
