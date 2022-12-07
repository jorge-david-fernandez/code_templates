----------------------------------------------------------------------------------------------------------------------
-- Company:		  Ultimate Software Corp. 
-- Author:		  Adrian Serrano
-- Client:		  Lazy Dog Restaurants, LLC
-- Date:		  1/28/2020
-- Request:		  SR-2019-00245269
-- Purpose:		  Instant Pay Direct Deposit (from scope project SR-2019-00233967)
-- Last Modified: 
-----------------------------------------------------------------------------------------------------------------------

/*
    Bridge Types: None = 0, Delimited = 1, XML = 2, FixedLength = 3, Custom = 4
    Translation Types: None = 0, Default = 1, SQL = 2
*/
--||Variables||
DECLARE @ConfigId INT;
DECLARE @FilePath VARCHAR(1000);
--||Environment Specific Values||
--||This is where you will set values that may change based on a clients environment, such as import path||
--[DEV]
IF @@SERVERNAME = 'RJDF1241S1SICO' OR DEFAULT_DOMAIN() = 'WORKGROUP'
BEGIN
    SET @FilePath = 'C:\Bridge';
END
--[Test]
IF @@SERVERNAME = 'EZ1SUP5DB01'
BEGIN
    SET @FilePath = '\\us.saas\ez\Public\LAZ1001\Imports_Test\DebitCard';
END
--[Production]
IF @@SERVERNAME = 'N3SUP1DB03'
BEGIN
    SET @FilePath = '\\us.saas\n3\Public\LAZ1001\Imports\DebitCard';
END

SELECT TOP 1 @ConfigId = ConfigurationId
FROM Bridge_Configuration (NOLOCK)
WHERE BridgeName = 'Debit Card Direct Deposit'

--||Bridge Configuration||
--||This is the parent configuration for bridge. Bridge Name is a unique key, and the generated Id will be output||
EXEC dbo.Bridge_AddUpdateConfiguration @BridgeName = 'Debit Card Direct Deposit',
                                         @BridgeType = 1,
                                         @Delimiter = ',',
                                         @InputFilePath = @FilePath,
                                         @FileNamePattern = 'Client_LAZ1001_DebitCardImport*.csv',
                                         @IgnoreHeader = 1,
                                         @IgnoreTrailer = 0,
					 @ExistingConfigurationID = @ConfigId,
                                         @ConfigurationId = @ConfigId OUTPUT;
IF @ConfigId IS NOT NULL
BEGIN
    --||Transactions||
    --||A transaction encapsulate which process you want your data to go through and in what order||
    --||You may configure different fields, mappings, and translations for each different transaction||
    DECLARE @UDFieldsTransId INT;
    DECLARE @transId INT;
    
    	SELECT TOP 1 @transId = TransactionId
	FROM Bridge_Transaction (NOLOCK)
	WHERE ConfigurationId = @ConfigId
	AND TransactionName = 'Add/Update UDFields'
			
    EXEC dbo.Bridge_AddUpdateTransaction @ConfigurationId = @ConfigId,
                                           @TransactionName = 'Add/Update UDFields',
                                           @ClientName = 'UltiPro',
                                           @TransactionType = 'UDFIELDS',
                                           @ExecutionOrder = 1,
                                           @QualifierExpression = NULL,
					   @ExistingTransactionId = @transId, 
                                           @TransactionId = @UDFieldsTransId OUTPUT;
    IF @UDFieldsTransId IS NOT NULL
    BEGIN
        --||Input Fields||
        --||These are all of the fields which are on the file and you need||
        --||In addition, fields not on the file, but that will be derived through a translation, must also be defined here||
        --[On file]
	DECLARE @InputId BIGINT
	SELECT TOP 1 @InputId = InputFieldId
	FROM Bridge_InputField (NOLOCK)
	WHERE TransactionId = @transId
	AND [Name] = 'Approved'
			
        EXEC dbo.Bridge_AddUpdateInputField @TransactionId = @UDFieldsTransId, @Name = 'Approved', @Position = 4, @Length = NULL, @XMLPath = NULL, @IsSupplemental = 0,@ExistingInputFieldId = @InputId;
	
	SET @InputId = NULL
	SELECT TOP 1 @InputId = InputFieldId
	FROM Bridge_InputField (NOLOCK)
	WHERE TransactionId = @transId
	AND [Name] = 'Company'
	
	EXEC dbo.Bridge_AddUpdateInputField @TransactionId = @UDFieldsTransId, @Name = 'Company', @Position = NULL, @Length = NULL, @XMLPath = NULL, @IsSupplemental = 0,@ExistingInputFieldId = @InputId;
        	
	SET @InputId = NULL
	SELECT TOP 1 @InputId = InputFieldId
	FROM Bridge_InputField (NOLOCK)
	WHERE TransactionId = @transId
	AND [Name] = 'EmployeeNumber'
	
	EXEC dbo.Bridge_AddUpdateInputField @TransactionId = @UDFieldsTransId, @Name = 'EmployeeNumber', @Position = 7, @Length = NULL, @XMLPath = NULL, @IsSupplemental = 0,@ExistingInputFieldId = @InputId;
        	
	SET @InputId = NULL
	SELECT TOP 1 @InputId = InputFieldId
	FROM Bridge_InputField (NOLOCK)
	WHERE TransactionId = @transId
	AND [Name] = 'ActiveCard'
	
	EXEC dbo.Bridge_AddUpdateInputField @TransactionId = @UDFieldsTransId, @Name = 'ActiveCard', @Position = 6, @Length = NULL, @XMLPath = NULL, @IsSupplemental = 0,@ExistingInputFieldId = @InputId;
     
        --[Not on file]
		
	SET @InputId = NULL
	SELECT TOP 1 @InputId = InputFieldId
	FROM Bridge_InputField (NOLOCK)
	WHERE TransactionId = @transId
	AND [Name] = 'TransactionType'
	
        EXEC dbo.Bridge_AddUpdateInputField @TransactionId = @UDFieldsTransId, @Name = 'TransactionType',@Position = NULL,@Length = NULL,@XMLPath = NULL,@IsSupplemental = 0,@ExistingInputFieldId = @InputId;
        	
	SET @InputId = NULL
	SELECT TOP 1 @InputId = InputFieldId
	FROM Bridge_InputField (NOLOCK)
	WHERE TransactionId = @transId
	AND [Name] = 'IdentifierRule'
	
	EXEC dbo.Bridge_AddUpdateInputField @TransactionId = @UDFieldsTransId, @Name = 'IdentifierRule',@Position = NULL,@Length = NULL,@XMLPath = NULL,@IsSupplemental = 0,@ExistingInputFieldId = @InputId;
        	
	SET @InputId = NULL
	SELECT TOP 1 @InputId = InputFieldId
	FROM Bridge_InputField (NOLOCK)
	WHERE TransactionId = @transId
	AND [Name] = 'ApprovalRule'
	
	EXEC dbo.Bridge_AddUpdateInputField @TransactionId = @UDFieldsTransId, @Name = 'ApprovalRule',@Position = NULL,@Length = NULL,@XMLPath = NULL,@IsSupplemental = 0,@ExistingInputFieldId = @InputId;
        --||Field Mappings||
        --||Here you will define where each field value should be put on the XSD||
        --||The XSD path should not include the "Transaction" node||
        --||Field Mappings||
		EXEC dbo.Bridge_AddUpdateMapping @TransactionId = @UDFieldsTransId,@InputFieldName = 'Approved',@MapToField = 'JobUDFields\JobUDField06';
		EXEC dbo.Bridge_AddUpdateMapping @TransactionId = @UDFieldsTransId,@InputFieldName = 'EmployeeNumber',@MapToField = 'KeyFields\Identifier';
		EXEC dbo.Bridge_AddUpdateMapping @TransactionId = @UDFieldsTransId,@InputFieldName = 'Company', @MapToField = 'KeyFields\CompanyCode';
		EXEC dbo.Bridge_AddUpdateMapping @TransactionId = @UDFieldsTransId,@InputFieldName = 'ActiveCard',@MapToField = 'JobUDFields\JobUDField05';
		EXEC dbo.Bridge_AddUpdateMapping @TransactionId = @UDFieldsTransId,@InputFieldName = 'TransactionType',@MapToField = 'Header\TransactionType';
		EXEC dbo.Bridge_AddUpdateMapping @TransactionId = @UDFieldsTransId,@InputFieldName = 'IdentifierRule',@MapToField = 'Header\IdentifierRule';
		EXEC dbo.Bridge_AddUpdateMapping @TransactionId = @UDFieldsTransId,@InputFieldName = 'ApprovalRule',@MapToField = 'Header\ApprovalRule';
        --||Field Translations||
        --||Here you will configure a translation to be applied to any of the input fields||
        --||Translations can be a static default value (Type 1), or SQL ran against the company DB (Type 2)||
        EXEC dbo.Bridge_AddUpdateTranslation @TransactionId = @UDFieldsTransId, @InputFieldName = 'EmployeeNumber', @Type = 2, @Expression = 'SELECT EecEEID FROM EmpComp (NOLOCK) INNER JOIN Company (NOLOCK) ON EecCOID = CmpCOID WHERE EecEmpNo = (REPLICATE(''0'', 6 - LEN(CAST(@EmployeeNumber AS CHAR(6)))) + CAST(@EmployeeNumber AS CHAR(6)))';
		EXEC dbo.Bridge_AddUpdateTranslation @TransactionId = @UDFieldsTransId, @InputFieldName = 'Company', @Type = 1, @Expression = 'LAZDG';
		EXEC dbo.Bridge_AddUpdateTranslation @TransactionId = @UDFieldsTransId, @InputFieldName = 'Approved', @Type = 2, @Expression = ' SELECT FORMAT(CAST(NULLIF(SUBSTRING(ISNULL(@Approved,''''), 0,CHARINDEX('' '', ISNULL(@Approved,'''')) +1),'''') AS DATETIME), ''MM/dd/yyyy'') ';
		EXEC dbo.Bridge_AddUpdateTranslation @TransactionId = @UDFieldsTransId, @InputFieldName = 'ActiveCard', @Type = 2, @Expression = 'SELECT CASE @ActiveCard WHEN ''TRUE'' THEN ''Y'' ELSE ''N'' END';
        EXEC dbo.Bridge_AddUpdateTranslation @TransactionId = @UDFieldsTransId, @InputFieldName = 'TransactionType', @Type = 1, @Expression = 'UDFIELDS';
        EXEC dbo.Bridge_AddUpdateTranslation @TransactionId = @UDFieldsTransId, @InputFieldName = 'IdentifierRule', @Type = 1, @Expression = 'EEID';
        EXEC dbo.Bridge_AddUpdateTranslation @TransactionId = @UDFieldsTransId, @InputFieldName = 'ApprovalRule', @Type = 1, @Expression = 'FORCEAUTO';
    END
END
ELSE
BEGIN
    DECLARE @ErrorMessage VARCHAR(500) = 'Could not successfully create Bridge Configuration';
    RAISERROR (@ErrorMessage,10,-1, 'Bridge_Setup');
END
