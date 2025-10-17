{{ 
    config(
        owner = ['jomen'],
        tags = ['monthly']
    ) 
}}

with profile_data as (
    select 
        customer_id,
        gender,
        income_bracket,
        income_level
    from {{ ref('stg_profile') }}
),

portfolio_data as (
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

-- Define high-income customers (top 3 income levels)
high_income_customers as (
    select
        customer_id,
        gender,
        income_bracket,
        income_level,
        case 
            when income_level >= 6 then 'Very High Income (>25 Juta)'
            when income_level >= 4 then 'High Income (>5 Juta)'
            when income_level >= 3 then 'Medium-High Income (>3 Juta)'
            else 'Lower Income'
        end as income_segment
    from profile_data
    where income_level >= 3  -- Focus on medium-high income and above
),

-- Portfolio analysis by income segment
portfolio_by_income as (
    select
        hic.income_segment,
        hic.income_bracket,
        pd.product_name,
        pd.product_category,
        count(distinct pd.customer_id) as customer_count,
        sum(pd.cleaned_amount) as total_portfolio_value,
        avg(pd.cleaned_amount) as avg_portfolio_value,
        count(*) as product_usage_count
    from portfolio_data pd
    inner join high_income_customers hic on pd.customer_id = hic.customer_id
    where pd.cleaned_amount > 0
    group by hic.income_segment, hic.income_bracket, pd.product_name, pd.product_category
),

-- Transaction analysis by income segment
transaction_by_income as (
    select
        hic.income_segment,
        hic.income_bracket,
        td.transaction_method,
        td.transaction_type,
        count(distinct td.customer_id) as customer_count,
        sum(td.cleaned_transaction_amount) as total_transaction_amount,
        avg(td.cleaned_transaction_amount) as avg_transaction_amount,
        count(*) as transaction_count
    from transaction_data td
    inner join high_income_customers hic on td.customer_id = hic.customer_id
    where td.cleaned_transaction_amount > 0
    group by hic.income_segment, hic.income_bracket, td.transaction_method, td.transaction_type
),

-- Product category summary for high-income customers
product_category_summary as (
    select
        hic.income_segment,
        hic.income_bracket,
        pd.product_category,
        count(distinct pd.customer_id) as unique_customers,
        sum(pd.cleaned_amount) as total_value,
        avg(pd.cleaned_amount) as avg_value,
        count(*) as usage_count,
        -- Calculate adoption rate within income segment
        round((count(distinct pd.customer_id) * 100.0 / 
               (select count(distinct hic2.customer_id) 
                from high_income_customers hic2 
                where hic2.income_segment = hic.income_segment)), 2) as adoption_rate_percent
    from portfolio_data pd
    inner join high_income_customers hic on pd.customer_id = hic.customer_id
    where pd.cleaned_amount > 0
    group by income_segment, income_bracket, product_category
),

-- Rank products by popularity among high-income customers
product_popularity_ranking as (
    select
        *,
        row_number() over (partition by income_segment order by unique_customers desc) as customer_rank,
        row_number() over (partition by income_segment order by total_value desc) as value_rank,
        row_number() over (partition by income_segment order by adoption_rate_percent desc) as adoption_rank
    from product_category_summary
)

select 
    income_segment,
    income_bracket,
    product_category,
    unique_customers,
    total_value,
    avg_value,
    usage_count,
    adoption_rate_percent,
    customer_rank,
    value_rank,
    adoption_rank,
    -- Calculate percentage of total high-income portfolio
    round((total_value / sum(total_value) over (partition by income_segment)) * 100, 2) as segment_value_percentage
from product_popularity_ranking
order by income_segment, customer_rank
