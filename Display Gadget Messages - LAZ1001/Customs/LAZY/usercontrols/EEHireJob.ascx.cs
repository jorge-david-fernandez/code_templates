using System;
using System.Web.UI;
using System.Web.UI.WebControls;
using UltimateSoftware.WebControls;
/// <Header summary>
///Company:		  Ultimate Software Corp. 
///Author:		  Adrian Serrano
///Client:		  Lazy Dog Restaurants, LLC
///Date:		  12/19/2019
///Request:		  SR-2019-00245269
///Purpose:		  Instant Pay Direct Deposit (from scope project SR-2019-00233967)
///Last Modified: 12/1/2021 David Domenico SR-2021-00335777

/// </Header summary>


public partial class Customs_LAZY_usercontrols_EEHireJob : USUserControl
{
    public ProcessTemplate _master
    {
        get { return (ProcessTemplate)Page.Master; }
    }

    private string pendHireSystemId
    {
        get
        {
            return _master.Parameters["PendHireSystemID"];
        }
    }

    public override void Initialize()
    {
        base.Initialize();

        InsertAt = InsertLocation.pageBottom;

        if (!string.IsNullOrEmpty(_master.Parameters["PendHireSystemID"]))
        {
            if (!IsPostBack)
            {
                if (_master.CurrentPage.Visited == false)
                {
                    if (_master.ProcessParams["CustomPendingHire"] != null && !_master.Page.ClientScript.IsClientScriptBlockRegistered(Page.GetType(), "CustomPendingHire"))
                    {
                        Page.ClientScript.RegisterClientScriptBlock(typeof(string), "CustomPendingHire"
                            , string.Format("<script> var varCustomPendingHire = '{0}'; var meal1Waiver = '{1}'; var meal2Waiver = '{2}'; var cardOptIn = '{3}';</script>"
                                , _master.ProcessParams["CustomPendingHire"].Value.ToString().ToLower(),
                                _master.ProcessParams["EecUDField24"] != null ? _master.ProcessParams["EecUDField24"].Value : string.Empty
                                , _master.ProcessParams["EecUDField23"] != null ? _master.ProcessParams["EecUDField23"].Value : string.Empty
                                , _master.ProcessParams["EecUDField22"] != null ? _master.ProcessParams["EecUDField22"].Value : string.Empty));
                    }

                    using (DataCommand cmd = new DataCommand())
                    {
                        cmd.ConnectionInfo = _master.ConnectionInfo;
                        cmd.SQL = "EXEC U_LAZ1001_LinkXmlUDFields @PendHireSystemID, @eecUdField01, @eecUdField11, @eecUdField12, @eecUdField14, @eecUdField15, @eecUdField21, @eecUdField22, @eecUdField23, @eecUdField24, @eepUdField01, @VaccineStatus, @PC1, @PC3, @PC4, @PC5, @PC6, @PC7, @PC8, @PC9 "; // CUSTOM SR-2021-00335777 
                        cmd.SqlParameters.Clear();
                        cmd.SqlParameters.Add("@PendHireSystemID", System.Data.SqlDbType.Int, _master.Parameters["PendHireSystemID"].ToString());
                        cmd.SqlParameters.Add("@eecUdField01", System.Data.SqlDbType.Char
                            , _master.ProcessParams["EecUDField01"] != null ? _master.ProcessParams["EecUDField01"].Value : string.Empty);
                        cmd.SqlParameters.Add("@eecUdField11", System.Data.SqlDbType.Char
                            , _master.ProcessParams["EecUDField11"] != null ? _master.ProcessParams["EecUDField11"].Value : string.Empty);
                        cmd.SqlParameters.Add("@eecUdField12", System.Data.SqlDbType.Char
                            , _master.ProcessParams["EecUDField12"] != null ? _master.ProcessParams["EecUDField12"].Value : string.Empty);
                        cmd.SqlParameters.Add("@eecUdField14", System.Data.SqlDbType.Char
                            , _master.ProcessParams["EecUDField14"] != null ? _master.ProcessParams["EecUDField14"].Value : string.Empty);
                        cmd.SqlParameters.Add("@eecUdField15", System.Data.SqlDbType.VarChar
                            , _master.ProcessParams["EecUDField15"] != null ? _master.ProcessParams["EecUDField15"].Value : string.Empty);
                        cmd.SqlParameters.Add("@eecUdField21", System.Data.SqlDbType.VarChar
                            , _master.ProcessParams["EecUDField21"] != null ? _master.ProcessParams["EecUDField21"].Value : string.Empty);
                        cmd.SqlParameters.Add("@eecUdField22", System.Data.SqlDbType.Char
                            , _master.ProcessParams["EecUDField22"] != null ? _master.ProcessParams["EecUDField22"].Value : string.Empty);
                        cmd.SqlParameters.Add("@eecUdField23", System.Data.SqlDbType.Char
                            , _master.ProcessParams["EecUDField23"] != null ? _master.ProcessParams["EecUDField23"].Value : string.Empty);
                        cmd.SqlParameters.Add("@eecUdField24", System.Data.SqlDbType.Char
                            , _master.ProcessParams["EecUDField24"] != null ? _master.ProcessParams["EecUDField24"].Value : string.Empty);
                        cmd.SqlParameters.Add("@eepUdField01", System.Data.SqlDbType.Char
                            , _master.ProcessParams["EepUDField01"] != null ? _master.ProcessParams["EepUDField01"].Value : string.Empty);
                        // DCD CUSTOM SR-2021-00335777 START
                        cmd.SqlParameters.Add("@VaccineStatus", System.Data.SqlDbType.Char
                            , _master.ProcessParams["_BVaccinationStatus"] != null ? _master.ProcessParams["_BVaccinationStatus"].Value : string.Empty);
                        cmd.SqlParameters.Add("@PC1", System.Data.SqlDbType.Char
                            , _master.ProcessParams["_BPC1"] != null ? _master.ProcessParams["_BPC1"].Value : string.Empty);
                        cmd.SqlParameters.Add("@PC3", System.Data.SqlDbType.Char
                            , _master.ProcessParams["_BPC3"] != null ? _master.ProcessParams["_BPC3"].Value : string.Empty);
                        cmd.SqlParameters.Add("@PC4", System.Data.SqlDbType.Char
                            , _master.ProcessParams["_BPC4"] != null ? _master.ProcessParams["_BPC4"].Value : string.Empty);
                        cmd.SqlParameters.Add("@PC5", System.Data.SqlDbType.Char
                            , _master.ProcessParams["_BPC5"] != null ? _master.ProcessParams["_BPC5"].Value : string.Empty);
                        cmd.SqlParameters.Add("@PC6", System.Data.SqlDbType.Char
                            , _master.ProcessParams["_BPC6"] != null ? _master.ProcessParams["_BPC6"].Value : string.Empty);
                        cmd.SqlParameters.Add("@PC7", System.Data.SqlDbType.Char
                            , _master.ProcessParams["_BPC7"] != null ? _master.ProcessParams["_BPC7"].Value : string.Empty);
                        cmd.SqlParameters.Add("@PC8", System.Data.SqlDbType.Char
                            , _master.ProcessParams["_BPC8"] != null ? _master.ProcessParams["_BPC8"].Value : string.Empty);
                        cmd.SqlParameters.Add("@PC9", System.Data.SqlDbType.Char
                            , _master.ProcessParams["_BPC9"] != null ? _master.ProcessParams["_BPC9"].Value : string.Empty);
                        // DCD CUSTOM SR-2021-00335777 END
                        cmd.ExecuteNonQuery();
                    }

                }
                // This code is to fix core bug for rehire an employee to new company and the tax info are not populated from pendhire xml 
                // because Master.ProcessParams["PendHireRehireDiffCompany"] is never set to "Y" but EEAdminTaxState page look for this value. We have this code to fix the issue until the core has it fixed.
                if (_master.ProcessParams["CustomPendingReHireToNewCompany"] != null && _master.ProcessParams["CustomPendingReHireToNewCompany"].Value.ToString().ToLower() == "true")
                {
                    _master.ProcessParams.Remove("PendHireRehireDiffCompany");
                    _master.ProcessParams.Add("PendHireRehireDiffCompany", "Y");
                }
            }
        }
    }
}