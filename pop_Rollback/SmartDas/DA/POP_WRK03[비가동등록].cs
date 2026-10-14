#region [ USING AREA ]
using System;
using System.Configuration;
using System.Data;
using System.Windows.Forms;

using SAMMI;
using SmartDas.Components;
using SmartDas.POPUP;

using Oracle.ManagedDataAccess.Client;
using System.Threading;
#endregion

namespace SmartDas
{
    public partial class POP_WRK03 : BaseForm
    {
        #region < MEMBER AREA >

        private SAMMI.Common _common = new SAMMI.Common();

        private string sNACode = string.Empty; //비가동 항목
        private string sGrpCode = string.Empty; //운전상태
        private bool bEndFlag = false; //비가동 완료(현재 비가동 상태시 true)

        #endregion

        #region < CONSTRUCTOR >

        public POP_WRK03()
        {
            InitializeComponent();

            Common.SetMessageList();

        }
        #endregion

        #region < POP_WRK03_Load >
        private void POP_WRK03_Load(object sender, EventArgs e)
        {
            string sSubTitle = string.Empty;
            try
            {
                #region --- 언어 설정 → 모듈별로 화면 첫 화면 분기되는 화면에 해당 코드 삽입 ---
                Configuration appConfig = ConfigurationManager.OpenExeConfiguration(ConfigurationUserLevel.None);

                SAMMI.Common.SystemID = appConfig.AppSettings.Settings["SystemID"].Value.ToString();
                SAMMI.Common.Lang = appConfig.AppSettings.Settings["LANGUAGE"].Value.ToString();

                DataTable rtnDtTemp = _common.GET_TBM0000_CODE("LANGKY");

                SAMMI.Common.FontName = Convert.ToString(((DataRow[])rtnDtTemp.Select("CODE_ID = '" + SAMMI.Common.Lang + "'"))[0]["RelCode1"]);
                #endregion

                this.lblTitle.Text = "비가동 등록";

                SetMenuButtons();
                SetGroupButtons(); //그룹 운전상태
                //SetButtons(Common.OpCode); //개별 비가동 항목
                doFind();

                btnRightPage.LinkMoveSize = 5;
                btnLeftPage.LinkMoveSize = 5;


            }
            catch (Exception ex)
            {
                SetMessage("POP_WRK03_Load Error!");
                LogFile.WriteLog("POP_WRK03.POP_WRK03_Load Error => " + ex.Message);
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

                bBox1[0, 0].Text = "등록";
                bBox1[0, 0].Tag = "Confirm";
                bBox1[0, 0].MappingButton.FontSize = 14;
                bBox1[0, 1].Text = "비가동\n이력";
                bBox1[0, 1].Tag = "NonLog";
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
                LogFile.WriteLog("POP_WRK03.SetButtons Error => " + ex.Message);
            }
        }

        private void SetGroupButtons()
        {
            DBHelper helper = new DBHelper();
            DataTable dt = new DataTable();

            try
            {
                bGroup.ButtonBoxType = ButtonBox.ButtonBoxTypeEnum.Selection;
                bGroup.SelectionMode = ButtonBox.SelectionModeEnum.Single;

                //출력 버튼수
                bGroup.CountX = 5;
                bGroup.CountY = 2;
                //이동 간격
                bGroup_Up.LinkMoveSize = bGroup.CountY;
                bGroup_Down.LinkMoveSize = bGroup.CountY;
                //버튼 폰트
                bGroup.FontSize = 20;
                //버튼 목록 조회
                System.Data.DataSet ds = helper.FillDataSet("SP_POP_WRK03_S03", CommandType.StoredProcedure
                                                               , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_PROC_CD", Common.OpCode, DbType.String, ParameterDirection.Input));
                if (ds.Tables[0].Rows.Count < 1)
                {
                    new POPUP.MessageForm("조회된 운전상태가 없습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return;
                }
                else
                {
                    bGroup.DoFind_Oracle(ds);
                }
                //버튼 출력
                bGroup.RedrawButtons();

                //초기선택
                ButtonData bdGroup = bGroup.GetButtonList()[0];
                bdGroup.ButtonPressed = true;
                SetButtons(Common.OpCode, bdGroup.Tag.ToString());
            }
            catch (Exception ex)
            {
                SetMessage("SetButtons Error!");
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                LogFile.WriteLog("POP_WRK03.SetButtons Error => " + ex.Message);
            }
        }

        private void SetButtons(string OPCode, string RunSta)
        {
            DBHelper helper = new DBHelper();
            DataTable dt = new DataTable();

            try
            {
                bItem.ButtonBoxType = ButtonBox.ButtonBoxTypeEnum.Selection;
                bItem.SelectionMode = ButtonBox.SelectionModeEnum.Single;

                //출력 버튼수
                bItem.CountX = 5;
                bItem.CountY = 4;
                //이동 간격
                bItem_Up.LinkMoveSize = bItem.CountY;
                bItem_Down.LinkMoveSize = bItem.CountY;
                //버튼 폰트
                bItem.FontSize = 20;
                //버튼 목록 조회
                System.Data.DataSet ds = helper.FillDataSet("SP_POP_WRK03_S01", CommandType.StoredProcedure
                                                               , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_PROC_CD", OPCode, DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_RUN_STA", RunSta, DbType.String, ParameterDirection.Input));
                if (ds.Tables[0].Rows.Count < 1)
                {
                    new POPUP.MessageForm("조회된 비가동 목록이 없습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return;
                }
                else
                {
                    bItem.DoFind_Oracle(ds);
                }
                //버튼 출력
                bItem.RedrawButtons();
            }
            catch (Exception ex)
            {
                SetMessage("SetOPButtons Error!");
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                LogFile.WriteLog("POP_WRK03.SetButtons Error => " + ex.Message);
            }
        }

        private void doFind()
        {
            DBHelper helper = new DBHelper();
            DataTable dtTemp = new DataTable();
            DateTime dTempDate;

            try
            {

                dtTemp = helper.FillTable("SP_POP_WRK03_S02", CommandType.StoredProcedure
                                                               , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_MACHCD", Common.MachineCode, DbType.String, ParameterDirection.Input)
                    //, helper.CreateParameter("P_INOUT", Common.IOType, DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_WRK_ORDR_NO", Common.WrkOrderNo, DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_WRK_ORDR_SEQ", Common.WrkOrderSeq, DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input));
                //기존 비가동 여부 확인
                if (dtTemp.Rows.Count > 0)
                {
                    dtpEndDate.Enabled = true;
                    btnEndDate.Enabled = true;
                    lblEndTime.Enabled = true;
                    bBox1[0, 0].UseFlag = true;

                    //설비구분이 다른경우 등록불가처리
                    for (int i = 0; i < dtTemp.Rows.Count; i++)
                    {
                        if (!dtTemp.Rows[0]["IN_OUT"].ToString().Equals(Common.IOType))
                        {
                            dtpEndDate.Enabled = false;
                            btnEndDate.Enabled = false;
                            lblEndTime.Enabled = false;
                            bBox1[0, 0].UseFlag = false;
                        }
                    }

                    //현재 비가동 상태
                    bEndFlag = true;
                    dtpStartDate.Enabled = false;
                    butStartDate.Enabled = false;
                    lblStartTime.Enabled = false;
                    //시간정보 호출
                    if (DateTime.TryParse(dtTemp.Rows[0]["STR_DATE"].ToString(), out dTempDate))
                    {
                        dtpStartDate.Value = dTempDate;
                        lblStartTime.Text = dtpStartDate.Value.ToString("HH:mm");
                    }
                    else
                    {
                        dtpStartDate.Value = DateTime.Today;
                        lblStartTime.Text = dtpStartDate.Value.ToString("HH:mm");
                    }
                    //비고 정보 호출
                    txtRemark.Text = dtTemp.Rows[0]["RMK"].ToString();
                    //가동그룹정보 호출
                    foreach (ButtonData bdGroup in bGroup.GetButtonList())
                    {
                        if (dtTemp.Rows[0]["RUN_STA"].ToString().Equals(bdGroup.Tag.ToString()))
                        {
                            bdGroup.ButtonPressed = true;
                            sGrpCode = bdGroup.Tag.ToString();
                        }
                        else
                            bdGroup.ButtonPressed = false;
                    }
                    //그룹별 작업자 목록 조회
                    SetButtons(Common.OpCode, sGrpCode);
                    //버튼 클릭정보 호출
                    foreach (ButtonData bdItem in bItem.GetButtonList())
                    {
                        if (dtTemp.Rows[0]["ABN_CD"].ToString().Equals(bdItem.Tag.ToString()))
                        {
                            bdItem.ButtonPressed = true;
                            sNACode = bdItem.Tag.ToString();
                        }
                        else
                            bdItem.ButtonPressed = false;
                    }
                }
                else
                {
                    //현재 가동상태
                    bEndFlag = false;
                    dtpStartDate.Enabled = true;
                    butStartDate.Enabled = true;
                    lblStartTime.Enabled = true;
                    //현재 시간을 비가동시작시간에 등록
                    dtpStartDate.Value = DateTime.Now;
                    lblStartTime.Text = dtpStartDate.Value.ToString("HH:mm");

                    //비고 정보 호출
                    txtRemark.Text = "";
                }
                //완료시간 초기화
                dtpEndDate.Value = DateTime.Today;
                lblEndTime.Text = string.Empty;
            }
            catch (Exception ex)
            {
                SetMessage("SetGrid Error!");
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                LogFile.WriteLog("POP_WRK03.SetGrid Error => " + ex.Message);
            }
        }

        private void doConfirm()
        {
            DBHelper helper = new DBHelper(false, "", true);
            DataSet dsTemp;
            DataTable dtTemp; //RFC 결과
            string sRFCList; //RFC결과 JSON 변환
            string sMSG = string.Empty;
            DateTime dNowStartDate;
            DateTime dNowEndDate;
            string sNowStartDate;
            string sNowEndDate;
            string sRemark;
            string sRunStopMessage = string.Empty;
            int iRunStopLoopCount = 0;

            bool isConfirm = false;

            TimeSpan newDayTime = new TimeSpan(7, 0, 0); //새로운 날이 시작하는 기준 오전 07:00:00


            try
            {
                dNowStartDate = Common.makeDateTime(dtpStartDate.Value, lblStartTime.Text);
                dNowEndDate = Common.makeDateTime(dtpEndDate.Value, lblEndTime.Text);
                string sNowStartDateCHK = dNowStartDate.ToString("yyyy-MM-dd HH:mm:ss");
                bool sNowEndDateCHK = string.IsNullOrEmpty(lblEndTime.Text);

                sRemark = txtRemark.Text;

                //비가동항목 미선택시 메세지 처리
                if (string.IsNullOrEmpty(sNACode))
                {
                    new POPUP.MessageForm("비가동 항목을 선택하여 주시기 바랍니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return;
                }
                //시간입력 체크
                if (string.IsNullOrEmpty(lblStartTime.Text))
                {
                    new POPUP.MessageForm("비가동 시작시간을 입력하여 주시기 바랍니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return;
                }
                if (bEndFlag && string.IsNullOrEmpty(lblEndTime.Text))
                {
                    new POPUP.MessageForm("비가동 완료시간을 입력하여 주시기 바랍니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return;
                }
                if (!sNowEndDateCHK && dNowStartDate >= dNowEndDate)
                {
                    new POPUP.MessageForm("입력된 시간을 확인하여 주시기 바랍니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return;
                }


                helper.ExecuteNoneQuery("SP_POP_WRK03_S04", CommandType.StoredProcedure
                                  , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)
                                  , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)
                                  , helper.CreateParameter("P_PRD_STR_DATE", dNowStartDate.ToString("yyyy-MM-dd HH:mm:ss"), DbType.String, ParameterDirection.Input)
                                  , helper.CreateParameter("P_PRD_END_DATE", dNowEndDate.ToString("yyyy-MM-dd HH:mm:ss"), DbType.String, ParameterDirection.Input));
                if (helper.RSCODE == "E" && !string.IsNullOrEmpty(lblEndTime.Text))
                {
                    new POPUP.MessageForm(helper.RSMSG, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return;
                }

                this.Cursor = Cursors.WaitCursor;   //Waitting



                // 신규 비가동 액티비티 정의 : 오전 07:00:00 기준으로 유저가 입력한 시작시간 완료시간을 하루단위로 나누어 등록 /이성민
                // ex)  시작시간 2022-12-01 13:00:00, 완료시간 2022-12-04 08:30:00
                //      비가동 등록 예시
                //      비가동 1 시작시간 2022-12-01 13:00:00 ~ 2022-12-02 07:00:00
                //      비가동 2 시작시간 2022-12-02 07:00:00 ~ 2022-12-03 07:00:00
                //      비가동 3 시작시간 2022-12-03 07:00:00 ~ 2022-12-04 07:00:00
                //      비가동 4 시작시간 2022-12-04 07:00:00 ~ 2022-12-04 08:30:00
                for (DateTime iStartDate = dNowStartDate; iStartDate < dNowEndDate || sNowEndDateCHK; ) // 시작시간에서 + 1 Day 하며 시작시간이 종료시간을 Over할때까지 for문
                {

                    DateTime iEndDate = new DateTime();
                    TimeSpan TimeGap = new TimeSpan();
                    iRunStopLoopCount++;
                    string sRunStopCount = iRunStopLoopCount.ToString();
                    string sRunStopRange = string.Empty;
                    string calculTimeCHK = string.Empty;

                    if (sNowEndDateCHK) // 종료시간 미입력시 비가동 시작만 걸리도록 세팅
                    {
                        sNowStartDate = iStartDate.ToString("yyyy-MM-dd HH:mm:ss");
                        sNowEndDate = string.Empty;
                    }
                    else // 비가동 시간 분할을 위한 로직
                    {
                        DateTime cEndDate = iStartDate; // 07:00 반영용 변수
                        if (iStartDate.TimeOfDay < newDayTime) //비가동 시작시간이 07:00 이전일 경우 당일 비가동 등록 ex) 2022-12-01 06:30 ~ 2022-12-01 07:00
                        {
                            cEndDate = iStartDate; // 
                        }
                        else
                        {
                            cEndDate = iStartDate.AddDays(1); //비가동 시작시간이 07:00 이후면 하루 더해서 endtime 세팅
                        }

                        iEndDate = cEndDate.Date + newDayTime; //종료시간(EndDate)를 07:00으로 세팅

                        if (iEndDate >= dNowEndDate) // end date가 사용자가 입력한 date보다 클경우 입력값으로 세팅(최종 비가동등록용)
                        {
                            iEndDate = dNowEndDate;
                        }
                        Console.WriteLine(iStartDate.ToString() + " ~ " + iEndDate.ToString());
                        sRunStopRange = "[" + iStartDate.ToString() + " ~ " + iEndDate.ToString() + "]";

                        sNowStartDate = iStartDate.ToString("yyyy-MM-dd HH:mm:ss");
                        sNowEndDate = iEndDate.ToString("yyyy-MM-dd HH:mm:ss");
                    }

                    //작업시작/완료처리 (작업지시 상태변경 및 작업장 현황의 가동상태 변경)
                    dsTemp = helper.FillDataSetN("SP_POP_WRK03_I01", CommandType.StoredProcedure, 2
                                 , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)
                                 , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)
                                 , helper.CreateParameter("P_IOTYPE", Common.IOType, DbType.String, ParameterDirection.Input)
                                 , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input)
                                 , helper.CreateParameter("P_ORDER_NO", Common.OrderNo, DbType.String, ParameterDirection.Input)
                                 , helper.CreateParameter("P_WRK_ORDR_NO", Common.WrkOrderNo, DbType.String, ParameterDirection.Input)
                                 , helper.CreateParameter("P_WRK_ORDR_SEQNO", Common.WrkOrderSeq, DbType.String, ParameterDirection.Input)
                                 , helper.CreateParameter("P_MATNR", Common.ItemCode, DbType.String, ParameterDirection.Input)
                                 , helper.CreateParameter("P_LOT_NO", Common.LotNo, DbType.String, ParameterDirection.Input)
                                 , helper.CreateParameter("P_PRD_STR_DATE", sNowStartDate, DbType.String, ParameterDirection.Input)
                                 , helper.CreateParameter("P_PRD_END_DATE", sNowEndDate, DbType.String, ParameterDirection.Input)
                                 , helper.CreateParameter("P_ABN_CD", sNACode, DbType.String, ParameterDirection.Input)
                                 , helper.CreateParameter("P_RMK", sRemark, DbType.String, ParameterDirection.Input)
                                 , helper.CreateParameter("P_ABN_FUNC", DbType.String, ParameterDirection.Output, null, 30));
                    TimeGap = iEndDate - iStartDate;
                    if (!string.IsNullOrEmpty(lblEndTime.Text))
                    {
                        calculTimeCHK = Environment.NewLine + "   " + sRunStopRange + " " + (TimeGap.Days * 24 * 60 + TimeGap.Hours * 60 + TimeGap.Minutes) + " 분";
                    }


                    if (helper.RSCODE == "E")
                    {
                        this.Cursor = Cursors.Default;   //Waitting
                        new POPUP.MessageForm(helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                        //this.DialogResult = DialogResult.OK;
                        return;
                    }
                    else
                    {
                        if (string.IsNullOrEmpty(helper.Parameters["P_ABN_FUNC"].Value.ToString()))
                        {
                            this.Cursor = Cursors.Default;   //Waitting
                            sRunStopMessage += sRunStopCount + ". 비가동 이력이 등록되었습니다. " + calculTimeCHK + Environment.NewLine;
                            helper.Commit();
                            isConfirm = true;
                        }
                        else
                        {
                            //SAP 인터페이스
                            SAPHelper sapRFC = new SAPHelper();
                            if (sapRFC.CallSAPFunc(helper.Parameters["P_ABN_FUNC"].Value.ToString(), dsTemp.Tables[0], dsTemp.Tables[1], helper).Equals("S"))
                            {
                                //RFC 전송 결과 조회
                                dtTemp = sapRFC.rtnTable;
                                sRFCList = Common.toJsonFormat("POP_WRK003", dtTemp);
                                sRFCList = sRFCList.Replace("MBLNR", "RUECK");
                                sRFCList = sRFCList.Replace("MJAHR", "RMZHL");
                                //RFC 결과정보 DB등록
                                helper.ExecuteNoneQuery("SP_IF_PUT_WRKRTN", CommandType.StoredProcedure
                                                                  , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)
                                                                  , helper.CreateParameter("P_WRK_TYPE", "3", DbType.String, ParameterDirection.Input)
                                                                  , helper.CreateParameterOracle("P_RFC_DATA", sRFCList, OracleDbType.Clob, ParameterDirection.Input)
                                                                  , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input));

                                this.Cursor = Cursors.Default;   //Waitting
                                TimeGap = iEndDate - iStartDate;
                                sRunStopMessage += sRunStopCount + ". 비가동 이력이 등록되었습니다. " + calculTimeCHK + Environment.NewLine;
                                helper.Commit();
                                isConfirm = true;
                            }
                            else
                            {
                                this.Cursor = Cursors.Default;   //Waitting
                                sRunStopMessage += sRunStopCount + ". 비가동 이력등록이 실패하였습니다. " + calculTimeCHK + sapRFC.rtnMSG;
                                helper.Rollback();
                                return;
                            }
                            Thread.Sleep(1000);
                        }

                    }
                    iStartDate = iEndDate; // 종료시간을 시작시간으로 세팅
                    if (sNowEndDateCHK) // end date 사용자 미입력 시 loop 돌지 않도록 break
                    {
                        sNowEndDateCHK = false;
                        break;
                    }
                }
                //return;

                new POPUP.MessageForm_ERR("비가동 등록", sRunStopMessage, MessageBoxButtons.OK).ShowDialog(this);
            }
            catch (Exception ex)
            {
                this.Cursor = Cursors.Default;   //Waitting
                SetMessage("SetGrid Error!");
                LogFile.WriteLog("POP_WRK03.SetGrid Error => " + ex.Message);
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
            }
            finally
            {
                this.Cursor = Cursors.Default;   //Waitting
                helper.Close();

                if (isConfirm == true)
                {
                    doFind();
                }
            }
        }

        private void AutoCalculation()
        {
            DateTime dtStartDate;
            DateTime dtEndDate;


            dtStartDate = Common.makeDateTime(dtpStartDate.Value, lblStartTime.Text);
            dtEndDate = Common.makeDateTime(dtpEndDate.Value, lblEndTime.Text);

            TimeSpan Diff_dates = dtEndDate.Subtract(dtStartDate);


            if (Diff_dates.TotalMinutes > 0)
            {
                lblNonActTime.Text = string.Format("{0}", Diff_dates.TotalMinutes);
            }
            else
            {
                lblNonActTime.Text = "0";

                SetMessage("작업 시작일시/종료일시를 확인하세요!");
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

                MESButton btn = sender;

                switch (btn.Tag.ToString())
                {

                    case "Confirm":  //비가동 시작
                        doConfirm();
                        break;
                    case "NonLog":  //비가동 이력
                        POP_WRK39 WRK39 = new POP_WRK39();
                        ShowDialogForm(WRK39);
                        break;

                    case "Close": //이전화면
                        this.Close();
                        break;
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
                LogFile.WriteLog("POP_WRK03.bBox1_buttonClickEvent Error => " + ex.Message);
            }
            finally
            {

            }
        }

        private void btnWorkDate_Click(object sender, EventArgs e)
        {
            Button btnTemp = (Button)sender;

            DateTime dt = DateTime.Today;
            if ((btnTemp.Tag.ToString() == "startDate"))
            {
                dt = dtpStartDate.Value;
            }
            else if ((btnTemp.Tag.ToString() == "endDate"))
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
                else if (btnTemp.Tag.ToString() == "endDate")
                {
                    dtpEndDate.Value = DateTime.Parse(strDate);
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
            AutoCalculation();
        }

        private void bGroup_buttonChangeEvent(MESButton sender, ButtonBox.ButtonClickEventArg e)
        {
            //선택된 그룹코드
            sGrpCode = sender.Tag.ToString();
            //그룹별 작업자 목록 조회
            SetButtons(Common.OpCode, sGrpCode);
            //선택된 비가동 항목 초기화
            sNACode = string.Empty;
        }

        private void bItem_buttonChangeEvent(MESButton sender, ButtonBox.ButtonClickEventArg e)
        {
            MESButton btn = sender;

            //선택된 작업자 등록
            if (btn.ButtonPressed)
                sNACode = btn.Tag.ToString();
            else
                sNACode = string.Empty;
        }

        #endregion


    }
}
