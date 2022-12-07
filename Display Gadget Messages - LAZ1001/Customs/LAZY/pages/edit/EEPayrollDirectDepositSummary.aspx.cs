using System;
using System.Collections;
using System.Configuration;
using System.Data;
using System.Web;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.Security;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using UltimateSoftware.Common;
using UltimateSoftware.Data;
using UltimateSoftware.EntityManager;
using UltimateSoftware.ObjectModel.Base;
using UltimateSoftware.ObjectModel.Common;
using UltimateSoftware.ObjectModel.Facade;
using UltimateSoftware.ObjectModel.Objects;
using UltimateSoftware.WebControls;
using UltimateSoftware.WebObjects;
using UltimateSoftware.DataAccessLayer;
using UltimateSoftware.Queries.DynamicSQL;
using System.Xml;

/// <Header summary>
///Company:		  Ultimate Software Corp. 
///Author:		  Adrian Serrano
///Client:		  Lazy Dog Restaurants, LLC
///Date:		  12/3/2019
///Request:		  SR-2019-00245269
///Purpose:		  Instant Pay Direct Deposit (from scope project SR-2019-00233967)
///Last Modified: 

/// </Header summary>


public partial class EePayrollDirectDepositSummary_aspx : USPage
{
    /* --------------------- CUSTOMS BEGIN - AdrianSerrano (SR-2019-00245269) ---------------------*/
    protected bool IsDebitCard = false;
    protected bool IsPendHireDCConsentWage = false;
    /* --------------------- CUSTOMS END - AdrianSerrano (SR-2019-00245269) ---------------------*/

    protected void Page_PreInit()
	{
        Master.UseLatestJquery = true;
		uc_eePayrollDirectDepositSummary.SetupObjectDataSource();
	}

	protected override void OnSave(ToolBarEventArgs tbea)
	{
		USGridView grvEEDirectDeposit = (USGridView)uc_eePayrollDirectDepositSummary.FindControl("grvEEDirectDeposit");
	    try
	    {
	        uc_eePayrollDirectDepositSummary.LogDeletedDirectDeposits();
	    }
	    finally
	    {
	        grvEEDirectDeposit.DeleteItems();
	    }
	}

	protected override void OnDelete(ToolBarEventArgs tbea)
	{
		USGridView grvEEDirectDeposit = (USGridView)uc_eePayrollDirectDepositSummary.FindControl("grvEEDirectDeposit");
	    try
	    {
	        uc_eePayrollDirectDepositSummary.LogDeletedDirectDeposits();
	    }
	    finally
	    {
	        grvEEDirectDeposit.DeleteItems();
	    }
	}
    
	protected void Page_Load(object sender, EventArgs e)
	{
		// This method takes time to update. We need immediate access to a possible
		// changed value so adhoc query it.
		//string CmmSuppressAllDDAs = Master.Info.Companys.Current.CompmastData.SuppressAllDDAs;
		DataCommand dc = null;
		dc = new DataCommand();
		dc.ConnectionInfo = Master.ConnectionInfo;
		string ddaSql = "SELECT CmmSuppressALLDDAs FROM compmast WITH (NOLOCK) WHERE CmmCoID = @COID";
		dc.SQL = ddaSql;
		dc.SqlParameters.Add("@COID", SqlDbType.VarChar, 5, Master.Info.Companys.Current.MasterCoid);
		string CmmSuppressAllDDAs = (string)dc.ExecuteScalar();
		dc.Close();

		string EeSuppressAllDDAs = string.Empty;
		bool doShowDDALinkage = false;

        if (CmmSuppressAllDDAs.Equals("N", StringComparison.OrdinalIgnoreCase))
		{
            doShowDDALinkage = true;
			dc = new DataCommand();
			dc.ConnectionInfo = Master.ConnectionInfo;
			string sql = "SELECT EepSuppressDDA FROM emppers WITH (NOLOCK) WHERE eepeeid = @EEID";
			dc.SQL = sql;
			dc.SqlParameters.Add("@EEID", SqlDbType.VarChar, 12, Master.EEID);
			EeSuppressAllDDAs = (string)dc.ExecuteScalar();
			dc.Close();
		}


		if (doShowDDALinkage)
		{
			this.lblPayStatementPreference.Visible = true;
			this.clDDAPreference.Visible = true;

			//Y = electronic only, no paper
			//N = paper and electronic
			if (EeSuppressAllDDAs.Equals("Y", StringComparison.OrdinalIgnoreCase))
			{
				((USClientLink)this.clDDAPreference).Text = Master.GetString("ElectronicOnly");
			}
			else
			{
				((USClientLink)this.clDDAPreference).Text = Master.GetString("PaperAndElectronicCopy");
			}

            ((USClientLink)this.clDDAPreference).Params = GetClientLinkParams();
		}
		else
		{
			this.lblPayStatementPreference.Visible = false;
			this.clDDAPreference.Visible = false;

			//////////////////////////////////////////////////////////////////////////
			// this hides things I can do. Should be revised as this is easily broken 
			// and will ONLY apply to THIS page, not the tabset (as it should).

			//PageAction.ActionID = 
			// (int)RBSActions.ESS_Myself_Pay_DirectDeposit_ChangePayStatementPreference;
			//PageAction.IsHidden = true;
			//////////////////////////////////////////////////////////////////////////
		}
		//literals to pass to Javascript
		// NOTE: no longer using as we now query on the lightbox page
		// so that the data is most recent, and available across ALL pages in tabset
		//litCurrentDDAPreference.Text = EeSuppressAllDDAs;
		//litCurrentDDAPreferenceCompMast.Text = CmmSuppressAllDDAs;

		HijackDeleteButton();
        /* --------------------- CUSTOMS BEGIN - AdrianSerrano (SR-2019-00245269) ---------------------*/
        UltimateSoftware.ObjectModel.Objects.Employee employee = null;
        IsDebitCard = GetEmployeeDebitCardUsage();

        if (Master.IsWizard && (Master.ProcessParams.Find("IsPendhireWizard") != null) && Boolean.Parse(Master.ProcessParams["IsPendhireWizard"].Value))
        {
            EmployeeList objEmployeeList = Master.DataList[0].Data as EmployeeList;
            employee = objEmployeeList.FindByObjectID(Master.ProcessParams["ObjectIDEmployee"].Value) as UltimateSoftware.ObjectModel.Objects.Employee;

            IsPendHireDCConsentWage = GetPendHireDCConsentWage(employee);
        }
        if (IsDebitCard || IsPendHireDCConsentWage)
        {
            divInformation.Style.Clear(); 
            liMessage.Text = GetEnrollmentMessage();
        }
        /* --------------------- CUSTOMS END - AdrianSerrano (SR-2019-00245269) ---------------------*/
    }

    protected string GetClientLinkParams()
    {
        USClientLinkParams usclp = new USClientLinkParams();
        usclp["ROLE"] = Master.Parameters["Role"];//roleSelector1.SelectedRoleCode.ToString();
        return usclp.ToString();
    }

	private void HijackDeleteButton()
	{
		Master.ToolbarButtons.Delete.Attributes.Add("style", "background-image:url('" + VirtualPathUtility.ToAbsolute("~/images/btnArchive.png") + "')");
		PMHelper.ChangeTextOnButton(Master, "btnDelete", "Archive");
	}

	private void ArchiveDirDp(object sender, ImageClickEventArgs e)
    {
        try
        {
            uc_eePayrollDirectDepositSummary.LogDeletedDirectDeposits();
        }
        finally
        {
            uc_eePayrollDirectDepositSummary.ArchiveItems();
            Master.Transfer("EePayrollDirectDepositSummary.aspx", TransferType.Delete);
        }
    }
    /* --------------------- CUSTOMS BEGIN - AdrianSerrano (SR-2019-00245269) ---------------------*/
    protected string GetEnrollmentMessage()
    {
        string message = "";
        new CompanyDataAccessControl(Master.UserContext).CallStoredProcedure("U_LAZ1001_GetCurrentEnrollmentMessage"
            , null
            , reader =>
            {
                while (reader.Read())
                {
                    message = reader["cnttext"].ToString().Trim();
                    break;
                }
            });
        return message;
    }

    protected bool GetEmployeeDebitCardUsage()
    {
        string UDField21 = new CompanyDataAccessControl(Master.UserContext).CallDynamicSqlScalar<string>(new SqlQuery
        {
            Select = "eecUDField21",
            From = "EmpComp",
            Where = new Field("eecEEID").Equals(Master.EEID).And(new Field("eecCOID").Equals(Master.COID))
        });

        return !String.IsNullOrEmpty(UDField21) && UDField21.Trim().Equals("Y");
    }

    private bool GetPendHireDCConsentWage(UltimateSoftware.ObjectModel.Objects.Employee employee)
    {
        XmlDocument supplXMLData = new XmlDocument();
        new CompanyDataAccessControl(Master.UserContext).CallDynamicSql(new SqlQuery
        {
            Select = "phSupplDataXML",
            From = "PendHire",
            Where = new Field("phPendingSessionID").Equals(employee.PendingHireSessionID)
        }, reader =>
        {
            while (reader.Read())
            {
                supplXMLData.LoadXml(reader[0].ToString());
            }
        });

        return supplXMLData.SelectSingleNode("//Supplemental/UserDefinedFieldsInfo/UdfInfo[FieldName='DC Consent WAGE']/Value/text()").Value.Equals("Y");
    }
    /* --------------------- CUSTOMS END - AdrianSerrano (SR-2019-00245269) ---------------------*/

}
