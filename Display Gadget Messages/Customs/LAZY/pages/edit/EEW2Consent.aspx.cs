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
using System.Linq;
using System.Text;
using System.Data;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using UltiProNet.app_code.Helpers.Compliance;
using UltimateSoftware.WebControls;
using UltimateSoftware.WebObjects;
using UltimateSoftware.DataAccessLayer;
using UltimateSoftware.Queries.DynamicSQL;
using UltimateSoftware.Security;

public partial class EEW2Consent_aspx : USPage
{
    private bool _hasPuertoRicoW2;
    CompanyDataAccessControl dac;

    protected void Page_Load(object sender, EventArgs e)
    {
        fvConsent.DefaultMode = FormViewMode.Edit;

        Master.ToolbarButtons.Delete.Visible = false;
        Master.ToolbarButtons.Restore.Visible = false;

        _hasPuertoRicoW2 = HasPuertoRicoW2(Master.EEID);
        dac = new CompanyDataAccessControl(Master.UserContext);
        // CUSTOM BEGIN - JDF - SR-2019-00245269
        new CompanyDataAccessControl(Master.UserContext).CallNonQueryStoredProcedure("U_LAZ1001_DefaultElectronicCopies",
            new object[] { Master.EEID });
        // CUSTOM END JDF - SR-2019-00245269
    }

    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);

        var dataItem = objEmployeeIdentification.Select().Cast<IdentificationDataItem>().FirstOrDefault();
        
        if (dataItem != null)
        {
            AddInfoMessages(dataItem.ConsentElectronicW2, dataItem.ConsentElectronicPuertoRicoW2);
            SetRadioButtons(dataItem.ConsentElectronicW2, "rlUsConsentYes", "rlUsConsentNo");
            SetRadioButtons(dataItem.ConsentElectronicPuertoRicoW2, "rlPrConsentYes", "rlPrConsentNo");
        }
        else
        {
            AddInfoMessages("N", "N");
            SetRadioButtons("N", "rlUsConsentYes", "rlUsConsentNo");
            SetRadioButtons("N", "rlPrConsentYes", "rlPrConsentNo");
        }

        btn1095CPaperlessYes.Text = Master.GetString("1095CPaperlessYes");
        btn1095CPaperlessNo.Text = Master.GetString("NoThanks").ToLower();
        btn1095CPaperlessNo.Text = Char.ToUpper(btn1095CPaperlessNo.Text[0]) + btn1095CPaperlessNo.Text.Substring(1);
        Paperless1095CModalHeader.InnerText = Master.GetString("ThanksConsentSaved");
    }

    private void AddInfoMessages(string usConsent,string prConsent)
    {
        bool consentedUs = usConsent.Trim().Equals("Y", StringComparison.InvariantCultureIgnoreCase);
        bool consentedPr = prConsent.Trim().Equals("Y", StringComparison.InvariantCultureIgnoreCase);

        // Line 1a
        Master.AddError(consentedUs ? "W2ConsentEmployer" : "W2NoConsentEmployer", ErrorSeverity.Informational);

        // Line 1b - If employee has PR W2 display second message
        if (_hasPuertoRicoW2)
        {
            Master.AddError(consentedPr ? "W2PRConsentEmployer" : "W2PRNoConsentEmployer", ErrorSeverity.Informational);
        }

        // Line 2
        Master.AddError(!consentedUs || (_hasPuertoRicoW2 && !consentedPr) ? "W2NoConsentEmployerNo" : "W2ConsentEmployerNo", ErrorSeverity.Informational);

        // Line 3
        Master.AddError("W2ConsentTermInfo", ErrorSeverity.Informational);

        // Line 4 - Company-specific consent text
        string w2ConsentMessage = TaxHelper.GetCompMastMessage(Master, "CmmYENoteID");
        if (!string.IsNullOrEmpty(w2ConsentMessage))
        {
            Master.AddErrorMessage(w2ConsentMessage, ErrorSeverity.Informational);
        }
    }

    protected override void OnSave(ToolBarEventArgs tbea)
    {
        // fvConsent.UpdateItem(true);
    }
    
    protected void UpdateConsent(object sender, EventArgs e)
    {
        // Update Database with selected Consent option
        using (DataCommand dc = new DataCommand())
        {
            dc.ConnectionInfo = Master.ConnectionInfo;
            dc.CommandType = CommandType.Text;
            StringBuilder SQL = new StringBuilder("update emppers set eepconsentelectronicW2  =  @ConsentVal");
            if (_hasPuertoRicoW2)
            {
                SQL.Append(", eepconsentelectronicw2PR = @PRConsentVal");
                dc.SqlParameters.Add("@PRConsentVal", SqlDbType.Char, GetRadioButtonsValue("rlPrConsentYes"));
            }
            SQL.Append(" where eepeeid = @EEID");
            dc.SQL = SQL.ToString();
            dc.SqlParameters.Add("@ConsentVal", SqlDbType.Char, GetRadioButtonsValue("rlUsConsentYes"));
            dc.SqlParameters.Add("@EEID", SqlDbType.VarChar, Master.EEID);
            dc.ExecuteNonQuery();
        }
        
        // Show Paperless modal if 1095-C Consent page is accessible and the user is opted for a paper 1095-C
        string paperlessConsentPopupScript = "$('#Paperless1095CModal').modal({ backdrop: 'static', keyboard: false });";
        if (ConsentPageIsAccessible() && !HasPaperless1095C())
        {
            ScriptManager.RegisterStartupScript(UpdatePanel1,UpdatePanel1.GetType(), "PaperlessPopup", paperlessConsentPopupScript, true);
        }
        else
        {
            Master.Transfer("~/pages/view/EEW2View.aspx", TransferType.Save);
        }
    }
    
    protected void OnPaperless1095CAccept(object sender, EventArgs e)
    {
        Master.Transfer("~/pages/edit/1095CEmployeeConsent.aspx", TransferType.Edit);
    }

    protected void OnPaperless1095CCancel(object sender, EventArgs e)
    {
        Master.Transfer("~/pages/edit/EEW2Consent.aspx", TransferType.Cancel);
    }

    //PRO-130956 This method is no longer executing because of the onclick save method in EEW2Consent.js 
    //Saving in case we need to navigate to the SubmitProcess.aspx page
    protected void objEmployeeIdentification_OnSaveObject(object sender, SaveObjectEventArgs e)
    {
        var dataItem = ((IdentificationDataItem) objEmployeeIdentification.GetDataItem());
        string oldUsConsent = dataItem.ConsentElectronicW2;
        string oldPrConsent = dataItem.ConsentElectronicPuertoRicoW2;

        dataItem.ConsentElectronicW2 = GetRadioButtonsValue("rlUsConsentYes");
        dataItem.ConsentElectronicPuertoRicoW2 = GetRadioButtonsValue("rlPrConsentYes");

        Master.CurrentPage.RuntimeControls["rtUsConsent"].BeforeValue = oldUsConsent;
        Master.CurrentPage.RuntimeControls["rtUsConsent"].AfterValue = dataItem.ConsentElectronicW2;

        if (_hasPuertoRicoW2)
        {
            Master.CurrentPage.RuntimeControls["rtPrConsent"].BeforeValue = oldPrConsent;
            Master.CurrentPage.RuntimeControls["rtPrConsent"].AfterValue = dataItem.ConsentElectronicPuertoRicoW2;
            Master.CurrentPage.RuntimeControls["rtPrConsent"].DisplayInChgDetail = "Y";
        }

        // CUSTOM BEGIN - JDF - SR-2019-00245269
        bool IsDebitCard = new CompanyDataAccessControl(Master.UserContext).CallDynamicSqlScalar<string>(new SqlQuery
        {
            Select = "eecUDField21",
            From = "EmpComp",
            Where = new Field("eecEEID").Equals(Master.EEID).And(new Field("eecCOID").Equals(Master.COID))
        }).Equals("Y");

        dataItem.ConsentElectronicW2 = (IsDebitCard) ? "Y" : GetRadioButtonsValue("rlUsConsentYes");
        // CUSTOM END JDF - SR-2019-00245269
    }
    
    protected void objEmployeeIdentification_OnGetObjectParams(object sender, GetObjectParamsEventArgs e)
    {
        e.Parameters.Add("EEID", Master.EEID);
    }

    #region Helpers

    private void SetRadioButtons(string electronicConsent, string yesRadioButtonId, string noRadioButtonId)
    {
        if (electronicConsent == "Y")
        {
            fvConsent.FindControl<RadioButton>(yesRadioButtonId).Checked = true;
        }
        else
        {
            fvConsent.FindControl<RadioButton>(noRadioButtonId).Checked = true;
        }
    }

    private string GetRadioButtonsValue(string yesRadioButtonId)
    {
        return fvConsent.FindControl<RadioButton>(yesRadioButtonId).Checked ? "Y" : "N";
    }

    protected bool HasPuertoRicoW2(string eeid)
    {
        return PMHelper.BuildCompanyDAL(Master.UserContext).EmployeeHasPuertoRicoW2(eeid);
    }
    
    private bool ConsentPageIsAccessible()
    {
        return PageSecurity.HasPermission(FoundationFacade.Instance.GetSecurableElementRights(Master.UserContext, 3694), CrudeEnum.Update);
    }
    
    private bool HasPaperless1095C()
    {
        var query = new SqlQuery
        {
            Select = new Field("eepconsentelectronicPPACA"),
            From = new UltimateSoftware.Queries.DynamicSQL.Table("emppers"),
            Where = new Field("eepeeid").Equals(Master.EEID)
        };
        var eepconsentelectronicPPACA = dac.CallDynamicSqlScalar<bool>(query);
        return eepconsentelectronicPPACA;
    }

    #endregion
}
