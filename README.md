# 🦆 my-duckdb-analytics 

This is just self exploration contains complete analytics pipeline using **DuckDB** and **dbt**. The cases about analyzing customer portfolio, profile, and transaction data. This project demonstrates modern data engineering practices with a local-first approach.

This project also includes a **Streamlit web application** for simple interactive customer analysis.

[![dbt](https://img.shields.io/badge/dbt-1.10.13-orange)](https://www.getdbt.com/)
[![DuckDB](https://img.shields.io/badge/DuckDB-1.4.1-blue)](https://duckdb.org/)
[![Python](https://img.shields.io/badge/Python-3.8+-green)](https://python.org/)

## 📁 Project Structure

```
my-duckdb-analytics/
├── 📊 Data Pipeline - my-duckdbt
│   ├── seeds/                       # Raw CSV data
│   │   ├── porto.csv                # Customer portfolio data
│   │   ├── profile.csv              # Customer demographics
│   │   └── transaction.csv          # Transaction history
|   ├── analyses/
|   |   ├── analysis_queries.sql     # Ready-to-run SQL queries
│   ├── models/
│   │   ├── staging/                 # Data cleaning & standardization
│   │   │   ├── stg_porto.sql
│   │   │   ├── stg_profile.sql
│   │   │   ├── stg_transaction.sql
|   |   |   ├── _stg_models.yml
|   |   |   └── _stg_sources.yml
│   │   └── marts/                   # Business logic & aggregations
│   │       ├── customer_portfolio_summary.sql
│   │       ├── customer_transaction_analysis.sql
│   │       ├── daily_transaction_trends.sql
│   │       ├── revenue_analysis_by_product.sql
│   │       ├── high_income_customer_analysis.sql
│   │       └── _marts_models.yml
│   │── dbt_project.yml              # Project configuration
│   │── profiles.yml                 # Profiles config fot dbt
|   └── analytics.duckdb             # DuckDB database (auto-created)
├── 🛠️ Development
│   ├── dbt_setup.sh                 # Automated setup script
│   ├── requirements.txt             # Python dependencies
│   ├── analysis_queries.sql         # Ready-to-run SQL queries
│   └── dbt_env/                     # Virtual environment
└── 📚 Documentation
    └── BUSINESS_INSIGHTS.md         # Executive summary
```

## 🚀 Enable the dbt as the main weapon 

### Quick Start

### Prerequisites
- Python 3.8+
- Git

### One-Command Setup
```bash
git clone <your-repo-url>
cd my_duckdbt
chmod +x dbt_setup.sh
./dbt_setup.sh
```

### Manual Setup
```bash
# 1. Clone repository
git clone <https://github.com/Jomen034/my-duckdb-analytics>
cd my_duckdbt

# 2. Create virtual environment
python3 -m venv dbt_env
source dbt_env/bin/activate

# 3. Install dependencies
pip install -r requirements.txt

# 4. Run the pipeline
dbt seed
dbt run
dbt test
```

## 📊 Customer 360 Dashboard with Python Streamlit

### Quick start the dashboard
```bash
# Start the Customer 360 dashboard
./streamlit_app.sh
```

The app will be available at: **http://localhost:8501**

### Features
- **👤 Customer Profile**: Demographics and income segmentation
- **💼 Portfolio Analysis**: Product holdings and value distribution
- **💳 Transaction Analysis**: Spending patterns and trends
- **🔍 Customer Filtering**: Select any customer for detailed view
- **📊 Interactive Charts**: Portfolio distribution and transaction trends
- **📈 Customer Insights**: Value scoring and risk assessment

### Web App Sections
1. **Customer Selection**: Sidebar dropdown to choose any customer
2. **Profile Overview**: Key customer metrics and demographics
3. **Portfolio Dashboard**: Product holdings, categories, and values
4. **Transaction Analytics**: Spending patterns and monthly trends
5. **Customer Insights**: Value scoring and activity levels

## 📊 Business Questions Answered

This project answers key business questions:

1. **Which product/product category is the biggest contributor to company revenue?**
   - Model: `revenue_analysis_by_product`
   - Key Insight: MULTI CURRENCY (FUNDING) contributes 15.46% of total revenue

2. **Which product/product category is usually used by customers with high income?**
   - Model: `high_income_customer_analysis`
   - Key Insight: FUNDING products have 96% adoption among medium-high income customers

For more details, visit [this](https://github.com/Jomen034/my-duckdb-analytics/blob/main/BUSINESS_INSIGHTS.md)

## 🔧 Usage

### All together (duckdb + dbt and the 360 dashboard)
```bash
chmod +x streamlit_app.sh
./streamlit_app.sh
```

### Quick Analysis
```bash
# Move to dbt project
cd my_duckdbt

# Connect to database
duckdb analytics.duckdb

# Run analysis queries
.read analyses/analysis_queries.sql
```

## 📈 Data Models

### Staging Models (Data Cleaning)
- **`stg_porto`**: Customer portfolio data (cleaned amounts, standardized names)
- **`stg_profile`**: Customer demographics (income levels, gender)
- **`stg_transaction`**: Transaction data (parsed dates, cleaned amounts)

### Mart Models (Business Logic)
- **`customer_portfolio_summary`**: Portfolio analysis by customer and category
- **`customer_transaction_analysis`**: Transaction behavior and patterns
- **`daily_transaction_trends`**: Daily transaction patterns and seasonality
- **`revenue_analysis_by_product`**: Revenue contribution by product/category
- **`high_income_customer_analysis`**: Product adoption by income segments

## 📊 Data Quality

The project includes a built-in data quality test:
- Not null constraints on key fields

For improving data quality, there are possibilities to enhance tests, such as:
- Referential integrity checks
- Data freshness monitoring
- Custom business logic tests

## 📚 Resources

- [dbt Documentation](https://docs.getdbt.com/)
- [DuckDB Documentation](https://duckdb.org/docs/)
- [dbt-duckdb Adapter](https://github.com/jwills/dbt-duckdb)
- [Modern Data Stack](https://docs.getdbt.com/docs/introduction)
- [Streamlit](https://docs.streamlit.io/)

## 🙏 Acknowledgments

- [dbt Labs](https://www.getdbt.com/) for the amazing dbt framework
- [DuckDB Team](https://duckdb.org/) for the fast analytical database
- [Some Cool Youtube Channel](https://www.youtube.com/)
- The open-source data community for inspiration and tools
