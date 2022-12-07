/// <Header summary>
/// Company:    Ultimate Sofware Corp.
/// Author:     Adrian Serrano
/// Client:     Lazy Dog Restaurants, LLC
/// Filename:   UltimateSoftware.Customs.LAZY.Objects\BusinessRules\EmpDebitTipConsentValidator.cs
/// CP Request: SR-2019-00245269
/// Date:       9/12/2019
/// Purpose:    Data Validator for table U_LAZ1001_EmpDebitTipConsent
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
using UltimateSoftware.Diagnostics.Common;
#endregion

#region Custom Using directives
using UltimateSoftware.Customs.LAZ1001.Objects;
#endregion

namespace UltimateSoftware.Customs.LAZ1001.BusinessRules
{
    #region EmpDebitTipConsent Data Validator

	public class EmpDebitTipConsentValidator : ObjectValidator
	{
        public override void OnPropertyValidation(object sender, PropertyValidationEventArgs e)
        {
            base.OnPropertyValidation(sender, e);
            EmpDebitTipConsent obj = (EmpDebitTipConsent)e.Object;
            switch (e.Property.Name)
            {
                default:
                break;
            }
        }

        public override void OnObjectDefaults(object sender, ObjectDefaultEventArgs e)
        {
            base.OnObjectDefaults(sender, e);

            EmpDebitTipConsent obj = (EmpDebitTipConsent)e.Object;
            if (obj.ObjectState == ObjectListItemState.Added)
            {
            }
        }

        public override void OnListDefaults(object sender, ListDefaultEventArgs e)
        {
            base.OnListDefaults(sender, e);
        }
	}
	#endregion
}
