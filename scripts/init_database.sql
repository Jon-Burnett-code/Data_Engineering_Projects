/*
========================================================
Create Database and Schemas
========================================================
Script Purpose:
  This script creates a new database named 'DataWarehouse' after checking if it already exists.
  If the database exists, it is dropped and recreated. Additionally, the script sets up three schemas 
  within the database: 'bronze', 'silver', 'gold'.

WARNING: 
  Running this script will drop the entire 'DataWarehouse' database if it exists.
  All Data in the database will be PERMANENTLY DELETED. Proceed with caution and 
  ensure you have proper backups before running the script.
*/

USE master;
Go 

-- Drop and recreate the 'DataWarehouse' database
IF EXISTS (SELECT 1 FROM sys.database WHERE name = 'DataWarehouse')
BEGIN
    ALTER DATABASE DateWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouse;
END;
GO

--Create the 'DataWarehouse' database
CREATE DATABASE DataWarehouse;
GO
  
USE DataWarehouse;
GO

--Creating schema's
CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
GO
