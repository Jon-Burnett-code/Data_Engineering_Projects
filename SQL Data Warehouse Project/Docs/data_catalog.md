# Data Dictionary for Gold Layer
## Overview 
The Gold Layer is the buisness-level data representation, structured to suppport analytical and reporting use cases. It consitis of **dimension**
tables and **fact** tables for specific buiness metrics.

### 1. gold.dim_customers
  * Purpose: Stores cutomer details enriched with demographic and geographical data.
  * Columns:

| Column Name  | Data Type | Description |
| --- | --- | --- |
| customer_key | INT | Surrogate key uniquely identifying each customer record in the dimension table. |
| customer_id | INT | Unique numerical identifier assigned to each customer. |
| customer_number | NVARCHAR(50) | Alphabetical identifier representing the customer, used for tracking and refrencing. |
| first_name | NVARCHAR(50) | The customer's first name as recorded on the system. |
| last_name | NVARCHAR(50) | The customer's last name or family name. |
| country | NVARCHAR(50) | The country of residence for the customer (e.g. 'Australia') |
| marital_status| NVARCHAR(50) | The marital status of the customer (e.g. 'Single', 'Married') |
| gender | NVARCHAR(50) | The gender of the customer (e.g. 'Male', 'Female', ''n/a') |
| birthdate | DATE | The date of birth of the customer, formatted as YYYY-MM-DD (e.g. 1984-05-19) |
| create_date | DATE | The date and time when the customer record was created in the system. |

### 2. gold.dim_products
 * Purpose: Provides information about the product and their attributes
 * Columns:

| Column Name  | Data Type | Description |
| --- | --- | --- |
| product_key | INT | Surrogate key uniquely identifying each product record in the product dimension table. |
| product_id | INT | A unique identifier assigned to the procuct for internal tracing and referencing. |
| product_number | NVARCHAR(50) | A structured alphanumeric code representing the product, oftern used for categorization or inventory. |
| product_name | NVARCHAR(50) | Descriptive name of the product, including key details such as type, color and size. |
| category | NVARCHAR(50) | The broader classification of the product (e.g. Bikes, Components) to group related items. |
| subcategory | NVARCHAR(50) | A more detailed classification of the product within the category, such as product type. |
| maintenance | NVARCHAR(50) | Indicates whether the product requires maintenance (e.g. 'Yes', 'No'). |
| cost | NVARCHAR(50) | The cost or base price of the product, measured in monetary units. |
| product_line | DATE | The specific product line or series to which the product belongs (e.g. Road, Mountain). |
| start_date | DATE | The date when the product became available for sale or use, stored in. |

### 3. gold.fact_sales


