----------------------------------------------------------------------------------------------------------------------
-- Company:		  Ultimate Software Corp. 
-- Author:		  Adrian Serrano
-- Client:		  Lazy Dog Restaurants, LLC
-- Date:		  12/3/2019
-- Request:		  SR-2019-00245269
-- Purpose:		  Instant Pay Direct Deposit (from scope project SR-2019-00233967)
-- Last Modified: 
-----------------------------------------------------------------------------------------------------------------------

IF OBJECT_ID(N'[dbo].[U_LAZ1001_GetCurrentEnrollmentMessage]') IS NOT NULL  
DROP PROCEDURE [dbo].[U_LAZ1001_GetCurrentEnrollmentMessage] 
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[U_LAZ1001_GetCurrentEnrollmentMessage]
AS
SET NOCOUNT ON
BEGIN
	select cnttext from content where cnttitle = 'Current Enrollment Message'
END
GO

SET NOCOUNT OFF
GO