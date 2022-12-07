----------------------------------------------------------------------------------------------------------------------
-- Company:		  Ultimate Software Corp. 
-- Author:		  Adrian Serrano
-- Client:		  Lazy Dog Restaurants, LLC
-- Date:		  9/11/2019
-- Request:		  SR-2019-00245269
-- Purpose:		  Instant Pay Direct Deposit (from scope project SR-2019-00233967)
-- Last Modified: 
-----------------------------------------------------------------------------------------------------------------------

IF OBJECT_ID(N'[dbo].[U_LAZY_GetDefaultInstantPayDetails]') IS NOT NULL  
DROP PROCEDURE [dbo].[U_LAZY_GetDefaultInstantPayDetails] 
GO

CREATE PROCEDURE dbo.U_LAZY_GetDefaultInstantPayDetails
AS
BEGIN	
	
	CREATE TABLE #DefaultInstantPayParms (Parm char(100), Value char(100))

	INSERT INTO #DefaultInstantPayParms 
	SELECT codcode as Parm, coddesc as Value
	FROM codes
	WHERE codtable = 'CO_ACCOUNTDETAILS'						UNION ALL 
	SELECT 'BankName' as Parm, 'Instant Pay' as Value			UNION ALL 
	SELECT 'Status' as Parm, 'Y' as Value 						UNION ALL 
	SELECT 'PrenoteStatus' as Parm, 'D' as Value 				UNION ALL 
	SELECT 'AmountType' as Parm, 'rdoAvailableBalance' as Value
		
	DECLARE @cols AS NVARCHAR(MAX),
    @query  AS NVARCHAR(MAX)

	select @cols = STUFF((	SELECT ',' + QUOTENAME(RTRIM(Parm)) 
							from #DefaultInstantPayParms						
							FOR XML PATH(''), TYPE
							).value('.', 'NVARCHAR(MAX)') ,1,1,'')

	set @query = '	SELECT ' + @cols + ' from 
					(
						select Parm, Value
						from #DefaultInstantPayParms
					) x
					pivot 
					(
						MAX(Value)
						for Parm in (' + @cols + ')
					) p '

	execute(@query);

	drop table #DefaultInstantPayParms

END
GO
