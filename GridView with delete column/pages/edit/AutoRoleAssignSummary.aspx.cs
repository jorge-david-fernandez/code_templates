/// <Header summary>
///
///   Company:    Ultimate Sofware Corp. 
///   Author:     Nathan Osterc
///   Client:     Internal
///   Filename:   UltiproNet\Customs\USG\pages\edit\AutoRoleAssignSummary.ASPX 
///   Date:       2/3/2015
///   Purpose:    Summary page for Role Assignment 
///   
/// </Header summary>

#region Using directives
using System;
using System.Data;
using System.Web.UI;
using UltimateSoftware.WebControls;
#endregion

#region Custom Using directives
using UltimateSoftware.Queries.DynamicSQL;
using UltimateSoftware.DataAccessLayer;
using System.Collections;
using UltimateSoftware.Diagnostics.Common;
using System.Web.UI.WebControls;
using UltimateSoftware.Security;
using System.Collections.Generic;
#endregion

public partial class AutoRoleAssignSummary_aspx : USPage
{
    #region Events

    protected void Page_Load(object sender, EventArgs e)
    {
        MasterPage.AddPageModeType(PageModeType.Create);
        MasterPage.ToolbarButtons.Add.NavigateUrl = "AutoRoleAssignDetail.aspx";

        MasterPage.AddPageModeType(PageModeType.Delete);
        MasterPage.PageHeader = Master.GetString("L_AutoRoleAssign_RoleAssignments");

        basicDS.GetData = GetJobRoleList;

        Master.HideThingsICanDo = true;

        this.MasterPage.PageMode += PageModeType.Delete;
        this.MasterPage.PageMode += PageModeType.Create;

       

    }

    protected void USGridView1_RowDataBound(object sender, System.Web.UI.WebControls.GridViewRowEventArgs e)
    {
        if (e.Row.RowType == System.Web.UI.WebControls.DataControlRowType.DataRow)
        {
            int QualValue1CellIndex = 6;
            int QualValue2CellIndex = 8;
            int QualValue3CellIndex = 10;
            int QualValue4CellIndex = 12;

            DataRowView dv = (DataRowView)e.Row.DataItem;
            LoadQualValueColumn(dv["QualField1"].ToString(), dv["QualValue1"].ToString(), e.Row, QualValue1CellIndex);
            LoadQualValueColumn(dv["QualField2"].ToString(), dv["QualValue2"].ToString(), e.Row, QualValue2CellIndex);
            LoadQualValueColumn(dv["QualField3"].ToString(), dv["QualValue3"].ToString(), e.Row, QualValue3CellIndex);
            LoadQualValueColumn(dv["QualField4"].ToString(), dv["QualValue4"].ToString(), e.Row, QualValue4CellIndex);
        }
    }

    protected override void OnAdd(ToolBarEventArgs tbea)
    {
        base.OnAdd(tbea);
        Master.Parameters["ObjectID"] = string.Empty;
    }

    protected override void OnDelete(ToolBarEventArgs tbea)
    {
        if (string.IsNullOrEmpty(Request.Form["chkDelete"]))
        {
            LogEntry log = new LogEntry();
            log.Message = "Nothing was selected to delete. Select a record to delete and try again.";
            Master.AddError(log, ErrorSeverity.Error);
            return;
        }

        string[] itemsToDelete = Request.Form["chkDelete"].Split(',');

        if (itemsToDelete.Length == 0)
        {
            LogEntry log = new LogEntry();
            log.Message = "Nothing was selected to delete. Select a record to delete and try again.";
            Master.AddError(log, ErrorSeverity.Error);
            return;
        }

        try
        {
            new CompanyDataAccessControl(Master.UserContext).CallScalarStoredProcedure<object>("AutoRoleAssign_DeleteRecord", new object[] { Request.Form["chkDelete"].Trim() });
        }
        catch (Exception exc)
        {
            LogEntry log = new LogEntry();
            log.Message = "Error deleting: " + exc.Message;
            Master.AddError(log, ErrorSeverity.Error);
            return;
        }
    }

    #endregion Events

    #region Data Functions

    private IEnumerable GetJobRoleList(int pageNumber, int pageSize, BooleanExpression filter, SortExpression orderBy, out int rowCount)
    {
        DataTable dataTable = new DataTable();
        new CompanyDataAccessControl(Master.UserContext).CallDynamicSql(GetMatrixListQuery(pageNumber, pageSize, filter, orderBy), dataTable.Load);
        rowCount = dataTable.Rows.Count > 0 ? Convert.ToInt32(dataTable.Rows[0]["MaxNo"]) : 0;
        return new DataView(dataTable);
    }

    protected string getQualifierDesc(object qualValue, object qualDesc)
    {

        if (string.IsNullOrEmpty(qualDesc + ""))
        {
            return "<span style='color:red'>" + qualValue + " - " + Master.GetString("L_AutoRoleAssign_Unavailable") + "</span>";
        }
        return qualDesc.ToString();
    }

    protected string GetJobDescription(object jobCode, object jobDesc)
    {
        if (string.IsNullOrEmpty(jobDesc+""))
        {
            return "<span style='color:red'>" + jobCode + " - " + Master.GetString("L_AutoRoleAssign_Unavailable") + "</span>";
        }
        return jobDesc.ToString().Replace("<","").Replace(">","");
    }

    protected string GetRoleDescription(object roleName, object roledesc)
    {

        if (string.IsNullOrEmpty(roledesc+""))
        {
            return "<span style='color:red'>" + roleName + " - " + Master.GetString("L_AutoRoleAssign_Unavailable") + "</span>";
        }
        return roledesc.ToString();
    }

    
    private static SqlQuery GetMatrixListQuery(int pageNumber, int pageSize, BooleanExpression filter, SortExpression orderBy)
    {
        return new SqlQuery
        {
            Select = Field.Star,
            From = new UltimateSoftware.Queries.DynamicSQL.Table("AutoRoleAssign_vwJobRoleSecurity"),
            Where = filter,
            OrderBy = orderBy,
            PageNumber = pageNumber,
            PageSize = pageSize
        };
    }

    #endregion Data Functions

    #region Helper Functions

    private void LoadQualValueColumn(string qualFieldName, string qualFieldValue, GridViewRow currentRow, int qualValueCellIndex)
    {
        if (!string.IsNullOrEmpty(qualFieldName))
        {
            if (!string.IsNullOrEmpty(qualFieldName) && !string.IsNullOrEmpty(qualFieldValue) && qualFieldName.ToLower() == qualFieldValue.ToLower() )
            {
                HideCDRShowLabel(currentRow, Master.GetString("L_AutoRoleAssign_DefaultTOEEQual"), qualValueCellIndex);
            }
            else if (qualFieldName.ToLower().Equals("eecsupervisorid") && qualFieldValue.ToLower().Equals("self"))
            {
                HideCDRShowLabel(currentRow, Master.GetString("L_AutoRoleAssign_Self"), qualValueCellIndex);
            }
            else
            {

                ShowCDR(currentRow, qualFieldName, qualValueCellIndex);

                if (!string.IsNullOrEmpty(qualFieldValue))
                {

                    IEnumerable<CodeDescriptionDTO> lstCodeTable =
                                        FoundationFacade.Instance.GetCompanyCodeTable(
                                       Master.UserContext.CompanyDatabase, getCodeTableFromQualifier(qualFieldName),
                                       Master.UserContext.Language);

                    string[] arrCodes = qualFieldValue.Split(',');
                    string badCodes = "";
                    foreach (string code in arrCodes)
                    {       
                        

                        bool bFound = false;

                        foreach (CodeDescriptionDTO cdt in lstCodeTable)
                        {
                            if (cdt.Code == code)
                            {
                                bFound = true;
                                break;
                            }

                        }

                        if (!bFound)
                        {
                            badCodes += Master.GetCodeDesc(getCodeTableFromQualifier(qualFieldName), code, true).Description;
                        }
                    }
                    if (!string.IsNullOrEmpty(badCodes))
                    {
                        ShowMissingQualifierLabel(currentRow, badCodes, qualValueCellIndex);
                    }

                }
            }
        }
    }

    private string getCodeTableFromQualifier(string qualName)
    {
        switch (qualName.ToUpper())
        {
            case "EECDEDGROUPCODE":
               return "BENGRP";                
 
            case "EECCOID":                
                return "_COMPANY";
 
            case "EECORGLVL2":
                return "ORGLVL2";
 
            case "EECORGLVL4":
                return "ORGLVL4";
  
            case "EECORGLVL1":
                return "ORGLVL1";
   
            case "EECEETYPE":
                return "EMPTYPE";

            case "EECEMPLSTATUS":
               return "EMPLOYEESTATUS";
   
            case "EECFULLTIMEORPARTTIME":
                return "FULLORPARTTIME";
  
            case "EECSALARYORHOURLY":
               return "SALARYORHOURLY";

            case "EECJOBCODE":
               return "JOBCODELIST";
                
            case "EECLOCATION":
                return "LOCATION";
                
            case "EECPAYGROUP":
                return "PAYGROUP";
                
            case "EECORGLVL3":
                return "ORGLVL3";
                
            case "EECSHIFT":
                return "SHIFT";
                
            case "EECPROJECT":
                return "PROJECT";
                
            case "EECSUPERVISORID":
             
                return "U_RolAsgn_Supervisor";
               
            default:
                return "";
    

        }

    }

    private void HideCDRShowLabel(GridViewRow currentRow, string labelText, int qualValueCellIndex)
    {

        foreach (Control ctrl in currentRow.Cells[qualValueCellIndex].Controls)
        {

            if (!string.IsNullOrEmpty(ctrl.ID) && ctrl.ID.StartsWith("txtQualValue"))
            {
                ((Label)ctrl).Text = labelText;
            }
            else
            {
                ctrl.Visible = false;
            }
        }
         
    }

    private void ShowMissingQualifierLabel(GridViewRow currentRow, string missingQuals, int qualValueCellIndex)
    {
        foreach (Control ctrl in currentRow.Cells[qualValueCellIndex].Controls)
        {

            if (!string.IsNullOrEmpty(ctrl.ID) && ctrl.ID.StartsWith("txtMissingQual"))
            {
                ((Label)ctrl).Text = missingQuals;
                ((Label)ctrl).Visible = true;
            }
           
        }
         
    }

    private void ShowCDR(GridViewRow currentRow, string qualFieldName, int qualValueCellIndex)
    {
        foreach (Control ctrl in currentRow.Cells[qualValueCellIndex].Controls)
        {
            if (!string.IsNullOrEmpty(ctrl.ID) && !ctrl.ID.ToLower().EndsWith(qualFieldName.ToLower()))
            {
                ctrl.Visible = false;
            }
        }
    }

    protected string GetParams(string recordId)
    {
        USClientLinkParams param = new USClientLinkParams();
        param["ObjectID"] = recordId;
        return param.ToString();
    }

    protected string GetTargetPage()
    {
        return "Customs/pages/edit/AutoRoleAssignDetail.aspx";
    }

    #endregion Helper Functions
}