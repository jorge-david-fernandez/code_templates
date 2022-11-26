using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Text;
using System.Web.UI;
using UltimateSoftware.WebControls;
using UltimateSoftware.WebObjects;

//--------------------------------------------------------------------------
// Initial Author       :		Marta Seoane (MS) 
// Client               :		OSI Restaurant Partners LLC (OSI1001) 
// Date                 :		11/30/2011 
// File Name            :		\UltiProNet\Customs\USG\usercontrols\ErecPendingHires.ascx.cs
//
// Customization History:
// 11/30/11 - MS  - CS-2011-46650 - Process Pending New Hires Filter by Imported ID field
// 01/09/12 - DCW - CS-2011-46571 - New Hire Custom: Send new parameter to hirewizard so knows called from MSS or EEADM, since core always sends PK=MSS.
// 03/08/12 - DCW - CS-2011-46650 - Modify the filtering by Imported ID field so pulls in applicants imported by other users at same unit or district.
// 03/28/12 - DCW - CS-2011-46650 - Modify so filtering kicks in even for EEADM, because we need Home Office manager users to use EEADM Process Hires due to the nature of New Hire customs
// 12/29/14 - KTP - SR-2014-00032842 - Process Pending New Hires Modification.  
//--------------------------------------------------------------------------

// MS 11/30/2011: Begin   >> CS-2011-46650 - NET Process Pending New Hires Filter by Imported ID Field 
using UltimateSoftware.ObjectModel.Objects;
using UltimateSoftware.Data;
using UltimateSoftware.DataAccessLayer;
using UltimateSoftware.ObjectModel.Common;
// MS 11/30/2011: End   >> CS-2011-46650 - NET Process Pending New Hires Filter by Imported ID Field 

public partial class PendHire_aspx : USPage
{
    protected CodeDescLabel translator;
    private bool _noDataBind = true;
    private JQGridDataHelper jqDataHelper;

    private enum PhGridColumns
    {
        Name = 1,
        Requisition = 2,
        Company = 3,
        Opportunity = 4,
        Start = 5,
        Imported = 6,
        ImportedBy = 7,
        GlobalEe = 8
    }

    private void SetupJQGrid()
    {
        //KTP 12/29/2014 - Custom 32842 - Start
        if (!UserHasAdminRole())
        {
            if (PendHireGrid != null)
            {
                foreach (Trirand.Web.UI.WebControls.JQGridColumn d in PendHireGrid.Columns)
                {
                    if (d.DataField == "PXImportedBy")
                    {
                        d.Editable = false;
                    }
                }
            }   
        }
        //KTP 12/29/2014 - Custom 32842 - End

        JQGridHelperArgs args = new JQGridHelperArgs
        {
            Grid = PendHireGrid,
            Datasource = PendHireDS,
            TypeName = "PendHire"
        };

        jqDataHelper = new JQGridDataHelper(args, Master);
        jqDataHelper.RecoverUSParameters(Master.SessionID);
    }
	
    protected void PendHireDS_GetObjectParams(object sender, GetObjectParamsEventArgs e)
    {

        e.Parameters.Add("CompanyId", Master.UserContext.ClientID);
    }

    void Page_Load(object sender, EventArgs e)
    {
        SetupJQGrid();
        Master.ToolbarButtons.Restore.Enabled = false;
        Master.ToolbarButtons.Restore.Visible = false;
    }

    protected override void OnDelete(ToolBarEventArgs tbea)
    {

    }

    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);
        jqDataHelper.PerformSelection();


        // MS 11/30/2011: Begin   >> CS-2011-46650 - NET Process Pending New Hires Filter by Imported ID Field 
        if (!UserHasAdminRole()){
            List<DataItem> pendList = jqDataHelper.DataProvider.GetDataItemList();
            List<DataItem> newList = new List<DataItem>();
            if (pendList.Count > 0)
            {
                //DCW 03/08/12 - Add call to get filtered list of SystemId's, and use that to determine whether to remove pendhire from list
                //Previously, ImportedBy was used.  Now, a stored procedure considers user's role, and potentially gathers SystemID's for multiple ImportedBy's,
                //all those at the same unit, or district if it's a JVP user.
                Dictionary<string, int> dctPendHires = GetFilteredListOfPendHireSystemIDs();
                for (int i = 0; i < pendList.Count; i++)
                {
                    ProcessHires hire = (ProcessHires)pendList[i].data;
                    //USC-CS-AR
                    //Previously we were removing from a list but now if the keys wre not equal, but now we are adding the rows that match
                    if (dctPendHires.ContainsKey(hire.SystemID))
                    {
                        newList.Add(pendList[i]);
                    }
                }                                              
                //Append the newList to the grid and bind
                PendHireGrid.DataSource = newList;
                PendHireGrid.DataBind();
            }                    
        }
        // MS 11/30/2011: Begin   >> CS-2011-46650 - NET Process Pending New Hires Filter by Imported ID Field 
    }

    protected override void Render(HtmlTextWriter writer)
    {
        if (_noDataBind)
        {
            base.Render(writer);
        }
    }

    protected String GetNewHireParams(string systemID)
    {
        var param = new USClientLinkParams();
        param["PendHireSystemID"] = systemID;
        param["isPendHire"] = "true";
        param["Mode"] = "ADD";

        //--------------- DCW 01/09/12 - CUSTOM: OSI New Hire Custom (CS-2011-46571) - BEGIN -----------------
        //Since core always sends PK as MSS no matter where we're coming from (EREC, MSS, or EEADM),
        //send a new custom parameter to tell newhire wizard that we can from MSS Pending Hire page.
        if (Master.ProductKey.Equals(ProductKeysEnum.MSS.ToString(), StringComparison.OrdinalIgnoreCase))
        {
            param["cstmMssPndHr"] = "Y";
        }
        else
        {
            param["cstmMssPndHr"] = "N";
        }
        //--------------- DCW 01/09/12 - CUSTOM: OSI New Hire Custom (CS-2011-46571) - END -------------------
        return param.ToString();
    }

    protected string GetParams()
    {
        return string.Empty;
    }

    protected void PendHireGrid_CellBinding(object sender, Trirand.Web.UI.WebControls.JQGridCellBindEventArgs e)
    {
        int rowindex = 0;
        for (var i = 0; i < e.RowValues.Length; i++)
        {
            if (e.RowValues[i].GetType() == typeof(UltimateSoftware.ObjectModel.Objects.ProcessHires))
            {
                rowindex = i;
            }
        }

        if (e.ColumnIndex == (int) PhGridColumns.Name)
        {
            var sb = new StringBuilder();
            var writer = new HtmlTextWriter(new StringWriter(sb));
            var clientLink = new USClientLink();
            clientLink.ID = "clientLink1";
            clientLink.TargetPage = "pages/EDIT/eeHireStart.aspx";
            string fullname = ((UltimateSoftware.ObjectModel.Objects.ProcessHires) (e.RowValues[rowindex])).FullName.Trim();
            clientLink.Text = fullname;
            clientLink.Params = GetNewHireParams(((UltimateSoftware.ObjectModel.Objects.ProcessHires)(e.RowValues[rowindex])).SystemID);
            clientLink.LinkTypeAttribute = USClientLinkType.WIZARD_POPUP;
            clientLink.Page = this.Page;
            clientLink.WindowParams =
                "directories=no, location=no, menubar=no, resizable=yes, scrollbars=yes, status=yes, toolbar=no, height=600, width=800";
            if (Master.ProductKey.Trim() == "EREC")
            {
                //must override the PK to MSS because New Hire won't launch under EREC. MSS is a prerequisite to the EREC prod key.
                clientLink.PK = "MSS";
            }
            clientLink.JqGridMode = true;
            clientLink.RenderControl(writer);
            string url = sb.ToString();
            url = getStrippedURL(url, "!eeid=");
            url = getStrippedURL(url, "!EEID=");
            e.CellHtml = url;
        }

        if (e.ColumnIndex == (int) PhGridColumns.Company)
        {
            var codeDescParams = new CodeDescParams
            {
                AllCountries = true
            };
            var companyname = Master.GetCodeDesc("COMPANY",
                ((UltimateSoftware.ObjectModel.Objects.ProcessHires)(e.RowValues[rowindex])).CompanyID.ToString(), codeDescParams).Description;
            e.CellHtml = companyname != null && companyname.Contains("unavailable") ? string.Empty : companyname;
        }

    }

    private string getStrippedURL(string stringUrl, string stringName)
    {
        if (stringUrl == null) throw new ArgumentNullException("stringUrl");
        string newUrl = stringUrl;
        if (stringUrl.Contains(stringName))
        {
            var startIndex = stringUrl.IndexOf(stringName);
            int endIndex = -1;
            for (int y = startIndex + 1; y < stringUrl.Length; y++)
            {
                if (stringUrl[y] == '!')
                {
                    endIndex = y;
                    break;
                }
            }
            newUrl = stringUrl.ToString().Remove(stringUrl.ToString().IndexOf(stringName), endIndex - startIndex);
        }
        return newUrl;
    }
    // MS 11/30/2011: Begin   >> CS-2011-46650 - NET Process Pending New Hires Filter by Imported ID Field 
    public void USObjectDataSource_OnAfterObjectLoad(object sender, AfterObjectLoadEventArgs e)
    {
        /*
        //DCW 03/28/12 CHANGE - Do filtering from EEADM as well for now also, because Home Office managers need to use EEADM Process Hires, but need to have filtering in place.  This may change in the future back to way it was, but that is not known yet.  For now, this is the change.
        //OLD: if (MasterPage.ProductKey == ProductKeysEnum.MSS.ToString() && !UserHasAdminRole())
        if (!UserHasAdminRole())
        {
            USObjectDataSource ds = sender as USObjectDataSource;
            if (ds != null)
            {
                if (ds.GetDataItem() != null)
                {
                    bool rebind = false;
                    
                    //DCW 03/08/12 - Add call to get filtered list of SystemId's, and use that to determine whether to remove pendhire from list
                    //Previously, ImportedBy was used.  Now, a stored procedure considers user's role, and potentially gathers SystemID's for multiple ImportedBy's,
                    //all those at the same unit, or district if it's a JVP user.
                    
                    Dictionary<string,int> dctPendHires = GetFilteredListOfPendHireSystemIDs();

                    PendHireList pendList = ((PendHireDataItem)ds.GetDataItem()).DataItemList as PendHireList;
                    foreach (PendHire hire in pendList)
                    {
                        if (!dctPendHires.ContainsKey(hire.SystemID))
                        {
                            pendList.Remove(hire);
                            rebind = true;
                        }
                    }

                    if (rebind)
                    {
                        //grdPendHire.DataBind();
                    }
                }
            }
        }*/
    }
    
    private Dictionary<string,int> GetFilteredListOfPendHireSystemIDs()
    {
        Dictionary<string,int> dctPendHires = new Dictionary<string,int>();
        int systemID = 0;
        
        using (DataCommand cmd = new DataCommand())
        {
            cmd.ConnectionInfo = Master.ConnectionInfo;
            
            cmd.SQL = "EXEC dbo.U_OSIRP_PendingHires_GetFilteredList @EEID, @COID";
            
            cmd.SqlParameters.Add("@EEID", SqlDbType.VarChar, Master.EEID);
            cmd.SqlParameters.Add("@COID", SqlDbType.VarChar, Master.COID);
            
            using (SqlDataReader reader = cmd.ExecuteReader())
            {
                while (reader.Read())
                {
                    systemID = reader.GetInt32(0);
                    dctPendHires.Add(systemID.ToString(),systemID);
                }
            }
        }
        
        return dctPendHires;
    }

    private bool UserHasAdminRole()
    {
        return Convert.ToBoolean(new CompanyDataAccessControl(MasterPage.UserContext).CallScalarStoredProcedure<int>("U_OSI_UserHasAdminRole", new object[] { MasterPage.UserContext.EEID }));
    }

    // MS 11/30/2011: End   >> CS-2011-46650 - NET Process Pending New Hires Filter by Imported ID Field 
    // Modified on   4/27/2012 5:07 PM Release Number:10.6.1  ---USC-CS-AR
}