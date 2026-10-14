#region [ USING AREA ]
using System;
using System.Configuration;
using System.Data;
using System.Windows.Forms;
using Infragistics.Win.UltraWinGrid;


using SAMMI;
using SmartDas.Components;
using SmartDas.POPUP;


#endregion

namespace SmartDas
{
    public partial class POP_WRK39 : BaseForm
    {
        #region < MEMBER AREA >
        private string sStartTime = string.Empty;

        private SAMMI.Common _common = new SAMMI.Common();

        public static string userID = string.Empty;
        public static string userName = string.Empty;

        #endregion

        #region < CONSTRUCTOR >

        public POP_WRK39()
        {
            InitializeComponent();

            Common.SetMessageList();

        }
        #endregion

        #region < POP_WRK39_Load >
        private void POP_WRK39_Load(object sender, EventArgs e)
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

                this.lblTitle.Text = "비가동 이력";

                dtpWorkDate.Value = DateTime.Now;

                SetMenuButtons();
                SetGrid();
            }
            catch (Exception ex)
            {
                SetMessage("POP_WRK39_Load_ Error!");
                LogFile.WriteLog("POP_WRK39.POP_WRK39_Load Error => " + ex.Message);
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

                bBox1[0, 0].Text = "비가동\n취소";
                bBox1[0, 0].Tag = "Delete";
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
                LogFile.WriteLog("POP_WRK39.SetButtons Error => " + ex.Message);
            }
        }

        private void SetGrid()
        {
            DBHelper helper = new DBHelper();
            DataSet dsTemp = new DataSet();
            string sWorkDate = string.Empty;

            try
            {
                sWorkDate = dtpWorkDate.Value.ToString("yyyyMMdd");

                Grid1.HeaderFontSize = 13;
                Grid1.FontSize = 13;
                Grid1.CountRows = 10;
                Grid1.AutoScroll = true;
                Grid1.DisplayLayout.Scrollbars = Scrollbars.Both;
                btnRightPage.LinkMoveSize = Grid1.CountRows;
                btnLeftPage.LinkMoveSize = Grid1.CountRows;

                dsTemp = helper.FillDataSetN("SP_POP_WRK39_S01", CommandType.StoredProcedure, 2
                                                               , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_IOTYPE", Common.IOType, DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_WRK_DT", sWorkDate, DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input)
                                                               );
                //그리드 출력
                Grid1.DoFind_Oracle(dsTemp);
            }
            catch (Exception ex)
            {
                SetMessage("SetGrid Error!");
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                LogFile.WriteLog("POP_WRK39.SetGrid Error => " + ex.Message);
            }
        }

        private void doConfirm(string pCancelList)
        {
            DBHelper helper = new DBHelper(false,"",true);
            DataSet dsTemp;
            bool bCheckrd = false;
            bool bInOutChk = false;
            try
            {
                //체크된 항목 확인
                for (int i = 0; i < Grid1.Rows.Count; i++)
                {
                    if (Grid1.Rows[i].Cells["CHK"].Value.ToString().Equals("V"))
                    {
                        bCheckrd = true;
                        //선택한 설비정보 확인
                        if (!Grid1.Rows[i].Cells["MACH_CD"].Value.ToString().Equals(Common.MachineCode))
                        {
                            bInOutChk = true;
                        }
                        else if (!Grid1.Rows[i].Cells["IN_OUT"].Value.ToString().Equals(Common.IOType))
                        {
                            bInOutChk = true;
                        }
                    }
                }

                if (bInOutChk)
                {
                    new POPUP.MessageForm("비가동이력은 등록한 설비에서 취소가 가능합니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return;
                }

                if (bCheckrd)
                {
                    LogFile.WriteLog(string.Format("비가동취소 리스트 => {0}, {1}, {2}, [{3}]", Common.PlantCode, Common.MachineCode, Common.IOType, pCancelList), LogType.PROC);

                    this.Cursor = Cursors.WaitCursor;   //Waitting
                    dsTemp = helper.FillDataSetN("SP_POP_WRK39_D01", CommandType.StoredProcedure, 2
                     , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)
                     , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)
                     , helper.CreateParameter("P_IOTYPE", Common.IOType, DbType.String, ParameterDirection.Input)
                     , helper.CreateParameter("P_LIST", pCancelList, DbType.String, ParameterDirection.Input)
                     , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input)
                     , helper.CreateParameter("P_ABN_FUNC", DbType.String, ParameterDirection.Output, null, 30)
                       );

                    if (helper.RSCODE == "E")
                    {
                        this.Cursor = Cursors.Default;   //Waitting
                        LogFile.WriteLog("비가동취소_E1 => " + helper.RSMSG.ToString());
                        new POPUP.MessageForm(helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                        this.DialogResult = DialogResult.OK;
                        return;
                    }
                    else
                    {
                        string sRS_PRFM_RFCFN = helper.Parameters["P_ABN_FUNC"].Value.ToString();      // 실적 RFCFN ID

                        LogFile.WriteLog(string.Format("비가동취소_01 => {0}", sRS_PRFM_RFCFN), LogType.PROC);

                        if (string.IsNullOrEmpty(sRS_PRFM_RFCFN) == false)
                        {
                            //SAP 인터페이스
                            SAPHelper sapRFC = new SAPHelper();
                            if (sapRFC.CallSAPFunc(helper.Parameters["P_ABN_FUNC"].Value.ToString(), dsTemp.Tables[0], dsTemp.Tables[1], helper).Equals("S"))
                            {
                                this.Cursor = Cursors.Default;   //Waitting

                                LogFile.WriteLog("SAP-선택된 이력이 취소 되었습니다.", LogType.ERROR);
                                new POPUP.MessageForm("선택된 이력이 취소 되었습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                            }
                            else
                            {
                                this.Cursor = Cursors.Default;   //Waitting

                                LogFile.WriteLog("SAP-비가동 이력취소가 실패하였습니다.", LogType.ERROR);
                                new POPUP.MessageForm("비가동 이력취소가 실패하였습니다.\n" + sapRFC.rtnMSG, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                helper.Rollback();
                                return;
                            }
                        }
                        else
                        {
                            this.Cursor = Cursors.Default;   //Waitting

                            LogFile.WriteLog("선택된 이력이 취소 되었습니다.", LogType.ERROR);
                            new POPUP.MessageForm("선택된 이력이 취소 되었습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                        }


                    }
                }
                else
                {
                    this.Cursor = Cursors.Default;   //Waitting
                    LogFile.WriteLog("취소할 이력을 선택하여 주시기 바랍니다.", LogType.ERROR);
                    new POPUP.MessageForm("취소할 이력을 선택하여 주시기 바랍니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                }
            }
            catch (Exception ex)
            {
                this.Cursor = Cursors.Default;   //Waitting
                LogFile.WriteLog("POP_WRK39.doConfirm Error => " + ex.Message);
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
            }
            finally
            {
                this.Cursor = Cursors.Default;   //Waitting
                helper.Close();

                if (bCheckrd == true)
                {
                    SetGrid();
                }
            }
        }

        private string setReqList()
        {
            string sRtnReqList = string.Empty;
            DataTable WrkOrderList = (DataTable)Grid1.DataSource;

            for (int i = 0; i < WrkOrderList.Rows.Count; i++)
            {
                //선택된 행처리
                if (WrkOrderList.Rows[i]["CHK"].ToString().Equals("V"))
                {
                    sRtnReqList = sRtnReqList + WrkOrderList.Rows[i]["PRD_STR_DATE"].ToString() + ",";
                }
            }
            return sRtnReqList;
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
                    case "Delete":  //비가동취소
                        doConfirm(setReqList());
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
                LogFile.WriteLog("POP_WRK39.bBox1_buttonClickEvent Error => " + ex.Message);
            }
            finally
            {

            }
        }

        private void butMoveDate_Click(object sender, EventArgs e)
        {
            Button btnTemp = (Button)sender;

            DAResultDate pop = new DAResultDate(dtpWorkDate.Value);
            pop.ShowDialog(this);
            if (pop.DialogResult == DialogResult.OK)
            {
                string strDate = pop.ResultString.ToString();
                dtpWorkDate.Value = DateTime.Parse(strDate);
            }
        }

        private void cboOrderDate_ValueChanged(object sender, EventArgs e)
        {
            SetGrid();
        }

        private void btnFind_Click(object sender, EventArgs e)
        {
            SetGrid();
        }

        private void Grid1_ClickCellButton(object sender, MESGrid.GridClickEventArg e)
        {
            if (e.column.ToString() == "CHK")
            {
                string sStatus_Pre = e.row.Cells["CHK"].Value.ToString();

                if (sStatus_Pre != "V")
                {
                    foreach (UltraGridRow row in Grid1.Rows)
                    {
                        row.Cells["CHK"].Value = "-";
                    }
                }

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
    }
}
