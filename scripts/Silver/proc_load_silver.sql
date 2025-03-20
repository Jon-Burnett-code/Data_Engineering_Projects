TRUNCATE TABLE silver.crm_cust_info;
INSERT INTO silver.crm_cust_info (
	cst_id,
	cst_key,
	cst_firstname,
	cst_lastname,
	cst_marital_status,
	cst_gndr,
	cst_create_date 
)
SELECT
cst_id,
cst_key,
TRIM(cst_firstname) AS cst_firstname,
TRIM(cst_lastname) AS cst_lastname,
CASE UPPER(TRIM(cst_marital_status))
	 WHEN 'M' THEN 'Married'
	 WHEN 'S' THEN 'Single'
	 ELSE 'n/a'
END AS marital_status,
CASE UPPER(TRIM(cst_gndr))
	 WHEN 'M' THEN 'Male'
	 WHEN 'F' THEN 'Female'
	 ELSE 'n/a'
END AS cst_gndr,
cst_create_date
FROM ( 
	 SELECT
	 *,
	 ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
	 FROM bronze.crm_cust_info
	 WHERE cst_id IS NOT NULL
)t WHERE flag_last = 1
 
TRUNCATE TABLE silver.crm_prd_info;
INSERT INTO silver.crm_prd_info (
	prd_id,
	cat_id,
	prd_key,
	prd_nm,
	prd_cost,
	prd_line,
	prd_start_dt,
	prd_end_dt
)
SELECT 
prd_id,
REPLACE(SUBSTRING(prd_key, 1,5),'-', '_')AS cat_id,
SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,
prd_nm,
ISNULL(prd_cost, 0) AS prd_cost,
CASE UPPER(TRIM(prd_line))
	 WHEN 'M' THEN 'Mountain'
	 WHEN 'R' THEN 'Road'
	 WHEN 'S' THEN 'Other Sales'
	 WHEN 'T' THEN 'Touring'
	 ELSE 'n/a'
END AS prd_line,
prd_start_dt,
LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)-1 AS prd_end_dt
FROM bronze.crm_prd_info;

TRUNCATE TABLE silver.crm_sales_details;
INSERT INTO silver.crm_sales_details (
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	sls_order_dt,
	sls_ship_date,
	sls_due_date,
	sls_sales,
	sls_quantity,
	sls_price
)
SELECT
sls_ord_num,
sls_prd_key,
sls_cust_id,
CASE WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
	ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
END AS sls_order_dt,
CASE WHEN sls_ship_date = 0 OR LEN(sls_ship_date) != 8 THEN NULL
	ELSE CAST(CAST(sls_ship_date AS VARCHAR) AS DATE)
END AS sls_ship_date,
CASE WHEN sls_due_date = 0 OR LEN(sls_due_date) !=8 THEN NULL
	ELSE CAST(CAST(sls_due_date AS VARCHAR) AS DATE)
END AS sls_due_date
CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
	 THEN sls_quantity * ABS(sls_price)
	 ELSE sls_sales
END AS sls_sales,
sls_quantity,
CASE WHEN sls_price IS NULL OR sls_price <= 0 
	 THEN sls_sales / NULLIF(sls_quantity, 0) 
	 ELSE sls_price
END AS sls_price
FROM bronze.crm_sales_details;

TRUNCATE TABLE silver.erp_loc_a101;
INSERT INTO silver.erp_loc_a101 (
	cid,
	cntry
)
SELECT 
REPLACE(cid, '-', '') cid,
CASE WHEN TRIM(cntry) = 'DE' THEN 'Germany'
	 WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
	 WHEN Trim(cntry)  = '' OR cntry IS NULL THEN 'n/a'
	 ELSE TRIM(cntry)
END AS cntry
FROM bronze.erp_loc_a101;

