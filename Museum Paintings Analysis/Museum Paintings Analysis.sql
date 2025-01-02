SELECT * FROM artist;
SELECT * FROM canvas_size;
SELECT * FROM image_link;
SELECT * FROM museum;
SELECT * FROM museum_hours;
SELECT * FROM product_size;
SELECT * FROM subject;
SELECT * FROM work;

-- 1) Fetch all the paintings which are not displayed on any museums?

SELECT *
FROM work
WHERE museum_id IS NULL;

-- 2) Are there museuems without any paintings?

SELECT m.*
FROM work w
LEFT JOIN museum m ON w.museum_id = m.museum_id AND w.museum_id IS NULL;

-- 3) How many paintings have an asking price of more than their regular price? 

SELECT * 
FROM product_size
WHERE sale_price > regular_price;

-- 4) Identify the paintings whose asking price is less than 50% of its regular price

SELECT * 
FROM product_size
WHERE sale_price < (0.5 * regular_price);


-- 5) Which canva size costs the most?

SELECT label, sale_price 
FROM (
	SELECT c.size_id, c.label, p.sale_price, RANK() OVER(ORDER BY p.sale_price DESC) AS rnk
	FROM product_size p
	JOIN canvas_size c ON p.size_id = c.size_id
) a
WHERE rnk = 1;

-- 6) Delete duplicate records from work, product_size, subject and image_link tables

WITH cte AS (
SELECT *, ROW_NUMBER() OVER (PARTITION BY work_id ORDER BY work_id) AS rn
FROM work
) 
DELETE FROM cte
WHERE rn > 1;


WITH cte AS (
SELECT *, ROW_NUMBER() OVER (PARTITION BY work_id ORDER BY work_id) AS rn
FROM subject
) 
DELETE FROM cte
WHERE rn > 1;


WITH cte AS (
SELECT *, ROW_NUMBER() OVER (PARTITION BY work_id ORDER BY work_id) AS rn
FROM image_link
) 
DELETE FROM cte
WHERE rn > 1;


-- 7) Identify the museums with invalid city information in the given dataset

SELECT *
FROM museum
WHERE city LIKE '[0-9]%';

-- 8) Museum_Hours table has 1 invalid entry. Identify it and remove it.

DELETE FROM museum_hours
WHERE day = 'Thusday';

-- 9) Fetch the top 10 most famous painting subject

SELECT *
FROM (
	SELECT s.subject, COUNT(*) as subject_cnt, RANK() OVER(ORDER BY COUNT(*) DESC) AS rnk 
	FROM subject s
	JOIN work w ON s.work_id = w.work_id
	GROUP BY s.subject
) A
WHERE rnk <= 10;

-- 10) Identify the museums which are open on both Sunday and Monday. Display museum name, city.

WITH cte1 AS (
SELECT m.name, mh.day, m.city, m.state, m.country
FROM museum m
JOIN museum_hours mh ON m.museum_id = mh.museum_id
WHERE day = 'Sunday'
UNION
SELECT m.name, mh.day, m.city, m.state, m.country
FROM museum m
JOIN museum_hours mh ON m.museum_id = mh.museum_id
WHERE day = 'Monday'
), 
cte2 AS (
SELECT *, ROW_NUMBER() OVER(PARTITION BY name ORDER BY name) AS rn
FROM cte1 
)
SELECT name AS museum_name, city, state, country
FROM cte2
WHERE rn = 2;


-- 11) How many museums are open every single day?

SELECT COUNT(museum_id) AS no_of_museums_open_everyday 
FROM (
	SELECT museum_id, COUNT(day) AS day_cnt
	FROM museum_hours
	GROUP BY museum_id
	HAVING COUNT(day) = 7
) a;

-- 12) Which are the top 5 most popular museum? (Popularity is defined based on most no of paintings in a museum)

SELECT museum_name, city, country, most_no_of_paintings
FROM (
	SELECT m.museum_id, m.name AS museum_name, m.city, m.country, COUNT(*) AS most_no_of_paintings,
	ROW_NUMBER() OVER(ORDER BY COUNT(*) DESC) AS rn
	FROM museum m
	JOIN work w ON m.museum_id = w.museum_id
	GROUP BY m.museum_id, m.name, m.city, m.country
) F 
WHERE rn <= 5;
	
-- 13) Who are the top 5 most popular artist? (Popularity is defined based on most no of paintings done by an artist)

SELECT full_name, artist_nationality, most_no_of_paintings
FROM (
	SELECT a.full_name, a.nationality AS artist_nationality, COUNT(*) AS most_no_of_paintings, 
	ROW_NUMBER() OVER(ORDER BY COUNT(*) DESC) AS rn
	FROM artist a
	JOIN work w ON a.artist_id = w.artist_id
	GROUP BY a.full_name, a.nationality
) G
WHERE rn <= 5;

-- 14) Display the 3 least popular canva sizes

SELECT label, no_of_paintings
FROM (
	SELECT p.size_id, c.label, COUNT(*) AS no_of_paintings, DENSE_RANK() OVER(ORDER BY COUNT(*)) AS drnk
	FROM canvas_size c
	JOIN product_size p ON c.size_id = p.size_id
	GROUP BY p.size_id, c.label
) t
WHERE drnk <= 3;

-- 15) Which museum is open for the longest during a day. Dispay museum name, state and hours open and which day?

SELECT museum_name, state, open_in_hours, day 
FROM (
	SELECT m.name AS museum_name, m.state, mh.day, CONCAT(DATEDIFF(HOUR, mh.[open], mh.[close]), ' Hrs') AS open_in_hours, 
	DENSE_RANK() OVER(ORDER BY DATEDIFF(HOUR, mh.[open], mh.[close]) DESC) AS drnk
	FROM museum_hours mh
	JOIN museum m ON mh.museum_id = m.museum_id
) G
WHERE drnk = 1 AND state IS NOT NULL;

-- 16) Which museum has the most no of most popular painting style?

WITH popular_style AS (
SELECT style, COUNT(*) AS pop_style, RANK() OVER(ORDER BY COUNT(*) DESC) AS rnk
FROM work
GROUP BY style
),
cte AS (
SELECT m.museum_id, m.name AS museum_name, ps.style, COUNT(*) AS no_of_paintings, RANK() OVER(ORDER BY COUNT(*) DESC) AS rnk
FROM museum m
JOIN work w ON m.museum_id = w.museum_id
JOIN popular_style ps ON w.style = ps.style
WHERE w.museum_id IS NOT NULL AND ps.rnk = 1
GROUP BY m.museum_id, m.name, ps.style
)
SELECT museum_name, style, no_of_paintings
FROM cte
WHERE rnk = 1;

-- 17) Identify the artists whose paintings are displayed in multiple countries

WITH cte AS (
SELECT DISTINCT a.full_name AS artist_name, w.name AS painting_name, m.name AS museum_name, m.country
FROM work w
JOIN artist a ON w.artist_id = a.artist_id
JOIN museum m ON w.museum_id = m.museum_id
)
SELECT artist_name, COUNT(1) AS no_of_paintings, COUNT(DISTINCT country) AS no_of_countries
FROM cte
GROUP BY artist_name
HAVING COUNT(country) > 1
ORDER BY 3 DESC;

-- 18) Display the country and the city with most no of museums. Output 2 seperate columns to mention the city and country. 
--     If there are multiple value, seperate them with comma.

WITH cte1 AS (
SELECT country, COUNT(1) AS no_of_museums, RANK() OVER(ORDER BY COUNT(1) DESC) AS rnk
FROM museum
GROUP BY country
),
cte2 AS (
SELECT city, COUNT(1) AS no_of_museums, RANK() OVER(ORDER BY COUNT(1) DESC) AS rnk
FROM museum
GROUP BY city
)
SELECT DISTINCT cte1.country AS country_with_most_paintings, STRING_AGG(cte2.city, ', ') AS cities_with_most_paintings
FROM cte1
CROSS JOIN cte2
WHERE cte1.rnk = 1 AND cte2.rnk = 1
GROUP BY cte1.country;


-- 19) Identify the artist and the museum where the most expensive and least expensive painting is placed. 
--     Display the artist name, sale_price, painting name, museum name, museum city and canvas label

WITH cte AS (
SELECT *, DENSE_RANK() OVER(ORDER BY sale_price) AS price_asc, 
DENSE_RANK() OVER(ORDER BY sale_price DESC) AS price_desc 
FROM product_size
)
SELECT a.full_name, cte.sale_price, w.name AS painting_name, m.name AS museum_name, m.city, cs.label
FROM cte
JOIN work w ON w.work_id=cte.work_id
JOIN museum m ON m.museum_id=w.museum_id
JOIN artist a ON a.artist_id=w.artist_id
JOIN canvas_size cs ON cs.size_id = cte.size_id
WHERE price_asc = 1 OR price_desc = 1;


-- 20) Which country has the 5th highest no of paintings?

SELECT country, no_of_paintings 
FROM (
	SELECT m.country, COUNT(*) AS no_of_paintings, RANK() OVER(ORDER BY COUNT(*) DESC) AS rnk
	FROM work w
	JOIN museum m ON w.museum_id = m.museum_id
	GROUP BY m.country
) J
WHERE rnk = 5;

-- 21) Which are the 3 most popular and 3 least popular painting styles?

WITH cte AS (
SELECT style, COUNT(*) AS cnt, RANK() OVER(ORDER BY COUNT(*) DESC) AS top_rnk, RANK() OVER(ORDER BY COUNT(*)) AS bottom_rnk
FROM work
WHERE style IS NOT NULL
GROUP BY style
)
SELECT style, cnt, 
CASE 
	WHEN top_rnk <= 3 THEN 'Most Popular'
	WHEN bottom_rnk <= 3 THEN 'Least Popular'
END AS remark
FROM cte
WHERE top_rnk <= 3 OR bottom_rnk <= 3
ORDER BY cnt DESC;

-- 22) Which artist has the most no of Portraits paintings outside USA?. Display artist name, no of paintings and the artist nationality.

SELECT full_name, nationality, no_of_paintings
FROM (
	SELECT a.full_name, a.nationality, COUNT(*) AS no_of_paintings, DENSE_RANK() OVER(ORDER BY COUNT(*) DESC) AS drnk
	FROM work w
	JOIN artist a ON w.artist_id = a.artist_id
	JOIN museum m ON w.museum_id = m.museum_id
	JOIN subject s ON w.work_id = s.work_id
	WHERE s.subject = 'Portraits' AND m.country != 'USA'
	GROUP BY a.full_name, a.nationality
) J
WHERE drnk = 1;

