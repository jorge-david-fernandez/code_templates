----------------------------------------------------------------------------------------------------------------------
-- Company:		  UKG 
-- Author:		  Jorge Fernandez
-- Client:		  Tesla, Inc.
-- Date:		  4/6/2023
-- Request:		  SR-2023-00398983
-- Purpose:		  Modify Rehire employee and Transfer Employee to retail 6 position employee number
-- Last Modified: 
-----------------------------------------------------------------------------------------------------------------------

IF NOT EXISTS (SELECT 1 FROM SysObjects WHERE id=Object_ID('dbo.U_EmpNo_Master') AND ObjectProperty(id,'IsUserTable')=1)
BEGIN

	CREATE TABLE dbo.U_EmpNo_Master
	(
		MstEEID char(12) not null,
		MstCOID char(5) not null,
		MstEmpNo varchar(9) not null,
		MstDateOfLastHire datetime not null,
		MstDateTimeCreated datetime not null default getdate(),
		CONSTRAINT pk_U_EmpNo_Master PRIMARY KEY (MstEEID,MstCOID)
	) ON [PRIMARY]

	PRINT 'Created table: [U_EmpNo_Master]'

END
GO

go

IF (NOT EXISTS(SELECT 1 FROM sysconstraints WHERE OBJECT_NAME(constid) = 'pk_U_EmpNo_Master' AND OBJECT_NAME(id) = 'U_EmpNo_Master')) 
begin
	alter table dbo.U_EmpNo_Master 
	add constraint pk_U_EmpNo_Master primary key (MstEEID,MstCOID)
end

go