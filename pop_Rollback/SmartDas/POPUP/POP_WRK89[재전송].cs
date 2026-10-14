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
using System.Threading;
using Oracle.ManagedDataAccess.Client;
using Infragistics.Win.UltraWinGrid;

namespace SmartDas.POPUP
{
    public partial class POP_WRK89 : Form
    {
        private string sPlantCode = string.Empty;
        private string sMachCode = string.Empty;

        // 플랜트코드, 작업지시번호, 작업지시순번, 업체/개별바코드, OperationType
        public POP_WRK89(string PlantCode, string MachCode)
        {
            InitializeComponent();

            sPlantCode = PlantCode;
            sMachCode = MachCode;

            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.Fixed3D;
        }

        public string LabelTitle
        {
            get { return labTitle.Text; }
            set { labTitle.Text = value; }
        }

        private void POP_WRK89_Load(object sender, EventArgs e)
        {
            SetGrid();
        }

        #region < METHOD AREA >

        private void SetGrid()
        {
            DBHelper helper = new DBHelper();
            DataSet dsTemp = new DataSet();

            try
            {

                Grid1.HeaderFontSize = 13;
                Grid1.FontSize = 13;
                Grid1.CountRows = 10;
                Grid1.AutoScroll = true;
                Grid1.DisplayLayout.Scrollbars = Scrollbars.Both;

                dsTemp = helper.FillDataSetN("SP_POP_WRK89_S01", CommandType.StoredProcedure, 2
                                                               , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input)
                                                               );
                //그리드 출력
                Grid1.DoFind_Oracle(dsTemp);
            }
            catch (Exception ex)
            {
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                LogFile.WriteLog("POP_WRK89.SetGrid Error => " + ex.Message);
            }
        }

        private bool doRFCSend(int SelRow)
        {
            bool bRtn = true;
            DBHelper helper = new DBHelper(false, "", true);
            DataSet dsTemp; //실적등록 결과 수신(0:라벨정보, 1:RFC 변수, 2:RFC 상세변수)

            string sIndBcd = Grid1.Rows[SelRow].Cells["IND_BCD"].Value.ToString();
            string sDocDiv = Grid1.Rows[SelRow].Cells["DOC_DIV"].Value.ToString();
            string sSAP_FUNC = string.Empty;
            DataTable dtTemp;
            DataSet dsPRFM = new DataSet(); //양품 등록 RFC Data

            try
            {
                this.Cursor = Cursors.WaitCursor;   //Waitting

                dsTemp = helper.FillDataSetN("SP_IF_PUT_IFRESEND", CommandType.StoredProcedure, 2
                                                              , helper.CreateParameter("P_DOC_DIV", sDocDiv, DbType.String, ParameterDirection.Input)
                                                              , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)
                                                              , helper.CreateParameter("P_IND_BCD", sIndBcd, DbType.String, ParameterDirection.Input)
                                                              , helper.CreateParameter("P_SAP_FUNC", DbType.String, ParameterDirection.Output, null, 30)
                                                              , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input)
                               );

                if (helper.RSCODE == "E")
                {
                    this.Cursor = Cursors.Default;   //Waitting
                    new POPUP.MessageForm(helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    helper.Rollback();
                    bRtn = false;
                }
                else
                {
                    sSAP_FUNC = helper.Parameters["P_SAP_FUNC"].Value.ToString();

                    //양품실적 Data
                    dtTemp = dsTemp.Tables[0].Copy();
                    dsPRFM.Tables.Add(dtTemp);
                    dtTemp = dsTemp.Tables[1].Copy();
                    dsPRFM.Tables.Add(dtTemp);

                    //SAP 실적 등록
                    SAPHelper sapRFC = new SAPHelper();
                    if (sapRFC.CallSAPFunc(sSAP_FUNC, dsPRFM.Tables[0], dsPRFM.Tables[1], helper).Equals("S"))
                    {
                        sapRFC.SaveResulttoWrk(helper, "POP_WRK089", "0");
                    }
                    else
                    {
                        this.Cursor = Cursors.Default;   //Waitting
                        new POPUP.MessageForm("SAP 재전송이 실패하였습니다.\nWEB에서 생산현황조회후 재발송을 진행하여 주시기 바랍니다." + sapRFC.rtnMSG, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                        bRtn = false;
                    }
                }
            }
            catch (Exception ex)
            {
                this.Cursor = Cursors.Default;   //Waitting
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                LogFile.WriteLog("POP_WRK89.doReSend Error => " + ex.Message);
                helper.Rollback();
                bRtn = false;
            }
            finally
            {
                this.Cursor = Cursors.Default;   //Waitting
                helper.Close();
                SetGrid();
            }

            return bRtn;
        }

        #endregion

        #region < EVENT AREA >

        private void btnConfirm_Click(object sender, EventArgs e)
        {
            if (Grid1.Rows.Count > 0)
            {
                for (int i = 0; i < Grid1.Rows.Count; i++)
                {
                    if (!doRFCSend(i))
                        break;
                }
            }
            //재전송 완료후 재조회
            SetGrid();
        }

        private void btnClose_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        #endregion
    }
}
