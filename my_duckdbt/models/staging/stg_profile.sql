{{ 
    config(
        owner = ['jomen']
    ) 
}}

with source_data as (
    select * from {{ ref('profile') }}
),

cleaned_data as (
    select
        customer_id,
        trim(gender) as gender,
        trim(customer_income) as income_bracket,
        -- Create income numeric ranges for analysis
        case 
            when customer_income like '%sd. 1 Juta%' then 1
            when customer_income like '%>1 Juta - 3 Juta%' then 2
            when customer_income like '%>3 Juta - 5 Juta%' then 3
            when customer_income like '%>5 Juta - 10 Juta%' then 4
            when customer_income like '%>10 Juta - 25 Juta%' then 5
            when customer_income like '%>25 Juta - 50 Juta%' then 6
            when customer_income like '%>50 Juta - 100 Juta%' then 7
            when customer_income like '%>100 Juta%' then 8
            else 0
        end as income_level
    from source_data
)

select * from cleaned_data
