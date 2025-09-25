 -
   - Creating a table with name netflix
CREATE TABLE netflix(
       show_id VARCHAR(10),
       type CHAR(20),
       title VARCHAR(125), 
       director VARCHAR (225),
       casts VARCHAR(800),
       country VARCHAR (200),
       date_added VARCHAR(50),
       release_year INT,
       rating VARCHAR(10),
       duration VARCHAR(20),
       listed_in VARCHAR(30),
       description VARCHAR(300)
)

ALTER TABLE netflix
ALTER COLUMN listed_in TYPE VARCHAR(100);
	
SELECT * FROM netflix

SELECT COUNT(*) FROM netflix

SELECT DISTINCT(type) FROM netflix

-- 1. Count the number of Movies vs TV Shows
SELECT type,Count(*) FROM netflix
GROUP BY type ;

-- 2. Find the most common rating for movies and TV shows
CREATE TEMP TABLE rating_counts AS
WITH count_of_rating AS (
    SELECT 
        type, 
        rating, 
        COUNT(*) AS count_of_rating
    FROM netflix
    GROUP BY type, rating ),
ranked_rating AS (
    SELECT 
        type, 
        rating, 
        count_of_rating,
        RANK() OVER (PARTITION BY type ORDER BY count_of_rating DESC) AS ranking
    FROM count_of_rating)
SELECT 
    type, 
    rating, 
    count_of_rating AS frequent_rating
FROM ranked_rating
WHERE ranking = 1;

SELECT * FROM rating_counts


-- 3. List all movies released in a specific year (e.g., 2008)
SELECT * FROM netflix
WHERE release_year = 2018

SELECT COUNT(release_year) FROM netflix 
WHERE release_year = 2018

-- 4. Find the top 5 countries with the most content on Netflix
SELECT * FROM netflix

SELECT country, count(show_id) FROM netflix
GROUP BY country

SELECT STRING_TO_ARRAY(country, ',') AS new_country
FROM netflix

SELECT TRIM(UNNEST(STRING_TO_ARRAY(country, ','))) AS neww_country , COUNT(show_id)
FROM netflix
GROUP BY 1         --y aha par country nahi neww_country se hoga q ki country old column me se data fetch karega 
ORDER BY 2 DESC 
LIMIT 5 

-- 5. Identify the longest movie
SELECT 
	duration
FROM netflix
WHERE type = 'Movie' 
  AND duration IS NOT NULL
ORDER BY SPLIT_PART(duration, ' ', 1)::INT DESC
LIMIT 5;     
-- make the limit as 1 to get the longest


-- 6. Find content added in the last 5 years
SELECT * FROM netflix

SELECT CURRENT_DATE - INTERVAL '5 Years'
TO_DATE(date_added,'Month DD, YYYY')
SELECT  date_added ,TO_DATE(date_added,'Month DD, YYYY') FROM netflix

SELECT title, date_added, TO_DATE(date_added,'Month DD, YYYY') AS proper_date 
FROM netflix
WHERE
TO_DATE(date_added,'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years'

-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
SELECT * FROM 
(SELECT title, TRIM(UNNEST(STRING_TO_ARRAY(director, ','))) AS neww_director 
FROM netflix )
WHERE neww_director = 'Rajiv Chilaka'

-- 8. List all TV shows with more than 5 seasons
SELECT title, duration FROM netflix
WHERE type = 'TV Show'
AND SPLIT_PART(duration, ' ', 1)::INT >5 

-- 9. Count the number of content items in each genre
SELECT listed_in AS Genre FROM netflix

SELECT STRING_TO_ARRAY(listed_in, ',') FROM netflix

SELECT UNNEST(STRING_TO_ARRAY(listed_in, ',')) FROM netflix

SELECT TRIM(UNNEST(STRING_TO_ARRAY(listed_in, ','))) AS genre,
COUNT(show_id) AS total_content 
FROM netflix
GROUP BY 1
ORDER BY 2 DESC

-- 10. Find each year and the average numbers of content release by India on netflix. 
--     return top 5 year with highest avg content release !
SELECT TO_DATE (date_added, 'Month DD, YYYY') AS date FROM netflix

SELECT EXTRACT(YEAR FROM TO_DATE (date_added, 'Month DD, YYYY')) AS year FROM netflix

SELECT ROUND(COUNT(*)::numeric/(SELECT COUNT(*) FROM netflix WHERE country = 'India')::numeric * 100,2)AS avg_count_content
FROM netflix

total content = 972

SELECT 
EXTRACT(YEAR FROM TO_DATE (date_added, 'Month DD, YYYY')) AS year ,
COUNT(*) AS per_year,
ROUND(COUNT(*)::numeric/(SELECT COUNT(*) FROM netflix WHERE country = 'India')::numeric * 100,2)AS avg_count_content
FROM netflix
WHERE country = 'India'
GROUP BY 1
ORDER BY avg_count_content DESC

-- 11. List all movies that are documentaries
SELECT * FROM netflix
WHERE listed_in LIKE '%Documentaries%'

-- 12. Find all content without a director
SELECT * FROM netflix
WHERE director IS NULL

SELECT
    COUNT(CASE WHEN director IS NULL THEN 1 END) AS null_directors_count
FROM netflix;

-- 13. Find how many movies actor 'Salman Khan' appeared in last 15 years!
SELECT title FROM netflix
WHERE casts LIKE '%Salman Khan%' 
AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 15

SELECT COUNT(CASE WHEN 
        casts LIKE '%Salman Khan%' 
              AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 15 
THEN 1 END ) FROM netflix

-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
SELECT 
UNNEST(STRING_TO_ARRAY(casts, ',')) AS actors,
COUNT(*) AS total_contents
FROM netflix 
WHERE country ILIKE  '%india%'
Group BY actors
ORDER BY total_contents DESC
LIMIT 10

/*
Question 15:
Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.
*/	

SELECT 
    category,
	TYPE,
    COUNT(*) AS content_count
FROM (
    SELECT 
		*,
        CASE 
            WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS categorized_content
GROUP BY 1,2
ORDER BY 2





















