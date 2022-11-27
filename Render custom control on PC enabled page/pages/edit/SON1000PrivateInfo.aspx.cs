
using System;

using System.Collections.Generic;

using System.Linq;

using System.Web;

using System.Web.UI;

using System.Web.UI.WebControls;

using UltimateSoftware.DataAccessLayer;

using UltimateSoftware.WebControls;

  

public partial class SON1000PrivateInfo_aspx : USPage

{

 protected void Page_Load(object sender, EventArgs e)

 {

 }

  

 protected void InitSPParamsEthnicCodes(object sender, EventArgs e)

 {

 csIntlEthnicID.Parameters["@EEID"].Value = Master.EEID;

  

 String intlEthnicID = new CompanyDataAccessControl(Master.UserContext).CallScalarStoredProcedure<string>("U_SON1000_GetIntEthnicID", new object[] { Master.EEID });

 if (!IsPostBack)

 csIntlEthnicID.Code = String.IsNullOrEmpty(intlEthnicID) ? String.Empty : intlEthnicID;

 }

}