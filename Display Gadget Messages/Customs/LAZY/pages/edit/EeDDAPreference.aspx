<%@ Page Language="C#" MasterPageFile="~/PopupViewOnly.master" CodeFile="EeDDAPreference.aspx.cs" AutoEventWireup="true" 
 ValidateRequest="false" Inherits="EeDDAPreference_aspx" Title="Untitled Page" %>
<%@ MasterType VirtualPath="~/PopupViewOnly.master" %>
<%-- ************************************************************************** 
Company:		  Ultimate Software Corp. 
Author:		      Adrian Serrano
Client:		      Lazy Dog Restaurants, LLC
Date:		      1/28/2020
Request:		  SR-2019-00245269
Purpose:		  Instant Pay Direct Deposit (from scope project SR-2019-00233967)
Last Modified: 
**************************************************************************  --%> 
<asp:Content ID="Content1" ContentPlaceHolderID="Content" runat="server">
  <fieldset runat="server" id="receiveFS" class="receiveFS serviceLength">
    <legend><usweb:LocalizedLabel ID="lblDDAPreference" runat="server" Alias="IWantToReceive" /></legend> 
      <asp:RadioButton runat="server" GroupName="DDAPreference" ID="PaperElectronic"/>&nbsp;<usweb:LocalizedLabel ID="lblPaperAndElectronicCopy" runat="server" Alias="PaperAndElectronicCopy" /><br />
      <asp:RadioButton runat="server" GroupName="DDAPreference" ID="ElectronicOnly"/>&nbsp;<usweb:LocalizedLabel ID="lblElectronicOnly" runat="server" Alias="ElectronicOnly" /><br /> 
  </fieldset> 
</asp:Content>
