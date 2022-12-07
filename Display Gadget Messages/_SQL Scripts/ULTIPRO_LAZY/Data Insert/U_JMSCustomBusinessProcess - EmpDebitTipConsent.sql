----------------------------------------------------------------------------------------------------------------------
-- Company:		  Ultimate Software Corp. 
-- Author:		  Adrian Serrano
-- Client:		  Lazy Dog Restaurants, LLC
-- Date:		  1/28/2020
-- Request:		  SR-2019-00245269
-- Purpose:		  Instant Pay Direct Deposit (from scope project SR-2019-00233967)
-- Last Modified: 
-----------------------------------------------------------------------------------------------------------------------
/*
Last Modified By: David Swait - 08/11/2015
Last Modified Reason: MDUU error on CTE.
Msg 547, Level 16, State 0, Procedure SetupJMS, Line 22
The DELETE statement conflicted with the REFERENCE constraint "FK_jobdef1_fk12". 
The conflict occurred in database "ULTIPRO_JMFAM", table "dbo.JMSJobWFLink", column 'jobDefCode'.
Coming from DELETE statement in SetupJMS.
*/
------------------------------------------------------------------------------------
-- Step 1 - Create Workflow Script - 01 - SetupJMS
------------------------------------------------------------------------------------

--------------------------------
-- UTILITY PROCEDURE
--------------------------------

IF EXISTS (SELECT 1 FROM SysObjects WHERE id=Object_ID('dbo.SetupJMS') AND ObjectProperty(id,'IsProcedure')=1)
BEGIN
	DROP PROCEDURE dbo.SetupJMS
END
GO

CREATE PROCEDURE dbo.SetupJMS (
	@ID           VARCHAR(16),
	@Description  VARCHAR(250),
	@Assembly     VARCHAR(100),
	@FacadeType   VARCHAR(100),
	@SaveMethod   VARCHAR(100),
	@DeleteIfCan  CHAR(1) = 'N'
) AS
BEGIN

	SET NOCOUNT ON
	
	BEGIN TRANSACTION
	
	IF (@DeleteIfCan = 'Y')
	BEGIN
		IF NOT EXISTS (SELECT 1 FROM dbo.JmsJob (NoLock) WHERE JobDefCode = @ID)
		BEGIN
			--Not sure why the following line was commented out as not having it causes a MDUU error. Added back by David Swait 08/11/2015.
			DELETE dbo.JmsJobWFLink WHERE jobDefCode = @ID		-- DCW/MARTAS 06/26/13 Added, found to be needed if dropping JmsJobDef after workflow setup created for it
			DELETE dbo.JmsJobDefSource WHERE JobDefCode = @ID
			DELETE dbo.JmsJobDef WHERE JobDefCode = @ID
			PRINT 'Deleted JmsJobWFLink and JmsJobDef and JmsJobDefSource for: ' + @ID
		END
	END

	IF NOT EXISTS (SELECT 1 FROM dbo.JmsJobDef (NoLock) WHERE JobDefCode = @ID)
	BEGIN
		INSERT INTO dbo.JmsJobDef (jobdefcode, jobdefdescription, display, isSystem)
		VALUES (@ID, @Description, 0, 'N')
		PRINT 'Added JmsJobDef for: ' + @ID
	END

	IF NOT EXISTS (SELECT 1 FROM dbo.JmsJobDefSource (NoLock) WHERE JobDefCode = @ID)
	BEGIN
		INSERT INTO dbo.JmsJobDefSource (
			jobdefcode, 
			jobdefversion, 
			categoryid, 
			priorityid, 
			WorkflowAllowed, 
			isSystem)
		VALUES (
			@ID,	
			'1',	-- jobdefversion
			1, 		-- categoryID
			1, 		-- priorityID
			0,		-- workflowallowed
			'N'		-- isSystem
		)
		PRINT 'Added JmsJobDefSource for: ' + @ID
	END

	UPDATE dbo.JmsJobDefSource 
	   SET jobdefsource = '<ProcessInfo><Description>' + @Description + '</Description><Document>Custom Document</Document><ExecutionDetails><ExecutionStep Order="1"><AssemblyName>'+ @Assembly +'</AssemblyName><TypeName>'+@FacadeType+'</TypeName><MethodName>' + @SaveMethod +'</MethodName></ExecutionStep></ExecutionDetails></ProcessInfo>'
	WHERE jobdefcode = @ID

	COMMIT TRANSACTION

END
GO

-------------------------------------------------------------
-- THE ACTUAL SCRIPT - Client Specific
-------------------------------------------------------------

EXEC dbo.SetupJMS
	@ID          = 'U_LAZ1001Consent',
	@Description = 'Pay Consent Settings',
	@FacadeType  = 'UltimateSoftware.Customs.LAZ1001.Facade.EmpDebitTipConsentFacade',
	@Assembly    = 'UltimateSoftware.Customs.LAZ1001.SR00245269',
	@SaveMethod  = 'SetEmpDebitTipConsent',
	@DeleteIfCan = 'Y'

--------------------------------
-- CLEANUP
--------------------------------

IF EXISTS (SELECT 1 FROM SysObjects WHERE id=Object_ID('dbo.SetupJMS') AND ObjectProperty(id,'IsProcedure')=1)
BEGIN
	DROP PROCEDURE dbo.SetupJMS
END
GO

------------------------------------------------------------------------------------
-- Step 2 - Create Workflow Script - 02 - SetupWorflow (RuleSet)
------------------------------------------------------------------------------------

IF OBJECT_ID('dbo.CustomWorkflows_RulesetTemplate') IS NOT NULL
BEGIN
	DROP FUNCTION dbo.CustomWorkflows_RulesetTemplate
END
GO

CREATE FUNCTION dbo.CustomWorkflows_RulesetTemplate(
	@CategoriesToInclude VARCHAR(100)	-- pass in comma-delimited list of catories, e.g. "ESS,MSS,EEADM" or just "MSS,EEADM".
) RETURNS VARCHAR(MAX) AS
BEGIN

	/*
	This creates a RuleSet template for some or all of following rules, depending on which categories have been requested.
	
		EE-Add-1
		EE-Change-2
		EE-Delete-3
		
		MANGR-Add-4
		MANGR-Change-5
		MANGR-Delete-6

		ADMIN-Add-7
		ADMIN-Change-8
		ADMIN-Delete-9
		
	*/
	
	------------------------------------------
	-- Declare and Initialize
	------------------------------------------
	
	DECLARE
		@RuleSet        VARCHAR(MAX),
		@RuleSetESS     VARCHAR(MAX),
		@RuleSetMSS     VARCHAR(MAX),
		@RuleSetEEADM   VARCHAR(MAX),
		@RuleSetHeader  VARCHAR(MAX),
		@RuleSetTrailer VARCHAR(MAX),
		@TestCategories VARCHAR(100),
		@IncludeESS     CHAR(1),
		@IncludeMSS     CHAR(1),
		@IncludeEEADM   CHAR(1)
	
	SET @TestCategories = ',' + REPLACE(@CategoriesToInclude, ' ', '') + ','
	
	SELECT
		@IncludeESS = 'N',
		@IncludeMSS = 'N',
		@IncludeEEADM = 'N'
	
	IF (CHARINDEX(',ESS,',@TestCategories) > 0) OR (CHARINDEX(',EE,',@TestCategories) > 0) BEGIN
		SET @IncludeESS = 'Y'
	END
	
	IF (CHARINDEX(',MSS,',@TestCategories) > 0) OR (CHARINDEX(',MANGR,',@TestCategories) > 0) BEGIN
		SET @IncludeMSS = 'Y'
	END
	
	IF (CHARINDEX(',EEADM,',@TestCategories) > 0) OR (CHARINDEX(',ADMIN,',@TestCategories) > 0) BEGIN
		SET @IncludeEEADM = 'Y'
	END
	
	------------------------------------------
	-- Ruleset Template - ESS
	------------------------------------------
	
	SET @RuleSetESS = '
    <Rule Name="EE-Add-1" ReevaluationBehavior="Always" Priority="1" Description="{p1:Null}" Active="True">
      <Rule.ThenActions>
        <RuleStatementAction>
          <RuleStatementAction.CodeDomStatement>
            <ns0:CodeAssignStatement xmlns:ns0="clr-namespace:System.CodeDom;Assembly=System, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" LinePragma="{p1:Null}">
              <ns0:CodeAssignStatement.Left>
                <ns0:CodePropertyReferenceExpression PropertyName="Result">
                  <ns0:CodePropertyReferenceExpression.TargetObject>
                    <ns0:CodeThisReferenceExpression />
                  </ns0:CodePropertyReferenceExpression.TargetObject>
                </ns0:CodePropertyReferenceExpression>
              </ns0:CodeAssignStatement.Left>
              <ns0:CodeAssignStatement.Right>
                <ns0:CodePrimitiveExpression>
                  <ns0:CodePrimitiveExpression.Value>
                    <ns1:String xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">EMPLOYEEBPDID</ns1:String>
                  </ns0:CodePrimitiveExpression.Value>
                </ns0:CodePrimitiveExpression>
              </ns0:CodeAssignStatement.Right>
            </ns0:CodeAssignStatement>
          </RuleStatementAction.CodeDomStatement>
        </RuleStatementAction>
      </Rule.ThenActions>
      <Rule.Condition>
        <RuleExpressionCondition Name="{p1:Null}">
          <RuleExpressionCondition.Expression>
            <ns0:CodeBinaryOperatorExpression xmlns:ns0="clr-namespace:System.CodeDom;Assembly=System, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" Operator="BooleanAnd">
              <ns0:CodeBinaryOperatorExpression.Left>
                <ns0:CodeBinaryOperatorExpression Operator="BooleanAnd">
                  <ns0:CodeBinaryOperatorExpression.Left>
                    <ns0:CodeBinaryOperatorExpression Operator="BooleanAnd">
                      <ns0:CodeBinaryOperatorExpression.Left>
                        <ns0:CodeBinaryOperatorExpression Operator="IdentityInequality">
                          <ns0:CodeBinaryOperatorExpression.Left>
                            <ns0:CodeMethodInvokeExpression>
                              <ns0:CodeMethodInvokeExpression.Parameters>
                                <ns0:CodePrimitiveExpression>
                                  <ns0:CodePrimitiveExpression.Value>
                                    <ns1:String xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">UltimateSoftware.Notifications.InitiatedFor</ns1:String>
                                  </ns0:CodePrimitiveExpression.Value>
                                </ns0:CodePrimitiveExpression>
                              </ns0:CodeMethodInvokeExpression.Parameters>
                              <ns0:CodeMethodInvokeExpression.Method>
                                <ns0:CodeMethodReferenceExpression MethodName="GetBusinessObjectByType">
                                  <ns0:CodeMethodReferenceExpression.TargetObject>
                                    <ns0:CodeThisReferenceExpression />
                                  </ns0:CodeMethodReferenceExpression.TargetObject>
                                </ns0:CodeMethodReferenceExpression>
                              </ns0:CodeMethodInvokeExpression.Method>
                            </ns0:CodeMethodInvokeExpression>
                          </ns0:CodeBinaryOperatorExpression.Left>
                          <ns0:CodeBinaryOperatorExpression.Right>
                            <ns0:CodePrimitiveExpression />
                          </ns0:CodeBinaryOperatorExpression.Right>
                        </ns0:CodeBinaryOperatorExpression>
                      </ns0:CodeBinaryOperatorExpression.Left>
                      <ns0:CodeBinaryOperatorExpression.Right>
                        <ns0:CodeBinaryOperatorExpression Operator="IdentityInequality">
                          <ns0:CodeBinaryOperatorExpression.Left>
                            <ns0:CodeMethodInvokeExpression>
                              <ns0:CodeMethodInvokeExpression.Parameters>
                                <ns0:CodePrimitiveExpression>
                                  <ns0:CodePrimitiveExpression.Value>
                                    <ns1:String xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">UltimateSoftware.Security.UserContext</ns1:String>
                                  </ns0:CodePrimitiveExpression.Value>
                                </ns0:CodePrimitiveExpression>
                              </ns0:CodeMethodInvokeExpression.Parameters>
                              <ns0:CodeMethodInvokeExpression.Method>
                                <ns0:CodeMethodReferenceExpression MethodName="GetBusinessObjectByType">
                                  <ns0:CodeMethodReferenceExpression.TargetObject>
                                    <ns0:CodeThisReferenceExpression />
                                  </ns0:CodeMethodReferenceExpression.TargetObject>
                                </ns0:CodeMethodReferenceExpression>
                              </ns0:CodeMethodInvokeExpression.Method>
                            </ns0:CodeMethodInvokeExpression>
                          </ns0:CodeBinaryOperatorExpression.Left>
                          <ns0:CodeBinaryOperatorExpression.Right>
                            <ns0:CodePrimitiveExpression />
                          </ns0:CodeBinaryOperatorExpression.Right>
                        </ns0:CodeBinaryOperatorExpression>
                      </ns0:CodeBinaryOperatorExpression.Right>
                    </ns0:CodeBinaryOperatorExpression>
                  </ns0:CodeBinaryOperatorExpression.Left>
                  <ns0:CodeBinaryOperatorExpression.Right>
                    <ns0:CodeBinaryOperatorExpression Operator="BooleanAnd">
                      <ns0:CodeBinaryOperatorExpression.Left>
                        <ns0:CodeBinaryOperatorExpression Operator="BooleanAnd">
                          <ns0:CodeBinaryOperatorExpression.Left>
                            <ns0:CodeBinaryOperatorExpression Operator="ValueEquality">
                              <ns0:CodeBinaryOperatorExpression.Left>
                                <ns0:CodeMethodInvokeExpression>
                                  <ns0:CodeMethodInvokeExpression.Parameters>
                                    <ns0:CodePrimitiveExpression>
                                      <ns0:CodePrimitiveExpression.Value>
                                        <ns1:String xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">ESS</ns1:String>
                                      </ns0:CodePrimitiveExpression.Value>
                                    </ns0:CodePrimitiveExpression>
                                  </ns0:CodeMethodInvokeExpression.Parameters>
                                  <ns0:CodeMethodInvokeExpression.Method>
                                    <ns0:CodeMethodReferenceExpression MethodName="IsValidProductKey">
                                      <ns0:CodeMethodReferenceExpression.TargetObject>
                                        <ns0:CodeThisReferenceExpression />
                                      </ns0:CodeMethodReferenceExpression.TargetObject>
                                    </ns0:CodeMethodReferenceExpression>
                                  </ns0:CodeMethodInvokeExpression.Method>
                                </ns0:CodeMethodInvokeExpression>
                              </ns0:CodeBinaryOperatorExpression.Left>
                              <ns0:CodeBinaryOperatorExpression.Right>
                                <ns0:CodePrimitiveExpression>
                                  <ns0:CodePrimitiveExpression.Value>
                                    <ns1:Boolean xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">true</ns1:Boolean>
                                  </ns0:CodePrimitiveExpression.Value>
                                </ns0:CodePrimitiveExpression>
                              </ns0:CodeBinaryOperatorExpression.Right>
                            </ns0:CodeBinaryOperatorExpression>
                          </ns0:CodeBinaryOperatorExpression.Left>
                          <ns0:CodeBinaryOperatorExpression.Right>
                            <ns0:CodeBinaryOperatorExpression Operator="IdentityInequality">
                              <ns0:CodeBinaryOperatorExpression.Left>
                                <ns0:CodeMethodInvokeExpression>
                                  <ns0:CodeMethodInvokeExpression.Parameters>
                                    <ns0:CodePrimitiveExpression>
                                      <ns0:CodePrimitiveExpression.Value>
                                        <ns1:String xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">ESS</ns1:String>
                                      </ns0:CodePrimitiveExpression.Value>
                                    </ns0:CodePrimitiveExpression>
                                  </ns0:CodeMethodInvokeExpression.Parameters>
                                  <ns0:CodeMethodInvokeExpression.Method>
                                    <ns0:CodeMethodReferenceExpression MethodName="GetValueByName">
                                      <ns0:CodeMethodReferenceExpression.TargetObject>
                                        <ns0:CodeThisReferenceExpression />
                                      </ns0:CodeMethodReferenceExpression.TargetObject>
                                    </ns0:CodeMethodReferenceExpression>
                                  </ns0:CodeMethodInvokeExpression.Method>
                                </ns0:CodeMethodInvokeExpression>
                              </ns0:CodeBinaryOperatorExpression.Left>
                              <ns0:CodeBinaryOperatorExpression.Right>
                                <ns0:CodePrimitiveExpression />
                              </ns0:CodeBinaryOperatorExpression.Right>
                            </ns0:CodeBinaryOperatorExpression>
                          </ns0:CodeBinaryOperatorExpression.Right>
                        </ns0:CodeBinaryOperatorExpression>
                      </ns0:CodeBinaryOperatorExpression.Left>
                      <ns0:CodeBinaryOperatorExpression.Right>
                        <ns0:CodeBinaryOperatorExpression Operator="ValueEquality">
                          <ns0:CodeBinaryOperatorExpression.Left>
                            <ns0:CodeCastExpression TargetType="System.String, mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">
                              <ns0:CodeCastExpression.Expression>
                                <ns0:CodeMethodInvokeExpression>
                                  <ns0:CodeMethodInvokeExpression.Parameters>
                                    <ns0:CodePrimitiveExpression>
                                      <ns0:CodePrimitiveExpression.Value>
                                        <ns1:String xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">ESS</ns1:String>
                                      </ns0:CodePrimitiveExpression.Value>
                                    </ns0:CodePrimitiveExpression>
                                  </ns0:CodeMethodInvokeExpression.Parameters>
                                  <ns0:CodeMethodInvokeExpression.Method>
                                    <ns0:CodeMethodReferenceExpression MethodName="GetValueByName">
                                      <ns0:CodeMethodReferenceExpression.TargetObject>
                                        <ns0:CodeThisReferenceExpression />
                                      </ns0:CodeMethodReferenceExpression.TargetObject>
                                    </ns0:CodeMethodReferenceExpression>
                                  </ns0:CodeMethodInvokeExpression.Method>
                                </ns0:CodeMethodInvokeExpression>
                              </ns0:CodeCastExpression.Expression>
                            </ns0:CodeCastExpression>
                          </ns0:CodeBinaryOperatorExpression.Left>
                          <ns0:CodeBinaryOperatorExpression.Right>
                            <ns0:CodePrimitiveExpression>
                              <ns0:CodePrimitiveExpression.Value>
                                <ns1:String xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">ESS</ns1:String>
                              </ns0:CodePrimitiveExpression.Value>
                            </ns0:CodePrimitiveExpression>
                          </ns0:CodeBinaryOperatorExpression.Right>
                        </ns0:CodeBinaryOperatorExpression>
                      </ns0:CodeBinaryOperatorExpression.Right>
                    </ns0:CodeBinaryOperatorExpression>
                  </ns0:CodeBinaryOperatorExpression.Right>
                </ns0:CodeBinaryOperatorExpression>
              </ns0:CodeBinaryOperatorExpression.Left>
              <ns0:CodeBinaryOperatorExpression.Right>
                <ns0:CodeBinaryOperatorExpression Operator="BooleanAnd">
                  <ns0:CodeBinaryOperatorExpression.Left>
                    <ns0:CodeBinaryOperatorExpression Operator="IdentityInequality">
                      <ns0:CodeBinaryOperatorExpression.Left>
                        <ns0:CodeMethodInvokeExpression>
                          <ns0:CodeMethodInvokeExpression.Parameters>
                            <ns0:CodePrimitiveExpression>
                              <ns0:CodePrimitiveExpression.Value>
                                <ns1:String xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">Add</ns1:String>
                              </ns0:CodePrimitiveExpression.Value>
                            </ns0:CodePrimitiveExpression>
                          </ns0:CodeMethodInvokeExpression.Parameters>
                          <ns0:CodeMethodInvokeExpression.Method>
                            <ns0:CodeMethodReferenceExpression MethodName="GetValueByName">
                              <ns0:CodeMethodReferenceExpression.TargetObject>
                                <ns0:CodeThisReferenceExpression />
                              </ns0:CodeMethodReferenceExpression.TargetObject>
                            </ns0:CodeMethodReferenceExpression>
                          </ns0:CodeMethodInvokeExpression.Method>
                        </ns0:CodeMethodInvokeExpression>
                      </ns0:CodeBinaryOperatorExpression.Left>
                      <ns0:CodeBinaryOperatorExpression.Right>
                        <ns0:CodePrimitiveExpression />
                      </ns0:CodeBinaryOperatorExpression.Right>
                    </ns0:CodeBinaryOperatorExpression>
                  </ns0:CodeBinaryOperatorExpression.Left>
                  <ns0:CodeBinaryOperatorExpression.Right>
                    <ns0:CodeBinaryOperatorExpression Operator="ValueEquality">
                      <ns0:CodeBinaryOperatorExpression.Left>
                        <ns0:CodeCastExpression TargetType="System.Int32, mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">
                          <ns0:CodeCastExpression.Expression>
                            <ns0:CodeMethodInvokeExpression>
                              <ns0:CodeMethodInvokeExpression.Parameters>
                                <ns0:CodePrimitiveExpression>
                                  <ns0:CodePrimitiveExpression.Value>
                                    <ns1:String xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">Add</ns1:String>
                                  </ns0:CodePrimitiveExpression.Value>
                                </ns0:CodePrimitiveExpression>
                              </ns0:CodeMethodInvokeExpression.Parameters>
                              <ns0:CodeMethodInvokeExpression.Method>
                                <ns0:CodeMethodReferenceExpression MethodName="GetValueByName">
                                  <ns0:CodeMethodReferenceExpression.TargetObject>
                                    <ns0:CodeThisReferenceExpression />
                                  </ns0:CodeMethodReferenceExpression.TargetObject>
                                </ns0:CodeMethodReferenceExpression>
                              </ns0:CodeMethodInvokeExpression.Method>
                            </ns0:CodeMethodInvokeExpression>
                          </ns0:CodeCastExpression.Expression>
                        </ns0:CodeCastExpression>
                      </ns0:CodeBinaryOperatorExpression.Left>
                      <ns0:CodeBinaryOperatorExpression.Right>
                        <ns0:CodePrimitiveExpression>
                          <ns0:CodePrimitiveExpression.Value>
                            <ns1:Int32 xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">0</ns1:Int32>
                          </ns0:CodePrimitiveExpression.Value>
                        </ns0:CodePrimitiveExpression>
                      </ns0:CodeBinaryOperatorExpression.Right>
                    </ns0:CodeBinaryOperatorExpression>
                  </ns0:CodeBinaryOperatorExpression.Right>
                </ns0:CodeBinaryOperatorExpression>
              </ns0:CodeBinaryOperatorExpression.Right>
            </ns0:CodeBinaryOperatorExpression>
          </RuleExpressionCondition.Expression>
        </RuleExpressionCondition>
      </Rule.Condition>
    </Rule>
    <Rule Name="EE-Change-2" ReevaluationBehavior="Always" Priority="2" Description="{p1:Null}" Active="True">
      <Rule.ThenActions>
        <RuleStatementAction>
          <RuleStatementAction.CodeDomStatement>
            <ns0:CodeAssignStatement xmlns:ns0="clr-namespace:System.CodeDom;Assembly=System, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" LinePragma="{p1:Null}">
              <ns0:CodeAssignStatement.Left>
                <ns0:CodePropertyReferenceExpression PropertyName="Result">
                  <ns0:CodePropertyReferenceExpression.TargetObject>
                    <ns0:CodeThisReferenceExpression />
                  </ns0:CodePropertyReferenceExpression.TargetObject>
                </ns0:CodePropertyReferenceExpression>
              </ns0:CodeAssignStatement.Left>
              <ns0:CodeAssignStatement.Right>
                <ns0:CodePrimitiveExpression>
                  <ns0:CodePrimitiveExpression.Value>
                    <ns1:String xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">EMPLOYEEBPDID</ns1:String>
                  </ns0:CodePrimitiveExpression.Value>
                </ns0:CodePrimitiveExpression>
              </ns0:CodeAssignStatement.Right>
            </ns0:CodeAssignStatement>
          </RuleStatementAction.CodeDomStatement>
        </RuleStatementAction>
      </Rule.ThenActions>
      <Rule.Condition>
        <RuleExpressionCondition Name="{p1:Null}">
          <RuleExpressionCondition.Expression>
            <ns0:CodeBinaryOperatorExpression xmlns:ns0="clr-namespace:System.CodeDom;Assembly=System, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" Operator="BooleanAnd">
              <ns0:CodeBinaryOperatorExpression.Left>
                <ns0:CodeBinaryOperatorExpression Operator="BooleanAnd">
                  <ns0:CodeBinaryOperatorExpression.Left>
                    <ns0:CodeBinaryOperatorExpression Operator="BooleanAnd">
                      <ns0:CodeBinaryOperatorExpression.Left>
                        <ns0:CodeBinaryOperatorExpression Operator="IdentityInequality">
                          <ns0:CodeBinaryOperatorExpression.Left>
                            <ns0:CodeMethodInvokeExpression>
                              <ns0:CodeMethodInvokeExpression.Parameters>
                                <ns0:CodePrimitiveExpression>
                                  <ns0:CodePrimitiveExpression.Value>
                                    <ns1:String xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">UltimateSoftware.Notifications.InitiatedFor</ns1:String>
                                  </ns0:CodePrimitiveExpression.Value>
                                </ns0:CodePrimitiveExpression>
                              </ns0:CodeMethodInvokeExpression.Parameters>
                              <ns0:CodeMethodInvokeExpression.Method>
                                <ns0:CodeMethodReferenceExpression MethodName="GetBusinessObjectByType">
                                  <ns0:CodeMethodReferenceExpression.TargetObject>
                                    <ns0:CodeThisReferenceExpression />
                                  </ns0:CodeMethodReferenceExpression.TargetObject>
                                </ns0:CodeMethodReferenceExpression>
                              </ns0:CodeMethodInvokeExpression.Method>
                            </ns0:CodeMethodInvokeExpression>
                          </ns0:CodeBinaryOperatorExpression.Left>
                          <ns0:CodeBinaryOperatorExpression.Right>
                            <ns0:CodePrimitiveExpression />
                          </ns0:CodeBinaryOperatorExpression.Right>
                        </ns0:CodeBinaryOperatorExpression>
                      </ns0:CodeBinaryOperatorExpression.Left>
                      <ns0:CodeBinaryOperatorExpression.Right>
                        <ns0:CodeBinaryOperatorExpression Operator="IdentityInequality">
                          <ns0:CodeBinaryOperatorExpression.Left>
                            <ns0:CodeMethodInvokeExpression>
                              <ns0:CodeMethodInvokeExpression.Parameters>
                                <ns0:CodePrimitiveExpression>
                                  <ns0:CodePrimitiveExpression.Value>
                                    <ns1:String xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">UltimateSoftware.Security.UserContext</ns1:String>
                                  </ns0:CodePrimitiveExpression.Value>
                                </ns0:CodePrimitiveExpression>
                              </ns0:CodeMethodInvokeExpression.Parameters>
                              <ns0:CodeMethodInvokeExpression.Method>
                                <ns0:CodeMethodReferenceExpression MethodName="GetBusinessObjectByType">
                                  <ns0:CodeMethodReferenceExpression.TargetObject>
                                    <ns0:CodeThisReferenceExpression />
                                  </ns0:CodeMethodReferenceExpression.TargetObject>
                                </ns0:CodeMethodReferenceExpression>
                              </ns0:CodeMethodInvokeExpression.Method>
                            </ns0:CodeMethodInvokeExpression>
                          </ns0:CodeBinaryOperatorExpression.Left>
                          <ns0:CodeBinaryOperatorExpression.Right>
                            <ns0:CodePrimitiveExpression />
                          </ns0:CodeBinaryOperatorExpression.Right>
                        </ns0:CodeBinaryOperatorExpression>
                      </ns0:CodeBinaryOperatorExpression.Right>
                    </ns0:CodeBinaryOperatorExpression>
                  </ns0:CodeBinaryOperatorExpression.Left>
                  <ns0:CodeBinaryOperatorExpression.Right>
                    <ns0:CodeBinaryOperatorExpression Operator="BooleanAnd">
                      <ns0:CodeBinaryOperatorExpression.Left>
                        <ns0:CodeBinaryOperatorExpression Operator="BooleanAnd">
                          <ns0:CodeBinaryOperatorExpression.Left>
                            <ns0:CodeBinaryOperatorExpression Operator="ValueEquality">
                              <ns0:CodeBinaryOperatorExpression.Left>
                                <ns0:CodeMethodInvokeExpression>
                                  <ns0:CodeMethodInvokeExpression.Parameters>
                                    <ns0:CodePrimitiveExpression>
                                      <ns0:CodePrimitiveExpression.Value>
                                        <ns1:String xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">ESS</ns1:String>
                                      </ns0:CodePrimitiveExpression.Value>
                                    </ns0:CodePrimitiveExpression>
                                  </ns0:CodeMethodInvokeExpression.Parameters>
                                  <ns0:CodeMethodInvokeExpression.Method>
                                    <ns0:CodeMethodReferenceExpression MethodName="IsValidProductKey">
                                      <ns0:CodeMethodReferenceExpression.TargetObject>
                                        <ns0:CodeThisReferenceExpression />
                                      </ns0:CodeMethodReferenceExpression.TargetObject>
                                    </ns0:CodeMethodReferenceExpression>
                                  </ns0:CodeMethodInvokeExpression.Method>
                                </ns0:CodeMethodInvokeExpression>
                              </ns0:CodeBinaryOperatorExpression.Left>
                              <ns0:CodeBinaryOperatorExpression.Right>
                                <ns0:CodePrimitiveExpression>
                                  <ns0:CodePrimitiveExpression.Value>
                                    <ns1:Boolean xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">true</ns1:Boolean>
                                  </ns0:CodePrimitiveExpression.Value>
                                </ns0:CodePrimitiveExpression>
                              </ns0:CodeBinaryOperatorExpression.Right>
                            </ns0:CodeBinaryOperatorExpression>
                          </ns0:CodeBinaryOperatorExpression.Left>
                          <ns0:CodeBinaryOperatorExpression.Right>
                            <ns0:CodeBinaryOperatorExpression Operator="IdentityInequality">
                              <ns0:CodeBinaryOperatorExpression.Left>
                                <ns0:CodeMethodInvokeExpression>
                                  <ns0:CodeMethodInvokeExpression.Parameters>
                                    <ns0:CodePrimitiveExpression>
                                      <ns0:CodePrimitiveExpression.Value>
                                        <ns1:String xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">ESS</ns1:String>
                                      </ns0:CodePrimitiveExpression.Value>
                                    </ns0:CodePrimitiveExpression>
                                  </ns0:CodeMethodInvokeExpression.Parameters>
                                  <ns0:CodeMethodInvokeExpression.Method>
                                    <ns0:CodeMethodReferenceExpression MethodName="GetValueByName">
                                      <ns0:CodeMethodReferenceExpression.TargetObject>
                                        <ns0:CodeThisReferenceExpression />
                                      </ns0:CodeMethodReferenceExpression.TargetObject>
                                    </ns0:CodeMethodReferenceExpression>
                                  </ns0:CodeMethodInvokeExpression.Method>
                                </ns0:CodeMethodInvokeExpression>
                              </ns0:CodeBinaryOperatorExpression.Left>
                              <ns0:CodeBinaryOperatorExpression.Right>
                                <ns0:CodePrimitiveExpression />
                              </ns0:CodeBinaryOperatorExpression.Right>
                            </ns0:CodeBinaryOperatorExpression>
                          </ns0:CodeBinaryOperatorExpression.Right>
                        </ns0:CodeBinaryOperatorExpression>
                      </ns0:CodeBinaryOperatorExpression.Left>
                      <ns0:CodeBinaryOperatorExpression.Right>
                        <ns0:CodeBinaryOperatorExpression Operator="ValueEquality">
                          <ns0:CodeBinaryOperatorExpression.Left>
                            <ns0:CodeCastExpression TargetType="System.String, mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">
                              <ns0:CodeCastExpression.Expression>
                                <ns0:CodeMethodInvokeExpression>
                                  <ns0:CodeMethodInvokeExpression.Parameters>
                                    <ns0:CodePrimitiveExpression>
                                      <ns0:CodePrimitiveExpression.Value>
                                        <ns1:String xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">ESS</ns1:String>
                                      </ns0:CodePrimitiveExpression.Value>
                                    </ns0:CodePrimitiveExpression>
                                  </ns0:CodeMethodInvokeExpression.Parameters>
                                  <ns0:CodeMethodInvokeExpression.Method>
                                    <ns0:CodeMethodReferenceExpression MethodName="GetValueByName">
                                      <ns0:CodeMethodReferenceExpression.TargetObject>
                                        <ns0:CodeThisReferenceExpression />
                                      </ns0:CodeMethodReferenceExpression.TargetObject>
                                    </ns0:CodeMethodReferenceExpression>
                                  </ns0:CodeMethodInvokeExpression.Method>
                                </ns0:CodeMethodInvokeExpression>
                              </ns0:CodeCastExpression.Expression>
                            </ns0:CodeCastExpression>
                          </ns0:CodeBinaryOperatorExpression.Left>
                          <ns0:CodeBinaryOperatorExpression.Right>
                            <ns0:CodePrimitiveExpression>
                              <ns0:CodePrimitiveExpression.Value>
                                <ns1:String xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">ESS</ns1:String>
                              </ns0:CodePrimitiveExpression.Value>
                            </ns0:CodePrimitiveExpression>
                          </ns0:CodeBinaryOperatorExpression.Right>
                        </ns0:CodeBinaryOperatorExpression>
                      </ns0:CodeBinaryOperatorExpression.Right>
                    </ns0:CodeBinaryOperatorExpression>
                  </ns0:CodeBinaryOperatorExpression.Right>
                </ns0:CodeBinaryOperatorExpression>
              </ns0:CodeBinaryOperatorExpression.Left>
              <ns0:CodeBinaryOperatorExpression.Right>
                <ns0:CodeBinaryOperatorExpression Operator="BooleanAnd">
                  <ns0:CodeBinaryOperatorExpression.Left>
                    <ns0:CodeBinaryOperatorExpression Operator="IdentityInequality">
                      <ns0:CodeBinaryOperatorExpression.Left>
                        <ns0:CodeMethodInvokeExpression>
                          <ns0:CodeMethodInvokeExpression.Parameters>
                            <ns0:CodePrimitiveExpression>
                              <ns0:CodePrimitiveExpression.Value>
                                <ns1:String xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">Change</ns1:String>
                              </ns0:CodePrimitiveExpression.Value>
                            </ns0:CodePrimitiveExpression>
                          </ns0:CodeMethodInvokeExpression.Parameters>
                          <ns0:CodeMethodInvokeExpression.Method>
                            <ns0:CodeMethodReferenceExpression MethodName="GetValueByName">
                              <ns0:CodeMethodReferenceExpression.TargetObject>
                                <ns0:CodeThisReferenceExpression />
                              </ns0:CodeMethodReferenceExpression.TargetObject>
                            </ns0:CodeMethodReferenceExpression>
                          </ns0:CodeMethodInvokeExpression.Method>
                        </ns0:CodeMethodInvokeExpression>
                      </ns0:CodeBinaryOperatorExpression.Left>
                      <ns0:CodeBinaryOperatorExpression.Right>
                        <ns0:CodePrimitiveExpression />
                      </ns0:CodeBinaryOperatorExpression.Right>
                    </ns0:CodeBinaryOperatorExpression>
                  </ns0:CodeBinaryOperatorExpression.Left>
                  <ns0:CodeBinaryOperatorExpression.Right>
                    <ns0:CodeBinaryOperatorExpression Operator="ValueEquality">
                      <ns0:CodeBinaryOperatorExpression.Left>
                        <ns0:CodeCastExpression TargetType="System.Int32, mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">
                          <ns0:CodeCastExpression.Expression>
                            <ns0:CodeMethodInvokeExpression>
                              <ns0:CodeMethodInvokeExpression.Parameters>
                                <ns0:CodePrimitiveExpression>
                                  <ns0:CodePrimitiveExpression.Value>
                                    <ns1:String xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">Change</ns1:String>
                                  </ns0:CodePrimitiveExpression.Value>
                                </ns0:CodePrimitiveExpression>
                              </ns0:CodeMethodInvokeExpression.Parameters>
                              <ns0:CodeMethodInvokeExpression.Method>
                                <ns0:CodeMethodReferenceExpression MethodName="GetValueByName">
                                  <ns0:CodeMethodReferenceExpression.TargetObject>
                                    <ns0:CodeThisReferenceExpression />
                                  </ns0:CodeMethodReferenceExpression.TargetObject>
                                </ns0:CodeMethodReferenceExpression>
                              </ns0:CodeMethodInvokeExpression.Method>
                            </ns0:CodeMethodInvokeExpression>
                          </ns0:CodeCastExpression.Expression>
                        </ns0:CodeCastExpression>
                      </ns0:CodeBinaryOperatorExpression.Left>
                      <ns0:CodeBinaryOperatorExpression.Right>
                        <ns0:CodePrimitiveExpression>
                          <ns0:CodePrimitiveExpression.Value>
                            <ns1:Int32 xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">1</ns1:Int32>
                          </ns0:CodePrimitiveExpression.Value>
                        </ns0:CodePrimitiveExpression>
                      </ns0:CodeBinaryOperatorExpression.Right>
                    </ns0:CodeBinaryOperatorExpression>
                  </ns0:CodeBinaryOperatorExpression.Right>
                </ns0:CodeBinaryOperatorExpression>
              </ns0:CodeBinaryOperatorExpression.Right>
            </ns0:CodeBinaryOperatorExpression>
          </RuleExpressionCondition.Expression>
        </RuleExpressionCondition>
      </Rule.Condition>
    </Rule>
    <Rule Name="EE-Delete-3" ReevaluationBehavior="Always" Priority="3" Description="{p1:Null}" Active="True">
      <Rule.ThenActions>
        <RuleStatementAction>
          <RuleStatementAction.CodeDomStatement>
            <ns0:CodeAssignStatement xmlns:ns0="clr-namespace:System.CodeDom;Assembly=System, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" LinePragma="{p1:Null}">
              <ns0:CodeAssignStatement.Left>
                <ns0:CodePropertyReferenceExpression PropertyName="Result">
                  <ns0:CodePropertyReferenceExpression.TargetObject>
                    <ns0:CodeThisReferenceExpression />
                  </ns0:CodePropertyReferenceExpression.TargetObject>
                </ns0:CodePropertyReferenceExpression>
              </ns0:CodeAssignStatement.Left>
              <ns0:CodeAssignStatement.Right>
                <ns0:CodePrimitiveExpression>
                  <ns0:CodePrimitiveExpression.Value>
                    <ns1:String xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">EMPLOYEEBPDID</ns1:String>
                  </ns0:CodePrimitiveExpression.Value>
                </ns0:CodePrimitiveExpression>
              </ns0:CodeAssignStatement.Right>
            </ns0:CodeAssignStatement>
          </RuleStatementAction.CodeDomStatement>
        </RuleStatementAction>
      </Rule.ThenActions>
      <Rule.Condition>
        <RuleExpressionCondition Name="{p1:Null}">
          <RuleExpressionCondition.Expression>
            <ns0:CodeBinaryOperatorExpression xmlns:ns0="clr-namespace:System.CodeDom;Assembly=System, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" Operator="BooleanAnd">
              <ns0:CodeBinaryOperatorExpression.Left>
                <ns0:CodeBinaryOperatorExpression Operator="BooleanAnd">
                  <ns0:CodeBinaryOperatorExpression.Left>
                    <ns0:CodeBinaryOperatorExpression Operator="BooleanAnd">
                      <ns0:CodeBinaryOperatorExpression.Left>
                        <ns0:CodeBinaryOperatorExpression Operator="IdentityInequality">
                          <ns0:CodeBinaryOperatorExpression.Left>
                            <ns0:CodeMethodInvokeExpression>
                              <ns0:CodeMethodInvokeExpression.Parameters>
                                <ns0:CodePrimitiveExpression>
                                  <ns0:CodePrimitiveExpression.Value>
                                    <ns1:String xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">UltimateSoftware.Notifications.InitiatedFor</ns1:String>
                                  </ns0:CodePrimitiveExpression.Value>
                                </ns0:CodePrimitiveExpression>
                              </ns0:CodeMethodInvokeExpression.Parameters>
                              <ns0:CodeMethodInvokeExpression.Method>
                                <ns0:CodeMethodReferenceExpression MethodName="GetBusinessObjectByType">
                                  <ns0:CodeMethodReferenceExpression.TargetObject>
                                    <ns0:CodeThisReferenceExpression />
                                  </ns0:CodeMethodReferenceExpression.TargetObject>
                                </ns0:CodeMethodReferenceExpression>
                              </ns0:CodeMethodInvokeExpression.Method>
                            </ns0:CodeMethodInvokeExpression>
                          </ns0:CodeBinaryOperatorExpression.Left>
                          <ns0:CodeBinaryOperatorExpression.Right>
                            <ns0:CodePrimitiveExpression />
                          </ns0:CodeBinaryOperatorExpression.Right>
                        </ns0:CodeBinaryOperatorExpression>
                      </ns0:CodeBinaryOperatorExpression.Left>
                      <ns0:CodeBinaryOperatorExpression.Right>
                        <ns0:CodeBinaryOperatorExpression Operator="IdentityInequality">
                          <ns0:CodeBinaryOperatorExpression.Left>
                            <ns0:CodeMethodInvokeExpression>
                              <ns0:CodeMethodInvokeExpression.Parameters>
                                <ns0:CodePrimitiveExpression>
                                  <ns0:CodePrimitiveExpression.Value>
                                    <ns1:String xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">UltimateSoftware.Security.UserContext</ns1:String>
                                  </ns0:CodePrimitiveExpression.Value>
                                </ns0:CodePrimitiveExpression>
                              </ns0:CodeMethodInvokeExpression.Parameters>
                              <ns0:CodeMethodInvokeExpression.Method>
                                <ns0:CodeMethodReferenceExpression MethodName="GetBusinessObjectByType">
                                  <ns0:CodeMethodReferenceExpression.TargetObject>
                                    <ns0:CodeThisReferenceExpression />
                                  </ns0:CodeMethodReferenceExpression.TargetObject>
                                </ns0:CodeMethodReferenceExpression>
                              </ns0:CodeMethodInvokeExpression.Method>
                            </ns0:CodeMethodInvokeExpression>
                          </ns0:CodeBinaryOperatorExpression.Left>
                          <ns0:CodeBinaryOperatorExpression.Right>
                            <ns0:CodePrimitiveExpression />
                          </ns0:CodeBinaryOperatorExpression.Right>
                        </ns0:CodeBinaryOperatorExpression>
                      </ns0:CodeBinaryOperatorExpression.Right>
                    </ns0:CodeBinaryOperatorExpression>
                  </ns0:CodeBinaryOperatorExpression.Left>
                  <ns0:CodeBinaryOperatorExpression.Right>
                    <ns0:CodeBinaryOperatorExpression Operator="BooleanAnd">
                      <ns0:CodeBinaryOperatorExpression.Left>
                        <ns0:CodeBinaryOperatorExpression Operator="BooleanAnd">
                          <ns0:CodeBinaryOperatorExpression.Left>
                            <ns0:CodeBinaryOperatorExpression Operator="ValueEquality">
                              <ns0:CodeBinaryOperatorExpression.Left>
                                <ns0:CodeMethodInvokeExpression>
                                  <ns0:CodeMethodInvokeExpression.Parameters>
                                    <ns0:CodePrimitiveExpression>
                                      <ns0:CodePrimitiveExpression.Value>
                                        <ns1:String xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">ESS</ns1:String>
                                      </ns0:CodePrimitiveExpression.Value>
                                    </ns0:CodePrimitiveExpression>
                                  </ns0:CodeMethodInvokeExpression.Parameters>
                                  <ns0:CodeMethodInvokeExpression.Method>
                                    <ns0:CodeMethodReferenceExpression MethodName="IsValidProductKey">
                                      <ns0:CodeMethodReferenceExpression.TargetObject>
                                        <ns0:CodeThisReferenceExpression />
                                      </ns0:CodeMethodReferenceExpression.TargetObject>
                                    </ns0:CodeMethodReferenceExpression>
                                  </ns0:CodeMethodInvokeExpression.Method>
                                </ns0:CodeMethodInvokeExpression>
                              </ns0:CodeBinaryOperatorExpression.Left>
                              <ns0:CodeBinaryOperatorExpression.Right>
                                <ns0:CodePrimitiveExpression>
                                  <ns0:CodePrimitiveExpression.Value>
                                    <ns1:Boolean xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">true</ns1:Boolean>
                                  </ns0:CodePrimitiveExpression.Value>
                                </ns0:CodePrimitiveExpression>
                              </ns0:CodeBinaryOperatorExpression.Right>
                            </ns0:CodeBinaryOperatorExpression>
                          </ns0:CodeBinaryOperatorExpression.Left>
                          <ns0:CodeBinaryOperatorExpression.Right>
                            <ns0:CodeBinaryOperatorExpression Operator="IdentityInequality">
                              <ns0:CodeBinaryOperatorExpression.Left>
                                <ns0:CodeMethodInvokeExpression>
                                  <ns0:CodeMethodInvokeExpression.Parameters>
                                    <ns0:CodePrimitiveExpression>
                                      <ns0:CodePrimitiveExpression.Value>
                                        <ns1:String xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">ESS</ns1:String>
                                      </ns0:CodePrimitiveExpression.Value>
                                    </ns0:CodePrimitiveExpression>
                                  </ns0:CodeMethodInvokeExpression.Parameters>
                                  <ns0:CodeMethodInvokeExpression.Method>
                                    <ns0:CodeMethodReferenceExpression MethodName="GetValueByName">
                                      <ns0:CodeMethodReferenceExpression.TargetObject>
                                        <ns0:CodeThisReferenceExpression />
                                      </ns0:CodeMethodReferenceExpression.TargetObject>
                                    </ns0:CodeMethodReferenceExpression>
                                  </ns0:CodeMethodInvokeExpression.Method>
                                </ns0:CodeMethodInvokeExpression>
                              </ns0:CodeBinaryOperatorExpression.Left>
                              <ns0:CodeBinaryOperatorExpression.Right>
                                <ns0:CodePrimitiveExpression />
                              </ns0:CodeBinaryOperatorExpression.Right>
                            </ns0:CodeBinaryOperatorExpression>
                          </ns0:CodeBinaryOperatorExpression.Right>
                        </ns0:CodeBinaryOperatorExpression>
                      </ns0:CodeBinaryOperatorExpression.Left>
                      <ns0:CodeBinaryOperatorExpression.Right>
                        <ns0:CodeBinaryOperatorExpression Operator="ValueEquality">
                          <ns0:CodeBinaryOperatorExpression.Left>
                            <ns0:CodeCastExpression TargetType="System.String, mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">
                              <ns0:CodeCastExpression.Expression>
                                <ns0:CodeMethodInvokeExpression>
                                  <ns0:CodeMethodInvokeExpression.Parameters>
                                    <ns0:CodePrimitiveExpression>
                                      <ns0:CodePrimitiveExpression.Value>
                                        <ns1:String xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">ESS</ns1:String>
                                      </ns0:CodePrimitiveExpression.Value>
                                    </ns0:CodePrimitiveExpression>
                                  </ns0:CodeMethodInvokeExpression.Parameters>
                                  <ns0:CodeMethodInvokeExpression.Method>
                                    <ns0:CodeMethodReferenceExpression MethodName="GetValueByName">
                                      <ns0:CodeMethodReferenceExpression.TargetObject>
                                        <ns0:CodeThisReferenceExpression />
                                      </ns0:CodeMethodReferenceExpression.TargetObject>
                                    </ns0:CodeMethodReferenceExpression>
                                  </ns0:CodeMethodInvokeExpression.Method>
                                </ns0:CodeMethodInvokeExpression>
                              </ns0:CodeCastExpression.Expression>
                            </ns0:CodeCastExpression>
                          </ns0:CodeBinaryOperatorExpression.Left>
                          <ns0:CodeBinaryOperatorExpression.Right>
                            <ns0:CodePrimitiveExpression>
                              <ns0:CodePrimitiveExpression.Value>
                                <ns1:String xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">ESS</ns1:String>
                              </ns0:CodePrimitiveExpression.Value>
                            </ns0:CodePrimitiveExpression>
                          </ns0:CodeBinaryOperatorExpression.Right>
                        </ns0:CodeBinaryOperatorExpression>
                      </ns0:CodeBinaryOperatorExpression.Right>
                    </ns0:CodeBinaryOperatorExpression>
                  </ns0:CodeBinaryOperatorExpression.Right>
                </ns0:CodeBinaryOperatorExpression>
              </ns0:CodeBinaryOperatorExpression.Left>
              <ns0:CodeBinaryOperatorExpression.Right>
                <ns0:CodeBinaryOperatorExpression Operator="BooleanAnd">
                  <ns0:CodeBinaryOperatorExpression.Left>
                    <ns0:CodeBinaryOperatorExpression Operator="IdentityInequality">
                      <ns0:CodeBinaryOperatorExpression.Left>
                        <ns0:CodeMethodInvokeExpression>
                          <ns0:CodeMethodInvokeExpression.Parameters>
                            <ns0:CodePrimitiveExpression>
                              <ns0:CodePrimitiveExpression.Value>
                                <ns1:String xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">Delete</ns1:String>
                              </ns0:CodePrimitiveExpression.Value>
                            </ns0:CodePrimitiveExpression>
                          </ns0:CodeMethodInvokeExpression.Parameters>
                          <ns0:CodeMethodInvokeExpression.Method>
                            <ns0:CodeMethodReferenceExpression MethodName="GetValueByName">
                              <ns0:CodeMethodReferenceExpression.TargetObject>
                                <ns0:CodeThisReferenceExpression />
                              </ns0:CodeMethodReferenceExpression.TargetObject>
                            </ns0:CodeMethodReferenceExpression>
                          </ns0:CodeMethodInvokeExpression.Method>
                        </ns0:CodeMethodInvokeExpression>
                      </ns0:CodeBinaryOperatorExpression.Left>
                      <ns0:CodeBinaryOperatorExpression.Right>
                        <ns0:CodePrimitiveExpression />
                      </ns0:CodeBinaryOperatorExpression.Right>
                    </ns0:CodeBinaryOperatorExpression>
                  </ns0:CodeBinaryOperatorExpression.Left>
                  <ns0:CodeBinaryOperatorExpression.Right>
                    <ns0:CodeBinaryOperatorExpression Operator="ValueEquality">
                      <ns0:CodeBinaryOperatorExpression.Left>
                        <ns0:CodeCastExpression TargetType="System.Int32, mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">
                          <ns0:CodeCastExpression.Expression>
                            <ns0:CodeMethodInvokeExpression>
                              <ns0:CodeMethodInvokeExpression.Parameters>
                                <ns0:CodePrimitiveExpression>
                                  <ns0:CodePrimitiveExpression.Value>
                                    <ns1:String xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">Delete</ns1:String>
                                  </ns0:CodePrimitiveExpression.Value>
                                </ns0:CodePrimitiveExpression>
                              </ns0:CodeMethodInvokeExpression.Parameters>
                              <ns0:CodeMethodInvokeExpression.Method>
                                <ns0:CodeMethodReferenceExpression MethodName="GetValueByName">
                                  <ns0:CodeMethodReferenceExpression.TargetObject>
                                    <ns0:CodeThisReferenceExpression />
                                  </ns0:CodeMethodReferenceExpression.TargetObject>
                                </ns0:CodeMethodReferenceExpression>
                              </ns0:CodeMethodInvokeExpression.Method>
                            </ns0:CodeMethodInvokeExpression>
                          </ns0:CodeCastExpression.Expression>
                        </ns0:CodeCastExpression>
                      </ns0:CodeBinaryOperatorExpression.Left>
                      <ns0:CodeBinaryOperatorExpression.Right>
                        <ns0:CodePrimitiveExpression>
                          <ns0:CodePrimitiveExpression.Value>
                            <ns1:Int32 xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">2</ns1:Int32>
                          </ns0:CodePrimitiveExpression.Value>
                        </ns0:CodePrimitiveExpression>
                      </ns0:CodeBinaryOperatorExpression.Right>
                    </ns0:CodeBinaryOperatorExpression>
                  </ns0:CodeBinaryOperatorExpression.Right>
                </ns0:CodeBinaryOperatorExpression>
              </ns0:CodeBinaryOperatorExpression.Right>
            </ns0:CodeBinaryOperatorExpression>
          </RuleExpressionCondition.Expression>
        </RuleExpressionCondition>
      </Rule.Condition>
    </Rule>'
	
	------------------------------------------
	-- Ruleset Template - MSS
	------------------------------------------
	
	SET @RuleSetMSS = '
    <Rule Name="MANGR-Add-4" ReevaluationBehavior="Always" Priority="4" Description="{p1:Null}" Active="True">
      <Rule.ThenActions>
        <RuleStatementAction>
          <RuleStatementAction.CodeDomStatement>
            <ns0:CodeAssignStatement xmlns:ns0="clr-namespace:System.CodeDom;Assembly=System, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" LinePragma="{p1:Null}">
              <ns0:CodeAssignStatement.Left>
                <ns0:CodePropertyReferenceExpression PropertyName="Result">
                  <ns0:CodePropertyReferenceExpression.TargetObject>
                    <ns0:CodeThisReferenceExpression />
                  </ns0:CodePropertyReferenceExpression.TargetObject>
                </ns0:CodePropertyReferenceExpression>
              </ns0:CodeAssignStatement.Left>
              <ns0:CodeAssignStatement.Right>
                <ns0:CodePrimitiveExpression>
                  <ns0:CodePrimitiveExpression.Value>
                    <ns1:String xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">MANAGERBPDID</ns1:String>
                  </ns0:CodePrimitiveExpression.Value>
                </ns0:CodePrimitiveExpression>
              </ns0:CodeAssignStatement.Right>
            </ns0:CodeAssignStatement>
          </RuleStatementAction.CodeDomStatement>
        </RuleStatementAction>
      </Rule.ThenActions>
      <Rule.Condition>
        <RuleExpressionCondition Name="{p1:Null}">
          <RuleExpressionCondition.Expression>
            <ns0:CodeBinaryOperatorExpression xmlns:ns0="clr-namespace:System.CodeDom;Assembly=System, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" Operator="BooleanAnd">
              <ns0:CodeBinaryOperatorExpression.Left>
                <ns0:CodeBinaryOperatorExpression Operator="BooleanAnd">
                  <ns0:CodeBinaryOperatorExpression.Left>
                    <ns0:CodeBinaryOperatorExpression Operator="BooleanAnd">
                      <ns0:CodeBinaryOperatorExpression.Left>
                        <ns0:CodeBinaryOperatorExpression Operator="IdentityInequality">
                          <ns0:CodeBinaryOperatorExpression.Left>
                            <ns0:CodeMethodInvokeExpression>
                              <ns0:CodeMethodInvokeExpression.Parameters>
                                <ns0:CodePrimitiveExpression>
                                  <ns0:CodePrimitiveExpression.Value>
                                    <ns1:String xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">UltimateSoftware.Notifications.InitiatedFor</ns1:String>
                                  </ns0:CodePrimitiveExpression.Value>
                                </ns0:CodePrimitiveExpression>
                              </ns0:CodeMethodInvokeExpression.Parameters>
                              <ns0:CodeMethodInvokeExpression.Method>
                                <ns0:CodeMethodReferenceExpression MethodName="GetBusinessObjectByType">
                                  <ns0:CodeMethodReferenceExpression.TargetObject>
                                    <ns0:CodeThisReferenceExpression />
                                  </ns0:CodeMethodReferenceExpression.TargetObject>
                                </ns0:CodeMethodReferenceExpression>
                              </ns0:CodeMethodInvokeExpression.Method>
                            </ns0:CodeMethodInvokeExpression>
                          </ns0:CodeBinaryOperatorExpression.Left>
                          <ns0:CodeBinaryOperatorExpression.Right>
                            <ns0:CodePrimitiveExpression />
                          </ns0:CodeBinaryOperatorExpression.Right>
                        </ns0:CodeBinaryOperatorExpression>
                      </ns0:CodeBinaryOperatorExpression.Left>
                      <ns0:CodeBinaryOperatorExpression.Right>
                        <ns0:CodeBinaryOperatorExpression Operator="IdentityInequality">
                          <ns0:CodeBinaryOperatorExpression.Left>
                            <ns0:CodeMethodInvokeExpression>
                              <ns0:CodeMethodInvokeExpression.Parameters>
                                <ns0:CodePrimitiveExpression>
                                  <ns0:CodePrimitiveExpression.Value>
                                    <ns1:String xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">UltimateSoftware.Security.UserContext</ns1:String>
                                  </ns0:CodePrimitiveExpression.Value>
                                </ns0:CodePrimitiveExpression>
                              </ns0:CodeMethodInvokeExpression.Parameters>
                              <ns0:CodeMethodInvokeExpression.Method>
                                <ns0:CodeMethodReferenceExpression MethodName="GetBusinessObjectByType">
                                  <ns0:CodeMethodReferenceExpression.TargetObject>
                                    <ns0:CodeThisReferenceExpression />
                                  </ns0:CodeMethodReferenceExpression.TargetObject>
                                </ns0:CodeMethodReferenceExpression>
                              </ns0:CodeMethodInvokeExpression.Method>
                            </ns0:CodeMethodInvokeExpression>
                          </ns0:CodeBinaryOperatorExpression.Left>
                          <ns0:CodeBinaryOperatorExpression.Right>
                            <ns0:CodePrimitiveExpression />
                          </ns0:CodeBinaryOperatorExpression.Right>
                        </ns0:CodeBinaryOperatorExpression>
                      </ns0:CodeBinaryOperatorExpression.Right>
                    </ns0:CodeBinaryOperatorExpression>
                  </ns0:CodeBinaryOperatorExpression.Left>
                  <ns0:CodeBinaryOperatorExpression.Right>
                    <ns0:CodeBinaryOperatorExpression Operator="BooleanAnd">
                      <ns0:CodeBinaryOperatorExpression.Left>
                        <ns0:CodeBinaryOperatorExpression Operator="BooleanAnd">
                          <ns0:CodeBinaryOperatorExpression.Left>
                            <ns0:CodeBinaryOperatorExpression Operator="ValueEquality">
                              <ns0:CodeBinaryOperatorExpression.Left>
                                <ns0:CodeMethodInvokeExpression>
                                  <ns0:CodeMethodInvokeExpression.Parameters>
                                    <ns0:CodePrimitiveExpression>
                                      <ns0:CodePrimitiveExpression.Value>
                                        <ns1:String xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">MSS</ns1:String>
                                      </ns0:CodePrimitiveExpression.Value>
                                    </ns0:CodePrimitiveExpression>
                                  </ns0:CodeMethodInvokeExpression.Parameters>
                                  <ns0:CodeMethodInvokeExpression.Method>
                                    <ns0:CodeMethodReferenceExpression MethodName="IsValidProductKey">
                                      <ns0:CodeMethodReferenceExpression.TargetObject>
                                        <ns0:CodeThisReferenceExpression />
                                      </ns0:CodeMethodReferenceExpression.TargetObject>
                                    </ns0:CodeMethodReferenceExpression>
                                  </ns0:CodeMethodInvokeExpression.Method>
                                </ns0:CodeMethodInvokeExpression>
                              </ns0:CodeBinaryOperatorExpression.Left>
                              <ns0:CodeBinaryOperatorExpression.Right>
                                <ns0:CodePrimitiveExpression>
                                  <ns0:CodePrimitiveExpression.Value>
                                    <ns1:Boolean xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">true</ns1:Boolean>
                                  </ns0:CodePrimitiveExpression.Value>
                                </ns0:CodePrimitiveExpression>
                              </ns0:CodeBinaryOperatorExpression.Right>
                            </ns0:CodeBinaryOperatorExpression>
                          </ns0:CodeBinaryOperatorExpression.Left>
                          <ns0:CodeBinaryOperatorExpression.Right>
                            <ns0:CodeBinaryOperatorExpression Operator="IdentityInequality">
                              <ns0:CodeBinaryOperatorExpression.Left>
                                <ns0:CodeMethodInvokeExpression>
                                  <ns0:CodeMethodInvokeExpression.Parameters>
                                    <ns0:CodePrimitiveExpression>
                                      <ns0:CodePrimitiveExpression.Value>
                                        <ns1:String xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">MSS</ns1:String>
                                      </ns0:CodePrimitiveExpression.Value>
                                    </ns0:CodePrimitiveExpression>
                                  </ns0:CodeMethodInvokeExpression.Parameters>
                                  <ns0:CodeMethodInvokeExpression.Method>
                                    <ns0:CodeMethodReferenceExpression MethodName="GetValueByName">
                                      <ns0:CodeMethodReferenceExpression.TargetObject>
                                        <ns0:CodeThisReferenceExpression />
                                      </ns0:CodeMethodReferenceExpression.TargetObject>
                                    </ns0:CodeMethodReferenceExpression>
                                  </ns0:CodeMethodInvokeExpression.Method>
                                </ns0:CodeMethodInvokeExpression>
                              </ns0:CodeBinaryOperatorExpression.Left>
                              <ns0:CodeBinaryOperatorExpression.Right>
                                <ns0:CodePrimitiveExpression />
                              </ns0:CodeBinaryOperatorExpression.Right>
                            </ns0:CodeBinaryOperatorExpression>
                          </ns0:CodeBinaryOperatorExpression.Right>
                        </ns0:CodeBinaryOperatorExpression>
                      </ns0:CodeBinaryOperatorExpression.Left>
                      <ns0:CodeBinaryOperatorExpression.Right>
                        <ns0:CodeBinaryOperatorExpression Operator="ValueEquality">
                          <ns0:CodeBinaryOperatorExpression.Left>
                            <ns0:CodeCastExpression TargetType="System.String, mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">
                              <ns0:CodeCastExpression.Expression>
                                <ns0:CodeMethodInvokeExpression>
                                  <ns0:CodeMethodInvokeExpression.Parameters>
                                    <ns0:CodePrimitiveExpression>
                                      <ns0:CodePrimitiveExpression.Value>
                                        <ns1:String xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">MSS</ns1:String>
                                      </ns0:CodePrimitiveExpression.Value>
                                    </ns0:CodePrimitiveExpression>
                                  </ns0:CodeMethodInvokeExpression.Parameters>
                                  <ns0:CodeMethodInvokeExpression.Method>
                                    <ns0:CodeMethodReferenceExpression MethodName="GetValueByName">
                                      <ns0:CodeMethodReferenceExpression.TargetObject>
                                        <ns0:CodeThisReferenceExpression />
                                      </ns0:CodeMethodReferenceExpression.TargetObject>
                                    </ns0:CodeMethodReferenceExpression>
                                  </ns0:CodeMethodInvokeExpression.Method>
                                </ns0:CodeMethodInvokeExpression>
                              </ns0:CodeCastExpression.Expression>
                            </ns0:CodeCastExpression>
                          </ns0:CodeBinaryOperatorExpression.Left>
                          <ns0:CodeBinaryOperatorExpression.Right>
                            <ns0:CodePrimitiveExpression>
                              <ns0:CodePrimitiveExpression.Value>
                                <ns1:String xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">MSS</ns1:String>
                              </ns0:CodePrimitiveExpression.Value>
                            </ns0:CodePrimitiveExpression>
                          </ns0:CodeBinaryOperatorExpression.Right>
                        </ns0:CodeBinaryOperatorExpression>
                      </ns0:CodeBinaryOperatorExpression.Right>
                    </ns0:CodeBinaryOperatorExpression>
                  </ns0:CodeBinaryOperatorExpression.Right>
                </ns0:CodeBinaryOperatorExpression>
              </ns0:CodeBinaryOperatorExpression.Left>
              <ns0:CodeBinaryOperatorExpression.Right>
                <ns0:CodeBinaryOperatorExpression Operator="BooleanAnd">
                  <ns0:CodeBinaryOperatorExpression.Left>
                    <ns0:CodeBinaryOperatorExpression Operator="IdentityInequality">
                      <ns0:CodeBinaryOperatorExpression.Left>
                        <ns0:CodeMethodInvokeExpression>
                          <ns0:CodeMethodInvokeExpression.Parameters>
                            <ns0:CodePrimitiveExpression>
                              <ns0:CodePrimitiveExpression.Value>
                                <ns1:String xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">Add</ns1:String>
                              </ns0:CodePrimitiveExpression.Value>
                            </ns0:CodePrimitiveExpression>
                          </ns0:CodeMethodInvokeExpression.Parameters>
                          <ns0:CodeMethodInvokeExpression.Method>
                            <ns0:CodeMethodReferenceExpression MethodName="GetValueByName">
                              <ns0:CodeMethodReferenceExpression.TargetObject>
                                <ns0:CodeThisReferenceExpression />
                              </ns0:CodeMethodReferenceExpression.TargetObject>
                            </ns0:CodeMethodReferenceExpression>
                          </ns0:CodeMethodInvokeExpression.Method>
                        </ns0:CodeMethodInvokeExpression>
                      </ns0:CodeBinaryOperatorExpression.Left>
                      <ns0:CodeBinaryOperatorExpression.Right>
                        <ns0:CodePrimitiveExpression />
                      </ns0:CodeBinaryOperatorExpression.Right>
                    </ns0:CodeBinaryOperatorExpression>
                  </ns0:CodeBinaryOperatorExpression.Left>
                  <ns0:CodeBinaryOperatorExpression.Right>
                    <ns0:CodeBinaryOperatorExpression Operator="ValueEquality">
                      <ns0:CodeBinaryOperatorExpression.Left>
                        <ns0:CodeCastExpression TargetType="System.Int32, mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">
                          <ns0:CodeCastExpression.Expression>
                            <ns0:CodeMethodInvokeExpression>
                              <ns0:CodeMethodInvokeExpression.Parameters>
                                <ns0:CodePrimitiveExpression>
                                  <ns0:CodePrimitiveExpression.Value>
                                    <ns1:String xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">Add</ns1:String>
                                  </ns0:CodePrimitiveExpression.Value>
                                </ns0:CodePrimitiveExpression>
                              </ns0:CodeMethodInvokeExpression.Parameters>
                              <ns0:CodeMethodInvokeExpression.Method>
                                <ns0:CodeMethodReferenceExpression MethodName="GetValueByName">
                                  <ns0:CodeMethodReferenceExpression.TargetObject>
                                    <ns0:CodeThisReferenceExpression />
                                  </ns0:CodeMethodReferenceExpression.TargetObject>
                                </ns0:CodeMethodReferenceExpression>
                              </ns0:CodeMethodInvokeExpression.Method>
                            </ns0:CodeMethodInvokeExpression>
                          </ns0:CodeCastExpression.Expression>
                        </ns0:CodeCastExpression>
                      </ns0:CodeBinaryOperatorExpression.Left>
                      <ns0:CodeBinaryOperatorExpression.Right>
                        <ns0:CodePrimitiveExpression>
                          <ns0:CodePrimitiveExpression.Value>
                            <ns1:Int32 xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">0</ns1:Int32>
                          </ns0:CodePrimitiveExpression.Value>
                        </ns0:CodePrimitiveExpression>
                      </ns0:CodeBinaryOperatorExpression.Right>
                    </ns0:CodeBinaryOperatorExpression>
                  </ns0:CodeBinaryOperatorExpression.Right>
                </ns0:CodeBinaryOperatorExpression>
              </ns0:CodeBinaryOperatorExpression.Right>
            </ns0:CodeBinaryOperatorExpression>
          </RuleExpressionCondition.Expression>
        </RuleExpressionCondition>
      </Rule.Condition>
    </Rule>
    <Rule Name="MANGR-Change-5" ReevaluationBehavior="Always" Priority="5" Description="{p1:Null}" Active="True">
      <Rule.ThenActions>
        <RuleStatementAction>
          <RuleStatementAction.CodeDomStatement>
            <ns0:CodeAssignStatement xmlns:ns0="clr-namespace:System.CodeDom;Assembly=System, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" LinePragma="{p1:Null}">
              <ns0:CodeAssignStatement.Left>
                <ns0:CodePropertyReferenceExpression PropertyName="Result">
                  <ns0:CodePropertyReferenceExpression.TargetObject>
                    <ns0:CodeThisReferenceExpression />
                  </ns0:CodePropertyReferenceExpression.TargetObject>
                </ns0:CodePropertyReferenceExpression>
              </ns0:CodeAssignStatement.Left>
              <ns0:CodeAssignStatement.Right>
                <ns0:CodePrimitiveExpression>
                  <ns0:CodePrimitiveExpression.Value>
                    <ns1:String xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">MANAGERBPDID</ns1:String>
                  </ns0:CodePrimitiveExpression.Value>
                </ns0:CodePrimitiveExpression>
              </ns0:CodeAssignStatement.Right>
            </ns0:CodeAssignStatement>
          </RuleStatementAction.CodeDomStatement>
        </RuleStatementAction>
      </Rule.ThenActions>
      <Rule.Condition>
        <RuleExpressionCondition Name="{p1:Null}">
          <RuleExpressionCondition.Expression>
            <ns0:CodeBinaryOperatorExpression xmlns:ns0="clr-namespace:System.CodeDom;Assembly=System, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" Operator="BooleanAnd">
              <ns0:CodeBinaryOperatorExpression.Left>
                <ns0:CodeBinaryOperatorExpression Operator="BooleanAnd">
                  <ns0:CodeBinaryOperatorExpression.Left>
                    <ns0:CodeBinaryOperatorExpression Operator="BooleanAnd">
                      <ns0:CodeBinaryOperatorExpression.Left>
                        <ns0:CodeBinaryOperatorExpression Operator="IdentityInequality">
                          <ns0:CodeBinaryOperatorExpression.Left>
                            <ns0:CodeMethodInvokeExpression>
                              <ns0:CodeMethodInvokeExpression.Parameters>
                                <ns0:CodePrimitiveExpression>
                                  <ns0:CodePrimitiveExpression.Value>
                                    <ns1:String xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">UltimateSoftware.Notifications.InitiatedFor</ns1:String>
                                  </ns0:CodePrimitiveExpression.Value>
                                </ns0:CodePrimitiveExpression>
                              </ns0:CodeMethodInvokeExpression.Parameters>
                              <ns0:CodeMethodInvokeExpression.Method>
                                <ns0:CodeMethodReferenceExpression MethodName="GetBusinessObjectByType">
                                  <ns0:CodeMethodReferenceExpression.TargetObject>
                                    <ns0:CodeThisReferenceExpression />
                                  </ns0:CodeMethodReferenceExpression.TargetObject>
                                </ns0:CodeMethodReferenceExpression>
                              </ns0:CodeMethodInvokeExpression.Method>
                            </ns0:CodeMethodInvokeExpression>
                          </ns0:CodeBinaryOperatorExpression.Left>
                          <ns0:CodeBinaryOperatorExpression.Right>
                            <ns0:CodePrimitiveExpression />
                          </ns0:CodeBinaryOperatorExpression.Right>
                        </ns0:CodeBinaryOperatorExpression>
                      </ns0:CodeBinaryOperatorExpression.Left>
                      <ns0:CodeBinaryOperatorExpression.Right>
                        <ns0:CodeBinaryOperatorExpression Operator="IdentityInequality">
                          <ns0:CodeBinaryOperatorExpression.Left>
                            <ns0:CodeMethodInvokeExpression>
                              <ns0:CodeMethodInvokeExpression.Parameters>
                                <ns0:CodePrimitiveExpression>
                                  <ns0:CodePrimitiveExpression.Value>
                                    <ns1:String xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">UltimateSoftware.Security.UserContext</ns1:String>
                                  </ns0:CodePrimitiveExpression.Value>
                                </ns0:CodePrimitiveExpression>
                              </ns0:CodeMethodInvokeExpression.Parameters>
                              <ns0:CodeMethodInvokeExpression.Method>
                                <ns0:CodeMethodReferenceExpression MethodName="GetBusinessObjectByType">
                                  <ns0:CodeMethodReferenceExpression.TargetObject>
                                    <ns0:CodeThisReferenceExpression />
                                  </ns0:CodeMethodReferenceExpression.TargetObject>
                                </ns0:CodeMethodReferenceExpression>
                              </ns0:CodeMethodInvokeExpression.Method>
                            </ns0:CodeMethodInvokeExpression>
                          </ns0:CodeBinaryOperatorExpression.Left>
                          <ns0:CodeBinaryOperatorExpression.Right>
                            <ns0:CodePrimitiveExpression />
                          </ns0:CodeBinaryOperatorExpression.Right>
                        </ns0:CodeBinaryOperatorExpression>
                      </ns0:CodeBinaryOperatorExpression.Right>
                    </ns0:CodeBinaryOperatorExpression>
                  </ns0:CodeBinaryOperatorExpression.Left>
                  <ns0:CodeBinaryOperatorExpression.Right>
                    <ns0:CodeBinaryOperatorExpression Operator="BooleanAnd">
                      <ns0:CodeBinaryOperatorExpression.Left>
                        <ns0:CodeBinaryOperatorExpression Operator="BooleanAnd">
                          <ns0:CodeBinaryOperatorExpression.Left>
                            <ns0:CodeBinaryOperatorExpression Operator="ValueEquality">
                              <ns0:CodeBinaryOperatorExpression.Left>
                                <ns0:CodeMethodInvokeExpression>
                                  <ns0:CodeMethodInvokeExpression.Parameters>
                                    <ns0:CodePrimitiveExpression>
                                      <ns0:CodePrimitiveExpression.Value>
                                        <ns1:String xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">MSS</ns1:String>
                                      </ns0:CodePrimitiveExpression.Value>
                                    </ns0:CodePrimitiveExpression>
                                  </ns0:CodeMethodInvokeExpression.Parameters>
                                  <ns0:CodeMethodInvokeExpression.Method>
                                    <ns0:CodeMethodReferenceExpression MethodName="IsValidProductKey">
                                      <ns0:CodeMethodReferenceExpression.TargetObject>
                                        <ns0:CodeThisReferenceExpression />
                                      </ns0:CodeMethodReferenceExpression.TargetObject>
                                    </ns0:CodeMethodReferenceExpression>
                                  </ns0:CodeMethodInvokeExpression.Method>
                                </ns0:CodeMethodInvokeExpression>
                              </ns0:CodeBinaryOperatorExpression.Left>
                              <ns0:CodeBinaryOperatorExpression.Right>
                                <ns0:CodePrimitiveExpression>
                                  <ns0:CodePrimitiveExpression.Value>
                                    <ns1:Boolean xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">true</ns1:Boolean>
                                  </ns0:CodePrimitiveExpression.Value>
                                </ns0:CodePrimitiveExpression>
                              </ns0:CodeBinaryOperatorExpression.Right>
                            </ns0:CodeBinaryOperatorExpression>
                          </ns0:CodeBinaryOperatorExpression.Left>
                          <ns0:CodeBinaryOperatorExpression.Right>
                            <ns0:CodeBinaryOperatorExpression Operator="IdentityInequality">
                              <ns0:CodeBinaryOperatorExpression.Left>
                                <ns0:CodeMethodInvokeExpression>
                                  <ns0:CodeMethodInvokeExpression.Parameters>
                                    <ns0:CodePrimitiveExpression>
                                      <ns0:CodePrimitiveExpression.Value>
                                        <ns1:String xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">MSS</ns1:String>
                                      </ns0:CodePrimitiveExpression.Value>
                                    </ns0:CodePrimitiveExpression>
                                  </ns0:CodeMethodInvokeExpression.Parameters>
                                  <ns0:CodeMethodInvokeExpression.Method>
                                    <ns0:CodeMethodReferenceExpression MethodName="GetValueByName">
                                      <ns0:CodeMethodReferenceExpression.TargetObject>
                                        <ns0:CodeThisReferenceExpression />
                                      </ns0:CodeMethodReferenceExpression.TargetObject>
                                    </ns0:CodeMethodReferenceExpression>
                                  </ns0:CodeMethodInvokeExpression.Method>
                                </ns0:CodeMethodInvokeExpression>
                              </ns0:CodeBinaryOperatorExpression.Left>
                              <ns0:CodeBinaryOperatorExpression.Right>
                                <ns0:CodePrimitiveExpression />
                              </ns0:CodeBinaryOperatorExpression.Right>
                            </ns0:CodeBinaryOperatorExpression>
                          </ns0:CodeBinaryOperatorExpression.Right>
                        </ns0:CodeBinaryOperatorExpression>
                      </ns0:CodeBinaryOperatorExpression.Left>
                      <ns0:CodeBinaryOperatorExpression.Right>
                        <ns0:CodeBinaryOperatorExpression Operator="ValueEquality">
                          <ns0:CodeBinaryOperatorExpression.Left>
                            <ns0:CodeCastExpression TargetType="System.String, mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">
                              <ns0:CodeCastExpression.Expression>
                                <ns0:CodeMethodInvokeExpression>
                                  <ns0:CodeMethodInvokeExpression.Parameters>
                                    <ns0:CodePrimitiveExpression>
                                      <ns0:CodePrimitiveExpression.Value>
                                        <ns1:String xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">MSS</ns1:String>
                                      </ns0:CodePrimitiveExpression.Value>
                                    </ns0:CodePrimitiveExpression>
                                  </ns0:CodeMethodInvokeExpression.Parameters>
                                  <ns0:CodeMethodInvokeExpression.Method>
                                    <ns0:CodeMethodReferenceExpression MethodName="GetValueByName">
                                      <ns0:CodeMethodReferenceExpression.TargetObject>
                                        <ns0:CodeThisReferenceExpression />
                                      </ns0:CodeMethodReferenceExpression.TargetObject>
                                    </ns0:CodeMethodReferenceExpression>
                                  </ns0:CodeMethodInvokeExpression.Method>
                                </ns0:CodeMethodInvokeExpression>
                              </ns0:CodeCastExpression.Expression>
                            </ns0:CodeCastExpression>
                          </ns0:CodeBinaryOperatorExpression.Left>
                          <ns0:CodeBinaryOperatorExpression.Right>
                            <ns0:CodePrimitiveExpression>
                              <ns0:CodePrimitiveExpression.Value>
                                <ns1:String xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">MSS</ns1:String>
                              </ns0:CodePrimitiveExpression.Value>
                            </ns0:CodePrimitiveExpression>
                          </ns0:CodeBinaryOperatorExpression.Right>
                        </ns0:CodeBinaryOperatorExpression>
                      </ns0:CodeBinaryOperatorExpression.Right>
                    </ns0:CodeBinaryOperatorExpression>
                  </ns0:CodeBinaryOperatorExpression.Right>
                </ns0:CodeBinaryOperatorExpression>
              </ns0:CodeBinaryOperatorExpression.Left>
              <ns0:CodeBinaryOperatorExpression.Right>
                <ns0:CodeBinaryOperatorExpression Operator="BooleanAnd">
                  <ns0:CodeBinaryOperatorExpression.Left>
                    <ns0:CodeBinaryOperatorExpression Operator="IdentityInequality">
                      <ns0:CodeBinaryOperatorExpression.Left>
                        <ns0:CodeMethodInvokeExpression>
                          <ns0:CodeMethodInvokeExpression.Parameters>
                            <ns0:CodePrimitiveExpression>
                              <ns0:CodePrimitiveExpression.Value>
                                <ns1:String xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">Change</ns1:String>
                              </ns0:CodePrimitiveExpression.Value>
                            </ns0:CodePrimitiveExpression>
                          </ns0:CodeMethodInvokeExpression.Parameters>
                          <ns0:CodeMethodInvokeExpression.Method>
                            <ns0:CodeMethodReferenceExpression MethodName="GetValueByName">
                              <ns0:CodeMethodReferenceExpression.TargetObject>
                                <ns0:CodeThisReferenceExpression />
                              </ns0:CodeMethodReferenceExpression.TargetObject>
                            </ns0:CodeMethodReferenceExpression>
                          </ns0:CodeMethodInvokeExpression.Method>
                        </ns0:CodeMethodInvokeExpression>
                      </ns0:CodeBinaryOperatorExpression.Left>
                      <ns0:CodeBinaryOperatorExpression.Right>
                        <ns0:CodePrimitiveExpression />
                      </ns0:CodeBinaryOperatorExpression.Right>
                    </ns0:CodeBinaryOperatorExpression>
                  </ns0:CodeBinaryOperatorExpression.Left>
                  <ns0:CodeBinaryOperatorExpression.Right>
                    <ns0:CodeBinaryOperatorExpression Operator="ValueEquality">
                      <ns0:CodeBinaryOperatorExpression.Left>
                        <ns0:CodeCastExpression TargetType="System.Int32, mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">
                          <ns0:CodeCastExpression.Expression>
                            <ns0:CodeMethodInvokeExpression>
                              <ns0:CodeMethodInvokeExpression.Parameters>
                                <ns0:CodePrimitiveExpression>
                                  <ns0:CodePrimitiveExpression.Value>
                                    <ns1:String xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">Change</ns1:String>
                                  </ns0:CodePrimitiveExpression.Value>
                                </ns0:CodePrimitiveExpression>
                              </ns0:CodeMethodInvokeExpression.Parameters>
                              <ns0:CodeMethodInvokeExpression.Method>
                                <ns0:CodeMethodReferenceExpression MethodName="GetValueByName">
                                  <ns0:CodeMethodReferenceExpression.TargetObject>
                                    <ns0:CodeThisReferenceExpression />
                                  </ns0:CodeMethodReferenceExpression.TargetObject>
                                </ns0:CodeMethodReferenceExpression>
                              </ns0:CodeMethodInvokeExpression.Method>
                            </ns0:CodeMethodInvokeExpression>
                          </ns0:CodeCastExpression.Expression>
                        </ns0:CodeCastExpression>
                      </ns0:CodeBinaryOperatorExpression.Left>
                      <ns0:CodeBinaryOperatorExpression.Right>
                        <ns0:CodePrimitiveExpression>
                          <ns0:CodePrimitiveExpression.Value>
                            <ns1:Int32 xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">1</ns1:Int32>
                          </ns0:CodePrimitiveExpression.Value>
                        </ns0:CodePrimitiveExpression>
                      </ns0:CodeBinaryOperatorExpression.Right>
                    </ns0:CodeBinaryOperatorExpression>
                  </ns0:CodeBinaryOperatorExpression.Right>
                </ns0:CodeBinaryOperatorExpression>
              </ns0:CodeBinaryOperatorExpression.Right>
            </ns0:CodeBinaryOperatorExpression>
          </RuleExpressionCondition.Expression>
        </RuleExpressionCondition>
      </Rule.Condition>
    </Rule>
    <Rule Name="MANGR-Delete-6" ReevaluationBehavior="Always" Priority="6" Description="{p1:Null}" Active="True">
      <Rule.ThenActions>
        <RuleStatementAction>
          <RuleStatementAction.CodeDomStatement>
            <ns0:CodeAssignStatement xmlns:ns0="clr-namespace:System.CodeDom;Assembly=System, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" LinePragma="{p1:Null}">
              <ns0:CodeAssignStatement.Left>
                <ns0:CodePropertyReferenceExpression PropertyName="Result">
                  <ns0:CodePropertyReferenceExpression.TargetObject>
                    <ns0:CodeThisReferenceExpression />
                  </ns0:CodePropertyReferenceExpression.TargetObject>
                </ns0:CodePropertyReferenceExpression>
              </ns0:CodeAssignStatement.Left>
              <ns0:CodeAssignStatement.Right>
                <ns0:CodePrimitiveExpression>
                  <ns0:CodePrimitiveExpression.Value>
                    <ns1:String xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">MANAGERBPDID</ns1:String>
                  </ns0:CodePrimitiveExpression.Value>
                </ns0:CodePrimitiveExpression>
              </ns0:CodeAssignStatement.Right>
            </ns0:CodeAssignStatement>
          </RuleStatementAction.CodeDomStatement>
        </RuleStatementAction>
      </Rule.ThenActions>
      <Rule.Condition>
        <RuleExpressionCondition Name="{p1:Null}">
          <RuleExpressionCondition.Expression>
            <ns0:CodeBinaryOperatorExpression xmlns:ns0="clr-namespace:System.CodeDom;Assembly=System, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" Operator="BooleanAnd">
              <ns0:CodeBinaryOperatorExpression.Left>
                <ns0:CodeBinaryOperatorExpression Operator="BooleanAnd">
                  <ns0:CodeBinaryOperatorExpression.Left>
                    <ns0:CodeBinaryOperatorExpression Operator="BooleanAnd">
                      <ns0:CodeBinaryOperatorExpression.Left>
                        <ns0:CodeBinaryOperatorExpression Operator="IdentityInequality">
                          <ns0:CodeBinaryOperatorExpression.Left>
                            <ns0:CodeMethodInvokeExpression>
                              <ns0:CodeMethodInvokeExpression.Parameters>
                                <ns0:CodePrimitiveExpression>
                                  <ns0:CodePrimitiveExpression.Value>
                                    <ns1:String xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">UltimateSoftware.Notifications.InitiatedFor</ns1:String>
                                  </ns0:CodePrimitiveExpression.Value>
                                </ns0:CodePrimitiveExpression>
                              </ns0:CodeMethodInvokeExpression.Parameters>
                              <ns0:CodeMethodInvokeExpression.Method>
                                <ns0:CodeMethodReferenceExpression MethodName="GetBusinessObjectByType">
                                  <ns0:CodeMethodReferenceExpression.TargetObject>
                                    <ns0:CodeThisReferenceExpression />
                                  </ns0:CodeMethodReferenceExpression.TargetObject>
                                </ns0:CodeMethodReferenceExpression>
                              </ns0:CodeMethodInvokeExpression.Method>
                            </ns0:CodeMethodInvokeExpression>
                          </ns0:CodeBinaryOperatorExpression.Left>
                          <ns0:CodeBinaryOperatorExpression.Right>
                            <ns0:CodePrimitiveExpression />
                          </ns0:CodeBinaryOperatorExpression.Right>
                        </ns0:CodeBinaryOperatorExpression>
                      </ns0:CodeBinaryOperatorExpression.Left>
                      <ns0:CodeBinaryOperatorExpression.Right>
                        <ns0:CodeBinaryOperatorExpression Operator="IdentityInequality">
                          <ns0:CodeBinaryOperatorExpression.Left>
                            <ns0:CodeMethodInvokeExpression>
                              <ns0:CodeMethodInvokeExpression.Parameters>
                                <ns0:CodePrimitiveExpression>
                                  <ns0:CodePrimitiveExpression.Value>
                                    <ns1:String xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">UltimateSoftware.Security.UserContext</ns1:String>
                                  </ns0:CodePrimitiveExpression.Value>
                                </ns0:CodePrimitiveExpression>
                              </ns0:CodeMethodInvokeExpression.Parameters>
                              <ns0:CodeMethodInvokeExpression.Method>
                                <ns0:CodeMethodReferenceExpression MethodName="GetBusinessObjectByType">
                                  <ns0:CodeMethodReferenceExpression.TargetObject>
                                    <ns0:CodeThisReferenceExpression />
                                  </ns0:CodeMethodReferenceExpression.TargetObject>
                                </ns0:CodeMethodReferenceExpression>
                              </ns0:CodeMethodInvokeExpression.Method>
                            </ns0:CodeMethodInvokeExpression>
                          </ns0:CodeBinaryOperatorExpression.Left>
                          <ns0:CodeBinaryOperatorExpression.Right>
                            <ns0:CodePrimitiveExpression />
                          </ns0:CodeBinaryOperatorExpression.Right>
                        </ns0:CodeBinaryOperatorExpression>
                      </ns0:CodeBinaryOperatorExpression.Right>
                    </ns0:CodeBinaryOperatorExpression>
                  </ns0:CodeBinaryOperatorExpression.Left>
                  <ns0:CodeBinaryOperatorExpression.Right>
                    <ns0:CodeBinaryOperatorExpression Operator="BooleanAnd">
                      <ns0:CodeBinaryOperatorExpression.Left>
                        <ns0:CodeBinaryOperatorExpression Operator="BooleanAnd">
                          <ns0:CodeBinaryOperatorExpression.Left>
                            <ns0:CodeBinaryOperatorExpression Operator="ValueEquality">
                              <ns0:CodeBinaryOperatorExpression.Left>
                                <ns0:CodeMethodInvokeExpression>
                                  <ns0:CodeMethodInvokeExpression.Parameters>
                                    <ns0:CodePrimitiveExpression>
                                      <ns0:CodePrimitiveExpression.Value>
                                        <ns1:String xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">MSS</ns1:String>
                                      </ns0:CodePrimitiveExpression.Value>
                                    </ns0:CodePrimitiveExpression>
                                  </ns0:CodeMethodInvokeExpression.Parameters>
                                  <ns0:CodeMethodInvokeExpression.Method>
                                    <ns0:CodeMethodReferenceExpression MethodName="IsValidProductKey">
                                      <ns0:CodeMethodReferenceExpression.TargetObject>
                                        <ns0:CodeThisReferenceExpression />
                                      </ns0:CodeMethodReferenceExpression.TargetObject>
                                    </ns0:CodeMethodReferenceExpression>
                                  </ns0:CodeMethodInvokeExpression.Method>
                                </ns0:CodeMethodInvokeExpression>
                              </ns0:CodeBinaryOperatorExpression.Left>
                              <ns0:CodeBinaryOperatorExpression.Right>
                                <ns0:CodePrimitiveExpression>
                                  <ns0:CodePrimitiveExpression.Value>
                                    <ns1:Boolean xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">true</ns1:Boolean>
                                  </ns0:CodePrimitiveExpression.Value>
                                </ns0:CodePrimitiveExpression>
                              </ns0:CodeBinaryOperatorExpression.Right>
                            </ns0:CodeBinaryOperatorExpression>
                          </ns0:CodeBinaryOperatorExpression.Left>
                          <ns0:CodeBinaryOperatorExpression.Right>
                            <ns0:CodeBinaryOperatorExpression Operator="IdentityInequality">
                              <ns0:CodeBinaryOperatorExpression.Left>
                                <ns0:CodeMethodInvokeExpression>
                                  <ns0:CodeMethodInvokeExpression.Parameters>
                                    <ns0:CodePrimitiveExpression>
                                      <ns0:CodePrimitiveExpression.Value>
                                        <ns1:String xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">MSS</ns1:String>
                                      </ns0:CodePrimitiveExpression.Value>
                                    </ns0:CodePrimitiveExpression>
                                  </ns0:CodeMethodInvokeExpression.Parameters>
                                  <ns0:CodeMethodInvokeExpression.Method>
                                    <ns0:CodeMethodReferenceExpression MethodName="GetValueByName">
                                      <ns0:CodeMethodReferenceExpression.TargetObject>
                                        <ns0:CodeThisReferenceExpression />
                                      </ns0:CodeMethodReferenceExpression.TargetObject>
                                    </ns0:CodeMethodReferenceExpression>
                                  </ns0:CodeMethodInvokeExpression.Method>
                                </ns0:CodeMethodInvokeExpression>
                              </ns0:CodeBinaryOperatorExpression.Left>
                              <ns0:CodeBinaryOperatorExpression.Right>
                                <ns0:CodePrimitiveExpression />
                              </ns0:CodeBinaryOperatorExpression.Right>
                            </ns0:CodeBinaryOperatorExpression>
                          </ns0:CodeBinaryOperatorExpression.Right>
                        </ns0:CodeBinaryOperatorExpression>
                      </ns0:CodeBinaryOperatorExpression.Left>
                      <ns0:CodeBinaryOperatorExpression.Right>
                        <ns0:CodeBinaryOperatorExpression Operator="ValueEquality">
                          <ns0:CodeBinaryOperatorExpression.Left>
                            <ns0:CodeCastExpression TargetType="System.String, mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">
                              <ns0:CodeCastExpression.Expression>
                                <ns0:CodeMethodInvokeExpression>
                                  <ns0:CodeMethodInvokeExpression.Parameters>
                                    <ns0:CodePrimitiveExpression>
                                      <ns0:CodePrimitiveExpression.Value>
                                        <ns1:String xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">MSS</ns1:String>
                                      </ns0:CodePrimitiveExpression.Value>
                                    </ns0:CodePrimitiveExpression>
                                  </ns0:CodeMethodInvokeExpression.Parameters>
                                  <ns0:CodeMethodInvokeExpression.Method>
                                    <ns0:CodeMethodReferenceExpression MethodName="GetValueByName">
                                      <ns0:CodeMethodReferenceExpression.TargetObject>
                                        <ns0:CodeThisReferenceExpression />
                                      </ns0:CodeMethodReferenceExpression.TargetObject>
                                    </ns0:CodeMethodReferenceExpression>
                                  </ns0:CodeMethodInvokeExpression.Method>
                                </ns0:CodeMethodInvokeExpression>
                              </ns0:CodeCastExpression.Expression>
                            </ns0:CodeCastExpression>
                          </ns0:CodeBinaryOperatorExpression.Left>
                          <ns0:CodeBinaryOperatorExpression.Right>
                            <ns0:CodePrimitiveExpression>
                              <ns0:CodePrimitiveExpression.Value>
                                <ns1:String xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">MSS</ns1:String>
                              </ns0:CodePrimitiveExpression.Value>
                            </ns0:CodePrimitiveExpression>
                          </ns0:CodeBinaryOperatorExpression.Right>
                        </ns0:CodeBinaryOperatorExpression>
                      </ns0:CodeBinaryOperatorExpression.Right>
                    </ns0:CodeBinaryOperatorExpression>
                  </ns0:CodeBinaryOperatorExpression.Right>
                </ns0:CodeBinaryOperatorExpression>
              </ns0:CodeBinaryOperatorExpression.Left>
              <ns0:CodeBinaryOperatorExpression.Right>
                <ns0:CodeBinaryOperatorExpression Operator="BooleanAnd">
                  <ns0:CodeBinaryOperatorExpression.Left>
                    <ns0:CodeBinaryOperatorExpression Operator="IdentityInequality">
                      <ns0:CodeBinaryOperatorExpression.Left>
                        <ns0:CodeMethodInvokeExpression>
                          <ns0:CodeMethodInvokeExpression.Parameters>
                            <ns0:CodePrimitiveExpression>
                              <ns0:CodePrimitiveExpression.Value>
                                <ns1:String xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">Delete</ns1:String>
                              </ns0:CodePrimitiveExpression.Value>
                            </ns0:CodePrimitiveExpression>
                          </ns0:CodeMethodInvokeExpression.Parameters>
                          <ns0:CodeMethodInvokeExpression.Method>
                            <ns0:CodeMethodReferenceExpression MethodName="GetValueByName">
                              <ns0:CodeMethodReferenceExpression.TargetObject>
                                <ns0:CodeThisReferenceExpression />
                              </ns0:CodeMethodReferenceExpression.TargetObject>
                            </ns0:CodeMethodReferenceExpression>
                          </ns0:CodeMethodInvokeExpression.Method>
                        </ns0:CodeMethodInvokeExpression>
                      </ns0:CodeBinaryOperatorExpression.Left>
                      <ns0:CodeBinaryOperatorExpression.Right>
                        <ns0:CodePrimitiveExpression />
                      </ns0:CodeBinaryOperatorExpression.Right>
                    </ns0:CodeBinaryOperatorExpression>
                  </ns0:CodeBinaryOperatorExpression.Left>
                  <ns0:CodeBinaryOperatorExpression.Right>
                    <ns0:CodeBinaryOperatorExpression Operator="ValueEquality">
                      <ns0:CodeBinaryOperatorExpression.Left>
                        <ns0:CodeCastExpression TargetType="System.Int32, mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">
                          <ns0:CodeCastExpression.Expression>
                            <ns0:CodeMethodInvokeExpression>
                              <ns0:CodeMethodInvokeExpression.Parameters>
                                <ns0:CodePrimitiveExpression>
                                  <ns0:CodePrimitiveExpression.Value>
                                    <ns1:String xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">Delete</ns1:String>
                                  </ns0:CodePrimitiveExpression.Value>
                                </ns0:CodePrimitiveExpression>
                              </ns0:CodeMethodInvokeExpression.Parameters>
                              <ns0:CodeMethodInvokeExpression.Method>
                                <ns0:CodeMethodReferenceExpression MethodName="GetValueByName">
                                  <ns0:CodeMethodReferenceExpression.TargetObject>
                                    <ns0:CodeThisReferenceExpression />
                                  </ns0:CodeMethodReferenceExpression.TargetObject>
                                </ns0:CodeMethodReferenceExpression>
                              </ns0:CodeMethodInvokeExpression.Method>
                            </ns0:CodeMethodInvokeExpression>
                          </ns0:CodeCastExpression.Expression>
                        </ns0:CodeCastExpression>
                      </ns0:CodeBinaryOperatorExpression.Left>
                      <ns0:CodeBinaryOperatorExpression.Right>
                        <ns0:CodePrimitiveExpression>
                          <ns0:CodePrimitiveExpression.Value>
                            <ns1:Int32 xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">2</ns1:Int32>
                          </ns0:CodePrimitiveExpression.Value>
                        </ns0:CodePrimitiveExpression>
                      </ns0:CodeBinaryOperatorExpression.Right>
                    </ns0:CodeBinaryOperatorExpression>
                  </ns0:CodeBinaryOperatorExpression.Right>
                </ns0:CodeBinaryOperatorExpression>
              </ns0:CodeBinaryOperatorExpression.Right>
            </ns0:CodeBinaryOperatorExpression>
          </RuleExpressionCondition.Expression>
        </RuleExpressionCondition>
      </Rule.Condition>
    </Rule>'
	
	------------------------------------------
	-- Ruleset Template - EEADM
	------------------------------------------
	
	SET @RuleSetEEADM = '
    <Rule Name="ADMIN-Add-7" ReevaluationBehavior="Always" Priority="7" Description="{p1:Null}" Active="True">
      <Rule.ThenActions>
        <RuleStatementAction>
          <RuleStatementAction.CodeDomStatement>
            <ns0:CodeAssignStatement xmlns:ns0="clr-namespace:System.CodeDom;Assembly=System, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" LinePragma="{p1:Null}">
              <ns0:CodeAssignStatement.Left>
                <ns0:CodePropertyReferenceExpression PropertyName="Result">
                  <ns0:CodePropertyReferenceExpression.TargetObject>
                    <ns0:CodeThisReferenceExpression />
                  </ns0:CodePropertyReferenceExpression.TargetObject>
                </ns0:CodePropertyReferenceExpression>
              </ns0:CodeAssignStatement.Left>
              <ns0:CodeAssignStatement.Right>
                <ns0:CodePrimitiveExpression>
                  <ns0:CodePrimitiveExpression.Value>
                    <ns1:String xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">ADMINBPDID</ns1:String>
                  </ns0:CodePrimitiveExpression.Value>
                </ns0:CodePrimitiveExpression>
              </ns0:CodeAssignStatement.Right>
            </ns0:CodeAssignStatement>
          </RuleStatementAction.CodeDomStatement>
        </RuleStatementAction>
      </Rule.ThenActions>
      <Rule.Condition>
        <RuleExpressionCondition Name="{p1:Null}">
          <RuleExpressionCondition.Expression>
            <ns0:CodeBinaryOperatorExpression xmlns:ns0="clr-namespace:System.CodeDom;Assembly=System, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" Operator="BooleanAnd">
              <ns0:CodeBinaryOperatorExpression.Left>
                <ns0:CodeBinaryOperatorExpression Operator="BooleanAnd">
                  <ns0:CodeBinaryOperatorExpression.Left>
                    <ns0:CodeBinaryOperatorExpression Operator="BooleanAnd">
                      <ns0:CodeBinaryOperatorExpression.Left>
                        <ns0:CodeBinaryOperatorExpression Operator="IdentityInequality">
                          <ns0:CodeBinaryOperatorExpression.Left>
                            <ns0:CodeMethodInvokeExpression>
                              <ns0:CodeMethodInvokeExpression.Parameters>
                                <ns0:CodePrimitiveExpression>
                                  <ns0:CodePrimitiveExpression.Value>
                                    <ns1:String xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">UltimateSoftware.Notifications.InitiatedFor</ns1:String>
                                  </ns0:CodePrimitiveExpression.Value>
                                </ns0:CodePrimitiveExpression>
                              </ns0:CodeMethodInvokeExpression.Parameters>
                              <ns0:CodeMethodInvokeExpression.Method>
                                <ns0:CodeMethodReferenceExpression MethodName="GetBusinessObjectByType">
                                  <ns0:CodeMethodReferenceExpression.TargetObject>
                                    <ns0:CodeThisReferenceExpression />
                                  </ns0:CodeMethodReferenceExpression.TargetObject>
                                </ns0:CodeMethodReferenceExpression>
                              </ns0:CodeMethodInvokeExpression.Method>
                            </ns0:CodeMethodInvokeExpression>
                          </ns0:CodeBinaryOperatorExpression.Left>
                          <ns0:CodeBinaryOperatorExpression.Right>
                            <ns0:CodePrimitiveExpression />
                          </ns0:CodeBinaryOperatorExpression.Right>
                        </ns0:CodeBinaryOperatorExpression>
                      </ns0:CodeBinaryOperatorExpression.Left>
                      <ns0:CodeBinaryOperatorExpression.Right>
                        <ns0:CodeBinaryOperatorExpression Operator="IdentityInequality">
                          <ns0:CodeBinaryOperatorExpression.Left>
                            <ns0:CodeMethodInvokeExpression>
                              <ns0:CodeMethodInvokeExpression.Parameters>
                                <ns0:CodePrimitiveExpression>
                                  <ns0:CodePrimitiveExpression.Value>
                                    <ns1:String xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">UltimateSoftware.Security.UserContext</ns1:String>
                                  </ns0:CodePrimitiveExpression.Value>
                                </ns0:CodePrimitiveExpression>
                              </ns0:CodeMethodInvokeExpression.Parameters>
                              <ns0:CodeMethodInvokeExpression.Method>
                                <ns0:CodeMethodReferenceExpression MethodName="GetBusinessObjectByType">
                                  <ns0:CodeMethodReferenceExpression.TargetObject>
                                    <ns0:CodeThisReferenceExpression />
                                  </ns0:CodeMethodReferenceExpression.TargetObject>
                                </ns0:CodeMethodReferenceExpression>
                              </ns0:CodeMethodInvokeExpression.Method>
                            </ns0:CodeMethodInvokeExpression>
                          </ns0:CodeBinaryOperatorExpression.Left>
                          <ns0:CodeBinaryOperatorExpression.Right>
                            <ns0:CodePrimitiveExpression />
                          </ns0:CodeBinaryOperatorExpression.Right>
                        </ns0:CodeBinaryOperatorExpression>
                      </ns0:CodeBinaryOperatorExpression.Right>
                    </ns0:CodeBinaryOperatorExpression>
                  </ns0:CodeBinaryOperatorExpression.Left>
                  <ns0:CodeBinaryOperatorExpression.Right>
                    <ns0:CodeBinaryOperatorExpression Operator="BooleanAnd">
                      <ns0:CodeBinaryOperatorExpression.Left>
                        <ns0:CodeBinaryOperatorExpression Operator="BooleanAnd">
                          <ns0:CodeBinaryOperatorExpression.Left>
                            <ns0:CodeBinaryOperatorExpression Operator="ValueEquality">
                              <ns0:CodeBinaryOperatorExpression.Left>
                                <ns0:CodeMethodInvokeExpression>
                                  <ns0:CodeMethodInvokeExpression.Parameters>
                                    <ns0:CodePrimitiveExpression>
                                      <ns0:CodePrimitiveExpression.Value>
                                        <ns1:String xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">EEADM</ns1:String>
                                      </ns0:CodePrimitiveExpression.Value>
                                    </ns0:CodePrimitiveExpression>
                                  </ns0:CodeMethodInvokeExpression.Parameters>
                                  <ns0:CodeMethodInvokeExpression.Method>
                                    <ns0:CodeMethodReferenceExpression MethodName="IsValidProductKey">
                                      <ns0:CodeMethodReferenceExpression.TargetObject>
                                        <ns0:CodeThisReferenceExpression />
                                      </ns0:CodeMethodReferenceExpression.TargetObject>
                                    </ns0:CodeMethodReferenceExpression>
                                  </ns0:CodeMethodInvokeExpression.Method>
                                </ns0:CodeMethodInvokeExpression>
                              </ns0:CodeBinaryOperatorExpression.Left>
                              <ns0:CodeBinaryOperatorExpression.Right>
                                <ns0:CodePrimitiveExpression>
                                  <ns0:CodePrimitiveExpression.Value>
                                    <ns1:Boolean xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">true</ns1:Boolean>
                                  </ns0:CodePrimitiveExpression.Value>
                                </ns0:CodePrimitiveExpression>
                              </ns0:CodeBinaryOperatorExpression.Right>
                            </ns0:CodeBinaryOperatorExpression>
                          </ns0:CodeBinaryOperatorExpression.Left>
                          <ns0:CodeBinaryOperatorExpression.Right>
                            <ns0:CodeBinaryOperatorExpression Operator="IdentityInequality">
                              <ns0:CodeBinaryOperatorExpression.Left>
                                <ns0:CodeMethodInvokeExpression>
                                  <ns0:CodeMethodInvokeExpression.Parameters>
                                    <ns0:CodePrimitiveExpression>
                                      <ns0:CodePrimitiveExpression.Value>
                                        <ns1:String xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">EEADM</ns1:String>
                                      </ns0:CodePrimitiveExpression.Value>
                                    </ns0:CodePrimitiveExpression>
                                  </ns0:CodeMethodInvokeExpression.Parameters>
                                  <ns0:CodeMethodInvokeExpression.Method>
                                    <ns0:CodeMethodReferenceExpression MethodName="GetValueByName">
                                      <ns0:CodeMethodReferenceExpression.TargetObject>
                                        <ns0:CodeThisReferenceExpression />
                                      </ns0:CodeMethodReferenceExpression.TargetObject>
                                    </ns0:CodeMethodReferenceExpression>
                                  </ns0:CodeMethodInvokeExpression.Method>
                                </ns0:CodeMethodInvokeExpression>
                              </ns0:CodeBinaryOperatorExpression.Left>
                              <ns0:CodeBinaryOperatorExpression.Right>
                                <ns0:CodePrimitiveExpression />
                              </ns0:CodeBinaryOperatorExpression.Right>
                            </ns0:CodeBinaryOperatorExpression>
                          </ns0:CodeBinaryOperatorExpression.Right>
                        </ns0:CodeBinaryOperatorExpression>
                      </ns0:CodeBinaryOperatorExpression.Left>
                      <ns0:CodeBinaryOperatorExpression.Right>
                        <ns0:CodeBinaryOperatorExpression Operator="ValueEquality">
                          <ns0:CodeBinaryOperatorExpression.Left>
                            <ns0:CodeCastExpression TargetType="System.String, mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">
                              <ns0:CodeCastExpression.Expression>
                                <ns0:CodeMethodInvokeExpression>
                                  <ns0:CodeMethodInvokeExpression.Parameters>
                                    <ns0:CodePrimitiveExpression>
                                      <ns0:CodePrimitiveExpression.Value>
                                        <ns1:String xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">EEADM</ns1:String>
                                      </ns0:CodePrimitiveExpression.Value>
                                    </ns0:CodePrimitiveExpression>
                                  </ns0:CodeMethodInvokeExpression.Parameters>
                                  <ns0:CodeMethodInvokeExpression.Method>
                                    <ns0:CodeMethodReferenceExpression MethodName="GetValueByName">
                                      <ns0:CodeMethodReferenceExpression.TargetObject>
                                        <ns0:CodeThisReferenceExpression />
                                      </ns0:CodeMethodReferenceExpression.TargetObject>
                                    </ns0:CodeMethodReferenceExpression>
                                  </ns0:CodeMethodInvokeExpression.Method>
                                </ns0:CodeMethodInvokeExpression>
                              </ns0:CodeCastExpression.Expression>
                            </ns0:CodeCastExpression>
                          </ns0:CodeBinaryOperatorExpression.Left>
                          <ns0:CodeBinaryOperatorExpression.Right>
                            <ns0:CodePrimitiveExpression>
                              <ns0:CodePrimitiveExpression.Value>
                                <ns1:String xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">EEADM</ns1:String>
                              </ns0:CodePrimitiveExpression.Value>
                            </ns0:CodePrimitiveExpression>
                          </ns0:CodeBinaryOperatorExpression.Right>
                        </ns0:CodeBinaryOperatorExpression>
                      </ns0:CodeBinaryOperatorExpression.Right>
                    </ns0:CodeBinaryOperatorExpression>
                  </ns0:CodeBinaryOperatorExpression.Right>
                </ns0:CodeBinaryOperatorExpression>
              </ns0:CodeBinaryOperatorExpression.Left>
              <ns0:CodeBinaryOperatorExpression.Right>
                <ns0:CodeBinaryOperatorExpression Operator="BooleanAnd">
                  <ns0:CodeBinaryOperatorExpression.Left>
                    <ns0:CodeBinaryOperatorExpression Operator="IdentityInequality">
                      <ns0:CodeBinaryOperatorExpression.Left>
                        <ns0:CodeMethodInvokeExpression>
                          <ns0:CodeMethodInvokeExpression.Parameters>
                            <ns0:CodePrimitiveExpression>
                              <ns0:CodePrimitiveExpression.Value>
                                <ns1:String xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">Add</ns1:String>
                              </ns0:CodePrimitiveExpression.Value>
                            </ns0:CodePrimitiveExpression>
                          </ns0:CodeMethodInvokeExpression.Parameters>
                          <ns0:CodeMethodInvokeExpression.Method>
                            <ns0:CodeMethodReferenceExpression MethodName="GetValueByName">
                              <ns0:CodeMethodReferenceExpression.TargetObject>
                                <ns0:CodeThisReferenceExpression />
                              </ns0:CodeMethodReferenceExpression.TargetObject>
                            </ns0:CodeMethodReferenceExpression>
                          </ns0:CodeMethodInvokeExpression.Method>
                        </ns0:CodeMethodInvokeExpression>
                      </ns0:CodeBinaryOperatorExpression.Left>
                      <ns0:CodeBinaryOperatorExpression.Right>
                        <ns0:CodePrimitiveExpression />
                      </ns0:CodeBinaryOperatorExpression.Right>
                    </ns0:CodeBinaryOperatorExpression>
                  </ns0:CodeBinaryOperatorExpression.Left>
                  <ns0:CodeBinaryOperatorExpression.Right>
                    <ns0:CodeBinaryOperatorExpression Operator="ValueEquality">
                      <ns0:CodeBinaryOperatorExpression.Left>
                        <ns0:CodeCastExpression TargetType="System.Int32, mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">
                          <ns0:CodeCastExpression.Expression>
                            <ns0:CodeMethodInvokeExpression>
                              <ns0:CodeMethodInvokeExpression.Parameters>
                                <ns0:CodePrimitiveExpression>
                                  <ns0:CodePrimitiveExpression.Value>
                                    <ns1:String xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">Add</ns1:String>
                                  </ns0:CodePrimitiveExpression.Value>
                                </ns0:CodePrimitiveExpression>
                              </ns0:CodeMethodInvokeExpression.Parameters>
                              <ns0:CodeMethodInvokeExpression.Method>
                                <ns0:CodeMethodReferenceExpression MethodName="GetValueByName">
                                  <ns0:CodeMethodReferenceExpression.TargetObject>
                                    <ns0:CodeThisReferenceExpression />
                                  </ns0:CodeMethodReferenceExpression.TargetObject>
                                </ns0:CodeMethodReferenceExpression>
                              </ns0:CodeMethodInvokeExpression.Method>
                            </ns0:CodeMethodInvokeExpression>
                          </ns0:CodeCastExpression.Expression>
                        </ns0:CodeCastExpression>
                      </ns0:CodeBinaryOperatorExpression.Left>
                      <ns0:CodeBinaryOperatorExpression.Right>
                        <ns0:CodePrimitiveExpression>
                          <ns0:CodePrimitiveExpression.Value>
                            <ns1:Int32 xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">0</ns1:Int32>
                          </ns0:CodePrimitiveExpression.Value>
                        </ns0:CodePrimitiveExpression>
                      </ns0:CodeBinaryOperatorExpression.Right>
                    </ns0:CodeBinaryOperatorExpression>
                  </ns0:CodeBinaryOperatorExpression.Right>
                </ns0:CodeBinaryOperatorExpression>
              </ns0:CodeBinaryOperatorExpression.Right>
            </ns0:CodeBinaryOperatorExpression>
          </RuleExpressionCondition.Expression>
        </RuleExpressionCondition>
      </Rule.Condition>
    </Rule>
    <Rule Name="ADMIN-Change-8" ReevaluationBehavior="Always" Priority="8" Description="{p1:Null}" Active="True">
      <Rule.ThenActions>
        <RuleStatementAction>
          <RuleStatementAction.CodeDomStatement>
            <ns0:CodeAssignStatement xmlns:ns0="clr-namespace:System.CodeDom;Assembly=System, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" LinePragma="{p1:Null}">
              <ns0:CodeAssignStatement.Left>
                <ns0:CodePropertyReferenceExpression PropertyName="Result">
                  <ns0:CodePropertyReferenceExpression.TargetObject>
                    <ns0:CodeThisReferenceExpression />
                  </ns0:CodePropertyReferenceExpression.TargetObject>
                </ns0:CodePropertyReferenceExpression>
              </ns0:CodeAssignStatement.Left>
              <ns0:CodeAssignStatement.Right>
                <ns0:CodePrimitiveExpression>
                  <ns0:CodePrimitiveExpression.Value>
                    <ns1:String xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">ADMINBPDID</ns1:String>
                  </ns0:CodePrimitiveExpression.Value>
                </ns0:CodePrimitiveExpression>
              </ns0:CodeAssignStatement.Right>
            </ns0:CodeAssignStatement>
          </RuleStatementAction.CodeDomStatement>
        </RuleStatementAction>
      </Rule.ThenActions>
      <Rule.Condition>
        <RuleExpressionCondition Name="{p1:Null}">
          <RuleExpressionCondition.Expression>
            <ns0:CodeBinaryOperatorExpression xmlns:ns0="clr-namespace:System.CodeDom;Assembly=System, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" Operator="BooleanAnd">
              <ns0:CodeBinaryOperatorExpression.Left>
                <ns0:CodeBinaryOperatorExpression Operator="BooleanAnd">
                  <ns0:CodeBinaryOperatorExpression.Left>
                    <ns0:CodeBinaryOperatorExpression Operator="BooleanAnd">
                      <ns0:CodeBinaryOperatorExpression.Left>
                        <ns0:CodeBinaryOperatorExpression Operator="IdentityInequality">
                          <ns0:CodeBinaryOperatorExpression.Left>
                            <ns0:CodeMethodInvokeExpression>
                              <ns0:CodeMethodInvokeExpression.Parameters>
                                <ns0:CodePrimitiveExpression>
                                  <ns0:CodePrimitiveExpression.Value>
                                    <ns1:String xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">UltimateSoftware.Notifications.InitiatedFor</ns1:String>
                                  </ns0:CodePrimitiveExpression.Value>
                                </ns0:CodePrimitiveExpression>
                              </ns0:CodeMethodInvokeExpression.Parameters>
                              <ns0:CodeMethodInvokeExpression.Method>
                                <ns0:CodeMethodReferenceExpression MethodName="GetBusinessObjectByType">
                                  <ns0:CodeMethodReferenceExpression.TargetObject>
                                    <ns0:CodeThisReferenceExpression />
                                  </ns0:CodeMethodReferenceExpression.TargetObject>
                                </ns0:CodeMethodReferenceExpression>
                              </ns0:CodeMethodInvokeExpression.Method>
                            </ns0:CodeMethodInvokeExpression>
                          </ns0:CodeBinaryOperatorExpression.Left>
                          <ns0:CodeBinaryOperatorExpression.Right>
                            <ns0:CodePrimitiveExpression />
                          </ns0:CodeBinaryOperatorExpression.Right>
                        </ns0:CodeBinaryOperatorExpression>
                      </ns0:CodeBinaryOperatorExpression.Left>
                      <ns0:CodeBinaryOperatorExpression.Right>
                        <ns0:CodeBinaryOperatorExpression Operator="IdentityInequality">
                          <ns0:CodeBinaryOperatorExpression.Left>
                            <ns0:CodeMethodInvokeExpression>
                              <ns0:CodeMethodInvokeExpression.Parameters>
                                <ns0:CodePrimitiveExpression>
                                  <ns0:CodePrimitiveExpression.Value>
                                    <ns1:String xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">UltimateSoftware.Security.UserContext</ns1:String>
                                  </ns0:CodePrimitiveExpression.Value>
                                </ns0:CodePrimitiveExpression>
                              </ns0:CodeMethodInvokeExpression.Parameters>
                              <ns0:CodeMethodInvokeExpression.Method>
                                <ns0:CodeMethodReferenceExpression MethodName="GetBusinessObjectByType">
                                  <ns0:CodeMethodReferenceExpression.TargetObject>
                                    <ns0:CodeThisReferenceExpression />
                                  </ns0:CodeMethodReferenceExpression.TargetObject>
                                </ns0:CodeMethodReferenceExpression>
                              </ns0:CodeMethodInvokeExpression.Method>
                            </ns0:CodeMethodInvokeExpression>
                          </ns0:CodeBinaryOperatorExpression.Left>
                          <ns0:CodeBinaryOperatorExpression.Right>
                            <ns0:CodePrimitiveExpression />
                          </ns0:CodeBinaryOperatorExpression.Right>
                        </ns0:CodeBinaryOperatorExpression>
                      </ns0:CodeBinaryOperatorExpression.Right>
                    </ns0:CodeBinaryOperatorExpression>
                  </ns0:CodeBinaryOperatorExpression.Left>
                  <ns0:CodeBinaryOperatorExpression.Right>
                    <ns0:CodeBinaryOperatorExpression Operator="BooleanAnd">
                      <ns0:CodeBinaryOperatorExpression.Left>
                        <ns0:CodeBinaryOperatorExpression Operator="BooleanAnd">
                          <ns0:CodeBinaryOperatorExpression.Left>
                            <ns0:CodeBinaryOperatorExpression Operator="ValueEquality">
                              <ns0:CodeBinaryOperatorExpression.Left>
                                <ns0:CodeMethodInvokeExpression>
                                  <ns0:CodeMethodInvokeExpression.Parameters>
                                    <ns0:CodePrimitiveExpression>
                                      <ns0:CodePrimitiveExpression.Value>
                                        <ns1:String xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">EEADM</ns1:String>
                                      </ns0:CodePrimitiveExpression.Value>
                                    </ns0:CodePrimitiveExpression>
                                  </ns0:CodeMethodInvokeExpression.Parameters>
                                  <ns0:CodeMethodInvokeExpression.Method>
                                    <ns0:CodeMethodReferenceExpression MethodName="IsValidProductKey">
                                      <ns0:CodeMethodReferenceExpression.TargetObject>
                                        <ns0:CodeThisReferenceExpression />
                                      </ns0:CodeMethodReferenceExpression.TargetObject>
                                    </ns0:CodeMethodReferenceExpression>
                                  </ns0:CodeMethodInvokeExpression.Method>
                                </ns0:CodeMethodInvokeExpression>
                              </ns0:CodeBinaryOperatorExpression.Left>
                              <ns0:CodeBinaryOperatorExpression.Right>
                                <ns0:CodePrimitiveExpression>
                                  <ns0:CodePrimitiveExpression.Value>
                                    <ns1:Boolean xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">true</ns1:Boolean>
                                  </ns0:CodePrimitiveExpression.Value>
                                </ns0:CodePrimitiveExpression>
                              </ns0:CodeBinaryOperatorExpression.Right>
                            </ns0:CodeBinaryOperatorExpression>
                          </ns0:CodeBinaryOperatorExpression.Left>
                          <ns0:CodeBinaryOperatorExpression.Right>
                            <ns0:CodeBinaryOperatorExpression Operator="IdentityInequality">
                              <ns0:CodeBinaryOperatorExpression.Left>
                                <ns0:CodeMethodInvokeExpression>
                                  <ns0:CodeMethodInvokeExpression.Parameters>
                                    <ns0:CodePrimitiveExpression>
                                      <ns0:CodePrimitiveExpression.Value>
                                        <ns1:String xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">EEADM</ns1:String>
                                      </ns0:CodePrimitiveExpression.Value>
                                    </ns0:CodePrimitiveExpression>
                                  </ns0:CodeMethodInvokeExpression.Parameters>
                                  <ns0:CodeMethodInvokeExpression.Method>
                                    <ns0:CodeMethodReferenceExpression MethodName="GetValueByName">
                                      <ns0:CodeMethodReferenceExpression.TargetObject>
                                        <ns0:CodeThisReferenceExpression />
                                      </ns0:CodeMethodReferenceExpression.TargetObject>
                                    </ns0:CodeMethodReferenceExpression>
                                  </ns0:CodeMethodInvokeExpression.Method>
                                </ns0:CodeMethodInvokeExpression>
                              </ns0:CodeBinaryOperatorExpression.Left>
                              <ns0:CodeBinaryOperatorExpression.Right>
                                <ns0:CodePrimitiveExpression />
                              </ns0:CodeBinaryOperatorExpression.Right>
                            </ns0:CodeBinaryOperatorExpression>
                          </ns0:CodeBinaryOperatorExpression.Right>
                        </ns0:CodeBinaryOperatorExpression>
                      </ns0:CodeBinaryOperatorExpression.Left>
                      <ns0:CodeBinaryOperatorExpression.Right>
                        <ns0:CodeBinaryOperatorExpression Operator="ValueEquality">
                          <ns0:CodeBinaryOperatorExpression.Left>
                            <ns0:CodeCastExpression TargetType="System.String, mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">
                              <ns0:CodeCastExpression.Expression>
                                <ns0:CodeMethodInvokeExpression>
                                  <ns0:CodeMethodInvokeExpression.Parameters>
                                    <ns0:CodePrimitiveExpression>
                                      <ns0:CodePrimitiveExpression.Value>
                                        <ns1:String xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">EEADM</ns1:String>
                                      </ns0:CodePrimitiveExpression.Value>
                                    </ns0:CodePrimitiveExpression>
                                  </ns0:CodeMethodInvokeExpression.Parameters>
                                  <ns0:CodeMethodInvokeExpression.Method>
                                    <ns0:CodeMethodReferenceExpression MethodName="GetValueByName">
                                      <ns0:CodeMethodReferenceExpression.TargetObject>
                                        <ns0:CodeThisReferenceExpression />
                                      </ns0:CodeMethodReferenceExpression.TargetObject>
                                    </ns0:CodeMethodReferenceExpression>
                                  </ns0:CodeMethodInvokeExpression.Method>
                                </ns0:CodeMethodInvokeExpression>
                              </ns0:CodeCastExpression.Expression>
                            </ns0:CodeCastExpression>
                          </ns0:CodeBinaryOperatorExpression.Left>
                          <ns0:CodeBinaryOperatorExpression.Right>
                            <ns0:CodePrimitiveExpression>
                              <ns0:CodePrimitiveExpression.Value>
                                <ns1:String xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">EEADM</ns1:String>
                              </ns0:CodePrimitiveExpression.Value>
                            </ns0:CodePrimitiveExpression>
                          </ns0:CodeBinaryOperatorExpression.Right>
                        </ns0:CodeBinaryOperatorExpression>
                      </ns0:CodeBinaryOperatorExpression.Right>
                    </ns0:CodeBinaryOperatorExpression>
                  </ns0:CodeBinaryOperatorExpression.Right>
                </ns0:CodeBinaryOperatorExpression>
              </ns0:CodeBinaryOperatorExpression.Left>
              <ns0:CodeBinaryOperatorExpression.Right>
                <ns0:CodeBinaryOperatorExpression Operator="BooleanAnd">
                  <ns0:CodeBinaryOperatorExpression.Left>
                    <ns0:CodeBinaryOperatorExpression Operator="IdentityInequality">
                      <ns0:CodeBinaryOperatorExpression.Left>
                        <ns0:CodeMethodInvokeExpression>
                          <ns0:CodeMethodInvokeExpression.Parameters>
                            <ns0:CodePrimitiveExpression>
                              <ns0:CodePrimitiveExpression.Value>
                                <ns1:String xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">Change</ns1:String>
                              </ns0:CodePrimitiveExpression.Value>
                            </ns0:CodePrimitiveExpression>
                          </ns0:CodeMethodInvokeExpression.Parameters>
                          <ns0:CodeMethodInvokeExpression.Method>
                            <ns0:CodeMethodReferenceExpression MethodName="GetValueByName">
                              <ns0:CodeMethodReferenceExpression.TargetObject>
                                <ns0:CodeThisReferenceExpression />
                              </ns0:CodeMethodReferenceExpression.TargetObject>
                            </ns0:CodeMethodReferenceExpression>
                          </ns0:CodeMethodInvokeExpression.Method>
                        </ns0:CodeMethodInvokeExpression>
                      </ns0:CodeBinaryOperatorExpression.Left>
                      <ns0:CodeBinaryOperatorExpression.Right>
                        <ns0:CodePrimitiveExpression />
                      </ns0:CodeBinaryOperatorExpression.Right>
                    </ns0:CodeBinaryOperatorExpression>
                  </ns0:CodeBinaryOperatorExpression.Left>
                  <ns0:CodeBinaryOperatorExpression.Right>
                    <ns0:CodeBinaryOperatorExpression Operator="ValueEquality">
                      <ns0:CodeBinaryOperatorExpression.Left>
                        <ns0:CodeCastExpression TargetType="System.Int32, mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">
                          <ns0:CodeCastExpression.Expression>
                            <ns0:CodeMethodInvokeExpression>
                              <ns0:CodeMethodInvokeExpression.Parameters>
                                <ns0:CodePrimitiveExpression>
                                  <ns0:CodePrimitiveExpression.Value>
                                    <ns1:String xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">Change</ns1:String>
                                  </ns0:CodePrimitiveExpression.Value>
                                </ns0:CodePrimitiveExpression>
                              </ns0:CodeMethodInvokeExpression.Parameters>
                              <ns0:CodeMethodInvokeExpression.Method>
                                <ns0:CodeMethodReferenceExpression MethodName="GetValueByName">
                                  <ns0:CodeMethodReferenceExpression.TargetObject>
                                    <ns0:CodeThisReferenceExpression />
                                  </ns0:CodeMethodReferenceExpression.TargetObject>
                                </ns0:CodeMethodReferenceExpression>
                              </ns0:CodeMethodInvokeExpression.Method>
                            </ns0:CodeMethodInvokeExpression>
                          </ns0:CodeCastExpression.Expression>
                        </ns0:CodeCastExpression>
                      </ns0:CodeBinaryOperatorExpression.Left>
                      <ns0:CodeBinaryOperatorExpression.Right>
                        <ns0:CodePrimitiveExpression>
                          <ns0:CodePrimitiveExpression.Value>
                            <ns1:Int32 xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">1</ns1:Int32>
                          </ns0:CodePrimitiveExpression.Value>
                        </ns0:CodePrimitiveExpression>
                      </ns0:CodeBinaryOperatorExpression.Right>
                    </ns0:CodeBinaryOperatorExpression>
                  </ns0:CodeBinaryOperatorExpression.Right>
                </ns0:CodeBinaryOperatorExpression>
              </ns0:CodeBinaryOperatorExpression.Right>
            </ns0:CodeBinaryOperatorExpression>
          </RuleExpressionCondition.Expression>
        </RuleExpressionCondition>
      </Rule.Condition>
    </Rule>
    <Rule Name="ADMIN-Delete-9" ReevaluationBehavior="Always" Priority="9" Description="{p1:Null}" Active="True">
      <Rule.ThenActions>
        <RuleStatementAction>
          <RuleStatementAction.CodeDomStatement>
            <ns0:CodeAssignStatement xmlns:ns0="clr-namespace:System.CodeDom;Assembly=System, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" LinePragma="{p1:Null}">
              <ns0:CodeAssignStatement.Left>
                <ns0:CodePropertyReferenceExpression PropertyName="Result">
                  <ns0:CodePropertyReferenceExpression.TargetObject>
                    <ns0:CodeThisReferenceExpression />
                  </ns0:CodePropertyReferenceExpression.TargetObject>
                </ns0:CodePropertyReferenceExpression>
              </ns0:CodeAssignStatement.Left>
              <ns0:CodeAssignStatement.Right>
                <ns0:CodePrimitiveExpression>
                  <ns0:CodePrimitiveExpression.Value>
                    <ns1:String xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">ADMINBPDID</ns1:String>
                  </ns0:CodePrimitiveExpression.Value>
                </ns0:CodePrimitiveExpression>
              </ns0:CodeAssignStatement.Right>
            </ns0:CodeAssignStatement>
          </RuleStatementAction.CodeDomStatement>
        </RuleStatementAction>
      </Rule.ThenActions>
      <Rule.Condition>
        <RuleExpressionCondition Name="{p1:Null}">
          <RuleExpressionCondition.Expression>
            <ns0:CodeBinaryOperatorExpression xmlns:ns0="clr-namespace:System.CodeDom;Assembly=System, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" Operator="BooleanAnd">
              <ns0:CodeBinaryOperatorExpression.Left>
                <ns0:CodeBinaryOperatorExpression Operator="BooleanAnd">
                  <ns0:CodeBinaryOperatorExpression.Left>
                    <ns0:CodeBinaryOperatorExpression Operator="BooleanAnd">
                      <ns0:CodeBinaryOperatorExpression.Left>
                        <ns0:CodeBinaryOperatorExpression Operator="IdentityInequality">
                          <ns0:CodeBinaryOperatorExpression.Left>
                            <ns0:CodeMethodInvokeExpression>
                              <ns0:CodeMethodInvokeExpression.Parameters>
                                <ns0:CodePrimitiveExpression>
                                  <ns0:CodePrimitiveExpression.Value>
                                    <ns1:String xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">UltimateSoftware.Notifications.InitiatedFor</ns1:String>
                                  </ns0:CodePrimitiveExpression.Value>
                                </ns0:CodePrimitiveExpression>
                              </ns0:CodeMethodInvokeExpression.Parameters>
                              <ns0:CodeMethodInvokeExpression.Method>
                                <ns0:CodeMethodReferenceExpression MethodName="GetBusinessObjectByType">
                                  <ns0:CodeMethodReferenceExpression.TargetObject>
                                    <ns0:CodeThisReferenceExpression />
                                  </ns0:CodeMethodReferenceExpression.TargetObject>
                                </ns0:CodeMethodReferenceExpression>
                              </ns0:CodeMethodInvokeExpression.Method>
                            </ns0:CodeMethodInvokeExpression>
                          </ns0:CodeBinaryOperatorExpression.Left>
                          <ns0:CodeBinaryOperatorExpression.Right>
                            <ns0:CodePrimitiveExpression />
                          </ns0:CodeBinaryOperatorExpression.Right>
                        </ns0:CodeBinaryOperatorExpression>
                      </ns0:CodeBinaryOperatorExpression.Left>
                      <ns0:CodeBinaryOperatorExpression.Right>
                        <ns0:CodeBinaryOperatorExpression Operator="IdentityInequality">
                          <ns0:CodeBinaryOperatorExpression.Left>
                            <ns0:CodeMethodInvokeExpression>
                              <ns0:CodeMethodInvokeExpression.Parameters>
                                <ns0:CodePrimitiveExpression>
                                  <ns0:CodePrimitiveExpression.Value>
                                    <ns1:String xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">UltimateSoftware.Security.UserContext</ns1:String>
                                  </ns0:CodePrimitiveExpression.Value>
                                </ns0:CodePrimitiveExpression>
                              </ns0:CodeMethodInvokeExpression.Parameters>
                              <ns0:CodeMethodInvokeExpression.Method>
                                <ns0:CodeMethodReferenceExpression MethodName="GetBusinessObjectByType">
                                  <ns0:CodeMethodReferenceExpression.TargetObject>
                                    <ns0:CodeThisReferenceExpression />
                                  </ns0:CodeMethodReferenceExpression.TargetObject>
                                </ns0:CodeMethodReferenceExpression>
                              </ns0:CodeMethodInvokeExpression.Method>
                            </ns0:CodeMethodInvokeExpression>
                          </ns0:CodeBinaryOperatorExpression.Left>
                          <ns0:CodeBinaryOperatorExpression.Right>
                            <ns0:CodePrimitiveExpression />
                          </ns0:CodeBinaryOperatorExpression.Right>
                        </ns0:CodeBinaryOperatorExpression>
                      </ns0:CodeBinaryOperatorExpression.Right>
                    </ns0:CodeBinaryOperatorExpression>
                  </ns0:CodeBinaryOperatorExpression.Left>
                  <ns0:CodeBinaryOperatorExpression.Right>
                    <ns0:CodeBinaryOperatorExpression Operator="BooleanAnd">
                      <ns0:CodeBinaryOperatorExpression.Left>
                        <ns0:CodeBinaryOperatorExpression Operator="BooleanAnd">
                          <ns0:CodeBinaryOperatorExpression.Left>
                            <ns0:CodeBinaryOperatorExpression Operator="ValueEquality">
                              <ns0:CodeBinaryOperatorExpression.Left>
                                <ns0:CodeMethodInvokeExpression>
                                  <ns0:CodeMethodInvokeExpression.Parameters>
                                    <ns0:CodePrimitiveExpression>
                                      <ns0:CodePrimitiveExpression.Value>
                                        <ns1:String xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">EEADM</ns1:String>
                                      </ns0:CodePrimitiveExpression.Value>
                                    </ns0:CodePrimitiveExpression>
                                  </ns0:CodeMethodInvokeExpression.Parameters>
                                  <ns0:CodeMethodInvokeExpression.Method>
                                    <ns0:CodeMethodReferenceExpression MethodName="IsValidProductKey">
                                      <ns0:CodeMethodReferenceExpression.TargetObject>
                                        <ns0:CodeThisReferenceExpression />
                                      </ns0:CodeMethodReferenceExpression.TargetObject>
                                    </ns0:CodeMethodReferenceExpression>
                                  </ns0:CodeMethodInvokeExpression.Method>
                                </ns0:CodeMethodInvokeExpression>
                              </ns0:CodeBinaryOperatorExpression.Left>
                              <ns0:CodeBinaryOperatorExpression.Right>
                                <ns0:CodePrimitiveExpression>
                                  <ns0:CodePrimitiveExpression.Value>
                                    <ns1:Boolean xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">true</ns1:Boolean>
                                  </ns0:CodePrimitiveExpression.Value>
                                </ns0:CodePrimitiveExpression>
                              </ns0:CodeBinaryOperatorExpression.Right>
                            </ns0:CodeBinaryOperatorExpression>
                          </ns0:CodeBinaryOperatorExpression.Left>
                          <ns0:CodeBinaryOperatorExpression.Right>
                            <ns0:CodeBinaryOperatorExpression Operator="IdentityInequality">
                              <ns0:CodeBinaryOperatorExpression.Left>
                                <ns0:CodeMethodInvokeExpression>
                                  <ns0:CodeMethodInvokeExpression.Parameters>
                                    <ns0:CodePrimitiveExpression>
                                      <ns0:CodePrimitiveExpression.Value>
                                        <ns1:String xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">EEADM</ns1:String>
                                      </ns0:CodePrimitiveExpression.Value>
                                    </ns0:CodePrimitiveExpression>
                                  </ns0:CodeMethodInvokeExpression.Parameters>
                                  <ns0:CodeMethodInvokeExpression.Method>
                                    <ns0:CodeMethodReferenceExpression MethodName="GetValueByName">
                                      <ns0:CodeMethodReferenceExpression.TargetObject>
                                        <ns0:CodeThisReferenceExpression />
                                      </ns0:CodeMethodReferenceExpression.TargetObject>
                                    </ns0:CodeMethodReferenceExpression>
                                  </ns0:CodeMethodInvokeExpression.Method>
                                </ns0:CodeMethodInvokeExpression>
                              </ns0:CodeBinaryOperatorExpression.Left>
                              <ns0:CodeBinaryOperatorExpression.Right>
                                <ns0:CodePrimitiveExpression />
                              </ns0:CodeBinaryOperatorExpression.Right>
                            </ns0:CodeBinaryOperatorExpression>
                          </ns0:CodeBinaryOperatorExpression.Right>
                        </ns0:CodeBinaryOperatorExpression>
                      </ns0:CodeBinaryOperatorExpression.Left>
                      <ns0:CodeBinaryOperatorExpression.Right>
                        <ns0:CodeBinaryOperatorExpression Operator="ValueEquality">
                          <ns0:CodeBinaryOperatorExpression.Left>
                            <ns0:CodeCastExpression TargetType="System.String, mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">
                              <ns0:CodeCastExpression.Expression>
                                <ns0:CodeMethodInvokeExpression>
                                  <ns0:CodeMethodInvokeExpression.Parameters>
                                    <ns0:CodePrimitiveExpression>
                                      <ns0:CodePrimitiveExpression.Value>
                                        <ns1:String xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">EEADM</ns1:String>
                                      </ns0:CodePrimitiveExpression.Value>
                                    </ns0:CodePrimitiveExpression>
                                  </ns0:CodeMethodInvokeExpression.Parameters>
                                  <ns0:CodeMethodInvokeExpression.Method>
                                    <ns0:CodeMethodReferenceExpression MethodName="GetValueByName">
                                      <ns0:CodeMethodReferenceExpression.TargetObject>
                                        <ns0:CodeThisReferenceExpression />
                                      </ns0:CodeMethodReferenceExpression.TargetObject>
                                    </ns0:CodeMethodReferenceExpression>
                                  </ns0:CodeMethodInvokeExpression.Method>
                                </ns0:CodeMethodInvokeExpression>
                              </ns0:CodeCastExpression.Expression>
                            </ns0:CodeCastExpression>
                          </ns0:CodeBinaryOperatorExpression.Left>
                          <ns0:CodeBinaryOperatorExpression.Right>
                            <ns0:CodePrimitiveExpression>
                              <ns0:CodePrimitiveExpression.Value>
                                <ns1:String xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">EEADM</ns1:String>
                              </ns0:CodePrimitiveExpression.Value>
                            </ns0:CodePrimitiveExpression>
                          </ns0:CodeBinaryOperatorExpression.Right>
                        </ns0:CodeBinaryOperatorExpression>
                      </ns0:CodeBinaryOperatorExpression.Right>
                    </ns0:CodeBinaryOperatorExpression>
                  </ns0:CodeBinaryOperatorExpression.Right>
                </ns0:CodeBinaryOperatorExpression>
              </ns0:CodeBinaryOperatorExpression.Left>
              <ns0:CodeBinaryOperatorExpression.Right>
                <ns0:CodeBinaryOperatorExpression Operator="BooleanAnd">
                  <ns0:CodeBinaryOperatorExpression.Left>
                    <ns0:CodeBinaryOperatorExpression Operator="IdentityInequality">
                      <ns0:CodeBinaryOperatorExpression.Left>
                        <ns0:CodeMethodInvokeExpression>
                          <ns0:CodeMethodInvokeExpression.Parameters>
                            <ns0:CodePrimitiveExpression>
                              <ns0:CodePrimitiveExpression.Value>
                                <ns1:String xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">Delete</ns1:String>
                              </ns0:CodePrimitiveExpression.Value>
                            </ns0:CodePrimitiveExpression>
                          </ns0:CodeMethodInvokeExpression.Parameters>
                          <ns0:CodeMethodInvokeExpression.Method>
                            <ns0:CodeMethodReferenceExpression MethodName="GetValueByName">
                              <ns0:CodeMethodReferenceExpression.TargetObject>
                                <ns0:CodeThisReferenceExpression />
                              </ns0:CodeMethodReferenceExpression.TargetObject>
                            </ns0:CodeMethodReferenceExpression>
                          </ns0:CodeMethodInvokeExpression.Method>
                        </ns0:CodeMethodInvokeExpression>
                      </ns0:CodeBinaryOperatorExpression.Left>
                      <ns0:CodeBinaryOperatorExpression.Right>
                        <ns0:CodePrimitiveExpression />
                      </ns0:CodeBinaryOperatorExpression.Right>
                    </ns0:CodeBinaryOperatorExpression>
                  </ns0:CodeBinaryOperatorExpression.Left>
                  <ns0:CodeBinaryOperatorExpression.Right>
                    <ns0:CodeBinaryOperatorExpression Operator="ValueEquality">
                      <ns0:CodeBinaryOperatorExpression.Left>
                        <ns0:CodeCastExpression TargetType="System.Int32, mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">
                          <ns0:CodeCastExpression.Expression>
                            <ns0:CodeMethodInvokeExpression>
                              <ns0:CodeMethodInvokeExpression.Parameters>
                                <ns0:CodePrimitiveExpression>
                                  <ns0:CodePrimitiveExpression.Value>
                                    <ns1:String xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">Delete</ns1:String>
                                  </ns0:CodePrimitiveExpression.Value>
                                </ns0:CodePrimitiveExpression>
                              </ns0:CodeMethodInvokeExpression.Parameters>
                              <ns0:CodeMethodInvokeExpression.Method>
                                <ns0:CodeMethodReferenceExpression MethodName="GetValueByName">
                                  <ns0:CodeMethodReferenceExpression.TargetObject>
                                    <ns0:CodeThisReferenceExpression />
                                  </ns0:CodeMethodReferenceExpression.TargetObject>
                                </ns0:CodeMethodReferenceExpression>
                              </ns0:CodeMethodInvokeExpression.Method>
                            </ns0:CodeMethodInvokeExpression>
                          </ns0:CodeCastExpression.Expression>
                        </ns0:CodeCastExpression>
                      </ns0:CodeBinaryOperatorExpression.Left>
                      <ns0:CodeBinaryOperatorExpression.Right>
                        <ns0:CodePrimitiveExpression>
                          <ns0:CodePrimitiveExpression.Value>
                            <ns1:Int32 xmlns:ns1="clr-namespace:System;Assembly=mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089">2</ns1:Int32>
                          </ns0:CodePrimitiveExpression.Value>
                        </ns0:CodePrimitiveExpression>
                      </ns0:CodeBinaryOperatorExpression.Right>
                    </ns0:CodeBinaryOperatorExpression>
                  </ns0:CodeBinaryOperatorExpression.Right>
                </ns0:CodeBinaryOperatorExpression>
              </ns0:CodeBinaryOperatorExpression.Right>
            </ns0:CodeBinaryOperatorExpression>
          </RuleExpressionCondition.Expression>
        </RuleExpressionCondition>
      </Rule.Condition>
    </Rule>'

	SET @RuleSetHeader = '
    <RuleSet xmlns:p1="http://schemas.microsoft.com/winfx/2006/xaml" xmlns="http://schemas.microsoft.com/winfx/2006/xaml/workflow" Name="RuleSet" ChainingBehavior="None" Description="{p1:Null}">
  <RuleSet.Rules>'
	
	SET @RuleSetTrailer = '
  </RuleSet.Rules>
</RuleSet>'

	------------------------------------------
	-- Set up RuleSet to return
	------------------------------------------
	
	SET @RuleSet = @RuleSetHeader
	
	IF (@IncludeESS = 'Y') BEGIN
		SET @RuleSet = @RuleSet + @RuleSetESS
	END
	
	IF (@IncludeMSS = 'Y') BEGIN
		SET @RuleSet = @RuleSet + @RuleSetMSS
	END
	
	IF (@IncludeEEADM = 'Y') BEGIN
		SET @RuleSet = @RuleSet + @RuleSetEEADM
	END
	
	SET @RuleSet = @RuleSet + @RuleSetTrailer

	RETURN @RuleSet

END
GO

------------------------------------------------------------------------------------
-- Step 3 - Create Workflow Script - 03 - SetupWorkflow (CreateProcs)
------------------------------------------------------------------------------------


------------------------------------------------
-- DROPS
------------------------------------------------

IF OBJECT_ID('dbo.CustomWorkflows_SetupBusinessProcessAndWorkflow') IS NOT NULL
	DROP PROCEDURE dbo.CustomWorkflows_SetupBusinessProcessAndWorkflow

IF OBJECT_ID('dbo.CustomWorkflows_RemoveBusinessProcessAndWorkflow') IS NOT NULL
	DROP PROCEDURE dbo.CustomWorkflows_RemoveBusinessProcessAndWorkflow

IF OBJECT_ID('dbo.CustomWorkflows_AddBusinessProcessDefinition') IS NOT NULL
	DROP PROCEDURE dbo.CustomWorkflows_AddBusinessProcessDefinition

IF OBJECT_ID('dbo.CustomWorkflows_AddBusinessProcessApprovers') IS NOT NULL
	DROP PROCEDURE dbo.CustomWorkflows_AddBusinessProcessApprovers

IF OBJECT_ID('dbo.CustomWorkflows_AddBusinessProcessApprover') IS NOT NULL
	DROP PROCEDURE dbo.CustomWorkflows_AddBusinessProcessApprover

IF OBJECT_ID('dbo.CustomWorkflows_AddJmsJobWFLink') IS NOT NULL
	DROP PROCEDURE dbo.CustomWorkflows_AddJmsJobWFLink

IF OBJECT_ID('dbo.CustomWorkflows_UpdateRuleSet') IS NOT NULL
	DROP PROCEDURE dbo.CustomWorkflows_UpdateRuleSet

GO

-- In the following, the procedures are created in reverse dependency order to avoid SysDepends warnings

---------------------------------------------
-- AddJmsJobWFLink
---------------------------------------------

CREATE PROCEDURE dbo.CustomWorkflows_AddJmsJobWFLink (
	@BPCode VARCHAR(16)
) AS
BEGIN

	DECLARE
		@JobDefCode    VARCHAR(16),
		@IntegrationID VARCHAR(32),
		@BPID          UNIQUEIDENTIFIER
	
	DECLARE @tblJmsActions TABLE (ActionIndex INT)
	
	INSERT @tblJmsActions (ActionIndex) VALUES (0)
	INSERT @tblJmsActions (ActionIndex) VALUES (1)
	INSERT @tblJmsActions (ActionIndex) VALUES (2)
	
	SELECT
		@BPID       = bpdID,
		@JobDefCode = bpdJobDefCode
	FROM dbo.WkcBprDef (NoLock)
	WHERE bpdCode = @BPCode
	
	IF (@BPID IS NULL) BEGIN
		PRINT 'AddJmsJobWFLink: BPID not found for ' + @BPCode
		RETURN
	END
	
	SELECT @IntegrationID = @BPCode + @JobDefCode
	
	INSERT dbo.JmsJobWFLink (
		BPDefCode,
		IntegrationID,
		IsSystem,
		JobDefCode,
		Action,
		BprDefID
	) SELECT
		@BPCode,
		@IntegrationID,
		'N',
		@JobDefCode,
		actions.ActionIndex,
		@BPID
	FROM @tblJmsActions actions
	LEFT JOIN dbo.JmsJobWFLink (NoLock) ON JobDefCode = @JobDefCode AND BPDefCode = @BPCode AND Action = actions.ActionIndex
	WHERE BPDefCode IS NULL		-- i.e., insert only if doesn't already exist

END
GO

---------------------------------------------
-- AddBusinessProcessApprover
---------------------------------------------

CREATE PROCEDURE dbo.CustomWorkflows_AddBusinessProcessApprover (
	@BPCode     VARCHAR(16),
	@LevelIndex INT  -- 0 to 9, for 10 approval levels
) AS
BEGIN

	SET NOCOUNT ON
	
	DECLARE
		@LevelNumber         VARCHAR(5)  ,
		@ApproverDescription VARCHAR(100),
		@ApproverCode        VARCHAR(16) ,
		@BPDescription       VARCHAR(100),
		@BPID                UNIQUEIDENTIFIER,
		@ApproverID          UNIQUEIDENTIFIER
	
	SET @LevelNumber = CONVERT(VARCHAR(5), @LevelIndex + 1)
	
	SELECT
		@BPID          = bpdID,
		@BPDescription = bpdDescription
	FROM dbo.WkcBprDef (NoLock)
	WHERE bpdCode = @BPCode
	
	
	IF (@BPID IS NULL) BEGIN
		PRINT 'AddBusinessProcessApprover: BPID not found for ' + @BPCode
		RETURN
	END
	
	SET @ApproverDescription = @BPDescription + ' Approver ' + @LevelNumber
	SET @ApproverCode = @BPCode + @LevelNumber
	
	-- Approver Definition
	
	SELECT @ApproverID = apdID FROM dbo.WkcAprDef (NoLock) WHERE apdCode = @ApproverCode
	
	IF (@ApproverID IS NULL) BEGIN
	
		INSERT dbo.WkcAprDef (
			apdApprovalTotal  , apdDefaultPerformerUID , apdDescription        , 
			apdEditableOption , apdEmailOption         , apdHideCommentsOption ,
			apdIsVisible      , apdSelectByRole        , apdBprDefID           , 
			apdIsConditional  , apdLevel               , apdCode
		) VALUES (
			0                 , 0                      , @ApproverDescription  , 
			0                 , 0                      , 0                     , 
			1                 , 0                      , @BPID                 , 
			0                 , @LevelIndex            , @ApproverCode
		)
		
		SELECT @ApproverID = apdID FROM dbo.WkcAprDef (NoLock) WHERE apdCode = @ApproverCode
	
	END
	
	-- BusinessProcess to Approver mapping
	
	IF NOT EXISTS (SELECT 1 FROM dbo.WkcBprToApr (NoLock) WHERE btaAprCode = @ApproverCode AND btaBprCode = @BPCode) BEGIN
	
		INSERT dbo.WkcBprToApr (
			btaAprCode     , btaBprCode  , btaLevel     , btaAprDefID  , btaBprDefID
		) VALUES (
			@ApproverCode  , @BPCode     , @LevelIndex  , @ApproverID  , @BPID
		)
		
	END
	
	-- Approver to Action mapping (5 actions)
	
	DECLARE @tblActions TABLE (ActionCode VARCHAR(16))
	
	INSERT @tblActions (ActionCode) VALUES ('APPRV')
	INSERT @tblActions (ActionCode) VALUES ('CANCL')
	INSERT @tblActions (ActionCode) VALUES ('COMNT')
	INSERT @tblActions (ActionCode) VALUES ('DENY' )
	INSERT @tblActions (ActionCode) VALUES ('OWN'  )
	
	INSERT dbo.WkcAprToAct (
		ataActCode          , ataLevel     , ataAprDefID  , ataBprDefID  , ataAprCode
	) SELECT
		actions.ActionCode  , @LevelIndex  , @ApproverID  , @BPID        , @ApproverCode
	FROM @tblActions actions
	LEFT JOIN dbo.WkcAprToAct (NoLock) ON ataAprDefID = @ApproverID AND ataActCode = actions.ActionCode
	WHERE ataAprDefID IS NULL		-- i.e., insert only if doesn't already exist
	
END
GO

---------------------------------------------
-- AddBusinessProcessApprovers
---------------------------------------------

CREATE PROCEDURE dbo.CustomWorkflows_AddBusinessProcessApprovers (
	@BPCode VARCHAR(16)
) AS
BEGIN

	DECLARE @LevelIndex INT
	
	SET @LevelIndex = 0
	
	WHILE (@LevelIndex < 10) BEGIN
	
		EXEC dbo.CustomWorkflows_AddBusinessProcessApprover @BPCode, @LevelIndex
	
		SET @LevelIndex = @LevelIndex + 1
	
	END

END
GO

---------------------------------------------
-- AddBusinessProcessDefinition
---------------------------------------------

CREATE PROCEDURE dbo.CustomWorkflows_AddBusinessProcessDefinition (
	@BPCode      VARCHAR(16) ,
	@Description VARCHAR(100),
	@JobDefCode  VARCHAR(16) ,
	@Category    VARCHAR(10)
) AS
BEGIN

	SET NOCOUNT ON

	DECLARE
		@BPID         UNIQUEIDENTIFIER,
		@DisplayName  VARCHAR(300)
	
	SELECT @BPID = bpdID FROM dbo.WkcBprDef (NoLock) WHERE bpdCode = @BPCode
	
	IF (@BPID IS NULL) BEGIN
	
		IF (@Category = 'ESS'  ) SET @Category = 'EE'
		IF (@Category = 'MSS'  ) SET @Category = 'MANGR'
		IF (@Category = 'EEADM') SET @Category = 'ADMIN'
		
		IF @Category NOT IN ('EE','MANGR','ADMIN') BEGIN
			PRINT 'AddBusinessProcessDefinition: ERROR - Invalid category "' + @Category + '".  Business Process Definition NOT added.'
			RETURN -1
		END
		
		INSERT dbo.WkcBprDef (
			bpdApprovalCount          , bpdApprovalsAllowed   , bpdApprovalsEnabled  ,  -- 1
			bpdAprEmailOption         , bpdAprIsVisible       , bpdAprSelectByRole   ,  -- 2
			bpdAprTemplateID          , bpdCanFutureDate      , bpdCanReOpen         ,  -- 3
			bpdCategory               , bpdCustomEmailText    , bpdCustomSMSText     ,  -- 4
			bpdDefaultPerformerUID    , bpdDescription        , bpdEditableOption    ,  -- 5
			bpdEmailOption            , bpdEnabled            , bpdExcludeInitiator  ,  -- 6
			bpdHideCommentsOption     , bpdInitiatedForCanSee , bpdInitiatorComments ,  -- 7
			bpdIsSystem               , bpdIsVisible          , bpdObsQualOption     ,  -- 8
			bpdPriority               , bpdQualify            , bpdReOpenLevel       ,  -- 9
			bpdSubCategory            , bpdIsConditional      , bpdRuleSet           ,  -- 10
			bpdRuleSetInfo            , bpdConditionalAllowed , bpdCountryCode       ,  -- 11
			bpdJobDefCode             , bpdCode
		) VALUES (
			0                         , 1                     , 0                    ,  -- 1
			0                         , 1                     , 0                    ,  -- 2
			NULL                      , 0                     , 0                    ,  -- 3
			@Category                 , NULL                  , NULL                 ,  -- 4
			0                         , @Description          , 0                    ,  -- 5
			0                         , 0                     , 0                    ,  -- 6
			0                         , 0                     , 0                    ,  -- 7
			0                         , 1                     , 0                    ,  -- 8
			2                         , 0                     , 0                    ,  -- 9
			@BPCode                   , 0                     , NULL                 ,  -- 10
			NULL                      , 0                     , 'ALL'                ,  -- 11
			@JobDefCode              , @BPCode
		)
		
		SELECT @BPID = bpdID FROM dbo.WkcBprDef (NoLock) WHERE bpdCode = @BPCode
		
		SET @DisplayName = 'Business Process "' + @Description + '" for ' + @Category + ' (' + @JobDefCode + ' - ' + @BPCode + ')'
		
		PRINT 'AddBusinessProcessDefinition: Added WkcBprDef (Business Process Definition) record for: ' + @DisplayName
	
	END
	
	-- Ensure certain flags
	-- Note: Not really sure why the flags are set this way, but it works for several clients I've used it for so do it. (DCW 08/23/11)
	
	UPDATE dbo.WkcBprDef SET 
		bpdEnabled        = 1, 
		bpdIsEditable     = 1, 
		bpdEditableOption = 0, 
		bpdIsSystem       = 1 
	WHERE bpdID = @BPID
	
	RETURN 1
	
END
GO

---------------------------------------------
-- RemoveBusinessProcessAndWorkflow
---------------------------------------------

CREATE PROCEDURE dbo.CustomWorkflows_RemoveBusinessProcessAndWorkflow (
	@BPCode     VARCHAR(16),
	@JobDefCode VARCHAR(16)
) AS
BEGIN

	SET NOCOUNT ON

	DECLARE
		@BPID         UNIQUEIDENTIFIER,
		@Category     VARCHAR(10),
		@Description  VARCHAR(100),
		@DisplayName  VARCHAR(300)
		
	SELECT 
		@BPID        = bpdID,
		@Category    = bpdCategory,
		@Description = bpdDescription
	FROM dbo.WkcBprDef (NoLock) 
	WHERE bpdCode = @BPCode
	
	IF (@BPID IS NULL) BEGIN
		RETURN
	END
	
	SET @DisplayName = 'Business Process "' + @Description + '" for ' + @Category + ' (' + @JobDefCode + ' - ' + @BPCode + ')'
	
	IF EXISTS (SELECT 1 FROM dbo.WkcBprInst (NoLock) WHERE bpiDefID = @BPID) BEGIN
		PRINT 'RemoveBusinessProcessAndWorkflow: WARNING - Cannot remove setup for ' + @DisplayName + ' because workflows (in WkcBprInst) already exists for it.'
		RETURN
	END
	
	IF EXISTS (SELECT 1 FROM dbo.JmsJob (NoLock) WHERE BPDefID = @BPID) BEGIN
		PRINT 'RemoveBusinessProcessAndWorkflow: WARNING - Cannot remove setup for ' + @DisplayName + ' because it is referenced by JmsJob records.'
		RETURN
	END
	
	DELETE dbo.JmsJobWFLink    WHERE BprDefID    = @BPID
	DELETE dbo.WkcBprToElement WHERE bteBprDefID = @BPID
	DELETE dbo.WkcAprToAct     WHERE ataBprDefID = @BPID
	DELETE dbo.WkcBprToApr     WHERE btaBprDefID = @BPID
	DELETE dbo.WkcAprDef       WHERE apdBprDefID = @BPID
	DELETE dbo.WkcBprDef       WHERE bpdID       = @BPID
	
	PRINT 'RemoveBusinessProcessAndWorkflow: Deleted BusinessProcess/Workflow setup for ' + @DisplayName

END
GO

---------------------------------------------
-- UpdateRuleSet
---------------------------------------------

CREATE PROCEDURE dbo.CustomWorkflows_UpdateRuleSet (
	@JobDefCode VARCHAR(16)
) AS
BEGIN

	SET NOCOUNT ON
	
	DECLARE 
		@RuleSet    VARCHAR(MAX),
		@AtLeastOne CHAR(1),
		@CategoriesToInclude VARCHAR(100),
		@BPID_EE    UNIQUEIDENTIFIER,
		@BPID_MANGR UNIQUEIDENTIFIER,
		@BPID_ADMIN UNIQUEIDENTIFIER

	-- JmsJob and JmsJobDefSource records must already exist
	
	IF NOT EXISTS (SELECT 1 FROM dbo.JmsJobDef (NoLock) WHERE JobDefCode = @JobDefCode) BEGIN
		PRINT 'SetupBusinessProcessAndWorkflow: ERROR - JmsJobDef record does not exist for JobDefCode "' + @JobDefCode + '"'
		RETURN -1
	END
	
	IF NOT EXISTS (SELECT 1 FROM dbo.JmsJobDefSource (NoLock) WHERE JobDefCode = @JobDefCode) BEGIN
		PRINT 'SetupBusinessProcessAndWorkflow: ERROR - JmsJobDefSource record does not exist for JobDefCode "' + @JobDefCode + '"'
		RETURN -1
	END
	
	-- Retrieve BPID's
	
	SELECT @BPID_EE    = bpdID FROM dbo.WkcBprDef (NoLock) WHERE bpdJobDefCode = @JobDefCode AND bpdCategory = 'EE'
	SELECT @BPID_MANGR = bpdID FROM dbo.WkcBprDef (NoLock) WHERE bpdJobDefCode = @JobDefCode AND bpdCategory = 'MANGR'
	SELECT @BPID_ADMIN = bpdID FROM dbo.WkcBprDef (NoLock) WHERE bpdJobDefCode = @JobDefCode AND bpdCategory = 'ADMIN'
	
	SET @CategoriesToInclude = ''
	
	IF (@BPID_EE IS NOT NULL) BEGIN
		SET @CategoriesToInclude = @CategoriesToInclude + ',EE'
	END
	
	IF (@BPID_MANGR IS NOT NULL) BEGIN
		SET @CategoriesToInclude = @CategoriesToInclude + ',MANGR'
	END
	
	IF (@BPID_ADMIN IS NOT NULL) BEGIN
		SET @CategoriesToInclude = @CategoriesToInclude + ',ADMIN'
	END
	
	-- Get RuleSet template, and update with BPID's
	
	SELECT @RuleSet = dbo.CustomWorkflows_RulesetTemplate(@CategoriesToInclude)
	
	SET @AtLeastOne = 'N'
	
	IF (@BPID_EE IS NOT NULL) BEGIN
		SET @RuleSet = REPLACE(@RuleSet, 'EMPLOYEEBPDID', @BPID_EE)
		SET @AtLeastOne = 'Y'
	END
	
	IF (@BPID_MANGR IS NOT NULL) BEGIN
		SET @RuleSet = REPLACE(@RuleSet, 'MANAGERBPDID', @BPID_MANGR)
		SET @AtLeastOne = 'Y'
	END
	
	IF (@BPID_ADMIN IS NOT NULL) BEGIN
		SET @RuleSet = REPLACE(@RuleSet, 'ADMINBPDID', @BPID_ADMIN)
		SET @AtLeastOne = 'Y'
	END
	
	-- Update RuleSet on JmsJobDefSource
	-- Also, update WorkflowAllowed and Display (display in SMC)
	-- Also, ensure CategoryID is 1 (if it isn't workflows won't display in Request Inbox) (DCW 05/07/13 Added)
	
	IF (@AtLeastOne = 'Y') BEGIN
	
		UPDATE dbo.JmsJobDefSource SET
			RuleSet         = @RuleSet,
			WorkflowAllowed = 1,
			CategoryID      = 1
		WHERE JobDefCode = @JobDefCode

		UPDATE dbo.JmsJobDef
		   SET Display = 1
		 WHERE JobDefCode = @JobDefCode
		
		PRINT 'UpdateRuleSet: Updated JmsJobDef and JmsJobDefSource with workflow settings including RuleSet, for JobDefCode "' + @JobDefCode + '"'

	END
	
	RETURN 1
	
END
GO

---------------------------------------------
-- SetupBusinessProcessAndWorkflow
---------------------------------------------

CREATE PROCEDURE dbo.CustomWorkflows_SetupBusinessProcessAndWorkflow (
	@BPCode      VARCHAR(16) ,
	@Description VARCHAR(100),
	@JobDefCode  VARCHAR(20) ,
	@Category    VARCHAR(10) ,
	@DeleteIfCan CHAR(1) = 'N'
) AS
BEGIN

	SET NOCOUNT ON
	
	DECLARE @BPID UNIQUEIDENTIFIER
	DECLARE @ResultCode INT
	
	-- Ensure proper lengths
	
	IF (LEN(@BPCode) > 10) BEGIN
		PRINT 'SetupBusinessProcessAndWorkflow: ERROR - BPCode parameter is too long, can only be 10 characters'
		RETURN -1
	END
	
	IF (LEN(@JobDefCode) > 16) BEGIN
		PRINT 'SetupBusinessProcessAndWorkflow: ERROR - JobDefCode parameter is too long, can only be 16 characters'
		RETURN -1
	END

	-- JmsJob and JmsJobDefSource records must already exist
	
	IF NOT EXISTS (SELECT 1 FROM dbo.JmsJobDef (NoLock) WHERE JobDefCode = @JobDefCode) BEGIN
		PRINT 'SetupBusinessProcessAndWorkflow: ERROR - JmsJobDef record does not exist for JobDefCode "' + @JobDefCode + '"'
		RETURN -1
	END
	
	IF NOT EXISTS (SELECT 1 FROM dbo.JmsJobDefSource (NoLock) WHERE JobDefCode = @JobDefCode) BEGIN
		PRINT 'SetupBusinessProcessAndWorkflow: ERROR - JmsJobDefSource record does not exist for JobDefCode "' + @JobDefCode + '"'
		RETURN -1
	END
	
	IF (@DeleteIfCan = 'Y') BEGIN
		EXEC dbo.CustomWorkflows_RemoveBusinessProcessAndWorkflow @BPCode, @JobDefCode
	END
	
	EXEC @ResultCode = dbo.CustomWorkflows_AddBusinessProcessDefinition @BPCode, @Description, @JobDefCode, @Category
	
	IF (@ResultCode < 0) BEGIN
		RETURN @ResultCode
	END
	
	SELECT @BPID = bpdID FROM dbo.WkcBprDef (NoLock) WHERE bpdCode = @BPCode
	
	IF (@BPID IS NULL) BEGIN
		PRINT 'SetupBusinessProcessAndWorkflow: ERROR - WkcBprDef record appears not to exist. Aborting.'
		RETURN -1
	END
	
	EXEC dbo.CustomWorkflows_AddBusinessProcessApprovers @BPCode
	
	EXEC dbo.CustomWorkflows_AddJmsJobWFLink @BPCode
	
	RETURN 1
	
END
GO

------------------------------------------------------------------------------------
-- Step 4 - Create Workflow Script - 04 - SetupWorkflow (Script) - Client specific
------------------------------------------------------------------------------------

/*
Script to create Worfklow setup for custom jobdefcodes.

Modification History:
08/23/11 - DCW - Initial version while fixing an Esclation for One America Financial.
08/31/11 - DCW - Generized filenames, and added handling for variable parts to RuleSet, for ESS, MSS, or EEADM.
*/

DECLARE @ResultCode INT
DECLARE @BPDescription VARCHAR(100)

BEGIN TRANSACTION

SET @BPDescription = 'Pay Consent Settings'	-- Choose your Business Process description here

SET @ResultCode = 1		-- Start out as success

-- ESS (comment this block out if not doing ESS)
IF (@ResultCode > 0) BEGIN
	EXEC @ResultCode = dbo.CustomWorkflows_SetupBusinessProcessAndWorkflow
		@BPCode       = 'UEDebTipSt',		-- Choose some unique code here, appropriate for Employee category.
		@Description  = @BPDescription,
		@JobDefCode   = 'U_LAZ1001Consent',	-- Use the custom JobDefCode you set up previously or in the JmsJobDef script.
		@Category     = 'EE',
		@DeleteIfCan  = 'Y'				-- Will delete all setup and re-insert, IF nothing exists in WkcBprInst for this custom workflow... that is, if nothing has ever been submitted for approval yet.
END

-- MSS (comment this block out if not doing MSS)
IF (@ResultCode > 0) BEGIN
	EXEC @ResultCode = dbo.CustomWorkflows_SetupBusinessProcessAndWorkflow
		@BPCode       = 'UMDebTipSt',		-- Choose some unique code here, appropriate for Manager category.
		@Description  = @BPDescription,
		@JobDefCode   = 'U_LAZ1001Consent',	-- Use the custom JobDefCode you set up previously or in the JmsJobDef script.
		@Category     = 'MANGR',
		@DeleteIfCan  = 'Y'				-- Will delete all setup and re-insert, IF nothing exists in WkcBprInst for this custom workflow... that is, if nothing has ever been submitted for approval yet.
END

-- EEADM (comment this block out if not doing EEADM)
IF (@ResultCode > 0) BEGIN
	EXEC @ResultCode = dbo.CustomWorkflows_SetupBusinessProcessAndWorkflow
		@BPCode       = 'UADebTipSt',		-- Choose some unique code here, appropriate for Admin category.
		@Description  = @BPDescription,
		@JobDefCode   = 'U_LAZ1001Consent',	-- Use the custom JobDefCode you set up previously or in the JmsJobDef script.
		@Category     = 'ADMIN',
		@DeleteIfCan  = 'Y'				-- Will delete all setup and re-insert, IF nothing exists in WkcBprInst for this custom workflow... that is, if nothing has ever been submitted for approval yet.
END
	
-- Update Ruleset for new custom workflow
IF (@ResultCode > 0) BEGIN
	EXEC @ResultCode = dbo.CustomWorkflows_UpdateRuleSet @JobDefCode = 'U_LAZ1001Consent'
END

IF (@ResultCode < 0) BEGIN
	PRINT 'ERROR detected during Workfow setup for "' + @BPDescription + '"... doing ROLLBACK';
	ROLLBACK TRANSACTION
END ELSE BEGIN
	COMMIT TRANSACTION
END

GO

------------------------------------------------------------------------------------
-- Step 5 - Create Workflow Script - 05 - SetupWorkflow (DropProcs) - Clean up
------------------------------------------------------------------------------------

IF OBJECT_ID('dbo.CustomWorkflows_SetupBusinessProcessAndWorkflow') IS NOT NULL
	DROP PROCEDURE dbo.CustomWorkflows_SetupBusinessProcessAndWorkflow

IF OBJECT_ID('dbo.CustomWorkflows_RemoveBusinessProcessAndWorkflow') IS NOT NULL
	DROP PROCEDURE dbo.CustomWorkflows_RemoveBusinessProcessAndWorkflow

IF OBJECT_ID('dbo.CustomWorkflows_AddBusinessProcessDefinition') IS NOT NULL
	DROP PROCEDURE dbo.CustomWorkflows_AddBusinessProcessDefinition

IF OBJECT_ID('dbo.CustomWorkflows_AddBusinessProcessApprovers') IS NOT NULL
	DROP PROCEDURE dbo.CustomWorkflows_AddBusinessProcessApprovers

IF OBJECT_ID('dbo.CustomWorkflows_AddBusinessProcessApprover') IS NOT NULL
	DROP PROCEDURE dbo.CustomWorkflows_AddBusinessProcessApprover

IF OBJECT_ID('dbo.CustomWorkflows_AddJmsJobWFLink') IS NOT NULL
	DROP PROCEDURE dbo.CustomWorkflows_AddJmsJobWFLink

IF OBJECT_ID('dbo.CustomWorkflows_UpdateRuleSet') IS NOT NULL
	DROP PROCEDURE dbo.CustomWorkflows_UpdateRuleSet

IF OBJECT_ID('dbo.CustomWorkflows_RulesetTemplate') IS NOT NULL
	DROP FUNCTION dbo.CustomWorkflows_RulesetTemplate

GO
