using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using UltimateSoftware.EntityManager;
using UltimateSoftware.Security;
using UltimateSoftware.WebControls;

namespace UltiProNet.DAL
{
    public class RoleReportRepository
    {
        private readonly UserContext _userContext;

        private SqlConnection GetSqlConnection()
        {
            return FoundationFacade.Instance.GetReadOnlySqlConnection(_userContext, _userContext.CompanyDatabase);
        }

        public RoleReportRepository(UserContext userContext)
        {
            _userContext = userContext;
        }

        public int GetFirstRoleIDCanAccessReport(string reportID, int[] roleIDs)
        {
            using (SqlCommand sqlCommand = new SqlCommand())
            {
                sqlCommand.Connection = GetSqlConnection();
                sqlCommand.CommandText = "HRMS_STDRPT_GetFirstRoleIDCanAccessReport";
                sqlCommand.CommandType = CommandType.StoredProcedure;
                
                sqlCommand.Parameters.Add(new SqlParameter { 
                    ParameterName = "@ReportID",
                    SqlDbType = SqlDbType.VarChar,
                    Size = 50,
                    Value = reportID
                });

                sqlCommand.Parameters.Add(new SqlParameter {
                    ParameterName = "@RoleIDs",
                    SqlDbType = SqlDbType.VarChar,
                    Size = int.MaxValue,
                    Value = string.Join(",", roleIDs)
                });

                sqlCommand.Parameters.Add(new SqlParameter {
                    ParameterName = "@RoleID",
                    SqlDbType = SqlDbType.Int,
                    Direction = ParameterDirection.Output 
                });

                sqlCommand.Connection.Open();
                sqlCommand.ExecuteNonQuery();
                sqlCommand.Connection.Close();
                
                int value = (int)sqlCommand.Parameters["@RoleID"].Value;
                return value;
            }
            
        }
    }
}