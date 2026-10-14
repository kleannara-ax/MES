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
    public partial class POP_WRK_LAMI_003 : BaseForm
    {
        #region < MEMBER AREA >
        private string sOPCode = string.Empty;
        private string sIOType = string.Empty;

        private SAMMI.Common _common = new SAMMI.Common();

        //private bool gbPacking = false;
        //Label lblSALES_ORDR;
        //TextBox txtSALES_ORDR;


        #endregion

        #region < CONSTRUCTOR >
        /*
        public POP_WRK_LAMI_003()
        {
            InitializeComponent();

            Common.SetMessageList();

            sOPCode = Common.OpCode;
            sIOType = Common.IOType;
        }
*/
        public POP_WRK_LAMI_003(string OPCode, string IOType)
        {
            InitializeComponent();

            Common.SetMessageList();

            sOPCode = OPCode;
            sIOType = IOType;

            //            gbPacking = false;

            if (Common.PlantCode.Equals("P100"))
            {
                //제지공통(지종, 평량, 가로, 세로 검색조건 활성화)
                lblPW.Visible = true;
                txtPCODE.Visible = true;
                txtWEIGHT.Visible = true;


                if (Common.OpCode.Equals("JA") == false)
                {
                    lblREQ_DATE.Text = "투입일시";
                }



                if (Common.OpCode.Equals("JA") || Common.OpCode.Equals("MA") || Common.OpCode.Equals("CA"))
                {
                    //lblWV.Visible = true;
                    //txtWLEN.Visible = true;
                    //txtVLEN.Visible = true;
                }
                else
                {
                    lblWV.Visible = true;
                    txtWLEN.Visible = true;
                    txtVLEN.Visible = true;
                    /*
                                        // 포장인경우만 gbPacking 을 true로 처리
                                        if (Common.OpCode.Equals("PB") || Common.OpCode.Equals("PC") || Common.OpCode.Equals("PD"))
                                        {
                                            gbPacking = true;

                                            lblSALES_ORDR = lblMATNR;
                                            txtSALES_ORDR = txtMATNR;

                                            lblSALES_ORDR.Text = "판매오더";
                                        }
                    */
                }
            }
        }
        #endregion

        #region < POP_WRK_LAMI_003_Load >
        private void POP_WRK_LAMI_003_Load(object sender, EventArgs e)
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

                this.lblTitle.Text = "지시 선택";

                //조회기간 초기설정
                DateTime daysBefore = DateTime.Now;
                daysBefore = daysBefore.AddDays(-3);
                dtpREQ_STR_DATE.Value = daysBefore;
                dtpREQ_END_DATE.Value = DateTime.Now.AddDays(1);

                txtPCODE.Text = Common.ORD_PCODE;
                txtWEIGHT.Text = Common.ORD_WEIGHT == 0 ? "" : Convert.ToString(Common.ORD_WEIGHT);
                txtWLEN.Text = Common.ORD_WLEN == 0 ? "" : Convert.ToString(Common.ORD_WLEN);
                txtVLEN.Text = Common.ORD_VLEN == 0 ? "" : Convert.ToString(Common.ORD_VLEN);

                SetMenuButtons();
                SetGrid();
                DoFind();
            }
            catch (Exception ex)
            {
                SetMessage("POP_WRK_LAMI_003_Load_ Error!");
                LogFile.WriteLog("POP_WRK_LAMI_003.POP_WRK_LAMI_003_Load Error => " + ex.Message);
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

                bBox1[0, 0].Text = "작업지시 선택";
                bBox1[0, 0].Tag = "Order";
                bBox1[0, 0].MappingButton.FontSize = 14;

                bBox1[0, 10].Text = "닫기";
                bBox1[0, 10].Tag = "Close";
                bBox1[0, 10].MappingButton.FontSize = 14;

                bBox1.RedrawButtons();
            }
            catch (Exception ex)
            {
                SetMessage("SetButtons Error!");
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                LogFile.WriteLog("POP_WRK_LAMI_003.SetButtons Error => " + ex.Message);
            }
        }

        private void DoFind()
        {

        }

        #region SET_GRID
        private void SetGrid_PS()
        {
            DBHelper helper = new DBHelper();
            //변수
            string sStartDate = string.Empty;
            string sEndDate = string.Empty;
            string sPCode = string.Empty; //지종
            string sWeight = string.Empty; //평량
            string sMatNR = string.Empty; //자재코드
            string sColInfo = string.Empty; //컬럼 헤더
            string sColType = string.Empty; //컬럼 타입
            //반환테이블
            DataSet dsTemp = new DataSet();

            try
            {
                //변수설정
                sStartDate = dtpREQ_STR_DATE.Value.ToString("yyyyMMdd");
                sEndDate = dtpREQ_END_DATE.Value.ToString("yyyyMMdd");
                sPCode = txtPCODE.Text; //지종
                sWeight = txtWEIGHT.Text; //평량

                sMatNR = txtMATNR.Text; //자재코드
                //그리드 설정
                Grid1.HeaderFontSize = 13;
                Grid1.FontSize = 13;
                Grid1.CountRows = 11;
                Grid1.AutoScroll = true;
                Grid1.DisplayLayout.Scrollbars = Scrollbars.Automatic;
                btnRightPage.LinkMoveSize = Grid1.CountRows;
                btnLeftPage.LinkMoveSize = Grid1.CountRows;

                Common.ORD_PCODE = txtPCODE.Text.ToString();
                Common.ORD_WEIGHT = txtWEIGHT.Text.ToString() == "" ? 0 : Convert.ToInt32(txtWEIGHT.Text.ToString());
                Common.ORD_WLEN = txtWLEN.Text.ToString() == "" ? 0 : Convert.ToInt32(txtWLEN.Text.ToString());
                Common.ORD_VLEN = txtVLEN.Text.ToString() == "" ? 0 : Convert.ToInt32(txtVLEN.Text.ToString());

                //PS 작업지시 (SP_POP_LAMI_P01)
                dsTemp = helper.FillDataSetN("SP_POP_LAMI_P01", CommandType.StoredProcedure, 2
                                                               , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_PROC_CD", Common.OpCode, DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_IOTYPE", Common.IOType, DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_MACHINE", Common.MachineNo, DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_PRD_STR_DATE", sStartDate, DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_PRD_END_DATE", sEndDate, DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_PCODE", txtPCODE.Text.ToString(), DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_WEIGHT", txtWEIGHT.Text.ToString(), DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_MATNR", txtMATNR.Text.ToString(), DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_WLEN", txtWLEN.Text.ToString(), DbType.String, ParameterDirection.Input)     // 가로
                                                               , helper.CreateParameter("P_VLEN", txtVLEN.Text.ToString(), DbType.String, ParameterDirection.Input)     // 세로
                                                               , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input));
                if (dsTemp.Tables[1].Rows.Count < 1)
                {
                    SetMessage("조회된 작업지시가 없습니다.");
                    //new POPUP.MessageForm("조회된 작업지시가 없습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                }
                //그리드 출력
                Grid1.DoFind_Oracle(dsTemp);

                // 첫번째열 고정
                Grid1.DisplayLayout.UseFixedHeaders = true;
                Grid1.DisplayLayout.Bands[0].Columns["CHK"].Header.Fixed = true;
                Grid1.DisplayLayout.Bands[0].Override.FixedHeaderIndicator = FixedHeaderIndicator.None;
            }
            catch (Exception ex)
            {
                SetMessage("SetGrid Error!");
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                LogFile.WriteLog("POP_WRK_LAMI_003.SetGrid Error => " + ex.Message);
            }
        }

        private void SetGrid()
        {
            if (Common.PlantCode.Equals("P100"))
            {
                SetGrid_PS();
            }
        }
        #endregion

        private DataTable setReqList()
        {
            DataTable dtRtn = new DataTable();
            DataRow dtTempRow;
            DataTable WrkOrderList = (DataTable)Grid1.DataSource;

            //테이블 양식 작성
            dtRtn.Columns.Add(new DataColumn("WRK_ORDR_NO", typeof(string)));       //작업지시
            dtRtn.Columns.Add(new DataColumn("WRK_ORDR_SEQNO", typeof(string)));    //작업지시 순번
            dtRtn.Columns.Add(new DataColumn("MATNR", typeof(string)));             //자재코드
            dtRtn.Columns.Add(new DataColumn("ORDER_QTY", typeof(string)));         //지시수량
            dtRtn.Columns.Add(new DataColumn("UNIT", typeof(string)));              //단위

            for (int i = 0; i < WrkOrderList.Rows.Count; i++)
            {
                //선택된 행처리
                if (WrkOrderList.Rows[i]["CHK"].ToString().Equals("V"))
                {
                    //조회결과 입력용 Row생성
                    dtTempRow = dtRtn.NewRow();
                    dtTempRow["WRK_ORDR_NO"] = WrkOrderList.Rows[i]["WRK_ORDR_NO"].ToString();
                    dtTempRow["WRK_ORDR_SEQNO"] = WrkOrderList.Rows[i]["WRK_ORDR_SEQNO"].ToString();
                    dtTempRow["MATNR"] = WrkOrderList.Rows[i]["MATNR"].ToString();
                    dtTempRow["ORDER_QTY"] = WrkOrderList.Rows[i]["WRK_ORDR_QTY"].ToString();
                    dtTempRow["UNIT"] = WrkOrderList.Rows[i]["UNIT"].ToString();
                    //결과 테이블에 저장
                    dtRtn.Rows.Add(dtTempRow);
                }
            }
            return dtRtn;
        }

        // 작업지시 선택 (제지 밀롤/재단/포장/슬리터/수재단)
        private bool doOrderSelect(string sWrkOrder, string sWrkOrderSeq, string sOrderNo, string sMATNR, string sLotNo)
        {
            bool bRetCode = false;
            DBHelper helper = new DBHelper(false);
            string sMSG = string.Empty;

            if (string.IsNullOrEmpty(sWrkOrder))    // 예외생산의 경우 sWrkOrder가 null로 표시됨 그래서 추가 함.
            {
                if (new POPUP.MessageForm(string.Format("오더번호 \"{0}\"로 선택 하시겠습니까?", sOrderNo), MessageBoxButtons.OKCancel, "알   림").ShowDialog(this) == DialogResult.Cancel)
                {
                    return false;
                }
            }
            else if (new POPUP.MessageForm(string.Format("작업지시 \"{0}-{1}\"로 선택 하시겠습니까?", sWrkOrder, sWrkOrderSeq), MessageBoxButtons.OKCancel, "알   림").ShowDialog(this) == DialogResult.Cancel)
            {
                return false;
            }

            try
            {
                //작업시작/완료처리 (작업지시 상태변경 및 작업장 현황의 가동상태 변경)
                helper.ExecuteNoneQuery("SP_POP_WRK07_I01", CommandType.StoredProcedure
                         , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)
                         , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)
                         , helper.CreateParameter("P_WRK_ORDR_NO", sWrkOrder, DbType.String, ParameterDirection.Input)
                         , helper.CreateParameter("P_WRK_ORDR_SEQNO", sWrkOrderSeq, DbType.String, ParameterDirection.Input)
                         , helper.CreateParameter("P_ORDER_NO", sOrderNo, DbType.String, ParameterDirection.Input)
                         , helper.CreateParameter("P_MATNR", sMATNR, DbType.String, ParameterDirection.Input)
                         //, helper.CreateParameter("P_LOT_NO", sLotNo, DbType.String, ParameterDirection.Input)
                         , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input)
                         );
				Common.WrkOrderNo = sWrkOrder;
				Common.WrkOrderSeq = sWrkOrderSeq;		 

                if (helper.RSCODE == "E")
                {
                    new POPUP.MessageForm(helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    bRetCode = false;
                }
                else
                {
                    new POPUP.MessageForm("작업지시 선택 완료되었습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    bRetCode = true;
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

            return bRetCode;
        }

        private void dtpDate_DropDown(object sender, EventArgs e)
        {
            CommonCalendar.CloseCalendar((DateTimePicker)sender);
        }

        #endregion

        #region < EVNET >

        private void btnFind_Click(object sender, EventArgs e)
        {
            SetGrid();
        }

        private void bBox1_buttonClickEvent(MESButton sender, ButtonBox.ButtonClickEventArg e)
        {
            //팝업 변수
            POPUP.MessageForm msgForm = null;
            DialogResult res = DialogResult.Cancel;
            //요청문서목록
            DataTable dtReqList;
            int iCnt = 0;

            string sOrderNo = string.Empty; //생산오더번호
            string sWrkOrder = string.Empty; //작업지시번호
            string sWrkOrderSeq = string.Empty; //작업지시순번
            string sMATNR = string.Empty;
            string sLotNo = string.Empty;

            try
            {
                if (!this.bUseNetwork)
                {
                    SetMessage("네트워크 상태를 확인하시기 바랍니다.");
                    return;
                }

                MESButton btn = sender;

                DataTable dt = (DataTable)Grid1.DataSource;

                //체크된 항목 확인
                for (int i = 0; i < dt.Rows.Count; i++)
                {
                    //선택된 행처리
                    if (dt.Rows[i]["CHK"].ToString().Equals("V"))
                    {
                        iCnt++;
                        sOrderNo = dt.Rows[i]["ORDER_NO"].ToString();
                        sWrkOrder = dt.Rows[i]["WRK_ORDR_NO"].ToString();
                        sWrkOrderSeq = dt.Rows[i]["WRK_ORDR_SEQNO"].ToString();
                        sMATNR = dt.Rows[i]["MATNR"].ToString();

                        // 예외생산 작업지시 선택에 필요하여 추가
                        if (dt.Columns.Contains("LOT_NO"))
                        {
                            sLotNo = dt.Rows[i]["LOT_NO"].ToString();
                        }
                        else
                        {
                            sLotNo = "";
                        }

                        lblRemark.Text = dt.Rows[i]["ORDER_RMK"].ToString();
                    }
                }

                switch (btn.Tag.ToString())
                {
                    case "Order":  //작업지시 선택
                        if (iCnt == 0 && string.IsNullOrEmpty(sWrkOrder))
                        {
                            msgForm = new POPUP.MessageForm("작업지시를 선택하여 주시기 바랍니다.", MessageBoxButtons.OK, "알   림");
                            res = msgForm.ShowDialog(this);
                        }
                        else if (iCnt > 1)
                        {
                            msgForm = new POPUP.MessageForm("작업지시를 하나만 선택하여 주시기 바랍니다.", MessageBoxButtons.OK, "알   림");
                            res = msgForm.ShowDialog(this);
                        }
                        else if (Common.PlantCode.Equals("P100"))
                        {
                            // 점보롤 인경우는 작업지시 변경 팝업 호출
                            if (Common.OpCode.Equals("JA"))
                            {
                                POP_WRK40 WRK040 = new POP_WRK40(sWrkOrder, sWrkOrderSeq);
                                if (ShowDialogForm(WRK040) == DialogResult.OK)
                                {
                                    this.DialogResult = DialogResult.OK;
                                    this.Close();
                                }
                            }
                            else
                            {
                                if (doOrderSelect(sWrkOrder, sWrkOrderSeq, sOrderNo, sMATNR, sLotNo) == true)
                                {
                                    this.DialogResult = DialogResult.OK;
                                    this.Close();
                                }
                            }
                        }
                        else
                        {
                            // 예외생산의 경우 sWrkOrder 가 null로 표시됨 그래서 !string.IsNullOrEmpty(sWrkOrder) 추가함
                            if (!string.IsNullOrEmpty(sWrkOrder) && sWrkOrder.Equals(Common.WrkOrderNo) && sWrkOrderSeq.Equals(Common.WrkOrderSeq.ToString()))
                            {
                                if (Grid1.Rows.Count == 1)
                                {
                                    if (new POPUP.MessageForm("현재작업지시를 완료하시겠습니까?", MessageBoxButtons.OKCancel, "알   림").ShowDialog(this) == DialogResult.OK)
                                    {
                                        POP_WRK41 WRK041 = new POP_WRK41(sWrkOrder, sWrkOrderSeq, true);
                                        if (ShowDialogForm(WRK041) == DialogResult.OK)
                                        {
                                            this.DialogResult = DialogResult.OK;
                                            this.Close();
                                        }
                                    }
                                }
                                else
                                {
                                    msgForm = new POPUP.MessageForm("현재 선택된 작업지시 입니다.", MessageBoxButtons.OK, "알   림");
                                    res = msgForm.ShowDialog(this);
                                }
                            }
                            else
                            {
                                POP_WRK41 WRK041 = new POP_WRK41(sWrkOrder, sWrkOrderSeq);
                                if (ShowDialogForm(WRK041) == DialogResult.OK)
                                {
                                    this.DialogResult = DialogResult.OK;
                                    this.Close();
                                }
                            }
                        }
                        break;
                    case "Request":  //자재불출요청
                        if (iCnt < 1)
                        {
                            msgForm = new POPUP.MessageForm("작업지시를 선택하여 주시기 바랍니다.", MessageBoxButtons.OK, "알   림");
                            res = msgForm.ShowDialog(this);
                        }
                        else
                        {
                            dtReqList = setReqList();
                            POP_INV01 INV01 = new POP_INV01(dtReqList);
                            ShowDialogForm(INV01);
                        }
                        break;
                    case "MoveLog":  //자재이동이력
                        POP_INV03 INV03 = new POP_INV03();
                        ShowDialogForm(INV03);
                        break;
                    case "Return":  //자재반납요청
                        POP_INV05 INV05 = new POP_INV05();
                        ShowDialogForm(INV05);
                        break;
                    case "ReturnLog": //자재반납이력
                        POP_INV06 INV06 = new POP_INV06();
                        ShowDialogForm(INV06);
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
                LogFile.WriteLog("POP_WRK_LAMI_003.bBox1_buttonClickEvent Error => " + ex.Message);
            }
            finally
            {

            }
        }

        private void Grid1_GridClick(object sender, MESGrid.GridClickEventArg e)
        {
            if (Grid1.Rows.Count < 1)
            {
                return;
            }

            if (Grid1.Row == null)
            {
                return;
            }

            //작업지시사항 출력
            lblRemark.Text = e.row.Cells["ORDER_RMK"].Value.ToString();
        }

        private void Grid1_ClickCellButton(object sender, MESGrid.GridClickEventArg e)
        {
            //선택 버튼 클릭시 체크여부 변경
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
            }
            else if (e.column.ToString() == "DBTN") // 상세보기
            {
                string sWrkOrder = e.row.Cells["WRK_ORDR_NO"].Value.ToString();
                string sWrkOrderSeq = e.row.Cells["WRK_ORDR_SEQNO"].Value.ToString();

                POP_WRK84 popWrk84 = new POP_WRK84(POP_WRK84.PROC_INP, Common.PlantCode, Common.OpCode, sWrkOrder, sWrkOrderSeq);  // 작업지시 정보
                //popWrk84.LabelTitle = "작업지시 정보";

                ShowDialogForm(popWrk84);
            }
            //작업지시사항 출력
            lblRemark.Text = e.row.Cells["ORDER_RMK"].Value.ToString();
            //상세보기 클릭시 팝업화면 호출

        }

        private void butWorkDate_Click(object sender, EventArgs e)
        {
            Button btnTemp = (Button)sender;

            DateTime dt = DateTime.Today;
            if (btnTemp.Tag.ToString() == "startDate")
            {
                dt = dtpREQ_STR_DATE.Value;
            }
            else
            {
                dt = dtpREQ_END_DATE.Value;
            }

            DAResultDate pop = new DAResultDate(dt);
            pop.ShowDialog(this);
            if (pop.DialogResult == DialogResult.OK)
            {
                string strDate = pop.ResultString.ToString();
                if (btnTemp.Tag.ToString() == "startDate")
                {
                    dtpREQ_STR_DATE.Value = DateTime.Parse(strDate);
                }
                else
                {
                    dtpREQ_END_DATE.Value = DateTime.Parse(strDate);
                }
                SetGrid();
            }
        }
        #endregion

    }
}
