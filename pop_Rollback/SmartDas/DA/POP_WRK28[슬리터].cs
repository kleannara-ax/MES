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
    public partial class POP_WRK28 : BaseForm
    {
        #region < MEMBER AREA >

        private DataTable dtInpInfo = new DataTable();   //투입 정보 테이블

        private int giBS_WGT = 0;              // 평량
        private int giMWIDTH_SUM = 0;          // 슬리터지폭합
        private decimal gdROLLCNT = 0;         // 실적권치수
        private decimal gdDISPO_ROLLCNT = 0;   // 폐품권치수
        private string gsgrid2CHK = "N";
        private string gsWODIV = string.Empty;  //작업지시 구분 ( 정상, 예외)

        private SAMMI.Common _common = new SAMMI.Common();

        // 버튼 알람용 변수
        private int iReSetCnt = 0;
        private bool bABNChk = false;
        DataTable dtStop_Temp = new DataTable();

        #endregion

        #region < CONSTRUCTOR >

        public POP_WRK28()
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

                // lblStartTime.Text 에 시:분 을 먼지 입력해야 dtpDate_ValueChanged 이벤트에서 AutoCalculation() 에서 정상처리됨.
                lblEndTime.Text = dtTmp.ToString("HH:mm");       // 작업종료시간
                dtpEndDate.Value = dtTmp;
            }
        }

        #endregion

        #region < POP_WRK28_Load >
        private void POP_WRK28_Load(object sender, EventArgs e)
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

                this.lblTitle.Text = "슬리터 실적등록";

                //IP별 정보 구하기
                Common.machSetting();


                ucPNT_CNT.Items.Clear();

                ucPNT_CNT.Items.Add("01", "1 매");
                ucPNT_CNT.Items.Add("02", "2 매");

                ucPNT_CNT.SelectedIndex = 0;
                ucPNT_CNT.ValueList.ItemHeight = 70;

                ucCORE.SelectedIndex = 0;
                ucCORE.ValueList.ItemHeight = 70;


                // 지관 ComboBox
                ucCORE.SelectedIndex = 0;
                ucCORE.ValueList.ItemHeight = 70;

                // 하단 메뉴버튼 생성
                SetMenuButtons();

                // 화면 초기설정
                InitProduct();

                // 지관 구하기
                SetCore();

                //투입정보 및 작업지시 정보 표시
                UpdateGrid();
            }
            catch (Exception ex)
            {
                SetMessage("POP_WRK28_Load_ Error!");
                LogFile.WriteLog("POP_WRK28.POP_WRK28_Load Error => " + ex.Message);
            }
        }
        #endregion

        #region < METHOD AREA >

        /// <summary>
        /// 실적 등록후 초기설정
        /// </summary>
        private void InitProduct()
        {
            // 체크박스 초기설정
            CheckValue(lblSEndChk, string.Empty);       //슬리터완료
            //CheckValue(lblPrintChk, "V");               //자동인쇄
            CheckValue(lblEndDateChk, "V");             //from date
            CheckValue(lblPF_CHK_DISPO, string.Empty);  //반품사유
            // 투입부분
            lblIN_MLOT_NO.Text = string.Empty;
            lblIN_PCODE.Text = string.Empty;
            lblIN_BS_WGT.Text = string.Empty;
            lblIN_MWIDTH.Text = string.Empty;
            lblIN_PRFM_WGT.Text = string.Empty;
            lblIN_USE_WGT.Text = string.Empty;
            lblIN_DISPO_QTY.Text = string.Empty;
            lblIN_AVA_WGT.Text = string.Empty;
            lblIN_PRFM_CNT.Text = string.Empty;
            lblIN_USE_CNT.Text = string.Empty;
            lblIN_DISPO_CNT.Text = string.Empty;
            lblIN_AVA_CNT.Text = string.Empty;

            txtIN_ORDER_RMK.Text = string.Empty;

            //lblMACH_STA.Text = "대기중";
            // 실적 등록 부분
            lblPF_ROLLCNT.Text = string.Empty;
            lblPF_WGT.Text = string.Empty;
            lblPF_WRK_ORDR_RMK.Text = string.Empty;

            // 지관 초기값
            ucCORE.SelectedIndex = -1;

            // 완료시간
            dtpEndDate.Enabled = false;
            butEndDate.Enabled = false;
            lblEndTime.Enabled = false;

            // 폐품 실적 부분
            InitDISPO();
        }

        // 폐품정보 초기설정
        private void InitDISPO()
        {
            lblPF_DISPO_ROLLCNT.Enabled = false;
            lblPF_DISPO_ROLLCNT.BackColor = Color.LightGray;
            lblPF_DISPO_ROLLCNT.Text = string.Empty;
            lblPF_DISPO_WGT.Text = string.Empty;
            lblPF_DISPO_CODE.Text = string.Empty;
            lblPF_DISPO_CODE.Tag = string.Empty;

            CheckValue(lblPF_CHK_DISPO, string.Empty);
            lblPF_CHK_DISPO.Visible = false;
            lblPF_DISPO_CODE_NAME.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;

            gdDISPO_ROLLCNT = 0;   // 폐품치수
        }

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

        private void UpdateGrid()
        {
            //작업지시정보 (그리드1, 그리드2)
            SetGrid();

            // 투입 정보 및 기 생산실적 정보 보여주기
            DoFind();

            //실적 기본값셋팅 및 중량표시
            DoFind02();

            // 투입정보 중량 표시
            if (Grid1.Rows.Count > 0)
                SetGrid02();
        }

        private void SetGrid()
        {
            DBHelper helper = new DBHelper();

            DataSet dsRtn = new DataSet();
            DataSet dsMA = new DataSet();       // 슬리터 바코드 정보
            DataSet dsMAWrk = new DataSet();    // 슬리터 작업지시 
            DataTable dtTemp = new DataTable();

            try
            {
                Grid1.Row = null;
                Grid2.Row = null;
                Grid1.DataSource = null;
                Grid2.DataSource = null;

                Common.OrderNo = string.Empty;      //생산오더번호
                Common.WrkOrderNo = string.Empty;   //작업지시번호
                Common.WrkOrderSeq = string.Empty;  //작업지시순번
                Common.ItemCode = string.Empty;     //자재코드

                Grid1.HeaderFontSize = 16;
                Grid1.FontSize = 16;
                Grid1.CountRows = 3;
                Grid1.AutoScroll = true;
                Grid1.DisplayLayout.Bands[0].Override.SelectTypeCol = SelectType.None;
                //Grid1.DisplayLayout.Scrollbars = Scrollbars.Vertical;
                btnRightPage.LinkMoveSize = Grid1.CountRows;
                btnLeftPage.LinkMoveSize = Grid1.CountRows;
                btnGroupUp.LinkMoveSize = Grid1.CountRows;
                btnGroupDown.LinkMoveSize = Grid1.CountRows;

                Grid2.HeaderFontSize = 11;
                Grid2.FontSize = 11;
                Grid2.CountRows = 4;
                Grid2.AutoScroll = true;
                Grid2.DisplayLayout.Bands[0].Override.SelectTypeCol = SelectType.None;
                //Grid2.DisplayLayout.Scrollbars = Scrollbars.Vertical;
                btnItemUp.LinkMoveSize = Grid2.CountRows;
                btnItemDown.LinkMoveSize = Grid2.CountRows;

                dsRtn = helper.FillDataSetN("SP_POP_WRK28_S01", CommandType.StoredProcedure, 5
                                                    , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)                  // 플랜트코드
                                                    , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)              //작업장코드(설비코드)
                                                    , helper.CreateParameter("RS_MACH_STA", DbType.String, ParameterDirection.Output, null, 30)                     //  RES MACH_STA 가동상태(R :가동, S:비가동, N:대기중)
                                                    );

                if (helper.RSCODE == "S" || helper.RSCODE == "E")
                {
                    timer1.Start();

                    bBox1[0, 4].bAlarm = false;

                    string sRS_MACH_STA = helper.Parameters["RS_MACH_STA"].Value.ToString();

                    //가동상태(R :가동, S:비가동, N:대기중)
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
                    dtInpInfo = dsRtn.Tables[0].Copy();

                    if (dtInpInfo.Rows.Count > 0)
                    {
                        Common.WrkOrderNo = dtInpInfo.Rows[0]["WRK_ORDR_NO"].ToString();//작업지시번호
                        Common.WrkOrderSeq = dtInpInfo.Rows[0]["WRK_ORDR_SEQNO"].ToString();//작업지시순번

                        //작업지시번호
                        lblIN_MLOT_NO.Text = string.Format("{0}-{1}", Common.WrkOrderNo, Common.WrkOrderSeq);
                    }

                    //슬리터 바코드 목록
                    dsMA.Tables.Add(dsRtn.Tables[1].Copy());
                    dsMA.Tables.Add(dsRtn.Tables[2].Copy());
                    Grid1.DoFind_Oracle(dsMA);

                    //슬리터 작업 지시
                    dsMAWrk.Tables.Add(dsRtn.Tables[3].Copy());
                    dsMAWrk.Tables.Add(dsRtn.Tables[4].Copy());
                    Grid2.DoFind_Oracle(dsMAWrk);

                    Grid1.DisplayLayout.Override.DefaultRowHeight = 50;
                    Grid2.DisplayLayout.Override.DefaultRowHeight = 50;

                    if (Grid1.Rows.Count > 0)
                    {
                        // 첫번째 행 선택
                        Grid1.Rows[0].Selected = true;
                        Grid1.Row = Grid1.Rows[0];
                        //GridSelectChanged event 강제 발생시킴
                        Grid1_GridSelectChanged(Grid1, new AfterSelectChangeEventArgs(typeof(UltraGridRow)));
                    }

                    if (Grid2.Rows.Count > 0)
                    {
                        // 첫번째 행 선택
                        Grid2.Rows[0].Selected = true;
                        Grid2.Row = Grid2.Rows[0];

                        if (Grid2.Row.Cells["GB"].Value.ToString() == "예외")
                        {
                            gsWODIV = "예외";
                            this.lblTitle.Text = "슬리터 실적등록(예외)";
                        }
                        else
                        {
                            gsWODIV = "계획";
                            this.lblTitle.Text = "슬리터 실적등록";
                        }
                    }
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
                LogFile.WriteLog("POP_WRK28.SetGrid Error => " + ex.Message);
            }
        }

        private void DoFind()
        {
            try
            {
                if (dtInpInfo.Rows.Count < 1)
                {
                    //SetMessage("조회된 작업지시가 없습니다.");
                    lblIN_MLOT_NO.Text = string.Empty;
                    lblIN_PCODE.Text = string.Empty;
                    lblIN_BS_WGT.Text = string.Empty;
                    lblIN_MWIDTH.Text = string.Empty;
                    txtIN_ORDER_RMK.Text = string.Empty;

                    lblIN_PRFM_WGT.Text = string.Empty;
                    lblIN_USE_WGT.Text = string.Empty;
                    lblIN_DISPO_QTY.Text = string.Empty;
                    lblIN_AVA_WGT.Text = string.Empty;

                    lblIN_PRFM_CNT.Text = string.Empty;
                    lblIN_USE_CNT.Text = string.Empty;
                    lblIN_DISPO_CNT.Text = string.Empty;
                    lblIN_AVA_CNT.Text = string.Empty;

                    //생산진행상태
                    //lblMACH_STA.Text = "대기중";
                }
                else
                {
                    //lblIN_MLOT_NO.Text = dtInpInfo.Rows[0]["LOT_NO"].ToString();  //LOT NO
                    lblIN_PCODE.Text = dtInpInfo.Rows[0]["PCODE"].ToString();       //지종
                    lblIN_BS_WGT.Text = dtInpInfo.Rows[0]["BS_WGT"].ToString();     //평량
                    lblIN_MWIDTH.Text = dtInpInfo.Rows[0]["MWIDTH"].ToString();     //슬리터지폭
                    txtIN_ORDER_RMK.Text = dtInpInfo.Rows[0]["ORDER_RMK"].ToString().Replace("|", "\r\n"); //생산오더 비고

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
                }

                // 평량 ...
                int.TryParse(lblIN_BS_WGT.Text.ToString().Replace(",", ""), out giBS_WGT);
            }
            catch (Exception ex)
            {
                SetMessage("SetGrid Error!");
                LogFile.WriteLog("POP_WRK28.DoFind Error => " + ex.Message);
            }
        }

        /// <summary>
        /// 슬리터 작업지시 내용
        /// </summary>
        /// <param name="gubun"> 1: 작업지시변경으로, 2: 그리드 클릭으로 </param>
        private void DoFind02()
        {
            int chk = 0;

            giMWIDTH_SUM = 0;   // 슬리터 지폭합

            if (Grid1.Rows.Count < 1)
                return;

            // 슬리터 선택된 지폭합 구하기.
            foreach (UltraGridRow ugr in Grid2.Rows)
            {
                if (ugr.Cells["CHK"].Value.ToString().Equals("V"))
                {
                    int nSWIDTH = 0;
                    string sSWIDTH = ugr.Cells["MWIDTH"].Value.ToString().Replace(",", "");

                    if (int.TryParse(sSWIDTH, out nSWIDTH) == true)
                    {
                        giMWIDTH_SUM += nSWIDTH;
                    }
                    chk++;
                }
            }

            decimal.TryParse(lblIN_AVA_CNT.Text, out gdROLLCNT);
            gdDISPO_ROLLCNT = 0;

            if (gdROLLCNT == 0)
                lblPF_ROLLCNT.Text = string.Empty;
            else
                lblPF_ROLLCNT.Text = string.Format("{0:#,0}", gdROLLCNT);

            if (gdDISPO_ROLLCNT == 0)
                lblPF_DISPO_ROLLCNT.Text = string.Empty;

            //중량계산
            CalculationWeigh();

            // 작업지시 선택여부를 판단을 위해...
            if (chk > 0)
                gsgrid2CHK = "Y";
            else
                gsgrid2CHK = "N";
        }

        private void SetGrid02()
        {
            DBHelper helper = new DBHelper();
            DataSet dsRtn = new DataSet();
            DataTable dtTemp = new DataTable();

            try
            {
                string sJIND_BCD = "";    // 개별바코드

                if (Grid1.Rows.Count < 1 || Grid1.Row == null)
                {
                    lblIN_PRFM_WGT.Text = "";   //실적량
                    lblIN_USE_WGT.Text = "";    //사용량
                    lblIN_DISPO_QTY.Text = "";  //폐품량
                    lblIN_AVA_WGT.Text = "";    //가용량

                    lblIN_PRFM_CNT.Text = string.Empty;
                    lblIN_USE_CNT.Text = string.Empty;
                    lblIN_DISPO_CNT.Text = string.Empty;
                    lblIN_AVA_CNT.Text = string.Empty;
                    txtIN_ORDER_RMK.Text = "";  //작업자 비고
                    return;
                }

                sJIND_BCD = Grid1.Row.Cells["IND_BCD"].Value.ToString();

                dsRtn = helper.FillDataSetN("SP_POP_WRK28_S02", CommandType.StoredProcedure, 2
                                                    , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)      // 플랜트코드
                                                    , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)  // 작업장코드(설비코드)
                                                    , helper.CreateParameter("P_JIND_BCD", sJIND_BCD, DbType.String, ParameterDirection.Input)          // 투입정보 바코드
                                                    );

                //버튼 상태 변경
                if (helper.RSCODE.Equals("S"))
                {
                    dtTemp = dsRtn.Tables[0].Copy();

                    if (dtTemp.Rows.Count > 0)
                    {
                        lblIN_PRFM_WGT.Text = Common.StrFormatDouble(dtTemp.Rows[0]["PRFM_QTY"].ToString());    //실적량
                        lblIN_USE_WGT.Text = Common.StrFormatDouble(dtTemp.Rows[0]["USE_QTY"].ToString());      //사용량
                        lblIN_DISPO_QTY.Text = Common.StrFormatDouble(dtTemp.Rows[0]["DISPO_QTY"].ToString());  //폐품량
                        lblIN_AVA_WGT.Text = Common.StrFormatDouble(dtTemp.Rows[0]["ABLE_QTY"].ToString());     //가용량
                        txtIN_ORDER_RMK.Text = dtTemp.Rows[0]["RMK"].ToString().Replace("|", "\r\n");           //투입의 비고

                        //투입권치수
                        decimal dINROLLCNT = 0, dUSECNT = 0, dDISPCNT = 0;
                        decimal.TryParse(Grid1.Row.Cells["ROLLCNT"].Value.ToString(), out dINROLLCNT);

                        lblIN_PRFM_CNT.Text = Common.StrFormatInteger(Grid1.Row.Cells["ROLLCNT"].Value.ToString());

                        if (dsRtn.Tables[1].Rows.Count > 0)
                        {
                            lblIN_USE_CNT.Text = Common.StrFormatInteger(dsRtn.Tables[1].Rows[0]["ROLLCNT"].ToString());
                            lblIN_DISPO_CNT.Text = Common.StrFormatInteger(dsRtn.Tables[1].Rows[0]["DISPO_ROLLCNT"].ToString());

                            decimal.TryParse(dsRtn.Tables[1].Rows[0]["ROLLCNT"].ToString(), out dUSECNT);
                            decimal.TryParse(dsRtn.Tables[1].Rows[0]["DISPO_ROLLCNT"].ToString(), out dDISPCNT);

                            // 가용 권치수가 음수인경우 0으로 표시
                            if ((dINROLLCNT - (dUSECNT + dDISPCNT)) > 0)
                                lblIN_AVA_CNT.Text = Common.StrFormatInteger((dINROLLCNT - (dUSECNT + dDISPCNT)).ToString());
                            else
                                lblIN_AVA_CNT.Text = "0";

                            //실적 권치수 조정
                            DoFind02();
                        }
                        else
                        {
                            lblIN_AVA_CNT.Text = lblIN_PRFM_CNT.Text;
                        }
                    }
                }
                else
                {
                    lblIN_PRFM_WGT.Text = "";   //실적량
                    lblIN_USE_WGT.Text = "";    //사용량
                    lblIN_DISPO_QTY.Text = "";  //폐품량
                    lblIN_AVA_WGT.Text = "";    //가용량
                    lblIN_PRFM_CNT.Text = string.Empty;
                    lblIN_USE_CNT.Text = string.Empty;
                    lblIN_DISPO_CNT.Text = string.Empty;
                    lblIN_AVA_CNT.Text = string.Empty;
                    txtIN_ORDER_RMK.Text = "";  //작업자 비고

                    new POPUP.MessageForm(helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return;
                }
            }
            catch (Exception ex)
            {
                lblIN_PRFM_WGT.Text = "";   //실적량
                lblIN_USE_WGT.Text = "";    //사용량
                lblIN_DISPO_QTY.Text = "";  //폐품량
                lblIN_AVA_WGT.Text = "";    //가용량
                lblIN_PRFM_CNT.Text = string.Empty;
                lblIN_USE_CNT.Text = string.Empty;
                lblIN_DISPO_CNT.Text = string.Empty;
                lblIN_AVA_CNT.Text = string.Empty;
                txtIN_ORDER_RMK.Text = "";  //작업자 비고

                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                LogFile.WriteLog("POP_WRK28.SetGrid2 Error => " + ex.Message);
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
                    helper.ExecuteNoneQuery("SP_POP_WRK28_I01", CommandType.StoredProcedure
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
                LogFile.WriteLog("POP_WRK28.SetGrid Error => " + ex.Message);
            }
            finally
            {
                helper.Close();
            }
        }

        /// <summary>
        /// 슬리터 실적등록
        /// </summary>
        private int doProduct()
        {
            DataTable dtList;

            // 작업지시 확인
            if (string.IsNullOrEmpty(lblIN_MLOT_NO.Text.ToString()))
            {
                new POPUP.MessageForm("투입정보가 없습니다.\r\n작업지시 선택후 실적등록 하세요!", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return Common.ERROR_FAIL;
            }

            // 선택된 슬리터 작업지시 확인
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
                new POPUP.MessageForm("실적 등록할 슬리터 작업지시를 선택 하세요!", MessageBoxButtons.OK, "알   림").ShowDialog(this);
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

            // 지관 확인
            if (ucCORE.SelectedIndex < 0)
            {
                new POPUP.MessageForm("지관 선택은 필수 입니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return Common.ERROR_FAIL;
            }

            //입력량 체크 (실적량은 투입량을 Over하면 안됨)
            //if (!CheckProdQty())
            //    return false;
            {
                decimal dIN_AVA_WGT = 0;     // 가용량
                decimal dPF_WGT = 0;
                decimal dPF_DISPO_WGT = 0;

                decimal.TryParse(lblIN_AVA_WGT.Text.ToString().Replace(",", ""), out dIN_AVA_WGT);
                decimal.TryParse(lblPF_WGT.Text.ToString().Replace(",", ""), out dPF_WGT);
                decimal.TryParse(lblPF_DISPO_WGT.Text.ToString().Replace(",", ""), out dPF_DISPO_WGT);

                if (dIN_AVA_WGT < (dPF_WGT + dPF_DISPO_WGT))
                {
                    new POPUP.MessageForm(string.Format("실적(폐품포함) 중량 값이 가용 중량 {0:#,0.###} (Kg)을 초과하여\r\n입력되었습니다.\r\n\r\n실적(폐품포함) 권치수 입력을 확인하세요!", dIN_AVA_WGT), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return Common.ERROR_FAIL;
                }
            }
            string sMRCOM_YN = "N"; // 밀롤 완료처리 (투입정보)
            string sSRCOM_YN = "N"; // 슬리터 완료처리

            if (lblSEndChk.Text.ToString() == "V")  // 슬리터 완료처리
            {
                sSRCOM_YN = "Y";
            }

            //if (sSRCOM_YN != "Y")
            {
                POPUP.MessageForm msgForm;
                msgForm = new POPUP.MessageForm("슬리터 완료 플래그를 체크 하시겠습니까?", MessageBoxButtons.YesNoCancel, "알  림");

                DialogResult dr = msgForm.ShowDialog(this);
                if (dr == DialogResult.Cancel)
                {
                    return Common.ERROR_FAIL;
                }
                else if (dr == DialogResult.Yes)
                {
                    sSRCOM_YN = "Y";
                }
            }

            // 슬리터완료 처리 되고, 슬리터 작업이 한개 남은경우는 밀롤 완료처리함(투입정보).
            if (sSRCOM_YN == "Y")
            {
                int iRowcnt = 0;

                foreach (UltraGridRow ugr in Grid2.Rows)
                {
                    if (ugr.Cells["CHK"].Value.ToString().Equals("V"))
                        iRowcnt++;
                }

                // 슬리터 작업지시를 모두 작업했을 경우 밀롤 'Y'
                if (Grid2.Rows.Count == iRowcnt)
                {
                    sMRCOM_YN = "Y";    //  밀롤 완료 처리(투입정보)
                }
            }

            // 0실적 체크용
            bool bZERO_PRFM = false;


            if (sMRCOM_YN == "Y")
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

            string sProcedure = string.Empty;

            if (gsWODIV == "예외")
                sProcedure = "SP_POP_WRK28_I03";
            else
                sProcedure = "SP_POP_WRK28_I02";

            LogFile.WriteLog("슬리터 실적 등록 시작 - " + sProcedure, LogType.PROC);

            // Temp table에 저장정보(실적) 담기
            dtList = setReqWorkList(sSRCOM_YN, sMRCOM_YN, sStartDate, sEndDate, sTM);

            string sJsonWrkList = Common.toJsonFormat("POP_WRK028", dtList);

            DBHelper helper = new DBHelper(false, "", true);
            DataSet dsTemp = new DataSet();     //실적등록 결과 수신(0:실적 RFC ID, 1:실적 IF 변수, 2:실적 RFC ID, 3:실적 IF 변수)
            bool bReturn1 = false, bReturn2 = false, bReturn3 = false; //실적, 폐품, 투입
            bool bRetSALES_DISPO = false;   // 영업폐품+잔량폐품 처리 결과
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
                //실적저장
                dsTemp = helper.FillDataSetN(sProcedure, CommandType.StoredProcedure, 8
                            , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)                  // 플랜트
                            , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)              // 작업장코드(설비코드)
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
                    sRES_IND_BCD = helper.Parameters["RS_IND_BCD"].Value.ToString();

                    string sRS_PRFM_RFCFN = helper.Parameters["RS_PRFM_RFCFN"].Value.ToString();      // 실적 RFCFN ID
                    string sRS_DISPO_RFCFN = helper.Parameters["RS_DISPO_RFCFN"].Value.ToString();    // 폐품 RFCFN ID
                    string sRS_INPUT_RFCFN = helper.Parameters["RS_INPUT_RFCFN"].Value.ToString();    // 투입량 RFCFN ID
                    string sRS_SDISPO_RFCFN = helper.Parameters["RS_SDISPO_RFCFN"].Value.ToString();    // 영업폐품 RFCFN ID

#if false
                    this.Cursor = Cursors.Default;

                    helper.Rollback();
                    return Common.ERROR_FAIL;
#endif


                    //SAP 롤백용 추가 CODE 범위 START
                    if (dsTemp.Tables[1].Columns[0].ColumnName != "1" && bZERO_PRFM == false)
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
                    //dsTemp.Tables[6];     // 잔량폐품 인터페이스 파라미터
                    //dsTemp.Tables[7];     // 잔량폐품 인터페이스 상세 파라미터

                    string sRfcData; //RFC결과 JSON 변환
                    bReturn1 = false;

                    // 1. 실적 등록 (슬리터 완료 플래그 때문에 마지막에 보냄)
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
                                LogFile.WriteLog("슬리터 실적 등록 - SAP 확정문서 등록 오류 [" + helper.RSMSG.ToString() + "]");
                                sMSG_ERR += "확정문서 등록 오류 : " + helper.RSMSG.ToString() + Environment.NewLine;
                                //new POPUP.MessageForm("실적 등록 - SAP 확정문서 등록 오류\r\n" + helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                throw new Exception("SAP_ERROR " + sMSG_ERR);  // SAP 로직 진행중 E 발생시 EXCEPTION THROW
                            }
                        }
                        else
                        {

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

                            bReturn1 = false;
                            //helper.Rollback();
                            LogFile.WriteLog("슬리터 실적 등록 - SAP 전송 실패 [" + sapRFC_P.rtnMSG + "]");
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
                        bReturn1 = true;
                    }

                    // 2. 폐품 등록
                    if ((bReturn1 == true) && (string.IsNullOrEmpty(sRS_DISPO_RFCFN) == false))
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
                                LogFile.WriteLog("슬리터 실적 등록(폐품) - SAP 확정문서 등록 오류 [" + helper.RSMSG.ToString() + "]");
                                sMSG_ERR += "확정문서 등록(폐품) 오류 : " + helper.RSMSG.ToString() + Environment.NewLine;
                                //new POPUP.MessageForm("실적 등록(폐품) - SAP 확정문서 등록 오류\r\n" + helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                throw new Exception("SAP_ERROR " + sMSG_ERR);  // SAP 로직 진행중 E 발생시 EXCEPTION THROW
                            }
                        }
                        else //SAP 에러
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

                            bReturn2 = false;
                            //helper.Rollback();
                            LogFile.WriteLog("슬리터 실적 등록(폐품) - SAP전송 오류 [" + sapRFC_D.rtnMSG + "]");
                            sMSG_ERR += "실적 등록(폐품) 오류 : " + sapRFC_D.rtnMSG + Environment.NewLine;
                            //new POPUP.MessageForm("밀롤 실적 등록(폐품) - SAP전송이 실패하였습니다.\r\n" + sapRFC_D.rtnMSG, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                            throw new Exception("SAP_ERROR " + sMSG_ERR);  // SAP 로직 진행중 E 발생시 EXCEPTION THROW
                        }
                        Thread.Sleep(Common.SLEEP_DELAY);
                        System.Windows.Forms.Application.DoEvents();        // 반복작업중 응답없음 안뜨게 하기
                        this.Cursor = Cursors.WaitCursor;   //Waitting
                    }

                    // 3. 잔량 폐품 등록
                    if ((bReturn1 == true) && (string.IsNullOrEmpty(sRS_SDISPO_RFCFN) == false))
                    {
                        SAPHelper sapRFC_SD = new SAPHelper();
                        // sapRFC.CallSAPFunc_PS 호출시 helper를 사용하여 내용이 변경됨. 
                        // 필요한 정보는 sapRFC.CallSAPFunc_PS 호출전에 처리해야함.
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
                            else if (helper.RSCODE == "E")
                            {
                                bRetSALES_DISPO = false;
                                //helper.Rollback();
                                //new POPUP.MessageForm("실적 등록 오류\r\n" + helper.RSMSG, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                LogFile.WriteLog("슬리터 실적 등록(잔량폐품) - SAP 확정문서 등록 오류 [" + helper.RSMSG.ToString() + "]");
                                sMSG_ERR += "확정문서 등록(잔량 폐품) 오류 : " + helper.RSMSG.ToString() + Environment.NewLine;
                                //new POPUP.MessageForm("실적 등록(영업폐품) - SAP 확정문서 등록 오류\r\n" + helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                throw new Exception("SAP_ERROR " + sMSG_ERR);

                            }
                        }
                        else
                        {
                            bRetSALES_DISPO = false;
                            //helper.Rollback();

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

                            LogFile.WriteLog("슬리터 실적 등록(잔량폐품) - SAP전송 오류 [" + sapRFC_SD.rtnMSG + "]");
                            sMSG_ERR += "실적 등록(잔량 폐품) 오류 : " + sapRFC_SD.rtnMSG + Environment.NewLine;
                            //new POPUP.MessageForm("실적 등록(영업폐품) - SAP전송이 실패하였습니다.\r\n" + sapRFC_SD.rtnMSG, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                            throw new Exception("SAP_ERROR " + sMSG_ERR);
                        }
                        Thread.Sleep(Common.SLEEP_DELAY);
                        System.Windows.Forms.Application.DoEvents();        // 반복작업중 응답없음 안뜨게 하기
                        this.Cursor = Cursors.WaitCursor;   //Waitting
                    }

                    // 4. 투입량 등록
                    if ((bReturn1 == true) && (string.IsNullOrEmpty(sRS_INPUT_RFCFN) == false))
                    {
                        bReturn3 = false;

                        // 문서번호, 문서순번으로  테이블 SORT 하여 전달
                        DataTable dtRFCData = new DataTable();
                        DataView dvPFRM = new DataView(dsTemp.Tables[5]);
                        dvPFRM.Sort = "MDOCNO, MDOCSEQ ASC";
                        dtRFCData = dvPFRM.ToTable();

                        SAPHelper sapRFC_I = new SAPHelper();
                        // sapRFC.CallSAPFunc_PS 호출시 helper를 사용하여 내용이 변경됨. 
                        // 필요한 정보는 sapRFC.CallSAPFunc_PS 호출전에 처리해야함.
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
                                bReturn3 = true;
                            }
                            else if (helper.RSCODE == "E")
                            {
                                bReturn3 = false;
                                //helper.Rollback();
                                //new POPUP.MessageForm(helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                LogFile.WriteLog("슬리터 실적 등록(투입량) - SAP 확정문서 등록 오류 [" + helper.RSMSG.ToString() + "]");
                                sMSG_ERR += "확정문서 등록(투입량) 오류 : " + helper.RSMSG.ToString() + Environment.NewLine;
                                //new POPUP.MessageForm("실적 등록(투입량) - SAP 확정문서 등록 오류\r\n" + helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                throw new Exception("SAP_ERROR " + sMSG_ERR);
                            }
                        }
                        else
                        {
                            bReturn3 = false;

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

                            //helper.Rollback();
                            LogFile.WriteLog("슬리터 실적 등록(투입량) - SAP전송 오류 [" + sapRFC_I.rtnMSG + "]");
                            sMSG_ERR += "실적 등록(투입량) 오류 : " + sapRFC_I.rtnMSG + Environment.NewLine;
                            //new POPUP.MessageForm("실적 등록(투입량) - SAP전송이 실패하였습니다.\r\n" + sapRFC_I.rtnMSG, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                            throw new Exception("SAP_ERROR " + sMSG_ERR);
                        }
                        System.Windows.Forms.Application.DoEvents();        // 반복작업중 응답없음 안뜨게 하기
                        this.Cursor = Cursors.WaitCursor;   //Waitting
                    }

                    //if (bReturn1 == true)
                    {
                        //helper.Commit();

                        if (lblPrintChk.Text.ToString() == "V")     // 자동인쇄 처리
                        {
                            //new POPUP.MessageForm("슬리터 개별바코드 [" + sRES_IND_BCD + "]", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                            this.Cursor = Cursors.WaitCursor;

                            int nPrtCnt = ucPNT_CNT.SelectedIndex + 1;

                            PrinterManager.PrintSliter(sRES_IND_BCD, nPrtCnt);

                            this.Cursor = Cursors.Default;
                        }

                        if (sMSG_ERR.Length > 0)
                        {
                            throw new Exception("SAP_ERROR " + sMSG_ERR);
                            //new POPUP.MessageForm(sMSG_ERR, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                        }
                        else
                        {
                            RET_CODE = Common.ERROR_SUCCESS;

                            new POPUP.MessageForm("실적등록 완료 되었습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                        }
                    }
                    //else
                    //{
                    //    //helper.Rollback();
                    //}
                }
                else //if (helper.RSCODE == "E")
                {
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
                    SetMessagePos("오류 발생하여 롤백 처리중 입니다.");
                    System.Windows.Forms.Application.DoEvents();        // 반복작업중 응답없음 안뜨게 하기

                    ProdRollback(helper, sapTemp, rollTemp, dsTemp, ref sMSG_ERR);
                }

                this.Cursor = Cursors.Default;

                LogFile.WriteLog("슬리터 실적등록 예외 오류 [" + ex.ToString() + "]");
                new POPUP.MessageForm_ERR("실적등록 오류", "실적등록 예외 오류\r\n" + ex.Message.ToString() + Environment.NewLine + sMSG_ERR, MessageBoxButtons.OK).ShowDialog(this);

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
                // 1.4 잔량폐품 인터페이스
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
                    System.Windows.Forms.Application.DoEvents();        // 반복작업중 응답없음 안뜨게 하기

                    foreach (DataRow Rows in sapTemp.Rows)
                    {
                        LogFile.WriteLog("=====SAP ROLLBACK START=====", LogType.PROC);
                        switch (Rows["SAP_TYPE"].ToString())
                        {
                            // 2.3  실적 ROLLBACK
                            case "3.PROD_REG_SAP": // 생산실적 롤백
                                LogFile.WriteLog("=====3.PROD_REG_SAP=====" + Rows["MDOCNO"].ToString() + "-" + Rows["MDOCSEQ"].ToString(), LogType.PROC);
                                dsTemp = helper.FillDataSetN("SP_POP_WRK28_IFR01", CommandType.StoredProcedure, 2
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
                                        LogFile.WriteLog("슬리터 실적등록 ROLLBACK COMPLETE", LogType.PROC);
                                    }
                                    else //if (helper.RSCODE == "E")
                                    {
                                        LogFile.WriteLog("슬리터 ROLLBACK 등록 - SAP 확정문서 등록 오류 [" + helper.RSMSG.ToString() + "]");
                                    }

                                    // DELAY 
                                    Thread.Sleep(Common.SLEEP_DELAY);
                                    System.Windows.Forms.Application.DoEvents();        // 반복작업중 응답없음 안뜨게 하기
                                }
                                else
                                {
                                    LogFile.WriteLog("슬리터 ROLLBACK 오류 - SAP전송 오류 [" + sapRFC_1.rtnMSG + "]");
                                    sMSG_ERR += "슬리터 ROLLBACK 오류 : " + sapRFC_1.rtnMSG + Environment.NewLine;
                                }
                                break;
                            // 2.2  생산폐품 ROLLBACK
                            case "2.SALV_REG_SAP": // 생산폐품 롤백
                                LogFile.WriteLog("=====2.SALV_REG_SAP=====" + Rows["MDOCNO"].ToString() + "-" + Rows["MDOCSEQ"].ToString(), LogType.PROC);
                                dsTemp = helper.FillDataSetN("SP_POP_WRK28_IFR02", CommandType.StoredProcedure, 2
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
                                    , helper.CreateParameter("P_WRK_TYPE", "1", DbType.String, ParameterDirection.Input)                        // '0'= 실적테이블, 비계획생산, '1'= 폐품테이블, '2'=소요량, '3'=비가동,
                                    , helper.CreateParameterOracle("P_RFC_DATA", rsRfcData, OracleDbType.Clob, ParameterDirection.Input)
                                    , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input));

                                    if (helper.RSCODE == "S")
                                    {
                                        LogFile.WriteLog("슬리터 생산폐품 ROLLBACK COMPLETE", LogType.PROC);

                                    }
                                    else //if (helper.RSCODE == "E")
                                    {
                                        LogFile.WriteLog("슬리터 ROLLBACK 등록 - SAP 확정문서 등록 오류 [" + helper.RSMSG.ToString() + "]");

                                    }

                                    // DELAY 
                                    Thread.Sleep(Common.SLEEP_DELAY);
                                    System.Windows.Forms.Application.DoEvents();        // 반복작업중 응답없음 안뜨게 하기
                                }
                                else
                                {
                                    LogFile.WriteLog("슬리터 ROLLBACK 오류 - SAP전송 오류 [" + sapRFC_2.rtnMSG + "]");
                                    sMSG_ERR += "슬리터 ROLLBACK 오류 : " + sapRFC_2.rtnMSG + Environment.NewLine;
                                }
                                break;
                            // 2.1  잔량폐품 ROLLBACK
                            case "1.SALE_SALV_REG_SAP": // 잔량 롤백
                                LogFile.WriteLog("=====1.SALE_SALV_REG_SAP=====" + Rows["MDOCNO"].ToString() + "-" + Rows["MDOCSEQ"].ToString(), LogType.PROC);
                                dsTemp = helper.FillDataSetN("SP_POP_WRK28_IFR03", CommandType.StoredProcedure, 2
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
                                    , helper.CreateParameter("P_WRK_TYPE", "9", DbType.String, ParameterDirection.Input)                        // '0'= 실적테이블, 비계획생산, '1'= 폐품테이블, '2'=소요량, '3'=비가동,
                                    , helper.CreateParameterOracle("P_RFC_DATA", rsRfcData, OracleDbType.Clob, ParameterDirection.Input)
                                    , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input));

                                    if (helper.RSCODE == "S")
                                    {
                                        LogFile.WriteLog("슬리터 영업페품 ROLLBACK COMPLETE", LogType.PROC);

                                    }
                                    else //if (helper.RSCODE == "E")
                                    {
                                        LogFile.WriteLog("슬리터 ROLLBACK 등록 - SAP 확정문서 등록 오류 [" + helper.RSMSG.ToString() + "]");

                                    }
                                    // DELAY 
                                    Thread.Sleep(Common.SLEEP_DELAY);
                                    System.Windows.Forms.Application.DoEvents();        // 반복작업중 응답없음 안뜨게 하기
                                }
                                else
                                {
                                    LogFile.WriteLog("슬리터 ROLLBACK 오류 - SAP전송 오류 [" + sapRFC_3.rtnMSG + "]");
                                    sMSG_ERR += "슬리터 ROLLBACK 오류 : " + sapRFC_3.rtnMSG + Environment.NewLine;
                                }
                                break;
                            // 2.4  투입량 ROLLBACK
                            case "4.WIP_REG_SAP":     // 투입량 롤백
                                if (gsWODIV == "예외")
                                {
                                    rProcedure = "SP_POP_WRK28_IFR04_EX";
                                }
                                else
                                {
                                    rProcedure = "SP_POP_WRK28_IFR04";
                                }
                                LogFile.WriteLog("=====4.WIP_REG_SAP=====" + Rows["MDOCNO"].ToString() + "-" + Rows["MDOCSEQ"].ToString(), LogType.PROC);

                                dsTemp = helper.FillDataSetN(rProcedure, CommandType.StoredProcedure, 2
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
                                    , helper.CreateParameter("P_WRK_TYPE", "2", DbType.String, ParameterDirection.Input)                        // '0'= 실적테이블, 비계획생산, '1'= 폐품테이블, '2'=소요량, '3'=비가동,
                                    , helper.CreateParameterOracle("P_RFC_DATA", rsRfcData, OracleDbType.Clob, ParameterDirection.Input)
                                    , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input));

                                    if (helper.RSCODE == "S")
                                    {
                                        LogFile.WriteLog("슬리터 투입량 ROLLBACK COMPLETE", LogType.PROC);

                                    }
                                    else //if (helper.RSCODE == "E")
                                    {
                                        LogFile.WriteLog("슬리터 ROLLBACK 등록 - SAP 확정문서 등록 오류 [" + helper.RSMSG.ToString() + "]");

                                    }
                                }
                                else
                                {
                                    LogFile.WriteLog("슬리터 ROLLBACK 오류 - SAP전송 오류 [" + sapRFC_4.rtnMSG + "]");
                                    sMSG_ERR += "슬리터 ROLLBACK 오류 : " + sapRFC_4.rtnMSG + Environment.NewLine;
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
                        mProcedure = "SP_POP_WRK28_R01_EX";
                    }
                    else
                    {
                        mProcedure = "SP_POP_WRK28_R01";
                    }

                    helper.Commit();

                    if (rollTemp.Rows.Count != 0)
                    {
                        foreach (DataRow Rows in rollTemp.Rows)
                        {
                            LogFile.WriteLog("=====MES ROLLBACK START=====" + Rows["MDOCNO"].ToString() + "-" + Rows["MDOCSEQ"].ToString(), LogType.PROC);
                            helper.ExecuteNoneQuery(mProcedure, CommandType.StoredProcedure
                           , helper.CreateParameter("P_DOC_NO", Rows["MDOCNO"].ToString(), DbType.String, ParameterDirection.Input)
                           , helper.CreateParameter("P_DOC_SEQNO", Rows["MDOCSEQ"].ToString(), DbType.String, ParameterDirection.Input)
                           , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input));
                            LogFile.WriteLog("=====MES ROLLBACK END=====" + Rows["MDOCNO"].ToString() + "-" + Rows["MDOCSEQ"].ToString(), LogType.PROC);
                        }
                    }
                    sMSG_ERR += "슬리터 MES ROLLBACK 실적이 취소되었습니다" + Environment.NewLine;
                    LogFile.WriteLog("수재단 MES ROLLBACK COMPLETE", LogType.PROC);

                }
                catch (Exception ex1)
                {
                    LogFile.WriteLog("슬리터 MES ROLLBACK 오류 [" + ex1.Message.ToString() + "]");
                    sMSG_ERR += "슬리터 MES ROLLBACK 오류 : " + ex1.Message.ToString() + Environment.NewLine;
                }
            }
        }





        private DataTable setReqWorkList(string sSRCOM_YN, string sMRCOM_YN, string sStartDate, string sEndDate, string sTM)
        {
            DataTable dtRtn = new DataTable();
            DataRow dtTempRow;
            DataTable dt = (DataTable)Grid2.DataSource;

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
                dtRtn.Columns.Add(new DataColumn("MRCOM_YN", typeof(string)));          //밀롤 완료여부
                dtRtn.Columns.Add(new DataColumn("SLITTERCOM_YN", typeof(string)));     //슬리터 완료여부
                dtRtn.Columns.Add(new DataColumn("IND_BCD_M", typeof(string)));         //밀롤 개별바코드 (투입정보)
                dtRtn.Columns.Add(new DataColumn("MATRN_M", typeof(string)));           //밀롤 자재코드   (투입정보)
                dtRtn.Columns.Add(new DataColumn("LOT_NO_M", typeof(string)));          //밀롤 LOT번호    (투입정보)


                bool bInpLogWrite = false;
                string sValue;
                for (int i = 0; i < dt.Rows.Count; i++)
                {
                    //선택된 행처리
                    if (dt.Rows[i]["CHK"].ToString().Equals("V"))
                    {
                        //조회결과 입력용 Row생성
                        dtTempRow = dtRtn.NewRow();

                        //슬리터 중량
                        int nMWIDTH = 0;            // 지폭
                        Decimal dWGT = 0;          // 슬리터 중량
                        Decimal dDISPO_WGT = 0;    // 슬리터 폐품 중량

                        string sMWIDTH = dt.Rows[i]["MWIDTH"].ToString().Replace(",", "");

                        if (int.TryParse(sMWIDTH, out nMWIDTH) == true)
                        {
                            // 평량 > 0 && 권치수 > 0
                            if ((giBS_WGT > 0) && (gdROLLCNT > 0))
                            {
                                dWGT = ((Decimal)giBS_WGT / 1000) * ((Decimal)nMWIDTH / 1000) * (Decimal)gdROLLCNT;
                                dWGT = Math.Round(dWGT);
                            }

                            if ((giBS_WGT > 0) && (gdDISPO_ROLLCNT > 0))
                            {
                                dDISPO_WGT = ((Decimal)giBS_WGT / 1000) * ((Decimal)nMWIDTH / 1000) * (Decimal)gdDISPO_ROLLCNT;
                            }
                        }

                        dtTempRow["WRK_ORDR_NO"] = dt.Rows[i]["WRK_ORDR_NO"].ToString();            //작업지시번호

                        sValue = dt.Rows[i]["WRK_ORDR_SEQNO"].ToString().Trim();
                        dtTempRow["WRK_ORDR_SEQNO"] = string.IsNullOrEmpty(sValue) ? "0" : sValue;  //작업지시번호순번

                        sValue = dt.Rows[i]["R_WIDTH"].ToString().Trim().Replace(",", "");
                        if (string.IsNullOrEmpty(sValue))
                        {
                            sValue = dt.Rows[i]["MWIDTH"].ToString().Trim().Replace(",", "");
                        }
                        dtTempRow["WIDTH"] = string.IsNullOrEmpty(sValue) ? "0" : sValue;           //생산실지폭
                        //dtTempRow["WIDTH"] = dt.Rows[i]["R_WIDTH"].ToString();                    //생산실지폭

                        dtTempRow["WIDTH_NO"] = dt.Rows[i]["WIDTH_NO"].ToString().Trim().Replace(",", "");           //지폭순번

                        sValue = dt.Rows[i]["PRD_SEQ"].ToString().Trim();
                        dtTempRow["PRD_SEQ"] = string.IsNullOrEmpty(sValue) ? "0" : sValue;         //실적순서

                        dtTempRow["MRLDCK"] = "N";                                                  //밀롤적치여부
                        dtTempRow["CUTTER"] = "";                                                   //재단
                        dtTempRow["ROLLCNT"] = string.Format("{0}", (int)gdROLLCNT);                //실적권치수
                        dtTempRow["WGT"] = string.Format("{0:0.###}", dWGT);                        //슬리터별 중량
                        dtTempRow["DISPO_CD"] = lblPF_DISPO_CODE.Tag;                               //폐품코드
                        dtTempRow["DISPO_ROLLCNT"] = string.Format("{0}", (int)gdDISPO_ROLLCNT);    //폐품권치수
                        dtTempRow["DISPO_WGT"] = string.Format("{0:0.###}", dDISPO_WGT);            //슬리터별 폐품중량
                        dtTempRow["CORE"] = Common.StrFormatInteger((string)ucCORE.Items[ucCORE.SelectedIndex].DataValue, "{0:###}");           //지관
                        dtTempRow["PRD_STR_DATE"] = sStartDate;                                     //작업시작일시
                        dtTempRow["PRD_END_DATE"] = sEndDate;                                       //작업종료일시
                        dtTempRow["TM"] = sTM;                                                      //가동시간(분)
                        dtTempRow["RMK"] = lblPF_WRK_ORDR_RMK.Text.ToString();                      //비고
                        dtTempRow["MRCOM_YN"] = sMRCOM_YN;                                          //밀롤 완료여부
                        dtTempRow["SLITTERCOM_YN"] = sSRCOM_YN;                                     //슬리터 완료여부
                        dtTempRow["IND_BCD_M"] = Grid1.Row.Cells["IND_BCD"].Value.ToString();       //점보롤 개별바코드
                        dtTempRow["MATRN_M"] = Grid1.Row.Cells["MATNR"].Value.ToString();           //점보롤 자재코드
                        dtTempRow["LOT_NO_M"] = Grid1.Row.Cells["LOT_NO"].Value.ToString();         //점보롤 LOT번호

                        // 투입된 반제품 정보
                        if (bInpLogWrite == false)
                        {
                            LogFile.WriteLog(string.Format("[밀롤 정보] IND_BCD_M = {0}, MATNR_M = {1}, LOT_NO_M = {2}",
                                                                        Grid1.Row.Cells["IND_BCD"].Value.ToString(),
                                                                        Grid1.Row.Cells["MATNR"].Value.ToString(),
                                                                        Grid1.Row.Cells["LOT_NO"].Value.ToString()),
                                                                        LogType.PROC);
                            bInpLogWrite = true;
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
                bBox1[0, 9].Text = ""; // "자재투입이력";
                bBox1[0, 9].Tag = ""; // "InputLog";
                bBox1[0, 9].MappingButton.FontSize = 14;
                bBox1[0, 10].Text = "실적현황";
                bBox1[0, 10].Tag = "Performance";
                bBox1[0, 10].MappingButton.FontSize = 14;

                bBox1.RedrawButtons();
            }
            catch (Exception ex)
            {
                SetMessage("SetButtons Error!");
                LogFile.WriteLog("POP_WRK28.SetMenuButtons Error => " + ex.Message);
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
                            isRefresh = true;
                            this.lblTitle.Text = "슬리터 실적등록";
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
                            popWrk35.LabelTitle = "슬리터 폐품사유";

                            if (ShowDialogForm(popWrk35) == DialogResult.OK)
                            {
                                lblPF_DISPO_CODE.Tag = popWrk35.DispoCode;
                                lblPF_DISPO_CODE.Text = popWrk35.DispoName;
                                CheckValue(lblPF_CHK_DISPO, "V");
                                lblPF_CHK_DISPO.Visible = true;
                                lblPF_DISPO_ROLLCNT.Enabled = true;
                                lblPF_DISPO_ROLLCNT.BackColor = Color.White;
                                lblPF_DISPO_CODE_NAME.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
                            }
                            isRefresh = false;
                        }
                        break;
                    case "Input": //슬리터공정투입
                        POP_WRK01 WRK01 = new POP_WRK01(POP_WRK01.LOC_SA_2200);
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
                LogFile.WriteLog("POP_WRK28.bBox1_buttonClickEvent Error => " + ex.Message);
            }
            finally
            {
            }
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
            if (pType.Contains("O") && string.IsNullOrEmpty(lblIN_MLOT_NO.Text.ToString()))
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

        #endregion

        #region FUNCTION

        /// <summary>
        /// 생산실적일자, 가동시간
        /// </summary>
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
                    lblPF_PRFM_DT.Text = "";   // 생산실적일자
                }
            }
            catch (Exception ex)
            {
                LogFile.WriteLog("슬리터 AutoCalculation Error => " + ex.Message);
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
            // 평량 > 0 || 슬리터 지폭합 > 0 || 권치수 > 0
            if (giBS_WGT <= 0 || giMWIDTH_SUM <= 0 || gdROLLCNT <= 0)
            {
                lblPF_WGT.Text = string.Empty;
                return;
            }

            //decimal dValue = ((decimal)giBS_WGT / 1000) * ((decimal)giMWIDTH_SUM / 1000) * (decimal)gdROLLCNT;
            //lblPF_WGT.Text = string.Format("{0:#,0.###}", dValue);

            Decimal dTotValue = 0;
            foreach (UltraGridRow ugr in Grid2.Rows)
            {
                if (ugr.Cells["CHK"].Value.ToString().Equals("V"))
                {
                    Decimal dValue = 0;
                    int nMWIDTH = 0;

                    string sMWIDTH = ugr.Cells["MWIDTH"].Value.ToString().Replace(",", "");

                    if (int.TryParse(sMWIDTH, out nMWIDTH) == true)
                    {
                        dValue = ((Decimal)giBS_WGT / 1000) * ((Decimal)nMWIDTH / 1000) * (Decimal)gdROLLCNT;

                        dValue = Math.Round(dValue);

                        dTotValue += dValue;
                    }
                }
            }

            lblPF_WGT.Text = string.Format("{0:#,0.###}", dTotValue);
        }

        // 폐품 중량 계산
        private void DispoWgtCalculation()
        {
            // 평량 > 0 || 슬리터 지폭합 > 0 || 폐품권치수 > 0
            if (giBS_WGT <= 0 || giMWIDTH_SUM <= 0 || gdDISPO_ROLLCNT <= 0)
            {
                lblPF_DISPO_WGT.Text = string.Empty;
                return;
            }

            decimal dValue = ((decimal)giBS_WGT / 1000) * ((decimal)giMWIDTH_SUM / 1000) * (decimal)gdDISPO_ROLLCNT;
            lblPF_DISPO_WGT.Text = string.Format("{0:#,0.###}", dValue);
        }

        private void CheckValue(SmartDas.Components.MESLabel mLavel, string sVlaue)
        {
            mLavel.Text = sVlaue;

            if (string.IsNullOrEmpty(mLavel.Text.Trim()))
                mLavel.BackColor = Color.White;
            else
                mLavel.BackColor = Color.Yellow;
        }

        private bool CheckProdQty()
        {
            decimal dABLE_ROLLCNT = 0;
            decimal dProdCNT = 0;   // 입력권치수(실적)
            decimal dDispCNT = 0;   // 입력권치수(폐품)

            decimal.TryParse(lblIN_AVA_CNT.Text.Replace(",", ""), out dABLE_ROLLCNT);
            decimal.TryParse(lblPF_ROLLCNT.Text.Replace(",", ""), out dProdCNT);
            decimal.TryParse(lblPF_DISPO_ROLLCNT.Text.Replace(",", ""), out dDispCNT);

            if (dABLE_ROLLCNT < (dProdCNT + dDispCNT))
            {
                new POPUP.MessageForm("입력권치수(실적+폐품 권치수)가 가용권치수보다 큽니다.\n\r"
                                        + "가용권치수 : " + lblIN_AVA_CNT.Text + "\n\r"
                                        + "실적권치수 : " + lblPF_ROLLCNT.Text + "\n\r"
                                        + "폐품권치수 : " + lblPF_DISPO_ROLLCNT.Text, MessageBoxButtons.OK, "알   림").ShowDialog(this);

                return false;
            }

            return true;
        }

        #region 바코드 라벨 테스트
        // 제브라 라벨 바코드 인쇄 - 슬리터
        private void PrintSlitter(string sRES_IND_BCD)
        {
            string PrinterName = "ZT421";
            string sZPL = string.Empty;
            //제목(PRODUCT)
            string sTitle = string.Empty;
            //생산정보(일자, 호기)
            string sPRD_DT = string.Empty;
            string sMACH_NM = string.Empty;
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
            ////생산정보(일자, 호기)
            //sPRD_DT = dtTemp.Rows[0]["PRFM_DT"].ToString();
            //sMACH_NM = dtTemp.Rows[0]["MACH_NM"].ToString();
            ////제품정보(종류, 코드, 명, KAN, 기본단위, 파렛트단위, LOT)
            //sMATNR_DIV = "KT";
            //sMATNR = dtTemp.Rows[0]["MATNR"].ToString();
            //sMATNR_NM = dtTemp.Rows[0]["MATNR_NM"].ToString();
            //sKAN_CD = dtTemp.Rows[0]["KAN_CD"].ToString();
            //sBS_UNIT = dtTemp.Rows[0]["BAG2BOX"].ToString();
            //sPLT_UNIT = dtTemp.Rows[0]["BOX2PLT"].ToString();
            //sLOT_NO = dtTemp.Rows[0]["LOT_NO"].ToString();
            ////바코드
            //sINDBCD = dtTemp.Rows[0]["IND_BCD"].ToString();

            DBHelper helper = new DBHelper(false);
            try
            {
                //ZPL코드 프로시저 호출
                helper.ExecuteNoneQuery("SP_INV_ZPL_PS", CommandType.StoredProcedure
                 , helper.CreateParameter("P_TYPE", "", DbType.String, ParameterDirection.Input) //라벨종류
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
                //new POPUP.MessageForm("라벨이 출력되었습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
            }
            catch (Exception ex)
            {
                LogFile.WriteLog("POP_WRK28.doPrint Error => " + ex.Message);
            }
            finally
            {
                helper.Close();
            }
        }


        #endregion

        #endregion

        private void btnCancel_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        private void dtpDate_DropDown(object sender, EventArgs e)
        {
            CommonCalendar.CloseCalendar((DateTimePicker)sender);
            lblPF_ROLLCNT.Focus();
        }

        private void lblPF_CHK_DISPO_Click(object sender, EventArgs e)
        {
            InitDISPO();
        }

        private void lblPrintChk_Click(object sender, EventArgs e)
        {
            if (lblPrintChk.Text.ToString().Equals("V"))
                CheckValue(lblPrintChk, string.Empty);
            else
                CheckValue(lblPrintChk, "V");
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

        private void ucCORE_ValueChanged(object sender, EventArgs e)
        {
            lblPF_ROLLCNT.Focus();
        }

        private void lblPF_ROLLCNT_Click(object sender, EventArgs e)
        {
            if (gsgrid2CHK == "N")
            {
                new POPUP.MessageForm("작업지시를 먼저 선택하세요", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return;
            }

            DAResultQty pop = new DAResultQty();
            pop.LabelTitle = "슬리터 실적 입력";
            pop.LabelHeader = "슬리터실적(M)";
            pop.ContentMaxLength = 8;

            pop.ShowDialog(this);

            if (pop.DialogResult == DialogResult.OK)
            {
                gdROLLCNT = Convert.ToDecimal(pop.ResultDouble);
                gdDISPO_ROLLCNT = decimal.TryParse(lblPF_DISPO_ROLLCNT.Text, out gdDISPO_ROLLCNT) ? gdDISPO_ROLLCNT : 0;

                lblPF_ROLLCNT.Text = string.Format("{0:#,0}", gdROLLCNT);
                //실적중량계산
                WgtCalculation();
            }
        }

        private void lblPF_WRK_ORDR_RMK_Click(object sender, EventArgs e)
        {
            DAResultText pop = new DAResultText("슬리터 비고 입력", lblPF_WRK_ORDR_RMK.Text.ToString());
            pop.ContentMaxLength = 100;

            pop.ShowDialog(this);
            if (pop.DialogResult == DialogResult.OK)
            {
                lblPF_WRK_ORDR_RMK.Text = pop.ResultString;
            }
        }

        private void lblPF_DISPO_ROLLCNT_Click(object sender, EventArgs e)
        {
            if (gsgrid2CHK == "N")
            {
                new POPUP.MessageForm("작업지시를 먼저 선택하세요", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return;
            }

            DAResultQty pop = new DAResultQty();
            pop.LabelTitle = "슬리터폐품 입력";
            pop.LabelHeader = "슬리터폐품(M)";
            pop.ContentMaxLength = 8;

            pop.ShowDialog(this);

            if (pop.DialogResult == DialogResult.OK)
            {
                gdDISPO_ROLLCNT = Convert.ToDecimal(pop.ResultDouble);
                gdROLLCNT = Decimal.TryParse(lblPF_ROLLCNT.Text, out gdROLLCNT) ? gdROLLCNT : 0;

                lblPF_DISPO_ROLLCNT.Text = string.Format("{0:#,0}", gdDISPO_ROLLCNT);
                //폐품중량계산
                DispoWgtCalculation();
            }
        }

        private void Grid1_GridSelectChanged(object sender, AfterSelectChangeEventArgs e)
        {
            if (typeof(UltraGridRow) == e.Type)
            {
                if (Grid1.Rows.Count < 1)
                {
                    return;
                }

                if (Grid1.Row == null)
                {
                    return;
                }

                // 투입정보중량표시, 비고 표시
                SetGrid02();
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

                //권치수 표시
                DoFind02();

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
                //popWrk84.LabelTitle = "작업지시 정보";
                ShowDialogForm(popWrk84);
            }
        }

        private void btnMRDetail_Click(object sender, EventArgs e)
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
            POP_WRK84 popWrk84 = new POP_WRK84(POP_WRK84.PROC_INP, Common.PlantCode, Common.OpCode, Common.WrkOrderNo, Common.WrkOrderSeq, sIND_BCD);  // 작업지시 정보
            //popWrk84.LabelTitle = "작업지시 정보";
            ShowDialogForm(popWrk84);
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

        private void lblSEndChk_Click(object sender, EventArgs e)
        {
            if (lblSEndChk.Text.ToString().Equals("V"))
                CheckValue(lblSEndChk, string.Empty);
            else
                CheckValue(lblSEndChk, "V");
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
