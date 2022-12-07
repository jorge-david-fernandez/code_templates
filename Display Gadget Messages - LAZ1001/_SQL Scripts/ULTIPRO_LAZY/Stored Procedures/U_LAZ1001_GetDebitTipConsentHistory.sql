----------------------------------------------------------------------------------------------------------------------
-- Company:		  Ultimate Software Corp. 
-- Author:		  Adrian Serrano
-- Client:		  Lazy Dog Restaurants, LLC
-- Date:		  1/28/2020
-- Request:		  SR-2019-00245269
-- Purpose:		  Instant Pay Direct Deposit (from scope project SR-2019-00233967)
-- Last Modified: 
-----------------------------------------------------------------------------------------------------------------------

IF OBJECT_ID(N'[dbo].[U_LAZ1001_GetDebitTipConsentHistory]') IS NOT NULL  
DROP PROCEDURE [dbo].[U_LAZ1001_GetDebitTipConsentHistory] 
GO

CREATE PROCEDURE [dbo].[U_LAZ1001_GetDebitTipConsentHistory]
	@EEID CHAR(12),
	@COID CHAR(5),  
	@WhereClause	nvarchar(max) = null,
	@OrderBy		nvarchar(max) = null		-- need for Gridview Data Source to not abort but don't need to use it
AS
BEGIN
		

	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET NOCOUNT ON

	DECLARE @SQL		     varchar(max)

	SET @SQL = '
	SELECT U_LAZ1001_EmpDebitTipConsent.udaRecID, udaDateSigned, udaConsentType, udaAcknowledge, udaInitials, udaConsentMessage
	FROM U_LAZ1001_EmpDebitTipConsent (NOLOCK)
	JOIN U_LAZ1001_DebitTipConsentMessage (NOLOCK) DTC ON udaTextID = DTC.udaRecID
	WHERE udaEEID = ''' + @EEID + '''
	AND udaCOID = ''' + @COID + ''''

	IF ( isNull(@WhereClause,'') != '' )
	BEGIN
		SET @SQL = @SQL + ' AND ' + @WhereClause 
	END
	
	IF ( isNull(@OrderBy,'') != '' )
	BEGIN
		SET @SQL = @SQL + ' ORDER BY ' + @OrderBy
	END
	
--  PRINT @SQL

	EXEC(@SQL)
END
GO