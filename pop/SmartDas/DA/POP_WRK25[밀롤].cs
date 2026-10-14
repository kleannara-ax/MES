#region [ USING AREA ]
using System;
using System.Configuration;
using System.Data;
using System.Windows.Forms;
using System.Drawing;
using Infragistics.Win.UltraWinGrid;


using SAMMI;
using SmartDas.Components;
using SmartDas.POPUP;
using System.Globalization;
using Oracle.ManagedDataAccess.Client;
using System.Threading;
#endregion

namespace SmartDas
{
    public partial class POP_WRK25 : BaseForm
    {
        #region < MEMBER AREA >

        private DataTable dtInpInfo = new DataTable(); //투입 정보 테이블

        private int giBS_WGT = 0;               // 평량
        private int giMWIDTH_SUM = 0;           // 밀롤지폭합
        private Decimal gdROLLCNT = 0;          // 밀롤실적치수
//        private Decimal gdWGT = 0;              // 총중량

        private Decimal gdDISPO_ROLLCNT = 0;   // 폐품치수
        private Decimal gdDISPO_WGT = 0;         // 폐품중량

        private int gMax_ROLLCNT = 0;           // 실적(생산 + 폐품) 가능한 권치수
        private string gsLAST_END_DATE = string.Empty;   //밀롤생산종료일시중 가장최근 자료(YYYYMMDDHH24MISS)

        private SAMMI.Common _common = new SAMMI.Common();

        private bool gbUpdateGrid = false;

        private bool btnWaitFlag = false;

        // 버튼 알람용 변수
        private int iReSetCnt = 0;
        private bool bABNChk = false;
        public string sRS_MACH_STA = string.Empty;
        DataTable dtStop_Temp = new DataTable();
        //public static string userID = string.Empty;
        //public static string userName = string.Empty;

        //*************************************
        //control 네이밍 정보
        //-------------------------------------
        //투입정보  : IN_XXX (INput)
        //작업지시정보 : WO_XXX (Work Order)
        //실적등록정보 : PF_XXX (PerFormance)
        //*************************************
        #endregion

        #region < CONSTRUCTOR >

        public POP_WRK25()
        {
            InitializeComponent();

            Common.SetMessageList();
            this.UpdateMinuteEvent += new UpdateMinuteHandler(CallUpdateMinuteFunc);
        }

        public void CallUpdateMinuteFunc()
        {
            if (lblEndDateChk.Text == "V")
            {
                DateTime dtTmp = DateTime.Now;

                //Console.WriteLine("CallUpdateTimeFunc : " + dtTmp.ToString("yyyy-MM-dd HH:mm:ss"));

                // lblStartTime.Text 에 시:분 을 먼지 입력해야 dtpDate_ValueChanged 이벤트에서 AutoCalculation() 에서 정상처리됨.
                lblEndTime.Text = dtTmp.ToString("HH:mm");       // 작업종료시간
                dtpEndDate.Value = dtTmp;
                
                //AutoCalculation();
            }
        }

        #endregion

        #region < POP_WRK25_Load >

        private void POP_WRK25_Load(object sender, EventArgs e)
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

                this.lblTitle.Text = "밀롤 실적등록";

                Common.machSetting();
                //테스트 설정 
                //Common.PlantCode = "P100";      // 플랜트 코드
                //Common.OpCode = "MA";           // 공정코드
                //Common.IOType = "N";            // PS=N, 
                //Common.MachineCode = "PMA03";   // 설비호기

                ucPNT_TYPE.SelectedIndex = 0;
                ucPNT_TYPE.ValueList.ItemHeight = 70;

                ucCORE.SelectedIndex = 0;
                ucCORE.ValueList.ItemHeight = 70;

                SetMenuButtons();

                InitProduct();

                SetCore();      // 지관 구하기

                UpdateGrid();

                lblMEndChk.BackColor = Color.Yellow;
                lblPrintChk.BackColor = Color.Yellow;
                lblPF_CHK_DISPO.BackColor = Color.Yellow;

            }
            catch (Exception ex)
            {
                SetMessage("POP_WRK25_Load_ Error!");
                LogFile.WriteLog("POP_WRK25.POP_WRK25_Load Error => " + ex.Message);
            }
        }
        #endregion

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

                bBox1[0, 0].Text = "작업지시" + Environment.NewLine + "선택";
                bBox1[0, 0].Tag = "Order";
                bBox1[0, 0].MappingButton.FontSize = 14;
                bBox1[0, 1].Text = "작업자" + Environment.NewLine + "선택";
                bBox1[0, 1].Tag = "Worker";
                bBox1[0, 1].MappingButton.FontSize = 14;
                bBox1[0, 2].Text = "설비선택";
                bBox1[0, 2].Tag = "Machine";
                bBox1[0, 2].MappingButton.FontSize = 14;
                bBox1[0, 3].Text = "작업시작";
                bBox1[0, 3].Tag = "Start";
                bBox1[0, 3].MappingButton.FontSize = 14;
                bBox1[0, 4].Text = "비가동" + Environment.NewLine + "등록";
                bBox1[0, 4].Tag = "NonOper";
                bBox1[0, 4].MappingButton.FontSize = 14;
                bBox1[0, 5].Text = "실적등록";
                bBox1[0, 5].Tag = "Product";
                bBox1[0, 5].MappingButton.FontSize = 14;
                bBox1[0, 6].Text = "폐품선택";
                bBox1[0, 6].Tag = "Dispo";
                bBox1[0, 6].MappingButton.FontSize = 14;
                bBox1[0, 7].Text = "공정투입";
                bBox1[0, 7].Tag = "Input";
                bBox1[0, 7].MappingButton.FontSize = 14;
                bBox1[0, 8].Text = "공정체크";
                bBox1[0, 8].Tag = "Check";
                bBox1[0, 8].MappingButton.FontSize = 14;
                bBox1[0, 9].Text = "";      //"자재" + Environment.NewLine + "투입이력";
                bBox1[0, 9].Tag = "";       //"InputLog";
                bBox1[0, 9].MappingButton.FontSize = 14;
                bBox1[0, 10].Text = "실적현황";
                bBox1[0, 10].Tag = "Performance";
                bBox1[0, 10].MappingButton.FontSize = 14;

                bBox1.RedrawButtons();
            }
            catch (Exception ex)
            {
                SetMessage("SetButtons Error!");
                LogFile.WriteLog("POP_WRK25.SetMenuButtons Error => " + ex.Message);
            }
        }

        #region < METHOD AREA >
        // 지관 정보 가져오기
        private void SetCore()
        {
            DBHelper helper = new DBHelper(false);
            DataTable dtRtn;
            string sIPAddr = string.Empty;

            try
            {
                dtRtn = helper.FillTable("SP_POP00_S05", CommandType.StoredProcedure
                                                        , helper.CreateParameter("P_CMCDKY", "CORETY", DbType.String, ParameterDirection.Input)
                                                        , helper.CreateParameter("P_COLINFO", DbType.String, ParameterDirection.Output, null, 1000)
                                                        , helper.CreateParameter("P_COLTYPE", DbType.String, ParameterDirection.Output, null, 1000));
                if (dtRtn.Rows.Count < 1)
                {
                    //new POPUP.MessageForm("조회된 작업지시가 없습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return;
                }
                else
                {
                    ucCORE.Items.Clear();

                    //ucCORE.Items.Add("00", " ");
                    foreach (DataRow row in dtRtn.Rows)
                    {
                        ucCORE.Items.Add(row["ITEM_CODE"].ToString(), row["DISPLAY"].ToString());
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                helper.Close();
            }
        }

        private void SetGrid()
        {
            DBHelper helper = new DBHelper();

            DataSet dsRtn = new DataSet();
            DataSet dsJA = new DataSet();
            DataSet dsWrk = new DataSet();

            DataTable dtTemp = new DataTable();
            try
            {
                Grid1.DataSource = null;
                Grid2.DataSource = null;
                Grid3.DataSource = null;

                Grid1.HeaderFontSize = 15;
                Grid1.FontSize = 16;
                Grid1.CountRows = 3;
                Grid1.AutoScroll = true;
                Grid1.DisplayLayout.Bands[0].Override.SelectTypeCol = SelectType.None;
                Grid1.DisplayLayout.Scrollbars = Scrollbars.Automatic;
                btnRightPage.LinkMoveSize = Grid1.CountRows;
                btnLeftPage.LinkMoveSize = Grid1.CountRows;

                Grid2.HeaderFontSize = 11;
                Grid2.FontSize = 11;
                Grid2.CountRows = 4;
                Grid2.AutoScroll = true;
                Grid2.DisplayLayout.Scrollbars = Scrollbars.Automatic;
                Grid2.DisplayLayout.Bands[0].Override.SelectTypeCol = SelectType.None;
                btnUp.LinkMoveSize = Grid2.CountRows;
                btnDown.LinkMoveSize = Grid2.CountRows;

                //Grid1.Rows.Band.Override.SelectedRowAppearance.BackColor = Color.PeachPuff;
                //Grid1.Rows.Band.Override.SelectedRowAppearance.ForeColor = Color.Black;
                //Grid1.Rows.Band.Override.SelectedRowAppearance.FontData.BoldAsString = "False";

                //Grid2.Rows.Band.Override.SelectedRowAppearance.BackColor = Color.PeachPuff;
                //Grid2.Rows.Band.Override.SelectedRowAppearance.ForeColor = Color.Black;
                //Grid2.Rows.Band.Override.SelectedRowAppearance.FontData.BoldAsString = "False";

                dsRtn = helper.FillDataSetN("SP_POP_WRK25_S01", CommandType.StoredProcedure, 5
                                                    , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)                     // 플랜트코드
                                                    , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)                  //작업장코드(설비코드)
                                                    , helper.CreateParameter("RS_MACH_STA", DbType.String, ParameterDirection.Output, null, 30)                     //  RES MACH_STA 가동상태(R :가동, S:비가동, N:대기중)
                                                    );

                if (helper.RSCODE == "S" || helper.RSCODE == "E")
                {
                    timer1.Start();

                    bBox1[0, 4].bAlarm = false;

                    sRS_MACH_STA = helper.Parameters["RS_MACH_STA"].Value.ToString();

                    //가동상태(R :가동, S:비가동, N:대기중)
                    if (sRS_MACH_STA.Equals("R"))
                    {
                        lblMACH_STA.Text = "가동중";
                        bBox1[0, 3].Text = "대기중";
                        bBox1[0, 3].Tag = "Start";
                        bBox1.RedrawButtons();
                        bABNChk = false;
                    }
                    else if (sRS_MACH_STA.Equals("S"))
                    {
                        lblMACH_STA.Text = "비가동";
                        bBox1[0, 3].Text = "작업시작";
                        bBox1[0, 3].Tag = "Start";
                        bBox1.RedrawButtons();
                        //비가동시 점멸처리
                        bABNChk = true;
                    }
                    else
                    {
                        lblMACH_STA.Text = "대기중";
                        bBox1[0, 3].Text = "작업시작";
                        bBox1[0, 3].Tag = "Start";
                        bBox1[0, 3].UseFlag = true;
                        bBox1.RedrawButtons();
                        bABNChk = false;
                    }

                }


                //버튼 상태 변경
                if (helper.RSCODE.Equals("S"))
                {

                    dtInpInfo = dsRtn.Tables[0].Copy();

                    //점보롤 바코드 목록
                    dsJA.Tables.Add(dsRtn.Tables[1].Copy());
                    dsJA.Tables.Add(dsRtn.Tables[2].Copy());
                    Grid1.DoFind_Oracle(dsJA);

                    //밀롤 작업 지시번호
                    dsWrk.Tables.Add(dsRtn.Tables[3].Copy());
                    dsWrk.Tables.Add(dsRtn.Tables[4].Copy());
                    Grid2.DoFind_Oracle(dsWrk);

                    Grid1.DisplayLayout.Override.DefaultRowHeight = 50;
                    Grid2.DisplayLayout.Override.DefaultRowHeight = 50;

                    if (Grid1.Rows.Count > 0)
                    {
                        // 첫번째 행 선택
                        Grid1.Rows[0].Selected = true;
                        Grid1.Row = Grid1.Rows[0];
                        ////GridSelectChanged event 강제 발생시킴
                        //Grid1_GridSelectChanged(Grid1, new AfterSelectChangeEventArgs(typeof(UltraGridRow)));
                    }
                    else
                    {
                        Grid1.Row = null;
                    }

                    if (Grid2.Rows.Count > 0)
                    {
                        // 첫번째 행 선택
                        Grid2.Rows[0].Selected = true;
                        Grid2.Row = Grid2.Rows[0];
                    }
                }
                else
                {
                    dtInpInfo.Reset();     // 투입정보 테이블

                    new POPUP.MessageForm(helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return;
                }
            }
            catch (Exception ex)
            {
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                LogFile.WriteLog("POP_WRK25.SetGrid Error => " + ex.Message);
            }
        }


        private void DoFind()
        {
            try
            {
                if (dtInpInfo.Rows.Count < 1
                    || string.IsNullOrEmpty(dtInpInfo.Rows[0]["WRK_ORDR_NO"].ToString()))
                {
                    //SetMessage("조회된 작업지시가 없습니다.");
                    lblIN_LOT_NO.Text = string.Empty;
                    lblIN_PCODE.Text = string.Empty;
                    lblIN_BS_WGT.Text = string.Empty;
                    lblIN_JWIDTH.Text = string.Empty;
                    txtIN_REMARK.Text = string.Empty;

                    lblIN_PRFM_WGT.Text = string.Empty;
                    lblIN_USE_WGT.Text = string.Empty;
                    lblIN_DISPO_QTY.Text = string.Empty;
                    lblIN_AVA_WGT.Text = string.Empty;

                    //lblMACH_STA.Text = "대기중";      // 설비 상태

                    Common.OrderNo = string.Empty;//생산오더번호
                    Common.WrkOrderNo = string.Empty;//작업지시번호
                    Common.WrkOrderSeq = string.Empty;//작업지시순번
                    Common.ItemCode = string.Empty; //자재코드
                }
                else
                {
                    //공통사용항목 관리
                    Common.OrderNo = dtInpInfo.Rows[0]["ORDER_NO"].ToString();//생산오더번호
                    Common.WrkOrderNo = dtInpInfo.Rows[0]["WRK_ORDR_NO"].ToString();//작업지시번호
                    Common.WrkOrderSeq = dtInpInfo.Rows[0]["WRK_ORDR_SEQNO"].ToString();//작업지시순번
                    Common.ItemCode = dtInpInfo.Rows[0]["MATNR"].ToString(); //자재코드


                    lblIN_LOT_NO.Text = string.Format("{0}-{1}", Common.WrkOrderNo, Common.WrkOrderSeq);
                    lblIN_PCODE.Text = dtInpInfo.Rows[0]["PCODE"].ToString(); //지종
                    lblIN_BS_WGT.Text = dtInpInfo.Rows[0]["BS_WGT"].ToString(); //평량
                    lblIN_JWIDTH.Text = dtInpInfo.Rows[0]["JWIDTH"].ToString(); //지폭

                    string sPRD_STR_DTM = dtInpInfo.Rows[0]["PRD_STR_DTM"].ToString(); //생산시작일시(YYYYMMDDHH24MISS)

                    DateTime dtTmp;
                    if (DateTime.TryParseExact(sPRD_STR_DTM, "yyyyMMddHHmmss", null, DateTimeStyles.AssumeLocal, out dtTmp))
                    {
                        lblStartTime.Text = dtTmp.ToString("HH:mm");       // 작업시작시간
                        dtpStartDate.Value = dtTmp;

                        lblEndTime.Text = dtTmp.ToString("HH:mm");       // 작업종료시간
                        dtpEndDate.Value = dtTmp;
                    }
                    else
                    {
                        lblStartTime.Text = lblEndTime.Text = "";
                        dtpStartDate.Value = dtpEndDate.Value = DateTime.Now;
                    }

                    ////가동상태(R :가동, S:비가동, N:대기중)
                    //if (dtInpInfo.Rows[0]["MACH_STA"].ToString().Equals("R"))
                    //{
                    //    lblMACH_STA.Text = "가동중";
                    //}
                    //else if (dtInpInfo.Rows[0]["MACH_STA"].ToString().Equals("S"))
                    //{
                    //    lblMACH_STA.Text = "비가동";
                    //}
                    //else
                    //{
                    //    lblMACH_STA.Text = "대기중";
                    //}
                }

                // 평량 ...
                int iData = 0;

                if (int.TryParse(lblIN_BS_WGT.Text.ToString().Replace(",", ""), out iData) == true)
                {
                    giBS_WGT = iData;
                }
                else
                {
                    giBS_WGT = 0;
                }
            }
            catch (Exception ex)
            {
                SetMessage("SetGrid Error!");
                LogFile.WriteLog("POP_WRK25.DoFind Error => " + ex.Message);
            }
        }

        // sListNo 정보 = 1 : 점보롤 바코드 정보, 2 : 작업지시정보
        private void SetGrid02(string sListNo)
        {
            if (Grid2.Rows.Count < 1)
            {
                return;
            }

            if (Grid2.Row == null)
            {
                return;
            }

            DBHelper helper = new DBHelper();
            DataSet dsRtn = new DataSet();
            DataTable dtTemp = new DataTable();
            try
            {
                string sJORDER_NO = "";   // 점보롤 오더번호
                string sORDER_NUM = "";      // 작업지시 순번
                string sORDER_SEQ = "";      // 작업지시 순번

                string sJIND_BCD = "";      // 개별바코드

                if (sListNo == "1")
                {
                    if (Grid1.Rows.Count < 1 || Grid1.Row == null) 
                    {
                        lblIN_PRFM_WGT.Text = ""; //실적량
                        lblIN_USE_WGT.Text = ""; //사용량
                        lblIN_DISPO_QTY.Text = ""; //폐품량
                        lblIN_AVA_WGT.Text = ""; //가용량
                        txtIN_REMARK.Text = ""; //작업자 비고

                        return;
                    }

                    sJIND_BCD = Grid1.Row.Cells["IND_BCD"].Value.ToString();      // 개별바코드
                }
                else
                {
                    sJORDER_NO = Grid2.Row.Cells["PRE_ORDER_NO"].Value.ToString();   // 점보롤 오더번호
                    sORDER_NUM = Grid2.Row.Cells["ORDER_NUM"].Value.ToString();      // 작업지시 순번
                    sORDER_SEQ = Grid2.Row.Cells["ORDER_SEQ"].Value.ToString();      // 작업지시 순번

                    Grid3.HeaderFontSize = 10;
                    Grid3.FontSize = 11;
                    //Grid3.CountRows = 4;
                    Grid3.AutoScroll = true;
                    Grid3.DisplayLayout.Scrollbars = Scrollbars.Automatic;
                    //Grid3.DisplayLayout.Bands[0].ColHeadersVisible = false;
                    //2022.10.25 한동규 그리드 소트 기능 추가
                    Grid3.DisplayLayout.Override.HeaderClickAction = HeaderClickAction.SortSingle;
                    //Grid3.DisplayLayout.Bands[0].ResetSortedColumns();

                    Grid3.DisplayLayout.Bands[0].Override.SelectTypeCol = SelectType.None;

                }

                dsRtn = helper.FillDataSetN("SP_POP_WRK25_S02", CommandType.StoredProcedure, 2
                                                    , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)      // 플랜트코드
                                                    , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)  // 작업장코드(설비코드)
                                                    , helper.CreateParameter("P_LIST_NO", sListNo, DbType.String, ParameterDirection.Input)             // 1 : 점보롤 바코드 정보, 2 : 작업지시정보
                                                    , helper.CreateParameter("P_JIND_BCD", sJIND_BCD, DbType.String, ParameterDirection.Input)          // 1 : 점보롤 바코드 정보 조회시
                                                    , helper.CreateParameter("P_JORDER_NO", sJORDER_NO, DbType.String, ParameterDirection.Input)        // 2 : 작업지시정보 조회 시
                                                    , helper.CreateParameter("P_ORDER_NUM", sORDER_NUM, DbType.String, ParameterDirection.Input)        // 2 : 작업지시정보 조회 시
                                                    , helper.CreateParameter("P_ORDER_SEQ", sORDER_SEQ, DbType.String, ParameterDirection.Input)        // 2 : 작업지시정보 조회 시
                                                    );
                //버튼 상태 변경
                if (helper.RSCODE.Equals("S"))
                {
                    if (sListNo == "1")
                    {
                        dtTemp = dsRtn.Tables[0].Copy();

                        if (dtTemp.Rows.Count > 0)
                        {
                            lblIN_PRFM_WGT.Text = Common.StrFormatDouble(dtTemp.Rows[0]["PRFM_QTY"].ToString()); //실적량
                            lblIN_USE_WGT.Text = Common.StrFormatDouble(dtTemp.Rows[0]["USE_QTY"].ToString()); //사용량
                            lblIN_DISPO_QTY.Text = Common.StrFormatDouble(dtTemp.Rows[0]["DISPO_QTY"].ToString()); //폐품량
                            lblIN_AVA_WGT.Text = Common.StrFormatDouble(dtTemp.Rows[0]["ABLE_QTY"].ToString()); //가용량
                            txtIN_REMARK.Text = dtTemp.Rows[0]["RMK"].ToString().Replace("|", "\r\n"); //작업자 비고
                        }
                        else
                        {
                            lblIN_PRFM_WGT.Text = ""; //실적량
                            lblIN_USE_WGT.Text = ""; //사용량
                            lblIN_DISPO_QTY.Text = ""; //폐품량
                            lblIN_AVA_WGT.Text = ""; //가용량
                            txtIN_REMARK.Text = ""; //작업자 비고
                        }
                    }
                    else
                    {
                        Grid3.DoFind_Oracle(dsRtn);
                        Grid3.DisplayLayout.Override.DefaultRowHeight = 50;
//                        Grid3.DisplayLayout.Bands[0].Columns["MWIDTH"].SortIndicator = SortIndicator.Descending;      // 기본 정렬을 지정할 경우 추가

                        DoFind03();
                    }
                }
                else
                {
                    if (sListNo == "1")
                    {
                        lblIN_PRFM_WGT.Text = ""; //실적량
                        lblIN_USE_WGT.Text = ""; //사용량
                        lblIN_DISPO_QTY.Text = ""; //폐품량
                        lblIN_AVA_WGT.Text = ""; //가용량
                        txtIN_REMARK.Text = ""; //작업자 비고
                    }

                    new POPUP.MessageForm(helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return;
                }
            }
            catch (Exception ex)
            {
                if (sListNo == "1")
                {
                    lblIN_PRFM_WGT.Text = ""; //실적량
                    lblIN_USE_WGT.Text = ""; //사용량
                    lblIN_DISPO_QTY.Text = ""; //폐품량
                    lblIN_AVA_WGT.Text = ""; //가용량
                    txtIN_REMARK.Text = ""; //작업자 비고
                }

                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                LogFile.WriteLog("POP_WRK25.SetGrid2 Error => " + ex.Message);
            }
        }

        // 밀롤작업지시 내용
        private void DoFind03()
        {
            int iMIN_ROLLCNT = 0;
            int iPosROLLCNT = 0;         // 등록가능한 권치수

            giMWIDTH_SUM = 0;                   // 밀롤지폭합

            // 밀롤 지폭합 구하기.
            foreach (UltraGridRow ugr in Grid3.Rows)
            {
                if (ugr.Cells["CHK"].Value.ToString().Equals("V"))
                {
                    int nMWIDTH = 0;
                    //string sMWIDTH = ugr.Cells["MWIDTH_INPUT"].Value.ToString().Replace(",", "");
                    string sMWIDTH = ugr.Cells["MWIDTH"].Value.ToString().Replace(",", "");

                    if (int.TryParse(sMWIDTH, out nMWIDTH) == true)
                    {
                        giMWIDTH_SUM += nMWIDTH;
                    }

                    int iMROLLCNT = 0;          // 계획권치수
                    int iPRD_MROLLCNT = 0;      // 실적권치수
                    int iDISPO_MROLLCNT = 0;    // 폐품권치수

                    int.TryParse(ugr.Cells["MROLLCNT"].Value.ToString().Replace(",", ""), out iMROLLCNT);               // 계획권치수
                    int.TryParse(ugr.Cells["PRD_MROLLCNT"].Value.ToString().Replace(",", ""), out iPRD_MROLLCNT);       // 실적권치수
                    int.TryParse(ugr.Cells["DISPO_MROLLCNT"].Value.ToString().Replace(",", ""), out iDISPO_MROLLCNT);   // 폐품권치수

                    if (iMIN_ROLLCNT > 0)
                    {
                        if (iMIN_ROLLCNT > (iMROLLCNT - (iPRD_MROLLCNT + iDISPO_MROLLCNT)))
                        {
                            iMIN_ROLLCNT = iMROLLCNT - (iPRD_MROLLCNT + iDISPO_MROLLCNT);
                        }
                    }
                    else
                    {
                        iMIN_ROLLCNT = iMROLLCNT - (iPRD_MROLLCNT + iDISPO_MROLLCNT);
                    }
                }
            }

            iPosROLLCNT = iMIN_ROLLCNT;         // 등록가능한 권치수
            if (iPosROLLCNT < 0)
            {
                iPosROLLCNT = 0;
            }

            gdROLLCNT = iPosROLLCNT;

            lblPF_ROLLCNT.Text = string.Format("{0:#,0}", gdROLLCNT);      // 실적등록할 권치수를 밀롤의 (계획권치수 - 실적권치수 - 폐품권치수) 중 가장 작은 값을 기본값으로 지정
            WgtCalculation();
        }

        private DataTable setReqWorkList(string sMRCOM_YN, string sJRCOM_YN, string sStartDate, string sEndDate, string sTM)
        {
            DataTable dtRtn = new DataTable();
            DataRow dtTempRow;
            DataTable dt = (DataTable)Grid3.DataSource;

            try
            {
                //테이블 컬럼명 작성
                dtRtn.Columns.Add(new DataColumn("WRK_ORDR_NO", typeof(string)));       //작업지시번호
                dtRtn.Columns.Add(new DataColumn("WRK_ORDR_SEQNO", typeof(string)));    //작업지시번호순번
                dtRtn.Columns.Add(new DataColumn("WIDTH", typeof(string)));             //생산실지폭
                dtRtn.Columns.Add(new DataColumn("WIDTH_NO", typeof(string)));          //지폭순번
                dtRtn.Columns.Add(new DataColumn("PRD_SEQ", typeof(string)));           //실적순서
                dtRtn.Columns.Add(new DataColumn("MRLDCK", typeof(string)));            //밀롤적치여부
                dtRtn.Columns.Add(new DataColumn("CUTTER", typeof(string)));            //재단
                dtRtn.Columns.Add(new DataColumn("ROLLCNT", typeof(string)));           //권치수
                dtRtn.Columns.Add(new DataColumn("WGT", typeof(string)));               //중량
                dtRtn.Columns.Add(new DataColumn("DISPO_CD", typeof(string)));          //폐품코드
                dtRtn.Columns.Add(new DataColumn("DISPO_ROLLCNT", typeof(string)));     //폐품권치수
                dtRtn.Columns.Add(new DataColumn("DISPO_WGT", typeof(string)));         //폐품중량
                dtRtn.Columns.Add(new DataColumn("CORE", typeof(string)));              //지관
                dtRtn.Columns.Add(new DataColumn("PRD_STR_DATE", typeof(string)));      //작업시작일시
                dtRtn.Columns.Add(new DataColumn("PRD_END_DATE", typeof(string)));      //작업종료일시
                dtRtn.Columns.Add(new DataColumn("TM", typeof(string)));                //가동시간(분)
                dtRtn.Columns.Add(new DataColumn("RMK", typeof(string)));               //비고
                dtRtn.Columns.Add(new DataColumn("JRCOM_YN", typeof(string)));          //점보롤 완료여부
                dtRtn.Columns.Add(new DataColumn("MRCOM_YN", typeof(string)));          //밀롤 완료여부
                dtRtn.Columns.Add(new DataColumn("IND_BCD_M", typeof(string)));         //점보롤 개별바코드
                dtRtn.Columns.Add(new DataColumn("MATRN_M", typeof(string)));           //점보롤 자재코드
                dtRtn.Columns.Add(new DataColumn("LOT_NO_M", typeof(string)));          //점보롤 LOT번호

                bool bInpLogWrite = false;
                string sValue;
                for (int i = 0; i < dt.Rows.Count; i++)
                {
                    //선택된 행처리
                    if (dt.Rows[i]["CHK"].ToString().Equals("V"))
                    {
                        //조회결과 입력용 Row생성
                        dtTempRow = dtRtn.NewRow();

                        //밀롤 중량
                        int nMWIDTH = 0;    //  지폭
                        Decimal dWGT = 0; //  밀롤 중량

                        //  밀롤 폐품 중량
                        Decimal dDISPO_WGT = 0; // 폐품 중량

                        //string sMWIDTH = dt.Rows[i]["MWIDTH_INPUT"].ToString().Replace(",", "");
                        string sMWIDTH = dt.Rows[i]["MWIDTH"].ToString().Replace(",", "");
                        if (int.TryParse(sMWIDTH, out nMWIDTH) == true)
                        {
                            if ((giBS_WGT > 0) && (gdROLLCNT > 0))
                            {
                                dWGT = ((Decimal)giBS_WGT / 1000) * ((Decimal)nMWIDTH / 1000) * (Decimal)gdROLLCNT;

                                if (dt.Rows[i]["NEXT_PROC"].ToString() == "ROLL")
                                {
                                    dWGT = Math.Round(dWGT);
                                }
                            }
                            if ((giBS_WGT > 0) && (gdDISPO_ROLLCNT > 0))
                            {
                                dDISPO_WGT = ((Decimal)giBS_WGT / 1000) * ((Decimal)nMWIDTH / 1000) * (Decimal)gdDISPO_ROLLCNT;
                            }
                        }

                        dtTempRow["WRK_ORDR_NO"] = dt.Rows[i]["WRK_ORDR_NO"].ToString();        //작업지시번호

                        sValue = dt.Rows[i]["WRK_ORDR_SEQNO"].ToString().Trim();
                        dtTempRow["WRK_ORDR_SEQNO"] = string.IsNullOrEmpty(sValue) ? "0" : sValue;  //작업지시번호순번 

                        sValue = dt.Rows[i]["MWIDTH_INPUT"].ToString().Trim().Replace(",", "");
                        if (string.IsNullOrEmpty(sValue))
                        {
                            sValue = dt.Rows[i]["MWIDTH"].ToString().Trim().Replace(",", "");
                        }
                        dtTempRow["WIDTH"] = string.IsNullOrEmpty(sValue) ? "0" : sValue;       //생산실지폭

                        dtTempRow["WIDTH_NO"] = dt.Rows[i]["WIDTH_NO"].ToString().Trim().Replace(",", "");              //지폭순번

                        sValue = dt.Rows[i]["PRD_SEQ"].ToString().Trim();
                        dtTempRow["PRD_SEQ"] = string.IsNullOrEmpty(sValue) ? "0" : sValue;         //실적순서

                        dtTempRow["MRLDCK"] = dt.Rows[i]["MRLDCK"].ToString() == "Y" ? "Y" : "N";   //밀롤적치여부

                        dtTempRow["CUTTER"] = dt.Rows[i]["CUTTER"].ToString();                      //재단

                        dtTempRow["ROLLCNT"] = string.Format("{0}", (int)gdROLLCNT);                //실적권치수  // ((int)gdROLLCNT).ToString();                     
                        dtTempRow["WGT"] = string.Format("{0:0.###}", dWGT);                        //밀롤별 중량   //dWGT.ToString();                                     
                        dtTempRow["DISPO_CD"] = lblPF_DISPO_CODE.Tag;                                  //폐품코드
                        dtTempRow["DISPO_ROLLCNT"] = string.Format("{0}", (int)gdDISPO_ROLLCNT);    //폐품권치수       //((int)gdDISPO_ROLLCNT).ToString();         
                        dtTempRow["DISPO_WGT"] = string.Format("{0:0.###}", dDISPO_WGT);            //밀롤별 폐품중량    /// dDISPO_WGT.ToString();                         
                        dtTempRow["CORE"] = Common.StrFormatInteger((string)ucCORE.Items[ucCORE.SelectedIndex].DataValue, "{0:###}");           //지관
                        dtTempRow["PRD_STR_DATE"] = sStartDate;                                     //작업시작일시
                        dtTempRow["PRD_END_DATE"] = sEndDate;                                       //작업종료일시
                        dtTempRow["TM"] = sTM;                                                      //가동시간(분)

                        string sRMK = dt.Rows[i]["ORDER_RMK"].ToString();

                        //if (sRMK == "-" || string.IsNullOrEmpty(sRMK))
                        //{
                            dtTempRow["RMK"] = lblPF_WRK_ORDR_RMK.Text.ToString();                         //비고
                        //}
                        //else
                        //{
                        //    dtTempRow["RMK"] = dt.Rows[i]["ORDER_RMK"].ToString();
                        //}

                        dtTempRow["JRCOM_YN"] = sJRCOM_YN;                                          //점보롤 완료여부
                        dtTempRow["MRCOM_YN"] = sMRCOM_YN;                                          //밀롤 완료여부
                        dtTempRow["IND_BCD_M"] = Grid1.Row.Cells["IND_BCD"].Value.ToString();       //점보롤 개별바코드
                        dtTempRow["MATRN_M"] = Grid1.Row.Cells["MATNR"].Value.ToString();          //점보롤 자재코드
                        dtTempRow["LOT_NO_M"] = Grid1.Row.Cells["LOT_NO"].Value.ToString();                          //점보롤 LOT번호

                        // 투입된 점보롤 정보 로그 출력
                        if (bInpLogWrite == false)
                        {
                            bInpLogWrite = true;
                            LogFile.WriteLog(string.Format("[점보롤 정보] IND_BCD_M = {0}, MATNR_M = {1}, LOT_NO_M = {2}",
                                                                        Grid1.Row.Cells["IND_BCD"].Value.ToString(),
                                                                        Grid1.Row.Cells["MATNR"].Value.ToString(),
                                                                        Grid1.Row.Cells["LOT_NO"].Value.ToString()),
                                                                        LogType.PROC);
                        }

                        //결과 테이블에 저장
                        dtRtn.Rows.Add(dtTempRow);
                    }
                }

                // 실적순서 별로 테이블 SORT 하여 리턴
                DataView dv = new DataView(dtRtn);
                dv.Sort = "PRD_SEQ ASC";
                dtRtn = dv.ToTable();
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return dtRtn;
        }


        /// <summary>
        /// 설비 및 작업자 선택여부 확인
        /// </summary>
        /// <param name="pType"></param>
        /// <returns></returns>
        private bool SettingCheck(string pType)
        {
            //설비 및 작업자 선택여부 확인
            if (pType.Contains("M") && string.IsNullOrEmpty(Common.MachineCode))
            {
                new POPUP.MessageForm("설비호기를 선택하여 주시기 바랍니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return false;
            }
            if (pType.Contains("W") && string.IsNullOrEmpty(Common.UserID))
            {
                new POPUP.MessageForm("작업자를 선택하여 주시기 바랍니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return false;
            }
            if (pType.Contains("O") && string.IsNullOrEmpty(lblIN_LOT_NO.Text.ToString()))
            {
                new POPUP.MessageForm("투입정보가 없습니다.\r\n작업지시 선택후 실적등록 하세요!", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return false;
            }

            //비가동 상태 확인
            if (pType.Contains("R") && lblMACH_STA.Text.Equals("비가동")) //가동중 여부 확인
            {
                new POPUP.MessageForm("비가동 중 입니다.\r\n지시 상태를 확인하여 주시기 바랍니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return false;
            }

            // 작업지시 선택 확인
            if (pType.Contains("C") && !lblMACH_STA.Text.Equals("대기중")) //자업지시 선택
            {
                new POPUP.MessageForm("대기중 상태가 아닙니다.\r\n작업 완료후 작업지시 선택하여 주시기 바랍니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return false;
            }

            //지시의 상태 구분
            if (pType.Contains("S") && !lblMACH_STA.Text.Equals("가동중")) //비가동(작업시작버튼 출력중)
            {
                new POPUP.MessageForm("가동중 상태가 아닙니다.\r\n지시 상태를 확인하여 주시기 바랍니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return false;
            }

            return true;
        }

        /// <summary>
        /// 작업지시 시작
        /// </summary>
        private void doConfirm()
        {
            DataSet dsRtn = new DataSet();

            DBHelper helper = new DBHelper(false);
            string sMSG = string.Empty;

            //팝업 변수
            POPUP.MessageForm msgForm = null;
            DialogResult res = DialogResult.Cancel;

            try
            {
                // 작업 시작일시 확인
                string sStartDate = dtpStartDate.Value.ToString("yyyyMMdd") + lblStartTime.Text.ToString().Replace(":", "") + "00";
                DateTime dtStartTime;
                if (DateTime.TryParseExact(sStartDate, "yyyyMMddHHmmss", null, DateTimeStyles.AssumeLocal, out dtStartTime) == false)
                {
                    new POPUP.MessageForm("작업 시작일시 확인하세요!", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return;
                }
                if (lblMACH_STA.Text.Equals("대기중"))
                {
                    msgForm = new POPUP.MessageForm("작업지시를 시작 하시겠습니까?", MessageBoxButtons.OKCancel, "알   림");
                    res = msgForm.ShowDialog(this);
                }
                else
                {
                    msgForm = new POPUP.MessageForm("작업지시를 대기중으로 변경 하시겠습니까?", MessageBoxButtons.OKCancel, "알   림");
                    res = msgForm.ShowDialog(this);
                }
                if (res == System.Windows.Forms.DialogResult.OK)
                {
                    //작업시작 (작업지시 상태변경 및 작업장 현황의 가동상태 변경)
                    helper.ExecuteNoneQuery("SP_POP_WRK25_I01", CommandType.StoredProcedure
                                                    , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)               // 플랜트
                                                    , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)           // 작업장코드(설비코드)
                                                    , helper.CreateParameter("P_SDATE", sStartDate, DbType.String, ParameterDirection.Input)           // 작업장코드(설비코드)
                                                    , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input)                 // 사용자ID
                                                    );

                    if (helper.RSCODE == "E")
                    {
                        new POPUP.MessageForm(helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                        this.DialogResult = DialogResult.OK;
                        return;
                    }

                    dsRtn = helper.FillDataSetN("SP_POP_WRK25_S01", CommandType.StoredProcedure, 5
                                    , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)                     // 플랜트코드
                                    , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)                  //작업장코드(설비코드)
                                    , helper.CreateParameter("RS_MACH_STA", DbType.String, ParameterDirection.Output, null, 30)                     //  RES MACH_STA 가동상태(R :가동, S:비가동, N:대기중)
                                    );

                    string sRS_MACH_STA = helper.Parameters["RS_MACH_STA"].Value.ToString();

                    if (sRS_MACH_STA == "R")
                    {
                        sMSG = "작업지시가 정상적으로 시작 되었습니다.";
                        new POPUP.MessageForm(sMSG, MessageBoxButtons.OK, "알   림").ShowDialog(this);

                        lblMACH_STA.Text = "가동중";

                        btnWaitFlag = false;

                        btnChange_Func();
                    }
                    else
                    {
                        sMSG = "작업지시가 대기처리 되었습니다.";
                        new POPUP.MessageForm(sMSG, MessageBoxButtons.OK, "알   림").ShowDialog(this);

                        btnWaitFlag = true;

                        lblMACH_STA.Text = "대기중";

                        btnChange_Func();

                        InitProduct();

                        SetCore();      // 지관 구하기

                        UpdateGrid();

                        lblMEndChk.BackColor = Color.Yellow;
                        lblPrintChk.BackColor = Color.Yellow;
                        lblPF_CHK_DISPO.BackColor = Color.Yellow;

                        lblPF_PRFM_DT.Text = "";
                        lblPF_ROLLCNT.Text = "";
                        lblPF_WGT.Text = "";
                    }

                    //lblMACH_STA.Text = "가동중";
                    //UpdateGrid();
                }
            }
            catch (Exception ex)
            {
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);

                //SetMessage("SetGrid Error!");
                LogFile.WriteLog("POP_WRK25.SetGrid Error => " + ex.Message);
            }
            finally
            {
                helper.Close();
            }
        }


        // 밀롤 완료플래그 처리 하지 않는경우, 
        // 전체 실적등록+폐품등록이 계획권치수 와 같거나 큰경우
        // 완료처리 없이 등록할지 재확인 함.
        private bool MRCompleteCheck()
        {
            int iMIN_PLAN_MR = 0;   // 계획권치수
            int iMIN_PRD_MR = 0;   // 실적 권치수 + 폐품권치수

            int iTOT_RCNT = 0;
            int iDISP_RCNT = 0;
            int.TryParse(lblPF_ROLLCNT.Text.ToString().Replace(",", ""), out iTOT_RCNT);      // 실적권치수
            int.TryParse(lblPF_DISPO_ROLLCNT.Text.ToString().Replace(",", ""), out iDISP_RCNT);   // 폐품권치수

            foreach (UltraGridRow ugr in Grid3.Rows)
            {
                if (ugr.Cells["CHK"].Value.ToString().Equals("V"))
                {
                    int iMROLLCNT = 0;          //계획권치수
                    int iPRD_MROLLCNT = 0;      // 실적권치수
                    int iDISPO_MROLLCNT = 0;    // 폐품권치수

                    int.TryParse(ugr.Cells["MROLLCNT"].Value.ToString().Replace(",", ""), out iMROLLCNT);               // 계획권치수
                    int.TryParse(ugr.Cells["PRD_MROLLCNT"].Value.ToString().Replace(",", ""), out iPRD_MROLLCNT);       // 실적권치수
                    int.TryParse(ugr.Cells["DISPO_MROLLCNT"].Value.ToString().Replace(",", ""), out iDISPO_MROLLCNT);   // 폐품권치수

                    // 계획권치수가 가장 작은값을 구함
                    if (iMIN_PLAN_MR == 0)
                    {
                        iMIN_PLAN_MR = iMROLLCNT;
                    }
                    else if (iMIN_PLAN_MR > iMROLLCNT)
                    {
                        iMIN_PLAN_MR = iMROLLCNT;
                    }

                    // 실적 권치수 + 폐품권치수 가장 작은값을 구함
                    if (iMIN_PRD_MR == 0)
                    {
                        iMIN_PRD_MR = (iPRD_MROLLCNT + iDISPO_MROLLCNT);
                    }
                    else if (iMIN_PRD_MR > (iPRD_MROLLCNT + iDISPO_MROLLCNT))
                    {
                        iMIN_PRD_MR = iPRD_MROLLCNT + iDISPO_MROLLCNT;
                    }
                }
            }

            if (iMIN_PLAN_MR <= (iMIN_PRD_MR + iTOT_RCNT + iDISP_RCNT))
            {
                return true;
            }
            else
            {
                return false;
            }
        }

        /// <summary>
        /// 밀롤 실적등록
        /// </summary>
        private int doProduct()
        {
            DataTable dtList;

            // 작업지시 확인
            if (string.IsNullOrEmpty(lblIN_LOT_NO.Text.ToString()))
            {
                new POPUP.MessageForm("투입정보가 없습니다.\r\n작업지시 선택후 실적등록 하세요!", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return Common.ERROR_FAIL;
            }

            // 선택된 밀롤 작업지시 확인
            int nSEL = 0;
            foreach (UltraGridRow ugr in Grid3.Rows)
            {
                if (ugr.Cells["CHK"].Value.ToString().Equals("V"))
                {
                    nSEL++;
                }
            }

            if (nSEL == 0)
            {
                new POPUP.MessageForm("실적 등록할 밀롤 작업지시를 선택 하세요!", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return Common.ERROR_FAIL;
            }

            //  실적등록 치수 확인
            if (lblPF_CHK_DISPO.Text == "V")
            {
                if ((gdROLLCNT == 0) && (gdDISPO_ROLLCNT == 0))
                {
                    new POPUP.MessageForm("실적 권치수 또는 폐품 권치수를 입력 하세요!", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return Common.ERROR_FAIL;
                }
            }
            else
            {
                if (gdROLLCNT == 0)
                {
                    new POPUP.MessageForm("실적 권치수를 입력 하세요!", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return Common.ERROR_FAIL;
                }
            }

            // 작업 시작일시, 종료일시 확인
            string sStartDate = dtpStartDate.Value.ToString("yyyyMMdd") + lblStartTime.Text.ToString().Replace(":", "") + "00";
            string sEndDate = dtpEndDate.Value.ToString("yyyyMMdd") + lblEndTime.Text.ToString().Replace(":", "") + "00";

            DateTime dtStartTime;
            if (DateTime.TryParseExact(sStartDate, "yyyyMMddHHmmss", null, DateTimeStyles.AssumeLocal, out dtStartTime) == false)
            {
                new POPUP.MessageForm("작업 시작일시 확인하세요!", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return Common.ERROR_FAIL;
            }

            DateTime dtEndTime;
            if (DateTime.TryParseExact(sEndDate, "yyyyMMddHHmmss", null, DateTimeStyles.AssumeLocal, out dtEndTime) == false)
            {
                new POPUP.MessageForm("작업 종료일시 확인하세요!", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return Common.ERROR_FAIL;
            }

            // 작업일시 확인
            if (string.IsNullOrEmpty(lblPF_PRFM_DT.Text.ToString()))
            {
                new POPUP.MessageForm("작업 시작일시~종료일시 입력을 확인하세요!", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return Common.ERROR_FAIL;
            }

            TimeSpan Diff_dates = dtEndTime.Subtract(dtStartTime);

            string sTM = "";    //가동시간(분)
            if (Diff_dates.TotalMinutes > 0)
            {
                sTM = Diff_dates.TotalMinutes.ToString();
            }
            else
            {
                new POPUP.MessageForm("작업 시작일시~종료일시 입력을 확인하세요!", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return Common.ERROR_FAIL;
            }

            // 계획권치수 보다 크게 실적을 잡을수 있는지 확인 필요!!!!!!!!


            //// 권치수 확인
            //Decimal.TryParse(lblPF_ROLLCNT.Text.ToString().Replace(",", ""), out gdROLLCNT);      // 등록할권치수 int
            //if (gdROLLCNT <= 0)
            //{
            //    new POPUP.MessageForm("권치수 입력은 필수 입니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
            //    return Common.ERROR_FAIL;
            //}

            // 지관 확인
            if (ucCORE.SelectedIndex < 0)
            {
                new POPUP.MessageForm("지관 선택은 필수 입니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return Common.ERROR_FAIL;
            }

            {
                Decimal dIN_AVA_WGT = 0;     // 가용량
                Decimal dPF_WGT = 0;
                Decimal dPF_DISPO_WGT = 0;


                Decimal dTOT_RCNT = 0;
                Decimal dDISP_RCNT = 0;
                Decimal.TryParse(lblPF_ROLLCNT.Text.ToString().Replace(",", ""), out dTOT_RCNT);      // 실적권치수
                Decimal.TryParse(lblPF_DISPO_ROLLCNT.Text.ToString().Replace(",", ""), out dDISP_RCNT);   // 폐품권치수


                if ((dTOT_RCNT + dDISP_RCNT) <= 0)
                {
                    new POPUP.MessageForm(string.Format("실적(폐품포함) 권치수 입력은 필수 입니다."), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return Common.ERROR_FAIL;
                }

                Decimal.TryParse(lblIN_AVA_WGT.Text.ToString().Replace(",", ""), out dIN_AVA_WGT);                       //
                Decimal.TryParse(lblPF_WGT.Text.ToString().Replace(",", ""), out dPF_WGT);                       //
                Decimal.TryParse(lblPF_DISPO_WGT.Text.ToString().Replace(",", ""), out dPF_DISPO_WGT);               //



                // 실적순서 확인
                bool bPrdSeqNull = false;
                foreach (UltraGridRow ugr in Grid3.Rows)
                {
                    if (ugr.Cells["CHK"].Value.ToString().Equals("V"))
                    {
                        if (string.IsNullOrEmpty(ugr.Cells["PRD_SEQ"].Value.ToString().Trim()))
                        {
                            bPrdSeqNull = true;
                            break;
                        }
                    }
                }

                if (bPrdSeqNull == true)
                {
                    // 실적이 있는경우만 실적순서를 필수 입력해야함. (폐품만 등록시에는 실적순서 체크 안함.)
                    if (dPF_WGT > 0)
                    {
                        new POPUP.MessageForm("밀롤 실적순서는 필수 입니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                        return Common.ERROR_FAIL;
                    }
                }

                if (dIN_AVA_WGT < (dPF_WGT + dPF_DISPO_WGT))
                {
                    //new POPUP.MessageForm(string.Format("실적(폐품포함) 중량 {0} (Kg)이 가용 중량 {1} (Kg)을\r\n초과하여 실적등록 할수 없습니다.\r\n\r\n실적(폐품포함) 연수 입력을 확인하세요!", (dPF_WGT + dPF_DISPO_WGT), dIN_AVA_WGT), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    new POPUP.MessageForm(string.Format("실적(폐품포함) 중량 값이 가용 중량 {0} (Kg)을 초과하여\r\n입력되었습니다.\r\n\r\n실적(폐품포함) 권치수 입력을 확인하세요!", dIN_AVA_WGT), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return Common.ERROR_FAIL;
                }
            }

            string sMRCOM_YN = "N";

            POPUP.MessageForm msgForm;
            msgForm = new POPUP.MessageForm("밀롤 완료 플래그를 체크 하시겠습니까?", MessageBoxButtons.YesNoCancel, "알  림");

            DialogResult dr = msgForm.ShowDialog(this);
            if (dr == DialogResult.Cancel)
            {
                return Common.ERROR_FAIL;
            }
            else if (dr == DialogResult.Yes)
            {
                sMRCOM_YN = "Y";
            }
            else
            {
                if (MRCompleteCheck() == true)
                {
                    msgForm = new POPUP.MessageForm("실적 등록후 남은 작업이 없어 완료 플래그를 체크해야 합니다.\r\n\r\n밀롤 완료 플래그를 체크 하시겠습니까?", MessageBoxButtons.OKCancel, "알  림");

                    dr = msgForm.ShowDialog(this);
                    if (dr == DialogResult.OK)
                    {
                        sMRCOM_YN = "Y";
                    }
                    else
                    {
                        return Common.ERROR_FAIL;
                    }
                }
            }

            string sJRCOM_YN = "N";      // 점보롤 완료처리
            // 밀롤완료 처리 되고, 밀롤 작업이 한개 남은경우는 점보롤 완료처리함.
            if (sMRCOM_YN.Equals("Y"))
            {
                // 밀롤 완료 인 경우, 지시번호가 한개 남은경우, 점보롤 완료 처리
                if (Grid2.Rows.Count == 1)
                {
                    DataTable dt = (DataTable)Grid3.DataSource;


                    // 지시번호가 한개 남은경우, 남은 밀롤 작업지시의 선택된 개수가 모두 선택된경우만 점보롤 완료처리함.
                    int MR_CHK_CNT = 0;
                    for (int i = 0; i < dt.Rows.Count; i++)
                    {
                        if (dt.Rows[i]["CHK"].ToString().Equals("V"))
                        {
                            MR_CHK_CNT++;
                        }
                    }

                    if (dt.Rows.Count == MR_CHK_CNT)
                    {
                        sJRCOM_YN = "Y";    //  점보롤 완료 처리
                    }
                }
            }


            // 0실적 체크용
            bool bZERO_PRFM = false;

            if (sJRCOM_YN == "Y")
            {
                Decimal dPF_WGT = 0;
                Decimal dPF_DISPO_WGT = 0;

                Decimal.TryParse(lblPF_WGT.Text.ToString().Replace(",", ""), out dPF_WGT);                       //
                Decimal.TryParse(lblPF_DISPO_WGT.Text.ToString().Replace(",", ""), out dPF_DISPO_WGT);               //

                if ((dPF_WGT == 0) && (dPF_DISPO_WGT > 0))
                {
                    //new POPUP.MessageForm(string.Format("폐품만 등록하여 작업 완료 처리 할수 없습니다.\r\n\r\n작업을 완료 하려면 실적을 추가 하세요."), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    //return Common.ERROR_FAIL;
                    bZERO_PRFM = true;
                }
            }

            LogFile.WriteLog("밀롤 실적 등록 시작", LogType.PROC);

            dtList = setReqWorkList(sMRCOM_YN, sJRCOM_YN, sStartDate, sEndDate, sTM);
            string sJsonWrkList = Common.toJsonFormat("POP_WRK025", dtList);

            DBHelper helper = new DBHelper(false, "", true);

            DataSet dsTemp = new DataSet();     //실적등록 결과 수신(0:실적 RFC ID, 1:실적 IF 변수, 2:실적 RFC ID, 3:실적 IF 변수)
            bool bReturn = false;           // 실적
            bool bRetDISPO = false;         // 폐품
            bool bRetSALES_DISPO = false;   // 영업폐품
            bool bRetINP = false;     // 투입량

            string sRES_IND_BCD = "";

            string sMSG_ERR = "";

            int RET_CODE = Common.ERROR_RFC_FAIL;

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

                LogFile.WriteLog("밀롤 실적 등록 시작", LogType.PROC);

                // 2022-11-12 : 프로시저명 수정 - 폐품만등록시 0실적 처리 부분 추가한 프로시저
                // 2022-12-08 : 프로시저명 원복 - SP_POP_WRK01_I02
                dsTemp = helper.FillDataSetN("SP_POP_WRK25_I02", CommandType.StoredProcedure, 8
                            , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)                  // 플랜트
                            , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)              // 작업장코드(설비코드)
                            , helper.CreateParameterOracle("P_WRK_LIST", sJsonWrkList, OracleDbType.Clob, ParameterDirection.Input)         // 밀롤 실적등록 리스트
                            , helper.CreateParameter("P_WRK_CLASS", Common.WorkClass, DbType.String, ParameterDirection.Input)              // 작업반
                            , helper.CreateParameter("P_WRK_SHIFT", Common.WorkShift, DbType.String, ParameterDirection.Input)              // 작업조
                            , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input)                    // 사용자ID
                            , helper.CreateParameter("RS_PRFM_RFCFN", DbType.String, ParameterDirection.Output, null, 200)                  // 실적 RFCFN ID값
                            , helper.CreateParameter("RS_DISPO_RFCFN", DbType.String, ParameterDirection.Output, null, 200)                 // 폐품 RFCFN ID값
                            , helper.CreateParameter("RS_INPUT_RFCFN", DbType.String, ParameterDirection.Output, null, 200)                 // 투입량 RFCFN ID값
                            , helper.CreateParameter("RS_SDISPO_RFCFN", DbType.String, ParameterDirection.Output, null, 200)                // 영업폐품 RFCFN ID값
                            , helper.CreateParameter("RS_IND_BCD", DbType.String, ParameterDirection.Output, null, 2000)                    // RES 개별바코드 
                        );

                if (helper.RSCODE == "S")
                {
                    sRES_IND_BCD = helper.Parameters["RS_IND_BCD"].Value.ToString();                  // RES 개별바코드 

                    string sRS_PRFM_RFCFN = helper.Parameters["RS_PRFM_RFCFN"].Value.ToString();      // 실적 RFCFN ID
                    string sRS_DISPO_RFCFN = helper.Parameters["RS_DISPO_RFCFN"].Value.ToString();    // 폐품 RFCFN ID
                    string sRS_INPUT_RFCFN = helper.Parameters["RS_INPUT_RFCFN"].Value.ToString();    // 투입량 RFCFN ID
                    string sRS_SDISPO_RFCFN = helper.Parameters["RS_SDISPO_RFCFN"].Value.ToString();  // 영업폐품 RFCFN ID

                    //SAP 롤백용 추가 CODE 범위 START
                    if (dsTemp.Tables[1].Columns[0].ColumnName != "1"  && bZERO_PRFM == false)
                    {
                        // 실적테이블에 정보가 있고, 0실적이 아닌경우
                        foreach (DataRow Rows in dsTemp.Tables[1].Rows)
                        {
                            string rollTempMDOC_NO_1 = Rows["MDOCNO"].ToString();
                            string rollTempMDOC_SEQNO_1 = Rows["MDOCSEQ"].ToString();
                            rollTemp.Rows.Add(rollTempMDOC_NO_1, rollTempMDOC_SEQNO_1);
                        }
                    }
                    //밀롤의 경우 실적과 폐품 개별바코드가 동일하여 else 로 처리 함, 폐품만 등록시 MES롤백을 위한 문서번호 저장 추가
                    else if (dsTemp.Tables[3].Columns[0].ColumnName != "1")
                    {
                        // 실적테이블에 정보가 있고, 0실적이 아닌경우
                        foreach (DataRow Rows in dsTemp.Tables[3].Rows)
                        {
                            string rollTempMDOC_NO_1 = Rows["MDOCNO"].ToString();
                            string rollTempMDOC_SEQNO_1 = Rows["MDOCSEQ"].ToString();
                            rollTemp.Rows.Add(rollTempMDOC_NO_1, rollTempMDOC_SEQNO_1);
                        }
                    }
                    //SAP 롤백용 추가 CODE 범위 END


                    //dsTemp.Tables[0];     // 실적 인터페이스 파라미터
                    //dsTemp.Tables[1];     // 실적 인터페이스 상세 파라미터
                    //dsTemp.Tables[2];     // 폐품 인터페이스 파라미터
                    //dsTemp.Tables[3];     // 폐품 인터페이스 상세 파라미터
                    //dsTemp.Tables[4];     // 투입량 인터페이스 파라미터
                    //dsTemp.Tables[5];     // 투입량 인터페이스 상세 파라미터
                    //dsTemp.Tables[6];     // 영업폐품 인터페이스 파라미터
                    //dsTemp.Tables[7];     // 영업폐품 인터페이스 상세 파라미터

#if false
                    helper.Rollback();
                    return Common.ERROR_FAIL;
#endif
                    string sRfcData; //RFC결과 JSON 변환

                    bReturn = false;

                    // 1. 실적 등록 (밀롤 완료 플래그 때문에 마지막에 보냄)
                    if (string.IsNullOrEmpty(sRS_PRFM_RFCFN) == false)
                    {
                        // 문서번호, 문서순번으로  테이블 SORT 하여 전달
                        DataTable dtRFCData = new DataTable();
                        DataView dvPFRM = new DataView(dsTemp.Tables[1]);
                        dvPFRM.Sort = "MDOCNO, MDOCSEQ ASC";
                        dtRFCData = dvPFRM.ToTable();

                        //SAP 실적 등록
                        SAPHelper sapRFC_P = new SAPHelper();
                        // sapRFC.CallSAPFunc 호출시 helper를 사용하여 내용이 변경됨. 
                        // 필요한 정보는 sapRFC.CallSAPFunc 호출전에 처리해야함.
                        if (sapRFC_P.CallSAPFunc_PS(sRS_PRFM_RFCFN, dsTemp.Tables[0], dtRFCData, helper).Equals("S"))
                        {
                            // ---- 전달시 MBLNR, MJAHR을 replace 처리하여 하나로 받도록함.
                            sRfcData = Common.toJsonFormat("PUT_WRKRTN", sapRFC_P.rtnTable).Replace("MBLNR", "RUECK").Replace("MJAHR", "RMZHL");

                            // 0실적이 아닌경우 문서번호 저장
                            if(bZERO_PRFM == false)
                            {
                                //SAP 롤백용 추가 CODE 범위 START
                                string sTempSAP_TYPE = string.Empty;
                                string sTempIF_KEY = string.Empty;
                                string sTempMDOC_NO = string.Empty;
                                string sTempMDOC_SEQNO = string.Empty;

                                sTempSAP_TYPE = "3.PROD_REG_SAP";
                                sTempIF_KEY = dsTemp.Tables[0].Rows[0]["I_IF_KEY"].ToString();
                                foreach (DataRow Rows in dsTemp.Tables[1].Rows)
                                {
                                    sTempMDOC_NO = Rows["MDOCNO"].ToString();
                                    sTempMDOC_SEQNO = Rows["MDOCSEQ"].ToString();
                                    sapTemp.Rows.Add(sTempSAP_TYPE, sTempIF_KEY, sTempMDOC_NO, sTempMDOC_SEQNO); // 후단 코드 실행시 EXCEPTION 상황 SAP CANCLE 정보 -- 실적등록
                                }
                                //SAP 롤백용 추가 CODE 범위 END
                            }

                            //실적등록 테이블에 확정문서 번호 갱신
                            helper.ExecuteNoneQuery("SP_IF_PUT_WRKRTN", CommandType.StoredProcedure
                                                                , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)          // 플랜트
                                                                , helper.CreateParameter("P_WRK_TYPE", "0", DbType.String, ParameterDirection.Input)                    // '0'= 실적테이블_비계획생산, '1'= 폐품테이블, '2'=소요량, '3'=비가동
                                                                , helper.CreateParameterOracle("P_RFC_DATA", sRfcData, OracleDbType.Clob, ParameterDirection.Input)
                                                                , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input));
                            if (helper.RSCODE == "S")
                            {
                                bReturn = true;
                            }
                            else if (helper.RSCODE == "E")
                            {
                                //helper.Rollback();
                                LogFile.WriteLog("밀롤 실적 등록 - SAP 확정문서 등록 오류 [" + helper.RSMSG.ToString() + "]");
                                LogFile.WriteLog("@@@ else if 밀롤 실적 등록 - SAP 확정문서 등록 오류 [ 개별바코드 : " + sRES_IND_BCD + "]");
                                sMSG_ERR += "확정문서 등록 오류 : " + helper.RSMSG.ToString() + Environment.NewLine;
                                //new POPUP.MessageForm("실적 등록 - SAP 확정문서 등록 오류\r\n" + helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                throw new Exception("SAP_ERROR " + sMSG_ERR);  // SAP 로직 진행중 E 발생시 EXCEPTION THROW

                            }
                            else
                            {
                                //helper.Rollback();
                                LogFile.WriteLog("밀롤 실적 등록 - SAP 확정문서 등록 오류 [" + helper.RSMSG.ToString() + "]");
                                LogFile.WriteLog("@@@ else 밀롤 실적 등록 - SAP 확정문서 등록 오류 [ 개별바코드 : " + sRES_IND_BCD + "]");
                                sMSG_ERR += "확정문서 등록 오류 : " + helper.RSMSG.ToString() + Environment.NewLine;
                                //new POPUP.MessageForm("실적 등록 - SAP 확정문서 등록 오류\r\n" + helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                throw new Exception("SAP_ERROR " + sMSG_ERR);  // SAP 로직 진행중 E 발생시 EXCEPTION THROW

                            }
                        }
                        else
                        {
                            //helper.Rollback();

                            //SAP 롤백용 추가 CODE 범위 START
                            string sTempSAP_TYPE = string.Empty;
                            string sTempIF_KEY = string.Empty;
                            string sTempMDOC_NO = string.Empty;
                            string sTempMDOC_SEQNO = string.Empty;

                            sTempSAP_TYPE = "3.PROD_REG_SAP";
                            sTempIF_KEY = dsTemp.Tables[0].Rows[0]["I_IF_KEY"].ToString();

                            foreach (DataRow rtnRows in sapRFC_P.rtnTable.Rows)
                            {
                                if (rtnRows["TYPE"].ToString() == "S")
                                {
                                    sapTemp.Rows.Add(sTempSAP_TYPE, sTempIF_KEY, rtnRows["MDOCNO"].ToString(), rtnRows["MDOCSEQ"].ToString()); // 후단 코드 실행시 EXCEPTION 상황 SAP CANCLE 정보 -- 실적등록
                                }
                            }
                            //SAP 롤백용 추가 CODE 범위 END

                            LogFile.WriteLog("밀롤 실적 등록 - SAP 전송 실패 [" + sapRFC_P.rtnMSG + "]");
                            LogFile.WriteLog("@@@ else 밀롤 실적 등록 - SAP 전송 실패 [ 개별바코드 : " + sRES_IND_BCD + "]");
                            sMSG_ERR += "실적 등록 오류 : " + sapRFC_P.rtnMSG + Environment.NewLine;
                            //new POPUP.MessageForm("실적 등록 - SAP전송이 실패하였습니다.\r\n" + sapRFC_P.rtnMSG, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                            throw new Exception("SAP_ERROR " + sMSG_ERR);  // SAP 로직 진행중 E 발생시 EXCEPTION THROW

                        }

                        Thread.Sleep(Common.SLEEP_DELAY);
                        System.Windows.Forms.Application.DoEvents();        // 반복작업중 응답없음 안뜨게 하기
                        this.Cursor = Cursors.WaitCursor;   //Waitting
                    }
                    else
                    {
                        bReturn = true;
                    }

                    // 2. 폐품 등록
                    if ((bReturn == true) && (string.IsNullOrEmpty(sRS_DISPO_RFCFN) == false))
                    {
                        bRetDISPO = false;

                        // 문서번호, 문서순번으로  테이블 SORT 하여 전달
                        DataTable dtRFCData = new DataTable();
                        DataView dvPFRM = new DataView(dsTemp.Tables[3]);
                        dvPFRM.Sort = "MDOCNO, MDOCSEQ ASC";
                        dtRFCData = dvPFRM.ToTable();

                        SAPHelper sapRFC_D = new SAPHelper();
                        // sapRFC.CallSAPFunc 호출시 helper를 사용하여 내용이 변경됨. 
                        // 필요한 정보는 sapRFC.CallSAPFunc 호출전에 처리해야함.
                        if (sapRFC_D.CallSAPFunc_PS(sRS_DISPO_RFCFN, dsTemp.Tables[2], dtRFCData, helper).Equals("S"))
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
                            foreach (DataRow Rows in dsTemp.Tables[3].Rows)
                            {
                                sTempMDOC_NO = Rows["MDOCNO"].ToString();
                                sTempMDOC_SEQNO = Rows["MDOCSEQ"].ToString();
                                sapTemp.Rows.Add(sTempSAP_TYPE, sTempIF_KEY, sTempMDOC_NO, sTempMDOC_SEQNO); // 후단 코드 실행시 EXCEPTION 상황 SAP CANCLE 정보 -- 실적등록
                            }

                            //SAP 롤백용 추가 CODE 범위 END

                            //실적등록 테이블에 확정문서 번호 갱신
                            helper.ExecuteNoneQuery("SP_IF_PUT_WRKRTN", CommandType.StoredProcedure
                                                                , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)          // 플랜트
                                                                , helper.CreateParameter("P_WRK_TYPE", "1", DbType.String, ParameterDirection.Input)                    // '0'= 실적테이블_비계획생산, '1'= 폐품테이블, '2'=소요량, '3'=비가동, '9'=영업폐품, 잔량폐품
                                                                , helper.CreateParameterOracle("P_RFC_DATA", sRfcData, OracleDbType.Clob, ParameterDirection.Input)
                                                                , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input));

                            if (helper.RSCODE == "S")
                            {
                                bRetDISPO = true;
                            }
                            else //if (helper.RSCODE == "E")
                            {
                                //helper.Rollback();    // 실적이 성공이면 rollback 처리 안함.
                                LogFile.WriteLog("밀롤 실적 등록(폐품) - SAP 확정문서 등록 오류 [" + helper.RSMSG.ToString() + "]");
                                LogFile.WriteLog("@@@ else 밀롤 실적 등록(폐품) - SAP 확정문서 등록 오류 [ 개별바코드 : " + sRES_IND_BCD + "]");
                                sMSG_ERR += "확정문서 등록(폐품) 오류 : " + helper.RSMSG.ToString() + Environment.NewLine;
                                throw new Exception("SAP_ERROR " + sMSG_ERR);  // SAP 로직 진행중 E 발생시 EXCEPTION THROW

                                //new POPUP.MessageForm("실적 등록(폐품) - SAP 확정문서 등록 오류\r\n" + helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                            }
                        }
                        else
                        {
                            //SAP 롤백용 추가 CODE 범위 START
                            string sTempSAP_TYPE = string.Empty;
                            string sTempIF_KEY = string.Empty;
                            string sTempMDOC_NO = string.Empty;
                            string sTempMDOC_SEQNO = string.Empty;

                            sTempSAP_TYPE = "2.SALV_REG_SAP";
                            sTempIF_KEY = dsTemp.Tables[2].Rows[0]["I_IF_KEY"].ToString();

                            foreach (DataRow rtnRows in sapRFC_D.rtnTable.Rows)
                            {
                                if (rtnRows["TYPE"].ToString() == "S")
                                {
                                    sapTemp.Rows.Add(sTempSAP_TYPE, sTempIF_KEY, rtnRows["MDOCNO"].ToString(), rtnRows["MDOCSEQ"].ToString()); // 후단 코드 실행시 EXCEPTION 상황 SAP CANCLE 정보 -- 실적등록
                                }
                            }
                            //SAP 롤백용 추가 CODE 범위 END


                            //helper.Rollback();    // 실적이 성공이면 rollback 처리 안함.
                            LogFile.WriteLog("밀롤 실적 등록(폐품) - SAP전송 오류 [" + sapRFC_D.rtnMSG + "]");
                            LogFile.WriteLog("@@@ else 밀롤 실적 등록(폐품) - SAP전송 오류 [ 개별바코드 : " + sRES_IND_BCD + "]");
                            sMSG_ERR += "실적 등록(폐품) 오류 : " + sapRFC_D.rtnMSG + Environment.NewLine;
                            throw new Exception("SAP_ERROR " + sMSG_ERR);  // SAP 로직 진행중 E 발생시 EXCEPTION THROW

                            //new POPUP.MessageForm("밀롤 실적 등록(폐품) - SAP전송이 실패하였습니다.\r\n" + sapRFC_D.rtnMSG, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                        }
                        Thread.Sleep(Common.SLEEP_DELAY);
                        System.Windows.Forms.Application.DoEvents();        // 반복작업중 응답없음 안뜨게 하기
                        this.Cursor = Cursors.WaitCursor;   //Waitting
                    }
#if true
                    // 3. 영업 폐품 등록
                    if ((bReturn == true) && (string.IsNullOrEmpty(sRS_SDISPO_RFCFN) == false))
                    {
                        bRetSALES_DISPO = false;

                        SAPHelper sapRFC_SD = new SAPHelper();
                        // sapRFC.CallSAPFunc 호출시 helper를 사용하여 내용이 변경됨. 
                        // 필요한 정보는 sapRFC.CallSAPFunc 호출전에 처리해야함.
                        if (sapRFC_SD.CallSAPFunc_PS(sRS_SDISPO_RFCFN, dsTemp.Tables[6], dsTemp.Tables[7], helper).Equals("S"))
                        {
                            // ---- 전달시 MBLNR, MJAHR을 replace 처리하여 하나로 받도록함.
                            sRfcData = Common.toJsonFormat("PUT_WRKRTN", sapRFC_SD.rtnTable).Replace("MBLNR", "RUECK").Replace("MJAHR", "RMZHL");

                            //SAP 롤백용 추가 CODE 범위 START
                            string sTempSAP_TYPE = string.Empty;
                            string sTempIF_KEY = string.Empty;
                            string sTempMDOC_NO = string.Empty;
                            string sTempMDOC_SEQNO = string.Empty;

                            sTempSAP_TYPE = "1.SALE_SALV_REG_SAP";
                            sTempIF_KEY = dsTemp.Tables[6].Rows[0]["I_IF_KEY"].ToString();
                            foreach (DataRow Rows in dsTemp.Tables[7].Rows)
                            {
                                sTempMDOC_NO = Rows["MDOCNO"].ToString();
                                sTempMDOC_SEQNO = Rows["MDOCSEQ"].ToString();
                                sapTemp.Rows.Add(sTempSAP_TYPE, sTempIF_KEY, sTempMDOC_NO, sTempMDOC_SEQNO); // 후단 코드 실행시 EXCEPTION 상황 SAP CANCLE 정보 -- 실적등록
                            }
                            //SAP 롤백용 추가 CODE 범위 END

                            //실적등록 테이블에 확정문서 번호 갱신
                            helper.ExecuteNoneQuery("SP_IF_PUT_WRKRTN", CommandType.StoredProcedure
                                                                , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)        // 플랜트
                                                                , helper.CreateParameter("P_WRK_TYPE", "9", DbType.String, ParameterDirection.Input)                  // '0'= 실적테이블_비계획생산, '1'= 폐품테이블, '2'=소요량, '3'=비가동
                                                                , helper.CreateParameterOracle("P_RFC_DATA", sRfcData, OracleDbType.Clob, ParameterDirection.Input)
                                                                , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input));

                            if (helper.RSCODE == "S")
                            {
                                bRetSALES_DISPO = true;
                            }
                            else //if (helper.RSCODE == "E")
                            {
                                //helper.Rollback();
                                LogFile.WriteLog("밀롤 실적 등록(영업폐품) - SAP 확정문서 등록 오류 [" + helper.RSMSG.ToString() + "]");
                                LogFile.WriteLog("@@@ else 밀롤 실적 등록(영업폐품) - SAP 확정문서 등록 오류 [ 개별바코드 : " + sRES_IND_BCD + " ]");
                                sMSG_ERR += "확정문서 등록(잔량 폐품) 오류 : " + helper.RSMSG.ToString() + Environment.NewLine;
                                //new POPUP.MessageForm("실적 등록(영업폐품) - SAP 확정문서 등록 오류\r\n" + helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                throw new Exception("SAP_ERROR " + sMSG_ERR);
                            }
                            Thread.Sleep(Common.SLEEP_DELAY);
                            System.Windows.Forms.Application.DoEvents();        // 반복작업중 응답없음 안뜨게 하기
                            this.Cursor = Cursors.WaitCursor;   //Waitting
                        }
                        else
                        {

                            //SAP 롤백용 추가 CODE 범위 START
                            string sTempSAP_TYPE = string.Empty;
                            string sTempIF_KEY = string.Empty;
                            string sTempMDOC_NO = string.Empty;
                            string sTempMDOC_SEQNO = string.Empty;

                            sTempSAP_TYPE = "1.SALE_SALV_REG_SAP";
                            sTempIF_KEY = dsTemp.Tables[6].Rows[0]["I_IF_KEY"].ToString();

                            foreach (DataRow rtnRows in sapRFC_SD.rtnTable.Rows)
                            {
                                if (rtnRows["TYPE"].ToString() == "S")
                                {
                                    sapTemp.Rows.Add(sTempSAP_TYPE, sTempIF_KEY, rtnRows["MDOCNO"].ToString(), rtnRows["MDOCSEQ"].ToString()); // 후단 코드 실행시 EXCEPTION 상황 SAP CANCLE 정보 -- 실적등록
                                }
                            }
                            //SAP 롤백용 추가 CODE 범위 END

                            //helper.Rollback();
                            LogFile.WriteLog("밀롤 실적 등록(영업폐품) - SAP전송 오류 [" + sapRFC_SD.rtnMSG + " ]");
                            LogFile.WriteLog("@@@ else 밀롤 실적 등록(영업폐품) - SAP전송 오류 [ 개별바코드 : " + sRES_IND_BCD + " ]");
                            sMSG_ERR += "실적 등록(잔량 폐품) 오류 : " + sapRFC_SD.rtnMSG + Environment.NewLine;
                            //new POPUP.MessageForm("실적 등록(영업폐품) - SAP전송이 실패하였습니다.\r\n" + sapRFC_SD.rtnMSG, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                            throw new Exception("SAP_ERROR " + sMSG_ERR);
                        }
                    }
#endif

                    // 4. 투입량 등록
                    if ((bReturn == true) && (string.IsNullOrEmpty(sRS_INPUT_RFCFN) == false))
                    {
                        bRetINP = false;

                        // 문서번호, 문서순번으로  테이블 SORT 하여 전달
                        DataTable dtRFCData = new DataTable();
                        DataView dvPFRM = new DataView(dsTemp.Tables[5]);
                        dvPFRM.Sort = "MDOCNO, MDOCSEQ ASC";
                        dtRFCData = dvPFRM.ToTable();

                        SAPHelper sapRFC_I = new SAPHelper();
                        // sapRFC.CallSAPFunc 호출시 helper를 사용하여 내용이 변경됨. 
                        // 필요한 정보는 sapRFC.CallSAPFunc 호출전에 처리해야함.
                        if (sapRFC_I.CallSAPFunc_PS(sRS_INPUT_RFCFN, dsTemp.Tables[4], dtRFCData, helper).Equals("S"))
                        {
                            // ---- 전달시 MBLNR, MJAHR을 replace 처리하여 하나로 받도록함.
                            sRfcData = Common.toJsonFormat("PUT_WRKRTN", sapRFC_I.rtnTable).Replace("MBLNR", "RUECK").Replace("MJAHR", "RMZHL");

                            //SAP 롤백용 추가 CODE 범위 START
                            string sTempSAP_TYPE = string.Empty;
                            string sTempIF_KEY = string.Empty;
                            string sTempMDOC_NO = string.Empty;
                            string sTempMDOC_SEQNO = string.Empty;

                            sTempSAP_TYPE = "4.WIP_REG_SAP";
                            sTempIF_KEY = dsTemp.Tables[4].Rows[0]["I_IF_KEY"].ToString();
                            foreach (DataRow Rows in dsTemp.Tables[5].Rows)
                            {
                                sTempMDOC_NO = Rows["MDOCNO"].ToString();
                                sTempMDOC_SEQNO = Rows["MDOCSEQ"].ToString();
                                sapTemp.Rows.Add(sTempSAP_TYPE, sTempIF_KEY, sTempMDOC_NO, sTempMDOC_SEQNO); // 후단 코드 실행시 EXCEPTION 상황 SAP CANCLE 정보 -- 실적등록
                            }
                            //SAP 롤백용 추가 CODE 범위 END

                            //실적등록 테이블에 확정문서 번호 갱신
                            helper.ExecuteNoneQuery("SP_IF_PUT_WRKRTN", CommandType.StoredProcedure
                                                                , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)                // 플랜트
                                                                , helper.CreateParameter("P_WRK_TYPE", "2", DbType.String, ParameterDirection.Input)                  // '0'= 실적테이블_비계획생산, '1'= 폐품테이블, '2'=소요량, '3'=비가동
                                                                , helper.CreateParameterOracle("P_RFC_DATA", sRfcData, OracleDbType.Clob, ParameterDirection.Input)
                                                                , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input));

                            if (helper.RSCODE == "S")
                            {
                                bRetINP = true;
                            }
                            else if (helper.RSCODE == "E")
                            {
                                LogFile.WriteLog("밀롤 실적 등록(투입량) - SAP 확정문서 등록 오류 [" + helper.RSMSG.ToString() + " ]");
                                LogFile.WriteLog("@@@ else if 밀롤 실적 등록(투입량) - SAP 확정문서 등록 오류 [ 개별바코드 : " + sRES_IND_BCD + " ]");
                                sMSG_ERR += "확정문서 등록(투입량) 오류 : " + helper.RSMSG.ToString() + Environment.NewLine;
                                //new POPUP.MessageForm("실적 등록(투입량) - SAP 확정문서 등록 오류\r\n" + helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                throw new Exception("SAP_ERROR " + sMSG_ERR);
                            }
                            else
                            {
                                LogFile.WriteLog("밀롤 실적 등록(투입량) - SAP 확정문서 등록 오류 [" + helper.RSMSG.ToString() + " ]");
                                LogFile.WriteLog("@@@ else 밀롤 실적 등록(투입량) - SAP 확정문서 등록 오류 [ 개별바코드 : " + sRES_IND_BCD + " ]");
                                sMSG_ERR += "확정문서 등록(투입량) 오류 : " + helper.RSMSG.ToString() + Environment.NewLine;
                                //new POPUP.MessageForm("실적 등록(투입량) - SAP 확정문서 등록 오류\r\n" + helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                throw new Exception("SAP_ERROR " + sMSG_ERR);
                            }
                        }
                        else
                        {
                            //SAP 롤백용 추가 CODE 범위 START
                            string sTempSAP_TYPE = string.Empty;
                            string sTempIF_KEY = string.Empty;
                            string sTempMDOC_NO = string.Empty;
                            string sTempMDOC_SEQNO = string.Empty;

                            sTempSAP_TYPE = "4.WIP_REG_SAP";
                            sTempIF_KEY = dsTemp.Tables[4].Rows[0]["I_IF_KEY"].ToString();

                            foreach (DataRow rtnRows in sapRFC_I.rtnTable.Rows)
                            {
                                if (rtnRows["TYPE"].ToString() == "S")
                                {
                                    sapTemp.Rows.Add(sTempSAP_TYPE, sTempIF_KEY, rtnRows["MDOCNO"].ToString(), rtnRows["MDOCSEQ"].ToString()); // 후단 코드 실행시 EXCEPTION 상황 SAP CANCLE 정보 -- 실적등록
                                }
                            }
                            //SAP 롤백용 추가 CODE 범위 END


                            LogFile.WriteLog("밀롤 실적 등록(투입량) - SAP전송 오류 [" + sapRFC_I.rtnMSG + " ]");
                            LogFile.WriteLog("@@@ else 밀롤 실적 등록(투입량) - SAP전송 오류 [ 개별바코드 : " + sRES_IND_BCD+ " ]");
                            sMSG_ERR += "실적 등록(투입량) 오류 : " + sapRFC_I.rtnMSG + Environment.NewLine;
                            //new POPUP.MessageForm("실적 등록(투입량) - SAP전송이 실패하였습니다.\r\n" + sapRFC_I.rtnMSG, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                            throw new Exception("SAP_ERROR " + sMSG_ERR);
                        }
                    }
                }
                else //if (helper.RSCODE == "E")
                {
                    this.Cursor = Cursors.Default;   //Waitting

                    //helper.Rollback();
                    LogFile.WriteLog("밀롤 실적 등록 실패 [" + helper.RSMSG.ToString() + " ]");
                    LogFile.WriteLog("@@@ else 밀롤 실적 등록 실패 [ 개별바코드 : " + sRES_IND_BCD + " ]");
                    new POPUP.MessageForm("실적 등록 실패\r\n" + helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return Common.ERROR_RFC_FAIL;
                }

                //if (bReturn == true)
                {
                    //helper.Commit();
                    if (lblPrintChk.Text.ToString() == "V")     // 자동인쇄 처리
                    {
                        int nPrtRollCnt = 2;
                        int nPrtSheetCnt = 1;
                        if (ucPNT_TYPE.SelectedIndex == 0)
                        {
                            nPrtRollCnt = 2;
                            nPrtSheetCnt = 1;
                        }
                        else
                        {
                            nPrtRollCnt = ucPNT_TYPE.SelectedIndex;
                            nPrtSheetCnt = ucPNT_TYPE.SelectedIndex;
                        }

                        // 원지 인경우는 라벨 프린터 인쇄...
                        // 판지 이면 레포트 인쇄
                        PrinterManager.PrintMillRoll(sRES_IND_BCD, false, true, nPrtRollCnt, nPrtSheetCnt); //TODO : 운영배포하면 qrDiv = true 로 보내야 QR코드 출력됨
                    }

                    this.Cursor = Cursors.Default;   //Waitting

                    if (sMSG_ERR.Length > 0)
                    {
                        //new POPUP.MessageForm(sMSG_ERR, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                        throw new Exception("SAP_ERROR " + sMSG_ERR);
                    }
                    else
                    {
                        RET_CODE = Common.ERROR_SUCCESS;

                        LogFile.WriteLog("밀롤 실적 등록 성공", LogType.PROC);
                        new POPUP.MessageForm("실적등록 완료 되었습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    }
                }
                //else
                //{
                //    helper.Rollback();
                //}
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

                this.Cursor = Cursors.Default;   //Waitting

                LogFile.WriteLog("밀롤 실적등록 예외 오류 [" + ex.ToString() + " ]");
                LogFile.WriteLog("@@@ catch 밀롤 실적등록 예외 오류 [ 개별바코드 : " + sRES_IND_BCD + " ]");
                new POPUP.MessageForm_ERR("실적등록 오류", "실적등록 예외 오류\r\n" + ex.Message.ToString() + Environment.NewLine + sMSG_ERR, MessageBoxButtons.OK).ShowDialog(this);

            }
            finally
            {
                this.Cursor = Cursors.Default;   //Default
                helper.Close();
            }

            return RET_CODE;
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

                // 1.  미사용 I/F 플래그 변경. 인터페이스 테이블에 ZRESULT 가 'N' -> 'R'로 변경

                // 1.1 실적 인터페이스
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
                // 1.2 폐품 인터페이스
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
                // 1.4 영업폐품+잔량폐품 인터페이스
                if (dsTemp.Tables[4].Rows[0][0].ToString() != "1")
                {
                    notUseIF_ID_1 = dsTemp.Tables[4].Rows[0]["I_IF_ID"].ToString();
                    foreach (DataRow notUseRows in dsTemp.Tables[5].Rows)
                    {
                        helper.ExecuteNoneQuery("SP_IF_NOT_USE_FLAG", CommandType.StoredProcedure
                            , helper.CreateParameter("P_MES_IF_ID", notUseIF_ID_1, DbType.String, ParameterDirection.Input)
                            , helper.CreateParameter("P_DOC_NO", notUseRows["MDOCNO"].ToString(), DbType.String, ParameterDirection.Input)
                            , helper.CreateParameter("P_DOC_SEQNO", notUseRows["MDOCSEQ"].ToString(), DbType.String, ParameterDirection.Input)
                            , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input));
                    }
                }
                // 1.4 투입량 인터페이스
                if (dsTemp.Tables[6].Rows[0][0].ToString() != "1")
                {
                    notUseIF_ID_1 = dsTemp.Tables[6].Rows[0]["I_IF_ID"].ToString();
                    foreach (DataRow notUseRows in dsTemp.Tables[7].Rows)
                    {
                        helper.ExecuteNoneQuery("SP_IF_NOT_USE_FLAG", CommandType.StoredProcedure
                            , helper.CreateParameter("P_MES_IF_ID", notUseIF_ID_1, DbType.String, ParameterDirection.Input)
                            , helper.CreateParameter("P_DOC_NO", notUseRows["MDOCNO"].ToString(), DbType.String, ParameterDirection.Input)
                            , helper.CreateParameter("P_DOC_SEQNO", notUseRows["MDOCSEQ"].ToString(), DbType.String, ParameterDirection.Input)
                            , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input));
                    }
                }

                // 2. SAP로 ROLLBACK 전송
                if (sapTemp.Rows.Count != 0)
                {
                    sapTemp = sapTemp.Select("", "SAP_TYPE ASC").CopyToDataTable<DataRow>();
                    foreach (DataRow Rows in sapTemp.Rows)
                    {
                        LogFile.WriteLog("=====SAP ROLLBACK START=====", LogType.PROC);
                        System.Windows.Forms.Application.DoEvents();        // 반복작업중 응답없음 안뜨게 하기

                        switch (Rows["SAP_TYPE"].ToString())
                        {
                            // 2.3  실적 ROLLBACK
                            case "3.PROD_REG_SAP":
                                LogFile.WriteLog("=====3.PROD_REG_SAP=====" + Rows["MDOCNO"].ToString() + "-" +  Rows["MDOCSEQ"].ToString(), LogType.PROC);
                                dsTemp = helper.FillDataSetN("SP_POP_WRK25_IFR01", CommandType.StoredProcedure, 2
                                       , helper.CreateParameter("P_DOC_NO", Rows["MDOCNO"].ToString(), DbType.String, ParameterDirection.Input)
                                       , helper.CreateParameter("P_DOC_SEQNO", Rows["MDOCSEQ"].ToString(), DbType.String, ParameterDirection.Input)
                                       , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input)
                                       , helper.CreateParameter("RS_RFCFN", DbType.String, ParameterDirection.Output, null, 30)
                                        );
                                string sRS_RFCFN_1 = helper.Parameters["RS_RFCFN"].Value.ToString();
                                SAPHelper sapRFC_1 = new SAPHelper();
                                if (sapRFC_1.CallSAPFunc_PS(sRS_RFCFN_1, dsTemp.Tables[0], dsTemp.Tables[1], helper).Equals("S"))
                                {
                                    rsRfcData = Common.toJsonFormat("PUT_WRKRTN", sapRFC_1.rtnTable).Replace("MBLNR", "RUECK").Replace("MJAHR", "RMZHL");
                                    helper.ExecuteNoneQuery("SP_IF_PUT_WRKRTN", CommandType.StoredProcedure
                                    , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)              // 플랜트
                                    , helper.CreateParameter("P_WRK_TYPE", "0", DbType.String, ParameterDirection.Input)                        // '0'= 실적테이블, 비계획생산, '1'= 폐품테이블, '2'=소요량, '3'=비가동,
                                    , helper.CreateParameterOracle("P_RFC_DATA", rsRfcData, OracleDbType.Clob, ParameterDirection.Input)
                                    , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input));

                                    if (helper.RSCODE == "S")
                                    {
                                        LogFile.WriteLog("밀롤 실적등록 ROLLBACK COMPLETE", LogType.PROC);
                                    }
                                    else //if (helper.RSCODE == "E")
                                    {
                                        LogFile.WriteLog("밀롤 ROLLBACK 등록 - SAP 확정문서 등록 오류 [" + helper.RSMSG.ToString() + "]");
                                        sMSG_ERR += "ROLLBACK 확정문서 등록 오류 : " + helper.RSMSG.ToString() + Environment.NewLine;
                                    }
                                    // DELAY 
                                    Thread.Sleep(Common.SLEEP_DELAY);
                                    System.Windows.Forms.Application.DoEvents();        // 반복작업중 응답없음 안뜨게 하기
                                }
                                else
                                {
                                    LogFile.WriteLog("밀롤 ROLLBACK 오류 - SAP전송 오류 [" + sapRFC_1.rtnMSG + "]");
                                    sMSG_ERR += "밀롤 ROLLBACK 오류 : " + sapRFC_1.rtnMSG + Environment.NewLine;
                                }
                                break;
                            // 2.2  폐품 ROLLBACK
                            case "2.SALV_REG_SAP":
                                LogFile.WriteLog("=====2.SALV_REG_SAP=====" + Rows["MDOCNO"].ToString() + "-" + Rows["MDOCSEQ"].ToString(), LogType.PROC);
                                dsTemp = helper.FillDataSetN("SP_POP_WRK25_IFR02", CommandType.StoredProcedure, 2
                                       , helper.CreateParameter("P_DOC_NO", Rows["MDOCNO"].ToString(), DbType.String, ParameterDirection.Input)
                                       , helper.CreateParameter("P_DOC_SEQNO", Rows["MDOCSEQ"].ToString(), DbType.String, ParameterDirection.Input)
                                       , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input)
                                       , helper.CreateParameter("RS_RFCFN", DbType.String, ParameterDirection.Output, null, 30)
                                        );
                                string sRS_RFCFN_2 = helper.Parameters["RS_RFCFN"].Value.ToString();
                                SAPHelper sapRFC_2 = new SAPHelper();
                                if (sapRFC_2.CallSAPFunc_PS(sRS_RFCFN_2, dsTemp.Tables[0], dsTemp.Tables[1], helper).Equals("S"))
                                {
                                    rsRfcData = Common.toJsonFormat("PUT_WRKRTN", sapRFC_2.rtnTable).Replace("MBLNR", "RUECK").Replace("MJAHR", "RMZHL");
                                    helper.ExecuteNoneQuery("SP_IF_PUT_WRKRTN", CommandType.StoredProcedure
                                    , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)              // 플랜트
                                    , helper.CreateParameter("P_WRK_TYPE", "0", DbType.String, ParameterDirection.Input)                        // '0'= 실적테이블, 비계획생산, '1'= 폐품테이블, '2'=소요량, '3'=비가동,
                                    , helper.CreateParameterOracle("P_RFC_DATA", rsRfcData, OracleDbType.Clob, ParameterDirection.Input)
                                    , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input));

                                    if (helper.RSCODE == "S")
                                    {
                                        LogFile.WriteLog("밀롤 폐품등록 ROLLBACK COMPLETE", LogType.PROC);
                                    }
                                    else //if (helper.RSCODE == "E")
                                    {
                                        LogFile.WriteLog("밀롤 ROLLBACK 등록 - SAP 확정문서 등록 오류 [" + helper.RSMSG.ToString() + "]");
                                        sMSG_ERR += "ROLLBACK 확정문서 등록 오류 : " + helper.RSMSG.ToString() + Environment.NewLine;
                                    }
                                    // DELAY 
                                    Thread.Sleep(Common.SLEEP_DELAY);
                                    System.Windows.Forms.Application.DoEvents();        // 반복작업중 응답없음 안뜨게 하기
                                }
                                else
                                {
                                    LogFile.WriteLog("밀롤 ROLLBACK 오류 - SAP전송 오류 [" + sapRFC_2.rtnMSG + "]");
                                    sMSG_ERR += "밀롤 ROLLBACK 오류 : " + sapRFC_2.rtnMSG + Environment.NewLine;
                                }
                                break;
                            // 2.1  영업폐품+잔량폐품 ROLLBACK
                            case "1.SALE_SALV_REG_SAP":
                                LogFile.WriteLog("=====1.SALE_SALV_REG_SAP=====" + Rows["MDOCNO"].ToString() + "-" + Rows["MDOCSEQ"].ToString(), LogType.PROC);
                                dsTemp = helper.FillDataSetN("SP_POP_WRK25_IFR03", CommandType.StoredProcedure, 2
                                       , helper.CreateParameter("P_DOC_NO", Rows["MDOCNO"].ToString(), DbType.String, ParameterDirection.Input)
                                       , helper.CreateParameter("P_DOC_SEQNO", Rows["MDOCSEQ"].ToString(), DbType.String, ParameterDirection.Input)
                                       , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input)
                                       , helper.CreateParameter("RS_RFCFN", DbType.String, ParameterDirection.Output, null, 30)
                                        );
                                string sRS_RFCFN_3 = helper.Parameters["RS_RFCFN"].Value.ToString();
                                SAPHelper sapRFC_3 = new SAPHelper();
                                if (sapRFC_3.CallSAPFunc_PS(sRS_RFCFN_3, dsTemp.Tables[0], dsTemp.Tables[1], helper).Equals("S"))
                                {
                                    rsRfcData = Common.toJsonFormat("PUT_WRKRTN", sapRFC_3.rtnTable).Replace("MBLNR", "RUECK").Replace("MJAHR", "RMZHL");
                                    helper.ExecuteNoneQuery("SP_IF_PUT_WRKRTN", CommandType.StoredProcedure
                                    , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)              // 플랜트
                                    , helper.CreateParameter("P_WRK_TYPE", "0", DbType.String, ParameterDirection.Input)                        // '0'= 실적테이블, 비계획생산, '1'= 폐품테이블, '2'=소요량, '3'=비가동,
                                    , helper.CreateParameterOracle("P_RFC_DATA", rsRfcData, OracleDbType.Clob, ParameterDirection.Input)
                                    , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input));

                                    if (helper.RSCODE == "S")
                                    {
                                        LogFile.WriteLog("밀롤 영업폐품 ROLLBACK COMPLETE", LogType.PROC);
                                    }
                                    else //if (helper.RSCODE == "E")
                                    {
                                        LogFile.WriteLog("밀롤 ROLLBACK 등록 - SAP 확정문서 등록 오류 [" + helper.RSMSG.ToString() + "]");
                                        sMSG_ERR += "ROLLBACK 확정문서 등록 오류 : " + helper.RSMSG.ToString() + Environment.NewLine;
                                    }
                                    // DELAY 
                                    Thread.Sleep(Common.SLEEP_DELAY);
                                    System.Windows.Forms.Application.DoEvents();        // 반복작업중 응답없음 안뜨게 하기
                                }
                                else
                                {
                                    LogFile.WriteLog("밀롤 ROLLBACK 오류 - SAP전송 오류 [" + sapRFC_3.rtnMSG + "]");
                                    sMSG_ERR += "밀롤 ROLLBACK 오류 : " + sapRFC_3.rtnMSG + Environment.NewLine;
                                }
                                break;
                            // 2.3  실적 ROLLBACK
                            case "4.WIP_REG_SAP":
                                LogFile.WriteLog("=====4.WIP_REG_SAP=====" + Rows["MDOCNO"].ToString() + "-" + Rows["MDOCSEQ"].ToString(), LogType.PROC);
                                dsTemp = helper.FillDataSetN("SP_POP_WRK25_IFR04", CommandType.StoredProcedure, 2
                                       , helper.CreateParameter("P_DOC_NO", Rows["MDOCNO"].ToString(), DbType.String, ParameterDirection.Input)
                                       , helper.CreateParameter("P_DOC_SEQNO", Rows["MDOCSEQ"].ToString(), DbType.String, ParameterDirection.Input)
                                       , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input)
                                       , helper.CreateParameter("RS_RFCFN", DbType.String, ParameterDirection.Output, null, 30)
                                        );
                                string sRS_RFCFN_4 = helper.Parameters["RS_RFCFN"].Value.ToString();
                                SAPHelper sapRFC_4 = new SAPHelper();
                                if (sapRFC_4.CallSAPFunc_PS(sRS_RFCFN_4, dsTemp.Tables[0], dsTemp.Tables[1], helper).Equals("S"))
                                {
                                    rsRfcData = Common.toJsonFormat("PUT_WRKRTN", sapRFC_4.rtnTable).Replace("MBLNR", "RUECK").Replace("MJAHR", "RMZHL");
                                    helper.ExecuteNoneQuery("SP_IF_PUT_WRKRTN", CommandType.StoredProcedure
                                    , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)              // 플랜트
                                    , helper.CreateParameter("P_WRK_TYPE", "0", DbType.String, ParameterDirection.Input)                        // '0'= 실적테이블, 비계획생산, '1'= 폐품테이블, '2'=소요량, '3'=비가동,
                                    , helper.CreateParameterOracle("P_RFC_DATA", rsRfcData, OracleDbType.Clob, ParameterDirection.Input)
                                    , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input));

                                    if (helper.RSCODE == "S")
                                    {
                                        LogFile.WriteLog("밀롤 투입량 ROLLBACK COMPLETE", LogType.PROC);

                                    }
                                    else //if (helper.RSCODE == "E")
                                    {
                                        LogFile.WriteLog("밀롤 ROLLBACK 등록 - SAP 확정문서 등록 오류 [" + helper.RSMSG.ToString() + "]");
                                        sMSG_ERR += "ROLLBACK 확정문서 등록 오류 : " + helper.RSMSG.ToString() + Environment.NewLine;
                                    }

                                    // DELAY 
                                    Thread.Sleep(Common.SLEEP_DELAY);
                                    System.Windows.Forms.Application.DoEvents();        // 반복작업중 응답없음 안뜨게 하기
                                }
                                else
                                {
                                    LogFile.WriteLog("밀롤 ROLLBACK 오류 - SAP전송 오류 [" + sapRFC_4.rtnMSG + "]");
                                    sMSG_ERR += "밀롤 ROLLBACK 오류 : " + sapRFC_4.rtnMSG + Environment.NewLine;
                                }
                                break;

                            default:
                                break;
                        }
                        LogFile.WriteLog("=====SAP ROLLBACK END=====", LogType.PROC);

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
                // 3. MES 롤백구간
                try
                {
                    helper.Commit();

                    if (rollTemp.Rows.Count != 0)
                    {
                        foreach (DataRow Rows in rollTemp.Rows)
                        {
                            LogFile.WriteLog("=====SAP ROLLBACK START=====" + Rows["MDOCNO"].ToString() + "-" + Rows["MDOCSEQ"].ToString(), LogType.PROC);
                            helper.ExecuteNoneQuery("SP_POP_WRK25_R01", CommandType.StoredProcedure
                           , helper.CreateParameter("P_DOC_NO", Rows["MDOCNO"].ToString(), DbType.String, ParameterDirection.Input)
                           , helper.CreateParameter("P_DOC_SEQNO", Rows["MDOCSEQ"].ToString(), DbType.String, ParameterDirection.Input)
                           , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input));
                            LogFile.WriteLog("=====SAP ROLLBACK END=====" + Rows["MDOCNO"].ToString() + "-" + Rows["MDOCSEQ"].ToString(), LogType.PROC);
                        }
                    }
                    sMSG_ERR += "밀롤 MES ROLLBACK 실적이 취소되었습니다" + Environment.NewLine;
                    LogFile.WriteLog("밀롤 MES ROLLBACK COMPLETE", LogType.PROC);
                }
                catch (Exception ex1)
                {
                    LogFile.WriteLog("점보롤 MES ROLLBACK 오류 [" + ex1.Message.ToString() + "]");
                    sMSG_ERR += "밀롤 MES ROLLBACK 오류 : " + ex1.Message.ToString() + Environment.NewLine;
                }
            }
        }

        private void UpdateGrid()
        {
            gbUpdateGrid = true;
            SetGrid();
            DoFind();
            SetGrid02("1");
            SetGrid02("2");
            gbUpdateGrid = false;
        }

        private void CleanOrderLabel()
        {
            //lblWRK_ORDR_NO.Text = "";       // 작업지시번호
            //lblWRK_ORDR_SEQNO.Text = ""; // 작업지시순번

            //lblMATNR.Text = "";           // 자재코드
            //lblJROLLCNT.Text = "";      // 계획 권치수
            //lblTSPEED.Text = "";        // 목표선속
            //lblTOT_WGT.Text = "";          // 중량  
            //lblPRD_REQ_DT.Text = "";     // 생산요청일자

            //lblBS_WGT.Text = "";          // 평량
            //lblJWIDTH.Text = "";             // 지폭
            //giBS_WGT = 0;
            //giJWIDTH = 0;
            //giNON_ORDR_BS_WGT = 0;

            //lblPRFM_ROLLCNT.Text = "";   // 실적권치수
            //lblPRFM_WGT.Text = "";      // 실적 중량
            //lblDISPO_QTY.Text = "";       // 폐품 중량
            //lblMACH_STA.Text = "";      // 설비 상태

            //txtORDER_RMK.Text = "";
            //lblPRFM_DT.Text = "";

            //dtpStartDate.Value = dtpEndDate.Value = DateTime.Now;
            //lblStartTime.Text = lblEndTime.Text = "";
        }

        /// <summary>
        /// 실적 등록후 초기설정
        /// </summary>
        private void InitProduct()
        {
            // 초기설정
            lblMEndChk.Text = lblPrintChk.Text = "V";
            lblMEndChk.BackColor = lblPrintChk.BackColor = Color.Yellow;

            //ucCORE.SelectedIndex = -1;      // 지관 초기값
            //ucPNT_TYPE.SelectedIndex = 0;   // 인쇄 매수

            lblPF_WRK_ORDR_RMK.Text = "";      // 비고

            lblEndDateChk.Text = "V";
            lblEndDateChk.BackColor = Color.Yellow;

            dtpEndDate.Enabled = false;
            butEndDate.Enabled = false;
            lblEndTime.Enabled = false;

            InitDISPO();
        }

        // 폐품정보 초기설정
        private void InitDISPO()
        {
            lblPF_DISPO_ROLLCNT.Enabled = false;
            lblPF_DISPO_ROLLCNT.BackColor = Color.LightGray;
            lblPF_DISPO_ROLLCNT.Text = lblPF_DISPO_WGT.Text = lblPF_DISPO_CODE.Text = "";
            lblPF_DISPO_CODE.Tag = "";
            lblPF_CHK_DISPO.Text = "";
            lblPF_CHK_DISPO.Visible = false;
            lblPF_DISPO_CODE_NAME.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;

            gdDISPO_ROLLCNT = 0;   // 폐품치수
            gdDISPO_WGT = 0;         // 폐품중량
        }
        #endregion

        #region < EVNET >

        private void bBox1_buttonClickEvent(MESButton sender, ButtonBox.ButtonClickEventArg e)
        {
            try
            {
                bool isRefresh = false;

                if (!this.bUseNetwork)
                {
                    SetMessage("네트워크 상태를 확인하시기 바랍니다.");
                    return;
                }

                MESButton btn = sender;

                switch (btn.Tag.ToString())
                {
                    case "Order": //작업지시 선택
                        if (SettingCheck("MR"))
                        {
                            POP_WRK07 WRK07 = new POP_WRK07(Common.OpCode, Common.IOType);

                            if (ShowDialogForm(WRK07) == DialogResult.OK)
                            {
                                InitProduct();
                                isRefresh = true;
                            }
                            else
                            {
                                isRefresh = false;
                            }
                        }
                        break;
                    case "Worker":  //작업자 선택
                        if (SettingCheck("M"))
                        {
                            POP_WRK05 WRK05 = new POP_WRK05(Common.MachineCode, Common.IOType);
                            ShowDialogForm(WRK05);
                            isRefresh = false;
                        }
                        break;
                    case "Machine": //설비선택
                        POP_WRK02 WRK02 = new POP_WRK02();
                        
                        if (ShowDialogForm(WRK02) == DialogResult.OK)
                            isRefresh = true;
                        else
                            isRefresh = false;
                        break;
                    case "Start": //작업시작 / 대기처리
                        if (SettingCheck("MWOR"))
                        {
                            doConfirm();
                            isRefresh = false;
                        }
                        break;
                    case "Stop": //정지
                        break;
                    case "NonOper": //비가동등록
                        if (SettingCheck("MW"))
                        {
                            POP_WRK03 WRK03 = new POP_WRK03();
                            ShowDialogForm(WRK03);
                            isRefresh = true;
                        }
                        break;
                    case "Product": //실적등록
                        if (SettingCheck("MWOSR"))
                        {
                            int RET_CODE = doProduct();

                            if (RET_CODE == Common.ERROR_SUCCESS)
                            {
                                InitProduct();
                            }
                            else if (RET_CODE == Common.ERROR_RFC_FAIL)
                            {
                                InitDISPO();
                            }

                            if (RET_CODE == Common.ERROR_SUCCESS || RET_CODE == Common.ERROR_RFC_FAIL)
                            {
                                UpdateGrid();
                                CallUpdateMinuteFunc();
                            }
                        }
                        break;
                    case "Dispo": //폐품사유선택
                        if (SettingCheck("MWOSR"))
                        {
                            POP_WRK35 popWrk35 = new POP_WRK35();
                            popWrk35.LabelTitle = "밀롤 폐품사유";

                            if (ShowDialogForm(popWrk35) == DialogResult.OK)
                            {
                                lblPF_DISPO_CODE.Tag = popWrk35.DispoCode;
                                lblPF_DISPO_CODE.Text = popWrk35.DispoName;
                                lblPF_CHK_DISPO.Text = "V";
                                lblPF_CHK_DISPO.Visible = true;
                                lblPF_DISPO_ROLLCNT.Enabled = true;
                                lblPF_DISPO_ROLLCNT.BackColor = Color.White;
                                lblPF_DISPO_CODE_NAME.TextAlign = System.Drawing.ContentAlignment.MiddleRight;

                                lblPF_DISPO_ROLLCNT.Text = "0";
                                lblPF_DISPO_WGT.Text = "0";
                                //new POPUP.MessageForm(string.Format("폐품코드={0}\r\n폐품명={1}", popWrk35.JunkItemCode, popWrk35.JunkItemName), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                            }
                            isRefresh = false;
                        }
                        break;
                    case "Input": //밀롤공정투입
                        POP_WRK01 WRK01 = new POP_WRK01(POP_WRK01.LOC_MA_2100);
                        if (ShowDialogForm(WRK01) == DialogResult.OK)
                            isRefresh = true;
                        else
                            isRefresh = false;
                        break;
                    case "Check": //공정체크
                        if (SettingCheck("MW"))
                        {
                            POP_WRK04 WRK04 = new POP_WRK04();
                            ShowDialogForm(WRK04);
                            isRefresh = false;
                        }
                        break;
                    //case "InputLog": //자재투입이력
                    //    //POP_INV02 INV02 = new POP_INV02();
                    //    //ShowDialogForm(INV02);

                    //    break;
                    case "Performance": //실적현황
                        POP_WRK30 WRK30 = new POP_WRK30(Common.OpCode, Common.MachineCode);
                        if (ShowDialogForm(WRK30) == DialogResult.OK)
                            isRefresh = true;
                        else
                            isRefresh = false;
                        break;

                    default:
                        isRefresh = false;
                        break;
                }

                if (isRefresh == true)
                {
                    UpdateGrid();
                    CallUpdateMinuteFunc();
                }
            }
            catch (Oracle.ManagedDataAccess.Client.OracleException oe)
            {
                SetMessage(oe.Message);
            }

            catch (Exception ex)
            {
                SetMessage(ex.Message);
                LogFile.WriteLog("POP_WRK25.bBox1_buttonClickEvent Error => " + ex.Message);
            }
            finally
            {
            }
        }

        private void btnCancel_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        #endregion

        private void lblCHK_DISPO_Click(object sender, EventArgs e)
        {
            InitDISPO();
        }

        private void lblMEndChk_Click(object sender, EventArgs e)
        {
            if (lblMEndChk.Text.ToString().Equals("V"))
            {
                lblMEndChk.Text = "";
                lblMEndChk.BackColor = Color.White;
            }
            else
            {
                lblMEndChk.Text = "V";
                lblMEndChk.BackColor = Color.Yellow;
            }
        }


        private void lblPrintChk_Click(object sender, EventArgs e)
        {
            if (lblPrintChk.Text.ToString().Equals("V"))
            {
                lblPrintChk.Text = "";
                lblPrintChk.BackColor = Color.White;
            }
            else
            {
                lblPrintChk.Text = "V";
                lblPrintChk.BackColor = Color.Yellow;
            }
        }

        private void butStartDate_Click(object sender, EventArgs e)
        {
            DAResultDate pop = new DAResultDate(dtpStartDate.Value);
            pop.ShowDialog(this);
            if (pop.DialogResult == DialogResult.OK)
            {
                string strDate = pop.ResultString.ToString();
                dtpStartDate.Value = DateTime.Parse(strDate);
                //AutoCalculation();    // dtpDate_ValueChanged 이벤트가 발생하여 주석처리
            }

        }

        private void butEndDate_Click(object sender, EventArgs e)
        {
            DAResultDate pop = new DAResultDate(dtpEndDate.Value);
            pop.ShowDialog(this);
            if (pop.DialogResult == DialogResult.OK)
            {
                string strDate = pop.ResultString.ToString();
                dtpEndDate.Value = DateTime.Parse(strDate);
                //AutoCalculation();    // dtpDate_ValueChanged 이벤트가 발생하여 주석처리
            }

        }

        private void dtpDate_ValueChanged(object sender, EventArgs e)
        {
            AutoCalculation();
        }

        private void AutoCalculation()
        {

            DateTime dtStartDate;
            DateTime dtEndDate;

            try
            {


                if ((lblStartTime.Text.ToString().Length != 5) || (lblEndTime.Text.ToString().Length != 5))
                {
                    lblPF_PRFM_DT.Text = "";                   // 생산실적일자
                    return;
                }

                string sStartDate = dtpStartDate.Value.ToString("yyyy-MM-dd") + " " + lblStartTime.Text.ToString() + ":00";
                if (Common.IsDateTime(sStartDate) == false)
                {
                    lblPF_PRFM_DT.Text = "";                   // 생산실적일자
                    return;
                }

                string sEndDate = dtpEndDate.Value.ToString("yyyy-MM-dd") + " " + lblEndTime.Text.ToString() + ":00";
                if (Common.IsDateTime(sEndDate) == false)
                {
                    lblPF_PRFM_DT.Text = "";                   // 생산실적일자
                    return;
                }

                dtStartDate = Convert.ToDateTime(sStartDate);
                dtEndDate = Convert.ToDateTime(sEndDate);

                TimeSpan Diff_dates = dtEndDate.Subtract(dtStartDate);


                if (Diff_dates.TotalMinutes > 0)
                {
                    string sDate = Common.GetRecDate(dtEndDate);
                    if (string.IsNullOrEmpty(sDate) == false)
                    {
                        try
                        {
                            lblPF_PRFM_DT.Text = DateTime.ParseExact(sDate, "yyyyMMdd", null).ToString("yyyy-MM-dd");
                        }
                        catch (FormatException)
                        {
                            Console.WriteLine("{0} is not in the correct format.", sDate);
                            lblPF_PRFM_DT.Text = "";
                        }
                    }

                    //lblTM.Text = string.Format("{0:#,0}", Diff_dates.TotalMinutes);                                 // 가동시간
                    //lblRSPEED.Text = string.Format("{0:#,0}", (int)((gdROLLCNT / Diff_dates.TotalMinutes) + 0.5));     // 선속
                    //SetMessage("");
                }
                else
                {
                    lblPF_PRFM_DT.Text = "";                   // 생산실적일자
                    //lblTM.Text = "0";           // 가동시간
                    //lblRSPEED.Text = "0";       // 선속
                    //SetMessage("작업 시작일시/종료일시를 확인하세요!");
                }
            }
            catch (Exception ex)
            {
                LogFile.WriteLog("밀롤 AutoCalculation Error => " + ex.Message);
            }

        }

        private void CalculationWeigh()
        {
            //실적중량계산
            WgtCalculation();

            //폐품중량계산
            if (lblPF_DISPO_ROLLCNT.Enabled)
                DispoWgtCalculation();
        }


        // 실적 중량 계산
        private void WgtCalculation()
        {
            if (giBS_WGT <= 0 || giMWIDTH_SUM <= 0 || gdROLLCNT <= 0)
            {
                lblPF_WGT.Text = "0";
                return;
            }

            //Decimal dValue = ((Decimal)giBS_WGT / 1000) * ((Decimal)giMWIDTH_SUM / 1000) * (Decimal)gdROLLCNT;
            Decimal dTotValue = 0;
            foreach (UltraGridRow ugr in Grid3.Rows)
            {
                if (ugr.Cells["CHK"].Value.ToString().Equals("V"))
                {
                    Decimal dValue = 0;
                    int nMWIDTH = 0;
                    
                    string sMWIDTH = ugr.Cells["MWIDTH"].Value.ToString().Replace(",", "");

                    if (int.TryParse(sMWIDTH, out nMWIDTH) == true)
                    {
                        dValue = ((Decimal)giBS_WGT / 1000) * ((Decimal)nMWIDTH / 1000) * (Decimal)gdROLLCNT;

                        if (ugr.Cells["NEXT_PROC"].Value.ToString() == "ROLL")
                        {
                            dValue = Math.Round(dValue);
                        }

                        dTotValue += dValue;
                    }
                }
            }

            lblPF_WGT.Text = string.Format("{0:#,0.###}", dTotValue);

//            gdWGT = dTotValue;      // 중량
        }

        
        // 폐품 중량 계산
        private void DispoWgtCalculation()
        {
            if (giBS_WGT <= 0 || giMWIDTH_SUM <= 0 || gdDISPO_ROLLCNT <= 0)
            {
                lblPF_DISPO_WGT.Text = "0";
                return;
            }

            Decimal dValue = ((Decimal)giBS_WGT / 1000) * ((Decimal)giMWIDTH_SUM / 1000) * (Decimal)gdDISPO_ROLLCNT;
            lblPF_DISPO_WGT.Text = string.Format("{0:#,0.###}", dValue);
            gdDISPO_WGT = dValue;      // 중량

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

        private void uc_ValueChanged(object sender, EventArgs e)
        {
            lblPF_ROLLCNT.Focus();
        }

        private void lblROLLCNT_Click(object sender, EventArgs e)
        {
            int nChkCnt = 0;
            foreach (UltraGridRow ugr in Grid3.Rows)
            {
                if (ugr.Cells["CHK"].Value.ToString().Equals("V"))
                {
                    nChkCnt++;
                }
            }

            if (nChkCnt == 0)
            {
                new POPUP.MessageForm("작업지시를 먼저 선택하세요", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return;
            }

            DAResultQty pop = new DAResultQty();
            pop.LabelTitle = "밀롤 실적 입력";
            pop.LabelHeader = "밀롤실적(M)";
            pop.ContentMaxLength = 8;

            pop.ShowDialog(this);

            if (pop.DialogResult == DialogResult.OK)
            {
                gdROLLCNT = Convert.ToDecimal(pop.ResultDouble);
                lblPF_ROLLCNT.Text = string.Format("{0:#,0}", gdROLLCNT);
                CalculationWeigh();
            }
        }

        private void lblWRK_ORDR_RMK_Click(object sender, EventArgs e)
        {
            DAResultText pop = new DAResultText("밀롤 비고 입력", lblPF_WRK_ORDR_RMK.Text.ToString());
            pop.ContentMaxLength = 100;

            pop.ShowDialog(this);
            if (pop.DialogResult == DialogResult.OK)
            {
                lblPF_WRK_ORDR_RMK.Text = pop.ResultString;
            }

        }

        private void lblDISPO_ROLLCNT_Click(object sender, EventArgs e)
        {
            int nChkCnt = 0;
            foreach (UltraGridRow ugr in Grid3.Rows)
            {
                if (ugr.Cells["CHK"].Value.ToString().Equals("V"))
                {
                    nChkCnt++;
                }
            }

            if (nChkCnt == 0)
            {
                new POPUP.MessageForm("작업지시를 먼저 선택하세요", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return;
            }

            DAResultQty pop = new DAResultQty();
            pop.LabelTitle = "밀롤 폐품 입력";
            pop.LabelHeader = "폐품(M)";
            pop.ContentMaxLength = 8;

            pop.ShowDialog(this);

            if (pop.DialogResult == DialogResult.OK)
            {
                gdDISPO_ROLLCNT = Convert.ToDecimal(pop.ResultDouble);
                lblPF_DISPO_ROLLCNT.Text = string.Format("{0:#,0}", gdDISPO_ROLLCNT);

                DispoWgtCalculation();
            }
        }

        private void Grid2_GridSelectChanged(object sender, AfterSelectChangeEventArgs e)
        {
            if (typeof(UltraGridRow) == e.Type)
            {
                //if (gbUpdateGrid == false)
                {
                    SetGrid02("2");

                    //DoFind03();
                    DispoWgtCalculation();
                    AutoCalculation();
                }
            }
        }

        private void Grid1_GridSelectChanged(object sender, AfterSelectChangeEventArgs e)
        {
            if (typeof(UltraGridRow) == e.Type)
            {
                //if (gbUpdateGrid == false)
                {
                    if (Grid1.Rows.Count < 1)
                    {
                        return;
                    }

                    if (Grid1.Row == null)
                    {
                        return;
                    }

                    SetGrid02("1");
                }
            }
        }

        private void Grid3_ClickCellButton(object sender, MESGrid.GridClickEventArg e)
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

                DoFind03();

                // 실적, 폐품중량계산
                CalculationWeigh();
            }
            else if (e.column.ToString() == "DETAIL_BTN") // 상세보기
            {
                string sWrkOrder = e.row.Cells["WRK_ORDR_NO"].Value.ToString();
                string sWrkOrderSeq = e.row.Cells["WRK_ORDR_SEQNO"].Value.ToString();

                //public static string PROC_INP = "PROC_INP";        // 작업지시선택 투입정보
                //public static string PROC_WRK = "PROC_WRK";        // 주작업 표시 정보
                POP_WRK84 popWrk84 = new POP_WRK84(POP_WRK84.PROC_WRK, Common.PlantCode, Common.OpCode, sWrkOrder, sWrkOrderSeq);  // 작업지시 정보
                popWrk84.LabelTitle = "밀롤 작업지시 상세정보";
                ShowDialogForm(popWrk84);
            }

        }

        private void btnJRDetail_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(Common.WrkOrderNo))
            {
                return;
            }

            if (Grid1.Rows.Count < 1 || Grid1.Row == null)
            {
                return;
            }


            string sIND_BCD = Grid1.Row.Cells["IND_BCD"].Value.ToString();      // 개별바코드

            //public static string PROC_INP = "PROC_INP";        // 작업지시선택 투입정보
            //public static string PROC_WRK = "PROC_WRK";        // 주작업 표시 정보
            POP_WRK84 popWrk84 = new POP_WRK84(POP_WRK84.PROC_INP_PRFM, Common.PlantCode, Common.OpCode, Common.WrkOrderNo, Common.WrkOrderSeq, sIND_BCD);  // 작업지시 정보
            popWrk84.LabelTitle = "점보롤 투입정보 상세보기";
            ShowDialogForm(popWrk84);
        }


        private void Grid3_GridDoubleClick(object sender, MESGrid.GridClickEventArg e)
        {
            if (Grid3.Rows.Count > 0)
            {
#if true
                DataTable dtData;
                if (Grid3.Rows.Band.SortedColumns.Count == 0)
                {
                    dtData = Grid3.DataSource.Copy();
                }
                else
                {
                    string strSORT = string.Format("{0} {1}", Grid3.Rows.Band.SortedColumns[0], Grid3.Rows.Band.SortedColumns[0].SortIndicator == SortIndicator.Ascending ? "ASC" : "DESC");
                    dtData = Grid3.DataSource.Select("", strSORT).CopyToDataTable<DataRow>();
                }

                POP_WRK87 pop = new POP_WRK87(dtData);    //밀롤 작업지시 수정
                pop.ShowDialog(this);

                if (pop.DialogResult == DialogResult.OK)
                {
                    Grid3.DataSource = pop.ResultDT;

                    DataSet dsMRWrk = new DataSet();
                    dsMRWrk.Tables.Add(Grid3.DataSourceDS.Tables[0].Copy());
                    dsMRWrk.Tables.Add(pop.ResultDT);
                    Grid3.DataSourceDS = dsMRWrk;
                }
#else
                POP_WRK87 pop = new POP_WRK87(Grid3.DataSource);    //밀롤 작업지시 수정

                pop.ShowDialog(this);

                if (pop.DialogResult == DialogResult.OK)
                {
                    Grid3.DataSource = pop.ResultDT;
                }
#endif
            }
        }

        private void lblEndDateChk_Click(object sender, EventArgs e)
        {
            if (lblEndDateChk.Text.Equals("V"))
            {
                lblEndDateChk.Text = "";
                lblEndDateChk.BackColor = Color.White;

                dtpEndDate.Enabled = true;
                butEndDate.Enabled = true;
                lblEndTime.Enabled = true;
            }
            else
            {
                lblEndDateChk.Text = "V";
                lblEndDateChk.BackColor = Color.Yellow;

                dtpEndDate.Enabled = false;
                butEndDate.Enabled = false;
                lblEndTime.Enabled = false;

                CallUpdateMinuteFunc();
            }
        }

        private void dtpDate_DropDown(object sender, EventArgs e)
        {
            CommonCalendar.CloseCalendar((DateTimePicker)sender);
            lblPF_ROLLCNT.Focus();
        }

        private void btnChange_Func()
        {
            if (btnWaitFlag)
            {
                bBox1[0, 3].Text = "작업시작";
                bBox1.RedrawButtons();
            }
            else
            {
                bBox1[0, 3].Text = "대기중";
                bBox1.RedrawButtons();
            }

        }

        private void timer1_Tick(object sender, EventArgs e)
        {
            if (bABNChk)
            {
                bBox1[0, 4].bAlarm = bBox1[0, 4].bAlarm ? false : true;
                bBox1.RedrawButtons();
            }

            //iReSetCnt++;
            //if (iReSetCnt % 60 == 0)
            //{
            //    //SetGrid();
            //    //DoFind();
            //    iReSetCnt = 0;
            //}
        }
    }
}
