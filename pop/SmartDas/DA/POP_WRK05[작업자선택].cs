#region [ USING AREA ]
using System;
using System.Configuration;
using System.Data;
using System.Windows.Forms;

using SAMMI;
using SmartDas.Components;
using SmartDas.POPUP;
using System.Drawing;

#endregion

namespace SmartDas
{
    public partial class POP_WRK05 : BaseForm
    {
        #region < MEMBER AREA >

        private SAMMI.Common _common = new SAMMI.Common();
        Configuration appConfig = ConfigurationManager.OpenExeConfiguration(ConfigurationUserLevel.None);

        private string sSelGrpCode = string.Empty;
        private string sGrpCode = string.Empty;
        private string sWrkTime = string.Empty;
        private string sWrkTimeNM = string.Empty;
        private string sMainWorker = string.Empty;
        private string sMainWorkerNM = string.Empty;
        private string sMachCode = string.Empty;
        private string sIOType = string.Empty;

        #endregion

        #region < CONSTRUCTOR >

        public POP_WRK05()
        {
            InitializeComponent();

            Common.SetMessageList();

        }

        public POP_WRK05(string pMach_CD, string pIO_Type)
        {
            InitializeComponent();

            Common.SetMessageList();

            sMachCode = pMach_CD;
            sIOType = pIO_Type;
        }
        #endregion

        #region < POP_WRK05_Load >
        private void POP_WRK05_Load(object sender, EventArgs e)
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

                this.lblTitle.Text = "작업자 선택";
                //설비(작업장) 정보 조회
                //sMachCode = appConfig.AppSettings.Settings["MACHCODE"].Value.ToString();

                // 근무시간 ComboBox
                setCombo();
                cboWorkTime.SelectedIndex = -1;
                cboWorkTime.ValueList.ItemHeight = 70;

                SetMenuButtons();
                SetGroupButtons(Common.OpCode);
                doFind();
            }
            catch (Exception ex)
            {
                SetMessage("POP_WRK05_Load Error!");
                LogFile.WriteLog("POP_WRK05.POP_WRK05_Load Error => " + ex.Message);
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

                bBox1[0, 0].Text = "작업자\n등록";
                bBox1[0, 0].Tag = "Confirm";
                bBox1[0, 0].MappingButton.FontSize = 14;
                bBox1[0, 1].Text = "작업자\n수정";
                bBox1[0, 1].Tag = "Update";
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
                LogFile.WriteLog("POP_WRK05.SetButtons Error => " + ex.Message);
            }
        }

        private void SetGroupButtons(string pGrp)
        {
            DBHelper helper = new DBHelper();
            DataTable dt = new DataTable();

            try
            {
                bGroup.ButtonBoxType = ButtonBox.ButtonBoxTypeEnum.Selection;
                bGroup.SelectionMode = ButtonBox.SelectionModeEnum.Single;

                //출력 버튼수
                bGroup.CountX = 5;
                bGroup.CountY = 1;
                //이동 간격
                bGroup_Up.LinkMoveSize = bWorker.CountY;
                bGroup_Down.LinkMoveSize = bWorker.CountY;
                //버튼 폰트
                bGroup.FontSize = 20;
                //버튼 목록 조회
                System.Data.DataSet ds = helper.FillDataSet("SP_POP_WRK05_S01", CommandType.StoredProcedure
                                                               , helper.CreateParameter("P_PROC_CD", pGrp, DbType.String, ParameterDirection.Input));
                if (ds.Tables[0].Rows.Count < 1)
                {
                    SetMessage("조회된 작업반이 없습니다.");
                    new POPUP.MessageForm("조회된 작업반이 없습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
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
                sGrpCode = bdGroup.Tag.ToString();
                sSelGrpCode = sGrpCode;
                SetButtons(Common.OpCode, bdGroup.Tag.ToString());
            }
            catch (Exception ex)
            {
                SetMessage("SetOPButtons Error!");
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                LogFile.WriteLog("POP_WRK05.SetOPButtons Error => " + ex.Message);
            }
        }

        private void SetButtons(string pGrp, string pShift)
        {
            DBHelper helper = new DBHelper();
            DataTable dt = new DataTable();

            try
            {
                //작업자
                bWorker.ButtonBoxType = ButtonBox.ButtonBoxTypeEnum.Selection;
                bWorker.SelectionMode = ButtonBox.SelectionModeEnum.Single;
                //출력 버튼수
                bWorker.CountX = 5;
                bWorker.CountY = 6;
                //화살표 클릭시 이동수
                bWorker_Up.LinkMoveSize = bWorker.CountY;
                bWorker_Down.LinkMoveSize = bWorker.CountY;
                //버튼 폰트
                bWorker.FontSize = 25;
                //버튼 목록 조회
                System.Data.DataSet ds = helper.FillDataSet("SP_POP_WRK05_S02", CommandType.StoredProcedure
                                                               , helper.CreateParameter("P_PROC_CD", pGrp, DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_CLASS", pShift, DbType.String, ParameterDirection.Input));
                if (ds.Tables[0].Rows.Count < 1)
                {
                    SetMessage("조회된 작업자가 없습니다.");
                    new POPUP.MessageForm("조회된 작업자가 없습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return;
                }
                else
                {
                    bWorker.DoFind_Oracle(ds);
                    //작업조 인원정보 등록
                    lblWorkerCnt.Text = "1"; // ds.Tables[0].Rows.Count.ToString();

                    //선택된 작업자 저장
                    for (int i = 0; i < ds.Tables[0].Rows.Count; i++)
                    {
                        if (ds.Tables[0].Rows[i]["CHECKED"].ToString().Equals("Y"))
                        {
                            sMainWorker = ds.Tables[0].Rows[i]["USERID"].ToString();
                            sMainWorkerNM = ds.Tables[0].Rows[i]["USERNM"].ToString();
                        }
                    }
                }

                ////기존 선택된 정보 조회
                //if (!string.IsNullOrEmpty(sSelGrpCode))
                //{
                //    if (sSelGrpCode.Equals(sGrpCode))
                //    {
                //        if (!string.IsNullOrEmpty(sMainWorker))
                //        {
                //            ButtonData btnData = bWorker.GetButtonByTag(sMainWorker);
                //            if (btnData != null)
                //                btnData.ButtonPressed = true;
                //        }
                //    }
                //}
                //버튼 출력
                bWorker.RedrawButtons();
            }
            catch (Exception ex)
            {
                SetMessage("SetButtons Error!");
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                LogFile.WriteLog("POP_WRK05.SetButtons Error => " + ex.Message);
            }
        }

        private void setCombo()
        {
            DBHelper helper = new DBHelper(false);
            DataTable dtRtn;

            try
            {
                dtRtn = helper.FillTable("SP_POP00_S02", CommandType.StoredProcedure
                                                               , helper.CreateParameter("P_CBOTYPE", "WORKTIME", DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_FILTER", Common.MachineCode, DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_COLINFO", DbType.String, ParameterDirection.Output, null, 1000)
                                                               , helper.CreateParameter("P_COLTYPE", DbType.String, ParameterDirection.Output, null, 1000));
                if (dtRtn.Rows.Count < 1)
                {
                    return;
                }
                else
                {
                    cboWorkTime.Items.Clear();

                    foreach (DataRow row in dtRtn.Rows)
                    {
                        //string sWRK_TIME = string.Format("{0} ~ {1}", row["STR_TM"].ToString().Insert(2, ":"), row["END_TM"].ToString().Insert(2, ":") ) ;
                        //cboWorkTime.Items.Add(row["ITEMCODE"].ToString(), sWRK_TIME);
                        cboWorkTime.Items.Add(row["ITEMCODE"].ToString(), row["DISPLAY"].ToString());
                    }
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

        private void doFind()
        {
            DBHelper helper = new DBHelper();
            DataTable dtTemp = new DataTable();
            DateTime dTempDate;

            try
            {
                //현재 작업자 조회
                dtTemp = helper.FillTable("SP_POP_WRK05_S03", CommandType.StoredProcedure
                                                          , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)
                                                          , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)
                                                          , helper.CreateParameter("P_IOTYPE", Common.IOType, DbType.String, ParameterDirection.Input));
                if (dtTemp.Rows.Count == 1)
                {
                    lblWorkerCnt.Text = dtTemp.Rows[0]["WRKER_CNT"].ToString(); //작업인원

                    //작업 시간 정보
                    sWrkTime = dtTemp.Rows[0]["WRK_SHIFT"].ToString();
                    sWrkTimeNM = dtTemp.Rows[0]["WRK_SHIFT_NM"].ToString(); //name

                    //시간정보 호출
                    if (DateTime.TryParse(dtTemp.Rows[0]["PRD_STR_DATE"].ToString(), out dTempDate))
                    {
                        dtpPRD_STR_DATE.Value = dTempDate;
                        cboWorkTime.SelectedText = sWrkTime;
                    }

                    //작업인원수 조회
                    lblWorkerCnt.Text = dtTemp.Rows[0]["WRKER_CNT"].ToString();

                    #region 작업반장 기본 선택처리로 인한 기존 작업자 조회기능 미사용처리
                    ////가동그룹정보 호출
                    //foreach (ButtonData bdGroup in bGroup.GetButtonList())
                    //{
                    //    if (dtTemp.Rows[0]["WRK_CLASS"].ToString().Equals(bdGroup.Tag.ToString()))
                    //    {
                    //        bdGroup.ButtonPressed = true;
                    //        sGrpCode = bdGroup.Tag.ToString();
                    //    }
                    //    else
                    //        bdGroup.ButtonPressed = false;
                    //}
                    ////그룹별 작업자 목록 조회
                    //SetButtons(Common.OpCode, sGrpCode);
                    ////버튼 클릭정보 호출
                    //foreach (ButtonData bdItem in bWorker.GetButtonList())
                    //{
                    //    if (dtTemp.Rows[0]["EMPLY_NO"].ToString().Equals(bdItem.Tag.ToString()))
                    //    {
                    //        bdItem.ButtonPressed = true;
                    //        sMainWorker = bdItem.Tag.ToString();
                    //        sMainWorkerNM = bdItem.Text;
                    //    }
                    //    else
                    //        bdItem.ButtonPressed = false;
                    //}
                    #endregion

                }
            }
            catch (Exception ex)
            {
                SetMessage("doFind Error!");
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                LogFile.WriteLog("POP_WRK05.Find Error => " + ex.Message);
            }
        }

        private void doConfirm()
        {
            string sWorkDT = string.Empty;
            string sWorkCnt = string.Empty;
            string sMessage = string.Empty;

            if (string.IsNullOrEmpty(sMainWorker))
            {
                sMessage = "작업자를 선택 후 확인을 눌러주세요.";
                SetMessage(sMessage);
                new POPUP.MessageForm(sMessage, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return;
            }

            if (string.IsNullOrEmpty(sMachCode))
            {
                sMessage = "투입설비를 선택 후 확인을 눌러주세요.";
                SetMessage(sMessage);
                new POPUP.MessageForm(sMessage, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return;
            }

            if (string.IsNullOrEmpty(sWrkTime))
            {
                sMessage = "작업시간을 선택 후 확인을 눌러주세요.";
                SetMessage(sMessage);
                new POPUP.MessageForm(sMessage, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return;
            }

            DBHelper helper = new DBHelper();
            try
            {
                sWorkDT = dtpPRD_STR_DATE.Value.ToString("yyyyMMdd");
                sWorkCnt = lblWorkerCnt.Text;

                helper.ExecuteNoneQuery("SP_POP_WRK05_I01", CommandType.StoredProcedure
                        , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)
                        , helper.CreateParameter("P_WRK_DT", sWorkDT, DbType.String, ParameterDirection.Input)
                        , helper.CreateParameter("P_WRK_TIME", sWrkTime, DbType.String, ParameterDirection.Input)
                        , helper.CreateParameter("P_WRK_CLASS", sGrpCode, DbType.String, ParameterDirection.Input)
                        , helper.CreateParameter("P_WORKER", sMainWorker, DbType.String, ParameterDirection.Input)
                        , helper.CreateParameter("P_WORKERCNT", sWorkCnt, DbType.String, ParameterDirection.Input)
                        , helper.CreateParameter("P_MACH_CD", sMachCode, DbType.String, ParameterDirection.Input)
                        , helper.CreateParameter("P_IOTYPE", sIOType, DbType.String, ParameterDirection.Input)
                        , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input)
                        );

                if (helper.RSCODE == "E")
                {
                    //SetMessage(helper.RSMSG);
                    new POPUP.MessageForm(helper.RSMSG, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    //this.DialogResult = DialogResult.OK;
                    return;
                }
                //Baseform출력 수정
                Common.UserID = sMainWorker;
                Common.machSetting();
                this.DialogResult = DialogResult.OK;
            }
            catch (Exception ex)
            {
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                SetMessage("POP_WRK05.btnConfirm_ClickEvent Error" + ex.ToString());
            }
            finally
            {
                helper.Close();
            }
        }
        private void doUpdate()
        {
            string sWorkDT = string.Empty;
            string sWorkCnt = string.Empty;

            if (string.IsNullOrEmpty(sMainWorker))
            {
                SetMessage("작업자를 선택 후 확인을 눌러주세요.");
                new POPUP.MessageForm("작업자를 선택 후 확인을 눌러주세요.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return;
            }

            if (string.IsNullOrEmpty(sMachCode))
            {
                SetMessage("투입설비를 선택 후 확인을 눌러주세요.");
                new POPUP.MessageForm("투입설비를 선택 후 확인을 눌러주세요.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return;
            }

            DBHelper helper = new DBHelper();
            try
            {
                sWorkDT = dtpPRD_STR_DATE.Value.ToString("yyyyMMdd");
                sWorkCnt = lblWorkerCnt.Text;

                helper.ExecuteNoneQuery("SP_POP_WRK05_U01", CommandType.StoredProcedure
                        , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)
                        , helper.CreateParameter("P_WRK_DT", sWorkDT, DbType.String, ParameterDirection.Input)
                        , helper.CreateParameter("P_WRK_TIME", sWrkTime, DbType.String, ParameterDirection.Input)
                        , helper.CreateParameter("P_WRK_CLASS", sGrpCode, DbType.String, ParameterDirection.Input)
                        //, helper.CreateParameter("P_BEF_WORKER", "", DbType.String, ParameterDirection.Input)
                        , helper.CreateParameter("P_WORKER", sMainWorker, DbType.String, ParameterDirection.Input)
                        , helper.CreateParameter("P_WORKERCNT", sWorkCnt, DbType.String, ParameterDirection.Input)
                        , helper.CreateParameter("P_MACH_CD", sMachCode, DbType.String, ParameterDirection.Input)
                        , helper.CreateParameter("P_IOTYPE", sIOType, DbType.String, ParameterDirection.Input)
                        , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input)
                        );

                if (helper.RSCODE == "E")
                {
                    SetMessage(helper.RSMSG);
                    new POPUP.MessageForm(helper.RSMSG, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return;
                }
                //Baseform출력 수정
                Common.UserID = sMainWorker;
                Common.machSetting();
                this.DialogResult = DialogResult.OK;
            }
            catch (Exception ex)
            {
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                SetMessage("POP_WRK05.btnConfirm_ClickEvent Error" + ex.ToString());
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
            //팝업 변수
            POPUP.MessageForm msgForm = null;
            DialogResult res = DialogResult.Cancel;

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
                    case "Confirm":  //작업자 선택
                        if (string.IsNullOrEmpty(sMainWorker))
                        {
                            msgForm = new POPUP.MessageForm("대표자를 선택하여 주시기 바랍니다.", MessageBoxButtons.OK, "알   림");
                            res = msgForm.ShowDialog(this);
                        }
                        else if (string.IsNullOrEmpty(lblWorkerCnt.Text))
                        {
                            //SetMessage("작업 인원을 입력하여 주시기 바랍니다.");
                            //return;
                            msgForm = new POPUP.MessageForm("작업 인원을 입력하여 주시기 바랍니다.", MessageBoxButtons.OK, "알   림");
                            res = msgForm.ShowDialog(this);
                        }
                        else if (string.IsNullOrEmpty(sWrkTime))
                        {
                            //SetMessage("작업 시간을 입력하여 주시기 바랍니다.");
                            //return;
                            msgForm = new POPUP.MessageForm("작업 시간을 입력하여 주시기 바랍니다.", MessageBoxButtons.OK, "알   림");
                            res = msgForm.ShowDialog(this);
                        }
                        else
                        {
                            msgForm = new POPUP.MessageForm("작업인원을 등록하시겠습니까?", MessageBoxButtons.OKCancel, "알   림");
                            res = msgForm.ShowDialog(this);
                            if (res == System.Windows.Forms.DialogResult.OK)
                                doConfirm();
                        }
                        break;
                    case "Update":  //작업자 수정
                        if (string.IsNullOrEmpty(sMainWorker))
                        {
                            msgForm = new POPUP.MessageForm("대표자를 선택하여 주시기 바랍니다.", MessageBoxButtons.OK, "알   림");
                            res = msgForm.ShowDialog(this);
                        }
                        else if (string.IsNullOrEmpty(lblWorkerCnt.Text))
                        {
                            //SetMessage("작업 인원을 입력하여 주시기 바랍니다.");
                            //return;
                            msgForm = new POPUP.MessageForm("작업 인원을 입력하여 주시기 바랍니다.", MessageBoxButtons.OK, "알   림");
                            res = msgForm.ShowDialog(this);
                        }
                        else if (string.IsNullOrEmpty(sWrkTime))
                        {
                            //SetMessage("작업 시간을 입력하여 주시기 바랍니다.");
                            //return;
                            msgForm = new POPUP.MessageForm("작업 시간을 입력하여 주시기 바랍니다.", MessageBoxButtons.OK, "알   림");
                            res = msgForm.ShowDialog(this);
                        }
                        else
                        {
                            msgForm = new POPUP.MessageForm("작업인원 정보를 수정하시겠습니까?", MessageBoxButtons.OKCancel, "알   림");
                            res = msgForm.ShowDialog(this);
                            if (res == System.Windows.Forms.DialogResult.OK)
                                doUpdate();
                        }
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
                LogFile.WriteLog("DA0500.bBox1_buttonClickEvent Error => " + ex.Message);
            }
            finally
            {

            }
        }

        private void bGroup_buttonChangeEvent(MESButton sender, ButtonBox.ButtonClickEventArg e)
        {
            //선택된 그룹코드
            sGrpCode = sender.Tag.ToString();
            if (!lblEditFlag.Text.Equals("V"))
            {
                //그룹별 작업자 목록 조회
                SetButtons(Common.OpCode, sGrpCode);
            }
        }

        private void bWorker_buttonChangeEvent(MESButton sender, ButtonBox.ButtonClickEventArg e)
        {
            MESButton btn = sender;
            //선택된 작업자 그룹 저장
            sSelGrpCode = sGrpCode;
            //선택된 작업자 등록
            sMainWorker = btn.Tag.ToString();
            sMainWorkerNM = btn.Text;
        }

        private void lblWorkerCnt_Click(object sender, EventArgs e)
        {
            DAResultQty pop = new DAResultQty();
            pop.LabelTitle = "작업자 인원 입력";
            pop.LabelHeader = "인원수";
            pop.ContentMaxLength = 4;

            pop.ShowDialog(this);
            if (pop.DialogResult == DialogResult.OK)
            {
                //인원수 정보 출력
                lblWorkerCnt.Text = string.Format("{0:#,0}", pop.ResultDouble);
            }
        }

        private void btnREQ_STR_DATE_Click(object sender, EventArgs e)
        {
            Button btnTemp = (Button)sender;

            DAResultDate pop = new DAResultDate(dtpPRD_STR_DATE.Value);
            pop.ShowDialog(this);
            if (pop.DialogResult == DialogResult.OK)
            {
                string strDate = pop.ResultString.ToString();
                dtpPRD_STR_DATE.Value = DateTime.Parse(strDate);

            }
        }

        private void dtpDate_DropDown(object sender, EventArgs e)
        {
            CommonCalendar.CloseCalendar((DateTimePicker)sender);
        }

        private void cboWorkTime_ValueChanged(object sender, EventArgs e)
        {
            sWrkTime = cboWorkTime.Items[cboWorkTime.SelectedIndex].DataValue.ToString();
        }

        private void lblEditFlag_Click(object sender, EventArgs e)
        {
            if (lblEditFlag.Text.ToString().Equals("V"))
            {
                lblEditFlag.Text = "";
                lblEditFlag.BackColor = Color.White;
                //그룹별 작업자 목록 조회
                SetButtons(Common.OpCode, sGrpCode);
            }
            else
            {
                lblEditFlag.Text = "V";
                lblEditFlag.BackColor = Color.Yellow;
            }
        }
        #endregion
    }
}
