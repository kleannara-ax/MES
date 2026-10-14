#region [ USING AREA ]
using System;
using System.Configuration;
using System.Data;
using System.Windows.Forms;
using Infragistics.Win.UltraWinGrid;

using SAMMI;
using SmartDas.Components;
using SmartDas.POPUP;
using Oracle.ManagedDataAccess.Client;
using System.Globalization;
using System.Threading;
using System.Drawing;
#endregion

namespace SmartDas
{
    public partial class POP_WRK_LAMI_006 : BaseForm
    {
        string strLocalPath = Application.ExecutablePath.Substring(0, Application.ExecutablePath.LastIndexOf('\\'));

        #region < MEMBER AREA >
        private string sStartTime = string.Empty;

        private SAMMI.Common _common = new SAMMI.Common();

        public static string userID = string.Empty;
        public static string userName = string.Empty;
        private string gsOP_CODE = string.Empty;
        private string gsMACH_CD = string.Empty;
        private string gsRESULT = "NG";         // 취소 최종 결과
        private string gsGB = string.Empty;     // 지시구분 ( '' , 계획, 예외, 등등 )
        #endregion

        #region < CONSTRUCTOR >

        public POP_WRK_LAMI_006()
        {
            InitializeComponent();

            Common.SetMessageList();

            gsOP_CODE = Common.OpCode;
            gsMACH_CD = Common.MachineCode;
        }

        public POP_WRK_LAMI_006(string OP_CODE, string MACH_CD)
        {
            InitializeComponent();

            Common.SetMessageList();

            gsOP_CODE = OP_CODE;
            gsMACH_CD = MACH_CD;

            // 현재시간이 7시 이전 이면 .. 생산실적일자는 이전 날짜로 표시해야함.
        }
        #endregion

        #region < POP_WRK_LAMI_006_Load >
        private void POP_WRK_LAMI_006_Load(object sender, EventArgs e)
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
/*
                DateTime daysBefore = DateTime.Now;
                //daysBefore = daysBefore.AddDays(-7);
                cboWorkDate.Value = daysBefore;
*/
                DateTime dtTime;
                if (DateTime.TryParseExact(Common.gRecDate, "yyyyMMdd", null, DateTimeStyles.AssumeLocal, out dtTime))
                {
                    cboWorkDate.Value = dtTime;
                }

                pnlPRINT.Visible = false;
                Grid1.Size = new System.Drawing.Size(1250, 715);

                SetMenuButtons();
                SetGrid();
            }
            catch (Exception ex)
            {
                SetMessage("POP_WRK_LAMI_006_Load_ Error!");
                LogFile.WriteLog("POP_WRK_LAMI_006_Load Error => " + ex.Message);
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

                bBox1[0, 1].Text = "";
                bBox1[0, 1].Tag = "";
                bBox1[0, 2].Text = "";
                bBox1[0, 2].Tag = "";
                bBox1[0, 3].Text = "";
                bBox1[0, 3].Tag = "";
                bBox1[0, 4].Text = "";
                bBox1[0, 4].Tag = "";
                bBox1[0, 5].Text = "";
                bBox1[0, 5].Tag = "";
                bBox1[0, 6].Text = "";
                bBox1[0, 6].Tag = "";

                
                bBox1[0, 0].Text = "실적취소";
                bBox1[0, 0].Tag = "Delete";
                bBox1[0, 0].MappingButton.FontSize = 14;

                bBox1[0, 1].Text = "라벨" + Environment.NewLine + "재발행";
                bBox1[0, 1].Tag = "Print";
                bBox1[0, 1].MappingButton.FontSize = 14;

                //bBox1[0, 2].Text = "비고수정";
                //bBox1[0, 2].Tag = "Remark";
                //bBox1[0, 2].MappingButton.FontSize = 14;
                bBox1[0, 1].MappingButton.FontSize = 14;
                bBox1[0, 2].MappingButton.FontSize = 14;
                bBox1[0, 3].MappingButton.FontSize = 14;
                bBox1[0, 4].MappingButton.FontSize = 14;
                bBox1[0, 5].MappingButton.FontSize = 14;
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
                LogFile.WriteLog("POP_WRK_LAMI_006.SetButtons Error => " + ex.Message);
            }
        }

        private void SetGrid()
        {
            DBHelper helper = new DBHelper();
            string sColInfo = string.Empty;
            string sColType = string.Empty;

            DataSet dsTemp = new DataSet();
            DataTable dtRtn;
            DataTable dtTemp = new DataTable();
            DataRow rTemp = null;

            string sPRFM_DT = cboWorkDate.Value.ToString("yyyyMMdd");

            try
            {
                Grid1.HeaderFontSize = 11;
                Grid1.FontSize = 13;
                Grid1.CountRows = 12;
                Grid1.AutoScroll = true;
                Grid1.DisplayLayout.Scrollbars = Scrollbars.Automatic;
                Grid1.DisplayLayout.Bands[0].Override.SelectTypeCol = SelectType.None;
                btnRightPage.LinkMoveSize = Grid1.CountRows;
                btnLeftPage.LinkMoveSize = Grid1.CountRows;

                //버튼 목록 조회
                dtRtn = helper.FillTable("SP_POP_LAMI006_S01", CommandType.StoredProcedure
                                                    , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)                     // 플랜트코드
                                                    , helper.CreateParameter("P_PROC_CD", Common.OpCode, DbType.String, ParameterDirection.Input)                    //공정코드 (JA, MA, CA, PB_PC ...)
                                                    , helper.CreateParameter("P_PRFM_DT", sPRFM_DT, DbType.String, ParameterDirection.Input)      // 생산실적일자
                                                    , helper.CreateParameter("P_MACH_CD", gsMACH_CD, DbType.String, ParameterDirection.Input)                    //작업장코드(설비코드)
                                                    , helper.CreateParameter("P_ORDER_NO", txtORDER_NO.Text, DbType.String, ParameterDirection.Input)      // 생산실적일자
                                                    , helper.CreateParameter("P_IND_BCD", txtIND_BCD.Text, DbType.String, ParameterDirection.Input)      // 생산실적일자
                                                    , helper.CreateParameter("P_PCODE", txtPCODE.Text, DbType.String, ParameterDirection.Input)      // 생산실적일자
                                                    , helper.CreateParameter("P_BS_WGT", txtBS_WGT.Text, DbType.String, ParameterDirection.Input)      // 생산실적일자
                                                    //, helper.CreateParameter("P_WLEN", "", DbType.String, ParameterDirection.Input)      // 생산실적일자
                                                    //, helper.CreateParameter("P_VLEN", "", DbType.String, ParameterDirection.Input)      // 생산실적일자
                                                    , helper.CreateParameter("P_COLINFO", DbType.String, ParameterDirection.Output, null, 1000)
                                                    , helper.CreateParameter("P_COLTYPE", DbType.String, ParameterDirection.Output, null, 1000));

                //버튼 상태 변경
                if (helper.RSCODE.Equals("S"))
                {
                    //컬럼설정 정보
                    sColInfo = helper.Parameters["P_COLINFO"].Value.ToString();
                    sColType = helper.Parameters["P_COLTYPE"].Value.ToString();
                    //컬럼 설정 테이블 생성
                    dtTemp.Columns.Add(new DataColumn("colInfo", typeof(string)));
                    rTemp = dtTemp.NewRow();
                    rTemp["colInfo"] = sColInfo;
                    dtTemp.Rows.Add(rTemp);
                    rTemp = dtTemp.NewRow();
                    rTemp["colInfo"] = sColType;
                    dtTemp.Rows.Add(rTemp);
                    //컬럼설정 및 데이터 목록 작성
                    dsTemp.Tables.Add(dtTemp);
                    dsTemp.Tables.Add(dtRtn);

                    //그리드 출력
                    Grid1.DoFind_Oracle(dsTemp);

                    if (dtRtn.Rows.Count > 1)
                    {
                        // 첫번째 행 선택
                        Grid1.Rows[0].Selected = true;
                        Grid1.Row = Grid1.Rows[0];
                    }


                    //sdoc 오류 
                    for (int i = 0; i < Grid1.Rows.Count; i++)
                    {
                        if (Grid1.Rows[i].Cells["SDOC_NO"].Value.ToString().Equals("E"))
                            Grid1.Rows[i].CellAppearance.BackColor = Color.Orange;
                    }
                    // 첫번째열 고정
                    Grid1.DisplayLayout.UseFixedHeaders = true;
                    Grid1.DisplayLayout.Bands[0].Columns["CHK"].Header.Fixed = true;
                    Grid1.DisplayLayout.Bands[0].Override.FixedHeaderIndicator = FixedHeaderIndicator.None;
                }
                else
                {
                    new POPUP.MessageForm(helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return;
                }

            }
            catch (Exception ex)
            {
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                LogFile.WriteLog("POP_WRK_LAMI_006.SetGrid Error => " + ex.Message);
            }
        }

        private void doDelete(string sCancelRmk)
        {
           if (Common.OpCode == "LP" || Common.OpCode == "LS") // 라미네이팅 인쇄코팅,슬리터
            {
                doDeleteProc(sCancelRmk, Common.OpCode);
            }
            else
            {
                new POPUP.MessageForm("실적 취소 준비중...", MessageBoxButtons.OK, "알   림").ShowDialog(this);
            }
        }

        /// <summary>
        /// 밀롤, 재단, 수재단, 슬리터 취소
        /// </summary>
        /// <param name="sCancelRmk"></param>
        /// <param name="opCode"></param>
        private void doDeleteProc(string sCancelRmk, string opCode)
        {
            string sQueryName = "";
            string sPlantName = "";
            string sType = "";
            if (opCode == "LP")
            {
                sQueryName = "SP_POP_LAMI_PC_WRKCANCEL_NEW";  // 라미네이팅 실적취소
                sPlantName = "인쇄/코팅";
                sType = "PC";
            }
            else if (opCode == "LS")
            {
                sQueryName = "SP_POP_LAMI_SL_WRKCANCEL_NEW";  // 라미네이팅 슬리팅 실적취소
                sPlantName = "슬리팅";
                sType = "SL";
            }
            else
            {
                // 준비중 입니다.
                return;
            }

            DBHelper helper = new DBHelper(false, "", true);
            DataTable dtList;

            DataTable dtTemp;
            bool bReturn1 = false;
            string sMSG_ERR = string.Empty;
            string sWorkNo = string.Empty, sWorkNoSeq = string.Empty, spName = string.Empty;
            string sapType, mDocNo, mDocSeq = string.Empty;
            string rsRfcData; //RFC결과 JSON 변환             
            DataRow drNew;
            DataSet dsTemp;
            try
            {
                this.Cursor = Cursors.WaitCursor;   //Waitting

                LogFile.WriteLog(sPlantName + " 실적 취소 --------------------------------------");
                dtList = Grid1.DataSource as DataTable;
                //string sJsonData = Common.toJsonFormat(sQueryName, dtList);
                // RFC 실적 취소용 테이블
                dtTemp = new DataTable();
                dtTemp.Columns.Add("SAP_TYPE", typeof(string));
                dtTemp.Columns.Add("MDOCNO", typeof(string));
                dtTemp.Columns.Add("MDOCSEQ", typeof(string));
                dtTemp.Columns.Add("P_FLAG", typeof(string));
                dtTemp.Columns.Add("IND_BCD", typeof(string));
                foreach (DataRow drow in dtList.Rows)
                {
                    if (drow["CHK"].ToString() != "V") continue;
                    sWorkNo = drow["WRK_ORDR_NO"].ToString();
                    sWorkNoSeq = drow["WRK_ORDR_SEQNO"].ToString();
                    // 폐품실적
                    if (dtList.Columns.Contains("DOC_NO"))
                    {
                        if (drow["DOC_NO"].ToString() != string.Empty)
                        {
                            drNew = dtTemp.NewRow();
                            drNew["SAP_TYPE"] = "2.SALV_REG_SAP";
                            drNew["MDOCNO"] = drow["DOC_NO"];
                            drNew["MDOCSEQ"] = "1";
                            drNew["IND_BCD"] = drow["IND_BCD"];
                            dtTemp.Rows.Add(drNew);
                        }
                    }
                    // 폐품 생산 실적
                    if (dtList.Columns.Contains("MDOCNO"))
                    {
                        if (drow["MDOCNO"].ToString() != string.Empty)
                        {
                            drNew = dtTemp.NewRow();
                            drNew["SAP_TYPE"] = "3.PROD_REG_SAP";
                            drNew["MDOCNO"] = drow["MDOCNO"];
                            drNew["MDOCSEQ"] = "1";
                            drNew["P_FLAG"] = "RC";
                            drNew["IND_BCD"] = drow["IND_BCD"];
                            dtTemp.Rows.Add(drNew);
                        }
                    }
                    // 양품 생산 실적
                    if (drow["SDOC_NO"].ToString() != string.Empty)
                    {
                        drNew = dtTemp.NewRow();
                        drNew["SAP_TYPE"] = "3.PROD_REG_SAP";
                        drNew["MDOCNO"] = drow["SDOC_NO"];
                        drNew["MDOCSEQ"] = "1";
                        drNew["P_FLAG"] = "RE";
                        drNew["IND_BCD"] = drow["IND_BCD"];
                        dtTemp.Rows.Add(drNew);
                    }
                    // 투입 실적
                    if (dtList.Columns.Contains("IDOC_NO"))
                    {
                        if (drow["IDOC_NO"].ToString() != string.Empty)
                        {
                            drNew = dtTemp.NewRow();
                            drNew["SAP_TYPE"] = "4.WIP_REG_SAP";
                            drNew["MDOCNO"] = drow["IDOC_NO"];
                            drNew["MDOCSEQ"] = "1";
                            drNew["IND_BCD"] = drow["IND_BCD"];
                            dtTemp.Rows.Add(drNew);
                        }
                    }
                }

                // 자재 투입여부 
                if (opCode == "LP")
                {
                    helper.ExecuteNoneQuery("SP_POP_LAMI_PC_PROCESS_CHECK", CommandType.StoredProcedure
                    , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)              // 플랜트
                    , helper.CreateParameter("P_WRK_ORDR_NO", sWorkNo, DbType.String, ParameterDirection.Input)              // 작업지시번호
                    , helper.CreateParameter("P_WRK_ORDR_SEQNO", sWorkNoSeq, DbType.String, ParameterDirection.Input));     // 작업지시번호 순번

                    if (helper.RSCODE != "S")
                    {
                        sMSG_ERR += "ROLLBACK 확정문서 등록 오류 : " + helper.RSMSG.ToString() + Environment.NewLine;
                        throw new Exception("MES_ERROR" + sMSG_ERR);
                    }
                }

                //RFC 취소 CALL
                foreach (DataRow Rows in dtTemp.Rows)
                {
                    LogFile.WriteLog("=====SAP ROLLBACK START=====", LogType.PROC);
                    switch (Rows["SAP_TYPE"].ToString())
                    {
                        // 2.3  실적 ROLLBACK
                        case "3.PROD_REG_SAP":
                            LogFile.WriteLog("=====3.PROD_REG_SAP=====" + Rows["MDOCNO"].ToString() + "-" + Rows["MDOCSEQ"].ToString(), LogType.PROC);
                            if (Rows["P_FLAG"].ToString() == "RC")
                            {
                                // 폐품생산 실적취소
                                spName = "SP_POP_LAMI_" + sType + "_IFR03";
                            }
                            else
                            {
                                // 양품생산 실적취소
                                spName = "SP_POP_LAMI_" + sType + "_IFR01";
                            }
                            dsTemp = helper.FillDataSetN(spName, CommandType.StoredProcedure, 2
                                    , helper.CreateParameter("P_DOC_NO", Rows["MDOCNO"].ToString(), DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_DOC_SEQNO", Rows["MDOCSEQ"].ToString(), DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("RS_RFCFN", DbType.String, ParameterDirection.Output, null, 30)
                                    );
                            string sRS_RFCFN_1 = helper.Parameters["RS_RFCFN"].Value.ToString();
                            SAPHelper sapRFC_1 = new SAPHelper();
                            if (sapRFC_1.CallSAPFunc(sRS_RFCFN_1, dsTemp.Tables[0], dsTemp.Tables[1], helper).Equals("S"))
                            {
                                rsRfcData = Common.toJsonFormat("PUT_WRKRTN", sapRFC_1.rtnTable).Replace("MBLNR", "RUECK").Replace("MJAHR", "RMZHL");
                                helper.ExecuteNoneQuery("SP_IF_PUT_LAMI_WRKRTN", CommandType.StoredProcedure
                                , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)              // 플랜트
                                , helper.CreateParameter("P_WRK_TYPE", "0", DbType.String, ParameterDirection.Input)                        // '0'= 실적테이블, 비계획생산, '1'= 폐품테이블, '2'=소요량, '3'=비가동,
                                , helper.CreateParameterOracle("P_RFC_DATA", rsRfcData, OracleDbType.Clob, ParameterDirection.Input)
                                , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input));

                                if (helper.RSCODE == "S")
                                {
                                    LogFile.WriteLog("실적등록 ROLLBACK COMPLETE", LogType.PROC);
                                }
                                else //if (helper.RSCODE == "E")
                                {
                                    LogFile.WriteLog("ROLLBACK 등록 - SAP 확정문서 등록 오류 [" + helper.RSMSG.ToString() + "]");
                                    sMSG_ERR += "ROLLBACK 확정문서 등록 오류 : " + helper.RSMSG.ToString() + Environment.NewLine;
                                    throw new Exception("SAP_ERROR" + sMSG_ERR);
                                }

                                // DELAY 
                                Thread.Sleep(Common.SLEEP_DELAY);
                                System.Windows.Forms.Application.DoEvents();        // 반복작업중 응답없음 안뜨게 하기
                            }
                            else
                            {
                                LogFile.WriteLog("ROLLBACK 오류 - SAP전송 오류 [" + sapRFC_1.rtnMSG + "]");
                                sMSG_ERR += "ROLLBACK 오류 : " + sapRFC_1.rtnMSG + Environment.NewLine;
                                throw new Exception("SAP_ERROR" + sMSG_ERR);
                            }
                            break;
                        // 2.2  폐품 ROLLBACK
                        case "2.SALV_REG_SAP":
                            LogFile.WriteLog("=====2.SALV_REG_SAP=====" + Rows["MDOCNO"].ToString() + "-" + Rows["MDOCSEQ"].ToString(), LogType.PROC);
                            dsTemp = helper.FillDataSetN("SP_POP_LAMI_" + sType + "_IFR02", CommandType.StoredProcedure, 2
                                    , helper.CreateParameter("P_DOC_NO", Rows["MDOCNO"].ToString(), DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_DOC_SEQNO", Rows["MDOCSEQ"].ToString(), DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("RS_RFCFN", DbType.String, ParameterDirection.Output, null, 30)
                                    );
                            string sRS_RFCFN_2 = helper.Parameters["RS_RFCFN"].Value.ToString();
                            SAPHelper sapRFC_2 = new SAPHelper();
                            if (sapRFC_2.CallSAPFunc(sRS_RFCFN_2, dsTemp.Tables[0], dsTemp.Tables[1], helper).Equals("S"))
                            {
                                rsRfcData = Common.toJsonFormat("PUT_WRKRTN", sapRFC_2.rtnTable).Replace("MBLNR", "RUECK").Replace("MJAHR", "RMZHL");
                                helper.ExecuteNoneQuery("SP_IF_PUT_LAMI_WRKRTN", CommandType.StoredProcedure
                                , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)              // 플랜트
                                , helper.CreateParameter("P_WRK_TYPE", "1", DbType.String, ParameterDirection.Input)                        // '0'= 실적테이블, 비계획생산, '1'= 폐품테이블, '2'=소요량, '3'=비가동,
                                , helper.CreateParameterOracle("P_RFC_DATA", rsRfcData, OracleDbType.Clob, ParameterDirection.Input)
                                , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input));

                                if (helper.RSCODE == "S")
                                {
                                    LogFile.WriteLog("폐품등록 ROLLBACK COMPLETE", LogType.PROC);
                                }
                                else //if (helper.RSCODE == "E")
                                {
                                    LogFile.WriteLog("ROLLBACK 등록 - SAP 확정문서 등록 오류 [" + helper.RSMSG.ToString() + "]");
                                    sMSG_ERR += "ROLLBACK 확정문서 등록 오류 : " + helper.RSMSG.ToString() + Environment.NewLine;
                                    throw new Exception("SAP_ERROR" + sMSG_ERR);
                                }

                                // DELAY 
                                Thread.Sleep(Common.SLEEP_DELAY);
                                System.Windows.Forms.Application.DoEvents();        // 반복작업중 응답없음 안뜨게 하기
                            }
                            else
                            {
                                LogFile.WriteLog("ROLLBACK 오류 - SAP전송 오류 [" + sapRFC_2.rtnMSG + "]");
                                sMSG_ERR += "ROLLBACK 오류 : " + sapRFC_2.rtnMSG + Environment.NewLine;
                                throw new Exception("SAP_ERROR" + sMSG_ERR);
                            }
                            break;
                        // 2.4 투입량 ROLLBACK
                        case "4.WIP_REG_SAP":
                            LogFile.WriteLog("=====4.WIP_REG_SAP=====" + Rows["MDOCNO"].ToString() + "-" + Rows["MDOCSEQ"].ToString(), LogType.PROC);
                            dsTemp = helper.FillDataSetN("SP_POP_LAMI_SL_IFR04", CommandType.StoredProcedure, 2
                                   , helper.CreateParameter("P_DOC_NO", Rows["MDOCNO"].ToString(), DbType.String, ParameterDirection.Input)
                                   , helper.CreateParameter("P_DOC_SEQNO", Rows["MDOCSEQ"].ToString(), DbType.String, ParameterDirection.Input)
                                   , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input)
                                   , helper.CreateParameter("RS_RFCFN", DbType.String, ParameterDirection.Output, null, 30)
                                    );
                            string sRS_RFCFN_4 = helper.Parameters["RS_RFCFN"].Value.ToString();
                            SAPHelper sapRFC_4 = new SAPHelper();
                            if (sapRFC_4.CallSAPFunc(sRS_RFCFN_4, dsTemp.Tables[0], dsTemp.Tables[1], helper).Equals("S"))
                            {
                                rsRfcData = Common.toJsonFormat("PUT_WRKRTN", sapRFC_4.rtnTable).Replace("MBLNR", "RUECK").Replace("MJAHR", "RMZHL");
                                helper.ExecuteNoneQuery("SP_IF_PUT_LAMI_WRKRTN", CommandType.StoredProcedure
                                , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)              // 플랜트
                                , helper.CreateParameter("P_WRK_TYPE", "0", DbType.String, ParameterDirection.Input)                        // '0'= 실적테이블, 비계획생산, '1'= 폐품테이블, '2'=소요량, '3'=비가동,
                                , helper.CreateParameterOracle("P_RFC_DATA", rsRfcData, OracleDbType.Clob, ParameterDirection.Input)
                                , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input));

                                if (helper.RSCODE == "S")
                                {
                                    LogFile.WriteLog("투입량 ROLLBACK COMPLETE", LogType.PROC);
                                }
                                else //if (helper.RSCODE == "E")
                                {
                                    LogFile.WriteLog("투입량 ROLLBACK 등록 - SAP 확정문서 등록 오류 [" + helper.RSMSG.ToString() + "]");
                                    sMSG_ERR += "ROLLBACK 확정문서 등록 오류 : " + helper.RSMSG.ToString() + Environment.NewLine;
                                    throw new Exception("SAP_ERROR" + sMSG_ERR);
                                }
                            }
                            else
                            {
                                LogFile.WriteLog("투입량 ROLLBACK 오류 - SAP전송 오류 [" + sapRFC_4.rtnMSG + "]");
                                sMSG_ERR += "투입량 ROLLBACK 오류 : " + sapRFC_4.rtnMSG + Environment.NewLine;
                                throw new Exception("SAP_ERROR" + sMSG_ERR);
                            }
                            break;

                        default:
                            break;
                    }
                    LogFile.WriteLog("=====SAP ROLLBACK END=====", LogType.PROC);

                    helper.Commit();
                    LogFile.WriteLog("=====MES ROLLBACK START=====" + sWorkNo + "-" + sWorkNoSeq, LogType.PROC);

                    helper.ExecuteNoneQuery("SP_POP_LAMI_" + sType + "_WRKCANCEL_NEW", CommandType.StoredProcedure
                                , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)              // 플랜트
                                , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)          // 설비
                                , helper.CreateParameter("P_WRK_ORDR_NO", sWorkNo, DbType.String, ParameterDirection.Input)                 // 작업지시번호
                                , helper.CreateParameter("P_WRK_ORDR_SEQNO", sWorkNoSeq, DbType.String, ParameterDirection.Input)         // 작업지시순번
                                , helper.CreateParameter("P_IND_BCD", Rows["IND_BCD"].ToString(), DbType.String, ParameterDirection.Input)         // 작업지시순번
                                , helper.CreateParameter("P_CLN_RMK", sCancelRmk, DbType.String, ParameterDirection.Input));

                    LogFile.WriteLog("=====MES ROLLBACK END=====" + sWorkNo + "-" + sWorkNoSeq, LogType.PROC);
                }

                sMSG_ERR += "MES ROLLBACK 실적이 취소되었습니다" + Environment.NewLine;
                LogFile.WriteLog("MES ROLLBACK COMPLETE", LogType.PROC);
                new POPUP.MessageForm(sMSG_ERR, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                bReturn1 = true;
            }
            catch (Exception ex)
            {
                LogFile.WriteLog("ProdRollback 오류" + ex.Message.ToString());
                sMSG_ERR += "ProdRollback 오류" + ex.Message.ToString();
                new POPUP.MessageForm_ERR("실적취소 오류", "실적취소 예외 오류\r\n" + ex.ToString() + Environment.NewLine + sMSG_ERR, MessageBoxButtons.OK).ShowDialog(this);
            }

            ////취소 최종 처리결과
            if (bReturn1)
            {
                gsRESULT = "OK";
            }
        }
        #endregion

        #region < EVNET >

        private void bBox1_buttonClickEvent(MESButton sender, ButtonBox.ButtonClickEventArg e)
        {
            DataTable dtReqList;
            int iCnt = 0;
            string sBtnName = "";

            try
            {
                if (!this.bUseNetwork)
                {
                    SetMessage("네트워크 상태를 확인하시기 바랍니다.");
                    return;
                }

                MESButton btn = sender;

                sBtnName = btn.Tag.ToString();

                //if (sBtnName.Equals("Close"))
                //{
                //    this.Close();
                //    return;
                //}

                //체크된 항목 확인
                dtReqList = setReqList();
                
                iCnt = dtReqList.Rows.Count;

                if ((iCnt == 0) && (sBtnName.Equals("Close") == false))
                {
                    new POPUP.MessageForm("선택된 것이 없습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return;
                }

                switch (sBtnName)
                {
                    case "Print":  //라벨재발행
                        LogFile.WriteLog("바코드 재발행 시작", LogType.PROC);

                        string sIND_BCD_GRP = "";   // 개별 바코드 묶음

                        this.Cursor = Cursors.WaitCursor;   //Waitting

                        if (gsOP_CODE.Equals("LP") || gsOP_CODE.Equals("LS"))
                        {
                            int nPrtCnt = 1;
                            for (int i = 0; i < dtReqList.Rows.Count; i++)
                            {
                                sIND_BCD_GRP = dtReqList.Rows[i]["IND_BCD"].ToString();

                                if (PrinterManager.PrintLami_3B(sIND_BCD_GRP, nPrtCnt) == false)
                                {
                                    LogFile.WriteLog("바코드 재발행 완료", LogType.PROC);
                                    return;
                                }
                            }
                        }

                        this.Cursor = Cursors.Default;   //원래대로

                        LogFile.WriteLog("바코드 재발행 완료", LogType.PROC);
                        new POPUP.MessageForm("라벨 재발행 되었습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);

                        break;
                    //LogFile.WriteLog("바코드 재발행 시작", LogType.PROC);

                    //string sIND_BCD_GRP = "";   // 개별 바코드 묶음

                    //this.Cursor = Cursors.WaitCursor;   //Waitting

                    //if (gsOP_CODE.Equals("LP") || gsOP_CODE.Equals("LS"))
                    //{
                    //    int nPrtCnt = ucPNT_CNT.SelectedIndex + 1;
                    //    sIND_BCD_GRP = dtReqList.Rows[0]["IND_BCD"].ToString();

                    //    if (PrinterManager.PrintLami(sIND_BCD_GRP, nPrtCnt) == false)
                    //    {
                    //        LogFile.WriteLog("바코드 재발행 완료", LogType.PROC);
                    //        return;
                    //    }
                    //}

                    //this.Cursor = Cursors.Default;   //원래대로

                    //LogFile.WriteLog("바코드 재발행 완료", LogType.PROC);
                    //new POPUP.MessageForm("라벨 재발행 되었습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);

                    //break;
                    case "Delete":  //실적취소
                        if (iCnt == 1)
                        {
                            DAResultText pop = new DAResultText("실적취소 사유를 자세히 기입하십시오.", "");
                            pop.bNullCheck = true;
                            pop.NullCheckString = "실적 취소 사유를 반드시 입력하십시오.";
                            pop.ContentMaxLength = 100;

                            pop.ShowDialog(this);
                            if (pop.DialogResult == DialogResult.OK)
                            {
                                string sCancelRmk = pop.ResultString;

                                //if (new POPUP.MessageForm(string.Format("개별바코드 '{0}'을 실적취소 하시겠습니까?", dtReqList.Rows[0]["IND_BCD"].ToString()), MessageBoxButtons.OKCancel, "알   림").ShowDialog(this) == DialogResult.OK)
                                if (new POPUP.MessageForm(string.Format("오더번호 '{0}'을 실적취소 하시겠습니까?", dtReqList.Rows[0]["ORDER_NO"].ToString()), MessageBoxButtons.OKCancel, "알   림").ShowDialog(this) == DialogResult.OK)
                                {
                                    if (dtReqList.Rows[0]["WRK_ORDR_NO"].ToString().Contains("WOEX"))
                                        gsGB = "예외";
                                    else
                                        gsGB = "";

                                    doDelete(sCancelRmk);                       // 실적취소시 취소사유 전달.
                                }
                            }
                            SetGrid();
                        }
                        else
                        {
                            new POPUP.MessageForm("동시에 2개 이상의 실적 취소를 실행 할 수 없습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                        }
                        break;
                    case "Remark":  //비고수정
                        #region < REGION_REMARK >
                        if (iCnt == 1)
                        {
                            POP_WRK85 WRK85 = new POP_WRK85("비고수정", Common.PlantCode, Common.MachineCode, dtReqList.Rows[0]["IND_BCD"].ToString(), dtReqList.Rows[0]["LOT_NO"].ToString(), dtReqList.Rows[0]["RMK"].ToString());
                            WRK85.ShowDialog(this);
                            if (WRK85.DialogResult == DialogResult.OK)
                            {
                                SetGrid();
                            }
                        }
                        else
                        {
                            new POPUP.MessageForm("동시에 2개 이상의 비고 수정을 실행 할 수 없습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                        }
                        #endregion

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
            }
            catch (Exception ex)
            {
                SetMessage(ex.Message);
                LogFile.WriteLog("POP_WRK_LAMI_006.bBox1_buttonClickEvent Error => " + ex.Message);
            }
            finally
            {
                this.Cursor = Cursors.Default;   //원래대로
            }
        }
        
        private DataTable setReqList()
        {
            DataTable dtRtn = null;
            DataTable dt = (DataTable)Grid1.DataSource;
            dtRtn = dt.Clone();
            try
            {
                foreach (DataRow drow in dt.Rows)
                {
                    if (drow["CHK"].ToString() == "V")
                    {
                        dtRtn.ImportRow(drow);
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return dtRtn;
        }


        private void Grid1_ClickCellButton(object sender, MESGrid.GridClickEventArg e)
        {
            ////선택 버튼 클릭시 체크여부 변경
            //if (e.column.ToString() == "CHK")
            //{
            //    string sStatus_Pre = e.row.Cells["CHK"].Value.ToString();

            //    if (sStatus_Pre == "V")
            //    {
            //        e.row.Cells["CHK"].Value = "-";
            //    }
            //    else
            //    {
            //        e.row.Cells["CHK"].Value = "V";
            //    }

            //    e.row.Update();
            //}

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

            //상세보기 클릭시 팝업화면 호출
            if (e.column.ToString() == "DBTN")
            {
                string sWrkOrder = e.row.Cells["WRK_ORDR_NO"].Value.ToString();
                string sWrkOrderSeq = e.row.Cells["WRK_ORDR_SEQNO"].Value.ToString();
                string sIND_BCD = e.row.Cells["IND_BCD"].Value.ToString();

                //public static string PROC_INP = "PROC_INP";        // 작업지시선택 투입정보
                //public static string PROC_WRK = "PROC_WRK";        // 주작업 표시 정보
                //public static string PROC_PRFM = "PROC_PRFM";      // 실적현황 표시 정보
                POP_WRK84 popWrk84 = new POP_WRK84(POP_WRK84.PROC_PRFM, Common.PlantCode, Common.OpCode, sWrkOrder, sWrkOrderSeq, sIND_BCD);  // 작업지시 정보
                popWrk84.LabelTitle = "실적현황 상세보기";

                ShowDialogForm(popWrk84);
            }
        }
        #endregion

        private void btnFind_Click(object sender, EventArgs e)
        {
            SetGrid(); 
        }

        private void butMoveDate_Click(object sender, EventArgs e)
        {
            DAResultDate pop = new DAResultDate(cboWorkDate.Value);
            pop.ShowDialog(this);
            if (pop.DialogResult == DialogResult.OK)
            {
                string strDate = pop.ResultString.ToString();
                cboWorkDate.Value = DateTime.Parse(strDate);
            }
        }

        private void cboWorkDate_ValueChanged(object sender, EventArgs e)
        {
            SetGrid(); 
        }
    }
}