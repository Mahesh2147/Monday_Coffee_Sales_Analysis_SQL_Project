-- Monady Coffee Schemas
create database monday_coffee_db;
use monday_coffee_db;

-- Import Rules
-- 1st import to city
-- 2nd import to products
-- 3rd import to customers
-- 4th import to sales

create table city
(
	city_id int primary key,
    city_name varchar(15),
	population bigint,
    estimated_rent float,
    city_rank int
);

create table customers
(
	customer_id int primary key,
    customer_name varchar(25),
    city_id int,
    constraint fk_city foreign key (city_id) references city(city_id)
);

create table products
(
	product_id int primary key,
    product_name varchar(35),
    price float
);

create table sales
(
	sale_id int primary key,
    sale_date date,
    product_id int,
    customer_id int,
    total float,
    rating int,
    constraint fk_products foreign key(product_id)  references products(product_id),
	constraint fk_customers foreign key(customer_id)  references customers(customer_id)
);

-- END