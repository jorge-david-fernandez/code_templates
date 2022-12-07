/// <Header summary>
///Company:		  UKG
///Author:		  Stela Garkova
///Client:		  Performance Food Group, Inc.
///Date:		  8/8/2022
///Request:		  SR-2022-00363993
///Purpose:		  Web administrator page for GL custom table for mapping for Org Levels
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
using UltimateSoftware.Queries.DynamicSQL;

public partial class Customs_PER1027_Pages_AdditionalPayDetailDetail : USPage
{
    string strFinSysSelected = String.Empty;
    string strOrgLvlSelected = String.Empty;

    public bool IsFinSysActive = false;

    protected String GetEditParams()
    {
        USClientLinkParams param = new USClientLinkParams();
        param.Add("RecID", Eval("uapRecID").ToString());
        return param.ToString();
    }

    protected override void OnFinish (ToolBarEventArgs tbea)
    {
        MasterPage.Parameters.Remove("PK");
        MasterPage.Parameters.Add("PK", "CORE");
        Response.Redirect (string.Format("{0}?{1}", "~/pages/EDIT/BridgeUpload.aspx", USParams.MakeUSParamsQueryString(Master.Parameters)));
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        
        Master.PageHeader = Master.GetString("U_AddlPay_AdditionaPaySummaryHeader");
        Master.ToolbarButtons.Help.Visible = false;

        Master.PageMode += PageModeType.Create;
        Master.PageMode += PageModeType.Delete;
        Master.PageMode += PageModeType.Prev;
        Master.ToolbarButtons.Prev.NavigateUrl = Page.ResolveUrl("AdditionalPayDetailSummary.aspx");
        Master.ToolbarButtons.Add.Visible = Master.ProductKey.Equals("EEADM");
        Master.ToolbarButtons.Delete.Visible = Master.ProductKey.Equals("EEADM");
        
        colDelete.Visible = Master.ProductKey.Equals("EEADM");

        // Set selected codes for FinSys and OrgLvls
        if (!IsPostBack && Master.Parameters["PayDate"] != null)
        {
            USGridDataSource1.SqlParameters.Add("@PayDate", Master.Parameters["PayDate"]);
        }
    }

    protected override void OnDelete(ToolBarEventArgs tbea)
    {
        if (!string.IsNullOrEmpty(Request.Form["chkDelete"]))
        {
            try
            {
                new CompanyDataAccessControl(Master.UserContext).CallNonQueryStoredProcedure(
                "dbo.U_PER1027_AdditionalPayDetail_Del",
                new object[] { Request.Form["chkDelete"] });
            }
            catch (Exception ex)
            {
                LogEntry log = new LogEntry();
                log.Message = "Error deleting.";//: " + ex.Message;
                Master.AddError(log, ErrorSeverity.Error);
            }
        }
    }

    protected override void OnAdd(ToolBarEventArgs tbea)
    {
        Master.Parameters["RecID"] = string.Empty;
        Server.Transfer(string.Format("../Edit/AddChangeAdditionalPayDetail.aspx?{0}", USParams.MakeUSParamsQueryString(Master.Parameters)));
    }

}
