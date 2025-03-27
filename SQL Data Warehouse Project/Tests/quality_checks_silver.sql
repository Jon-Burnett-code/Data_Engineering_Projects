/*
=============================================================================
Quality Checks
=============================================================================
Script Purpose: 
  This script performs various quality checks for data consistency, accuracy,
  and standardization across the 'silver' schema.
  It checks for:
   - Null or duplicate primary keys.
   - Unwanted spaces in string fields.
   - Data standardization and consistency.
   - Invalid date ranges ad orders. 
   - Data consistency between related fields.

Usage notes:
  -  Run these checks after loading the silver layer.
  - Investigate and resolve any discrepancies found during the checks
=============================================================================
*/

-- =================================================================
-- Checking 'silver.crm_cust_info
-- =================================================================
-- Check for NULLs or Duplicates in Primary Key
-- Expectation no results
SELECT 
  cst_id,
  COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- =================================================================
-- Checking 'silver.crm_prd_info'
-- =================================================================
-- Check for NULLS or Duplicates in Primary Key 
-- Expectations: No results
SELECT 
  prd_id,
  COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL

-- Check for unwanted spaces
-- Expectations: No results
SELECT 
  prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

-- Check for Nulls or negative values in cost
-- Expectation: No Results
SELECT 
  prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;

-- Data standarization & consistency
SELECT DISTINCT 
  prd_line
FROM silver.crm_prd_info;

-- Check for invalid Date orders (start date > end date)
-- Expectation: No results
SELECT 
  *
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;

-- =================================================================
-- Checking 'silver.crm_sales_details'
-- =================================================================
-- Check for Invalid dates
-- Expectation: No results
SELECT 
  NULLIF(sls_due_date, 0) AS sls_due_date
FROM silver.crm_sales_details
WHERE sls_due_date <= 0 
  OR LEN(sls_due_date) != 8
  OR sls_due_date > 20500101
  OR sls_due_date < 19000101;

-- Check for Invalid date orders (Order date > shipping/due date)
-- Expectation: No results
SELECT 
  *
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_date
  OR sls_order_dt > sls_due_date;

-- Check data consistency: Sales = quantity * price
-- Expectation: No result
SELECT DISTINCT
  sls_sales,
  sls_quantity,
  sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
  OR sls_sales IS NULL 
  OR sls_quantity IS NULL 
  OR sls_price IS NULL
  OR sls_sales <= 0
  OR sls_quantity <= 0
  OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price;

-- =================================================================
-- Checking 'silver.erp_cust_az12'
-- =================================================================
-- Identify out of range dates
-- Expectation: Birthdates between 1925-01-01 and today
SELECT DISTINCT 
  bdate
FROM silver.erp_cust_az12
WHERE bdate < '1925-01-01'
  OR bdate > GETDATE();

-- Data Standardization & Consistency
SELECT DISTINCT 
  gen
FROM silver.erp_cust_az12;

-- =================================================================
-- Checking 'silver.erp_loc_a101'
-- =================================================================
-- Data Standardization & Consistency
SELECT DISTINCT 
  cntry
FROM silver.erp_loc_a101
ORDER BY cntry;

-- =================================================================
-- Checking 'silver.erp_px_cat_g1v2'
-- =================================================================
-- Check for Unwanted spaces
-- Expectation: No result
SELECT 
  *
FROM silver.erp_px_cat_g1v2
WHERE cat != TRIM(cat)
  OR subcat != TRIM(subcat)
  OR maintenance != TRIM(maintenance);

-- Data Standardization & Consistency
SELECT DISTINCT 
  maintenance
FROM silver.erp_px_cat_g1v2;
