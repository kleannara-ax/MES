using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using SAP.Middleware.Connector;
using System.Data;

namespace SAP_STOCK
{
    class SAPHelper
    {
        //접속 관리
        public RfcConfigParameters rfc = null;
        public RfcDestination rfcDest = null;
        public RfcRepository rfcRep = null;
        //SAP 호출
        public IRfcFunction function = null;
        private string sIFID = string.Empty;
        private string sIFKey = string.Empty;
        //SAP 전송
        public IRfcTable sendTable = null;
        //결과정보
        public IRfcStructure rtnStruct = null;
        public DataTable rtnTable = null;
        public string rtnCD = string.Empty;
        public string rtnMSG = string.Empty;

        //접속정보 설정
        public void Destination()
        {
            try
            {
                rfc = new RfcConfigParameters();

                //////개발 DPQ SAP(신규)
                //rfc.Add(RfcConfigParameters.Name, "DPQ");
                //rfc.Add(RfcConfigParameters.AppServerHost, "10.2.14.210");
                //rfc.Add(RfcConfigParameters.Client, "100");
                //rfc.Add(RfcConfigParameters.User, "MES001");
                //rfc.Add(RfcConfigParameters.Password, "Klean22709291");
                //rfc.Add(RfcConfigParameters.SystemNumber, "01");
                //rfc.Add(RfcConfigParameters.Language, "KO");

                //운영 서버
                rfc.Add(RfcConfigParameters.Name, "DPP");
                rfc.Add(RfcConfigParameters.AppServerHost, "10.2.14.200");
                rfc.Add(RfcConfigParameters.Client, "100");
                rfc.Add(RfcConfigParameters.User, "MES001");
                rfc.Add(RfcConfigParameters.Password, "Klean22709290");
                rfc.Add(RfcConfigParameters.SystemNumber, "01");
                rfc.Add(RfcConfigParameters.Language, "KO");



                rfcDest = RfcDestinationManager.GetDestination(rfc);
                rfcRep = rfcDest.Repository;
            }
            catch (Exception ex)
            {
                //LogFile.WriteLog(ex.ToString());
                Console.WriteLine(ex.ToString());
            }
        }

        //SAP Interface
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
                        sColValue = PramList.Rows[0][sColName].ToString().Remove(0, 1).Insert(0, "M");
                    }

                    //Parameter값 등록
                    function.SetValue(sColName, sColValue);
                    //관리항목 별도저장
                    if (sColName.Equals("I_IF_ID"))
                        sIFID = sColValue;
                    else if (sColName.Equals("I_IF_KEY"))
                        sIFKey = sColValue;
                }

                //SAP RFC 실행
                function.Invoke(rfcDest);
                rfcDest = null;

                //결과 확인
                rtnStruct = function.GetStructure("ES_RETURN");
                rtnCD = rtnStruct.GetValue("TYPE").ToString();
                if (rtnCD.Equals("S"))
                {
                    //결과 저장
                    rtnTable = GetDataTableFromRFCTable(function.GetTable("ET_DATA"));
                }
                else
                {
                    rtnMSG = rtnStruct.GetValue("MESSAGE").ToString();
                }

                return rtnCD;
            }
            catch (Exception ex)
            {
                rtnMSG = ex.Message;
                return "E";
            }
        }

        //단일재고 데이터 조회
        public string GetStckData(string WERKS, string LOTNO, string MATNR, string LOCATION)
        {
            DBHelper Helper = new DBHelper();
            DataTable dtImport = new DataTable();
            DataRow drImport;
            DataTable dtTempRtn;
            string sSQL = string.Empty;

            sSQL += "Select LTRIM(RTRIM(TO_CHAR(SEQ_GET_IFR_KEY.NEXTVAL, '00000000000000000000000000000'))) AS I_IF_KEY ";
            sSQL += "FROM dual";

            dtTempRtn = Helper.FillTable(sSQL);

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
    }
}
