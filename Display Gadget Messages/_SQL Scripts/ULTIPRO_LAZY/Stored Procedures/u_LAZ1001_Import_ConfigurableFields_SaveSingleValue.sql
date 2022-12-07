----------------------------------------------------------------------------------------------------------------------
-- Company:		  UKG 
-- Author:		  David Domenico
-- Client:		  Lazy Dog Restaurants, LLC
-- Date:		  11/9/2021
-- Request:		  SR-2021-00335777
-- Purpose:		  Modify Direct Deposit Custom to Remap UD fields
-- Last Modified: 
-----------------------------------------------------------------------------------------------------------------------

IF EXISTS (SELECT 1 FROM SysObjects WHERE id = Object_ID('dbo.u_LAZ1001_Import_ConfigurableFields_SaveSingleValue') AND ObjectProperty(id,'IsProcedure')=1)
BEGIN
	DROP PROCEDURE dbo.u_LAZ1001_Import_ConfigurableFields_SaveSingleValue
END
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE dbo.u_LAZ1001_Import_ConfigurableFields_SaveSingleValue (
	@EEID       CHAR(12)     ,
	@COID       CHAR(5)      ,
	@ClassName  VARCHAR(50)  ,		-- 'Employee' or 'Employment'
	@FieldName  VARCHAR(200) ,
	@FieldValue NVARCHAR(4000),
	@DataType   VARCHAR(20)  ,
	@UltiproUserID INT
) AS
BEGIN
	---------------------------------------------------------------------
	-- Original version from Dan Welborn.
	-- This procedure saves a value to a configurable field for an employee.
	--
	-- Modification History:
	-- 08/20/14 - DCW - SR-2014-00047224 - Initial version
	-- 10/25/14 - DCW - SR-2014-00050114 - For conversion of automated import to global, add handling for '_F' fields (core global pay fields), and for 'DATE' AND 'DECIMAL' datatypes.
	-- 01/09/15 - DCW - SR-2014-00050114 - When the value to save is an empty string, don't save at all, when coming from newhire/jobchange (i.e. jobhistorysystemid passed in). Original import didn't update UDFields when import value was blank, and new import wasn't supposed to either. Real fix should be up in plugin for today, quickfix here to not save.  JobChange imports are resulting in fields getting blanked out that shouldn't.
	-- 01/13/15 - DCW - SR-2014-00050114 - Undo prior change, had a flaw.  Caller will choose not to call if value sent in JobChange is blank. Also, remove support for EmploymentHistory/JobHistory, now handled by calling core sprocs from plugin.
	-- 06/03/21 - BSS - SR-2021-00310794 - Adding Person ClassName
	---------------------------------------------------------------------
	
	SET NOCOUNT ON
	
	DECLARE
		@ReturnErrorMsg  VARCHAR(400),
		@ObjectID        INT,
		@FieldUniqueID   VARCHAR(200),
		@PriorValue      NVARCHAR(MAX),
		@DateValue       DATETIME,
		@DecimalValue    DECIMAL(18,6),
		@PriorDecimalValue DECIMAL(18,6),
		@DoTheWrite      CHAR(1),
		@CurrentDateTime DATETIME,
		@CurrentDate     DATETIME,
		@PersonID		 UNIQUEIDENTIFIER
	
	SET @ReturnErrorMsg = ''
	SET @CurrentDateTime = GetDate()
	SET @CurrentDate = CONVERT(DATETIME,CONVERT(VARCHAR(10),@CurrentDateTime,121))
	
	-- Validate Ultipro User ID
	
	-- No, do not perform this validation, because this query is taking up to 2 seconds (on client's TEST)
	/*
	IF NOT EXISTS (SELECT 1 FROM dbo.vw_RbsUsers (NoLock) WHERE susUserID = @UltiproUserID) BEGIN
		SET @ReturnErrorMsg = 'Ultipro UserID [' + CONVERT(VARCHAR(50),@UltiproUserID + '] does not exist'
		SELECT @ReturnErrorMsg as ReturnErrorMsg
		RETURN
	END
	*/
	
	-- Validate ClassName
	
	IF (@ClassName = 'Employee') SET @ClassName = 'SEmployee'
	IF (@Classname = 'Employment') SET @ClassName = 'SEmployment'
	IF (@Classname = 'Person') SET @ClassName = 'SPerson'
	
	IF (@ClassName = 'SEMPLOYEE') SET @ClassName = 'SEmployee'		-- to ensure proper casing
	IF (@ClassName = 'SEMPLOYMENT') SET @ClassName = 'SEmployment'	-- to ensure proper casing
	IF (@ClassName = 'SPERSON') SET @ClassName = 'SPerson' -- to ensure proper casing

	IF (@ClassName NOT IN ('SEmployee','SEmployment','SPerson')) BEGIN
		SET @ReturnErrorMsg = 'Invalid Classname parameter value [' + @ClassName + ']'
		SELECT @ReturnErrorMsg as ReturnErrorMsg
		RETURN
	END
	
	--  Validate required input exists
	
	IF (ISNULL(@EEID,'') = '') OR (@ClassName = 'SEmployment' AND (ISNULL(@COID,'') = '')) BEGIN
		SET @ReturnErrorMsg = 'EEID and/or COID parameter values cannot be null or empty'
		SELECT @ReturnErrorMsg as ReturnErrorMsg
		RETURN
	END
	
	IF (ISNULL(@FieldName,'') = '') BEGIN
		SET @ReturnErrorMsg = 'FieldName parameter value cannot be null or empty'
		SELECT @ReturnErrorMsg as ReturnErrorMsg
		RETURN
	END
	
	-- Validate DataType
	
	IF (@DataType = 'TEXT') SET @DataType = 'STRING'
	IF (@DataType = 'VARCHAR') SET @DataType = 'STRING'
	IF (@DataType = 'CHAR') SET @DataType = 'STRING'
	
	IF (@DataType = 'BOOL') SET @DataType = 'BOOLEAN'
	IF (@DataType = 'BIT') SET @DataType = 'BOOLEAN'
	
	IF (@DataType = 'DATETIME') SET @DataType = 'DATE'
	
	IF (@DataType = 'NUMERIC') SET @DataType = 'DECIMAL'

	IF (@DataType NOT IN ('BOOLEAN','STRING','DATE','DECIMAL')) BEGIN
		SET @ReturnErrorMsg = 'Invalid DataType parameter value [' + @DataType + ']'
		SELECT @ReturnErrorMsg as ReturnErrorMsg
		RETURN
	END
	
	-- Validate Values per Datatype
	
	IF (@DataType = 'BOOLEAN') BEGIN
		
		IF (ISNULL(@FieldValue,'') = '') SET @FieldValue = 'N'
		IF (@FieldValue = '0') SET @FieldValue = 'N'
		IF (@FieldValue = 'False') SET @FieldValue = 'N'
		IF (@FieldValue = '1') SET @FieldValue = 'Y'
		IF (@FieldValue = 'True') SET @FieldValue = 'Y'
		
		IF (@FieldValue NOT IN ('Y','N')) BEGIN
			SET @ReturnErrorMsg = 'Invalid Boolean value [' + @FieldValue + '] passed in for field [' + @FieldName + ']'
			SELECT @ReturnErrorMsg as ReturnErrorMsg
			RETURN
		END
		
	END
	
	IF (@DataType = 'DATE') BEGIN
	
		IF (ISNULL(@FieldValue,'') = '') BEGIN
			SET @DateValue = NULL
			SET @FieldValue = ''
		END
		
		IF (@FieldValue != '') BEGIN
		
			BEGIN TRY
				SET @DateValue = CONVERT(DATETIME,@FieldValue)
				SET @FieldValue = CONVERT(VARCHAR(50),@DateValue,121)		-- Format 121 is YYYY-MM-DD HH:MM:SS.mmm
			END TRY
			BEGIN CATCH
				SET @ReturnErrorMsg = 'Invalid Date value [' + @FieldValue + '] passed in for field [' + @FieldName + ']'
			END CATCH
			
			IF (@ReturnErrorMsg != '') BEGIN
				SELECT @ReturnErrorMsg as ReturnErrorMsg
				RETURN
			END
			
		END
	
	END
	
	IF (@DataType = 'DECIMAL') BEGIN
	
		IF (ISNULL(@FieldValue,'') = '') BEGIN
			SET @DecimalValue = NULL
			SET @FieldValue = ''
		END
		
		IF (@FieldValue != '') BEGIN
		
			BEGIN TRY
				SET @DecimalValue = CONVERT(DECIMAL(16,6),@FieldValue)
			END TRY
			BEGIN CATCH
				SET @ReturnErrorMsg = 'Invalid Decimal value [' + ISNULL(@FieldValue,'NULL') + ' passed in for field [' + @FieldName + ']'
			END CATCH
			
			IF (@ReturnErrorMsg != '') BEGIN
				SELECT @ReturnErrorMsg as ReturnErrorMsg
				RETURN
			END
			
		END
	
	END
	
	-- Set FieldUniqueID
	
	-- Configurable Fields unique field names are in the format '_BFieldName' (or also '_FFieldName' - ones starting with _F are core global pay fields).
	-- So, if user created a field called "Expense User", the unique name would have been saved as '_BExpenseUser'
	-- Caller can pass in the name without the '_B' to it's more readable, but here we prepend the '_B'
	-- The like-mask of '[_]B%' means "Starts with underscore (literally) followed by B, then whatever else',
	-- because the understand by itself is a wildcard for a letter, you have to use the square brackets to "escape" it.
	
	IF (@FieldName LIKE '[_]B%') OR (@FieldName LIKE '[_]F%') BEGIN
		SET @FieldUniqueID = @FieldName
	END ELSE BEGIN
		SET @FieldUniqueID = '_B' + @FieldName
	END
	
	-- Get or Create MetaObject header record for this class for this employee
	
	IF (@ClassName = 'SEmployee') BEGIN
		SELECT @ObjectID = ID 
		  FROM dbo.MetaObject (NoLock) 
		 WHERE ClassUniqueId = @ClassName
		   AND StandardPrimaryKeyString1 = @EEID
	END
	
	IF (@ClassName = 'SEmployment') BEGIN
		SELECT @ObjectID = ID 
		  FROM dbo.MetaObject (NoLock) 
		 WHERE ClassUniqueId = @ClassName
		   AND StandardPrimaryKeyString1 = @EEID
		   AND StandardPrimaryKeyString2 = @COID
	END

	IF (@ClassName = 'SPerson') BEGIN
		SET @PersonID = (SELECT eepPersonID FROM EmpPers WHERE eepEEID = @EEID)

		SELECT @ObjectID = ID 
		  FROM dbo.MetaObject (NoLock) 
		 WHERE ClassUniqueId = @ClassName
		   AND StandardPrimaryKeyGuid1 = @PersonID	  
	END
	
	IF (@ObjectID IS NULL) BEGIN
	
		-- Create it.
		-- Note: Caller may use transactions, so we won't use transactions in here.
		INSERT dbo.MetaObject (
			ClassUniqueId,
			Created,
			StandardPrimaryKeyString1,
			StandardPrimaryKeyGuid1,
			StandardPrimaryKeyString2
		) VALUES (
			@ClassName,
			@CurrentDateTime,
			CASE WHEN (@ClassName IN ('SEmployee', 'SEmployment')) THEN @EEID ELSE NULL END,
			CASE WHEN (@ClassName = 'SPerson') THEN @PersonID ELSE NULL END,
			CASE WHEN (@ClassName = 'SEmployment') THEN @COID ELSE NULL END
		)
		
		SET @ObjectID = Scope_Identity()
		
	END
	
	-- Get the prior value for this field
	
	IF (@DataType = 'BOOLEAN') BEGIN
		SELECT TOP 1 @PriorValue = CASE WHEN (ISNULL(BooleanValue,0) = 0) THEN 'N' ELSE 'Y' END
		FROM dbo.MetaFieldValue (NoLock)
		WHERE ObjectID = @ObjectID
		  AND FieldUniqueID = @FieldUniqueID
		ORDER BY Created DESC
	END
	
	IF (@DataType = 'STRING') BEGIN 
		SELECT TOP 1 @PriorValue = ISNULL(StringValue,'')
		FROM dbo.MetaFieldValue (NoLock)
		WHERE ObjectID = @ObjectID
		  AND FieldUniqueID = @FieldUniqueID
		ORDER BY Created DESC
	END
	
	IF (@DataType = 'DATE') BEGIN 
		SELECT TOP 1 @PriorValue = ISNULL(CONVERT(VARCHAR(50),DateTimeValue,121),'NULL')
		FROM dbo.MetaFieldValue (NoLock)
		WHERE ObjectID = @ObjectID
		  AND FieldUniqueID = @FieldUniqueID
		ORDER BY Created DESC
	END

	IF (@DataType = 'DECIMAL') BEGIN 
		SELECT TOP 1 @PriorDecimalValue = NumericValue
		FROM dbo.MetaFieldValue (NoLock)
		WHERE ObjectID = @ObjectID
		  AND FieldUniqueID = @FieldUniqueID
		ORDER BY Created DESC
	END
	
	-- Decide if we will be writing new value.
	-- We don't write new value if we don't need to, if it didn't change.
	
	SET @DoTheWrite = 'N'
	
	IF (@DataType != 'DECIMAL') BEGIN
	
		IF (@PriorValue IS NULL) AND (@FieldValue <> '') BEGIN
			SET @DoTheWrite = 'Y'
		END
		
		IF (@PriorValue IS NOT NULL) AND (@PriorValue != @FieldValue) BEGIN
			SET @DoTheWrite = 'Y'
		END
		
	END ELSE BEGIN
	
		-- Note: Couldn't do the compares of string-conversions of prior value and new value,
		-- because precision differences that weren't real differences were causing it to write the same value over and over,
		-- that is 2.00 and 2.0000 are equivalent, but don't necessarily compare the same when converted to text.
		
		IF (@PriorDecimalValue IS NULL) AND (@DecimalValue IS NOT NULL) BEGIN
			SET @DoTheWrite = 'Y'
		END
		
		IF (@PriorDecimalValue IS NOT NULL) AND (@DecimalValue IS NULL OR @PriorDecimalValue != @DecimalValue) BEGIN
			SET @DoTheWrite = 'Y'
		END
		
	END
	
	-- Write the new value
	
	IF (@DoTheWrite = 'Y') AND (@DataType = 'BOOLEAN') BEGIN
	
		INSERT dbo.MetaFieldValue (
			ObjectID,
			FieldUniqueID,
			Effective,
			Created,
			CreatedBy,
			BooleanValue
		) VALUES (
			@ObjectID,
			@FieldUniqueID,
			@CurrentDate,
			@CurrentDateTime,
			@UltiproUserID,
			CASE WHEN (@FieldValue = 'Y') THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END
		)
		
	END
	
	IF (@DoTheWrite = 'Y') AND (@DataType = 'STRING') BEGIN
	
		INSERT dbo.MetaFieldValue (
			ObjectID,
			FieldUniqueID,
			Effective,
			Created,
			CreatedBy,
			StringValue
		) VALUES (
			@ObjectID,
			@FieldUniqueID,
			@CurrentDate,
			@CurrentDateTime,
			@UltiproUserID,
			@FieldValue
		)
		
	END
	
	IF (@DoTheWrite = 'Y') AND (@DataType = 'DATE') BEGIN
	
		INSERT dbo.MetaFieldValue (
			ObjectID,
			FieldUniqueID,
			Effective,
			Created,
			CreatedBy,
			DateTimeValue
		) VALUES (
			@ObjectID,
			@FieldUniqueID,
			@CurrentDate,
			@CurrentDateTime,
			@UltiproUserID,
			@DateValue
		)
		
	END
	
	IF (@DoTheWrite = 'Y') AND (@DataType = 'DECIMAL') BEGIN
	
		INSERT dbo.MetaFieldValue (
			ObjectID,
			FieldUniqueID,
			Effective,
			Created,
			CreatedBy,
			NumericValue
		) VALUES (
			@ObjectID,
			@FieldUniqueID,
			@CurrentDate,
			@CurrentDateTime,
			@UltiproUserID,
			@DecimalValue
		)
		
	END
	
	-- Return success to caller (@ReturnErrorMsg should be an empty string at this point if we got to here)
	SELECT @ReturnErrorMsg AS ReturnErrorMsg

END
GO
