----------------------------------------------------------------------------------------------------------------------
-- Company:		  Ultimate Software Corp. 
-- Author:		  Adrian Serrano
-- Client:		  Lazy Dog Restaurants, LLC
-- Date:		  1/28/2020
-- Request:		  SR-2019-00245269
-- Purpose:		  Instant Pay Direct Deposit (from scope project SR-2019-00233967)
-- Last Modified: 
-----------------------------------------------------------------------------------------------------------------------

IF OBJECT_ID(N'[dbo].[U_LAZ1001_GetDirectDepositInfo]') IS NOT NULL  
DROP PROCEDURE [dbo].[U_LAZ1001_GetDirectDepositInfo] 
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[U_LAZ1001_GetDirectDepositInfo]
AS
SET NOCOUNT ON
BEGIN
	DECLARE @Acct VARCHAR(45), @Bank VARCHAR(45), @Route VARCHAR(45)

	SELECT @Acct = [Acct], @Bank = [Bank], @Route = [Route]
	FROM (SELECT CodCode,CodDesc
	FROM Codes (NOLOCK)
	WHERE CodTable = 'CO_ACCOUNTDETAILS') As SourceTable
	PIVOT (MAX(CodDesc) FOR CodCode IN ([Acct],[Bank],[Route])) AS PivotTable;

	SELECT @Acct AS Account,@Bank AS Bank,@Route AS [Route]
END
GO

SET NOCOUNT OFF
GO