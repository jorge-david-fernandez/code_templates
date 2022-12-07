<%@ Page Language="C#" MasterPageFile="~/Process.master" CodeFile="EePayrollDirectDepositSummaryWiz.aspx.cs" Inherits="EePayrollDirectDepositSummaryWiz_aspx" %>
<%@ MasterType VirtualPath="~/Process.master" %>
<%--<%@ Register TagPrefix="uc1" TagName="eePayrollDirectDepositSummary" Src="~/usercontrols/eePayrollDirectDepositSummary.ascx" %>--%>
<%@ Register TagPrefix="uc1" TagName="eePayrollDirectDepositSummary" Src="../../usercontrols/LAZ1001_eePayrollDirectDepositSummary.ascx" %>

    <%-- ************************************************************************** 
    Company:		  Ultimate Software Corp. 
    Author:		      Adrian Serrano
    Client:		      Lazy Dog Restaurants, LLC
    Date:		      12/3/2019
    Request:		  SR-2019-00245269
    Purpose:		  Instant Pay Direct Deposit (from scope project SR-2019-00233967)
    Last Modified: 
    **************************************************************************  --%> 

<asp:Content ID="Content1" ContentPlaceHolderID="Content" runat="server">
<%-- --------------------- CUSTOMS BEGIN - AdrianSerrano (SR-2019-00245269) --------------------- --%>
    <div id="divInformation" class="info" runat="server" style="display:none">
	    <h3>Information</h3>
        <asp:Literal ID="liMessage" runat="server"></asp:Literal>
    </div>
<%-- --------------------- CUSTOMS END - AdrianSerrano (SR-2019-00245269) --------------------- --%>
<uc1:eePayrollDirectDepositSummary id="uc_eePayrollDirectDepositSummary" runat="server" />
</asp:Content>