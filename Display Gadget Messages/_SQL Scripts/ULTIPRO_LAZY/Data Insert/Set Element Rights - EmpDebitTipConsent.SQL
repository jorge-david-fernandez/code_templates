/*======================================================================================
 * Company:    Ultimate Sofware Corp.
 * Author:     Adrian Serrano
 * Date:       9/11/2019
 * Client:     Lazy Dog Restaurants, LLC
 * Filename:   _SQL Scripts\Data Insert\Set Element Rights - EmpDebitTipConsent.SQL
 * CP Request: SR-2019-00245269
 * Purpose:    Adjusts Rights mask - EmpDebitTipConsent
 * 
 * Last Modified: 
 * 
 * =====================================================================================*/

DECLARE @PageName VARCHAR(60)
SET @PageName = 'EmpDebitTipConsentSummary'

IF EXISTS( SELECT menElementID 
             FROM rbsCoMenus (NOLOCK)
             JOIN rbsCoPages (NOLOCK) ON menPageID = pagID
            WHERE pagName = @PageName )
BEGIN
	UPDATE rbsCOElementRelations
	   SET rerRightsMask = 15
	 WHERE rerID in ( SELECT rerId 
                        FROM rbsCOelementrelations (NOLOCK) 
                        JOIN rbsCoMenus (NOLOCK) ON menElementID = rerElementID
                        JOIN rbsCoPages (NOLOCK) ON menPageID    = pagID
                       WHERE pagName = @PageName )
END

GO
