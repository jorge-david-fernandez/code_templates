<%@ Page Language="C#" MasterPageFile="~/Content.master" CodeFile="AddChangeAdditionalPayDetail.aspx.cs" Inherits="Customs_PER1027_AddChangeAdditionalPayDetail" %>

<%-- ************************************************************************** 
Company:		  UKG
Author:		      Stela Garkova
Client:		      Performance Food Group, Inc.
Date:		      8/9/2022
Request:		  SR-2022-00363993
Purpose:		  Web administrator page for GL custom table for mapping for Org Levels
Last Modified: 
**************************************************************************  --%>
<%@ MasterType VirtualPath="~/Content.master" %>
<asp:Content ID="Content1" ContentPlaceHolderID="Content" runat="server">
    <script type="text/javascript">
        $(function () {
            initForm(document.getElementById('aspnetForm'));
        });
    </script>
    <div class="oneCol">
        <table border="0" cellspacing="0" cellpadding="5">
            <tr>
                <td>
                    <usweb:LocalizedLabel ID="llbPayDate" runat="server" Alias="U_AddlPay_PayDate" /></td>
                <td class="required">
                    <usweb:USCalendar ID="calPayDate" runat="server" required="true"></usweb:USCalendar>
                </td>
            </tr>
            <tr>
                <td>
                    <usweb:LocalizedLabel ID="llbWeekEndDate" runat="server" Alias="U_AddlPay_WeekEndDate" /></td>
                <td class="required">
                    <usweb:USCalendar ID="calWeekEndDate" runat="server" required="true"></usweb:USCalendar>
                </td>
            </tr>
            <tr>
                <td>
                    <usweb:LocalizedLabel ID="llbDescription" Alias="Description" runat="server" /></td>
                <td class="required">
                    <asp:TextBox runat="server" ID="txtDescription" Required="true" autocomplete="off" /></td>
            </tr>
            <tr>
                <td>
                    <usweb:LocalizedLabel ID="llbHours" runat="server" Alias="U_AddlPay_Hours" /></td>
                <td>
                    <asp:TextBox runat="server" ID="txtHours" ustyle="RATE2" /></td>
            </tr>
            <tr>
                <td>
                    <usweb:LocalizedLabel ID="llbUnits" runat="server" Alias="U_AddlPay_Units" /></td>
                <td>
                    <asp:TextBox runat="server" ID="txtUnits" autocomplete="off" ustyle="INT" /></td>
            </tr>
            <tr>
                <td>
                    <usweb:LocalizedLabel ID="llbRate" runat="server" Alias="U_AddlPay_Rate" /></td>
                <td>
                    <asp:TextBox runat="server" ID="txtRate" autocomplete="off" ustyle="RATE2" /></td>
            </tr>
            <tr>
                <td>
                    <usweb:LocalizedLabel ID="llbSales" runat="server" Alias="U_AddlPay_Sales" /></td>
                <td>
                    <asp:TextBox runat="server" ID="txtSales" autocomplete="off" ustyle="INT" /></td>
            </tr>
            <tr>
                <td>
                    <usweb:LocalizedLabel ID="llbProfit" runat="server" Alias="U_AddlPay_Profit" /></td>
                <td>
                    <asp:TextBox runat="server" ID="txtProfit" ustyle="RATE2" /></td>
            </tr>
            <tr>
                <td>
                    <usweb:LocalizedLabel ID="llbSupplemental" runat="server" Alias="U_AddlPay_Supplemental" /></td>
                <td>
                    <asp:TextBox runat="server" ID="txtSupplemental" autocomplete="off" ustyle="RATE2" /></td>
            </tr>
            <tr>
                <td>
                    <usweb:LocalizedLabel ID="llbNotes" runat="server" Alias="U_AddlPay_Notes" /></td>
                <td>
                    <asp:TextBox ID="txtNotes" runat="server" TextMode="MultiLine" Columns="30" Rows="10" autocomplete="off" /></td>
            </tr>

        </table>
    </div>
</asp:Content>
