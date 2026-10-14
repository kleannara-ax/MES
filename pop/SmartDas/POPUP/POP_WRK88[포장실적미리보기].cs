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
using Infragistics.Win.UltraWinGrid;

namespace SmartDas.POPUP
{
    public partial class POP_WRK88 : Form
    {
        DataTable dtRtn;
     
        //public POP_WRK88()
        //{
        //    InitializeComponent();
        //}


        public DataTable resultDT;

        //20230123 wsw
        public DataTable dtCheck;

        public POP_WRK88(DataTable dt, string sIN_PER_CNT)
        {
            InitializeComponent();

            dtRtn = dt;

            lblIN_PER_CNT.Text = sIN_PER_CNT;
        }

        public string LabelTitle
        {
            get { return labTitle.Text; }
            set { labTitle.Text = value; }
        }
        private void POP_WRK88_Load(object sender, EventArgs e)
        {
            //20230123 wsw
            dtCheck = new DataTable();
            dtCheck.Columns.Add("MATNR", typeof(string));
            dtCheck.Columns.Add("IND_BCD", typeof(string));
            

            DataTable sdt1 = new DataTable();

            sdt1.Columns.Add("NO", typeof(string));
            sdt1.Columns.Add("TOT_REAM", typeof(string));
            sdt1.Columns.Add("CT_LOT_ID1", typeof(string));
            sdt1.Columns.Add("REAM1", typeof(string));
            sdt1.Columns.Add("CT_LOT_ID2", typeof(string));
            sdt1.Columns.Add("REAM2", typeof(string));
            sdt1.Columns.Add("CT_LOT_ID3", typeof(string));
            sdt1.Columns.Add("REAM3", typeof(string));
            sdt1.Columns.Add("CT_LOT_ID4", typeof(string));
            sdt1.Columns.Add("REAM4", typeof(string));
            sdt1.Columns.Add("CT_LOT_ID5", typeof(string));
            sdt1.Columns.Add("REAM5", typeof(string));

            DataRow dr;
            string oPalletno = string.Empty;

            //dr = sdt1.NewRow();
            //dr["PLT_NO"] = iPalletno.ToString();
            //dr["IND_BCD_M"] = Grid1.Rows[i].Cells["IND_BCD"].Value.ToString();
            //dr["LOT_NO_M"] = Grid1.Rows[i].Cells["LOT_NO"].Value.ToString();
            //dr["ABLE_QTY_M"] = Grid1.Rows[i].Cells["ABLE_QTY"].Value.ToString();
            //dr["USE_REAM_M"] = dProdRe.ToString();
            //sdt1.Rows.Add(dr);

            const int MAX_LOT = 5;
            string[] sLOTID = new string[MAX_LOT];
            double[] dREAM = new double[MAX_LOT];
            double dTOT_REAM = 0;
            int nLotCnt = 0;
            for (int i = 0; i<dtRtn.Rows.Count; i++)
            {
                //20230123 wsw
                dr = dtCheck.NewRow();
                dr["MATNR"] = dtRtn.Rows[i]["MATNR_M"].ToString();
                dr["IND_BCD"] = dtRtn.Rows[i]["IND_BCD_M"].ToString();

                //20230125 wsw 
                //dtCheck.Rows.Add(dr);
                bool bExist = false;
                for( int k = 0; k < dtCheck.Rows.Count; k++ )
                {
                    if(dtCheck.Rows[k]["IND_BCD"].ToString() == dtRtn.Rows[i]["IND_BCD_M"].ToString())
                    {
                        bExist = true;
                    }
                }
                if( !bExist)
                {
                    dtCheck.Rows.Add(dr);
                }
                ////////////////////////////////////////////////////////////////////

                string sSrcPalletno = dtRtn.Rows[i]["PLT_NO"].ToString();
                string sSrcLOTID = dtRtn.Rows[i]["LOT_NO_M"].ToString();
                double dSrcREAM = 0;
                double.TryParse(dtRtn.Rows[i]["USE_REAM_M"].ToString().Replace(",", ""), out dSrcREAM);   // 연수

                if (sSrcPalletno == oPalletno)
                {
                    if (sSrcLOTID == sLOTID[nLotCnt])
                    {
                    }
                    else
                    {
                        nLotCnt++;
                    }
                }
                else
                {
                    if (i != 0)
                    {
                        dr = sdt1.NewRow();
                        dr["NO"] = oPalletno;
                        dr["TOT_REAM"] = string.Format("{0:#,##0.000}", dTOT_REAM);
                        dr["CT_LOT_ID1"] = sLOTID[0];
                        dr["REAM1"] = dREAM[0] > 0 ? string.Format("{0:#,##0.000}", dREAM[0]) : "";
                        dr["CT_LOT_ID2"] = sLOTID[1];
                        dr["REAM2"] = dREAM[1] > 0 ? string.Format("{0:#,##0.000}", dREAM[1]) : "";
                        dr["CT_LOT_ID3"] = sLOTID[2];
                        dr["REAM3"] = dREAM[2] > 0 ? string.Format("{0:#,##0.000}", dREAM[2]) : ""; 
                        dr["CT_LOT_ID4"] = sLOTID[3];
                        dr["REAM4"] = dREAM[3] > 0 ? string.Format("{0:#,##0.000}", dREAM[3]) : ""; 
                        dr["CT_LOT_ID5"] = sLOTID[4];
                        dr["REAM5"] = dREAM[4] > 0 ? string.Format("{0:#,##0.000}", dREAM[4]) : ""; 
                        sdt1.Rows.Add(dr);
                    }

                    for (int x = 0; x < MAX_LOT; x++)
                    {
                        sLOTID[x] = "";
                        dREAM[x] = 0;
                    }

                    nLotCnt = 0;
                    dTOT_REAM = 0;
                }

                oPalletno = sSrcPalletno;

                sLOTID[nLotCnt] = sSrcLOTID;
                dREAM[nLotCnt] += dSrcREAM;
                dTOT_REAM += dSrcREAM;
            }

            dr = sdt1.NewRow();
            dr["NO"] = oPalletno;
            dr["TOT_REAM"] = string.Format("{0:#,##0.000}", dTOT_REAM);
            dr["CT_LOT_ID1"] = sLOTID[0];
            dr["REAM1"] = dREAM[0] > 0 ? string.Format("{0:#,##0.000}", dREAM[0]) : "";
            dr["CT_LOT_ID2"] = sLOTID[1];
            dr["REAM2"] = dREAM[1] > 0 ? string.Format("{0:#,##0.000}", dREAM[1]) : "";
            dr["CT_LOT_ID3"] = sLOTID[2];
            dr["REAM3"] = dREAM[2] > 0 ? string.Format("{0:#,##0.000}", dREAM[2]) : "";
            dr["CT_LOT_ID4"] = sLOTID[3];
            dr["REAM4"] = dREAM[3] > 0 ? string.Format("{0:#,##0.000}", dREAM[3]) : "";
            dr["CT_LOT_ID5"] = sLOTID[4];
            dr["REAM5"] = dREAM[4] > 0 ? string.Format("{0:#,##0.000}", dREAM[4]) : "";
            sdt1.Rows.Add(dr);

            SetGrid(sdt1);

            resultDT = sdt1;
        }

        private void SetGrid(DataTable sdt)
        {
            string sColInfo = string.Empty;
            string sColType = string.Empty;

            DataSet dsTemp = new DataSet();
            DataTable dtTemp = new DataTable();
            DataRow rTemp = null;
            //DataTable dtRtn = new DataTable();

            try
            {
                Grid1.HeaderFontSize = 12;
                Grid1.FontSize = 12;
                Grid1.CountRows = 10;
                Grid1.AutoScroll = true;
                Grid1.DisplayLayout.Scrollbars = Scrollbars.Vertical;
                btnRightPage.LinkMoveSize = Grid1.CountRows;
                btnLeftPage.LinkMoveSize = Grid1.CountRows;

                //P_COLINFO := 'NO@C^100|자재코드@C^200|자내 내역@L^600';
                //P_COLTYPE := 'NO@varchar|MATNR@varchar|MATNR_NM@varchar';
                //컬럼설정 정보
                sColInfo = "팔레트순번@C^90|총연수@R^90|CT_LOT_ID1@C^110|연수1@R^90|CT_LOT_ID2@C^110|연수2@R^90|CT_LOT_ID3@C^110|연수3@R^90|CT_LOT_ID4@C^110|연수4@R^90|CT_LOT_ID5@C^110|연수5@R^90";
                sColType = "NO@varchar|TOT_REAM@varchar|CT_LOT_ID1@varchar|REAM1@varchar|CT_LOT_ID2@varchar|REAM2@varchar|CT_LOT_ID3@varchar|REAM3@varchar|CT_LOT_ID4@varchar|REAM4@varchar|CT_LOT_ID5@varchar|REAM5@varchar";
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
                dsTemp.Tables.Add(sdt);
                //그리드 출력
                Grid1.DoFind_Oracle(dsTemp);
            }
            catch (Exception ex)
            {
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                LogFile.WriteLog("POP_WRK08.SetGrid Error => " + ex.Message);
            }

        }
        private void btnConfirm_Click(object sender, EventArgs e)
        {
            this.DialogResult = System.Windows.Forms.DialogResult.OK;
        }

        private void btnCancel_Click(object sender, EventArgs e)
        {
            this.DialogResult = System.Windows.Forms.DialogResult.Cancel;
        }
    }
}
