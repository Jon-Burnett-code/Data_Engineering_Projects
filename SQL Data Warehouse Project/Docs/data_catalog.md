# Data Dictionary for Gold Layer
## Overview 
The Gold Layer is the buisness-level data representation, structured to suppport analytical and reporting use cases. It consitis of **dimension**
tables and **fact** tables for specific buiness metrics.

### 1.gold.dim_customers
  * Purpose: Stores cutomer details enriched with demographic and geographical data.
  * Columns
| Column Name  | Data Type | Description                                                                     |
|------------- |-----------|---------------------------------------------------------------------------------|
| customer_key | INT       | Surrogate key uniquely identifying each customer record in the dimension table. |
