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

using System.Threading;
using System.Globalization;

#endregion

namespace SmartDas
{
    public partial class POP_WRK51 : BaseForm
    {
        #region < MEMBER AREA >

        private SAMMI.Common _common = new SAMMI.Common();
        Configuration appConfig = ConfigurationManager.OpenExeConfiguration(ConfigurationUserLevel.None);

        private int iSelRow = -1; //그리드 선택된 행
        private DataTable dtNowWrk; //현재 작업지시지
        private int iReSetCnt = 0;
        private bool bABNChk = false;

        #endregion

        #region < CONSTRUCTOR >

        public POP_WRK51()
        {
            InitializeComponent();

            Common.SetMessageList();
            this.UpdateMinuteEvent += new UpdateMinuteHandler(Common.dailyLotChange);
        }

        //public void CallUpdateMinuteFunc()
        //{
        //    //설비별 LOT_NO 확인
        //    DBHelper helper = new DBHelper(false, "", true);
        //    helper.ExecuteNoneQuery("SP_SET_LOT_NO", CommandType.StoredProcedure
        //                                                      , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)
        //                                                      , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)
        //                                                      , helper.CreateParameter("P_IOTYPE", Common.IOType, DbType.String, ParameterDirection.Input));
        //    if (helper.RSCODE.Equals("S"))
        //        helper.Commit();
        //    else
        //        helper.Rollback();
        //}
        #endregion

        #region < POP_WRK51_Load >
        private void POP_WRK51_Load(object sender, EventArgs e)
        {
            try
            {
                #region --- 언어 설정 → 모듈별로 화면 첫 화면 분기되는 화면에 해당 코드 삽입 ---
                SAMMI.Common.SystemID = appConfig.AppSettings.Settings["SystemID"].Value.ToString();
                SAMMI.Common.Lang = appConfig.AppSettings.Settings["LANGUAGE"].Value.ToString();


                DataTable rtnDtTemp = _common.GET_TBM0000_CODE("LANGKY");

                SAMMI.Common.FontName = Convert.ToString(((DataRow[])rtnDtTemp.Select("CODE_ID = '" + SAMMI.Common.Lang + "'"))[0]["RelCode1"]);

                #endregion

                //설비정보 설정호출
                Common.machSetting();

                this.lblTitle.Text = "합지기 판매용원단";
                DateTime daysBefore = DateTime.Now;
                daysBefore = daysBefore.AddDays(-7);

                SetMenuButtons();
                SetGrid();
                DoFind();

                this.btnMove.Text = "합지기화면\n이동";
            }
            catch (Exception ex)
            {
                SetMessage("POP_WRK51_Load_ Error!");
                LogFile.WriteLog("POP_WRK51.POP_WRK51_Load Error\r\n" + ex.Message);
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
                bBox1[0, 5].Text = "실적 등록";
                bBox1[0, 5].Tag = "Product";
                bBox1[0, 5].MappingButton.FontSize = 14;
                bBox1[0, 6].Text = "폐품등록";
                bBox1[0, 6].Tag = "Waste";
                bBox1[0, 6].MappingButton.FontSize = 14;
                bBox1[0, 7].Text = "작업완료";
                bBox1[0, 7].Tag = "End";
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
                LogFile.WriteLog("POP_WRK51.SetButtons Error\r\n" + ex.Message);
            }
        }
        private void doWaste()
        {
            DateTime dtStartTime;
            DateTime dtEndTime;

            string sBasisWgt = Grid1.Rows[0].Cells["BS_WGT"].Value.ToString().Replace(",", "");//평량
            string sWidth = Grid1.Rows[0].Cells["WIDTH"].Value.ToString().Replace(",", "");//지폭
            string sLength = Grid1.Rows[0].Cells["ROLLCNT"].Value.ToString().Replace(",", "");//길이(권치수)
            string sUnit = Grid1.Rows[0].Cells["UNIT"].Value.ToString().Replace(",", "");//단위

            double nBasisWgt;//평량
            int nWidth;//지폭
            int nLength;//길이(권치수)

            string dispoQty = string.Empty;

            dispoQty = lblWorkSpeed.Text.Replace(",","");
            //////생산실지폭 입력시 처리
            ////sWidth = (string.IsNullOrEmpty(lblWorkWidth.Text) ? sWidth : lblWorkWidth.Text).Replace(",", "");
            //////권치수 양식 수정
            ////sLength = sLength.Replace(",", "");

            if (!double.TryParse(sBasisWgt, out nBasisWgt))
                nBasisWgt = 0;
            if (!int.TryParse(sWidth, out nWidth))
                nWidth = 0;
            if (!int.TryParse(sLength, out nLength))
                nLength = 0;

            DateTime dtNow = DateTime.Now;

            if (lblPRD_STR_TIME.Text.Contains(":"))
            {
                string sStartDate = dtpPRD_STR_DATE.Value.ToString("yyyyMMdd") + lblPRD_STR_TIME.Text.ToString().Replace(":", "") + "00";

                if (DateTime.TryParseExact(sStartDate, "yyyyMMddHHmmss", null, DateTimeStyles.AssumeLocal, out dtStartTime) == false)
                {
                    dtStartTime = dtNow;
                }
            }
            else
            {
                dtStartTime = dtNow;
            }

            if (lblPRD_END_TIME.Text.Contains(":"))
            {
                string sEndDate = dtpPRD_END_DATE.Value.ToString("yyyyMMdd") + lblPRD_END_TIME.Text.ToString().Replace(":", "") + "00";
                if (DateTime.TryParseExact(sEndDate, "yyyyMMddHHmmss", null, DateTimeStyles.AssumeLocal, out dtEndTime) == false)
                {
                    dtEndTime = dtNow;
                }
            }
            else
            {
                dtEndTime = dtNow;
            }

            if (nBasisWgt == 0.0)
            {
                new POPUP.MessageForm("평량정보를 확인하여 주시기 바랍니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return;
            }
            if (nWidth == 0)
            {
                new POPUP.MessageForm("지폭은 0이 될수 없습니다.\n지폭정보를 변경하여주시기 바랍니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return;
            }

            // 시작일시, 종료일시, 평량, 지폭, 단위, 실적중량, 폐품중량
            POP_WRK53 WRK53 = new POP_WRK53(dtStartTime, dtEndTime, nBasisWgt, nWidth, sUnit, dispoQty, dispoQty);
            if (ShowDialogForm(WRK53) == DialogResult.OK)
            {
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
                    lblPRD_END_TIME.Text = "";
                    //공통사용항목 지시정보 초기화
                    Common.OrderNo = string.Empty;//생산오더번호
                    Common.WrkOrderNo = string.Empty;//작업지시번호
                    Common.WrkOrderSeq = string.Empty;//작업지시순번
                    Common.ItemCode = string.Empty; //자재코드
                    //return;
                }
                else
                {
                    //공통사용항목 관리
                    Common.OrderNo = dtNowWrk.Rows[0]["ORDER_NO"].ToString();//생산오더번호
                    Common.WrkOrderNo = dtNowWrk.Rows[0]["WRK_ORDR_NO"].ToString();//작업지시번호
                    Common.WrkOrderSeq = dtNowWrk.Rows[0]["WRK_ORDR_SEQNO"].ToString();//작업지시순번
                    Common.ItemCode = dtNowWrk.Rows[0]["MATNR"].ToString(); //자재코드

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

                    // 총 폐품량
                    lblWorkSpeed.Text = dtNowWrk.Rows[0]["DISPO_QTY"].ToString();

                    //가동상태 출력
                    if (dtNowWrk.Rows[0]["MACH_STA"].ToString().Equals("N"))
                    {
                        lblMACH_STA.Text = "대기중";
                        bBox1[0, 3].Text = "작업시작";
                        bBox1[0, 3].Tag = "Start";
                        bBox1[0, 3].UseFlag = true;
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
                        bABNChk = true;
                        //timer1.Start();
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
                }
            }
            catch (Exception ex)
            {
                SetMessage("SetGrid Error!");
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                LogFile.WriteLog("POP_WRK51.WRK_ORDER Find Error\r\n" + ex.Message);
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

                dsTemp = helper.FillDataSetN("SP_POP_WRK51_S01", CommandType.StoredProcedure, 2
                                                               , helper.CreateParameter("P_MACHCD", Common.MachineCode, DbType.String, ParameterDirection.Input));
                //그리드 출력
                Grid1.DoFind_Oracle(dsTemp);
                //현재 지시정보 저장
                dtNowWrk = dsTemp.Tables[1];

                // 총 중량 기준으로 작업지시에 중량 배분
                calWeightNew();
            }
            catch (Exception ex)
            {
                SetMessage("SetGrid Error!");
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                LogFile.WriteLog("POP_WRK51.SetGrid Error\r\n" + ex.Message);
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

            if (sStatus.Equals("S") && dtNowWrk.Rows[0]["MACH_STA"].Equals("R"))
            {
                new POPUP.MessageForm("이미 가동중 입니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return;
            }

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
                if (dtStr >= dtEnd)
                {
                    new POPUP.MessageForm("작업 종료일시는 작업시작일시보다 같거나 빠를수 없습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return;
                }

                msgForm = new POPUP.MessageForm("지시의 상태를 변경하시겠습니까?", MessageBoxButtons.OKCancel, "알   림");
                res = msgForm.ShowDialog(this);
                if (res == System.Windows.Forms.DialogResult.OK)
                {
                    if (Grid1.Rows.Count > 0)
                    {
                        foreach (UltraGridRow rc in Grid1.Rows)
                        {
                            helper.ExecuteNoneQuery("SP_POP_WRK51_U01", CommandType.StoredProcedure
                             , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)
                             , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)
                             , helper.CreateParameter("P_IOTYPE", Common.IOType, DbType.String, ParameterDirection.Input)
                             , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input)
                             , helper.CreateParameter("P_ORDER_NO", rc.Cells["ORDER_NO"].Value.ToString(), DbType.String, ParameterDirection.Input)
                             , helper.CreateParameter("P_WRK_ORDR_NO", rc.Cells["WRK_ORDR_NO"].Value.ToString(), DbType.String, ParameterDirection.Input)
                             , helper.CreateParameter("P_WRK_ORDR_SEQNO", rc.Cells["WRK_ORDR_SEQNO"].Value.ToString(), DbType.String, ParameterDirection.Input)
                             , helper.CreateParameter("P_MATNR", rc.Cells["MATNR"].Value.ToString(), DbType.String, ParameterDirection.Input)
                             , helper.CreateParameter("P_STA", sStatus, DbType.String, ParameterDirection.Input)
                             , helper.CreateParameter("P_REGDATE", dRegDate, DbType.String, ParameterDirection.Input));

                            if (helper.RSCODE == "E")
                            {
                                new POPUP.MessageForm(helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                //this.DialogResult = DialogResult.OK;
                                return;
                            }
                        }

                        if (sStatus == "S")
                        {
                            sMSG = "작업지시가 정상적으로 시작되었습니다.";
                        }
                        else
                        {
                            sMSG = "작업지시가 정상적으로 완료되었습니다.";
                        }
                        new POPUP.MessageForm(sMSG, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                        SetGrid();
                        DoFind();
                    }

                    ////////작업시작/완료처리 (작업지시 상태변경 및 작업장 현황의 가동상태 변경)
                    //////helper.ExecuteNoneQuery("SP_POP_WRK51_U01", CommandType.StoredProcedure
                    ////// , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)
                    ////// , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)
                    ////// , helper.CreateParameter("P_IOTYPE", Common.IOType, DbType.String, ParameterDirection.Input)
                    ////// , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input)
                    ////// , helper.CreateParameter("P_ORDER_NO", Common.OrderNo, DbType.String, ParameterDirection.Input)
                    ////// , helper.CreateParameter("P_WRK_ORDR_NO", Common.WrkOrderNo, DbType.String, ParameterDirection.Input)
                    ////// , helper.CreateParameter("P_WRK_ORDR_SEQNO", Common.WrkOrderSeq, DbType.String, ParameterDirection.Input)
                    ////// , helper.CreateParameter("P_MATNR", Common.ItemCode, DbType.String, ParameterDirection.Input)
                    ////// , helper.CreateParameter("P_STA", sStatus, DbType.String, ParameterDirection.Input)
                    ////// , helper.CreateParameter("P_REGDATE", dRegDate, DbType.String, ParameterDirection.Input));

                    //////if (helper.RSCODE == "E")
                    //////{
                    //////    new POPUP.MessageForm(helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    //////    this.DialogResult = DialogResult.OK;
                    //////    return;
                    //////}
                    ////작업지시변경시 완료처리 진행
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
                    //////sMSG = "작업지시가 정상적으로 시작되었습니다.";
                    //////new POPUP.MessageForm(sMSG, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    //////SetGrid();
                    //////DoFind();
                }
            }
            catch (Exception ex)
            {
                SetMessage("SetGrid Error!");
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                LogFile.WriteLog("POP_WRK51.SetGrid Error\r\n" + ex.Message);
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
            ////지시의 상태 구분
            //if (pType.Contains("S") && lblMACH_STA.Text.Equals("대기중")) //시작 이후 비가동 기능 사용가능
            //{
            //    new POPUP.MessageForm("지시 상태를 확인하여 주시기 바랍니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
            //    return false;
            //}
            //if (pType.Contains("R") && lblMACH_STA.Text.Equals("비가동")) //가동중 여부 확인
            //{
            //    new POPUP.MessageForm("현재 비가동 상태입니다.\n비가동 종료후 진행 바랍니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
            //    return false;
            //}

            return true;
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
            //    SetGrid();
            //    DoFind();
            //    iReSetCnt = 0;
            //}
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
                    case "Order":  //작업지시 선택
                        if (SettingCheck("MR"))
                        {
                            ////POP_WRK07 WRK07 = new POP_WRK07(Common.OpCode, Common.IOType);
                            POP_WRK52 WRK52 = new POP_WRK52(Common.OpCode, Common.IOType, Common.WrkOrderNo, Common.WrkOrderSeq);
                            ShowDialogForm(WRK52);
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
                        POP_WRK02 WRK02 = new POP_WRK02(Common.OpCode);
                        ShowDialogForm(WRK02);
                        //설비변경후 연동정보 재조회
                        Common.machSetting();
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
                            doConfirm(bBox1[0, 7].Tag.ToString());
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
                            if (doRegist() == "E")
                            {
                                return;
                            }
                            //POP_WRK12 WRK12 = new POP_WRK12(dtNowWrk);
                            //ShowDialogForm(WRK12);
                        }
                        break;
                    case "Check": //공정체크
                        if (SettingCheck("MW"))
                        {
                            POP_WRK04 WRK04 = new POP_WRK04();
                            ShowDialogForm(WRK04);
                        }
                        break;
                    case "Waste": //폐품등록
                        if (SettingCheck("MW"))
                        {
                            doWaste();
                        }
                        break;
                    case "InputLog": //자재 투입이력
                        POP_INV02 INV02 = new POP_INV02();
                        ShowDialogForm(INV02);
                        break;
                    case "Performance": //실적현황
                        POP_WRK54 WRK54 = new POP_WRK54();
                        ShowDialogForm(WRK54);
                        //POP_WRK19 WRK19 = new POP_WRK19();
                        //ShowDialogForm(WRK19);
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
                LogFile.WriteLog("POP_WRK51.bBox1_buttonClickEvent Error\r\n" + ex.Message);
            }
            finally
            {

            }
        }

        private void Grid1_GridClick(object sender, MESGrid.GridClickEventArg e)
        {
            float curWidth = 0;         // 작업지시 지폭
            float perWeight = 0;        // 지시별 중량
            float remainWidth = 2950;   // 남은 지폭
            double remainWeight = float.Parse(lblWGT.Text.Replace(",", ""));    // 남은 중량

            float rollCnt = 0;          // 권치수
            float bsWgt = 0;            // 평량
            float speed = 0;            // 선속
            DateTime dtStartDate;
            DateTime dtEndDate;
            string sStartDate = dtpPRD_STR_DATE.Value.ToString("yyyy-MM-dd") + " " + lblPRD_STR_TIME.Text.ToString() + ":00";
            string sEndDate = dtpPRD_END_DATE.Value.ToString("yyyy-MM-dd") + " " + lblPRD_END_TIME.Text.ToString() + ":00";

            dtStartDate = Convert.ToDateTime(sStartDate);
            dtEndDate = Convert.ToDateTime(sEndDate);

            TimeSpan Diff_dates = dtEndDate.Subtract(dtStartDate);

            int chkcnt = 0;

            //조회된 항목이 없는 경우 처리
            if (Grid1.Rows.Count < 1)
                return;
            if (Grid1.Row == null)
                return;

            if (e.column.ToString() == "INS_QTY")
            {
                DAResultNum pop = new DAResultNum();
                pop.LabelTitle = "중량 입력";
                pop.LabelHeader = "중량(Kg)";
                pop.ContentMaxLength = 8;

                if (e.row.Cells["CHK"].Value.ToString() != "V")
                {
                    return;
                }
                pop.ShowDialog(this);

                float totWeight = float.Parse(lblWGT.Text);
                float wasteWeight = 0;
                float tmpSum = 0;

                if (pop.DialogResult == DialogResult.OK)
                {
                    double dWGT = 0;

                    dWGT = pop.ResultDouble;

                    // 총 계획량 대비 실적량이 107% 까지 입력 가능하도록 변경
                    float planWgt = 0, prfmWgt = 0;
                    planWgt = float.Parse(e.row.Cells["ORDER_QTY"].Value.ToString());
                    prfmWgt = float.Parse(e.row.Cells["PRFM_QTY"].Value.ToString());
                    planWgt = (float)(planWgt + (planWgt * 0.07));
                    //if (planWgt < (prfmWgt + dWGT))
                    //{
                    //    new POPUP.MessageForm("입력된 총 중량이 잔량보다 많습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    //    e.row.Cells["INS_QTY"].Value = string.Format("{0:#,0.###}", 0);
                    //} else
                    //{
                    //    e.row.Cells["INS_QTY"].Value = string.Format("{0:#,0.###}", dWGT);
                    //}

                    e.row.Cells["INS_QTY"].Value = string.Format("{0:#,0.###}", dWGT);
                }

                // 그리드별 수량 입력으로 인하여 로직 변경 2023.03.15
                for (int i = 0; i < Grid1.Rows.Count; i++)
                {
                    if (e.row.Cells["CHK"].Value.ToString() == "V")
                    {
                        tmpSum = tmpSum + float.Parse(Grid1.Rows[i].Cells["INS_QTY"].Value.ToString());
                    }
                }

                if (totWeight < tmpSum + float.Parse(lblTubeWGT.Text))
                {
                    new POPUP.MessageForm("입력된 중량이 총 중량보다 많습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return;
                }
                else
                {
                    lblWaste.Text = (float.Parse(lblWGT.Text) - float.Parse(lblTubeWGT.Text) - tmpSum).ToString();
                }

                curWidth = int.Parse(e.row.Cells["WIDTH"].Value.ToString().Replace(",", ""));
                remainWidth = remainWidth - curWidth;

                bsWgt = float.Parse(e.row.Cells["BS_WGT"].Value.ToString());
                perWeight = float.Parse(e.row.Cells["INS_QTY"].Value.ToString());
                // 작업지시 별 권치수 계산
                rollCnt = (perWeight) / ((bsWgt / 1000) * (curWidth / 1000));
                e.row.Cells["ROLLCNT"].Value = rollCnt;

                // 작업지시 별 선속 계산
                speed = rollCnt * ((bsWgt / 1000) * (curWidth / 1000));

                if (Diff_dates.TotalMinutes > 0)
                {
                    e.row.Cells["SPEED"].Value = ((rollCnt / Diff_dates.TotalMinutes) + 0.5);
                }

                // 폐품량 다시 계산

                AutoCalculation();
            }
            //클릭된 행
            iSelRow = e.row.Index;
        }

        private void Grid1_ClickCellButton(object sender, MESGrid.GridClickEventArg e)
        {
            string[] saORDR_INFO;

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
            else if (e.column.ToString() == "SEL")
            {
                string sStatus_Pre = e.row.Cells["SEL"].Value.ToString();

                if (sStatus_Pre == "선택")
                {
                    e.row.Cells["SEL"].Value = "-";
                }
                else
                {
                    e.row.Cells["SEL"].Value = "선택";
                }
            }
            else if (e.column.ToString() == "WRK_ORDR_DETAIL") // 상세보기
            {
                saORDR_INFO = e.row.Cells["WRK_ORDR_NO"].Value.ToString().Split('-');
                string sWrkOrder = saORDR_INFO[0];
                string sWrkOrderSeq = saORDR_INFO[1];

                POP_WRK84 popWrk84 = new POP_WRK84(POP_WRK84.PROC_INP, Common.PlantCode, Common.OpCode, sWrkOrder, sWrkOrderSeq);  // 작업지시 정보

                ShowDialogForm(popWrk84);
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
            // 선속, 권치수 계산 위한 변수
            float curWidth = 0;
            float bsWgt = 0, perWeight = 0, rollCnt = 0;
            DateTime dtStartDate;
            DateTime dtEndDate;
            string sStartDate = string.Empty;
            string sEndDate = string.Empty;
            if (lblPRD_STR_TIME.Text.ToString().Equals(""))
            {
                sStartDate = dtpPRD_STR_DATE.Value.ToString("yyyy-MM-dd") + " " + "00:00:00";
            }
            else
            {
                sStartDate = dtpPRD_STR_DATE.Value.ToString("yyyy-MM-dd") + " " + lblPRD_STR_TIME.Text.ToString() + ":00";
            }

            if (lblPRD_END_TIME.Text.ToString().Equals(""))
            {
                sEndDate = dtpPRD_END_DATE.Value.ToString("yyyy-MM-dd") + " " + "00:00:00";
            }
            else
            {
                sEndDate = dtpPRD_END_DATE.Value.ToString("yyyy-MM-dd") + " " + lblPRD_END_TIME.Text.ToString() + ":00";
            }

            dtStartDate = Convert.ToDateTime(sStartDate);
            dtEndDate = Convert.ToDateTime(sEndDate);

            TimeSpan Diff_dates = dtEndDate.Subtract(dtStartDate);

            MESLabel lblTemp = (MESLabel)sender;
            DAResultTime pop = new DAResultTime();
            pop.ShowDialog(this);
            if (pop.DialogResult == DialogResult.OK)
            {
                lblTemp.Text = pop.ResultString.ToString();
            }

            AutoCalculation();

            // 시간이 변경되는 경우 그리드의 선속, 권치수 재 계산
            foreach (UltraGridRow rc in Grid1.Rows)
            {
                curWidth = 0;
                bsWgt = 0;
                perWeight = 0;
                rollCnt = 0;

                if (rc.Cells["CHK"].Value.ToString().Equals("V") && int.Parse(rc.Cells["INS_QTY"].Value.ToString()) != 0)
                {

                    curWidth = int.Parse(rc.Cells["WIDTH"].Value.ToString().Replace(",", ""));

                    bsWgt = float.Parse(rc.Cells["BS_WGT"].Value.ToString());
                    perWeight = float.Parse(rc.Cells["INS_QTY"].Value.ToString());
                    // 작업지시 별 권치수 계산
                    rollCnt = (perWeight) / ((bsWgt / 1000) * (curWidth / 1000));
                    rc.Cells["ROLLCNT"].Value = rollCnt;

                    // 작업지시 별 선속 계산
                    if (Diff_dates.TotalMinutes > 0)
                    {
                        rc.Cells["SPEED"].Value = ((rollCnt / Diff_dates.TotalMinutes) + 0.5);
                    } else
                    {
                        rc.Cells["SPEED"].Value = 0;
                    }
                }
            }
        }

        private void lblStatus_Click(object sender, EventArgs e)
        {
            SetGrid();
            DoFind();

        }

        private void dtpDate_DropDown(object sender, EventArgs e)
        {
            CommonCalendar.CloseCalendar((DateTimePicker)sender);
        }

        #endregion

        private void lblWGT_Click(object sender, EventArgs e)
        {
            DAResultNum pop = new DAResultNum();
            pop.LabelTitle = "중량 입력";
            pop.LabelHeader = "중량(Kg)";
            pop.ContentMaxLength = 8;

            if (lblTubeWGT.Text == "0")
            {
                new POPUP.MessageForm("지관 무게부터 입력해 주십시오.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return;
            }

            pop.ShowDialog(this);

            if (pop.DialogResult == DialogResult.OK)
            {
                double dWGT = 0;

                dWGT = pop.ResultDouble;
                lblWGT.Text = string.Format("{0:#,0.###}", dWGT);
            }

            calWeightNew();
            AutoCalculation();
        }

        // 총중량 - 지관무게를 기본으로 계산
        // 기존 총 지폭 2950이던 것을 입력받아서 처리
        private void calWeightNew()
        {
            // 총 지폭
            float totWidth = float.Parse(lblWIDTH.Text.ToString());
            float totPlanWeight = 0;    // 총 계획량
            float totConWeight = 0;     // 총 실적량
            float totRemainWeight = 0;  // 총 잔량
            Double insQty = float.Parse(lblWGT.Text.Replace(",", "").ToString());    // 입력된 중량
            float remainWidth = 0;
            float curWidth = 0;         // 작업지시 지폭
            float perWeight = 0;        // 지시별 중량
            float woPlanWeight = 0;     // 작업지시 계획량
            float woConWeight = 0;      // 작업지시 실적량
            float tubeWeight = float.Parse(lblTubeWGT.Text.ToString());

            float rollCnt = 0;          // 권치수
            float bsWgt = 0;            // 평량
            float speed = 0;            // 선속

            if (totWidth == 0) totWidth = 2950;

            remainWidth = totWidth;

            DateTime dtStartDate;
            DateTime dtEndDate;
            string sStartDate = dtpPRD_STR_DATE.Value.ToString("yyyy-MM-dd") + " " + lblPRD_STR_TIME.Text.ToString() + ":00";
            string sEndDate = dtpPRD_END_DATE.Value.ToString("yyyy-MM-dd") + " " + lblPRD_END_TIME.Text.ToString() + ":00";

            for (int i = 0; i < Grid1.Rows.Count; i++)
            {
                totPlanWeight = totPlanWeight + int.Parse(Grid1.Rows[i].Cells["ORDER_QTY"].Value.ToString().Replace(",", ""));
                totConWeight = totConWeight + int.Parse(Grid1.Rows[i].Cells["PRFM_QTY"].Value.ToString().Replace(",", ""));
            }

            //totRemainWeight = totPlanWeight - totConWeight - tubeWeight;
            totRemainWeight = totPlanWeight - totConWeight - tubeWeight;

            // 총 중량이 0일 경우 리턴
            if (insQty == 0) return;

            // Valid1 입력된 실적량이 남은 잔량보다 많은 경우
            //if (float.Parse(lblWGT.Text.ToString()) > (totRemainWeight + (totRemainWeight * 0.07)))
            //{
            //    new POPUP.MessageForm("입력된 총 중량이 잔량보다 많습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
            //    return;
            //}

            // 총 입력량에서 지관무게를 빼준다.
            insQty = insQty - tubeWeight;
            if (insQty < 0)
            {
                new POPUP.MessageForm("입력된 총 중량이 지관무게보다 많아야 합니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return;
            }

            // 총 중량을 0으로 입력
            if (insQty == 0)
            {
                int rowCnt = 0;
                for (int i = 0; i < Grid1.Rows.Count; i++)
                {
                    if (Grid1.Rows[i].Cells["CHK"].Value.ToString() == "V")
                    {
                        rowCnt++;
                    }
                }
                if (Grid1.Rows.Count == rowCnt)
                {
                    for (int i = 0; i < Grid1.Rows.Count; i++)
                    {
                        Grid1.Rows[i].Cells["INS_QTY"].Value = 0;
                    }
                    lblWaste.Text = string.Format("{0:#,0.###}", insQty);
                }
                else
                {
                    dtStartDate = Convert.ToDateTime(sStartDate);
                    dtEndDate = Convert.ToDateTime(sEndDate);

                    TimeSpan Diff_dates = dtEndDate.Subtract(dtStartDate);

                    for (int i = 0; i < Grid1.Rows.Count; i++)
                    {
                        if (Grid1.Rows[i].Cells["CHK"].Value.ToString() == "V")
                        {
                            woPlanWeight = int.Parse(Grid1.Rows[i].Cells["ORDER_QTY"].Value.ToString().Replace(",", ""));
                            woConWeight = int.Parse(Grid1.Rows[i].Cells["PRFM_QTY"].Value.ToString().Replace(",", ""));

                            curWidth = int.Parse(Grid1.Rows[i].Cells["WIDTH"].Value.ToString().Replace(",", ""));
                            remainWidth = remainWidth - curWidth;

                            perWeight = float.Parse(Grid1.Rows[i].Cells["INS_QTY"].Value.ToString());
                            //perWeight = curWidth / totWidth * float.Parse(lblWGT.Text.Replace(",", ""));
                            if ((woPlanWeight - woConWeight) < perWeight)
                            {
                                Grid1.Rows[i].Cells["INS_QTY"].Value = Math.Round(woPlanWeight - woConWeight, 0);
                                insQty = insQty - Math.Round(woPlanWeight - woConWeight, 0);
                                bsWgt = float.Parse(Grid1.Rows[i].Cells["BS_WGT"].Value.ToString());

                                // 작업지시 별 권치수 계산
                                rollCnt = (woPlanWeight - woConWeight) / ((bsWgt / 1000) * (curWidth / 1000));
                                Grid1.Rows[i].Cells["ROLLCNT"].Value = rollCnt;

                                // 작업지시 별 선속 계산
                                speed = rollCnt * ((bsWgt / 1000) * (curWidth / 1000));
                                //Grid1.Rows[i].Cells["SPEED"].Value = speed;

                                if (Diff_dates.TotalMinutes > 0)
                                {
                                    Grid1.Rows[i].Cells["SPEED"].Value = ((rollCnt / Diff_dates.TotalMinutes) + 0.5);
                                }
                            }
                            else
                            {
                                bsWgt = float.Parse(Grid1.Rows[i].Cells["BS_WGT"].Value.ToString());
                                perWeight = float.Parse(Grid1.Rows[i].Cells["INS_QTY"].Value.ToString());
                                // 작업지시 별 권치수 계산
                                rollCnt = (perWeight) / ((bsWgt / 1000) * (curWidth / 1000));
                                Grid1.Rows[i].Cells["ROLLCNT"].Value = rollCnt;

                                // 작업지시 별 선속 계산
                                speed = rollCnt * ((bsWgt / 1000) * (curWidth / 1000));
                                //Grid1.Rows[i].Cells["SPEED"].Value = speed;

                                if (Diff_dates.TotalMinutes > 0)
                                {
                                    Grid1.Rows[i].Cells["SPEED"].Value = ((rollCnt / Diff_dates.TotalMinutes) + 0.5);
                                }
                            }
                        }
                    }
                }
            }
            else
            {
                dtStartDate = Convert.ToDateTime(sStartDate);
                dtEndDate = Convert.ToDateTime(sEndDate);

                TimeSpan Diff_dates = dtEndDate.Subtract(dtStartDate);

                for (int i = 0; i < Grid1.Rows.Count; i++)
                {
                    woPlanWeight = int.Parse(Grid1.Rows[i].Cells["ORDER_QTY"].Value.ToString().Replace(",", ""));
                    woConWeight = int.Parse(Grid1.Rows[i].Cells["PRFM_QTY"].Value.ToString().Replace(",", ""));

                    curWidth = int.Parse(Grid1.Rows[i].Cells["WIDTH"].Value.ToString().Replace(",", ""));
                    remainWidth = remainWidth - curWidth;
                    perWeight = curWidth / totWidth * (float.Parse(lblWGT.Text.Replace(",", "")) - float.Parse(lblTubeWGT.Text.Replace(",", "")));
                    //perWeight = curWidth / totWidth * (float)insQty;
                    if ((woPlanWeight - woConWeight) < perWeight)
                    {
                        Grid1.Rows[i].Cells["INS_QTY"].Value = Math.Round(woPlanWeight - woConWeight, 0);
                        insQty = insQty - Math.Round(woPlanWeight - woConWeight, 0);
                        bsWgt = float.Parse(Grid1.Rows[i].Cells["BS_WGT"].Value.ToString());

                        // 작업지시 별 권치수 계산
                        rollCnt = (woPlanWeight - woConWeight) / ((bsWgt / 1000) * (curWidth / 1000));
                        Grid1.Rows[i].Cells["ROLLCNT"].Value = rollCnt;

                        // 작업지시 별 선속 계산
                        speed = rollCnt * ((bsWgt / 1000) * (curWidth / 1000));
                        //Grid1.Rows[i].Cells["SPEED"].Value = speed;

                        if (Diff_dates.TotalMinutes > 0)
                        {
                            Grid1.Rows[i].Cells["SPEED"].Value = ((rollCnt / Diff_dates.TotalMinutes) + 0.5);
                        }
                    }
                    else
                    {
                        Grid1.Rows[i].Cells["INS_QTY"].Value = Math.Round(perWeight, 0);
                        insQty = insQty - Math.Round(perWeight, 0);
                        bsWgt = float.Parse(Grid1.Rows[i].Cells["BS_WGT"].Value.ToString());

                        // 작업지시 별 권치수 계산
                        rollCnt = (perWeight) / ((bsWgt / 1000) * (curWidth / 1000));
                        Grid1.Rows[i].Cells["ROLLCNT"].Value = rollCnt;

                        // 작업지시 별 선속 계산
                        speed = rollCnt * ((bsWgt / 1000) * (curWidth / 1000));
                        //Grid1.Rows[i].Cells["SPEED"].Value = speed;

                        if (Diff_dates.TotalMinutes > 0)
                        {
                            Grid1.Rows[i].Cells["SPEED"].Value = ((rollCnt / Diff_dates.TotalMinutes) + 0.5);
                        }
                    }
                }

                lblWaste.Text = string.Format("{0:#,0.###}", insQty);
            }
        }

        private void calWeight()
        {

            // 작업지시에 배분 처리
            // 계산 공식 필요

            float totWidth = 2950;      // 총 지폭 = 2,950
            float curWidth = 0;         // 작업지시 지폭
            float perWeight = 0;        // 지시별 중량
            float remainWidth = 2950;   // 남은 지폭
            double remainWeight = float.Parse(lblWGT.Text.Replace(",", ""));    // 남은 중량
            float totPlanWeight = 0;    // 총 계획량
            float totConWeight = 0;     // 총 실적량
            float totRemainWeight = 0;  // 총 잔량

            float woPlanWeight = 0;     // 작업지시 계획량
            float woConWeight = 0;      // 작업지시 실적량

            float rollCnt = 0;          // 권치수
            float bsWgt = 0;            // 평량
            float speed = 0;            // 선속
            DateTime dtStartDate;
            DateTime dtEndDate;
            string sStartDate = dtpPRD_STR_DATE.Value.ToString("yyyy-MM-dd") + " " + lblPRD_STR_TIME.Text.ToString() + ":00";
            string sEndDate = dtpPRD_END_DATE.Value.ToString("yyyy-MM-dd") + " " + lblPRD_END_TIME.Text.ToString() + ":00";


            // 총 계획량, 총 실적량, 총 잔량
            for (int i = 0; i < Grid1.Rows.Count; i++)
            {
                totPlanWeight = totPlanWeight + int.Parse(Grid1.Rows[i].Cells["ORDER_QTY"].Value.ToString().Replace(",", ""));
                totConWeight = totConWeight + int.Parse(Grid1.Rows[i].Cells["PRFM_QTY"].Value.ToString().Replace(",", ""));
            }
            totRemainWeight = totPlanWeight - totConWeight;

            // Valid1 입력된 실적량이 남은 잔량보다 많은 경우
            //if (float.Parse(lblWGT.Text.ToString()) > totRemainWeight)
            //{
            //    new POPUP.MessageForm("입력된 총 중량이 잔량보다 많습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
            //    return;
            //}

            if (remainWeight == 0)
            {
                int rowCnt = 0;
                for (int i = 0; i < Grid1.Rows.Count; i++)
                {
                    if (Grid1.Rows[i].Cells["CHK"].Value.ToString() == "V")
                    {
                        rowCnt++;
                    }
                }
                if (Grid1.Rows.Count == rowCnt)
                {
                    for (int i = 0; i < Grid1.Rows.Count; i++)
                    {
                        Grid1.Rows[i].Cells["INS_QTY"].Value = 0;
                    }
                    lblWaste.Text = string.Format("{0:#,0.###}", remainWeight);
                }
                else
                {
                    dtStartDate = Convert.ToDateTime(sStartDate);
                    dtEndDate = Convert.ToDateTime(sEndDate);

                    TimeSpan Diff_dates = dtEndDate.Subtract(dtStartDate);

                    for (int i = 0; i < Grid1.Rows.Count; i++)
                    {
                        if (Grid1.Rows[i].Cells["CHK"].Value.ToString() == "V")
                        {
                            woPlanWeight = int.Parse(Grid1.Rows[i].Cells["ORDER_QTY"].Value.ToString().Replace(",", ""));
                            woConWeight = int.Parse(Grid1.Rows[i].Cells["PRFM_QTY"].Value.ToString().Replace(",", ""));

                            curWidth = int.Parse(Grid1.Rows[i].Cells["WIDTH"].Value.ToString().Replace(",", ""));
                            remainWidth = remainWidth - curWidth;

                            perWeight = float.Parse(Grid1.Rows[i].Cells["INS_QTY"].Value.ToString());
                            //perWeight = curWidth / totWidth * float.Parse(lblWGT.Text.Replace(",", ""));
                            if ((woPlanWeight - woConWeight) < perWeight)
                            {
                                Grid1.Rows[i].Cells["INS_QTY"].Value = Math.Round(woPlanWeight - woConWeight, 0);
                                remainWeight = remainWeight - Math.Round(woPlanWeight - woConWeight, 0);
                                bsWgt = float.Parse(Grid1.Rows[i].Cells["BS_WGT"].Value.ToString());

                                // 작업지시 별 권치수 계산
                                rollCnt = (woPlanWeight - woConWeight) / ((bsWgt / 1000) * (curWidth / 1000));
                                Grid1.Rows[i].Cells["ROLLCNT"].Value = rollCnt;

                                // 작업지시 별 선속 계산
                                speed = rollCnt * ((bsWgt / 1000) * (curWidth / 1000));
                                //Grid1.Rows[i].Cells["SPEED"].Value = speed;

                                if (Diff_dates.TotalMinutes > 0)
                                {
                                    Grid1.Rows[i].Cells["SPEED"].Value = ((rollCnt / Diff_dates.TotalMinutes) + 0.5);
                                }
                            }
                            else
                            {
                                bsWgt = float.Parse(Grid1.Rows[i].Cells["BS_WGT"].Value.ToString());
                                perWeight = float.Parse(Grid1.Rows[i].Cells["INS_QTY"].Value.ToString());
                                // 작업지시 별 권치수 계산
                                rollCnt = (perWeight) / ((bsWgt / 1000) * (curWidth / 1000));
                                Grid1.Rows[i].Cells["ROLLCNT"].Value = rollCnt;

                                // 작업지시 별 선속 계산
                                speed = rollCnt * ((bsWgt / 1000) * (curWidth / 1000));
                                //Grid1.Rows[i].Cells["SPEED"].Value = speed;

                                if (Diff_dates.TotalMinutes > 0)
                                {
                                    Grid1.Rows[i].Cells["SPEED"].Value = ((rollCnt / Diff_dates.TotalMinutes) + 0.5);
                                }
                            }
                        }
                    }
                }
            }
            else if (remainWeight != 0)
            {
                dtStartDate = Convert.ToDateTime(sStartDate);
                dtEndDate = Convert.ToDateTime(sEndDate);

                TimeSpan Diff_dates = dtEndDate.Subtract(dtStartDate);

                for (int i = 0; i < Grid1.Rows.Count; i++)
                {
                    woPlanWeight = int.Parse(Grid1.Rows[i].Cells["ORDER_QTY"].Value.ToString().Replace(",", ""));
                    woConWeight = int.Parse(Grid1.Rows[i].Cells["PRFM_QTY"].Value.ToString().Replace(",", ""));

                    curWidth = int.Parse(Grid1.Rows[i].Cells["WIDTH"].Value.ToString().Replace(",", ""));
                    remainWidth = remainWidth - curWidth;
                    perWeight = curWidth / totWidth * float.Parse(lblWGT.Text.Replace(",", ""));
                    if ((woPlanWeight - woConWeight) < perWeight)
                    {
                        Grid1.Rows[i].Cells["INS_QTY"].Value = Math.Round(woPlanWeight - woConWeight, 0);
                        remainWeight = remainWeight - Math.Round(woPlanWeight - woConWeight, 0);
                        bsWgt = float.Parse(Grid1.Rows[i].Cells["BS_WGT"].Value.ToString());

                        // 작업지시 별 권치수 계산
                        rollCnt = (woPlanWeight - woConWeight) / ((bsWgt / 1000) * (curWidth / 1000));
                        Grid1.Rows[i].Cells["ROLLCNT"].Value = rollCnt;

                        // 작업지시 별 선속 계산
                        speed = rollCnt * ((bsWgt / 1000) * (curWidth / 1000));
                        //Grid1.Rows[i].Cells["SPEED"].Value = speed;

                        if (Diff_dates.TotalMinutes > 0)
                        {
                            Grid1.Rows[i].Cells["SPEED"].Value = ((rollCnt / Diff_dates.TotalMinutes) + 0.5);
                        }
                    }
                    else
                    {
                        Grid1.Rows[i].Cells["INS_QTY"].Value = Math.Round(perWeight, 0);
                        remainWeight = remainWeight - Math.Round(perWeight, 0);
                        bsWgt = float.Parse(Grid1.Rows[i].Cells["BS_WGT"].Value.ToString());

                        // 작업지시 별 권치수 계산
                        rollCnt = (perWeight) / ((bsWgt / 1000) * (curWidth / 1000));
                        Grid1.Rows[i].Cells["ROLLCNT"].Value = rollCnt;

                        // 작업지시 별 선속 계산
                        speed = rollCnt * ((bsWgt / 1000) * (curWidth / 1000));
                        //Grid1.Rows[i].Cells["SPEED"].Value = speed;

                        if (Diff_dates.TotalMinutes > 0)
                        {
                            Grid1.Rows[i].Cells["SPEED"].Value = ((rollCnt / Diff_dates.TotalMinutes) + 0.5);
                        }
                    }
                }

                lblWaste.Text = string.Format("{0:#,0.###}", remainWeight);
            }
        }

        // 가동시간 / 선속 / 중량 계산
        private void AutoCalculation()
        {
            DateTime dtStartDate;
            DateTime dtEndDate;

            if ((lblPRD_STR_TIME.Text.ToString().Length != 5) || (lblPRD_END_TIME.Text.ToString().Length != 5))
            {
                lblTM.Text = "0";
                lblWorkSpeed.Text = "0";
                return;
            }

            string sStartDate = dtpPRD_STR_DATE.Value.ToString("yyyy-MM-dd") + " " + lblPRD_STR_TIME.Text.ToString() + ":00";
            if (Common.IsDateTime(sStartDate) == false)
            {
                lblTM.Text = "0";
                lblWorkSpeed.Text = "0";
                return;
            }

            string sEndDate = dtpPRD_END_DATE.Value.ToString("yyyy-MM-dd") + " " + lblPRD_END_TIME.Text.ToString() + ":00";
            if (Common.IsDateTime(sEndDate) == false)
            {
                lblTM.Text = "0";
                lblWorkSpeed.Text = "0";
                return;
            }

            dtStartDate = Convert.ToDateTime(sStartDate);
            dtEndDate = Convert.ToDateTime(sEndDate);

            TimeSpan Diff_dates = dtEndDate.Subtract(dtStartDate);

            if (Diff_dates.TotalMinutes > 0)
            {
                lblTM.Text = string.Format("{0:#,0}", Diff_dates.TotalMinutes);

                //int nROLLCNT = int.TryParse(lblROLLCNT.Text.Replace(",", ""), out nROLLCNT) ? nROLLCNT : 0; // 권치수

                //if (nROLLCNT > 0)
                //{
                //    lblWorkSpeed.Text = string.Format("{0:#,0}", (int)((nROLLCNT / Diff_dates.TotalMinutes) + 0.5)); // 선속
                //}
                SetMessage("");
            }
            else
            {
                lblTM.Text = "0";
                lblWorkSpeed.Text = "0";
                lblPRD_END_TIME.Text = string.Empty;

                SetMessage("작업 시작일시/종료일시를 확인하세요!");
                new POPUP.MessageForm("작업 종료일시는 작업시작일시보다 같거나 빠를수 없습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return;
            }
        }


        // 실적 등록
        private string doRegist()
        {
            //DBHelper helper = new DBHelper(false, "", true);

            DataSet dsTemp = new DataSet(); //실적등록 결과 수신(0:라벨정보, 1:RFC 변수, 2:IF 변수)
            DataSet dsPrint = new DataSet();        // 출력용 DataSet
            int doCnt = 0;
            string sWDocNo = string.Empty;
            string sUseFunc = string.Empty;
            string sResult = "ROLLBACK";
            string rtnCode = "E";


            DateTime dNowStartDate;
            DateTime dNowEndDate;

            DataSet dsRegist = new DataSet();
            DataTable dtRegist = new DataTable();

            dtRegist.Columns.Add("WRK_ORDR_NO", typeof(string));
            dtRegist.Columns.Add("WRK_ORDR_SEQNO", typeof(string));
            dtRegist.Columns.Add("REG_QTY", typeof(float));
            dtRegist.Columns.Add("RES_CODE", typeof(string));

            try
            {
                if (!dtNowWrk.Rows[0]["MACH_STA"].ToString().Equals("R"))
                {
                    new POPUP.MessageForm("작업지시 시작을 먼저 해주시기 바랍니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return rtnCode;
                }
                dNowStartDate = Common.makeDateTime(dtpPRD_STR_DATE.Value, lblPRD_STR_TIME.Text);
                dNowEndDate = Common.makeDateTime(dtpPRD_END_DATE.Value, lblPRD_END_TIME.Text);

                if (string.IsNullOrEmpty(dtpPRD_STR_DATE.Text) || string.IsNullOrEmpty(lblPRD_END_TIME.Text))
                {
                    new POPUP.MessageForm("작업 시간을 입력하여 주시기 바랍니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return rtnCode;
                }
                TimeSpan Diff_dates = dNowEndDate.Subtract(dNowStartDate);

                if (Diff_dates.TotalMinutes <= 0)
                {
                    lblTM.Text = "0";
                    lblWorkSpeed.Text = "0";

                    new POPUP.MessageForm("작업 종료일시는 작업시작일시보다 같거나 빠를수 없습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return rtnCode;
                }

                if (new POPUP.MessageForm(string.Format("실적등록 하시겠습니까?"), MessageBoxButtons.OKCancel, "알   림").ShowDialog(this) == DialogResult.Cancel)
                {
                    return "E";
                }
                foreach (UltraGridRow rc in Grid1.Rows)
                {
                    this.Cursor = Cursors.WaitCursor;   //Waitting

                    // 선택된 작업지시 실적 등록
                    if (rc.Cells["CHK"].Value.ToString() == "V" && !rc.Cells["INS_QTY"].Value.ToString().Equals("0"))
                    {
                        DBHelper helper = new DBHelper(false, "", true);

                        try
                        {

                            dsTemp = helper.FillDataSetN("SP_POP_WRK51_I01", CommandType.StoredProcedure, 6
                                     , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)
                                     , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)
                                     , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input)
                                     , helper.CreateParameter("P_ORDER_NO", rc.Cells["ORDER_NO"].Value.ToString().Replace(",", ""), DbType.String, ParameterDirection.Input)
                                     , helper.CreateParameter("P_WRK_ORDR_NO", rc.Cells["WRK_ORDR_NO"].Value.ToString().Replace(",", ""), DbType.String, ParameterDirection.Input)
                                     , helper.CreateParameter("P_WRK_ORDR_SEQNO", rc.Cells["WRK_ORDR_SEQNO"].Value.ToString().Replace(",", ""), DbType.String, ParameterDirection.Input)
                                     , helper.CreateParameter("P_MATNR", rc.Cells["MATNR"].Value.ToString().Replace(",", ""), DbType.String, ParameterDirection.Input)
                                     , helper.CreateParameter("P_WRK_ROLLCNT", rc.Cells["ROLLCNT"].Value.ToString().Replace(",", ""), DbType.String, ParameterDirection.Input) //권치수
                                     , helper.CreateParameter("P_WRK_WIDTH", rc.Cells["WIDTH"].Value.ToString().Replace(",", ""), DbType.String, ParameterDirection.Input) //지폭
                                     , helper.CreateParameter("P_WRK_QTY", rc.Cells["INS_QTY"].Value.ToString().Replace(",", ""), DbType.String, ParameterDirection.Input)//중량
                                     , helper.CreateParameter("P_PRD_STR_DATE", dNowStartDate.ToString("yyyy-MM-dd HH:mm:ss"), DbType.String, ParameterDirection.Input)
                                     , helper.CreateParameter("P_PRD_END_DATE", dNowEndDate.ToString("yyyy-MM-dd HH:mm:ss"), DbType.String, ParameterDirection.Input)
                                     , helper.CreateParameter("P_TM", lblTM.Text.Replace(",", ""), DbType.String, ParameterDirection.Input)
                                     , helper.CreateParameter("P_SPEED", rc.Cells["SPEED"].Value.ToString().Replace(",", ""), DbType.String, ParameterDirection.Input)
                                     , helper.CreateParameter("P_RMK", txtRMK.Text, DbType.String, ParameterDirection.Input)
                                     , helper.CreateParameter("P_WRK_DATE", Common.dateFormat("I", dtpPRD_STR_DATE.Text), DbType.String, ParameterDirection.Input)
                                     , helper.CreateParameter("P_DISPO_QTY", lblWaste.Text.Replace(",", ""), DbType.String, ParameterDirection.Input)
                                     , helper.CreateParameter("P_WDOC_NO", DbType.String, ParameterDirection.Output, null, 30)
                                     , helper.CreateParameter("P_USE_FUNC", DbType.String, ParameterDirection.Output, null, 30)
                                       );

                            if (helper.RSCODE == "E")
                            {
                                this.Cursor = Cursors.Default;   //Waitting
                                new POPUP.MessageForm(helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                helper.Rollback();

                                DataRow drRegist = dtRegist.NewRow();
                                drRegist["WRK_ORDR_NO"] = rc.Cells["WRK_ORDR_NO"].Value.ToString().Replace(",", "");
                                drRegist["WRK_ORDR_SEQNO"] = rc.Cells["WRK_ORDR_SEQNO"].Value.ToString().Replace(",", "");
                                drRegist["RES_CODE"] = helper.RSCODE;
                                drRegist["REG_QTY"] = rc.Cells["INS_QTY"].Value;

                                dtRegist.Rows.Add(drRegist);

                                // 실패한 작업지시 v 표시
                                int cnt = 0;
                                foreach (DataRow row in dtRegist.Rows)
                                {
                                    if (row["RES_CODE"].ToString() != "S")
                                    {
                                        foreach (UltraGridRow grdrow in Grid1.Rows)
                                        {
                                            if (grdrow.Cells["WRK_ORDR_NO"].Value.ToString() == row["WRK_ORDR_NO"].ToString())
                                            {
                                                grdrow.Cells["CHK"].Value = "V";
                                                grdrow.Cells["INS_QTY"].Value = row["REG_QTY"];
                                            }
                                        }
                                    }
                                }
                                return rtnCode;
                            }
                            else if (helper.RSCODE == "N")
                            {
                                this.Cursor = Cursors.Default;   //Waitting
                                new POPUP.MessageForm("자재의 수량이 부족합니다.\n" + helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                helper.Rollback();

                                DataRow drRegist = dtRegist.NewRow();
                                drRegist["WRK_ORDR_NO"] = rc.Cells["WRK_ORDR_NO"].Value.ToString().Replace(",", "");
                                drRegist["WRK_ORDR_SEQNO"] = rc.Cells["WRK_ORDR_SEQNO"].Value.ToString().Replace(",", "");
                                drRegist["RES_CODE"] = helper.RSCODE;
                                drRegist["REG_QTY"] = rc.Cells["INS_QTY"].Value;

                                dtRegist.Rows.Add(drRegist);

                                // 실패한 작업지시 v 표시
                                int cnt = 0;
                                foreach (DataRow row in dtRegist.Rows)
                                {
                                    if (row["RES_CODE"].ToString() != "S")
                                    {
                                        foreach (UltraGridRow grdrow in Grid1.Rows)
                                        {
                                            if (grdrow.Cells["WRK_ORDR_NO"].Value.ToString() == row["WRK_ORDR_NO"].ToString())
                                            {
                                                grdrow.Cells["CHK"].Value = "V";
                                                grdrow.Cells["INS_QTY"].Value = row["REG_QTY"];
                                            }
                                        }
                                    }
                                }
                                return rtnCode;
                            }
                            else
                            {
                                DataTable dtTemp = new DataTable();    // 출력용 DataTable
                                dtTemp.TableName = "Table" + doCnt.ToString();

                                //출고요청 문서번호 저장
                                sWDocNo = helper.Parameters["P_WDOC_NO"].Value.ToString();
                                sUseFunc = helper.Parameters["P_USE_FUNC"].Value.ToString();
                                //SAP 실적 등록
                                SAPHelper sapRFC = new SAPHelper();
                                if (sapRFC.CallSAPFunc_HL(helper.RSMSG, dsTemp.Tables[2], dsTemp.Tables[3], helper).Equals("S"))
                                {
                                    sapRFC.SaveResulttoWrk_HL(helper, "POP_WRK012", "0");
                                    //helper.Commit();

                                    doCnt++;
                                    dtTemp = dsTemp.Tables[0].Copy();
                                    dtTemp.TableName = "Table" + doCnt.ToString();
                                    dsPrint.Tables.Add(dtTemp);

                                    Thread.Sleep(1000);

                                    DataRow drRegist = dtRegist.NewRow();
                                    drRegist["WRK_ORDR_NO"] = rc.Cells["WRK_ORDR_NO"].Value.ToString().Replace(",", "");
                                    drRegist["WRK_ORDR_SEQNO"] = rc.Cells["WRK_ORDR_SEQNO"].Value.ToString().Replace(",", "");
                                    drRegist["RES_CODE"] = helper.RSCODE;
                                    drRegist["REG_QTY"] = rc.Cells["INS_QTY"].Value;

                                    dtRegist.Rows.Add(drRegist);

                                    // 실패한 작업지시 v 표시
                                    int cnt = 0;
                                    foreach (DataRow row in dtRegist.Rows)
                                    {
                                        if (row["RES_CODE"].ToString() != "S")
                                        {
                                            foreach (UltraGridRow grdrow in Grid1.Rows)
                                            {
                                                if (grdrow.Cells["WRK_ORDR_NO"].Value.ToString() == row["WRK_ORDR_NO"].ToString())
                                                {
                                                    grdrow.Cells["CHK"].Value = "V";
                                                    grdrow.Cells["INS_QTY"].Value = row["REG_QTY"];
                                                }
                                            }
                                        }
                                    }
                                }
                                else
                                {

                                    DataRow drRegist = dtRegist.NewRow();
                                    drRegist["WRK_ORDR_NO"] = rc.Cells["WRK_ORDR_NO"].Value.ToString().Replace(",", "");
                                    drRegist["WRK_ORDR_SEQNO"] = rc.Cells["WRK_ORDR_SEQNO"].Value.ToString().Replace(",", "");
                                    drRegist["RES_CODE"] = "E";
                                    drRegist["REG_QTY"] = rc.Cells["INS_QTY"].Value;

                                    dtRegist.Rows.Add(drRegist);

                                    // 실패한 작업지시 v 표시
                                    int cnt = 0;
                                    foreach (DataRow row in dtRegist.Rows)
                                    {
                                        if (row["RES_CODE"].ToString() != "S")
                                        {
                                            foreach (UltraGridRow grdrow in Grid1.Rows)
                                            {
                                                if (grdrow.Cells["WRK_ORDR_NO"].Value.ToString() == row["WRK_ORDR_NO"].ToString())
                                                {
                                                    grdrow.Cells["CHK"].Value = "V";
                                                    grdrow.Cells["INS_QTY"].Value = row["REG_QTY"];
                                                }
                                            }
                                        }
                                    }

                                    this.Cursor = Cursors.Default;   //Waitting
                                    throw new Exception("SAP전송이 실패하였습니다.\n" + sapRFC.rtnMSG);
                                }
                                // 작업지시 별 Commit
                                rtnCode = "S";
                                helper.Commit();
                            }
                        }
                        catch (Exception ex)
                        {
                            this.Cursor = Cursors.Default;   //Waitting
                            RollbackLog(helper, dsTemp, ex.Message, sResult);
                            helper.Rollback();

                            rtnCode = "E";

                            string sRollBackMsg = ex.Message + Environment.NewLine + "MES ROLLBACK 실적 취소되었습니다";
                            new POPUP.MessageForm_ERR("알   림", sRollBackMsg, MessageBoxButtons.OK).ShowDialog(this);
                        }
                        finally
                        {
                            this.Cursor = Cursors.Default;   //Waitting
                            helper.Close();
                        }

                        dNowStartDate = dNowStartDate.AddMinutes(1);
                        dNowEndDate = dNowEndDate.AddMinutes(1);
                    }
                }

                //// 실적등록한 작업지시 체크 변경
                //foreach (UltraGridRow grdrow in Grid1.Rows)
                //{
                //    grdrow.Cells["CHK"].Value = "-";
                //    grdrow.Cells["INS_QTY"].Value = "0";
                //}
                //lblWGT.Text = "0";

                // 출력
                foreach (DataTable dt in dsPrint.Tables)
                {
                    doPrint(dt);
                }


                new POPUP.MessageForm(doCnt.ToString() + "건의 실적이 등록되었습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);

                // 완료 후 재조회
                if (dsPrint.Tables.Count == Grid1.Rows.Count)
                {
                    SetGrid();
                    DoFind();
                }

                // 실적등록한 작업지시 체크 변경
                if (rtnCode == "E")
                {
                    foreach (UltraGridRow grdrow in Grid1.Rows)
                    {
                        foreach (DataRow dr in dtRegist.Rows)
                        {
                            if (dr["WRK_ORDR_NO"].ToString() == grdrow.Cells["WRK_ORDR_NO"].Value.ToString())
                            {
                                if (dr["RES_CODE"].ToString() == "E")
                                {
                                    grdrow.Cells["CHK"].Value = "V";
                                    grdrow.Cells["INS_QTY"].Value = dr["REG_QTY"];
                                }
                                else
                                {
                                    grdrow.Cells["CHK"].Value = "-";
                                    grdrow.Cells["INS_QTY"].Value = "0";
                                }
                            }
                        }
                    }
                }
                lblWGT.Text = "0";

                //helper.Commit();
            }
            catch (Exception ex)
            {
                this.Cursor = Cursors.Default;   //Waitting
                //RollbackLog(helper, dsTemp, ex.Message, sResult);
                //helper.Rollback();

                string sRollBackMsg = ex.Message + Environment.NewLine + "MES ROLLBACK 실적 취소되었습니다";
                new POPUP.MessageForm_ERR("알   림", sRollBackMsg, MessageBoxButtons.OK).ShowDialog(this);
            }
            finally
            {
                this.Cursor = Cursors.Default;   //Waitting
                //helper.Close();

            }
            return rtnCode;
        }

        private void RollbackLog(DBHelper helper, DataSet dsTemp, string sMSG_ERR, string sResult)
        {
            if (dsTemp.Tables.Count == 0) return;
            if (dsTemp.Tables[3] != null)
            {
                if (dsTemp.Tables[3].Rows[0][0].ToString() != "1")
                {
                    foreach (DataRow Rows in dsTemp.Tables[3].Rows) //실적등록 실패시 롤백 발생원인 저장
                    {
                        helper.ExecuteNoneQuery("SP_HL_ROLLBACK_LOG", CommandType.StoredProcedure
                        , helper.CreateParameter("P_DOC_NO", Rows["MDOCNO"], DbType.String, ParameterDirection.Input)
                        , helper.CreateParameter("P_DOC_SEQNO", Rows["MDOCSEQ"], DbType.String, ParameterDirection.Input)
                        , helper.CreateParameter("P_LOT_NO", Rows["LOTNO"], DbType.String, ParameterDirection.Input)
                        , helper.CreateParameter("P_ORDER_NO", Rows["AUFNR"], DbType.String, ParameterDirection.Input)
                        , helper.CreateParameter("P_WERKS", Rows["WERKS"], DbType.String, ParameterDirection.Input)
                        , helper.CreateParameter("P_WORKCENTERCODE", Rows["WORKCENTERCODE"].ToString(), DbType.String, ParameterDirection.Input)
                        , helper.CreateParameter("P_MACH_CD", Rows["MACHINE"], DbType.String, ParameterDirection.Input)
                        , helper.CreateParameter("P_PRDCD", Rows["PRDCD"], DbType.String, ParameterDirection.Input)
                        , helper.CreateParameter("P_QTY", Rows["PROQTY"], DbType.String, ParameterDirection.Input)
                        , helper.CreateParameter("P_MATNR", "", DbType.String, ParameterDirection.Input)
                        , helper.CreateParameter("P_BUDAT", Rows["PRDDT"], DbType.String, ParameterDirection.Input)
                        , helper.CreateParameter("P_RESULT", sResult, DbType.String, ParameterDirection.Input)
                        , helper.CreateParameter("P_REMARK", sMSG_ERR, DbType.String, ParameterDirection.Input)
                        , helper.CreateParameter("P_MBLNR", "", DbType.String, ParameterDirection.Input)
                        , helper.CreateParameter("P_MJAHR", "", DbType.String, ParameterDirection.Input)
                        , helper.CreateParameter("P_I_IF_ID", dsTemp.Tables[2].Rows[0]["I_IF_ID"].ToString(), DbType.String, ParameterDirection.Input)
                        , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input));
                    }
                }
            }
        }

        private void doPrint(DataTable dtTemp)
        {
            //조회결과 입력용 Row생성
            REPORT_ITEM HLitem = new REPORT_ITEM();

            HLitem.MACH_NM = dtTemp.Rows[0]["MACH_NM"].ToString();          // 설비호기 명
            HLitem.LOT_NO = dtTemp.Rows[0]["LOT_NO"].ToString();            // LOT NO
            HLitem.SPEC = dtTemp.Rows[0]["MATNR_NM"].ToString();               // 제품규격(품명)
            HLitem.PRFM_ROLLCNT = dtTemp.Rows[0]["ROLLCNT"].ToString();     // 길이
            HLitem.BS_WGT = dtTemp.Rows[0]["BS_WGT"].ToString();            // 편량
            HLitem.PRFM_WGT = dtTemp.Rows[0]["PRFM_WGT"].ToString();        // 중량
            HLitem.COLOR = dtTemp.Rows[0]["COLOR"].ToString();              // 색
            HLitem.WRK_NAME = dtTemp.Rows[0]["WRK_NAME"].ToString();        // 작업자
            HLitem.QCJUD = dtTemp.Rows[0]["QCJUD"].ToString();              // 판정
            HLitem.IND_BCD = dtTemp.Rows[0]["IND_BCD"].ToString();          // 바코드

            string pstrERR = "";

            REPORT rp = new REPORT();
            rp.EXCEL_OPEN(Common.PlantCode);
            rp.AA_PRINT(HLitem, ref pstrERR);
            if (pstrERR.Length > 0)
            {
                rp.EXCEL_CLOSE();
                return;
            }
            rp.EXCEL_CLOSE();
        }

        private void btnMove_Click(object sender, EventArgs e)
        {
            DBHelper helper = new DBHelper(false);

            if (new POPUP.MessageForm(string.Format("합지기 화면으로 이동하시겠습니까?"), MessageBoxButtons.OKCancel, "알   림").ShowDialog(this) == DialogResult.OK)
            {
                helper.ExecuteNoneQuery("SP_POP_WRK51_U02", CommandType.StoredProcedure
                 , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)
                 , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)
                 , helper.CreateParameter("P_IOTYPE", Common.IOType, DbType.String, ParameterDirection.Input)
                 , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input)
                 , helper.CreateParameter("P_WRK_ORDR_NO", Common.WrkOrderNo, DbType.String, ParameterDirection.Input)
                 , helper.CreateParameter("P_WRK_ORDR_SEQNO", Common.WrkOrderSeq, DbType.String, ParameterDirection.Input));

                if (helper.RSCODE == "E")
                {
                    new POPUP.MessageForm(helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    //this.DialogResult = DialogResult.OK;
                    return;
                }
                else if (helper.RSCODE == "S")
                {
                    this.Close();
                }
            }
            else
            {
                return;
            }
        }

        private void lblWaste_Click(object sender, EventArgs e)
        {
            int tmpSum = 0;

            DAResultNum pop = new DAResultNum();
            pop.LabelTitle = "폐품 입력";
            pop.LabelHeader = "폐품중량(Kg)";
            pop.ContentMaxLength = 8;

            pop.ShowDialog(this);

            if (pop.DialogResult == DialogResult.OK)
            {
                double dWGT = 0;

                dWGT = pop.ResultDouble;
                lblWaste.Text = string.Format("{0:#,0.###}", dWGT);
            }

            // 총 중량 계산
            foreach (UltraGridRow rc in Grid1.Rows)
            {
                if (rc.Cells["CHK"].Value.ToString().Equals("V"))
                {
                    tmpSum = tmpSum + int.Parse(rc.Cells["INS_QTY"].Value.ToString());
                }
            }
            tmpSum = tmpSum + int.Parse(lblWaste.Text);

            lblWGT.Text = tmpSum.ToString();
        }

        private void lblTubeWGT_Click(object sender, EventArgs e)
        {
            DAResultNum pop = new DAResultNum();
            pop.LabelTitle = "지관무게 입력";
            pop.LabelHeader = "중량(Kg)";
            pop.ContentMaxLength = 8;

            pop.ShowDialog(this);

            if (pop.DialogResult == DialogResult.OK)
            {
                double dWGT = 0;

                dWGT = pop.ResultDouble;
                lblTubeWGT.Text = string.Format("{0:#,0.###}", dWGT);
            }

            calWeightNew();
            AutoCalculation();
        }

        private void lblWIDTH_Click(object sender, EventArgs e)
        {
            DAResultNum pop = new DAResultNum();
            pop.LabelTitle = "총지폭 입력";
            pop.LabelHeader = "중량(Kg)";
            pop.ContentMaxLength = 8;

            pop.ShowDialog(this);

            if (pop.DialogResult == DialogResult.OK)
            {
                double dWGT = 0;
                double tmpWidth = 0;

                dWGT = pop.ResultDouble;

                if (dWGT > 2950)
                {
                    new POPUP.MessageForm("최대 총 지폭은 2,950 입니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    lblWIDTH.Text = string.Format("{0:#,0.###}", 2950);
                    return;
                }

                foreach (UltraGridRow rc in Grid1.Rows)
                {
                    tmpWidth = tmpWidth + double.Parse(rc.Cells["WIDTH"].Value.ToString());
                }
                if (dWGT == 0)
                {
                    new POPUP.MessageForm("총 지폭을 0으로 입력할 수 없습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    lblWIDTH.Text = string.Format("{0:#,0.###}", tmpWidth);
                    return;
                }
                else if (tmpWidth > dWGT)
                {
                    new POPUP.MessageForm("입력된 총 지폭이 선택된 작업지시들의 지폭 합보다 작을 수 없습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    lblWIDTH.Text = string.Format("{0:#,0.###}", tmpWidth);
                    return;
                }
                else
                {
                    lblWIDTH.Text = string.Format("{0:#,0.###}", dWGT);
                }
            }

            calWeightNew();
            AutoCalculation();
        }
    }
}
