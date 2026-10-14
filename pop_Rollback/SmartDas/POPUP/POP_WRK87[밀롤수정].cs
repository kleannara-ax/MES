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
using System.Configuration;
using System.Net;
using System.Net.Sockets;
using Infragistics.Win.UltraWinEditors;

namespace SmartDas.POPUP
{
    public partial class POP_WRK87 : Form
    {
        private int ARR_COUNT = 4; // 생성할 텍스트 박스 갯수 설정 

        MESLabel[] lCHK;
        MESLabel[] lWRK_ORDR;

        TextBox[] tR_WIDTH;
        TextBox[] tWIDTH_NO;

        TextBox[] tPRD_SEQ;
        MESLabel[] lMRLDCK;
        TextBox[] tCUTTER;
        TextBox[] tREMARK;

        string[] sSLITER;
        string[] sNEXT_PROC;

        private DataTable gdtMR;

        public DataTable ResultDT
        {
            get { return gdtMR; }
        }

        public POP_WRK87(DataTable dtMR)
        {
            InitializeComponent();

            gdtMR = dtMR;

            InitControlWRK87();
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.Fixed3D;

        }

        private void InitControlWRK87()
        {
            lCHK = new MESLabel[] { lblCHK_01, lblCHK_02, lblCHK_03, lblCHK_04 };
            lWRK_ORDR = new MESLabel[] { lblWRK_ORDR_01, lblWRK_ORDR_02, lblWRK_ORDR_03, lblWRK_ORDR_04 };

            tR_WIDTH = new TextBox[] { txtR_WIDTH_01, txtR_WIDTH_02, txtR_WIDTH_03, txtR_WIDTH_04 };
            tWIDTH_NO = new TextBox[] { txtWIDTH_NO_01, txtWIDTH_NO_02, txtWIDTH_NO_03, txtWIDTH_NO_04 };
            tPRD_SEQ = new TextBox[] { txtPRD_SEQ_01, txtPRD_SEQ_02, txtPRD_SEQ_03, txtPRD_SEQ_04 };

            lMRLDCK = new MESLabel[] { lblMRLDCK_01, lblMRLDCK_02, lblMRLDCK_03, lblMRLDCK_04 };
            tCUTTER = new TextBox[] { txtCUTTER_01, txtCUTTER_02, txtCUTTER_03, txtCUTTER_04 };

            tREMARK = new TextBox[] { txtRMK_01, txtRMK_02, txtRMK_03, txtRMK_04 };

            sSLITER = new string[ARR_COUNT];
            sNEXT_PROC = new string[ARR_COUNT];

            try
            {
                for (int i = 0; i < gdtMR.Rows.Count; i++)
                {
                    lCHK[i].Text = gdtMR.Rows[i]["CHK"].ToString();
                    lWRK_ORDR[i].Text = string.Format("{0}-{1}", gdtMR.Rows[i]["WRK_ORDR_NO"].ToString(), gdtMR.Rows[i]["WRK_ORDR_SEQNO"].ToString());

                    tR_WIDTH[i].Text = gdtMR.Rows[i]["MWIDTH_INPUT"].ToString();
                    tWIDTH_NO[i].Text = gdtMR.Rows[i]["WIDTH_NO"].ToString();
                    tPRD_SEQ[i].Text = gdtMR.Rows[i]["PRD_SEQ"].ToString();

                    lMRLDCK[i].Text = gdtMR.Rows[i]["MRLDCK"].ToString();
                    lMRLDCK[i].Tag = gdtMR.Rows[i]["MRLDCK_FROM"].ToString();

                    tCUTTER[i].Text = gdtMR.Rows[i]["CUTTER"].ToString();

                    sSLITER[i] = gdtMR.Rows[i]["SLITER"].ToString();
                    sNEXT_PROC[i] = gdtMR.Rows[i]["NEXT_PROC"].ToString();

                    tREMARK[i].Text = gdtMR.Rows[i]["ORDER_RMK"].ToString();

                    bool bEnabled = lCHK[i].Text.ToString() == "V" ? true : false;
                    Color BGColor = bEnabled == true ? Color.White : lWRK_ORDR[i].BackColor;

                    tR_WIDTH[i].Enabled = bEnabled;
                    tWIDTH_NO[i].Enabled = bEnabled;
                    tPRD_SEQ[i].Enabled = bEnabled;
                    lMRLDCK[i].Enabled = bEnabled;
                    //tCUTTER[i].Enabled = bEnabled;
                    tREMARK[i].Enabled = bEnabled;

                    tR_WIDTH[i].BackColor = BGColor;
                    tWIDTH_NO[i].BackColor = BGColor;
                    tPRD_SEQ[i].BackColor = BGColor;
                    lMRLDCK[i].BackColor = bEnabled == true ? lCHK[i].BackColor : lWRK_ORDR[i].BackColor;
                    //tCUTTER[i].BackColor = BGColor;
                    tREMARK[i].BackColor = BGColor;

                    if (lMRLDCK[i].Text.ToString().Equals("Y"))
                    {
                        tCUTTER[i].Text = "0";
                        tCUTTER[i].Enabled = false;
                        tCUTTER[i].BackColor = lWRK_ORDR[i].BackColor;
                    }
                    else
                    {
                        tCUTTER[i].Enabled = true;
                        tCUTTER[i].BackColor = Color.White;
                    }

                }

                if (gdtMR.Rows.Count < ARR_COUNT)
                {
                    for (int i = gdtMR.Rows.Count; i < ARR_COUNT; i++)
                    {
                        lCHK[i].Visible = false;
                        lWRK_ORDR[i].Visible = false;

                        tR_WIDTH[i].Visible = false;
                        tWIDTH_NO[i].Visible = false;
                        tPRD_SEQ[i].Visible = false;
                        tREMARK[i].Visible = false;

                        lMRLDCK[i].Visible = false;
                        tCUTTER[i].Visible = false;
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
            }
        }

        public string LabelTitle
        {
            get { return labTitle.Text; }
            set { labTitle.Text = value; }
        }

        private void lblCHK_Click(object sender, EventArgs e)
        {
            MESLabel lblTmp = (MESLabel)sender;
            bool bEnabled;

            if (lblTmp.Text.ToString().Equals("V"))
            {
                lblTmp.Text = "-";
                bEnabled = false;
            }
            else
            {
                lblTmp.Text = "V";
                bEnabled = true;
            }

            for (int i = 0; i < gdtMR.Rows.Count; i++)
            {
                if (lblTmp == lCHK[i])
                {
                    Color BGColor = bEnabled == true ? Color.White : lWRK_ORDR[i].BackColor;

                    tR_WIDTH[i].Enabled = bEnabled;
                    tWIDTH_NO[i].Enabled = bEnabled;
                    tPRD_SEQ[i].Enabled = bEnabled;
                    lMRLDCK[i].Enabled = bEnabled;
                    //tCUTTER[i].Enabled = bEnabled;
                    tREMARK[i].Enabled = bEnabled;

                    tR_WIDTH[i].BackColor = BGColor;
                    tWIDTH_NO[i].BackColor = BGColor;
                    tPRD_SEQ[i].BackColor = BGColor;
                    lMRLDCK[i].BackColor = bEnabled == true ? lCHK[i].BackColor : lWRK_ORDR[i].BackColor;
                    //tCUTTER[i].BackColor = BGColor;
                    tREMARK[i].BackColor = BGColor;

                    if (lMRLDCK[i].Text.ToString().Equals("Y"))
                    {
                        tCUTTER[i].Text = "0";
                        tCUTTER[i].Enabled = false;
                        tCUTTER[i].BackColor = lWRK_ORDR[i].BackColor;
                    }
                    else
                    {
                        tCUTTER[i].Enabled = true;
                        tCUTTER[i].BackColor = Color.White;
                    }

                    break;
                }
            }
        }

        private void lblMRLDCK_Click(object sender, EventArgs e)
        {
            MESLabel lblTmp = (MESLabel)sender;

            if (lblTmp.Tag.ToString() == "Y")
            {
                new POPUP.MessageForm("밀롤적치만 가능한 밀롤 입니다.\r\n밀롤적치를 수정 할수 없습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return;
            }

            for (int i = 0; i < gdtMR.Rows.Count; i++)
            {
                if (lblTmp == lMRLDCK[i])
                {
                    if (sSLITER[i] == "Y")
                    {
                        new POPUP.MessageForm("슬리터 이동 작업 입니다.\r\n밀롤적치를 수정 할수 없습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                        return;
                    }

                    if (sNEXT_PROC[i] == "ROLL")
                    {
                        new POPUP.MessageForm("원지포장 작업 입니다.\r\n밀롤적치를 수정 할수 없습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                        return;
                    }

                }

            }

            if (lblTmp.Text.ToString().Equals("Y"))
            {
                lblTmp.Text = "N";
            }
            else
            {
                lblTmp.Text = "Y";
            }

            for (int i = 0; i < gdtMR.Rows.Count; i++)
            {
                if (lblTmp == lMRLDCK[i])
                {
                    if (lblTmp.Text.ToString().Equals("Y"))
                    {
                        tCUTTER[i].Text = "0";
                        tCUTTER[i].Enabled = false;
                        tCUTTER[i].BackColor = lWRK_ORDR[i].BackColor;
                    }
                    else
                    {
                        tCUTTER[i].Enabled = true;
                        tCUTTER[i].BackColor = Color.White;
                    }
                    break;
                }
            }

        }

        private void btnConfirm_Click(object sender, EventArgs e)
        {
            int nRowCnt = gdtMR.Rows.Count;
            
            bool bDuplicate = false;

            //매칭 로직 (중복된 데이터 개수 구하는 로직)
            for (int i = 0; i < nRowCnt-1; i++)
            {
                string tmpNumber = tPRD_SEQ[i].Text.ToString();

                if (string.IsNullOrEmpty(tmpNumber) == false)
                {
                    for (int k = i + 1; k < nRowCnt; k++)
                    {
                        string number = tPRD_SEQ[k].Text.ToString();

                        if (string.IsNullOrEmpty(number) == false)
                        {
                            if (number == tmpNumber)
                            {
                                bDuplicate = true;
                                break;
                            }
                        }
                    }
                }
                if (bDuplicate == true)
                {
                    break;
                }
            }

            if (bDuplicate == true)
            {
                new POPUP.MessageForm("중복된 실적 순서가 있습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);

                return;
            }


            bool bError = false;
            for (int i = 0; i < gdtMR.Rows.Count; i++)
            {
                gdtMR.Rows[i]["CHK"] = lCHK[i].Text.ToString();

                gdtMR.Rows[i]["MWIDTH_INPUT"] = tR_WIDTH[i].Text.ToString();
                gdtMR.Rows[i]["WIDTH_NO"] = tWIDTH_NO[i].Text.ToString();
                gdtMR.Rows[i]["PRD_SEQ"] = tPRD_SEQ[i].Text.ToString();

                string sMRLDCK = lMRLDCK[i].Text.ToString();
                gdtMR.Rows[i]["MRLDCK"] = sMRLDCK;

                gdtMR.Rows[i]["ORDER_RMK"] = tREMARK[i].Text.ToString();

                if (sMRLDCK == "Y")
                {
                    gdtMR.Rows[i]["CUTTER"] = "0";
                }
                else
                {
                    int nCutter = 0;
                    if (Int32.TryParse(tCUTTER[i].Text.ToString(), out nCutter))
                    {
                        gdtMR.Rows[i]["CUTTER"] = nCutter.ToString();
                    }
                    else
                    {
                        bError = true;
                        break;
                    }
                }
            }

            if (bError == true)
            {
                new POPUP.MessageForm("재단 번호 입력 오류", MessageBoxButtons.OK, "알   림").ShowDialog(this);

                return;
            }


            this.DialogResult = System.Windows.Forms.DialogResult.OK;
        }

        private void btnCancel_Click(object sender, EventArgs e)
        {
            this.DialogResult = System.Windows.Forms.DialogResult.Cancel;
        }

        private void txtPRD_SEQ_KeyPress(object sender, KeyPressEventArgs e)
        {
            if (e.KeyChar == '1' || e.KeyChar == '2' || e.KeyChar == '3' || e.KeyChar == '4' ||
                e.KeyChar == '5' || e.KeyChar == '6' || e.KeyChar == '7' || e.KeyChar == '8' || e.KeyChar == '9' )    //숫자와 백스페이스를 제외한 나머지를 바로 처리    
            {
                if (CheckDuplicate(e.KeyChar.ToString()) == true)
                    e.Handled = true;
            }
            else if (e.KeyChar != Convert.ToChar(Keys.Back))
            {
                e.Handled = true;
            }
        }


        private bool CheckDuplicate(string tmpNumber)
        {
            int nRowCnt = gdtMR.Rows.Count;

            bool bDuplicate = false;

            //매칭 로직 (중복된 데이터 개수 구하는 로직)
            if (string.IsNullOrEmpty(tmpNumber) == false)
            {
                for (int k = 0; k < nRowCnt; k++)
                {
                    string number = tPRD_SEQ[k].Text.ToString();

                    if (string.IsNullOrEmpty(number) == false)
                    {
                        if (number == tmpNumber)
                        {
                            bDuplicate = true;
                            break;
                        }
                    }
                }
            }

            return bDuplicate;
        }

        private void CUTTER_KeyPress(object sender, KeyPressEventArgs e)
        {
            //숫자만 입력되도록 필터링
            if (!(char.IsDigit(e.KeyChar) || e.KeyChar == Convert.ToChar(Keys.Back)))    //숫자와 백스페이스를 제외한 나머지를 바로 처리    
            {
                e.Handled = true;
            }
        }

        private void MR_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.KeyData == Keys.Enter)
            {
                e.SuppressKeyPress = true;
                SelectNextControl(ActiveControl, true, true, true, true);
            }
        }

    }
}
