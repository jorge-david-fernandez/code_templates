/// <Header summary>
///Company:		  Ultimate Software Corp. 
///Author:		  Gayle Velazquez
///Client:		  Lazy Dog Restaurants, LLC
///Date:		  3/12/2018
///Request:		  SR-2018-00189031
///Purpose:		  Default Pay Statement Preference to Electronic copies only
///Last Modified: 

/// </Header summary>


#region Using directives
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
using UltimateSoftware.ObjectModel.Objects.PositionManagement;
using UltimateSoftware.PerformanceManagement.Objects;
#endregion

namespace UltimateSoftware.Customs.LAZ1001.BPCustomSteps
{
    public class NewHireStepFacade : UltimateSoftware.ObjectModel.Facade.BaseFacade      
    {
        public NewHireStepFacade()       
        {
        }

        public NewHireStepFacade(UserContextData userContextData)           
        {
            this.UserContextData = userContextData;
        }

        [BDUAssociatedClass(typeof(EmployeeList), FacadeMethodType.SetterMethod)]
        public void SetCustomValuesNewHire(EmployeeList employeeList)
        {
            BaseFacade bf = new BaseFacade();
            bf.UserContextData = UserContextData;
            bf.InitiliazeDALSettings();

            CompanyDAL companyDAL = new CompanyDAL();

            NewHireStepDA DA = new NewHireStepDA();
            DA.SetCustomValuesNewHire(employeeList, companyDAL, this.UserContextData);
        }
    }
}