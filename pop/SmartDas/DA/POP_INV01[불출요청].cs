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
#endregion

namespace SmartDas
{
    public partial class POP_INV01 : BaseForm
    {
        #region < MEMBER AREA >

        private SAMMI.Common _common = new SAMMI.Common();

        private DataTable dtWrkOrderList;
        private DataTable dtUnitRate;
        int iSelectedRow = -1;

        #endregion

        #region < CONSTRUCTOR >

        public POP_INV01()
        {
            InitializeComponent();

            Common.SetMessageList();

        }

        public POP_INV01(DataTable pWrkOrderList)
        {
            InitializeComponent();

            Common.SetMessageList();

            dtWrkOrderList = pWrkOrderList;

        }
        #endregion

        #region < POP_INV01_Load >
        private void POP_INV01_Load(object sender, EventArgs e)
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

                this.lblTitle.Text = "자재 불출 요청";

                DateTime daysBefore = DateTime.Now;

                SetMenuButtons();
                SetGrid();
            }
            catch (Exception ex)
            {
                SetMessage("POP_INV01_Load_ Error!");
                LogFile.WriteLog("POP_INV01.POP_INV01_Load Error => " + ex.Message);
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

                bBox1[0, 0].Text = "자재불출\n요청";
                bBox1[0, 0].Tag = "Request";
                bBox1[0, 0].MappingButton.FontSize = 14;
                bBox1[0, 1].Text = "자재불출\n이력";
                bBox1[0, 1].Tag = "MoveLog";
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
                LogFile.WriteLog("POP_INV01.SetButtons Error => " + ex.Message);
            }
        }

        private void SetGrid()
        {
            DBHelper helper = new DBHelper();
            DataSet dsTemp = new DataSet();
            DataSet dsTemp1 = new DataSet();
            DataTable dtTemp1 = new DataTable();
            DataTable dtTemp2 = new DataTable();
            DataSet dsTemp2 = new DataSet();
            DataTable dtTemp3 = new DataTable();
            DataTable dtTemp4 = new DataTable();

            string sWrkList = string.Empty;

            try
            {
                //선택된 작업지시를 string
                for (int i = 0; i < dtWrkOrderList.Rows.Count; i++)
                {
                    if (i > 0)
                        sWrkList = sWrkList + ",";
                    sWrkList = sWrkList + dtWrkOrderList.Rows[i]["WRK_ORDR_NO"].ToString() + dtWrkOrderList.Rows[i]["WRK_ORDR_SEQNO"].ToString().PadLeft(5, '0');
                }
                //제품목록 설정
                Grid1.HeaderFontSize = 13;
                Grid1.FontSize = 13;
                Grid1.CountRows = 8;
                Grid1.AutoScroll = true;
                Grid1.DisplayLayout.Scrollbars = Scrollbars.Both;
                btnRightPage.LinkMoveSize = Grid1.CountRows;
                btnLeftPage.LinkMoveSize = Grid1.CountRows;
                //자재목록 설정
                Grid2.HeaderFontSize = 13;
                Grid2.FontSize = 13;
                Grid2.CountRows = 8;
                Grid2.AutoScroll = true;
                Grid2.DisplayLayout.Scrollbars = Scrollbars.Both;

                //버튼 목록 조회
                dsTemp = helper.FillDataSetN("SP_POP_INV01_S01", CommandType.StoredProcedure, 5
                                                               , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_PROC_CD", Common.OpCode, DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_WRK_LIST", sWrkList, DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input)
                                                               );
                //데이터 목록 작성
                //제품목록 Grid
                dtTemp1 = dsTemp.Tables[0].Copy();
                dtTemp2 = dsTemp.Tables[1].Copy();
                dsTemp1.Tables.Add(dtTemp1);
                dsTemp1.Tables.Add(dtTemp2);
                //자재목록 Grid
                dtTemp3 = dsTemp.Tables[2].Copy();
                dtTemp4 = dsTemp.Tables[3].Copy();
                dsTemp2.Tables.Add(dtTemp3);
                dsTemp2.Tables.Add(dtTemp4);
                //그리드 출력
                Grid1.DoFind_Oracle(dsTemp1);
                Grid2.DoFind_Oracle(dsTemp2);
                //단위정보 저장
                dtUnitRate = dsTemp.Tables[4].Copy();

                if (dsTemp.Tables[3].Rows.Count < 1)
                {
                    new POPUP.MessageForm("조회된 자재목록이 없습니다.\n생산오더 BOM을 확인하여 주시기 바랍니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                }

            }
            catch (Exception ex)
            {
                SetMessage("SetGrid Error!" + ex.Message);
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                LogFile.WriteLog("POP_INV01.SetGrid Error => " + ex.Message);
            }
        }

        private void doConfirm()
        {
            DataTable dtTemp;
            string sWrkList;
            DataTable dtRtnList;
            DataRow drTemp;
            string pURL; //restful 전송주소
            string rtnData; //전송결과 메세지
            string WrkOrderNo; //작업지시번호
            string WrkOrderSeqNo; //작업지시 순번
            string[] RestfulList; //불출요청 목록
            bool restfulFlag = true;
            string sRtnCode; //전송성공여부

            if (Grid2.Rows.Count < 1)
            {
                new POPUP.MessageForm("불출요청 자재 데이터가 없습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return;
            }

            try
            {
                this.Cursor = Cursors.WaitCursor;   //Waitting

                WrkOrderNo = dtWrkOrderList.Rows[0]["WRK_ORDR_NO"].ToString();
                WrkOrderSeqNo = dtWrkOrderList.Rows[0]["WRK_ORDR_SEQNO"].ToString();
                if (string.IsNullOrEmpty(WrkOrderNo))
                {
                    new POPUP.MessageForm("작업지시 정보를 확인하여 주시기 바랍니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return;
                }
                
                //기존 그리드 양식 복사
                dtRtnList = ((DataTable)Grid2.DataSource).Clone();
                drTemp = dtRtnList.NewRow();
                //선택 및 수량이 입력된 반납요청 목록 작성
                for (int i = 0; i < Grid2.Rows.Count; i++)
                {
                    //체크된 항목 확인(반납수량입력여부 추가확인)
                    if ( Grid2.Rows[i].Cells["CHK"].Value.ToString().Equals("V"))
                    {
                        // 각 컬럼별 데이터를 저장용 Row에 등록
                        for (int j = 0; j < dtRtnList.Columns.Count; j++)
                        {
                            drTemp[j] = Grid2.Rows[i].Cells[j].Value;
                        }
                        //저장용 Row를 테이블에 등록
                        dtRtnList.Rows.Add(drTemp.ItemArray);
                    }
                }
                
                int nRtnCnt = dtRtnList.Rows.Count;      // 불출요청 개수
                DataTable dtRtnOne = dtRtnList.Clone();

                for (int i = 0; i < nRtnCnt; i++)
                {
                    DBHelper helper = new DBHelper(false, "", true);
                    try
                    {
                        dtRtnOne.Rows.Clear();
                        dtRtnOne.ImportRow(dtRtnList.Rows[i]);

                        //자재목록 테이블 JSON으로 변환
                        sWrkList = Common.toJsonFormat("POP_INV01", dtRtnOne);

                        dtTemp = helper.FillTable("SP_POP_INV01_I01", CommandType.StoredProcedure
                                                                  , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)
                                                                  , helper.CreateParameter("P_PROC_CD", Common.OpCode, DbType.String, ParameterDirection.Input)
                                                                  , helper.CreateParameter("P_WRK_ORDR", WrkOrderNo, DbType.String, ParameterDirection.Input)
                                                                  , helper.CreateParameter("P_WRK_ORDR_SEQ", WrkOrderSeqNo, DbType.String, ParameterDirection.Input)
                                                                  , helper.CreateParameterOracle("P_WRK_LIST", sWrkList, OracleDbType.Clob, ParameterDirection.Input)
                                                                  , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input)
                                   );

                        if (helper.RSCODE == "E")
                        {
                            this.Cursor = Cursors.Default;   //Waitting
                            new POPUP.MessageForm(helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                            this.DialogResult = DialogResult.OK;
                            return;
                        }
                        else if (helper.RSCODE == "Q")
                        {
                            this.Cursor = Cursors.Default;   //Waitting
                            rtnData = helper.RSMSG.ToString().Replace(",", "\n") + "\n자재의 수량이 부족합니다.";
                            new POPUP.MessageForm(rtnData, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                            return;
                        }
                        else
                        {
                            //프로시저 성공시 변경사항 저장후 Restful 전송
                            helper.Commit();

                            restfulFlag = true;

                            RestfulList = Common.toJsonFormat_Array("list", dtTemp);
                            //restful 전송
                            pURL = Common.WMS_IF_URL.Replace("IFID", "WMS_IF_303");
                            for (int nx = 0; nx < RestfulList.Length; nx++)
                            {
                                try
                                {
                                    rtnData = Common.GetRestToString(pURL, RestfulList[nx], "POST");
                                }
                                catch (Exception EX_WMS)
                                {
                                    LogFile.WriteLog("POP_INV01.doConfirm::GetRestToString Error\r\n" + EX_WMS.Message);
                                    // Exception 내용 결과 저장 시 내용에서 ":", "'" 문자 제거
                                    rtnData = "{\"result\":\"" + EX_WMS.Message.Replace(":", "").Replace("'", "") + "\",\"IFID\":\"WMS_IF_303\"}";
                                }

                                sRtnCode = rtnData.Contains("SUCCESS") ? "S" : "E";
                                //결과저장
                                Common.GetRestSaveResult("MES_IF_201", RestfulList[nx], dtTemp.Rows[nx]["VBELN"].ToString(), "1", sRtnCode, rtnData).Equals("S");

                                if (rtnData.Contains("result"))
                                {
                                    if (!rtnData.Contains("SUCCESS"))
                                    {
                                        restfulFlag = false;
                                        break;
                                    }
                                }
                                else
                                {
                                    restfulFlag = false;
                                    break;
                                }
                            }
                        }

                        if (restfulFlag == false)
                        {
                            break;
                        }
                    }
                    catch (Exception ex)
                    {
                        this.Cursor = Cursors.Default;   //Waitting
                        helper.Rollback();
                        LogFile.WriteLog("POP_INV01.doConfirm Error => " + ex.Message);
                        new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                        return;
                    }
                    finally
                    {
                        this.Cursor = Cursors.Default;   //Waitting
                        helper.Close();
                    }
                }

                if (restfulFlag)
                {
                    this.Cursor = Cursors.Default;   //Waitting
                    new POPUP.MessageForm("불출 요청이 정상적으로 완료되었습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    this.DialogResult = DialogResult.OK;
                }
                else
                {
                    this.Cursor = Cursors.Default;   //Waitting
                    new POPUP.MessageForm("불출 요청이 실패하였습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                }
            }
            catch (Exception ex)
            {
                this.Cursor = Cursors.Default;   //Waitting
                LogFile.WriteLog("POP_INV01.doConfirm Error => " + ex.Message);
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
            }
            finally
            {
                this.Cursor = Cursors.Default;   //Waitting
            }
        }

        private void chgUnit(string pMATNR, string pReqQty)
        {
            DataRow[] drRateList;
            double dReqQty;
            string[] sUnitRate;
            int iMul;
            int iDiv;

            //요청수량을 숫자로 변환 실패시 종료
            if (!double.TryParse(pReqQty, out dReqQty))
                return;
            //지정된 품목의 단위목록 조회
            drRateList = dtUnitRate.Select("MATNR = '" + pMATNR + "'");
            //각 단위별 환산 후 출력
            if (drRateList.Length > 0)
            {
                if (!string.IsNullOrEmpty(drRateList[0]["PLT_RATE"].ToString()))
                {
                    //변환 단위 조회
                    sUnitRate = drRateList[0]["PLT_RATE"].ToString().Split(',');
                    int.TryParse(sUnitRate[0], out iMul);
                    int.TryParse(sUnitRate[1], out iDiv);
                    //변환수량 등록
                    lblPLT_QTY.Text = string.Format("{0:#,###}", (dReqQty * iMul / iDiv));
                }
                if (!string.IsNullOrEmpty(drRateList[0]["BOX_RATE"].ToString()))
                {
                    //변환 단위 조회
                    sUnitRate = drRateList[0]["BOX_RATE"].ToString().Split(',');
                    int.TryParse(sUnitRate[0], out iMul);
                    int.TryParse(sUnitRate[1], out iDiv);
                    //변환수량 등록
                    lblBOX_QTY.Text = string.Format("{0:#,###}", (dReqQty * iMul / iDiv));
                }
                if (!string.IsNullOrEmpty(drRateList[0]["BAG_RATE"].ToString()))
                {
                    //변환 단위 조회
                    sUnitRate = drRateList[0]["BAG_RATE"].ToString().Split(',');
                    int.TryParse(sUnitRate[0], out iMul);
                    int.TryParse(sUnitRate[1], out iDiv);
                    //변환수량 등록
                    lblBAG_QTY.Text = string.Format("{0:#,###}", (dReqQty * iMul / iDiv));
                }
                if (!string.IsNullOrEmpty(drRateList[0]["EA_RATE"].ToString()))
                {
                    //변환 단위 조회
                    sUnitRate = drRateList[0]["EA_RATE"].ToString().Split(',');
                    int.TryParse(sUnitRate[0], out iMul);
                    int.TryParse(sUnitRate[1], out iDiv);
                    //변환수량 등록
                    lblEA_QTY.Text = string.Format("{0:#,###}", (dReqQty * iMul / iDiv));
                }
                if (!string.IsNullOrEmpty(drRateList[0]["RL_RATE"].ToString()))
                {
                    //변환 단위 조회
                    sUnitRate = drRateList[0]["RL_RATE"].ToString().Split(',');
                    int.TryParse(sUnitRate[0], out iMul);
                    int.TryParse(sUnitRate[1], out iDiv);
                    //변환수량 등록
                    lblROLL_QTY.Text = string.Format("{0:#,###}", (dReqQty * iMul / iDiv));
                }
                if (!string.IsNullOrEmpty(drRateList[0]["M_RATE"].ToString()))
                {
                    //변환 단위 조회
                    sUnitRate = drRateList[0]["M_RATE"].ToString().Split(',');
                    int.TryParse(sUnitRate[0], out iMul);
                    int.TryParse(sUnitRate[1], out iDiv);
                    //변환수량 등록
                    lblLENGTH.Text = string.Format("{0:#,###}", (dReqQty * iMul / iDiv));
                }
                if (!string.IsNullOrEmpty(drRateList[0]["KG_RATE"].ToString()))
                {
                    //변환 단위 조회
                    sUnitRate = drRateList[0]["KG_RATE"].ToString().Split(',');
                    int.TryParse(sUnitRate[0], out iMul);
                    int.TryParse(sUnitRate[1], out iDiv);
                    //변환수량 등록
                    lblWGT.Text = string.Format("{0:#,###}", (dReqQty * iMul / iDiv));
                }
            }
        }

        private void showUnit(int RowIndex)
        {
            string sMATNR;
            string sREQQTY;

            //선택된 행 저장
            iSelectedRow = RowIndex;
            sMATNR = Grid2.Rows[iSelectedRow].Cells["MATNR"].Value.ToString();
            sREQQTY = Grid2.Rows[iSelectedRow].Cells["REQ_QTY"].Value.ToString();
            //요청 출력
            lblREQ_QTY.Text = sREQQTY;
            //단위 환산
            chgUnit(sMATNR, sREQQTY);
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
                    case "Request":  //자재불출요청
                        doConfirm();
                        break;
                    case "MoveLog":  //자재이동이력
                        POP_INV03 INV03 = new POP_INV03();
                        ShowDialogForm(INV03);
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
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                LogFile.WriteLog("POP_INV01.bBox1_buttonClickEvent Error => " + ex.Message);
            }
            finally
            {

            }
        }

        private void Grid2_GridClick(object sender, MESGrid.GridClickEventArg e)
        {
            if (Grid2.Rows.Count < 1)
            {
                return;
            }

            if (Grid2.Row == null)
            {
                return;
            }

            showUnit(e.row.Index);
        }

        private void Grid2_ClickCellButton(object sender, MESGrid.GridClickEventArg e)
        {
            double dSTCKQty;
            double dUseQty;

            if (e.column.ToString() == "CHK")
            {
                string sStatus_Pre = e.row.Cells["CHK"].Value.ToString();

                if (sStatus_Pre == "V")
                {
                    e.row.Cells["CHK"].Value = "-";
                }
                else
                {
                    //수량확인
                    double.TryParse(Grid2.Rows[e.row.Index].Cells["STCK_QTY"].Value.ToString(), out dSTCKQty);
                    double.TryParse(Grid2.Rows[e.row.Index].Cells["WRK_ORDR_QTY"].Value.ToString(), out dUseQty);
                    if (dUseQty <= dSTCKQty)
                    {
                        if (new POPUP.MessageForm("현재 보유량이 충분합니다.\n추가로 요청하시겠습니까?", MessageBoxButtons.YesNo, "알   림").ShowDialog(this) == System.Windows.Forms.DialogResult.No)
                            return;
                    }

                    e.row.Cells["CHK"].Value = "V";
                    //체크로 변경시 단위정보 출력
                    showUnit(e.row.Index);
                }
            }
        }

        private void lblREQ_QTY_Click(object sender, EventArgs e)
        {
            string sMATNR;
            double dREQQTY;
            double dDimension = 0;

            if (iSelectedRow < 0)
            {
                new POPUP.MessageForm("자재를 선택하여 주시기 바랍니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
            }
            else
            {
                DAResultNum pop = new DAResultNum();
                pop.LabelTitle = "요청수량 변경";
                pop.LabelHeader = "요청수량";
                pop.ContentMaxLength = 8;

                pop.ShowDialog(this);

                if (pop.DialogResult == DialogResult.OK)
                {
                    dDimension = pop.ResultDouble;
                    lblREQ_QTY.Text = dDimension.ToString();
                }

                //선택된 자재정보 조회
                sMATNR = Grid2.Rows[iSelectedRow].Cells["MATNR"].Value.ToString();
                //입력된 값이 숫자인경우 변경된 수량으로 단위 재출력
                if (double.TryParse(lblREQ_QTY.Text, out dREQQTY))
                {
                    chgUnit(sMATNR, dREQQTY.ToString());
                }
            }
        }

        private void lblUNIT_QTY_Click(object sender, EventArgs e)
        {
            MESLabel selLabel = (MESLabel)sender;
            DataRow[] drRateList;
            string sMatnr;
            string sUnit;
            string[] sUnitRate;
            int iMul;
            int iDiv;
            double dBefQty; //변경전 수량
            int iUpperQty; //올림처리 수량
            int iAtfQty; //변경후 수량

            //선택여부 확인
            if (iSelectedRow < 0)
            {
                new POPUP.MessageForm("자재를 선택하여 주시기 바랍니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return;
            }
            //자재정보 확인
            sMatnr = Grid2.Rows[iSelectedRow].Cells["MATNR"].Value.ToString();

            //단위 정보 확인
            if (string.IsNullOrEmpty(selLabel.Tag.ToString()))
                return;
            else
                sUnit = selLabel.Tag.ToString();

            //지정된 품목의 단위정보 조회
            drRateList = dtUnitRate.Select("MATNR = '" + sMatnr + "'");
            sUnitRate = drRateList[0][selLabel.Tag.ToString() + "_RATE"].ToString().Split(',');
            int.TryParse(sUnitRate[0], out iDiv);
            int.TryParse(sUnitRate[1], out iMul);
            //단위 정보 확인
            if (iMul <= 0 || iDiv <= 0)
                return;
            //선택된 단위의 수량을 정수로 올림처리
            if (double.TryParse(selLabel.Text, out dBefQty))
            {
                iUpperQty = (int)Math.Ceiling(dBefQty);

                iAtfQty = iUpperQty * iMul / iDiv;

                lblREQ_QTY.Text = string.Format("{0:#,###}", iAtfQty);

                chgUnit(sMatnr, lblREQ_QTY.Text);
            }
            else
                return;
        }

        private void btnSave_Click(object sender, EventArgs e)
        {
            double dREQQTY;
            double dWMSQty;
            //선택된 행이 존재하는 경우
            if (iSelectedRow >= 0)
            {
                //입력된 값이 숫자인 경우
                if (double.TryParse(lblREQ_QTY.Text, out dREQQTY))
                {
                    //수량 비교
                    double.TryParse(Grid2.Rows[iSelectedRow].Cells["WMS_QTY"].Value.ToString(), out dWMSQty);
                    if (dWMSQty < dREQQTY)
                    {
                        new POPUP.MessageForm("WMS의 재고수량이 부족합니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                        return;
                    }
                    //요청수량 등록
                    Grid2.Rows[iSelectedRow].Cells["REQ_QTY"].Value = string.Format("{0:#,##0.###}", dREQQTY);
                }
            }
        }

        #endregion


    }
}
