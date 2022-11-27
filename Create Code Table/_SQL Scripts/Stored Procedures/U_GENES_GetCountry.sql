
IF EXISTS (SELECT * FROM sysObjects WHERE ID = Object_ID('dbo.U_GENES_GetCountry') AND ObjectProperty(id,'IsProcedure')=1) BEGIN
	DROP PROCEDURE dbo.U_GENES_GetCountry
END
GO

SET QUOTED_IDENTIFIER ON 
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE dbo.U_GENES_GetCountry
	@DedCode CHAR(5) = NULL
AS
BEGIN

----------------------------------------------------------------------------------------------------------------------
-- Company:		  Ultimate Software Corp. 
-- Author:		  Jorge David Fernandez
-- Client:		  Genesco Inc.
-- Date:		  1/4/2017
-- Request:		  SR-2016-00137430
-- Purpose:		  Custom Web Page to Manage Translation Table for Position Key Export
-- Last Modified: 
-----------------------------------------------------------------------------------------------------------------------
	SELECT CodCode AS [Code], CodDesc AS [Description]
	FROM Codes (NOLOCK)
	WHERE CodTable = 'COUNTRY'
	AND CodCode IN ('CAN','USA')
END
GO
