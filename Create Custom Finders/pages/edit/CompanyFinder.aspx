<%@ Page Language="C#" MasterPageFile="~/PopupViewOnly.master" CodeFile="CompanyFinder.aspx.cs" Inherits="CustomCompanyFinder_aspx" Title="Untitled Page" %>
<%@ MasterType VirtualPath="~/PopupViewOnly.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Content" runat="server">
<!-- ************************************************************************** 
Company:		  UKG
Author:		      Jorge David Fernandez
Client:		      Sony Pictures Entertainment Inc.
Date:		      3/17/2021
Request:		  SR-2021-00303642
Purpose:		  Web Admin for BI Reporting Security Matrix Custom Screen and Tables
Last Modified: 
**************************************************************************  --> 

    <script type="text/javascript">

        jQuery(document).ready(function ()
        {
            var options =
            {
                codeIndex: 0,
                descIndex: 1,
                codeElemId: "COID",
  			    descElemId: "codDesc"
            };

            jQuery('table[id$=gridView]').USFinder(options);
        });
        
    </script>
    <usweb:FilterManager ID="FilterManager1" runat="server" GridViewID="USGridView1" SingleFilterRow="false" DisplayFilterString="false"  />
    <usweb:TextEntryFilterControl FilterManagerID="FilterManager1" ID="objCode" FilterName="Code" Casing="Title"  Runat="server"  FilterValue="orgcode"  />
    <usweb:CodeTableFilterControl FilterManagerID="FilterManager1" ID="objDesc" FilterName="Description" Runat="server" CodeTableName="ORGLVL1ACTIVE" FilterValue="orgcode" />  
    
    <usweb:USGridDataSource 
	ID                    = "GridDataSource1" 
	runat                 = "server" 
	StoredProcName        = "dbo.U_SON1003_GetCompanies"
	EnableSqlServerPaging = "false"
    />
   
	<usweb:USGridView ID="USGridView1" runat="server"
        DataSourceID="GridDataSource1"
        TotalRow="(Collection)"
        AllowPaging="True"
        AllowSorting="True"
        PageSize="10"
        DefaultSort="cmpCompanyName"
        AutoGenerateColumns="False"
        DeleteColumn="false"
        EmptyOnLoad="false"
        Width="100%">        
        <Columns>
            <usweb:USTemplateField ID="colCode" HeaderText="Code" SortExpression="cmpCompanyCode"
                Unhideable="false" DefaultHidden="false" HeaderStyle-CssClass="left" ItemStyle-CssClass="left">
                <ItemTemplate>
                    <span id="COID"><%#: Eval("COID") %></span>
                    <%--<span id="CompanyCode"><%#: Eval("CompanyCode") %></span>--%>
                </ItemTemplate>
            </usweb:USTemplateField>
            <usweb:USTemplateField ID="colDesc" HeaderText="Description" SortExpression="cmpCompanyName"
                Unhideable="false" DefaultHidden="false" HeaderStyle-CssClass="left" ItemStyle-CssClass="left">
                <ItemTemplate>
                    <usweb:CodeDescLabel ID="codDesc" runat="server" CodeTableName="COMPANY" Code='<%# Eval("COID").ToString() %>' DisplayMethod="Description" AllCountries="true" />
                </ItemTemplate>
            </usweb:USTemplateField>
        </Columns>
        <AlternatingRowStyle CssClass="altShading"></AlternatingRowStyle>
        <RowStyle CssClass="GridRowStyle"></RowStyle>
    </usweb:USGridView>
</asp:Content>