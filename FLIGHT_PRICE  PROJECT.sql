-- PROJECT FLIGHT_PRICE
CREATE DATABASE FLIGHTS;
ALTER TABLE FLIGHT_PRICE
RENAME TO INFO;
USE FLIGHTS;
SELECT* FROM INFO;
-- Q1. What is the average flight price per airline?
SELECT AIRLINE, ROUND(AVG(PRICE),2) AS PRICES
FROM INFO
GROUP BY AIRLINE
ORDER BY ROUND(AVG(PRICE),2) DESC;

SELECT DISTINCT(AIRLINE),
(SELECT AVG(Price) from INFO as f2
where f2.airline = f1.airline) as avg_price
from INFO as f1
order by avg_price desc;

-- Q2 Which airline has the most number of flights?
SELECT AIRLINE,COUNT(*) AS NUMBER_OF_FLIGHTS
FROM INFO
GROUP BY AIRLINE
ORDER BY NUMBER_OF_FLIGHTS DESC ;

-- Q3. Which flights have prices higher than the average price for their route?
SELECT AIRLINE,Source,DESTINATION,PRICE
FROM INFO AS I
WHERE PRICE > (SELECT AVG(PRICE) 
FROM INFO AS I2
WHERE I.SOURCE=I2.SOURCE AND I.DESTINATION=I2.DESTINATION );

-- Q4 Which is the second most expensive flight per source-destination pair?
SELECT AIRLINE,Source,DESTINATION,PRICE
FROM INFO AS I
WHERE PRICE = (select DISTINCT PRICE 
FROM INFO AS I2
WHERE I.SOURCE = I2.SOURCE AND I.DESTINATION = I2.DESTINATION
ORDER BY PRICE LIMIT 1,1);

-- OR 
WITH 
SCND_EXPNSV_FLIGHT AS (
SELECT*,
row_number() OVER(partition by SOURCE,DESTINATION order by PRICE DESC) AS RANK_
FROM INFO 
)
SELECT AIRLINE,SOURCE,DESTINATION,PRICE
FROM SCND_EXPNSV_FLIGHT
WHERE RANK_ = 2;

-- Q5 What is the total number of flights for each source city?
select  SOURCE, COUNT(*) AS TOTAL_FLIGHTS
FROM INFO
group by SOURCE
order by TOTAL_FLIGHTS DESC;

-- Q6  What is the average duration and price per stop type (non-stop, 1 stop, etc.)?
WITH StopwiseStats AS (
    SELECT TOTAL_stops,
           AVG(ARRIVAL_TIME-DEP_TIME) AS avg_duration,
           AVG(price) AS avg_price
    FROM INFO
    GROUP BY TOTAL_stops
)
SELECT *
FROM StopwiseStats
ORDER BY avg_price DESC;

-- OR

SELECT TOTAL_stops, ROUND(AVG(ARRIVAL_TIME-DEP_TIME),3) AS avg_duration, AVG(price) AS avg_price
FROM INFO
GROUP BY TOTAL_stops;

-- Q7 Find the cheapest flight per source-destination pair?
SELECT AIRLINE,source, destination,  MIN(price) AS cheapest_price
FROM INFO
GROUP BY AIRLINE,source, destination
ORDER BY cheapest_price LIMIT 1;

-- Q8 Which airlines have average flight prices above the overall average price?
SELECT AIRLINE,avg(PRICE) AS AVG_PRICE 
FROM INFO
GROUP BY AIRLINE
having AVG(PRICE) > (SELECT avg(PRICE) FROM INFO);


-- Q9  Count number of flights by source-destination where total flights > 10
SELECT SOURCE,DESTINATION,COUNT(*) AS NO_OF_FLIGHTS
FROM INFO
GROUP BY SOURCE,DESTINATION
HAVING NO_OF_FLIGHTS > 10;

-- Q10 For each airline, find the most expensive flight it operates?
SELECT  AIRLINE, MAX(PRICE) AS EXPENSIVE_TICKET
FROM INFO
GROUP BY AIRLINE
ORDER BY EXPENSIVE_TICKET DESC ;

-- OR
WITH ranked_prices AS (
    SELECT *,
           row_number() OVER (PARTITION BY airline ORDER BY price DESC) AS rnk
    FROM INFO
)
SELECT airline, source, destination, price
FROM ranked_prices
WHERE rnk = 1;

