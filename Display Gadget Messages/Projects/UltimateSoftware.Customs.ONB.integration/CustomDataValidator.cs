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
    public class CustomDataValidator : ObjectValidator      //todo: adjust class name
    {
        public override void OnPropertyValidation(object sender, PropertyValidationEventArgs e)
        {
        }
    }
}
