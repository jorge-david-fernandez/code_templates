using System;
using System.Collections.Generic;


//TODO: Always should be in sync with /UltiProServices/UkgProIgniteApi/API/Configuration/PayDetails Helper class.

public class PayDetailsServiceHelper
{
    /// <summary>
    /// Get where clause on base of filter params
    /// </summary>
    /// <param name="payDetailsFilterParams"></param>
    /// <returns></returns>
    public string getWhereClauseForFilters(PayDetailsFilterParams payDetailsFilterParams)
    {
        if (payDetailsFilterParams == null)
            return "";
        string whereClause = getConditionalString(payDetailsFilterParams);
        return whereClause;

    }

    /// <summary>
    /// Get where clause based on filters applied
    /// </summary>
    /// <param name="parameters"></param>
    /// <returns>where clause for filters</returns>
    public string getConditionalString(PayDetailsFilterParams parameters)
    {
        string whereClause = string.Empty;
        string uniqueId = string.Empty;
        if (!(parameters.CompanyName == null))
        {
            if (parameters.CompanyName.Count > 0)
            {
                whereClause += CreateOrJoinWhereClause(whereClause, "Company") + " IN( " + "'" + getInClauseForFilters(parameters.CompanyName).Trim(' ') + "')";
            }
        }
        if (!(parameters.PayItemCode == null))
        {
            if (parameters.PayItemCode.Count > 0)
            {
                whereClause += CreateOrJoinWhereClause(whereClause, "payItemCode") + " IN( " + "'" + getInClauseForFilters(parameters.PayItemCode).Trim(' ') + "')";
            }
        }
        if (!(String.IsNullOrEmpty(parameters.DeductionStartDate)) && !(String.IsNullOrEmpty(parameters.DeductionEndDate)))
        {
            string dateRange = string.Empty;
            whereClause += CreateOrJoinWhereClause(whereClause, "payItemDate") + ">=" + "'" + parameters.DeductionStartDate.Trim(' ') + "'" + " and " + "payItemDate<=" + "'" + parameters.DeductionEndDate.Trim(' ') + "'";
        }
        if (!(String.IsNullOrEmpty(parameters.DeductionStartDate)) && (String.IsNullOrEmpty(parameters.DeductionEndDate)))
        {
            string dateRange = string.Empty;
            whereClause += CreateOrJoinWhereClause(whereClause, "payItemDate") + ">=" + "'" + parameters.DeductionStartDate.Trim(' ') + "'";
        }
        if ((String.IsNullOrEmpty(parameters.DeductionStartDate)) && !(String.IsNullOrEmpty(parameters.DeductionEndDate)))
        {
            string dateRange = string.Empty;
            whereClause += CreateOrJoinWhereClause(whereClause, "payItemDate") + "<=" + "'" + parameters.DeductionEndDate.Trim(' ') + "'";

        }
        if (!(String.IsNullOrEmpty(parameters.EmployeeName)))
        {
            whereClause += CreateOrJoinWhereClause(whereClause, "EmployeeName") + " like  " + "'%" + parameters.EmployeeName.Trim(' ') + "%'";
        }
        if (!(String.IsNullOrEmpty(parameters.EmployeeNumber)))
        {

            whereClause += CreateOrJoinWhereClause(whereClause, "EmployeeNumber") + " like " + "'%" + parameters.EmployeeNumber.Trim(' ') + "%'";
        }
        if (!(parameters.PayGroup == null))
        {
            if (parameters.PayGroup.Count > 0)
            {
                whereClause += CreateOrJoinWhereClause(whereClause, "PayGroup") + " IN( " + "'" + getInClauseForFilters(parameters.PayGroup).Trim(' ') + "')";
            }
        }
        if (!(parameters.PayItemType == null))
        {
            if (parameters.PayItemType.Count > 0)
            {
                whereClause += CreateOrJoinWhereClause(whereClause, "PayItemType") + " IN( " + "'" + getInClauseForFilters(parameters.PayItemType).Trim(' ') + "')";
            }
        }
        if (!(parameters.SourceSystem == null))
        {
            if (parameters.SourceSystem.Count > 0)
            {
                whereClause += CreateOrJoinWhereClause(whereClause, "SourceSystem") + " IN(" + "'" + getInClauseForFilters(parameters.SourceSystem).Trim(' ') + "')";
            }
        }
        if (!(parameters.Status == null))
        {
            if (parameters.Status.Count > 0)
            {
                whereClause += CreateOrJoinWhereClause(whereClause, "Status") + " IN(" + "'" + getInClauseForFilters(parameters.Status).Trim(' ') + "')";
            }
        }
        if (!(parameters.SelectedRowIds == null))
        {
            if (parameters.SelectedRowIds.Length > 0)
            {
                uniqueId = string.Join("','", parameters.SelectedRowIds);
                whereClause += CreateOrJoinWhereClause(whereClause, "UniqueId") + " IN(" + "'" + uniqueId.Trim(' ') + "')";
            }
        }
        if (!(parameters.DeselectedRowIds == null))
        {
            if (parameters.DeselectedRowIds.Length > 0)
            {
                uniqueId = string.Join("','", parameters.DeselectedRowIds);
                whereClause += CreateOrJoinWhereClause(whereClause, "UniqueId") + " NOT IN(" + "'" + uniqueId.Trim(' ') + "')";
            }
        }
        return whereClause;
    }

    /// <summary>
    /// Join array values to get in clause string
    /// </summary>
    /// <param name="inClause"></param>
    /// <returns></returns>
    public string getInClauseForFilters(IList<PayDetailsFiltersMetadata> inClause)
    {
        string joinFilters = string.Empty;
        List<string> list = new List<string>();
        foreach (var item in inClause)
        {
            list.Add(item.value);
        }
        joinFilters = string.Join("','", list);
        return joinFilters;
    }

    /// <summary>
    /// Check if where clause is not empty then append with and else not.
    /// </summary>
    /// <param name="whereClause"></param>
    /// <param name="newCondition"></param>
    /// <returns></returns>
    private string CreateOrJoinWhereClause(string whereClause, string newCondition)
    {
        return string.Format("{0}{1}", (string.IsNullOrEmpty(whereClause) ? "" : " and "), newCondition);
    }
}

