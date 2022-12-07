<%@ Page Language="C#" MasterPageFile="~/Content.master" CodeFile="EmpDebitTipConsentHistorySummary.ASPX.CS" Inherits="Customs_LAZ1001_Pages_Edit_EmpDebitTipConsentHistorySummary_aspx" %>

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
    <usweb:USGridDataSource
        ID="gdsDebitTipConsentHistory"
        runat="server"
        StoredProcName="dbo.U_LAZ1001_GetDebitTipConsentHistory"
        EnableSqlServerPaging="false" />
    
    <usweb:FilterManager ID="fltmgrDebitTipConsentHistory" runat="server" GridViewID="grdvDebitTipConsentHistory" />

    <usweb:DateRangeFilterControl FilterManagerID="fltmgrDebitTipConsentHistory" runat="server" ID="DateSignedFilter" DbType="DateTime" FilterName="L_LAZ1001_DateSigned" FromKey="udaDateSigned" ToKey="udaDateSigned" />
    
<%--    <usweb:TextEntryFilterControl ID="CodeFilter" FilterManagerID="FilterManager1" runat="server"
        DbType="VarChar" FilterName="U_LAZ1001_DateSigned" FilterValue="DateSigned" />--%>

    <usweb:USGridView ID="grdvDebitTipConsentHistory" runat="server" EnableViewState="False"
        DataSourceID="gdsDebitTipConsentHistory" EmptyOnLoad="False" TotalRow="(Collection)"
        BorderWidth="0px" DeleteColumn="False" ShowHideColumnMenu="false"
        AutoGenerateColumns="False" AllowSorting="True" DefaultSort="udaDateSigned DESC"
        CssClass="grid" PageSize="20" AllowPaging="True" UseConventionalCheckboxId="true">
        <Columns>
            <usweb:USTemplateField SortExpression="udaDateSigned" HeaderText="L_LAZ1001_DateSigned"
                Unhideable="false" DefaultHidden="False" HeaderStyle-CssClass="left" ItemStyle-CssClass="left">
                <ItemTemplate>
                    <usweb:USClientLink Visible="true" ID="lnkEdit" runat="server" Text='<%# Eval("udaDateSigned") %>'
                        TargetPage='<%# DetailURL %>' LinkTypeAttribute="USClientLinkType.STANDARD"
                        PK="<%# Master.ProductKey %>" Params='<%# GetEditParams() %>' />
                </ItemTemplate>
            </usweb:USTemplateField>
            <usweb:USTemplateField SortExpression="udaConsentType" HeaderText="Description"
                Unhideable="false" DefaultHidden="False" HeaderStyle-CssClass="left" ItemStyle-CssClass="left">
                <ItemTemplate><%# Eval("udaConsentType") %></ItemTemplate>
            </usweb:USTemplateField>
        </Columns>
        <AlternatingRowStyle CssClass="AltShading" />
        <RowStyle CssClass="GridRowStyle" />
    </usweb:USGridView>

</asp:Content>
