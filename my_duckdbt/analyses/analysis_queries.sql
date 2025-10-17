-- Quick analysis queries to answer the business questions
-- Run these in DuckDB to get insights

-- Question 1: Which product/product category is the biggest contributor to company revenue?
-- Top 10 products by total revenue
SELECT 
    product_name,
    product_category,
    total_revenue,
    revenue_percentage,
    customer_count,
    revenue_rank
FROM main_mart.revenue_analysis_by_product 
ORDER BY revenue_rank 
LIMIT 10;

-- Question 1: Top product categories by revenue
SELECT 
    product_category,
    SUM(total_revenue) as category_total_revenue,
    SUM(revenue_percentage) as category_revenue_percentage,
    COUNT(DISTINCT product_name) as product_count,
    SUM(customer_count) as total_customers
FROM main_mart.revenue_analysis_by_product 
GROUP BY product_category
ORDER BY category_total_revenue DESC;

-- Question 2: Which products are most popular among high-income customers?
-- Top products by adoption rate among high-income customers
SELECT 
    income_segment,
    product_category,
    unique_customers,
    adoption_rate_percent,
    total_value,
    customer_rank
FROM main_mart.high_income_customer_analysis 
WHERE customer_rank <= 5
ORDER BY income_segment, customer_rank;

-- Question 2: Product categories preferred by different income segments
SELECT 
    income_segment,
    product_category,
    SUM(unique_customers) as total_customers,
    AVG(adoption_rate_percent) as avg_adoption_rate,
    SUM(total_value) as total_value
FROM main_mart.high_income_customer_analysis 
GROUP BY income_segment, product_category
ORDER BY income_segment, total_customers DESC;
