----------------------------------------------------------------------------------------------------------------------
-- Company:		  Ultimate Software Corp. 
-- Author:		  Jorge David Fernandez
-- Client:		  Lazy Dog Restaurants, LLC
-- Date:		  1/28/2020
-- Request:		  SR-2019-00245269
-- Purpose:		  Instant Pay Direct Deposit (from scope project SR-2019-00233967)
-- Last Modified: 
-----------------------------------------------------------------------------------------------------------------------

IF OBJECT_ID(N'[dbo].[U_LAZ1001_DownloadGadgetMessages]') IS NOT NULL  
DROP PROCEDURE [dbo].[U_LAZ1001_DownloadGadgetMessages]
GO

CREATE PROCEDURE dbo.U_LAZ1001_DownloadGadgetMessages
AS
BEGIN
	SELECT cntTitle AS MessageID, cntText AS [Message]
	FROM Content (NOLOCK)
	WHERE cntTitle IN ('DC Consent Wage','DC Non Consent Wage', 'DC Consent Tips', 'DC Non Consent Tips','Meal Waiver 1 Consent Y','Meal Waiver 1 Consent N','Meal Waiver 2 Consent Y','Meal Waiver 2 Consent N')
	UNION
	SELECT ctbTitle AS MessageID, ctbTitle AS [Message] FROM ContentBox (NOLOCK)
	WHERE ctbTitle IN ('DC Consent Wage','DC Non Consent Wage', 'DC Consent Tips', 'DC Non Consent Tips','Meal Waiver 1 Consent Y','Meal Waiver 1 Consent N','Meal Waiver 2 Consent Y','Meal Waiver 2 Consent N')
END
GO
