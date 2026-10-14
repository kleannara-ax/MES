using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using SmartDas.Components;
using System.Runtime.InteropServices;
using Infragistics.Win.Misc;
using System.Collections;
using Microsoft.Practices.EnterpriseLibrary.Data;
using System.Data.SqlClient;
using SAMMI;
using System.Configuration;
using System.Net;
using System.Net.Sockets;
using System.Threading;
using Oracle.ManagedDataAccess.Client;
using Infragistics.Win.UltraWinGrid;

using SAP.Middleware.Connector;

namespace SmartDas.POPUP
{
    public partial class POP_WRK91 : Form
    {
        private string sPlantCode = string.Empty;
        private string sMachCode = string.Empty;
        //접속 관리
        public RfcConfigParameters rfc = null;
        public RfcDestination rfcDest = null;
        public RfcRepository rfcRep = null;
        //SAP 호출
        public IRfcFunction function = null;
        private string sIFID = string.Empty;
        private string sIFKey = string.Empty;
        //결과정보
        public IRfcStructure rtnStruct = null;
        public DataTable rtnTable = null;
        public string rtnCD = string.Empty;
        public string rtnMSG = string.Empty;

        // 플랜트코드, 작업지시번호, 작업지시순번, 업체/개별바코드, OperationType
        public POP_WRK91()
        {
            InitializeComponent();

            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.Fixed3D;
        }

        public string LabelTitle
        {
            get { return labTitle.Text; }
            set { labTitle.Text = value; }
        }

        private void POP_WRK91_Load(object sender, EventArgs e)
        {
        }

        #region < METHOD AREA >

        #endregion

        #region < EVENT AREA >

        private void btnConfirm_Click(object sender, EventArgs e)
        {
            SAPHelper SAPTemp = new SAPHelper();
            string sData = "";  // 리턴
            string aufnr = txtAufnr.Text.Trim().ToString();
            try
            {
                if (aufnr.Length != 8)
                {
                    new POPUP.MessageForm("오더번호는 8자리 입니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return;
                }
                if (aufnr.Substring(0, 1) != "4")
                {
                    new POPUP.MessageForm("점보롤 오더번호는 4로 시작됩니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return;
                }

                sData = CallOrderRFC(aufnr);
                sData = aufnr + " 번 오더에 대한 " + sData;

                new POPUP.MessageForm(sData, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                txtAufnr.Text = "";
            }
            catch (Exception ex)
            {
                LogFile.WriteLog(ex.Message.ToString());
                new POPUP.MessageForm(ex.Message.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return;
            }
        }

        private void btnClose_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        // 오더 재수신 변경 RFC 호출
        public string CallOrderRFC(string AUFNR)
        {
            DBHelper Helper = new DBHelper();
            DataTable dtImport = new DataTable();
            DataRow drImport;
            DataTable dtTempRtn;
            string sSQL = string.Empty;

            //변수 테이블 컬럼 설정
            dtImport.Columns.Add("I_FRAUFNR", typeof(string));

            //변수 테이블 값 입력
            drImport = dtImport.NewRow();
            drImport["I_FRAUFNR"] = AUFNR;

            //데이터 추가
            dtImport.Rows.Add(drImport);

            //SAP 통신
            return CallSAPChgFlagFuncQuery("Z_MES_UPDATE_IFSTE", dtImport, null, Helper);

        }

        //SAP Interface
        public string CallSAPChgFlagFuncQuery(string FuncID, DataTable PramList, DataTable PramData, DBHelper Helper)
        {
            string sColName = string.Empty;
            string sColValue = string.Empty;
            string sSeqType = string.Empty;

            //초기화
            function = null;

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

                    ////Parameter값 등록
                    //if (sColName.Equals("I_FRAUFNR"))
                    //    function.SetValue(sColName, "0000" + sColValue);
                    //else
                    //    function.SetValue(sColName, sColValue);

                    function.SetValue(sColName, sColValue);

                    //관리항목 별도저장
                    if (sColName.Equals("I_FRAUFNR"))
                    {
                        sIFID = sColValue;
                        //LogFile.WriteLog("I_FRAUFNR :  [" + function.GetValue("I_FRAUFNR").ToString() + "]");
                    }
                    else if (sColName.Equals("I_IF_KEY"))
                    {
                        sIFKey = sColValue;
                        //LogFile.WriteLog("I_IF_KEY :  [" + function.GetValue("I_IF_KEY").ToString() + "]");
                    }
                    LogFile.WriteLog(sColName + " :  [" + function.GetValue(sColName).ToString() + "]");
                }

                function.SetValue("ES_RETURN", rtnStruct);
                //LogFile.WriteLog("ES_RETURN :  [" + rtnStruct.ToString() + "]");
                //SAP RFC 실행
                function.Invoke(rfcDest);
                rfcDest = null;

                //결과 확인
                rtnStruct = function.GetStructure("ES_RETURN");
                rtnCD = rtnStruct.GetValue("TYPE").ToString();
                if (rtnCD.Equals("S"))
                {
                    //결과 저장
                    rtnMSG = rtnStruct.GetValue("MESSAGE").ToString();
                    rtnMSG = rtnMSG + "\n";
                    rtnMSG = rtnMSG + "MES 인터페이스 수신 까지 최대 40분 소요될 수 있습니다.";
                }
                else
                {
                    rtnMSG = rtnStruct.GetValue("MESSAGE").ToString();
                }

                return rtnMSG;
            }
            catch (Exception ex)
            {
                rtnMSG = ex.Message;
                return rtnMSG;
            }
        }

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
            }
            catch (Exception ex)
            {
                //LogFile.WriteLog(ex.ToString());
                Console.WriteLine(ex.ToString());
            }
        }

        #endregion

        private void txtAufnr_Click(object sender, EventArgs e)
        {

            DAResultQty pop = new DAResultQty();
            pop.LabelTitle = "오더번호 입력";
            pop.LabelHeader = "밀롤실적(M)";
            pop.ContentMaxLength = 8;

            pop.ShowDialog(this);

            if (pop.DialogResult == DialogResult.OK)
            {
                txtAufnr.Text = pop.ResultString;
            }
        }
    }
}
