DROP PROCEDURE IF EXISTS [dbo].[U_PER1027_AdditionalPayDetail_Summary]
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.U_PER1027_AdditionalPayDetail_Summary
	@EEID CHAR(12) = NULL,
	@COID CHAR (5) = NULL,
	@WhereClause	NVARCHAR(MAX) = NULL,
	@OrderBy		NVARCHAR(MAX) = NULL,
	@page_size int = 20,  
	@page_number int = 1
AS
----------------------------------------------------------------------------------------------------------------------
-- Company:		  UKG 
-- Author:		  Jorge Fernandez
-- Client:		  Performance Food Group, Inc.
-- Date:		  11/2/2022
-- Request:		  SR-2022-00377312
-- Purpose:		  Custom Web Page for Additional Pay Detail
-- Last Modified: 
-----------------------------------------------------------------------------------------------------------------------
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET NOCOUNT ON

	DECLARE @SQL NVARCHAR(MAX)

	SET @SQL = 'SET NOCOUNT ON;'+CHAR(10)+CHAR(13)+
	'WITH ResultSet AS (
		SELECT ROW_NUMBER() OVER (ORDER BY ' + COALESCE(@OrderBy,'uapPayDate DESC') + ' ) as rownum, res.*
		FROM(
		SELECT DISTINCT CAST(uapPayDate AS DATE) AS uapPayDate
		FROM dbo.U_PER1027_AddlPayDetail (NOLOCK)
		JOIN dbo.EmpComp (NOLOCK) ON eecEmpNo = uapEmpNo 
		WHERE eecEEID  = ''' + @EEID + '''
		AND eecCOID = ''' + @COID + ''''
		+ COALESCE(' AND ' + @WhereClause,'')
		+ ') as res)
		SELECT ResultSet.*,
			[MaxNo] = (SELECT COUNT(1) FROM ResultSet)
		FROM ResultSet		
		WHERE (rownum > @page_size * (@page_number-1) AND rownum <= (@page_size * @page_number) ) 
		ORDER BY rownum'

	--PRINT @SQL

	EXEC sp_executesql @SQL, N'@page_number int, @page_size int', @page_size = @page_size, @page_number = @page_number
	--exec U_PER1027_AdditionalPayDetail_Summary @FinancialSystem='OPR   ',@OrgLvl='3',@WhereClause=default,@OrderBy=N'uoxUKGValue ',@page_size=20,@page_number=1
END
GO
