Create database if not exists zomato_db;
use zomato_db;
-- zomato Data Analysis using SQL
CREATE TABLE if not exists customers(
customer_id INT PRIMARY KEY,
customer_name varchar(30),
reg_date DATE 
);
create table if not exists restaurants(
restaurant_id int primary key ,
restaurant_name varchar(60),
city varchar(30),
opening_hours varchar(50)
);
create table if not exists orders(
order_id int primary key,
customer_id int,-- this is coming from customers table
restaurant_id int,-- this is coming from restaurants table 
order_item varchar(60),
order_date date,
order_time time,
order_status varchar(55),
total_amount float
);
-- adding foreign key oonstraints
alter table orders
add constraint fk_customers
foreign key(customer_id)
references customers(customer_id);

-- adding foreign key oonstraints
alter table orders
add constraint fk_restaurants
foreign key(restaurant_id)
references restaurants(restaurant_id);

create table if not exists riders(
rider_id int primary key,
rider_name varchar(60),
sign_up date
);
create table if not exists deliveries(
delivery_id int primary key ,
order_id int ,-- this is coming from orders table 
delivery_status varchar(40),
delivery_time time,
rider_id int -- this is coming from riders 
);
