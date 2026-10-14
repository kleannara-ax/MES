using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace SmartDas.POPUP
{
    public partial class POPQty : Form
    {
        private double resultDouble = 0;
        private string resultString = "";

        string sQty = "";

        public POPQty()
        {
            InitializeComponent();
        }

        public POPQty(string sTitle)
        {
            InitializeComponent();
            labTitle.Text = sTitle;
        }

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

        private void but7_Click(object sender, EventArgs e)
        {
            sQty = sQty + but7.Text;
            txtContent.Text = sQty;
        }

        private void but8_Click(object sender, EventArgs e)
        {
            sQty = sQty + but8.Text;
            txtContent.Text = sQty;
        }

        private void but9_Click(object sender, EventArgs e)
        {
            sQty = sQty + but9.Text;
            txtContent.Text = sQty;
        }

        private void but4_Click(object sender, EventArgs e)
        {
            sQty = sQty + but4.Text;
            txtContent.Text = sQty;
        }

        private void but5_Click(object sender, EventArgs e)
        {
            sQty = sQty + but5.Text;
            txtContent.Text = sQty;
        }

        private void but6_Click(object sender, EventArgs e)
        {
            sQty = sQty + but6.Text;
            txtContent.Text = sQty;
        }

        private void but1_Click(object sender, EventArgs e)
        {
            sQty = sQty + but1.Text;
            txtContent.Text = sQty;
        }

        private void but2_Click(object sender, EventArgs e)
        {
            sQty = sQty + but2.Text;
            txtContent.Text = sQty;
        }

        private void but3_Click(object sender, EventArgs e)
        {
            sQty = sQty + but3.Text;
            txtContent.Text = sQty;
        }

        private void but0_Click(object sender, EventArgs e)
        {
            sQty = sQty + but0.Text;
            txtContent.Text = sQty;
        }

        private void butcom_Click(object sender, EventArgs e)
        {
            sQty = sQty + butcom.Text;
            txtContent.Text = sQty;
        }

        private void butspace_Click(object sender, EventArgs e)
        {
            sQty = sQty + butspace.Text;
            txtContent.Text = sQty;
        }

        private void butback_Click(object sender, EventArgs e)
        {
            if (sQty.Length == 0)
                return;
            else
            {
                sQty = sQty.Substring(0, sQty.Length - 1);
            }
            
            txtContent.Text = sQty;
        }

        private void butdelete_Click(object sender, EventArgs e)
        {
            sQty = string.Empty;
            txtContent.Text = sQty;
        }

        private void butok_Click(object sender, EventArgs e)
        {
            resultString = txtContent.Text.Trim();
            resultDouble = resultString == "" ? 0 : Convert.ToDouble(resultString.Replace(",", ""));

            this.DialogResult = System.Windows.Forms.DialogResult.OK;
        }

        private void butcancle_Click(object sender, EventArgs e)
        {
            this.DialogResult = System.Windows.Forms.DialogResult.Cancel;
        }
    }
}
