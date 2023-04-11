----------------------------------------------------------------------------------------------------------------------
-- Company:		  UKG 
-- Author:		  Jorge Fernandez
-- Client:		  Tesla, Inc.
-- Date:		  	4/6/2023
-- Request:		  SR-2023-00398983
-- Purpose:		  Modify Rehire employee and Transfer Employee to retail 6 position employee number
-- Last Modified: 
-----------------------------------------------------------------------------------------------------------------------
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.U_EmpNo_Log') AND type in (N'U'))
BEGIN
	CREATE TABLE dbo.U_EmpNo_Log
	(
		DateTimeCreated DateTime NOT NULL default(GetDate()),
		ID Int Identity NOT NULL,
		LogMessage xml NULL,
		CONSTRAINT [PK_U_EmpNo_Log] PRIMARY KEY CLUSTERED 
		(
			DateTimeCreated ASC,
			ID ASC
		)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
	) ON [PRIMARY]
END
GO