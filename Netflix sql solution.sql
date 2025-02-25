select * Netflix_database;

Create Table Netflix
(
show_id VARCHAR(6),
type VARCHAR(10),
title VARCHAR(150),
director VARCHAR(208),
casts VARCHAR(1000),	
country	VARCHAR(150),
date_added VARCHAR(50),
release_year int,
rating VARCHAR(10),	
duration VARCHAR(15),	
listed_in VARCHAR(25),
description VARCHAR(250)
);

-- Q1 count the number of movies vs tv shows

select 
	type,
	count(*) as total_content
	from netflix
	group by type;

-- Q2 find the most common rating for movies & TV shows

SELECT
	type, 
	rating
from 
(
SELECT
	type,
		rating,
		count(*),
		RANK() over(partition by type order by count(*)desc) as ranking
	from netflix
	group by 1,2
) as t1
where 
	ranking = 1

-- Q3 List all movies released in a specific year (e.g, 2020)
select * from netflix
where
	type = 'Movie'
	and
	release_year = 2020	

-- Q4 Find out top 5 countries with the most content on netflix 

select 
	unnest(string_to_array(country,',')) as new_country,
	count(show_id) as total_count
from netflix
group  by country
order by 2 desc
limit 5

-- Q5 identify the longest movie?

select * from netflix
where 
	type = 'Movie' 
	and 
	duration = (select max(duration)from netflix)

-- Q6 Find content added in the last 5 years

select 
	*,
	to_date(date_added, 'Month DD, YYYY') >= current_date - interval '5 years'
from netflix

-- Q7 Find all the movies/TV shows by director 'Rajiv Chilaka'

select * from Netflix
where director ilike '%Rajiv Chilaka%'

-- Q8 List all TV shows with more than 5 seasons

select * from netflix
where	
	type = 'TV show' 
	and
	split_part(duration, ' ',1)::numeric > 5;


-- Q9 count the number of content items in each genre

select 
	unnest(string_to_array(listed_in, ',')) as genre,
	count(show_id) as total_content
from netflix
group by 1

-- Q10 Find each year and the average numbers of content release by india on netflix. return top 5 year with highest avg content release

select 
	extract(year from to_date(date_added, 'Month DD,YYYY')) as year,
	count(*)as yaerly_content,
	round(
	count(*)::numeric/(select count(*) from netflix where country = 'India')::numeric * 100
	, 2 )as avg_content_per_year
from netflix
where country = 'India'
group by 1

-- Q11 List all movies that are documntaries

select * from netflix
where 
	listed_in ilike '%documentaries%'
	
--Q12 find all content without a director 

select * from netflix
where 
	director is null;

-- Q13 Find how many movies actor 'Salman Khan' appeared in the last 10 years

select * from netflix
where 
	casts ilike '%Salman Khan%' and 
	release_year > extract(year from current_date) - 10

-- Q14 Find the top 10 actors who have appeared in the highest number of movies produced in india.

select 
unnest(string_to_array(casts, ','))as actors,
count(*) as total_content
from netflix
where country ilike '%india%'
group by 1
order by 2 desc
limit 10

-- Q15 categorize the content based on the presence of the keywords 'kill' and 'violence' in the description field. 
label content containing these keywords as 'Bad' and all other content as 'Good'. count how many items fall into each category.

with new_table
as
(
select
*,
	case 
	when description ilike '%kills%'
	or
	description ilike '%violence%' then 'Bad_content'
	else 'Good_content'
	end category
from netflix
)
select
	category,
	count(*) as total_count
from new_table
group by 1



