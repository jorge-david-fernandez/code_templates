/// <Header summary>
///Company:		  Ultimate Software Corp. 
///Author:		  Jorge David Fernandez
///Client:		  Lazy Dog Restaurants, LLC
///Date:		  10/4/2019
///Request:		  SR-2019-00245269
///Purpose:		  Instant Pay Direct Deposit (from scope project SR-2019-00233967)
///Last Modified: 

/// </Header summary>

using System;
using System.Collections.Generic;
using System.Data;
using System.Collections;
using System.Linq;
using System.Web.UI.WebControls;
using System.Xml;
using UltimateSoftware.DataAccessLayer;
using UltimateSoftware.Diagnostics.Common.Syslog;
using UltimateSoftware.ObjectModel.Objects;
using UltimateSoftware.Queries.DynamicSQL;
using UltimateSoftware.WebControls;
using UltimateSoftware.WebObjects;
using UltimateSoftware.ObjectModel.Facade;

public partial class usercontrols_LAZ1001_eePayrollDirectDepositSummary : USUserControl
{
  const int COL_ACCOUNTNUMBER = 0;
  const int COL_DESCRIPTION = 1;
  const int COL_BANK = 2;
  const int COL_ACCOUNTTYPE = 3;
  const int COL_ROUTINGNUMBER = 4;
  const int COL_BANKINSTNUM = 5;
  const int COL_AMOUNT = 6;
  const int COL_STATUS = 7;

  string sEECoID;
  string sEEEEID;

    // CUSTOM BEGIN - JDF - SR-2019-00245269
    protected bool IsDebitCard = false;
    protected bool IsPendHireDCConsentWage = false;
    // CUSTOM END - JDF - SR-2019-00245269
	
  // Begin PRO-132598 >> HP 4/5/2022 >> Add variable to track index of Account Number column (previously index was hardcoded and errored when column order changed)
  int indexAcctNum = -1;
  // End PRO-132598 >> HP 4/5/2022	

  public ProcessTemplate Master
  {
    get { return (ProcessTemplate)this.Page.Master; }
  }

  public string GetCountry()
  {
    string CountryCode = Master.Country;
    if (!string.IsNullOrEmpty(Master.OperatingCountry))
      CountryCode = Master.OperatingCountry;

    return CountryCode;
  }

  public void SetupObjectDataSource()
  {
    if (Master.IsWizard)
    {
        if (Master.PageName.ToLower() == "hiredirectdeposit.aspx")
        {
            Master.ProcessName = "HireProcess";
            odsPayrollDirectDepositSummary.ParentObjectName = "UltimateSoftware.WebObjects.EmployeeHireRecordDataItem";
        }
        else
        {
            Master.ProcessName = "NewHireWizard";
            odsPayrollDirectDepositSummary.ParentObjectName =  "UltimateSoftware.WebObjects.EmployeeDataItem";
        }
        odsPayrollDirectDepositSummary.ParentPropertyName = "DirectDeposits";
    }
    else
    {
      Master.ProcessName = "eePayrollDirectDeposit";
    }
  }

  void Page_Load(object sender, EventArgs e)
  {
      // ULTI-84152
      // Make btnDoNothing.Visible = false so that when tabbing to and pressing Enter/Space on the column headers on the Direct Deposit and PTO grid, columns do sort
      Button btnDoNothing = Master.FindControl("btnDoNothing") as Button;
      btnDoNothing.Visible = false;
    sEECoID = (!Master.ProcessParams.IsPopulated("EECoID")) ? Master.COID : Master.ProcessParams["EECoID"].Value;
    sEEEEID = Master.IsWizard ? ((!Master.ProcessParams.IsPopulated("EEEEID")) ? string.Empty : Master.ProcessParams["EEEEID"].Value) : Master.EEID;


      USTemplateField ustfAcctType = (USTemplateField)grvEEDirectDeposit.Columns[COL_ACCOUNTTYPE];
      USBoundField usbfDescription = (USBoundField)grvEEDirectDeposit.Columns[COL_DESCRIPTION];

      if (Master.ProductKey != "ESS")
        usbfDescription.Visible = false;


      if (GetCountry() == "CAN")
      {
        grvEEDirectDeposit.Columns[COL_ACCOUNTTYPE].Visible = false;
        grvEEDirectDeposit.Columns[COL_ROUTINGNUMBER].HeaderText = "BranchNumber";
        (grvEEDirectDeposit.Columns[COL_BANKINSTNUM] as USBoundField).DefaultHidden = true;
        grvEEDirectDeposit.Columns[COL_ACCOUNTNUMBER].Visible = true;
        grvEEDirectDeposit.Columns[COL_BANKINSTNUM].Visible = true;

        if (Master.Pages["EEPayrollDirectDepositDetailWiz.aspx"] != null)
          Master.Pages["EEPayrollDirectDepositDetailWiz.aspx"].Controls["txbBankInstitutionNo"].DisplayInChgDetail = "Y";
      }
      else
      {
        if (Master.Pages["EEPayrollDirectDepositDetailWiz.aspx"] != null)
          Master.Pages["EEPayrollDirectDepositDetailWiz.aspx"].Controls["txbBankInstitutionNo"].DisplayInChgDetail = "N";
      }
        if (!IsPostBack)
        {
            //To turn on Toolbar Icons:
            //Master.PageMode = PageModeType.Create + PageModeType.Read + PageModeType.Editable + PageModeType.Delete;
            Master.PageMode += PageModeType.Create;
      grvEEDirectDeposit.DeleteButton.EntityKey = "OID";

      // Do not display the Delete/Select column if in a Wizard
      if (Master.IsWizard)
      {
          grvEEDirectDeposit.DeleteColumn = false;
          grvEEDirectDeposit.SelectColumn = false;
      }

            // CUSTOM BEGIN - JDF - SR-2019-00245269
            Employee employee = null;
            IsDebitCard = GetEmployeeDebitCardUsage();

            if (Master.IsWizard && (Master.ProcessParams.Find("IsPendhireWizard") != null) && Boolean.Parse(Master.ProcessParams["IsPendhireWizard"].Value))
            {
                EmployeeList objEmployeeList = Master.DataList[0].Data as EmployeeList;
                employee = objEmployeeList.FindByObjectID(Master.ProcessParams["ObjectIDEmployee"].Value) as Employee;

                IsPendHireDCConsentWage = GetPendHireDCConsentWage(employee);
            }
            if (IsDebitCard || IsPendHireDCConsentWage)
            {
                grvEEDirectDeposit.DeleteColumn = false;
                Master.ToolbarButtons.Delete.Visible = false;
                Master.ToolbarButtons.Add.Visible = false;

                var editDivider = (Image)Master.FindControl("editDivider");
                editDivider.Attributes["class"] = "hide";

                var labelsDivider = (Image)Master.FindControl("labelsDivider");
                labelsDivider.Attributes["class"] = "hide";
                
                if (employee != null && IsPendHireDCConsentWage)
                {
                    AddDebitCardAccount(employee);
                }
            }
            // CUSTOM END - JDF - SR-2019-00245269
        }
    }

    // CUSTOM BEGIN - JDF - SR-2019-00245269
    private void AddDebitCardAccount(Employee employee)
    {
        Dictionary<string, string> directDepositInfo = new Dictionary<string, string>();

        new CompanyDataAccessControl(Master.UserContext).CallStoredProcedure("U_LAZ1001_GetDirectDepositInfo", null, reader =>
        {
            while (reader.Read())
            {
                directDepositInfo.Add("Account", reader["Account"].ToString().Trim());
                directDepositInfo.Add("Bank", reader["Bank"].ToString().Trim());
                directDepositInfo.Add("Route", reader["Route"].ToString().Trim());
            }
        });

        DirectDeposit directDeposit = new DirectDeposit();
        directDeposit.Account = directDepositInfo["Account"];
        directDeposit.AccountType.Code = "D";
        directDeposit.Bank.BankName = directDepositInfo["Bank"];
        directDeposit.DateTimeCreated = DateTime.Now;
        directDeposit.IsInActive = false;
        directDeposit.Bank.BankRoutingNo = directDepositInfo["Route"];
        directDeposit.DirectDepositRule = EDirectDepositRule.AvailableBalance;
        directDeposit.PrenoteStatus = EPrenoteStatus.Prenote;
        directDeposit.AmtOrPct = 0;

        if(employee.DirectDeposits.Count == 0 || employee.DirectDeposits.Count > 1 || (employee.DirectDeposits.Count == 1 && employee.DirectDeposits[0].AccountType.Code != "D"))
        {
            employee.DirectDeposits.Clear();
            employee.DirectDeposits.Add(directDeposit);
        }

    }
    // CUSTOM END - JDF - SR-2019-00245269
  public void dsEEDirectDeposit_OnGridDataTableFilled(object sender, GridDataTableEventArgs args)
  {
    //Add a new column for the "order" depending on the sequence #.
    int idxCount = 0;
    ArrayList AL = new ArrayList();
    DataTable dt = args.Table;

    //This method stops the 2nd databind event from occuring (beta issue perhaps?)
    if (!dt.Columns.Contains("NewOrder"))
    {
      dt.Columns.Add("NewOrder", Type.GetType("System.Int16"));

      DataView dvSorted = new DataView(dt, "", "Sequence asc", DataViewRowState.CurrentRows);

      for (int i = 0; i < dt.Rows.Count; i++)
      {
        //Set virtual order by according to sequence number.
        dvSorted[i]["NewOrder"] = ++idxCount;
      }
    }
  }

    protected string PrenoteStatus(string status, string inactive, string isarchived)
  {
    if ((status == "P") && (inactive.ToUpper() != "TRUE") && (GetCountry().ToUpper() == "USA"))
      return Master.GetString("Prenote");
    else
            return (isarchived.ToUpper() == "TRUE" ? Master.GetString("GDPR_Title_Archived") :
                (inactive.ToUpper() == "TRUE" ? Master.GetString("Inactive") : Master.GetString("Active")));
  }

  public string PctAmtOrBalance(object rule, object amtorpct, object bal)
  {
    string strRule = rule.ToString();
    string Amtorpct = amtorpct.ToString();
    string Bal = bal.ToString();
    string retVal = string.Empty;

    switch (strRule.ToUpper())
    {
      case "P":
        retVal = Master.Format((Convert.ToDecimal(Amtorpct) * 100).ToString(), StyleConsts.PRCNT);
        break;
      case "A":
        retVal = Master.GetCodeDesc("EEDEPOSITRULE", strRule).Description;
        break;
      case "D":
        retVal = Master.Format(Amtorpct.ToString(), StyleConsts.MONEY);
        break;
    }
    return retVal;
  }

  protected void GetObjectParams(object sender, GetObjectParamsEventArgs e)
  {
    e.Parameters.Add("COID", sEECoID);
    e.Parameters.Add("EEID", sEEEEID);
  }

  public static string DDMaskValue(string InputValue, string mType)
  {
    string origVal = InputValue.Trim();
    char maskValue = 'x';
    string retValue = "";
    switch (mType)
    {
      case "ACCTNR":
        {
          if (origVal.Length < 4)
            retValue = retValue.PadLeft(22 - origVal.Length, maskValue) + origVal;
          else
            retValue = (string.Format("{0}{1}", retValue.PadLeft(18, maskValue), origVal.Substring(origVal.Length - 4)));
          break;
        }
    }
    return retValue;
  }

    protected void SummaryGrid_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        GridViewRow r = e.Row;
        DirectDepositDataItem dv = (DirectDepositDataItem)r.DataItem;
        if (r.DataItem != null)
        {
            if (string.Equals(dv.Account.Trim(), ""))
            {
                e.Row.Visible = false;
            }
            if (string.Equals(dv.IsArchived.ToUpper(), "TRUE"))
            {
                e.Row.Cells[0].Enabled = false;
            }
        }

        // CUSTOM BEGIN - JDF - SR-2019-00245269
        /* Begin PRO-132598 >> HP 4/2/2022 >> Refactored to find index of Account Number dynamically and avoid errors when column order changes */
        if (e.Row.RowType == DataControlRowType.Header)
        {
            foreach (TableCell cell in e.Row.Cells)
            {                
                if (cell.Text == Master.GetString("AccountNumber"))
                {
                    indexAcctNum = e.Row.Cells.GetCellIndex(cell);
                    break;
                }
            }
        }        
        else if (e.Row.RowType == DataControlRowType.DataRow && indexAcctNum >= 0)        
        {
            USDetailLink usdlAccount = e.Row.Cells[indexAcctNum].Controls[1] as USDetailLink;
        /* End PRO-132598 >> HP 4/2/2022 */
            usdlAccount.Enabled = !(IsDebitCard || IsPendHireDCConsentWage);
        }
        // CUSTOM END - JDF - SR-2019-00245269
    }

    public void LogDeletedDirectDeposits()
    {
        if (TemplateHelper.SysLogEnabled)
        {
            String[] deletedRecords = grvEEDirectDeposit.DeletedRecords;
            DirectDepositDataItem dataItems = odsPayrollDirectDepositSummary.GetDataItem() as DirectDepositDataItem;

            foreach (DirectDeposit di in dataItems.DataItemList.Cast<DirectDeposit>())
            {
                if (deletedRecords.Contains(di.ObjectID))
                {
                    string msg = string.Format("DD:Deleted, UID:{0}, UN:{1}, SID:{2}, EEID={3}, COID={4}, CLIENTID={5}", Master.UserContext.UserID, Master.UserContext.LoginName ?? "", Master.Helper.GetSessionID(), sEEEEID, sEECoID, Master.UserContext.ClientID);
                    string logData = GetSysLogDebugString(di);
                    msg += logData;
                    SysLogClient.Send(TemplateHelper.SyslogEndpoint, TemplateHelper.SyslogPort, PriorityType.Informational, "DirectDepositPage", msg);
                }
            }
        }
    }

    //TODO: To be moved to common helper class. Code duplicated in order to reduce number of components changed for this one-off. NL
    private static string GetSysLogDebugString(DirectDeposit obj)
    {
        string result = "";

        if (obj != null)
        {
            var bankName = (obj.Bank.BankName != null) ? obj.Bank.BankName.Replace("'", "").Replace(",", "") : "";
            result += string.Format(", A={0}, R={1}, B='{2}', AMT={3}", obj.Account, obj.Bank.BankRoutingNo, bankName, obj.AmtOrPct);
            result += string.Format(", DR={0}, Act={1}, SNo={2}, PN={3}", obj.DirectDepositRule, obj.IsInActive, obj.SequenceNo, obj.PrenoteStatus);
        }

        return result;
    }
    public void ArchiveItems()
    {
        var selectedDirectDepositIds = grvEEDirectDeposit.SelectedDataKeys.Select(x => x.Value.ToString()).ToList();
        DirectDepositDataItem dataItems = odsPayrollDirectDepositSummary.GetDataItem() as DirectDepositDataItem;

        foreach (DirectDeposit di in dataItems.DataItemList.Cast<DirectDeposit>())
        {
            if (selectedDirectDepositIds.Count > 0 && selectedDirectDepositIds.Contains(di.ObjectID))
            {
                Session["successMessage"] =
                    string.Format(Master.GetString("ArchiveDirectDepositMessage"), selectedDirectDepositIds.Count);
                new EmployeeSetup(Master.UserContext).ArchiveEmployeeDirectDeposit(di.PrimaryKey["COID"].ToString(), di.PrimaryKey["EEID"].ToString(), di.PrimaryKey["Sequence"].ToString());
            }
        }
    }
    // CUSTOM BEGIN - JDF - SR-2019-00245269
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

    private bool GetPendHireDCConsentWage(Employee employee)
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
    // CUSTOM END - JDF - SR-2019-00245269
}
