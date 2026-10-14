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
    public partial class POP_WRK54 : BaseForm
    {
        #region < MEMBER AREA >
        private string sStartTime = string.Empty;

        private SAMMI.Common _common = new SAMMI.Common();

        public static string userID = string.Empty;
        public static string userName = string.Empty;

        string sMenuType = string.Empty;

        #endregion

        #region < CONSTRUCTOR >

        public POP_WRK54()
        {
            InitializeComponent();

            Common.SetMessageList();

            sMenuType = "Common";
        }

        public POP_WRK54(string MenuType)
        {
            InitializeComponent();

            Common.SetMessageList();

            sMenuType = MenuType;
        }
        #endregion

        #region < POP_WRK54_Load >
        private void POP_WRK54_Load(object sender, EventArgs e)
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

                this.lblTitle.Text = "실적 현황";

                DateTime daysBefore = DateTime.Now;
                //daysBefore = daysBefore.AddDays(-7);
                dtpWorkDate.Value = daysBefore;

                SetMenuButtons();
                SetGrid();
            }
            catch (Exception ex)
            {
                SetMessage("POP_WRK54_Load_ Error!");
                LogFile.WriteLog("POP_WRK54.POP_WRK54_Load Error\r\n" + ex.Message);
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


                bBox1[0, 0].Text = "라벨\n재발행";
                bBox1[0, 0].Tag = "Print";
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
                LogFile.WriteLog("POP_WRK54.SetButtons Error\r\n" + ex.Message);
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

                dsTemp = helper.FillDataSetN("SP_POP_WRK54_S01", CommandType.StoredProcedure, 2
                                                               , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)
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
                LogFile.WriteLog("POP_WRK39.SetGrid Error\r\n" + ex.Message);
            }
        }

        private void doPrint()
        {
            //조회결과 입력용 Row생성
            REPORT_ITEM HLitem = new REPORT_ITEM();

            if (Grid1.Rows.Count == 0)
            {
                new POPUP.MessageForm("조회된 실적 정보가 없습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return;
            }

            for (int i = 0; i < Grid1.Rows.Count; i++)
            {
                if (Grid1.Rows[i].Cells["CHK"].Value.ToString().Equals("V"))
                {
                    HLitem.MACH_NM = Grid1.Rows[i].Cells["MACH_NM"].Value.ToString();          // 설비호기 명
                    HLitem.LOT_NO = Grid1.Rows[i].Cells["LOT_NO"].Value.ToString();            // LOT NO
                    HLitem.SPEC = Grid1.Rows[i].Cells["MATNR_NM"].Value.ToString();               // 제품규격(품명)
                    HLitem.PRFM_ROLLCNT = Grid1.Rows[i].Cells["ROLLCNT"].Value.ToString();     // 길이
                    HLitem.BS_WGT = Grid1.Rows[i].Cells["BS_WGT"].Value.ToString();            // 편량
                    HLitem.PRFM_WGT = Grid1.Rows[i].Cells["PRFM_WGT"].Value.ToString();        // 중량
                    HLitem.COLOR = Grid1.Rows[i].Cells["COLOR"].Value.ToString();              // 색
                    HLitem.WRK_NAME = Grid1.Rows[i].Cells["WRK_NAME"].Value.ToString();        // 작업자
                    HLitem.QCJUD = Grid1.Rows[i].Cells["QCJUD"].Value.ToString();              // 판정
                    HLitem.IND_BCD = Grid1.Rows[i].Cells["IND_BCD"].Value.ToString();          // 바코드

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
                    case "Print":  //라벨재발행
                        doPrint();
                        break;
                    case "Delete":  //실적취소

                        break;
                    case "Remark":  //비고수정

                        break;
                    case "Union":  //라벨병합

                        break;
                    case "UnUnion":  //라벨병합취소

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
                LogFile.WriteLog("POP_WRK54.bBox1_buttonClickEvent Error\r\n" + ex.Message);
            }
            finally
            {

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

                if (sStatus_Pre == "V")
                {
                    e.row.Cells["CHK"].Value = "-";
                }
                else
                {
                    e.row.Cells["CHK"].Value = "V";
                }
            }
        }

        private void butWorkDate_Click(object sender, EventArgs e)
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

        private void dtpDate_DropDown(object sender, EventArgs e)
        {
            CommonCalendar.CloseCalendar((DateTimePicker)sender);
        }

        #endregion
    }
}
