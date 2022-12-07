DROP PROCEDURE IF EXISTS [dbo].[U_PER1027_AdditionalPayDetail_Get]
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[U_PER1027_AdditionalPayDetail_Get]
	@RecId int = NULL
AS
----------------------------------------------------------------------------------------------------------------------
-- Company:		  UKG 
-- Author:		  Jorge Fernandez
-- Client:		  Performance Food Group, Inc.
-- Date:		  11/2/2022
-- Request:		  SR-2022-00377312
-- Purpose:		  Custom Web Page for Additional Pay Detail
-- Last Modified: 
-----------------------------------------------------------------------------------------------------------------------
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET NOCOUNT ON

	SELECT
		uapPayDate,
		uapWeekEndDate,
		uapDesc,
		uapHours,
		uapUnits,
		uapRate,
		uapSales,
		uapProfit,
		uapSupplemental,
		uapNotes
	FROM dbo.U_PER1027_AddlPayDetail (NOLOCK)
	WHERE uapRecID = @RecId
END

GO
