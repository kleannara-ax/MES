#region [ USING AREA ]
using System;
using System.Configuration;
using System.Data;
using System.Windows.Forms;
using System.Drawing;
using Infragistics.Win;
using Infragistics.Win.UltraWinGrid;

using SAMMI;
using SmartDas.Components;
using SmartDas.POPUP;

#endregion

namespace SmartDas
{
    public partial class POP_INV04 : BaseForm
    {
        #region < MEMBER AREA >

        private SAMMI.Common _common = new SAMMI.Common();

        private static string sGrpCode = string.Empty;
        private static string userID = string.Empty;
        private static string userName = string.Empty;

        #endregion

        #region < CONSTRUCTOR >

        public POP_INV04()
        {
            InitializeComponent();

            Common.SetMessageList();

        }
        #endregion

        #region < POP_INV04_Load >
        private void POP_INV04_Load(object sender, EventArgs e)
        {
            //string sSubTitle = string.Empty;
            try
            {
                #region --- 언어 설정 → 모듈별로 화면 첫 화면 분기되는 화면에 해당 코드 삽입 ---
                Configuration appConfig = ConfigurationManager.OpenExeConfiguration(ConfigurationUserLevel.None);

                SAMMI.Common.SystemID = appConfig.AppSettings.Settings["SystemID"].Value.ToString();
                SAMMI.Common.Lang = appConfig.AppSettings.Settings["LANGUAGE"].Value.ToString();

                DataTable rtnDtTemp = _common.GET_TBM0000_CODE("LANGKY");

                SAMMI.Common.FontName = Convert.ToString(((DataRow[])rtnDtTemp.Select("CODE_ID = '" + SAMMI.Common.Lang + "'"))[0]["RelCode1"]);
                #endregion

                this.lblTitle.Text = "재단대기창고 현황조회";

                //sSubTitle = "< ";
                //sSubTitle = sSubTitle + "설비정보";//Common.MachineName;
                //sSubTitle = sSubTitle + " - ";
                ////sSubTitle = sSubTitle; //작업조 추가필요
                //sSubTitle = sSubTitle + " >";

                SetMenuButtons();
                SetGroupButtons();

                SetGrid(sGrpCode);
            }
            catch (Exception ex)
            {
                SetMessage("POP_INV04_Load Error!");
                LogFile.WriteLog("POP_INV04.POP_INV04_Load Error => " + ex.Message);
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

                bBox1[0, 0].Text = "상세정보";
                bBox1[0, 0].Tag = "Detail";
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
                LogFile.WriteLog("POP_INV04.SetButtons Error => " + ex.Message);
            }
        }

        private void SetGroupButtons()
        {
            DBHelper helper = new DBHelper();
            DataTable dt = new DataTable();

            try
            {
                bGroup.ButtonBoxType = ButtonBox.ButtonBoxTypeEnum.Selection;
                bGroup.SelectionMode = ButtonBox.SelectionModeEnum.Single;

                //출력 버튼수
                bGroup.CountX = 11;
                bGroup.CountY = 1;
                //이동 간격
                //bGroup_Up.LinkMoveSize = bGroup.CountY;
                //bGroup_Down.LinkMoveSize = bGroup.CountY;
                //버튼 폰트
                bGroup.FontSize = 14;
                //버튼 목록 조회
                System.Data.DataSet ds = helper.FillDataSet("SP_POP_INV04_S01", CommandType.StoredProcedure
                                                               , helper.CreateParameter("P_PROC_CD", Common.OpCode, DbType.String, ParameterDirection.Input));
                if (ds.Tables[0].Rows.Count < 1)
                {
                    SetMessage("조회된 재단 설비가 없습니다.");
                    return;
                }
                else
                {
                    bGroup.DoFind_Oracle(ds);
                }
                //버튼 출력
                bGroup.RedrawButtons();
#if true
                bGroup[0, 0].ButtonPressed = true;
                sGrpCode = bGroup[0, 0].Tag.ToString();
#else
                // 선택된 설비를 먼저 보여줌.
                bool bGropSelect = false;
                for (int ny = 0; ny < bGroup.CountX; ny++)
                {
                    if (Common.MachineCode == bGroup[0, ny].Tag.ToString())
                    {
                        bGroup[0, ny].ButtonPressed = true;
                        sGrpCode = bGroup[0, ny].Tag.ToString();
                        bGropSelect = true;
                        break;
                    }
                }

                if (bGropSelect == false)
                {
                    bGroup[0, 0].ButtonPressed = true;
                    sGrpCode = bGroup[0, 0].Tag.ToString();
                }
#endif
            }
            catch (Exception ex)
            {
                SetMessage("SetOPButtons Error!");
                LogFile.WriteLog("DA0110.SetOPButtons Error => " + ex.Message);
            }
        }


        private void SetGrid(string sMachineCode)
        {

            DBHelper helper = new DBHelper();
            string sColInfo = string.Empty;
            string sColType = string.Empty;

            DataSet dsTemp = new DataSet();
            DataSet dsRtn = new DataSet();

            DataTable dtTemp = new DataTable();

            try
            {
                Grid1.HeaderFontSize = 13;
                Grid1.FontSize = 12;
                Grid1.CountRows = 8;
                Grid1.AutoScroll = true;
                Grid1.DisplayLayout.Scrollbars = Scrollbars.Vertical;

                btnRightPage.LinkMoveSize = Grid1.CountRows;
                btnLeftPage.LinkMoveSize = Grid1.CountRows;

                // WERKS = 'P100' AND LOC_CD = 'L2900' AND STCK_QTY > 0
                // WERKS = 'P100' AND STOR_LOC_CD = '2700' AND STCK_QTY > 0
                // 재단 대기창고 조회
                dsTemp = helper.FillDataSetN("SP_POP_INV04_S02", CommandType.StoredProcedure, 2
                                                    , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)     // 플랜트코드
                                                    , helper.CreateParameter("P_MACH_CD", sMachineCode, DbType.String, ParameterDirection.Input)      // 작업장코드(설비코드)
                                                    );

                if (dsTemp.Tables[1].Rows.Count < 1)
                {
                    //SetMessage("대기창고에 조회된 정보가 없습니다.");
                }

                if (helper.RSCODE.Equals("S"))
                {
                    DataTable dt1 = new DataTable();
                    dt1.TableName = "HeaderTable";
                    dt1.Columns.Add("RTN_VALUES", typeof(string));

                    DataTable dt2 = new DataTable();
                    dt2.Columns.Add("SEQ", typeof(string));
                    {

                        string sValue1 = "순번@C^80";
                        string sValue2 = "SEQ@varchar";
                        string sColWidth = "@C^232";    // 칼럼이 5개인경우

                        if (dsTemp.Tables[0].Rows.Count < 5)
                        {
                            sColWidth = "@C^290";
                        }

                        if (dsTemp.Tables[0].Rows.Count > 5)
                        {
                            Grid1.DisplayLayout.Scrollbars = Scrollbars.Both;
                        }


                        foreach (DataRow drow in dsTemp.Tables[0].Rows)
                        {
                            sValue1 += "|" + drow["LOC_NM"].ToString().Replace(" # ", "\n# ") + sColWidth;
                            sValue2 += "|" + drow["LOC_CD"].ToString() + "@varchar";

                            dt2.Columns.Add(drow["LOC_CD"].ToString(), typeof(string));         //
                        }
                        DataRow row = dt1.NewRow();
                        row["RTN_VALUES"] = sValue1;
                        dt1.Rows.Add(row);

                        DataRow row2 = dt1.NewRow();
                        row2["RTN_VALUES"] = sValue2;
                        dt1.Rows.Add(row2);

                    }


                    foreach (DataRow drData in dsTemp.Tables[1].Rows)
                    {
                        DataRow row = dt2.NewRow();

                        row["SEQ"] = drData["SEQ"].ToString();

                        foreach (DataRow drCol in dsTemp.Tables[0].Rows)
                        {
                            string sColNm = drCol["LOC_CD"].ToString();

                            string sData = drData[sColNm].ToString().Replace("|", "\n");

                            row[sColNm] = sData;
                        }
                        dt2.Rows.Add(row);
                    }

                    //그리드 출력
                    dsRtn.Tables.Add(dt1.Copy());
                    dsRtn.Tables.Add(dt2.Copy());
                    Grid1.DoFind_Oracle(dsRtn);

                    //그리드 설정
                    //Grid1.Row.Band.Override.CellMultiLine = DefaultableBoolean.True;
                    //Grid1.DisplayLayout.Override.DefaultRowHeight = 50;

                    // Header 2라인 표시
                    //Grid1.DisplayLayout.Override.WrapHeaderText = DefaultableBoolean.True;
                    Grid1.DisplayLayout.Bands[0].ColHeaderLines = 2;
                    //Grid1.DisplayLayout.Bands[0].GroupHeaderLines = 2;

                    // Header click 무시
                    Grid1.DisplayLayout.Bands[0].Override.SelectTypeCol = SelectType.None;

                    // Cell Multi Line 및 가운데 정령
                    //Grid1.DisplayLayout.Override.CellAppearance.TextHAlign = HAlign.Center;
                    Grid1.DisplayLayout.Override.CellAppearance.TextVAlign = VAlign.Middle;
                    Grid1.DisplayLayout.Override.CellMultiLine = DefaultableBoolean.True;
                    Grid1.DisplayLayout.Override.CellDisplayStyle = CellDisplayStyle.FormattedText;


                    // 한개의 CELL 만 선택 가능하도록 지정
                    Grid1.DisplayLayout.Override.SelectTypeCell = SelectType.Single;
                    Grid1.DisplayLayout.Override.SelectTypeRow = SelectType.None;
                    Grid1.DisplayLayout.Override.SelectTypeCol = SelectType.None;

                    Grid1.DisplayLayout.Override.SelectedCellAppearance.ForeColor = Color.Black;
                    Grid1.DisplayLayout.Override.SelectedCellAppearance.BackColor = Color.Wheat;
                    Grid1.DisplayLayout.Override.SelectedCellAppearance.FontData.Bold = DefaultableBoolean.False;

                    Grid1.DisplayLayout.Override.SelectTypeCol = SelectType.None;

                    Grid1.DisplayLayout.Bands[0].Columns["SEQ"].CellActivation = Activation.Disabled;

                    Color txtColor = Color.Black;

                    if (Grid1.Rows.Count > 0)
                    {
                        foreach (UltraGridRow rc in Grid1.Rows)
                        {
                            foreach (UltraGridCell cell in rc.Cells)
                            {
                                if (cell.Column.ToString().Equals("SEQ") == false)
                                {
                                    string sCellData = cell.Value.ToString();

                                    if (string.IsNullOrEmpty(sCellData))
                                        continue;

                                    //string sValue = sCellData.Substring(14, 1);
                                    string[] Words = sCellData.Split('@');

                                    cell.Value = Words[0];
                                    
                                    txtColor = Color.Black;
                                    if (Words[1] == "PM2")
                                    {
                                        txtColor = Color.Red;
                                    }
                                    else if (Words[1] == "PM3")
                                    {
                                        txtColor = Color.Blue;
                                    }

                                    if (Words.Length > 2)
                                    {
                                        //지급분에 대해서 폰트 굵게 표시
                                        if (Words[2] == "Y")
                                        {
                                            cell.Appearance.FontData.Bold = DefaultableBoolean.True;
                                            cell.SelectedAppearance.FontData.Bold = DefaultableBoolean.True;
                                        }
                                    }

                                    {
                                        string[] sWords2 = Words[0].Split('\n');

                                        string[] sPW  = sWords2[1].Split('/');
                                        string[] sWV = sWords2[2].Split('*');               // 가로, 세로

                                        string sIND_BCD = sWords2[0];   // 개별바코드
                                        string sPCODE = sPW[0];         //  지종
                                        string sWEIGHT = sPW[1];        //   평량
                                        string sWLEN = sWV[0];          //  가로
                                        string sVLEN = sWV[1];          //   세로

                                        if (String.IsNullOrEmpty(txtPCODE.Text)==false ||
                                            String.IsNullOrEmpty(txtWEIGHT.Text) == false ||
                                            String.IsNullOrEmpty(txtWLEN.Text) == false ||
                                            String.IsNullOrEmpty(txtVLEN.Text) == false ||
                                            String.IsNullOrEmpty(txtIND_BCD.Text) == false)
                                        {
                                            if ((sPCODE.Equals(txtPCODE.Text)==true || String.IsNullOrEmpty(txtPCODE.Text)) && 
                                                (sWEIGHT.Equals(txtWEIGHT.Text)==true || String.IsNullOrEmpty(txtWEIGHT.Text)) &&
                                                (sIND_BCD.Equals(txtIND_BCD.Text) == true || String.IsNullOrEmpty(txtIND_BCD.Text)) &&
                                                (sWLEN.Contains(txtWLEN.Text)==true || String.IsNullOrEmpty(txtWLEN.Text)) &&
                                                (sVLEN.Contains(txtVLEN.Text)==true || String.IsNullOrEmpty(txtVLEN.Text)) )
                                            {
                                                
                                                cell.Appearance.BackColor = Color.Yellow;
                                            }
                                        }
                                    }

                                    cell.Appearance.ForeColor = txtColor;
                                    cell.SelectedAppearance.ForeColor = txtColor;
                                }
                            }

                            rc.Update();
                        }

                        // 첫번째 행 선택
                        Grid1.Rows[0].Selected = true;
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
                LogFile.WriteLog("POP_WRK04.SetGrid Error => " + ex.Message);
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
                    case "Detail":  //상세보기
                        try
                        {
                            if (Grid1.Row == null)
                                return;

                            string sData = Grid1.Row.Cells[Grid1.Col].Value.ToString();

                            if (string.IsNullOrEmpty(sData))
                                return;

                            //string sMsg = string.Format("밀롤 정보\r\n{0}", sData);
                            //new POPUP.MessageForm(sMsg, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                            string[] Words = sData.Split('\n');
                            DetailView(Words[0]);
                        }
                        catch (Exception ex)
                        {
                            Console.WriteLine(ex.Message);
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
            }

            catch (Exception ex)
            {
                SetMessage(ex.Message);
                LogFile.WriteLog("POP_INV04.bBox1_buttonClickEvent Error => " + ex.Message);
            }
            finally
            {

            }
        }


        private void bGroup_buttonChangeEvent(MESButton sender, ButtonBox.ButtonClickEventArg e)
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
                    case "PCA01":  // 1재단기
                    case "PCA02":  // 2재단기
                    case "PCA03":  // 3재단기
                    case "PCA04":  // 4재단기
                    case "PCA05":  // 5재단기
                    case "PCA06":  // 6재단기
                    case "PCA07":  // 7재단기
                    case "PCA08":  // 8재단기
                    case "PCA09":  // 9재단기
                    case "PCA10":  // 9재단기
                    case "PCA11":  // 9재단기
                    {
                        sGrpCode = btn.Tag.ToString();
                        SetGrid(sGrpCode);
                    }
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
                LogFile.WriteLog("POP_INV04.bGroup1_buttonClickEvent Error => " + ex.Message);
            }
            finally
            {

            }
        }
        #endregion

        private void DetailView(string sIND_BCD)
        {
            DBHelper helper = new DBHelper(false);

            try
            {
                helper.ExecuteNoneQuery("SP_POP_INV04_S03", CommandType.StoredProcedure
                                 , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)
                                 , helper.CreateParameter("P_IND_BCD", sIND_BCD, DbType.String, ParameterDirection.Input)
                                 , helper.CreateParameter("RS_WRK_ORDR_NO", DbType.String, ParameterDirection.Output, null, 100)
                                 , helper.CreateParameter("RS_WRK_ORDR_SEQNO", DbType.String, ParameterDirection.Output, null, 100)
                                 );

                if (helper.RSCODE == "S")
                {
                    string sWrkOrder = helper.Parameters["RS_WRK_ORDR_NO"].Value.ToString();
                    string sWrkOrderSeq = helper.Parameters["RS_WRK_ORDR_SEQNO"].Value.ToString();

                    POP_WRK81 popWrk81 = new POP_WRK81(Common.PlantCode, Common.OpCode, sWrkOrder, sWrkOrderSeq, sIND_BCD);  // 작업지시 정보
                    ShowDialogForm(popWrk81);

                    SetGrid(sGrpCode);
                }
            }
            catch (Exception ex)
            {
                SetMessage("정보가 없습니다.");
                LogFile.WriteLog("SP_POP_INV04_S03.DateSet Error => " + ex.Message);
            }
            finally
            {
                helper.Close();
            }
        }

        private void Grid1_GridDoubleClick(object sender, MESGrid.GridClickEventArg e)
        {
            try
            {
                string sColumnName = e.column.ToString();

                if (sColumnName.Equals("SEQ"))
                    return;


                string sData = e.cell.Value.ToString();

                if (string.IsNullOrEmpty(sData))
                    return;

                //string sMsg = string.Format("밀롤 정보\r\n{0}", sData);
                //new POPUP.MessageForm(sMsg, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                string[] Words = sData.Split('\n');
                DetailView(Words[0]);
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
            }
        }

        private void btnFind_Click(object sender, EventArgs e)
        {
            SetGrid(sGrpCode);
        }

        private void txtContent_KeyPress(object sender, KeyPressEventArgs e)
        {
            //숫자만 입력되도록 필터링
            if (e.KeyChar == Convert.ToChar(Keys.Enter))
            {
                SetGrid(sGrpCode);
            }
            else if (!(char.IsDigit(e.KeyChar) || e.KeyChar == Convert.ToChar(Keys.Back)))    //숫자와 백스페이스를 제외한 나머지를 바로 처리
            {
                e.Handled = true;
            }
        }

        private void txtPCODE_KeyPress(object sender, KeyPressEventArgs e)
        {
            if (e.KeyChar == Convert.ToChar(Keys.Enter))
            {
                SetGrid(sGrpCode);
            }
        }
    }
}
