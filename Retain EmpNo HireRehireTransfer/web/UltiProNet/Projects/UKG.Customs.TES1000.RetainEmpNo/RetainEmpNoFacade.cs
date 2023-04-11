/// <Header summary>
///Company:		  UKG
///Author:		  Jorge Fernandez
///Client:		  Tesla, Inc.
///Date:		  4/6/2023
///Request:		  SR-2023-00398983
///Purpose:		  Modify Rehire employee and Transfer Employee to retail 6 position employee number
///Last Modified: 

/// </Header summary>

namespace UKG.Customs.TES1000.RetainEmpNo
{
    using System.Data.SqlClient;
    using UltimateSoftware.Common;
    using UltimateSoftware.DataAccessLayer;
    using UltimateSoftware.ObjectModel.Common;
    using UltimateSoftware.ObjectModel.Objects;

    public class RetainEmpNoFacade : UltimateSoftware.ObjectModel.Facade.BaseFacade      
    {
        public RetainEmpNoFacade()       
        {
        }

        public RetainEmpNoFacade(UserContextData userContextData)           
        {
            this.UserContextData = userContextData;
        }

        [BDUAssociatedClass(typeof(Employee), FacadeMethodType.SetterMethod)]
        public void RetainEmpNo(EmployeeList EmployeeList)
        {
            foreach (Employee Employee in EmployeeList)
            {
                string sqlString = "dbo.U_TES1000_RetainEmpNo";
                using (SqlCommand cmd = new SqlCommand(sqlString))
                {
                    cmd.CommandType = System.Data.CommandType.StoredProcedure;
                    cmd.Parameters.Add("@JOBID", System.Data.SqlDbType.Int);
                    cmd.Parameters["@JOBID"].Value = UserContextData.JobID;
                    cmd.Parameters.Add("@EEID", System.Data.SqlDbType.Char);
                    cmd.Parameters["@EEID"].Value = Employee.PrimaryKey["EEID"].ToString().Trim();
                    cmd.Parameters.Add("@COID", System.Data.SqlDbType.Char);
                    cmd.Parameters["@COID"].Value = Employee.PrimaryKey["COID"].ToString().Trim();
                    new CompanyDAL().ExecuteNonQuery(cmd);
                }
            }
        }
    }
}