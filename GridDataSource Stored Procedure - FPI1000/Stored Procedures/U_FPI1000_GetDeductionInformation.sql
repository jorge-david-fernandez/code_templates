IF OBJECT_ID(N'[dbo].[U_FPI1000_GetDeductionInformation]' ) IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[U_FPI1000_GetDeductionInformation] 
END
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE dbo.U_FPI1000_GetDeductionInformation (
	@EEID			CHAR(12),
	@COID			CHAR(5),
	@WhereClause	VARCHAR(1000) = NULL,
	@OrderBy		VARCHAR(1000) = NULL
) AS
BEGIN
	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	CREATE TABLE #tblDeductionInformation (
		SystemID			CHAR(12),
		EEID				CHAR(12),
		COID				CHAR(5),
		DedCode				CHAR(5),
		BenStatus			CHAR(1),
		StartDate			DATETIME,
		StopDate			DATETIME,
		EELstAmt			MONEY,
		EEMTDAmt			MONEY,
		EEQTDAmt			MONEY,
		EEYTDAmt			MONEY,
		EEAmt				MONEY,
		ERLstAmt			MONEY,
		ERMTDAmt			MONEY,
		ERQTDAmt			MONEY,
		ERYTDAmt			MONEY,
		EECalcRateOrPct		DECIMAL(16,6),
		EECalcRule			CHAR(2),
		BenAmtRateOrPct		DECIMAL(16,6),
		BenAmtCalcRule		CHAR(2),
		BenAmt				MONEY,
		Notes_Note			VARCHAR(MAX),
		DedGroupCode		CHAR(5),
		DateLastPayDatePaid DATETIME,
		PayPeriod			CHAR(1),
		IsDedOffSet			CHAR(1),
		DedType				CHAR(4),
		DedIsBenefit		CHAR(1),
		DedLongDesc			VARCHAR(40),
		UsePrimaryCarePhysician	CHAR(1),
		HideManagerView		CHAR(1),
		DedEECalcRateOrPct	DECIMAL(16,6),
		DedEECalcRule		CHAR(2),
		EEUseEERate			CHAR(1),
		EEUseEERule			CHAR(1),
		EEBenAmt			MONEY,
		DedBenAmtCalcRule	CHAR(2),
		DedBenAmtRateOrPct	DECIMAL(16,6),
		EEWeeklyAmt			MONEY,
		EEBiWeeklyAmt		MONEY,
		EESemiMonthlyAmt	MONEY,
		EEMonthlyAmt		MONEY,
		TaxCategory			CHAR(6),
		DedAdminFeeCode		CHAR(5),
		DedTypeDesc			VARCHAR(25),
		UseBeneficiary		CHAR(1),
		UseDependent		CHAR(1),
		AllowBenAmtChg		CHAR(1)
	)

	DECLARE @SqlStmt VARCHAR(1000)

	INSERT #tblDeductionInformation (
		SystemID,
		EEID,
		COID,
		DedCode,
		BenStatus,
		StartDate,
		StopDate,
		EELstAmt,
		EEMTDAmt,
		EEQTDAmt,
		EEYTDAmt,
		EEAmt,
		ERLstAmt,
		ERMTDAmt,
		ERQTDAmt,
		ERYTDAmt,
		EECalcRateOrPct,
		EECalcRule,
		BenAmtRateOrPct,
		BenAmtCalcRule,
		BenAmt,
		Notes_Note,
		DedGroupCode,
		DateLastPayDatePaid,
		PayPeriod,
		IsDedOffSet,
		DedType,
		DedIsBenefit,
		DedLongDesc,
		UsePrimaryCarePhysician,
		HideManagerView,
		DedEECalcRateOrPct,
		DedEECalcRule,
		EEUseEERate,
		EEUseEERule,
		EEBenAmt,
		DedBenAmtCalcRule,
		DedBenAmtRateOrPct,
		EEWeeklyAmt,
		EEBiWeeklyAmt,
		EESemiMonthlyAmt,
		EEMonthlyAmt,
		TaxCategory,
		DedAdminFeeCode,
		DedTypeDesc,
		UseBeneficiary,
		UseDependent,
		AllowBenAmtChg
	) SELECT
		ED.EedSystemID,	
		ED.eedEEID,		
		ED.eedCOID,			
		ED.eedDedCode,
		ED.eedBenStatus,
		ED.eedStartDate,
		ED.eedStopDate,
		ED.eedEELstAmt,
		EP.eedEEMTDAmt,
		EP.eedEEQTDAmt,
		EP.eedEEYTDAmt,
		ED.eedEEAmt,
		ED.eedERLstAmt,
		EP.eedERMTDAmt,
		EP.eedERQTDAmt,
		EP.eedERYTDAmt,
		ED.eedEECalcRateOrPct,
		ED.eedEECalcRule,
		ED.eedBenAmtRateOrPct,
		ED.eedBenAmtCalcRule,
		ED.eedBenAmt,
		ED.eedNotes,
		eecDedGroupCode,
		eecDateLastPayDatePaid,
		eecPayPeriod,
		dedIsDedOffSet,
		dedDedType,
		dedIsBenefit,
		dedLongDesc,
		dedUsePrimaryCarePhysician,
		DedHideManagerView,
		DedEECalcRateOrPct,
		DedEECalcRule,
		DedEEUseEERate,
		DedEEUseEERule,
		DedEEBenAmt,
		DedBenAmtCalcRule,
		DedBenAmtRateOrPct,
		DedEEWeeklyAmt,
		DedEEBiweeklyAmt,
		DedEESemiMonthlyAmt,
		DedEEMonthlyAmt,
		DedTaxCategory,
		DedAdminFeeCode,
		CdtDedTypeDesc,
		CdtUseBeneficiary,
		CdtUseDependent,
		CdtAllowBenAmtChg
	FROM dbo.EmpDed [ED] (NoLock)
	JOIN dbo.EmpDedPg [EP] (NoLock) ON ED.EedCoID = EP.EedCoID AND ED.eedEEID = EP.eedEEID AND ED.EedDedCode = EP.EedDedCode
	JOIN dbo.EmpComp (NoLock) ON EmpComp.eecEEID = ED.eedEEID AND EmpComp.EecCoID = ED.EedCoID
	JOIN dbo.DedCode (NOLOCK) ON DedCode.DedDedCode = ED.EedDedCode
	JOIN dbo.DedType (NOLOCK) ON DedType.CdtDedTypeCode = DedCode.DedDedType
	WHERE ED.eedEEID = @EEID
	AND ED.eedCOID = @COID 

	SET @SqlStmt = 'SELECT '
	             + '  * '
	             + 'FROM #tblDeductionInformation '

	IF (LEN(ISNULL(@WhereClause,'')) > 0) BEGIN
		SET @SqlStmt = @SqlStmt + ' WHERE ' + @WhereClause
	END

	IF (LEN(ISNULL(@OrderBy,'')) > 0) BEGIN
		SET @SqlStmt = @SqlStmt + ' ORDER BY ' + @OrderBy
	END

	EXEC(@SqlStmt)
END
GO