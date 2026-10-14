#region [ USING AREA ]
using System;
using System.Configuration;
using System.Data;
using System.Windows.Forms;
using System.Drawing;
using SmartDas.Components;
using SmartDas.POPUP;
using Infragistics.Win.UltraWinGrid;
using SAMMI;
using System.Globalization;
using Oracle.ManagedDataAccess.Client;
using System.Threading;
#endregion

namespace SmartDas
{
    public partial class POP_WRK29 : BaseForm
    {
        #region < MEMBER AREA >
        private DataTable dtInpInfo = new DataTable();            //투입 정보 테이블
        private DataTable dtInpInfo1 = new DataTable();           //투입 정보 테이블 (수재단에서만 사용)
        private DataTable dtWrkInfo = new DataTable();

        private Decimal gdABLEWGT = 0;           //실적가능 중량 (실적 + 폐품)
        private Decimal gdABLREAM = 0;           //실적가능 REAM (실적 + 폐품)
        private string gsgrid2CHK = "N";
        private string gsWODIV = string.Empty;  //작업지시 구분 ( 정상, 예외)
        private Decimal gdCntReam = 1;

        private bool gbWrkOrdrChange = true;

        private SAMMI.Common _common = new SAMMI.Common();

        // 버튼 알람용 변수
        private int iReSetCnt = 0;
        private bool bABNChk = false;
        DataTable dtStop_Temp = new DataTable();

        #endregion

        #region < CONSTRUCTOR >

        public POP_WRK29()
        {
            InitializeComponent();

            Common.SetMessageList();
            this.UpdateMinuteEvent += new UpdateMinuteHandler(CallUpdateMinuteFunc);
        }

        private void CallUpdateMinuteFunc()
        {
            if (lblEndDateChk.Text == "V")
            {
                DateTime dtTmp = DateTime.Now;

                // lblStartTime.Text 에 시:분 을 먼지 입력해야 dtpDate_ValueChanged 이벤트에서 AutoCalculation() 에서 정상처리됨.
                lblEndTime.Text = dtTmp.ToString("HH:mm");       // 작업종료시간
                dtpEndDate.Value = dtTmp;
            }
        }

        #endregion

        #region < POP_WRK29_Load >
        private void POP_WRK29_Load(object sender, EventArgs e)
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

                this.lblTitle.Text = "수재단 실적등록";

                //IP별 정보 구하기
                Common.machSetting();

                // 하단 메뉴버튼 생성
                SetMenuButtons();


                // 콤보박스 초기화
                ucLABEL_TYPE.SelectedIndex = 1;
                ucLABEL_TYPE.ValueList.ItemHeight = 70;

                ucPNT_CNT.SelectedIndex = 1;
                ucPNT_CNT.ValueList.ItemHeight = 70;

                // 화면 초기설정
                InitProduct();

                CheckValue(lblEndChk, string.Empty);        //수재단완료
                CheckValue(lblPrintChk, "V");               //자동인쇄

                //투입정보 및 작업지시 정보 표시
                gbWrkOrdrChange = true;
                UpdateGrid();
            }
            catch (Exception ex)
            {
                SetMessage("POP_WRK29_Load_ Error!");
                LogFile.WriteLog("POP_WRK29.POP_WRK29_Load Error => " + ex.Message);
            }
        }

        /// <summary>
        /// 실적 등록후 초기설정
        /// </summary>
        private void InitProduct()
        {
            // 체크박스 초기설정
            CheckValue(lblEndDateChk, "V");             //to date

            CheckValue(lblPF_CHK_DISPO, string.Empty);  //반품사유
            // 투입정보
            lblIN_WRK_ORDR.Text = string.Empty;
            lblIN_PCODE.Text = string.Empty;
            lblIN_MAT_CD.Text = string.Empty;
            lblIN_MOVE_WGT.Text = string.Empty;
            lblIN_USE_WGT.Text = string.Empty;
            lblIN_DISPO_WGT.Text = string.Empty;
            lblIN_AVA_WGT.Text = string.Empty;
            lblIN_MOVE_REAM.Text = string.Empty;
            lblIN_USE_REAM.Text = string.Empty;
            lblIN_DISPO_REAM.Text = string.Empty;
            lblIN_AVA_REAM.Text = string.Empty;
            lblIN_BS_WGT.Text = string.Empty;
            lblIN_WLEN.Text = string.Empty;
            lblIN_VLEN.Text = string.Empty;
            txtIN_ORDER_RMK.Text = string.Empty;
            //생산진행상태
            //lblMACH_STA.Text = "대기중";
            // 실적 입력
            lblPF_PLT_REAM.Text = string.Empty;
            lblPF_PLT_EA.Text = string.Empty;
            lblPF_TOT_REAM.Text = string.Empty;
            lblPF_TOT_WGT.Text = string.Empty;
            lblPF_WRK_ORDR_RMK.Text = string.Empty;
            // 완료시간
            dtpEndDate.Enabled = false;
            butEndDate.Enabled = false;
            lblEndTime.Enabled = false;

            InitDISPO();
        }

        // 폐품정보 초기설정
        private void InitDISPO()
        {
            lblPF_DISPO_REAM.Enabled = false;
            lblPF_DISPO_REAM.BackColor = Color.LightGray;
            lblPF_DISPO_REAM.Text = string.Empty;
            lblPF_DISPO_WGT.Text = string.Empty;
            lblPF_DISPO_CODE.Text = string.Empty;
            lblPF_DISPO_CODE.Tag = string.Empty;

            CheckValue(lblPF_CHK_DISPO, string.Empty);
            lblPF_CHK_DISPO.Visible = false;
            lblPF_DISPO_CODE_NAME.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
        }
        #endregion

        #region < METHOD AREA >

        private void UpdateGrid()
        {
            //작업지시정보 (그리드1, 그리드2)
            SetGrid();

            // 투입 정보 및 기 생산실적 정보 보여주기
            //DoFind();

            //기 입력 실적 계산
            DoFind02();

            //DoFind03();
        }

        private void SetGrid()
        {
            DBHelper helper = new DBHelper();
            DataSet dsRtn = new DataSet();
            DataSet dsMA = new DataSet();       // 수재단 바코드 정보
            DataSet dsMAWrk = new DataSet();    // 수재단 작업지시 

            DataTable dtTemp = new DataTable();
            try
            {
                int nRowSel = 0;
                if (gbWrkOrdrChange == false)
                {
                    if (Grid1.Rows.Count > 0)
                    {
                        for (int i = 0; i < Grid1.Rows.Count; i++)
                        {
                            if (Grid1.Rows[i].Cells["CHK"].Value.ToString().Equals("V"))
                            {
                                nRowSel = i;
                            }
                        }
                    }
                }

                gbWrkOrdrChange = false;

                Grid1.Row = null;
                Grid1.DataSource = null;
                Grid2.DataSource = null;

                Common.OrderNo = string.Empty;      //생산오더번호
                Common.WrkOrderNo = string.Empty;   //작업지시번호
                Common.WrkOrderSeq = string.Empty;  //작업지시순번
                Common.ItemCode = string.Empty;     //자재코드

                Grid1.HeaderFontSize = 11;
                Grid1.FontSize = 12;
                Grid1.CountRows = 3;
                Grid1.AutoScroll = true;
                Grid1.DisplayLayout.Bands[0].Override.SelectTypeCol = SelectType.None;
                btnRightPage.LinkMoveSize = Grid1.CountRows;
                btnLeftPage.LinkMoveSize = Grid1.CountRows;
                btnGroupUp.LinkMoveSize = Grid1.CountRows;
                btnGroupDown.LinkMoveSize = Grid1.CountRows;

                Grid2.HeaderFontSize = 11;
                Grid2.FontSize = 11;
                Grid2.CountRows = 3;
                Grid2.AutoScroll = true;
                Grid2.DisplayLayout.Bands[0].Override.SelectTypeCol = SelectType.None;
                btnItemUp.LinkMoveSize = Grid2.CountRows;
                btnItemDown.LinkMoveSize = Grid2.CountRows;

                dsRtn = helper.FillDataSetN("SP_POP_WRK29_S01", CommandType.StoredProcedure, 4
                                                    , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)                     // 플랜트코드
                                                    , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)                  //작업장코드(설비코드)
                                                    , helper.CreateParameter("RS_MACH_STA", DbType.String, ParameterDirection.Output, null, 30)                     //  RES MACH_STA 가동상태(R :가동, S:비가동, N:대기중)
                                                    );

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

                //화면 Display
                if (helper.RSCODE.Equals("S"))
                {
                    dtInpInfo = dsRtn.Tables[0].Copy();
                    dtWrkInfo = dsRtn.Tables[3].Copy();
                    //Grid1에 필요한 Table에 데이타 넣기
                    dsMA.Tables.Add(dsRtn.Tables[1].Copy());
                    dsMA.Tables.Add(dsRtn.Tables[2].Copy());

                    if (dtInpInfo.Rows.Count > 0)
                    {
                        //작업지시
                        Common.WrkOrderNo = dtInpInfo.Rows[0]["WRK_ORDR_NO"].ToString();      //작업지시번호
                        Common.WrkOrderSeq = dtInpInfo.Rows[0]["WRK_ORDR_SEQNO"].ToString();  //작업지시순번

                        //작업지시번호
                        lblIN_WRK_ORDR.Text = string.Format("{0}-{1}", Common.WrkOrderNo, Common.WrkOrderSeq);

                        //투입정보 표시
                        lblIN_PCODE.Text = dtInpInfo.Rows[0]["PCODE_NM"].ToString();
                        lblIN_MAT_CD.Text = dtInpInfo.Rows[0]["MATNR"].ToString();
                        lblIN_BS_WGT.Text = dtInpInfo.Rows[0]["BS_WGT"].ToString();
                        lblIN_WLEN.Text = dtInpInfo.Rows[0]["WLEN"].ToString();
                        lblIN_VLEN.Text = dtInpInfo.Rows[0]["VLEN"].ToString();
                        txtIN_ORDER_RMK.Text = dtInpInfo.Rows[0]["RMK"].ToString();

                        // 시간 표시
                        DoFind01();
                    }
                    else
                    {
                        //SetMessage("투입에 대한 작업지시가 없습니다.");

                        lblIN_WRK_ORDR.Text = string.Empty;
                        lblIN_PCODE.Text = string.Empty;
                        lblIN_MAT_CD.Text = string.Empty;
                        lblIN_BS_WGT.Text = string.Empty;
                        lblIN_WLEN.Text = string.Empty;
                        lblIN_VLEN.Text = string.Empty;
                        txtIN_ORDER_RMK.Text = string.Empty;
                    }

                    // Grid1 View
                    Grid1.DoFind_Oracle(dsMA);
                    Grid1.DisplayLayout.Override.DefaultRowHeight = 50;

                    if (Grid1.Rows.Count > 0)
                    {
                        // 첫번째 행 선택
                        Grid1.Rows[nRowSel].Selected = true;
                        Grid1.Row = Grid1.Rows[nRowSel];

                        Grid1.Rows[nRowSel].Cells["CHK"].Value = "V";

                        Decimal dINREAM = 0, dUSEREAM = 0, dDISPREAM = 0, dABLEREAM = 0;
                        Decimal dINWGT = 0, dUSEWGT = 0, dDISPWGT, dABLEWGT = 0;

                        Decimal.TryParse(Grid1.Rows[nRowSel].Cells["IN_REAM"].Value.ToString(), out dINREAM);
                        Decimal.TryParse(Grid1.Rows[nRowSel].Cells["WGT"].Value.ToString(), out dINWGT);
                        Decimal.TryParse(Grid1.Rows[nRowSel].Cells["USE_QTY"].Value.ToString(), out dUSEREAM);
                        Decimal.TryParse(Grid1.Rows[nRowSel].Cells["USE_WGT"].Value.ToString(), out dUSEWGT);
                        Decimal.TryParse(Grid1.Rows[nRowSel].Cells["DISPO_QTY"].Value.ToString(), out dDISPREAM);
                        Decimal.TryParse(Grid1.Rows[nRowSel].Cells["DISWGT"].Value.ToString(), out dDISPWGT);

                        dABLEWGT = dINWGT - (dUSEWGT + dDISPWGT);
                        if (dABLEWGT < 0) dABLEWGT = 0;

                        // 중량정보
                        lblIN_MOVE_WGT.Text = string.Format("{0:#,##0.000}", dINWGT);     //투입중량
                        lblIN_USE_WGT.Text = string.Format("{0:#,##0.000}", dUSEWGT);     //사용중량
                        lblIN_DISPO_WGT.Text = string.Format("{0:#,##0.000}", dDISPWGT);  //폐품중량
                        lblIN_AVA_WGT.Text = string.Format("{0:#,##0.000}", dABLEWGT);    //가용중량

                        //GridSelectChanged event 강제 발생시킴
                        //Grid1_GridSelectChanged(Grid1, new AfterSelectChangeEventArgs(typeof(UltraGridRow)));
                        SetGrid2(Grid1.Rows[nRowSel].Cells["IND_BCD"].Value.ToString());

                        //연수정보 => MultipleReam : 가로,세로 비교하여 연수 구함
                        dINREAM = MultipleReam(dINREAM);
                        dABLEREAM = dINREAM - (dUSEREAM + dDISPREAM);

                        lblIN_MOVE_REAM.Text = string.Format("{0:#,##0.000}", dINREAM);    //투입연수
                        lblIN_USE_REAM.Text = string.Format("{0:#,##0.000}", dUSEREAM);    //사용연수
                        lblIN_DISPO_REAM.Text = string.Format("{0:#,##0.000}", dDISPREAM); //폐품연수
                        lblIN_AVA_REAM.Text = string.Format("{0:#,##0.000}", dABLEREAM);   //가용연수
                    }
                    else
                    {
                        lblIN_MOVE_REAM.Text = string.Empty;
                        lblIN_USE_REAM.Text = string.Empty;
                        lblIN_DISPO_REAM.Text = string.Empty;
                        lblIN_AVA_REAM.Text = string.Empty;
                        lblIN_MOVE_WGT.Text = string.Empty;
                        lblIN_USE_WGT.Text = string.Empty;
                        lblIN_DISPO_WGT.Text = string.Empty;
                        lblIN_AVA_WGT.Text = string.Empty;
                    }
                }
                else
                {
                    new POPUP.MessageForm(helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                }
            }
            catch (Exception ex)
            {
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                LogFile.WriteLog("POP_WRK29.SetGrid Error => " + ex.Message);
            }
        }

        /// <summary>
        /// 그리드2 변경
        /// </summary>
        private void SetGrid2(string sIND_BCD_M)
        {
            DBHelper helper = new DBHelper();
            DataSet dsRtn1 = new DataSet();
            DataSet dsMAWrk = new DataSet();    // 수재단 작업지시 

            try
            {
                Grid2.Row = null;
                Grid2.DataSource = null;

                Grid2.HeaderFontSize = 11;
                Grid2.FontSize = 11;
                Grid2.CountRows = 3;
                Grid2.AutoScroll = true;
                btnItemUp.LinkMoveSize = Grid2.CountRows;
                btnItemDown.LinkMoveSize = Grid2.CountRows;

                //if (Grid1.Rows.Count > 0)
                {
                    //string sIND_BCD_M = Grid1.Row.Cells["IND_BCD"].Value.ToString();

                    dsRtn1 = helper.FillDataSetN("SP_POP_WRK29_S02", CommandType.StoredProcedure, 3
                                                , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)
                                                , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)
                                                , helper.CreateParameter("P_IND_BCD_M", sIND_BCD_M, DbType.String, ParameterDirection.Input));

                    if (helper.RSCODE.Equals("S"))
                    {
                        dtInpInfo1 = dsRtn1.Tables[0].Copy();

                        //수재단 작업 지시
                        dsMAWrk.Tables.Add(dsRtn1.Tables[1].Copy());
                        //dsMAWrk.Tables.Add(dsRtn1.Tables[2].Copy());
                        // 작업지시번호로 테이블 SORT
                        DataView dv = new DataView(dsRtn1.Tables[2]);
                        dv.Sort = "WRK_ORDR_NO ASC";
                        //dtWrkOne = dv.ToTable();
                        dsMAWrk.Tables.Add(dv.ToTable());
                        Grid2.DoFind_Oracle(dsMAWrk);

                        Grid2.DisplayLayout.Override.DefaultRowHeight = 50;

                        if (Grid2.Rows.Count > 0)
                        {
                            // 첫번째 행 선택
                            Grid2.Rows[0].Selected = true;
                            Grid2.Row = Grid2.Rows[0];

                            if (Grid2.Row.Cells["GB"].Value.ToString() == "예외")
                            {
                                gsWODIV = "예외";
                                //메인 Title변경
                                this.lblTitle.Text = "수재단 실적등록(예외)";
                            }
                            else
                            {
                                gsWODIV = "계획";
                                this.lblTitle.Text = "수재단 실적등록";
                            }

                            gsgrid2CHK = "Y";   //그리드 check 여부


                            //초기 실적연수 및 팔레트 수량 표시
                            lblPF_PLT_REAM.Text = Grid2.Row.Cells["PLT_PER_CNT"].Value.ToString();
                            lblPF_PLT_EA.Text = "1";

                            WgtCalculation();

                            //for (int i = 1; i < Grid2.Rows.Count; i++)
                            //{
                            //    Grid2.Rows[i].Hidden = true;
                            //}
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                LogFile.WriteLog("POP_WRK29.SetGrid Error => " + ex.Message);
            }
        }

        private void DoFind()
        {
            try
            {
                if (dtInpInfo1.Rows.Count < 1 || Grid2.Rows.Count < 1)
                {
                    //SetMessage("조회된 작업지시가 없습니다.");
                    lblIN_PCODE.Text = string.Empty;
                    lblIN_MAT_CD.Text = string.Empty;
                    lblIN_MOVE_WGT.Text = string.Empty;
                    lblIN_USE_WGT.Text = string.Empty;
                    lblIN_DISPO_WGT.Text = string.Empty;
                    lblIN_AVA_WGT.Text = string.Empty;

                    lblIN_MOVE_REAM.Text = string.Empty;
                    lblIN_USE_REAM.Text = string.Empty;
                    lblIN_DISPO_REAM.Text = string.Empty;
                    lblIN_AVA_REAM.Text = string.Empty;

                    lblIN_BS_WGT.Text = string.Empty;
                    lblIN_WLEN.Text = string.Empty;
                    lblIN_VLEN.Text = string.Empty;
                    txtIN_ORDER_RMK.Text = string.Empty;
                }
                else
                {
                    lblIN_MAT_CD.Text = dtInpInfo1.Rows[0]["MATNR"].ToString();

                    // Grid2에서 구해옴 ( 예외 생산으로 인해 변경됨 dtInpInfo1 -> Grid2 )
                    if (gsgrid2CHK == "N")
                    {
                        lblIN_PCODE.Text = string.Empty;
                        lblIN_BS_WGT.Text = string.Empty;
                        lblIN_WLEN.Text = string.Empty;
                        lblIN_VLEN.Text = string.Empty;
                    }
                    else
                    {
                        lblIN_PCODE.Text = Grid2.Row.Cells["PCODE_NM"].Value.ToString();
                        lblIN_BS_WGT.Text = Grid2.Row.Cells["BS_WGT"].Value.ToString();
                        lblIN_WLEN.Text = Common.StrFormatInteger(dtInpInfo1.Rows[0]["WLEN"].ToString());
                        lblIN_VLEN.Text = Common.StrFormatInteger(dtInpInfo1.Rows[0]["VLEN"].ToString());
                    }

                    txtIN_ORDER_RMK.Text = dtInpInfo1.Rows[0]["RMK"].ToString().Replace("|", "\r\n"); //생산오더 비고
                }
            }
            catch (Exception ex)
            {
                SetMessage("SetGrid Error!");
                LogFile.WriteLog("POP_WRK29.DoFind Error => " + ex.Message);
            }
        }

        private void DoFind01()
        {
            try
            {
                string sPRD_STR_DTM = dtInpInfo.Rows[0]["PRD_STR_DTM"].ToString(); //생산시작일시(YYYYMMDDHH24MISS)
                DateTime dtTmp;

                if (DateTime.TryParseExact(sPRD_STR_DTM, "yyyyMMddHHmmss", null, DateTimeStyles.AssumeLocal, out dtTmp))
                {
                    lblStartTime.Text = dtTmp.ToString("HH:mm");    // 작업시작시간
                    dtpStartDate.Value = dtTmp;

                    lblEndTime.Text = dtTmp.ToString("HH:mm");      // 작업종료시간
                    dtpEndDate.Value = dtTmp;
                }
                else
                {
                    lblStartTime.Text = lblEndTime.Text = "";
                    dtpStartDate.Value = dtpEndDate.Value = DateTime.Now;
                }
            }
            catch (Exception ex)
            {
                SetMessage("SetGrid Error!");
                LogFile.WriteLog("POP_WRK29.DoFind Error => " + ex.Message);
            }
        }

        private void DoFind02()
        {
            int chk = 0;
            Decimal dINPUTWGT = 0;       //공정투입 중량
            Decimal dPRODWGT = 0;        //총 실적연수
            Decimal dDISPWGT = 0;        //총 폐품 실적연수

            if (Grid1.Rows.Count < 1)
                return;

            // 선택된 투입연수(T를 포함하는 바코드) 구하기
            Decimal.TryParse(lblIN_MOVE_WGT.Text, out dINPUTWGT);

            // 수재단 작업지시에서 계획연수(X), 실적연수, 폐품연수 구하기
            foreach (UltraGridRow ugr in Grid2.Rows)
            {
                Decimal dPRODREAM = 0;       //실적연수
                Decimal dDISPREAM = 0;       //폐품연수

                if (ugr.Cells["CHK"].Value.ToString().Equals("V"))
                {
                    Decimal.TryParse(ugr.Cells["PCNT"].Value.ToString().Replace(",", ""), out dPRODREAM);
                    Decimal.TryParse(ugr.Cells["DISPO_QTY"].Value.ToString().Replace(",", ""), out dDISPREAM);

                    dPRODWGT = dPRODWGT + ReamToWgt("2", dPRODREAM);
                    dDISPWGT = dDISPWGT + ReamToWgt("2", dDISPREAM);

                    chk++;
                }
            }

            if (chk > 0)
            {
                // 실적등록 가능 연수 (실적 + 폐품)
                gdABLEWGT = dINPUTWGT - (dPRODWGT + dDISPWGT);
                gdABLREAM = WgtToReam(gdABLEWGT);

                gsgrid2CHK = "Y";
            }
            else
            {
                // 실적등록 가능 연수 (실적 + 폐품)
                gdABLEWGT = 0;
                gdABLREAM = 0;

                gsgrid2CHK = "N";
            }
        }

        /// <summary>
        /// 실적수량 ( 실적, 폐품), 가용수량 계산하여 보여줌
        /// </summary>
        private void DoFind03()
        {
            if (Grid2.Rows.Count > 0)
            {
                Decimal dINWGT = string.IsNullOrEmpty(lblIN_MOVE_WGT.Text) ? 0 : Decimal.Parse(lblIN_MOVE_WGT.Text);
                Decimal dPRODREAM = 0;
                Decimal dDISPREAM = 0;
                Decimal dPRODWGT = 0;
                Decimal dDISPWGT = 0;
                Decimal dINREAM = string.IsNullOrEmpty(lblIN_MOVE_REAM.Text) ? 0 : Decimal.Parse(lblIN_MOVE_REAM.Text);

                if (dINWGT > 0)
                {
                    Decimal.TryParse(Grid2.Row.Cells["PCNT"].Value.ToString(), out dPRODREAM);
                    Decimal.TryParse(Grid2.Row.Cells["DISPO_QTY"].Value.ToString(), out dDISPREAM);

                    dPRODWGT = ReamToWgt("2", dPRODREAM);
                    dDISPWGT = ReamToWgt("2", dDISPREAM);

                    lblIN_USE_WGT.Text = Common.StrFormatDouble(dPRODWGT.ToString());
                    lblIN_DISPO_WGT.Text = Common.StrFormatDouble(dDISPWGT.ToString());
                    lblIN_AVA_WGT.Text = Common.StrFormatDouble((dINWGT - (dPRODWGT + dDISPWGT)).ToString());

                    lblIN_USE_REAM.Text = Common.StrFormatDouble(dPRODREAM.ToString());
                    lblIN_DISPO_REAM.Text = Common.StrFormatDouble(dDISPREAM.ToString());
                    lblIN_AVA_REAM.Text = Common.StrFormatDouble((dINREAM - (dPRODREAM + dDISPREAM)).ToString());
                }
            }
            else
            {
                lblIN_USE_WGT.Text = string.Empty;
                lblIN_DISPO_WGT.Text = string.Empty;
                lblIN_AVA_WGT.Text = lblIN_MOVE_WGT.Text;

                lblIN_USE_REAM.Text = string.Empty;
                lblIN_DISPO_REAM.Text = string.Empty;
                lblIN_AVA_REAM.Text = lblIN_MOVE_REAM.Text;
            }
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
                bBox1[0, 9].Text = "";  // + Environment.NewLine + "투입이력";
                bBox1[0, 9].Tag = "";   //"InputLog";
                bBox1[0, 9].MappingButton.FontSize = 14;
                bBox1[0, 10].Text = "실적현황";
                bBox1[0, 10].Tag = "Performance";
                bBox1[0, 10].MappingButton.FontSize = 14;

                bBox1.RedrawButtons();
            }
            catch (Exception ex)
            {
                SetMessage("SetButtons Error!");
                LogFile.WriteLog("POP_WRK29.SetMenuButtons Error => " + ex.Message);
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
                                isRefresh = true;
                                InitProduct();
                                gbWrkOrdrChange = true;
                            }
                            else
                                isRefresh = false;
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
                            InitProduct();
                            this.lblTitle.Text = "수재단 실적등록";
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
                        if (SettingCheck("MWOSXR"))
                        {
                            POP_WRK35 popWrk35 = new POP_WRK35();
                            popWrk35.LabelTitle = "수재단 폐품사유";

                            if (ShowDialogForm(popWrk35) == DialogResult.OK)
                            {
                                lblPF_DISPO_CODE.Tag = popWrk35.DispoCode;
                                lblPF_DISPO_CODE.Text = popWrk35.DispoName;
                                CheckValue(lblPF_CHK_DISPO, "V");
                                lblPF_CHK_DISPO.Visible = true;
                                lblPF_DISPO_REAM.Enabled = true;
                                lblPF_DISPO_REAM.BackColor = Color.White;
                                lblPF_DISPO_CODE_NAME.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
                            }
                            isRefresh = false;
                        }
                        break;
                    case "Input": //공정투입
                        POP_WRK01 WRK01 = new POP_WRK01(POP_WRK01.LOC_CB_2400);
                        if (ShowDialogForm(WRK01) == DialogResult.OK)
                            isRefresh = true;
                        else
                            isRefresh = false;

                        break;
                    case "Check": //공정체크
                        if (SettingCheck("MW"))
                        {
                            POP_WRK04 WRK04 = new POP_WRK04();
                            if (ShowDialogForm(WRK04) == DialogResult.OK)
                                isRefresh = true;
                            else
                                isRefresh = false;
                        }
                        break;
                    //case "InputLog": //자재투입이력
                    //    POP_INV02 INV02 = new POP_INV02();
                    //    ShowDialogForm(INV02);
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
                LogFile.WriteLog("POP_WRK29.bBox1_buttonClickEvent Error => " + ex.Message);
            }
            finally
            {
            }
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
                    helper.ExecuteNoneQuery("SP_POP_WRK29_I01", CommandType.StoredProcedure
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

                    sMSG = "작업지시가 정상적으로 시작 되었습니다.";
                    new POPUP.MessageForm(sMSG, MessageBoxButtons.OK, "알   림").ShowDialog(this);

                    lblMACH_STA.Text = "가동중";
                }
            }
            catch (Exception ex)
            {
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                //SetMessage("SetGrid Error!");
                LogFile.WriteLog("POP_WRK29.SetGrid Error => " + ex.Message);
            }
            finally
            {
                helper.Close();
            }
        }

        // 영업폐품 포함하여 가용량을 넘는지 검사
        private bool ValidationSalesDispo()
        {
            Decimal dIN_AVA_WGT = 0;     // 가용량
            Decimal dPF_TOT_WGT = 0;
            Decimal dPF_DISPO_WGT_01 = 0;
            Decimal dPF_SALES_DISPO_WGT = 0;    // 영업폐품

            Decimal dMWIDTH = 0;    // 실지폭
            Decimal dBS_WGT = 0;    // 평량
            Decimal dWLEN = 0;      // 가로길이
            Decimal dVLEN = 0;      // 세로길이
            Decimal dPKCNT = 0;     // 폭수

            Decimal.TryParse(lblIN_AVA_WGT.Text.ToString().Replace(",", ""), out dIN_AVA_WGT);         //
            Decimal.TryParse(lblPF_TOT_WGT.Text.ToString().Replace(",", ""), out dPF_TOT_WGT);         // 실적중량
            Decimal.TryParse(lblPF_DISPO_WGT.Text.ToString().Replace(",", ""), out dPF_DISPO_WGT_01);  // 폐품연수

            Decimal.TryParse(dtWrkInfo.Rows[0]["MWIDTH_INPUT"].ToString().Replace(",", ""), out dMWIDTH);       // 실지폭
            Decimal.TryParse(lblIN_BS_WGT.Text.ToString().Replace(",", ""), out dBS_WGT);                       // 평량
            Decimal.TryParse(Grid2.Row.Cells["WLEN"].Value.ToString().ToString().Replace(",", ""), out dWLEN);  // 가로길이
            Decimal.TryParse(Grid2.Row.Cells["VLEN"].Value.ToString().Replace(",", ""), out dVLEN);             // 세로길이

            if (dtWrkInfo.Rows[0]["MWIDTH_INPUT"].ToString() == "ZCOR")
                Decimal.TryParse(dtWrkInfo.Rows[0]["PKCNT"].ToString().Replace(",", ""), out dPKCNT);   // 재단폭수 사용
            else
                Decimal.TryParse(dtWrkInfo.Rows[0]["MRCNT"].ToString().Replace(",", ""), out dPKCNT);   // 밀롤폭수 사용

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

            // 영업폐품 계산 임시로 주석 처리.
            dPF_SALES_DISPO_WGT = 0;

            Decimal dTOT_WGT_CALC = dPF_TOT_WGT + dPF_DISPO_WGT_01 + dPF_SALES_DISPO_WGT;
            if (dIN_AVA_WGT < dTOT_WGT_CALC)
            {
                new POPUP.MessageForm(string.Format("실적(폐품포함) 중량 {0:#,0.###} (Kg)값이\r\n가용 중량 {1:#,0.###} (Kg)을 초과하여 입력되었습니다.\r\n\r\n실적(폐품포함) 연수 입력을 확인하세요.", dTOT_WGT_CALC, dIN_AVA_WGT), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                //new POPUP.MessageForm(string.Format("실적(폐품포함) 중량 값이 가용 중량 {0} (Kg)을 초과하여\r\n입력되었습니다.\r\n\r\n실적(폐품포함) 연수 입력을 확인하세요.", dIN_AVA_WGT), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return false;
            }

            return true;
        }

        /// <summary>
        /// 수재단 실적등록
        /// </summary>
        private int doProduct()
        {
            DataTable dtList;

            // 작업지시 확인
            if (string.IsNullOrEmpty(lblIN_MAT_CD.Text.ToString()))
            {
                new POPUP.MessageForm("투입정보가 없습니다.\r\n작업지시 선택후 실적등록 하세요!", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return Common.ERROR_FAIL;
            }

            // 선택된 수재단 작업지시 확인
            int nSEL = 0;
            foreach (UltraGridRow ugr in Grid2.Rows)
            {
                if (ugr.Cells["CHK"].Value.ToString().Equals("V"))
                {
                    nSEL++;
                }
            }

            if (nSEL == 0)
            {
                new POPUP.MessageForm("실적 등록할 수재단 작업지시를 선택 하세요!", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return Common.ERROR_FAIL;
            }

            //  실적등록 치수 확인
            Decimal dPROD_REAM = Decimal.TryParse(lblPF_PLT_REAM.Text.Replace(",", ""), out dPROD_REAM) ? dPROD_REAM : 0;
            Decimal dPROD_EA = Decimal.TryParse(lblPF_PLT_EA.Text.Replace(",", ""), out dPROD_EA) ? dPROD_EA : 0;
            Decimal dDISPO_REAM = Decimal.TryParse(lblPF_DISPO_REAM.Text.Replace(",", ""), out dDISPO_REAM) ? dDISPO_REAM : 0;

            if (lblPF_CHK_DISPO.Text == "V")
            {
                if ((dPROD_REAM == 0 || dPROD_EA == 0) && (dDISPO_REAM == 0))
                {
                    new POPUP.MessageForm("실적연수 및 팔레트 또는 폐품연수를 입력 하세요!", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return Common.ERROR_FAIL;
                }
            }
            else
            {
                if (dPROD_REAM == 0 || dPROD_EA == 0)
                {
                    new POPUP.MessageForm("실적연수 및 팔레트를 입력 하세요!", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return Common.ERROR_FAIL;
                }
            }

            //// 계획연수 이상인지 확인
            //{
            //    Decimal dWRK_ORDR_QTY = 0;
            //    Decimal dTOTAL_QTY = 0;
            //    Decimal dPCNT = 0;
            //    Decimal dDISPO_QTY = 0;

            //    Decimal dPF_REAM = 0;
            //    Decimal dPF_DISPO_REAM = 0;

            //    Decimal.TryParse(Grid2.Row.Cells["WRK_ORDR_QTY"].Value.ToString(), out dWRK_ORDR_QTY);  // 계획연수
            //    Decimal.TryParse(Grid2.Row.Cells["PCNT"].Value.ToString(), out dPCNT);                  // 실적연수
            //    Decimal.TryParse(Grid2.Row.Cells["DISPO_QTY"].Value.ToString(), out dDISPO_QTY);        // 폐품연수

            //    Decimal.TryParse(lblPF_TOT_REAM.Text.ToString().Replace(",", ""), out dPF_REAM);           //
            //    Decimal.TryParse(lblPF_DISPO_REAM.Text.ToString().Replace(",", ""), out dPF_DISPO_REAM);   //

            //    dTOTAL_QTY = dPCNT + dDISPO_QTY + dPF_REAM + dPF_DISPO_REAM;

            //    if (dTOTAL_QTY > dWRK_ORDR_QTY)
            //    {
            //        new POPUP.MessageForm(string.Format("실적 연수가 계획연수를 초과 할수 없습니다.\r\n\r\n계획연수 : {0:#,##0.###}\r\n가용(폐품)연수 : {1:#,##0.###}\r\n실적(폐품)연수 : {2:#,##0.###}"
            //                                , dWRK_ORDR_QTY, dWRK_ORDR_QTY - (dPCNT + dDISPO_QTY), dPF_REAM + dPF_DISPO_REAM), MessageBoxButtons.OK, "알   림").ShowDialog(this);
            //        //new POPUP.MessageForm(string.Format("실적 연수가 계획연수를 초과 할수 없습니다.\r\n\r\n{0}\r\n{1}\r\n{2}"
            //        //                        , string.Format("계획연수 : {0:#,##0.###}", dWRK_ORDR_QTY).PadRight(50)
            //        //                        , string.Format("가용(폐품)연수 : {0:#,##0.###}", dWRK_ORDR_QTY - (dPCNT + dDISPO_QTY)).PadRight(50)
            //        //                        , string.Format("실적(폐품)연수 : {0:#,##0.###}", dPF_REAM + dPF_DISPO_REAM)).PadRight(50)
            //        //                        , MessageBoxButtons.OK, "알   림").ShowDialog(this);
            //        return false;
            //    }
            //}

            //입력량 체크 (실적량은 투입량을 Over하면 안됨)
            if (!CheckProdQty())
                return Common.ERROR_FAIL;

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

            // 예외생산은 폐품처리 안함.
            if (gsWODIV == "계획")
            {
                if (ValidationSalesDispo() == false)
                {
                    return Common.ERROR_FAIL;
                }
            }

            string sCBRCOM_YN = "N";    //수재단완료 여부

            POPUP.MessageForm msgForm;
            msgForm = new POPUP.MessageForm("수재단 완료 플래그를 체크 하시겠습니까?", MessageBoxButtons.YesNoCancel, "알  림");

            DialogResult dr = msgForm.ShowDialog(this);
            if (dr == DialogResult.Cancel)
            {
                return Common.ERROR_FAIL;
            }
            else if (dr == DialogResult.Yes)
            {
                sCBRCOM_YN = "Y";
            }

            string sCARCOM_YN = "N";      // 재단 완료처리 (투입정보)
            // 수재단 완료 처리 되고, 수재단 작업이 한개 남은경우는 재단 완료처리함(투입정보).
            if (sCBRCOM_YN.Equals("Y"))
            {
                int iRowcnt = 0;

                foreach (UltraGridRow ugr in Grid2.Rows)
                {
                    if (ugr.Cells["CHK"].Value.ToString().Equals("V"))
                        iRowcnt++;
                }

                // 수재단 작업지시를 모두 작업했을 경우 재단 'Y'
                if (Grid2.Rows.Count == iRowcnt)
                {
                    sCARCOM_YN = "Y";    //  재단 완료 처리(투입정보)
                }
            }

            // 0실적 체크용
            bool bZERO_PRFM = false;

            if (sCARCOM_YN == "Y")
            {
                Decimal dPF_TOT_WGT = 0;
                Decimal dPF_DISPO_WGT = 0;

                Decimal.TryParse(lblPF_TOT_WGT.Text.ToString().Replace(",", ""), out dPF_TOT_WGT);                       //
                Decimal.TryParse(lblPF_DISPO_WGT.Text.ToString().Replace(",", ""), out dPF_DISPO_WGT);               //

                if ((dPF_TOT_WGT == 0) && (dPF_DISPO_WGT > 0))
                {
                //    new POPUP.MessageForm(string.Format("폐품만 등록하여 작업 완료 처리 할수 없습니다.\r\n\r\n작업을 완료 하려면 실적을 추가 하세요."), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                //    return Common.ERROR_FAIL;
                    bZERO_PRFM = true;
                }

                Decimal dTOT_INREAM = 0;
                Decimal dTOT_INWGT = 0;
                foreach (DataRow drow in Grid1.DataSource.Rows)
                {
                    Decimal dINREAM = 0;
                    Decimal dINWGT = 0;

                    Decimal.TryParse(drow["IN_REAM"].ToString(), out dINREAM);
                    Decimal.TryParse(drow["WGT"].ToString(), out dINWGT);

                    dTOT_INREAM += dINREAM;
                    dTOT_INWGT += dINWGT;
                }


                Decimal dPF_REAM = 0;           // 실적연수
                Decimal dPF_DISPO_REAM = 0;     // 폐품연수

                Decimal.TryParse(lblPF_TOT_REAM.Text.ToString().Replace(",", ""), out dPF_REAM);           //
                Decimal.TryParse(lblPF_DISPO_REAM.Text.ToString().Replace(",", ""), out dPF_DISPO_REAM);   //


                DBHelper hp = new DBHelper();

                try
                {
                    hp.ExecuteNoneQuery("SP_POP_WRK29_S03", CommandType.StoredProcedure
                                                    , hp.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)              // 플랜트
                                                    , hp.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)          // 작업장코드(설비코드)
                                                    , hp.CreateParameter("P_WRK_ORDR_NO", Common.WrkOrderNo, DbType.String, ParameterDirection.Input)       // 작업지시
                                                    , hp.CreateParameter("P_WRK_ORDR_SEQNO", Common.WrkOrderSeq, DbType.String, ParameterDirection.Input)   // 작업지시순번
                                                    , hp.CreateParameter("P_IN_PCNT", string.Format("{0:###0.000}", dTOT_INREAM), DbType.String, ParameterDirection.Input)     // 투입연수 합
                                                    , hp.CreateParameter("P_IN_WGT", string.Format("{0:###0.000}", dTOT_INWGT), DbType.String, ParameterDirection.Input)       // 투입중량 합
                                                    , hp.CreateParameter("P_PCNT", string.Format("{0}", dPF_REAM + dPF_DISPO_REAM), DbType.String, ParameterDirection.Input)     // 실적 연수
                                                    , hp.CreateParameter("P_WGT", string.Format("{0}", dPF_TOT_WGT + dPF_DISPO_WGT), DbType.String, ParameterDirection.Input)  // 실적 중량
                                                    );


                    if (hp.RSCODE == "E")
                    {
                        string sMSG = string.Format("{0}\n완료 처리후에는 실적등록을 할수 없습니다.\n\n완료 처리를 진행 하시겠습니까?", hp.RSMSG);

                        //if (new POPUP.MessageForm("투입되지 않은 바코드가 존재합니다.\n그래도 완료 처리를 진행 하시겠습니까?", MessageBoxButtons.YesNo, "알  림").ShowDialog(this) == DialogResult.No)
                        if (new POPUP.MessageForm(sMSG, MessageBoxButtons.YesNo, "알  림").ShowDialog(this) == DialogResult.No)
                        {
                            return Common.ERROR_FAIL;
                        }
                    }
                }
                catch (Exception ex)
                {
                    this.Cursor = Cursors.Default;

                    //hp.Rollback();

                    LogFile.WriteLog("SP_POP_WRK29_I02.doProduct Error => " + ex.Message);
                    new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return Common.ERROR_FAIL;
                }
                finally
                {
                    this.Cursor = Cursors.Default;
                    hp.Close();
                }
            }


            string sProcedure = string.Empty;

            if (gsWODIV == "예외")
                sProcedure = "SP_POP_WRK29_I04";
            else
                sProcedure = "SP_POP_WRK29_I02";

            // Temp table에 저장정보(실적) 담기
            dtList = setReqWorkList(sCBRCOM_YN, sCARCOM_YN, sStartDate, sEndDate, sTM);

            DBHelper helper = new DBHelper(false, "", true);
            DataSet dsTemp = new DataSet();     //실적등록 결과 수신(0:실적 RFC ID, 1:실적 IF 변수, 2:실적 RFC ID, 3:실적 IF 변수)
            bool bReturn1 = false, bReturn2 = false, bReturn3 = false; //실적, 폐품, 투입
            bool bRetSALES_DISPO = false;   // 영업폐품+잔량폐품 처리 결과

            string sRES_IND_BCD = string.Empty;

            string sMSG_ERR = "";

            int RET_CODE = Common.ERROR_RFC_FAIL;

            try
            {
                this.Cursor = Cursors.WaitCursor;   //Waitting

                Decimal dPallet = 0;
                Decimal.TryParse(lblPF_PLT_EA.Text.Replace(",", ""), out dPallet);

                Decimal dReamNum = 0;
                Decimal.TryParse(lblPF_PLT_REAM.Text.ToString().Replace(",", ""), out dReamNum);

                int nPltCnt = 0;
                if (dReamNum > 0)
                    nPltCnt = (int)Math.Ceiling(dPallet);
                else
                    nPltCnt = 0;

                Decimal dDispoReamNum = 0;      //폐품연수
                Decimal.TryParse(lblPF_DISPO_REAM.Text.ToString().Replace(",", ""), out dDispoReamNum);
                if (dDispoReamNum > 0)
                {
                    nPltCnt++;
                }

                DataTable dtWrkOne = dtList.Clone();

                for (int i = 0; i < nPltCnt; i++)
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
                        dtWrkOne.Rows.Clear();

                        //dtWrkOne.ImportRow(dtList.Rows[i]);

                        DataRow[] drArry = dtList.Select(string.Format("PLT_NO = {0}", (i + 1).ToString()));

                        foreach (DataRow dr1 in drArry)
                        {
                            dtWrkOne.ImportRow(dr1);
                        }

                        // 실적순서 별로 테이블 SORT 하여 리턴
                        DataView dv = new DataView(dtWrkOne);
                        dv.Sort = "NO ASC";
                        dtWrkOne = dv.ToTable();

                        string sJsonWrkList = Common.toJsonFormat("POP_WRK029", dtWrkOne);

                        //실적저장
                        dsTemp = helper.FillDataSetN(sProcedure, CommandType.StoredProcedure, 8
                                    , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)                  // 플랜트
                                    , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)              // 작업장코드(설비코드)
                                    , helper.CreateParameter("P_WRK_ORDR_NO", Common.WrkOrderNo, DbType.String, ParameterDirection.Input)           // 작업장코드(설비코드)
                                    , helper.CreateParameter("P_WRK_ORDR_SEQNO", Common.WrkOrderSeq, DbType.Int32, ParameterDirection.Input)        // 작업장코드(설비코드)
                                    , helper.CreateParameterOracle("P_WRK_LIST", sJsonWrkList, OracleDbType.Clob, ParameterDirection.Input)         // 슬리터 실적등록 리스트
                                    , helper.CreateParameter("P_WRK_CLASS", Common.WorkClass, DbType.String, ParameterDirection.Input)              // 작업반
                                    , helper.CreateParameter("P_WRK_SHIFT", Common.WorkShift, DbType.String, ParameterDirection.Input)              // 작업조
                                    , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input)                    // 사용자ID
                                    , helper.CreateParameter("RS_PRFM_RFCFN", DbType.String, ParameterDirection.Output, null, 200)                  // 실적 RFCFN ID값
                                    , helper.CreateParameter("RS_DISPO_RFCFN", DbType.String, ParameterDirection.Output, null, 200)                 // 폐품 RFCFN ID값
                                    , helper.CreateParameter("RS_INPUT_RFCFN", DbType.String, ParameterDirection.Output, null, 200)                 // 투입량 RFCFN ID값
                                    , helper.CreateParameter("RS_SDISPO_RFCFN", DbType.String, ParameterDirection.Output, null, 200)                // 영업폐품 RFCFN ID값 (폐품과 합침)
                                    , helper.CreateParameter("RS_IND_BCD", DbType.String, ParameterDirection.Output, null, 2000)                    // RES 개별바코드 
                                );

                        if (helper.RSCODE == "S")
                        {
                            //sRES_IND_BCD += helper.Parameters["RS_IND_BCD"].Value.ToString() + "|";
                            bufferIND_BCD = helper.Parameters["RS_IND_BCD"].Value.ToString() + "|"; // 프린트 바코드 저장 위치 변경 2022-11-08


                            string sRS_PRFM_RFCFN = helper.Parameters["RS_PRFM_RFCFN"].Value.ToString();      // 실적 RFCFN ID
                            string sRS_DISPO_RFCFN = helper.Parameters["RS_DISPO_RFCFN"].Value.ToString();    // 폐품 RFCFN ID
                            string sRS_INPUT_RFCFN = helper.Parameters["RS_INPUT_RFCFN"].Value.ToString();    // 투입량 RFCFN ID
                            string sRS_SDISPO_RFCFN = helper.Parameters["RS_SDISPO_RFCFN"].Value.ToString();    // 영업폐품 RFCFN ID

                            //dsTemp.Tables[0];     // 실적 인터페이스 파라미터
                            //dsTemp.Tables[1];     // 실적 인터페이스 상세 파라미터
                            //dsTemp.Tables[2];     // 폐품 인터페이스 파라미터
                            //dsTemp.Tables[3];     // 폐품 인터페이스 상세 파라미터
                            //dsTemp.Tables[4];     // 투입량 인터페이스 파라미터
                            //dsTemp.Tables[5];     // 투입량 인터페이스 상세 파라미터
                            //dsTemp.Tables[6];     // 영업+잔량폐품 인터페이스 파라미터8
                            //dsTemp.Tables[7];     // 영업+잔량폐품 인터페이스 상세 파라미터
#if false
                            this.Cursor = Cursors.Default;   //Waitting

                            helper.Rollback();

                            return Common.ERROR_FAIL;
#endif                      //SAP 롤백용 추가 CODE 범위 START
                            if (dsTemp.Tables[1].Columns[0].ColumnName != "1")
                            {
                                //SAP 롤백용 추가 CODE 범위 START
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
                                //SAP 롤백용 추가 CODE 범위 START
                                foreach (DataRow Rows in dsTemp.Tables[3].Rows)
                                {
                                    string rollTempMDOC_NO_1 = Rows["MDOCNO"].ToString();
                                    string rollTempMDOC_SEQNO_1 = Rows["MDOCSEQ"].ToString();
                                    rollTemp.Rows.Add(rollTempMDOC_NO_1, rollTempMDOC_SEQNO_1);
                                }
                            }
                            //SAP 롤백용 추가 CODE 범위 END

                            string sRfcData; //RFC결과 JSON 변환
                            bReturn1 = false;

                            // 1. 실적 등록 (수재단 완료 플래그 때문에 마지막에 보냄)
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
                                    //RFC 전송 결과 조회
                                    string sType = sapRFC_P.rtnTable.Rows[0]["TYPE"].ToString();
                                    string sMessage = sapRFC_P.rtnTable.Rows[0]["MESSAGE"].ToString();

                                    if (sType == "S")
                                    {
                                        // ---- 전달시 MBLNR, MJAHR을 replace 처리하여 하나로 받도록함.
                                        sRfcData = Common.toJsonFormat("PUT_WRKRTN", sapRFC_P.rtnTable).Replace("MBLNR", "RUECK").Replace("MJAHR", "RMZHL");

                                        // ----- 생산실적량이 0이면 롤백 테이블에 저장 안함
                                        // 0실적이 아닌경우 문서번호 저장
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
                                            bReturn1 = true;
                                        }
                                        else if (helper.RSCODE == "E")
                                        {
                                            bReturn1 = false;
                                            //helper.Rollback();
                                            //new POPUP.MessageForm("실적 등록 오류\r\n" + helper.RSMSG, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                            sMSG_ERR += "확정문서 등록 오류 : " + helper.RSMSG.ToString() + Environment.NewLine;
                                            throw new Exception("SAP_ERROR" + sMSG_ERR);  // SAP 로직 진행중 E 발생시 EXCEPTION THROW
                                        }
                                    }
                                    else
                                    {
                                        bReturn1 = false;
                                        //helper.Rollback();
                                        //new POPUP.MessageForm("실적 등록 오류\r\n" + sMessage, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                        sMSG_ERR += "실적 등록 오류 : " + sapRFC_P.rtnMSG + Environment.NewLine;
                                        throw new Exception("SAP_ERROR" + sMSG_ERR);  // SAP 로직 진행중 E 발생시 EXCEPTION THROW
                                    }
                                }
                                else
                                {
                                    bReturn1 = false;
                                    //helper.Rollback();
                                    sMSG_ERR += "실적 등록 오류 : " + sapRFC_P.rtnMSG + Environment.NewLine;
                                    throw new Exception("SAP_ERROR" + sMSG_ERR);  // SAP 로직 진행중 E 발생시 EXCEPTION THROW
                                    //new POPUP.MessageForm("실적 등록 오류\r\n" + sapRFC_P.rtnMSG, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                }

                                Thread.Sleep(Common.SLEEP_DELAY);
                                System.Windows.Forms.Application.DoEvents();        // 반복작업중 응답없음 안뜨게 하기
                                this.Cursor = Cursors.WaitCursor;   //Waitting
                            }
                            else
                            {
                                bReturn1 = true;
                            }

                            // 2. 생산폐품 등록
                            if (/*(bReturn1 == true) &&*/ (string.IsNullOrEmpty(sRS_DISPO_RFCFN) == false))
                            {
                                bReturn2 = false;

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
                                                                            , helper.CreateParameter("P_WRK_TYPE", "1", DbType.String, ParameterDirection.Input)                  // '0'= 실적테이블_비계획생산, '1'= 폐품테이블, '2'=소요량, '3'=비가동
                                                                            , helper.CreateParameterOracle("P_RFC_DATA", sRfcData, OracleDbType.Clob, ParameterDirection.Input)
                                                                            , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input));

                                        if (helper.RSCODE == "S")
                                        {
                                            bReturn2 = true;
                                        }
                                        else if (helper.RSCODE == "E")
                                        {
                                            bReturn2 = false;
                                            //helper.Rollback();
                                            //new POPUP.MessageForm("실적 등록(폐품) 오류\r\n" + helper.RSMSG, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                            sMSG_ERR += "확정문서 등록(폐품) 오류 : " + helper.RSMSG.ToString() + Environment.NewLine;
                                            throw new Exception("SAP_ERROR" + sMSG_ERR);  // SAP 로직 진행중 E 발생시 EXCEPTION THROW
                                        }
                                    }
                                    else
                                    {
                                        bReturn2 = false;
                                        //helper.Rollback();
                                        //new POPUP.MessageForm("실적 등록(폐품) 오류\r\n" + sMessage, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                        sMSG_ERR += "실적 등록(폐품) 오류 : " + sapRFC_D.rtnMSG + Environment.NewLine;
                                        throw new Exception("SAP_ERROR" + sMSG_ERR);  // SAP 로직 진행중 E 발생시 EXCEPTION THROW
                                    }
                                }
                                else //SAP 에러
                                {
                                    bReturn2 = false;
                                    //helper.Rollback();
                                    //new POPUP.MessageForm("실적 등록(폐품) 오류\r\n" + sapRFC_D.rtnMSG, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                    sMSG_ERR += "실적 등록(폐품) 오류 : " + sapRFC_D.rtnMSG + Environment.NewLine;
                                    throw new Exception("SAP_ERROR" + sMSG_ERR);  // SAP 로직 진행중 E 발생시 EXCEPTION THROW
                                }

                                Thread.Sleep(Common.SLEEP_DELAY);
                                System.Windows.Forms.Application.DoEvents();        // 반복작업중 응답없음 안뜨게 하기
                                this.Cursor = Cursors.WaitCursor;   //Waitting
                            }
#if true
                            // 3. 영업+잔량 폐품 등록
                            if (/*(bReturn1 == true) &&*/ (string.IsNullOrEmpty(sRS_SDISPO_RFCFN) == false))
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
                                        else if (helper.RSCODE == "E")
                                        {
                                            bRetSALES_DISPO = false;
                                            //helper.Rollback();
                                            //new POPUP.MessageForm("실적 등록(영업+잔량 폐품) 오류\r\n" + helper.RSMSG, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                            sMSG_ERR += "확정문서 등록(영업+잔량 폐품) 오류 : " + helper.RSMSG.ToString() + Environment.NewLine;
                                            throw new Exception("SAP_ERROR" + sMSG_ERR);
                                        }
                                    }
                                    else
                                    {
                                        bRetSALES_DISPO = false;
                                        //helper.Rollback();
                                        //new POPUP.MessageForm("실적 등록(영업+잔량 폐품) 오류\r\n" + sMessage, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                        sMSG_ERR += "실적 등록(영업+잔량 폐품) 오류 : " + sapRFC_D.rtnMSG + Environment.NewLine;
                                        throw new Exception("SAP_ERROR" + sMSG_ERR);
                                    }
                                }
                                else
                                {
                                    bRetSALES_DISPO = false;
                                    //helper.Rollback();
                                    //new POPUP.MessageForm("실적 등록(영업+잔량 폐품) 오류\r\n" + sapRFC_D.rtnMSG, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                    sMSG_ERR += "실적 등록(영업+잔량 폐품) 오류 : " + sapRFC_D.rtnMSG + Environment.NewLine;
                                    throw new Exception("SAP_ERROR" + sMSG_ERR);

                                }

                                Thread.Sleep(Common.SLEEP_DELAY);
                                System.Windows.Forms.Application.DoEvents();        // 반복작업중 응답없음 안뜨게 하기
                                this.Cursor = Cursors.WaitCursor;   //Waitting
                            }
#endif
                            // 4. 투입량 등록
                            if (/*(bReturn1 == true) &&*/ (string.IsNullOrEmpty(sRS_INPUT_RFCFN) == false))
                            {
                                bReturn3 = false;

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
                                    //RFC 전송 결과 조회
                                    string sType = sapRFC_I.rtnTable.Rows[0]["TYPE"].ToString();
                                    string sMessage = sapRFC_I.rtnTable.Rows[0]["MESSAGE"].ToString();

                                    if (sType == "S")
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
                                            bReturn3 = true;
                                        }
                                        else if (helper.RSCODE == "E")
                                        {
                                            bReturn3 = false;
                                            //helper.Rollback();
                                            //new POPUP.MessageForm(helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                            sMSG_ERR += "확정문서 등록(투입량) 오류 : " + helper.RSMSG.ToString() + Environment.NewLine;
                                            throw new Exception("SAP_ERROR" + sMSG_ERR);
                                        }
                                    }
                                    else
                                    {
                                        bReturn3 = false;
                                        //helper.Rollback();
                                        //new POPUP.MessageForm("실적 등록(투입량) 오류\r\n" + sMessage, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                        sMSG_ERR += "실적 등록(투입량) 오류 : " + sapRFC_I.rtnMSG + Environment.NewLine;
                                        throw new Exception("SAP_ERROR" + sMSG_ERR);
                                    }
                                }
                                else
                                {
                                    bReturn3 = false;
                                    //helper.Rollback();
                                    //new POPUP.MessageForm("실적 등록(투입량) 오류\r\n" + sapRFC_I.rtnMSG, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                    sMSG_ERR += "실적 등록(투입량) 오류 : " + sapRFC_I.rtnMSG + Environment.NewLine;
                                    throw new Exception("SAP_ERROR" + sMSG_ERR);
                                }

                                Thread.Sleep(Common.SLEEP_DELAY);
                                System.Windows.Forms.Application.DoEvents();        // 반복작업중 응답없음 안뜨게 하기
                                this.Cursor = Cursors.WaitCursor;   //Waitting
                            }
                            sRES_IND_BCD += bufferIND_BCD; // 프린트 바코드 저장 위치 변경 2022-11-08
                        }
                        else //if (helper.RSCODE == "E")
                        {
                            this.Cursor = Cursors.Default;   //Waitting

                            //helper.Rollback();
                            new POPUP.MessageForm(helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                            this.DialogResult = DialogResult.OK;
                        }
                    }
                    catch (Exception ex)
                    {
                        sMSG_ERR = "";
                        if (rollTemp.Rows.Count != 0)
                        {
                            ProdRollback(helper, sapTemp, rollTemp, dsTemp, ref sMSG_ERR);
                        }

                        this.Cursor = Cursors.Default;

                        LogFile.WriteLog("실적등록 예외 오류\r\n" + ex.ToString() + Environment.NewLine + sMSG_ERR);
                        new POPUP.MessageForm_ERR("실적등록 오류", "실적등록 예외 오류\r\n" + ex.Message.ToString() + Environment.NewLine + sMSG_ERR, MessageBoxButtons.OK).ShowDialog(this);
                        break;
                    }
                }

                //if (bReturn1 == true)
                {
                    //helper.Commit();
                    if (lblPrintChk.Text.ToString() == "V")     // 자동인쇄 처리
                    {
                        sRES_IND_BCD = sRES_IND_BCD.TrimEnd('|');

                        string sLABEL_TYPE = (string)ucLABEL_TYPE.Items[ucLABEL_TYPE.SelectedIndex].DataValue;           //

                        int nPrtCnt = ucPNT_CNT.SelectedIndex + 1;

                        PrinterManager.PrintMCutter(sRES_IND_BCD, sLABEL_TYPE, nPrtCnt);
                            
                    }
                    this.Cursor = Cursors.Default;   //Waitting


                    if (sMSG_ERR.Length > 0)
                    {
                        //new POPUP.MessageForm(sMSG_ERR, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    }
                    else
                    {
                        LogFile.WriteLog("수재단 실적 등록 성공");
                        RET_CODE = Common.ERROR_SUCCESS;

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
                this.Cursor = Cursors.Default;

                //helper.Rollback();

                //if (bReturn1 == true)
                //{
                //    helper.Commit();
                //}
                //else
                //{
                //    helper.Rollback();
                //}

                //ProdRollback(helper, sapTemp, rollTemp, dsTemp, sMSG_ERR);

                LogFile.WriteLog("SP_POP_WRK29_I02.doProduct Error => " + ex.Message);
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
            }
            finally
            {
                this.Cursor = Cursors.Default;
                helper.Close();
            }

            return RET_CODE;
        }

        // ROLLBACK FUNCTION
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
                // 1.2 생산폐품 인터페이스
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
                // 1.3 영업+잔량 폐품 인터페이스
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
                            case "3.PROD_REG_SAP": // 생산실적 롤백
                                LogFile.WriteLog("=====3.PROD_REG_SAP=====" + Rows["MDOCNO"].ToString() + Rows["MDOCSEQ"].ToString(), LogType.PROC);
                                dsTemp = helper.FillDataSetN("SP_POP_WRK29_IFR01", CommandType.StoredProcedure, 2
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
                                        LogFile.WriteLog("수재단 실적등록 ROLLBACK COMPLETE", LogType.PROC);
                                        
                                    }
                                    else //if (helper.RSCODE == "E")
                                    {
                                        LogFile.WriteLog("수재단 ROLLBACK 등록 - SAP 확정문서 등록 오류 [" + helper.RSMSG.ToString() + "]");
                                        sMSG_ERR += "ROLLBACK 확정문서 등록 오류 : " + helper.RSMSG.ToString() + Environment.NewLine;
                                    }
                                    // DELAY 
                                    Thread.Sleep(Common.SLEEP_DELAY);
                                    System.Windows.Forms.Application.DoEvents();        // 반복작업중 응답없음 안뜨게 하기
                                }
                                else
                                {
                                    LogFile.WriteLog("수재단 ROLLBACK 오류 - SAP전송 오류 [" + sapRFC_1.rtnMSG + "]");
                                    sMSG_ERR += "수재단 ROLLBACK 오류 : " + sapRFC_1.rtnMSG + Environment.NewLine;
                                }
                                break;
                            // 2.2  생산폐품 ROLLBACK
                            case "2.SALV_REG_SAP": // 생산폐품 롤백
                                LogFile.WriteLog("=====2.SALV_REG_SAP=====" + Rows["MDOCNO"].ToString() + Rows["MDOCSEQ"].ToString(), LogType.PROC);
                                dsTemp = helper.FillDataSetN("SP_POP_WRK29_IFR02", CommandType.StoredProcedure, 2
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
                                    , helper.CreateParameter("P_WRK_TYPE", "1", DbType.String, ParameterDirection.Input)                        // '0'= 실적테이블, 비계획생산, '1'= 폐품테이블, '2'=소요량, '3'=비가동,
                                    , helper.CreateParameterOracle("P_RFC_DATA", rsRfcData, OracleDbType.Clob, ParameterDirection.Input)
                                    , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input));

                                    if (helper.RSCODE == "S")
                                    {
                                        LogFile.WriteLog("수재단 폐품등록 ROLLBACK COMPLETE", LogType.PROC);
                                        
                                    }
                                    else //if (helper.RSCODE == "E")
                                    {
                                        LogFile.WriteLog("수재단 ROLLBACK 등록 - SAP 확정문서 등록 오류 [" + helper.RSMSG.ToString() + "]");
                                        sMSG_ERR += "ROLLBACK 확정문서 등록 오류 : " + helper.RSMSG.ToString() + Environment.NewLine;
                                    }
                                    // DELAY 
                                    Thread.Sleep(Common.SLEEP_DELAY);
                                    System.Windows.Forms.Application.DoEvents();        // 반복작업중 응답없음 안뜨게 하기
                                }
                                else
                                {
                                    LogFile.WriteLog("수재단 ROLLBACK 오류 - SAP전송 오류 [" + sapRFC_2.rtnMSG + "]");
                                    sMSG_ERR += "수재단 ROLLBACK 오류 : " + sapRFC_2.rtnMSG + Environment.NewLine;
                                }
                                break;
                            // 2.1  잔량폐품 ROLLBACK
                            case "1.SALE_SALV_REG_SAP": // 잔량 롤백
                                LogFile.WriteLog("=====1.SALE_SALV_REG_SAP=====" + Rows["MDOCNO"].ToString() + Rows["MDOCSEQ"].ToString(), LogType.PROC);
                                dsTemp = helper.FillDataSetN("SP_POP_WRK29_IFR03", CommandType.StoredProcedure, 2
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
                                    , helper.CreateParameter("P_WRK_TYPE", "9", DbType.String, ParameterDirection.Input)                        // '0'= 실적테이블, 비계획생산, '1'= 폐품테이블, '2'=소요량, '3'=비가동,
                                    , helper.CreateParameterOracle("P_RFC_DATA", rsRfcData, OracleDbType.Clob, ParameterDirection.Input)
                                    , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input));

                                    if (helper.RSCODE == "S")
                                    {
                                        LogFile.WriteLog("수재단 영업폐품 ROLLBACK COMPLETE", LogType.PROC);
                                        
                                    }
                                    else //if (helper.RSCODE == "E")
                                    {
                                        LogFile.WriteLog("수재단 ROLLBACK 등록 - SAP 확정문서 등록 오류 [" + helper.RSMSG.ToString() + "]");
                                        sMSG_ERR += "ROLLBACK 확정문서 등록 오류 : " + helper.RSMSG.ToString() + Environment.NewLine;
                                    }
                                    // DELAY 
                                    Thread.Sleep(Common.SLEEP_DELAY);
                                    System.Windows.Forms.Application.DoEvents();        // 반복작업중 응답없음 안뜨게 하기
                                }
                                else
                                {
                                    LogFile.WriteLog("수재단 ROLLBACK 오류 - SAP전송 오류 [" + sapRFC_3.rtnMSG + "]");
                                    sMSG_ERR += "수재단 ROLLBACK 오류 : " + sapRFC_3.rtnMSG + Environment.NewLine;
                                }
                                break;
                            // 2.4 투입량 ROLLBACK
                            case "4.WIP_REG_SAP":     // 투입량 롤백

                                if (gsWODIV == "예외")
                                {
                                    rProcedure = "SP_POP_WRK29_IFR04_EX";
                                }
                                else
                                {
                                    rProcedure = "SP_POP_WRK29_IFR04";
                                }
                                LogFile.WriteLog("=====4.WIP_REG_SAP=====" + Rows["MDOCNO"].ToString() + Rows["MDOCSEQ"].ToString(), LogType.PROC);
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
                                        LogFile.WriteLog("수재단 투입량 ROLLBACK COMPLETE", LogType.PROC);
                                        
                                    }
                                    else //if (helper.RSCODE == "E")
                                    {
                                        LogFile.WriteLog("수재단 ROLLBACK 등록 - SAP 확정문서 등록 오류 [" + helper.RSMSG.ToString() + "]");
                                        sMSG_ERR += "ROLLBACK 확정문서 등록 오류 : " + helper.RSMSG.ToString() + Environment.NewLine;
                                    }
                                }
                                else
                                {
                                    LogFile.WriteLog("수재단 ROLLBACK 오류 - SAP전송 오류 [" + sapRFC_4.rtnMSG + "]");
                                    sMSG_ERR += "수재단 ROLLBACK 오류 : " + sapRFC_4.rtnMSG + Environment.NewLine;
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
                    string mProcedure = string.Empty;

                    if (gsWODIV == "예외")
                    {
                        mProcedure = "SP_POP_WRK29_R01_EX";
                    }
                    else
                    {
                        mProcedure = "SP_POP_WRK29_R01";
                    }

                    helper.Commit();

                    if (rollTemp.Rows.Count != 0)
                    {

                        foreach (DataRow Rows in rollTemp.Rows)
                        {
                            LogFile.WriteLog("=====MES ROLLBACK START=====" + Rows["MDOCNO"].ToString() + Rows["MDOCSEQ"].ToString(), LogType.PROC);
                            helper.ExecuteNoneQuery(mProcedure, CommandType.StoredProcedure
                           , helper.CreateParameter("P_DOC_NO", Rows["MDOCNO"].ToString(), DbType.String, ParameterDirection.Input)
                           , helper.CreateParameter("P_DOC_SEQNO", Rows["MDOCSEQ"].ToString(), DbType.String, ParameterDirection.Input)
                           , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input));
                            LogFile.WriteLog("=====MES ROLLBACK END=====" + Rows["MDOCNO"].ToString() + Rows["MDOCSEQ"].ToString(), LogType.PROC);
                        }
                    }
                    sMSG_ERR += "수재단 MES ROLLBACK 실적이 취소되었습니다" + Environment.NewLine;
                    LogFile.WriteLog("수재단 MES ROLLBACK COMPLETE", LogType.PROC);
                }
                catch (Exception ex1)
                {
                    LogFile.WriteLog("수재단 MES ROLLBACK 오류 [" + ex1.Message.ToString() + "]");
                    sMSG_ERR += "수재단 MES ROLLBACK 오류 : " + ex1.Message.ToString() + Environment.NewLine;
                }
            }
        }





        private DataTable GetPalletIndBCD(Decimal dPallet, Decimal dReamNum, Decimal dDispoReamNum)
        {
            DataTable sdt = new DataTable();
            DataTable dt = (DataTable)Grid1.DataSource;

            int iPalletCnt = 0;

            if (dReamNum > 0)
                iPalletCnt = (int)Math.Ceiling(dPallet);
            else
                iPalletCnt = 0;

            Decimal dPartReam = ((dPallet - (iPalletCnt - 1)) * dReamNum);        // 부분실적 (소수점 처리된 실적)

            string sSTAT_DISPO = "0";   // "0":정상실적
            if (dDispoReamNum > 0)
            {
                ++iPalletCnt;
                sSTAT_DISPO = "9";      // "9":폐품실적
            }

            // 팔레트 갯수 만큼 한 팔레트당 연수를 배열로 저장
            Decimal[] dProdReam = new Decimal[iPalletCnt];
            for (int i = 0; i < iPalletCnt; i++)
            {
                dProdReam[i] = dReamNum;

                if (i == 0 && sSTAT_DISPO == "9")
                {
                    dProdReam[i] = dDispoReamNum;   // 폐품이 있으면 첫번째 팔레트는 페품연수 입력
                }
                else if (i == (iPalletCnt - 1))
                {
                    // 부분 실적이 있으면, 마지막 배열값은 부분 팔레트 연수로 저장
                    ////if (iPalletCnt > 0)
                    //{
                    //    dProdReam[i] = ((dPallet - i) * dReamNum);
                    //}
                    dProdReam[i] = dPartReam;
                }
            }

            try
            {
                sdt.Columns.Add("NO", typeof(int));           //'1' 은 실적, '2'은 부분실적
                sdt.Columns.Add("STAT", typeof(string));      // 1이면 폐품 0은 정상실적
                sdt.Columns.Add("PLT_NO", typeof(string));    // 팔레트수량
                sdt.Columns.Add("IND_BCD", typeof(string));   // 개별바코드
                sdt.Columns.Add("USE_REAM", typeof(string));  // 실적연수

                Decimal dInReam = 0;     //투입연수
                Decimal dADUSEReam = 0;  //사용실적연수
                Decimal dDISPReam = 0;   //폐품실적연수
                Decimal dABLEReam = 0;   //가용연수

                Decimal dUseReam = 0;    //사용연수
                Decimal dProdRe = 0;     //적재잔여연수
                Decimal dInRe = 0;       //투입잔여연수

                string sIND_BCD = "";
                int nNo = 0;
                int iLoop = 0;
                int iPalletno = 1;

                foreach (DataRow dr in dt.Rows)
                {
                    // 10월이전 생산 분에 대하여 처리시, CHK 칼럼만 선택 하여 처리.
                    if (dr["CHK"].ToString() != "V")
                        continue;

                    Decimal.TryParse(dr["IN_REAM"].ToString(), out dInReam);      //투입연수
                    Decimal.TryParse(dr["USE_QTY"].ToString(), out dADUSEReam);   //기 사용연수
                    Decimal.TryParse(dr["DISPO_QTY"].ToString(), out dDISPReam);  //기 폐품연수

                    // 투입연수는 투입자재의 연수 => 실적가능한 연수로 변경해서 사용
                    if (gdCntReam > 0)
                        dInReam = dInReam * gdCntReam;

                    //가용연수
                    dABLEReam = dInReam - (dADUSEReam + dDISPReam);

                    if (dABLEReam <= 0)
                        continue;

                    //개별바코드
                    sIND_BCD = dr["IND_BCD"].ToString();

                    // 추가 Pallet 수가 적재하기로 한 수 보다 크면 적재를 끝낸다.
                    if (iPalletCnt < iPalletno)
                        break;

                    if (dProdReam[iPalletno - 1] <= dABLEReam)  // 가용연수가 적재연수 이상일 경우
                    {
                        if (dProdRe > 0)    // 적재 잔여가 있을 경우 계속 적재한다.
                        {
                            DataRow drBCD = sdt.NewRow();
                            nNo++;
                            drBCD["NO"] = nNo;
                            drBCD["STAT"] = (iPalletno == 1 ? sSTAT_DISPO : "0");        // "9"=폐품, "0"=정상 
                            drBCD["PLT_NO"] = iPalletno.ToString();
                            drBCD["IND_BCD"] = sIND_BCD;
                            drBCD["USE_REAM"] = string.Format("{0:###0.###}", dProdRe);
                            sdt.Rows.Add(drBCD);

                            iPalletno++;

                            dABLEReam = dABLEReam - dProdRe;  // 투입연수 재 계산
                            dProdRe = 0;                      // 적재 잔여연수 초기화

                            // 추가 Pallet 수가 적재하기로 한 수 보다 크면 적재를 끝낸다.
                            if (iPalletCnt < iPalletno)
                                break;
                        }

                        // 투입연수로 몇 Palleting가능한 지 계산
                        iLoop = (int)(dABLEReam / dProdReam[iPalletno - 1]);

                        if (iLoop > 0)  // 투입연수로 Palleting 가능한 만큼 적재한다.
                        {
                            dInRe = dABLEReam - (dProdReam[iPalletno - 1] * iLoop);   // 투입연수 잔여량 계산
                            dProdRe = 0;
                            for (int j = 0; j < iLoop; j++)
                            {
                                dUseReam = dProdReam[iPalletno - 1];                    // 적재연수

                                DataRow drBCD = sdt.NewRow();
                                nNo++;
                                drBCD["NO"] = nNo;
                                drBCD["STAT"] = (iPalletno == 1 ? sSTAT_DISPO : "0");        // "9"=폐품, "0"=정상 
                                drBCD["PLT_NO"] = iPalletno.ToString();
                                drBCD["IND_BCD"] = sIND_BCD;
                                drBCD["USE_REAM"] = string.Format("{0:###0.###}", dUseReam);
                                sdt.Rows.Add(drBCD);

                                iPalletno++;

                                // 추가 Pallet 수가 적재하기로 한 수 보다 크면 적재를 끝낸다.
                                if (iPalletCnt < iPalletno)
                                {
                                    break;
                                }
                            }
                        }
                        else   // 투입연수로 Palleting계산시 0일 경우 (발생 : 잔여적재가 남은 상태에서 투입할 경우 발생)
                        {
                            dInRe = 0;                                       // 투입 잔여 초기화
                            dProdRe = dProdReam[iPalletno - 1] - dABLEReam;  // 적재 잔여 계산
                            dUseReam = dABLEReam;                            // 적재 연수

                            DataRow drBCD = sdt.NewRow();
                            nNo++;
                            drBCD["NO"] = nNo;
                            drBCD["STAT"] = (iPalletno == 1 ? sSTAT_DISPO : "0");   // "9"=폐품, "0"=정상 
                            drBCD["PLT_NO"] = iPalletno.ToString();
                            drBCD["IND_BCD"] = sIND_BCD;
                            drBCD["USE_REAM"] = string.Format("{0:###0.###}", dUseReam);
                            sdt.Rows.Add(drBCD);

                        }

                        // 추가 Pallet 수가 적재하기로 한 수 보다 크면 적재를 끝낸다.
                        if (iPalletCnt < iPalletno)
                            break;

                        if (dInRe > 0)      // 투입잔여가 있을 경우 계속 적재한다.
                        {
                            DataRow drBCD = sdt.NewRow();
                            nNo++;
                            drBCD["NO"] = nNo;
                            drBCD["STAT"] = (iPalletno == 1 ? sSTAT_DISPO : "0");   // "9"=폐품, "0"=정상 
                            drBCD["PLT_NO"] = iPalletno.ToString();
                            drBCD["IND_BCD"] = sIND_BCD;
                            drBCD["USE_REAM"] = string.Format("{0:###0.###}", dInRe);
                            sdt.Rows.Add(drBCD);

                            dProdRe = dProdReam[iPalletno - 1] - dInRe;  // 적재 잔여 계산
                            dInRe = 0;                                   // 투입 잔여 초기화
                        }
                    }
                    else    // 투입연수가 적재연수 보다 작을 경우
                    {
                        // 추가 Pallet 수가 적재하기로 한 수 보다 크면 적재를 끝낸다.
                        if (iPalletCnt < iPalletno)
                            break;

                        if (dProdRe > 0)    // 적재 잔여가 있을 경우
                        {
                            if (dProdRe > dABLEReam)  // 적재잔여가 투입연수 보다 클 경우
                            {
                                DataRow drBCD = sdt.NewRow();
                                nNo++;
                                drBCD["NO"] = nNo;
                                drBCD["STAT"] = (iPalletno == 1 ? sSTAT_DISPO : "0");   // "9"=폐품, "0"=정상 
                                drBCD["PLT_NO"] = iPalletno.ToString();
                                drBCD["IND_BCD"] = sIND_BCD;
                                drBCD["USE_REAM"] = string.Format("{0:###0.###}", dABLEReam);
                                sdt.Rows.Add(drBCD);

                                dProdRe = dProdRe - dABLEReam;    // 적재 잔여 계산
                            }
                            else    // 적재잔여가 투입연수 이하 일 경우
                            {
                                DataRow drBCD = sdt.NewRow();
                                nNo++;
                                drBCD["NO"] = nNo;
                                drBCD["STAT"] = (iPalletno == 1 ? sSTAT_DISPO : "0");    // "9"=폐품, "0"=정상 
                                drBCD["PLT_NO"] = iPalletno.ToString();
                                drBCD["IND_BCD"] = sIND_BCD;
                                drBCD["USE_REAM"] = string.Format("{0:###0.###}", dProdRe);
                                sdt.Rows.Add(drBCD);

                                iPalletno++;

                                // 추가 Pallet 수가 적재하기로 한 수 보다 크면 적재를 끝낸다.
                                if (iPalletCnt < iPalletno)
                                    break;

                                dInRe = dABLEReam - dProdRe;  // 투입잔여계산
                                dProdRe = 0;                  // 적재잔여 초기화

                                if (dInRe > 0)  // 투입잔여가 있을 경우 계속 적재한다.
                                {
                                    drBCD = sdt.NewRow();
                                    nNo++;
                                    drBCD["NO"] = nNo;
                                    drBCD["STAT"] = (iPalletno == 1 ? sSTAT_DISPO : "0");  // "9"=폐품, "0"=정상 
                                    drBCD["PLT_NO"] = iPalletno.ToString();
                                    drBCD["IND_BCD"] = sIND_BCD;
                                    drBCD["USE_REAM"] = string.Format("{0:###0.###}", dInRe);
                                    sdt.Rows.Add(drBCD);

                                    dProdRe = dProdReam[iPalletno - 1] - dInRe;   // 적재 잔여 계산
                                    dInRe = 0;                                    // 투입 잔여 초기화
                                }
                            }
                        }
                        else
                        {
                            DataRow drBCD = sdt.NewRow();
                            nNo++;
                            drBCD["NO"] = nNo;
                            drBCD["STAT"] = (iPalletno == 1 ? sSTAT_DISPO : "0");    // "9"=폐품, "0"=정상 
                            drBCD["PLT_NO"] = iPalletno.ToString();
                            drBCD["IND_BCD"] = sIND_BCD;
                            drBCD["USE_REAM"] = string.Format("{0:###0.###}", dABLEReam);
                            sdt.Rows.Add(drBCD);

                            dProdRe = dProdReam[iPalletno - 1] - dABLEReam;   // 적재잔여 계산
                        }
                    }
                }

                // 실적순서 별로 테이블 SORT 하여 리턴
                DataView dv = new DataView(sdt);
                dv.Sort = "NO ASC";
                sdt = dv.ToTable();
            }
            catch (Exception ex)
            {
                new POPUP.MessageForm("팔레트별 연수 계산 오류 : \r\n" + ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);

                return null;
            }

            return sdt;
        }

        private DataTable setReqWorkList(string sCBRCOM_YN, string sCARCOM_YN, string sStartDate, string sEndDate, string sTM)
        {
            DataTable dtRtn = new DataTable();
            DataRow dtTempRow;
            DataTable dt = (DataTable)Grid2.DataSource;

            int iWLEN = 0;
            int iVLEN = 0;

            int.TryParse(Grid2.Row.Cells["WLEN"].Value.ToString().ToString().Replace(",", ""), out iWLEN);  // 가로길이
            int.TryParse(Grid2.Row.Cells["VLEN"].Value.ToString().Replace(",", ""), out iVLEN);             // 세로길이

            try
            {
                //테이블 컬럼명 작성
                dtRtn.Columns.Add(new DataColumn("NO", typeof(int)));                //순서
                dtRtn.Columns.Add("PLT_NO", typeof(string));                        // 팔레트NO

                dtRtn.Columns.Add(new DataColumn("PRD_STR_DATE", typeof(string)));      //작업시작일시
                dtRtn.Columns.Add(new DataColumn("PRD_END_DATE", typeof(string)));      //작업종료일시
                dtRtn.Columns.Add(new DataColumn("PRFM_QTY", typeof(string)));          //실적수량(연수)
                dtRtn.Columns.Add(new DataColumn("PRFM_PLT", typeof(string)));          //팔레트수량
                dtRtn.Columns.Add(new DataColumn("WGT", typeof(string)));               //실적중량
                dtRtn.Columns.Add(new DataColumn("TM", typeof(string)));                //가동시간(분)
                dtRtn.Columns.Add(new DataColumn("WLEN", typeof(string)));              //가로길이
                dtRtn.Columns.Add(new DataColumn("VLEN", typeof(string)));              //세로길이
                dtRtn.Columns.Add(new DataColumn("BS_WGT", typeof(string)));            //평량
                dtRtn.Columns.Add(new DataColumn("DISPO_QTY", typeof(string)));         //폐품연수
                dtRtn.Columns.Add(new DataColumn("DISPO_WGT", typeof(string)));         //폐품중량
                dtRtn.Columns.Add(new DataColumn("DISPO_CD", typeof(string)));          //폐품코드
                dtRtn.Columns.Add(new DataColumn("DISPO_NM", typeof(string)));          //폐품명
                dtRtn.Columns.Add(new DataColumn("RMK", typeof(string)));               //비고
                dtRtn.Columns.Add(new DataColumn("CACOM_YN", typeof(string)));          //재단완료여부
                dtRtn.Columns.Add(new DataColumn("SCACOM_YN", typeof(string)));         //수재단완료여부
                dtRtn.Columns.Add(new DataColumn("IND_BCD_M", typeof(string)));         //재단 개별바코드
                dtRtn.Columns.Add(new DataColumn("MATRN_M", typeof(string)));           //재단 자재코드
                dtRtn.Columns.Add(new DataColumn("LOT_NO_M", typeof(string)));          //재단 LOT_NO
                dtRtn.Columns.Add(new DataColumn("WRK_ORDR_NO_M", typeof(string)));     //재단 작업지시번호
                dtRtn.Columns.Add(new DataColumn("WRK_ORDR_SEQNO_M", typeof(string)));  //재단 작업지시순번
                dtRtn.Columns.Add(new DataColumn("WRK_ORDR_NO", typeof(string)));       //수재단 작업지시번호
                dtRtn.Columns.Add(new DataColumn("WRK_ORDR_SEQNO", typeof(string)));    //수재단 작업지시순번
                dtRtn.Columns.Add(new DataColumn("PRFM_PLT_GU", typeof(string)));       //팔레트 변경 시 '1', 동일 팔레트 인경우'0'
                dtRtn.Columns.Add(new DataColumn("INUSE_REAM", typeof(string)));        //자재삭감을 위한 실적연수

                string sValue;
                Decimal dPallet = 0, dReamNum = 0, dINUSE_REAM = 0;

                Decimal.TryParse(lblPF_PLT_EA.Text.Replace(",", ""), out dPallet);
                Decimal.TryParse(lblPF_PLT_REAM.Text.ToString().Replace(",", ""), out dReamNum);

                int iPallet = 0;

                if (dReamNum > 0)
                {
                    iPallet = (int)Math.Ceiling(dPallet);
                }
                else
                {
                    iPallet = 0;
                }

                Decimal dDispoReamNum = 0;      //폐품연수
                Decimal.TryParse(lblPF_DISPO_REAM.Text.ToString().Replace(",", ""), out dDispoReamNum);

                if (dDispoReamNum > 0)
                {
                    iPallet++;
                }

                //팔렛트 갯수만큼 자료 생성
                DataTable dtIND_BCD = GetPalletIndBCD(dPallet, dReamNum, dDispoReamNum);

                DataTable dtWrkOne = dtIND_BCD.Clone();
                int no = 0;
                for (int i = 0; i < iPallet; i++)
                {
                    // 실적연수에 필요한 개별 바코드, 연수 구하기
                    dtWrkOne.Rows.Clear();

                    DataRow[] drArry = dtIND_BCD.Select(string.Format("PLT_NO = {0}", (i + 1).ToString()));
                    foreach (DataRow dr in drArry)
                    {
                        dtWrkOne.ImportRow(dr);
                    }

                    for (int nplt = 0; nplt < dtWrkOne.Rows.Count; nplt++)
                    {
                        //조회결과 입력용 Row생성
                        dtTempRow = dtRtn.NewRow();

                        dtTempRow["NO"] = (++no).ToString();         //순서
                        dtTempRow["PLT_NO"] = dtWrkOne.Rows[nplt]["PLT_NO"].ToString();                //PLT_NO
                        dtTempRow["PRD_STR_DATE"] = sStartDate;                                     //작업시작일시
                        dtTempRow["PRD_END_DATE"] = sEndDate;                                       //작업종료일시
                        dtTempRow["TM"] = sTM;                                                      //가동시간(분)
                        dtTempRow["WLEN"] = string.Format("{0}", (int)iWLEN);                       //가로길이
                        dtTempRow["VLEN"] = string.Format("{0}", (int)iVLEN);                       //세로길이
                        dtTempRow["BS_WGT"] = lblIN_BS_WGT.Text.Replace(",", "");                   //평량
                        dtTempRow["RMK"] = lblPF_WRK_ORDR_RMK.Text;                                 //비고
                        dtTempRow["IND_BCD_M"] = dtWrkOne.Rows[nplt]["IND_BCD"].ToString();         //재단 개별바코드
                        dtTempRow["MATRN_M"] = Grid1.Row.Cells["MATNR"].Value.ToString();           //재단 자재코드
                        dtTempRow["LOT_NO_M"] = Grid1.Row.Cells["LOT_NO"].Value.ToString();         //재단 LOT 번호
                        dtTempRow["WRK_ORDR_NO_M"] = Common.WrkOrderNo;                             //재단 작업지시번호
                        dtTempRow["WRK_ORDR_SEQNO_M"] = Common.WrkOrderSeq;                         //재단 작업지시순번
                        dtTempRow["WRK_ORDR_NO"] = dt.Rows[0]["WRK_ORDR_NO"].ToString();            //수재단 작업지시번호
                        sValue = dt.Rows[0]["WRK_ORDR_SEQNO"].ToString().Trim();
                        dtTempRow["WRK_ORDR_SEQNO"] = string.IsNullOrEmpty(sValue) ? "0" : sValue;  //수재단 작업지시번호순번

                        dtTempRow["PRFM_PLT"] = "1";   //lblPF_PLT_EA.Text.ToString().Replace(",", "");      //팔레트 개수

                        if (nplt == 0)
                            dtTempRow["PRFM_PLT_GU"] = "1";   //lblPF_PLT_EA.Text.ToString().Replace(",", "");      //팔레트 시작구분
                        else
                            dtTempRow["PRFM_PLT_GU"] = "0";   //lblPF_PLT_EA.Text.ToString().Replace(",", "");      //팔레트 시작구분

                        //Decimal.TryParse(lblPF_PLT_REAM.Text.ToString().Replace(",", ""), out dReamNum);

                        // dtWrkOne.Rows[nplt]["USE_REAM"].ToString();
                        Decimal.TryParse(dtWrkOne.Rows[nplt]["USE_REAM"].ToString().Replace(",", ""), out dReamNum);
                        // 투입자재 삭감을 위한 연수 ( 투입 기준으로 삭감 처리 )
                        dINUSE_REAM = dReamNum / gdCntReam;

                        if (dtWrkOne.Rows[nplt]["STAT"].ToString().Equals("9"))
                        {
                            dtTempRow["PRFM_QTY"] = "0";             //팔레트 연수
                            dtTempRow["WGT"] = "0";  //lblPF_TOT_WGT.Text.ToString().Replace(",", "");
                            if (i == (iPallet - 1)) // 폐품인경우도 마지막 팔레트 완료여부 전송
                            {
                                // 마지막 팔렛트에 입력
                                dtTempRow["CACOM_YN"] = sCARCOM_YN;                      //재단완료여부 (투입)
                                dtTempRow["SCACOM_YN"] = sCBRCOM_YN;                     //수재단완료여부
                            }
                            else
                            {
                                dtTempRow["CACOM_YN"] = "N";                              //재단완료여부 (투입)
                                dtTempRow["SCACOM_YN"] = "N";                             //수재단완료여부
                            }

                            dtTempRow["DISPO_QTY"] = dReamNum.ToString();                       //폐품연수
                            dtTempRow["DISPO_WGT"] = ReamToWgt("2", dReamNum).ToString();       //폐품중량
                            dtTempRow["DISPO_CD"] = lblPF_DISPO_CODE.Tag;                       //폐품코드
                            dtTempRow["DISPO_NM"] = lblPF_DISPO_CODE.Text.ToString();           //폐품명
                        }
                        else
                        {
                            // 팔렛트 당 계산
                            if (i == (iPallet - 1)) // 마지막 팔레트
                            {
                                //dtTempRow["PRFM_QTY"] = ((dPallet - i) * dReamNum).ToString();  //팔레트 연수
                                //dtTempRow["WGT"] = ReamToWgt("2", (dPallet - i) * dReamNum).ToString();  //lblPF_TOT_WGT.Text.ToString().Replace(",", "");
                                dtTempRow["PRFM_QTY"] = dReamNum.ToString();             //팔레트 연수
                                dtTempRow["WGT"] = ReamToWgt("2", dReamNum).ToString();  //lblPF_TOT_WGT.Text.ToString().Replace(",", "");

                                // 마지막 팔렛트에 입력
                                dtTempRow["CACOM_YN"] = sCARCOM_YN;                      //재단완료여부 (투입)
                                dtTempRow["SCACOM_YN"] = sCBRCOM_YN;                     //수재단완료여부
                            }
                            else
                            {
                                dtTempRow["PRFM_QTY"] = dReamNum.ToString();             //팔레트 연수
                                dtTempRow["WGT"] = ReamToWgt("2", dReamNum).ToString();  //lblPF_TOT_WGT.Text.ToString().Replace(",", "");

                                dtTempRow["CACOM_YN"] = "N";                              //재단완료여부 (투입)
                                dtTempRow["SCACOM_YN"] = "N";                             //수재단완료여부
                            }

                            dtTempRow["DISPO_QTY"] = string.Empty;                  //폐품연수
                            dtTempRow["DISPO_WGT"] = string.Empty;                  //폐품중량
                            dtTempRow["DISPO_CD"] = string.Empty;                   //폐품코드
                            dtTempRow["DISPO_NM"] = string.Empty;                   //폐품명
                        }

                        dtTempRow["INUSE_REAM"] = dINUSE_REAM.ToString();

                        //결과 테이블에 저장
                        dtRtn.Rows.Add(dtTempRow);
                    }
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

        #endregion

        #region FUNCTION
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

                //생산시작일자 및 시간
                string sStartDate = dtpStartDate.Value.ToString("yyyy-MM-dd") + " " + lblStartTime.Text.ToString() + ":00";
                if (Common.IsDateTime(sStartDate) == false)
                {
                    lblPF_PRFM_DT.Text = "";                   // 생산실적일자
                    return;
                }

                //생산완료일자 및 시간
                string sEndDate = dtpEndDate.Value.ToString("yyyy-MM-dd") + " " + lblEndTime.Text.ToString() + ":00";
                if (Common.IsDateTime(sEndDate) == false)
                {
                    lblPF_PRFM_DT.Text = "";                   // 생산실적일자
                    return;
                }

                // 가동시간 확인
                dtStartDate = Convert.ToDateTime(sStartDate);
                dtEndDate = Convert.ToDateTime(sEndDate);

                TimeSpan Diff_dates = dtEndDate.Subtract(dtStartDate);

                // 가동시간
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
                            //Console.WriteLine("{0} is not in the correct format.", sDate);
                            SetMessage(sDate + " 날짜형식을 바르게 입력하세요(년월일).");
                            lblPF_PRFM_DT.Text = "";
                        }
                    }
                }
                else
                {
                    lblPF_PRFM_DT.Text = "";  // 생산실적일자
                }
            }
            catch (Exception ex)
            {
                LogFile.WriteLog("수재단 AutoCalculation Error => " + ex.Message);
            }
        }

        private void CalculationWeigh()
        {
            //실적중량계산
            WgtCalculation();

            //폐품중량계산
            if (lblPF_DISPO_REAM.Enabled)
                DispoWgtCalculation();
        }

        // 실적 중량 계산
        private void WgtCalculation()
        {
            Decimal dPLT_REAM = 0;     // 팔레트 연수
            Decimal dPLT_EA = 0;       // 팔레트 개수

            // 팔레트연수
            Decimal.TryParse(lblPF_PLT_REAM.Text.ToString().Replace(",", ""), out dPLT_REAM);
            // 팔레트 EA
            Decimal.TryParse(lblPF_PLT_EA.Text.ToString().Replace(",", ""), out dPLT_EA);

            if (gsgrid2CHK == "N")
            {
                dPLT_REAM = 0;
                dPLT_EA = 0;
            }

            Decimal dTOT_REAM = dPLT_REAM * dPLT_EA;
            Decimal dValue = ReamToWgt("2", dTOT_REAM);

            if (dPLT_REAM == 0 || dPLT_EA == 0 || dValue == 0)
            {
                lblPF_TOT_REAM.Text = string.Empty;
                lblPF_TOT_WGT.Text = string.Empty;
            }
            else
            {
                lblPF_TOT_REAM.Text = string.Format("{0:#,0.###}", dTOT_REAM);
                lblPF_TOT_WGT.Text = string.Format("{0:#,0.###}", dValue);
            }
        }

        // 폐품 중량 계산
        private void DispoWgtCalculation()
        {
            Decimal dDISPO_REAM = 0;

            // 폐품 연수
            Decimal.TryParse(lblPF_DISPO_REAM.Text.ToString().Replace(",", ""), out dDISPO_REAM);

            if (gsgrid2CHK == "N")
                dDISPO_REAM = 0;

            Decimal dValue = ReamToWgt("2", dDISPO_REAM);

            if (dValue == 0)
                lblPF_DISPO_WGT.Text = string.Empty;
            else
                lblPF_DISPO_WGT.Text = string.Format("{0:#,0.###}", dValue);
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
            if (pType.Contains("O") && string.IsNullOrEmpty(lblIN_MAT_CD.Text.ToString()))
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

            if (gsWODIV == "예외")
            {
                //예외생산은 폐품 등록 못함
                if (pType.Contains("X"))
                {
                    new POPUP.MessageForm("예외생산입니다.\r\n폐품등록은 할 수 없습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return false;
                }
            }

            return true;
        }

        private void CheckValue(SmartDas.Components.MESLabel mLavel, string sVlaue)
        {
            mLavel.Text = sVlaue;

            if (string.IsNullOrEmpty(mLavel.Text.Trim()))
                mLavel.BackColor = Color.White;
            else
                mLavel.BackColor = Color.Yellow;
        }

        /// <summary>
        /// 연수로 중량계산
        /// </summary>
        private Decimal ReamToWgt(string gubun, Decimal dvalue)
        {
            if (dvalue == 0) return 0;
            if (Grid2.Rows.Count < 1) return 0;

            Decimal rtnWgt = 0;
            Decimal dBSWGT = 0;     // 평량
            Decimal dWLENWGT = 0;   // 폭
            Decimal dVLENWGT = 0;   // 길이

            Decimal.TryParse(lblIN_BS_WGT.Text.Replace(",", ""), out dBSWGT);

            if (gubun == "1")
                Decimal.TryParse(lblIN_WLEN.Text.Replace(",", ""), out dWLENWGT);
            else
                Decimal.TryParse(Grid2.Row.Cells["WLEN"].Value.ToString().Replace(",", ""), out dWLENWGT);

            if (gubun == "1")
                Decimal.TryParse(lblIN_VLEN.Text.Replace(",", ""), out dVLENWGT);
            else
                Decimal.TryParse(Grid2.Row.Cells["VLEN"].Value.ToString().Replace(",", ""), out dVLENWGT);

            //return Math.Round(dvalue * 500 * (dBSWGT / 1000) * (dWLENWGT / 1000) * (dVLENWGT / 1000), 3, MidpointRounding.AwayFromZero);
            return Math.Truncate(dvalue * 500 * (dBSWGT / 1000) * (dWLENWGT / 1000) * (dVLENWGT / 1000) * 1000) / 1000;
        }

        /// <summary>
        /// 중량으로 연수계산
        /// </summary>
        private Decimal WgtToReam(Decimal dvalue)
        {
            if (dvalue == 0) return 0;
            if (Grid2.Rows.Count < 1) return 0;

            Decimal dBSWGT = 0;     // 평량
            Decimal dWLENWGT = 0;   // 폭
            Decimal dVLENWGT = 0;   // 길이

            Decimal.TryParse(lblIN_BS_WGT.Text.Replace(",", ""), out dBSWGT);
            Decimal.TryParse(Grid2.Row.Cells["WLEN"].Value.ToString().Replace(",", ""), out dWLENWGT);
            Decimal.TryParse(Grid2.Row.Cells["VLEN"].Value.ToString().Replace(",", ""), out dVLENWGT);

            if (dBSWGT == 0 || dWLENWGT == 0 || dVLENWGT == 0)
                return 0;

            return dvalue / (500 * (dBSWGT / 1000) * (dWLENWGT / 1000) * (dVLENWGT / 1000));
        }

        /// <summary>
        /// 수재단 규격이 계획연수의 두배 이상인지 확인.
        /// </summary>
        /// <param name="srcReam">투입연수</param>
        /// <returns></returns>
        private Decimal MultipleReam(Decimal srcReam)
        {
#if true
            return srcReam;  
#else
            if (Grid2.Rows.Count < 1) return srcReam;

            if (srcReam == 0) return srcReam;

            Decimal dWLEN = 0;   // 폭
            Decimal dVLEN = 0;   // 길이

            Decimal dWLENMAN = 0;   // 수재단 폭 
            Decimal dVLENMAN = 0;   // 수재단 길이

            Decimal.TryParse(lblIN_WLEN.Text.Replace(",", ""), out dWLENMAN);
            Decimal.TryParse(lblIN_VLEN.Text.Replace(",", ""), out dVLENMAN);

            Decimal.TryParse(Grid2.Row.Cells["WLEN"].Value.ToString().Replace(",", ""), out dWLEN);
            Decimal.TryParse(Grid2.Row.Cells["VLEN"].Value.ToString().Replace(",", ""), out dVLEN);

            if (dWLEN == 0 || dVLEN == 0 || dWLENMAN == 0 || dVLENMAN == 0)
            {
                return srcReam;
            }

            Decimal wMul = 1;
            Decimal vMul = 1;

            if (dWLENMAN > dWLEN)
            {
                wMul = Math.Truncate(dWLENMAN / dWLEN);
                if (wMul == 0) wMul = 1;
            }

            if (dVLENMAN > dVLEN)
            {
                vMul = Math.Truncate(dVLENMAN / dVLEN);
                if (vMul == 0) vMul = 1;
            }

            // 여러 팔렛트가 투입되어 작업 할 때 선입선출로 투입연수 계산을 위해...
            gdCntReam = wMul * vMul;

            return (wMul * vMul) * srcReam;
#endif
        }

        private bool CheckProdQty()
        {
            Decimal dPLT_REAM_EA = Decimal.TryParse(lblPF_TOT_REAM.Text.Replace(",", ""), out dPLT_REAM_EA) ? dPLT_REAM_EA : 0;
            Decimal dDISPO_REAM = Decimal.TryParse(lblPF_DISPO_REAM.Text.Replace(",", ""), out dDISPO_REAM) ? dDISPO_REAM : 0;
            Decimal dAVA_REAM = Decimal.TryParse(lblIN_AVA_REAM.Text.Replace(",", ""), out dAVA_REAM) ? dAVA_REAM : 0;

            // 가용중량 보다 클 경우 메세지 발생
            if (dAVA_REAM < (dPLT_REAM_EA + dDISPO_REAM))
            {
                DialogResult RST = new POPUP.MessageForm("입력된 실적(실적 + 폐품) 연수가 가용연수보다 많습니다.\n\r"
                                    + "가용연수 : " + dAVA_REAM.ToString("#,##0.###") + "\n\r"
                                    + "실적연수 : " + dPLT_REAM_EA.ToString("#,##0.###") + "\n\r"
                                    + "폐품연수 : " + dDISPO_REAM.ToString("#,##0.###") + "\n\r"
                                    , MessageBoxButtons.OK, "알   림").ShowDialog(this);

                return false;
            }

            return true;
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
            if (gsgrid2CHK == "N")
            {
                new POPUP.MessageForm("작업지시를 먼저 선택하세요", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return;
            }

            DAResultNum pop = new DAResultNum();
            pop.LabelTitle = "수재단 실적 연수 입력 ";
            pop.LabelHeader = "실적 연수";
            pop.ContentMaxLength = 10;

            pop.ShowDialog(this);

            if (pop.DialogResult == DialogResult.OK)
            {
                Decimal dPLT_REAM_EA = 0;
                Decimal dDISPO_REAM = 0;
                Decimal dPLT_REAM_WGT = 0;
                Decimal dDISPO_REAM_WGT = 0;

                Decimal dPLT_REAM = Convert.ToDecimal(pop.ResultDouble);

                Decimal dEA = Convert.ToDecimal(pop.ResultDouble) * 500;
                if ((dEA % 1) == 0)
                {

                    // 실적중량 check ( 투입중량 보다 많을 경우 메세지 발생 )
                    Decimal.TryParse(lblPF_PLT_EA.Text.Replace(",", ""), out dPLT_REAM_EA);
                    Decimal.TryParse(lblPF_DISPO_REAM.Text.Replace(",", ""), out dDISPO_REAM);

                    //실적중량계산
                    if (dPLT_REAM_EA > 0)
                    {
                        //실적 중량
                        dPLT_REAM_WGT = ReamToWgt("2", dPLT_REAM * dPLT_REAM_EA);
                        // 폐품중량
                        dDISPO_REAM_WGT = ReamToWgt("2", dDISPO_REAM);

                        // 가용중량 보다 클 경우 메세지 발생
                        //if (gdABLEWGT < (dPLT_REAM_WGT + dDISPO_REAM_WGT))
                        //{
                        //    DialogResult RST = new POPUP.MessageForm("입력된 실적(실적 + 폐품) 중량이 가용중량보다 많습니다.\n\r"
                        //                        + "가용중량 : " + gdABLEWGT.ToString("#,##0.###") + " kg" + "\n\r"
                        //                        + "(가용연수) : " + gdABLREAM.ToString("#,##0.###") + "\n\r"
                        //                        + "실적중량 : " + dPLT_REAM_WGT.ToString("#,##0.###") + " kg" + "\n\r"
                        //                        + "폐품중량 : " + dDISPO_REAM_WGT.ToString("#,##0.###") + " kg" + "\n\r\n\r"
                        //                        + "계속 진행하시겠습니까? ", MessageBoxButtons.YesNo, "알   림").ShowDialog(this);

                        //    if (RST == DialogResult.No)
                        //        return;
                        //}
                    }

                    lblPF_PLT_REAM.Text = string.Format("{0:#,0.###}", dPLT_REAM);
                    //중량계산
                    WgtCalculation();
                }
                else
                {
                    string sMsg = string.Format("실적연수를 매수로 환산 했을 때 정수가 아닙니다.\r\n소숫점 세자리 입력시 짝수로 끝나야 합니다.\r\n{0:#,0.###} x 500 = {1:#,0.###}", Convert.ToDecimal(pop.ResultDouble), dEA);
                    new POPUP.MessageForm(sMsg, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                }
            }
        }

        private void lblMAKE_PLT_EA_Click(object sender, EventArgs e)
        {
            if (gsgrid2CHK == "N")
            {
                new POPUP.MessageForm("작업지시를 먼저 선택하세요", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return;
            }

            DAResultNum pop = new DAResultNum();
            //DAResultQty pop = new DAResultQty();
            pop.LabelTitle = "수재단 실적 팔레트 입력 ";
            pop.LabelHeader = "실적 팔레트수";
            pop.ContentMaxLength = 8;

            pop.ShowDialog(this);

            if (pop.DialogResult == DialogResult.OK)
            {
                Decimal dPLT_REAM = 0;
                Decimal dDISPO_REAM = 0;
                Decimal dPLT_REAM_WGT = 0;
                Decimal dDISPO_REAM_WGT = 0;

                Decimal dPLT_REAM_EA = Convert.ToDecimal(pop.ResultDouble);

                // 실적중량 check ( 투입중량 보다 많을 경우 메세지 발생 )
                Decimal.TryParse(lblPF_PLT_REAM.Text.Replace(",", ""), out dPLT_REAM);
                Decimal.TryParse(lblPF_DISPO_REAM.Text.Replace(",", ""), out dDISPO_REAM);

                //실적중량계산
                if (dPLT_REAM > 0)
                {
                    //실적 중량
                    dPLT_REAM_WGT = ReamToWgt("2", dPLT_REAM * dPLT_REAM_EA);
                    // 폐품중량
                    dDISPO_REAM_WGT = ReamToWgt("2", dDISPO_REAM);

                    // 가용중량 보다 클 경우 메세지 발생
                    //if (gdABLEWGT < (dPLT_REAM_WGT + dDISPO_REAM_WGT))
                    //{
                    //    DialogResult RST = new POPUP.MessageForm("입력된 실적(실적 + 폐품) 중량이 가용중량보다 많습니다.\n\r"
                    //                        + "가용중량 : " + gdABLEWGT.ToString("#,##0.###") + " kg" + "\n\r"
                    //                        + "(가용연수) : " + gdABLREAM.ToString("#,##0.###") + "\n\r"
                    //                        + "실적중량 : " + dPLT_REAM_WGT.ToString("#,##0.###") + " kg" + "\n\r"
                    //                        + "폐품중량 : " + dDISPO_REAM_WGT.ToString("#,##0.###") + " kg" + "\n\r\n\r"
                    //                        + "계속 진행하시겠습니까? ", MessageBoxButtons.YesNo, "알   림").ShowDialog(this);

                    //    if (RST == DialogResult.No)
                    //        return;
                    //}
                }

                lblPF_PLT_EA.Text = string.Format("{0:#,0.#}", dPLT_REAM_EA);
                WgtCalculation();
            }
        }

        private void lblCHK_DISPO_Click(object sender, EventArgs e)
        {
            InitDISPO();
        }

        private void lblDISPO_REAM_Click(object sender, EventArgs e)
        {
            if (gsgrid2CHK == "N")
            {
                new POPUP.MessageForm("작업지시를 먼저 선택하세요", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return;
            }

            DAResultNum pop = new DAResultNum();
            pop.LabelTitle = "수재단폐품 입력";
            pop.LabelHeader = "수재단폐품(R)";
            pop.ContentMaxLength = 10;

            pop.ShowDialog(this);

            if (pop.DialogResult == DialogResult.OK)
            {
                Decimal dPLT_REAM_EA = 0;
                Decimal dPLT_REAM = 0;
                Decimal dPLT_REAM_WGT = 0;
                Decimal dDISPO_REAM_WGT = 0;

                Decimal dDISPO_REAM = Convert.ToDecimal(pop.ResultDouble);

                Decimal dEA = Convert.ToDecimal(pop.ResultDouble) * 500;
                if ((dEA % 1) == 0)
                {
                    // 폐품실적중량 check ( 투입중량 보다 많을 경우 메세지 발생 )
                    Decimal.TryParse(lblPF_PLT_EA.Text.Replace(",", ""), out dPLT_REAM_EA);
                    Decimal.TryParse(lblPF_PLT_REAM.Text.Replace(",", ""), out dPLT_REAM);

                    //실적 중량
                    dPLT_REAM_WGT = ReamToWgt("2", dPLT_REAM * dPLT_REAM_EA);
                    // 폐품중량
                    dDISPO_REAM_WGT = ReamToWgt("2", dDISPO_REAM);

                    // 가용중량 보다 클 경우 메세지 발생
                    //if (gdABLEWGT < (dPLT_REAM_WGT + dDISPO_REAM_WGT))
                    //{
                    //    DialogResult RST = new POPUP.MessageForm("입력된 실적(실적 + 폐품) 중량이 가용중량보다 많습니다.\n\r"
                    //                        + "가용중량 : " + gdABLEWGT.ToString("#,##0.###") + " kg" + "\n\r"
                    //                        + "(가용연수) : " + gdABLREAM.ToString("#,##0.###") + "\n\r"
                    //                        + "실적중량 : " + dPLT_REAM_WGT.ToString("#,##0.###") + " kg" + "\n\r"
                    //                        + "폐품중량 : " + dDISPO_REAM_WGT.ToString("#,##0.###") + " kg" + "\n\r\n\r"
                    //                        + "계속 진행하시겠습니까? ", MessageBoxButtons.YesNo, "알   림").ShowDialog(this);

                    //    if (RST == DialogResult.No)
                    //        return;
                    //}

                    lblPF_DISPO_REAM.Text = string.Format("{0:#,0.###}", dDISPO_REAM);
                    DispoWgtCalculation();
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
            DAResultText pop = new DAResultText("수재단 비고 입력", lblPF_WRK_ORDR_RMK.Text.ToString());
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
                CheckValue(lblEndChk, string.Empty);
            else
                CheckValue(lblEndChk, "V");
        }

        private void lblPrintChk_Click(object sender, EventArgs e)
        {
            if (lblPrintChk.Text.ToString().Equals("V"))
                CheckValue(lblPrintChk, string.Empty);
            else
                CheckValue(lblPrintChk, "V");
        }

        private void dtpDate_DropDown(object sender, EventArgs e)
        {
            CommonCalendar.CloseCalendar((DateTimePicker)sender);
            lblPF_PLT_REAM.Focus();
        }

        private void Grid1_GridSelectChanged(object sender, AfterSelectChangeEventArgs e)
        {
            //if (typeof(UltraGridRow) == e.Type)
            //{
            //    if (Grid1.Rows.Count < 1)
            //        return;

            //    if (Grid1.Row == null)
            //        return;

            //    SetGrid1();

            //    // 투입 정보 및 기 생산실적 정보 보여주기
            //    //DoFind();

            //    // 투입연수 및 중량 구하기
            //    DoFind02();

            //    if (Grid2.Rows.Count > 0)
            //    {
            //        //초기 실적연수 및 팔레트 수량 표시
            //        lblPF_PLT_REAM.Text = Grid2.Row.Cells["PLT_PER_CNT"].Value.ToString();
            //        lblPF_PLT_EA.Text = "1";

            //        WgtCalculation();

            //        //투입정보에 사용량 표시
            //        //DoFind03();
            //    }
            //}
        }

        private void lblEndDateChk_Click(object sender, EventArgs e)
        {
            if (lblEndDateChk.Text.Equals("V"))
            {
                CheckValue(lblEndDateChk, string.Empty);

                dtpEndDate.Enabled = true;
                butEndDate.Enabled = true;
                lblEndTime.Enabled = true;
            }
            else
            {
                CheckValue(lblEndDateChk, "V");

                dtpEndDate.Enabled = false;
                butEndDate.Enabled = false;
                lblEndTime.Enabled = false;

                CallUpdateMinuteFunc();
            }
        }

        private void btnMRDetail_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(Common.WrkOrderNo))
                return;

            string sIND_BCD = Grid1.Row.Cells["IND_BCD"].Value.ToString();      // 개별바코드

            POP_WRK84 popWrk84 = new POP_WRK84(POP_WRK84.PROC_INP, Common.PlantCode, Common.OpCode, Common.WrkOrderNo, Common.WrkOrderSeq, sIND_BCD);  // 작업지시 정보
            ShowDialogForm(popWrk84);
        }

        private void Grid2_ClickCellButton(object sender, MESGrid.GridClickEventArg e)
        {
            //선택 버튼 클릭시 체크여부 변경
            //if (e.column.ToString() == "CHK")
            //{
            //    string sStatus_Pre = e.row.Cells["CHK"].Value.ToString();

            //    if (sStatus_Pre == "V")
            //        e.row.Cells["CHK"].Value = "-";
            //    else
            //        e.row.Cells["CHK"].Value = "V";

            //    // 기 입력 실적 및 폐품연수 구하기
            //    DoFind02();

            //    // 예외생산으로 인해 추가 됨
            //    DoFind();

            //    // 실적, 폐품중량계산
            //    CalculationWeigh();
            //}
            //else 
            if (e.column.ToString() == "DETAIL_BTN") // 상세보기
            {
                string sWrkOrder = e.row.Cells["WRK_ORDR_NO"].Value.ToString();
                string sWrkOrderSeq = e.row.Cells["WRK_ORDR_SEQNO"].Value.ToString();

                POP_WRK84 popWrk84 = new POP_WRK84(POP_WRK84.PROC_WRK, Common.PlantCode, Common.OpCode, sWrkOrder, sWrkOrderSeq);  // 작업지시 정보
                ShowDialogForm(popWrk84);
            }
        }

        private void Grid1_ClickCellButton(object sender, MESGrid.GridClickEventArg e)
        {
            //선택 버튼 클릭시 체크여부 변경
            if (e.column.ToString() == "CHK")
            {
                string sStatus_Pre = e.row.Cells["CHK"].Value.ToString();

                if (sStatus_Pre != "V")
                {
                    foreach (UltraGridRow row in Grid1.Rows)
                    {
                        row.Cells["CHK"].Value = "-";
                    }
                }

                if (sStatus_Pre == "V")
                {
                    e.row.Cells["CHK"].Value = "-";

                    lblIN_MOVE_REAM.Text = string.Empty;
                    lblIN_USE_REAM.Text = string.Empty;
                    lblIN_DISPO_REAM.Text = string.Empty;
                    lblIN_AVA_REAM.Text = string.Empty;
                    lblIN_MOVE_WGT.Text = string.Empty;
                    lblIN_USE_WGT.Text = string.Empty;
                    lblIN_DISPO_WGT.Text = string.Empty;
                    lblIN_AVA_WGT.Text = string.Empty;
                }
                else
                {
                    e.row.Cells["CHK"].Value = "V";

                    Decimal dINREAM = 0, dUSEREAM = 0, dDISPREAM = 0, dABLEREAM = 0;
                    Decimal dINWGT = 0, dUSEWGT = 0, dDISPWGT, dABLEWGT = 0;

                    Decimal.TryParse(e.row.Cells["IN_REAM"].Value.ToString(), out dINREAM);
                    Decimal.TryParse(e.row.Cells["WGT"].Value.ToString(), out dINWGT);
                    Decimal.TryParse(e.row.Cells["USE_QTY"].Value.ToString(), out dUSEREAM);
                    Decimal.TryParse(e.row.Cells["USE_WGT"].Value.ToString(), out dUSEWGT);
                    Decimal.TryParse(e.row.Cells["DISPO_QTY"].Value.ToString(), out dDISPREAM);
                    Decimal.TryParse(e.row.Cells["DISWGT"].Value.ToString(), out dDISPWGT);


                    dABLEWGT = dINWGT - (dUSEWGT + dDISPWGT);
                    if (dABLEWGT < 0) dABLEWGT = 0;

                    // 중량정보
                    lblIN_MOVE_WGT.Text = string.Format("{0:###0.000}", dINWGT);     //투입중량
                    lblIN_USE_WGT.Text = string.Format("{0:###0.000}", dUSEWGT);     //사용중량
                    lblIN_DISPO_WGT.Text = string.Format("{0:###0.000}", dDISPWGT);  //폐품중량
                    lblIN_AVA_WGT.Text = string.Format("{0:###0.000}", dABLEWGT);    //가용중량

                    SetGrid2(e.row.Cells["IND_BCD"].Value.ToString());

                    //연수정보 => MultipleReam : 가로,세로 비교하여 연수 구함
                    dINREAM = MultipleReam(dINREAM);

                    dABLEREAM = dINREAM - (dUSEREAM + dDISPREAM);

                    lblIN_MOVE_REAM.Text = string.Format("{0:###0.000}", dINREAM);    //투입연수
                    lblIN_USE_REAM.Text = string.Format("{0:###0.000}", dUSEREAM);    //사용연수
                    lblIN_DISPO_REAM.Text = string.Format("{0:###0.000}", dDISPREAM); //폐품연수
                    lblIN_AVA_REAM.Text = string.Format("{0:###0.000}", dABLEREAM);   //가용연수



                    //if (typeof(UltraGridRow) == e.Type)
                    //{
                    //    if (Grid1.Rows.Count < 1)
                    //        return;

                    //    if (Grid1.Row == null)
                    //        return;

                    //    SetGrid1();

                    //    // 투입 정보 및 기 생산실적 정보 보여주기
                    //    //DoFind();

                    //    // 투입연수 및 중량 구하기
                    //    DoFind02();

                    //    if (Grid2.Rows.Count > 0)
                    //    {
                    //        //초기 실적연수 및 팔레트 수량 표시
                    //        lblPF_PLT_REAM.Text = Grid2.Row.Cells["PLT_PER_CNT"].Value.ToString();
                    //        lblPF_PLT_EA.Text = "1";

                    //        WgtCalculation();

                    //        //투입정보에 사용량 표시
                    //        //DoFind03();
                    //    }
                    //}
                }
            }
        }

        private void btnFindMain_Click(object sender, EventArgs e)
        {
            UpdateGrid();
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
