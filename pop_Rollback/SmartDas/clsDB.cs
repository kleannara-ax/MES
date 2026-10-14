using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using System.Data.Odbc;
using System.Data.SqlClient;
using System.Data;
using Microsoft.Practices.EnterpriseLibrary.Data;

namespace SmartDas
{
    public static class clsDB
    {
        private static string _sErrDesc = "";

        private static SqlTransaction transaction = null;
        public static bool bUseNetwork = false;

        public static string ErrorDesc
        {
            get { return _sErrDesc; }
        }

        public static SqlConnection sqlConn
        {
            get
            {
                if (!bUseNetwork)
                {
                    _sErrDesc = "네트워크 상태를 확인하세요.";
                    return null;
                }

                Database db = DatabaseFactory.CreateDatabase();
                SqlConnection _sqlConn = (SqlConnection)db.CreateConnection();

                return _sqlConn;
            }
        }

        public static SqlTransaction BeginTran(SqlConnection sqlConn)
        {
            if (!bUseNetwork)
            {
                _sErrDesc = "네트워크 상태를 확인하세요.";
                return null;
            }

            if (sqlConn.State != ConnectionState.Open)
            {
                sqlConn.Open();
            }

            transaction = sqlConn.BeginTransaction();

            return transaction;
        }

        public static void Commit()
        {
            if (!bUseNetwork)
            {
                _sErrDesc = "네트워크 상태를 확인하세요.";
                return ;
            }

            if (transaction != null)
            {
                transaction.Commit();
                transaction = null;
            }
        }

        public static void Rollback()
        {
            if (!bUseNetwork)
            {
                _sErrDesc = "네트워크 상태를 확인하세요.";
                return ;
            }

            if (transaction != null)
            {
                transaction.Rollback();
                transaction = null;
            }
        }

        public static void Close(SqlConnection sqlConn)
        {
            if (!bUseNetwork)
            {
                _sErrDesc = "네트워크 상태를 확인하세요.";
                return ;
            }

            sqlConn.Close();
        }

        public static bool gCreateRSet(SqlConnection sqlConn, string sSQL, DataSet ds)
        {
            _sErrDesc = "";
            if (!bUseNetwork)
            {
                _sErrDesc = "네트워크 상태를 확인하세요.";
                return false;
            }

            SqlCommand sqlCmd;
            SqlDataAdapter DA;

            ds.Clear();

            if (sSQL == "")
            {
                return false;
            }

            sqlCmd = new SqlCommand();
            DA = new SqlDataAdapter();

            try
            {
                sqlCmd.Connection = sqlConn;
                sqlCmd.CommandText = sSQL;
                DA.SelectCommand = sqlCmd;
                DA.Fill(ds);
            }
            catch (OdbcException EX)
            {
                _sErrDesc = EX.Message;
                return false;
            }
            catch (Exception EX)
            {
                _sErrDesc = EX.Message;
                return false;
            }
            finally
            {
                sqlCmd.Dispose();
                DA.Dispose();
            }
            return true;
        }

        public static bool gCreateRSet(SqlConnection SqlConn, SqlCommand SqlCmd, DataSet ds)
        {
            _sErrDesc = "";
            if (!bUseNetwork)
            {
                _sErrDesc = "네트워크 상태를 확인하세요.";
                return false;
            }

            SqlDataAdapter DA;

            ds.Clear();

            if (SqlCmd.CommandText == "")
            {
                return false;
            }

            DA = new SqlDataAdapter();

            try
            {
                SqlCmd.Connection = SqlConn;
                DA.SelectCommand = SqlCmd;
                DA.Fill(ds);
            }
            catch (SqlException EX)
            {
                _sErrDesc = EX.Message;
                return false;
            }
            catch (Exception EX)
            {
                _sErrDesc = EX.Message;
                return false;
            }
            finally
            {
                SqlCmd.Dispose();
                DA.Dispose();
            }
            return true;
        }

        public static bool gCreateRSet(SqlCommand SqlCmd, DataSet ds)
        {
            _sErrDesc = "";
            if (!bUseNetwork)
            {
                _sErrDesc = "네트워크 상태를 확인하세요.";
                return false;
            }

            SqlDataAdapter DA;

            ds.Clear();

            if (SqlCmd.CommandText == "")
            {
                return false;
            }

            DA = new SqlDataAdapter();

            try
            {
                DA.SelectCommand = SqlCmd;
                DA.Fill(ds);
            }
            catch (SqlException EX)
            {
                _sErrDesc = EX.Message;
                return false;
            }
            catch (Exception EX)
            {
                _sErrDesc = EX.Message;
                return false;
            }
            finally
            {
                SqlCmd.Dispose();
                DA.Dispose();
            }
            return true;
        }

        public static bool gCreateRSet(SqlConnection sqlConn, string sSQL, DataTable DT)
        {
            _sErrDesc = "";
            if (!bUseNetwork)
            {
                _sErrDesc = "네트워크 상태를 확인하세요."; 
                return false;
            }

            SqlCommand sqlCmd;
            SqlDataAdapter DA;

            DT.Clear();

            if (sSQL == "")
            {
                return false;
            }

            sqlCmd = new SqlCommand();
            DA = new SqlDataAdapter();

            try
            {
                sqlCmd.Connection = sqlConn;
                sqlCmd.CommandText = sSQL;
                DA.SelectCommand = sqlCmd;
                DA.Fill(DT);
            }
            catch (OdbcException EX)
            {
                _sErrDesc = EX.Message;
                return false;
            }
            catch (Exception EX)
            {
                _sErrDesc = EX.Message;
                return false;
            }
            finally
            {
                sqlCmd.Dispose();
                DA.Dispose();
            }
            return true;
        }

        public static bool gCreateRSet(SqlConnection SqlConn, SqlCommand SqlCmd, DataTable DT)
        {
            _sErrDesc = "";
            if (!bUseNetwork)
            {
                _sErrDesc = "네트워크 상태를 확인하세요.";
                return false;
            }

            SqlDataAdapter DA;

            DT.Clear();

            if (SqlCmd.CommandText == "")
            {
                return false;
            }

            DA = new SqlDataAdapter();

            try
            {
                SqlCmd.Connection = SqlConn;
                DA.SelectCommand = SqlCmd;
                DA.Fill(DT);
            }
            catch (SqlException EX)
            {
                _sErrDesc = EX.Message;
                return false;
            }
            catch (Exception EX)
            {
                _sErrDesc = EX.Message;
                return false;
            }
            finally
            {
                SqlCmd.Dispose();
                DA.Dispose();
            }
            return true;
        }

        public static bool gCreateRSet(SqlCommand SqlCmd, DataTable DT)
        {
            _sErrDesc = "";
            if (!bUseNetwork)
            {
                _sErrDesc = "네트워크 상태를 확인하세요.";
                return false;
            }

            SqlDataAdapter DA;

            DT.Clear();

            if (SqlCmd.CommandText == "")
            {
                return false;
            }

            DA = new SqlDataAdapter();

            try
            {
                DA.SelectCommand = SqlCmd;
                DA.Fill(DT);
            }
            catch (SqlException EX)
            {
                _sErrDesc = EX.Message;
                return false;
            }
            catch (Exception EX)
            {
                _sErrDesc = EX.Message;
                return false;
            }
            finally
            {
                SqlCmd.Dispose();
                DA.Dispose();
            }
            return true;
        }

        /// <summary>
        /// 쿼리를 수행하고, 처리 수량을 반환한다.
        /// 오류 발생시 -1을 반환하고,
        /// 네트워크 상태가 비정상일 땐 -2를 반환한다.
        /// </summary>
        /// <param name="SqlConn"></param>
        /// <param name="sSQL"></param>
        /// <returns></returns>
        public static int gExecute(SqlConnection SqlConn, string sSQL)
        {
            _sErrDesc = "";
            if (!bUseNetwork)
            {
                _sErrDesc = "네트워크 상태를 확인하세요.";
                return -2;
            }

            try
            {
                if (SqlConn.State == ConnectionState.Closed)
                {
                    SqlConn.Open();
                }

                //Create the createTable command on the connection.
                SqlCommand cmdQuery = SqlConn.CreateCommand();
                cmdQuery.CommandText = sSQL;
                cmdQuery.CommandType = CommandType.Text;

                cmdQuery.Connection = SqlConn;

                if (transaction != null)
                    cmdQuery.Transaction = transaction;

                return cmdQuery.ExecuteNonQuery();
            }
            catch (SqlException ex)
            {
                _sErrDesc = ex.Message;
                return -1;
            }
            catch (Exception ex)
            {
                _sErrDesc = ex.Message;
                return -1;
            }
            finally
            {
                if (transaction == null)
                {
                    if (SqlConn.State != ConnectionState.Closed)
                    {
                        SqlConn.Close();
                    }
                }
            }
        }

        /// <summary>
        /// 쿼리를 수행하고, 처리 수량을 반환한다.
        /// 오류 발생시 -1을 반환하고,
        /// 네트워크 상태가 비정상일 땐 -2를 반환한다.
        /// </summary>
        /// <param name="SqlConn"></param>
        /// <param name="SqlCmd"></param>
        /// <returns></returns>
        public static int gExecute(SqlConnection SqlConn, SqlCommand SqlCmd)
        {
            _sErrDesc = "";
            if (!bUseNetwork)
            {
                _sErrDesc = "네트워크 상태를 확인하세요.";
                return -2;
            }

            try
            {
                if (SqlConn.State == ConnectionState.Closed)
                {
                    SqlConn.Open();
                }

                //Create the createTable command on the connection.
                SqlCmd.Connection = SqlConn;

                if (transaction != null)
                    SqlCmd.Transaction = transaction;

                return SqlCmd.ExecuteNonQuery();
            }
            catch (SqlException ex)
            {
                _sErrDesc = ex.Message;
                return -1;
            }
            catch (Exception ex)
            {
                _sErrDesc = ex.Message;
                return -1;
            }
            finally
            {
                if (transaction == null)
                {
                    if (SqlConn.State != ConnectionState.Closed)
                    {
                        SqlConn.Close();
                    }
                }
            }
        }

        public static object gExecuteScalar(SqlConnection SqlConn, string sSQL)
        {
            _sErrDesc = "";
            if (!bUseNetwork)
            {
                _sErrDesc = "네트워크 상태를 확인하세요.";
                return null;
            }

            try
            {
                if (SqlConn.State == ConnectionState.Closed)
                {
                    SqlConn.Open();
                }

                //Create the createTable command on the connection.
                SqlCommand cmdQuery = SqlConn.CreateCommand();
                cmdQuery.CommandText = sSQL;
                cmdQuery.CommandType = CommandType.Text;

                cmdQuery.Connection = SqlConn;

                if (transaction != null)
                    cmdQuery.Transaction = transaction;

                return cmdQuery.ExecuteScalar();
            }
            catch (SqlException ex)
            {
                _sErrDesc = ex.Message;
                return null;
            }
            catch (Exception ex)
            {
                _sErrDesc = ex.Message;
                return null;
            }
            finally
            {
                if (transaction == null)
                {
                    if (SqlConn.State != ConnectionState.Closed)
                    {
                        SqlConn.Close();
                    }
                }
            }
        }

        public static object gExecuteScalar(SqlConnection SqlConn, SqlCommand SqlCmd)
        {
            _sErrDesc = "";
            if (!bUseNetwork)
            {
                _sErrDesc = "네트워크 상태를 확인하세요.";
                return null;
            }

            try
            {
                if (SqlConn.State == ConnectionState.Closed)
                {
                    SqlConn.Open();
                }

                SqlCmd.Connection = SqlConn;

                if (transaction != null)
                    SqlCmd.Transaction = transaction;
                //Create the createTable command on the connection.
                return SqlCmd.ExecuteScalar();
            }
            catch (SqlException ex)
            {
                _sErrDesc = ex.Message;
                return null;
            }
            catch (Exception ex)
            {
                _sErrDesc = ex.Message;
                return null;
            }
            finally
            {
                if (transaction == null)
                {
                    if (SqlConn.State != ConnectionState.Closed)
                    {
                        SqlConn.Close();
                    }
                }
            }
        }


        /// <summary>
        /// 쿼리를 수행하고, 처리 수량을 반환한다.
        /// </summary>
        /// <param name="SqlConn"></param>
        /// <param name="sSQL"></param>
        /// <returns></returns>
        public static bool gExecuteProcedure(SqlConnection SqlConn, SqlCommand cmd)
        {
            _sErrDesc = "";
            if (!bUseNetwork)
            {
                _sErrDesc = "네트워크 상태를 확인하세요.";
                return false;
            }

            try
            {
                cmd.Connection = SqlConn;
                DataTable dt = new DataTable();
                if (gCreateRSet(cmd, dt))
                {
                    if (dt.Rows.Count == 1)
                    {
                        _sErrDesc = dt.Rows[0]["ErrorMessage"].ToString();
                        return false;
                    }

                    return true;
                }
                else
                {
                    return false;
                }
            }
            catch (SqlException ex)
            {
                _sErrDesc = ex.Message;
                return false;
            }
            catch (Exception ex)
            {
                _sErrDesc = ex.Message;
                return false;
            }
            finally
            {
                if (transaction == null)
                {
                    if (SqlConn.State != ConnectionState.Closed)
                    {
                        SqlConn.Close();
                    }
                }
            }
        }

        public static int nvlInt(object obj, int def = 0)
        {
            if (obj == null)
                return def;

            if (obj == DBNull.Value)
                return def;

            if (obj.ToString() == "")
                return def;

            return Convert.ToInt32(obj.ToString().Replace(",", ""));
        }

        public static double nvlDouble(object obj, double def = 0.0)
        {
            if (obj == null)
                return def;

            if (obj == DBNull.Value)
                return def;

            if (obj.ToString() == "")
                return def;

            return Convert.ToDouble(obj.ToString().Replace(",", ""));
        }

        public static string nvlString(object obj, string def = "")
        {
            if (obj == null)
                return def;

            if (obj == DBNull.Value)
                return def;

            if (obj.ToString() == "")
                return def;

            return obj.ToString();
        }

        public static DateTime nvlDateTime(object obj)
        {
            if (obj == null)
                return Convert.ToDateTime("2000-01-01 00:00:00");

            if (obj == DBNull.Value)
                return Convert.ToDateTime("2000-01-01 00:00:00");

            if (obj.ToString() == "")
                return Convert.ToDateTime("2000-01-01 00:00:00");

            return Convert.ToDateTime(obj);
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
                return s.Substring(iStart + 1, iEnd - iStart - 1);
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
                return s.Substring(iEnd + 1).Trim() ;
            }
        }
    }
}
