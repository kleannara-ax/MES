#region [ USING AREA ]
using System;
using System.Configuration;
using System.Data;
using System.Windows.Forms;
using System.Drawing;


using SAMMI;
using SmartDas.Components;
using SmartDas.POPUP;
using System.Globalization;
using Oracle.ManagedDataAccess.Client;
using System.Threading;
#endregion

namespace SmartDas
{
    public partial class POP_WRK24 : BaseForm
    {
        #region < MEMBER AREA >
        //private string sStartTime = string.Empty;
        //private int iSelRow;
        //private int iSecond = 0;

        private int giBS_WGT = 0;                   // 평량
        private int giNON_ORDR_BS_WGT = 0;          // 비계획 생산 평량
        private int giJWIDTH = 0;                   // 지폭
        private Decimal gdTSPEED = 0;                   // 목표선속
        private Decimal gdROLLCNT = 0;       // 권치수
        private Decimal gdWGT = 0;           // 중량

        private string gsUNIT = string.Empty;

        //private string gsIND_BCD = "";      // 개별바코드 (인쇄용)
        private int giPosROLLCNT = 0;  // 등록가능한 권치수

        private SAMMI.Common _common = new SAMMI.Common();

        public static string userID = string.Empty;
        public static string userName = string.Empty;


        // 버튼 알람용 변수
        private int iReSetCnt = 0;
        private bool bABNChk = false;
        DataTable dtStop_Temp = new DataTable();
        //*************************************
        //control 네이밍 정보
        //-------------------------------------
        //투입정보  : IN_XXX (INput)
        //작업지시정보 : WO_XXX (Work Order)
        //실적등록정보 : PF_XXX (PerFormance)
        //*************************************
        #endregion

        #region < CONSTRUCTOR >

        public POP_WRK24()
        {
            InitializeComponent();

            Common.SetMessageList();
        }
        #endregion

        #region < POP_WRK24_Load >
        private void POP_WRK24_Load(object sender, EventArgs e)
        {
            try
            {
                #region --- 언어 설정 → 모듈별로 화면 첫 화면 분기되는 화면에 해당 코드 삽입 ---
                Configuration appConfig = ConfigurationManager.OpenExeConfiguration(ConfigurationUserLevel.None);

                SAMMI.Common.SystemID = appConfig.AppSettings.Settings["SystemID"].Value.ToString();
                SAMMI.Common.Lang = appConfig.AppSettings.Settings["LANGUAGE"].Value.ToString();


                DataTable rtnDtTemp = _common.GET_TBM0000_CODE("LANGKY");

                SAMMI.Common.FontName = Convert.ToString(((DataRow[])rtnDtTemp.Select("CODE_ID = '" + SAMMI.Common.Lang + "'"))[0]["RelCode1"]);

                #endregion

                this.lblTitle.Text = "점보롤 실적등록";

                //공장코드..
                Common.machSetting();

                //테스트 설정 
                //Common.PlantCode = "P100";      // 플랜트 코드
                //Common.OpCode = "JA";           // 공정코드
                //Common.IOType = "N";            // PS=N, 
                //Common.MachineCode = "PJA02";   // 설비호기
                //Common.UserID = "hnw.bmkim";        // user id

                SetMenuButtons();

                DoFind();

                lblEndChk.BackColor = Color.Yellow;
                lblPrintChk.BackColor = Color.Yellow;
            }
            catch (Exception ex)
            {
                SetMessage("POP_WRK24_Load_ Error!");
                LogFile.WriteLog("POP_WRK24.POP_WRK24_Load Error => " + ex.Message);
            }
        }

        #endregion

        #region < METHOD AREA >

        private void CleanOrderLabel()
        {
            lblWO_WRK_ORDR_NO.Text = "";       // 작업지시번호
            lblWO_WRK_ORDR_SEQNO.Text = ""; // 작업지시순번

            lblWO_MATNR.Text = "";           // 자재코드
            lblWO_JROLLCNT.Text = "";      // 계획 권치수
            lblWO_TSPEED.Text = "";        // 목표선속
            lblWO_TOT_WGT.Text = "";          // 중량  
            lblWO_PRD_REQ_DT.Text = "";     // 생산요청일자

            lblWO_PCODE.Text = "";          // 지종
            lblWO_BS_WGT.Text = "";          // 평량
            lblWO_JWIDTH.Text = "";             // 지폭
            giBS_WGT = 0;
            giJWIDTH = 0;
            giNON_ORDR_BS_WGT = 0;


            lblPF_ROLLCNT.Text = "";
            lblPF_MWIDTH.Text = "";
            lblWO_PRFM_ROLLCNT.Text = "";   // 실적권치수
            lblWO_PRFM_WGT.Text = "";      // 실적 중량
            lblWO_DISPO_QTY.Text = "";       // 폐품 중량
            //lblMACH_STA.Text = "대기중";      // 설비 상태

            txtWO_ORDER_RMK.Text = "";
            lblPF_PRFM_DT.Text = "";

            dtpStartDate.Value = dtpEndDate.Value = DateTime.Now;
            lblStartTime.Text = lblEndTime.Text = "";

            //공통사용항목 지시정보 초기화
            Common.OrderNo = string.Empty;//생산오더번호
            Common.WrkOrderNo = string.Empty;//작업지시번호
            Common.WrkOrderSeq = string.Empty;//작업지시순번
            Common.ItemCode = string.Empty; //자재코드
        }



        private void DoFind()
        {
            DBHelper helper = new DBHelper();
            DataTable dtRtn;

            try
            {

                //버튼 목록 조회
                dtRtn = helper.FillTable("SP_POP_WRK24_S01", CommandType.StoredProcedure
                                                    , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)           // 작업장코드(설비코드)
                                                    , helper.CreateParameter("RS_MACH_STA", DbType.String, ParameterDirection.Output, null, 30)                     //  RES MACH_STA
                                                    );

                if (helper.RSCODE == "S" || helper.RSCODE == "E")
                {
                    timer1.Start();

                    bBox1[0, 4].bAlarm = false;

                    string sRS_MACH_STA = helper.Parameters["RS_MACH_STA"].Value.ToString();

                    //가동상태(R :가동, S:비가동, N:대기중)
                    //if (sRS_MACH_STA.Equals("R"))
                    //{
                    //    lblMACH_STA.Text = "가동중";
                    //}
                    //else if (sRS_MACH_STA.Equals("S"))
                    //{
                    //    lblMACH_STA.Text = "비가동";
                    //}
                    //else
                    //{
                    //    lblMACH_STA.Text = "대기중";
                    //}
                    //가동상태(R :가동, S:비가동, N:대기중)
                    if (sRS_MACH_STA.Equals("R"))
                    {
                        lblMACH_STA.Text = "가동중";
                        bBox1[0, 3].Text = "작업시작";
                        bBox1[0, 3].Tag = "Start";
                        bBox1.RedrawButtons();
                        bABNChk = false;
                    }
                    else if (sRS_MACH_STA.Equals("S"))
                    {
                        lblMACH_STA.Text = "비가동";
                        bBox1[0, 3].Text = "작업시작";
                        bBox1[0, 3].Tag = "Start";
                        bBox1.RedrawButtons();
                        //비가동시 점멸처리
                        bABNChk = true;
                    }
                    else
                    {
                        lblMACH_STA.Text = "대기중";
                        bBox1[0, 3].Text = "작업시작";
                        bBox1[0, 3].Tag = "Start";
                        bBox1[0, 3].UseFlag = true;
                        bBox1.RedrawButtons();
                        bABNChk = false;
                    }
                }

                if (dtRtn.Rows.Count == 1)
                {
                    //공통사용항목 관리
                    Common.OrderNo = dtRtn.Rows[0]["ORDER_NO"].ToString();//생산오더번호
                    Common.WrkOrderNo = dtRtn.Rows[0]["WRK_ORDR_NO"].ToString();//작업지시번호
                    Common.WrkOrderSeq = dtRtn.Rows[0]["WRK_ORDR_SEQNO"].ToString();//작업지시순번
                    Common.ItemCode = dtRtn.Rows[0]["MATNR"].ToString(); //자재코드

                    lblWO_WRK_ORDR_NO.Text = Common.WrkOrderNo;       // 작업지시번호
                    lblWO_WRK_ORDR_SEQNO.Text = Common.WrkOrderSeq; // 작업지시순번

                    lblWO_MATNR.Text = Common.ItemCode;           // 자재코드
                    lblWO_JROLLCNT.Text = Common.StrFormatInteger(dtRtn.Rows[0]["JROLLCNT"].ToString());        // 계획 권치수

                    Decimal.TryParse(dtRtn.Rows[0]["TSPEED"].ToString(), out gdTSPEED);
                    lblWO_TSPEED.Text = string.Format("{0:#,##0}", gdTSPEED);          // 목표선속

                    lblWO_TOT_WGT.Text = Common.StrFormatDouble(dtRtn.Rows[0]["ORDR_WGT"].ToString());          // 중량  

                    DateTime dtTime;
                    if (DateTime.TryParseExact(dtRtn.Rows[0]["PRD_REQ_DT"].ToString(), "yyyyMMdd", null, DateTimeStyles.AssumeLocal, out dtTime))
                    {
                        lblWO_PRD_REQ_DT.Text = dtTime.ToShortDateString();        // 생산요청일자
                    }
                    else
                    {
                        lblWO_PRD_REQ_DT.Text = "";
                    }

                    if(DateTime.TryParseExact(dtRtn.Rows[0]["PRD_STR_DTM"].ToString(), "yyyyMMddHHmmss", null, DateTimeStyles.AssumeLocal, out dtTime))
                    {
                        dtpStartDate.Value = dtTime;                                    
                        lblStartTime.Text = dtpStartDate.Value.ToString("HH:mm:ss");       // 작업시작시간

                        dtpEndDate.Value = dtTime;
                        lblEndTime.Text = dtpStartDate.Value.ToString("HH:mm:ss");       // 작업종료시간
                    }
                    else
                    {
                        dtpStartDate.Value = dtpEndDate.Value = DateTime.Now;
                        lblStartTime.Text = lblEndTime.Text = "";
                    }


                    lblWO_PCODE.Text = dtRtn.Rows[0]["PCODE"].ToString(); //지종코드

                    int nData = 0;
                    if (int.TryParse(dtRtn.Rows[0]["BS_WGT"].ToString(), out nData))         // 평량
                    {
                        giBS_WGT = nData;
                        lblWO_BS_WGT.Text = string.Format("{0:#,##0}", nData);
                    }
                    else
                    {
                        giBS_WGT = 0;
                        lblWO_BS_WGT.Text = "0";
                    }

                    nData = 0;
                    if (int.TryParse(dtRtn.Rows[0]["JWIDTH"].ToString(), out nData))         // 지폭
                    {
                        giJWIDTH = nData;
                        lblWO_JWIDTH.Text = string.Format("{0:#,##0}", nData);
                    }
                    else
                    {
                        giJWIDTH = 0;
                        lblWO_JWIDTH.Text = "0";
                    }

                    gsUNIT = dtRtn.Rows[0]["UNIT"].ToString();   // 단위

                    lblWO_PRFM_ROLLCNT.Text = Common.StrFormatInteger(dtRtn.Rows[0]["PRFM_ROLLCNT"].ToString());   // 실적권치수
                    lblWO_PRFM_WGT.Text = Common.StrFormatDouble(dtRtn.Rows[0]["PRFM_WGT"].ToString());      // 실적 중량
                    lblWO_DISPO_QTY.Text = Common.StrFormatDouble(dtRtn.Rows[0]["DISPO_QTY"].ToString());       // 폐품 중량

                    lblPF_MWIDTH.Text = Common.StrFormatInteger(dtRtn.Rows[0]["TOT_MR_WIDTH"].ToString());    // R/W 지폭합

                    txtWO_ORDER_RMK.Text = dtRtn.Rows[0]["ORDER_RMK"].ToString().Replace("|", "\r\n");         // 오더비고

                    //lblWRK_ORDR_RMK.Text = dtRtn.Rows[0]["WRK_ORDR_RMK"].ToString();                        // 작업지시비고

                    // 생산실적일자는 작업시작일을 기준으로 계산 하여 이동 처리
                    //lblWorkDate.Text = Common.GetRecDate(DateTime.Now);                                     // 생산실적일자
                    
                    //lblMACH_STA.Text = dtRtn.Rows[0]["MACH_STA"].ToString();                                // 설비 상태

                    ////가동상태(R :가동, S:비가동, N:대기중)
                    //if (dtRtn.Rows[0]["MACH_STA"].ToString().Equals("R"))
                    //{
                    //    lblMACH_STA.Text = "가동중";
                    //}
                    //else if (dtRtn.Rows[0]["MACH_STA"].ToString().Equals("S"))
                    //{
                    //    lblMACH_STA.Text = "비가동";
                    //}
                    //else
                    //{
                    //    lblMACH_STA.Text = "대기중";
                    //}

                    // 계획권치수 - 실적권치수를 하여 실적등록할권치수에 입력함.
                    int iJROLLCNT = 0;
                    int iPRFM_ROLLCNT = 0;
                    int.TryParse(lblWO_JROLLCNT.Text.ToString().Replace(",", ""), out iJROLLCNT);          // 계획권치수 int
                    int.TryParse(lblWO_PRFM_ROLLCNT.Text.ToString().Replace(",", ""), out iPRFM_ROLLCNT);      // 실적권치수 int

                    giPosROLLCNT = iJROLLCNT - iPRFM_ROLLCNT;
                    if (giPosROLLCNT < 0)
                    {
                        giPosROLLCNT = 0;
                    }

                    lblPF_ROLLCNT.Text = string.Format("{0:#,##0}", giPosROLLCNT);
                    gdROLLCNT = (Decimal)giPosROLLCNT;
                }
                else
                {
                    CleanOrderLabel();
                }

                AutoCalculation();
            }
            catch (Exception ex)
            {
                CleanOrderLabel();
//                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                LogFile.WriteLog("SP_POP_WRK24_S01.DoFind Error => " + ex.Message);
                SetMessage(ex.Message);
            }
        }


        /// <summary>
        /// 설비 및 작업자 선택여부 확인
        /// </summary>
        /// <param name="pType"></param>
        /// <returns></returns>
        private bool SettingCheck(string pType)
        {
            //설비 및 작업자 선택여부 확인
            if (pType.Contains("M") && string.IsNullOrEmpty(Common.MachineCode))
            {
                new POPUP.MessageForm("설비호기를 선택하여 주시기 바랍니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return false;
            }
            if (pType.Contains("W") && string.IsNullOrEmpty(Common.UserID))
            {
                new POPUP.MessageForm("작업자를 선택하여 주시기 바랍니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return false;
            }
            if (pType.Contains("O") && string.IsNullOrEmpty(Common.WrkOrderNo))
            {
                new POPUP.MessageForm("작업지시를 선택하여 주시기 바랍니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return false;
            }

            //비가동 상태 확인
            if (pType.Contains("R") && lblMACH_STA.Text.Equals("비가동")) //가동중 여부 확인
            {
                new POPUP.MessageForm("비가동 중 입니다.\r\n지시 상태를 확인하여 주시기 바랍니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return false;
            }
            // 작업지시 선택 확인
            if (pType.Contains("C") && !lblMACH_STA.Text.Equals("대기중")) //자업지시 선택
            {
                new POPUP.MessageForm("대기중 상태가 아닙니다.\r\n작업 완료후 작업지시 선택하여 주시기 바랍니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return false;
            }
            //지시의 상태 구분
            if (pType.Contains("S") && !lblMACH_STA.Text.Equals("가동중")) //비가동(작업시작버튼 출력중)
            {
                new POPUP.MessageForm("가동중 상태가 아닙니다.\r\n지시 상태를 확인하여 주시기 바랍니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return false;
            }
            

            return true;
        }
        

        /// <summary>
        /// 작업지시 시작
        /// </summary>
        private void doConfirm()
        {
            DBHelper helper = new DBHelper(false);
            string sMSG = string.Empty;
            
            //팝업 변수
            POPUP.MessageForm msgForm = null;
            DialogResult res = DialogResult.Cancel;

            try
            {
                if (!lblMACH_STA.Text.Equals("대기중"))
                {
                    new POPUP.MessageForm("가동중인 작업지시가 있습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return;
                }

                // 작업 시작일시 확인
                string sStartDate = dtpStartDate.Value.ToString("yyyyMMdd") + lblStartTime.Text.ToString().Replace(":", ""); // +"00";
                DateTime dtStartTime;
                if (DateTime.TryParseExact(sStartDate, "yyyyMMddHHmmss", null, DateTimeStyles.AssumeLocal, out dtStartTime) == false)
                {
                    new POPUP.MessageForm("작업 시작일시 확인하세요!", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return;
                }

                msgForm = new POPUP.MessageForm("작업지시를 시작 하시겠습니까?", MessageBoxButtons.OKCancel, "알   림");
                res = msgForm.ShowDialog(this);
                if (res == System.Windows.Forms.DialogResult.OK)
                {
                    //작업시작/완료처리 (작업지시 상태변경 및 작업장 현황의 가동상태 변경)
                    helper.ExecuteNoneQuery("SP_POP_WRK24_I01", CommandType.StoredProcedure
                                                    , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)               // 플랜트
                                                    , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)           // 작업장코드(설비코드)
                                                    , helper.CreateParameter("P_SDATE", sStartDate, DbType.String, ParameterDirection.Input)           // 작업시작시간 변경
                                                    , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input)                 // 사용자ID
                                                    );


                    if (helper.RSCODE == "E")
                    {
                        new POPUP.MessageForm(helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                        return;
                    }

                    sMSG = "작업지시가 정상적으로 시작 되었습니다.";
                    new POPUP.MessageForm(sMSG, MessageBoxButtons.OK, "알   림").ShowDialog(this);

                    lblMACH_STA.Text = "가동중";
                    //SetGrid();
                    //DoFind();
                }
            }
            catch (Exception ex)
            {
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);

                //SetMessage("SetGrid Error!");
                LogFile.WriteLog("POP_WRK24.SetGrid Error => " + ex.Message);
            }
            finally
            {
                helper.Close();
            }
        }


        /// <summary>
        /// 점보롤 실적등록
        /// </summary>
        private bool doProduct()
        {
            DBHelper helper = new DBHelper(false, "", true);
            DataSet dsTemp = new DataSet();     //실적등록 결과 수신(0:RFC 변수, 1:IF 변수)

            int iTM = 0;        // 가동시간
            int.TryParse(lblPF_TM.Text.ToString().Replace(",", ""), out iTM);          // 가동시간

            // 작업일시 확인
            if (string.IsNullOrEmpty(lblPF_PRFM_DT.Text.ToString()) || iTM == 0)
            {
                new POPUP.MessageForm("작업일시 입력은 필수 입니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return false;
            }

            // 권치수 확인
            Decimal.TryParse(lblPF_ROLLCNT.Text.ToString().Replace(",", ""), out gdROLLCNT);      // 등록할권치수 int
            if (gdROLLCNT <= 0)
            {
                new POPUP.MessageForm("권치수 입력은 필수 입니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return false;
            }

            // 실적 등록시 07시 이전에 시작된 작업에 대해서는 07:59분까지만 실적등록 가능.
            string sStartDate = dtpStartDate.Value.ToString("yyyyMMdd") + lblStartTime.Text.ToString().Replace(":", ""); // +"00";
            string sEndDate = dtpEndDate.Value.ToString("yyyyMMdd") + lblEndTime.Text.ToString().Replace(":", ""); // +"00";

            DateTime dtStartTime;
            if (DateTime.TryParseExact(sStartDate, "yyyyMMddHHmmss", null, DateTimeStyles.AssumeLocal, out dtStartTime) == false)
            {
                new POPUP.MessageForm("작업 시작일시 확인하세요!", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return false;
            }

            DateTime dtEndTime;
            if (DateTime.TryParseExact(sEndDate, "yyyyMMddHHmmss", null, DateTimeStyles.AssumeLocal, out dtEndTime) == false)
            {
                new POPUP.MessageForm("작업 종료일시 확인하세요!", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return false;
            }

            string sStartRecDate = Common.GetRecDate(dtStartTime) +  "080000";
            string sEndRecDate = Common.GetRecDate(dtEndTime) + "080000";

            //new POPUP.MessageForm(sStartRecDate + ", " + sEndRecDate, MessageBoxButtons.OK, "알   림").ShowDialog(this);
            if(sStartRecDate != sEndRecDate)
            {
                DateTime dtSRecDate;
                if (DateTime.TryParseExact(sStartRecDate, "yyyyMMddHHmmss", null, DateTimeStyles.AssumeLocal, out dtSRecDate) == false)
                {
                    new POPUP.MessageForm("작업시작일시 오류", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return false;
                }

                DateTime dtERecDate;
                if (DateTime.TryParseExact(sEndRecDate, "yyyyMMddHHmmss", null, DateTimeStyles.AssumeLocal, out dtERecDate) == false)
                {
                    new POPUP.MessageForm("작업종료일시 오류", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return false;
                }

                if ((dtERecDate - dtSRecDate).TotalDays > 1)
                {
                    new POPUP.MessageForm("작업일시가 2일 이상 입니다.\r\n\r\n실적처리가 불가능 합니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return false;
                }

                if ((dtERecDate - dtEndTime).TotalMinutes <= 0)
                {
                    new POPUP.MessageForm("생산실적일자가 바뀐경우는\r\n07시59분 까지만 실적등록 가능 합니다.\r\n\r\n실적처리가 불가능 합니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return false;
                }
                                
            }

            // 목표선속 대비 선속 확인
            string sMsgData = "";
            bool bMsgData = false;
            int iRSPEED = 0;
            int.TryParse(lblPF_RSPEED.Text.ToString().Replace(",", ""), out iRSPEED);  // 선속

            if (iRSPEED >= (gdTSPEED * (Decimal)1.1))
            {
                bMsgData = true;
                sMsgData += "목표선속 대비 실적 선속이 110% 이상 입니다.\r\n";
            }
            else if (iRSPEED <= (gdTSPEED * (Decimal)0.9))
            {
                bMsgData = true;
                sMsgData += "목표선속 대비 실적 선속이 90% 이하 입니다.\r\n";
            }

            // 계획권치수 - 실적권치수를 하여 실적등록할권치수에 입력함.
            int iJROLLCNT = 0;
            int iPRFM_ROLLCNT = 0;
            int.TryParse(lblWO_JROLLCNT.Text.ToString().Replace(",", ""), out iJROLLCNT);          // 계획권치수 int
            int.TryParse(lblWO_PRFM_ROLLCNT.Text.ToString().Replace(",", ""), out iPRFM_ROLLCNT);      // 실적권치수 int

            // 계획권치수 대비 (실적+입력) 권치수 확인
            if ((iPRFM_ROLLCNT + gdROLLCNT) >= (iJROLLCNT * (Decimal)1.1))
            {
                bMsgData = true;
                sMsgData += "계획 권치수 대비 실적 권치수가 110% 이상 입니다.\r\n";
                //sMsgData = "계획 권치수 대비 실적 권치수가 110% 이상입니다.\r\n실적처리가 불가능 합니다.";
                //POPUP.MessageForm msgForm = new POPUP.MessageForm(sMsgData, MessageBoxButtons.OK, "알   림");
                //DialogResult dr = msgForm.ShowDialog(this);
                //return false;
            }
            else if ((iPRFM_ROLLCNT + gdROLLCNT) <= (iJROLLCNT * (Decimal)0.9)) 
            {
                bMsgData = true;
                sMsgData += "계획 권치수 대비 실적 권치수가 90% 이하 입니다.\r\n";
            }

            string sFINISH = "N";
            if (lblEndChk.Text.ToString() == "V")           // 점보롤 완료처리
            {
                sFINISH = "Y";
            }

            // 비계획생산 인지 확인.
            string sNON_ORDR_MATNR = "";
            bool isNonOrder = btnNonOrder.ButtonPressed;    // 비계획 생산 확인 플래그
            if (isNonOrder == true)
            {
                sMsgData = string.Format("비계획생산용 자재코드 {0}\r\n", lblNonOrderCode.Text.ToString());
                sMsgData += string.Format("권치수 {0}M, 중량 {1}KG, 선속{2}M/분\r\n\r\n", lblPF_ROLLCNT.Text.ToString(), lblPF_WGT.Text.ToString(), lblPF_RSPEED.Text.ToString());
                sMsgData += "비계획생산 등록을 하시겠습니까?";

                POPUP.MessageForm msgForm = new POPUP.MessageForm(sMsgData, MessageBoxButtons.OKCancel, "알   림");
                DialogResult dr = msgForm.ShowDialog(this);
                if (dr == DialogResult.Cancel)
                {
                    return false;
                }
                sNON_ORDR_MATNR = lblNonOrderCode.Text.ToString();
                sFINISH = "N";      // 비계획 생산은 항상 완료 플래그를 처리 하며 안됨.
            }
            else
            {
                // 경고 메시지 가 있는경우 개행문자 추가
                if ((bMsgData == true) || (sFINISH == "N"))
                {
                    if (bMsgData == true)
                    {
                        sMsgData += "\r\n";
                    }

                    sMsgData += "점보롤 완료 플래그를 체크 하시겠습니까?";

                    POPUP.MessageForm msgForm = new POPUP.MessageForm(sMsgData, MessageBoxButtons.YesNoCancel, "알   림");
                    DialogResult dr = msgForm.ShowDialog(this);
                    if (dr == DialogResult.Cancel)
                    {
                        return false;
                    }
                    else if (dr == DialogResult.Yes)
                    {
                        sFINISH = "Y";
                    }
                    else
                    {
                        sFINISH = "N";
                    }
                }
            }


            this.Cursor = Cursors.WaitCursor;   //Waitting

            bool bReturn = false;
            string sRES_IND_BCD = "";

            string sMSG_ERR = "";

            //SAP 롤백용 추가 CODE 범위 START
            DataTable sapTemp = new DataTable(); // 성공한 sap 정보 저장
            sapTemp.Columns.Add("SAP_TYPE", typeof(string));
            sapTemp.Columns.Add("IF_KEY", typeof(string));
            sapTemp.Columns.Add("MDOCNO", typeof(string));
            sapTemp.Columns.Add("MDOCSEQ", typeof(string));

            DataTable rollTemp = new DataTable(); // ROLLBACK용 정보 저장
            rollTemp.Columns.Add("MDOCNO", typeof(string));
            rollTemp.Columns.Add("MDOCSEQ", typeof(string));
            //SAP 롤백용 추가 CODE 범위 END

            try
            {
                LogFile.WriteLog("점보롤 실적 등록 시작", LogType.PROC);

                // 점보롤 실적등록
                dsTemp = helper.FillDataSetN("SP_POP_WRK24_I02", CommandType.StoredProcedure, 2
                    , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)                  // 플랜트
                    , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)              // 작업장코드(설비코드)
                    , helper.CreateParameter("P_ROLLCNT", gdROLLCNT, DbType.Double, ParameterDirection.Input)                    // 권치수
                    , helper.CreateParameter("P_WGT", gdWGT, DbType.Double, ParameterDirection.Input)                            // 중량
                    , helper.CreateParameter("P_RSPEED", iRSPEED, DbType.Double, ParameterDirection.Input)                      // 선속
                    , helper.CreateParameter("P_SDATE", sStartDate, DbType.String, ParameterDirection.Input)                // 작업시작시간(YYYYMMDDHHMMSS)
                    , helper.CreateParameter("P_EDATE", sEndDate, DbType.String, ParameterDirection.Input)                  // 작업종료시간(YYYYMMDDHHMMSS)
                    , helper.CreateParameter("P_TM", iTM, DbType.Double, ParameterDirection.Input)                          // 작업시간
                    , helper.CreateParameter("P_PRFM_DT", lblPF_PRFM_DT.Text.ToString().Replace("-", ""), DbType.String, ParameterDirection.Input)                      // 생산실적일자
                    , helper.CreateParameter("P_FINISH", sFINISH, DbType.String, ParameterDirection.Input)          // 완료여부
                    , helper.CreateParameter("P_MATNR", sNON_ORDR_MATNR, DbType.String, ParameterDirection.Input)          // 비계획생산용 자재코드
                    , helper.CreateParameter("P_RMK", lblPF_WRK_ORDR_RMK.Text.ToString(), DbType.String, ParameterDirection.Input)                         // 비고
                    , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input)                     // 사용자ID
                    , helper.CreateParameter("RS_IND_BCD", DbType.String, ParameterDirection.Output, null, 200)                     //  RES 개별바코드 
                    , helper.CreateParameter("RS_RFCFN", DbType.String, ParameterDirection.Output, null, 30)                     //  RES RFCFN
                    );

                if (helper.RSCODE == "S")
                {
                    string sRfcData; //RFC결과 JSON 변환

                    string sRS_RFCFN = helper.Parameters["RS_RFCFN"].Value.ToString();
                    sRES_IND_BCD = helper.Parameters["RS_IND_BCD"].Value.ToString();

                    //SAP 롤백용 추가 CODE 범위 START
                    string rollTempMDOC_NO_1 = dsTemp.Tables[1].Rows[0]["MDOCNO"].ToString();
                    string rollTempMDOC_SEQNO_1 = dsTemp.Tables[1].Rows[0]["MDOCSEQ"].ToString();
                    rollTemp.Rows.Add(rollTempMDOC_NO_1, rollTempMDOC_SEQNO_1);
                    //SAP 롤백용 추가 CODE 범위 END

                    //SAP 실적 등록
                    SAPHelper sapRFC = new SAPHelper();
                    // sapRFC.CallSAPFunc_PS 호출시 helper를 사용하여 내용이 변경됨. 
                    // 필요한 정보는 sapRFC.CallSAPFunc_PS 호출전에 처리해야함.
                    if (sapRFC.CallSAPFunc_PS(sRS_RFCFN, dsTemp.Tables[0], dsTemp.Tables[1], helper).Equals("S"))
                    {
                        // ---- 전달시 MBLNR, MJAHR을 replace 처리하여 하나로 받도록함.
                        sRfcData = Common.toJsonFormat("PUT_WRKRTN", sapRFC.rtnTable).Replace("MBLNR", "RUECK").Replace("MJAHR", "RMZHL");
                        
                        //SAP 롤백용 추가 CODE 범위 START
                        string sTempSAP_TYPE = string.Empty;
                        string sTempIF_KEY = string.Empty;
                        string sTempMDOC_NO = string.Empty;
                        string sTempMDOC_SEQNO = string.Empty;

                        sTempSAP_TYPE   = "3.PROD_REG_SAP";
                        sTempIF_KEY     = dsTemp.Tables[0].Rows[0]["I_IF_KEY"].ToString();
                        sTempMDOC_NO    = dsTemp.Tables[1].Rows[0]["MDOCNO"].ToString();
                        sTempMDOC_SEQNO = dsTemp.Tables[1].Rows[0]["MDOCSEQ"].ToString();

                        sapTemp.Rows.Add(sTempSAP_TYPE, sTempIF_KEY, sTempMDOC_NO, sTempMDOC_SEQNO); // 후단 코드 실행시 EXCEPTION 상황 SAP CANCLE 정보 -- 실적등록
                        //SAP 롤백용 추가 CODE 범위 END

                        //실적등록 테이블에 확정문서 번호 갱신
                        helper.ExecuteNoneQuery("SP_IF_PUT_WRKRTN", CommandType.StoredProcedure
                                                            , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)              // 플랜트
                                                            , helper.CreateParameter("P_WRK_TYPE", "0", DbType.String, ParameterDirection.Input)                        // '0'= 실적테이블, 비계획생산, '1'= 폐품테이블, '2'=소요량, '3'=비가동,
                                                            , helper.CreateParameterOracle("P_RFC_DATA", sRfcData, OracleDbType.Clob, ParameterDirection.Input)         
                                                            , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input));

                        if (helper.RSCODE == "S")
                        {
                            bReturn = true;
                            //helper.Commit();
                        }
                        else //if (helper.RSCODE == "E")
                        {
                            //helper.Rollback();

                            LogFile.WriteLog("점보롤 실적 등록 - SAP 확정문서 등록 오류 [" + helper.RSMSG.ToString() + "]");
                            LogFile.WriteLog("@@@ else 점보롤 실적 등록 - SAP 확정문서 등록 오류 [ 개별바코드 : " + sRES_IND_BCD + "]");
                            sMSG_ERR += "확정문서 등록 오류 : " + helper.RSMSG.ToString() + Environment.NewLine;
                            throw new Exception("SAP_ERROR " + sMSG_ERR);  // SAP 로직 진행중 E 발생시 EXCEPTION THROW
                            //new POPUP.MessageForm("실적 등록 - SAP 확정문서 등록 오류\r\n" + helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                        }
                    }
                    else
                    {
                        //helper.Rollback();

                        LogFile.WriteLog("점보롤 실적 등록 - SAP전송 실패 [" + sapRFC.rtnMSG + "]");
                        LogFile.WriteLog("@@@ else 점보롤 실적 등록 - SAP전송 실패 [ 개별바코드 : " + sRES_IND_BCD + "]");
                        sMSG_ERR += "실적 등록 오류 : " + sapRFC.rtnMSG + Environment.NewLine;
                        throw new Exception("SAP_ERROR " + sMSG_ERR);
                    }
                }
                else
                {
                    LogFile.WriteLog("점보롤 실적 등록 실패 [" + helper.RSMSG.ToString() + "]");
                    LogFile.WriteLog("@@@ else 점보롤 실적 등록 실패 [ 개별바코드 : " + sRES_IND_BCD + "]");
                    new POPUP.MessageForm("실적 등록 실패\r\n" + helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    bReturn = false;
                    return false;
                }

                //if (bReturn == true)
                {
                    if (lblPrintChk.Text.ToString() == "V")     // 자동인쇄 처리
                    {
                        PrinterManager.PrintJumboRoll(sRES_IND_BCD);
                    }

                    this.Cursor = Cursors.Default;   //Waitting

                    if (sMSG_ERR.Length > 0)
                    {
                        throw new Exception("SAP_ERROR " + sMSG_ERR);
                    }
                    else
                    {
                        if (isNonOrder == false)
                        {
                            LogFile.WriteLog("점보롤 실적등록 성공", LogType.PROC);
                            new POPUP.MessageForm("실적등록 완료 되었습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                        }
                        else
                        {
                            LogFile.WriteLog("점보롤 비계획 실적등록 성공", LogType.PROC);
                            new POPUP.MessageForm("비계획 실적등록 완료 되었습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                sMSG_ERR = "";
                if (rollTemp.Rows.Count != 0)
                {
                    SetMessagePos("오류 발생하여 롤백 처리중 입니다.");
                    System.Windows.Forms.Application.DoEvents();        // 반복작업중 응답없음 안뜨게 하기

                    ProdRollback(helper, sapTemp, rollTemp, dsTemp, ref sMSG_ERR);
                }

                this.Cursor = Cursors.Default;   //Waitting
                LogFile.WriteLog("점보롤 실적등록 예외 오류 [" + ex.ToString() + "]");
                LogFile.WriteLog("@@@ catch 점보롤 실적등록 예외 오류 [ 개별바코드 : " + sRES_IND_BCD + "]");
                new POPUP.MessageForm_ERR("실적등록 오류", "실적등록 예외 오류\r\n" + ex.Message.ToString() + Environment.NewLine + sMSG_ERR, MessageBoxButtons.OK).ShowDialog(this);
            }
            finally
            {
                this.Cursor = Cursors.Default;   //Waitting
                helper.Close();
            } 

            return bReturn;
        }

        private void ProdRollback(DBHelper helper, DataTable sapTemp, DataTable rollTemp, DataSet dsTemp, ref string sMSG_ERR) 
        {

            try
            {
                string rsRfcData; //RFC결과 JSON 변환
                string notUseIF_ID_1 = string.Empty;
                string notUseIF_ID_2 = string.Empty;
                string notUseIF_ID_3 = string.Empty;
                string notUseIF_ID_4 = string.Empty;

                Thread.Sleep(Common.SLEEP_ROLLBACK_DELAY);               // 2초 대기
                System.Windows.Forms.Application.DoEvents();        // 반복작업중 응답없음 안뜨게 하기
                this.Cursor = Cursors.WaitCursor;   //Waitting

                // 1.  미사용 I/F 플래그 변경. 인터페이스 테이블에 ZRESULT 가 'N' -> 'R'로 변경
                // 1.1 실적 인터페이스
                if (dsTemp.Tables[0].Rows[0][0].ToString() != "1")
                {
                    notUseIF_ID_1 = dsTemp.Tables[0].Rows[0]["I_IF_ID"].ToString();
                    foreach (DataRow notUseRows in dsTemp.Tables[1].Rows)
                    {
                        helper.ExecuteNoneQuery("SP_IF_NOT_USE_FLAG", CommandType.StoredProcedure
                            , helper.CreateParameter("P_MES_IF_ID", notUseIF_ID_1, DbType.String, ParameterDirection.Input)
                            , helper.CreateParameter("P_DOC_NO", notUseRows["MDOCNO"].ToString(), DbType.String, ParameterDirection.Input)
                            , helper.CreateParameter("P_DOC_SEQNO", notUseRows["MDOCSEQ"].ToString(), DbType.String, ParameterDirection.Input)
                            , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input));
                    }
                }

                LogFile.WriteLog("=====SAP ROLLBACK BEFORE=====", LogType.PROC);
                LogFile.WriteLog("===== " + sapTemp.Rows.Count + " =====", LogType.PROC);
                // 2. SAP로 ROLLBACK 전송
                // 조건문 기준이 이렇게되면안될듯함 //SAPHELPER에서 RETURN 값이없는경우에는 실적등록 IF문내부로 안들어가므로 당연히 sapTemp도 없기때문에 롤백시키지 않음 ...
                if (sapTemp.Rows.Count != 0)
                {
                    sapTemp = sapTemp.Select("", "SAP_TYPE ASC").CopyToDataTable<DataRow>();

                    if (dsTemp.Tables[0].Rows.Count > 0)
                    {
                        LogFile.WriteLog(dsTemp.Tables[0].Rows[0]["I_IF_ID"].ToString(), LogType.PROC);
                    }


                    foreach (DataRow Rows in sapTemp.Rows)
                    {
                        //LogFile.WriteLog("점보롤 실적등록 예외 오류 [" + ex.ToString() + "]");
                        LogFile.WriteLog("=====SAP ROLLBACK START=====", LogType.PROC);
                        System.Windows.Forms.Application.DoEvents();        // 반복작업중 응답없음 안뜨게 하기

                        switch (Rows["SAP_TYPE"].ToString())
                        {
                            // 2.3  실적 ROLLBACK
                            case "3.PROD_REG_SAP":
                                LogFile.WriteLog("=====3.PROD_REG_SAP=====" + Rows["MDOCNO"].ToString() + "-" + Rows["MDOCSEQ"].ToString(), LogType.PROC);
                                //
                                dsTemp = helper.FillDataSetN("SP_POP_WRK24_IFR01", CommandType.StoredProcedure, 2
                                       , helper.CreateParameter("P_DOC_NO", Rows["MDOCNO"].ToString(), DbType.String, ParameterDirection.Input)
                                       , helper.CreateParameter("P_DOC_SEQNO", Rows["MDOCSEQ"].ToString(), DbType.String, ParameterDirection.Input)
                                       , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input)
                                       , helper.CreateParameter("RS_RFCFN", DbType.String, ParameterDirection.Output, null, 30)
                                        );
                                string sRS_RFCFN = helper.Parameters["RS_RFCFN"].Value.ToString();
                                SAPHelper sapRFC = new SAPHelper();
                                if (sapRFC.CallSAPFunc_PS(sRS_RFCFN, dsTemp.Tables[0], dsTemp.Tables[1], helper).Equals("S"))
                                {
                                    rsRfcData = Common.toJsonFormat("PUT_WRKRTN", sapRFC.rtnTable).Replace("MBLNR", "RUECK").Replace("MJAHR", "RMZHL");
                                    helper.ExecuteNoneQuery("SP_IF_PUT_WRKRTN", CommandType.StoredProcedure
                                    , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)              // 플랜트
                                    , helper.CreateParameter("P_WRK_TYPE", "0", DbType.String, ParameterDirection.Input)                        // '0'= 실적테이블, 비계획생산, '1'= 폐품테이블, '2'=소요량, '3'=비가동,
                                    , helper.CreateParameterOracle("P_RFC_DATA", rsRfcData, OracleDbType.Clob, ParameterDirection.Input)
                                    , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input));

                                    if (helper.RSCODE == "S")
                                    {
                                        LogFile.WriteLog("점보롤 실적등록 ROLLBACK COMPLETE", LogType.PROC);
                                    }
                                    else //if (helper.RSCODE == "E")
                                    {
                                        LogFile.WriteLog("점보롤 ROLLBACK 등록 - SAP 확정문서 등록 오류 [" + helper.RSMSG.ToString() + "]");
                                        sMSG_ERR += "ROLLBACK 확정문서 등록 오류 : " + helper.RSMSG.ToString() + Environment.NewLine;
                                    }
                                }
                                else
                                {
                                    LogFile.WriteLog("점보롤 ROLLBACK 오류 - SAP전송 오류 [" + sapRFC.rtnMSG + "]");
                                    sMSG_ERR += "점보롤 ROLLBACK 오류 : " + sapRFC.rtnMSG + Environment.NewLine;
                                }
                                break;

                            default:
                                break;
                        }

                        LogFile.WriteLog("=====SAP ROLLBACK END=====", LogType.PROC);
                    }

                }

            }
            catch (Exception ex)
            {
                LogFile.WriteLog("ProdRollback 오류" + ex.Message.ToString());
                sMSG_ERR += "ProdRollback 오류" + ex.Message.ToString();
            }
            finally
            {
                try//MES롤백구간
                {
                    helper.Commit();

                    if (rollTemp.Rows.Count != 0)
                    {
                        foreach (DataRow Rows in rollTemp.Rows)
                        {
                            LogFile.WriteLog("=====MES ROLLBACK START=====" + Rows["MDOCNO"].ToString() + "-" + Rows["MDOCSEQ"].ToString(), LogType.PROC);

                            helper.ExecuteNoneQuery("SP_POP_WRK24_R01", CommandType.StoredProcedure
                           , helper.CreateParameter("P_DOC_NO", Rows["MDOCNO"].ToString(), DbType.String, ParameterDirection.Input)
                           , helper.CreateParameter("P_DOC_SEQNO", Rows["MDOCSEQ"].ToString(), DbType.String, ParameterDirection.Input)
                           , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input));
                            LogFile.WriteLog("=====MES ROLLBACK END=====" + Rows["MDOCNO"].ToString() + "-" + Rows["MDOCSEQ"].ToString(), LogType.PROC);
                        }
                    }
                    sMSG_ERR += "점보롤 MES ROLLBACK 실적이 취소되었습니다" + Environment.NewLine;
                    LogFile.WriteLog("점보롤 MES ROLLBACK COMPLETE", LogType.PROC);
                }
                catch(Exception ex1)
                {
                    LogFile.WriteLog("점보롤 MES ROLLBACK 오류 [" + ex1.Message.ToString() + "]");
                    sMSG_ERR += "점보롤 MES ROLLBACK 오류 : " + ex1.Message.ToString() + Environment.NewLine;
                }
            }
        }



        private void SetMenuButtons()
        {
            try
            {
                //메인버튼 설정
                bBox1.ButtonBoxType = ButtonBox.ButtonBoxTypeEnum.Buttons;
                bBox1.SelectionMode = ButtonBox.SelectionModeEnum.Single;

                bBox1.CountX = 11;
                bBox1.CountY = 1;

                bBox1.SetButtons();

                bBox1[0, 0].Text = "작업지시" + Environment.NewLine + "선택";
                bBox1[0, 0].Tag = "Order";
                bBox1[0, 0].MappingButton.FontSize = 14;
                bBox1[0, 1].Text = "작업자" + Environment.NewLine + "선택";
                bBox1[0, 1].Tag = "Worker";
                bBox1[0, 1].MappingButton.FontSize = 14;
                bBox1[0, 2].Text = "설비선택";
                bBox1[0, 2].Tag = "Machine";
                bBox1[0, 2].MappingButton.FontSize = 14;
                bBox1[0, 3].Text = "작업시작";
                bBox1[0, 3].Tag = "Start";
                bBox1[0, 3].MappingButton.FontSize = 14;
                bBox1[0, 4].Text = "비가동" + Environment.NewLine + "등록";
                bBox1[0, 4].Tag = "NonOper";
                bBox1[0, 4].MappingButton.FontSize = 14;
                bBox1[0, 5].Text = "실적등록";
                bBox1[0, 5].Tag = "Product";
                bBox1[0, 5].MappingButton.FontSize = 14;
                bBox1[0, 6].Text = "폐품등록";
                bBox1[0, 6].Tag = "Dispo";
                bBox1[0, 6].MappingButton.FontSize = 14;
                bBox1[0, 7].Text = "공정체크"; //"공정투입";
                bBox1[0, 7].Tag = "Check"; //"Input";
                bBox1[0, 7].MappingButton.FontSize = 14;
                bBox1[0, 8].Text = ""; // "공정체크";
                bBox1[0, 8].Tag = ""; // "Check";
                bBox1[0, 8].MappingButton.FontSize = 14;
                bBox1[0, 9].Text = ""; // "자재투입" + Environment.NewLine + "이력";
                bBox1[0, 9].Tag = ""; // "InputLog";
                bBox1[0, 9].MappingButton.FontSize = 14;
                bBox1[0, 10].Text = "실적현황";
                bBox1[0, 10].Tag = "Performance";
                bBox1[0, 10].MappingButton.FontSize = 14;

                bBox1.RedrawButtons();
            }
            catch (Exception ex)
            {
                SetMessage("SetButtons Error!");
                LogFile.WriteLog("DA0100.SetButtons Error => " + ex.Message);
            }
        }
        #endregion

        #region < EVNET >

        private void bBox1_buttonClickEvent(MESButton sender, ButtonBox.ButtonClickEventArg e)
        {
            try
            {
                bool isRefresh = false;

                if (!this.bUseNetwork)
                {
                    SetMessage("네트워크 상태를 확인하시기 바랍니다.");
                    return;
                }

                MESButton btn = sender;

                switch (btn.Tag.ToString())
                {
                    case "Order": //작업지시 선택
                        if (SettingCheck("MR"))
                        {
                            //비가동 상태 확인
                            //if (lblMACH_STA.Text.Equals("가동중")) //가동중 여부 확인
                            //{
                            //    new POPUP.MessageForm("가동중 상태에서는 작업지시를 변경할수 없습니다.\r\n작업 완료후 작업지시 변경 바랍니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                            //}
                            //else
                            {
                                POP_WRK07 WRK07 = new POP_WRK07(Common.OpCode, Common.IOType);
                                if (ShowDialogForm(WRK07) == DialogResult.OK)
                                {
                                    //InitProduct();
                                    isRefresh = true;
                                }
                                else
                                {
                                    isRefresh = false;
                                }

                            }
                        }

                        break;
                    case "Worker":  //작업자 선택
                        if (SettingCheck("M"))
                        {
                            POP_WRK05 WRK05 = new POP_WRK05(Common.MachineCode, Common.IOType);
                            ShowDialogForm(WRK05);
                            isRefresh = false;
                        }
                        break;
                    case "Machine": //설비선택
                        POP_WRK02 WRK02 = new POP_WRK02();

                        if (ShowDialogForm(WRK02) == DialogResult.OK)
                            isRefresh = true;
                        else
                            isRefresh = false;

                        break;
                    case "Start": //작업시작
                        if (SettingCheck("MWOR"))
                        {
                            doConfirm();
                            isRefresh = false;
                        }
                        break;
                    case "Stop": //정지
                        break;
                    case "NonOper": //비가동등록
                        if (SettingCheck("MW"))
                        {
                            POP_WRK03 WRK03 = new POP_WRK03();
                            ShowDialogForm(WRK03);
                            isRefresh = true;
                        }
                        break;
                    case "Product": //실적등록
                        if (SettingCheck("MWOSR"))
                        {
                            if (doProduct())
                            {
                                //lblEndChk.Text = lblPrintChk.Text = "V";
                                //lblEndChk.BackColor = lblPrintChk.BackColor = Color.Yellow;
                                lblEndChk.Text = "V";
                                lblEndChk.BackColor = Color.Yellow;

                                lblPF_WRK_ORDR_RMK.Text = "";

                                btnNonOrder.Text = "비계획생산";
                                btnNonOrder.ButtonPressed = false;
                                lblNonOrderCode.Text = "";
                                lblNonOrderName.Text = "";
                                lblNonOrderBS_WGT.Text = "";
                             
                            }

                            isRefresh = true;
                        }
                        break;

                    case "Dispo": //폐품등록
                        if (SettingCheck("MWOSR"))
                        {

                            DateTime dtStartTime;
                            DateTime dtEndTime;

                            DateTime dtNow = DateTime.Now;

                            if (lblStartTime.Text.Contains(":"))
                            {
                                string sStartDate = dtpStartDate.Value.ToString("yyyyMMdd") + lblStartTime.Text.ToString().Replace(":", ""); // +"00";

                                if (DateTime.TryParseExact(sStartDate, "yyyyMMddHHmmss", null, DateTimeStyles.AssumeLocal, out dtStartTime) == false)
                                {
                                    dtStartTime = dtNow;
                                }
                            }
                            else
                            {
                                dtStartTime = dtNow;
                            }

                            if (lblStartTime.Text.Contains(":"))
                            {
                                string sEndDate = dtpEndDate.Value.ToString("yyyyMMdd") + lblEndTime.Text.ToString().Replace(":", ""); // +"00";
                                if (DateTime.TryParseExact(sEndDate, "yyyyMMddHHmmss", null, DateTimeStyles.AssumeLocal, out dtEndTime) == false)
                                {
                                    dtEndTime = dtNow;
                                }
                            }
                            else
                            {
                                dtEndTime = dtNow;
                            }

                            // 시작일시, 종료일시, 평량, 지폭, 단위, 실적중량, 폐품중량
                            POP_WRK36 WRK36 = new POP_WRK36(dtStartTime, dtEndTime, giBS_WGT, giJWIDTH, gsUNIT, lblWO_PRFM_WGT.Text.ToString(), lblWO_DISPO_QTY.Text.ToString());
                            if (ShowDialogForm(WRK36) == DialogResult.OK)
                            {
                                //string strData = WRK85.ResultString;
                                //MessageForm msgForm = new POPUP.MessageForm("비고수정이 완료되었습니다.\r\n", MessageBoxButtons.OK, "알   림");
                                //msgForm.ShowDialog(this);
                                isRefresh = true;
                            }
                            else
                            {
                                isRefresh = false;
                            }
                        }
                        break;
                    //case "Input": //밀로 공정투입 테스트
                    //    break;
                    case "Check": //공정체크
                        if (SettingCheck("MW"))
                        {
                            POP_WRK04 WRK04 = new POP_WRK04();
                            ShowDialogForm(WRK04);
                            isRefresh = false;
                        }
                        break;
                    case "InputLog": //자재투입이력
                        //POP_INV02 INV02 = new POP_INV02();
                        //ShowDialogForm(INV02);
                        break;
                    case "Performance": //실적현황
                        POP_WRK30 WRK30 = new POP_WRK30(Common.OpCode, Common.MachineCode);
                        if (ShowDialogForm(WRK30) == DialogResult.OK)
                            isRefresh = true;
                        else
                            isRefresh = false;
                        break;

                    default:
                        isRefresh = false;
                        break;
                }

                if (isRefresh == true)
                {
                    DoFind();
                }
            }
            catch (Oracle.ManagedDataAccess.Client.OracleException oe)
            {
                SetMessage(oe.Message);
            }

            catch (Exception ex)
            {
                SetMessage(ex.Message);
                LogFile.WriteLog("POP_WRK24.bBox1_buttonClickEvent Error => " + ex.Message);
            }
            finally
            {

            }
        }

        private void btnCancel_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        //private void lblNonOrder_Click(object sender, EventArgs e)
        //{
        //    if (string.IsNullOrEmpty(lblNonOrder.Text))
        //    {
        //        lblNonOrder.Text = string.Empty;
        //        lblNonOrder.BackColor = Color.White;
        //    }
        //    else
        //    {
        //        lblNonOrder.Text = "V";
        //        lblNonOrder.BackColor = Color.Yellow;

        //        POP_ItemSelect pop = new POP_ItemSelect();
        //        pop.ShowDialog(this);
        //    }
        //}

        private void btnNonOrder_Click(object sender, EventArgs e)
        {
            if (btnNonOrder.ButtonPressed == true)
            {
                POP_WRK80 pop = new POP_WRK80("");
                pop.ShowDialog(this);
                if (pop.DialogResult == DialogResult.OK)
                {
                    lblNonOrderCode.Text = pop.ResultMATNR;
                    lblNonOrderName.Text = pop.ResultMATNR_NM;
                    btnNonOrder.Text = "비계획생산 취소";

                    int nData = 0;
                    if (int.TryParse(pop.ResultBS_WGT, out nData))         // 평량
                    {
                        giNON_ORDR_BS_WGT = nData;
                        lblNonOrderBS_WGT.Text = string.Format("{0:#,##0}", nData);
                    }
                    else
                    {
                        giNON_ORDR_BS_WGT = 0;
                        lblNonOrderBS_WGT.Text = "";
                    }
                }
                else
                {
                    btnNonOrder.ButtonPressed = false;
                }
            }
            else
            {
                new POPUP.MessageForm("비계획 생산을 취소 했습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);

                btnNonOrder.Text = "비계획생산";
                btnNonOrder.ButtonPressed = false;
                
                lblNonOrderCode.Text = "";
                lblNonOrderName.Text = "";
                lblNonOrderBS_WGT.Text = "";
            }

            AutoCalculation();
        }

        // 시간 팝업
        private void lblWorkTime_Click(object sender, EventArgs e)
        {
            MESLabel lblTemp = (MESLabel)sender;
            DAResultTime pop = new DAResultTime("HHmmss");  // 점보롤은 시분초입력
            pop.ShowDialog(this);
            if (pop.DialogResult == DialogResult.OK)
            {
                lblTemp.Text = pop.ResultString.ToString();
                AutoCalculation();
            }
        }

        // 날짜 팝업
        private void butStartDate_Click(object sender, EventArgs e)
        {
            DAResultDate pop = new DAResultDate(dtpStartDate.Value);
            pop.ShowDialog(this);
            if (pop.DialogResult == DialogResult.OK)
            {
                string strDate = pop.ResultString.ToString();
                dtpStartDate.Value = DateTime.Parse(strDate);
                //AutoCalculation();    // dtpDate_ValueChanged 이벤트가 발생하여 주석처리
            }
        }

        private void butEndDate_Click(object sender, EventArgs e)
        {
            DAResultDate pop = new DAResultDate(dtpEndDate.Value);
            pop.ShowDialog(this);
            if (pop.DialogResult == DialogResult.OK)
            {
                string strDate = pop.ResultString.ToString();
                dtpEndDate.Value = DateTime.Parse(strDate);
                //AutoCalculation();    // dtpDate_ValueChanged 이벤트가 발생하여 주석처리
            }
        }


        private void dtpDate_ValueChanged(object sender, EventArgs e)
        {
            AutoCalculation();
        }

        private void lblROLLCNT_Click(object sender, EventArgs e)
        {
            DAResultQty pop = new DAResultQty();
            pop.LabelTitle = "권치수 입력";
            pop.LabelHeader = "권치수(M)";
            pop.ContentMaxLength = 8;

            pop.ShowDialog(this);

            if (pop.DialogResult == DialogResult.OK)
            {
                gdROLLCNT = Convert.ToDecimal(pop.ResultDouble);
                lblPF_ROLLCNT.Text = string.Format("{0:#,0}", gdROLLCNT);
                AutoCalculation();
            }

        }

        #endregion
        // 가동시간 / 선속 / 중량 계산
        private void AutoCalculation()
        {
            DateTime dtStartDate;
            DateTime dtEndDate;

            try
            {

                WgtCalculation();


                if ((lblStartTime.Text.ToString().Length != 8) || (lblEndTime.Text.ToString().Length != 8))
                {
                    lblPF_PRFM_DT.Text = "";                   // 생산실적일자
                    lblPF_TM.Text = "0";       // 가동시간
                    lblPF_RSPEED.Text = "0";   // 선속
                    return;
                }

                string sStartDate = dtpStartDate.Value.ToString("yyyy-MM-dd") + " " + lblStartTime.Text.ToString(); // +":00";
                if (Common.IsDateTime(sStartDate) == false)
                {
                    lblPF_PRFM_DT.Text = "";                   // 생산실적일자
                    lblPF_TM.Text = "0";       // 가동시간
                    lblPF_RSPEED.Text = "0";   // 선속
                    return;
                }

                string sEndDate = dtpEndDate.Value.ToString("yyyy-MM-dd") + " " + lblEndTime.Text.ToString(); // +":00";
                if (Common.IsDateTime(sEndDate) == false)
                {
                    lblPF_PRFM_DT.Text = "";                   // 생산실적일자
                    lblPF_TM.Text = "0";       // 가동시간
                    lblPF_RSPEED.Text = "0";   // 선속
                    return;
                }

                dtStartDate = Convert.ToDateTime(sStartDate);
                dtEndDate = Convert.ToDateTime(sEndDate);

                TimeSpan Diff_dates = dtEndDate.Subtract(dtStartDate);


                if (Diff_dates.TotalMinutes > 0)
                {
                    //lblPRFM_DT.Text = Common.GetRecDate(dtStartDate);                   // 생산실적일자
                    string sDate = Common.GetRecDate(dtStartDate);
                    if (string.IsNullOrEmpty(sDate) == false)
                    {
                        try
                        {
                            lblPF_PRFM_DT.Text = DateTime.ParseExact(sDate, "yyyyMMdd", null).ToString("yyyy-MM-dd");
                        }
                        catch (FormatException)
                        {
                            Console.WriteLine("{0} is not in the correct format.", sDate);
                            lblPF_PRFM_DT.Text = "";
                        }
                    }

                    lblPF_TM.Text = string.Format("{0:#,0}", Diff_dates.TotalMinutes);                                 // 가동시간
                    lblPF_RSPEED.Text = string.Format("{0:#,0}", (int)((gdROLLCNT / Convert.ToDecimal(Diff_dates.TotalMinutes))/*+(Decimal)0.5*/));     // 선속
                    SetMessage("");
                }
                else
                {
                    lblPF_PRFM_DT.Text = "";                   // 생산실적일자
                    lblPF_TM.Text = "0";           // 가동시간
                    lblPF_RSPEED.Text = "0";       // 선속
                    //SetMessage("작업 시작일시/종료일시를 확인하세요!");
                }
            }
            catch (Exception ex)
            {
                LogFile.WriteLog("점보롤 AutoCalculation Error => " + ex.Message);
            }
        }

        // 중량 계산
        private void WgtCalculation()
        {

            Decimal dBS_WGT = 0;

            if (btnNonOrder.ButtonPressed == false)
            {
                dBS_WGT = (Decimal)giBS_WGT;                 // 평량
            }
            else
            {
                dBS_WGT = (Decimal)giNON_ORDR_BS_WGT;        // 비계획생산 평량
            }


            if (dBS_WGT <= 0 || giJWIDTH <= 0 || gdROLLCNT <= 0)
            {
                lblPF_WGT.Text = "0";
                gdWGT = 0;
                return;
            }

            Decimal dValue = (dBS_WGT / 1000) * ((Decimal)giJWIDTH / 1000) * (Decimal)gdROLLCNT;

            lblPF_WGT.Text = string.Format("{0:#,0.###}", dValue);
            gdWGT = dValue;      // 중량
        }

        private void btnDetail_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(Common.WrkOrderNo))
            {
                return;
            }

            //public static string PROC_INP = "PROC_INP";        // 작업지시선택 투입정보
            //public static string PROC_WRK = "PROC_WRK";        // 주작업 표시 정보
            POP_WRK84 popWrk84 = new POP_WRK84(POP_WRK84.PROC_WRK, Common.PlantCode, Common.OpCode, Common.WrkOrderNo, Common.WrkOrderSeq);  // 작업지시 정보
            //popWrk84.LabelTitle = "작업지시 정보";
            ShowDialogForm(popWrk84);
        }

        private void lblRemark_Click(object sender, EventArgs e)
        {
            DAResultText pop = new DAResultText("점보롤 비고입력", lblPF_WRK_ORDR_RMK.Text.ToString());
            pop.ContentMaxLength = 100;

            pop.ShowDialog(this);
            if (pop.DialogResult == DialogResult.OK)
            {
                lblPF_WRK_ORDR_RMK.Text = pop.ResultString;
            }
        }

        private void lblEndChk_Click(object sender, EventArgs e)
        {
            if (lblEndChk.Text.ToString().Equals("V"))
            {
                lblEndChk.Text = "";
                lblEndChk.BackColor = Color.White;
            }
            else
            {
                lblEndChk.Text = "V";
                lblEndChk.BackColor = Color.Yellow;
            }
        }

        private void lblPrintChk_Click(object sender, EventArgs e)
        {
            if (lblPrintChk.Text.ToString().Equals("V"))
            {
                lblPrintChk.Text = "";
                lblPrintChk.BackColor = Color.White;
            }
            else
            {
                lblPrintChk.Text = "V";
                lblPrintChk.BackColor = Color.Yellow;
            }

        }

        private void dtpDate_DropDown(object sender, EventArgs e)
        {
            CommonCalendar.CloseCalendar((DateTimePicker)sender);
        }

        private void timer1_Tick(object sender, EventArgs e)
        {
            if (bABNChk)
            {
                bBox1[0, 4].bAlarm = bBox1[0, 4].bAlarm ? false : true;
                bBox1.RedrawButtons();
            }

            //iReSetCnt++;
            //if (iReSetCnt % 60 == 0)
            //{
            //    //SetGrid();
            //    DoFind();
            //    iReSetCnt = 0;
            //}
        }
    }
}
