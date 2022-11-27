<%@ Page Language="C#" MasterPageFile="~/Content.master" CodeFile="SON1000PrivateInfo.aspx.cs" Inherits="SON1000PrivateInfo_aspx" Title="Untitled Page" %>

  

<%@ MasterType VirtualPath="~/Content.master" %>

  

<asp:Content ID="Content1" ContentPlaceHolderID="Content" runat="server">

 <div id="divCustom">

 <div id="divIntlEthnicity" runat="server" class="legacy-control control-group">

 <usweb:LocalizedLabel ID="llbIntlEthnicID" runat="server" Alias="EthnicGroup" Casing="Title" />

 <div class="controls">

 <div class="required">

 <usweb:CodeSelector ID="csIntlEthnicID" runat="server" CodeTableName="U_SON1000_ETHNICID" OnPreRender="InitSPParamsEthnicCodes"

 DisplayMethod="Description" required="true" />

 </div>

 <usweb:USSpan ID="spnLocation" runat="server"></usweb:USSpan>

 </div>

 </div>

 </div>

</asp:Content>
