using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using SmartDas.Components;
using System.Runtime.InteropServices;
using Infragistics.Win.Misc;
using System.Collections;
using Microsoft.Practices.EnterpriseLibrary.Data;
using System.Data.SqlClient;
using SAMMI;

namespace SmartDas.POPUP
{
    public partial class POP_WRK85 : Form
    {
        private string strPlantCode = "";
        private string strMachCode = "";

        private string strBeforeChange = "";

        public POP_WRK85(string sTitle, string sPlantCode, string sMachNo, string sIndBarCode, string sLotNo, string sBeforeChange)
        {
            InitializeComponent();

            strPlantCode = sPlantCode;
            strMachCode = sMachNo;

            lblTitle.Text = sTitle;
            lblIndBarCode.Text = sIndBarCode;
            lblLotNo.Text = sLotNo;

            strBeforeChange = sBeforeChange;
            lblBeforeChange.Text = sBeforeChange;

            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.Fixed3D;
        }

        private void POP_WRK85_Load(object sender, EventArgs e)
        {
            this.ActiveControl = txtContent;
            txtContent.Focus();
        }

        private void rbtnAppend_CheckedChanged(object sender, EventArgs e)
        {
            lblBeforeChange.Text = strBeforeChange;
            lbInfo.Text = "변경전 비고에 추가할 내용을 이어서 씁니다.";
            lbInfo.ForeColor = Color.DarkRed;
        }

        private void rbtnModify_CheckedChanged(object sender, EventArgs e)
        {
            lblBeforeChange.Text = "";
            lbInfo.Text = "변경전 비고를 추가할 내용으로 덮어 씁니다.";
            lbInfo.ForeColor = Color.Navy;
        }

        private void btnCancel_Click(object sender, EventArgs e)
        {
            this.DialogResult = System.Windows.Forms.DialogResult.Cancel;
        }

        private void btnOK_Click(object sender, EventArgs e)
        {
            string sRemark;

            if (txtContent.Text.Trim().Length > 0)
            {
                // Radio Button 확인
                if (rbtnAppend.Checked == true)
                {
                    sRemark = strBeforeChange + " " + txtContent.Text.Trim();
                }
                else
                {
                    sRemark = txtContent.Text.Trim();
                }

                doConfirm(strPlantCode, strMachCode, lblIndBarCode.Text.ToString(), lblLotNo.Text.ToString(), sRemark);

                this.DialogResult = System.Windows.Forms.DialogResult.OK;
            }
            else
            {
                this.DialogResult = System.Windows.Forms.DialogResult.Cancel;
            }
        }

        #region < METHOD AREA >

        private void doConfirm(string sPlantCode, string sMachCode, string sIndBarCode, string sLotNo, string sRemark)
        {
            DBHelper helper = new DBHelper(false);
            string sUserId = Common.UserID;
            //// bmkim 테스트용으로 Common.UserID가 null 이면 고정ID 사용
            //if (String.IsNullOrEmpty(sUserId))
            //{
            //    sUserId = "hnw";
            //}

            string sMSG = string.Empty;

            try
            {
                //작업시작/완료처리 (작업지시 상태변경 및 작업장 현황의 가동상태 변경)
                helper.ExecuteNoneQuery("SP_POP_WRK85_U01", CommandType.StoredProcedure
                 , helper.CreateParameter("P_WERKS", sPlantCode, DbType.String, ParameterDirection.Input)
                 , helper.CreateParameter("P_MACH_CD", sMachCode, DbType.String, ParameterDirection.Input)
                 , helper.CreateParameter("P_IND_BCD", sIndBarCode, DbType.String, ParameterDirection.Input)
                 , helper.CreateParameter("P_LOT_NO", sLotNo, DbType.String, ParameterDirection.Input)
                 , helper.CreateParameter("P_REMARK", sRemark, DbType.String, ParameterDirection.Input)
                 , helper.CreateParameter("P_USER_ID", sUserId, DbType.String, ParameterDirection.Input)
                 );

                //버튼 상태 변경
                if (helper.RSCODE.Equals("S"))
                {
                    sMSG = "비고수정이 완료되었습니다";
                }
                else
                {
                    sMSG = helper.RSMSG.ToString();
                }

                new POPUP.MessageForm(sMSG, MessageBoxButtons.OK, "알   림").ShowDialog(this);
            }
            catch (Exception ex)
            {
                ///SetMessage("SetGrid Error!");
                LogFile.WriteLog("DAS0200.SetGrid Error => " + ex.Message);
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
            }
            finally
            {
                helper.Close();
                this.DialogResult = DialogResult.OK;
            }
        }
        #endregion

    }
}
