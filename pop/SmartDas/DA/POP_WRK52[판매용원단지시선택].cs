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
    public partial class POP_WRK52 : BaseForm
    {
        #region < MEMBER AREA >
        private string sOPCode = string.Empty;
        private string sIOType = string.Empty;
        private string sWrkOrderNo = string.Empty;
        private string sWrkOrderSeq = string.Empty;

        private SAMMI.Common _common = new SAMMI.Common();

        //private bool gbPacking = false;
        //Label lblSALES_ORDR;
        //TextBox txtSALES_ORDR;


        #endregion

        #region < CONSTRUCTOR >
/*
        public POP_WRK52()
        {
            InitializeComponent();

            Common.SetMessageList();

            sOPCode = Common.OpCode;
            sIOType = Common.IOType;
        }
*/
        public POP_WRK52(string OPCode, string IOType, string wrkOrderNo, string wrkOrderSeq)
        {
            InitializeComponent();

            Common.SetMessageList();

            sOPCode = OPCode;
            sIOType = IOType;
            sWrkOrderNo = wrkOrderNo;
            sWrkOrderSeq = wrkOrderSeq;

//            gbPacking = false;

            if (Common.PlantCode.Equals("P100"))
            {
                //제지공통(지종, 평량, 가로, 세로 검색조건 활성화)
                lblPW.Visible = true;
                txtPCODE.Visible = true;
                txtWEIGHT.Visible = true;

                pnlORDER_LOT.Visible = true;

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

        #region < POP_WRK52_Load >
        private void POP_WRK52_Load(object sender, EventArgs e)
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

                this.lblTitle.Text = "판매용 원단 지시 선택";

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
                SetMessage("POP_WRK52_Load_ Error!");
                LogFile.WriteLog("POP_WRK52.POP_WRK52_Load Error => " + ex.Message);
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

                if (Common.PlantCode.Equals("P100"))
                {
                    if (Common.OpCode == "SA" || Common.OpCode == "CB" || Common.OpCode == "PB" || Common.OpCode == "PC")
                    {
                        //bBox1[0, 1].Text = "자재불출\n요청";
                        //bBox1[0, 1].Tag = "Request";
                        //bBox1[0, 1].MappingButton.FontSize = 14;
                        //bBox1[0, 2].Text = "자재불출\n이력";
                        //bBox1[0, 2].Tag = "MoveLog";
                        //bBox1[0, 2].MappingButton.FontSize = 14;
                        bBox1[0, 1].Text = "자재반납\n요청";
                        bBox1[0, 1].Tag = "Return";
                        bBox1[0, 1].MappingButton.FontSize = 14;
                        bBox1[0, 2].Text = "자재반납\n이력";
                        bBox1[0, 2].Tag = "ReturnLog";
                        bBox1[0, 2].MappingButton.FontSize = 14;
                    }
                    else
                    {
                        bBox1[0, 1].Text = "";
                        bBox1[0, 1].Tag = "";
                        bBox1[0, 1].MappingButton.FontSize = 14;
                        bBox1[0, 2].Text = "";
                        bBox1[0, 2].Tag = "";
                        bBox1[0, 2].MappingButton.FontSize = 14;
                    }

                    bBox1[0, 3].Text = "";
                    bBox1[0, 3].Tag = "";
                    bBox1[0, 3].MappingButton.FontSize = 14;
                    bBox1[0, 4].Text = "";
                    bBox1[0, 4].Tag = "";
                    bBox1[0, 4].MappingButton.FontSize = 14;
                }
                else
                {
                    bBox1[0, 1].Text = "자재불출\n요청";
                    bBox1[0, 1].Tag = "Request";
                    bBox1[0, 1].MappingButton.FontSize = 14;
                    bBox1[0, 2].Text = "자재불출\n이력";
                    bBox1[0, 2].Tag = "MoveLog";
                    bBox1[0, 2].MappingButton.FontSize = 14;
                    bBox1[0, 3].Text = "자재반납\n요청";
                    bBox1[0, 3].Tag = "Return";
                    bBox1[0, 3].MappingButton.FontSize = 14;
                    bBox1[0, 4].Text = "자재반납\n이력";
                    bBox1[0, 4].Tag = "ReturnLog";
                    bBox1[0, 4].MappingButton.FontSize = 14;
                }

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
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                LogFile.WriteLog("POP_WRK52.SetButtons Error => " + ex.Message);
            }
        }

        private void DoFind()
        {

        }

        #region SET_GRID

        private void SetGrid()
        {
            DBHelper helper = new DBHelper();
            //변수
            string sStartDate = string.Empty;
            string sEndDate = string.Empty;
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
                sMatNR = txtMATNR.Text; //자재코드
                //그리드 설정
                Grid1.HeaderFontSize = 13;
                Grid1.FontSize = 13;
                Grid1.CountRows = 8;
                Grid1.AutoScroll = true;
                Grid1.DisplayLayout.Scrollbars = Scrollbars.Automatic;
                btnRightPage.LinkMoveSize = Grid1.CountRows;
                btnLeftPage.LinkMoveSize = Grid1.CountRows;

                //HL 작업지시 (SP_POP_WRK52_S01)
                dsTemp = helper.FillDataSetN("SP_POP_WRK52_S01", CommandType.StoredProcedure, 2
                                                               , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_PROC_CD", Common.OpCode, DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_IOTYPE", Common.IOType, DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_MACHINE", Common.MachineNo, DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_PRD_STR_DATE", sStartDate, DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_PRD_END_DATE", sEndDate, DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_PCODE", Common.ORD_PCODE, DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_WEIGHT", Common.ORD_WEIGHT, DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_MATNR", sMatNR, DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input));
                if (dsTemp.Tables[1].Rows.Count < 1)
                {
                    SetMessage("조회된 작업지시가 없습니다.");
                    new POPUP.MessageForm("조회된 작업지시가 없습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
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
                LogFile.WriteLog("POP_WRK52.SetGrid Error => " + ex.Message);
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
        private bool doOrderSelect(string sWrkOrder, string sWrkOrderSeq, string sOrderNo, string sMATNR)
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
                helper.ExecuteNoneQuery("SP_POP_WRK52_I01", CommandType.StoredProcedure
                         , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)
                         , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)
                         , helper.CreateParameter("P_WRK_ORDR_NO", sWrkOrder, DbType.String, ParameterDirection.Input)
                         , helper.CreateParameter("P_WRK_ORDR_SEQNO", sWrkOrderSeq, DbType.String, ParameterDirection.Input)
                         , helper.CreateParameter("P_ORDER_NO", sOrderNo, DbType.String, ParameterDirection.Input)
                         , helper.CreateParameter("P_MATNR", sMATNR, DbType.String, ParameterDirection.Input)
                         , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input)
                         );

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

            try
            {
                if (!this.bUseNetwork)
                {
                    SetMessage("네트워크 상태를 확인하시기 바랍니다.");
                    return;
                }

                MESButton btn = sender;
                //체크된 항목 확인
                for (int i = 0; i < Grid1.Rows.Count; i++)
                {
                    if (Grid1.Rows[i].Cells["CHK"].Value.ToString().Equals("V"))
                    {
                        iCnt++;
                        sOrderNo = Grid1.Rows[i].Cells["ORDER_NO"].Value.ToString();
                        sWrkOrder = Grid1.Rows[i].Cells["WRK_ORDR_NO"].Value.ToString();
                        sWrkOrderSeq = Grid1.Rows[i].Cells["WRK_ORDR_SEQNO"].Value.ToString();
                        sMATNR = Grid1.Rows[i].Cells["MATNR"].Value.ToString();
                        lblRemark.Text = Grid1.Rows[i].Cells["ORDER_RMK"].Value.ToString();
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
                        else
                        {
                            // TO-DO
                            /*
                             * 1. 최대지폭을 넘어가는 지 확인
                             * 2. 작업지시 선택 처리
                            */

                            // 1. 최대지폭 확인
                            int limitWidthPaper = 2950;  // 추후 변경해야함
                            int wrkWidthPaper = 0;
                            string orderNo = string.Empty, wrkOrderNo = string.Empty, wrkOrderSeq = string.Empty, itemCode = string.Empty;

                            for (int i = 0; i < Grid1.Rows.Count; i++)
                            {
                                // 현재 선택되어 있는 작업지시와 동일한 경우
                                if (Grid1.Rows[i].Cells["WRK_ORDR_NO"].Value.ToString().Equals(sWrkOrderNo) && Grid1.Rows[i].Cells["WRK_ORDR_SEQNO"].Value.ToString().Equals(sWrkOrderSeq))
                                {
                                    msgForm = new POPUP.MessageForm("기존과 동일한 작업지시 입니다.", MessageBoxButtons.OK, "알   림");
                                    res = msgForm.ShowDialog(this);
                                    return;
                                }

                                if (Grid1.Rows[i].Cells["CHK"].Value.ToString() == "V")
                                {
                                    if (wrkWidthPaper == 0)
                                    {
                                        orderNo = Grid1.Rows[i].Cells["ORDER_NO"].Value.ToString();
                                        wrkOrderNo = Grid1.Rows[i].Cells["WRK_ORDR_NO"].Value.ToString();
                                        wrkOrderSeq = Grid1.Rows[i].Cells["WRK_ORDR_SEQNO"].Value.ToString();
                                        itemCode = Grid1.Rows[i].Cells["MATNR"].Value.ToString();
                                    }
                                    wrkWidthPaper = wrkWidthPaper + int.Parse(Grid1.Rows[i].Cells["MATNR_SPEC"].Value.ToString());

                                    if (wrkWidthPaper > limitWidthPaper)
                                    {
                                        msgForm = new POPUP.MessageForm("선택된 작업지시의 지폭 합이 설비의 최대 지폭보다 큽니다.", MessageBoxButtons.OK, "알   림");
                                        res = msgForm.ShowDialog(this);
                                        return;
                                    }
                                }
                            }

                            // 작업지시 변경 호출
                            doConfirm(orderNo, wrkOrderNo, wrkOrderSeq, itemCode);
                            //POP_WRK41 WRK041 = new POP_WRK41(sWrkOrder, sWrkOrderSeq);
                            //if (ShowDialogForm(WRK041) == DialogResult.OK)
                            //{
                            //    this.DialogResult = DialogResult.OK;
                            //    this.Close();
                            //}
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
                LogFile.WriteLog("POP_WRK52.bBox1_buttonClickEvent Error => " + ex.Message);
            }
            finally
            {

            }
        }

        private void doConfirm(string orderNo, string wrkOrderNo, string wrkOrderSeq, string itemCode)
        {
            DBHelper helper = new DBHelper(false, "", true);

            DataSet dsTemp;
            DataTable dtTemp;

            string sMSG = string.Empty;

            POPUP.MessageForm msgForm = null;
            DialogResult res = DialogResult.Cancel;

            //string sORDER_NO = drNowWrk == null ? string.Empty : drNowWrk["ORDER_NO"].ToString(); //기존지시 생산오더
            string sWRK_ORDER_NO = ""; //기존작업지시
            string sWRK_ORDER_SEQNO = ""; //기존작업지시순번
            string sNEW_ORDER_NO = orderNo; //신규지시 생산오더                             // 조회 그리드에서
            string sNEW_WRK_ORDER_NO = wrkOrderNo; //신규작업지시                                             // 조회 그리드에서
            string sNEW_WRK_ORDER_SEQNO = wrkOrderSeq; //신규작업지시순번                                     // 조회 그리드에서
            string sMTANR = ""; //기존 품목 코드          // 쿼리에서
            string sMTANRN = itemCode; //신규 품목 코드                                          // 조회 그리드에서
            string sTempOrder;//비교용 기존 지시정보
            string sTempNewOrder; //비교용 신규 지시정보
            string sPRFM_DOC = string.Empty;//실적등록 문서번호
            string sDISPO_DOC = string.Empty;//폐품등록 문서번호
            string sORDER_DOC = string.Empty;//오더완료 문서번호
            string sPRFM_CNL_FUNC = string.Empty;//실적취소 기능명
            string sDISPO_CNL_FUNC = string.Empty;//폐품취소 기능명
            string sPRFM_FUNC = string.Empty;//실적등록 기능명
            string sDISPO_FUNC = string.Empty;//폐품등록 기능명
            string sORDER_FUNC = string.Empty;//오더완료 기능명
            DataSet dsPRFM_CNL = new DataSet(); //실적 취소 RFC Data
            DataSet dsDISPO_CNL = new DataSet(); //폐품 취소 RFC Data
            DataSet dsPRFM = new DataSet(); //실적 등록 RFC Data
            DataSet dsDISPO = new DataSet(); //폐품 등록 RFC Data
            DataSet dsORDER = new DataSet(); //오더완료 등록 RFC Data
            DateTime dNowStartDate;
            DateTime dNowEndDate;
            DateTime dNewStartDate;
            int iDispoQty = 0; //폐품 수량,

            ////dNowStartDate = Common.makeDateTime(dtpStartDate.Value, lblStartTime.Text);
            ////dNowEndDate = Common.makeDateTime(dtpEndDate.Value, lblEndTime.Text);
            ////dNewStartDate = Common.makeDateTime(dtpStartDateN.Value, lblStartTimeN.Text);

            dNowStartDate = Common.makeDateTime(dtpStartDateN.Value, dtpStartDateN.Value.ToString("yyyyMMddHH:mm:ss").Substring(8, 5));
            dNowEndDate = Common.makeDateTime(dtpStartDateN.Value, dtpStartDateN.Value.ToString("yyyyMMddHH:mm:ss").Substring(8, 5));
            dNewStartDate = Common.makeDateTime(dtpStartDateN.Value, dtpStartDateN.Value.ToString("yyyyMMddHH:mm:ss").Substring(8, 5));

            try
            {
                sTempOrder = sWRK_ORDER_NO + sWRK_ORDER_SEQNO;
                sTempNewOrder = sNEW_WRK_ORDER_NO + sNEW_WRK_ORDER_SEQNO;
                if (sTempOrder.Equals(sTempNewOrder))
                {
                    new POPUP.MessageForm("기존과 동일한 작업지시 입니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                }
                //else if ((!string.IsNullOrEmpty(lblStartTime.Text) && !string.IsNullOrEmpty(lblStartTime.Text))
                //        && (dNowStartDate >= dNowEndDate || dNowEndDate > dNewStartDate))
                //{
                //    new POPUP.MessageForm("작업시간을 확인하여 주시기 바랍니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                //}
                else
                {
                    this.Cursor = Cursors.WaitCursor;   //Waitting
                    int repCnt = 0;
                    string repWrkOrdrNo = string.Empty;
                    for (int i = 0; i < Grid1.Rows.Count; i++)
                    {
                        if (Grid1.Rows[i].Cells["CHK"].Value.ToString().Equals("V"))
                        {
                            if (repCnt == 0)
                            {
                                repWrkOrdrNo = Grid1.Rows[i].Cells["WRK_ORDR_NO"].Value.ToString();
                            }
                            repCnt++;

                            //작업시작 (작업지시 상태변경 및 작업장 현황의 가동상태 변경)
                            dsTemp = helper.FillDataSetN("SP_POP_WRK52_U01", CommandType.StoredProcedure, 2
                                          , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)
                                          , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)
                                          , helper.CreateParameter("P_IOTYPE", Common.IOType, DbType.String, ParameterDirection.Input)
                                          , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input)
                                          , helper.CreateParameter("P_ORDER_NO", Grid1.Rows[i].Cells["ORDER_NO"].Value.ToString(), DbType.String, ParameterDirection.Input)                     // 사용하지 않음
                                          , helper.CreateParameter("P_WRK_ORDR_NO", Grid1.Rows[i].Cells["WRK_ORDR_NO"].Value.ToString(), DbType.String, ParameterDirection.Input)               // 사용하지 않음
                                          , helper.CreateParameter("P_WRK_ORDR_SEQNO", Grid1.Rows[i].Cells["WRK_ORDR_SEQNO"].Value.ToString(), DbType.String, ParameterDirection.Input)         // 사용하지 않음
                                          , helper.CreateParameter("P_PRD_STR_DATE", dNowStartDate.ToString("yyyy-MM-dd HH:mm:ss"), DbType.String, ParameterDirection.Input)
                                          , helper.CreateParameter("P_PRD_END_DATE", dNowEndDate.ToString("yyyy-MM-dd HH:mm:ss"), DbType.String, ParameterDirection.Input)
                                          , helper.CreateParameter("P_NEW_ORDER_NO", Grid1.Rows[i].Cells["ORDER_NO"].Value.ToString(), DbType.String, ParameterDirection.Input)
                                          , helper.CreateParameter("P_NEW_WRK_ORDR_NO", Grid1.Rows[i].Cells["WRK_ORDR_NO"].Value.ToString(), DbType.String, ParameterDirection.Input)
                                          , helper.CreateParameter("P_NEW_WRK_ORDR_SEQNO", Grid1.Rows[i].Cells["WRK_ORDR_SEQNO"].Value.ToString(), DbType.String, ParameterDirection.Input)
                                          , helper.CreateParameter("P_NEW_PRD_STR_DATE", dNewStartDate.ToString("yyyy-MM-dd HH:mm:ss"), DbType.String, ParameterDirection.Input)
                                          , helper.CreateParameter("P_MATNR", sMTANR, DbType.String, ParameterDirection.Input)
                                          , helper.CreateParameter("P_NEW_MATNR", sMTANRN, DbType.String, ParameterDirection.Input)
                                          , helper.CreateParameter("P_PROC_CD", Common.OpCode, DbType.String, ParameterDirection.Input)
                                          , helper.CreateParameter("P_SEQ_NO", repCnt.ToString(), DbType.String, ParameterDirection.Input)
                                          , helper.CreateParameter("P_CHIN_WRK_ORDR_NO", repWrkOrdrNo, DbType.String, ParameterDirection.Input)
                                          , helper.CreateParameter("P_ORDER_DOC", DbType.String, ParameterDirection.Output, null, 30)
                                          , helper.CreateParameter("P_WRK_FUNC", DbType.String, ParameterDirection.Output, null, 30)
                                          );

                            if (helper.RSCODE == "E")
                            {
                                this.Cursor = Cursors.WaitCursor;   //Waitting
                                new POPUP.MessageForm(helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                helper.Rollback();
                                return;
                            }
                            else
                            {
                                sORDER_DOC = helper.Parameters["P_ORDER_DOC"].Value.ToString();
                                sORDER_FUNC = helper.Parameters["P_WRK_FUNC"].Value.ToString();
                                //오더완료 전송 Data
                                if (dsTemp.Tables.Count > 0)
                                {
                                    dtTemp = dsTemp.Tables[0].Copy();
                                    dsORDER.Tables.Add(dtTemp);
                                    dtTemp = dsTemp.Tables[1].Copy();
                                    dsORDER.Tables.Add(dtTemp);
                                }
                            }
                        }
                    }

                    
                    //프로시저 결과 저장
                    helper.Commit();

                    //공통관리정보 수정
                    Common.OrderNo = sNEW_ORDER_NO;
                    Common.WrkOrderNo = sWRK_ORDER_NO;
                    Common.WrkOrderSeq = sWRK_ORDER_SEQNO;
                    Common.ItemCode = sMTANRN;

                    this.Cursor = Cursors.WaitCursor;   //Waitting
                    new POPUP.MessageForm("지시변경이 완료되었습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    this.DialogResult = DialogResult.OK;
                    this.Close();
                }
            }
            catch (Exception ex)
            {
                this.Cursor = Cursors.Default;   //Waitting
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                helper.Rollback();
            }
            finally
            {
                this.Cursor = Cursors.Default;   //Waitting
                helper.Close();
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

                //if (sStatus_Pre != "V")
                //{
                //    foreach (UltraGridRow row in Grid1.Rows)
                //    {
                //        row.Cells["CHK"].Value = "-";
                //    }
                //}

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
