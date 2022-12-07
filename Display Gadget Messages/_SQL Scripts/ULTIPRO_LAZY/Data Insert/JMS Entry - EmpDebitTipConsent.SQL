/*======================================================================================
 * Company:    Ultimate Sofware Corp.
 * Author:     Adrian Serrano
 * Date:       9/11/2019
 * Client:     Lazy Dog Restaurants, LLC
 * Filename:   _SQL Scripts\Data Insert\JMS Entry - EmpDebitTipConsent.SQL
 * CP Request: SR-2019-00245269
 * Purpose:    Adds workflow to JMS entry for EmpDebitTipConsent
 * 
 * Last Modified: 
 * 
 * =====================================================================================*/

IF OBJECT_ID(N'[dbo].[U_AddJMSEntriesNoWorkflow]') IS NOT NULL  
	DROP PROCEDURE [dbo].[U_AddJMSEntriesNoWorkflow]
GO

CREATE PROCEDURE [dbo].[U_AddJMSEntriesNoWorkflow]
  @JobDefCode        VARCHAR (  16 ),
  @JobDefDescription VARCHAR (  50 ),
  @FacadeName        VARCHAR ( 100 ),
  @SetMethod         VARCHAR ( 100 ),
  @AssemblyName      VARCHAR ( 100 )
AS
BEGIN
	-------------------------------------------------
	-- Author:    Patrick Gnehm
	-- Customer:  ALL
	-- Date:      03/19/2010
	-- Purpose:   SP to add JMS Entries - NO WORKFLOW
	-------------------------------------------------

	IF EXISTS( SELECT * FROM Jmsjobdef WHERE jobDefCode = @JobDefCode )
	BEGIN
		UPDATE Jmsjobdef 
		   SET JobDefDescription = @JobDefDescription,
		       IsSystem          = 'N',
			   Display           = 0
		WHERE jobDefCode = @JobDefCode
	END
	ELSE
	BEGIN
		INSERT INTO   Jmsjobdef ( jobdefcode ,  jobdefdescription ,  IsSystem ,  Display )  
		VALUES ( @JobDefCode,  @JobDefDescription, 'N',  0 )
	END
	
	IF EXISTS( SELECT * FROM Jmsjobdefsource WHERE jobDefCode = @JobDefCode )
	BEGIN
		UPDATE Jmsjobdefsource 
		   SET jobdefversion        = '1',
               jobdefsource         = '<ProcessInfo><Description>'   +  @JobDefDescription +   '</Description><Document>'   +  @JobDefDescription +   '</Document><ExecutionDetails><ExecutionStep Order="1"><AssemblyName>' + @AssemblyName + '</AssemblyName><TypeName>'   +  @FacadeName +   '</TypeName><MethodName>'   +  @SetMethod +   '</MethodName></ExecutionStep></ExecutionDetails></ProcessInfo>',
			   categoryid           = 3,  
			   priorityid           = 1, 
			   DPMProcessDefinition = NULL, 
			   WorkflowAllowed      = 0, 
			   IsEnabled            = 1, 
			   IsSystem             = 'N'
		 WHERE jobDefCode = @JobDefCode
	END
	ELSE
	BEGIN
		INSERT   INTO   Jmsjobdefsource ( jobdefcode ,  jobdefversion ,  jobdefsource ,  categoryid ,  priorityid , DPMProcessDefinition , WorkflowAllowed , IsEnabled , IsSystem )  
		VALUES   ( @JobDefCode,
				   '1',
				   '<ProcessInfo><Description>'   +  @JobDefDescription +   '</Description><Document>'   +  @JobDefDescription +   '</Document><ExecutionDetails><ExecutionStep Order="1"><AssemblyName>' + @AssemblyName + '</AssemblyName><TypeName>'   +  @FacadeName +   '</TypeName><MethodName>'   +  @SetMethod +   '</MethodName></ExecutionStep></ExecutionDetails></ProcessInfo>',
				   3,
				   1,
				   NULL,
				   0,
				   1,
				   'N' )
	END
END
 
EXEC U_AddJMSEntriesNoWorkflow @JobDefCode        = 'LAZYEmpDebitTipConsent',
                               @JobDefDescription = 'EmpDebitTipConsent',
                               @FacadeName        = 'UltimateSoftware.Customs.LAZ1001.Facade.EmpDebitTipConsentFacade',
                               @SetMethod         = 'SetEmpDebitTipConsent',
                               @AssemblyName      = 'UltimateSoftware.Customs.LAZ1001.SR00245269'


GO

IF OBJECT_ID(N'[dbo].[fn_MP_CustomFields_iLocation_Export]') IS NOT NULL  
	DROP PROCEDURE [dbo].[U_AddJMSEntriesNoWorkflow]
GO
