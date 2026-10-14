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

    public partial class PopOrder : Form
    {
        public string resultString;
        public string[] resultArray;

        public PopOrder()
        {
            InitializeComponent();

            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.Fixed3D;
        }

        public string LabelTitle
        {
            get { return labTitle.Text; }
            set { labTitle.Text = value;}
        }

        private void SetGrid()
        {
            mesGrid.FontSize = 18;
            mesGrid.SelectProcedureName = "POP_Order_S";
            mesGrid.CountRows = 5;
        }

        private void btnCancel_Click(object sender, EventArgs e)
        {
            this.DialogResult = System.Windows.Forms.DialogResult.Cancel;
            resultArray = new string[] { };
        }

        private void mesGrid1_GridClick(object sender, MESGrid.GridClickEventArg e)
        {
            resultArray = new string[5];

            if (mesGrid.Rows.Count > 0)
            {
                for (int i = 0; i < mesGrid.Columns.Count; i++)
                {
                    resultArray[i] = e.row.Cells[i].Value.ToString();
                }

                this.DialogResult = System.Windows.Forms.DialogResult.OK;
            }

            /*
            resultArray = new string[] { resultString, clsDB.nvlString(e.row.Cells[1].Value) };
            this.DialogResult = System.Windows.Forms.DialogResult.OK;
            */
        }

        private void DoFind()
        {
            try
            {
                mesGrid.SetStoreProc();

                mesGrid.DoFind();

                mesGrid.DisplayLayout.Bands[0].Override.WrapHeaderText = Infragistics.Win.DefaultableBoolean.False;
                mesGrid.DisplayLayout.Bands[0].ColHeaderLines = 2;
            }
            catch (Exception ex)
            {
                LogFile.WriteLog("DA9800.DoFind Error => " + ex.Message);
            }
        }

        private void mesGrid1_Load(object sender, EventArgs e)
        {
            SetGrid();
            DoFind();
        }
    }
}
