<%@ Page Language="C#" MasterPageFile="~/PopupViewOnly.master" CodeFile="CustomUSSuperFinder.aspx.cs" Inherits="CustomUSSuperFinder_aspx" Title="Untitled Page" %>
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
        function Control_OnLoad(){}
        var form = document.getElementById('aspnetForm');
        var codeSelectorID = <asp:Literal runat="server" ID="litCodeSelectorID"></asp:Literal>;
        var hiddenID = <asp:Literal runat="server" ID="litHiddenID"></asp:Literal>;

        jQuery(document).ready(function ()
        {
            var options =
  		    {
  			    codeIndex: 0,
  			    descIndex: 0,
  			    codeElemId: "EEID",
  			    descElemId: "fullName"
  		    };

            jQuery("#" + USFinderGrid.getGridIdFromPage()).USFinder(options);
        });
        
    </script>
    <asp:Literal runat="server" ID="litScripts"></asp:Literal>
    <usweb:FilterManager ID="FilterManager1" runat="server" GridViewID="USGridView1" SingleFilterRow="false" DisplayFilterString="false"  />
    <usweb:TextEntryFilterControl FilterManagerID="FilterManager1" ID="fltrFirstName" FilterName="FirstName" Casing="Title"  Runat="server"  FilterValue="FirstName"  />
    <usweb:TextEntryFilterControl FilterManagerID="FilterManager1" ID="fltrLastName" FilterName="LastName" Casing="Title"  Runat="server"  FilterValue="LastName"  />
    <usweb:TextEntryFilterControl FilterManagerID="FilterManager1" ID="fltrEmpNo" FilterName="EmployeeNumber" Runat="server" FilterValue="EmpNo" /> 
    <usweb:TextEntryFilterControl FilterManagerID="FilterManager1" ID="fltrCompany" FilterName="Company" Runat="server" FilterValue="CompanyName" /> 
    
    <usweb:USGridDataSource 
	ID                    = "GridDataSource1" 
	runat                 = "server" 
	StoredProcName        = "dbo.U_SON1003_GetEmployees"
	EnableSqlServerPaging = "false"
    />
   
	<usweb:USGridView ID="USGridView1" runat="server"
        DataSourceID="GridDataSource1"
        TotalRow="(Collection)"
        AllowPaging="True"
        AllowSorting="True"
        PageSize="10"
        DefaultSort="Name"
        AutoGenerateColumns="False"
        DeleteColumn="false"
        EmptyOnLoad="false"
        Width="100%">        
        <Columns>
            <usweb:USTemplateField ID="colName" HeaderText="Name" SortExpression="Name"
                Unhideable="false" DefaultHidden="false" HeaderStyle-CssClass="left" ItemStyle-CssClass="left">
                <ItemTemplate>
                    <span id="Name" ><%#: Eval("Name") %></span>
                    <span id="EEID" class="hide"><%#: Eval("EEID") %></span>
                    <span id="fullName" class="hide"><%#: Eval("Name") %></span>
                </ItemTemplate>
            </usweb:USTemplateField>
            <usweb:USTemplateField ID="colEmpNo" HeaderText="EmployeeNumber" SortExpression="EmpNo"
                Unhideable="false" DefaultHidden="false" HeaderStyle-CssClass="left" ItemStyle-CssClass="left">
                <ItemTemplate>
                    <%# Eval("EmpNo").ToString() %>
                </ItemTemplate>
            </usweb:USTemplateField>
            <usweb:USTemplateField ID="colCompany" HeaderText="Company" SortExpression="CompanyName"
                Unhideable="false" DefaultHidden="false" HeaderStyle-CssClass="left" ItemStyle-CssClass="left">
                <ItemTemplate>
                    <%# Eval("CompanyName").ToString() %>
                </ItemTemplate>
            </usweb:USTemplateField>
        </Columns>
        <AlternatingRowStyle CssClass="altShading"></AlternatingRowStyle>
        <RowStyle CssClass="GridRowStyle"></RowStyle>
    </usweb:USGridView>
</asp:Content>