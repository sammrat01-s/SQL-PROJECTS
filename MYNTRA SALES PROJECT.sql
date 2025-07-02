USE MYNTRA;
SELECT*FROM PRODUCTS;
-- Q1. Top 10 Brands by Number of Products
SELECT BRAND_TAG,COUNT(PRODUCT_NAME) AS NO_OF_PRODUCTS
FROM PRODUCTS
GROUP BY BRAND_TAG
ORDER BY NO_OF_PRODUCTS DESC LIMIT 10;

-- Q2 Top 5 Brands with Highest Average Rating
SELECT BRAND_TAG,AVG(RATING) AS RATINGS
FROM PRODUCTS
GROUP BY BRAND_TAG
HAVING COUNT(*) > 10
ORDER BY RATINGS  DESC LIMIT 5;

-- Q3. Products with Maximum Discount
SELECT PRODUCT_NAME,MAX(DISCOUNT_PERCENT) AS DISCOUNT_PERCENTAGE
FROM PRODUCTS
GROUP BY PRODUCT_NAME
ORDER BY DISCOUNT_PERCENTAGE DESC limit 1;

-- or
select* 
from products
where discount_percent = (select max(discount_percent) as DISCOUNT_PERCENTAGE
from products
);

-- Q4. Average Marked Price vs Discounted Price per Product Category along with discount percentage?
SELECT PRODUCT_TAG ,ROUND(AVG(MARKED_PRICE),2) AS AVERAGE_MP ,ROUND(AVG(DISCOUNTED_PRICE),2) AS AVERAGE_DP , DISCOUNT_PERCENT
FROM PRODUCTS
GROUP BY PRODUCT_TAG,DISCOUNT_PERCENT;

-- Q5 Top Discounted Products Per Brand
WITH Discounted_Products AS
(SELECT BRAND_TAG ,MAX(DISCOUNT_PERCENT) AS DISCOUNT_PERCENT, PRODUCT_NAME
FROM PRODUCTS
GROUP BY BRAND_TAG , PRODUCT_NAME
ORDER BY DISCOUNT_PERCENT DESC )
SELECT* 
FROM Discounted_Products;

-- Q6 Top 3 Product Tags with Most High Discount Products (>50%)
select PRODUCT_TAG,COUNT(PRODUCT_NAME) AS NO_OF_PRODUCTS
FROM PRODUCTS
WHERE DISCOUNT_PERCENT > 50
GROUP BY PRODUCT_TAG
ORDER BY NO_OF_PRODUCTS DESC LIMIT 3;

-- Q7 Running Total of Discount Percent per Brand
SELECT BRAND_TAG,PRODUCT_TAG ,Discount_Percent ,
sum(DISCOUNT_PERCENT) OVER(partition by BRAND_TAG order by Discount_Percent DESC) AS running_discount
FROM PRODUCTS;

-- Q8 Top 3 Most Expensive Products per Category
WITH TOP_THREE AS 
( SELECT PRODUCT_TAG, PRODUCT_NAME , DISCOUNTED_PRICE,
row_number() OVER(PARTITION BY PRODUCT_TAG ORDER BY DISCOUNTED_PRICE DESC) AS RANK_
FROM PRODUCTS )
SELECT *
FROM TOP_THREE
WHERE RANK_ <=3 ;

-- OR
SELECT PRODUCT_TAG , PRODUCT_NAME , DISCOUNTED_PRICE
FROM PRODUCTS
ORDER BY DISCOUNTED_PRICE DESC LIMIT 3;

-- Q9. Identify Brands Whose Average Discount is Higher Than the Overall Average Discount
SELECT brand_name, AVG(discount_percent) AS avg_discount
FROM PRODUCTS
GROUP BY brand_name
HAVING AVG(discount_percent) > (
    SELECT AVG(discount_percent) FROM PRODUCTS
);

-- Q10 Identify the Top Product per Brand Whose Discount Is Among the Top 10% of All Discounts and Rating Is in the Top 10% for That Brand?
-- Step 1: Find 90th percentile discount globally
WITH DiscountPercentile AS (
  SELECT *,
         PERCENT_RANK() OVER (ORDER BY discount_percent) AS discount_rank
  FROM PRODUCTS
),
-- Step 2: Filter only top 10% discount products
TopDiscounted AS (
  SELECT * 
  FROM DiscountPercentile
  WHERE discount_rank >= 0.90
),
-- Step 3: Within each brand, rank products by rating
BrandTopRated AS (
  SELECT *,
         PERCENT_RANK() OVER (PARTITION BY brand_name ORDER BY rating DESC) AS brand_rating_rank
  FROM TopDiscounted
),
-- Step 4: Get best product per brand (in both top discount and top rating)
FinalSelection AS (
  SELECT *
  FROM BrandTopRated
  WHERE brand_rating_rank >= 0.90
)
-- Step 5: Pick the top-rated, highest-discount product per brand
SELECT *
FROM (
    SELECT *, 
           ROW_NUMBER() OVER (PARTITION BY brand_name ORDER BY rating DESC, discount_percent DESC) AS rn
    FROM FinalSelection
) sub
WHERE rn = 1;