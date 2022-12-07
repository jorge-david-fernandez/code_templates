/// <Header summary>
///Company:		  Ultimate Software Corp. 
///Author:		  Adrian Serrano
///Client:		  Lazy Dog Restaurants, LLC
///Date:		  1/28/2020
///Request:		  SR-2019-00245269
///Purpose:		  Instant Pay Direct Deposit (from scope project SR-2019-00233967)
///Last Modified: 

/// </Header summary>

$(function () {


    if (HideDebitCard.toLowerCase() == 'false') {
        $("tr[id$='DebitCardRow']").hide();
        $("select[name$='csDebitCard']").prop('required', false);
    }

    function getConsentType(id) {
        if (id.indexOf("csDebitCard") != -1) {
            return "Debit";
        }
        else if (id.indexOf("csMealWaiver1") != -1) {
            return "MealWaiver1";
        }
        else if (id.indexOf("csMealWaiver2") != -1) {
            return "MealWaiver2";
        }
        else {
            return "Tip";
        }
    }


    $("select[name$='csDebitCard'], select[name$='csTipCard'], select[name$='csMealWaiver1'], select[name$='csMealWaiver2']").change(function (
        e
    ) {
        if ($(e.target).val() != "") {
            var consentType = getConsentType(e.target.id);
            if ($(e.target).val() == "Y" || $(e.target).val() == "N") {
                showPopup(consentType, $(e.target).val());
            }
        }
    });

    GlobalVars.hidePopWinCallBack = function () {
        fBaseRestore();
    };

    function showPopup(consentType, consentAnswer) {
        initPopUp();
        postOrNot(false);
        showPopWin(
            "Customs/" +
            compCode +
            "/pages/edit/DebitTipConsentPopUp.aspx" +
            buildQueryString({ 'Source':'CustomAdd', 'ConsentType':consentType, 'ConsentAnswer':consentAnswer }),
            1000,
            600
        );
        return false;
    };
});
