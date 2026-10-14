using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using SmartDas.Components;
using SAMMI;
using System.Runtime.InteropServices;

namespace SmartDas.POPUP
{
    public partial class DAResultTime : Form
    {
        private string resultString = "";

        private int sInMaxLen = 4;
        private string sInData = "";

        public string ResultString
        {
            get
            {
                return resultString;
            }
        }

        public DAResultTime(string sTimeFormat = "HHmm")
        {
            InitializeComponent();

            this.TopMost = true;

            if (sTimeFormat == "HHmm")
            {
                sInMaxLen = 4;
                txtContent.Text = "__:__";
            }
            else
            {
                //점보롤인경우는 시분초까지 입력 가능하도록 수정
                sInMaxLen = 6;
                txtContent.Text = "__:__:__";
            }
        }

        public string LabelTitle
        {
            get { return labTitle.Text; }
            set { labTitle.Text = value;}
        }

        public string LabelHeader
        {
            get { return labHeader.Text; }
            set { labHeader.Text = value; }
        }

        public string ContentText
        {
            get { return txtContent.Text; }
            set { txtContent.Text = value; }
        }

        private void DAResultTime_Load(object sender, EventArgs e)
        {
            //SetButtons();
            //txtContent.Focus();
        }

        private void btn_type(string s)
        {
            string strHour = "";
            string strMin = "";
            string strSec = "";
            int nHour = 0;
            int nMin = 0;
            int nSec = 0;

            if (s == "")
                return;

            byte b = (byte)s[0];

            switch (s)
            {
                case "모두지움":
                    sInData = "";
                    break;
                case "◀":
                    if (sInData.Length > 0)
                    {
                        sInData = sInData.Substring(0, sInData.Length - 1);
                    }
                    break;
                case "확인":

                    //2018 05 08 HJH 
                    //숫자만 입력 할 수 있도록
                    //정수만 입력 할 수 있도록(실적을 소수점 단위로 잡지 않음, 또한 라벨 매수는 소수점이 필요 없음)
                    int lString = 0;
                    //int nHour = 0;
                    //int nMin = 0;

                    bool canConvert = int.TryParse(sInData.Trim(), out lString);
                    if (canConvert != true)
                    {
                        lblErrorMessage.BackColor = Color.DarkRed;
                        lblErrorMessage.ForeColor = Color.White;
                        lblErrorMessage.Text = "수가 너무 크거나 정수변환 에러가 발생했습니다.\n지금보다 작은 수를 입력하거나 취소 후 다시 실행해주세요.";
                        return;
                    }

#if false
                    if (sInData.Length == 3)
                    {
                        strHour = sInData.Substring(0, 1);
                        strMin = sInData.Substring(1);
                    }
                    else if (sInData.Length == 4)
                    {
                        strHour = sInData.Substring(0, 2);
                        strMin = sInData.Substring(2);
                    }
                    else
                    {
                        lblErrorMessage.BackColor = Color.DarkRed;
                        lblErrorMessage.ForeColor = Color.White;
                        lblErrorMessage.Text = "시간 입력 에러가 발생했습니다.\n시간 입력을 확인 후 다시 실행해주세요.";
                        return;
                    }
#else
                    if (sInData.Length == sInMaxLen)
                    {
                        strHour = sInData.Substring(0, 2);
                        strMin = sInData.Substring(2, 2);
                        strSec = sInData.Substring(4);
                    }
                    else
                    {
                        lblErrorMessage.BackColor = Color.DarkRed;
                        lblErrorMessage.ForeColor = Color.White;
                        lblErrorMessage.Text = "시간 입력 에러가 발생했습니다.\n시간 입력을 확인 후 다시 실행해주세요.";
                        return;
                    }
#endif

                    try
                    {
                        //nHour = Convert.ToInt32(strHour);
                        //nMin = Convert.ToInt32(strMin);

                        if (!int.TryParse(strHour, out nHour)) nHour = 0;
                        if (!int.TryParse(strMin, out nMin)) nMin = 0;

                        if (sInData.Length == 6)
                        {
                            if (!int.TryParse(strSec, out nSec)) nSec = 0;
                        }
                        else
                        {
                            nSec = 0;
                        }
                    }
                    catch
                    {
                        //lblErrorMessage.Text = "시간 입력 에러가 발생했습니다. \n시간 입력을 확인 후 다시 실행해주세요.";
                        nHour = nMin = nSec = -1;
                        return;
                    }


                    if (!(nHour >= 0 && nHour < 24) || !(nMin >= 0 && nMin < 60) || !(nSec >= 0 && nSec < 60))
                    {
                        lblErrorMessage.BackColor = Color.DarkRed;
                        lblErrorMessage.ForeColor = Color.White;
                        lblErrorMessage.Text = "시간 입력 에러가 발생했습니다.\n시간 입력을 확인 후 다시 실행해주세요.";
                        return;
                    }
                    else{
                        lblErrorMessage.Text = "";
                    }

                    if (sInData.Length == 4)
                        resultString = string.Format("{0:0#}:{1:0#}", nHour, nMin);
                    else
                        resultString = string.Format("{0:0#}:{1:0#}:{2:0#}", nHour, nMin, nSec);

                    //resultString = string.Format("{0:0#}:{1:0#}:00", nHour, nMin);
                    this.DialogResult = System.Windows.Forms.DialogResult.OK;
                    break;

                case "취소":
                    this.DialogResult = System.Windows.Forms.DialogResult.Cancel;
                    break;
                default:
                    if (sInData.Length < sInMaxLen)
                    {
                        sInData += s;
                    }
                    break;
            }

#if false
            if (sInData.Length == 0)
            {
                txtContent.Text = "__시__분";
            }
            else if (sInData.Length == 1)
            {
                txtContent.Text = string.Format("__시_{0}분", sInData);
            }
            else if (sInData.Length == 2)
            {
                txtContent.Text = string.Format("__시{0}분", sInData);
            }
            else if (sInData.Length == 3)
            {
                strHour = sInData.Substring(0, 1);
                strMin = sInData.Substring(1);
                txtContent.Text = string.Format("_{0}시{1}분", strHour, strMin);
            }
            else
            {
                strHour = sInData.Substring(0, 2);
                strMin = sInData.Substring(2);
                txtContent.Text = string.Format("{0}시{1}분", strHour, strMin);
            }
#else
            if (sInData.Length == 0)
            {
                if(sInMaxLen == 4)
                    txtContent.Text = "__:__";
                else
                    txtContent.Text = "__:__:__";
            }
            else if (sInData.Length == 1)
            {
                if (sInMaxLen == 4)
                    txtContent.Text = sInData + "_:__";
                else
                    txtContent.Text = sInData + "_:__:__";
            }
            else if (sInData.Length == 2)
            {
                if (sInMaxLen == 4)
                    txtContent.Text = sInData + ":__";
                else

                    txtContent.Text = sInData + ":__:__";
            }
            else if (sInData.Length == 3)
            {
                strMin = sInData.Substring(2);
                if (sInMaxLen == 4)
                {
                    txtContent.Text = sInData.Substring(0, 2) + ":" + strMin + "_";
                }
                else
                {
                    txtContent.Text = sInData.Substring(0, 2) + ":" + strMin + "_:__";
                }

            }
            else if (sInData.Length == 4)
            {
                strMin = sInData.Substring(2);
                if (sInMaxLen == 4)
                    txtContent.Text = sInData.Substring(0, 2) + ":" + strMin;
                else
                    txtContent.Text = sInData.Substring(0, 2) + ":" + strMin + ":__"; ;
            }
            else if (sInData.Length == 5)
            {
                strMin = sInData.Substring(2, 2);
                strSec = sInData.Substring(4);
                txtContent.Text = sInData.Substring(0, 2) + ":" + strMin + ":" + strSec + "_";
            }
            else
            {
                strMin = sInData.Substring(2, 2);
                strSec = sInData.Substring(4);
                txtContent.Text = sInData.Substring(0, 2) + ":" + strMin + ":" + strSec;
            }

#endif
        }

        private void txtContent_Leave(object sender, EventArgs e)
        {
        }

        private void DA9200_Activated(object sender, EventArgs e)
        {
        }

        #region  [버튼 이벤트]
        private void but_Click(object sender, EventArgs e)
        {
            Button btn = (Button)sender;
           
            string s = btn.Text.ToUpper();
            
            btn_type(s);
        }
        #endregion

        //private void SetButtons()
        //{
        //    try
        //    {
       
        //    }
        //    catch (Exception ex)
        //    {
        //        //SetMessage("SetButtons Error!");
        //        LogFile.WriteLog("DASMain.SetButtons Error\r\n" + ex.Message);
        //    }
        //}

        protected override bool ProcessCmdKey(ref Message msg, Keys keyData)
        {
            string s = "";
            char key = (char)keyData;

            if (keyData >= Keys.D0 && keyData <= Keys.D9)
            {
                s = string.Format("{0}", keyData - Keys.D0);
            }
            else if (keyData >= Keys.NumPad0 && keyData <= Keys.NumPad9)
            {
                s = string.Format("{0}", keyData - Keys.NumPad0);
            }
            else if (keyData == Keys.Back)
            {
                s = "◀";
            }
            else if (keyData == Keys.Enter)
            {
                s = "확인";
            }

            if (String.IsNullOrEmpty(s) == false)
            {
                btn_type(s);

                return true;
            }

            return base.ProcessCmdKey(ref msg, keyData);

        }

    }
}
