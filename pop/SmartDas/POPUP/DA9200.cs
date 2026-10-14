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

namespace SmartDas.POPUP
{
    public partial class DA9200 : Form
    {
        System.Windows.Forms.Button[] btnArray = new System.Windows.Forms.Button[40];

        private string resultString = "";

        public string ResultString
        {
            get
            {
                return resultString;
            }
        }

        [DllImport("user32.dll")]
        static extern uint keybd_event(byte bVk, byte bScan, int dwFlags, int dwExtraInfo);

        public DA9200()
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

        private void DA9200_Load(object sender, EventArgs e)
        {
            AddButtons();

            this.ActiveControl = txtContent;
            txtContent.Focus();
        }

        private void AddButtons()
        {
            int xPos = 0;
            int yPos = 0;

            char[] btnData = {
                  '1', '2', '3', '4', '5', '6', '7', '8', '9', '0'
                , 'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'
                , 'A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L', '.'
                , 'Z', 'X', 'C', 'V', 'B', 'N', 'M', '-', '_', '/' };
            
            // Declare and assign number of buttons = 40
            // Create (40) Buttons:
            for (int i = 0; i < 40; i++)
            {
                // Initialize one variable
                btnArray[i] = new System.Windows.Forms.Button();
            }


            int n = 0;
            while (n < 40)
            {
                btnArray[n].Tag = n + 1; // Tag of button
                btnArray[n].Width = 90; // Width of button
                btnArray[n].Height = 100; // Height of button
                btnArray[n].BackColor = Color.FromArgb(182, 205, 249);    // Color.FromArgb(223, 235, 253);
                btnArray[n].Font = new Font("맑은 고딕", 18, FontStyle.Bold);
                btnArray[n].FlatStyle = FlatStyle.Flat;
                btnArray[n].FlatAppearance.BorderColor = Color.Gray;
                btnArray[n].FlatAppearance.BorderSize = 2;
                btnArray[n].FlatAppearance.MouseDownBackColor = Color.FromArgb(255, 192, 192);


                if ( (n > 0) && ((n%10) == 0) ) // Location of second line of buttons:
                {
                    xPos = 0;
                    yPos += 107;
                }
                // Location of button:
                btnArray[n].Left = xPos;
                btnArray[n].Top = yPos;
                
                // Add buttons to a Panel:
                pnlButtons.Controls.Add(btnArray[n]); // Let panel hold the Buttons
                xPos = xPos + btnArray[n].Width + 7; // Left of next button
                
                // Write English Character:
                //btnArray[n].Text = ((char)(n + 65)).ToString();
                btnArray[n].Text = btnData[n].ToString();

                // the Event of click Button
                btnArray[n].Click += new System.EventHandler(but_Click);
                n++;
            }
        }

        private void btn_Click(object sender, EventArgs e)
        {
            txtContent.Focus();
            MESButton btn = (MESButton)sender;

            switch (btn.Text)
            {
                case " ":
                    keybd_event((byte)Keys.Space, 0, 0, 0);
                    keybd_event((byte)Keys.Space, 0, 0x02, 0);
                    break;
                case "대문자":
                    foreach (Button b in btnArray)
                    {
                        b.Text = b.Text.ToLower();
                    }

                    btn.Text = "소문자";
                    break;
                case "소문자":
                    foreach (Button b in btnArray)
                    {
                        b.Text = b.Text.ToUpper();
                    }
                    btn.Text = "대문자";
                    break;
                case "모두지움":
                    txtContent.Text = "";
                    break;
                case "◀":
                    keybd_event((byte)Keys.Back, 0, 0, 0);
                    keybd_event((byte)Keys.Back, 0, 0x02, 0);
                    break;
                case "확인":
                    resultString = txtContent.Text.Trim();
                    this.DialogResult = System.Windows.Forms.DialogResult.OK;
                    break;
                case "취소":
                    this.DialogResult = System.Windows.Forms.DialogResult.Cancel;
                    break;
            }

            txtContent.Focus();
        }

        private void txtContent_Leave(object sender, EventArgs e)
        {
            txtContent.Focus();

            keybd_event((byte)Keys.End, 0, 0, 0);
            keybd_event((byte)Keys.End, 0, 0x02, 0);
        }

        private void DA9200_Activated(object sender, EventArgs e)
        {
            this.ActiveControl = txtContent;
            txtContent.Focus();
        }

        private void txtContent_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.KeyCode == Keys.Enter)
            {
                resultString = txtContent.Text.Trim();
                this.DialogResult = System.Windows.Forms.DialogResult.OK;
            }
        }

        private void but_Click(object sender, EventArgs e)
        {
            txtContent.Focus();

            Button btn = (Button)sender;

            string s = btn.Text.ToUpper();

            btn_type(s);
        }

        private void btn_type(string s)
        {
            keybd_event((byte)Keys.End, 0, 0, 0);
            keybd_event((byte)Keys.End, 0, 0x02, 0);

            if (s == "")
                return;

            byte b = (byte)s[0];

            switch (s)
            {
                case ".":
                    keybd_event((byte)Keys.OemPeriod, 0, 0, 0);
                    keybd_event((byte)Keys.OemPeriod, 0, 0x02, 0);
                    break;
                case "-":
                    keybd_event((byte)Keys.OemMinus, 0, 0, 0);
                    keybd_event((byte)Keys.OemMinus, 0, 0x02, 0);
                    break;
                case "_":
                    keybd_event((byte)Keys.LShiftKey, 0, 0, 0);
                    keybd_event((byte)Keys.OemMinus, 0, 0, 0);
                    keybd_event((byte)Keys.OemMinus, 0, 0x02, 0);
                    keybd_event((byte)Keys.LShiftKey, 0, 0x02, 0);
                    break;
                case "/":
                    keybd_event((byte)Keys.OemQuestion, 0, 0, 0);
                    keybd_event((byte)Keys.OemQuestion, 0, 0x02, 0);
                    break;
                case "1":
                case "2":
                case "3":
                case "4":
                case "5":
                case "6":
                case "7":
                case "8":
                case "9":
                case "0":
                    keybd_event(b, 0, 0, 0);
                    keybd_event(b, 0, 0x02, 0);
                    break;
                default:
                    if (Control.IsKeyLocked(Keys.CapsLock) == false)
                    {
                        if (btnChnage.Text == "대문자" /*&& (e.x > 0)*/)
                        {
                            keybd_event((byte)Keys.LShiftKey, 0, 0, 0);
                            keybd_event(b, 0, 0, 0);
                            keybd_event(b, 0, 0x02, 0);
                            keybd_event((byte)Keys.LShiftKey, 0, 0x02, 0);
                        }
                        else
                        {
                            keybd_event(b, 0, 0, 0);
                            keybd_event(b, 0, 0x02, 0);
                        }
                    }
                    else
                    {
                        if (btnChnage.Text == "소문자" /*&& (e.x > 0)*/)
                        {
                            keybd_event((byte)Keys.LShiftKey, 0, 0, 0);
                            keybd_event(b, 0, 0, 0);
                            keybd_event(b, 0, 0x02, 0);
                            keybd_event((byte)Keys.LShiftKey, 0, 0x02, 0);
                        }
                        else
                        {
                            keybd_event(b, 0, 0, 0);
                            keybd_event(b, 0, 0x02, 0);
                        }
                    }

                    break;
            }
        }

    }
}
