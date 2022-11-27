/// <Header summary>
///Company:		  Ultimate Software Corp. 
///Author:		  Jordan Farinas
///Client:		  Vectrus Systems Corporation
///Date:		  6/4/2020
///Request:		  SR-2020-00274177
///Purpose:		  Modify Pending Pay - Allow for entry of Org Level 1 (Activity)
///Last Modified: 

/// </Header summary>

using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using UltimateSoftware.WebControls;
using UltimateSoftware.Common;
using System.Text;
using Microsoft.Security.Application;

public partial class CustomUSSuperFinder_aspx : USPage
{
    //public override IUSGrid GridView
    //{
    //    get
    //    {
    //        return this.USGridView1;
    //    }
    //}

    ////public override FinderPageOptions FinderOptions
    ////{
    ////    get
    ////    {
    ////        return new FinderPageOptions
    ////        {
    ////            CodeColumnIndex = 0,
    ////            DescColumnIndex = 1,
    ////            CompanyColumnIndex = 2
    ////        };
    ////    }
    ////}

    //protected override void OnInit(EventArgs e)
    //{
    //    base.OnInit(e);
    //}
    protected void Page_Load()
    {
        Master.WindowTitle = Master.GetString("UltiPro");
        Master.Toolbar = false;
        Master.SuppressContentBoxes = true;
        litCodeSelectorID.Text = AntiXss.JavaScriptEncode(Master.Parameters["codeSelectorID"]);
        litHiddenID.Text = AntiXss.JavaScriptEncode(Master.Parameters["hiddenID"]);

        // Write out Javascript for callback function
        //StringBuilder sbScripts = new StringBuilder();
        //sbScripts.Append("<script type=\"text/javascript\">");
        //sbScripts.Append("var codeSelectorID=" + Microsoft.Security.Application.Encoder.JavaScriptEncode(Master.Parameters["codeSelectorID"]) + ";");
        //sbScripts.Append("var hiddenID=" + Microsoft.Security.Application.Encoder.JavaScriptEncode(Master.Parameters["hiddenID"]) + ";");
        //sbScripts.Append("</script>");
    }

}
