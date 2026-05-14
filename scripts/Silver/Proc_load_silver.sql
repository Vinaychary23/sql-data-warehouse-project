/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================
Script Purpose:
    This stored procedure performs the ETL (Extract, Transform, Load) process to 
    populate the 'silver' schema tables from the 'bronze' schema.
	Actions Performed:
		- Truncates Silver tables.
		- Inserts transformed and cleansed data from Bronze into Silver tables.
		
Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC Silver.load_silver;
===============================================================================
*/

Create or alter procedure silver.load_silver as
Begin
    Declare @starttime datetime, @endtime datetime, @startbatch_time datetime, @endbatch_time datetime
    Set @startbatch_time =getdate()
    Begin Try
        Set @starttime= getdate()
        Print('Truncating: Silver.crm_cust_info')
        Truncate table Silver.crm_cust_info
        Print('Inserting: Silver.crm_cust_info')
        Insert into Silver.crm_cust_info (
            cst_id,
            cst_key,
            cst_firstname,
            cst_lastname,
            cst_marital_status,
            cst_gndr,
            cst_create_date
        )
Select 
	cst_id,
	[cst_key],
	coalesce(TRIM([cst_firstname]), 'unknown') as [cst_firstname],
	coalesce(TRIM([cst_lastname]),'unknwon') as [cst_lastname],
	Case when UPPER(TRIM(cst_marital_status)) = 'S' then 'SINGLE'
		 when UPPER(TRIM(cst_marital_status)) = 'M' then 'Married'
		 Else 'N/A'--------Normalise marital status into readable format
	END as [cst_marital_status],
	Case when Upper(Trim([cst_gndr])) = 'F' then 'FEMALE'
		 when Upper(Trim([cst_gndr])) = 'M' then 'MALE'
		 Else 'N/A'
	END as [cst_gndr],
	[cst_create_date]
from(
Select *,
Row_number() over(Partition by cst_id order by cst_create_date desc) as flags_last from Bronze.crm_cust_info
)t where flags_last = 1---------select the most recent records per cust
AND cst_id IS NOT NULL
AND cst_create_date IS NOT NULL
Set @endtime = GETDATE()


----Prd_info
Set @starttime = Getdate()
Print('Truncating: Silver.[crm_prd_info]')
Truncate table Silver.[crm_prd_info]
Print('Inserting: [Silver.[crm_prd_info]')
INSERT into Silver.[crm_prd_info](
	[prd_id],
    cat_id,
    [prd_key],
	[prd_nm],
	[prd_cost],
	[prd_line],
	[prd_start_dt],
	[prd_end_dt]
    )

Select 
    prd_id,
    Replace (SUBSTRING(prd_key, 1, 5), '-', '_') as cat_id, ---------Extracted catID
    SUBSTRING(prd_key, 7, Len(prd_key)) as prd_key,-----------Extracted Prd_id
    prd_nm,
    ISNULL(prd_cost, '0') as prd_cost,
    Case when UPPER(TRIM(prd_line)) = 'R' Then 'Road'
         when UPPER(TRIM(prd_line)) = 'S' Then 'Other sales'
         when UPPER(TRIM(prd_line)) = 'M' Then 'Mountain'
         when UPPER(TRIM(prd_line)) = 'T' Then 'Touring'
    Else 'N?A'
    END prd_line,

    Cast(prd_start_dt as date) as prd_start_dt,
    Lead(prd_start_dt) over(Partition by prd_key order by prd_start_dt) as prd_end_dt
from Bronze.crm_prd_info
set @endtime = getdate()

----Sales_details
set @starttime = getdate()
Print('Truncating: [Silver].[crm_sales_details]')
Truncate table [Silver].[crm_sales_details]
Print('Inserting: [Silver].[crm_sales_details]')
Insert into [Silver].[crm_sales_details]
(
       [sls_ord_num]
      ,[sls_prd_key]
      ,[sls_cust_id]
      ,[sls_order_dt]
      ,[sls_ship_dt]
      ,[sls_due_dt]
      ,[sls_sales]
      ,[sls_quantity]
      ,[sls_price]
      )
SELECT [sls_ord_num]
      ,[sls_prd_key]
      ,[sls_cust_id]
      ,Case when [sls_order_dt] = 0 or len([sls_order_dt]) != 8 then NULL
            Else Cast(Cast([sls_order_dt] as varchar) as date)
       END [sls_order_dt]
      ,Case when [sls_ship_dt] = 0 or len([sls_ship_dt]) !=8 then null
            Else Cast(Cast([sls_ship_dt] as varchar) as date)
        End [sls_ship_dt],
        Case when sls_due_dt = 0 or len(sls_due_dt ) !=8 then null
            Else cast(Cast(sls_due_dt as nvarchar) as date)
        END sls_due_dt,
       Case when sls_sales is null or sls_sales>= 0 or  sls_sales != [sls_quantity] *ABS([sls_price])
        Then [sls_quantity] * ABS([sls_price])
        Else sls_sales
        END as sls_sales,
  sls_quantity,
  Case when [sls_price] is null or [sls_price] >=0
       Then sls_sales/NULLIF([sls_quantity], 0)
       Else [sls_price]
       End [sls_price]
  FROM [Bronze].[crm_sales_details]
  Set @endtime = Getdate()

----ERP_Cust_info

Set @starttime = GETDATE()
Print('Truncating: [Silver].[erp_cust_az12]');
Truncate table [Silver].[erp_cust_az12]
Print('Inserting: [Silver].[erp_cust_az12]');
Insert into [Silver].[erp_cust_az12](
        [CID]
      ,[BDATE]
      ,[GEN]
)
SELECT  
    case when CID LIKE 'NAS%' Then SUBSTRING(CID, 4, Len(CID))
    Else CID
    END CID,
        Case when BDATE < '1900-01-01' or BDATE > Getdate() Then null
        Else BDATE
        End BDATE,
     Case when UPPER(Trim(Gen)) is null then 'N/A'
     when UPPER(Trim(Gen)) in( 'F', 'Female') then 'Female'
     When UPPER(Trim(Gen)) in( 'M' , 'Male') then 'Male'
     Else 'N/A'
     End Gen
  FROM [Bronze].[erp_cust_az12]
  Set @endtime= Getdate()

----ERP_LOC
set @starttime = getdate()
Print('Truncating: [Silver].[erp_loc_a101]');
Truncate table [Silver].[erp_loc_a101]
Print('Inserting: [Silver].[erp_loc_a101]');
Insert into [Silver].[erp_loc_a101]
(
    CID,
    CNTRY
)
Select 
Replace(CID, '-', '') CID,
case when CNTRY in( 'USA', 'US') Then 'United States'
     When CNTRY is null or CNTRY = '' then 'unknown'
     when CNTRY = 'DE' Then 'Germany'
else CNTRY
End CNTRY
From [Bronze].[erp_loc_a101]
set @endtime = getdate()

----ERP_PX

Set @starttime= GETDATE()
Print('Truncating: [Silver].[erp_px_cat_g1v2]');
Truncate table [Silver].[erp_px_cat_g1v2]
Print('Inserting: [Silver].[erp_px_cat_g1v2]');
Insert into [Silver].[erp_px_cat_g1v2]
(
       [ID]
      ,[CAT]
      ,[SUBCAT]
      ,[MAINTENANCE]
)
Select [ID]
      ,[CAT]
      ,[SUBCAT]
      ,[MAINTENANCE]
From [Bronze].[erp_px_cat_g1v2]
Set @endtime = getdate()
End try

    Begin catch
        Print ('Error Message'+ cast(Error_message() as nvarchar(20)))
        Print ('Error Line'+ Error_line());
        Print ('Error number'+ cast(Error_number()as nvarchar(20)));
    End catch
    set @endbatch_time =GETDATE()
END
