--==================================================
-->>Performing Checks for all of the bronze data
--==================================================

--==================================================
-->> Performing Checks for bronze.crm_cust_info
--==================================================

-- Check For Nulls or Dublicates in Primary Key
-- Expectation: No results
SELECT 
cst_id,
COUNT(*)
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

--Check for unwanted spaces
--Expectation: No Results
SELECT cst_firstname
FROM bronze.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);

SELECT cst_lastname
FROM bronze.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname);

-- Data Standardization & Consistency
SELECT DISTINCT cst_gndr
FROM bronze.crm_cust_info;

SELECT DISTINCT cst_material_status
FROM bronze.crm_cust_info;

--==================================================
-->> Perfroming Checks for bronze.crm_prd_info
--==================================================

--Check for Nulls or Duplicates in Primary Key
--Expectations: No Results 
SELECT 
prd_id,
COUNT(*)
FROM bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

--Checking for Unwanted Spaces
--Expected Result: No results
SELECT prd_nm
FROM bronze.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

--Checking for Nulls or Negative Numbers
--Expectations: No results
SELECT prd_cost
FROM bronze.crm_prd_info
WHERE prd_cost IS null OR prd_cost < 0;

--Data Standardization & Consistency
SELECT DISTINCT prd_line
FROM bronze.crm_prd_info;

--Check for Invalid Date Orders
SELECT *
FROM bronze.crm_prd_info
WHERE prd_end_dt < prd_start_dt

--==================================================
-->> Performing Checks for bronze.crm_sales_details
--==================================================

--Checking for Unwanted Spaces
--Expectation: No results
SELECT * FROM bronze.crm_sales_details
WHERE sls_ord_num != TRIM(sls_ord_num);

--Checking everything working between sls_prd_key >> pr_key
--Expectation: No results
SELECT * FROM bronze.crm_sales_details
WHERE sls_prd_key NOT IN (SELECT prd_key FROM silver.crm_prd_info);
--Checking everything working between sls_cust_id >> cust_id
--Expectation: No results
SELECT * FROM bronze.crm_sales_details
WHERE sls_cust_id NOT IN (SELECT cst_id FROM silver.crm_cust_info);

--Check for Invalid dates
SELECT 
sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt <= 0;
--Check for Invalid dates cont.
 SELECT 
 NULLIF (sls_order_dt, 0) sls_order_dt
 FROM bronze.crm_sales_details
 WHERE sls_order_dt <= 0
 OR LEN(sls_order_dt) != 8;
 --Check for invalid date orders
 SELECT *
 FROM bronze.crm_sales_details
 WHERE sls_order_dt > sls_ship_date OR sls_order_dt > sls_due_date;

 --Check Data Consistency: Between Sales, Quantity, and Price
 -- >> Sales = Quantity * Price
 -- >> Values must not be NULL, zero, or negative.

 SELECT DISTINCT 
 sls_sales,
 sls_quantity,
 sls_price
 FROM bronze.crm_sales_details
 WHERE sls_sales != sls_quantity*sls_price
 OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL 
 OR sls_sales <=0 OR sls_quantity <=0 OR sls_price <=0
 ORDER BY sls_sales, sls_quantity, sls_price;

 --==================================================
-->> Perfroming Checks for bronze.erp_cust_az12
--==================================================
SELECT * FROM bronze.erp_cust_az12
WHERE

--Identify out of date ranges
SELECT DISTINCT 
bdate
FROM bronze.erp_cust_az12
WHERE bdate < '1925-01-01' OR bdate > GETDATE();

--Data Standardization & Consistency
SELECT DISTINCT gen
FROM bronze.erp_cust_az12;
 
  --==================================================
-->> Perfroming Checks for bronze.erp_loc_a101
--====================================================

SELECT 
REPLACE(cid, '-', '') cid
FROM bronze.erp_loc_a101
WHERE REPLACE(cid, '-', '') NOT IN (SELECT cst_key FROM silver.crm_cust_info);

--Data Standardization & Consistency
SELECT DISTINCT
cntry
FROM bronze.erp_loc_a101
ORDER BY cntry;


SELECT * FROM bronze.erp_loc_a101;

SELECT 
CASE WHEN TRIM(cntry) = 'DE' THEN 'Germany'
	 WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
	 WHEN Trim(cntry)  = '' OR cntry IS NULL THEN 'n/a'
	 ELSE TRIM(cntry)
END AS cntry

 --===================================================
-->> Perfroming Checks for bronze.erp_px_cat_g1v2
--====================================================

SELECT 
id,
cat,
subcat,
maintenance
FROM bronze.erp_px_cat_g1v2;

--Check for unwanted spaces
SELECT 
cat,
subcat,
maintenance
FROM bronze.erp_px_cat_g1v2
WHERE cat != TRIM(cat) OR subcat != TRIM(subcat) OR maintenance != TRIM(maintenance);

--Check data standardization and consistency
SELECT DISTINCT 
cat
FROM bronze.erp_px_cat_g1v2;

SELECT DISTINCT 
subcat
FROM bronze.erp_px_cat_g1v2;

SELECT DISTINCT 
maintenance
FROM bronze.erp_px_cat_g1v2;
