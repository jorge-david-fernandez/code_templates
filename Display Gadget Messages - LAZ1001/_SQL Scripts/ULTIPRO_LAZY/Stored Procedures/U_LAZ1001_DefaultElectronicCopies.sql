----------------------------------------------------------------------------------------------------------------------
-- Company:		  Ultimate Software Corp. 
-- Author:		  Adrian Serrano
-- Client:		  Lazy Dog Restaurants, LLC
-- Date:		  1/28/2020
-- Request:		  SR-2019-00245269
-- Purpose:		  Instant Pay Direct Deposit (from scope project SR-2019-00233967)
-- Last Modified: 
-----------------------------------------------------------------------------------------------------------------------

IF OBJECT_ID(N'[dbo].[U_LAZ1001_DefaultElectronicCopies]') IS NOT NULL  
DROP PROCEDURE [dbo].[U_LAZ1001_DefaultElectronicCopies] 
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[U_LAZ1001_DefaultElectronicCopies]
	@EEID CHAR(12)
AS
SET NOCOUNT ON
BEGIN

	-- SLC NULL eecUDFIeld21 values cause validation issues so correcting during page load through existing utility. PRO-113539
 		IF EXISTS (select 1 from empcomp(NOLOCK) WHERE eecEEID = @EEID and eecUDField21 is null)   
 			BEGIN 
 			 UPDATE Empcomp
  			 set eecUDField21 = 'N'
  			 WHERE eecEEID = @EEID and eecUDField21 is null
 			END
 	-- PRO-113539 Complete
 
	IF EXISTS (SELECT 1 FROM EmpComp (NOLOCK) WHERE eecEEID = @EEID AND eecUDField21 = 'Y')
	BEGIN 
		UPDATE EmpPers
		SET eepSuppressDDA = 'Y'
		WHERE eepEEID = @EEID
		AND eepSuppressDDA = 'N'

		UPDATE EmpPers
		SET eepConsentElectronicW2 = 'Y'
		WHERE eepEEID = @EEID
		AND eepConsentElectronicW2 = 'N'
	END
END
GO

SET NOCOUNT OFF
GO
