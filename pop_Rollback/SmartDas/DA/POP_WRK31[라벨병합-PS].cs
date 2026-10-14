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
#endregion

namespace SmartDas
{
    public partial class POP_WRK31 : BaseForm
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
        #endregion

        #region < CONSTRUCTOR >

        public POP_WRK31()
        {
            InitializeComponent();

            Common.SetMessageList();

            gsOP_CODE = Common.OpCode;
            gsMACH_CD = Common.MachineCode;
        }

        #endregion

        #region < POP_WRK31_Load >
        private void POP_WRK31_Load(object sender, EventArgs e)
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

                this.lblTitle.Text = "실적현황(라벨병합)";

                DateTime dtTime;
                if (DateTime.TryParseExact(Common.gRecDate, "yyyyMMdd", null, DateTimeStyles.AssumeLocal, out dtTime))
                {
                    cboToDate.Value = dtTime;
                    cboFromDate.Value = dtTime.AddDays(-1);
                }

                SetMenuButtons();
                SetGrid();
            }
            catch (Exception ex)
            {
                SetMessage("POP_WRK31_Load_ Error!");
                LogFile.WriteLog("POP_WRK31_Load Error => " + ex.Message);
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
                bBox1[0, 0].Text = "라벨" + Environment.NewLine + "재발행";
                bBox1[0, 0].Tag = "Print";
                bBox1[0, 0].MappingButton.FontSize = 14;
                bBox1[0, 1].Text = "라벨병합";
                bBox1[0, 1].Tag = "Merge";
                bBox1[0, 1].MappingButton.FontSize = 14;
                bBox1[0, 2].Text = "라벨병합" + Environment.NewLine + "취소";
                bBox1[0, 2].Tag = "UnMerge";
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
                LogFile.WriteLog("POP_WRK31.SetButtons Error => " + ex.Message);
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



            string sPFROM_DT = cboFromDate.Value.ToString("yyyyMMdd");
            string sPTO_DT = cboToDate.Value.ToString("yyyyMMdd");
            string sMATNR = txtMATNR.Text.Trim();

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
                dtRtn = helper.FillTable("SP_POP_WRK31_S01", CommandType.StoredProcedure
                                                    , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)  // 플랜트코드
                                                    , helper.CreateParameter("P_MACH_CD", gsMACH_CD, DbType.String, ParameterDirection.Input)       // 작업장코드(설비코드)
                                                    , helper.CreateParameter("P_PFROM_DT", sPFROM_DT, DbType.String, ParameterDirection.Input)      // 조회일자 (FROM)
                                                    , helper.CreateParameter("P_PTO_DT", sPTO_DT, DbType.String, ParameterDirection.Input)          // 조회일자 (TO)
                                                    , helper.CreateParameter("P_MATNR", sMATNR, DbType.String, ParameterDirection.Input)            // 자재코드
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
                LogFile.WriteLog("POP_WRK31.SetGrid Error => " + ex.Message);
            }
        }

        // 라벨 병합
        private void doLabelMerge()
        {
            DBHelper helper = new DBHelper(false, "", true);
            DataTable dtList;
            DataSet dsTemp = new DataSet();     //실적등록 결과 수신(0:실적 RFC ID, 1:실적 IF 변수, 2:실적 RFC ID, 3:실적 IF 변수)
            bool bReturn = false, bReturn1 = false, bReturn2 = false; // 실적 처리 결과
            string sRES_IND_BCD = string.Empty;
            string EMSG = string.Empty;
            string sResult = string.Empty;

            //rollback용 
            //SAP 롤백용 추가 CODE 범위 START
            DataTable sapTemp = new DataTable();
            DataTable cancleTemp = new DataTable();
            DataTable prodTemp = new DataTable();
            DataTable[] tableGroup = new DataTable[2] { cancleTemp, prodTemp };
            sapTemp.Columns.Add("SAP_TYPE", typeof(string));
            sapTemp.Columns.Add("IF_KEY", typeof(string));
            sapTemp.Columns.Add("MDOCNO", typeof(string));
            sapTemp.Columns.Add("MDOCSEQ", typeof(string));
            sapTemp.Columns.Add("SDOC_NO", typeof(string));
            sapTemp.Columns.Add("SDOC_SEQNO", typeof(string));
            //SAP 롤백용 추가 CODE 범위 END
            //rollback용 end



            string sIND_BCD = "";
            try
            {
                dtList = setReqMergeList("M", out sIND_BCD);

                if (dtList == null)
                {
                    new POPUP.MessageForm("2개 이상의 판매문서/품목이 선택되었습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return;
                }
                else if (dtList.Rows.Count > 5)
                {
                    new POPUP.MessageForm("라벨병합은 5 팔레트까지 가능합니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return;
                }

                if (dtList.Select("MER_YN = 'Y'").Length > 0)
                {
                    new POPUP.MessageForm("이미 병합된 바코드 입니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return;
                }

                // 병합 처리 여부 확인
                if (new POPUP.MessageForm("선택된 바코드를 병합 처리 하시겠습니까?\r\n" + sIND_BCD, MessageBoxButtons.YesNo, "알   림").ShowDialog(this) == DialogResult.No)
                {
                    return;
                }

                string sJsonData = Common.toJsonFormat("POP_WRK030", dtList);

                this.Cursor = Cursors.WaitCursor;   //Waitting

                dsTemp = helper.FillDataSetN("SP_POP_WRK30_I05", CommandType.StoredProcedure, 20
                    , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)       // 플랜트
                    , helper.CreateParameterOracle("P_JSON_STR", sJsonData, OracleDbType.Clob, ParameterDirection.Input)
                    , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input)         // 사용자ID
                    , helper.CreateParameter("RS_PRFM_RFCFN", DbType.String, ParameterDirection.Output, null, 200)       // 병합실적 RFCFN
                    , helper.CreateParameter("RS_PRFM_RFCFN_CN", DbType.String, ParameterDirection.Output, null, 200)     // 실적취소 RFCFN
                    , helper.CreateParameter("RS_PRFM_RFCFN_ZR", DbType.String, ParameterDirection.Output, null, 200)     // 실적취소 RFCFN
                    , helper.CreateParameter("RS_MER_IND_BCD", DbType.String, ParameterDirection.Output, null, 1000)     // RES 개별바코드 리스트
                    );

                //1. A 생산실적 취소 ( 최대 5개)
                //2. C 생산실적 등록 ( A 와 같은 내용으로..) => 라벨병합
                //3. 취소라벨 실적 전송 (완료를 위해)

                if (helper.RSCODE.Equals("S"))
                {
                    sRES_IND_BCD = helper.Parameters["RS_MER_IND_BCD"].Value.ToString();

                    string sRS_PRFM_RFCFN = helper.Parameters["RS_PRFM_RFCFN"].Value.ToString();      // 실적 RFCFN ID
                    string sRS_PRFM_RFCFNC = helper.Parameters["RS_PRFM_RFCFN_CN"].Value.ToString();  // 실적취소 RFCFN ID
                    string sRS_PRFM_RFCFNZR = helper.Parameters["RS_PRFM_RFCFN_ZR"].Value.ToString(); // ZERO실적 RFCFN ID

                    if (dsTemp.Tables[0].Rows[0][0].ToString() != "1") tableGroup[0] = dsTemp.Tables[1].Copy();
                    if (dsTemp.Tables[3].Rows[0][0].ToString() != "1") tableGroup[1] = dsTemp.Tables[3].Copy();
                    if (dsTemp.Tables[5].Rows[0][0].ToString() != "1") tableGroup[1].Merge(dsTemp.Tables[5]);
                    if (dsTemp.Tables[7].Rows[0][0].ToString() != "1") tableGroup[1].Merge(dsTemp.Tables[7]);
                    if (dsTemp.Tables[9].Rows[0][0].ToString() != "1") tableGroup[1].Merge(dsTemp.Tables[9]);
                    if (dsTemp.Tables[11].Rows[0][0].ToString() != "1") tableGroup[1].Merge(dsTemp.Tables[11]);
                   


#if false
                {
                    this.Cursor = Cursors.Default;   //Waitting

                    if (helper.RSCODE == "E")
                    {
                        new POPUP.MessageForm(helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    }
                    helper.Rollback();
                    return;
                }
#endif
                    // 라벨병합에 사용된 바코드 실적 삭제
                    if (!string.IsNullOrEmpty(sRS_PRFM_RFCFNC))
                    {
                        if (dsTemp.Tables[2].Rows[0][0].ToString() != "1")
                        {
                            SAPHelper sapRFC_P = new SAPHelper();

                            // sapRFC.CallSAPFunc 호출시 helper를 사용하여 내용이 변경됨. 
                            // 필요한 정보는 sapRFC.CallSAPFunc 호출전에 처리해야함.
                            if (sapRFC_P.CallSAPFunc_HL(sRS_PRFM_RFCFNC, dsTemp.Tables[2], dsTemp.Tables[3], helper).Equals("S"))
                            {
                                bReturn1 = true;

                                //rollback 적용 정보수집 start 
                                SaveRfcSuccesData("2.CANCLE_REG_SAP", sRS_PRFM_RFCFNC, sapRFC_P, ref tableGroup[1], ref sapTemp, sapRFC_P.rtnTable.Rows[0]["RUECK"].ToString(), sapRFC_P.rtnTable.Rows[0]["RMZHL"].ToString());
                                //end

                                Thread.Sleep(Common.SLEEP_DELAY);
                                System.Windows.Forms.Application.DoEvents();        // 반복작업중 응답없음 안뜨게 하기
                                this.Cursor = Cursors.WaitCursor;   //Waitting
                            }
                            else
                            {
                                bReturn1 = false;
                                //helper.Rollback();
                                LogFile.WriteLog("라벨병합(1)을 위한 실적 취소 SAP 전송 오류 [" + sapRFC_P.rtnMSG + "]");
                                throw new Exception("라벨병합(1)을 위한 실적 취소 SAP전송이 실패하였습니다.\r\n" + sapRFC_P.rtnMSG);
                            }
                        }
                        else
                        {
                            // 최소  두개는 반드시 있어야 함.
                            bReturn1 = false;
                            EMSG = "라벨병합에 사용할 개발바코드 정보가 없습니다.";
                        }

                        if (dsTemp.Tables[4].Rows[0][0].ToString() != "1" && bReturn1)
                        {
                            SAPHelper sapRFC_P = new SAPHelper();

                            // sapRFC.CallSAPFunc 호출시 helper를 사용하여 내용이 변경됨. 
                            // 필요한 정보는 sapRFC.CallSAPFunc 호출전에 처리해야함.
                            if (sapRFC_P.CallSAPFunc_HL(sRS_PRFM_RFCFNC, dsTemp.Tables[4], dsTemp.Tables[5], helper).Equals("S"))
                            {
                                bReturn1 = true;

                                //rollback 적용 정보수집 start 
                                SaveRfcSuccesData("2.CANCLE_REG_SAP", sRS_PRFM_RFCFNC, sapRFC_P, ref tableGroup[1], ref sapTemp, sapRFC_P.rtnTable.Rows[0]["RUECK"].ToString(), sapRFC_P.rtnTable.Rows[0]["RMZHL"].ToString());
                                //end

                                Thread.Sleep(Common.SLEEP_DELAY);
                                System.Windows.Forms.Application.DoEvents();        // 반복작업중 응답없음 안뜨게 하기
                                this.Cursor = Cursors.WaitCursor;   //Waitting
                            }
                            else
                            {
                                bReturn1 = false;
                                //helper.Rollback();
                                LogFile.WriteLog("라벨병합(2)을 위한 실적 취소 SAP 전송 오류 [" + sapRFC_P.rtnMSG + "]");
                                throw new Exception("라벨병합(2)을 위한 실적 취소 SAP전송이 실패하였습니다.\r\n" + sapRFC_P.rtnMSG);
                            }
                        }
                        else
                        {
                            // 최소  두개는 반드시 있어야 함.
                            bReturn1 = false;
                            EMSG = "라벨병합에 사용할 개발바코드 정보가 없습니다.";
                        }

                        if (dsTemp.Tables[6].Rows[0][0].ToString() != "1" && bReturn1)
                        {
                            SAPHelper sapRFC_P = new SAPHelper();

                            // sapRFC.CallSAPFunc 호출시 helper를 사용하여 내용이 변경됨. 
                            // 필요한 정보는 sapRFC.CallSAPFunc 호출전에 처리해야함.
                            if (sapRFC_P.CallSAPFunc_HL(sRS_PRFM_RFCFNC, dsTemp.Tables[6], dsTemp.Tables[7], helper).Equals("S"))
                            {
                                bReturn1 = true;

                                //rollback 적용 정보수집 start 
                                SaveRfcSuccesData("2.CANCLE_REG_SAP", sRS_PRFM_RFCFNC, sapRFC_P, ref tableGroup[1], ref sapTemp, sapRFC_P.rtnTable.Rows[0]["RUECK"].ToString(), sapRFC_P.rtnTable.Rows[0]["RMZHL"].ToString());
                                //end

                                Thread.Sleep(Common.SLEEP_DELAY);
                                System.Windows.Forms.Application.DoEvents();        // 반복작업중 응답없음 안뜨게 하기
                                this.Cursor = Cursors.WaitCursor;   //Waitting
                            }
                            else
                            {
                                bReturn1 = false;
                                //helper.Rollback();
                                LogFile.WriteLog("라벨병합(3)을 위한 실적 취소 SAP 전송 오류 [" + sapRFC_P.rtnMSG + "]");
                                throw new Exception("라벨병합(3)을 위한 실적 취소 SAP전송이 실패하였습니다.\r\n" + sapRFC_P.rtnMSG);
                            }
                        }
                        else
                        {
                            bReturn1 = true;
                        }

                        if (dsTemp.Tables[8].Rows[0][0].ToString() != "1" && bReturn1)
                        {
                            SAPHelper sapRFC_P = new SAPHelper();

                            // sapRFC.CallSAPFunc 호출시 helper를 사용하여 내용이 변경됨. 
                            // 필요한 정보는 sapRFC.CallSAPFunc 호출전에 처리해야함.
                            if (sapRFC_P.CallSAPFunc_HL(sRS_PRFM_RFCFNC, dsTemp.Tables[8], dsTemp.Tables[9], helper).Equals("S"))
                            {
                                bReturn1 = true;

                                //rollback 적용 정보수집 start 
                                SaveRfcSuccesData("2.CANCLE_REG_SAP", sRS_PRFM_RFCFNC, sapRFC_P, ref tableGroup[1], ref sapTemp, sapRFC_P.rtnTable.Rows[0]["RUECK"].ToString(), sapRFC_P.rtnTable.Rows[0]["RMZHL"].ToString());
                                //end

                                Thread.Sleep(Common.SLEEP_DELAY);
                                System.Windows.Forms.Application.DoEvents();        // 반복작업중 응답없음 안뜨게 하기
                                this.Cursor = Cursors.WaitCursor;   //Waitting
                            }
                            else
                            {
                                bReturn1 = false;
                                //helper.Rollback();
                                LogFile.WriteLog("라벨병합(4)을 위한 실적 취소 SAP 전송 오류 [" + sapRFC_P.rtnMSG + "]");
                                throw new Exception("라벨병합(4)을 위한 실적 취소 SAP전송이 실패하였습니다.\r\n" + sapRFC_P.rtnMSG);
                            }
                        }
                        else
                        {
                            bReturn1 = true;
                        }

                        if (dsTemp.Tables[10].Rows[0][0].ToString() != "1" && bReturn1)
                        {
                            SAPHelper sapRFC_P = new SAPHelper();

                            // sapRFC.CallSAPFunc 호출시 helper를 사용하여 내용이 변경됨. 
                            // 필요한 정보는 sapRFC.CallSAPFunc 호출전에 처리해야함.
                            if (sapRFC_P.CallSAPFunc_HL(sRS_PRFM_RFCFNC, dsTemp.Tables[10], dsTemp.Tables[11], helper).Equals("S"))
                            {
                                bReturn1 = true;

                                //rollback 적용 정보수집 start 
                                SaveRfcSuccesData("2.CANCLE_REG_SAP", sRS_PRFM_RFCFNC, sapRFC_P, ref tableGroup[1], ref sapTemp, sapRFC_P.rtnTable.Rows[0]["RUECK"].ToString(), sapRFC_P.rtnTable.Rows[0]["RMZHL"].ToString());
                                //end

                                Thread.Sleep(Common.SLEEP_DELAY);
                                System.Windows.Forms.Application.DoEvents();        // 반복작업중 응답없음 안뜨게 하기
                                this.Cursor = Cursors.WaitCursor;   //Waitting
                            }
                            else
                            {
                                bReturn1 = false;
                                //helper.Rollback();
                                LogFile.WriteLog("라벨병합(5)을 위한 실적 취소 SAP 전송 오류 [" + sapRFC_P.rtnMSG + "]");
                                throw new Exception("라벨병합(5)을 위한 실적 취소 SAP전송이 실패하였습니다.\r\n" + sapRFC_P.rtnMSG);
                            }
                        }
                    }
                    else
                    {
                        bReturn1 = true;
                    }

                    // 병합 바코드 실적 등록
                    if (!string.IsNullOrEmpty(sRS_PRFM_RFCFN) && bReturn1)
                    {
                        string sRfcData; //RFC결과 JSON 변환

                        //SAP 실적 등록
                        SAPHelper sapRFC_P = new SAPHelper();

                        // sapRFC.CallSAPFunc 호출시 helper를 사용하여 내용이 변경됨. 
                        // 필요한 정보는 sapRFC.CallSAPFunc 호출전에 처리해야함.
                        if (sapRFC_P.CallSAPFunc_HL(sRS_PRFM_RFCFN, dsTemp.Tables[0], dsTemp.Tables[1], helper).Equals("S"))
                        {
                            // ---- 전달시 MBLNR, MJAHR을 replace 처리하여 하나로 받도록함.
                            sRfcData = Common.toJsonFormat("PUT_WRKRTN", sapRFC_P.rtnTable).Replace("MBLNR", "RUECK").Replace("MJAHR", "RMZHL");

                            //rollback 적용 정보수집 start 
                            SaveRfcSuccesData("1.PROD_REG_SAP", sRS_PRFM_RFCFN, sapRFC_P, ref tableGroup[0], ref sapTemp, "", "");
                            //end

                            //실적등록 테이블에 확정문서 번호 갱신
                            helper.ExecuteNoneQuery("SP_IF_PUT_WRKRTN_HL", CommandType.StoredProcedure
                                                                , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)       // 플랜트
                                                                , helper.CreateParameter("P_WRK_TYPE", "0", DbType.String, ParameterDirection.Input)                 // '0'= 실적테이블_비계획생산, '1'= 폐품테이블, '2'=소요량, '3'=비가동
                                                                , helper.CreateParameterOracle("P_RFC_DATA", sRfcData, OracleDbType.Clob, ParameterDirection.Input)
                                                                , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input));
                            if (helper.RSCODE == "S")
                            {
                                bReturn = true;

                                Thread.Sleep(Common.SLEEP_DELAY);
                                System.Windows.Forms.Application.DoEvents();        // 반복작업중 응답없음 안뜨게 하기
                                this.Cursor = Cursors.WaitCursor;   //Waitting
                            }
                            else if (helper.RSCODE == "E")
                            {
                                bReturn = false;
                                //helper.Rollback();
                                LogFile.WriteLog("라벨병합-SAP 확정문서 등록 오류 [" + helper.RSMSG.ToString());
                                throw new Exception("라벨병합-SAP 확정문서 등록 오류\r\n" + helper.RSMSG.ToString());
                            }
                        }
                        else
                        {
                            bReturn = false;
                            //helper.Rollback();
                            LogFile.WriteLog("라벨병합-SAP 전송 실패 [" + sapRFC_P.rtnMSG);
                            throw new Exception("라벨병합-SAP전송이 실패하였습니다.\r\n" + sapRFC_P.rtnMSG);
                        }
                    }
                    else
                    {
                        if (bReturn1)
                            bReturn = true;
                        else
                            bReturn = false;
                    }

                    // Zero실적 전송
                    if (!string.IsNullOrEmpty(sRS_PRFM_RFCFNZR) && bReturn)
                    {
                        if (dsTemp.Tables[12].Rows[0][0].ToString() != "1")
                        {
                            string sRfcData; //RFC결과 JSON 변환

                            //SAP 실적 등록
                            SAPHelper sapRFC_P = new SAPHelper();

                            // sapRFC.CallSAPFunc 호출시 helper를 사용하여 내용이 변경됨. 
                            // 필요한 정보는 sapRFC.CallSAPFunc 호출전에 처리해야함.
                            if (sapRFC_P.CallSAPFunc_HL(sRS_PRFM_RFCFNZR, dsTemp.Tables[12], dsTemp.Tables[13], helper).Equals("S"))
                            {
                                // ---- 전달시 MBLNR, MJAHR을 replace 처리하여 하나로 받도록함.
                                sRfcData = Common.toJsonFormat("PUT_WRKRTN", sapRFC_P.rtnTable).Replace("MBLNR", "RUECK").Replace("MJAHR", "RMZHL");

                                //실적등록 테이블에 확정문서 번호 갱신
                                helper.ExecuteNoneQuery("SP_IF_PUT_WRKRTN_HL", CommandType.StoredProcedure
                                                                    , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)       // 플랜트
                                                                    , helper.CreateParameter("P_WRK_TYPE", "0", DbType.String, ParameterDirection.Input)                 // '0'= 실적테이블_비계획생산, '1'= 폐품테이블, '2'=소요량, '3'=비가동
                                                                    , helper.CreateParameterOracle("P_RFC_DATA", sRfcData, OracleDbType.Clob, ParameterDirection.Input)
                                                                    , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input));
                                if (helper.RSCODE == "S")
                                {
                                    bReturn2 = true;

                                    Thread.Sleep(Common.SLEEP_DELAY);
                                    System.Windows.Forms.Application.DoEvents();        // 반복작업중 응답없음 안뜨게 하기
                                    this.Cursor = Cursors.WaitCursor;   //Waitting
                                }
                                else if (helper.RSCODE == "E")
                                {
                                    bReturn2 = false;
                                    //helper.Rollback();
                                    LogFile.WriteLog("Zero실적(1)-SAP 확정문서 등록 오류 [" + helper.RSMSG.ToString());
                                    throw new Exception("Zero실적(1)-SAP 확정문서 등록 오류\r\n" + helper.RSMSG.ToString());
                                }
                            }
                            else
                            {
                                bReturn2 = false;
                                //helper.Rollback();
                                LogFile.WriteLog("Zero실적(1)-SAP 전송 실패 [" + sapRFC_P.rtnMSG);
                                throw new Exception("Zero실적(1)-SAP전송이 실패하였습니다.\r\n" + sapRFC_P.rtnMSG);
                            }
                        }
                        else
                        {
                            bReturn2 = true;
                        }

                        if (dsTemp.Tables[14].Rows[0][0].ToString() != "1" && bReturn2)
                        {
                            string sRfcData; //RFC결과 JSON 변환

                            //SAP 실적 등록
                            SAPHelper sapRFC_P = new SAPHelper();

                            // sapRFC.CallSAPFunc 호출시 helper를 사용하여 내용이 변경됨. 
                            // 필요한 정보는 sapRFC.CallSAPFunc 호출전에 처리해야함.
                            if (sapRFC_P.CallSAPFunc_HL(sRS_PRFM_RFCFNZR, dsTemp.Tables[14], dsTemp.Tables[15], helper).Equals("S"))
                            {
                                // ---- 전달시 MBLNR, MJAHR을 replace 처리하여 하나로 받도록함.
                                sRfcData = Common.toJsonFormat("PUT_WRKRTN", sapRFC_P.rtnTable).Replace("MBLNR", "RUECK").Replace("MJAHR", "RMZHL");

                                //실적등록 테이블에 확정문서 번호 갱신
                                helper.ExecuteNoneQuery("SP_IF_PUT_WRKRTN_HL", CommandType.StoredProcedure
                                                                    , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)       // 플랜트
                                                                    , helper.CreateParameter("P_WRK_TYPE", "0", DbType.String, ParameterDirection.Input)                 // '0'= 실적테이블_비계획생산, '1'= 폐품테이블, '2'=소요량, '3'=비가동
                                                                    , helper.CreateParameterOracle("P_RFC_DATA", sRfcData, OracleDbType.Clob, ParameterDirection.Input)
                                                                    , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input));
                                if (helper.RSCODE == "S")
                                {
                                    bReturn2 = true;

                                    Thread.Sleep(Common.SLEEP_DELAY);
                                    System.Windows.Forms.Application.DoEvents();        // 반복작업중 응답없음 안뜨게 하기
                                    this.Cursor = Cursors.WaitCursor;   //Waitting
                                }
                                else if (helper.RSCODE == "E")
                                {
                                    bReturn2 = false;
                                    //helper.Rollback();
                                    LogFile.WriteLog("Zero실적(2)-SAP 확정문서 등록 오류 [" + helper.RSMSG.ToString());
                                    throw new Exception("Zero실적(2)-SAP 확정문서 등록 오류\r\n" + helper.RSMSG.ToString());
                                }
                            }
                            else
                            {
                                bReturn2 = false;
                                //helper.Rollback();
                                LogFile.WriteLog("Zero실적(2)-SAP 전송 실패 [" + sapRFC_P.rtnMSG);
                                throw new Exception("Zero실적(2)-SAP전송이 실패하였습니다.\r\n" + sapRFC_P.rtnMSG);
                            }
                        }
                        else
                        {
                            bReturn2 = true;
                        }

                        if (dsTemp.Tables[16].Rows[0][0].ToString() != "1" && bReturn2)
                        {
                            string sRfcData; //RFC결과 JSON 변환

                            //SAP 실적 등록
                            SAPHelper sapRFC_P = new SAPHelper();

                            // sapRFC.CallSAPFunc 호출시 helper를 사용하여 내용이 변경됨. 
                            // 필요한 정보는 sapRFC.CallSAPFunc 호출전에 처리해야함.
                            if (sapRFC_P.CallSAPFunc_HL(sRS_PRFM_RFCFNZR, dsTemp.Tables[16], dsTemp.Tables[17], helper).Equals("S"))
                            {
                                // ---- 전달시 MBLNR, MJAHR을 replace 처리하여 하나로 받도록함.
                                sRfcData = Common.toJsonFormat("PUT_WRKRTN", sapRFC_P.rtnTable).Replace("MBLNR", "RUECK").Replace("MJAHR", "RMZHL");

                                //실적등록 테이블에 확정문서 번호 갱신
                                helper.ExecuteNoneQuery("SP_IF_PUT_WRKRTN_HL", CommandType.StoredProcedure
                                                                    , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)       // 플랜트
                                                                    , helper.CreateParameter("P_WRK_TYPE", "0", DbType.String, ParameterDirection.Input)                 // '0'= 실적테이블_비계획생산, '1'= 폐품테이블, '2'=소요량, '3'=비가동
                                                                    , helper.CreateParameterOracle("P_RFC_DATA", sRfcData, OracleDbType.Clob, ParameterDirection.Input)
                                                                    , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input));
                                if (helper.RSCODE == "S")
                                {
                                    bReturn2 = true;

                                    Thread.Sleep(Common.SLEEP_DELAY);
                                    System.Windows.Forms.Application.DoEvents();        // 반복작업중 응답없음 안뜨게 하기
                                    this.Cursor = Cursors.WaitCursor;   //Waitting
                                }
                                else if (helper.RSCODE == "E")
                                {
                                    bReturn2 = false;
                                    //helper.Rollback();
                                    LogFile.WriteLog("Zero실적(3)-SAP 확정문서 등록 오류 [" + helper.RSMSG.ToString());
                                    throw new Exception("Zero실적(3)-SAP 확정문서 등록 오류\r\n" + helper.RSMSG.ToString());
                                }
                            }
                            else
                            {
                                bReturn2 = false;
                                //helper.Rollback();
                                LogFile.WriteLog("Zero실적(3)-SAP 전송 실패 [" + sapRFC_P.rtnMSG);
                                throw new Exception("Zero실적(3)-SAP전송이 실패하였습니다.\r\n" + sapRFC_P.rtnMSG);
                            }
                        }
                        else
                        {
                            bReturn2 = true;
                        }

                        if (dsTemp.Tables[18].Rows[0][0].ToString() != "1" && bReturn2)
                        {
                            string sRfcData; //RFC결과 JSON 변환

                            //SAP 실적 등록
                            SAPHelper sapRFC_P = new SAPHelper();

                            // sapRFC.CallSAPFunc 호출시 helper를 사용하여 내용이 변경됨. 
                            // 필요한 정보는 sapRFC.CallSAPFunc 호출전에 처리해야함.
                            if (sapRFC_P.CallSAPFunc_HL(sRS_PRFM_RFCFNZR, dsTemp.Tables[18], dsTemp.Tables[19], helper).Equals("S"))
                            {
                                // ---- 전달시 MBLNR, MJAHR을 replace 처리하여 하나로 받도록함.
                                sRfcData = Common.toJsonFormat("PUT_WRKRTN", sapRFC_P.rtnTable).Replace("MBLNR", "RUECK").Replace("MJAHR", "RMZHL");

                                //실적등록 테이블에 확정문서 번호 갱신
                                helper.ExecuteNoneQuery("SP_IF_PUT_WRKRTN_HL", CommandType.StoredProcedure
                                                                    , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)       // 플랜트
                                                                    , helper.CreateParameter("P_WRK_TYPE", "0", DbType.String, ParameterDirection.Input)                 // '0'= 실적테이블_비계획생산, '1'= 폐품테이블, '2'=소요량, '3'=비가동
                                                                    , helper.CreateParameterOracle("P_RFC_DATA", sRfcData, OracleDbType.Clob, ParameterDirection.Input)
                                                                    , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input));
                                if (helper.RSCODE == "S")
                                {
                                    bReturn2 = true;

                                    Thread.Sleep(Common.SLEEP_DELAY);
                                    System.Windows.Forms.Application.DoEvents();        // 반복작업중 응답없음 안뜨게 하기
                                    this.Cursor = Cursors.WaitCursor;   //Waitting
                                }
                                else if (helper.RSCODE == "E")
                                {
                                    bReturn2 = false;
                                    //helper.Rollback();
                                    LogFile.WriteLog("Zero실적(4)-SAP 확정문서 등록 오류 [" + helper.RSMSG.ToString());
                                    throw new Exception("Zero실적(4)-SAP 확정문서 등록 오류\r\n" + helper.RSMSG.ToString());
                                }
                            }
                            else
                            {
                                bReturn2 = false;
                                //helper.Rollback();
                                LogFile.WriteLog("Zero실적(4)-SAP 전송 실패 [" + sapRFC_P.rtnMSG);
                                throw new Exception("Zero실적(4)-SAP전송이 실패하였습니다.\r\n" + sapRFC_P.rtnMSG);
                            }
                        }
                    }

                    // 라벨병합만 성공하면 Commit 한다.
                    if (bReturn)
                    {
                        helper.Commit();

                        this.Cursor = Cursors.WaitCursor;
                        PrinterManager.PrintCutter(sRES_IND_BCD);
                        this.Cursor = Cursors.Default;   //Waitting

                        LogFile.WriteLog("라벨 병합 성공", LogType.PROC);
                        new POPUP.MessageForm("라벨 병합 성공\r\n" + helper.RSMSG, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    }
                    else
                    {
                        this.Cursor = Cursors.Default;   //Waitting
                        throw new Exception("bReturn False");
                    }
                }
                else
                {
                    this.Cursor = Cursors.Default;   //Waitting
                    LogFile.WriteLog("라벨병합 실패 [" + helper.RSMSG.ToString());
                    throw new Exception("라벨병합 실패\r\n" + helper.RSMSG.ToString());
                }
            }
            catch (Exception ex)
            {

                sResult = "ROLLBACK";
                RollbackLog(helper, dsTemp, tableGroup, ex.Message, sResult, false);
                ProdRollback_HL(helper, sapTemp, dsTemp);
                helper.Rollback();
                ProdRollback_HL_Prod(helper, sapTemp, dsTemp);
                helper.Commit();
                this.Cursor = Cursors.Default;   //Waitting
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                LogFile.WriteLog("SP_POP_WRK30_I05.doLabelMerge Error => " + ex.Message);
            }
            finally
            {
                helper.Close();
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
                            case "1.PROD_REG_SAP":
                                dsTemp = helper.FillDataSetN("SP_POP_WRK41_IFR02", CommandType.StoredProcedure, 2
                                       , helper.CreateParameter("P_DOC_NO", Rows["MDOCNO"].ToString(), DbType.String, ParameterDirection.Input)
                                       , helper.CreateParameter("P_DOC_SEQNO", Rows["MDOCSEQ"].ToString(), DbType.String, ParameterDirection.Input)
                                       , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input)
                                       , helper.CreateParameter("RS_RFCFN", DbType.String, ParameterDirection.Output, null, 30)
                                        );
                                string sRS_RFCFN_2 = helper.Parameters["RS_RFCFN"].Value.ToString();
                                SAPHelper sapRFC_2 = new SAPHelper();
                                if (sapRFC_2.CallSAPFunc_HL(sRS_RFCFN_2, dsTemp.Tables[0], dsTemp.Tables[1], helper).Equals("S"))
                                {
                                    if (helper.RSCODE == "S")
                                    {
                                        LogFile.WriteLog("병합실적등록 ROLLBACK [" + helper.RSMSG.ToString() + "]");
                                        sMSG_ERR = "병합실적등록 ROLLBACK [" + helper.RSMSG.ToString() + "]";

                                        sResult = "S";
                                    }
                                    else //if (helper.RSCODE == "E")
                                    {
                                        LogFile.WriteLog("병합실적등록 ROLLBACK 등록 - SAP 확정문서 등록 오류 [" + helper.RSMSG.ToString() + "]");
                                        sMSG_ERR = "ROLLBACK MES IF TABLE 등록 오류 : " + helper.RSMSG.ToString() + Environment.NewLine;
                                        sResult = "E";
                                    }
                                }
                                else
                                {
                                    LogFile.WriteLog("병합실적등록 ROLLBACK 오류 - SAP전송 오류 [" + sapRFC_2.rtnMSG + "]");
                                    sMSG_ERR = "병합실적등록 ROLLBACK 오류 : " + sapRFC_2.rtnMSG + Environment.NewLine;
                                    sResult = "E";
                                }
                                RollbackLog(helper, dsTemp, null, sMSG_ERR, sResult, true);
                                break;
                            default:
                                break;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                LogFile.WriteLog("병합실적등록 ROLLBACK 에러 Exception 발생 [" + ex.Message + "]");
            }
        }


        private void ProdRollback_HL_Prod(DBHelper helper, DataTable sapTemp, DataSet dsTemp)
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
                            case "2.CANCLE_REG_SAP":
                                dsTemp = helper.FillDataSetN("SP_POP_WRK41_IFR01", CommandType.StoredProcedure, 2
                                       , helper.CreateParameter("P_SDOC_NO", Rows["SDOC_NO"].ToString(), DbType.String, ParameterDirection.Input)
                                       , helper.CreateParameter("P_SDOC_SEQNO", Rows["SDOC_SEQNO"].ToString(), DbType.String, ParameterDirection.Input)
                                       , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input)
                                       , helper.CreateParameter("RS_RFCFN", DbType.String, ParameterDirection.Output, null, 30)
                                        );
                                string sRS_RFCFN_1 = helper.Parameters["RS_RFCFN"].Value.ToString();
                                SAPHelper sapRFC_1 = new SAPHelper();
                                if (sapRFC_1.CallSAPFunc_HL(sRS_RFCFN_1, dsTemp.Tables[0], dsTemp.Tables[1], helper).Equals("S"))
                                {
                                    string sRfcData; //RFC결과 JSON 변환
                                    // ---- 전달시 MBLNR, MJAHR을 replace 처리하여 하나로 받도록함.
                                    sRfcData = Common.toJsonFormat("PUT_WRKRTN", sapRFC_1.rtnTable).Replace("MBLNR", "RUECK").Replace("MJAHR", "RMZHL");

                                    //실적등록 테이블에 확정문서 번호 갱신
                                    helper.ExecuteNoneQuery("SP_IF_PUT_WRKRTN", CommandType.StoredProcedure
                                                                        , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)       // 플랜트
                                                                        , helper.CreateParameter("P_WRK_TYPE", "0", DbType.String, ParameterDirection.Input)                 // '0'= 실적테이블_비계획생산, '1'= 폐품테이블, '2'=소요량, '3'=비가동
                                                                        , helper.CreateParameterOracle("P_RFC_DATA", sRfcData, OracleDbType.Clob, ParameterDirection.Input)
                                                                        , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input));
                                    if (helper.RSCODE == "S")
                                    {
                                    }
                                    else if (helper.RSCODE == "E")
                                    {
                                        LogFile.WriteLog("실적취소 ROLLBACK 오류 - 확정문서 등록오류 [" + sapRFC_1.rtnMSG + "]");
                                        sMSG_ERR = "실적취소 ROLLBACK 확정문서 등록오류 : " + sapRFC_1.rtnMSG + Environment.NewLine;
                                    }
                                }
                                else
                                {
                                    LogFile.WriteLog("실적취소 ROLLBACK 오류 - SAP전송 오류 [" + sapRFC_1.rtnMSG + "]");
                                    sMSG_ERR = "실적취소 ROLLBACK 오류 : " + sapRFC_1.rtnMSG + Environment.NewLine;
                                    sResult = "E";
                                }
                                RollbackLog(helper, dsTemp, null, sMSG_ERR, sResult, true);
                                break;
                            default:
                                break;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                LogFile.WriteLog("폐품등록 ROLLBACK 에러 Exception 발생 [" + ex.Message + "]");
            }
        }


        private void RollbackLog(DBHelper helper, DataSet dsTemp, DataTable[] tableGroup, string sMSG_ERR, string sResult, bool sapRollbackLogFlag)
        {
            if (sapRollbackLogFlag)// sap 롤백에 대한 로그 저장
            {
                if (dsTemp.Tables.Count == 0) return;
                if (dsTemp.Tables[1] != null)
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
            else  // sap 롤백발생원인에 대한 저장
            {
                if (tableGroup.Length == 0) return;
                if (tableGroup[0] != null)
                {
                    if (tableGroup[0].Rows[0][0].ToString() != "1")
                    {
                        foreach (DataRow Rows in tableGroup[0].Rows) //실적등록 및 실적취소 실패시 롤백 발생원인 저장 - 실적등록 로그
                        {
                            helper.ExecuteNoneQuery("SP_HL_ROLLBACK_LOG", CommandType.StoredProcedure
                            , helper.CreateParameter("P_DOC_NO", tableGroup[0].Columns.Contains("MDOCNO") ? Rows["MDOCNO"] : "", DbType.String, ParameterDirection.Input)
                            , helper.CreateParameter("P_DOC_SEQNO", tableGroup[0].Columns.Contains("MDOCSEQ") ? Rows["MDOCSEQ"] : "", DbType.String, ParameterDirection.Input)
                            , helper.CreateParameter("P_LOT_NO", tableGroup[0].Columns.Contains("CRLOT") ? Rows["CRLOT"] : "", DbType.String, ParameterDirection.Input)
                            , helper.CreateParameter("P_ORDER_NO", tableGroup[0].Columns.Contains("AUFNR") ? Rows["AUFNR"] : "", DbType.String, ParameterDirection.Input)
                            , helper.CreateParameter("P_WERKS", tableGroup[0].Columns.Contains("WERKS") ? Rows["WERKS"] : "", DbType.String, ParameterDirection.Input)
                            , helper.CreateParameter("P_WORKCENTERCODE", tableGroup[0].Columns.Contains("WORKCENTERCODE") ? Rows["WORKCENTERCODE"] : "", DbType.String, ParameterDirection.Input)
                            , helper.CreateParameter("P_MACH_CD", tableGroup[0].Columns.Contains("MACHINE") ? Rows["MACHINE"] : "", DbType.String, ParameterDirection.Input)
                            , helper.CreateParameter("P_PRDCD", "", DbType.String, ParameterDirection.Input)
                            , helper.CreateParameter("P_QTY", tableGroup[0].Columns.Contains("PRDQTY") ? Rows["PRDQTY"] : "", DbType.String, ParameterDirection.Input)
                            , helper.CreateParameter("P_MATNR", tableGroup[0].Columns.Contains("MATNR") ? Rows["MATNR"] : "", DbType.String, ParameterDirection.Input)
                            , helper.CreateParameter("P_BUDAT", tableGroup[0].Columns.Contains("BUDAT") ? Rows["BUDAT"] : "", DbType.String, ParameterDirection.Input)
                            , helper.CreateParameter("P_RESULT", sResult, DbType.String, ParameterDirection.Input)
                            , helper.CreateParameter("P_REMARK", "MEINS : " + (tableGroup[0].Columns.Contains("MEINS") ? Rows["MEINS"].ToString() : "") + " "
                                                                 + "MRLOT : " + (tableGroup[0].Columns.Contains("MRLOT") ? Rows["MRLOT"].ToString() : "") + " "
                                                                 + sMSG_ERR, DbType.String, ParameterDirection.Input)
                            , helper.CreateParameter("P_MBLNR", tableGroup[0].Columns.Contains("SDOC_NO") ? Rows["SDOC_NO"] : "", DbType.String, ParameterDirection.Input)
                            , helper.CreateParameter("P_MJAHR", tableGroup[0].Columns.Contains("SDOC_SEQNO") ? Rows["SDOC_SEQNO"] : "", DbType.String, ParameterDirection.Input)
                            , helper.CreateParameter("P_I_IF_ID", dsTemp.Tables[0].Rows[0]["I_IF_ID"].ToString(), DbType.String, ParameterDirection.Input)
                            , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input));
                        }
                    }
                }
                if (tableGroup[1] != null)
                {
                    if (tableGroup[1].Rows[0][0].ToString() != "1")
                    {
                        foreach (DataRow Rows in tableGroup[1].Rows)//실적등록 및 실적취소 실패시 롤백 발생원인 저장 - 실적취소 로그
                        {
                            helper.ExecuteNoneQuery("SP_HL_ROLLBACK_LOG", CommandType.StoredProcedure
                            , helper.CreateParameter("P_DOC_NO", tableGroup[1].Columns.Contains("MDOCNO") ? Rows["MDOCNO"] : "", DbType.String, ParameterDirection.Input)
                            , helper.CreateParameter("P_DOC_SEQNO", tableGroup[1].Columns.Contains("MDOCSEQ") ? Rows["MDOCSEQ"] : "", DbType.String, ParameterDirection.Input)
                            , helper.CreateParameter("P_LOT_NO", tableGroup[1].Columns.Contains("LOTNO") ? Rows["LOTNO"] : "", DbType.String, ParameterDirection.Input)
                            , helper.CreateParameter("P_ORDER_NO", tableGroup[1].Columns.Contains("AUFNR") ? Rows["AUFNR"] : "", DbType.String, ParameterDirection.Input)
                            , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)
                            , helper.CreateParameter("P_WORKCENTERCODE", tableGroup[1].Columns.Contains("WORKCENTERCODE") ? Rows["WORKCENTERCODE"].ToString() : "", DbType.String, ParameterDirection.Input)
                            , helper.CreateParameter("P_MACH_CD", "", DbType.String, ParameterDirection.Input)
                            , helper.CreateParameter("P_PRDCD", "", DbType.String, ParameterDirection.Input)
                            , helper.CreateParameter("P_QTY", tableGroup[1].Columns.Contains("ROLLCNT") ? Rows["ROLLCNT"] : "", DbType.String, ParameterDirection.Input)
                            , helper.CreateParameter("P_MATNR", tableGroup[1].Columns.Contains("MATNR") ? Rows["MATNR"] : "", DbType.String, ParameterDirection.Input)
                            , helper.CreateParameter("P_BUDAT", tableGroup[1].Columns.Contains("BUDAT") ? Rows["BUDAT"] : "", DbType.String, ParameterDirection.Input)
                            , helper.CreateParameter("P_RESULT", sResult, DbType.String, ParameterDirection.Input)
                            , helper.CreateParameter("P_REMARK", "RUECK : " + (tableGroup[0].Columns.Contains("RUECK") ? Rows["RUECK"].ToString() : "") + " "
                                                                 + "RMZHL : " + (tableGroup[0].Columns.Contains("RMZHL") ? Rows["RMZHL"].ToString() : "") + " "
                                                                 + sMSG_ERR, DbType.String, ParameterDirection.Input)
                            , helper.CreateParameter("P_MBLNR", tableGroup[1].Columns.Contains("SDOC_NO") ? Rows["SDOC_NO"] : "", DbType.String, ParameterDirection.Input)
                            , helper.CreateParameter("P_MJAHR", tableGroup[1].Columns.Contains("SDOC_SEQNO") ? Rows["SDOC_SEQNO"] : "", DbType.String, ParameterDirection.Input)
                            , helper.CreateParameter("P_I_IF_ID", dsTemp.Tables[2].Rows[0]["I_IF_ID"].ToString(), DbType.String, ParameterDirection.Input)
                            , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input));
                        }
                    }
                }

            }



        }

        private void SaveRfcSuccesData(string sTempSAP_TYPE, string sTempIF_KEY, SAPHelper sapRFC, ref DataTable dsTempTable, ref DataTable sapTemp, string sSDOC_NO, string sSDOC_SEQNO)
        {
            if (dsTempTable.Rows.Count == 0) return;
            //rollback용
            //SAP 롤백용 추가 CODE 범위 START
            string sTempMDOC_NO = string.Empty;
            string sTempMDOC_SEQNO = string.Empty;

            string sSDOC_ColunmName = string.Empty;
            string sSDOCNO_ColunmName = string.Empty;
            if (sapRFC.rtnTable.Columns.Contains("MBLNR") && sapRFC.rtnTable.Columns.Contains("MJAHR"))
            {
                sSDOC_ColunmName = "MBLNR";
                sSDOCNO_ColunmName = "MJAHR";
            }
            else
            {
                sSDOC_ColunmName = "RUECK";
                sSDOCNO_ColunmName = "RMZHL";
            }

            if (!dsTempTable.Columns.Contains("SDOC_NO") && !dsTempTable.Columns.Contains("SDOC_SEQNO"))
            {
                dsTempTable.Columns.Add("SDOC_NO", typeof(string));
                dsTempTable.Columns.Add("SDOC_SEQNO", typeof(string));
            }


            // saptemp에 중복으로 또 담는 상황, 중복체크 추가

            sTempMDOC_NO = dsTempTable.Rows[0]["MDOCNO"].ToString();
            sTempMDOC_SEQNO = dsTempTable.Rows[0]["MDOCSEQ"].ToString();

            sapTemp.Rows.Add(sTempSAP_TYPE, sTempIF_KEY, sTempMDOC_NO, sTempMDOC_SEQNO, sSDOC_NO, sSDOC_SEQNO); // 후단 코드 실행시 EXCEPTION 상황 SAP CANCLE 정보 -- 실적등록
            //


            foreach (DataRow Rows in dsTempTable.Rows)
            {
                sTempMDOC_NO = Rows["MDOCNO"].ToString();
                sTempMDOC_SEQNO = Rows["MDOCSEQ"].ToString();


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

        }


        // 라벨 병합 취소
        private void doLabelUnMerge()
        {
            DBHelper helper = new DBHelper(false, "", true);
            DataTable dtList;
            DataSet dsTemp;     //실적등록 결과 수신(0:실적 RFC ID, 1:실적 IF 변수, 2:실적 RFC ID, 3:실적 IF 변수)
            bool bReturn = false, bReturn1 = false, bReturn2 = false; // 실적 처리 결과
            string sRES_IND_BCD = string.Empty;

            //1. A 라벨병합 생산실적 취소
            //2. Zero실적 삭제 전송 ( 완료 Flag를 해제를 위해..)
            //3. C 생산실적 등록 ( 병합에 사용된 바코드로 생산실적 처리 - 최대 5개)

            string sIND_BCD = "";

            try
            {
                dtList = setReqMergeList("C", out sIND_BCD); //병합취소 정보 확인

                if (dtList.Rows.Count > 1)
                {
                    new POPUP.MessageForm("라벨병합취소는 1개만 가능합니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return;
                }
                else if (dtList.Rows[0]["MER_YN"].ToString() != "Y")
                {
                    new POPUP.MessageForm("라벨병합된 바코드가 아닙니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return;
                }

                // 병합 처리 여부 확인
                if (new POPUP.MessageForm("선택된 바코드를 병합 취소 하시겠습니까?\r\n" + sIND_BCD, MessageBoxButtons.YesNo, "알   림").ShowDialog(this) == DialogResult.No)
                {
                    return;
                }


                this.Cursor = Cursors.WaitCursor;   //Waitting

                string sJsonData = Common.toJsonFormat("POP_WRK030", dtList);

                dsTemp = helper.FillDataSetN("SP_POP_WRK30_I06", CommandType.StoredProcedure, 20
                                                    , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)        // 플랜트코드
                                                    , helper.CreateParameterOracle("P_JSON_STR", sJsonData, OracleDbType.Clob, ParameterDirection.Input)  //
                                                    , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input)          // USER ID
                                                    , helper.CreateParameter("RS_PRFM_RFCFN_CN", DbType.String, ParameterDirection.Output, null, 200)     //병합실적 취소 RFCFN ID값
                                                    , helper.CreateParameter("RS_PRFM_RFCFN_ZR", DbType.String, ParameterDirection.Output, null, 200)     //병합실적 취소 RFCFN ID값
                                                    , helper.CreateParameter("RS_PRFM_RFCFN", DbType.String, ParameterDirection.Output, null, 200)        //병합전 실적 재등록 RFCFN ID값
                                                    , helper.CreateParameter("RS_MER_IND_BCD", DbType.String, ParameterDirection.Output, null, 1000)
                                                    );

                if (helper.RSCODE.Equals("S"))
                {
                    // 개별바코드 출력을 위해..
                    sRES_IND_BCD = helper.Parameters["RS_MER_IND_BCD"].Value.ToString();

                    string sRS_PRFM_RFCFN_CN = helper.Parameters["RS_PRFM_RFCFN_CN"].Value.ToString();   // 병합실적 취소 RFCFN ID
                    string sRS_PRFM_RFCFN_ZR = helper.Parameters["RS_PRFM_RFCFN_ZR"].Value.ToString();   // Zero실적 취소 RFCFN ID
                    string sRS_PRFM_RFCFN = helper.Parameters["RS_PRFM_RFCFN"].Value.ToString();         // 생산실적 재등록 RFCFN ID
#if false
                {
                    this.Cursor = Cursors.Default;   //Waitting

                    if (helper.RSCODE == "E")
                    {
                        new POPUP.MessageForm(helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    }
                    helper.Rollback();
                    return;
                }
#endif
                    // 1. 병합실적 취소
                    if (!string.IsNullOrEmpty(sRS_PRFM_RFCFN_CN))
                    {
                        //SAP 병합실적 취소
                        SAPHelper sapRFC_P = new SAPHelper();

                        // sapRFC.CallSAPFunc 호출시 helper를 사용하여 내용이 변경됨. 
                        // 필요한 정보는 sapRFC.CallSAPFunc 호출전에 처리해야함.
                        if (sapRFC_P.CallSAPFunc(sRS_PRFM_RFCFN_CN, dsTemp.Tables[0], dsTemp.Tables[1], helper).Equals("S"))
                        {
                            bReturn = true;
                        }
                        else
                        {
                            bReturn = false;
                            //helper.Rollback();
                            LogFile.WriteLog("라벨 병합 취소 SAP 전송 오류 [" + sapRFC_P.rtnMSG + "]");
                            new POPUP.MessageForm("라벨 병합 취소 SAP전송이 실패하였습니다.\r\n" + sapRFC_P.rtnMSG, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                        }
                    }
                    else
                    {
                        bReturn = true;
                    }

                    // 2. Zero실적 취소
                    if (!string.IsNullOrEmpty(sRS_PRFM_RFCFN_ZR) && bReturn)
                    {
                        if (dsTemp.Tables[2].Rows[0][0].ToString() != "1")
                        {
                            //SAP 병합실적 취소
                            SAPHelper sapRFC_P = new SAPHelper();

                            // sapRFC.CallSAPFunc 호출시 helper를 사용하여 내용이 변경됨. 
                            // 필요한 정보는 sapRFC.CallSAPFunc 호출전에 처리해야함.
                            if (sapRFC_P.CallSAPFunc(sRS_PRFM_RFCFN_ZR, dsTemp.Tables[2], dsTemp.Tables[3], helper).Equals("S"))
                            {
                                bReturn2 = true;
                            }
                            else
                            {
                                bReturn2 = false;
                                //helper.Rollback();
                                LogFile.WriteLog("ZERO실적 취소(1) SAP 전송 오류 [" + sapRFC_P.rtnMSG + "]");
                                new POPUP.MessageForm("ZERO실적 취소(1) SAP전송이 실패하였습니다.\r\n" + sapRFC_P.rtnMSG, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                            }
                        }
                        else
                        {
                            bReturn2 = true;
                        }

                        if (dsTemp.Tables[4].Rows[0][0].ToString() != "1" && bReturn2)
                        {
                            //SAP 병합실적 취소
                            SAPHelper sapRFC_P = new SAPHelper();

                            // sapRFC.CallSAPFunc 호출시 helper를 사용하여 내용이 변경됨. 
                            // 필요한 정보는 sapRFC.CallSAPFunc 호출전에 처리해야함.
                            if (sapRFC_P.CallSAPFunc(sRS_PRFM_RFCFN_ZR, dsTemp.Tables[4], dsTemp.Tables[5], helper).Equals("S"))
                            {
                                bReturn2 = true;
                            }
                            else
                            {
                                bReturn2 = false;
                                //helper.Rollback();
                                LogFile.WriteLog("ZERO실적 취소(2) SAP 전송 오류 [" + sapRFC_P.rtnMSG + "]");
                                new POPUP.MessageForm("ZERO실적 취소(2) SAP전송이 실패하였습니다.\r\n" + sapRFC_P.rtnMSG, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                            }
                        }
                        else
                        {
                            bReturn2 = true;
                        }

                        if (dsTemp.Tables[6].Rows[0][0].ToString() != "1" && bReturn2)
                        {
                            //SAP 병합실적 취소
                            SAPHelper sapRFC_P = new SAPHelper();

                            // sapRFC.CallSAPFunc 호출시 helper를 사용하여 내용이 변경됨. 
                            // 필요한 정보는 sapRFC.CallSAPFunc 호출전에 처리해야함.
                            if (sapRFC_P.CallSAPFunc(sRS_PRFM_RFCFN_ZR, dsTemp.Tables[6], dsTemp.Tables[7], helper).Equals("S"))
                            {
                                bReturn2 = true;
                            }
                            else
                            {
                                bReturn2 = false;
                                //helper.Rollback();
                                LogFile.WriteLog("ZERO실적 취소(3) SAP 전송 오류 [" + sapRFC_P.rtnMSG + "]");
                                new POPUP.MessageForm("ZERO실적 취소(3) SAP전송이 실패하였습니다.\r\n" + sapRFC_P.rtnMSG, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                            }
                        }
                        else
                        {
                            bReturn2 = true;
                        }

                        if (dsTemp.Tables[8].Rows[0][0].ToString() != "1" && bReturn2)
                        {
                            //SAP 병합실적 취소
                            SAPHelper sapRFC_P = new SAPHelper();

                            // sapRFC.CallSAPFunc 호출시 helper를 사용하여 내용이 변경됨. 
                            // 필요한 정보는 sapRFC.CallSAPFunc 호출전에 처리해야함.
                            if (sapRFC_P.CallSAPFunc(sRS_PRFM_RFCFN_ZR, dsTemp.Tables[8], dsTemp.Tables[9], helper).Equals("S"))
                            {
                                bReturn2 = true;
                            }
                            else
                            {
                                bReturn2 = false;
                                //helper.Rollback();
                                LogFile.WriteLog("ZERO실적 취소(4) SAP 전송 오류 [" + sapRFC_P.rtnMSG + "]");
                                new POPUP.MessageForm("ZERO실적 취소(4) SAP전송이 실패하였습니다.\r\n" + sapRFC_P.rtnMSG, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                            }
                        }
                        else
                        {
                            bReturn2 = true;
                        }
                    }

                    // 3. 생산실적 재등록
                    if (!string.IsNullOrEmpty(sRS_PRFM_RFCFN) && bReturn)
                    {
                        if (dsTemp.Tables[10].Rows[0][0].ToString() != "1")
                        {
                            string sRfcData; //RFC결과 JSON 변환

                            //SAP 실적 등록
                            SAPHelper sapRFC_P = new SAPHelper();

                            // sapRFC.CallSAPFunc 호출시 helper를 사용하여 내용이 변경됨. 
                            // 필요한 정보는 sapRFC.CallSAPFunc 호출전에 처리해야함.
                            if (sapRFC_P.CallSAPFunc(sRS_PRFM_RFCFN, dsTemp.Tables[10], dsTemp.Tables[11], helper).Equals("S"))
                            {
                                // ---- 전달시 MBLNR, MJAHR을 replace 처리하여 하나로 받도록함.
                                sRfcData = Common.toJsonFormat("PUT_WRKRTN", sapRFC_P.rtnTable).Replace("MBLNR", "RUECK").Replace("MJAHR", "RMZHL");

                                //실적등록 테이블에 확정문서 번호 갱신
                                helper.ExecuteNoneQuery("SP_IF_PUT_WRKRTN", CommandType.StoredProcedure
                                                                    , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)       // 플랜트
                                                                    , helper.CreateParameter("P_WRK_TYPE", "0", DbType.String, ParameterDirection.Input)                 // '0'= 실적테이블_비계획생산, '1'= 폐품테이블, '2'=소요량, '3'=비가동
                                                                    , helper.CreateParameterOracle("P_RFC_DATA", sRfcData, OracleDbType.Clob, ParameterDirection.Input)
                                                                    , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input));
                                if (helper.RSCODE == "S")
                                {
                                    bReturn1 = true;
                                }
                                else if (helper.RSCODE == "E")
                                {
                                    bReturn1 = false;
                                    //helper.Rollback();
                                    LogFile.WriteLog("라벨병합 실적 재등록(1)-SAP 확정문서 등록 오류 [" + helper.RSMSG.ToString());
                                    new POPUP.MessageForm("라벨병합 실적 재등록(1)-SAP 확정문서 등록 오류\r\n" + helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                }
                            }
                            else
                            {
                                bReturn1 = false;
                                //helper.Rollback();
                                LogFile.WriteLog("라벨병합 실적 재등록(1)-SAP 전송 실패 [" + sapRFC_P.rtnMSG);
                                new POPUP.MessageForm("라벨병합 실적 재등록(1)-SAP전송이 실패하였습니다.\r\n" + sapRFC_P.rtnMSG, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                            }
                        }
                        else
                        {
                            // 반드시 2개는 있어야 함.
                            bReturn1 = false;
                        }

                        if (dsTemp.Tables[12].Rows[0][0].ToString() != "1" && bReturn1)
                        {
                            string sRfcData; //RFC결과 JSON 변환

                            //SAP 실적 등록
                            SAPHelper sapRFC_P = new SAPHelper();

                            // sapRFC.CallSAPFunc 호출시 helper를 사용하여 내용이 변경됨. 
                            // 필요한 정보는 sapRFC.CallSAPFunc 호출전에 처리해야함.
                            if (sapRFC_P.CallSAPFunc(sRS_PRFM_RFCFN, dsTemp.Tables[12], dsTemp.Tables[13], helper).Equals("S"))
                            {
                                // ---- 전달시 MBLNR, MJAHR을 replace 처리하여 하나로 받도록함.
                                sRfcData = Common.toJsonFormat("PUT_WRKRTN", sapRFC_P.rtnTable).Replace("MBLNR", "RUECK").Replace("MJAHR", "RMZHL");

                                //실적등록 테이블에 확정문서 번호 갱신
                                helper.ExecuteNoneQuery("SP_IF_PUT_WRKRTN", CommandType.StoredProcedure
                                                                    , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)       // 플랜트
                                                                    , helper.CreateParameter("P_WRK_TYPE", "0", DbType.String, ParameterDirection.Input)                 // '0'= 실적테이블_비계획생산, '1'= 폐품테이블, '2'=소요량, '3'=비가동
                                                                    , helper.CreateParameterOracle("P_RFC_DATA", sRfcData, OracleDbType.Clob, ParameterDirection.Input)
                                                                    , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input));
                                if (helper.RSCODE == "S")
                                {
                                    bReturn1 = true;
                                }
                                else if (helper.RSCODE == "E")
                                {
                                    bReturn1 = false;
                                    //helper.Rollback();
                                    LogFile.WriteLog("라벨병합 실적 재등록(2)-SAP 확정문서 등록 오류 [" + helper.RSMSG.ToString());
                                    new POPUP.MessageForm("라벨병합 실적 재등록(2)-SAP 확정문서 등록 오류\r\n" + helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                }
                            }
                            else
                            {
                                bReturn1 = false;
                                //helper.Rollback();
                                LogFile.WriteLog("라벨병합 실적 재등록(2)-SAP 전송 실패 [" + sapRFC_P.rtnMSG);
                                new POPUP.MessageForm("라벨병합 실적 재등록(2)-SAP전송이 실패하였습니다.\r\n" + sapRFC_P.rtnMSG, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                            }
                        }
                        else
                        {
                            // 반드시 2개는 있어야 함.
                            bReturn1 = false;
                        }

                        if (dsTemp.Tables[14].Rows[0][0].ToString() != "1" && bReturn1)
                        {
                            string sRfcData; //RFC결과 JSON 변환

                            //SAP 실적 등록
                            SAPHelper sapRFC_P = new SAPHelper();

                            // sapRFC.CallSAPFunc 호출시 helper를 사용하여 내용이 변경됨. 
                            // 필요한 정보는 sapRFC.CallSAPFunc 호출전에 처리해야함.
                            if (sapRFC_P.CallSAPFunc(sRS_PRFM_RFCFN, dsTemp.Tables[14], dsTemp.Tables[15], helper).Equals("S"))
                            {
                                // ---- 전달시 MBLNR, MJAHR을 replace 처리하여 하나로 받도록함.
                                sRfcData = Common.toJsonFormat("PUT_WRKRTN", sapRFC_P.rtnTable).Replace("MBLNR", "RUECK").Replace("MJAHR", "RMZHL");

                                //실적등록 테이블에 확정문서 번호 갱신
                                helper.ExecuteNoneQuery("SP_IF_PUT_WRKRTN", CommandType.StoredProcedure
                                                                    , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)       // 플랜트
                                                                    , helper.CreateParameter("P_WRK_TYPE", "0", DbType.String, ParameterDirection.Input)                 // '0'= 실적테이블_비계획생산, '1'= 폐품테이블, '2'=소요량, '3'=비가동
                                                                    , helper.CreateParameterOracle("P_RFC_DATA", sRfcData, OracleDbType.Clob, ParameterDirection.Input)
                                                                    , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input));
                                if (helper.RSCODE == "S")
                                {
                                    bReturn1 = true;
                                }
                                else if (helper.RSCODE == "E")
                                {
                                    bReturn1 = false;
                                    //helper.Rollback();
                                    LogFile.WriteLog("라벨병합 실적 재등록(3)-SAP 확정문서 등록 오류 [" + helper.RSMSG.ToString());
                                    new POPUP.MessageForm("라벨병합 실적 재등록(3)-SAP 확정문서 등록 오류\r\n" + helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                }
                            }
                            else
                            {
                                bReturn1 = false;
                                //helper.Rollback();
                                LogFile.WriteLog("라벨병합 실적 재등록(3)-SAP 전송 실패 [" + sapRFC_P.rtnMSG);
                                new POPUP.MessageForm("라벨병합 실적 재등록(3)-SAP전송이 실패하였습니다.\r\n" + sapRFC_P.rtnMSG, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                            }
                        }
                        else
                        {
                            bReturn1 = true;
                        }

                        if (dsTemp.Tables[16].Rows[0][0].ToString() != "1" && bReturn1)
                        {
                            string sRfcData; //RFC결과 JSON 변환

                            //SAP 실적 등록
                            SAPHelper sapRFC_P = new SAPHelper();

                            // sapRFC.CallSAPFunc 호출시 helper를 사용하여 내용이 변경됨. 
                            // 필요한 정보는 sapRFC.CallSAPFunc 호출전에 처리해야함.
                            if (sapRFC_P.CallSAPFunc(sRS_PRFM_RFCFN, dsTemp.Tables[16], dsTemp.Tables[17], helper).Equals("S"))
                            {
                                // ---- 전달시 MBLNR, MJAHR을 replace 처리하여 하나로 받도록함.
                                sRfcData = Common.toJsonFormat("PUT_WRKRTN", sapRFC_P.rtnTable).Replace("MBLNR", "RUECK").Replace("MJAHR", "RMZHL");

                                //실적등록 테이블에 확정문서 번호 갱신
                                helper.ExecuteNoneQuery("SP_IF_PUT_WRKRTN", CommandType.StoredProcedure
                                                                    , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)       // 플랜트
                                                                    , helper.CreateParameter("P_WRK_TYPE", "0", DbType.String, ParameterDirection.Input)                 // '0'= 실적테이블_비계획생산, '1'= 폐품테이블, '2'=소요량, '3'=비가동
                                                                    , helper.CreateParameterOracle("P_RFC_DATA", sRfcData, OracleDbType.Clob, ParameterDirection.Input)
                                                                    , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input));
                                if (helper.RSCODE == "S")
                                {
                                    bReturn1 = true;
                                }
                                else if (helper.RSCODE == "E")
                                {
                                    bReturn1 = false;
                                    //helper.Rollback();
                                    LogFile.WriteLog("라벨병합 실적 재등록(4)-SAP 확정문서 등록 오류 [" + helper.RSMSG.ToString());
                                    new POPUP.MessageForm("라벨병합 실적 재등록(4)-SAP 확정문서 등록 오류\r\n" + helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                }
                            }
                            else
                            {
                                bReturn1 = false;
                                //helper.Rollback();
                                LogFile.WriteLog("라벨병합 실적 재등록(4)-SAP 전송 실패 [" + sapRFC_P.rtnMSG);
                                new POPUP.MessageForm("라벨병합 실적 재등록(4)-SAP전송이 실패하였습니다.\r\n" + sapRFC_P.rtnMSG, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                            }
                        }
                        else
                        {
                            bReturn1 = true;
                        }

                        if (dsTemp.Tables[18].Rows[0][0].ToString() != "1")
                        {
                            string sRfcData; //RFC결과 JSON 변환

                            //SAP 실적 등록
                            SAPHelper sapRFC_P = new SAPHelper();

                            // sapRFC.CallSAPFunc 호출시 helper를 사용하여 내용이 변경됨. 
                            // 필요한 정보는 sapRFC.CallSAPFunc 호출전에 처리해야함.
                            if (sapRFC_P.CallSAPFunc(sRS_PRFM_RFCFN, dsTemp.Tables[18], dsTemp.Tables[19], helper).Equals("S"))
                            {
                                // ---- 전달시 MBLNR, MJAHR을 replace 처리하여 하나로 받도록함.
                                sRfcData = Common.toJsonFormat("PUT_WRKRTN", sapRFC_P.rtnTable).Replace("MBLNR", "RUECK").Replace("MJAHR", "RMZHL");

                                //실적등록 테이블에 확정문서 번호 갱신
                                helper.ExecuteNoneQuery("SP_IF_PUT_WRKRTN", CommandType.StoredProcedure
                                                                    , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)       // 플랜트
                                                                    , helper.CreateParameter("P_WRK_TYPE", "0", DbType.String, ParameterDirection.Input)                 // '0'= 실적테이블_비계획생산, '1'= 폐품테이블, '2'=소요량, '3'=비가동
                                                                    , helper.CreateParameterOracle("P_RFC_DATA", sRfcData, OracleDbType.Clob, ParameterDirection.Input)
                                                                    , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input));
                                if (helper.RSCODE == "S")
                                {
                                    bReturn1 = true;
                                }
                                else if (helper.RSCODE == "E")
                                {
                                    bReturn1 = false;
                                    //helper.Rollback();
                                    LogFile.WriteLog("라벨병합 실적 재등록(5)-SAP 확정문서 등록 오류 [" + helper.RSMSG.ToString());
                                    new POPUP.MessageForm("라벨병합 실적 재등록(5)-SAP 확정문서 등록 오류\r\n" + helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                }
                            }
                            else
                            {
                                bReturn1 = false;
                                //helper.Rollback();
                                LogFile.WriteLog("라벨병합 실적 재등록(5)-SAP 전송 실패 [" + sapRFC_P.rtnMSG);
                                new POPUP.MessageForm("라벨병합 실적 재등록(5)-SAP전송이 실패하였습니다.\r\n" + sapRFC_P.rtnMSG, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                            }
                        }
                        else
                        {
                            bReturn1 = true;
                        }
                    }
                    else
                    {
                        if (bReturn)
                            bReturn1 = true;
                        else
                            bReturn1 = false;
                    }

                    if (bReturn && bReturn1)
                    {
                        helper.Commit();

                        this.Cursor = Cursors.WaitCursor;
                        PrinterManager.PrintCutter(sRES_IND_BCD);

                        this.Cursor = Cursors.Default;   //Waitting

                        LogFile.WriteLog("라벨 병합 취소 성공", LogType.PROC);
                        new POPUP.MessageForm("라벨 병합 취소 성공\r\n" + helper.RSMSG, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    }
                    else
                    {
                        this.Cursor = Cursors.Default;   //Waitting
                        helper.Rollback();
                        //LogFile.WriteLog("라벨 병합 취소 실패 [" + helper.RSMSG.ToString() + "]");
                        //new POPUP.MessageForm("라벨 병합 취소 실패1\r\n" + helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    }
                }
                else
                {
                    helper.Rollback();
                    LogFile.WriteLog("라벨 병합 취소 실패 [" + helper.RSMSG.ToString() + "]");
                    new POPUP.MessageForm("라벨 병합 취소 실패2\r\n" + helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);

                    return;
                }
            }
            catch (Exception ex)
            {
                helper.Rollback();
                LogFile.WriteLog("라벨병합 취소:SP_POP_WRK30_I06.doLabelUnMerge Error => " + ex.Message);
                new POPUP.MessageForm("라벨 병합 취소 오류\r\n" + ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
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
                        string sIND_BCD_GRP = "";   // 개별 바코드 묶음
                        //doPrint();

                        bool bRePrint = false;
                        int nPRFM_CNT = 0;

                        for (int i = 0; i < iCnt; i++)
                        {
                            // '00' 정상
                            if (dtReqList.Rows[i]["STA"].ToString().Equals("00"))
                            {
                                nPRFM_CNT++;
                            }
                        }

                        if (nPRFM_CNT > 0)
                        {
                            bRePrint = true;
                        }

                        if (bRePrint == false)
                        {
                            return;
                        }

                        this.Cursor = Cursors.WaitCursor;   //Waitting

                        for (int i = 0; i < iCnt; i++)
                        {
                            //PrinterManager.PrintMillRoll(dtReqList.Rows[i]["IND_BCD"].ToString());
                            if (dtReqList.Rows[i]["STA"].ToString().Equals("00"))
                            {
                                sIND_BCD_GRP += dtReqList.Rows[i]["IND_BCD"].ToString() + "|";
                            }
                        }

                        if (sIND_BCD_GRP.Length > 0)
                        {
                            PrinterManager.PrintCutter(sIND_BCD_GRP);
                        }

                        this.Cursor = Cursors.Default;   //원래대로

                        new POPUP.MessageForm("라벨 재발행 되었습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);

                        break;
                    case "Merge":  //라벨병합
                        if (iCnt > 1)
                        {
                            doLabelMerge();
                            SetGrid();
                        }
                        else
                        {
                            new POPUP.MessageForm("라벨 병합은 최소 두개 이상의 바코드를 선택하십시오.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                        }

                        break;
                    case "UnMerge":  //라벨병합취소
                        if (iCnt == 1)
                        {
                            // -----------------------------------------------
                            // 병합된 바코드가 아닙니다. 변압 바코드를 선택해 주세요.
                            doLabelUnMerge();
                            SetGrid();
                        }
                        else
                        {
                            new POPUP.MessageForm("라벨 병합 취소 대상은 한개만 선택하십시오.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                        }
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
                LogFile.WriteLog("POP_WRK31.bBox1_buttonClickEvent Error => " + ex.Message);
            }
            finally
            {

            }
        }

        private DataTable setReqList()
        {
            DataTable dtRtn = new DataTable();
            DataRow dtTempRow;
            DataTable dt = (DataTable)Grid1.DataSource;

            try
            {
                //테이블 양식 작성
                dtRtn.Columns.Add(new DataColumn("WRK_ORDR_NO", typeof(string)));       //작업지시
                dtRtn.Columns.Add(new DataColumn("WRK_ORDR_SEQNO", typeof(string)));    //작업지시 순번
                dtRtn.Columns.Add(new DataColumn("IND_BCD", typeof(string)));           //개별바코드
                dtRtn.Columns.Add(new DataColumn("LOT_NO", typeof(string)));            //LOT_NO
                dtRtn.Columns.Add(new DataColumn("RMK", typeof(string)));               //비고내용
                dtRtn.Columns.Add(new DataColumn("STA", typeof(string)));               //상태
                dtRtn.Columns.Add(new DataColumn("COMP_YN", typeof(string)));           //작업지시상태
                dtRtn.Columns.Add(new DataColumn("GB", typeof(string)));                //지시구분 (예외생산 구분을 위해 추가)

                for (int i = 0; i < dt.Rows.Count; i++)
                {
                    //선택된 행처리
                    if (dt.Rows[i]["CHK"].ToString().Equals("V"))
                    {
                        //조회결과 입력용 Row생성
                        dtTempRow = dtRtn.NewRow();
                        dtTempRow["WRK_ORDR_NO"] = dt.Rows[i]["WRK_ORDR_NO"].ToString();
                        dtTempRow["WRK_ORDR_SEQNO"] = dt.Rows[i]["WRK_ORDR_SEQNO"].ToString();
                        dtTempRow["IND_BCD"] = dt.Rows[i]["IND_BCD"].ToString();
                        dtTempRow["LOT_NO"] = dt.Rows[i]["LOT_NO"].ToString();
                        dtTempRow["RMK"] = dt.Rows[i]["RMK"].ToString();
                        //dtTempRow["STA"] = dt.Rows[i]["STA"].ToString();
                        if (dt.Columns.Contains("STA"))
                        {
                            dtTempRow["STA"] = dt.Rows[i]["STA"].ToString();
                        }
                        else
                        {
                            dtTempRow["STA"] = "";
                        }

                        if (dt.Columns.Contains("COMP_YN"))
                        {
                            dtTempRow["COMP_YN"] = dt.Rows[i]["COMP_YN"].ToString();
                        }
                        else
                        {
                            dtTempRow["COMP_YN"] = "";
                        }

                        // DataTable에 칼럼명이 있는지 확인
                        if (dt.Columns.Contains("GB"))
                        {
                            dtTempRow["GB"] = dt.Rows[i]["GB"].ToString();
                        }
                        else
                        {
                            dtTempRow["GB"] = "";
                        }
                        //결과 테이블에 저장
                        dtRtn.Rows.Add(dtTempRow);
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return dtRtn;
        }

        /// <summary>
        /// 라벨병합 및 취소 정보 묶음
        /// </summary>
        /// <param name="GUBUN"> M : 라벨병합, C: 병합취소</param>
        /// <returns></returns>
        private DataTable setReqMergeList(string GUBUN, out string rsIND_BCD)
        {
            DataTable dtRtn = new DataTable();
            DataRow dtTempRow;
            DataTable dt = (DataTable)Grid1.DataSource;
            string sVBELN = string.Empty;
            string sPOSNR = string.Empty;
            string sLOTNO = string.Empty;
            string sLOTSAMECHK = "Y";

            rsIND_BCD = "";

            try
            {
                //테이블 양식 작성
                dtRtn.Columns.Add(new DataColumn("IND_BCD", typeof(string))); //개별바코드
                dtRtn.Columns.Add(new DataColumn("MER_YN", typeof(string)));  //병합여부
                dtRtn.Columns.Add(new DataColumn("LOT_YN", typeof(string)));  //LOT동일 여부

                if (GUBUN == "M") //라벨병합에서 호출할 때
                {
                    for (int i = 0; i < dt.Rows.Count; i++)
                    {
                        if (dt.Rows[i]["CHK"].ToString().Equals("V"))
                        {
                            if (!string.IsNullOrEmpty(sLOTNO) && sLOTNO != dt.Rows[i]["LOT_NO"].ToString())
                            {
                                sLOTSAMECHK = "N";
                                break;
                            }

                            sLOTNO = dt.Rows[i]["LOT_NO"].ToString();
                        }
                    }
                }

                for (int i = 0; i < dt.Rows.Count; i++)
                {
                    //선택된 행처리
                    if (dt.Rows[i]["CHK"].ToString().Equals("V"))
                    {
                        if (GUBUN == "M") //라벨병합에서 호출할 때
                        {
                            if (!string.IsNullOrEmpty(sVBELN) && !string.IsNullOrEmpty(sPOSNR))
                            {
                                if (sVBELN != dt.Rows[i]["VBELN"].ToString() || sPOSNR != dt.Rows[i]["POSNR"].ToString())
                                    return null;
                            }
                            else
                            {
                                sVBELN = dt.Rows[i]["VBELN"].ToString();
                                sPOSNR = dt.Rows[i]["POSNR"].ToString();
                            }
                        }

                        //조회결과 입력용 Row생성
                        dtTempRow = dtRtn.NewRow();
                        dtTempRow["IND_BCD"] = dt.Rows[i]["IND_BCD"].ToString();
                        dtTempRow["MER_YN"] = dt.Rows[i]["MER_YN"].ToString();
                        dtTempRow["LOT_YN"] = sLOTSAMECHK;

                        rsIND_BCD += "\r\n" + dt.Rows[i]["IND_BCD"].ToString();
                        //결과 테이블에 저장
                        dtRtn.Rows.Add(dtTempRow);
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return dtRtn;
        }

        private DataTable setReqDeleteList()
        {
            DataTable dtRtn = new DataTable();
            DataRow dtTempRow;
            DataTable dt = (DataTable)Grid1.DataSource;

            try
            {
                //테이블 양식 작성
                dtRtn.Columns.Add(new DataColumn("IND_BCD", typeof(string))); //개별바코드

                for (int i = 0; i < dt.Rows.Count; i++)
                {
                    //선택된 행처리
                    if (dt.Rows[i]["CHK"].ToString().Equals("V"))
                    {
                        //조회결과 입력용 Row생성
                        dtTempRow = dtRtn.NewRow();
                        dtTempRow["IND_BCD"] = dt.Rows[i]["IND_BCD"].ToString();

                        //결과 테이블에 저장
                        dtRtn.Rows.Add(dtTempRow);
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
            //선택 버튼 클릭시 체크여부 변경
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

                e.row.Update();
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
            DAResultDate pop = new DAResultDate(cboFromDate.Value);
            pop.ShowDialog(this);
            if (pop.DialogResult == DialogResult.OK)
            {
                string strDate = pop.ResultString.ToString();
                cboFromDate.Value = DateTime.Parse(strDate);
            }
        }

        private void butMoveDate1_Click(object sender, EventArgs e)
        {
            DAResultDate pop = new DAResultDate(cboToDate.Value);
            pop.ShowDialog(this);
            if (pop.DialogResult == DialogResult.OK)
            {
                string strDate = pop.ResultString.ToString();
                cboToDate.Value = DateTime.Parse(strDate);
            }
        }

        private void cboWorkDate_ValueChanged(object sender, EventArgs e)
        {
            SetGrid();
        }

        private void cboToDate_ValueChanged(object sender, EventArgs e)
        {
            SetGrid();
        }
    }
}
