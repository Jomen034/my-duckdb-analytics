{{ 
    config(
        owner = ['jomen'],
        tags = ['daily']
    ) 
}}

with transaction_data as (
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

daily_transaction_summary as (
    select
        transaction_date,
        transaction_year,
        transaction_month,
        transaction_day_of_week,
        count(*) as transaction_count,
        sum(cleaned_transaction_amount) as total_amount,
        avg(cleaned_transaction_amount) as avg_amount,
        count(distinct customer_id) as unique_customers,
        count(distinct transaction_method) as payment_methods_used,
        count(distinct transaction_type) as transaction_types_used
    from transaction_data
    group by 
        transaction_date, 
        transaction_year, 
        transaction_month, 
        transaction_day_of_week
),

monthly_summary as (
    select
        transaction_year,
        transaction_month,
        count(*) as monthly_transaction_count,
        sum(total_amount) as monthly_total_amount,
        avg(total_amount) as monthly_avg_amount,
        count(distinct transaction_date) as active_days
    from daily_transaction_summary
    group by transaction_year, transaction_month
)

select 
    dts.*,
    ms.monthly_transaction_count,
    ms.monthly_total_amount,
    ms.monthly_avg_amount,
    ms.active_days,
    -- Calculate daily metrics
    round(dts.total_amount / dts.transaction_count, 2) as avg_transaction_value,
    round(dts.transaction_count / dts.unique_customers, 2) as transactions_per_customer
from daily_transaction_summary dts
left join monthly_summary ms 
    on dts.transaction_year = ms.transaction_year 
    and dts.transaction_month = ms.transaction_month
