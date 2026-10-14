using System;
using System.Collections.Generic;
using System.Text;
using System.Collections;
using System.Configuration;
using System.Data.SqlClient;
using System.Net;
using System.Data;
using System.Net.NetworkInformation;
using System.Windows.Forms;
using System.Management;
using System.Diagnostics;
using System.IO;

using System.Runtime.InteropServices;
using SAMMI;

namespace SmartDas
{
    #region 공통 모듈

    public class OrderInfo
    {
        public OrderInfo(string orderNo, double orderQty, string unitCode, string itemCode, string itemName, string lotNo = "0")
        {
            this.OrderNo = orderNo;
            this.OrderQty = orderQty;
            this.UnitCode = unitCode;
            this.ItemCode = itemCode;
            this.ItemName = itemName;
            this.LotNo = lotNo;
        }

        public string OrderNo { get; set; }
        public double OrderQty { get; set; }
        public string UnitCode { get; set; }
        public string ItemCode { get; set; }
        public string ItemName { get; set; }
        public string LotNo { get; set; }
        public string CastingType { get; set; }
    }

    public static class Common
    {
        public static string gsIP;
        private const string WMI_QUERY = "SELECT * FROM Win32_NetworkAdapterConfiguration WHERE IPEnabled='True'";

        public enum ListWorkerType { SELECT, PROD, MACH, OUT }

        // <OrderNo, OrderInfo>
        public static Dictionary<string, OrderInfo> OrderTable { get; set; }

        public static DataTable F_OrderToTable(Dictionary<string, OrderInfo> dict)
        {
            DataTable table = new DataTable();

            table.Columns.Add("OrderNo", typeof(string));
            table.Columns.Add("ItemCode", typeof(string));
            table.Columns.Add("ItemName", typeof(string));
            table.Columns.Add("OrderQty", typeof(double));

            foreach (KeyValuePair<string, OrderInfo> pair in dict)
            {
                DataRow row = table.NewRow();

                row["OrderNo"] = pair.Value.OrderNo;
                row["OrderQty"] = pair.Value.OrderQty;
                row["ItemCode"] = pair.Value.ItemCode;
                row["ItemName"] = pair.Value.ItemName;

                table.Rows.Add(row);
            }
            return table;
        }

        public static DataTable OrderToDataTable
        {
            get
            {
                DataTable table = new DataTable();

                table.Columns.Add("OrderNo", typeof(string));
                table.Columns.Add("ItemCode", typeof(string));
                table.Columns.Add("ItemName", typeof(string));
                table.Columns.Add("OrderQty", typeof(double));

                foreach (KeyValuePair<string, OrderInfo> pair in OrderTable)
                {
                    DataRow row = table.NewRow();

                    row["OrderNo"] = pair.Value.OrderNo;
                    row["OrderQty"] = pair.Value.OrderQty;
                    row["ItemCode"] = pair.Value.ItemCode;
                    row["ItemName"] = pair.Value.ItemName;

                    table.Rows.Add(row);
                }
                return table;
            }
            set
            {
                DataTable dt = value;

                if (dt != null)
                {
                    OrderTable.Clear();

                    for (int i = 0; i < dt.Rows.Count; i++)
                    {
                        OrderTable.Add(dt.Rows[i]["OrderNo"].ToString(),
                            new OrderInfo(
                                dt.Rows[i]["OrderNo"].ToString(),
                                Convert.ToDouble(dt.Rows[i]["OrderQty"]),
                                dt.Rows[i]["UnitCode"].ToString(),
                                dt.Rows[i]["ItemCode"].ToString(),
                                dt.Rows[i]["ItemName"].ToString()));

                        if (!string.IsNullOrEmpty(dt.Rows[i]["CastingType"].ToString()))
                        {
                            OrderTable[dt.Rows[i]["OrderNo"].ToString()].CastingType
                                = dt.Rows[i]["CastingType"].ToString();
                        }
                    }
                }

            }
        }

        public static bool IsOrderSelected
        {
            get
            {
                if (OrderTable != null && OrderTable.Count > 0)
                    return true;

                return false;
            }
        }
        

        public static bool gbInMotonicIP = false;
        public static string gsWorkCenterCode;
        public static string gsWorkCenterName;
        public static string gRecDate;
        public static string gDayNight;
        public static double dOverRate;
        public static string sPrintValue;
        public static long giReceived;

        private static Hashtable hashMessage = new Hashtable();
        //public static DASMain dasMain = null;

        //2018 05 02 HJH 오류떠서 추가해놓음(기존 DASMain(SKCPAD)에서 사용했던 코드로 보임
        public static DA0000 dasMain = null;
        public static string LineMsg;
        public static string PrinterName = "ZT421";

        public const string defaultPlantCode = "100";
        //private static string getQty;

        static Common()
        {
            OrderTable = new Dictionary<string, OrderInfo>();
        }

        public static string GetComputerName()
        {
            return SystemInformation.ComputerName;
        }

        public static void RollBackTran(SqlTransaction ot)
        {
            if (ot != null)
            {
                ot.Rollback();

                if (ot.Connection != null)
                {
                    if (ot.Connection.State != System.Data.ConnectionState.Closed)
                    {
                        ot.Connection.Close();
                    }
                }
            }
        }

        public static void GetKeyboard()
        {
            string oskPath = System.Environment.SystemDirectory + @"\\osk.exe";

            if (System.IO.File.Exists(oskPath))
            {
                ProcessStartInfo info = new ProcessStartInfo(oskPath);
                info.UseShellExecute = true; info.Verb = "runas";
                Process.Start(info);
                // System.Diagnostics.Process.Start((oskPath);
            }
        }

        [DllImport("psapi")]
        public static extern int EmptyWorkingSet(IntPtr handle);
        public static void CleanProcess(String processName)
        {
            Process[] process = Process.GetProcessesByName(processName);

            if (process.Length == 1)
            {
                EmptyWorkingSet(process[0].Handle);
            }
        }

        private static int CheckNetwork()
        {
            try
            {
                int iReturn = 0;
                //uint iLinkQuality = 0;

                foreach (NetworkInterface ni in NetworkInterface.GetAllNetworkInterfaces())
                {
                    if (iReturn != 0)
                        break;

                    switch (ni.NetworkInterfaceType)
                    {
                        case NetworkInterfaceType.Wireless80211:
                        case NetworkInterfaceType.Isdn:
                        case NetworkInterfaceType.Ethernet:
                            if (ni.OperationalStatus == OperationalStatus.Up)
                            {
                                iReturn = 1;
                            }
                            break;
                    }
                }

                if (iReturn == 1)
                {
                    clsDB.bUseNetwork = true;
                }
                return iReturn;
            }
            catch (SqlException ex)
            {
                switch (ex.Number)
                {
                    case 3135:
                        break;
                    case 12543:
                        break;
                    default:
                        break;
                }

                return 0;
            }
        }

        public static void SendSMS(string sMsg)
        {
            //da0000.SendSMS(sMsg);

            LogFile.WriteLog(sMsg);
        }

        public static void SetMessageList()
        {
            //테이블 미사용으로 인한 주석처리(2022.04.25 김기연)
            //hashMessage.Clear();
            //DBHelper helper = new DBHelper(false);
            //DataTable dt = new DataTable();

            //try
            //{
            //    string sSQL = "";
            //    sSQL = "select MessageID, MessageDesc FROM TBM4000 where UseFlag = 'Y'  ";
            //    dt = helper.FillTable(sSQL, CommandType.Text);
            //    foreach (DataRow dr in dt.Rows)
            //    {
            //        hashMessage.Add(clsDB.nvlString(dr["MessageID"]), clsDB.nvlString(dr["MessageDesc"]));
            //    }

            //}
            //catch (Exception)
            //{
            //}
            //finally
            //{
            //    helper.Close();
            //}
        }

        public static string GetMessage(string mes)
        {
            string[] sArr = mes.Split(':');
            if (sArr.Length == 2 && sArr[0] == "C")
            {
                if (hashMessage[sArr[1]] != null)
                {
                    return clsDB.nvlString(hashMessage[sArr[1]]);
                }
                else
                {
                    return "(" + mes + ") 를 등록하세요.";
                }
            }
            else
            {
                return clsDB.nvlString(mes);
            }
        }

        public static string getLangText(string cText)
        {
            return getLangText(cText, "");
        }

        public static DataTable langTable = null;

        public static string getLangText(string cText, string cOp)
        {
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
        }

        public static string GetIPAddress()
        {
            string sIPAddress = string.Empty;
            ObjectQuery oQry = new ObjectQuery(WMI_QUERY);
            ManagementObjectSearcher oSearcher = new ManagementObjectSearcher(oQry);
            try
            {
                foreach (ManagementObject obj in oSearcher.Get())
                {
                    if (obj["Description"].ToString().ToUpper().IndexOf("VIRTUAL") >= 0) continue;
                    sIPAddress = ((string[])obj["IPAddress"])[0];
                    break;
                }
            }
            catch (System.Exception ex)
            {
                LogFile.WriteLog("Common.GetIPAddress => " + ex.Message);
                sIPAddress = "ERROR";
                //sIPAddress = ex.Message;
            }
            return sIPAddress;
        }

        /// <summary>
        /// 날짜/시간 문자열을 DateTime 구조체에 넣을수 있는지 검사
        /// </summary>
        public static bool IsDateTime(string txtDate)
        {
            DateTime tempDate;
            return DateTime.TryParse(txtDate, out tempDate);
        }

        /// <summary>
        /// 문자열을 int로 변환 가능한지 검사
        /// </summary>
        public static bool isStr2Int(string txtData)
        {
            int intData;
            return int.TryParse(txtData, out intData);
        }

        public static bool isStr2Int(string txtData, out int data)
        {
            return int.TryParse(txtData, out data);
        }

        /// <summary>
        /// 문자열된 숫자에 콤마 처리
        /// </summary>
        /// <param name="sValue"></param>
        /// <returns></returns>
        public static string StrFormatInteger(string sValue, string format = "{0:#,##0}")
        {
            int iTmp;

            sValue = sValue.Replace(",", "");

            if (int.TryParse(sValue, out iTmp))
            {
                return string.Format(format, iTmp);
            }
            else
            {
                return "0";
            }
        }

        /// <summary>
        /// 문자열로된 실수데이터에 콤마 및 소수점 3자리 반올림 처리
        /// </summary>
        /// <param name="sValue"></param>
        /// <returns></returns>
        public static string StrFormatDouble(string sValue, string format = "{0:#,##0.000}")
        {
            double dTmp;

            sValue = sValue.Replace(",", "");

            if (double.TryParse(sValue, out dTmp))
            {
                return string.Format(format, dTmp);
            }
            else
            {
                return string.Format(format, dTmp);
            }
        }



        //날짜 정보 생성
        public static DateTime makeDateTime(DateTime pDate, string pTime)
        {
            DateTime dtReturn; //반환될 신규 일자 및 시간
            string[] sTime; //시간, 분 저장배열
            int iHour; //신규 시간
            int iMin; //신규 분
            int iSec = 0; //신규 초 (미관리)

            //시간정보 공백 처리
            pTime = string.IsNullOrEmpty(pTime) ? ":" : pTime;
            //시간, 분 분할처리
            sTime = pTime.Split(':');
            //시간정보 변환
            if (!int.TryParse(sTime[0], out iHour))
                iHour = 0;
            //분 정보 변환
            if (!int.TryParse(sTime[1], out iMin))
                iMin = 0;

            //초 정보 변환
            if (sTime.Length == 3)
            {
                if (!int.TryParse(sTime[2], out iSec))
                    iSec = 0;
            }

            //전달된 일자 및 시간 정보 작성
            dtReturn = new DateTime(pDate.Year, pDate.Month, pDate.Day, iHour, iMin, iSec);
            return dtReturn;
        }
        //날짜 양식 변환
        public static string dateFormat(string pInOut, string pDate)
        {
            //DB에 등록시 -문자 제거
            if (pInOut.Equals("I"))
                return pDate.Replace("-", "");
            //DB에서 조회시 -문자 추가
            else if (pInOut.Equals("O"))
                return pDate.Substring(0, 4) + "-" + pDate.Substring(4, 2) + "-" + pDate.Substring(6, 2);
            //그외 변경 없음
            else
                return pDate;
        }

        public static string getConfig(string Key)
        {
            //config open
            Configuration appConfig = ConfigurationManager.OpenExeConfiguration(ConfigurationUserLevel.None);

            //Return Value
            return appConfig.AppSettings.Settings[Key].Value.ToString();
        }

        public static void setConfig()
        {
            //config open
            Configuration appConfig = ConfigurationManager.OpenExeConfiguration(ConfigurationUserLevel.None);

            //WMS 전송시 주소양식 조회
            WMS_IF_URL = appConfig.AppSettings.Settings["WMSIFURL"].Value.ToString();
            //IF 진행시 IFKey 첫문자 지정
            SeqType = appConfig.AppSettings.Settings["SEQTYPE"].Value.ToString();
        }

        //깨끗한 나라 IP별 설비정보 조회
        public static void machSetting()
        {
            DBHelper helper = new DBHelper(false);
            DataTable dtRtn;
            string sIPAddr = string.Empty;

            try
            {
                string conStr = helper.DBConnect.ConnectionString;

                // DB 서버 아이피 가 운영인지 개발서버 인지 확인
                if (conStr.Contains("10.2.14.194"))
                {
                    bDBRealServer = true;   // 운영서버인경우
                }
                else
                {
                    bDBRealServer = false;  // 개발서버인경우
                    Common.ProgVersion = Common.ProgVersion.Replace("Ver", "DBG"); 
                }

                sIPAddr = GetIPAddress();
                dtRtn = helper.FillTable("SP_POP00_S01", CommandType.StoredProcedure
                                                                    , helper.CreateParameter("p_IPADDRESS", sIPAddr, DbType.String, ParameterDirection.Input));
                if (dtRtn.Rows.Count == 1)
                {
                    PlantCode = dtRtn.Rows[0]["WERKS"].ToString();
                    OpCode = dtRtn.Rows[0]["PROC_CD"].ToString();
                    IOType = dtRtn.Rows[0]["WRK_POT"].ToString();
                    MachineCode = dtRtn.Rows[0]["MACH_CD"].ToString();
                    MachineName = dtRtn.Rows[0]["MACH_NM"].ToString();
                    WorkCenterCode = dtRtn.Rows[0]["WRK_CD"].ToString();
                    MachineNo = dtRtn.Rows[0]["MACHINE"].ToString();        // 22-05-21 설비호기 추가, PS 공정투입에 사용하기 위해서
                    //설비에 투입된 작업자 조회시 사용자정보(USRMA)에 등록되지 않은 경우 작업자정보 미설정
                    if (!string.IsNullOrEmpty(dtRtn.Rows[0]["NMLAST"].ToString()))
                    {
                        UserID = dtRtn.Rows[0]["EMPLY_NO"].ToString();
                        UserName = dtRtn.Rows[0]["NMLAST"].ToString();
                        WorkCrewName = dtRtn.Rows[0]["WRK_INFO"].ToString();

                        WorkClass = dtRtn.Rows[0]["WRK_CLASS"].ToString();   // 작업반
                        WorkShift = dtRtn.Rows[0]["WRK_SHIFT"].ToString();   // 작업조
                    }
                    else
                    {
                        // 사용자 정보가 없는경우 초기값
                        UserID = "";
                        //UserName = "";
                        //WorkCrewName = "";
                        WorkCrewName = "작업조";
                        UserName = "작업자";

                        WorkClass = "";   // 작업반
                        WorkShift = "";   // 작업조
                    }

                    LogFile.WriteLog(string.Format("설비정보 [{0}, {1}, {2}, {3}]", PlantCode, OpCode, MachineCode, MachineName), LogType.PROC);
                }

                setConfig();
            }
            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                helper.Close();
            }
        }
        //깨끗한 나라 LOT_NO 실적일자 변경시 수정처리
        public static void dailyLotChange()
        {
            DBHelper helper = new DBHelper(false, "", true);

            if (!clsDB.bUseNetwork)
                return;

            try
            {
                //설비별 LOT_NO 확인
                helper.ExecuteNoneQuery("SP_SET_LOT_NO", CommandType.StoredProcedure
                                                                  , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)
                                                                  , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)
                                                                  , helper.CreateParameter("P_IOTYPE", Common.IOType, DbType.String, ParameterDirection.Input));
                if (helper.RSCODE.Equals("S"))
                {
                    helper.Commit();
                    //LogFile.WriteLog("LOT CHECK (WERKS : " + Common.PlantCode + " / MACH_CD : " + Common.MachineCode + " / IOType : " + Common.IOType + ")", LogType.PROC);
                }
                else
                    helper.Rollback();
            }
            catch (Exception ex)
            {
                LogFile.WriteLog(ex.ToString());
            }
            finally
            {
                helper.Close();
            }
        }

        public static string toJsonFormat(string Proc_CD, DataTable dtDataList)
        {
            string sJsonRtn = string.Empty;

            //시작처리 및 프로시저 정보
            sJsonRtn = "{\"PROC_CD\": \"" + Proc_CD + "\",\"list\": [";
            //테이블 정보 변환
            //행단위 반복
            for (int i = 0; i < dtDataList.Rows.Count; i++)
            {
                //Row 시작
                //두번째부터 구분자 ,추가
                if (i > 0)
                    sJsonRtn = sJsonRtn + ",";
                sJsonRtn = sJsonRtn + "{\"map\": {";
                //열단위 정보 입력
                for (int j = 0; j < dtDataList.Columns.Count; j++)
                {
                    //두번째부터 구분자 ,추가
                    if (j > 0)
                        sJsonRtn = sJsonRtn + ",";
                    //각 셀의 정보를 JSON으로 변환
                    sJsonRtn = sJsonRtn + "\"" + dtDataList.Columns[j].ColumnName.ToString().Replace("\"", "`") + "\":\"" + dtDataList.Rows[i][j].ToString().Replace("\"", "`") + "\"";
                }
                //Row 완료
                sJsonRtn = sJsonRtn + "}}";
            }
            //완료처리
            sJsonRtn = sJsonRtn + "]}";
            return sJsonRtn;
        }

        public static string toJsonFormat_List(string pTitle, DataTable dtDataList)
        {
            string sJsonRtn = string.Empty;

            //시작처리 및 프로시저 정보
            sJsonRtn = "{\"" + pTitle + "\": [";
            //테이블 정보 변환
            //행단위 반복
            for (int i = 0; i < dtDataList.Rows.Count; i++)
            {
                //Row 시작
                //두번째부터 구분자 ,추가
                if (i > 0)
                    sJsonRtn = sJsonRtn + ",";
                sJsonRtn = sJsonRtn + "{";
                //열단위 정보 입력
                for (int j = 0; j < dtDataList.Columns.Count; j++)
                {
                    //두번째부터 구분자 ,추가
                    if (j > 0)
                        sJsonRtn = sJsonRtn + ",";
                    //각 셀의 정보를 JSON으로 변환
                    sJsonRtn = sJsonRtn + "\"" + dtDataList.Columns[j].ColumnName.ToString() + "\":\"" + dtDataList.Rows[i][j].ToString() + "\"";
                }
                //Row 완료
                sJsonRtn = sJsonRtn + "}";
            }
            //완료처리
            sJsonRtn = sJsonRtn + "]}";
            return sJsonRtn;
        }

        public static string[] toJsonFormat_Array(string pTitle, DataTable dtDataList)
        {
            string[] sasJsonRtn = new string[dtDataList.Rows.Count];
            string sJsonRtn = string.Empty;

            //테이블 정보 변환
            //행단위 반복
            for (int i = 0; i < dtDataList.Rows.Count; i++)
            {
                //Row 시작
                //시작처리 및 프로시저 정보
                sJsonRtn = "{\"" + pTitle + "\": [";
                sJsonRtn = sJsonRtn + "{";
                //열단위 정보 입력
                for (int j = 0; j < dtDataList.Columns.Count; j++)
                {
                    //두번째부터 구분자 ,추가
                    if (j > 0)
                        sJsonRtn = sJsonRtn + ",";
                    //각 셀의 정보를 JSON으로 변환
                    sJsonRtn = sJsonRtn + "\"" + dtDataList.Columns[j].ColumnName.ToString() + "\":\"" + dtDataList.Rows[i][j].ToString() + "\"";
                }
                //Row 완료
                sJsonRtn = sJsonRtn + "}]}";
                sasJsonRtn[i] = sJsonRtn;
            }
            return sasJsonRtn;
        }

        public static string GetRecDate(DateTime dEndDateTime)
        {
            //네트워크 비정상시 미사용
            if (!clsDB.bUseNetwork)
                return string.Empty;

            DBHelper helper = new DBHelper(true);
            string rtnRecDate = string.Empty;

            string sDateTime = "TO_DATE('" + dEndDateTime.ToString("yyyy-MM-dd HH:mm:ss") + "', 'yyyy-MM-dd HH24:mi:ss')";

            try
            {

                string sSQL = "";
                sSQL += "Select FN_RECDATE(" + sDateTime + ") as RECDATE ";
                sSQL += "FROM dual";

                DataSet ds = helper.FillDataSet(sSQL, CommandType.Text);

                if (ds.Tables[0].Rows.Count == 1)
                    rtnRecDate = ds.Tables[0].Rows[0]["RECDATE"].ToString();
                else
                    rtnRecDate = string.Empty;
            }
            catch (Exception ex)
            {
                // throw ex;
                LogFile.WriteLog(ex.ToString());
            }
            finally
            {
                helper.Close();
            }
            return rtnRecDate;

        }

        public static int GetChangeUnit(string Rate, double Qty)
        {
            string[] saTemp;
            int iMul; //분자
            int iDiv; //분모
            double dCalc;
            int iRtn; //결과값 

            saTemp = Rate.Split(',');
            if (!int.TryParse(saTemp[0], out iMul))
                iMul = 0;
            if (!int.TryParse(saTemp[1], out iDiv))
                iDiv = 1; //0일 경우 0으로 나누기 에러 발생
            //계산 시작
            dCalc = Qty * iMul;
            dCalc = dCalc / iDiv;
            //소수점(완료되지 못한 단위)의 경우 올림처리
            iRtn = (int)Math.Ceiling(dCalc);
            return iRtn;
        }

        public static string GetRestToString(string pURL, string pPram, string pType)
        {
            //요청정보
            string requestURL = pURL;
            byte[] sendData = UTF8Encoding.UTF8.GetBytes(pPram);
            //수신
            string data;

            if (pType.Equals("POST"))
            {
                //요청 객체 생성
                HttpWebRequest request = (HttpWebRequest)WebRequest.Create(requestURL);
                //request.ContentType = "application/x-www-form-urlencoded; charset=UTF-8";
                request.ContentType = "text/json";
                request.Method = "POST";
                request.ContentLength = sendData.Length;
                request.Timeout = 300000; //300s
                //데이터 요청
                LogFile.WriteLog("Restful Start (URL : " + pURL + " / Pram : " + pPram + ")", LogType.PROC);
                Stream requestStream = request.GetRequestStream();
                requestStream.Write(sendData, 0, sendData.Length);
                requestStream.Close();
                LogFile.WriteLog("Restful Send (URL : " + pURL + " / Pram : " + pPram + ")", LogType.PROC);
                //수신
                HttpWebResponse response = (HttpWebResponse)request.GetResponse();
                LogFile.WriteLog("Restful Receive(URL : " + pURL + " / Pram : " + pPram + ")", LogType.PROC);
                StreamReader streamReader = new StreamReader(response.GetResponseStream(), Encoding.GetEncoding("UTF-8"));
                data = streamReader.ReadToEnd();
                LogFile.WriteLog("Restful End(URL : " + pURL + " / Pram : " + data + ")", LogType.PROC);
                streamReader.Close();
                response.Close();
                return data;
            }
            else if (pType.Equals("GET"))
            {
                //요청 객체 생성
                HttpWebRequest request = (HttpWebRequest)WebRequest.Create(requestURL);
                request.Method = "GET";
                request.ContentType = "application/json";

                HttpWebResponse response = (HttpWebResponse)request.GetResponse(); //응답 수신
                Stream stream = response.GetResponseStream(); //stream으로 저장
                StreamReader reader = new StreamReader(stream); //데이터 처리
                data = reader.ReadToEnd();//수신 데이터 문자열로 저장

                return data;
            }
            else
                return "GET/POST를 확인하여 주시기 바랍니다.";
        }

        public static string GetWMSIFKEY()
        {
            DBHelper helper = new DBHelper(true);
            string rtnRecDate;

            try
            {
                string sSQL = "";
                sSQL += "SELECT LTRIM(RTRIM(TO_CHAR(SEQ_GET_IFR_KEY.NEXTVAL, '00000000000000000000000000000'))) FROM DUAL";

                // 개발 테스트 할때 I_IF_KEY 의 첫번째 문자 'M' -> 'T'로 변경 하여 보내서 KEY 중복을 회피하기 위해서 사용, 운영서버는 M 을 사용 함.
                // 'M0000000000000000000000010000' -> 'T0000000000000000000000010000'
                String sSeqType = string.IsNullOrEmpty(Common.SeqType) ? "M" : Common.SeqType;

                // 230106 김병무 : sSeqType 추가
                String sIF_Key = sSeqType + helper.ExecuteScalar(sSQL).ToString();
                rtnRecDate = sIF_Key;
            }
            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                helper.Close();
            }
            return rtnRecDate;
        }
        //깨끗한 나라 WMS 전송결과 저장
        public static string GetRestSaveResult(string IFID, string JsonData, string DocNo, string DocSeq, string rtnCD, string rtnMSG)
        {
            DBHelper helper = new DBHelper(true);
            DBHelper helper2 = new DBHelper(true);

            DataTable dtRtnTemp;
            string sProcedure;
            string sIF_Key;
            string[] sResultList;
            string sResultData;
            string sSQL = "";

            if (IFID.Equals("MES_IF_402"))
                sProcedure = "SP_IF_PUT_IFSWM005";
            else if(IFID.Equals("MES_IF_201") && PlantCode.Equals("P500"))
                sProcedure = "SP_IF_PUT_IFSWM003";
            else if(IFID.Equals("MES_IF_201") && !PlantCode.Equals("P500"))
                sProcedure = "SP_IF_PUT_IFSWM002";
            else if (IFID.Equals("MES_IF_400"))
                sProcedure = "SP_IF_PUT_IFSWM004";
            else
                return "N";

            //순번정보 생성

            sIF_Key = GetWMSIFKEY();

            LogFile.WriteLog("GetRestSaveResult GetWMSIFKEY : " + sIF_Key, LogType.PROC);

            try
            {
                //LOG 등록
                sSQL = "INSERT INTO TB_ITFRCVWMSLOG(IFID, JSONDATA, LOGNO, SAVEYN) VALUES('" + IFID + "','" + JsonData + "','" + sIF_Key + "','" + rtnCD + "')";
                helper.ExecuteScalar(sSQL);

                //LOG 등록
                try
                {
                    //Key:Value 단위로 분할
                    sResultList = rtnMSG.Replace("\"", "").Split(',');
                    //Result의 결과를 조회
                    sResultData = (sResultList[0].Split(':'))[1];

                    DateTime V_DATE = DateTime.Now;
                    sSQL = string.Format("INSERT INTO TB_ITFMESLOG (SEQNO, IFID, COMSTAT, ERRTXT, CREDAT, CRETIM, CDATE, CREUSR) VALUES('{0}', '{1}', '{2}', '{3}', '{4}', '{5}', TO_DATE('{6}', 'yyyy-mm-dd HH24:mi:ss'), '{7}')",
                                            sIF_Key, IFID, rtnCD, sResultData, V_DATE.ToString("yyyyMMdd"), V_DATE.ToString("HHmmss"), V_DATE.ToString("yyyyMMddHHmmss"), IFID);
                    helper2.ExecuteScalar(sSQL);
                }
                catch (Exception ex)
                {
                    sResultData = "";
                }
                finally
                {
                    helper2.Close();
                }

                //기존 IF정보 수정
                dtRtnTemp = helper.FillTable(sProcedure, CommandType.StoredProcedure, false, false
                                                                  , helper.CreateParameter("P_TYPE", "SAVE", DbType.String, ParameterDirection.Input)
                                                                  , helper.CreateParameter("P_DOCNO", DocNo, DbType.String, ParameterDirection.Input)
                                                                  , helper.CreateParameter("P_DOCSEQ", DocSeq, DbType.String, ParameterDirection.Input)
                                                                  , helper.CreateParameter("P_IF_STATUS", rtnCD, DbType.String, ParameterDirection.Input)
                                                                  , helper.CreateParameter("P_IF_ERR_MESS", sResultData, DbType.String, ParameterDirection.Input)
                                                                  , helper.CreateParameter("P_IF_MES_KEY", sIF_Key, DbType.String, ParameterDirection.Input)
                                                                  , helper.CreateParameter("P_SUCCESS", DbType.String, ParameterDirection.Output, null, 30)
                                                                  );

                if (helper.Parameters["P_SUCCESS"].Value.ToString().Equals("Y"))
                {
                    return "S";
                }
                else
                {
                    return "E";
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                helper.Close();
            }

        }

        //PS 포장 인증확인
        public static string Cert_Check(string UserID, string CertNo)
        {
            //네트워크 비정상시 미사용
            if (!clsDB.bUseNetwork)
                return string.Empty;

            DBHelper helper = new DBHelper(true);
            string rtnRecDate = string.Empty;

            try
            {
                string sSQL = "";
                sSQL += "Select FN_CERT_CHK(\'" + UserID + "\',\'" + CertNo + "\') as RESULT ";
                sSQL += "FROM dual";

                DataSet ds = helper.FillDataSet(sSQL, CommandType.Text);

                if (ds.Tables[0].Rows.Count == 1)
                    rtnRecDate = ds.Tables[0].Rows[0]["RESULT"].ToString();
                else
                    rtnRecDate = string.Empty;
            }
            catch (Exception ex)
            {
                // throw ex;
            }
            finally
            {
                helper.Close();
            }
            return rtnRecDate;

        }

        //설비별 현황 조회시 마지막 동작시간 등록
        public static void Set_LastAct()
        {
            //네트워크 비정상시 미사용
            if (!clsDB.bUseNetwork)
                return;

            DBHelper helper = new DBHelper(true);
            DateTime dtNow = DateTime.Now;
            try
            {
                //10분마다 등록
                if (dtNow.Minute % 10 == 0)
                {
                    string sSQL = "UPDATE TB_WRK011 SET LASTACT_DTM = SYSDATE WHERE WERKS  = '" + PlantCode + "' AND MACH_CD = '" + MachineCode + "' AND IN_OUT ='" + IOType + "'";
                    helper.ExecuteScalar(sSQL);
                }
            }
            catch (Exception ex)
            {
                // throw ex;
            }
            finally
            {
                helper.Close();
            }
        }

        #region 공통정보
        /// <summary>
        /// 버전 정보 (BaseForm 표시 용도)
        /// </summary>
        public static string ProgVersion { get; set; }

        /// <summary>
        /// IP 정보 (BaseForm 표시 용도)
        /// </summary>
        public static string IpAddrInfo { get; set; }

        /// <summary>
        /// 작업조 (BaseForm 표시 용도)
        /// </summary>
        public static string WorkCrewName { get; set; }

        /// <summary>
        /// 작업반
        /// </summary>
        public static string WorkClass { get; set; }

        /// <summary>
        /// 작업조
        /// </summary>
        public static string WorkShift { get; set; }

        /// <summary>
        /// 공장 코드
        /// </summary>
        public static string PlantCode { get; set; }

        /// <summary>
        /// 사용자
        /// </summary>
        public static string UserID { get; set; }

        /// <summary>
        /// 사용자 명
        /// </summary>
        public static string UserName { get; set; }

        /// <summary>
        /// 공정 그룹 명
        /// </summary>
        public static string OpGrpName { get; set; }

        /// <summary>
        /// 공정 그룹 코드
        /// </summary>
        public static string OpGrpCode { get; set; }

        /// <summary>
        /// 공정 명
        /// </summary>
        public static string OpName { get; set; }

        /// <summary>
        /// 공정 코드
        /// </summary>
        public static string OpCode { get; set; }

        /// <summary>
        /// 설비 명
        /// </summary>
        public static string MachineName { get; set; }

        /// <summary>
        /// 설비 코드
        /// </summary>
        public static string MachineCode { get; set; }

        /// <summary>
        /// 단말타입
        /// </summary>
        public static string IOType { get; set; }

        /// <summary>
        /// 바코드프린터종류
        /// </summary>
        public static string PrintType { get; set; }

        /// <summary>
        /// 바코드프린터종류 명
        /// </summary>
        public static string PrientTypeName { get; set; }

        /// <summary>
        /// 바코드프린터사용유무
        /// </summary>
        public static string BarPrtUseFlag { get; set; }

        /// <summary>
        /// 프린터포트
        /// </summary>
        public static string BarPrtPortNo { get; set; }

        /// <summary>
        /// 프린터COM세팅
        /// </summary>
        public static string BarPrtComSet { get; set; }

        /// <summary>
        /// 유선스캐너사용유무
        /// </summary>
        public static string BarScanUseFlag { get; set; }

        /// <summary>
        /// 유선스캐너포트
        /// </summary>
        public static string BarScanPortNo { get; set; }

        /// <summary>
        /// 유선스캐너COM세팅
        /// </summary>
        public static string BarScanComSet { get; set; }

        /// <summary>
        /// 생산창고
        /// </summary>
        public static string WHCode { get; set; }  // private static string _WHCode

        /// <summary>
        /// 작업장
        /// </summary>
        public static string WorkCenterCode { get; set; }

        /// <summary>
        /// 작업장명 2018 05 03 hjh
        /// </summary>
        public static string WorkCenterName { get; set; }

        /// <summary>
        /// 설비호기
        /// </summary>
        public static string MachineNo { get; set; }

        /// <summary>
        /// 작업지시 번호
        /// </summary>
        public static string OrderNo { get; set; }

        /// <summary>
        /// 작업지시 비고
        /// </summary>
        public static string Remark { get; set; }

        /// <summary>
        /// 품목코드
        /// </summary>
        public static string ItemCode { get; set; }

        /// <summary>
        /// 품목명
        /// </summary>
        public static string ItemName { get; set; }

        /// <summary>
        /// LOT NO
        /// </summary>
        public static string LotNo { get; set; }

        /// <summary>
        /// 작업지시번호(깨끗한나라)
        /// </summary>
        public static string WrkOrderNo { get; set; }

        /// <summary>
        /// 작업지시순번(깨끗한나라)
        /// </summary>
        public static string WrkOrderSeq { get; set; }

        /// <summary>
        /// WMS 통신 URL(깨끗한나라)
        /// </summary>
        public static string WMS_IF_URL { get; set; }

        /// <summary>
        /// 개발/운영 IFKey 구분(깨끗한나라)
        /// </summary>
        public static string SeqType { get; set; }

        /// <summary>
        /// BaseForm 처음 실행인지 확인용 변수
        /// </summary>
        public static bool bFirstTime = false;

        /// <summary>
        /// 포장은 인증된 사용자만 공정투입 사용
        /// </summary>
        public static bool Auth_Package = false;
        

        /// <summary>
        /// DB 서버 정보 , 운영서버 인지 개발서버인지 확인
        /// </summary>
        public static bool bDBRealServer { get; set; }

        /// <summary>
        /// SAP 통신 sleep 시간 msec
        /// </summary>
        public static int SLEEP_DELAY = 1000;
        public static int SLEEP_ROLLBACK_DELAY = 2000;

        // 지시선택 화면용 조회조건 공통
        /// <summary>
        /// 지종코드
        /// </summary>
        public static string ORD_PCODE { get; set; }

        /// <summary>
        /// 평량
        /// </summary>
        public static int ORD_WEIGHT { get; set; }

        /// <summary>
        /// 가로
        /// </summary>
        public static int ORD_WLEN { get; set; }

        /// <summary>
        /// 세로
        /// </summary>
        public static int ORD_VLEN { get; set; }


        // 실적조회 화면용 조회조건 공통 (포장에서만 사용)
        /// <summary>
        /// 실적조회 시작일자 종료일자
        /// </summary>
        public static string PRFM_START_DATE { get; set; }
        public static string PRFM_END_DATE { get; set; }

        // 작업지시선택 화면용 조회조건 공통 (포장에서만 사용) 2023-09-08 백우종 추가
        /// <summary>
        /// 작업지시선택 시작일자 종료일자
        /// </summary>
        public static string WRK_START_DATE { get; set; }
        public static string WRK_END_DATE { get; set; }

        ///// <summary>
        ///// 실적조회 오더번호
        ///// </summary>
        //public static int PRFM_ORDER_NO { get; set; }

        ///// <summary>
        ///// 실적조회 개별바코드
        ///// </summary>
        //public static int PRFM_IND_BCD { get; set; }

        /// <summary>
        /// 실적조회 지종코드
        /// </summary>
        public static string PRFM_PCODE { get; set; }

        /// <summary>
        /// 실적조회 평량코드
        /// </summary>
        public static string PRFM_BSWGT { get; set; }

        /// <summary>
        /// 실적조회 가로
        /// </summary>
        public static string PRFM_WIDTH { get; set; }

        /// <summary>
        /// 실적조회 세로
        /// </summary>
        public static string PRFM_HEIGHT { get; set; }

        ///// <summary>
        ///// 실적조회 평량
        ///// </summary>
        //public static int PRFM_WEIGHT { get; set; }
        #endregion

        #region ERROR_CODE

        public const int ERROR_SUCCESS = 0;
        public const int ERROR_FAIL = 0x100;
        public const int ERROR_RFC_FAIL = 0x200;
        
        #endregion
    }


    public static class CommonCalendar
    {
        [DllImport("user32.dll", CharSet = CharSet.Auto)]
        private static extern IntPtr SendMessage(IntPtr hWnd, uint Msg, IntPtr wParam, IntPtr lParam);

        private const uint DTM_FIRST = 0x1000;
        private const uint DTM_CLOSEMONTHCAL = DTM_FIRST + 13;

        // DateTimePicker 의 달력표시 버튼 누를때 바로 닫기하여 표시 안하도록함.
        // 사용방법 : DateTimePicker의 DropDown 이벤트에서 ClsoeCalendar를 호출
        public static void CloseCalendar(DateTimePicker dtp)
        {
            SendMessage(dtp.Handle, DTM_CLOSEMONTHCAL, IntPtr.Zero, IntPtr.Zero);
        }
    }

    #endregion

    #region 콤보class
    public class ComboboxItem
    {
        public string Text { get; set; }
        public object Value { get; set; }

        public override string ToString()
        {
            return Text;
        }
    }
    #endregion
}
