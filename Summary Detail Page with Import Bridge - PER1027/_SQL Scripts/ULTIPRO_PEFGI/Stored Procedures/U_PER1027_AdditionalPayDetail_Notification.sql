DROP PROCEDURE IF EXISTS [dbo].[U_PER1027_AdditionalPayDetail_Notification]
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].U_PER1027_AdditionalPayDetail_Notification
	@LastRunDate DATETIME = NULL,
	@Debug BIT = 0
AS
----------------------------------------------------------------------------------------------------------------------
-- Company:		  UKG 
-- Author:		  Jorge Fernandez
-- Client:		  Performance Food Group, Inc.
-- Date:		  10/31/2022
-- Request:		  SR-2022-00377312
-- Purpose:		  Custom Web Page for Additional Pay Detail
-- Last Modified: 
-----------------------------------------------------------------------------------------------------------------------
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET NOCOUNT ON

	DECLARE @ConfigurationId INT
	DECLARE @Message VARCHAR(MAX)
	DECLARE @Subject VARCHAR(200)
	DECLARE @Recipients VARCHAR(200)
	DECLARE @ErrorStatus INT = 4


	SET @Recipients = 'jorge.fernandez@ukg.com'-- a semi-colon delimited list of email addresses
	SET @Subject = 'Additional Pay Detail Import Error Notification'

	IF (@@SERVERNAME IN ('nz1d222db01','e2d222db01'))
	BEGIN
		IF (@@SERVERNAME IN ('nz1d222db01')) BEGIN
			SET @Subject = @Subject + ' - TEST ENVIRONMENT' + ' - ' + LEFT(@@SERVERNAME, 3)
		END
		IF (@@SERVERNAME IN ('e2d222db01')) BEGIN
			SET @Recipients = 'Michael.forget@pfgc.com'
		END
	END
	ELSE IF @Debug = 0
	BEGIN
		RETURN --Email doesn't work in rCloud
	END
	SELECT @ConfigurationId = ConfigurationId
		FROM dbo.Bridge_Configuration WITH (NOLOCK)
			WHERE BridgeName = 'Additional Pay Detail Import'

	IF ISNULL(@ConfigurationId, 0) > 0
	BEGIN
		IF @LastRunDate IS NULL
		BEGIN
			--Get the last time the job ran 
			SELECT @LastRunDate = MAX(msdb.DBO.AGENT_DATETIME(RUN_DATE, RUN_TIME))
			FROM msdb.dbo.SYSJOBS SJ 
			LEFT OUTER JOIN msdb.dbo.SYSJOBHISTORY JH ON SJ.job_id = JH.job_id
			WHERE SJ.name = 'U_PER1027_AdditionalPayDetailBridgeNotif' AND JH.step_id = 0 AND jh.run_status = 1
			--If we still don't have a date set it a day ago		
			IF @LastRunDate IS NULL
			BEGIN
				SET @LastRunDate = DATEADD(DAY, -1, GETDATE())
			END
		END

		IF NOT EXISTS (SELECT 1 
		               FROM dbo.Bridge_StagingRecord WITH (NOLOCK)
					   WHERE ConfigurationId = @ConfigurationId AND Status = @ErrorStatus AND DateCreated >= @LastRunDate) BEGIN
			--Dont have any records to report so exit
			RETURN
		END

		SET @Message = '<html><head><style>
							table { border-collapse: collapse; }
							h1, th {
								background-color: #ececec;
								color: #5a5a5a;	
							}
							h1 { padding: 5px 10px; }
							th, td {
								text-align: left;
								padding: 2px 8px;
							}
							table, td, th { border: 1px solid gray; }
							</style></head><body>'
					
		SET @Message = @Message + '<h1 style="padding: 5px 10px;">Additional Pay Detail Import Exceptions</h1>'
	
		SET @Message = @Message + '<p>The following Additional Pay Detail Import records failed to be imported into the system.</p>'
		SET @Message = @Message + '<p>To see further details go to the "Administration > Integration Studio > Bridge > Bridge Results" menu area.</p>'
	
		SET @Message = @Message + '<table><thead><tr><th>Employee Number</th><th>Pay Date</th><th>Week End Date</th><th>Description</th><th>Action indicator</th><th>Exceptions</th></tr></thead>'
		SET @Message = @Message + '<tbody>'

		SELECT @Message = @Message + '<tr>' 
								   + '<td>' + [EmployeeNumber] + '</td>'
								   + '<td>' + [PayDate] + '</td>'
								   + '<td>' + [WeekEndDate] + '</td>'
								   + '<td>' + [Description] + '</td>'
								   + '<td>' + [ActionIndicator] + '</td>'
								   + '<td>' + ErrorMessages + '</td>'
								   + '</tr>'
		FROM  
		(	SELECT s.StagingId, s.Source, fvd.FinalFieldValue, f.Name
			FROM dbo.Bridge_StagingRecord s WITH (NOLOCK)
			LEFT JOIN dbo.Bridge_MappedFieldValueData fvd WITH (NOLOCK) ON fvd.StagingId = s.StagingId
			LEFT JOIN dbo.Bridge_InputField f WITH (NOLOCK) ON f.InputFieldId = fvd.InputFieldId
			WHERE s.ConfigurationId = @ConfigurationId AND s.Status = @ErrorStatus AND s.DateCreated >= @LastRunDate) AS SourceTable  
		PIVOT  
		(  
		MIN(FinalFieldValue)  
		FOR Name IN ([EmployeeNumber], [PayDate], [WeekEndDate], [Description], [ActionIndicator])  
		) AS s
		LEFT JOIN (
		SELECT s.StagingId, 
			STUFF((
			SELECT '<br/>' + [Message]
			FROM dbo.Bridge_Log l WITH (NOLOCK) 
			WHERE l.StagingId = s.StagingId
			FOR XML PATH(''),TYPE).value('(./text())[1]','VARCHAR(MAX)')
		  ,1,5,'') AS ErrorMessages
		FROM dbo.Bridge_StagingRecord s WITH (NOLOCK)
		WHERE s.ConfigurationId = @ConfigurationId AND s.Status = @ErrorStatus
		GROUP BY s.StagingId
		) AS Msg ON msg.StagingId = s.StagingId

		SET @Message = @Message + '</tbody></table></body></html>'

		-- Send the email
		IF @Recipients <> '' AND @Debug = 0
		BEGIN
			EXEC msdb.dbo.sp_Send_DBMail
					@Recipients	= @Recipients,
					@Body		= @Message,
					@Subject	= @Subject,
					@Profile_Name = 'usgsqlmail',
					@body_format = 'HTML'
		END
	END
	IF @Debug = 1
	BEGIN
		SELECT @Message
	END
END
GO