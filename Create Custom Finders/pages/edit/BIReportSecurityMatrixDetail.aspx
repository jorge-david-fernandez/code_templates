<%@ Page Language="C#" MasterPageFile="~/Content.master" CodeFile="BIReportSecurityMatrixDetail.aspx.cs" Inherits="BIReportSecurityMatrixDetail_aspx" %>

<%@ Import Namespace="UltimateSoftware.Data" %>
<%@ Register TagPrefix="asp" Namespace="System.Web.UI.WebControls" %>
<%@ MasterType VirtualPath="~/Content.master" %>
<asp:Content ID="Content1" ContentPlaceHolderID="Content" runat="server">
    <!-- ************************************************************************** 
Company:		  UKG
Author:		      Jorge David Fernandez
Client:		      Sony Pictures Entertainment Inc.
Date:		      3/5/2021
Request:		  SR-2021-00303642
Purpose:		  Web Admin for BI Reporting Security Matrix Custom Screen and Tables
Last Modified: 
**************************************************************************  -->
    <div class="oneCol">
        <table border="0" cellspacing="0" cellpadding="5">
            <tr>
                <td height="30px">
                    <usweb:LocalizedLabel ID="llbReportName" Alias="L_SON1003_ReportName" runat="server" /></td>
                <td>&nbsp;</td>
                <td class="required">
                    <usweb:CodeSelector ID="csReportName" runat="server" CodeTableName="CO_BIReportNames" DisplayMethod="CodeDashDescription" required="true" />
                </td>
            </tr>
            <tr>
                <td height="30px">
                    <usweb:LocalizedLabel ID="llbEffectiveStartDate" Alias="L_SON1003_EffectiveStartDate" runat="server" /></td>
                <td>&nbsp;</td>
                <td class="required">
                    <usweb:USCalendar ID="calEffectiveStartDate" runat="server" required="true" />
                </td>
            </tr>
            <tr>
                <td height="30px">
                    <usweb:LocalizedLabel ID="llbUserName" Alias="L_SON1003_UserName" runat="server" /></td>
                <td>&nbsp;</td>
                <td class="required">
                    <%--<usweb:USSuperFinder ID="supUserName" runat="server" required="true" />--%>
                    <usweb:USCustomFinder ID="fndrUSSuperFinder" runat="server" Enabled="true" Visible="true" DisplayMethod="Description" ClientOnChangeCallback="PopulateCustomLabel(this);" />
                </td>
            </tr>
            <tr>
                <td height="30px">
                    <usweb:LocalizedLabel ID="llbReportCompany" Alias="L_SON1003_ReportCompany" runat="server" /></td>
                <td>&nbsp;</td>
                <td>
                    <usweb:USCustomFinder ID="fndrCompany" runat="server" Enabled="true" Visible="true" DisplayMethod="CodeDashDescription" ClientOnChangeCallback="PopulateCustomLabel(this);" />
                    <%--<usweb:CodeSelector ID="csReportCompany" runat="server" CodeTableName="COMPANY" IncludeOnlyCountries="USA,CAN" DisplayMethod="CodeDashDescription" />--%>
                </td>
            </tr>
            <tr>
                <td height="30px">
                    <usweb:LocalizedLabel ID="llbSAPCompany" Alias="L_SON1003_SAPCompany" runat="server" /></td>
                <td>&nbsp;</td>
                <td>
                    <usweb:USCustomFinder ID="fndrOrgLvl1" runat="server" Enabled="true" Visible="true" DisplayMethod="CodeDashDescription" ClientOnChangeCallback="PopulateCustomLabel(this);" />
                </td>
            </tr>
            <tr>
                <td height="30px">
                    <usweb:LocalizedLabel ID="llbCostCenter" Alias="L_SON1003_CostCenter" runat="server" /></td>
                <td>&nbsp;</td>
                <td>
                    <%--<usweb:CodeSelector ID="csCostCenter" runat="server" CodeTableName="ORGLVL3" DisplayMethod="CodeDashDescription" />--%>
                    <usweb:USCustomFinder ID="fndrOrgLvl3" runat="server" Enabled="true" Visible="true" DisplayMethod="CodeDashDescription" ClientOnChangeCallback="PopulateCustomLabel(this);" />
                </td>
            </tr>
            <tr>
                <td height="30px">
                    <usweb:LocalizedLabel ID="llbEffectiveStopDate" Alias="L_SON1003_EffectiveStopDate" runat="server" /></td>
                <td>&nbsp;</td>
                <td>
                    <usweb:USCalendar ID="calEffectiveStopDate" runat="server" />
                </td>
            </tr>
        </table>
        <br />
        <asp:Label ID="lbPolicy" runat="server" />
    </div>
    <asp:HiddenField ID="PageMode" runat="server" />
</asp:Content>
