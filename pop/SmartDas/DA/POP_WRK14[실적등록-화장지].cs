#region [ USING AREA ]
using System;
using System.Configuration;
using System.Data;
using System.Windows.Forms;
using System.Drawing;


using SAMMI;
using SmartDas.Components;
using SmartDas.POPUP;
using System.Threading;
using Oracle.ManagedDataAccess.Client;
using System.Data.Common;


#endregion

namespace SmartDas
{
    public partial class POP_WRK14 : BaseForm
    {
        #region < MEMBER AREA >
        private string sStartTime = string.Empty;

        private SAMMI.Common _common = new SAMMI.Common();

        private DataTable dtNowWrk;
        //private double dDimension = 0;
        private int iPLT2BOX = 0;
        private int iBOXCNT = 0;

        #endregion

        #region < CONSTRUCTOR >

        public POP_WRK14()
        {
            InitializeComponent();

            Common.SetMessageList();
            this.UpdateMinuteEvent += new UpdateMinuteHandler(Common.dailyLotChange);
        }
        public POP_WRK14(DataTable pNowWrkOrder)
        {
            InitializeComponent();

            Common.SetMessageList();
            this.UpdateMinuteEvent += new UpdateMinuteHandler(Common.dailyLotChange);

            dtNowWrk = pNowWrkOrder;
        }
        #endregion

        #region < POP_WRK14_Load >
        private void POP_WRK14_Load(object sender, EventArgs e)
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

                this.lblTitle.Text = "화장지 실적등록";

                lblEndChk.Text = "";

                SetMenuButtons();
                DoFind();
            }
            catch (Exception ex)
            {
                SetMessage("POP_WRK14_Load_ Error!");
                LogFile.WriteLog("POP_WRK14.POP_WRK14_Load Error\r\n" + ex.Message);
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

                bBox1[0, 0].Text = "실적등록";
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
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                LogFile.WriteLog("POP_WRK14.SetButtons Error\r\n" + ex.Message);
            }
        }

        private void DoFind()
        {
            int iTempValue;
            int iBoxinPLT;

            try
            {
                if (dtNowWrk.Rows.Count < 1)
                {
                    SetMessage("조회된 작업지시가 없습니다.");
                    return;
                }
                else
                {
                    lblPRD_REQ_DT.Text = Common.dateFormat("O", dtNowWrk.Rows[0]["PRD_REQ_DT"].ToString());//생산지시일
                    lblWRK_ORDR_NO.Text = dtNowWrk.Rows[0]["WRK_ORDR_NO"].ToString();//작업지시번호
                    lblWRK_ORDR_SEQNO.Text = dtNowWrk.Rows[0]["WRK_ORDR_SEQNO"].ToString();//작업지시순번
                    lblMATNR.Tag = dtNowWrk.Rows[0]["MATNR"].ToString(); //자재코드
                    lblMATNR.Text = dtNowWrk.Rows[0]["MATNR_NM"].ToString(); //자재명
                    lblMATNR_SPEC.Text = dtNowWrk.Rows[0]["PCODE"].ToString(); //지종
                    lblMATNR_SPEC.Text = dtNowWrk.Rows[0]["MATNR_SPEC"].ToString(); //규격
                    lblWRK_ORDR_RMK.Text = dtNowWrk.Rows[0]["WRK_ORDR_RMK"].ToString(); //작업지시사항

                    #region 계획수량
                    //팔레트 계획
                    if (int.TryParse(dtNowWrk.Rows[0]["PLTORDR"].ToString(), out iTempValue))
                        lblPLT_QTY.Text = iTempValue >= 0 ? string.Format("{0:#,##0}", iTempValue) : string.Empty; //실적량
                    else
                        lblPLT_QTY.Text = dtNowWrk.Rows[0]["PLTORDR"].ToString();
                    //박스 계획
                    if (int.TryParse(dtNowWrk.Rows[0]["BOXORDR"].ToString(), out iTempValue))
                        lblBOX_QTY.Text = iTempValue >= 0 ? string.Format("{0:#,##0}", iTempValue) : string.Empty; //실적량
                    else
                        lblBOX_QTY.Text = dtNowWrk.Rows[0]["BOXORDR"].ToString();
                    //폴리백 계획
                    if (int.TryParse(dtNowWrk.Rows[0]["BAGORDR"].ToString(), out iTempValue))
                        lblBAG_QTY.Text = iTempValue >= 0 ? string.Format("{0:#,##0}", iTempValue) : string.Empty; //실적량
                    else
                        lblBAG_QTY.Text = dtNowWrk.Rows[0]["BAGORDR"].ToString();
                    //개수 계획
                    if (int.TryParse(dtNowWrk.Rows[0]["EAORDR"].ToString(), out iTempValue))
                        lblEA_QTY.Text = iTempValue >= 0 ? string.Format("{0:#,##0}", iTempValue) : string.Empty; //실적량
                    else
                        lblEA_QTY.Text = dtNowWrk.Rows[0]["EAORDR"].ToString();
                    #endregion

                    #region 실적수량
                    //팔레트 실적
                    if (int.TryParse(dtNowWrk.Rows[0]["PLTQTY"].ToString(), out iTempValue))
                        lblTOT_PLT.Text = iTempValue >= 0 ? string.Format("{0:#,##0}", iTempValue) : string.Empty; //실적량
                    else
                        lblTOT_PLT.Text = dtNowWrk.Rows[0]["PLTQTY"].ToString();
                    //박스 실적
                    if (int.TryParse(dtNowWrk.Rows[0]["BOXQTY"].ToString(), out iTempValue))
                        lblTOT_BOX.Text = iTempValue >= 0 ? string.Format("{0:#,##0}", iTempValue) : string.Empty; //실적량
                    else
                        lblTOT_BOX.Text = dtNowWrk.Rows[0]["BOXQTY"].ToString();
                    //폴리백 실적
                    if (int.TryParse(dtNowWrk.Rows[0]["BAGQTY"].ToString(), out iTempValue))
                        lblTOT_BAG.Text = iTempValue >= 0 ? string.Format("{0:#,##0}", iTempValue) : string.Empty; //실적량
                    else
                        lblTOT_BAG.Text = dtNowWrk.Rows[0]["BAGQTY"].ToString();
                    //개수 실적
                    if (int.TryParse(dtNowWrk.Rows[0]["EAQTY"].ToString(), out iTempValue))
                        lblTOT_EA.Text = iTempValue >= 0 ? string.Format("{0:#,##0}", iTempValue) : string.Empty; //실적량
                    else
                        lblTOT_EA.Text = dtNowWrk.Rows[0]["EAQTY"].ToString();
                    #endregion

                    #region 실적 초기정보
                    int.TryParse(dtNowWrk.Rows[0]["PLT2BOX"].ToString(), out iBoxinPLT);
                    lblPRFM_BOX.Text = iBoxinPLT.ToString();
                    //팔레트
                    lblPRFM_PLT.Text = string.Format("{0:#,##0}", Common.GetChangeUnit(dtNowWrk.Rows[0]["PLT_RATE"].ToString(), iBoxinPLT));
                    //폴리백
                    lblPRFM_BAG.Text = string.Format("{0:#,##0}", Common.GetChangeUnit(dtNowWrk.Rows[0]["BAG_RATE"].ToString(), iBoxinPLT));
                    //개수
                    lblPRFM_EA.Text = string.Format("{0:#,##0}", Common.GetChangeUnit(dtNowWrk.Rows[0]["EA_RATE"].ToString(), iBoxinPLT));
                    #endregion

                    //팔레트당 박스 수량 (조회 실패시 0으로 입력하여 등록제한)
                    if (!int.TryParse(dtNowWrk.Rows[0]["PLT2BOX"].ToString(), out iPLT2BOX))
                        iPLT2BOX = 0;

                    lblPRFM_DATE.Text = Common.dateFormat("O", Common.GetRecDate(DateTime.Now));
                }
            }
            catch (Exception ex)
            {
                SetMessage("doFind Error!");
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                LogFile.WriteLog("POP_WRK08.WRK_ORDER Find Error\r\n" + ex.Message);
            }
        }

        private void doConfirm()
        {
            DataSet dsTemp; //실적등록 결과 수신(0:라벨정보, 1:RFC 변수, 2:RFC 상세변수)
            int iTempQty = 0;
            string sCompflag = "N";

            try
            {
                if (iPLT2BOX == 0)
                {
                    new POPUP.MessageForm("팔레트별 박스수량을 확인하여 주시기 바랍니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return;
                }
                if (!int.TryParse(lblPRFM_BOX.Text.Replace(",", ""), out iBOXCNT))
                {
                    new POPUP.MessageForm("입력한 박스수량을 확인하여 주시기 바랍니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return;
                }

                //등록 수량이 남은 경우
                while (iBOXCNT > 0)
                {
                    DBHelper helper = new DBHelper(false, "", true);

                    try
                    {
                        //잔여수량이 팔레트 단위수량보다 많은 경우 단위수량 사용
                        //잔여수량이 단위수량보다 적은 경우 잔량을 사용
                        if (iBOXCNT > iPLT2BOX)
                        {
                            iTempQty = iPLT2BOX;
                        }
                        else
                        {
                            iTempQty = iBOXCNT;
                            //마지막 생산 체크후 마지막 팔레트시 완료상태 등록
                            if (lblEndChk.Text.Equals("V"))
                                sCompflag = "Y";
                        }

                        dsTemp = helper.FillDataSetN("SP_POP_WRK14_I01", CommandType.StoredProcedure, 1
                                 , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)
                                 , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)
                                 , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input)
                                 , helper.CreateParameter("P_ORDER_NO", Common.OrderNo, DbType.String, ParameterDirection.Input)
                                 , helper.CreateParameter("P_WRK_ORDR_NO", Common.WrkOrderNo, DbType.String, ParameterDirection.Input)
                                 , helper.CreateParameter("P_WRK_ORDR_SEQNO", Common.WrkOrderSeq, DbType.String, ParameterDirection.Input)
                                 , helper.CreateParameter("P_MATNR", Common.ItemCode, DbType.String, ParameterDirection.Input)
                                 , helper.CreateParameter("P_PRFM_QTY", iTempQty.ToString(), DbType.String, ParameterDirection.Input)
                                 , helper.CreateParameter("P_PRFM_DT", lblPRFM_DATE.Text, DbType.String, ParameterDirection.Input)
                                 , helper.CreateParameter("P_COMP_YN", sCompflag, DbType.String, ParameterDirection.Input)
                                   );

                        if (helper.RSCODE == "E")
                        {
                            helper.Rollback();
                            new POPUP.MessageForm(helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                            return;
                        }
                        else if (helper.RSCODE == "N")
                        {
                            helper.Rollback();
                            new POPUP.MessageForm("자재의 수량이 부족합니다.\n" + helper.RSMSG.ToString() + "\n가공파트에 자재투입을 의뢰하세요.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                            return;
                        }
                        else
                        {
                            //현재 팔레트 완료처리
                            helper.Commit();
                            //라벨 출력
                            doPrint(dsTemp.Tables[0]);
                            //등록 및 출력된 수량 차감
                            iBOXCNT = iBOXCNT - iPLT2BOX;
                            System.Threading.Thread.Sleep(1000);
                        }
                    }
                    catch (Exception ex)
                    {
                        helper.Rollback();
                        new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                        return;
                    }
                    finally
                    {
                        helper.Close();
                    }
                }

                new POPUP.MessageForm("실적이 정상적으로 등록되었습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
            }
            catch (Exception ex)
            {
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
            }
            finally
            {
                this.Close();
            }
        }

        private void doConfirm_AGV()
        {
            //step1.MES 실적등록 & WMS 입고요청
            //step1_2.라벨발행
            //step2.SAP 실적등록
            //step3.WMS 입고
            //step4.SAP 재고이전
            //step5.WCS호출(3, 6호기만)

            DataSet dsTemp; //실적등록 결과 수신(0:라벨정보, 1:RFC 변수, 2:RFC 상세변수)
            int iTempQty = 0;
            string sCompflag = "N";
            string sResult = string.Empty;
            string sRtnMessage = string.Empty;
            string sRtnCode = string.Empty;
            string sDOC_TRANS = string.Empty;
            string sDOC_WMS = string.Empty;
            string sMOVE_FUNC = string.Empty;
            string sPRFM_FUNC = string.Empty;
            string sMATNR_NM = string.Empty;
            string sIND_BCD = string.Empty;

            string rollbackType = string.Empty;

            #region DB(MES, WMS) 롤백용 추가 
            DataTable rbTemp = new DataTable(); // 성공한 sap 정보 저장
            rbTemp.Columns.Add("IND_BCD", typeof(string));
            rbTemp.Columns.Add("DOC_NO_TRANS", typeof(string));
            rbTemp.Columns.Add("DOC_NO_WMS", typeof(string));
            #endregion

            try
            {
                if (iPLT2BOX == 0)
                {
                    new POPUP.MessageForm("팔레트별 박스수량을 확인하여 주시기 바랍니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return;
                }
                if (!int.TryParse(lblPRFM_BOX.Text.Replace(",", ""), out iBOXCNT))
                {
                    new POPUP.MessageForm("입력한 박스수량을 확인하여 주시기 바랍니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return;
                }

                //등록 수량이 남은 경우
                while (iBOXCNT > 0)
                {
                    DBHelper helper = new DBHelper(false, "", true);
                    bool bReturn_PRFM = false, bReturn_MOVE = false; //실적, 재고이전
                    bool wcsCallTF = true;
                    DataTable sapTemp = new DataTable(); // 성공한 sap 정보 저장
                    string sMSG_ERR = "";
                    string sWrkList;

                    try
                    {
                        //잔여수량이 팔레트 단위수량보다 많은 경우 단위수량 사용
                        //잔여수량이 단위수량보다 적은 경우 잔량을 사용
                        if (iBOXCNT > iPLT2BOX)
                        {
                            iTempQty = iPLT2BOX;
                        }
                        else
                        {
                            iTempQty = iBOXCNT;
                            //마지막 생산 체크후 마지막 팔레트시 완료상태 등록
                            if (lblEndChk.Text.Equals("V"))
                                sCompflag = "Y";
                        }

                        //3호기, 6호기만 WCS 호출
                        if ("TRA03".Equals(Common.MachineCode) | "TRA06".Equals(Common.MachineCode))
                        {
                            if (DialogResult.No == MessageBoxShow("무인지게차 호출 하시겠습니까?", MessageBoxButtons.YesNo))
                            {
                                wcsCallTF = false;
                            }
                        }

                        //step1.MES 실적등록 오류
                        rollbackType = "DELETE_workMes_RB";

                        //step1.MES 실적등록
                        dsTemp = helper.FillDataSetN("SP_POP_WRK14_I01", CommandType.StoredProcedure, 1
                                 , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)
                                 , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)
                                 , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input)
                                 , helper.CreateParameter("P_ORDER_NO", Common.OrderNo, DbType.String, ParameterDirection.Input)
                                 , helper.CreateParameter("P_WRK_ORDR_NO", Common.WrkOrderNo, DbType.String, ParameterDirection.Input)
                                 , helper.CreateParameter("P_WRK_ORDR_SEQNO", Common.WrkOrderSeq, DbType.String, ParameterDirection.Input)
                                 , helper.CreateParameter("P_MATNR", Common.ItemCode, DbType.String, ParameterDirection.Input)
                                 , helper.CreateParameter("P_PRFM_QTY", iTempQty.ToString(), DbType.String, ParameterDirection.Input)
                                 , helper.CreateParameter("P_PRFM_DT", lblPRFM_DATE.Text, DbType.String, ParameterDirection.Input)
                                 , helper.CreateParameter("P_COMP_YN", sCompflag, DbType.String, ParameterDirection.Input)
                                 );

                        //Step1_1.MES 실적 등록 성공시 SAP 전송
                        if (helper.RSCODE == "S")
                        {
                            string sRfcData; //RFC결과 JSON 변환
                            bReturn_PRFM = false;

                            sMATNR_NM = dsTemp.Tables[0].Rows[0]["MATNR_NM"].ToString(); //WCS 요청을 위한 PARAMETER
                            sIND_BCD = dsTemp.Tables[0].Rows[0]["IND_BCD"].ToString(); //WCS 요청을 위한 PARAMETER

                            rbTemp.Rows.Add(sIND_BCD);

                            helper.Commit();

                            //step1_2.라벨발행
                            doPrint(dsTemp.Tables[0]);
                            //등록 및 출력된 수량 차감
                            iBOXCNT = iBOXCNT - iPLT2BOX;

                            //Step2. SAP 실적 전송
                            try
                            {
                                #region SAP 롤백용 추가 CODE 범위 START 
                                sapTemp = new DataTable();
                                sapTemp.Columns.Add("SAP_TYPE", typeof(string));
                                sapTemp.Columns.Add("IF_KEY", typeof(string));
                                sapTemp.Columns.Add("MDOCNO", typeof(string));
                                sapTemp.Columns.Add("MDOCSEQ", typeof(string));
                                #endregion SAP 롤백용 추가 CODE 범위 END

                                this.Cursor = Cursors.WaitCursor;   //Waitting

                                //실적목록 테이블 JSON으로 변환
                                sWrkList = Common.toJsonFormat("POP_WRK20", dsTemp.Tables[0]);

                                LogFile.WriteLog("PROC WRK_LIST : " + sWrkList, LogType.PROC);

                                dsTemp = helper.FillDataSetN("SP_POP_WRK20_I01_AGV", CommandType.StoredProcedure, 8
                                                                            , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)
                                                                            , helper.CreateParameter("P_PROC_CD", Common.OpCode, DbType.String, ParameterDirection.Input)
                                                                            , helper.CreateParameterOracle("P_WRK_LIST", sWrkList, OracleDbType.Clob, ParameterDirection.Input)
                                                                            , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input)
                                                                            , helper.CreateParameter("P_PRFM_FUNC", DbType.String, ParameterDirection.Output, null, 200)                  // 실적 RFCFN ID값
                                                                            , helper.CreateParameter("P_USE_FUNC", DbType.String, ParameterDirection.Output, null, 200)                  // 재고이전 RFCFN ID
                                                                            , helper.CreateParameter("P_WDOC_NO", DbType.String, ParameterDirection.Output, null, 30)
                                                                            );

                                if (helper.RSCODE == "E")
                                {
                                    this.Cursor = Cursors.Default;   //Waitting
                                    helper.Rollback();
                                    new POPUP.MessageForm(helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                    this.DialogResult = DialogResult.OK;
                                    throw new Exception("개별바코드 [" + sIND_BCD + "] \r\n MES 생산실적 등록 실패하였습니다. \r\n (" + rollbackType + ")");

                                }
                                else
                                {
                                    //step2.SAP 실적 전송 오류
                                    rollbackType = "DELETE_workSap_RB";

                                    sPRFM_FUNC = helper.Parameters["P_PRFM_FUNC"].Value.ToString();
                                    //sUSE_FUNC = helper.Parameters["P_USE_FUNC"].Value.ToString();
                                    string sWDOC_NO = helper.Parameters["P_WDOC_NO"].Value.ToString();
                                    //SAP 실적 등록
                                    SAPHelper sapRFC = new SAPHelper();
                                    if (string.IsNullOrEmpty(sPRFM_FUNC) == false)
                                    {
                                        if (sapRFC.CallSAPFunc_HL(sPRFM_FUNC, dsTemp.Tables[0], dsTemp.Tables[1], helper).Equals("S"))
                                        {
                                            #region SAP 롤백용 추가 CODE 범위 START
                                            sapRFC.SaveResulttoWrk_HL(helper, "POP_WRK020", "0");//롤백처리용 결과처리 함수(COMMIT 제거)
                                                                                                 //rollback용
                                            string sTempSAP_TYPE = string.Empty;
                                            string sTempIF_KEY = string.Empty;
                                            string sTempMDOC_NO = string.Empty;
                                            string sTempMDOC_SEQNO = string.Empty;

                                            sTempSAP_TYPE = "PROD_REG_SAP";

                                            string sSDOC_ColunmName = string.Empty;
                                            string sSDOCNO_ColunmName = string.Empty;
                                            if (sapRFC.rtnTable.Columns.Contains("MBLNR"))
                                            {
                                                sSDOC_ColunmName = "MBLNR";
                                                sSDOCNO_ColunmName = "MJAHR";
                                            }
                                            else
                                            {
                                                sSDOC_ColunmName = "RUECK";
                                                sSDOCNO_ColunmName = "RMZHL";
                                            }
                                            sTempIF_KEY = dsTemp.Tables[0].Rows[0]["I_IF_KEY"].ToString();
                                            if (!dsTemp.Tables[1].Columns.Contains("SDOC_NO") && !dsTemp.Tables[1].Columns.Contains("SDOC_SEQNO"))
                                            {
                                                dsTemp.Tables[1].Columns.Add("SDOC_NO", typeof(string));
                                                dsTemp.Tables[1].Columns.Add("SDOC_SEQNO", typeof(string));
                                            }
                                            foreach (DataRow Rows in dsTemp.Tables[1].Rows)
                                            {
                                                sTempMDOC_NO = Rows["MDOCNO"].ToString();
                                                sTempMDOC_SEQNO = Rows["MDOCSEQ"].ToString();
                                                sapTemp.Rows.Add(sTempSAP_TYPE, sTempIF_KEY, sTempMDOC_NO, sTempMDOC_SEQNO); // 후단 코드 실행시 EXCEPTION 상황 SAP CANCLE 정보 -- 실적등록
                                                foreach (DataRow rfcRows in sapRFC.rtnTable.Rows)
                                                {
                                                    string sMBLNRtemp = string.Empty;
                                                    string sMJAHRtemp = string.Empty;
                                                    sMBLNRtemp = rfcRows[sSDOC_ColunmName].ToString();
                                                    sMJAHRtemp = rfcRows[sSDOCNO_ColunmName].ToString();
                                                    if (Rows["MDOCNO"].ToString() == rfcRows["MDOCNO"].ToString() && Convert.ToInt32(Rows["MDOCSEQ"].ToString()) == Convert.ToInt32(rfcRows["MDOCSEQ"].ToString()))
                                                    {
                                                        Rows["SDOC_NO"] = sMBLNRtemp;
                                                        Rows["SDOC_SEQNO"] = sMJAHRtemp;
                                                    }
                                                }
                                            }
                                            //rollback용 end
                                            #endregion SAP 롤백용 추가 CODE 범위 END

                                            Thread.Sleep(1000);

                                            #region 오더 완료실적이 존재시
                                            //오더 완료실적이 존재시
                                            if (!dsTemp.Tables[5].Rows[0][0].ToString().Equals("1"))
                                            {
                                                SAPHelper sapRFC_O = new SAPHelper();
                                                if (!sapRFC_O.CallSAPFunc_HL(sPRFM_FUNC, dsTemp.Tables[5], dsTemp.Tables[6], helper).Equals("S"))
                                                {
                                                    this.Cursor = Cursors.Default;   //Waitting
                                                    throw new Exception("오더 완료 SAP전송이 실패하였습니다.\n" + sapRFC_O.rtnMSG);
                                                }
                                                if (sapRFC_O.rtnTable.Columns.Contains("MBLNR"))
                                                {
                                                    sSDOC_ColunmName = "MBLNR";
                                                    sSDOCNO_ColunmName = "MJAHR";
                                                }
                                                else
                                                {
                                                    sSDOC_ColunmName = "RUECK";
                                                    sSDOCNO_ColunmName = "RMZHL";
                                                }
                                                if (!dsTemp.Tables[6].Columns.Contains("SDOC_NO") && !dsTemp.Tables[6].Columns.Contains("SDOC_SEQNO"))
                                                {
                                                    dsTemp.Tables[6].Columns.Add("SDOC_NO", typeof(string));
                                                    dsTemp.Tables[6].Columns.Add("SDOC_SEQNO", typeof(string));
                                                }
                                                foreach (DataRow Rows in dsTemp.Tables[6].Rows)
                                                {
                                                    foreach (DataRow rfcRows in sapRFC_O.rtnTable.Rows)
                                                    {
                                                        string sMBLNRtemp = string.Empty;
                                                        string sMJAHRtemp = string.Empty;
                                                        sMBLNRtemp = rfcRows[sSDOC_ColunmName].ToString();
                                                        sMJAHRtemp = rfcRows[sSDOCNO_ColunmName].ToString();
                                                        if (Rows["MDOCNO"].ToString() == rfcRows["MDOCNO"].ToString() && Convert.ToInt32(Rows["MDOCSEQ"].ToString()) == Convert.ToInt32(rfcRows["MDOCSEQ"].ToString()))
                                                        {
                                                            Rows["SDOC_NO"] = sMBLNRtemp;
                                                            Rows["SDOC_SEQNO"] = sMJAHRtemp;
                                                        }
                                                    }
                                                }
                                                Thread.Sleep(1000);
                                            }
                                            #endregion

                                            try { helper.Commit(); }// 모두 성공시 커밋
                                            catch { }

                                            //Step3. wms 입고요청
                                            if (!string.IsNullOrEmpty(sWDOC_NO))
                                            {
                                                //dblink : DBLINK_WMSIF205

                                                //Step3. wms 입고요청 오류
                                                rollbackType = "DELETE_storeWms_RB";

                                                string sJsonData = Common.toJsonFormat_List("list", dsTemp.Tables[2]);
                                                string rtnData = string.Empty;
                                                bool bWMSTrans = false;

                                                helper.RSCODE = "";

                                                DataRow targetRow = dsTemp.Tables[2].Rows[0];
                                                string I_PRFM_LIST = dsTemp.Tables[7].Rows[0]["I_PRFM_LIST"].ToString();

                                                LogFile.WriteLog("I_PRFM_LIST : \r\n" + I_PRFM_LIST);

                                                try
                                                {
                                                    //프로시저 호출 SP_POP_AUTO_RCV_STEP3
                                                    dsTemp = helper.FillDataSetN("SP_POP_AUTO_RCV_STEP3", CommandType.StoredProcedure, 2
                                                                                    , helper.CreateParameterOracle("P_JSONSTR", I_PRFM_LIST, OracleDbType.Clob, ParameterDirection.Input)
                                                                                    , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)
                                                                                    , helper.CreateParameter("P_MATNR", targetRow["MATNR"].ToString(), DbType.String, ParameterDirection.Input)
                                                                                    , helper.CreateParameter("P_IND_BCD", targetRow["LOTA14"].ToString(), DbType.String, ParameterDirection.Input)
                                                                                    , helper.CreateParameter("P_DOC_NO", "", DbType.String, ParameterDirection.Input)     //WMS 입고요청 문서번호 //RCV_STEP3 프로시저 내에서 가져다씀
                                                                                    , helper.CreateParameter("P_DOC_SEQ", "", DbType.String, ParameterDirection.Input)    //WMS 입고요청 문서번호 SEQ //RCV_STEP3 프로시저 내에서 가져다씀
                                                                                    , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input)
                                                                                    , helper.CreateParameter("P_LOT_NO", targetRow["LOTA15"].ToString(), DbType.String, ParameterDirection.Input)
                                                                                    , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)
                                                                                    , helper.CreateParameter("P_WRK_ORDR_NO", Common.WrkOrderNo, DbType.String, ParameterDirection.Input)
                                                                                    , helper.CreateParameter("P_WRK_ORDR_SEQNO", Common.WrkOrderSeq, DbType.String, ParameterDirection.Input)
                                                                                    , helper.CreateParameter("P_DOC_NO_TRANS", DbType.String, ParameterDirection.Output, null, 30)
                                                                                    , helper.CreateParameter("P_DOC_NO_WMS", DbType.String, ParameterDirection.Output, null, 30)
                                                                                    , helper.CreateParameter("P_MOVE_FUNC", DbType.String, ParameterDirection.Output, null, 30)
                                                    );
                                                    bWMSTrans = true;
                                                    sDOC_TRANS = helper.Parameters["P_DOC_NO_TRANS"].Value.ToString();
                                                    sDOC_WMS = helper.Parameters["P_DOC_NO_WMS"].Value.ToString();
                                                    sMOVE_FUNC = helper.Parameters["P_MOVE_FUNC"].Value.ToString();

                                                    rbTemp.Rows.Clear();
                                                    rbTemp.Rows.Add(sIND_BCD, sDOC_TRANS, sDOC_WMS);
                                                }
                                                catch (Exception EX_WMS)
                                                {
                                                    LogFile.WriteLog("POP_WRK14.doConfirm_AGV::GetRestToString Error\r\n" + EX_WMS.ToString());
                                                    new POPUP.MessageForm(EX_WMS.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                                    this.DialogResult = DialogResult.OK;

                                                    Thread.Sleep(1000);
                                                    System.Windows.Forms.Application.DoEvents();        // 반복작업중 응답없음 안뜨게 하기
                                                    this.Cursor = Cursors.Default;   //Waitting
                                                    helper.Rollback();
                                                    throw new Exception("개별바코드 [" + sIND_BCD + "] \r\n WMS 입고요청 & 입고 실패하였습니다. \r\n (" + rollbackType + ")\r\n오류메시지\r\n" + EX_WMS.Message);
                                                }

                                                if (helper.RSCODE == "S")
                                                {
                                                    //wms 입고요청 & wms 입고 성공
                                                    //step4. SAP 재고이전
                                                    if (string.IsNullOrEmpty(sMOVE_FUNC) == false & bWMSTrans)
                                                    {
                                                        //step4.SAP 재고이전
                                                        rollbackType = "DELETE_transferSap_RB";

                                                        //SAP 재고이전
                                                        SAPHelper sapRFC_MOVE = new SAPHelper();
                                                        // sapRFC.CallSAPFunc 호출시 helper를 사용하여 내용이 변경됨. 
                                                        // 필요한 정보는 sapRFC.CallSAPFunc 호출전에 처리해야함.
                                                        if (sapRFC_MOVE.CallSAPFunc(sMOVE_FUNC, dsTemp.Tables[0], dsTemp.Tables[1], helper).Equals("S"))
                                                        {
                                                            // ---- 전달시 MBLNR, MJAHR을 replace 처리하여 하나로 받도록함.
                                                            sRfcData = Common.toJsonFormat("PUT_WRKRTN", sapRFC_MOVE.rtnTable).Replace("MBLNR", "RUECK").Replace("MJAHR", "RMZHL");

                                                            bReturn_MOVE = true;

                                                            //실적등록 테이블에 확정문서 번호 갱신
                                                            helper.ExecuteNoneQuery("SP_IF_PUT_WRKRTN", CommandType.StoredProcedure
                                                                                                , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)                // 플랜트
                                                                                                , helper.CreateParameter("P_WRK_TYPE", "TX", DbType.String, ParameterDirection.Input)                  // '0'= 실적테이블_비계획생산, '1'= 폐품테이블, '2'=소요량, '3'=비가동
                                                                                                , helper.CreateParameterOracle("P_RFC_DATA", sRfcData, OracleDbType.Clob, ParameterDirection.Input)
                                                                                                , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input));

                                                            if (helper.RSCODE == "S")
                                                            {
                                                                //3호기, 6호기만 WCS 호출
                                                                if ("TRA03".Equals(Common.MachineCode) | "TRA06".Equals(Common.MachineCode))
                                                                {
                                                                    //step5.WCS호출(3, 6호기만)
                                                                    rollbackType = "DELETE_WCS_RB";

                                                                    //무인지게차 호출 유무
                                                                    if (wcsCallTF)
                                                                    {
                                                                        //WCS 호출 
                                                                        //MARAIDB 연결
                                                                        DBHelper helper_maria = new DBHelper("", true, "maria");
                                                                        if (helper_maria != null & helper_maria.DBConnect.State == ConnectionState.Open)
                                                                        {
                                                                            var inputParams = new DbParameter[]
                                                                            {
                                                                            helper_maria.CreateParameter("", sDOC_TRANS + "C", DbType.String, ParameterDirection.Input),
                                                                            helper_maria.CreateParameter("", "IN", DbType.String, ParameterDirection.Input),
                                                                            helper_maria.CreateParameter("", Common.PlantCode, DbType.String, ParameterDirection.Input),
                                                                            helper_maria.CreateParameter("", targetRow["MATNR"].ToString(), DbType.String, ParameterDirection.Input),
                                                                            helper_maria.CreateParameter("", sMATNR_NM, DbType.String, ParameterDirection.Input),
                                                                            helper_maria.CreateParameter("", targetRow["LOTA15"].ToString(), DbType.String, ParameterDirection.Input),
                                                                            helper_maria.CreateParameter("", targetRow["LOTA14"].ToString(), DbType.String, ParameterDirection.Input),
                                                                            helper_maria.CreateParameter("", targetRow["MEINS"].ToString(), DbType.String, ParameterDirection.Input),
                                                                            helper_maria.CreateParameter("", targetRow["MENGE"].ToString(), DbType.String, ParameterDirection.Input),
                                                                            helper_maria.CreateParameter("", Common.MachineCode, DbType.String, ParameterDirection.Input)
                                                                            };

                                                                            DataTable result = helper_maria.ExecuteProcedureWithOutSelect("SP_INSERT_TB_PLT_STOCK", inputParams);

                                                                            if (result.Rows.Count > 0)
                                                                            {
                                                                                string code = result.Rows[0]["P_RESULT"]?.ToString();
                                                                                string msg = result.Rows[0]["P_RESULT_MSG"]?.ToString();
                                                                                Console.WriteLine($"▶ 결과: {code}, 메시지: {msg}");

                                                                                this.Cursor = Cursors.Default;   //Waitting
                                                                                new POPUP.MessageForm("[MES 실적등록, WMS 입고완료, WCS 입고완료]", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                                                            }
                                                                            else
                                                                            {
                                                                                new POPUP.MessageForm("[MES 실적등록, WMS 입고완료] \r\n [WCS 입고 실패] \r\n WCS 프로그램을 통해 개별바코드 수동입고처리 바랍니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                                                            }

                                                                        }
                                                                        else
                                                                        {
                                                                            LogFile.WriteLog("[WCS 호출 실패] : WCS CONNECTION 실패");
                                                                            this.Cursor = Cursors.Default;   //Waitting
                                                                            throw new Exception("개별바코드 [" + sIND_BCD + "] WCS 입고 실패하였습니다.(" + rollbackType + ")\r\n오류메시지\r\n[WCS 호출 실패] : WCS CONNECTION 실패");
                                                                        }
                                                                    }
                                                                }
                                                                else
                                                                {
                                                                    this.Cursor = Cursors.Default;   //Waitting
                                                                    new POPUP.MessageForm("[MES 실적등록 및 WMS 입고완료]", MessageBoxButtons.OK, "알   림").ShowDialog(this);

                                                                }
                                                            }
                                                            else
                                                            {
                                                                //helper.Rollback();
                                                                LogFile.WriteLog("재고이전 - SAP 확정문서 등록 오류 [" + helper.RSMSG.ToString() + " ]");
                                                                sMSG_ERR += "확정문서 등록 오류 : " + helper.RSMSG.ToString() + Environment.NewLine;
                                                                throw new Exception("SAP_ERROR" + sMSG_ERR);
                                                            }
                                                        }
                                                        else
                                                        {
                                                            bReturn_MOVE = false;
                                                            LogFile.WriteLog("재고이전 SAP 오류 [" + sapRFC_MOVE.rtnMSG + "]");
                                                            new POPUP.MessageForm("재고이전 SAP 오류\r\n" + sapRFC_MOVE.rtnMSG, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                                            throw new Exception("개별바코드 [" + sIND_BCD + "] 재고이전 SAP전송이 실패하였습니다.(" + rollbackType + ")\r\n오류메시지\r\n" + sapRFC_MOVE.rtnMSG);
                                                        }
                                                    }
                                                }
                                                else
                                                {
                                                    this.Cursor = Cursors.Default;   //Waitting
                                                    new POPUP.MessageForm("완제품 입고요청이 실패하였습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                                    return;
                                                }
                                            }
                                        }
                                        else
                                        {
                                            LogFile.WriteLog("SP_POP_WRK20_I01_AGV[SAP Retrun Error] : " + sapRFC.rtnMSG);
                                            this.Cursor = Cursors.Default;   //Waitting
                                            throw new Exception("개별바코드 [" + sIND_BCD + "] 생산실적 SAP전송이 실패하였습니다.(" + rollbackType + ")\r\n오류메시지\r\n" + sapRFC.rtnMSG);
                                        }
                                    }
                                    else
                                    {
                                        bReturn_PRFM = true;
                                    }
                                }
                            }
                            catch (Exception ex)
                            {
                                try
                                {
                                    LogFile.WriteLog("POP_WRK14.doConfirm_AGV Error\r\n" + ex.Message);

                                    sResult = "ROLLBACK";
                                    RollbackLog(helper, dsTemp, ex.Message, sResult, false);
                                    if ("DELETE_WCS_RB".Equals(rollbackType))
                                    {
                                        new POPUP.MessageForm("[MES, WMS 실적등록 및 입고완료] \r\n [WCS 입고 실패] \r\n WCS 프로그램을 통해 개별바코드[" + sIND_BCD + "] 수동입고처리 바랍니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                        return;
                                    }
                                    ProdRollback_HL_AGV(helper, sapTemp, dsTemp, rollbackType, rbTemp);
                                    helper.Rollback();

                                    LogFile.WriteLog("POP_WRK14.doConfirm_AGV ROLLBACK 완료\r\n");

                                    this.Cursor = Cursors.Default;   //Waitting

                                    string sRollBackMsg = ex.Message + Environment.NewLine + "MES ROLLBACK 실적 취소되었습니다";

                                    new POPUP.MessageForm_ERR("알   림", sRollBackMsg, MessageBoxButtons.OK).ShowDialog(this);

                                    return;
                                }
                                catch (Exception EX2)
                                {
                                    LogFile.WriteLog("롤백 프로세스 Exception 발생\r\n" + EX2.Message);
                                    helper.Rollback();
                                    new POPUP.MessageForm_ERR("알   림", "롤백 프로세스 Exception 발생\r\n" + EX2.Message, MessageBoxButtons.OK).ShowDialog(this);

                                    return;
                                }
                            }
                            finally
                            {
                                this.Cursor = Cursors.Default;   //Waitting
                                helper.Close();
                            }

                            Thread.Sleep(Common.SLEEP_DELAY);
                            System.Windows.Forms.Application.DoEvents();        // 반복작업중 응답없음 안뜨게 하기
                            this.Cursor = Cursors.WaitCursor;   //Waitting
                        }
                        else if (helper.RSCODE == "N")
                        {
                            helper.Rollback();
                            new POPUP.MessageForm("자재의 수량이 부족합니다.\n" + helper.RSMSG.ToString() + "\n가공파트에 자재투입을 의뢰하세요.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                            return;
                        }
                        else
                        {
                            helper.Rollback();
                            new POPUP.MessageForm(helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                            return;
                        }
                    }
                    catch (Exception ex)
                    {
                        helper.Rollback();
                        new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                        return;
                    }
                    finally
                    {
                        helper.Close();
                    }
                }

                new POPUP.MessageForm("실적이 정상적으로 등록되었습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
            }
            catch (Exception ex)
            {
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
            }
            finally
            {
                this.Close();
            }
        }

        private void RollbackLog(DBHelper helper, DataSet dsTemp, string sMSG_ERR, string sResult, bool sapRollbackLogFlag)
        {
            try
            {
                if (sapRollbackLogFlag)// sap 롤백에 대한 로그 저장
                {
                    if (dsTemp.Tables.Count == 0) return;

                    if (dsTemp.Tables[1] != null)
                    {
                        if (dsTemp.Tables[1].Rows.Count > 0)
                        {
                            if (dsTemp.Tables[1].Rows[0][0].ToString() != "1")
                            {
                                foreach (DataRow Rows in dsTemp.Tables[1].Rows) //실적전송 롤백 수행 로그 저장
                                {
                                    helper.ExecuteNoneQuery("SP_HL_ROLLBACK_LOG", CommandType.StoredProcedure
                                    , helper.CreateParameter("P_DOC_NO", dsTemp.Tables[1].Columns.Contains("MDOCNO") ? Rows["MDOCNO"] : "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_DOC_SEQNO", dsTemp.Tables[1].Columns.Contains("MDOCSEQ") ? Rows["MDOCSEQ"] : "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_LOT_NO", "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_ORDER_NO", dsTemp.Tables[1].Columns.Contains("AUFNR") ? Rows["AUFNR"] : "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_WORKCENTERCODE", dsTemp.Tables[1].Columns.Contains("WORKCENTERCODE") ? Rows["WORKCENTERCODE"] : "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_MACH_CD", "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_PRDCD", "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_QTY", "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_MATNR", "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_BUDAT", "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_RESULT", sResult, DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_REMARK", sMSG_ERR, DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_MBLNR", "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_MJAHR", "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_I_IF_ID", dsTemp.Tables[0].Rows[0]["I_IF_ID"].ToString(), DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input));
                                }
                            }
                        }
                    }
                }
                else  // sap 롤백발생원인에 대한 저장
                {
                    if (dsTemp.Tables.Count == 0) return;

                    if (dsTemp.Tables[1] != null)
                    {
                        if (dsTemp.Tables[1].Rows.Count > 0)
                        {
                            if (dsTemp.Tables[1].Rows[0][0].ToString() != "1")
                            {
                                foreach (DataRow Rows in dsTemp.Tables[1].Rows) //실적등록 및 폐품등록 실패시 롤백 발생원인 저장 - 실적등록 로그
                                {
                                    helper.ExecuteNoneQuery("SP_HL_ROLLBACK_LOG", CommandType.StoredProcedure
                                    , helper.CreateParameter("P_DOC_NO", dsTemp.Tables[1].Columns.Contains("MDOCNO") ? Rows["MDOCNO"] : "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_DOC_SEQNO", dsTemp.Tables[1].Columns.Contains("MDOCSEQ") ? Rows["MDOCSEQ"] : "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_LOT_NO", dsTemp.Tables[1].Columns.Contains("LOTNO") ? Rows["LOTNO"] : "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_ORDER_NO", dsTemp.Tables[1].Columns.Contains("AUFNR") ? Rows["AUFNR"] : "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_WERKS", dsTemp.Tables[1].Columns.Contains("WERKS") ? Rows["WERKS"] : "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_WORKCENTERCODE", "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_MACH_CD", "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_PRDCD", "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_QTY", dsTemp.Tables[1].Columns.Contains("PROQTY") ? Rows["PROQTY"] : "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_MATNR", dsTemp.Tables[1].Columns.Contains("MATNR") ? Rows["MATNR"] : "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_BUDAT", dsTemp.Tables[1].Columns.Contains("BUDAT") ? Rows["BUDAT"] : "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_RESULT", sResult, DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_REMARK", sMSG_ERR, DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_MBLNR", dsTemp.Tables[1].Columns.Contains("SDOC_NO") ? Rows["SDOC_NO"] : "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_MJAHR", dsTemp.Tables[1].Columns.Contains("SDOC_SEQNO") ? Rows["SDOC_SEQNO"] : "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_I_IF_ID", dsTemp.Tables[0].Rows[0]["I_IF_ID"].ToString(), DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input));
                                }
                            }
                        }
                    }

                    if (dsTemp.Tables[5] != null)
                    {
                        if (dsTemp.Tables[6].Rows.Count > 0)
                        {
                            if (dsTemp.Tables[6].Rows[0][0].ToString() != "1")
                            {
                                foreach (DataRow Rows in dsTemp.Tables[6].Rows) //실적등록 및 폐품등록 실패시 롤백 발생원인 저장 - 오더완료 로그
                                {
                                    helper.ExecuteNoneQuery("SP_HL_ROLLBACK_LOG", CommandType.StoredProcedure
                                    , helper.CreateParameter("P_DOC_NO", dsTemp.Tables[6].Columns.Contains("MDOCNO") ? Rows["MDOCNO"] : "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_DOC_SEQNO", dsTemp.Tables[6].Columns.Contains("MDOCSEQ") ? Rows["MDOCSEQ"] : "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_LOT_NO", dsTemp.Tables[6].Columns.Contains("CHARG") ? Rows["CHARG"] : "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_ORDER_NO", dsTemp.Tables[6].Columns.Contains("AUFNR") ? Rows["AUFNR"] : "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_WERKS", dsTemp.Tables[6].Columns.Contains("WERKS") ? Rows["WERKS"] : "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_WORKCENTERCODE", dsTemp.Tables[6].Columns.Contains("WORKCENTERCODE") ? Rows["WORKCENTERCODE"] : "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_MACH_CD", "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_PRDCD", "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_QTY", dsTemp.Tables[6].Columns.Contains("MENGE") ? Rows["MENGE"] : "", DbType.String, ParameterDirection.Input)// MENGE의 CONTAIN 체크 누락 보완 진행 20221226 이성민
                                    , helper.CreateParameter("P_MATNR", dsTemp.Tables[6].Columns.Contains("MATNR") ? Rows["MATNR"] : "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_BUDAT", dsTemp.Tables[6].Columns.Contains("BUDAT") ? Rows["BUDAT"] : "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_RESULT", sResult, DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_REMARK", sMSG_ERR, DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_MBLNR", dsTemp.Tables[6].Columns.Contains("SDOC_NO") ? Rows["SDOC_NO"] : "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_MJAHR", dsTemp.Tables[6].Columns.Contains("SDOC_SEQNO") ? Rows["SDOC_SEQNO"] : "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_I_IF_ID", dsTemp.Tables[5].Rows[0]["I_IF_ID"].ToString(), DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input));
                                }
                            }
                        }
                    }

                }
            }
            catch (Exception EX)
            {
                LogFile.WriteLog("HL 실적현황 ROLLBACK LOG 기록 에러 Exception 발생 [" + EX.Message + "] + [" + helper.RSCODE + " " + helper.RSMSG + "]"); //현장로그기록 보완 20221226 이성민
            }

        }

        private void ProdRollback_HL_AGV(DBHelper helper, DataTable sapTemp, DataSet dsTemp, string rollbackType, DataTable rbTemp)
        {
            // Step1. MES 실적 등록 취소 & WMS 입고요청 취소
            // Step2. WMS 입고 취소
            // Step3. SAP 재고이전 취소(필요없음)
            // Step4. SAP 실적전송 취소
            string sDocNoTrans = string.Empty;
            string sDocNoWms = string.Empty;
            string sIndBcd = string.Empty;
            try
            {
                // Step1. MES 실적 등록 취소 & WMS 입고요청 취소
                // Step2. WMS 입고 취소
                //SP_AUTO_CANC_SAP 먼저 호출 
                //프로시저 호출 SP_AUTO_CANC_SAP
                if ("DELETE_transferSap_RB".Equals(rollbackType) || "DELETE_storeWms_RB".Equals(rollbackType))
                {
                    sDocNoTrans = rbTemp.Rows[0]["DOC_NO_TRANS"].ToString();
                    sDocNoWms = rbTemp.Rows[0]["DOC_NO_WMS"].ToString();
                }
                sIndBcd = rbTemp.Rows[0]["IND_BCD"].ToString();


                DataSet dsTemp_canc = helper.FillDataSetN_AGV("SP_AUTO_CANC_SAP", CommandType.StoredProcedure, 0, false, false
                                                , helper.CreateParameterOracle("ROLLBACK_TYPE", rollbackType, OracleDbType.Clob, ParameterDirection.Input)
                                                , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)
                                                , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)
                                                , helper.CreateParameter("P_IND_BCD", sIndBcd, DbType.String, ParameterDirection.Input)
                                                , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input)
                                                , helper.CreateParameter("P_WMS_CANC_KEY", sDocNoWms, DbType.String, ParameterDirection.Input)     //WCS 입고 프로시저내에서 RETURN 받은 문서번호 넣어줘야함
                                                , helper.CreateParameter("P_TRANS_CANC_KEY", sDocNoTrans, DbType.String, ParameterDirection.Input)    //WCS 입고 프로시저내에서 RETURN 받은 문서번호 넣어줘야함	
                                                , helper.CreateParameter("P_TYPE", "POP", DbType.String, ParameterDirection.Input)    // 입력 타입 ( AUTO, POP ) 	
                                                , helper.CreateParameter("RS_CODE_RB", DbType.String, ParameterDirection.Output, null, 30)
                                                , helper.CreateParameter("RS_MSG_RB", DbType.String, ParameterDirection.Output, null, 30)
                                                , helper.CreateParameter("P_DOC_NO_CANC_TRANS", DbType.String, ParameterDirection.Output, null, 30)
                                                , helper.CreateParameter("P_DOC_NO_CANC_WRK", DbType.String, ParameterDirection.Output, null, 30)
                );

                if (helper.Parameters["RS_CODE_RB"].Value.ToString() == "S")
                {
                    if (sapTemp.Rows.Count != 0)
                    {
                        string sMSG_ERR = string.Empty;
                        string sResult = string.Empty;
                        sapTemp = sapTemp.Select("", "SAP_TYPE ASC").CopyToDataTable<DataRow>();
                        foreach (DataRow Rows in sapTemp.Rows)
                        {
                            switch (Rows["SAP_TYPE"].ToString())
                            {
                                case "PROD_REG_SAP":
                                    dsTemp = helper.FillDataSetN("SP_POP_WRK20_IFR01", CommandType.StoredProcedure, 2
                                           , helper.CreateParameter("P_DOC_NO", Rows["MDOCNO"].ToString(), DbType.String, ParameterDirection.Input)
                                           , helper.CreateParameter("P_DOC_SEQNO", Rows["MDOCSEQ"].ToString(), DbType.String, ParameterDirection.Input)
                                           , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input)
                                           , helper.CreateParameter("RS_RFCFN", DbType.String, ParameterDirection.Output, null, 30)
                                            );

                                    if (helper.RSCODE == "S")
                                    {
                                        string sRS_RFCFN_1 = helper.Parameters["RS_RFCFN"].Value.ToString();
                                        SAPHelper sapRFC_1 = new SAPHelper();
                                        if (sapRFC_1.CallSAPFunc_HL(sRS_RFCFN_1, dsTemp.Tables[0], dsTemp.Tables[1], helper).Equals("S"))
                                        {
                                            LogFile.WriteLog("HL 실적등록 ROLLBACK [" + helper.RSMSG.ToString() + "]");
                                            sMSG_ERR = "HL 실적등록 ROLLBACK [" + helper.RSMSG.ToString() + "]";

                                            sResult = "S";
                                        }
                                        else
                                        {
                                            LogFile.WriteLog("HL ROLLBACK 오류 - SAP전송 오류 [" + sapRFC_1.rtnMSG + "]");
                                            sMSG_ERR = "HL ROLLBACK 오류 : " + sapRFC_1.rtnMSG + Environment.NewLine;
                                            sResult = "E";
                                        }
                                    }
                                    else
                                    {
                                        LogFile.WriteLog("HL ROLLBACK 등록 - MES IF TABLE 등록 오류 [" + helper.RSMSG.ToString() + "]");
                                        sMSG_ERR = "ROLLBACK MES IF TABLE 등록 오류 : " + helper.RSMSG.ToString() + Environment.NewLine;
                                        sResult = "E";
                                    }

                                    RollbackLog(helper, dsTemp, sMSG_ERR, sResult, true);
                                    break;

                                //case "TRANS_SAP":

                                //    string sRS_MOVE_RFCFN = helper.Parameters["P_MOVE_FUNC"].Value.ToString();

                                //    if (string.IsNullOrEmpty(sRS_MOVE_RFCFN) == false)
                                //    {
                                //        //SAP 재고이전
                                //        SAPHelper sapRFC = new SAPHelper();
                                //        // sapRFC.CallSAPFunc 호출시 helper를 사용하여 내용이 변경됨. 
                                //        // 필요한 정보는 sapRFC.CallSAPFunc 호출전에 처리해야함.
                                //        if (sapRFC.CallSAPFunc(sRS_MOVE_RFCFN, dsTemp.Tables[0], dsTemp.Tables[1], helper).Equals("S"))
                                //        {
                                //            //helper.Commit();
                                //        }
                                //        else
                                //        {
                                //            LogFile.WriteLog("HL ROLLBACK 오류 - 재고이전 SAP 오류 [" + sapRFC.rtnMSG + "]");
                                //            new POPUP.MessageForm("HL ROLLBACK 오류 - 재고이전 SAP 오류\r\n" + sapRFC.rtnMSG, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                //            sMSG_ERR = "ROLLBACK MES IF TABLE 등록 오류 : " + helper.RSMSG.ToString() + Environment.NewLine;
                                //            sResult = "E";
                                //        }
                                //    }
                                //    RollbackLog(helper, dsTemp, sMSG_ERR, sResult, true);
                                //    break;
                                default:
                                    break;
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                LogFile.WriteLog("HL ROLLBACK 에러 Exception 발생 [" + ex.Message + "]");
            }
        }

        private void doPrint(DataTable dtTemp)
        {
            #region A4출력
            ////조회결과 입력용 Row생성
            //REPORT_ITEM HLitem = new REPORT_ITEM();

            //HLitem.PRD_DATE = dtTemp.Rows[0]["PRFM_DT"].ToString();      // 생산일자
            //HLitem.MACH_NM = dtTemp.Rows[0]["MACH_NM"].ToString();       // 설비호기 명
            //HLitem.WERKS_NM = dtTemp.Rows[0]["WERKS_NM"].ToString();     // 제품구분
            //HLitem.MATNR = dtTemp.Rows[0]["MATNR"].ToString();           // 제품코드
            //HLitem.MATNR_NM = dtTemp.Rows[0]["MATNR_NM"].ToString();     // 제품명
            //HLitem.KAN_CD = dtTemp.Rows[0]["KAN_CD"].ToString();         // KAN코드
            //HLitem.UNIT = dtTemp.Rows[0]["BAG2BOX"].ToString();          // 기본단위
            //HLitem.PLT_UNIT = dtTemp.Rows[0]["BOX2PLT"].ToString();      // 팔레트 단위
            //HLitem.IND_BCD = dtTemp.Rows[0]["IND_BCD"].ToString();       // 개별바코드

            //string pstrERR = "";
            //REPORT rp = CommonReport.GetReport();   // REPORT rp = new REPORT();
            //rp.HL_PRINT(HLitem, ref pstrERR);
            //if (pstrERR.Length > 0)
            //{
            //    return;
            //}
            #endregion

            #region 바코드 라벨 테스트
            string PrinterName = SAMMI.IniFile.GetValue("KLEANNARA", "PRINTER", null);
            string PrinterDPI = SAMMI.IniFile.GetValue("KLEANNARA", "PRINTERDPI", null);
            string sZPL = string.Empty;
            //제목(PRODUCT)
            string sTitle = string.Empty;
            //생산정보(일자, 호기)
            string sPRD_DT = string.Empty;
            string sMACH_NM = string.Empty;
            string sPRFM_QTY = string.Empty;
            //제품정보(종류, 코드, 명, KAN, 기본단위, 파렛트단위, LOT)
            string sMATNR_DIV = string.Empty;
            string sMATNR = string.Empty;
            string sMATNR_NM = string.Empty;
            string sKAN_CD = string.Empty;
            string sBS_UNIT = string.Empty;
            string sPLT_UNIT = string.Empty;
            string sLOT_NO = string.Empty;
            //바코드
            string sINDBCD = string.Empty;

            sTitle = "PRODUCT";
            //생산정보(일자, 호기)
            sPRD_DT = dtTemp.Rows[0]["PRFM_DT"].ToString();
            sMACH_NM = dtTemp.Rows[0]["MACH_NM"].ToString();
            sPRFM_QTY = dtTemp.Rows[0]["PRFM_QTY"].ToString();
            //제품정보(종류, 코드, 명, KAN, 기본단위, 파렛트단위, LOT)
            sMATNR_DIV = dtTemp.Rows[0]["MATNR_DIV_NM"].ToString();
            sMATNR = dtTemp.Rows[0]["MATNR"].ToString();
            sMATNR_NM = dtTemp.Rows[0]["MATNR_NM"].ToString();
            sKAN_CD = dtTemp.Rows[0]["KAN_CD"].ToString();
            sBS_UNIT = dtTemp.Rows[0]["BAG2BOX"].ToString();
            sPLT_UNIT = dtTemp.Rows[0]["BOX2PLT"].ToString();
            sLOT_NO = dtTemp.Rows[0]["LOT_NO"].ToString();
            //바코드
            sINDBCD = dtTemp.Rows[0]["IND_BCD"].ToString();

            DBHelper helper = new DBHelper(false);
            try
            {
                //ZPL코드 프로시저 호출
                helper.ExecuteNoneQuery("SP_INV_ZPL_HL", CommandType.StoredProcedure
                 , helper.CreateParameter("P_TYPE", PrinterDPI, DbType.String, ParameterDirection.Input) //라벨종류
                 , helper.CreateParameter("P_TITLE", sTitle, DbType.String, ParameterDirection.Input) //제목
                 , helper.CreateParameter("P_PRD_DT", sPRD_DT, DbType.String, ParameterDirection.Input) //생산일자
                 , helper.CreateParameter("P_MACH_NM", sMACH_NM, DbType.String, ParameterDirection.Input) //생산호기
                 , helper.CreateParameter("P_MATNR_DIV", sMATNR_DIV, DbType.String, ParameterDirection.Input) //품목구분
                 , helper.CreateParameter("P_MATNR", sMATNR, DbType.String, ParameterDirection.Input) //품목코드
                 , helper.CreateParameter("P_MATNR_NM", sMATNR_NM, DbType.String, ParameterDirection.Input) //품목명
                 , helper.CreateParameter("P_KAN_CD", sKAN_CD, DbType.String, ParameterDirection.Input) //KAN코드
                 , helper.CreateParameter("P_BS_UNIT", sBS_UNIT, DbType.String, ParameterDirection.Input) //기준단위
                 , helper.CreateParameter("P_PLT_UNIT", sPLT_UNIT, DbType.String, ParameterDirection.Input) //팔레트
                 , helper.CreateParameter("P_LOT_NO", sLOT_NO, DbType.String, ParameterDirection.Input) //LOT
                 , helper.CreateParameter("P_INDBCD", sINDBCD, DbType.String, ParameterDirection.Input) //바코드
                 , helper.CreateParameter("P_PRFM_QTY", sPRFM_QTY, DbType.String, ParameterDirection.Input) //적재수량
                 , helper.CreateParameter("P_ZPL", DbType.String, ParameterDirection.Output, null, 4000)
                   );

                if (helper.RSCODE == "E")
                {
                    new POPUP.MessageForm(helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    this.DialogResult = DialogResult.OK;
                    return;
                }
                else
                {
                    sZPL = helper.Parameters["P_ZPL"].Value.ToString();
                }

                foreach (string sPrinter in System.Drawing.Printing.PrinterSettings.InstalledPrinters)
                {
                    if (sPrinter.Contains(PrinterName))
                    {
                        SAMMI.RawPrinterHelper.SendStringToBytePrinter(sPrinter, sZPL);

                        break;
                    }
                }

                //new POPUP.MessageForm("라벨이 출력되었습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
            }
            catch (Exception ex)
            {
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                LogFile.WriteLog("POP_WRK14.doPrint Error\r\n" + ex.Message);
            }
            finally
            {
                helper.Close();
            }
            #endregion
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
                    case "Confirm":  //실적등록

                        DBHelper helper = new DBHelper(false, "", true);
                        try
                        {
                            string sSQL = "SELECT AGV_NEW_YN FROM TB_MAS012 WHERE 1 = 1 AND MACH_CD = '" + Common.MachineCode + "'";
                            DataTable dtTemp = helper.FillTable(sSQL, CommandType.Text);

                            if ("N".Equals(dtTemp.Rows[0]["AGV_NEW_YN"].ToString()))
                            {
                                doConfirm();
                            }
                            else
                            {
                                doConfirm_AGV();
                            }
                        }
                        catch(OracleException oe)
                        {
                            throw new Exception(oe.Message);
                        }
                        finally
                        {
                            helper.Close();
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
                LogFile.WriteLog("POP_WRK14.bBox1_buttonClickEvent Error\r\n" + ex.Message);
            }
            finally
            {
                
            }
        }

        private void lblPRFM_BOX_Click(object sender, EventArgs e)
        {
            double dDimension = 0;

            DAResultQty pop = new DAResultQty();
            pop.LabelTitle = "실적수량 입력";
            pop.LabelHeader = "실적수량";
            pop.ContentMaxLength = 8;

            pop.ShowDialog(this);

            if (pop.DialogResult == DialogResult.OK)
            {
                dDimension = pop.ResultDouble;
                lblPRFM_BOX.Text = string.Format("{0:#,0}", dDimension);
                //팔레트
                //lblPRFM_PLT.Text = Common.GetChangeUnit(dtNowWrk.Rows[0]["PLT_RATE"].ToString(), dDimension).ToString();
                lblPRFM_PLT.Text = string.Format("{0:#,##0}", Common.GetChangeUnit(dtNowWrk.Rows[0]["PLT_RATE"].ToString(), dDimension));
                //폴리백
                //lblPRFM_BAG.Text = Common.GetChangeUnit(dtNowWrk.Rows[0]["BAG_RATE"].ToString(), dDimension).ToString();
                lblPRFM_BAG.Text = string.Format("{0:#,##0}", Common.GetChangeUnit(dtNowWrk.Rows[0]["BAG_RATE"].ToString(), dDimension));
                //개수
                //lblPRFM_EA.Text = Common.GetChangeUnit(dtNowWrk.Rows[0]["EA_RATE"].ToString(), dDimension).ToString();
                lblPRFM_EA.Text = string.Format("{0:#,##0}", Common.GetChangeUnit(dtNowWrk.Rows[0]["EA_RATE"].ToString(), dDimension));
            }
        }

        private void lblEndChk_Click(object sender, EventArgs e)
        {
            if (lblEndChk.Text.ToString().Equals("V"))
            {
                lblEndChk.Text = "";
                lblEndChk.BackColor = Color.White;
            }
            else
            {
                lblEndChk.Text = "V";
                lblEndChk.BackColor = Color.Yellow;
            }
        }
        #endregion
    }
}
