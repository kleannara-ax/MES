#region [ USING AREA ]
using System;
using System.Configuration;
using System.ComponentModel;
using System.Data;
using System.Runtime.InteropServices;
using System.Windows.Forms;
using System.Data.SqlClient;
using System.Drawing;
using System.IO.Ports;
using System.Text.RegularExpressions;
using System.Windows.Forms.VisualStyles;
using Infragistics.Win;
using Infragistics.Win.UltraWinGrid;
using Infragistics.Win.UltraWinTabs;

using Microsoft.Practices.EnterpriseLibrary.Data;

using SAMMI;
using SmartDas.Components;
using SmartDas.POPUP;
using System.Diagnostics;
using SmartDas.DA;

using System.Net;
using System.IO;
#endregion

namespace SmartDas
{
    public partial class DA0000 : BaseForm
    {
        #region < MEMBER AREA >

        private SAMMI.Common _common = new SAMMI.Common();
        Configuration appConfig = ConfigurationManager.OpenExeConfiguration(ConfigurationUserLevel.None);

        #endregion

        #region < CONSTRUCTOR >

        public DA0000()
        {
            InitializeComponent();

            Common.SetMessageList(); 
            Common.dasMain = this;
        }
        #endregion

        #region < DA0000_Load >
        private void DA0000_Load(object sender, EventArgs e)
        {
            try
            {
                #region --- 언어 설정 → 모듈별로 화면 첫 화면 분기되는 화면에 해당 코드 삽입 ---
                //Configuration appConfig = ConfigurationManager.OpenExeConfiguration(ConfigurationUserLevel.None);

                SAMMI.Common.SystemID = appConfig.AppSettings.Settings["SystemID"].Value.ToString();
                SAMMI.Common.Lang = appConfig.AppSettings.Settings["LANGUAGE"].Value.ToString();


                DataTable rtnDtTemp = _common.GET_TBM0000_CODE("LANGKY");
                SAMMI.Common.FontName = Convert.ToString(((DataRow[])rtnDtTemp.Select("CODE_ID = '" + SAMMI.Common.Lang + "'"))[0]["RelCode1"]);

                #endregion
                this.lblTitle.Text = "작업 메인";
                //2018 05 03 HJH 공장코드..
                Common.PlantCode = appConfig.AppSettings.Settings["SITE"].Value.ToString();
                Common.gsIP = Common.GetIPAddress();

                //상단 좌,우 버튼 세팅
                btnRightPage.LinkMoveSize = 5;
                btnLeftPage.LinkMoveSize = 5;

#if true
                string sMsgErr = string.Format("MES에서 현재 IP({0})의\n설비설정을 확인 하세요.\r\n\r\nMES 시스템관리 담당자 에게 문의 하시기 바랍니다.", Common.GetIPAddress());
                new POPUP.MessageForm(sMsgErr, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                Application.Exit();
#else           
                // 테스트 용     
                SetButtons();
#endif                
            }
            catch (Exception ex)
            {
                SetMessage("DA0000_Load_ Error!");
                LogFile.WriteLog("DA0000.DA0000_Load Error => " + ex.Message);
            }
        }
        #endregion

        #region < METHOD AREA >
        


        private void SetButtons()
        {
            try
            {
                //메인버튼 설정
                bBox1.MarginOut = new Padding(10, 250, 10, 250);
                bBox1.ButtonBoxType = ButtonBox.ButtonBoxTypeEnum.Buttons;
                bBox1.SelectionMode = ButtonBox.SelectionModeEnum.Single;

                bBox1.CountX = 6;
                bBox1.CountY = 3;

                bBox1.SetButtons();

                bBox1[0, 0].Text = "점보롤";
                bBox1[0, 0].Tag = "Jumbo";
                bBox1[0, 0].MappingButton.FontSize = 18;
                bBox1[0, 1].Text = "밀롤";
                bBox1[0, 1].Tag = "Rewinder";
                bBox1[0, 1].MappingButton.FontSize = 18;
                bBox1[0, 2].Text = "슬리터";
                bBox1[0, 2].Tag = "Sliter";
                bBox1[0, 2].MappingButton.FontSize = 18;
                bBox1[0, 3].Text = "재단";
                bBox1[0, 3].Tag = "Cutter";
                bBox1[0, 3].MappingButton.FontSize = 18;
                bBox1[0, 4].Text = "수재단";
                bBox1[0, 4].Tag = "Manual";
                bBox1[0, 4].MappingButton.FontSize = 18;
                bBox1[0, 5].Text = "포장";
                bBox1[0, 5].Tag = "Packing";
                bBox1[0, 5].MappingButton.FontSize = 18;

                bBox1[1, 0].Text = "화장지-원지";
                bBox1[1, 0].Tag = "PaperRoll";
                bBox1[1, 0].MappingButton.FontSize = 18;
                bBox1[1, 1].Text = "화장지-가공";
                bBox1[1, 1].Tag = "Tissue";
                bBox1[1, 1].MappingButton.FontSize = 18;
                bBox1[1, 2].Text = "생리대";
                bBox1[1, 2].Tag = "Pad";
                bBox1[1, 2].MappingButton.FontSize = 18;
                bBox1[1, 3].Text = "기저귀";
                bBox1[1, 3].Tag = "Diaper";
                bBox1[1, 3].MappingButton.FontSize = 18;
                bBox1[1, 4].Text = "화장지포장";
                bBox1[1, 4].Tag = "TissuePack";
                bBox1[1, 4].MappingButton.FontSize = 18;
                bBox1[1, 5].Text = "시간입력-테스트";
                bBox1[1, 5].Tag = "TEST01";
                bBox1[1, 5].MappingButton.FontSize = 18;


                bBox1[2, 0].Text = "상세조회-테스트";
                bBox1[2, 0].Tag = "TEST02";
                bBox1[2, 0].MappingButton.FontSize = 18;
                bBox1[2, 1].Text = "잔량처리-테스트";
                bBox1[2, 1].Tag = "TEST03";
                bBox1[2, 1].MappingButton.FontSize = 18;
                bBox1[2, 2].Text = "폐품사유-테스트";
                bBox1[2, 2].Tag = "TEST04";
                bBox1[2, 2].MappingButton.FontSize = 18;
                bBox1[2, 3].Text = "재단상세정보-테스트";
                bBox1[2, 3].Tag = "TEST05";
                bBox1[2, 3].MappingButton.FontSize = 18;
                bBox1[2, 4].Text = "등급변경-테스트";
                bBox1[2, 4].Tag = "TEST06";
                bBox1[2, 4].MappingButton.FontSize = 18;

                bBox1.RedrawButtons();

            }
            catch (Exception ex)
            {
                SetMessage("SetButtons Error!");
                LogFile.WriteLog("DA0000.SetButtons Error => " + ex.Message);
            }
        }

        #endregion

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
                    case "Jumbo":  //점보롤 실적등록
                        POP_WRK24 WRK24 = new POP_WRK24();
                        ShowDialogForm(WRK24);
                        break;
                    case "Rewinder":  //밀롤 실적등록
                        POP_WRK25 WRK25 = new POP_WRK25();
                        ShowDialogForm(WRK25);
                        break;
                    case "Sliter":  //슬리터 실적등록
                        POP_WRK28 WRK28 = new POP_WRK28();
                        ShowDialogForm(WRK28);
                        break;
                    case "Cutter":  //재단 실적등록
                        POP_WRK26 WRK26 = new POP_WRK26();
                        ShowDialogForm(WRK26);
                        break;
                    case "Manual":  //수재단 실적등록
                        POP_WRK29 WRK29 = new POP_WRK29();
                        ShowDialogForm(WRK29);
                        break;
                    case "Packing":  //포장 실적등록
                        POP_WRK27 WRK27 = new POP_WRK27();
                        ShowDialogForm(WRK27);
                        break;

                    case "PaperRoll":  //화장지-원지
                        Common.MachineCode = "TAA04";
                        POP_WRK08 WRK08 = new POP_WRK08();
                        ShowDialogForm(WRK08);
                        break;
                    case "Tissue":  //화장지-가공
                        POP_WRK09 WRK09 = new POP_WRK09();
                        ShowDialogForm(WRK09);
                        break;
                    case "TissuePack":  //화장지-포장
                        POP_WRK21 WRK21 = new POP_WRK21();
                        ShowDialogForm(WRK21);
                        break;
                    case "Pad":  //생리대
                        POP_WRK10 WRK10 = new POP_WRK10();
                        ShowDialogForm(WRK10);
                        break;
                    case "Diaper":  //기저귀
                        POP_WRK11 WRK11 = new POP_WRK11();
                        ShowDialogForm(WRK11);
                        break;
                    case "TEST01":
                        {
                            DAResultTime popTest = new DAResultTime();
                            ShowDialogForm(popTest);
                        }
                        break;
                    case "TEST02":
                        {
                            //POP_WRK84 popWrk84 = new POP_WRK84(POP_WRK84.PROC_INP, "P100", "JA", "P220426J0001", "1");  // 점보롤 작업지시 정보
                            //popWrk84.LabelTitle = "점보롤 작업지시 정보";

                            //POP_WRK84 popWrk84 = new POP_WRK84(POP_WRK84.PROC_INP, Common.PlantCode, Common.OpCode, sWrkOrder, sWrkOrderSeq);  // 작업지시 정보
                            POP_WRK84 popWrk84 = new POP_WRK84(POP_WRK84.PROC_INP, "P100", "MA", "WOMA202205200001", "1");  // 밀롤 작업지시 정보
                            popWrk84.LabelTitle = "리와인더 작업지시 정보";

                            //POP_WRK84 popWrk84 = new POP_WRK84(POP_WRK84.PROC_INP, "P100", "CA", "P220426C0001", "1");  // 재단 작업지시 정보 - 재단 작업지시 정보에 비고 칼럼 없음.
                            //popWrk84.LabelTitle = "재단 작업지시 정보";

                            //POP_WRK84 popWrk84 = new POP_WRK84(POP_WRK84.PROC_INP, "P100", "PB", "P220426P0001", "1");  // 포장 작업지시 정보
                            //popWrk84.LabelTitle = "포장 작업지시 정보";

                            //POP_WRK84 popWrk84 = new POP_WRK84(POP_WRK84.PROC_INP, "P200", "AA", "H220427A0001", "1");  // 
                            //popWrk84.LabelTitle = "화장지 합지기 작업지시 정보";

                            ShowDialogForm(popWrk84);
                        }
                        break;
                    case "TEST03":
                        {
                            // 플랜트코드, 작업지시번호, 작업지시순번, 업체/개별바코드, OperationType
                            //public POP_WRK82(string PlantCode, string WrkOrdrNo, string WrkOrdrSeqNo, string IndBcd, string OperType)
                            //POP_WRK82 popWrk82 = new POP_WRK82("P100", "P111222333", "1", "A111222333", "REMAIN");

                            //ShowDialogForm(popWrk82);
                        }
                        break;
                    case "TEST04":
                        {
                            Common.PlantCode = "P100";      // 플랜트 코드
                            Common.OpCode = "PC";           // 공정코드
                            Common.IOType = "N";            // PS=N, 
                            Common.MachineCode = "PPC03";   // 설비호기

                            POP_WRK35 popWrk35 = new POP_WRK35();
                            popWrk35.LabelTitle = "포장 폐품사유";

                            if (ShowDialogForm(popWrk35) == DialogResult.OK)
                            {
                                new POPUP.MessageForm(string.Format("폐품코드={0}\r\n폐품명={1}", popWrk35.DispoCode, popWrk35.DispoName), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                            }
                        }
                        break;
                    case "TEST05":
                        {
                            ////테스트 설정 
                            //Common.PlantCode = "P100";      // 플랜트 코드
                            //Common.OpCode = "CA";           // 공정코드
                            //Common.IOType = "N";            // PS=N, 
                            //Common.MachineCode = "PCA03";   // 설비호기
                            //Common.UserID = "hnw";

                            //POP_WRK81 popWrk81 = new POP_WRK81();

                            //if (ShowDialogForm(popWrk81) == DialogResult.OK)
                            //{
                            //}
                        }
                        break;
                    case "TEST06":
                        {
                            //테스트 설정 
                            //Common.PlantCode = "P100";      // 플랜트 코드
                            //Common.OpCode = "CA";           // 공정코드
                            //Common.IOType = "N";            // PS=N, 
                            //Common.MachineCode = "PCA03";   // 설비호기
                            //Common.UserID = "hnw";

                            //POP_WRK37 popWrk37 = new POP_WRK37();

                            //if (ShowDialogForm(popWrk37) == DialogResult.OK)
                            //{
                            //}
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
                LogFile.WriteLog("DA0000.bBox1_buttonClickEvent Error => " + ex.Message);
            }
            finally
            {

            }
        }
    }
}
