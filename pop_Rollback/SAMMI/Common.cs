using System;
using System.Collections.Generic;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Management;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using System.Data.Common;
using System.Diagnostics;
using System.Windows.Forms;
using Infragistics.Win.UltraWinGrid;
using System.Runtime.InteropServices;
using Infragistics.Win.UltraWinEditors;
using System.Collections;
using System.Configuration;
using System.Security;
using System.Security.Cryptography;
using System.Text.RegularExpressions;

namespace SAMMI
{

    public class Common
    {
        //2020 02 14 HJH 추가
        public static string currentFormName = string.Empty;

        public static string Lang="KO";
        public static string DefaultLang="KO";
        public static string SystemID;
        public static bool bPlantAuth = true;
        public static string ProcessName;
        public static bool oraFlag = false;
        public static string FontName;
        public static string UIStyle = "DarkGray";
        public static string UIMenu = "TREE";
        private const string WMI_QUERY = "SELECT * FROM Win32_NetworkAdapterConfiguration WHERE IPEnabled='True'";
        
        private Configuration appConfig = ConfigurationManager.OpenExeConfiguration(ConfigurationUserLevel.None);

        [DllImport("psapi")]
        public static extern int EmptyWorkingSet(IntPtr handle);

        public void CleanProcess(String processName)
        {
            Process[] process = Process.GetProcessesByName(processName);

            if (process.Length == 1)
            {
                EmptyWorkingSet(process[0].Handle);
            }
        }

        

        #region 2. 사용자정의 전역변수 및 인스턴스 생성

        DataTable rtnDtTemp = new DataTable(); // return DataTable 공통

        /// <summary>
        /// 콤보박스의 기타 데이터를 저장

        /// </summary>
        private Hashtable ComboEtcData = new Hashtable();

        public string EtcData(string MajorCode, string minorCode, int relCodeNum)
        {
            string sObj = null;

            if (ComboEtcData[MajorCode] != null)
            {
                Hashtable hash = (Hashtable)ComboEtcData[MajorCode];

                sObj = ((string[])hash[minorCode])[relCodeNum - 1];
            }

            return sObj;
        }

        private void SetEtcData(string MajorCode, string minorCode, string[] sList)
        {
            Hashtable hash = (Hashtable)ComboEtcData[MajorCode];

            if (hash == null)
            {
                hash = new Hashtable();
                ComboEtcData.Add(MajorCode, hash);
            }

            if (hash[minorCode] != null)
            {
                hash.Add(minorCode, sList);
            }
        }

        private void SetEtcData(string MajorCode, string MinorCodeColumnName, DataRow dr)
        {
            string[] sList = new string[5];
            string minorCode = "";

            foreach (DataColumn dc in dr.Table.Columns)
            {
                if (dc.ColumnName.ToUpper().Contains("RELCODE"))
                {
                    int iIdx = Convert.ToInt32(dc.ColumnName.Substring(dc.ColumnName.Length - 1, 1)) - 1;

                    sList[iIdx] = DBHelper.nvlString(dr[dc.ColumnName]);
                }
                else if (dc.ColumnName.ToUpper().Contains(MinorCodeColumnName))
                {
                    minorCode = DBHelper.nvlString(dr[dc.ColumnName]);
                }
            }

            SetEtcData(MajorCode, minorCode, sList);
        }

        #endregion

        #region 문자열 자르기
        public static string Left(string Text, int TextLenth)
        {
            string ConvertText;
            if (Text.Length < TextLenth)
            {
                TextLenth = Text.Length;
            }
            ConvertText = Text.Substring(0, TextLenth);
            return ConvertText;
        }

        public static string Right(string Text, int TextLenth)
        {
            string ConvertText;
            if (Text.Length < TextLenth)
            {
                TextLenth = Text.Length;
            }
            ConvertText = Text.Substring(Text.Length - TextLenth, TextLenth);
            return ConvertText;
        }

        public static string Mid(string Text, int Startint, int Endint)
        {
            string ConvertText;
            if (Startint < Text.Length || Endint < Text.Length)
            {
                ConvertText = Text.Substring(Startint, Endint);
                return ConvertText;
            }
            else
                return Text;
        }
        #endregion 문자열 자르기

        public string GetData()
        {
            string sTime = DBHelper.nvlString(new DBHelper(true).ExecuteScalar("SELECT CONVERT(VARCHAR(10),GETDATE(),120)"));
            return string.IsNullOrEmpty(sTime) ? string.Format("{0:yyyy-MM-dd}",DateTime.Now.ToString()) : sTime;
        }

        //2020 03 09 HJH 화면별 권한 부여를 위한 조회
        public string CheckAuth(string programName)
        {
            /* 버튼 별 권한 설정
             ***************** 사용법 *****************
             * 각 Form의 Init() 함수에서 
             * Common common = new Common(); //이미 선언했다면 선언하지 않아도 됨

             * string auth = common.CheckAuth(this.Name);
             * 만약 auth가 0이면 권한 없음(각 버튼들 Enable = false)
             * 만약 auth가 1이면 권한 있음(각 버튼들 Enable = true)
             * 만약 auth가 0 또는 1이 아니면 팝업에 auth 내용 보여줄 것

             * auth 값은 "0 ,1, 에러메세지" 총 3가지가 들어갈 수 있음)
             */
            string auth = "0";
            DBHelper helper = new DBHelper();
            try
            {
                //결과가 없으면 0, 있으면 해당 권한대로 나옴
                //결과가 1이면 권한이 있는 것이므로 Button을 활성화 시키면 됨


                //아래 쿼리는 로그인 아이디로 그룹ID를 가져와서 프로그램 리스트에서 그룹ID로 조회하여 PrnFlag권한이 있는지 확인하는 쿼리
                //PrnFlag 는 기존에는 출력 기능으로 사용했으나 대림 WMS에서는 "버튼 기능"의 권한으로 사용함



                helper.ExecuteNoneQuery1("SP_CheckAuth_S1", CommandType.StoredProcedure, 1
                                    , helper.CreateParameter("LoginID", SAMMI.LoginInfo.UserID, DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("ProgramID", programName, DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("auth", DbType.String, ParameterDirection.Output, null, 2));

                auth = helper.Parameters["auth"].Value.ToString();

            }
            catch (Exception ex)
            {
                auth = ex.Message;
            }
            finally
            {
                helper.Close();
            }
            return auth;
        }

        #region 공통코드 정보 가져오기

        /// <summary>
        /// 공통코드 정보 가져오기

        /// </summary>
        /// <param name="MajorCode">메이저코드 예) 사업장(PLANTCODE)</param>
        /// <returns></returns>
        public DataTable GET_TBM0000_CODE(string MajorCode, string sSql = " ")
        {
            string methodName = new StackFrame().GetMethod().Name;
            StringBuilder query = null;
            DBHelper helper = new DBHelper(false);
            try
            {
                query = new StringBuilder();
                query.Remove(0, query.Length);

                if (helper.ConType == "OracleConnection")
                {
                    //디센트 공통코드 테이블 사용2022.02.24 KKY
                    query.AppendLine(" SELECT B.CMCDVL AS CODE_ID, ");
                    query.AppendLine("        '[' || B.CMCDVL || '] ' || B.CDESC1 AS CODE_NAME, ");
                    query.AppendLine("        B.CDESC1 AS CODE_NAME_ORG, ");
                    query.AppendLine("        USARG1 AS Relcode1, USARG2 AS Relcode2, USARG3 AS Relcode3, USARG4 AS Relcode4, USARG5 AS Relcode5 ");
                    query.AppendLine(" FROM   CMCDM A, CMCDV B ");
                    query.AppendLine(" WHERE  A.CMCDKY = B.CMCDKY");
                    query.AppendLine(" AND    A.CMCDKY = '" + MajorCode.ToUpper() + "'");
                    if (sSql != " ")
                    {
                        query.AppendLine(" AND B.CMCDVL = '" + sSql + "'");
                    }
                    //기존 코드
                    //query.AppendLine(" SELECT MINORCODE AS CODE_ID, ");
                    //query.AppendLine("        '['  || MinorCode || '] '|| CodeName AS CODE_NAME, ");
                    //query.AppendLine("        CodeName AS CODE_NAME_ORG, ");
                    //query.AppendLine("        RelCode1,RelCode2,RelCode3,RelCode4,RelCode5, DisplayNo   AS DisplayNo ");
                    //query.AppendLine(" FROM   TBM0000 ");
                    //query.AppendLine(" WHERE  MajorCode = '" + MajorCode.ToUpper() + "'");
                    //query.AppendLine(" AND    MinorCode <> '$' ");
                    //if (sSql != " ")
                    //{
                    //    query.AppendLine(" AND RELCODE1 = '" + sSql + "'");
                    //}
                }
                else
                {
                    query.AppendLine(" SELECT MinorCode AS CODE_ID, ");
                    query.AppendLine("        '[' + MinorCode + '] '+ dbo.FN_Translate('" + SAMMI.Common.Lang + "', CodeName,'BM0000') AS CODE_NAME, ");
                    query.AppendLine("        dbo.FN_Translate('" + SAMMI.Common.Lang + "', CodeName, 'BM0000') AS CODE_NAME_ORG, ");
                    query.AppendLine("        RelCode1,RelCode2,RelCode3,RelCode4,RelCode5, DisplayNo   AS DisplayNo ");
                    query.AppendLine(" FROM   TBM0000 WITH(NOLOCK) ");
                    query.AppendLine(" WHERE  MajorCode = '" + MajorCode + "'");
                    query.AppendLine(" AND    MinorCode <> '$' ");
                    if (sSql != " ")
                    {
                        query.AppendLine(" AND  " + sSql);
                    }
                }
                //query.AppendLine(" AND UseFlag ='Y'");
                //query.AppendLine(" ORDER BY DisplayNo ");
                rtnDtTemp = helper.FillTable(Convert.ToString(query));
                
                return rtnDtTemp;
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
                return new DataTable();
            }
            finally
            {
                helper.Close();
            }
        }
        #endregion 공통코드 정보 가져오기

        #region 작업장 정보 가져오기

        /// <summary>
        /// 작업장 정보 가져오기

        /// </summary>
        /// <param name="MajorCode">메이저코드 예) 사업장(PLANTCODE)</param>
        /// <returns></returns>
        public DataTable GET_TBM0400_CODE(string OPCode)
        {
            string methodName = new StackFrame().GetMethod().Name;
            DBHelper helper = new DBHelper(false);
            StringBuilder query = null;

            try
            {
                query = new StringBuilder();
                query.Remove(0, query.Length);
                if (helper.ConType == "OracleConnection")
                {
                    query.AppendLine(" SELECT OPCODE AS CODE_ID, ");
                    query.AppendLine("        '[' || OPCODE || '] '||  FN_Translate('" + SAMMI.Common.Lang + "', OPNAME,'BM0400') AS CODE_NAME ");
                    query.AppendLine(" FROM   TBM0400 ");
                    query.AppendLine(" WHERE  OPCODE LIKE '" + OPCode + "%'");
                }
                else
                {
                    query.AppendLine(" SELECT OPCODE AS CODE_ID, ");
                    query.AppendLine("        '[' + OPCODE + '] '+  dbo.FN_Translate('" + SAMMI.Common.Lang + "', OPNAME,'BM0400') AS CODE_NAME ");
                    query.AppendLine(" FROM   TBM0400 ");
                    query.AppendLine(" WHERE  OPCODE LIKE '" + OPCode + "%'");
                }

                return helper.FillTable(Convert.ToString(query));

 
                
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.ToString(), methodName);
                return new DataTable();
            }
            finally
            {
                helper.Close();
             }
        }
        #endregion 작업장 정보 가져오기

        #region 작업라인코드 정보 가져오기

        /// <summary>
        /// 작업라인코드 정보 가져오기

        /// </summary>
        /// <param name="MajorCode">메이저코드 예) 사업장(PLANTCODE)</param>
        /// <returns></returns>
        public DataTable GET_TBM0600_CODE(string WorkCenterCode)
        {
            string methodName = new StackFrame().GetMethod().Name;
            DBHelper helper = new DBHelper(false);
            StringBuilder query = null;

            try
            {
                query = new StringBuilder();
                query.Remove(0, query.Length);
                if (helper.ConType == "OracleConnection")
                {
                    query.AppendLine(" SELECT WorkCenterCode AS CODE_ID, ");
                    query.AppendLine("        '[' || WorkCenterCode || '] '||  FN_Translate('" + SAMMI.Common.Lang + "', WorkCenterName,'BM0600') AS CODE_NAME ");
                    query.AppendLine(" FROM   TBM0600 ");
                    query.AppendLine(" WHERE  WorkCenterCode LIKE '" + WorkCenterCode + "%' ");
                    query.AppendLine(" ORDER BY WorkCenterCode ");
                }
                else
                {
                    query.AppendLine(" SELECT WorkCenterCode AS CODE_ID, ");
                    query.AppendLine("        '[' + WorkCenterCode + '] '+ dbo.FN_Translate('" + SAMMI.Common.Lang + "', WorkCenterName,'BM0600')  AS CODE_NAME ");
                    query.AppendLine(" FROM   TBM0600 WITH(NOLOCK) ");
                    query.AppendLine(" WHERE  WorkCenterCode LIKE '" + WorkCenterCode + "%' ");
                    query.AppendLine(" ORDER BY WorkCenterCode ");
                }

                return helper.FillTable(Convert.ToString(query));

                
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.ToString(), methodName);
                return new DataTable();
            }
            finally
            {
                helper.Close();
            }
        }
        #endregion 작업라인코드 정보 가져오기

        #region 설비코드 정보 가져오기

        /// <summary>
        /// 설비코드 정보 가져오기

        /// </summary>
        /// <param name="MajorCode">메이저코드 예) 사업장(PLANTCODE)</param>
        /// <returns></returns>
        public DataTable GET_TBM0700_CODE(string MachCode)
        {
            string methodName = new StackFrame().GetMethod().Name;
            DBHelper helper = new DBHelper(false);
            StringBuilder query = null;

            try
            {
                query = new StringBuilder();
                query.Remove(0, query.Length);
                if (helper.ConType == "OracleConnection")
                {
                    query.AppendLine(" SELECT MachCode AS CODE_ID, ");
                    query.AppendLine("        '[' || MachCode || '] '||  FN_Translate('" + SAMMI.Common.Lang + "', MachName,'BM0700') AS CODE_NAME ");
                    query.AppendLine(" FROM   TBM0700 ");
                    query.AppendLine(" WHERE  MachCode LIKE '" + MachCode + "%' ");
                    query.AppendLine(" ORDER BY MachCode ");
                }
                else
                {

                    query.AppendLine(" SELECT MachCode AS CODE_ID, ");
                    query.AppendLine("        '[' + MachCode + '] '+  dbo.FN_Translate('" + SAMMI.Common.Lang + "', MachName,'BM0700')  AS CODE_NAME ");
                    query.AppendLine(" FROM   TBM0700 WITH(NOLOCK) ");
                    query.AppendLine(" WHERE  MachCode LIKE '" + MachCode + "%' ");
                    query.AppendLine(" ORDER BY MachCode ");
                }

                return helper.FillTable(Convert.ToString(query));

                
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.ToString(), methodName);
                return new DataTable();
            }
            finally
            {
                helper.Close();
            }
        }
        #endregion 설비코드 정보 가져오기

        #region 품목/품번 정보 가져오기

        /// <summary>
        /// 공통코드 정보 가져오기

        /// </summary>
        /// <param name="MajorCode">메이저코드 예) 사업장(PLANTCODE)</param>
        /// <returns></returns>
        public DataTable GET_TBM0100_CODE(string ItemCode)
        {
            string methodName = new StackFrame().GetMethod().Name;
            DBHelper helper = new DBHelper(false);
            StringBuilder query = null;

            try
            {
                query = new StringBuilder();
                query.Remove(0, query.Length);

                if (helper.ConType == "OracleConnection")
                {
                    query.AppendLine(" SELECT ItemCode AS CODE_ID, ");
                    query.AppendLine("        '[' || ItemCode || '] '||  FN_Translate('" + SAMMI.Common.Lang + "', ItemName,'BM0100') AS CODE_NAME ");
                    query.AppendLine(" FROM   TBM0100 ");
                    query.AppendLine(" WHERE  ItemCode LIKE '" + ItemCode + "%' ");

                }
                else
                {
                    query.AppendLine(" SELECT ItemCode AS CODE_ID, ");
                    query.AppendLine("        '[' + ItemCode + '] '+  dbo.FN_Translate('" + SAMMI.Common.Lang + "', ItemName,'BM0100')    AS CODE_NAME ");
                    query.AppendLine(" FROM   TBM0100 WITH(NOLOCK) ");
                    query.AppendLine(" WHERE  ItemCode LIKE '" + ItemCode + "%' ");


                 }
                return  helper.FillTable(Convert.ToString(query));

            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.ToString(), methodName);
                return new DataTable();
            }
            finally
            {
                helper.Close();
            }
        }
        #endregion 품목/품번 정보 가져오기

        #region 공통코드 컬럼별로 값 가져오기

        /// <summary>
        /// 공통코드 정보 가져오기

        /// </summary>
        /// <param name="MajorCode">메이저코드 예) 사업장(PLANTCODE)</param>
        /// <param name="sArr"> ColumnName, Value, ColumnName2, Value2, ... </param>
        /// <returns></returns>
        public DataTable GET_TBM0000_CODE(string MajorCode, string[] sArr)
        {
            string methodName = new StackFrame().GetMethod().Name;
            DBHelper helper = new DBHelper();
            StringBuilder query = null;

            try
            {
                query = new StringBuilder();
                query.Remove(0, query.Length);
                if (helper.ConType == "OracleConnection")
                {

                    query.AppendLine(" SELECT MinorCode AS CODE_ID, ");
                    query.AppendLine("        '[' || MinorCode || '] '|| FN_Translate('" + SAMMI.Common.Lang + "', CodeName,'BM0000') AS CODE_NAME, ");
                    query.AppendLine("        FN_Translate('" + SAMMI.Common.Lang + "', CodeName, 'BM0000') AS CODE_NAME_ORG, ");
                    query.AppendLine("         DisplayNo   AS DisplayNo ");
                    query.AppendLine(" FROM   TBM0000  ");
                    query.AppendLine(" WHERE  MajorCode =  :MajorCode ");
                    query.AppendLine(" AND    MinorCode <> '$' "); 
                }
                else
                {
                    query.AppendLine(" SELECT MinorCode AS CODE_ID, ");
                    query.AppendLine("        '[' + MinorCode + '] '+  dbo.FN_Translate('" + SAMMI.Common.Lang + "', CodeName,'BM0000') AS CODE_NAME, ");
                    query.AppendLine("        dbo.FN_Translate('" + SAMMI.Common.Lang + "', CodeName, 'BM0000') AS CODE_NAME_ORG, ");
                    query.AppendLine("         DisplayNo   AS DisplayNo ");
                    query.AppendLine(" FROM   TBM0000 WITH(NOLOCK) ");
                    query.AppendLine(" WHERE  MajorCode =  @MajorCode ");
                    query.AppendLine(" AND    MinorCode <> '$' ");

                }
                for (int i = 0; i < sArr.Length; i += 2)
                {
                    query.AppendLine(" AND  " + sArr[i] + " = '" + sArr[i + 1] + "' ");
                }

                query.AppendLine(" ORDER BY DisplayNo ");


                return helper.FillTable(Convert.ToString(query));

                
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
                return new DataTable();
            }
            finally
            {
                helper.Close();
           }
        }
        #endregion 공통코드 정보 가져오기

        #region 거래선정보 가져오기

        /// <summary>
        /// 거래선정보 가져오기 , 외주처 정보 가져오기.
        /// </summary>
        /// <param name="MajorCode">메이저코드 예) 사업장(PLANTCODE)</param>
        /// <returns></returns>
        public DataTable GET_TBM0300_CODE(string CustCode)
        {
            return GET_TBM0300_CODE(CustCode, "");
        }
        public DataTable GET_TBM0300_CODE(string CustCode, string InCustType)
        {
            string methodName = new StackFrame().GetMethod().Name;
            DBHelper helper = new DBHelper(false);
            StringBuilder query = null;
            try
            {
                query = new StringBuilder();
                query.Remove(0, query.Length);
                if (InCustType == "CustType")//
                {
                    if (helper.ConType == "OracleConnection")
                    {
                        query.AppendLine(" SELECT CUSTCODE AS CODE_ID, ");
                        query.AppendLine("        '[' || CUSTCODE || '] '||  FN_Translate('" + SAMMI.Common.Lang + "', CustName,'BM0300') AS CODE_NAME ");
                        query.AppendLine(" FROM   TBM0300  ");
                        query.AppendLine(" WHERE  CustType =  'P' ");
                        query.AppendLine(" AND    CustCode like '" + CustCode + "%'");
                        query.AppendLine(" ORDER BY CustCode ");
                    }
                    else
                    {
                        query.AppendLine(" SELECT CustCode AS CODE_ID, ");
                        query.AppendLine("        '[' + CustCode + '] '+   dbo.FN_Translate('" + SAMMI.Common.Lang + "', CustName,'BM0300')  AS CODE_NAME ");
                        query.AppendLine(" FROM   TBM0300 WITH(NOLOCK) ");
                        query.AppendLine(" WHERE  CustType =  'P' ");
                        query.AppendLine(" AND    CustCode like '" + CustCode + "%'");
                        query.AppendLine(" ORDER BY CustCode ");
                    }
                    return helper.FillTable(Convert.ToString(query));
                }
                else
                {
                    if (InCustType == "")
                    {
                        if (helper.ConType == "OracleConnection")
                        {
                            query.AppendLine(" SELECT CustCode AS CODE_ID, ");
                            query.AppendLine("        '[' || CustCode || '] '||  FN_Translate('" + SAMMI.Common.Lang + "', CustName,'BM0300') AS CODE_NAME ");
                            query.AppendLine(" FROM   TBM0300  ");
                            query.AppendLine(" WHERE  CustType =  'V' ");
                            query.AppendLine(" AND    CustCode <> '$' ");
                            query.AppendLine(" AND    CustCode like '" + CustCode + "%'");

                            query.AppendLine(" ORDER BY CustCode ");
                        }
                        else
                        {
                            query.AppendLine(" SELECT CustCode AS CODE_ID, ");
                            query.AppendLine("        '[' + CustCode + '] '+   dbo.FN_Translate('" + SAMMI.Common.Lang + "', CustName,'BM0300')   AS CODE_NAME ");
                            query.AppendLine(" FROM   TBM0300 WITH(NOLOCK) ");
                            query.AppendLine(" WHERE  CustType =  'V' ");
                            query.AppendLine(" AND    CustCode <> '$' ");
                            query.AppendLine(" AND    CustCode like '" + CustCode + "%'");
                            query.AppendLine(" ORDER BY CustCode ");
                        }

                        return helper.FillTable(Convert.ToString(query));
                    }
                    else
                    {
                        if (helper.ConType == "OracleConnection")
                        {
                            query.AppendLine(" SELECT CUSTCODE AS CODE_ID, ");
                            query.AppendLine("        '[' || CUSTCODE || '] '||  FN_Translate('" + SAMMI.Common.Lang + "', CustName,'BM0300') AS CODE_NAME ");
                            query.AppendLine(" FROM   TBM0300  ");
                            query.AppendLine(" WHERE  CustType in  (" + InCustType + ") ");
                            query.AppendLine(" AND    CustCode like '" + CustCode + "%'");
                            query.AppendLine(" ORDER BY CustCode ");
                        }
                        else
                        {
                            query.AppendLine(" SELECT CustCode AS CODE_ID, ");
                            query.AppendLine("        '[' + CustCode + '] '+   dbo.FN_Translate('" + SAMMI.Common.Lang + "', CustName,'BM0300')  AS CODE_NAME ");
                            query.AppendLine(" FROM   TBM0300 WITH(NOLOCK) ");
                            query.AppendLine(" WHERE  CustType in  (" + InCustType + ")");
                            query.AppendLine(" AND    CustCode like '" + CustCode + "%'");
                            query.AppendLine(" ORDER BY CustCode ");
                        }

                        rtnDtTemp = helper.FillTable(Convert.ToString(query));
                        //사업장권한 설정
                        if (bPlantAuth && SAMMI.LoginInfo.UserID != "SYSTEM")
                        {
                            SetPlantAuth();
                        }
                        return rtnDtTemp;
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.ToString(), methodName);
                return new DataTable();
            }
            finally
            {
                helper.Close();
            }

        }
        #endregion 거래선 정보 가져오기

        #region 단위 정보 가져오기

        /// <summary>
        /// 단위 정보 가져오기

        /// </summary>
        /// <returns></returns>
        public DataTable GET_TBM1300_CODE(string sUseFlag)
        {
            string methodName = new StackFrame().GetMethod().Name;
            DBHelper helper = new DBHelper(false);
            StringBuilder query = null;


            try
            {
                query = new StringBuilder();
                query.Remove(0, query.Length);

                if (helper.ConType == "OracleConnection")
                {
                    query.AppendLine(" SELECT UnitCode AS CODE_ID, ");
                    query.AppendLine("        UnitCode AS CODE_NAME, ");
                    query.AppendLine("         DisplayNo   AS DisplayNo ");
                    query.AppendLine(" FROM   TBM1300  ");
                    query.AppendLine(" WHERE  UseFlag =  '"+sUseFlag+"' ");
                    query.AppendLine(" ORDER BY DisplayNo ");
                }
                else
                {
                    query.AppendLine(" SELECT UnitCode AS CODE_ID, ");
                    query.AppendLine("        UnitCode AS CODE_NAME, ");
                    query.AppendLine("         DisplayNo   AS DisplayNo ");
                    query.AppendLine(" FROM   TBM1300 WITH(NOLOCK) ");
                    query.AppendLine(" WHERE  UseFlag =  '"+sUseFlag+"'  ");
                    query.AppendLine(" ORDER BY DisplayNo ");
                }
                return helper.FillTable(Convert.ToString(query) );

                
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.ToString(), methodName);
                return new DataTable();
            }
            finally
            {
                helper.Close();
            }
        }

        public DataTable GET_TBM1300_CODE_1(string sUnitType, string sUseflag)
        {
            string methodName = new StackFrame().GetMethod().Name;
             StringBuilder query = null;
            DBHelper helper = new DBHelper(false);

            try
            {
                query = new StringBuilder();
                query.Remove(0, query.Length);
                if (helper.ConType == "OracleConnection")
                {
                    query.AppendLine(" SELECT UnitCode AS CODE_ID, ");
                    query.AppendLine("        '[' || UnitCode || ']'  AS CODE_NAME, ");
                    query.AppendLine("         DisplayNo   AS DisplayNo ");
                    query.AppendLine(" FROM   TBM1300  ");
                    query.AppendLine(" WHERE  UseFlag =  :useflag ");
                    query.AppendLine("   AND  unitType =  :unitType ");
                    query.AppendLine(" ORDER BY DisplayNo ");
                }
                else
                {
                    query.AppendLine(" SELECT UnitCode AS CODE_ID, ");
                    query.AppendLine("        UnitCode AS CODE_NAME, ");
                    query.AppendLine("         DisplayNo   AS DisplayNo ");
                    query.AppendLine(" FROM   TBM1300 WITH(NOLOCK) ");
                    query.AppendLine(" WHERE  UseFlag =  @useflag ");
                    query.AppendLine("   AND  unitType =  @unitType ");
                    query.AppendLine(" ORDER BY DisplayNo ");
                }

                return helper.FillTable(Convert.ToString(query), CommandType.Text, helper.CreateParameter("useflag", sUseflag, DbType.String, ParameterDirection.Input)
                                                                                      , helper.CreateParameter("unitType", sUnitType, DbType.String, ParameterDirection.Input));

               
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.ToString(), methodName);
                return new DataTable();
            }
            finally
            {
                helper.Close();
            }
        }
        #endregion 공통코드 정보 가져오기

        #region 창고 코드 정보 가져오기

        /// <summary>
        /// 창고 코드 정보 가져오기

        /// </summary>
        /// <param name="sPlantCode">사업장(공장)</param>
        /// <returns></returns>
        public DataTable GET_TBM0800_CODE(string sPlantCode)
        {
            string methodName = new StackFrame().GetMethod().Name;
            DBHelper helper = new DBHelper(false);
            StringBuilder query = null;

            try
            {
                query = new StringBuilder();
                query.Remove(0, query.Length);

                if (helper.ConType == "OracleConnection")
                {
                    query.AppendLine(" SELECT  WHCode AS CODE_ID,                        ");
                    query.AppendLine("       '[' || WHCode || ']' || FN_Translate('" + SAMMI.Common.Lang + "', WHName,'BM0800')   AS CODE_NAME");
                    query.AppendLine("  FROM   TBM0800                                   ");
                    query.AppendLine(" WHERE  PlantCode  Like  '" + sPlantCode.ToUpper() + "' || '%'         ");
                    query.AppendLine(" ORDER BY PlantCode, WHCode                        ");
                }
                else
                {

                    query.AppendLine(" SELECT  WHCode AS CODE_ID,                        ");
                    query.AppendLine("        '[' + WHCode + ']' +  dbo.FN_Translate('" + SAMMI.Common.Lang + "', WHName,'BM0800')  AS CODE_NAME  ");
                    query.AppendLine("  FROM   TBM0800 WITH(NOLOCK)                      ");
                    query.AppendLine(" WHERE  PlantCode  Like  '" + sPlantCode + "%'          ");
                    query.AppendLine(" ORDER BY PlantCode, WHCode                        ");
                }

                return helper.FillTable(Convert.ToString(query));
               
               
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.ToString(), methodName);
                return new DataTable();
            }
            finally
            {
                helper.Close();
            }
        }
        #endregion 창고 코드 정보 가져오기

        #region 창고 코드 정보 가져오기(창고별)
        /// <summary>
        /// 창고 코드 정보 가져오기(창고별)
        /// </summary>
        /// <param name="sPlantCode">사업장(공장)</param>
        /// <returns></returns>
        public DataTable GET_TBM0800_1_CODE(string WHType)
        {
            string methodName = new StackFrame().GetMethod().Name;
            DBHelper helper = new DBHelper(false);
            StringBuilder query = null;

            try
            {
                query = new StringBuilder();
                query.Remove(0, query.Length);
                if (helper.ConType == "OracleConnection")
                {
                    query.AppendLine(" SELECT  WHCode AS CODE_ID,                         ");
                    query.AppendLine("        '[' || WHCode || ']' || FN_Translate('" + SAMMI.Common.Lang + "', WHName,'BM0800')  AS CODE_NAME");
                    query.AppendLine("  FROM   TBM0800                                    ");
                    query.AppendLine(" WHERE  '" + WHType.ToUpper() + "'  =  'Y'             ");
                    query.AppendLine(" ORDER BY PlantCode, WHCode                         ");
                }
                else
                {

                    query.AppendLine(" SELECT  WHCode AS CODE_ID,                        ");
                    query.AppendLine("        '[' + WHCode + ']' + dbo.FN_Translate('" + SAMMI.Common.Lang + "', WHName,'BM0800')   AS CODE_NAME  ");
                    query.AppendLine("  FROM   TBM0800 WITH(NOLOCK)                      ");
                    query.AppendLine(" WHERE  '" + WHType.ToUpper() + "' =  'Y'           ");
                    query.AppendLine(" ORDER BY PlantCode, WHCode                        ");
                }

                return helper.FillTable(Convert.ToString(query));

                 
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.ToString(), methodName);
                return new DataTable();
            }
            finally
            {
                helper.Close();
             }
        }
        #endregion 창고 코드 정보 가져오기(창고별)

        #region 자재검사결과 코드 정보 가져오기

        /// <summary>
        /// 자재검사결과 코드 정보 가져오기

        /// </summary>
        /// <param name="sPlantCode">자재검사결과(공장)</param>
        /// <returns></returns>
        public DataTable GET_TMM0900_CODE(string InspResultDesc)
        {
            string methodName = new StackFrame().GetMethod().Name;
            DBHelper helper = new DBHelper();
            StringBuilder query = null;

            try
            {
                query = new StringBuilder();
                query.Remove(0, query.Length);

                query.AppendLine(" SELECT  InspResultDesc AS CODE_ID,                        ");
                query.AppendLine(" InspResultDesc  AS CODE_NAME  ");
                query.AppendLine("  FROM   TMM0900 WITH(NOLOCK)                      ");
                query.AppendLine(" WHERE  InspResultDesc  Like '"+InspResultDesc+"%'          ");
                query.AppendLine(" ORDER BY InspResultDesc                     ");

                return helper.FillTable(Convert.ToString(query));

                 
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.ToString(), methodName);
                return new DataTable();
            }
            finally
            {
                helper.Close();
            }
        }
        #endregion 자재검사결과 코드 정보 가져오기

        #region 저장위치코드 정보 가져오기

        /// <summary>
        /// 저장위치코드 정보 가져오기

        /// </summary>
        /// <param name="sWHCode">창고코드</param>
        /// <returns></returns>
        public DataTable GET_TBM0900_CODE(string sWHCode)
        {
            string methodName = new StackFrame().GetMethod().Name;

            DBHelper helper = new DBHelper(false);
            StringBuilder query = null;

            try
            {
                query = new StringBuilder();
                query.Remove(0, query.Length);

                if (helper.ConType == "OracleConnection")
                {
                    query.AppendLine("   SELECT  StorageLocCode  AS CODE_ID,                               ");
                    query.AppendLine("        '[' || StorageLocCode ||']' + FN_Translate('" + SAMMI.Common.Lang + "', StorageLocName,'BM0900') AS CODE_NAME     ");
                    query.AppendLine("   FROM TBM0900                                                      ");
                    query.AppendLine("  WHERE WHCode LIKE '" + sWHCode.ToUpper() + "' || '%'                                    ");
                    query.AppendLine("   ORDER BY WHCode, StorageLocCode                                    ");
                }

                else
                {
                    query.AppendLine("   SELECT  StorageLocCode  AS CODE_ID,                               ");
                    query.AppendLine("        '[' + StorageLocCode +']' +  dbo.FN_Translate('" + SAMMI.Common.Lang + "', StorageLocName,'BM0900') AS CODE_NAME     ");
                    query.AppendLine("   FROM TBM0900                                                      ");
                    query.AppendLine("  WHERE WHCode LIKE " + sWHCode + " + '%'                                    ");
                    query.AppendLine("   ORDER BY WHCode, StorageLocCode                                    ");
                }

 
                return helper.FillTable(Convert.ToString(query));

                
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.ToString(), methodName);
                return new DataTable();
            }
            finally
            {
                 helper.Close();

            }
        }
        #endregion 저장위치코드 정보 가져오기



        #region 콤보박스 바인
        public static void FillComboMaster(UltraCombo comboBox, object DataSource, string[] colList = null)
        {
            if (DataSource.GetType() == typeof(DataTable))
            {
                DataTable tempDataTable = new DataTable();
                tempDataTable = (DataSource as DataTable);

                int colCount = tempDataTable.Columns.Count;

                if (colList != null)
                {
                    for (int i = 0; i < colCount; i++)
                        comboBox.DisplayLayout.Bands[0].Columns.Add(tempDataTable.Columns[i].ColumnName, colList[i]);
                }
                else
                {
                    for (int i = 0; i < colCount; i++)
                        comboBox.DisplayLayout.Bands[0].Columns.Add(tempDataTable.Columns[i].ColumnName, tempDataTable.Columns[i].ColumnName);
                }
            }
            comboBox.DropDownStyle = UltraComboStyle.DropDown;
            comboBox.DataSource = DataSource;
            comboBox.MouseWheel += new MouseEventHandler(Common.comboBox_MouseWheel);
            
        }
        public static void FillComboboxMaster(UltraCombo comboBox, object DataSource, string ValueField, string DisplayField, string InitText, string InitValue)
        {
            comboBox.DropDownStyle = UltraComboStyle.DropDown;

            List<KeyValuePair<string, string>> comboBoxData = new List<KeyValuePair<string, string>>();

            if (InitText != null && bPlantAuthALL)
                comboBoxData.Add(new KeyValuePair<string, string>(InitValue, InitText));
            bPlantAuthALL = true;
            if (DataSource.GetType() == typeof(DataSet))
            {
                foreach (DataRow drRow1 in (DataSource as DataSet).Tables[0].Rows)
                    comboBoxData.Add(new KeyValuePair<string, string>(drRow1[ValueField].ToString(), drRow1[DisplayField].ToString()));
            }
            else if (DataSource.GetType() == typeof(DataTable))
            {
                foreach (DataRow drRow2 in (DataSource as DataTable).Rows)
                    comboBoxData.Add(new KeyValuePair<string, string>(drRow2[ValueField].ToString(), drRow2[DisplayField].ToString()));
            }
            else if (DataSource.GetType() == typeof(Dictionary<string, string>))
            {
                foreach (KeyValuePair<string, string> dValue in (DataSource as Dictionary<string, string>))
                    comboBoxData.Add(dValue);
            }

            comboBox.ValueMember = "Key";
            comboBox.DisplayMember = "Value";
            comboBox.DataSource = comboBoxData;

            comboBox.MouseWheel += new MouseEventHandler(Common.comboBox_MouseWheel);
        }

        //2019 11 19 HJH
        //콤보박스에서 데이터를 검색할 수 있도록(UltraComboEditor 컨트롤만 사용 가능)
        public static void FillComboboxMasterSearch(UltraComboEditor comboBox, object DataSource, string ValueField, string DisplayField, string InitText, string InitValue)
        {
            List<KeyValuePair<string, string>> comboBoxData = new List<KeyValuePair<string, string>>();

            if (InitText != null && bPlantAuthALL)
                comboBoxData.Add(new KeyValuePair<string, string>(InitValue, InitText));
            bPlantAuthALL = true;

            if (DataSource.GetType() == typeof(DataSet))
            {
                foreach (DataRow drRow1 in (DataSource as DataSet).Tables[0].Rows)
                    comboBoxData.Add(new KeyValuePair<string, string>(drRow1[ValueField].ToString(), drRow1[DisplayField].ToString()));
            }
            else if (DataSource.GetType() == typeof(DataTable))
            {
                foreach (DataRow drRow2 in (DataSource as DataTable).Rows)
                    comboBoxData.Add(new KeyValuePair<string, string>(drRow2[ValueField].ToString(), drRow2[DisplayField].ToString()));
            }
            else if (DataSource.GetType() == typeof(Dictionary<string, string>))
            {
                foreach (KeyValuePair<string, string> dValue in (DataSource as Dictionary<string, string>))
                    comboBoxData.Add(dValue);
            }

            comboBox.ValueMember = "Key";
            comboBox.DisplayMember = "Value";
            comboBox.DataSource = comboBoxData;

            comboBox.MouseWheel += new MouseEventHandler(Common.comboBox_MouseWheel);

            if (comboBox.Items.Count > 0)
                comboBox.SelectedIndex = 0;

            //2019 11 19 HJH 추가
            comboBox.AutoCompleteMode = Infragistics.Win.AutoCompleteMode.SuggestAppend;
            comboBox.AutoSuggestFilterMode = Infragistics.Win.AutoSuggestFilterMode.Contains;
            //2020 01 08 HJH 주석
            //아래 주석 해제하면 없는 값 입력하는 경우 먹통 됨

            //comboBox.LimitToList = true;
            comboBox.DropDownStyle = Infragistics.Win.DropDownStyle.DropDown;
        }
        public static void FillComboboxMaster(UltraComboEditor comboBox, object DataSource, string ValueField, string DisplayField, string InitText, string InitValue)
        {
            //comboBox.DropDownStyle = ComboBoxStyle.DropDownList;
            comboBox.DropDownStyle = Infragistics.Win.DropDownStyle.DropDownList;

            comboBox.AutoCompleteMode = Infragistics.Win.AutoCompleteMode.SuggestAppend;
            //comboBox.AutoCompleteSource   = AutoCompleteSource.ListItems;

            List<KeyValuePair<string, string>> comboBoxData = new List<KeyValuePair<string, string>>();
  
            if (InitText != null && bPlantAuthALL)
                comboBoxData.Add(new KeyValuePair<string, string>(InitValue, InitText));
            bPlantAuthALL = true;

            if (DataSource.GetType() == typeof(DataSet))
            {
                foreach (DataRow drRow1 in (DataSource as DataSet).Tables[0].Rows)
                    comboBoxData.Add(new KeyValuePair<string, string>(drRow1[ValueField].ToString(), drRow1[DisplayField].ToString()));
            }
            else if (DataSource.GetType() == typeof(DataTable))
            {
                foreach (DataRow drRow2 in (DataSource as DataTable).Rows)
                    comboBoxData.Add(new KeyValuePair<string, string>(drRow2[ValueField].ToString(), drRow2[DisplayField].ToString()));
            }
            else if (DataSource.GetType() == typeof(Dictionary<string, string>))
            {
                foreach (KeyValuePair<string, string> dValue in (DataSource as Dictionary<string, string>))
                    comboBoxData.Add(dValue);
            }

            comboBox.ValueMember = "Key";
            comboBox.DisplayMember = "Value";
            comboBox.DataSource = comboBoxData;

            comboBox.MouseWheel += new MouseEventHandler(Common.comboBox_MouseWheel);

            if (comboBox.Items.Count > 0)
                comboBox.SelectedIndex = 0;
        }
        public static void FillComboboxMaster(ComboBox comboBox, object DataSource, string ValueField, string DisplayField, string InitText, string InitValue, bool bMakeComboEtcData = false, string selectValue = "")
        {
            //comboBox.DropDownStyle = ComboBoxStyle.DropDownList;
            comboBox.DropDownStyle = ComboBoxStyle.DropDown;

            comboBox.AutoCompleteMode = AutoCompleteMode.SuggestAppend;
            comboBox.AutoCompleteSource = AutoCompleteSource.ListItems;

            List<KeyValuePair<string, string>> comboBoxData = new List<KeyValuePair<string, string>>();

            if (InitText != null && bPlantAuthALL)
                comboBoxData.Add(new KeyValuePair<string, string>(InitValue, InitText));
            bPlantAuthALL = true;

            if (DataSource.GetType() == typeof(DataSet))
            {
                foreach (DataRow drRow1 in (DataSource as DataSet).Tables[0].Rows)
                {
                    comboBoxData.Add(new KeyValuePair<string, string>(drRow1[ValueField].ToString(), drRow1[DisplayField].ToString()));


                }
            }
            else if (DataSource.GetType() == typeof(DataTable))
            {
                foreach (DataRow drRow2 in (DataSource as DataTable).Rows)
                    comboBoxData.Add(new KeyValuePair<string, string>(drRow2[ValueField].ToString(), drRow2[DisplayField].ToString()));
            }
            else if (DataSource.GetType() == typeof(Dictionary<string, string>))
            {
                foreach (KeyValuePair<string, string> dValue in (DataSource as Dictionary<string, string>))
                    comboBoxData.Add(dValue);
            }

            comboBox.ValueMember = "Key";
            comboBox.DisplayMember = "Value";
            comboBox.DataSource = comboBoxData;

            comboBox.MouseWheel += new MouseEventHandler(Common.comboBox_MouseWheel);

            if (comboBox.Items.Count > 0)
            {
                // selectValue 초기값 설정
                if (selectValue != null && selectValue != "")
                {
                    int idx = 0;
                    foreach (KeyValuePair<string, string> dValue in comboBox.Items)
                    {
                        if (dValue.Key == selectValue)
                        {
                            comboBox.SelectedIndex = idx;
                            break;
                        }
                        idx++;
                    }
                }
                else
                {
                    comboBox.SelectedIndex = 0;
                }
            }
        }
        #endregion

        #region 콤보박스 마우스 휠

        public static void comboBox_MouseWheel(object sender, MouseEventArgs e)
        {
            ((HandledMouseEventArgs)e).Handled = true;

            // index 에러 : 11/20 장우규 - try, catch 추가
            try
            {
                if (((ComboBox)(sender)).SelectedIndex == 0)
                {
                    if (e.Delta / 120 == -1)
                    {
                        ((ComboBox)(sender)).SelectedIndex += (e.Delta / 120) * -1;
                        return;
                    }
                    else
                    {
                        return;
                    }
                }
                ((ComboBox)(sender)).SelectedIndex += (e.Delta / 120) * -1;
            }
            catch { }
        }
        #endregion

        #region 콤보박스 바인
        public static void FillUltraComboboxMaster(UltraComboEditor comboBox, object DataSource, string ValueField, string DisplayField, string InitText, string InitValue)
        {
            //comboBox.DropDownStyle = ComboBoxStyle.DropDownList;
            comboBox.DropDownStyle = Infragistics.Win.DropDownStyle.DropDownList;

            comboBox.AutoCompleteMode = Infragistics.Win.AutoCompleteMode.SuggestAppend;
            //comboBox.AutoCompleteSource   = AutoCompleteSource.ListItems;

            List<KeyValuePair<string, string>> comboBoxData = new List<KeyValuePair<string, string>>();

            if (InitText != null)
                comboBoxData.Add(new KeyValuePair<string, string>(InitValue, InitText));
            if (DataSource.GetType() == typeof(DataSet))
            {
                foreach (DataRow drRow1 in (DataSource as DataSet).Tables[0].Rows)
                    comboBoxData.Add(new KeyValuePair<string, string>(drRow1[ValueField].ToString(), drRow1[DisplayField].ToString()));
            }
            else if (DataSource.GetType() == typeof(DataTable))
            {
                foreach (DataRow drRow2 in (DataSource as DataTable).Rows)
                    comboBoxData.Add(new KeyValuePair<string, string>(drRow2[ValueField].ToString(), drRow2[DisplayField].ToString()));
            }
            else if (DataSource.GetType() == typeof(Dictionary<string, string>))
            {
                foreach (KeyValuePair<string, string> dValue in (DataSource as Dictionary<string, string>))
                    comboBoxData.Add(dValue);
            }

            comboBox.ValueMember = "Key";
            comboBox.DisplayMember = "Value";
            comboBox.DataSource = comboBoxData;

            comboBox.MouseWheel += new MouseEventHandler(Common.comboBox_MouseWheel);

            if (comboBox.Items.Count > 0)
                comboBox.SelectedIndex = 0;
        }
        #endregion

        #region 그리드 컬럼 넓이 값 복사
        public void Grid_Column_Width(UltraGrid grid)
        {
            string sWidth = string.Empty;

            for (int i = 0; i < grid.DisplayLayout.Bands[0].Columns.Count; i++)
            {
                sWidth = sWidth + Convert.ToString(grid.DisplayLayout.Bands[0].Columns[i].Width) + " ";
            }

            Clipboard.Clear();
            Clipboard.SetText(sWidth);
        }

        private System.Windows.Forms.Control gGetControl(System.Windows.Forms.Control con, string name)
        {
            if (con == null)
                return null;

            if (con.Name == name)
                return con;

            foreach (System.Windows.Forms.Control c in con.Controls)
            {
                con = gGetControl(c, name);
                if (con != null)
                    return con;
            }

            return null;
        }

        public static System.Windows.Forms.Control gRemoveControl(System.Windows.Forms.Control con, string name)
        {
            if (con == null)
                return null;

            if (con.Name == name)
            {
                System.Windows.Forms.Control c = con.Parent;
                c.Controls.Remove(con);
                return null;
            }

            foreach (System.Windows.Forms.Control c in con.Controls)
            {
                con = gRemoveControl(c, name);
            }

            return null;
        }


        #endregion

        #region 트리 그리드 관련

        public static DataSet MultiGridRelations(DataTable DtTemp, bool Relations)
        {

            DataSet set = new DataSet();

            int level = 1;

            for (int i = 1; i < DtTemp.Rows.Count; i++)
            {

                if (level < Convert.ToInt32(DtTemp.Rows[i]["LEVEL"]))
                {

                    level = Convert.ToInt32(DtTemp.Rows[i]["LEVEL"]);

                }

            }

            DataTable[] tableArray = new DataTable[level];



            for (int j = 0; j < tableArray.Length; j++)
            {

                tableArray[j] = DtTemp.Clone();

                foreach (DataRow row in DtTemp.Select("LEVEL= '" + (j + 1) + "'"))
                {

                    tableArray[j].ImportRow(row);

                    tableArray[j].TableName = j.ToString();

                }

                set.Tables.Add(tableArray[j]);

            }

            int relation = level - 1;

            for (int k = 0; k < level; k++)
            {

                if (relation != k)
                {

                    set.Relations.Add("MultiGrid" + k, set.Tables[k].Columns["TAG_NAME"], set.Tables[k + 1].Columns["TAG_NAME"], Relations);

                }

            }

            return set;

        }

        #endregion

        #region 공통Function
        public static Color FromStringToColor(string name)
        {
            if (string.IsNullOrWhiteSpace(name))
            {
                return Color.Black;
            }

            if (name.Equals(""))
                return Color.Black;
            
            KnownColor knownColor;

            if (Enum.TryParse(name, out knownColor))
            {
                return Color.FromKnownColor(knownColor);
            }

            if (name.IndexOf(",") < 0)
                return Color.Black;

            string[] svar = name.Split(',');
            int A = 255, R = 255, G = 255, B = 255;

            foreach (string s in svar)
            {
                string[] sRGB = s.Split('=');
                if (sRGB[0].IndexOf("A") >= 0)
                    A = Convert.ToInt32(sRGB[1]);
                if (sRGB[0].IndexOf("R") >= 0)
                    R = Convert.ToInt32(sRGB[1]);
                if (sRGB[0].IndexOf("G") >= 0)
                    G = Convert.ToInt32(sRGB[1]);
                if (sRGB[0].IndexOf("B") >= 0)
                    B = Convert.ToInt32(sRGB[1]);
            }
            return Color.FromArgb(A, R, G, B);
        }


        public static string GetIPAddress()
        {
            string iniADDR = SAMMI.IniFile.GetValue("KLEANNARA", "IPADDR", "").Trim();
            string sIPAddress = string.Empty;

            ObjectQuery oQry = new ObjectQuery(WMI_QUERY);
            ManagementObjectSearcher oSearcher = new ManagementObjectSearcher(oQry);
            try
            {
                foreach (ManagementObject obj in oSearcher.Get())
                {
                    if(obj["Description"].ToString().ToUpper().IndexOf("VIRTUAL") >= 0) continue;
                    
                    sIPAddress = ((string[])obj["IPAddress"])[0];

                    if (iniADDR.Length > 0)
                    {
                        if (iniADDR == sIPAddress)
                        {
                            break; 
                        }
                        continue;
                    }
                    break;
                }
            }
            catch (System.Exception ex)
            {
                Console.WriteLine(ex.Message);
                sIPAddress = "127.0.0.1";
            }
            return sIPAddress;
        }
        public static System.Windows.Forms.Control FindControl(System.Windows.Forms.Control.ControlCollection controlcollection, string controlid)
        {
            System.Windows.Forms.Control rsltcontrol;
            // 정상적으로 찾은 경우 컨트롤을 반환
            if (controlcollection[controlid] != null) return controlcollection[controlid];

            // 없을 경우 자식을 변경 한다.
            for (int i = 0; i < controlcollection.Count; i++)
            {
                rsltcontrol = FindControl(controlcollection[i].Controls, controlid);

                if (rsltcontrol != null) return rsltcontrol;
            }

            return null;
        }
        public static string getLangText(string cText)
        {
            return getLangText(cText, "");
        }

        public static DataTable langTable = null;

        public static string getLangText(string cText, string cOp)
        {
#if true
            //2020 03 12 이윤지
            return cText;
#else
            if (SAMMI.Common.Lang == "KO")
                return cText;

            if (langTable == null)
            {
                DBHelper helper1 = new DBHelper(true);

                langTable = helper1.FillTable("USP_ZZ9100_S2", CommandType.StoredProcedure);
                langTable.PrimaryKey = new DataColumn[] { langTable.Columns["WKEY"], langTable.Columns["OPKEY"] };
            }

            DataRow dr = langTable.Rows.Find(new string[] { cText, cOp });
            if (dr != null)
            {
                return dr["Translate"].ToString();
            }

            DBHelper helper = new DBHelper(false);

            try
            {
                cText = helper.ExecuteScalar("USP_ZZ9100_S1", CommandType.StoredProcedure
                                                                  //  , helper.CreateParameter("Lang", SAMMI.Common.Lang, DbType.String, ParameterDirection.Input)
                                                                    , helper.CreateParameter("wKey", cText, DbType.String, ParameterDirection.Input)
                                                                    , helper.CreateParameter("OpKey", cOp, DbType.String, ParameterDirection.Input)
                                                                    ).ToString();
            }
            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                helper.Close();
            }

            return cText;
#endif
        }

        #region encrytion
        static string passkey = "sammii";

        public string PassKey
        {
            set { passkey = value; }
        }

        public static byte[] Encrypt(byte[] clearData, byte[] Key, byte[] IV)
        {
            System.IO.MemoryStream ms = new System.IO.MemoryStream();

            Rijndael alg = Rijndael.Create();

            alg.Key = Key;
            alg.IV = IV;

            CryptoStream cs = new CryptoStream(ms, alg.CreateEncryptor(), CryptoStreamMode.Write);

            cs.Write(clearData, 0, clearData.Length);

            cs.Close();

            byte[] encryptedData = ms.ToArray();

            return encryptedData;
        } 

        public static string EncryptString(string InputText)
        {
            if (InputText.Length == 0)
                return "";

            byte[] clearBytes = System.Text.Encoding.Unicode.GetBytes(InputText);

            PasswordDeriveBytes pdb = new PasswordDeriveBytes(passkey,
                new byte[] { 0x49, 0x76, 0x61, 0x6e, 0x20, 0x4d, 0x65, 0x64, 0x76, 0x65, 0x64, 0x65, 0x76 });

            byte[] encryptedData = Encrypt(clearBytes, pdb.GetBytes(32), pdb.GetBytes(16));

            return Convert.ToBase64String(encryptedData);
        }

        public static byte[] Decrypt(byte[] cipherData, byte[] Key, byte[] IV)
        {
            System.IO.MemoryStream ms = new System.IO.MemoryStream();

            Rijndael alg = Rijndael.Create();

            alg.Key = Key;
            alg.IV = IV;

            CryptoStream cs = new CryptoStream(ms,
                alg.CreateDecryptor(), CryptoStreamMode.Write);


            cs.Write(cipherData, 0, cipherData.Length);
            cs.Close();

            byte[] decryptedData = ms.ToArray();

            return decryptedData;
        }

        /// <summary>
        /// 복호화

        /// </summary>
        /// <param name="InputText"></param>
        /// <returns></returns>
        public static string DecryptString(string InputText)
        {
            if (InputText.Length == 0)
                return "";
            string DecryptedData = "";
            try
            {
                byte[] cipherBytes = Convert.FromBase64String(InputText);

                PasswordDeriveBytes pdb = new PasswordDeriveBytes(passkey,
                    new byte[] { 0x49, 0x76, 0x61, 0x6e, 0x20, 0x4d, 0x65, 0x64, 0x76, 0x65, 0x64, 0x65, 0x76 });

                byte[] decryptedData = Decrypt(cipherBytes, pdb.GetBytes(32), pdb.GetBytes(16));

                DecryptedData = System.Text.Encoding.Unicode.GetString(decryptedData); 
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return DecryptedData;
        }
        /// <summary>
        /// MD5 암호화

        /// </summary>
        /// <param name="Data"></param>
        /// <returns></returns>
        public static string MD5Hash(string Data)
        {

            if (Data.Length == 0)
                return "";
            MD5 md5 = new MD5CryptoServiceProvider();
            byte[] hash = md5.ComputeHash(Encoding.ASCII.GetBytes(Data));

            StringBuilder stringBuilder = new StringBuilder();
            foreach (byte b in hash)
            {
                stringBuilder.AppendFormat("{0:x2}", b);
            }
            return stringBuilder.ToString();
        }
        #endregion

        #region drag&drop

        private struct IconInfo
        {
            public bool fIcon;
            public int xHotspot;
            public int yHotspot;
            public IntPtr hbmMask;
            public IntPtr hbmColor;
        }
        [DllImport("user32.dll")]
        private static extern IntPtr CreateIconIndirect(
            ref IconInfo icon);

        [DllImport("user32.dll")]
        [return: MarshalAs(UnmanagedType.Bool)]
        private static extern bool GetIconInfo(IntPtr hIcon,
            ref IconInfo pIconInfo);

        public static Cursor CreateCursor(string str)
        {
            System.Drawing.SizeF size;
            System.Drawing.Font f = new System.Drawing.Font(System.Drawing.FontFamily.GenericSansSerif,
              10, System.Drawing.FontStyle.Bold);
            using (System.Drawing.Bitmap tmpBmp = new System.Drawing.Bitmap(1, 1))
            using (System.Drawing.Graphics g = System.Drawing.Graphics.FromImage(tmpBmp))
                size = g.MeasureString(str, f);

            System.Drawing.Bitmap bitmap = new System.Drawing.Bitmap((int)Math.Ceiling(size.Width),
              (int)Math.Ceiling(size.Height));
            using (System.Drawing.Graphics g = System.Drawing.Graphics.FromImage(bitmap))
                g.DrawString(str, f, System.Drawing.Brushes.Black, 0, 0);

            // Cursor.Current = CreateCursor(bitmap, 0, 0);
            IconInfo tmp = new IconInfo();
            GetIconInfo(bitmap.GetHicon(), ref tmp);
            tmp.xHotspot = 0;
            tmp.yHotspot = 0;
            tmp.fIcon = false;
            Cursor cursor = new Cursor(CreateIconIndirect(ref tmp));

            bitmap.Dispose();
            f.Dispose();
            return cursor;
        }
        #endregion


        #endregion

        #region License
        static string bLicense = "";
        public static bool LicenseChek()
        {
            if (bLicense != "")
                return (bLicense == "T" ? true : false);
            try
            {
                // Data Source=210.182.240.136  HOST=210.182.240.136
                Configuration appConfig = ConfigurationManager.OpenExeConfiguration(ConfigurationUserLevel.None);
                string conStr = appConfig.ConnectionStrings.ConnectionStrings["ConnectionString"].ConnectionString;
                if (appConfig.AppSettings.Settings["ENCRYTION"].Value == "YES")
                {
                    conStr = SAMMI.Common.DecryptString(conStr);
                }
                conStr = conStr.ToUpper();
                int pos = conStr.IndexOf("DATA SOURCE");
                if (pos == -1)
                    pos = conStr.IndexOf("HOST");

                if (pos == -1)
                {
                    bLicense = "F";
                    return false;
                }
                string val = "";
                int cnt = 0;
                while (pos < conStr.Length)
                {
                    string ch = conStr.Substring(pos, 1);
                    if (ch == "." || (ch.CompareTo("0") >= 0 && ch.CompareTo("9") <= 0))
                    {
                        val += ch;
                        if (ch == ".")
                            ++cnt;
                    }
                    else
                    {
                        if (cnt == 3)
                            break;
                    }
                    ++pos;


                }
                string enk = SAMMI.Common.passkey;
                SAMMI.Common.passkey = "sammicomputerpk";
                conStr = SAMMI.Common.EncryptString(val);
                SAMMI.Common.passkey = enk;

                try
                {
                    string License = appConfig.AppSettings.Settings["SMCLicense1"].Value;
                    if (conStr == License)
                    {
                        bLicense = "T";
                        return true;
                    }
                    License = appConfig.AppSettings.Settings["SMCLicense2"].Value;
                    if (conStr == License)
                    {
                        bLicense = "T";
                        return true;
                    }
                    License = appConfig.AppSettings.Settings["SMCLicense3"].Value;
                    if (conStr == License)
                    {
                        bLicense = "T";
                        return true;
                    }
                    License = appConfig.AppSettings.Settings["SMCLicense4"].Value;
                    if (conStr == License)
                    {
                        bLicense = "T";
                        return true;
                    }
                    License = appConfig.AppSettings.Settings["SMCLicense5"].Value;
                    if (conStr == License)
                    {
                        bLicense = "T";
                        return true;
                    }
                }
                catch { }
                bLicense = "F";
                return false;
            }
            catch { }
            bLicense = "";
            return true;
        }

        public static DataTable dtPlantAuth = null;
        static bool bPlantAuthALL = true;
        public void SetPlantAuth()
        {
            if (dtPlantAuth == null)
            {
                DBHelper helper = new DBHelper(true);
                dtPlantAuth = helper.FillTable("SELECT PlantCode FROM TSY0301 where WorkerID='" + SAMMI.LoginInfo.UserID + "'");
            }
            bPlantAuthALL = true;
            if (rtnDtTemp.Rows.Count == dtPlantAuth.Rows.Count)
                return ;

            for (int i = rtnDtTemp.Rows.Count - 1; 0 <= i; i--)
            {
                bool bok = false;
                foreach (DataRow dr in dtPlantAuth.Rows)
                {
                    if (rtnDtTemp.Rows[i]["CODE_ID"].ToString() == dr["PlantCode"].ToString())
                    {
                        bok = true;
                        break;
                    }
                }
                if (bok == false)
                    rtnDtTemp.Rows.RemoveAt(i);

            }
            if (rtnDtTemp.Rows.Count < 2)
               bPlantAuthALL = false;
        }
    #endregion

        #region [정규식으로 숫자만/문자만/특수문자만 확인]
        public int Regex_Numer(string pwd1)
        {
            string NumberPwd = Regex.Replace(pwd1, @"[^0-9]", "");
            int number = DBHelper.nvlInt(NumberPwd.Length); // 숫자만
            return number;

        }

        public int Regex_String(string pwd1)
        {
            string StringPwd = Regex.Replace(pwd1, @"[^a-zA-Z]", "");
            int String = DBHelper.nvlInt(StringPwd.Length); // 문자만
            return String;

        }

        public int Regex_SpcString(string pwd1)
        {
            string SpcStringPwd = Regex.Replace(pwd1, @"[^\W]", "");
            int SpcString = DBHelper.nvlInt(SpcStringPwd.Length); // 특수문자만
            return SpcString;

        }
        #endregion

    }

    #region 바코드 출력관련 클래스

    public class RawPrinterHelper
    {
        // Structure and API declarions:
        [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Ansi)]
        public class DOCINFOA
        {
            [MarshalAs(UnmanagedType.LPStr)]
            public string pDocName;
            [MarshalAs(UnmanagedType.LPStr)]
            public string pOutputFile;
            [MarshalAs(UnmanagedType.LPStr)]
            public string pDataType;
        }
        [DllImport("winspool.Drv", EntryPoint = "OpenPrinterA", SetLastError = true, CharSet = CharSet.Ansi, ExactSpelling = true, CallingConvention = CallingConvention.StdCall)]
        public static extern bool OpenPrinter([MarshalAs(UnmanagedType.LPStr)] string szPrinter, out IntPtr hPrinter, IntPtr pd);

        [DllImport("winspool.Drv", EntryPoint = "ClosePrinter", SetLastError = true, ExactSpelling = true, CallingConvention = CallingConvention.StdCall)]
        public static extern bool ClosePrinter(IntPtr hPrinter);

        [DllImport("winspool.Drv", EntryPoint = "StartDocPrinterA", SetLastError = true, CharSet = CharSet.Ansi, ExactSpelling = true, CallingConvention = CallingConvention.StdCall)]
        public static extern bool StartDocPrinter(IntPtr hPrinter, Int32 level, [In, MarshalAs(UnmanagedType.LPStruct)] DOCINFOA di);

        [DllImport("winspool.Drv", EntryPoint = "EndDocPrinter", SetLastError = true, ExactSpelling = true, CallingConvention = CallingConvention.StdCall)]
        public static extern bool EndDocPrinter(IntPtr hPrinter);

        [DllImport("winspool.Drv", EntryPoint = "StartPagePrinter", SetLastError = true, ExactSpelling = true, CallingConvention = CallingConvention.StdCall)]
        public static extern bool StartPagePrinter(IntPtr hPrinter);

        [DllImport("winspool.Drv", EntryPoint = "EndPagePrinter", SetLastError = true, ExactSpelling = true, CallingConvention = CallingConvention.StdCall)]
        public static extern bool EndPagePrinter(IntPtr hPrinter);

        [DllImport("winspool.Drv", EntryPoint = "WritePrinter", SetLastError = true, ExactSpelling = true, CallingConvention = CallingConvention.StdCall)]
        public static extern bool WritePrinter(IntPtr hPrinter, IntPtr pBytes, Int32 dwCount, out Int32 dwWritten);

        // SendBytesToPrinter()
        // When the function is given a printer name and an unmanaged array
        // of bytes, the function sends those bytes to the print queue.
        // Returns true on success, false on failure.
        public static bool SendBytesToPrinter(string szPrinterName, IntPtr pBytes, Int32 dwCount)
        {
            Int32 dwError = 0, dwWritten = 0;
            IntPtr hPrinter = new IntPtr(0);
            DOCINFOA di = new DOCINFOA();
            bool bSuccess = false; // Assume failure unless you specifically succeed.

            di.pDocName = "My C#.NET RAW Document";
            di.pDataType = "RAW";

            // Open the printer.
            if (OpenPrinter(szPrinterName.Normalize(), out hPrinter, IntPtr.Zero))
            {
                // Start a document.
                if (StartDocPrinter(hPrinter, 1, di))
                {
                    // Start a page.
                    if (StartPagePrinter(hPrinter))
                    {
                        // Write your bytes.
                        bSuccess = WritePrinter(hPrinter, pBytes, dwCount, out dwWritten);
                        EndPagePrinter(hPrinter);
                    }
                    EndDocPrinter(hPrinter);
                }
                ClosePrinter(hPrinter);
            }
            // If you did not succeed, GetLastError may give more information
            // about why not.
            if (bSuccess == false)
            {
                dwError = Marshal.GetLastWin32Error();
            }
            return bSuccess;
        }

        public static bool SendFileToPrinter(string szPrinterName, string szFileName)
        {
            // Open the file.
            FileStream fs = new FileStream(szFileName, FileMode.Open);
            // Create a BinaryReader on the file.
            BinaryReader br = new BinaryReader(fs);
            // Dim an array of bytes big enough to hold the file's contents.
            Byte[] bytes = new Byte[fs.Length];
            bool bSuccess = false;
            // Your unmanaged pointer.
            IntPtr pUnmanagedBytes = new IntPtr(0);
            int nLength;

            nLength = Convert.ToInt32(fs.Length);
            // Read the contents of the file into the array.
            bytes = br.ReadBytes(nLength);
            // Allocate some unmanaged memory for those bytes.
            pUnmanagedBytes = Marshal.AllocCoTaskMem(nLength);
            // Copy the managed byte array into the unmanaged array.
            Marshal.Copy(bytes, 0, pUnmanagedBytes, nLength);
            // Send the unmanaged bytes to the printer.
            bSuccess = SendBytesToPrinter(szPrinterName, pUnmanagedBytes, nLength);
            // Free the unmanaged memory that you allocated earlier.
            Marshal.FreeCoTaskMem(pUnmanagedBytes);
            return bSuccess;
        }

        public static bool SendStringToBytePrinter(string szPrinterName, string szString)
        {
            Int32 dwCount;
            // How many characters are in the string?
            dwCount = szString.Length;
            // Assume that the printer is expecting ANSI text, and then convert
            // the string to ANSI text.
            //pBytes = Marshal.StringToCoTaskMemAnsi(szString);

            Byte[] bytes = Encoding.Default.GetBytes(szString);

            bool bSuccess = false;
            // Your unmanaged pointer.
            IntPtr pUnmanagedBytes = new IntPtr(0);
            int nLength;

            nLength = Convert.ToInt32(bytes.Length);
            // Allocate some unmanaged memory for those bytes.
            pUnmanagedBytes = Marshal.AllocCoTaskMem(nLength);
            // Copy the managed byte array into the unmanaged array.
            Marshal.Copy(bytes, 0, pUnmanagedBytes, nLength);
            // Send the unmanaged bytes to the printer.
            bSuccess = SendBytesToPrinter(szPrinterName, pUnmanagedBytes, nLength);
            // Free the unmanaged memory that you allocated earlier.
            Marshal.FreeCoTaskMem(pUnmanagedBytes);
            return bSuccess;
        }

        public static bool SendStringToPrinter(string szPrinterName, string szString)
        {
            IntPtr pBytes;
            Int32 dwCount;
            // How many characters are in the string?
            dwCount = szString.Length;
            // Assume that the printer is expecting ANSI text, and then convert
            // the string to ANSI text.
            pBytes = Marshal.StringToCoTaskMemAnsi(szString);

            // Send the converted ANSI string to the printer.
            SendBytesToPrinter(szPrinterName, pBytes, dwCount);
            Marshal.FreeCoTaskMem(pBytes);
            return true;
        }
    }
    #endregion
}
