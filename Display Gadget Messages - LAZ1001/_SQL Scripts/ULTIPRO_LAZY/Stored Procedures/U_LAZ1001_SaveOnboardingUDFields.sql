----------------------------------------------------------------------------------------------------------------------
-- Company:		  Ultimate Software Corp. 
-- Author:		  Adrian Serrano
-- Client:		  Lazy Dog Restaurants, LLC
-- Date:		  12/19/2019
-- Request:		  SR-2019-00245269
-- Purpose:		  Instant Pay Direct Deposit (from scope project SR-2019-00233967)
-- Last Modified: 12/1/2021 David Domenico SR-2021-00335777
-----------------------------------------------------------------------------------------------------------------------

GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[U_LAZ1001_SaveOnboardingUDFields]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[U_LAZ1001_SaveOnboardingUDFields]

GO

CREATE PROCEDURE [dbo].[U_LAZ1001_SaveOnboardingUDFields]
	@JOBID	INT,
	@SSN	CHAR(12),
	@COID	CHAR(5)
AS
BEGIN
    DECLARE @EEID CHAR(12)
    DECLARE @JobDefCode VARCHAR(16)

	DECLARE @phSystemID	int		
	DECLARE @xml XML
	DECLARE @valueCheck VARCHAR(25)	
	
    -- Sanity check - confirm correct JobDefCode
    SELECT 
        @JobDefCode = JobDefCode
    FROM dbo.JmsJob (NoLock) 
    WHERE JobID = @JobID

    IF (@JobDefCode NOT IN ('EmployeeAdd','ProcessHires')) BEGIN
        RETURN
    END

	SELECT @EEID = eepEEID
      FROM dbo.EmpPers (NoLock)
     WHERE eepSSN = @SSN
    
    SELECT TOP 1 @phSystemID = phSystemID, @xml = CAST(CAST(phSupplDataXML AS NVARCHAR(MAX)) AS XML)
    FROM dbo.PendHire (NoLock)
	WHERE RTRIM(phSSN) = RTRIM(REPLACE(@SSN, '-', ''))
	ORDER BY phPXImportDate DESC

	
	SELECT @valueCheck = eecUdField01 FROM EmpComp WHERE EecEEID = @EEID AND EecCoID = @COID
	IF (@valueCheck IS NULL or @valueCheck = '') -- Value was not updated from wizard
	BEGIN
		UPDATE EmpComp
		SET eecUdField01 = (SELECT onb_FieldValue FROM U_LAZ1001_OnboardingFieldValues WHERE onb_PendHireSystemID = @phSystemID AND  onb_FieldNameID = 'eecUdField01')
		WHERE eecEEID = @EEID
		AND eecCOID = @COID
	END
	
	SELECT @valueCheck = eecUdField11 FROM EmpComp WHERE EecEEID = @EEID AND EecCoID = @COID
	IF (@valueCheck IS NULL or @valueCheck = '') -- Value was not updated from wizard
	BEGIN
		UPDATE EmpComp
		SET eecUdField11 = (SELECT onb_FieldValue FROM U_LAZ1001_OnboardingFieldValues WHERE onb_PendHireSystemID = @phSystemID AND  onb_FieldNameID = 'eecUdField11')
		WHERE eecEEID = @EEID
		AND eecCOID = @COID
	END

	SELECT @valueCheck = eecUdField12 FROM EmpComp WHERE EecEEID = @EEID AND EecCoID = @COID
	IF (@valueCheck IS NULL or @valueCheck = '') -- Value was not updated from wizard
	BEGIN
		UPDATE EmpComp
		SET eecUdField12 = (SELECT onb_FieldValue FROM U_LAZ1001_OnboardingFieldValues WHERE onb_PendHireSystemID = @phSystemID AND  onb_FieldNameID = 'eecUdField12')
		WHERE eecEEID = @EEID
		AND eecCOID = @COID
	END

	SELECT @valueCheck = eecUdField14 FROM EmpComp WHERE EecEEID = @EEID AND EecCoID = @COID
	IF (@valueCheck IS NULL or @valueCheck = '') -- Value was not updated from wizard
	BEGIN
		UPDATE EmpComp
		SET eecUdField14 = (SELECT onb_FieldValue FROM U_LAZ1001_OnboardingFieldValues WHERE onb_PendHireSystemID = @phSystemID AND  onb_FieldNameID = 'eecUdField14')
		WHERE eecEEID = @EEID
		AND eecCOID = @COID
	END

	SELECT @valueCheck = eecUdField15 FROM EmpComp WHERE EecEEID = @EEID AND EecCoID = @COID
	IF (@valueCheck IS NULL or @valueCheck = '') -- Value was not updated from wizard
	BEGIN
		UPDATE EmpComp
		SET eecUdField15 = (SELECT onb_FieldValue FROM U_LAZ1001_OnboardingFieldValues WHERE onb_PendHireSystemID = @phSystemID AND  onb_FieldNameID = 'eecUdField15')
		WHERE eecEEID = @EEID
		AND eecCOID = @COID
	END

	SELECT @valueCheck = eecUdField21 FROM EmpComp WHERE EecEEID = @EEID AND EecCoID = @COID
	IF (@valueCheck IS NULL or @valueCheck = '') -- Value was not updated from wizard
	BEGIN
		UPDATE EmpComp
		SET eecUdField21 = (SELECT onb_FieldValue FROM U_LAZ1001_OnboardingFieldValues WHERE onb_PendHireSystemID = @phSystemID AND  onb_FieldNameID = 'eecUdField21')
		WHERE eecEEID = @EEID
		AND eecCOID = @COID
	END

	SELECT @valueCheck = eecUdField22 FROM EmpComp WHERE EecEEID = @EEID AND EecCoID = @COID
	IF (@valueCheck IS NULL or @valueCheck = '') -- Value was not updated from wizard
	BEGIN
		UPDATE EmpComp
		SET eecUdField22 = (SELECT onb_FieldValue FROM U_LAZ1001_OnboardingFieldValues WHERE onb_PendHireSystemID = @phSystemID AND  onb_FieldNameID = 'eecUdField22')
		WHERE eecEEID = @EEID
		AND eecCOID = @COID
	END

	SELECT @valueCheck = eecUdField23 FROM EmpComp WHERE EecEEID = @EEID AND EecCoID = @COID
	IF (@valueCheck IS NULL or @valueCheck = '') -- Value was not updated from wizard
	BEGIN
		UPDATE EmpComp
		SET eecUdField23 = (SELECT onb_FieldValue FROM U_LAZ1001_OnboardingFieldValues WHERE onb_PendHireSystemID = @phSystemID AND  onb_FieldNameID = 'eecUdField23')
		WHERE eecEEID = @EEID
		AND eecCOID = @COID
	END

	SELECT @valueCheck = eecUdField24 FROM EmpComp WHERE EecEEID = @EEID AND EecCoID = @COID
	IF (@valueCheck IS NULL or @valueCheck = '') -- Value was not updated from wizard
	BEGIN
		UPDATE EmpComp
		SET eecUdField24 = (SELECT onb_FieldValue FROM U_LAZ1001_OnboardingFieldValues WHERE onb_PendHireSystemID = @phSystemID AND  onb_FieldNameID = 'eecUdField24')
		WHERE eecEEID = @EEID
		AND eecCOID = @COID
	END

	SELECT @valueCheck = eepUdField01 FROM EmpPers WHERE EepEEID = @EEID
	IF (@valueCheck IS NULL or @valueCheck = '') -- Value was not updated from wizard
	BEGIN
		UPDATE EmpPers
		SET eepUdField01 = (SELECT onb_FieldValue FROM U_LAZ1001_OnboardingFieldValues WHERE onb_PendHireSystemID = @phSystemID AND  onb_FieldNameID = 'eepUdField01')
		WHERE eepEEID = @EEID
	END

	-- DCD SR-2021-00335777 BEGIN
	DECLARE @VaccinationStatus VARCHAR (100)
	DECLARE @PC1 VARCHAR (100)
	DECLARE @PC3 VARCHAR (100)
	DECLARE @PC4 VARCHAR (100)
	DECLARE @PC5 VARCHAR (100)
	DECLARE @PC6 VARCHAR (100)
	DECLARE @PC7 VARCHAR (100)
	DECLARE @PC8 VARCHAR (100)
	DECLARE @PC9 VARCHAR (100)

	SELECT @VaccinationStatus = onb_FieldValue FROM U_LAZ1001_OnboardingFieldValues WHERE onb_PendHireSystemID = @phSystemID AND  onb_FieldNameID = 'VaccineStatus'
	IF LEN(ISNULL(@VaccinationStatus, '')) > 0 BEGIN
		EXEC u_LAZ1001_Import_ConfigurableFields_SaveSingleValue @EEID, @COID, 'Employee', 'VaccinationStatus', @VaccinationStatus, 'STRING', 1;
	END

	SELECT @PC1 = onb_FieldValue FROM U_LAZ1001_OnboardingFieldValues WHERE onb_PendHireSystemID = @phSystemID AND  onb_FieldNameID = 'PC1'
	IF LEN(ISNULL(@PC1,'')) > 0 BEGIN
		EXEC u_LAZ1001_Import_ConfigurableFields_SaveSingleValue @EEID, @COID, 'Employee', 'PC1', @PC1, 'STRING', 1;
	END

	SELECT @PC3 = onb_FieldValue FROM U_LAZ1001_OnboardingFieldValues WHERE onb_PendHireSystemID = @phSystemID AND  onb_FieldNameID = 'PC3'
	IF LEN(ISNULL(@PC3,'')) > 0 BEGIN
		EXEC u_LAZ1001_Import_ConfigurableFields_SaveSingleValue @EEID, @COID, 'Employee', 'PC3', @PC3, 'STRING', 1;
	END

	SELECT @PC4 = onb_FieldValue FROM U_LAZ1001_OnboardingFieldValues WHERE onb_PendHireSystemID = @phSystemID AND  onb_FieldNameID = 'PC4'
	IF LEN(ISNULL(@PC4,'')) > 0 BEGIN
		EXEC u_LAZ1001_Import_ConfigurableFields_SaveSingleValue @EEID, @COID, 'Employee', 'PC4', @PC4, 'STRING', 1;
	END

	SELECT @PC5 = onb_FieldValue FROM U_LAZ1001_OnboardingFieldValues WHERE onb_PendHireSystemID = @phSystemID AND  onb_FieldNameID = 'PC5'
	IF LEN(ISNULL(@PC5,'')) > 0 BEGIN
		EXEC u_LAZ1001_Import_ConfigurableFields_SaveSingleValue @EEID, @COID, 'Employee', 'PC5', @PC5, 'STRING', 1;
	END

	SELECT @PC6 = onb_FieldValue FROM U_LAZ1001_OnboardingFieldValues WHERE onb_PendHireSystemID = @phSystemID AND  onb_FieldNameID = 'PC6'
	IF LEN(ISNULL(@PC6,'')) > 0 BEGIN
		EXEC u_LAZ1001_Import_ConfigurableFields_SaveSingleValue @EEID, @COID, 'Employment', 'PC6', @PC6, 'STRING', 1;
		EXEC sp_usg_CopyMetaFieldValuesToEmploymentHistory @EEID, @COID
	END

	SELECT @PC7 = onb_FieldValue FROM U_LAZ1001_OnboardingFieldValues WHERE onb_PendHireSystemID = @phSystemID AND  onb_FieldNameID = 'PC7'
	IF LEN(ISNULL(@PC7,'')) > 0 BEGIN
		EXEC u_LAZ1001_Import_ConfigurableFields_SaveSingleValue @EEID, @COID, 'Employment', 'PC7', @PC7, 'STRING', 1;
		EXEC sp_usg_CopyMetaFieldValuesToEmploymentHistory @EEID, @COID
	END

	SELECT @PC8 = onb_FieldValue FROM U_LAZ1001_OnboardingFieldValues WHERE onb_PendHireSystemID = @phSystemID AND  onb_FieldNameID = 'PC8'
	IF LEN(ISNULL(@PC8,'')) > 0 BEGIN
		EXEC u_LAZ1001_Import_ConfigurableFields_SaveSingleValue @EEID, @COID, 'Employment', 'PC8', @PC8, 'STRING', 1;
		EXEC sp_usg_CopyMetaFieldValuesToEmploymentHistory @EEID, @COID
	END

	SELECT @PC9 = onb_FieldValue FROM U_LAZ1001_OnboardingFieldValues WHERE onb_PendHireSystemID = @phSystemID AND  onb_FieldNameID = 'PC9'
	IF LEN(ISNULL(@PC9,'')) > 0 BEGIN
		EXEC u_LAZ1001_Import_ConfigurableFields_SaveSingleValue @EEID, @COID, 'Person', 'PC9', @PC9, 'STRING', 1;
	END
	-- DCD SR-2021-00335777 END

	EXEC U_LAZ1001_DefaultElectronicCopies @EEID
END

GO
