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
using System.Data;
using System.Configuration;
using System.Collections;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using UltimateSoftware.WebControls;
using UltimateSoftware.DataAccessLayer;
using UltimateSoftware.Queries.DynamicSQL;

public partial class EeDDAPreference_aspx : USPage
{
	string CmmSuppressAllDDAs = string.Empty;
	string EeSuppressAllDDAs = string.Empty;

	void Page_PreRender(object sender, EventArgs e)
	{
		if (CmmSuppressAllDDAs.Equals("Y", StringComparison.InvariantCultureIgnoreCase) || !Master.ToolbarButtons.Edit.IsAllowed)
		{
			// if DDAs are suppressed then nothing will be in the lightbox except
			// a message. Nothing to SAVE, hide it
			Master.ToolbarButtons.Save.On = false;
            PaperElectronic.Enabled = false;
            ElectronicOnly.Enabled = false;
		}

        // Add the for= for these labels to associate them with the radio button inputs.
        lblElectronicOnly.Attributes.Add("for", ElectronicOnly.ClientID);
        lblPaperAndElectronicCopy.Attributes.Add("for", PaperElectronic.ClientID);
    }

	void Page_Load(object sender, EventArgs e)
	{
        Master.PageMode = PageModeType.Editable;
        Master.ToolbarButtons.Restore.Visible = false;
        Master.ToolbarButtons.Cancel.NavigateUrl = "~/pages/EDIT/EePayrollDirectDepositSummary.aspx";
        Master.ToolbarButtons.Save.NavigateUrl = "~/pages/EDIT/EePayrollDirectDepositSummary.aspx";

        // CUSTOM BEGIN - JDF - SR-2019-00245269
        new CompanyDataAccessControl(Master.UserContext).CallNonQueryStoredProcedure("U_LAZ1001_DefaultElectronicCopies",
            new object[] { Master.EEID });
        // CUSTOM END JDF - SR-2019-00245269

        DataCommand dc = null;

		if (ViewState["EeSuppressAllDDAs"] == null)
		{
			// adhoc query for the correct option selection
			dc = new DataCommand();
			dc.ConnectionInfo = Master.ConnectionInfo;
			string sql = "SELECT EepSuppressDDA FROM emppers WITH (NOLOCK) WHERE eepeeid = @EEID";
			dc.SQL = sql;
			dc.SqlParameters.Add("@EEID", SqlDbType.VarChar, 12, Master.EEID);
			EeSuppressAllDDAs = (string)dc.ExecuteScalar();
			dc.Close();
			ViewState.Add("EeSuppressAllDDAs", EeSuppressAllDDAs);
		}
		else
		{
			EeSuppressAllDDAs = ViewState["EeSuppressAllDDAs"].ToString();
		}

		if (ViewState["CmmSuppressAllDDAs"] == null)
		{
			// adhoc query for the visibility of controls
			dc = new DataCommand();
			dc.ConnectionInfo = Master.ConnectionInfo;
			string ddaSql = "SELECT CmmSuppressALLDDAs FROM compmast WITH (NOLOCK) WHERE CmmCoID = @COID";
			dc.SQL = ddaSql;
			dc.SqlParameters.Add("@COID", SqlDbType.VarChar, 5, Master.Info.Companys.Current.MasterCoid);
			CmmSuppressAllDDAs = (string)dc.ExecuteScalar();
			dc.Close();
			ViewState.Add("CmmSuppressAllDDAs", CmmSuppressAllDDAs);
		}
		else
		{
			CmmSuppressAllDDAs = ViewState["CmmSuppressAllDDAs"].ToString();
		}

		// set the value & visibility (if necessary) else hide it
		if (CmmSuppressAllDDAs.Equals("Y", StringComparison.InvariantCultureIgnoreCase))
		{
			this.MasterPage.PageMode -= PageModeType.Print;

			Master.AddError("DirDepElectDisableMsg", ErrorSeverity.Informational);
			Master.WriteOutErrors();

			ElectronicOnly.Visible = false;
			PaperElectronic.Visible = false;
			receiveFS.Visible = false;
		}
		else
		{
			Master.AddError("DirDepElectMsg", ErrorSeverity.Informational);
			Master.WriteOutErrors();

			//Y = electronic only, no paper
			//N = paper and electronic
			if (EeSuppressAllDDAs.Equals("Y", StringComparison.OrdinalIgnoreCase))
			{
				ElectronicOnly.Checked = true;
				PaperElectronic.Checked = false;
			}
			else
			{
				ElectronicOnly.Checked = false;
				PaperElectronic.Checked = true;
			}
		}
	}
}