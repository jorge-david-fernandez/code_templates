----------------------------------------------------------------------------------------------------------------------
-- Company:		  UKG 
-- Author:		  Jorge Fernandez
-- Client:		  Performance Food Group, Inc.
-- Date:		  10/31/2022
-- Request:		  SR-2022-00377312
-- Purpose:		  Custom Web Page for Additional Pay Detail
-- Last Modified: 
-----------------------------------------------------------------------------------------------------------------------
DECLARE
    @JobName    VARCHAR(500),
    @StepName   VARCHAR(500),
    @Command    VARCHAR(500),
    @JobDesc    VARCHAR(200),
    @Database   VARCHAR(500),
    @Server     VARCHAR(500),
    @User       VARCHAR(20),
    @Owner      VARCHAR(20),
    @ReturnCode INT,
    @JobID      UNIQUEIDENTIFIER

SET NOCOUNT ON
SET XACT_ABORT ON

SELECT
    @JobName    = 'U_PER1027_AdditionalPayDetailBridgeNotif',
    @JobDesc    = 'PER1027-AdditionalPayDetail Bridge Notifications',
    @Command    = N'EXEC dbo.U_PER1027_AdditionalPayDetail_Notification',
    @Database   = DB_Name(),
    @Server     = @@ServerName,
    @User       = 'dbo',
    @Owner      = 'sa'

-- Does Job already exists?

IF EXISTS (SELECT 1 FROM msdb..sysjobs WHERE NAME = @JobName) BEGIN
    PRINT 'Job [' + @JobName + '] already exists, did not need to create.'
    GOTO Finished
END

BEGIN TRANSACTION

-- Add Job

EXEC @ReturnCode = msdb.dbo.sp_add_job 
    @job_id             = @JobID OUTPUT,
    @job_name           = @JobName, 
    @description        = @JobDesc,
    @owner_login_name   = @Owner

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
    @job_name           = @JobName      , 
    @step_id            = 1             ,
    @step_name          = @StepName     ,
    @command            = @Command      ,
    @database_name      = @Database

IF (@@ERROR <> 0 OR @ReturnCode <> 0) BEGIN
    ROLLBACK TRANSACTION
    PRINT 'Unable to add job step 1.'
    GOTO Finished
END

EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule 
    @job_name           = @JobName, 
    @name               = @JobName, 
    @enabled            = 1, 
    @freq_type          = 4,        -- means "Daily"
    @freq_interval      = 1,        -- every 1 day(s), i.e. every day
    @freq_subday_type   = 1,        -- "1" means "at the specified time"   ("4" means "at an interval of every X number of minutes")
    @freq_subday_interval = 0,      -- "0" means "does not apply for this subday_type"  (If subday_type were "4", put the number of interval minutes, e.g. 10 for run every 10 minutes)
    @active_start_time  = 51015,    -- 5:10:15am.  Slightly after 5am.  On purpose we choose a random time slightly after 5, since other jobs are all queued up to run at exactly 5am.
    @active_end_time    = 235959    -- 11:59pm.  Actually, for subday_type=1, end_time is meaningless, any value would do
        
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