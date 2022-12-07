----------------------------------------------------------------------------------------------------------------------
-- Company:		  Ultimate Software Corp. 
-- Author:		  Jorge David Fernandez
-- Client:		  Lazy Dog Restaurants, LLC
-- Date:		  10/4/2019
-- Request:		  SR-2019-00245269
-- Purpose:		  Instant Pay Direct Deposit (from scope project SR-2019-00233967)
-- Last Modified: 
-----------------------------------------------------------------------------------------------------------------------

DECLARE
	@JobName	VARCHAR(500),
	@StepName	VARCHAR(500),
	@Command	VARCHAR(500),
	@JobDesc	VARCHAR(120),
	@Database	VARCHAR(500),
	@Server		VARCHAR(500),
	@User		VARCHAR(20),
	@Owner		VARCHAR(20),
	@ReturnCode	INT,
	@JobID		UNIQUEIDENTIFIER

SET NOCOUNT ON
SET XACT_ABORT ON

SELECT
	@JobName	= 'U_LAZ1001_SetDirectDepositsActiveJob',
	@JobDesc	= 'Set Direct Deposits Active',
	@Command	= 'EXEC [dbo].[U_LAZ1001_SetDirectDepositsActive]',
	@Database	= DB_Name(),
	@Server		= @@ServerName,
	@User		= 'dbo',
	@Owner		= 'sa'

-- Does Job already exists?

IF EXISTS (SELECT 1 FROM msdb..sysjobs WHERE NAME = @JobName) BEGIN
	PRINT 'Job [' + @JobName + '] already exists, did not need to create.'
	GOTO Finished
END

BEGIN TRANSACTION

-- Add Job

EXEC @ReturnCode = msdb.dbo.sp_add_job 
	@job_id				= @JobID OUTPUT,
	@job_name			= @JobName, 
	@description		= @JobDesc,
    @owner_login_name	= @Owner

IF (@@ERROR <> 0 OR @ReturnCode <> 0) BEGIN
	ROLLBACK TRANSACTION
	PRINT 'Unable to add job'
	GOTO Finished
END

-- Define which Server to run Job on.... add for local server

EXEC @ReturnCode = msdb.dbo.sp_add_jobserver
	@job_name    = @JobName

IF (@@ERROR <> 0 OR @ReturnCode <> 0) BEGIN
	ROLLBACK TRANSACTION
	PRINT 'Unable to add job server.'
	GOTO Finished
END

-- Define command to run (as Step 1)

SET @StepName = @JobName + ' - Step 1'

EXEC @ReturnCode = msdb.dbo.sp_add_jobstep
	@job_name			= @JobName		, 
	@step_id			= 1				,
	@step_name			= @StepName		,
	@command			= @Command		,
	@database_name		= @Database

IF (@@ERROR <> 0 OR @ReturnCode <> 0) BEGIN
	ROLLBACK TRANSACTION
	PRINT 'Unable to add job step 1.'
	GOTO Finished
END

EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule 
	@job_name			= @JobName, 
	@name				= @JobName, 
	@enabled			= 1, 
	@freq_type			= 4,		-- means "Daily"
	@freq_interval		= 1,		-- every 1 day(s), i.e. every day
	@freq_subday_type	= 1,		-- At specified time
	@freq_subday_interval = 0,		-- 
	@active_start_time	= 230000,	-- 10PM. 
	@active_end_time    = 235959    		

IF (@@ERROR <> 0 OR @ReturnCode <> 0) BEGIN
	ROLLBACK TRANSACTION
	PRINT 'Unable to add job schedule.'
	GOTO Finished
END

COMMIT TRANSACTION
PRINT 'Successfully added job [' + @JobName + ']'

-----------------------------------
Finished:

PRINT 'Done'

GO
