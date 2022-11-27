/// <Header summary>
///Company:		  Ultimate Software Corp. 
///Author:		  Jordan Farinas
///Client:		  Vectrus Systems Corporation
///Date:		  6/4/2020
///Request:		  SR-2020-00274177
///Purpose:		  Modify Pending Pay - Allow for entry of Org Level 1 (Activity)
///Last Modified: 

/// </Header summary>

using UltimateSoftware.WebControls;
using System;

public partial class CustomCompanyFinder_aspx : BaseCustomFinderPage
{
    public override IUSGrid GridView
    {
        get
        {
            return this.USGridView1;
        }
    }

    public override FinderPageOptions FinderOptions
    {
        get
        {
            return new FinderPageOptions
            {
                CodeColumnIndex = 0,
                DescColumnIndex = 1
            };
        }
    }

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
    }
    protected void Page_Load()
    {
        Master.WindowTitle = Master.GetString("UltiPro");
        Master.Toolbar = false;
        Master.SuppressContentBoxes = true;
    }

}
