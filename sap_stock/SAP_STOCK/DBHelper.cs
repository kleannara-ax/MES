using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using Oracle.ManagedDataAccess.Client;
using System.Data;

namespace SAP_STOCK
{
    class DBHelper
    {
        public OracleConnection Connection { get; private set; }
        string sConn = string.Empty;

        public DBHelper()
        {
            getConnecion();
        }

        public void DBClose()
        {
            this.Connection.Close();
            this.Connection.Dispose();
            this.Connection = null;
        }

        public bool getConnecion()
        {
            //접속설정
            sConn = "Data Source=(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=10.2.14.194)(PORT=1522)))(CONNECT_DATA=(SERVER=DEDICATED)(SID=KNRAMES)));User Id=knrames;Password=knrames321$";

            try
            {
                //초기화
                if (this.Connection != null)
                {
                    this.Connection.Close();
                    this.Connection.Dispose();
                    this.Connection = null;
                }
                //연결 생성
                Connection = new OracleConnection(sConn);

                if (this.sConn != string.Empty)
                    Connection.Open();
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.ToString());
            }

            if (Connection.State == System.Data.ConnectionState.Open)
                return true;
            else
                return false;
        }

        public DataTable FillTable(string query)
        {
            DataTable dt = new DataTable();
            //Comand 생성
            OracleCommand oCmd = new OracleCommand(query, Connection);
            //Comand실행 및 결과 수신
            OracleDataReader oDataReader = oCmd.ExecuteReader();
            //결과정보 양식변경
            dt.Load(oDataReader);

            return dt;
        }
    }
}
