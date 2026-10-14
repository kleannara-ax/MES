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

    public partial class PopItem : Form
    {
        public string resultString;
        public string[] resultArray;
        public string sOrder = string.Empty;

        public PopItem(string sOrderID)
        {
            InitializeComponent();

            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.Fixed3D;

            sOrder = sOrderID;
        }
        

        private void SetGrid()
        {
            mesGrid.FontSize = 16;
            mesGrid.SelectProcedureName = "POP_Item_S";
            mesGrid.CountRows = 9;
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
                //string lblName = labTitle.Text.Trim();

                mesGrid.SetStoreProc();

                mesGrid.ParameterList.Add(new SqlParameter("@OrderID", SqlDbType.VarChar));
                mesGrid.ParameterList["@OrderID"].Value = sOrder;

                mesGrid.DoFind();

                mesGrid.DisplayLayout.Bands[0].Override.WrapHeaderText = Infragistics.Win.DefaultableBoolean.False;
                mesGrid.DisplayLayout.Bands[0].ColHeaderLines = 2;
            }
            catch (Exception ex)
            {
                LogFile.WriteLog("PopItem.DoFind Error => " + ex.Message);
            }
        }

        private void mesGrid1_Load(object sender, EventArgs e)
        {
            SetGrid();
            DoFind();
        }
    }
}
