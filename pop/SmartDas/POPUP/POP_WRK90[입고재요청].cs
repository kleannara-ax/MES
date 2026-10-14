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
    public partial class POP_WRK90 : Form
    {
        private string sPlantCode = string.Empty;
        private string sMachCode = string.Empty;
        private DateTime sFindDate = DateTime.Now;

        // 플랜트코드, 작업지시번호, 작업지시순번, 업체/개별바코드, OperationType
        public POP_WRK90(string PlantCode, string MachCode, DateTime FindDate)
        {
            InitializeComponent();

            sPlantCode = PlantCode;
            sMachCode = MachCode;
            sFindDate = FindDate;

            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.Fixed3D;
        }

        public string LabelTitle
        {
            get { return labTitle.Text; }
            set { labTitle.Text = value; }
        }

        private void POP_WRK90_Load(object sender, EventArgs e)
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

                dsTemp = helper.FillDataSetN("SP_POP_WRK90_S01", CommandType.StoredProcedure, 2
                                                               , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_WRKDATE", sFindDate.ToString("yyyyMMdd"), DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input)
                                                               );
                //그리드 출력
                Grid1.DoFind_Oracle(dsTemp);
            }
            catch (Exception ex)
            {
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                LogFile.WriteLog("POP_WRK90.SetGrid Error => " + ex.Message);
            }
        }

        private bool doSend(int SelRow)
        {
            bool bRtn = true;
            DBHelper helper = new DBHelper(false, "", true);
            string sSQL = "";

            string sIndBcd = Grid1.Rows[SelRow].Cells["IND_BCD"].Value.ToString();
            string sDocNo = string.Empty;
            string sRtnCode = string.Empty;
            string sSAP_FUNC = string.Empty;
            DataTable dtTemp;


            try
            {
                //전송문서번호 지정
                sDocNo = Grid1.Rows[SelRow].Cells["DOC_NO"].Value.ToString();
                //조회명령서 작성
                sSQL += "SELECT FN_IF_QUERY('MES_IF_402', '" + sDocNo + "') FROM DUAL";
                dtTemp = helper.FillTable(sSQL, CommandType.Text);

                //restful 전송
                string pURL = Common.WMS_IF_URL.Replace("IFID", "WMS_IF_205");
                string sJsonData = Common.toJsonFormat_List("list", dtTemp);

                string rtnData = string.Empty;

                // ---------------------------------------------------------- 
                // POP_WRK90[입고재요청].cs 사용 안함.
                // ----------------------------------------------------------
                // POP_WRK89[재전송].cs 에서 입고재요청 처리
                try
                {
                    rtnData = Common.GetRestToString(pURL, sJsonData, "POST");
                }
                catch (Exception EX_WMS)
                {
                    LogFile.WriteLog("POP_WRK90.doSend::GetRestToString Error\r\n" + EX_WMS.Message);
                    // Exception 내용 결과 저장 시 내용에서 ":", "'" 문자 제거
                    rtnData = "{\"result\":\"" + EX_WMS.Message.Replace(":", "").Replace("'", "") + "\",\"IFID\":\"WMS_IF_205\"}";
                }

                sRtnCode = rtnData.Contains("SUCCESS") ? "S" : "E";

                //결과저장
                Common.GetRestSaveResult("MES_IF_402", sJsonData, sDocNo, "1", sRtnCode, rtnData).Equals("S");

                if (rtnData.Contains("result"))
                {
                    if (!sRtnCode.Equals("S"))
                    {
                        this.Cursor = Cursors.Default;   //Waitting
                        new POPUP.MessageForm("완제품 입고요청이 중단되었습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    }
                }

            }
            catch (Exception ex)
            {
                this.Cursor = Cursors.Default;   //Waitting
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                LogFile.WriteLog("POP_WRK90.doReSend Error => " + ex.Message);
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
                    if (!doSend(i))
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
