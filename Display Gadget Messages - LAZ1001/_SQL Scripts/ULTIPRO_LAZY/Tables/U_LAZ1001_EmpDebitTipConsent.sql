----------------------------------------------------------------------------------------------------------------------
-- Company:		  Ultimate Software Corp. 
-- Author:		  Adrian Serrano
-- Client:		  Lazy Dog Restaurants, LLC
-- Date:		  9/11/2019
-- Request:		  SR-2019-00245269
-- Purpose:		  Instant Pay Direct Deposit (from scope project SR-2019-00233967)
-- Last Modified: 
-----------------------------------------------------------------------------------------------------------------------

IF OBJECT_ID(N'[dbo].[U_LAZ1001_EmpDebitTipConsent]' ) IS NULL  
BEGIN
	CREATE TABLE U_LAZ1001_EmpDebitTipConsent(
		[udaRecID] INT IDENTITY(1,1) NOT NULL, 
		[udaEEID] CHAR(12) NOT NULL, 
		[udaCOID] CHAR(5) NOT NULL, 
		[udaAcknowledge] CHAR(1) NOT NULL,  
		[udaDateSigned] DATETIME NOT NULL, 
		[udaInitials] VARCHAR(50) NOT NULL, 
		[udaConsentType] VARCHAR(50) NOT NULL, 
		[udaTextID] INT NOT NULL, 
		CONSTRAINT pk_U_LAZ1001_EmpDebitTipConsent PRIMARY KEY (udaRecID, udaEEID, udaCOID))
END

GO

