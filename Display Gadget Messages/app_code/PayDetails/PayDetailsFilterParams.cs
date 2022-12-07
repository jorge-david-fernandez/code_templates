using System.Collections.Generic;
public class PayDetailsFilterParams
{
    public IList<PayDetailsFiltersMetadata> CompanyName { get; set; }
    public IList<PayDetailsFiltersMetadata> Status { get; set; }
    public IList<PayDetailsFiltersMetadata> PayItemType { get; set; }
    public IList<PayDetailsFiltersMetadata> PayGroup { get; set; }
    public IList<PayDetailsFiltersMetadata> SourceSystem { get; set; }
    public string EmployeeName { get; set; }
    public string EmployeeNumber { get; set; }
    public string DeductionStartDate { get; set; }
    public string DeductionEndDate { get; set; }
    public IList<PayDetailsFiltersMetadata> PayItemCode { get; set; }
    public string[] DeselectedRowIds { get; set; }
    public string[] SelectedRowIds { get; set; }
    public string FileType { get; set; }
    public bool IsExportAll { get; set; }

}

