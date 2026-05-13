/*
===============================================================================
DDL Script: Create Bronze Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'bronze' schema, dropping existing tables 
    if they already exist.
	  Run this script to re-define the DDL structure of 'bronze' Tables
===============================================================================
*/

If OBJECT_ID ('bronze.crm_cust_info', 'U') is not null
    drop table bronze.crm_cust_info
Create Table bronze.crm_cust_info (
    cst_id Int,
    cst_key Nvarchar(50),
    cst_firstname Nvarchar(50),
    cst_lastname Nvarchar(50),
    cst_marital_status Nvarchar(50),
    cst_gndr Nvarchar(50),
    cst_create_date Date
)

If OBJECT_ID ('bronze.crm_sales_details', 'U') is not null
    drop table bronze.crm_sales_details
Create table bronze.crm_sales_details (
sls_ord_num Nvarchar(50),
sls_prd_key Nvarchar(50),
sls_cust_id Int,
sls_order_dt int,
sls_ship_dt int,
sls_due_dt int,
sls_sales Int,
sls_quantity Int,
sls_price int
)

If OBJECT_ID ('bronze.crm_prd_info', 'U') is not null
    drop table bronze.crm_prd_info
Create table bronze.crm_prd_info(
prd_id Int,
prd_key Nvarchar(50),
prd_nm Nvarchar(50),
prd_cost int,
prd_line Nvarchar(50),
prd_start_dt datetime,
prd_end_dt datetime
)

If OBJECT_ID ('bronze.erp_cust_az12', 'U') is not null
    drop table bronze.erp_cust_az12
Create table bronze.erp_cust_az12(
CID Nvarchar(50),
BDATE Date,
GEN Nvarchar(50)
)

If OBJECT_ID ('bronze.erp_loc_a101', 'U') is not null
    drop table bronze.erp_loc_a101
Create table bronze.erp_loc_a101(
CID Nvarchar(50),
CNTRY Nvarchar(50)
)

If OBJECT_ID ('bronze.erp_px_cat_g1v2', 'U') is not null
    drop table bronze.erp_px_cat_g1v2
Create table bronze.erp_px_cat_g1v2(
ID Nvarchar(50),
CAT Nvarchar(50),
SUBCAT Nvarchar(50),
MAINTENANCE Nvarchar(50)
)

