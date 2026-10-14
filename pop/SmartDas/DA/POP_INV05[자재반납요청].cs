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
    public partial class POP_INV05 : BaseForm
    {
        #region < MEMBER AREA >
        private SAMMI.Common _common = new SAMMI.Common();

        string sMenuType = string.Empty;

        #endregion

        #region < CONSTRUCTOR >

        public POP_INV05()
        {
            InitializeComponent();

            Common.SetMessageList();
        }

        public POP_INV05(string MenuType)
        {
            InitializeComponent();

            Common.SetMessageList();

            sMenuType = MenuType;
        }
        #endregion

        #region < POP_INV05_Load >
        private void POP_INV05_Load(object sender, EventArgs e)
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

                this.lblTitle.Text = "자재 반납 요청";

                if (Common.MachineCode.Contains("TRA"))
                {
                    lblMATNR.Visible = true;
                    btnMATNR.Visible = true;
                    txtMATNR.Visible = false;
                }
                else
                {
                    lblMATNR.Visible = false;
                    btnMATNR.Visible = false;
                    txtMATNR.Visible = true;
                }

                SetMenuButtons();
                //SetGrid();
            }
            catch (Exception ex)
            {
                SetMessage("POP_INV05_Load_ Error!");
                LogFile.WriteLog("POP_INV05.POP_INV05_Load Error => " + ex.Message);
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

                bBox1[0, 0].Text = "라벨\n재발행";
                bBox1[0, 0].Tag = "Print";
                bBox1[0, 0].MappingButton.FontSize = 14;
                bBox1[0, 1].Text = "자재반납\n요청";
                bBox1[0, 1].Tag = "Return";
                bBox1[0, 1].MappingButton.FontSize = 14;
                bBox1[0, 2].Text = "자재반납\n이력";
                bBox1[0, 2].Tag = "ReturnLog";
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
                LogFile.WriteLog("POP_INV05.SetButtons Error => " + ex.Message);
            }
        }
        private void SetGrid()
        {
            DBHelper helper = new DBHelper();
            DataSet dsTemp = new DataSet();
            string sLocCD = string.Empty;
            string sMatnr = string.Empty;
            string sIndBcd = string.Empty;

            try
            {
                Grid1.HeaderFontSize = 13;
                Grid1.FontSize = 13;
                Grid1.CountRows = 10;
                Grid1.AutoScroll = true;
                Grid1.DisplayLayout.Scrollbars = Scrollbars.Both;
                btnRightPage.LinkMoveSize = Grid1.CountRows;
                btnLeftPage.LinkMoveSize = Grid1.CountRows;

                sLocCD = lblSTOR_LOC.Tag == null ? string.Empty : lblSTOR_LOC.Tag.ToString();
                if (Common.MachineCode.Contains("TRA"))
                {
                    sMatnr = lblMATNR.Tag == null ? string.Empty : lblMATNR.Tag.ToString();
                } 
                else
                {
                    sMatnr = txtMATNR.Text == null ? string.Empty : txtMATNR.Text.ToString();
                }
                
                sIndBcd = txtINDBCD.Text == null ? string.Empty : txtINDBCD.Text.ToString();

                if ("".Equals(sLocCD))
                {
                    new POPUP.MessageForm("저장위치를 선택해주세요.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return;
                }
                
                if ("".Equals(sMatnr) && "".Equals(sIndBcd))
                {
                    new POPUP.MessageForm("자재코드나 개별바코드중 한가지이상 입력해주세요.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return;
                }

                dsTemp = helper.FillDataSetN("SP_POP_INV05_S01", CommandType.StoredProcedure, 2
                                                               , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_STOR_LOC", sLocCD, DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_MATNR", sMatnr, DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_WRK_ORDR_NO", Common.WrkOrderNo, DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_IND_BCD", sIndBcd, DbType.String, ParameterDirection.Input)
                                                               );
                //그리드 출력
                Grid1.DoFind_Oracle(dsTemp);
            }
            catch (Exception ex)
            {
                SetMessage("SetGrid Error!" + ex.Message);
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                LogFile.WriteLog("POP_INV05.SetGrid Error => " + ex.Message);
            }
        }

        private void doConfirm()
        {
            DataTable dtTemp;
            string sWrkList;
            DataTable dtRtnList;
            DataRow drTemp;
            bool bErrChk = true;
            string pURL; //restful 전송주소
            string rtnData; //전송결과 메세지
            double dStckQty; //재고수량
            double dRtnQty; //반납요청수량
            string[] RestfulList; //불출요청 목록
            bool restfulFlag = true;
            string sRtnCode; //전송성공여부

            if (Grid1.Rows.Count < 1)
            {
                SetMessage("반납요청 데이터가 없습니다.");
                new POPUP.MessageForm("반납요청 데이터가 없습니다.\n반납을 진행할 자재를 선택하여 주시기 바랍니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return;
            }

            try
            {
                //기존 그리드 양식 복사
                dtRtnList = ((DataTable)Grid1.DataSource).Clone();
                drTemp = dtRtnList.NewRow();
                //선택 및 수량이 입력된 반납요청 목록 작성
                for (int i = 0; i < Grid1.Rows.Count; i++)
                {
                    //체크된 항목 확인(반납수량입력여부 추가확인)
                    if (Grid1.Rows[i].Cells["CHK"].Value.ToString().Equals("V")
                        && !(string.IsNullOrEmpty(Grid1.Rows[i].Cells["RTN_QTY"].Value.ToString())
                            || Grid1.Rows[i].Cells["RTN_QTY"].Value.ToString().Equals("0")))
                    {
                        //재고수량 체크
                        double.TryParse(Grid1.Rows[i].Cells["STCK_QTY"].Value.ToString(), out dStckQty);
                        double.TryParse(Grid1.Rows[i].Cells["RTN_QTY"].Value.ToString(), out dRtnQty);
                        if (dStckQty < dRtnQty)
                        {
                            new POPUP.MessageForm("재고 수량이 부족합니다.\n반납 요청수량을 변경하여 주시기 바랍니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                            return;
                        }
                        // 각 컬럼별 데이터를 저장용 Row에 등록
                        for (int j = 0; j < dtRtnList.Columns.Count; j++)
                        {
                            drTemp[j] = Grid1.Rows[i].Cells[j].Value;
                        }
                        //저장용 Row를 테이블에 등록
                        dtRtnList.Rows.Add(drTemp.ItemArray);
                        //dtRtnList.ImportRow(drTemp);
                        bErrChk = false;
                    }
                }
                //선택된 데이터가 없는 경우 메세지 출력
                if (bErrChk)
                {
                    new POPUP.MessageForm("반납요청 항목을 확인하여 주시기 바랍니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                }
                else
                {
                    this.Cursor = Cursors.WaitCursor;   //Waitting

                    int nRtnCnt = dtRtnList.Rows.Count;      // 자재반납 개수
                    DataTable dtRtnOne = dtRtnList.Clone();

                    for (int i = 0; i < nRtnCnt; i++)
                    {
                        DBHelper helper = new DBHelper(false, "", true);

                        try
                        {
                            dtRtnOne.Rows.Clear();
                            dtRtnOne.ImportRow(dtRtnList.Rows[i]);

                            //자재목록 테이블 JSON으로 변환
                            sWrkList = Common.toJsonFormat("POP_INV05", dtRtnOne);

                            dtTemp = helper.FillTable("SP_POP_INV05_I01", CommandType.StoredProcedure
                                                                      , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)
                                                                      , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)
                                                                      , helper.CreateParameter("P_PROC_CD", Common.OpCode, DbType.String, ParameterDirection.Input)
                                                                      , helper.CreateParameterOracle("P_WRK_LIST", sWrkList, OracleDbType.Clob, ParameterDirection.Input)
                                                                      , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input)
                                       );

                            if (helper.RSCODE == "E")
                            {
                                this.Cursor = Cursors.Default;   //Waitting
                                new POPUP.MessageForm(helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                return;
                            }
                            else
                            {
                                //프로시저 성공시 변경사항 저장
                                helper.Commit();

                                restfulFlag = true;
                                RestfulList = Common.toJsonFormat_Array("list", dtTemp);

                                //restful 전송
                                pURL = Common.WMS_IF_URL.Replace("IFID", "WMS_IF_207");

                                for (int nx = 0; nx < RestfulList.Length; nx++)
                                {
                                    try
                                    {
                                        rtnData = Common.GetRestToString(pURL, RestfulList[nx], "POST");
                                    }
                                    catch (Exception EX_WMS)
                                    {
                                        LogFile.WriteLog("POP_INV05.doConfirm::GetRestToString Error\r\n" + EX_WMS.Message);
                                        // Exception 내용 결과 저장 시 내용에서 ":", "'" 문자 제거
                                        rtnData = "{\"result\":\"" + EX_WMS.Message.Replace(":", "").Replace("'", "") + "\",\"IFID\":\"WMS_IF_207\"}";
                                    }

                                    sRtnCode = rtnData.Contains("SUCCESS") ? "S" : "E";
                                    //결과저장 : sRtnCode가 "E"인경우 롤백처리하여 인터페이스 로그 저장 안함
                                    Common.GetRestSaveResult("MES_IF_400", RestfulList[nx], dtTemp.Rows[nx]["EBELN"].ToString(), "1", sRtnCode, rtnData).Equals("S");

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

                                if (restfulFlag == false)
                                {
                                    break;
                                }
                            }
                        }
                        catch (Exception ex)
                        {
                            this.Cursor = Cursors.Default;   //Waitting

                            helper.Rollback();

                            LogFile.WriteLog("POP_INV05.doConfirm Error => " + ex.Message);
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
                        new POPUP.MessageForm("반납 요청이 정상적으로 완료되었습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                        this.DialogResult = DialogResult.OK;
                    }
                    else
                    {
                        this.Cursor = Cursors.Default;   //Waitting
                        new POPUP.MessageForm("반납 요청이 실패하였습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    }
                }
            }
            catch (Exception ex)
            {
                this.Cursor = Cursors.Default;   //Waitting
                
                LogFile.WriteLog("POP_INV05.doConfirm Error => " + ex.Message);
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
            }
            finally
            {
                this.Cursor = Cursors.Default;   //Waitting
            }
        }

        private void doPrint(int iSelRow)
        {
            string PrinterName = SAMMI.IniFile.GetValue("KLEANNARA", "PRINTER", null); 
            string PrinterDPI = SAMMI.IniFile.GetValue("KLEANNARA", "PRINTERDPI", null);
            bool bPrint = false;
            string sZPL = string.Empty;

            string sPRD_DT = string.Empty;
            string sPRFM_QTY = string.Empty;
            string sMATNR = string.Empty;
            string sMATNR_NM = string.Empty;
            string sKAN_CD = string.Empty;
            string sUNIT = string.Empty;
            string sLOT_NO = string.Empty;
            //바코드
            string sINDBCD = string.Empty;
            //합지라벨용
            string sBS_WGT = string.Empty;
            string sMACH_NM = string.Empty;
            string sCOLOR = string.Empty;
            string sWRK_NAME = string.Empty;
            string sQCJUD = string.Empty;

            sPRFM_QTY = Grid1.Rows[iSelRow].Cells["RTN_QTY"].Value.ToString();
            sMATNR = Grid1.Rows[iSelRow].Cells["MATNR"].Value.ToString();
            sMATNR_NM = Grid1.Rows[iSelRow].Cells["MATNR_NM"].Value.ToString();
            sUNIT = Grid1.Rows[iSelRow].Cells["UNIT"].Value.ToString();
            sLOT_NO = Grid1.Rows[iSelRow].Cells["LOT_NO"].Value.ToString();
            //바코드
            sINDBCD = Grid1.Rows[iSelRow].Cells["IND_BCD"].Value.ToString();

            //합지롤의 경우 B5로 출력
            if (Common.PlantCode == "P200" && Grid1.Rows[iSelRow].Cells["MATNR_DIV"].Value.ToString().Equals("HALB"))
            {
                //합지라벨용
                sBS_WGT = Grid1.Rows[iSelRow].Cells["BS_WGT"].Value.ToString();
                sMACH_NM = Grid1.Rows[iSelRow].Cells["MACH_NM"].Value.ToString();
                sCOLOR = Grid1.Rows[iSelRow].Cells["COLOR"].Value.ToString();
                sWRK_NAME = Grid1.Rows[iSelRow].Cells["WRK_NAME"].Value.ToString();
                sQCJUD = Grid1.Rows[iSelRow].Cells["QCJUD"].Value.ToString();

                REPORT_ITEM HLitem = new REPORT_ITEM();

                HLitem.MACH_NM = sMACH_NM;          // 설비호기 명
                HLitem.LOT_NO = sLOT_NO;            // LOT NO
                HLitem.SPEC = sMATNR_NM;            // 제품규격(품명)
                HLitem.PRFM_ROLLCNT = string.Empty; // 길이
                HLitem.BS_WGT = sBS_WGT;            // 평량
                HLitem.PRFM_WGT = sPRFM_QTY;        // 중량
                HLitem.COLOR = sCOLOR;              // 색
                HLitem.WRK_NAME = sWRK_NAME;        // 작업자
                HLitem.QCJUD = sQCJUD;              // 판정
                HLitem.IND_BCD = sINDBCD;           // 바코드

                string pstrERR = "";

                REPORT rp = new REPORT();
                rp.EXCEL_OPEN(Common.PlantCode);
                rp.AA_PRINT(HLitem, ref pstrERR);
                if (pstrERR.Length > 0)
                    bPrint = false;
                else
                    bPrint = true;
                rp.EXCEL_CLOSE();
            }
            else
            {
                if (PrinterName.Contains("ZDesigner"))
                {
                    DBHelper helper = new DBHelper(false);
                    try
                    {
                        if (Grid1.Rows.Count == 0)
                        {
                            new POPUP.MessageForm("조회된 자재 정보가 없습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                            return;
                        }

                        //ZPL코드 프로시저 호출
                        helper.ExecuteNoneQuery("SP_INV_ZPL_RM", CommandType.StoredProcedure
                         , helper.CreateParameter("P_TYPE", "M" + PrinterDPI, DbType.String, ParameterDirection.Input) //라벨종류
                         , helper.CreateParameter("P_PRD_DT", sPRD_DT, DbType.String, ParameterDirection.Input) //생산일자
                         , helper.CreateParameter("P_MATNR", sMATNR, DbType.String, ParameterDirection.Input) //품목코드
                         , helper.CreateParameter("P_MATNR_NM", sMATNR_NM, DbType.String, ParameterDirection.Input) //품목명
                         , helper.CreateParameter("P_UNIT", sUNIT, DbType.String, ParameterDirection.Input) //기준단위
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
                                bPrint = true;
                                break;
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                        LogFile.WriteLog("POP_INV05.doPrint Error => " + ex.Message);
                        bPrint = false;
                    }
                    finally
                    {
                        helper.Close();
                    }
                }
                else
                {
                    #region A4출력
                    //조회결과 입력용 Row생성
                    REPORT_ITEM RMitem = new REPORT_ITEM();

                    RMitem.POCUST = string.Empty;           // 납품업체
                    RMitem.POCUST_NM = string.Empty;        // 납품업체명
                    RMitem.PO_NO = string.Empty;            // PO번호
                    RMitem.QCREQ_NO = string.Empty;         // 검수요청번호
                    RMitem.QCREQ_DT = string.Empty;         // 검수요청일
                    RMitem.MATNR = sMATNR;                  // ERP 제품코드
                    RMitem.MATNR_NM = sMATNR_NM;            // 제품명
                    RMitem.QCREQ_QTY = sPRFM_QTY;           // 검수요청수량
                    RMitem.UNIT = sUNIT;                    // 입고단위
                    RMitem.QCPAL_QTY = string.Empty;        // 검수 Pallet수
                    RMitem.QCREQ_QTY = sPRFM_QTY;           // Pallet 적치수량
                    RMitem.PRD_DATE = string.Empty;         // 생산일자 
                    RMitem.LOT_NO = sLOT_NO;                // LOT번호
                    RMitem.IND_BCD = sINDBCD;               // 개별바코드

                    string pstrERR = "";

                    REPORT rp = new REPORT();
                    rp.EXCEL_OPEN(Common.PlantCode);
                    rp.RM_PRINT(RMitem, ref pstrERR);
                    if (pstrERR.Length > 0)
                        bPrint = false;
                    else
                        bPrint = true;

                    rp.EXCEL_CLOSE();

                    #endregion
                }
            }
            if (bPrint)
                new POPUP.MessageForm("라벨이 출력되었습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
            else
                new POPUP.MessageForm("라벨출력을 실패하였습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
        }

        #endregion

        #region < EVNET >

        private void bBox1_buttonClickEvent(MESButton sender, ButtonBox.ButtonClickEventArg e)
        {
            try
            {

                //if (!this.bUseNetwork)
                //{
                //    SetMessage("네트워크 상태를 확인하시기 바랍니다.");
                //    return;
                //}

                MESButton btn = sender;

                switch (btn.Tag.ToString())
                {
                    case "Print": //라벨재발행
                        for (int i = 0; i < Grid1.Rows.Count; i++)
                            if (Grid1.Rows[i].Cells["CHK"].Value.ToString().Equals("V"))
                                doPrint(i);
                        break;
                    case "Return": //자재반납요청
                        doConfirm();
                        break;
                    case "ReturnLog": //자재반납이력
                        POP_INV06 INV06 = new POP_INV06();
                        ShowDialogForm(INV06);
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
                LogFile.WriteLog("POP_INV05.bBox1_buttonClickEvent Error => " + ex.Message);
            }
            finally
            {

            }
        }

        private void btnFind_Click(object sender, EventArgs e)
        {
            SetGrid();
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
            }
            else if (e.column.ToString() == "RTN_QTY")
            {
                double dStckQty; //재고수량
                double dRtnQty; //반납요청수량
                double dDimension = 0;

                DAResultNum pop = new DAResultNum();
                pop.LabelTitle = "반납수량 변경";
                pop.LabelHeader = "반납수량";
                pop.ContentMaxLength = 8;

                pop.ShowDialog(this);

                if (pop.DialogResult == DialogResult.OK)
                {
                    dDimension = pop.ResultDouble;
                    e.row.Cells["RTN_QTY"].Value = dDimension.ToString();
                    Grid1.Update();

                    double.TryParse(Grid1.Rows[e.row.Index].Cells["STCK_QTY"].Value.ToString(), out dStckQty);
                    double.TryParse(Grid1.Rows[e.row.Index].Cells["RTN_QTY"].Value.ToString(), out dRtnQty);
                    if (dStckQty < dRtnQty)
                    {
                        new POPUP.MessageForm("재고 수량이 부족합니다.\n반납 요청수량을 변경하여 주시기 바랍니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                        return;
                    }
                }
            }
        }

        private void lblSTOR_LOC_Click(object sender, EventArgs e)
        {
            POPCombo combo_pop = new POPCombo("저장위치", "STORLOC", "SP_POP00_S02", Common.PlantCode);
            combo_pop.ShowDialog(this);
            if (combo_pop.DialogResult == DialogResult.OK)
            {
                lblSTOR_LOC.Tag = combo_pop.resultArray[0].ToString(); //code
                lblSTOR_LOC.Text = combo_pop.resultArray[2].ToString(); //display
            }
        }
        private void lblMATNR_Click(object sender, EventArgs e)
        {
            POPCombo combo_pop = new POPCombo("자재코드", "MATNRTRA", "SP_POP00_S02");
            combo_pop.ShowDialog(this);
            if (combo_pop.DialogResult == DialogResult.OK)
            {
                lblMATNR.Tag = combo_pop.resultArray[0].ToString(); //code
                lblMATNR.Text = combo_pop.resultArray[2].ToString(); //display
            }
        }

        #endregion
    }
}
