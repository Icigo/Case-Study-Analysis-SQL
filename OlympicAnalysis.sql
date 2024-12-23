CREATE TABLE IF NOT EXISTS OLYMPICS_HISTORY
(
    id          INT,
    name        VARCHAR,
    sex         VARCHAR,
    age         VARCHAR,
    height      VARCHAR,
    weight      VARCHAR,
    team        VARCHAR,
    noc         VARCHAR,
    games       VARCHAR,
    year        INT,
    season      VARCHAR,
    city        VARCHAR,
    sport       VARCHAR,
    event       VARCHAR,
    medal       VARCHAR
);

CREATE TABLE IF NOT EXISTS OLYMPICS_HISTORY_NOC_REGIONS
(
    noc         VARCHAR,
    region      VARCHAR,
    notes       VARCHAR
);

select * from OLYMPICS_HISTORY;
select * from OLYMPICS_HISTORY_NOC_REGIONS;

-- 1. How many olympics games have been held?

SELECT COUNT(DISTINCT games) AS no_of_olympic_games 
FROM OLYMPICS_HISTORY;

-- 2. List down all Olympics games held so far.

SELECT DISTINCT year, season, city
FROM OLYMPICS_HISTORY
ORDER BY year, season;

-- 3. Mention the total no of nations who participated in each olympics game?

WITH cte AS (
SELECT oh.games, nr.region
FROM OLYMPICS_HISTORY oh
JOIN OLYMPICS_HISTORY_NOC_REGIONS nr ON oh.noc = nr.noc
GROUP BY games, region
)
SELECT games, COUNT(1) AS total_no_of_nations
FROM cte
GROUP BY games
ORDER BY games;

-- 4. Which year saw the highest and lowest no of countries participating in olympics?

WITH all_countries AS (
SELECT games, nr.region
FROM olympics_history oh
JOIN olympics_history_noc_regions nr ON nr.noc=oh.noc
GROUP BY games, nr.region
),
tot_countries AS ( 
SELECT games, COUNT(1) AS total_countries
FROM all_countries
GROUP BY games
)
SELECT DISTINCT CONCAT(FIRST_VALUE(games) OVER(ORDER BY total_countries), ' - ',
FIRST_VALUE(total_countries) OVER(ORDER BY total_countries)) AS Lowest_Countries,
CONCAT(FIRST_VALUE(games) OVER(ORDER BY total_countries DESC), ' - ',
FIRST_VALUE(total_countries) OVER(ORDER BY total_countries DESC)) AS Highest_Countries
FROM tot_countries
ORDER BY 1;

-- 5. Which nation has participated in all of the olympic games?

WITH cte1 AS (
SELECT COUNT(DISTINCT games) AS total_games 
FROM olympics_history
),
cte2 AS (
SELECT games, nr.region AS country
FROM olympics_history oh
JOIN olympics_history_noc_regions nr ON nr.noc=oh.noc
GROUP BY games, nr.region
),
cte3 AS (
SELECT country, COUNT(1) AS total_participated_games
FROM cte2
GROUP BY country
)
SELECT cte3.*
FROM cte3
JOIN cte1 ON cte3.total_participated_games = cte1.total_games
ORDER BY 1;

-- 6. Identify the sport which was played in all summer olympics.

WITH cte1 AS (
SELECT COUNT(DISTINCT games) AS total_summer_games 
FROM olympics_history
WHERE season = 'Summer'	
),
cte2 AS (
SELECT DISTINCT sport, games
FROM olympics_history
WHERE season = 'Summer'	
),
cte3 AS (
SELECT sport, COUNT(games) AS no_of_games
FROM cte2
GROUP BY sport
)
SELECT *
FROM cte3
JOIN cte1 ON cte3.no_of_games = cte1.total_summer_games;


-- 7. Which Sports were just played only once in the olympics?

WITH cte1 AS (
SELECT DISTINCT games, sport
FROM olympics_history oh
),
cte2 AS (
SELECT sport, COUNT(1) AS no_of_games
FROM cte1
GROUP BY sport	
)
SELECT cte2.*, cte1.games
FROM cte2
JOIN cte1 ON cte2.sport = cte1.sport AND cte2.no_of_games = 1
ORDER BY cte1.sport;

-- 8. Fetch the total no of sports played in each olympic games.

WITH cte1 AS (
SELECT DISTINCT games, sport
FROM olympics_history oh
),
cte2 AS (
SELECT games, COUNT(1) AS no_of_sports
FROM cte1
GROUP BY games	
)
SELECT *
FROM cte2
ORDER BY no_of_sports DESC;

-- 9. Fetch details of the oldest athletes to win a gold medal.

with temp as (
select name, sex, cast(case when age = 'NA' then '0' else age end as int) as age,
team,games,city,sport, event, medal
from olympics_history
),
ranking as (
select *, rank() over(order by age desc) as rnk
from temp
where medal='Gold'
)
select *
from ranking
where rnk = 1;

-- 10. Find the Ratio of male and female athletes participated in all olympic games.

WITH cte AS (
SELECT sex, COUNT(1) AS cnt
FROM olympics_history
GROUP BY sex
)
SELECT CONCAT('1 : ', ROUND(MAX(cnt)::DECIMAL / MIN(cnt), 2)) AS ratio
FROM cte;

	
-- 11. Fetch the top 5 athletes who have won the most gold medals.

SELECT name, cnt 
FROM (
	SELECT name, team, COUNT(*) AS cnt, DENSE_RANK() OVER(ORDER BY COUNT(*) DESC) AS drnk
	FROM olympics_history
	WHERE medal = 'Gold'
	GROUP BY name, team
)
WHERE drnk <= 5;

-- 12. Fetch the top 5 athletes who have won the most medals (gold/silver/bronze).

SELECT name, cnt 
FROM (
	SELECT name, team, COUNT(*) AS cnt, DENSE_RANK() OVER(ORDER BY COUNT(*) DESC) AS drnk
	FROM olympics_history
	WHERE medal IN ('Gold', 'Silver', 'Bronze')
	GROUP BY name, team
)
WHERE drnk <= 5
ORDER BY cnt DESC;

-- 13. Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won.

SELECT region, total_medals, drnk
FROM (
	SELECT nr.region, COUNT(*) as total_medals, DENSE_RANK() OVER(ORDER BY COUNT(*) DESC) AS drnk
	FROM OLYMPICS_HISTORY oh
	JOIN olympics_history_noc_regions nr ON nr.noc=oh.noc
	WHERE medal IN ('Gold', 'Silver', 'Bronze')
	GROUP BY nr.region
)
WHERE drnk <= 5;
	
-- 14. List down total gold, silver and broze medals won by each country.

SELECT nr.region AS country, 
COUNT(CASE WHEN medal = 'Gold' THEN oh.id END) AS Gold,
COUNT(CASE WHEN medal = 'Silver' THEN oh.id END) AS Silver,
COUNT(CASE WHEN medal = 'Bronze' THEN oh.id END) AS Bronze
FROM OLYMPICS_HISTORY oh
JOIN olympics_history_noc_regions nr ON nr.noc=oh.noc
WHERE medal IN ('Gold', 'Silver', 'Bronze')
GROUP BY nr.region
ORDER BY Gold DESC;

-- OR USING PIVOT

SELECT country, coalesce(gold, 0) as gold, coalesce(silver, 0) as silver, coalesce(bronze, 0) as bronze
FROM CROSSTAB (
'SELECT nr.region AS country, oh.medal, COUNT(1) AS total_medals 
FROM OLYMPICS_HISTORY oh
JOIN olympics_history_noc_regions nr ON nr.noc=oh.noc
WHERE medal <> ''NA''
GROUP BY nr.region, oh.medal',
'VALUES (''Gold''), (''Silver''), (''Bronze'')' 
) AS result(country VARCHAR, gold BIGINT, silver BIGINT, bronze BIGINT)
ORDER BY gold DESC, silver DESC, bronze DESC;


CREATE EXTENSION tablefunc;

-- 15. List down total gold, silver and broze medals won by each country corresponding to each olympic games.

SELECT oh.games, nr.region AS country, 
COUNT(CASE WHEN medal = 'Gold' THEN oh.id END) AS Gold,
COUNT(CASE WHEN medal = 'Silver' THEN oh.id END) AS Silver,
COUNT(CASE WHEN medal = 'Bronze' THEN oh.id END) AS Bronze
FROM OLYMPICS_HISTORY oh
JOIN olympics_history_noc_regions nr ON nr.noc=oh.noc
WHERE medal IN ('Gold', 'Silver', 'Bronze')
GROUP BY oh.games, nr.region
ORDER BY oh.games, nr.region;

-- 16. Identify which country won the most gold, most silver and most bronze medals in each olympic games.

WITH cte AS (
SELECT oh.games, nr.region AS country,  
COUNT(CASE WHEN medal = 'Gold' THEN oh.id END) AS Gold,
COUNT(CASE WHEN medal = 'Silver' THEN oh.id END) AS Silver,
COUNT(CASE WHEN medal = 'Bronze' THEN oh.id END) AS Bronze
FROM OLYMPICS_HISTORY oh
JOIN olympics_history_noc_regions nr ON nr.noc=oh.noc
WHERE medal IN ('Gold', 'Silver', 'Bronze')
GROUP BY oh.games, nr.region
ORDER BY oh.games
)
SELECT DISTINCT games,
CONCAT(FIRST_VALUE(country) OVER(PARTITION BY games ORDER BY gold DESC), ' - ', 
		FIRST_VALUE(gold) OVER(PARTITION BY games ORDER BY gold DESC)) AS max_gold,
CONCAT(FIRST_VALUE(country) OVER(PARTITION BY games ORDER BY silver DESC), ' - ', 
		FIRST_VALUE(silver) OVER(PARTITION BY games ORDER BY silver DESC)) AS max_silver,
CONCAT(FIRST_VALUE(country) OVER(PARTITION BY games ORDER BY bronze DESC), ' - ', 
		FIRST_VALUE(bronze) OVER(PARTITION BY games ORDER BY bronze DESC)) AS max_bronze
FROM cte
ORDER BY games;


-- 17. Identify which country won the most gold, most silver, most bronze medals and the most medals in each olympic games.


WITH cte1 AS (
SELECT oh.games, nr.region AS country,  
COUNT(CASE WHEN medal = 'Gold' THEN oh.id END) AS Gold,
COUNT(CASE WHEN medal = 'Silver' THEN oh.id END) AS Silver,
COUNT(CASE WHEN medal = 'Bronze' THEN oh.id END) AS Bronze
FROM OLYMPICS_HISTORY oh
JOIN olympics_history_noc_regions nr ON nr.noc=oh.noc
WHERE medal IN ('Gold', 'Silver', 'Bronze')
GROUP BY oh.games, nr.region
ORDER BY oh.games
),
cte2 AS (
SELECT oh.games, nr.region AS country, COUNT(1) AS total_medals 
FROM OLYMPICS_HISTORY oh
JOIN olympics_history_noc_regions nr ON nr.noc=oh.noc
WHERE medal IN ('Gold', 'Silver', 'Bronze')
GROUP BY oh.games, nr.region
ORDER BY 1, 2
)
SELECT DISTINCT cte1.games,
CONCAT(FIRST_VALUE(cte1.country) OVER(PARTITION BY cte1.games ORDER BY gold DESC), ' - ', 
		FIRST_VALUE(cte1.gold) OVER(PARTITION BY cte1.games ORDER BY gold DESC)) AS max_gold,
CONCAT(FIRST_VALUE(cte1.country) OVER(PARTITION BY cte1.games ORDER BY silver DESC), ' - ', 
		FIRST_VALUE(cte1.silver) OVER(PARTITION BY cte1.games ORDER BY silver DESC)) AS max_silver,
CONCAT(FIRST_VALUE(cte1.country) OVER(PARTITION BY cte1.games ORDER BY bronze DESC), ' - ', 
		FIRST_VALUE(cte1.bronze) OVER(PARTITION BY cte1.games ORDER BY bronze DESC)) AS max_bronze,
CONCAT(FIRST_VALUE(cte2.country) OVER(PARTITION BY cte2.games ORDER BY total_medals DESC NULLS LAST), ' - ', 
	   FIRST_VALUE(cte2.total_medals) OVER(PARTITION BY cte2.games ORDER BY total_medals DESC NULLS LAST)) AS Max_Medals
FROM cte1
JOIN cte2 ON cte2.games = cte1.games AND cte2.country = cte1.country
ORDER BY games;

-- 18. Which countries have never won gold medal but have won silver/bronze medals?

WITH cte AS (
SELECT nr.region AS country, 
COUNT(CASE WHEN medal = 'Gold' THEN oh.id END) AS Gold,
COUNT(CASE WHEN medal = 'Silver' THEN oh.id END) AS Silver,
COUNT(CASE WHEN medal = 'Bronze' THEN oh.id END) AS Bronze
FROM OLYMPICS_HISTORY oh
JOIN olympics_history_noc_regions nr ON nr.noc=oh.noc
WHERE medal IN ('Gold', 'Silver', 'Bronze')
GROUP BY nr.region
)
SELECT *
FROM cte 
WHERE Gold = 0 AND (Silver > 0 OR Bronze > 0)
ORDER BY silver DESC, bronze DESC;

-- 19. In which Sport/event, India has won highest medals.

SELECT oh.sport, COUNT(1) as highest_medals
FROM OLYMPICS_HISTORY oh
JOIN olympics_history_noc_regions nr ON nr.noc=oh.noc
WHERE nr.region = 'India' AND oh.medal <> 'NA'
GROUP BY oh.sport
ORDER BY 2 DESC
LIMIT 1;

-- 20. Break down all olympic games where india won medal for Hockey and how many medals in each olympic games.

SELECT oh.team, oh.sport, oh.games, COUNT(1) as total_medals
FROM OLYMPICS_HISTORY oh
JOIN olympics_history_noc_regions nr ON nr.noc=oh.noc
WHERE oh.team = 'India'  AND oh.sport = 'Hockey' AND oh.medal <> 'NA'
GROUP BY oh.team, oh.sport, oh.games
ORDER BY 4 DESC;

