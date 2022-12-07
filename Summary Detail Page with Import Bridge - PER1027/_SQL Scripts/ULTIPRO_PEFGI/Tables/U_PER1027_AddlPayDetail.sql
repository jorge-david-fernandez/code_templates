----------------------------------------------------------------------------------------------------------------------
-- Company:		  UKG 
-- Author:		  Jorge Fernandez
-- Client:		  Performance Food Group, Inc.
-- Date:		  10/31/2022
-- Request:		  SR-2022-00377312
-- Purpose:		  Custom Web Page for Additional Pay Detail
-- Last Modified: 
-----------------------------------------------------------------------------------------------------------------------
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

IF OBJECT_ID('U_PER1027_AddlPayDetail','U') IS NULL
BEGIN
	CREATE TABLE [dbo].[U_PER1027_AddlPayDetail](
		[uapRecID]						[int] IDENTITY(1,1),
		[uapEmpNo]						[char](9) NOT NULL,
		[uapPayDate]					[datetime] NOT NULL,
		[uapWeekEndDate]				[datetime] NOT NULL,
		[uapDesc]						[varchar](50) NOT NULL,
		[uapHours]						[varchar](20) NULL,
		[uapUnits]						[varchar](20) NULL,
		[uapRate]						[varchar](20) NULL,
		[uapSales]						[varchar](20) NULL,
		[uapProfit]						[varchar](20) NULL,
		[uapSupplemental]				[varchar](20) NULL,
		[uapNotes]						[varchar](max) NULL,
		[uapDateTimeCreated]			[datetime] NOT NULL DEFAULT GETDATE(),
		[uapDateTimeUpdated]			[datetime] NOT NULL DEFAULT GETDATE(),
		[uapUpdatedBy]					[varchar](50) NOT NULL,
		[uapFileName]					[varchar](100) DEFAULT ''
	 CONSTRAINT [PK_U_PER1027_AddlPayDetail] PRIMARY KEY CLUSTERED 
	(
		[uapRecID] ASC
	)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
	) ON [PRIMARY]
END
GO