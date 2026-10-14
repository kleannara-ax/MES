using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using SmartDas.Components;
using System.Configuration;
using System.Data.SqlClient;
using SAMMI;

namespace SmartDas
{
    public partial class DASOper : BaseForm
    {
        private SAMMI.Common _common = new SAMMI.Common();
        DataTable dt = new DataTable();

        public DASOper(string sUserID, string sUserName, string sPlantCode = "")
        {
            InitializeComponent();

            Common.SetMessageList();

            Common.PlantCode = sPlantCode;
            Common.UserID = sUserID;
            Common.UserName = sUserName;

            Common.UserID = string.IsNullOrEmpty(sUserID) ? "1" : sUserID;
            Common.UserName = string.IsNullOrEmpty(sUserName) ? "테스트" : sUserName;

            txtUserName.Text = Common.UserName;
        }

        #region [ LOAD ]

        private void DASOper_Load(object sender, EventArgs e)
        {
            #region --- 언어 설정 → 모듈별로 화면 첫 화면 분기되는 화면에 해당 코드 삽입 ---
            Configuration appConfig = ConfigurationManager.OpenExeConfiguration(ConfigurationUserLevel.None);

            SAMMI.Common.SystemID = appConfig.AppSettings.Settings["SystemID"].Value.ToString();
            SAMMI.Common.Lang = appConfig.AppSettings.Settings["LANGUAGE"].Value.ToString();

            DataTable rtnDtTemp = _common.GET_TBM0000_CODE("LANG");

            SAMMI.Common.FontName = Convert.ToString(((DataRow[])rtnDtTemp.Select("CODE_ID = '" + SAMMI.Common.Lang + "'"))[0]["RelCode1"]);
            #endregion

            SetButton();    //버튼 셋팅
            SetButtonOPGrp();
        }

        #endregion

        #region [ METHOD ]

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

        private void SetButtonOPGrp()
        {
            //OPGRPCODE 셋팅
            bBoxOPGrp.ButtonBoxType = ButtonBox.ButtonBoxTypeEnum.Selection;
            bBoxOPGrp.SelectionMode = ButtonBox.SelectionModeEnum.Single;

            bBoxOPGrp.CountX = 5;
            bBoxOPGrp.CountY = 2;

            bBoxOPGrp.FontSize = 20;

            bBoxOPGrp.SelectProcedureName = "USP_DASOper_S1";
            bBoxOPGrp.SetStoreProc();

            bBoxOPGrp.ParameterList.Add(new SqlParameter("@PlantCode", SqlDbType.VarChar));
            bBoxOPGrp.ParameterList.Add(new SqlParameter("@UserID", SqlDbType.VarChar));
            
            bBoxOPGrp.ParameterList["@PlantCode"].Value = Common.PlantCode;
            bBoxOPGrp.ParameterList["@UserID"].Value = Common.UserID;

            bBoxOPGrp.DoFind();
            bBoxOPGrp.RedrawButtons();

            //OPERCDOE 셋팅
            bBoxOper.ButtonBoxType = ButtonBox.ButtonBoxTypeEnum.Selection;
            bBoxOper.SelectionMode = ButtonBox.SelectionModeEnum.Single;

            bBoxOper.CountX = 5;
            bBoxOper.CountY = 2;

            bBoxOper.FontSize = 20;

            bBoxOper.SelectProcedureName = "USP_DASOper_S2";
            bBoxOper.SetStoreProc();

            bBoxOper.ParameterList.Add(new SqlParameter("@PlantCode", SqlDbType.VarChar));
            bBoxOper.ParameterList.Add(new SqlParameter("@UserID", SqlDbType.VarChar));

            bBoxOper.ParameterList["@PlantCode"].Value = Common.PlantCode;
            bBoxOper.ParameterList["@UserID"].Value = Common.UserID;

            bBoxOper.ExTag = bBoxOPGrp.GetSelectedButtons()[0].Tag.ToString();

            bBoxOper.DoFind();
            bBoxOper.RedrawButtons();

            bBoxOPGrp.GetButtonList()[0].ButtonPressed = true;

            Common.OpGrpCode = bBoxOPGrp.GetSelectedButtons()[0].Tag.ToString();
            Common.OpGrpName = bBoxOPGrp.GetSelectedButtons()[0].Text;
            txtOPGrpName.Text = bBoxOPGrp.GetSelectedButtons()[0].Text;
        }

        #endregion

        #region [ EVENT ]

        private void bBox1_buttonClickEvent(MESButton sender, ButtonBox.ButtonClickEventArg e)
        {
            DBHelper helper = new DBHelper();
            DataTable dt = new DataTable();

            try
            {
                switch (sender.Tag.ToString())
                {
                    case "NEXT":

                        if (string.IsNullOrEmpty(Common.OpCode))
                        {
                            MessageBoxShow("공정을 선택하세요");
                            return;
                        }

                        dt = helper.FillTable("USP_DASOper_S2", CommandType.StoredProcedure, false, false
                            , helper.CreateParameter("@PlantCode", Common.PlantCode, DbType.String, ParameterDirection.Input)
                            , helper.CreateParameter("@UserID", Common.UserID, DbType.String, ParameterDirection.Input));

                        if (dt.Rows.Count > 0)
                        {
                            for (int i = 0; i < dt.Rows.Count; i++)
                            {
                                if (Common.OpCode.Equals(dt.Rows[i]["OPCode"].ToString()))
                                    Common.WHCode = dt.Rows[i]["WHCode"].ToString();
                            }
                        }

                        DASMain dasMain = new DASMain(Common.UserID, Common.UserName, Common.PlantCode);
                        dasMain.ShowDialog(this);

                        break;

                    case "CLOSE":

                        if (DialogResult.Yes == MessageBoxShow("종료하시겠습니까?", MessageBoxButtons.YesNo))
                            this.Close();

                        break;
                }
            }
            catch (Exception ex)
            {
                SetMessage(ex.Message);
            }
            finally
            {
                helper.Close();
            }
        }

        private void bBoxOPGrp_buttonChangeEvent(MESButton sender, ButtonBox.ButtonClickEventArg e)
        {
            bBoxOper.ExTag = bBoxOPGrp.GetSelectedButtons()[0].Tag.ToString();

            for (int i = 0; i < bBoxOper.GetButtonList().Count; i++)
            {
                bBoxOper.GetButtonList()[i].ButtonPressed = false;
            }

            Common.OpGrpCode = bBoxOPGrp.GetSelectedButtons()[0].Tag.ToString();
            Common.OpGrpName = bBoxOPGrp.GetSelectedButtons()[0].Text;
            txtOPGrpName.Text = bBoxOPGrp.GetSelectedButtons()[0].Text;

            Common.OpCode = string.Empty;
            Common.OpName = string.Empty;
            txtOPName.Text = string.Empty;

            bBoxOper.RedrawButtons();
        }

        private void bBoxOper_buttonChangeEvent(MESButton sender, ButtonBox.ButtonClickEventArg e)
        {
            Common.OpCode = bBoxOper.GetSelectedButtons()[0].Tag.ToString();
            Common.OpName = bBoxOper.GetSelectedButtons()[0].Text;

            txtOPName.Text = bBoxOper.GetSelectedButtons()[0].Text;
        }

        #endregion
    }
}
