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
using Oracle.ManagedDataAccess.Client;
using System.Threading;
#endregion

namespace SmartDas
{
    public partial class POP_WRK27 : BaseForm
    {
        #region < MEMBER AREA >
        //private string sStartTime = string.Empty;
        //private int iSelRow;
        //private int iSecond = 0;

        private DataTable dtInpInfo = new DataTable();    // 투입정보 테이블
        private DataTable dtNowWrk = new DataTable();     // 현재 작업지시 테이블

        private Decimal gdGridSumReam = 0;   //투입 그리드 선택된 연수 합
        private string gsWODIV = string.Empty;  //작업지시 구분 ( 정상, 예외)

        string gsDISPO_GROUP = "";     // 폐품그룹

        private SAMMI.Common _common = new SAMMI.Common();

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

        public POP_WRK27()
        {
            InitializeComponent();

            Common.SetMessageList();

            this.UpdateMinuteEvent += new UpdateMinuteHandler(CallUpdateMinuteFunc);
        }

        public void CallUpdateMinuteFunc()
        {
            try
            {
                if (this.bUseNetwork)
                {
                    string sDate = Common.GetRecDate(DateTime.Now);
                    if (string.IsNullOrEmpty(sDate) == false)
                    {
                        lblPF_PRFM_DT.Text = DateTime.ParseExact(sDate, "yyyyMMdd", null).ToString("yyyy-MM-dd");
                    }
                }
            }
            catch (FormatException ex)
            {
                Console.WriteLine("FormatException {0} ", ex.Message);
                lblPF_PRFM_DT.Text = "";
            }
        }
        #endregion

        #region < POP_WRK27_Load >
        private void POP_WRK27_Load(object sender, EventArgs e)
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

                this.lblTitle.Text = "포장 실적등록";

                Common.machSetting();

                ////테스트 설정 
                //Common.PlantCode = "P100";      // 플랜트 코드
                //Common.OpCode = "PB";           // 공정코드  - 포장은 PB, PC 가 있다.
                //Common.IOType = "N";            // PS=N, 
                //Common.MachineCode = "PPB03";   // 설비호기
                
                // 콤보박스 초기화
                ucLABEL_TYPE.SelectedIndex = 1;
                ucLABEL_TYPE.ValueList.ItemHeight = 70;

                ucPNT_CNT.SelectedIndex = 1;
                ucPNT_CNT.ValueList.ItemHeight = 70;

                // 자동인쇄 초기화
                lblPrintChk.Text = "V";
                lblPrintChk.BackColor = Color.Yellow;


                SetMenuButtons();

                InitProduct();
                UpdateGrid();

                lblPF_CHK_DISPO.BackColor = Color.Yellow;

                //---------------------------------------------------------------------
                pnlWrkOrdr.Location = new Point(4, 462);
                pnlWrkOrdr.Size = new Size(1272, 490);
            }
            catch (Exception ex)
            {
                SetMessage("POP_WRK27_Load_ Error");
                LogFile.WriteLog("POP_WRK27.POP_WRK27_Load Error => " + ex.Message);
            }
        }
        #endregion

        #region < METHOD AREA >

        private void SetGrid()
        {
            DBHelper helper = new DBHelper();

            DataSet dsRtn = new DataSet();
            DataSet dsCA = new DataSet();

            DataTable dtTemp = new DataTable();
            try
            {
                Grid1.DataSource = null;

                Grid1.HeaderFontSize = 11;
                Grid1.FontSize = 12;
                Grid1.CountRows = 5;
                Grid1.AutoScroll = true;
                Grid1.DisplayLayout.Scrollbars = Scrollbars.Automatic;
                Grid1.DisplayLayout.Bands[0].Override.SelectTypeCol = SelectType.None;
                btnRightPage.LinkMoveSize = Grid1.CountRows;
                btnLeftPage.LinkMoveSize = Grid1.CountRows;

                dsRtn = helper.FillDataSetN("SP_POP_WRK27_S01", CommandType.StoredProcedure, 4
                                                    , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)        //플랜트코드
                                                    , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)
                                                    , helper.CreateParameter("RS_MACH_STA", DbType.String, ParameterDirection.Output, null, 30));  //작업장코드(설비코드)

                if (helper.RSCODE == "S" || helper.RSCODE == "E")
                {
                    timer1.Start();

                    bBox1[0, 3].bAlarm = false;

                    sRS_MACH_STA = helper.Parameters["RS_MACH_STA"].Value.ToString();



                    //가동상태(R :가동, S:비가동, N:대기중)
                    if (sRS_MACH_STA.Equals("S"))
                    {
                        //비가동시 점멸처리
                        bABNChk = true;
                    }
                    else
                    {
                        bABNChk = false;
                    }
                }


                //버튼 상태 변경
                if (helper.RSCODE.Equals("S"))
                {
                    dtInpInfo = dsRtn.Tables[0].Copy();     // 투입정보 테이블
                    dtNowWrk = dsRtn.Tables[3].Copy();      // 현재 작업지시 테이블

                    //재단 바코드 목록
                    dsCA.Tables.Add(dsRtn.Tables[1].Copy());
                    dsCA.Tables.Add(dsRtn.Tables[2].Copy());

                    Grid1.DoFind_Oracle(dsCA);

                    Grid1.DisplayLayout.Override.DefaultRowHeight = 45;
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
                LogFile.WriteLog("POP_WRK27.SetGrid Error => " + ex.Message);
            }
        }

        private void DoFind()
        {
            try
            {
                bool isInitIN = false;
                if (dtInpInfo.Rows.Count < 1
                    || string.IsNullOrEmpty(dtInpInfo.Rows[0]["VBELN"].ToString()))
                {
                    //SetMessage("조회된 작업지시가 없습니다.");
                    if (dtNowWrk.Rows[0]["GB"].ToString() == "예외")
                    {
                        isInitIN = true;
                    }
                    else
                    {
                        isInitIN = false;
                        InitControl_IN();
                    }
                }
                else
                {
                    isInitIN = true;
                }

                if(isInitIN == true)
                {
                    lblIN_VBELN.Text = dtInpInfo.Rows[0]["VBELN"].ToString();       // 판매문서
                    lblIN_POSNR.Text = dtInpInfo.Rows[0]["POSNR"].ToString();       // 판매문서항목번호

                    lblIN_BS_WGT.Text = dtInpInfo.Rows[0]["BS_WGT"].ToString();       // 평량
                    lblIN_WLEN.Text = dtInpInfo.Rows[0]["WLEN"].ToString();           // 가로길이
                    lblIN_VLEN.Text = dtInpInfo.Rows[0]["VLEN"].ToString();           // 세로길이
                }

                if (dtNowWrk.Rows.Count < 1
                    || string.IsNullOrEmpty(dtNowWrk.Rows[0]["WRK_ORDR_NO"].ToString()))
                {
                    //SetMessage("조회된 작업지시가 없습니다.");
                    InitControl_WO();
                }
                else
                {
                    Common.WrkOrderNo = dtNowWrk.Rows[0]["WRK_ORDR_NO"].ToString();     //포장작업지시번호
                    Common.WrkOrderSeq = dtNowWrk.Rows[0]["WRK_ORDR_SEQNO"].ToString(); //포장작업지시순번

                    // 포장 작업지시
                    lblWO_PCODE.Text = dtNowWrk.Rows[0]["PCODE"].ToString();            //지종코드
                    lblWO_PCODE_NM.Text = dtNowWrk.Rows[0]["PCODE_NM"].ToString();      //지종명


                    Decimal dWO_REAM = 0;
                    Decimal dWO_PLT_PER_CNT = 0;
                    Decimal dWO_IN_PER_CNT = 0;

                    Decimal.TryParse(dtNowWrk.Rows[0]["WRK_ORDR_QTY"].ToString().Replace(",", ""), out dWO_REAM);                    //  계획정보 연수
                    Decimal.TryParse(dtNowWrk.Rows[0]["PLT_PER_CNT"].ToString().Replace(",", ""), out dWO_PLT_PER_CNT);              //  팔레트당연수
                    Decimal.TryParse(dtNowWrk.Rows[0]["IN_PER_CNT"].ToString().Replace(",", ""), out dWO_IN_PER_CNT);                //  속당매수

                    lblWO_IN_PER_CNT.Text = string.Format("{0:#,##0.###}", dWO_IN_PER_CNT);                                               //속당매수
                    if (dWO_PLT_PER_CNT == 0 || dWO_IN_PER_CNT == 0)
                    {
                        lblWO_SCNT.Text = "0";
                    }
                    else
                    {
                        lblWO_SCNT.Text = string.Format("{0:#,##0.###}", (dWO_PLT_PER_CNT * 500) / dWO_IN_PER_CNT);                             //속수
                    }
                    //lblWO_IN_PER_CNT.Text = Common.StrFormatDouble(dtNowWrk.Rows[0]["IN_PER_CNT"].ToString().Replace(",", ""));     //속당매수
                    //lblWO_SCNT.Text = Common.StrFormatInteger(dtNowWrk.Rows[0]["SCNT"].ToString().Replace(",", ""));                //속

                    //lblWO_MCNT.Text = string.Format("{0:#,0}", dWO_REAM * 500);                                                      //총매수
                    lblWO_MCNT.Text = string.Format("{0:#,0}", Math.Truncate(dWO_REAM * 500));                                         //총매수

                    string sMATNR = dtNowWrk.Rows[0]["MATNR"].ToString();                //자재코드
                    lblWO_MATNR.Text = sMATNR;                //자재코드

                    lblWO_PRD_REAM.Text = Common.StrFormatDouble(dtNowWrk.Rows[0]["WRK_ORDR_QTY"].ToString());      //계획정보 연수

                    lblWO_PRD_WGT.Text = Common.StrFormatDouble(dtNowWrk.Rows[0]["TOT_WGT"].ToString());        //계획정보 중량

                    lblWO_PLT_PER_CNT.Text = string.Format("{0:#,##0.###}", dWO_PLT_PER_CNT);                                               //팔레트당연수
                    //lblWO_PLT_PER_CNT.Text = Common.StrFormatDouble(dtNowWrk.Rows[0]["PLT_PER_CNT"].ToString(), "{0:#,##0.###}");    //팔레트당연수

                    lblWO_PRD_REQ_DT.Text = dtNowWrk.Rows[0]["PRD_REQ_DT"].ToString();      //생산요청일자
                    lblWO_PACKTYPE.Text = dtNowWrk.Rows[0]["PACKTYPE_NM"].ToString();       //포장타입

                    if (string.IsNullOrEmpty(lblPF_DISPO_CODE.Text))    // 폐품 코드가 없는경우만 계획연수를 가져옴.
                    {
                        lblPF_PLT_REAM.Text = Common.StrFormatDouble(dtNowWrk.Rows[0]["PLT_PER_CNT"].ToString(), "{0:#,##0.###}");
                        lblPF_PLT_EA.Text = "1";
                        lblPF_PART_PLT_REAM.Text = "0";
                    }
                    lblPF_IN_PER_CNT.Text = Common.StrFormatDouble(dtNowWrk.Rows[0]["IN_PER_CNT"].ToString().Replace(",", ""), "{0:#,##0.###}");     //속당매수
                    //lblWO_SCNT.Text = Common.StrFormatInteger(dtNowWrk.Rows[0]["SCNT"].ToString().Replace(",", ""));                //속

                    //타이틀 변경
                    if (dtNowWrk.Rows[0]["GB"].ToString() == "예외")
                    {
                        gsWODIV = "예외";
                        this.lblTitle.Text = "포장 실적등록(예외)";

                        //lblWrkTitle.Size = new Size(471, 40);
                        //btnINP_INFO.Visible = false;
                    }
                    else
                    {
                        gsWODIV = string.Empty;
                        this.lblTitle.Text = "포장 실적등록";

                        //lblWrkTitle.Size = new Size(315, 40);
                        //btnINP_INFO.Visible = true;
                    }

                    // 자동포장인경우만 자재투입 이력 표시
                    //if (Common.OpCode == "PB")
                    //{
                    //    lblWrkTitle.Size = new Size(471, 40);
                    //    btnINP_INFO.Visible = false;
                    //}
                    //else
                    {
                        lblWrkTitle.Size = new Size(315, 40);
                        btnINP_INFO.Visible = true;
                    }


                    // 포장타입...확인...
                    string sDOM_EXP = sMATNR.Substring(4, 1);   // 1=내수, 2=수출
                    string sPACK_TYPE = sMATNR.Substring(sMATNR.Length -1, 1);  // A=스티커, B=페이퍼

                    LogFile.WriteLog(string.Format("라벨양식 확인 {0} = [{1}-{2}], [{3} {4}]", sMATNR, sDOM_EXP, sPACK_TYPE,
                                                                                sDOM_EXP == "1" ? "내수" : "수출",
                                                                                sPACK_TYPE == "A" ? "스티커" : "페이퍼"));

                    if ((sDOM_EXP == "1") && (sPACK_TYPE == "B"))       // 내수 페이퍼
                        ucLABEL_TYPE.SelectedIndex = 0;
                    else if ((sDOM_EXP == "1") && (sPACK_TYPE == "A"))  // 내수 스티커
                        ucLABEL_TYPE.SelectedIndex = 1;
                    else if ((sDOM_EXP == "2") && (sPACK_TYPE == "B"))  // 수출 페이퍼
                        ucLABEL_TYPE.SelectedIndex = 2;
                    else if ((sDOM_EXP == "2") && (sPACK_TYPE == "A"))  // 수출 스티커
                        ucLABEL_TYPE.SelectedIndex = 3;
                    else
                        ucLABEL_TYPE.SelectedIndex = 1;                 // 기본값 (내수 스티커)
                }
                //PrdWgtCalculation();

                WgtCalculation();
            }
            catch (Exception ex)
            {
                SetMessage("DoFind Error");
                LogFile.WriteLog("POP_WRK27.DoFind Error => " + ex.Message);
            }
        }

        private void DoFind02()
        {
            Decimal dSEL_PRFM_REAM = 0;
            Decimal dSEL_USE_REAM = 0;
            Decimal dSEL_DISPO_REAM = 0;
            Decimal dSEL_ABLE_REAM = 0;

            Decimal dPRFM_REAM = 0;
            Decimal dUSE_REAM = 0;
            Decimal dDISPO_REAM = 0;
            Decimal dABLE_REAM = 0;

            Decimal dSEL_PRFM_WGT = 0;
            Decimal dSEL_USE_WGT = 0;
            Decimal dSEL_DISPO_WGT = 0;
            Decimal dSEL_ABLE_WGT = 0;

            Decimal dPRFM_WGT = 0;
            Decimal dUSE_WGT = 0;
            Decimal dDISPO_WGT = 0;
            Decimal dABLE_WGT = 0;

            // Sum 연수 초기화
            gdGridSumReam = 0;

            DataTable dt = (DataTable)Grid1.DataSource;

            for (int i = 0; i < dt.Rows.Count; i++)
            {
                //선택된 행처리
                if (dt.Rows[i]["CHK"].ToString().Equals("V"))
                {
                    dPRFM_REAM = 0;
                    dUSE_REAM = 0;
                    dDISPO_REAM = 0;
                    dABLE_REAM = 0;

                    Decimal.TryParse(dt.Rows[i]["IN_QTY"].ToString().Replace(",", ""), out dPRFM_REAM);     //  실적연수
                    Decimal.TryParse(dt.Rows[i]["USE_QTY"].ToString().Replace(",", ""), out dUSE_REAM);     //  사용연수
                    Decimal.TryParse(dt.Rows[i]["DISPO_QTY"].ToString().Replace(",", ""), out dDISPO_REAM); //  폐품연수
                    Decimal.TryParse(dt.Rows[i]["ABLE_QTY"].ToString().Replace(",", ""), out dABLE_REAM);   //  실적연수

                    gdGridSumReam = gdGridSumReam + dABLE_REAM;

                    dPRFM_WGT = 0;
                    dUSE_WGT = 0;
                    dDISPO_WGT = 0;
                    dABLE_WGT = 0;

                    Decimal.TryParse(dt.Rows[i]["IN_WGT"].ToString().Replace(",", ""), out dPRFM_WGT);     //  실적중량
                    Decimal.TryParse(dt.Rows[i]["USE_WGT"].ToString().Replace(",", ""), out dUSE_WGT);     //  사용중량
                    Decimal.TryParse(dt.Rows[i]["DISPO_WGT"].ToString().Replace(",", ""), out dDISPO_WGT); //  폐품중량
                    Decimal.TryParse(dt.Rows[i]["ABLE_WGT"].ToString().Replace(",", ""), out dABLE_WGT);   //  가용중량

                    dSEL_PRFM_REAM += dPRFM_REAM;
                    dSEL_USE_REAM += dUSE_REAM;
                    dSEL_DISPO_REAM += dDISPO_REAM;
                    dSEL_ABLE_REAM += dABLE_REAM;

                    dSEL_PRFM_WGT += dPRFM_WGT;
                    dSEL_USE_WGT += dUSE_WGT;
                    dSEL_DISPO_WGT += dDISPO_WGT;
                    dSEL_ABLE_WGT += dABLE_WGT;
                }
            }

            lblIN_PRFM_REAM.Text = string.Format("{0:#,0.###}", dSEL_PRFM_REAM); //투입연수
            lblIN_USE_REAM.Text = string.Format("{0:#,0.###}", dSEL_USE_REAM);  //사용연수
            lblIN_DISPO_REAM.Text = string.Format("{0:#,0.###}", dSEL_DISPO_REAM); //폐품연수
            lblIN_AVA_REAM.Text = string.Format("{0:#,0.###}", dSEL_ABLE_REAM); //가용연수


            Decimal dBS_WGT = Decimal.TryParse(lblIN_BS_WGT.Text.ToString().Replace(",", ""), out dBS_WGT) ? dBS_WGT : 0;        // 평량
            Decimal dWLEN = Decimal.TryParse(lblIN_WLEN.Text.ToString().Replace(",", ""), out dWLEN) ? dWLEN : 0;                // 가로길이
            Decimal dVLEN = Decimal.TryParse(lblIN_VLEN.Text.ToString().Replace(",", ""), out dVLEN) ? dVLEN : 0;                // 세로길이

            if (dBS_WGT <= 0 || dWLEN <= 0 || dVLEN <= 0)
            {
                lblIN_PRFM_WGT.Text = string.Format("{0:#,0.###}", dSEL_PRFM_WGT); //투입중량
                lblIN_USE_WGT.Text = string.Format("{0:#,0.###}", dSEL_USE_WGT); //사용중량
                lblIN_DISPO_WGT.Text = string.Format("{0:#,0.###}", dSEL_DISPO_WGT); //폐품중량
                lblIN_AVA_WGT.Text = string.Format("{0:#,0.###}", dSEL_ABLE_WGT); //가용중량
            }
            else
            {
                dSEL_PRFM_WGT = (dSEL_PRFM_REAM * 500) * ((Decimal)dBS_WGT / 1000) * ((Decimal)dWLEN / 1000) * ((Decimal)dVLEN / 1000);    //실적중량
                dSEL_USE_WGT = (dSEL_USE_REAM * 500) * ((Decimal)dBS_WGT / 1000) * ((Decimal)dWLEN / 1000) * ((Decimal)dVLEN / 1000);    //사용중량
                dSEL_DISPO_WGT = (dSEL_DISPO_REAM * 500) * ((Decimal)dBS_WGT / 1000) * ((Decimal)dWLEN / 1000) * ((Decimal)dVLEN / 1000);    //폐품중량
                dSEL_ABLE_WGT = (dSEL_ABLE_REAM * 500) * ((Decimal)dBS_WGT / 1000) * ((Decimal)dWLEN / 1000) * ((Decimal)dVLEN / 1000);    //가용중량

                lblIN_PRFM_WGT.Text = string.Format("{0:#,0.###}", dSEL_PRFM_WGT); //투입중량
                lblIN_USE_WGT.Text = string.Format("{0:#,0.###}", dSEL_USE_WGT); //사용중량
                lblIN_DISPO_WGT.Text = string.Format("{0:#,0.###}", dSEL_DISPO_WGT); //폐품중량
                lblIN_AVA_WGT.Text = string.Format("{0:#,0.###}", dSEL_ABLE_WGT); //가용중량
            }
        }

        private void InitControl_IN()
        {
            // 투입정보
            lblIN_VBELN.Text = string.Empty;            // 판매문서
            lblIN_POSNR.Text = string.Empty;            // 판매문서항목번호

            lblIN_BS_WGT.Text = string.Empty;            // 평량
            lblIN_WLEN.Text = string.Empty;           // 가로길이
            lblIN_VLEN.Text = string.Empty;           // 세로길이
            
            lblIN_PRFM_WGT.Text = string.Empty;         // 실적량
            lblIN_USE_WGT.Text = string.Empty;          // 사용량
            lblIN_DISPO_WGT.Text = string.Empty;        // 폐품량
            lblIN_AVA_WGT.Text = string.Empty;          // 가용량

            Common.OrderNo = string.Empty;//생산오더번호
            Common.WrkOrderNo = string.Empty;//작업지시번호
            Common.WrkOrderSeq = string.Empty;//작업지시순번
            Common.ItemCode = string.Empty; //자재코드
        }

        private void InitControl_WO()
        {
            // 포장 작업지시
            lblWO_PCODE.Text = string.Empty;
            lblWO_PCODE_NM.Text = string.Empty;
            lblWO_MATNR.Text = string.Empty;
            lblWO_PRD_REQ_DT.Text = string.Empty;
            lblWO_IN_PER_CNT.Text = string.Empty;
            lblWO_SCNT.Text = string.Empty;
            lblWO_PACKTYPE.Text = string.Empty;
            lblWO_MCNT.Text = string.Empty;
            lblWO_PLT_PER_CNT.Text = string.Empty;

            lblWO_PRD_REAM.Text = string.Empty;
            lblWO_PRD_WGT.Text = string.Empty;
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
                bBox1[0, 3].Text = "비가동" + Environment.NewLine + "등록";
                bBox1[0, 3].Tag = "NonOper";
                bBox1[0, 3].MappingButton.FontSize = 14;
                bBox1[0, 4].Text = "실적등록";
                bBox1[0, 4].Tag = "Product";
                bBox1[0, 4].MappingButton.FontSize = 14;
                bBox1[0, 5].Text = "폐품선택";
                bBox1[0, 5].Tag = "Dispo";
                bBox1[0, 5].MappingButton.FontSize = 14;
                bBox1[0, 6].Text = "공정투입";
                bBox1[0, 6].Tag = "Input";
                bBox1[0, 6].MappingButton.FontSize = 14;
                bBox1[0, 7].Text = "공정체크";
                bBox1[0, 7].Tag = "Check";
                bBox1[0, 7].MappingButton.FontSize = 14;

                // 자동포장인경우만 자재투입 이력 표시
                if (Common.OpCode == "PB")
                {
                    bBox1[0, 8].Text = "자재투입\n이력";
                    bBox1[0, 8].Tag = "InputLog";
                    bBox1[0, 8].MappingButton.FontSize = 14;
                }
                else
                {
                    bBox1[0, 8].Text = "";
                    bBox1[0, 8].Tag = "";
                    bBox1[0, 8].MappingButton.FontSize = 14;
                }
                //bBox1[0, 9].Text = "자재" + Environment.NewLine + "투입이력";
                //bBox1[0, 9].Tag = "InputLog";
                bBox1[0, 9].Text = "";
                bBox1[0, 9].Tag = "";
                bBox1[0, 9].MappingButton.FontSize = 14;
                bBox1[0, 10].Text = "실적현황";
                bBox1[0, 10].Tag = "Performance";
                bBox1[0, 10].MappingButton.FontSize = 14;

                bBox1.RedrawButtons();
            }
            catch (Exception ex)
            {
                SetMessage("SetButtons Error");
                LogFile.WriteLog("DA0100.SetButtons Error => " + ex.Message);
            }
        }
        /// <summary>
        /// 투입정보에서 체크된 개별바코드의 총 연수를 구함
        /// </summary>
        /// <returns></returns>
        private Decimal GetTotAbleReam()
        {
            DataTable dt = (DataTable)Grid1.DataSource;
            Decimal dTotReam = 0;
            Decimal dABLE_QTY = 0;
            try
            {
                foreach (DataRow dRow in dt.Rows)
                {
                    if (dRow["CHK"].ToString().Equals("V"))
                    {
                        dABLE_QTY = Decimal.TryParse(dRow["ABLE_QTY"].ToString().Replace(",", ""), out dABLE_QTY) ? dABLE_QTY : 0;   // 가용연수
                        dTotReam += dABLE_QTY;
                    }
                }
            }
            catch (Exception ex)
            {
                dTotReam = 0;
                throw ex;
            }

            return dTotReam;
        }

        private void UpdateGrid()
        {
            SetGrid();
            DoFind();
            DoFind02();
            //SetGrid02("1");
            //SetGrid02("2");
            CallUpdateMinuteFunc();
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

            Decimal dIN_BS_WGT = Decimal.TryParse(lblIN_BS_WGT.Text.ToString().Replace(",", ""), out dIN_BS_WGT) ? dIN_BS_WGT : 0;                // 투입정보 평량
            if (pType.Contains("O") && dIN_BS_WGT == 0)
            {
                new POPUP.MessageForm("투입정보가 없습니다.\r\n작업지시 선택후 실적등록 하세요.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return false;
            }

            if (gsWODIV == "예외")
            {
                //예외생산은 폐품 등록 못함
                if (pType.Contains("X"))
                {
                    new POPUP.MessageForm("예외생산입니다.\r\n폐품등록은 할 수 없습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return false;
                }
            }


            ////지시의 상태 구분
            //if (pType.Contains("S") && !lblMACH_STA.Text.Equals("가동중")) //비가동(작업시작버튼 출력중)
            //{
            //    new POPUP.MessageForm("가동중 상태가 아닙니다.\r\n지시 상태를 확인하여 주시기 바랍니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
            //    return false;
            //}
            ////비가동 상태 확인
            if (pType.Contains("R") && sRS_MACH_STA.Equals("S")) //가동중 여부 확인
            {
                new POPUP.MessageForm("비가동 중 입니다.\r\n지시 상태를 확인하여 주시기 바랍니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return false;
            }
            return true;
        }

        ///// <summary>
        ///// 작업지시 시작
        ///// </summary>
        //private void doConfirm()
        //{
        //    DBHelper helper = new DBHelper(false);
        //    string sMSG = string.Empty;

        //    //팝업 변수
        //    POPUP.MessageForm msgForm = null;
        //    DialogResult res = DialogResult.Cancel;

        //    try
        //    {
        //        if (!lblMACH_STA.Text.Equals("대기중"))
        //        {
        //            new POPUP.MessageForm("가동중인 작업지시가 있습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
        //            return;
        //        }

        //        // 작업 시작일시 확인
        //        string sStartDate = dtpStartDate.Value.ToString("yyyyMMdd") + lblStartTime.Text.ToString().Replace(":", "") + "00";
        //        DateTime dtStartTime;
        //        if (DateTime.TryParseExact(sStartDate, "yyyyMMddHHmmss", null, DateTimeStyles.AssumeLocal, out dtStartTime) == false)
        //        {
        //            new POPUP.MessageForm("작업 시작일시 확인하세요", MessageBoxButtons.OK, "알   림").ShowDialog(this);
        //            return;
        //        }

        //        msgForm = new POPUP.MessageForm("작업지시를 시작 하시겠습니까?", MessageBoxButtons.OKCancel, "알   림");
        //        res = msgForm.ShowDialog(this);
        //        if (res == System.Windows.Forms.DialogResult.OK)
        //        {
        //            //작업시작 (작업지시 상태변경 및 작업장 현황의 가동상태 변경)
        //            helper.ExecuteNoneQuery("SP_POP_WRK27_I01", CommandType.StoredProcedure
        //                                            , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)               // 플랜트
        //                                            , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)           // 작업장코드(설비코드)
        //                                            , helper.CreateParameter("P_SDATE", sStartDate, DbType.String, ParameterDirection.Input)           // 작업장코드(설비코드)
        //                                            , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input)                 // 사용자ID
        //                                            );

        //            if (helper.RSCODE == "E")
        //            {
        //                new POPUP.MessageForm(helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
        //                this.DialogResult = DialogResult.OK;
        //                return;
        //            }

        //            sMSG = "작업지시가 정상적으로 시작 되었습니다.";
        //            new POPUP.MessageForm(sMSG, MessageBoxButtons.OK, "알   림").ShowDialog(this);

        //            UpdateGrid();
        //        }
        //    }
        //    catch (Exception ex)
        //    {
        //        new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);

        //        //SetMessage("SetGrid Error");
        //        LogFile.WriteLog("POP_WRK27.SetGrid Error\r\n" + ex.Message);
        //    }
        //    finally
        //    {
        //        helper.Close();
        //    }
        //}

        /// <summary>
        /// 포장 실적등록
        /// </summary>
        private int doProduct()
        {
            DataTable dtList;

            bool bReturn = false;

            //// 작업지시 확인
            //if (string.IsNullOrEmpty(lblIN_VBELN.Text.ToString()))
            //{
            //    new POPUP.MessageForm("투입정보가 없습니다.\r\n작업지시 선택후 실적등록 하세요.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
            //    return Common.ERROR_FAIL;
            //}

            // 선택된 개별바코드 있는지 확인
            int nChkCnt = 0;
            foreach (DataRow dRow in Grid1.DataSource.Rows)
            {
                if (dRow["CHK"].ToString().Equals("V"))
                {
                    nChkCnt++;
                    break;
                }
            }

            if (nChkCnt == 0)
            {
                new POPUP.MessageForm("선택된 개별 바코드가 없습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return Common.ERROR_FAIL;
            }


            Decimal dBS_WGT = Decimal.TryParse(lblIN_BS_WGT.Text.ToString().Replace(",", ""), out dBS_WGT) ? dBS_WGT : 0;        // 평량
            Decimal dWLEN = Decimal.TryParse(lblIN_WLEN.Text.ToString().Replace(",", ""), out dWLEN) ? dWLEN : 0;                // 가로길이
            Decimal dVLEN = Decimal.TryParse(lblIN_VLEN.Text.ToString().Replace(",", ""), out dVLEN) ? dVLEN : 0;                // 세로길이

            if (dBS_WGT <= 0 || dWLEN <= 0 || dVLEN <= 0)
            {
                new POPUP.MessageForm("평량 또는 규격을 확인하세요.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return Common.ERROR_FAIL;
            }

            Decimal dIN_PER_CNT = 0;

            Decimal.TryParse(lblPF_IN_PER_CNT.Text.ToString().Replace(",", ""), out dIN_PER_CNT);            // 
            if (dIN_PER_CNT <= 0)
            {
                new POPUP.MessageForm("속당 매수를 확인하세요.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return Common.ERROR_FAIL;
            }

            if(string.IsNullOrEmpty(lblPF_SCNT.Tag.ToString()) == false)
            {
                new POPUP.MessageForm(lblPF_SCNT.Tag.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return Common.ERROR_FAIL;
            }




            Decimal dPF_TOT_REAM = 0;
            Decimal dPF_DISPO_REAM = 0;
            Decimal.TryParse(lblPF_TOT_REAM.Text.ToString().Replace(",", ""), out dPF_TOT_REAM);          // 총연수
            Decimal.TryParse(lblPF_DISPO_REAM.Text.ToString().Replace(",", ""), out dPF_DISPO_REAM);      // 총연수

            Decimal dTotAbleReam = GetTotAbleReam();

            if ((dPF_TOT_REAM + dPF_DISPO_REAM) <= 0)
            {
                new POPUP.MessageForm("처리하려는 총 연수(실적+폐품) 0 입니다. 연수를 입력하세요.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return Common.ERROR_FAIL;
            }

            if (dTotAbleReam < (dPF_TOT_REAM + dPF_DISPO_REAM))
            {
                new POPUP.MessageForm(string.Format("처리하려는 총 연수(실적+폐품) {0:0.###}(R) 보다,\r\n선택된 바코드의 가용연수 {1:0.###}(R) 가 적습니다.", (dPF_TOT_REAM + dPF_DISPO_REAM), dTotAbleReam), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return Common.ERROR_FAIL;
            }

            // 폐품코드 확인...
            DataTable dtRtn;

            if (string.IsNullOrEmpty(lblPF_DISPO_CODE.Text))
            {
                dtRtn = RePacking();

                if (dtRtn != null)
                {
                    POP_WRK88 WRK88 = new POP_WRK88(dtRtn, lblPF_IN_PER_CNT.Text.ToString());
                    if (ShowDialogForm(WRK88) == System.Windows.Forms.DialogResult.OK)
                    {
                        if (WRK88.resultDT.Rows.Count > 0)
                        {
                            DataTable rDT = WRK88.resultDT;

                            foreach(DataRow dr1 in dtRtn.Rows)
                            {
                                foreach(DataRow dr2 in rDT.Rows)
                                {
                                    if (dr1["PLT_NO"].ToString() == dr2["NO"].ToString())
                                    {
                                        dr1["LOT_NO_M1"] = dr2["CT_LOT_ID1"].ToString();
                                        dr1["LOT_NO_M2"] = dr2["CT_LOT_ID2"].ToString();
                                        dr1["LOT_NO_M3"] = dr2["CT_LOT_ID3"].ToString();
                                        dr1["LOT_NO_M4"] = dr2["CT_LOT_ID4"].ToString();
                                        dr1["LOT_NO_M5"] = dr2["CT_LOT_ID5"].ToString();

                                        dr1["USE_REAM_M1"] = dr2["REAM1"].ToString();
                                        dr1["USE_REAM_M2"] = dr2["REAM2"].ToString();
                                        dr1["USE_REAM_M3"] = dr2["REAM3"].ToString();
                                        dr1["USE_REAM_M4"] = dr2["REAM4"].ToString();
                                        dr1["USE_REAM_M5"] = dr2["REAM5"].ToString();
                                    }
                                }
                            }
                        }
                        else
                        {
                            // 에러표시
                        }
                    }
                    else
                    {
                        return Common.ERROR_FAIL;
                    }
                }
                else
                {
                    //new POPUP.MessageForm("실적등록 하기위한 재단 바코드가 부족합니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return Common.ERROR_FAIL;
                }
            }
            else
            {
                DataTable dtTmp = new DataTable();

                dtRtn = RePackingDispo();   // 폐품 처리용 
            }

            
            string sProcedure = string.Empty;

            if (gsWODIV == "예외")
                sProcedure = "SP_POP_WRK27_I03";
            else
                sProcedure = "SP_POP_WRK27_I02";


            DBHelper helper = new DBHelper(false, "", true);
            DataSet dsTemp = new DataSet();     //실적등록 결과 수신(0:실적 RFC ID, 1:실적 IF 변수, 2:실적 RFC ID, 3:실적 IF 변수)
            bool bRetDISPO = false;     // 폐품 처리 결과
            bool bRetINP = false;       // 투입량 처리 결과

            string sMSG_ERR = "";
            string sRES_IND_BCD = "";

            try
            {
                this.Cursor = Cursors.WaitCursor;   //Waitting

                Decimal dProdReam = Decimal.TryParse(lblPF_PLT_REAM.Text.Replace(",", ""), out dProdReam) ? dProdReam : 0;  // 실적연수
                int iProdEA = int.TryParse(lblPF_PLT_EA.Text.Replace(",", ""), out iProdEA) ? iProdEA : 0;                // 팔레트수
                Decimal dProdPartReam = Decimal.TryParse(lblPF_PART_PLT_REAM.Text.Replace(",", ""), out dProdPartReam) ? dProdPartReam : 0;   // 부분실적

                //Decimal dTOTAL_WGT = Decimal.TryParse(lblPF_TOT_WGT.Text.Replace(",", ""), out dTOTAL_WGT) ? dTOTAL_WGT : 0;  // 총중량(실적중량+부분실적중량)
                Decimal dProdPartWGT = (dProdPartReam * 500) * ((Decimal)dBS_WGT / 1000) * ((Decimal)dWLEN / 1000) * ((Decimal)dVLEN / 1000);    //부분실적중량
                Decimal dProdWGT = (dProdReam * 500) * ((Decimal)dBS_WGT / 1000) * ((Decimal)dWLEN / 1000) * ((Decimal)dVLEN / 1000);        //실적중량
                //Decimal dProdWGT2 = dTOTAL_WGT - dProdPartWGT;        //실적중량

                if (string.IsNullOrEmpty(lblPF_DISPO_CODE.Text))
                {
                    // 실적 등록시 부분 연수가 있으면 팔레트수 1증가
                    if (dProdPartReam > 0)
                    {
                        iProdEA = iProdEA + 1;
                    }
                }
                else
                {
                    // 폐품 전송인경우 팔레트수 1개로 고정
                    iProdEA = 1;
                }

                if (iProdEA == 0)
                {
                    new POPUP.MessageForm("포장 실적 등록할 정보가 없습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return Common.ERROR_FAIL;
                }

                DataSet dsWrkPLT = new DataSet();
                
                for (int tableNo = 0; tableNo < iProdEA; tableNo++)
                {
                    DataTable tempTable = new DataTable();
                    tempTable = dtRtn.Clone();
                    tempTable.TableName = string.Format("TablePLT_{0:#000}", tableNo + 1);

                    Decimal dSND_REAM = dProdReam;          // 전송할 팔레트 연수

                    // 부분 실적이 있으면, 마지막 배열값은 부분 팔레트 연수로 저장
                    if (dProdPartReam > 0 && tableNo == (iProdEA - 1))
                    {
                        dSND_REAM = dProdPartReam;
                    }

                    if (tableNo == 0)
                    {
                        if (!string.IsNullOrEmpty(lblPF_DISPO_CODE.Text))
                        {
                            Decimal dDispoReam = Decimal.TryParse(lblPF_DISPO_REAM.Text.Replace(",", ""), out dDispoReam) ? dDispoReam : 0;
                            dSND_REAM = dDispoReam;
                            LogFile.WriteLog(string.Format("포장 폐품등록 연수[{0:0.###}]", dSND_REAM), LogType.PROC);
                        }
                    }

                    Decimal dPltUseReam = 0;       // 사용된 팔레트 연수

                    foreach (DataRow Row in dtRtn.Rows)
                    {
                        int nPltNo = 0;
                        if (int.TryParse(Row["PLT_NO"].ToString(), out nPltNo) == false)
                        {
                            LogFile.WriteLog(string.Format("포장 팔레트 번호 오류 : 실적연수[{0:0.###}], 팔레트수[{1:0.###}], 부분실적연수[{2:0.###}]", dProdReam, iProdEA, dProdPartReam), LogType.PROC);
                            LogFile.WriteLog("포장 팔레트 번호 오류 : " + Common.toJsonFormat("POP_WRK027_WRK", dtRtn), LogType.PROC);
                            LogFile.WriteLog(string.Format("포장 팔레트 번호 오류 : PLT_NO 오류", nPltNo), LogType.PROC);

                            new POPUP.MessageForm("포장 실적 등록시 팔레트 정보(번호)를 찾지 못했습니다.\r\n포장실적을 다시 등록 바랍니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                            return Common.ERROR_RFC_FAIL;
                        }
                        
                        if (nPltNo == (tableNo + 1))
                        {
                            Decimal dUseReam = Decimal.TryParse(Row["USE_REAM_M"].ToString(), out dUseReam) ? dUseReam : 0;
                            dPltUseReam += dUseReam;
                            tempTable.ImportRow(Row);
                        }
                    }

                    if (dSND_REAM != dPltUseReam)
                    {
                        LogFile.WriteLog(string.Format("포장연수 계산 오류 : 실적연수[{0:0.###}], 팔레트수[{1:0.###}], 부분실적연수[{2:0.###}]", dProdReam, iProdEA, dProdPartReam), LogType.PROC);
                        LogFile.WriteLog("포장연수 계산 오류 : " + Common.toJsonFormat("POP_WRK027_WRK", dtRtn), LogType.PROC);

                        new POPUP.MessageForm("포장 실적 등록시 포장연수 계산 오류\r\n포장실적을 다시 등록 바랍니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                        return Common.ERROR_RFC_FAIL;
                    }

                    dsWrkPLT.Tables.Add(tempTable);
                }

                for (int i = 0; i < iProdEA; i++)
                {
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

                        string sJsonWrkList = Common.toJsonFormat("POP_WRK027_WRK", dsWrkPLT.Tables[i]);

                        Decimal dSND_REAM = dProdReam;
                        Decimal dSND_WGT = dProdWGT;

                        // 속당매수/속수 정보
                        string sSND_SCNT = lblPF_SCNT.Text.Replace("-", "");              //속수
                        string sSND_IN_PER_CNT = lblPF_IN_PER_CNT.Text.Replace(",", "");        //속당매수

                        // 부분 실적이 있으면, 마지막 배열값은 부분 팔레트 연수로 저장
                        if (dProdPartReam > 0)
                        {
                            if (i == (iProdEA - 1))
                            {
                                dSND_REAM = dProdPartReam;
                                dSND_WGT = dProdPartWGT;
                            
                                // 부분 실적인경우 속수 계산
                                Decimal dPART_SCNT = (dProdPartReam * 500) / dIN_PER_CNT;

                                sSND_SCNT = string.Format("{0:###}", dPART_SCNT);               //속수
                                sSND_IN_PER_CNT = lblPF_IN_PER_CNT.Text.Replace(",", "");       //속당매수
                            }
                        }

                        // 폐품 정보
                        string sSND_DISPO_GROUP = "";
                        string sSND_DISPO_REAM = "";
                        string sSND_DISPO_WGT = "";
                        string sSND_DISPO_CODE = "";
                        string sSND_DISPO_NAME = "";

                        if (i == 0)
                        {
                            if (!string.IsNullOrEmpty(lblPF_DISPO_CODE.Text))
                            {
                                sSND_DISPO_GROUP = gsDISPO_GROUP;
                                sSND_DISPO_REAM = lblPF_DISPO_REAM.Text.Replace(",", "");
                                sSND_DISPO_WGT = lblPF_DISPO_WGT.Text.Replace(",", "");
                                sSND_DISPO_CODE = lblPF_DISPO_CODE.Tag.ToString();
                                sSND_DISPO_NAME = lblPF_DISPO_CODE.Text;
                            }
                        }

                        LogFile.WriteLog("PROC SND : " + sJsonWrkList, LogType.PROC);
                        LogFile.WriteLog(string.Format("PROC SND : 속수[{0}], 속당매수[{1}], 실적연수[{2:#.###}], 실적중량[{3:#.###}]", sSND_SCNT, sSND_IN_PER_CNT, dSND_REAM, dSND_WGT), LogType.PROC);


                        dsTemp = helper.FillDataSetN(sProcedure, CommandType.StoredProcedure, 8
                                            , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)                              // 플랜트
                                            , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)                          // 작업장코드(설비코드)
                                            , helper.CreateParameterOracle("P_WRK_LIST", sJsonWrkList, OracleDbType.Clob, ParameterDirection.Input)                     // 포장 실적등록 리스트
                                            , helper.CreateParameter("P_WRK_CLASS", Common.WorkClass, DbType.String, ParameterDirection.Input)                          // 작업반
                                            , helper.CreateParameter("P_WRK_SHIFT", Common.WorkShift, DbType.String, ParameterDirection.Input)                          // 작업조
                                            , helper.CreateParameter("P_SCNT", sSND_SCNT, DbType.String, ParameterDirection.Input)               // 속수
                                            , helper.CreateParameter("P_IN_PER_CNT", sSND_IN_PER_CNT, DbType.String, ParameterDirection.Input)   // 속당매수
                                            , helper.CreateParameter("P_PRFM_DT", lblPF_PRFM_DT.Text.Replace("-", ""), DbType.String, ParameterDirection.Input)         // 실적일자
                                            , helper.CreateParameter("P_PRFM_QTY", string.Format("{0:#.###}", dSND_REAM), DbType.String, ParameterDirection.Input)       // 실적(연수)
                                            , helper.CreateParameter("P_PRFM_WGT", string.Format("{0:#.###}", dSND_WGT), DbType.String, ParameterDirection.Input)        // 실적(중량)
                                            , helper.CreateParameter("P_PRFM_PLT", "1", DbType.String, ParameterDirection.Input)             // 팔레트수
                                            , helper.CreateParameter("P_PART_PRFM_QTY", "0", DbType.String, ParameterDirection.Input)  // 부분실적(연수)
                                            , helper.CreateParameter("P_PART_PRFM_WGT", "0", DbType.String, ParameterDirection.Input)  // 부분실적(중량)
                                            , helper.CreateParameter("P_TOT_REAM", string.Format("{0:#.###}", dSND_REAM), DbType.String, ParameterDirection.Input)   // 총연수
                                            , helper.CreateParameter("P_TOT_WGT", string.Format("{0:#.###}", dSND_WGT), DbType.String, ParameterDirection.Input)      // 총중량
                                            , helper.CreateParameter("P_DISPO_GROUP", sSND_DISPO_GROUP, DbType.String, ParameterDirection.Input)     // 폐품그룹  ( 'P' 인경우  SCRQTY_OP, SCRAPCODE_OP, SCRAPREASON_OP, 나머지는 SCRQTY, SCRAPCODE, SCRAPREASON)
                                            , helper.CreateParameter("P_DISPO_QTY", sSND_DISPO_REAM.Replace(",", ""), DbType.String, ParameterDirection.Input)        // 폐품연수
                                            , helper.CreateParameter("P_DISPO_WGT", sSND_DISPO_WGT.Replace(",", ""), DbType.String, ParameterDirection.Input)         // 폐품중량
                                            , helper.CreateParameter("P_DISPO_CD", sSND_DISPO_CODE, DbType.String, ParameterDirection.Input)                           // 폐품코드
                                            , helper.CreateParameter("P_DISPO_NM", sSND_DISPO_NAME, DbType.String, ParameterDirection.Input)                          // 폐품코드
                                            , helper.CreateParameter("P_RMK", lblPF_WRK_ORDR_RMK.Text, DbType.String, ParameterDirection.Input)                             // 비고
                                            , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input)                                    // 사용자ID
                                            , helper.CreateParameter("RS_DISPO_RFCFN", DbType.String, ParameterDirection.Output, null, 200)                                 // 폐품 RFCFN
                                            , helper.CreateParameter("RS_INPUT_RFCFN", DbType.String, ParameterDirection.Output, null, 200)                                 // 투입량 RFCFN
                                            , helper.CreateParameter("RS_PRFM_RFCFN", DbType.String, ParameterDirection.Output, null, 200)                                  // 실적 RFCFN값
                                            , helper.CreateParameter("RS_SDISPO_RFCFN", DbType.String, ParameterDirection.Output, null, 200)                                // 영업폐품 RFCFN ID값
                                            , helper.CreateParameter("RS_IND_BCD", DbType.String, ParameterDirection.Output, null, 2000)                                    //  RES 개별바코드 리스트
                                            );
#if false
                        {
                            this.Cursor = Cursors.Default;   //Waitting

                            string sRS_PRFM_RFCFN = helper.Parameters["RS_PRFM_RFCFN"].Value.ToString();      // 실적 RFCFN ID
                            string sRS_DISPO_RFCFN = helper.Parameters["RS_DISPO_RFCFN"].Value.ToString();    // 폐품 RFCFN ID
                            string sRS_INPUT_RFCFN = helper.Parameters["RS_INPUT_RFCFN"].Value.ToString();    // 투입량 RFCFN ID
                            string sRS_SDISPO_RFCFN = helper.Parameters["RS_SDISPO_RFCFN"].Value.ToString();  // 영업폐품 RFCFN ID

                            if (helper.RSCODE == "E")
                            {
                                new POPUP.MessageForm(helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                            }
                            helper.Rollback();
                            return Common.ERROR_FAIL;
                        }
#endif
                        if (helper.RSCODE == "S")
                        {
                            // 포장 잔량폐품 전달 안함.
                            //sRES_IND_BCD += helper.Parameters["RS_IND_BCD"].Value.ToString() + "|";
                            bufferIND_BCD = helper.Parameters["RS_IND_BCD"].Value.ToString() + "|"; // 프린트 바코드 저장 위치 변경 2022-11-08

                            string sRS_PRFM_RFCFN = helper.Parameters["RS_PRFM_RFCFN"].Value.ToString();      // 실적 RFCFN ID
                            string sRS_DISPO_RFCFN = helper.Parameters["RS_DISPO_RFCFN"].Value.ToString();    // 폐품 RFCFN ID
                            string sRS_INPUT_RFCFN = helper.Parameters["RS_INPUT_RFCFN"].Value.ToString();    // 투입량 RFCFN ID
                            string sRS_SDISPO_RFCFN = helper.Parameters["RS_SDISPO_RFCFN"].Value.ToString();  // 영업폐품 RFCFN ID


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
                            //포장의 경우 폐품에 개별바코드 생성됨 MES롤백을 위한 문서번호 저장 추가
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
                            //dsTemp.Tables[2];     // 폐품 인터페이스 파라미터
                            //dsTemp.Tables[3];     // 폐품 인터페이스 상세 파라미터
                            //dsTemp.Tables[4];     // 투입량 인터페이스 파라미터
                            //dsTemp.Tables[5];     // 투입량 인터페이스 상세 파라미터

                            string sRfcData; //RFC결과 JSON 변환

                            bReturn = false;
                            if ((string.IsNullOrEmpty(sRS_PRFM_RFCFN) == false) || (string.IsNullOrEmpty(sRS_DISPO_RFCFN) == false) || (string.IsNullOrEmpty(sRS_INPUT_RFCFN) == false))
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
                                            LogFile.WriteLog("포장 실적 등록 - SAP 확정문서 등록 오류 [" + helper.RSMSG.ToString());
                                            //new POPUP.MessageForm("실적 등록 - SAP 확정문서 등록 오류\r\n" + helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                            sMSG_ERR += "확정문서 등록 오류 : " + helper.RSMSG.ToString() + Environment.NewLine;
                                            throw new Exception("SAP_ERROR" + sMSG_ERR);
                                        }
                                    }
                                    else
                                    {
                                        //helper.Rollback();

                                        LogFile.WriteLog("포장 실적 등록 - SAP 전송 실패 [" + sapRFC_P.rtnMSG);
                                        //new POPUP.MessageForm("실적 - 등록 SAP전송이 실패하였습니다.\r\n" + sapRFC_P.rtnMSG, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                        sMSG_ERR += "실적 등록 : " + sapRFC_P.rtnMSG + Environment.NewLine;
                                        throw new Exception("SAP_ERROR" + sMSG_ERR);
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
                                if (/*(bReturn == true) && */(string.IsNullOrEmpty(sRS_DISPO_RFCFN) == false))
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
                                            LogFile.WriteLog("포장 실적 등록(폐품) - SAP 확정문서 등록 오류 [" + helper.RSMSG.ToString());
                                            //new POPUP.MessageForm("실적 등록(폐품) - SAP 확정문서 등록 오류\r\n" + helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                            sMSG_ERR += "확정문서 등록(폐품) 오류 : " + helper.RSMSG.ToString() + Environment.NewLine;
                                            throw new Exception("SAP_ERROR" + sMSG_ERR);
                                        }
                                    }
                                    else
                                    {
                                        //helper.Rollback();    // 실적이 성공이면 rollback 처리 안함.
                                        LogFile.WriteLog("포장 실적 등록(폐품) - SAP전송 오류 [" + sapRFC_D.rtnMSG);
                                        //new POPUP.MessageForm("실적 등록(폐품) - SAP전송이 실패하였습니다.\r\n" + sapRFC_D.rtnMSG, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                        sMSG_ERR += "실적 등록(폐품) 오류 : " + sapRFC_D.rtnMSG + Environment.NewLine;
                                        throw new Exception("SAP_ERROR" + sMSG_ERR);
                                    }

                                    Thread.Sleep(Common.SLEEP_DELAY);
                                    System.Windows.Forms.Application.DoEvents();        // 반복작업중 응답없음 안뜨게 하기
                                    this.Cursor = Cursors.WaitCursor;   //Waitting
                                }

                                // 3. 투입량 등록
                                if (/*(bReturn == true) && */(string.IsNullOrEmpty(sRS_INPUT_RFCFN) == false))
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
                                            LogFile.WriteLog("포장 실적 등록(투입량) - SAP 확정문서 등록 오류 [" + helper.RSMSG.ToString());
                                            //new POPUP.MessageForm("실적 등록(투입량) - SAP 확정문서 등록 오류\r\n" + helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                            sMSG_ERR += "확정문서 등록(투입량) 오류 : " + helper.RSMSG.ToString() + Environment.NewLine;
                                            throw new Exception("SAP_ERROR" + sMSG_ERR);
                                        }

                                    }
                                    else
                                    {
                                        //helper.Rollback();
                                        LogFile.WriteLog("포장 실적 등록(투입량) - SAP전송 오류 [" + sapRFC_I.rtnMSG);
                                        //new POPUP.MessageForm("실적 등록(투입량) - SAP전송이 실패하였습니다.\r\n" + sapRFC_I.rtnMSG, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                        sMSG_ERR += "실적 등록(투입량) 오류 : " + sapRFC_I.rtnMSG + Environment.NewLine;
                                        throw new Exception("SAP_ERROR" + sMSG_ERR);
                                    }

                                    Thread.Sleep(Common.SLEEP_DELAY);
                                    System.Windows.Forms.Application.DoEvents();        // 반복작업중 응답없음 안뜨게 하기
                                    this.Cursor = Cursors.WaitCursor;   //Waitting
                                }
                            }
                            sRES_IND_BCD += bufferIND_BCD; // 프린트 바코드 저장 위치 변경 2022-11-08
                        }
                        else
                        {
                            this.Cursor = Cursors.Default;   //Waitting

                            //helper.Rollback();
                            LogFile.WriteLog("포장 실적 등록 실패 [" + helper.RSMSG.ToString());
                            new POPUP.MessageForm("포장 등록 실패\r\n" + helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                            return Common.ERROR_RFC_FAIL;
                        }
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
                        LogFile.WriteLog("포장 실적등록 예외 오류 [" + ex.ToString() + "]");
                        //new POPUP.MessageForm_ERR("실적등록 오류", "실적등록 예외 오류\r\n" + ex.Message.ToString() + Environment.NewLine + sMSG_ERR, MessageBoxButtons.OK).ShowDialog(this);
                        new POPUP.MessageForm_ERR("실적등록 오류", "실적등록 예외 오류\r\n" + ex.ToString() + Environment.NewLine + sMSG_ERR, MessageBoxButtons.OK).ShowDialog(this);
                        break;
                    }

                    
                }


                this.Cursor = Cursors.Default;   //Waitting


                if (sRES_IND_BCD.Length > 0)
                {
                    if (lblPrintChk.Text.ToString() == "V")     // 자동인쇄 처리
                    {
                        string sLABEL_TYPE = (string)ucLABEL_TYPE.Items[ucLABEL_TYPE.SelectedIndex].DataValue;           //
                        int nPrtCnt = ucPNT_CNT.SelectedIndex + 1;
                        
                        LogFile.WriteLog(string.Format("바코드 정보[{0}매] : {1}", nPrtCnt, sRES_IND_BCD.Replace("|", ", ")), LogType.PROC);

                        sRES_IND_BCD = sRES_IND_BCD.TrimEnd('|');

                        PrinterManager.PrintPackaging(sRES_IND_BCD, sLABEL_TYPE, nPrtCnt);
                    }
                }

                if (sMSG_ERR.Length == 0)
                {
                    LogFile.WriteLog("포장 실적 등록 성공");
                    new POPUP.MessageForm("실적등록 완료 되었습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                }
                else
                {
                    LogFile.WriteLog("포장 실적 등록 실패");
                }
/*
                if (sRES_IND_BCD.Length > 0)
                {
                    if (lblPrintChk.Text.ToString() == "V")     // 자동인쇄 처리
                    {
                        //new POPUP.MessageForm("재단 개별바코드 [" + sRES_IND_BCD + "]", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                        sRES_IND_BCD = sRES_IND_BCD.TrimEnd('|');

                        PrinterManager.PrintCutter(sRES_IND_BCD);
                    }
                    this.Cursor = Cursors.Default;   //Waitting

                    LogFile.WriteLog("포장 실적 등록 성공");

                    if (sMSG_ERR.Length == 0)
                    {
                        new POPUP.MessageForm("실적등록 완료 되었습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    }
                    else if (sMSG_ERR.Length > 0)
                    {
                        new POPUP.MessageForm("실적등록 부분 성공.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    }
                }
*/
            }
            catch (Exception ex)
            {
                this.Cursor = Cursors.Default;   //Waitting

                LogFile.WriteLog("SP_POP_WRK26_I02.doProduct Error => " + ex.Message);
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
            }
            finally
            {
                this.Cursor = Cursors.Default;   //Waitting
                helper.Close();
            }

            return Common.ERROR_SUCCESS;
        }


        private void ProdRollback(DBHelper helper, DataTable sapTemp, DataTable rollTemp, DataSet dsTemp, ref string sMSG_ERR)
        {
            try
            {
                string rProcedure = string.Empty;
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


                // 2. SAP로 ROLLBACK 전송
                string rsRfcData; //RFC결과 JSON 변환
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
                                dsTemp = helper.FillDataSetN("SP_POP_WRK27_IFR01", CommandType.StoredProcedure, 2
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
                                        LogFile.WriteLog("포장 실적등록 ROLLBACK COMPLETE", LogType.PROC);
                                        
                                    }
                                    else //if (helper.RSCODE == "E")
                                    {
                                        LogFile.WriteLog("포장 ROLLBACK 등록 - SAP 확정문서 등록 오류 [" + helper.RSMSG.ToString() + "]");
                                        sMSG_ERR += "ROLLBACK 확정문서 등록 오류 : " + helper.RSMSG.ToString() + Environment.NewLine;
                                    }
                                    // DELAY 
                                    Thread.Sleep(Common.SLEEP_DELAY);
                                    System.Windows.Forms.Application.DoEvents();        // 반복작업중 응답없음 안뜨게 하기
                                }
                                else
                                {
                                    LogFile.WriteLog("포장 ROLLBACK 오류 - SAP전송 오류 [" + sapRFC_1.rtnMSG + "]");
                                    sMSG_ERR += "포장 ROLLBACK 오류 : " + sapRFC_1.rtnMSG + Environment.NewLine;
                                }
                                break;
                            // 2.2  폐품 ROLLBACK
                            case "2.SALV_REG_SAP":
                                LogFile.WriteLog("=====2.SALV_REG_SAP=====" + Rows["MDOCNO"].ToString() + "-" + Rows["MDOCSEQ"].ToString(), LogType.PROC);
                                dsTemp = helper.FillDataSetN("SP_POP_WRK27_IFR02", CommandType.StoredProcedure, 2
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
                                        LogFile.WriteLog("포장 폐품등록 ROLLBACK COMPLETE", LogType.PROC);
                                        
                                    }
                                    else //if (helper.RSCODE == "E")
                                    {
                                        LogFile.WriteLog("포장 ROLLBACK 등록 - SAP 확정문서 등록 오류 [" + helper.RSMSG.ToString() + "]");
                                        sMSG_ERR += "ROLLBACK 확정문서 등록 오류 : " + helper.RSMSG.ToString() + Environment.NewLine;
                                    }
                                    // DELAY 
                                    Thread.Sleep(Common.SLEEP_DELAY);
                                    System.Windows.Forms.Application.DoEvents();        // 반복작업중 응답없음 안뜨게 하기
                                }
                                else
                                {
                                    LogFile.WriteLog("포장 ROLLBACK 오류 - SAP전송 오류 [" + sapRFC_2.rtnMSG + "]");
                                    sMSG_ERR += "포장 ROLLBACK 오류 : " + sapRFC_2.rtnMSG + Environment.NewLine;
                                }
                                break;
                            // 2.1  잔량폐품 ROLLBACK
                            case "1.SALE_SALV_REG_SAP":
                                LogFile.WriteLog("=====1.SALE_SALV_REG_SAP=====" + Rows["MDOCNO"].ToString() + "-" + Rows["MDOCSEQ"].ToString(), LogType.PROC);
                                dsTemp = helper.FillDataSetN("SP_POP_WRK27_IFR03", CommandType.StoredProcedure, 2
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
                                        LogFile.WriteLog("포장 영업폐품 ROLLBACK COMPLETE", LogType.PROC);
                                        
                                    }
                                    else //if (helper.RSCODE == "E")
                                    {
                                        LogFile.WriteLog("포장 ROLLBACK 등록 - SAP 확정문서 등록 오류 [" + helper.RSMSG.ToString() + "]");
                                        sMSG_ERR += "ROLLBACK 확정문서 등록 오류 : " + helper.RSMSG.ToString() + Environment.NewLine;
                                    }
                                    // DELAY 
                                    Thread.Sleep(Common.SLEEP_DELAY);
                                    System.Windows.Forms.Application.DoEvents();        // 반복작업중 응답없음 안뜨게 하기
                                }
                                else
                                {
                                    LogFile.WriteLog("포장 ROLLBACK 오류 - SAP전송 오류 [" + sapRFC_3.rtnMSG + "]");
                                    sMSG_ERR += "포장 ROLLBACK 오류 : " + sapRFC_3.rtnMSG + Environment.NewLine;
                                }
                                break;
                            // 2.4 투입량 ROLLBACK
                            case "4.WIP_REG_SAP":     // 투입량 롤백
                                LogFile.WriteLog("=====4.WIP_REG_SAP=====" + Rows["MDOCNO"].ToString() + "-" + Rows["MDOCSEQ"].ToString(), LogType.PROC);
                                if (gsWODIV == "예외")
                                {
                                    rProcedure = "SP_POP_WRK27_IFR04_EX";
                                }
                                else
                                {
                                    rProcedure = "SP_POP_WRK27_IFR04";
                                }

                                dsTemp = helper.FillDataSetN(rProcedure, CommandType.StoredProcedure, 2
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
                                    , helper.CreateParameter("P_WRK_TYPE", "2", DbType.String, ParameterDirection.Input)                        // '0'= 실적테이블, 비계획생산, '1'= 폐품테이블, '2'=소요량, '3'=비가동,
                                    , helper.CreateParameterOracle("P_RFC_DATA", rsRfcData, OracleDbType.Clob, ParameterDirection.Input)
                                    , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input));

                                    if (helper.RSCODE == "S")
                                    {
                                        LogFile.WriteLog("포장 투입량 ROLLBACK COMPLETE", LogType.PROC);
                                        
                                    }
                                    else //if (helper.RSCODE == "E")
                                    {
                                        LogFile.WriteLog("포장 ROLLBACK 등록 - SAP 확정문서 등록 오류 [" + helper.RSMSG.ToString() + "]");
                                        sMSG_ERR += "ROLLBACK 확정문서 등록 오류 : " + helper.RSMSG.ToString() + Environment.NewLine;
                                    }
                                }
                                else
                                {
                                    LogFile.WriteLog("포장 ROLLBACK 오류 - SAP전송 오류 [" + sapRFC_4.rtnMSG + "]");
                                    sMSG_ERR += "포장 ROLLBACK 오류 : " + sapRFC_4.rtnMSG + Environment.NewLine;
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
                    helper.Commit();    // SAP로 ROLLBACK 전송 테이블 commit

                    string mProcedure = string.Empty;

                    if (gsWODIV == "예외")
                    {
                        mProcedure = "SP_POP_WRK27_R01_EX";
                    }
                    else
                    {
                        mProcedure = "SP_POP_WRK27_R01";
                    }

                    if (rollTemp.Rows.Count != 0)
                    {
                        foreach (DataRow Rows in rollTemp.Rows)
                        {
                            LogFile.WriteLog("=====MES ROLLBACK START=====" + Rows["MDOCNO"].ToString() + "-" + Rows["MDOCSEQ"].ToString(), LogType.PROC);
                            helper.ExecuteNoneQuery(mProcedure, CommandType.StoredProcedure
                           , helper.CreateParameter("P_DOC_NO", Rows["MDOCNO"].ToString(), DbType.String, ParameterDirection.Input)
                           , helper.CreateParameter("P_DOC_SEQNO", Rows["MDOCSEQ"].ToString(), DbType.String, ParameterDirection.Input)
                           , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input));
                            LogFile.WriteLog("=====MES ROLLBACK START=====" + Rows["MDOCNO"].ToString() + "-" + Rows["MDOCSEQ"].ToString(), LogType.PROC);
                        }
                    }
                    sMSG_ERR += "포장 MES ROLLBACK 실적이 취소되었습니다" + Environment.NewLine;
                    LogFile.WriteLog("포장 MES ROLLBACK COMPLETE", LogType.PROC);
                }
                catch (Exception ex1)
                {
                    LogFile.WriteLog("포장 MES ROLLBACK 오류 [" + ex1.Message.ToString() + "]");
                    sMSG_ERR += "포장 MES ROLLBACK 오류 : " + ex1.Message.ToString() + Environment.NewLine;
                }
            }
        }
        
        #endregion

        #region < EVNET >

        private void bBox1_buttonClickEvent(MESButton sender, ButtonBox.ButtonClickEventArg e)
        {
            bool isRefresh = false;
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
                    case "Order": //작업지시 선택
                        if (SettingCheck("MR"))
                        {
                            POP_WRK07 WRK07 = new POP_WRK07(Common.OpCode, Common.IOType);

                            if (ShowDialogForm(WRK07) == DialogResult.OK)
                            {
                                InitProduct();
                                Grid2.DataSource = null;
                                isRefresh = true;
                            }
                            else
                            {
                                isRefresh = false;
                            }
                        }
                        break;
                    case "Worker":  //작업자 선택
                        if (SettingCheck("MR"))
                        {
                            POP_WRK05 WRK05 = new POP_WRK05(Common.MachineCode, Common.IOType);
                            ShowDialogForm(WRK05);
                        }
                        break;
                    case "Machine": //설비선택
                        {
                            POP_WRK02 WRK02 = new POP_WRK02();
                            if (ShowDialogForm(WRK02) == DialogResult.OK)
                            {
                                InitProduct();
                                isRefresh = true;
                                this.lblTitle.Text = "포장 실적등록";
                            }
                            else
                            {
                                isRefresh = false;
                            }

                        }
                        break;
                    case "Start": //작업시작
                        //if (SettingCheck("MWOR"))
                        //{
                        //    //doConfirm();
                        //}
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

                        if (SettingCheck("MWOSXR"))
                        {
                            POP_WRK35 popWrk35 = new POP_WRK35();
                            popWrk35.LabelTitle = "포장 폐품사유";

                            if (ShowDialogForm(popWrk35) == DialogResult.OK)
                            {
                                gsDISPO_GROUP = popWrk35.sSelectGrpCode;        // 폐품그룹
                                lblPF_DISPO_CODE.Tag = popWrk35.DispoCode;
                                lblPF_DISPO_CODE.Text = popWrk35.DispoName;
                                lblPF_CHK_DISPO.Text = "V";
                                lblPF_CHK_DISPO.Visible = true;

                                lblPF_DISPO_REAM.Text = "0";
                                lblPF_DISPO_REAM.Enabled = true;
                                lblPF_DISPO_REAM.BackColor = Color.White;
                                lblPF_DISPO_CODE_NAME.TextAlign = System.Drawing.ContentAlignment.MiddleRight;

                                lblPF_PLT_REAM.Text = lblPF_PLT_EA.Text = lblPF_PART_PLT_REAM.Text = lblPF_TOT_REAM.Text = lblPF_TOT_WGT.Text = "";
                                lblPF_PLT_REAM.Enabled = lblPF_PLT_EA.Enabled = lblPF_PART_PLT_REAM.Enabled = false;
                                lblPF_PLT_REAM.BackColor = lblPF_PLT_EA.BackColor = lblPF_PART_PLT_REAM.BackColor = Color.LightGray;


                                WgtCalculation();
                                //new POPUP.MessageForm(string.Format("폐품코드={0}\r\n폐품명={1}", popWrk35.JunkItemCode, popWrk35.JunkItemName), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                            }
                        }
                        break;
                    case "Input": //공정투입
                        string sLOC_CD = POP_WRK01.LOC_PB_2600;

                        if (Common.OpCode.Equals("ZA"))
                        {
                            sLOC_CD = POP_WRK01.LOC_ZA_2500;
                        }
                        POP_WRK01 WRK01 = new POP_WRK01(sLOC_CD);

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
                        }
                        break;
                    case "InputLog": //자재 투입이력
                        POP_INV02 INV02 = new POP_INV02();
                        ShowDialogForm(INV02);
                        break;

                    case "Performance": //실적현황
                        POP_WRK30 WRK30 = new POP_WRK30(Common.OpCode, Common.MachineCode);
                        if (ShowDialogForm(WRK30) == DialogResult.OK)
                            isRefresh = true;
                        else
                            isRefresh = false;
                        break;
                    default:
                        InitProduct();
                        isRefresh = true;
                        break;
                }

                if (isRefresh == true)
                {
                    UpdateGrid();

                    if (lblAllSearchChk.Text.ToString() == "V")     // 전체보기 Y=전체, N=현재 작업장만 조회
                    {
                        ChkBtnFind();
                    }
                }
            }
            catch (Oracle.ManagedDataAccess.Client.OracleException oe)
            {
                SetMessage(oe.Message);
            }
            catch (Exception ex)
            {
                SetMessage(ex.Message);
                LogFile.WriteLog("POP_WRK27.bBox1_buttonClickEvent Error => " + ex.Message);
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

        #region INIT_METHOD

        /// <summary>
        /// 실적 등록후 초기설정
        /// </summary>
        private void InitProduct()
        {
            //lblPrintChk.Text = "V";
            //lblPrintChk.BackColor = Color.Yellow;

            lblAllSearchChk.Text = "";
            lblAllSearchChk.BackColor = Color.White;

            btnFindMain.Text = "설비조회";

            //ucLABEL_TYPE.SelectedIndex = 1;     // 라벨 타입
            //ucPNT_CNT.SelectedIndex = 1;        // 인쇄 매수
            lblPF_WRK_ORDR_RMK.Text = "";          // 비고

            
            lblPF_PRFM_DT.Text = "";
            lblPF_IN_PER_CNT.Text = "";
            lblPF_SCNT.Text = "";
            lblPF_SCNT.Tag = "";

            lblPF_PLT_REAM.Text = "";
            lblPF_PLT_EA.Text = "";
            lblPF_PART_PLT_REAM.Text = "";
            lblPF_TOT_REAM.Text = "";
            lblPF_TOT_WGT.Text = "";
            lblPF_DISPO_REAM.Text = "";
            lblPF_DISPO_WGT.Text = "";
            lblPF_DISPO_CODE.Text = "";
            lblPF_DISPO_CODE.Tag = "";
            gsDISPO_GROUP = "";     // 폐품그룹

            lblPF_WRK_ORDR_RMK.Text = "";


            lblPF_PLT_REAM.Enabled = lblPF_PLT_EA.Enabled = lblPF_PART_PLT_REAM.Enabled = true;
            lblPF_PLT_REAM.BackColor = lblPF_PLT_EA.BackColor = lblPF_PART_PLT_REAM.BackColor = Color.White;

            InitDISPO();
        }

        private void InitDISPO()
        {
            lblPF_DISPO_REAM.Enabled = false;
            lblPF_DISPO_REAM.BackColor = Color.LightGray;
            lblPF_DISPO_REAM.Text = lblPF_DISPO_WGT.Text = lblPF_DISPO_CODE.Text = "";
            lblPF_DISPO_CODE.Tag = "";
            gsDISPO_GROUP = "";         // 폐품그룹

            lblPF_CHK_DISPO.Text = "";
            lblPF_CHK_DISPO.Visible = false;
            lblPF_DISPO_CODE_NAME.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
        }


        #endregion

        #region FUNCTION
        private void AutoCalculation()
        {
            //DateTime dtStartDate;
            //DateTime dtEndDate;

            WgtCalculation();

            //if ((lblStartTime.Text.ToString().Length != 5) || (lblEndTime.Text.ToString().Length != 5))
            //{
            //    lblPF_PRFM_DT.Text = "";                   // 생산실적일자
            //    return;
            //}

            //string sStartDate = dtpStartDate.Value.ToString("yyyy-MM-dd") + " " + lblStartTime.Text.ToString() + ":00";
            //if (Common.IsDateTime(sStartDate) == false)
            //{
            //    lblPF_PRFM_DT.Text = "";                   // 생산실적일자
            //    return;
            //}

            //string sEndDate = dtpEndDate.Value.ToString("yyyy-MM-dd") + " " + lblEndTime.Text.ToString() + ":00";
            //if (Common.IsDateTime(sEndDate) == false)
            //{
            //    lblPF_PRFM_DT.Text = "";                   // 생산실적일자
            //    return;
            //}

            //dtStartDate = Convert.ToDateTime(sStartDate);
            //dtEndDate = Convert.ToDateTime(sEndDate);

            //TimeSpan Diff_dates = dtEndDate.Subtract(dtStartDate);


            //if (Diff_dates.TotalMinutes > 0)
            //{
            //    string sDate = Common.GetRecDate(dtEndDate);
            //    if (string.IsNullOrEmpty(sDate) == false)
            //    {
            //        try
            //        {
            //            lblPF_PRFM_DT.Text = DateTime.ParseExact(sDate, "yyyyMMdd", null).ToString("yyyy-MM-dd");
            //        }
            //        catch (FormatException)
            //        {
            //            Console.WriteLine("{0} is not in the correct format.", sDate);
            //            lblPF_PRFM_DT.Text = "";
            //        }
            //    }

            //    //lblTM.Text = string.Format("{0:#,0}", Diff_dates.TotalMinutes);                                 // 가동시간
            //    //lblRSPEED.Text = string.Format("{0:#,0}", (int)((gdROLLCNT / Diff_dates.TotalMinutes) + 0.5));     // 선속
            //    //SetMessage("");
            //}
            //else
            //{
            //    lblPF_PRFM_DT.Text = "";                   // 생산실적일자
            //    //lblTM.Text = "0";           // 가동시간
            //    //lblRSPEED.Text = "0";       // 선속
            //    //SetMessage("작업 시작일시/종료일시를 확인하세요");
            //}
        }

#if false
        // 계획 정보 계산
        private void PrdWgtCalculation()
        {
            Decimal dBS_WGT = 0.0;       // 평량
            Decimal dWLEN = 0.0;         // 가로길이
            Decimal dVLEN = 0.0;         // 세로길이
            Decimal dTOT_EA = 0.0;     // 팔레트 연수
            //Decimal dPLT_REAM = 0.0;     // 팔레트 연수
            //Decimal dPLT_EA = 0.0;       // 팔레트 개수

            Decimal.TryParse(lblIN_BS_WGT.Text.ToString().Replace(",", ""), out dBS_WGT);               // 평량
            Decimal.TryParse(lblWO_WLEN.Text.ToString().Replace(",", ""), out dWLEN);                // 가로길이
            Decimal.TryParse(lblWO_VLEN.Text.ToString().Replace(",", ""), out dVLEN);                // 세로길이
            //Decimal.TryParse(lblPF_PLT_REAM.Text.ToString().Replace(",", ""), out dPLT_REAM);      // 팔레트연수
            //Decimal.TryParse(lblPF_PLT_EA.Text.ToString().Replace(",", ""), out dPLT_EA);          // 팔레트 EA
            Decimal.TryParse(lblWO_MCNT.Text.ToString().Replace(",", ""), out dTOT_EA);          // 계획 정보 EA

            if (dBS_WGT <= 0 || dWLEN <= 0 || dVLEN <= 0 || dTOT_EA <= 0)
            {
                lblWO_PRD_REAM.Text = "0";
                lblWO_PRD_WGT.Text = "0";
                return;
            }

            Decimal dTOT_REAM = dTOT_EA / 500;
            Decimal dValue = dTOT_EA * ((Decimal)dBS_WGT / 1000) * ((Decimal)dWLEN / 1000) * ((Decimal)dVLEN / 1000);

            lblWO_PRD_REAM.Text = string.Format("{0:#,0.000}", dTOT_REAM);
            lblWO_PRD_WGT.Text = string.Format("{0:#,0.000}", dValue);
        }
#endif

        // 실적 중량 계산
        private void WgtCalculation()
        {
            Decimal dBS_WGT = 0;       // 평량
            Decimal dWLEN = 0;         // 가로길이
            Decimal dVLEN = 0;         // 세로길이
            Decimal dPLT_REAM = 0;     // 팔레트 연수
            Decimal dPLT_EA = 0;       // 팔레트 개수

            Decimal dPART_PLT_REAM = 0;     // 팔레트 연수

            Decimal dPF_IN_PER_CNT = 0; // 속당매수

            Decimal.TryParse(lblIN_BS_WGT.Text.ToString().Replace(",", ""), out dBS_WGT);               // 평량
            Decimal.TryParse(lblIN_WLEN.Text.ToString().Replace(",", ""), out dWLEN);                // 가로길이
            Decimal.TryParse(lblIN_VLEN.Text.ToString().Replace(",", ""), out dVLEN);                // 세로길이
            Decimal.TryParse(lblPF_PLT_REAM.Text.ToString().Replace(",", ""), out dPLT_REAM);      // 팔레트연수
            Decimal.TryParse(lblPF_PLT_EA.Text.ToString().Replace(",", ""), out dPLT_EA);          // 팔레트수

            Decimal.TryParse(lblPF_PART_PLT_REAM.Text.ToString().Replace(",", ""), out dPART_PLT_REAM);      // 부분팔레트연수

            Decimal.TryParse(lblPF_IN_PER_CNT.Text.ToString().Replace(",", ""), out dPF_IN_PER_CNT);      // 속당매수

            if (dBS_WGT <= 0 || dWLEN <= 0 || dVLEN <= 0 || dPLT_REAM <= 0 || dPLT_EA <= 0)
            {
                lblPF_TOT_REAM.Text = "0";
                lblPF_TOT_WGT.Text = "0";
            }
            else
            {
                Decimal dTOT_REAM = (dPLT_REAM * dPLT_EA) + dPART_PLT_REAM;
                Decimal dValue = (dTOT_REAM * 500) * ((Decimal)dBS_WGT / 1000) * ((Decimal)dWLEN / 1000) * ((Decimal)dVLEN / 1000);

                lblPF_TOT_REAM.Text = string.Format("{0:#,0.###}", dTOT_REAM);
                lblPF_TOT_WGT.Text = string.Format("{0:#,0.###}", dValue);
            }

            if (dPF_IN_PER_CNT <= 0)
            {
                lblPF_SCNT.Text = "0";
                lblPF_SCNT.ForeColor = Color.White;
                lblPF_SCNT.BackColor = Color.DarkRed;
                lblPF_SCNT.Tag = "속수가 0 입니다.";
            }
            else
            {
                Decimal dValue = (dPLT_REAM * 500) / dPF_IN_PER_CNT;

                lblPF_SCNT.Text = string.Format("{0:#,0.#}", dValue);

                if ((dValue % 1) == 0)
                {
                    lblPF_SCNT.ForeColor = Color.Black;
                    lblPF_SCNT.BackColor = Color.LightGray;
                    lblPF_SCNT.Tag = "";
                }
                else
                {
                    lblPF_SCNT.ForeColor = Color.White;
                    lblPF_SCNT.BackColor = Color.DarkRed;
                    lblPF_SCNT.Tag = "속수가 정수가 되도록 입력 하십시오.";
                }
            }

        }

        private void DispoWgtCalculation()
        {
            Decimal dBS_WGT = 0;       // 평량
            Decimal dWLEN = 0;         // 가로길이
            Decimal dVLEN = 0;         // 세로길이
            Decimal dPLT_REAM = 0;     // 팔레트 연수

            Decimal.TryParse(lblIN_BS_WGT.Text.ToString().Replace(",", ""), out dBS_WGT);               // 평량
            Decimal.TryParse(lblIN_WLEN.Text.ToString().Replace(",", ""), out dWLEN);                // 가로길이
            Decimal.TryParse(lblIN_VLEN.Text.ToString().Replace(",", ""), out dVLEN);                // 세로길이
            Decimal.TryParse(lblPF_DISPO_REAM.Text.ToString().Replace(",", ""), out dPLT_REAM);      // 폐품연수

            if (dBS_WGT <= 0 || dWLEN <= 0 || dVLEN <= 0 || dPLT_REAM <= 0)
            {
                lblPF_DISPO_WGT.Text = "0";
                return;
            }

            Decimal dValue = (dPLT_REAM * 500) * ((Decimal)dBS_WGT / 1000) * ((Decimal)dWLEN / 1000) * ((Decimal)dVLEN / 1000);

            lblPF_DISPO_WGT.Text = string.Format("{0:#,0.###}", dValue);
        }
        #endregion

        private void lblWasteCheck_Click(object sender, EventArgs e)
        {
            lblPF_DISPO_REAM.Enabled = false;
            lblPF_DISPO_REAM.BackColor = Color.LightGray;
            lblPF_DISPO_REAM.Text = lblPF_DISPO_WGT.Text = lblPF_DISPO_CODE.Text = "";
            gsDISPO_GROUP = "";     // 폐품그룹

            lblPF_CHK_DISPO.Visible = false;
            lblPF_DISPO_CODE_NAME.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;

            lblPF_PLT_REAM.Text = lblPF_PLT_EA.Text = "0";
            lblPF_PART_PLT_REAM.Text = "0";
            lblPF_PLT_REAM.Enabled = lblPF_PLT_EA.Enabled = lblPF_PART_PLT_REAM.Enabled = true;
            lblPF_PLT_REAM.BackColor = lblPF_PLT_EA.BackColor = lblPF_PART_PLT_REAM.BackColor = Color.White;

            // 실적연수 계획연수로 입력
            lblPF_PLT_REAM.Text = Common.StrFormatDouble(dtNowWrk.Rows[0]["PLT_PER_CNT"].ToString(), "{0:#,##0.###}");
            lblPF_PLT_EA.Text = "1";
            lblPF_PART_PLT_REAM.Text = "0";

            WgtCalculation();

        }

        private void uc_ValueChanged(object sender, EventArgs e)
        {
            lblPF_PLT_REAM.Focus();
        }

        private void lblPF_IN_PER_CNT_Click(object sender, EventArgs e)
        {
            DAResultQty pop = new DAResultQty();
            pop.LabelTitle = "포장 속당 매수 입력 ";
            pop.LabelHeader = "속당 매수";
            pop.ContentMaxLength = 8;

            pop.ShowDialog(this);

            if (pop.DialogResult == DialogResult.OK)
            {
                lblPF_IN_PER_CNT.Text = string.Format("{0:#,0}", Convert.ToDecimal(pop.ResultDouble));
                AutoCalculation();
            }
        }

        private void lblPF_PLT_REAM_Click(object sender, EventArgs e)
        {
            DAResultNum pop = new DAResultNum();
            pop.LabelTitle = "포장 실적 연수 입력";
            pop.LabelHeader = "실적 연수";
            pop.ContentMaxLength = 8;

            pop.ShowDialog(this);

            if (pop.DialogResult == DialogResult.OK)
            {
                //gdPLT_REAM = pop.ResultDouble;
                lblPF_PLT_REAM.Text = string.Format("{0:#,0.###}", Convert.ToDecimal(pop.ResultDouble));
                AutoCalculation();
            }
        }

        private void lblPF_PLT_EA_Click(object sender, EventArgs e)
        {
            DAResultQty pop = new DAResultQty();
            pop.LabelTitle = "포장 실적 팔레트 입력 ";
            pop.LabelHeader = "실적 팔레트";
            pop.ContentMaxLength = 6;

            pop.ShowDialog(this);

            if (pop.DialogResult == DialogResult.OK)
            {
                //gdPLT_EA = pop.ResultDouble;
                lblPF_PLT_EA.Text = string.Format("{0:#,0}", Convert.ToDecimal(pop.ResultDouble));
                AutoCalculation();
            }
        }

        private void lblPF_PART_PLT_REAM_Click(object sender, EventArgs e)
        {
            Decimal dIN_PER_CNT = Decimal.TryParse(lblPF_IN_PER_CNT.Text.ToString().Replace(",", ""), out dIN_PER_CNT) ? dIN_PER_CNT : 0;      // 속당매수
            if (dIN_PER_CNT <= 0)
            {
                new POPUP.MessageForm("부분실적 입력\r\n속당 매수를 확인하세요.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return;
            }

            DAResultNum pop = new DAResultNum();
            pop.LabelTitle = "포장 실적 부분 연수 입력";
            pop.LabelHeader = "실적 연수";
            pop.ContentMaxLength = 8;

            pop.ShowDialog(this);

            if (pop.DialogResult == DialogResult.OK)
            {
                Decimal dPLT_REAM = Convert.ToDecimal(pop.ResultDouble);
                Decimal dValue = (dPLT_REAM * 500) / dIN_PER_CNT;

                if ((dValue % 1) == 0)
                {
                    lblPF_PART_PLT_REAM.Text = string.Format("{0:#,0.###}", dPLT_REAM);
                    AutoCalculation();
                }
                else
                {
                    string sMsg = string.Format("부분실적 입력\r\n\r\n속수({0:#,0.###})가 정수가 되도록 입력하십시요", dValue);
                    new POPUP.MessageForm(sMsg, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return;
                }
            }
        }

        private void lblPF_DISPO_REAM_Click(object sender, EventArgs e)
        {
            DAResultNum pop = new DAResultNum();
            pop.LabelTitle = "포장 폐품 입력";
            pop.LabelHeader = "폐품(R)";
            pop.ContentMaxLength = 8;

            pop.ShowDialog(this);

            if (pop.DialogResult == DialogResult.OK)
            {
                lblPF_DISPO_REAM.Text = string.Format("{0:#,0.###}", Convert.ToDecimal(pop.ResultDouble));
                
                DispoWgtCalculation();
            }

        }
/*
        private bool CheckUnconformityReam(string sDispoReam)
        {
            string sMsg = string.Format("선택된 개별바코드의 부적합연수 {0}(R) 가\r\n폐품으로 등록되지 않았습니다.\r\n\r\n폐품등록 하시겠습니까?", sDispoReam);

            //if (new POPUP.MessageForm("선택된 개별바코드의 부적합연수가\r\n폐품으로 등록되지 않았습니다.\r\n\r\n폐품등록 하시겠습니까?", MessageBoxButtons.OKCancel, "알   림").ShowDialog(this) == System.Windows.Forms.DialogResult.No)
            if (new POPUP.MessageForm(sMsg, MessageBoxButtons.OKCancel, "알   림").ShowDialog(this) == System.Windows.Forms.DialogResult.Cancel)
            {
                return false;
            }

            bool bRetCode = false;
            if (SettingCheck("MWOSX"))
            {
                POP_WRK35 popWrk35 = new POP_WRK35();
                popWrk35.LabelTitle = "포장 폐품사유";

                if (ShowDialogForm(popWrk35) == DialogResult.OK)
                {
                    gsDISPO_GROUP = popWrk35.sSelectGrpCode;        // 폐품그룹
                    lblPF_DISPO_CODE.Tag = popWrk35.DispoCode;
                    lblPF_DISPO_CODE.Text = popWrk35.DispoName;
                    lblPF_CHK_DISPO.Text = "V";
                    lblPF_CHK_DISPO.Visible = true;

                    lblPF_DISPO_REAM.Text = sDispoReam;
                    lblPF_DISPO_REAM.Enabled = true;
                    lblPF_DISPO_REAM.BackColor = Color.White;
                    lblPF_DISPO_CODE_NAME.TextAlign = System.Drawing.ContentAlignment.MiddleRight;

                    lblPF_PLT_REAM.Text = lblPF_PLT_EA.Text = lblPF_PART_PLT_REAM.Text = lblPF_TOT_REAM.Text = lblPF_TOT_WGT.Text = "";
                    lblPF_PLT_REAM.Enabled = lblPF_PLT_EA.Enabled = lblPF_PART_PLT_REAM.Enabled = false;
                    lblPF_PLT_REAM.BackColor = lblPF_PLT_EA.BackColor = lblPF_PART_PLT_REAM.BackColor = Color.LightGray;

                    DispoWgtCalculation();
                    bRetCode = true;
                }
            }

            return bRetCode;
        }
*/
        private void Grid1_ClickCellButton(object sender, MESGrid.GridClickEventArg e)
        {
#if true
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


                DoFind02();
                //AutoCalculation();
            }
#else
/*
            try
            {
                //선택 버튼 클릭시 체크여부 변경
                if (e.column.ToString() == "CHK")
                {
                    string sStatus_Pre = e.row.Cells["CHK"].Value.ToString();
                    string sChk = "-";

                    if (sStatus_Pre == "V")
                    {
                        sChk = "-";
                    }
                    else
                    {
                        sChk = "V";
                    }

                    // 문제재기 적재소 인경우 부적합 연수 가 있는경우 폐품연수로 등록 되었는지 체크
                    if (Common.OpCode == "ZA" && sChk == "V")
                    {
                        Decimal dUCFMTY_AMT = 0;
                        Decimal dDISPO_REAM = 0;

                        Decimal.TryParse(e.row.Cells["UCFMTY_AMT"].Value.ToString(), out dUCFMTY_AMT);   //  부적합연수
                        Decimal.TryParse(e.row.Cells["DISPO_QTY"].Value.ToString().Replace(",", ""), out dDISPO_REAM); //  폐품연수

                        if (dUCFMTY_AMT > 0 && dDISPO_REAM < dUCFMTY_AMT)
                        {
                            if (CheckUnconformityReam(string.Format("{0:#,##0.###}", dUCFMTY_AMT - dDISPO_REAM)) == true)
                            {
                                // 체크된 항목들 초기화
                                for (int i = 0; i < Grid1.Rows.Count; i++)
                                {
                                    Grid1.Rows[i].Cells["CHK"].Value = "-";
                                }

                                // 현재 선택된 row만 체크 처리
                                e.row.Cells["CHK"].Value = sChk;

                                e.row.Selected = true;
                                Grid1.Row = e.row;
                            }
                        }
                        else
                        {
                            e.row.Cells["CHK"].Value = sChk;
                        }
                    }
                    else
                    {
                        e.row.Cells["CHK"].Value = sChk;
                    }

                    DoFind02();
                    //AutoCalculation();
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine("POP_WRK27.Grid1_ClickCellButton {0} ", ex.Message);
            }
*/
#endif
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

        private void btnPKDetail_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(Common.WrkOrderNo))
            {
                return;
            }

            //public static string PROC_INP = "PROC_INP";        // 작업지시선택 투입정보
            //public static string PROC_WRK = "PROC_WRK";        // 주작업 표시 정보
            POP_WRK84 popWrk84 = new POP_WRK84(POP_WRK84.PROC_WRK, Common.PlantCode, Common.OpCode, Common.WrkOrderNo, Common.WrkOrderSeq);  // 작업지시 정보
            //popWrk84.LabelTitle = "작업지시 정보";
            ShowDialogForm(popWrk84);
        }

        private void btnINP_INFO_Click(object sender, EventArgs e)
        {
            if (gsWODIV == "예외")
                return;

            if (pnlWrkOrdr.Visible == false)
            {
                pnlWrkOrdr.Visible = true;
                
                //조회기간 초기설정
                DateTime daysBefore = DateTime.Now;
                daysBefore = daysBefore.AddDays(-3);
                dtpREQ_STR_DATE.Value = daysBefore;
                dtpREQ_END_DATE.Value = DateTime.Now.AddDays(1);


                if (Common.OpCode == "ZA")
                {
                    lblAllSearchChkName.Visible = false;
                    lblAllSearchChk.Visible = false;
                    
                    lblAllSearchChk.Text = "";
                }
                else
                {
                    lblAllSearchChkName.Visible = true;
                    lblAllSearchChk.Visible = true;

                    lblAllSearchChk.Text = "";
                    lblAllSearchChk.BackColor = Color.White;
                }
                btnFind_Click(sender, e);

            }
        }

        private void SetGridWrkOrdr()
        {
            DBHelper helper = new DBHelper();
            //변수
            string sStartDate = string.Empty;
            string sEndDate = string.Empty;
            string sPCode = string.Empty; //지종
            string sWeight = string.Empty; //평량
            string sMatNR = string.Empty; //자재코드
            string sColInfo = string.Empty; //컬럼 헤더
            string sColType = string.Empty; //컬럼 타입
            //반환테이블
            DataSet dsTemp = new DataSet();


            DataTable dtSrc = (DataTable)Grid2.DataSource;

            try
            {
                //변수설정
                sStartDate = dtpREQ_STR_DATE.Value.ToString("yyyyMMdd");
                sEndDate = dtpREQ_END_DATE.Value.ToString("yyyyMMdd");
                
                //그리드 설정
                Grid2.DataSource = null;

                Grid2.HeaderFontSize = 11;
                Grid2.FontSize = 11;
                Grid2.CountRows = 10;
                Grid2.AutoScroll = true;
                Grid2.DisplayLayout.Scrollbars = Scrollbars.Automatic;
                btnRightPage.LinkMoveSize = Grid2.CountRows;
                btnLeftPage.LinkMoveSize = Grid2.CountRows;

                //lblIN_VBELN.Text = dtInpInfo.Rows[0]["VBELN"].ToString();
                //lblIN_POSNR.Text = dtInpInfo.Rows[0]["POSNR"].ToString();

                //lblIN_BS_WGT.Text = dtInpInfo.Rows[0]["BS_WGT"].ToString();           // 평량
                //lblIN_WLEN.Text = dtInpInfo.Rows[0]["WLEN"].ToString();           // 가로길이
                //lblIN_VLEN.Text = dtInpInfo.Rows[0]["VLEN"].ToString();           // 세로길이

                // 전체보기 Y=전체, N=현재 작업장만 조회
                string sAllSearch = "N";
                if (lblAllSearchChk.Text.ToString() == "V")     // 전체보기 Y=전체, N=현재 작업장만 조회
                {
                    sAllSearch = "Y";
                }

                dsTemp = helper.FillDataSetN("SP_POP_WRK27_S03", CommandType.StoredProcedure, 2
                                                               , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)               // 플랜트코드
                                                               , helper.CreateParameter("P_ALL_SEARCH", sAllSearch, DbType.String, ParameterDirection.Input)                // 전체보기 Y=전체, N=현재 작업장만 조회
                                                               , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)           // 작업장코드
                                                               , helper.CreateParameter("P_PRD_STR_DATE", sStartDate, DbType.String, ParameterDirection.Input)              // 조회 시작일
                                                               , helper.CreateParameter("P_PRD_END_DATE", sEndDate, DbType.String, ParameterDirection.Input)                // 조회 마지막일 
                                                               , helper.CreateParameter("P_VBELN", lblIN_VBELN.Text.ToString(), DbType.String, ParameterDirection.Input)    // 판매문서
                                                               , helper.CreateParameter("P_POSNR", lblIN_POSNR.Text.ToString(), DbType.String, ParameterDirection.Input)    // 판매문서 항목번호
                                                               );

                if (dsTemp.Tables[1].Rows.Count < 1)
                {
                    //SetMessage("조회된 작업지시가 없습니다.");
                }
                //그리드 출력
                Grid2.DoFind_Oracle(dsTemp);

                // 투입된 정보와 같은 개별바코드들은 Check 버튼 처리
                //
                for (int i = 0; i < Grid2.Rows.Count; i++)
                {
                    DataTable dt1 = (DataTable)Grid1.DataSource;
                    foreach (DataRow dRow1 in dt1.Rows)
                    {
                        //선택된 행처리
                        if (dRow1["CHK"].ToString().Equals("V"))
                        {
                            if ((dRow1["WRK_ORDR_NO"].ToString() == Grid2.Rows[i].Cells["WRK_ORDR_NO"].Value.ToString()) &&
                                (dRow1["WRK_ORDR_SEQNO"].ToString() == Grid2.Rows[i].Cells["WRK_ORDR_SEQNO"].Value.ToString()))
                            {
                                Grid2.Rows[i].Cells["CHK"].Value = "V";
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                SetMessage("SetGrid Error");
                LogFile.WriteLog("POP_WRK07.SetGrid Error => " + ex.Message );
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog();

            }
        }

        private void btnFind_Click(object sender, EventArgs e)
        {
            SetGridWrkOrdr();

            UpdateGrid();
            if (lblAllSearchChk.Text.ToString() == "V")     // 전체보기 Y=전체, N=현재 작업장만 조회
            {
                ChkBtnFind();
            }
        }

        private void ChkBtnFind()
        {
            if (Grid2.Rows.Count == 0)
            {
                return;
            }

            string sJsonWrkList = "";

            DataTable dtRtn = new DataTable();
            DataRow dtTempRow;
            
            try
            {
                //테이블 컬럼명 작성
                dtRtn.Columns.Add(new DataColumn("WO_NO", typeof(string)));      //작업시작일시
                dtRtn.Columns.Add(new DataColumn("WO_SEQ", typeof(string)));      //작업종료일시


                DataTable dt = (DataTable)Grid2.DataSource;
                foreach (DataRow dRow in dt.Rows)
                {
                    //선택된 행처리
                    if (dRow["CHK"].ToString().Equals("V"))
                    {
                        //조회결과 입력용 Row생성
                        dtTempRow = dtRtn.NewRow();

                        dtTempRow["WO_NO"] = dRow["WRK_ORDR_NO"].ToString();            //작업지시번호
                        dtTempRow["WO_SEQ"] = dRow["WRK_ORDR_SEQNO"].ToString();        //작업지시순번

                        //결과 테이블에 저장
                        dtRtn.Rows.Add(dtTempRow);
                    }
                }

                sJsonWrkList = Common.toJsonFormat("POP_WRK027", dtRtn);
            }
            catch (Exception ex)
            {
                sJsonWrkList = "";
                throw ex;
            }

            DBHelper helper = new DBHelper();
            try
            {

                Grid1.DataSource = null;

                Grid1.HeaderFontSize = 11;
                Grid1.FontSize = 12;
                Grid1.CountRows = 5;
                Grid1.AutoScroll = true;
                Grid1.DisplayLayout.Scrollbars = Scrollbars.Automatic;
                Grid1.DisplayLayout.Bands[0].Override.SelectTypeCol = SelectType.None;
                btnRightPage.LinkMoveSize = Grid1.CountRows;
                btnLeftPage.LinkMoveSize = Grid1.CountRows;


                // 전체보기 Y=전체, N=현재 작업장만 조회
                string sAllSearch = "N";
                if (lblAllSearchChk.Text.ToString() == "V")     // 전체보기 Y=전체, N=현재 작업장만 조회
                {
                    sAllSearch = "Y";
                }

                //반환테이블
                DataSet dsTemp = new DataSet();
                dsTemp = helper.FillDataSetN("SP_POP_WRK27_S04", CommandType.StoredProcedure, 2
                                                                , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)               // 플랜트코드
                                                                , helper.CreateParameter("P_ALL_SEARCH", sAllSearch, DbType.String, ParameterDirection.Input)                // 전체보기 Y=전체, N=현재 작업장만 조회
                                                                , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)           // 작업장코드
                                                                , helper.CreateParameterOracle("P_WRK_LIST", sJsonWrkList, OracleDbType.Clob, ParameterDirection.Input)      // 작업지시 번호, 순번
                                                                );

                if (helper.RSCODE == "E")
                {
                    new POPUP.MessageForm(helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                }
                else
                {
                    if (dsTemp.Tables[1].Rows.Count < 1)
                    {
                        // 조회하여 테이블이 NULL인경우 화면 표시를 위해서 칼럼명 추가
                        if (dsTemp.Tables[1].Columns.Contains("NULL"))
                        {
                            //SetMessage("조회된 작업지시가 없습니다.");
                            dsTemp.Tables[1].Reset();
                            dsTemp.Tables[1].Columns.Add("CHK", typeof(string));
                            dsTemp.Tables[1].Columns.Add("IND_BCD", typeof(string));
                            dsTemp.Tables[1].Columns.Add("LOT_NO", typeof(string));
                            dsTemp.Tables[1].Columns.Add("IN_QTY", typeof(string));
                            dsTemp.Tables[1].Columns.Add("USE_QTY", typeof(string));
                            dsTemp.Tables[1].Columns.Add("DISPO_QTY", typeof(string));
                            dsTemp.Tables[1].Columns.Add("ABLE_QTY", typeof(string));
                            dsTemp.Tables[1].Columns.Add("UCFMTY_AMT", typeof(string));
                            dsTemp.Tables[1].Columns.Add("IN_WGT", typeof(string));
                            dsTemp.Tables[1].Columns.Add("USE_WGT", typeof(string));
                            dsTemp.Tables[1].Columns.Add("DISPO_WGT", typeof(string));
                            dsTemp.Tables[1].Columns.Add("ABLE_WGT", typeof(string));
                            dsTemp.Tables[1].Columns.Add("ORDER_NO", typeof(string));
                            dsTemp.Tables[1].Columns.Add("MATNR", typeof(string));
                            dsTemp.Tables[1].Columns.Add("WRK_ORDR_NO", typeof(string));
                            dsTemp.Tables[1].Columns.Add("WRK_ORDR_SEQNO", typeof(string));
                            dsTemp.Tables[1].Columns.Add("PC_WRK_ORDR_NO", typeof(string));
                            dsTemp.Tables[1].Columns.Add("PC_WRK_ORDR_SEQNO", typeof(string));
                        }
                    }

                    //그리드 출력
                    Grid1.DoFind_Oracle(dsTemp);

                    //Grid1.DisplayLayout.Bands[0].Columns["PC_WRK_ORDR_SEQNO"].Hidden = true;


                    Grid1.DisplayLayout.Override.DefaultRowHeight = 45;
                    if (Grid1.Rows.Count > 0)
                    {
                        // 첫번째 행 선택
                        Grid1.Rows[0].Selected = true;
                        Grid1.Row = Grid1.Rows[0];
                    }
                }

                DoFind02();
            }
            catch (Exception ex)
            {
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                LogFile.WriteLog("POP_WRK27.ChkBtnFind Error => " + ex.Message);
            }
        }

        private void Grid2_ClickCellButton(object sender, MESGrid.GridClickEventArg e)
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

                ChkBtnFind();

            }

        }

        private void CheckReam()
        {
            Decimal dProdReam = Decimal.TryParse(lblPF_PLT_REAM.Text.Replace(",", ""), out dProdReam) ? dProdReam : 0;
            Decimal dProdEA = Decimal.TryParse(lblPF_PLT_EA.Text.Replace(",", ""), out dProdEA) ? dProdEA : 0;
            Decimal dProdReamPart = Decimal.TryParse(lblPF_PART_PLT_REAM.Text.Replace(",", ""), out dProdReamPart) ? dProdReamPart : 0;
            Decimal dDispoReam = Decimal.TryParse(lblPF_DISPO_REAM.Text.Replace(",", ""), out dDispoReam) ? dDispoReam : 0;

            if (gdGridSumReam < (dProdReam * dProdEA + dProdReamPart + dDispoReam))
            {
                string sMsg = "입력한 실적이 가용연수를 초과 했습니다." + "\n\r"
                              + "가용연수 : " + gdGridSumReam.ToString() + "\n\r"
                              + "실적연수 : " + (dProdReam * dProdEA + dProdReamPart + dDispoReam).ToString();

                new POPUP.MessageForm(sMsg, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                LogFile.WriteLog("POP_WRK27.ChkBtnFind Error => " + sMsg);
            }
        }
        
        private DataTable RePackingDispo()   // 폐품 처리용 
        {
            // Grid1 가 여러개 체크 되어 있으면 오류 발생.
            DataTable dt = (DataTable)Grid1.DataSource;
            DataTable dtDst = dt.Clone();

            try
            {
                foreach (DataRow dRow in dt.Rows)
                {
                    if (dRow["CHK"].ToString().Equals("V"))
                    {
                        dtDst.ImportRow(dRow);
                    }
                }
            }
            catch (Exception ex)
            {
                new POPUP.MessageForm("폐품등록 오류\r\n" + ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);

                return null;
            }

            if(dtDst.Rows.Count == 0)
            {
                new POPUP.MessageForm("선택된 개별 바코드가 없습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return null;
            }
            else if (dtDst.Rows.Count > 1)
            {
                new POPUP.MessageForm("폐품등록은 하나의 개별 바코드 선택 가능합니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return null;
            }
            
            Decimal dBS_WGT = Decimal.TryParse(lblIN_BS_WGT.Text.ToString().Replace(",", ""), out dBS_WGT) ? dBS_WGT : 0;        // 평량
            Decimal dWLEN = Decimal.TryParse(lblIN_WLEN.Text.ToString().Replace(",", ""), out dWLEN) ? dWLEN : 0;                // 가로길이
            Decimal dVLEN = Decimal.TryParse(lblIN_VLEN.Text.ToString().Replace(",", ""), out dVLEN) ? dVLEN : 0;                // 세로길이

            if (dBS_WGT <= 0 || dWLEN <= 0 || dVLEN <= 0)
            {
                new POPUP.MessageForm("평량 또는 가로/세로 값을 확인 하십시오", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return null;
            }


            DataTable sdt = new DataTable();

            sdt.Columns.Add("GUBUN", typeof(string));              //'1' 은 실적, '2'은 부분실적, '3' 폐품
            sdt.Columns.Add("PLT_NO", typeof(string));             // 팔레트 번호
            sdt.Columns.Add("IND_BCD_M", typeof(string));          // 재단 개별바코드
            sdt.Columns.Add("LOT_NO_M", typeof(string));           // 재단 LOTONO
            sdt.Columns.Add("ABLE_QTY_M", typeof(string));         // 재단 개별바코드 가용연수
            sdt.Columns.Add("USE_REAM_M", typeof(string));         // 재단 개별바코드 사용연수
            sdt.Columns.Add("USE_WGT_M", typeof(string));          // 재단 개별바코드 사용중량
            sdt.Columns.Add("MATNR_M", typeof(string));            // 재단 자재코드
            sdt.Columns.Add("PACK_LABEL_TYPE", typeof(string));      // 포장 라벨 인쇄 양식
            sdt.Columns.Add("WRK_ORDR_NO_M", typeof(string));        // 재단 작업지시번호
            sdt.Columns.Add("WRK_ORDR_SEQNO_M", typeof(string));     // 재단 작업지시순번
            sdt.Columns.Add("WRK_ORDR_NO", typeof(string));          // 포장 작업지시번호
            sdt.Columns.Add("WRK_ORDR_SEQNO", typeof(string));       // 포장 작업지시순번

            Decimal dDispoReam = Decimal.TryParse(lblPF_DISPO_REAM.Text.ToString().Replace(",", ""), out dDispoReam) ? dDispoReam : 0;          // 폐품연수



            DataRow dr = sdt.NewRow();

            dr["GUBUN"] = "3";          //'1' 은 실적, '2'은 부분실적, '3' 폐품
            dr["PLT_NO"] = "1";         // 팔레트 번호 (폐품은 항상 1)
            dr["IND_BCD_M"] = dtDst.Rows[0]["IND_BCD"].ToString();
            dr["LOT_NO_M"] = dtDst.Rows[0]["LOT_NO"].ToString();
            dr["ABLE_QTY_M"] = dtDst.Rows[0]["ABLE_QTY"].ToString();
            dr["USE_REAM_M"] = string.Format("{0:###0.###}", dDispoReam);
            dr["USE_WGT_M"] = string.Format("{0:###0.###}", (dDispoReam * 500) * ((Decimal)dBS_WGT / 1000) * ((Decimal)dWLEN / 1000) * ((Decimal)dVLEN / 1000));
            dr["MATNR_M"] = dtDst.Rows[0]["MATNR"].ToString();                      // 재단 자재코드
            dr["WRK_ORDR_NO_M"] = dtDst.Rows[0]["WRK_ORDR_NO"].ToString();          // 재단작업지시번호
            dr["WRK_ORDR_SEQNO_M"] = dtDst.Rows[0]["WRK_ORDR_SEQNO"].ToString();    // 재단작업지시순번
            dr["PACK_LABEL_TYPE"] = (string)ucLABEL_TYPE.Items[ucLABEL_TYPE.SelectedIndex].DataValue; // 포장 라벨 인쇄 양식

            if (gsWODIV == "예외")
            {
                dr["WRK_ORDR_NO"] = Common.WrkOrderNo;          // 포장작업지시번호
                dr["WRK_ORDR_SEQNO"] = Common.WrkOrderSeq;    // 포장작업지시순번
            }
            else
            {
                dr["WRK_ORDR_NO"] = dtDst.Rows[0]["PC_WRK_ORDR_NO"].ToString();          // 포장작업지시번호
                dr["WRK_ORDR_SEQNO"] = dtDst.Rows[0]["PC_WRK_ORDR_SEQNO"].ToString();    // 포장작업지시순번
            }

            sdt.Rows.Add(dr);
            
            return sdt;
        }

        private DataTable RePacking()
        {
            Decimal dProdNormalReam = Decimal.TryParse(lblPF_PLT_REAM.Text.Replace(",", ""), out dProdNormalReam) ? dProdNormalReam : 0;
            int iProdEA = int.TryParse(lblPF_PLT_EA.Text.Replace(",", ""), out iProdEA) ? iProdEA : 0;
            Decimal dProdPartReam = Decimal.TryParse(lblPF_PART_PLT_REAM.Text.Replace(",", ""), out dProdPartReam) ? dProdPartReam : 0;

            bool bProdPart = false;     // 부분 실적이 있는지 여부

            // 부분 팔레트 연수가 있으면 추가
            if (dProdPartReam > 0)
            {
                bProdPart = true;
            }

            Decimal dInReam = 0;     //투입 연수
            Decimal dInRe = 0;       //투입 잔여 연수
            Decimal dProdRe = 0;     //적재 잔여 연수
            Decimal dUseReam = 0;    //적재 연수
            int iPalletno = 1;
            int iLoop = 0;
            string oLotno = string.Empty;
            int ichkPalleno = 1;
            int lotCnt = 0;

            const int MAX_LOT_CNT   = 5;

            Decimal dBS_WGT = Decimal.TryParse(lblIN_BS_WGT.Text.ToString().Replace(",", ""), out dBS_WGT) ? dBS_WGT : 0;        // 평량
            Decimal dWLEN = Decimal.TryParse(lblIN_WLEN.Text.ToString().Replace(",", ""), out dWLEN) ? dWLEN : 0;                // 가로길이
            Decimal dVLEN = Decimal.TryParse(lblIN_VLEN.Text.ToString().Replace(",", ""), out dVLEN) ? dVLEN : 0;                // 세로길이

            string sLABEL_TYPE = (string)ucLABEL_TYPE.Items[ucLABEL_TYPE.SelectedIndex].DataValue;           //

            if (dBS_WGT <= 0 || dWLEN <= 0 || dVLEN <= 0 )
            {
                new POPUP.MessageForm("평량 또는 가로/세로 값을 확인 하십시오", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return null;
            }


            DataTable sdt1 = new DataTable();

            try
            {
                sdt1.Columns.Add("GUBUN", typeof(string));              //'1' 은 실적, '2'은 부분실적
                sdt1.Columns.Add("PLT_NO", typeof(string));             // 팔레트 번호
                sdt1.Columns.Add("IND_BCD_M", typeof(string));          // 재단 개별바코드
                sdt1.Columns.Add("LOT_NO_M", typeof(string));           // 재단 LOTONO
                sdt1.Columns.Add("ABLE_QTY_M", typeof(string));         // 재단 개별바코드 가용연수
                sdt1.Columns.Add("USE_REAM_M", typeof(string));         // 재단 개별바코드 사용연수
                sdt1.Columns.Add("USE_WGT_M", typeof(string));          // 재단 개별바코드 사용중량
                sdt1.Columns.Add("MATNR_M", typeof(string));            // 재단 자재코드
                sdt1.Columns.Add("PACK_LABEL_TYPE", typeof(string));      // 포장 라벨 인쇄 양식
                sdt1.Columns.Add("WRK_ORDR_NO_M", typeof(string));        // 재단 작업지시번호
                sdt1.Columns.Add("WRK_ORDR_SEQNO_M", typeof(string));     // 재단 작업지시순번
                sdt1.Columns.Add("WRK_ORDR_NO", typeof(string));          // 포장 작업지시번호
                sdt1.Columns.Add("WRK_ORDR_SEQNO", typeof(string));       // 포장 작업지시순번
                sdt1.Columns.Add("LOT_NO_M1", typeof(string));          // 재단 LOT 번호 1
                sdt1.Columns.Add("USE_REAM_M1", typeof(string));        // 재단 LOT 번호 에 대한 연수 1
                sdt1.Columns.Add("LOT_NO_M2", typeof(string));          // 재단 LOT 번호 2 
                sdt1.Columns.Add("USE_REAM_M2", typeof(string));        // 재단 LOT 번호 에 대한 연수 2
                sdt1.Columns.Add("LOT_NO_M3", typeof(string));          // 재단 LOT 번호 3 
                sdt1.Columns.Add("USE_REAM_M3", typeof(string));        // 재단 LOT 번호 에 대한 연수 3
                sdt1.Columns.Add("LOT_NO_M4", typeof(string));          // 재단 LOT 번호 4
                sdt1.Columns.Add("USE_REAM_M4", typeof(string));        // 재단 LOT 번호 에 대한 연수 4
                sdt1.Columns.Add("LOT_NO_M5", typeof(string));          // 재단 LOT 번호 5
                sdt1.Columns.Add("USE_REAM_M5", typeof(string));        // 재단 LOT 번호 에 대한 연수 5

                DataRow dr;
                Decimal dAbleQty = 0;
                string sGUBUN_DATA = "1";                   //'1' 은 실적, '2'은 부분실적, '3' 폐품
                Decimal dSND_PLT_REAM = dProdNormalReam;    // 전송할 팔레트당 연수 

                DataTable dtSrc = (DataTable)Grid1.DataSource.Copy();
                if (dtSrc.Rows.Count > 0)
                {
                    int nxMAX = 1;

                    if (bProdPart == true)
                    {
                        nxMAX = 2;
                    }

                    for (int nx = 0; nx < nxMAX; nx++)
                    {
                        if (nx == 0)
                        {
                            sGUBUN_DATA = "1";            //'1' 은 실적, '2'은 부분실적, '3' 폐품
                            dSND_PLT_REAM = dProdNormalReam;
                        }
                        else
                        {
                            sGUBUN_DATA = "2";            //'1' 은 실적, '2'은 부분실적, '3' 폐품
                            iProdEA += 1;    // 1팔레트 추가   

                            dSND_PLT_REAM = dProdPartReam;
                        }

                        dInReam = 0;     //투입 연수
                        dInRe = 0;       //투입 잔여 연수
                        dProdRe = 0;     //적재 잔여 연수
                        dUseReam = 0;    //적재 연수
                        
                        lotCnt = 0;
                        oLotno = string.Empty;
                        ichkPalleno = 1;
                        
                        for (int i = 0; i < dtSrc.Rows.Count; i++)
                        {
                            if (dtSrc.Rows[i]["CHK"].ToString() == "V")
                            {
                                dInReam = Decimal.TryParse(dtSrc.Rows[i]["ABLE_QTY"].ToString().Replace(",", ""), out dInReam) ? dInReam : 0;

                                if (dInReam == 0)
                                    continue;

                                // 1팔레트에 LOT 5개 이하만 적재 가능을 체크하기 위해..
                                if (dtSrc.Rows[i]["LOT_NO"].ToString() != oLotno)
                                {
                                    oLotno = dtSrc.Rows[i]["LOT_NO"].ToString();
                                    lotCnt++;
                                }

                                // 추가 Pallet 수가 적재하기로 한 수 보다 크면 적재를 끝낸다.
                                if (iProdEA < iPalletno)
                                    break;

                                if (dSND_PLT_REAM <= dInReam)  // 투입연수가 적재연수 이상일 경우
                                {
                                    if (dProdRe > 0)    // 적재 잔여가 있을 경우 계속 적재한다.
                                    {
                                        if (ichkPalleno == iPalletno && lotCnt > MAX_LOT_CNT)
                                        {
                                            new POPUP.MessageForm("1팔레트에 최대 5개 LOT만 적재 가능합니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                            LogFile.WriteLog("POP_WRK27.ChkBtnFind Error : " + "1팔레트에 최대 5개 LOT만 적재 가능합니다.");
                                            return null;
                                        }

                                        dr = sdt1.NewRow();
                                        dr["GUBUN"] = sGUBUN_DATA;                   //'1' 은 실적, '2'은 부분실적, '3' 폐품
                                        dr["PLT_NO"] = iPalletno.ToString();
                                        dr["IND_BCD_M"] = dtSrc.Rows[i]["IND_BCD"].ToString();
                                        dr["LOT_NO_M"] = dtSrc.Rows[i]["LOT_NO"].ToString();
                                        dr["ABLE_QTY_M"] = dtSrc.Rows[i]["ABLE_QTY"].ToString();
                                        dr["USE_REAM_M"] = string.Format("{0:###0.###}", dProdRe);
                                        dr["USE_WGT_M"] = string.Format("{0:###0.###}", (dProdRe * 500) * ((Decimal)dBS_WGT / 1000) * ((Decimal)dWLEN / 1000) * ((Decimal)dVLEN / 1000));
                                        dr["MATNR_M"] = dtSrc.Rows[i]["MATNR"].ToString();                      // 재단 자재코드
                                        dr["WRK_ORDR_NO_M"] = dtSrc.Rows[i]["WRK_ORDR_NO"].ToString();          // 재단작업지시번호
                                        dr["WRK_ORDR_SEQNO_M"] = dtSrc.Rows[i]["WRK_ORDR_SEQNO"].ToString();    // 재단작업지시순번
                                        dr["PACK_LABEL_TYPE"] = sLABEL_TYPE;      // 포장 라벨 인쇄 양식

                                        if (gsWODIV == "예외")
                                        {
                                            dr["WRK_ORDR_NO"] = Common.WrkOrderNo;          // 포장작업지시번호
                                            dr["WRK_ORDR_SEQNO"] = Common.WrkOrderSeq;    // 포장작업지시순번
                                        }
                                        else
                                        {
                                            dr["WRK_ORDR_NO"] = dtSrc.Rows[i]["PC_WRK_ORDR_NO"].ToString();         // 포장작업지시번호
                                            dr["WRK_ORDR_SEQNO"] = dtSrc.Rows[i]["PC_WRK_ORDR_SEQNO"].ToString();   // 포장작업지시순번
                                        }

                                        // 가용연수 업데이트
                                        Decimal.TryParse(dtSrc.Rows[i]["ABLE_QTY"].ToString().Replace(",", ""), out dAbleQty);
                                        dAbleQty = dAbleQty - dProdRe;
                                        dtSrc.Rows[i]["ABLE_QTY"] = string.Format("{0:###0.###}", dAbleQty);
                                        if (dAbleQty <= 0)
                                        {
                                            dtSrc.Rows[i]["CHK"] = "-";
                                        }

                                        sdt1.Rows.Add(dr);

                                        iPalletno++;
                                        lotCnt = 0;                 // LOT갯수 체크를 위해 사용
                                        ichkPalleno = iPalletno;    // LOT갯수 체크를 위해 사용

                                        // 추가 Pallet 수가 적재하기로 한 수 보다 크면 적재를 끝낸다.
                                        if (iProdEA < iPalletno)
                                            break;

                                        dInReam = dInReam - dProdRe;    // 투입연수 재 계산
                                        dProdRe = 0;                    // 적재 잔여연수 초기화
                                    }

                                    // 투입연수로 몇 Palleting가능한 지 계산
                                    iLoop = (int)(dInReam / dSND_PLT_REAM);

                                    if (iLoop > 0)  // 투입연수로 Palleting 가능한 만큼 적재한다.
                                    {
                                        dInRe = dInReam - (dSND_PLT_REAM * iLoop);   // 투입연수 잔여량 계산

                                        dProdRe = 0;

                                        for (int j = 0; j < iLoop; j++)
                                        {
                                            dUseReam = dSND_PLT_REAM;                    // 적재연수

                                            if (ichkPalleno == iPalletno && lotCnt > MAX_LOT_CNT)
                                            {
                                                new POPUP.MessageForm("1팔레트에 최대 5개 LOT만 적재 가능합니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                                LogFile.WriteLog("POP_WRK27.ChkBtnFind Error : " + "1팔레트에 최대 5개 LOT만 적재 가능합니다.");
                                                return null;
                                            }

                                            dr = sdt1.NewRow();
                                            dr["GUBUN"] = sGUBUN_DATA;                       //'1' 은 실적, '2'은 부분실적, '3' 폐품
                                            dr["PLT_NO"] = iPalletno.ToString();
                                            dr["IND_BCD_M"] = dtSrc.Rows[i]["IND_BCD"].ToString();
                                            dr["LOT_NO_M"] = dtSrc.Rows[i]["LOT_NO"].ToString();
                                            dr["ABLE_QTY_M"] = dtSrc.Rows[i]["ABLE_QTY"].ToString();
                                            dr["USE_REAM_M"] = string.Format("{0:###0.###}", dUseReam);
                                            dr["USE_WGT_M"] = string.Format("{0:###0.###}", (dUseReam * 500) * ((Decimal)dBS_WGT / 1000) * ((Decimal)dWLEN / 1000) * ((Decimal)dVLEN / 1000));
                                            dr["MATNR_M"] = dtSrc.Rows[i]["MATNR"].ToString();                      // 재단 자재코드
                                            dr["WRK_ORDR_NO_M"] = dtSrc.Rows[i]["WRK_ORDR_NO"].ToString();          // 재단작업지시번호
                                            dr["WRK_ORDR_SEQNO_M"] = dtSrc.Rows[i]["WRK_ORDR_SEQNO"].ToString();    // 재단작업지시순번
                                            dr["PACK_LABEL_TYPE"] = sLABEL_TYPE;      // 포장 라벨 인쇄 양식

                                            if (gsWODIV == "예외")
                                            {
                                                dr["WRK_ORDR_NO"] = Common.WrkOrderNo;          // 포장작업지시번호
                                                dr["WRK_ORDR_SEQNO"] = Common.WrkOrderSeq;      // 포장작업지시순번
                                            }
                                            else
                                            {
                                                dr["WRK_ORDR_NO"] = dtSrc.Rows[i]["PC_WRK_ORDR_NO"].ToString();          // 포장작업지시번호
                                                dr["WRK_ORDR_SEQNO"] = dtSrc.Rows[i]["PC_WRK_ORDR_SEQNO"].ToString();    // 포장작업지시순번
                                            }

                                            // 가용연수 업데이트
                                            Decimal.TryParse(dtSrc.Rows[i]["ABLE_QTY"].ToString().Replace(",", ""), out dAbleQty);
                                            dAbleQty = dAbleQty - dUseReam;
                                            dtSrc.Rows[i]["ABLE_QTY"] = string.Format("{0:###0.###}", dAbleQty);
                                            if (dAbleQty <= 0)
                                            {
                                                dtSrc.Rows[i]["CHK"] = "-";
                                            }

                                            sdt1.Rows.Add(dr);

                                            iPalletno++;
                                            lotCnt = 0;
                                            ichkPalleno = iPalletno;

                                            // 추가 Pallet 수가 적재하기로 한 수 보다 크면 적재를 끝낸다.
                                            if (iProdEA < iPalletno)
                                                break;
                                        }

                                    }
                                    else    // 투입연수로 Palleting계산시 0일 경우 (발생 : 잔여적재가 남은 상태에서 투입할 경우 발생)
                                    {
                                        dInRe = 0;                                      // 투입 잔여 초기화
                                        dProdRe = dSND_PLT_REAM - dInReam;   // 적재 잔여 계산
                                        dUseReam = dInReam;                             // 적재 연수

                                        if (ichkPalleno == iPalletno && lotCnt > MAX_LOT_CNT)
                                        {
                                            new POPUP.MessageForm("1팔레트에 최대 5개 LOT만 적재 가능합니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                            LogFile.WriteLog("POP_WRK27.ChkBtnFind Error : " + "1팔레트에 최대 5개 LOT만 적재 가능합니다.");
                                            return null;
                                        }

                                        dr = sdt1.NewRow();
                                        dr["GUBUN"] = sGUBUN_DATA;                       //'1' 은 실적, '2'은 부분실적, '3' 폐품
                                        dr["PLT_NO"] = iPalletno.ToString();
                                        dr["IND_BCD_M"] = dtSrc.Rows[i]["IND_BCD"].ToString();
                                        dr["LOT_NO_M"] = dtSrc.Rows[i]["LOT_NO"].ToString();
                                        dr["ABLE_QTY_M"] = dtSrc.Rows[i]["ABLE_QTY"].ToString();
                                        dr["USE_REAM_M"] = string.Format("{0:###0.###}", dUseReam);
                                        dr["USE_WGT_M"] = string.Format("{0:###0.###}", (dUseReam * 500) * ((Decimal)dBS_WGT / 1000) * ((Decimal)dWLEN / 1000) * ((Decimal)dVLEN / 1000));
                                        dr["MATNR_M"] = dtSrc.Rows[i]["MATNR"].ToString();                      // 재단 자재코드
                                        dr["WRK_ORDR_NO_M"] = dtSrc.Rows[i]["WRK_ORDR_NO"].ToString();          // 재단작업지시번호
                                        dr["WRK_ORDR_SEQNO_M"] = dtSrc.Rows[i]["WRK_ORDR_SEQNO"].ToString();    // 재단작업지시순번
                                        dr["PACK_LABEL_TYPE"] = sLABEL_TYPE;      // 포장 라벨 인쇄 양식

                                        if (gsWODIV == "예외")
                                        {
                                            dr["WRK_ORDR_NO"] = Common.WrkOrderNo;          // 포장작업지시번호
                                            dr["WRK_ORDR_SEQNO"] = Common.WrkOrderSeq;    // 포장작업지시순번
                                        }
                                        else
                                        {
                                            dr["WRK_ORDR_NO"] = dtSrc.Rows[i]["PC_WRK_ORDR_NO"].ToString();          // 포장작업지시번호
                                            dr["WRK_ORDR_SEQNO"] = dtSrc.Rows[i]["PC_WRK_ORDR_SEQNO"].ToString();    // 포장작업지시순번
                                        }

                                        // 가용연수 업데이트
                                        Decimal.TryParse(dtSrc.Rows[i]["ABLE_QTY"].ToString().Replace(",", ""), out dAbleQty);
                                        dAbleQty = dAbleQty - dUseReam;
                                        dtSrc.Rows[i]["ABLE_QTY"] = string.Format("{0:###0.###}", dAbleQty);
                                        if (dAbleQty <= 0)
                                        {
                                            dtSrc.Rows[i]["CHK"] = "-";
                                        }

                                        sdt1.Rows.Add(dr);
                                    }

                                    // 추가 Pallet 수가 적재하기로 한 수 보다 크면 적재를 끝낸다.
                                    if (iProdEA < iPalletno)
                                        break;

                                    if (dInRe > 0)      // 투입잔여가 있을 경우 계속 적재한다.
                                    {
                                        if (ichkPalleno == iPalletno && lotCnt > MAX_LOT_CNT)
                                        {
                                            new POPUP.MessageForm("1팔레트에 최대 5개 LOT만 적재 가능합니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                            LogFile.WriteLog("POP_WRK27.ChkBtnFind Error : " + "1팔레트에 최대 5개 LOT만 적재 가능합니다.");
                                            return null;
                                        }

                                        dr = sdt1.NewRow();
                                        dr["GUBUN"] = sGUBUN_DATA;                       //'1' 은 실적, '2'은 부분실적, '3' 폐품
                                        dr["PLT_NO"] = iPalletno.ToString();
                                        dr["IND_BCD_M"] = dtSrc.Rows[i]["IND_BCD"].ToString();
                                        dr["LOT_NO_M"] = dtSrc.Rows[i]["LOT_NO"].ToString();
                                        dr["ABLE_QTY_M"] = dtSrc.Rows[i]["ABLE_QTY"].ToString();
                                        dr["USE_REAM_M"] = string.Format("{0:###0.###}", dInRe);
                                        dr["USE_WGT_M"] = string.Format("{0:###0.###}", (dInRe * 500) * ((Decimal)dBS_WGT / 1000) * ((Decimal)dWLEN / 1000) * ((Decimal)dVLEN / 1000));
                                        dr["MATNR_M"] = dtSrc.Rows[i]["MATNR"].ToString();                      // 재단 자재코드
                                        dr["WRK_ORDR_NO_M"] = dtSrc.Rows[i]["WRK_ORDR_NO"].ToString();          // 재단작업지시번호
                                        dr["WRK_ORDR_SEQNO_M"] = dtSrc.Rows[i]["WRK_ORDR_SEQNO"].ToString();    // 재단작업지시순번
                                        dr["PACK_LABEL_TYPE"] = sLABEL_TYPE;      // 포장 라벨 인쇄 양식

                                        if (gsWODIV == "예외")
                                        {
                                            dr["WRK_ORDR_NO"] = Common.WrkOrderNo;          // 포장작업지시번호
                                            dr["WRK_ORDR_SEQNO"] = Common.WrkOrderSeq;    // 포장작업지시순번
                                        }
                                        else
                                        {
                                            dr["WRK_ORDR_NO"] = dtSrc.Rows[i]["PC_WRK_ORDR_NO"].ToString();          // 포장작업지시번호
                                            dr["WRK_ORDR_SEQNO"] = dtSrc.Rows[i]["PC_WRK_ORDR_SEQNO"].ToString();    // 포장작업지시순번
                                        }

                                        // 가용연수 업데이트
                                        Decimal.TryParse(dtSrc.Rows[i]["ABLE_QTY"].ToString().Replace(",", ""), out dAbleQty);
                                        dAbleQty = dAbleQty - dInRe;
                                        dtSrc.Rows[i]["ABLE_QTY"] = string.Format("{0:###0.###}", dAbleQty);
                                        if (dAbleQty <= 0)
                                        {
                                            dtSrc.Rows[i]["CHK"] = "-";
                                        }


                                        sdt1.Rows.Add(dr);

                                        dProdRe = dSND_PLT_REAM - dInRe;     // 적재 잔여 계산
                                        dInRe = 0;                                      // 투입 잔여 초기화
                                    }
                                }
                                else // 투입연수가 적재연수 보다 작을 경우
                                {
                                    // 추가 Pallet 수가 적재하기로 한 수 보다 크면 적재를 끝낸다.
                                    if (iProdEA < iPalletno)
                                        break;

                                    if (dProdRe > 0)    // 적재 잔여가 있을 경우
                                    {
                                        if (dProdRe > dInReam)  // 적재잔여가 투입연수 보다 클 경우
                                        {
                                            if (ichkPalleno == iPalletno && lotCnt > MAX_LOT_CNT)
                                            {
                                                new POPUP.MessageForm("1팔레트에 최대 5개 LOT만 적재 가능합니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                                LogFile.WriteLog("POP_WRK27.ChkBtnFind Error : " + "1팔레트에 최대 5개 LOT만 적재 가능합니다.");
                                                return null;
                                            }

                                            dr = sdt1.NewRow();
                                            dr["GUBUN"] = sGUBUN_DATA;                       //'1' 은 실적, '2'은 부분실적, '3' 폐품
                                            dr["PLT_NO"] = iPalletno.ToString();
                                            dr["IND_BCD_M"] = dtSrc.Rows[i]["IND_BCD"].ToString();
                                            dr["LOT_NO_M"] = dtSrc.Rows[i]["LOT_NO"].ToString();
                                            dr["ABLE_QTY_M"] = dtSrc.Rows[i]["ABLE_QTY"].ToString();
                                            dr["USE_REAM_M"] = string.Format("{0:###0.###}", dInReam);
                                            dr["USE_WGT_M"] = string.Format("{0:###0.###}", (dInReam * 500) * ((Decimal)dBS_WGT / 1000) * ((Decimal)dWLEN / 1000) * ((Decimal)dVLEN / 1000));
                                            dr["MATNR_M"] = dtSrc.Rows[i]["MATNR"].ToString();                      // 재단 자재코드
                                            dr["WRK_ORDR_NO_M"] = dtSrc.Rows[i]["WRK_ORDR_NO"].ToString();          // 재단작업지시번호
                                            dr["WRK_ORDR_SEQNO_M"] = dtSrc.Rows[i]["WRK_ORDR_SEQNO"].ToString();    // 재단작업지시순번
                                            dr["PACK_LABEL_TYPE"] = sLABEL_TYPE;      // 포장 라벨 인쇄 양식

                                            if (gsWODIV == "예외")
                                            {
                                                dr["WRK_ORDR_NO"] = Common.WrkOrderNo;          // 포장작업지시번호
                                                dr["WRK_ORDR_SEQNO"] = Common.WrkOrderSeq;    // 포장작업지시순번
                                            }
                                            else
                                            {
                                                dr["WRK_ORDR_NO"] = dtSrc.Rows[i]["PC_WRK_ORDR_NO"].ToString();          // 포장작업지시번호
                                                dr["WRK_ORDR_SEQNO"] = dtSrc.Rows[i]["PC_WRK_ORDR_SEQNO"].ToString();    // 포장작업지시순번
                                            }

                                            // 가용연수 업데이트
                                            Decimal.TryParse(dtSrc.Rows[i]["ABLE_QTY"].ToString().Replace(",", ""), out dAbleQty);
                                            dAbleQty = dAbleQty - dInReam;
                                            dtSrc.Rows[i]["ABLE_QTY"] = string.Format("{0:###0.###}", dAbleQty);
                                            if (dAbleQty <= 0)
                                            {
                                                dtSrc.Rows[i]["CHK"] = "-";
                                            }

                                            sdt1.Rows.Add(dr);

                                            dProdRe = dProdRe - dInReam;    // 적재 잔여 계산
                                        }
                                        else    // 적재잔여가 투입연수 이하 일 경우
                                        {
                                            if (ichkPalleno == iPalletno && lotCnt > MAX_LOT_CNT)
                                            {
                                                new POPUP.MessageForm("1팔레트에 최대 5개 LOT만 적재 가능합니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                                LogFile.WriteLog("POP_WRK27.ChkBtnFind Error : " + "1팔레트에 최대 5개 LOT만 적재 가능합니다.");
                                                return null;
                                            }

                                            dr = sdt1.NewRow();
                                            dr["GUBUN"] = sGUBUN_DATA;                       //'1' 은 실적, '2'은 부분실적, '3' 폐품
                                            dr["PLT_NO"] = iPalletno.ToString();
                                            dr["IND_BCD_M"] = dtSrc.Rows[i]["IND_BCD"].ToString();
                                            dr["LOT_NO_M"] = dtSrc.Rows[i]["LOT_NO"].ToString();
                                            dr["ABLE_QTY_M"] = dtSrc.Rows[i]["ABLE_QTY"].ToString();
                                            dr["USE_REAM_M"] = string.Format("{0:###0.###}", dProdRe);
                                            dr["USE_WGT_M"] = string.Format("{0:###0.###}", (dProdRe * 500) * ((Decimal)dBS_WGT / 1000) * ((Decimal)dWLEN / 1000) * ((Decimal)dVLEN / 1000));
                                            dr["MATNR_M"] = dtSrc.Rows[i]["MATNR"].ToString();                      // 재단 자재코드
                                            dr["WRK_ORDR_NO_M"] = dtSrc.Rows[i]["WRK_ORDR_NO"].ToString();          // 재단작업지시번호
                                            dr["WRK_ORDR_SEQNO_M"] = dtSrc.Rows[i]["WRK_ORDR_SEQNO"].ToString();    // 재단작업지시순번
                                            dr["PACK_LABEL_TYPE"] = sLABEL_TYPE;      // 포장 라벨 인쇄 양식

                                            if (gsWODIV == "예외")
                                            {
                                                dr["WRK_ORDR_NO"] = Common.WrkOrderNo;          // 포장작업지시번호
                                                dr["WRK_ORDR_SEQNO"] = Common.WrkOrderSeq;    // 포장작업지시순번
                                            }
                                            else
                                            {
                                                dr["WRK_ORDR_NO"] = dtSrc.Rows[i]["PC_WRK_ORDR_NO"].ToString();          // 포장작업지시번호
                                                dr["WRK_ORDR_SEQNO"] = dtSrc.Rows[i]["PC_WRK_ORDR_SEQNO"].ToString();    // 포장작업지시순번
                                            }

                                            // 가용연수 업데이트
                                            Decimal.TryParse(dtSrc.Rows[i]["ABLE_QTY"].ToString().Replace(",", ""), out dAbleQty);
                                            dAbleQty = dAbleQty - dProdRe;
                                            dtSrc.Rows[i]["ABLE_QTY"] = string.Format("{0:###0.###}", dAbleQty);
                                            if (dAbleQty <= 0)
                                            {
                                                dtSrc.Rows[i]["CHK"] = "-";
                                            }

                                            sdt1.Rows.Add(dr);

                                            iPalletno++;
                                            lotCnt = 0;
                                            ichkPalleno = iPalletno;

                                            // 추가 Pallet 수가 적재하기로 한 수 보다 크면 적재를 끝낸다.
                                            if (iProdEA < iPalletno)
                                                break;

                                            dInRe = dInReam - dProdRe;  // 투입잔여계산
                                            dProdRe = 0;                // 적재잔여 초기화

                                            if (dInRe > 0)  // 투입잔여가 있을 경우 계속 적재한다.
                                            {
                                                if (ichkPalleno == iPalletno && lotCnt > MAX_LOT_CNT)
                                                {
                                                    new POPUP.MessageForm("1팔레트에 최대 5개 LOT만 적재 가능합니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                                    LogFile.WriteLog("POP_WRK27.ChkBtnFind Error : " + "1팔레트에 최대 5개 LOT만 적재 가능합니다.");
                                                    return null;
                                                }

                                                dr = sdt1.NewRow();
                                                dr["GUBUN"] = sGUBUN_DATA;                       //'1' 은 실적, '2'은 부분실적, '3' 폐품
                                                dr["PLT_NO"] = iPalletno.ToString();
                                                dr["IND_BCD_M"] = dtSrc.Rows[i]["IND_BCD"].ToString();
                                                dr["LOT_NO_M"] = dtSrc.Rows[i]["LOT_NO"].ToString();
                                                dr["ABLE_QTY_M"] = dtSrc.Rows[i]["ABLE_QTY"].ToString();
                                                dr["USE_REAM_M"] = string.Format("{0:###0.###}", dInRe);
                                                dr["USE_WGT_M"] = string.Format("{0:###0.###}", (dInRe * 500) * ((Decimal)dBS_WGT / 1000) * ((Decimal)dWLEN / 1000) * ((Decimal)dVLEN / 1000));
                                                dr["MATNR_M"] = dtSrc.Rows[i]["MATNR"].ToString();                      // 재단 자재코드
                                                dr["WRK_ORDR_NO_M"] = dtSrc.Rows[i]["WRK_ORDR_NO"].ToString();          // 재단작업지시번호
                                                dr["WRK_ORDR_SEQNO_M"] = dtSrc.Rows[i]["WRK_ORDR_SEQNO"].ToString();    // 재단작업지시순번
                                                dr["PACK_LABEL_TYPE"] = sLABEL_TYPE;      // 포장 라벨 인쇄 양식

                                                if (gsWODIV == "예외")
                                                {
                                                    dr["WRK_ORDR_NO"] = Common.WrkOrderNo;          // 포장작업지시번호
                                                    dr["WRK_ORDR_SEQNO"] = Common.WrkOrderSeq;    // 포장작업지시순번
                                                }
                                                else
                                                {
                                                    dr["WRK_ORDR_NO"] = dtSrc.Rows[i]["PC_WRK_ORDR_NO"].ToString();          // 포장작업지시번호
                                                    dr["WRK_ORDR_SEQNO"] = dtSrc.Rows[i]["PC_WRK_ORDR_SEQNO"].ToString();    // 포장작업지시순번
                                                }

                                                // 가용연수 업데이트
                                                Decimal.TryParse(dtSrc.Rows[i]["ABLE_QTY"].ToString().Replace(",", ""), out dAbleQty);
                                                dAbleQty = dAbleQty - dInRe;
                                                dtSrc.Rows[i]["ABLE_QTY"] = string.Format("{0:###0.###}", dAbleQty);
                                                if (dAbleQty <= 0)
                                                {
                                                    dtSrc.Rows[i]["CHK"] = "-";
                                                }

                                                sdt1.Rows.Add(dr);

                                                dProdRe = dSND_PLT_REAM - dInRe;     // 적재잔여 계산
                                                dInRe = 0;                                      // 투입잔여 초괴화
                                            }
                                        }
                                    }
                                    else
                                    {
                                        if (ichkPalleno == iPalletno && lotCnt > MAX_LOT_CNT)
                                        {
                                            new POPUP.MessageForm("1팔레트에 최대 5개 LOT만 적재 가능합니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                            LogFile.WriteLog("POP_WRK27.ChkBtnFind Error : " + "1팔레트에 최대 5개 LOT만 적재 가능합니다.");
                                            return null;
                                        }

                                        dr = sdt1.NewRow();
                                        dr["GUBUN"] = sGUBUN_DATA;                       //'1' 은 실적, '2'은 부분실적, '3' 폐품
                                        dr["PLT_NO"] = iPalletno.ToString();
                                        dr["IND_BCD_M"] = dtSrc.Rows[i]["IND_BCD"].ToString();
                                        dr["LOT_NO_M"] = dtSrc.Rows[i]["LOT_NO"].ToString();
                                        dr["ABLE_QTY_M"] = dtSrc.Rows[i]["ABLE_QTY"].ToString();
                                        dr["USE_REAM_M"] = string.Format("{0:###0.###}", dInReam);
                                        dr["USE_WGT_M"] = string.Format("{0:###0.###}", (dInReam * 500) * ((Decimal)dBS_WGT / 1000) * ((Decimal)dWLEN / 1000) * ((Decimal)dVLEN / 1000));
                                        dr["MATNR_M"] = dtSrc.Rows[i]["MATNR"].ToString();                      // 재단 자재코드
                                        dr["WRK_ORDR_NO_M"] = dtSrc.Rows[i]["WRK_ORDR_NO"].ToString();          // 재단작업지시번호
                                        dr["WRK_ORDR_SEQNO_M"] = dtSrc.Rows[i]["WRK_ORDR_SEQNO"].ToString();    // 재단작업지시순번
                                        dr["PACK_LABEL_TYPE"] = sLABEL_TYPE;      // 포장 라벨 인쇄 양식

                                        if (gsWODIV == "예외")
                                        {
                                            dr["WRK_ORDR_NO"] = Common.WrkOrderNo;          // 포장작업지시번호
                                            dr["WRK_ORDR_SEQNO"] = Common.WrkOrderSeq;    // 포장작업지시순번
                                        }
                                        else
                                        {
                                            dr["WRK_ORDR_NO"] = dtSrc.Rows[i]["PC_WRK_ORDR_NO"].ToString();          // 포장작업지시번호
                                            dr["WRK_ORDR_SEQNO"] = dtSrc.Rows[i]["PC_WRK_ORDR_SEQNO"].ToString();    // 포장작업지시순번
                                        }

                                        // 가용연수 업데이트
                                        Decimal.TryParse(dtSrc.Rows[i]["ABLE_QTY"].ToString().Replace(",", ""), out dAbleQty);
                                        dAbleQty = dAbleQty - dInReam;
                                        dtSrc.Rows[i]["ABLE_QTY"] = string.Format("{0:###0.###}", dAbleQty);
                                        if (dAbleQty <= 0)
                                        {
                                            dtSrc.Rows[i]["CHK"] = "-";
                                        }

                                        sdt1.Rows.Add(dr);

                                        dProdRe = dSND_PLT_REAM - dInReam;   // 적재잔여 계산
                                    }
                                }
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                new POPUP.MessageForm("팔레트별 연수 계산 오류 : \r\n" + ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);

                return null;
            }

            return sdt1;
        }

        private void lblPF_WRK_ORDR_RMK_Click(object sender, EventArgs e)
        {
            DAResultText pop = new DAResultText("포장 비고 입력", lblPF_WRK_ORDR_RMK.Text.ToString());
            pop.ContentMaxLength = 100;

            pop.ShowDialog(this);
            if (pop.DialogResult == DialogResult.OK)
            {
                lblPF_WRK_ORDR_RMK.Text = pop.ResultString;
            }
        }

        private void btnClose_Click(object sender, EventArgs e)
        {
            pnlWrkOrdr.Visible = false;
            btnINP_INFO.Text = "선택";

            if (lblAllSearchChk.Text.ToString().Equals("V"))
            {
                btnFindMain.Text = "전체조회";
            }
            else
            {
                btnFindMain.Text = "설비조회";
            }
        }

        private void lblAllSearchChk_Click(object sender, EventArgs e)
        {
            if (lblAllSearchChk.Text.ToString().Equals("V"))
            {
                lblAllSearchChk.Text = "";
                lblAllSearchChk.BackColor = Color.White;
                btnFindMain.Text = "설비조회";
            }
            else
            {
                // 전체보기 인증번호 없이 다보이도록함.
                //POP_Login pop = new POP_Login();
                //pop.ShowDialog();
                //if (pop.DialogResult == DialogResult.OK)
                {
                    lblAllSearchChk.Text = "V";
                    lblAllSearchChk.BackColor = Color.Yellow;
                    btnFindMain.Text = "전체조회";
                }
            }

            SetGridWrkOrdr();

            UpdateGrid();
            if (lblAllSearchChk.Text.ToString() == "V")     // 전체보기 Y=전체, N=현재 작업장만 조회
            {
                ChkBtnFind();
            }
        }

        private void btnREQ_STR_DATE_Click(object sender, EventArgs e)
        {
            DAResultDate pop = new DAResultDate(dtpREQ_STR_DATE.Value);
            pop.ShowDialog();
            if (pop.DialogResult == DialogResult.OK)
            {
                string strDate = pop.ResultString.ToString();
                dtpREQ_STR_DATE.Value = DateTime.Parse(strDate);
            }
        }

        private void btnREQ_END_DATE_Click(object sender, EventArgs e)
        {
            DAResultDate pop = new DAResultDate(dtpREQ_END_DATE.Value);
            pop.ShowDialog();
            if (pop.DialogResult == DialogResult.OK)
            {
                string strDate = pop.ResultString.ToString();
                dtpREQ_END_DATE.Value = DateTime.Parse(strDate);
            }
        }

        private void btnFindMain_Click(object sender, EventArgs e)
        {
            UpdateGrid();
            if (lblAllSearchChk.Text.ToString() == "V")     // 전체보기 Y=전체, N=현재 작업장만 조회
            {
                ChkBtnFind();
            }
        }

        private void timer1_Tick(object sender, EventArgs e)
        {
            if (bABNChk)
            {
                bBox1[0, 3].bAlarm = bBox1[0, 3].bAlarm ? false : true;
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
