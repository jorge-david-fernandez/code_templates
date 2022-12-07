-------------------------------------------------------------------------------------------
-- Template/Example Script to Insert Local Strings
--
-- Inserts alias strings in the LocalStrings table on client company database.
-------------------------------------------------------------------------------------------

---------------------------------------------------------------
-- UTILITY Stored Procedure - CREATE
---------------------------------------------------------------

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SetupLocalization]') AND type in (N'P', N'PC'))
BEGIN
	DROP PROCEDURE dbo.SetupLocalization
END
GO

CREATE PROCEDURE dbo.SetupLocalization
	@Alias        VARCHAR(50),
	@EnglishText  VARCHAR(1000),
	@SpanishText VARCHAR(1000) = NULL,
	@FrenchText VARCHAR(1000) = NULL
AS
BEGIN
	SET NOCOUNT ON

	BEGIN TRAN

	PRINT char(10) + 'Adding ' + @Alias

	-- Clean up
	DELETE FROM LocalStrings WHERE StringID = @Alias

	-- English
	INSERT INTO LocalStrings (StringID, TextString, LanguageCode, IncludeInJS, Severity, DateTimeChanged)
	VALUES (@Alias, @EnglishText, 'en', 'N', '', GetDate())

	-- Spanish
	INSERT INTO LocalStrings (StringID, TextString, LanguageCode, IncludeInJS, Severity, DateTimeChanged)
	VALUES (@Alias, ISNULL(@SpanishText, '(es) ' + @EnglishText), 'es', 'N', '', GetDate())

	-- French
	INSERT INTO LocalStrings (StringID, TextString, LanguageCode, IncludeInJS, Severity, DateTimeChanged)
	VALUES (@Alias, ISNULL(@FrenchText, '(fr) ' + @EnglishText), 'fr', 'N', '', GetDate())

	COMMIT TRAN
END
GO

---------------------------------------------------------------
-- SCRIPT - ADD STRINGS
---------------------------------------------------------------

-- Use the above SP to setup strings
-- Convention for alias name is:  U_XXX_YYY    XXX=ClientCode   YYY=AliasName
-- Spanish and French translations are optional

--select * from LocalStrings

-- BEGIN SR-2022-00363993 - Web administrator page for GL custom table for mapping for Org Levels
EXEC dbo.SetupLocalization 'U_GLTransl_FSOLTrans_Header', 'Financial System Org Level Translations'
EXEC dbo.SetupLocalization 'U_GLTransl_FSOLTransDetails_Header', 'Add/Change Financial System Org Level Translations'
EXEC dbo.SetupLocalization 'U_GLTransl_UKGValue', 'UKG Value'
EXEC dbo.SetupLocalization 'U_GLTransl_OPCO', 'OPCO'
EXEC dbo.SetupLocalization 'U_GLTransl_OPCODesc', 'OPCO Description'
EXEC dbo.SetupLocalization 'U_GLTransl_TranslatesTo', 'Translates To'
EXEC dbo.SetupLocalization 'U_GLTransl_Ref1', 'Ref 1'
EXEC dbo.SetupLocalization 'U_GLTransl_Ref2', 'Ref 2'
EXEC dbo.SetupLocalization 'U_GLTransl_Status', 'Status'
EXEC dbo.SetupLocalization 'U_GLTransl_FinSystem', 'Financial System'
EXEC dbo.SetupLocalization 'U_GLTransl_OrgLevel', 'Org Level'
EXEC dbo.SetupLocalization 'U_GLTransl_SummaryInfoMsg', 'Select the Financial System and Org Level (i.e. OPCO or Department) that you want to view.  Once both are selected, the related data will display.  If you want to add a new translation, you also need to select the Financial System and Org Level you want to add the translation for.'
EXEC dbo.SetupLocalization 'U_GLTransl_Err_RecExists', 'This combination already exists.  You must correct the relationship before you can continue.'

EXEC dbo.SetupLocalization 'U_AddlPay_AdditionalPaySummaryHeader', 'Additional Pay Detail'
EXEC dbo.SetupLocalization 'U_AddlPay_AddChangeitionalPayHeader', 'Add/Change Additional Pay Detail'
EXEC dbo.SetupLocalization 'U_AddlPay_PayDate', 'Pay Date'
EXEC dbo.SetupLocalization 'U_AddlPay_WeekEndDate', 'Week End Date'
EXEC dbo.SetupLocalization 'U_AddlPay_Description', 'Description'
EXEC dbo.SetupLocalization 'U_AddlPay_Hours', 'Hours'
EXEC dbo.SetupLocalization 'U_AddlPay_Units', 'Units'
EXEC dbo.SetupLocalization 'U_AddlPay_Rate', 'Rate'
EXEC dbo.SetupLocalization 'U_AddlPay_Sales', 'Sales'
EXEC dbo.SetupLocalization 'U_AddlPay_Profit', 'Profit'
EXEC dbo.SetupLocalization 'U_AddlPay_Supplemental', 'Supplemental'
EXEC dbo.SetupLocalization 'U_AddlPay_Notes', 'Notes'

-- END SR-2022-00363993 - Web administrator page for GL custom table for mapping for Org Levels

GO

---------------------------------------------------------------
-- UTILITY Stored Procedure - CLEANUP
---------------------------------------------------------------

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SetupLocalization]') AND type in (N'P', N'PC'))
BEGIN
	DROP PROCEDURE dbo.SetupLocalization
END
GO
