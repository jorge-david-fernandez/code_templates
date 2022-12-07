/// <Header summary>
///Company:		  Ultimate Software Corp. 
///Author:		  Adrian Serrano
///Client:		  Lazy Dog Restaurants, LLC
///Date:		  1/28/2020
///Request:		  SR-2019-00245269
///Purpose:		  Instant Pay Direct Deposit (from scope project SR-2019-00233967)
///Last Modified: 

/// </Header summary>
            

#region Using directives
using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using UltimateSoftware.WebControls;
#endregion

public partial class Customs_LAZ1001_Pages_Edit_EmpDebitTipConsentHistorySummary_aspx : USPage
{
    protected string DetailURL = String.Empty;
    public string USParams
    {
        get
        {
            string usParams = string.Empty;
            HtmlInputHidden ctrl = (HtmlInputHidden)Page.FindControl("ctl00$Content$_USPARAMS");
            if (ctrl != null)
            {
                usParams = ctrl.Value;
            }
            return usParams;
        }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        MasterPage.Parameters.Remove("udaRecID");  //clear systemid in the query

        DetailURL = "/Customs/" + Master.UserContext.ClientID + "/pages/edit/EmpDebitTipConsentHistoryDetail.aspx";
        Master.PageHeader = "Pay Consent History";
        //set the input parameters for the sql sp here
        gdsDebitTipConsentHistory.SqlParameters.Add("@EEID", DbType.String, Master.EEID);
        gdsDebitTipConsentHistory.SqlParameters.Add("@COID", DbType.String, Master.COID);
        //dsList.SqlParameters.Clear();
        //dsList.SqlParameters.Add("@HideCompletedSessions", this.chkHideCompletedSessions2.Checked.ToString());


    }
    protected string GetEditParams()
    {
        USClientLinkParams param = new USClientLinkParams();
        param["udaRecID"] = Eval("udaRecID").ToString();
        return param.ToString();
    }
}
