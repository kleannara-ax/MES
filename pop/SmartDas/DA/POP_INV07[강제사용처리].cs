#region [ USING AREA ]
using System;
using System.Configuration;
using System.Data;
using System.Threading;
using System.Windows.Forms;
using Infragistics.Win.UltraWinGrid;
using Oracle.ManagedDataAccess.Client;
using SAMMI;
using SmartDas.Components;
using SmartDas.POPUP;

#endregion

namespace SmartDas
{
    public partial class POP_INV07 : BaseForm
    {
        #region < MEMBER AREA >

        private SAMMI.Common _common = new SAMMI.Common();

        #endregion

        #region < CONSTRUCTOR >

        public POP_INV07()
        {
            InitializeComponent();

            Common.SetMessageList();
        }

        #endregion

        #region < POP_INV07_Load >
        private void POP_INV07_Load(object sender, EventArgs e)
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

                this.lblTitle.Text = "예외생산완료 잔량미처리 내역";

                DateTime daysBefore = DateTime.Now;
                dtpPRD_STR_DATE.Value = daysBefore;

                SetMenuButtons();
                SetGrid();
            }
            catch (Exception ex)
            {
                SetMessage("POP_INV07_Load_ Error!");
                LogFile.WriteLog("POP_INV07.POP_INV07_Load Error => " + ex.Message);
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

                bBox1[0, 0].Text = "사용처리";
                bBox1[0, 0].Tag = "USE";
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
                LogFile.WriteLog("POP_INV07.SetButtons Error => " + ex.Message);
            }
        }

        private void SetGrid()
        {
            DBHelper helper = new DBHelper();
            DataSet dsTemp = new DataSet();
            string sStartDate = string.Empty;
            string sEndDate = string.Empty;

            try
            {
                sStartDate = dtpPRD_STR_DATE.Value.ToString("yyyyMMdd");
                sEndDate = dtpPRD_END_DATE.Value.ToString("yyyyMMdd");

                Grid1.HeaderFontSize = 13;
                Grid1.FontSize = 13;
                Grid1.CountRows = 10;
                Grid1.AutoScroll = true;
                Grid1.DisplayLayout.Scrollbars = Scrollbars.Both;
                btnRightPage.LinkMoveSize = Grid1.CountRows;
                btnLeftPage.LinkMoveSize = Grid1.CountRows;

                dsTemp = helper.FillDataSetN("SP_POP_INV07_FORCE_USE", CommandType.StoredProcedure, 4
                                                               , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_MATNR", "", DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_PRD_STR_DT", sStartDate, DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_PRD_END_DT", sEndDate, DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_WRK_ORDR_NO", txtWRKORDNO.Text, DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_WRK_ORDR_SEQNO", txtWRKORDNO.Text, DbType.String, ParameterDirection.Input)
                                                               //, helper.CreateParameter("P_DISPO_QTY", "", DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_TYPE", "LIST", DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("RS_SINPUT_RFCFN", DbType.String, ParameterDirection.Output, null, 200)                //영업폐품 RFCFN ID값
                                                               );
                //그리드 출력
                Grid1.DoFind_Oracle(dsTemp);

                // 첫번째열 고정
                Grid1.DisplayLayout.UseFixedHeaders = true;
                Grid1.DisplayLayout.Bands[0].Columns["CHK"].Header.Fixed = true;
                Grid1.DisplayLayout.Bands[0].Override.FixedHeaderIndicator = FixedHeaderIndicator.None;
            }
            catch (Exception ex)
            {
                SetMessage("SetGrid Error!" + ex.Message);
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                LogFile.WriteLog("POP_INV07.SetGrid Error => " + ex.Message);
            }
        }

        #endregion

        #region < EVNET >

        private void bBox1_buttonClickEvent(MESButton sender, ButtonBox.ButtonClickEventArg e)
        {
            DBHelper helper = new DBHelper();
            DataTable dtReqList;

            try
            {
                if (!this.bUseNetwork)
                {
                    SetMessage("네트워크 상태를 확인하시기 바랍니다.");
                    return;
                }

                MESButton btn = sender;

                //체크된 항목 확인
                dtReqList = setReqList();

                string[] sWrkOrdr = txtWRKORDNO.Text.Split('-');

                switch (btn.Tag.ToString())
                {
                    case "USE":   //사용처리
                        if (doUse(dtReqList))
                        {
                            SetGrid();
                        }
                        break;
                    case "Close":   //이전화면
                        this.Close();
                        break;
                }
            }
            catch (OracleException oe)
            {
                SetMessage(oe.Message);
                new POPUP.MessageForm(oe.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
            }

            catch (Exception ex)
            {
                SetMessage(ex.Message);
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                LogFile.WriteLog("POP_INV07.bBox1_buttonClickEvent Error => " + ex.Message);
            }
            finally
            {
                this.Cursor = Cursors.Default;   //Default
                helper.Close();
            }
        }

        private bool doUse(DataTable dtReqList)
        {
            DBHelper helper = new DBHelper("", true);
            DataSet dsTemp = new DataSet();
            string sMSG_ERR = "";
            bool useReturn = false;

            string sStartDate = dtpPRD_STR_DATE.Value.ToString("yyyyMMdd");
            string sEndDate = dtpPRD_END_DATE.Value.ToString("yyyyMMdd");

            try
            {
                foreach (DataRow dr in dtReqList.Rows)
                {
                    string targetWrkOrderNo = dr["WRK_ORDR_NO"].ToString();

                    dsTemp = helper.FillDataSetN("SP_POP_INV07_FORCE_USE", CommandType.StoredProcedure, 4
                                       , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)
                                       , helper.CreateParameter("P_MATNR", dr["MATNR"].ToString(), DbType.String, ParameterDirection.Input)
                                       , helper.CreateParameter("P_MACH_CD", dr["MACH_CD"].ToString(), DbType.String, ParameterDirection.Input)
                                       , helper.CreateParameter("P_PRD_STR_DT", sStartDate, DbType.String, ParameterDirection.Input)
                                       , helper.CreateParameter("P_PRD_END_DT", sEndDate, DbType.String, ParameterDirection.Input)
                                       , helper.CreateParameter("P_WRK_ORDR_NO", dr["WRK_ORDR_NO"].ToString(), DbType.String, ParameterDirection.Input)
                                       , helper.CreateParameter("P_WRK_ORDR_SEQ", dr["WRK_ORDR_SEQ"].ToString(), DbType.String, ParameterDirection.Input)
                                       //, helper.CreateParameter("P_DISPO_QTY", dr["STCK_QTY"].ToString(), DbType.String, ParameterDirection.Input)
                                       , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input)
                                       , helper.CreateParameter("P_TYPE", "FORCE_USE", DbType.String, ParameterDirection.Input)
                                       , helper.CreateParameter("RS_SINPUT_RFCFN", DbType.String, ParameterDirection.Output, null, 200)                //영업폐품 RFCFN ID값
                                       );

                    //check : 필요유무
                    //SAP 롤백용 추가 CODE 범위 START
                    DataTable sapTemp = new DataTable(); // 성공한 sap 정보 저장
                    sapTemp.Columns.Add("SAP_TYPE", typeof(string));
                    sapTemp.Columns.Add("IF_KEY", typeof(string));
                    sapTemp.Columns.Add("MDOCNO", typeof(string));
                    sapTemp.Columns.Add("MDOCSEQ", typeof(string));


                    if (helper.RSCODE == "S")
                    {
                        string sRS_SINPUT_RFCFN = helper.Parameters["RS_SINPUT_RFCFN"].Value.ToString();    // 투입(사용) RFCFN ID

                        string sRfcData; //RFC결과 JSON 변환

                        if (string.IsNullOrEmpty(sRS_SINPUT_RFCFN) == false)
                        {
                            // 투입(사용) 등록
                            if (string.IsNullOrEmpty(sRS_SINPUT_RFCFN) == false)
                            {
                                // 문서번호, 문서순번으로  테이블 SORT 하여 전달
                                DataTable dtRFCData = new DataTable();
                                DataView dvPFRM = new DataView(dsTemp.Tables[3]);
                                dvPFRM.Sort = "MDOCNO, MDOCSEQ ASC";
                                dtRFCData = dvPFRM.ToTable();

                                SAPHelper sapRFC_D = new SAPHelper();
                                // sapRFC.CallSAPFunc 호출시 helper를 사용하여 내용이 변경됨. 
                                // 필요한 정보는 sapRFC.CallSAPFunc 호출전에 처리해야함.
                                if (sapRFC_D.CallSAPFunc(sRS_SINPUT_RFCFN, dsTemp.Tables[2], dtRFCData, helper).Equals("S"))
                                {
                                    //RFC 전송 결과 조회
                                    string sType = sapRFC_D.rtnTable.Rows[0]["TYPE"].ToString();
                                    string sMessage = sapRFC_D.rtnTable.Rows[0]["MESSAGE"].ToString();

                                    if (sType == "S")
                                    {
                                        // ---- 전달시 MBLNR, MJAHR을 replace 처리하여 하나로 받도록함.
                                        sRfcData = Common.toJsonFormat("PUT_WRKRTN", sapRFC_D.rtnTable).Replace("MBLNR", "RUECK").Replace("MJAHR", "RMZHL");

                                        //SAP 롤백용 추가 CODE 범위 START
                                        string sTempSAP_TYPE = string.Empty;
                                        string sTempIF_KEY = string.Empty;
                                        string sTempMDOC_NO = string.Empty;
                                        string sTempMDOC_SEQNO = string.Empty;

                                        sTempSAP_TYPE = "1.SALE_SALV_REG_SAP";
                                        sTempIF_KEY = dsTemp.Tables[2].Rows[0]["I_IF_KEY"].ToString();
                                        foreach (DataRow Rows in dsTemp.Tables[3].Rows)
                                        {
                                            sTempMDOC_NO = Rows["MDOCNO"].ToString();
                                            sTempMDOC_SEQNO = Rows["MDOCSEQ"].ToString();
                                            sapTemp.Rows.Add(sTempSAP_TYPE, sTempIF_KEY, sTempMDOC_NO, sTempMDOC_SEQNO); // 후단 코드 실행시 EXCEPTION 상황 SAP CANCLE 정보 -- 실적등록
                                        }
                                        //SAP 롤백용 추가 CODE 범위 END

                                        //실적등록 테이블에 확정문서 번호 갱신
                                        helper.ExecuteNoneQuery("SP_IF_PUT_WRKRTN", CommandType.StoredProcedure
                                                                            , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)        // 플랜트
                                                                            , helper.CreateParameter("P_WRK_TYPE", "2", DbType.String, ParameterDirection.Input)                  // '2'=소요량
                                                                            , helper.CreateParameterOracle("P_RFC_DATA", sRfcData, OracleDbType.Clob, ParameterDirection.Input)
                                                                            , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input));

                                        if (helper.RSCODE == "S")
                                        {
                                            helper.Commit();
                                            useReturn = true;
                                            LogFile.WriteLog("사용처리 성공", LogType.PROC);
                                            new POPUP.MessageForm("[" + targetWrkOrderNo + "] 작업지시 잔량 사용처리 완료 되었습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                        }
                                        else if (helper.RSCODE == "E")
                                        {
                                            sMSG_ERR += "확정문서 등록(투입(사용)) 오류 : " + helper.RSMSG.ToString() + Environment.NewLine;
                                            throw new Exception("SAP_ERROR" + sMSG_ERR);
                                        }
                                    }
                                    else
                                    {
                                        sMSG_ERR += "실적 등록(투입(사용)) 오류 : " + sapRFC_D.rtnMSG + Environment.NewLine;
                                        throw new Exception("SAP_ERROR" + sMSG_ERR);
                                    }
                                }
                                else
                                {
                                    sMSG_ERR += "실적 등록(투입(사용)) 오류 : " + sapRFC_D.rtnMSG + Environment.NewLine;
                                    throw new Exception("SAP_ERROR" + sMSG_ERR);

                                }

                                Thread.Sleep(Common.SLEEP_DELAY);
                                System.Windows.Forms.Application.DoEvents();        // 반복작업중 응답없음 안뜨게 하기
                                this.Cursor = Cursors.WaitCursor;   //Waitting
                            }
                        }
                    }
                    else
                    {
                        useReturn = false;
                        this.Cursor = Cursors.Default;   //Waitting
                        helper.Rollback();
                        new POPUP.MessageForm("사용처리 실패하였습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                        LogFile.WriteLog("POP_INV07.bBox1_buttonClickEvent Error => 사용처리 실패(프로시저)");
                    }
                }
            }
            catch (Exception ex)
            {
                useReturn = false;
                this.Cursor = Cursors.Default;   //Waitting
                helper.Rollback();
                new POPUP.MessageForm("사용처리 실패하였습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                LogFile.WriteLog("POP_INV07.bBox1_buttonClickEvent Error => 사용처리 실패");
            }
            finally
            {
                this.Cursor = Cursors.Default;   //Default
                helper.Close();
            }
            return useReturn;
        }

        private void cboOrderDate_ValueChanged(object sender, EventArgs e)
        {
            SetGrid();

        }

        private void cboOrderDateE_ValueChanged(object sender, EventArgs e)
        {
            SetGrid();
        }

        private void btnFind_Click(object sender, EventArgs e)
        {
            SetGrid();
        }

        private void dtpDate_DropDown(object sender, EventArgs e)
        {
            CommonCalendar.CloseCalendar((DateTimePicker)sender);
        }

        private void butWorkDate_Click(object sender, EventArgs e)
        {
            Button btnTemp = (Button)sender;

            DateTime dt = DateTime.Today;
            if ((btnTemp.Tag.ToString() == "startDate"))        
                dt = dtpPRD_STR_DATE.Value;
            else if ((btnTemp.Tag.ToString() == "endDate"))
                dt = dtpPRD_END_DATE.Value;

            DAResultDate pop = new DAResultDate(dt);
            pop.ShowDialog(this);
            if (pop.DialogResult == DialogResult.OK)
            {
                string sDate = pop.ResultString.ToString();
                if((btnTemp.Tag.ToString() == "startDate"))
                    dtpPRD_STR_DATE.Value = DateTime.Parse(sDate);
                else if ((btnTemp.Tag.ToString() == "endDate"))
                    dtpPRD_END_DATE.Value = DateTime.Parse(sDate);
            }
        }

        #endregion

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
        }
        private DataTable setReqList()
        {
            DataTable dtRtn = new DataTable();
            DataRow dtTempRow;
            DataTable dt = (DataTable)Grid1.DataSource;

            try
            {
                //테이블 양식 작성
                dtRtn.Columns.Add(new DataColumn("WRK_ORDR_NO", typeof(string)));       //작업지시 번호
                dtRtn.Columns.Add(new DataColumn("WRK_ORDR_SEQ", typeof(string)));      //작업지시 SEQ
                dtRtn.Columns.Add(new DataColumn("STCK_QTY", typeof(string)));          //잔량 
                dtRtn.Columns.Add(new DataColumn("MATNR", typeof(string)));             //자재코드
                dtRtn.Columns.Add(new DataColumn("MACH_CD", typeof(string)));           //설비호기

                if(dt != null)
                {
                    for (int i = 0; i < dt.Rows.Count; i++)
                    {
                        //선택된 행처리
                        if (dt.Rows[i]["CHK"].ToString().Equals("V"))
                        {
                            //조회결과 입력용 Row생성
                            dtTempRow = dtRtn.NewRow();
                            string[] orderArray = (dt.Rows[i]["WRK_ORDR_NO"].ToString()).Split('-');
                            dtTempRow["WRK_ORDR_NO"] = orderArray[0];
                            //dtTempRow["WRK_ORDR_SEQ"] = orderArray[1];
                            dtTempRow["WRK_ORDR_SEQ"] = dt.Rows[i]["WRK_ORDR_SEQNO"].ToString();
                            dtTempRow["STCK_QTY"] = dt.Rows[i]["SUM_STCK_QTY"].ToString();
                            dtTempRow["MATNR"] = dt.Rows[i]["MATNR"].ToString();
                            dtTempRow["MACH_CD"] = dt.Rows[i]["MACH_CD"].ToString();


                            //결과 테이블에 저장
                            dtRtn.Rows.Add(dtTempRow);
                        }
                    }
                }
                
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return dtRtn;
        }
    }
}
