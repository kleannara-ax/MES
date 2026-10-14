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
    public partial class MessageForm : Form
    {

        //2018 05 04 HJH
        public MessageForm(string Message, string btn1, string btn2, string lblTitle = "알   림")
        {
            InitializeComponent();

            this.lblTitle.Text = lblTitle;

            this.txtMessage.TextHAlign = Infragistics.Win.HAlign.Center;

            if (Message.Contains("\\n"))
            {
                Message = Message.Replace("\\n", "\n");
            }
            this.txtMessage.Text = Message;

            btnBox.CountY = 1;

            btnBox.Width = 500;
            btnBox.Left = this.Width - 14 - btnBox.Width;
            btnBox.CountX = 3;
            btnBox.SetButtons();
            btnBox[0, 0].Text = btn1;
            btnBox[0, 0].Tag = DialogResult.OK;
            btnBox[0, 1].Text = btn2;
            btnBox[0, 1].Tag = DialogResult.Cancel;
            btnBox[0, 2].Text = "취소";
            btnBox[0, 2].Tag = DialogResult.Ignore;
        }

        public MessageForm(string Message, MessageBoxButtons buttons = MessageBoxButtons.OK, string lblTitle = "알   림")
        {
            InitializeComponent();

            this.lblTitle.Text = lblTitle;

            if (Message.Contains("\\n"))
            {
                Message = Message.Replace("\\n", "\n");
            }
            this.txtMessage.Text = Message;

            btnBox.CountY = 1;

            switch (buttons)
            {
                case MessageBoxButtons.OK:
                    // 버튼 1개
                    btnBox.Width = 240;
                    btnBox.Left = this.Width - 14 - btnBox.Width;
                    btnBox.CountX = 1;
                    btnBox.SetButtons();

                    btnBox[0, 0].Text = "확인";
                    btnBox[0, 0].Tag = DialogResult.OK;
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

        public MessageForm(string Message, Infragistics.Win.HAlign textAllign,  MessageBoxButtons buttons = MessageBoxButtons.OK, string lblTitle = "알   림")
        {
            InitializeComponent();

            this.lblTitle.Text = lblTitle;

            this.txtMessage.TextHAlign = textAllign;

            if (Message.Contains("\\n"))
            {
                Message = Message.Replace("\\n", "\n");
            }
            this.txtMessage.Text = Message;

            btnBox.CountY = 1;

            switch (buttons)
            {
                case MessageBoxButtons.OK:
                    // 버튼 1개
                    btnBox.Width = 240;
                    btnBox.Left = this.Width - 14 - btnBox.Width;
                    btnBox.CountX = 1;
                    btnBox.SetButtons();

                    btnBox[0, 0].Text = "확인";
                    btnBox[0, 0].Tag = DialogResult.OK;
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
            this.DialogResult = (DialogResult)(sender.Tag);
        }
    }
}
