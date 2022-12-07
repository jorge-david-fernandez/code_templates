using System;
using System.Collections.Generic;
using System.Text;
using UltimateSoftware.ObjectModel.DataAccess;
using UltimateSoftware.ObjectModel.BusinessProcesses;
using UltimateSoftware.ObjectModel.Objects;
using UltimateSoftware.ObjectModel.Base;
using UltimateSoftware.Security;
using UltimateSoftware.ObjectModel.Common;
using UltimateSoftware.Common;
using UltimateSoftware.ObjectModel.Facade;
using UltimateSoftware.DataAccessLayer;

/// <Header summary>
///Company:		  Ultimate Software Corp. 
///Author:		  Adrian Serrano
///Client:		  Lazy Dog Restaurants, LLC
///Date:		  1/28/2020
///Request:		  SR-2019-00245269
///Purpose:		  Instant Pay Direct Deposit (from scope project SR-2019-00233967)
///Last Modified: 

/// </Header summary>
            

namespace UltimateSoftware.Customs.ONB.LAZ1001_Integration
{
    public class CustomDataFacade : UltimateSoftware.ObjectModel.Facade.BaseFacade      //todo: Adjust class name
    {
        public CustomDataFacade()       //todo: Adjust constructor name
        {
        }

        public CustomDataFacade(UserContextData userContextData)           //todo: Adjust constructor name 
        {
            this.UserContextData = userContextData;
        }

        //todo: In the below:
        //Adjust type name
        //Adjust data-accessor class name
        //Adjust data-accessor method name

        //The typeof() and the first parameter of method may need to be adjusted
        //to correspond to one of the data items mentioned in the WebBusinessObjects block in the Process XML file.
        //In this example, an EmployeeDataItem was referenced in the WebBusinessObjects block of the process file.
        //In Ultipronet object framework, for every xxxxDataItem, there is an xxxxList object, and an xxxx object.
        //So for the EmployeeDataItem, we use typeof(EmployeeList) and first parameter of EmployeeList.
        //This was appropriate for the New Hire wizard.
        //For other wizards, figure out which type to use.

        [BDUAssociatedClass(typeof(EmployeeList), FacadeMethodType.SetterMethod)]
        public void SetCustomData(EmployeeList employeeList)
        {
            BaseFacade bf = new BaseFacade();
            bf.UserContextData = UserContextData;
            bf.InitiliazeDALSettings();

            CompanyDAL companyDAL = new CompanyDAL();

            CustomDataDA DA = new CustomDataDA();
            DA.SetCustomDataValue(employeeList, companyDAL, this.UserContextData);
        }

    }
}
