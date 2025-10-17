#!/bin/bash
# setup.sh - Setup script for DuckDB Analytics project

echo "🚀 Setting up DuckDB Analytics project..."

if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 is required but not installed."
    exit 1
fi

echo "📦 Creating virtual environment..."
python3 -m venv dbt_env

echo "🔧 Installing dependencies..."
source dbt_env/bin/activate
pip install -r requirements.txt

PROFILES_DIR="$HOME/.dbt"
PROFILES_FILE="$PROFILES_DIR/profiles.yml"

if [ ! -d "$PROFILES_DIR" ]; then
    mkdir -p "$PROFILES_DIR"
fi

if [ ! -f "$PROFILES_FILE" ]; then
    echo "📝 Creating profiles.yml..."
    cat > "$PROFILES_FILE" << EOF
duckdb_analytics:
  target: dev
  outputs:
    dev:
      type: duckdb
      path: 'analytics.duckdb'
      threads: 4
      schema: main
    prod:
      type: duckdb
      path: 'analytics_prod.duckdb'
      threads: 4
      schema: main
EOF
else
    echo "✅ profiles.yml already exists"
fi

echo "🧪 Testing dbt connection..."
dbt debug

echo "✅ Setup complete! You can now run:"
echo "   source dbt_env/bin/activate"
echo "   cd my_duckdbt"
echo "   dbt seed"
echo "   dbt run"
echo "   dbt test"
echo "   or dbt build"
echo "   Then run the Streamlit app with ./streamlit_app.sh"