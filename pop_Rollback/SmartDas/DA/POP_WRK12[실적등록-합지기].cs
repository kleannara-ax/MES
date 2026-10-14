#region [ USING AREA ]
using System;
using System.Configuration;
using System.Data;
using System.Windows.Forms;


using SAMMI;
using SmartDas.Components;
using SmartDas.POPUP;
using System.Globalization;

using Oracle.ManagedDataAccess.Client;
#endregion

namespace SmartDas
{
    public partial class POP_WRK12 : BaseForm
    {
        #region < MEMBER AREA >
        private string sStartTime = string.Empty;

        private SAMMI.Common _common = new SAMMI.Common();

        private DataTable dtNowWrk;
        private string sPRFMQty = string.Empty;
        private string sDISPOQty = string.Empty;

        #endregion

        #region < CONSTRUCTOR >

        public POP_WRK12()
        {
            InitializeComponent();

            Common.SetMessageList();
            this.UpdateMinuteEvent += new UpdateMinuteHandler(Common.dailyLotChange);
        }
        public POP_WRK12(DataTable pNowWrkOrder)
        {
            InitializeComponent();

            Common.SetMessageList();

            dtNowWrk = pNowWrkOrder;
            this.UpdateMinuteEvent += new UpdateMinuteHandler(Common.dailyLotChange);
        }
        #endregion

        #region < POP_WRK12_Load >
        private void POP_WRK12_Load(object sender, EventArgs e)
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

                this.lblTitle.Text = "합지기 실적등록";

                SetMenuButtons();
                DoFind();
            }
            catch (Exception ex)
            {
                SetMessage("POP_WRK12_Load_ Error!");
                LogFile.WriteLog("POP_WRK12.POP_WRK12_Load Error\r\n" + ex.Message);
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
                bBox1[0, 1].Text = "폐품등록";
                bBox1[0, 1].Tag = "Waste";
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
                LogFile.WriteLog("POP_WRK12.SetButtons Error\r\n" + ex.Message);
            }
        }

        private void DoFind()
        {
            int iTempValue;

            try
            {
                if (dtNowWrk.Rows.Count < 1)
                {
                    SetMessage("조회된 작업지시가 없습니다.");
                    new POPUP.MessageForm("조회된 작업지시가 없습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return;
                }
                else
                {
                    lblPRD_REQ_DT.Text = Common.dateFormat("O", dtNowWrk.Rows[0]["PRD_REQ_DT"].ToString());//생산지시일
                    lblWRK_ORDR_NO.Text = dtNowWrk.Rows[0]["WRK_ORDR_NO"].ToString();//작업지시번호
                    lblWRK_ORDR_SEQNO.Text = dtNowWrk.Rows[0]["WRK_ORDR_SEQNO"].ToString();//작업지시순번
                    lblMATNR.Tag = dtNowWrk.Rows[0]["MATNR"].ToString(); //자재코드
                    lblMATNR.Text = dtNowWrk.Rows[0]["MATNR_NM"].ToString(); //자재명
                    lblMATNR_SPEC.Text = dtNowWrk.Rows[0]["MATNR_SPEC"].ToString(); //규격
                    //lblSPEC.Text = dtNowWrk.Rows[0]["WIDTH"].ToString(); //지폭(폭수)
                    lblBSWGT.Text = dtNowWrk.Rows[0]["BS_WGT"].ToString();//평량
                    lblWRK_ORDR_RMK.Text = dtNowWrk.Rows[0]["WRK_ORDR_RMK"].ToString(); //작업지시사항

                    if (int.TryParse(dtNowWrk.Rows[0]["WIDTH"].ToString(), out iTempValue))
                    {
                        lblSPEC.Text = string.Format("{0:#,##0}", iTempValue); //지폭
                        lblWorkWidth.Text = string.Format("{0:#,##0}", iTempValue);
                    }
                    else
                    {
                        lblSPEC.Text = dtNowWrk.Rows[0]["WIDTH"].ToString();
                        lblWorkWidth.Text = dtNowWrk.Rows[0]["WIDTH"].ToString();
                    }

                    if (int.TryParse(dtNowWrk.Rows[0]["ORDER_QTY"].ToString(), out iTempValue))
                        lblORDER_QTY.Text = string.Format("{0:#,##0}", iTempValue); //계획량
                    else
                        lblORDER_QTY.Text = dtNowWrk.Rows[0]["ORDER_QTY"].ToString();

                    setPRDSTR();
                    AutoCalculation();
                }
            }
            catch (Exception ex)
            {
                SetMessage("doFind Error!");
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                LogFile.WriteLog("POP_WRK08.WRK_ORDER Find Error\r\n" + ex.Message);
            }
        }

        private void setPRDSTR()
        {
            DBHelper helper = new DBHelper(false);
            DateTime dPRDSTRDATE;

            try
            {
                helper.ExecuteNoneQuery("SP_POP_WRK12_S01", CommandType.StoredProcedure
                 , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)
                 , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)
                 , helper.CreateParameter("P_IOTYPE", Common.IOType, DbType.String, ParameterDirection.Input)
                 , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input)
                 , helper.CreateParameter("P_WRK_ORDR_NO", Common.WrkOrderNo, DbType.String, ParameterDirection.Input)
                 , helper.CreateParameter("P_WRK_ORDR_SEQNO", Common.WrkOrderSeq, DbType.String, ParameterDirection.Input)
                 , helper.CreateParameter("P_PRD_STR_DATE", DbType.String, ParameterDirection.Output, null, 100)
                 , helper.CreateParameter("P_PRFM_QTY", DbType.String, ParameterDirection.Output, null, 100)
                 , helper.CreateParameter("P_DISPO_QTY", DbType.String, ParameterDirection.Output, null, 100));

                if (helper.RSCODE == "S")
                {
                    //시작시간 출력
                    if (DateTime.TryParse(helper.Parameters["P_PRD_STR_DATE"].Value.ToString(), out dPRDSTRDATE))
                        dtpPRD_STR_DATE.Value = dPRDSTRDATE;
                    lblPRD_STR_DATE.Text = dtpPRD_STR_DATE.Value.ToString("HH:mm");
                    //실적, 폐품 정보 저장
                    sPRFMQty = helper.Parameters["P_PRFM_QTY"].Value.ToString();
                    sDISPOQty = helper.Parameters["P_DISPO_QTY"].Value.ToString();

                    DateCalc();
                }
            }
            catch (Exception ex)
            {
                SetMessage("DateSet Error!");
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                LogFile.WriteLog("POP_WRK12.DateSet Error\r\n" + ex.Message);
            }
            finally
            {
                helper.Close();
            }
        }

        private void doConfirm()
        {
            DBHelper helper = new DBHelper(false, "", true);

            DataSet dsTemp = new DataSet(); //실적등록 결과 수신(0:라벨정보, 1:RFC 변수, 2:IF 변수)
            string sWDocNo = string.Empty;
            string sUseFunc = string.Empty;
            string sResult = "ROLLBACK";

            DateTime dNowStartDate;
            DateTime dNowEndDate;

            try
            {
                if (string.IsNullOrEmpty(lblPRD_STR_DATE.Text) || string.IsNullOrEmpty(lblPRD_END_TIME.Text))
                {
                    new POPUP.MessageForm("작업 시간을 입력하여 주시기 바랍니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return;
                }

                dNowStartDate = Common.makeDateTime(dtpPRD_STR_DATE.Value, lblPRD_STR_DATE.Text);
                dNowEndDate = Common.makeDateTime(dtpPRD_END_DATE.Value, lblPRD_END_TIME.Text);

                TimeSpan Diff_dates = dNowEndDate.Subtract(dNowStartDate);

                if (Diff_dates.TotalMinutes <= 0)
                {
                    lblTM.Text = "0";
                    lblWorkSpeed.Text = "0";

                    new POPUP.MessageForm("작업 종료일시는 작업시작일시보다 같거나 빠를수 없습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return;
                }

                this.Cursor = Cursors.WaitCursor;   //Waitting

                //helper.ExecuteNoneQuery("SP_POP_WRK12_I01", CommandType.StoredProcedure
                dsTemp = helper.FillDataSetN("SP_POP_WRK12_I01", CommandType.StoredProcedure, 6
                         , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)
                         , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)
                         , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input)
                         , helper.CreateParameter("P_ORDER_NO", Common.OrderNo, DbType.String, ParameterDirection.Input)
                         , helper.CreateParameter("P_WRK_ORDR_NO", Common.WrkOrderNo, DbType.String, ParameterDirection.Input)
                         , helper.CreateParameter("P_WRK_ORDR_SEQNO", Common.WrkOrderSeq, DbType.String, ParameterDirection.Input)
                         , helper.CreateParameter("P_MATNR", Common.ItemCode, DbType.String, ParameterDirection.Input)
                         , helper.CreateParameter("P_WRK_ROLLCNT", lblROLLCNT.Text.Replace(",", ""), DbType.String, ParameterDirection.Input) //권치수
                         , helper.CreateParameter("P_WRK_WIDTH", lblWorkWidth.Text.Replace(",", ""), DbType.String, ParameterDirection.Input) //지폭
                         , helper.CreateParameter("P_WRK_QTY", lblWGT.Text.Replace(",", ""), DbType.String, ParameterDirection.Input)//중량
                         , helper.CreateParameter("P_PRD_STR_DATE", dNowStartDate.ToString("yyyy-MM-dd HH:mm:ss"), DbType.String, ParameterDirection.Input)
                         , helper.CreateParameter("P_PRD_END_DATE", dNowEndDate.ToString("yyyy-MM-dd HH:mm:ss"), DbType.String, ParameterDirection.Input)
                         , helper.CreateParameter("P_TM", lblTM.Text.Replace(",", ""), DbType.String, ParameterDirection.Input)
                         , helper.CreateParameter("P_SPEED", lblWorkSpeed.Text.Replace(",", ""), DbType.String, ParameterDirection.Input)
                         , helper.CreateParameter("P_RMK", txtRMK.Text, DbType.String, ParameterDirection.Input)
                         , helper.CreateParameter("P_WRK_DATE", Common.dateFormat("I", lblPRFM_DT.Text), DbType.String, ParameterDirection.Input)
                         , helper.CreateParameter("P_WDOC_NO", DbType.String, ParameterDirection.Output, null, 30)
                         , helper.CreateParameter("P_USE_FUNC", DbType.String, ParameterDirection.Output, null, 30)
                           );

                if (helper.RSCODE == "E")
                {
                    this.Cursor = Cursors.Default;   //Waitting
                    new POPUP.MessageForm(helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    helper.Rollback();
                    
                    return;
                }
                else if (helper.RSCODE == "N")
                {
                    this.Cursor = Cursors.Default;   //Waitting
                    new POPUP.MessageForm("자재의 수량이 부족합니다.\n" + helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    helper.Rollback();
                    return;
                }
                else
                {
                    //출고요청 문서번호 저장
                    sWDocNo = helper.Parameters["P_WDOC_NO"].Value.ToString();
                    sUseFunc = helper.Parameters["P_USE_FUNC"].Value.ToString();
                    //SAP 실적 등록
                    SAPHelper sapRFC = new SAPHelper();
                    if (sapRFC.CallSAPFunc_HL(helper.RSMSG, dsTemp.Tables[2], dsTemp.Tables[3], helper).Equals("S"))
                    {
                        sapRFC.SaveResulttoWrk_HL(helper, "POP_WRK012", "0");
                        helper.Commit();
                        new POPUP.MessageForm("실적이 정상적으로 등록되었습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                       
                        doPrint(dsTemp.Tables[0]);
                        this.Cursor = Cursors.Default;   //Waitting
                        this.Close();
                    }
                    else
                    {
                        this.Cursor = Cursors.Default;   //Waitting
                        throw new Exception("SAP전송이 실패하였습니다.\n" + sapRFC.rtnMSG);
                    }
                    helper.Commit();
                }
            }
            catch (Exception ex)
            {
                this.Cursor = Cursors.Default;   //Waitting
                RollbackLog(helper, dsTemp, ex.Message, sResult);
                helper.Rollback();

                string sRollBackMsg = ex.Message + Environment.NewLine + "MES ROLLBACK 실적 취소되었습니다";
                new POPUP.MessageForm_ERR("알   림", sRollBackMsg, MessageBoxButtons.OK).ShowDialog(this);
            }
            finally
            {
                this.Cursor = Cursors.Default;   //Waitting
                helper.Close();
            }
        }

        private void RollbackLog(DBHelper helper, DataSet dsTemp, string sMSG_ERR, string sResult)
        {
            if (dsTemp.Tables.Count == 0) return;
            if (dsTemp.Tables[3] != null)
            {
                if (dsTemp.Tables[3].Rows[0][0].ToString() != "1")
                {
                    foreach (DataRow Rows in dsTemp.Tables[3].Rows) //실적등록 실패시 롤백 발생원인 저장
                    {
                        helper.ExecuteNoneQuery("SP_HL_ROLLBACK_LOG", CommandType.StoredProcedure
                        , helper.CreateParameter("P_DOC_NO", Rows["MDOCNO"], DbType.String, ParameterDirection.Input)
                        , helper.CreateParameter("P_DOC_SEQNO", Rows["MDOCSEQ"], DbType.String, ParameterDirection.Input)
                        , helper.CreateParameter("P_LOT_NO", Rows["LOTNO"], DbType.String, ParameterDirection.Input)
                        , helper.CreateParameter("P_ORDER_NO", Rows["AUFNR"], DbType.String, ParameterDirection.Input)
                        , helper.CreateParameter("P_WERKS", Rows["WERKS"], DbType.String, ParameterDirection.Input)
                        , helper.CreateParameter("P_WORKCENTERCODE", Rows["WORKCENTERCODE"].ToString(), DbType.String, ParameterDirection.Input)
                        , helper.CreateParameter("P_MACH_CD", Rows["MACHINE"], DbType.String, ParameterDirection.Input)
                        , helper.CreateParameter("P_PRDCD", Rows["PRDCD"], DbType.String, ParameterDirection.Input)
                        , helper.CreateParameter("P_QTY", Rows["PROQTY"], DbType.String, ParameterDirection.Input)
                        , helper.CreateParameter("P_MATNR", "", DbType.String, ParameterDirection.Input)
                        , helper.CreateParameter("P_BUDAT", Rows["PRDDT"], DbType.String, ParameterDirection.Input)
                        , helper.CreateParameter("P_RESULT", sResult, DbType.String, ParameterDirection.Input)
                        , helper.CreateParameter("P_REMARK", sMSG_ERR, DbType.String, ParameterDirection.Input)
                        , helper.CreateParameter("P_MBLNR", "", DbType.String, ParameterDirection.Input)
                        , helper.CreateParameter("P_MJAHR", "", DbType.String, ParameterDirection.Input)
                        , helper.CreateParameter("P_I_IF_ID", dsTemp.Tables[2].Rows[0]["I_IF_ID"].ToString(), DbType.String, ParameterDirection.Input)
                        , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input));
                    }
                }
            }
        }

        private void doWaste()
        {
            DateTime dtStartTime;
            DateTime dtEndTime;

            string sBasisWgt = dtNowWrk.Rows[0]["BS_WGT"].ToString();//평량
            string sWidth = dtNowWrk.Rows[0]["WIDTH"].ToString();//지폭
            string sLength = lblROLLCNT.Text;//길이(권치수)
            string sUnit = dtNowWrk.Rows[0]["UNIT"].ToString();//단위

            double nBasisWgt;//평량
            int nWidth;//지폭
            int nLength;//길이(권치수)

            //생산실지폭 입력시 처리
            sWidth = (string.IsNullOrEmpty(lblWorkWidth.Text) ? sWidth : lblWorkWidth.Text).Replace(",", "");
            //권치수 양식 수정
            sLength = sLength.Replace(",", "");

            if (!double.TryParse(sBasisWgt, out nBasisWgt))
                nBasisWgt = 0;
            if (!int.TryParse(sWidth, out nWidth))
                nWidth = 0;
            if (!int.TryParse(sLength, out nLength))
                nLength = 0;

            DateTime dtNow = DateTime.Now;

            if (lblPRD_STR_DATE.Text.Contains(":"))
            {
                string sStartDate = dtpPRD_STR_DATE.Value.ToString("yyyyMMdd") + lblPRD_STR_DATE.Text.ToString().Replace(":", "") + "00";

                if (DateTime.TryParseExact(sStartDate, "yyyyMMddHHmmss", null, DateTimeStyles.AssumeLocal, out dtStartTime) == false)
                {
                    dtStartTime = dtNow;
                }
            }
            else
            {
                dtStartTime = dtNow;
            }

            if (lblPRD_END_TIME.Text.Contains(":"))
            {
                string sEndDate = dtpPRD_END_DATE.Value.ToString("yyyyMMdd") + lblPRD_END_TIME.Text.ToString().Replace(":", "") + "00";
                if (DateTime.TryParseExact(sEndDate, "yyyyMMddHHmmss", null, DateTimeStyles.AssumeLocal, out dtEndTime) == false)
                {
                    dtEndTime = dtNow;
                }
            }
            else
            {
                dtEndTime = dtNow;
            }

            if (nBasisWgt == 0.0)
            {
                new POPUP.MessageForm("평량정보를 확인하여 주시기 바랍니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return;
            }
            if (nWidth == 0)
            {
                new POPUP.MessageForm("지폭은 0이 될수 없습니다.\n지폭정보를 변경하여주시기 바랍니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return;
            }

            // 시작일시, 종료일시, 평량, 지폭, 단위, 실적중량, 폐품중량
            POP_WRK43 WRK43 = new POP_WRK43(dtStartTime, dtEndTime, nBasisWgt, nWidth, sUnit, sPRFMQty, sDISPOQty);
            if (ShowDialogForm(WRK43) == DialogResult.OK)
            {
            }
        }
        // 중량 계산
        private void WgtCalculation()
        {
            string sBasisWgt = dtNowWrk.Rows[0]["BS_WGT"].ToString();//평량
            string sWidth = dtNowWrk.Rows[0]["WIDTH"].ToString();//지폭
            string sLength = lblROLLCNT.Text;//길이(권치수)

            double nBasisWgt;//평량
            double nWidth;//지폭
            double nLength;//길이(권치수)

            double nMulCnt = double.TryParse(lblMulCnt.Text.Replace(",",""), out nMulCnt) ? nMulCnt : 0.0; //겹수
            double nTotWgt = double.TryParse(lblWGT.Text.Replace(",", ""), out nTotWgt) ? nTotWgt : 0.0; ;//중량

            //생산실지폭 입력시 처리
            sWidth = (string.IsNullOrEmpty(lblWorkWidth.Text) ? sWidth : lblWorkWidth.Text).Replace(",", "");
            //권치수 양식 수정
            sLength = sLength.Replace(",", "");

            if (!double.TryParse(sBasisWgt, out nBasisWgt))
                nBasisWgt = 0;
            if (!double.TryParse(sWidth, out nWidth))
                nWidth = 0;
            if (!double.TryParse(sLength, out nLength))
                nLength = 0;

            //계산시 최대숫자 초과로 인한 에러 수정(mg->kg)
            double dValue;
            if (nLength > 0.0)
            {
                dValue = (nLength * ((nBasisWgt / 1000) * (nWidth / 1000))) * nMulCnt;
                lblWGT.Text = string.Format("{0:#,0.000}", dValue);
            }
            else
            {
                dValue = (nTotWgt / ((nBasisWgt / 1000) * (nWidth / 1000))) / nMulCnt;
                lblROLLCNT.Text = string.Format("{0:#,0}", dValue);
            }
        }

        // 가동시간 / 선속 / 중량 계산
        private void AutoCalculation()
        {
            DateTime dtStartDate;
            DateTime dtEndDate;

            if ((lblPRD_STR_DATE.Text.ToString().Length != 5) || (lblPRD_END_TIME.Text.ToString().Length != 5))
            {
                lblTM.Text = "0";
                lblWorkSpeed.Text = "0";
                return;
            }

            string sStartDate = dtpPRD_STR_DATE.Value.ToString("yyyy-MM-dd") + " " + lblPRD_STR_DATE.Text.ToString() + ":00";
            if (Common.IsDateTime(sStartDate) == false)
            {
                lblTM.Text = "0";
                lblWorkSpeed.Text = "0";
                return;
            }

            string sEndDate = dtpPRD_END_DATE.Value.ToString("yyyy-MM-dd") + " " + lblPRD_END_TIME.Text.ToString() + ":00";
            if (Common.IsDateTime(sEndDate) == false)
            {
                lblTM.Text = "0";
                lblWorkSpeed.Text = "0";
                return;
            }

            dtStartDate = Convert.ToDateTime(sStartDate);
            dtEndDate = Convert.ToDateTime(sEndDate);

            TimeSpan Diff_dates = dtEndDate.Subtract(dtStartDate);

            if (Diff_dates.TotalMinutes > 0)
            {
                lblTM.Text = string.Format("{0:#,0}", Diff_dates.TotalMinutes);

                int nROLLCNT = int.TryParse(lblROLLCNT.Text.Replace(",", ""), out nROLLCNT) ? nROLLCNT : 0; // 권치수

                if (nROLLCNT > 0)
                {
                    lblWorkSpeed.Text = string.Format("{0:#,0}", (int)((nROLLCNT / Diff_dates.TotalMinutes) + 0.5)); // 선속
                }
                SetMessage("");
            }
            else
            {
                lblTM.Text = "0";
                lblWorkSpeed.Text = "0";
                lblPRD_END_TIME.Text = string.Empty;

                SetMessage("작업 시작일시/종료일시를 확인하세요!");
                new POPUP.MessageForm("작업 종료일시는 작업시작일시보다 같거나 빠를수 없습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return;
            }
        }


        private void DateCalc()
        {
            DateTime dtStartDate;
            DateTime dtEndDate;

            string sStartDate = dtpPRD_STR_DATE.Value.ToString("yyyy-MM-dd") + " " + lblPRD_STR_DATE.Text.ToString() + ":00";
            string sEndDate = dtpPRD_END_DATE.Value.ToString("yyyy-MM-dd") + " " + lblPRD_END_TIME.Text.ToString() + ":00";

            //실적등록일자 표기
            if (Common.IsDateTime(sEndDate) == false)
            {
                if (DateTime.TryParse(sStartDate, out dtStartDate))
                    lblPRFM_DT.Text = Common.dateFormat("O", Common.GetRecDate(dtStartDate));
            }
            else
            {
                if (DateTime.TryParse(sEndDate, out dtEndDate))
                    lblPRFM_DT.Text = Common.dateFormat("O", Common.GetRecDate(dtEndDate));
            }
        }


        private void doPrint(DataTable dtTemp)
        {
            //조회결과 입력용 Row생성
            REPORT_ITEM HLitem = new REPORT_ITEM();

            HLitem.MACH_NM = dtTemp.Rows[0]["MACH_NM"].ToString();          // 설비호기 명
            HLitem.LOT_NO = dtTemp.Rows[0]["LOT_NO"].ToString();            // LOT NO
            HLitem.SPEC = dtTemp.Rows[0]["MATNR_NM"].ToString();               // 제품규격(품명)
            HLitem.PRFM_ROLLCNT = dtTemp.Rows[0]["ROLLCNT"].ToString();     // 길이
            HLitem.BS_WGT = dtTemp.Rows[0]["BS_WGT"].ToString();            // 편량
            HLitem.PRFM_WGT = dtTemp.Rows[0]["PRFM_WGT"].ToString();        // 중량
            HLitem.COLOR = dtTemp.Rows[0]["COLOR"].ToString();              // 색
            HLitem.WRK_NAME = dtTemp.Rows[0]["WRK_NAME"].ToString();        // 작업자
            HLitem.QCJUD = dtTemp.Rows[0]["QCJUD"].ToString();              // 판정
            HLitem.IND_BCD = dtTemp.Rows[0]["IND_BCD"].ToString();          // 바코드

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
                        doConfirm();
                        break;
                    case "Waste":  //폐품등록
                        doWaste();
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
                LogFile.WriteLog("POP_WRK12.bBox1_buttonClickEvent Error\r\n" + ex.Message);
            }
            finally
            {

            }
        }

        private void butWorkDate_Click(object sender, EventArgs e)
        {
            Button btnTemp = (Button)sender;

            DateTime dt = DateTime.Today;
            if (btnTemp.Tag.ToString() == "startDate")
            {
                dt = dtpPRD_STR_DATE.Value;
            }
            else
            {
                dt = dtpPRD_END_DATE.Value;
            }

            DAResultDate pop = new DAResultDate(dt);
            pop.ShowDialog(this);
            if (pop.DialogResult == DialogResult.OK)
            {
                string strDate = pop.ResultString.ToString();
                if (btnTemp.Tag.ToString() == "startDate")
                {
                    dtpPRD_STR_DATE.Value = DateTime.Parse(strDate);
                }
                else if (btnTemp.Tag.ToString() == "endDate")
                {
                    dtpPRD_END_DATE.Value = DateTime.Parse(strDate);
                }

                AutoCalculation();
                DateCalc();
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
                AutoCalculation();
                DateCalc();
            }
        }

        private void lblWorkWidth_Click(object sender, EventArgs e)
        {
            DAResultQty pop = new DAResultQty();
            pop.LabelTitle = "지폭 입력";
            pop.LabelHeader = "지폭";
            pop.ContentMaxLength = 8;

            pop.ShowDialog(this);

            if (pop.DialogResult == DialogResult.OK)
            {
                double dlWorkWidth = 0;
                dlWorkWidth = pop.ResultDouble;
                lblWorkWidth.Text = string.Format("{0:#,0}", ((int)dlWorkWidth));
                // 지폭 입력시 중량/선속을 갱신해야 하는지 PI팀에서 결정후 업데이트...
                // 현재는 중량이 변경됨, 권치수를 갱신하려면 lblROLLCNT.Text = string.Empty; 추가 해야함.
                //WgtCalculation();
                //AutoCalculation();
            }
        }

        private void lblWrkQty_Click(object sender, EventArgs e)
        {
            //중량 입력을 통한 권치수 계산처리로 인한 기능삭제
            return;
            //DAResultQty pop = new DAResultQty();
            //pop.LabelTitle = "권치수 입력";
            //pop.LabelHeader = "권치수(M)";
            //pop.ContentMaxLength = 8;

            //pop.ShowDialog(this);

            //if (pop.DialogResult == DialogResult.OK)
            //{
            //    dDimension = pop.ResultDouble;
            //    lblWrkQty.Text = string.Format("{0:#,0}", dDimension);
            //    WgtCalculation();
            //    AutoCalculation();
            //}
        }

        private void lblMulCnt_Click(object sender, EventArgs e)
        {
            DAResultQty pop = new DAResultQty();
            pop.LabelTitle = "겹수 입력";
            pop.LabelHeader = "겹수";
            pop.ContentMaxLength = 8;

            pop.ShowDialog(this);

            if (pop.DialogResult == DialogResult.OK)
            {
                double dMulCnt = 0;
                dMulCnt = pop.ResultDouble;
                lblMulCnt.Text = string.Format("{0:#,0}", dMulCnt);
                WgtCalculation();
                AutoCalculation();
            }
        }

        private void lblWGT_Click(object sender, EventArgs e)
        {
            DAResultNum pop = new DAResultNum();
            pop.LabelTitle = "중량 입력";
            pop.LabelHeader = "중량(Kg)";
            pop.ContentMaxLength = 8;

            pop.ShowDialog(this);

            if (pop.DialogResult == DialogResult.OK)
            {
                double dWGT = 0;

                lblROLLCNT.Text = string.Empty;
                dWGT = pop.ResultDouble;
                lblWGT.Text = string.Format("{0:#,0.###}", dWGT);
                WgtCalculation();
                AutoCalculation();
            }
        }

        private void dtpDate_DropDown(object sender, EventArgs e)
        {
            CommonCalendar.CloseCalendar((DateTimePicker)sender);
        }
        #endregion
        
    }
}
