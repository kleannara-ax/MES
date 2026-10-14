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
    public partial class DAResultNum : Form
    {
        private double resultDouble = 0;
        private string resultString = "";

        public double ResultDouble
        {
            get
            {
                return resultDouble;
            }
        }
        
        public string ResultString
        {
            get
            {
                return resultString;
            }
        }

        [DllImport("user32.dll")]
        static extern uint keybd_event(byte bVk, byte bScan, int dwFlags, int dwExtraInfo);

        public DAResultNum()
        {
            InitializeComponent();

            this.TopMost = true;
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

        public int ContentMaxLength
        {
            get { return txtContent.MaxLength; }
            set { txtContent.MaxLength = value; }
        }

        private void DAResultNum_Load(object sender, EventArgs e)
        {
            SetButtons();

            this.ActiveControl = txtContent;
            txtContent.Focus();
        }

        private void btn_type(string s)
        {
            // 팝업 종료할경우 호출한 화면의 Grid가 포커스가 있는경우 오동작 발생하여 수정.
            if ((s.Equals("확인") || s.Equals("닫기")) == false)
            {
                keybd_event((byte)Keys.End, 0, 0, 0);
                keybd_event((byte)Keys.End, 0, 0x02, 0);
            }

            if (s == "")
                return;

            byte b = (byte)s[0];

            switch (s)
            {
                case ".":
                    if (txtContent.Text.Trim() == "")
                    {
                        txtContent.Text = "0.";
                        txtContent.Focus();
                        txtContent.Select(txtContent.Text.Length, 0);
                        break;
                    }
                    else
                    {
                        if (txtContent.Text.IndexOf(".") >= 0)
                        {
                            break;
                        }
                    }
                    keybd_event((byte)Keys.OemPeriod, 0, 0, 0);
                    keybd_event((byte)Keys.OemPeriod, 0, 0x02, 0);
                    break;
                case "-":
                    if (txtContent.Text.Trim() != "")
                    {
                        txtContent.Text = "-" + txtContent.Text;
                        txtContent.Focus();
                        txtContent.Select(txtContent.Text.Length, 0);
                    }
                    break;
                case "+":
                    if (txtContent.Text.Trim() != "")
                    {
                        txtContent.Text = txtContent.Text.Substring(1);
                        txtContent.Focus();
                        txtContent.Select(txtContent.Text.Length, 0);
                    }
                    break;
                case "모두지움":
                    txtContent.Text = "";
                    break;
                case "◀":
                    keybd_event((byte)Keys.Back, 0, 0, 0);
                    keybd_event((byte)Keys.Back, 0, 0x02, 0);
                    break;
                case "확인":
                    double lString = 0;
                    if (txtContent.Text.Trim().Length != 0)
                    {
                        bool canConvert = double.TryParse(txtContent.Text.Trim(), out lString);
                        if (canConvert != true)
                        {
                            lblErrorMessage.BackColor = Color.DarkRed;
                            lblErrorMessage.ForeColor = Color.White;
                            lblErrorMessage.Text = "수가 너무 크거나 실수변환 에러가 발생했습니다. \n지금보다 작은 수를 입력하거나 취소 후 다시 실행해주세요.";
                            return;
                        }
                    }
                    //현재 메시지큐에 있는 모든 메시지 처리함수 
                    SendKeys.Flush();

                    resultString = txtContent.Text.Trim();
                    resultDouble = resultString == "" ? 0 : Convert.ToDouble(resultString.Replace(",",""));                    
                    this.DialogResult = System.Windows.Forms.DialogResult.OK;
                    break;

                case "닫기":
                    //현재 메시지큐에 있는 모든 메시지 처리함수 
                    SendKeys.Flush();

                    this.DialogResult = System.Windows.Forms.DialogResult.Cancel;
                    break;
                case "0":
                    if (txtContent.Text.Trim() != "0")
                    {
                        keybd_event(b, 0, 0, 0);
                        keybd_event(b, 0, 0x02, 0);
                    }
                    break;
                case "00":
                    if (txtContent.Text.Trim() == "")
                    {
                        keybd_event(b, 0, 0, 0);
                        keybd_event(b, 0, 0x02, 0);
                    }
                    else if (txtContent.Text.Trim() != "0")
                    {
                        keybd_event(b, 0, 0, 0);
                        keybd_event(b, 0, 0x02, 0);
                        keybd_event(b, 0, 0, 0);
                        keybd_event(b, 0, 0x02, 0);
                    }
                    break;
                default:
                    if (txtContent.Text.Trim() == "0")
                    {
                        txtContent.Text = "";
                    }
                    keybd_event(b, 0, 0, 0);
                    keybd_event(b, 0, 0x02, 0);
                    break;
            }
        }

        private void txtContent_Leave(object sender, EventArgs e)
        {
            txtContent.Focus();

            keybd_event((byte)Keys.End, 0, 0, 0);
            keybd_event((byte)Keys.End, 0, 0x02, 0);            
        }

        private void DA9200_Activated(object sender, EventArgs e)
        {
            txtContent.Focus();
        }

        #region  [버튼 이벤트]
        private void but_Click(object sender, EventArgs e)
        {
            txtContent.Focus();

            Button btn = (Button)sender;
           
            string s = btn.Text.ToUpper();
            
            btn_type(s);
        }
        #endregion

        private void SetButtons()
        {
            try
            {
       
            }
            catch (Exception ex)
            {
                //SetMessage("SetButtons Error!");
                LogFile.WriteLog("DASMain.SetButtons Error =>" + ex.Message);
            }
        }

        private void txtContent_KeyPress(object sender, KeyPressEventArgs e)
        {
            //숫자만 입력되도록 필터링
            if (e.KeyChar == Convert.ToChar(Keys.Enter))
            {
                btn_type("확인");
            }
            else if (!(char.IsDigit(e.KeyChar) || e.KeyChar == Convert.ToChar(Keys.Back) || e.KeyChar == '.'))    //숫자와 백스페이스를 제외한 나머지를 바로 처리
            {
                e.Handled = true;
            }
            else if (e.KeyChar == 0x30)
            {
                if (txtContent.Text.Trim() == "0")
                {
                    e.Handled = true;
                }
            }
            else if (e.KeyChar == '.')
            {
                if (butcom.Enabled == true)
                {
                    string sContent = txtContent.Text.Trim();

                    if (sContent == "")     // 입력된 숫자가 없는경우는 추가 안함
                    {
                        e.Handled = true;
                    }
                    else if (sContent.Contains("."))    // '.'이 포함된경우는 '.' 추가 안함
                    {
                        e.Handled = true;
                    }
                }
                else
                {
                    e.Handled = true;
                }
            }
        }  
    }
}
