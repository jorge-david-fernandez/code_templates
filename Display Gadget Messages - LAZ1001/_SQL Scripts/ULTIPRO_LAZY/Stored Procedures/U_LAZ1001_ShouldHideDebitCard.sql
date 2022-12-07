----------------------------------------------------------------------------------------------------------------------
-- Company:		  Ultimate Software Corp. 
-- Author:		  Adrian Serrano
-- Client:		  Lazy Dog Restaurants, LLC
-- Date:		  1/28/2020
-- Request:		  SR-2019-00245269
-- Purpose:		  Instant Pay Direct Deposit (from scope project SR-2019-00233967)
-- Last Modified: 
-----------------------------------------------------------------------------------------------------------------------

IF OBJECT_ID(N'[dbo].[U_LAZ1001_ShouldHideDebitCard]') IS NOT NULL  
DROP PROCEDURE [dbo].[U_LAZ1001_ShouldHideDebitCard] 
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[U_LAZ1001_ShouldHideDebitCard]
	@EEID CHAR(12),
	@COID CHAR(5)
AS
SET NOCOUNT ON
BEGIN


		SELECT (CASE WHEN Location_DebitCard = 1 THEN 'true' ELSE 'false' END)
		FROM dbo.fn_MP_CustomFields_iLocation_Export((SELECT TOP 1 sucUserCompanyID from vw_rbsUserCompany where sucEEID = @EEID), (SELECT TOP 1 EecEEType from EmpComp where EecEEID = @EEID AND EecCoID = @COID), NULL, NULL)
		WHERE Code = (SELECT TOP 1 EecLocation from EmpComp where EecEEID = @EEID AND EecCoID = @COID)
	
	
END
GO

SET NOCOUNT OFF
GO