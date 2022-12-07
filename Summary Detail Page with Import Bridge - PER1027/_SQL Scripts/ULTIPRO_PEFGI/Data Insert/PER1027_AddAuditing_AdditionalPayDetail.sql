/*
This script adds the specified custom table to Ultipro's Audit Configuration, as well as turning on the table and all columns in it, for Auditing.
The first part is a long utility procedure.  
The actual script is near the bottom (search on the phrase "THE SCRIPT").  
Comments down there explain how to use.

Modification History:
pre-02/15/15    Various     Original version, which was a copy of a script some teams in Core used to add a core table to Audit system in Ultipro.
02/15/15        DanW        Reworked script to not use Dynamic SQL, making it more readable, and do a lot of validations to prevent bad audit setups, and provide comments/explanations on how to use.
04/05/16        DanW        Adapt script for 12.1.1 release, because core is removing column "IdxIsCheckConstraint" from table "IndxDict" on database "Ultipro_DataDict".
04/27/16        DanW        Rewrote so it only uses AuditSetupCustom and AuditConfig on Company DB. Turns out that's all that's needed.  Doesn't need to to add to DataDict at all. Allows longer tablenames/columnnames.
06/06/16        DanW        No functional change, just tidying up the comments to be more accurate. Tablenames and ColumnNames can bee 100 chars long.  IndexNames no longer matter.
12/28/17        DanW        Add TRY-TRANSACTION-CATCH wrapper with Retry logic, to lessen possibility of interference/errors due to core audit process kicking in while this script is in progress.
*/

-------------------------------------------------
-- UTILITY PROCEDURE
-------------------------------------------------

IF EXISTS (SELECT 1 FROM SysObjects WHERE id = Object_ID('dbo.U_WebCustoms_AddAuditingToTable') AND ObjectProperty(id,'IsProcedure')=1)
BEGIN
	DROP PROCEDURE dbo.U_WebCustoms_AddAuditingToTable
END
GO

IF EXISTS (SELECT 1 FROM SysObjects WHERE id = Object_ID('dbo.U_WebCustoms_AddAuditingToTable_Internal') AND ObjectProperty(id,'IsProcedure')=1)
BEGIN
	DROP PROCEDURE dbo.U_WebCustoms_AddAuditingToTable_Internal
END
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE dbo.U_WebCustoms_AddAuditingToTable_Internal (
	@TableName          VARCHAR(101),       -- Tablename can be up to 100 chars long now.
	@ColumnToUseForKey1 VARCHAR(101),       -- Required. What will be used for AdrKey1 value? If table is for an EEID, specify the EEID column here.  Otherwise, put some value that helps uniquely identify a record .
	@ColumnToUseForKey2 VARCHAR(101) = '',  -- If table is for an EEID and COID, specify the COID column here
	@ColumnToUseForKey3 VARCHAR(101) = '',  -- If table is for an EEID and COID, but record has a timed-key SystemID column specify it here.
	@DropBeforeAdd      CHAR(1) = 'N',      -- If checking into "Data Insert", which means it runs each upgrade, recommend that this be set to "N".
	@TurnItOn           CHAR(1) = 'Y',      -- This script makes the table audit-able, and actually configures it to be audited. That's what we/customs usually do. But pass TurnItOn="N" if you want to leave it up to the client to turn on the auditing for the table.
	@OverrideEEIDCheck  CHAR(1) = 'N',      -- If 'N', and there is a column named "xxxEEID", script will require that it be specified as Key1. Usually we want that, but allow for cases where we don't.
	@DropOnly           CHAR(1) = 'N'       -- If all you want to do is remove the Audit configuration, pass 'Y' here.
) AS
BEGIN

	SET NOCOUNT ON

	DECLARE 
		@ErrorMessage      VARCHAR(500),
		@TriggerDEL        VARCHAR(200), 
		@TriggerINS        VARCHAR(200), 
		@TriggerMOD        VARCHAR(200), 
		@DisableTriggerSQL VARCHAR(500),
		@GhostTableName    VARCHAR(500),
		@DropGhostSQL      VARCHAR(500),
		@ColEEID           VARCHAR(500),
		@ColCOID           VARCHAR(500),
		@ColIdentity       VARCHAR(500),
		@ColumnNameTooLong VARCHAR(500),
		@AllAuditingIsDisabled CHAR(1),
		@AdrKey1IsNullable BIT
	
	PRINT ''
	PRINT 'Starting Audit Configuration for table [' + @TableName + ']'
	
	SET @ErrorMessage = ''
	
	-- VALIDATIONS
	
	SET @TableName = RTRIM(ISNULL(@TableName,''))
	SET @ColumnToUseForKey1 = RTRIM(ISNULL(@ColumnToUseForKey1,''))
	SET @ColumnToUseForKey2 = RTRIM(ISNULL(@ColumnToUseForKey2,''))
	SET @ColumnToUseForKey3 = RTRIM(ISNULL(@ColumnToUseForKey3,''))
	SET @TurnItOn = RTRIM(ISNULL(@TurnItOn,'Y'))
	
	IF (ISNULL(@TurnItOn,'') NOT IN ('Y','N'))
	BEGIN
		SET @ErrorMessage = 'Unrecognized value [' + ISNULL(@TurnItOn,'null') + '] for the @TurnItOn parameter. Must by Y or N.'
		RAISERROR(@ErrorMessage,16,1)
		RETURN
	END
	
	IF (ISNULL(@DropBeforeAdd,'') NOT IN ('Y','N'))
	BEGIN
		SET @ErrorMessage = 'Unrecognized value [' + ISNULL(@DropBeforeAdd,'null') + '] for the @DropBeforeAdd parameter. Must by Y or N.'
		RAISERROR(@ErrorMessage,16,1)
		RETURN
	END

	IF (ISNULL(@OverrideEEIDCheck,'') NOT IN ('Y','N'))
	BEGIN
		SET @ErrorMessage = 'Unrecognized value [' + ISNULL(@OverrideEEIDCheck,'null') + '] for the @OverrideEEIDCheck parameter. Must by Y or N.'
		RAISERROR(@ErrorMessage,16,1)
		RETURN
	END

	IF (ISNULL(@DropOnly,'') NOT IN ('Y','N'))
	BEGIN
		SET @ErrorMessage = 'Unrecognized value [' + ISNULL(@DropOnly,'null') + '] for the @DropOnly parameter. Must by Y or N.'
		RAISERROR(@ErrorMessage,16,1)
		RETURN
	END

	-- Test for lengths

	IF (LEN(@TableName) > 100)
	BEGIN
		SET @ErrorMessage = 'Error in Audit Configuration for table [' + @TableName + ']: Tablename is too to be used in Auditing. It can only be 100 characters.'
		RAISERROR(@ErrorMessage,16,1)
		RETURN
	END
	
	IF (LEN(@ColumnToUseForKey1) > 100)
	BEGIN
		SET @ErrorMessage = 'Error in Audit Configuration for table [' + @TableName + ']: ColumnToUseForKey1 is too to be used in Auditing. The column name can only be 100 characters long.'
		RAISERROR(@ErrorMessage,16,1)
		RETURN
	END
	
	IF (LEN(@ColumnToUseForKey2) > 100)
	BEGIN
		SET @ErrorMessage = 'Error in Audit Configuration for table [' + @TableName + ']: ColumnToUseForKey2 is too to be used in Auditing. The column name can only be 100 characters long.'
		RAISERROR(@ErrorMessage,16,1)
		RETURN
	END
	
	IF (LEN(@ColumnToUseForKey3) > 100)
	BEGIN
		SET @ErrorMessage = 'Error in Audit Configuration for table [' + @TableName + ']: ColumnToUseForKey3 is too to be used in Auditing. The column name can only be 100 characters long.'
		RAISERROR(@ErrorMessage,16,1)
		RETURN
	END
	
	-- Does table exist
	
	IF (@TableName = '')
	BEGIN
		SET @ErrorMessage = 'TableName parameter is required, and cannot be blank'
		RAISERROR(@ErrorMessage,16,1)
		RETURN
	END
	
	IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = @TableName)
	BEGIN
		SET @ErrorMessage = 'Error in Audit Configuration for table [' + @TableName + ']: Table Name: ' + @TableName + ' - Does Not Exist In Database: ' + DB_NAME()
		RAISERROR(@ErrorMessage,16,1)
		RETURN
	END
	
	IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = @TableName AND [type] = 'U')		-- Type U means "User Table".
	BEGIN
		SET @ErrorMessage = 'Error in Audit Configuration for table [' + @TableName + ']: Table Name: ' + @TableName + ' - Does Not Exist In Database: ' + DB_NAME()
		RAISERROR(@ErrorMessage,16,1)
		RETURN
	END
	
	DECLARE @TableSchemaOwner VARCHAR(200)
	
	SELECT @TableSchemaOwner = table_schema FROM INFORMATION_SCHEMA.TABLES tbl (NoLock) WHERE tbl.table_name = @TableName
	
	IF (ISNULL(@TableSchemaOwner,'') != 'dbo')
	BEGIN
		SET @ErrorMessage = 'Error in Audit Configuration for table [' + @TableName + ']: Table must in the ''dbo'' schema namespace.'
		RAISERROR(@ErrorMessage,16,1)
		RETURN
	END
	
	-- Validate the AdrKey1 through AdrKey3
	
	IF (@DropOnly = 'N')
	BEGIN
	
		IF (@ColumnToUseForKey1 = '')
		BEGIN
			SET @ErrorMessage = 'Error in Audit Configuration for table [' + @TableName + ']: ColumnToUseForKey1 must be specified'
			RAISERROR(@ErrorMessage,16,1)
			RETURN
		END
		ELSE
		BEGIN
			IF (@ColumnToUseForKey2 = '') AND (@ColumnToUseForKey3 != '')
			BEGIN
				SET @ErrorMessage = 'Error in Audit Configuration for table [' + @TableName + ']: Please specify the ColumnToUseForKeys in order. Key3 is specified while Key2 is not.'
				RAISERROR(@ErrorMessage,16,1)
				RETURN
			END
		END
		
		SELECT @ColEEID = col.NAME
		FROM SysObjects tbl (NoLock)
		JOIN SysColumns col (NoLock) ON col.id = tbl.id
		WHERE tbl.id = Object_ID('dbo.' + @TableName)
		  AND tbl.xtype = 'U'
		  AND (col.Name = 'EEID' OR col.Name LIKE '___EEID')	-- '___EEID' means "has exactly three characters, then 'EEID' ".  This accounts for our typical column name prefixes.
		
		SELECT @ColCOID = col.NAME
		FROM SysObjects tbl (NoLock)
		JOIN SysColumns col (NoLock) ON col.id = tbl.id
		WHERE tbl.id = Object_ID('dbo.' + @TableName)
		  AND tbl.xtype = 'U'
		  AND (col.Name = 'COID' OR col.Name LIKE '___COID')
		
		-- If an EEID column exists, it is strongly recommended it be set as Key1, so that Audit data automatically shows up for the employee under the Audit tab in the employee window in the web application.
		-- However, there might be times we don't want the data to show up there. In those cases, explicitly pass in parameter @OverrideEEIDCheck as 'Y'.
		
		IF (@ColEEID IS NOT NULL) AND (ISNULL(@OverrideEEIDCheck,'N') != 'Y')
		BEGIN
			IF (@ColumnToUseForKey1 != @ColEEID)
			BEGIN
				-- Used to think that EEID column had to be prefixed by three chars, but not true... if AdrKey1 column name fits the '%EEID' mask, it will pull up on employee page.  See core view vw_AuditEEData. In fact, core may have changed that, maybe it used to require three-char prefix.
				SET @ErrorMessage = 'Error in Audit Configuration for table [' + @TableName + ']: EEID column detected on table, but was not specified as ColumnToUseForKey1.'
				RAISERROR(@ErrorMessage,16,1)
				RETURN
			END
			IF (@ColCOID IS NOT NULL) AND (@ColumnToUseForKey2 != @ColCOID)
			BEGIN
				-- A table that has both an EEID column and COID column, should have EEID As the first key (tested in preceding case), and COID as the second key.
				-- Note that if table only has COID column, there is no requirement that it be key2, or key1, or any key.
				SET @ErrorMessage = 'Error in Audit Configuration for table [' + @TableName + ']: COID column detected on table, but was not specified as ColumnToUseForKey2.'
				RAISERROR(@ErrorMessage,16,1)
				RETURN
			END
		END
		
		IF NOT EXISTS (SELECT 1 FROM SysColumns WHERE id = Object_ID('dbo.' + @TableName) AND name = @ColumnToUseForKey1)
		BEGIN
			SET @ErrorMessage = 'The column specified by the ColumnToUseForKey1 parameter is not valid. It does not exist for the specified table. ColumnName=[' + @ColumnToUseForKey1 + ']'
			RAISERROR(@ErrorMessage,16,1)
			RETURN
		END
		
		-- ColumnToUseForKey1 (aka AdrKey1) cannot be Nullable, or Audit system will get an error.  (However, AdrKey2 and AdrKey3 can be nullable, doesn't matter there).
		SELECT @AdrKey1IsNullable = IsNullable FROM SysColumns WHERE id = Object_ID('dbo.' + @TableName) AND name = @ColumnToUseForKey1
		IF (@AdrKey1IsNullable = 1)
		BEGIN
			SET @ErrorMessage = 'The column specified by the ColumnToUseForKey1 parameter cannot be a Nullable column. ColumnName=[' + @ColumnToUseForKey1 + ']'
			RAISERROR(@ErrorMessage,16,1)
			RETURN
		END
		
		IF (@ColumnToUseForKey2 <> '')
		BEGIN
			IF NOT EXISTS (SELECT 1 FROM SysColumns WHERE id = Object_ID('dbo.' + @TableName) AND name = @ColumnToUseForKey2)
			BEGIN
				SET @ErrorMessage = 'The column specified by the ColumnToUseForKey2 parameter is not valid. It does not exist for the specified table. ColumnName=[' + @ColumnToUseForKey2 + ']'
				RAISERROR(@ErrorMessage,16,1)
				RETURN
			END
		END
		
		IF (@ColumnToUseForKey3 <> '')
		BEGIN
			IF NOT EXISTS (SELECT 1 FROM SysColumns WHERE id = Object_ID('dbo.' + @TableName) AND name = @ColumnToUseForKey3)
			BEGIN
				SET @ErrorMessage = 'The column specified by the ColumnToUseForKey3 parameter is not valid. It does not exist for the specified table. ColumnName=[' + @ColumnToUseForKey3 + ']'
				RAISERROR(@ErrorMessage,16,1)
				RETURN
			END
		END
		
		SELECT @ColIdentity = col.NAME
		FROM SysObjects tbl (NoLock)
		JOIN SysColumns col (NoLock) ON col.id = tbl.id
		WHERE tbl.id = Object_ID('dbo.' + @TableName)
		  AND tbl.xtype = 'U'
		  AND ColumnProperty(tbl.id, col.Name, 'IsIdentity') = 1
		
		IF (@ColIdentity IS NULL)
		BEGIN
			SET @ErrorMessage = 'Error in Audit Configuration for table [' + @TableName + ']: No Identity column detected. An Identity column is required to use the Auditing system.'
			RAISERROR(@ErrorMessage,16,1)
			RETURN
		END
		
	END		-- Ends if not DropOnly
	
	-- DROP EXISTING STUFF
	
	IF (@DropBeforeAdd = 'Y') OR (@DropOnly = 'Y')
	BEGIN
	
		PRINT 'Removing any existing Audit Configuration for table [' + @TableName + ']'

		-- Disable triggers, just so that Audit system doesn't get an error while this script is being run
	
		SET @TriggerDEL = 'dbo.trg_Audit_' + @TableName + '_DEL'
		SET @TriggerINS = 'dbo.trg_Audit_' + @TableName + '_INS'
		SET @TriggerMOD = 'dbo.trg_Audit_' + @TableName + '_MOD'

		IF EXISTS (SELECT 1 FROM SysObjects WHERE id = Object_ID(@TriggerDEL) and OBJECTPROPERTY(id,'IsTrigger') = 1)
		BEGIN
			PRINT 'Disabling Trigger ' + @TriggerDEL
			SET @DisableTriggerSQL = 'DISABLE TRIGGER ' + @TriggerDEL + ' ON dbo.' + @TableName
			EXEC(@DisableTriggerSQL)
			IF (@@ERROR <> 0) SET @ErrorMessage = 'Error in Audit Configuration for table [' + @TableName + ']: Error disabling trigger. Quitting.'
			IF (@ErrorMessage != '')
			BEGIN
				PRINT @ErrorMessage
				RETURN
			END
		END

		IF EXISTS (SELECT 1 FROM SysObjects WHERE id = Object_ID(@TriggerINS) and OBJECTPROPERTY(id,'IsTrigger') = 1)
		BEGIN
			PRINT 'Disabling Trigger ' + @TriggerINS
			SET @DisableTriggerSQL = 'DISABLE TRIGGER ' + @TriggerINS + ' ON dbo.' + @TableName
			EXEC(@DisableTriggerSQL)
			IF (@@ERROR <> 0) SET @ErrorMessage = 'Error in Audit Configuration for table [' + @TableName + ']: Error disabling trigger. Quitting.'
			IF (@ErrorMessage != '')
			BEGIN
				PRINT @ErrorMessage
				RETURN
			END
		END

		IF EXISTS (SELECT 1 FROM SysObjects WHERE id = Object_ID(@TriggerMOD) and OBJECTPROPERTY(id,'IsTrigger') = 1)
		BEGIN
			PRINT 'Disabling Trigger ' + @TriggerMOD
			SET @DisableTriggerSQL = 'DISABLE TRIGGER ' + @TriggerMOD + ' ON dbo.' + @TableName
			EXEC(@DisableTriggerSQL)
			IF (@@ERROR <> 0) SET @ErrorMessage = 'Error in Audit Configuration for table [' + @TableName + ']: Error disabling trigger. Quitting.'
			IF (@ErrorMessage != '')
			BEGIN
				PRINT @ErrorMessage
				RETURN
			END
		END
		
		-- Delete previous configuration and remove triggers and ghost table
	
		BEGIN TRY
		
			-- Remove previous configuration
			
			DELETE FROM dbo.AuditSetupCustom WHERE asdTableName = @TableName
			DELETE FROM dbo.AuditConfig WHERE TableName = @TableName
			
			-- Drop triggers
			
			-- NOTE: Dropping triggers and removing ghost table could also have been accomplished with:  EXEC dbo.HRMS_CreateAuditTablesAndTriggers @p_TableName='sometable', @p_DropOnly=1
			-- However, that won't clean up AuditPending table, and doesn't disable then drop, and besides, I think I had already written all this logic before realizing I could have
			-- called that core routine.  So, keeping the in-line logic.
			
			IF EXISTS (SELECT 1 FROM SysObjects WHERE id = Object_ID(@TriggerMOD) and OBJECTPROPERTY(id,'IsTrigger') = 1)
			BEGIN
				SET @DisableTriggerSQL = 'DROP TRIGGER ' + @TriggerMOD
				EXEC(@DisableTriggerSQL)
			END
			
			IF EXISTS (SELECT 1 FROM SysObjects WHERE id = Object_ID(@TriggerDEL) and OBJECTPROPERTY(id,'IsTrigger') = 1)
			BEGIN
				SET @DisableTriggerSQL = 'DROP TRIGGER ' + @TriggerDEL
				EXEC(@DisableTriggerSQL)
			END
			
			IF EXISTS (SELECT 1 FROM SysObjects WHERE id = Object_ID(@TriggerINS) and OBJECTPROPERTY(id,'IsTrigger') = 1)
			BEGIN
				SET @DisableTriggerSQL = 'DROP TRIGGER ' + @TriggerINS
				EXEC(@DisableTriggerSQL)
			END
			
			SET @GhostTableName = 'dbo.Ghost_' + @TableName
			
			IF EXISTS (SELECT 1 FROM SysObjects WHERE id = Object_ID(@GhostTableName) AND OBJECTPROPERTY(id,'IsUserTable') = 1)
			BEGIN
				SET @DropGhostSQL = 'DROP TABLE ' + @GhostTableName
				EXEC(@DropGhostSQL)
			END
			
			IF EXISTS (SELECT 1 FROM dbo.AuditPending (NoLock) WHERE pndTableName = @TableName)
			BEGIN
				-- Clears any data that hasn't been processed by audit system for this table. This can be helpful in case some bad data got staged here and is causing auditing process to error out.
				DELETE FROM dbo.AuditPending WHERE pndTableName = @TableName
				PRINT 'Cleared data for this table from AuditPending table'
			END
			
			PRINT 'Dropped triggers and ghost table'
			
		END TRY
		BEGIN CATCH
			SET @ErrorMessage = 'Error in Audit Configuration for table [' + @TableName + ']: Error clearing previous configuration. Quitting.'
			PRINT @ErrorMessage
			RETURN
		END CATCH
		
	END
	
	IF (@DropOnly = 'Y') BEGIN
		PRINT 'Finished removing Audit configuration for table [' + @TableName + ']. Since DropOnly was requested, we are done.'
		RETURN
	END
	
	-- GET OUT IF ALREADY EXISTS
	
	IF EXISTS (SELECT 1 FROM dbo.AuditSetupCustom (NoLock) WHERE asdTableName = @TableName)
	BEGIN
		PRINT 'Audit Configuration for table [' + @TableName + '] already exists. Doing nothing.'
		RETURN
	END
	
	-- Due to "SET XACT_ABORT ON", from this point on, any errors will cause statement or transaction in progress to abort/rollback and execution of the stored procedure to end
	
	SET XACT_ABORT ON

	-- Validate lengths on column names
	
	SET @ColumnNameTooLong = ''
	
	SELECT TOP 1 @ColumnNameTooLong = col.name
	FROM sys.objects tbl (NoLock)
	JOIN sys.columns col (NoLock) ON col.object_id = tbl.object_id
	WHERE tbl.name = @TableName
	  AND LEN(ISNULL(col.name,'')) > 100
	ORDER BY LEN(ISNULL(col.name,'')) DESC
	
	IF (@ColumnNameTooLong <> '')
	BEGIN
		SET @ErrorMessage = 'Error in Audit Configuration for table [' + @TableName + ']: Column Name [' + @ColumnNameTooLong + '] is too long, cannot be more than 100 chars.'
		RAISERROR(@ErrorMessage,16,1)
		RETURN
	END
	
	-- INSERTS
	
	PRINT 'Adding Audit Configuration records...'
	
	INSERT INTO dbo.AuditSetupCustom (asdTableName, asdKey1FieldName, asdKey2FieldName, asdKey3FieldName)
	SELECT @TableName, @ColumnToUseForKey1, @ColumnToUseForKey2, @ColumnToUseForKey3
	
	-- AuditConfig is the table that specifies which columns of the table are being audited.
	-- We're are turning them all on (except the identity column and columns of type TEXT).

	-- Identity column doesn't need to be added because it's already present in AuditRecords.adrKey column.  It can be added to AuditConfig, but it's redundant.
	-- TEXT columns, if added to AuditConfig, are just ignored by Audit system, and won't be put in Ghost table or tracked.  That's because you can't do a SUBSTRING on TEXT column.
	-- We could add it, but would just cause confusion, better to not add it.

	-- Client admin users can adjust this configuration afterwards, choosing not to audit some columns, or turning auditing off on the table altogether,
	-- via web screen "System Configuration > System Settings > Auditing".
	
	IF (@TurnItOn = 'Y')
	BEGIN
		INSERT INTO dbo.AuditConfig (TableName, FieldName)
		SELECT tbl.Name, col.Name
		FROM sys.objects tbl (NoLock)
		JOIN sys.columns col (NoLock) ON col.object_id = tbl.object_id
		JOIN sys.types typ (NoLock) ON typ.user_type_id = col.user_type_id
		WHERE tbl.name = @TableName
		  AND col.is_identity <> 1
		  AND typ.name <> 'text'
		ORDER BY col.Name
	END
	
	-- CREATE TRIGGERS

	IF (@TurnItOn = 'Y')
	BEGIN
		PRINT 'Creating Audit Triggers...'
		EXEC dbo.HRMS_CreateAuditTablesAndTriggers @p_TableName=@TableName, @p_DropOnly=0
	END
	
	IF (@TurnItOn != 'Y')
	BEGIN
		PRINT 'NOTE: The table has been made Audit-able, but Auditing for it has not actually been turned on. Client can turn it on themselves now.'
	END
	
	-- Check if Auditing is disabled overall for this client.  Shouldn't be.  But can happen if there were errors in the Audit process (not necessarily our stuff).
	-- Point is, our custom table auditing is not going to happen if the overall auditing is disabled, hence this Warning.
	SELECT @AllAuditingIsDisabled = CASE ProcessPending WHEN 0 THEN 'Y' ELSE 'N' END FROM dbo.AuditStatus (NoLock)
	IF (ISNULL(@AllAuditingIsDisabled,'Y') = 'Y') BEGIN
		PRINT 'WARNING: Audit configuration for the table was added, BUT Auditing is currently disabled (for ALL tables) on this database.  The Audit process must be turned on first.'
	END
	
	PRINT 'Finished Audit Configuration for table [' + @TableName + ']'
	PRINT ''

END
GO

CREATE PROCEDURE dbo.U_WebCustoms_AddAuditingToTable (
	@TableName          VARCHAR(101),       -- Tablename can be up to 100 chars long now.
	@ColumnToUseForKey1 VARCHAR(101),       -- Required. What will be used for AdrKey1 value? If table is for an EEID, specify the EEID column here.  Otherwise, put some value that helps uniquely identify a record .
	@ColumnToUseForKey2 VARCHAR(101) = '',  -- If table is for an EEID and COID, specify the COID column here
	@ColumnToUseForKey3 VARCHAR(101) = '',  -- If table is for an EEID and COID, but record has a timed-key SystemID column specify it here.
	@DropBeforeAdd      CHAR(1) = 'N',      -- If checking into "Data Insert", which means it runs each upgrade, recommend that this be set to "N".
	@TurnItOn           CHAR(1) = 'Y',      -- This script makes the table audit-able, and actually configures it to be audited. That's what we/customs usually do. But pass TurnItOn="N" if you want to leave it up to the client to turn on the auditing for the table.
	@OverrideEEIDCheck  CHAR(1) = 'N',      -- If 'N', and there is a column named "xxxEEID", script will require that it be specified as Key1. Usually we want that, but allow for cases where we don't.
	@DropOnly           CHAR(1) = 'N'       -- If all you want to do is remove the Audit configuration, pass 'Y' here.
) AS
BEGIN

	-- This is a wrapper function to the actual function that sets up the Audit Config.
	-- This is so we can attempt, rollback, wait, attempt again, if there are errors setting up the Audit Config.
	-- Because sometimes, due to timing, the Config stuff fails because of the core audit process kicking off every 10 seconds.

	DECLARE @WaitTime VARCHAR(20)
	DECLARE @AttemptNumber INTEGER
	DECLARE @MaxAttempts INT
	DECLARE @KeepTrying CHAR(1)
	
	SET NOCOUNT ON
	
	SET @WaitTime = '00:00:03'		-- Wait 3 seconds
	SET @MaxAttempts = 3
	
	SET @AttemptNumber = 0
	SET @KeepTrying = 'Y'
	
	WHILE (@KeepTrying = 'Y') BEGIN
	
		SET @AttemptNumber = @AttemptNumber + 1
		
		IF (@AttemptNumber > 1) BEGIN
			PRINT 'Waiting a few seconds to try again...'
			WAITFOR DELAY @WaitTime
			PRINT 'Now Trying again...'
		END

		BEGIN TRY
			
			BEGIN TRANSACTION
			
			EXEC dbo.U_WebCustoms_AddAuditingToTable_Internal
				@TableName          ,
				@ColumnToUseForKey1 ,
				@ColumnToUseForKey2 ,
				@ColumnToUseForKey3 ,
				@DropBeforeAdd      ,
				@TurnItOn           ,
				@OverrideEEIDCheck  ,
				@DropOnly
			
			IF (@@TRANCOUNT > 0) BEGIN
				COMMIT TRANSACTION
			END
			
			SET @KeepTrying = 'N'

		END TRY
		BEGIN CATCH
		
			PRINT 'Error encountered: Msg ' + CONVERT(VARCHAR(20),ERROR_NUMBER()) + ', Level ' + CONVERT(VARCHAR(20),ERROR_SEVERITY()) + ', State ' + CONVERT(VARCHAR(20),ERROR_STATE()) + ', Line ' + CONVERT(VARCHAR(20),ERROR_LINE())
			PRINT 'Error Message: ' + ERROR_MESSAGE()
			
			IF (@@TRANCOUNT > 0) BEGIN
				PRINT 'Rolling back transaction'
				ROLLBACK TRANSACTION
			END
			
		END CATCH
		
		IF (@KeepTrying = 'Y') AND (@AttemptNumber >= @MaxAttempts) BEGIN
			PRINT 'Maximum attempts exceeded, giving up on this one.'
			SET @KeepTrying = 'N'
		END

	END		-- End Retry Loop
	
END
GO

-------------------------------------------------
-- SCRIPT  (THE SCRIPT)
-------------------------------------------------

-- Table names can be up to 100 chars long.
-- Column names can be up to 100 chars long.
-- For Key1-to-Key3, the columns can be integer, decimal, varchar, etc.... anything except TEXT.
-- If you can't figure out a good column to use for Key1 (which is required), you can specify the Identity column. That's ok, doesn't cause a problem.
-- DropBeforeAdd removes all configuration first, then re-adds.  Will lose customer's preferences if they had limited auditing on the table.  Will turn it all back on (if TurnItOn specified).
-- If not DropBeforeAdd, then it's really Add If Not Exists.... procedure checks for presence of audit configuration for table, and if it sees some configuration, will exit without doing anything.
-- If DropBeforeAdd=N, and records exist in AuditSetupCustom, nothing is done.... so even if you had TurnItOn=Y, and client had since turned it off, it won't turn it back on.
-- if you really need to ensure that Auditing is re-turned-on each release, specify both DropBeforeAdd=Y and TurnItOn=Y.

-- Example of typical way we would call this:

EXEC dbo.U_WebCustoms_AddAuditingToTable
	@TableName          = 'U_PER1027_AddlPayDetail',   -- Table can't be more than 100 chars long.  Table needs to have an Identity column.  The Identity column does NOT have to be called AuditKey, can be called anything.
	@ColumnToUseForKey1 = 'uapRecID',				   -- Required. Column cannot be nullable. This specifies what will be used for AuditRecords.AdrKey1 value. If table is for an EEID, specify the EEID column here.  Otherwise, put some value that helps uniquely identify a record.
	@ColumnToUseForKey2 = '',                          -- Optional. If table is for an EEID and COID, recommended to specify the COID column here
	@ColumnToUseForKey3 = '',                          -- Optional. If table is for an EEID and COID, and table has a timed-key SystemID column in addition to EEID/COID, recommended to specify it here.
	@DropBeforeAdd      = 'N',                         -- If checking into "Data Insert", which means it runs each upgrade, recommend that this be set to "N".  Use "Y" during development if you make changes to table setup and want to re-add to audit configuration.
	@TurnItOn           = 'Y'                          -- This script makes the table audit-able, and actually configures it to be audited. That's what we/customs usually do. But pass TurnItOn="N" if you want to leave it up to the client to turn on the auditing for the table.

-------------------------------------------------
-- CLEANUP
-------------------------------------------------

IF EXISTS (SELECT 1 FROM SysObjects WHERE id = Object_ID('dbo.U_WebCustoms_AddAuditingToTable') AND ObjectProperty(id,'IsProcedure')=1)
BEGIN
	DROP PROCEDURE dbo.U_WebCustoms_AddAuditingToTable
END
GO

IF EXISTS (SELECT 1 FROM SysObjects WHERE id = Object_ID('dbo.U_WebCustoms_AddAuditingToTable_Internal') AND ObjectProperty(id,'IsProcedure')=1)
BEGIN
	DROP PROCEDURE dbo.U_WebCustoms_AddAuditingToTable_Internal
END
GO
