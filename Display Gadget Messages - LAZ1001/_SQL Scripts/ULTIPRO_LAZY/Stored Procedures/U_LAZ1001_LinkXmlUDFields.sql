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
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[U_LAZ1001_LinkXmlUDFields]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[U_LAZ1001_LinkXmlUDFields]

GO

CREATE PROCEDURE [dbo].[U_LAZ1001_LinkXmlUDFields]
	@PendHireSystemID	INT,
	@eecUdField01		CHAR(10),
	@eecUdField11		CHAR(10),
	@eecUdField12		CHAR(10),
	@eecUdField14		VARCHAR(25),
	@eecUdField15		VARCHAR(25),
	@eecUdField21		CHAR(1),
	@eecUdField22		CHAR(1),
	@eecUdField23		CHAR(1),
	@eecUdField24		CHAR(1),
	@eepUdField01		CHAR(25),
	@VaccineStatus		VARCHAR(100),
	@PC1				VARCHAR(100),
	@PC3				VARCHAR(100),
	@PC4				VARCHAR(100),
	@PC5				VARCHAR(100),
	@PC6				VARCHAR(100),
	@PC7				VARCHAR(100),
	@PC8				VARCHAR(100),
	@PC9				VARCHAR(100)
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM U_LAZ1001_OnboardingFieldValues WHERE onb_PendHireSystemID = @PendHireSystemID)
	BEGIN
		INSERT INTO [dbo].[U_LAZ1001_OnboardingFieldValues] ([onb_PendHireSystemID],[onb_FieldNameID],[onb_FieldValue])
		VALUES (@PendHireSystemID,'eecUdField01',@eecUdField01)
		INSERT INTO [dbo].[U_LAZ1001_OnboardingFieldValues] ([onb_PendHireSystemID],[onb_FieldNameID],[onb_FieldValue])
		VALUES (@PendHireSystemID,'eecUdField11',@eecUdField11)
		INSERT INTO [dbo].[U_LAZ1001_OnboardingFieldValues] ([onb_PendHireSystemID],[onb_FieldNameID],[onb_FieldValue])
		VALUES (@PendHireSystemID,'eecUdField12',@eecUdField12)
		INSERT INTO [dbo].[U_LAZ1001_OnboardingFieldValues] ([onb_PendHireSystemID],[onb_FieldNameID],[onb_FieldValue])
		VALUES (@PendHireSystemID,'eecUdField14',@eecUdField14)
		INSERT INTO [dbo].[U_LAZ1001_OnboardingFieldValues] ([onb_PendHireSystemID],[onb_FieldNameID],[onb_FieldValue])
		VALUES (@PendHireSystemID,'eecUdField15',@eecUdField15)
		INSERT INTO [dbo].[U_LAZ1001_OnboardingFieldValues] ([onb_PendHireSystemID],[onb_FieldNameID],[onb_FieldValue])
		VALUES (@PendHireSystemID,'eecUdField21',@eecUdField21)
		INSERT INTO [dbo].[U_LAZ1001_OnboardingFieldValues] ([onb_PendHireSystemID],[onb_FieldNameID],[onb_FieldValue])
		VALUES (@PendHireSystemID,'eecUdField22',@eecUdField22)
		INSERT INTO [dbo].[U_LAZ1001_OnboardingFieldValues] ([onb_PendHireSystemID],[onb_FieldNameID],[onb_FieldValue])
		VALUES (@PendHireSystemID,'eecUdField23',@eecUdField23)
		INSERT INTO [dbo].[U_LAZ1001_OnboardingFieldValues] ([onb_PendHireSystemID],[onb_FieldNameID],[onb_FieldValue])
		VALUES (@PendHireSystemID,'eecUdField24',@eecUdField24)
		INSERT INTO [dbo].[U_LAZ1001_OnboardingFieldValues] ([onb_PendHireSystemID],[onb_FieldNameID],[onb_FieldValue])
		VALUES (@PendHireSystemID,'eepUdField01',@eepUdField01)
		-- DCD 11/15/2021 SR-2021-00335777
		INSERT INTO [dbo].[U_LAZ1001_OnboardingFieldValues] ([onb_PendHireSystemID],[onb_FieldNameID],[onb_FieldValue])
		VALUES (@PendHireSystemID,'VaccineStatus',@VaccineStatus)
		INSERT INTO [dbo].[U_LAZ1001_OnboardingFieldValues] ([onb_PendHireSystemID],[onb_FieldNameID],[onb_FieldValue])
		VALUES (@PendHireSystemID,'PC1',@PC1)
		INSERT INTO [dbo].[U_LAZ1001_OnboardingFieldValues] ([onb_PendHireSystemID],[onb_FieldNameID],[onb_FieldValue])
		VALUES (@PendHireSystemID,'PC3',@PC3)
		INSERT INTO [dbo].[U_LAZ1001_OnboardingFieldValues] ([onb_PendHireSystemID],[onb_FieldNameID],[onb_FieldValue])
		VALUES (@PendHireSystemID,'PC4',@PC4)
		INSERT INTO [dbo].[U_LAZ1001_OnboardingFieldValues] ([onb_PendHireSystemID],[onb_FieldNameID],[onb_FieldValue])
		VALUES (@PendHireSystemID,'PC5',@PC5)
		INSERT INTO [dbo].[U_LAZ1001_OnboardingFieldValues] ([onb_PendHireSystemID],[onb_FieldNameID],[onb_FieldValue])
		VALUES (@PendHireSystemID,'PC6',@PC6)
		INSERT INTO [dbo].[U_LAZ1001_OnboardingFieldValues] ([onb_PendHireSystemID],[onb_FieldNameID],[onb_FieldValue])
		VALUES (@PendHireSystemID,'PC7',@PC7)
		INSERT INTO [dbo].[U_LAZ1001_OnboardingFieldValues] ([onb_PendHireSystemID],[onb_FieldNameID],[onb_FieldValue])
		VALUES (@PendHireSystemID,'PC8',@PC8)
		INSERT INTO [dbo].[U_LAZ1001_OnboardingFieldValues] ([onb_PendHireSystemID],[onb_FieldNameID],[onb_FieldValue])
		VALUES (@PendHireSystemID,'PC9',@PC9)
		-- DCD 11/15/2021 SR-2021-00335777
	END
	
END

GO
