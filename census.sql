CREATE DATABASE Census_2011
USE Census_2011

SP_HELP Data2

SP_HELP Data1

SELECT * FROM Data1

SELECT * FROM Data2

-- Number of rows into our dataset

SELECT COUNT(*) FROM Data1

SELECT COUNT(*) FROM Data2

-- Data set for Jharkhand and Bihar

SELECT * FROM Data1
WHERE State in ('Jharkhand','Bihar')

-- Calculate the total population of India

SELECT SUM(population) AS Population
FROM Data2


-- Average growth of India

SELECT State,AVG(Growth)*100 As Avg_Growth
FROM Data1
GROUP BY State

-- Average sex ratio

SELECT State,ROUND(AVG(sex_ratio),0) AS Sex_Ratio
FROM Data1
GROUP BY State
ORDER BY Sex_Ratio DESC

-- Average Literacy rate

SELECT State,ROUND(AVG(literacy),0) AS Avg_literacy_Rate
FROM Data1
GROUP BY State
HAVING ROUND(AVG(literacy),0)>90
ORDER BY Avg_literacy_Rate DESC

-- TOP 3 states heighest growth ratio

SELECT TOP 3 state,AVG(growth)*100 AS Avg_growth
FROM Data1
GROUP BY state
ORDER BY Avg_growth DESC 

-- Bottom 3 states lowest growth ratio ( creating a tamperory table)


SELECT TOP 3 State,ROUND(AVG(sex_ratio),0) AS Sex_Ratio
FROM Data1
GROUP BY State
ORDER BY Sex_Ratio ASC

-- Top and Bottom 3 states in literacy state

-- Top

DROP TABLE if exists #topstates
CREATE TABLE #topstates
( state nvarchar(255),
topstates float
)

insert into #topstates
SELECT State,ROUND(AVG(literacy),0) AS Avg_literacy_Rate
FROM Data1
GROUP BY State
ORDER BY Avg_literacy_Rate DESC

SELECT  TOP 3 * FROM #topstates
ORDER BY  #topstates.topstates DESC

-- Bottom

DROP TABLE if exists #bottomstates
CREATE TABLE #bottomstates
( state nvarchar(255),
#bottomstates float
)

insert into #bottomstates
SELECT State,ROUND(AVG(literacy),0) AS Avg_literacy_Rate
FROM Data1
GROUP BY State
ORDER BY Avg_literacy_Rate DESC

SELECT  TOP 3 * FROM #bottomstates
ORDER BY  #bottomstates.#bottomstates ASC


-- union operator (commbining two columns)

SELECT * FROM (
SELECT  TOP 3 * FROM #topstates
ORDER BY  #topstates.topstates DESC 
) a
UNION
SELECT * FROM (
SELECT  TOP 3 * FROM #bottomstates
ORDER BY  #bottomstates.#bottomstates ASC
) b

-- States starting with letter a

SELECT DISTINCT state
FROM Data1
WHERE lower(state) like 'a%' OR	 lower(state) like 'b%'

-- States starting with letter a and end with letter d

SELECT DISTINCT state
FROM Data1
WHERE lower(state) like 'a%' OR	 lower(state) like '%d'

-- joining boh table

SELECT a.District,a.state,a.sex_ratio,b.population
FROM Data1 
a INNER JOIN Data2 b ON a.District=b.District

-- total number of male and female population

SELECT c.District,c.state,ROUND(c.population/(c.sex_ratio+1),0) males, ROUND((c.population*c.sex_ratio)/(c.sex_ratio+1),0) female
FROM
(
SELECT a.District,a.state,a.sex_ratio,b.population
FROM Data1 
a INNER JOIN Data2 b ON a.District=b.District
) c

-- -- total number of male and female state population 

SELECT d.state,SUM(d.males) Total_Males,SUM(d.females) Total_Females
FROM 
(
SELECT c.District,c.state,ROUND(c.population/(c.sex_ratio+1),0) males, ROUND((c.population*c.sex_ratio)/(c.sex_ratio+1),0) females
FROM
(
SELECT a.District,a.state,a.sex_ratio/1000 sex_ratio,b.population
FROM Data1 
a INNER JOIN Data2 b ON a.District=b.District
) c)d
GROUP BY d.state

-- Total literaracy Rate

SELECT d.District,d.state,ROUND(d.literacy_ratio*d.population,0) literate_people,ROUND((1-literacy_ratio)*d.population,0) illiterate_people
FROM
(
SELECT a.District,a.state,a.literacy/100 literacy_ratio,b.population
FROM Data1 
a INNER JOIN Data2 b ON a.District=b.District
)d

-- Total literaracy Rate on state level basis

SELECT c.state,SUM(literate_people) Total_literate_pop,SUM(illiterate_people) Total_illiterate_pop
FROM
(
SELECT d.District,d.state,ROUND(d.literacy_ratio*d.population,0) literate_people,ROUND((1-literacy_ratio)*d.population,0) illiterate_people
FROM
(
SELECT a.District,a.state,a.literacy/100 literacy_ratio,b.population
FROM Data1 
a INNER JOIN Data2 b ON a.District=b.District
)d)c
GROUP BY c.state

-- Population in previous census

SELECT d.District,d.state,ROUND(d.population/(1+d.growth),0) previous_census_population,d.population current_census_population
FROM
(
SELECT a.District,a.state,a.growth growth,b.population
FROM Data1 a
INNER JOIN Data2 b ON a.District=b.District
)d

-- state by Population in previous census

SELECT e.state,SUM(e.previous_census_population) previous_census_population,SUM(e.current_census_population) current_census_population
FROM
(
SELECT d.District,d.state,ROUND(d.population/(1+d.growth),0) previous_census_population,d.population current_census_population
FROM
(
SELECT a.District,a.state,a.growth growth,b.population
FROM Data1 a
INNER JOIN Data2 b ON a.District=b.District
)d)e
GROUP BY e.state


-- Total population of India previous year and current year census

SELECT SUM(r.previous_census_population) previous_census_population ,SUM(r.current_census_population) current_census_population
FROM
(
SELECT e.state,SUM(e.previous_census_population) previous_census_population,SUM(e.current_census_population) current_census_population
FROM
(
SELECT d.District,d.state,ROUND(d.population/(1+d.growth),0) previous_census_population,d.population current_census_population
FROM
(
SELECT a.District,a.state,a.growth growth,b.population
FROM Data1 a
INNER JOIN Data2 b ON a.District=b.District
)d)e
GROUP BY e.state
)r

-- population vs area

SELECT q.*,r.*
FROM (
SELECT '1' as keyy,n.*
FROM 
(
SELECT SUM(m.previous_census_population) previous_census_population ,SUM(m.current_census_population) current_census_population
FROM
(
SELECT e.state,SUM(e.previous_census_population) previous_census_population,SUM(e.current_census_population) current_census_population
FROM
(
SELECT d.District,d.state,ROUND(d.population/(1+d.growth),0) previous_census_population,d.population current_census_population
FROM
(
SELECT a.District,a.state,a.growth growth,b.population
FROM Data1 a
INNER JOIN Data2 b ON a.District=b.District
)d)e
GROUP BY e.state)m) n)q INNER JOIN
(
SELECT '1' AS keyy,z.*
FROM (
SELECT SUM(area_km2) Total_area
FROM Data2
)z) r ON q.keyy=r.keyy


-- Area increased by a previous population

SELECT (g.total_area/g.previous_census_population) AS previous_census_population_vs_area,(g.total_area/g.current_census_population) AS current_census_population_vs_area
FROM
(
SELECT q.*,r.Total_area
FROM (
SELECT '1' as keyy,n.*
FROM 
(
SELECT SUM(m.previous_census_population) previous_census_population ,SUM(m.current_census_population) current_census_population
FROM
(
SELECT e.state,SUM(e.previous_census_population) previous_census_population,SUM(e.current_census_population) current_census_population
FROM
(
SELECT d.District,d.state,ROUND(d.population/(1+d.growth),0) previous_census_population,d.population current_census_population
FROM
(
SELECT a.District,a.state,a.growth growth,b.population
FROM Data1 a
INNER JOIN Data2 b ON a.District=b.District
)d)e
GROUP BY e.state)m) n)q INNER JOIN
(
SELECT '1' AS keyy,z.*
FROM (
SELECT SUM(area_km2) Total_area
FROM Data2
)z) r ON q.keyy=r.keyy)g

-- Give me the output of top 3 state which is having a heighest literacy rate

select a.* 
FROM
(
SELECT District,state,literacy,RANK() OVER(PARTITION BY STATE ORDER BY literacy DESC) RNK 
FROM Data1
)a
WHERE a.RNK IN (1,2,3)
ORDER BY state