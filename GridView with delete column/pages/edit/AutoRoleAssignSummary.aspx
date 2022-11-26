<%@ Page Language="C#" MasterPageFile="~/Content.master" CodeFile="AutoRoleAssignSummary.aspx.cs" Inherits="AutoRoleAssignSummary_aspx" %>
<%@ MasterType virtualPath="~/Content.master"%>
<asp:Content ID="Content1" ContentPlaceHolderID="Content" Runat="server">
<!-- 
 Company:    Ultimate Sofware Corp. 
 Author:     Nathan Osterc
 Client:     Internal
 Filename:   UltiproNet\Customs\USG\pages\edit\AutoRoleAssignSummary.ASPX
 Date:       2/3/2015
 Purpose:    Summary page for Role Assignment 
 -->
<script language="javascript">
    
    $(document).ready(function () {

        $('[id$=btnHelp]').parent().hide();
      
    });


    function fBaseDelete() {

        var isOneDeleteChecked = $("[name=chkDelete]:checked").length;
        if (!isOneDeleteChecked) {
            alert(lstrSelectRecord);
            postOrNot(isOneDeleteChecked);
            return false;
        }
        else {
            if (ConfirmDelete()) {
                postOrNot(true);
            }
        }
        return isOneDeleteChecked; 
    }

</script>
<table class="gridOuterContainer" cellspacing="0" cellpadding="0">
  <tr><td>
    <usweb:USBasicDataSource ID="basicDS" EnablePaging="true" runat="server" ></usweb:USBasicDataSource>
 
    <usweb:FilterManager ID="FilterManager1" runat="server" GridViewID="USGridView1"/>
    
    <usweb:TextEntryFilterControl FilterManagerID="FilterManager1" Runat="server" ID="JobCodeFilter" FilterName="JobCode"            FilterValue="JobCode" />
    <usweb:TextEntryFilterControl FilterManagerID="FilterManager1" Runat="server" ID="JobCodeDescFilter"   FilterName="JobDescription"        FilterValue="JobDesc"  />
    <usweb:CodeTableFilterControl FilterManagerID="FilterManager1" Runat="server" ID="roleNameFilter"      CodeTableName="U_RoleAssign_Roles"      FilterName="Role"           FilterValue="RoleId" />
    <usweb:TextEntryFilterControl FilterManagerID="FilterManager1" Runat="server" ID="QualFieldName1Filter"     FilterName="L_AutoRoleAssign_QualField1" FilterValue="QualField1Name" />
    <usweb:TextEntryFilterControl FilterManagerID="FilterManager1" Runat="server" ID="QualFieldName2Filter"     FilterName="L_AutoRoleAssign_QualField2" FilterValue="QualField2Name" />
    <usweb:TextEntryFilterControl FilterManagerID="FilterManager1" Runat="server" ID="QualFieldName3Filter"     FilterName="L_AutoRoleAssign_QualField3" FilterValue="QualField3Name" />
    <usweb:TextEntryFilterControl FilterManagerID="FilterManager1" Runat="server" ID="QualFieldName4Filter"     FilterName="L_AutoRoleAssign_QualField4" FilterValue="QualField4Name" />
    
	<usweb:USGridView ID="USGridView1" runat="server"
        DataSourceID="basicDS" 
        TotalRow="(Collection)" 
        AllowPaging="True" 
        AllowSorting="True" 
        DefaultSort="JobCode" 
        DefaultSecondarySort="" 
        AutoGenerateColumns="False"
        DeleteColumn="false" 
        EmptyOnLoad="False" 
        Width="100%" 
        OnRowDataBound="USGridView1_RowDataBound"
        >
        
        <Columns>
            <usweb:USTemplateField  SortExpression="JobCode" HeaderText="JobCode"  Unhideable="true" 
                DefaultHidden="False" HeaderStyle-CssClass="left" ItemStyle-CssClass="left" ID="colJobCode" >
            <ItemTemplate>
                    <usweb:USClientLink ID="lnkJobCode" TargetPage='<%# GetTargetPage() %>' Params='<%# GetParams(Eval("RecordId").ToString()) %>' Text='<%# Eval("JobCode").ToString()%>' runat="server" />
            </ItemTemplate>
            </usweb:USTemplateField>
            <usweb:USTemplateField SortExpression="JobDesc" HeaderText="Description"  Unhideable="true" 
                DefaultHidden="False" HeaderStyle-CssClass="left" ItemStyle-CssClass="left" ID="colJobCodeDesc">
            <ItemTemplate>
                    <%# GetJobDescription(Eval("JobCode"),Eval("JobDesc"))%>
            </ItemTemplate>
            </usweb:USTemplateField>

          
           
            <usweb:USTemplateField SortExpression="RoleDescription" HeaderText="Role"  Unhideable="true" 
                DefaultHidden="False" HeaderStyle-CssClass="left" ItemStyle-CssClass="left" ID="colRole">
                <ItemTemplate>
                        <%# GetRoleDescription(Eval("RoleName"),Eval("RoleDescription"))%>
                </ItemTemplate>
            </usweb:USTemplateField>

            
            <usweb:USTemplateField SortExpression="ExcludeSelf" HeaderText="L_AutoRoleAssign_ExcludeSelf"  Unhideable="false" 
                DefaultHidden="False" HeaderStyle-CssClass="left" ItemStyle-CssClass="left" ID="colExcludeSelf">
                <ItemTemplate>
                    <usweb:USCheckBox Visible="true" ID="cbxExcludeSelf" runat="server" BooleanValue='<%# (Eval("ExcludeSelf").ToString()=="Y") %>' Enabled="false" />                       
                </ItemTemplate>
            </usweb:USTemplateField>  
            <usweb:USTemplateField SortExpression="UseRoleInBI" HeaderText="L_AutoRoleAssign_UseRoleInBI"  Unhideable="false" 
                DefaultHidden="False" HeaderStyle-CssClass="left" ItemStyle-CssClass="left" ID="ColRoleInBI">
                <ItemTemplate>
                     <usweb:USCheckBox Visible="true" ID="cbxRoleInBI" runat="server" BooleanValue='<%# (Eval("UseRoleInBI").ToString()=="Y") %>' Enabled="false" />                      
                </ItemTemplate>
            </usweb:USTemplateField> 


            <usweb:USTemplateField SortExpression="QualField1Name" HeaderText="L_AutoRoleAssign_QualField1"  Unhideable="false" 
                DefaultHidden="False" HeaderStyle-CssClass="left" ItemStyle-CssClass="left" ID="colQualField1">
            <ItemTemplate>
                    <%# Eval("QualField1Name") %>
            </ItemTemplate>
            </usweb:USTemplateField>
            <usweb:USTemplateField  HeaderText="L_AutoRoleAssign_QualValue1"  Unhideable="false" 
                DefaultHidden="False" HeaderStyle-CssClass="left" ItemStyle-CssClass="left" ID="colQualValueSupervisor1" >
            <ItemTemplate>
                    <asp:Label runat="server" id="txtQualValue1"></asp:Label>
                    <asp:Label runat="server" style="color:red" ID="txtMissingQualifier1"></asp:Label>
                    <usweb:CodeDescRepeater  runat="server" AllCountries="true" ID="cdr1EecDedGroupCode" CSV='<%# Eval("QualValue1") %>'  CodeTableName="BENGRP" />
                    <usweb:CodeDescRepeater runat="server" AllCountries="true" ID="cdr1EecCoID" CSV='<%# Eval("QualValue1") %>' CodeTableName="COMPANY"/>
                    <usweb:CodeDescRepeater runat="server" AllCountries="true" ID="cdr1EecEmplStatus" CSV='<%# Eval("QualValue1") %>' CodeTableName="EMPLOYEESTATUS" />
                    <usweb:CodeDescRepeater runat="server" AllCountries="true" ID="cdr1EecEEType" CSV='<%# Eval("QualValue1") %>' CodeTableName="EMPTYPE" />
                    <usweb:CodeDescRepeater runat="server" AllCountries="true" ID="cdr1eecFullTimeOrPartTime" CSV='<%# Eval("QualValue1") %>' CodeTableName="FULLORPARTTIME" />
                    <usweb:CodeDescRepeater runat="server" AllCountries="true" ID="cdr1eecJobCode" CSV='<%# Eval("QualValue1") %>' CodeTableName="JOBCODE" />
                    <usweb:CodeDescRepeater runat="server" AllCountries="true" ID="cdr1eecLocation" CSV='<%# Eval("QualValue1") %>' CodeTableName="LOCATION" />
                    <usweb:CodeDescRepeater runat="server" AllCountries="true" ID="cdr1EecOrgLvl1" CSV='<%# Eval("QualValue1") %>' CodeTableName="ORGLVL1" />
                    <usweb:CodeDescRepeater runat="server" AllCountries="true" ID="cdr1EecOrgLvl2" CSV='<%# Eval("QualValue1") %>' CodeTableName="ORGLVL2" />
                    <usweb:CodeDescRepeater runat="server" AllCountries="true" ID="cdr1EecOrgLvl3" CSV='<%# Eval("QualValue1") %>' CodeTableName="ORGLVL3" />
                    <usweb:CodeDescRepeater runat="server" AllCountries="true" ID="cdr1EecOrgLvl4" CSV='<%# Eval("QualValue1") %>' CodeTableName="ORGLVL4" />
                    <usweb:CodeDescRepeater runat="server" AllCountries="true" ID="cdr1eecPayGroup" CSV='<%# Eval("QualValue1") %>' CodeTableName="PAYGROUP" />
                    <usweb:CodeDescRepeater runat="server" AllCountries="true" ID="cdr1eecProject" CSV='<%# Eval("QualValue1") %>' CodeTableName="PROJECT" />
                    <usweb:CodeDescRepeater runat="server" AllCountries="true" ID="cdr1eecSalaryOrHourly" CSV='<%# Eval("QualValue1") %>' CodeTableName="SALARYORHOURLY" />
                    <usweb:CodeDescRepeater runat="server" AllCountries="true" ID="cdr1eecShift" CSV='<%# Eval("QualValue1") %>' CodeTableName="SHIFT" />
                    <usweb:CodeDescRepeater runat="server" AllCountries="true" ID="cdr1eecSupervisorId" CSV='<%# Eval("QualValue1") %>' CodeTableName="U_RolAsgn_Supervisor" /> 
            </ItemTemplate>
            </usweb:USTemplateField>
            <usweb:USTemplateField SortExpression="QualField2Name" HeaderText="L_AutoRoleAssign_QualField2"  Unhideable="false" 
                DefaultHidden="False" HeaderStyle-CssClass="left" ItemStyle-CssClass="left" ID="colQualField2">
            <ItemTemplate>
                    <%# Eval("QualField2Name") %>
            </ItemTemplate>
            </usweb:USTemplateField>
            <usweb:USTemplateField HeaderText="L_AutoRoleAssign_QualValue2"  Unhideable="false" 
                DefaultHidden="False" HeaderStyle-CssClass="left" ItemStyle-CssClass="left" ID="colQualValue2">
            <ItemTemplate>
                    <asp:Label runat="server" id="txtQualValue2"></asp:Label>
                    <asp:Label runat="server" style="color:red" ID="txtMissingQualifier2"></asp:Label>
                    <usweb:CodeDescRepeater runat="server" AllCountries="true" ID="cdr2EecDedGroupCode" CSV='<%# Eval("QualValue2") %>' CodeTableName="BENGRP" />
                    <usweb:CodeDescRepeater runat="server" AllCountries="true" ID="cdr2EecCoID" CSV='<%# Eval("QualValue2") %>' CodeTableName="COMPANY" />
                    <usweb:CodeDescRepeater runat="server" AllCountries="true" ID="cdr2EecEmplStatus" CSV='<%# Eval("QualValue2") %>' CodeTableName="EMPLOYEESTATUS" />
                    <usweb:CodeDescRepeater runat="server" AllCountries="true" ID="cdr2EecEEType" CSV='<%# Eval("QualValue2") %>' CodeTableName="EMPTYPE" />
                    <usweb:CodeDescRepeater runat="server" AllCountries="true" ID="cdr2eecFullTimeOrPartTime" CSV='<%# Eval("QualValue2") %>' CodeTableName="FULLORPARTTIME" />
                    <usweb:CodeDescRepeater runat="server" AllCountries="true" ID="cdr2eecJobCode" CSV='<%# Eval("QualValue2") %>' CodeTableName="JOBCODE" />
                    <usweb:CodeDescRepeater runat="server" AllCountries="true" ID="cdr2eecLocation" CSV='<%# Eval("QualValue2") %>' CodeTableName="LOCATION" />
                    <usweb:CodeDescRepeater runat="server" AllCountries="true" ID="cdr2EecOrgLvl1" CSV='<%# Eval("QualValue2") %>' CodeTableName="ORGLVL1" />
                    <usweb:CodeDescRepeater runat="server" AllCountries="true" ID="cdr2EecOrgLvl2" CSV='<%# Eval("QualValue2") %>' CodeTableName="ORGLVL2" />
                    <usweb:CodeDescRepeater runat="server" AllCountries="true" ID="cdr2EecOrgLvl3" CSV='<%# Eval("QualValue2") %>' CodeTableName="ORGLVL3" />
                    <usweb:CodeDescRepeater runat="server" AllCountries="true" ID="cdr2EecOrgLvl4" CSV='<%# Eval("QualValue2") %>'  CodeTableName="ORGLVL4" />
                    <usweb:CodeDescRepeater runat="server" AllCountries="true" ID="cdr2eecPayGroup" CSV='<%# Eval("QualValue2") %>' CodeTableName="PAYGROUP" />
                    <usweb:CodeDescRepeater runat="server" AllCountries="true" ID="cdr2eecProject" CSV='<%# Eval("QualValue2") %>' CodeTableName="PROJECT" />
                    <usweb:CodeDescRepeater runat="server" AllCountries="true" ID="cdr2eecSalaryOrHourly" CSV='<%# Eval("QualValue2") %>' CodeTableName="SALARYORHOURLY" />
                    <usweb:CodeDescRepeater runat="server" AllCountries="true" ID="cdr2eecShift" CSV='<%# Eval("QualValue2") %>' CodeTableName="SHIFT" />
                    <usweb:CodeDescRepeater runat="server" AllCountries="true" ID="cdr2eecSupervisorId" CSV='<%# Eval("QualValue2") %>' CodeTableName="U_RolAsgn_Supervisor" /> 
            </ItemTemplate>
            </usweb:USTemplateField>
            <usweb:USTemplateField SortExpression="QualField3Name" HeaderText="L_AutoRoleAssign_QualField3"  Unhideable="false" 
                DefaultHidden="False" HeaderStyle-CssClass="left" ItemStyle-CssClass="left" ID="colQualField3">
            <ItemTemplate>
                    <%# Eval("QualField3Name") %>
            </ItemTemplate>
            </usweb:USTemplateField>
            <usweb:USTemplateField HeaderText="L_AutoRoleAssign_QualValue3"  Unhideable="false" 
                DefaultHidden="False" HeaderStyle-CssClass="left" ItemStyle-CssClass="left" ID="colQualValue3">
            <ItemTemplate>
                    <asp:Label runat="server" id="txtQualValue3"></asp:Label>
                    <asp:Label runat="server" style="color:red" ID="txtMissingQualifier3"></asp:Label>  
                    <usweb:CodeDescRepeater runat="server" AllCountries="true" ID="cdr3EecDedGroupCode" CSV='<%# Eval("QualValue3") %>' CodeTableName="BENGRP" />
                    <usweb:CodeDescRepeater runat="server" AllCountries="true" ID="cdr3EecCoID" CSV='<%# Eval("QualValue3") %>' CodeTableName="COMPANY" />
                    <usweb:CodeDescRepeater runat="server" AllCountries="true" ID="cdr3EecEmplStatus" CSV='<%# Eval("QualValue3") %>' CodeTableName="EMPLOYEESTATUS" />
                    <usweb:CodeDescRepeater runat="server" AllCountries="true" ID="cdr3EecEEType" CSV='<%# Eval("QualValue3") %>' CodeTableName="EMPTYPE" />
                    <usweb:CodeDescRepeater runat="server" AllCountries="true" ID="cdr3eecFullTimeOrPartTime" CSV='<%# Eval("QualValue3") %>' CodeTableName="FULLORPARTTIME" />
                    <usweb:CodeDescRepeater runat="server" AllCountries="true" ID="cdr3eecJobCode" CSV='<%# Eval("QualValue3") %>' CodeTableName="JOBCODE" />
                    <usweb:CodeDescRepeater runat="server" AllCountries="true" ID="cdr3eecLocation" CSV='<%# Eval("QualValue3") %>' CodeTableName="LOCATION" />
                    <usweb:CodeDescRepeater runat="server" AllCountries="true" ID="cdr3EecOrgLvl1" CSV='<%# Eval("QualValue3") %>' CodeTableName="ORGLVL1" />
                    <usweb:CodeDescRepeater runat="server" AllCountries="true" ID="cdr3EecOrgLvl2" CSV='<%# Eval("QualValue3") %>' CodeTableName="ORGLVL2" />
                    <usweb:CodeDescRepeater runat="server" AllCountries="true" ID="cdr3EecOrgLvl3" CSV='<%# Eval("QualValue3") %>' CodeTableName="ORGLVL3" />
                    <usweb:CodeDescRepeater runat="server" AllCountries="true" ID="cdr3EecOrgLvl4" CSV='<%# Eval("QualValue3") %>' CodeTableName="ORGLVL4" />
                    <usweb:CodeDescRepeater runat="server" AllCountries="true" ID="cdr3eecPayGroup" CSV='<%# Eval("QualValue3") %>' CodeTableName="PAYGROUP" />
                    <usweb:CodeDescRepeater runat="server" AllCountries="true" ID="cdr3eecProject" CSV='<%# Eval("QualValue3") %>' CodeTableName="PROJECT" />
                    <usweb:CodeDescRepeater runat="server" AllCountries="true" ID="cdr3eecSalaryOrHourly" CSV='<%# Eval("QualValue3") %>' CodeTableName="SALARYORHOURLY" />
                    <usweb:CodeDescRepeater runat="server" AllCountries="true" ID="cdr3eecShift" CSV='<%# Eval("QualValue3") %>' CodeTableName="SHIFT" />
                    <usweb:CodeDescRepeater runat="server" AllCountries="true" ID="cdr3eecSupervisorId" CSV='<%# Eval("QualValue3") %>' CodeTableName="U_RolAsgn_Supervisor" /> 
            </ItemTemplate>
            </usweb:USTemplateField>
            <usweb:USTemplateField SortExpression="QualField4Name" HeaderText="L_AutoRoleAssign_QualField4"  Unhideable="false" 
                DefaultHidden="False" HeaderStyle-CssClass="left" ItemStyle-CssClass="left" ID="colQualField4">
            <ItemTemplate>
                    <%# Eval("QualField4Name") %>
            </ItemTemplate>
            </usweb:USTemplateField>
            <usweb:USTemplateField HeaderText="L_AutoRoleAssign_QualValue4"  Unhideable="false" 
                DefaultHidden="False" HeaderStyle-CssClass="left" ItemStyle-CssClass="left" ID="colQualValue4">
            <ItemTemplate>
                    <asp:Label runat="server" id="txtQualValue4"></asp:Label>
                    <asp:Label runat="server" style="color:red" ID="txtMissingQualifier4"></asp:Label>       
                    <usweb:CodeDescRepeater runat="server" AllCountries="true" ID="cdr4EecDedGroupCode" CSV='<%# Eval("QualValue4") %>' CodeTableName="BENGRP" />
                    <usweb:CodeDescRepeater runat="server" AllCountries="true" ID="cdr4EecCoID" CSV='<%# Eval("QualValue4") %>' CodeTableName="COMPANY" />
                    <usweb:CodeDescRepeater runat="server" AllCountries="true" ID="cdr4EecEmplStatus" CSV='<%# Eval("QualValue4") %>' CodeTableName="EMPLOYEESTATUS" />
                    <usweb:CodeDescRepeater runat="server" AllCountries="true" ID="cdr4EecEEType" CSV='<%# Eval("QualValue4") %>' CodeTableName="EMPTYPE" />
                    <usweb:CodeDescRepeater runat="server" AllCountries="true" ID="cdr4eecFullTimeOrPartTime" CSV='<%# Eval("QualValue4") %>' CodeTableName="FULLORPARTTIME" />
                    <usweb:CodeDescRepeater runat="server" AllCountries="true" ID="cdr4eecJobCode" CSV='<%# Eval("QualValue4") %>' CodeTableName="JOBCODE" />
                    <usweb:CodeDescRepeater runat="server" AllCountries="true" ID="cdr4eecLocation" CSV='<%# Eval("QualValue4") %>' CodeTableName="LOCATION" />
                    <usweb:CodeDescRepeater runat="server" AllCountries="true" ID="cdr4EecOrgLvl1" CSV='<%# Eval("QualValue4") %>' CodeTableName="ORGLVL1" />
                    <usweb:CodeDescRepeater runat="server" AllCountries="true" ID="cdr4EecOrgLvl2" CSV='<%# Eval("QualValue4") %>' CodeTableName="ORGLVL2" />
                    <usweb:CodeDescRepeater runat="server" AllCountries="true" ID="cdr4EecOrgLvl3" CSV='<%# Eval("QualValue4") %>' CodeTableName="ORGLVL3" />
                    <usweb:CodeDescRepeater runat="server" AllCountries="true" ID="cdr4EecOrgLvl4" CSV='<%# Eval("QualValue4") %>' CodeTableName="ORGLVL4" />
                    <usweb:CodeDescRepeater runat="server" AllCountries="true" ID="cdr4eecPayGroup" CSV='<%# Eval("QualValue4") %>' CodeTableName="PAYGROUP" />
                    <usweb:CodeDescRepeater runat="server" AllCountries="true" ID="cdr4eecProject" CSV='<%# Eval("QualValue4") %>' CodeTableName="PROJECT" />
                    <usweb:CodeDescRepeater runat="server" AllCountries="true" ID="cdr4eecSalaryOrHourly" CSV='<%# Eval("QualValue4") %>' CodeTableName="SALARYORHOURLY" />
                    <usweb:CodeDescRepeater runat="server" AllCountries="true" ID="cdr4eecShift" CSV='<%# Eval("QualValue4") %>' CodeTableName="SHIFT" />
                    <usweb:CodeDescRepeater runat="server" AllCountries="true" ID="cdr4eecSupervisorId" CSV='<%# Eval("QualValue4") %>' CodeTableName="U_RolAsgn_Supervisor" />
            </ItemTemplate>
            </usweb:USTemplateField>
 
            <usweb:USTemplateField ID="colDelete" HeaderText="Delete">
			    <ItemTemplate><input type="checkbox" name="chkDelete" value="<%# Eval("RecordId") %>" /></ItemTemplate>
		    </usweb:USTemplateField>
        </Columns>
        <AlternatingRowStyle CssClass="AltShading" />
        <RowStyle CssClass="GridRowStyle" />
    </usweb:USGridView>
        </td>
      </tr>
</table>
</asp:Content>
