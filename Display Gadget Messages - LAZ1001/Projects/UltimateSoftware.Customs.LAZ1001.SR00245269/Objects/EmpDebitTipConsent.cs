/// <Header summary>
/// Company:    Ultimate Sofware Corp.
/// Author:     Adrian Serrano
/// Client:     Lazy Dog Restaurants, LLC
/// Filename:   UltimateSoftware.Customs.LAZY.Objects\Objects\EmpDebitTipConsent.cs
/// CP Request: SR-2019-00245269
/// Date:       9/12/2019
/// Purpose:    Object for table U_LAZ1001_EmpDebitTipConsent
///
/// Last Modified: 
/// 
/// </Header summary>

#region Using directives
using System;
using System.Collections.Generic;
using System.Text;
using System.IO;
using UltimateSoftware.ObjectModel.Base;
using UltimateSoftware.DataAccessLayer;
using UltimateSoftware.ObjectModel.Common;
#endregion

#region Custom Using directives
#endregion

namespace UltimateSoftware.Customs.LAZ1001.Objects
{
    #region EmpDebitTipConsent class
    [Serializable]
	public class EmpDebitTipConsent : ObjectListItem
	{

		new public class Properties: ObjectListItem.Properties
		{
            public const string EEID = "EEID";
            public const string CoID = "CoID";
            public const string UDField21 = "UDField21";
            public const string UDField22 = "UDField22";
            public const string UDField05 = "UDField05";
            public const string UDField06 = "UDField06";
            public const string UDField24 = "UDField24";
            public const string UDField23 = "UDField23";
        }

		public EmpDebitTipConsent() : base()
		{
		}

		public EmpDebitTipConsent(ObjectBase parent):base(parent)
		{
		}

        public EmpDebitTipConsent(ObjectBase parent, IObjectList ol)
            : base(parent, ol)
		{
		}

		protected override void InitObject()
		{
            base.InitObject();
            base.AddDataElement(Properties.EEID, String.Empty, typeof(string));
            base.AddDataElement(Properties.CoID, String.Empty, typeof(string));
            base.AddDataElement(Properties.UDField21, String.Empty, typeof(string));
            base.AddDataElement(Properties.UDField22, String.Empty, typeof(string));
            base.AddDataElement(Properties.UDField05, String.Empty, typeof(string));
            base.AddDataElement(Properties.UDField06, null, typeof(DateTime));
            base.AddDataElement(Properties.UDField24, String.Empty, typeof(string));
            base.AddDataElement(Properties.UDField23, String.Empty, typeof(string));
        }

		public void SetEmpDebitTipConsent
		(
           string aEEID,
            string aCoID,
            string aUDField21,
            string aUDField22,
            string aUDField05,
            DateTime aUDField06,
            string aUDField24,
            string aUDField23
        )
		{
            this.EEID = aEEID;
            this.CoID = aCoID;
            this.UDField21 = aUDField21;
            this.UDField22 = aUDField22;
            this.UDField05 = aUDField05;
            this.UDField06 = aUDField06;
            this.UDField24 = aUDField24;
            this.UDField23 = aUDField23;
        }

        #region Property Getter/Setters

        public string EEID
        {
            get { return (string)this[Properties.EEID]; }
            set { this[Properties.EEID] = value; }
        }

        public string CoID
        {
            get { return (string)this[Properties.CoID]; }
            set { this[Properties.CoID] = value; }
        }

        public string UDField21
        {
            get { return (string)this[Properties.UDField21]; }
            set { this[Properties.UDField21] = value; }
        }

        public string UDField22
        {
            get { return (string)this[Properties.UDField22]; }
            set { this[Properties.UDField22] = value; }
        }

        public string UDField05
        {
            get { return (string)this[Properties.UDField05]; }
            set { this[Properties.UDField05] = value; }
        }

        public DateTime UDField06
        {
            get { return (DateTime)this[Properties.UDField06]; }
            set { this[Properties.UDField06] = value; }
        }

        public string UDField24
        {
            get { return (string)this[Properties.UDField24]; }
            set { this[Properties.UDField24] = value; }
        }

        public string UDField23
        {
            get { return (string)this[Properties.UDField23]; }
            set { this[Properties.UDField23] = value; }
        }


        #endregion

    } //end class EmpDebitTipConsent
    #endregion

    #region EmpDebitTipConsentList class
    [Serializable]
	public class EmpDebitTipConsentList : DBObjectList
	{

     public EmpDebitTipConsentList() : base(typeof(EmpDebitTipConsent))
      {
      }

     public EmpDebitTipConsentList(string mappingsFileName) : base(typeof(EmpDebitTipConsent), mappingsFileName)
      {
      }

     public EmpDebitTipConsentList(ObjectBase parent) : base(typeof(EmpDebitTipConsent), parent)
      {
      }

     public EmpDebitTipConsentList(ObjectBase parent, string mappingsFileName) : base(typeof(EmpDebitTipConsent), parent, mappingsFileName)
      {
      }

     public EmpDebitTipConsentList(TextReader reader) : base(typeof(EmpDebitTipConsent), reader)
      {
      }

     public EmpDebitTipConsentList(Type type) : base(type)
      {
      }

     public EmpDebitTipConsentList(Type type, string mappingsFileName): base(type, mappingsFileName)
      {
      }

     public EmpDebitTipConsentList(Type type, ObjectBase parent): base(type, parent)
      {
      }

     public EmpDebitTipConsentList(Type type, ObjectBase parent, string mappingsFileName): base(type, parent, mappingsFileName)
      {
      }

     public EmpDebitTipConsentList(Type type, TextReader reader): base(type, reader)
      {
      }

     public new EmpDebitTipConsent this[int index]
      {
          get { return (EmpDebitTipConsent)base[index]; }
      }

     public EmpDebitTipConsent NewEmpDebitTipConsent()
      {
          return (EmpDebitTipConsent)NewObject();
      }

     public EmpDebitTipConsent AddEmpDebitTipConsent
		(
             string aEEID,
            string aCoID,
            string aUDField21,
            string aUDField22,
            string aUDField05,
            DateTime aUDField06,
            string aUDField24,
            string aUDField23
        )
		{
            EmpDebitTipConsent aEmpDebitTipConsent = NewEmpDebitTipConsent();

      aEmpDebitTipConsent.SetEmpDebitTipConsent
      (
           aEEID,
            aCoID,
            aUDField21,
            aUDField22,
            aUDField05,
            aUDField06,
            aUDField24,
            aUDField23
        );

			Add(aEmpDebitTipConsent);
			return aEmpDebitTipConsent;
		}

	}	//end class EmpDebitTipConsentList

#endregion
}
