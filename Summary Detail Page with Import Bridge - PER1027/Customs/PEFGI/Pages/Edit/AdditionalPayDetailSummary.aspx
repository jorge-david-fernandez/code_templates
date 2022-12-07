<%@ Page Language="C#"  MasterPageFile="~/Content.master"  AutoEventWireup="true" CodeFile="AdditionalPayDetailSummary.aspx.cs" Inherits="Customs_PER1027_Pages_AdditionalPayDetailSummary" %>
<%@ MasterType virtualPath="~/Content.master"%>
<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="server">
<%-- ************************************************************************** 
Company:		  UKG
Author:		      Stela Garkova
Client:		      Performance Food Group, Inc.
Date:		      8/9/2022
Request:		  SR-2022-00363993
Purpose:		  Web administrator page for GL custom table for mapping for Org Levels
Last Modified: 
**************************************************************************  --%>
<usweb:USGridDataSource ID="USGridDataSource1" runat="server" StoredProcName="U_PER1027_AdditionalPayDetail_Summary" SqlDataSourceCommandType="StoredProcedure" EnableSqlServerPaging="true" />
  <usweb:FilterManager ID="fmFilterManager" runat="server" GridViewID="gvSummaryGrid"/>
    <usweb:DateRangeFilterControl FilterManagerID="fmFilterManager" Runat="server" ID="PayDateFilter" FilterName="U_AddlPay_PayDate" FromKey="uapPayDate" ToKey="uapPayDate" />

    <usweb:USToolbar ID="gridToolbar" runat="server" >
        <Actions>
            <usweb:ToolbarAction DescriptionAlias="ExportToExcel" JSCallBackMethod="fExportToExcel()" DisplayInQuickAction="true" QuickActionImage="btnActionsExcel.gif" />
            <usweb:ToolbarAction DescriptionAlias="ExportToCSV" JSCallBackMethod="fExportToCSV()" DisplayInQuickAction="true" QuickActionImage="btnActionsCSV.gif" />
        </Actions>
    </usweb:USToolbar>
    <usweb:USGridViewExporter ID="gridViewExporter" runat="server" GridControl="gvSummaryGrid" ExportHiddenColumns="true" ExportEntireGrid="true" FileName="GLOrgLvlTranslations" ExcludeColumns="Delete"></usweb:USGridViewExporter>
    <usweb:USGridView ID="gvSummaryGrid" runat="server" EnableViewState="False" 
	DataSourceID="USGridDataSource1" EmptyOnLoad="False"
	TotalRow="(Collection)" BorderWidth="0px" DeleteColumn="False"
	ShowHideColumnMenu="true" AutoGenerateColumns="False" 
	AllowSorting="True" DefaultSort="uapPayDate DESC"
	CssClass="grid" PageSize="20" AllowPaging="True" NumPages="1">  
        <Columns>
            <usweb:USTemplateField ID="colPayDate" SortExpression="uapPayDate" HeaderText="U_AddlPay_PayDate" Unhideable="True" DefaultHidden="False">
                <ItemTemplate>
                    <usweb:USClientLink id="lnkPayDate" runat="server" 
                                        Params='<%# GetEditParams() %>'  
                                        Text='<%#  Master.Format(Eval("uapPayDate").ToString(), StyleConsts.DATE) %>' 
                                        TargetPage='<%# string.Format("Customs/{0}/pages/edit/AdditionalPayDetailDetail.aspx", Master.UserContext.ClientID) %>' />
                </ItemTemplate>
            </usweb:USTemplateField>
        </Columns>
        <AlternatingRowStyle CssClass="AltShading" />
        <RowStyle CssClass="GridRowStyle" />
    </usweb:USGridView>
</asp:Content>
