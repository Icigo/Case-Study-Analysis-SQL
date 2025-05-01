create Table Employees (
EmpID int, 
Emp_name varchar(30), 
Manager_id int, 
Salary int, 
Location varchar(30)
)

INSERT INTO Employees (EmpID, Emp_name, Manager_id, Salary, Location)
VALUES
(1, 'John Smith', NULL, 120000, 'New York'),
(2, 'Alice Johnson', 1, 100000, 'Los Angeles'),
(3, 'Robert Brown', 1, 105000, 'Chicago'),
(4, 'Emma Davis', 2, 95000, 'Miami'),
(5, 'Michael Miller', 2, 90000, 'Boston'),
(6, 'Sophia Wilson', 3, 88000, 'Dallas'),
(7, 'Daniel Garcia', 3, 86000, 'Seattle'),
(8, 'Olivia Martinez', 4, 83000, 'Houston'),
(9, 'James Anderson', 5, 81000, 'Atlanta'),
(10, 'Isabella Lee', 5, 80000, 'San Francisco'),
(11, 'Henry Thomas', 6, 78000, 'Austin'),
(12, 'Emily Walker', 6, 76000, 'Philadelphia'),
(13, 'Alexander Scott', 7, 74000, 'Denver'),
(14, 'Grace Turner', 7, 72000, 'Phoenix'),
(15, 'Benjamin Hill', 8, 70000, 'San Diego'),
(16, 'Amelia Carter', 8, 69000, 'Dallas'),
(17, 'Ethan Lewis', 9, 68000, 'Chicago'),
(18, 'Charlotte Nelson', 9, 67000, 'Houston'),
(19, 'Mason Young', 10, 66000, 'Miami'),
(20, 'Abigail Perez', 10, 65000, 'Seattle'),
(21, 'Liam Clark', 1, 100000, 'New York'),
(22, 'Ava Hernandez', 1, 99000, 'Los Angeles'),
(23, 'Noah King', 2, 98000, 'San Francisco'),
(24, 'Mia Hall', 2, 97000, 'Boston'),
(25, 'Lucas Allen', 3, 96000, 'Dallas'),
(26, 'Harper Wright', 3, 94000, 'Philadelphia'),
(27, 'Elijah Baker', 4, 93000, 'Atlanta'),
(28, 'Evelyn Gonzalez', 4, 92000, 'Houston'),
(29, 'William Adams', 5, 91000, 'Denver'),
(30, 'Sophia Rodriguez', 5, 90000, 'Phoenix'),
(31, 'James Foster', 6, 88000, 'San Diego'),
(32, 'Amelia Howard', 6, 86000, 'Chicago'),
(33, 'Alexander Bell', 7, 85000, 'Miami'),
(34, 'Luna Russell', 7, 84000, 'Seattle'),
(35, 'Oliver Stewart', 8, 83000, 'Los Angeles'),
(36, 'Aria Morris', 8, 82000, 'Boston'),
(37, 'Jack Hughes', 9, 81000, 'New York'),
(38, 'Scarlett Simmons', 9, 80000, 'Dallas'),
(39, 'Henry Jenkins', 10, 79000, 'San Francisco'),
(40, 'Ella Coleman', 10, 78000, 'Philadelphia'),
(41, 'Jacob Cook', 1, 115000, 'Chicago'),
(42, 'Avery Powell', 1, 110000, 'Miami'),
(43, 'Lucas Ward', 2, 108000, 'Atlanta'),
(44, 'Isabella Butler', 2, 107000, 'Dallas'),
(45, 'Michael Barnes', 3, 106000, 'Phoenix'),
(46, 'Mia Mitchell', 3, 104000, 'Houston'),
(47, 'Daniel Brooks', 4, 103000, 'Denver'),
(48, 'Charlotte Sanders', 4, 102000, 'Seattle'),
(49, 'Ethan Murphy', 5, 101000, 'San Diego'),
(50, 'Emily Reed', 5, 100000, 'Boston');


select * from Employees;

-- 1. Write a SQL query to find employees whose salary is greater than the average salary of employees in their respective location.

WITH cte AS (
SELECT Location, AVG(Salary) AS avg_salary
FROM Employees
GROUP BY Location
)
SELECT e.EmpID, e.Emp_name, e.Location
FROM Employees e
INNER JOIN cte c ON e.Location = c.location
WHERE e.Salary > c.avg_salary
ORDER BY 1;

-------------------------------------------------------------------------------------------------------------------------------------------------


Create Table Trip (
trip_id int, 
driver_id int, 
rider_id int, 
trip_start_timestamp datetime
)

INSERT INTO Trip (trip_id, driver_id, rider_id, trip_start_timestamp)
VALUES
-- Rider 201 has taken trips on all 10 days
(1, 101, 201, '2023-09-01 08:30:00'),
(2, 102, 201, '2023-09-02 09:00:00'),
(3, 103, 201, '2023-09-03 09:15:00'),
(4, 104, 201, '2023-09-04 10:00:00'),
(5, 105, 201, '2023-09-05 10:30:00'),
(6, 106, 201, '2023-09-06 11:00:00'),
(7, 107, 201, '2023-09-07 11:30:00'),
(8, 108, 201, '2023-09-08 12:00:00'),
(9, 109, 201, '2023-09-09 12:30:00'),
(10, 110, 201, '2023-09-10 13:00:00'),
-- Rider 202 missed one day
(11, 101, 202, '2023-09-01 08:45:00'),
(12, 102, 202, '2023-09-02 09:10:00'),
(13, 103, 202, '2023-09-03 09:25:00'),
(14, 104, 202, '2023-09-04 10:05:00'),
-- Missed on 2023-09-05
(15, 106, 202, '2023-09-06 11:10:00'),
(16, 107, 202, '2023-09-07 11:40:00'),
(17, 108, 202, '2023-09-08 12:15:00'),
(18, 109, 202, '2023-09-09 12:45:00'),
(19, 110, 202, '2023-09-10 13:15:00'),
-- Rider 203 has taken trips on all 10 days
(20, 101, 203, '2023-09-01 08:50:00'),
(21, 102, 203, '2023-09-02 09:20:00'),
(22, 103, 203, '2023-09-03 09:30:00'),
(23, 104, 203, '2023-09-04 10:15:00'),
(24, 105, 203, '2023-09-05 10:45:00'),
(25, 106, 203, '2023-09-06 11:20:00'),
(26, 107, 203, '2023-09-07 11:50:00'),
(27, 108, 203, '2023-09-08 12:25:00'),
(28, 109, 203, '2023-09-09 12:50:00'),
(29, 110, 203, '2023-09-10 13:30:00'),
-- Rider 204 only took trips on 5 days
(30, 101, 204, '2023-09-01 08:55:00'),
(31, 102, 204, '2023-09-02 09:25:00'),
(32, 103, 204, '2023-09-04 10:30:00'),
(33, 104, 204, '2023-09-06 11:40:00'),
(34, 105, 204, '2023-09-08 12:35:00');


select * from Trip;

-- update for one user as duplicate date

update Trip
set trip_start_timestamp = '2023-09-09 13:30:00'
where trip_id = 29;


-- 2. Write a SQL query to identify riders who have taken at least one trip every day for the last 10 days/ 10 consecutive days

WITH cte AS (
SELECT *, DENSE_RANK() OVER(PARTITION BY rider_id ORDER BY trip_start_timestamp) AS drnk
FROM Trip
)
SELECT rider_id, MIN(trip_start_timestamp) AS start_date, MAX(trip_start_timestamp) AS end_date
FROM cte
GROUP BY rider_id, DATEDIFF(DAY, drnk, trip_start_timestamp)
HAVING DATEDIFF(DAY, MIN(trip_start_timestamp), MAX(trip_start_timestamp)) = 9; 

-- or

WITH cte AS (
SELECT *, DENSE_RANK() OVER(PARTITION BY rider_id ORDER BY trip_start_timestamp) AS drnk
FROM Trip
)
SELECT rider_id
FROM cte
WHERE DAY(trip_start_timestamp) - drnk = 0 AND drnk = 10;
 
 -- 203 although has done 10 trips but on 9 days not 10 days hence should not be the part of the result

 ---------------------------------------------------------------------------------------------------------------------------------------------------

CREATE TABLE Rides (
    ride_id INT PRIMARY KEY,
    driver_id INT,
    fare_amount DECIMAL(10, 2),
    driver_rating DECIMAL(2, 1),
    start_time DATETIME,
    payment_status VARCHAR(20)
);

INSERT INTO Rides (ride_id, driver_id, fare_amount, driver_rating, start_time, payment_status)
VALUES
(1, 101, 15.50, 4.5, '2023-10-01 10:00:00', 'Completed'),
(2, 102, 22.75, 4.0, '2023-10-01 12:00:00', 'Failed'),
(3, 101, 30.00, 4.8, '2023-10-01 14:00:00', 'Completed'),
(4, 103, 12.50, 4.1, '2023-10-01 15:00:00', 'Completed'),
(5, 101, 18.00, 3.9, '2023-10-01 16:00:00', 'Pending'),
(6, 102, 25.00, 4.2, '2023-10-02 10:00:00', 'Completed'),
(7, 103, 20.75, 4.6, '2023-10-02 11:00:00', 'Failed'),
(8, 104, 35.00, 4.7, '2023-10-02 12:00:00', 'Completed'),
(9, 101, 27.50, 4.5, '2023-10-02 13:00:00', 'Completed'),
(10, 104, 18.25, 4.3, '2023-10-02 14:00:00', 'Pending');


select * from Rides;

-- 3. Write a SQL query to calculate the percentage of successful payments for each driver. 
--    A payment is considered successful if its status is 'Completed'.

SELECT driver_id, CONCAT(100 * COUNT(CASE WHEN payment_status = 'Completed' THEN driver_id END) / COUNT(*), ' %') AS percent_success
FROM Rides
GROUP BY driver_id;

----------------------------------------------------------------------------------------------------------------------------------------------------

CREATE TABLE Items (
    item_id INT PRIMARY KEY,
    rest_id INT
);

CREATE TABLE Orders (
    order_id INT PRIMARY KEY,
    item_id INT,
    quantity INT,
    is_offer Varchar(10),
    client_id INT,
    Date_Timestamp DATETIME
);


INSERT INTO Items (item_id, rest_id)
VALUES
(1, 201),
(2, 201),
(3, 201),
(4, 202),
(5, 202),
(6, 203),
(7, 203),
(8, 203),
(9, 203),
(10, 204),
(11, 205),
(12, 205),
(14, 205),
(13, 204),
(20, 201);


INSERT INTO Orders (order_id, item_id, quantity, is_offer, client_id, Date_Timestamp)
VALUES
(1, 1, 2, 'FALSE', 1001, '2023-10-01 10:00:00'),
(2, 2, 1, 'TRUE', 1002, '2023-10-01 11:00:00'),
(3, 3, 1, 'FALSE', 1003, '2023-10-01 12:00:00'),
(4, 5, 3, 'FALSE', 1004, '2023-10-02 13:00:00'),
(5, 6, 1, 'TRUE', 1005, '2023-10-02 14:00:00'),
(6, 9, 2, 'FALSE', 1006, '2023-10-02 15:00:00'),
(7, 10, 4, 'FALSE', 1007, '2023-10-02 16:00:00');


-- 4. Write a SQL query to calculate the percentage of menu items sold for each restaurant.

SELECT i.rest_id, CONCAT(100 * COUNT(DISTINCT o.item_id) / COUNT(DISTINCT i.item_id), ' %') as percent_items_ordered
FROM Items i
LEFT JOIN Orders o ON i.item_id = o.item_id
GROUP BY i.rest_id;

-----------------------------------------------------------------------------------------------------------------------------------------------------

CREATE TABLE Orders1 (
    order_id INT PRIMARY KEY,
    user_id INT,
    is_offer int,
    Date_Timestamp DATETIME
);


INSERT INTO Orders1 (order_id, user_id, is_offer, Date_Timestamp)
VALUES
(1, 1001, 1, '2023-09-01 10:00:00'),   -- First order with offer
(2, 1001, 0, '2023-09-05 12:00:00'),  -- Next order without offer
(3, 1002, 0, '2023-09-02 11:00:00'),  -- First order without offer
(4, 1002, 1, '2023-09-10 14:00:00'),   -- Next order with offer
(5, 1003, 1, '2023-09-03 09:30:00'),   -- First order with offer
(6, 1003, 1, '2023-09-15 16:00:00'),   -- Next order with offer
(7, 1004, 0, '2023-09-04 08:00:00'),  -- First order without offer
(8, 1004, 0, '2023-09-20 10:30:00'),  -- Next order without offer
(9, 1001, 1, '2023-09-21 10:00:00'),  
(10, 1003, 0, '2023-09-25 12:00:00');


select * from Orders1;

-- 5. Write a SQL query to compare the time taken for clients who placed their first order with an offer versus those without an offer 
--    to make their next order.

WITH cte AS (
SELECT *, ROW_NUMBER() OVER(PARTITION BY user_id ORDER BY date_timestamp) AS rn
FROM Orders1
)
SELECT user_id, DATEDIFF(DAY, first_order_date, next_order_date)
FROM (
	SELECT user_id, MIN(CASE WHEN rn = 1 AND is_offer = 1 THEN Date_Timestamp END) AS first_order_date, 
	MAX(CASE WHEN is_offer = 0 THEN Date_Timestamp END) AS next_order_date
	FROM cte
	GROUP BY user_id
) G
WHERE first_order_date IS NOT NULL;

-- or

with cte as(
	select *,
	lead(Date_Timestamp) over (partition by user_id order by Date_Timestamp) as next_order_date
	from Orders1
)
-- we only need the details of first order from cte
select is_offer, avg(datediff(day, Date_Timestamp, next_order_date)) days_taken_for_next_order
from cte a
where a.Date_Timestamp = (
	select min(Date_Timestamp)
	from cte b
	group by user_id
	having a.user_id = b.user_id
) 
group by is_offer;



CREATE TABLE Logs (
    Id INT PRIMARY KEY,
    Num INT
);

INSERT INTO Logs (Id, Num)
VALUES
(1, 5),
(2, 5),
(3, 5),   -- 5 appears 3 times consecutively
(4, 3),
(5, 2),
(6, 7),
(7, 7),
(8, 7),   -- 7 appears 3 times consecutively
(9, 7),   -- 7 appears 4 times consecutively
(10, 1),
(11, 9),
(12, 9),
(13, 9),  -- 9 appears 3 times consecutively
(14, 6),
(15, 6),
(16, 8);

-- 6. Write a SQL query to find all numbers that appear at least three times consecutively in the log.

SELECT Num, COUNT(*) AS num_cnt
FROM Logs
GROUP BY Num
HAVING COUNT(*) >= 3

-- or	

select distinct Num
from(
	select *,
	lead(Num) over (order by Id) as frst_next,
	lead(Num, 2) over (order by Id) as scnd_next
	from Logs
)a
where Num = frst_next and Num = scnd_next


----------------------------------------------------------------------------------------------------------------------------------------------------

CREATE TABLE Consecutive (
    number INT PRIMARY KEY
);

INSERT INTO Consecutive (number)
VALUES
(1),
(2),
(3),    -- Sequence: 1, 2, 3
(5),
(6),    -- Sequence: 5, 6
(8),
(9),
(10),   -- Sequence: 8, 9, 10
(15),
(16),
(17),
(18);   -- Sequence: 15, 16, 17, 18


-- 7. Write a SQL query to find the length of the longest sequence of consecutive numbers in the table.

WITH cte1 AS (
SELECT *, ROW_NUMBER() OVER(ORDER BY number) AS rn
FROM Consecutive
),
cte2 AS (
SELECT number, 
CASE 
	WHEN number - rn = 0 THEN 'Sequence 1' 
	WHEN number - rn = 1 THEN 'Sequence 2'
	WHEN number - rn = 2 THEN 'Sequence 3'
	ELSE 'Sequence 4'
END AS num_sequence
FROM cte1
GROUP BY number, rn
)
SELECT num_sequence, STRING_AGG(number, ', ') AS num, COUNT(1) AS sequence_length
FROM cte2
GROUP BY num_sequence;

-- or

with cte as(
	select number,
	number-row_number() over(order by number) as seq
	from Consecutive
)
select max(len) as longest_seq_length
from(
	select seq, count(*) as len
	from cte
	group by seq
)a

----------------------------------------------------------------------------------------------------------------------------------------------------

CREATE TABLE Pass_Subscriptions (
    user_id INT PRIMARY KEY,
    pass_id INT,
    start_date DATE,
    end_date DATE,
    status VARCHAR(10)
);

CREATE TABLE Trips1 (
    trip_id INT PRIMARY KEY,
    user_id INT,
    is_promo int,
    trip_date DATE
);

INSERT INTO Pass_Subscriptions (user_id, pass_id, start_date, end_date, status)
VALUES
(1, 101, '2023-01-01', '2023-12-31', 'Active'),
(2, 102, '2023-06-01', '2023-11-30', 'Active'),
(3, NULL, NULL, NULL, 'Inactive'), -- Non-member
(4, NULL, NULL, NULL, 'Inactive'), -- Non-member
(5, 103, '2023-03-01', '2023-08-31', 'Expired');


INSERT INTO Trips1 (trip_id, user_id, is_promo, trip_date)
VALUES
(1, 1, 1, '2023-10-01'),  -- Promo trip by a member
(2, 2, 0, '2023-09-01'), -- Non-promo trip by a member
(3, 3, 1, '2023-10-02'),  -- Promo trip by a non-member
(4, 3, 0, '2023-09-15'), -- Non-promo trip by a non-member
(5, 4, 1, '2023-09-20'),  -- Promo trip by a non-member
(6, 1, 0, '2023-08-01'), -- Non-promo trip by a member
(7, 2, 1, '2023-10-05'),  -- Promo trip by a member
(8, 4, 0, '2023-08-10'); -- Non-promo trip by a non-member

select * from Pass_Subscriptions;
select * from Trips1;

-- 8. Write a SQL query to calculate the percentage of promo trips, comparing members versus non-members.

SELECT ps.status AS 'member vs non member', 100 * SUM(CASE WHEN t.is_promo = 1 THEN 1 ELSE 0 END) / COUNT(*) AS percent_promo_trips 
FROM Pass_Subscriptions ps
INNER JOIN Trips1 t ON ps.user_id = t.user_id
GROUP BY ps.status;
