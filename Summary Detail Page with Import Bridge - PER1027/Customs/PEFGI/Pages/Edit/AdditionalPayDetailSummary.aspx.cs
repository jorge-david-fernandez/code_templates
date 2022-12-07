/// <Header summary>
///Company:		  UKG
///Author:		  Jorge Fernandez
///Client:		  Performance Food Group, Inc.
///Date:		  11/2/2022
///Request:		  SR-2022-00377312
///Purpose:		  Custom Web Page for Additional Pay Detail
///Last Modified: 

/// </Header summary>

using System;
using System.Web.UI.WebControls;
using UltimateSoftware.WebControls;
using UltimateSoftware.Diagnostics.Common;
using UltimateSoftware.Data;
using UltimateSoftware.Common;
using System.Text;
using System.Data;
using UltimateSoftware.DataAccessLayer;

public partial class Customs_PER1027_Pages_AdditionalPayDetailSummary : USPage
{
    string strFinSysSelected = String.Empty;
    string strOrgLvlSelected = String.Empty;

    public bool IsFinSysActive = false;

    protected String GetEditParams()
    {
        USClientLinkParams param = new USClientLinkParams();
        param.Add("PayDate", Eval("uapPayDate").ToString());
        return param.ToString();
    }

    protected override void OnFinish(ToolBarEventArgs tbea)
    {
        MasterPage.Parameters.Remove("PK");
        MasterPage.Parameters.Add("PK", "CORE");
        Response.Redirect(string.Format("{0}?{1}", "~/pages/EDIT/BridgeUpload.aspx", USParams.MakeUSParamsQueryString(Master.Parameters)));
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        Master.PageHeader = Master.GetString("U_AddlPay_AdditionalPaySummaryHeader");
        Master.ToolbarButtons.Help.Visible = false;

        Master.PageMode += PageModeType.Finish;

        // Upload tool bar
        Master.ToolbarButtons.Finish.PageButton.ImageUrl = "~/images/ButtonDownload.png";
        Master.ToolbarButtons.Finish.ToolbarLabel = "upload";
        Master.ToolbarButtons.Finish.Visible = Master.ProductKey.Equals("EEADM");

        USGridDataSource1.SqlParameters.Add("@EEID", Master.EEID);
        USGridDataSource1.SqlParameters.Add("@COID", Master.COID);
    }
}