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
    public partial class DAResultText : Form
    {
        private string resultString = "";

        private bool gbNullCheck = false;
        private string gbNullCheckString = "내용이 없습니다.";

        public string ResultString
        {
            get
            {
                return resultString;
            }
        }

        public DAResultText(string sTitle)
        {
            InitializeComponent();

            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.Fixed3D;

            lblTitle.Text = sTitle;
        }

        public DAResultText(string sTitle, string sContent)
        {
            InitializeComponent();

            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.Fixed3D;

            lblTitle.Text = sTitle;
            txtContent.Text = sContent;
        }

        public int ContentMaxLength
        {
            get { return txtContent.MaxLength; }
            set { txtContent.MaxLength = value; }
        }

        public bool bNullCheck
        {
            get { return gbNullCheck; }
            set { gbNullCheck = value; }
        }
        
        public string NullCheckString
        {
            get { return gbNullCheckString; }
            set { gbNullCheckString = value; }
        }


        private void DAResultText_Load(object sender, EventArgs e)
        {
            this.ActiveControl = txtContent;
            txtContent.Focus();
        }

        private void btnCancel_Click(object sender, EventArgs e)
        {
            this.DialogResult = System.Windows.Forms.DialogResult.Cancel;
        }

        private void ResultStringNullCheck()
        {
            if (gbNullCheck == true)
            {
                if (string.IsNullOrEmpty(txtContent.Text.Trim()))
                {
                    new POPUP.MessageForm(gbNullCheckString, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return;
                }
            }

            resultString = txtContent.Text.Trim();
            this.DialogResult = System.Windows.Forms.DialogResult.OK;
        }

        private void btnOK_Click(object sender, EventArgs e)
        {
            ResultStringNullCheck();

            //resultString = txtContent.Text.Trim();
            //this.DialogResult = System.Windows.Forms.DialogResult.OK;
        }


        private void txtContent_KeyPress(object sender, KeyPressEventArgs e)
        {
            if (e.KeyChar == Convert.ToChar(Keys.Enter))
            {
                ResultStringNullCheck();

                //resultString = txtContent.Text.Trim();
                //this.DialogResult = System.Windows.Forms.DialogResult.OK;
            }
        }

    }
}
