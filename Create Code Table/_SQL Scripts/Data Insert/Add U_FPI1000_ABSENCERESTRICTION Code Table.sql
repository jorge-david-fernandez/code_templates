----------------------------------------------------------------------------------------------------------------------
-- Company:		  UKG 
-- Author:		  Jorge David Fernandez
-- Client:		  FPI Management, Inc.
-- Date:		  6/6/2021
-- Request:		  SR-2020-00299650
-- Purpose:		  Custom Modifications to OSHA Screen
-- Last Modified: 
-----------------------------------------------------------------------------------------------------------------------

-- Drop temporary utility procedure
IF OBJECT_ID('dbo.ConsultingServices_AddCodeTable') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.ConsultingServices_AddCodeTable
END
GO

-- Create temporary utility procedure
CREATE PROCEDURE dbo.ConsultingServices_AddCodeTable (
	@CodeTableName           VARCHAR(20),
	@CodeTableDescription    VARCHAR(50),
	@CodeTableWebDescription VARCHAR(140) = NULL,
	@CodeLength              INT = 15,
	@DescriptionLength       INT = 45,
	@VisibleInWeb            CHAR(1) = 'N'
) AS
BEGIN

	SET NOCOUNT ON
	
	DELETE [dbo].[CoUpCdeDrv] WHERE [CodeTable] = @CodeTableName

	IF NOT EXISTS (SELECT 1 FROM [dbo].[CoUpCdeDrv] WHERE [CodeTable] = @CodeTableName)
	BEGIN
	
		DECLARE @CodeEditMask VARCHAR(25)
		
		SET @CodeEditMask = '>' + REPLICATE('a',@CodeLength) + ';0;-'
		
		IF (@CodeTableWebDescription IS NULL) BEGIN
			SET @CodeTableWebDescription = 'Define or Modify ' + @CodeTableDescription
		END
		
		INSERT INTO [dbo].[CoUpCdeDrv] (
			[AllowAllCountryRecords],
			[AllowCodeAdds] ,
			[AllowDeletes] ,
			[AllowInserts] ,
			[AllowWebCodeAdds] ,
			[AllowWebCodeDeletes] ,
			[AllowWebCodeEdits] ,
			[AltCodeField] ,
			[AuditAction],
			[CodeEditMask] ,
			[CodeField] ,
			[CodeIndexTag] ,
			[CodeLength] ,
			[CodeTable] ,
			[CountryCodeFieldName] ,
			[DatabaseName] ,
			[DescField] ,
			[DescLength] ,
			[Description] ,
			[DisplayInAll] ,
			[DisplayInAT] ,
			[DisplayInDev] ,
			[DisplayInDotNet] ,
			[DisplayInHR] ,
			[DisplayInPR] ,
			[DisplayInSystem],
			[DisplayInWeb] ,
			[DisplayMode] ,
			[InputFormName] ,
			[ModifyStampFieldName] ,
			[PageTypeID] ,
			[RangeFieldName] ,
			[RangeValue] ,
			[SqlStatement] ,
			[TableName],
			[UpcAllowBlankLookups] ,
			[UpcExcCodeTableColumnName] ,
			[UpcExtCodeTableName] ,
			[UpcHelpContext] ,
			[UpcHelpFileName] ,
			[UpcIsSystemFieldName] ,
			[UpcUnitID],
			[UseOrdering] ,
			[UseRange] ,
			[UseSql] ,
			[WebDescription]
		) VALUES (
			'N',			-- AllowAllCountryRecords
			'Y',			-- AllowCodeAdds
			'N',			-- AllowCodeDeletes
			'Y',			-- AllowCodeInserts
			@VisibleInWeb,	-- AllowWebCodeAdds
			@VisibleInWeb,	-- AllowWebCodeDeletes
			@VisibleInWeb,	-- AllowWebCodeEdits
			NULL,			-- AltCodeField
			NULL,			-- AuditAction
			@CodeEditMask,	-- CodeEditMask
			'CodCode',		-- CodeField
			'CodCode',		-- CodeIndexTag
			@CodeLength,	-- CodeLength
			@CodeTableName,	-- CodeTable
			'*',			-- CountryCodeFieldName
			'Company',		-- DatabaseName
			'CodDesc',		-- DescField
			@DescriptionLength,	-- DescLength
			@CodeTableDescription,	-- Description
			'N',			-- DisplayInAll
			'N',			-- DisplayInAT
			'N',			-- DisplayInDev
			'1',			-- DisplayInDotNet
			'Y',			-- DisplayInHR
			'N',			-- DisplayInPR
			'N',			-- DisplayInSystem
			@VisibleInWeb,	-- DisplayInWeb
			'D',			-- DisplayMode
			'FORM_CODEDESC',	-- InputFormName
			'CodModifyStamp',	-- ModifyStampFieldName
			'0',			-- PageTypeID
			'CodTable',		-- RangeFieldName
			@CodeTableName,	-- RangeValue
			'',				-- SqlStatement
			'Codes',		-- TableName
			NULL,			-- UpcAllowBlankLookups
			NULL,			-- UpcExcCodeTableColumnName
			NULL,			-- UpcExtCodeTableName
			5000,			-- UpcHelpContext
			NULL,			-- UpcHelpFileName
			'CodSystem',	-- UpcIsSystemFieldName
			NULL,			-- UpcUnitID
			0,				-- UseOrdering
			'Y',			-- UseRange
			'N',			-- UseSql
			@CodeTableWebDescription	-- WebDescription
		)

			PRINT 'Added CodeTable: ' + @CodeTableName
		
	END

END
GO

-- Add the CodeTable entries, using temporary utility procedure

EXEC dbo.ConsultingServices_AddCodeTable
	@CodeTableName           = 'U_FPI1000_ABSENCERESTRICTION',
	@CodeTableDescription    = 'Absences and Restrictions',
	@CodeTableWebDescription = 'Define Absences and Restrictions',
	@CodeLength              = 15,
	@VisibleInWeb            = 'Y'

GO

-- Clean up - Drop temporary utility procedure
IF OBJECT_ID('dbo.ConsultingServices_AddCodeTable') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.ConsultingServices_AddCodeTable
END
GO

IF OBJECT_ID('dbo.ConsultingServices_AddCodeTable') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.ConsultingServices_AddCodeTableRecords
END
GO

-- Create temporary utility procedure
CREATE PROCEDURE dbo.ConsultingServices_AddCodeTableRecords (
	@Code					CHAR(15),
	@Description				VARCHAR(45),
	@CodeTableName          VARCHAR(50)
) AS
BEGIN
	IF NOT EXISTS(SELECT 1 FROM Codes (NOLOCK) WHERE CodCode = @Code AND CodTable = @CodeTableName)
	BEGIN
		INSERT INTO Codes
		(CodCode,CodDesc,CodTable)
		SELECT @Code,@Description,@CodeTableName
	END
END

EXEC dbo.ConsultingServices_AddCodeTableRecords
	@Code = 'A',
	@Description = 'Absence',
	@CodeTableName = 'U_FPI1000_ABSENCERESTRICTION'
GO

EXEC dbo.ConsultingServices_AddCodeTableRecords
	@Code = 'R',
	@Description = 'Restriction',
	@CodeTableName = 'U_FPI1000_ABSENCERESTRICTION'
GO

IF OBJECT_ID('dbo.ConsultingServices_AddCodeTable') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.ConsultingServices_AddCodeTableRecords
END
GO

/*
-- UNDO:
DELETE FROM dbo.Codes WHERE codTable = 'U_ELIGIBLECONFIG1'
DELETE FROM [dbo].[CoUpCdeDrv] WHERE [CodeTable] = 'U_ELIGIBLECONFIG1'
*/
