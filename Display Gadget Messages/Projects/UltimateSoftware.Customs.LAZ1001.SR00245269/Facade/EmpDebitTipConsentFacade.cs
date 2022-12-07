/// <Header summary>
/// Company:    Ultimate Sofware Corp.
/// Author:     Adrian Serrano
/// Client:     Lazy Dog Restaurants, LLC
/// Filename:   UltimateSoftware.Customs.LAZY.Facade\EmpDebitTipConsentFacade.cs
/// CP Request: SR-2019-00245269
/// Date:       9/12/2019
/// Purpose:    Facade for table U_LAZ1001_EmpDebitTipConsent
///
/// Last Modified: 
/// 
/// </Header summary>

#region Using directives
using System;
using System.Collections.Generic;
using System.Text;
using UltimateSoftware.ObjectModel.DataAccess;
using UltimateSoftware.ObjectModel.BusinessProcesses;
using UltimateSoftware.ObjectModel.Objects;
using UltimateSoftware.ObjectModel.Base;
using UltimateSoftware.ObjectModel.Common;
using UltimateSoftware.Common;
#endregion

#region Custom Using directives
using UltimateSoftware.Customs.LAZ1001.Objects;
using UltimateSoftware.Customs.LAZ1001.DataAccess;
using UltimateSoftware.Customs.LAZ1001.BusinessRules;
#endregion

namespace UltimateSoftware.Customs.LAZ1001.Facade
{
    #region EmpDebitTipConsent Facade

    public class EmpDebitTipConsentFacade : UltimateSoftware.ObjectModel.Facade.BaseFacade
    {
        public EmpDebitTipConsentFacade()
        {
        }

        public EmpDebitTipConsentFacade(UserContextData userContextData)
        {
            this.UserContextData = userContextData;
        }

        [BDUAssociatedClass(typeof(EmpDebitTipConsent), FacadeMethodType.SetterMethod)]
        public void SetEmpDebitTipConsent(EmpDebitTipConsentList aEmpDebitTipConsentList)
        {
            EmpDebitTipConsentDA DA = new EmpDebitTipConsentDA();
            DA.SetEmpDebitTipConsent(aEmpDebitTipConsentList);
        }

        [BDUAssociatedClass(typeof(EmpDebitTipConsent), FacadeMethodType.FactoryMethod)]
        public EmpDebitTipConsentList GetEmpDebitTipConsent()
        {
            EmpDebitTipConsentDA DA = new EmpDebitTipConsentDA();
            return DA.GetEmpDebitTipConsent();
        }

		[BDUAssociatedClass(typeof(EmpDebitTipConsent), FacadeMethodType.GetterMethod)]
        public EmpDebitTipConsentList GetEmpDebitTipConsentByKey(string aCOID,  string aEEID)
        {
            EmpDebitTipConsentDA DA = new EmpDebitTipConsentDA();
            return DA.GetEmpDebitTipConsentByKey(aCOID, aEEID);
        }

        [BDUAssociatedClass(typeof(EmpDebitTipConsent), FacadeMethodType.SetterMethod)]
        public void PostProcessEmpDebitTipConsent(EmpDebitTipConsentList aEmpDebitTipConsentList)
        {
            EmpDebitTipConsentDA DA = new EmpDebitTipConsentDA();
            DA.PostProcessEmpDebitTipConsent(aEmpDebitTipConsentList);
        }
    }
	#endregion
}
