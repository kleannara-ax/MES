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

namespace SmartDas.POPUP
{
    public partial class DA0310_POP : Form
    {
        public string resultString;
        public string[] resultArray;
        private string _sWHCode = "";

        public DA0310_POP()
        {
            InitializeComponent();

            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.Fixed3D;
            this.TopMost = true;
        }

        public string LabelTitle
        {
            get { return labTitle.Text; }
            set { labTitle.Text = value;}
        }

        public string WHCode
        {
            get { return _sWHCode; }
            set { _sWHCode = value; }
        }

        private void DA0310_POP_Load(object sender, EventArgs e)
        {
            SetGrid();

            DoFind();
        }

        private void SetGrid()
        {
            mesGrid1.FontSize = 16;
            mesGrid1.SelectProcedureName = "USP_DA0310_POP_S1";
            mesGrid1.CountRows = 7;
        }

        private void DoFind()
        {
            mesGrid1.SetStoreProc();

            mesGrid1.GridAutoFitStyle = Infragistics.Win.UltraWinGrid.AutoFitStyle.ExtendLastColumn;

            // 조회
            //mesGrid1.ParameterList.Add(new SqlParameter("@WHCode", _sWHCode));

            mesGrid1.DoFind();
        }

        private void btnCancel_Click(object sender, EventArgs e)
        {
            this.DialogResult = System.Windows.Forms.DialogResult.Cancel;
        }

        private void mesGrid1_GridClick(object sender, MESGrid.GridClickEventArg e)
        {
            resultString = clsDB.nvlString(e.row.Cells[0].Value);

            resultArray = new string[] { resultString, clsDB.nvlString(e.row.Cells[1].Value) };
            this.DialogResult = System.Windows.Forms.DialogResult.OK;
        }
    }
}
