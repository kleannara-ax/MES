#region [ USING AREA ]
using System;
using System.Configuration;
using System.Data;
using System.Windows.Forms;
using System.Drawing;


using SAMMI;
using SmartDas.Components;
using SmartDas.POPUP;

using Oracle.ManagedDataAccess.Client;
#endregion

namespace SmartDas
{
    public partial class POP_WRK41 : BaseForm
    {
        #region < MEMBER AREA >

        private SAMMI.Common _common = new SAMMI.Common();

        private string sMachCode = string.Empty;
        private string sIOType = string.Empty;
        private string sWorker = string.Empty;
        private string sOrderNo = string.Empty;
        private string sNewWrkOrder = string.Empty;
        private string sNewWrkOrderSeq = string.Empty;
        private DataTable dtWrkOrder; //작업정보 조회
        private DataRow drNowWrk; //기본 작업정보
        private DataRow drNewWrk; //신규 작업정보
        private double dNowPRFMQty; //현재지시 실적수량
        private bool bEndFlag = false; //설비별 작업 완료여부(이후 작업이 없이 완료처리)

        #endregion

        #region < CONSTRUCTOR >

        public POP_WRK41()
        {
            InitializeComponent();

            Common.SetMessageList();

        }

        public POP_WRK41(string WrkOrderNo, string WrkOrderSeq)
        {
            InitializeComponent();

            Common.SetMessageList();

            sMachCode = Common.MachineCode;
            sIOType = Common.IOType;
            sWorker = Common.UserID;
            sNewWrkOrder = WrkOrderNo;
            sNewWrkOrderSeq = WrkOrderSeq;
            bEndFlag = false;
        }

        public POP_WRK41(string WrkOrderNo, string WrkOrderSeq, bool EndFlag)
        {
            InitializeComponent();

            Common.SetMessageList();

            sMachCode = Common.MachineCode;
            sIOType = Common.IOType;
            sWorker = Common.UserID;
            sNewWrkOrder = WrkOrderNo;
            sNewWrkOrderSeq = WrkOrderSeq;
            bEndFlag = true;
        }

        #endregion

        #region < POP_WRK41_Load >
        private void POP_WRK41_Load(object sender, EventArgs e)
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

                this.lblTitle.Text = "작업지시 변경";

                SetMenuButtons();
                if(bEndFlag)
                    DoFind_End();
                else
                    DoFind();
            }
            catch (Exception ex)
            {
                SetMessage("POP_WRK41_Load_ Error!");
                LogFile.WriteLog("POP_WRK41.POP_WRK41_Load Error\r\n" + ex.Message);
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

                bBox1[0, 0].Text = "확인";
                bBox1[0, 0].Tag = "Confirm";
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
                LogFile.WriteLog("POP_WRK41.SetButtons Error\r\n" + ex.Message);
            }
        }

        private void DoFind()
        {
            DBHelper helper = new DBHelper();
            DateTime dtStartTime;
            DateTime dtEndTime;
            DateTime dtStartTimeN;
            int iInputQty;
            int iProdQty;
            int iDispoQty;

            try
            {
                dtWrkOrder = helper.FillTable("SP_POP_WRK41_S01", CommandType.StoredProcedure
                                                                   , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)
                                                                   , helper.CreateParameter("P_PROC_CD", Common.OpCode, DbType.String, ParameterDirection.Input)
                                                                   , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)
                                                                   , helper.CreateParameter("P_IOTYPE", Common.IOType, DbType.String, ParameterDirection.Input)
                                                                   , helper.CreateParameter("P_WRK_ORDR_NO", sNewWrkOrder, DbType.String, ParameterDirection.Input)
                                                                   , helper.CreateParameter("P_WRK_ORDR_SEQ", sNewWrkOrderSeq, DbType.String, ParameterDirection.Input)
                                                                   , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input));
                if (dtWrkOrder.Rows.Count < 1)
                {
                    SetMessage("조회된 작업지시가 없습니다.");
                    new POPUP.MessageForm("조회된 작업지시가 없습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return;
                }
                else if (dtWrkOrder.Rows.Count == 1)
                {
                    //조회된 지시가 선택된 지시인 경우(작업중인 지시가 없는 경우)
                    if (dtWrkOrder.Rows[0]["MACH_STA"].ToString().Equals("0"))
                    {
                        drNewWrk = dtWrkOrder.Select("MACH_STA = '0'")[0];
                        //변경될 작업지시 조회
                        lblOrderDateN.Text = drNewWrk["PRD_REQ_DT"].ToString();//생산지시일
                        lblOrderNoN.Text = drNewWrk["WRK_ORDR_NO"].ToString();//작업지시번호
                        lblOrderSeqN.Text = drNewWrk["WRK_ORDR_SEQNO"].ToString();//작업지시순번
                        lblItemCodeN.Tag = drNewWrk["MATNR"].ToString(); //자재코드
                        lblItemCodeN.Text = drNewWrk["MATNR_NM"].ToString(); //자재명
                        lblItemSpecN.Text = drNewWrk["MATNR_SPEC"].ToString(); //규격
                        lblPaperWidthN.Text = drNewWrk["SPEC"].ToString(); //지폭(폭수)
                        lblOrderRemarkN.Text = drNewWrk["WRK_ORDR_RMK"].ToString(); //작업지시사항
                        lblPlanQtyN.Text = string.Format("{0:#,##0}", drNewWrk["ORDER_QTY"]); //계획량
                        //이전지시 완료시간을 신규 시작시간으로 자동처리
                        if (DateTime.TryParse(drNewWrk["PRD_STR_DATE"].ToString(), out dtStartTimeN))
                        {
                            dtpStartDateN.Value = dtStartTimeN;
                            lblStartTimeN.Text = dtpStartDateN.Value.ToString("HH:mm");
                        }
                        //이전 지시가 없는 경우 금일 07시로 지정
                        else
                        {
                            dtpStartDateN.Value = DateTime.Now;
                            lblStartTimeN.Text = "07:00";
                        }

                        sOrderNo = drNewWrk["ORDER_NO"].ToString();//생산오더번호

                        lblTotalHead.Visible = false;
                        lblProdHead.Visible = false;
                        lblDispoHead.Visible = false;
                        lblTotalQty.Visible = false;
                        lblProdQty.Visible = false;
                        lblDispoQty.Visible = false;
                    }
                    //조회된 지시가 작업중인 지시인 경우
                    else
                    {
                        new POPUP.MessageForm("선택된 지시를 확인하여 주시기 바랍니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                        this.Close();
                    }
                }
                else
                {
                    //현재 및 변경될 작업지시 조회
                    drNowWrk = dtWrkOrder.Select("MACH_STA <> '0'")[0];
                    drNewWrk = dtWrkOrder.Select("MACH_STA = '0'")[0];
                    //현재 작업지시 정보 출력
                    lblOrderDate.Text = drNowWrk["PRD_REQ_DT"].ToString();//생산지시일
                    lblOrderNo.Text = drNowWrk["WRK_ORDR_NO"].ToString();//작업지시번호
                    lblOrderSeq.Text = drNowWrk["WRK_ORDR_SEQNO"].ToString();//작업지시순번
                    lblItemCode.Tag = drNowWrk["MATNR"].ToString(); //자재코드
                    lblItemCode.Text = drNowWrk["MATNR_NM"].ToString(); //자재명
                    lblItemSpec.Text = drNowWrk["MATNR_SPEC"].ToString(); //규격
                    lblPaperWidth.Text = drNowWrk["SPEC"].ToString(); //지폭(폭수)
                    lblOrderRemark.Text = drNowWrk["WRK_ORDR_RMK"].ToString(); //작업지시사항
                    lblPlanQty.Text = string.Format("{0:#,##0}", drNowWrk["ORDER_QTY"]); //계획량
                    double.TryParse(drNowWrk["PRD_QTY"].ToString(), out dNowPRFMQty);
                    //시작시간 출력
                    if (DateTime.TryParse(drNowWrk["PRD_STR_DATE"].ToString(), out dtStartTime))
                        dtpStartDate.Value = dtStartTime;
                    else
                        dtpStartDate.Value = DateTime.Now;
                    lblStartTime.Text = dtpStartDate.Value.ToString("HH:mm");
                    //완료시간 출력
                    if (DateTime.TryParse(drNowWrk["PRD_END_DATE"].ToString(), out dtEndTime))
                        dtpEndDate.Value = dtEndTime;
                    else
                        dtpEndDate.Value = DateTime.Now;
                    lblEndTime.Text = dtpEndDate.Value.ToString("HH:mm");
                    //실적 정보 출력(T:화장지 / P:생리대,기저귀)
                    if (drNowWrk["PRODTYPE"].ToString().Equals("T"))
                    {
                        lblTotalHead.Text = "투입중량";
                        lblProdHead.Text = "완제품생산중량";
                        lblDispoHead.Text = "폐품중량";

                        lblTotalQty.BackColor = Color.LightGray;
                        lblProdQty.BackColor = Color.LightGray;
                        lblDispoQty.BackColor = Color.White;

                        //화장지 폐품등록시 WEB에서 처리
                        lblTotalHead.Visible = false;
                        lblProdHead.Visible = false;
                        lblDispoHead.Visible = false;
                        lblTotalQty.Visible = false;
                        lblProdQty.Visible = false;
                        lblDispoQty.Visible = false;
                    }
                    else if (drNowWrk["PRODTYPE"].ToString().Equals("P"))
                    {
                        lblTotalHead.Text = "총생산수량";
                        lblProdHead.Text = "실적수량";
                        lblDispoHead.Text = "폐품수량";

                        lblTotalQty.BackColor = Color.White;
                        lblProdQty.BackColor = Color.LightGray;
                        lblDispoQty.BackColor = Color.White;

                        //포장기에서 처리시 폐품등록 불가
                        if (!Common.PlantCode.Equals("P500") && Common.IOType.Equals("O"))
                        {
                            lblTotalHead.Visible = false;
                            lblProdHead.Visible = false;
                            lblDispoHead.Visible = false;
                            lblTotalQty.Visible = false;
                            lblProdQty.Visible = false;
                            lblDispoQty.Visible = false;
                        }
                    }
                    else
                    {
                        lblTotalHead.Visible = false;
                        lblProdHead.Visible = false;
                        lblDispoHead.Visible = false;
                        lblTotalQty.Visible = false;
                        lblProdQty.Visible = false;
                        lblDispoQty.Visible = false;
                    }
                    //수량 출력
                    lblTotalQty.Text = drNowWrk["TOTAL_QTY"].ToString();
                    lblProdQty.Text = drNowWrk["PRD_QTY"].ToString();
                    lblDispoQty.Text = drNowWrk["DISPO_QTY"].ToString();
                    //화장지 가공기의 경우 폐품수량 자동 처리
                    if (Common.MachineCode.Contains("RA"))
                    {
                        if (Common.IOType.Equals("I"))
                        {
                            int.TryParse(drNowWrk["TOTAL_QTY"].ToString(), out iInputQty);
                            int.TryParse(drNowWrk["PRD_QTY"].ToString(), out iProdQty);
                            iDispoQty = iInputQty - iProdQty;
                            lblDispoQty.Text = iDispoQty > 0 ? iDispoQty.ToString() : "0";
                        }
                    }

                    //변경될 작업지시 조회
                    lblOrderDateN.Text = drNewWrk["PRD_REQ_DT"].ToString();//생산지시일
                    lblOrderNoN.Text = drNewWrk["WRK_ORDR_NO"].ToString();//작업지시번호
                    lblOrderSeqN.Text = drNewWrk["WRK_ORDR_SEQNO"].ToString();//작업지시순번
                    lblItemCodeN.Tag = drNewWrk["MATNR"].ToString(); //자재코드
                    lblItemCodeN.Text = drNewWrk["MATNR_NM"].ToString(); //자재명
                    lblItemSpecN.Text = drNewWrk["MATNR_SPEC"].ToString(); //규격
                    lblPaperWidthN.Text = drNewWrk["SPEC"].ToString(); //지폭(폭수)
                    lblOrderRemarkN.Text = drNewWrk["WRK_ORDR_RMK"].ToString(); //작업지시사항
                    lblPlanQtyN.Text = string.Format("{0:#,##0}", drNewWrk["ORDER_QTY"]); //계획량

                    sOrderNo = drNewWrk["ORDER_NO"].ToString();//생산오더번호
                    //이전지시 완료시간을 신규 시작시간으로 자동처리
                    if (DateTime.TryParse(drNowWrk["PRD_END_DATE"].ToString(), out dtStartTimeN))
                        dtpStartDateN.Value = dtStartTimeN;
                    else
                        dtpStartDateN.Value = DateTime.Now;
                    lblStartTimeN.Text = dtpStartDateN.Value.ToString("HH:mm");
                }
            }
            catch (Exception ex)
            {
                SetMessage("SetGrid Error!");
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                LogFile.WriteLog("POP_WRK41.WRK_ORDER Find Error\r\n" + ex.Message);
            }
        }

        private void DoFind_End()
        {
            DBHelper helper = new DBHelper();
            DateTime dtStartTime;
            DateTime dtEndTime;
            DateTime dtStartTimeN;
            int iInputQty;
            int iProdQty;
            int iDispoQty;

            try
            {
                dtWrkOrder = helper.FillTable("SP_POP_WRK41_S02", CommandType.StoredProcedure
                                                                   , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)
                                                                   , helper.CreateParameter("P_PROC_CD", Common.OpCode, DbType.String, ParameterDirection.Input)
                                                                   , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)
                                                                   , helper.CreateParameter("P_IOTYPE", Common.IOType, DbType.String, ParameterDirection.Input)
                                                                   , helper.CreateParameter("P_WRK_ORDR_NO", sNewWrkOrder, DbType.String, ParameterDirection.Input)
                                                                   , helper.CreateParameter("P_WRK_ORDR_SEQ", sNewWrkOrderSeq, DbType.String, ParameterDirection.Input)
                                                                   , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input));
                if (dtWrkOrder.Rows.Count < 1)
                {
                    SetMessage("조회된 작업지시가 없습니다.");
                    new POPUP.MessageForm("조회된 작업지시가 없습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return;
                }
                else if (dtWrkOrder.Rows.Count == 1)
                {
                    //현재 및 변경될 작업지시 조회
                    drNowWrk = dtWrkOrder.Select("MACH_STA <> '0'")[0];
                    //현재 작업지시 정보 출력
                    lblOrderDate.Text = drNowWrk["PRD_REQ_DT"].ToString();//생산지시일
                    lblOrderNo.Text = drNowWrk["WRK_ORDR_NO"].ToString();//작업지시번호
                    lblOrderSeq.Text = drNowWrk["WRK_ORDR_SEQNO"].ToString();//작업지시순번
                    lblItemCode.Tag = drNowWrk["MATNR"].ToString(); //자재코드
                    lblItemCode.Text = drNowWrk["MATNR_NM"].ToString(); //자재명
                    lblItemSpec.Text = drNowWrk["MATNR_SPEC"].ToString(); //규격
                    lblPaperWidth.Text = drNowWrk["SPEC"].ToString(); //지폭(폭수)
                    lblOrderRemark.Text = drNowWrk["WRK_ORDR_RMK"].ToString(); //작업지시사항
                    lblPlanQty.Text = string.Format("{0:#,##0}", drNowWrk["ORDER_QTY"]); //계획량
                    double.TryParse(drNowWrk["PRD_QTY"].ToString(), out dNowPRFMQty);
                    //시작시간 출력
                    if (DateTime.TryParse(drNowWrk["PRD_STR_DATE"].ToString(), out dtStartTime))
                        dtpStartDate.Value = dtStartTime;
                    else
                        dtpStartDate.Value = DateTime.Now;
                    lblStartTime.Text = dtpStartDate.Value.ToString("HH:mm");
                    //완료시간 출력
                    if (DateTime.TryParse(drNowWrk["PRD_END_DATE"].ToString(), out dtEndTime))
                        dtpEndDate.Value = dtEndTime;
                    else
                        dtpEndDate.Value = DateTime.Now;
                    lblEndTime.Text = dtpEndDate.Value.ToString("HH:mm");
                    //실적 정보 출력(T:화장지 / P:생리대,기저귀)
                    if (drNowWrk["PRODTYPE"].ToString().Equals("T"))
                    {
                        lblTotalHead.Text = "투입중량";
                        lblProdHead.Text = "완제품생산중량";
                        lblDispoHead.Text = "폐품중량";

                        lblTotalQty.BackColor = Color.LightGray;
                        lblProdQty.BackColor = Color.LightGray;
                        lblDispoQty.BackColor = Color.White;

                        //화장지 폐품등록시 WEB에서 처리
                        lblTotalHead.Visible = false;
                        lblProdHead.Visible = false;
                        lblDispoHead.Visible = false;
                        lblTotalQty.Visible = false;
                        lblProdQty.Visible = false;
                        lblDispoQty.Visible = false;
                    }
                    else if (drNowWrk["PRODTYPE"].ToString().Equals("P"))
                    {
                        lblTotalHead.Text = "총생산수량";
                        lblProdHead.Text = "실적수량";
                        lblDispoHead.Text = "폐품수량";

                        lblTotalQty.BackColor = Color.White;
                        lblProdQty.BackColor = Color.LightGray;
                        lblDispoQty.BackColor = Color.White;

                        //포장기에서 처리시 폐품등록 불가
                        if (!Common.PlantCode.Equals("P500") && Common.IOType.Equals("O"))
                        {
                            lblTotalHead.Visible = false;
                            lblProdHead.Visible = false;
                            lblDispoHead.Visible = false;
                            lblTotalQty.Visible = false;
                            lblProdQty.Visible = false;
                            lblDispoQty.Visible = false;
                        }
                    }
                    else
                    {
                        lblTotalHead.Visible = false;
                        lblProdHead.Visible = false;
                        lblDispoHead.Visible = false;
                        lblTotalQty.Visible = false;
                        lblProdQty.Visible = false;
                        lblDispoQty.Visible = false;
                    }
                    //수량 출력
                    lblTotalQty.Text = drNowWrk["TOTAL_QTY"].ToString();
                    lblProdQty.Text = drNowWrk["PRD_QTY"].ToString();
                    lblDispoQty.Text = drNowWrk["DISPO_QTY"].ToString();
                    //화장지 가공기의 경우 폐품수량 자동 처리
                    if (Common.MachineCode.Contains("RA"))
                    {
                        if (Common.IOType.Equals("I"))
                        {
                            int.TryParse(drNowWrk["TOTAL_QTY"].ToString(), out iInputQty);
                            int.TryParse(drNowWrk["PRD_QTY"].ToString(), out iProdQty);
                            iDispoQty = iInputQty - iProdQty;
                            lblDispoQty.Text = iDispoQty > 0 ? iDispoQty.ToString() : "0";
                        }
                    }
                }

            }
            catch (Exception ex)
            {
                SetMessage("SetGrid Error!");
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                LogFile.WriteLog("POP_WRK41.WRK_ORDER Find Error\r\n" + ex.Message);
            }
        }

        private void doConfirm()
        {
            DBHelper helper = new DBHelper(false, "", true);

            DataSet dsTemp;
            DataTable dtTemp;

            string sMSG = string.Empty;

            POPUP.MessageForm msgForm = null;
            DialogResult res = DialogResult.Cancel;

            string sORDER_NO = drNowWrk == null ? string.Empty : drNowWrk["ORDER_NO"].ToString(); //기존지시 생산오더
            string sWRK_ORDER_NO = lblOrderNo.Text; //기존작업지시
            string sWRK_ORDER_SEQNO = lblOrderSeq.Text; //기존작업지시순번
            string sNEW_ORDER_NO = drNewWrk["ORDER_NO"].ToString(); //신규지시 생산오더
            string sNEW_WRK_ORDER_NO = lblOrderNoN.Text; //신규작업지시
            string sNEW_WRK_ORDER_SEQNO = lblOrderSeqN.Text; //신규작업지시순번
            string sMTANR = drNowWrk == null ? string.Empty : lblItemCode.Tag.ToString(); //기존 품목 코드
            string sMTANRN = lblItemCodeN.Tag.ToString(); //신규 품목 코드
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

            dNowStartDate = Common.makeDateTime(dtpStartDate.Value, lblStartTime.Text);
            dNowEndDate = Common.makeDateTime(dtpEndDate.Value, lblEndTime.Text);
            dNewStartDate = Common.makeDateTime(dtpStartDateN.Value, lblStartTimeN.Text);

            try
            {
                sTempOrder = sWRK_ORDER_NO + sWRK_ORDER_SEQNO;
                sTempNewOrder = sNEW_WRK_ORDER_NO + sNEW_WRK_ORDER_SEQNO;
                if (sTempOrder.Equals(sTempNewOrder))
                {
                    new POPUP.MessageForm("기존과 동일한 작업지시 입니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                }
                else if ((!string.IsNullOrEmpty(lblStartTime.Text) && !string.IsNullOrEmpty(lblStartTime.Text))
                        && (dNowStartDate >= dNowEndDate || dNowEndDate > dNewStartDate))
                {
                    new POPUP.MessageForm("작업시간을 확인하여 주시기 바랍니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                }
                else
                {
                    if (dNowPRFMQty == 0.0)
                    {
                        msgForm = new POPUP.MessageForm("현재 지시의 실적이 등록되지 않았습니다.\n지시를 변경하시겠습니까?", MessageBoxButtons.OKCancel, "알   림");
                        res = msgForm.ShowDialog(this);
                        if (res != System.Windows.Forms.DialogResult.OK)
                            return;
                    }
                    //이전 지시의 실적 존재시 폐품 수량입력 필수
                    else
                    {
                        if (lblDispoQty.Visible)
                        {
                            if (int.TryParse(lblDispoQty.Text.Replace(",", ""), out iDispoQty))
                            {
                                if (iDispoQty == 0)
                                {
                                    //new POPUP.MessageForm("폐품수량을 확인하여 주시기 바랍니다.\n" + helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                    //return;
                                    msgForm = new POPUP.MessageForm("폐품수량이 0으로 입력되었습니다.\n진행하시겠습니까?", MessageBoxButtons.OKCancel, "알   림");
                                    res = msgForm.ShowDialog(this);
                                    if (res != System.Windows.Forms.DialogResult.OK)
                                        return;
                                }
                            }
                            else
                            {
                                new POPUP.MessageForm("폐품수량을 확인하여 주시기 바랍니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                return;
                            }
                        }
                    }

                    this.Cursor = Cursors.WaitCursor;   //Waitting
                    //폐품수량 등록
                    if (!string.IsNullOrEmpty(lblDispoQty.Text) && !lblDispoQty.Text.Equals("0"))
                    {
                        #region 작업중
                        ////기존 폐품이력 존재시 취소처리
                        //dsTemp = helper.FillDataSetN("SP_POP_WRK41_D02", CommandType.StoredProcedure, 4
                        //          , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)
                        //          , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)
                        //          , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input)
                        //          , helper.CreateParameter("P_ORDER_NO", sORDER_NO, DbType.String, ParameterDirection.Input)
                        //          , helper.CreateParameter("P_WRK_ORDR_NO", sWRK_ORDER_NO, DbType.String, ParameterDirection.Input)
                        //          , helper.CreateParameter("P_WRK_ORDR_SEQNO", sWRK_ORDER_SEQNO, DbType.String, ParameterDirection.Input)
                        //          , helper.CreateParameter("P_DISPO_FUNC", DbType.String, ParameterDirection.Output, null, 30)
                        //          , helper.CreateParameter("P_PRFM_FUNC", DbType.String, ParameterDirection.Output, null, 30)
                        //          );

                        //if (helper.RSCODE == "E")
                        //{
                        //    new POPUP.MessageForm("폐품취소에 실패 하였습니다.\n" + helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                        //    helper.Rollback();
                        //    return;
                        //}
                        //else if (helper.RSCODE == "N")
                        //{
                        //    sDISPO_CNL_FUNC = string.Empty;
                        //    sPRFM_CNL_FUNC = string.Empty;
                        //}
                        //else
                        //{
                        //    //실적, 폐품 SAP기능
                        //    sDISPO_CNL_FUNC = helper.Parameters["P_DISPO_FUNC"].Value.ToString();
                        //    sPRFM_CNL_FUNC = helper.Parameters["P_PRFM_FUNC"].Value.ToString();
                        //    //폐품 취소 Data
                        //    dtTemp = dsTemp.Tables[0].Copy();
                        //    dsDISPO_CNL.Tables.Add(dtTemp);
                        //    dtTemp = dsTemp.Tables[1].Copy();
                        //    dsDISPO_CNL.Tables.Add(dtTemp);
                        //    //실적 취소 Data
                        //    dtTemp = dsTemp.Tables[2].Copy();
                        //    dsPRFM_CNL.Tables.Add(dtTemp);
                        //    dtTemp = dsTemp.Tables[3].Copy();
                        //    dsPRFM_CNL.Tables.Add(dtTemp);
                        //}
                        #endregion

                        //폐품 이력 등록
                        dsTemp = helper.FillDataSetN("SP_POP_WRK41_D01", CommandType.StoredProcedure, 4
                                  , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)
                                  , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)
                                  , helper.CreateParameter("P_IOTYPE", Common.IOType, DbType.String, ParameterDirection.Input)
                                  , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input)
                                  , helper.CreateParameter("P_ORDER_NO", sORDER_NO, DbType.String, ParameterDirection.Input)
                                  , helper.CreateParameter("P_WRK_ORDR_NO", sWRK_ORDER_NO, DbType.String, ParameterDirection.Input)
                                  , helper.CreateParameter("P_WRK_ORDR_SEQNO", sWRK_ORDER_SEQNO, DbType.String, ParameterDirection.Input)
                                  , helper.CreateParameter("P_PRD_STR_DATE", dNowStartDate.ToString("yyyy-MM-dd HH:mm:ss"), DbType.String, ParameterDirection.Input)
                                  , helper.CreateParameter("P_PRD_END_DATE", dNowEndDate.ToString("yyyy-MM-dd HH:mm:ss"), DbType.String, ParameterDirection.Input)
                                  , helper.CreateParameter("P_MATNR", sMTANR, DbType.String, ParameterDirection.Input)
                                  , helper.CreateParameter("P_PROC_CD", Common.OpCode, DbType.String, ParameterDirection.Input)
                                  , helper.CreateParameter("P_PRFM_QTY", lblProdQty.Text.Replace(",", ""), DbType.String, ParameterDirection.Input)
                                  , helper.CreateParameter("P_DISPO_QTY", lblDispoQty.Text.Replace(",", ""), DbType.String, ParameterDirection.Input)
                                  , helper.CreateParameter("P_PRFM_DOC", DbType.String, ParameterDirection.Output, null, 30)
                                  , helper.CreateParameter("P_DISPO_DOC", DbType.String, ParameterDirection.Output, null, 30)
                                  , helper.CreateParameter("P_WRK_FUNC", DbType.String, ParameterDirection.Output, null, 30)
                                  , helper.CreateParameter("P_DISPO_FUNC", DbType.String, ParameterDirection.Output, null, 30)
                                  );

                        if (helper.RSCODE == "E")
                        {
                            this.Cursor = Cursors.WaitCursor;   //Waitting
                            new POPUP.MessageForm("폐품등록에 실패 하였습니다.\n" + helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                            helper.Rollback();
                            return;
                        }
                        else
                        {
                            //실적, 폐품 문서번호
                            sPRFM_DOC = helper.Parameters["P_PRFM_DOC"].Value.ToString();
                            sDISPO_DOC = helper.Parameters["P_DISPO_DOC"].Value.ToString();
                            //실적, 폐품 SAP기능
                            sPRFM_FUNC = helper.Parameters["P_WRK_FUNC"].Value.ToString();
                            sDISPO_FUNC = helper.Parameters["P_DISPO_FUNC"].Value.ToString();
                            //폐품 전송 Data
                            dtTemp = dsTemp.Tables[0].Copy();
                            dsDISPO.Tables.Add(dtTemp);
                            dtTemp = dsTemp.Tables[1].Copy();
                            dsDISPO.Tables.Add(dtTemp);
                            //실적 전송 Data
                            if (dsTemp.Tables.Count > 2)
                            {
                                dtTemp = dsTemp.Tables[2].Copy();
                                dsPRFM.Tables.Add(dtTemp);
                                dtTemp = dsTemp.Tables[3].Copy();
                                dsPRFM.Tables.Add(dtTemp);
                            }
                        }
                    }

                    //작업시작/완료처리 (작업지시 상태변경 및 작업장 현황의 가동상태 변경)
                    dsTemp = helper.FillDataSetN("SP_POP_WRK41_U01", CommandType.StoredProcedure, 2
                                  , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)
                                  , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)
                                  , helper.CreateParameter("P_IOTYPE", Common.IOType, DbType.String, ParameterDirection.Input)
                                  , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input)
                                  , helper.CreateParameter("P_ORDER_NO", sORDER_NO, DbType.String, ParameterDirection.Input)
                                  , helper.CreateParameter("P_WRK_ORDR_NO", sWRK_ORDER_NO, DbType.String, ParameterDirection.Input)
                                  , helper.CreateParameter("P_WRK_ORDR_SEQNO", sWRK_ORDER_SEQNO, DbType.String, ParameterDirection.Input)
                                  , helper.CreateParameter("P_PRD_STR_DATE", dNowStartDate.ToString("yyyy-MM-dd HH:mm:ss"), DbType.String, ParameterDirection.Input)
                                  , helper.CreateParameter("P_PRD_END_DATE", dNowEndDate.ToString("yyyy-MM-dd HH:mm:ss"), DbType.String, ParameterDirection.Input)
                                  , helper.CreateParameter("P_NEW_ORDER_NO", sNEW_ORDER_NO, DbType.String, ParameterDirection.Input)
                                  , helper.CreateParameter("P_NEW_WRK_ORDR_NO", sNEW_WRK_ORDER_NO, DbType.String, ParameterDirection.Input)
                                  , helper.CreateParameter("P_NEW_WRK_ORDR_SEQNO", sNEW_WRK_ORDER_SEQNO, DbType.String, ParameterDirection.Input)
                                  , helper.CreateParameter("P_NEW_PRD_STR_DATE", dNewStartDate.ToString("yyyy-MM-dd HH:mm:ss"), DbType.String, ParameterDirection.Input)
                                  , helper.CreateParameter("P_MATNR", sMTANR, DbType.String, ParameterDirection.Input)
                                  , helper.CreateParameter("P_NEW_MATNR", sMTANRN, DbType.String, ParameterDirection.Input)
                                  , helper.CreateParameter("P_PROC_CD", Common.OpCode, DbType.String, ParameterDirection.Input)
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
                    //프로시저 결과 저장
                    helper.Commit();
                    if (!string.IsNullOrEmpty(lblDispoQty.Text) && !lblDispoQty.Text.Equals("0"))
                    {
                        //폐품 실적 취소
                        SAPHelper sapRFC_DC = new SAPHelper();
                        SAPHelper sapRFC_PC = new SAPHelper();
                        //폐품 실적 등록
                        SAPHelper sapRFC_P = new SAPHelper();
                        SAPHelper sapRFC_E = new SAPHelper();

                        #region
                        ////기존 이력 존재시 취소처리
                        //if (!string.IsNullOrEmpty(sDISPO_CNL_FUNC))
                        //{
                        //    if (!sapRFC_DC.CallSAPFunc(sDISPO_CNL_FUNC, dsDISPO_CNL.Tables[0], dsDISPO_CNL.Tables[1], helper).Equals("S"))
                        //    {
                        //        sapRFC_DC.SaveResulttoWrk(helper, "POP_WRK041", "0");
                        //    }
                        //    else
                        //    {
                        //        this.Cursor = Cursors.WaitCursor;   //Waitting
                        //        new POPUP.MessageForm("폐품취소 SAP전송이 실패하였습니다.\n" + sapRFC_DC.rtnMSG, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                        //        return;
                        //    }
                        //    if (!sapRFC_PC.CallSAPFunc(sPRFM_CNL_FUNC, dsPRFM_CNL.Tables[0], dsPRFM_CNL.Tables[1], helper).Equals("S"))
                        //    {
                        //        sapRFC_PC.SaveResulttoWrk(helper, "POP_WRK041", "0");
                        //    }
                        //    else
                        //    {
                        //        this.Cursor = Cursors.WaitCursor;   //Waitting
                        //        new POPUP.MessageForm("폐품실적취소 SAP전송이 실패하였습니다.\n" + sapRFC_PC.rtnMSG, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                        //        return;
                        //    }
                        //}
                        #endregion

                        //폐품등록시 실적등록
                        if (!string.IsNullOrEmpty(sPRFM_DOC))
                        {
                            if (!sapRFC_P.CallSAPFunc_EX(sPRFM_FUNC, dsPRFM.Tables[0], dsPRFM.Tables[1], helper, "AUFNR", string.Empty).Equals("E"))
                            {
                                sapRFC_P.SaveResulttoWrk(helper, "POP_WRK041", "0");
                            }
                            else
                            {
                                this.Cursor = Cursors.WaitCursor;   //Waitting
                                new POPUP.MessageForm("폐품등록을 위한 실적정보의 SAP전송이 실패하였습니다.\n" + sapRFC_P.rtnMSG, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                return;
                            }
                        }
                        //폐품등록
                        if (!string.IsNullOrEmpty(sDISPO_DOC))
                        {
                            if (sapRFC_E.CallSAPFunc_EX(sDISPO_FUNC, dsDISPO.Tables[0], dsDISPO.Tables[1], helper, "", sapRFC_P.rtnPAUFNR).Equals("S"))
                            {
                                sapRFC_E.SaveResulttoWrk(helper, "POP_WRK041", "4");
                            }
                            else
                            {
                                this.Cursor = Cursors.WaitCursor;   //Waitting
                                new POPUP.MessageForm("폐품이력 SAP전송이 실패하였습니다.\n" + sapRFC_E.rtnMSG, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                return;
                            }
                        }
                    }

                    //생산오더 완료실적
                    if (!string.IsNullOrEmpty(sORDER_DOC))
                    {
                        //SAP 오더완료 실적 등록
                        SAPHelper sapRFC_O = new SAPHelper();
                        if (!sapRFC_O.CallSAPFunc(sORDER_FUNC, dsORDER.Tables[0], dsORDER.Tables[1], helper).Equals("S"))
                        {
                            this.Cursor = Cursors.WaitCursor;   //Waitting
                            new POPUP.MessageForm("오더완료 SAP전송이 실패하였습니다.\n" + sapRFC_O.rtnMSG, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                            return;
                        }
                    }

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

        private void doConfirm_End()
        {
            DBHelper helper = new DBHelper(false, "", true);

            DataSet dsTemp;
            DataTable dtTemp;

            string sMSG = string.Empty;

            POPUP.MessageForm msgForm = null;
            DialogResult res = DialogResult.Cancel;

            string sORDER_NO = drNowWrk == null ? string.Empty : drNowWrk["ORDER_NO"].ToString(); //기존지시 생산오더
            string sWRK_ORDER_NO = lblOrderNo.Text; //기존작업지시
            string sWRK_ORDER_SEQNO = lblOrderSeq.Text; //기존작업지시순번
            string sNEW_ORDER_NO = string.Empty; //신규지시 생산오더
            string sNEW_WRK_ORDER_NO = string.Empty; //신규작업지시
            string sNEW_WRK_ORDER_SEQNO = string.Empty; //신규작업지시순번
            string sMTANR = drNowWrk == null ? string.Empty : lblItemCode.Tag.ToString(); //기존 품목 코드
            string sMTANRN = string.Empty; //신규 품목 코드
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

            dNowStartDate = Common.makeDateTime(dtpStartDate.Value, lblStartTime.Text);
            dNowEndDate = Common.makeDateTime(dtpEndDate.Value, lblEndTime.Text);
            dNewStartDate = Common.makeDateTime(dtpStartDateN.Value, lblStartTimeN.Text);

            try
            {
                if ((!string.IsNullOrEmpty(lblStartTime.Text) && !string.IsNullOrEmpty(lblStartTime.Text))
                        && (dNowStartDate >= dNowEndDate || dNowEndDate > dNewStartDate))
                {
                    new POPUP.MessageForm("작업시간을 확인하여 주시기 바랍니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                }
                else
                {
                    if (dNowPRFMQty == 0.0)
                    {
                        msgForm = new POPUP.MessageForm("현재 지시의 실적이 등록되지 않았습니다.\n지시를 변경하시겠습니까?", MessageBoxButtons.OKCancel, "알   림");
                        res = msgForm.ShowDialog(this);
                        if (res != System.Windows.Forms.DialogResult.OK)
                            return;
                    }
                    //이전 지시의 실적 존재시 폐품 수량입력 필수
                    else
                    {
                        if (lblDispoQty.Visible)
                        {
                            if (int.TryParse(lblDispoQty.Text.Replace(",", ""), out iDispoQty))
                            {
                                if (iDispoQty == 0)
                                {
                                    //new POPUP.MessageForm("폐품수량을 확인하여 주시기 바랍니다.\n" + helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                    //return;
                                    msgForm = new POPUP.MessageForm("폐품수량이 0으로 입력되었습니다.\n진행하시겠습니까?", MessageBoxButtons.OKCancel, "알   림");
                                    res = msgForm.ShowDialog(this);
                                    if (res != System.Windows.Forms.DialogResult.OK)
                                        return;
                                }
                            }
                            else
                            {
                                new POPUP.MessageForm("폐품수량을 확인하여 주시기 바랍니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                return;
                            }
                        }
                    }

                    this.Cursor = Cursors.WaitCursor;   //Waitting
                    //폐품수량 등록
                    if (!string.IsNullOrEmpty(lblDispoQty.Text) && !lblDispoQty.Text.Equals("0"))
                    {
                        //폐품 이력 등록
                        dsTemp = helper.FillDataSetN("SP_POP_WRK41_D01", CommandType.StoredProcedure, 4
                                  , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)
                                  , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)
                                  , helper.CreateParameter("P_IOTYPE", Common.IOType, DbType.String, ParameterDirection.Input)
                                  , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input)
                                  , helper.CreateParameter("P_ORDER_NO", sORDER_NO, DbType.String, ParameterDirection.Input)
                                  , helper.CreateParameter("P_WRK_ORDR_NO", sWRK_ORDER_NO, DbType.String, ParameterDirection.Input)
                                  , helper.CreateParameter("P_WRK_ORDR_SEQNO", sWRK_ORDER_SEQNO, DbType.String, ParameterDirection.Input)
                                  , helper.CreateParameter("P_PRD_STR_DATE", dNowStartDate.ToString("yyyy-MM-dd HH:mm:ss"), DbType.String, ParameterDirection.Input)
                                  , helper.CreateParameter("P_PRD_END_DATE", dNowEndDate.ToString("yyyy-MM-dd HH:mm:ss"), DbType.String, ParameterDirection.Input)
                                  , helper.CreateParameter("P_MATNR", sMTANR, DbType.String, ParameterDirection.Input)
                                  , helper.CreateParameter("P_PROC_CD", Common.OpCode, DbType.String, ParameterDirection.Input)
                                  , helper.CreateParameter("P_PRFM_QTY", lblProdQty.Text.Replace(",", ""), DbType.String, ParameterDirection.Input)
                                  , helper.CreateParameter("P_DISPO_QTY", lblDispoQty.Text.Replace(",", ""), DbType.String, ParameterDirection.Input)
                                  , helper.CreateParameter("P_PRFM_DOC", DbType.String, ParameterDirection.Output, null, 30)
                                  , helper.CreateParameter("P_DISPO_DOC", DbType.String, ParameterDirection.Output, null, 30)
                                  , helper.CreateParameter("P_WRK_FUNC", DbType.String, ParameterDirection.Output, null, 30)
                                  , helper.CreateParameter("P_DISPO_FUNC", DbType.String, ParameterDirection.Output, null, 30)
                                  );

                        if (helper.RSCODE == "E")
                        {
                            this.Cursor = Cursors.WaitCursor;   //Waitting
                            new POPUP.MessageForm("폐품등록에 실패 하였습니다.\n" + helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                            helper.Rollback();
                            return;
                        }
                        else
                        {
                            //실적, 폐품 문서번호
                            sPRFM_DOC = helper.Parameters["P_PRFM_DOC"].Value.ToString();
                            sDISPO_DOC = helper.Parameters["P_DISPO_DOC"].Value.ToString();
                            //실적, 폐품 SAP기능
                            sPRFM_FUNC = helper.Parameters["P_WRK_FUNC"].Value.ToString();
                            sDISPO_FUNC = helper.Parameters["P_DISPO_FUNC"].Value.ToString();
                            //폐품 전송 Data
                            dtTemp = dsTemp.Tables[0].Copy();
                            dsDISPO.Tables.Add(dtTemp);
                            dtTemp = dsTemp.Tables[1].Copy();
                            dsDISPO.Tables.Add(dtTemp);
                            //실적 전송 Data
                            if (dsTemp.Tables.Count > 2)
                            {
                                dtTemp = dsTemp.Tables[2].Copy();
                                dsPRFM.Tables.Add(dtTemp);
                                dtTemp = dsTemp.Tables[3].Copy();
                                dsPRFM.Tables.Add(dtTemp);
                            }
                        }
                    }

                    //작업시작/완료처리 (작업지시 상태변경 및 작업장 현황의 가동상태 변경)
                    dsTemp = helper.FillDataSetN("SP_POP_WRK41_U02", CommandType.StoredProcedure, 2
                                  , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)
                                  , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)
                                  , helper.CreateParameter("P_IOTYPE", Common.IOType, DbType.String, ParameterDirection.Input)
                                  , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input)
                                  , helper.CreateParameter("P_ORDER_NO", sORDER_NO, DbType.String, ParameterDirection.Input)
                                  , helper.CreateParameter("P_WRK_ORDR_NO", sWRK_ORDER_NO, DbType.String, ParameterDirection.Input)
                                  , helper.CreateParameter("P_WRK_ORDR_SEQNO", sWRK_ORDER_SEQNO, DbType.String, ParameterDirection.Input)
                                  , helper.CreateParameter("P_PRD_STR_DATE", dNowStartDate.ToString("yyyy-MM-dd HH:mm:ss"), DbType.String, ParameterDirection.Input)
                                  , helper.CreateParameter("P_PRD_END_DATE", dNowEndDate.ToString("yyyy-MM-dd HH:mm:ss"), DbType.String, ParameterDirection.Input)
                                  , helper.CreateParameter("P_NEW_ORDER_NO", sNEW_ORDER_NO, DbType.String, ParameterDirection.Input)
                                  , helper.CreateParameter("P_NEW_WRK_ORDR_NO", sNEW_WRK_ORDER_NO, DbType.String, ParameterDirection.Input)
                                  , helper.CreateParameter("P_NEW_WRK_ORDR_SEQNO", sNEW_WRK_ORDER_SEQNO, DbType.String, ParameterDirection.Input)
                                  , helper.CreateParameter("P_NEW_PRD_STR_DATE", dNewStartDate.ToString("yyyy-MM-dd HH:mm:ss"), DbType.String, ParameterDirection.Input)
                                  , helper.CreateParameter("P_MATNR", sMTANR, DbType.String, ParameterDirection.Input)
                                  , helper.CreateParameter("P_NEW_MATNR", sMTANRN, DbType.String, ParameterDirection.Input)
                                  , helper.CreateParameter("P_PROC_CD", Common.OpCode, DbType.String, ParameterDirection.Input)
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
                    //프로시저 결과 저장
                    helper.Commit();
                    if (!string.IsNullOrEmpty(lblDispoQty.Text) && !lblDispoQty.Text.Equals("0"))
                    {
                        //폐품 실적 취소
                        SAPHelper sapRFC_DC = new SAPHelper();
                        SAPHelper sapRFC_PC = new SAPHelper();
                        //폐품 실적 등록
                        SAPHelper sapRFC_P = new SAPHelper();
                        SAPHelper sapRFC_E = new SAPHelper();


                        //폐품등록시 실적등록
                        if (!string.IsNullOrEmpty(sPRFM_DOC))
                        {
                            if (!sapRFC_P.CallSAPFunc_EX(sPRFM_FUNC, dsPRFM.Tables[0], dsPRFM.Tables[1], helper, "AUFNR", string.Empty).Equals("E"))
                            {
                                sapRFC_P.SaveResulttoWrk(helper, "POP_WRK041", "0");
                            }
                            else
                            {
                                this.Cursor = Cursors.WaitCursor;   //Waitting
                                new POPUP.MessageForm("폐품등록을 위한 실적정보의 SAP전송이 실패하였습니다.\n" + sapRFC_P.rtnMSG, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                return;
                            }
                        }
                        //폐품등록
                        if (!string.IsNullOrEmpty(sDISPO_DOC))
                        {
                            if (sapRFC_E.CallSAPFunc_EX(sDISPO_FUNC, dsDISPO.Tables[0], dsDISPO.Tables[1], helper, "", sapRFC_P.rtnPAUFNR).Equals("S"))
                            {
                                sapRFC_E.SaveResulttoWrk(helper, "POP_WRK041", "4");
                            }
                            else
                            {
                                this.Cursor = Cursors.WaitCursor;   //Waitting
                                new POPUP.MessageForm("폐품이력 SAP전송이 실패하였습니다.\n" + sapRFC_E.rtnMSG, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                return;
                            }
                        }
                    }

                    //생산오더 완료실적
                    if (!string.IsNullOrEmpty(sORDER_DOC))
                    {
                        //SAP 오더완료 실적 등록
                        SAPHelper sapRFC_O = new SAPHelper();
                        if (!sapRFC_O.CallSAPFunc(sORDER_FUNC, dsORDER.Tables[0], dsORDER.Tables[1], helper).Equals("S"))
                        {
                            this.Cursor = Cursors.WaitCursor;   //Waitting
                            new POPUP.MessageForm("오더완료 SAP전송이 실패하였습니다.\n" + sapRFC_O.rtnMSG, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                            return;
                        }
                    }

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
                        if(bEndFlag)
                            doConfirm_End();
                        else
                            doConfirm();
                        break;

                    case "Close": //이전화면
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
                LogFile.WriteLog("POP_WRK41.bBox1_buttonClickEvent Error\r\n" + ex.Message);
            }
            finally
            {

            }
        }

        private void butStartDate_Click(object sender, EventArgs e)
        {
            string tempDate = string.Empty;

            DAResultDate pop = new DAResultDate(dtpStartDate.Value);
            pop.ShowDialog(this);
            if (pop.DialogResult == DialogResult.OK)
            {
                tempDate = pop.ResultString.ToString();
                dtpStartDate.Value = DateTime.Parse(tempDate);
            }
        }

        private void butEndDate_Click(object sender, EventArgs e)
        {
            string tempDate = string.Empty;

            DAResultDate pop = new DAResultDate(dtpEndDate.Value);
            pop.ShowDialog(this);
            if (pop.DialogResult == DialogResult.OK)
            {
                tempDate = pop.ResultString.ToString();
                dtpEndDate.Value = DateTime.Parse(tempDate);
                //이전작업 완료시간 입력시 신규지시 시작시간 연동
                dtpStartDateN.Value = dtpEndDate.Value;
            }
        }

        private void butStartDateN_Click(object sender, EventArgs e)
        {
            string tempDate = string.Empty;

            DAResultDate pop = new DAResultDate(dtpStartDateN.Value);
            pop.ShowDialog(this);
            if (pop.DialogResult == DialogResult.OK)
            {
                tempDate = pop.ResultString.ToString();
                dtpStartDateN.Value = DateTime.Parse(tempDate);
            }
        }

        private void lblWorkTime_Click(object sender, EventArgs e)
        {
            MESLabel lblTemp = (MESLabel)sender;
            DateTime dNowStartDate;
            DateTime dNowEndDate;

            DAResultTime pop = new DAResultTime();
            pop.ShowDialog(this);
            if (pop.DialogResult == DialogResult.OK)
            {
                lblTemp.Text = pop.ResultString.ToString();
                //이전작업 완료시간 입력시 신규지시 시작시간 연동
                if (lblTemp.Name.ToString().Equals("lblEndTime"))
                {
                    dNowStartDate = Common.makeDateTime(dtpStartDate.Value, lblStartTime.Text);
                    dNowEndDate = Common.makeDateTime(dtpEndDate.Value, lblEndTime.Text);
                    if (dNowStartDate >= dNowEndDate)
                    {
                        new POPUP.MessageForm("작업시간을 확인하여 주시기 바랍니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                        return;
                    }

                    lblStartTimeN.Text = lblEndTime.Text;
                }
            }
        }

        private void lblQty_Click(object sender, EventArgs e)
        {
            //호출한 항목
            MESLabel tempLabel = (MESLabel)sender;
            double dDimension = 0;
            double dTotal;//총 생산 수량
            double dProd;//실적 수량

            //입력불가상태인 경우 복귀(배경색으로 구분)
            if (tempLabel.BackColor == Color.LightGray)
                return;

            DAResultQty pop = new DAResultQty();
            //화장지 생리대에 따라 제목 수정
            if (drNowWrk["PRODTYPE"].ToString().Equals("T"))
            {
                pop.LabelTitle = "중량 입력";
                pop.LabelHeader = "중량(Kg)";
            }
            else
            {
                pop.LabelTitle = "수량 입력";
                pop.LabelHeader = "수량";
            }
            pop.ContentMaxLength = 8;

            pop.ShowDialog(this);

            if (pop.DialogResult == DialogResult.OK)
            {
                //선택된 항목 수량 등록
                dDimension = pop.ResultDouble;
                tempLabel.Text = string.Format("{0:#,0}", dDimension);
                //계산된 수량처리(생리대)
                if (drNowWrk["PRODTYPE"].ToString().Equals("P") && tempLabel.Name.Equals("lblTotalQty"))
                {
                    if (double.TryParse(lblTotalQty.Text.Replace(",", ""), out dTotal))
                    {
                        if (double.TryParse(lblProdQty.Text.Replace(",", ""), out dProd))
                        {
                            lblDispoQty.Text = string.Format("{0:#,##0}", (dTotal - dProd));
                        }
                    }
                }
                else if (drNowWrk["PRODTYPE"].ToString().Equals("P") && tempLabel.Name.Equals("lblDispoQty"))
                {
                    if (double.TryParse(lblDispoQty.Text.Replace(",", ""), out dTotal))
                    {
                        if (double.TryParse(lblProdQty.Text.Replace(",", ""), out dProd))
                        {
                            lblTotalQty.Text = string.Format("{0:#,##0}", (dTotal + dProd));
                        }
                    }
                }
            }
        }

        private void dtpDate_DropDown(object sender, EventArgs e)
        {
            CommonCalendar.CloseCalendar((DateTimePicker)sender);
        }
        #endregion

    }
}
