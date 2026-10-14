#region [ USING AREA ]
using System;
using System.Configuration;
using System.Data;
using System.Windows.Forms;
using Infragistics.Win.UltraWinGrid;
using System.Threading;

using SAMMI;
using SmartDas.Components;
using SmartDas.POPUP;

using Oracle.ManagedDataAccess.Client;
using System.Drawing;
#endregion

namespace SmartDas
{
    public partial class POP_WRK20 : BaseForm
    {
        #region < MEMBER AREA >
        private string sStartTime = string.Empty;

        private SAMMI.Common _common = new SAMMI.Common();

        private string sMenuType = string.Empty;

        #endregion

        #region < CONSTRUCTOR >

        public POP_WRK20()
        {
            InitializeComponent();

            Common.SetMessageList();
        }
        #endregion

        #region < POP_WRK20_Load >
        private void POP_WRK20_Load(object sender, EventArgs e)
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

                //화장지/패드 구분에 따라 하단 메뉴 목록 변경
                if (Common.OpCode.Equals("RA")) //화장지
                    sMenuType = "T";
                else if (Common.OpCode.Equals("RB")) //생리대
                    sMenuType = "P";
                else if (Common.OpCode.Equals("PF")) //생리대 예외생산
                    sMenuType = "P";
                else if (Common.OpCode.Equals("PE")) //생리대 예외생산
                    sMenuType = "P";
                else if (Common.OpCode.Equals("RC")) //기저귀
                    sMenuType = "B";

                SetMenuButtons();
                SetGrid();
            }
            catch (Exception ex)
            {
                SetMessage("POP_WRK20_Load_ Error!");
                LogFile.WriteLog("POP_WRK20.POP_WRK20_Load Error\r\n" + ex.Message);
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

                if (sMenuType.Equals("T"))
                {
                    bBox1[0, 1].Text = "입고요청";
                    bBox1[0, 1].Tag = "Input";
                    bBox1[0, 2].Text = "부분폐품";
                    bBox1[0, 2].Tag = "Waste";
                    //20221228 wsw
                    //bBox1[0, 3].Text = "재전송";
                    bBox1[0, 3].Text = "WMS\n재전송";
                    bBox1[0, 3].Tag = "ReSend";
                    //bBox1[0, 4].Text = "입고\n재요청";
                    //bBox1[0, 4].Tag = "ReRestful";
                    bBox1[0, 4].Text = "";
                    bBox1[0, 4].Tag = "";
                }
                else if (sMenuType.Equals("P"))
                {
                    bBox1[0, 1].Text = "확인요청";
                    bBox1[0, 1].Tag = "Check";
                    bBox1[0, 2].Text = "부분폐품";
                    bBox1[0, 2].Tag = "Waste";
                    //20221228 wsw 화장지만 WMS 재전송 버튼이 필요하다.
                    //bBox1[0, 3].Text = "재전송";
                    //bBox1[0, 3].Text = "WMS\n재전송";
                    //bBox1[0, 3].Tag = "ReSend";
                    bBox1[0, 4].Text = "";
                    bBox1[0, 4].Tag = "";
                }
                else
                {
                    bBox1[0, 1].Text = "확인요청";
                    bBox1[0, 1].Tag = "Check";
                    bBox1[0, 2].Text = "부분폐품";
                    bBox1[0, 2].Tag = "Waste";
                    //20221228 wsw 화장지만 WMS 재전송 버튼이 필요하다.
                    //bBox1[0, 3].Text = "재전송";
                    //bBox1[0, 3].Text = "WMS\n재전송";
                    //bBox1[0, 3].Tag = "ReSend";
                    bBox1[0, 4].Text = "";
                    bBox1[0, 4].Tag = "";
                    //bBox1[0, 1].Text = "부분폐품";
                    //bBox1[0, 1].Tag = "Waste";
                    //bBox1[0, 2].Text = "재전송";
                    //bBox1[0, 2].Tag = "ReSend";
                    //bBox1[0, 3].Text = "";
                    //bBox1[0, 3].Tag = "";
                }

                bBox1[0, 0].Text = "라벨\n재발행";
                bBox1[0, 0].Tag = "Print";
                bBox1[0, 0].MappingButton.FontSize = 14;
                bBox1[0, 1].MappingButton.FontSize = 14;
                bBox1[0, 2].MappingButton.FontSize = 14;
                bBox1[0, 3].MappingButton.FontSize = 14;
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
                bBox1[0, 9].Text = "자재투입현황";
                bBox1[0, 9].Tag = "InputStatus";
                bBox1[0, 9].MappingButton.FontSize = 14;
                bBox1[0, 10].Text = "닫기";
                bBox1[0, 10].Tag = "Close";
                bBox1[0, 10].MappingButton.FontSize = 14;

                bBox1.RedrawButtons();
            }
            catch (Exception ex)
            {
                SetMessage("SetButtons Error!");
                LogFile.WriteLog("POP_WRK20.SetButtons Error\r\n" + ex.Message);
            }
        }

        private void SetGrid()
        {
            DBHelper helper = new DBHelper();
            DataSet dsTemp = new DataSet();
            string sWorkDate = string.Empty;
            string sProdChk = string.Empty;
            string sStckSta = string.Empty;

            try
            {
                sWorkDate = dtpWorkDate.Value.ToString("yyyyMMdd");
                sProdChk = lblCHKFLAG.Tag == null ? string.Empty : lblCHKFLAG.Tag.ToString();
                sStckSta = lblCHKFLAG2.Tag == null ? "00" : lblCHKFLAG2.Tag.ToString();

                Grid1.HeaderFontSize = 13;
                Grid1.FontSize = 13;
                Grid1.CountRows = 10;
                Grid1.AutoScroll = true;
                Grid1.DisplayLayout.Scrollbars = Scrollbars.Both;
                btnRightPage.LinkMoveSize = Grid1.CountRows;
                btnLeftPage.LinkMoveSize = Grid1.CountRows;

                dsTemp = helper.FillDataSetN("SP_POP_WRK20_S01", CommandType.StoredProcedure, 2
                                                               , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_WRK_DT", sWorkDate, DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_CHKFLAG", sProdChk, DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_CHKFLAG2", sStckSta, DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_STCKSTA", DbType.String, ParameterDirection.Output, null, 10)
                                                               , helper.CreateParameter("P_STCKSTANM", DbType.String, ParameterDirection.Output, null, 100)
                                                               );
                //그리드 출력
                Grid1.DoFind_Oracle(dsTemp);

                if (string.IsNullOrEmpty(lblCHKFLAG2.Text))
                {
                    lblCHKFLAG2.Tag = helper.Parameters["P_STCKSTA"].Value.ToString();
                    lblCHKFLAG2.Text = helper.Parameters["P_STCKSTANM"].Value.ToString();
                }

                // 화장지 WMS 미요청건 주황색으로 표시
                if (sMenuType.Equals("T"))
                {
                    for (int i = 0; i < Grid1.Rows.Count; i++)
                    {
                        if (Grid1.Rows[i].Cells["CHK_YN_NM"].Value.ToString().Equals("확인") &&
                            Grid1.Rows[i].Cells["WMS_STA"].Value.ToString().Equals("미요청"))
                            Grid1.Rows[i].CellAppearance.BackColor = Color.Orange;
                    }
                }

                // 첫번째열 고정
                Grid1.DisplayLayout.UseFixedHeaders = true;
                Grid1.DisplayLayout.Bands[0].Columns["CHK"].Header.Fixed = true;
                Grid1.DisplayLayout.Bands[0].Override.FixedHeaderIndicator = FixedHeaderIndicator.None;
            }
            catch (Exception ex)
            {
                SetMessage("SetGrid Error!");
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                LogFile.WriteLog("POP_WRK20.SetGrid Error\r\n" + ex.Message);
            }
        }

        private void doConfirm(string pType)
        {
            string sPlantCode = Common.PlantCode;
            string sOPCode = Common.OpCode;
            string sUserID = Common.UserID;
            //요청문서목록
            DataTable dtReqList;
            string sWrkList;
            string sWDOC_NO = string.Empty;
            string sPRFM_FUNC = string.Empty;
            string sUSE_FUNC = string.Empty;
            string sRtnMessage = string.Empty;
            string sRtnCode = string.Empty;

            DateTime dtStr;
            DateTime dtEnd;
            TimeSpan tsDiff;

            if (Grid1.Rows.Count < 1)
            {
                new POPUP.MessageForm("해당 날짜에 실적 데이터가 없습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return;
            }
            if (!chkReqList())
            {
                new POPUP.MessageForm("확인이 완료된 실적이 존재합니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return;
            }

            DataSet dsTemp = new DataSet(); //실적등록 결과 수신(0:라벨정보, 1:RFC 변수, 2:RFC 상세변수)
            string sResult = string.Empty;
            //rollback용 
            //SAP 롤백용 추가 CODE 범위 START
            DataTable sapTemp = new DataTable(); // 성공한 sap 정보 저장
            //SAP 롤백용 추가 CODE 범위 END
            //rollback용 end

            try
            {
                sRtnMessage = "생산실적 전송이 정상적으로 완료되었습니다.";
                
                //개별 바코드 단위로 전송처리
                dtStr = DateTime.Now;
                for (int i = 0; i < Grid1.Rows.Count; i++)
                {
                    DBHelper helper = new DBHelper(false, "", true);

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

                        //체크여부 확인
                        if (!Grid1.Rows[i].Cells["CHK"].Value.ToString().Equals("V"))
                            continue;

                        this.Cursor = Cursors.WaitCursor;   //Waitting


                        string sIND_BCD = "";
                        //실적목록 테이블 JSON으로 변환
                        dtReqList = setReqList(i, ref sIND_BCD);
                        sWrkList = Common.toJsonFormat("POP_WRK20", dtReqList);

                        LogFile.WriteLog("PROC WRK_LIST : " + sWrkList, LogType.PROC);

                        dsTemp = helper.FillDataSetN("SP_POP_WRK20_I01", CommandType.StoredProcedure, 7
                                                                  , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)
                                                                  , helper.CreateParameter("P_PROC_CD", Common.OpCode, DbType.String, ParameterDirection.Input)
                                                                  , helper.CreateParameterOracle("P_WRK_LIST", sWrkList, OracleDbType.Clob, ParameterDirection.Input)
                                                                  , helper.CreateParameter("P_USERID", sUserID, DbType.String, ParameterDirection.Input)
                                                                  , helper.CreateParameter("P_PRFM_FUNC", DbType.String, ParameterDirection.Output, null, 30)
                                                                  , helper.CreateParameter("P_USE_FUNC", DbType.String, ParameterDirection.Output, null, 30)
                                                                  , helper.CreateParameter("P_WDOC_NO", DbType.String, ParameterDirection.Output, null, 30)
                                   );

                        //helper.Rollback();
                        if (helper.RSCODE == "E")
                        {
                            this.Cursor = Cursors.Default;   //Waitting
                            helper.Rollback();
                            new POPUP.MessageForm(helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                            this.DialogResult = DialogResult.OK;
                            return;
                        }
                        else
                        {
                            sPRFM_FUNC = helper.Parameters["P_PRFM_FUNC"].Value.ToString();
                            sUSE_FUNC = helper.Parameters["P_USE_FUNC"].Value.ToString();
                            sWDOC_NO = helper.Parameters["P_WDOC_NO"].Value.ToString();
                            //SAP 실적 등록
                            SAPHelper sapRFC = new SAPHelper();
                            if (sapRFC.CallSAPFunc_HL(sPRFM_FUNC, dsTemp.Tables[0], dsTemp.Tables[1], helper).Equals("S"))
                            {
                                sapRFC.SaveResulttoWrk_HL(helper, "POP_WRK020", "0");//롤백처리용 결과처리 함수(COMMIT 제거)
                                //rollback용
                                //SAP 롤백용 추가 CODE 범위 START
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
                                //SAP 롤백용 추가 CODE 범위 END
                                //rollback용 end

                                Thread.Sleep(1000);
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

                                try { helper.Commit(); }// 모두 성공시 커밋
                                catch { }

                                if (!string.IsNullOrEmpty(sWDOC_NO))
                                {
                                    //restful 전송
                                    string pURL = Common.WMS_IF_URL.Replace("IFID", "WMS_IF_205");
                                    string sJsonData = Common.toJsonFormat_List("list", dsTemp.Tables[2]);
                                    string rtnData = string.Empty;
                                    bool bWMSTrans = false;
                                    // 오류발생시 최대 3회 재전송 시도
                                    for (int ntry = 0; ntry < 3; ntry++)
                                    {
                                        try
                                        {
                                            rtnData = Common.GetRestToString(pURL, sJsonData, "POST");
                                            ntry = 3;
                                            bWMSTrans = true;
                                            break;
                                        }
                                        catch (Exception EX_WMS)
                                        {
                                            LogFile.WriteLog("POP_WRK20.doConfirm::GetRestToString Error\r\n" + EX_WMS.ToString());

                                            if (ntry == 2)
                                            {
                                                // Exception 내용 결과 저장 시 내용에서 ":", "'" 문자 제거
                                                rtnData = "{\"result\":\"" + EX_WMS.Message.Replace(":", "").Replace("'", "") + "\",\"IFID\":\"WMS_IF_205\"}";
                                                bWMSTrans = false;
                                                break;
                                            }

                                            LogFile.WriteLog(string.Format("GetRestToString Retry[{0}] : {1}", ntry + 1, sWDOC_NO));

                                            Thread.Sleep(2000);
                                            System.Windows.Forms.Application.DoEvents();        // 반복작업중 응답없음 안뜨게 하기
                                            this.Cursor = Cursors.WaitCursor;   //Waitting
                                        }
                                    }

                                    sRtnCode = rtnData.Contains("SUCCESS") ? "S" : "E";

                                    //결과저장
                                    Common.GetRestSaveResult("MES_IF_402", sJsonData, sWDOC_NO, "1", sRtnCode, rtnData).Equals("S");

                                    if (bWMSTrans == true)
                                    {
                                        if (rtnData.Contains("result"))
                                        {
                                            if (sRtnCode.Equals("S"))
                                            {
                                                sRtnMessage = "완제품 입고요청이 정상적으로 완료되었습니다.";
                                            }
                                            else
                                            {
                                                this.Cursor = Cursors.Default;   //Waitting
                                                new POPUP.MessageForm("완제품 입고요청이 실패하였습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                                return;
                                            }
                                        }
                                        else
                                        {
                                            this.Cursor = Cursors.Default;   //Waitting
                                            new POPUP.MessageForm("완제품 입고요청이 실패하였습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                            return;
                                        }
                                    }
                                    else
                                    {
                                        this.Cursor = Cursors.Default;   //Waitting
                                        new POPUP.MessageForm("완제품 입고요청 WMS전송이 실패하였습니다.\nWMS 재전송을 진행 하겠습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);

                                        try
                                        {
                                            System.Windows.Forms.Application.DoEvents();        // 반복작업중 응답없음 안뜨게 하기
                                            this.Cursor = Cursors.WaitCursor;   //Waitting
                                            Thread.Sleep(1000);

                                            LogFile.WriteLog("POP_WRK20.doConfirm::GetRestToString 재전송\r\n");
                                            rtnData = Common.GetRestToString(pURL, sJsonData, "POST");
                                        }
                                        catch (Exception EX_WMS)
                                        {
                                            LogFile.WriteLog("POP_WRK20.doConfirm::GetRestToString Error\r\n" + EX_WMS.ToString());
                                            // Exception 내용 결과 저장 시 내용에서 ":", "'" 문자 제거
                                            rtnData = "{\"result\":\"" + EX_WMS.Message.Replace(":", "").Replace("'", "") + "\",\"IFID\":\"WMS_IF_205\"}";
                                        }

                                        sRtnCode = rtnData.Contains("SUCCESS") ? "S" : "E";

                                        //결과저장
                                        Common.GetRestSaveResult("MES_IF_402", sJsonData, sWDOC_NO, "1", sRtnCode, rtnData).Equals("S");

                                        if (rtnData.Contains("result"))
                                        {
                                            if (sRtnCode.Equals("S"))
                                            {
                                                sRtnMessage = "완제품 입고요청이 정상적으로 완료되었습니다.";
                                            }
                                            else
                                            {
                                                this.Cursor = Cursors.Default;   //Waitting
                                                new POPUP.MessageForm("완제품 입고요청 WMS전송이 실패하였습니다.\n'WMS 재전송' 버튼을 눌러서 재전송 진행하여 주시기 바랍니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                                return;
                                            }
                                        }
                                        else
                                        {
                                            this.Cursor = Cursors.Default;   //Waitting
                                            new POPUP.MessageForm("완제품 입고요청 WMS전송이 실패하였습니다.\n'WMS 재전송' 버튼을 눌러서 재전송 진행하여 주시기 바랍니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                            return;
                                        }
                                    }
                                }
                            }
                            else
                            {
                                LogFile.WriteLog("SP_POP_WRK20_I01[SAP Retrun Error] : " + sapRFC.rtnMSG);
                                this.Cursor = Cursors.Default;   //Waitting
                                throw new Exception("개별바코드 [" + sIND_BCD + "] 생산실적 SAP전송이 실패하였습니다.\r\n오류메시지\r\n" + sapRFC.rtnMSG);
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        try
                        {
                            LogFile.WriteLog("POP_WRK20.doConfirm Error\r\n" + ex.Message);
                            sResult = "ROLLBACK";
                            RollbackLog(helper, dsTemp, ex.Message, sResult, false);
                            ProdRollback_HL(helper, sapTemp, dsTemp);
                            helper.Rollback();

                            LogFile.WriteLog("POP_WRK20.doConfirm ROLLBACK 완료\r\n");

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
                }

                this.Cursor = Cursors.Default;   //Waitting
                new POPUP.MessageForm(sRtnMessage, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                dtEnd = DateTime.Now;
                tsDiff = dtEnd - dtStr;
                //new POPUP.MessageForm(sRtnMessage + "\n 소요시간 : " + tsDiff.Seconds.ToString() + string.Format("{0:T}", dtStr) + "~" + string.Format("{0:T}", dtEnd), MessageBoxButtons.OK, "알   림").ShowDialog(this);
            }
            finally
            {
                SetGrid();
            }
        }

        private void doConfirm_WMSReSend(string pType)
        {
            string sPlantCode = Common.PlantCode;
            string sOPCode = Common.OpCode;
            string sUserID = Common.UserID;
            //요청문서목록
            DataTable dtReqList;
            string sWrkList;
            string sWDOC_NO = string.Empty;
            string sPRFM_FUNC = string.Empty;
            string sUSE_FUNC = string.Empty;
            string sRtnMessage = string.Empty;
            string sRtnCode = string.Empty;

            DateTime dtStr;
            DateTime dtEnd;
            TimeSpan tsDiff;

            if (Grid1.Rows.Count < 1)
            {
                new POPUP.MessageForm("해당 날짜에 실적 데이터가 없습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return;
            }
            /*if (!chkReqList())
            {
                new POPUP.MessageForm("확인이 완료된 실적이 존재합니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return;
            }*/

            DataSet dsTemp = new DataSet(); //실적등록 결과 수신(0:라벨정보, 1:RFC 변수, 2:RFC 상세변수)
            string sResult = string.Empty;
            //rollback용 
            //SAP 롤백용 추가 CODE 범위 START
            DataTable sapTemp = new DataTable(); // 성공한 sap 정보 저장
            //SAP 롤백용 추가 CODE 범위 END
            //rollback용 end

            try
            {
                sRtnMessage = "생산실적 전송이 정상적으로 완료되었습니다.";
                //개별 바코드 단위로 전송처리
                dtStr = DateTime.Now;
                for (int i = 0; i < Grid1.Rows.Count; i++)
                {
                    DBHelper helper = new DBHelper(false, "", true);

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

                        //체크여부 확인
                        //if (!Grid1.Rows[i].Cells["CHK"].Value.ToString().Equals("V"))
                        //    continue;
                        if
                        (
                            !(
                            Grid1.Rows[i].Cells["CHK"].Value.ToString().Equals("V") &&
                            Grid1.Rows[i].Cells["CHK_YN_NM"].Value.ToString().Equals("확인") &&
                            Grid1.Rows[i].Cells["WMS_STA"].Value.ToString().Equals("미요청")
                            )
                         )
                            continue;

                        this.Cursor = Cursors.WaitCursor;   //Waitting

                        string sIND_BCD = "";
                        //실적목록 테이블 JSON으로 변환
                        dtReqList = setReqList(i, ref sIND_BCD);
                        sWrkList = Common.toJsonFormat("POP_WRK20", dtReqList);

                        LogFile.WriteLog("PROC WRK_LIST : " + sWrkList, LogType.PROC);

                        dsTemp = helper.FillDataSetN("SP_POP_WRK20_I02", CommandType.StoredProcedure, 7
                                                                  , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)
                                                                  , helper.CreateParameter("P_PROC_CD", Common.OpCode, DbType.String, ParameterDirection.Input)
                                                                  , helper.CreateParameterOracle("P_WRK_LIST", sWrkList, OracleDbType.Clob, ParameterDirection.Input)
                                                                  , helper.CreateParameter("P_USERID", sUserID, DbType.String, ParameterDirection.Input)
                                                                  , helper.CreateParameter("P_PRFM_FUNC", DbType.String, ParameterDirection.Output, null, 30)
                                                                  , helper.CreateParameter("P_USE_FUNC", DbType.String, ParameterDirection.Output, null, 30)
                                                                  , helper.CreateParameter("P_WDOC_NO", DbType.String, ParameterDirection.Output, null, 30)
                                   );

                        //helper.Rollback();
                        if (helper.RSCODE == "E")
                        {
                            this.Cursor = Cursors.Default;   //Waitting
                            new POPUP.MessageForm(helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                            this.DialogResult = DialogResult.OK;
                            helper.Rollback();
                            return;
                        }
                        else
                        {
                            sPRFM_FUNC = helper.Parameters["P_PRFM_FUNC"].Value.ToString();
                            sUSE_FUNC = helper.Parameters["P_USE_FUNC"].Value.ToString();
                            sWDOC_NO = helper.Parameters["P_WDOC_NO"].Value.ToString();
                            //SAP 실적 등록
                            SAPHelper sapRFC = new SAPHelper();
                            //if (sapRFC.CallSAPFunc_HL(sPRFM_FUNC, dsTemp.Tables[0], dsTemp.Tables[1], helper).Equals("S"))
                            {
                                /*sapRFC.SaveResulttoWrk_HL(helper, "POP_WRK020", "0");//롤백처리용 결과처리 함수(COMMIT 제거)
                                //rollback용
                                //SAP 롤백용 추가 CODE 범위 START
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
                                //SAP 롤백용 추가 CODE 범위 END
                                //rollback용 end

                                Thread.Sleep(1000);
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
                                try { helper.Commit(); }// 모두 성공시 커밋
                                catch { }
                                */
                                try { helper.Commit(); }// 모두 성공시 커밋
                                catch { }

                                if (!string.IsNullOrEmpty(sWDOC_NO))
                                {
                                    //restful 전송
                                    string pURL = Common.WMS_IF_URL.Replace("IFID", "WMS_IF_205");
                                    string sJsonData = Common.toJsonFormat_List("list", dsTemp.Tables[2]);
                                    string rtnData = string.Empty;

                                    try
                                    {
                                        rtnData = Common.GetRestToString(pURL, sJsonData, "POST");
                                    }
                                    catch (Exception EX_WMS)
                                    {
                                        this.Cursor = Cursors.Default;   //Waitting
                                        LogFile.WriteLog("POP_WRK20.doConfirm Error\r\n" + EX_WMS.ToString());
                                        rtnData = "{\"result\":\"" + EX_WMS.Message.Replace(":", "").Replace("'", "") + "\",\"IFID\":\"WMS_IF_205\"}";
                                        //new POPUP.MessageForm("WMS 전송이 실패하였습니다. " + Environment.NewLine + EX_WMS.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                        //return;
                                    }
                                    sRtnCode = rtnData.Contains("SUCCESS") ? "S" : "E";

                                    //결과저장
                                    Common.GetRestSaveResult("MES_IF_402", sJsonData, sWDOC_NO, "1", sRtnCode, rtnData).Equals("S");

                                    if (rtnData.Contains("result"))
                                    {
                                        if (sRtnCode.Equals("S"))
                                        {
                                            sRtnMessage = "완제품 입고요청 WMS재전송이 정상적으로 완료되었습니다.";
                                        }
                                        else
                                        {
                                            this.Cursor = Cursors.Default;   //Waitting
                                            new POPUP.MessageForm("완제품 입고요청 WMS재전송이 실패하였습니다.\n잠시후 다시 재전송을 진행하여 주시기 바랍니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                            return;
                                        }
                                    }
                                    else
                                    {
                                        this.Cursor = Cursors.Default;   //Waitting
                                        new POPUP.MessageForm("완제품 입고요청 WMS재전송이 실패하였습니다.\n잠시후 다시 재전송을 진행하여 주시기 바랍니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                        return;
                                    }
                                }
                            }
                            //else
                            /*{
                                this.Cursor = Cursors.Default;   //Waitting
                                throw new Exception("생산실적 SAP전송이 실패하였습니다.\n" + sapRFC.rtnMSG);
                            }*/
                        }
                    }
                    catch (Exception ex)
                    {
                        try
                        {
                            LogFile.WriteLog("POP_WRK20.doConfirm_WMSReSend Error\r\n" + ex.Message);
                            sResult = "ROLLBACK";
                            RollbackLog(helper, dsTemp, ex.Message, sResult, false);
                            ProdRollback_HL(helper, sapTemp, dsTemp);
                            helper.Rollback();

                            LogFile.WriteLog("POP_WRK20.doConfirm_WMSReSend ROLLBACK 완료\r\n");
                            this.Cursor = Cursors.Default;   //Waitting

                            string sRollBackMsg = ex.Message + Environment.NewLine + "MES ROLLBACK WMS재전송 취소되었습니다";

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
                        helper.Close();
                    }

                }
                this.Cursor = Cursors.Default;   //Waitting
                new POPUP.MessageForm(sRtnMessage, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                dtEnd = DateTime.Now;
                tsDiff = dtEnd - dtStr;
                //new POPUP.MessageForm(sRtnMessage + "\n 소요시간 : " + tsDiff.Seconds.ToString() + string.Format("{0:T}", dtStr) + "~" + string.Format("{0:T}", dtEnd), MessageBoxButtons.OK, "알   림").ShowDialog(this);
            }
            catch (Exception ex)
            {
                LogFile.WriteLog("롤백 프로세스 Exception 발생\r\n" + ex.ToString());
            }
            finally
            {
                this.Cursor = Cursors.Default;   //Waitting
                SetGrid();
            }
        }

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
                                else //if (helper.RSCODE == "E")
                                {
                                    LogFile.WriteLog("HL ROLLBACK 등록 - MES IF TABLE 등록 오류 [" + helper.RSMSG.ToString() + "]");
                                    sMSG_ERR = "ROLLBACK MES IF TABLE 등록 오류 : " + helper.RSMSG.ToString() + Environment.NewLine;
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
            //20221226 이성민 에러 발생시 바깥 함수 EXCEPTION으로 토출되지 않도록 내부 TRY CATCH 설정, 현장로그 기록 보완 세팅
            //                특정 에러발생 가능성 위치 보완 진행 (CS 633줄 MENGE CONTAIN 누락)
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

        private void doReSend(int SelRow, string SendType)
        {
            DBHelper helper = new DBHelper(false, "", true);
            DataSet dsTemp; //실적등록 결과 수신(0:라벨정보, 1:RFC 변수, 2:RFC 상세변수)

            string sPlantCode = Common.PlantCode;
            string sOPCode = Common.OpCode;
            string sUserID = Common.UserID;
            string sIndBcd = Grid1.Rows[SelRow].Cells["IND_BCD"].Value.ToString();
            //요청문서목록
            DataTable dtReqList;
            string sWrkList;
            string sWDOC_NO = string.Empty;
            string sPRFM_FUNC = string.Empty;
            string sRtnMessage = string.Empty;
            string sRtnCode = string.Empty;
            DataTable dtTemp;
            DataSet dsPRFM = new DataSet(); //양품ㅡ 등록 RFC Data
            DataSet dsORDR = new DataSet(); //오더완료ㅡ 등록 RFC Data
            DataTable dtWMS = new DataTable();//완제품 입고요청 Restful Data

            try
            {
                this.Cursor = Cursors.WaitCursor;   //Waitting

                string sIND_BCD = "";
                //실적목록 테이블 JSON으로 변환
                dtReqList = setReqList(SelRow, ref sIND_BCD);
                sWrkList = Common.toJsonFormat("POP_WRK20", dtReqList);

                dsTemp = helper.FillDataSetN("SP_IF_PUT_REIFS", CommandType.StoredProcedure, 5
                                                              , helper.CreateParameter("P_IF_TYPE", SendType, DbType.String, ParameterDirection.Input)
                                                              , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)
                                                              , helper.CreateParameter("P_IND_BCD", sIndBcd, DbType.String, ParameterDirection.Input)
                                                              , helper.CreateParameter("P_PRFM_FUNC", DbType.String, ParameterDirection.Output, null, 30)
                                                              , helper.CreateParameter("P_WDOC_NO", DbType.String, ParameterDirection.Output, null, 30)
                                                              , helper.CreateParameter("P_USERID", sUserID, DbType.String, ParameterDirection.Input)
                               );

                if (helper.RSCODE == "E")
                {
                    this.Cursor = Cursors.Default;   //Waitting
                    new POPUP.MessageForm(helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    this.DialogResult = DialogResult.OK;
                    helper.Rollback();
                    return;
                }
                else
                {
                    sPRFM_FUNC = helper.Parameters["P_PRFM_FUNC"].Value.ToString();
                    sWDOC_NO = helper.Parameters["P_WDOC_NO"].Value.ToString();

                    //양품실적 Data
                    dtTemp = dsTemp.Tables[0].Copy();
                    dsPRFM.Tables.Add(dtTemp);
                    dtTemp = dsTemp.Tables[1].Copy();
                    dsPRFM.Tables.Add(dtTemp);
                    //오더완료 Data
                    dtTemp = dsTemp.Tables[2].Copy();
                    dsORDR.Tables.Add(dtTemp);
                    dtTemp = dsTemp.Tables[3].Copy();
                    dsORDR.Tables.Add(dtTemp);
                    //제품입고요청 Data
                    dtWMS = dsTemp.Tables[4].Copy();

                    if (SendType.Equals("P"))
                    {
                        //SAP 실적 등록
                        SAPHelper sapRFC = new SAPHelper();
                        if (sapRFC.CallSAPFunc(sPRFM_FUNC, dsPRFM.Tables[0], dsPRFM.Tables[1], helper).Equals("S"))
                        {
                            sapRFC.SaveResulttoWrk(helper, "POP_WRK020", "0");
                            Thread.Sleep(1000);

                            //오더 완료실적이 존재시
                            if (!dsORDR.Tables[0].Rows[0][0].ToString().Equals("1"))
                            {
                                SAPHelper sapRFC_O = new SAPHelper();
                                if (!sapRFC_O.CallSAPFunc(sPRFM_FUNC, dsORDR.Tables[0], dsORDR.Tables[1], helper).Equals("S"))
                                {
                                    this.Cursor = Cursors.Default;   //Waitting
                                    new POPUP.MessageForm("오더 완료 SAP전송이 실패하였습니다.\n" + sapRFC_O.rtnMSG, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                    return;
                                }
                                Thread.Sleep(1000);
                            }
                            helper.Commit();

                            if (!string.IsNullOrEmpty(sWDOC_NO))
                            {
                                //restful 전송
                                string pURL = Common.WMS_IF_URL.Replace("IFID", "WMS_IF_205");
                                string sJsonData = Common.toJsonFormat_List("list", dtWMS);

                                string rtnData = string.Empty;

                                try
                                {
                                    rtnData = Common.GetRestToString(pURL, sJsonData, "POST");
                                }
                                catch (Exception EX_WMS)
                                {
                                    LogFile.WriteLog("POP_WRK20.doReSend(P)::GetRestToString " + sWDOC_NO + "Error\r\n" + EX_WMS.ToString());
                                    // Exception 내용 결과 저장 시 내용에서 ":", "'" 문자 제거
                                    rtnData = "{\"result\":\"" + EX_WMS.Message.Replace(":", "").Replace("'", "") + "\",\"IFID\":\"WMS_IF_205\"}";
                                }

                                sRtnCode = rtnData.Contains("SUCCESS") ? "S" : "E";

                                //결과저장
                                Common.GetRestSaveResult("MES_IF_402", sJsonData, sWDOC_NO, "1", sRtnCode, rtnData).Equals("S");

                                if (rtnData.Contains("result"))
                                {
                                    if (sRtnCode.Equals("S"))
                                    {
                                        this.Cursor = Cursors.Default;   //Waitting
                                        new POPUP.MessageForm("완제품 입고요청이 정상적으로 완료되었습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                        return;
                                    }
                                    else
                                    {
                                        this.Cursor = Cursors.Default;   //Waitting
                                        new POPUP.MessageForm("완제품 입고요청이 실패하였습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                        return;
                                    }
                                }
                                else
                                {
                                    this.Cursor = Cursors.Default;   //Waitting
                                    new POPUP.MessageForm("완제품 입고요청 WMS전송이 실패하였습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                    return;
                                }
                            }
                            else
                            {
                                this.Cursor = Cursors.Default;   //Waitting
                                new POPUP.MessageForm("실적 재전송이 정상적으로 완료되었습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                return;
                            }
                        }
                        else
                        {
                            this.Cursor = Cursors.Default;   //Waitting
                            new POPUP.MessageForm("생산실적 SAP전송이 실패하였습니다.\nWEB에서 생산현황조회후 재발송을 진행하여 주시기 바랍니다." + sapRFC.rtnMSG, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                            return;
                        }
                    }
                    else if (SendType.Equals("W"))
                    {
                        if (!string.IsNullOrEmpty(sWDOC_NO))
                        {
                            //restful 전송
                            string pURL = Common.WMS_IF_URL.Replace("IFID", "WMS_IF_205");
                            string sJsonData = Common.toJsonFormat_List("list", dtWMS);

                            string rtnData;

                            try
                            {
                                rtnData = Common.GetRestToString(pURL, sJsonData, "POST");
                            }
                            catch (Exception EX_WMS)
                            {
                                LogFile.WriteLog("POP_WRK20.doReSend(W)::GetRestToString " + sWDOC_NO + "Error\r\n" + EX_WMS.Message);
                                // Exception 내용 결과 저장 시 내용에서 ":", "'" 문자 제거
                                rtnData = "{\"result\":\"" + EX_WMS.Message.Replace(":", "").Replace("'", "") + "\",\"IFID\":\"WMS_IF_205\"}";
                            }

                            sRtnCode = rtnData.Contains("SUCCESS") ? "S" : "E";

                            //결과저장
                            Common.GetRestSaveResult("MES_IF_402", sJsonData, sWDOC_NO, "1", sRtnCode, rtnData).Equals("S");

                            if (rtnData.Contains("result"))
                            {
                                if (sRtnCode.Equals("S"))
                                {
                                    this.Cursor = Cursors.Default;   //Waitting
                                    new POPUP.MessageForm("완제품 입고요청이 정상적으로 완료되었습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                    return;
                                }
                                else
                                {
                                    this.Cursor = Cursors.Default;   //Waitting
                                    new POPUP.MessageForm("완제품 입고요청이 실패하였습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                    return;
                                }
                            }
                            else
                            {
                                this.Cursor = Cursors.Default;   //Waitting
                                new POPUP.MessageForm("완제품 입고요청 WMS전송이 실패하였습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                return;
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                this.Cursor = Cursors.Default;   //Waitting
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                LogFile.WriteLog("POP_WRK20.doReSend Error\r\n" + ex.Message);
                helper.Rollback();
            }
            finally
            {
                this.Cursor = Cursors.Default;   //Waitting
                helper.Close();
                SetGrid();
            }
        }

        private void doReSend_WMSReSend(int SelRow, string SendType)
        {
            DBHelper helper = new DBHelper(false, "", true);
            DataSet dsTemp; //실적등록 결과 수신(0:라벨정보, 1:RFC 변수, 2:RFC 상세변수)

            string sPlantCode = Common.PlantCode;
            string sOPCode = Common.OpCode;
            string sUserID = Common.UserID;
            string sIndBcd = Grid1.Rows[SelRow].Cells["IND_BCD"].Value.ToString();
            //요청문서목록
            DataTable dtReqList;
            string sWrkList;
            string sWDOC_NO = string.Empty;
            string sPRFM_FUNC = string.Empty;
            string sRtnMessage = string.Empty;
            string sRtnCode = string.Empty;
            DataTable dtTemp;
            DataSet dsPRFM = new DataSet(); //양품ㅡ 등록 RFC Data
            DataSet dsORDR = new DataSet(); //오더완료ㅡ 등록 RFC Data
            DataTable dtWMS = new DataTable();//완제품 입고요청 Restful Data

            try
            {
                this.Cursor = Cursors.WaitCursor;   //Waitting

                string sIND_BCD = "";
                //실적목록 테이블 JSON으로 변환
                dtReqList = setReqList(SelRow, ref sIND_BCD);
                sWrkList = Common.toJsonFormat("POP_WRK20", dtReqList);

                dsTemp = helper.FillDataSetN("SP_IF_PUT_REIFS", CommandType.StoredProcedure, 5
                                                              , helper.CreateParameter("P_IF_TYPE", SendType, DbType.String, ParameterDirection.Input)
                                                              , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)
                                                              , helper.CreateParameter("P_IND_BCD", sIndBcd, DbType.String, ParameterDirection.Input)
                                                              , helper.CreateParameter("P_PRFM_FUNC", DbType.String, ParameterDirection.Output, null, 30)
                                                              , helper.CreateParameter("P_WDOC_NO", DbType.String, ParameterDirection.Output, null, 30)
                                                              , helper.CreateParameter("P_USERID", sUserID, DbType.String, ParameterDirection.Input)
                               );

                if (helper.RSCODE == "E")
                {
                    this.Cursor = Cursors.Default;   //Waitting
                    new POPUP.MessageForm(helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    this.DialogResult = DialogResult.OK;
                    helper.Rollback();
                    return;
                }
                else
                {
                    sPRFM_FUNC = helper.Parameters["P_PRFM_FUNC"].Value.ToString();
                    sWDOC_NO = helper.Parameters["P_WDOC_NO"].Value.ToString();

                    //양품실적 Data
                    dtTemp = dsTemp.Tables[0].Copy();
                    dsPRFM.Tables.Add(dtTemp);
                    dtTemp = dsTemp.Tables[1].Copy();
                    dsPRFM.Tables.Add(dtTemp);
                    //오더완료 Data
                    dtTemp = dsTemp.Tables[2].Copy();
                    dsORDR.Tables.Add(dtTemp);
                    dtTemp = dsTemp.Tables[3].Copy();
                    dsORDR.Tables.Add(dtTemp);
                    //제품입고요청 Data
                    dtWMS = dsTemp.Tables[4].Copy();

                    if (SendType.Equals("P"))
                    {
                        //SAP 실적 등록
                        SAPHelper sapRFC = new SAPHelper();
                        if (sapRFC.CallSAPFunc(sPRFM_FUNC, dsPRFM.Tables[0], dsPRFM.Tables[1], helper).Equals("S"))
                        {
                            sapRFC.SaveResulttoWrk(helper, "POP_WRK020", "0");
                            Thread.Sleep(1000);

                            //오더 완료실적이 존재시
                            if (!dsORDR.Tables[0].Rows[0][0].ToString().Equals("1"))
                            {
                                SAPHelper sapRFC_O = new SAPHelper();
                                if (!sapRFC_O.CallSAPFunc(sPRFM_FUNC, dsORDR.Tables[0], dsORDR.Tables[1], helper).Equals("S"))
                                {
                                    this.Cursor = Cursors.Default;   //Waitting
                                    new POPUP.MessageForm("오더 완료 SAP전송이 실패하였습니다.\n" + sapRFC_O.rtnMSG, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                    return;
                                }
                                Thread.Sleep(1000);
                            }
                            helper.Commit();

                            if (!string.IsNullOrEmpty(sWDOC_NO))
                            {
                                //restful 전송
                                string pURL = Common.WMS_IF_URL.Replace("IFID", "WMS_IF_205");
                                string sJsonData = Common.toJsonFormat_List("list", dtWMS);
                                string rtnData = Common.GetRestToString(pURL, sJsonData, "POST");

                                sRtnCode = rtnData.Contains("SUCCESS") ? "S" : "E";

                                //결과저장
                                Common.GetRestSaveResult("MES_IF_402", sJsonData, sWDOC_NO, "1", sRtnCode, rtnData).Equals("S");

                                if (rtnData.Contains("result"))
                                {
                                    if (sRtnCode.Equals("S"))
                                    {
                                        this.Cursor = Cursors.Default;   //Waitting
                                        new POPUP.MessageForm("완제품 입고요청이 정상적으로 완료되었습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                        return;
                                    }
                                    else
                                    {
                                        this.Cursor = Cursors.Default;   //Waitting
                                        new POPUP.MessageForm("완제품 입고요청이 실패하였습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                        return;
                                    }
                                }
                                else
                                {
                                    this.Cursor = Cursors.Default;   //Waitting
                                    new POPUP.MessageForm("완제품 입고요청 WMS전송이 실패하였습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                    return;
                                }
                            }
                            else
                            {
                                this.Cursor = Cursors.Default;   //Waitting
                                new POPUP.MessageForm("실적 재전송이 정상적으로 완료되었습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                return;
                            }
                        }
                        else
                        {
                            this.Cursor = Cursors.Default;   //Waitting
                            new POPUP.MessageForm("생산실적 SAP전송이 실패하였습니다.\nWEB에서 생산현황조회후 재발송을 진행하여 주시기 바랍니다." + sapRFC.rtnMSG, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                            return;
                        }
                    }
                    else if (SendType.Equals("W"))
                    {
                        if (!string.IsNullOrEmpty(sWDOC_NO))
                        {
                            //restful 전송
                            string pURL = Common.WMS_IF_URL.Replace("IFID", "WMS_IF_205");
                            string sJsonData = Common.toJsonFormat_List("list", dtWMS);
                            string rtnData = Common.GetRestToString(pURL, sJsonData, "POST");

                            sRtnCode = rtnData.Contains("SUCCESS") ? "S" : "E";

                            //결과저장
                            Common.GetRestSaveResult("MES_IF_402", sJsonData, sWDOC_NO, "1", sRtnCode, rtnData).Equals("S");

                            if (rtnData.Contains("result"))
                            {
                                if (sRtnCode.Equals("S"))
                                {
                                    this.Cursor = Cursors.Default;   //Waitting
                                    new POPUP.MessageForm("완제품 입고요청이 정상적으로 완료되었습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                    return;
                                }
                                else
                                {
                                    this.Cursor = Cursors.Default;   //Waitting
                                    new POPUP.MessageForm("완제품 입고요청이 실패하였습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                    return;
                                }
                            }
                            else
                            {
                                this.Cursor = Cursors.Default;   //Waitting
                                new POPUP.MessageForm("완제품 입고요청 WMS전송이 실패하였습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                return;
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                this.Cursor = Cursors.Default;   //Waitting
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                LogFile.WriteLog("POP_WRK20.doReSend Error\r\n" + ex.Message);
                helper.Rollback();
            }
            finally
            {
                this.Cursor = Cursors.Default;   //Waitting
                helper.Close();
                SetGrid();
            }
        }

        private void doWastePop()
        {
            POPUP.MessageForm msgForm = null;
            //DialogResult res = DialogResult.Cancel;

            int iSelCnt = 0;
            int iSelRow = -1;
            string sWrkOrdrNo;
            string sWrkOrdrSeq;
            string sMachCode;
            string sIndBcd;
            DataTable WrkOrderList = (DataTable)Grid1.DataSource;

            for (int i = 0; i < WrkOrderList.Rows.Count; i++)
            {
                if (WrkOrderList.Rows[i]["CHK"].ToString().Equals("V"))
                {
                    iSelCnt++;
                    iSelRow = i;
                }
            }

            if (iSelCnt < 1)
                new POPUP.MessageForm("작업실적을 선택하여 주시기 바랍니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
            else if (iSelCnt > 1)
                new POPUP.MessageForm("하나의 작업실적을 선택하여 주시기 바랍니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
            else
            {
                if (!Grid1.Rows[iSelRow].Cells["STCK_STA"].Value.ToString().Equals("40"))
                {
                    new POPUP.MessageForm("부적합 실적을 선택하시기 바랍니다..", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return;
                }
                sWrkOrdrNo = Grid1.Rows[iSelRow].Cells["WRK_ORDR_NO"].Value.ToString();
                sWrkOrdrSeq = Grid1.Rows[iSelRow].Cells["WRK_ORDR_SEQNO"].Value.ToString();
                sMachCode = Grid1.Rows[iSelRow].Cells["MACH_CD"].Value.ToString();
                sIndBcd = Grid1.Rows[iSelRow].Cells["IND_BCD"].Value.ToString();

                POP_WRK86 pop = new POP_WRK86(Common.PlantCode, sWrkOrdrNo, sWrkOrdrSeq, sMachCode, sIndBcd);
                pop.ShowDialog(this);
                if (pop.DialogResult == DialogResult.OK)
                {
                    msgForm = new POPUP.MessageForm("폐품등록이 완료되었습니다.", MessageBoxButtons.OK, "알   림");
                }
            }
        }

        private bool chkReqList()
        {
            DataTable WrkOrderList = (DataTable)Grid1.DataSource;

            for (int i = 0; i < WrkOrderList.Rows.Count; i++)
            {
                //선택된 행 확인여부 검사
                if (WrkOrderList.Rows[i]["CHK"].ToString().Equals("V") && WrkOrderList.Rows[i]["CHK_YN"].ToString().Equals("Y"))
                {
                    return false;
                }
            }
            return true;
        }

        private DataTable setReqList()
        {
            DataTable dtRtn = new DataTable();
            DataRow dtTempRow;
            DataTable WrkOrderList = (DataTable)Grid1.DataSource;

            //테이블 양식 작성
            dtRtn.Columns.Add(new DataColumn("WERKS", typeof(string))); //플랜트
            dtRtn.Columns.Add(new DataColumn("MACH_CD", typeof(string))); //설비코드
            dtRtn.Columns.Add(new DataColumn("LOT_NO", typeof(string))); //작업지시
            dtRtn.Columns.Add(new DataColumn("IND_BCD", typeof(string))); //작업지시 순번
            dtRtn.Columns.Add(new DataColumn("MATNR", typeof(string))); //자재코드
            dtRtn.Columns.Add(new DataColumn("PRFM_QTY", typeof(string))); //지시수량
            dtRtn.Columns.Add(new DataColumn("UNIT", typeof(string))); //단위
            dtRtn.Columns.Add(new DataColumn("PRFM_DT", typeof(string))); //실적일자

            for (int i = 0; i < WrkOrderList.Rows.Count; i++)
            {
                //선택된 행처리
                if (WrkOrderList.Rows[i]["CHK"].ToString().Equals("V"))
                {
                    //조회결과 입력용 Row생성
                    dtTempRow = dtRtn.NewRow();
                    dtTempRow["WERKS"] = WrkOrderList.Rows[i]["WERKS"].ToString();
                    dtTempRow["MACH_CD"] = WrkOrderList.Rows[i]["MACH_CD"].ToString();
                    dtTempRow["LOT_NO"] = WrkOrderList.Rows[i]["LOT_NO"].ToString();
                    dtTempRow["IND_BCD"] = WrkOrderList.Rows[i]["IND_BCD"].ToString();
                    dtTempRow["MATNR"] = WrkOrderList.Rows[i]["MATNR"].ToString();
                    dtTempRow["PRFM_QTY"] = WrkOrderList.Rows[i]["PRFM_QTY"].ToString();
                    dtTempRow["UNIT"] = WrkOrderList.Rows[i]["UNIT"].ToString();
                    dtTempRow["PRFM_DT"] = WrkOrderList.Rows[i]["PRFM_DT"].ToString();
                    //결과 테이블에 저장
                    dtRtn.Rows.Add(dtTempRow);
                }
            }
            return dtRtn;
        }

        private DataTable setReqList(int Index, ref string ind_bcd)
        {
            DataTable dtRtn = new DataTable();
            DataRow dtTempRow;
            DataTable WrkOrderList = (DataTable)Grid1.DataSource;

            //테이블 양식 작성
            dtRtn.Columns.Add(new DataColumn("WERKS", typeof(string))); //플랜트
            dtRtn.Columns.Add(new DataColumn("MACH_CD", typeof(string))); //설비코드
            dtRtn.Columns.Add(new DataColumn("LOT_NO", typeof(string))); //작업지시
            dtRtn.Columns.Add(new DataColumn("IND_BCD", typeof(string))); //작업지시 순번
            dtRtn.Columns.Add(new DataColumn("MATNR", typeof(string))); //자재코드
            dtRtn.Columns.Add(new DataColumn("PRFM_QTY", typeof(string))); //지시수량
            dtRtn.Columns.Add(new DataColumn("UNIT", typeof(string))); //단위
            dtRtn.Columns.Add(new DataColumn("PRFM_DT", typeof(string))); //실적일자

            //선택된 행처리
            if (WrkOrderList.Rows[Index]["CHK"].ToString().Equals("V"))
            {
                //조회결과 입력용 Row생성
                dtTempRow = dtRtn.NewRow();
                dtTempRow["WERKS"] = WrkOrderList.Rows[Index]["WERKS"].ToString();
                dtTempRow["MACH_CD"] = WrkOrderList.Rows[Index]["MACH_CD"].ToString();
                dtTempRow["LOT_NO"] = WrkOrderList.Rows[Index]["LOT_NO"].ToString();
                dtTempRow["IND_BCD"] = WrkOrderList.Rows[Index]["IND_BCD"].ToString();
                dtTempRow["MATNR"] = WrkOrderList.Rows[Index]["MATNR"].ToString();
                dtTempRow["PRFM_QTY"] = WrkOrderList.Rows[Index]["PRFM_QTY"].ToString();
                dtTempRow["UNIT"] = WrkOrderList.Rows[Index]["UNIT"].ToString();
                dtTempRow["PRFM_DT"] = WrkOrderList.Rows[Index]["PRFM_DT"].ToString();

                //결과 테이블에 저장
                dtRtn.Rows.Add(dtTempRow);

                ind_bcd = WrkOrderList.Rows[Index]["IND_BCD"].ToString();
            }

            return dtRtn;
        }

        private void doPrint()
        {
            bool bPrint = false;
            #region 바코드 라벨 테스트
            string PrinterName = SAMMI.IniFile.GetValue("KLEANNARA", "PRINTER", null);
            string PrinterDPI = SAMMI.IniFile.GetValue("KLEANNARA", "PRINTERDPI", null);
            string sZPL = string.Empty;
            //제목(PRODUCT)
            string sTitle = string.Empty;
            //생산정보(일자, 호기, 수량)
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

            if (!PrinterName.Contains("ZDesigner"))
            {
                new POPUP.MessageForm("선택된 프린터를 확인하여 주시기 바랍니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return;
            }

            DBHelper helper = new DBHelper(false);
            try
            {
                if (Grid1.Rows.Count == 0)
                {
                    new POPUP.MessageForm("조회된 실적 정보가 없습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return;
                }
                sTitle = "PRODUCT";
                for (int i = 0; i < Grid1.Rows.Count; i++)
                {
                    if (Grid1.Rows[i].Cells["CHK"].Value.ToString().Equals("V"))
                    {
                        //생산정보(일자, 호기, 수량)
                        sPRD_DT = Grid1.Rows[i].Cells["PRFM_DT"].Value.ToString();
                        sMACH_NM = Grid1.Rows[i].Cells["MACH_NM"].Value.ToString();
                        sPRFM_QTY = Grid1.Rows[i].Cells["BOX_QTY"].Value.ToString();
                        //제품정보(종류, 코드, 명, KAN, 기본단위, 파렛트단위, LOT)
                        sMATNR_DIV = Grid1.Rows[i].Cells["MATNR_DIV_NM"].Value.ToString();
                        sMATNR = Grid1.Rows[i].Cells["MATNR"].Value.ToString();
                        sMATNR_NM = Grid1.Rows[i].Cells["MATNR_NM"].Value.ToString();
                        sKAN_CD = Grid1.Rows[i].Cells["KAN_CD"].Value.ToString();
                        sBS_UNIT = Grid1.Rows[i].Cells["BAG2BOX"].Value.ToString();
                        sPLT_UNIT = Grid1.Rows[i].Cells["BOX2PLT"].Value.ToString();
                        sLOT_NO = Grid1.Rows[i].Cells["LOT_NO"].Value.ToString();
                        //바코드
                        sINDBCD = Grid1.Rows[i].Cells["IND_BCD"].Value.ToString();

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
                                bPrint = true;
                                break;
                            }
                        }
                    }
                }
                if (bPrint)
                    new POPUP.MessageForm("라벨이 출력되었습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                else
                    new POPUP.MessageForm("라벨출력을 실패하였습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                //this.DialogResult = DialogResult.OK;
            }
            catch (Exception ex)
            {
                LogFile.WriteLog("POP_WRK20.doPrint Error\r\n" + ex.Message);
            }
            finally
            {
                helper.Close();
            }
            #endregion

            #region A4라벨
            ////조회결과 입력용 Row생성
            //REPORT_ITEM HLitem = new REPORT_ITEM();

            //HLitem.PRD_DATE = Grid1.Rows[0].Cells["PRFM_DT"].Value.ToString();      // 생산일자
            //HLitem.MACH_NM = Grid1.Rows[0].Cells["MACH_NM"].Value.ToString();       // 설비호기 명
            //HLitem.WERKS_NM = Grid1.Rows[0].Cells["WERKS_NM"].Value.ToString();     // 제품구분
            //HLitem.MATNR = Grid1.Rows[0].Cells["MATNR"].Value.ToString();           // 제품코드
            //HLitem.MATNR_NM = Grid1.Rows[0].Cells["MATNR_NM"].Value.ToString();     // 제품명
            //HLitem.KAN_CD = Grid1.Rows[0].Cells["KAN_CD"].Value.ToString();         // KAN코드
            //HLitem.UNIT = Grid1.Rows[0].Cells["BAG2BOX"].Value.ToString();          // 기본단위
            //HLitem.PLT_UNIT = Grid1.Rows[0].Cells["BOX2PLT"].Value.ToString();      // 팔레트 단위
            //HLitem.IND_BCD = Grid1.Rows[0].Cells["IND_BCD"].Value.ToString();       // 개별바코드

            //string pstrERR = "";
            //REPORT rp = CommonReport.GetReport();   // REPORT rp = new REPORT();
            //rp.HL_PRINT(HLitem, ref pstrERR);
            //if (pstrERR.Length > 0)
            //{
            //    return;
            //}
            #endregion
        }

        private void doReRestful()
        {
            for (int i = 0; i < Grid1.Rows.Count; i++)
            {
                if (Grid1.Rows[i].Cells["CHK"].Value.ToString().Equals("V"))
                {
                    doReSend(i, "W");
                }
            }
        }
        private void doReRestful_WMSReSend()
        {
            for (int i = 0; i < Grid1.Rows.Count; i++)
            {
                if (Grid1.Rows[i].Cells["CHK"].Value.ToString().Equals("V") &&
                    Grid1.Rows[i].Cells["CHK_YN_NM"].Value.ToString().Equals("확인") &&
                    Grid1.Rows[i].Cells["WMS_STA"].Value.ToString().Equals("미요청")
                    )
                {
                    doReSend_WMSReSend(i, "W");
                }
            }
        }
        #endregion

        #region < EVNET >

        private void bBox1_buttonClickEvent(MESButton sender, ButtonBox.ButtonClickEventArg e)
        {
            //팝업 변수
            POPUP.MessageForm msgForm = null;
            DialogResult res = DialogResult.Cancel;
            int iCnt = 0;

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
                    if (Grid1.Rows[i].Cells["CHK"].Value.ToString().Equals("V"))
                        iCnt++;

                switch (btn.Tag.ToString())
                {
                    case "Print":  //라벨재발행
                        if (iCnt == 0)
                        {
                            msgForm = new POPUP.MessageForm("라벨을 출력할 작업실적을 선택하여 주시기 바랍니다.", MessageBoxButtons.OK, "알   림");
                            res = msgForm.ShowDialog(this);
                        }
                        else
                        {
                            doPrint();
                        }
                        break;
                    case "Input":  //WMS 제품 입고 요청
                        if (iCnt == 0)
                        {
                            msgForm = new POPUP.MessageForm("입고를 요청할 작업실적을 선택하여 주시기 바랍니다.", MessageBoxButtons.OK, "알   림");
                            res = msgForm.ShowDialog(this);
                        }
                        else
                        {
                            doConfirm("I");
                        }
                        break;
                    case "Check":  //품질팀 검사요청
                        if (iCnt == 0)
                        {
                            msgForm = new POPUP.MessageForm("확인이 완료된 작업실적을 선택하여 주시기 바랍니다.", MessageBoxButtons.OK, "알   림");
                            res = msgForm.ShowDialog(this);
                        }
                        else
                        {
                            doConfirm("C");
                        }
                        break;
                    case "Waste":  //부분 폐품
                        if (iCnt == 0)
                        {
                            msgForm = new POPUP.MessageForm("폐품을 등록할 작업실적을 선택하여 주시기 바랍니다.", MessageBoxButtons.OK, "알   림");
                            res = msgForm.ShowDialog(this);
                        }
                        else
                        {
                            doWastePop();
                        }
                        break;
                    case "ReSend":  //WMS 재발송
                        /*  20221228 wsw
                            case "ReSend":  //SAP 재발송
                            POP_WRK89 pop = new POP_WRK89(Common.PlantCode, Common.MachineCode);
                            pop.ShowDialog(this);*/
                        int count = 0;
                        for (int i = 0; i < Grid1.Rows.Count; i++)
                        {
                            if (Grid1.Rows[i].Cells["CHK"].Value.ToString().Equals("V") &&
                                Grid1.Rows[i].Cells["CHK_YN_NM"].Value.ToString().Equals("확인") &&
                                Grid1.Rows[i].Cells["WMS_STA"].Value.ToString().Equals("미요청")
                               )
                            {
                                count++;
                            }
                        }
                        if (count == 0)
                        {
                            msgForm = new POPUP.MessageForm("입고요청을 재요청할 실적(생산확인:확인,입고요청:미요청)을 선택하여 주시기 바랍니다.", MessageBoxButtons.OK, "알   림");
                            res = msgForm.ShowDialog(this);
                        }
                        else
                        {
                            //20221228 wsw
                            doConfirm_WMSReSend("I");
                            //doReRestful_WMSReSend();
                        }
                        break;
                    case "ReRestful":  //WMS 재발송
                        if (iCnt == 0)
                        {
                            msgForm = new POPUP.MessageForm("입고요청을 재요청할 실적을 선택하여 주시기 바랍니다.", MessageBoxButtons.OK, "알   림");
                            res = msgForm.ShowDialog(this);
                        }
                        else
                        {
                            doReRestful();
                        }
                        break;
                    case "InputStatus": //자재투입현황
                        POP_INV91 INV91 = new POP_INV91();
                        ShowDialogForm(INV91);
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
                LogFile.WriteLog("POP_WRK20.bBox1_buttonClickEvent Error\r\n" + ex.Message);
            }
            finally
            {
                SetGrid();
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
            else if (e.column.ToString() == "RESEND")
            {
                doReSend(e.row.Index, "P");
            }
        }

        private void btnWorkDate_Click(object sender, EventArgs e)
        {
            DAResultDate pop = new DAResultDate(dtpWorkDate.Value);
            pop.ShowDialog(this);
            if (pop.DialogResult == DialogResult.OK)
            {
                string strDate = pop.ResultString.ToString();
                dtpWorkDate.Value = DateTime.Parse(strDate);
            }
        }

        private void btnCHKFLAG_Click(object sender, EventArgs e)
        {
            POPCombo combo_pop = new POPCombo("확인여부", "CHKPPYN", "SP_POP00_S02", "CHKPPYN");
            combo_pop.ShowDialog(this);
            if (combo_pop.DialogResult == DialogResult.OK)
            {
                lblCHKFLAG.Tag = combo_pop.resultArray[0].ToString(); //code
                lblCHKFLAG.Text = combo_pop.resultArray[1].ToString(); //display

                SetGrid();
            }
        }

        private void lblCHKFLAG2_Click(object sender, EventArgs e)
        {
            POPCombo combo_pop = new POPCombo("부적합여부", "STCKSTA", "SP_POP00_S02", "00,40");
            combo_pop.ShowDialog(this);
            if (combo_pop.DialogResult == DialogResult.OK)
            {
                lblCHKFLAG2.Tag = combo_pop.resultArray[0].ToString(); //code
                lblCHKFLAG2.Text = combo_pop.resultArray[1].ToString(); //display

                SetGrid();
            }
        }

        private void dtpDate_DropDown(object sender, EventArgs e)
        {
            CommonCalendar.CloseCalendar((DateTimePicker)sender);
        }

        #endregion

    }
}
