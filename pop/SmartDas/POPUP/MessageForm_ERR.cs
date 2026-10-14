using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using SmartDas.Components;

namespace SmartDas.POPUP
{
    public partial class MessageForm_ERR : Form
    {
        private Size origin_Size = new Size();


        public MessageForm_ERR(string MainMessage, string Message, MessageBoxButtons buttons = MessageBoxButtons.OK)
        {
            InitializeComponent();

            if (Message.Contains("\\n"))
            {
                Message = Message.Replace("\\n", "\n");
            }
            this.lblTitle.Text = MainMessage;
            this.subMessageText.Text = Message;

            btnBox.CountY = 1;

            origin_Size = this.Size;

            switch (buttons)
            {
                case MessageBoxButtons.OK:
                    // 버튼 1개
                    btnBox.Width = 360;
                    btnBox.Left = this.Width - 14 - btnBox.Width;
                    btnBox.CountX = 1;
                    btnBox.SetButtons();

                    btnBox[0, 0].Text = "확인";
                    btnBox[0, 0].Tag = DialogResult.OK;
                    //btnBox[0, 1].Text = "자세히";
                    //btnBox[0, 1].Tag = DialogResult.None;
                    break;
                case MessageBoxButtons.OKCancel:
                case MessageBoxButtons.RetryCancel:
                case MessageBoxButtons.YesNo:
                    // 버튼 2개
                    btnBox.Width = 360;
                    btnBox.Left = this.Width - 14 - btnBox.Width;
                    btnBox.CountX = 2;
                    btnBox.SetButtons();
                    switch (buttons)
                    {
                        case MessageBoxButtons.OKCancel:
                            btnBox[0, 0].Text = "확인";
                            btnBox[0, 0].Tag = DialogResult.OK;

                            btnBox[0, 1].Text = "취소";
                            btnBox[0, 1].Tag = DialogResult.Cancel;
                            break;
                        case MessageBoxButtons.RetryCancel:
                            btnBox[0, 0].Text = "재시도";
                            btnBox[0, 0].Tag = DialogResult.Retry;

                            btnBox[0, 1].Text = "취소";
                            btnBox[0, 1].Tag = DialogResult.Cancel;
                            break;
                        case MessageBoxButtons.YesNo:
                            btnBox[0, 0].Text = "예";
                            btnBox[0, 0].Tag = DialogResult.Yes;

                            btnBox[0, 1].Text = "아니오";
                            btnBox[0, 1].Tag = DialogResult.No;
                            break;
                    }
                    break;
                case MessageBoxButtons.AbortRetryIgnore:
                case MessageBoxButtons.YesNoCancel:
                    // 버튼 3개
                    btnBox.Width = 480;
                    btnBox.Left = this.Width - 14 - btnBox.Width;
                    btnBox.CountX = 3;
                    btnBox.SetButtons();
                    switch (buttons)
                    {
                        case MessageBoxButtons.AbortRetryIgnore:
                            btnBox[0, 0].Text = "중지";
                            btnBox[0, 0].Tag = DialogResult.Yes;

                            btnBox[0, 1].Text = "재시도";
                            btnBox[0, 1].Tag = DialogResult.Retry;

                            btnBox[0, 2].Text = "무시";
                            btnBox[0, 2].Tag = DialogResult.Ignore;
                            break;
                        case MessageBoxButtons.YesNoCancel:
                            btnBox[0, 0].Text = "예";
                            btnBox[0, 0].Tag = DialogResult.Yes;

                            btnBox[0, 1].Text = "아니오";
                            btnBox[0, 1].Tag = DialogResult.No;

                            btnBox[0, 2].Text = "취소";
                            btnBox[0, 2].Tag = DialogResult.Cancel;
                            break;
                    }
                    break;
            }
        }
 

        private void btnBox_buttonClickEvent(MESButton sender, ButtonBox.ButtonClickEventArg e)
        {
            if ((DialogResult)(sender.Tag) == DialogResult.None)
            {
                if (origin_Size == this.Size)
                {
                    this.Size = new Size(this.Size.Width, this.Size.Height + this.subMessageText.Size.Height + 30);
                }
                else
                {
                    this.Size = origin_Size;
                }
                return;
            }
            this.DialogResult = (DialogResult)(sender.Tag);
        }

        private void subMessageText_TextChanged(object sender, EventArgs e)
        {

        }
    }
}
