----------------------------------------------------------------------------------------------------------------------
-- Company:		  Ultimate Software Corp. 
-- Author:		  Adrian Serrano
-- Client:		  Lazy Dog Restaurants, LLC
-- Date:		  1/28/2020
-- Request:		  SR-2019-00245269
-- Purpose:		  Instant Pay Direct Deposit (from scope project SR-2019-00233967)
-- Last Modified: 
-----------------------------------------------------------------------------------------------------------------------

IF OBJECT_ID(N'[dbo].[U_LAZ1001_SetDirectDepositsActive]') IS NOT NULL  
DROP PROCEDURE [dbo].[U_LAZ1001_SetDirectDepositsActive] 
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[U_LAZ1001_SetDirectDepositsActive]
AS
SET NOCOUNT ON
BEGIN
	DECLARE @EEID CHAR(12), @COID CHAR(5), @Acct VARCHAR(45)


	SELECT @Acct = [Acct]
	FROM (SELECT CodCode,CodDesc
	FROM Codes (NOLOCK)
	WHERE CodTable = 'CO_ACCOUNTDETAILS') As SourceTable
	PIVOT (MAX(CodDesc) FOR CodCode IN ([Acct])) AS PivotTable;

	DECLARE emp_cursor CURSOR FOR
	SELECT eecEEID,eecCOID
	FROM EmpComp (NOLOCK)
	WHERE eecUDField05 = 'Y'
	AND eecUDField21 = 'Y'

	OPEN emp_cursor

	FETCH NEXT FROM emp_cursor 
	INTO @EEID, @COID

	WHILE @@FETCH_STATUS = 0
	BEGIN
		UPDATE Empdirdp
		SET EddAmtOrPct = 0.01,
			EddAccountIsInactive = 'Y',
			EddDepositRule = 'D'
		WHERE EddEEID = @EEID
		AND EddCoID = @COID
		AND EddAcctType <> 'D'

		UPDATE Empdirdp
		SET EddAmtOrPct = 0,
			-- RA - ULTI-434453
			EddAccountIsInactive = 'N',
			-- RA - ULTI-434453
			EddDepositRule = 'A',
			EddDdOrPrenote = 'D'
		WHERE EddEEID = @EEID
		AND EddCoID = @COID
		AND EddAcctType = 'D'
		AND EddAcct = @Acct

		FETCH NEXT FROM emp_cursor 
		INTO @EEID, @COID
	END

	CLOSE emp_cursor;
	DEALLOCATE emp_cursor;
	
END
GO

SET NOCOUNT OFF
GO