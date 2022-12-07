
IF OBJECT_ID(N'[dbo].[U_LAZ1001_GetDebitTipConsentHistoryDetails]') IS NOT NULL  
DROP PROCEDURE [dbo].[U_LAZ1001_GetDebitTipConsentHistoryDetails] 
GO

----------------------------------------------------------------------------------------------------------------------
-- Company:		  UKG 
-- Author:		  JORGE FERNANDEZ
-- Client:		  Lazy Dog Restaurants, LLC
-- Date:		  8/2/2021
-- Request:		  SR-2021-00313265
-- Purpose:		  Update Web - Custom Screen for Direct Deposit Process
-- Last Modified: 
-----------------------------------------------------------------------------------------------------------------------

CREATE PROCEDURE [dbo].U_LAZ1001_GetDebitTipConsentHistoryDetails
	@EEID CHAR(12),
	@COID CHAR(5),  
	@RecId INT,
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
	AND udaCOID = ''' + @COID + '''
	AND U_LAZ1001_EmpDebitTipConsent.udaRecID = ' + CAST(@RecId AS VARCHAR(50)) 

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

