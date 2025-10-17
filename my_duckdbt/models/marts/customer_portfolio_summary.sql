{{ 
    config(
        owner = ['jomen'],
        tags = ['daily']
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

customer_portfolio_summary as (
    select
        customer_id,
        product_category,
        count(*) as product_count,
        sum(cleaned_amount) as total_amount,
        avg(cleaned_amount) as avg_amount,
        max(cleaned_amount) as max_amount,
        min(cleaned_amount) as min_amount
    from portfolio_data
    group by customer_id, product_category
),

customer_totals as (
    select
        customer_id,
        sum(total_amount) as total_portfolio_value,
        count(distinct product_category) as category_count,
        sum(product_count) as total_products
    from customer_portfolio_summary
    group by customer_id
)

select 
    cps.*,
    ct.total_portfolio_value,
    ct.category_count,
    ct.total_products,
    -- Calculate percentage of total portfolio
    round((cps.total_amount / ct.total_portfolio_value) * 100, 2) as portfolio_percentage
from customer_portfolio_summary cps
left join customer_totals ct on cps.customer_id = ct.customer_id
