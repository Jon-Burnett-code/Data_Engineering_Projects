/*
=============================================================================================
Stored Procedure: Load Silver Layer (bronze -> silver)
=============================================================================================
Script Purpose:
	This stored procedure performs the ETL (Extract, Transform, Load) process to
	populate the 'silver' schema tables from the 'broze' schema.
Actions Performed:
	Truncates Silver tables.
	Inserts transformed and cleansed data from Bronze into Silver tables.
Parameters:
	None.
	This stored procedure does not accept any parameters or return any values.

Usage Example:
	EXEC silver.load_silver;
=============================================================================================
*/
CREATE OR ALTER PROCEDURE silver.load_silver AS 
BEGIN 
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;

	BEGIN TRY
		SET @batch_start_time = GETDATE()
		
		PRINT'=====================================================';
		PRINT'Loading the Silver Layer';
		PRINT'=====================================================';

		PRINT'=====================================================';
		PRINT'Loading the CRM Tables';
		PRINT'=====================================================';

		SET @start_time = GETDATE()
		PRINT' >> Truncating Table: silver.crm_cust_info';
		TRUNCATE TABLE silver.crm_cust_info;

		PRINT' >> Inserting Data into Table: silver.crm_cust_info'
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

		SET @end_time = GETDATE()
		PRINT' >> Load Duration: ' +CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR)+ ' seconds';
		PRINT' >>-----------------------------------------';
		
		SET @start_time = GETDATE()
		PRINT' >> Truncating Table: silver.crm_prd_info';
		TRUNCATE TABLE silver.crm_prd_info;

		PRINT' >> Inserting Data into Table: silver.crm_prd_info';
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
		CAST(prd_start_dt AS DATE) AS prd_start_dt,
		CAST(
			LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)-1 
			AS DATE
		) AS prd_end_dt
		FROM bronze.crm_prd_info;

		SET @end_time = GETDATE()
		PRINT' >> Load Duration: ' +CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR)+ ' seconds';
		PRINT' >>-----------------------------------------';


		SET @start_time = GETDATE()
		PRINT' >> Truncating Table: silver.crm_sales_details';
		TRUNCATE TABLE silver.crm_sales_details;

		PRINT' >> Inserting Data into Table: silver.crm_sales_details';
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
		END AS sls_due_date,
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

		SET @end_time = GETDATE()
		PRINT' >> Load Duration: ' +CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR)+ ' seconds';
		PRINT' >>-----------------------------------------';

		PRINT'=====================================================';
		PRINT'Loading the ERP Tables';
		PRINT'=====================================================';

		SET @start_time = GETDATE()
		PRINT' >> Truncating Table: silver.erp_cust_az12';
		TRUNCATE TABLE silver.erp_cust_az12;

		PRINT' >> Inserting Data into Table: silver.erp_cust_az12';
		INSERT INTO silver.erp_cust_az12 (
			cid,
			bdate,
			gen
		)
		SELECT 
		CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
			 ELSE cid
		END AS cid,
		CASE WHEN bdate > GETDATE() THEN NULL
			 ELSE bdate
		END AS bdate,
		CASE WHEN UPPER(TRIM(gen)) IN ('M', 'Male') THEN 'Male'
			 WHEN UPPER(TRIM(gen)) IN ('F', 'Female') THEN 'Female'
			 ELSE 'n/a'
		END AS gen
		FROM bronze.erp_cust_az12;

		SET @end_time = GETDATE()
		PRINT' >> Load Duration: ' +CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR)+ ' seconds';
		PRINT' >>-----------------------------------------';


		SET @start_time = GETDATE()
		PRINT' >> Truncating Table: silver.erp_loc_a101';
		TRUNCATE TABLE silver.erp_loc_a101;

		PRINT' >> Inserting Data into Table: silver.erp_loc_a101';
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

		SET @end_time = GETDATE()
		PRINT' >> Load Duration: ' +CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR)+ ' seconds';
		PRINT' >>-----------------------------------------';

		SET @start_time = GETDATE()
		PRINT' >> Truncating Table: silver.erp_px_cat_g1v2';
		TRUNCATE TABLE silver.erp_px_cat_g1v2;

		PRINT' >> Inserting Data into Table: silver.erp_px_cat_g1v2';
		INSERT INTO silver.erp_px_cat_g1v2 (
			id,
			cat,
			subcat,
			maintenance
		)
		SELECT
		id,
		cat,
		subcat,
		maintenance
		FROM bronze.erp_px_cat_g1v2;
		SET @end_time = GETDATE()
		PRINT' >> Load Duration: ' +CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR)+ ' seconds';
		PRINT' >>-----------------------------------------';

		SET @batch_end_time = GETDATE()
		PRINT'================================================================================================================';
		PRINT'Whole Batch Load Time: ' + CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
		PRINT'================================================================================================================';

	END TRY
	BEGIN CATCH 
		PRINT '====================================================='
		PRINT 'ERROR OCCUDED DURING LOADING BRONZE LAYER'
		PRINT 'ERROR MESSAGE' + ERROR_MESSAGE();
		PRINT 'ERROR MESSAGE' + CAST (ERROR_NUMBER() AS NVARCHAR);
		PRINT 'ERROR MESSAGE' + CAST (ERROR_STATE() AS NVARCHAR);
		PRINT '====================================================='
	END CATCH
END
/*
=============================================================================================
Types of Transformations and cleansing completed for each table
=============================================================================================
Table 1 (bronze.crm_cust_info -> silver.crm_cust_info):
	-Removal of Unwanted Spaces (Row: 51-52)
		Ensures data consitency and uniformity in all records. 
			e.g. TRIM(cst_firstname) 
	-Data Normalization/Standardization (Row: 53-62)
		Maps coded values to meaningful, user-friednly descriptions. 
			e.g. CASE UPPER(TRIM(cst_marital_status)) WHEN 'M' THEN 'Married' ... ect. 
	-Handling Missing Data (Row: 57 and 62)
		Fills in blanks by adding a default value. 
			e.g. ...ELSE 'n/a' 
	-Remove Duplicates (Row: 63-70)
		Ensures only one record per entity by identifying and retaining the most relevant row.
			e.g.  SELECT *, ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last ... ect. 
			
Table 2 (bronze.crm_prd_info -> silver.crm_prd_info):
	- Derived Columns (Row: 93-94)
		Create new columns based on calculations or transformations of existing ones.
			e.g. REPLACE(SUBSTRING(prd_key, 1,5),'-', '_')AS cat_id,
	- Handling missing information (Row: 96)
		Changing a null to a value such as n/a
			e.g. ISNULL(prd_cost, 0) AS prd_cost,
	- Data Normalization (Row: 97-103)
		Instead of having a code value, changed it to a friendly value 
			CASE UPPER(TRIM(prd_line)) WHEN 'M' THEN 'Mountain' ... ect.
	- Handled Missing Data (Row: 102)
		Fills in blanks by adding a default value. 
			e.g. ...ELSE 'n/a' 
	- Data type casting (Row: 104)
		Converting the type from one type to another 
			e.g. CAST(prd_start_dt AS DATE) AS prd_start_dt,
	- Data type casting + Data enrichment (Row: 105-108)
		Converting the type from one type to another + add new, relevant data to enhance the dataset for analysis
			e.g. CAST(LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)-1 AS DATE ... ect.

Table 3 (bronze.crm_sales_details -> silver.crm_sales_details):
	- Handling invalid data + data type casting (Row: 136 - 144)
		e.g. CASE WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL ...ect.
	- Handling missing + invalid data by deriving the column from an already exisiting one (Row: 145 - 153)
		e.g. CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price) ... ect.

Table 4 (bronze.erp_cust_az12 -> silver.erp_cust_az12):
	- Handled invalid values (Row: 175 - 177)
		e.g. CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid)) ELSE cid END AS cid,
	- Handled invalid values cont. ( Row: 178 - 180)
		e.g. CASE WHEN bdate > GETDATE() THEN NULL ELSE bdate END AS bdate, 
	- Data Normalizations + handled missing values (Row: 181 - 184)
		Mapped coded values to more friendly values 
			e.g. CASE WHEN UPPER(TRIM(gen)) IN ('M', 'Male') ...ect.

Table 5 (bronze.erp_loc_a101 -> silver.erp_loc_a101):
	- Handled invalid values (Row: 202)
		e.g. REPLACE(cid, '-', '') cid,
	- Data Normalization + Remove unwanted spaces (Row: 203-207)
		e.g. CASE WHEN TRIM(cntry) = 'DE' THEN 'Germany' ... ect.

Table 6 (bronze.erp_px_cat_g1v2 -> silver.erp_px_cat_g1v2):
	- NO TRANSFORMATIONS NEEDED
*/
