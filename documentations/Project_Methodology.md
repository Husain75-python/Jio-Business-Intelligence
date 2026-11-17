\# Project Methodology

\## Reliance Jio – 10-Year Business Intelligence \& Growth Analysis



\### 1. Business Objective



The objective of this project is to analyze Reliance Jio's financial performance and business growth over the period FY2016–17 to FY2025–26 using SQL, PostgreSQL, Power BI, and DAX.



The analysis focuses on identifying financial trends, profitability patterns, and changes in business performance.



\### 2. Technology Stack



\- PostgreSQL – Data storage and querying

\- SQL – Data extraction, transformation, and analysis

\- Power BI Desktop – Interactive dashboard development

\- DAX – Measures and KPI calculations

\- GitHub – Project version control and documentation



\### 3. Data Sources



The project uses publicly available information from:



\- Reliance Jio financial statements

\- Reliance Industries annual reports

\- Official investor publications

\- Airtel annual reports for selected competitor comparisons



Only figures with identifiable sources and reporting periods are included in the analysis.



\### 4. Data Structure



The PostgreSQL database follows a structured analytical design.



| Table | Purpose |

|---|---|

| dim\_entity | Stores reporting entities |

| dim\_period | Stores financial periods |

| dim\_metric | Stores financial and operational metrics |

| fact\_metric | Stores metric observations and values |

| source\_reference | Stores source references |



\### 5. SQL Analysis



SQL techniques used include:



\- JOIN operations

\- Common Table Expressions (CTEs)

\- Aggregate functions

\- CASE statements

\- Window functions

\- LAG() for previous-period comparisons

\- Year-over-year growth calculations



\### 6. Financial KPIs



The analysis includes:



\- Revenue from Operations

\- Profit After Tax (PAT)

\- Revenue YoY Growth

\- PAT YoY Growth

\- Profitability ratios

\- Expense ratios

\- Revenue and profit trends



\### 7. Power BI \& DAX



Power BI is used to create interactive dashboards with:



\- KPI cards

\- Financial trend charts

\- Year-over-year comparisons

\- Analytical tables

\- Dynamic measures and metric selection

\- Interactive slicers



\### 8. Reporting Scope \& Data Limitations



\- RJIL standalone financials are kept separate from Reliance Industries consolidated figures and Jio Platforms Limited reporting.

\- Competitor figures are compared only where reporting definitions and periods are reasonably comparable.

\- Historical data availability varies by metric and reporting period.

\- FY2016–17 financial values require special attention because some figures are presented as comparative amounts in later financial statements.

\- Missing observations are not treated as zero unless the source explicitly reports zero.



\### 9. Expected Outcome



The project demonstrates an end-to-end Business Intelligence workflow, combining structured data management, SQL-based analysis, financial KPI development, and interactive visualization.



It is designed to communicate business performance through evidence-based analysis rather than unsupported assumptions.

