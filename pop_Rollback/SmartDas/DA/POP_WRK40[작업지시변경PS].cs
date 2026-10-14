#region [ USING AREA ]
using System;
using System.Configuration;
using System.Data;
using System.Windows.Forms;


using SAMMI;
using SmartDas.Components;
using SmartDas.POPUP;
using System.Globalization;
#endregion

namespace SmartDas
{
    public partial class POP_WRK40 : BaseForm
    {
        #region < MEMBER AREA >
        private string sStartTime = string.Empty;

        private SAMMI.Common _common = new SAMMI.Common();


        private string sMachCode = string.Empty;
        private string sIOType = string.Empty;
        private string sWorker = string.Empty;
        private string sNewWrkOrder = string.Empty;
        private string sNewWrkOrderSeq = string.Empty;
        private DataTable dtWrkOrder; //작업정보 조회
        private DataRow drNowWrk; //기본 작업정보
        private DataRow drNewWrk; //신규 작업정보


        public static string userID = string.Empty;
        public static string userName = string.Empty;

        #endregion

        #region < CONSTRUCTOR >

        public POP_WRK40()
        {
            InitializeComponent();

            Common.SetMessageList();

        }

        public POP_WRK40(string WrkOrderNo, string WrkOrderSeq)
        {
            InitializeComponent();

            Common.SetMessageList();

            sMachCode = Common.MachineCode;
            sIOType = Common.IOType;
            sWorker = Common.UserID;
            sNewWrkOrder = WrkOrderNo;
            sNewWrkOrderSeq = WrkOrderSeq;
        }


        #endregion

        #region < POP_WRK40_Load >
        private void POP_WRK40_Load(object sender, EventArgs e)
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

                this.lblTitle.Text = "작업지시 변경";

                //DateTime daysBefore = DateTime.Now;
                //daysBefore = daysBefore.AddDays(-7);

                SetMenuButtons();
                DoFind();
            }
            catch (Exception ex)
            {
                SetMessage("POP_WRK40_Load_ Error!");
                LogFile.WriteLog("POP_WRK40.POP_WRK40_Load Error => " + ex.Message);
            }

            //현재 메시지큐에 있는 모든 메시지 처리함수 
            SendKeys.Flush();
        }
        #endregion

        #region < METHOD AREA >

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

                bBox1[0, 0].Text = "확인";
                bBox1[0, 0].Tag = "Confirm";
                bBox1[0, 0].MappingButton.FontSize = 14;
                bBox1[0, 1].Text = "";
                bBox1[0, 1].Tag = "";
                bBox1[0, 1].MappingButton.FontSize = 14;
                bBox1[0, 2].Text = "";
                bBox1[0, 2].Tag = "";
                bBox1[0, 2].MappingButton.FontSize = 14;
                bBox1[0, 3].Text = "";
                bBox1[0, 3].Tag = "";
                bBox1[0, 3].MappingButton.FontSize = 14;
                bBox1[0, 4].Text = "";
                bBox1[0, 4].Tag = "";
                bBox1[0, 4].MappingButton.FontSize = 14;
                bBox1[0, 5].Text = "";
                bBox1[0, 5].Tag = "";
                bBox1[0, 5].MappingButton.FontSize = 14;
                bBox1[0, 6].Text = "";
                bBox1[0, 6].Tag = "";
                bBox1[0, 6].MappingButton.FontSize = 14;
                bBox1[0, 7].Text = "";
                bBox1[0, 7].Tag = "";
                bBox1[0, 7].MappingButton.FontSize = 14;
                bBox1[0, 8].Text = "";
                bBox1[0, 8].Tag = "";
                bBox1[0, 8].MappingButton.FontSize = 14;
                bBox1[0, 9].Text = "";
                bBox1[0, 9].Tag = "";
                bBox1[0, 9].MappingButton.FontSize = 14;
                bBox1[0, 10].Text = "닫기";
                bBox1[0, 10].Tag = "Close";
                bBox1[0, 10].MappingButton.FontSize = 14;

                bBox1.RedrawButtons();
            }
            catch (Exception ex)
            {
                SetMessage("SetButtons Error!");
                LogFile.WriteLog("POP_WRK40.SetButtons Error => " + ex.Message);
            }
        }

        private void DoFind()
        {
            DBHelper helper = new DBHelper();
            DateTime dtStartTime;
            DateTime dtEndTime;

            try
            {
                dtWrkOrder = helper.FillTable("SP_POP_WRK40_S01", CommandType.StoredProcedure
                                                                   , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)
                                                                   , helper.CreateParameter("P_PROC_CD", Common.OpCode, DbType.String, ParameterDirection.Input)
                                                                   , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)
                                                                   , helper.CreateParameter("P_WRK_ORDR_NO", sNewWrkOrder, DbType.String, ParameterDirection.Input)
                                                                   , helper.CreateParameter("P_WRK_ORDR_SEQ", sNewWrkOrderSeq, DbType.String, ParameterDirection.Input)
                                                                   , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input));
                if (dtWrkOrder.Rows.Count < 1)
                {
                    SetMessage("조회된 작업지시가 없습니다.");
                    return;
                }
                else if (dtWrkOrder.Rows.Count == 1)
                {
                    //조회된 지시가 선택된 지시인 경우(작업중인 지시가 없는 경우)
                    if (dtWrkOrder.Rows[0]["ROW_STA"].ToString().Equals("N"))
                    {
                        drNewWrk = dtWrkOrder.Select("ROW_STA = 'N'")[0];
                        ////변경될 작업지시 조회
                        lblWRK_ORDR_NO_N.Text = drNewWrk["WRK_ORDR_NO"].ToString();       // 작업지시번호
                        lblWRK_ORDR_SEQNO_N.Text = drNewWrk["WRK_ORDR_SEQNO"].ToString(); // 작업지시순번
                        lblMATNR_N.Tag = drNewWrk["MATNR"].ToString(); // 자재코드
                        lblMATNR_N.Text = drNewWrk["MATNR"].ToString(); // 자재코드
//                        lblMATNR_N.Text = drNewWrk["MATNR_NM"].ToString(); // 자재명

                        lblJROLLCNT_N.Text = drNewWrk["JROLLCNT"].ToString(); // 계획권치수
                        lblTOT_WGT_N.Text = drNewWrk["TOT_WGT"].ToString(); // 계획중량

                        lblPRD_REQ_DT_N.Text = drNewWrk["PRD_REQ_DT"].ToString(); // 생산요청일자
                        lblBS_WGT_N.Text = drNewWrk["BS_WGT"].ToString(); // 평량
                        lblWIDTH_N.Text = drNewWrk["WIDTH"].ToString(); // 지폭
                        lblPRFM_ROLLCNT_N.Text = drNewWrk["PRFM_ROLLCNT"].ToString(); // 실적 권치수
                        lblPRFM_WGT_N.Text = drNewWrk["PRFM_WGT"].ToString(); // 실적중량
                        lblDISPO_QTY_N.Text = drNewWrk["DISPO_QTY"].ToString(); // 폐품 중량

                        dtpStartDateN.Value = DateTime.Now;
                        lblStartTimeN.Text = dtpStartDateN.Value.ToString("HH:mm:ss");
                    }
                    //조회된 지시가 작업중인 지시인 경우
                    else
                    {
                        new POPUP.MessageForm("선택된 지시를 확인하여 주시기 바랍니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                        this.Close();
                    }
                }
                else
                {
                    ////현재 및 변경될 작업지시 조회
                    drNowWrk = dtWrkOrder.Select("ROW_STA = 'P'")[0];
                    drNewWrk = dtWrkOrder.Select("ROW_STA = 'N'")[0];

                    ////현재 작업지시 정보 출력
                    lblWRK_ORDR_NO.Text = drNowWrk["WRK_ORDR_NO"].ToString();       // 작업지시번호
                    lblWRK_ORDR_SEQNO.Text = drNowWrk["WRK_ORDR_SEQNO"].ToString(); // 작업지시순번
                    lblMATNR.Tag = drNowWrk["MATNR"].ToString(); // 자재코드
                    lblMATNR.Text = drNowWrk["MATNR"].ToString(); // 자재코드
                    //lblMATNR.Text = drNowWrk["MATNR_NM"].ToString(); // 자재명

                    lblJROLLCNT.Text = Common.StrFormatInteger(drNowWrk["JROLLCNT"].ToString()); // 계획 권치수
                    lblTOT_WGT.Text = Common.StrFormatDouble(drNowWrk["TOT_WGT"].ToString()); // 계획 중량
                    lblPRD_REQ_DT.Text = drNowWrk["PRD_REQ_DT"].ToString(); // 생산요청일자
                    lblBS_WGT.Text = Common.StrFormatInteger(drNowWrk["BS_WGT"].ToString()); // 평량
                    lblWIDTH.Text = Common.StrFormatInteger(drNowWrk["WIDTH"].ToString()); // 지폭
                    lblPRFM_ROLLCNT.Text = Common.StrFormatInteger(drNowWrk["PRFM_ROLLCNT"].ToString()); // 실적 권치수
                    lblPRFM_WGT.Text = Common.StrFormatDouble(drNowWrk["PRFM_WGT"].ToString()); // 실적 중량
                    lblDISPO_QTY.Text = Common.StrFormatDouble(drNowWrk["DISPO_QTY"].ToString()); // 폐품 중량

                    txtWRK_ORDR_RMK.Text = drNowWrk["WRK_ORDR_RMK"].ToString(); // 작업지시비고

                    //시작시간 출력
                    if(DateTime.TryParseExact(drNowWrk["PRD_STR_DATE"].ToString(), "yyyyMMddHHmmss", null, DateTimeStyles.AssumeLocal, out dtStartTime))
                    {
                        dtpStartDate.Value = dtStartTime;
                        lblStartTime.Text = dtpStartDate.Value.ToString("HH:mm:ss");
                    }
                    else
                    {
                        dtpStartDate.Value = DateTime.Now;
                        lblStartTime.Text = "";
                    }


                    //완료시간 출력
                    if (DateTime.TryParseExact(drNowWrk["PRD_END_DATE"].ToString(), "yyyyMMddHHmmss", null, DateTimeStyles.AssumeLocal, out dtEndTime))
                    {
                        dtpEndDate.Value = dtEndTime;
                        lblEndTime.Text = dtpEndDate.Value.ToString("HH:mm:ss");

                        dtpStartDateN.Value = dtEndTime;
                        lblStartTimeN.Text = dtpStartDateN.Value.ToString("HH:mm:ss");
                    }
                    else
                    {
                        dtpEndDate.Value = DateTime.Now;
                        lblEndTime.Text = dtpEndDate.Value.ToString("HH:mm:ss");

                        dtpStartDateN.Value = DateTime.Now;
                        lblStartTimeN.Text = dtpStartDateN.Value.ToString("HH:mm:ss");
                    }

                    ////변경될 작업지시 조회
                    lblWRK_ORDR_NO_N.Text = drNewWrk["WRK_ORDR_NO"].ToString();       // 작업지시번호
                    lblWRK_ORDR_SEQNO_N.Text = drNewWrk["WRK_ORDR_SEQNO"].ToString(); // 작업지시순번
                    lblMATNR_N.Tag = drNewWrk["MATNR"].ToString(); // 자재코드
                    lblMATNR_N.Text = drNewWrk["MATNR"].ToString(); // 자재명
                    //lblMATNR_N.Text = drNewWrk["MATNR_NM"].ToString(); // 자재명

                    lblJROLLCNT_N.Text = Common.StrFormatInteger(drNewWrk["JROLLCNT"].ToString()); // 계획 권치수
                    lblTOT_WGT_N.Text = Common.StrFormatDouble(drNewWrk["TOT_WGT"].ToString()); // 계획 중량
                    lblPRD_REQ_DT_N.Text = drNewWrk["PRD_REQ_DT"].ToString(); // 생산요청일자
                    lblBS_WGT_N.Text = Common.StrFormatInteger(drNewWrk["BS_WGT"].ToString()); // 평량
                    lblWIDTH_N.Text = Common.StrFormatInteger(drNewWrk["WIDTH"].ToString()); // 지폭
                    lblPRFM_ROLLCNT_N.Text = Common.StrFormatInteger(drNewWrk["PRFM_ROLLCNT"].ToString()); // 실적 권치수
                    lblPRFM_WGT_N.Text = Common.StrFormatDouble(drNewWrk["PRFM_WGT"].ToString()); // 실적 중량
                    lblDISPO_QTY_N.Text = Common.StrFormatDouble(drNewWrk["DISPO_QTY"].ToString()); // 폐품 중량

                    txtWRK_ORDR_RMK_N.Text = drNewWrk["WRK_ORDR_RMK"].ToString(); // 작업지시비고
                }
            }
            catch (Exception ex)
            {
                SetMessage(ex.Message);
                LogFile.WriteLog("POP_WRK41.WRK_ORDER Find Error => " + ex.Message);
            }
        }


        private void doConfirm()
        {
            DBHelper helper = new DBHelper(false);
            string sMSG = string.Empty;

            string sWRK_ORDER_NO = lblWRK_ORDR_NO_N.Text.ToString(); //신규작업지시
            string sWRK_ORDER_SEQNO = lblWRK_ORDR_SEQNO_N.Text.ToString(); //신규작업지시순번
            string sNEW_ORDER_NO = drNewWrk["ORDER_NO"].ToString(); //신규지시 생산오더
            string sMTANR = lblMATNR_N.Tag.ToString(); //신규 품목 코드

            DateTime dNowEndDate;

//            dNowStartDate = Common.makeDateTime(dtpStartDate.Value, lblStartTime.Text);
//            dNowEndDate = Common.makeDateTime(dtpEndDate.Value, lblEndTime.Text);
//            dNewStartDate = Common.makeDateTime(dtpStartDateN.Value, lblStartTimeN.Text);

            dNowEndDate = Common.makeDateTime(dtpStartDateN.Value, lblStartTimeN.Text);

            if (sWRK_ORDER_NO == "")
            {
                string sStartDateN = dtpStartDateN.Value.ToString("yyyyMMdd") + lblStartTimeN.Text.ToString().Replace(":", ""); // +"00";

                DateTime dtStartTimeN;
                if (DateTime.TryParseExact(sStartDateN, "yyyyMMddHHmmss", null, DateTimeStyles.AssumeLocal, out dtStartTimeN) == false)
                {
                    new POPUP.MessageForm("이후 작업 시작일시 확인하세요!", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return;
                }
            }
            else
            {
                // 실적 등록시 07시 이전에 시작된 작업에 대해서는 07:59분까지만 실적등록 가능.
                string sStartDate = dtpStartDate.Value.ToString("yyyyMMdd") + lblStartTime.Text.ToString().Replace(":", ""); // +"00";
                string sEndDate = dtpEndDate.Value.ToString("yyyyMMdd") + lblEndTime.Text.ToString().Replace(":", ""); // +"00";

                DateTime dtStartTime;
                if (DateTime.TryParseExact(sStartDate, "yyyyMMddHHmmss", null, DateTimeStyles.AssumeLocal, out dtStartTime) == false)
                {
                    new POPUP.MessageForm("작업 시작일시 확인하세요!", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return;
                }

                DateTime dtEndTime;
                if (DateTime.TryParseExact(sEndDate, "yyyyMMddHHmmss", null, DateTimeStyles.AssumeLocal, out dtEndTime) == false)
                {
                    new POPUP.MessageForm("작업 종료일시 확인하세요!", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return;
                }

                if (dtEndTime.Subtract(dtStartTime).TotalMinutes <= 0)
                {
                    new POPUP.MessageForm("이전 작업시작일시가 이전 작업종료일시보다 큽니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return;
                }
            }

            try
            {
                //작업시작/완료처리 (작업지시 상태변경 및 작업장 현황의 가동상태 변경)
                helper.ExecuteNoneQuery("SP_POP_WRK40_U01", CommandType.StoredProcedure
                         , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)
                         , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)
                         , helper.CreateParameter("P_IOTYPE", Common.IOType, DbType.String, ParameterDirection.Input)
                         , helper.CreateParameter("P_WRK_ORDR_NO", sWRK_ORDER_NO, DbType.String, ParameterDirection.Input)
                         , helper.CreateParameter("P_WRK_ORDR_SEQNO", sWRK_ORDER_SEQNO, DbType.String, ParameterDirection.Input)
                         , helper.CreateParameter("P_ORDER_NO", sNEW_ORDER_NO, DbType.String, ParameterDirection.Input)
                         , helper.CreateParameter("P_PRD_END_DATE", dNowEndDate.ToString("yyyyMMddHHmmss"), DbType.String, ParameterDirection.Input)
                         , helper.CreateParameter("P_MATNR", sMTANR, DbType.String, ParameterDirection.Input)
                         , helper.CreateParameter("P_PROC_CD", Common.OpCode, DbType.String, ParameterDirection.Input)
                         , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input)
                         );

                if (helper.RSCODE == "E")
                {
                    new POPUP.MessageForm(helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    this.DialogResult = DialogResult.OK;
                    return;
                }
                else
                {
                    //공통관리정보 수정
                    Common.OrderNo = sNEW_ORDER_NO;
                    Common.WrkOrderNo = sWRK_ORDER_NO;
                    Common.WrkOrderSeq = sWRK_ORDER_SEQNO;
                    Common.ItemCode = sMTANR;

                    new POPUP.MessageForm("지시변경이 완료되었습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    this.DialogResult = DialogResult.OK;
                    this.Close();
                }
            }
            catch (Exception ex)
            {
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
            }
            finally
            {
                helper.Close();
            }
        }
        
        #endregion

        #region < EVNET >

        private void bBox1_buttonClickEvent(MESButton sender, ButtonBox.ButtonClickEventArg e)
        {
            try
            {

                if (!this.bUseNetwork)
                {
                    SetMessage("네트워크 상태를 확인하시기 바랍니다.");
                    return;
                }

                MESButton btn = sender;

                switch (btn.Tag.ToString())
                {
                    case "Confirm":  //작업지시 선택
                        doConfirm();
                        break;

                    case "Close": //이전화면
                        this.Close();
                        break;
                }
            }
            catch (Oracle.ManagedDataAccess.Client.OracleException oe)
            {
                SetMessage(oe.Message);
            }

            catch (Exception ex)
            {
                SetMessage(ex.Message);
                LogFile.WriteLog("POP_WRK40.bBox1_buttonClickEvent Error => " + ex.Message);
            }
            finally
            {

            }
        }

        private void cboOrderDate_ValueChanged(object sender, EventArgs e)
        {
                DoFind();

        }

        private void cboOrderDateE_ValueChanged(object sender, EventArgs e)
        {
                DoFind();
        }

        #endregion

        private void butStartDate_Click(object sender, EventArgs e)
        {
            string tempDate = string.Empty;

            DAResultDate pop = new DAResultDate(dtpStartDate.Value);
            pop.ShowDialog(this);
            if (pop.DialogResult == DialogResult.OK)
            {
                tempDate = pop.ResultString.ToString();
                dtpStartDate.Value = DateTime.Parse(tempDate);
            }
        }

        private void butEndDate_Click(object sender, EventArgs e)
        {
            string tempDate = string.Empty;

            DAResultDate pop = new DAResultDate(dtpEndDate.Value);
            pop.ShowDialog(this);
            if (pop.DialogResult == DialogResult.OK)
            {
                tempDate = pop.ResultString.ToString();
                dtpEndDate.Value = DateTime.Parse(tempDate);
                //이전작업 완료시간 입력시 신규지시 시작시간 연동
                dtpStartDateN.Value = dtpEndDate.Value;
            }
        }

        private void butStartDateN_Click(object sender, EventArgs e)
        {
            string tempDate = string.Empty;

            DAResultDate pop = new DAResultDate(dtpStartDateN.Value);
            pop.ShowDialog(this);
            if (pop.DialogResult == DialogResult.OK)
            {
                tempDate = pop.ResultString.ToString();
                dtpStartDateN.Value = DateTime.Parse(tempDate);
            }
        }

        private void lblWorkTime_Click(object sender, EventArgs e)
        {
            MESLabel lblTemp = (MESLabel)sender;
            DateTime dNowStartDate;
            DateTime dNowEndDate;

            DAResultTime pop = new DAResultTime("HHmmss");  // 점보롤은 시분초입력
            pop.ShowDialog(this);
            if (pop.DialogResult == DialogResult.OK)
            {
                lblTemp.Text = pop.ResultString.ToString();
                //이전작업 완료시간 입력시 신규지시 시작시간 연동
                if (lblTemp.Name.ToString().Equals("lblEndTime"))
                {
                    dNowStartDate = Common.makeDateTime(dtpStartDate.Value, lblStartTime.Text);
                    dNowEndDate = Common.makeDateTime(dtpEndDate.Value, lblEndTime.Text);
                    if (dNowStartDate >= dNowEndDate)
                    {
                        new POPUP.MessageForm("작업시간을 확인하여 주시기 바랍니다..", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                        return;
                    }

                    lblStartTimeN.Text = lblEndTime.Text;
                }
            }
        }

        private void dtpDate_DropDown(object sender, EventArgs e)
        {
            CommonCalendar.CloseCalendar((DateTimePicker)sender);
        }
    }
}
