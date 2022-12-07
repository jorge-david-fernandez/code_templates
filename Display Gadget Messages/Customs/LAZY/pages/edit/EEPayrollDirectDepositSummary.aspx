<%@ Page Language="C#" MasterPageFile="~/Process.master" CodeFile="EePayrollDirectDepositSummary.aspx.cs" Inherits="EePayrollDirectDepositSummary_aspx" %>
<%@ MasterType VirtualPath="~/Process.master" %>
<%--<%@ Register TagPrefix="uc1" TagName="eePayrollDirectDepositSummary" Src="~/usercontrols/eePayrollDirectDepositSummary.ascx" %>--%>
<%@ Register TagPrefix="uc1" TagName="eePayrollDirectDepositSummary" Src="../../usercontrols/LAZ1001_eePayrollDirectDepositSummary.ascx" %>
<asp:Content ID="Content1" ContentPlaceHolderID="Content" runat="server">

<script type="text/javascript">
  // moved page-side
  //var CurrentDDAPreference = '<asp:Literal runat="server" id="litCurrentDDAPreference" />';
  //var CurrentDDAPreferenceCompMast = '<asp:Literal runat="server" id="litCurrentDDAPreferenceCompMast" />'; 
  $(document).ready(
      function () {
          pr.payrollDirectDepositSummary.initializePage();
      }
  );
</script>
    <%-- ************************************************************************** 
    Company:		  Ultimate Software Corp. 
    Author:		      Adrian Serrano
    Client:		      Lazy Dog Restaurants, LLC
    Date:		      12/3/2019
    Request:		  SR-2019-00245269
    Purpose:		  Instant Pay Direct Deposit (from scope project SR-2019-00233967)
    Last Modified: 
    **************************************************************************  --%> 
<usweb:USActions runat="server" ID="MyAction">
  <usweb:USPageAction ID="PageAction" runat="server">    </usweb:USPageAction>
</usweb:USActions>

<div class="fullLayout">
<%-- --------------------- CUSTOMS BEGIN - AdrianSerrano (SR-2019-00245269) --------------------- --%>
    <div id="divInformation" class="info" runat="server" style="display:none">
	    <h3>Information</h3>
        <asp:Literal ID="liMessage" runat="server"></asp:Literal>
    </div>
<%-- --------------------- CUSTOMS END - AdrianSerrano (SR-2019-00245269) --------------------- --%>
  <usweb:LocalizedLabel ID="lblPayStatementPreference" runat="server" Alias="PayStatementPreference" />&nbsp;
  <usweb:USClientLink id="clDDAPreference" runat="server" 
    Params="<%# GetClientLinkParams()%>"
    LinkTypeAttribute="USClientLinkType.STANDARD" 
    Text='Electronic Only' 
    TargetPage="pages/edit/EeDDAPreference.aspx">
  </usweb:USClientLink>
  <br />
</div>
<uc1:eePayrollDirectDepositSummary id="uc_eePayrollDirectDepositSummary" runat="server" />
</asp:Content>