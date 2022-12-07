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
using System.Data.SqlClient;
using UltimateSoftware.ObjectModel.Common;
using UltimateSoftware.ObjectModel.Base;
using UltimateSoftware.ObjectModel.Objects;
using UltimateSoftware.DataAccessLayer;
using UltimateSoftware.ObjectModel.BusinessRules;
using UltimateSoftware.Diagnostics.Common;
#endregion

namespace UltimateSoftware.Customs.LAZ1001.BPCustomSteps
{
    public class NewHireStepValidator : ObjectValidator      //todo: adjust class name
    {
        public override void OnPropertyValidation(object sender, PropertyValidationEventArgs e)
        {
        }
    }
}