/// <Header summary>
///Company:		  UKG
///Author:		  Jorge David Fernandez
///Client:		  Sony Pictures Entertainment Inc.
///Date:		  3/5/2021
///Request:		  SR-2021-00303642
///Purpose:		  Web Admin for BI Reporting Security Matrix Custom Screen and Tables
///Last Modified: 

/// </Header summary>


#region Using directives
using System;
using System.Web.UI.WebControls;
using UltimateSoftware.WebControls;
using UltimateSoftware.Data;
using UltimateSoftware.Common;
using System.Text;
using System.Data.SqlClient;
using System.Collections.Generic;
using System.Text.RegularExpressions;

using System.Data;
using UltimateSoftware.Queries.DynamicSQL;
using UltimateSoftware.DataAccessLayer;
using System.Web.UI.HtmlControls;
using System.Linq;
using System.Collections;
using System.Web.UI;
using UltimateSoftware.Diagnostics.Common;
using System.Collections.Specialized;
#endregion

#region Custom Using directives
#endregion

public partial class BIReportSecurityMatrixDetail_aspx : USPage
{
    private const string PAGEMODE_Edit = "Edit";
    private const string PAGEMODE_Add = "Add";
    protected string SummaryPageFileName = "BIReportSecurityMatrixSummary.aspx";

    protected void Page_Load(object sender, EventArgs e)
    {
        Master.PageHeader = Master.GetString("L_SON1003_BIReportSecurityMatrixDetail");
        Master.ToolbarButtons.Help.Visible = false;
        Master.WriteScriptInclude("validate");    //RJ Note: this line allows the initForm javascript function to work, to hook html fields up with ustyle event handlers.

        if (!IsPostBack)
        {
            switch (Master.Parameters["Mode"])
            {
                case PAGEMODE_Edit:
                    PageMode.Value = PAGEMODE_Edit;
                    LoadRecordBeingEdited();
                    break;
                case PAGEMODE_Add:
                    PageMode.Value = PAGEMODE_Add;
                    break;
            }
        }
    }

    protected void Page_PreRender(object sender, EventArgs e)
    {
        if (PageMode.Value == PAGEMODE_Edit || PageMode.Value == PAGEMODE_Add)
        {
            Master.PageMode += PageModeType.Editable;
        }

        SetupCustomUSSuperFinder();
        SetupCompanyFinder();
        SetupOrgLvl1Finder();
        SetupOrgLvl3Finder();
    }

    private void SetupCustomUSSuperFinder()
    {
        ((USCustomFinder)fndrUSSuperFinder).PagePath = "/Customs/" + Master.UserContext.ClientID + "/pages/utility/CustomUSSuperFinder.aspx";
        NameValueCollection Parameters = new NameValueCollection
        {
            { "EEID", Master.UserContext.EEID },
            { "COID", Master.UserContext.COID },
            { "role", Master.UserContext.Role },
            { "includeTerm", "false" },
            { "includeOnlyWebUsers", "true" },
            { "PK", Master.ProductKey.ToString().ToUpper() },
        };
        ((USCustomFinder)fndrUSSuperFinder).Parameters = Parameters;
    }

    private void SetupCompanyFinder()
    {
        ((USCustomFinder)fndrCompany).PagePath = "/Customs/" + Master.UserContext.ClientID + "/pages/utility/CompanyFinder.aspx";
        NameValueCollection Parameters = new NameValueCollection
        {
            { "EEID", Master.UserContext.EEID },
            { "COID", Master.UserContext.COID },
            { "role", Master.UserContext.Role },
            { "PK", Master.ProductKey.ToString().ToUpper() },
        };
        ((USCustomFinder)fndrCompany).Parameters = Parameters;
    }

    private void SetupOrgLvl1Finder()
    {
        ((USCustomFinder)fndrOrgLvl1).PagePath = "/Customs/" + Master.UserContext.ClientID + "/pages/utility/OrgLevel1Finder.aspx";
        NameValueCollection Parameters = new NameValueCollection
        {
            { "EEID", Master.UserContext.EEID },
            { "COID", Master.UserContext.COID },
            { "role", Master.UserContext.Role },
            { "PK", Master.ProductKey.ToString().ToUpper() },
        };
        ((USCustomFinder)fndrOrgLvl1).Parameters = Parameters;
    }

    private void SetupOrgLvl3Finder()
    {
        ((USCustomFinder)fndrOrgLvl3).PagePath = "/Customs/" + Master.UserContext.ClientID + "/pages/utility/OrgLevel3Finder.aspx";
        NameValueCollection Parameters = new NameValueCollection
        {
            { "EEID", Master.UserContext.EEID },
            { "COID", Master.UserContext.COID },
            { "role", Master.UserContext.Role },
            { "PK", Master.ProductKey.ToString().ToUpper() },
        };
        ((USCustomFinder)fndrOrgLvl3).Parameters = Parameters;
    }

    protected void LoadRecordBeingEdited()
    {
        new CompanyDataAccessControl(Master.UserContext).CallStoredProcedure("U_SON1003_GetBIReportSecurityMatrix", new object[] { Master.Parameters["RecID"] }, reader =>
         {
             while (reader.Read())
             {
                 csReportName.Code = !reader.IsDBNull(0) ? reader["ReportName"].ToString() : String.Empty;
                 calEffectiveStartDate.Value = !reader.IsDBNull(1) ? reader["EffectiveStartDate"].ToString() : String.Empty;
                 //supUserName.EEID = !reader.IsDBNull(2) ? reader["UserName"].ToString() : String.Empty;
                 //supUserName.EmpCOID = !reader.IsDBNull(3) ? reader["ReportCOID"].ToString() : String.Empty;
                 fndrUSSuperFinder.Value = !reader.IsDBNull(5) ? reader["UserName"].ToString() : String.Empty;
                 fndrUSSuperFinder.Description = !reader.IsDBNull(5) ? reader["FullName"].ToString() : String.Empty;
                 fndrCompany.Value = !reader.IsDBNull(5) ? reader["ReportCompany"].ToString() : String.Empty;
                 fndrCompany.Description = !reader.IsDBNull(5) ? Master.GetCodeDesc("COMPANY", reader["ReportCompany"].ToString()).CodeDashDescription : String.Empty;
                 fndrOrgLvl1.Value = !reader.IsDBNull(5) ? reader["SAPCompany"].ToString() : String.Empty;
                 fndrOrgLvl1.Description = !reader.IsDBNull(5) ? Master.GetCodeDesc("ORGLVL1ACTIVE", reader["SAPCompany"].ToString()).CodeDashDescription : String.Empty;
                 fndrOrgLvl3.Value = !reader.IsDBNull(5) ? reader["CostCenter"].ToString() : String.Empty;
                 fndrOrgLvl3.Description = !reader.IsDBNull(5) ? Master.GetCodeDesc("ORGLVL3ACTIVE", reader["CostCenter"].ToString()).CodeDashDescription : String.Empty;
                 calEffectiveStopDate.Value = !reader.IsDBNull(7) ? reader["EffectiveStopDate"].ToString() : String.Empty;
             }
         });
    }
    protected void LogMessage(string msg, ErrorSeverity severity = ErrorSeverity.Error)
    {
        LogEntry log = new LogEntry();
        log.Message = msg;
        Master.AddError(log, severity);
        Master.WriteOutErrors();
    }

    protected bool EntriesAreValid()
    {
        bool isValid = true;

        string validationMessage = new CompanyDataAccessControl(Master.UserContext).CallScalarStoredProcedure<string>("U_SON1003_ValidateBIReportSecurityMatrix",
            new object[] {
                csReportName.Code,
                String.IsNullOrEmpty(calEffectiveStartDate.Value) ? (DateTime?)null :Convert.ToDateTime(calEffectiveStartDate.Value),
                fndrUSSuperFinder.Value,
                fndrCompany.Value,
                fndrOrgLvl1.Value,
                fndrOrgLvl3.Value,
                String.IsNullOrEmpty(calEffectiveStopDate.Value) ? (DateTime?)null : Convert.ToDateTime(calEffectiveStopDate.Value) });

        if (String.IsNullOrEmpty(validationMessage))
        {
            isValid = true;
        }
        else
        {
            isValid = false;
            LogMessage(validationMessage);
        }

        if (!isValid)
        {
            Master.WriteOutErrors();
        }

        return isValid;
    }

    protected bool SaveBIReportSecurity()
    {
        try
        {
            new CompanyDataAccessControl(Master.UserContext).CallNonQueryStoredProcedure("U_SON1003_SaveBIReportSecurity",
                new object[]
                {
                    Master.Parameters["RecID"],
                    csReportName.Code,
                    String.IsNullOrEmpty(calEffectiveStartDate.Value) ? (DateTime?)null : Convert.ToDateTime(calEffectiveStartDate.Value),
                    fndrUSSuperFinder.Value,
                    fndrCompany.Value,
                    fndrOrgLvl1.Value,
                    fndrOrgLvl3.Value,
                    String.IsNullOrEmpty(calEffectiveStopDate.Value) ? (DateTime?)null : Convert.ToDateTime(calEffectiveStopDate.Value)
                });
        }
        catch (Exception ex)
        {
            LogMessage("Error saving: " + ex.Message);
            return false;
        }

        return true;
    }

    protected override void OnCancel(ToolBarEventArgs tbea)
    {
        //Remove edit parameters and Transfer
        Master.Parameters.Remove("Mode");
        Server.Transfer(string.Format("{0}?{1}", SummaryPageFileName, USParams.MakeUSParamsQueryString(Master.Parameters)));
    }

    protected override void OnSave(ToolBarEventArgs tbea)
    {
        if (EntriesAreValid())
        {
            if (SaveBIReportSecurity())
            {
                //Remove edit parameters and Transfer
                Master.Parameters.Remove("Mode");
                Server.Transfer(string.Format("{0}?{1}", SummaryPageFileName, USParams.MakeUSParamsQueryString(Master.Parameters)));
            }
        }
    }
}
