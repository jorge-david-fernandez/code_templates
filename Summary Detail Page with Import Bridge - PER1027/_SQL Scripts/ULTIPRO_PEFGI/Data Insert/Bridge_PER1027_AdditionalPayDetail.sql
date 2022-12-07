----------------------------------------------------------------------------------------------------------------------
-- Company:		  UKG 
-- Author:		  Jorge Fernandez
-- Client:		  Performance Food Group, Inc.
-- Date:		  10/31/2022
-- Request:		  SR-2022-00377312
-- Purpose:		  Custom Web Page for Additional Pay Detail
-- Last Modified: 
-----------------------------------------------------------------------------------------------------------------------
/*
    Bridge Types: None = 0, Delimited = 1, XML = 2, FixedLength = 3, Custom = 4
    Translation Types: None = 0, Default = 1, SQL = 2
*/
--||Variables||
DECLARE @ConfigId INT,
		@FilePath VARCHAR(1000),
		@ClientId VARCHAR(100),
		@ClientName VARCHAR(100) = 'Custom'
		--Endpoint variables
		,
		@AuthClientId VARCHAR(100),
		@Secret VARCHAR(500) = '',
		@AuthUrl VARCHAR(100),
		@BaseUrl VARCHAR(100),
		@TenantAlias VARCHAR(100);

SET @ClientId = 'PER1027';
-- custom function name to be executed to process the record.
SET @TenantAlias = 'dbo.U_PER1027_AdditionalPayDetail_Import'
SET @AuthClientId = 'Custom';

--Do not change the Bridge names as they're also used to send notifications
DECLARE @BridgeName VARCHAR(200) = 'Additional Pay Detail Import'


IF RIGHT(@@SERVERNAME, 2) = 'CO'
	OR RIGHT(@@SERVERNAME, 4) = 'WEB' --[DEV]
BEGIN
    SET @FilePath = 'C:\Imports'; 
	SET @AuthUrl = 'https://localhost'
	SET @BaseUrl = 'https://localhost'
	SET @AuthClientId = @AuthClientId
END
ELSE IF @@SERVERNAME = 'nz1d222db01' --TEST
BEGIN
    SET @FilePath = '\\us.saas\nz\Public\PER1027\Imports\AdditionalPay';
	SET @AuthUrl = 'https://EZ41.ultipro.com'
	SET @BaseUrl = 'https://EZ41.ultipro.com'
	SET @AuthClientId = @AuthClientId
END
ELSE IF @@SERVERNAME = 'e2d222db01' --PROD
BEGIN
    SET @FilePath = '\\us.saas\e2\Public\PER1027\Imports\AdditionalPay'; 
	SET @AuthUrl = 'https://E22.ultipro.com'
	SET @BaseUrl = 'https://E22.ultipro.com'
	SET @AuthClientId = @AuthClientId
END

--||Bridge Configuration||
--||This is the parent configuration for bridge. Bridge Name is a unique key, and the generated Id will be output||
SELECT @ConfigId = ConfigurationId FROM Bridge_Configuration (NOLOCK) WHERE BridgeName = @BridgeName

EXEC dbo.Bridge_AddUpdateConfiguration
	@BridgeName = @BridgeName,
	@BridgeType = 1,
	@Delimiter = ',',
	@InputFilePath = @FilePath,
	@FileNamePattern = '*.csv',
	@IgnoreHeader = 1,
	@IgnoreTrailer = 0,
	@ShowInResults = 1,
	@AllowManualUpload = 1,
	@ExistingConfigurationID = @ConfigId,
	@ConfigurationId = @ConfigId OUTPUT;

IF @ConfigId IS NOT NULL
BEGIN
    --||Add Endpoint Configuration
	EXEC dbo.Bridge_AddUpdateClientEndpoint @ConfigurationId = @ConfigId,
		@ClientName = @ClientName,
		@AuthUrl = @AuthUrl,
		@BaseUrl = @BaseUrl,
		@AuthClientId = @AuthClientId,
		@AuthClientSecret = @Secret,
		@TenantAlias = @TenantAlias

	DECLARE @Client_ClientId INT;

	SELECT TOP 1 @Client_ClientId = [ClientId]
	FROM [dbo].[Bridge_Client]
	WHERE [ClientName] = @ClientName;

	IF EXISTS (
			SELECT 1
			FROM [dbo].[Bridge_ClientTransactionInfo]
			WHERE ClientId = @Client_ClientId
				AND TransactionName = @BridgeName
			)
	BEGIN
		UPDATE [dbo].[Bridge_ClientTransactionInfo]
		SET JsonSchema = NULL,
			CustomSPName = @TenantAlias -- function to retrieve the schema from
		WHERE ClientId = @Client_ClientId
			AND TransactionName = @BridgeName
	END
	ELSE
	BEGIN
		EXEC [dbo].[Bridge_AddUpdateClientTransactionInfo] @ClientId = @Client_ClientId,
			@TransactionName = @BridgeName,
			@PostUri = 'custom-sql-object',
			@JsonSchema = NULL,
			@CustomSPName = @TenantAlias
	END

	DECLARE @transId INT;
	DECLARE @TranslationId INT;

	--||TRANSACTION||
	SELECT @transId = TransactionId FROM dbo.Bridge_Transaction (NOLOCK) WHERE ConfigurationId = @ConfigId AND TransactionName = @BridgeName

	EXEC dbo.Bridge_AddUpdateTransaction @ConfigurationId = @ConfigId
										,@TransactionName = @BridgeName
										,@ClientName = 'Custom'
										,@TransactionType = @BridgeName
										,@ExecutionOrder = 0
										,@QualifierExpression = NULL
										,@ExistingTransactionId = @transId
										,@TransactionId = @transId OUTPUT;

	IF @TransId IS NOT NULL
    BEGIN
		--||Input Fields||
		DECLARE @InputFieldId INT, @InputName VARCHAR (250)

		SELECT @InputFieldId = 0, @InputName = 'EmployeeNumber'
		SELECT @InputFieldId = InputFieldId FROM dbo.Bridge_InputField (NOLOCK) WHERE TransactionId = @transId AND Name = @InputName
		EXEC dbo.Bridge_AddUpdateInputField @TransactionId = @transId,@Name = @InputName, @Position = 1,@XMLPath = NULL, @ExistingInputFieldId = @InputFieldId, @IsSupplemental = 0;

		SELECT @InputFieldId = 0, @InputName = 'PayDate'
		SELECT @InputFieldId = InputFieldId FROM dbo.Bridge_InputField (NOLOCK) WHERE TransactionId = @transId AND Name = @InputName
		EXEC dbo.Bridge_AddUpdateInputField @TransactionId = @transId,@Name = @InputName, @Position = 2,@XMLPath = NULL, @ExistingInputFieldId = @InputFieldId, @IsSupplemental = 0;

		SELECT @InputFieldId = 0, @InputName = 'WeekEndDate'
		SELECT @InputFieldId = InputFieldId FROM dbo.Bridge_InputField (NOLOCK) WHERE TransactionId = @transId AND Name = @InputName
		EXEC dbo.Bridge_AddUpdateInputField @TransactionId = @transId,@Name = @InputName, @Position = 7,@XMLPath = NULL, @ExistingInputFieldId = @InputFieldId, @IsSupplemental = 0;

		SELECT @InputFieldId = 0, @InputName = 'Description'
		SELECT @InputFieldId = InputFieldId FROM dbo.Bridge_InputField (NOLOCK) WHERE TransactionId = @transId AND Name = @InputName
		EXEC dbo.Bridge_AddUpdateInputField @TransactionId = @transId,@Name = @InputName, @Position = 8,@XMLPath = NULL, @ExistingInputFieldId = @InputFieldId, @IsSupplemental = 0;

		SELECT @InputFieldId = 0, @InputName = 'Hours'
		SELECT @InputFieldId = InputFieldId FROM dbo.Bridge_InputField (NOLOCK) WHERE TransactionId = @transId AND Name = @InputName
		EXEC dbo.Bridge_AddUpdateInputField @TransactionId = @transId,@Name = @InputName, @Position = 9,@XMLPath = NULL, @ExistingInputFieldId = @InputFieldId, @IsSupplemental = 0;

		SELECT @InputFieldId = 0, @InputName = 'Units'
		SELECT @InputFieldId = InputFieldId FROM dbo.Bridge_InputField (NOLOCK) WHERE TransactionId = @transId AND Name = @InputName
		EXEC dbo.Bridge_AddUpdateInputField @TransactionId = @transId,@Name = @InputName, @Position = 10,@XMLPath = NULL, @ExistingInputFieldId = @InputFieldId, @IsSupplemental = 0;

		SELECT @InputFieldId = 0, @InputName = 'Rate'
		SELECT @InputFieldId = InputFieldId FROM dbo.Bridge_InputField (NOLOCK) WHERE TransactionId = @transId AND Name = @InputName
		EXEC dbo.Bridge_AddUpdateInputField @TransactionId = @transId,@Name = @InputName, @Position = 11,@XMLPath = NULL, @ExistingInputFieldId = @InputFieldId, @IsSupplemental = 0;

		SELECT @InputFieldId = 0, @InputName = 'Sales'
		SELECT @InputFieldId = InputFieldId FROM dbo.Bridge_InputField (NOLOCK) WHERE TransactionId = @transId AND Name = @InputName
		EXEC dbo.Bridge_AddUpdateInputField @TransactionId = @transId,@Name = @InputName, @Position = 12,@XMLPath = NULL, @ExistingInputFieldId = @InputFieldId, @IsSupplemental = 0;

		SELECT @InputFieldId = 0, @InputName = 'Supplemental'
		SELECT @InputFieldId = InputFieldId FROM dbo.Bridge_InputField (NOLOCK) WHERE TransactionId = @transId AND Name = @InputName
		EXEC dbo.Bridge_AddUpdateInputField @TransactionId = @transId,@Name = @InputName, @Position = 13,@XMLPath = NULL, @ExistingInputFieldId = @InputFieldId, @IsSupplemental = 0;

		SELECT @InputFieldId = 0, @InputName = 'Profit'
		SELECT @InputFieldId = InputFieldId FROM dbo.Bridge_InputField (NOLOCK) WHERE TransactionId = @transId AND Name = @InputName
		EXEC dbo.Bridge_AddUpdateInputField @TransactionId = @transId,@Name = @InputName, @Position = 14,@XMLPath = NULL, @ExistingInputFieldId = @InputFieldId, @IsSupplemental = 0;

		SELECT @InputFieldId = 0, @InputName = 'Notes'
		SELECT @InputFieldId = InputFieldId FROM dbo.Bridge_InputField (NOLOCK) WHERE TransactionId = @transId AND Name = @InputName
		EXEC dbo.Bridge_AddUpdateInputField @TransactionId = @transId,@Name = @InputName, @Position = 15,@XMLPath = NULL, @ExistingInputFieldId = @InputFieldId, @IsSupplemental = 0;

		SELECT @InputFieldId = 0, @InputName = 'ActionIndicator'
		SELECT @InputFieldId = InputFieldId FROM dbo.Bridge_InputField (NOLOCK) WHERE TransactionId = @transId AND Name = @InputName
		EXEC dbo.Bridge_AddUpdateInputField @TransactionId = @transId,@Name = @InputName, @Position = 16,@XMLPath = NULL, @ExistingInputFieldId = @InputFieldId, @IsSupplemental = 0;

		SELECT @InputFieldId = 0, @InputName = 'TransactionID'
		SELECT @InputFieldId = InputFieldId FROM dbo.Bridge_InputField (NOLOCK) WHERE TransactionId = @transId AND Name = @InputName
		EXEC dbo.Bridge_AddUpdateInputField @TransactionId = @transId,@Name = @InputName, @Position = NULL,@XMLPath = NULL, @ExistingInputFieldId = @InputFieldId, @IsSupplemental = 1;

		--||Field Mappings||
		EXEC dbo.Bridge_AddUpdateMapping @TransactionId = @transId,@InputFieldName = 'EmployeeNumber',@MapToField = 'EmployeeNumber';
		EXEC dbo.Bridge_AddUpdateMapping @TransactionId = @transId,@InputFieldName = 'PayDate',@MapToField = 'PayDate';
		EXEC dbo.Bridge_AddUpdateMapping @TransactionId = @transId,@InputFieldName = 'WeekEndDate',@MapToField = 'WeekEndDate';
		EXEC dbo.Bridge_AddUpdateMapping @TransactionId = @transId,@InputFieldName = 'Description',@MapToField = 'Description';
		EXEC dbo.Bridge_AddUpdateMapping @TransactionId = @transId,@InputFieldName = 'Hours',@MapToField = 'Hours';
		EXEC dbo.Bridge_AddUpdateMapping @TransactionId = @transId,@InputFieldName = 'Units',@MapToField = 'Units';
		EXEC dbo.Bridge_AddUpdateMapping @TransactionId = @transId,@InputFieldName = 'Rate',@MapToField = 'Rate';
		EXEC dbo.Bridge_AddUpdateMapping @TransactionId = @transId,@InputFieldName = 'Sales',@MapToField = 'Sales';
		EXEC dbo.Bridge_AddUpdateMapping @TransactionId = @transId,@InputFieldName = 'Supplemental',@MapToField = 'Supplemental';
		EXEC dbo.Bridge_AddUpdateMapping @TransactionId = @transId,@InputFieldName = 'Profit',@MapToField = 'Profit';
		EXEC dbo.Bridge_AddUpdateMapping @TransactionId = @transId,@InputFieldName = 'Notes',@MapToField = 'Notes';
		EXEC dbo.Bridge_AddUpdateMapping @TransactionId = @transId,@InputFieldName = 'ActionIndicator',@MapToField = 'Action';
		EXEC dbo.Bridge_AddUpdateMapping @TransactionId = @transId,@InputFieldName = 'TransactionID',@MapToField = 'TransactionID';

		--||Field Translations||
		EXEC dbo.Bridge_AddUpdateTranslation @TransactionId = @transId,@InputFieldName = 'TransactionID',@Type = 2,@Expression = 'SELECT NEWID()',@TranslationId = @TranslationId OUTPUT;
	END
END
ELSE
BEGIN
    DECLARE @ErrorMessage VARCHAR(500) = 'Could not successfully create Bridge Configuration';
    RAISERROR (@ErrorMessage,10,-1, 'Bridge_Setup');
END
