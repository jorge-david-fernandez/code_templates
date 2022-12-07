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
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[U_LAZ1001_OnboardingFieldValues]') AND type in (N'U'))
BEGIN
	CREATE TABLE [dbo].[U_LAZ1001_OnboardingFieldValues](
		[onb_SystemID] [int] IDENTITY(1,1) NOT NULL,
		[onb_PendHireSystemID] [int] NOT NULL,
		[onb_FieldNameID] [VARCHAR](100) NOT NULL,
		[onb_FieldValue] [NVARCHAR](MAX) NOT NULL,
		[onb_DateInserted] [datetime] NOT NULL DEFAULT (getdate()),
	 CONSTRAINT [PK_u_LAZ1001_OnboardingFieldValues] PRIMARY KEY CLUSTERED 
	(
		[onb_SystemID] ASC
	)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
	) ON [PRIMARY]
END
GO