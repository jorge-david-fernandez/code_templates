SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER PROCEDURE dbo.U_PER1027_AdditionalPayDetail_Del
	@DeleteList VARCHAR(MAX)
AS
----------------------------------------------------------------------------------------------------------------------
-- Company:		  UKG 
-- Author:		  Jorge Fernandez
-- Client:		  Performance Food Group, Inc.
-- Date:		  11/4/2022
-- Request:		  SR-2022-00377312
-- Purpose:		  Custom Web Page for Additional Pay Detail
-- Last Modified: 
-----------------------------------------------------------------------------------------------------------------------
BEGIN
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	IF (LEN(@DeleteList) = 0) BEGIN
		RETURN
	END

	DECLARE @tblToDeleteIds TABLE (RecID INT)
	
	INSERT @tblToDeleteIds (RecID) 
	SELECT LTRIM(RTRIM(Item))
	FROM dbo.fn_ListToTable(@DeleteList)

	DELETE dbo.[U_PER1027_AddlPayDetail]
	WHERE uapRecID IN (SELECT RecID FROM @tblToDeleteIds)

END
GO