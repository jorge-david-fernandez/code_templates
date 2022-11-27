function AddCustomControls() {

 var url = "eeEEOChg.aspx?USParams=" + $("#ctl00_Content__USPARAMS").val();

 $.ajax({

 url: url,

 success: function (data) {

  

 var divCustom = $(data).find('div[id$=divCustomField]');

 var divServiceCode = divCustom.find("div[id$='divServiceCode']");

  

 $("[id$=lblOrglvl3]")

 .closest("div.legacy-control.control-group")

 .after(divServiceCode);

  

 },

 async: false

 });

}

  

$(document).ready(function () {

 USMeta.Utils.addMetaComplete(AddCustomControls);

});