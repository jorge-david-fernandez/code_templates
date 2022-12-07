/// <Header summary>
///Company:		  Ultimate Software Corp. 
///Author:		  Adrian Serrano
///Client:		  Lazy Dog Restaurants, LLC
///Date:		  12/19/2019
///Request:		  SR-2019-00245269
///Purpose:		  Instant Pay Direct Deposit (from scope project SR-2019-00233967)
///Last Modified: 

/// </Header summary>


$(document).ready(function () {
    if (typeof (meal1Waiver) != 'undefined' && meal1Waiver) {
        //Populate PC field
        USMeta.Utils.addMetaComplete(SetMeal1Waiver);

        function SetMeal1Waiver() {
            var form = USMetaRuntime.currentPage.forms[0];

            if (typeof form.root._FUDField24 != 'undefined') {
                form.root._FUDField24.update({ Value: meal1Waiver });
            }
        }
    }
    if (typeof (meal2Waiver) != 'undefined' && meal2Waiver) {
        //Populate PC field
        USMeta.Utils.addMetaComplete(SetMeal2Waiver);

        function SetMeal2Waiver() {
            var form = USMetaRuntime.currentPage.forms[0];

            if (typeof form.root._FUDField23 != 'undefined') {
                form.root._FUDField23.update({ Value: meal2Waiver });
            }
        }
    }
    if (typeof (cardOptIn) != 'undefined' && cardOptIn) {
        //Populate PC field
        USMeta.Utils.addMetaComplete(SetCardOptIn);

        function SetCardOptIn() {
            var form = USMetaRuntime.currentPage.forms[0];

            if (typeof form.root._FUDField22 != 'undefined') {
                form.root._FUDField22.update({ Value: cardOptIn });
            }
        }
    }
    if (typeof (consentWAGE) != 'undefined' && consentWAGE) {
        //Populate PC field
        USMeta.Utils.addMetaComplete(SetConsentWAGE);

        function SetConsentWAGE() {
            var form = USMetaRuntime.currentPage.forms[0];

            if (typeof form.root._FUDField21 != 'undefined') {
                form.root._FUDField21.update({ Value: consentWAGE });
            }
        }
    }
})