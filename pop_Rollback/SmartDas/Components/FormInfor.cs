using System;
using System.Collections;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.Common;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.Drawing;
using SAMMI;

namespace SmartDas.Components
{
    public class FormInfor
    {
        #region FUNCTION 정의
        public Hashtable FormFunction = new Hashtable();
        public int _nTopicID = 0;
        #endregion
        //private string getFormInforText = "USP_ZGETPROGRAMINFOR_S";
        public string SystemID = string.Empty;
        public string ProgramID = string.Empty;
        public string ProgramName = string.Empty;
        public string Lang = string.Empty;
        public string PopupColor = string.Empty;
        bool binit = false;

        public FormInfor(string formid, string formname, string lang)
        {
            DBHelper helper = new DBHelper(true);
            this.ProgramID = formid;
            this.Lang = lang;

        }

        public string GetMessage(string msgcode)
        {
            DBHelper helper = new DBHelper();
            string message = string.Empty;

            message = Convert.ToString(helper.ExecuteScalar("USP_ZGETMESSAGEDESC_SN", CommandType.StoredProcedure
                                                           , helper.CreateParameter("MESSAGEID", msgcode, DbType.String, ParameterDirection.Input)
                                                           ));

            return message == "" ? string.Format(Common.getLangText("{0}를 등록하세요."), msgcode) : message;
        }

        public string GetProgramName(string formid, string lang)
        {
            SAMMI.DBHelper helper = new SAMMI.DBHelper(false);

            if (helper.ConType == "OracleConnection")
            {
                this.ProgramName = Convert.ToString(helper.ExecuteScalar("SELECT UFN_ZS0010('" + formid + "','" + lang + "') FROM DUAL", CommandType.Text
                                                    , helper.CreateParameter("Editor", "", DbType.String, ParameterDirection.Input)));
            }
            else
            {
                this.ProgramName = Convert.ToString(helper.ExecuteScalar("SELECT dbo.UFN_ZS0010('" + formid + "','" + lang + "')", CommandType.Text
                                                    , helper.CreateParameter("Editor", "", DbType.String, ParameterDirection.Input)));
            }
            return ProgramName;
        }

        public void ManageForm(System.Windows.Forms.Form form)
        {
            SetControl(form, SAMMI.Common.Lang);
            binit = true;
        }

        int textpos = -1;
        public void SetControl(Form form, string lang)
        {
            textpos = -1;
            SetControlText(form);

            return;

        }
        ArrayList arrText = new ArrayList();
        private System.Windows.Forms.Control SetControlText(System.Windows.Forms.Control control)
        {
            // 없을 경우 자식을 변경 한다.
            foreach (System.Windows.Forms.Control chcontrol in control.Controls)
            {
                try
                {
                    switch (chcontrol.GetType().Name)
                    {
                        case "SLabel":
                        case "UltraLabel":
                        case "UltraButton":
                        case "UltraGroupBox":
                        case "UltraCheckEditor":
                        case "RadioButton":
                        case "ToolStripButton":
                        case "ToolStripLabel":
                        case "SBtnTextEditor":
                            try
                            {
                                string ctext = chcontrol.Text;
                                if (binit == false)
                                    arrText.Add(chcontrol.Text);
                                ++textpos;
                                chcontrol.Text = SAMMI.Common.getLangText(arrText[textpos].ToString());
                                if (SAMMI.Common.FontName != "")
                                    chcontrol.Font = new Font(SAMMI.Common.FontName, chcontrol.Font.Size, chcontrol.Font.Style);

                            }
                            catch { }

                            break;
                        case "UltraTabPageControl":
                            if (binit == false)
                                arrText.Add(((Infragistics.Win.UltraWinTabControl.UltraTabPageControl)chcontrol).Tab.Text);
                            ++textpos;
                            ((Infragistics.Win.UltraWinTabControl.UltraTabPageControl)chcontrol).Tab.Text = SAMMI.Common.getLangText(arrText[textpos].ToString());
                            if (SAMMI.Common.FontName != "")
                                ((Infragistics.Win.UltraWinTabControl.UltraTabPageControl)chcontrol).Tab.Appearance.FontData.Name = SAMMI.Common.FontName;


                            break;
                        case "ToolStrip":
                            for (int i = 0; i < ((System.Windows.Forms.ToolStrip)chcontrol).Items.Count; i++)
                            {
                                if (binit == false)
                                    arrText.Add(((System.Windows.Forms.ToolStrip)chcontrol).Items[i].Text);
                                ++textpos;
                                ((System.Windows.Forms.ToolStrip)chcontrol).Items[i].Text = SAMMI.Common.getLangText(arrText[textpos].ToString());
                                ((System.Windows.Forms.ToolStrip)chcontrol).Items[i].Font = new Font(SAMMI.Common.FontName, ((System.Windows.Forms.ToolStrip)chcontrol).Items[i].Font.Size, ((System.Windows.Forms.ToolStrip)chcontrol).Items[i].Font.Style);
                            }
                            break;
                        case "UltraTree":
                        case "MenuStrip":
                        case "BaseMDIChildForm":
                        case "MdiClient":
                        case "UltraPanel":
                        case "ComboBox":
                        case "UltraPanelClientAreaUnsafe":
                        case "UnpinnedTabArea":
                        case "Grid":
                        case "Grid1":
                        case "Grid2":
                        case "MESGrid":
                        case "SCodeNMComboBox":
                        case "UltraComboEditor":

                            if (SAMMI.Common.FontName != "")
                                chcontrol.Font = new Font(SAMMI.Common.FontName, chcontrol.Font.Size, chcontrol.Font.Style);

                            break;

                        default:

                            break;
                    }
                }
                catch (Exception ex) 
                {
                    Console.WriteLine(ex.Message);
                }

                if (chcontrol.Parent.GetType().Name != "MdiClient")
                {
                    SetControlText(chcontrol);
                }
            }
            return null;
        }
    }
}
