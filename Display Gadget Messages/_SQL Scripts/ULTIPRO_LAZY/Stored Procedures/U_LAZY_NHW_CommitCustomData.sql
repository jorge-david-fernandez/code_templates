----------------------------------------------------------------------------------------------------------------------
-- Company:		  Ultimate Software Corp. 
-- Author:		  Gayle Velazquez
-- Client:		  Lazy Dog Restaurants, LLC
-- Date:		  3/12/2018
-- Request:		  SR-2018-00189031
-- Purpose:		  Default Pay Statement Preference to Electronic copies only
-- Last Modified: 
-----------------------------------------------------------------------------------------------------------------------


IF OBJECT_ID(N'[dbo].[U_LAZY_NHW_CommitCustomData]' ) IS NOT NULL  
DROP PROCEDURE [dbo].[U_LAZY_NHW_CommitCustomData] 
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE dbo.U_LAZY_NHW_CommitCustomData (
	@JobID INT,
	@EEID char(12),
	@COID char(5)
) AS

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED; 
	
	UPDATE EmpPers
		SET EepSuppressDDA = 'Y'
		WHERE EepEEID = @EEID
		
GO

