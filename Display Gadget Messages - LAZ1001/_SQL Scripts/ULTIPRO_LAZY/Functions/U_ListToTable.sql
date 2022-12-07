----------------------------------------------------------------------------------------------------------------------
-- Company:		  Ultimate Software Corp. 
-- Author:		  Adrian Serrano
-- Client:		  Lazy Dog Restaurants, LLC
-- Date:		  1/28/2020
-- Request:		  SR-2019-00245269
-- Purpose:		  Instant Pay Direct Deposit (from scope project SR-2019-00233967)
-- Last Modified: 
-----------------------------------------------------------------------------------------------------------------------

IF OBJECT_ID(N'[dbo].[U_ListToTable]' ) IS NOT NULL  
DROP FUNCTION [dbo].[U_ListToTable] 
GO


CREATE FUNCTION dbo.U_ListToTable
(
  @List VARCHAR(MAX),
  @Delim CHAR
)
RETURNS
@ParsedList TABLE
(
  item VARCHAR(MAX)
)
AS
BEGIN
  DECLARE @item VARCHAR(MAX), @Pos INT
  SET @List = LTRIM(RTRIM(@List))+ @Delim
  SET @Pos = CHARINDEX(@Delim, @List, 1)
  WHILE @Pos > 0
  BEGIN
    SET @item = LTRIM(RTRIM(LEFT(@List, @Pos - 1)))
    IF @item <> ''
    BEGIN
      INSERT INTO @ParsedList (item)
      VALUES (CAST(@item AS VARCHAR(MAX)))
    END
    SET @List = RIGHT(@List, LEN(@List) - @Pos)
    SET @Pos = CHARINDEX(@Delim, @List, 1)
  END
  RETURN
END
GO
