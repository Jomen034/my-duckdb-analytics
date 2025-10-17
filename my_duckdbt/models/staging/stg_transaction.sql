{{ 
    config(
        owner = ['jomen']
    ) 
}}

with source_data as (
    select * from {{ ref('transaction') }}
),

cleaned_data as (
    select
        -- Parse date from string format
        strptime(trim(activity_date), '%m/%d/%Y') as transaction_date,
        customerid as customer_id,
        trim(transaction_method) as transaction_method,
        trim(transaction_type) as transaction_type,
        -- Clean transaction amount - handle various formats including negatives
        case 
            when trim(" transaction_amount") = '' or trim(" transaction_amount") = '-' then 0
            else cast(
                replace(
                    replace(
                        replace(trim(" transaction_amount"), ',', ''), 
                        ' ', ''
                    ), 
                    '"', ''
                ) as numeric
            )
        end as cleaned_transaction_amount,
        -- Extract date components for analysis
        extract(year from strptime(trim(activity_date), '%m/%d/%Y')) as transaction_year,
        extract(month from strptime(trim(activity_date), '%m/%d/%Y')) as transaction_month,
        extract(dayofweek from strptime(trim(activity_date), '%m/%d/%Y')) as transaction_day_of_week
    from source_data
)

select * from cleaned_data
