///<Header Summary>
/// Initial Author:		William Bissett(WB)
/// Client        :		MasTec North America, Inc.(MAS1016)
/// Date          :		7/12/2021
/// File Name     :		
/// Purpose       :		SR-2021-00312637 - MAS-C08- Process to update values in a Simple Business rule
///
///</Header Summary>

$(function () {
    USMeta.Utils.addMetaComplete(MetaApplyCustom);
});

function MetaApplyCustom() {
    AddCustomControls();

    LoadCustomControls();

    SetupOnChangeFunctions("_BmasReferredBy1", "supReferredBy1");
    SetupOnChangeFunctions("_BmasReferredBy2", "supReferredBy2");
    SetupOnChangeFunctions("_BmasTimeCardApprover", "supTimeCardApprover");
    SetupOnChangeFunctions("_BmasTimeCardApproverGRE", "supGREApprover");
    SetupOnChangeFunctions("_BvstSponsor", "supSponsor");

    if (isPendHire && !IsVisited) {
        var EEID;
        var Name;

        EEID = GetCodeSelector("supSupervisor").val();
        Name = GetCodeSelector("supSupervisor").$control.val();

        GetCodeSelector("supTimeCardApprover").$control.val(Name);
        $('input[id$=supTimeCardApprover]:hidden').val(EEID).change();

        GetCodeSelector("supGREApprover").$control.val(Name);
        $('input[id$=supGREApprover]:hidden').val(EEID).change();
    }

    GetCodeSelector("supSupervisor").$control.change(function () {
        var EEID;
        var Name;

        EEID = GetCodeSelector("supSupervisor").val();
        Name = GetCodeSelector("supSupervisor").$control.val();
        
        GetCodeSelector("supTimeCardApprover").$control.val(Name);
        $('input[id$=supTimeCardApprover]:hidden').val(EEID).change();

        GetCodeSelector("supGREApprover").$control.val(Name);
        $('input[id$=supGREApprover]:hidden').val(EEID).change();
    });
}

function AddCustomControls() {
    var usParams = $("#ctl00_Content__USPARAMS").val();
    var url = "../../Customs/MTNA/pages/edit/PCSuperFinders.aspx";
    $.ajax({
        url: url + "?USParams=" + usParams,
        async: false,
    })
    .done(function (html) {
        $('div[data-bind*="_BmasReferredBy1"] > div').hide();
        $('div[data-bind*="_BmasReferredBy1"]').append($(html).find('span[id$=supReferredBy1]'));
        $('div[data-bind*="_BmasReferredBy2"] > div').hide();
        $('div[data-bind*="_BmasReferredBy2"]').append($(html).find('span[id$=supReferredBy2]'));
        $('div[data-bind*="_BmasTimeCardApprover"] > div').hide();
        $('div[data-bind*="_BmasTimeCardApprover,"]').append($(html).find('span[id$=supTimeCardApprover]'));
        $('div[data-bind*="_BmasTimeCardApproverGRE"] > div').hide();
        $('div[data-bind*="_BmasTimeCardApproverGRE"]').append($(html).find('span[id$=supGREApprover]'));
        $('div[data-bind*="_BvstSponsor"] > div').hide();
        $('div[data-bind*="_BvstSponsor"]').append($(html).find('span[id$=supSponsor]'));

    })
    .fail(function (err) {
        console.log(err);
    });
}

function LoadCustomControls() {
    var Request = {
        ReferredBy1: typeof (USMetaRuntime.currentPage.forms[0].root["_BmasReferredBy1"]) == "undefined" ? "" : USMetaRuntime.currentPage.forms[0].root["_BmasReferredBy1"].value(),
        ReferredBy2: typeof (USMetaRuntime.currentPage.forms[0].root["_BmasReferredBy2"]) == "undefined" ? "" : USMetaRuntime.currentPage.forms[0].root["_BmasReferredBy2"].value(),
        TimeCardApprover: typeof (USMetaRuntime.currentPage.forms[0].root["_BmasTimeCardApprover"]) == "undefined" ? "" : USMetaRuntime.currentPage.forms[0].root["_BmasTimeCardApprover"].value(),
        GREApprover: typeof (USMetaRuntime.currentPage.forms[0].root["_BmasTimeCardApproverGRE"]) == "undefined" ? "" : USMetaRuntime.currentPage.forms[0].root["_BmasTimeCardApproverGRE"].value(),
        Sponsor: typeof (USMetaRuntime.currentPage.forms[0].root["_BvstSponsor"]) == "undefined" ? "" : USMetaRuntime.currentPage.forms[0].root["_BvstSponsor"].value()
    };

    $.ajax({
        type: "POST",
        data: JSON.stringify(Request),
        url: "/services/MTNA_EmpNoLookup.asmx/LookupPCFieldSuperfinderValues",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        async: false,
        success: function (data, textStatus, XMLHttpRequest) {
            if (data.d) {
                if (typeof (data.d.ReferredBy1) != "undefined") {
                    GetCodeSelector("supReferredBy1").$control.val(data.d.ReferredBy1.EmpName);
                    $('input[id$=supReferredBy1]:hidden').val(data.d.ReferredBy1.EEID);
                }
                if (typeof (data.d.ReferredBy2) != "undefined") {
                    GetCodeSelector("supReferredBy2").$control.val(data.d.ReferredBy2.EmpName);
                    $('input[id$=supReferredBy2]:hidden').val(data.d.ReferredBy2.EEID);
                }
                if (typeof (data.d.TimeCardApprover) != "undefined") {
                    GetCodeSelector("supTimeCardApprover").$control.val(data.d.TimeCardApprover.EmpName);
                    $('input[id$=supTimeCardApprover]:hidden').val(data.d.TimeCardApprover.EEID);
                }
                if (typeof (data.d.GREApprover) != "undefined") {
                    GetCodeSelector("supGREApprover").$control.val(data.d.GREApprover.EmpName);
                    $('input[id$=supGREApprover]:hidden').val(data.d.GREApprover.EEID);
                }
                if (typeof (data.d.Sponsor) != "undefined") {
                    GetCodeSelector("supSponsor").$control.val(data.d.Sponsor.EmpName);
                    $('input[id$=supSponsor]:hidden').val(data.d.Sponsor.EEID);
                }
            }
        },
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            log.displayNow('There was an error with a web service call.', null, null, null, Log.ERR, null, true);
        }
    });
}

function SetupOnChangeFunctions(PCName, superfinder) {
    $('input[id$=' + superfinder + ']:hidden').on("change", function (event) {
        var EmpNo = "";

        var Request = {
            EEID: $('input[id$=' + superfinder + ']:hidden').val()
        };

        if (Request.EEID != "") {
            $.ajax({
                type: "POST",
                data: JSON.stringify(Request),
                url: "/services/MTNA_EmpNoLookup.asmx/LookupEmpNoByEEID",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: false,
                success: function (data, textStatus, XMLHttpRequest) {
                    if (data.d) EmpNo = data.d;
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    log.displayNow('There was an error with a web service call.', null, null, null, Log.ERR, null, true);
                }
            });
        }
        
        USMetaRuntime.currentPage.forms[0].root[PCName].update({ Value: EmpNo });
    });

    $('span[id$=' + superfinder + ']').children('input[type=image]').click(function (event) {
        USMetaRuntime.currentPage.forms[0].root[PCName].update({ Value: "" });
    });
}