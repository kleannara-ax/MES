using System;
using System.Data;
using System.Data.Common;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Configuration;
using System.Data.SqlClient;
using Microsoft.Practices.EnterpriseLibrary.Common.Configuration;
using Microsoft.Practices.EnterpriseLibrary.Data;
using Oracle.ManagedDataAccess.Client;

namespace SAMMI
{
    public class DBHelper
    {
        //public Database db;
        private DbConnection _sConn = null;
        private DbTransaction _sTran = null;
        private DbCommand oCmd = null;
        public bool Oracle = false;
        private bool _completedClose = false;
        private Configuration appConfig = ConfigurationManager.OpenExeConfiguration(ConfigurationUserLevel.None);
        public DbProviderFactory dataFactory = null;
        public string RSCODE = "S";
        public string RSMSG = String.Empty;
        public bool bConFail = false;
        public string var1 = string.Empty;

        public int cnt = 0;
        public List<string> output = new List<string>();

        //private bool _bEncrypt = false;

        public string ConType
        {
            get { return _sConn.GetType().Name; }
        }

        public DbConnection DBConnect
        {
            get { return _sConn; }
        }

        public DbParameterCollection Parameters
        {
            get { return oCmd.Parameters; }
        }

        private bool Init(string conStr, bool btran, bool completedClose)
        {
            try
            {
                //if (conStr == "SmartWMS")
                //{
                //    conStr = "Persist Security Info=True;Data Source=125.141.59.78,3780;Initial Catalog=ASRS1;User ID=sa;Password=sammi32~!~!~!;Connect Timeout=10";
                //    dataFactory = DbProviderFactories.GetFactory("System.Data.SqlClient");
                //}
                //else
                {
                    if (conStr == "")
                    {
                        conStr = appConfig.ConnectionStrings.ConnectionStrings["ConnectionString"].ConnectionString;
                        conStr = SAMMI.Common.DecryptString(conStr);
                    }

                    dataFactory = DbProviderFactories.GetFactory("Oracle.ManagedDataAccess.Client");
                    this.Oracle = true;
                }

                _completedClose = completedClose;
                _sConn = dataFactory.CreateConnection();
                _sConn.ConnectionString = conStr;
                _sConn.Open();
                if (btran)
                    _sTran = _sConn.BeginTransaction();
            }
            catch (Exception ex)
            {
                string sExMessage = ex.Message;
                //System.Windows.Forms.MessageBox.Show(ex.Message, "DB Error!!");
                bConFail = true;
                return true;
            }
            bConFail = false;
            return false;

        }

        public DBHelper()
        {
            Init("", false, false);
        }

        public DBHelper(bool completedClose)
        {
            Init("", false, completedClose);

        }

        public DBHelper(bool completedClose, string conStr)
        {
            Init(conStr, false, completedClose);
        }

        public DBHelper(string conStr, bool bTrans)
        {
            Init(conStr, bTrans, false);
        }

        public DBHelper(bool completedClose, string conStr, bool bTrans)
        {
            Init(conStr, bTrans, completedClose);
        }

        public void Close()
        {
            Close(true);
        }

        public void Close(bool bCommit)
        {
            try
            {
                if (_sTran != null)
                {
                    if (bCommit)
                        _sTran.Commit();
                    else
                        _sTran.Rollback();
                }
                _sConn.Close();
            }
            catch { }
        }

        public void Commit()
        {
            if (_sTran != null)
            {
                _sTran.Commit();
                _sTran = null;
            }
        }

        public void Rollback()
        {
            if (_sTran != null)
            {
                _sTran.Rollback();
                _sTran = null;
            }
        }

        public Database CreateDataBase()
        {
            Configuration appConfig = ConfigurationManager.OpenExeConfiguration(ConfigurationUserLevel.None);
            string conStr = appConfig.ConnectionStrings.ConnectionStrings["ConnectionString"].ConnectionString;
            conStr = SAMMI.Common.DecryptString(conStr);

            var builder = new ConfigurationSourceBuilder();

            builder.ConfigureData()
                   .ForDatabaseNamed("DBConn")
                     .ThatIs.ASqlDatabase()
                     .WithConnectionString(@conStr);

            var configSource = new DictionaryConfigurationSource();
            builder.UpdateConfigurationWithReplace(configSource);

            Microsoft.Practices.EnterpriseLibrary.Common.Configuration.EnterpriseLibraryContainer.Current = EnterpriseLibraryContainer.CreateDefaultContainer(configSource);

            return DatabaseFactory.CreateDatabase("DBConn");
        }

        public static DataTable Join(DataTable First, DataTable Second, string[] FJC, string[] SJC, string flg = "JOIN")
        {
            DataTable table = new DataTable("Join");
            using (DataSet ds = new DataSet())
            {
                ds.Tables.AddRange(new DataTable[] { First.Copy(), Second.Copy() });
                DataColumn[] parentcolumns = new DataColumn[FJC.Length];
                for (int i = 0; i < parentcolumns.Length; i++)
                {
                    parentcolumns[i] = ds.Tables[0].Columns[FJC[i].ToString()];
                }
                DataColumn[] childcolumns = new DataColumn[SJC.Length];
                for (int i = 0; i < childcolumns.Length; i++)
                {
                    childcolumns[i] = ds.Tables[1].Columns[SJC[i].ToString()];
                }
                DataRelation r = new DataRelation(string.Empty, parentcolumns, childcolumns, false);
                if (flg != "CJOIN")
                {
                    ds.Relations.Add(r);
                }
                for (int i = 0; i < First.Columns.Count; i++)
                {
                    table.Columns.Add(First.Columns[i].ColumnName, First.Columns[i].DataType);
                    table.Columns[i].DefaultValue = 0;
                }
                for (int i = 0; i < Second.Columns.Count; i++)
                {
                    if (!table.Columns.Contains(Second.Columns[i].ColumnName))
                    {
                        table.Columns.Add(Second.Columns[i].ColumnName, Second.Columns[i].DataType);
                    }
                    else
                    {
                        table.Columns.Add(Second.Columns[i].ColumnName + "_" + Second.TableName, Second.Columns[i].DataType);
                    }
                    table.Columns[First.Columns.Count + i].DefaultValue = 0;
                }
                table.BeginLoadData();

                if (flg.ToUpper() == "JOIN")
                {
                    object[] parentarray = null;
                    object[] secondarray = null;
                    object[] joinarray = null;
                    foreach (DataRow firstrow in ds.Tables[0].Rows)
                    {
                        parentarray = firstrow.ItemArray;
                        joinarray = new object[parentarray.Length];
                        Array.Copy(parentarray, 0, joinarray, 0, parentarray.Length);
                        table.LoadDataRow(joinarray, true);
                    }
                    foreach (DataRow secondrow in ds.Tables[1].Rows)
                    {
                        secondarray = secondrow.ItemArray;
                        joinarray = new object[secondarray.Length];
                        Array.Copy(secondarray, 0, joinarray, 0, secondarray.Length);
                        table.LoadDataRow(joinarray, true);
                    }
                }
                else if (flg == "CJOIN")
                {
                    object[] parentarray = null;
                    object[] secondarray = null;
                    object[] joinarray = null;
                    foreach (DataRow firstrow in ds.Tables[0].Rows)
                    {
                        parentarray = firstrow.ItemArray;
                        foreach (DataRow secondrow in ds.Tables[1].Rows)
                        {
                            secondarray = secondrow.ItemArray;
                            joinarray = new object[parentarray.Length + secondarray.Length];
                            Array.Copy(parentarray, 0, joinarray, 0, parentarray.Length);
                            Array.Copy(secondarray, 0, joinarray, parentarray.Length, secondarray.Length);
                            table.LoadDataRow(joinarray, true);
                        }
                    }
                }
                else // Left Outer Join & Inner Join
                {
                    foreach (DataRow firstrow in ds.Tables[0].Rows)
                    {
                        DataRow[] childrows = firstrow.GetChildRows(r);
                        if (flg.ToUpper() == "LOJ")
                        {
                            object[] parentarray = firstrow.ItemArray;
                            object[] joinarray = null;
                            if (childrows != null && childrows.Length > 0)
                            {
                                foreach (DataRow secondrow in childrows)
                                {
                                    object[] secondarray = secondrow.ItemArray;
                                    joinarray = new object[parentarray.Length + secondarray.Length];
                                    Array.Copy(parentarray, 0, joinarray, 0, parentarray.Length);
                                    Array.Copy(secondarray, 0, joinarray, parentarray.Length, secondarray.Length);
                                    table.LoadDataRow(joinarray, true);
                                }
                            }
                            else
                            {
                                joinarray = new object[parentarray.Length];
                                Array.Copy(parentarray, 0, joinarray, 0, parentarray.Length);
                                table.LoadDataRow(joinarray, true);
                            }
                        }
                        // Inner Join
                        else if (flg.ToUpper() == "IJ")
                        {
                            if (childrows != null && childrows.Length > 0)
                            {
                                object[] parentarray = firstrow.ItemArray;
                                foreach (DataRow secondrow in childrows)
                                {
                                    object[] secondarray = secondrow.ItemArray;
                                    object[] joinarray = new object[parentarray.Length + secondarray.Length];
                                    Array.Copy(parentarray, 0, joinarray, 0, parentarray.Length);
                                    Array.Copy(secondarray, 0, joinarray, parentarray.Length, secondarray.Length);
                                    table.LoadDataRow(joinarray, true);
                                }
                            }
                        }
                    }
                }

                table.EndLoadData();
            }
            return table;
        }

        public void FillSchema(DataTable dt, string query, CommandType commandType)
        {
            oCmd = _sConn.CreateCommand();
            oCmd.Connection = _sConn;
            oCmd.CommandText = query;
            oCmd.CommandType = commandType;

            DbDataAdapter oAdap = dataFactory.CreateDataAdapter();
            oAdap.SelectCommand = oCmd;

            oAdap.FillSchema(dt, SchemaType.Source);

            if (_completedClose)
                Close();

            for (int i = 0; i < dt.Columns.Count; i++)
            {
                dt.Columns[i].ColumnName = dt.Columns[i].ColumnName.ToUpper();
            }
        }

        public void FillTable(DataTable dt, string query, CommandType commandType, params Object[] parameters)
        {
            FillTable(dt, query, commandType, true, true, parameters);
        }
        public void FillTable(DataTable dt, string query, CommandType commandType, bool baddLang, bool baddOut, params Object[] parameters)
        {
            oCmd = _sConn.CreateCommand();
            oCmd.Connection = _sConn;
            oCmd.CommandText = query;
            oCmd.CommandType = commandType;

            RSCODE = "S";
            RSMSG = String.Empty;

            if (parameters != null)
            {
                for (int i = 0; i < parameters.Length; i++)
                {
                    oCmd.Parameters.Add(parameters[i]);
                }
            }

            if (commandType == CommandType.StoredProcedure)
            {

                if (baddLang)
                {
                    oCmd.Parameters.Add(this.CreateParameter("Lang", DbType.String, SAMMI.Common.Lang));
                }
                if (baddOut)
                {
                    oCmd.Parameters.Add(this.CreateParameter("RS_CODE", DbType.String, ParameterDirection.Output, null, 1));
                    oCmd.Parameters.Add(this.CreateParameter("RS_MSG", DbType.String, ParameterDirection.Output, null, 200));
                }

                if (this.Oracle)
                {
                    oCmd.Parameters.Add(new OracleParameter("CUR_1", OracleDbType.RefCursor, ParameterDirection.Output));
                }
            }

            DbDataAdapter oAdap = dataFactory.CreateDataAdapter();
            oAdap.SelectCommand = oCmd;

            oAdap.Fill(dt);

            if (commandType == CommandType.StoredProcedure && baddOut)
            {
                RSMSG = Convert.ToString(oCmd.Parameters["RS_MSG"].Value);
                RSCODE = Convert.ToString(oCmd.Parameters["RS_CODE"].Value);
            }
            if (_completedClose)
                Close();

            for (int i = 0; i < dt.Columns.Count; i++)
            {
                dt.Columns[i].ColumnName = dt.Columns[i].ColumnName.ToUpper();
            }
        }
        public DataTable FillTable(string query, CommandType commandType, params Object[] parameters)
        {
            return FillTable(query, commandType, true, true, parameters);
        }
        public DataTable FillTable1(string query, CommandType commandType, int cnt, params Object[] parameters)// 오라클 output 변수를 위함
        {
            return FillTable1(query, commandType, true, true, cnt, parameters);
        }

        private DataTable FillTable1(string query, CommandType commandType, bool baddLang, bool baddOut, int cnt, params Object[] parameters)
        {
            oCmd = _sConn.CreateCommand();
            oCmd.Connection = _sConn;
            oCmd.CommandText = query;
            oCmd.CommandType = commandType;

            RSCODE = "S";
            RSMSG = String.Empty;

            if (parameters != null)
            {
                for (int i = 0; i < parameters.Length; i++)
                {
                    oCmd.Parameters.Add(parameters[i]);
                }
            }
            if (commandType == CommandType.StoredProcedure)
            {
                if (baddLang)
                {
                    oCmd.Parameters.Add(this.CreateParameter("LANG", DbType.String, SAMMI.Common.Lang));
                }
                if (baddOut)
                {
                    oCmd.Parameters.Add(this.CreateParameter("RS_CODE", DbType.String, ParameterDirection.Output, null, 1));
                    oCmd.Parameters.Add(this.CreateParameter("RS_MSG", DbType.String, ParameterDirection.Output, null, 200));
                }
                if (this.Oracle)
                {
                    oCmd.Parameters.Add(new OracleParameter("CUR_1", OracleDbType.RefCursor, ParameterDirection.Output));
                }
            }
            DbDataAdapter oAdap = dataFactory.CreateDataAdapter();
            oAdap.SelectCommand = oCmd;

            //DataSet ds   = new DataSet();
            DataTable dt = new DataTable();
            oAdap.Fill(dt);

            if (commandType == CommandType.StoredProcedure && baddOut)
            {
                RSMSG = Convert.ToString(oCmd.Parameters["RS_MSG"].Value);
                RSCODE = Convert.ToString(oCmd.Parameters["RS_CODE"].Value);
            }
            for (int i = parameters.Length - cnt; i < parameters.Length; i++)
            {
                var1 = oCmd.Parameters[i].ToString();
                output.Add(Convert.ToString(oCmd.Parameters[var1].Value));
            }

            if (_completedClose)
                Close();

            // 해당 주석 차후에 수정 예정 

            //bool bPlant = false;
            for (int i = 0; i < dt.Columns.Count; i++)
            {
                dt.Columns[i].ColumnName = dt.Columns[i].ColumnName.ToUpper();
                //if (!bPlant && dt.Columns[i].ColumnName.Equals("PLANTCODE"))
                //{
                //    bPlant = true;
                //}
            }

            //사업장권한 설정
            //if (Common.bPlantAuth && SAMMI.LoginInfo.UserID != "SYSTEM" && bPlant)
            //{
            //    if (Common.dtPlantAuth != null)
            //    {
            //        dt = Join(dt, Common.dtPlantAuth, new string[] { "PLANTCODE " }, new string[] { "PLANTCODE" });
            //    }
            //}

            return dt;
        }


        public DataTable FillTable(string query, CommandType commandType, bool baddLang, bool baddOut, params Object[] parameters)
        {
            oCmd = _sConn.CreateCommand();
            oCmd.Connection = _sConn;
            oCmd.CommandText = query;
            oCmd.CommandType = commandType;

            RSCODE = "S";
            RSMSG = String.Empty;

            if (parameters != null)
            {
                for (int i = 0; i < parameters.Length; i++)
                {
                    oCmd.Parameters.Add(parameters[i]);
                }
            }

            if (commandType == CommandType.StoredProcedure)
            {

                if (baddLang)
                {
                    oCmd.Parameters.Add(this.CreateParameter("Lang", DbType.String, SAMMI.Common.Lang));
                }
                if (baddOut)
                {
                    oCmd.Parameters.Add(this.CreateParameter("RS_CODE", DbType.String, ParameterDirection.Output, null, 1));
                    oCmd.Parameters.Add(this.CreateParameter("RS_MSG", DbType.String, ParameterDirection.Output, null, 200));
                }

                if (this.Oracle)
                {
                    oCmd.Parameters.Add(new OracleParameter("CUR_1", OracleDbType.RefCursor, ParameterDirection.Output));
                }
            }

            DbDataAdapter oAdap = dataFactory.CreateDataAdapter();
            oAdap.SelectCommand = oCmd;

            //DataSet ds   = new DataSet();
            DataTable dt = new DataTable();
            oAdap.Fill(dt);

            if (commandType == CommandType.StoredProcedure && baddOut)
            {
                RSMSG = Convert.ToString(oCmd.Parameters["RS_MSG"].Value);
                RSCODE = Convert.ToString(oCmd.Parameters["RS_CODE"].Value);
            }
            if (_completedClose)
                Close();

            // 해당 주석 차후에 수정 예정 

            //bool bPlant = false;
            for (int i = 0; i < dt.Columns.Count; i++)
            {
                dt.Columns[i].ColumnName = dt.Columns[i].ColumnName.ToUpper();
                //if (!bPlant && dt.Columns[i].ColumnName.Equals("PLANTCODE"))
                //{
                //    bPlant = true;
                //}
            }

            //사업장권한 설정
            //if (Common.bPlantAuth && SAMMI.LoginInfo.UserID != "SYSTEM" && bPlant)
            //{
            //    if (Common.dtPlantAuth != null)
            //    {
            //        dt = Join(dt, Common.dtPlantAuth, new string[] { "PLANTCODE " }, new string[] { "PLANTCODE" });
            //    }
            //}

            return dt;
        }
        public DataTable FillTable(string query)//, List<DbParameter> param = null)
        {
            Object[] parameters = null;
            return FillTable(query, CommandType.Text, parameters);//, param.ToArray());
        }
        public DataTable FillTable(string query, CommandType commandType, List<DbParameter> param)
        {
            return FillTable(query, commandType, param.ToArray());
        }

        public DataSet FillDataSet(string query, CommandType commandType, params Object[] parameters)
        {
            return FillDataSet(query, commandType, true, true, parameters);
        }
        public DataSet FillDataSetN(string query, CommandType commandType, int tableCnt, params Object[] parameters)
        {
            return FillDataSetN(query, commandType, true, true, tableCnt, parameters);
        }
        public DataSet FillDataSet(string query, CommandType commandType, bool baddLang, bool baddOut, params Object[] parameters)
        {
            oCmd = _sConn.CreateCommand();
            oCmd.Connection = _sConn;
            oCmd.CommandText = query;
            oCmd.CommandType = commandType;

            RSCODE = "S";
            RSMSG = String.Empty;

            if (parameters != null)
            {
                for (int i = 0; i < parameters.Length; i++)
                {
                    oCmd.Parameters.Add(parameters[i]);
                }
            }

            if (commandType == CommandType.StoredProcedure)
            {
                if (baddLang)
                {
                    oCmd.Parameters.Add(this.CreateParameter("Lang", DbType.String, SAMMI.Common.Lang));
                }
                if (baddOut)
                {
                    oCmd.Parameters.Add(this.CreateParameter("RS_CODE", DbType.String, ParameterDirection.Output, null, 1));
                    oCmd.Parameters.Add(this.CreateParameter("RS_MSG", DbType.String, ParameterDirection.Output, null, 200));
                }

                if (this.Oracle)
                {
                    oCmd.Parameters.Add(new OracleParameter("CUR_1", OracleDbType.RefCursor, ParameterDirection.Output));
                }
            }
            DbDataAdapter oAdap = dataFactory.CreateDataAdapter();
            oAdap.SelectCommand = oCmd;
            DataSet ds = new DataSet();

            oAdap.Fill(ds);

            if (commandType == CommandType.StoredProcedure && baddOut)
            {
                RSMSG = Convert.ToString(oCmd.Parameters["RS_MSG"].Value);
                RSCODE = Convert.ToString(oCmd.Parameters["RS_CODE"].Value);
            }

            if (_completedClose)
                Close();
            foreach (DataTable dt in ds.Tables)
            {
                for (int i = 0; i < dt.Columns.Count; i++)
                {
                    dt.Columns[i].ColumnName = dt.Columns[i].ColumnName.ToUpper();
                }
            }
            return ds;
        }
        public DataSet FillDataSetN(string query, CommandType commandType, bool baddLang, bool baddOut, int tableCnt, params Object[] parameters)
        {
            oCmd = _sConn.CreateCommand();
            oCmd.Connection = _sConn;
            oCmd.CommandText = query;
            oCmd.CommandType = commandType;

            RSCODE = "S";
            RSMSG = String.Empty;

            if (parameters != null)
            {
                for (int i = 0; i < parameters.Length; i++)
                {
                    oCmd.Parameters.Add(parameters[i]);
                }
            }

            if (commandType == CommandType.StoredProcedure)
            {
                if (baddLang)
                {
                    oCmd.Parameters.Add(this.CreateParameter("Lang", DbType.String, SAMMI.Common.Lang));
                }
                if (baddOut)
                {
                    oCmd.Parameters.Add(this.CreateParameter("RS_CODE", DbType.String, ParameterDirection.Output, null, 1));
                    oCmd.Parameters.Add(this.CreateParameter("RS_MSG", DbType.String, ParameterDirection.Output, null, 200));
                }

                if (this.Oracle)
                {
                    for(int i=1;i<=tableCnt;i++)
                        oCmd.Parameters.Add(new OracleParameter("CUR_" + i.ToString(), OracleDbType.RefCursor, ParameterDirection.Output));
                }
            }
            DbDataAdapter oAdap = dataFactory.CreateDataAdapter();
            oAdap.SelectCommand = oCmd;
            DataSet ds = new DataSet();

            oAdap.Fill(ds);

            if (commandType == CommandType.StoredProcedure && baddOut)
            {
                RSMSG = Convert.ToString(oCmd.Parameters["RS_MSG"].Value);
                RSCODE = Convert.ToString(oCmd.Parameters["RS_CODE"].Value);
            }

            if (_completedClose)
                Close();
            foreach (DataTable dt in ds.Tables)
            {
                for (int i = 0; i < dt.Columns.Count; i++)
                {
                    dt.Columns[i].ColumnName = dt.Columns[i].ColumnName.ToUpper();
                }
            }
            return ds;
        }
        public DataSet FillDataSet(string query, CommandType commandType, List<DbParameter> param)
        {
            return FillDataSet(query, commandType, param.ToArray());
        }
        public DataSet FillDataSet(string query)
        {
            Object[] parameters = null;
            return FillDataSet(query, CommandType.Text, parameters);

        }

        public DataSet OraFillDataSet(string query, int tableCount)
        {
            Object[] parameters = null;
            return OraFillDataSet(query, CommandType.Text, tableCount, parameters);
        }
        public DataSet OraFillDataSet(string query, CommandType commandType, int tableCount, params Object[] parameters)
        {
            return OraFillDataSet(query, commandType, true, true, tableCount, parameters);
        }
        public DataSet OraFillDataSet(string query, CommandType commandType, bool baddLang, bool baddOut, int tableCount, params Object[] parameters)
        {
            oCmd = _sConn.CreateCommand();
            oCmd.Connection = _sConn;
            oCmd.CommandText = query;
            oCmd.CommandType = commandType;

            RSCODE = "S";
            RSMSG = String.Empty;

            if (parameters != null)
            {
                for (int i = 0; i < parameters.Length; i++)
                {
                    oCmd.Parameters.Add(parameters[i]);
                }
            }

            if (commandType == CommandType.StoredProcedure)
            {
                if (baddLang)
                {
                    oCmd.Parameters.Add(this.CreateParameter("Lang", DbType.String, SAMMI.Common.Lang));
                }
                if (baddOut)
                {
                    oCmd.Parameters.Add(this.CreateParameter("RS_CODE", DbType.String, ParameterDirection.Output, null, 1));
                    oCmd.Parameters.Add(this.CreateParameter("RS_MSG", DbType.String, ParameterDirection.Output, null, 200));
                }
                //if (oCmd.GetType().Name == "OracleCommand")
                //{
                //    oCmd.Parameters.Add(new OracleParameter("CUR_1", OracleDbType.RefCursor, ParameterDirection.Output));

                //}
                if (this.Oracle)
                {
                    for (int i = 1; i <= tableCount; i++)
                        oCmd.Parameters.Add(new OracleParameter("CUR_" + i.ToString(), OracleDbType.RefCursor, ParameterDirection.Output));
                }
            }
            DbDataAdapter oAdap = dataFactory.CreateDataAdapter();
            oAdap.SelectCommand = oCmd;
            DataSet ds = new DataSet();

            oAdap.Fill(ds);

            if (commandType == CommandType.StoredProcedure && baddOut)
            {
                RSMSG = Convert.ToString(oCmd.Parameters["RS_MSG"].Value);
                RSCODE = Convert.ToString(oCmd.Parameters["RS_CODE"].Value);
            }

            if (_completedClose)
                Close();
            foreach (DataTable dt in ds.Tables)
            {
                for (int i = 0; i < dt.Columns.Count; i++)
                {
                    dt.Columns[i].ColumnName = dt.Columns[i].ColumnName.ToUpper();
                }
            }
            return ds;
        }

        //2020 05 14 HJH
        /*
         * SDWM0001 과 SDWM0002의 소스를 보면 RFCCall을 이용하여 SAP에서 데이터를 받아옴.
         * 그걸 DataTable에 넣고 프로시저 호출 시 매개변수로 DataTable을 DbType.Object 형식으로 가져감 
         * 그리고 MSSQL의 프로시저에서 사용자 정의 테이블 형식을 매개변수로 선언하여 받게 됨

         * 근데 오라클에서는 위와 같이 C#의 DataTable을 받는 방법이 MSSQL과 조금 달라서 DBhelper Class에 함수가 추가되어야 함(아래 함수 UserTypeFillTable)
         * 우선 DataTable을 받는 방법은 
         * 우리가 FillTable 시 OracleDbType.RefCursor를 이용하여 CUR_1을 ParameterDirection.Output으로 받는것처럼

         * ParameterDirection.InPut으로 OracleDbType.RefCursor타입으로 넘겨야함 (제가 구글 검색했을 땐 이렇게 나왔는데 다른 방법이 있으면 그렇게 해봐도 될듯.)
         * 아래 FillTable이 다른 FillTable하고 다른 점은 비교해보면 알겠지만 DataTable을 직접 Parameter list에 넣는 것이 아닌 따로 함수 매개변수로 받아서

         * CUR_1을 추가해주는 곳에 추가해두었음
         * 테스트는 못해봤으니까 혹시 저 부분이 문제가 되면 연락 주고..
         * 이름은 어떤 걸로 해야될지 몰라서 우선 저렇게 써놨어요.
         * 
         * 지금 개발해야 하는 부분은 결국
         * C#의 DataTable(RFCCall의 Return 값)을 Procedure로 가져가서 WMS 테이블과  Full Join을 한 후에 다시 CUR_1로 받고자 하는 거에요

         * 꼭 제가 말하는 방법대로 안해도 검색이나 생각 했을 때 좋은 방법이 있거나 쉬운 방법이 있으면 그걸로 해봐요.
         * 도저히 이해가 안되거나 잘 모르겠으면 연락 주고
         */
        public DataTable UserTypeFillTable(string query, CommandType commandType, bool baddLang, bool baddOut, DataTable userTypeTable, params Object[] parameters)
        {
            oCmd = _sConn.CreateCommand();
            oCmd.Connection = _sConn;
            oCmd.CommandText = query;
            oCmd.CommandType = commandType;

            RSCODE = "S";
            RSMSG = String.Empty;

            if (parameters != null)
            {
                for (int i = 0; i < parameters.Length; i++)
                {
                    oCmd.Parameters.Add(parameters[i]);
                }
            }

            if (commandType == CommandType.StoredProcedure)
            {

                if (baddLang)
                {
                    oCmd.Parameters.Add(this.CreateParameter("Lang", DbType.String, SAMMI.Common.Lang));
                }
                if (baddOut)
                {
                    oCmd.Parameters.Add(this.CreateParameter("RS_CODE", DbType.String, ParameterDirection.Output, null, 1));
                    oCmd.Parameters.Add(this.CreateParameter("RS_MSG", DbType.String, ParameterDirection.Output, null, 200));
                }

                if (this.Oracle)
                {
                    oCmd.Parameters.Add(new OracleParameter("여기다가 프로시저에서 사용할 명칭을 넣으면 될 거 같은데?", OracleDbType.RefCursor, userTypeTable, ParameterDirection.Input));
                    oCmd.Parameters.Add(new OracleParameter("CUR_1", OracleDbType.RefCursor, ParameterDirection.Output));
                }
            }

            DbDataAdapter oAdap = dataFactory.CreateDataAdapter();
            oAdap.SelectCommand = oCmd;

            DataTable dt = new DataTable();
            oAdap.Fill(dt);

            if (commandType == CommandType.StoredProcedure && baddOut)
            {
                RSMSG = Convert.ToString(oCmd.Parameters["RS_MSG"].Value);
                RSCODE = Convert.ToString(oCmd.Parameters["RS_CODE"].Value);
            }
            if (_completedClose)
                Close();

            for (int i = 0; i < dt.Columns.Count; i++)
            {
                dt.Columns[i].ColumnName = dt.Columns[i].ColumnName.ToUpper();
            }

            return dt;
        }

        public int ExecuteNoneQuery(string query, CommandType commandType, params Object[] parameters)
        {
            return ExecuteNoneQuery(query, commandType, true, true, parameters);
        }
        public int ExecuteNoneQuery(string query, CommandType commandType, List<DbParameter> param)
        {
            return ExecuteNoneQuery(query, commandType, param.ToArray());
        }
        public int ExecuteNoneQuery(string query, CommandType commandType, bool baddLang, bool baddOut, params Object[] parameters)
        {
            oCmd = _sConn.CreateCommand();
            oCmd.Connection = _sConn;
            oCmd.CommandText = query;
            oCmd.CommandType = commandType;

            RSCODE = "S";
            RSMSG = String.Empty;

            if (parameters != null)
            {
                for (int i = 0; i < parameters.Length; i++)
                {
                    oCmd.Parameters.Add(parameters[i]);
                }
            }
            if (commandType == CommandType.StoredProcedure)
            {
                if (baddLang)
                {
                    oCmd.Parameters.Add(this.CreateParameter("LANG", DbType.String, SAMMI.Common.Lang));
                }
                if (baddOut)
                {
                    oCmd.Parameters.Add(this.CreateParameter("RS_CODE", DbType.String, ParameterDirection.Output, null, 1));
                    oCmd.Parameters.Add(this.CreateParameter("RS_MSG", DbType.String, ParameterDirection.Output, null, 200));
                }


            }

            //2020 02 14 HJH
            //if (_sTran != null && oCmd.GetType().Name != "OracleCommand") oCmd.Transaction = _sTran;
            if (_sTran != null) oCmd.Transaction = _sTran;


            int rtn = oCmd.ExecuteNonQuery();

            if (commandType == CommandType.StoredProcedure && baddOut)
            {
                RSMSG = Convert.ToString(oCmd.Parameters["RS_MSG"].Value);
                RSCODE = Convert.ToString(oCmd.Parameters["RS_CODE"].Value);
            }


            if (_completedClose)
                Close();

            return rtn;
        }
        public int ExecuteNoneQuery(string query)
        {
            Object[] parameters = null;
            return ExecuteNoneQuery(query, CommandType.Text, parameters);
        }
        public int ExecuteNoneQuery(string query, CommandType commandType, ref string RS_CODE, ref string RS_MSG, ref string TakingORDNO, params Object[] parameters)
        {
            oCmd = _sConn.CreateCommand();
            oCmd.Connection = _sConn;
            oCmd.CommandText = query;
            oCmd.CommandType = commandType;
            RSCODE = "S";
            RSMSG = String.Empty;

            if (parameters != null)
            {
                for (int i = 0; i < parameters.Length; i++)
                {
                    oCmd.Parameters.Add(parameters[i]);
                }
            }
            oCmd.Parameters.Add(this.CreateParameter("TakingORDNO", DbType.String, ParameterDirection.Output, null, 50));
            oCmd.Parameters.Add(this.CreateParameter("RS_CODE", DbType.String, ParameterDirection.Output, null, 1));
            oCmd.Parameters.Add(this.CreateParameter("RS_MSG", DbType.String, ParameterDirection.Output, null, 200));

            //2020 02 14 HJH
            //if (_sTran != null && oCmd.GetType().Name != "OracleCommand") oCmd.Transaction = _sTran;
            if (_sTran != null) oCmd.Transaction = _sTran;
            int rtn = oCmd.ExecuteNonQuery();

            RS_MSG = Convert.ToString(oCmd.Parameters["RS_MSG"].Value);
            RS_CODE = Convert.ToString(oCmd.Parameters["RS_CODE"].Value);
            TakingORDNO = Convert.ToString(oCmd.Parameters["TakingORDNO"].Value);
            RSMSG = Convert.ToString(oCmd.Parameters["RS_MSG"].Value);
            RSCODE = Convert.ToString(oCmd.Parameters["RS_CODE"].Value);

            if (_completedClose)
                Close();

            return rtn;
        }

        public int ExecuteNoneQuery1(string query, CommandType commandType, int cnt, params Object[] parameters) // 오라클 output 변수를 위함
        {
            return ExecuteNoneQuery1(query, commandType, true, true, cnt, parameters);
        }
        public int ExecuteNoneQuery1(string query, CommandType commandType, bool baddLang, bool baddOut, int cnt, params Object[] parameters)
        {
            oCmd = _sConn.CreateCommand();
            oCmd.Connection = _sConn;
            oCmd.CommandText = query;
            oCmd.CommandType = commandType;

            RSCODE = "S";
            RSMSG = String.Empty;

            if (parameters != null)
            {
                for (int i = 0; i < parameters.Length; i++)
                {
                    oCmd.Parameters.Add(parameters[i]);
                }
            }
            if (commandType == CommandType.StoredProcedure)
            {
                if (baddLang)
                {
                    oCmd.Parameters.Add(this.CreateParameter("LANG", DbType.String, SAMMI.Common.Lang));
                }
                if (baddOut)
                {
                    oCmd.Parameters.Add(this.CreateParameter("RS_CODE", DbType.String, ParameterDirection.Output, null, 1));
                    oCmd.Parameters.Add(this.CreateParameter("RS_MSG", DbType.String, ParameterDirection.Output, null, 200));
                }

            }

            //2020 02 14 HJH
            //if (_sTran != null && oCmd.GetType().Name != "OracleCommand") oCmd.Transaction = _sTran;
            if (_sTran != null) oCmd.Transaction = _sTran;


            int rtn = oCmd.ExecuteNonQuery();

            if (commandType == CommandType.StoredProcedure && baddOut)
            {
                RSMSG = Convert.ToString(oCmd.Parameters["RS_MSG"].Value);
                RSCODE = Convert.ToString(oCmd.Parameters["RS_CODE"].Value);


                for (int i = parameters.Length - cnt; i < parameters.Length; i++)
                {
                    var1 = oCmd.Parameters[i].ToString();
                    output.Add(Convert.ToString(oCmd.Parameters[var1].Value));
                }

            }

            if (_completedClose)
                Close();

            return rtn;
        }

        public DbDataReader ExecuteReader(string query, CommandType commandType, params Object[] parameters)
        {
            oCmd = _sConn.CreateCommand();
            oCmd.Connection = _sConn;
            oCmd.CommandText = query;
            oCmd.CommandType = commandType;

            if (parameters != null)
            {
                for (int i = 0; i < parameters.Length; i++)
                {
                    oCmd.Parameters.Add(parameters[i]);
                }
            };

            if (commandType == CommandType.StoredProcedure)
            {
                oCmd.Parameters.Add(this.CreateParameter("RS_CODE", DbType.String, ParameterDirection.Output, null, 1));
                oCmd.Parameters.Add(this.CreateParameter("RS_MSG", DbType.String, ParameterDirection.Output, null, 200));
                if (this.Oracle)
                {
                    oCmd.Parameters.Add(new OracleParameter("CUR_1", OracleDbType.RefCursor, ParameterDirection.Output));
                }

            }

            DbDataReader rtn = oCmd.ExecuteReader();

            if (commandType == CommandType.StoredProcedure)
            {
                RSMSG = Convert.ToString(oCmd.Parameters["RS_MSG"].Value);
                RSCODE = Convert.ToString(oCmd.Parameters["RS_CODE"].Value);
            }
            if (_completedClose)
                Close();

            return rtn;
        }
        public object ExecuteScalar(string query, CommandType commandType, params Object[] parameters)
        {
            return ExecuteScalar(query, commandType, true, true, parameters);
        }
        public object ExecuteScalar(string query, CommandType commandType, bool baddLang, bool baddOut, params Object[] parameters)
        {
            oCmd = _sConn.CreateCommand();

            oCmd.Connection = _sConn;
            oCmd.CommandText = query;
            oCmd.CommandType = commandType;

            RSCODE = "S";
            RSMSG = String.Empty;

            if (parameters != null)
            {
                for (int i = 0; i < parameters.Length; i++)
                {
                    oCmd.Parameters.Add(parameters[i]);
                }
            };
            if (commandType == CommandType.StoredProcedure)
            {
                if (baddLang)
                {
                    oCmd.Parameters.Add(this.CreateParameter("Lang", DbType.String, SAMMI.Common.Lang));
                }
                if (baddOut)
                {
                    oCmd.Parameters.Add(this.CreateParameter("RS_CODE", DbType.String, ParameterDirection.Output, null, 1));
                    oCmd.Parameters.Add(this.CreateParameter("RS_MSG", DbType.String, ParameterDirection.Output, null, 200));
                }
                if (this.Oracle)
                {
                    oCmd.Parameters.Add(new OracleParameter("CUR_1", OracleDbType.RefCursor, ParameterDirection.Output));
                }

            }

            object rtn = oCmd.ExecuteScalar();

            if (commandType == CommandType.StoredProcedure && baddOut)
            {
                RSMSG = Convert.ToString(oCmd.Parameters["RS_MSG"].Value);
                RSCODE = Convert.ToString(oCmd.Parameters["RS_CODE"].Value);
            };
            if (_completedClose)
                Close();

            return rtn;
        }
        public object ExecuteScalar(string query)
        {
            Object[] parameters = null;
            return ExecuteScalar(query, CommandType.Text, parameters);
        }

        #region 2019 10 10 HJH 각종 프로시저 호출 함수 타임아웃 추가
        /// <summary>
        /// 2019 10 10 HJH Timeout 추가
        /// </summary>
        /// <param name="query"></param>
        /// <param name="commandType"></param>
        /// <param name="timeOut"></param>
        /// <param name="parameters"></param>
        /// <returns></returns>
        public DataTable FillTable2(string query, CommandType commandType, int timeOut, params Object[] parameters)
        {
            return FillTable2(query, commandType, timeOut, true, true, parameters);
        }

        /// <summary>
        /// 2019 10 10 HJH Timeout 추가
        /// </summary>
        /// <param name="query"></param>
        /// <param name="commandType"></param>
        /// <param name="timeOut"></param>
        /// <param name="baddLang"></param>
        /// <param name="baddOut"></param>
        /// <param name="parameters"></param>
        /// <returns></returns>
        public DataTable FillTable2(string query, CommandType commandType, int timeOut, bool baddLang, bool baddOut, params Object[] parameters)
        {
            oCmd = _sConn.CreateCommand();
            oCmd.Connection = _sConn;
            oCmd.CommandText = query;
            oCmd.CommandType = commandType;

            //2019 10 10 HJH
            if (timeOut <= 0)
                timeOut = 30;
            oCmd.CommandTimeout = timeOut;
            RSCODE = "S";
            RSMSG = String.Empty;

            if (parameters != null)
            {
                for (int i = 0; i < parameters.Length; i++)
                {
                    oCmd.Parameters.Add(parameters[i]);
                }
            }

            if (commandType == CommandType.StoredProcedure)
            {

                if (baddLang)
                {
                    oCmd.Parameters.Add(this.CreateParameter("Lang", DbType.String, SAMMI.Common.Lang));
                }
                if (baddOut)
                {
                    oCmd.Parameters.Add(this.CreateParameter("RS_CODE", DbType.String, ParameterDirection.Output, null, 1));
                    oCmd.Parameters.Add(this.CreateParameter("RS_MSG", DbType.String, ParameterDirection.Output, null, 200));
                }
                if (this.Oracle)
                {
                    oCmd.Parameters.Add(new OracleParameter("CUR_1", OracleDbType.RefCursor, ParameterDirection.Output));
                }

            }

            DbDataAdapter oAdap = dataFactory.CreateDataAdapter();
            oAdap.SelectCommand = oCmd;

            //DataSet ds   = new DataSet();
            DataTable dt = new DataTable();
            oAdap.Fill(dt);

            if (commandType == CommandType.StoredProcedure && baddOut)
            {
                RSMSG = Convert.ToString(oCmd.Parameters["RS_MSG"].Value);
                RSCODE = Convert.ToString(oCmd.Parameters["RS_CODE"].Value);
            }
            if (_completedClose)
                Close();

            // 해당 주석 차후에 수정 예정 

            //bool bPlant = false;
            for (int i = 0; i < dt.Columns.Count; i++)
            {
                dt.Columns[i].ColumnName = dt.Columns[i].ColumnName.ToUpper();
                //if (!bPlant && dt.Columns[i].ColumnName.Equals("PLANTCODE"))
                //{
                //    bPlant = true;
                //}
            }

            //사업장권한 설정
            //if (Common.bPlantAuth && SAMMI.LoginInfo.UserID != "SYSTEM" && bPlant)
            //{
            //    if (Common.dtPlantAuth != null)
            //    {
            //        dt = Join(dt, Common.dtPlantAuth, new string[] { "PLANTCODE " }, new string[] { "PLANTCODE" });
            //    }
            //}

            return dt;
        }

        /// <summary>
        /// 2019 10 10 HJH Timeout 추가
        /// </summary>
        /// <param name="query"></param>
        /// <param name="commandType"></param>
        /// <param name="timeOut"></param>
        /// <param name="parameters"></param>
        /// <returns></returns>
        public DataSet FillDataSet2(string query, CommandType commandType, int timeOut, params Object[] parameters)
        {
            return FillDataSet2(query, commandType, timeOut, true, true, parameters);
        }

        /// <summary>
        /// 2019 10 10 HJH Timeout 추가
        /// </summary>
        /// <param name="query"></param>
        /// <param name="commandType"></param>
        /// <param name="timeOut"></param>
        /// <param name="baddLang"></param>
        /// <param name="baddOut"></param>
        /// <param name="parameters"></param>
        /// <returns></returns>
        public DataSet FillDataSet2(string query, CommandType commandType, int timeOut, bool baddLang, bool baddOut, params Object[] parameters)
        {
            oCmd = _sConn.CreateCommand();
            oCmd.Connection = _sConn;
            oCmd.CommandText = query;
            oCmd.CommandType = commandType;
            if (timeOut <= 0)
                timeOut = 30;
            oCmd.CommandTimeout = timeOut;
            RSCODE = "S";
            RSMSG = String.Empty;

            if (parameters != null)
            {
                for (int i = 0; i < parameters.Length; i++)
                {
                    oCmd.Parameters.Add(parameters[i]);
                }
            }

            if (commandType == CommandType.StoredProcedure)
            {
                if (baddLang)
                {
                    oCmd.Parameters.Add(this.CreateParameter("Lang", DbType.String, SAMMI.Common.Lang));
                }
                if (baddOut)
                {
                    oCmd.Parameters.Add(this.CreateParameter("RS_CODE", DbType.String, ParameterDirection.Output, null, 1));
                    oCmd.Parameters.Add(this.CreateParameter("RS_MSG", DbType.String, ParameterDirection.Output, null, 200));
                }
                if (this.Oracle)
                {
                    oCmd.Parameters.Add(new OracleParameter("CUR_1", OracleDbType.RefCursor, ParameterDirection.Output));
                }

            }
            DbDataAdapter oAdap = dataFactory.CreateDataAdapter();
            oAdap.SelectCommand = oCmd;
            DataSet ds = new DataSet();

            oAdap.Fill(ds);

            if (commandType == CommandType.StoredProcedure && baddOut)
            {
                RSMSG = Convert.ToString(oCmd.Parameters["RS_MSG"].Value);
                RSCODE = Convert.ToString(oCmd.Parameters["RS_CODE"].Value);
            }

            if (_completedClose)
                Close();
            foreach (DataTable dt in ds.Tables)
            {
                for (int i = 0; i < dt.Columns.Count; i++)
                {
                    dt.Columns[i].ColumnName = dt.Columns[i].ColumnName.ToUpper();
                }
            }
            return ds;
        }

        /// <summary>
        /// 2019 10 10 HJH Timeout 추가
        /// </summary>
        /// <param name="query"></param>
        /// <param name="commandType"></param>
        /// <param name="timeOut"></param>
        /// <param name="parameters"></param>
        /// <returns></returns>
        public int ExecuteNoneQuery2(string query, CommandType commandType, int timeOut, params Object[] parameters)
        {
            return ExecuteNoneQuery2(query, commandType, timeOut, true, true, parameters);
        }

        /// <summary>
        /// 2019 10 10 HJH Timeout 추가
        /// </summary>
        /// <param name="query"></param>
        /// <param name="commandType"></param>
        /// <param name="timeOut"></param>
        /// <param name="baddLang"></param>
        /// <param name="baddOut"></param>
        /// <param name="parameters"></param>
        /// <returns></returns>
        public int ExecuteNoneQuery2(string query, CommandType commandType, int timeOut, bool baddLang, bool baddOut, params Object[] parameters)
        {
            oCmd = _sConn.CreateCommand();
            oCmd.Connection = _sConn;
            oCmd.CommandText = query;
            oCmd.CommandType = commandType;
            if (timeOut <= 0)
                timeOut = 30;
            oCmd.CommandTimeout = timeOut;
            RSCODE = "S";
            RSMSG = String.Empty;

            if (parameters != null)
            {
                for (int i = 0; i < parameters.Length; i++)
                {
                    oCmd.Parameters.Add(parameters[i]);
                }
            }
            if (commandType == CommandType.StoredProcedure)
            {
                if (baddLang)
                {
                    oCmd.Parameters.Add(this.CreateParameter("Lang", DbType.String, SAMMI.Common.Lang));
                }
                if (baddOut)
                {
                    oCmd.Parameters.Add(this.CreateParameter("RS_CODE", DbType.String, ParameterDirection.Output, null, 1));
                    oCmd.Parameters.Add(this.CreateParameter("RS_MSG", DbType.String, ParameterDirection.Output, null, 200));
                }
            }

            //2020 02 14 HJH
            //if (_sTran != null && oCmd.GetType().Name != "OracleCommand") oCmd.Transaction = _sTran;
            if (_sTran != null) oCmd.Transaction = _sTran;

            int rtn = oCmd.ExecuteNonQuery();

            if (commandType == CommandType.StoredProcedure && baddOut)
            {
                RSMSG = Convert.ToString(oCmd.Parameters["RS_MSG"].Value);
                RSCODE = Convert.ToString(oCmd.Parameters["RS_CODE"].Value);
            }

            if (_completedClose)
                Close();

            return rtn;
        }

        /// <summary>
        /// 2019 10 10 HJH Timeout 추가
        /// </summary>
        /// <param name="query"></param>
        /// <param name="commandType"></param>
        /// <param name="timeOut"></param>
        /// <param name="baddLang"></param>
        /// <param name="baddOut"></param>
        /// <param name="parameters"></param>
        /// <returns></returns>
        public object ExecuteScalar2(string query, CommandType commandType, int timeOut, bool baddLang, bool baddOut, params Object[] parameters)
        {
            oCmd = _sConn.CreateCommand();

            oCmd.Connection = _sConn;
            oCmd.CommandText = query;
            oCmd.CommandType = commandType;
            if (timeOut <= 0)
                timeOut = 30;
            oCmd.CommandTimeout = timeOut;

            RSCODE = "S";
            RSMSG = String.Empty;

            if (parameters != null)
            {
                for (int i = 0; i < parameters.Length; i++)
                {
                    oCmd.Parameters.Add(parameters[i]);
                }
            };
            if (commandType == CommandType.StoredProcedure)
            {
                if (baddLang)
                {
                    oCmd.Parameters.Add(this.CreateParameter("Lang", DbType.String, SAMMI.Common.Lang));
                }
                if (baddOut)
                {
                    oCmd.Parameters.Add(this.CreateParameter("RS_CODE", DbType.String, ParameterDirection.Output, null, 1));
                    oCmd.Parameters.Add(this.CreateParameter("RS_MSG", DbType.String, ParameterDirection.Output, null, 200));
                }
                if (this.Oracle)
                {
                    oCmd.Parameters.Add(new OracleParameter("CUR_1", OracleDbType.RefCursor, ParameterDirection.Output));
                }

            }

            object rtn = oCmd.ExecuteScalar();

            if (commandType == CommandType.StoredProcedure && baddOut)
            {
                RSMSG = Convert.ToString(oCmd.Parameters["RS_MSG"].Value);
                RSCODE = Convert.ToString(oCmd.Parameters["RS_CODE"].Value);
            };
            if (_completedClose)
                Close();

            return rtn;
        }
        #endregion 2019 10 10 HJH 각종 프로시저 호출 함수 타임아웃 추가

        #region 파라미터 처리

        public OracleParameter CreateParameterOracle(string name, object value, OracleDbType OraType, ParameterDirection direction)
        {
            OracleParameter param = new OracleParameter();
            param.ParameterName = name;
            param.Value = value;
            param.OracleDbType = OraType;
            param.Direction = direction;
            return param;
        }

        public DbParameter CreateParameter(string name, object value, DbType SqlType, ParameterDirection direction)
        {
            DbParameter param = dataFactory.CreateParameter();
            param.ParameterName = name.ToUpper();
            param.Value = value;
            //param.DbType      = SqlType;
            param.Direction = direction;

            return param;
        }

        public DbParameter CreateParameter(string parameterName, DbType DbType, ParameterDirection parameterDirection, object value, int? size)
        {
            DbParameter param = null;
            try
            {
                param = dataFactory.CreateParameter();
                param.ParameterName = parameterName.ToUpper();
                param.DbType = DbType;
                param.Direction = parameterDirection;
                param.Value = value;
                if (size.HasValue)
                {
                    param.Size = size.Value;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return param;
        }

        public DbParameter CreateParameter(string parameterName, DbType DbType, object value)
        {
            DbParameter param = null;
            try
            {
                param = dataFactory.CreateParameter();
                param.ParameterName = parameterName.ToUpper();
                param.DbType = DbType;
                param.Value = value;

            }
            catch (Exception ex)
            {
                throw ex;
            }
            return param;
        }

        #endregion

        #region Null 값 처리

        public static int nvlInt(object obj, int def = 0)
        {
            if (obj == null)
                return def;

            if (obj == DBNull.Value)
                return def;

            if (obj.ToString() == "")
                return def;

            return Convert.ToInt32(nvlString(obj).Replace(",", ""));
        }

        public static double nvlDouble(object obj, double def = 0.0)
        {
            if (obj == null)
                return def;

            if (obj == DBNull.Value)
                return def;

            if (obj.ToString() == "")
                return def;

            return Convert.ToDouble(nvlString(obj).Replace(",", ""));
        }

        public static string nvlString(object obj, string def = "")
        {
            if (obj == null)
                return def;

            if (obj == DBNull.Value)
                return def;

            if (obj.ToString() == "")
                return def;

            if (obj.ToString().ToUpper() == "ALL")
                return def;

            if (obj.ToString() == Common.getLangText("전체"))
                return def;

            return obj.ToString();
        }

        public static bool nvlBoolean(object obj, bool def = false)
        {
            if (obj == null)
                return def;

            if (obj == DBNull.Value)
                return def;

            if (obj.ToString() == "")
                return def;

            if (obj.ToString().ToUpper() == "ALL")
                return def;

            if (obj.ToString() == Common.getLangText("전체"))
                return def;
            if (obj.ToString() == "0")
                return def;
            else
            {
                def = true;
                return def;
            }

            //return Convert.ToBoolean(obj);
        }

        public static DateTime nvlDateTime(object obj)
        {
            try
            {
                if (obj == null)
                    return Convert.ToDateTime("2000-01-01 00:00:00");

                if (obj == DBNull.Value)
                    return Convert.ToDateTime("2000-01-01 00:00:00");

                if (obj.ToString() == "")
                    return Convert.ToDateTime("2000-01-01 00:00:00");

                return Convert.ToDateTime(obj);
            }
            catch (Exception)
            {
                return DateTime.Now;
            }
        }

        public static string gGetCode(object obj, string def = "")
        {
            if (obj == null)
                return def;

            if (obj == DBNull.Value)
                return def;

            if (obj.ToString() == "")
                return "";

            string s = obj.ToString();

            int iStart = s.IndexOf('[');
            int iEnd = s.IndexOf(']');

            if (iStart < 0 && iEnd < 0)
            {
                return s;
            }
            else
            {
                return s.Substring(iStart + 1, iEnd - iStart - 1).Trim();
            }
        }

        public static string gGetName(object obj, string def = "")
        {
            if (obj == null)
                return def;

            if (obj == DBNull.Value)
                return def;

            if (obj.ToString() == "")
                return "";

            string s = obj.ToString();

            int iStart = s.IndexOf('[');
            int iEnd = s.IndexOf(']');

            if (iStart < 0 && iEnd < 0)
            {
                return s;
            }
            else
            {
                return s.Substring(iEnd + 1).Trim();
            }
        }
        #endregion
    }
}
