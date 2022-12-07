/// <Header summary>
///Company:		  Ultimate Software Corp. 
///Author:		  Adrian Serrano
///Client:		  Lazy Dog Restaurants, LLC
///Date:		  1/28/2020
///Request:		  SR-2019-00245269
///Purpose:		  Instant Pay Direct Deposit (from scope project SR-2019-00233967)
///Last Modified: 

/// </Header summary>
            

$(function() {

  addEvent(window, "load", SetToolBarButtons);

  function SetToolBarButtons() {
    var callingWindow = findMainFrame(windowTop());
    saveBtn = document.getElementById("ctl00_btnSave");
    addEvent(saveBtn, "click", SaveConsent);
    cancelBtn = document.getElementById("ctl00_btnCancel");
    addEvent(cancelBtn, "click", cancel);
  }

  function cancel() {
      findMainFrame(windowTop()).hidePopWinWithCallBack();
      return false;
  }

  function SaveConsent() {

      var eeid = getEEID();
      var coid = getCOID();
      var debitTip = getDebitTip();
      var consentAnswer = getConsentAnswer();
      var data;
      if (eeid === undefined) {
          data = JSON.stringify({
              EEID: '',
              COID: '',
              consentType: CONSENT_TYPE,
              debitTip: debitTip,
              consentAnswer: consentAnswer,
              initials: $("input[id$=txtInitials]").val()
          })
      }
      else {
          data = JSON.stringify({
              EEID: eeid,
              COID: coid,
              consentType: CONSENT_TYPE,
              debitTip: debitTip,
              consentAnswer: consentAnswer,
              initials: $("input[id$=txtInitials]").val()
          })
      }

    var initialsCtrl = $("input[id$=txtInitials]");
    var agreeChkCtrl = $("[id$=chkAgree]");
    initialsCtrl.prop("class", "");
    agreeChkCtrl.prop("class", "");

    log.clearErrorsByControl("FillOutConsent");
    if (initialsCtrl.val() !== "" && agreeChkCtrl.is(":checked")) {
      $.ajax({
        type: "POST",
        url: "DebitTipConsentPopUp.aspx/SaveConsent",
        data: data,
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        async: false,
        cache: false,
        success: function(msg) {
          if (
            document
              .getElementById("aspnetForm")
              .getAttribute("action")
              .indexOf("originatingurl") > 0
          ) {
              callingWindow.location.reload(true);
              callingWindow.hidePopWin();
          }
          return true;
        }
      });

      findMainFrame(windowTop()).hidePopWin();
    } else {
      postOrNot(false);
      log.displayNow(
        "Please agree to the consent and sign with your initials.",
        "FillOutConsent",
        null,
        null,
        Log.ERR,
        null,
        true
      );

      if (initialsCtrl.val() === "") {
        initialsCtrl.prop("class", "requiredSelect");
      }
      if (!agreeChkCtrl.is(":checked")) {
        agreeChkCtrl.prop("class", "requiredFieldError");
      }
      return false;
    }
  }


  function getDebitTip() {
      var QueryString = getQueryString();
      USParams = getUSParams(QueryString);
      return USParams.consenttype;
  }

  function getConsentAnswer() {
      var QueryString = getQueryString();
      USParams = getUSParams(QueryString);
      return USParams.consentanswer;
  }

  function getEEID() {
      var QueryString = getQueryString();
      USParams = getUSParams(QueryString);
      return USParams.eeid;
  }

  function getCOID() {
      var QueryString = getQueryString();
      USParams = getUSParams(QueryString);
      return USParams.coid;
  }

  function getQueryString() {
      var qs = {},
        e,
        d = function (s) { return decodeURIComponent(s.replace(/\+/g, " ")); },
        q = window.location.search.substring(1),
        r = /([^&=]+)=?([^&]*)/g;
      while (e = r.exec(q)) {
          qs[d(e[1])] = d(e[2]);
      }
      return qs;
  }

  function getUSParams(qs) {
      var us = {},
        e,
        d = function (s) { return decodeURIComponent(s.replace(/\+/g, " ")); },
        q = qs.USParams,
        r = /([^!=]+)=?([^!]*)/g;
      while (e = r.exec(q)) {
          us[d(e[1]).toLowerCase()] = d(e[2]);
      }
      return us;
  }

});
