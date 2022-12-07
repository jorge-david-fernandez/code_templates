using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Collections;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using UltimateSoftware.Common;
using UltimateSoftware.ObjectModel.Objects;
using UltimateSoftware.ObjectModel.Facade;
using UltimateSoftware.EntityManager;
using UltimateSoftware.WebControls;
using UltimateSoftware.WebObjects;
using System.Text;
using UltimateSoftware.DataAccessLayer;
using System.Xml;
using UltimateSoftware.Queries.DynamicSQL;

/// <Header summary>
///Company:		  Ultimate Software Corp. 
///Author:		  Adrian Serrano
///Client:		  Lazy Dog Restaurants, LLC
///Date:		  12/3/2019
///Request:		  SR-2019-00245269
///Purpose:		  Instant Pay Direct Deposit (from scope project SR-2019-00233967)
///Last Modified: 

/// </Header summary>
/// 
public partial class EePayrollDirectDepositSummaryWiz_aspx : USPage
{
    /* --------------------- CUSTOMS BEGIN - AdrianSerrano (SR-2019-00245269) ---------------------*/
    protected bool IsDebitCard = false;
    protected bool IsPendHireDCConsentWage = false;
    /* --------------------- CUSTOMS END - AdrianSerrano (SR-2019-00245269) ---------------------*/

    protected void Page_Init(object sender, EventArgs e)
    {
        this.PendoEnabled = true;
    }

    protected void Page_Load()
    {
        uc_eePayrollDirectDepositSummary.SetupObjectDataSource();
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

    protected override void OnAdd(ToolBarEventArgs tbea)
    {
        Master.AddParameter("IsWizard", "true");
        Master.Parameters.Remove("ObjectID");
        Master.GoToSubProcess("DirectDeposit");
    }

    protected override void OnSave(ToolBarEventArgs tbea)
    {
        USGridView grvEEDirectDeposit = (USGridView)uc_eePayrollDirectDepositSummary.FindControl("grvEEDirectDeposit");
        grvEEDirectDeposit.DeleteItems();
    }

    protected override void OnDelete(ToolBarEventArgs tbea)
    {
        USGridView grvEEDirectDeposit = (USGridView)uc_eePayrollDirectDepositSummary.FindControl("grvEEDirectDeposit");
        grvEEDirectDeposit.DeleteItems();
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

        XmlNode consentWAGENode = supplXMLData.SelectSingleNode("//Supplemental/UserDefinedFieldsInfo/UdfInfo[FieldName='DC Consent WAGE']");
        if (consentWAGENode != null)
        {
            XmlNode consentWAGE = consentWAGENode.SelectSingleNode("Value");
            if (consentWAGE != null && !string.IsNullOrEmpty(consentWAGE.InnerText))
            {
                return consentWAGE.InnerText.Equals("Y");
            }
        }
        return false;
    }
    /* --------------------- CUSTOMS END - AdrianSerrano (SR-2019-00245269) ---------------------*/

}