{{ 
    config(
        owner = ['jomen'],
        tags = ['monthly']
    ) 
}}

with portfolio_data as (
    select 
        customer_id,
        product_name,
        product_category,
        cleaned_amount
    from {{ ref('stg_porto') }}
),

transaction_data as (
    select 
        transaction_date,
        customer_id,
        transaction_method,
        transaction_type,
        cleaned_transaction_amount,
        transaction_year,
        transaction_month,
        transaction_day_of_week
    from {{ ref('stg_transaction') }}
),

-- Calculate revenue from transactions
transaction_revenue as (
    select
        customer_id,
        sum(cleaned_transaction_amount) as total_transaction_revenue,
        count(*) as transaction_count,
        avg(cleaned_transaction_amount) as avg_transaction_amount
    from transaction_data
    where cleaned_transaction_amount > 0  -- Only positive transactions count as revenue
    group by customer_id
),

-- Calculate portfolio value by product
portfolio_revenue as (
    select
        customer_id,
        product_name,
        product_category,
        sum(cleaned_amount) as portfolio_value,
        count(*) as product_count
    from portfolio_data
    where cleaned_amount > 0  -- Only positive amounts
    group by customer_id, product_name, product_category
),

-- Combine transaction and portfolio data
combined_revenue as (
    select
        pr.customer_id,
        pr.product_name,
        pr.product_category,
        pr.portfolio_value,
        pr.product_count,
        coalesce(tr.total_transaction_revenue, 0) as transaction_revenue,
        coalesce(tr.transaction_count, 0) as transaction_count,
        coalesce(tr.avg_transaction_amount, 0) as avg_transaction_amount
    from portfolio_revenue pr
    left join transaction_revenue tr on pr.customer_id = tr.customer_id
),

-- Aggregate by product
product_revenue_summary as (
    select
        product_name,
        product_category,
        count(distinct customer_id) as customer_count,
        sum(portfolio_value) as total_portfolio_value,
        sum(transaction_revenue) as total_transaction_revenue,
        sum(portfolio_value + transaction_revenue) as total_revenue,
        avg(portfolio_value) as avg_portfolio_value,
        avg(transaction_revenue) as avg_transaction_revenue,
        sum(product_count) as total_product_count,
        sum(transaction_count) as total_transaction_count
    from combined_revenue
    group by product_name, product_category
),

-- Calculate revenue percentages
revenue_with_percentages as (
    select
        *,
        round((total_revenue / sum(total_revenue) over()) * 100, 2) as revenue_percentage,
        round((total_portfolio_value / sum(total_portfolio_value) over()) * 100, 2) as portfolio_percentage,
        round((total_transaction_revenue / sum(total_transaction_revenue) over()) * 100, 2) as transaction_percentage
    from product_revenue_summary
)

select 
    product_name,
    product_category,
    customer_count,
    total_portfolio_value,
    total_transaction_revenue,
    total_revenue,
    revenue_percentage,
    portfolio_percentage,
    transaction_percentage,
    avg_portfolio_value,
    avg_transaction_revenue,
    total_product_count,
    total_transaction_count,
    -- Ranking
    row_number() over (order by total_revenue desc) as revenue_rank,
    row_number() over (order by total_portfolio_value desc) as portfolio_rank,
    row_number() over (order by total_transaction_revenue desc) as transaction_rank
from revenue_with_percentages
order by total_revenue desc
