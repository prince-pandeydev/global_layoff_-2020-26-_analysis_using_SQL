SELECT * FROM global_layoff
LIMIT 10;

SELECT DISTINCT industry
			FROM global_layoff;


SELECT DISTINCT country
			FROM global_layoff;


SELECT DISTINCT continent
			FROM global_layoff;

SELECT company_size,
		COUNT(*)
		FROM global_layoff
		GROUP BY 1;

SELECT continent,
		COUNT(*)
		FROM global_layoff
		GROUP BY 1;


--                     ADVANCED LEVEL QUERIES 
--                      20 BUSINESS QUESTION;

---Financial Impact & Market Reaction
--------------------------------------
--------------------------------------
-- Q1 Which companies had negative revenue growth but still continued hiring?

SELECT  company,
		industry,
		hiring_status,
		revenue_growth_percent
		FROM global_layoff
		
	WHERE revenue_growth_percent < 0 
	AND hiring_status = 'Hiring'
	ORDER BY 4 DESC
	
--Q2 Is there a correlation between stock_price_change_7d and layoff_count?


SELECT 
		EXTRACT (YEAR FROM layoff_date) AS layoff_year,
		industry,
		COUNT(layoff_count) AS total_termination 
		FROM global_layoff
		WHERE stock_price_change_7d < 0
		GROUP BY 1,2
		ORDER BY 1 

SELECT 
    CORR(layoff_count, stock_price_change_7d) AS correlation_value
FROM global_layoff;


--Q3 Do companies with higher market_cap_billion_usd lay off a smaller percentage of workforce?


SELECT 
    CORR(market_cap_billion_usd, workforce_percentage) AS correlation_value
FROM global_layoff;

--Q4 Which funding stage shows the highest average layoff_severity_score?

SELECT  
		funding_stage,
		COUNT (*) AS total_companies,
		ROUND(
			AVG(layoff_severity_score)
				,2) AS avg_severity_score
		FROM global_layoff
		GROUP BY 1
		ORDER BY 3 DESC;
		
--Q5 Did companies with IPO funding stage face more layoffs during Tech Correction compared to Pandemic Impact?


SELECT 
    economic_cycle_flag,
    ROUND(AVG(layoff_count), 2) AS avg_layoff_count,
    ROUND(AVG(workforce_percentage), 2) AS avg_workforce_percent,
    ROUND(AVG(layoff_severity_score), 2) AS avg_severity_score,
    COUNT(*) AS total_companies
FROM global_layoff
WHERE funding_stage = 'IPO'
GROUP BY economic_cycle_flag
ORDER BY avg_severity_score DESC;

--Q6 Which continent has the highest average workforce_percentage laid off?


SELECT DISTINCT continent,
		 ROUND(AVG(workforce_percentage), 2) AS avg_workforce_percent,
		 COUNT (*) AS total_companies
			FROM global_layoff
			GROUP BY 1
			ORDER BY 2 DESC;


--Q7 During Pandemic Impact, which country experienced the largest layoffs?

SELECT country,
		 ROUND(AVG(layoff_count), 2) AS avg_layoff_count
		 FROM global_layoff
		 WHERE economic_cycle_flag= 'Pandemic Impact'
			GROUP BY 1
			ORDER BY 2 DESC;

--Q 8 Are layoffs more severe in developed markets (USA, Germany) compared to Asia?

SELECT 
    CASE 
        WHEN country IN ('USA', 'Germany') THEN 'Developed Markets'
        WHEN continent = 'Asia' THEN 'Asia'
        ELSE 'Other'
    END AS region_group,
    
    ROUND(AVG(layoff_severity_score), 2) AS avg_severity,
    ROUND(AVG(workforce_percentage), 2) AS avg_workforce_percent,
    SUM(layoff_count) AS total_layoffs,
    COUNT(*) AS total_companies

FROM global_layoff
GROUP BY region_group
ORDER BY avg_severity DESC;


-- Q 9 Which economic cycle flag results in the highest average stock price drop?

SELECT economic_cycle_flag,
		ROUND(AVG (stock_price_change_7d),2)  AS avg_stock_price_drop,
		COUNT(*) AS total_company
		
FROM global_layoff
GROUP BY 1
ORDER BY 2 DESC;

--Q 10 Do companies in North America respond differently to Tech Correction compared to Europe?
	

SELECT 
    continent,
	economic_cycle_flag,
    ROUND(AVG(layoff_count), 2) AS avg_layoff_count,
    ROUND(AVG(workforce_percentage), 2) AS avg_workforce_percent,
    ROUND(AVG(stock_price_change_7d), 2) AS avg_stock_change,
    ROUND(AVG(layoff_severity_score), 2) AS avg_severity,
    COUNT(*) AS total_companies
FROM global_layoff
WHERE continent IN ('North America', 'Europe')
  AND economic_cycle_flag = 'Tech Correction'
GROUP BY 1,2
ORDER BY 6 DESC;

--Q 11 Do Startups have higher layoff severity compared to Enterprises?



SELECT   company_size,
 		 ROUND(AVG(layoff_severity_score), 2) AS avg_severity
 	FROM 
		  global_layoff
		  GROUP BY 1
		  ORDER BY 2 DESC


--Q12 Which company size category shows the highest market cap volatility?

SELECT 
    company_size,
    ROUND(STDDEV(market_cap_billion_usd), 2) AS market_cap_volatility,
    ROUND(AVG(market_cap_billion_usd), 2) AS avg_market_cap,
    COUNT(*) AS total_companies
FROM global_layoff
GROUP BY company_size
ORDER BY market_cap_volatility DESC;

--Q13 Are companies with positive revenue growth still conducting layoffs?

SELECT 
        CASE 
        WHEN revenue_growth_percent > 0 THEN 'Positive Growth'
        ELSE 'Negative Growth'
        END AS growth_status,
    
    ROUND(AVG(layoff_count), 2) AS avg_layoff_count,
    ROUND(AVG(workforce_percentage), 2) AS avg_workforce_percent,
    ROUND(AVG(layoff_severity_score), 2) AS avg_severity,
    COUNT(*) AS total_companies

FROM global_layoff
GROUP BY growth_status
ORDER BY avg_severity DESC;

--Q14 Does hiring_status = 'Hiring' contradict high layoff counts? (Strategic restructuring?)


--hiring vs not hiring

SELECT  hiring_status,
		ROUND(COUNT(layoff_count), 2) AS total_layoff_count,
	    ROUND(AVG(layoff_count), 2) AS avg_layoff_count,
	    ROUND(AVG(workforce_percentage), 2) AS avg_workforce_percent,
	    ROUND(AVG(layoff_severity_score), 2) AS avg_severity,
	    COUNT(*) AS total_companies
FROM global_layoff
		GROUP BY 1


---hiring with layoff
SELECT 
    COUNT(*) AS hiring_with_high_layoffs_companies
	FROM global_layoff
	WHERE hiring_status = 'Hiring'
  	AND layoff_count > (
        SELECT AVG(layoff_count)
        FROM global_layoff
  );
  
--AI IMPACT
SELECT 
    hiring_status,
    ai_automation_flag,
    ROUND(AVG(layoff_count),2) AS avg_layoff
FROM global_layoff
GROUP BY 1,2
ORDER BY 1;
  

--Q15  Which company size reduces workforce the most during restructuring?

SELECT company_size,
		ROUND(AVG(layoff_count), 2) AS avg_layoff_count,
	    ROUND(AVG(workforce_percentage), 2) AS avg_workforce_percent,
	    ROUND(AVG(layoff_severity_score), 2) AS avg_severity,
	    COUNT(*) AS total_companies
FROM global_layoff
WHERE reason = 'Restructuring'
GROUP BY 1
ORDER BY 3 DESC;

----add economic cycle flag

SELECT 
    company_size,
    economic_cycle_flag,
    ROUND(AVG(workforce_percentage), 2) AS avg_workforce_percent
FROM global_layoff
WHERE reason = 'Restructuring'
GROUP BY 1,2
ORDER BY 1 ;


--Q 16 Do companies with ai_automation_flag = 1 show higher layoff_severity_score?


SELECT  
		ai_automation_flag,
		AVG(layoff_severity_score) AS avg_layoff_severity_score,
		COUNT(*) AS total_company
	FROM global_layoff
	GROUP BY 1;


		SELECT 
    CORR(ai_automation_flag::int, layoff_severity_score) AS correlation_ai_severity
FROM global_layoff;


--Q 17 Is AI adoption associated with workforce percentage reduction?

   
SELECT  
		ai_automation_flag,
		AVG(workforce_percentage) AS avg_workforce_percentage,
		COUNT(*) AS total_company
	FROM global_layoff
	GROUP BY 1;

-- Compare Average Workforce %

	SELECT 
    economic_cycle_flag,
    ai_automation_flag,
    ROUND(AVG(workforce_percentage),2) AS avg_workforce_percent,
	COUNT(*) AS total_company
FROM global_layoff
GROUP BY 1,2
ORDER BY economic_cycle_flag;

	---STATISTICAL CHECK	
SELECT
	CORR( ai_automation_flag::INT ,workforce_percentage) AS correraltion_ai_workforce
FROM global_layoff


--Q 18 Which industries show highest layoffs due to AI automation?


SELECT industry,
		ROUND(AVG(layoff_count), 2) AS avg_layoff_count,
	    ROUND(AVG(workforce_percentage), 2) AS avg_workforce_percent,
	    ROUND(AVG(layoff_severity_score), 2) AS avg_severity,
	    COUNT(*) AS total_companies
		
FROM global_layoff
WHERE ai_automation_flag= 'true'
GROUP BY 1
ORDER BY 3 DESC ;

--compare AI VS NON AI indust
SELECT 
    industry,
    ai_automation_flag,
    ROUND(AVG(workforce_percentage), 2) AS avg_workforce_percent
FROM global_layoff
GROUP BY industry, ai_automation_flag
ORDER BY industry;


--Q 19 Can layoff_severity_score predict stock price movement within 7 days?


SELECT 
    CASE
        WHEN layoff_severity_score < 2000 THEN 'Low Severity'
        WHEN layoff_severity_score BETWEEN 2000 AND 5000 THEN 'Medium Severity'
        ELSE 'High Severity'
    END AS severity_category,
    
    ROUND(AVG(stock_price_change_7d),2) AS avg_stock_change,
    COUNT(*) AS total_companies

FROM global_layoff
GROUP BY 1
ORDER BY avg_stock_change;

			

/* Q 20 Build a ranking model:
Which companies are at highest financial distress risk using:

* Revenue decline
* Stock drop
* Layoff severity
* Workforce reduction
*/

SELECT 
    company,
	industry,
	ai_automation_flag,
	economic_cycle_flag,
    
-- Risk Components
    (CASE WHEN revenue_growth_percent < 0 
          THEN ABS(revenue_growth_percent) 
          ELSE 0 END) AS revenue_risk,

    (CASE WHEN stock_price_change_7d < 0 
          THEN ABS(stock_price_change_7d) 
          ELSE 0 END) AS stock_risk,

    layoff_severity_score AS severity_risk,
    workforce_percentage AS workforce_risk,

-- Total Composite Risk Score
    ROUND(
        (CASE WHEN revenue_growth_percent < 0 
              THEN ABS(revenue_growth_percent) 
              ELSE 0 END)
      +
        (CASE WHEN stock_price_change_7d < 0 
              THEN ABS(stock_price_change_7d) 
              ELSE 0 END)
      +
        layoff_severity_score
        +
        workforce_percentage
    , 2) AS total_risk_score

FROM global_layoff
ORDER BY total_risk_score DESC
LIMIT 10;



/*
		END OF THE PROJECT
		
		AUTHOR | Prince_Pandey 
			
*/


		








		
