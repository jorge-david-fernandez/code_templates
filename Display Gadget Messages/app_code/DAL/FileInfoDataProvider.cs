using System;
using System.Data;
using System.Data.SqlClient;
using UltimateSoftware.EntityManager;
using UltimateSoftware.WebControls;
using UltimateSoftware.Diagnostics.Common;

/// <summary>
/// provides methods to get data from FileIno Db entity 
/// </summary>
public class FileInfoDataProvider
{

    private ConnectionInfo _connectionInfo;

    public FileInfoDataProvider(ConnectionInfo connectionInfo)
    {
        _connectionInfo = connectionInfo;
    }

    public FileInfoEntity GetFileInfo(string eeid, string coid)
    {
        FileInfoEntity fileInfo = new FileInfoEntity();

        try
        {
            using (DataCommand dc = new DataCommand())
            {
                dc.ConnectionInfo = this._connectionInfo;
                dc.SQL = "SELECT TOP 1 filFileName, filSystemID FROM FileInfo WITH (NOLOCK) WHERE filFileType = 'P' AND filExpirationDate > getDate() AND filEEID = @EEID AND filComponentCOID = @COID order by filcreatedate desc";
                dc.SqlParameters.Add("@EEID", SqlDbType.VarChar, eeid);
                dc.SqlParameters.Add("@COID", SqlDbType.VarChar, coid);
                dc.CommandType = CommandType.Text;

                using (SqlDataReader dr = dc.ExecuteReader())
                {
                    while (dr.Read())
                    {
                        var imageName = (dr.IsDBNull(0)) ? "" : dr.GetString(0);
                        var systemId = (dr.IsDBNull(1)) ? "" : dr.GetString(1);
                        fileInfo = new FileInfoEntity(imageName, systemId);
                    }
                    dr.Close();
                }
            }

        }
        catch (Exception e)
        {
            Log.WriteLogEntry("00000", new ExceptionData(e, string.Format("Unable to get Data from FileInfo table for EEID - '{0}' and COID - '{1}'", eeid, coid)));
        }

        return fileInfo;
    }
}

public class FileInfoEntity
{
    public FileInfoEntity(string imageName = "", string systemId = ""){
        ImageName = imageName;
        SystemID = systemId;
    }

    public string ImageName {
        get;
        private set;
    }

    public string SystemID {
        get;
        private set;
    }
}
