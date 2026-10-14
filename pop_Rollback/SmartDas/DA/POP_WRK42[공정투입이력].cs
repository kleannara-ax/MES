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
    public partial class POP_WRK42 : BaseForm
    {
        #region < MEMBER AREA >
        private SAMMI.Common _common = new SAMMI.Common();
        private string gsRESULT = "NG";     // 본 화면에서 데이타 변경( 투입취소, etc) 발생 여부를 넘기기 위해...
        #endregion

        #region < CONSTRUCTOR >
        private static string gsLOC_CD = "";

        public POP_WRK42()
        {
            InitializeComponent();

            Common.SetMessageList();
        }

        public POP_WRK42(string sLOC_CD)
        {
            InitializeComponent();

            Common.SetMessageList();

            gsLOC_CD = sLOC_CD;
        }
        #endregion

        #region < POP_WRK42_Load >
        private void POP_WRK42_Load(object sender, EventArgs e)
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

                //조회기간 초기설정
                DateTime daysBefore = DateTime.Now;
                daysBefore = daysBefore.AddDays(-1);
                dtpINP_STR_DATE.Value = daysBefore;
                dtpINP_END_DATE.Value = DateTime.Now;

                this.lblTitle.Text = "공정투입 이력";

                SetMenuButtons();
                SetGrid();
                DoFind();
            }
            catch (Exception ex)
            {
                SetMessage("POP_WRK42_Load_ Error!");
                LogFile.WriteLog("POP_WRK42.POP_WRK42_Load Error => " + ex.Message);
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

                bBox1[0, 0].Text = "공정투입" + Environment.NewLine + "취소";
                bBox1[0, 0].Tag = "Cancel";
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
                LogFile.WriteLog("POP_WRK42.SetButtons Error => " + ex.Message);
            }
        }

        private void DoFind()
        {

            //////2018 05 03 hjh 
            //////처음 메인화면 접속 시, 라인 선택 후, 작업자 선택 후, 지시 선택 후 호출
            //Grid1.SetStoreProc();
            //Grid1.ParameterList.Add(new SqlParameter("OrderDateS", SqlDbType.VarChar));
            //Grid1.ParameterList.Add(new SqlParameter("OrderDateE", SqlDbType.VarChar));
            //Grid1.ParameterList.Add(new SqlParameter("Flag", SqlDbType.VarChar));
            //Grid1.ParameterList.Add(new SqlParameter("LineCode", SqlDbType.VarChar));
            //Grid1.ParameterList["OrderDateS"].Value = cboOrderDateS.Text;
            //Grid1.ParameterList["OrderDateE"].Value = cboOrderDateE.Text;
            
            //Grid1.DoFind();
            
            //lblItemCode.Text = string.Empty;
            //lblLotNo.Text = string.Empty;
            //lblRemark.Text = string.Empty;
            //lblPType.Text = string.Empty;
            //lblOrderType.Text = string.Empty;
        }


        private void SetGrid()
        {
            DBHelper helper = new DBHelper();
            DataSet dsTemp = new DataSet();

            string sStartDate = string.Empty;
            string sEndDate = string.Empty;

            try
            {
                sStartDate = dtpINP_STR_DATE.Value.ToString("yyyyMMdd");
                sEndDate = dtpINP_END_DATE.Value.ToString("yyyyMMdd");


                Grid1.HeaderFontSize = 13;
                Grid1.FontSize = 13;
                Grid1.CountRows = 11;
                Grid1.AutoScroll = true;
                Grid1.DisplayLayout.Scrollbars = Scrollbars.Both;
                btnRightPage.LinkMoveSize = Grid1.CountRows;
                btnLeftPage.LinkMoveSize = Grid1.CountRows;

                dsTemp = helper.FillDataSetN("SP_POP_WRK42_S01_V02", CommandType.StoredProcedure, 2
                                                                , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)     // 플랜트코드
                                                                //, helper.CreateParameter("P_LOC_CD", gsLOC_CD, DbType.String, ParameterDirection.Input)            // 로케이션코드
                                                                //, helper.CreateParameter("P_MACHINE", Common.MachineNo, DbType.String, ParameterDirection.Input)      // 공정호기 (PM2, PM3)
                                                                , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)      // 작업장코드(설비코드)
                                                                , helper.CreateParameter("P_STR_DATE", sStartDate, DbType.String, ParameterDirection.Input)      // 조회 시작
                                                                , helper.CreateParameter("P_END_DATE", sEndDate, DbType.String, ParameterDirection.Input)      // 조회 끝
                                                                , helper.CreateParameter("P_ORDER_NO", txtORDER_NO.Text, DbType.String, ParameterDirection.Input)      // 오더번호
                                                                , helper.CreateParameter("P_IND_BCD", txtIND_BCD.Text, DbType.String, ParameterDirection.Input)      // 개별바코드
                                                                , helper.CreateParameter("P_PCODE", txtPCODE.Text, DbType.String, ParameterDirection.Input)      // 지종
                                                                , helper.CreateParameter("P_BS_WGT", txtBS_WGT.Text, DbType.String, ParameterDirection.Input)      // 평량
                                                                , helper.CreateParameter("P_WLEN", txtWLEN.Text.ToString(), DbType.String, ParameterDirection.Input)      // 가로길이
                                                                , helper.CreateParameter("P_VLEN", txtVLEN.Text.ToString(), DbType.String, ParameterDirection.Input)      // 세로길이
                                                               );

                //그리드 출력
                Grid1.DoFind_Oracle(dsTemp);
            }
            catch (Exception ex)
            {
                SetMessage("SetGrid Error!");
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                LogFile.WriteLog("POP_WRK42.SetGrid Error => " + ex.Message);
            }
        }


        private void doCancel()
        {
            if (Grid1.Rows.Count < 1)
            {
                new POPUP.MessageForm("투입된 정보가 없습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return;
            }

            if (Grid1.Row == null)
            {
                new POPUP.MessageForm("선택된 투입 정보가 없습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return;
            }

            string sIND_BCD = Grid1.Row.Cells["IND_BCD"].Value.ToString();

            if  ( !(sIND_BCD.Length == 15 || sIND_BCD.Length == 10) )
            {
                new POPUP.MessageForm("개별바코드 형식이 틀립니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return;
            }

            if (new POPUP.MessageForm(string.Format("선택된 개별바코드 \"{0}\"를\r\n[{1}]에 투입 취소 하시겠습니까?", sIND_BCD, Common.MachineName), MessageBoxButtons.OKCancel, "알   림").ShowDialog(this) == DialogResult.Cancel)
            {
                return;
            }

            DBHelper helper = new DBHelper(false);
            try
            {
                // 2022.10.25 한동규 밀롤에서 공정투입취소할경우 작업지시 초기화
                if (Common.OpCode == "MA")
                {
                    // 밀롤 투입정보 취소
                    helper.ExecuteNoneQuery("SP_POP_WRK01_I02_MA", CommandType.StoredProcedure
                        , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)          // 플랜트
                        , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)      // 작업장코드(설비코드)
                        , helper.CreateParameter("P_IND_BCD", sIND_BCD, DbType.Double, ParameterDirection.Input)                // 개별바코드
                        , helper.CreateParameter("P_STOR_LOC_CD", gsLOC_CD, DbType.String, ParameterDirection.Input)            // 저장위치 재단 WCS 사용하기위해서 추가
                        , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input)            // 사용자ID
                        );

                }
                else
                {
                    // 투입정보 취소
                    helper.ExecuteNoneQuery("SP_POP_WRK01_I02", CommandType.StoredProcedure
                        , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)          // 플랜트
                        , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)      // 작업장코드(설비코드)
                        , helper.CreateParameter("P_IND_BCD", sIND_BCD, DbType.Double, ParameterDirection.Input)                // 개별바코드
                        , helper.CreateParameter("P_STOR_LOC_CD", gsLOC_CD, DbType.String, ParameterDirection.Input)            // 저장위치 재단 WCS 사용하기위해서 추가
                        , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input)            // 사용자ID
                        );
                }

                if (helper.RSCODE == "E")
                {
                    new POPUP.MessageForm(helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                }
                else
                {
                    new POPUP.MessageForm("공정투입 취소가 정상적으로 완료되었습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    gsRESULT = "OK";
                }

                SetGrid();
            }
            catch (Exception ex)
            {
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                LogFile.WriteLog("POP_WRK42.doCancel Error => " + ex.Message);
            }
            finally
            {
                helper.Close();
            }
        }

        private void btnFind_Click(object sender, EventArgs e)
        {
            SetGrid();
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
                    case "Cancel":  //공정투입 취소
                        doCancel();
                        break;

                    case "Close": //이전화면
                        if (gsRESULT == "OK")
                            this.DialogResult = DialogResult.OK;
                        else
                            this.DialogResult = DialogResult.Cancel;

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
                LogFile.WriteLog("POP_WRK42.bBox1_buttonClickEvent Error => " + ex.Message);
            }
            finally
            {

            }
        }

        private void cboOrderDate_ValueChanged(object sender, EventArgs e)
        {
                DoFind();
        }

        private void Grid1_ClickCellButton(object sender, MESGrid.GridClickEventArg e)
        {
            if (e.column.ToString() == "SEL")
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

                e.row.Update();
            }
            else if (e.column.ToString() == "DBTN") // 상세보기
            {
                string sWrkOrder = e.row.Cells["WRK_ORDR_NO"].Value.ToString();
                string sWrkOrderSeq = e.row.Cells["WRK_ORDR_SEQNO"].Value.ToString();
                string sIND_BCD = e.row.Cells["IND_BCD"].Value.ToString();

                POP_WRK84 popWrk84 = new POP_WRK84(POP_WRK84.PROC_INP_PRFM, Common.PlantCode, Common.OpCode, sWrkOrder, sWrkOrderSeq, sIND_BCD);  // 작업지시 정보
                popWrk84.LabelTitle = "공정투입 상세보기";

                ShowDialogForm(popWrk84);
            }
        }
        #endregion

        private void butWorkDate_Click(object sender, EventArgs e)
        {
            Button btnTemp = (Button)sender;

            DateTime dt = DateTime.Today;
            if (btnTemp.Tag.ToString() == "startDate")
            {
                dt = dtpINP_STR_DATE.Value;
            }
            else
            {
                dt = dtpINP_END_DATE.Value;
            }

            DAResultDate pop = new DAResultDate(dt);
            pop.ShowDialog(this);
            if (pop.DialogResult == DialogResult.OK)
            {
                string strDate = pop.ResultString.ToString();
                if (btnTemp.Tag.ToString() == "startDate")
                {
                    dtpINP_STR_DATE.Value = DateTime.Parse(strDate);
                }
                else
                {
                    dtpINP_END_DATE.Value = DateTime.Parse(strDate);
                }
                SetGrid();
            }
        }


    }
}
