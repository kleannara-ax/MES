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
    public partial class DA0050 : BaseForm
    {
        #region < MEMBER AREA >
        private string sStartTime = string.Empty;
        private int iSelRow;
        private int iSecond = 0;
        private SAMMI.Common _common = new SAMMI.Common();
        WorkCenter wc = new WorkCenter();
        public static string userID = string.Empty;
        public static string userName = string.Empty;
        private string sFormName = string.Empty;
        #endregion

        #region < CONSTRUCTOR >
        
        public DA0050()
        {
            InitializeComponent();
            
            Common.SetMessageList();
            
            
        }
        #endregion

        #region < DA0050_Load >
        private void DA0050_Load(object sender, EventArgs e)
        {
            try
            {
                #region --- 언어 설정 → 모듈별로 화면 첫 화면 분기되는 화면에 해당 코드 삽입 ---
                Configuration appConfig = ConfigurationManager.OpenExeConfiguration(ConfigurationUserLevel.None);

                SAMMI.Common.SystemID = appConfig.AppSettings.Settings["SystemID"].Value.ToString();
                SAMMI.Common.Lang = appConfig.AppSettings.Settings["LANGUAGE"].Value.ToString();

                DataTable rtnDtTemp = _common.GET_TBM0000_CODE("LANG"); ;
                sFormName = appConfig.AppSettings.Settings["STARTFORM"].Value.ToString();
                SAMMI.Common.FontName = Convert.ToString(((DataRow[])rtnDtTemp.Select("CODE_ID = '" + SAMMI.Common.Lang + "'"))[0]["RelCode1"]);
                #endregion
                
                btnRightPage.LinkMoveSize = 5;
                btnLeftPage.LinkMoveSize = 5;

                this.lblTitle.Text = "라인 선택";

                lblLineCode.Text = Common.WorkCenterCode;
                lblLineName.Text = Common.WorkCenterName;

                SetButtons();
            }
            catch (Exception ex)
            {
                SetMessage("DA0050_Load_ Error!");
                LogFile.WriteLog("DA0050.DA0050_Load Error\r\n" + ex.Message + "\r\n");
            }
        }
        #endregion

        #region < METHOD AREA >   
       
        private string GetIP
        {
            get
            {
                System.Net.IPHostEntry host = System.Net.Dns.GetHostEntry(System.Net.Dns.GetHostName());
                string clientIP = string.Empty;
                for (int i = 0; i < host.AddressList.Length; i++)
                {
                    // AddressFamily.InterNetworkV6 - IPv6
                    if (host.AddressList[i].AddressFamily == System.Net.Sockets.AddressFamily.InterNetwork)
                    {
                        clientIP = host.AddressList[i].ToString();
                    }
                }
                return clientIP;
            }
        }

   

        private void SetButtons()
        {
            try
            {
                //조구분
                bLine.ButtonBoxType = ButtonBox.ButtonBoxTypeEnum.Selection;
                bLine.SelectionMode = ButtonBox.SelectionModeEnum.Single;

                bLine.FontSize = 20;
                bLine.CountX = 4;
                bLine.CountY = 4;
                bLine.SetButtons();

                //2018 05 02 HJH 
                //추후 라인이 많아져서 버튼이 많아진다면 아래 주석을 쓰면
                //bLine_btnUp.LinkMoveSize = bLine.CountY;
                //bLine_btnDown.LinkMoveSize = bLine.CountY;

                bLine.SelectProcedureName = "USP_DA0050_S1_R";
                bLine.SetStoreProc();

                bLine.DoFind();

                for (int i = 0; i < bLine.GetButtonList().Count; i++)
                {

                    if (Common.WorkCenterCode == bLine.GetButtonList()[i].Tag.ToString())
                    {
                        bLine.GetButtonList()[i].ButtonPressed = true;
                    }
                    else
                    {
                        bLine.GetButtonList()[i].ButtonPressed = false;
                    }
                }

                bLine.RedrawButtons();
            }
            catch (Exception ex)
            {
                SetMessage("SetButtons Error!");
                LogFile.WriteLog("DA0050.SetButtons Error\r\n" + ex.Message + "\r\n");
            }
        }
     
        #endregion

        private void btnCancel_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        private void bLine_buttonChangeEvent(MESButton sender, ButtonBox.ButtonClickEventArg e)
        {
            lblLineCode.Text = sender.Tag.ToString();
            lblLineName.Text = sender.Text;
        }

        private void btnConfirm_Click(object sender, EventArgs e)
        {
            if (lblLineCode.Text == "")
            {
                SetMessage("라인을 선택해주세요.");
                return;
            }
            DBHelper helper = new DBHelper();
            try
            {
                Common.WorkCenterCode = lblLineCode.Text;
                Common.WorkCenterName = lblLineName.Text;

                helper.ExecuteNoneQuery("USP_DA0050_I1_R", CommandType.StoredProcedure
                                                        , helper.CreateParameter("PlantCode", Common.PlantCode, DbType.String, ParameterDirection.Input)
                                                        , helper.CreateParameter("IPAddr", GetIP, DbType.String, ParameterDirection.Input)
                                                        , helper.CreateParameter("WorkCenterCode", Common.WorkCenterCode, DbType.String, ParameterDirection.Input)
                                                        , helper.CreateParameter("Form", sFormName, DbType.String, ParameterDirection.Input)
                                                        );
                
                wc.Code = Common.WorkCenterCode;
                wc.Name = Common.WorkCenterName;
                Common.SelectedWorkCenter = wc;
                this.DialogResult = DialogResult.OK;
            }
            catch (Exception ex)
            {
                SetMessage("DA0050.btnConfirm_Click Error!");
                LogFile.WriteLog("DA0050.btnConfirm_Click Error\r\n" + ex.Message + "\r\n");
            }
            finally
            {
                helper.Close();
            }

        
        }

      

        #region < EVNET >

     
      
        #endregion
    }
}
