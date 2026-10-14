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
using System.Globalization;
using System.Threading;
using System.Drawing;
using System.Linq;
using QRCoder;
#endregion

namespace SmartDas
{
    public partial class POP_WRK30 : BaseForm
    {
        string strLocalPath = Application.ExecutablePath.Substring(0, Application.ExecutablePath.LastIndexOf('\\'));

        #region < MEMBER AREA >
        private string sStartTime = string.Empty;

        private SAMMI.Common _common = new SAMMI.Common();

        public static string userID = string.Empty;
        public static string userName = string.Empty;
        private string gsOP_CODE = string.Empty;
        private string gsMACH_CD = string.Empty;
        private string gsRESULT = "NG";         // 취소 최종 결과
        private string gsGB = string.Empty;     // 지시구분 ( '' , 계획, 예외, 등등 )
        private bool gsPACK_PART = false;     // 포장파트인지 확인
        #endregion

        #region < CONSTRUCTOR >

        public POP_WRK30()
        {
            InitializeComponent();

            Common.SetMessageList();

            gsOP_CODE = Common.OpCode;
            gsMACH_CD = Common.MachineCode;
        }

        public POP_WRK30(string OP_CODE, string MACH_CD)
        {
            InitializeComponent();

            Common.SetMessageList();

            gsOP_CODE = OP_CODE;
            gsMACH_CD = MACH_CD;

            // 현재시간이 7시 이전 이면 .. 생산실적일자는 이전 날짜로 표시해야함.
        }
        #endregion

        #region < POP_WRK30_Load >
        private void POP_WRK30_Load(object sender, EventArgs e)
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

                this.lblTitle.Text = "실적 현황";
/*
                DateTime daysBefore = DateTime.Now;
                //daysBefore = daysBefore.AddDays(-7);
                cboWorkDate.Value = daysBefore;
*/

                DateTime dtTime;
                if (DateTime.TryParseExact(Common.gRecDate, "yyyyMMdd", null, DateTimeStyles.AssumeLocal, out dtTime))
                {
                    cboWorkStartDate.Value = cboWorkEndDate.Value = dtTime;
                }

                // 지종, 평량, 가로/세로 값이 있는 경우 Common 값 처리
                if (Common.PRFM_PCODE != "")            // 지종
                {
                    txtPCODE.Text = Common.PRFM_PCODE;
                }
                if (Common.PRFM_BSWGT != "")             // 평량
                {
                    txtBS_WGT.Text = Common.PRFM_BSWGT;
                }
                if (Common.PRFM_WIDTH != "")             // 가로
                {
                    txtWLEN.Text = Common.PRFM_WIDTH;
                }
                if (Common.PRFM_HEIGHT != "")             // 세로
                {
                    txtVLEN.Text = Common.PRFM_HEIGHT;
                }


                // 포장 파트 에서만 조회조건 저장
                //  PB : 자동포장, PC : 원지 포장, PD : 예외생산포장, ZA : 문제제품
                if (Common.OpCode == "PB" || Common.OpCode == "PC" || Common.OpCode == "PD" || Common.OpCode == "ZA")
                {
                    gsPACK_PART = true;

                    if (!string.IsNullOrEmpty(Common.PRFM_START_DATE))
                    {
                        if (DateTime.TryParseExact(Common.PRFM_START_DATE, "yyyyMMdd", null, DateTimeStyles.AssumeLocal, out dtTime))
                        {
                            cboWorkStartDate.Value = dtTime;
                        }
                    }

                    if (!string.IsNullOrEmpty(Common.PRFM_END_DATE))
                    {
                        if (DateTime.TryParseExact(Common.PRFM_END_DATE, "yyyyMMdd", null, DateTimeStyles.AssumeLocal, out dtTime))
                        {
                            cboWorkEndDate.Value = dtTime;
                        }
                    }
                }
                else
                {
                    gsPACK_PART = false;
                }

                //  PB : 자동포장, PC : 원지 포장, PD : 예외생산포장, ZA : 문제제품, CB : 수재단
                if (Common.OpCode == "PB" || Common.OpCode == "PC" || Common.OpCode == "PD" || Common.OpCode == "ZA" || Common.OpCode == "CB")
                {
                    // 콤보박스 초기화
                    lblPNT_CNT.Visible = true;
                    ucPNT_CNT.Visible = true;

                    lblLABEL_TYPE.Visible = true;
                    ucLABEL_TYPE.Visible = true;
                    pnlPRINT.Visible = true;

                    ucLABEL_TYPE.SelectedIndex = 1;
                    ucLABEL_TYPE.ValueList.ItemHeight = 70;

                    ucPNT_CNT.SelectedIndex = 1;
                    ucPNT_CNT.ValueList.ItemHeight = 70;

                    Grid1.Size = new System.Drawing.Size(1250, 641);
                }
                else if (Common.OpCode == "MA" || Common.OpCode == "SA")        // 밀롤, 슬리터
                {
                    ucPNT_CNT.Items.Clear();
                    if (Common.OpCode == "MA")
                    {
                        ucPNT_CNT.Size = new System.Drawing.Size(180, 40);
                        ucPNT_CNT.Items.Add("00", "Roll=2/Sheet=1");
                        ucPNT_CNT.Items.Add("01", "1 매");
                        ucPNT_CNT.Items.Add("02", "2 매");
                        ucPNT_CNT.Items.Add("03", "3 매");
                        ucPNT_CNT.Items.Add("04", "4 매");
                        ucPNT_CNT.Items.Add("05", "5 매");
                    }
                    else
                    {
                        ucPNT_CNT.Items.Add("01", "1 매");
                        ucPNT_CNT.Items.Add("02", "2 매");
                    }
                    ucPNT_CNT.SelectedIndex = 0;
                    ucPNT_CNT.ValueList.ItemHeight = 70;

                    lblPNT_CNT.Location = lblLABEL_TYPE.Location;
                    ucPNT_CNT.Location = ucLABEL_TYPE.Location;

                    lblPNT_CNT.Visible = true;
                    ucPNT_CNT.Visible = true;
                    pnlPRINT.Visible = true;

                    Grid1.Size = new System.Drawing.Size(1250, 641);
                }
                else
                {
                    pnlPRINT.Visible = false;
                    Grid1.Size = new System.Drawing.Size(1250, 691);
                }

                SetMenuButtons();

                if (gsPACK_PART == false)
                {
                    SetGrid();
                }

                if (Common.OpCode.Equals("JA"))
                {
                    lblWV.Visible = false;
                    txtWLEN.Visible = false;
                    txtVLEN.Visible = false;
                }
                else if (Common.OpCode.Equals("MA") || Common.OpCode.Equals("SA"))
                {
                    lblWV.Text = "지폭";
                    lblWV.Visible = true;
                    txtWLEN.Visible = true;
                }
                else
                {
                    lblWV.Visible = true;
                    txtWLEN.Visible = true;
                    txtVLEN.Visible = true;
                }
            }
            catch (Exception ex)
            {
                SetMessage("POP_WRK30_Load_ Error!");
                LogFile.WriteLog("POP_WRK30_Load Error => " + ex.Message);
            }
            
            //현재 메시지큐에 있는 모든 메시지 처리함수 
            //SendKeys.Flush();
        }

        private void POP_WRK30_Shown(object sender, EventArgs e)
        {
            try
            {
                if (gsPACK_PART == true)
                {
                    SetGrid();
                }
            }
            catch (Exception ex)
            {
                SetMessage("POP_WRK30_Shown Error!");
                LogFile.WriteLog("POP_WRK30_Shown Error => " + ex.Message);
            }
            finally
            {
                //현재 메시지큐에 있는 모든 메시지 처리함수 
                SendKeys.Flush();
            }
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

                if (gsOP_CODE.Equals("CA"))
                {
                    bBox1[0, 3].Text = "여유생산";  //"라벨병합";
                    bBox1[0, 3].Tag = "Spare";  //"Merge";
                    bBox1[0, 4].Text = "";  //"라벨병합" + Environment.NewLine + "취소";
                    bBox1[0, 4].Tag = "";  //"UnMerge";
                    bBox1[0, 5].Text = ""; // "여유생산";
                    bBox1[0, 5].Tag = "";   // "";
                    bBox1[0, 6].Text = "";
                    bBox1[0, 6].Tag = "";
                }
                else if (gsOP_CODE.Equals("PB") || gsOP_CODE.Equals("PC") || gsOP_CODE.Equals("ZA"))
                {
                    bBox1[0, 3].Text = "등급변경";
                    bBox1[0, 3].Tag = "Grade";
                    bBox1[0, 4].Text = "등급변경" + Environment.NewLine + "취소";
                    bBox1[0, 4].Tag = "UnGrade";
                    bBox1[0, 5].Text = "";
                    bBox1[0, 5].Tag = "";
                    bBox1[0, 6].Text = "";
                    bBox1[0, 6].Tag = "";
                }
                else
                {
                    bBox1[0, 3].Text = "";
                    bBox1[0, 3].Tag = "";
                    bBox1[0, 4].Text = "";
                    bBox1[0, 4].Tag = "";
                    bBox1[0, 5].Text = "";
                    bBox1[0, 5].Tag = "";
                    bBox1[0, 6].Text = "";
                    bBox1[0, 6].Tag = "";
                }
                bBox1[0, 0].Text = "라벨" + Environment.NewLine + "재발행";
                bBox1[0, 0].Tag = "Print";
                bBox1[0, 0].MappingButton.FontSize = 14;
                bBox1[0, 1].Text = "실적취소";
                bBox1[0, 1].Tag = "Delete";
                bBox1[0, 1].MappingButton.FontSize = 14;
                bBox1[0, 2].Text = "비고수정";
                bBox1[0, 2].Tag = "Remark";
                bBox1[0, 2].MappingButton.FontSize = 14;
                bBox1[0, 3].MappingButton.FontSize = 14;
                bBox1[0, 4].MappingButton.FontSize = 14;
                bBox1[0, 5].MappingButton.FontSize = 14;
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
                LogFile.WriteLog("POP_WRK30.SetButtons Error => " + ex.Message);
            }
        }

        private void SetGrid()
        {
            DBHelper helper = new DBHelper();
            string sColInfo = string.Empty;
            string sColType = string.Empty;

            DataSet dsTemp = new DataSet();
            DataTable dtRtn;
            DataTable dtTemp = new DataTable();
            DataRow rTemp = null;

            int pltCnt = 0;         // 팔렛트 수량
            float prfmQty = 0;        // 실적 수량

            string sSPRFM_DT = cboWorkStartDate.Value.ToString("yyyyMMdd");
            string sEPRFM_DT = cboWorkEndDate.Value.ToString("yyyyMMdd");

            // 지종, 평량, 가로/세로 값 Common 변수에 저장
            Common.PRFM_PCODE = txtPCODE.Text;
            Common.PRFM_BSWGT = txtBS_WGT.Text;
            Common.PRFM_WIDTH = txtWLEN.Text;
            Common.PRFM_HEIGHT = txtVLEN.Text;

            //// 포장 파트 에서만 조회조건 시작/종료 일시 저장
            if (gsPACK_PART == true)
            {
                Common.PRFM_START_DATE = sSPRFM_DT;
                Common.PRFM_END_DATE = sEPRFM_DT;
            }

            try
            {
                System.Windows.Forms.Application.DoEvents();        // 반복작업중 응답없음 안뜨게 하기
                this.Cursor = Cursors.WaitCursor;   //Waitting

                Grid1.HeaderFontSize = 11;
                Grid1.FontSize = 13;
                Grid1.CountRows = 12;
                Grid1.AutoScroll = true;
                Grid1.DisplayLayout.Scrollbars = Scrollbars.Automatic;
                Grid1.DisplayLayout.Bands[0].Override.SelectTypeCol = SelectType.None;
                btnRightPage.LinkMoveSize = Grid1.CountRows;
                btnLeftPage.LinkMoveSize = Grid1.CountRows;

                int nOUT = 0;
                string sBS_WGT = "";
                if (!string.IsNullOrEmpty(txtBS_WGT.Text))
                {
                    nOUT = 0;
                    int.TryParse(txtBS_WGT.Text, out nOUT);
                    sBS_WGT = nOUT <= 0 ? txtBS_WGT.Text : nOUT.ToString();            // 평량
                }

                string sWLEN = "";
                if (!string.IsNullOrEmpty(txtWLEN.Text))
                {
                    nOUT = 0;
                    int.TryParse(txtWLEN.Text, out nOUT);
                    sWLEN = nOUT <= 0 ? txtWLEN.Text : nOUT.ToString();                // 가로
                }

                string sVLEN = "";
                if (!string.IsNullOrEmpty(txtVLEN.Text))
                {
                    nOUT = 0;
                    int.TryParse(txtVLEN.Text, out nOUT);
                    sVLEN = nOUT <= 0 ? txtVLEN.Text : nOUT.ToString();                // 세로
                }


                //버튼 목록 조회
                dtRtn = helper.FillTable("SP_POP_WRK30_S01_V01", CommandType.StoredProcedure
                                                    , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)               // 플랜트코드
                                                    , helper.CreateParameter("P_PROC_CD", Common.OpCode, DbType.String, ParameterDirection.Input)                //공정코드 (JA, MA, CA, PB_PC ...)
                                                    , helper.CreateParameter("P_MACH_CD", gsMACH_CD, DbType.String, ParameterDirection.Input)                    //작업장코드(설비코드)
                                                    , helper.CreateParameter("P_SPRFM_DT", sSPRFM_DT, DbType.String, ParameterDirection.Input)                   // 생산실적 조회 시작일
                                                    , helper.CreateParameter("P_EPRFM_DT", sEPRFM_DT, DbType.String, ParameterDirection.Input)                   // 생산실적 조회 종료일
                                                    , helper.CreateParameter("P_ORDER_NO", txtORDER_NO.Text, DbType.String, ParameterDirection.Input)           // 오더번호
                                                    , helper.CreateParameter("P_IND_BCD", txtIND_BCD.Text, DbType.String, ParameterDirection.Input)             // 개별바코드
                                                    , helper.CreateParameter("P_PCODE", txtPCODE.Text, DbType.String, ParameterDirection.Input)                 // 지종
                                                    , helper.CreateParameter("P_BS_WGT", sBS_WGT, DbType.String, ParameterDirection.Input)                      // 평량
                                                    , helper.CreateParameter("P_WLEN", sWLEN, DbType.String, ParameterDirection.Input)                          // 가로길이
                                                    , helper.CreateParameter("P_VLEN", sVLEN, DbType.String, ParameterDirection.Input)                          // 세로길이
                                                    , helper.CreateParameter("P_USERNM", txtUSERNM.Text, DbType.String, ParameterDirection.Input)               // 작업자
                                                    , helper.CreateParameter("P_COLINFO", DbType.String, ParameterDirection.Output, null, 1000)
                                                    , helper.CreateParameter("P_COLTYPE", DbType.String, ParameterDirection.Output, null, 1000));

                //버튼 상태 변경
                if (helper.RSCODE.Equals("S"))
                {
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

                    if (dtRtn.Rows.Count > 1)
                    {
                        // 첫번째 행 선택
                        Grid1.Rows[0].Selected = true;
                        Grid1.Row = Grid1.Rows[0];
                    }


                    //sdoc 오류 
                    for (int i = 0; i < Grid1.Rows.Count; i++)
                    {
                        if (Grid1.Rows[i].Cells["SDOC_NO"].Value.ToString().Equals("E"))
                            Grid1.Rows[i].CellAppearance.BackColor = Color.Orange;

                        if (Common.OpCode == "JA" || Common.OpCode == "MA" || Common.OpCode == "SA")
                        {
                            prfmQty = prfmQty + float.Parse(Grid1.Rows[i].Cells["WGT"].Value.ToString());
                        } else if (Common.OpCode == "CA" || Common.OpCode == "CB")
                        {
                            prfmQty = prfmQty + float.Parse(Grid1.Rows[i].Cells["PRFM_QTY"].Value.ToString());
                        }
                        else
                        {
                            prfmQty = prfmQty + float.Parse(Grid1.Rows[i].Cells["PCNT"].Value.ToString());
                        }

                        if (Grid1.Rows[i].Cells["ORDER_NO"].Value.ToString() != "")
                        {
                            pltCnt++;
                        }
                    }
                    // 첫번째열 고정
                    Grid1.DisplayLayout.UseFixedHeaders = true;
                    Grid1.DisplayLayout.Bands[0].Columns["CHK"].Header.Fixed = true;
                    Grid1.DisplayLayout.Bands[0].Override.FixedHeaderIndicator = FixedHeaderIndicator.None;


                    txtPltCnt.Text = string.Format("{0:##,###}", pltCnt);
                    txtPrfmQty.Text = string.Format("{0:##,###.##}", prfmQty);
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
                LogFile.WriteLog("POP_WRK30.SetGrid Error => " + ex.Message);
            }
            finally
            {
                this.Cursor = Cursors.Default;   //Waitting
            }
        }

        private void doUnGradeConfirm(string sIND_BCD)
        {
            DBHelper helper = new DBHelper();
            DataTable dtRtn;

            try
            {
                //등급변경 취소 여부 및 취소할 개별 바코드 정보
                dtRtn = helper.FillTable("SP_POP_WRK37_S02", CommandType.StoredProcedure
                                                    , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)          // 플랜트코드
                                                    , helper.CreateParameter("P_MACH_CD", gsMACH_CD, DbType.String, ParameterDirection.Input)               //작업장코드(설비코드)
                                                    , helper.CreateParameter("P_IND_BCD", sIND_BCD, DbType.String, ParameterDirection.Input)                // 생산실적일자
                                                    );

                //버튼 상태 변경
                if (helper.RSCODE.Equals("S"))
                {
                    if (dtRtn.Rows.Count > 0)
                    {
                        string sGrdMsg = "";
                        for (int i = 0; i < dtRtn.Rows.Count; i++)
                        {
                            string ind_bcd = dtRtn.Rows[i]["IND_BCD"].ToString();
                            string wrk_type = dtRtn.Rows[i]["WRK_TYPE"].ToString();
                            string pcnt = dtRtn.Rows[i]["PCNT"].ToString();

                            sGrdMsg += string.Format("{0} / {1}R / {2}\r\n", ind_bcd, pcnt, (wrk_type == "1" ? "정상" : "폐품"));
                        }

                        sGrdMsg += "\r\n등급변경 취소 하시겠습니까?";

                        if (DialogResult.Yes == MessageBoxShow(sGrdMsg, MessageBoxButtons.YesNo))
                        {
                            doUnGrade(sIND_BCD, "");
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
                LogFile.WriteLog("SP_POP_WRK37_S02.doLabelUnMerge Error => " + ex.Message);
            }
            finally
            {
                helper.Close();
            }
        }

        private void doUnGrade(string sIND_BCD, string sCancelRmk)
        {
            DBHelper helper = new DBHelper(false, "", true);
            DataSet dsTemp;     //실적등록 결과 수신(0:실적 RFC ID, 1:실적 IF 변수, 2:실적 RFC ID, 3:실적 IF 변수)
            bool bReturn = false;

            string sMSG_ERR = "";
            try
            {
                this.Cursor = Cursors.WaitCursor;   //Waitting

                dsTemp = helper.FillDataSetN("SP_POP_WRK30_I09", CommandType.StoredProcedure, 4
                                                    , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)              // 플랜트코드
                                                    , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)          //작업장코드(설비코드)
                                                    , helper.CreateParameter("P_IND_BCD", sIND_BCD, DbType.String, ParameterDirection.Input)                    //등급변경 취소 바코드
                                                    , helper.CreateParameter("P_CNL_RMK", sCancelRmk, DbType.String, ParameterDirection.Input)                  //
                                                    , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input)                //
                                                    , helper.CreateParameter("RS_GRD_RFCFN", DbType.String, ParameterDirection.Output, null, 20)                // 등급변경취소 RFCFN
                                                    , helper.CreateParameter("RS_DISPO_RFCFN", DbType.String, ParameterDirection.Output, null, 20)              // 폐품취소 RFCFN
                                                    );

                bReturn = false;

                //버튼 상태 변경
                if (helper.RSCODE.Equals("S"))
                {
                    string sRS_GRD_RFCFN = helper.Parameters["RS_GRD_RFCFN"].Value.ToString();          // 등급변경취소 RFCFN ID (생산오더별 자재 투입량 취소) 로 처리함.
                    string sRS_DISPO_RFCFN = helper.Parameters["RS_DISPO_RFCFN"].Value.ToString();      // 폐품취소 RFCFN ID


#if false
                this.Cursor = Cursors.Default;   //Waitting

                if (helper.RSCODE.Equals("E"))
                {
                    //helper.Rollback();
                    //LogFile.WriteLog(sPlantName + " 실적 취소 실패 [" + helper.RSMSG.ToString() + "]");
                    new POPUP.MessageForm(helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                }

                helper.Rollback();
                return;
#endif
                    //string sRfcData; //RFC결과 JSON 변환

                    if (!string.IsNullOrEmpty(sRS_DISPO_RFCFN))
                    {
                        SAPHelper sapRFC_D = new SAPHelper();

                        //SAP 등급변경 폐품 취소
                        if (sapRFC_D.CallSAPFunc(sRS_DISPO_RFCFN, dsTemp.Tables[2], dsTemp.Tables[3], helper).Equals("S"))
                        {
                            bReturn = true;
                        }
                        else
                        {
                            //helper.Rollback();

                            LogFile.WriteLog("등급변경 취소(폐품) - SAP 전송 실패 [" + sapRFC_D.rtnMSG);
                            //new POPUP.MessageForm("등급변경 취소(폐품) - SAP전송이 실패하였습니다.\r\n" + sapRFC_D.rtnMSG, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                            sMSG_ERR += "실적 등록 오류 : " + sapRFC_D.rtnMSG + Environment.NewLine;
                        }

                        Thread.Sleep(Common.SLEEP_DELAY);
                        System.Windows.Forms.Application.DoEvents();        // 반복작업중 응답없음 안뜨게 하기
                        this.Cursor = Cursors.WaitCursor;   //Waitting
                    }
                    else
                    {
                        bReturn = true;
                    }

                    if (/*bReturn == true && */string.IsNullOrEmpty(sRS_GRD_RFCFN) == false)
                    {

                        //SAP 등급변경 취소 (생산오더별 자재 투입량 취소 와 동일한 RFCFN)
                        SAPHelper sapRFC_G = new SAPHelper();

                        if (sapRFC_G.CallSAPFunc(sRS_GRD_RFCFN, dsTemp.Tables[0], dsTemp.Tables[1], helper).Equals("S"))
                        {
                            //string sType = sapRFC_G.rtnTable.Rows[0]["TYPE"].ToString();
                            //string sMessage = sapRFC_G.rtnTable.Rows[0]["MESSAGE"].ToString();
                            //if (sType == "S")
                            //{
                            //    bReturn = true;
                            //    helper.Commit();
                            //}
                            //else
                            //{
                            //    new POPUP.MessageForm("SAP전송이 실패하였습니다.\r\n" + sMessage, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                            //    helper.Rollback();
                            //}
                        }
                        else
                        {
                            LogFile.WriteLog("등급변경 취소 - SAP전송 오류 [" + sapRFC_G.rtnMSG + "]");
                            //new POPUP.MessageForm("실적 취소 - SAP전송이 실패하였습니다.\r\n" + sapRFC_G.rtnMSG, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                            sMSG_ERR += "등급변경 취소 오류 : " + sapRFC_G.rtnMSG + Environment.NewLine;
                        }
                    }

                    //if (bReturn == true)
                    {
                        //helper.Commit();

                        this.Cursor = Cursors.Default;

                        LogFile.WriteLog("등급변경 취소 성공");

                        if (sMSG_ERR.Length > 0)
                        {
                            new POPUP.MessageForm(sMSG_ERR, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                        }
                        else
                        {
                            new POPUP.MessageForm("등급변경 취소 성공", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                        }
                    }
                }
                else
                {
                    helper.Rollback();
                    LogFile.WriteLog("등급변경취소 실패 [" + helper.RSMSG.ToString() + "]");
                    new POPUP.MessageForm("등급변경 취소 실패\r\n" + helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);

                    return;
                }
            }
            catch (Exception ex)
            {
                helper.Rollback();

                LogFile.WriteLog("등급변경 취소 예외 오류 [" + ex.Message + "]");
                new POPUP.MessageForm("등급변경 취소 예외 오류\r\n" + ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
            }
            finally
            {
                this.Cursor = Cursors.Default;   //Default
                helper.Close();
            }

            //취소 최종 처리결과
            if (bReturn)
            {
                gsRESULT = "OK";
            }
        }

        private void doDelete(string sCancelRmk, string delINDBCD, string stckSta)
        {
            //
            if (Common.OpCode == "JA")  // 점보롤
            {
                doJADelete(sCancelRmk, delINDBCD, stckSta);
            }
            else if (Common.OpCode == "MA" || Common.OpCode == "CA" || Common.OpCode == "CB" || Common.OpCode == "SA"
                  || Common.OpCode == "PB" || Common.OpCode == "PC" || Common.OpCode == "PD" || Common.OpCode == "ZA") // 밀롤, 재단, 수재단, 슬리터, 포장
            {
                doDeleteProc(sCancelRmk, Common.OpCode, delINDBCD, stckSta);
            }
            else
            {
                new POPUP.MessageForm("실적 취소 준비중...", MessageBoxButtons.OK, "알   림").ShowDialog(this);
            }
        }

        // 점보롤 취소
        private void doJADelete(string sCancelRmk, string delINDBCD, string stckSta)
        {
            DBHelper helper = new DBHelper(false, "", true);
            DataSet dsTemp;     //실적등록 결과 수신(0:실적 RFC ID, 1:실적 IF 변수, 2:실적 RFC ID, 3:실적 IF 변수)
            DataTable dtList;

            string sQueryName = "SP_POP_WRK30_I02";
            string sMSG_ERR = "";

            try
            {
                this.Cursor = Cursors.WaitCursor;   //Waitting

                LogFile.WriteLog("점보롤 실적 취소 --------------------------------------");

                dtList = setReqDeleteList();

                // SAP 재고체크
                if (!"폐품".Equals(stckSta))
                {
                    if (!CompareInventory(delINDBCD, dtList))
                    {
                        return;
                    }
                }

                string sJsonData = Common.toJsonFormat(sQueryName, dtList);

                dsTemp = helper.FillDataSetN(sQueryName, CommandType.StoredProcedure, 4
                                                    , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)              // 플랜트코드
                                                    , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)          //작업장코드(설비코드)
                                                    , helper.CreateParameterOracle("P_IND_BCD_LIST", sJsonData, OracleDbType.Clob, ParameterDirection.Input)    //
                                                    , helper.CreateParameter("P_CNL_RMK", sCancelRmk, DbType.String, ParameterDirection.Input)                  //
                                                    , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input)                //
                                                    , helper.CreateParameter("RS_PRFM_RFCFN", DbType.String, ParameterDirection.Output, null, 20)               // 실적 RFCFN값
                                                    , helper.CreateParameter("RS_DISPO_RFCFN", DbType.String, ParameterDirection.Output, null, 20)              // 폐품 RFCFN값
                                                    );

                //버튼 상태 변경
                if (helper.RSCODE.Equals("S"))
                {
                    string sRS_PRFM_RFCFN = helper.Parameters["RS_PRFM_RFCFN"].Value.ToString();      // 실적 RFCFN ID
                    string sRS_DISPO_RFCFN = helper.Parameters["RS_DISPO_RFCFN"].Value.ToString();    // 폐품 RFCFN ID

                    //string sRfcData; //RFC결과 JSON 변환
                    bool bJR_CAN_PRFM = (string.IsNullOrEmpty(sRS_PRFM_RFCFN) == false);   // 실적 취소
                    bool bJR_CAN_DISPO = (string.IsNullOrEmpty(sRS_DISPO_RFCFN) == false);    // 생산 폐품 취소

                    bool bRtnPRFM = false;  // 실적취소가 정상적인지 확인
                    bool bRtnDISPO = false; // 폐품취소가 정상적인지 확인

                    if (bJR_CAN_DISPO == true)
                    {
                        SAPHelper sapRFC_D = new SAPHelper();

                        //SAP 폐품 취소
                        if (sapRFC_D.CallSAPFunc(sRS_DISPO_RFCFN, dsTemp.Tables[2], dsTemp.Tables[3], helper).Equals("S"))
                        {
                            bRtnDISPO = true; // 폐품취소 성공
                        }
                        else
                        {
                            bRtnDISPO = false; // 폐품취소 실패

                            helper.Rollback();

                            LogFile.WriteLog("점보롤 실적 취소(폐품) - SAP 전송 오류 [" + sapRFC_D.rtnMSG);
                            sMSG_ERR += "점보롤 실적 취소(폐품) 오류 : " + sapRFC_D.rtnMSG + Environment.NewLine + Environment.NewLine;
                            sMSG_ERR += "실적취소 MES ROLLBACK 취소되었습니다" + Environment.NewLine;
                            new POPUP.MessageForm_ERR("알   림", sMSG_ERR, MessageBoxButtons.OK).ShowDialog(this);
                            return;
                        }

                        Thread.Sleep(Common.SLEEP_DELAY);
                        System.Windows.Forms.Application.DoEvents();        // 반복작업중 응답없음 안뜨게 하기
                        this.Cursor = Cursors.WaitCursor;   //Waitting
                    }

                    // 실적취소
                    if (bJR_CAN_PRFM == true)
                    {
                        //SAP 실적 등록 취소
                        SAPHelper sapRFC_P = new SAPHelper();

                        if (sapRFC_P.CallSAPFunc(sRS_PRFM_RFCFN, dsTemp.Tables[0], dsTemp.Tables[1], helper).Equals("S"))
                        {
                            bRtnPRFM = true;  // 실적취소 성공
                        }
                        else
                        {
                            bRtnPRFM = false;  // 실적취소 실패

                            if (bRtnDISPO == true)
                            {
                                // 폐품 취소가 된경우는 롤백처리 하지 않고 실적취소 계속 진행
                                LogFile.WriteLog("점보롤 실적 취소 - SAP전송 오류 [" + sapRFC_P.rtnMSG + "]");
                                //new POPUP.MessageForm("실적 취소 - SAP전송이 실패하였습니다.\r\n" + sapRFC_P.rtnMSG, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                sMSG_ERR += "점보롤 실적 취소(실적) 오류 : " + sapRFC_P.rtnMSG + Environment.NewLine;
                            }
                            else
                            {
                                helper.Rollback();

                                LogFile.WriteLog("점보롤 실적 취소 - SAP 전송 오류 [" + sapRFC_P.rtnMSG);

                                sMSG_ERR += "점보롤 실적 취소 오류 : " + sapRFC_P.rtnMSG + Environment.NewLine + Environment.NewLine;
                                sMSG_ERR += "실적취소 MES ROLLBACK 취소되었습니다" + Environment.NewLine;
                                new POPUP.MessageForm_ERR("알   림", sMSG_ERR, MessageBoxButtons.OK).ShowDialog(this);
                                return;
                            }
                        }
                    }

                    this.Cursor = Cursors.Default;

                    // 리턴값이 false인경우 실패
                    if (bRtnPRFM == true || bRtnDISPO == true)
                    {
                        gsRESULT = "OK";        //취소 최종 처리결과

                        LogFile.WriteLog("점보롤 실적 취소 성공", LogType.PROC);
                        new POPUP.MessageForm("실적 취소 성공", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    }
                    else
                    {
                        new POPUP.MessageForm(sMSG_ERR, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    }
                }
                else
                {
                    helper.Rollback();
                    LogFile.WriteLog("실적 취소 실패 [" + helper.RSMSG.ToString() + "]");

                    sMSG_ERR += "점보롤 실적 취소 실패 : " + helper.RSMSG.ToString() + Environment.NewLine + Environment.NewLine;
                    sMSG_ERR += "MES ROLLBACK 실적취소가 취소되었습니다" + Environment.NewLine;
                    new POPUP.MessageForm_ERR("알   림", sMSG_ERR, MessageBoxButtons.OK).ShowDialog(this);

                    return;
                }
            }
            catch (Exception ex)
            {
                helper.Rollback();

                LogFile.WriteLog("점보롤 실적 취소 예외 오류 [" + ex.Message + "]");

                sMSG_ERR += "점보롤 실적 취소 예외 오류\r\n" + ex.Message + Environment.NewLine + Environment.NewLine;
                sMSG_ERR += "MES ROLLBACK 실적취소가 취소되었습니다" + Environment.NewLine;
                new POPUP.MessageForm_ERR("알   림", sMSG_ERR, MessageBoxButtons.OK).ShowDialog(this);
            }
            finally
            {
                this.Cursor = Cursors.Default;   //Default
                helper.Close();
            }
        }

        private bool CompareInventory(string delINDBCD, DataTable dtList)
        {
            DBHelper helper = new DBHelper(false, "", true);
            string invLocation = string.Empty;
            bool stockCheck = true;

            //재단만 적용 => 전부적용
            //실적취소 2건이상 가능한줄알고 SUM 값으로 작업 
            //현재는 1건만 실적취소되게 되어있음 
            //추후에 여러건도 그대로 사용가능
            //실적취소하려는 lotno 별로 sum 해서 비교
            if (delINDBCD != null && delINDBCD.Length > 6 && delINDBCD[5] != 'T')
            //if (opCode == "CA" && delINDBCD != null && delINDBCD.Length > 6 && delINDBCD[5] != 'T')
            {
                var result = dtList.AsEnumerable()
                   .GroupBy(row => row.Field<string>("LOT_NO")) // LOT_NO 기준 그룹화
                   .Select(g => new {
                       LotNo = g.Key, // 그룹의 키 (LOT_NO)
                       Matnr = g.FirstOrDefault()?.Field<string>("MATNR") ?? "N/A", //MATNR
                       TotalWgt = g.Sum(row => {
                           double wgt;
                           return double.TryParse(row.Field<string>("WGT"), out wgt) ? wgt : 0.0; // 변환 실패 시 0.0
                       }), //wgt 합산
                       TotalEA = g.Sum(row => row.Field<double>("PRFM_QTY")),
                       Count = g.Count() //그룹별 건수
                   });

                //삭제할 개별바코드의 저장위치 가져오기
                //밀롤만 해당 // 나머지 공정은 정해져있는데 밀롤은 사용에 따라 저장위치가 달라짐 (inv001 테이블 check 필요)
                //점보롤, 슬리터, 재단, 수재단 : 2000
                //밀롤 : 2000(원지판매용), 2500(밀롤창고-적치용), 2700(카타대기)
                //포장 : 2600

                // 2000 : 점보롤, 슬리터, 재단, 수재단(정규), 밀롤(원지판매용)
                // 2500 : 밀롤(밀롤창고-적치용)
                // 2600 : 포장, 수재단(예외)-무조건제품이나오므로
                // 2700 : 밀롤(카타대기)

                // 밀롤일때만 inv001 확인할지 
                if (Common.OpCode == "PB" || Common.OpCode == "PC" || (Common.OpCode == "CB" && gsGB == "예외"))
                {
                    //포장, 수재단(예외)
                    invLocation = "2600";
                }
                else if (Common.OpCode == "MA")
                {
                    // INV001 CHECK
                    DataTable dt = new DataTable();
                    dt = helper.FillTable("SELECT * from tb_inv001 where 1=1 and ind_bcd = '" + delINDBCD + "'");
                    invLocation = dt.Rows[0]["STOR_LOC_CD"].ToString();
                }
                else
                {
                    //점보롤, 슬리터, 재단, 수재단(정규), 밀롤(원지판매용)
                    invLocation = "2000";
                }


                foreach (var item in result)
                {
                    Console.WriteLine($"LotNo: {item.LotNo}, MATNR: {item.Matnr}, PRFM_QTY 합계: {item.TotalEA}, WGT 합계: {item.TotalWgt}, Count: {item.Count}");

                    double stockEA = doCheckInventoryProc(item.LotNo, item.Matnr, invLocation); //실적재고
                    string unit = "KG";

                    //재고값과 실적취소값을 비교
                    //재고값보다 실적취소값이 더 큰 경우 return;
                    if (stockEA < item.TotalEA)
                    {
                        if (Common.OpCode == "CB")
                        {
                            if (gsGB == "예외")
                            {
                                unit = "R";
                            }
                            else
                            {
                                unit = "EA";
                            }
                                
                        }
                        else if (Common.OpCode == "CA")
                        {
                            unit = "EA";
                        }
                        else if(Common.OpCode == "PC" || Common.OpCode == "PB")
                        {
                            unit = "R";
                        }

                        new POPUP.MessageForm_ERR("알   림", "[" + item.LotNo + " / " + item.Matnr + " " + "] \r\n실적 취소에 필요한 재고가 부족하여 실적취소 불가합니다. \r\n취소량은 " + item.TotalEA + " " + unit + ", SAP에 남아있는 재고량은 " + stockEA + " " + unit + " 입니다.", MessageBoxButtons.OK).ShowDialog(this);
                        stockCheck = false;
                    }
                }
            }
            return stockCheck;
        }

        /// <summary>
        /// 밀롤, 재단, 수재단, 슬리터 취소전 실적 재고체크
        /// </summary>
        /// <param name="sCancelRmk"></param>
        /// <param name="opCode"></param>
        private double doCheckInventoryProc(string LotNo, string ItemCode, string location)
        {
            double bSTQTY = 0;

            try
            {
                //점보롤, 슬리터, 재단, 수재단 : 2000
                //밀롤 : 2000(원지판매용), 2500(밀롤창고-적치용), 2700(카타대기)
                //포장 : 2600
                LogFile.WriteLog("SAP 재고 확인");
                {
                    SAPHelper sapRFCQuery = new SAPHelper();

                    if (sapRFCQuery.GetStckData("P100", LotNo, ItemCode, location).Equals("S"))
                    {
                        foreach (DataRow dr in sapRFCQuery.rtnTable.Rows)
                        {
                            if (dr["STQTY"] != DBNull.Value && double.TryParse(dr["STQTY"].ToString(), out double parsedQty))
                            {
                                bSTQTY = parsedQty;
                            }
                        }
                    }
                    else
                    {
                        LogFile.WriteLog("SAP 재고 확인 오류 : 실적취소 skip");
                    }
                }
            }
            catch (Exception ex)
            {
                this.Cursor = Cursors.Default;   //Waitting

                LogFile.WriteLog("재고 조회 예외 오류 [" + ex.Message + "]");
                new POPUP.MessageForm("재고 조회 예외 오류\r\n" + ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
            }
            finally
            {
                this.Cursor = Cursors.Default;   //Waitting
            }
      
            return bSTQTY;
        }

        /// <summary>
        /// 밀롤, 재단, 수재단, 슬리터 취소
        /// </summary>
        /// <param name="sCancelRmk"></param>
        /// <param name="opCode"></param>
        private void doDeleteProc(string sCancelRmk, string opCode, string delINDBCD, string stckSta)
        {
            string sQueryName = "";
            string sPlantName = "";
            string sMSG_ERR = "";

            DataTable dtList;
            DBHelper helper = new DBHelper(false, "", true);
            DataSet dsTemp;     //실적등록 결과 수신(0:실적 RFC ID, 1:실적 IF 변수, 2:실적 RFC ID, 3:실적 IF 변수)

            if (opCode == "MA")
            {
                sQueryName = "SP_POP_WRK30_I03";  // 밀롤 실적취소
                sPlantName = "밀롤";
            }
            else if (opCode == "SA")
            {
                if (gsGB == "예외")
                {
                    sQueryName = "SP_POP_WRK28_I04";  // 슬리터 실적(예외)취소
                    sPlantName = "슬리터(예외)";
                }
                else
                {
                    sQueryName = "SP_POP_WRK30_I04";  // 슬리터 실적취소
                    sPlantName = "슬리터";
                }
            }
            else if (opCode == "CA")
            {
                sQueryName = "SP_POP_WRK26_I03_V01";  // 재단 실적취소
                sPlantName = "재단";
            }
            else if (opCode == "CB")
            {
                if (gsGB == "예외")
                {
                    sQueryName = "SP_POP_WRK29_I05";  // 수재단 예외 실적취소
                    sPlantName = "수재단(예외)";
                }
                else
                {
                    sQueryName = "SP_POP_WRK29_I03_V01";  // 수재단 실적취소
                    sPlantName = "수재단";
                }
            }
            else if (opCode == "PB" || opCode == "PC" || opCode == "PD" || opCode == "ZA")
            {
                if (gsGB == "예외")
                {
                    sQueryName = "SP_POP_WRK27_I04";  // 포장 실적(예외)취소
                    sPlantName = "포장(예외)";
                }
                else
                {
                    sQueryName = "SP_POP_WRK30_I08";  // 포장 실적취소
                    sPlantName = "포장";
                }
            }
            else
            {
                // 준비중 입니다.
                return;
            }

            try
            {
                this.Cursor = Cursors.WaitCursor;   //Waitting

                LogFile.WriteLog(sPlantName + " 실적 취소 --------------------------------------");

                dtList = setReqDeleteList();

                if (!"폐품".Equals(stckSta))
                {
                    // SAP 재고체크
                    if (!CompareInventory(delINDBCD, dtList))
                    {
                        return;
                    }
                }

                string sJsonData = Common.toJsonFormat(sQueryName, dtList);

                // 포장실적취소시 실적취소된 바코드인지 확인
                if (opCode == "PB" || opCode == "PC" || opCode == "PD" || opCode == "ZA")
                {
                    //20230116 wsw
                    dsTemp = helper.FillDataSetN("SP_POP_WRK30_V01", CommandType.StoredProcedure, 0
                                                        , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)              // 플랜트코드
                                                        , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)          // 작업장코드(설비코드)
                                                        , helper.CreateParameterOracle("P_IND_BCD_LIST", sJsonData, OracleDbType.Clob, ParameterDirection.Input)    // 개별바코드 리스트
                                                        , helper.CreateParameter("P_CNL_RMK", sCancelRmk, DbType.String, ParameterDirection.Input)                  // 취소내용
                                                        , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input)                // USER ID
                                                        , helper.CreateParameter("RS_PRFM_RFCFN", DbType.String, ParameterDirection.Output, null, 200)                  //실적 RFCFN ID값
                                                        , helper.CreateParameter("RS_DISPO_RFCFN", DbType.String, ParameterDirection.Output, null, 200)                 //폐품 RFCFN ID값
                                                        , helper.CreateParameter("RS_INPUT_RFCFN", DbType.String, ParameterDirection.Output, null, 200)                 //투입량 RFCFN ID값
                                                        , helper.CreateParameter("RS_SDISPO_RFCFN", DbType.String, ParameterDirection.Output, null, 200)                 //폐품 RFCFN ID값
                                                        );
                    if (helper.RSCODE.Equals("E"))
                    {
                        new POPUP.MessageForm_ERR("알   림", helper.RSMSG, MessageBoxButtons.OK).ShowDialog(this);
                        return;
                    }
                    //////////////////////////////////////////
                }

                dsTemp = helper.FillDataSetN(sQueryName, CommandType.StoredProcedure, 8
                                                    , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)              // 플랜트코드
                                                    , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)          // 작업장코드(설비코드)
                                                    , helper.CreateParameterOracle("P_IND_BCD_LIST", sJsonData, OracleDbType.Clob, ParameterDirection.Input)    // 개별바코드 리스트
                                                    , helper.CreateParameter("P_CNL_RMK", sCancelRmk, DbType.String, ParameterDirection.Input)                  // 취소내용
                                                    , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input)                // USER ID
                                                    , helper.CreateParameter("RS_PRFM_RFCFN", DbType.String, ParameterDirection.Output, null, 200)                  //실적 RFCFN ID값
                                                    , helper.CreateParameter("RS_DISPO_RFCFN", DbType.String, ParameterDirection.Output, null, 200)                 //폐품 RFCFN ID값
                                                    , helper.CreateParameter("RS_INPUT_RFCFN", DbType.String, ParameterDirection.Output, null, 200)                 //투입량 RFCFN ID값
                                                    , helper.CreateParameter("RS_SDISPO_RFCFN", DbType.String, ParameterDirection.Output, null, 200)                 //폐품 RFCFN ID값
                                                    );

            #if false
                this.Cursor = Cursors.Default;   //Waitting

                if (helper.RSCODE.Equals("E"))
                {
                    //helper.Rollback();
                    //LogFile.WriteLog(sPlantName + " 실적 취소 실패 [" + helper.RSMSG.ToString() + "]");
                    new POPUP.MessageForm(helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                }

                helper.Rollback();
                return;
            #endif
                //버튼 상태 변경
                if (helper.RSCODE.Equals("S"))
                {
                    string sRS_PRFM_RFCFN = helper.Parameters["RS_PRFM_RFCFN"].Value.ToString();      // 실적 RFCFN ID
                    string sRS_DISPO_RFCFN = helper.Parameters["RS_DISPO_RFCFN"].Value.ToString();    // 폐품 RFCFN ID
                    string sRS_INPUT_RFCFN = helper.Parameters["RS_INPUT_RFCFN"].Value.ToString();    // 투입량 RFCFN ID
                    string sRS_SDISPO_RFCFN = helper.Parameters["RS_SDISPO_RFCFN"].Value.ToString();    // 폐품 RFCFN ID

                    //dsTemp.Tables[0];     // 실적 취소 인터페이스 파라미터
                    //dsTemp.Tables[1];     // 실적 취소 인터페이스 상세 파라미터
                    //dsTemp.Tables[2];     // 폐품 취소 인터페이스 파라미터
                    //dsTemp.Tables[3];     // 폐품 취소 인터페이스 상세 파라미터
                    //dsTemp.Tables[4];     // 투입량 취소 인터페이스 파라미터
                    //dsTemp.Tables[5];     // 투입량 취소 인터페이스 상세 파라미터

                    bool bCAN_PRFM = (string.IsNullOrEmpty(sRS_PRFM_RFCFN) == false);   // 실적 취소
                    bool bCAN_DISPO = (string.IsNullOrEmpty(sRS_DISPO_RFCFN) == false);    // 생산 폐품 취소
                    bool bCAN_INPUT = (string.IsNullOrEmpty(sRS_INPUT_RFCFN) == false);    // 투입량 취소
                    bool bCAN_SDISPO = (string.IsNullOrEmpty(sRS_SDISPO_RFCFN) == false);   // 영업, 잔량 폐품

                    bool bRtnPRFM = false;  // 실적취소가 정상적인지 확인
                    bool bRtnDISPO = false; // 폐품취소가 정상적인지 확인
                    bool bRtnINPUT = false; // 투입량취소가 정상적인지 확인
                    bool bRtnSDISPO = false;  // 영업, 잔량 폐품취소가 정상적인지 확인

                    // 1. 영업,잔량 폐품 등록 취소
                    if (bCAN_SDISPO == true)
                    {
                        SAPHelper sapRFC_D = new SAPHelper();

                        // sapRFC.CallSAPFunc 호출시 helper를 사용하여 내용이 변경됨. 
                        // 필요한 정보는 sapRFC.CallSAPFunc 호출전에 처리해야함.
                        if (sapRFC_D.CallSAPFunc(sRS_SDISPO_RFCFN, dsTemp.Tables[6], dsTemp.Tables[7], helper).Equals("S"))
                        {
                            bRtnSDISPO = true;      // 영업+잔량 폐품 성공

                            Thread.Sleep(Common.SLEEP_DELAY);
                            System.Windows.Forms.Application.DoEvents();        // 반복작업중 응답없음 안뜨게 하기
                            this.Cursor = Cursors.WaitCursor;   //Waitting
                        }
                        else
                        {
                            bRtnSDISPO = false;     // 영업+잔량 폐품 실패

                            helper.Rollback();
                            LogFile.WriteLog(sPlantName + " 실적 취소(영업+잔량 폐품) SAP전송 오류 [" + sapRFC_D.rtnMSG + "]");

                            sMSG_ERR = "실적 취소(영업+잔량 폐품) SAP전송이 실패하였습니다.\r\n" + sapRFC_D.rtnMSG + Environment.NewLine + Environment.NewLine;
                            sMSG_ERR += "실적취소 MES ROLLBACK 취소되었습니다" + Environment.NewLine;
                            new POPUP.MessageForm_ERR("알   림", sMSG_ERR, MessageBoxButtons.OK).ShowDialog(this);

                            return;
                        }
                    }

                    // 2. 폐품 등록 취소
                    if (bCAN_DISPO == true)
                    {
                        SAPHelper sapRFC_D = new SAPHelper();

                        // sapRFC.CallSAPFunc 호출시 helper를 사용하여 내용이 변경됨. 
                        // 필요한 정보는 sapRFC.CallSAPFunc 호출전에 처리해야함.
                        if (sapRFC_D.CallSAPFunc(sRS_DISPO_RFCFN, dsTemp.Tables[2], dsTemp.Tables[3], helper).Equals("S"))
                        {
                            bRtnDISPO = true;       //생산폐품

                            Thread.Sleep(Common.SLEEP_DELAY);
                            System.Windows.Forms.Application.DoEvents();        // 반복작업중 응답없음 안뜨게 하기
                            this.Cursor = Cursors.WaitCursor;   //Waitting
                        }
                        else
                        {
                            bRtnDISPO = false;       //생산폐품

                            if (bRtnSDISPO == true)
                            {
                                // 잔량 폐품이 성공한 경우는 롤백처리 하지 않고 실적취소 진행
                                LogFile.WriteLog(sPlantName + " 실적 취소(폐품) SAP전송 오류 [" + sapRFC_D.rtnMSG + "]");
                                new POPUP.MessageForm_ERR("알   림", "실적 취소(폐품) SAP전송이 실패하였습니다.\r\n" + sapRFC_D.rtnMSG, MessageBoxButtons.OK).ShowDialog(this);
                            }
                            else
                            {
                                helper.Rollback();

                                LogFile.WriteLog(sPlantName + " 실적 취소(폐품) SAP전송 오류 [" + sapRFC_D.rtnMSG + "]");

                                sMSG_ERR += "실적 취소(폐품) SAP전송이 실패하였습니다.\r\n" + sapRFC_D.rtnMSG + Environment.NewLine + Environment.NewLine;
                                sMSG_ERR += "실적취소 MES ROLLBACK 취소되었습니다" + Environment.NewLine;
                                new POPUP.MessageForm_ERR("알   림", sMSG_ERR, MessageBoxButtons.OK).ShowDialog(this);
                                return;
                            }
                        }
                    }

                    // 3. 실적 취소
                    if (bCAN_PRFM == true)
                    {
                        //SAP 실적 취소
                        SAPHelper sapRFC_P = new SAPHelper();

                        // sapRFC.CallSAPFunc 호출시 helper를 사용하여 내용이 변경됨. 
                        // 필요한 정보는 sapRFC.CallSAPFunc 호출전에 처리해야함.
                        if (sapRFC_P.CallSAPFunc(sRS_PRFM_RFCFN, dsTemp.Tables[0], dsTemp.Tables[1], helper).Equals("S"))
                        {
                            bRtnPRFM = true;        // 실적취소 성공

                            Thread.Sleep(Common.SLEEP_DELAY);
                            System.Windows.Forms.Application.DoEvents();        // 반복작업중 응답없음 안뜨게 하기
                            this.Cursor = Cursors.WaitCursor;   //Waitting
                        }
                        else
                        {
                            bRtnPRFM = true;        // 실적취소 실패

                            // 영업+잔량폐품 또는 생산폐품 취소가 이루어진경우
                            if (bRtnSDISPO == true || bRtnDISPO == true)
                            {
                                // 영업+잔량폐품 또는 생산폐품  취소가 성공한 경우는 롤백처리 하지 않고 실적취소 진행
                                LogFile.WriteLog(sPlantName + " 실적 취소 SAP 전송 오류 [" + sapRFC_P.rtnMSG + "]");
                                new POPUP.MessageForm_ERR("알   림", "실적 취소 SAP전송이 실패하였습니다.\r\n" + sapRFC_P.rtnMSG, MessageBoxButtons.OK).ShowDialog(this);
                            }
                            else
                            {
                                // 영업+잔량폐품 또는 생산폐품  취소가 이루어지지 않은경우 롤백
                                helper.Rollback();

                                LogFile.WriteLog(sPlantName + " 실적 취소 SAP전송 오류 [" + sapRFC_P.rtnMSG + "]");

                                sMSG_ERR += "실적 취소 SAP전송이 실패하였습니다.\r\n" + sapRFC_P.rtnMSG + Environment.NewLine + Environment.NewLine;
                                sMSG_ERR += "실적취소 MES ROLLBACK 취소되었습니다" + Environment.NewLine;
                                new POPUP.MessageForm_ERR("알   림", sMSG_ERR, MessageBoxButtons.OK).ShowDialog(this);
                                return;
                            }
                        }
                    }

                    // 4. 투입량 등록 취소
                    if(bCAN_INPUT == true) 
                    {
                        SAPHelper sapRFC_I = new SAPHelper();

                        // 문서번호, 문서순번으로  테이블 SORT 하여 전달
                        DataTable dtRFCData = new DataTable();
                        DataView dvPFRM = new DataView(dsTemp.Tables[5]);
                        dvPFRM.Sort = "MDOCNO, MDOCSEQ ASC";
                        dtRFCData = dvPFRM.ToTable();

                        // sapRFC.CallSAPFunc 호출시 helper를 사용하여 내용이 변경됨. 
                        // 필요한 정보는 sapRFC.CallSAPFunc 호출전에 처리해야함.
                        if (sapRFC_I.CallSAPFunc(sRS_INPUT_RFCFN, dsTemp.Tables[4], dtRFCData, helper).Equals("S"))
                        {
                            bCAN_INPUT = true;
                            Thread.Sleep(Common.SLEEP_DELAY);
                            System.Windows.Forms.Application.DoEvents();        // 반복작업중 응답없음 안뜨게 하기
                            this.Cursor = Cursors.WaitCursor;   //Waitting
                        }
                        else
                        {
                            //helper.Rollback();
                            bCAN_INPUT = false;
                            LogFile.WriteLog(sPlantName + " 실적 취소(투입량) SAP전송 오류 [" + sapRFC_I.rtnMSG + "]");
                            new POPUP.MessageForm_ERR( "알   림", "실적 취소(투입량) SAP전송이 실패하였습니다.\r\n" + sapRFC_I.rtnMSG, MessageBoxButtons.OK).ShowDialog(this);
                        }
                    }

                    helper.Commit();
                    // RFC중 하나라도 성공한 경우, 전체 취소 성공으로 한다. (POP만 해당)
                    if (bRtnSDISPO == true || bRtnDISPO == true || bCAN_PRFM == true || bCAN_INPUT == true)
                    {
//                        gsRESULT = "OK";
                        
                        LogFile.WriteLog(sPlantName + " 실적 취소 성공");
                        new POPUP.MessageForm("실적 취소 성공\r\n", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    }
                }
                else
                {
                    helper.Rollback();
                    LogFile.WriteLog(sPlantName + " 실적 취소 실패 [" + helper.RSMSG.ToString() + "]");
                    new POPUP.MessageForm_ERR("알   림", "실적 취소 실패\r\n" + helper.RSMSG.ToString(), MessageBoxButtons.OK).ShowDialog(this);

                    return;
                }
            }
            catch (Exception ex)
            {
                helper.Rollback();

                LogFile.WriteLog(sPlantName + " 실적 취소 예외 오류  [" + ex.Message + "]");
                new POPUP.MessageForm_ERR("알   림", "실적 취소 예외 오류\r\n" + ex.Message, MessageBoxButtons.OK).ShowDialog(this);
            }
            finally
            {
                this.Cursor = Cursors.Default;   //Waitting
                helper.Close();
            }
            gsRESULT = "OK";
        }

        bool AhtuPackageCheck()
        {
            // 포장공정에서는 인증된 사용자만 사용가능하도록 함
            if (Common.OpCode == "PB" || Common.OpCode == "PC" || Common.OpCode == "PD" || Common.OpCode == "ZA" || Common.OpCode == "CB")
            {
                if (Common.Auth_Package == false)
                {
                    // 전체보기 인증번호 없이 다보이도록함.
                    POP_Login pop = new POP_Login();
                    pop.ShowDialog();
                    if (pop.DialogResult == DialogResult.OK)
                    {
                        Common.Auth_Package = true;
                    }
                }

                return Common.Auth_Package;
            }
            else
            {
                return true;
            }
        }

        #endregion

        #region < EVNET >

        private void bBox1_buttonClickEvent(MESButton sender, ButtonBox.ButtonClickEventArg e)
        {
            DataTable dtReqList;
            int iCnt = 0;
            string sBtnName = "";

            try
            {
                if (!this.bUseNetwork)
                {
                    SetMessage("네트워크 상태를 확인하시기 바랍니다.");
                    return;
                }

                MESButton btn = sender;

                sBtnName = btn.Tag.ToString();

                //if (sBtnName.Equals("Close"))
                //{
                //    this.Close();
                //    return;
                //}

                //체크된 항목 확인
                dtReqList = setReqList();
                
                iCnt = dtReqList.Rows.Count;

                if ((iCnt == 0) && (sBtnName.Equals("Close") == false))
                {
                    new POPUP.MessageForm("선택된 것이 없습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return;
                }

                switch (sBtnName)
                {
                    case "Print":  //라벨재발행
                        LogFile.WriteLog("바코드 재발행 시작", LogType.PROC);

                        string sIND_BCD_GRP = "";   // 개별 바코드 묶음
                        //doPrint();
                        //if (gsOP_CODE.Equals("CA") || gsOP_CODE.Equals("MA"))    // 재단 폐품 선택된경우 알림 처리
                        {
                            bool bRePrint = false;
                            int nPRFM_CNT = 0;
                            int nDISOP_CNT = 0;

                            for (int i = 0; i < iCnt; i++)
                            {
                                if (gsOP_CODE.Equals("JA"))
                                {
                                    //  [예외처리] 점보롤 의 경우 STA 값이 항상 '00' 이여서, RUN_STA값을 -> "STA"로 가져와서 상태값 확인.
                                    // RUN_STA 상태값 : '01' 정상, '00' 폐품, '09' 비계획생산
                                    if (dtReqList.Rows[i]["STA"].ToString().Equals("00") == false)
                                    {
                                        nPRFM_CNT++;
                                    }
                                    else
                                    {
                                        nDISOP_CNT++;
                                    }
                                }
                                else
                                {
                                    // '00' 정상
                                    if (dtReqList.Rows[i]["RUN_STA_NM"].ToString().Equals("폐품"))
                                    {
                                        nDISOP_CNT++;
                                    }
                                    else
                                    {
                                        nPRFM_CNT++;
                                    }
                                }
                            }
                            
                            if (nPRFM_CNT > 0 && nDISOP_CNT == 0)
                            {
                                bRePrint = true;
                            }
                            else if (nPRFM_CNT > 0 && nDISOP_CNT > 0)
                            {
                                if (new POPUP.MessageForm("선택항목중 폐품 실적이 선택 되었습니다.\r\n\r\n폐품 실적을 제외 하고 재발행 하시겠습니까?", MessageBoxButtons.OKCancel, "알   림").ShowDialog(this) == DialogResult.OK)
                                {
                                    bRePrint = true;
                                }
                                else
                                {
                                    bRePrint = false;
                                }
                            }
                            else if (nPRFM_CNT == 0 && nDISOP_CNT > 0)
                            {
                                new POPUP.MessageForm("폐품실적만 선택 되었습니다.\r\n\r\n폐품 실적은 재발행 할수 없습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                bRePrint = false;
                            }

                            if (bRePrint == false)
                            {
                                LogFile.WriteLog("바코드 재발행 완료", LogType.PROC);
                                return;
                            }
                        }

                        this.Cursor = Cursors.WaitCursor;   //Waitting

                        if (gsOP_CODE.Equals("JA"))     // 점보롤
                        {
                            for (int i = 0; i < iCnt; i++)
                            {
                                //PrinterManager.PrintJumboRoll(dtReqList.Rows[i]["IND_BCD"].ToString());
                                //  [예외처리] 점보롤 의 경우 STA 값이 항상 '00' 이여서, RUN_STA값을 -> "STA"로 가져와서 상태값 확인.
                                // RUN_STA 상태값 : '01' 정상, '00' 폐품, '09' 비계획생산
                                if (dtReqList.Rows[i]["STA"].ToString().Equals("00") == false)
                                {
                                    sIND_BCD_GRP += dtReqList.Rows[i]["IND_BCD"].ToString() + "|";
                                }
                            }

                            if (sIND_BCD_GRP.Length > 0)
                            {
                                sIND_BCD_GRP = sIND_BCD_GRP.Substring(0, sIND_BCD_GRP.Length - 1);
                                PrinterManager.PrintJumboRoll(sIND_BCD_GRP);
                            }
                        }
                        else if (gsOP_CODE.Equals("MA") || gsOP_CODE.Equals("CA") || gsOP_CODE.Equals("CB") || gsOP_CODE.Equals("SA") ||    // 밀롤, 재단
                                 gsOP_CODE.Equals("PB") || gsOP_CODE.Equals("PC") || gsOP_CODE.Equals("PD") || gsOP_CODE.Equals("ZA"))     // 포장
                        {
                            for (int i = 0; i < iCnt; i++)
                            {
                                //PrinterManager.PrintMillRoll(dtReqList.Rows[i]["IND_BCD"].ToString());
                                if (!dtReqList.Rows[i]["RUN_STA_NM"].ToString().Equals("폐품"))
                                {
                                    sIND_BCD_GRP += dtReqList.Rows[i]["IND_BCD"].ToString() + "|";
                                }
                            }

                            if (sIND_BCD_GRP.Length > 0)
                            {
                                bool qrDiv = false; //true => QR, false => 최종라벨
                                sIND_BCD_GRP = sIND_BCD_GRP.Substring(0, sIND_BCD_GRP.Length - 1);
                                if (gsOP_CODE.Equals("MA"))
                                {
                                    int nPrtRollCnt = 2;
                                    int nPrtSheetCnt = 1;

                                    if (ucPNT_CNT.SelectedIndex == 0)
                                    {
                                        nPrtRollCnt = 2;
                                        nPrtSheetCnt = 1;
                                    }
                                    else
                                    {
                                        nPrtRollCnt = ucPNT_CNT.SelectedIndex;
                                        nPrtSheetCnt = ucPNT_CNT.SelectedIndex;
                                    }

                                    POPUP.MessageForm msgForm;
                                    msgForm = new POPUP.MessageForm("QR코드로 출력하시겠습니까?\n QR코드(예) / 실적라벨(아니오)", MessageBoxButtons.YesNoCancel, "알  림");

                                    DialogResult dr = msgForm.ShowDialog(this);
                                    if (dr == DialogResult.Cancel)
                                    {
                                        return;
                                    }
                                    else if (dr == DialogResult.Yes)
                                    {
                                        qrDiv = true;
                                    }


                                    if (PrinterManager.PrintMillRoll(sIND_BCD_GRP, true, qrDiv, nPrtRollCnt, nPrtSheetCnt) == false)
                                    {
                                        LogFile.WriteLog("바코드 재발행 완료", LogType.PROC);
                                        return;
                                    }
                                }
                                else if (gsOP_CODE.Equals("SA"))
                                {
                                    int nPrtCnt = ucPNT_CNT.SelectedIndex+1;

                                    POPUP.MessageForm msgForm;
                                    msgForm = new POPUP.MessageForm("QR코드로 출력하시겠습니까?\n QR코드(예) / 실적라벨(아니오)", MessageBoxButtons.YesNoCancel, "알  림");

                                    DialogResult dr = msgForm.ShowDialog(this);
                                    if (dr == DialogResult.Cancel)
                                    {
                                        return;
                                    }
                                    else if (dr == DialogResult.Yes)
                                    {
                                        qrDiv = true;
                                    }

                                    //if (new POPUP.MessageForm("QR코드로 출력하시겠습니까?\n QR코드(예) / 실적라벨(아니오)", MessageBoxButtons.YesNoCancel, "알   림").ShowDialog() == DialogResult.No)
                                    //{
                                    //    qrDiv = true;
                                    //}

                                    if (PrinterManager.PrintSliter(sIND_BCD_GRP, qrDiv, nPrtCnt) == false)
                                    {
                                        LogFile.WriteLog("바코드 재발행 완료", LogType.PROC);
                                        return;
                                    }
                                }
                                else if (gsOP_CODE.Equals("CA"))    // 재단
                                {
                                    PrinterManager.PrintCutter(sIND_BCD_GRP);
                                }
                                else if (gsOP_CODE.Equals("CB"))    // 수재단
                                {
                                    // 예외이면....라벨프린터 이용
                                    string sLABEL_TYPE = (string)ucLABEL_TYPE.Items[ucLABEL_TYPE.SelectedIndex].DataValue;           //

                                    int nPrtCnt = ucPNT_CNT.SelectedIndex + 1;

                                    if (PrinterManager.PrintMCutter(sIND_BCD_GRP, sLABEL_TYPE, nPrtCnt) == false)
                                    {
                                        LogFile.WriteLog("바코드 재발행 완료", LogType.PROC);
                                        return;
                                    }
                                }
                                else if (gsOP_CODE.Equals("PB") || gsOP_CODE.Equals("PC") || gsOP_CODE.Equals("PD") || gsOP_CODE.Equals("ZA"))    // 포장
                                {
                                    string sLABEL_TYPE = (string)ucLABEL_TYPE.Items[ucLABEL_TYPE.SelectedIndex].DataValue;           //

                                    int nPrtCnt = ucPNT_CNT.SelectedIndex + 1;

                                    if (PrinterManager.PrintPackaging(sIND_BCD_GRP, sLABEL_TYPE, nPrtCnt) == false)
                                    {
                                        LogFile.WriteLog("바코드 재발행 완료", LogType.PROC);
                                        return;
                                    }
                                }

                            }
                        }
                        //else if (gsOP_CODE.Equals("CA"))    // 재단
                        //{
                        //    for (int i = 0; i < iCnt; i++)
                        //    {
                        //        if (dtReqList.Rows[i]["STA"].ToString().Equals("00"))
                        //        {
                        //            PrinterManager.PrintCutter(dtReqList.Rows[i]["IND_BCD"].ToString());
                        //        }
                        //    }
                        //}
                        //else if (gsOP_CODE.Equals("SA"))    // 슬리터
                        //{
                        //    //for (int i = 0; i < iCnt; i++)
                        //    //{
                        //    //    PrinterManager.PrintMillRoll(dtReqList.Rows[i]["IND_BCD"].ToString());
                        //    //}
                        //    for (int i = 0; i < iCnt; i++)
                        //    {
                        //        if (dtReqList.Rows[i]["STA"].ToString().Equals("00"))
                        //        {
                        //            sIND_BCD_GRP += dtReqList.Rows[i]["IND_BCD"].ToString() + "|";
                        //        }
                        //    }

                        //    if (sIND_BCD_GRP.Length > 0)
                        //    {
                        //        sIND_BCD_GRP = sIND_BCD_GRP.Substring(0, sIND_BCD_GRP.Length - 1);
                        //        PrinterManager.PrintMillRoll(sIND_BCD_GRP);
                        //    }
                        //}

                        this.Cursor = Cursors.Default;   //원래대로

                        LogFile.WriteLog("바코드 재발행 완료", LogType.PROC);
                        new POPUP.MessageForm("라벨 재발행 되었습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);

                        break;
                    case "Delete":  //실적취소
                        if (iCnt == 1)
                        {
                            if (dtReqList.Rows[0]["MER_YN"].ToString() == "Y")
                            {
                                new POPUP.MessageForm("라벨병합된 바코드 입니다. \r\n실적 취소를 실행 할 수 없습니다.\r\n\r\n라벨병합 취소후 실적취소를 실행 하세요.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                return;
                            }

                            DAResultText pop = new DAResultText("실적취소 사유를 자세히 기입하십시오.", "");
                            pop.bNullCheck = true;
                            pop.NullCheckString = "실적 취소 사유를 반드시 입력하십시오.";
                            pop.ContentMaxLength = 100;

                            pop.ShowDialog(this);
                            if (pop.DialogResult == DialogResult.OK)
                            {
                                string sCancelRmk = pop.ResultString;
                                string delINDBCD = dtReqList.Rows[0]["IND_BCD"].ToString();

                                if (new POPUP.MessageForm(string.Format("개별바코드 '{0}'을 실적취소 하시겠습니까?", delINDBCD), MessageBoxButtons.OKCancel, "알   림").ShowDialog(this) == DialogResult.OK)
                                {
                                    if (dtReqList.Rows[0]["WRK_ORDR_NO"].ToString().Contains("WOEX"))
                                        gsGB = "예외";
                                    else
                                        gsGB = "";

                                    doDelete(sCancelRmk, delINDBCD, dtReqList.Rows[0]["STCK_STA_NM"].ToString());                       // 실적취소시 취소사유 전달.
                                }
                            }
                            SetGrid();
                        }
                        else
                        {
                            new POPUP.MessageForm("동시에 2개 이상의 실적 취소를 실행 할 수 없습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                        }
                        break;
                    case "Remark":  //비고수정
                        #region < REGION_REMARK >
                        if (iCnt == 1)
                        {
                            POP_WRK85 WRK85 = new POP_WRK85("비고수정", Common.PlantCode, Common.MachineCode, dtReqList.Rows[0]["IND_BCD"].ToString(), dtReqList.Rows[0]["LOT_NO"].ToString(), dtReqList.Rows[0]["RMK"].ToString());
                            WRK85.ShowDialog(this);
                            if (WRK85.DialogResult == DialogResult.OK)
                            {
                                SetGrid();
                            }
                        }
                        else
                        {
                            new POPUP.MessageForm("동시에 2개 이상의 비고 수정을 실행 할 수 없습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                        }
                        #endregion

                        break;
                    case "Spare":  //여유생산
                        {
                            if (iCnt == 1)
                            {
                                if (dtReqList.Rows[0]["RUN_STA_NM"].ToString().Equals("폐품"))
                                {
                                    new POPUP.MessageForm("폐품 실적을 선택 하여 여유생산을 실행 할수 없습니다.\r\n\r\n정상 실적을 선택 하시기 바랍니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                }
                                else
                                {
                                    if (dtReqList.Rows[0]["COMP_YN"].ToString().Equals("Y"))
                                    {
                                        POP_WRK83 WRK83 = new POP_WRK83(dtReqList.Rows[0]["IND_BCD"].ToString());
                                        WRK83.ShowDialog(this);
                                        SetGrid();
                                    }
                                    else
                                    {
                                        //new POPUP.MessageForm("재단 작업지시가 생산 완료된 작업지시가 아닙니다.\r\n\r\n작업지시상태가 완료 처리된 실적만\r\n여유생산을 실행 할수 있습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                        new POPUP.MessageForm("작업지시상태가 완료 처리된 실적만\r\n여유생산을 실행 할수 있습니다.\r\n\r\n작업지시를 완료후 실행 하시기 바랍니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                    }
                                }

                            }
                            else
                            {
                                new POPUP.MessageForm("동시에 2개 이상의 여유 생산를 실행 할 수 없습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                            }
                        }
                        break;

                    case "Grade":  //등급변경

                        if (iCnt == 1)
                        {
                            if (Common.OpCode == "PB" || Common.OpCode == "PC" || Common.OpCode == "PD" || Common.OpCode == "ZA")
                            {
                                if (AhtuPackageCheck() == false)
                                {
                                    return;
                                }
                            }

                            if (dtReqList.Rows[0]["STCK_STA_NM"].ToString().Equals("정상"))
                            {
                                string sLABEL_TYPE = (string)ucLABEL_TYPE.Items[ucLABEL_TYPE.SelectedIndex].DataValue;           //
                                int nPrtCnt = ucPNT_CNT.SelectedIndex + 1;

                                POP_WRK37 WRK37 = new POP_WRK37(dtReqList.Rows[0]["IND_BCD"].ToString(), dtReqList.Rows[0]["WRK_ORDR_NO"].ToString(), dtReqList.Rows[0]["WRK_ORDR_SEQNO"].ToString(), sLABEL_TYPE, nPrtCnt);
                                ShowDialogForm(WRK37);
                                SetGrid();
                            }
                            else
                            {
                                new POPUP.MessageForm("등급변경 가능 상태가 아닙니다.\r\n\r\n재고상태 : " + dtReqList.Rows[0]["STCK_STA_NM"].ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                            }
                        }
                        else
                        {
                            new POPUP.MessageForm("동시에 2개 이상의 등급 변경을 실행 할 수 없습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                        }

                        break;

                    case "UnGrade": //등급변경 취소
                        if (iCnt == 1)
                        {
                            if (Common.OpCode == "PB" || Common.OpCode == "PC" || Common.OpCode == "PD" || Common.OpCode == "ZA")
                            {
                                if (AhtuPackageCheck() == false)
                                {
                                    return;
                                }
                            }

                            // -----------------------------------------------
                            // 등급변경한 바코드가 아닙니다. 등급변경 바코드를 선택해 주세요.
                            doUnGradeConfirm(dtReqList.Rows[0]["IND_BCD"].ToString());
                            SetGrid();
                        }
                        else
                        {
                            new POPUP.MessageForm("등급변경 취소 대상은 한개만 선택하십시오.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                        }
                        break;

                    case "Close": //이전화면
                        if (gsRESULT == "OK")
                            this.DialogResult = DialogResult.OK;
                        else
                            this.DialogResult = DialogResult.Cancel;

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
                LogFile.WriteLog("POP_WRK30.bBox1_buttonClickEvent Error => " + ex.Message);
            }
            finally
            {
                this.Cursor = Cursors.Default;   //원래대로
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
                dtRtn.Columns.Add(new DataColumn("WRK_ORDR_NO", typeof(string)));       //작업지시
                dtRtn.Columns.Add(new DataColumn("WRK_ORDR_SEQNO", typeof(string)));    //작업지시 순번
                dtRtn.Columns.Add(new DataColumn("IND_BCD", typeof(string)));           //개별바코드
                dtRtn.Columns.Add(new DataColumn("LOT_NO", typeof(string)));            //LOT_NO
                dtRtn.Columns.Add(new DataColumn("RMK", typeof(string)));               //비고내용
                dtRtn.Columns.Add(new DataColumn("STA", typeof(string)));               //상태
                dtRtn.Columns.Add(new DataColumn("COMP_YN", typeof(string)));               //작업지시상태
                dtRtn.Columns.Add(new DataColumn("MER_YN", typeof(string)));               //라벨병합
                dtRtn.Columns.Add(new DataColumn("GB", typeof(string)));                //지시구분 (예외생산 구분을 위해 추가)
                dtRtn.Columns.Add(new DataColumn("RUN_STA_NM", typeof(string)));               // 
                dtRtn.Columns.Add(new DataColumn("STCK_STA_NM", typeof(string)));               // 
                

                for (int i = 0; i < dt.Rows.Count; i++)
                {
                    //선택된 행처리
                    if (dt.Rows[i]["CHK"].ToString().Equals("V"))
                    {
                        //조회결과 입력용 Row생성
                        dtTempRow = dtRtn.NewRow();
                        dtTempRow["WRK_ORDR_NO"] = dt.Rows[i]["WRK_ORDR_NO"].ToString();
                        dtTempRow["WRK_ORDR_SEQNO"] = dt.Rows[i]["WRK_ORDR_SEQNO"].ToString();
                        dtTempRow["IND_BCD"] = dt.Rows[i]["IND_BCD"].ToString();
                        dtTempRow["LOT_NO"] = dt.Rows[i]["LOT_NO"].ToString();
                        dtTempRow["RMK"] = dt.Rows[i]["RMK"].ToString();
                        //dtTempRow["STA"] = dt.Rows[i]["STA"].ToString();
                        if (dt.Columns.Contains("STA"))
                        {
                            dtTempRow["STA"] = dt.Rows[i]["STA"].ToString();
                        }
                        else
                        {
                            dtTempRow["STA"] = "";
                        }

                        if (dt.Columns.Contains("COMP_YN"))
                        {
                            dtTempRow["COMP_YN"] = dt.Rows[i]["COMP_YN"].ToString();
                        }
                        else
                        {
                            dtTempRow["COMP_YN"] = "";
                        }

                        // DataTable에 칼럼명이 있는지 확인
                        if (dt.Columns.Contains("GB"))
                        {
                            dtTempRow["GB"] = dt.Rows[i]["GB"].ToString();
                        }
                        else
                        {
                            dtTempRow["GB"] = "";
                        }

                        if (gsOP_CODE.Equals("CA"))
                        {

                            if (dt.Columns.Contains("MER_YN"))
                            {
                                dtTempRow["MER_YN"] = dt.Rows[i]["MER_YN"].ToString();
                            }
                            else
                            {
                                dtTempRow["MER_YN"] = "";
                            }
                        }


                        if (dt.Columns.Contains("RUN_STA_NM"))
                        {
                            dtTempRow["RUN_STA_NM"] = dt.Rows[i]["RUN_STA_NM"].ToString();
                        }
                        else
                        {
                            dtTempRow["RUN_STA_NM"] = "";
                        }

                        if (dt.Columns.Contains("STCK_STA_NM"))
                        {
                            dtTempRow["STCK_STA_NM"] = dt.Rows[i]["STCK_STA_NM"].ToString();
                        }
                        else
                        {
                            dtTempRow["STCK_STA_NM"] = "";
                        }


                        //결과 테이블에 저장
                        dtRtn.Rows.Add(dtTempRow);
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return dtRtn;
        }

        private DataTable setReqMergeList()
        {
            DataTable dtRtn = new DataTable();
            DataRow dtTempRow;
            DataTable dt = (DataTable)Grid1.DataSource;

            try
            {
                //테이블 양식 작성
                dtRtn.Columns.Add(new DataColumn("IND_BCD", typeof(string))); //개별바코드
                //dtRtn.Columns.Add(new DataColumn("MATNR", typeof(string))); //자재코드
                //dtRtn.Columns.Add(new DataColumn("UNIT", typeof(string))); //단위
                //dtRtn.Columns.Add(new DataColumn("PRFM_QTY", typeof(string))); //실적수량
                //dtRtn.Columns.Add(new DataColumn("LOT_NO", typeof(string))); //LOT NO
                //dtRtn.Columns.Add(new DataColumn("DOC_NO", typeof(string))); //MES 문서번호
                //dtRtn.Columns.Add(new DataColumn("DOC_SEQNO", typeof(string))); //MES 문서번호 순번
                //dtRtn.Columns.Add(new DataColumn("SDOC_NO", typeof(string))); //SAP 확정문서번호
                //dtRtn.Columns.Add(new DataColumn("SDOC_SEQNO", typeof(string))); //SAP 확정문서번호순번
                //dtRtn.Columns.Add(new DataColumn("RMK", typeof(string))); //비고내용

                for (int i = 0; i < dt.Rows.Count; i++)
                {
                    //선택된 행처리
                    if (dt.Rows[i]["CHK"].ToString().Equals("V"))
                    {
                        //조회결과 입력용 Row생성
                        dtTempRow = dtRtn.NewRow();
                        dtTempRow["IND_BCD"] = dt.Rows[i]["IND_BCD"].ToString();
                        //dtTempRow["MATNR"] = dt.Rows[i]["MATNR"].ToString();
                        //dtTempRow["UNIT"] = dt.Rows[i]["UNIT"].ToString();
                        //dtTempRow["PRFM_QTY"] = dt.Rows[i]["PRFM_QTY"].ToString().Replace(",", "");
                        //dtTempRow["LOT_NO"] = dt.Rows[i]["LOT_NO"].ToString();
                        //dtTempRow["DOC_NO"] = dt.Rows[i]["DOC_NO"].ToString();
                        //dtTempRow["DOC_SEQNO"] = dt.Rows[i]["DOC_SEQNO"].ToString().Replace(",", "");
                        //dtTempRow["SDOC_NO"] = dt.Rows[i]["SDOC_NO"].ToString();
                        //dtTempRow["SDOC_SEQNO"] = "";   // dt.Rows[i]["SDOC_SEQNO"].ToString();
                        //dtTempRow["RMK"] = dt.Rows[i]["RMK"].ToString();

                        //결과 테이블에 저장
                        dtRtn.Rows.Add(dtTempRow);
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return dtRtn;
        }

        private DataTable setReqDeleteList()
        {
            DataTable dtRtn = new DataTable();
            DataRow dtTempRow;
            DataTable dt = (DataTable)Grid1.DataSource;

            try
            {
                //테이블 양식 작성
                dtRtn.Columns.Add(new DataColumn("IND_BCD", typeof(string))); //개별바코드
                //재단만 => 전부적용
                //if(Common.OpCode == "CA")
                //{
                    dtRtn.Columns.Add(new DataColumn("LOT_NO", typeof(string))); //LotNo
                    dtRtn.Columns.Add(new DataColumn("MATNR", typeof(string))); //자재코드
                    dtRtn.Columns.Add(new DataColumn("WGT", typeof(string))); //실적중량
                    dtRtn.Columns.Add(new DataColumn("PRFM_QTY", typeof(double))); //실적연수
                //}
                
                for (int i = 0; i < dt.Rows.Count; i++)
                {
                    //선택된 행처리
                    if (dt.Rows[i]["CHK"].ToString().Equals("V"))
                    {
                        //조회결과 입력용 Row생성
                        dtTempRow = dtRtn.NewRow();

                        string sIND_BCD = dt.Rows[i]["IND_BCD"].ToString();
                        dtTempRow["IND_BCD"] = sIND_BCD;
                        LogFile.WriteLog("취소 바코드 : " + sIND_BCD);

                        //재단만 => 전부적용
                        //if (Common.OpCode == "CA") 
                        //{

                        string sLOT_NO = dt.Rows[i]["LOT_NO"].ToString();
                        string sMATNR = dt.Rows[i]["MATNR"].ToString();
                        string sWGT = dt.Rows[i]["WGT"].ToString();
                        double sPRFM_QTY = 0;

                        if (Common.OpCode == "CA" || Common.OpCode == "CB") 
                        {
                            //재단, 포장
                            if (dt.Rows[i]["PRFM_QTY"] != DBNull.Value && double.TryParse(dt.Rows[i]["PRFM_QTY"].ToString(), out double parsedQty))
                            {
                                if (Common.OpCode == "CB" & gsGB == "예외")
                                {
                                    sPRFM_QTY = parsedQty;
                                }
                                else
                                {
                                    sPRFM_QTY = parsedQty * 500;
                                }
                                
                            }
                        }
                        else if (Common.OpCode == "PC" || Common.OpCode == "PB")
                        {
                            string sPCNT = dt.Rows[i]["PCNT"].ToString();//실적연수
                            sPRFM_QTY = double.Parse(sPCNT);
                        }
                        else
                        {
                            //점보롤, 밀롤
                            sPRFM_QTY = double.Parse(sWGT);
                        }

                        dtTempRow["LOT_NO"] = sLOT_NO;
                        dtTempRow["MATNR"] = sMATNR;
                        dtTempRow["WGT"] = sWGT;
                        dtTempRow["PRFM_QTY"] = sPRFM_QTY;
                        
                        LogFile.WriteLog("취소 LOT_NO : " + sLOT_NO);
                        LogFile.WriteLog("취소 자재코드 : " + sMATNR);
                        LogFile.WriteLog("취소 중량 : " + sWGT);
                        LogFile.WriteLog("취소 량 : " + sPRFM_QTY);

                        //}

                        //결과 테이블에 저장
                        dtRtn.Rows.Add(dtTempRow);
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return dtRtn;
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

                e.row.Update();
            }

            //상세보기 클릭시 팝업화면 호출
            if (e.column.ToString() == "DBTN")
            {
                string sWrkOrder = e.row.Cells["WRK_ORDR_NO"].Value.ToString();
                string sWrkOrderSeq = e.row.Cells["WRK_ORDR_SEQNO"].Value.ToString();
                string sIND_BCD = e.row.Cells["IND_BCD"].Value.ToString();

                //public static string PROC_INP = "PROC_INP";        // 작업지시선택 투입정보
                //public static string PROC_WRK = "PROC_WRK";        // 주작업 표시 정보
                //public static string PROC_PRFM = "PROC_PRFM";      // 실적현황 표시 정보
                POP_WRK84 popWrk84 = new POP_WRK84(POP_WRK84.PROC_PRFM, Common.PlantCode, Common.OpCode, sWrkOrder, sWrkOrderSeq, sIND_BCD);  // 작업지시 정보
                popWrk84.LabelTitle = "실적현황 상세보기";

                ShowDialogForm(popWrk84);
            }
        }
        #endregion

        private void btnFind_Click(object sender, EventArgs e)
        {
            SetGrid(); 
        }

        private void butWorkStartDate_Click(object sender, EventArgs e)
        {
            DAResultDate pop = new DAResultDate(cboWorkStartDate.Value);
            pop.ShowDialog(this);
            if (pop.DialogResult == DialogResult.OK)
            {
                string strDate = pop.ResultString.ToString();
                cboWorkStartDate.Value = DateTime.Parse(strDate);
            }
        }

        private void butWorkEndDate_Click(object sender, EventArgs e)
        {
            DAResultDate pop = new DAResultDate(cboWorkEndDate.Value);
            pop.ShowDialog(this);
            if (pop.DialogResult == DialogResult.OK)
            {
                string strDate = pop.ResultString.ToString();
                cboWorkEndDate.Value = DateTime.Parse(strDate);
            }
        }

        private void textBox_KeyPress(object sender, KeyPressEventArgs e)
        {
            if (!(char.IsDigit(e.KeyChar) || e.KeyChar == Convert.ToChar(Keys.Back)))    //숫자와 백스페이스를 제외한 나머지를 바로 처리
            {
                e.Handled = true;
            }

        }
    }
}
