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
using System.Data.SqlClient;
using UltimateSoftware.DataAccessLayer;
using UltimateSoftware.ObjectModel.DataAccess;
using UltimateSoftware.Common;
using UltimateSoftware.PerformanceManagement.Objects;
using UltimateSoftware.ObjectModel.Objects;

#endregion

namespace UltimateSoftware.Customs.LAZ1001.BPCustomSteps
{
    public class NewHireStepDA : EmployeeDA
    {
        public NewHireStepDA()
        {
        }


        public void SetCustomValuesNewHire(EmployeeList employeeList, CompanyDAL companyDAL, UserContextData uc)
        {
            foreach (Employee emp in employeeList)
            {
                string sqlString = "EXEC dbo.U_LAZY_NHW_CommitCustomData @JOBID, @EEID, @COID";
                using (SqlCommand aCommand = new SqlCommand(sqlString))
                {
                    //JobID
                    aCommand.Parameters.Add("@JOBID", System.Data.SqlDbType.Int);
                    aCommand.Parameters["@JOBID"].Value = uc.JobID;
                    //EEID
                    aCommand.Parameters.Add("@EEID", System.Data.SqlDbType.Char);
                    aCommand.Parameters["@EEID"].Value = emp.PrimaryKey["EEID"].ToString().Trim();
                    //COID
                    aCommand.Parameters.Add("@COID", System.Data.SqlDbType.Char, 5);
                    aCommand.Parameters["@COID"].Value = emp.PrimaryKey["COID"].ToString().Trim();
                    //EXECUTE
                    companyDAL.ExecuteNonQuery(aCommand);
                }
            }
        }

    }
}