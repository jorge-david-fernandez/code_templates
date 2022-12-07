----------------------------------------------------------------------------------------------------------------------
-- Company:		  Ultimate Software Corp. 
-- Author:		  Adrian Serrano
-- Client:		  Lazy Dog Restaurants, LLC
-- Date:		  1/28/2020
-- Request:		  SR-2019-00245269
-- Purpose:		  Instant Pay Direct Deposit (from scope project SR-2019-00233967)
-- Last Modified: 
-----------------------------------------------------------------------------------------------------------------------

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
	@Alias        VARCHAR(250),
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
-- Convention for alias name is:  U_POST_YYY    POST=ClientCode   YYY=AliasName
-- Spanish and French translations are optional

-- R2 Resource File Conversion

-- Example Disclaimer Custom LocalString Inserts
-- CS-20XX-POSTXX - Title of Project Goes Here
 
-- SR-2016-00113489 - PTO Donation Web Custom
EXEC dbo.SetupLocalization 'L_LAZY_DebitCard', 'Debit Card'
EXEC dbo.SetupLocalization 'L_LAZY_TipCard', 'Tip Card'
EXEC dbo.SetupLocalization 'L_LAZY_Approved', 'Approved'
EXEC dbo.SetupLocalization 'L_LAZY_DateApproved', 'Date Approved'
EXEC dbo.SetupLocalization 'L_LAZY_EmpDebitTipConsentDetailHeader', 'Pay Consent Settings'
EXEC dbo.SetupLocalization 'L_LAZ1001_DateSigned', 'Date Signed'
EXEC dbo.SetupLocalization 'L_LAZ1001_MealWaiverConsent', 'Meal Waiver Consent'
EXEC dbo.SetupLocalization 'L_LAZ1001_MealWaiver1', 'Meal Waiver 1'
EXEC dbo.SetupLocalization 'L_LAZ1001_MealWaiver2', 'Meal Waiver 2'

GO

---------------------------------------------------------------
-- UTILITY Stored Procedure - CLEANUP
---------------------------------------------------------------

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SetupLocalization]') AND type in (N'P', N'PC'))
BEGIN
	DROP PROCEDURE dbo.SetupLocalization
END
GO
