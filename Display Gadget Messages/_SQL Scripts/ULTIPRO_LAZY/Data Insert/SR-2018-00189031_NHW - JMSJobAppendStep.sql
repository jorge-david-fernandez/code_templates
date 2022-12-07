----------------------------------------------------------------------------------------------------------------------
-- Company:		  Ultimate Software Corp. 
-- Author:		  Gayle Velazquez
-- Client:		  Lazy Dog Restaurants, LLC
-- Date:		  3/12/2018
-- Request:		  SR-2018-00189031
-- Purpose:		  Default Pay Statement Preference to Electronic copies only
-- Last Modified: 
-----------------------------------------------------------------------------------------------------------------------

SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UpdateJMSjobDefSource]') AND type in (N'P', N'PC'))
BEGIN
	DROP PROCEDURE dbo.UpdateJMSjobDefSource
END
GO

CREATE PROCEDURE dbo.UpdateJMSjobDefSource
	@jobDefCode    VARCHAR(16)  ,
	@AssemblyName  VARCHAR(255) ,
	@TypeName      VARCHAR(255) ,
	@MethodName    VARCHAR(255) ,
	@InsertBeforeMethod   VARCHAR(255) = NULL
AS
BEGIN
	DECLARE @InsertOrder INT
	DECLARE @CustomOrder INT
	DECLARE @LastOrder INT

	IF NOT EXISTS(SELECT 1 
					FROM JMSjobDefSource (NOLOCK)
					WHERE jobDefCode = @jobDefCode
					AND CAST(jobDefSource AS VARCHAR(8000)) LIKE ('%' + @AssemblyName + '%' + @MethodName + '%'))
	BEGIN
		SELECT @LastOrder = 
			CAST (CAST(jobDefSource.query('data(//@Order)[last()]') AS VARCHAR(5)) AS INT)
			FROM JMSjobDefSource (NOLOCK)
			WHERE jobDefCode = @jobDefCode

		IF (@InsertBeforeMethod IS NOT NULL AND @InsertBeforeMethod <> '')
		BEGIN
			SELECT @CustomOrder = 
				CAST(jobDefSource.query('//ExecutionStep[MethodName = sql:variable("@InsertBeforeMethod")]').value ('(/ExecutionStep/@Order)[1]', 'VARCHAR(5)') AS INT)
				FROM JMSjobDefSource (NOLOCK)
				WHERE jobDefCode = @jobDefCode
			
			SET @InsertOrder = @CustomOrder + 1
			
			IF @LastOrder >= @CustomOrder BEGIN
				DECLARE @NextOrder INT
				DECLARE @NewOrder INT
				SET @NextOrder = @LastOrder
				While @NextOrder >= @CustomOrder
				BEGIN
					
					SET @NewOrder = @NextOrder + 1
					UPDATE dbo.JMSjobDefSource
						SET  jobDefSource.modify('replace value of (//ExecutionStep[@Order=(sql:variable("@NextOrder"))]/@Order)[1] with sql:variable("@NewOrder")')
						WHERE jobDefCode = @jobDefCode
					SET @NextOrder = @NextOrder - 1
				END       
			END
			
			--Insert Custom Step before given core step
			UPDATE JMSjobDefSource 
			SET jobDefSource.modify('
				insert 
				<ExecutionStep Order="{sql:variable("@CustomOrder")}">
					<AssemblyName>{sql:variable("@AssemblyName")}</AssemblyName>
					<TypeName>{sql:variable("@TypeName")}</TypeName>
					<MethodName>{sql:variable("@MethodName")}</MethodName>
				</ExecutionStep>
				before (/ProcessInfo/ExecutionDetails//ExecutionStep[@Order=(sql:variable("@InsertOrder"))])[1]')
			WHERE jobDefCode = @jobDefCode
		END
		ELSE
		BEGIN
			SET @InsertOrder = @LastOrder
			SET @CustomOrder = @LastOrder + 1
			
			--Insert Custom Step as last step
			UPDATE JMSjobDefSource 
			SET jobDefSource.modify('
				insert 
				<ExecutionStep Order="{sql:variable("@CustomOrder")}">
					<AssemblyName>{sql:variable("@AssemblyName")}</AssemblyName>
					<TypeName>{sql:variable("@TypeName")}</TypeName>
					<MethodName>{sql:variable("@MethodName")}</MethodName>
				</ExecutionStep>
				after (/ProcessInfo/ExecutionDetails//ExecutionStep[@Order=(sql:variable("@InsertOrder"))])[1]')
			WHERE jobDefCode = @jobDefCode
		END
	END
END
GO

---------------------------------------------------------------
-- SCRIPT - ADD JOB STEPS
---------------------------------------------------------------

EXEC dbo.UpdateJMSjobDefSource
		@jobDefCode   = 'EmployeeAdd',
		@AssemblyName = 'UltimateSoftware.Customs.LAZ1001.SR00245269',
		@TypeName     = 'UltimateSoftware.Customs.LAZ1001.BPCustomSteps.NewHireStepFacade',
		@MethodName   = 'SetCustomValuesNewHire'

		
EXEC dbo.UpdateJMSjobDefSource
		@jobDefCode   = 'ProcessHires',
		@AssemblyName = 'UltimateSoftware.Customs.LAZ1001.SR00245269',
		@TypeName     = 'UltimateSoftware.Customs.LAZ1001.BPCustomSteps.NewHireStepFacade',
		@MethodName   = 'SetCustomValuesNewHire'
		

---------------------------------------------------------------
-- UTILITY Stored Procedure - CLEANUP
---------------------------------------------------------------

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UpdateJMSjobDefSource]') AND type in (N'P', N'PC'))
BEGIN
	DROP PROCEDURE dbo.UpdateJMSjobDefSource
END
GO