----------------------------------------------------------------------------------------------------------------------
-- Company:		  Ultimate Software Corp. 
-- Author:		  Adrian Serrano
-- Client:		  Lazy Dog Restaurants, LLC
-- Date:		  9/11/2019
-- Request:		  SR-2019-00245269
-- Purpose:		  Instant Pay Direct Deposit (from scope project SR-2019-00233967)
-- Last Modified: 
-----------------------------------------------------------------------------------------------------------------------

IF OBJECT_ID(N'[dbo].[U_LAZY_GetEmpLocationCode]') IS NOT NULL  
DROP PROCEDURE [dbo].[U_LAZY_GetEmpLocationCode]
GO

CREATE PROCEDURE dbo.U_LAZY_GetEmpLocationCode
(
	@EEID char(12),
	@COID char(6)
)
AS 
BEGIN

	SELECT Top 1 EecLocation
	FROM EmpComp
	WHERE eeceeid = @EEID
	  AND eecCoid = @COID
	  
END
GO
