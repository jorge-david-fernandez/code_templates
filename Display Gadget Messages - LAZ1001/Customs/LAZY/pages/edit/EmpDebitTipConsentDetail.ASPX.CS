/// <Header summary>
/// Company:    Ultimate Sofware Corp.
/// Author:     Adrian Serrano
/// Client:     Lazy Dog Restaurants, LLC
/// Filename:   UltiproNet\Customs\LAZY\pages\edit\EmpDebitTipConsentDetail.ASPX.CS
/// CP Request: SR-2019-00245269
/// Date:       9/11/2019
/// Purpose:    Detail Code-Behind page for table U_LAZ1001_EmpDebitTipConsent
///
/// Last Modified: 
/// 
/// </Header summary>

#region Using directives
using System;
using System.Web.UI.WebControls;
using UltimateSoftware.DataAccessLayer;
using UltimateSoftware.Queries.DynamicSQL;
using UltimateSoftware.WebControls;
#endregion

#region Custom Using directives
//using UltimateSoftware.WebObjects.Customs.LAZY;
#endregion

public partial class EmpDebitTipConsentDetail_aspx : USPage
{
    string strObjectID, UDField21, UDField22, UDField24, UDField23;

    protected void Page_Load(object sender, EventArgs e)
    {
        strObjectID = string.IsNullOrEmpty(Master.Parameters["ObjectID"]) ? string.Empty : Master.Parameters["ObjectID"];

        if (!IsPostBack)
        {
            //if (strObjectID.Equals(string.Empty))
            //{
            //  FormView1.DefaultMode = FormViewMode.Insert;
            //}
            //else
            //{
            FormView1.DefaultMode = FormViewMode.Edit;
            // ViewState.Add("ObjectID", strObjectID);
            // }
        }

        ClientScript.RegisterClientScriptBlock(typeof(string), "CompCode",
            string.Format("<script>var compCode = '{0}'; </script>", Master.UserContext.ClientID), false);

        Master.ToolbarButtons.Delete.Visible = false;
        Master.ToolbarButtons.ManageLabels.Visible = false;
        Master.ToolbarButtons.Cancel.Visible = false;

        //KTP: This custom was supposed to go through workflow; however, it was designed to use Ajax calls to 
        //update UDFields immediately when a user clicks on the 'Save' button on the popup screen.  Therefore, if 
        //a user doesn't click on the Save button next to the reset, the record would never be sent to the workflow.  
        //Even if a user clicks on the Save button, it's too late as the UDFields are already updated by the Ajax call.

        //I discussed this issue with the client and they're ok to not enable the workflow.  We will hide the 'Save' and 'Reset' 
        //to eliminate any confusion to users.  The client (Katie Biggs) said she will create an BI report to monitor any changes
        Master.ToolbarButtons.Save.Visible = false;
        Master.ToolbarButtons.Restore.Visible = false;

        var editDivider = (Image)Master.FindControl("editDivider");
        editDivider.Attributes["class"] = "hide";

        var labelsDivider = (Image)Master.FindControl("labelsDivider");
        labelsDivider.Attributes["class"] = "hide";

        liDebitTipCardSettingsMsg.InnerHtml = new CompanyDataAccessControl(Master.UserContext).CallDynamicSqlScalar<string>(new SqlQuery
        {
            Select = "cntText",
            From = "CONTENT",
            Where = new Field("cntTitle").Equals("Tip/Debit Card Settings Message")
        });

        GetUDFields();
        FormView1.FindControl<Label>("llbDateApproved").Text = !String.IsNullOrEmpty(FormView1.FindControl<Label>("llbDateApproved").Text) ? DateTime.Parse(FormView1.FindControl<Label>("llbDateApproved").Text).ToShortDateString(): FormView1.FindControl<Label>("llbDateApproved").Text;

        ClientScript.RegisterClientScriptBlock(typeof(string), "UDField21",
            string.Format("<script>var UDField21 = '{0}'; </script>", UDField21), false);
        ClientScript.RegisterClientScriptBlock(typeof(string), "UDField22",
            string.Format("<script>var UDField22 = '{0}'; </script>", UDField22), false);
        ClientScript.RegisterClientScriptBlock(typeof(string), "UDField24",
            string.Format("<script>var UDField24 = '{0}'; </script>", UDField24), false);
        ClientScript.RegisterClientScriptBlock(typeof(string), "UDField23",
            string.Format("<script>var UDField23 = '{0}'; </script>", UDField23), false);
        ClientScript.RegisterClientScriptBlock(typeof(string), "HideDebitCard",
            string.Format("<script>var HideDebitCard = '{0}'; </script>", ShouldHideDebitCard()), false);

    }

    private string ShouldHideDebitCard()
    {
        string result = new CompanyDataAccessControl(Master.UserContext).CallScalarStoredProcedure<string>("U_LAZ1001_ShouldHideDebitCard"
            , new object[] { Master.EEID, Master.COID });
        if (string.IsNullOrEmpty(result))
        {
            result = "false";
        }
        return result;
    }

    private void GetUDFields()
    {
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
    }

    protected void USObjectDataSource1_OnAfterObjectLoad(object sender, AfterObjectLoadEventArgs e)
    {
        //strObjectID = e.DataItemObject.ObjectID;
        //ViewState.Add("ObjectID", strObjectID);
    }

    protected override void OnSave(ToolBarEventArgs tbea)
    {
        //case FormViewMode.Edit:
        FormView1.FindControl<CodeDescLabel>("cdlApproved").Code = "Y";
        FormView1.FindControl<Label>("llbDateApproved").Text = DateTime.Now.ToShortDateString();
        FormView1.UpdateItem(true);
        
        new CompanyDataAccessControl(Master.UserContext).CallNonQueryStoredProcedure("U_LAZ1001_DefaultElectronicCopies"
            , new object[] { Master.EEID });
    }

    protected override void OnDelete(ToolBarEventArgs tbea)
    {
        FormView1.DeleteItem();
    }

    protected void USObjectDataSource1_OnGetObjectParams(object sender, GetObjectParamsEventArgs e)
    {
        e.Parameters.Add("aCOID", Master.COID);
        e.Parameters.Add("aEEID", Master.EEID);
    }

    protected override void OnPreRender(EventArgs e)
    {
        if (FormView1.CurrentMode == FormViewMode.Insert)
        {
            Master.PageMode -= PageModeType.Delete;
        }
        base.OnPreRender(e);
    }
}
