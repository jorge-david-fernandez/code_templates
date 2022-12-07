<%@ Page Language="C#" MasterPageFile="~/Process.master" CodeFile="EmpDebitTipConsentDetail.aspx.cs" Inherits="EmpDebitTipConsentDetail_aspx" %>

<%@ MasterType VirtualPath="~/Process.master" %>
<asp:Content ID="Content1" ContentPlaceHolderID="Content" runat="server">
    <!-- *************************************  
 Company:    Ultimate Sofware Corp. 
 Author:     Adrian Serrano
 Client:     Lazy Dog Restaurants, LLC
 Filename:   UltiproNet\Customs\LAZY\pages\edit\EmpDebitTipConsentDetail.ASPX
 CP Request: SR-2019-00245269
 Date:       9/11/2019
 Purpose:    Detail form view page for U_LAZ1001_EmpDebitTipConsent

 Last Modified: 

     *************************************  -->
    <usweb:ProcessManager ID="ProcessManager1" ProcessName="LAZYEmpDebitTipConsent" runat="server" />

    <usweb:USObjectDataSource ID="USObjectDataSource1" runat="server"
        TypeName="UltimateSoftware.WebObjects.Customs.LAZ1001.EmpDebitTipConsentDataItem"
        SelectMethod="SelectData"
        UpdateMethod="UpdateData"
        InsertMethod="InsertData"
        DeleteMethod="DeleteData"
        MaximumRowsParameterName="maxRows"
        DataObjectTypeName="UltimateSoftware.WebObjects.Customs.LAZ1001.EmpDebitTipConsentDataItem"
        ProcessManagerName="ProcessManager1"
        OnGetObjectParams="USObjectDataSource1_OnGetObjectParams"
        OnAfterObjectLoad="USObjectDataSource1_OnAfterObjectLoad" />

    <div id="DebitTipCardSettingsMsg" class="info">
        <h3>Information</h3>
        <ul>
            <li id="liDebitTipCardSettingsMsg" runat="server"></li>
        </ul>
    </div>
    <usweb:USFormView ID="FormView1" runat="server" DataSourceID="USObjectDataSource1">
        <EditItemTemplate>
            <div class="twoColL">
                <table>
                    <tr id="DebitCardRow">
                        <td>
                            <usweb:LocalizedLabel ID="lblDebitCard" Alias="L_LAZY_DebitCard" runat="server" />
                        </td>
                        <td>&nbsp;</td>
                        <td runat="server">
                            <usweb:CodeSelector ID="csDebitCard" runat="server" Code='<%# Bind("UDField21")%>' CodeTableName="YESNO"></usweb:CodeSelector>

                        </td>
                    </tr>
                    <tr>
                        <td>
                            <usweb:LocalizedLabel ID="lblTipCard" Alias="L_LAZY_TipCard" runat="server" />
                        </td>
                        <td>&nbsp;</td>
                        <td runat="server">
                            <usweb:CodeSelector ID="csTipCard" runat="server" Code='<%# Bind("UDField22")%>' CodeTableName="YESNO"></usweb:CodeSelector>
                        </td>
                    </tr>


                </table>
            </div>

            <div class="twoColL">
                <table>
                    <tr>
                        <td>
                            <usweb:LocalizedLabel ID="lblStatus" Alias="Status" runat="server" />
                        </td>
                        <td>&nbsp;</td>
                        <td>&nbsp;</td>
                    </tr>
                    <tr>
                        <td>
                            <usweb:LocalizedLabel ID="lblApproved" Alias="L_LAZY_Approved" runat="server" />
                        </td>
                        <td>&nbsp;</td>
                        <td runat="server">
                            <usweb:CodeDescLabel runat="server" ID="cdlApproved" Code='<%# Bind("UDField05")%>' CodeTableName="YESNO"></usweb:CodeDescLabel>

                        </td>
                    </tr>
                    <tr>
                        <td>
                            <usweb:LocalizedLabel ID="lblDateApproved" Alias="L_LAZY_DateApproved" runat="server" />
                        </td>
                        <td>&nbsp;</td>
                        <td runat="server">
                            <asp:Label runat="server" Text='<%# Bind("UDField06")%>' ID="llbDateApproved"></asp:Label>

                        </td>
                    </tr>
                </table>
            </div>
            <div>
                <h2 class="banner">
                    <usweb:LocalizedLabel ID="llbMealWaiverConsent" runat="server" Alias="L_LAZ1001_MealWaiverConsent"></usweb:LocalizedLabel>
                </h2>
                <div class="twoColL">
                    <table>
                        <tr id="MealWaiver1Row">
                            <td>
                                <usweb:LocalizedLabel ID="llbMealWaiver1" Alias="L_LAZ1001_MealWaiver1" runat="server" />
                            </td>
                            <td>&nbsp;</td>
                            <td runat="server">
                                <usweb:CodeSelector ID="csMealWaiver1" runat="server" Code='<%# Bind("UDField24")%>' CodeTableName="YESNO"></usweb:CodeSelector>
                            </td>
                        </tr>
                        <tr id="MealWaiver2Row">
                            <td>
                                <usweb:LocalizedLabel ID="llbMealWaiver2" Alias="L_LAZ1001_MealWaiver2" runat="server" />
                            </td>
                            <td>&nbsp;</td>
                            <td runat="server">
                                <usweb:CodeSelector ID="csMealWaiver2" runat="server" Code='<%# Bind("UDField23")%>' CodeTableName="YESNO"></usweb:CodeSelector>
                            </td>
                        </tr>
                    </table>
                </div>
            </div>
        </EditItemTemplate>
    </usweb:USFormView>
</asp:Content>
