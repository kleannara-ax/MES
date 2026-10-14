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
    public partial class DAResultDate : Form
    {
        private string resultString = "";

        private const int sInMaxLen = 4;
        //private string sInData = "";

        public string ResultString
        {
            get
            {
                return resultString;
            }
        }

        public DAResultDate()
        {
            InitializeComponent();

            //this.TopMost = true;
        }


        public DAResultDate(DateTime dt)
        {
            InitializeComponent();

            mesMonthCalendar.SelectionStart = dt;
            mesMonthCalendar.SelectionEnd = dt;
            mesMonthCalendar.Focus();

            //this.TopMost = true;
        }


        public string LabelTitle
        {
            get { return labTitle.Text; }
            set { labTitle.Text = value;}
        }

        public string ContentText
        {
            get { return mesLabelDate.Text; }
            set { mesLabelDate.Text = value; }
        }

        private void DAResultDate_Load(object sender, EventArgs e)
        {
            mesLabelDate.Text = string.Format("{0:yyyy-MM-dd}", mesMonthCalendar.SelectionStart);
        }

        #region  [버튼 이벤트]
        
        private void btnOK_Click(object sender, EventArgs e)
        {
            resultString = mesLabelDate.Text.ToString();
            this.DialogResult = System.Windows.Forms.DialogResult.OK;
        }

        private void btnCancel_Click(object sender, EventArgs e)
        {
            this.DialogResult = System.Windows.Forms.DialogResult.Cancel;
        }
        #endregion

        private void mesMonthCalendar_DateChanged(object sender, DateRangeEventArgs e)
        {
            mesLabelDate.Text = string.Format("{0:yyyy-MM-dd}", e.Start);
        }

        private void butNextMonth_Click(object sender, EventArgs e)
        {
            DateTime DT = mesMonthCalendar.SelectionStart;
            mesMonthCalendar.SelectionStart = DT.AddMonths(1);
            mesMonthCalendar.Focus();
        }

        private void butPreMonth_Click(object sender, EventArgs e)
        {
            DateTime DT = mesMonthCalendar.SelectionStart;
            mesMonthCalendar.SelectionStart = DT.AddMonths(-1);
            mesMonthCalendar.Focus();
        }

        private void mesMonthCalendar_DoubleClickEx(object sender, EventArgs e)
        {
            resultString = mesLabelDate.Text.ToString();
            this.DialogResult = System.Windows.Forms.DialogResult.OK;
        }

        private void mesMonthCalendar_MouseDown(object sender, MouseEventArgs e)
        {
        }
    }
}
