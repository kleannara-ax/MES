using System;
using System.Drawing;
using System.Windows.Forms;

namespace SmartDas.POPUP
{
    public partial class POP_Login : Form
    {
        private int gnRetryCnt;

        public POP_Login()
        {
            InitializeComponent();

            gnRetryCnt = 0;
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.Fixed3D;
        }

        private void LogIN()
        {
            if (string.IsNullOrEmpty(txtID.Text))
            {
                new POPUP.MessageForm("관리자 ID를 입력하세요.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                //MessageBox.Show("관리자 ID를 입력하세요.");
                txtID.Focus();
                return;
            }

            if (string.IsNullOrEmpty(txtPWD.Text))
            {
                new POPUP.MessageForm("인증번호를 입력하세요.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                //MessageBox.Show("패스워드를 입력하세요.");
                txtPWD.Focus();
                return;
            }

            string retCode = Common.Cert_Check(txtID.Text, txtPWD.Text);

            if (retCode == "S")
            {
                // 로그인 OK
                new POPUP.MessageForm("인증성공 했습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                this.DialogResult = System.Windows.Forms.DialogResult.OK;
            }
            else if (retCode == "N")
            {
                new POPUP.MessageForm("일치하는 ID 정보가 없습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
            }
            else
            {
                new POPUP.MessageForm("인증실패 했습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
            }

            if (++gnRetryCnt >= 3)
            {
                this.DialogResult = System.Windows.Forms.DialogResult.Cancel;
            }
        }

        private void btnOK_Click(object sender, EventArgs e)
        {
            //로그인 체크 로직 호출
            LogIN();
        }

        private void btnCancel_Click(object sender, EventArgs e)
        {
            this.DialogResult = System.Windows.Forms.DialogResult.Cancel;
        }

        private void txtID_KeyPress(object sender, KeyPressEventArgs e)
        {
            if (e.KeyChar == (char)Keys.Enter)
            {
                if (string.IsNullOrEmpty(txtID.Text))
                {
                    e.Handled = false;
                }
                else
                {
                    if (string.IsNullOrEmpty(txtPWD.Text))
                    {
                        e.Handled = false;
                        SendKeys.Send("{TAB}"); // tab key를 실행한다.
                    }
                    else
                    {
                        LogIN();
                    }
                }
            }
        }

        private void txtPWD_KeyPress(object sender, KeyPressEventArgs e)
        {
            if (e.KeyChar == (char)Keys.Enter)
            {
                if (string.IsNullOrEmpty(txtPWD.Text))
                {
                    e.Handled = false;
                }
                else
                {
                    if (string.IsNullOrEmpty(txtID.Text))
                    {
                        new POPUP.MessageForm("관리자 ID를 입력하세요.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
//                        MessageBox.Show("관리자 ID를 입력하세요.");
                        txtID.Focus();
                        e.Handled = false;
                    }
                    else
                    {
                        LogIN();
                    }
                }
            }
        }

        private void TextBox_Enter(object sender, EventArgs e)
        {
            TextBox textBox = sender as TextBox;
            if (textBox != null)
            {
                textBox.BackColor = Color.Yellow;
            }
        }

        private void textBox_Leave(object sender, EventArgs e)
        {
            TextBox textBox = sender as TextBox;
            if (textBox != null)
            {
                textBox.BackColor = Color.White;
            }
        }

    }
}
