/* 


*/ 
--===============================================
--Performing Checks for all of the bronze data
--===============================================

-->> Performing Checks for bronze.crm_cust_info
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

-->> Perfroming Checks for bronze.crm_prd_info

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
