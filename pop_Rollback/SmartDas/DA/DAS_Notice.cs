using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using SmartDas.Components;
using System.Data.SqlClient;

namespace SmartDas.DA
{
    public partial class DAS_Notice : Form
    {
        #region Constructor
        public DAS_Notice()
        {
            InitializeComponent();

            try
            {
                bBox1.ButtonBoxType = ButtonBox.ButtonBoxTypeEnum.Buttons;
                bBox1.SelectionMode = ButtonBox.SelectionModeEnum.Single;

                bBox1.CountX = 1;
                bBox1.CountY = 1;

                bBox1.SetButtons();

                bBox1[0, 0].Text = "확 인";
                bBox1[0, 0].Tag = "NEXT";
                bBox1[0, 0].MappingButton.FontSize = 20;

                bBox1.RedrawButtons();
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
            }
        }
        #endregion
        
        #region METHOD
        private void SetGrid()
        {
            grid_Notice.HeaderFontSize = 15;
            grid_Notice.FontSize = 15;
            grid_Notice.SelectProcedureName = "USP_DASNOTICE_S1";
            grid_Notice.CountRows = 6;
        }

        private void DoFind_Notice()
        {
            grid_Notice.SetStoreProc();

            grid_Notice.ParameterList.Add(new SqlParameter("@PlantCode", SqlDbType.VarChar));
            grid_Notice.ParameterList.Add(new SqlParameter("@OPCode", SqlDbType.VarChar));
            grid_Notice.ParameterList.Add(new SqlParameter("@Date", SqlDbType.VarChar));

            grid_Notice.ParameterList["@PlantCode"].Value = string.IsNullOrEmpty(Common.PlantCode) ? "" : Common.PlantCode;
            grid_Notice.ParameterList["@OPCode"].Value = string.IsNullOrEmpty(Common.OpCode) ? "" : Common.OpCode;
            grid_Notice.ParameterList["@Date"].Value = Convert.ToString(cboDate.Text);

            grid_Notice.DoFind();
        }
        #endregion

        private void DAS_Notice_Load(object sender, EventArgs e)
        {
            cboDate.Value = DateTime.Now;
            cboDate.Enabled = false;
            txtOPName.Text = Common.OpName;

            SetGrid();
            DoFind_Notice();
        }

        private void bBox1_buttonClickEvent(MESButton sender, ButtonBox.ButtonClickEventArg e)
        {
            this.Close();
        }

        #region EventHandler

        #endregion
    }
}
