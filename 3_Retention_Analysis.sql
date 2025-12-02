WITH CUSTOMER_LAST_PURCHASE AS (
	SELECT 
		customerkey,
		COHORT_YEAR,
		cleaned_name,
		first_purchase_date,
		orderdate,
		ROW_NUMBER() OVER(PARTITION BY CUSTOMERKEY ORDER BY ORDERDATE DESC) AS rn
	FROM cohort_analysys
), Churned_customers AS(
	SELECT
		CUSTOMERKEY,
		COHORT_YEAR,
		cleaned_name,
		orderdate AS LAST_purchase_date,
		CASE
		WHEN orderdate < (SELECT MAX(orderdate) FROM sales) - INTERVAL '6 months' THEN 'Churned'
			ELSE 'Active' END AS customer_category
		
		
	FROM CUSTOMER_LAST_PURCHASE 
	WHERE RN = '1' AND
		first_purchase_date  < (SELECT MAX(orderdate) FROM sales) - INTERVAL '6 months'
)
SELECT 
	customer_category,
	COUNT(CUstomerkey) AS customers_num,
	SUM(COUNT(CUstomerkey)) OVER(PARTITION BY cohort_year) AS total_number_of_customers,
	ROUND(COUNT(CUstomerkey) / SUM(COUNT(CUstomerkey)) OVER(PARTITION BY cohort_year),2)  AS perctl
FROM 
Churned_customers 
GROUP BY
COHORT_YEAR, Customer_category
