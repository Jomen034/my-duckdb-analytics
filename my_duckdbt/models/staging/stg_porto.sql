{{ 
    config(
        owner = ['jomen']
    ) 
}}

with source_data as (
    select * from {{ ref('porto') }}
),

cleaned_data as (
    select
        customerid as customer_id,
        trim(product) as product_name,
        trim(product_category) as product_category,
        -- Clean amount field - handle various formats including dashes
        case 
            when trim(" amount") = '-' or trim(" amount") = '' or trim(" amount") = ' - ' then 0
            else cast(
                replace(
                    replace(
                        replace(trim(" amount"), ',', ''), 
                        ' ', ''
                    ), 
                    '"', ''
                ) as numeric
            )
        end as cleaned_amount
    from source_data
)

select * from cleaned_data
