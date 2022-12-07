/// <Header summary>
/// Company:    Ultimate Sofware Corp.
/// Author:     Adrian Serrano
/// Client:     Lazy Dog Restaurants, LLC
/// Filename:   UltimateSoftware.Customs.LAZY.Objects\DataAccess\EmpDebitTipConsentDA.cs
/// CP Request: SR-2019-00245269
/// Date:       9/12/2019
/// Purpose:    Data Accessor for table U_LAZ1001_EmpDebitTipConsent
///
/// Last Modified: 
/// 
/// </Header summary>

#region Using directives
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
#endregion

#region Custom Using directives
using UltimateSoftware.Customs.LAZ1001.Objects;
#endregion

namespace UltimateSoftware.Customs.LAZ1001.DataAccess
{
    #region EmpDebitTipConsent Data Accessor

	public class EmpDebitTipConsentDA : DataAccessor
	{
		public EmpDebitTipConsentDA()
		{
		}

		public void SetEmpDebitTipConsent(EmpDebitTipConsentList aEmpDebitTipConsentList)
		{
			aEmpDebitTipConsentList.Write();
		}

        public void PostProcessEmpDebitTipConsent(EmpDebitTipConsentList aEmpDebitTipConsentList)
        {
            if (aEmpDebitTipConsentList != null && aEmpDebitTipConsentList.Count > 0)
            {
                 EmpDebitTipConsent EmpDebitTip = aEmpDebitTipConsentList[0];

                CompanyDAL companyDAL = new CompanyDAL();
                PerformPostProcess(EmpDebitTip, companyDAL);
            }
        }

        public EmpDebitTipConsentList GetEmpDebitTipConsent()
		{
		    return new EmpDebitTipConsentList("LAZYEmpDebitTipConsent.xml");
		}

        public EmpDebitTipConsentList GetEmpDebitTipConsentByKey(string aCOID, string aEEID)
        {
            EmpDebitTipConsentList list = new EmpDebitTipConsentList("LAZYEmpDebitTipConsent.xml");

            if (aCOID != "" && aEEID != "")
            {
                return LoadEmpDebitTipConsentListByKey(aCOID,aEEID, list);
            }
            else
            {
                return LoadEmpDebitTipConsentList(list);
            }
        }

		protected virtual EmpDebitTipConsentList LoadEmpDebitTipConsentList(EmpDebitTipConsentList list)
		{
			Dictionary<string, object> paramList = new Dictionary<string, object>();
			list.Read(paramList);
			return list;
		}

        protected virtual EmpDebitTipConsentList LoadEmpDebitTipConsentListByKey(string aCOID, string aEEID, EmpDebitTipConsentList list)
        {
            Dictionary<string, object> paramList = new Dictionary<string, object>();
            paramList.Add("EmpComp.EecCoID", aCOID);
            paramList.Add("EmpComp.EecEEID", aEEID);
            list.Read(paramList);
            return list;
        }

        public void PerformPostProcess(EmpDebitTipConsent EmpDebitTip, CompanyDAL companyDAL)
        {
            String DedCode = String.Empty;

            using (SqlCommand sql = new SqlCommand())
            {
                sql.CommandType = System.Data.CommandType.StoredProcedure;
                sql.CommandText = "[U_LAZ1001_PerformDirectDepositPosting]";
                sql.Parameters.Add(new SqlParameter("@EEID", EmpDebitTip.PrimaryKey["EEID"]));
                sql.Parameters.Add(new SqlParameter("@COID", EmpDebitTip.PrimaryKey["CoID"]));
                sql.Parameters.Add(new SqlParameter("@DebitCard", EmpDebitTip.UDField21));

                companyDAL.ExecuteNonQuery(sql);
            }
        }
    }
	#endregion
}
