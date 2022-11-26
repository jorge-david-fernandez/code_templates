IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AutoRoleAssign_DeleteRecord]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[AutoRoleAssign_DeleteRecord]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

----------------------------------------------------------------------------
-- Author		:		Nathan Osterc
-- Client		:		Internal
-- Date                 :		2/3/2015 
-- Purpose              :		Web Automate Role Assignments - Remove Job Role Entry  
-- Last Modified Date   :		
-- Ultipro Version      :		Ultipro 10.8.2
----------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[AutoRoleAssign_DeleteRecord] (
	@DeleteList VARCHAR(8000)
) AS
BEGIN
	
	SET NOCOUNT ON
	
	DECLARE @tblList TABLE (
		RecordId VARCHAR(200)
	)
	
	SET XACT_ABORT ON
	
	SET @DeleteList = RTRIM(@DeleteList)
	
	IF (Len(@DeleteList) = 0) BEGIN
		RETURN
	END
	
	INSERT @tblList (
		RecordId
	) SELECT
		RTRIM(Item)
	FROM dbo.fn_ListToTable(@DeleteList)
	
	BEGIN TRY
	
		BEGIN TRANSACTION DelJobRoleRecs

		DELETE FROM AutoRoleAssign_JobRoleSecurity WHERE 
		rjsRecID IN (SELECT list.RecordId FROM @tblList list)
		
		DELETE FROM AutoRoleAssign_Qualifiers
		WHERE reqRecId IN (SELECT list.RecordId FROM @tblList list)
	
		COMMIT TRANSACTION DelJobRoleRecs
	
	END TRY
	BEGIN CATCH

 		DECLARE @ErrorMessage NVARCHAR(4000);
		DECLARE @ErrorSeverity INT;
		DECLARE @ErrorState INT;    
		
		ROLLBACK TRANSACTION DelJobRoleRecs
						
		SELECT 
		@ErrorMessage = ERROR_MESSAGE(),
		@ErrorSeverity = ERROR_SEVERITY(),
		@ErrorState = ERROR_STATE();
  
		RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState)

	END CATCH
	
	
END



GO
