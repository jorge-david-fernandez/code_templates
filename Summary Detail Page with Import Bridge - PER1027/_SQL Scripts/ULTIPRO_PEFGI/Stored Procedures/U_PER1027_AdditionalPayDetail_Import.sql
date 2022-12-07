DROP PROCEDURE IF EXISTS [dbo].[U_PER1027_AdditionalPayDetail_Import]
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].U_PER1027_AdditionalPayDetail_Import
	@EmployeeNumber varchar(50),
	@PayDate varchar(50),
	@WeekEndDate varchar(50),
	@Description varchar(50),
	@Hours varchar(50),
	@Units varchar(50),
	@Rate varchar(50),
	@Sales varchar(50),
	@Supplemental varchar(50),
	@Profit varchar(50),
	@Notes varchar(max),
	@Action varchar(50),
	@TransactionID varchar(50) = NULL
AS
BEGIN
----------------------------------------------------------------------------------------------------------------------
-- Company:		  UKG 
-- Author:		  Jorge Fernandez
-- Client:		  Performance Food Group, Inc.
-- Date:		  10/31/2022
-- Request:		  SR-2022-00377312
-- Purpose:		  Custom Web Page for Additional Pay Detail
-- Last Modified: 
-----------------------------------------------------------------------------------------------------------------------
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET NOCOUNT ON
	
	--Validations
	DECLARE @RecID int = NULL
	DECLARE @Errors table (Level int,ErrMessage varchar (255))
	--DECLARE @MssgLvl_Development INT = 0
	--DECLARE @MssgLvl_Information INT = 1
	--DECLARE	@MssgLvl_Warning INT = 2
	DECLARE	@MssgLvl_Error int = 3

	SELECT @EmployeeNumber = LTRIM(RTRIM(COALESCE(@EmployeeNumber, ''))),
			@PayDate  = LTRIM(RTRIM(COALESCE(@PayDate, ''))),
			@WeekEndDate  = LTRIM(RTRIM(COALESCE(@WeekEndDate, ''))),
			@Description  = LTRIM(RTRIM(COALESCE(@Description, ''))),
			@Hours  = LTRIM(RTRIM(COALESCE(@Hours, ''))),
			@Units  = LTRIM(RTRIM(COALESCE(@Units, ''))),
			@Rate  = LTRIM(RTRIM(COALESCE(@Rate, ''))),
			@Sales  = LTRIM(RTRIM(COALESCE(@Sales,''))),
			@Supplemental  = LTRIM(RTRIM(COALESCE(@Supplemental,''))),
			@Profit  = LTRIM(RTRIM(COALESCE(@Profit,''))),
			@Notes  = LTRIM(RTRIM(COALESCE(@Notes,''))),
			@Action  = LTRIM(RTRIM(COALESCE(@Action, '')))

	DECLARE @Pay DATE,
			@WeekEnd DATE

	IF @Action NOT IN ('A', 'D')
	BEGIN
		INSERT @Errors SELECT @MssgLvl_Error,'The Action indicator does not match a valid code value.'
		--RAISERROR ('The Action indicator does not match a valid code value.', 16, 1)
		--RETURN
		SELECT * FROM @Errors
		RETURN
	END

	DECLARE @Error varchar (500) = ''

	IF @EmployeeNumber = ''
	BEGIN
		INSERT @Errors SELECT @MssgLvl_Error, 'The Employee Number is a required field.'
		--SET @Error = @Error + ' The Employee Number is a required field.'
		SELECT * FROM @Errors
		RETURN
	END

	IF NOT EXISTS (SELECT 1 FROM dbo.EmpComp (NOLOCK) where EecEmpNo = @EmployeeNumber)
	BEGIN
		INSERT @Errors SELECT @MssgLvl_Error, 'The Employee Number does not correspond to a valid employee or is in an invalid format.'
		--SET @Error = @Error + ' The Employee Number does not correspond to a valid employee or is not in a valid format.'
		SELECT * FROM @Errors
		RETURN
	END

	IF @PayDate = ''
	BEGIN
		INSERT @Errors SELECT @MssgLvl_Error, 'The Pay Date is a required field.'
		SELECT * FROM @Errors
		RETURN
		--SET @Error = @Error + ' The Pay Date is a required field.'
	END

	--IF ISDATE(@PayDate) = 1
	--BEGIN
	--	INSERT @Errors SELECT @MssgLvl_Error, 'The Pay Date is not a valid date.'
	--	SELECT * FROM @Errors
	--	RETURN
	--	--SET @Error = @Error + ' The Pay Date is not a valid date.'
	--END

	BEGIN TRY
		SELECT @Pay =  CONVERT(DATE, SUBSTRING(@PayDate, 5, 4) + SUBSTRING(@PayDate, 1, 2) + SUBSTRING(@PayDate, 3, 2) , 101)
	END TRY
	BEGIN CATCH
		INSERT @Errors SELECT @MssgLvl_Error, 'The Pay Date is not a valid date.'
		SELECT * FROM @Errors
		RETURN
	END CATCH;

	IF @WeekEndDate = ''
	BEGIN
		INSERT @Errors SELECT @MssgLvl_Error, 'The Week End Date is a required field.'
		--SET @Error = @Error + ' The Week End Date is a required field.'
		SELECT * FROM @Errors
		RETURN
	END

	-- The Week End Date is a valid date
	--IF ISDATE(@WeekEndDate) = 1
	--BEGIN
	--	INSERT @Errors SELECT @MssgLvl_Error, 'The Week End Date is not a valid date.'
	--	--SET @Error = @Error + ' The Week End Date is not a valid date.'
	--	SELECT * FROM @Errors
	--	RETURN
	--END

	BEGIN TRY
		SELECT @WeekEnd = CONVERT(DATE, @WeekEndDate)
	END TRY
	BEGIN CATCH
		INSERT @Errors SELECT @MssgLvl_Error, 'The Week End Date is not a valid date.'
		SELECT * FROM @Errors
		RETURN
	END CATCH;

	IF @Description = ''
	BEGIN
		INSERT @Errors SELECT @MssgLvl_Error, 'The Description is a required field.'
		--SET @Error = @Error + ' The Description is a required field.'
		SELECT * FROM @Errors
		RETURN
	END
	
	IF @Hours = '' AND @Rate = '' AND @Units = '' AND @Profit = '' AND @Sales = '' AND @Supplemental = ''
	BEGIN
		INSERT @Errors SELECT @MssgLvl_Error, 'At least one of Hours, Rate, Units, Profit, Sales, Supplemental must be provided.'
		--SET @Error = @Error + ' At least one of Hours, Rate, Units, Profit, Sales, Supplemental must be provided.'
		SELECT * FROM @Errors
		RETURN
	END

	SELECT @RecID = uapRecID
		FROM dbo.U_PER1027_AddlPayDetail (NOLOCK)
		WHERE uapEmpNo = @EmployeeNumber
		AND uapPayDate = @Pay
		AND uapWeekEndDate = @WeekEnd
		AND uapDesc = @Description
		AND uapHours = @Hours
		AND uapUnits = @Units
		AND uapRate = @Rate
		AND uapSales = @Sales
		AND uapSupplemental = @Supplemental
		AND uapProfit = @Profit
		AND uapNotes = @Notes

	IF @Action IN ('D') AND @RecID IS NULL
	BEGIN
		INSERT @Errors SELECT @MssgLvl_Error,'Cannot find matching record for Employee Number, Pay Date, Week End Date, Hours, Units, Rate, Sales, Supplemental, Profit and Notes.'
		--RAISERROR ('Cannot find matching record for Employee Number, Pay Date, Week End Date, Hours, Units, Rate, Sales, Supplemental, Profit and Notes.', 16, 1)
		--RETURN
		SELECT * FROM @Errors
		RETURN
	END

	IF @Action = 'A' AND @RecID IS NOT NULL
	BEGIN
		INSERT @Errors SELECT @MssgLvl_Error,'This combination already exists. You must correct the relationship before you can continue.'
		--RAISERROR ('This combination already exists. You must correct the relationship before you can continue.', 16, 1)
		--RETURN
		SELECT * FROM @Errors
		RETURN
	END

	IF EXISTS (SELECT 1 FROM @Errors)-- @Error <> ''
	BEGIN
		SELECT * FROM @Errors
		--RAISERROR (@Error, 16, 1)
		RETURN
	END

	IF @Action IN ('A') 
	BEGIN	
		DECLARE @FileName VARCHAR(1000), @FileUploadDate DATE
		
		SELECT @FileName = Stag.Source, @FileUploadDate = CONVERT(DATE,Stag.DateCreated)
		FROM Bridge_SupplementalData Sup (NOLOCK)
		JOIN Bridge_StagingRecord Stag ON Sup.StagingId = Stag.StagingId
		WHERE Sup.DataName = 'TransactionID'
		AND Sup.DataValue = @TransactionID

		SELECT @FileName = [FileName]
		FROM (SELECT DISTINCT [FileName],[DateCreated] FROM Bridge_FileUpload (NOLOCK)) Brid
		WHERE @FileName LIKE REPLACE([FileName],'.csv','') + '%'
		AND CONVERT(DATE,[DateCreated]) = @FileUploadDate

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
		SELECT @EmployeeNumber,@Pay,@WeekEnd,@Description,@Hours,@Units,@Rate,@Sales,@Profit,@Supplemental,@Notes,'Import',@FileName
	END
	ELSE IF @Action = 'D'
	BEGIN
		DELETE dbo.U_PER1027_AddlPayDetail
		WHERE uapRecID = @RecID
	END

	SELECT * FROM @Errors
END	

GO
