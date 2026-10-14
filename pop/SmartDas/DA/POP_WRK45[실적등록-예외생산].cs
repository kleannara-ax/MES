#region [ USING AREA ]
using System;
using System.Configuration;
using System.Data;
using System.Windows.Forms;
using System.Drawing;


using SAMMI;
using SmartDas.Components;
using SmartDas.POPUP;

using Oracle.ManagedDataAccess.Client;
#endregion

namespace SmartDas
{
    public partial class POP_WRK45 : BaseForm
    {
        #region < MEMBER AREA >
        private string sStartTime = string.Empty;

        private SAMMI.Common _common = new SAMMI.Common();

        private DataTable dtNowWrk;
        //private double dDimension = 0;
        private int iPLT2BOX = 0;
        private int iBOXCNT = 0;

        #endregion

        #region < CONSTRUCTOR >

        public POP_WRK45()
        {
            InitializeComponent();

            Common.SetMessageList();
            this.UpdateMinuteEvent += new UpdateMinuteHandler(Common.dailyLotChange);
        }
        public POP_WRK45(DataTable pNowWrkOrder)
        {
            InitializeComponent();

            Common.SetMessageList();

            dtNowWrk = pNowWrkOrder;
        }
        #endregion

        #region < POP_WRK45_Load >
        private void POP_WRK45_Load(object sender, EventArgs e)
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

                this.lblTitle.Text = "예외생산 실적등록";

                lblEndChk.Text = "";

                DateTime daysBefore = DateTime.Now;
                daysBefore = daysBefore.AddDays(-7);

                SetMenuButtons();
                DoFind();
            }
            catch (Exception ex)
            {
                SetMessage("POP_WRK45_Load_ Error!");
                LogFile.WriteLog("POP_WRK45.POP_WRK45_Load Error => " + ex.Message);
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
                LogFile.WriteLog("POP_WRK45.SetButtons Error => " + ex.Message);
            }
        }

        private void DoFind()
        {
            int iTempValue;
            int iBoxinPLT;

            try
            {
                if (dtNowWrk.Rows.Count < 1)
                {
                    SetMessage("조회된 작업지시가 없습니다.");
                    return;
                }
                else
                {
                    lblPRD_REQ_DT.Text = Common.dateFormat("O", dtNowWrk.Rows[0]["PRD_REQ_DT"].ToString());//생산지시일
                    lblWRK_ORDR_NO.Text = dtNowWrk.Rows[0]["WRK_ORDR_NO"].ToString();//작업지시번호
                    lblWRK_ORDR_SEQNO.Text = dtNowWrk.Rows[0]["WRK_ORDR_SEQNO"].ToString();//작업지시순번
                    lblMATNR.Tag = dtNowWrk.Rows[0]["MATNR"].ToString(); //자재코드
                    lblMATNR.Text = dtNowWrk.Rows[0]["MATNR_NM"].ToString(); //자재명
                    //lblMATNR_SPEC.Text = dtNowWrk.Rows[0]["PCODE"].ToString(); //지종
                    lblMATNR_SPEC.Text = dtNowWrk.Rows[0]["MATNR_SPEC"].ToString(); //규격
                    lblWRK_ORDR_RMK.Text = dtNowWrk.Rows[0]["WRK_ORDR_RMK"].ToString(); //작업지시사항

                    #region 계획수량
                    //팔레트 계획
                    if (int.TryParse(dtNowWrk.Rows[0]["PLTORDR"].ToString(), out iTempValue))
                        lblPLT_QTY.Text = iTempValue >= 0 ? string.Format("{0:#,##0}", iTempValue) : string.Empty; //실적량
                    else
                        lblPLT_QTY.Text = dtNowWrk.Rows[0]["PLTORDR"].ToString();
                    //박스 계획
                    if (int.TryParse(dtNowWrk.Rows[0]["BOXORDR"].ToString(), out iTempValue))
                        lblBOX_QTY.Text = iTempValue >= 0 ? string.Format("{0:#,##0}", iTempValue) : string.Empty; //실적량
                    else
                        lblBOX_QTY.Text = dtNowWrk.Rows[0]["BOXORDR"].ToString();
                    //폴리백 계획
                    if (int.TryParse(dtNowWrk.Rows[0]["BAGORDR"].ToString(), out iTempValue))
                        lblBAG_QTY.Text = iTempValue >= 0 ? string.Format("{0:#,##0}", iTempValue) : string.Empty; //실적량
                    else
                        lblBAG_QTY.Text = dtNowWrk.Rows[0]["BAGORDR"].ToString();
                    //개수 계획
                    if (int.TryParse(dtNowWrk.Rows[0]["EAORDR"].ToString(), out iTempValue))
                        lblEA_QTY.Text = iTempValue >= 0 ? string.Format("{0:#,##0}", iTempValue) : string.Empty; //실적량
                    else
                        lblEA_QTY.Text = dtNowWrk.Rows[0]["EAORDR"].ToString();
                    #endregion

                    #region 실적수량
                    //팔레트 실적
                    if (int.TryParse(dtNowWrk.Rows[0]["PLTQTY"].ToString(), out iTempValue))
                        lblTOT_PLT.Text = iTempValue >= 0 ? string.Format("{0:#,##0}", iTempValue) : string.Empty; //실적량
                    else
                        lblTOT_PLT.Text = dtNowWrk.Rows[0]["PLTQTY"].ToString();
                    //박스 실적
                    if (int.TryParse(dtNowWrk.Rows[0]["BOXQTY"].ToString(), out iTempValue))
                        lblTOT_BOX.Text = iTempValue >= 0 ? string.Format("{0:#,##0}", iTempValue) : string.Empty; //실적량
                    else
                        lblTOT_BOX.Text = dtNowWrk.Rows[0]["BOXQTY"].ToString();
                    //폴리백 실적
                    if (int.TryParse(dtNowWrk.Rows[0]["BAGQTY"].ToString(), out iTempValue))
                        lblTOT_BAG.Text = iTempValue >= 0 ? string.Format("{0:#,##0}", iTempValue) : string.Empty; //실적량
                    else
                        lblTOT_BAG.Text = dtNowWrk.Rows[0]["BAGQTY"].ToString();
                    //개수 실적
                    if (int.TryParse(dtNowWrk.Rows[0]["EAQTY"].ToString(), out iTempValue))
                        lblTOT_EA.Text = iTempValue >= 0 ? string.Format("{0:#,##0}", iTempValue) : string.Empty; //실적량
                    else
                        lblTOT_EA.Text = dtNowWrk.Rows[0]["EAQTY"].ToString();
                    #endregion

                    #region 실적 초기정보
                    int.TryParse(dtNowWrk.Rows[0]["PLT2BOX"].ToString(), out iBoxinPLT);
                    lblPRFM_BOX.Text = iBoxinPLT.ToString();
                    //팔레트
                    lblPRFM_PLT.Text = string.Format("{0:#,##0}", Common.GetChangeUnit(dtNowWrk.Rows[0]["PLT_RATE"].ToString(), iBoxinPLT));
                    //폴리백
                    lblPRFM_BAG.Text = string.Format("{0:#,##0}", Common.GetChangeUnit(dtNowWrk.Rows[0]["BAG_RATE"].ToString(), iBoxinPLT));
                    //개수
                    lblPRFM_EA.Text = string.Format("{0:#,##0}", Common.GetChangeUnit(dtNowWrk.Rows[0]["EA_RATE"].ToString(), iBoxinPLT));
                    #endregion

                    //팔레트당 박스 수량 (조회 실패시 0으로 입력하여 등록제한)
                    if (!int.TryParse(dtNowWrk.Rows[0]["PLT2BOX"].ToString(), out iPLT2BOX))
                        iPLT2BOX = 0;

                    lblPRFM_DATE.Text = Common.dateFormat("O", Common.GetRecDate(DateTime.Now));
                }
            }
            catch (Exception ex)
            {
                SetMessage("doFind Error!");
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                LogFile.WriteLog("POP_WRK08.WRK_ORDER Find Error => " + ex.Message);
            }
        }

        private void doConfirm()
        {
            DataSet dsTemp; //실적등록 결과 수신(0:라벨정보, 1:RFC 변수, 2:RFC 상세변수)
            int iTempQty = 0;
            string sCompflag = "N";

            try
            {
                if (iPLT2BOX == 0)
                {
                    new POPUP.MessageForm("팔레트별 박스수량을 확인하여 주시기 바랍니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return;
                }
                if (!int.TryParse(lblPRFM_BOX.Text.Replace(",", ""), out iBOXCNT))
                {
                    new POPUP.MessageForm("입력한 박스수량을 확인하여 주시기 바랍니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return;
                }

                //등록 수량이 남은 경우
                while (iBOXCNT > 0)
                {
                    DBHelper helper = new DBHelper(false, "", true);

                    try
                    {
                        //잔여수량이 팔레트 단위수량보다 많은 경우 단위수량 사용
                        //잔여수량이 단위수량보다 적은 경우 잔량을 사용
                        if (iBOXCNT > iPLT2BOX)
                        {
                            iTempQty = iPLT2BOX;
                        }
                        else
                        {
                            iTempQty = iBOXCNT;
                            //마지막 생산 체크후 마지막 팔레트시 완료상태 등록
                            if (lblEndChk.Text.Equals("V"))
                                sCompflag = "Y";
                        }

                        dsTemp = helper.FillDataSetN("SP_POP_WRK45_I01", CommandType.StoredProcedure, 3
                                 , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)
                                 , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)
                                 , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input)
                                 , helper.CreateParameter("P_ORDER_NO", Common.OrderNo, DbType.String, ParameterDirection.Input)
                                 , helper.CreateParameter("P_WRK_ORDR_NO", Common.WrkOrderNo, DbType.String, ParameterDirection.Input)
                                 , helper.CreateParameter("P_WRK_ORDR_SEQNO", Common.WrkOrderSeq, DbType.String, ParameterDirection.Input)
                                 , helper.CreateParameter("P_MATNR", Common.ItemCode, DbType.String, ParameterDirection.Input)
                                 , helper.CreateParameter("P_PRFM_QTY", iTempQty.ToString(), DbType.String, ParameterDirection.Input)
                                 , helper.CreateParameter("P_PRFM_DT", lblPRFM_DATE.Text, DbType.String, ParameterDirection.Input)
                                 , helper.CreateParameter("P_COMP_YN", sCompflag, DbType.String, ParameterDirection.Input)
                                 , helper.CreateParameter("P_USE_FUNC", DbType.String, ParameterDirection.Output, null, 30)
                                   );

                        if (helper.RSCODE == "E")
                        {
                            helper.Rollback();
                            new POPUP.MessageForm(helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                            return;
                        }
                        else if (helper.RSCODE == "N")
                        {
                            helper.Rollback();
                            new POPUP.MessageForm("자재의 수량이 부족합니다.\n" + helper.RSMSG.ToString() + "\n자재를 투입해 주세요.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                            return;
                        }
                        else
                        {
                            //현재 팔레트 완료처리
                            helper.Commit();
                            //라벨 출력
                            doPrint(dsTemp.Tables[0]);
                            //등록 및 출력된 수량 차감
                            iBOXCNT = iBOXCNT - iPLT2BOX;
                            System.Threading.Thread.Sleep(1000);
                        }
                    }
                    catch (Exception ex)
                    {
                        helper.Rollback();
                        new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                        return;
                    }
                    finally
                    {
                        helper.Close();
                    }

                }
                new POPUP.MessageForm("실적이 정상적으로 등록되었습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
            }
            catch (Exception ex)
            {
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
            }
            finally
            {
                this.Close();
            }
        }

        private void doPrint(DataTable dtTemp)
        {
            #region 바코드 라벨 테스트
            string PrinterName = SAMMI.IniFile.GetValue("KLEANNARA", "PRINTER", null);
            string PrinterDPI = SAMMI.IniFile.GetValue("KLEANNARA", "PRINTERDPI", null);
            string sZPL = string.Empty;
            //제목(PRODUCT)
            string sTitle = string.Empty;
            //생산정보(일자, 호기)
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

            sTitle = "PRODUCT";
            //생산정보(일자, 호기)
            sPRD_DT = dtTemp.Rows[0]["PRFM_DT"].ToString();
            sMACH_NM = dtTemp.Rows[0]["MACH_NM"].ToString();
            sPRFM_QTY = dtTemp.Rows[0]["PRFM_QTY"].ToString();
            //제품정보(종류, 코드, 명, KAN, 기본단위, 파렛트단위, LOT)
            sMATNR_DIV = dtTemp.Rows[0]["MATNR_DIV_NM"].ToString();
            sMATNR = dtTemp.Rows[0]["MATNR"].ToString();
            sMATNR_NM = dtTemp.Rows[0]["MATNR_NM"].ToString();
            sKAN_CD = dtTemp.Rows[0]["KAN_CD"].ToString();
            sBS_UNIT = dtTemp.Rows[0]["BAG2BOX"].ToString();
            sPLT_UNIT = dtTemp.Rows[0]["BOX2PLT"].ToString();
            sLOT_NO = dtTemp.Rows[0]["LOT_NO"].ToString();
            //바코드
            sINDBCD = dtTemp.Rows[0]["IND_BCD"].ToString();

            DBHelper helper = new DBHelper(false);
            try
            {
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

                        break;
                    }
                }
            }
            catch (Exception ex)
            {
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                LogFile.WriteLog("POP_WRK45.doPrint Error\r\n" + ex.Message);
            }
            finally
            {
                helper.Close();
            }
            #endregion
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
                    case "Confirm":  //작업지시 선택
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
                new POPUP.MessageForm(oe.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
            }

            catch (Exception ex)
            {
                SetMessage(ex.Message);
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                LogFile.WriteLog("POP_WRK45.bBox1_buttonClickEvent Error => " + ex.Message);
            }
            finally
            {

            }
        }

        private void lblPRFM_BOX_Click(object sender, EventArgs e)
        {
            double dDimension = 0;

            DAResultQty pop = new DAResultQty();
            pop.LabelTitle = "실적수량 입력";
            pop.LabelHeader = "실적수량";
            pop.ContentMaxLength = 8;

            pop.ShowDialog(this);

            if (pop.DialogResult == DialogResult.OK)
            {
                dDimension = pop.ResultDouble;
                lblPRFM_BOX.Text = string.Format("{0:#,0}", dDimension);
                //팔레트
                lblPRFM_PLT.Text = Common.GetChangeUnit(dtNowWrk.Rows[0]["PLT_RATE"].ToString(), dDimension).ToString();
                //폴리백
                lblPRFM_BAG.Text = Common.GetChangeUnit(dtNowWrk.Rows[0]["BAG_RATE"].ToString(), dDimension).ToString();
                //개수
                lblPRFM_EA.Text = Common.GetChangeUnit(dtNowWrk.Rows[0]["EA_RATE"].ToString(), dDimension).ToString();
            }
        }

        private void lblEndChk_Click(object sender, EventArgs e)
        {
            if (lblEndChk.Text.ToString().Equals("V"))
            {
                lblEndChk.Text = "";
                lblEndChk.BackColor = Color.White;
            }
            else
            {
                lblEndChk.Text = "V";
                lblEndChk.BackColor = Color.Yellow;
            }
        }
        #endregion
    }
}
