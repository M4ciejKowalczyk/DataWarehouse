# Data Warehouse & Business Intelligence System

## Overview
This end-to-end Business Intelligence (BI) and Data Warehouse (DW) system was developed as part of the **Data Warehouses** coursework at **Gdańsk University of Technology**. The project delivers a comprehensive analytical ecosystem for a fictional fitness club chain, **EnergyFit**, managing and analyzing operational data. 

The system contains the entire BI lifecycle: from business requirements gathering and data engineering to multi-dimensional data warehouse modeling, ETL pipeline execution, OLAP cube optimization, and interactive dashboarding.

*Note: This project was developed in a two-person team.*

## Phase 1: Business Requirements Specification
The analysis identified two core business processes: group class participation and member activity management. To evaluate success, two measurable goals were formulated: increasing average group class attendance by at least 5% year-over-year and boosting the active member ratio from 53% to 60%. Furthermore, the Requirements Specification document defined a heterogeneous data source environment consisting of a relational database (operational reservation system) and flat Excel/CSV files containing qualitative member feedback.

## Phase 2: Source Schemas & Scalable Data Generation
To test the warehouse under realistic conditions, a custom Python script generated temporal data snapshots (T1 and T2) reflecting true source system drift over time. This synthetic data populated a fully designed operational SQL database mimicking the daily operations of the fitness club. Due to the massive scale of the generated operational data (scalable up to millions of records), the data was efficiently inserted into the database using BULK loading techniques.
## Phase 3: Data Warehouse Dimensional Design
The warehouse architecture relies on a multi-dimensional schema centered around two distinct fact tables: `Fact_PrzeprowadzenieZajec` (tracking overall class conduction instances by instructors in specific rooms) and `Fact_Uczestnictwo` (recording individual member enrollments, attendance, and qualitative feedback). These fact tables are surrounded by conformed dimensions, including Type 2 Slowly Changing Dimensions (SCD2) for both instructors and members to accurately track historical attribute changes like seniority tiers over time. The supporting dimension tables providing analytical context are comprehensively detailed below:

| Dimension Table | Short Description |
| :--- | :--- |
| **Dim_Sala** | Stores physical studio attributes, including the room number, maximum capacity, and size category. |
| **Dim_Instruktor** | An SCD Type 2 dimension storing employee details like name, specialization, and seniority tier. |
| **Dim_TypZajec** | Contains the descriptive names and detailed descriptions of the offered fitness classes. |
| **Dim_Czlonek** | An SCD Type 2 dimension storing member personal details and their club seniority categorization. |
| **Dim_Data** | A hierarchical date dimension enabling chronological roll-ups by year, month, day of the week, holidays, and vacation periods. |
| **Dim_Czas** | A detailed time dimension categorizing class hours and broader times of day (e.g., morning, afternoon). |
| **Dim_Uczestnictwo_Junk** | A junk dimension storing low-cardinality transactional flags, such as the actual attendance status for a given class enrollment. |
| **Dim_Ocena** | Stores qualitative feedback details, capturing the numeric rating value and the categorized text comment left by a member. |

## Phase 4: OLAP Cube Implementation
In this phase, the physical multi-dimensional OLAP cube was designed and deployed using Microsoft Visual Studio (SQL Server Analysis Services). The conformed dimensions and fact tables designed in the previous stage were mapped to build strict attribute hierarchies and user-defined hierarchies. Measures such as total attendance and average ratings were established alongside custom calculated members.

## Phase 5: ETL Process Implementation
This phase focused on automating data orchestration by implementing ETL pipelines using SQL Server Integration Services (SSIS) alongside custom T-SQL orchestration scripts. The pipeline was engineered to execute seamless data loading across two distinct temporal checkpoints, handling full historical ingestion at T1 and delta updates at T2. Special logic was implemented to generate surrogate keys dynamically and manage Slowly Changing Dimensions (SCD Type 2) to maintain historical data integrity.

## Phase 6: Multi-Dimensional Analysis & KPIs (MDX)
Analytical problems defined in the requirements specification were mapped to technical multi-dimensional MDX queries. These queries utilized advanced features such as calculated members, sub-select WHERE clauses, and hierarchical navigation functions to identify trends in class registration and customer dissatisfaction. Additionally, core business goals were implemented as Key Performance Indicators (KPIs) within the cube. These KPIs programmatically evaluated current attendance and rating performance against historical targets using the ParallelPeriod function to track status and trends over time.

## Phase 7: Data Warehouse Optimization
This phase investigated performance tuning across a dataset of one million fact rows by evaluating different storage architectures and aggregation designs. Rigorous benchmarking compared the MOLAP and ROLAP storage models, revealing that while MOLAP required more storage space, it delivered significantly faster query execution. Designing custom aggregations inside the MOLAP cube further optimized execution, cutting query retrieval times down from 62 ms to approximately 10 ms. The optimization proved the trade-off of slightly increased cube processing times in exchange for rapid query execution.

## Phase 8: Reporting & Interactive Dashboards (Power BI)
The final stage materialized the analytical data into a comprehensive, multi-page interactive dashboard implemented in Power BI. The reporting layer featured custom metrics and cross-filtered charts to visualize attendance trends, year-over-year registration shifts, and average customer feedback. All report pages were fully parametrized with interactive slicers for years and months, giving end-users the ability to seamlessly filter insights across different time horizons. The finalized dashboard successfully delivered an intuitive interface for monitoring active KPIs and uncovering operational bottlenecks within the organization.

## Technologies Used
* **Database & DW Engine:** Microsoft SQL Server, SSAS (SQL Server Analysis Services)
* **ETL Automation:** SSIS (SQL Server Integration Services), T-SQL
* **Data Generation:** Python 3, Pandas, Faker
* **Analytics & Querying:** MDX (Multi-Dimensional Expressions)
* **Data Visualization:** Microsoft Power BI
