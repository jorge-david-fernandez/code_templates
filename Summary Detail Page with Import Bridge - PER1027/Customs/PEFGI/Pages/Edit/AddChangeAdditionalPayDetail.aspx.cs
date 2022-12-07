/// <Header summary>
///Company:		  UKG
///Author:		  Stela Garkova
///Client:		  Performance Food Group, Inc.
///Date:		  8/8/2022
///Request:		  SR-2022-00363993
///Purpose:		  Web administrator page for GL custom table for mapping for Org Levels
///Last Modified: 

/// </Header summary>
using System;
using System.Collections.Generic;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;
using UltimateSoftware.Diagnostics.Common;
using UltimateSoftware.WebControls;
using UltimateSoftware.DataAccessLayer;

public partial class Customs_PER1027_AddChangeAdditionalPayDetail : USPage
{
    protected string RecID
    {
        get { return Master.Parameters["RecID"]; }
    }

    protected string PayDate
    {
        get { return Master.Parameters["PayDate"]; }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        Master.PageHeader = Master.GetString("U_AddlPay_AddChangeitionalPayHeader");
        Master.ToolbarButtons.Help.Visible = false;
        Master.PageMode += PageModeType.Editable;

        if (!IsPostBack)
        {
            if(!string.IsNullOrWhiteSpace(RecID))
                LoadDetailsForEdit();

            calPayDate.Value = PayDate;
        }
    }

    protected override void OnCancel(ToolBarEventArgs tbea)
    {
        //Remove edit parameters and Transfer
        Master.Parameters.Remove("RecID");
        Server.Transfer(string.Format("AdditionalPayDetailDetail.aspx?{0}", USParams.MakeUSParamsQueryString(Master.Parameters)));
    }

    private void GoBack()
    {
        //Remove edit parameters and Transfer
        Master.Parameters.Remove("RecID");
        Master.Parameters.Remove("PayDate");
        Server.Transfer("AdditionalPayDetailSummary.aspx");
    }

    protected override void OnSave(ToolBarEventArgs tbea)
    {
        if (SaveRecord())
        {
            //Remove edit parameters and Transfer
            GoBack();
        }
    }

    private void LoadDetailsForEdit()
    {
        int intRecId = 0;
        if (int.TryParse(RecID, out intRecId))
        {
            using (DataCommand cmd = new DataCommand())
            {
                cmd.ConnectionInfo = Master.ConnectionInfo;
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.SQL = "dbo.U_PER1027_AdditionalPayDetail_Get";
                cmd.SqlParameters.Add("@RecID", SqlDbType.Int, RecID);

                try
                {
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            calPayDate.Value = Convert.ToString(reader["uapPayDate"]).Trim();
                            calWeekEndDate.Value = Convert.ToString(reader["uapWeekEndDate"]);
                            txtDescription.Text = Convert.ToString(reader["uapDesc"]).Trim();
                            txtHours.Text = Convert.ToString(reader["uapHours"]);
                            txtUnits.Text = Convert.ToString(reader["uapUnits"]);
                            txtRate.Text = Convert.ToString(reader["uapRate"]);
                            txtSales.Text = Convert.ToString(reader["uapSales"]);
                            txtProfit.Text = Convert.ToString(reader["uapProfit"]);
                            txtSupplemental.Text = Convert.ToString(reader["uapSupplemental"]);
                            txtNotes.Text = Convert.ToString(reader["uapNotes"]);
                        }
                    }
                }
                catch (Exception ex)
                {
                    LogEntry log = new LogEntry();
                    log.Message = "Error retrieving data";// + ex.Message;
                    Master.AddError(log, ErrorSeverity.Error);
                    Master.WriteOutErrors();
                }
            }
        }
    }

    private bool RecordValidation()
    {
        bool result = true;

        if (String.IsNullOrEmpty(txtHours.Text.Trim()) &&
            String.IsNullOrEmpty(txtRate.Text.Trim()) &&
            String.IsNullOrEmpty(txtUnits.Text.Trim()) &&
            String.IsNullOrEmpty(txtSales.Text.Trim()) &&
            String.IsNullOrEmpty(txtProfit.Text.Trim()) &&
            String.IsNullOrEmpty(txtSupplemental.Text.Trim()))
        {
            LogEntry log = new LogEntry();
            log.Message = "You must enter a value in at least one of the following fields:  Hours, Rate, Units, Profit, Sales, Supplemental. You must enter the appropriate field(s) before you can continue.";
            Master.AddError(log, ErrorSeverity.Error);
            Master.WriteOutErrors();
            result = false;
        }

        return result;
    }

    private bool SaveRecord()
    {
        if (RecordValidation())
        {
            using (DataCommand cmd = new DataCommand())
            {
                cmd.ConnectionInfo = Master.ConnectionInfo;
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.SQL = "dbo.U_PER1027_AdditionalPayDetail_Save";

                cmd.SqlParameters.Add("@EmployeeEEID", SqlDbType.Char, Master.EEID);
                cmd.SqlParameters.Add("@EmployeeCOID", SqlDbType.Char, Master.COID);
                cmd.SqlParameters.Add("@AdminEEID", SqlDbType.Char, Master.UserContext.EEID);
                if (!string.IsNullOrWhiteSpace(RecID))
                {
                    cmd.SqlParameters.Add("@RecID", SqlDbType.Int, RecID);
                }
                cmd.SqlParameters.Add("@PayDate", SqlDbType.DateTime, calPayDate.Value);
                cmd.SqlParameters.Add("@WeekEndDate", SqlDbType.DateTime, calWeekEndDate.Value);
                cmd.SqlParameters.Add("@Desc", SqlDbType.VarChar, txtDescription.Text.Trim());
                cmd.SqlParameters.Add("@Hours", SqlDbType.VarChar, txtHours.Text.Trim());
                cmd.SqlParameters.Add("@Units", SqlDbType.VarChar, txtUnits.Text.Trim());
                cmd.SqlParameters.Add("@Rate", SqlDbType.VarChar, txtRate.Text.Trim());
                cmd.SqlParameters.Add("@Sales", SqlDbType.VarChar, txtSales.Text.Trim());
                cmd.SqlParameters.Add("@Profit", SqlDbType.VarChar, txtProfit.Text.Trim());
                cmd.SqlParameters.Add("@Supplemental", SqlDbType.VarChar, txtSupplemental.Text.Trim());
                cmd.SqlParameters.Add("@Notes", SqlDbType.VarChar, txtNotes.Text.Trim());

                try
                {
                    string returnMessage = (string)cmd.ExecuteScalar();
                    if (!string.IsNullOrWhiteSpace(returnMessage))
                    {
                        LogEntry log = new LogEntry();
                        log.Message = returnMessage;
                        Master.AddError(log, ErrorSeverity.Error);

                        return false;
                    }
                }
                catch (Exception ex)
                {
                    LogEntry log = new LogEntry();

                    log.Message = "Error saving. " + ex.Message;
                    Master.AddError(log, ErrorSeverity.Error);
                    Master.WriteOutErrors();

                    return false;
                }
            }
            return true;
        }
        return false;
    }
}