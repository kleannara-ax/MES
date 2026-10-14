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

using Infragistics.Win;
using Infragistics.Win.UltraWinGrid;


namespace SmartDas.POPUP
{
    public partial class POPCombo : Form
    {
        //public string resultString;
        public string[] resultArray;
        public MESGrid resultGrid;
        private string SearchItem;
        private string SearchFilter;
        private string Query;


        private string gsWERKS;
        private string gsPROC_CD;

        public POPCombo(string pTitle, string pData, string pQuery)
        {
            InitializeComponent();
            LabelTitle = pTitle;
            //SearchItem = pSearchItem;
            SearchFilter = string.Empty;

            Query = pQuery;
            if (pQuery.Equals("SP_POP00_S02"))            
                SearchItem = pData;
            else if(pQuery.Equals("SP_POP00_S03"))
                gsWERKS = pData;
            else if (pQuery.Equals("SP_POP00_S04"))
                gsPROC_CD = pData;

            this.TopMost = true;
        }

        public POPCombo(string pTitle, string pSearchItem, string pQuery, string pFilter)
        {
            InitializeComponent();
            LabelTitle = pTitle;
            SearchItem = pSearchItem;
            SearchFilter = pFilter;

            Query = pQuery;

            this.TopMost = true;
        }


        public POPCombo(string pTitle, string pQuery)
        {
            InitializeComponent();

            LabelTitle = pTitle;

            Query = pQuery;

            
            this.TopMost = true;
        }

        public string LabelTitle
        {
            get { return labTitle.Text; }
            set { labTitle.Text = value;}
        }

        private void POPCombo_Load(object sender, EventArgs e)
        {
            mesGrid1.HeaderFontSize = 14;
            mesGrid1.FontSize = 14;
            mesGrid1.CountRows = 9;
            mesGrid1.AutoScroll = true;
            mesGrid1.DisplayLayout.Scrollbars = Scrollbars.Vertical;
            btnRightPage.LinkMoveSize = mesGrid1.CountRows;
            btnLeftPage.LinkMoveSize = mesGrid1.CountRows;


            if (Query.Equals("SP_POP00_S02")) 
            {
                DoFind();
            }
            else if (Query.Equals("SP_POP00_S03")) 
            {
                doSetLocation();
            }
            else if (Query.Equals("SP_POP00_S04")) 
            {
                doSetMach();
            }

        }

        private void DoFind()
        {
            POPUP.MessageForm msgForm = null;
            DialogResult dr;

            DBHelper helper = new DBHelper();
            string sColInfo = string.Empty;
            string sColType = string.Empty;

            DataSet dsTemp = new DataSet();
            DataTable dtRtn;
            DataTable dtTemp = new DataTable();
            DataRow rTemp = null;

            try
            {
                //버튼 목록 조회
                dtRtn = helper.FillTable("SP_POP00_S02", CommandType.StoredProcedure
                                                               , helper.CreateParameter("P_CBOTYPE", SearchItem, DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_FILTER", SearchFilter, DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_COLINFO", DbType.String, ParameterDirection.Output, null, 1000)
                                                               , helper.CreateParameter("P_COLTYPE", DbType.String, ParameterDirection.Output, null, 1000));
                if (dtRtn.Rows.Count < 1)
                {
                    msgForm = new POPUP.MessageForm("조회된 항목이 없습니다.", MessageBoxButtons.OK, "알   림");
                    dr = msgForm.ShowDialog(this);
                    return;
                }
                else
                {
                    //컬럼설정 정보
                    sColInfo = helper.Parameters["P_COLINFO"].Value.ToString();
                    sColType = helper.Parameters["P_COLTYPE"].Value.ToString();
                    //컬럼 설정 테이블 생성
                    dtTemp.Columns.Add(new DataColumn("colInfo", typeof(string)));
                    rTemp = dtTemp.NewRow();
                    rTemp["colInfo"] = sColInfo;
                    dtTemp.Rows.Add(rTemp);
                    rTemp = dtTemp.NewRow();
                    rTemp["colInfo"] = sColType;
                    dtTemp.Rows.Add(rTemp);
                    //컬럼설정 및 데이터 목록 작성
                    dsTemp.Tables.Add(dtTemp);
                    dsTemp.Tables.Add(dtRtn);
                    //그리드 출력
                    mesGrid1.DoFind_Oracle(dsTemp);
                }

            }
            catch (Exception ex)
            {
                msgForm = new POPUP.MessageForm("SetGrid Error!", MessageBoxButtons.OK, "알   림");
                dr = msgForm.ShowDialog(this);
                LogFile.WriteLog("POPCombo.SetGrid Error => " + ex.Message);
            }
        }


        // 로케이션명
        private void doSetLocation()
        {
            DBHelper helper = new DBHelper();
            string sColInfo = string.Empty;
            string sColType = string.Empty;

            DataSet dsTemp = new DataSet();
            DataTable dtRtn;
            DataTable dtTemp = new DataTable();
            DataRow rTemp = null;

            try
            {
                //버튼 목록 조회
                dtRtn = helper.FillTable("SP_POP00_S03", CommandType.StoredProcedure
                                                               , helper.CreateParameter("P_WERKS", gsWERKS, DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_STOR_LOC_CD", "2700", DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_COLINFO", DbType.String, ParameterDirection.Output, null, 1000)
                                                               , helper.CreateParameter("P_COLTYPE", DbType.String, ParameterDirection.Output, null, 1000));
                if (dtRtn.Rows.Count < 1)
                {
                    new POPUP.MessageForm("조회된 항목이 없습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return;
                }
                else
                {
                    //컬럼설정 정보
                    sColInfo = helper.Parameters["P_COLINFO"].Value.ToString();
                    sColType = helper.Parameters["P_COLTYPE"].Value.ToString();
                    //컬럼 설정 테이블 생성
                    dtTemp.Columns.Add(new DataColumn("colInfo", typeof(string)));
                    rTemp = dtTemp.NewRow();
                    rTemp["colInfo"] = sColInfo;
                    dtTemp.Rows.Add(rTemp);
                    rTemp = dtTemp.NewRow();
                    rTemp["colInfo"] = sColType;
                    dtTemp.Rows.Add(rTemp);
                    //컬럼설정 및 데이터 목록 작성
                    dsTemp.Tables.Add(dtTemp);
                    dsTemp.Tables.Add(dtRtn);

                    mesGrid1.DoFind_Oracle(dsTemp);
                }

            }
            catch (Exception ex)
            {
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                LogFile.WriteLog("SP_POP00_S03.SetGrid Error => " + ex.Message);
            }

        }


        // 설비명
        public void doSetMach()
        {
            DBHelper helper = new DBHelper();
            string sColInfo = string.Empty;
            string sColType = string.Empty;

            DataSet dsTemp = new DataSet();
            DataTable dtRtn;
            DataTable dtTemp = new DataTable();
            DataRow rTemp = null;

            try
            {
                dtRtn = helper.FillTable("SP_POP00_S04", CommandType.StoredProcedure
                                                               , helper.CreateParameter("P_PROC_CD", gsPROC_CD, DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_COLINFO", DbType.String, ParameterDirection.Output, null, 1000)
                                                               , helper.CreateParameter("P_COLTYPE", DbType.String, ParameterDirection.Output, null, 1000));
                if (dtRtn.Rows.Count < 1)
                {
                    new POPUP.MessageForm("조회된 항목이 없습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return;
                }
                else
                {
                    //컬럼설정 정보
                    sColInfo = helper.Parameters["P_COLINFO"].Value.ToString();
                    sColType = helper.Parameters["P_COLTYPE"].Value.ToString();
                    //컬럼 설정 테이블 생성
                    dtTemp.Columns.Add(new DataColumn("colInfo", typeof(string)));
                    rTemp = dtTemp.NewRow();
                    rTemp["colInfo"] = sColInfo;
                    dtTemp.Rows.Add(rTemp);
                    rTemp = dtTemp.NewRow();
                    rTemp["colInfo"] = sColType;
                    dtTemp.Rows.Add(rTemp);
                    //컬럼설정 및 데이터 목록 작성
                    dsTemp.Tables.Add(dtTemp);
                    dsTemp.Tables.Add(dtRtn);

                    mesGrid1.DoFind_Oracle(dsTemp);
                }

            }
            catch (Exception ex)
            {
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                LogFile.WriteLog("SP_POP00_S04.SetGrid Error => " + ex.Message);
            }
        }


        private void btnCancel_Click(object sender, EventArgs e)
        {
            this.DialogResult = System.Windows.Forms.DialogResult.Cancel;
        }

        private void mesGrid1_GridClick(object sender, MESGrid.GridClickEventArg e)
        {
            string resCode = clsDB.nvlString(e.row.Cells[0].Value);
            string resName = clsDB.nvlString(e.row.Cells[1].Value);
            string resDisplay = clsDB.nvlString(e.row.Cells["Display"].Value);
            resultArray = new string[] { resCode, resName, resDisplay };
            resultGrid = mesGrid1;
            
            this.DialogResult = System.Windows.Forms.DialogResult.OK;
        }
    }
}
