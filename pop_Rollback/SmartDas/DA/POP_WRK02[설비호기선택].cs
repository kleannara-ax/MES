#region [ USING AREA ]
using System;
using System.Configuration;
using System.Data;
using System.Windows.Forms;

using SAMMI;
using SmartDas.Components;
using SmartDas.POPUP;

#endregion

namespace SmartDas
{
    public partial class POP_WRK02 : BaseForm
    {
        #region < MEMBER AREA >

        private SAMMI.Common _common = new SAMMI.Common();
        private string sProcCD = string.Empty; //공정코드
        Configuration appConfig = ConfigurationManager.OpenExeConfiguration(ConfigurationUserLevel.None);

        bool bSelectFlag = true; //미선택시 True

        #endregion

        #region < CONSTRUCTOR >

        public POP_WRK02()
        {
            InitializeComponent();

            Common.SetMessageList();
            sProcCD = Common.OpCode;
        }
        //공정 코드 지정
        public POP_WRK02(string pProcCD)
        {
            InitializeComponent();

            Common.SetMessageList();

            //화면을 호출한 공정정보 저장
            sProcCD = pProcCD;
        }
        #endregion

        #region < POP_WRK02_Load >
        private void POP_WRK02_Load(object sender, EventArgs e)
        {
            string sSubTitle = string.Empty;
            try
            {
                #region --- 언어 설정 → 모듈별로 화면 첫 화면 분기되는 화면에 해당 코드 삽입 ---
                Configuration appConfig = ConfigurationManager.OpenExeConfiguration(ConfigurationUserLevel.None);

                SAMMI.Common.SystemID = appConfig.AppSettings.Settings["SystemID"].Value.ToString();
                SAMMI.Common.Lang = appConfig.AppSettings.Settings["LANGUAGE"].Value.ToString();

                DataTable rtnDtTemp = _common.GET_TBM0000_CODE("LANGKY");

                SAMMI.Common.FontName = Convert.ToString(((DataRow[])rtnDtTemp.Select("CODE_ID = '" + SAMMI.Common.Lang + "'"))[0]["RelCode1"]);
                #endregion

                this.lblTitle.Text = "설비호기 선택";

                //하단 버튼목록 설정
                SetMenuButtons();
                //설비 버튼목록 설정
                SetButtons();
            }
            catch (Exception ex)
            {
                SetMessage("POP_WRK02_Load Error!");
                LogFile.WriteLog("POP_WRK02.POP_WRK02_Load Error => " + ex.Message);
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

                bBox1[0, 0].Text = "선택";
                bBox1[0, 0].Tag = "Confirm";
                bBox1[0, 0].MappingButton.FontSize = 14;
                bBox1[0, 1].Text = "프린터\n설정";  //"프린터" + Environment.NewLine + "설정";
                bBox1[0, 1].Tag = "Printer";   //"Printer";
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
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                LogFile.WriteLog("POP_WRK02.SetButtons Error => " + ex.Message);
            }
        }
        
        private void SetButtons()
        {
            DBHelper helper = new DBHelper();

            try
            {
                //작업자
                bMachine.ButtonBoxType = ButtonBox.ButtonBoxTypeEnum.Selection;
                bMachine.SelectionMode = ButtonBox.SelectionModeEnum.Single;
                //출력 버튼수
                bMachine.CountX = 2;
                bMachine.CountY = 5;
                //화살표 클릭시 이동수
                btnLeftPage.LinkMoveSize = bMachine.CountY;
                btnRightPage.LinkMoveSize = bMachine.CountY;
                //버튼 폰트
                bMachine.FontSize = 25;
                //버튼 목록 조회
                System.Data.DataSet ds = helper.FillDataSet("SP_POP_WRK02_S01", CommandType.StoredProcedure
                                                               , helper.CreateParameter("P_IPADDR", Common.GetIPAddress(), DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_IOTYPE", Common.IOType, DbType.String, ParameterDirection.Input));
                if (ds.Tables[0].Rows.Count < 1)
                {
                        SetMessage("조회된 설비가 없습니다.");
                        new POPUP.MessageForm("조회된 설비가 없습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                        return;
                }
                else
                {
                    bMachine.DoFind_Oracle(ds);

                    foreach (ButtonData bdGroup in bMachine.GetButtonList())
                    {
                        if (bdGroup.Tag.ToString().Equals(Common.MachineCode))
                        {
                            bdGroup.ButtonPressed = true;
                            bSelectFlag = false;
                        }
                        else
                            bdGroup.ButtonPressed = false;
                    }
                }

                bMachine.RedrawButtons();
            }
            catch (Exception ex)
            {
                SetMessage("SetButtons Error!");
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                LogFile.WriteLog("POP_WRK02.SetButtons Error => " + ex.Message);
            }
        }

        private void doConfirm()
        {
            DBHelper helper = new DBHelper(false);
            string sMachNo = string.Empty;
            string sMachName = string.Empty;
            string sIOType = string.Empty;
            ButtonData bTempBtn = (ButtonData)bMachine.GetSelectedButtons()[0];

            if (bSelectFlag || string.IsNullOrEmpty(((ButtonData)bMachine.GetSelectedButtons()[0]).Tag.ToString()))
            {
                new POPUP.MessageForm("작업설비를 선택 후 확인을 눌러주세요.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return;
            }

            sMachNo = ((ButtonData)bMachine.GetSelectedButtons()[0]).Tag.ToString();
            sMachName = ((ButtonData)bMachine.GetSelectedButtons()[0]).Text.ToString();


            if (Common.MachineCode == sMachNo)
            {
                new POPUP.MessageForm("현재 사용중이 설비명과 동일 합니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return;
            }

            try
            {

                //가공기 주작업 화면 작업 이전까지 확인 필요
                if (string.IsNullOrEmpty(bTempBtn.ExTag.ToString()))
                    sIOType = "N";
                else
                    sIOType = bTempBtn.ExTag.ToString();

                //작업시작/완료처리 (작업지시 상태변경 및 작업장 현황의 가동상태 변경)
                helper.ExecuteNoneQuery("SP_POP_WRK02_U01", CommandType.StoredProcedure
                 , helper.CreateParameter("P_IPADDR", Common.GetIPAddress(), DbType.String, ParameterDirection.Input)
                 , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)
                 , helper.CreateParameter("P_MACH_CD", sMachNo, DbType.String, ParameterDirection.Input)
                 //, helper.CreateParameter("P_IOTYPE", sIOType, DbType.String, ParameterDirection.Input)
                 );

                if (helper.RSCODE == "E")
                {
                    new POPUP.MessageForm(helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    this.DialogResult = DialogResult.OK;
                    return;
                }
                else
                {
                    Common.machSetting();

                    if (sProcCD == Common.OpCode)
                    {
                        new POPUP.MessageForm("설비변경이 완료되었습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                        this.DialogResult = DialogResult.OK;
                    }
                    else
                    {
                        // 공정이 변경되면 프로그램 재시작
                        new POPUP.MessageForm("설비변경이 완료되었습니다.\r\n\r\n설비공정이 변경되어 프로그램을 재시작 합니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                        Application.Restart();
                        Environment.Exit(0);
                        // 중료 : 설비변경하여 재부팅시 주작업화면에서 화면 갱신을 못하게 하기위해서 DialogResult.Cancel로 전달
                        this.DialogResult = DialogResult.Cancel;
                    }
                }
            }
            catch (Exception ex)
            {
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
            }
            finally
            {
                helper.Close();
            }
            
            //Baseform출력 수정
            ShowInfoMachineName(Common.MachineName);
            this.Close();
        }

        private void doPrinter()
        {
            try
            {
                POP_Printer popPrinter = new POP_Printer();
                ShowDialogForm(popPrinter);
            }
            catch (Exception ex)
            {
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
            }
        }
        #endregion

        #region < EVNET >

        private void bMachine_buttonChangeEvent(MESButton sender, ButtonBox.ButtonClickEventArg e)
        {
            bSelectFlag = false;
        }

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

                    case "Confirm":  //설비호기 선택
                        doConfirm();
                        break;

                    case "Printer":  //프린터설정
                        doPrinter();
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
                LogFile.WriteLog("POP_WRK02.bBox1_buttonClickEvent Error => " + ex.Message);
            }
            finally
            {

            }
        }

        #endregion

 
    }
}
