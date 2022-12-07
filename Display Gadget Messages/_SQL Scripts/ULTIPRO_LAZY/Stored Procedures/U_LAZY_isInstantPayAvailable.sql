----------------------------------------------------------------------------------------------------------------------
-- Company:		  Ultimate Software Corp. 
-- Author:		  Adrian Serrano
-- Client:		  Lazy Dog Restaurants, LLC
-- Date:		  9/11/2019
-- Request:		  SR-2019-00245269
-- Purpose:		  Instant Pay Direct Deposit (from scope project SR-2019-00233967)
-- Last Modified: 
-----------------------------------------------------------------------------------------------------------------------

IF OBJECT_ID(N'[dbo].[U_LAZY_isInstantPayAvailable]') IS NOT NULL  
DROP PROCEDURE [dbo].[U_LAZY_isInstantPayAvailable] 
GO

CREATE PROCEDURE dbo.U_LAZY_isInstantPayAvailable
(
	@LocID char(6)
)
AS 
BEGIN

	SELECT isEnabled
    FROM (	SELECT mfv.ObjectId 
                 , mo.ClassUniqueId 
                 , mo.StandardPrimaryKeyString1 as LocCode
                 , ObjectSeqNo = ROW_NUMBER() OVER (PARTITION BY mfv.ObjectId, mfv.FieldUniqueId ORDER BY mfv.Effective DESC, mfv.Created DESC) 
                 , mfv.BooleanValue + 0 AS isEnabled	         
			FROM MetaObject mo (NOLOCK)
			JOIN MetaFieldValue mfv (NOLOCK) ON mfv.ObjectId = mo.Id 
			WHERE mo.ClassUniqueId = 'SLocation' 
			  AND FieldUniqueId = '_BInstantPay' 
			  AND mo.StandardPrimaryKeyString1 = @LocID) as a
    WHERE ObjectSeqNo = 1
	  
END
GO

