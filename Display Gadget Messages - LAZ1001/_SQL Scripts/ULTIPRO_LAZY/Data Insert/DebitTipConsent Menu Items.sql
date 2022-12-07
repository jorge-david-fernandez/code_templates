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
Script to add custom menu elements

For actual script logic, skip ahead to "BEGIN SCRIPT".
There's a lot of lines at first to create utility procedures to assist in custom menu creation.

Modification History:
06/20/11 - DCW - Original version
06/01/12 - NCO - Add handling for "Action" element types (the "Things I Can Do" menu items)
04/10/13 - DCW - Improve handling for referencing custom elements in the paths, so that can create custom elements under custom elements.  Added EnsureRbsCoPageMap.
04/02/14 - DCW - Handle NULL RightsMask after custom element creation.
04/03/14 - DCW - Add handling for ProdCodeOverride and TabSequence parameters to AddMenuElement.
02/18/15 - DCW - Adding handling for Custom SiteLevel pages.
01/29/18 - WB - Adding handling for Benefits menus, which feature multiple core elements with the same labels (.Net Benefits & Benefits Prime)
*/

-- 09/10/13 - DCW - Idea for improvement.  If "UPDATE" or "DELETE" are specified, then "READ" must be specified too.

------------------------------------------------------
----------    UTILITY PROCEDURES    ------------------
------------------------------------------------------

------------------------------------------------------------------------------------------------------------
-- U_FN_WebCustoms_ListToTable.sql
------------------------------------------------------------------------------------------------------------

IF OBJECT_ID('dbo.U_FN_WebCustoms_ListToTable') IS NOT NULL
BEGIN
	DROP FUNCTION dbo.U_FN_WebCustoms_ListToTable
END
GO

/*
This is a copy of Core's fn_ListToTableCSVOrder function, except that instead of Items of Varchar(20), we return Items of Varchar(200).
*/
CREATE FUNCTION dbo.U_FN_WebCustoms_ListToTable (
    @p_List TEXT
) RETURNS @r_List TABLE (
    ID INT PRIMARY KEY CLUSTERED IDENTITY,
    Item VARCHAR(200)
) AS
BEGIN

    DECLARE @v_POS INT,
    @v_OldPOS INT,
    @v_Done BIT,
    @v_Str VARCHAR(200)

    SET @v_OldPOS = 0
    SET @v_Done = 0

    WHILE NOT (@v_Done = 1)
    BEGIN
        SET @v_POS = CHARINDEX(',', SUBSTRING(@p_List, @v_OldPos + 1, 200))

        IF (@v_POS > 0)
        BEGIN
            SET @v_Str = SUBSTRING(@p_List, @v_OldPos + 1, ABS(@v_POS - 1))
        END
        ELSE
        BEGIN
            SET @v_Str = SUBSTRING(@p_List, @v_OldPos + 1, 200)
            SET @v_Done = 1
        END

        SET @v_OldPOS = @v_OldPOS + @v_POS
        SET @v_Str = COALESCE(RTRIM(LTRIM(REPLACE(REPLACE(@v_Str,'''',''),'"',''))),'')

        INSERT INTO @r_List (Item) VALUES(@v_Str)
    END

    RETURN
END
GO

------------------------------------------------------------------------------------------------------------
-- U_FN_WebCustoms_GetCoreRerIDFromMenuPath.sql
------------------------------------------------------------------------------------------------------------

IF OBJECT_ID('dbo.U_FN_WebCustoms_GetRerIDFromMenuPath') IS NOT NULL
BEGIN
	DROP FUNCTION dbo.U_FN_WebCustoms_GetRerIDFromMenuPath
END
GO

/*
Utility function to return the RerID of a menu path (handles both core and custom elelements in the path)
*/
CREATE FUNCTION dbo.U_FN_WebCustoms_GetRerIDFromMenuPath (
	@MenuPath VARCHAR(300)
) RETURNS INT AS
BEGIN

	-- Return the RerID for a specified menu path, which is the heirarchy of menu labels delimited by ">" signs.
	-- For example: "System Admin > Business Rules"
	-- For pages on tabsets of the employee popup under "My Team" or "Employee Admin", a shorthad is allowed, as follows:
	-- "(Employee Popup)" may be used for "My Employees List > Employee Admin"
	--   Full Path :  Employee Admin > My Employees > My Employees List > Employee Admin > Jobs > Other
	--   Short Path:  Employee Admin > My Employees > (Employee Popup) > Jobs > Other
	
	-- As of 04/10/13, the path can contain a combination of core and custom elements. Previously used to expect them always to be core elements.

	DECLARE @MenuPathCommaDelimited VARCHAR(300)

	DECLARE
		@ProcessID		INT,
		@MaxID			INT,
		@ItemRerID		INT,
		@PrevRerID		INT,
		@ItemLabel		VARCHAR(200),
		@ItemsFound		INT

	DECLARE @tblMenuItem TABLE (
		RecID  INT IDENTITY(1,1),
		Item   VARCHAR(200)
	)

	-- There can't be commas already in the menu path. Unsupported.
	IF (CHARINDEX(',',@MenuPath) > 0) BEGIN
		RETURN -2
	END
	
	-- Ensure PageCoMaps  (DCW 04/10/13 Added)

	-- Replace (Employee Popup) for MSS
	IF (CHARINDEX('My Team', @MenuPath) > 0) BEGIN
		SET @MenuPath = REPLACE(@MenuPath, '(Employee Popup)', 'My Employees List > My Team')
	END

	-- Replace (Employee Popup) for EEADM
	IF (CHARINDEX('Employee Admin', @MenuPath) > 0) BEGIN
		SET @MenuPath = REPLACE(@MenuPath, '(Employee Popup)', 'My Employees List > Employee Admin')
	END

	-- Parse Menu Path into a table of items
	
	SET @MenuPathCommaDelimited = REPLACE(@MenuPath,' > ',',')

	INSERT @tblMenuItem (Item) SELECT item FROM dbo.U_FN_WebCustoms_ListToTable(@MenuPathCommaDelimited) ORDER BY ID
	
	-- Loop through items, successively getting RerID until get the last one

	SELECT @MaxID = MAX(RecID) FROM @tblMenuItem

	SET @MaxID = ISNULL(@MaxID,0)
	SET @ProcessID = 1
	SET @PrevRerID = 0
	SET @ItemRerID = -1

	WHILE (@ProcessID <= @MaxID) BEGIN

		SELECT @ItemLabel = Item FROM @tblMenuItem WHERE RecID = @ProcessID
		
		SET @ItemRerID = -1
		
		-- First, try to find the element as a core element
		SELECT @ItemRerID = rerID
		FROM HRMS_GLOBALDATA.dbo.RbsElementRelations (NoLock)
		JOIN HRMS_GLOBALDATA.dbo.RbsElements (NoLock) ON eleID = rerElementID
		LEFT JOIN HRMS_GLOBALDATA.dbo.RbsMenus (NoLock) ON menElementID = rerElementID
		LEFT JOIN HRMS_GLOBALDATA.dbo.RbsTabs  (NoLock) ON tabElementID = rerElementID
		LEFT JOIN HRMS_GLOBALDATA.dbo.RbsPages (NoLock) ON pagElementID = rerElementID
		WHERE rerParentID = @PrevRerID
		  AND @ItemLabel = REPLACE(CASE eleType		-- Core ElementTypes are defined in Hrms_GlobalData.dbo.RbsElementTypes
		                       WHEN 2 THEN pagDescription
		                       WHEN 3 THEN menText
		                       WHEN 4 THEN tabText
		                       ELSE NULL
		                   END, ',','')
		  AND (@ItemLabel <> 'Benefits Admin' OR rerProdCode = 'EBEN')
		  AND (@ItemLabel <> 'Life Events Setup' OR rerId = 3091)
		  AND (@ItemLabel <> 'Open Enrollment Setup' OR rerProdCode = 'NETOE')

		SELECT @ItemsFound = @@ROWCOUNT

		IF (@ItemsFound > 1) BEGIN
			RETURN -4
		END
		
		-- Next, try to find the element as a custom element   (DCW 04/10/13 Added)
		IF (@ItemsFound = 0) BEGIN
		
			SELECT @ItemRerID = rerID
			FROM dbo.RbsCoElementRelations (NoLock)
			JOIN dbo.RbsCoElements (NoLock) ON eleID = rerElementID
			LEFT JOIN dbo.RbsCoMenus (NoLock) ON menElementID = rerElementID
			LEFT JOIN dbo.RbsCoTabs  (NoLock) ON tabElementID = rerElementID
			LEFT JOIN dbo.RbsCoPages (NoLock) ON pagElementID = rerElementID
			WHERE rerParentID = @PrevRerID
			  AND rerLabel = @ItemLabel
			
			SELECT @ItemsFound = @@ROWCOUNT
			
			IF (@ItemsFound = 0) BEGIN
				RETURN -3
			END
			
			IF (@ItemsFound > 1) BEGIN
				RETURN -4
			END
			
		END
		
		SET @PrevRerID = @ItemRerID
		
		SET @ProcessID = @ProcessID + 1
		
	END
	
	-- Return the last item's RerID
	RETURN @ItemRerID

END
GO

------------------------------------------------------------------------------------------------------------
-- U_WebCustoms_EnsureRbsPageCoMap.sql
------------------------------------------------------------------------------------------------------------

IF OBJECT_ID('dbo.U_WebCustoms_EnsureRbsPageCoMap') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.U_WebCustoms_EnsureRbsPageCoMap
END
GO

/*
Utility Procedure to ensure the correct rows exist in RbsCoPageMap.

Table RbsCoPageMap is a system-delivered table, and is supposed to have system-delivered rows, two rows in all, one for "EDIT" and one for "VIEW",
and it maps the RbsCoPages.pagURL value (which is 1 or 2) to the actual subfolder under "UltiProNet\pages" that the aspx page will be found in (either "edit" or "view").
However, in new client databases, for whatever reason, the table is either empty, or has rows with values other than 1 or 2.
Therefore, we need to ensure this table is set up correctly, otherwise, the custom menu elements we add never get displayed or accessed in the menu system when the UltiProNet application runs.
*/
CREATE PROCEDURE dbo.U_WebCustoms_EnsureRbsPageCoMap
AS
BEGIN

	SET NOCOUNT ON
	
	DECLARE @ViewExists CHAR(1)
	DECLARE @EditExists CHAR(1)

	SET @ViewExists = 'N'
	SET @EditExists = 'N'

	SELECT @ViewExists = 'Y' FROM dbo.RbsCoPageMap (NoLock) WHERE rpmID = 1 AND rpmURL = 'VIEW'
	SELECT @EditExists = 'Y' FROM dbo.RbsCoPageMap (NoLock) WHERE rpmID = 2 AND rpmURL = 'EDIT'

	IF (@ViewExists = 'N') OR (@EditExists = 'N') BEGIN
	
		-- Note that truncating the table resets the identity column back to 1
		TRUNCATE TABLE dbo.RbsCoPageMap
		
		-- But still use Identity_Insert, just in case the table is set with rpmID column NOT being Identity sometimes (usually is)
		SET IDENTITY_INSERT dbo.RbsCoPageMap ON
		
		INSERT dbo.RbsCoPageMap (rpmID,rpmURL) VALUES (1,'VIEW')
		INSERT dbo.RbsCoPageMap (rpmID,rpmURL) VALUES (2,'EDIT')
		
		SET IDENTITY_INSERT dbo.RbsCoPageMap OFF
		
		PRINT 'Created needed entries in RbsCoPageMap'
	END
	
END
GO

------------------------------------------------------------------------------------------------------------
-- U_WebCustoms_AddMenuElement.sql
------------------------------------------------------------------------------------------------------------

IF OBJECT_ID('dbo.U_WebCustoms_AddMenuElement') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.U_WebCustoms_AddMenuElement
END
GO

/*
Utility Procedure to insert a custom menu or tab element
*/
CREATE PROCEDURE dbo.U_WebCustoms_AddMenuElement (
	@ElementLabel     VARCHAR(100),
	@ElementType      VARCHAR(10),   -- Either "MENU" or "TAB" or "ACTION"
	@ParentPath       VARCHAR(300),  -- Examples:  "System Admin" or "Employee Admin > My Employees > (Employee Popup) > Jobs".  See function U_FN_WebCustoms_GetCoreRerIDFromMenuPath for more.
	@ReferencePath    VARCHAR(300),  -- Examples:  "System Admin > Business Rules" or "Employee Admin > My Employees > (Employee Popup) > Jobs > Other".  See function U_FN_WebCustoms_GetCoreRerIDFromMenuPath for more.
	@EditOrViewFolder VARCHAR(10),   -- pass either "EDIT" or "VIEW"
	@AspxFilename     VARCHAR(100),  -- For TIMESMyCustomPage.aspx, pass either "TIMESMyCustomPage" or "TIMESMyCustomPage.aspx". We'll strip off the ".aspx".
	@AllowableRights  VARCHAR(100),   -- Comma-delimited list of rights like "CREATE,UPDATE,READ,DELETE" or any combination and order thereof
	@ProdCodeOverride VARCHAR(10) = '',  -- Sometimes pages are called for a prodcode different than how it gets added by SMC routine. In those cases we have to update ProdCode afterwards.
	@TabSequence      INT = 0,         -- needed only for relative ordering within tabsets
	@PageLocation     VARCHAR(20) = 'M'   -- "S" OR "SITE", or "M" OR "MASTERCOMPANY".  This is about if the page is located in Customs\pages\edit (site) or \Customs\USG\pages\edit (mastercompany)
) AS
BEGIN

	---------------------------------------
	-- DECLARES
	---------------------------------------

	SET NOCOUNT ON

	DECLARE @Xml_CustomElement VARCHAR(2000)

	DECLARE @TargetRerID INT
	DECLARE @TargetRightsMask INT
	DECLARE @SetElementType VARCHAR(10)
	DECLARE @RightsMask INT
	DECLARE @PagePermissions CHAR(1)
	DECLARE @ParentID INT
	DECLARE @ReferenceID INT
	DECLARE @CustomPath VARCHAR(300)
	DECLARE @ProdCode VARCHAR(20)
	DECLARE @CurrentTabSequence INT
	
	DECLARE
		@PagePermissions_URL_pages_edit CHAR(1),
		@PagePermissions_URL_pages_view CHAR(1)
	
	DECLARE
		@ACCESSBIT_NONE		INT,
		@ACCESSBIT_CREATE	INT,
		@ACCESSBIT_READ		INT,
		@ACCESSBIT_UPDATE	INT,
		@ACCESSBIT_DELETE	INT,
		@ACCESSBIT_EXECUTE	INT
	
	---------------------------------------
	-- INITIALIZE
	---------------------------------------
	
	EXEC dbo.U_WebCustoms_EnsureRbsPageCoMap	-- DCW 04/10/13 Added
	
	SELECT
		@PagePermissions_URL_pages_view = '1',
		@PagePermissions_URL_pages_edit = '2'

	-- These values correspond to the CrudeEnum values declared in RBSSecurableMenuItem.cs class in UltimateSoftware.Security assembly/project.
	SELECT
		@ACCESSBIT_NONE		= 0,
		@ACCESSBIT_CREATE	= 1,
		@ACCESSBIT_READ		= 2,
		@ACCESSBIT_UPDATE	= 4,
		@ACCESSBIT_DELETE	= 8,
		@ACCESSBIT_EXECUTE	= 16
		
	SET @Xml_CustomElement =
'<DATA>
 <CUSTOM> <ELEMENTTYPE EType="[[@ElementType]]" />
 <IDINFO ParentID="[[@ParentID]]" ReferenceID="[[@ReferenceID]]" />
 <CUSTOMLABEL CustomLabel="[[@Label]]" />
 <STATUS StatusFlag="A" />
 <TYPE Type="ASP Page" />
 <URL Url="[[@AspxFilenameRoot]]" />
 <DESCRIPTION Description="[[@Label]]" />
 <COUNTRY Country="*" />
 <LOCATION Location="[[@PageLocation]]" />
 <PERMISSIONS Permissions="[[@PagePermissions]]" />
 <LOCALIZED LanguageCode="en" CustomText="[[@Label]]" />
 <LOCALIZED LanguageCode="es" CustomText="[[@Label]] (sp)" />
 <LOCALIZED LanguageCode="fr" CustomText="[[@Label]] (fr)" />
</CUSTOM>
</DATA>
'
	
	---------------------------------------
	-- VALIDATE PARAMETERS
	---------------------------------------
	
	-- Get ParentID and ReferenceID from paths

	SET @ParentID = dbo.U_FN_WebCustoms_GetRerIDFromMenuPath(@ParentPath)
	
	IF (ISNULL(@ParentID,0) <= 0) BEGIN
		IF (ISNULL(@ParentID,0) <= 0) BEGIN
			PRINT 'Error: U_WebCustoms_AddMenuElement: Parent RerID could not be found'
			RETURN
		END
	END
	
	IF (@ReferencePath = @ParentPath) BEGIN
		SET @ReferenceID = @ParentID
	END ELSE BEGIN
		SET @ReferenceID = dbo.U_FN_WebCustoms_GetRerIDFromMenuPath(@ReferencePath)
	END

	IF (ISNULL(@ReferenceID,0) <= 0) BEGIN
		PRINT 'Error: U_WebCustoms_AddMenuElement: Reference RerID could not be found'
		RETURN
	END
	
	SET @CustomPath = @ParentPath + ' > ' + @ElementLabel
	
	-- Validate/Set PagePermissions from EditOrViewFolder parameter
	
	SET @PagePermissions = ''
	
	IF (@EditOrViewFolder = 'VIEW') BEGIN
		SET @PagePermissions = @PagePermissions_URL_pages_view
	END
	
	IF (@EditOrViewFolder = 'EDIT') BEGIN
		SET @PagePermissions = @PagePermissions_URL_pages_edit
	END
	
	IF (@PagePermissions = '') BEGIN
		PRINT 'Error: U_WebCustoms_AddMenuElement: Invalid EditOrViewFolder parameter specified.  Must be either "EDIT" or "VIEW".'
		RETURN
	END
	
	-- Validate ElementType
	
	SET @SetElementType = ''
	
	IF (@ElementType = 'MENU') BEGIN
		SET @SetElementType = 'Menu'
	END
	
	IF (@ElementType = 'TAB') BEGIN
		SET @SetElementType = 'Tab'
	END

	IF (@ElementType = 'ACTION') BEGIN
		SET @SetElementType = 'Action'
	END
	
	IF (@SetElementType = '') BEGIN
		PRINT 'Error: U_WebCustoms_AddMenuElement: Invalid ElementType parameter specified.  Must be either "Menu", "Tab", or "Action".'
		RETURN
	END
	
	-- Validate AspxFilename
	
	SET @AspxFilename = REPLACE(@AspxFilename,'.aspx','')
	
	IF (CHARINDEX(',',@AspxFilename) > 0) OR (CHARINDEX('\',@AspxFilename) > 0) OR (CHARINDEX('/',@AspxFilename) > 0) BEGIN
		PRINT 'Invalid AspxFilename parameter. No dots or slashes allowed (other than .aspx)'
		RETURN
	END
	
	-- Validate/Set AllowableRights
	
	SET @RightsMask = @ACCESSBIT_NONE
	
	SET @AllowableRights = ',' + @AllowableRights + ','
	
	IF (CHARINDEX(',ADD,',@AllowableRights) > 0) OR (CHARINDEX(',CREATE,',@AllowableRights) > 0) BEGIN
		SET @RightsMask = @RightsMask + @ACCESSBIT_CREATE
	END
	
	IF (CHARINDEX(',CHANGE,',@AllowableRights) > 0) OR (CHARINDEX(',UPDATE,',@AllowableRights) > 0) BEGIN
		SET @RightsMask = @RightsMask + @ACCESSBIT_UPDATE
	END
	
	IF (CHARINDEX(',REMOVE,',@AllowableRights) > 0) OR (CHARINDEX(',DELETE,',@AllowableRights) > 0) BEGIN
		SET @RightsMask = @RightsMask + @ACCESSBIT_DELETE
	END
	
	IF (CHARINDEX(',VIEW,',@AllowableRights) > 0) OR (CHARINDEX(',READ,',@AllowableRights) > 0) BEGIN
		SET @RightsMask = @RightsMask + @ACCESSBIT_READ
	END
	
	IF (@RightsMask = @ACCESSBIT_NONE) BEGIN
		PRINT 'Error: U_WebCustoms_AddMenuElement: Invalid AllowableRights parameter.'
		RETURN
	END
	
	-- Validate PageLocation
	
	IF (@PageLocation = 'MASTERCOMPANY') BEGIN
		SET @PageLocation = 'M'
	END
	
	IF (@PageLocation = 'SITE') BEGIN
		SET @PageLocation = 'S'
	END
	
	IF (@PageLocation NOT IN('M','S')) BEGIN
		PRINT 'Error: U_WebCustoms_AddMenuElement: Invalidate PageLocation parameter must be M (MASTERCOMPANY) or S (SITE)'
		RETURN
	END
	
	---------------------------------------
	-- CHECK EXISTS
	---------------------------------------
	
	SET @TargetRerID = 0
	
	SELECT 
		@TargetRerID = rerID,
		@TargetRightsMask = ISNULL(rerRightsMask,0),
		@ProdCode = ISNULL(rerProdCode,''),
		@CurrentTabSequence = ISNULL(rerSequence,0)
	FROM dbo.RbsCoElementRelations (NoLock)
	WHERE rerParentID = @ParentID
	  AND rerLabel = @ElementLabel
	
	---------------------------------------
	-- ADD
	---------------------------------------
	
	IF (@TargetRerID = 0) BEGIN
	
		-- Set ElementType
		SET @Xml_CustomElement = REPLACE(@Xml_CustomElement, '[[@ElementType]]', @SetElementType)

		-- Set Parent rerID
		SET @Xml_CustomElement = REPLACE(@Xml_CustomElement, '[[@ParentID]]', CONVERT(VARCHAR(10), @ParentID) )
		
		-- Set Reference rerID (element after which, positionally, we should go)
		SET @Xml_CustomElement = REPLACE(@Xml_CustomElement, '[[@ReferenceID]]', CONVERT(VARCHAR(10), @ReferenceID) )

		-- Set Page "Permissions" (which pages folder will this go into, the "pages/view" folder, or the "pages/edit" folder?) (corresponds to RbsCoPages.pagURL)
		SET @Xml_CustomElement = REPLACE(@Xml_CustomElement, '[[@PagePermissions]]', @PagePermissions)
		
		-- Set ASPX filename
		SET @Xml_CustomElement = REPLACE(@Xml_CustomElement, '[[@AspxFilenameRoot]]', @AspxFilename)

		-- Set Label text
		SET @Xml_CustomElement = REPLACE(@Xml_CustomElement, '[[@Label]]', @ElementLabel)
		
		-- Set Page Location
		SET @Xml_CustomElement = REPLACE(@Xml_CustomElement, '[[@PageLocation]', @PageLocation)

		-- Create custom menu element
		EXEC dbo.HRMS_SMC_NewCustomElements_Save @Xml_CustomElement
		
		-- See if got created
		SELECT 
			@TargetRerID = rerID,
			@TargetRightsMask = ISNULL(rerRightsMask,0),
			@ProdCode = ISNULL(rerProdCode,''),
			@CurrentTabSequence = ISNULL(rerSequence,0)
		FROM dbo.RbsCoElementRelations (NoLock)
		WHERE rerParentID = @ParentID
		  AND rerLabel = @ElementLabel

		IF (@TargetRerID <> 0) BEGIN
			PRINT 'U_WebCustoms_AddMenuElement: Created custom ' + @SetElementType + ' item: ' + @CustomPath
		END ELSE BEGIN
			PRINT 'Error: U_WebCustoms_AddMenuElement: Error creating custom ' + @SetElementType + ' item "' + @CustomPath + '". Custom menu item not created.'
			RETURN
		END
	
	END ELSE BEGIN
	
		PRINT 'U_WebCustoms_AddMenuElement: Custom ' + @SetElementType + ' item "' + @CustomPath + '" already existed, did not need to add.'
	
	END
	
	---------------------------------------
	-- SET RIGHTS
	---------------------------------------
	
	IF (@TargetRerID <> 0) BEGIN
		IF (@TargetRightsMask <> @RightsMask) BEGIN
			UPDATE dbo.RbsCoElementRelations SET rerRightsMask = @RightsMask WHERE rerID = @TargetRerID
			PRINT 'U_WebCustoms_AddMenuElement: Adjusted RightsMask for: ' + @CustomPath
		END
	END
	
	---------------------------------------
	-- SET PRODCODE
	---------------------------------------
	
	IF (@TargetRerID <> 0) AND (@ProdCodeOverride != '') BEGIN
		IF (@ProdCode <> @ProdCodeOverride) BEGIN
			UPDATE dbo.RbsCoElementRelations SET rerProdCode = @ProdCodeOverride WHERE rerID = @TargetRerID
			PRINT 'U_WebCustoms_AddMenuElement: Adjusted ProdCode for: ' + @CustomPath
		END
	END
	
	---------------------------------------
	-- SET TAB SEQUENCE
	---------------------------------------
	
	IF (@TargetRerID <> 0) AND (@TabSequence > 0) BEGIN
		IF (@TabSequence <> @CurrentTabSequence) BEGIN
			UPDATE dbo.RbsCoElementRelations SET rerSequence = @TabSequence WHERE rerID = @TargetRerID
			PRINT 'U_WebCustoms_AddMenuElement: Adjusted Sequence for: ' + @CustomPath
		END
	END
	
END
GO

------------------------------------------------------------------------------------------------------------
-- U_WebCustoms_RemoveMenuElement.sql
------------------------------------------------------------------------------------------------------------

IF OBJECT_ID('dbo.U_WebCustoms_RemoveMenuElement') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.U_WebCustoms_RemoveMenuElement
END
GO

/*
Utility Procedure to remove a custom menu or tab element.
*/
CREATE PROCEDURE dbo.U_WebCustoms_RemoveMenuElement (
	@CustomPath VARCHAR(300)    -- Examples:  "System Admin > Stock Grant Codes" or "Employee Admin > My Employees > (Employee Popup) > Jobs > Stock Grants"
) AS
BEGIN

	SET NOCOUNT ON

	DECLARE @ParentPath VARCHAR(300)
	DECLARE @CustomElementLabel VARCHAR(100)
	DECLARE @CustomRerID INT
	DECLARE @CustomElementType VARCHAR(50)
	DECLARE @ParentID INT
	DECLARE @MenuPathCommaDelimited VARCHAR(300)
	DECLARE @MaxRecID INT
	DECLARE @DeleteXML NVARCHAR(4000)
	
	DECLARE @tblMenuItems TABLE (
		RecID  INT IDENTITY(1,1),
		Item   VARCHAR(200)
	)

	SET @DeleteXML = 
'<DATA>
  <CUSTOM>
    <IDINFO rerID="[[DeleteRerID]]" EType="[[DeleteElementType]]" />
  </CUSTOM>
</DATA>'
	
	-- There can't be commas already in the menu path. Unsupported.
	IF (CHARINDEX(',',@CustomPath) > 0) BEGIN
		PRINT 'Error: U_WebCustoms_RemoveMenuElement: Commas not allowed in the CustomPath parameter.  CustomPath=[' + @CustomPath + ']'
		RETURN
	END
	
	-- Parse Menu Path into a table of items
	
	SET @MenuPathCommaDelimited = REPLACE(@CustomPath,' > ',',')

	INSERT @tblMenuItems (Item) SELECT item FROM dbo.U_FN_WebCustoms_ListToTable(@MenuPathCommaDelimited) ORDER BY ID
	
	-- Validate the parsing
	
	SELECT @MaxRecID = MAX(RecID) FROM @tblMenuItems
	
	SET @MaxRecID = ISNULL(@MaxRecID,0)
	
	IF (@MaxRecID = 0) BEGIN
		PRINT 'Error: U_WebCustoms_RemoveMenuElement: Error parsing CustomPath parameter. Zero elements retrieved. CustomPath=[' + @CustomPath + ']'
		RETURN
	END
	
	IF (@MaxRecID = 1) BEGIN
		PRINT 'Error: U_WebCustoms_RemoveMenuElement: CustomPath parameter should have more than one item in the path. CustomPath=[' + @CustomPath + ']'
		RETURN
	END
	
	-- Last item is the custom item
	SELECT @CustomElementLabel = Item FROM @tblMenuItems WHERE RecID = @MaxRecID

	-- Build the parent path (everything but the last item)
	
	SET @ParentPath = ''
	
	SELECT @ParentPath = @ParentPath + ' > ' + Item
	  FROM @tblMenuItems
	 WHERE RecID <> @MaxRecID
	ORDER BY RecID
	
	-- Remove initial " > "
	SET @ParentPath = SUBSTRING(@ParentPath,4,LEN(@ParentPath))
	
	IF (LEN(@ParentPath) = 0) BEGIN
		PRINT 'Error: U_WebCustoms_RemoveMenuElement: Some problem re-establishing ParentPath. Came up blank. CustomPath=[' + @CustomPath + '] ParentPath=[' + @ParentPath + ']'
		RETURN
	END
	
	-- Get ParentID
	
	SET @ParentID = dbo.U_FN_WebCustoms_GetRerIDFromMenuPath(@ParentPath)
	
	IF (ISNULL(@ParentID,0) <= 0) BEGIN
		PRINT 'Error: U_WebCustoms_RemoveMenuElement: Parent RerID could not be found. CustomPath=[' + @CustomPath + '] ParentPath=[' + @ParentPath + ']'
		RETURN
	END
	
	-- Get Custom RerID
	
	SELECT 
		@CustomRerID = rerID,
		@CustomElementType = eltDescription
	  FROM dbo.RbsCoElementRelations (NoLock)
	  JOIN dbo.RbsCoElements (NoLock) ON eleID = rerElementID
	  JOIN dbo.RbsCoElementTypes (NoLock) ON eltID = eleType
	 WHERE rerParentID = @ParentID
	   AND rerLabel = @CustomElementLabel
	
	-- Remove Custom menu item
	
	IF (@CustomRerID IS NULL) BEGIN
		PRINT 'Info: U_WebCustoms_RemoveMenuElement: Custom menu element not found. No need to remove. CustomPath=[' + @CustomPath + ']'
	END ELSE BEGIN
		IF (@CustomElementType NOT IN ('Menu','Tab','Action')) BEGIN
			PRINT 'Error: U_WebCustoms_RemoveMenuElement: Only Menu, Tab, or Action custom element types are supported. Unsupported ElementType=[' + @CustomElementType + ']. CustomPath=[' + @CustomPath + ']'
		END ELSE BEGIN
			-- REMOVE  (note that the core stored procedure we're calling will take care of deleting child/dependent records (e.g. RbsCoElements, RbsCoPages) when nothing else reference these any longer)
			SET @DeleteXML = REPLACE(@DeleteXML, '[[DeleteRerID]]', CAST(@CustomRerID AS VARCHAR(20)))
			SET @DeleteXML = REPLACE(@DeleteXML, '[[DeleteElementType]]', @CustomElementType)
			EXEC HRMS_SMC_CustomElements_Delete @XML = @DeleteXML
			PRINT 'U_WebCustoms_RemoveMenuElement: Removed custom menu element: ' + @CustomPath
		END
	END
	
END
GO

------------------------------------------------------
----------      BEGIN SCRIPT      --------------------
------------------------------------------------------

-- Add menu item:  System Configuration > Custom Labels
EXEC dbo.U_WebCustoms_AddMenuElement
	@ElementLabel     = 'Pay Consent Settings',
	@ElementType      = 'Tab',
	@ParentPath       = 'Myself > Pay',
	@ReferencePath    = 'Myself > Pay > Direct Deposit',    -- this is the menu item AFTER which we want ours to appear
	@EditOrViewFolder = 'EDIT',
	@AspxFilename     = 'EmpDebitTipConsentDetail.aspx',          -- we reference a page, just use the same page as the first submenu item will use
	@AllowableRights  = 'CREATE,READ,UPDATE,DELETE'

EXEC dbo.U_WebCustoms_AddMenuElement
	@ElementLabel     = 'Pay Consent Settings',
	@ElementType      = 'Tab',
	@ParentPath       = 'My Team > My Employees > (Employee Popup) > Pay',
	@ReferencePath    = 'My Team > My Employees > (Employee Popup) > Pay > Direct Deposit',    -- this is the menu item AFTER which we want ours to appear
	@EditOrViewFolder = 'EDIT',
	@AspxFilename     = 'EmpDebitTipConsentDetail.aspx',          -- we reference a page, just use the same page as the first submenu item will use
	@AllowableRights  = 'CREATE,READ,UPDATE,DELETE'

EXEC dbo.U_WebCustoms_AddMenuElement
	@ElementLabel     = 'Pay Consent Settings',
	@ElementType      = 'Tab',
	@ParentPath       = 'Employee Admin > My Employees > (Employee Popup) > Pay',
	@ReferencePath    = 'Employee Admin > My Employees > (Employee Popup) > Pay > Direct Deposit',    -- this is the menu item AFTER which we want ours to appear
	@EditOrViewFolder = 'EDIT',
	@AspxFilename     = 'EmpDebitTipConsentDetail.aspx',          -- we reference a page, just use the same page as the first submenu item will use
	@AllowableRights  = 'CREATE,READ,UPDATE,DELETE'

EXEC dbo.U_WebCustoms_AddMenuElement
	@ElementLabel     = 'Pay Consent Settings PopUp',
	@ElementType      = 'Tab',
	@ParentPath       = 'Myself',
	@ReferencePath    = 'Myself',    -- this is the menu item AFTER which we want ours to appear
	@EditOrViewFolder = 'EDIT',
	@AspxFilename     = 'DebitTipConsentPopUp.aspx',          -- we reference a page, just use the same page as the first submenu item will use
	@AllowableRights  = 'UPDATE,READ'

EXEC dbo.U_WebCustoms_AddMenuElement
	@ElementLabel     = 'Pay Consent Settings PopUp',
	@ElementType      = 'Tab',
	@ParentPath       = 'My Team',
	@ReferencePath    = 'My Team',    -- this is the menu item AFTER which we want ours to appear
	@EditOrViewFolder = 'EDIT',
	@AspxFilename     = 'DebitTipConsentPopUp.aspx',          -- we reference a page, just use the same page as the first submenu item will use
	@AllowableRights  = 'UPDATE,READ'

EXEC dbo.U_WebCustoms_AddMenuElement
	@ElementLabel     = 'Pay Consent Settings PopUp',
	@ElementType      = 'Tab',
	@ParentPath       = 'Employee Admin',
	@ReferencePath    = 'Employee Admin',    -- this is the menu item AFTER which we want ours to appear
	@EditOrViewFolder = 'EDIT',
	@AspxFilename     = 'DebitTipConsentPopUp.aspx',          -- we reference a page, just use the same page as the first submenu item will use
	@AllowableRights  = 'UPDATE,READ'

EXEC dbo.U_WebCustoms_AddMenuElement
	@ElementLabel     = 'Pay Consent History',
	@ElementType      = 'Tab',
	@ParentPath       = 'Myself > Pay',
	@ReferencePath    = 'Myself > Pay > Pay Consent Settings',    -- this is the menu item AFTER which we want ours to appear
	@EditOrViewFolder = 'EDIT',
	@AspxFilename     = 'EmpDebitTipConsentHistorySummary.aspx',          -- we reference a page, just use the same page as the first submenu item will use
	@AllowableRights  = 'CREATE,READ,UPDATE,DELETE'

EXEC dbo.U_WebCustoms_AddMenuElement
	@ElementLabel     = 'Pay Consent History',
	@ElementType      = 'Tab',
	@ParentPath       = 'My Team > My Employees > (Employee Popup) > Pay',
	@ReferencePath    = 'My Team > My Employees > (Employee Popup) > Pay > Pay Consent Settings',    -- this is the menu item AFTER which we want ours to appear
	@EditOrViewFolder = 'EDIT',
	@AspxFilename     = 'EmpDebitTipConsentHistorySummary.aspx',          -- we reference a page, just use the same page as the first submenu item will use
	@AllowableRights  = 'CREATE,READ,UPDATE,DELETE'

EXEC dbo.U_WebCustoms_AddMenuElement
	@ElementLabel     = 'Pay Consent History',
	@ElementType      = 'Tab',
	@ParentPath       = 'Employee Admin > My Employees > (Employee Popup) > Pay',
	@ReferencePath    = 'Employee Admin > My Employees > (Employee Popup) > Pay > Pay Consent Settings',    -- this is the menu item AFTER which we want ours to appear
	@EditOrViewFolder = 'EDIT',
	@AspxFilename     = 'EmpDebitTipConsentHistorySummary.aspx',          -- we reference a page, just use the same page as the first submenu item will use
	@AllowableRights  = 'CREATE,READ,UPDATE,DELETE'

EXEC dbo.U_WebCustoms_AddMenuElement
	@ElementLabel     = 'Pay Consent History Detail',
	@ElementType      = 'Tab',
	@ParentPath       = 'Myself',
	@ReferencePath    = 'Myself',    -- this is the menu item AFTER which we want ours to appear
	@EditOrViewFolder = 'EDIT',
	@AspxFilename     = 'EmpDebitTipConsentHistoryDetail.aspx',          -- we reference a page, just use the same page as the first submenu item will use
	@AllowableRights  = 'CREATE,READ,UPDATE,DELETE'

EXEC dbo.U_WebCustoms_AddMenuElement
	@ElementLabel     = 'Pay Consent History Detail',
	@ElementType      = 'Tab',
	@ParentPath       = 'My Team',
	@ReferencePath    = 'My Team',    -- this is the menu item AFTER which we want ours to appear
	@EditOrViewFolder = 'EDIT',
	@AspxFilename     = 'EmpDebitTipConsentHistoryDetail.aspx',          -- we reference a page, just use the same page as the first submenu item will use
	@AllowableRights  = 'CREATE,READ,UPDATE,DELETE'

EXEC dbo.U_WebCustoms_AddMenuElement
	@ElementLabel     = 'Pay Consent History Detail',
	@ElementType      = 'Tab',
	@ParentPath       = 'Employee Admin',
	@ReferencePath    = 'Employee Admin',    -- this is the menu item AFTER which we want ours to appear
	@EditOrViewFolder = 'EDIT',
	@AspxFilename     = 'EmpDebitTipConsentHistoryDetail.aspx',          -- we reference a page, just use the same page as the first submenu item will use
	@AllowableRights  = 'CREATE,READ,UPDATE,DELETE'


--EXEC dbo.U_WebCustoms_AddMenuElement
--	@ElementLabel     = 'Change Pay Statement Preference',
--	@ElementType      = 'Action',
--	@ParentPath       = 'My Team > My Employees > (Employee Popup) > Pay',
--	@ReferencePath    = 'My Team > My Employees > (Employee Popup) > Pay > Direct Deposit',    -- this is the menu item AFTER which we want ours to appear
--	@EditOrViewFolder = 'EDIT',
--	@AspxFilename     = 'ARA1002EeDDAPreference.aspx',          -- we reference a page, just use the same page as the first submenu item will use
--	@AllowableRights  = 'UPDATE,READ'


--EXEC dbo.U_WebCustoms_AddMenuElement
--	@ElementLabel     = 'Change Pay Statement Preference',
--	@ElementType      = 'Action',
--	@ParentPath       = 'Employee Admin > My Employees > (Employee Popup) > Pay',
--	@ReferencePath    = 'Employee Admin > My Employees > (Employee Popup) > Pay > Direct Deposit',    -- this is the menu item AFTER which we want ours to appear
--	@EditOrViewFolder = 'EDIT',
--	@AspxFilename     = 'ARA1002EeDDAPreference.aspx',          -- we reference a page, just use the same page as the first submenu item will use
--	@AllowableRights  = 'UPDATE,READ'

/*
UNDO:
EXEC dbo.U_WebCustoms_RemoveMenuElement 'Myself > Pay > Pay Consents History Detail'
*/

GO

------------------------------------------------------
----------   DROP UTILITY PROCEDURES  ----------------
------------------------------------------------------

IF OBJECT_ID('dbo.U_WebCustoms_RemoveMenuElement') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.U_WebCustoms_RemoveMenuElement
END
GO

IF OBJECT_ID('dbo.U_WebCustoms_AddMenuElement') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.U_WebCustoms_AddMenuElement
END
GO

IF OBJECT_ID('dbo.U_FN_WebCustoms_GetRerIDFromMenuPath') IS NOT NULL
BEGIN
	DROP FUNCTION dbo.U_FN_WebCustoms_GetRerIDFromMenuPath
END
GO

IF OBJECT_ID('dbo.U_WebCustoms_EnsureRbsPageCoMap') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.U_WebCustoms_EnsureRbsPageCoMap
END
GO

IF OBJECT_ID('dbo.U_FN_WebCustoms_ListToTable') IS NOT NULL
BEGIN
	DROP FUNCTION dbo.U_FN_WebCustoms_ListToTable
END
GO
