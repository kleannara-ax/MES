#region [ USING AREA ]
using System;
using System.Configuration;
using System.Data;
using System.Windows.Forms;
using Infragistics.Win.UltraWinGrid;


using SAMMI;
using SmartDas.Components;
using SmartDas.POPUP;

#endregion

namespace SmartDas
{
    public partial class POP_INV91 : BaseForm
    {
        #region < MEMBER AREA >

        private SAMMI.Common _common = new SAMMI.Common();

        private int iSelRow = -1;

        #endregion

        #region < CONSTRUCTOR >

        public POP_INV91()
        {
            InitializeComponent();

            Common.SetMessageList();

        }
        #endregion

        #region < POP_INV91_Load >
        private void POP_INV91_Load(object sender, EventArgs e)
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

                this.lblTitle.Text = "자재 투입 현황";

                DateTime daysBefore = DateTime.Now;
                dtpSTRDate.Value = daysBefore;

                SetMenuButtons();
                SetGrid();
            }
            catch (Exception ex)
            {
                SetMessage("POP_INV91_Load_ Error!");
                LogFile.WriteLog("POP_INV91.POP_INV91_Load Error => " + ex.Message);
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

                bBox1[0, 0].Text = "";
                bBox1[0, 0].Tag = "";
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
                LogFile.WriteLog("POP_INV91.SetButtons Error => " + ex.Message);
            }
        }

        private void SetGrid()
        {
            DBHelper helper = new DBHelper();
            //변수
            string sStrDate = string.Empty;
            string sEndDate = string.Empty;
            string sItemCode = string.Empty; //자재코드
            string sWrkOrder = string.Empty; //작업지시
            string sMatnr = string.Empty;       // 자재코드
            string sMatnrNm = string.Empty;     // 자재명

            string sColInfo = string.Empty; //컬럼 헤더
            string sColType = string.Empty; //컬럼 타입
            //반환테이블
            DataSet dsTemp = new DataSet();
            DataTable dtRtn;
            DataTable dtTemp = new DataTable();
            DataRow rTemp = null;

            try
            {
                //변수설정
                sStrDate = dtpSTRDate.Value.ToString("yyyy-MM-dd");//시작일자
                sEndDate = dtpENDDate.Value.ToString("yyyy-MM-dd");//완료일자
                sWrkOrder = txtWrkOrder.Text; //작업지시
                sMatnr = txtMATNR.Text;         // 자재코드
                sMatnrNm = txtMATNRNM.Text;     // 자재명

                //그리드 설정
                Grid1.HeaderFontSize = 13;
                Grid1.FontSize = 13;
                Grid1.CountRows = 8;
                Grid1.AutoScroll = true;
                Grid1.DisplayLayout.Scrollbars = Scrollbars.Automatic;
                Grid1.DisplayLayout.Bands[0].Override.SelectTypeCol = SelectType.None;

                btnRightPage.LinkMoveSize = Grid1.CountRows;
                btnLeftPage.LinkMoveSize = Grid1.CountRows;

                //버튼 목록 조회
                dtRtn = helper.FillTable("SP_POP_INV91_S01", CommandType.StoredProcedure
                                                               , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_STRDATE", sStrDate, DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_ENDDATE", sEndDate, DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_WRK_ORDER", sWrkOrder, DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_MATNR", sMatnr, DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_MATNRNM", sMatnrNm, DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_COLINFO", DbType.String, ParameterDirection.Output, null, 1000)
                                                               , helper.CreateParameter("P_COLTYPE", DbType.String, ParameterDirection.Output, null, 1000));
                if (dtRtn.Rows.Count < 1)
                {
                    SetMessage("조회된 투입이력이 없습니다.");
                }

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


            }
            catch (Exception ex)
            {
                SetMessage("SetGrid Error!");
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                LogFile.WriteLog("POP_INV91.SetGrid Error => " + ex.Message);
            }
        }

        private void doPrint(int iSelRow, string StckQty)
        {
            string PrinterName = SAMMI.IniFile.GetValue("KLEANNARA", "PRINTER", null); //Common.getConfig("PRINTER");//"ZT421";
            string PrinterDPI = SAMMI.IniFile.GetValue("KLEANNARA", "PRINTERDPI", null);
            bool bPrint = false;
            string sZPL = string.Empty;
            double dPRFM_QTY;

            string sPRD_DT = string.Empty;
            string sPRFM_QTY = string.Empty;
            string sMATNR = string.Empty;
            string sMATNR_NM = string.Empty;
            string sKAN_CD = string.Empty;
            string sUNIT = string.Empty;
            string sLOT_NO = string.Empty;
            //합지라벨용
            string sBS_WGT = string.Empty;
            string sMACH_NM = string.Empty;
            string sCOLOR = string.Empty;
            string sWRK_NAME = string.Empty;
            string sQCJUD = string.Empty;
            //바코드
            string sINDBCD = string.Empty;
            //int iSelRow = Grid1.Row.Index;

            if (double.TryParse(StckQty, out dPRFM_QTY))
            {
                //소진 완료시 라벨 미출력처리
                if (dPRFM_QTY == 0.0)
                    return;
                else
                    sPRFM_QTY = StckQty;
            }
            else
            {
                new POPUP.MessageForm("실잔량은 숫자만 입력가능합니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                this.DialogResult = DialogResult.Cancel;
                return;
            }

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
                        LogFile.WriteLog("POP_INV91.doPrint Error => " + ex.Message);
                        bPrint = false;
                    }
                    finally
                    {
                        helper.Close();
                    }
                }
                else
                {
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
            POP_WRK82 pop;
            string WrkOrdrNo = string.Empty;
            string WrkOrdrSeqNo = string.Empty;
            string IndBcd = string.Empty;
            string InpDT = String.Format("{0:yyyyMMdd}", (DateTime)(dtpENDDate.Value));

            if (Grid1.Rows.Count > 0)
            {
                if (iSelRow >= 0)
                {
                    WrkOrdrNo = Grid1.Rows[iSelRow].Cells["WRK_ORDR_NO"].Value.ToString();
                    WrkOrdrSeqNo = Grid1.Rows[iSelRow].Cells["WRK_ORDR_SEQNO"].Value.ToString();
                    IndBcd = Grid1.Rows[iSelRow].Cells["IND_BCD"].Value.ToString();
                }
            }

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
                    case "Remain":  //잔량처리
                        // 플랜트코드, 작업지시번호, 작업지시순번, 업체/개별바코드, OperationType
                        //public POP_WRK82(string PlantCode, string WrkOrdrNo, string WrkOrdrSeqNo, string IndBcd, string OperType)
                        if (iSelRow >= 0)
                        {
                            pop = new POP_WRK82(Common.PlantCode, WrkOrdrNo, WrkOrdrSeqNo, InpDT, IndBcd, "REMAIN");
                            pop.ShowDialog(this);
                            if (pop.DialogResult == DialogResult.OK)
                                doPrint(iSelRow, pop.StckQty_Get);
                            SetGrid();
                        }
                        else
                        {
                            new POPUP.MessageForm("잔량처리를 진행할 자재를 선택하시기 바랍니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                            return;
                        }
                        break;

                    case "Return":  //반납처리
                        if (iSelRow >= 0)
                        {
                            pop = new POP_WRK82(Common.PlantCode, WrkOrdrNo, WrkOrdrSeqNo, InpDT, IndBcd, "RETURN");
                            pop.ShowDialog(this);
                            if (pop.DialogResult == DialogResult.OK)
                                doPrint(iSelRow, pop.StckQty_Get);
                            SetGrid();
                        }
                        else
                        {
                            new POPUP.MessageForm("반품처리를 진행할 자재를 선택하시기 바랍니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                            return;
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
                LogFile.WriteLog("POP_INV91.bBox1_buttonClickEvent Error => " + ex.Message);
            }
            finally
            {

            }
        }

        private void Grid1_GridClick(object sender, MESGrid.GridClickEventArg e)
        {
            if (Grid1.Rows.Count < 1)
            {
                return;
            }

            if (Grid1.Row == null)
            {
                return;
            }

            iSelRow = e.row.Index;
        }

        private void butWorkDate_Click(object sender, EventArgs e)
        {
            Button btnTemp = (Button)sender;
            DAResultDate pop;
            string tempDate;

            if (btnTemp.Name.Equals("butSTRDate"))
            {
                pop = new DAResultDate(dtpSTRDate.Value);
                pop.ShowDialog(this);
                if (pop.DialogResult == DialogResult.OK)
                {
                    tempDate = pop.ResultString.ToString();
                    dtpSTRDate.Value = DateTime.Parse(tempDate);
                }
            }
            else
            {
                pop = new DAResultDate(dtpENDDate.Value);
                pop.ShowDialog(this);
                if (pop.DialogResult == DialogResult.OK)
                {
                    tempDate = pop.ResultString.ToString();
                    dtpENDDate.Value = DateTime.Parse(tempDate);
                }
            }
        }

        private void btnFind_Click(object sender, EventArgs e)
        {
            SetGrid();
        }

        private void dtpDate_DropDown(object sender, EventArgs e)
        {
            CommonCalendar.CloseCalendar((DateTimePicker)sender);
        }
        #endregion



    }
}
