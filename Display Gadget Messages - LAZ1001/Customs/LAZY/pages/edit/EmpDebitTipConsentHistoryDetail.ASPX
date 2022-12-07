<%@ Page Language="C#" MasterPageFile="~/Content.master" CodeFile="EmpDebitTipConsentHistoryDetail.ASPX.CS" Inherits="Customs_LAZ1001_Pages_Edit_EmpDebitTipConsentHistoryDetail_aspx" %>

<%@ MasterType VirtualPath="~/Content.master" %>
<asp:Content ID="Content1" ContentPlaceHolderID="Content" runat="server">
    <!-- ************************************************************************** 
Company:		  Ultimate Software Corp. 
Author:		      Jorge David Fernandez
Client:		      Lazy Dog Restaurants, LLC
Date:		      10/2/2019
Request:		  SR-2019-00245269
Purpose:		  Instant Pay Direct Deposit (from scope project SR-2019-00233967)
Last Modified: 
**************************************************************************  -->
    <usweb:DataSource
        ID="dsDebitTipConsentHistory"
        runat="server"
        StoredProcName="dbo.U_LAZ1001_GetDebitTipConsentHistoryDetails"
        EnableSqlServerPaging="false" />

    <usweb:USFormView runat="server" ID="frmDebitTipConsentDetails" DataSourceID="dsDebitTipConsentHistory">
        <ItemTemplate>
            <div style="padding-bottom:20px">
                <asp:Label ID="liAckText" runat="server" Text='<%# Eval("udaConsentMessage").ToString() %>'></asp:Label>
            </div>
            <div id="divConsent" runat="server" class="twoCol">
                <table>
                    <tr>
                        <td id="tdChkAgree">
                            <asp:CheckBox ID="chkAgree" runat="server" Text="I agree to the above" Checked='<%# Eval("udaAcknowledge").ToString().Equals("Y") %>' Enabled="false" />
                        </td>
                    </tr>
                    <tr id="trInitials">
                        <td>
                            <asp:Label ID="lblInitials" runat="server" Text="Signature: "></asp:Label>
                        </td>
                        <td>
                            <asp:Label ID="txtInitials" runat="server" Text='<%# Eval("udaInitials").ToString() %>'></asp:Label>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <asp:Label ID="Label1" runat="server" Text="Date Signed: "></asp:Label>
                        </td>
                        <td>
                            <asp:Label ID="lblDate" runat="server" Text='<%# Eval("udaDateSigned").ToString() %>'></asp:Label>
                        </td>
                    </tr>
                </table>
            </div>
        </ItemTemplate>
    </usweb:USFormView>
</asp:Content>
