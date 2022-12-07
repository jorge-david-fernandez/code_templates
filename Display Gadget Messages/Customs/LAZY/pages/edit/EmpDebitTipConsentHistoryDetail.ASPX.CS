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

public partial class Customs_LAZ1001_Pages_Edit_EmpDebitTipConsentHistoryDetail_aspx : USPage
{
    string strSystemID = string.Empty;
    int intStystemID = 0;

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
        strSystemID = string.IsNullOrEmpty(Master.Parameters["udaRecID"]) ? string.Empty : Master.Parameters["udaRecID"];

        if (!Int32.TryParse(strSystemID, out intStystemID))
        {
            intStystemID = 0;
        }

        dsDebitTipConsentHistory.SQL = "dbo.U_LAZ1001_GetDebitTipConsentHistoryDetails @EEID, @COID, @RecId";
        dsDebitTipConsentHistory.SqlParameters.Add("@EEID", SqlDbType.VarChar, Master.EEID);
        dsDebitTipConsentHistory.SqlParameters.Add("@COID", SqlDbType.VarChar, Master.COID);
        dsDebitTipConsentHistory.SqlParameters.Add("@RecId", SqlDbType.Int, intStystemID);

        Master.PageMode += PageModeType.Prev;
        Master.PageMode += PageModeType.Download;
        Master.PageHeader = "Pay Consent History Detail";
        Master.ToolbarButtons.Prev.NavigateUrl = "Customs/" + Master.UserContext.ClientID + "/pages/edit/EmpDebitTipConsentHistorySummary.ASPX";
    }
    protected string GetEditParams()
    {
        USClientLinkParams param = new USClientLinkParams();
        param["DateSigned"] = Eval("DateSigned").ToString();
        return param.ToString();
    }
}

