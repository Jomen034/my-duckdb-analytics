#!/bin/bash
# streamlit_app.sh - Start the Customer 360 Streamlit app

echo "🚀 Starting Customer 360 Dashboard..."

# Check if virtual environment exists
if [ ! -d "dbt_env" ]; then
    echo "❌ Virtual environment not found. Please run ./dbt_setup.sh first."
    exit 1
fi

# Activate virtual environment
source dbt_env/bin/activate

# Check if database exists
if [ ! -f "duckdb_analytics/analytics.duckdb" ]; then
    echo "📊 Database not found. Running dbt pipeline..."
    source ../dbt_env/bin/activate
    cd my_duckdbt
    dbt seed
    dbt run
    dbt test
    cd ..
fi

# Install/upgrade streamlit if needed
echo "📦 Ensuring Streamlit is installed..."
pip install -r requirements.txt

# Start Streamlit app
echo "🌐 Starting Customer 360 Dashboard..."
echo "📍 App will be available at: http://localhost:8501"
echo "🛑 Press Ctrl+C to stop the app"
echo ""

streamlit run app.py
