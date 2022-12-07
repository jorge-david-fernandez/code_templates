
----------------------------------------------------------------------------------------------------------------------
-- Company:		  Ultimate Software Corp. 
-- Author:		  Adrian Serrano
-- Client:		  Lazy Dog Restaurants, LLC
-- Date:		  9/10/2019
-- Request:		  SR-2019-00245269
-- Purpose:		  Instant Pay Direct Deposit (from scope project SR-2019-00233967)
-- Last Modified: 
-----------------------------------------------------------------------------------------------------------------------


IF OBJECT_ID(N'[dbo].[U_LAZY_SavePendHireSupplData]' ) IS NOT NULL  
DROP PROCEDURE [dbo].[U_LAZY_SavePendHireSupplData] 

GO

SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE PROCEDURE dbo.U_LAZY_SavePendHireSupplData (
	@PENDHITEID VARCHAR(255),
	@EEID CHAR(12),
	@COID CHAR(5)
) AS

	DECLARE @SupplData XML
	DECLARE @UDField01 CHAR(10)
	DECLARE @UDField11 CHAR(10)
	DECLARE @UDField12 CHAR(10)
	DECLARE @UDField14 VARCHAR(25)
	DECLARE @UDField15 VARCHAR(25)
	DECLARE @UDField21 CHAR(1)
	DECLARE @UDField22 CHAR(1)

	SELECT TOP(1) @SupplData = phSupplDataXML
	FROM PendHire
	WHERE phPendingSessionID = @PENDHITEID
	
	SET @UDField01 =  @SupplData.value('(/Supplemental/UserDefinedFieldsInfo/UdfInfo[FieldName = ''EECUDFIELD01'']/Value/text())[1]', 'CHAR(10)')
	SET @UDField11 =  @SupplData.value('(/Supplemental/UserDefinedFieldsInfo/UdfInfo[FieldName = ''EECUDFIELD11'']/Value/text())[1]', 'CHAR(10)')
	SET @UDField12 =  @SupplData.value('(/Supplemental/UserDefinedFieldsInfo/UdfInfo[FieldName = ''EECUDFIELD12'']/Value/text())[1]', 'CHAR(10)')
	SET @UDField14 =  @SupplData.value('(/Supplemental/UserDefinedFieldsInfo/UdfInfo[FieldName = ''EECUDFIELD14'']/Value/text())[1]', 'VARCHAR(25)')
	SET @UDField15 =  @SupplData.value('(/Supplemental/UserDefinedFieldsInfo/UdfInfo[FieldName = ''EECUDFIELD15'']/Value/text())[1]', 'VARCHAR(25)')
	SET @UDField21 =  @SupplData.value('(/Supplemental/UserDefinedFieldsInfo/UdfInfo[FieldName = ''DC Consent WAGE'']/Value/text())[1]', 'CHAR(1)')
	SET @UDField22 =  @SupplData.value('(/Supplemental/UserDefinedFieldsInfo/UdfInfo[FieldName = ''DC Consent TIPS'']/Value/text())[1]', 'CHAR(1)')

	UPDATE EmpComp
	SET EecUdField01 = @UDField01
		,EecUdField11 = @UDField11
		,EecUdField12 = @UDField12
		,EecUdField14 = @UDField14
		,EecUdField15 = @UDField15
		,EecUdField21 = @UDField21
		,EecUdField22 = @UDField22
	WHERE EecEEID = @EEID AND EecCoID = @COID
GO