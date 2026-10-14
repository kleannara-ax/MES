#region [ USING AREA ]
using System;
using System.Configuration;
using System.Data;


using SAMMI;
using SmartDas.Components;

#endregion

namespace SmartDas
{
    public partial class POP_WRK35 : BaseForm
    {
        #region < MEMBER AREA >

        private SAMMI.Common _common = new SAMMI.Common();


        private string sGrpCode = string.Empty;
        private string gsTitle = string.Empty;

        public string sSelectGrpCode = string.Empty;

        public string DispoCode { get; set; }
        public string DispoName { get; set; }
        
        #endregion

        #region < CONSTRUCTOR >

        public POP_WRK35()
        {
            InitializeComponent();

            Common.SetMessageList();

            DispoCode = string.Empty;
            DispoName = string.Empty;
        }

        public string LabelTitle
        {
            get { return gsTitle; }
            set { gsTitle = value; }
        }

        #endregion

        #region < POP_WRK35_Load >
        private void POP_WRK35_Load(object sender, EventArgs e)
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

                if (string.IsNullOrEmpty(gsTitle))
                    this.lblTitle.Text = "폐품 등록";
                else
                    this.lblTitle.Text = gsTitle;

                SetMenuButtons();
                SetGroupButtons(Common.OpCode);
                SetItemButtons(Common.OpCode, sGrpCode);
                //DoFind();

            }
            catch (Exception ex)
            {
                SetMessage("POP_WRK35_Load_ Error!");
                LogFile.WriteLog("POP_WRK35.POP_WRK35_Load Error => " + ex.Message);
            }

            //현재 메시지큐에 있는 모든 메시지 처리함수 
            System.Windows.Forms.SendKeys.Flush();
        }

        #endregion

        #region < METHOD AREA >

        private void DoFind()
        {

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

                bBox1[0, 0].Text = "폐품선택";
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
                LogFile.WriteLog("POP_WRK35.SetButtons Error => " + ex.Message);
            }

        }



        private void SetGroupButtons(string pGrp)
        {
            DBHelper helper = new DBHelper();

            try
            {
                bGroup.ButtonBoxType = ButtonBox.ButtonBoxTypeEnum.Selection;
                bGroup.SelectionMode = ButtonBox.SelectionModeEnum.Single;

                //출력 버튼수
                bGroup.CountX = 5;
                bGroup.CountY = 1;
                //이동 간격
                bGroup_Up.LinkMoveSize = bItem.CountY;
                bGroup_Down.LinkMoveSize = bItem.CountY;
                //버튼 폰트
                bGroup.FontSize = 20;
                //버튼 목록 조회
                System.Data.DataSet ds = helper.FillDataSet("SP_POP_WRK36_S01", CommandType.StoredProcedure
                                                               , helper.CreateParameter("P_PROC_CD", pGrp, DbType.String, ParameterDirection.Input));
                if (ds.Tables[0].Rows.Count < 1)
                {
                    SetMessage("조회된 폐품그룹이 없습니다.");
                    return;
                }
                else
                {
                    bGroup.DoFind_Oracle(ds);
                }

                bGroup[0, 0].ButtonPressed = true;
                sGrpCode = bGroup[0, 0].Tag.ToString();

                //버튼 출력
                bGroup.RedrawButtons();

            }
            catch (Exception ex)
            {
                SetMessage("SetOPButtons Error!");
                LogFile.WriteLog("DA0110.SetOPButtons Error => " + ex.Message);
            }
        }

        private void SetItemButtons(string pGrp, string pDispoClass)
        {
            DBHelper helper = new DBHelper();

            try
            {
                //작업자
                bItem.ButtonBoxType = ButtonBox.ButtonBoxTypeEnum.Selection;
                bItem.SelectionMode = ButtonBox.SelectionModeEnum.Single;

                //출력 버튼수
                bItem.CountX = 4;
                bItem.CountY = 5;

                //화살표 클릭시 이동수
                bItem_Up.LinkMoveSize = bItem.CountY;
                bItem_Down.LinkMoveSize = bItem.CountY;

                btnLeftPage.LinkMoveSize = bItem.CountY;
                btnRightPage.LinkMoveSize = bItem.CountY;

                //버튼 폰트
                bItem.FontSize = 14;
                //버튼 목록 조회
                System.Data.DataSet ds = helper.FillDataSet("SP_POP_WRK36_S02", CommandType.StoredProcedure
                                                               , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_PROC_CD", pGrp, DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_DISPO_CLASS", pDispoClass, DbType.String, ParameterDirection.Input));
                if (ds.Tables[0].Rows.Count < 1)
                {
                    SetMessage("조회된 폐품항목이 없습니다.");
                    return;
                }
                else
                {
                    bItem.DoFind_Oracle(ds);
                }

                // 이전에 선택된 item을 다시 선택으로 지정
                if (string.IsNullOrEmpty(sSelectGrpCode) == false && string.IsNullOrEmpty(DispoCode) == false)
                {
                    if (sSelectGrpCode.Equals(sGrpCode))
                    {
                        ButtonData btnData = bItem.GetButtonByTag(DispoCode);
                        if (btnData != null)
                        {
                            btnData.ButtonPressed = true;
                        }
                    }
                }
                
                //버튼 출력
                bItem.RedrawButtons();
            }
            catch (Exception ex)
            {
                SetMessage("SetButtons Error!");
                LogFile.WriteLog("POP_WRK35.SetButtons Error => " + ex.Message);
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
                    case "Confirm":  //폐품 이력 등록
                        
                        if (string.IsNullOrEmpty(DispoCode) == false)
                        {
                            Console.WriteLine(string.Format("{0} {1} {2}", sSelectGrpCode, DispoCode, DispoName));
                            //Console.WriteLine(string.Format("{0} {1}", bItem.GetSelectedButtons().Count, ((ButtonData)bItem.GetSelectedButtons()[0]).Text.ToString()));

                            this.DialogResult = System.Windows.Forms.DialogResult.OK;
                        }
                        else
                        {
                            Console.WriteLine(string.Format("선택 항목이 없습니다."));
                        }

                        break;

                    case "Close": //이전화면
                        this.DialogResult = System.Windows.Forms.DialogResult.Cancel;
                        //this.Close();
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
                LogFile.WriteLog("POP_WRK35.bBox1_buttonClickEvent Error => " + ex.Message);
            }
            finally
            {

            }
        }
        #endregion

        private void bGroup_buttonChangeEvent(MESButton sender, ButtonBox.ButtonClickEventArg e)
        {
            //선택된 그룹코드
            sGrpCode = sender.Tag.ToString();
            //그룹별 작업자 목록 조회
            SetItemButtons(Common.OpCode, sGrpCode);

        }


        private void bItem_buttonChangeEvent(MESButton sender, ButtonBox.ButtonClickEventArg e)
        {
            if (bItem.GetSelectedButtons().Count > 0)
            {
                sSelectGrpCode = sGrpCode;
                DispoCode = sender.Tag.ToString();
                DispoName = sender.Text.ToString().Replace("\n", "").Replace(" ", "");
                lblDISPO_NAME.Text = DispoName;
            }
            else
            {
                sSelectGrpCode = string.Empty;
                DispoCode = string.Empty;
                DispoName = string.Empty;
                lblDISPO_NAME.Text = string.Empty;
            }
        }
    }
}
