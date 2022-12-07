<%@ Page Language="C#" MasterPageFile="~/PopupViewOnly.master" CodeFile="DebitTipConsentPopUp.aspx.cs" AutoEventWireup="true"
    ValidateRequest="false" Inherits="DebitTipConsentPopUp_aspx" Title="Untitled Page" %>

<%@ MasterType VirtualPath="~/PopupViewOnly.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" runat="server">
<%-- ************************************************************************** 
Company:		  Ultimate Software Corp. 
Author:		      Adrian Serrano
Client:		      Lazy Dog Restaurants, LLC
Date:		      1/28/2020
Request:		  SR-2019-00245269
Purpose:		  Instant Pay Direct Deposit (from scope project SR-2019-00233967)
Last Modified: 
**************************************************************************  --%> 
    <div>
        <asp:Literal ID="liAckText" runat="server"></asp:Literal>
    </div>
    <div id="div1Popup" runat="server" class="twoCol">
        <table>
            <tr>
                <td id="tdChkAgree" class="required">
                    <asp:CheckBox ID="chkAgree" required="true" runat="server" Text="I agree to the above" />
                </td>
            </tr>
            <tr id="trInitials">
                <td class="required">
                    <asp:Label ID="lblInitials" runat="server" Text="Full Legal Name: "></asp:Label>
                </td>
                <td>
                    <asp:TextBox ID="txtInitials" required="true" runat="server"></asp:TextBox>
                </td>
            </tr>
            <tr>
                <td>
                    <asp:Label ID="Label1" runat="server" Text="Date Signed: "></asp:Label>
                </td>
                <td>
                    <asp:Label ID="lblDate" runat="server"></asp:Label>
                </td>
            </tr>
        </table>
    </div>
</asp:Content>
