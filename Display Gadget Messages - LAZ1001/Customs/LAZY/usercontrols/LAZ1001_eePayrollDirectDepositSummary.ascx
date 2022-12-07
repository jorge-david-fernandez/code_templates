<%@ Control Language="C#" AutoEventWireup="true" CodeFile="LAZ1001_eePayrollDirectDepositSummary.ascx.cs" Inherits="usercontrols_LAZ1001_eePayrollDirectDepositSummary" %>   

  <style type="text/css">
        #ctl00_Content_uc_eePayrollDirectDepositSummary_grvEEDirectDeposit tbody tr td span {
            font-size: 14px;
        }                
  </style>
<%-- ************************************************************************** 
Company:		  Ultimate Software Corp. 
Author:		      Adrian Serrano
Client:		      Lazy Dog Restaurants, LLC
Date:		      1/28/2020
Request:		  SR-2019-00245269
Purpose:		  Instant Pay Direct Deposit (from scope project SR-2019-00233967)
Last Modified: 
**************************************************************************  --%> 

  <usweb:ProcessManager ID="pmPayrollDirectDeposit" runat="server" />

  <usweb:USObjectDataSource ID="odsPayrollDirectDepositSummary" runat="server" ProcessManagerName="pmPayrollDirectDeposit"
    SelectMethod="SelectData" UpdateMethod="UpdateData" InsertMethod="InsertData" DeleteMethod="DeleteData"
    TypeName="UltimateSoftware.WebObjects.DirectDepositDataItem" DataObjectTypeName="UltimateSoftware.WebObjects.DirectDepositDataItem"
    OnGetObjectParams="GetObjectParams" BindToGrid="true" RaiseErrorOnNoRecordsReturned="False"
    EnablePaging="True" FilterAdded="False" MaximumRowsParameterName="maxRows" OldValuesParameterFormatString="original_{0}"
    PageRequest="False" RowCount="0" SelectCountMethod="ListCount" SkipDataBind="False"
    SortParameterName="sortExpression" StartRowIndexParameterName="startRow" />
    
    <div id="contentDiv">
  <usweb:USGridView ID="grvEEDirectDeposit" runat="server" DataSourceID="odsPayrollDirectDepositSummary"
    AllowSorting="True" AllowPaging="True" AutoGenerateColumns="False" TotalRow="(Collection)" FilterString="" EnableViewState="False" DeleteColumn="True" ShowHideColumnMenu="True" 
    EmptyOnLoad="False" DataKeyNames="ObjectID" DefaultSort="IsArchived" EnableSingleRowEdits="False" 
    HeadersLocalizedInPage="False" IsCodeTableGrid="False" OnRowDataBound="SummaryGrid_RowDataBound" SelectColumn="True">
    <Columns>
      <usweb:USTemplateField ID="colAccountNumber" HeaderText="AccountNumber" sortexpression="Account" Unhideable="true">
        <ItemTemplate>
<%--          <usweb:USDetailLink id="usdlAccountCA" runat="server" ObjectID='<%#: Eval("ObjectID") %>' SubProcessName="DirectDeposit" Text='<%# DDMaskValue((string)Eval("Account"), "ACCTNR")%>'></usweb:USDetailLink>--%>
          <usweb:USDetailLink id="usdlAccountCA" runat="server" ObjectID='<%#: Eval("ObjectID") %>' SubProcessName="DirectDeposit" Text='<%# DDMaskValue((string)Eval("Account"), "ACCTNR")%>' Enabled='<%# !GetEmployeeDebitCardUsage() %>'></usweb:USDetailLink>
        </ItemTemplate>
      </usweb:USTemplateField>

      <usweb:USBoundField ID="colDescription" HeaderText="Description" SortExpression="Description" DataField="Description" />
      <usweb:USBoundField ID="colBank" HeaderText="Bank" SortExpression="Bank_BankName" DataField="Bank_BankName" />

      <usweb:USTemplateField ID="colAccountType" HeaderText="AccountType" SortExpression="AccountType_Code">
        <itemtemplate>
            <usweb:CodeDescLabel ID="lblBankCa" runat="server" CodeTableName="BANKACCTTYPE" Code='<%# Eval("AccountType_Code").ToString() %>' ></usweb:CodeDescLabel>
        </itemtemplate>
      </usweb:USTemplateField>


      <usweb:USBoundField ID="colRoutingNumber" HeaderText="RoutingNumber" DefaultHidden="true" datafield="Bank_BankRoutingNo" sortexpression="Bank_BankRoutingNo" Alignment="Left"/>

      <usweb:USBoundField ID="colBankingInstitutionNumber" HeaderText="BankingInstitutionNumber" visible="false" datafield="InstitutionNo" sortexpression="InstitutionNo" Alignment="Left"/>
      <usweb:USTemplateField ID="colAmount" HeaderText="Amount" SortExpression="AmtOrPct" >
        <itemtemplate>
            <%#PctAmtOrBalance(Eval("DirectDepositRule"), Eval("AmtOrPct"), Eval("IsPrenoteEnabled"))%>
        </itemtemplate>
        <ItemStyle CssClass="right" />
        <HeaderStyle CssClass="right" />
      </usweb:USTemplateField>    
      <usweb:USTemplateField ID="colStatus" HeaderText="Status" sortexpression="AccountStatus">
         <itemtemplate>
              <%#PrenoteStatus(Eval("PrenoteStatus").ToString(), Eval("IsInactive").ToString(), Eval("IsArchived").ToString())%>
          </itemtemplate>
        <ItemStyle CssClass="left" />
        <HeaderStyle CssClass="left" />
      </usweb:USTemplateField>
          
    </Columns>
    <AlternatingRowStyle CssClass="altShading"></AlternatingRowStyle>
    <RowStyle CssClass="GridRowStyle"></RowStyle>
  </usweb:USGridView>
    </div>
