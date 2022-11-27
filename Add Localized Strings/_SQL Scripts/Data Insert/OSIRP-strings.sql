
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

-- R2 Resource File Conversion
EXEC dbo.SetupLocalization 'Name','Custom Name'

-- CS-20XX-XXXXX - Title of Project Goes Here
--EXEC dbo.SetupLocalization 'U_ONEB_ExampleString', 'Example String'


GO

---------------------------------------------------------------
-- UTILITY Stored Procedure - CLEANUP
---------------------------------------------------------------

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SetupLocalization]') AND type in (N'P', N'PC'))
BEGIN
	DROP PROCEDURE dbo.SetupLocalization
END
GO
