-- HOTEL RESERVATION OPERATIONS ANALYTICS
-- MySQL Business Analytics Project
-- Database: hotel_reservation_db

-- =========================================================
-- SPRINT 2: DATABASE SETUP
-- =========================================================

-- 2.1 Design the Database from the ER diagram

create database hotel_reservation_db;
use hotel_reservation_db;

-- 2.2 Data Import
CREATE TABLE guests(
    guest_id VARCHAR(50) PRIMARY KEY,
    guest_name VARCHAR(100) NOT NULL,
    city VARCHAR(50) NOT NULL,
    guest_type VARCHAR(20) NOT NULL,
    preferred_room_type VARCHAR(20),
    loyalty_tier VARCHAR(20),
    account_since DATE
);
ALTER TABLE guests
MODIFY account_since VARCHAR(20);
UPDATE guests
SET account_since = STR_TO_DATE(account_since, '%d-%m-%Y');
SELECT account_since
FROM guests;


select * from guests;
create table hotels(
hotel_id varchar(20) primary key,
hotel_name varchar(100) not null,
city varchar(50) not null,
star_rating int not null,
total_rooms int not null,
opened_date date
);

create table staff(
staff_id varchar(20) primary key,
staff_name varchar(100) not null,
hire_date date,
rating decimal(3,2),
department varchar(30),
is_active varchar(3)
);

create table rooms(
room_id varchar(20) primary key,
hotel_id varchar(20) not null,
room_type varchar(20) not null,
floor_number int,
max_occupancy int,
price_per_night decimal(10,2),
is_active varchar(5),

foreign key (hotel_id)
references hotels(hotel_id)
);

create table bookings(
booking_id varchar(20) primary key,
guest_id varchar(20) not null,
hotel_id varchar(20) not null,
booking_date date not null,
room_type_requested varchar(20),
booking_channel varchar(30),
nights_booked int,
total_amount decimal(12,2),

foreign key (guest_id)
references guests(guest_id),

foreign key (hotel_id)
references hotels(hotel_id)
);
ALTER TABLE bookings
MODIFY booking_date VARCHAR(20);
UPDATE bookings
SET booking_date = STR_TO_DATE(booking_date, '%d-%m-%Y');


CREATE TABLE stays (
    stay_id VARCHAR(20) PRIMARY KEY,
    booking_id VARCHAR(20),
    room_id VARCHAR(20),
    staff_id VARCHAR(20),
    check_in_date DATE,
    check_out_date DATE,
    status VARCHAR(20),
    nights_stayed INT,
    service_requests INT,
    stay_duration_hrs INT,

    FOREIGN KEY (booking_id)
    REFERENCES bookings(booking_id),

    FOREIGN KEY (room_id)
    REFERENCES rooms(room_id),

    FOREIGN KEY (staff_id)
    REFERENCES staff(staff_id)
);

-- =========================================================
-- DATA IMPORT
-- Update the file paths to your local CSV locations.
-- MySQL Workbench Table Data Import Wizard may also be used.
-- Dates in bookings/guests CSV are DD-MM-YYYY; load using
-- STR_TO_DATE if using LOAD DATA.

select * from hotels;
show tables;
select * from guests;
select * from rooms;
select * from staff;
select * from bookings;

-- ===========================================
-- Sprint 3: Basic Analysis / Data Exploration
-- ===========================================

-- 1. What is the total number of guests?
select count(*) from guests;
-- 3. What is the total number of stays?
select count(*) from stays;
-- 2. What is the total number of bookings?
select count(*) from bookings;
-- 4. What are the different room types available?
select distinct room_type
from rooms;
-- 5. How many staff members are currently active?
select count(*) staff_active
from staff;
-- 6. What are the different booking channels?
select distinct booking_channel
from bookings;
-- 7. What is the total booking amount across all bookings?
select sum(total_amount) as total_booking_amount
from bookings;
-- 8. What is the average nights booked per booking?
select avg(nights_booked) as avg_nights_booked
from bookings;

-- =====================================
-- Sprint 4: Objective-Based Analysis
-- =====================================

-- 1. Compare the number of bookings across hotels
select hotel_id,count(*) as total_bookings
from bookings
group by hotel_id
order by  total_bookings desc;

-- 2. Compare bookings across different booking channels
select booking_channel,
count(*) as total_bookings
from bookings
group by booking_channel
order by total_bookings desc;

-- 3. Compare bookings based on room type requested
select room_type_requested,
count(*) as total_bookings
from bookings
group by room_type_requested
order by total_bookings desc;

-- 4. Examine how booking volume changes over time
select year(booking_date) as booking_year,
month(booking_date) as booking_month,
count(*) as total_bookings
from bookings
group by 
year(booking_date),
month(booking_date)
order by 
booking_year, booking_month;

-- 5. Look at the booking amount across different groups
desc bookings;

select 
    booking_channel,
    sum(total_amount) as total_booking_amount,
    avg(total_amount) as avg_booking_amount
from bookings
group by booking_channel
order by total_booking_amount desc;

-- 4.2 Understand Guest Booking Behaviour
-- 1. Compare guests based on the number of bookings they make
select guest_id,count(booking_id) as total_bookings
from bookings
group by guest_id
order by total_bookings desc;

-- 2. Identify guests with a higher total booking amount
select 
    guest_id,
    sum(total_amount) as total_booking_amount
from bookings
group by guest_id
order by total_booking_amount desc;

-- 3. Compare guest activity across hotels
select 
    hotel_id,
    count(distinct guest_id) as total_guests,
    count(booking_id) as total_bookings
from bookings
group by hotel_id
order by total_bookings desc;

-- 4. Look at differences between Individual and Corporate guests
select 
    g.guest_type,
    count(b.booking_id) as total_bookings,
    sum(b.total_amount) as total_booking_amount
from guests g
join bookings b
    on g.guest_id = b.guest_id
group by g.guest_type;

-- 5. Examine guest booking patterns over time
select 
    year(STR_TO_DATE(booking_date, '%d-%m-%Y')) as booking_year,
    month(STR_TO_DATE(booking_date, '%d-%m-%Y')) as booking_month,
    count(booking_id) as total_bookings
from bookings
group by 
    year(STR_TO_DATE(booking_date, '%d-%m-%Y')),
    month(STR_TO_DATE(booking_date, '%d-%m-%Y'))
order by 
    booking_year,
    booking_month;
    
-- 4.3 Evaluate Stay Performance
-- 1. Compare stay outcomes across different hotels
select 
    b.hotel_id,
    s.status,
    count(s.stay_id) as total_stays
from bookings b
join stays s
    on b.booking_id = s.booking_id
group by b.hotel_id, s.status
order by b.hotel_id, total_stays DESC;

-- 2. Examine stay duration
select 
    avg(nights_stayed) as avg_nights_stayed,
    avg(stay_duration_hrs) as avg_stay_duration_hrs,
    min(nights_stayed) as minimum_nights,
    max(nights_stayed) as maximum_nights
from stays;

-- 3. Compare stay outcomes by status
select 
    status,
    count(stay_id) as total_stays
from stays
group by status
order by total_stays DESC;

-- 4. Identify hotels with higher booking activity or poorer outcomes
select 
    b.hotel_id,
    count(s.stay_id) as total_stays,
    sum(case 
        when s.status in ('No-show', 'Cancelled') then 1
        else 0
    end) as problem_stays
from bookings b
join stays s
    on b.booking_id = s.booking_id
group by b.hotel_id
order by total_stays DESC;

-- 5. Compare stay performance over time
select 
    year(check_in_date) as stay_year,
    month(check_in_date) as stay_month,
    count(stay_id) as total_stays,
    avg(nights_stayed) as avg_nights_stayed
from stays
group by 
    year(check_in_date),
    month(check_in_date)
order by
    stay_year,
    stay_month;
    
-- 4.4 Understand Staff and Room Performance
-- 1. Compare the number of stays handled by each staff member
select 
    staff_id,
    count(stay_id) as total_stays
from stays
group by staff_id
order by total_stays DESC;

-- 2. Compare staff performance across different stay outcomes
select 
    staff_id,
    status,
    count(stay_id) as total_stays
from stays
group by staff_id, status
order by staff_id, total_stays DESC;

-- 3. Compare stay duration across staff members
select 
    staff_id,
    avg(nights_stayed) as avg_nights_stayed,
    avg(stay_duration_hrs) as avg_stay_duration_hrs
from stays
group by staff_id
order by avg_stay_duration_hrs DESC;

-- 4. Examine room usage by room type
select 
    r.room_type,
    count(s.stay_id) as total_stays
from rooms r
join stays s
    on r.room_id = s.room_id
group by r.room_type
order by total_stays DESC;

-- 5. Compare stay performance across different rooms
select 
    s.room_id,
    s.status,
    count(s.stay_id) as total_stays
from stays s
group by s.room_id, s.status
order by s.room_id, total_stays DESC;

-- 4.5 Identify Booking and Stay Problems
-- 1. Identify cancellations and no-shows
select 
    status,
    count(stay_id) as total_stays
from stays
where status IN ('Cancelled', 'No-show')
group by status
order by total_stays DESC;

-- 2. Identify common booking and stay status patterns
select
    status,
    count(stay_id) as total_stays
from stays
group by status
order by total_stays DESC;

-- 3. Examine service request counts
select 
    sum(service_requests) as total_service_requests,
    avg(service_requests) as avg_service_requests_per_stay,
    max(service_requests) as maximum_service_requests
from stays;

-- 4. Identify hotels with more booking problems
select 
    b.hotel_id,
    count(s.stay_id) as total_stays,
    sum(case 
        when s.status in ('Cancelled', 'No-show') then 1
        else 0
    end) as problem_stays
from bookings b
join stays s
    on b.booking_id = s.booking_id
group by b.hotel_id
order by problem_stays DESC;

-- Final Outcome

-- By completing this project, we are able to understand how a real-world hotel reservation business problem can be converted into a data-driven solution. The project helps us understand the business requirements and identify how the available hotel reservation data can be used to answer important business questions.

-- We are able to understand the relational data model and the relationships between guests, hotels, rooms, bookings, stays, and staff. Based on these relationships, we can build and manage a relational database using MySQL and organize the data in a structured way.

-- The project also helps us formulate meaningful analytical questions related to booking demand, guest booking behaviour, stay performance, staff and room performance, and booking or stay problems. Using SQL queries, joins, aggregate functions, filtering, grouping, and sorting, we can analyze the data and obtain useful results.

-- By interpreting the results, we can identify important patterns, trends, booking behaviour, operational problems, and resource utilization. These findings help us understand how the hotel reservation system is performing and where improvements may be required.

-- Conclusion

-- Overall, this project demonstrates how SQL and relational databases can be used to analyze hotel reservation operations. The analysis provides a better understanding of booking activity, guest behaviour, stay outcomes, staff performance, room usage, and common booking problems. The project shows that analyzing data systematically can help the organization understand its operations and make better decisions.

-- Recommendations

-- Based on the analysis, the hotel management can focus on improving the areas where booking problems or poor stay outcomes are observed. The management can also monitor booking channels, room demand, guest behaviour, staff workload, and room utilization regularly.

-- Hotels with higher cancellation or no-show activity can be investigated further to understand the reasons behind these problems. Similarly, staff and room performance can be monitored to improve operational efficiency and guest experience.

-- Overall, regular analysis of reservation data can help StayPoint Hospitality improve its operations, understand its guests better, utilize resources effectively, and make informed data-driven decisions.