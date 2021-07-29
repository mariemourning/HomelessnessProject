/* US Homelessness Exploration 2007-start of 2016*/
/*Skills used: Joins, Aggregate Functions, Creating Views, Converting Data Types, Editing Tables, Cases*/


-- Looking at the most common categories of homelessness from 2007-2016

SELECT measures, SUM(count) FROM homelessness
GROUP BY measures
ORDER BY SUM(count) DESC

--Seeing how homelessness has changed over time and then
--Determining when homelessness was at its highest from 2007-2016

SELECT year, SUM(count) AS total_homeless 
FROM homelessness
WHERE measures = 'Total Homeless'
GROUP BY year
ORDER BY year

SELECT year, SUM(count) AS total_homeless 
FROM homelessness
WHERE measures= 'Total Homeless'
GROUP BY year
ORDER BY SUM(count) DESC

-- Which Continuum of Care Program served the most individuals in each state in 2016?
SELECT state, coc_name, SUM(count) FROM homelessness
WHERE measures = 'Total Homeless'
GROUP BY state, coc_name
ORDER BY state, SUM(count) DESC

-- Finding the percentage of homelessness individuals for all of the U.S. in 2016
-- starting by checking if any states/territories are not shared in both tables so that I don't count them in sums

SELECT DISTINCT state, state_info.state_id, state_info.state_name FROM homelessness
FULL OUTER JOIN state_info
ON homelessness.state=state_info.state_id
WHERE homelessness.state IS NULL OR state_info.state_id IS NULL

-- finding/inserting sums from 2016 as new rows to make things simpler/more efficient
SELECT SUM(twentysixteen_pop) FROM state_info

INSERT INTO state_info 
	(state_id, state_name, twentysixteen_pop)
VALUES 
	('US', 'United_States', 326538820)
	
-- Excluding Guam and Virgin Islands from this sum since they aren't represented in state_info
SELECT SUM(count) FROM homelessness
WHERE state NOT IN ('GU','VI')
AND year = '2016-01-01'
AND measures = 'Total Homeless'

INSERT INTO homelessness
	(year, state, measures, count)
VALUES
	('2016-01-01', 'US', 'Total Homeless', 548502)
	
-- Finally finding percent homeless for the country in 2016	
SELECT count AS total_homeless, state_info.twentysixteen_pop AS total_pop, 
((count)*1.0/twentysixteen_pop)*100 AS percent_homeless FROM homelessness
JOIN state_info
ON homelessness.state=state_info.state_id
WHERE state= 'US'


-- Finding state with highest percentage of homelessness at the start of 2016
SELECT state, state_info.state_name, SUM(count) AS total_homeless, state_info.twentysixteen_pop,
((SUM(count))*1.0/state_info.twentysixteen_pop)*100 AS percent_homeless
FROM homelessness
JOIN state_info
ON homelessness.state=state_info.state_id
WHERE year = '2016-01-01' 
AND measures = 'Total Homeless'
AND state NOT IN ('GU','VI')
GROUP BY year, state, state_info.state_name, state_info.twentysixteen_pop
ORDER BY percent_homeless DESC


-- Creating View to Store Data for Later Visualizations
CREATE VIEW bystatehomeless2016 AS
SELECT state, state_info.state_name, SUM(count) AS total_homeless, state_info.twentysixteen_pop,
((SUM(count))*1.0/state_info.twentysixteen_pop)*100 AS percent_homeless
FROM homelessness
JOIN state_info
ON homelessness.state=state_info.state_id
WHERE year = '2016-01-01' 
AND measures = 'Total Homeless'
AND state NOT IN ('GU','VI')
GROUP BY year, state, state_info.state_name, state_info.twentysixteen_pop
ORDER BY percent_homeless DESC

--Aligning yearly populations with homelessness data to more easily view changes over time
SELECT year,state,
(CASE
WHEN year = '2010-01-01' THEN twentyten_pop
WHEN year = '2011-01-01' THEN twentyeleven_pop
WHEN year = '2012-01-01' THEN twentytwelve_pop
WHEN year = '2013-01-01' THEN twentythirteen_pop
WHEN year = '2014-01-01' THEN twentyfourteen_pop
WHEN year = '2015-01-01' THEN twentyfifteen_pop
WHEN year = '2016-01-01' THEN twentysixteen_pop
ELSE NULL
END) AS year_pop
FROM homelessness
JOIN state_info
ON homelessness.state=state_info.state_id
GROUP BY year, state, year_pop
ORDER BY year, state

-- Creating a view that shows total homeless per state compared to total population for each year 2010-2016
-- and saving as a view for later visualizations
CREATE VIEW homeless_to_pop AS
(SELECT state, year, SUM(count),
(CASE
WHEN year = '2010-01-01' THEN twentyten_pop
WHEN year = '2011-01-01' THEN twentyeleven_pop
WHEN year = '2012-01-01' THEN twentytwelve_pop
WHEN year = '2013-01-01' THEN twentythirteen_pop
WHEN year = '2014-01-01' THEN twentyfourteen_pop
WHEN year = '2015-01-01' THEN twentyfifteen_pop
WHEN year = '2016-01-01' THEN twentysixteen_pop
ELSE NULL
END) AS population
FROM homelessness
JOIN state_info
ON homelessness.state=state_info.state_id
WHERE YEAR >= '2010-01-01'
AND measures = 'Total Homeless'
GROUP BY state, year, twentyten_pop, 
twentyeleven_pop, twentytwelve_pop, twentythirteen_pop, 
twentyfourteen_pop, twentyfifteen_pop, twentysixteen_pop
ORDER BY state, year)






