/*
===============================================================================
DDL Script: Create Gold Views
===============================================================================
Script Purpose:
    This script creates views for the Gold layer in the data warehouse. 
    The Gold layer represents the final dimension and fact tables (Star Schema)

    Each view performs transformations and combines data from the Silver layer 
    to produce a clean, enriched, and business-ready dataset.

Usage:
    - These views can be queried directly for analytics and reporting.
===============================================================================
*/

-- =============================================================================
-- Create Dimension: gold.dim_customers
-- =============================================================================



If object_ID ('gold.dim_customers', 'V') is not null
    Drop view gold.dim_customers
GO
Create View gold.dim_customers as (

SELECT 
       Row_number() over(order by ci.cst_id) as Customer_key -----------Generating a surrogate key to connect tables
      ,ci.[cst_id] as customer_id
      ,ci.[cst_key] as customer_number
      ,ci.[cst_firstname] as First_name
      ,ci.[cst_lastname] as Last_name
      ,[cst_marital_status] as Marrital_status
      ,CASE when [cst_gndr] != 'N/A' then [cst_gndr]
            else coalesce (ca.gen, 'N/A')
       END Gender -----CRM IS THE MASTER TABLE for gender
      ,ca.BDATE as Birthdate
      ,ci.[cst_create_date] as Create_date
      ,cl.CNTRY as Country
  FROM [Silver].[crm_cust_info] ci
  Left Join [Silver].[erp_cust_az12]  ca
  on ci.cst_key = ca.cid
  Left Join [Silver].[erp_loc_a101] cl
  on ci.cst_key = cl.cid
)

select * from gold.dim_customers
--PRD
----
If object_ID ('gold.dim_products', 'V') is not null
    Drop view gold.dim_products
GO
Create View gold.dim_products as (
SELECT
       ROW_NUMBER() over(order by Prd_id) as Product_key
      ,pr.[prd_id] as Product_ID
      ,pr.[prd_key] as Product_number
      ,pr.[prd_nm] as Product_name
      ,pr.[cat_id] as Category_ID
      ,pc.cat as Category
      ,pc.subcat as Subcategory
      ,pc.maintenance as Maintenance
      ,pr.[prd_cost] as Cost
      ,pr.[prd_line] as Product_line
      ,pr.[prd_start_dt] as Start_date
  FROM [Silver].[crm_prd_info] pr
  Left Join [Silver].[erp_px_cat_g1v2] pc
        on pr.cat_id = pc.ID
)

----Select * from gold.dim_products

---------------Creating a Fact_Table
If object_ID ('gold.fact_sales', 'V') is not null
    Drop view gold.fact_sales
GO
Create view gold.fact_sales as (

SELECT sd.[sls_ord_num] as Order_number
      ,pd.product_key
      ,cd.customer_key
      ,sd.[sls_order_dt] as Order_date
      ,sd.[sls_ship_dt] as Shipping_date
      ,sd.[sls_due_dt] as Due_date
      ,sd.[sls_sales] as Sales_amount
      ,sd.[sls_quantity] as Quantity
      ,sd.[sls_price] as Price
  FROM [Silver].[crm_sales_details] sd
  Left Join Gold.dim_products pd
  on sd.[sls_prd_key] = pd.Product_number
  Left Join gold.dim_customers cd
  on sd.sls_cust_id = cd.customer_id

  )
