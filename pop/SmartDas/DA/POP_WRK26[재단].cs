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
    public partial class POP_WRK26 : BaseForm
    {
        #region < MEMBER AREA >
        private SAMMI.Common _common = new SAMMI.Common();

        private DataTable dtInpInfo = new DataTable();    // 투입정보 테이블
        private DataTable dtNowWrk = new DataTable();     //현재 작업지시 테이블

        private string gsMAN_CUT_YN = "";
        private string gsTT_WLEN = "";      // 수재단 규격
        private string gsTT_VLEN = "";      // 수재단 규격
        private bool continuWork = false;   // 밀롤창고 고도화에 의한 flag


        private string gsIN_MR_YN = string.Empty;  //작업지시 구분 (정상, 수입밀롤)

        private bool gbMAT_TRANS = false;   //재고이전 실행유무

        // 버튼 알람용 변수
        private int iReSetCnt = 0;
        private bool bABNChk = false;
        DataTable dtStop_Temp = new DataTable();

        //*************************************
        //control 네이밍 정보
        //-------------------------------------
        //투입정보  : IN_XXX (INput)
        //작업지시정보 : WO_XXX (Work Order)
        //실적등록정보 : PF_XXX (PerFormance)
        //*************************************
        #endregion

        #region < CONSTRUCTOR >

        public POP_WRK26()
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

        #region < POP_WRK26_Load >
        private void POP_WRK26_Load(object sender, EventArgs e)
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

                this.lblTitle.Text = "재단 실적등록";

                Common.machSetting();

                SetMenuButtons();

                UpdateGrid();

                InitProduct();

                lblPrintChk.Text = "V";
                lblPrintChk.BackColor = Color.Yellow;

                lblPF_CHK_DISPO_01.BackColor = Color.Yellow;
                lblPF_CHK_DISPO_02.BackColor = Color.Yellow;

                if (gsMAN_CUT_YN == "Y")
                {
                    FixManualCutter();
                }

                gbMAT_TRANS = true;
            }
            catch (Exception ex)
            {
                SetMessage("POP_WRK26_Load_ Error!");
                LogFile.WriteLog("POP_WRK26.POP_WRK26_Load Error => " + ex.Message);
            }
        }
        #endregion

        #region < METHOD AREA >

        // 재단 재 조회
        private void reSearch()
        {
            DBHelper helper = new DBHelper();

            DataSet dsRtn = new DataSet();
            DataSet dsMA = new DataSet();

            DataTable dtTemp = new DataTable();
            try
            {
                Grid1.HeaderFontSize = 16;
                Grid1.FontSize = 16;
                Grid1.CountRows = 3;
                Grid1.AutoScroll = true;
                Grid1.DisplayLayout.Scrollbars = Scrollbars.Automatic;
                Grid1.DisplayLayout.Bands[0].Override.SelectTypeCol = SelectType.None;
                btnRightPage.LinkMoveSize = Grid1.CountRows;
                btnLeftPage.LinkMoveSize = Grid1.CountRows;

                dsRtn = helper.FillDataSetN("SP_POP_WRK26_C01", CommandType.StoredProcedure, 4
                                                    , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)                     // 플랜트코드
                                                    , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)                  //작업장코드(설비코드)
                                                    , helper.CreateParameter("RS_MACH_STA", DbType.String, ParameterDirection.Output, null, 30)                     //  RES MACH_STA 가동상태(R :가동, S:비가동, N:대기중)
                                                    );

                // 가동상태(R :가동, S:비가동, N:대기중)
                if (helper.RSCODE == "S" || helper.RSCODE == "E")
                {
                    timer1.Start();

                    bBox1[0, 4].bAlarm = false;

                    string sRS_MACH_STA = helper.Parameters["RS_MACH_STA"].Value.ToString();

                    //가동상태(R :가동, S:비가동, N:대기중)
                    if (sRS_MACH_STA.Equals("R"))
                    {
                        lblMACH_STA.Text = "가동중";
                        bBox1[0, 3].Text = "작업시작";
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
                    dtInpInfo = dsRtn.Tables[0].Copy();     // 투입정보 테이블
                    dtNowWrk = dsRtn.Tables[3].Copy();      // 현재 작업지시 테이블

                    //밀롤 바코드 목록
                    dsMA.Tables.Add(dsRtn.Tables[1].Copy());
                    dsMA.Tables.Add(dsRtn.Tables[2].Copy());
                    Grid1.DoFind_Oracle(dsMA);

                    Grid1.DisplayLayout.Override.DefaultRowHeight = 50;
                    if (Grid1.Rows.Count > 0)
                    {
                        // 첫번째 행 선택
                        Grid1.Rows[0].Selected = true;
                        Grid1.Row = Grid1.Rows[0];
                    }
                }
                else
                {
                    dtInpInfo.Reset();     // 투입정보 테이블
                    dtNowWrk.Reset();      // 현재 작업지시 테이블

                    new POPUP.MessageForm(helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return;
                }

            }
            catch (Exception ex)
            {
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                LogFile.WriteLog("POP_WRK26.SetGrid Error => " + ex.Message);
            }
        }
        private void SetGrid()
        {
            DBHelper helper = new DBHelper();

            DataSet dsRtn = new DataSet();
            DataSet dsMA = new DataSet();

            DataTable dtTemp = new DataTable();
            try
            {
                Grid1.HeaderFontSize = 16;
                Grid1.FontSize = 16;
                Grid1.CountRows = 3;
                Grid1.AutoScroll = true;
                Grid1.DisplayLayout.Scrollbars = Scrollbars.Automatic;
                Grid1.DisplayLayout.Bands[0].Override.SelectTypeCol = SelectType.None;
                btnRightPage.LinkMoveSize = Grid1.CountRows;
                btnLeftPage.LinkMoveSize = Grid1.CountRows;

                dsRtn = helper.FillDataSetN("SP_POP_WRK26_S01", CommandType.StoredProcedure, 4
                                                    , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)                     // 플랜트코드
                                                    , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)                  //작업장코드(설비코드)
                                                    , helper.CreateParameter("RS_MACH_STA", DbType.String, ParameterDirection.Output, null, 30)                     //  RES MACH_STA 가동상태(R :가동, S:비가동, N:대기중)
                                                    );

                // 가동상태(R :가동, S:비가동, N:대기중)
                if (helper.RSCODE == "S" || helper.RSCODE == "E")
                {
                    timer1.Start();

                    bBox1[0, 4].bAlarm = false;

                    string sRS_MACH_STA = helper.Parameters["RS_MACH_STA"].Value.ToString();

                    //가동상태(R :가동, S:비가동, N:대기중)
                    if (sRS_MACH_STA.Equals("R"))
                    {
                        lblMACH_STA.Text = "가동중";
                        bBox1[0, 3].Text = "작업시작";
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
                    dtInpInfo = dsRtn.Tables[0].Copy();     // 투입정보 테이블
                    dtNowWrk = dsRtn.Tables[3].Copy();      // 현재 작업지시 테이블

                    //밀롤 바코드 목록
                    dsMA.Tables.Add(dsRtn.Tables[1].Copy());
                    dsMA.Tables.Add(dsRtn.Tables[2].Copy());
                    Grid1.DoFind_Oracle(dsMA);

                    Grid1.DisplayLayout.Override.DefaultRowHeight = 50;
                    if (Grid1.Rows.Count > 0)
                    {
                        // 첫번째 행 선택
                        Grid1.Rows[0].Selected = true;
                        Grid1.Row = Grid1.Rows[0];
                    }
                }
                else
                {
                    dtInpInfo.Reset();     // 투입정보 테이블
                    dtNowWrk.Reset();      // 현재 작업지시 테이블

                    if (helper.RSCODE.Equals("N"))
                    {
                        new POPUP.MessageForm(helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);

                        continuWork = true;
                        reSearch();
                    }
                    else
                    {
                        new POPUP.MessageForm(helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);

                        return;
                        continuWork = false;
                    }
                }

            }
            catch (Exception ex)
            {
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                LogFile.WriteLog("POP_WRK26.SetGrid Error => " + ex.Message);
            }
        }


        private void DoFind()
        {
            try
            {
                gsMAN_CUT_YN = "";      // 이전에 수재단 이동한 작업지시 인지 확인.

                if (dtInpInfo.Rows.Count < 1
                    || string.IsNullOrEmpty(dtInpInfo.Rows[0]["LOT_NO"].ToString()))
                {
                    //SetMessage("조회된 작업지시가 없습니다.");
                    InitControl_IN();
                }
                else
                {
                    //공통사용항목 관리
                    Common.OrderNo = dtInpInfo.Rows[0]["ORDER_NO"].ToString();//생산오더번호
                    Common.WrkOrderNo = dtInpInfo.Rows[0]["WRK_ORDR_NO"].ToString();//밀롤작업지시번호
                    Common.WrkOrderSeq = dtInpInfo.Rows[0]["WRK_ORDR_SEQNO"].ToString();//밀롤작업지시순번
                    Common.ItemCode = dtInpInfo.Rows[0]["MATNR"].ToString(); //자재코드
                    Common.LotNo = dtInpInfo.Rows[0]["LOT_NO"].ToString(); //lot no

                    gsIN_MR_YN = dtInpInfo.Rows[0]["IN_MR_YN"].ToString(); //지종
                    if (gsIN_MR_YN == "Y")
                    {
                        this.lblTitle.Text = "재단 실적등록(수입)";
                    }
                    else
                    {
                        this.lblTitle.Text = "재단 실적등록";
                    }
                    

                    //lblIN_LOT_NO.Text = dtInpInfo.Rows[0]["LOT_NO"].ToString(); //LOT 번호
                    lblIN_WRK_ORDR.Text = string.Format("{0}-{1}", Common.WrkOrderNo, Common.WrkOrderSeq);
                    lblIN_PCODE.Text = dtInpInfo.Rows[0]["PCODE"].ToString(); //지종


                    lblIN_BS_WGT.Text = Common.StrFormatInteger(dtInpInfo.Rows[0]["BS_WGT"].ToString()); //실적량
                    lblIN_MWIDTH.Text = Common.StrFormatInteger(dtInpInfo.Rows[0]["MWIDTH_INPUT"].ToString()); //실적량

                    string sPRD_STR_DTM = dtInpInfo.Rows[0]["PRD_STR_DTM"].ToString(); //생산시작일시(YYYYMMDDHH24MISS)

                    DateTime dtTmp;
                    if (DateTime.TryParseExact(sPRD_STR_DTM, "yyyyMMddHHmmss", null, DateTimeStyles.AssumeLocal, out dtTmp))
                    {
                        lblStartTime.Text = dtTmp.ToString("HH:mm");       // 작업시작시간
                        dtpStartDate.Value = dtTmp;

                        //lblEndTime.Text = dtTmp.ToString("HH:mm");       // 작업종료시간
                        //dtpEndDate.Value = dtTmp;
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
                
                if (dtNowWrk.Rows.Count < 1
                    || string.IsNullOrEmpty(dtNowWrk.Rows[0]["WRK_ORDR_NO"].ToString()))
                {
                    //SetMessage("조회된 작업지시가 없습니다.");
                    InitControl_WO();
                }
                else
                {
                    lblWO_WRK_ORDR_NO.Text = dtNowWrk.Rows[0]["WRK_ORDR_NO"].ToString();
                    lblWO_WRK_ORDR_SEQNO.Text = dtNowWrk.Rows[0]["WRK_ORDR_SEQNO"].ToString();
                    lblWO_MATNR.Text = dtNowWrk.Rows[0]["MATNR"].ToString(); //자재코드

                    lblWO_WLEN.Text = Common.StrFormatInteger(dtNowWrk.Rows[0]["WLEN"].ToString());            // 재단규격 가로
                    lblWO_VLEN.Text = Common.StrFormatInteger(dtNowWrk.Rows[0]["VLEN"].ToString());            // 재단규격 세로

                    lblWO_CON_TYPE.Text = dtNowWrk.Rows[0]["CON_TYPE"].ToString();        // 컨테이너 유형
                    lblWO_PACKTYPE.Text = dtNowWrk.Rows[0]["PACKTYPE"].ToString();            // 포장타입
                    lblWO_DOMESTIC.Text = dtNowWrk.Rows[0]["DOMTC_DIV"].ToString();            // 내수구분
                    lblWO_PRD_REQ_DT.Text = dtNowWrk.Rows[0]["PRD_REQ_DT"].ToString();            // 생산지시일

                    lblWO_CUST_NM.Text = dtNowWrk.Rows[0]["KUNNRT"].ToString();              // 거래처
                    lblWO_MWIDTH.Text = Common.StrFormatInteger(dtNowWrk.Rows[0]["MWIDTH"].ToString());               // 밀롤 지폭

                    if (gsIN_MR_YN.Equals("Y"))
                    {
                        lblWO_MWIDTH_NAME.Text = "밀롤지폭/재단폭수";
                        lblWO_PKCNT.Text = dtNowWrk.Rows[0]["PKCNT"].ToString();                // 재단폭수
                    }
                    else
                    {
                        if (dtNowWrk.Rows[0]["OAUART_DIV"].ToString().Equals("ZCOR"))
                        {
                            lblWO_MWIDTH_NAME.Text = "밀롤지폭/재단폭수";
                            lblWO_PKCNT.Text = dtNowWrk.Rows[0]["PKCNT"].ToString();                // 재단폭수
                        }
                        else
                        {
                            lblWO_MWIDTH_NAME.Text = "밀롤지폭/밀롤폭수";
                            lblWO_PKCNT.Text = dtNowWrk.Rows[0]["MRCNT"].ToString();                // 밀롤폭수
                        }
                    }

                    //lblWO_PLT_PER_CNT.Text = Common.StrFormatInteger(dtNowWrk.Rows[0]["PLT_PER_CNT"].ToString());          // 팔레트당 연수
                    
                    Decimal dTmp = 0;
                    Decimal.TryParse(dtNowWrk.Rows[0]["PLT_PER_CNT"].ToString().Replace(",", ""), out dTmp);          // 팔레트당 연수
                    lblWO_PLT_PER_CNT.Text = string.Format("{0:#,##0.0}", dTmp);
                    //소숫점 표시되게 변경
                    lblWO_PLT_EA.Text = Common.StrFormatDouble(dtNowWrk.Rows[0]["PLT_CNT"].ToString(), "{0:#,##0.0}");               // 팔레트 수량

                    lblWO_IN_PER_CNT.Text = Common.StrFormatInteger(dtNowWrk.Rows[0]["IN_PER_CNT"].ToString());           // 속당매수
                    lblWO_SCNT.Text = Common.StrFormatDouble(dtNowWrk.Rows[0]["SHEET_CNT"].ToString(), "{0:#,##0.0}");                 // 속


                    lblWO_PRD_REAM.Text = Common.StrFormatDouble(dtNowWrk.Rows[0]["WRK_ORDR_QTY"].ToString());           //계획연수
                    lblWO_PRD_WGT.Text = Common.StrFormatDouble(dtNowWrk.Rows[0]["TOT_WGT"].ToString());           //계획중량
                    lblWO_MCNT.Text = Common.StrFormatInteger(dtNowWrk.Rows[0]["MCNT"].ToString());             // 매수

                    txtWO_ORDER_RMK.Text = dtNowWrk.Rows[0]["ORDER_RMK"].ToString();             // 오더 비고

                    // 수재단 작업지시
                    gsMAN_CUT_YN = dtNowWrk.Rows[0]["MAN_CUT_YN"].ToString();
                    if (gsMAN_CUT_YN == "Y")
                    {
                        FixManualCutter();
                    }

                    if (string.IsNullOrEmpty(lblWO_PLT_PER_CNT.Text))
                        lblPF_PLT_REAM.Text = "0";
                    else
                        lblPF_PLT_REAM.Text = Common.StrFormatDouble(lblWO_PLT_PER_CNT.Text.Replace(",", ""), "{0:#,##0.#}");

                    lblPF_PLT_EA.Text = "1";

                    WgtCalculation();
                }
            }
            catch (Exception ex)
            {
                SetMessage("DoFind Error!");
                LogFile.WriteLog("POP_WRK26.DoFind Error => " + ex.Message);
            }
        }

        // 수재단 이동이 발생한 작업지시는 남은 재단을 모두 수재단 이동으로 보냄.
        private void FixManualCutter()
        {
            lblMoveTTChk.Text = "V";
            lblMoveTTChk.BackColor = Color.Yellow;

            if( string.IsNullOrEmpty(dtNowWrk.Rows[0]["TT_WLEN"].ToString()))
            {
                gsTT_WLEN = lblWO_WLEN.Text.ToString();   // 모든 실적 취소한경우 규격이 빈상태로 들어와서, 재단 가로 길이를 표시함
            }
            else
            {
                gsTT_WLEN = Common.StrFormatInteger(dtNowWrk.Rows[0]["TT_WLEN"].ToString());
            }

            if (string.IsNullOrEmpty(dtNowWrk.Rows[0]["TT_VLEN"].ToString()))
            {
                gsTT_VLEN = lblWO_VLEN.Text.ToString();   // 모든 실적 취소한경우 규격이 빈상태로 들어와서, 재단 세로길이를 표시함
            }
            else
            {
                gsTT_VLEN = Common.StrFormatInteger(dtNowWrk.Rows[0]["TT_VLEN"].ToString());
            }

            // 수재단 이동시 수재단 규격 입력 팝업 호출....
            lblPF_TT_WLEN.Text = gsTT_WLEN;
            lblPF_TT_VLEN.Text = gsTT_VLEN;

            lblPF_TT_NAME.Visible = true;
            lblPF_TT_WLEN.Visible = true;
            lblPF_TT_VLEN.Visible = true;

            //lblPF_TT_WLEN.BackColor = Color.LightSteelBlue;
            //lblPF_TT_VLEN.BackColor = Color.LightSteelBlue;

            lblPF_TT_WLEN.Enabled = true;
            lblPF_TT_VLEN.Enabled = true;
        }

        private void DoFind02()
        {
            if (Grid1.Rows.Count < 1)
            {
                return;
            }

            if (Grid1.Row == null)
            {
                return;
            } 

            DBHelper helper = new DBHelper();
            DataSet dsRtn = new DataSet();
            DataTable dtTemp = new DataTable();

            try
            {
                string sMIND_BCD = "";      // 밀롤 개별바코드
                string sMORDER_NO = "";     // 밀롤 오더번호

                sMIND_BCD = Grid1.Row.Cells["IND_BCD"].Value.ToString();        // 밀롤 개별바코드
                sMORDER_NO = Grid1.Row.Cells["ORDER_NO"].Value.ToString();      // 밀롤 오더번호

                if (continuWork == true)
                {
                    dsRtn = helper.FillDataSetN("SP_POP_WRK26_S12", CommandType.StoredProcedure, 2
                                                        , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)          // 플랜트코드
                                                        , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)      // 작업장코드(설비코드)
                                                        , helper.CreateParameter("P_IND_BCD_M", sMIND_BCD, DbType.String, ParameterDirection.Input)             // 밀롤 개별바코드
                                                        , helper.CreateParameter("P_ORDER_NO_M", sMORDER_NO, DbType.String, ParameterDirection.Input)         // 밀롤 오더번호
                                                        , helper.CreateParameter("P_WRK_ORDR_NO_CA", lblWO_WRK_ORDR_NO.Text.ToString(), DbType.String, ParameterDirection.Input)       // 재단 작업지시번호
                                                        , helper.CreateParameter("P_WRK_ORDR_SEQNO_CA", lblWO_WRK_ORDR_SEQNO.Text.ToString(), DbType.String, ParameterDirection.Input) // 재단 작업지시순번
                                                        );
                }
                else
                {
                    dsRtn = helper.FillDataSetN("SP_POP_WRK26_S02", CommandType.StoredProcedure, 2
                                                        , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)          // 플랜트코드
                                                        , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)      // 작업장코드(설비코드)
                                                        , helper.CreateParameter("P_IND_BCD_M", sMIND_BCD, DbType.String, ParameterDirection.Input)             // 밀롤 개별바코드
                                                        , helper.CreateParameter("P_ORDER_NO_M", sMORDER_NO, DbType.String, ParameterDirection.Input)         // 밀롤 오더번호
                                                        , helper.CreateParameter("P_WRK_ORDR_NO_CA", lblWO_WRK_ORDR_NO.Text.ToString(), DbType.String, ParameterDirection.Input)       // 재단 작업지시번호
                                                        , helper.CreateParameter("P_WRK_ORDR_SEQNO_CA", lblWO_WRK_ORDR_SEQNO.Text.ToString(), DbType.String, ParameterDirection.Input) // 재단 작업지시순번
                                                        );
                }


                //버튼 상태 변경
                if (helper.RSCODE.Equals("S"))
                {
                    dtTemp = dsRtn.Tables[0].Copy();     // 투입정보 테이블
                    if (dtTemp.Rows.Count > 0)
                    {
                        lblIN_PRFM_WGT.Text = Common.StrFormatDouble(dtTemp.Rows[0]["PRFM_QTY"].ToString()); //실적량
                        lblIN_USE_WGT.Text = Common.StrFormatDouble(dtTemp.Rows[0]["USE_QTY"].ToString()); //사용량
                        lblIN_DISPO_QTY.Text = Common.StrFormatDouble(dtTemp.Rows[0]["DISPO_QTY"].ToString()); //폐품량
                        lblIN_AVA_WGT.Text = Common.StrFormatDouble(dtTemp.Rows[0]["ABLE_QTY"].ToString()); //가용량
                        //lblIN_AVA_WGT.Tag = dtTemp.Rows[0]["ABLE_QTY"].ToString();
                        txtIN_REMARK.Text = dtTemp.Rows[0]["RMK"].ToString().Replace("|", "\r\n"); //작업자 비고

                        // 재단 작업지시에  계획잔량, 및 (실적량+폐품량) 표시
                        lblWO_PERF_DISPO_REAM.Text = Common.StrFormatDouble(dtTemp.Rows[0]["WO_QTY_CA"].ToString()); //실적연수+폐품연수
                        lblWO_PERF_DISPO_WGT.Text = Common.StrFormatDouble(dtTemp.Rows[0]["WO_WGT_CA"].ToString()); //실적량+폐품량

                        PrdWgtCalculation();
                    }
                    else
                    {
                        lblIN_PRFM_WGT.Text = ""; //실적량
                        lblIN_USE_WGT.Text = ""; //사용량
                        lblIN_DISPO_QTY.Text = ""; //폐품량
                        lblIN_AVA_WGT.Text = ""; //가용량
                        txtIN_REMARK.Text = ""; //작업자 비고

                        lblWO_PERF_DISPO_REAM.Text = "";
                        lblWO_PERF_DISPO_WGT.Text = "";
                        lblWO_RESI_REAM.Text = "";
                        lblWO_RESI_WGT.Text = "";
                    }
                }
                else
                {
                    lblIN_PRFM_WGT.Text = ""; //실적량
                    lblIN_USE_WGT.Text = ""; //사용량
                    lblIN_DISPO_QTY.Text = ""; //폐품량
                    lblIN_AVA_WGT.Text = ""; //가용량
                    txtIN_REMARK.Text = ""; //작업자 비고

                    lblWO_PERF_DISPO_REAM.Text = "";
                    lblWO_PERF_DISPO_WGT.Text = "";
                    lblWO_RESI_REAM.Text = "";
                    lblWO_RESI_WGT.Text = "";
                    new POPUP.MessageForm(helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return;
                }

            }
            catch (Exception ex)
            {
                lblIN_PRFM_WGT.Text = ""; //실적량
                lblIN_USE_WGT.Text = ""; //사용량
                lblIN_DISPO_QTY.Text = ""; //폐품량
                lblIN_AVA_WGT.Text = ""; //가용량
                txtIN_REMARK.Text = ""; //작업자 비고

                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                LogFile.WriteLog("DoFind02.SetGrid Error => " + ex.Message);
            }
        }

        private void InitControl_IN()
        {
            // 투입정보
            lblIN_WRK_ORDR.Text = string.Empty;           // LOT NO
            lblIN_PCODE.Text = string.Empty;            // 지종
            lblIN_BS_WGT.Text = string.Empty;           // 평량
            lblIN_MWIDTH.Text = string.Empty;           // 지폭
            txtIN_REMARK.Text = string.Empty;        // 비고
            
            lblIN_PRFM_WGT.Text = string.Empty;         // 실적량
            lblIN_USE_WGT.Text = string.Empty;          // 사용량
            lblIN_DISPO_QTY.Text = string.Empty;        // 폐품량
            lblIN_AVA_WGT.Text = string.Empty;          // 가용량

            //lblMACH_STA.Text = "대기중";

            Common.OrderNo = string.Empty;//생산오더번호
            Common.WrkOrderNo = string.Empty;//작업지시번호
            Common.WrkOrderSeq = string.Empty;//작업지시순번
            Common.ItemCode = string.Empty; //자재코드
            Common.LotNo = string.Empty; // lot no
        }

        private void InitControl_WO()
        {
            // 재단 작업지시
            lblWO_WRK_ORDR_NO.Text = string.Empty;      // 작업지시번호-순번
            lblWO_WRK_ORDR_SEQNO.Text = string.Empty;   // 작업지시번호-순번
            lblWO_MATNR.Text = string.Empty;            // 자재코드
            lblWO_WLEN.Text = string.Empty;             // 재단규격 가로
            lblWO_VLEN.Text = string.Empty;             // 재단규격 세로
            lblPF_TT_WLEN.Text = string.Empty;
            lblPF_TT_VLEN.Text = string.Empty;

            lblWO_CON_TYPE.Text = string.Empty;         // 컨테이너 유형
            lblWO_PACKTYPE.Text = string.Empty;         // 포장타입
            lblWO_DOMESTIC.Text = string.Empty;         // 내수구분
            lblWO_PRD_REQ_DT.Text = string.Empty;       // 생산지시일

            lblWO_PRD_REAM.Text = string.Empty;         // 계획정보 연수
            lblWO_PRD_WGT.Text = string.Empty;          // 계획정보 중량
            lblWO_RESI_REAM.Text = string.Empty;        // 계획잔량 연수
            lblWO_RESI_WGT.Text = string.Empty;         // 계획잔량 중량
            lblWO_PERF_DISPO_REAM.Text = string.Empty;  // 실적+폐품 연수 
            lblWO_PERF_DISPO_WGT.Text = string.Empty;   // 실적+폐품 중량

            lblWO_CUST_NM.Text = string.Empty;          // 거래처
            lblWO_MWIDTH.Text = string.Empty;           // 밀롤 지폭
            lblWO_PKCNT.Text = string.Empty;            // 폭수
            lblWO_PLT_PER_CNT.Text = string.Empty;      // 팔레트당 연수
            lblWO_PLT_EA.Text = string.Empty;           // 계획실적 팔레트수
            lblWO_IN_PER_CNT.Text = string.Empty;       // 속당매수
            lblWO_SCNT.Text = string.Empty;             // 속
            lblWO_MCNT.Text = string.Empty;             // 매수

            gsMAN_CUT_YN = "";


            lblPF_PLT_REAM.Text = "0";
            lblPF_PLT_EA.Text = "1";
            lblPF_TOT_REAM.Text = "0";
            lblPF_TOT_WGT.Text = "0";
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
                bBox1[0, 9].Text = "라벨병합";
                bBox1[0, 9].Tag = "LBMerge";
                bBox1[0, 9].MappingButton.FontSize = 14;
                bBox1[0, 10].Text = "실적현황";
                bBox1[0, 10].Tag = "Performance";
                bBox1[0, 10].MappingButton.FontSize = 14;

                bBox1.RedrawButtons();
            }
            catch (Exception ex)
            {
                SetMessage("SetButtons Error!");
                LogFile.WriteLog("POP_WRK26.SetButtons Error => " + ex.ToString());
            }
        }


        private void UpdateGrid()
        {
            SetGrid();
            DoFind();
            DoFind02();
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
            if (pType.Contains("O") && string.IsNullOrEmpty(lblIN_WRK_ORDR.Text.ToString()))
            {
                new POPUP.MessageForm("투입정보가 없습니다.\r\n작업지시를 선택하여 주시기 바랍니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
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
            DBHelper helper = new DBHelper(false);
            string sMSG = string.Empty;

            //팝업 변수
            POPUP.MessageForm msgForm = null;
            DialogResult res = DialogResult.Cancel;

            try
            {
                if (!lblMACH_STA.Text.Equals("대기중"))
                {
                    new POPUP.MessageForm("가동중인 작업지시가 있습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return;
                }

                // 작업 시작일시 확인
                string sStartDate = dtpStartDate.Value.ToString("yyyyMMdd") + lblStartTime.Text.ToString().Replace(":", "") + "00";
                DateTime dtStartTime;
                if (DateTime.TryParseExact(sStartDate, "yyyyMMddHHmmss", null, DateTimeStyles.AssumeLocal, out dtStartTime) == false)
                {
                    new POPUP.MessageForm("작업 시작일시 확인하세요!", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return;
                }

                msgForm = new POPUP.MessageForm("작업지시를 시작 하시겠습니까?", MessageBoxButtons.OKCancel, "알   림");
                res = msgForm.ShowDialog(this);
                if (res == System.Windows.Forms.DialogResult.OK)
                {
                    //작업시작 (작업지시 상태변경 및 작업장 현황의 가동상태 변경)
                    helper.ExecuteNoneQuery("SP_POP_WRK26_I01", CommandType.StoredProcedure
                                                    , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)               // 플랜트
                                                    , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)           // 작업장코드(설비코드)
                                                    , helper.CreateParameter("P_SDATE", sStartDate, DbType.String, ParameterDirection.Input)                     // 작업시작일시
                                                    , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input)                 // 사용자ID
                                                    );

                    if (helper.RSCODE == "E")
                    {
                        new POPUP.MessageForm(helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                        return;
                    }

                    sMSG = "작업지시가 정상적으로 시작 되었습니다.";
                    new POPUP.MessageForm(sMSG, MessageBoxButtons.OK, "알   림").ShowDialog(this);

                    lblMACH_STA.Text = "가동중";
                    gbMAT_TRANS = true;
                    //UpdateGrid();
                    //AutoCalculation();
                }
            }
            catch (Exception ex)
            {
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                //SetMessage("SetGrid Error!");
                LogFile.WriteLog("POP_WRK26.SetGrid Error => " + ex.Message);
            }
            finally
            {
                helper.Close();
            }
        }


        private DataTable setReqWorkList(int iPLT_EA, string sStartDate, string sEndDate, string sTM, string sMRCOM_YN)
        {
            DataTable dtRtn = new DataTable();
            DataRow dtTempRow;

            int iWLEN;
            int iVLEN;

            int.TryParse(lblWO_WLEN.Text.ToString().Replace(",", ""), out iWLEN);       // 가로길이
            int.TryParse(lblWO_VLEN.Text.ToString().Replace(",", ""), out iVLEN);       // 세로길이

            try
            {
                //테이블 컬럼명 작성
                dtRtn.Columns.Add(new DataColumn("NO", typeof(int)));                   //순서

                dtRtn.Columns.Add(new DataColumn("PRD_STR_DATE", typeof(string)));      //작업시작일시
                dtRtn.Columns.Add(new DataColumn("PRD_END_DATE", typeof(string)));      //작업종료일시
                dtRtn.Columns.Add(new DataColumn("PRFM_QTY", typeof(string)));          //실적수량(연수)
                dtRtn.Columns.Add(new DataColumn("PRFM_PLT", typeof(string)));          //실적수량(연수)
                dtRtn.Columns.Add(new DataColumn("TM", typeof(string)));                //가동시간(분)

                dtRtn.Columns.Add(new DataColumn("WLEN", typeof(string)));              //가로길이
                dtRtn.Columns.Add(new DataColumn("VLEN", typeof(string)));              //세로길이
                dtRtn.Columns.Add(new DataColumn("BS_WGT", typeof(string)));            //평량
                dtRtn.Columns.Add(new DataColumn("TT_WLEN", typeof(string)));           //가로길이(실재단규격) 수재단사용
                dtRtn.Columns.Add(new DataColumn("TT_VLEN", typeof(string)));           //세로길이(실재단규격) 수재단사용

                //dtRtn.Columns.Add(new DataColumn("WGT", typeof(string)));               //중량
                dtRtn.Columns.Add(new DataColumn("DISPO_QTY1", typeof(string)));        //폐품권치수
                dtRtn.Columns.Add(new DataColumn("DISPO_WGT1", typeof(string)));        //폐품중량
                dtRtn.Columns.Add(new DataColumn("DISPO_CD1", typeof(string)));         //폐품코드
                dtRtn.Columns.Add(new DataColumn("DISPO_NM1", typeof(string)));         //폐품코드

                dtRtn.Columns.Add(new DataColumn("DISPO_QTY2", typeof(string)));        //폐품권치수
                dtRtn.Columns.Add(new DataColumn("DISPO_WGT2", typeof(string)));        //폐품중량
                dtRtn.Columns.Add(new DataColumn("DISPO_CD2", typeof(string)));         //폐품코드
                dtRtn.Columns.Add(new DataColumn("DISPO_NM2", typeof(string)));         //폐품코드

                dtRtn.Columns.Add(new DataColumn("RMK", typeof(string)));               //비고
                dtRtn.Columns.Add(new DataColumn("CACOM_YN", typeof(string)));          //재단완료여부
                dtRtn.Columns.Add(new DataColumn("LAST_YN", typeof(string)));           //마지막품목(품목교체)여부
                dtRtn.Columns.Add(new DataColumn("MOVE_YN", typeof(string)));           //수재단이동여부
                dtRtn.Columns.Add(new DataColumn("IND_BCD_M", typeof(string)));         //밀롤 개별바코드
                dtRtn.Columns.Add(new DataColumn("MATRN_M", typeof(string)));           //밀롤 자재코드
                dtRtn.Columns.Add(new DataColumn("LOT_NO_M", typeof(string)));          //밀롤 LOT_NO
                dtRtn.Columns.Add(new DataColumn("WRK_ORDR_NO_M", typeof(string)));     //밀롤 작업지시번호
                dtRtn.Columns.Add(new DataColumn("WRK_ORDR_SEQNO_M", typeof(string)));  //밀롤 작업지시순번
                dtRtn.Columns.Add(new DataColumn("SEQNO", typeof(string)));             //투입순번

                Decimal dPallet = 0, dReamNum = 0;
                Decimal.TryParse(lblPF_PLT_EA.Text.Replace(",", ""), out dPallet);

                int nWoPkCnt = int.TryParse(lblWO_PKCNT.Text.ToString().Replace(",", ""), out nWoPkCnt) ? nWoPkCnt : 1;                // 폭수

                int iPallet = (int)Math.Ceiling(dPallet);       // 팔레트 정보가 실수인경우 올림 처림

                for (int i = 0; i < iPallet; i++)
                {
                    //조회결과 입력용 Row생성
                    dtTempRow = dtRtn.NewRow();

                    dtTempRow["NO"] = (i + 1).ToString();         //순서

                    dtTempRow["PRD_STR_DATE"] = sStartDate;                                     //작업시작일시
                    dtTempRow["PRD_END_DATE"] = sEndDate;                                       //작업종료일시

                    dtTempRow["TM"] = sTM;                                                      //가동시간(분)

                    dtTempRow["WLEN"] = string.Format("{0}", (int)iWLEN);                       //가로길이
                    dtTempRow["VLEN"] = string.Format("{0}", (int)iVLEN);                       //세로길이
                    dtTempRow["BS_WGT"] = lblIN_BS_WGT.Text.ToString().Replace(",", "");        //평량

                    dtTempRow["TT_WLEN"] = lblPF_TT_WLEN.Text.ToString().Replace(",", "");       //가로길이(실재단규격) 수재단사용
                    dtTempRow["TT_VLEN"] = lblPF_TT_VLEN.Text.ToString().Replace(",", "");       //세로길이(실재단규격) 수재단사용


                    // 마지막품목교체 체크된경우
                    string sWrkOrdrRmk = "";

                    if (lblMoveTTChk.Text.Equals("V"))
                    {
                        sWrkOrdrRmk = "[수재단이동]";
                    }
                    dtTempRow["MOVE_YN"] = lblMoveTTChk.Text.Equals("V") ? "Y" : "N";       // 수재단이동

                    dtTempRow["PRFM_PLT"] = "1";          //팔레트 개수
                    //dtTempRow["PRFM_PLT"] = lblPF_PLT_EA.Text.ToString().Replace(",", "");          //팔레트 개수

                    Decimal.TryParse(lblPF_PLT_REAM.Text.ToString().Replace(",", ""), out dReamNum);  //팔레트 연수

                    //dtTempRow["PRFM_QTY"] = lblPF_PLT_REAM.Text.ToString().Replace(",", "");        //팔레트 연수


                    // 작업지시의 폭수가 2인경우 '마지막품목교체' 를 2팔레트에 출력한다. 단, 실적을 1개만 잡으면 1팔레트에 출력됨.
                    if(nWoPkCnt >= iPallet - i) {
                        // 마지막 팔렛트에 입력
                        if (lblLastChk.Text.Equals("V"))
                        {
                            sWrkOrdrRmk += "[마지막품목교체]";         //비고내용에 [마지막품목교체] 내용 추가
                        }
                    }



                    // 팔렛트 당 계산
                    if (i == (iPallet - 1)) // 마지막 팔레트
                    {
                        if ( (dPallet % 1) == 0)    // 정수인지 확인
                        {
                            dtTempRow["PRFM_QTY"] = dReamNum.ToString();             //팔레트 연수
                        }
                        else
                        {
                            dtTempRow["PRFM_QTY"] = ((dPallet - i) * dReamNum).ToString();  //팔레트 연수
                        }

                        dtTempRow["LAST_YN"] = lblLastChk.Text.Equals("V") ? "Y" : "N";  // 마지막품목교체
                        dtTempRow["CACOM_YN"] = sMRCOM_YN;                               //재단완료여부 (투입)
                    }
                    else
                    {
                        dtTempRow["PRFM_QTY"] = dReamNum.ToString();             //팔레트 연수

                        dtTempRow["LAST_YN"] =  "N";   // 마지막품목교체
                        dtTempRow["CACOM_YN"] = "N";   // 재단완료여부 (투입)
                    }

                    dtTempRow["RMK"] = sWrkOrdrRmk + lblPF_WRK_ORDR_RMK.Text.ToString(); // 비고

                    // 폐품은 처음 한번만 입력
                    if(i == 0) 
                    {
                        dtTempRow["DISPO_QTY1"] = lblPF_DISPO_REAM_01.Text.ToString().Replace(",", "");   // 폐품연수
                        dtTempRow["DISPO_WGT1"] = lblPF_DISPO_WGT_01.Text.ToString().Replace(",", "");    // 폐품중량
                        dtTempRow["DISPO_CD1"] = lblPF_DISPO_CODE_01.Tag;              // 폐품코드
                        dtTempRow["DISPO_NM1"] = lblPF_DISPO_CODE_01.Text.ToString();  // 폐품명

                        dtTempRow["DISPO_QTY2"] = lblPF_DISPO_REAM_02.Text.ToString().Replace(",", "");  // 폐품연수
                        dtTempRow["DISPO_WGT2"] = lblPF_DISPO_WGT_02.Text.ToString().Replace(",", "");   // 폐품중량
                        dtTempRow["DISPO_CD2"] = lblPF_DISPO_CODE_02.Tag;              // 폐품코드
                        dtTempRow["DISPO_NM2"] = lblPF_DISPO_CODE_02.Text.ToString();  // 폐품명
                    }
                    else 
                    {
                        dtTempRow["DISPO_QTY1"] = string.Empty;   // 폐품연수
                        dtTempRow["DISPO_WGT1"] = string.Empty;   // 폐품중량
                        dtTempRow["DISPO_CD1"] = string.Empty;    // 폐품코드
                        dtTempRow["DISPO_NM1"] = string.Empty;    // 폐품명

                        dtTempRow["DISPO_QTY2"] = string.Empty;   // 폐품연수
                        dtTempRow["DISPO_WGT2"] = string.Empty;   // 폐품중량
                        dtTempRow["DISPO_CD2"] = string.Empty;    // 폐품코드
                        dtTempRow["DISPO_NM2"] = string.Empty;    // 폐품명
                    }

                    //dtTempRow["CACOM_YN"] = sMRCOM_YN;

                    dtTempRow["IND_BCD_M"] = Grid1.Row.Cells["IND_BCD"].Value.ToString();  //밀롤 개별바코드
                    dtTempRow["MATRN_M"] = Grid1.Row.Cells["MATNR"].Value.ToString();      //밀롤 자재코드
                    dtTempRow["LOT_NO_M"] = Grid1.Row.Cells["LOT_NO"].Value.ToString();    //밀롤 LOT 번호

                    dtTempRow["WRK_ORDR_NO_M"] = Common.WrkOrderNo;                        //밀롤 작업지시번호
                    dtTempRow["WRK_ORDR_SEQNO_M"] = Common.WrkOrderSeq;                    //밀롤 작업지시순번
                    dtTempRow["SEQNO"] = Grid1.Row.Cells["SEQNO"].Value.ToString();        //투입순번

                    //결과 테이블에 저장
                    dtRtn.Rows.Add(dtTempRow);
                }

                // 실적순서 별로 테이블 SORT 하여 리턴
                DataView dv = new DataView(dtRtn);
                dv.Sort = "NO ASC";
                dtRtn = dv.ToTable();
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return dtRtn;
        }

        // 영업폐품 포함하여 가용량 을 넘는지 검사
        private bool ValidationSalesDispo()
        {
            Decimal dIN_AVA_WGT = 0;     // 가용량
            Decimal dPF_TOT_WGT = 0;
            Decimal dPF_DISPO_WGT_01 = 0;
            Decimal dPF_DISPO_WGT_02 = 0;
            Decimal dPF_SALES_DISPO_WGT = 0;  // 영업폐품

            Decimal dMWIDTH = 0;    // 실지폭
            Decimal dBS_WGT = 0;    // 평량
            Decimal dWLEN = 0;      // 가로길이
            Decimal dVLEN = 0;      // 세로길이
            Decimal dPKCNT = 0;     // 폭수

            Decimal dTOT_REAM = 0;
            Decimal dDISP_REAM_01 = 0;
            Decimal dDISP_REAM_02 = 0;

            Decimal.TryParse(lblPF_TOT_REAM.Text.ToString().Replace(",", ""), out dTOT_REAM);           // 실적연수
            Decimal.TryParse(lblPF_DISPO_REAM_01.Text.ToString().Replace(",", ""), out dDISP_REAM_01);   // 폐품연수1
            Decimal.TryParse(lblPF_DISPO_REAM_02.Text.ToString().Replace(",", ""), out dDISP_REAM_02);   // 폐품연수2
            
            if( (dTOT_REAM + dDISP_REAM_01 + dDISP_REAM_02)  <= 0)
            {
                new POPUP.MessageForm(string.Format("실적(폐품포함) 연수 입력은 필수 입니다."), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return false;
            }

            Decimal.TryParse(lblIN_AVA_WGT.Text.ToString().Replace(",", ""), out dIN_AVA_WGT); 
            Decimal.TryParse(lblPF_TOT_WGT.Text.ToString().Replace(",", ""), out dPF_TOT_WGT);            // 실적중량
            Decimal.TryParse(lblPF_DISPO_WGT_01.Text.ToString().Replace(",", ""), out dPF_DISPO_WGT_01);  // 폐품연수 1
            Decimal.TryParse(lblPF_DISPO_WGT_02.Text.ToString().Replace(",", ""), out dPF_DISPO_WGT_02);  // 폐품연수 2

            //dPF_SALES_DISPO_WGT
            Decimal.TryParse(lblIN_MWIDTH.Text.ToString().Replace(",", ""), out dMWIDTH);  // 실지폭
            Decimal.TryParse(lblIN_BS_WGT.Text.ToString().Replace(",", ""), out dBS_WGT);  // 평량
            Decimal.TryParse(lblWO_WLEN.Text.ToString().Replace(",", ""), out dWLEN);      // 가로길이
            Decimal.TryParse(lblWO_VLEN.Text.ToString().Replace(",", ""), out dVLEN);      // 세로길이
            Decimal.TryParse(lblWO_PKCNT.Text.ToString().Replace(",", ""), out dPKCNT);    // 폭수

            if ((dWLEN * dPKCNT) < dMWIDTH)
            {
                if (dBS_WGT <= 0 || dWLEN <= 0 || dVLEN <= 0 || dPKCNT <= 0)
                {
                    dPF_SALES_DISPO_WGT = 0;
                }
                else
                {
                    try
                    {
                        Decimal dPallet = 0, dReamNum = 0;

                        Decimal.TryParse(lblPF_PLT_REAM.Text.ToString().Replace(",", ""), out dReamNum);    //팔레트 연수
                        Decimal.TryParse(lblPF_PLT_EA.Text.Replace(",", ""), out dPallet);                  //팔레트 수량

                        int iPallet = (int)Math.Ceiling(dPallet);

                        Decimal dTOT_METER = 0;

                        for (int i = 0; i < iPallet; i++)
                        {
                            Decimal dReam = 0;
                            // 팔렛트 당 계산
                            if (i == (iPallet - 1)) // 마지막 팔레트
                            {
                                dReam = ((dPallet - (Decimal)i) * dReamNum);  //팔레트 연수
                            }
                            else
                            {
                                dReam = dReamNum;
                            }

                            Decimal dWGT = (dReam * 500) * (dBS_WGT / 1000) * (dWLEN / 1000) * (dVLEN / 1000);

                            //재단 총 생산 M =  (재단중량 / 재단폭수) / ((평량 / 1000) * (재단 가로길이 / 1000))
                            dTOT_METER = (dWGT / dPKCNT) / ((dBS_WGT / 1000) * (dWLEN / 1000));

                            //영업폐품 = ( 재단 평량 / 1000 ) * (M/R 지폭 - ( 재단 가로길이 * 재단 폭수 ) ) * 재단 총 생산  M / 1000"
                            Decimal dSD_WGT = Math.Round((dBS_WGT / 1000) * (dMWIDTH - (dWLEN * dPKCNT)) * dTOT_METER / 1000, 3, MidpointRounding.AwayFromZero);

                            // 영업폐품이 0보다 큰경우
                            if (dSD_WGT > 0)
                            {
                                dPF_SALES_DISPO_WGT += dSD_WGT;
                            }
                            Console.WriteLine(string.Format("팔레트별 영업폐품 = {0:#,0.###}", dSD_WGT));
                        }
                    }
                    catch (Exception ex)
                    {
                        dPF_SALES_DISPO_WGT = 0;
                    }
                }
            }
            else
            {
                dPF_SALES_DISPO_WGT = 0;
            }

            Console.WriteLine(string.Format("총중량 = {0:#,0.###}, 영업폐품 = {1:#,0.###}", dPF_TOT_WGT, dPF_SALES_DISPO_WGT));

            Decimal dTOT_WGT_CALC = dPF_TOT_WGT + dPF_DISPO_WGT_01 + dPF_DISPO_WGT_02 + dPF_SALES_DISPO_WGT;
            if (dIN_AVA_WGT < dTOT_WGT_CALC)
            {
                new POPUP.MessageForm(string.Format("실적(폐품포함) 중량 {0:#,0.###} (Kg)값이\r\n가용 중량 {1:#,0.###} (Kg)을 초과하여 입력되었습니다.\r\n\r\n실적(폐품포함) 연수 입력을 확인하세요.", dTOT_WGT_CALC, dIN_AVA_WGT), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                //new POPUP.MessageForm(string.Format("실적(폐품포함) 중량 값이 가용 중량 {0} (Kg)을 초과하여\r\n입력되었습니다.\r\n\r\n실적(폐품포함) 연수 입력을 확인하세요.", dIN_AVA_WGT), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return false;
            }

            return true;
        }

        /// <summary>
        /// 재단 실적등록
        /// </summary>
        private int doProduct()
        {
            DataTable dtList;
            string isFinish = "N";

            // 작업지시 확인
            if (string.IsNullOrEmpty(lblIN_WRK_ORDR.Text.ToString()))
            {
                new POPUP.MessageForm("투입정보가 없습니다.\r\n작업지시 선택후 실적등록 하세요!", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return Common.ERROR_FAIL;
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

            if (ValidationSalesDispo() == false)
            {
                return Common.ERROR_FAIL;
            }

            if (lblMoveTTChk.Text.Equals("V"))
            {
                // 수재단 규격 확인....
                int iTT_WLEN = 0;
                int iTT_VLEN = 0;
                int iWLEN = 0;
                int iVLEN = 0;

                int.TryParse(lblPF_TT_WLEN.Text.ToString().Replace(",", ""), out iTT_WLEN);          // 수재단 가로길이
                int.TryParse(lblPF_TT_VLEN.Text.ToString().Replace(",", ""), out iTT_VLEN);          // 수재단 세로길이

                int.TryParse(lblWO_WLEN.Text.ToString().Replace(",", ""), out iWLEN);                // 가로길이
                int.TryParse(lblWO_VLEN.Text.ToString().Replace(",", ""), out iVLEN);                // 세로길이


                if (iTT_WLEN == 0 || iTT_VLEN == 0)
                {
                    // 수재단 이동 규격 오류
                }

                if (iTT_WLEN == iWLEN && iTT_VLEN == iVLEN)
                {
                    // 재단 규격 과 같습니다.
                }
            }

            // 수재단 이동 처리 팝업 표시............---------------------------------------------------------------------------
            string sMRCOM_YN = "N";
            if (lblEndChk.Text.ToString() == "V")           // 밀롤 완료처리
            {
                sMRCOM_YN = "Y";
            }

            if (sMRCOM_YN.Equals("N"))
            {
                POPUP.MessageForm msgForm;

                if (lblMoveTTChk.Text.Equals("V"))
                    msgForm = new POPUP.MessageForm("수재단 이동 등록\r\n\r\n밀롤 완료 플래그를 체크 하시겠습니까?", MessageBoxButtons.YesNoCancel, "알  림");
                else
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
            }



            Decimal dPLT_REAM = 0;
            Decimal dTOT_REAM = 0;
            Decimal dDISP_REAM_01 = 0;
            Decimal dDISP_REAM_02 = 0;

            Decimal.TryParse(lblPF_PLT_REAM.Text.ToString().Replace(",", ""), out dPLT_REAM);      // 팔레트연수
            Decimal.TryParse(lblPF_TOT_REAM.Text.ToString().Replace(",", ""), out dTOT_REAM);           // 실적연수
            Decimal.TryParse(lblPF_DISPO_REAM_01.Text.ToString().Replace(",", ""), out dDISP_REAM_01);   // 폐품연수1
            Decimal.TryParse(lblPF_DISPO_REAM_02.Text.ToString().Replace(",", ""), out dDISP_REAM_02);   // 폐품연수2

            if (dTOT_REAM == 0)
            {
                if (dPLT_REAM > 0)
                {
                    new POPUP.MessageForm(string.Format("총연수, 총중량 계산 오류\r\n실적 연수를 다시 입력 하세요\r\n"), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return Common.ERROR_FAIL;
                }
            }

            // 0실적 체크용
            bool bZERO_PRFM = false;

            if (sMRCOM_YN == "Y")
            {
                if (dTOT_REAM == 0)
                {
                    if ((dDISP_REAM_01 + dDISP_REAM_02) > 0)
                    {
                        //new POPUP.MessageForm(string.Format("폐품만 등록하여 작업 완료 처리 할수 없습니다.\r\n\r\n작업을 완료 하려면 실적을 추가 하세요."), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                        //return Common.ERROR_FAIL;

                        bZERO_PRFM = true;
                    }
                }
            }

            int iPLT_EA = 0;
            int.TryParse(lblPF_PLT_EA.Text.ToString().Replace(",", ""), out iPLT_EA);          // 팔레트 EA

            dtList = setReqWorkList(iPLT_EA, sStartDate, sEndDate, sTM, sMRCOM_YN);

            string IND_BCD_M = string.Empty;

            // 투입정보를 모두 가져오기
            for (int i = 0; i < Grid1.Rows.Count; i++)
            {
                if ( i == 0)
                    IND_BCD_M = Grid1.Rows[i].Cells["IND_BCD"].Value.ToString();
                else
                    IND_BCD_M = IND_BCD_M + "," + Grid1.Rows[i].Cells["IND_BCD"].Value.ToString();
            }


            DBHelper helper = new DBHelper(false, "", true);
            DataSet dsTemp = new DataSet();//실적등록 결과 수신(0:실적 RFC ID, 1:실적 IF 변수, 2:실적 RFC ID, 3:실적 IF 변수)
            bool bReturn = false;       // 실적 처리 결과
            bool bRetDISPO = false;     // 폐품 처리 결과
            bool bRetSALES_DISPO = false;   // 영업폐품+잔량폐품 처리 결과
            bool bRetINP = false;       // 투입량 처리 결과

            string sMSG_ERR = "";
            string sRES_IND_BCD = "";

            int RET_CODE = Common.ERROR_RFC_FAIL;
            try
            {
                // 작업시작 하고 1회만 체크
                if (gbMAT_TRANS == true)
                {
                    gbMAT_TRANS = false;

                    bool bLGORT_2000 = false;
                    bool bLGORT_2700 = false;           // 

                    LogFile.WriteLog("재단투입 SAP 재고 확인");

                    {
                        SAPHelper sapRFCQuery = new SAPHelper();

                        if (sapRFCQuery.GetStckData("P100", Common.LotNo, Common.ItemCode, "").Equals("S"))
                        {
                            foreach (DataRow dr in sapRFCQuery.rtnTable.Rows)
                            {
                                if (dr["LGORT"].ToString() == "2000")
                                {
                                    bLGORT_2000 = true;
                                    LogFile.WriteLog("재고 위치 : 2000");
                                }
                                else if (dr["LGORT"].ToString() == "2700")
                                {
                                    bLGORT_2700 = true;
                                    LogFile.WriteLog("재고 위치 : 2700");
                                }
                            }
                        }
                        else
                        {
                            LogFile.WriteLog("재단투입 SAP 재고 확인 오류 : 재고이전 skip");
                        }
                    }

                    if (bLGORT_2000 == true)
                    {
                        LogFile.WriteLog("재단투입 재고이전 프로시저 호출");

                        this.Cursor = Cursors.WaitCursor;   //Waitting

                        string[] sARR_IND_BCD = IND_BCD_M.Split(',');

                        foreach (string sIND_BCD in sARR_IND_BCD)
                        {
                            // 재고이전 호출
                            dsTemp = helper.FillDataSetN("SP_POP_WRK26_I09_V01", CommandType.StoredProcedure, 2
                                , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)                  // 플랜트
                                , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)              // 작업장코드(설비코드)
                                , helper.CreateParameter("P_IND_BCD", sIND_BCD, DbType.Double, ParameterDirection.Input)                      // 재고이전할 바코드
                                , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input)                    // 사용자ID
                                , helper.CreateParameter("P_MOVE_FUNC", DbType.String, ParameterDirection.Output, null, 200)                    // 재고이전 함수명
                                );

                            if (helper.RSCODE == "S")
                            {
                                string sRS_MOVE_RFCFN = helper.Parameters["P_MOVE_FUNC"].Value.ToString();

                                if (string.IsNullOrEmpty(sRS_MOVE_RFCFN) == false)
                                {
                                    //SAP 실적 등록
                                    SAPHelper sapRFC = new SAPHelper();
                                    // sapRFC.CallSAPFunc 호출시 helper를 사용하여 내용이 변경됨. 
                                    // 필요한 정보는 sapRFC.CallSAPFunc 호출전에 처리해야함.
                                    if (sapRFC.CallSAPFunc(sRS_MOVE_RFCFN, dsTemp.Tables[0], dsTemp.Tables[1], helper).Equals("S"))
                                    {
                                        //helper.Commit();
                                    }
                                    else
                                    {
                                        // 재고이전할 lot_no  가 2700에 이미 있는경우는 오류 메시지 표시 안함.
                                        if (bLGORT_2700 == false)
                                        {
                                            LogFile.WriteLog("재단 공정투입 재고이전 SAP 오류 [" + sapRFC.rtnMSG + "]");
                                            LogFile.WriteLog("@@@ else 재단 공정투입 재고이전 SAP 오류 [ 개별바코드 : " + sIND_BCD + "]");
                                            new POPUP.MessageForm("재고이전 SAP 오류\r\n" + sapRFC.rtnMSG, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                            return Common.ERROR_FAIL;
                                        }
                                    }
                                }
                            }
                            else
                            {
                                LogFile.WriteLog("@@@ else 재단 공정투입 재고이전 등록 오류 [ 개별바코드 : " + sIND_BCD + "]");
                                new POPUP.MessageForm(helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                return Common.ERROR_FAIL;
                            }
                        }
                    }
                }

                int nPltCnt = dtList.Rows.Count;

                DataTable dtWrkOne = dtList.Clone();

                LogFile.WriteLog("재단 실적 등록 시작", LogType.PROC);

                for (int i = 0; i < nPltCnt; i++)
                {
                    if (i == nPltCnt - 1)
                    {
                        isFinish = "Y";
                    } else
                    {
                        isFinish = "N";
                    }
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
                        string bufferIND_BCD = string.Empty;
                        dtWrkOne.Rows.Clear();
                        dtWrkOne.ImportRow(dtList.Rows[i]);

                        string sJsonWrkList = Common.toJsonFormat("POP_WRK026", dtWrkOne);

                        this.Cursor = Cursors.WaitCursor;   //Waitting

                        string sProcedure = string.Empty;

                        if (gsIN_MR_YN.Equals("Y") == false)
                        {
                            sProcedure = "SP_POP_WRK26_I02";
                        }
                        else
                        {
                            sProcedure = "SP_POP_WRK26_I07";    //수입밀롤
                        }

                        // 밀롤창고 고도화에 의한 오더실적처리인 경우 새로운 프로시져 호출
                        if (continuWork)
                        {
                            if (gsIN_MR_YN.Equals("Y") == false)
                            {
                                sProcedure = "SP_POP_WRK26_I10";
                            }
                            else
                            {
                                sProcedure = "SP_POP_WRK26_I11";
                            }
                        }

                        if (sProcedure == "SP_POP_WRK26_I10" || sProcedure == "SP_POP_WRK26_I11")
                        {
                            dsTemp = helper.FillDataSetN(sProcedure, CommandType.StoredProcedure, 8
                                , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)                              // 플랜트
                                , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)                          // 작업장코드(설비코드)
                                , helper.CreateParameter("P_WRK_ORDR_NO", lblWO_WRK_ORDR_NO.Text.ToString(), DbType.String, ParameterDirection.Input)       // 재단 작업지시번호
                                , helper.CreateParameter("P_WRK_ORDR_SEQNO", lblWO_WRK_ORDR_SEQNO.Text.ToString(), DbType.String, ParameterDirection.Input) // 재단 작업지시순번
                                , helper.CreateParameterOracle("P_WRK_LIST", sJsonWrkList, OracleDbType.Clob, ParameterDirection.Input)                     // 밀롤 실적등록 리스트
                                , helper.CreateParameter("P_WRK_CLASS", Common.WorkClass, DbType.String, ParameterDirection.Input)                          // 작업반
                                , helper.CreateParameter("P_WRK_SHIFT", Common.WorkShift, DbType.String, ParameterDirection.Input)                          // 작업조
                                , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input)                                // 사용자ID
                                , helper.CreateParameter("P_IND_BCD", IND_BCD_M, DbType.String, ParameterDirection.Input)                                // 사용자ID
                                , helper.CreateParameter("P_IS_FINISH", isFinish, DbType.String, ParameterDirection.Input)                                // 마지막 실적 여부
                                , helper.CreateParameter("RS_PRFM_RFCFN", DbType.String, ParameterDirection.Output, null, 200)                              // 실적 RFCFN
                                , helper.CreateParameter("RS_DISPO_RFCFN", DbType.String, ParameterDirection.Output, null, 200)                             // 폐품1+폐품2 RFCFN
                                , helper.CreateParameter("RS_INPUT_RFCFN", DbType.String, ParameterDirection.Output, null, 200)                             // 투입량 RFCFN
                                , helper.CreateParameter("RS_SDISPO_RFCFN", DbType.String, ParameterDirection.Output, null, 200)                            // 영업+잔량폐품 RFCFN ID값
                                , helper.CreateParameter("RS_IND_BCD", DbType.String, ParameterDirection.Output, null, 2000)                                //  RES 개별바코드 리스트
                                );
                        }
                        else
                        {
                            dsTemp = helper.FillDataSetN(sProcedure, CommandType.StoredProcedure, 8
                                , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)                              // 플랜트
                                , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)                          // 작업장코드(설비코드)
                                , helper.CreateParameter("P_WRK_ORDR_NO", lblWO_WRK_ORDR_NO.Text.ToString(), DbType.String, ParameterDirection.Input)       // 재단 작업지시번호
                                , helper.CreateParameter("P_WRK_ORDR_SEQNO", lblWO_WRK_ORDR_SEQNO.Text.ToString(), DbType.String, ParameterDirection.Input) // 재단 작업지시순번
                                , helper.CreateParameterOracle("P_WRK_LIST", sJsonWrkList, OracleDbType.Clob, ParameterDirection.Input)                     // 밀롤 실적등록 리스트
                                , helper.CreateParameter("P_WRK_CLASS", Common.WorkClass, DbType.String, ParameterDirection.Input)                          // 작업반
                                , helper.CreateParameter("P_WRK_SHIFT", Common.WorkShift, DbType.String, ParameterDirection.Input)                          // 작업조
                                , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input)                                // 사용자ID
                                , helper.CreateParameter("P_IND_BCD", IND_BCD_M, DbType.String, ParameterDirection.Input)                                // 사용자ID
                                , helper.CreateParameter("RS_PRFM_RFCFN", DbType.String, ParameterDirection.Output, null, 200)                              // 실적 RFCFN
                                , helper.CreateParameter("RS_DISPO_RFCFN", DbType.String, ParameterDirection.Output, null, 200)                             // 폐품1+폐품2 RFCFN
                                , helper.CreateParameter("RS_INPUT_RFCFN", DbType.String, ParameterDirection.Output, null, 200)                             // 투입량 RFCFN
                                , helper.CreateParameter("RS_SDISPO_RFCFN", DbType.String, ParameterDirection.Output, null, 200)                            // 영업+잔량폐품 RFCFN ID값
                                , helper.CreateParameter("RS_IND_BCD", DbType.String, ParameterDirection.Output, null, 2000)                                //  RES 개별바코드 리스트
                                );
                        }

                        if (helper.RSCODE == "S")
                        {
                            //sRES_IND_BCD += helper.Parameters["RS_IND_BCD"].Value.ToString() + "|";
                            bufferIND_BCD = helper.Parameters["RS_IND_BCD"].Value.ToString() + "|"; // 프린트 바코드 저장 위치 변경 2022-11-08

                            string sRS_PRFM_RFCFN = helper.Parameters["RS_PRFM_RFCFN"].Value.ToString();      // 실적 RFCFN ID
                            string sRS_DISPO_RFCFN = helper.Parameters["RS_DISPO_RFCFN"].Value.ToString();    // 폐품1+폐품2 RFCFN ID
                            string sRS_INPUT_RFCFN = helper.Parameters["RS_INPUT_RFCFN"].Value.ToString();    // 투입량 RFCFN ID
                            string sRS_SDISPO_RFCFN = helper.Parameters["RS_SDISPO_RFCFN"].Value.ToString();    // 영업+잔량폐품 RFCFN ID


                            //SAP 롤백용 추가 CODE 범위 START
                            if (dsTemp.Tables[1].Columns[0].ColumnName != "1")
                            {
                                foreach (DataRow Rows in dsTemp.Tables[1].Rows)
                                {
                                    string rollTempMDOC_NO_1 = Rows["MDOCNO"].ToString();
                                    string rollTempMDOC_SEQNO_1 = Rows["MDOCSEQ"].ToString();
                                    rollTemp.Rows.Add(rollTempMDOC_NO_1, rollTempMDOC_SEQNO_1);
                                }
                            }
                            //재단의 경우 폐품에 개별바코드 생성됨 MES롤백을 위한 문서번호 저장 추가
                            if (dsTemp.Tables[3].Columns[0].ColumnName != "1")
                            {
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
                            //dsTemp.Tables[2];     // 폐품1+폐품2 인터페이스 파라미터
                            //dsTemp.Tables[3];     // 폐품1+폐품2 인터페이스 상세 파라미터
                            //dsTemp.Tables[4];     // 투입량 인터페이스 파라미터
                            //dsTemp.Tables[5];     // 투입량 인터페이스 상세 파라미터
                            //dsTemp.Tables[6];     // 영업폐품+잔량폐품 인터페이스 파라미터
                            //dsTemp.Tables[7];     // 영업폐품+잔량폐품 인터페이스 상세 파라미터
#if  false
                        this.Cursor = Cursors.Default;   //Waitting

                        if (helper.RSCODE == "E")
                        {
                            new POPUP.MessageForm(helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                        }

                        helper.Rollback();
                        return Common.ERROR_FAIL;
#endif

                            // 수재단 이동인경우... 처리 표시...-----------------------------------------------------------------------------------------------------
                            // lblMoveTTChk.Text
                            if (lblMoveTTChk.Text.Equals("V"))
                            {
                                bReturn = true;
                            }
                            else
                            {
                                string sRfcData; //RFC결과 JSON 변환

                                bReturn = false;
                                if ((string.IsNullOrEmpty(sRS_PRFM_RFCFN) == false) || (string.IsNullOrEmpty(sRS_DISPO_RFCFN) == false) || (string.IsNullOrEmpty(sRS_INPUT_RFCFN) == false) || (string.IsNullOrEmpty(sRS_SDISPO_RFCFN) == false))
                                {
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
                                        if (sapRFC_P.CallSAPFunc(sRS_PRFM_RFCFN, dsTemp.Tables[0], dtRFCData, helper).Equals("S"))
                                        {
                                            // ---- 전달시 MBLNR, MJAHR을 replace 처리하여 하나로 받도록함.
                                            sRfcData = Common.toJsonFormat("PUT_WRKRTN", sapRFC_P.rtnTable).Replace("MBLNR", "RUECK").Replace("MJAHR", "RMZHL");

                                            // ----- 생산실적량이 0이면 롤백 테이블에 저장 안함
                                            if (bZERO_PRFM == false)
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
                                                ///helper.Rollback();
                                                LogFile.WriteLog("재단 실적 등록 - SAP 확정문서 등록 오류 [" + helper.RSMSG.ToString());
                                                LogFile.WriteLog("@@@ else if 재단 실적 등록 - SAP 확정문서 등록 오류 [ 개별바코드 " + sRES_IND_BCD + " ]");
                                                sMSG_ERR += "확정문서 등록 오류 : " + helper.RSMSG.ToString() + Environment.NewLine;
                                                //new POPUP.MessageForm("실적 등록 - SAP 확정문서 등록 오류\r\n" + helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                                throw new Exception("SAP_ERROR" + sMSG_ERR);  // SAP 로직 진행중 E 발생시 EXCEPTION THROW
                                            }
                                            else 
                                            {
                                                ///helper.Rollback();
                                                LogFile.WriteLog("재단 실적 등록 - SAP 확정문서 등록 오류 [" + helper.RSMSG.ToString());
                                                LogFile.WriteLog("@@@ else 재단 실적 등록 - SAP 확정문서 등록 오류 [ 개별바코드 : " + helper.RSMSG.ToString() + " ]");
                                                sMSG_ERR += "확정문서 등록 오류 : " + helper.RSMSG.ToString() + Environment.NewLine;
                                                //new POPUP.MessageForm("실적 등록 - SAP 확정문서 등록 오류\r\n" + helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                                throw new Exception("SAP_ERROR" + sMSG_ERR);  // SAP 로직 진행중 E 발생시 EXCEPTION THROW
                                            }

                                        }
                                        else
                                        {
                                            //helper.Rollback();
                                            LogFile.WriteLog("재단 실적 등록 - SAP 전송 실패 [" + sapRFC_P.rtnMSG);
                                            LogFile.WriteLog("@@@ else 재단 실적 등록 - SAP 전송 실패 [ 개별바코드 : " + sRES_IND_BCD + " ]");
                                            sMSG_ERR += "실적 등록 오류 : " + sapRFC_P.rtnMSG + Environment.NewLine;
                                            //new POPUP.MessageForm("실적 - 등록 SAP전송이 실패하였습니다.\r\n" + sapRFC_P.rtnMSG, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                            throw new Exception("SAP_ERROR" + sMSG_ERR);  // SAP 로직 진행중 E 발생시 EXCEPTION THROW
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
                                    if (/*(bReturn == true) &&*/ (string.IsNullOrEmpty(sRS_DISPO_RFCFN) == false))
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
                                        if (sapRFC_D.CallSAPFunc(sRS_DISPO_RFCFN, dsTemp.Tables[2], dtRFCData, helper).Equals("S"))
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
                                                                                , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)                // 플랜트
                                                                                , helper.CreateParameter("P_WRK_TYPE", "1", DbType.String, ParameterDirection.Input)                  // '0'= 실적테이블_비계획생산, '1'= 폐품테이블, '2'=소요량, '3'=비가동, '9'=영업폐품+잔량폐품
                                                                                , helper.CreateParameterOracle("P_RFC_DATA", sRfcData, OracleDbType.Clob, ParameterDirection.Input)
                                                                                , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input));

                                            if (helper.RSCODE == "S")
                                            {
                                                bRetDISPO = true;
                                            }
                                            else //if (helper.RSCODE == "E")
                                            {
                                                //helper.Rollback();    // 실적이 성공이면 rollback 처리 안함.
                                                LogFile.WriteLog("재단 실적 등록(폐품) - SAP 확정문서 등록 오류 [" + helper.RSMSG.ToString() + " ]");
                                                LogFile.WriteLog("@@@ else 재단 실적 등록(폐품) - SAP 확정문서 등록 오류 [ 개별바코드 : " + sRES_IND_BCD + " ]");
                                                sMSG_ERR += "확정문서 등록(폐품) 오류 : " + helper.RSMSG.ToString() + Environment.NewLine;
                                                throw new Exception("SAP_ERROR" + sMSG_ERR);  // SAP 로직 진행중 E 발생시 EXCEPTION THROW
                                                //new POPUP.MessageForm("실적 등록(폐품) - SAP 확정문서 등록 오류\r\n" + helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                            }
                                        }
                                        else
                                        {
                                            //helper.Rollback();    // 실적이 성공이면 rollback 처리 안함.
                                            LogFile.WriteLog("재단 실적 등록(폐품) - SAP전송 오류 [" + sapRFC_D.rtnMSG + " ]");
                                            LogFile.WriteLog("@@@ else 재단 실적 등록(폐품) - SAP전송 오류 [ 개별바코드 : " + sRES_IND_BCD + " ]");
                                            sMSG_ERR += "실적 등록(폐품) 오류 : " + sapRFC_D.rtnMSG + Environment.NewLine;
                                            throw new Exception("SAP_ERROR" + sMSG_ERR);  // SAP 로직 진행중 E 발생시 EXCEPTION THROW
                                            //new POPUP.MessageForm("실적 등록(폐품) - SAP전송이 실패하였습니다.\r\n" + sapRFC_D.rtnMSG, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                        }

                                        Thread.Sleep(Common.SLEEP_DELAY);
                                        System.Windows.Forms.Application.DoEvents();        // 반복작업중 응답없음 안뜨게 하기
                                        this.Cursor = Cursors.WaitCursor;   //Waitting
                                    }

                                    // 3. 영업폐품+잔량폐품 등록
                                    if (/*(bReturn == true) &&*/ (string.IsNullOrEmpty(sRS_SDISPO_RFCFN) == false))
                                    {
                                        bRetSALES_DISPO = false;

                                        // 문서번호, 문서순번으로  테이블 SORT 하여 전달
                                        DataTable dtRFCData = new DataTable();
                                        DataView dvPFRM = new DataView(dsTemp.Tables[7]);
                                        dvPFRM.Sort = "MDOCNO, MDOCSEQ ASC";
                                        dtRFCData = dvPFRM.ToTable();

                                        SAPHelper sapRFC_D = new SAPHelper();
                                        // sapRFC.CallSAPFunc 호출시 helper를 사용하여 내용이 변경됨. 
                                        // 필요한 정보는 sapRFC.CallSAPFunc 호출전에 처리해야함.
                                        if (sapRFC_D.CallSAPFunc(sRS_SDISPO_RFCFN, dsTemp.Tables[6], dtRFCData, helper).Equals("S"))
                                        {
                                            // ---- 전달시 MBLNR, MJAHR을 replace 처리하여 하나로 받도록함.
                                            sRfcData = Common.toJsonFormat("PUT_WRKRTN", sapRFC_D.rtnTable).Replace("MBLNR", "RUECK").Replace("MJAHR", "RMZHL");



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
                                                                                , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)                // 플랜트
                                                                                , helper.CreateParameter("P_WRK_TYPE", "9", DbType.String, ParameterDirection.Input)                  // '0'= 실적테이블_비계획생산, '1'= 폐품테이블, '2'=소요량, '3'=비가동, '9'=영업폐품+잔량폐품
                                                                                , helper.CreateParameterOracle("P_RFC_DATA", sRfcData, OracleDbType.Clob, ParameterDirection.Input)
                                                                                , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input));

                                            if (helper.RSCODE == "S")
                                            {
                                                bRetSALES_DISPO = true;
                                            }
                                            else //if (helper.RSCODE == "E")
                                            {
                                                //helper.Rollback();    // 실적이 성공이면 rollback 처리 안함.
                                                LogFile.WriteLog("재단 실적 등록(영업+잔량 폐품) - SAP 확정문서 등록 오류 [" + helper.RSMSG.ToString() + " ]");
                                                LogFile.WriteLog("@@@ else 재단 실적 등록(영업+잔량 폐품) - SAP 확정문서 등록 오류 [ 개별바코드 : " + sRES_IND_BCD + " ]");
                                                sMSG_ERR += "확정문서 등록(영업+잔량 폐품) 오류 : " + helper.RSMSG.ToString() + Environment.NewLine;
                                                //new POPUP.MessageForm("실적 등록(영업+잔량 폐품) - SAP 확정문서 등록 오류\r\n" + helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                                throw new Exception("SAP_ERROR" + sMSG_ERR);
                                            }
                                        }
                                        else
                                        {
                                            //helper.Rollback();    // 실적이 성공이면 rollback 처리 안함.
                                            LogFile.WriteLog("재단 실적 등록(영업+잔량 폐품) - SAP전송 오류 [" + sapRFC_D.rtnMSG + " ]");
                                            LogFile.WriteLog("@@@ else 재단 실적 등록(영업+잔량 폐품) - SAP전송 오류 [ 개별바코드 : " + sapRFC_D.rtnMSG + " ]");
                                            sMSG_ERR += "실적 등록(영업+잔량 폐품) 오류 : " + sapRFC_D.rtnMSG + Environment.NewLine;
                                            throw new Exception("SAP_ERROR" + sMSG_ERR);  // SAP 로직 진행중 E 발생시 EXCEPTION THROW
                                            //new POPUP.MessageForm("실적 등록(영업+잔량 폐품) - SAP전송이 실패하였습니다.\r\n" + sapRFC_D.rtnMSG, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                        }

                                        Thread.Sleep(Common.SLEEP_DELAY);
                                        System.Windows.Forms.Application.DoEvents();        // 반복작업중 응답없음 안뜨게 하기
                                        this.Cursor = Cursors.WaitCursor;   //Waitting
                                    }

                                    // 4. 투입량 등록
                                    if (/*(bReturn == true) &&*/ (string.IsNullOrEmpty(sRS_INPUT_RFCFN) == false))
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
                                        if (sapRFC_I.CallSAPFunc(sRS_INPUT_RFCFN, dsTemp.Tables[4], dtRFCData, helper).Equals("S"))
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
                                                //helper.Rollback();
                                                LogFile.WriteLog("재단 실적 등록(투입량) - SAP 확정문서 등록 오류 [" + helper.RSMSG.ToString() + " ]");
                                                LogFile.WriteLog("@@@ else if 재단 실적 등록(투입량) - SAP 확정문서 등록 오류 [ 개별바코드 : " + sRES_IND_BCD + " ]");
                                                sMSG_ERR += "확정문서 등록(투입량) 오류 : " + helper.RSMSG.ToString() + Environment.NewLine;
                                                throw new Exception("SAP_ERROR" + sMSG_ERR);
                                                //new POPUP.MessageForm("실적 등록(투입량) - SAP 확정문서 등록 오류\r\n" + helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                            }
                                            else 
                                            {
                                                //helper.Rollback();
                                                LogFile.WriteLog("재단 실적 등록(투입량) - SAP 확정문서 등록 오류 [" + helper.RSMSG.ToString() + " ]");
                                                LogFile.WriteLog("@@@ else 재단 실적 등록(투입량) - SAP 확정문서 등록 오류 [ 개별바코드 : " + sRES_IND_BCD + " ]");
                                                sMSG_ERR += "확정문서 등록(투입량) 오류 : " + helper.RSMSG.ToString() + Environment.NewLine;
                                                throw new Exception("SAP_ERROR" + sMSG_ERR);
                                                //new POPUP.MessageForm("실적 등록(투입량) - SAP 확정문서 등록 오류\r\n" + helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                            }

                                        }
                                        else
                                        {
                                            //helper.Rollback();
                                            LogFile.WriteLog("재단 실적 등록(투입량) - SAP전송 오류 [" + sapRFC_I.rtnMSG + " ]");
                                            LogFile.WriteLog("@@@ else 재단 실적 등록(투입량) - SAP전송 오류 [ 개별바코드 : " + sRES_IND_BCD + " ]");
                                            sMSG_ERR += "실적 등록(투입량) 오류 : " + sapRFC_I.rtnMSG + Environment.NewLine;
                                            throw new Exception("SAP_ERROR" + sMSG_ERR);
                                            //new POPUP.MessageForm("실적 등록(투입량) - SAP전송이 실패하였습니다.\r\n" + sapRFC_I.rtnMSG, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                        }

                                        Thread.Sleep(Common.SLEEP_DELAY);
                                        System.Windows.Forms.Application.DoEvents();        // 반복작업중 응답없음 안뜨게 하기
                                        this.Cursor = Cursors.WaitCursor;   //Waitting
                                    }
                                }
                            }
                            sRES_IND_BCD += bufferIND_BCD; // 프린트 바코드 저장 위치 변경 2022-11-08
                        }
                        else
                        {
                            this.Cursor = Cursors.Default;   //Waitting

                            //helper.Rollback();
                            LogFile.WriteLog("재단 실적 등록 실패 [" + helper.RSMSG.ToString() + "]");
                            LogFile.WriteLog("@@@ else 재단 실적 등록 실패 [ 개별바코드 : " + sRES_IND_BCD + " ]");
                            new POPUP.MessageForm_ERR("실적등록 오류 발생", "실적 등록 실패\r\n" + helper.RSMSG.ToString(), MessageBoxButtons.OK).ShowDialog(this);

                            return Common.ERROR_FAIL;
                        }
                    }
                    catch (Exception ex)
                    {
                        if (rollTemp.Rows.Count != 0)
                        {
                            ProdRollback(helper, sapTemp, rollTemp, dsTemp, ref sMSG_ERR);
                        }
                        this.Cursor = Cursors.Default;   //Waitting

                        LogFile.WriteLog("@@@ catch 재단 실적 등록 실패 [ 개별바코드 : " + sRES_IND_BCD + " ]");
                        new POPUP.MessageForm_ERR("실적등록 오류", "실적등록 예외 오류\r\n" + ex.ToString() + Environment.NewLine + sMSG_ERR, MessageBoxButtons.OK).ShowDialog(this);
                        break;
                    }

                }


                if (sRES_IND_BCD.Length > 0)
                {
                    if (lblPrintChk.Text.ToString() == "V")     // 자동인쇄 처리
                    {
                        //new POPUP.MessageForm("재단 개별바코드 [" + sRES_IND_BCD + "]", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                        sRES_IND_BCD = sRES_IND_BCD.TrimEnd('|');

                        PrinterManager.PrintCutter(sRES_IND_BCD);
                    }
                    this.Cursor = Cursors.Default;   //Waitting

                    LogFile.WriteLog("재단 실적 등록 성공");

                    if (lblMoveTTChk.Text.Equals("V") && sMSG_ERR.Length == 0)
                        new POPUP.MessageForm("수재단 이동\r\n\r\n실적등록 완료 되었습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    else if (sMSG_ERR.Length == 0)
                    {
                        RET_CODE = Common.ERROR_SUCCESS;
                        new POPUP.MessageForm("실적등록 완료 되었습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    }
                    else if (sMSG_ERR.Length > 0)
                    {
                        //new POPUP.MessageForm("실적등록 부분 성공.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    }
                }

            }
            catch (Exception ex)
            {
                this.Cursor = Cursors.Default;   //Waitting

                //if (bReturn == true)
                //{
                //    helper.Commit();
                //}
                //else
                //{
                //    helper.Rollback();
                //}

                LogFile.WriteLog("재단 실적 등록 예외 오류 [" + ex.Message + "]");
                LogFile.WriteLog("@@@ catch 재단 실적 등록 예외 오류 [ 개별바코드 : " + sRES_IND_BCD + " ]");
                new POPUP.MessageForm("실적 등록 예외 오류\r\n" + ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
            }
            finally
            {
                this.Cursor = Cursors.Default;   //Waitting
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
                // 1.2 폐품1+폐품2 인터페이스
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
                // 1.3 투입량 인터페이스
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
                //1.4 영업폐품+잔량폐품 인터페이스
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
                        switch (Rows["SAP_TYPE"].ToString())
                        {
                            // 2.3  실적 ROLLBACK
                            case "3.PROD_REG_SAP":
                                LogFile.WriteLog("=====3.PROD_REG_SAP=====" + Rows["MDOCNO"].ToString() + "-" + Rows["MDOCSEQ"].ToString(), LogType.PROC);
                                dsTemp = helper.FillDataSetN("SP_POP_WRK26_IFR01", CommandType.StoredProcedure, 2
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
                                    helper.ExecuteNoneQuery("SP_IF_PUT_WRKRTN", CommandType.StoredProcedure
                                    , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)              // 플랜트
                                    , helper.CreateParameter("P_WRK_TYPE", "0", DbType.String, ParameterDirection.Input)                        // '0'= 실적테이블, 비계획생산, '1'= 폐품테이블, '2'=소요량, '3'=비가동,
                                    , helper.CreateParameterOracle("P_RFC_DATA", rsRfcData, OracleDbType.Clob, ParameterDirection.Input)
                                    , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input));

                                    if (helper.RSCODE == "S")
                                    {
                                        LogFile.WriteLog("재단 실적등록 ROLLBACK COMPLETE", LogType.PROC);
                                    }
                                    else //if (helper.RSCODE == "E")
                                    {
                                        LogFile.WriteLog("재단 ROLLBACK 등록 - SAP 확정문서 등록 오류 [" + helper.RSMSG.ToString() + "]");
                                        sMSG_ERR += "ROLLBACK 확정문서 등록 오류 : " + helper.RSMSG.ToString() + Environment.NewLine;
                                    }

                                    // DELAY 
                                    Thread.Sleep(Common.SLEEP_DELAY);
                                    System.Windows.Forms.Application.DoEvents();        // 반복작업중 응답없음 안뜨게 하기
                                }
                                else
                                {
                                    LogFile.WriteLog("재단 ROLLBACK 오류 - SAP전송 오류 [" + sapRFC_1.rtnMSG + "]");
                                    sMSG_ERR += "재단 ROLLBACK 오류 : " + sapRFC_1.rtnMSG + Environment.NewLine;
                                }
                                break;
                            // 2.2  폐품 ROLLBACK
                            case "2.SALV_REG_SAP":
                                LogFile.WriteLog("=====2.SALV_REG_SAP=====" + Rows["MDOCNO"].ToString() + "-" + Rows["MDOCSEQ"].ToString(), LogType.PROC);
                                dsTemp = helper.FillDataSetN("SP_POP_WRK26_IFR02", CommandType.StoredProcedure, 2
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
                                    helper.ExecuteNoneQuery("SP_IF_PUT_WRKRTN", CommandType.StoredProcedure
                                    , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)              // 플랜트
                                    , helper.CreateParameter("P_WRK_TYPE", "0", DbType.String, ParameterDirection.Input)                        // '0'= 실적테이블, 비계획생산, '1'= 폐품테이블, '2'=소요량, '3'=비가동,
                                    , helper.CreateParameterOracle("P_RFC_DATA", rsRfcData, OracleDbType.Clob, ParameterDirection.Input)
                                    , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input));

                                    if (helper.RSCODE == "S")
                                    {
                                        LogFile.WriteLog("재단 폐품등록 ROLLBACK COMPLETE", LogType.PROC);
                                    }
                                    else //if (helper.RSCODE == "E")
                                    {
                                        LogFile.WriteLog("재단 ROLLBACK 등록 - SAP 확정문서 등록 오류 [" + helper.RSMSG.ToString() + "]");
                                        sMSG_ERR += "ROLLBACK 확정문서 등록 오류 : " + helper.RSMSG.ToString() + Environment.NewLine;
                                    }

                                    // DELAY 
                                    Thread.Sleep(Common.SLEEP_DELAY);
                                    System.Windows.Forms.Application.DoEvents();        // 반복작업중 응답없음 안뜨게 하기
                                }
                                else
                                {
                                    LogFile.WriteLog("재단 ROLLBACK 오류 - SAP전송 오류 [" + sapRFC_2.rtnMSG + "]");
                                    sMSG_ERR += "재단 ROLLBACK 오류 : " + sapRFC_2.rtnMSG + Environment.NewLine;
                                }
                                break;
                            // 2.1  잔량폐품 ROLLBACK
                            case "1.SALE_SALV_REG_SAP":
                                LogFile.WriteLog("=====1.SALE_SALV_REG_SAP=====" + Rows["MDOCNO"].ToString() + "-" + Rows["MDOCSEQ"].ToString(), LogType.PROC);
                                dsTemp = helper.FillDataSetN("SP_POP_WRK26_IFR03", CommandType.StoredProcedure, 2
                                       , helper.CreateParameter("P_DOC_NO", Rows["MDOCNO"].ToString(), DbType.String, ParameterDirection.Input)
                                       , helper.CreateParameter("P_DOC_SEQNO", Rows["MDOCSEQ"].ToString(), DbType.String, ParameterDirection.Input)
                                       , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input)
                                       , helper.CreateParameter("RS_RFCFN", DbType.String, ParameterDirection.Output, null, 30)
                                        );
                                string sRS_RFCFN_3 = helper.Parameters["RS_RFCFN"].Value.ToString();
                                SAPHelper sapRFC_3 = new SAPHelper();
                                if (sapRFC_3.CallSAPFunc(sRS_RFCFN_3, dsTemp.Tables[0], dsTemp.Tables[1], helper).Equals("S"))
                                {
                                    rsRfcData = Common.toJsonFormat("PUT_WRKRTN", sapRFC_3.rtnTable).Replace("MBLNR", "RUECK").Replace("MJAHR", "RMZHL");
                                    helper.ExecuteNoneQuery("SP_IF_PUT_WRKRTN", CommandType.StoredProcedure
                                    , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)              // 플랜트
                                    , helper.CreateParameter("P_WRK_TYPE", "0", DbType.String, ParameterDirection.Input)                        // '0'= 실적테이블, 비계획생산, '1'= 폐품테이블, '2'=소요량, '3'=비가동,
                                    , helper.CreateParameterOracle("P_RFC_DATA", rsRfcData, OracleDbType.Clob, ParameterDirection.Input)
                                    , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input));

                                    if (helper.RSCODE == "S")
                                    {
                                        LogFile.WriteLog("재단 영업폐품 ROLLBACK COMPLETE", LogType.PROC);
                                    }
                                    else //if (helper.RSCODE == "E")
                                    {
                                        LogFile.WriteLog("재단 ROLLBACK 등록 - SAP 확정문서 등록 오류 [" + helper.RSMSG.ToString() + "]");
                                        sMSG_ERR += "ROLLBACK 확정문서 등록 오류 : " + helper.RSMSG.ToString() + Environment.NewLine;
                                    }

                                    // DELAY 
                                    Thread.Sleep(Common.SLEEP_DELAY);
                                    System.Windows.Forms.Application.DoEvents();        // 반복작업중 응답없음 안뜨게 하기
                                }
                                else
                                {
                                    LogFile.WriteLog("재단 ROLLBACK 오류 - SAP전송 오류 [" + sapRFC_3.rtnMSG + "]");
                                    sMSG_ERR += "재단 ROLLBACK 오류 : " + sapRFC_3.rtnMSG + Environment.NewLine;
                                }
                                break;
                            // 2.4 투입량 ROLLBACK
                            case "4.WIP_REG_SAP":
                                LogFile.WriteLog("=====4.WIP_REG_SAP=====" + Rows["MDOCNO"].ToString() + "-" + Rows["MDOCSEQ"].ToString(), LogType.PROC);
                                dsTemp = helper.FillDataSetN("SP_POP_WRK26_IFR04", CommandType.StoredProcedure, 2
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
                                    helper.ExecuteNoneQuery("SP_IF_PUT_WRKRTN", CommandType.StoredProcedure
                                    , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)              // 플랜트
                                    , helper.CreateParameter("P_WRK_TYPE", "0", DbType.String, ParameterDirection.Input)                        // '0'= 실적테이블, 비계획생산, '1'= 폐품테이블, '2'=소요량, '3'=비가동,
                                    , helper.CreateParameterOracle("P_RFC_DATA", rsRfcData, OracleDbType.Clob, ParameterDirection.Input)
                                    , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input));

                                    if (helper.RSCODE == "S")
                                    {
                                        LogFile.WriteLog("재단 투입량 ROLLBACK COMPLETE", LogType.PROC);
                                    }
                                    else //if (helper.RSCODE == "E")
                                    {
                                        LogFile.WriteLog("재단 ROLLBACK 등록 - SAP 확정문서 등록 오류 [" + helper.RSMSG.ToString() + "]");
                                        sMSG_ERR += "ROLLBACK 확정문서 등록 오류 : " + helper.RSMSG.ToString() + Environment.NewLine;
                                    }
                                }
                                else
                                {
                                    LogFile.WriteLog("재단 ROLLBACK 오류 - SAP전송 오류 [" + sapRFC_4.rtnMSG + "]");
                                    sMSG_ERR += "재단 ROLLBACK 오류 : " + sapRFC_4.rtnMSG + Environment.NewLine;
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
                try//MES롤백구간
                {
                    helper.Commit();

                    if (rollTemp.Rows.Count != 0)
                    {
                        foreach (DataRow Rows in rollTemp.Rows)
                        {
                            LogFile.WriteLog("=====MES ROLLBACK START=====" + Rows["MDOCNO"].ToString() + "-" + Rows["MDOCSEQ"].ToString(), LogType.PROC);
                            helper.ExecuteNoneQuery("SP_POP_WRK26_R01", CommandType.StoredProcedure
                           , helper.CreateParameter("P_DOC_NO", Rows["MDOCNO"].ToString(), DbType.String, ParameterDirection.Input)
                           , helper.CreateParameter("P_DOC_SEQNO", Rows["MDOCSEQ"].ToString(), DbType.String, ParameterDirection.Input)
                           , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input));
                            LogFile.WriteLog("=====MES ROLLBACK END=====" + Rows["MDOCNO"].ToString() + "-" + Rows["MDOCSEQ"].ToString(), LogType.PROC);
                        }
                    }
                    sMSG_ERR += "재단 MES ROLLBACK 실적이 취소되었습니다" + Environment.NewLine;
                    LogFile.WriteLog("재단 MES ROLLBACK COMPLETE", LogType.PROC);
                }
                catch (Exception ex1)
                {
                    LogFile.WriteLog("재단 MES ROLLBACK 오류 [" + ex1.Message.ToString() + "]");
                    sMSG_ERR += "재단 MES ROLLBACK 오류 : " + ex1.Message.ToString() + Environment.NewLine;
                }
            }
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
                                gbMAT_TRANS = false;
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
                        {
                            this.lblTitle.Text = "재단 실적등록";
                            isRefresh = true;
                        }
                        else
                        {
                            isRefresh = false;
                        }

                        break;
                    case "Start": //작업시작
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

                            if (RET_CODE == Common.ERROR_SUCCESS || RET_CODE == Common.ERROR_RFC_FAIL)
                            {
                                isRefresh = true;
                            }
                        }
                        break;
                    case "Dispo": //폐품사유선택
                        if (SettingCheck("MWOSR"))
                        {

                            if (lblPF_CHK_DISPO_01.Text.Equals("V") && lblPF_CHK_DISPO_02.Text.Equals("V"))
                            {
                                new POPUP.MessageForm("폐품 선택은 두개 까지 가능합니다.\r\n선택된 폐품을 취소하고 다시 선택해 주세요!", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                            }
                            else
                            {
                                if (lblMoveTTChk.Text.Equals("V"))
                                {
                                    new POPUP.MessageForm("수재단 이동인경우는 폐품등록을 할 수 없습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                    return;
                                }

                                POP_WRK35 popWrk35 = new POP_WRK35();
                                popWrk35.LabelTitle = "재단 폐품사유";

                                if (ShowDialogForm(popWrk35) == DialogResult.OK)
                                {
                                    if (lblPF_CHK_DISPO_01.Text.ToString() == "")
                                    {
                                        lblPF_DISPO_CODE_01.Tag = popWrk35.DispoCode;
                                        lblPF_DISPO_CODE_01.Text = popWrk35.DispoName;
                                        lblPF_CHK_DISPO_01.Text = "V";
                                        lblPF_CHK_DISPO_01.Visible = true;

                                        lblPF_DISPO_WGT_01.Text = "0";
                                        lblPF_DISPO_REAM_01.Text = "0";
                                        lblPF_DISPO_REAM_01.Enabled = true;
                                        lblPF_DISPO_REAM_01.BackColor = Color.White;
                                        lblPF_DISPO_CODE_NAME_01.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
                                    }
                                    else if (lblPF_CHK_DISPO_02.Text.ToString() == "")
                                    {
                                        lblPF_DISPO_CODE_02.Tag = popWrk35.DispoCode;
                                        lblPF_DISPO_CODE_02.Text = popWrk35.DispoName;
                                        lblPF_CHK_DISPO_02.Text = "V";
                                        lblPF_CHK_DISPO_02.Visible = true;

                                        lblPF_DISPO_WGT_02.Text = "0";
                                        lblPF_DISPO_REAM_02.Text = "0";
                                        lblPF_DISPO_REAM_02.Enabled = true;
                                        lblPF_DISPO_REAM_02.BackColor = Color.White;
                                        lblPF_DISPO_CODE_NAME_02.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
                                    }
                                    //new POPUP.MessageForm(string.Format("폐품코드={0}\r\n폐품명={1}", popWrk35.JunkItemCode, popWrk35.JunkItemName), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                }

                                isRefresh = false;
                            }
                        }
                        break;
                    case "Input": //공정투입
                        POP_WRK01 WRK01 = new POP_WRK01(POP_WRK01.LOC_CA_2700);

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
                    case "LBMerge": //라밸병합
                        POP_WRK31 WRK31 = new POP_WRK31();
                        ShowDialogForm(WRK31);
                        break;
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
                LogFile.WriteLog("POP_WRK26.bBox1_buttonClickEvent Error => " + ex.Message);
            }
            finally
            {

            }
        }

        private void btnCancel_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        private void btnWaitLoc_Click(object sender, EventArgs e)
        {
            if (!this.bUseNetwork)
            {
                SetMessage("네트워크 상태를 확인하시기 바랍니다.");
                return;
            }


            POP_INV04 INV04 = new POP_INV04();
            ShowDialogForm(INV04);
        }

        #endregion

        #region FUNCTION
        private void AutoCalculation()
        {
            DateTime dtStartDate;
            DateTime dtEndDate;

            try
            {
                WgtCalculation();

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
                LogFile.WriteLog("재단 AutoCalculation Error => " + ex.Message);
            }
        }

        // 계획 정보 계산
        private void PrdWgtCalculation()
        {
            Decimal dBS_WGT = 0;       // 평량
            Decimal dWLEN = 0;         // 가로길이
            Decimal dVLEN = 0;         // 세로길이
            Decimal dTOT_EA = 0;     // EA
            Decimal dWO_REAM = 0;     // 연수

            Decimal.TryParse(lblIN_BS_WGT.Text.ToString().Replace(",", ""), out dBS_WGT);               // 평량
            Decimal.TryParse(lblWO_WLEN.Text.ToString().Replace(",", ""), out dWLEN);                // 가로길이
            Decimal.TryParse(lblWO_VLEN.Text.ToString().Replace(",", ""), out dVLEN);                // 세로길이
            Decimal.TryParse(lblWO_PRD_REAM.Text.ToString().Replace(",", ""), out dWO_REAM);          // 계획 정보 연수

            dTOT_EA = dWO_REAM * 500;
            lblWO_MCNT.Text = string.Format("{0:#,0}", dTOT_EA);

            if (dBS_WGT <= 0 || dWLEN <= 0 || dVLEN <= 0 || dTOT_EA <= 0)
            {
                //lblWO_PRD_REAM.Text = "0";
                lblWO_PRD_WGT.Text = "0";
                return;
            }

            Decimal dValue = dTOT_EA * ((Decimal)dBS_WGT / 1000) * ((Decimal)dWLEN / 1000) * ((Decimal)dVLEN / 1000);     // 계획중량

            lblWO_PRD_WGT.Text = string.Format("{0:#,0.000}", dValue);      // 계획중량

            Decimal dPERF_DISPO_REAM = 0;
            Decimal dPERF_DISPO_WGT = 0;

            Decimal.TryParse(lblWO_PERF_DISPO_REAM.Text.ToString().Replace(",", ""), out dPERF_DISPO_REAM);         //실적연수+폐품연수
            Decimal.TryParse(lblWO_PERF_DISPO_WGT.Text.ToString().Replace(",", ""), out dPERF_DISPO_WGT);          //실적량+폐품량

            lblWO_RESI_REAM.Text = string.Format("{0:#,0.000}", dWO_REAM - dPERF_DISPO_REAM);
            lblWO_RESI_WGT.Text = string.Format("{0:#,0.000}", dValue - dPERF_DISPO_WGT);
        }


        // 파레트당 매수 유효성 검사
        private bool EA_ValidationCheck(string sREAM, string sPLT_CNT)
        {
            Decimal dREAM = 0;             // 팔레트당 연수
            Decimal dPLT_CNT = 0;          // 팔레트수
            Decimal dPLT_QUOTIENT = 0;        // 팔레트 몫
            Decimal dPLT_REMAINDER = 0;       // 팔레트 나머지

            dREAM = Decimal.TryParse(sREAM.Replace(",", ""), out dREAM) ? dREAM : 0;                 // 팔레트당 연수
            dPLT_CNT = Decimal.TryParse(sPLT_CNT.Replace(",", ""), out dPLT_CNT) ? dPLT_CNT : 0;     // 팔레트수

            if (dPLT_CNT < 1)
            {
                return false;
            }

            dPLT_QUOTIENT = (dPLT_CNT / 1);
            dPLT_REMAINDER = (dPLT_CNT % 1);


            Decimal dEA = (dREAM * 500);

            if ((dEA % 1) != 0)
            {
                string sMsg = string.Format("실적연수를 매수로 환산 했을 때 정수가 아닙니다.\r\n소숫점 세자리 입력시 짝수로 끝나야 합니다.\r\n{0:#,0.###} x 500 = {1:#,0.###}(EA)", dREAM, dEA);
                new POPUP.MessageForm(sMsg, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return false;
            }


            if (dPLT_REMAINDER != 0)
            {
                dEA = (dREAM * dPLT_REMAINDER * 500);

                if ((dEA % 1) != 0)
                {
                    string sMsg = string.Format("실적연수({0:#,0.###}) x 부분팔레트수({1:#,0.###})를 매수로 환산 했을 때\r\n정수가 아닙니다.\r\n\r\n{0:#,0.###} x {1:#,0.###} = {2:#,0.###}(R)\r\n{2:#,0.###} x 500 = {3:#,0.###}(EA)",
                                                    dREAM, dPLT_REMAINDER, (dREAM*dPLT_REMAINDER), dEA);
                    new POPUP.MessageForm(sMsg, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return false;
                }
            }

            return true;
        }

        // 실적 중량 계산
        private void WgtCalculation()
        {
            Decimal dBS_WGT = 0;       // 평량
            Decimal dWLEN = 0;         // 가로길이
            Decimal dVLEN = 0;         // 세로길이
            Decimal dPLT_REAM = 0;     // 팔레트 연수
            Decimal dPLT_EA = 0;       // 팔레트 개수

            Decimal.TryParse(lblIN_BS_WGT.Text.ToString().Replace(",", ""), out dBS_WGT);               // 평량

            if (lblMoveTTChk.Text.Equals("V"))
            {
                dWLEN = Decimal.TryParse(lblPF_TT_WLEN.Text.ToString().Replace(",", ""), out dWLEN) ? dWLEN : 0;                // 수재단 가로길이
                dVLEN = Decimal.TryParse(lblPF_TT_VLEN.Text.ToString().Replace(",", ""), out dVLEN) ? dVLEN : 0;                // 수재단 세로길이
            }
            else
            {
                dWLEN = Decimal.TryParse(lblWO_WLEN.Text.ToString().Replace(",", ""), out dWLEN) ? dWLEN : 0;                // 가로길이
                dVLEN = Decimal.TryParse(lblWO_VLEN.Text.ToString().Replace(",", ""), out dVLEN) ? dVLEN : 0;                // 세로길이
            }

            Decimal.TryParse(lblPF_PLT_REAM.Text.ToString().Replace(",", ""), out dPLT_REAM);      // 팔레트연수
            Decimal.TryParse(lblPF_PLT_EA.Text.ToString().Replace(",", ""), out dPLT_EA);          // 팔레트 EA


            if (dBS_WGT <= 0 || dWLEN <= 0 || dVLEN <= 0 || dPLT_REAM <= 0 || dPLT_EA <= 0)
            {
                lblPF_TOT_REAM.Text = "0";
                lblPF_TOT_WGT.Text = "0";
                return;
            }

            Decimal dTOT_REAM = dPLT_REAM * dPLT_EA;
            Decimal dValue = (dTOT_REAM * 500) * ((Decimal)dBS_WGT / 1000) * ((Decimal)dWLEN / 1000) * ((Decimal)dVLEN / 1000);

            lblPF_TOT_REAM.Text = string.Format("{0:#,0.###}", dTOT_REAM);
            lblPF_TOT_WGT.Text = string.Format("{0:#,0.###}", dValue);
        }

        // 폐품 중량 계산
        private void DispoWgtCalculation_01()
        {
            Decimal dBS_WGT = 0;       // 평량
            Decimal dWLEN = 0;         // 가로길이
            Decimal dVLEN = 0;         // 세로길이
            Decimal dPLT_REAM = 0;     // 팔레트 연수

            Decimal.TryParse(lblIN_BS_WGT.Text.ToString().Replace(",", ""), out dBS_WGT);               // 평량
            Decimal.TryParse(lblWO_WLEN.Text.ToString().Replace(",", ""), out dWLEN);                // 가로길이
            Decimal.TryParse(lblWO_VLEN.Text.ToString().Replace(",", ""), out dVLEN);                // 세로길이
            Decimal.TryParse(lblPF_DISPO_REAM_01.Text.ToString().Replace(",", ""), out dPLT_REAM);      // 폐품연수

            if (dBS_WGT <= 0 || dWLEN <= 0 || dVLEN <= 0 || dPLT_REAM <= 0)
            {
                lblPF_DISPO_WGT_01.Text = "0";
                return;
            }

            Decimal dValue = (dPLT_REAM * 500) * ((Decimal)dBS_WGT / 1000) * ((Decimal)dWLEN / 1000) * ((Decimal)dVLEN / 1000);

            lblPF_DISPO_WGT_01.Text = string.Format("{0:#,0.###}", dValue);
        }

        private void DispoWgtCalculation_02()
        {
            Decimal dBS_WGT = 0;       // 평량
            Decimal dWLEN = 0;         // 가로길이
            Decimal dVLEN = 0;         // 세로길이
            Decimal dPLT_REAM = 0;     // 팔레트 연수

            Decimal.TryParse(lblIN_BS_WGT.Text.ToString().Replace(",", ""), out dBS_WGT);               // 평량
            Decimal.TryParse(lblWO_WLEN.Text.ToString().Replace(",", ""), out dWLEN);                // 가로길이
            Decimal.TryParse(lblWO_VLEN.Text.ToString().Replace(",", ""), out dVLEN);                // 세로길이
            Decimal.TryParse(lblPF_DISPO_REAM_02.Text.ToString().Replace(",", ""), out dPLT_REAM);      // 폐품연수

            if (dBS_WGT <= 0 || dWLEN <= 0 || dVLEN <= 0 || dPLT_REAM <= 0)
            {
                lblPF_DISPO_WGT_02.Text = "0";
                return;
            }

            Decimal dValue = (dPLT_REAM * 500) * ((Decimal)dBS_WGT / 1000) * ((Decimal)dWLEN / 1000) * ((Decimal)dVLEN / 1000);

            lblPF_DISPO_WGT_02.Text = string.Format("{0:#,0.###}", dValue);
        }

        /// <summary>
        /// 실적 등록후 초기설정
        /// </summary>
        private void InitProduct()
        {
            // 초기설정
            if (string.IsNullOrEmpty(lblWO_PLT_PER_CNT.Text))
                lblPF_PLT_REAM.Text = "0";
            else
                lblPF_PLT_REAM.Text = Common.StrFormatDouble(lblWO_PLT_PER_CNT.Text.Replace(",", ""), "{0:#,##0.#}");

            lblPF_PLT_EA.Text = "1";
            lblPF_TOT_REAM.Text = "";
            lblPF_TOT_WGT.Text = "";
            lblPF_WRK_ORDR_RMK.Text = "";


            lblEndChk.Text = lblLastChk.Text = lblMoveTTChk.Text = "";
            lblEndChk.BackColor = lblLastChk.BackColor = lblMoveTTChk.BackColor = Color.White;

            lblPF_TT_NAME.Visible = lblPF_TT_WLEN.Visible = lblPF_TT_VLEN.Visible = false;
            lblPF_TT_WLEN.Text = lblPF_TT_VLEN.Text = "";
            lblPF_TT_WLEN.BackColor = lblPF_TT_VLEN.BackColor = Color.White;
            lblEndDateChk.Text = "V";
            lblEndDateChk.BackColor = Color.Yellow;
            dtpEndDate.Enabled = false;
            butEndDate.Enabled = false;
            lblEndTime.Enabled = false;

            lblPrintChk.Text = "V";
            lblPrintChk.BackColor = Color.Yellow;

            InitDISPO_01();
            InitDISPO_02();
        }

        // 폐품정보 01 초기설정
        private void InitDISPO_01()
        {
            lblPF_DISPO_REAM_01.Enabled = false;
            lblPF_DISPO_REAM_01.BackColor = Color.LightGray;
            lblPF_DISPO_REAM_01.Text = lblPF_DISPO_WGT_01.Text = lblPF_DISPO_CODE_01.Text = "";
            lblPF_DISPO_CODE_01.Tag = "";
            lblPF_CHK_DISPO_01.Text = "";
            lblPF_CHK_DISPO_01.Visible = false;
            lblPF_DISPO_CODE_NAME_01.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
        }

        // 폐품정보 02 초기설정
        private void InitDISPO_02()
        {
            lblPF_DISPO_REAM_02.Enabled = false;
            lblPF_DISPO_REAM_02.BackColor = Color.LightGray;
            lblPF_DISPO_REAM_02.Text = lblPF_DISPO_WGT_02.Text = lblPF_DISPO_CODE_02.Text = "";
            lblPF_DISPO_CODE_02.Tag = "";
            lblPF_CHK_DISPO_02.Text = "";
            lblPF_CHK_DISPO_02.Visible = false;
            lblPF_DISPO_CODE_NAME_02.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
        }

        #endregion

        private void dtpDate_ValueChanged(object sender, EventArgs e)
        {
            AutoCalculation();
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

        private void lblMAKE_PLT_REAM_Click(object sender, EventArgs e)
        {
            DAResultNum pop = new DAResultNum();
            pop.LabelTitle = "재단 실적 연수 입력 ";
            pop.LabelHeader = "실적 연수";
            pop.ContentMaxLength = 10;
            
            pop.ShowDialog(this);

            if (pop.DialogResult == DialogResult.OK)
            {
                Decimal dREAM = Math.Truncate(Convert.ToDecimal(pop.ResultDouble) * 1000) / 1000;

                if (EA_ValidationCheck(string.Format("{0:#,##0.###}", dREAM), lblPF_PLT_EA.Text) == true)
                {
                    Decimal dEA = dREAM * 500;

                    if ((dEA % 1) == 0)
                    {
                        lblPF_PLT_REAM.Text = string.Format("{0:#,##0.###}", dREAM);
                        AutoCalculation();
                    }
                    else
                    {
                        string sMsg = string.Format("실적연수를 매수로 환산 했을 때 정수가 아닙니다.\r\n소숫점 세자리 입력시 짝수로 끝나야 합니다.\r\n{0:#,0.###} x 500 = {1:#,0.###}", Convert.ToDecimal(pop.ResultDouble), dEA);
                        new POPUP.MessageForm(sMsg, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    }
                }
            }
        }

        private void lblMAKE_PLT_EA_Click(object sender, EventArgs e)
        {
            DAResultNum pop = new DAResultNum();
            pop.LabelTitle = "재단 실적 팔레트수 입력 ";
            pop.LabelHeader = "실적 팔레트수";
            pop.ContentMaxLength = 6;

            pop.ShowDialog(this);

            if (pop.DialogResult == DialogResult.OK)
            {
                Decimal dPLT_CNT = Math.Truncate(Convert.ToDecimal(pop.ResultDouble) * 10) / 10;

                if (dPLT_CNT < 1)
                {
                    new POPUP.MessageForm("팔레트수를 1이상 입력 하세요", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return;
                }

                if (EA_ValidationCheck(lblPF_PLT_REAM.Text, string.Format("{0:#,##0.#}", dPLT_CNT)) == true)
                {
                    lblPF_PLT_EA.Text = string.Format("{0:#,##0.#}", dPLT_CNT);
                    AutoCalculation();
                }
            }
        }

        private void lblCHK_DISPO_01_Click(object sender, EventArgs e)
        {
            lblPF_DISPO_REAM_01.Enabled = false;
            lblPF_DISPO_REAM_01.BackColor = Color.LightGray;
            lblPF_DISPO_REAM_01.Text = lblPF_DISPO_WGT_01.Text = lblPF_DISPO_CODE_01.Text = "";
            lblPF_CHK_DISPO_01.Text = "";
            lblPF_CHK_DISPO_01.Visible = false;
            lblPF_DISPO_CODE_NAME_01.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
        }

        private void lblCHK_DISPO_02_Click(object sender, EventArgs e)
        {
            lblPF_DISPO_REAM_02.Enabled = false;
            lblPF_DISPO_REAM_02.BackColor = Color.LightGray;
            lblPF_DISPO_REAM_02.Text = lblPF_DISPO_WGT_02.Text = lblPF_DISPO_CODE_02.Text = "";
            lblPF_CHK_DISPO_02.Text = "";
            lblPF_CHK_DISPO_02.Visible = false;
            lblPF_DISPO_CODE_NAME_02.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
        }

        private void lblDISPO_REAM_01_Click(object sender, EventArgs e)
        {
            DAResultNum pop = new DAResultNum();
            pop.LabelTitle = "재단폐품 입력";
            pop.LabelHeader = "재단폐품(R)";
            pop.ContentMaxLength = 10;

            pop.ShowDialog(this);

            if (pop.DialogResult == DialogResult.OK)
            {
                Decimal dEA = Convert.ToDecimal(pop.ResultDouble) * 500;
                if ((dEA % 1) == 0)
                {
                    lblPF_DISPO_REAM_01.Text = string.Format("{0:#,0.###}", Convert.ToDecimal(pop.ResultDouble));
                    DispoWgtCalculation_01();
                }
                else
                {
                    string sMsg = string.Format("폐품연수를 매수로 환산 했을 때 정수가 아닙니다.\r\n소숫점 세자리 입력시 짝수로 끝나야 합니다.\r\n{0:#,0.###} x 500 = {1:#,0.###}", Convert.ToDecimal(pop.ResultDouble), dEA);
                    new POPUP.MessageForm(sMsg, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                }
            }
        }

        private void lblDISPO_REAM_02_Click(object sender, EventArgs e)
        {
            DAResultNum pop = new DAResultNum();
            pop.LabelTitle = "재단폐품 입력";
            pop.LabelHeader = "재단폐품(R)";
            pop.ContentMaxLength = 10;

            pop.ShowDialog(this);

            if (pop.DialogResult == DialogResult.OK)
            {
                Decimal dEA = Convert.ToDecimal(pop.ResultDouble) * 500;
                if ((dEA % 1) == 0)
                {
                    lblPF_DISPO_REAM_02.Text = string.Format("{0:#,0.###}", Convert.ToDecimal(pop.ResultDouble));
                    DispoWgtCalculation_02();
                }
                else
                {
                    string sMsg = string.Format("폐품연수를 매수로 환산 했을 때 정수가 아닙니다.\r\n소숫점 세자리 입력시 짝수로 끝나야 합니다.\r\n{0:#,0.###} x 500 = {1:#,0.###}", Convert.ToDecimal(pop.ResultDouble), dEA);
                    new POPUP.MessageForm(sMsg, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                }
            }
        }

        private void lblWRK_ORDR_RMK_Click(object sender, EventArgs e)
        {
            DAResultText pop = new DAResultText("재단 비고 입력", lblPF_WRK_ORDR_RMK.Text.ToString());
            pop.ContentMaxLength = 100;

            pop.ShowDialog(this);
            if (pop.DialogResult == DialogResult.OK)
            {
                lblPF_WRK_ORDR_RMK.Text = pop.ResultString;
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

        private void lblLastChk_Click(object sender, EventArgs e)
        {
            if (lblLastChk.Text.ToString().Equals("V"))
            {
                lblLastChk.Text = "";
                lblLastChk.BackColor = Color.White;
            }
            else
            {
                lblLastChk.Text = "V";
                lblLastChk.BackColor = Color.Yellow;
            }
        }

        private void lblMoveTTChk_Click(object sender, EventArgs e)
        {
            if (SettingCheck("S"))
            {
                if (lblMoveTTChk.Text.ToString().Equals("V"))
                {
                    //if (lblMoveTTChk.Text.Equals("V"))
                    // 
                    if (gsMAN_CUT_YN == "Y")
                    {
                        //투입량과 가용량이 같은 경우만 수재단 이동을 해제할수 있다.
                        new POPUP.MessageForm("수재단 이동 등록이 있는경우는 해제 할 수 없습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                        return;
                    }

                    lblMoveTTChk.Text = "";
                    lblMoveTTChk.BackColor = Color.White;

                    lblPF_TT_NAME.Visible = false;
                    lblPF_TT_WLEN.Visible = false;
                    lblPF_TT_VLEN.Visible = false;

                    lblPF_TT_WLEN.Text = lblPF_TT_VLEN.Text = "";
                }
                else
                {
                    lblMoveTTChk.Text = "V";
                    lblMoveTTChk.BackColor = Color.Yellow;


                    //int iMWIDTH = 0;    // 밀롤지폭
                    int iWLEN = 0;      // 재단 가로길이
                    int iVLEN = 0;      // 재단 세로길이

                    //int.TryParse(lblIN_MWIDTH.Text.ToString().Replace(",", ""), out iMWIDTH);      // 밀롤 지폭
                    int.TryParse(lblWO_WLEN.Text.ToString().Replace(",", ""), out iWLEN);          // 재단 가로길이
                    int.TryParse(lblWO_VLEN.Text.ToString().Replace(",", ""), out iVLEN);          // 재단 세로길이

                    //int iTT_VLEN = 0;   //수재단 세로길이

                    //// 밀롤지폭이 재단가로길이의 두배가 안되는 경우는 세로길이의 두배 사이즈를 기본 표시
                    //// 아닌경우는 세로길이는 원래 사이즈로
                    //if (iMWIDTH < iWLEN * 2)
                    //{
                    //    iTT_VLEN = iVLEN*2;
                    //}
                    //else
                    //{
                    //    iTT_VLEN = iVLEN;
                    //}

                    // 수재단 기본 가로/세로 길이를 재단의 길이로 표시 하기로함.
                    //iTT_VLEN = iVLEN;


                    // 수재단 이동시 수재단 규격 입력 팝업 호출....
                    //lblPF_TT_WLEN.Text = lblIN_MWIDTH.Text;
                    //lblPF_TT_VLEN.Text = lblWO_VLEN.Text;
                    lblPF_TT_WLEN.Text = string.Format("{0:#,##0}", iWLEN);
                    lblPF_TT_VLEN.Text = string.Format("{0:#,##0}", iVLEN);

                    lblPF_TT_NAME.Visible = true;
                    lblPF_TT_WLEN.Visible = true;
                    lblPF_TT_VLEN.Visible = true;


                    InitDISPO_01();
                    InitDISPO_02();
                }

                AutoCalculation();

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

        private void dtpDate_DropDown(object sender, EventArgs e)
        {
            CommonCalendar.CloseCalendar((DateTimePicker)sender);
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

        private void lblWO_CUST_NM_Click(object sender, EventArgs e)
        {
            string msgData = string.Format("거래처명\r\n\r\n{0}", lblWO_CUST_NM.Text);
            new POPUP.MessageForm(msgData, MessageBoxButtons.OK, "알   림").ShowDialog(this);
        }

        private void lbPF_TT_WLEN_Click(object sender, EventArgs e)
        {
            //if (gsMAN_CUT_YN == "Y")
            //    return;

            DAResultQty pop = new DAResultQty();
            pop.LabelTitle = "수재단 가로 입력 ";
            pop.LabelHeader = "수재단 가로";
            pop.ContentMaxLength = 5;

            pop.ShowDialog(this);

            if (pop.DialogResult == DialogResult.OK)
            {
                Decimal dWLEN;
                Decimal.TryParse(lblWO_WLEN.Text.ToString().Replace(",", ""), out dWLEN);                // 가로길이

                Decimal dResult = Convert.ToDecimal(pop.ResultDouble);

                if (dWLEN > dResult)
                {
                    // 재단 규격보다 작은 사이즈를 선택 했습니다.
                    //string sMsg = string.Format("재단 가로길이 보다 작게 입력 했습니다.\r\n\r\n재단 가로 길이 : {0:#,##0}\r\n입력 가로 길이 : {1:#,##0}", dWLEN, dResult);
                    string sMsg = string.Format("재단 가로길이 ({0:#,##0}) 보다 작은 가로 길이는 입력 할수 없습니다.\r\n\r\n입력 가로 길이 : {1:#,##0}", dWLEN, dResult);
                    new POPUP.MessageForm(sMsg, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return;
                }

                Decimal dWLEN_MA;
                Decimal.TryParse(lblIN_MWIDTH.Text.ToString().Replace(",", ""), out dWLEN_MA);              // 밀롤지폭

                if (dWLEN_MA < dResult)
                {
                    // 재단 규격보다 작은 사이즈를 선택 했습니다.
                    string sMsg = string.Format("밀롤 지폭 ({0:#,##0}) 보다 큰 가로 길이는 입력 할수 없습니다.\r\n\r\n입력 가로 길이 : {1:#,##0}", dWLEN, dResult);
                    new POPUP.MessageForm(sMsg, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return;
                }

                // 배수인지 확인.
                if (dResult % dWLEN != 0)
                {
                    string sMsg = string.Format("입력 가로 길이 ({0:#,##0}) 가 재단 규격 ({1:#,##0}) 의 배수가 아닙니다.\r\n\r\n수재단 이동 가로 길이로 사용하시겠습니까?", dResult, dWLEN);

                    if (new POPUP.MessageForm(sMsg, MessageBoxButtons.OKCancel, "알   림").ShowDialog(this) == System.Windows.Forms.DialogResult.Cancel)
                    {
                        return;
                    }
                }

                lblPF_TT_WLEN.Text = string.Format("{0:#,0}", Convert.ToDecimal(pop.ResultDouble));
                AutoCalculation();
            }
        }

        private void lblPF_TT_VLEN_Click(object sender, EventArgs e)
        {
            //if (gsMAN_CUT_YN == "Y")
            //    return;

            DAResultQty pop = new DAResultQty();
            pop.LabelTitle = "수재단 세로 입력 ";
            pop.LabelHeader = "수재단 세로";
            pop.ContentMaxLength = 5;

            pop.ShowDialog(this);

            if (pop.DialogResult == DialogResult.OK)
            {
                Decimal dVLEN;
                Decimal.TryParse(lblWO_VLEN.Text.ToString().Replace(",", ""), out dVLEN);                // 세로길이

                Decimal dResult = Convert.ToDecimal(pop.ResultDouble);

                if (dVLEN > dResult)
                {
                    // 재단 규격보다 작은 사이즈를 선택 했습니다.
                    string sMsg = string.Format("재단 세로길이 ({0:#,##0}) 보다 작은 길이는 선택 할수 없습니다.\r\n\r\n입력 세로 길이 : {1:#,##0}", dVLEN, dResult);
                    new POPUP.MessageForm(sMsg, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return;
                }

                //// 두배가 넘는지 확인
                //if (dVLEN*2 < dResult)
                //{
                //    // 재단 규격보다 작은 사이즈를 선택 했습니다.
                //    string sMsg = string.Format("재단 세로길이 ({0:#,##0}) 보다 두배 이상은 선택 할수 없습니다.\r\n\r\n입력 세로 길이 : {1:#,##0}", dVLEN, dResult);
                //    new POPUP.MessageForm(sMsg, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                //    return;
                //}

                // 배수인지 확인.
                if (dResult % dVLEN != 0)
                {
                    string sMsg = string.Format("입력 세로 길이 ({0:#,##0}) 가 재단 규격 ({1:#,##0}) 의 배수가 아닙니다.\r\n\r\n수재단 이동 세로 길이로 사용하시겠습니까?", dResult, dVLEN);

                    if (new POPUP.MessageForm(sMsg, MessageBoxButtons.OKCancel, "알   림").ShowDialog(this) == System.Windows.Forms.DialogResult.Cancel)
                    {
                        return;
                    }
                }


                lblPF_TT_VLEN.Text = string.Format("{0:#,0}", Convert.ToDecimal(pop.ResultDouble));
                AutoCalculation();
            }
        }

        private void btnMRDetail_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(Common.WrkOrderNo))
            {
                return;
            }

            if (Grid1.Rows.Count > 0)
            {
                string sIND_BCD = Grid1.Row.Cells["IND_BCD"].Value.ToString();      // 개별바코드

                //public static string PROC_INP = "PROC_INP";        // 작업지시선택 투입정보
                //public static string PROC_WRK = "PROC_WRK";        // 주작업 표시 정보
                POP_WRK84 popWrk84 = new POP_WRK84(POP_WRK84.PROC_INP_PRFM, Common.PlantCode, Common.OpCode, Common.WrkOrderNo, Common.WrkOrderSeq, sIND_BCD);  // 작업지시 정보
                popWrk84.LabelTitle = "밀롤 투입정보 상세보기";
                ShowDialogForm(popWrk84);
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

                    DoFind02();
                }
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
            //    SetGrid();
            //    DoFind();
            //    iReSetCnt = 0;
            //}
        }
    }
}
