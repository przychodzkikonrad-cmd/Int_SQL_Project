/* 2. Get the 25th and 75th percentile of the LTV. This will help us segement the customer's (similar to the notebook [3_Advanced_Segementation.ipynb](../1_Pivot_With_Case_Statements/3_Advanced_Segmentation.ipynb)).
    - High-Value: Customers in the top 25% (75th percentile and above)
    - Mid-Value: Customers in the middle 50% (25th to 75th percentile)
    - Low-Value: Customers in the bottom 25% (below the 25th percentile) */ 


WITH LTV_per_customer AS (
	SELECT 
	customerkey,
	cleaned_name,
	ROUND(SUM(total_net_revenue)) AS total_ltv
	FROM cohort_analysys  
	GROUP BY 
	customerkey, cleaned_name
), 
PERCENTILE AS (
	SELECT
	 PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY total_ltv) AS quartile_75th,
	 PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY total_ltv) AS quartile_25th
	 	
	 FROM LTV_per_customer 
 ), 
 segment_values AS 
 (
	 SELECT
	 	ltvpc.*,
	 	CASE 
			WHEN total_ltv > quartile_75th THEN '3. High value'
			WHEN total_ltv < quartile_25th THEN '1. Low value'
			ELSE '2. Mid value' END AS category_
	 FROM LTV_per_customer AS ltvPC, PERCENTILE
 )
 SELECT 
  category_,
  SUM(total_ltv) AS total_ltv,
  COUNT(customerkey) AS customercount,
   SUM(total_ltv) /  COUNT(customerkey) AVG_LTV
 FROM segment_values
 GROUP BY
 category_


 