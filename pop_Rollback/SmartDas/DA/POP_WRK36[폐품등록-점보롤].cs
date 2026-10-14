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
using System.Threading;
#endregion

namespace SmartDas
{
    public partial class POP_WRK36 : BaseForm
    {
        #region < MEMBER AREA >


        private int giBS_WGT = 0;     // 평량
        private int giJWIDTH = 0;       // 지폭
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

        public POP_WRK36()
        {
            InitializeComponent();

            Common.SetMessageList();

        }

        public POP_WRK36(DateTime dtStartTime, DateTime dtEndTime, int nBasisWgt, int nWidth, string sUNIT, string sPRFM_WGT, string sDISP_QTY)
        {
            InitializeComponent();

            Common.SetMessageList();

            giBS_WGT = nBasisWgt;
            giJWIDTH = nWidth;

            gsUNIT = sUNIT;

            dtpStartDate.Value = dtStartTime;
            lblStartTime.Text = dtpStartDate.Value.ToString("HH:mm:ss");       // 작업시작시간

            dtpEndDate.Value = dtEndTime;
            lblEndTime.Text = dtpEndDate.Value.ToString("HH:mm:ss");       // 작업종료시간

            lblBS_WGT.Text = string.Format("{0:#,0}", giBS_WGT);
            lblJWIDTH.Text = string.Format("{0:#,0}", nWidth);

            lblPRFM_WGT.Text = sPRFM_WGT;
            lblDISPO_QTY.Text = sDISP_QTY;


            lblDISPO_NAME.Tag = "";
        }


        #endregion

        #region < POP_WRK36_Load >
        private void POP_WRK36_Load(object sender, EventArgs e)
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

                this.lblTitle.Text = "점보롤 폐품 등록";

                SetMenuButtons();
                SetGroupButtons(Common.OpCode);
                SetItemButtons(Common.OpCode, sGrpCode);

                AutoCalculation();
            }
            catch (Exception ex)
            {
                SetMessage("POP_WRK36_Load_ Error!");
                LogFile.WriteLog("POP_WRK36.POP_WRK36_Load Error => " + ex.Message);
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

            if ((lblStartTime.Text.ToString().Length != 8) || (lblEndTime.Text.ToString().Length != 8))
            {
                lblPRFM_DT.Text = "";                   // 생산실적일자
                lblTM.Text = "0";
                lblRSPEED.Text = "0";
                return;
            }

            string sStartDate = dtpStartDate.Value.ToString("yyyy-MM-dd") + " " + lblStartTime.Text.ToString(); // +":00";
            if (Common.IsDateTime(sStartDate) == false)
            {
                lblPRFM_DT.Text = "";                   // 생산실적일자
                lblTM.Text = "0";
                lblRSPEED.Text = "0";
                return;
            }

            string sEndDate = dtpEndDate.Value.ToString("yyyy-MM-dd") + " " + lblEndTime.Text.ToString(); // +":00";
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
                SetMessage("");
            }
            else
            {
                lblPRFM_DT.Text = "";
                lblTM.Text = "0";
                lblRSPEED.Text = "0";

                //SetMessage("작업 시작일시/종료일시를 확인하세요!");
            }
        }

        // 중량 계산
        private void WgtCalculation()
        {
            if (giBS_WGT <= 0 || giJWIDTH <= 0 || gdROLLCNT <= 0)
            {
                lblWGT.Text = "0";
                gdWGT = 0;
                return;
            }

            double dValue = ((double)giBS_WGT / 1000.0) * ((double)giJWIDTH / 1000.0) * (double)gdROLLCNT;
            lblWGT.Text = string.Format("{0:#,0.###}", dValue);
            gdWGT = dValue;      // 중량
        }
        #endregion

        #region < METHOD AREA >

        private void DoFind()
        {

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
                LogFile.WriteLog("POP_WRK36.SetButtons Error => " + ex.Message);
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
                bGroup_Up.LinkMoveSize = bGroup.CountY;
                bGroup_Down.LinkMoveSize = bGroup.CountY;
                //버튼 폰트
                bGroup.FontSize = 20;
                //버튼 목록 조회
                System.Data.DataSet ds = helper.FillDataSet("SP_POP_WRK36_S01", CommandType.StoredProcedure
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
                LogFile.WriteLog("DA0110.SetOPButtons Error => " + ex.Message);
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
                System.Data.DataSet ds = helper.FillDataSet("SP_POP_WRK36_S02", CommandType.StoredProcedure
                                                               , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_PROC_CD", pGrp, DbType.String, ParameterDirection.Input)             // 
                                                               , helper.CreateParameter("P_DISPO_DIV", pDispoClass, DbType.String, ParameterDirection.Input));  // 폐품유형
                if (ds.Tables[0].Rows.Count < 1)
                {
                    SetMessage("조회된 폐품항목이 없습니다.");
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
                LogFile.WriteLog("POP_WRK36.SetButtons Error => " + ex.Message);
            }
        }

        /// <summary>
        /// 점보롤 폐품등록
        /// </summary>
        private void doConfirm()
        {
            if (string.IsNullOrEmpty(gsDISPO_CD))
            {
                new POPUP.MessageForm("폐품코드 선택은 필수 입니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return;
            }

            string sStartDateTime = dtpStartDate.Value.ToString("yyyyMMdd") + lblStartTime.Text.ToString().Replace(":", ""); // +"00";
            DateTime dtStartTime;
            if (DateTime.TryParseExact(sStartDateTime, "yyyyMMddHHmmss", null, DateTimeStyles.AssumeLocal, out dtStartTime) == false)
            {
                new POPUP.MessageForm("작업 시작일시 확인하세요!", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return;
            }

            string sEndDateTime = dtpEndDate.Value.ToString("yyyyMMdd") + lblEndTime.Text.ToString().Replace(":", ""); // +"00";
            DateTime dtEndTime;
            if (DateTime.TryParseExact(sEndDateTime, "yyyyMMddHHmmss", null, DateTimeStyles.AssumeLocal, out dtEndTime) == false)
            {
                new POPUP.MessageForm("작업 종료일시 확인하세요!", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return;
            }

            string sWrkTime = lblTM.Text.ToString().Replace(",", "");     // 선속
            int nWrkTime = 0;
            if ( (Common.isStr2Int(sWrkTime, out nWrkTime) == false) || (nWrkTime <= 0) )
            {
                new POPUP.MessageForm("작업 시작일시/종료일시를 확인하세요!", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return;
            }


            // 권치수 확인
            double.TryParse(lblROLLCNT.Text.ToString().Replace(",", ""), out gdROLLCNT);      // 등록할권치수 int
            if (gdROLLCNT <= 0)
            {
                new POPUP.MessageForm("권치수 입력은 필수 입니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return;
            }

            int iRSPEED = 0;
            int.TryParse(lblRSPEED.Text.ToString().Replace(",", ""), out iRSPEED);  // 선속

            string sFINISH = "N";
            {
                POPUP.MessageForm msgForm = new POPUP.MessageForm("점보롤 완료 플래그를 체크 하시겠습니까?", MessageBoxButtons.YesNoCancel, "알   림");
                DialogResult dr = msgForm.ShowDialog(this);
                if (dr == DialogResult.Cancel)
                {
                    return;
                }
                else if (dr == DialogResult.Yes)
                {
                    sFINISH = "Y";
                }
                else
                {
                    sFINISH = "N";
                }
            }


            DBHelper helper = new DBHelper(false, "", true);
            DataSet dsTemp = new DataSet();     //실적등록 결과 수신(0:실적 RFC ID, 1:실적 IF 변수, 2:실적 RFC ID, 3:실적 IF 변수)
            bool bReturn = false;

            string sMSG_ERR = "";

            //SAP 롤백용 추가 CODE 범위 START
            DataTable sapTemp = new DataTable(); // 성공한 sap 정보 저장
            sapTemp.Columns.Add("SAP_TYPE", typeof(string));
            sapTemp.Columns.Add("IF_KEY", typeof(string));
            sapTemp.Columns.Add("MDOCNO", typeof(string));
            sapTemp.Columns.Add("MDOCSEQ", typeof(string));

            DataTable rollTemp = new DataTable(); // ROLLBACK용 정보 저장
            rollTemp.Columns.Add("MDOCNO", typeof(string));
            rollTemp.Columns.Add("MDOCSEQ", typeof(string));
            //SAP 롤백용 추가 CODE 범위 END


            try
            {
                this.Cursor = Cursors.WaitCursor;   //Waitting

                dsTemp = helper.FillDataSetN("SP_POP_WRK36_I01", CommandType.StoredProcedure, 6
                                                , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)      // 플랜트
                                                , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)         // 작업장코드(설비코드)
                                                , helper.CreateParameter("P_DISPO_CD", gsDISPO_CD, DbType.String, ParameterDirection.Input)           // 폐품코드
                                                , helper.CreateParameter("P_UNIT", gsUNIT, DbType.String, ParameterDirection.Input)                // 실적단위
                                                , helper.CreateParameter("P_ROLLCNT", gdROLLCNT, DbType.Double, ParameterDirection.Input)       // 폐품권치수
                                                , helper.CreateParameter("P_DISPO_QTY", gdWGT, DbType.Double, ParameterDirection.Input)         // 폐품중량
                                                , helper.CreateParameter("P_RSPEED", iRSPEED, DbType.Double, ParameterDirection.Input)                      // 선속
                                                , helper.CreateParameter("P_PRD_STR_DATE", sStartDateTime, DbType.String, ParameterDirection.Input)         // 생산시작 일시
                                                , helper.CreateParameter("P_PRD_END_DATE", sEndDateTime, DbType.String, ParameterDirection.Input)           // 생산 종료 일시
                                                , helper.CreateParameter("P_TM", sWrkTime, DbType.String, ParameterDirection.Input)                 // 생산시간(분)
                                                , helper.CreateParameter("P_PRFM_DT", lblPRFM_DT.Text.ToString().Replace("-", ""), DbType.String, ParameterDirection.Input)                      // 생산실적일자
                                                , helper.CreateParameter("P_FINISH", sFINISH, DbType.String, ParameterDirection.Input)          // 완료여부
                                                , helper.CreateParameter("P_RMK", lb_RMK.Text.ToString(), DbType.String, ParameterDirection.Input)             // 비고
                                                , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input)             // 사용자ID
                                                , helper.CreateParameter("RS_PRFM_RFCFN", DbType.String, ParameterDirection.Output, null, 30)               // 실적 RFCFN값
                                                , helper.CreateParameter("RS_DISPO_RFCFN", DbType.String, ParameterDirection.Output, null, 30)              // 폐품 RFCFN값
                                                , helper.CreateParameter("RS_ZERO_RFCFN", DbType.String, ParameterDirection.Output, null, 30)              // 0 실적 RFCFN값
                                                );

                bReturn = false;
                if (helper.RSCODE == "S")
                {
                    string sRS_PRFM_RFCFN = helper.Parameters["RS_PRFM_RFCFN"].Value.ToString();      // 실적 RFCFN ID
                    string sRS_DISPO_RFCFN = helper.Parameters["RS_DISPO_RFCFN"].Value.ToString();    // 폐품 RFCFN ID
                    string sRS_ZERO_RFCFN = helper.Parameters["RS_ZERO_RFCFN"].Value.ToString();    // 0 실적 RFCFN ID


                    //SAP 롤백용 추가 CODE 범위 END
                    string rollTempMDOC_NO_1 = dsTemp.Tables[1].Rows[0]["MDOCNO"].ToString();
                    string rollTempMDOC_SEQNO_1 = dsTemp.Tables[1].Rows[0]["MDOCSEQ"].ToString();
                    string rollTempMDOC_NO_2 = dsTemp.Tables[3].Rows[0]["MDOCNO"].ToString();
                    string rollTempMDOC_SEQNO_2 = dsTemp.Tables[3].Rows[0]["MDOCSEQ"].ToString();
                    rollTemp.Rows.Add(rollTempMDOC_NO_1, rollTempMDOC_SEQNO_1);
                    rollTemp.Rows.Add(rollTempMDOC_NO_2, rollTempMDOC_SEQNO_2);
                    //SAP 롤백용 추가 CODE 범위 END

                    //dsTemp.Tables[0];     // 실적 인터페이스 파라미터
                    //dsTemp.Tables[1];     // 실적 인터페이스 상세 파라미터
                    //dsTemp.Tables[2];     // 폐품 인터페이스 파라미터
                    //dsTemp.Tables[3];     // 폐품 인터페이스 상세 파라미터

                    string sRfcData; //RFC결과 JSON 변환

                    // 점보롤의 경우 폐품등록 RFC 호출시 아래 순서로 처리됨.
                    // 1. 폐품용 실적 등록 
                    if (string.IsNullOrEmpty(sRS_PRFM_RFCFN) == false)
                    {
                        //SAP 실적 등록
                        SAPHelper sapRFC_P = new SAPHelper();

                        // sapRFC.CallSAPFunc_PS 호출시 helper를 사용하여 내용이 변경됨. 
                        // 필요한 정보는 sapRFC.CallSAPFunc_PS 호출전에 처리해야함.
                        if (sapRFC_P.CallSAPFunc_PS(sRS_PRFM_RFCFN, dsTemp.Tables[0], dsTemp.Tables[1], helper).Equals("S"))
                        {
                            // ---- 전달시 MBLNR, MJAHR을 replace 처리하여 하나로 받도록함.
                            sRfcData = Common.toJsonFormat("PUT_WRKRTN", sapRFC_P.rtnTable).Replace("MBLNR", "RUECK").Replace("MJAHR", "RMZHL");

                            //SAP 롤백용 추가 CODE 범위 START
                            string sTempSAP_TYPE = string.Empty;
                            string sTempIF_KEY = string.Empty;
                            string sTempMDOC_NO = string.Empty;
                            string sTempMDOC_SEQNO = string.Empty;

                            sTempSAP_TYPE = "3.PROD_REG_SAP";
                            sTempIF_KEY = dsTemp.Tables[0].Rows[0]["I_IF_KEY"].ToString();
                            sTempMDOC_NO = dsTemp.Tables[1].Rows[0]["MDOCNO"].ToString();
                            sTempMDOC_SEQNO = dsTemp.Tables[1].Rows[0]["MDOCSEQ"].ToString();

                            sapTemp.Rows.Add(sTempSAP_TYPE, sTempIF_KEY, sTempMDOC_NO, sTempMDOC_SEQNO); // 후단 코드 실행시 EXCEPTION 상황 SAP CANCLE 정보 -- 실적등록
                            //SAP 롤백용 추가 CODE 범위 END

                            //실적등록 테이블에 확정문서 번호 갱신
                            helper.ExecuteNoneQuery("SP_IF_PUT_WRKRTN", CommandType.StoredProcedure
                                                                , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)          // 플랜트
                                                                , helper.CreateParameter("P_WRK_TYPE", "0", DbType.String, ParameterDirection.Input)                    // 0이면 실적테이블,  1이면 폐품테이블
                                                                , helper.CreateParameterOracle("P_RFC_DATA", sRfcData, OracleDbType.Clob, ParameterDirection.Input)
                                                                , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input));
                            
                            if (helper.RSCODE == "S")
                            {
                                bReturn = true;
                            }
                            else //if (helper.RSCODE == "E")
                            {
                                //helper.Rollback();

                                LogFile.WriteLog("점보롤 폐품 등록(실적) - SAP 확정문서 등록 오류 [" + helper.RSMSG.ToString());
                                //new POPUP.MessageForm("폐품 등록(실적) - SAP 확정문서 등록 오류\r\n" + helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                sMSG_ERR += "확정문서 등록 오류 : " + helper.RSMSG.ToString() + Environment.NewLine;
                                throw new Exception("SAP_ERROR " + sMSG_ERR);
                            }
                            
                            Thread.Sleep(Common.SLEEP_DELAY);
                            System.Windows.Forms.Application.DoEvents();        // 반복작업중 응답없음 안뜨게 하기
                            this.Cursor = Cursors.WaitCursor;   //Waitting
                        }
                        else
                        {
                            //helper.Rollback();
                            LogFile.WriteLog("점보롤 폐품 등록(실적) - SAP 전송 실패 [" + sapRFC_P.rtnMSG);
                            //new POPUP.MessageForm("폐품 등록(실적) - SAP전송이 실패하였습니다.\r\n" + sapRFC_P.rtnMSG, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                            sMSG_ERR += "점보로 폐품 등록(1) 오류 : " + sapRFC_P.rtnMSG + Environment.NewLine;
                            throw new Exception("SAP_ERROR " + sMSG_ERR);

                        }
                    }
                    else
                    {
                        // 폐품 등록을 위한 가실적을 받지 못한경우 폐품등록을 해야하는지?
                        bReturn = true;
                    }

                    // 2. 폐품 등록
                    if (/*(bReturn == true) &&*/ (string.IsNullOrEmpty(sRS_DISPO_RFCFN) == false))
                    {
                        SAPHelper sapRFC_D = new SAPHelper();
                        // sapRFC.CallSAPFunc_PS 호출시 helper를 사용하여 내용이 변경됨. 
                        // 필요한 정보는 sapRFC.CallSAPFunc_PS 호출전에 처리해야함.
                        if (sapRFC_D.CallSAPFunc_PS(sRS_DISPO_RFCFN, dsTemp.Tables[2], dsTemp.Tables[3], helper).Equals("S"))
                        {
                            // ---- 전달시 MBLNR, MJAHR을 replace 처리하여 하나로 받도록함.
                            sRfcData = Common.toJsonFormat("PUT_WRKRTN", sapRFC_D.rtnTable).Replace("MBLNR", "RUECK").Replace("MJAHR", "RMZHL");

                            //SAP 롤백용 추가 CODE 범위 START
                            string sTempSAP_TYPE = string.Empty;
                            string sTempIF_KEY = string.Empty;
                            string sTempMDOC_NO = string.Empty;
                            string sTempMDOC_SEQNO = string.Empty;

                            sTempSAP_TYPE = "2.SALV_REG_SAP";
                            sTempIF_KEY = dsTemp.Tables[2].Rows[0]["I_IF_KEY"].ToString();
                            sTempMDOC_NO = dsTemp.Tables[3].Rows[0]["MDOCNO"].ToString();
                            sTempMDOC_SEQNO = dsTemp.Tables[3].Rows[0]["MDOCSEQ"].ToString();

                            sapTemp.Rows.Add(sTempSAP_TYPE, sTempIF_KEY, sTempMDOC_NO, sTempMDOC_SEQNO); // 후단 코드 실행시 EXCEPTION 상황 SAP CANCLE 정보 -- 실적등록
                            //SAP 롤백용 추가 CODE 범위 END5

                            //실적등록 테이블에 확정문서 번호 갱신
                            helper.ExecuteNoneQuery("SP_IF_PUT_WRKRTN", CommandType.StoredProcedure
                                                                , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)                // 플랜트
                                                                , helper.CreateParameter("P_WRK_TYPE", "1", DbType.String, ParameterDirection.Input)                  // 0이면 실적테이블,  1이면 폐품테이블
                                                                , helper.CreateParameterOracle("P_RFC_DATA", sRfcData, OracleDbType.Clob, ParameterDirection.Input)
                                                                , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input));

                            if (helper.RSCODE == "S")
                            {
                            }
                            else //if (helper.RSCODE == "E")
                            {
                                LogFile.WriteLog("점보롤 폐품 등록 - SAP 확정문서 등록 오류 [" + helper.RSMSG.ToString());
                                //new POPUP.MessageForm("폐품 등록 - SAP 확정문서 등록 오류\r\n" + helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                sMSG_ERR += "확정문서 등록(폐품) 오류 : " + helper.RSMSG.ToString() + Environment.NewLine;
                                throw new Exception("SAP_ERROR " + sMSG_ERR);
                            }
                            
                            Thread.Sleep(Common.SLEEP_DELAY);
                            System.Windows.Forms.Application.DoEvents();        // 반복작업중 응답없음 안뜨게 하기
                            this.Cursor = Cursors.WaitCursor;   //Waitting
                        }
                        else
                        {
                            LogFile.WriteLog("점보롤 폐품 등록 - SAP전송 오류 [" + sapRFC_D.rtnMSG);
                            //new POPUP.MessageForm("폐품 등록 - SAP전송이 실패하였습니다.\r\n" + sapRFC_D.rtnMSG, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                            sMSG_ERR += "점보로 폐품 등록(2) 오류 : " + sapRFC_D.rtnMSG + Environment.NewLine;
                            throw new Exception("SAP_ERROR " + sMSG_ERR);
                        }

                    }

                    // 3. 완료 처리시 0 실적 등록
                    if (/*(bReturn == true) &&*/ string.IsNullOrEmpty(sRS_ZERO_RFCFN) == false)
                    {
                        //SAP 실적 등록
                        SAPHelper sapRFC_Z = new SAPHelper();

                        // sapRFC.CallSAPFunc_PS 호출시 helper를 사용하여 내용이 변경됨. 
                        // 필요한 정보는 sapRFC.CallSAPFunc_PS 호출전에 처리해야함.
                        if (sapRFC_Z.CallSAPFunc_PS(sRS_ZERO_RFCFN, dsTemp.Tables[4], dsTemp.Tables[5], helper).Equals("S"))
                        {

                            // ---- 전달시 MBLNR, MJAHR을 replace 처리하여 하나로 받도록함.
                            sRfcData = Common.toJsonFormat("PUT_WRKRTN", sapRFC_Z.rtnTable).Replace("MBLNR", "RUECK").Replace("MJAHR", "RMZHL");

                            //실적등록 테이블에 확정문서 번호 갱신
                            helper.ExecuteNoneQuery("SP_IF_PUT_WRKRTN", CommandType.StoredProcedure
                                                                , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)          // 플랜트
                                                                , helper.CreateParameter("P_WRK_TYPE", "0", DbType.String, ParameterDirection.Input)                    // 0이면 실적테이블,  1이면 폐품테이블
                                                                , helper.CreateParameterOracle("P_RFC_DATA", sRfcData, OracleDbType.Clob, ParameterDirection.Input)
                                                                , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input));

                            if (helper.RSCODE == "S")
                            {
                            }
                            else //if (helper.RSCODE == "E")
                            {
                                //helper.Rollback();

                                LogFile.WriteLog("점보롤 0 실적 등록 - SAP 확정문서 등록 오류 [" + helper.RSMSG.ToString());
                                //new POPUP.MessageForm("폐품 등록(실적) - SAP 확정문서 등록 오류\r\n" + helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                sMSG_ERR += "확정문서 완료 등록 오류 : " + helper.RSMSG.ToString() + Environment.NewLine;
                                throw new Exception("SAP_ERROR " + sMSG_ERR);
                            }

                            Thread.Sleep(Common.SLEEP_DELAY);
                            System.Windows.Forms.Application.DoEvents();        // 반복작업중 응답없음 안뜨게 하기
                            this.Cursor = Cursors.WaitCursor;   //Waitting
                        }
                        else
                        {
                            //helper.Rollback();
                            LogFile.WriteLog("점보롤 0 실적 등록 - SAP 전송 실패 [" + sapRFC_Z.rtnMSG);
                            //new POPUP.MessageForm("폐품 등록(실적) - SAP전송이 실패하였습니다.\r\n" + sapRFC_P.rtnMSG, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                            sMSG_ERR += "점보롤 폐품 완료 등록 오류 : " + sapRFC_Z.rtnMSG + Environment.NewLine;
                            throw new Exception("SAP_ERROR " + sMSG_ERR);
                        }
                    }

                }
                else //if (helper.RSCODE == "E")
                {
                    //helper.Rollback();
                    LogFile.WriteLog("점보롤 폐품 등록 실패 [" + helper.RSMSG.ToString() + "]");
                    new POPUP.MessageForm("폐품 등록 실패\r\n" + helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return;
                }

                //if (bReturn == true)
                {
                    //helper.Commit();
                    this.Cursor = Cursors.Default;   //Waitting

                    LogFile.WriteLog("점보롤 폐품 등록 성공", LogType.PROC);
                    if (sMSG_ERR.Length > 0)
                    {
                        throw new Exception("SAP_ERROR " + sMSG_ERR);
                        //new POPUP.MessageForm(sMSG_ERR, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                        //this.DialogResult = DialogResult.Cancel;
                    }
                    else
                    {
                        new POPUP.MessageForm("폐품 등록이 정상적으로 등록되었습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                        this.DialogResult = DialogResult.OK;
                    }
                }
            }
            catch (Exception ex)
            {
                sMSG_ERR = "";
                if (rollTemp.Rows.Count != 0)
                {
                    SetMessagePos("오류 발생하여 롤백 처리중 입니다.");
                    System.Windows.Forms.Application.DoEvents();        // 반복작업중 응답없음 안뜨게 하기

                    ProdRollback(helper, sapTemp, rollTemp, dsTemp, ref sMSG_ERR);
                }

                this.Cursor = Cursors.Default;
                LogFile.WriteLog("점보롤 폐품 등록 예외 오류 [" + ex.ToString() + "]");
                new POPUP.MessageForm_ERR("실적등록 오류", "폐품등록 예외 오류\r\n" + ex.Message.ToString() + Environment.NewLine + sMSG_ERR, MessageBoxButtons.OK).ShowDialog(this);
                this.DialogResult = DialogResult.Cancel;
            }
            finally
            {
                this.Cursor = Cursors.Default;   //Default
                helper.Close();
            }
        }

        private void ProdRollback(DBHelper helper, DataTable sapTemp, DataTable rollTemp, DataSet dsTemp, ref string sMSG_ERR)
        {

            try
            {
                string rsRfcData; //RFC결과 JSON 변환
                string notUseIF_ID_1 = string.Empty;
                string notUseIF_ID_2 = string.Empty;
                string notUseIF_ID_3 = string.Empty;
                string notUseIF_ID_4 = string.Empty;

                Thread.Sleep(Common.SLEEP_ROLLBACK_DELAY);               // 2초 대기
                System.Windows.Forms.Application.DoEvents();        // 반복작업중 응답없음 안뜨게 하기
                this.Cursor = Cursors.WaitCursor;   //Waitting

                if (dsTemp.Tables[0].Rows[0][0].ToString() != "1")
                {
                    notUseIF_ID_1 = dsTemp.Tables[0].Rows[0]["I_IF_ID"].ToString();
                    foreach (DataRow notUseRows in dsTemp.Tables[1].Rows)
                    {
                        helper.ExecuteNoneQuery("SP_IF_NOT_USE_FLAG", CommandType.StoredProcedure
                            , helper.CreateParameter("P_MES_IF_ID", notUseIF_ID_1, DbType.String, ParameterDirection.Input)
                            , helper.CreateParameter("P_DOC_NO", notUseRows["MDOCNO"].ToString(), DbType.String, ParameterDirection.Input)
                            , helper.CreateParameter("P_DOC_SEQNO", notUseRows["MDOCSEQ"].ToString(), DbType.String, ParameterDirection.Input)
                            , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input));
                    }
                }
                if (dsTemp.Tables[2].Rows[0][0].ToString() != "1")
                {
                    notUseIF_ID_1 = dsTemp.Tables[2].Rows[0]["I_IF_ID"].ToString();
                    foreach (DataRow notUseRows in dsTemp.Tables[3].Rows)
                    {
                        helper.ExecuteNoneQuery("SP_IF_NOT_USE_FLAG", CommandType.StoredProcedure
                            , helper.CreateParameter("P_MES_IF_ID", notUseIF_ID_1, DbType.String, ParameterDirection.Input)
                            , helper.CreateParameter("P_DOC_NO", notUseRows["MDOCNO"].ToString(), DbType.String, ParameterDirection.Input)
                            , helper.CreateParameter("P_DOC_SEQNO", notUseRows["MDOCSEQ"].ToString(), DbType.String, ParameterDirection.Input)
                            , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input));
                    }
                }
                //if (dsTemp.Tables[4].Rows[0][0].ToString() != "1")
                //{
                //    notUseIF_ID_3 = dsTemp.Tables[5].Rows[0]["I_IF_ID"].ToString();
                //    foreach (DataRow notUseRows in dsTemp.Tables[5].Rows)
                //    {
                //        helper.ExecuteNoneQuery("SP_IF_NOT_USE_FLAG", CommandType.StoredProcedure
                //            , helper.CreateParameter("P_MES_IF_ID", notUseIF_ID_1, DbType.String, ParameterDirection.Input)
                //            , helper.CreateParameter("P_DOC_NO", notUseRows["MDOCNO"].ToString(), DbType.String, ParameterDirection.Input)
                //            , helper.CreateParameter("P_DOC_SEQNO", notUseRows["MDOCSEQ"].ToString(), DbType.String, ParameterDirection.Input)
                //            , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input));
                //    }
                //}
                if (sapTemp.Rows.Count != 0)
                {
                    sapTemp = sapTemp.Select("", "SAP_TYPE ASC").CopyToDataTable<DataRow>();
                    System.Windows.Forms.Application.DoEvents();        // 반복작업중 응답없음 안뜨게 하기

                    foreach (DataRow Rows in sapTemp.Rows)
                    {
                        SAPHelper sapRFC;

                        switch (Rows["SAP_TYPE"].ToString())
                        {
                            case "3.PROD_REG_SAP":
                                LogFile.WriteLog("=====3.PROD_REG_SAP=====" + Rows["MDOCNO"].ToString() + "-" +  Rows["MDOCSEQ"].ToString(), LogType.PROC);
                                //
                                dsTemp = helper.FillDataSetN("SP_POP_WRK24_IFR01", CommandType.StoredProcedure, 2
                                       , helper.CreateParameter("P_DOC_NO", Rows["MDOCNO"].ToString(), DbType.String, ParameterDirection.Input)
                                       , helper.CreateParameter("P_DOC_SEQNO", Rows["MDOCSEQ"].ToString(), DbType.String, ParameterDirection.Input)
                                       , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input)
                                       , helper.CreateParameter("RS_RFCFN", DbType.String, ParameterDirection.Output, null, 30)
                                        );
                                string sRS_RFCFN_1 = helper.Parameters["RS_RFCFN"].Value.ToString();
                                sapRFC = new SAPHelper();
                                if (sapRFC.CallSAPFunc_PS(sRS_RFCFN_1, dsTemp.Tables[0], dsTemp.Tables[1], helper).Equals("S"))
                                {
                                    LogFile.WriteLog(dsTemp.Tables[0].Rows[0]["I_IF_ID"].ToString(), LogType.PROC);
                                    //
                                    rsRfcData = Common.toJsonFormat("PUT_WRKRTN", sapRFC.rtnTable).Replace("MBLNR", "RUECK").Replace("MJAHR", "RMZHL");
                                    helper.ExecuteNoneQuery("SP_IF_PUT_WRKRTN", CommandType.StoredProcedure
                                                          , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)              // 플랜트
                                                          , helper.CreateParameter("P_WRK_TYPE", "0", DbType.String, ParameterDirection.Input)                        // '0'= 실적테이블, 비계획생산, '1'= 폐품테이블, '2'=소요량, '3'=비가동,
                                                          , helper.CreateParameterOracle("P_RFC_DATA", rsRfcData, OracleDbType.Clob, ParameterDirection.Input)
                                                          , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input));

                                    if (helper.RSCODE == "S")
                                    {

                                    }
                                    else //if (helper.RSCODE == "E")
                                    {
                                        LogFile.WriteLog("점보롤폐품 ROLLBACK 등록 - SAP 확정문서 등록 오류 [" + helper.RSMSG.ToString() + "]");
                                   }

                                }
                                else
                                {
                                    LogFile.WriteLog("점보롤폐품 ROLLBACK 오류 - SAP전송 오류 [" + sapRFC.rtnMSG + "]");
                                    sMSG_ERR += "점보롤폐품 ROLLBACK 오류 : " + sapRFC.rtnMSG + Environment.NewLine;
                                }
                                break;
                            case "2.SALV_REG_SAP":
                                LogFile.WriteLog("=====2.SALV_REG_SAP=====" + Rows["MDOCNO"].ToString() + "-" + Rows["MDOCSEQ"].ToString(), LogType.PROC);
                                //
                                dsTemp = helper.FillDataSetN("SP_POP_WRK36_IFR01", CommandType.StoredProcedure, 2
                                       , helper.CreateParameter("P_DOC_NO", Rows["MDOCNO"].ToString(), DbType.String, ParameterDirection.Input)
                                       , helper.CreateParameter("P_DOC_SEQNO", Rows["MDOCSEQ"].ToString(), DbType.String, ParameterDirection.Input)
                                       , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input)
                                       , helper.CreateParameter("RS_RFCFN", DbType.String, ParameterDirection.Output, null, 30)
                                        );
                                string sRS_RFCFN_2 = helper.Parameters["RS_RFCFN"].Value.ToString();
                                sapRFC = new SAPHelper();
                                if (sapRFC.CallSAPFunc_PS(sRS_RFCFN_2, dsTemp.Tables[0], dsTemp.Tables[1], helper).Equals("S"))
                                {
                                    LogFile.WriteLog(dsTemp.Tables[0].Rows[0]["I_IF_ID"].ToString(), LogType.PROC);

                                    rsRfcData = Common.toJsonFormat("PUT_WRKRTN", sapRFC.rtnTable).Replace("MBLNR", "RUECK").Replace("MJAHR", "RMZHL");
                                    helper.ExecuteNoneQuery("SP_IF_PUT_WRKRTN", CommandType.StoredProcedure
                                                          , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)              // 플랜트
                                                          , helper.CreateParameter("P_WRK_TYPE", "0", DbType.String, ParameterDirection.Input)                        // '0'= 실적테이블, 비계획생산, '1'= 폐품테이블, '2'=소요량, '3'=비가동,
                                                          , helper.CreateParameterOracle("P_RFC_DATA", rsRfcData, OracleDbType.Clob, ParameterDirection.Input)
                                                          , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input));

                                    if (helper.RSCODE == "S")
                                    {

                                    }
                                    else //if (helper.RSCODE == "E")
                                    {
                                        LogFile.WriteLog("점보롤폐품 ROLLBACK 등록 - SAP 확정문서 등록 오류 [" + helper.RSMSG.ToString() + "]");
                                        sMSG_ERR += "ROLLBACK 확정문서 등록 오류 : " + helper.RSMSG.ToString() + Environment.NewLine;
                                    }

                                }
                                else
                                {
                                    LogFile.WriteLog("점보롤폐품 ROLLBACK 오류 - SAP전송 오류 [" + sapRFC.rtnMSG + "]");
                                    sMSG_ERR += "점보롤폐품 ROLLBACK 오류 : " + sapRFC.rtnMSG + Environment.NewLine;
                                }
                                break;

                            default:
                                break;
                        }
                        

                    }

                }

            }
            catch (Exception ex)
            {
                LogFile.WriteLog("ProdRollback 오류" + ex.Message.ToString());
                sMSG_ERR += "ProdRollback 오류" + ex.Message.ToString();
            }
            finally
            {
                try//MES롤백구간
                {
                    helper.Commit();

                    if (rollTemp.Rows.Count != 0)
                    {
                        foreach (DataRow Rows in rollTemp.Rows)
                        {
                            LogFile.WriteLog("MES ROLLBACK", LogType.PROC);
                            helper.ExecuteNoneQuery("SP_POP_WRK24_R01", CommandType.StoredProcedure
                           , helper.CreateParameter("P_DOC_NO", Rows["MDOCNO"].ToString(), DbType.String, ParameterDirection.Input)
                           , helper.CreateParameter("P_DOC_SEQNO", Rows["MDOCSEQ"].ToString(), DbType.String, ParameterDirection.Input)
                           , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input));
                        }
                    }
                    sMSG_ERR += "점보롤 폐품 MES ROLLBACK 실적이 취소되었습니다" + Environment.NewLine;
                }
                catch (Exception ex1)
                {
                    LogFile.WriteLog("점보롤 MES ROLLBACK 오류 [" + ex1.Message.ToString() + "]");
                    sMSG_ERR += "점보롤 MES ROLLBACK 오류 : " + ex1.Message.ToString() + Environment.NewLine;
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
                    case "Confirm":  //폐품 이력 등록
                        //if (bItem.GetSelectedButtons().Count > 0)
                        //{
                        //    Console.WriteLine(string.Format("{0} {1}", bItem.GetSelectedButtons().Count, ((ButtonData)bItem.GetSelectedButtons()[0]).Text.ToString()));
                        //}
                        //sMachNo = ((ButtonData)bMachine.GetSelectedButtons()[0]).Tag.ToString();
                        //sMachName = ((ButtonData)bItem.GetSelectedButtons()[0]).Text.ToString();

                        doConfirm();
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
                LogFile.WriteLog("POP_WRK36.bBox1_buttonClickEvent Error => " + ex.Message);
            }
            finally
            {

            }
        }

        #endregion

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

                //lblWasteItemName.Tag = ((ButtonData)bItem.GetSelectedButtons()[0]).Tag.ToString().Replace("\n", " ");
                //lblWasteItemName.Text = ((ButtonData)bItem.GetSelectedButtons()[0]).Text.ToString().Replace("\n", " ");
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
            DAResultTime pop = new DAResultTime("HHmmss");
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
                //AutoCalculation();
            }

        }

        private void lblLength_Click(object sender, EventArgs e)
        {
            DAResultQty pop = new DAResultQty();
            pop.LabelTitle = "권치수 입력";
            pop.LabelHeader = "권치수(M)";
            pop.ContentMaxLength = 8;

            pop.ShowDialog(this);

            if (pop.DialogResult == DialogResult.OK)
            {
                gdROLLCNT = pop.ResultDouble;
                lblROLLCNT.Text = string.Format("{0:#,0}", gdROLLCNT);
                AutoCalculation();
            }

        }

        private void dtpDate_ValueChanged(object sender, EventArgs e)
        {
            AutoCalculation();
        }

        private void lblRemark_Click(object sender, EventArgs e)
        {
            DAResultText pop = new DAResultText("점보롤 폐품등록 비고입력");
            pop.ContentMaxLength = 100;
            pop.ShowDialog(this);
            if (pop.DialogResult == DialogResult.OK)
            {
                lb_RMK.Text = pop.ResultString;
            }

        }

        private void lblEndChk_Click(object sender, EventArgs e)
        {
            if (lblEndChk.Text.ToString().Equals("V"))
            {
                lblEndChk.Text = "";
            }
            else
            {
                lblEndChk.Text = "V";
            }

        }

        private void dtpDate_DropDown(object sender, EventArgs e)
        {
            CommonCalendar.CloseCalendar((DateTimePicker)sender);
        }
    }
}
