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
    public partial class POP_WRK43 : BaseForm
    {
        #region < MEMBER AREA >


        private double giBS_WGT = 0;     // 평량
        private int giWIDTH = 0;       // 지폭
        private double gdROLLCNT = 0;       // 권치수
        private double gdWGT = 0;           // 중량

        private string gsUNIT = string.Empty;   // 단위

        private SAMMI.Common _common = new SAMMI.Common();

        private string sGrpCode = string.Empty;
        private string sSelectGrpCode = string.Empty;

        private string gsDISPO_CD = string.Empty;       // 폐품코드
        private string gsDISPO_NAME = string.Empty;     // 폐품명

        #endregion

        #region < CONSTRUCTOR >

        public POP_WRK43()
        {
            InitializeComponent();

            Common.SetMessageList();

        }

        public POP_WRK43(DateTime dtStartTime, DateTime dtEndTime, double nBasisWgt, int nWidth, string sUNIT, string sPRFM_WGT, string sDISP_QTY)
        {
            InitializeComponent();

            Common.SetMessageList();

            giBS_WGT = nBasisWgt;
            giWIDTH = nWidth;

            gsUNIT = sUNIT;

            dtpStartDate.Value = dtStartTime;
            lblStartTime.Text = dtpStartDate.Value.ToString("HH:mm");       // 작업시작시간

            dtpEndDate.Value = dtEndTime;
            lblEndTime.Text = dtpEndDate.Value.ToString("HH:mm");       // 작업종료시간

            //lblBS_WGT.Text = string.Format("{0:#,0}", giBS_WGT);
            lblBS_WGT.Text = string.Format("{0:#,0.###}", giBS_WGT);
            lblWIDTH.Text = string.Format("{0:#,0}", nWidth);

            lblPRFM_WGT.Text =  Common.StrFormatInteger(sPRFM_WGT);
            lblDISPO_QTY.Text = Common.StrFormatInteger(sDISP_QTY);

            lblDISPO_NAME.Tag = "";
        }


        #endregion

        #region < POP_WRK43_Load >
        private void POP_WRK43_Load(object sender, EventArgs e)
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

                this.lblTitle.Text = "합지기 폐품 등록";

                SetMenuButtons();
                SetGroupButtons(Common.OpCode);
                SetItemButtons(Common.OpCode, sGrpCode);

                doFind();

                AutoCalculation();
            }
            catch (Exception ex)
            {
                SetMessage("POP_WRK43_Load_ Error!");
                LogFile.WriteLog("POP_WRK43.POP_WRK43_Load Error\r\n" + ex.Message);
            }

            //현재 메시지큐에 있는 모든 메시지 처리함수 
            SendKeys.Flush();
        }
        #endregion

        #region < CALC_AREA >
        // 가동시간 / 선속 / 중량 계산
        private void AutoCalculation()
        {
            DateTime dtStartDate;
            DateTime dtEndDate;

            WgtCalculation();

            if ((lblStartTime.Text.ToString().Length != 5) || (lblEndTime.Text.ToString().Length != 5))
            {
                lblPRFM_DT.Text = "";                   // 생산실적일자
                lblTM.Text = "0";
                lblRSPEED.Text = "0";
                return;
            }

            string sStartDate = dtpStartDate.Value.ToString("yyyy-MM-dd") + " " + lblStartTime.Text.ToString() + ":00";
            if (Common.IsDateTime(sStartDate) == false)
            {
                lblPRFM_DT.Text = "";                   // 생산실적일자
                lblTM.Text = "0";
                lblRSPEED.Text = "0";
                return;
            }

            string sEndDate = dtpEndDate.Value.ToString("yyyy-MM-dd") + " " + lblEndTime.Text.ToString() + ":00";
            if (Common.IsDateTime(sEndDate) == false)
            {
                lblPRFM_DT.Text = "";                   // 생산실적일자
                lblTM.Text = "0";
                lblRSPEED.Text = "0";
                return;
            }

            dtStartDate = Convert.ToDateTime(sStartDate);
            dtEndDate = Convert.ToDateTime(sEndDate);

            TimeSpan Diff_dates = dtEndDate.Subtract(dtStartDate);


            if (Diff_dates.TotalMinutes > 0)
            {
                string sDate = Common.GetRecDate(dtStartDate);                   // 생산실적일자
                if (string.IsNullOrEmpty(sDate) == false)
                {
                    try
                    {
                        lblPRFM_DT.Text = DateTime.ParseExact(sDate, "yyyyMMdd", null).ToString("yyyy-MM-dd");
                    }
                    catch (FormatException)
                    {
                        Console.WriteLine("{0} is not in the correct format.", sDate);
                        lblPRFM_DT.Text = "";
                    }
                }

                lblTM.Text = string.Format("{0:#,0}", Diff_dates.TotalMinutes);
                lblRSPEED.Text = string.Format("{0:#,0}", (int)((gdROLLCNT / Diff_dates.TotalMinutes) + 0.5));
            }
            else
            {
                lblPRFM_DT.Text = "";
                lblTM.Text = "0";
                lblRSPEED.Text = "0";
            }
        }

        // 중량 계산
        private void WgtCalculation()
        {
            if (giBS_WGT <= 0.0 || giWIDTH <= 0 || gdWGT <= 0)
            {
                lblWGT.Text = "0";
                gdROLLCNT = 0;
                return;
            }
            double dValue = (double)gdWGT / ((giBS_WGT / 1000.0) * ((double)giWIDTH / 1000.0));
            lblROLLCNT.Text = string.Format("{0:#,0}", dValue);
            gdROLLCNT = Math.Round(dValue);      // 중량
        }
        #endregion

        #region < METHOD AREA >

        private void doFind()
        {
            DBHelper helper = new DBHelper(false);

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
                    //실적, 폐품 정보 저장
                    lblPRFM_WGT.Text = Common.StrFormatInteger(helper.Parameters["P_PRFM_QTY"].Value.ToString());
                    lblDISPO_QTY.Text = Common.StrFormatInteger(helper.Parameters["P_DISPO_QTY"].Value.ToString());
                }
            }
            catch (Exception ex)
            {
                SetMessage("DateSet Error!");
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                LogFile.WriteLog("POP_WRK43.DateSet Error\r\n" + ex.Message);
            }
            finally
            {
                helper.Close();
            }
        }

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

                bBox1[0, 0].Text = "폐품등록";
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
                LogFile.WriteLog("POP_WRK43.SetButtons Error\r\n" + ex.Message);
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
                bGroup_Up.LinkMoveSize = bItem.CountY;
                bGroup_Down.LinkMoveSize = bItem.CountY;
                //버튼 폰트
                bGroup.FontSize = 20;
                //버튼 목록 조회
                System.Data.DataSet ds = helper.FillDataSet("SP_POP_WRK43_S01", CommandType.StoredProcedure
                                                               , helper.CreateParameter("P_PROC_CD", pGrp, DbType.String, ParameterDirection.Input));
                if (ds.Tables[0].Rows.Count < 1)
                {
                    SetMessage("조회된 폐품그룹이 없습니다.");
                    return;
                }
                else
                {
                    bGroup.DoFind_Oracle(ds);
                }
                //버튼 출력
                bGroup.RedrawButtons();

                bGroup[0, 0].ButtonPressed = true;
                sGrpCode = bGroup[0, 0].Tag.ToString();
            }
            catch (Exception ex)
            {
                SetMessage("SetOPButtons Error!");
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                LogFile.WriteLog("DA0110.SetOPButtons Error\r\n" + ex.Message);
            }
        }

        private void SetItemButtons(string pGrp, string pDispoClass)
        {
            DBHelper helper = new DBHelper();
            DataTable dt = new DataTable();

            try
            {
                //작업자
                bItem.ButtonBoxType = ButtonBox.ButtonBoxTypeEnum.Selection;
                bItem.SelectionMode = ButtonBox.SelectionModeEnum.Single;

                //출력 버튼수
                bItem.CountX = 4;
                bItem.CountY = 5;

                //화살표 클릭시 이동수
                bItem_Up.LinkMoveSize = bItem.CountY;
                bItem_Down.LinkMoveSize = bItem.CountY;

                btnLeftPage.LinkMoveSize = bItem.CountY;
                btnRightPage.LinkMoveSize = bItem.CountY;

                //버튼 폰트
                bItem.FontSize = 14;
                //버튼 목록 조회
                System.Data.DataSet ds = helper.FillDataSet("SP_POP_WRK43_S02", CommandType.StoredProcedure
                                                               , helper.CreateParameter("P_PROC_CD", pGrp, DbType.String, ParameterDirection.Input)             // 
                                                               , helper.CreateParameter("P_DISPO_DIV", pDispoClass, DbType.String, ParameterDirection.Input));  // 폐품유형
                if (ds.Tables[0].Rows.Count < 1)
                {
                    SetMessage("조회된 폐품항목이 없습니다.");
                    new POPUP.MessageForm("조회된 폐품항목이 없습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return;
                }
                else
                {
                    bItem.DoFind_Oracle(ds);
                }

                // 이전에 선택된 item을 다시 선택으로 지정
                if (string.IsNullOrEmpty(sSelectGrpCode) == false && string.IsNullOrEmpty(gsDISPO_CD) == false)
                {
                    if (sSelectGrpCode.Equals(sGrpCode))
                    {
                        ButtonData btnData = bItem.GetButtonByTag(gsDISPO_CD);
                        if (btnData != null)
                        {
                            btnData.ButtonPressed = true;
                        }
                    }
                }

                //버튼 출력
                bItem.RedrawButtons();
            }
            catch (Exception ex)
            {
                SetMessage("SetButtons Error!");
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                LogFile.WriteLog("POP_WRK43.SetButtons Error\r\n" + ex.Message);
            }
        }


        private void doConfirm()
        {
            DataSet dsTemp = new DataSet(); //실적등록 결과 수신(0:라벨정보, 1:RFC 변수, 2:RFC 상세변수)
            string sResult = string.Empty;
            //rollback용 
            //SAP 롤백용 추가 CODE 범위 START
            DataTable sapTemp = new DataTable(); // 성공한 sap 정보 저장
            //SAP 롤백용 추가 CODE 범위 END
            //rollback용 end
            string sUSE_Func;
            string sPRFM_Func;
            string sDISPO_Func;

            if (string.IsNullOrEmpty(gsDISPO_CD))
            {
                new POPUP.MessageForm("폐품코드 선택은 필수 입니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return;
            }

            string sStartDateTime = dtpStartDate.Value.ToString("yyyyMMdd") + lblStartTime.Text.ToString().Replace(":", "") + "00";
            DateTime dtStartTime;
            if (DateTime.TryParseExact(sStartDateTime, "yyyyMMddHHmmss", null, DateTimeStyles.AssumeLocal, out dtStartTime) == false)
            {
                new POPUP.MessageForm("작업 시작일시 확인하세요!", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return;
            }

            string sEndDateTime = dtpEndDate.Value.ToString("yyyyMMdd") + lblEndTime.Text.ToString().Replace(":", "") + "00";
            DateTime dtEndTime;
            if (DateTime.TryParseExact(sEndDateTime, "yyyyMMddHHmmss", null, DateTimeStyles.AssumeLocal, out dtEndTime) == false)
            {
                new POPUP.MessageForm("작업 종료일시 확인하세요!", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return;
            }

            string sWrkTime = lblTM.Text.ToString().Replace(",", "");     // 선속
            int nWrkTime = 0;
            if ((Common.isStr2Int(sWrkTime, out nWrkTime) == false) || (nWrkTime <= 0))
            {
                new POPUP.MessageForm("작업 시작일시/종료일시를 확인하세요!", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return;
            }

            // 지폭 확인
            int.TryParse(lblWIDTH.Text.ToString().Replace(",", ""), out giWIDTH);      // 등록할권치수 int
            if (giWIDTH <= 0)
            {
                new POPUP.MessageForm("지폭정보를 확인하세요!", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return;
            }

            // 권치수 확인
            double.TryParse(lblWGT.Text.ToString().Replace(",", ""), out gdWGT);      // 등록할권치수 int
            if (gdWGT <= 0)
            {
                new POPUP.MessageForm("중량 입력은 필수 입니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return;
            }

            int iRSPEED = 0;
            int.TryParse(lblRSPEED.Text.ToString().Replace(",", ""), out iRSPEED);  // 선속

            DBHelper helper = new DBHelper(false,"",true);
            try
            {
                //rollback용 
                //SAP 롤백용 추가 CODE 범위 START
                sapTemp = new DataTable();
                sapTemp.Columns.Add("SAP_TYPE", typeof(string));
                sapTemp.Columns.Add("IF_KEY", typeof(string));
                sapTemp.Columns.Add("MDOCNO", typeof(string));
                sapTemp.Columns.Add("MDOCSEQ", typeof(string));
                //SAP 롤백용 추가 CODE 범위 END
                //rollback용 end

                this.Cursor = Cursors.WaitCursor;   //Waitting
                dsTemp = helper.FillDataSetN("SP_POP_WRK43_I01", CommandType.StoredProcedure, 4
                    , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)      // 플랜트
                    , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)         // 작업장코드(설비코드)
                    , helper.CreateParameter("P_DISPO_CD", gsDISPO_CD, DbType.String, ParameterDirection.Input)           // 폐품코드
                    , helper.CreateParameter("P_UNIT", gsUNIT, DbType.String, ParameterDirection.Input)                // 실적단위
                    , helper.CreateParameter("P_WIDTH", giWIDTH, DbType.Double, ParameterDirection.Input)       // 폐품권치수
                    , helper.CreateParameter("P_ROLLCNT", gdROLLCNT, DbType.Double, ParameterDirection.Input)       // 폐품권치수
                    , helper.CreateParameter("P_DISPO_QTY", gdWGT, DbType.Double, ParameterDirection.Input)         // 폐품중량
                    , helper.CreateParameter("P_RSPEED", iRSPEED, DbType.Double, ParameterDirection.Input)                      // 선속
                    , helper.CreateParameter("P_PRD_STR_DATE", sStartDateTime, DbType.String, ParameterDirection.Input)         // 생산시작 일시
                    , helper.CreateParameter("P_PRD_END_DATE", sEndDateTime, DbType.String, ParameterDirection.Input)           // 생산 종료 일시
                    , helper.CreateParameter("P_TM", sWrkTime, DbType.String, ParameterDirection.Input)                 // 생산시간(분)
                    , helper.CreateParameter("P_PRFM_DT", lblPRFM_DT.Text.ToString().Replace("-", ""), DbType.String, ParameterDirection.Input) // 생산실적일자
                    , helper.CreateParameter("P_RMK", lb_RMK.Text.ToString(), DbType.String, ParameterDirection.Input)             // 비고
                    , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input)             // 사용자ID
                    , helper.CreateParameter("P_USE_FUNC", DbType.String, ParameterDirection.Output, null, 30) //폐품시 자재소요량(와딩투입합지롤)
                    , helper.CreateParameter("P_PRFM_FUNC", DbType.String, ParameterDirection.Output, null, 30) //폐품실적
                    , helper.CreateParameter("P_DISPO_FUNC", DbType.String, ParameterDirection.Output, null, 30) //폐품이력
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
                    sUSE_Func = helper.Parameters["P_USE_FUNC"].Value.ToString();
                    sPRFM_Func = helper.Parameters["P_PRFM_FUNC"].Value.ToString();
                    sDISPO_Func = helper.Parameters["P_DISPO_FUNC"].Value.ToString();

                    //SAP 소요량sUSE_Func 등록
                    if (!string.IsNullOrEmpty(sUSE_Func))
                    {
                        //SAPHelper sapRFC_U = new SAPHelper();
                        //if (sapRFC_U.CallSAPFunc(sPRFM_Func, dsTemp.Tables[0], dsTemp.Tables[1], helper).Equals("S"))
                        //{
                        //    //RFC 전송 결과 조회
                        //    dtTemp = sapRFC_U.rtnTable;
                        //    sRFCList = Common.toJsonFormat("POP_WRK043", dtTemp);
                        //    sRFCList = sRFCList.Replace("MBLNR", "RUECK");
                        //    sRFCList = sRFCList.Replace("MJAHR", "RMZHL");
                        //    //RFC 결과정보 DB등록
                        //    helper.ExecuteNoneQuery("SP_IF_PUT_WRKRTN", CommandType.StoredProcedure
                        //                                      , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)
                        //                                      , helper.CreateParameter("P_WRK_TYPE", "0", DbType.String, ParameterDirection.Input)
                        //                                      , helper.CreateParameterOracle("P_RFC_DATA", sRFCList, OracleDbType.Clob, ParameterDirection.Input)
                        //                                      , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input));
                        //}
                        //else
                        //{
                        //    new POPUP.MessageForm("폐품실적의 자재사용량 정보 SAP전송이 실패하였습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                        //    helper.Rollback();
                        //}
                    }

                    //SAP 실적 등록
                    if (!string.IsNullOrEmpty(sPRFM_Func))
                    {
                        SAPHelper sapRFC_P = new SAPHelper();
                        if (sapRFC_P.CallSAPFunc_HL(sPRFM_Func, dsTemp.Tables[0], dsTemp.Tables[1], helper).Equals("S"))
                        {
                            sapRFC_P.SaveResulttoWrk_HL(helper, "POP_WRK043", "0");

                            //rollback용
                            //SAP 롤백용 추가 CODE 범위 START
                            string sTempSAP_TYPE = string.Empty;
                            string sTempIF_KEY = string.Empty;
                            string sTempMDOC_NO = string.Empty;
                            string sTempMDOC_SEQNO = string.Empty;
                            string sTempMBLNR = string.Empty;
                            string sTempMJAHR = string.Empty;
                            sTempSAP_TYPE = "PROD_REG_SAP";
                            sTempIF_KEY = dsTemp.Tables[0].Rows[0]["I_IF_KEY"].ToString();
                            if (!dsTemp.Tables[1].Columns.Contains("MBLNR") && !dsTemp.Tables[1].Columns.Contains("MJAHR"))
                            {
                                dsTemp.Tables[1].Columns.Add("MBLNR", typeof(string));
                                dsTemp.Tables[1].Columns.Add("MJAHR", typeof(string));
                            }
                            foreach (DataRow Rows in dsTemp.Tables[1].Rows)
                            {
                                sTempMDOC_NO = Rows["MDOCNO"].ToString();
                                sTempMDOC_SEQNO = Rows["MDOCSEQ"].ToString();
                                sapTemp.Rows.Add(sTempSAP_TYPE, sTempIF_KEY, sTempMDOC_NO, sTempMDOC_SEQNO); // 후단 코드 실행시 EXCEPTION 상황 SAP CANCLE 정보 -- 실적등록
                                foreach (DataRow rfcRows in sapRFC_P.rtnTable.Rows)
                                {
                                    string sMBLNRtemp = string.Empty;
                                    string sMJAHRtemp = string.Empty;
                                    sMBLNRtemp = rfcRows["MBLNR"].ToString();
                                    sMJAHRtemp = rfcRows["MJAHR"].ToString();
                                    if (Rows["MDOCNO"].ToString() == rfcRows["MDOCNO"].ToString() && Convert.ToInt32(Rows["MDOCSEQ"].ToString()) == Convert.ToInt32(rfcRows["MDOCSEQ"].ToString()))
                                    {
                                        Rows["MBLNR"] = sMBLNRtemp;
                                        Rows["MJAHR"] = sMJAHRtemp;
                                    }
                                }
                            }
                            //SAP 롤백용 추가 CODE 범위 END
                            //rollback용 end
                        }
                        else
                        {
                            this.Cursor = Cursors.Default;   //Waitting
                            throw new Exception("폐품실적 SAP전송이 실패하였습니다.\n" + sapRFC_P.rtnMSG);
                        }
                    }
                    
                    //SAP 폐품 등록
                    SAPHelper sapRFC_D = new SAPHelper();
                    if (sapRFC_D.CallSAPFunc_HL(sDISPO_Func, dsTemp.Tables[2], dsTemp.Tables[3], helper).Equals("S"))
                    {
                        this.Cursor = Cursors.Default;   //Waitting
                        sapRFC_D.SaveResulttoWrk_HL(helper, "POP_WRK043", "1");
                        helper.Commit();
                        new POPUP.MessageForm("폐품이력이 정상적으로 등록되었습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                        return;
                    }
                    else
                    {
                        this.Cursor = Cursors.Default;   //Waitting
                        throw new Exception("폐품이력 SAP전송이 실패하였습니다.\n" + sapRFC_D.rtnMSG);
                    }
                }
            }
            catch (Exception ex)
            {
                sResult = "ROLLBACK";
                RollbackLog(helper, dsTemp, ex.Message, sResult, false);
                ProdRollback_HL(helper, sapTemp, dsTemp);
                helper.Rollback();
                this.Cursor = Cursors.Default;   //Waitting

                string sRollBackMsg = ex.Message + Environment.NewLine + "합지기 MES ROLLBACK 폐품등록 취소되었습니다";
                new POPUP.MessageForm_ERR("알   림", sRollBackMsg, MessageBoxButtons.OK).ShowDialog(this);
            }
            finally
            {

                this.Cursor = Cursors.Default;   //Waitting
                helper.Close();
            }
        }
        #endregion

        private void ProdRollback_HL(DBHelper helper, DataTable sapTemp, DataSet dsTemp)
        {
            try
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
                                dsTemp = helper.FillDataSetN("SP_POP_WRK43_IFR01", CommandType.StoredProcedure, 2
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
                                        sMSG_ERR += "HL 실적등록 ROLLBACK [" + helper.RSMSG.ToString() + "]";
                                        sResult = "S";
                                    }
                                    else
                                    {
                                        LogFile.WriteLog("HL ROLLBACK 오류 - SAP전송 오류 [" + sapRFC_1.rtnMSG + "]");
                                        sMSG_ERR += "HL ROLLBACK 오류 : " + sapRFC_1.rtnMSG + Environment.NewLine;
                                        sResult = "E";
                                    }
                                }
                                else //if (helper.RSCODE == "E")
                                {
                                    LogFile.WriteLog("HL ROLLBACK 등록 - MES IF TABLE 등록 오류 [" + helper.RSMSG.ToString() + "]");
                                    sMSG_ERR += "ROLLBACK MES IF TABLE 등록 오류 : " + helper.RSMSG.ToString() + Environment.NewLine;
                                    sResult = "E";
                                }
                                RollbackLog(helper, dsTemp, sMSG_ERR, sResult, true);
                                break;
                            default:
                                break;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                LogFile.WriteLog("HL ROLLBACK 에러 Exception 발생 [" + ex.Message + "]");
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
                                foreach (DataRow Rows in dsTemp.Tables[1].Rows) //실적등록 롤백 수행 로그 저장
                                {
                                    helper.ExecuteNoneQuery("SP_HL_ROLLBACK_LOG", CommandType.StoredProcedure
                                    , helper.CreateParameter("P_DOC_NO", Rows["MDOCNO"], DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_DOC_SEQNO", Rows["MDOCSEQ"], DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_LOT_NO", Rows["LOTNO"], DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_ORDER_NO", Rows["AUFNR"], DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_WORKCENTERCODE", Rows["WORKCENTERCODE"].ToString(), DbType.String, ParameterDirection.Input)
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
                else // sap 롤백발생원인에 대한 저장
                {
                    if (dsTemp.Tables.Count == 0) return;
                    if (dsTemp.Tables[1] != null)
                    {
                        if (dsTemp.Tables[1].Rows.Count > 0)//실적등록 및 폐품등록 실패시 롤백 발생원인 저장 - 실적등록 로그
                        {
                            if (dsTemp.Tables[1].Rows[0][0].ToString() != "1")//실적등록 및 폐품등록 실패시 롤백 발생원인 저장 - 실적등록 로그
                            {
                                foreach (DataRow Rows in dsTemp.Tables[1].Rows)
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
                                    , helper.CreateParameter("P_MBLNR", dsTemp.Tables[1].Columns.Contains("MBLNR") ? Rows["MBLNR"] : "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_MJAHR", dsTemp.Tables[1].Columns.Contains("MJAHR") ? Rows["MJAHR"] : "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_I_IF_ID", dsTemp.Tables[0].Rows[0]["I_IF_ID"].ToString(), DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input));
                                }
                            }
                        }
                    }
                    if (dsTemp.Tables[3] != null)
                    {
                        if (dsTemp.Tables[3].Rows.Count > 0)
                        {
                            if (dsTemp.Tables[3].Rows[0][0].ToString() != "1")
                            {
                                foreach (DataRow Rows in dsTemp.Tables[3].Rows)//실적등록 및 폐품등록 실패시 롤백 발생원인 저장 - 폐품등록 로그
                                {
                                    helper.ExecuteNoneQuery("SP_HL_ROLLBACK_LOG", CommandType.StoredProcedure
                                    , helper.CreateParameter("P_DOC_NO", Rows["MDOCNO"], DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_DOC_SEQNO", Rows["MDOCSEQ"], DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_LOT_NO", Rows["LOTNO"], DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_ORDER_NO", Rows["AUFNR"], DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_WORKCENTERCODE", Rows["WORKCENTERCODE"].ToString(), DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_MACH_CD", "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_PRDCD", "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_QTY", Rows["SCRQTY"], DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_MATNR", Rows["MATNR"], DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_BUDAT", Rows["BUDAT"], DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_RESULT", sResult, DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_REMARK", Rows["SCRAPREASON"].ToString() + " " + sMSG_ERR, DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_MBLNR", dsTemp.Tables[3].Columns.Contains("MBLNR") ? Rows["MBLNR"] : "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_MJAHR", dsTemp.Tables[3].Columns.Contains("MJAHR") ? Rows["MJAHR"] : "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_I_IF_ID", dsTemp.Tables[2].Rows[0]["I_IF_ID"].ToString(), DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input));
                                }
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                LogFile.WriteLog("합지기 폐품등록 LOG 기록 에러 Exception 발생 [" + ex.Message + "]");
            }
        }
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
                    case "Confirm":  //폐품 이력 등록
                        doConfirm();
                        doFind();
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
                LogFile.WriteLog("POP_WRK43.bBox1_buttonClickEvent Error\r\n" + ex.Message);
            }
            finally
            {

            }
        }

        private void bGroup_buttonChangeEvent(MESButton sender, ButtonBox.ButtonClickEventArg e)
        {
            //선택된 그룹코드
            sGrpCode = sender.Tag.ToString();
            //그룹별 작업자 목록 조회
            SetItemButtons(Common.OpCode, sGrpCode);
        }

        private void bItem_buttonChangeEvent(MESButton sender, ButtonBox.ButtonClickEventArg e)
        {
            if (bItem.GetSelectedButtons().Count > 0)
            {
                sSelectGrpCode = sGrpCode;

                gsDISPO_CD = sender.Tag.ToString();
                gsDISPO_NAME = sender.Text.ToString().Replace("\n", "").Replace(" ", "");
                lblDISPO_NAME.Text = gsDISPO_NAME;
            }
            else
            {
                sSelectGrpCode = string.Empty;

                gsDISPO_CD = string.Empty;
                gsDISPO_NAME = string.Empty;

                lblDISPO_NAME.Text = string.Empty;
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
            }
        }

        private void butDate_Click(object sender, EventArgs e)
        {
            Button btnTemp = (Button)sender;

            DateTime dt = DateTime.Today; 
            if (btnTemp.Tag.ToString() == "startDate")
            {
                dt = dtpStartDate.Value;
            }
            else
            {
                dt = dtpEndDate.Value;
            }

            DAResultDate pop = new DAResultDate(dt);
            pop.ShowDialog(this);
            if (pop.DialogResult == DialogResult.OK)
            {
                string strDate = pop.ResultString.ToString();
                if (btnTemp.Tag.ToString() == "startDate")
                {
                    dtpStartDate.Value = DateTime.Parse(strDate);
                }
                else
                {
                    dtpEndDate.Value = DateTime.Parse(strDate);
                }
            }

        }

        private void lblLength_Click(object sender, EventArgs e)
        {
            DAResultQty pop = new DAResultQty();
            pop.LabelTitle = "중량 입력";
            pop.LabelHeader = "중량(Kg)";
            pop.ContentMaxLength = 8;
            pop.ShowDialog(this);
            if (pop.DialogResult == DialogResult.OK)
            {
                gdWGT = pop.ResultDouble;
                lblWGT.Text = string.Format("{0:#,0}", gdWGT);
                AutoCalculation();
            }
        }

        private void dtpDate_ValueChanged(object sender, EventArgs e)
        {
            AutoCalculation();
        }

        private void lblRemark_Click(object sender, EventArgs e)
        {
            DAResultText pop = new DAResultText("합지기 폐품등록 비고입력");
            pop.ContentMaxLength = 100;
            pop.ShowDialog(this);
            if (pop.DialogResult == DialogResult.OK)
            {
                lb_RMK.Text = pop.ResultString;
            }
        }

        private void dtpDate_DropDown(object sender, EventArgs e)
        {
            CommonCalendar.CloseCalendar((DateTimePicker)sender);
        }

        #endregion
    }
}
