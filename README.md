\# Procurement Spend \& Profit Recovery Analytics



\## Overview



An end-to-end procurement analytics project designed to identify supplier spending patterns, procurement risks, payment issues, pricing variances, and potential cost-recovery opportunities.



The project uses Python, MySQL, SQL, Machine Learning, Power BI, and DAX to transform procurement transactions into actionable business insights.



\## Business Objectives



\- Analyze supplier and category procurement spend

\- Identify non-contract procurement spend

\- Evaluate supplier delivery and quality performance

\- Detect unusual invoice transactions

\- Identify potential price-recovery opportunities

\- Analyze invoice payment performance

\- Classify supplier risk

\- Build an executive procurement dashboard



\## Technology Stack



\- Python

\- Pandas

\- NumPy

\- MySQL

\- SQL

\- Scikit-learn

\- Power BI

\- DAX

\- Jupyter Notebook



\## Data Model



The database contains:



\- Categories

\- Suppliers

\- Products

\- Contracts

\- Purchase Orders

\- Purchase Order Items

\- Invoices

\- Payments



\## SQL Analysis



Implemented:



\- JOINs

\- Aggregations

\- CASE expressions

\- CTEs

\- Window functions

\- Analytical views

\- Supplier spend analysis

\- Category spend analysis

\- Contract compliance analysis

\- Delivery performance analysis

\- Supplier quality analysis

\- Price variance analysis

\- Invoice and payment analysis



\## Python Analysis



Python and Pandas were used for:



\- Data profiling

\- Missing-value analysis

\- Duplicate detection

\- Data quality checks

\- KPI calculation

\- Supplier and category analysis

\- Invoice-to-PO validation

\- Price-recovery analysis



\## Machine Learning



\### Isolation Forest — Invoice Anomaly Detection



Isolation Forest was used to identify potentially anomalous invoice transactions based on:



\- Invoice amount

\- Quantity

\- Average unit price

\- Purchase order value



Potential anomalies are flagged for further investigation and are not automatically considered fraudulent.



\### K-Means — Supplier Segmentation



K-Means clustering was used to segment suppliers based on procurement characteristics such as:



\- Spend

\- Average unit price

\- Purchase quantity

\- Rejected quantity



\## Power BI Dashboard



The dashboard contains two analytical pages.



\### Executive Procurement Dashboard



\- Total procurement spend

\- Purchase order count

\- Supplier count

\- Potential price recovery

\- Late delivery rate

\- Rejection rate

\- Non-contract spend

\- Top suppliers

\- Category spend

\- Top recovery opportunities

\- Supplier risk distribution



\### Financial \& Supplier Risk



\- Outstanding invoice value

\- Total invoice amount

\- Invoice payment performance

\- Supplier risk filtering

\- Supplier risk details

\- Delivery performance

\- Rejection rate



\## Key Business Insights



The analysis identified:



\- Significant procurement spend concentration among top suppliers

\- High non-contract procurement exposure

\- High delivery lateness

\- Supplier quality differences

\- Significant modeled price-recovery opportunities

\- Supplier risk differences based on delivery and quality performance

\- Potentially anomalous invoice transactions requiring investigation



\## Important Note



The procurement dataset is synthetic and was generated for portfolio demonstration purposes.



Potential recovery figures represent modeled procurement savings opportunities and should be validated against contracts, market prices, taxes, freight, quality specifications, currency effects, and other commercial factors before implementation.

