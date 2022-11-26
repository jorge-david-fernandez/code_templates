/// <Header summary>
///Company:		  UKG
///Author:		  Jorge Fernandez
///Client:		  MasTec North America, Inc.
///Date:		  11/17/2022
///Request:		  SR-2022-00368637
///Purpose:		  Platform Configuration Field - Create Custom SuperFinder field
///Last Modified:

/// </Header summary>

$(function () {
  USMeta.Utils.addMetaComplete(MetaApplyCustom);
});

function MetaApplyCustom() {
  $('div[data-bind*="_BvstSponsor"] > div').hide();
  $('div[data-bind*="_BvstSponsor"]').append(
    "<div class='textarea' id='divSponsorName'>"
  );

  $('div[data-bind*="_BmasTimeCardApprover"] > div').hide();
  $('div[data-bind*="_BmasTimeCardApprover"]')
    .filter((idx, ctrl) => {
      return ctrl.outerHTML.includes("root._BmasTimeCardApprover,");
    })
    .append("<div class='textarea' id='divTimeCardApproverName'>");

  var Request = {
    sponsorEmpNo:
      USMetaRuntime.currentPage.forms[0].root["_BvstSponsor"].value(),
    timeCardApproverEmpNo:
      USMetaRuntime.currentPage.forms[0].root["_BmasTimeCardApprover"].value(),
  };

  if (Request.EmpNo != "") {
    $.ajax({
      type: "POST",
      data: JSON.stringify(Request),
      url: "/services/MTNA_EmpNoLookup.asmx/GetEmployeeNameByEmpNo",
      contentType: "application/json; charset=utf-8",
      dataType: "json",
      async: false,
      success: function (data, textStatus, XMLHttpRequest) {
        if (data.d) {
          if (typeof data.d.sponsorName != "undefined") {
            $("div[id$=divSponsorName]").html(data.d.sponsorName);
          }
          if (typeof data.d.timeCardApproverName != "undefined") {
            $("div[id$=divTimeCardApproverName]").html(
              data.d.timeCardApproverName
            );
          }
        }
      },
      error: function (XMLHttpRequest, textStatus, errorThrown) {
        log.displayNow(
          "There was an error with a web service call.",
          null,
          null,
          null,
          Log.ERR,
          null,
          true
        );
      },
    });
  }
}
