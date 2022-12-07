using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml;
using UltimateSoftware.ObjectModel.DataAccess;
using UltimateSoftware.ObjectModel.Objects;
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

public partial class Customs_LAZY_usercontrols_EEHireStart : USUserControl
{
    public ProcessTemplate Master
    {
        get { return (ProcessTemplate)Page.Master; }
    }

    private string pendHireSystemId
    {
        get
        {
            return Master.Parameters["PendHireSystemID"];
        }
    }

    public override void Initialize()
    {
        base.Initialize();

        InsertAt = InsertLocation.pageBottom;

        if (!string.IsNullOrEmpty(Master.Parameters["PendHireSystemID"]))
        {
            if (!IsPostBack)
            {
                string PendHireSystemID = Master.Parameters["PendHireSystemID"].ToString();
                if (Master.Pages[0].Visited == false)
                {
                    PendHireDA pendHireDa = new PendHireDA(Master.UserContext);
                    PendHireList pendHireList = pendHireDa.GetPendHire(Master.Parameters["PendHireSystemID"], Master.ClientID);
                    PendHire pendHire = pendHireList[0];

                    bool IsCustomPendHire = (pendHire.PXImportedBy == "AUTOIMPORTER");
                    Page.ClientScript.RegisterClientScriptBlock(typeof(string), "CustomPendingHire", string.Format("<script> var varCustomPendingHire = {0};</script>", IsCustomPendHire.ToString().ToLower()));

                    Master.ProcessParams.Add("CustomPendingHire", IsCustomPendHire.ToString());

                    if (IsCustomPendHire)
                    {
                        EmployeeList objEmployeeList = (EmployeeList)Master.DataList[0].Data;
                        Employee eeDataItem = objEmployeeList[0];
                    }

                }
            }
        }

    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack && !Master.CurrentPage.Visited)
        {
            if (!string.IsNullOrEmpty(pendHireSystemId))
            {
                PendHireDA pendHireDa = new PendHireDA(Master.UserContext);
                PendHireList pendHireList = pendHireDa.GetPendHire(Master.Parameters["PendHireSystemID"], Master.ClientID);
                PendHire pendHire = pendHireList[0];

                EmployeeList objEmployeeList = (EmployeeList)Master.DataList[0].Data;
                Employee eeDataItem = objEmployeeList[0];

                XmlDocument SuppXml = new XmlDocument();
                SuppXml.LoadXml(pendHire.SupplDataXML);

                XmlNode udField01Node = SuppXml.SelectSingleNode("Supplemental/UserDefinedFieldsInfo/UdfInfo[FieldExternalCode = 'EECUDFIELD01']");
                if (udField01Node != null)
                {
                    XmlNode udField01 = udField01Node.SelectSingleNode("Value");
                    if (udField01 != null && !string.IsNullOrEmpty(udField01.InnerText))
                    {
                        Master.ProcessParams.Add("EecUDField01", udField01.InnerText);
                    }
                }
                XmlNode udField11Node = SuppXml.SelectSingleNode("Supplemental/UserDefinedFieldsInfo/UdfInfo[FieldExternalCode = 'EECUDFIELD11']");
                if (udField11Node != null)
                {
                    XmlNode udField11 = udField11Node.SelectSingleNode("Value");
                    if (udField11 != null && !string.IsNullOrEmpty(udField11.InnerText))
                    {
                        Master.ProcessParams.Add("EecUDField11", udField11.InnerText);
                    }
                }
                XmlNode udField12Node = SuppXml.SelectSingleNode("Supplemental/UserDefinedFieldsInfo/UdfInfo[FieldExternalCode = 'EECUDFIELD12']");
                if (udField12Node != null)
                {
                    XmlNode udField12 = udField12Node.SelectSingleNode("Value");
                    if (udField12 != null && !string.IsNullOrEmpty(udField12.InnerText))
                    {
                        Master.ProcessParams.Add("EecUDField12", udField12.InnerText);
                    }
                }
                XmlNode udField14Node = SuppXml.SelectSingleNode("Supplemental/UserDefinedFieldsInfo/UdfInfo[FieldExternalCode = 'EECUDFIELD14']");
                if (udField14Node != null)
                {
                    XmlNode udField14 = udField14Node.SelectSingleNode("Value");
                    if (udField14 != null && !string.IsNullOrEmpty(udField14.InnerText))
                    {
                        Master.ProcessParams.Add("EecUDField14", udField14.InnerText);
                    }
                }
                XmlNode udField15Node = SuppXml.SelectSingleNode("Supplemental/UserDefinedFieldsInfo/UdfInfo[FieldExternalCode = 'EECUDFIELD15']");
                if (udField15Node != null)
                {
                    XmlNode udField15 = udField15Node.SelectSingleNode("Value");
                    if (udField15 != null && !string.IsNullOrEmpty(udField15.InnerText))
                    {
                        Master.ProcessParams.Add("EecUDField15", udField15.InnerText);
                    }
                }
                XmlNode udField21Node = SuppXml.SelectSingleNode("Supplemental/UserDefinedFieldsInfo/UdfInfo[FieldExternalCode = 'EECUDFIELD21']"); 
                if (udField21Node != null)
                {
                    XmlNode udField21 = udField21Node.SelectSingleNode("Value");
                    if (udField21 != null && !string.IsNullOrEmpty(udField21.InnerText))
                    {
                        Master.ProcessParams.Add("EecUDField21", udField21.InnerText);
                    }
                }
                XmlNode udField22Node = SuppXml.SelectSingleNode("Supplemental/UserDefinedFieldsInfo/UdfInfo[FieldExternalCode = 'EECUDFIELD22']"); 
                if (udField22Node != null)
                {
                    XmlNode udField22 = udField22Node.SelectSingleNode("Value");
                    if (udField22 != null && !string.IsNullOrEmpty(udField22.InnerText))
                    {
                        Master.ProcessParams.Add("EecUDField22", udField22.InnerText);
                    }
                }
                XmlNode udField23Node = SuppXml.SelectSingleNode("Supplemental/UserDefinedFieldsInfo/UdfInfo[FieldExternalCode = 'EECUDFIELD23']");
                if (udField23Node != null)
                {
                    XmlNode udField23 = udField23Node.SelectSingleNode("Value");
                    if (udField23 != null && !string.IsNullOrEmpty(udField23.InnerText))
                    {
                        Master.ProcessParams.Add("EecUDField23", udField23.InnerText);
                    }
                }
                XmlNode udField24Node = SuppXml.SelectSingleNode("Supplemental/UserDefinedFieldsInfo/UdfInfo[FieldExternalCode = 'EECUDFIELD24']");
                if (udField24Node != null)
                {
                    XmlNode udField24 = udField24Node.SelectSingleNode("Value");
                    if (udField24 != null && !string.IsNullOrEmpty(udField24.InnerText))
                    {
                        Master.ProcessParams.Add("EecUDField24", udField24.InnerText);
                    }
                }
                XmlNode eepUdField01Node = SuppXml.SelectSingleNode("Supplemental/UserDefinedFieldsInfo/UdfInfo[FieldExternalCode = 'EEPUDFIELD01']");
                if (eepUdField01Node != null)
                {
                    XmlNode eepUdField01 = eepUdField01Node.SelectSingleNode("Value");
                    if (eepUdField01 != null && !string.IsNullOrEmpty(eepUdField01.InnerText))
                    {
                        Master.ProcessParams.Add("EepUDField01", eepUdField01.InnerText);
                    }
                }

                // DCD CUSTOM SR-2021-00335777 START
                XmlNode VaccinationStatusNode = SuppXml.SelectSingleNode("Supplemental/UserDefinedFieldsInfo/UdfInfo[FieldExternalCode = 'Vaccination Status']");
                if (VaccinationStatusNode != null)
                {
                    XmlNode VaccinationStatus = VaccinationStatusNode.SelectSingleNode("Value");
                    if (VaccinationStatus != null && !string.IsNullOrEmpty(VaccinationStatus.InnerText))
                    {
                        Master.ProcessParams.Add("_BVaccinationStatus", VaccinationStatus.InnerText);
                    }
                }

                XmlNode PC1Node = SuppXml.SelectSingleNode("Supplemental/UserDefinedFieldsInfo/UdfInfo[FieldExternalCode = 'PC1']");
                if (PC1Node != null)
                {
                    XmlNode PC1 = PC1Node.SelectSingleNode("Value");
                    if (PC1 != null && !string.IsNullOrEmpty(PC1.InnerText))
                    {
                        Master.ProcessParams.Add("_BPC1", PC1.InnerText);
                    }
                }

                XmlNode PC3Node = SuppXml.SelectSingleNode("Supplemental/UserDefinedFieldsInfo/UdfInfo[FieldExternalCode = 'PC3']");
                if (PC3Node != null)
                {
                    XmlNode PC3 = PC3Node.SelectSingleNode("Value");
                    if (PC3 != null && !string.IsNullOrEmpty(PC3.InnerText))
                    {
                        Master.ProcessParams.Add("_BPC3", PC3.InnerText);
                    }
                }

                XmlNode PC4Node = SuppXml.SelectSingleNode("Supplemental/UserDefinedFieldsInfo/UdfInfo[FieldExternalCode = 'PC4']");
                if (PC4Node != null)
                {
                    XmlNode PC4 = PC4Node.SelectSingleNode("Value");
                    if (PC4 != null && !string.IsNullOrEmpty(PC4.InnerText))
                    {
                        Master.ProcessParams.Add("_BPC4", PC4.InnerText);
                    }
                }
                XmlNode PC5Node = SuppXml.SelectSingleNode("Supplemental/UserDefinedFieldsInfo/UdfInfo[FieldExternalCode = 'PC5']");
                if (PC5Node != null)
                {
                    XmlNode PC5 = PC5Node.SelectSingleNode("Value");
                    if (PC5 != null && !string.IsNullOrEmpty(PC5.InnerText))
                    {
                        Master.ProcessParams.Add("_BPC5", PC5.InnerText);
                    }
                }
                XmlNode PC6Node = SuppXml.SelectSingleNode("Supplemental/UserDefinedFieldsInfo/UdfInfo[FieldExternalCode = 'PC6']");
                if (PC6Node != null)
                {
                    XmlNode PC6 = PC6Node.SelectSingleNode("Value");
                    if (PC6 != null && !string.IsNullOrEmpty(PC6.InnerText))
                    {
                        Master.ProcessParams.Add("_BPC6", PC6.InnerText);
                    }
                }
                XmlNode PC7Node = SuppXml.SelectSingleNode("Supplemental/UserDefinedFieldsInfo/UdfInfo[FieldExternalCode = 'PC7']");
                if (PC7Node != null)
                {
                    XmlNode PC7 = PC7Node.SelectSingleNode("Value");
                    if (PC7 != null && !string.IsNullOrEmpty(PC7.InnerText))
                    {
                        Master.ProcessParams.Add("_BPC7", PC7.InnerText);
                    }
                }
                XmlNode PC8Node = SuppXml.SelectSingleNode("Supplemental/UserDefinedFieldsInfo/UdfInfo[FieldExternalCode = 'PC8']");
                if (PC8Node != null)
                {
                    XmlNode PC8 = PC8Node.SelectSingleNode("Value");
                    if (PC8 != null && !string.IsNullOrEmpty(PC8.InnerText))
                    {
                        Master.ProcessParams.Add("_BPC8", PC8.InnerText);
                    }
                }
                XmlNode PC9Node = SuppXml.SelectSingleNode("Supplemental/UserDefinedFieldsInfo/UdfInfo[FieldExternalCode = 'PC9']");
                if (PC9Node != null)
                {
                    XmlNode PC9 = PC9Node.SelectSingleNode("Value");
                    if (PC9 != null && !string.IsNullOrEmpty(PC9.InnerText))
                    {
                        Master.ProcessParams.Add("_BPC9", PC9.InnerText);
                    }
                }
                // DCD CUSTOM SR-2021-00335777 END
            }
        }
    }
}