#region [ USING AREA ]
using System;
using System.Configuration;
using System.Data;
using System.Windows.Forms;
using Infragistics.Win.UltraWinGrid;

using SAMMI;
using SmartDas.Components;
using SmartDas.POPUP;
using System.Drawing;

#endregion

namespace SmartDas
{
    public partial class POP_WRK01 : BaseForm
    {
        #region < MEMBER AREA >

        private SAMMI.Common _common = new SAMMI.Common();

        private static string gsLOC_CD = string.Empty;
        private string gsRESULT = "NG";     // 본 화면에서 데이타 변경( 투입, etc) 발생 여부를 넘기기 위해...

        public static readonly string LOC_MA_2100 = "L2100";    // 리와인더
        public static readonly string LOC_SA_2200 = "L2200";    // 슬리터
        public static readonly string LOC_PA_2300 = "L2300";    // 원지포장
        public static readonly string LOC_CB_2400 = "L2400";    // 수재단
        public static readonly string LOC_CA_2700 = "2700";     // 재단           //"L2900";    --밀롤창고 입고대기 창고
        public static readonly string LOC_ZA_2500 = "L2500";    // 문제제품적재소
        public static readonly string LOC_PB_2600 = "L2600";    // 포장           //"L2800"   --포장 완료 입고대기 창고;      
        #endregion

        #region < CONSTRUCTOR >

        public POP_WRK01()
        {
            InitializeComponent();

            Common.SetMessageList();
        }

        public POP_WRK01(string sLOC_CD)
        {
            InitializeComponent();

            Common.SetMessageList();

            gsLOC_CD = sLOC_CD;
            lblLocation.Text = sLOC_CD;
        }
        #endregion

        #region < POP_WRK01_Load >
        private void POP_WRK01_Load(object sender, EventArgs e)
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

                this.lblTitle.Text = "공정투입";

                SetMenuButtons();

                SetGrid();
                DoFind();
            }
            catch (Exception ex)
            {
                SetMessage("POP_WRK01_Load_ Error!");
                LogFile.WriteLog("POP_WRK01.POP_WRK01_Load Error => " + ex.Message);
            }

            if (string.IsNullOrEmpty(gsLOC_CD))
            {
                new POPUP.MessageForm("로케이션 코드를 전달 받지 못했습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                Close();
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

                bBox1[0, 0].Text = "공정투입";
                bBox1[0, 0].Tag = "Confirm";
                bBox1[0, 0].MappingButton.FontSize = 14;
                bBox1[0, 1].Text = "공정투입" + Environment.NewLine + "이력";
                bBox1[0, 1].Tag = "InputLog";
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
                LogFile.WriteLog("POP_WRK01.SetButtons Error => " + ex.Message);
            }
        }

        private void DoFind()
        {

            //////2018 05 03 hjh 
            //////처음 메인화면 접속 시, 라인 선택 후, 작업자 선택 후, 지시 선택 후 호출
            //Grid1.SetStoreProc();
            //Grid1.ParameterList.Add(new SqlParameter("OrderDateS", SqlDbType.VarChar));
            //Grid1.ParameterList.Add(new SqlParameter("OrderDateE", SqlDbType.VarChar));
            //Grid1.ParameterList.Add(new SqlParameter("Flag", SqlDbType.VarChar));
            //Grid1.ParameterList.Add(new SqlParameter("LineCode", SqlDbType.VarChar));
            //Grid1.ParameterList["OrderDateS"].Value = cboOrderDateS.Text;
            //Grid1.ParameterList["OrderDateE"].Value = cboOrderDateE.Text;
            
            //Grid1.DoFind();
            
            //lblItemCode.Text = string.Empty;
            //lblLotNo.Text = string.Empty;
            //lblRemark.Text = string.Empty;
            //lblPType.Text = string.Empty;
            //lblOrderType.Text = string.Empty;
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

            // string sPRFM_DT = cboWorkDate.Value.ToString("yyyyMMdd");

            try
            {
                Grid1.HeaderFontSize = 13;
                Grid1.FontSize = 13;
                Grid1.CountRows = 11;
                Grid1.AutoScroll = true;
                Grid1.DisplayLayout.Scrollbars = Scrollbars.Automatic;
                Grid1.DisplayLayout.Bands[0].Override.SelectTypeCol = SelectType.None;

                btnRightPage.LinkMoveSize = Grid1.CountRows;
                btnLeftPage.LinkMoveSize = Grid1.CountRows;

                //버튼 목록 조회
                dtRtn = helper.FillTable("SP_POP_WRK01_S01", CommandType.StoredProcedure
                                                    , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)     // 플랜트코드
                                                    , helper.CreateParameter("P_LOC_CD", gsLOC_CD, DbType.String, ParameterDirection.Input)            // 로케이션코드
                                                    , helper.CreateParameter("P_MACHINE", Common.MachineNo, DbType.String, ParameterDirection.Input)      // 공정호기 (PM2, PM3)
                                                    , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)      // 작업장코드(설비코드)
                                                    , helper.CreateParameter("P_STR_DATE", "", DbType.String, ParameterDirection.Input)      // 조회 시작
                                                    , helper.CreateParameter("P_END_DATE", "", DbType.String, ParameterDirection.Input)      // 조회 끝
                                                    , helper.CreateParameter("P_ORDER_NO", txtORDER_NO.Text, DbType.String, ParameterDirection.Input)      // 오더번호
                                                    , helper.CreateParameter("P_IND_BCD", txtIND_BCD.Text, DbType.String, ParameterDirection.Input)      // 개별바코드
                                                    , helper.CreateParameter("P_PCODE", txtPCODE.Text, DbType.String, ParameterDirection.Input)      // 지종
                                                    , helper.CreateParameter("P_BS_WGT", txtBS_WGT.Text, DbType.String, ParameterDirection.Input)      // 평량
                                                    , helper.CreateParameter("P_WLEN", "", DbType.String, ParameterDirection.Input)      // 가로길이
                                                    , helper.CreateParameter("P_VLEN", "", DbType.String, ParameterDirection.Input)      // 세로길이
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
                        Grid1.DisplayLayout.Bands[0].Columns["IND_BCD"].MergedCellStyle = MergedCellStyle.Always;
                        //Grid1.DisplayLayout.Override.MergedCellAppearance.BackColor = Color.LightYellow;

                        // 첫번째 행 선택
                        Grid1.Rows[0].Selected = true;
                        Grid1.Row = Grid1.Rows[0];

                        // 첫번째열 고정
                        Grid1.DisplayLayout.UseFixedHeaders = true;
                        Grid1.DisplayLayout.Bands[0].Columns["CHK"].Header.Fixed = true;
                        Grid1.DisplayLayout.Bands[0].Override.FixedHeaderIndicator = FixedHeaderIndicator.None;
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
                LogFile.WriteLog("POP_WRK01.SetGrid Error => " + ex.Message);
            }
        }

        private void doConfirm()
        {
            if (Grid1.Rows.Count < 1)
            {
                new POPUP.MessageForm("대기로케이션 정보가 없습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return;
            }

            if (Grid1.Row == null)
            {
                new POPUP.MessageForm("선택된 로케이션 정보가 없습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return;
            }


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

                if (Common.Auth_Package == false)
                {
                    return;
                }
            }



            //체크된 항목 확인
            DataTable dtReqList = setReqList();
            int iRowCnt = dtReqList.Rows.Count;

            if (iRowCnt == 0)
            {
                new POPUP.MessageForm("선택된 개별바코드가 없습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return;
            }

            string sIND_BCD_LIST = "";
            for (int i = 0; i < iRowCnt; i++)
            {
                // 개별바코드리스트에 포함되지 않은경우 추가...
                if (i < 5)
                {
                    if (i == (iRowCnt - 1))
                        sIND_BCD_LIST += dtReqList.Rows[i]["IND_BCD"].ToString();
                    else
                        sIND_BCD_LIST += dtReqList.Rows[i]["IND_BCD"].ToString() + ", ";
                }
            }
            
            sIND_BCD_LIST = sIND_BCD_LIST.Trim();
            sIND_BCD_LIST = sIND_BCD_LIST.TrimEnd(',');

            if (iRowCnt > 5)
            {
                sIND_BCD_LIST += string.Format("\r\n외 {0}건 투입 합니다.", iRowCnt - 5);
            }

            if (new POPUP.MessageForm(string.Format("선택된 개별바코드를 투입 하시겠습니까?\r\n\r\n{0}", sIND_BCD_LIST), MessageBoxButtons.OKCancel, "알   림").ShowDialog(this) == DialogResult.Cancel)
            {
                return;
            }

            DBHelper helper = new DBHelper();
            try
            {
                this.Cursor = Cursors.WaitCursor;   //Waitting

                for (int i = 0; i < iRowCnt; i++)
                {
                    string sIND_BCD = dtReqList.Rows[i]["IND_BCD"].ToString();
                    string sGUBUN = dtReqList.Rows[i]["GUBUN"].ToString();

                    helper.ExecuteNoneQuery("SP_POP_WRK01_I01", CommandType.StoredProcedure
                        , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)               // 플랜트
                        , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)           // 작업장코드(설비코드)
                        , helper.CreateParameter("P_IND_BCD", sIND_BCD, DbType.String, ParameterDirection.Input)                    // 개별바코드
                        , helper.CreateParameter("P_STOR_LOC_CD", gsLOC_CD, DbType.String, ParameterDirection.Input)                // 로케이션코드
                        , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input)                 // 사용자ID
                        , helper.CreateParameter("P_EXCEPTION", sGUBUN, DbType.String, ParameterDirection.Input)                 // 예외인경우 : "E"로 전달
                        );

                    if (helper.RSCODE == "E")
                    {
                        new POPUP.MessageForm(helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                        gsRESULT = "";

                        break;
                    }
                    else
                    {
                        //new POPUP.MessageForm("공정투입이 정상적으로 완료되었습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                        gsRESULT = "OK";

                        //Thread.Sleep(100);
                    }
                }
            }
            catch (Exception ex)
            {
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                LogFile.WriteLog("POP_WRK01.doConfirm Error => " + ex.Message);
                gsRESULT = "";
            }
            finally
            {
                helper.Close();
                    
                SetGrid();

                this.Cursor = Cursors.Default;   //Waitting
                if (gsRESULT == "OK")
                {
                    new POPUP.MessageForm("공정투입이 정상적으로 완료되었습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                }

            }

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
                    case "Confirm":     //공정투입
                        doConfirm();
                        break;

                    case "InputLog":    // 공정투입 이력조회
                        POP_WRK42 WRK42 = new POP_WRK42(gsLOC_CD);
                        if (ShowDialogForm(WRK42) == DialogResult.OK)
                            gsRESULT = "OK";
                        else
                            gsRESULT = "NG";

                        SetGrid();
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
                LogFile.WriteLog("POP_WRK01.bBox1_buttonClickEvent Error => " + ex.Message);
            }
            finally
            {

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
                dtRtn.Columns.Add(new DataColumn("IND_BCD", typeof(string)));           //개별바코드
                dtRtn.Columns.Add(new DataColumn("GUBUN", typeof(string)));                //지시구분 (예외생산 구분을 위해 추가)

                string sIND_BCD_LIST = "";
                for (int i = 0; i < dt.Rows.Count; i++)
                {
                    //선택된 행처리
                    if (dt.Rows[i]["CHK"].ToString().Equals("V"))
                    {
                        // 개발바코드리스트에 포함되지 않은경우가 추가...
                        if (sIND_BCD_LIST.Contains(dt.Rows[i]["IND_BCD"].ToString()))
                        {
                            continue;
                        }
                        sIND_BCD_LIST += dt.Rows[i]["IND_BCD"].ToString() + ", ";


                        //조회결과 입력용 Row생성
                        dtTempRow = dtRtn.NewRow();

                        dtTempRow["IND_BCD"] = dt.Rows[i]["IND_BCD"].ToString();

                        string sGUBUN = "";
                        // "GU" 칼럼이 있으면 예외 생산인지 확인하여 전달
                        if (dt.Columns.Contains("GU"))
                        {
                            if (dt.Rows[i]["GU"].ToString() == "예외")
                            {
                                sGUBUN = "E";
                            }
                        }

                        dtTempRow["GUBUN"] = sGUBUN;

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

        private void cboOrderDate_ValueChanged(object sender, EventArgs e)
        {
                DoFind();
        }

        private void Grid1_ClickCellButton(object sender, MESGrid.GridClickEventArg e)
        {
            // 선택 버튼 클릭시 체크여부 변경
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
            //else if (e.column.ToString() == "SEL")
            //{
            //    string sStatus_Pre = e.row.Cells["SEL"].Value.ToString();

            //    if (sStatus_Pre == "선택")
            //    {
            //        e.row.Cells["SEL"].Value = "-";
            //    }
            //    else
            //    {
            //        e.row.Cells["SEL"].Value = "선택";
            //    }
            //}
            else if (e.column.ToString() == "DBTN") // 상세보기
            {
                string sWrkOrder = e.row.Cells["WRK_ORDR_NO"].Value.ToString();
                string sWrkOrderSeq = e.row.Cells["WRK_ORDR_SEQNO"].Value.ToString();
                string sIND_BCD = e.row.Cells["IND_BCD"].Value.ToString();

                POP_WRK84 popWrk84 = new POP_WRK84(POP_WRK84.PROC_INP_PRFM, Common.PlantCode, Common.OpCode, sWrkOrder, sWrkOrderSeq, sIND_BCD);  // 작업지시 정보
                popWrk84.LabelTitle = "공정투입 상세보기";

                ShowDialogForm(popWrk84);
            }
        }
        #endregion

        private void btnFind_Click(object sender, EventArgs e)
        {
            SetGrid();
        }
    }
}
