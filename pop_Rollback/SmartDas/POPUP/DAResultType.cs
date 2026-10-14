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
    public partial class DAResultType : Form
    {
        public string resultString;

        public DAResultType()
        {
            InitializeComponent();
        }

        private void DAResultType_Load(object sender, EventArgs e)
        {
            SetButtons();
        }

        private void SetButtons()
        {
            try
            {
                bBox1.ButtonBoxType = ButtonBox.ButtonBoxTypeEnum.Selection;
                bBox1.SelectionMode = ButtonBox.SelectionModeEnum.Single;

                bBox1.CountX = 3;
                bBox1.CountY = 1;

                bList_btnUp.LinkMoveSize = bBox1.CountY + 1;
                bList_btnDown.LinkMoveSize = bBox1.CountY + 1;

                bBox1.FontSize = 25;

                bBox1.SelectProcedureName = "USP_DA0000_ResultType_R";
                bBox1.SetStoreProc();

                bBox1.DoFind();

                bBox1.RedrawButtons();
            }
            catch (Exception ex)
            {
                LogFile.WriteLog("DAResultType.SetButtons Error => " + ex.Message);
            }
        }

        private void but_Click(object sender, EventArgs e)
        {
            Button btn = (Button)sender;

            string s = btn.Text.ToUpper();

            if (s.Equals("확인"))
            {
                resultString = ((ButtonData)bBox1.GetSelectedButtons()[0]).Tag.ToString();
                this.DialogResult = System.Windows.Forms.DialogResult.OK;
            }
            else
            {
                this.DialogResult = System.Windows.Forms.DialogResult.Cancel;
            }
        }
    }
}
