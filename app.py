import streamlit as st
import duckdb
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
from datetime import datetime, timedelta
import numpy as np

# Page configuration
st.set_page_config(
    page_title="Customer 360 Dashboard",
    page_icon="📊",
    layout="wide",
    initial_sidebar_state="expanded"
)

# Custom CSS for better styling
st.markdown("""
<style>
    .main-header {
        font-size: 3rem;
        font-weight: bold;
        text-align: center;
        margin-bottom: 2rem;
        background: linear-gradient(90deg, #1f77b4, #ff7f0e);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
    }
    .metric-card {
        background-color: #f0f2f6;
        padding: 1rem;
        border-radius: 0.5rem;
        border-left: 4px solid #1f77b4;
    }
    .section-header {
        font-size: 1.5rem;
        font-weight: bold;
        margin-top: 2rem;
        margin-bottom: 1rem;
        color: #1f77b4;
    }
</style>
""", unsafe_allow_html=True)

# Database connection
@st.cache_resource # cache the connection to the database
def get_db_connection():
    """Create and cache database connection"""
    try:
        conn = duckdb.connect('my_duckdbt/analytics.duckdb')
        return conn
    except Exception as e:
        st.error(f"Database connection failed: {e}")
        return None

# Data loading functions
@st.cache_data # cache the data loading functions
def load_customer_list():
    """Load list of customers for filtering"""
    conn = get_db_connection()
    if conn is None:
        return pd.DataFrame()
    
    query = """
    SELECT DISTINCT 
        p.customer_id,
        p.gender,
        p.income_bracket,
        p.income_level,
        CASE 
            WHEN p.income_level >= 6 THEN 'Very High Income (>25 Juta)'
            WHEN p.income_level >= 4 THEN 'High Income (>5 Juta)'
            WHEN p.income_level >= 3 THEN 'Medium-High Income (>3 Juta)'
            ELSE 'Lower Income'
        END as income_segment
    FROM main_stg.stg_profile p
    ORDER BY p.customer_id
    """
    
    try:
        return conn.execute(query).df()
    except Exception as e:
        st.error(f"Error loading customer list: {e}")
        return pd.DataFrame()

@st.cache_data # cache the data loading functions
def load_customer_profile(customer_id):
    """Load detailed customer profile"""
    conn = get_db_connection()
    if conn is None:
        return pd.DataFrame()
    
    query = """
    SELECT 
        customer_id,
        gender,
        income_bracket,
        income_level,
        CASE 
            WHEN income_level >= 6 THEN 'Very High Income (>25 Juta)'
            WHEN income_level >= 4 THEN 'High Income (>5 Juta)'
            WHEN income_level >= 3 THEN 'Medium-High Income (>3 Juta)'
            ELSE 'Lower Income'
        END as income_segment
    FROM main_stg.stg_profile
    WHERE customer_id = ?
    """
    
    try:
        return conn.execute(query, [customer_id]).df()
    except Exception as e:
        st.error(f"Error loading customer profile: {e}")
        return pd.DataFrame()

@st.cache_data # cache the data loading functions
def load_customer_portfolio(customer_id):
    """Load customer portfolio data"""
    conn = get_db_connection()
    if conn is None:
        return pd.DataFrame()
    
    query = """
    SELECT 
        product_name,
        product_category,
        cleaned_amount,
        CASE 
            WHEN cleaned_amount > 0 THEN 'Active'
            ELSE 'Inactive'
        END as status
    FROM main_stg.stg_porto
    WHERE customer_id = ?
    ORDER BY cleaned_amount DESC
    """
    
    try:
        return conn.execute(query, [customer_id]).df()
    except Exception as e:
        st.error(f"Error loading customer portfolio: {e}")
        return pd.DataFrame()

@st.cache_data # cache the data loading functions
def load_customer_transactions(customer_id):
    """Load customer transaction data"""
    conn = get_db_connection()
    if conn is None:
        return pd.DataFrame()
    
    query = """
    SELECT 
        transaction_date,
        transaction_method,
        transaction_type,
        cleaned_transaction_amount,
        transaction_year,
        transaction_month,
        transaction_day_of_week
    FROM main_stg.stg_transaction
    WHERE customer_id = ?
    ORDER BY transaction_date DESC
    """
    
    try:
        return conn.execute(query, [customer_id]).df()
    except Exception as e:
        st.error(f"Error loading customer transactions: {e}")
        return pd.DataFrame()

@st.cache_data # cache the data loading functions
def load_portfolio_summary(customer_id):
    """Load portfolio summary from mart model"""
    conn = get_db_connection()
    if conn is None:
        return pd.DataFrame()
    
    query = """
    SELECT 
        product_category,
        product_count,
        total_amount,
        avg_amount,
        max_amount,
        min_amount,
        portfolio_percentage
    FROM main_mart.customer_portfolio_summary
    WHERE customer_id = ?
    ORDER BY total_amount DESC
    """
    
    try:
        return conn.execute(query, [customer_id]).df()
    except Exception as e:
        st.error(f"Error loading portfolio summary: {e}")
        return pd.DataFrame()

@st.cache_data # cache the data loading functions
def load_transaction_summary(customer_id):
    """Load transaction summary from mart model"""
    conn = get_db_connection()
    if conn is None:
        return pd.DataFrame()
    
    query = """
    SELECT 
        total_transactions,
        total_spent,
        avg_transaction_amount,
        max_transaction_amount,
        min_transaction_amount,
        payment_methods_used,
        transaction_types_used,
        first_transaction_date,
        last_transaction_date,
        transactions_per_day
    FROM main_mart.customer_transaction_analysis
    WHERE customer_id = ?
    """
    
    try:
        return conn.execute(query, [customer_id]).df()
    except Exception as e:
        st.error(f"Error loading transaction summary: {e}")
        return pd.DataFrame()

# Main app
def main():
    # Header
    st.markdown('<h1 class="main-header">Customer 360 Dashboard</h1>', unsafe_allow_html=True)
    
    # Sidebar for customer selection
    st.sidebar.header("🔍 Customer Selection")
    
    # Load customer list
    customers_df = load_customer_list()
    
    if customers_df.empty:
        st.error("No customer data available. Please run 'dbt seed' and 'dbt run' first.")
        return
    
    # Customer selection
    customer_options = customers_df['customer_id'].tolist()
    selected_customer = st.sidebar.selectbox(
        "Select Customer ID:",
        options=customer_options,
        format_func=lambda x: f"Customer {x}"
    )
    
    # Show customer info in sidebar
    if selected_customer:
        customer_info = customers_df[customers_df['customer_id'] == selected_customer].iloc[0]
        st.sidebar.markdown("### Customer Info")
        st.sidebar.metric("Customer ID", selected_customer)
        st.sidebar.metric("Gender", customer_info['gender'])
        st.sidebar.metric("Income Segment", customer_info['income_segment'])
        st.sidebar.metric("Income Bracket", customer_info['income_bracket'])
    
    # Main content
    if selected_customer:
        # Customer Profile Section
        st.markdown('<div class="section-header">👤 Customer Profile</div>', unsafe_allow_html=True)
        
        profile_df = load_customer_profile(selected_customer)
        if not profile_df.empty:
            col1, col2, col3, col4 = st.columns(4)
            
            with col1:
                st.metric("Customer ID", profile_df.iloc[0]['customer_id'])
            with col2:
                st.metric("Gender", profile_df.iloc[0]['gender'])
            with col3:
                st.metric("Income Level", profile_df.iloc[0]['income_level'])
            with col4:
                st.metric("Income Segment", profile_df.iloc[0]['income_segment'])
        
        # Portfolio Section
        st.markdown('<div class="section-header">💼 Portfolio Analysis</div>', unsafe_allow_html=True)
        
        portfolio_df = load_customer_portfolio(selected_customer)
        portfolio_summary_df = load_portfolio_summary(selected_customer)
        
        if not portfolio_df.empty:
            col1, col2 = st.columns(2)
            
            with col1:
                st.subheader("Portfolio Overview")
                if not portfolio_summary_df.empty:
                    # Portfolio metrics
                    total_portfolio = portfolio_summary_df['total_amount'].sum()
                    active_products = len(portfolio_df[portfolio_df['status'] == 'Active'])
                    categories = portfolio_summary_df['product_category'].nunique()
                    
                    col1_1, col1_2, col1_3 = st.columns(3)
                    with col1_1:
                        st.metric("Total Portfolio Value", f"Rp {total_portfolio:,.0f}")
                    with col1_2:
                        st.metric("Active Products", active_products)
                    with col1_3:
                        st.metric("Categories", categories)
                    
                    # Portfolio by category chart
                    fig_portfolio = px.pie(
                        portfolio_summary_df, 
                        values='total_amount', 
                        names='product_category',
                        title="Portfolio Distribution by Category"
                    )
                    st.plotly_chart(fig_portfolio, use_container_width=True)
            
            with col2:
                st.subheader("Product Details")
                # Portfolio table
                st.dataframe(
                    portfolio_df[['product_name', 'product_category', 'cleaned_amount', 'status']],
                    use_container_width=True,
                    hide_index=True
                )
        
        # Transaction Section
        st.markdown('<div class="section-header">💳 Transaction Analysis</div>', unsafe_allow_html=True)
        
        transaction_df = load_customer_transactions(selected_customer)
        transaction_summary_df = load_transaction_summary(selected_customer)
        
        if not transaction_df.empty:
            col1, col2 = st.columns(2)
            
            with col1:
                st.subheader("Transaction Overview")
                if not transaction_summary_df.empty:
                    summary = transaction_summary_df.iloc[0]
                    
                    col1_1, col1_2, col1_3 = st.columns(3)
                    with col1_1:
                        st.metric("Total Transactions", int(summary['total_transactions']))
                    with col1_2:
                        st.metric("Total Spent", f"Rp {summary['total_spent']:,.0f}")
                    with col1_3:
                        st.metric("Avg Transaction", f"Rp {summary['avg_transaction_amount']:,.0f}")
                    
                    col1_4, col1_5, col1_6 = st.columns(3)
                    with col1_4:
                        st.metric("Payment Methods", int(summary['payment_methods_used']))
                    with col1_5:
                        st.metric("Transaction Types", int(summary['transaction_types_used']))
                    with col1_6:
                        st.metric("Transactions/Day", f"{summary['transactions_per_day']:.2f}")
            
            with col2:
                st.subheader("Transaction Trends")
                # Transaction amount over time
                transaction_df['transaction_date'] = pd.to_datetime(transaction_df['transaction_date'])
                monthly_transactions = transaction_df.groupby([
                    transaction_df['transaction_date'].dt.to_period('M')
                ])['cleaned_transaction_amount'].sum().reset_index()
                monthly_transactions['transaction_date'] = monthly_transactions['transaction_date'].astype(str)
                
                fig_transactions = px.line(
                    monthly_transactions,
                    x='transaction_date',
                    y='cleaned_transaction_amount',
                    title="Monthly Transaction Amount",
                    labels={'cleaned_transaction_amount': 'Amount', 'transaction_date': 'Month'}
                )
                st.plotly_chart(fig_transactions, use_container_width=True)
            
            # Transaction details
            st.subheader("Recent Transactions")
            recent_transactions = transaction_df.head(10)[
                ['transaction_date', 'transaction_method', 'transaction_type', 'cleaned_transaction_amount']
            ]
            st.dataframe(recent_transactions, use_container_width=True, hide_index=True)
        
        # Customer Insights Section
        st.markdown('<div class="section-header">📊 Customer Insights</div>', unsafe_allow_html=True)
        
        if not portfolio_summary_df.empty and not transaction_summary_df.empty:
            col1, col2, col3 = st.columns(3)
            
            with col1:
                st.metric("Customer Value Score", "High" if portfolio_summary_df['total_amount'].sum() > 1000000 else "Medium")
            with col2:
                st.metric("Activity Level", "High" if transaction_summary_df.iloc[0]['total_transactions'] > 50 else "Medium")
            with col3:
                st.metric("Risk Profile", "Low" if customer_info['income_level'] >= 4 else "Medium")
    
    else:
        st.info("👈 Please select a customer from the sidebar to view their 360 profile.")

if __name__ == "__main__":
    main()
