using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;

using Oracle.ManagedDataAccess.Client;

using SAP.Middleware.Connector;

using SAMMI;

namespace SmartDas
{
    public class SAPHelper
    {
        //접속 관리
        public RfcConfigParameters rfc = null;
        public RfcDestination rfcDest = null;
        public RfcRepository rfcRep = null;
        //SAP 호출
        public IRfcFunction function = null;
        private string sIFID = string.Empty;
        private string sIFKey = string.Empty;
        private string sIDATE = string.Empty;

        //SAP 전송
        public IRfcTable sendTable = null;
        //결과정보
        public IRfcStructure rtnStruct = null;
        public DataTable rtnTable = null;
        public string rtnCD = string.Empty;
        public string rtnMSG = string.Empty;
        public string rtnPAUFNR = string.Empty; //생리대 폐품용 1P오더

        //접속정보 설정
        public void Destination()
        {
            try
            {
                rfc = new RfcConfigParameters();

                if (Common.bDBRealServer == true)
                {
                    ////운영 서버
                    rfc.Add(RfcConfigParameters.Name, "DPP");
                    rfc.Add(RfcConfigParameters.AppServerHost, "10.2.14.200");
                    rfc.Add(RfcConfigParameters.Client, "100");
                    rfc.Add(RfcConfigParameters.User, "MES001");
                    rfc.Add(RfcConfigParameters.Password, "Klean22709290");
                    rfc.Add(RfcConfigParameters.SystemNumber, "01");
                    rfc.Add(RfcConfigParameters.Language, "KO");
                }
                else
                {
                    //개발 DPQ SAP(신규)
                    rfc.Add(RfcConfigParameters.Name, "DPQ");
                    rfc.Add(RfcConfigParameters.AppServerHost, "10.2.14.210");
                    rfc.Add(RfcConfigParameters.Client, "100");
                    rfc.Add(RfcConfigParameters.User, "MES001");
                    rfc.Add(RfcConfigParameters.Password, "Klean22709290");
                    rfc.Add(RfcConfigParameters.SystemNumber, "01");
                    rfc.Add(RfcConfigParameters.Language, "KO");
                    ////개발용 KLQ SAP
                    //rfc.Add(RfcConfigParameters.Name, "KLQ");
                    //rfc.Add(RfcConfigParameters.AppServerHost, "10.2.14.217");
                    //rfc.Add(RfcConfigParameters.Client, "100");
                    //rfc.Add(RfcConfigParameters.User, "MESSYS");
                    //rfc.Add(RfcConfigParameters.Password, "a12345678");
                    //rfc.Add(RfcConfigParameters.SystemNumber, "01");
                    //rfc.Add(RfcConfigParameters.Language, "KO");
                    ////운영 테스트 KNQ SAP
                    //rfc.Add(RfcConfigParameters.Name, "KNQ");
                    //rfc.Add(RfcConfigParameters.AppServerHost, "10.2.14.216");
                    //rfc.Add(RfcConfigParameters.Client, "100");
                    //rfc.Add(RfcConfigParameters.User, "MES001");
                    //rfc.Add(RfcConfigParameters.Password, "Klean22709290");
                    //rfc.Add(RfcConfigParameters.SystemNumber, "01");
                    //rfc.Add(RfcConfigParameters.Language, "KO");
                }
                //-----------------------------------------------------------
                //[오후 3:26] 1. 운영시스템 (DPP)
                // - 어플리케이션 서버: 10.2.14.200
                // - 인스턴스 번호: 01
                // - 시스템 ID: DPP
                //2. 품질시스템 (DPQ) 사용안함
                // - 어플리케이션 서버: 10.2.14.210
                // - 인스턴스 번호: 01
                // - 시스템 ID: DPQ
                //3. ID
                // - 대상 시스템: DPP/DPQ
                // - 생성 ID: MES001 / WMS001
                // - PW: Klean22709290
                //-----------------------------------------------------------

                rfcDest = RfcDestinationManager.GetDestination(rfc);
                rfcRep = rfcDest.Repository;

                sIFID = string.Empty;
                sIFKey = string.Empty;
                sIDATE = string.Empty;

                //-----------------------------------------------------------
                LogFile.WriteLog(string.Format("{0} [{1}]", rfcDest.Name, rfcDest.AppServerHost), LogType.PROC);
                //-----------------------------------------------------------
            }
            catch (Exception ex)
            {
                LogFile.WriteLog(ex.ToString());
                throw ex;
            }
        }

        //SAP Interface
        public string CallSAPFunc(string FuncID, DataTable PramList, DataTable PramData, DBHelper Helper)
        {
            string sColName = string.Empty;
            string sColValue = string.Empty;
            string sSeqType = string.Empty;
            bool bSflag = false; //세부항목 성공여부
            bool bEflag = false; //세부항목 실패여부
            //초기화
            function = null;
            rtnTable = null;

            try
            {
                LogFile.WriteLog("CallSAPFunc : " + FuncID, LogType.PROC);

                //SAP 접속정보 설정
                Destination();
                function = rfcRep.CreateFunction(FuncID);

                //SAP RFC PARAM 설정
                foreach (DataColumn item in PramList.Rows[0].Table.Columns)
                {
                    sColName = item.ColumnName;
                    sColValue = PramList.Rows[0][sColName].ToString();

                    // 개발 테스트 할때 I_IF_KEY 의 첫번째 문자 'M' -> 'T'로 변경 하여 보내서 KEY 중복을 회피하기 위해서 사용, 운영서버는 M 을 사용 함.
                    // 'M0000000000000000000000010000' -> 'T0000000000000000000000010000'
                    if (sColName.Equals("I_IF_KEY"))
                    {
                        sSeqType = string.IsNullOrEmpty(Common.SeqType) ? "M" : Common.SeqType;
                        sColValue = PramList.Rows[0][sColName].ToString().Remove(0, 1).Insert(0, sSeqType);
                    }
                 
                    //Parameter값 등록
                    function.SetValue(sColName, sColValue);
                    //관리항목 별도저장
                    if (sColName.Equals("I_IF_ID"))
                        sIFID = sColValue;
                    else if (sColName.Equals("I_IF_KEY"))
                        sIFKey = sColValue;
                    else if (sColName.Equals("I_DATE"))
                        sIDATE = sColValue;
                }


                LogFile.WriteLog("----------------------------------------------------", LogType.PROC);
                LogFile.WriteLog(string.Format("{0}", FuncID), LogType.PROC);
                LogFile.WriteLog(string.Format("{0}, {1}, {2}", sIFID, sIFKey, sIDATE), LogType.PROC);

                //LogFile.WriteLog("POP_WRK26.POP_WRK26_Load Error\r\n" + ex.Message);

                //IT_DATA 설정
                if (PramData != null)
                {
                    //RFCTable 양식 복사
                    sendTable = function.GetTable("IT_DATA");
                    //각 항목별 데이터 복사
                    foreach (DataRow oRow in PramData.Rows)
                    {
                        sendTable.Append();
                        LogFile.WriteLog("----------------------------------------------------", LogType.PROC);
                        foreach (DataColumn item in PramData.Rows[0].Table.Columns)
                        {
                            sColName = item.ColumnName;
                            LogFile.WriteLog(string.Format("{0}, {1}", item.ColumnName, oRow[sColName].ToString()), LogType.PROC);
                            sendTable.SetValue(sColName, oRow[sColName].ToString());
                        }
                    }
                    function.SetValue("IT_DATA", sendTable);
                }
                LogFile.WriteLog("----------------------------------------------------", LogType.PROC);
                
                //SAP RFC 실행
                LogFile.WriteLog("RFC Start (IFID : " + sIFID + " / IFKey : " + sIFKey + ") ", LogType.PROC);
                function.Invoke(rfcDest);
                LogFile.WriteLog("After Invoke", LogType.PROC);

                rfcDest = null;
                //결과 확인
                rtnStruct = function.GetStructure("ES_RETURN");
                rtnCD = rtnStruct.GetValue("TYPE").ToString();
                if (rtnCD.Equals("S"))
                {
                    //결과 저장
                    rtnTable = GetDataTableFromRFCTable(function.GetTable("ET_DATA"));
                    LogFile.WriteLog("After Invoke rtnCD = S Step 1", LogType.PROC);

                    LogFile.WriteLog("After Invoke rtnCD = S Step 2 rtnTable.Rows.Count = " + rtnTable.Rows.Count.ToString(), LogType.PROC);
                    //세부사항 실패여부 확인
                    for (int i=0;i<rtnTable.Rows.Count;i++)
                    {
                        //에러 발생시
                        if (rtnTable.Rows[i]["TYPE"].ToString().Equals("S"))
                        {
                            bSflag = true;
                        }
                        else
                        {
                            bEflag = true;
                            LogFile.WriteLog("[RFC ERROR] " + rtnTable.Rows[i]["MESSAGE"].ToString(), LogType.PROC);

                            if (string.IsNullOrEmpty(rtnMSG))
                                rtnMSG = rtnTable.Rows[i]["MESSAGE"].ToString() + "\n";
                            else
                                rtnMSG = rtnMSG + rtnTable.Rows[i]["MESSAGE"].ToString() + "\n";
                        }
                    }
                    //전체 성공
                    if (bSflag && !bEflag)
                        rtnCD = "S";
                    //부분성공
                    else if (bSflag && bEflag)
                        rtnCD = "S";//"P";
                    //전체실패
                    else if (!bSflag && bEflag)
                        rtnCD = "E";
                    else
                        rtnCD = "E";
                }
                else
                {
                    rtnMSG = rtnStruct.GetValue("MESSAGE").ToString();
                    //실패결과 저장처리
                    //결과 저장
                    rtnTable = GetDataTableFromRFCTable(function.GetTable("IT_DATA"));
                    LogFile.WriteLog("After Invoke rtnCD = E Step 1" + rtnTable.Rows.Count.ToString(), LogType.PROC);
                    for (int i = 0; i < rtnTable.Rows.Count; i++)
                    {
                        rtnTable.Rows[i]["TYPE"] = rtnCD;
                        rtnTable.Rows[i]["MESSAGE"] = rtnMSG;
                    }
                }

                LogFile.WriteLog("RFC End (IFID : " + sIFID + " / IFKey : " + sIFKey + ") ", LogType.PROC);

                //반환 결과 저장
                if (SaveRFCResult(Helper))
                    return rtnCD;
                else
                    return "E";//"F";
                //return rtnCD;
            }
            catch (Exception ex)
            {
                LogFile.WriteLog(ex.ToString());
                rtnMSG = ex.Message;
                return "E";
            }
        }


        //SAP Interface
        public string CallSAPFunc_PS(string FuncID, DataTable PramList, DataTable PramData, DBHelper Helper)
        {
            string sColName = string.Empty;
            string sColValue = string.Empty;
            string sSeqType = string.Empty;
            bool bSflag = false; //세부항목 성공여부
            bool bEflag = false; //세부항목 실패여부
            //초기화
            function = null;
            rtnTable = null;

            try
            {
                LogFile.WriteLog("CallSAPFunc_PS : " + FuncID, LogType.PROC);

                //SAP 접속정보 설정
                Destination();
                function = rfcRep.CreateFunction(FuncID);

                //SAP RFC PARAM 설정
                foreach (DataColumn item in PramList.Rows[0].Table.Columns)
                {
                    sColName = item.ColumnName;
                    sColValue = PramList.Rows[0][sColName].ToString();

                    // 개발 테스트 할때 I_IF_KEY 의 첫번째 문자 'M' -> 'T'로 변경 하여 보내서 KEY 중복을 회피하기 위해서 사용, 운영서버는 M 을 사용 함.
                    // 'M0000000000000000000000010000' -> 'T0000000000000000000000010000'
                    if (sColName.Equals("I_IF_KEY"))
                    {
                        sSeqType = string.IsNullOrEmpty(Common.SeqType) ? "M" : Common.SeqType;
                        sColValue = PramList.Rows[0][sColName].ToString().Remove(0, 1).Insert(0, sSeqType);
                    }

                    //Parameter값 등록
                    function.SetValue(sColName, sColValue);
                    //관리항목 별도저장
                    if (sColName.Equals("I_IF_ID"))
                        sIFID = sColValue;
                    else if (sColName.Equals("I_IF_KEY"))
                        sIFKey = sColValue;
                    else if (sColName.Equals("I_DATE"))
                        sIDATE = sColValue;
                }


                LogFile.WriteLog("----------------------------------------------------", LogType.PROC);
                LogFile.WriteLog(string.Format("{0}", FuncID), LogType.PROC);
                LogFile.WriteLog(string.Format("{0}, {1}, {2}", sIFID, sIFKey, sIDATE), LogType.PROC);

                //LogFile.WriteLog("POP_WRK26.POP_WRK26_Load Error\r\n" + ex.Message);

                //IT_DATA 설정
                if (PramData != null)
                {
                    //RFCTable 양식 복사
                    sendTable = function.GetTable("IT_DATA");
                    //각 항목별 데이터 복사
                    foreach (DataRow oRow in PramData.Rows)
                    {
                        sendTable.Append();
                        LogFile.WriteLog("----------------------------------------------------", LogType.PROC);
                        foreach (DataColumn item in PramData.Rows[0].Table.Columns)
                        {
                            sColName = item.ColumnName;
                            LogFile.WriteLog(string.Format("{0}, {1}", item.ColumnName, oRow[sColName].ToString()), LogType.PROC);
                            sendTable.SetValue(sColName, oRow[sColName].ToString());
                        }
                    }
                    function.SetValue("IT_DATA", sendTable);
                }
                LogFile.WriteLog("----------------------------------------------------", LogType.PROC);

                //SAP RFC 실행
                LogFile.WriteLog("RFC Start (IFID : " + sIFID + " / IFKey : " + sIFKey + ") ", LogType.PROC);
                function.Invoke(rfcDest);
                LogFile.WriteLog("After Invoke", LogType.PROC);

                rfcDest = null;
                //결과 확인
                rtnStruct = function.GetStructure("ES_RETURN");
                rtnCD = rtnStruct.GetValue("TYPE").ToString();
               if (rtnCD.Equals("S"))
                {
                    //결과 저장
                    rtnTable = GetDataTableFromRFCTable(function.GetTable("ET_DATA"));
                    LogFile.WriteLog("After Invoke rtnCD = S Step 1", LogType.PROC);

                    LogFile.WriteLog("After Invoke rtnCD = S Step 2 rtnTable.Rows.Count = " + rtnTable.Rows.Count.ToString(), LogType.PROC);
                    //세부사항 실패여부 확인
                    for (int i = 0; i < rtnTable.Rows.Count; i++)
                    {
                        //에러 발생시
                        if (rtnTable.Rows[i]["TYPE"].ToString().Equals("S"))
                        {
                            bSflag = true;
                        }
                        else
                        {
                            bEflag = true;
                            LogFile.WriteLog("[RFC ERROR] " + rtnTable.Rows[i]["MESSAGE"].ToString(), LogType.PROC);

                            if (string.IsNullOrEmpty(rtnMSG))
                                rtnMSG = rtnTable.Rows[i]["MESSAGE"].ToString() + "\n";
                            else
                                rtnMSG = rtnMSG + rtnTable.Rows[i]["MESSAGE"].ToString() + "\n";
                        }
                    }

                    // 한건이라도 실패인경우
                    if (bEflag)
                        rtnCD = "E";
                    else
                        rtnCD = "S";
                }
                else
                {
                    rtnMSG = rtnStruct.GetValue("MESSAGE").ToString();
                    //실패결과 저장처리
                    //결과 저장
                    rtnTable = GetDataTableFromRFCTable(function.GetTable("ET_DATA"));
                    LogFile.WriteLog("After Invoke rtnCD = E Step 1" + rtnTable.Rows.Count.ToString(), LogType.PROC);
                    rtnTable = GetDataTableFromRFCTable(function.GetTable("IT_DATA"));
                    for (int i = 0; i < rtnTable.Rows.Count; i++)
                    {
                        rtnTable.Rows[i]["TYPE"] = rtnCD;
                        rtnTable.Rows[i]["MESSAGE"] = rtnMSG;
                    }
                }

                LogFile.WriteLog("RFC End (IFID : " + sIFID + " / IFKey : " + sIFKey + ") ", LogType.PROC);

                //반환 결과 저장
                if (SaveRFCResult(Helper))
                    return rtnCD;
                else
                    return "E";//"F";
                //return rtnCD;
            }
            catch (Exception ex)
            {
                LogFile.WriteLog(ex.ToString());
                rtnMSG = ex.Message;
                return "E";
            }
        }

        //SAP Interface
        public string CallSAPFunc_HL(string FuncID, DataTable PramList, DataTable PramData, DBHelper Helper)
        {
            string sColName = string.Empty;
            string sColValue = string.Empty;
            string sSeqType = string.Empty;
            bool bSflag = false; //세부항목 성공여부
            bool bEflag = false; //세부항목 실패여부
            //초기화
            function = null;
            rtnTable = null;
            try
            {
                LogFile.WriteLog("CallSAPFunc_HL : " + FuncID, LogType.PROC);

                //SAP 접속정보 설정
                Destination();
                function = rfcRep.CreateFunction(FuncID);
                //SAP RFC PARAM 설정
                foreach (DataColumn item in PramList.Rows[0].Table.Columns)
                {
                    sColName = item.ColumnName;
                    sColValue = PramList.Rows[0][sColName].ToString();
                    // 개발 테스트 할때 I_IF_KEY 의 첫번째 문자 'M' -> 'T'로 변경 하여 보내서 KEY 중복을 회피하기 위해서 사용, 운영서버는 M 을 사용 함.
                    // 'M0000000000000000000000010000' -> 'T0000000000000000000000010000'
                    if (sColName.Equals("I_IF_KEY"))
                    {
                        sSeqType = string.IsNullOrEmpty(Common.SeqType) ? "M" : Common.SeqType;
                        sColValue = PramList.Rows[0][sColName].ToString().Remove(0, 1).Insert(0, sSeqType);
                    }
                    //Parameter값 등록
                    function.SetValue(sColName, sColValue);
                    //관리항목 별도저장
                    if (sColName.Equals("I_IF_ID"))
                        sIFID = sColValue;
                    else if (sColName.Equals("I_IF_KEY"))
                        sIFKey = sColValue;
                    else if (sColName.Equals("I_DATE"))
                        sIDATE = sColValue;
                }
                LogFile.WriteLog("----------------------------------------------------", LogType.PROC);
                LogFile.WriteLog(string.Format("{0}", FuncID), LogType.PROC);
                LogFile.WriteLog(string.Format("{0}, {1}, {2}", sIFID, sIFKey, sIDATE), LogType.PROC);
                //LogFile.WriteLog("POP_WRK26.POP_WRK26_Load Error\r\n" + ex.Message);
                //IT_DATA 설정
                if (PramData != null)
                {
                    //RFCTable 양식 복사
                    sendTable = function.GetTable("IT_DATA");
                    //각 항목별 데이터 복사
                    foreach (DataRow oRow in PramData.Rows)
                    {
                        sendTable.Append();
                        LogFile.WriteLog("----------------------------------------------------", LogType.PROC);
                        foreach (DataColumn item in PramData.Rows[0].Table.Columns)
                        {
                            sColName = item.ColumnName;
                            LogFile.WriteLog(string.Format("{0}, {1}", item.ColumnName, oRow[sColName].ToString()), LogType.PROC);
                            sendTable.SetValue(sColName, oRow[sColName].ToString());
                        }
                    }
                    function.SetValue("IT_DATA", sendTable);
                }
                LogFile.WriteLog("----------------------------------------------------", LogType.PROC);
                //SAP RFC 실행
                LogFile.WriteLog("RFC Start (IFID : " + sIFID + " / IFKey : " + sIFKey + ") ", LogType.PROC);
                function.Invoke(rfcDest);
                LogFile.WriteLog("After Invoke", LogType.PROC);
                rfcDest = null;
                //결과 확인
                rtnStruct = function.GetStructure("ES_RETURN");
                rtnCD = rtnStruct.GetValue("TYPE").ToString();
                if (rtnCD.Equals("S"))
                {
                    //결과 저장
                    rtnTable = GetDataTableFromRFCTable(function.GetTable("ET_DATA"));
                    LogFile.WriteLog("After Invoke rtnCD = S Step 1", LogType.PROC);

                    LogFile.WriteLog("After Invoke rtnCD = S Step 2 rtnTable.Rows.Count = " + rtnTable.Rows.Count.ToString(), LogType.PROC);
                    //세부사항 실패여부 확인
                    for (int i = 0; i < rtnTable.Rows.Count; i++)
                    {
                        //에러 발생시
                        if (rtnTable.Rows[i]["TYPE"].ToString().Equals("S"))
                        {
                            bSflag = true;
                        }
                        else
                        {
                            bEflag = true;
                            LogFile.WriteLog("[RFC ERROR] " + rtnTable.Rows[i]["MESSAGE"].ToString(), LogType.PROC);
                            if (string.IsNullOrEmpty(rtnMSG))
                                rtnMSG = rtnTable.Rows[i]["MESSAGE"].ToString() + "\n";
                            else
                                rtnMSG = rtnMSG + rtnTable.Rows[i]["MESSAGE"].ToString() + "\n";
                        }
                    }
                    //전체 성공
                    if (bSflag && !bEflag)
                        rtnCD = "S";
                    //부분성공
                    else if (bSflag && bEflag)
                        rtnCD = "S";//"P";
                    //전체실패
                    else if (!bSflag && bEflag)
                        rtnCD = "E";
                    else
                        rtnCD = "E";
                }
                else
                {
                    rtnMSG = rtnStruct.GetValue("MESSAGE").ToString();
                    //실패결과 저장처리
                    //결과 저장
                    rtnTable = GetDataTableFromRFCTable(function.GetTable("IT_DATA"));
                    LogFile.WriteLog("After Invoke rtnCD = E Step 1" + rtnTable.Rows.Count.ToString(), LogType.PROC);
                    for (int i = 0; i < rtnTable.Rows.Count; i++)
                    {
                        rtnTable.Rows[i]["TYPE"] = rtnCD;
                        rtnTable.Rows[i]["MESSAGE"] = rtnMSG;
                    }
                }
                LogFile.WriteLog("RFC End (IFID : " + sIFID + " / IFKey : " + sIFKey + ") ", LogType.PROC);
                //반환 결과 저장
                if (SaveRFCResult_HL(Helper))
                    return rtnCD;
                else
                    return "E";//"F";
                //return rtnCD;
            }
            catch (Exception ex)
            {
                LogFile.WriteLog(ex.ToString());
                rtnMSG = ex.Message;
                return "E";
            }
        }

        //수신 데이터 DB 등록
        public bool SaveRFCResult(DBHelper helper)
        {
            //DBHelper helper = new DBHelper(false, "", true);
            string sRFCList;
            //결과 테이블 존재여부 확인
            if (rtnTable != null)
            {
                //RFC 전송 결과 조회
                sRFCList = Common.toJsonFormat(sIFID, rtnTable);

                LogFile.WriteLog("RFC Return " + sRFCList, LogType.PROC);
                LogFile.WriteLog("\r\n", LogType.PROC);

                try
                {
                    //RFC 결과정보 DB등록
                    helper.ExecuteNoneQuery("SP_IF_PUT_IFSRTN", CommandType.StoredProcedure
                                                      , helper.CreateParameter("P_IF_ID", sIFID, DbType.String, ParameterDirection.Input)
                                                      , helper.CreateParameter("P_IF_KEY", sIFKey, DbType.String, ParameterDirection.Input)
                                                      , helper.CreateParameterOracle("P_RFC_DATA", sRFCList, OracleDbType.Clob, ParameterDirection.Input)
                                                      , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input));
                }
                catch (Exception ex)
                {

                    Console.WriteLine(ex.ToString());
                    rtnMSG = ex.Message;
                    //helper.Rollback();
                    return false;
                }
            }
            return true;
        }

        public bool SaveRFCResult_HL(DBHelper helper)
        {
            //롤백처리용 HL SAP 결과처리 함수, COMMIT 제거
            //DBHelper helper = new DBHelper(false, "", true);
            string sRFCList;
            //결과 테이블 존재여부 확인
            if (rtnTable != null)
            {
                //RFC 전송 결과 조회
                sRFCList = Common.toJsonFormat(sIFID, rtnTable);
                LogFile.WriteLog("RFC Return " + sRFCList, LogType.PROC);
                LogFile.WriteLog("\r\n", LogType.PROC);
                try
                {
                    //RFC 결과정보 DB등록
                    helper.ExecuteNoneQuery("SP_IF_PUT_IFSRTN_HL", CommandType.StoredProcedure
                                                      , helper.CreateParameter("P_IF_ID", sIFID, DbType.String, ParameterDirection.Input)
                                                      , helper.CreateParameter("P_IF_KEY", sIFKey, DbType.String, ParameterDirection.Input)
                                                      , helper.CreateParameterOracle("P_RFC_DATA", sRFCList, OracleDbType.Clob, ParameterDirection.Input)
                                                      , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input));
                }
                catch (Exception ex)
                {
                    Console.WriteLine(ex.ToString());
                    rtnMSG = ex.Message;
                    //helper.Rollback();
                    return false;
                }
            }
            return true;
        }

        public bool SaveResulttoWrk(DBHelper helper, string ProcCD, string WrkType)
        {
            string sRFCList; //RFC결과 JSON 변환

            //RFC 전송 결과 조회
            sRFCList = Common.toJsonFormat(ProcCD, rtnTable);
            sRFCList = sRFCList.Replace("MBLNR", "RUECK");
            sRFCList = sRFCList.Replace("MJAHR", "RMZHL");

            //RFC 결과정보 DB등록
            helper.ExecuteNoneQuery("SP_IF_PUT_WRKRTN", CommandType.StoredProcedure
                                              , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)
                                              , helper.CreateParameter("P_WRK_TYPE", WrkType, DbType.String, ParameterDirection.Input)
                                              , helper.CreateParameterOracle("P_RFC_DATA", sRFCList, OracleDbType.Clob, ParameterDirection.Input)
                                              , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input));
            if (helper.RSCODE.Equals("S"))
                return true;
            else
                return false;
        }

        public bool SaveResulttoWrk_HL(DBHelper helper, string ProcCD, string WrkType)
        {
            string sRFCList; //RFC결과 JSON 변환
            //RFC 전송 결과 조회
            sRFCList = Common.toJsonFormat(ProcCD, rtnTable);
            sRFCList = sRFCList.Replace("MBLNR", "RUECK");
            sRFCList = sRFCList.Replace("MJAHR", "RMZHL");
            //RFC 결과정보 DB등록
            helper.ExecuteNoneQuery("SP_IF_PUT_WRKRTN_HL", CommandType.StoredProcedure
                                              , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)
                                              , helper.CreateParameter("P_WRK_TYPE", WrkType, DbType.String, ParameterDirection.Input)
                                              , helper.CreateParameterOracle("P_RFC_DATA", sRFCList, OracleDbType.Clob, ParameterDirection.Input)
                                              , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input));
            if (helper.RSCODE.Equals("S"))
                return true;
            else
                return false;
        }



        //단일재고 데이터 조회
        public string GetStckData(string WERKS, string LOTNO, string MATNR, string LOCATION)
        {
            DBHelper Helper = new DBHelper(false, "", true);
            DataTable dtImport = new DataTable();
            DataRow drImport;
            DataTable dtTempRtn;
            string sSQL = string.Empty;

            sSQL += "Select LTRIM(RTRIM(TO_CHAR(SEQ_GET_IFR_KEY.NEXTVAL, '00000000000000000000000000000'))) AS I_IF_KEY ";
            sSQL += "FROM dual";

            dtTempRtn = Helper.FillTable(sSQL, CommandType.Text);

            //변수 테이블 컬럼 설정
            dtImport.Columns.Add("I_IF_ID", typeof(string));
            dtImport.Columns.Add("I_IF_KEY", typeof(string));
            dtImport.Columns.Add("I_WERKS", typeof(string));
            dtImport.Columns.Add("I_LOTNO", typeof(string));
            dtImport.Columns.Add("I_MATNR", typeof(string));
            dtImport.Columns.Add("I_LGORT", typeof(string));
            //변수 테이블 값 입력
            drImport = dtImport.NewRow();
            drImport["I_IF_ID"] = "MES_IF_907";
            drImport["I_IF_KEY"] = "M" + dtTempRtn.Rows[0][0].ToString();
            drImport["I_WERKS"] = WERKS;
            drImport["I_LOTNO"] = LOTNO;
            drImport["I_MATNR"] = MATNR;
            drImport["I_LGORT"] = LOCATION;
            //데이터 추가
            dtImport.Rows.Add(drImport);

            //SAP 통신
            return CallSAPFuncQuery("Z_MES_SAP_INV_INFO", dtImport, null, Helper);
        }

        //수신 테이터 DataTable로 변환처리
        public DataTable GetDataTableFromRFCTable(IRfcTable myrfcTable)
        {
            DataTable loTable = new DataTable();
            int liElement = 0;
            for (liElement = 0; liElement <= myrfcTable.ElementCount - 1; liElement++)
            {
                RfcElementMetadata metadata = myrfcTable.GetElementMetadata(liElement);
                loTable.Columns.Add(metadata.Name);
            }
            foreach (IRfcStructure Row in myrfcTable)
            {
                DataRow ldr = loTable.NewRow();
                for (liElement = 0; liElement <= myrfcTable.ElementCount - 1; liElement++)
                {
                    RfcElementMetadata metadata = myrfcTable.GetElementMetadata(liElement);
                    ldr[metadata.Name] = Row.GetString(metadata.Name);
                }
                loTable.Rows.Add(ldr);
            }
            return loTable;
        }

        //SAP Interface 예외항목 존재시 사용
        public string CallSAPFunc_EX(string FuncID, DataTable PramList, DataTable PramData, DBHelper Helper, string EXList, string P_AUFNR)
        {
            string sColName = string.Empty;
            //초기화
            function = null;
            rtnTable = null;

            try
            {
                LogFile.WriteLog("CallSAPFunc_EX : " + FuncID, LogType.PROC);

                //SAP 접속정보 설정
                Destination();
                function = rfcRep.CreateFunction(FuncID);

                //SAP RFC PARAM 설정
                foreach (DataColumn item in PramList.Rows[0].Table.Columns)
                {
                    sColName = item.ColumnName;
                    function.SetValue(sColName, PramList.Rows[0][sColName].ToString());

                    if (sColName.Equals("I_IF_ID"))
                        sIFID = PramList.Rows[0][sColName].ToString();
                    else if (sColName.Equals("I_IF_KEY"))
                        sIFKey = PramList.Rows[0][sColName].ToString();
                    else if (sColName.Equals("I_DATE"))
                        sIDATE = PramList.Rows[0][sColName].ToString();
                }

                LogFile.WriteLog("----------------------------------------------------", LogType.PROC);
                //LogFile.WriteLog(string.Format("{0}", FuncID), LogType.PROC);
                LogFile.WriteLog(string.Format("{0}, {1}, {2}", sIFID, sIFKey, sIDATE), LogType.PROC);
                
                //IT_DATA 설정
                if (PramData != null)
                {
                    //RFCTable 양식 복사
                    sendTable = function.GetTable("IT_DATA");
                    //각 항목별 데이터 복사
                    foreach (DataRow oRow in PramData.Rows)
                    {
                        sendTable.Append();
                        LogFile.WriteLog("----------------------------------------------------", LogType.PROC);
                        foreach (DataColumn item in PramData.Rows[0].Table.Columns)
                        {
                            sColName = item.ColumnName;
                            //미전송 목록여부 확인
                            if (!EXList.Contains(sColName))
                            {
                                //대체 정보 확인
                                if ((!string.IsNullOrEmpty(P_AUFNR)) && sColName.Equals("AUFNR"))
                                {
                                    LogFile.WriteLog(string.Format("{0}, {1}", sColName, P_AUFNR), LogType.PROC);
                                    sendTable.SetValue(sColName, P_AUFNR);
                                }
                                else
                                {
                                    LogFile.WriteLog(string.Format("{0}, {1}", sColName, oRow[sColName].ToString()), LogType.PROC);
                                    sendTable.SetValue(sColName, oRow[sColName].ToString());
                                }
                            }
                        }
                    }
                    function.SetValue("IT_DATA", sendTable);
                }
                LogFile.WriteLog("----------------------------------------------------", LogType.PROC);

                //SAP RFC 실행
                LogFile.WriteLog("RFC Start (IFID : " + sIFID + " / IFKey : " + sIFKey + ") ", LogType.PROC);
                function.Invoke(rfcDest);
                LogFile.WriteLog("After Invoke rtnCD = S Step 1", LogType.PROC);
                LogFile.WriteLog("RFC End (IFID : " + sIFID + " / IFKey : " + sIFKey + ") ", LogType.PROC);
                rfcDest = null;
                //결과 확인
                rtnStruct = function.GetStructure("ES_RETURN");
                rtnCD = rtnStruct.GetValue("TYPE").ToString();
                if (rtnCD.Equals("S"))
                {
                    //결과 저장
                    rtnTable = GetDataTableFromRFCTable(function.GetTable("ET_DATA"));

                    LogFile.WriteLog("After Invoke rtnCD = S Step 2 rtnTable.Rows.Count = " + rtnTable.Rows.Count.ToString(), LogType.PROC);
                    //신규 1P 오더저장
                    if (EXList.Contains("AUFNR"))
                        rtnPAUFNR = rtnTable.Rows[0]["PAUFNR"].ToString();
                }
                else
                {
                    rtnMSG = rtnStruct.GetValue("MESSAGE").ToString();
                    LogFile.WriteLog("After Invoke rtnCD = E Step 1" + rtnTable.Rows.Count.ToString(), LogType.PROC);

                    LogFile.WriteLog("[RFC ERROR] " + rtnMSG, LogType.ERROR);
                }

                //반환 결과 저장
                if (SaveRFCResult_HL(Helper))
                    return rtnCD;
                else
                    return "E";
                //return rtnCD;
            }
            catch (Exception ex)
            {
                LogFile.WriteLog(ex.ToString());
                rtnMSG = ex.Message;
                return "E";
            }
        }


        //SAP Interface 조회용
        public string CallSAPFuncQuery(string FuncID, DataTable PramList, DataTable PramData, DBHelper Helper)
        {
            string sColName = string.Empty;
            string sColValue = string.Empty;
            string sSeqType = string.Empty;

            //초기화
            function = null;
            rtnTable = null;

            try
            {
                //SAP 접속정보 설정
                Destination();
                function = rfcRep.CreateFunction(FuncID);

                //SAP RFC PARAM 설정
                foreach (DataColumn item in PramList.Rows[0].Table.Columns)
                {
                    sColName = item.ColumnName;
                    sColValue = PramList.Rows[0][sColName].ToString();

                    // 개발 테스트 할때 I_IF_KEY 의 첫번째 문자 'M' -> 'T'로 변경 하여 보내서 KEY 중복을 회피하기 위해서 사용, 운영서버는 M 을 사용 함.
                    // 'M0000000000000000000000010000' -> 'T0000000000000000000000010000'
                    if (sColName.Equals("I_IF_KEY"))
                    {
                        sSeqType = string.IsNullOrEmpty(Common.SeqType) ? "M" : Common.SeqType;
                        sColValue = PramList.Rows[0][sColName].ToString().Remove(0, 1).Insert(0, sSeqType);
                    }

                    //Parameter값 등록
                    function.SetValue(sColName, sColValue);
                    //관리항목 별도저장
                    if (sColName.Equals("I_IF_ID"))
                        sIFID = sColValue;
                    else if (sColName.Equals("I_IF_KEY"))
                        sIFKey = sColValue;
                }


                LogFile.WriteLog("----------------------------------------------------", LogType.PROC);
                LogFile.WriteLog(string.Format("{0}", FuncID), LogType.PROC);
                LogFile.WriteLog(string.Format("{0}, {1}", sIFID, sIFKey), LogType.PROC);

                //LogFile.WriteLog("POP_WRK26.POP_WRK26_Load Error\r\n" + ex.Message);

                //IT_DATA 설정
                if (PramData != null)
                {
                    //RFCTable 양식 복사
                    sendTable = function.GetTable("IT_DATA");
                    //각 항목별 데이터 복사
                    foreach (DataRow oRow in PramData.Rows)
                    {
                        sendTable.Append();
                        LogFile.WriteLog("----------------------------------------------------", LogType.PROC);
                        foreach (DataColumn item in PramData.Rows[0].Table.Columns)
                        {
                            sColName = item.ColumnName;
                            LogFile.WriteLog(string.Format("{0}, {1}", item.ColumnName, oRow[sColName].ToString()), LogType.PROC);
                            sendTable.SetValue(sColName, oRow[sColName].ToString());
                        }
                    }
                    function.SetValue("IT_DATA", sendTable);
                }
                LogFile.WriteLog("----------------------------------------------------", LogType.PROC);

                //SAP RFC 실행
                LogFile.WriteLog("RFC Start (IFID : " + sIFID + " / IFKey : " + sIFKey + ") ", LogType.PROC);
                function.Invoke(rfcDest);
                LogFile.WriteLog("After Invoke", LogType.PROC);

                rfcDest = null;
                //결과 확인
                rtnStruct = function.GetStructure("ES_RETURN");
                rtnCD = rtnStruct.GetValue("TYPE").ToString();
                rtnMSG = rtnStruct.GetValue("MESSAGE").ToString();

                if (rtnCD.Equals("S"))
                {
                    //결과 저장
                    rtnTable = GetDataTableFromRFCTable(function.GetTable("ET_DATA"));
                    LogFile.WriteLog("After Invoke rtnCD = S Step 1", LogType.PROC);

                    LogFile.WriteLog("After Invoke rtnCD = S Step 2 rtnTable.Rows.Count = " + rtnTable.Rows.Count.ToString(), LogType.PROC);
                }

                LogFile.WriteLog("RFC End (IFID : " + sIFID + " / IFKey : " + sIFKey + ") ", LogType.PROC);

                return rtnCD;
            }
            catch (Exception ex)
            {
                LogFile.WriteLog(ex.ToString());
                rtnMSG = ex.Message;
                return "E";
            }
        }

    }
}
