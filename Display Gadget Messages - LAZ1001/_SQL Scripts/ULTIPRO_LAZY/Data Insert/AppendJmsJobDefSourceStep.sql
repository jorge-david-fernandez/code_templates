----------------------------------------------------------------------------------------------------------------------
-- Company:		  Ultimate Software Corp. 
-- Author:		  Adrian Serrano
-- Client:		  Lazy Dog Restaurants, LLC
-- Date:		  12/19/2019
-- Request:		  SR-2019-00245269
-- Purpose:		  Instant Pay Direct Deposit (from scope project SR-2019-00233967)
-- Last Modified: 
-----------------------------------------------------------------------------------------------------------------------

GO
-- Drop temporary utility procedure if had been left out there
IF EXISTS (SELECT 1 FROM SysObjects WHERE id = Object_ID('dbo.U_ConsultingServices_AppendJmsJobDefSourceStep') AND ObjectProperty(id,'IsProcedure')=1)
BEGIN
	DROP PROCEDURE dbo.U_ConsultingServices_AppendJmsJobDefSourceStep
END
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE dbo.U_ConsultingServices_AppendJmsJobDefSourceStep (
	@JobDefCode    VARCHAR(16)  ,
	@AssemblyName  VARCHAR(255) ,
	@TypeName      VARCHAR(255) ,
	@MethodName    VARCHAR(255)
) AS
BEGIN

	SET NOCOUNT ON

	DECLARE 
		@NewStepNum      INT,
		@LastStepNum     INT,
		@strNewStepNum   VARCHAR(5),
		@strLastStepNum  VARCHAR(5),
		@NewStepXML      VARCHAR(1000),
		@JobDefSource    VARCHAR(8000),
		@SearchPhrase    VARCHAR(1000)

	DECLARE
		@PosEndExecutionDetails  INT,
		@LenJobDefSource         INT

	SET @SearchPhrase = '%' + @AssemblyName + '%' + @MethodName + '%'

	IF NOT EXISTS (
		SELECT 1 FROM dbo.JmsJobDefSource (NoLock)
		WHERE JobDefCode = @JobDefCode
		  AND CONVERT(VARCHAR(8000),JobDefSource) LIKE @SearchPhrase
	) BEGIN

		SELECT @strLastStepNum = CAST(JobDefSource.query('data(//@Order)[last()]') AS VARCHAR(5))
		  FROM dbo.JmsJobDefSource (NoLock)
		 WHERE JobDefCode = @JobDefCode

		SELECT @JobDefSource = CAST(JobDefSource AS VARCHAR(8000))
		  FROM dbo.JmsJobDefSource (NoLock)
		 WHERE JobDefCode = @JobDefCode

		SET @LastStepNum = CAST(@strLastStepNum AS INT)

		SET @NewStepNum = @LastStepNum + 1

		SET @strNewStepNum = CAST(@NewStepNum AS VARCHAR(5))
 
		SET @NewStepXML =
			 '<ExecutionStep Order="[[@NewStepNum]]">
			   <AssemblyName>[[@AssemblyName]]</AssemblyName>
			   <TypeName>[[@TypeName]]</TypeName>
			   <MethodName>[[@MethodName]]</MethodName>
			 </ExecutionStep>'
	         
		SET @NewStepXML = REPLACE(@NewStepXML, '[[@NewStepNum]]'  , @strNewStepNum)
		SET @NewStepXML = REPLACE(@NewStepXML, '[[@AssemblyName]]', @AssemblyName )
		SET @NewStepXML = REPLACE(@NewStepXML, '[[@TypeName]]'    , @TypeName     )
		SET @NewStepXML = REPLACE(@NewStepXML, '[[@MethodName]]'  , @MethodName   )

		SET @PosEndExecutionDetails = CHARINDEX('</ExecutionDetails>', @JobDefSource)

		SET @LenJobDefSource = LEN(@JobDefSource)

		SET @JobDefSource = SUBSTRING(@JobDefSource, 1, @PosEndExecutionDetails - 1)
		                  + @NewStepXML
		                  + SUBSTRING(@JobDefSource, @PosEndExecutionDetails, @LenJobDefSource)

		UPDATE dbo.JmsJobDefSource
		   SET JobDefSource = @JobDefSource
		 WHERE JobDefCode = @JobDefCode

		PRINT 'Appended custom step "' + @AssemblyName + ' - ' + @MethodName + '" to JobDefCode "' + @JobDefCode + '"'
		
	END

END
GO

IF (SELECT is_quoted_identifier_on FROM sys.databases (NOLOCK) WHERE [name] = (SELECT db_name())) = 0
  SET QUOTED_IDENTIFIER OFF
ELSE
  SET QUOTED_IDENTIFIER ON

GO



EXEC dbo.U_ConsultingServices_AppendJmsJobDefSourceStep
		@JobDefCode   = 'EmployeeAdd',
		@AssemblyName = 'UltimateSoftware.Customs.ONB.LAZ1001_Integration',    ---ktp this is assembly name 
		@TypeName     = 'UltimateSoftware.Customs.ONB.LAZ1001_Integration.CustomDataFacade',  ----in the CustomData Facads.cs
		@MethodName   = 'SetCustomData'    ---in the CustomData Facads.cs

GO

-- Discard temporary utility procedure
IF EXISTS (SELECT 1 FROM SysObjects WHERE id = Object_ID('dbo.U_ConsultingServices_AppendJmsJobDefSourceStep') AND ObjectProperty(id,'IsProcedure')=1)
BEGIN
	DROP PROCEDURE dbo.U_ConsultingServices_AppendJmsJobDefSourceStep
END
GO

