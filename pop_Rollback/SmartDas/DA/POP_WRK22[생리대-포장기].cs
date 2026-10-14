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

#endregion

namespace SmartDas
{
    public partial class POP_WRK22 : BaseForm
    {
        #region < MEMBER AREA >
        private SAMMI.Common _common = new SAMMI.Common();

        private DataTable dtNowWrk; //현재 작업지시지

        private int iReSetCnt = 0;
        private bool bABNChk = false;
        #endregion

        #region < CONSTRUCTOR >

        public POP_WRK22()
        {
            InitializeComponent();

            Common.SetMessageList();
            this.UpdateMinuteEvent += new UpdateMinuteHandler(Common.dailyLotChange);
        }
        #endregion

        #region < POP_WRK22_Load >
        private void POP_WRK22_Load(object sender, EventArgs e)
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

                this.lblTitle.Text = "생리대-포장기";

                DateTime daysBefore = DateTime.Now;
                daysBefore = daysBefore.AddDays(-7);

                SetMenuButtons();
                SetGrid();
                DoFind();
            }
            catch (Exception ex)
            {
                SetMessage("POP_WRK22_Load_ Error!");
                LogFile.WriteLog("POP_WRK22.POP_WRK22_Load Error\r\n" + ex.Message);
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
                bBox1[0, 2].Text = "설비 선택";
                bBox1[0, 2].Tag = "Machine";
                bBox1[0, 2].MappingButton.FontSize = 14;
                bBox1[0, 3].Text = "작업시작";
                bBox1[0, 3].Tag = "Start";
                bBox1[0, 3].MappingButton.FontSize = 14;
                bBox1[0, 4].Text = "비가동\n등록";
                bBox1[0, 4].Tag = "NonOper";
                bBox1[0, 4].MappingButton.FontSize = 14;
                bBox1[0, 5].Text = "실적등록";
                bBox1[0, 5].Tag = "Product";
                bBox1[0, 5].MappingButton.FontSize = 14;
                bBox1[0, 6].Text = "";
                bBox1[0, 6].Tag = "";
                bBox1[0, 6].MappingButton.FontSize = 14;
                bBox1[0, 7].Text = "";
                bBox1[0, 7].Tag = "";
                bBox1[0, 7].MappingButton.FontSize = 14;
                bBox1[0, 8].Text = "공정체크";
                bBox1[0, 8].Tag = "Check";
                bBox1[0, 8].MappingButton.FontSize = 14;
                bBox1[0, 9].Text = "자재투입\n이력";
                bBox1[0, 9].Tag = "InputLog";
                bBox1[0, 9].MappingButton.FontSize = 14;
                bBox1[0, 10].Text = "실적현황";
                bBox1[0, 10].Tag = "Performance";
                bBox1[0, 10].MappingButton.FontSize = 14;

                bBox1.RedrawButtons();
            }
            catch (Exception ex)
            {
                SetMessage("SetButtons Error!");
                LogFile.WriteLog("POP_WRK22.SetButtons Error\r\n" + ex.Message);
            }
        }

        private void DoFind()
        {
            DateTime dtStartTime;
            DateTime dtEndTime;
            int iTempValue;

            try
            {
                timer1.Start();
                //비가동 알람 초기화
                bBox1[0, 4].bAlarm = false;

                if (dtNowWrk.Rows.Count < 1
                    || string.IsNullOrEmpty(dtNowWrk.Rows[0]["WRK_ORDR_NO"].ToString()))
                {
                    //SetMessage("조회된 작업지시가 없습니다.");
                    //조회된 항목 초기화
                    lblPRD_REQ_DT.Text = string.Empty;//생산지시일
                    lblWRK_ORDR_NO.Text = string.Empty;//작업지시번호
                    lblWRK_ORDR_SEQNO.Text = string.Empty;//작업지시순번
                    lblMATNR.Tag = string.Empty; //자재코드
                    lblMATNR.Text = string.Empty; //자재명
                    lblMATNR_SPEC.Text = string.Empty; //규격
                    lblWRK_ORDR_RMK.Text = string.Empty; //작업지시사항
                    lblORDER_QTY.Text = string.Empty; //계획량
                    lblPLT_QTY.Text = string.Empty; //팔레트
                    lblBOX_QTY.Text = string.Empty; //박스
                    lblBAG_QTY.Text = string.Empty; //폴리백
                    lblEA_QTY.Text = string.Empty; //개수
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
                    //lblPCode.Text = dtNowWrk.Rows[0]["WIDTH"].ToString(); //지종
                    lblMATNR_SPEC.Text = dtNowWrk.Rows[0]["MATNR_SPEC"].ToString(); //규격
                    lblWRK_ORDR_RMK.Text = dtNowWrk.Rows[0]["WRK_ORDR_RMK"].ToString(); //작업지시사항
                    lblUNIT.Text = dtNowWrk.Rows[0]["UNIT"].ToString(); //단위

                    if (int.TryParse(dtNowWrk.Rows[0]["ORDER_QTY"].ToString(), out iTempValue))
                        lblORDER_QTY.Text = string.Format("{0:#,##0}", iTempValue); //계획량
                    else
                        lblORDER_QTY.Text = dtNowWrk.Rows[0]["ORDER_QTY"].ToString();

                    //팔레트
                    if (int.TryParse(dtNowWrk.Rows[0]["PLTQTY"].ToString(), out iTempValue))
                        lblPLT_QTY.Text = iTempValue >= 0 ? string.Format("{0:#,##0}", iTempValue) : string.Empty; //실적량
                    else
                        lblPLT_QTY.Text = dtNowWrk.Rows[0]["PLTQTY"].ToString();
                    //박스
                    if (int.TryParse(dtNowWrk.Rows[0]["BOXQTY"].ToString(), out iTempValue))
                        lblBOX_QTY.Text = iTempValue >= 0 ? string.Format("{0:#,##0}", iTempValue) : string.Empty; //실적량
                    else
                        lblBOX_QTY.Text = dtNowWrk.Rows[0]["BOXQTY"].ToString();
                    //폴리백
                    if (int.TryParse(dtNowWrk.Rows[0]["BAGQTY"].ToString(), out iTempValue))
                        lblBAG_QTY.Text = iTempValue >= 0 ? string.Format("{0:#,##0}", iTempValue) : string.Empty; //실적량
                    else
                        lblBAG_QTY.Text = dtNowWrk.Rows[0]["BAGQTY"].ToString();
                    //개수
                    if (int.TryParse(dtNowWrk.Rows[0]["EAQTY"].ToString(), out iTempValue))
                        lblEA_QTY.Text = iTempValue >= 0 ? string.Format("{0:#,##0}", iTempValue) : string.Empty; //실적량
                    else
                        lblEA_QTY.Text = dtNowWrk.Rows[0]["EAQTY"].ToString();

                    //공통사용항목 관리
                    Common.OrderNo = dtNowWrk.Rows[0]["ORDER_NO"].ToString();//생산오더번호
                    Common.WrkOrderNo = dtNowWrk.Rows[0]["WRK_ORDR_NO"].ToString();//작업지시번호
                    Common.WrkOrderSeq = dtNowWrk.Rows[0]["WRK_ORDR_SEQNO"].ToString();//작업지시순번
                    Common.ItemCode = dtNowWrk.Rows[0]["MATNR"].ToString(); //자재코드

                    //가동상태 출력
                    if (dtNowWrk.Rows[0]["MACH_STA"].ToString().Equals("N"))
                    {
                        lblMACH_STA.Text = "대기중";
                        bBox1[0, 3].Text = "작업시작";
                        bBox1[0, 3].Tag = "Start";
                        bBox1.RedrawButtons();
                        bABNChk = false;
                    }
                    else if (dtNowWrk.Rows[0]["MACH_STA"].ToString().Equals("S"))
                    {
                        lblMACH_STA.Text = "비가동";
                        bBox1[0, 3].Text = "작업시작";
                        bBox1[0, 3].Tag = "Start";
                        bBox1.RedrawButtons();
                        //비가동시 점멸처리
                        //timer1.Start();
                        bABNChk = true;
                    }
                    else
                    {
                        lblMACH_STA.Text = "가동중";
                        //bBox1[0, 3].Text = "작업완료";
                        //bBox1[0, 3].Tag = "End";
                        bBox1[0, 3].Text = "작업시작";
                        bBox1[0, 3].Tag = "Start";
                        bBox1.RedrawButtons();
                        bABNChk = false;
                    }

                    //시작시간 출력
                    if (DateTime.TryParse(dtNowWrk.Rows[0]["PRD_STR_DATE"].ToString(), out dtStartTime))
                        dtpPRD_STR_DATE.Value = dtStartTime;
                    else
                        dtpPRD_STR_DATE.Value = DateTime.Now;
                    lblPRD_STR_TIME.Text = dtpPRD_STR_DATE.Value.ToString("HH:mm");
                    //완료시간 출력
                    if (DateTime.TryParse(dtNowWrk.Rows[0]["PRD_END_DATE"].ToString(), out dtEndTime))
                        dtpPRD_END_DATE.Value = dtEndTime;
                    else
                        dtpPRD_END_DATE.Value = DateTime.Now;
                    lblPRD_END_TIME.Text = dtpPRD_END_DATE.Value.ToString("HH:mm");

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
                SetMessage("SetGrid Error!");
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                LogFile.WriteLog("POP_WRK22.WRK_ORDER Find Error\r\n" + ex.Message);
            }
        }
        private void SetGrid()
        {
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

                dsTemp = helper.FillDataSetN("SP_POP_WRK22_S01", CommandType.StoredProcedure, 3
                                                               , helper.CreateParameter("P_MACHCD", Common.MachineCode, DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_IOTYPE", Common.IOType, DbType.String, ParameterDirection.Input));
                //그리드 출력
                Grid1.DoFind_Oracle(dsTemp);
                //현재 지시정보 저장
                dtNowWrk = dsTemp.Tables[2];
            }
            catch (Exception ex)
            {
                SetMessage("SetGrid Error!");
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                LogFile.WriteLog("POP_WRK21.SetGrid Error\r\n" + ex.Message);
            }
        }

        private void doConfirm(string RegType)
        {
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
            string sStrDt = dtpPRD_STR_DATE.Text + " " + lblPRD_STR_TIME.Text;
            string sEndDt = dtpPRD_END_DATE.Text + " " + lblPRD_END_TIME.Text;
            string sRegDate = (sStatus == "S" ? sStrDt : sEndDt);//등록시간
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
                    new POPUP.MessageForm("현재 작업이 대기상태입니다. 작업시작을 클릭하여 주시기 바랍니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return;
                }
                if (dtStr >= dtEnd)
                {
                    new POPUP.MessageForm("작업 종료일시는 작업시작일시보다 같거나 빠를수 없습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return;
                }

                msgForm = new POPUP.MessageForm("지시의 상태를 변경하시겠습니까?", MessageBoxButtons.OKCancel, "알   림");
                res = msgForm.ShowDialog(this);
                if (res == System.Windows.Forms.DialogResult.OK)
                {
                    //작업시작/완료처리 (작업지시 상태변경 및 작업장 현황의 가동상태 변경)
                    helper.ExecuteNoneQuery("SP_POP_WRK22_U01", CommandType.StoredProcedure
                     , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)
                     , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)
                     , helper.CreateParameter("P_IOTYPE", Common.IOType, DbType.String, ParameterDirection.Input)
                     , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input)
                     , helper.CreateParameter("P_ORDER_NO", Common.OrderNo, DbType.String, ParameterDirection.Input)
                     , helper.CreateParameter("P_WRK_ORDR_NO", Common.WrkOrderNo, DbType.String, ParameterDirection.Input)
                     , helper.CreateParameter("P_WRK_ORDR_SEQNO", Common.WrkOrderSeq, DbType.String, ParameterDirection.Input)
                     , helper.CreateParameter("P_MATNR", Common.ItemCode, DbType.String, ParameterDirection.Input)
                     , helper.CreateParameter("P_STA", sStatus, DbType.String, ParameterDirection.Input)
                     , helper.CreateParameter("P_REGDATE", dRegDate, DbType.String, ParameterDirection.Input));

                    if (helper.RSCODE == "E")
                    {
                        new POPUP.MessageForm(helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                        this.DialogResult = DialogResult.OK;
                        return;
                    }
                    ////버튼 상태 변경
                    //if (sStatus.Equals("S"))
                    //{
                    //    bBox1[0, 3].Text = "작업완료";
                    //    bBox1[0, 3].Tag = "End";
                    //    bBox1.RedrawButtons();

                    //    sMSG = "작업지시가 정상적으로 시작되었습니다.";
                    //}
                    //else
                    //{
                    //    bBox1[0, 3].Text = "작업시작";
                    //    bBox1[0, 3].Tag = "Start";
                    //    bBox1.RedrawButtons();

                    //    sMSG = "작업지시가 정상적으로 완료되었습니다.";
                    //}
                    sMSG = "작업지시가 정상적으로 시작되었습니다.";
                    new POPUP.MessageForm(sMSG, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    SetGrid();
                    DoFind();
                }
            }
            catch (Exception ex)
            {
                SetMessage("SetGrid Error!");
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                LogFile.WriteLog("POP_WRK21.SetGrid Error\r\n" + ex.Message);
            }
            finally
            {
                helper.Close();
            }
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
                new POPUP.MessageForm("지시 상태를 확인하여 주시기 바랍니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return false;
            }
            if (pType.Contains("R") && lblMACH_STA.Text.Equals("비가동")) //가동중 여부 확인
            {
                new POPUP.MessageForm("현재 비가동 상태입니다.\n비가동 종료후 진행 바랍니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return false;
            }
            return true;
        }

        private void timer1_Tick(object sender, EventArgs e)
        {
            if (bABNChk)
            {
                bBox1[0, 4].bAlarm = bBox1[0, 4].bAlarm ? false : true;
                bBox1.RedrawButtons();
            }

            iReSetCnt++;
            if (iReSetCnt % 60 == 0)
            {
                SetGrid();
                DoFind();
                iReSetCnt = 0;
            }
        }

        private void dtpDate_DropDown(object sender, EventArgs e)
        {
            CommonCalendar.CloseCalendar((DateTimePicker)sender);
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

                //타이머 정지
                //timer1.Stop();

                MESButton btn = sender;

                switch (btn.Tag.ToString())
                {
                    case "Order":  //작업지시 선택
                        if (SettingCheck("MR"))
                        {
                            POP_WRK07 WRK07 = new POP_WRK07(Common.OpCode, Common.IOType);
                            ShowDialogForm(WRK07);
                            SetGrid();
                        }
                        break;
                    case "Worker": //작업자 선택
                        if (SettingCheck("M"))
                        {
                            POP_WRK05 WRK05 = new POP_WRK05(Common.MachineCode, Common.IOType);
                            ShowDialogForm(WRK05);
                        }
                        break;
                    case "Machine": //설비 선택
                        POP_WRK02 WRK02 = new POP_WRK02();
                        ShowDialogForm(WRK02);
                        break;
                    case "Start": //작업시작
                        if (SettingCheck("MWOR"))
                        {
                            doConfirm(bBox1[0, 3].Tag.ToString());
                        }
                        break;
                    case "End": //작업완료
                        if (SettingCheck("MWO"))
                        {
                            doConfirm(bBox1[0, 3].Tag.ToString());
                        }
                        break;
                    case "NonOper": //비가동 등록
                        if (SettingCheck("MW"))
                        {
                            POP_WRK03 WRK03 = new POP_WRK03();
                            ShowDialogForm(WRK03);
                        }
                        break;
                    case "Product": //실적등록
                        if (SettingCheck("MWOSR"))
                        {
                            POP_WRK16 WRK16 = new POP_WRK16(dtNowWrk);
                            ShowDialogForm(WRK16);
                        }
                        break;
                    case "Check": //공정체크
                        if (SettingCheck("MW"))
                        {
                            POP_WRK04 WRK04 = new POP_WRK04();
                            ShowDialogForm(WRK04);
                        }
                        break;
                    case "InputLog": //자재 투입이력
                        POP_INV02 INV02 = new POP_INV02();
                        ShowDialogForm(INV02);
                        break;
                    case "Performance": //실적현황
                        POP_WRK20 WRK20 = new POP_WRK20();
                        ShowDialogForm(WRK20);
                        break;
                }
                //화면 복귀후 재조회
                Common.machSetting();
                SetGrid();
                DoFind();
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
                LogFile.WriteLog("POP_WRK22.bBox1_buttonClickEvent Error\r\n" + ex.Message);
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
                dt = dtpPRD_STR_DATE.Value;
            }
            else
            {
                dt = dtpPRD_END_DATE.Value;
            }

            DAResultDate pop = new DAResultDate(dt);
            pop.ShowDialog(this);
            if (pop.DialogResult == DialogResult.OK)
            {
                string strDate = pop.ResultString.ToString();
                if (btnTemp.Tag.ToString() == "startDate")
                {
                    dtpPRD_STR_DATE.Value = DateTime.Parse(strDate);
                }
                else
                {
                    dtpPRD_END_DATE.Value = DateTime.Parse(strDate);
                }
            }
        }

        private void lblWorkTime_Click(object sender, EventArgs e)
        {
            MESLabel lblTemp = (MESLabel)sender;
            DAResultTime pop = new DAResultTime();
            pop.ShowDialog(this);
            if (pop.DialogResult == DialogResult.OK)
            {
                lblTemp.Text = pop.ResultString.ToString();
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
        #endregion

    }
}
