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
#endregion

namespace SmartDas
{
    public partial class DASMain : BaseForm
    {
        #region < MEMBER AREA >
        //private string sStartTime = string.Empty;
        //private int iSelRow;
        //private int iSecond = 0;
        private SAMMI.Common _common = new SAMMI.Common();

        public static string userID = string.Empty;
        public static string userName = string.Empty;

        #endregion

        #region < CONSTRUCTOR >
        public DASMain(string sUserID, string sUserName, string sPlantCode)
        {
            InitializeComponent();

            Common.SetMessageList();
            
            //2018 05 02 HJH 주석
            //Common.dasMain = this;

            Common.PlantCode = sPlantCode;
            Common.UserID = string.IsNullOrEmpty(sUserID) ? "1" : sUserID;
            Common.UserName = string.IsNullOrEmpty(sUserName) ? "테스트" : sUserName;

            if (string.IsNullOrEmpty(Common.OpCode))
                GetDevInfo();

            txtUserName.Text = Common.UserName;
            txtOPGrpName.Text = Common.OpGrpName;
            txtOPName.Text = Common.OpName;
        }
        #endregion

        #region < DASMain_Load >
        private void DASMain_Load(object sender, EventArgs e)
        {
            try
            {
                #region --- 언어 설정 → 모듈별로 화면 첫 화면 분기되는 화면에 해당 코드 삽입 ---
                Configuration appConfig = ConfigurationManager.OpenExeConfiguration(ConfigurationUserLevel.None);

                SAMMI.Common.SystemID = appConfig.AppSettings.Settings["SystemID"].Value.ToString();
                SAMMI.Common.Lang = appConfig.AppSettings.Settings["LANGUAGE"].Value.ToString();

                DataTable rtnDtTemp = _common.GET_TBM0000_CODE("LANG");

                SAMMI.Common.FontName = Convert.ToString(((DataRow[])rtnDtTemp.Select("CODE_ID = '" + SAMMI.Common.Lang + "'"))[0]["RelCode1"]);
                #endregion

                SetButton();    //버튼 셋팅
                SetMachineButton();

                //iSelRow = -1;
                EventTimerEnable = false;

                //// 외관검사 일 경우, 설비 선택 화면 없이 바로 공정 화면으로 가기? 
                //if (Common.OpCode.Equals("5059"))
                //{
                //    DAS6010 das6010 = new DAS6010();
                //    das6010.ShowDialog(this);

                //    return;
                //}

                SetMessage("작업설비를 선택하세요");
            }
            catch (Exception ex)
            {
                SetMessage("DASMain_Load_ Error!");
                LogFile.WriteLog("DASMain.DASMain_Load Error => " + ex.Message);
            }
        }
        #endregion

        #region < METHOD AREA >
        private DataTable GetDevInfo()
        {
            DBHelper helper = new DBHelper(false);
            DataTable dt = new DataTable();

            string DevName = Common.GetComputerName();

            try
            {
                dt = helper.FillTable("USP_DASOper_S2", CommandType.StoredProcedure, false, false
                                    , helper.CreateParameter("@PlantCode", Common.PlantCode, DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("@UserID", Common.UserID, DbType.String, ParameterDirection.Input));


                if (dt.Rows.Count > 0)
                {
                    Common.OpGrpCode = dt.Rows[0]["OPGrpCode"].ToString();
                    Common.OpGrpName = dt.Rows[0]["OPGrpName"].ToString();
                    Common.OpCode = dt.Rows[0]["OPCode"].ToString();
                    Common.OpName = dt.Rows[0]["OPName"].ToString();
                    Common.WHCode = dt.Rows[0]["WHCode"].ToString();
                }

                //if (dt.Rows.Count > 1)
                //{
                //    for (int i = 0; i < dt.Rows.Count; i++)
                //    {
                //        if (dt.Rows[i]["OPCode"].ToString().Equals(Common.OpCode))
                //        {
                //            Common.OpGrpCode = dt.Rows[i]["OPGrpCode"].ToString();
                //            Common.OpGrpName = dt.Rows[i]["OPGrpName"].ToString();
                //            Common.OpCode = dt.Rows[i]["OPCode"].ToString();
                //            Common.OpName = dt.Rows[i]["OPName"].ToString();
                //            Common.WHCode = dt.Rows[i]["WHCode"].ToString();
                //        }
                //    }
                //}
            }
            catch (Exception ex)
            {
                SetMessage(ex.Message, 20);
            }
            finally
            {
                helper.Close();
            }

            return dt;
        }

        private void SetTimerInterval()
        {
            DBHelper helper = new DBHelper(false);
            string sQuery = "SELECT * "
                          + "FROM TBM0000 WITH(NOLOCK) "
                          + "WHERE MINORCODE = 'DASTIMER'";

            DataTable tmpDt = new DataTable();

            try
            {
                tmpDt = helper.FillTable(sQuery);

                if (tmpDt.Rows.Count == 0) return;

                //iSecond = Convert.ToInt32(tmpDt.Rows[0]["RelCode1"].ToString());
            }
            catch (Exception ex)
            {
                throw (ex);
            }
            finally
            {
                helper.Close();
            }
        }

        private void SetButton()
        {
            bBox1.ButtonBoxType = ButtonBox.ButtonBoxTypeEnum.Buttons;
            bBox1.SelectionMode = ButtonBox.SelectionModeEnum.Single;

            bBox1.CountX = 2;
            bBox1.CountY = 1;

            bBox1.SetButtons();

            bBox1[0, 0].Text = "확 인";
            bBox1[0, 0].Tag = "NEXT";
            bBox1[0, 0].MappingButton.FontSize = 20;

            bBox1[0, 1].Text = "닫 기";
            bBox1[0, 1].Tag = "CLOSE";
            bBox1[0, 1].MappingButton.FontSize = 20;

            bBox1.RedrawButtons();
        }

        private void SetMachineButton()
        {
            bBoxMachine.ButtonBoxType = ButtonBox.ButtonBoxTypeEnum.Selection;
            bBoxMachine.SelectionMode = ButtonBox.SelectionModeEnum.Single;

            bBoxMachine.CountX = 5;
            bBoxMachine.CountY = 2;

            bBoxMachine.FontSize = 20;

            bBoxMachine.SelectProcedureName = "USP_DASMain_S1";
            bBoxMachine.SetStoreProc();

            bBoxMachine.ParameterList.Add(new SqlParameter("@PlantCode", SqlDbType.VarChar));
            bBoxMachine.ParameterList.Add(new SqlParameter("@OPCode", SqlDbType.VarChar));
            bBoxMachine.ParameterList["@PlantCode"].Value = Common.PlantCode;
            bBoxMachine.ParameterList["@OPCode"].Value = Common.OpCode;

            bBoxMachine.DoFind();
            bBoxMachine.RedrawButtons();
        }

        #endregion

        #region < EVNET >

        private void bBox1_buttonClickEvent(MESButton sender, ButtonBox.ButtonClickEventArg e)
        {
            //DBHelper helper = new DBHelper();

            //switch (sender.Tag.ToString())
            //{
            //    case "NEXT":

            //        //인터락 기능
            //        helper.ExecuteNoneQuery("USP_TBM3640_CHECK_MC", CommandType.StoredProcedure
            //            , helper.CreateParameter("@PlantCode", Common.PlantCode, DbType.String, ParameterDirection.Input)
            //            , helper.CreateParameter("@MachCode", Common.MachineCode, DbType.String, ParameterDirection.Input));

            //        if (helper.RSCODE.Equals("E"))
            //        {
            //            MessageBoxShow(helper.RSMSG);
            //            return;
            //        }

            //        if (string.IsNullOrEmpty(txtMachName.Text))
            //        {
            //            MessageBoxShow("설비를 선택하세요");
            //            return;
            //        }

            //        switch (Common.OpCode)
            //        {
            //            case "1010":
            //                DAS0000 das0000 = new DAS0000();
            //                das0000.ShowDialog(this);
            //                break;
            //            case "1030":
            //                DAS1000 das1000 = new DAS1000();
            //                das1000.ShowDialog(this);

            //                //DAS1001 das1001 = new DAS1001();
            //                //das1001.ShowDialog(this);
            //                break;
            //            case "1040":
            //                DAS2000 das2000 = new DAS2000();
            //                das2000.ShowDialog(this);
            //                break;
            //            case "2010":
            //                DAS2500 das2500 = new DAS2500();
            //                das2500.ShowDialog(this);
            //                break;
            //            case "2020":
            //                DAS3500 das3500 = new DAS3500();
            //                das3500.ShowDialog(this);
            //                break;
            //            case "2030":
            //                DAS3000 das3000 = new DAS3000();
            //                das3000.ShowDialog(this);
            //                break;
            //            case "3011":
            //                {
            //                    DAS4000 das4000 = new DAS4000();
            //                    das4000.ShowDialog(this);
            //                    break;
            //                }
            //            case "3012":
            //                {
            //                    DAS4000 das4000 = new DAS4000();
            //                    das4000.ShowDialog(this);
            //                    break;
            //                }
            //            case "3013":
            //                {
            //                    DAS4000 das4000 = new DAS4000();
            //                    das4000.ShowDialog(this);
            //                    break;
            //                }
            //            case "3014":
            //                {
            //                    DAS4000 das4000 = new DAS4000();
            //                    das4000.ShowDialog(this);
            //                    break;
            //                }
            //            case "3020":
            //                DAS5000 das5000 = new DAS5000();
            //                das5000.ShowDialog(this);
            //                break;
            //            case "5099":
            //                {
            //                    DAS6010 das6010 = new DAS6010();
            //                    das6010.ShowDialog(this);
            //                    break;
            //                }
            //            case "6011":
            //                {
            //                    DAS6000 das6000 = new DAS6000();
            //                    das6000.ShowDialog(this);
            //                    break;
            //                }
            //            case "6012":
            //                {
            //                    DAS6100 das6100 = new DAS6100();
            //                    das6100.ShowDialog(this);
            //                    break;
            //                }
            //            case "6013":
            //                {
            //                    DAS6200 das6200 = new DAS6200();
            //                    das6200.ShowDialog(this);
            //                    break;
            //                }
            //            case "6014":
            //                {
            //                    DAS6100 das6100 = new DAS6100();
            //                    das6100.ShowDialog(this);
            //                    break;
            //                }
            //            case "7013":
            //                {
            //                    DAS6010 das6010 = new DAS6010();
            //                    das6010.ShowDialog(this);
            //                    break;
            //                }
            //            case "8010":
            //                DAS8000 das8000 = new DAS8000();
            //                das8000.ShowDialog(this);
            //                break;
            //            case "8020":
            //                DAS8100 das8100 = new DAS8100();
            //                das8100.ShowDialog(this);
            //                break;
            //            case "8030":
            //                DAS8200 das8200 = new DAS8200();
            //                das8200.ShowDialog(this);
            //                break;
            //        }

            //        Common.OrderTable.Clear();
            //        break;

            //    case "CLOSE":
            //        if (DialogResult.Yes == MessageBoxShow("종료하시겠습니까?", MessageBoxButtons.YesNo))
            //            this.Close();

            //        break;
            //}
        }

        private void bBoxMachine_buttonChangeEvent(MESButton sender, ButtonBox.ButtonClickEventArg e)
        {

            Common.MachineCode = bBoxMachine.GetSelectedButtons()[0].Tag.ToString();
            Common.MachineName = bBoxMachine.GetSelectedButtons()[0].Text;

            txtMachName.Text = Common.MachineName;
        }

        #endregion
    }
}
