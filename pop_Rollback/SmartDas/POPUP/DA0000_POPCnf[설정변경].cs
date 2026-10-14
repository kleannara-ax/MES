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

namespace SmartDas.POPUP
{
    public partial class DA0000_POPCnf : Form
    {
        Configuration appConfig = ConfigurationManager.OpenExeConfiguration(ConfigurationUserLevel.None);
        private string sDpi = "300";

        public DA0000_POPCnf()
        {
            InitializeComponent();

            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.Fixed3D;

            //프린터 DPI
            sDpi = appConfig.AppSettings.Settings["PRINTERDPI"].Value.ToString();
            lblLabelDpi.Text = sDpi;
        }

        public string LabelTitle
        {
            get { return labTitle.Text; }
            set { labTitle.Text = value; }
        }

        private void btnInput_Click(object sender, EventArgs e)
        {
            appConfig.AppSettings.Settings["PRINTERDPI"].Value = lblLabelDpi.Text;
            appConfig.Save(ConfigurationSaveMode.Modified);
            ConfigurationManager.RefreshSection("appSettings");

            this.Close();
        }

        private void btnCancel_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        private void lblLabelDpi_Click(object sender, EventArgs e)
        {
            POPUP.MessageForm msgForm = null;
            DialogResult dr;
            DAResultQty pop = new DAResultQty();
            pop.ShowDialog(this);
            if (pop.DialogResult == DialogResult.OK)
            {
                if (!(pop.ResultDouble / 1.00 == (int)pop.ResultDouble))
                {
                    msgForm = new POPUP.MessageForm("정수만 입력 가능합니다.", MessageBoxButtons.OK, "알   림");
                    dr = msgForm.ShowDialog(this);
                    return;
                }
                lblLabelDpi.Text = pop.ResultDouble.ToString();
            }
        }
    }
}
