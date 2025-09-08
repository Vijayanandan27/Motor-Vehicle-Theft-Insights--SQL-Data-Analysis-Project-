# Motor-Vehicle-Theft-Insights--SQL-Data-Analysis-Project-
I recently completed a comprehensive SQL data analysis project on Motor Vehicle Theft, where I explored trends, hotspots, and risk factors using relational data. This project was designed to replicate a real-world analytics workflow, from data cleaning to advanced insights.
🔑 Project Steps

1. Database & Schema Setup

Designed tables: stolen_vehicles, locations, make_details

Established relationships for location and manufacturer lookups

2. Data Quality & Cleaning

Checked for missing values, invalid dates, and duplicate records

Validated foreign key relationships between fact and dimension tables

Standardized date formats and model year categories

3. Exploratory Analysis

Theft trends by year & month 📅

Breakdown by vehicle type & color 🚘

Theft distribution by model year buckets (Old vs New)

4. Regional Insights

Top 5 regions with highest theft counts

Theft rate per 100,000 population 📊

Identified disproportionately high-density regions

5. Vehicle Manufacturer Analysis

Top 10 most stolen makes

Theft trends for top 5 makes over time

Standard vs other make types comparison

6. Temporal Analysis

Peak months and seasonal trends (Spring, Summer, Fall, Winter)

Weekday vs weekend theft patterns

7. Advanced Business-Oriented KPIs

Hotspot identification: region + make combinations most at risk

Percentage share of make types within each region

Cumulative theft growth trends over years

8. Advanced SQL (Subqueries, CTEs, Windows)

Used CTEs for YoY growth and top 3 makes per region

Window functions (ROW_NUMBER, LAG, SUM OVER) for trend analysis

Subqueries to identify regions/makes above overall averages

📌 Key Insights

Vehicle thefts are seasonal, with certain months peaking significantly.

A few manufacturers dominate theft counts, highlighting risk concentration.

Some regions show theft rates far higher than expected given population density.

Weekends see more theft incidents than weekdays.

🛠️ Tech Stack

SQL (MySQL) for data wrangling & analysis

Focus on joins, aggregations, CTEs, subqueries, and window functions

Designed queries for real-world KPI reporting
