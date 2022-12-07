<%@ Page Language="C#" MasterPageFile="~/Process.master" CodeFile="EEW2Consent.aspx.cs"
    Inherits="EEW2Consent_aspx" Title="Untitled Page" %>

<%-- ************************************************************************** 
Company:		  Ultimate Software Corp. 
Author:		      Adrian Serrano
Client:		      Lazy Dog Restaurants, LLC
Date:		      1/28/2020
Request:		  SR-2019-00245269
Purpose:		  Instant Pay Direct Deposit (from scope project SR-2019-00233967)
Last Modified: 
**************************************************************************  --%> 

<%@ MasterType VirtualPath="~/Process.master" %>
<asp:Content ID="Content1" ContentPlaceHolderID="Content" runat="server">
    <usweb:ProcessManager ID="pmConsent" runat="server" ProcessName="EEW2Consent" />
    <usweb:USObjectDataSource ID="objEmployeeIdentification" runat="server" TypeName="UltimateSoftware.WebObjects.IdentificationDataItem"
        SelectMethod="SelectData" UpdateMethod="UpdateData" InsertMethod="InsertData"
        DeleteMethod="DeleteData" DataObjectTypeName="UltimateSoftware.WebObjects.IdentificationDataItem"
        ProcessManagerName="pmConsent" OnGetObjectParams="objEmployeeIdentification_OnGetObjectParams"
        OnSaveObject="objEmployeeIdentification_OnSaveObject" />
    <br />
    <asp:HiddenField ID="hdnShouldAskW2Paperless" Value="false" runat="server"/>
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
            <ContentTemplate>
                <asp:Button ID="updateButton" Style="display: none;" Text="" onclick="UpdateConsent" runat="server"/>
            </ContentTemplate>
        </asp:UpdatePanel>
    <usweb:USFormView ID="fvConsent" runat="server" DataSourceID="objEmployeeIdentification">
        <EditItemTemplate>
            <asp:Panel ID="Panel1" runat="server">
                <h2 class="banner">
                    <%: Master.GetString("USW-2")%>
                </h2>
                <div class="oneCol" >
                    <div>
                        <asp:RadioButton ID="rlUsConsentYes" runat="server" GroupName="rlUsConsent" />
                        <usweb:LocalizedLabel ID="lblUsConsent" runat="server" Alias="W2ConsentElectronic" AssociatedControlID="rlUsConsentYes" />
                        <asp:Image ID="imgUsPaperlessLeaf" runat="server" ImageUrl="~/images/leaf_sm.png" CssClass="bottom" />
                    </div>
                    <div>
                        <asp:RadioButton ID="rlUsConsentNo" runat="server" GroupName="rlUsConsent" />
                        <usweb:LocalizedLabel ID="lblUsNoConsent" runat="server" Alias="W2ConsentPaperElectronic" AssociatedControlID="rlUsConsentNo" />
                    </div>
                </div>
            </asp:Panel>
            <asp:Panel runat="server" Visible='<%# HasPuertoRicoW2(Master.EEID) %>'>
                <h2 class="banner">
                    <%: Master.GetString("PuertoRicoW-2")%>
                </h2>
                <div class="oneCol" >
                    <div>
                        <asp:RadioButton ID="rlPrConsentYes" runat="server" GroupName="rlPrConsent" />
                        <usweb:LocalizedLabel ID="lblPrConsent" runat="server" Alias="W2ConsentElectronic" AssociatedControlID="rlPrConsentYes" />
                        <asp:Image ID="imgPrPaperlessLeaf" runat="server" ImageUrl="~/images/leaf_sm.png" CssClass="bottom" />
                    </div>
                    <div>
                        <asp:RadioButton ID="rlPrConsentNo" runat="server" GroupName="rlPrConsent" />
                        <usweb:LocalizedLabel ID="lblPrNoConsent" runat="server" Alias="W2ConsentPaperElectronic" AssociatedControlID="rlPrConsentNo" />
                    </div>
                </div>
            </asp:Panel>
        </EditItemTemplate>
    </usweb:USFormView>
    <div class="tbs">
            <div id="Paperless1095CModal" class="modal fade hide" role="dialog" tabindex="-1" aria-hidden="true">
                <div class="modal-dialog">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h4 class="modal-title" id="Paperless1095CModalHeader" runat="server"></h4>
                        </div>
                        <div class="modal-body">
                            <usweb:LocalizedLabel ID="Paperless1095CModalBody" Alias="1095CPaperlessPrompt" runat="server" ></usweb:LocalizedLabel>
                        </div>
                        <div class="modal-footer">
                            <table class="right" style="width:100%;">
                                <tr>
                                    <td style="position:relative; left:20%;"><asp:Button class="btn" id="btn1095CPaperlessNo" OnClick="OnPaperless1095CCancel" runat="server"/></td>
                                    <td style="position:relative; left:10%;"><asp:Button class="btn btn-primary" id="btn1095CPaperlessYes" OnClick="OnPaperless1095CAccept" runat="server"/></td>
                                </tr>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
</asp:Content>
