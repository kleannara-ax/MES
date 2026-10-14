#region [ USING AREA ]
using System;
using System.Configuration;
using System.Data;
using System.Windows.Forms;
using System.Drawing;
using Infragistics.Win.UltraWinGrid;


using SAMMI;
using SmartDas.Components;
using SmartDas.POPUP;
using System.Globalization;

using Oracle.ManagedDataAccess.Client;
using System.Threading;
#endregion

namespace SmartDas
{
    public partial class POP_WRK_LAMI_SL_002 : BaseForm
    {
        #region < MEMBER AREA >
        private SAMMI.Common _common = new SAMMI.Common();

        private DataTable dtNowWrk; //현재 작업지시지
        private int iReSetCnt = 0;
        private bool bABNChk = false;
        private string sWorkType = string.Empty;
        private bool bWorkStart = false;
        private string sStatus = string.Empty;
        #endregion

        #region < CONSTRUCTOR >

        public POP_WRK_LAMI_SL_002()
        {
            InitializeComponent();

            Common.SetMessageList();
            this.UpdateMinuteEvent += new UpdateMinuteHandler(CallUpdateMinuteFunc);
        }

        public void CallUpdateMinuteFunc()
        {
            // DateTime dtTmp = DateTime.Now;

            // lblStartTime.Text 에 시:분 을 먼지 입력해야 dtpDate_ValueChanged 이벤트에서 AutoCalculation() 에서 정상처리됨.
            //lblEndTime.Text = dtTmp.ToString("HH:mm");       // 작업종료시간
            //dtpEndDate.Value = dtTmp;
        }
        #endregion

        #region < POP_WRK_LAMI_SL_002_Load >
        private void POP_WRK_LAMI_SL_002_Load(object sender, EventArgs e)
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

                //설비정보 설정
                Common.machSetting();

                this.lblTitle.Text = "슬리팅";

                DateTime daysBefore = DateTime.Now;
                daysBefore = daysBefore.AddDays(-7);

                ucPNT_CNT.SelectedIndex = 0;
                ucPNT_CNT.ValueList.ItemHeight = 70;

                SetMenuButtons();
                lblPF_WGT.Text = "0";
                SetGrid();
                DoFind();
            }
            catch (Exception ex)
            {
                SetMessage("POP_WRK_LAMI_SL_002_Load_ Error!");
                LogFile.WriteLog("POP_WRK_LAMI_SL_002.POP_WRK_LAMI_SL_002_Load Error\r\n" + ex.Message);
            }
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

                bBox1[0, 0].Text = "작업지시\n선택";
                bBox1[0, 0].Tag = "Order";
                bBox1[0, 0].MappingButton.FontSize = 14;
                bBox1[0, 1].Text = "작업자\n선택";
                bBox1[0, 1].Tag = "Worker";
                bBox1[0, 1].MappingButton.FontSize = 14;
                bBox1[0, 2].Text = "작업시작";
                bBox1[0, 2].Tag = "Start";
                bBox1[0, 2].MappingButton.FontSize = 14;
                bBox1[0, 3].Text = "비가동\n등록";
                bBox1[0, 3].Tag = "NonOper";
                bBox1[0, 3].MappingButton.FontSize = 14;
                //bBox1[0, 4].Text = "폐품선택";
                //bBox1[0, 4].Tag = "Dispo";
                //bBox1[0, 4].MappingButton.FontSize = 14;
                bBox1[0, 4].Text = "실적등록";
                bBox1[0, 4].Tag = "Split";
                bBox1[0, 4].MappingButton.FontSize = 14;
                bBox1[0, 5].Text = "공정투입";
                bBox1[0, 5].Tag = "Input";
                bBox1[0, 5].MappingButton.FontSize = 14;
                bBox1[0, 6].Text = "공정투입\n취소";
                bBox1[0, 6].Tag = "Cancel";
                bBox1[0, 6].MappingButton.FontSize = 14;
                //bBox1[0, 6].Text = "프린터\n설정";  //"프린터" + Environment.NewLine + "설정";
                //bBox1[0, 6].Tag = "Printer";   //"Printer";
                //bBox1[0, 6].MappingButton.FontSize = 14;
                //bBox1[0, 7].Text = "작업종료";
                //bBox1[0, 7].Tag = "Product";
                //bBox1[0, 7].MappingButton.FontSize = 14;
                bBox1[0, 7].Text = "설비선택";
                bBox1[0, 7].Tag = "Machine";
                bBox1[0, 7].MappingButton.FontSize = 14;
                bBox1[0, 9].Text = "";
                bBox1[0, 9].Tag = "";
                bBox1[0, 9].MappingButton.FontSize = 14;
                bBox1[0, 10].Text = "실적현황";
                bBox1[0, 10].Tag = "Performance";
                bBox1[0, 10].MappingButton.FontSize = 14;

                bBox1.RedrawButtons();
            }
            catch (Exception ex)
            {
                SetMessage("SetButtons Error!");
                LogFile.WriteLog("POP_WRK_LAMI_SL_002.SetButtons Error\r\n" + ex.Message);
            }
        }

        private void DoFind()
        {
            DateTime dtStartTime;
            DateTime dtEndTime;
            DateTime dtLastDate;
            int iTempValue;

            try
            {
                timer1.Start();
                //비가동 알람 초기화
                bBox1[0, 3].bAlarm = false;

                lblPF_WGT.Text = "0";                                               // 중량
                lblPRFMMET_QTY.Text = "";                                           //실적 - 미터
                lblROLL_QTYSUM.Text = "";                                          // 롤수
                lblPRFN_QTY.Text = "";
                lblPRFN_QTY.Tag = "";
                lblROLL_QTY.Text = "0";
                lblStartTime.Text = "";
                lblEndTime.Text = "";
                lblINPUTMATNR.Tag = "";
                lblINPUTMATNR.Text = "";
                lblINPUTLOTNO.Text = "";
                lblINPUT_QTY.Text = "";
                lblINPUT_ORDER_QTY.Text = "";
                if (dtNowWrk.Rows.Count < 1 || string.IsNullOrEmpty(dtNowWrk.Rows[0]["WRK_ORDR_NO"].ToString()))
                {
                    //SetMessage("조회된 작업지시가 없습니다.");
                    //조회된 항목 초기화
                    CheckValue(lblPrintChk, "V");     //자동인쇄
                    lblPRD_REQ_DT.Text = string.Empty;//생산지시일
                    lblWRK_ORDR_NO.Text = string.Empty;//작업지시번호
                    lblWRK_ORDR_SEQNO.Text = string.Empty;//작업지시순번
                    lblMATNR.Tag = string.Empty; //자재코드
                    lblMATNR.Text = string.Empty; //자재명
                    lblINPUTMATNR.Tag = string.Empty;
                    lblINPUTMATNR.Text = string.Empty;
                    lblINPUTLOTNO.Text = string.Empty;
                    lblINPUT_QTY.Text = string.Empty;              
                    lblREMAIN_QTY.Text = string.Empty; //규격
                    txtRemark.Text = string.Empty; //작업지시사항
                    lblORDER_QTY.Text = string.Empty; //계획량
                    lblUNIT.Text = string.Empty; //단위
                    lblORDER_QTY.Text = string.Empty; //계획량
                    lblROLL_QTY.Text = string.Empty;        // 롤수

                    lblORDER_QTY.Text = string.Empty; //계획량
                    lblMACH_STA.Text = string.Empty; //가동상태                    

                    //공통사용항목 지시정보 초기화
                    Common.OrderNo = string.Empty;//생산오더번호
                    Common.WrkOrderNo = string.Empty;//작업지시번호
                    Common.WrkOrderSeq = string.Empty;//작업지시순번
                    Common.ItemCode = string.Empty; //자재코드
                    //return;
                }
                else
                {
                    lblPRD_REQ_DT.Text = Common.dateFormat("O", dtNowWrk.Rows[0]["PRD_REQ_DT"].ToString());//생산지시일
                    lblWRK_ORDR_NO.Text = dtNowWrk.Rows[0]["WRK_ORDR_NO"].ToString();//작업지시번호
                    lblWRK_ORDR_SEQNO.Text = dtNowWrk.Rows[0]["WRK_ORDR_SEQNO"].ToString();//작업지시순번
                    lblMATNR.Tag = dtNowWrk.Rows[0]["MATNR"].ToString(); //자재코드
                    lblMATNR.Text = dtNowWrk.Rows[0]["MATNR_NM"].ToString(); //자재명
                    txtRemark.Text = dtNowWrk.Rows[0]["WRK_ORDR_RMK"].ToString(); //작업지시사항
                    lblUNIT.Text = dtNowWrk.Rows[0]["UNIT"].ToString(); //단위
                    lblINPUTMATNR.Tag = dtNowWrk.Rows[0]["M_MATNR"].ToString(); //투입 품목
                    lblINPUTMATNR.Text = dtNowWrk.Rows[0]["M_MATNR_NM"].ToString(); //투입 품목명                    
                    lblINPUTLOTNO.Text = dtNowWrk.Rows[0]["M_LOT_NO"].ToString(); //투입 LOTNO

                    if (int.TryParse(dtNowWrk.Rows[0]["WRK_ORDR_QTY"].ToString(), out iTempValue))
                        lblORDER_QTY.Text = string.Format("{0:#,##0}", iTempValue); //계획량
                    else
                        lblORDER_QTY.Text = dtNowWrk.Rows[0]["WRK_ORDR_QTY"].ToString();

                    if (int.TryParse(dtNowWrk.Rows[0]["PRFM_QTY"].ToString(), out iTempValue))
                        lblPRFN_QTY.Text = string.Format("{0:#,##0}", iTempValue); //중량
                    else
                        lblPRFN_QTY.Text = dtNowWrk.Rows[0]["PRFM_QTY"].ToString();

                    if (int.TryParse(dtNowWrk.Rows[0]["REMAIN_QTY"].ToString(), out iTempValue))
                        lblREMAIN_QTY.Text = string.Format("{0:#,##0}", iTempValue); //잔량
                    else
                        lblREMAIN_QTY.Text = dtNowWrk.Rows[0]["REMAIN_QTY"].ToString();

                    if (int.TryParse(dtNowWrk.Rows[0]["ROLL_QTY"].ToString(), out iTempValue))
                        lblROLL_QTYSUM.Text = string.Format("{0:#,##0}", iTempValue); //롤수
                    else
                        lblROLL_QTYSUM.Text = dtNowWrk.Rows[0]["ROLL_QTY"].ToString();

                    if (int.TryParse(dtNowWrk.Rows[0]["M_IN_QTY"].ToString(), out iTempValue))
                        lblINPUT_QTY.Text = string.Format("{0:#,##0}", iTempValue); //투입량
                    else
                        lblINPUT_QTY.Text = dtNowWrk.Rows[0]["M_IN_QTY"].ToString();

                    if (int.TryParse(dtNowWrk.Rows[0]["M_IN_QTY_OVR"].ToString(), out iTempValue))
                        lblINPUT_ORDER_QTY.Text = string.Format("{0:#,##0}", iTempValue); //투입지시량
                    else
                        lblINPUT_ORDER_QTY.Text = dtNowWrk.Rows[0]["M_IN_QTY_OVR"].ToString();


                    //공통사용항목 관리
                    Common.OrderNo = dtNowWrk.Rows[0]["ORDER_NO"].ToString();//생산오더번호
                    Common.WrkOrderNo = dtNowWrk.Rows[0]["WRK_ORDR_NO"].ToString();//작업지시번호
                    Common.WrkOrderSeq = dtNowWrk.Rows[0]["WRK_ORDR_SEQNO"].ToString();//작업지시순번
                    Common.ItemCode = dtNowWrk.Rows[0]["MATNR"].ToString(); //자재코드

                    //시작시간 출력
                    if (!String.IsNullOrEmpty(dtNowWrk.Rows[0]["PRD_STR_DATE"].ToString()))
                    {
                        dtStartTime = new DateTime(
                            Convert.ToInt16(dtNowWrk.Rows[0]["PRD_STR_DATE"].ToString().Substring(0, 4)),
                            Convert.ToInt16(dtNowWrk.Rows[0]["PRD_STR_DATE"].ToString().Substring(4, 2)),
                            Convert.ToInt16(dtNowWrk.Rows[0]["PRD_STR_DATE"].ToString().Substring(6, 2)),
                            Convert.ToInt16(dtNowWrk.Rows[0]["PRD_STR_DATE"].ToString().Substring(8, 2)),
                            Convert.ToInt16(dtNowWrk.Rows[0]["PRD_STR_DATE"].ToString().Substring(10, 2)),
                            Convert.ToInt16(dtNowWrk.Rows[0]["PRD_STR_DATE"].ToString().Substring(12, 2)));
                        dtpStartDate.Value = dtStartTime;
                    }
                    else
                        dtpStartDate.Value = DateTime.Now;

                    lblStartTime.Text = "";
                    //완료시간 출력
                    dtpEndDate.Value = DateTime.Now;
                    lblEndTime.Text = "";
                    sStatus = dtNowWrk.Rows[0]["ORG_MACH_STA"].ToString();
                    //가동상태 출력
                    if (dtNowWrk.Rows[0]["MACH_STA"].ToString().Equals("S"))
                    {
                        lblMACH_STA.Text = "비가동";
                        bBox1[0, 2].Text = "작업시작";
                        bBox1[0, 2].Tag = "Start";
                        bBox1.RedrawButtons();
                        //비가동시 점멸처리
                        bABNChk = true;
                        //timer1.Start();
                    }
                    else if (dtNowWrk.Rows[0]["MACH_STA"].ToString().Equals("N"))
                    {
                        lblMACH_STA.Text = "대기중";
                        bBox1[0, 2].Text = "작업시작";
                        bBox1[0, 2].Tag = "Start";
                        bBox1.RedrawButtons();
                        bABNChk = false;
                        lblEndTime.Text = "";
                        if (!dtNowWrk.Rows[0]["PRFM_QTY"].ToString().Equals(string.Empty))
                        {
                            if (Convert.ToDecimal(dtNowWrk.Rows[0]["PRFM_QTY"]) > 0)
                            {
                                lblStartTime.Text = dtpStartDate.Value.ToString("HH:mm");
                            }
                        }
                    }
                    else
                    {
                        lblMACH_STA.Text = "가동중";

                        bBox1[0, 2].Text = "작업시작";
                        bBox1[0, 2].Tag = "Start";
                        bBox1.RedrawButtons();
                        bABNChk = false;
                        lblStartTime.Text = dtpStartDate.Value.ToString("HH:mm");
                    }

                    //선택된 행 색상 변경
                    for (int i = 0; i < Grid1.Rows.Count; i++)
                    {
                        if (Grid1.Rows[i].Cells["ROWSEQ"].Value.ToString().Equals("0"))
                            Grid1.Rows[i].CellAppearance.BackColor = Color.Orange;
                    }
                }
            }
            catch (Exception ex)
            {
                SetMessage("DoFind Error!");
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                LogFile.WriteLog("POP_WRK08.WRK_ORDER Find Error\r\n" + ex.Message);
            }
        }
        private void SetGrid()
        {
            //if (string.IsNullOrEmpty(Common.WrkOrderNo) || string.IsNullOrEmpty(Common.WrkOrderSeq))
            //{
            //    return;
            //}

            DBHelper helper = new DBHelper();
            string sColInfo = string.Empty;
            string sColType = string.Empty;

            DataSet dsTemp = new DataSet();

            try
            {
                Grid1.HeaderFontSize = 13;
                Grid1.FontSize = 13;
                Grid1.CountRows = 8;
                Grid1.AutoScroll = true;
                Grid1.DisplayLayout.Scrollbars = Scrollbars.Both;
                btnRightPage.LinkMoveSize = Grid1.CountRows;
                btnLeftPage.LinkMoveSize = Grid1.CountRows;

                dsTemp = helper.FillDataSetN("SP_POP_WRK_LAMI_SL", CommandType.StoredProcedure, 5
                                                                , helper.CreateParameter("P_WRK_ORDR_NO", Common.WrkOrderNo, DbType.String, ParameterDirection.Input)
                                                                , helper.CreateParameter("P_WRK_ORDR_SEQNO", Common.WrkOrderSeq, DbType.String, ParameterDirection.Input)
                                                                , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)
                                                                , helper.CreateParameter("P_IOTYPE", Common.IOType, DbType.String, ParameterDirection.Input));
                //그리드 출력
                Grid1.DoFind_Oracle(dsTemp);

                // 투입그리드 세팅
                DataSet ds = new DataSet();
                ds.Tables.Add(dsTemp.Tables[3].Copy());
                ds.Tables.Add(dsTemp.Tables[4].Copy());

                Grid2.HeaderFontSize = 13;
                Grid2.FontSize = 13;
                Grid2.CountRows = 8;
                Grid2.AutoScroll = true;
                Grid2.DisplayLayout.Scrollbars = Scrollbars.Vertical;
                btnRightPage.LinkMoveSize = Grid2.CountRows;
                btnLeftPage.LinkMoveSize = Grid2.CountRows;

                //투입그리드 출력
                Grid2.DoFind_Oracle(ds);

                //현재 지시정보 저장
                dtNowWrk = dsTemp.Tables[2];
            }
            catch (Exception ex)
            {
                SetMessage("SetGrid Error!");
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                LogFile.WriteLog("POP_WRK_LAMI_SL_002.SetGrid Error\r\n" + ex.Message);
            }
        }

        private void doConfirm(string RegType)
        {
            bWorkStart = false;
            DBHelper helper = new DBHelper(false);
            string sMSG = string.Empty;
            DateTime dtStr;
            DateTime dtEnd;
            //팝업 변수
            POPUP.MessageForm msgForm = null;
            DialogResult res = DialogResult.Cancel;

            Common.OrderNo = dtNowWrk.Rows[0]["ORDER_NO"].ToString();//생산오더
            Common.WrkOrderNo = dtNowWrk.Rows[0]["WRK_ORDR_NO"].ToString(); //작업지시
            Common.WrkOrderSeq = dtNowWrk.Rows[0]["WRK_ORDR_SEQNO"].ToString(); //작업지시순번
            Common.ItemCode = dtNowWrk.Rows[0]["MATNR"].ToString();//자재코드

            string sStatus = RegType == "Start" ? "S" : "E";
            string sStrDt = dtpStartDate.Text + " " + lblStartTime.Text;
            string sEndDt = dtpEndDate.Text + " " + lblEndTime.Text;
            string sRegDate = sStrDt;//등록시간
            DateTime dRegDate;

            if (!DateTime.TryParse(sStrDt, out dtStr))
            {
                new POPUP.MessageForm("시작시간을 확인하여 주시기 바랍니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return;
            }
            if (!DateTime.TryParse(sEndDt, out dtEnd))
            {
                new POPUP.MessageForm("종료시간을 확인하여 주시기 바랍니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return;
            }
            if (!DateTime.TryParse(sRegDate, out dRegDate))
            {
                dRegDate = DateTime.Now; //잘못된 날자가 입력된 경우 현재일자 등록
            }

            try
            {
                //설비 및 작업자 선택여부 확인
                if (string.IsNullOrEmpty(Common.MachineCode))
                {
                    new POPUP.MessageForm("설비호기를 선택하여 주시기 바랍니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return;
                }
                if (string.IsNullOrEmpty(Common.UserID))
                {
                    new POPUP.MessageForm("작업자를 선택하여 주시기 바랍니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return;
                }
                if (string.IsNullOrEmpty(Common.WrkOrderNo))
                {
                    new POPUP.MessageForm("작업지시를 선택하여 주시기 바랍니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return;
                }
                if (!lblMACH_STA.Text.Equals("대기중"))
                {
                    new POPUP.MessageForm("이미 진행중인 작업지시 입니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return;
                }
                if (lblEndTime.Text != "")
                {
                    if (dtStr >= dtEnd)
                    {
                        new POPUP.MessageForm("작업 종료일시는 작업시작일시보다 같거나 빠를수 없습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                        return;
                    }
                }

                msgForm = new POPUP.MessageForm("지시의 상태를 변경하시겠습니까?", MessageBoxButtons.OKCancel, "알   림");
                res = msgForm.ShowDialog(this);
                if (res == System.Windows.Forms.DialogResult.OK)
                {
                    //작업시작/완료처리 (작업지시 상태변경 및 작업장 현황의 가동상태 변경)
                    helper.ExecuteNoneQuery("SP_POP_WRKLAMI_SL_I01", CommandType.StoredProcedure
                     , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)
                     , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)
                     , helper.CreateParameter("P_SDATE", dRegDate.ToString("yyyyMMddHHmmss"), DbType.String, ParameterDirection.Input)
                     , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input)
                     , helper.CreateParameter("P_WRK_ORDR_NO", Common.WrkOrderNo, DbType.String, ParameterDirection.Input)
                     , helper.CreateParameter("P_WRK_ORDR_SEQNO", Common.WrkOrderSeq, DbType.String, ParameterDirection.Input));

                    if (helper.RSCODE == "E")
                    {
                        new POPUP.MessageForm(helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                        this.DialogResult = DialogResult.OK;
                        return;
                    }
                    sMSG = "작업지시가 정상적으로 시작되었습니다.";
                    new POPUP.MessageForm(sMSG, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    bWorkStart = true;
                    //SetGrid();
                    //DoFind();
                }
            }
            catch (Exception ex)
            {
                SetMessage("SetGrid Error!");
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                LogFile.WriteLog("POP_WRK_LAMI_SL_002.SetGrid Error\r\n" + ex.Message);
            }
            finally
            {
                helper.Close();
            }
        }

        ///<summary>
        /// 슬리팅 분할 수정 (2023.07.11 백우종)
        /// 분할실적 등록 시 프로세스 수정
        /// 1. 실적테이블(TB_WRK002에 입력되도록 수정)
        /// 2. 사용량 계산
        /// 3. 등록된 실적에 대한 I/F 바로 처리
        /// 4. 출력
        /// </summary>
        private bool doSplit()
        {
            DataTable dtList;

            // 작업 시작일시, 종료일시 확인
            string sStartDate = dtpStartDate.Value.ToString("yyyyMMdd") + lblStartTime.Text.ToString().Replace(":", "") + "00";
            string sEndDate = dtpEndDate.Value.ToString("yyyyMMdd") + lblEndTime.Text.ToString().Replace(":", "") + "00";

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

            TimeSpan Diff_dates = dtEndTime.Subtract(dtStartTime);

            string sTM = "";    //가동시간(분)
            if (Diff_dates.TotalMinutes > 0)
            {
                sTM = Diff_dates.TotalMinutes.ToString();
            }
            else
            {
                new POPUP.MessageForm("작업 시작일시~종료일시 입력을 확인하세요!", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return false;
            }

            Decimal dPF_WGT = 0;
            Decimal dPF_DISPO_WGT = 0;
            Decimal orderQty = 0;
            Decimal height = 0;
            Decimal pEquil = 0;
            Decimal pRemainQty = 0;
            Decimal pMeterQty = 0;
            Decimal pMeterSalQty = 0;
            Decimal pPrfnQty = 0;
            Decimal pRollQty = 0;

            Decimal.TryParse(lblPF_WGT.Text.ToString().Replace(",", ""), out dPF_WGT);                          // 실적중량
            Decimal.TryParse(lblORDER_QTY.Text.ToString().Replace(",", ""), out orderQty);                      // 계획량
            Decimal.TryParse(lblPRFN_QTY.Text.ToString().Replace(",", ""), out pPrfnQty);                       // 실적량
            Decimal.TryParse(lblREMAIN_QTY.Text.ToString().Replace(",", ""), out pRemainQty);                   // 잔량실적량
            Decimal.TryParse(lblPRFMMET_QTY.Text.ToString().Replace(",", ""), out pMeterQty);                   // 실적중량 미터
            Decimal.TryParse(lblROLL_QTY.Text.ToString().Replace(",", ""), out pRollQty);                       // 롤 수

            string sProcedure = "SP_POP_WRKLAMI_SL_I12";
            string sFinishType = "N";


            // 실적중량과 잔량이 같은 경우 sFinishType = 'Y' 처리
            if (dPF_WGT == pRemainQty)
            {
                sFinishType = "Y";
            }
            // 중량 확인
            if (dPF_WGT == 0 && dPF_DISPO_WGT == 0)
            {
                new POPUP.MessageForm(string.Format("작업을 완료 하려면 실적을 추가 하세요."), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return false;
            }

            //if ((dPF_WGT == 0) && (dPF_DISPO_WGT > 0))
            //{
            //    new POPUP.MessageForm(string.Format("폐품만 등록하여 작업 완료 처리 할수 없습니다.\r\n\r\n작업을 완료 하려면 실적을 추가 하세요."), MessageBoxButtons.OK, "알   림").ShowDialog(this);
            //    return false;
            //}            

            DBHelper helper = new DBHelper(false, "", true);
            DataSet dsTemp = null;     //실적등록 결과 수신(0:실적 RFC ID, 1:실적 IF 변수, 2:실적 RFC ID, 3:실적 IF 변수)
            bool bReturn = false;       // 실적 처리 결과
            bool bRetDISPO = false;     // 폐품 처리 결과
            bool bRetINP = false;       // 투입량 처리 결과
            string sRES_IND_BCD = "";
            bool bRtn = false;
            DataTable rollTemp = null;
            DataTable sapTemp = null;

            string sMSG_ERR = "";

            try
            {
                this.Cursor = Cursors.WaitCursor;   //Waitting
                //1. 실적테이블(TB_WRK002), 사용테이블(TB_INV010) 저장
                dsTemp = helper.FillDataSetN(sProcedure, CommandType.StoredProcedure, 4
                            , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)                          // 플랜트
                            , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)                      // 작업장코드(설비코드)
                            , helper.CreateParameter("P_ROLLCNT", 1, DbType.Decimal, ParameterDirection.Input)                                      // 권치수
                            , helper.CreateParameter("P_WRK_ORDR_NO", lblWRK_ORDR_NO.Text, DbType.String, ParameterDirection.Input)                 // 작업지시번호
                            , helper.CreateParameter("P_WRK_ORDR_SEQNO", lblWRK_ORDR_SEQNO.Text, DbType.String, ParameterDirection.Input)           // 작업지시번호 순번
                            , helper.CreateParameter("P_LOT_NO", lblINPUTLOTNO.Text, DbType.String, ParameterDirection.Input)                       // 투입 LOTNO
                            , helper.CreateParameter("P_WGT", orderQty, DbType.Decimal, ParameterDirection.Input)                                    // 총중량
                            , helper.CreateParameter("P_SDATE", dtStartTime.ToString("yyyyMMddHHmmss"), DbType.String, ParameterDirection.Input)    // 작업시작시간
                            , helper.CreateParameter("P_EDATE", dtEndTime.ToString("yyyyMMddHHmmss"), DbType.String, ParameterDirection.Input)      // 작업종료시간
                            , helper.CreateParameter("P_PRFM_DT", dtEndTime.ToString("yyyyMMdd"), DbType.String, ParameterDirection.Input)          // 생산실적일자
                            , helper.CreateParameter("P_PRFM_QTY", dPF_WGT, DbType.Decimal, ParameterDirection.Input)                              // 실적중량
                            , helper.CreateParameter("P_SALCODE", null, DbType.String, ParameterDirection.Input)         // 폐품코드
                            , helper.CreateParameter("P_SALWEIGHT", Convert.ToString(dPF_DISPO_WGT), DbType.String, ParameterDirection.Input)       // 폐품중량
                            , helper.CreateParameter("P_PPCODE", null, DbType.String, ParameterDirection.Input)                          // 지종
                            , helper.CreateParameter("P_HEIGHT", null, DbType.String, ParameterDirection.Input)                 // 길이
                            , helper.CreateParameter("P_EQUIL", null, DbType.String, ParameterDirection.Input)                                      // 평형
                            , helper.CreateParameter("P_STD", null, DbType.String, ParameterDirection.Input)                                        // 규격
                            , helper.CreateParameter("P_FINISH", sFinishType, DbType.String, ParameterDirection.Input)                              // 완료여부
                            , helper.CreateParameter("P_RMK", txtRemark.Text, DbType.String, ParameterDirection.Input)                              // 비고
                            , helper.CreateParameter("P_SALRMK", null, DbType.String, ParameterDirection.Input)                        // 폐품비고
                            , helper.CreateParameter("P_WRK_CLASS", Common.WorkClass, DbType.String, ParameterDirection.Input)                     // 작업반
                            , helper.CreateParameter("P_WRK_SHIFT", Common.WorkShift, DbType.String, ParameterDirection.Input)                     // 작업조
                            , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input)                            // 사용자ID
                            , helper.CreateParameter("P_PRFMMET_QTY", pMeterQty, DbType.Decimal, ParameterDirection.Input)                          // 실중량 미터f
                            , helper.CreateParameter("P_SALMETER", pMeterSalQty, DbType.Decimal, ParameterDirection.Input)                         // 폐품미터
                            , helper.CreateParameter("P_ROLL_QTY", pRollQty, DbType.Decimal, ParameterDirection.Input)                         // 롤 수
                            , helper.CreateParameter("RS_PRFM_RFCFN", DbType.String, ParameterDirection.Output, null, 2000)                         // 실적 RFCFN값
                            , helper.CreateParameter("RS_INPUT_RFCFN", DbType.String, ParameterDirection.Output, null, 2000)                         // 투입 RFCFN값
                            , helper.CreateParameter("RS_IND_BCD", DbType.String, ParameterDirection.Output, null, 2000)                    // RES 개별바코드 
                            , helper.CreateParameter("RS_RFCFN", DbType.String, ParameterDirection.Output, null, 2000)                      // RFCFN ID값
                        );

                if (helper.RSCODE == "S")
                {
                    sRES_IND_BCD = helper.Parameters["RS_IND_BCD"].Value.ToString();

                    string sRS_PRFM_RFCFN = helper.Parameters["RS_PRFM_RFCFN"].Value.ToString();      // 실적 RFCFN ID
                    string sRS_INPUT_RFCFN = helper.Parameters["RS_INPUT_RFCFN"].Value.ToString();    // 투입량 RFCFN ID

                    //SAP 롤백용 추가 CODE 범위 START
                    sapTemp = new DataTable(); // 성공한 sap 정보 저장
                    sapTemp.Columns.Add("SAP_TYPE", typeof(string));
                    sapTemp.Columns.Add("IF_KEY", typeof(string));
                    sapTemp.Columns.Add("MDOCNO", typeof(string));
                    sapTemp.Columns.Add("MDOCSEQ", typeof(string));
                    sapTemp.Columns.Add("P_FLAG", typeof(string));

                    rollTemp = new DataTable(); // ROLLBACK용 정보 저장
                    rollTemp.Columns.Add("MDOCNO", typeof(string));
                    rollTemp.Columns.Add("MDOCSEQ", typeof(string));
                    //SAP 롤백용 추가 CODE 범위 END

                    //SAP 롤백용 추가 CODE 범위 START
                    if (dsTemp.Tables[1].Columns[0].ColumnName != "1")
                    {
                        foreach (DataRow Rows in dsTemp.Tables[1].Rows)
                        {
                            string rollTempMDOC_NO_1 = Rows["MDOCNO"].ToString();
                            string rollTempMDOC_SEQNO_1 = Rows["MDOCSEQ"].ToString();
                            rollTemp.Rows.Add(rollTempMDOC_NO_1, rollTempMDOC_SEQNO_1);
                        }
                    }
                    //재단의 경우 폐품에 개별바코드 생성됨 MES롤백을 위한 문서번호 저장 추가
                    if (dsTemp.Tables[3].Columns[0].ColumnName != "1")
                    {
                        foreach (DataRow Rows in dsTemp.Tables[3].Rows)
                        {
                            string rollTempMDOC_NO_1 = Rows["MDOCNO"].ToString();
                            string rollTempMDOC_SEQNO_1 = Rows["MDOCSEQ"].ToString();
                            rollTemp.Rows.Add(rollTempMDOC_NO_1, rollTempMDOC_SEQNO_1);
                        }
                    }

                    string sRfcData; //RFC결과 JSON 변환
                    bReturn = false;

                    if ((string.IsNullOrEmpty(sRS_PRFM_RFCFN) == false) || (string.IsNullOrEmpty(sRS_INPUT_RFCFN) == false))
                    {
                        // 1. 실적 등록 (밀롤 완료 플래그 때문에 마지막에 보냄)
                        if (string.IsNullOrEmpty(sRS_PRFM_RFCFN) == false)
                        {
                            #region 실적 등록
                            // 문서번호, 문서순번으로  테이블 SORT 하여 전달
                            DataTable dtRFCData = new DataTable();
                            DataView dvPFRM = new DataView(dsTemp.Tables[1]);
                            dvPFRM.Sort = "MDOCNO, MDOCSEQ ASC";
                            dtRFCData = dvPFRM.ToTable();

                            //SAP 실적 등록
                            SAPHelper sapRFC_P = new SAPHelper();
                            // sapRFC.CallSAPFunc 호출시 helper를 사용하여 내용이 변경됨. 
                            // 필요한 정보는 sapRFC.CallSAPFunc 호출전에 처리해야함.
                            if (dtRFCData.Rows.Count > 0)
                            {
                                int i = 0;
                                string rfcType = "0";
                                string mdocNo = string.Empty;
                                string ifKey = string.Empty;
                                string pFlag = "RE"; // RE : 양품실적, RC : 폐품생산실적
                                // 생산 실적 첫번째행은 양품실적, 두번째행은 폐품생산실적
                                foreach (DataRow drow in dsTemp.Tables[1].Rows)
                                {
                                    mdocNo = drow["MDOCNO"].ToString();
                                    ifKey = dsTemp.Tables[0].Rows[i]["I_IF_KEY"].ToString();
                                    DataTable dtPFRMData = dtRFCData.Select("MDOCNO = '" + mdocNo + "'").CopyToDataTable();
                                    DataTable dtPFRMTemp = dsTemp.Tables[0].Select("I_IF_KEY = '" + ifKey + "'").CopyToDataTable();
                                    if (i > 0)
                                    {
                                        // 폐품생산실적
                                        rfcType = "LM";
                                        pFlag = "RC";
                                    }
                                    if (sapRFC_P.CallSAPFunc(sRS_PRFM_RFCFN, dtPFRMTemp, dtPFRMData, helper).Equals("S"))
                                    {
                                        // ---- 전달시 MBLNR, MJAHR을 replace 처리하여 하나로 받도록함.
                                        sRfcData = Common.toJsonFormat("PUT_WRKRTN", sapRFC_P.rtnTable).Replace("MBLNR", "RUECK").Replace("MJAHR", "RMZHL");

                                        //SAP 롤백용 추가 CODE 범위 START
                                        string sTempSAP_TYPE = string.Empty;
                                        string sTempIF_KEY = string.Empty;
                                        string sTempMDOC_NO = string.Empty;
                                        string sTempMDOC_SEQNO = string.Empty;

                                        sTempSAP_TYPE = "3.PROD_REG_SAP";
                                        sTempIF_KEY = dsTemp.Tables[0].Rows[i]["I_IF_KEY"].ToString();
                                        sTempMDOC_NO = dsTemp.Tables[1].Rows[i]["MDOCNO"].ToString();
                                        sTempMDOC_SEQNO = dsTemp.Tables[1].Rows[i]["MDOCSEQ"].ToString();

                                        sapTemp.Rows.Add(sTempSAP_TYPE, sTempIF_KEY, sTempMDOC_NO, sTempMDOC_SEQNO, pFlag); // 후단 코드 실행시 EXCEPTION 상황 SAP CANCLE 정보 -- 실적등록
                                        //SAP 롤백용 추가 CODE 범위 END

                                        //실적등록 테이블에 확정문서 번호 갱신
                                        helper.ExecuteNoneQuery("SP_IF_PUT_LAMI_WRKRTN", CommandType.StoredProcedure
                                                                            , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)          // 플랜트
                                                                            , helper.CreateParameter("P_WRK_TYPE", rfcType, DbType.String, ParameterDirection.Input)                    // '0'= 실적테이블_비계획생산, '1'= 폐품테이블, '2'=소요량, '3'=비가동
                                                                            , helper.CreateParameterOracle("P_RFC_DATA", sRfcData, OracleDbType.Clob, ParameterDirection.Input)
                                                                            , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input));
                                        if (helper.RSCODE == "S")
                                        {
                                            bReturn = true;
                                        }
                                        else if (helper.RSCODE == "E")
                                        {
                                            ///helper.Rollback();
                                            LogFile.WriteLog("인쇄/코팅 실적 등록 - SAP 확정문서 등록 오류 [" + helper.RSMSG.ToString());
                                            sMSG_ERR += "확정문서 등록 오류 : " + helper.RSMSG.ToString() + Environment.NewLine;
                                            //new POPUP.MessageForm("실적 등록 - SAP 확정문서 등록 오류\r\n" + helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                            throw new Exception("SAP_ERROR" + sMSG_ERR);  // SAP 로직 진행중 E 발생시 EXCEPTION THROW
                                        }
                                    }
                                    else
                                    {
                                        //helper.Rollback();
                                        LogFile.WriteLog("인쇄/코팅 실적 등록 - SAP 전송 실패 [" + sapRFC_P.rtnMSG);
                                        sMSG_ERR += "실적 등록 오류 : " + sapRFC_P.rtnMSG + Environment.NewLine;
                                        //new POPUP.MessageForm("실적 - 등록 SAP전송이 실패하였습니다.\r\n" + sapRFC_P.rtnMSG, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                        throw new Exception("SAP_ERROR" + sMSG_ERR);  // SAP 로직 진행중 E 발생시 EXCEPTION THROW
                                    }
                                    i++;
                                }
                            }

                            Thread.Sleep(Common.SLEEP_DELAY);
                            System.Windows.Forms.Application.DoEvents();        // 반복작업중 응답없음 안뜨게 하기
                            this.Cursor = Cursors.WaitCursor;   //Waitting                            
                            #endregion
                        }
                        else
                        {
                            bReturn = true;
                        }
                        // 2. 사용량 등록
                        if (/*(bReturn == true) &&*/ (string.IsNullOrEmpty(sRS_INPUT_RFCFN) == false))
                        {
                            #region 폐품 등록
                            bRetDISPO = false;

                            // 문서번호, 문서순번으로  테이블 SORT 하여 전달
                            DataTable dtRFCData = new DataTable();
                            DataView dvPFRM = new DataView(dsTemp.Tables[3]);
                            dvPFRM.Sort = "MDOCNO, MDOCSEQ ASC";
                            dtRFCData = dvPFRM.ToTable();

                            SAPHelper sapRFC_D = new SAPHelper();
                            // sapRFC.CallSAPFunc 호출시 helper를 사용하여 내용이 변경됨. 
                            // 필요한 정보는 sapRFC.CallSAPFunc 호출전에 처리해야함.
                            if (sapRFC_D.CallSAPFunc(sRS_INPUT_RFCFN, dsTemp.Tables[2], dtRFCData, helper).Equals("S"))
                            {
                                // ---- 전달시 MBLNR, MJAHR을 replace 처리하여 하나로 받도록함.
                                sRfcData = Common.toJsonFormat("PUT_WRKRTN", sapRFC_D.rtnTable).Replace("MBLNR", "RUECK").Replace("MJAHR", "RMZHL");

                                //SAP 롤백용 추가 CODE 범위 START
                                string sTempSAP_TYPE = string.Empty;
                                string sTempIF_KEY = string.Empty;
                                string sTempMDOC_NO = string.Empty;
                                string sTempMDOC_SEQNO = string.Empty;

                                sTempSAP_TYPE = "2.SALV_REG_SAP";
                                sTempIF_KEY = dsTemp.Tables[2].Rows[0]["I_IF_KEY"].ToString();
                                foreach (DataRow Rows in dsTemp.Tables[3].Rows)
                                {
                                    sTempMDOC_NO = Rows["MDOCNO"].ToString();
                                    sTempMDOC_SEQNO = Rows["MDOCSEQ"].ToString();
                                    sapTemp.Rows.Add(sTempSAP_TYPE, sTempIF_KEY, sTempMDOC_NO, sTempMDOC_SEQNO, ""); // 후단 코드 실행시 EXCEPTION 상황 SAP CANCLE 정보 -- 실적등록
                                }

                                //SAP 롤백용 추가 CODE 범위 END


                                //실적등록 테이블에 확정문서 번호 갱신
                                helper.ExecuteNoneQuery("SP_IF_PUT_LAMI_WRKRTN", CommandType.StoredProcedure
                                                                    , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)                // 플랜트
                                                                    , helper.CreateParameter("P_WRK_TYPE", "2", DbType.String, ParameterDirection.Input)                  // '0'= 실적테이블_비계획생산, '1'= 폐품테이블, '2'=소요량, '3'=비가동, '9'=영업폐품+잔량폐품
                                                                    , helper.CreateParameterOracle("P_RFC_DATA", sRfcData, OracleDbType.Clob, ParameterDirection.Input)
                                                                    , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input));

                                if (helper.RSCODE == "S")
                                {
                                    bRetDISPO = true;
                                }
                                else //if (helper.RSCODE == "E")
                                {
                                    //helper.Rollback();    // 실적이 성공이면 rollback 처리 안함.
                                    LogFile.WriteLog("인쇄/코팅 실적 등록(폐품) - SAP 확정문서 등록 오류 [" + helper.RSMSG.ToString());
                                    sMSG_ERR += "확정문서 등록(사용량 등록) 오류 : " + helper.RSMSG.ToString() + Environment.NewLine;
                                    throw new Exception("SAP_ERROR" + sMSG_ERR);  // SAP 로직 진행중 E 발생시 EXCEPTION THROW
                                    //new POPUP.MessageForm("실적 등록(폐품) - SAP 확정문서 등록 오류\r\n" + helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                }
                            }
                            else
                            {
                                //helper.Rollback();    // 실적이 성공이면 rollback 처리 안함.
                                LogFile.WriteLog("인쇄/코팅 실적 등록(폐품) - SAP전송 오류 [" + sapRFC_D.rtnMSG);
                                sMSG_ERR += "실적 등록(사용량 등록) 오류 : " + sapRFC_D.rtnMSG + Environment.NewLine;
                                throw new Exception("SAP_ERROR" + sMSG_ERR);  // SAP 로직 진행중 E 발생시 EXCEPTION THROW
                                //new POPUP.MessageForm("실적 등록(폐품) - SAP전송이 실패하였습니다.\r\n" + sapRFC_D.rtnMSG, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                            }

                            Thread.Sleep(Common.SLEEP_DELAY);
                            System.Windows.Forms.Application.DoEvents();        // 반복작업중 응답없음 안뜨게 하기
                            this.Cursor = Cursors.WaitCursor;   //Waitting
                            #endregion
                        }
                    }

                    if (lblPrintChk.Text.ToString() == "V" && sRES_IND_BCD != string.Empty)     // 자동인쇄 처리
                    {
                        //new POPUP.MessageForm("슬리터 개별바코드 [" + sRES_IND_BCD + "]", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                        this.Cursor = Cursors.WaitCursor;

                        int nPrtCnt = ucPNT_CNT.SelectedIndex + 1;

                        PrinterManager.PrintLami(sRES_IND_BCD, nPrtCnt);

                        this.Cursor = Cursors.Default;
                    }

                    if (sMSG_ERR.Length > 0)
                    {
                        new POPUP.MessageForm(sMSG_ERR, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    }
                    else
                    {
                        new POPUP.MessageForm("실적등록이 완료 되었습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                        bRtn = true;
                    }
                }
                else //if (helper.RSCODE == "E")
                {
                    helper.Rollback();
                    new POPUP.MessageForm(helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    this.DialogResult = DialogResult.OK;
                }
            }
            catch (Exception ex)
            {
                this.Cursor = Cursors.Default;

                LogFile.WriteLog(sProcedure + ".doSplit Error => " + ex.Message);
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);

                if (rollTemp.Rows.Count != 0)
                {
                    ProdRollback(helper, sapTemp, rollTemp, dsTemp, ref sMSG_ERR, sRES_IND_BCD);
                }
                this.Cursor = Cursors.Default;   //Waitting

                new POPUP.MessageForm_ERR("실적등록 오류", "실적등록 예외 오류\r\n" + ex.ToString() + Environment.NewLine + sMSG_ERR, MessageBoxButtons.OK).ShowDialog(this);
            }
            finally
            {
                this.Cursor = Cursors.Default;
                helper.Close();
            }
            return bRtn;
        }
        /// <summary>
        /// 실적종료
        /// </summary>
        private bool doSplit_Old()
        {
            DataTable dtList;

            // 작업 시작일시, 종료일시 확인
            string sStartDate = dtpStartDate.Value.ToString("yyyyMMdd") + lblStartTime.Text.ToString().Replace(":", "") + "00";
            string sEndDate = dtpEndDate.Value.ToString("yyyyMMdd") + lblEndTime.Text.ToString().Replace(":", "") + "00";

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

            TimeSpan Diff_dates = dtEndTime.Subtract(dtStartTime);

            string sTM = "";    //가동시간(분)
            if (Diff_dates.TotalMinutes > 0)
            {
                sTM = Diff_dates.TotalMinutes.ToString();
            }
            else
            {
                new POPUP.MessageForm("작업 시작일시~종료일시 입력을 확인하세요!", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return false;
            }

            Decimal dPF_WGT = 0;
            Decimal dPF_DISPO_WGT = 0;
            Decimal orderQty = 0;
            Decimal height = 0;
            Decimal pEquil = 0;
            Decimal pRemainQty = 0;
            Decimal pMeterQty = 0;
            Decimal pMeterSalQty = 0;
            Decimal pPrfnQty = 0;
            Decimal pRollQty = 0;

            Decimal.TryParse(lblPF_WGT.Text.ToString().Replace(",", ""), out dPF_WGT);                          // 실적중량
            Decimal.TryParse(lblORDER_QTY.Text.ToString().Replace(",", ""), out orderQty);                      // 계획량
            Decimal.TryParse(lblPRFN_QTY.Text.ToString().Replace(",", ""), out pPrfnQty);                       // 실적량
            Decimal.TryParse(lblREMAIN_QTY.Text.ToString().Replace(",", ""), out pRemainQty);                   // 잔량실적량
            Decimal.TryParse(lblPRFMMET_QTY.Text.ToString().Replace(",", ""), out pMeterQty);                   // 실적중량 미터
            Decimal.TryParse(lblROLL_QTY.Text.ToString().Replace(",", ""), out pRollQty);                       // 롤 수

            string sProcedure = "SP_POP_WRKLAMI_SL_I04";
            string sFinishType = "N";

            // 중량 확인
            if (dPF_WGT == 0 && dPF_DISPO_WGT == 0)
            {
                new POPUP.MessageForm(string.Format("작업을 완료 하려면 실적을 추가 하세요."), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return false;
            }

            //if ((dPF_WGT == 0) && (dPF_DISPO_WGT > 0))
            //{
            //    new POPUP.MessageForm(string.Format("폐품만 등록하여 작업 완료 처리 할수 없습니다.\r\n\r\n작업을 완료 하려면 실적을 추가 하세요."), MessageBoxButtons.OK, "알   림").ShowDialog(this);
            //    return false;
            //}            

            DBHelper helper = new DBHelper(false, "", true);
            DataSet dsTemp = null;     //실적등록 결과 수신(0:실적 RFC ID, 1:실적 IF 변수, 2:실적 RFC ID, 3:실적 IF 변수)
            bool bReturn = false;       // 실적 처리 결과
            bool bRetDISPO = false;     // 폐품 처리 결과
            bool bRetINP = false;       // 투입량 처리 결과
            string sRES_IND_BCD = "";
            bool bRtn = false;
            DataTable rollTemp = null;
            DataTable sapTemp = null;

            string sMSG_ERR = "";

            try
            {
                this.Cursor = Cursors.WaitCursor;   //Waitting
                //실적저장
                dsTemp = helper.FillDataSetN(sProcedure, CommandType.StoredProcedure, 2
                            , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)                          // 플랜트
                            , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)                      // 작업장코드(설비코드)
                            , helper.CreateParameter("P_ROLLCNT", 1, DbType.Decimal, ParameterDirection.Input)                                      // 권치수
                            , helper.CreateParameter("P_WRK_ORDR_NO", lblWRK_ORDR_NO.Text, DbType.String, ParameterDirection.Input)                 // 작업지시번호
                            , helper.CreateParameter("P_WRK_ORDR_SEQNO", lblWRK_ORDR_SEQNO.Text, DbType.String, ParameterDirection.Input)           // 작업지시번호 순번
                            , helper.CreateParameter("P_WGT", orderQty, DbType.Decimal, ParameterDirection.Input)                                    // 총중량
                            , helper.CreateParameter("P_SDATE", dtStartTime.ToString("yyyyMMddHHmmss"), DbType.String, ParameterDirection.Input)    // 작업시작시간
                            , helper.CreateParameter("P_EDATE", dtEndTime.ToString("yyyyMMddHHmmss"), DbType.String, ParameterDirection.Input)      // 작업종료시간
                            , helper.CreateParameter("P_PRFM_DT", dtEndTime.ToString("yyyyMMdd"), DbType.String, ParameterDirection.Input)          // 생산실적일자
                            , helper.CreateParameter("P_PRFM_QTY", dPF_WGT, DbType.Decimal, ParameterDirection.Input)                              // 실적중량
                            , helper.CreateParameter("P_SALCODE", null, DbType.String, ParameterDirection.Input)         // 폐품코드
                            , helper.CreateParameter("P_SALWEIGHT", Convert.ToString(dPF_DISPO_WGT), DbType.String, ParameterDirection.Input)       // 폐품중량
                            , helper.CreateParameter("P_PPCODE", null, DbType.String, ParameterDirection.Input)                          // 지종
                            , helper.CreateParameter("P_HEIGHT", null, DbType.String, ParameterDirection.Input)                 // 길이
                            , helper.CreateParameter("P_EQUIL", null, DbType.String, ParameterDirection.Input)                                      // 평형
                            , helper.CreateParameter("P_STD", null, DbType.String, ParameterDirection.Input)                                        // 규격
                            , helper.CreateParameter("P_FINISH", sFinishType, DbType.String, ParameterDirection.Input)                              // 완료여부
                            , helper.CreateParameter("P_RMK", txtRemark.Text, DbType.String, ParameterDirection.Input)                              // 비고
                            , helper.CreateParameter("P_SALRMK", null, DbType.String, ParameterDirection.Input)                        // 폐품비고
                            , helper.CreateParameter("P_WRK_CLASS", Common.WorkClass, DbType.String, ParameterDirection.Input)                     // 작업반
                            , helper.CreateParameter("P_WRK_SHIFT", Common.WorkShift, DbType.String, ParameterDirection.Input)                     // 작업조

                            , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input)                            // 사용자ID
                            , helper.CreateParameter("P_PRFMMET_QTY", pMeterQty, DbType.Decimal, ParameterDirection.Input)                          // 실중량 미터f
                            , helper.CreateParameter("P_SALMETER", pMeterSalQty, DbType.Decimal, ParameterDirection.Input)                         // 폐품미터
                            , helper.CreateParameter("P_ROLL_QTY", pRollQty, DbType.Decimal, ParameterDirection.Input)                         // 롤 수
                            , helper.CreateParameter("RS_IND_BCD", DbType.String, ParameterDirection.Output, null, 2000)                    // RES 개별바코드 
                            , helper.CreateParameter("RS_RFCFN", DbType.String, ParameterDirection.Output, null, 2000)                      // RFCFN ID값
                        );

                if (helper.RSCODE == "S")
                {
                    sRES_IND_BCD = helper.Parameters["RS_IND_BCD"].Value.ToString();

                    if (lblPrintChk.Text.ToString() == "V" && sRES_IND_BCD != string.Empty)     // 자동인쇄 처리
                    {
                        //new POPUP.MessageForm("슬리터 개별바코드 [" + sRES_IND_BCD + "]", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                        this.Cursor = Cursors.WaitCursor;

                        int nPrtCnt = ucPNT_CNT.SelectedIndex + 1;

                        PrinterManager.PrintLami(sRES_IND_BCD, nPrtCnt);

                        this.Cursor = Cursors.Default;
                    }

                    if (sMSG_ERR.Length > 0)
                    {
                        new POPUP.MessageForm(sMSG_ERR, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    }
                    else
                    {
                        new POPUP.MessageForm("분할등록 완료 되었습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                        bRtn = true;
                    }
                }
                else //if (helper.RSCODE == "E")
                {
                    //helper.Rollback();
                    new POPUP.MessageForm(helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    this.DialogResult = DialogResult.OK;
                }
            }
            catch (Exception ex)
            {
                this.Cursor = Cursors.Default;

                LogFile.WriteLog(sProcedure + ".doSplit Error => " + ex.Message);
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);

                if (rollTemp.Rows.Count != 0)
                {
                    ProdRollback(helper, sapTemp, rollTemp, dsTemp, ref sMSG_ERR, sRES_IND_BCD);
                }
                this.Cursor = Cursors.Default;   //Waitting

                new POPUP.MessageForm_ERR("실적등록 오류", "실적등록 예외 오류\r\n" + ex.ToString() + Environment.NewLine + sMSG_ERR, MessageBoxButtons.OK).ShowDialog(this);
            }
            finally
            {
                this.Cursor = Cursors.Default;
                helper.Close();
            }
            return bRtn;
        }

        /// <summary>
        /// 실적종료
        /// </summary>
        private bool doProduct()
        {
            DataTable dtList;

            // 작업 시작일시, 종료일시 확인
            string sStartDate = dtpStartDate.Value.ToString("yyyyMMdd") + lblStartTime.Text.ToString().Replace(":", "") + "00";
            string sEndDate = dtpEndDate.Value.ToString("yyyyMMdd") + lblEndTime.Text.ToString().Replace(":", "") + "00";

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

            TimeSpan Diff_dates = dtEndTime.Subtract(dtStartTime);

            string sTM = "";    //가동시간(분)
            if (Diff_dates.TotalMinutes > 0)
            {
                sTM = Diff_dates.TotalMinutes.ToString();
            }
            else
            {
                new POPUP.MessageForm("작업 시작일시~종료일시 입력을 확인하세요!", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return false;
            }

            Decimal dPF_WGT = 0;
            Decimal dPF_DISPO_WGT = 0;
            Decimal orderQty = 0;
            Decimal height = 0;
            Decimal pEquil = 0;
            Decimal pRemainQty = 0;
            Decimal pMeterQty = 0;
            Decimal pMeterSalQty = 0;
            Decimal pPrfnQty = 0;
            Decimal pRollQty = 0;

            Decimal.TryParse(lblPF_WGT.Text.ToString().Replace(",", ""), out dPF_WGT);                          // 실적중량
            Decimal.TryParse(lblORDER_QTY.Text.ToString().Replace(",", ""), out orderQty);                      // 계획량
            Decimal.TryParse(lblPRFN_QTY.Text.ToString().Replace(",", ""), out pPrfnQty);                       // 실적량
            Decimal.TryParse(lblREMAIN_QTY.Text.ToString().Replace(",", ""), out pRemainQty);                   // 잔량실적량
            Decimal.TryParse(lblPRFMMET_QTY.Text.ToString().Replace(",", ""), out pMeterQty);                   // 실적중량 미터
            Decimal.TryParse(lblROLL_QTY.Text.ToString().Replace(",", ""), out pRollQty);                       // 롤 수

            string sProcedure = "SP_POP_WRKLAMI_SL_I02";
            string sFinishType = "Y";

            DBHelper helper = new DBHelper(false, "", true);
            DataSet dsTemp = null;     //실적등록 결과 수신(0:실적 RFC ID, 1:실적 IF 변수, 2:실적 RFC ID, 3:실적 IF 변수)
            bool bReturn = false;       // 실적 처리 결과
            bool bRetINP = false;       // 투입량 처리 결과
            string sRES_IND_BCD = "";
            bool bRtn = false;
            DataTable rollTemp = null;
            DataTable sapTemp = null;

            string sMSG_ERR = "";

            try
            {
                this.Cursor = Cursors.WaitCursor;   //Waitting
                //실적저장
                dsTemp = helper.FillDataSetN(sProcedure, CommandType.StoredProcedure, 4
                            , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)                          // 플랜트
                            , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)                      // 작업장코드(설비코드)
                            , helper.CreateParameter("P_ROLLCNT", 1, DbType.Decimal, ParameterDirection.Input)                                      // 권치수
                            , helper.CreateParameter("P_WRK_ORDR_NO", lblWRK_ORDR_NO.Text, DbType.String, ParameterDirection.Input)                 // 작업지시번호
                            , helper.CreateParameter("P_WRK_ORDR_SEQNO", lblWRK_ORDR_SEQNO.Text, DbType.String, ParameterDirection.Input)           // 작업지시번호 순번
                            , helper.CreateParameter("P_LOT_NO", lblINPUTLOTNO.Text, DbType.String, ParameterDirection.Input)                       // 투입 LOTNO
                            , helper.CreateParameter("P_WGT", orderQty, DbType.Decimal, ParameterDirection.Input)                                    // 총중량
                            , helper.CreateParameter("P_SDATE", dtStartTime.ToString("yyyyMMddHHmmss"), DbType.String, ParameterDirection.Input)    // 작업시작시간
                            , helper.CreateParameter("P_EDATE", dtEndTime.ToString("yyyyMMddHHmmss"), DbType.String, ParameterDirection.Input)      // 작업종료시간
                            , helper.CreateParameter("P_PRFM_DT", dtEndTime.ToString("yyyyMMdd"), DbType.String, ParameterDirection.Input)          // 생산실적일자
                            , helper.CreateParameter("P_PRFM_QTY", dPF_WGT, DbType.Decimal, ParameterDirection.Input)                              // 실적중량
                            , helper.CreateParameter("P_SALCODE", null, DbType.String, ParameterDirection.Input)         // 폐품코드
                            , helper.CreateParameter("P_SALWEIGHT", Convert.ToString(dPF_DISPO_WGT), DbType.String, ParameterDirection.Input)       // 폐품중량
                            , helper.CreateParameter("P_PPCODE", null, DbType.String, ParameterDirection.Input)                          // 지종
                            , helper.CreateParameter("P_HEIGHT", null, DbType.String, ParameterDirection.Input)                 // 길이
                            , helper.CreateParameter("P_EQUIL", null, DbType.String, ParameterDirection.Input)                                      // 평형
                            , helper.CreateParameter("P_STD", null, DbType.String, ParameterDirection.Input)                                        // 규격
                            , helper.CreateParameter("P_FINISH", sFinishType, DbType.String, ParameterDirection.Input)                              // 완료여부
                            , helper.CreateParameter("P_RMK", txtRemark.Text, DbType.String, ParameterDirection.Input)                              // 비고
                            , helper.CreateParameter("P_SALRMK", null, DbType.String, ParameterDirection.Input)                        // 폐품비고
                            , helper.CreateParameter("P_WRK_CLASS", Common.WorkClass, DbType.String, ParameterDirection.Input)                     // 작업반
                            , helper.CreateParameter("P_WRK_SHIFT", Common.WorkShift, DbType.String, ParameterDirection.Input)                     // 작업조

                            , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input)                            // 사용자ID
                            , helper.CreateParameter("P_PRFMMET_QTY", pMeterQty, DbType.Decimal, ParameterDirection.Input)                          // 실중량 미터f
                            , helper.CreateParameter("P_SALMETER", pMeterSalQty, DbType.Decimal, ParameterDirection.Input)                         // 폐품미터
                            , helper.CreateParameter("P_ROLL_QTY", pRollQty, DbType.Decimal, ParameterDirection.Input)                         // 롤 수

                            , helper.CreateParameter("RS_PRFM_RFCFN", DbType.String, ParameterDirection.Output, null, 2000)                         // 실적 RFCFN값
                            , helper.CreateParameter("RS_INPUT_RFCFN", DbType.String, ParameterDirection.Output, null, 2000)                         // 투입 RFCFN값

                            , helper.CreateParameter("RS_IND_BCD", DbType.String, ParameterDirection.Output, null, 2000)                    // RES 개별바코드 
                            , helper.CreateParameter("RS_RFCFN", DbType.String, ParameterDirection.Output, null, 2000)                      // RFCFN ID값
                        );

                if (helper.RSCODE == "S")
                {
                    sRES_IND_BCD = helper.Parameters["RS_IND_BCD"].Value.ToString();

                    // 실적종료일 경우 RFC CALL
                    if (sFinishType == "Y")
                    {
                        string sRS_PRFM_RFCFN = helper.Parameters["RS_PRFM_RFCFN"].Value.ToString();      // 실적 RFCFN ID
                        string sRS_INPUT_RFCFN = helper.Parameters["RS_INPUT_RFCFN"].Value.ToString();    // 투입량 RFCFN ID

                        //SAP 롤백용 추가 CODE 범위 START
                        sapTemp = new DataTable(); // 성공한 sap 정보 저장
                        sapTemp.Columns.Add("SAP_TYPE", typeof(string));
                        sapTemp.Columns.Add("IF_KEY", typeof(string));
                        sapTemp.Columns.Add("MDOCNO", typeof(string));
                        sapTemp.Columns.Add("MDOCSEQ", typeof(string));

                        rollTemp = new DataTable(); // ROLLBACK용 정보 저장
                        rollTemp.Columns.Add("MDOCNO", typeof(string));
                        rollTemp.Columns.Add("MDOCSEQ", typeof(string));
                        //SAP 롤백용 추가 CODE 범위 END

                        //SAP 롤백용 추가 CODE 범위 START
                        if (dsTemp.Tables[1].Columns[0].ColumnName != "1")
                        {
                            foreach (DataRow Rows in dsTemp.Tables[1].Rows)
                            {
                                string rollTempMDOC_NO_1 = Rows["MDOCNO"].ToString();
                                string rollTempMDOC_SEQNO_1 = Rows["MDOCSEQ"].ToString();
                                rollTemp.Rows.Add(rollTempMDOC_NO_1, rollTempMDOC_SEQNO_1);
                            }
                        }
                        //SAP 롤백용 추가 CODE 범위 END

                        //dsTemp.Tables[0];     // 실적 인터페이스 파라미터
                        //dsTemp.Tables[1];     // 실적 인터페이스 상세 파라미터
                        //dsTemp.Tables[2];     // 투입량 인터페이스 파라미터
                        //dsTemp.Tables[3];     // 투입량 인터페이스 상세 파라미터

#if  false
                        this.Cursor = Cursors.Default;   //Waitting

                        if (helper.RSCODE == "E")
                        {
                            new POPUP.MessageForm(helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                        }

                        helper.Rollback();
                        return Common.ERROR_FAIL;
#endif

                        string sRfcData; //RFC결과 JSON 변환
                        bReturn = false;

                        if ((string.IsNullOrEmpty(sRS_PRFM_RFCFN) == false) || (string.IsNullOrEmpty(sRS_INPUT_RFCFN) == false))
                        {
                            // 1. 실적 등록 (밀롤 완료 플래그 때문에 마지막에 보냄)
                            if (string.IsNullOrEmpty(sRS_PRFM_RFCFN) == false)
                            {
                                #region 실적 등록
                                // 문서번호, 문서순번으로  테이블 SORT 하여 전달
                                DataTable dtRFCData = new DataTable();
                                DataView dvPFRM = new DataView(dsTemp.Tables[1]);
                                dvPFRM.Sort = "MDOCNO, MDOCSEQ ASC";
                                dtRFCData = dvPFRM.ToTable();

                                //SAP 실적 등록
                                SAPHelper sapRFC_P = new SAPHelper();
                                // sapRFC.CallSAPFunc 호출시 helper를 사용하여 내용이 변경됨. 
                                // 필요한 정보는 sapRFC.CallSAPFunc 호출전에 처리해야함.
                                if (dtRFCData.Rows.Count > 0)
                                {
                                    if (sapRFC_P.CallSAPFunc(sRS_PRFM_RFCFN, dsTemp.Tables[0], dtRFCData, helper).Equals("S"))
                                    {
                                        // ---- 전달시 MBLNR, MJAHR을 replace 처리하여 하나로 받도록함.
                                        sRfcData = Common.toJsonFormat("PUT_WRKRTN", sapRFC_P.rtnTable).Replace("MBLNR", "RUECK").Replace("MJAHR", "RMZHL");

                                        //SAP 롤백용 추가 CODE 범위 START
                                        string sTempSAP_TYPE = string.Empty;
                                        string sTempIF_KEY = string.Empty;
                                        string sTempMDOC_NO = string.Empty;
                                        string sTempMDOC_SEQNO = string.Empty;

                                        sTempSAP_TYPE = "3.PROD_REG_SAP";
                                        sTempIF_KEY = dsTemp.Tables[0].Rows[0]["I_IF_KEY"].ToString();
                                        sTempMDOC_NO = dsTemp.Tables[1].Rows[0]["MDOCNO"].ToString();
                                        sTempMDOC_SEQNO = dsTemp.Tables[1].Rows[0]["MDOCSEQ"].ToString();

                                        sapTemp.Rows.Add(sTempSAP_TYPE, sTempIF_KEY, sTempMDOC_NO, sTempMDOC_SEQNO); // 후단 코드 실행시 EXCEPTION 상황 SAP CANCLE 정보 -- 실적등록
                                        //SAP 롤백용 추가 CODE 범위 END

                                        //실적등록 테이블에 확정문서 번호 갱신
                                        helper.ExecuteNoneQuery("SP_IF_PUT_LAMI_WRKRTN", CommandType.StoredProcedure
                                                                            , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)          // 플랜트
                                                                            , helper.CreateParameter("P_WRK_TYPE", "SL", DbType.String, ParameterDirection.Input)                    // '0'= 실적테이블_비계획생산, '1'= 폐품테이블, '2'=소요량, '3'=비가동
                                                                            , helper.CreateParameterOracle("P_RFC_DATA", sRfcData, OracleDbType.Clob, ParameterDirection.Input)
                                                                            , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input));
                                        if (helper.RSCODE == "S")
                                        {
                                            bReturn = true;
                                        }
                                        else if (helper.RSCODE == "E")
                                        {
                                            ///helper.Rollback();
                                            LogFile.WriteLog("슬리팅 실적 등록 - SAP 확정문서 등록 오류 [" + helper.RSMSG.ToString());
                                            sMSG_ERR += "확정문서 등록 오류 : " + helper.RSMSG.ToString() + Environment.NewLine;
                                            //new POPUP.MessageForm("실적 등록 - SAP 확정문서 등록 오류\r\n" + helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                            throw new Exception("SAP_ERROR" + sMSG_ERR);  // SAP 로직 진행중 E 발생시 EXCEPTION THROW
                                        }
                                    }
                                    else
                                    {
                                        //helper.Rollback();
                                        LogFile.WriteLog("슬리팅 실적 등록 - SAP 전송 실패 [" + sapRFC_P.rtnMSG);
                                        sMSG_ERR += "실적 등록 오류 : " + sapRFC_P.rtnMSG + Environment.NewLine;
                                        //new POPUP.MessageForm("실적 - 등록 SAP전송이 실패하였습니다.\r\n" + sapRFC_P.rtnMSG, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                        throw new Exception("SAP_ERROR" + sMSG_ERR);  // SAP 로직 진행중 E 발생시 EXCEPTION THROW
                                    }
                                }

                                Thread.Sleep(Common.SLEEP_DELAY);
                                System.Windows.Forms.Application.DoEvents();        // 반복작업중 응답없음 안뜨게 하기
                                this.Cursor = Cursors.WaitCursor;   //Waitting                            
                                #endregion
                            }
                            else
                            {
                                bReturn = true;
                            }
                            
                            // 4. 투입량 등록 - 라미네이팅은 투입없음
                            if (/*(bReturn == true) &&*/ (string.IsNullOrEmpty(sRS_INPUT_RFCFN) == false))
                            {
                                #region 투입량 등록
                                bRetINP = false;

                                // 문서번호, 문서순번으로  테이블 SORT 하여 전달
                                DataTable dtRFCData = new DataTable();
                                DataView dvPFRM = new DataView(dsTemp.Tables[3]);
                                dvPFRM.Sort = "MDOCNO, MDOCSEQ ASC";
                                dtRFCData = dvPFRM.ToTable();

                                SAPHelper sapRFC_I = new SAPHelper();
                                // sapRFC.CallSAPFunc 호출시 helper를 사용하여 내용이 변경됨. 
                                // 필요한 정보는 sapRFC.CallSAPFunc 호출전에 처리해야함.
                                if (sapRFC_I.CallSAPFunc(sRS_INPUT_RFCFN, dsTemp.Tables[2], dtRFCData, helper).Equals("S"))
                                {
                                    // ---- 전달시 MBLNR, MJAHR을 replace 처리하여 하나로 받도록함.
                                    sRfcData = Common.toJsonFormat("PUT_WRKRTN", sapRFC_I.rtnTable).Replace("MBLNR", "RUECK").Replace("MJAHR", "RMZHL");


                                    //SAP 롤백용 추가 CODE 범위 START
                                    string sTempSAP_TYPE = string.Empty;
                                    string sTempIF_KEY = string.Empty;
                                    string sTempMDOC_NO = string.Empty;
                                    string sTempMDOC_SEQNO = string.Empty;

                                    sTempSAP_TYPE = "4.WIP_REG_SAP";
                                    sTempIF_KEY = dsTemp.Tables[2].Rows[0]["I_IF_KEY"].ToString();
                                    foreach (DataRow Rows in dsTemp.Tables[3].Rows)
                                    {
                                        sTempMDOC_NO = Rows["MDOCNO"].ToString();
                                        sTempMDOC_SEQNO = Rows["MDOCSEQ"].ToString();
                                        sapTemp.Rows.Add(sTempSAP_TYPE, sTempIF_KEY, sTempMDOC_NO, sTempMDOC_SEQNO); // 후단 코드 실행시 EXCEPTION 상황 SAP CANCLE 정보 -- 실적등록
                                    }
                                    //SAP 롤백용 추가 CODE 범위 END


                                    //실적등록 테이블에 확정문서 번호 갱신
                                    helper.ExecuteNoneQuery("SP_IF_PUT_LAMI_WRKRTN", CommandType.StoredProcedure
                                                                        , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)                // 플랜트
                                                                        , helper.CreateParameter("P_WRK_TYPE", "8", DbType.String, ParameterDirection.Input)                  // '0'= 실적테이블_비계획생산, '1'= 폐품테이블, '2'=소요량, '3'=비가동
                                                                        , helper.CreateParameterOracle("P_RFC_DATA", sRfcData, OracleDbType.Clob, ParameterDirection.Input)
                                                                        , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input));

                                    if (helper.RSCODE == "S")
                                    {
                                        bRetINP = true;
                                    }
                                    else if (helper.RSCODE == "E")
                                    {
                                        //helper.Rollback();
                                        LogFile.WriteLog("슬리팅 실적 등록(투입량) - SAP 확정문서 등록 오류 [" + helper.RSMSG.ToString());
                                        sMSG_ERR += "확정문서 등록(투입량) 오류 : " + helper.RSMSG.ToString() + Environment.NewLine;
                                        throw new Exception("SAP_ERROR" + sMSG_ERR);
                                        //new POPUP.MessageForm("실적 등록(투입량) - SAP 확정문서 등록 오류\r\n" + helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                    }

                                }
                                else
                                {
                                    //helper.Rollback();
                                    LogFile.WriteLog("슬리팅 실적 등록(투입량) - SAP전송 오류 [" + sapRFC_I.rtnMSG);
                                    sMSG_ERR += "실적 등록(투입량) 오류 : " + sapRFC_I.rtnMSG + Environment.NewLine;
                                    throw new Exception("SAP_ERROR" + sMSG_ERR);
                                    //new POPUP.MessageForm("실적 등록(투입량) - SAP전송이 실패하였습니다.\r\n" + sapRFC_I.rtnMSG, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                }

                                Thread.Sleep(Common.SLEEP_DELAY);
                                System.Windows.Forms.Application.DoEvents();        // 반복작업중 응답없음 안뜨게 하기
                                this.Cursor = Cursors.WaitCursor;   //Waitting
                                #endregion
                            }
                        }
                    }

                    if (lblPrintChk.Text.ToString() == "V" && sRES_IND_BCD != string.Empty)     // 자동인쇄 처리
                    {
                        //new POPUP.MessageForm("슬리터 개별바코드 [" + sRES_IND_BCD + "]", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                        this.Cursor = Cursors.WaitCursor;

                        int nPrtCnt = ucPNT_CNT.SelectedIndex + 1;

                        PrinterManager.PrintLami(sRES_IND_BCD, nPrtCnt);

                        this.Cursor = Cursors.Default;
                    }

                    if (sMSG_ERR.Length > 0)
                    {
                        new POPUP.MessageForm(sMSG_ERR, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    }
                    else
                    {
                        new POPUP.MessageForm("실적등록 완료 되었습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                        bRtn = true;
                    }
                }
                else //if (helper.RSCODE == "E")
                {
                    //helper.Rollback();
                    new POPUP.MessageForm(helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    this.DialogResult = DialogResult.OK;
                }
            }
            catch (Exception ex)
            {
                this.Cursor = Cursors.Default;

                LogFile.WriteLog(sProcedure + ".doProduct Error => " + ex.Message);
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);

                if (rollTemp != null)
                {
                    if (rollTemp.Rows.Count != 0)
                    {
                        ProdRollback(helper, sapTemp, rollTemp, dsTemp, ref sMSG_ERR, sRES_IND_BCD);
                    }
                }

                this.Cursor = Cursors.Default;   //Waitting

                new POPUP.MessageForm_ERR("실적등록 오류", "실적등록 예외 오류\r\n" + ex.ToString() + Environment.NewLine + sMSG_ERR, MessageBoxButtons.OK).ShowDialog(this);
            }
            finally
            {
                this.Cursor = Cursors.Default;
                helper.Close();
            }
            return bRtn;
        }

        private void ProdRollback(DBHelper helper, DataTable sapTemp, DataTable rollTemp, DataSet dsTemp, ref string sMSG_ERR, string rsIndBcd)
        {

            try
            {
                string rsRfcData; //RFC결과 JSON 변환
                string notUseIF_ID_1 = string.Empty;
                string notUseIF_ID_2 = string.Empty;
                string notUseIF_ID_3 = string.Empty;

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
                // 1.2 투입량 인터페이스
                if (dsTemp.Tables[2].Rows[0][0].ToString() != "1")
                {
                    notUseIF_ID_1 = dsTemp.Tables[2].Rows[0]["I_IF_ID"].ToString();
                    foreach (DataRow notUseRows in dsTemp.Tables[3].Rows)
                    {
                        helper.ExecuteNoneQuery("SP_IF_NOT_USE_FLAG", CommandType.StoredProcedure
                            , helper.CreateParameter("P_MES_IF_ID", notUseIF_ID_1, DbType.String, ParameterDirection.Input)
                            , helper.CreateParameter("P_DOC_NO", notUseRows["MDOCNO"].ToString(), DbType.String, ParameterDirection.Input)
                            , helper.CreateParameter("P_DOC_SEQNO", notUseRows["MDOCSEQ"].ToString(), DbType.String, ParameterDirection.Input)
                            , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input));
                    }
                }

                // 2. SAP로 ROLLBACK 전송
                if (sapTemp.Rows.Count != 0)
                {
                    sapTemp = sapTemp.Select("", "SAP_TYPE ASC").CopyToDataTable<DataRow>();
                    foreach (DataRow Rows in sapTemp.Rows)
                    {
                        LogFile.WriteLog("=====SAP ROLLBACK START=====", LogType.PROC);
                        switch (Rows["SAP_TYPE"].ToString())
                        {
                            // 2.3  실적 ROLLBACK
                            case "3.PROD_REG_SAP":
                                LogFile.WriteLog("=====3.PROD_REG_SAP=====" + Rows["MDOCNO"].ToString() + "-" + Rows["MDOCSEQ"].ToString(), LogType.PROC);
                                dsTemp = helper.FillDataSetN("SP_POP_LAMI_SL_IFR01", CommandType.StoredProcedure, 2
                                       , helper.CreateParameter("P_DOC_NO", Rows["MDOCNO"].ToString(), DbType.String, ParameterDirection.Input)
                                       , helper.CreateParameter("P_DOC_SEQNO", Rows["MDOCSEQ"].ToString(), DbType.String, ParameterDirection.Input)
                                       , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input)
                                       , helper.CreateParameter("RS_RFCFN", DbType.String, ParameterDirection.Output, null, 30)
                                        );
                                string sRS_RFCFN_1 = helper.Parameters["RS_RFCFN"].Value.ToString();
                                SAPHelper sapRFC_1 = new SAPHelper();
                                if (sapRFC_1.CallSAPFunc(sRS_RFCFN_1, dsTemp.Tables[0], dsTemp.Tables[1], helper).Equals("S"))
                                {
                                    rsRfcData = Common.toJsonFormat("PUT_WRKRTN", sapRFC_1.rtnTable).Replace("MBLNR", "RUECK").Replace("MJAHR", "RMZHL");
                                    helper.ExecuteNoneQuery("SP_IF_PUT_LAMI_WRKRTN", CommandType.StoredProcedure
                                    , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)              // 플랜트
                                    , helper.CreateParameter("P_WRK_TYPE", "0", DbType.String, ParameterDirection.Input)                        // '0'= 실적테이블, 비계획생산, '1'= 폐품테이블, '2'=소요량, '3'=비가동,
                                    , helper.CreateParameterOracle("P_RFC_DATA", rsRfcData, OracleDbType.Clob, ParameterDirection.Input)
                                    , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input));

                                    if (helper.RSCODE == "S")
                                    {
                                        LogFile.WriteLog("슬리팅 실적등록 ROLLBACK COMPLETE", LogType.PROC);
                                    }
                                    else //if (helper.RSCODE == "E")
                                    {
                                        LogFile.WriteLog("슬리팅 ROLLBACK 등록 - SAP 확정문서 등록 오류 [" + helper.RSMSG.ToString() + "]");
                                        sMSG_ERR += "ROLLBACK 확정문서 등록 오류 : " + helper.RSMSG.ToString() + Environment.NewLine;
                                    }

                                    // DELAY 
                                    Thread.Sleep(Common.SLEEP_DELAY);
                                    System.Windows.Forms.Application.DoEvents();        // 반복작업중 응답없음 안뜨게 하기
                                }
                                else
                                {
                                    LogFile.WriteLog("슬리팅 ROLLBACK 오류 - SAP전송 오류 [" + sapRFC_1.rtnMSG + "]");
                                    sMSG_ERR += "슬리팅 ROLLBACK 오류 : " + sapRFC_1.rtnMSG + Environment.NewLine;
                                }
                                break;
                            // 2.4 투입량 ROLLBACK
                            case "4.WIP_REG_SAP":
                                LogFile.WriteLog("=====4.WIP_REG_SAP=====" + Rows["MDOCNO"].ToString() + "-" + Rows["MDOCSEQ"].ToString(), LogType.PROC);
                                dsTemp = helper.FillDataSetN("SP_POP_WRK26_IFR04", CommandType.StoredProcedure, 2
                                       , helper.CreateParameter("P_DOC_NO", Rows["MDOCNO"].ToString(), DbType.String, ParameterDirection.Input)
                                       , helper.CreateParameter("P_DOC_SEQNO", Rows["MDOCSEQ"].ToString(), DbType.String, ParameterDirection.Input)
                                       , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input)
                                       , helper.CreateParameter("RS_RFCFN", DbType.String, ParameterDirection.Output, null, 30)
                                        );
                                string sRS_RFCFN_4 = helper.Parameters["RS_RFCFN"].Value.ToString();
                                SAPHelper sapRFC_4 = new SAPHelper();
                                if (sapRFC_4.CallSAPFunc(sRS_RFCFN_4, dsTemp.Tables[0], dsTemp.Tables[1], helper).Equals("S"))
                                {
                                    rsRfcData = Common.toJsonFormat("PUT_WRKRTN", sapRFC_4.rtnTable).Replace("MBLNR", "RUECK").Replace("MJAHR", "RMZHL");
                                    helper.ExecuteNoneQuery("SP_IF_PUT_LAMI_WRKRTN", CommandType.StoredProcedure
                                    , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)              // 플랜트
                                    , helper.CreateParameter("P_WRK_TYPE", "2", DbType.String, ParameterDirection.Input)                        // '0'= 실적테이블, 비계획생산, '1'= 폐품테이블, '2'=소요량, '3'=비가동,
                                    , helper.CreateParameterOracle("P_RFC_DATA", rsRfcData, OracleDbType.Clob, ParameterDirection.Input)
                                    , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input));

                                    if (helper.RSCODE == "S")
                                    {
                                        LogFile.WriteLog("슬리팅 투입량 ROLLBACK COMPLETE", LogType.PROC);
                                    }
                                    else //if (helper.RSCODE == "E")
                                    {
                                        LogFile.WriteLog("슬리팅 ROLLBACK 등록 - SAP 확정문서 등록 오류 [" + helper.RSMSG.ToString() + "]");
                                        sMSG_ERR += "ROLLBACK 확정문서 등록 오류 : " + helper.RSMSG.ToString() + Environment.NewLine;
                                    }
                                }
                                else
                                {
                                    LogFile.WriteLog("재단 ROLLBACK 오류 - SAP전송 오류 [" + sapRFC_4.rtnMSG + "]");
                                    sMSG_ERR += "재단 ROLLBACK 오류 : " + sapRFC_4.rtnMSG + Environment.NewLine;
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
                        //foreach (DataRow Rows in rollTemp.Rows)
                        //{
                        LogFile.WriteLog("=====MES ROLLBACK START=====" + lblWRK_ORDR_NO.Text + "-" + lblWRK_ORDR_SEQNO.Text, LogType.PROC);

                        helper.ExecuteNoneQuery("SP_POP_LAMI_SL_WRKCANCEL_NEW", CommandType.StoredProcedure
                                    , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)              // 플랜트
                                    , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)                      // 설비
                                    , helper.CreateParameter("P_WRK_ORDR_NO", lblWRK_ORDR_NO.Text, DbType.String, ParameterDirection.Input)                 // 작업지시번호
                                    , helper.CreateParameter("P_WRK_ORDR_SEQNO", lblWRK_ORDR_SEQNO.Text, DbType.String, ParameterDirection.Input)         // 작업지시순번
                                    , helper.CreateParameter("P_IND_BCD", rsIndBcd, DbType.String, ParameterDirection.Input)         // 작업지시순번
                                    , helper.CreateParameter("P_CLN_RMK", string.Empty, DbType.String, ParameterDirection.Input));              
                        LogFile.WriteLog("=====MES ROLLBACK END=====" + lblWRK_ORDR_NO.Text + "-" + lblWRK_ORDR_SEQNO.Text, LogType.PROC);
                        //}
                    }
                    sMSG_ERR += "슬리팅 MES ROLLBACK 실적이 취소되었습니다" + Environment.NewLine;
                    LogFile.WriteLog("슬리팅 MES ROLLBACK COMPLETE", LogType.PROC);
                }
                catch (Exception ex1)
                {
                    LogFile.WriteLog("슬리팅 MES ROLLBACK 오류 [" + ex1.Message.ToString() + "]");
                    sMSG_ERR += "슬리팅 MES ROLLBACK 오류 : " + ex1.Message.ToString() + Environment.NewLine;
                }
            }
            SetGrid();
            DoFind();
        }

        #endregion

        #region < EVENT >

        private void timer1_Tick(object sender, EventArgs e)
        {
            if (bABNChk)
            {
                bBox1[0, 3].bAlarm = bBox1[0, 3].bAlarm ? false : true;
                bBox1.RedrawButtons();
            }

            iReSetCnt++;
            if (iReSetCnt % 60 == 0)
            {
                setMachStatus();
                iReSetCnt = 0;
            }
        }

        private void dtpDate_DropDown(object sender, EventArgs e)
        {
            CommonCalendar.CloseCalendar((DateTimePicker)sender);
        }

        private void bBox1_buttonClickEvent(MESButton sender, ButtonBox.ButtonClickEventArg e)
        {
            try
            {
                if (!this.bUseNetwork)
                {
                    SetMessage("네트워크 상태를 확인하시기 바랍니다.");
                    return;
                }

                //타이머 정지
                //timer1.Stop();

                MESButton btn = sender;
                bool isRefresh = false;
                switch (btn.Tag.ToString())
                {
                    case "Order":  //작업지시 선택
                        if (SettingCheck("MR"))
                        {
                            POP_WRK_LAMI_003 WRK_LAMI_003 = new POP_WRK_LAMI_003(Common.OpCode, Common.IOType);
                            if (ShowDialogForm(WRK_LAMI_003) == DialogResult.OK)
                            {
                                isRefresh = true;
                            }
                        }
                        break;
                    case "Worker": //작업자 선택
                        if (SettingCheck("M"))
                        {
                            POP_WRK05 WRK05 = new POP_WRK05(Common.MachineCode, Common.IOType);
                            if (ShowDialogForm(WRK05) == DialogResult.OK)
                            {
                                isRefresh = true;
                            }
                        }
                        break;
                    case "Machine": //설비 선택
                        POP_WRK02 WRK02 = new POP_WRK02(Common.OpCode);
                        if (ShowDialogForm(WRK02) == DialogResult.OK)
                        {
                            isRefresh = true;
                        }
                        break;
                    case "Start": //작업시작
                        if (SettingCheck("MWOR"))
                        {
                            doConfirm(bBox1[0, 3].Tag.ToString());
                            // 작업시작 성공해야 재조회
                            if (bWorkStart)
                            {
                                isRefresh = true;
                            }
                        }
                        break;
                    case "NonOper": //비가동 등록
                        if (SettingCheck("MWO"))
                        {
                            POP_WRK_LAMI_004 WRK_LAMI_004 = new POP_WRK_LAMI_004();
                            if (ShowDialogForm(WRK_LAMI_004) == DialogResult.OK)
                            {
                                isRefresh = true;
                            }
                            else
                            {
                                setMachStatus();
                            }
                        }
                        break;
                    case "Split": // 슬리팅 분할
                        if (SettingCheck("MWOSXRIP"))
                        {
                            sWorkType = "Split";
                            //isRefresh = doSplit();
                            isRefresh = doSplit();
                        }
                        break;
                    case "Product": //실적종료
                        if (SettingCheck("MWOSRP"))
                        {
                            sWorkType = "Product";
                            isRefresh = doProduct();
                        }
                        break;
                    case "Printer":  //프린터설정
                        doPrinter();
                        break;
                    case "Performance": //실적현황
                        POP_WRK_LAMI_006 WRK_LAMI_006 = new POP_WRK_LAMI_006(Common.OpCode, Common.MachineCode);
                        if (ShowDialogForm(WRK_LAMI_006) == DialogResult.OK)
                            isRefresh = true;
                        else
                            isRefresh = false;
                        break;
                    case "Input": //공정투입
                        if (SettingCheck("MWOSR"))
                        {
                            POP_WRK_LAMI_007 WRK007 = new POP_WRK_LAMI_007(lblWRK_ORDR_NO.Text, lblWRK_ORDR_SEQNO.Text, lblINPUTLOTNO.Text, lblINPUT_ORDER_QTY.Text);
                            if (ShowDialogForm(WRK007) == DialogResult.OK)
                                isRefresh = true;
                            else
                                isRefresh = false;
                        }
                        break;
                    case "Cancel": //투입취소
                        if (SettingCheck("MWOSR"))
                        {
                            isRefresh = doCancel();
                        }
                        break;
                }
                if (isRefresh)
                {
                    //화면 복귀후 재조회
                    Common.machSetting();
                    SetGrid();
                    DoFind();
                }
            }
            catch (Oracle.ManagedDataAccess.Client.OracleException oe)
            {
                SetMessage(oe.Message);
                new POPUP.MessageForm(oe.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
            }

            catch (Exception ex)
            {
                SetMessage(ex.Message);
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                LogFile.WriteLog("POP_WRK_LAMI_SL_002.bBox1_buttonClickEvent Error\r\n" + ex.Message);
            }
            finally
            {

            }
        }

        private void butWorkDate_Click(object sender, EventArgs e)
        {
            Button btnTemp = (Button)sender;

            DateTime dt = DateTime.Today;
            if (btnTemp.Tag.ToString() == "startDate")
            {
                dt = dtpStartDate.Value;
            }
            else
            {
                dt = dtpEndDate.Value;
            }

            DAResultDate pop = new DAResultDate(dt);
            pop.ShowDialog(this);
            if (pop.DialogResult == DialogResult.OK)
            {
                string strDate = pop.ResultString.ToString();
                if (btnTemp.Tag.ToString() == "startDate")
                {
                    dtpStartDate.Value = DateTime.Parse(strDate);
                }
                else
                {
                    dtpEndDate.Value = DateTime.Parse(strDate);
                }
            }
        }

        private void lblStatus_Click(object sender, EventArgs e)
        {
            SetGrid();
            DoFind();
        }

        private void Grid1_ClickCellButton(object sender, MESGrid.GridClickEventArg e)
        {
            string[] saORDR_INFO;

            if (e.column.ToString() == "WRK_ORDR_DETAIL") // 상세보기
            {
                saORDR_INFO = e.row.Cells["WRK_ORDR_NO"].Value.ToString().Split('-');
                string sWrkOrder = saORDR_INFO[0];
                string sWrkOrderSeq = saORDR_INFO[1];

                POP_WRK84 popWrk84 = new POP_WRK84(POP_WRK84.PROC_INP, Common.PlantCode, Common.OpCode, sWrkOrder, sWrkOrderSeq);  // 작업지시 정보

                ShowDialogForm(popWrk84);
            }
        }

        private void lblPrintChk_Click(object sender, EventArgs e)
        {
            if (lblPrintChk.Text.ToString().Equals("V"))
                CheckValue(lblPrintChk, string.Empty);
            else
                CheckValue(lblPrintChk, "V");
        }

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

        private void lblPF_WGT_Click(object sender, EventArgs e)
        {
            if (!SettingCheck("OSI"))
                return;
            double dDimension;

            DAResultQty pop = new DAResultQty();
            pop.LabelTitle = "중량 입력";
            pop.LabelHeader = "중량";
            pop.ContentMaxLength = 8;

            pop.ShowDialog(this);

            if (pop.DialogResult == DialogResult.OK)
            {
                dDimension = pop.ResultDouble;
                //중량 입력
                lblPF_WGT.Tag = ((int)dDimension).ToString();
                lblPF_WGT.Text = string.Format("{0:#,##0}", ((int)dDimension)); //중량
                //미터 환산
                double dWgt = Double.Parse(dtNowWrk.Rows[0]["BS_WGT"].ToString());
                double dLen = Double.Parse(dtNowWrk.Rows[0]["WLEN"].ToString());
                double calMeter = Math.Truncate(dDimension / (dWgt / 1000) / (dLen / 1000));
                lblPRFMMET_QTY.Tag = calMeter.ToString();
                lblPRFMMET_QTY.Text = string.Format("{0:#,##0}", calMeter);
            }
        }

        private void lblROLL_QTY_Click(object sender, EventArgs e)
        {
            if (!SettingCheck("OSI"))
                return;
            double dDimension;

            DAResultQty pop = new DAResultQty();
            pop.LabelTitle = "롤 수 입력";
            pop.LabelHeader = "롤 수";
            pop.ContentMaxLength = 8;

            pop.ShowDialog(this);

            if (pop.DialogResult == DialogResult.OK)
            {
                dDimension = pop.ResultDouble;
                //중량 입력
                lblROLL_QTY.Tag = ((int)dDimension).ToString();
                lblROLL_QTY.Text = string.Format("{0:#,##0}", ((int)dDimension)); //중량
            }
        }
        private void lblWorkTime_Click(object sender, EventArgs e)
        {
            MESLabel lblTemp = (MESLabel)sender;
            if (lblMACH_STA.Text != "가동중")
            {
                new POPUP.MessageForm("가동중일때만 입력가능합니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return;
            }
            DAResultTime pop = new DAResultTime();
            pop.ShowDialog(this);
            if (pop.DialogResult == DialogResult.OK)
            {
                lblTemp.Text = pop.ResultString.ToString();
            }
        }

        private void Grid2_ClickCellButton(object sender, MESGrid.GridClickEventArg e)
        {
            // 선택 버튼 클릭시 체크여부 변경
            if (e.column.ToString() == "CHK")
            {
                string sStatus_Pre = e.row.Cells["CHK"].Value.ToString();

                if (sStatus_Pre == "V")
                {
                    e.row.Cells["CHK"].Value = "-";
                }
                else
                {
                    e.row.Cells["CHK"].Value = "V";
                }

                e.row.Update();
            }
        }
        #endregion

        #region < Function >
        private void CheckValue(SmartDas.Components.MESLabel mLavel, string sVlaue)
        {
            mLavel.Text = sVlaue;

            if (string.IsNullOrEmpty(mLavel.Text.Trim()))
                mLavel.BackColor = Color.White;
            else
                mLavel.BackColor = Color.Yellow;
        }

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
            //지시의 상태 구분
            if (pType.Contains("S") && lblMACH_STA.Text.Equals("대기중")) //시작 이후 비가동 기능 사용가능
            {
                new POPUP.MessageForm("현재 작업이 대기상태입니다. 작업시작을 클릭하여 주시기 바랍니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return false;
            }
            if (pType.Contains("R") && lblMACH_STA.Text.Equals("비가동")) //가동중 여부 확인
            {
                new POPUP.MessageForm("현재 비가동 상태입니다.\n비가동 종료후 진행 바랍니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return false;
            }
            if (pType.Contains("P") && Convert.ToInt64(dtNowWrk.Rows[0]["M_IN_QTY"].ToString()) == 0) // 자재투입여부
            {
                new POPUP.MessageForm("공정 투입은 필수입니다.\n투입 후 진행 바랍니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return false;
            }
            //잔량,폐품
            if (dtNowWrk != null)
            {
                if(dtNowWrk.Rows.Count > 0)
                {
                    decimal remainQty = Convert.ToDecimal(dtNowWrk.Rows[0]["REMAIN_QTY"]);
                    if (pType.Contains("I") && remainQty == 0)
                    {
                        new POPUP.MessageForm("잔량이 소진되서 추가가 불가능합니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                        return false;
                    }
                }
            }
            return true;
        }

        private void doPrinter()
        {
            try
            {
                POP_Printer popPrinter = new POP_Printer();
                ShowDialogForm(popPrinter);
            }
            catch (Exception ex)
            {
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
            }
        }
        /// <summary>
        /// 투입취소
        /// </summary>
        private bool doCancel()
        {
            bool bRtn = false;
            if (Convert.ToUInt64(lblINPUT_QTY.Text.Replace(",", "")) == 0)
            {
                new POPUP.MessageForm("투입된 정보가 없습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return bRtn;
            }

            //체크된 항목 확인
            DataTable dtReqList = setReqList();
            int iRowCnt = dtReqList.Rows.Count;

            if (iRowCnt == 0)
            {
                new POPUP.MessageForm("선택된 개별바코드가 없습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return bRtn;
            }

            string sIND_BCD_LIST = "";
            int inQty = 0;
            for (int i = 0; i < iRowCnt; i++)
            {
                // 개별바코드리스트에 포함되지 않은경우 추가...
                if (i < 5)
                {
                    if (i == (iRowCnt - 1))
                        sIND_BCD_LIST += dtReqList.Rows[i]["IND_BCD"].ToString();
                    else
                        sIND_BCD_LIST += dtReqList.Rows[i]["IND_BCD"].ToString() + ", ";
                }
                inQty += Convert.ToInt32(dtReqList.Rows[i]["IN_QTY"].ToString().Replace(",",""));
            }

            //if (!(sIND_BCD.Length == 15 || sIND_BCD.Length == 10))
            //{
            //    new POPUP.MessageForm("개별바코드 형식이 틀립니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
            //    return bRtn;
            //}

            if (new POPUP.MessageForm(string.Format("선택된 개별바코드 \"{0}\"를\r\n[{1}]에 투입 취소 하시겠습니까?", sIND_BCD_LIST, Common.MachineName), MessageBoxButtons.OKCancel, "알   림").ShowDialog(this) == DialogResult.Cancel)
            {
                return bRtn;
            }
            
            DBHelper helper = new DBHelper(false);
            try
            {
                for (int i = 0; i < iRowCnt; i++)
                {
                    string sIND_BCD = dtReqList.Rows[i]["IND_BCD"].ToString();
                    // 투입정보 취소
                    helper.ExecuteNoneQuery("SP_POP_WRK01_LAMI_I02", CommandType.StoredProcedure
                            , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)                          // 플랜트
                            , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)                      // 작업장코드(설비코드)
                            , helper.CreateParameter("P_IND_BCD", sIND_BCD, DbType.Double, ParameterDirection.Input)                                // 개별바코드
                            , helper.CreateParameter("P_WRK_ORDR_NO", lblWRK_ORDR_NO.Text, DbType.Double, ParameterDirection.Input)                 // 작업지시번호
                            , helper.CreateParameter("P_WRK_ORDR_SEQNO", lblWRK_ORDR_SEQNO.Text, DbType.Double, ParameterDirection.Input)           // 작업지시순번
                            , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input)                            // 사용자ID
                            );

                    if (helper.RSCODE == "E")
                    {
                        new POPUP.MessageForm(helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    }
                    else
                    {
                        new POPUP.MessageForm("공정투입 취소가 정상적으로 완료되었습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                        bRtn = true;
                    }
                } 
            }
            catch (Exception ex)
            {
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                LogFile.WriteLog("POP_WRK_LAMI_SL_002.doCancel Error => " + ex.Message);
            }
            finally
            {
                helper.Close();
            }
            return bRtn;
        }
        /// <summary>
        /// 비가동 여부
        /// </summary>
        private void setMachStatus()
        {
            try
            {
                if (dtNowWrk.Rows.Count == 0) return;
                DBHelper helper = new DBHelper();
                DataTable dtTemp = helper.FillTable("SP_POP_WRK_MACH_STATUS", CommandType.StoredProcedure
                                                        , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input));

                if (dtTemp.Rows[0]["MACH_STA"].ToString().Equals("S"))
                {
                    dtNowWrk.Rows[0]["MACH_STA"] = "S";
                    lblMACH_STA.Text = "비가동";
                    bBox1[0, 2].Text = "작업시작";
                    bBox1[0, 2].Tag = "Start";
                    bBox1.RedrawButtons();
                    //비가동시 점멸처리
                    bABNChk = true;
                    //timer1.Start();
                }
                else
                {
                    //가동상태 출력
                    if (sStatus.Equals("N"))
                    {
                        lblMACH_STA.Text = "대기중";
                        bBox1[0, 2].Text = "작업시작";
                        bBox1[0, 2].Tag = "Start";
                        bBox1.RedrawButtons();
                        bABNChk = false;
                        lblEndTime.Text = "";
                    }
                    else
                    {
                        lblMACH_STA.Text = "가동중";

                        bBox1[0, 2].Text = "작업시작";
                        bBox1[0, 2].Tag = "Start";
                        bBox1.RedrawButtons();
                        bABNChk = false;
                        lblStartTime.Text = dtpStartDate.Value.ToString("HH:mm");
                    }
                }
            }
            catch (Exception ex)
            {
                SetMessage("setMachStatus Error!");
                LogFile.WriteLog("POP_WRK_LAMI_SL_002.setMachStatus Error\r\n" + ex.Message);
            }
        }
        private DataTable setReqList()
        {
            DataTable dtRtn = null;
            DataTable dt = (DataTable)Grid2.DataSource;
            dtRtn = dt.Clone();
            try
            {
                foreach (DataRow drow in dt.Rows)
                {
                    if (drow["CHK"].ToString() == "V")
                    {
                        dtRtn.ImportRow(drow);
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return dtRtn;
        }
        #endregion
    }
}
