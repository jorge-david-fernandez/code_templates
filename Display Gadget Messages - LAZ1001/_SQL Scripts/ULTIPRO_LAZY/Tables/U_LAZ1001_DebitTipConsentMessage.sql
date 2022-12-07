----------------------------------------------------------------------------------------------------------------------
-- Company:		  Ultimate Software Corp. 
-- Author:		  Adrian Serrano
-- Client:		  Lazy Dog Restaurants, LLC
-- Date:		  9/11/2019
-- Request:		  SR-2019-00245269
-- Purpose:		  Instant Pay Direct Deposit (from scope project SR-2019-00233967)
-- Last Modified: 
-----------------------------------------------------------------------------------------------------------------------

IF OBJECT_ID(N'[dbo].[U_LAZ1001_DebitTipConsentMessage]' ) IS NULL  
BEGIN
	CREATE TABLE U_LAZ1001_DebitTipConsentMessage(
		[udaRecID] INT IDENTITY(1,1) NOT NULL,
		[udaConsentMessage] VARCHAR(MAX) NOT NULL,
		CONSTRAINT pk_U_LAZ1001_DebitTipConsentMessage PRIMARY KEY (udaRecID))
END

GO

