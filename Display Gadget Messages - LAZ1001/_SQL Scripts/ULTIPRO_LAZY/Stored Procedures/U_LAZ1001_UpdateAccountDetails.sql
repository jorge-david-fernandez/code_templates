----------------------------------------------------------------------------------------------------------------------
-- Company:		  Ultimate Software Corp. 
-- Author:		  Adrian Serrano
-- Client:		  Lazy Dog Restaurants, LLC
-- Date:		  1/28/2020
-- Request:		  SR-2019-00245269
-- Purpose:		  Instant Pay Direct Deposit (from scope project SR-2019-00233967)
-- Last Modified: 
-----------------------------------------------------------------------------------------------------------------------

IF OBJECT_ID(N'[dbo].[U_LAZ1001_UpdateAccountDetails]') IS NOT NULL  
DROP PROCEDURE [dbo].[U_LAZ1001_UpdateAccountDetails] 
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[U_LAZ1001_UpdateAccountDetails]
AS
SET NOCOUNT ON
BEGIN
	DECLARE @Acct VARCHAR(45), @Bank VARCHAR(45), @Route VARCHAR(45)


	SELECT @Acct = [Acct], @Bank = [Bank], @Route = [Route]
	FROM (SELECT CodCode,CodDesc
	FROM Codes (NOLOCK)
	WHERE CodTable = 'CO_ACCOUNTDETAILS') As SourceTable
	PIVOT (MAX(CodDesc) FOR CodCode IN ([Acct],[Bank],[Route])) AS PivotTable;

	UPDATE Empdirdp
	SET EddAcct = @Acct,
		EddEeBankRoute = @Route,
		EddEEBankName = @Bank
	FROM Empdirdp (NOLOCK) JOIN EmpComp ON EddEEID = EecEEID AND EddCoID = EecCoID
	WHERE (EddAcct <> @Acct OR EddEeBankRoute <> @Route OR EddEEBankName <> @Bank) AND EecUDfield21 = 'Y'
	
END
GO

SET NOCOUNT OFF
GO