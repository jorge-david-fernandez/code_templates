DROP PROCEDURE IF EXISTS [dbo].[U_PER1027_AdditionalPayDetail_Save]
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].U_PER1027_AdditionalPayDetail_Save
	@EmployeeEEID char(12) =  NULL,
	@EmployeeCOID char(5) = NULL,
	@AdminEEID char(12) = NULL,
	@RecID int = NULL,
	@PayDate datetime,
	@WeekEndDate datetime,
	@Desc varchar(50),
	@Hours varchar (20) = NULL,
	@Units varchar (20) = NULL,
	@Rate varchar (20) = NULL,
	@Sales varchar (20) = NULL,
	@Profit varchar (20) = NULL,
	@Supplemental varchar (20) = NULL,
	@Notes varchar (max) = NULL
AS
----------------------------------------------------------------------------------------------------------------------
-- Company:		  UKG 
-- Author:		  Jorge Fernandez
-- Client:		  Performance Food Group, Inc.
-- Date:		  10/31/2022
-- Request:		  SR-2022-00377312
-- Purpose:		  Custom Web Page for Additional Pay Detail
-- Last Modified: 
-----------------------------------------------------------------------------------------------------------------------
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET NOCOUNT ON

	DECLARE @UpdatedBy varchar(20) = 'Import'

	SELECT @UpdatedBy = UserName
	FROM vw_rbsUserCompany (NOLOCK)
	JOIN vw_rbsUser (NOLOCK) ON susUserID = sucUserID
	WHERE sucEEID = @AdminEEID

	IF @RecID IS NULL
	BEGIN
		INSERT dbo.U_PER1027_AddlPayDetail (
			uapEmpNo,
			uapPayDate,
			uapWeekEndDate,
			uapDesc,
			uapHours,
			uapUnits,
			uapRate,
			uapSales,
			uapProfit,
			uapSupplemental,
			uapNotes,
			uapUpdatedBy,
			uapFileName
		)
		SELECT eecEmpNo, @PayDate, @WeekEndDate, @Desc, @Hours, @Units, @Rate, @Sales, @Profit, @Supplemental, @Notes, @UpdatedBy, ''
		FROM EmpComp (NOLOCK)
		WHERE EecEEID = @EmployeeEEID
		AND EecCoID = @EmployeeCOID
			
	END
	ELSE
	BEGIN
		UPDATE dbo.U_PER1027_AddlPayDetail
		SET	uapPayDate = @PayDate,
			uapWeekEndDate = @WeekEndDate,
			uapDesc = @Desc,
			uapHours = @Hours,
			uapUnits = @Units,
			uapRate = @Rate,
			uapSales = @Sales,
			uapProfit = @Profit,
			uapSupplemental = @Supplemental,
			uapNotes = @Notes,
			uapDateTimeUpdated = GETDATE(),
			uapUpdatedBy = @UpdatedBy
		WHERE uapRecID = @RecID
	END
END
GO