Create SMC Menu Items

To find the reference path do as follows:

1. Find rerParentID of label you want to insert next to

```sql
declare @ItemLabel varchar(50) = 'View Pending Pay Items Status History'
SELECT rerID, *
        FROM HRMS_GLOBALDATA.dbo.RbsElementRelations (NoLock)
        JOIN HRMS_GLOBALDATA.dbo.RbsElements (NoLock) ON eleID = rerElementID
        LEFT JOIN HRMS_GLOBALDATA.dbo.RbsMenus (NoLock) ON menElementID = rerElementID
        LEFT JOIN HRMS_GLOBALDATA.dbo.RbsTabs  (NoLock) ON tabElementID = rerElementID
        LEFT JOIN HRMS_GLOBALDATA.dbo.RbsPages (NoLock) ON pagElementID = rerElementID
        LEFT JOIN HRMS_GLOBALDATA.dbo.RbsActions (Nolock) ON actElementID = rerElementID
        WHERE -- rerParentID = @PrevRerID
          -- AND 
          @ItemLabel = CASE eleType     -- Core ElementTypes are defined in Hrms_GlobalData.dbo.RbsElementTypes
                               WHEN 2 THEN pagDescription
                               WHEN 3 THEN menText
                               WHEN 4 THEN tabText
                               WHEN 5 THEN actText
                               ELSE NULL
                           END
```
2. Select rerParentID and construct path up until rerParentID is 0
```sql
-- Payroll Processing > Payroll Gateway > Payroll Gateway > Payroll Overview > View Pending Pay Items Status History
SELECT rerID, rerParentID,*
        FROM HRMS_GLOBALDATA.dbo.RbsElementRelations (NoLock)
        JOIN HRMS_GLOBALDATA.dbo.RbsElements (NoLock) ON eleID = rerElementID
        LEFT JOIN HRMS_GLOBALDATA.dbo.RbsMenus (NoLock) ON menElementID = rerElementID
        LEFT JOIN HRMS_GLOBALDATA.dbo.RbsTabs  (NoLock) ON tabElementID = rerElementID
        LEFT JOIN HRMS_GLOBALDATA.dbo.RbsPages (NoLock) ON pagElementID = rerElementID
        LEFT JOIN HRMS_GLOBALDATA.dbo.RbsActions (Nolock) ON actElementID = rerElementID
        WHERE rerId = 323
```