# About District Census 2011

According to the Census Statistics 2011, the population of India was 1,210,854,977 with 623,270,258 males and 587,584,719 females. Literacy was found to be a total of 74.04% with 65.46% literate females and 82.14% males. This was a 9.81% increase since the last census. The density of population was found out to be 382 per square kilometers. The total sex ratio was 940 females to 1000 males. The child sex ratio (of ages 0 to 6 years old) was 914 females to 1000 males. The growth rate was 17.64% and the death rate was 21.5%.

Census is the process by which the information of a given population is calculated on the basis of economical, educational and social records, in a given period of time. Census is calculated after regular time intervals. These are some basic census facts. In India, the census is carried out every 5 years. The last census was calculated in the year 2011. This official census 2011 was the 15th census calculation which was done India. It was carried out in two main phases- population listing and house enumeration.

# Census 2011 SQL Server Project
![](https://github.com/Ranjit933/Census-2011/blob/main/images.jpeg)

# Overview

This project aims to analyze and visualize data from the Census 2011 dataset using Microsoft SQL Server. The dataset provides a wealth of information about the population, housing, employment, and other demographics across various regions.

# Features

* Data Import: Scripts for importing Census 2011 data into SQL Server.

* Data Modeling: Well-structured tables representing different aspects of the census, including population, age distribution, and housing.

* Queries & Reports: A collection of SQL queries to extract meaningful insights from the data, such as population growth trends and demographic distributions.

# Queries Included

* Total Population Count: Aggregate population across all regions.

* Population by Age Group: Breakdown of population statistics by age demographics.

* Population Growth Rate: Calculation of growth rates over the years.

* Housing Statistics: Summary of housing units by region.

* Employment Status by Region: Employment distribution across various regions.

* Demographic Distribution: Gender and population analysis by region.

* Top 5 Most Populated Regions: Identification of regions with the highest populations.

* Performed advanced level query.

* Using Joins

* Using some mathematics formula.

* Using statistical analysis.


```sql
CREATE DATABASE Census_2011
```
```sql
USE Census_2011
```
```sql
SP_HELP Data2
```
```sql
SP_HELP Data1
```
```sql
SELECT * FROM Data1
```
```sql
SELECT * FROM Data2
```
## 1.Number of rows into our dataset
```sql
SELECT COUNT(*) FROM Data1
```
```sql
SELECT COUNT(*) FROM Data2
```
## 2.Data set for Jharkhand and Bihar
```sql
SELECT * FROM Data1
WHERE State in ('Jharkhand','Bihar')
```
## 3.Calculate the total population of India
```sql
SELECT SUM(population) AS Population
FROM Data2
```

## 4.Average growth of India
```sql
SELECT State,AVG(Growth)*100 As Avg_Growth
FROM Data1
GROUP BY State
```
## 5.Average sex ratio
```sql
SELECT State,ROUND(AVG(sex_ratio),0) AS Sex_Ratio
FROM Data1
GROUP BY State
ORDER BY Sex_Ratio DESC
```
## 6.Average Literacy rate
```sql
SELECT State,ROUND(AVG(literacy),0) AS Avg_literacy_Rate
FROM Data1
GROUP BY State
HAVING ROUND(AVG(literacy),0)>90
ORDER BY Avg_literacy_Rate DESC
```
## 7.TOP 3 states heighest growth ratio
```sql
SELECT TOP 3 state,AVG(growth)*100 AS Avg_growth
FROM Data1
GROUP BY state
ORDER BY Avg_growth DESC 
```
## 7.Bottom 3 states lowest growth ratio ( creating a tamperory table)

```sql
SELECT TOP 3 State,ROUND(AVG(sex_ratio),0) AS Sex_Ratio
FROM Data1
GROUP BY State
ORDER BY Sex_Ratio ASC
```
## 8.Top and Bottom 3 states in literacy state

### Top
```sql
DROP TABLE if exists #topstates
CREATE TABLE #topstates
( state nvarchar(255),
topstates float
)
```
```sql
insert into #topstates
SELECT State,ROUND(AVG(literacy),0) AS Avg_literacy_Rate
FROM Data1
GROUP BY State
ORDER BY Avg_literacy_Rate DESC
```
```sql
SELECT  TOP 3 * FROM #topstates
ORDER BY  #topstates.topstates DESC
```
### Bottom
```sql
DROP TABLE if exists #bottomstates
CREATE TABLE #bottomstates
( state nvarchar(255),
#bottomstates float
)
```
```sql
insert into #bottomstates
SELECT State,ROUND(AVG(literacy),0) AS Avg_literacy_Rate
FROM Data1
GROUP BY State
ORDER BY Avg_literacy_Rate DESC
```
```sql
SELECT  TOP 3 * FROM #bottomstates
ORDER BY  #bottomstates.#bottomstates ASC
```

## 9.union operator (commbining two columns)
```sql
SELECT * FROM (
SELECT  TOP 3 * FROM #topstates
ORDER BY  #topstates.topstates DESC 
) a
UNION
SELECT * FROM (
SELECT  TOP 3 * FROM #bottomstates
ORDER BY  #bottomstates.#bottomstates ASC
) b
```
## 10.States starting with letter a
```sql
SELECT DISTINCT state
FROM Data1
WHERE lower(state) like 'a%' OR	 lower(state) like 'b%'
```
## 11.States starting with letter a and end with letter d
```sql
SELECT DISTINCT state
FROM Data1
WHERE lower(state) like 'a%' OR	 lower(state) like '%d'
```
## 12.joining boh table
```sql
SELECT a.District,a.state,a.sex_ratio,b.population
FROM Data1 
a INNER JOIN Data2 b ON a.District=b.District
```
## 13.total number of male and female population
```sql
SELECT c.District,c.state,ROUND(c.population/(c.sex_ratio+1),0) males, ROUND((c.population*c.sex_ratio)/(c.sex_ratio+1),0) female
FROM
(
SELECT a.District,a.state,a.sex_ratio,b.population
FROM Data1 
a INNER JOIN Data2 b ON a.District=b.District
) c
```
## 14.total number of male and female state population 
```sql
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
```
## 15.Total literaracy Rate?
```sql
SELECT d.District,d.state,ROUND(d.literacy_ratio*d.population,0) literate_people,ROUND((1-literacy_ratio)*d.population,0) illiterate_people
FROM
(
SELECT a.District,a.state,a.literacy/100 literacy_ratio,b.population
FROM Data1 
a INNER JOIN Data2 b ON a.District=b.District
)d
```
## 16.Total literaracy Rate on state level basis?
```sql
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
```
## 17.Population in previous census?
```sql
SELECT d.District,d.state,ROUND(d.population/(1+d.growth),0) previous_census_population,d.population current_census_population
FROM
(
SELECT a.District,a.state,a.growth growth,b.population
FROM Data1 a
INNER JOIN Data2 b ON a.District=b.District
)d
```
## 18.state by Population in previous census?
```sql
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
```

## 19.Total population of India previous year and current year census?
```sql
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
```
## 20.population vs area?
```sql
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
```

## 21.Area increased by a previous population?
```sql
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
```
## 22.Give me the output of top 3 state which is having a heighest literacy rate?
```sql
select a.* 
FROM
(
SELECT District,state,literacy,RANK() OVER(PARTITION BY STATE ORDER BY literacy DESC) RNK 
FROM Data1
)a
WHERE a.RNK IN (1,2,3)
ORDER BY state
```
