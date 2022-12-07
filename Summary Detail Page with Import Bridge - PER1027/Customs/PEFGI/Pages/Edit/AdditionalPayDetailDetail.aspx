<%@ Page Language="C#" MasterPageFile="~/Content.master" AutoEventWireup="true" CodeFile="AdditionalPayDetailDetail.aspx.cs" Inherits="Customs_PER1027_Pages_AdditionalPayDetailDetail" %>

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
    <usweb:USGridDataSource ID="USGridDataSource1" runat="server" StoredProcName="U_PER1027_AdditionalPayDetail_Detail" SqlDataSourceCommandType="StoredProcedure" EnableSqlServerPaging="true" />

    <%--<div style="padding-left: 8px;">
        <table>
            <tr>
                <td>
                    <usweb:LocalizedLabel runat="server" ID="llbPayDate" Alias="U_AddlPay_PayDate" />
                </td>
                <td>
                    <asp:Label runat="server" ID="lblPayDate" Style="width: 100%" />
                </td>
            </tr>
        </table>
    </div>--%>
    <usweb:FilterManager ID="fmFilterManager" runat="server" GridViewID="gvSummaryGrid" />
    <usweb:DateRangeFilterControl FilterManagerID="fmFilterManager" runat="server" ID="WeekEndDateFilter" FilterName="U_AddlPay_WeekEndDate" FromKey="uapWeekEndDate" ToKey="uapWeekEndDate" />
    <usweb:TextEntryFilterControl FilterManagerID="fmFilterManager" runat="server" ID="DescFilter" FilterName="Description" FilterValue="uapDesc" />
    <usweb:NumericFilterControl FilterManagerID="fmFilterManager" runat="server" ID="HoursFilter" FilterName="U_AddlPay_Hours" FilterValue="uapHours" />
    <usweb:NumericFilterControl FilterManagerID="fmFilterManager" runat="server" ID="UnitsFilter" FilterName="U_AddlPay_Units" FilterValue="uapUnits" />
    <usweb:NumericFilterControl FilterManagerID="fmFilterManager" runat="server" ID="RateFilter" FilterName="U_AddlPay_Rate" FilterValue="uapRate" />
    <usweb:NumericFilterControl FilterManagerID="fmFilterManager" runat="server" ID="SalesFilter" FilterName="U_AddlPay_Sales" FilterValue="uapSales" />
    <usweb:NumericFilterControl FilterManagerID="fmFilterManager" runat="server" ID="ProfitFilter" FilterName="U_AddlPay_Profit" FilterValue="uapProfit" />
    <usweb:NumericFilterControl FilterManagerID="fmFilterManager" runat="server" ID="SupplementalFilter" FilterName="U_AddlPay_Supplemental" FilterValue="uapSupplemental" />

    <usweb:USToolbar ID="gridToolbar" runat="server">
        <actions>
            <usweb:ToolbarAction DescriptionAlias="ExportToExcel" JSCallBackMethod="fExportToExcel()" DisplayInQuickAction="true" QuickActionImage="btnActionsExcel.gif" />
            <usweb:ToolbarAction DescriptionAlias="ExportToCSV" JSCallBackMethod="fExportToCSV()" DisplayInQuickAction="true" QuickActionImage="btnActionsCSV.gif" />
        </actions>
    </usweb:USToolbar>
    <usweb:USGridViewExporter ID="gridViewExporter" runat="server" GridControl="gvSummaryGrid" ExportHiddenColumns="true" ExportEntireGrid="true" FileName="GLOrgLvlTranslations" ExcludeColumns="Delete"></usweb:USGridViewExporter>
    <usweb:USGridView ID="gvSummaryGrid" runat="server" EnableViewState="False"
        DataSourceID="USGridDataSource1" EmptyOnLoad="False"
        TotalRow="(Collection)" BorderWidth="0px" DeleteColumn="False"
        ShowHideColumnMenu="true" AutoGenerateColumns="False"
        AllowSorting="True" DefaultSort="uapWeekEndDate ASC" DefaultSecondarySort="uapDesc ASC"
        CssClass="grid" PageSize="20" AllowPaging="True" NumPages="1">
        <Columns>
            <usweb:USTemplateField ID="colPayDate" SortExpression="uapPayDate" HeaderText="U_AddlPay_PayDate" Unhideable="True" DefaultHidden="False" HeaderStyle-CssClass="center" ItemStyle-CssClass="center">
                <ItemTemplate>
                    <usweb:USClientLink ID="lnkWeekEndDate" runat="server"
                        Params='<%# GetEditParams() %>'
                        Text='<%#  Master.Format(Eval("uapPayDate").ToString(), StyleConsts.DATE) %>'
                        TargetPage='<%# string.Format("Customs/{0}/pages/edit/AddChangeAdditionalPayDetail.aspx", Master.UserContext.ClientID) %>'
                        Enabled='<%# Master.ProductKey.Equals("EEADM") %>'/>
                </ItemTemplate>
            </usweb:USTemplateField>
            <usweb:USTemplateField ID="colWeekEndDate" HeaderText="U_AddlPay_WeekEndDate" SortExpression="uapWeekEndDate" Unhideable="true" HeaderStyle-CssClass="center" ItemStyle-CssClass="center">
                <ItemTemplate>
                    <asp:Label ID="cdlWeekEndDate" runat="server" Text='<%#: String.Format(DateTime.Parse(Eval("uapWeekEndDate").ToString()).ToShortDateString(), StyleConsts.DATE)%>'></asp:Label>
                </ItemTemplate>
            </usweb:USTemplateField>
            <usweb:USBoundField ID="colDesc" HeaderText="Description" DataField="uapDesc" SortExpression="uapDesc" HeaderStyle-CssClass="center" ItemStyle-CssClass="center">
                <ItemStyle Wrap="True"></ItemStyle>
            </usweb:USBoundField>
            <usweb:USTemplateField ID="colHours" HeaderText="U_AddlPay_Hours" SortExpression="uapHours" Unhideable="true" HeaderStyle-CssClass="center" ItemStyle-CssClass="center">
                <ItemTemplate>
                    <asp:Label ID="cdlHours" runat="server" Text='<%#: String.Format(Eval("uapHours").ToString(), StyleConsts.RATE2)%>'></asp:Label>
                </ItemTemplate>
            </usweb:USTemplateField>
            <usweb:USTemplateField ID="colUnits" HeaderText="U_AddlPay_Units" SortExpression="uapUnits" Unhideable="true" HeaderStyle-CssClass="center" ItemStyle-CssClass="center">
                <ItemTemplate>
                    <asp:Label ID="cdlUnits" runat="server" Text='<%#: String.Format(Eval("uapUnits").ToString(), StyleConsts.INT)%>'></asp:Label>
                </ItemTemplate>
            </usweb:USTemplateField>
            <usweb:USTemplateField ID="colRate" HeaderText="U_AddlPay_Rate" SortExpression="uapRate" Unhideable="true" HeaderStyle-CssClass="center" ItemStyle-CssClass="center">
                <ItemTemplate>
                    <asp:Label ID="cdlRate" runat="server" Text='<%#: String.Format(Eval("uapRate").ToString(), StyleConsts.RATE2)%>'></asp:Label>
                </ItemTemplate>
            </usweb:USTemplateField>
            <usweb:USTemplateField ID="colSales" HeaderText="U_AddlPay_Sales" SortExpression="uapSales" Unhideable="true" HeaderStyle-CssClass="center" ItemStyle-CssClass="center">
                <ItemTemplate>
                    <asp:Label ID="cdlSales" runat="server" Text='<%#: String.Format(Eval("uapSales").ToString(), StyleConsts.INT)%>'></asp:Label>
                </ItemTemplate>
            </usweb:USTemplateField>
            <usweb:USTemplateField ID="colProfit" HeaderText="U_AddlPay_Profit" SortExpression="uapProfit" Unhideable="true" HeaderStyle-CssClass="center" ItemStyle-CssClass="center">
                <ItemTemplate>
                    <asp:Label ID="cdlProfit" runat="server" Text='<%#: String.Format(Eval("uapProfit").ToString(), StyleConsts.MONEY)%>'></asp:Label>
                </ItemTemplate>
            </usweb:USTemplateField>
            <usweb:USTemplateField ID="colSupplemental" HeaderText="U_AddlPay_Supplemental" SortExpression="uapSupplemental" Unhideable="true" HeaderStyle-CssClass="center" ItemStyle-CssClass="center">
                <ItemTemplate>
                    <asp:Label ID="cdlSupplemental" runat="server" Text='<%#: String.Format(Eval("uapSupplemental").ToString(), StyleConsts.MONEY)%>'></asp:Label>
                </ItemTemplate>
            </usweb:USTemplateField>
            <usweb:USTemplateField ID="colNotes" HeaderText="Notes" HeaderStyle-CssClass="center" ItemStyle-CssClass="center">
                <ItemTemplate>
                    <usweb:NotesButton ID="btnNotes" runat="server" Editable="False" Notes='<%# Eval("uapNotes") %>'>
                    </usweb:NotesButton>
                </ItemTemplate>
            </usweb:USTemplateField>
            <usweb:USTemplateField ID="colDelete" HeaderText="Delete" Unhideable="True" HeaderStyle-CssClass="center" ItemStyle-CssClass="center">
                <ItemTemplate>
                    <input type="checkbox" name="chkDelete" value="<%# Eval("uapRecID") %>" />
                </ItemTemplate>
            </usweb:USTemplateField>
        </Columns>
        <AlternatingRowStyle CssClass="AltShading" />
        <RowStyle CssClass="GridRowStyle" />
    </usweb:USGridView>
</asp:Content>
