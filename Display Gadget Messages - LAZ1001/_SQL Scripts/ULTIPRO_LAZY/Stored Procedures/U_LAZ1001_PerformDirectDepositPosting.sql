----------------------------------------------------------------------------------------------------------------------
-- Company:		  Ultimate Software Corp. 
-- Author:		  Adrian Serrano
-- Client:		  Lazy Dog Restaurants, LLC
-- Date:		  1/28/2020
-- Request:		  SR-2019-00245269
-- Purpose:		  Instant Pay Direct Deposit (from scope project SR-2019-00233967)
-- Last Modified: 
-----------------------------------------------------------------------------------------------------------------------

IF OBJECT_ID(N'[dbo].[U_LAZ1001_PerformDirectDepositPosting]') IS NOT NULL  
DROP PROCEDURE [dbo].[U_LAZ1001_PerformDirectDepositPosting] 
GO

CREATE PROCEDURE [dbo].[U_LAZ1001_PerformDirectDepositPosting]
	@EEID CHAR(12),
	@COID CHAR(5),  
	@DebitCard CHAR(1)
AS
BEGIN
	IF(@DebitCard = 'Y')
	BEGIN
		UPDATE Empdirdp
		SET EddAccountIsInactive = 'Y',
			EddAmtOrPct = 0.01,
			EddDepositRule = 'F'
		WHERE EddEEID = @EEID AND EddCoID = @COID

		INSERT INTO Empdirdp
		(EddEEID,EddCoID,EddAcct,EddEEBankName,EddAcctType,EddEeBankRoute,EddAmtOrPct,EddAccountIsInactive,EddDepositRule,EddDdOrPrenote,EddSequence)
		--RA - ULTI-434453
		SELECT @EEID,@COID,[Acct],[Bank],'D',[Route],0.00,'Y','A','P',(SELECT TOP 1 number FROM master..[spt_values]
																		WHERE number > 0 
																		AND number NOT IN (SELECT  EddSequence FROM Empdirdp (NOLOCK)
																							WHERE EddEEID = @EEID AND EddCOID = @COID))
		--RA - ULTI-434453																				
		FROM (SELECT CodCode,CodDesc
		FROM Codes (NOLOCK)
		WHERE CodTable = 'CO_ACCOUNTDETAILS') As SourceTable
		PIVOT (MAX(CodDesc) FOR CodCode IN ([Acct],[Bank],[Route])) AS PivotTable;
	END
	ELSE
	BEGIN
		UPDATE Empdirdp
		--RA - ULTI-434453
		SET EddAccountIsInactive = 'Y',
		--RA - ULTI-434453
			EddAmtOrPct = 0.01,
			EddDepositRule = 'F'
		WHERE EddEEID = @EEID AND EddCoID = @COID AND EddAcctType = 'D'
	END
END
GO