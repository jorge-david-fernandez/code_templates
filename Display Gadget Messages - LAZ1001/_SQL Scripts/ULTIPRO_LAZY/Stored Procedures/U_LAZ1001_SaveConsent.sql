----------------------------------------------------------------------------------------------------------------------
-- Company:		  Ultimate Software Corp. 
-- Author:		  Jorge David Fernandez
-- Client:		  Lazy Dog Restaurants, LLC
-- Date:		  1/28/2020
-- Request:		  SR-2019-00245269
-- Purpose:		  Instant Pay Direct Deposit (from scope project SR-2019-00233967)
-- Last Modified: 
-----------------------------------------------------------------------------------------------------------------------

IF OBJECT_ID(N'[dbo].[U_LAZ1001_SaveConsent]') IS NOT NULL  
DROP PROCEDURE [dbo].[U_LAZ1001_SaveConsent]
GO

CREATE PROCEDURE dbo.U_LAZ1001_SaveConsent
	@EEID CHAR(12),
	@COID CHAR(5),
	@ConsentType VARCHAR(50),
	@DebitTip varchar(50),
	@ConsentAnswer CHAR(1),
	@Initials VARCHAR(50)
AS
BEGIN
	IF NOT EXISTS(SELECT 1
		FROM U_LAZ1001_DebitTipConsentMessage (NOLOCK)
		JOIN Content (NOLOCK) ON udaConsentMessage = cntText
		JOIN ContentBox (NOLOCK) ON udaConsentMessage = ctbTitle
		WHERE cntTitle = @ConsentType)
	BEGIN
		DECLARE @ConsentMessage VARCHAR(MAX)

		SELECT @ConsentMessage = cntText
		FROM Content (NOLOCK)
		WHERE cntTitle = @ConsentType

		IF NULLIF(@ConsentMessage,'') IS NULL
		BEGIN
			SELECT @ConsentMessage = ctbTitle
			FROM ContentBox (NOLOCK)
			WHERE ctbTitle = @ConsentType
		END

		INSERT INTO U_LAZ1001_DebitTipConsentMessage
		(udaConsentMessage)
		SELECT @ConsentMessage
	END

	IF (@DebitTip = 'Debit')
	BEGIN
		UPDATE EmpComp
		SET EecUDField21 = @ConsentAnswer
		WHERE EecEEID = @EEID AND EecCoID = @COID
	END
	IF (@DebitTip = 'TIP')
	BEGIN
		UPDATE EmpComp
		SET EecUDField22 = @ConsentAnswer
		WHERE EecEEID = @EEID AND EecCoID = @COID
	END
	IF (@DebitTip = 'MealWaiver1')
	BEGIN
		UPDATE EmpComp
		SET EecUDField24 = @ConsentAnswer
		WHERE EecEEID = @EEID AND EecCoID = @COID
	END
	IF (@DebitTip = 'MealWaiver2')
	BEGIN
		UPDATE EmpComp
		SET EecUDField23 = @ConsentAnswer
		WHERE EecEEID = @EEID AND EecCoID = @COID
	END

	/*
	INSERT INTO U_LAZ1001_EmpDebitTipConsent
	(udaEEID,udaCOID,udaAcknowledge,udaDateSigned,udaInitials,udaConsentType,udaTextID)
	SELECT @EEID,@COID,'Y',GETDATE(),@Initials,@ConsentType,(SELECT udaRecID
		FROM U_LAZ1001_DebitTipConsentMessage (NOLOCK)
		LEFT JOIN Content (NOLOCK) ON cntText = udaConsentMessage
		LEFT JOIN ContentBox (NOLOCK) ON ctbTitle = udaConsentMessage
		WHERE cntTitle = @ConsentType
		OR ctbTitle = @ConsentType)
	*/
	INSERT INTO U_LAZ1001_EmpDebitTipConsent (udaEEID,udaCOID,udaAcknowledge,udaDateSigned,udaInitials,udaConsentType,udaTextID)
		SELECT @EEID,@COID,'Y',GETDATE(),@Initials,@ConsentType,(SELECT TOP 1 udaRecID
																	FROM dbo.ContentBox WITH (NoLock)
																	JOIN dbo.Content WITH (NoLock) ON cntContentBoxID = ctbContentBoxID
																	JOIN dbo.U_LAZ1001_DebitTipConsentMessage WITH (NoLock) ON udaConsentMessage = cntText
																	WHERE cntTitle = @ConsentType
																	ORDER BY cntUpdateDate)
END
GO
