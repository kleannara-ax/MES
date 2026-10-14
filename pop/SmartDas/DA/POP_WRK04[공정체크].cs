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

using Oracle.ManagedDataAccess.Client;
#endregion

namespace SmartDas
{
    public partial class POP_WRK04 : BaseForm
    {
        #region < MEMBER AREA >
        private string sStartTime = string.Empty;
        private int iMTDSEQ = -1;
        private int iMaxSeq = 1;
        private string sSeqList = string.Empty;

        private SAMMI.Common _common = new SAMMI.Common();

        #endregion

        #region < CONSTRUCTOR >

        public POP_WRK04()
        {
            InitializeComponent();

            Common.SetMessageList();

        }
        #endregion

        #region < POP_WRK04_Load >
        private void POP_WRK04_Load(object sender, EventArgs e)
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

                this.lblTitle.Text = "공정체크";

                DateTime daysBefore = DateTime.Now;
                //daysBefore = daysBefore.AddDays(-7);
                dtpCheckDate.Value = daysBefore;

                SetMenuButtons();
                SetGrid();
            }
            catch (Exception ex)
            {
                SetMessage("POP_WRK04_Load_ Error!");
                LogFile.WriteLog("POP_WRK04.POP_WRK04_Load Error => " + ex.Message);
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
                bBox1[0, 1].Text = "초기화";
                bBox1[0, 1].Tag = "Init";
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
                LogFile.WriteLog("POP_WRK04.SetButtons Error => " + ex.Message);
            }
        }

        private void SetGrid()
        {
            DBHelper helper = new DBHelper();
            DataSet dsTemp = new DataSet();
            string sCheckDate = string.Empty;

            try
            {
                sCheckDate = dtpCheckDate.Value.ToString("yyyyMMdd");

                Grid1.HeaderFontSize = 13;
                Grid1.FontSize = 13;
                Grid1.CountRows = 10;
                Grid1.AutoScroll = true;
                Grid1.DisplayLayout.Scrollbars = Scrollbars.Automatic;
                btnRightPage.LinkMoveSize = Grid1.CountRows;
                btnLeftPage.LinkMoveSize = Grid1.CountRows;

                dsTemp = helper.FillDataSetN("SP_POP_WRK04_S01", CommandType.StoredProcedure, 2
                                                               , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_WRK_DT", sCheckDate, DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_CHKSEQ", DbType.String, ParameterDirection.Output, null, 4000)
                                                               , helper.CreateParameter("P_CHKLIST", DbType.String, ParameterDirection.Output, null, 4000)
                                                               );
                //그리드 출력
                Grid1.DoFind_Oracle(dsTemp);

                //검사결과 등록차수조회
                lblCheckSeq.Text = helper.Parameters["P_CHKSEQ"].Value.ToString();
                sSeqList = helper.Parameters["P_CHKLIST"].Value.ToString();
                lblCheckTime.Text = string.Empty;
                iMTDSEQ = -1;
                iMaxSeq = int.TryParse(helper.Parameters["P_CHKSEQ"].Value.ToString(), out iMaxSeq) ? iMaxSeq : 1;
            }
            catch (Exception ex)
            {
                SetMessage("SetGrid Error!");
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                LogFile.WriteLog("POP_WRK04.SetGrid Error => " + ex.Message);
            }
        }

        private void doConfirm()
        {
            DBHelper helper = new DBHelper(false);
            POPUP.MessageForm msgForm = null;
            DialogResult res = DialogResult.Cancel;

            string sWrkList;
            DataTable dtRtnList;
            int iErrChk = 0;
            int iSeqTime = 0;

            if (Grid1.Rows.Count < 1)
            {
                SetMessage("공정검사 데이터가 없습니다.");
                new POPUP.MessageForm("공정검사 데이터가 없습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return;
            }
            //현재 차수 확인
            if (sSeqList.Contains(lblCheckSeq.Text))
            {
                new POPUP.MessageForm("이미 등록된 검사차수 입니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return;
            }
            //미입력항목 확인
            if (string.IsNullOrEmpty(lblCheckSeq.Text))
                iSeqTime = 1;
            if (string.IsNullOrEmpty(lblCheckTime.Text))
                iSeqTime = iSeqTime + 2;
            //미입력 확인 메세지 지정
            if(iSeqTime == 1)
                msgForm = new POPUP.MessageForm("검사차수를 확인하여 주시기 바랍니다.", MessageBoxButtons.OK, "알   림");
            else if (iSeqTime == 2)
                msgForm = new POPUP.MessageForm("검사시간을 확인하여 주시기 바랍니다.", MessageBoxButtons.OK, "알   림");
            else if (iSeqTime == 3)
                msgForm = new POPUP.MessageForm("검사차수 및 검사시간을 확인하여 주시기 바랍니다.", MessageBoxButtons.OK, "알   림");
            //메세지 출력
            if (iSeqTime > 0)
            {
                res = msgForm.ShowDialog(this);
                return;
            }
            
            try
            {
                //기존 그리드 양식 복사
                dtRtnList = ((DataTable)Grid1.DataSource);
                //선택 및 수량이 입력된 반납요청 목록 작성
                for (int i = 0; i < dtRtnList.Rows.Count; i++)
                {
                    // 1:미확인, 2:불합격, 3:미확인 + 불합격
                    if (string.IsNullOrEmpty(dtRtnList.Rows[i]["RESULT"].ToString()))
                        if (iErrChk != 1) 
                            iErrChk = iErrChk + 1;
                    if (dtRtnList.Rows[i]["RESULT"].Equals("N"))
                        if (iErrChk < 2)
                            iErrChk = iErrChk + 2;
                }
                //문제 데이터가 있는 경우 메세지 출력
                if (iErrChk > 0)
                {
                    if(iErrChk ==1)
                        msgForm = new POPUP.MessageForm("미확인 항목이 존재합니다.\n 진행하시겠습니까?.", MessageBoxButtons.OKCancel, "알   림");
                    else if (iErrChk == 2)
                        msgForm = new POPUP.MessageForm("불합격 항목이 존재합니다.\n 진행하시겠습니까?.", MessageBoxButtons.OKCancel, "알   림");
                    else
                        msgForm = new POPUP.MessageForm("미확인 및 불합격 항목이 존재합니다.\n 진행하시겠습니까?.", MessageBoxButtons.OKCancel, "알   림");

                    //메세지 출력
                    res = msgForm.ShowDialog(this);
                    //진행 선택시 OK처리
                    if (res == DialogResult.OK)
                        iErrChk = 0;
                }
                //OK 처리시 등록진행
                if (iErrChk == 0)
                {
                    //자재목록 테이블 JSON으로 변환
                    sWrkList = Common.toJsonFormat("POP_WRK04", dtRtnList);

                    helper.ExecuteNoneQuery("SP_POP_WRK04_I01", CommandType.StoredProcedure
                                                              , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)
                                                              , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)
                                                              , helper.CreateParameter("P_IOTYPE", Common.IOType, DbType.String, ParameterDirection.Input)
                                                              , helper.CreateParameter("P_PROC_CD", "", DbType.String, ParameterDirection.Input)
                                                              , helper.CreateParameter("P_CHK_DT", dtpCheckDate.Value.ToString("yyyyMMdd"), DbType.String, ParameterDirection.Input)
                                                              , helper.CreateParameter("P_CHK_SEQ", lblCheckSeq.Text, DbType.String, ParameterDirection.Input)
                                                              , helper.CreateParameter("P_CHK_TM", lblCheckTime.Text.Replace(":",""), DbType.String, ParameterDirection.Input)
                                                              , helper.CreateParameterOracle("P_WRK_LIST", sWrkList, OracleDbType.Clob, ParameterDirection.Input)
                                                              , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input)
                               );

                    if (helper.RSCODE == "E")
                    {
                        new POPUP.MessageForm(helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                        return;
                    }

                    new POPUP.MessageForm("공정검사가 정상적으로 완료되었습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    SetGrid();
                }
            }
            catch (Exception ex)
            {
                LogFile.WriteLog("POP_WRK04.doConfirm Error => " + ex.Message);
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
            }
            finally
            {
                helper.Close();
            }
        }

        private void doJudgment(int pRow)
        {
            string sInpType = Grid1.Rows[pRow].Cells["INPT_TYP"].Value.ToString();
            string sStdTemp;
            string sStdVal = Grid1.Rows[pRow].Cells["STD_VAL"].Value.ToString();
            double dLowVAL;
            double dUppVAL;
            double dInpVAL;
            bool bJudFlag = false;

            //수치입력
            if (sInpType.Equals("N"))
            {
                //하한값
                sStdTemp = Grid1.Rows[pRow].Cells["LOW_VAL"].Value.ToString().Replace(",", "");
                if (!double.TryParse(sStdTemp, out dLowVAL))
                    dLowVAL = 0.0;
                //상한값
                sStdTemp = Grid1.Rows[pRow].Cells["UPP_VAL"].Value.ToString().Replace(",", "");
                if (!double.TryParse(sStdTemp, out dUppVAL))
                    dUppVAL = 0.0;
                //입력값
                sStdTemp = Grid1.Rows[pRow].Cells["RES_VAL"].Value.ToString().Replace(",", "");
                if (!double.TryParse(sStdTemp, out dInpVAL))
                    dInpVAL = -1;
                //판정
                if (dLowVAL <= dInpVAL && dUppVAL >= dInpVAL)
                    bJudFlag = true;
                else
                    bJudFlag = false;
            }
            else if (sInpType.Equals("S"))
            {
                //입력값
                sStdTemp = Grid1.Rows[pRow].Cells["RES_VAL"].Value.ToString();
                //판정
                if (string.IsNullOrEmpty(sStdTemp))
                    bJudFlag = false;
                else
                    bJudFlag = true;
            }
            //결과 선택
            else
            {
                //입력값
                sStdTemp = Grid1.Rows[pRow].Cells["RES_VAL"].Value.ToString().Replace(",", "");
                //판정
                if (sStdTemp.Equals(sStdVal))
                    bJudFlag = true;
                else
                    bJudFlag = false;
            }

            //판정결과 처리
            if (bJudFlag)
            {
                Grid1.Rows[pRow].Cells["RESULT"].Value = "Y";
                Grid1.Rows[pRow].Cells["RESULT_DESC"].Value = "합격";
                Grid1.Rows[pRow].Cells["RESULT_DESC"].Appearance.BackColor = Color.Lime;
            }
            else
            {
                Grid1.Rows[pRow].Cells["RESULT"].Value = "N";
                Grid1.Rows[pRow].Cells["RESULT_DESC"].Value = "불합격";
                Grid1.Rows[pRow].Cells["RESULT_DESC"].Appearance.BackColor = Color.Tomato;
            }
        }

        private void ReadLog()
        {
            DBHelper helper = new DBHelper();
            DataTable dtTemp = new DataTable();
            DataColumn[] dtKey = new DataColumn[1];
            DataRow drTemp;
            string sCheckDate = string.Empty;
            string sCheckSeq = string.Empty;

            try
            {
                sCheckDate = dtpCheckDate.Value.ToString("yyyyMMdd");
                sCheckSeq = lblCheckSeq.Text;
                //등록된 검사이력 조회
                dtTemp = helper.FillTable("SP_POP_WRK04_S02", CommandType.StoredProcedure
                                                               , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_CHK_DT", sCheckDate, DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_CHKSEQ", sCheckSeq, DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input)
                                                               );
                if (dtTemp.Rows.Count == 0)
                {
                    //조회된 이력이 없는 경우 목록 초기화
                    doInit();
                    return;
                }
                //조호된 테이블 키정보 설정
                dtKey[0] = dtTemp.Columns["CHK_ITEM_CD"];
                dtTemp.PrimaryKey = dtKey;
                //검사시간 출력
                lblCheckTime.Text = dtTemp.Rows[0]["CHK_TM"].ToString();
                //각 검사항목별 검사결과 출력
                for(int i=0;i<Grid1.Rows.Count;i++)
                {
                    //검사항목에 따른 결과 조회
                    drTemp = dtTemp.Rows.Find(Grid1.Rows[i].Cells["ITEM_CD"].Value.ToString());
                    if(Grid1.Rows[i].Cells["ITEM_CD"].Value.ToString().Equals(drTemp["CHK_ITEM_CD"].ToString()))
                    {
                        Grid1.Rows[i].Cells["RES_VAL"].Value = drTemp["RST_VAL"].ToString();
                        doJudgment(i);
                    }
                }
            }
            catch (Exception ex)
            {
                SetMessage("SetGrid Error!");
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                LogFile.WriteLog("POP_WRK04.SetGrid Error => " + ex.Message);
            }
        }

        private void doInit()
        {
            //입력정보 초기화
            lblCheckTime.Text = string.Empty;
            for (int i = 0; i < Grid1.Rows.Count; i++)
            {
                Grid1.Rows[i].Cells["RES_VAL"].Value = string.Empty;
                Grid1.Rows[i].Cells["RESULT"].Value = string.Empty;
                Grid1.Rows[i].Cells["RESULT_DESC"].Value = string.Empty;
                Grid1.Rows[i].Cells["RESULT_DESC"].Appearance.BackColor = Color.White;
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
                    case "Confirm":  //작업지시 선택
                        doConfirm();
                        break;
                    case "Init":  //초기화
                        doInit();
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
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                LogFile.WriteLog("POP_WRK04.bBox1_buttonClickEvent Error => " + ex.Message);
            }
            finally
            {

            }
        }

        private void cboOrderDate_ValueChanged(object sender, EventArgs e)
        {
            SetGrid();
        }

        private void Grid1_ClickCellButton(object sender, MESGrid.GridClickEventArg e)
        {
            double dDimension = 0;
            string sFormat = string.Empty;
            string[] sResList;

            if (e.column.ToString() == "RES_VAL")
            {
                //기존값 확인
                string sStatus_Pre = e.row.Cells["RES_VAL"].Value.ToString();

                if (e.row.Cells["INPT_TYP"].Value.ToString().Equals("N"))
                {
                    //수치값 입력
                    sFormat = e.row.Cells["INPT_MTD_DESC"].Value.ToString().Replace("9", "0");

                    DAResultNum pop = new DAResultNum();
                    pop.LabelTitle = "검사결과 입력";
                    pop.LabelHeader = "결과";
                    pop.ContentMaxLength = 8;

                    pop.ShowDialog(this);

                    if (pop.DialogResult == DialogResult.OK)
                    {
                        dDimension = pop.ResultDouble;
                        e.row.Cells["RES_VAL"].Value = string.Format("{0:" + sFormat + "#}", dDimension);
                    }
                }
                else if (e.row.Cells["INPT_TYP"].Value.ToString().Equals("S"))
                {
                    //문자열 입력
                    DAResultText pop = new DAResultText("공정검사 결과입력", e.row.Cells["RES_VAL"].Value.ToString());
                    pop.ShowDialog(this);
                    if (pop.DialogResult == DialogResult.OK)
                    {
                        e.row.Cells["RES_VAL"].Value = pop.ResultString;
                    }
                }
                else
                {
                    //결과 목록 설정
                    sResList = e.row.Cells["INPT_MTD_DESC"].Value.ToString().Split('/');
                    //결과정보 선택
                    if (sResList[sResList.Length - 1].Equals(sStatus_Pre))
                        iMTDSEQ = 0;
                    else
                        iMTDSEQ++;
                    //결과정보 출력
                    e.row.Cells["RES_VAL"].Value = sResList[iMTDSEQ];

                }
                //결과 판정
                doJudgment(e.cell.Row.Index);
            }

        }

        private void btnCheckDate_Click(object sender, EventArgs e)
        {
            Button btnTemp = (Button)sender;

            DAResultDate pop = new DAResultDate(dtpCheckDate.Value);
            pop.ShowDialog(this);
            if (pop.DialogResult == DialogResult.OK)
            {
                string strDate = pop.ResultString.ToString();
                dtpCheckDate.Value = DateTime.Parse(strDate);
            }
        }

        private void bCheckSeq_Up_Click(object sender, EventArgs e)
        {
            int iSeq;//순번

            //기존순번 변경
            if (int.TryParse(lblCheckSeq.Text, out iSeq))
            {
                iSeq++;
                //lblCheckSeq.Text = (iSeq + 1).ToString();
                lblCheckSeq.Text = (iSeq > iMaxSeq ? iMaxSeq : iSeq).ToString();
            }
            //기존 순번의 확인이 불가능한 경우 초기화
            else
                lblCheckSeq.Text = "1";
            ReadLog();
        }

        private void bCheckSeq_Down_Click(object sender, EventArgs e)
        {
            int iSeq;//순번

            //기존순번 변경
            if (int.TryParse(lblCheckSeq.Text, out iSeq))
            {
                //0 이하로 내려가는 경우 1로 고정
                iSeq--;
                lblCheckSeq.Text = (iSeq < 1 ? 1 : iSeq).ToString();
            }
            //기존 순번의 확인이 불가능한 경우 초기화
            else
                lblCheckSeq.Text = "1";
            ReadLog();
        }

        private void lblCheckTime_Click(object sender, EventArgs e)
        {
            MESLabel lblTemp = (MESLabel)sender;
            DAResultTime pop = new DAResultTime();
            pop.ShowDialog(this);
            if (pop.DialogResult == DialogResult.OK)
            {
                lblCheckTime.Text = pop.ResultString.ToString();
            }
        }

        #endregion

        
    }
}
