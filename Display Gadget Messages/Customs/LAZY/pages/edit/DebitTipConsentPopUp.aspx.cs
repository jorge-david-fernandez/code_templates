/// <Header summary>
///Company:		  Ultimate Software Corp. 
///Author:		  Adrian Serrano
///Client:		  Lazy Dog Restaurants, LLC
///Date:		  1/28/2020
///Request:		  SR-2019-00245269
///Purpose:		  Instant Pay Direct Deposit (from scope project SR-2019-00233967)
///Last Modified: 

/// </Header summary>
            

using System;
using System.Collections.Generic;
using System.Web;
using System.Web.Services;
using UltimateSoftware.DataAccessLayer;
using UltimateSoftware.Queries.DynamicSQL;
using UltimateSoftware.Security;
using UltimateSoftware.WebControls;

public partial class DebitTipConsentPopUp_aspx : USPage
{
    string CmmSuppressAllDDAs = string.Empty;
    private Dictionary<string, string> gadgetMessages = new Dictionary<string, string>(StringComparer.InvariantCultureIgnoreCase);
    Dictionary<string, string> USParams = new Dictionary<string, string>();

    readonly string CONSENT_WAGE = "DC Consent Wage";
    readonly string NON_CONSENT_WAGE = "DC Non Consent Wage";
    readonly string CONSENT_TIPS = "DC Consent Tips";
    readonly string NON_CONSENT_TIPS = "DC Non Consent Tips";
    readonly string MEAL_WAIVER_1_CONSENT_Y = "Meal Waiver 1 Consent Y";
    readonly string MEAL_WAIVER_1_CONSENT_N = "Meal Waiver 1 Consent N";
    readonly string MEAL_WAIVER_2_CONSENT_Y = "Meal Waiver 2 Consent Y";
    readonly string MEAL_WAIVER_2_CONSENT_N = "Meal Waiver 2 Consent N";


    private string CONSENT_TYPE = String.Empty;

    void Page_PreRender(object sender, EventArgs e)
    {
        //if (CmmSuppressAllDDAs.Equals("Y", StringComparison.InvariantCultureIgnoreCase) || !Master.ToolbarButtons.Edit.IsAllowed)
        //{
        //	// if DDAs are suppressed then nothing will be in the lightbox except
        //	// a message. Nothing to SAVE, hide it
        //	Master.ToolbarButtons.Save.On = false;
        //         // PaperElectronic.Enabled = false;
        //          //ElectronicOnly.Enabled = false;
        //}

        // Add the for= for these labels to associate them with the radio button inputs.
        //lblElectronicOnly.Attributes.Add("for", ElectronicOnly.ClientID);
        //lblPaperAndElectronicCopy.Attributes.Add("for", PaperElectronic.ClientID);
    }

    [WebMethod]
    public static void SaveConsent(string EEID, string COID, string consentType, string debitTip, string consentAnswer, string initials)
    {
        // If you need to make a DB call you can get the usercontext like this
        UserContext uc = ((UserContext)((Dictionary<string, CacheItem>)HttpContext.Current.Session["SESSIONMANAGER"])["USERCONTEXT"].Data);
        if (string.IsNullOrEmpty(EEID) || string.IsNullOrEmpty(COID))
        {
            EEID = uc.EEID;
            COID = uc.COID;
        }
        new CompanyDataAccessControl(uc).CallNonQueryStoredProcedure("U_LAZ1001_SaveConsent"
            , new object[] { EEID, COID, consentType, debitTip, consentAnswer, initials });

        new CompanyDataAccessControl(uc).CallNonQueryStoredProcedure("U_LAZ1001_DefaultElectronicCopies"
            , new object[] { EEID });

        if (string.Compare(debitTip, "debit", true) == 0)
        {
            new CompanyDataAccessControl(uc).CallNonQueryStoredProcedure("U_LAZ1001_PerformDirectDepositPosting"
                , new object[] { EEID, COID, consentAnswer });
        }
    }

    private void FormatUSParams()
    {
        foreach (string touple in Master.Request["USParams"].Split('!'))
        {
            if (touple.Contains("="))
            {
                string[] pair = touple.Split('=');
                USParams.Add(pair[0].ToString().Trim(), pair[1].ToString().Trim());
            }
        }
    }

    private string GetConsentType()
    {
        string UDField21 = String.Empty, UDField22 = String.Empty, UDField24 = String.Empty, UDField23 = String.Empty;

        new CompanyDataAccessControl(Master.UserContext).CallDynamicSql(new SqlQuery
        {
            Select = new FieldCollection(new Field("eecUDField21"), new Field("eecUDField22"), new Field("eecUDField24"), new Field("eecUDField23")),
            From = "EmpComp",
            Where = new Field("eecEEID").Equals(Master.EEID).And(new Field("eecCOID").Equals(Master.COID))
        }, reader =>
        {
            while (reader.Read())
            {
                UDField21 = (!reader.IsDBNull(0)) ? reader["eecUDField21"].ToString().Trim() : String.Empty;
                UDField22 = (!reader.IsDBNull(1)) ? reader["eecUDField22"].ToString().Trim() : String.Empty;
                UDField24 = (!reader.IsDBNull(2)) ? reader["eecUDField24"].ToString().Trim() : String.Empty;
                UDField23 = (!reader.IsDBNull(3)) ? reader["eecUDField23"].ToString().Trim() : String.Empty;
            }
        });

        switch (USParams["ConsentType"])
        {
            case "Debit":
                if (USParams["ConsentAnswer"].Equals("Y"))
                {
                    return CONSENT_WAGE;
                }
                else if (USParams["ConsentAnswer"].Equals("N"))
                {
                    return NON_CONSENT_WAGE;
                }
                else
                {
                    return String.Empty;
                }
            case "Tip":
                if (USParams["ConsentAnswer"].Equals("Y"))
                {
                    return CONSENT_TIPS;
                }
                else if (USParams["ConsentAnswer"].Equals("N"))
                {
                    return NON_CONSENT_TIPS;
                }
                else
                {
                    return String.Empty;
                }
            case "MealWaiver1":
                if (USParams["ConsentAnswer"].Equals("Y"))
                {
                    return MEAL_WAIVER_1_CONSENT_Y;
                }
                else if (USParams["ConsentAnswer"].Equals("N"))
                {
                    return MEAL_WAIVER_1_CONSENT_N;
                }
                else
                {
                    return String.Empty;
                }
            case "MealWaiver2":
                if (USParams["ConsentAnswer"].Equals("Y"))
                {
                    return MEAL_WAIVER_2_CONSENT_Y;
                }
                else if (USParams["ConsentAnswer"].Equals("N"))
                {
                    return MEAL_WAIVER_2_CONSENT_N;
                }
                else
                {
                    return String.Empty;
                }
            default:
                return String.Empty;
        }
    }

    void Page_Load(object sender, EventArgs e)
    {
        DownloadGadgetMessages();
        FormatUSParams();
        CONSENT_TYPE = GetConsentType();

        Master.PageMode = PageModeType.Editable;
        Master.ToolbarButtons.Restore.Visible = false;
        liAckText.Text = GetConsentMessage();
        lblDate.Text = Master.Format(DateTime.Now.ToString(), StyleConsts.DATE);

        ClientScript.RegisterClientScriptBlock(typeof(string), "CONSENT_TYPE",
            string.Format("<script>var CONSENT_TYPE = '{0}'; </script>", CONSENT_TYPE), false);
    }

    //JSR >> begin >> SR-2018-00193269
    private string GetConsentMessage()
    {
        if (gadgetMessages.ContainsKey(CONSENT_TYPE))
        {
            return gadgetMessages[CONSENT_TYPE];
        }
        else if (String.IsNullOrEmpty(CONSENT_TYPE))
        {
            return String.Empty;
        }
        else
        {
            Master.AddErrorMessage("There is no Gadget set as " + CONSENT_TYPE + ".", ErrorSeverity.Error);
            return String.Empty;
        }
    }
    private void DownloadGadgetMessages()
    {
        new CompanyDataAccessControl(Master.UserContext).CallStoredProcedure("U_LAZ1001_DownloadGadgetMessages"
            , null
            , reader =>
             {
                 while (reader.Read())
                 {
                     gadgetMessages.Add(reader["MessageID"].ToString().Trim(), reader["Message"].ToString().Trim());
                 }
             });
    }
    //JSR >> end >> SR-2018-00193269
}