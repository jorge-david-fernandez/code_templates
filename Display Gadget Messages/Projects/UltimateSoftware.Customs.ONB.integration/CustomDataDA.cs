using System;
using System.Collections.Generic;
using System.Text;
using System.Data.SqlClient;
using UltimateSoftware.ObjectModel.Common;
using UltimateSoftware.ObjectModel.Base;
using UltimateSoftware.ObjectModel.Objects;
using UltimateSoftware.DataAccessLayer;
using UltimateSoftware.ObjectModel.BusinessRules;
using UltimateSoftware.ObjectModel.Mappings;
using UltimateSoftware.ObjectModel.DataAccess;
using UltimateSoftware.Common;

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
    public class CustomDataDA : JobInformationDA        //todo: Adjust class name
    {
        public CustomDataDA()       //todo: Adjust constructor name
        {
        }

        //todo: In the below:
        //Adjust method name
        //Adjust first parameter type
        //Adjust foreach loop to be for appropriate type
        //Adjust stored procedure name and parameters

        //For New Hire, in addition to passing JobID to stored procedure,
        //passed SSN and COID to locate EmpPers record with,
        //because the InitiatedFor EEID and COID are not available.
        //However, for other wizards, like job change, that operate on existing employees,
        //just the JobID would be needed, because the InitiatedFor EEID and COID are available.

        public void SetCustomDataValue(EmployeeList employeeList, CompanyDAL companyDAL, UserContextData uc)
        {
            foreach (Employee emp in employeeList)
            {
                string sqlString = "EXEC U_LAZ1001_SaveOnboardingUDFields @JOBID, @SSN, @COID";
                using (SqlCommand aCommand = new SqlCommand(sqlString))
                {
                    //JobID
                    aCommand.Parameters.Add("@JOBID", System.Data.SqlDbType.Int);
                    aCommand.Parameters["@JOBID"].Value = uc.JobID;
                    //SSN
                    aCommand.Parameters.Add("@SSN", System.Data.SqlDbType.Char, 12);
                    aCommand.Parameters["@SSN"].Value = emp.Identification.SocialSecurity;
                    //COID
                    aCommand.Parameters.Add("@COID", System.Data.SqlDbType.Char, 5);
                    aCommand.Parameters["@COID"].Value = emp.COID;
                    //EXECUTE
                    companyDAL.ExecuteNonQuery(aCommand);
                }
            }
        }

    }
}
