
----------------------------------------------------------------------------------------------------------------------
-- Company:		  Ultimate Software Corp. 
-- Author:		  Jorge David Fernandez
-- Client:		  Genesco Inc.
-- Date:		  1/4/2017
-- Request:		  SR-2016-00137430
-- Purpose:		  Custom Web Page to Manage Translation Table for Position Key Export
-- Last Modified: 
-----------------------------------------------------------------------------------------------------------------------

DELETE [dbo].[CoUpCdeDrv] WHERE CodeTable = 'U_GENES_COUNTRY'

INSERT INTO [dbo].[CoUpCdeDrv]
           ([AllowAllCountryRecords]
           ,[AllowCodeAdds]
           ,[AllowDeletes]
           ,[AllowInserts]
           ,[AllowWebCodeAdds]
           ,[AllowWebCodeDeletes]
           ,[AllowWebCodeEdits]
           ,[AuditAction]
           ,[CodeEditMask]
           ,[CodeField]
           ,[CodeIndexTag]
           ,[CodeLength]
           ,[CodeTable]
           ,[CountryCodeFieldName]
           ,[DatabaseName]
           ,[DescField]
           ,[DescLength]
           ,[Description]
           ,[DisplayInAll]
           ,[DisplayInAT]
           ,[DisplayInDev]
           ,[DisplayInHR]
           ,[DisplayInPR]
           ,[DisplayInSystem]
           ,[DisplayInWeb]
           ,[DisplayMode]
           ,[InputFormName]
           ,[ModifyStampFieldName]
           ,[RangeFieldName]
           ,[RangeValue]
           ,[SqlStatement]
           ,[TableName]
           ,[UpcAllowBlankLookups]
           ,[UpcExcCodeTableColumnName]
           ,[UpcExtCodeTableName]
           ,[UpcHelpContext]
           ,[UpcHelpFileName]
           ,[UpcIsSystemFieldName]
           ,[UpcUnitID]
           ,[UseOrdering]
           ,[UseRange]
           ,[UseSql]
           ,[WebDescription])
     VALUES
           ('N'
           ,'N'
           ,'N'
           ,'N'
           ,'N'
           ,'N'
           ,'N'
           ,NULL
           ,'>a;0;'
           ,'Code'
           ,NULL
           ,6.000000
           ,'U_GENES_COUNTRY'
           ,'*'
           ,'Company'
           ,'Description'
           ,50.000000
           ,'Country Codes'
           ,'N'
           ,'N'
           ,'N'
           ,'N'
           ,'N'
           ,'N'
           ,'N'
           ,'D'
           ,NULL
           ,NULL
           ,NULL
           ,NULL
           ,'U_GENES_GetCountry'
           ,'#SP'
           ,NULL
           ,NULL
           ,NULL
           ,NULL
           ,NULL
           ,NULL
           ,NULL
           ,0
           ,'N'
           ,'Y'
           ,'Country Codes')

SELECT * FROM [dbo].[CoUpCdeDrv]
WHERE CodeTable = 'U_GENES_COUNTRY'
