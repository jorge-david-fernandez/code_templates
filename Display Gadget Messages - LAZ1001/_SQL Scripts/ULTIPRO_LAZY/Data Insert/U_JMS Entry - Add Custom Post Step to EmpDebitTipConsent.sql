----------------------------------------------------------------------------------------------------------------------
-- Company:		  Ultimate Software Corp. 
-- Author:		  Adrian Serrano
-- Client:		  Lazy Dog Restaurants, LLC
-- Date:		  1/28/2020
-- Request:		  SR-2019-00245269
-- Purpose:		  Instant Pay Direct Deposit (from scope project SR-2019-00233967)
-- Last Modified: 
-----------------------------------------------------------------------------------------------------------------------

-- Add custom step to Emp Debit Tip Consent
SET ANSI_PADDING ON
declare @lastOrder int

select @lastOrder = 
	cast (cast(jobDefSource.query('data(//@Order)[last()]') as varchar(5)) as int)
	from jmsjobdefsource (nolock)
	where jobdefcode = 'U_LAZ1001Consent'

set @lastOrder = @lastOrder + 1

if not exists(select
1 from jmsjobdefsource (nolock) where jobdefcode = 'U_LAZ1001Consent'
and cast(jobDefSource as varchar(8000)) like '%UltimateSoftware.Customs.LAZ1001.SR00245269.EmpDebitTipConsentFacade%')
BEGIN

	update jmsjobdefsource 
	set jobDefSource.modify('
		insert 
		<ExecutionStep Order="{sql:variable("@lastOrder")}">
		  <AssemblyName>UltimateSoftware.Customs.LAZ1001.SR00245269</AssemblyName>
		  <TypeName>UltimateSoftware.Customs.LAZ1001.Facade.EmpDebitTipConsentFacade</TypeName>
		  <MethodName>PostProcessEmpDebitTipConsent</MethodName>
		</ExecutionStep>
		after (/ProcessInfo/ExecutionDetails//ExecutionStep[last()])[1]')
	where jobdefcode = 'U_LAZ1001Consent'
	

END

GO

select jobDefSource from jmsjobdefsource (nolock) where jobdefcode = 'U_LAZ1001Consent'

GO