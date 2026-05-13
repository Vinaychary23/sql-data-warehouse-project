/*
===============================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
===============================================================================
Script Purpose:
    This stored procedure loads data into the 'bronze' schema from external CSV files. 
    It performs the following actions:
    - Truncates the bronze tables before loading data.
    - Uses the `BULK INSERT` command to load data from csv Files to bronze tables.

Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC bronze.load_bronze;
===============================================================================
*/
Create or alter procedure bronze.load_bronze As 
BEGIN 
    Declare @starttime datetime, @endtime datetime, @batch_start_time datetime, @batch_end_time datetime
    BEGIN TRY

        set @batch_start_time= GETDATE()
        Print ('=================================================');
        Print ('Loading bronze layer');
        Print ('-------------------------------------------------');

        SET @starttime = getdate()
        Print('Loading ERP data');
        Print ('Truncating table:bronze.crm_cust_info');
        Truncate table bronze.crm_cust_info;
        Print ('Inserting into:bronze.crm_cust_info');
        Bulk insert bronze.crm_cust_info 
        from 'C:\Users\LENOVO\Downloads\datasets\source_crm\cust_info.csv'
        with(
            Firstrow = 2,
            Fieldterminator =',',
            Tablock
            )
        SET @endtime = GETDATE()
        Print ('Duration:'+ CAST(datediff(second,@starttime,@endtime) as nvarchar) + 'Seconds');
        Print ('--------------------------------------------------------------');


        Set @starttime= GETDATE()
        Print ('Truncating table:[Bronze].[crm_prd_info]');
        Truncate table [Bronze].[crm_prd_info]
        Print ('Inserting into:[Bronze].[crm_prd_info]');
        bulk insert [Bronze].[crm_prd_info]
        from 'C:\Users\LENOVO\Downloads\datasets\source_crm\prd_info.csv'
        with (
            Firstrow = 2,
            Fieldterminator = ',',
            Tablock
             )
        Set @endtime = GETDATE()
        Print('Duration:'+ Cast(Datediff(second, @starttime, @endtime) as nvarchar)+ 'Seconds')
        Print('-------------------------------------------------------------------')

        Set @starttime= GETDATE()
        Print ('Truncating table:[Bronze].[crm_sales_details]');
        Truncate table [Bronze].[crm_sales_details];
        Print ('Inserting into:[Bronze].[crm_sales_details]');
        bulk insert [Bronze].[crm_sales_details]
        from 'C:\Users\LENOVO\Downloads\datasets\source_crm\sales_details.csv'
        with(
            Firstrow= 2,
            Fieldterminator =',',
            Tablock
            )
        Set @endtime= GETDATE()
        Print('Duration:'+ Cast(Datediff(second, @starttime, @endtime) as nvarchar)+ 'Seconds')
        Print('-------------------------------------------------------------------')


        Print('===================================================');
        Print('Loading ERP data');
        Print('---------------------------------------------------');

        Set @starttime = GETDATE()
        Print('Truncating table: [Bronze].[erp_cust_az12]')
        Truncate table [Bronze].[erp_cust_az12]
        Print('Inserting into: [Bronze].[erp_cust_az12]')
        bulk insert [Bronze].[erp_cust_az12]
        from 'C:\Users\LENOVO\Downloads\datasets\source_erp\cust_az12.csv'
        with(
            Firstrow = 2,
            Fieldterminator =',',
            Tablock
            )
        Set @endtime = getdate()
        Print('Duration:'+ Cast(Datediff(second, @starttime, @endtime) as nvarchar)+ 'Seconds')
        Print('-------------------------------------------------------------------')

        Set @starttime = GETDATE()
        Print('Truncating table: [Bronze].[erp_loc_a101]')
        Truncate table [Bronze].[erp_loc_a101]
        Print('Inserting into: [Bronze].[erp_loc_a101]')
        bulk insert [Bronze].[erp_loc_a101]
        from 'C:\Users\LENOVO\Downloads\datasets\source_erp\loc_a101.csv'
        with(
            Firstrow = 2,
            Fieldterminator =',',
            Tablock
            )
        Set @endtime = GETDATE()
        Print('Duration:'+ Cast(Datediff(second, @starttime, @endtime) as nvarchar)+ 'Seconds')
        Print('-------------------------------------------------------------------')

        Set @starttime = getdate()
        Print('Truncating table: [Bronze].[erp_px_cat_g1v2]')
        Truncate table [Bronze].[erp_px_cat_g1v2]
        Print('Inserting into: [Bronze].[erp_px_cat_g1v2]')
        bulk insert [Bronze].[erp_px_cat_g1v2]
        from 'C:\Users\LENOVO\Downloads\datasets\source_erp\px_cat_g1v2.csv'
        with(
            Firstrow = 2,
            Fieldterminator =',',
            Tablock
            )
        Set @endtime = GETDATE()
        Print('Duration:'+ Cast(Datediff(second, @starttime, @endtime) as nvarchar)+ 'Seconds')
        Print('-------------------------------------------------------------------')
    END TRY
    BEGIN CATCH
        Print('===========================================');
        Print('Error_Occured'+ cast(ERROR_MESSAGE() as nvarchar(20)));
        Print('Error_Number'+ cast(ERROR_NUMBER() as nvarchar(20)));
        Print('Error_State' + ERROR_STATE());
    END CATCH
    set @batch_end_time= GETDATE()

    Print('Total duration:'+ Cast(Datediff(second,@batch_start_time, @batch_end_time) as nvarchar(20)))
END
