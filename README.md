\# Procurement Spend \& Profit Recovery Analytics



\## 📊 Executive Summary



An end-to-end procurement analytics project designed to identify supplier spending patterns, procurement risks, payment issues, pricing variances, delivery performance, supplier quality issues, and potential procurement cost-recovery opportunities.



The project demonstrates an end-to-end analytics workflow:



\*\*Raw Data → MySQL → SQL Analysis → Python/Pandas → Machine Learning → Power BI → Business Insights\*\*



\---



\## 🎯 Business Objectives



The project was designed to answer key procurement questions:



\- Where is procurement spend concentrated?

\- Which suppliers contribute the highest spend?

\- How much procurement spend occurs without a linked contract?

\- Which suppliers have poor delivery or quality performance?

\- Where are potential pricing-recovery opportunities?

\- Which invoices require further investigation?

\- Which suppliers represent higher procurement risk?

\- What is the outstanding invoice exposure?



\---



\# 📈 Power BI Dashboard



\## Executive Procurement Dashboard



!\[Executive Procurement Dashboard](screenshots/executive\_dashboard.png)



The executive dashboard provides a high-level view of procurement performance including:



\- Total Procurement Spend

\- Purchase Order Count

\- Supplier Count

\- Potential Price Recovery

\- Late Delivery Rate

\- Rejection Rate

\- Non-Contract Spend

\- Top Suppliers

\- Category Spend

\- Top Product Recovery Opportunities

\- Supplier Risk Distribution



\---



\## Financial \& Supplier Risk Dashboard



!\[Financial \& Supplier Risk Dashboard](screenshots/financial\_supplier\_risk.png)



This page focuses on financial exposure and supplier risk:



\- Outstanding Invoice Value

\- Total Invoice Amount

\- Invoice Payment Performance

\- Supplier Risk Filtering

\- Supplier Risk Details

\- Delivery Performance

\- Rejection Rate



\---



\# 💰 Key Business Metrics



| Metric | Result |

|---|---:|

| Total Procurement Spend | ₹3,430.23 Cr |

| Purchase Orders | 2,500 |

| Suppliers | 100 |

| Potential Price Recovery | ₹260.19 Cr |

| Non-Contract Spend | 39.27% |

| Average Late Delivery | 80.19% |

| Average Rejection Rate | 3.19% |

| Total Invoice Amount | ₹2,711.63 Cr |

| Outstanding Invoice Value | ₹1,052.99 Cr |



> \*\*Note:\*\* The dataset is synthetic and these figures are for portfolio demonstration purposes.



\---



\# 🗄️ Data Model



The procurement database contains eight related entities:



| Entity | Purpose |

|---|---|

| Categories | Procurement category information |

| Suppliers | Supplier master and performance data |

| Products | Product and baseline cost information |

| Contracts | Supplier contract information |

| Purchase Orders | Procurement order transactions |

| Purchase Order Items | Product-level PO transactions |

| Invoices | Supplier invoice transactions |

| Payments | Invoice payment transactions |



The data was generated as synthetic procurement transactions with realistic business scenarios and selected data-quality issues for analytical validation.



\---



\# 🔎 SQL Analysis



SQL was used for data extraction, transformation, validation, and business analysis.



Implemented:



\- INNER JOIN and LEFT JOIN

\- GROUP BY

\- Aggregations

\- CASE expressions

\- CTEs

\- Window Functions

\- Analytical SQL Views

\- Supplier Spend Analysis

\- Category Spend Analysis

\- Contract Compliance Analysis

\- Delivery Performance Analysis

\- Supplier Quality Analysis

\- Price Variance Analysis

\- Invoice and Payment Analysis

\- Supplier Risk Classification



\## Analytical Views



Key SQL views include:



\- `vw\_procurement\_spend`

\- `vw\_supplier\_spend`

\- `vw\_category\_spend`

\- `vw\_contract\_spend`

\- `vw\_delivery\_performance`

\- `vw\_supplier\_quality`

\- `vw\_price\_variance`

\- `vw\_invoice\_payment`

\- `vw\_supplier\_kpi`

\- `vw\_procurement\_recovery`

\- `vw\_supplier\_risk`

\- `vw\_invoice\_analytics`



\---



\# 🐍 Python \& Pandas Analysis



Python and Pandas were used for data profiling, quality analysis, business analysis, validation, and visualization.



Implemented:



\- Data profiling

\- Missing-value analysis

\- Duplicate detection

\- Data quality checks

\- KPI calculation

\- Supplier analysis

\- Category analysis

\- Price-recovery analysis

\- Invoice-to-PO validation

\- Exploratory Data Analysis

\- Data visualization



\### Invoice-to-PO Validation



Invoice amounts were reconciled against the corresponding purchase-order line-item values to identify potential invoice-to-PO mismatches.



\---



\# 🤖 Machine Learning



\## Isolation Forest — Invoice Anomaly Detection



Isolation Forest was applied to identify potentially anomalous invoice transactions using:



\- Invoice Amount

\- Total Quantity

\- Average Unit Price

\- Purchase Order Value



Potential anomalies are flagged for further investigation and are \*\*not automatically considered fraudulent\*\*.



\---



\## K-Means — Supplier Segmentation



K-Means clustering was used to segment suppliers based on procurement characteristics including:



\- Total Spend

\- Average Unit Price

\- Purchase Quantity

\- Rejected Quantity



The segmentation helps identify groups of suppliers with similar procurement behavior.



\---



\# 💡 Key Business Insights



The analysis identified several procurement improvement opportunities.



\### 1. Supplier Spend Concentration



A significant portion of procurement spend is concentrated among a smaller group of suppliers, creating opportunities for strategic negotiation and supplier-management initiatives.



\### 2. Non-Contract Procurement



Approximately \*\*39.27% of procurement spend\*\* is associated with purchase orders without a linked contract, highlighting an opportunity to investigate contract coverage and procurement compliance.



\### 3. Delivery Performance



The overall late-delivery rate is approximately \*\*80.19%\*\*, indicating significant supplier delivery-performance concerns.



\### 4. Pricing Opportunities



Potential price-recovery opportunities were identified by comparing transaction unit prices against product baseline costs.



The modeled opportunity is approximately \*\*₹260.19 Cr\*\*.



These figures represent potential opportunities rather than guaranteed savings and require commercial validation.



\### 5. Supplier Risk



Supplier risk classification combines delivery and rejection performance to identify suppliers requiring greater management attention.



\### 6. Invoice Risk



Invoice-to-PO reconciliation and Isolation Forest anomaly detection help identify transactions that may require additional investigation.



\---



\# 🛠️ Technology Stack



| Area | Technologies |

|---|---|

| Programming | Python |

| Data Analysis | Pandas, NumPy |

| Database | MySQL |

| Querying | SQL |

| Machine Learning | Scikit-learn |

| Visualization | Matplotlib |

| Business Intelligence | Power BI |

| BI Calculations | DAX |

| Notebook | Jupyter |

| Version Control | Git \& GitHub |



\---



\# 📁 Project Structure



```text

Procurement-Analytics/

│

├── data/

│   ├── raw/

│   └── processed/

│

├── notebooks/

│   └── 01\_procurement\_eda.ipynb

│

├── powerbi/

│   └── Procurement\_Analytics\_Dashboard.pbix

│

├── reports/

│   └── data\_dictionary.md

│

├── screenshots/

│   ├── executive\_dashboard.png

│   └── financial\_supplier\_risk.png

│

├── sql/

│   ├── 03\_procurement\_analysis.sql

│   ├── 04\_analytical\_views.sql

│   ├── 05\_advanced\_business\_analysis.sql

│   └── 06\_final\_analytical\_datasets.sql

│

├── data\_quality.py

├── generate\_data.py

├── inspect\_data.py

├── load\_to\_mysql.py

├── test\_mysql\_connection.py

├── requirements.txt

├── README.md

└── .gitignore

