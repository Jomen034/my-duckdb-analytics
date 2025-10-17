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

profile_data as (
    select 
        customer_id,
        gender,
        income_bracket,
        income_level
    from {{ ref('stg_profile') }}
),

customer_transaction_summary as (
    select
        t.customer_id,
        count(*) as total_transactions,
        sum(t.cleaned_transaction_amount) as total_spent,
        avg(t.cleaned_transaction_amount) as avg_transaction_amount,
        max(t.cleaned_transaction_amount) as max_transaction_amount,
        min(t.cleaned_transaction_amount) as min_transaction_amount,
        count(distinct t.transaction_method) as payment_methods_used,
        count(distinct t.transaction_type) as transaction_types_used,
        min(t.transaction_date) as first_transaction_date,
        max(t.transaction_date) as last_transaction_date,
        -- Calculate transaction frequency (transactions per day)
        case 
            when date_diff('day', min(t.transaction_date), max(t.transaction_date)) > 0 
            then count(*) / date_diff('day', min(t.transaction_date), max(t.transaction_date))
            else count(*)
        end as transactions_per_day
    from transaction_data t
    group by t.customer_id
),

customer_profile_summary as (
    select
        cts.*,
        p.gender,
        p.income_bracket,
        p.income_level
    from customer_transaction_summary cts
    left join profile_data p on cts.customer_id = p.customer_id
)

select * from customer_profile_summary
