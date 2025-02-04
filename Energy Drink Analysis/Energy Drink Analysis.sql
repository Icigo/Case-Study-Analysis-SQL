CREATE TABLE fact_survey_responses (
	Response_ID INT,
	Respondent_ID INT,
	Consume_frequency TEXT,
	Consume_time TEXT,
	Consume_reason TEXT,
	Heard_before TEXT,
	Brand_perception TEXT, 
	General_perception TEXT,
	Tried_before TEXT,
	Taste_experience INT,
	Reasons_preventing_trying TEXT,
	Current_brands TEXT,
	Reasons_for_choosing_brands TEXT,
	Improvements_desired TEXT,
	Ingredients_expected TEXT,
	Health_concerns TEXT,
	Interest_in_natural_or_organic TEXT,
	Marketing_channels TEXT,
	Packaging_preference TEXT,
	Limited_edition_packaging TEXT,
	Price_range TEXT,
	Purchase_location TEXT,
	Typical_consumption_situations TEXT
);

CREATE TABLE dim_repondents (
	Respondent_ID INT,
	Name TEXT,
	Age TEXT,
	Gender TEXT,
	City_ID TEXT
);

CREATE TABLE dim_cities (
	City_ID TEXT,
	City TEXT,
	Tier TEXT
);

SELECT * FROM fact_survey_responses
SELECT * FROM dim_repondents
SELECT * FROM dim_cities

-- 1. Demographic Insights (examples)
--    a. Who prefers energy drink more? (male/female/non-binary?)

SELECT r.gender, COUNT(*) AS preference_in_numbers
FROM fact_survey_responses sr
JOIN dim_repondents r ON sr.respondent_id = r.respondent_id
GROUP BY r.gender
ORDER BY 2 DESC

--    b. Which age group prefers energy drinks more?

SELECT r.age AS age_group, COUNT(1) AS preference_cnt
FROM fact_survey_responses sr
JOIN dim_repondents r ON sr.respondent_id = r.respondent_id
GROUP BY r.age
ORDER BY 2 DESC 

--    c. Which type of marketing reaches the most Youth (15-30)?

SELECT sr.marketing_channels, COUNT(1) AS most_reaching_marketing_channel
FROM fact_survey_responses sr
JOIN dim_repondents r ON sr.respondent_id = r.respondent_id
WHERE r.age BETWEEN '15-18' AND '19-30'
GROUP BY sr.marketing_channels
ORDER BY 2 DESC

-- 2. Consumer Preferences:
--    a. What are the preferred ingredients of energy drinks among respondents?

SELECT ingredients_expected, COUNT(1) AS preferred_cnt
FROM fact_survey_responses
GROUP BY ingredients_expected
ORDER BY 2 DESC

--    b. What packaging preferences do respondents have for energy drinks?

SELECT packaging_preference, COUNT(1) AS preferred_cnt
FROM fact_survey_responses
GROUP BY packaging_preference
ORDER BY 2 DESC

-- 3. Competition Analysis:
--    a. Who are the current market leaders?

SELECT current_brands AS current_market_leaders, COUNT(1) AS preferred_cnt
FROM fact_survey_responses
GROUP BY current_brands
ORDER BY 2 DESC

--    b. What are the primary reasons consumers prefer those brands over ours?

SELECT current_brands AS current_market_leaders, reasons_for_choosing_brands,
COUNT(reasons_for_choosing_brands) AS consumers_count
FROM fact_survey_responses
GROUP BY current_brands, reasons_for_choosing_brands
ORDER BY 1, 2, 3 DESC

-- 4. Marketing Channels and Brand Awareness:
--    a. Which marketing channel can be used to reach more customers?

SELECT marketing_channels, COUNT(1) AS most_reaching_marketing_channel
FROM fact_survey_responses 
WHERE current_brands = 'CodeX' 
GROUP BY marketing_channels
ORDER BY 2 DESC

--    b. How effective are different marketing strategies and channels in reaching our customers?

SELECT marketing_channels, limited_edition_packaging, COUNT(limited_edition_packaging) AS limited_pack_cnt
FROM fact_survey_responses
WHERE current_brands = 'CodeX' 
GROUP BY marketing_channels, limited_edition_packaging
ORDER BY marketing_channels, limited_pack_cnt DESC

-- 5. Brand Penetration:
--    a. What do people think about our brand? (overall rating)

SELECT sr.current_brands, sr.taste_experience AS rating, COUNT(*) AS total_people
FROM fact_survey_responses sr
INNER JOIN dim_repondents r ON sr.respondent_id = r.respondent_id
WHERE current_brands = 'CodeX'
GROUP BY sr.current_brands, sr.taste_experience
ORDER BY rating

--    b. Which cities do we need to focus more on?

SELECT c.tier, c.city, COUNT(*) AS people_cnt
FROM fact_survey_responses sr
JOIN dim_repondents r ON sr.respondent_id = r.respondent_id
JOIN dim_cities c ON r.city_id = c.city_id
WHERE sr.current_brands = 'CodeX'
GROUP BY c.tier, c.city
ORDER BY 3 DESC

-- 6. Purchase Behavior:
--    a. Where do respondents prefer to purchase energy drinks?

SELECT sr.purchase_location, COUNT(1) AS respondents_cnt
FROM fact_survey_responses sr
JOIN dim_repondents r ON sr.respondent_id = r.respondent_id
GROUP BY sr.purchase_location
ORDER BY 2 DESC

--    b. What are the typical consumption situations for energy drinks among respondents?

SELECT sr.typical_consumption_situations, COUNT(1) AS respondents_cnt
FROM fact_survey_responses sr
JOIN dim_repondents r ON sr.respondent_id = r.respondent_id
GROUP BY sr.typical_consumption_situations
ORDER BY 2 DESC

--    c. What factors influence respondents' purchase decisions, such as price range and limited edition 
--       packaging?

SELECT sr.price_range, sr.limited_edition_packaging, COUNT(*) AS respondents_cnt
FROM fact_survey_responses sr
JOIN dim_repondents r ON sr.respondent_id = r.respondent_id
GROUP BY sr.price_range, sr.limited_edition_packaging
ORDER BY 1, 2

-- 7. Product Development
--    a. Which area of business should we focus more on our product development? (Branding/taste/availability)

SELECT sr.reasons_for_choosing_brands, 
COUNT(CASE WHEN sr.current_brands = 'CodeX' THEN sr.respondent_id END) AS CodeX_respondents_cnt,
COUNT(CASE WHEN sr.current_brands = 'Cola-Coka' THEN sr.respondent_id END) AS ColaCoka_respondents_cnt
FROM fact_survey_responses sr
JOIN dim_repondents r ON sr.respondent_id = r.respondent_id
GROUP BY sr.reasons_for_choosing_brands
ORDER BY 2 DESC
