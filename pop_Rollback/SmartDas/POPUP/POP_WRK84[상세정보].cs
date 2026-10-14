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

namespace SmartDas.POPUP
{
    public partial class POP_WRK84 : Form
    {
        private string strPlantCode = "";
        private string strOpCode = "";
        private string strProcdureName = "";
        //private string strMachineCode = "";
        private string strWrkOrdrNo = "";
        private string strWrkOrdrSeqNo = "";
        private string strIND_BCD = "";

        public static string PROC_INP = "PROC_INP";        // 작업지시선택 투입정보
        public static string PROC_WRK = "PROC_WRK";        // 주작업 표시 정보
        public static string PROC_PRFM = "PROC_PRFM";      // 실적현황 표시 정보
        public static string PROC_INP_PRFM = "PROC_INP_PRFM";  // 투입된 반제품 실적현황 표시 정보 (공정투입에서 선택)

        public POP_WRK84()
        {
            InitializeComponent();

            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.Fixed3D;
        }

        // 프로시저호출 타입, 플랜트코드, 공정코드, 작업지시번호, 작업지시순번
        public POP_WRK84(string sProcdureName, string sPlantCode, string sOpCode, string sWrkOrdrNo, string sWrkOrdrSeqNo, string sIND_BCD = "")
        {
            InitializeComponent();


            strProcdureName = sProcdureName;
            strPlantCode = sPlantCode;
            strOpCode = sOpCode;
            strWrkOrdrNo = sWrkOrdrNo;
            strWrkOrdrSeqNo = sWrkOrdrSeqNo;

            strIND_BCD = sIND_BCD;

            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.Fixed3D;
        }

        public string LabelTitle
        {
            get { return labTitle.Text; }
            set { labTitle.Text = value; }
        }

        private void btnCancel_Click(object sender, EventArgs e)
        {
            this.DialogResult = System.Windows.Forms.DialogResult.Cancel;
        }

        private void POP_WRK84_Load(object sender, EventArgs e)
        {
            DoFind();
        }


        private void DoFind()
        {
            DBHelper helper = new DBHelper();
            string sWrkInfo1 = string.Empty;
            string sWrkInfo2 = string.Empty;
            string sWrkRemark = string.Empty;
            string sRemark = string.Empty;
            string sQueryName = string.Empty;

            try
            {
                if (strProcdureName.Equals(PROC_INP))
                {
                    sQueryName = "SP_POP_WRK84_S01";
                }
                else if (strProcdureName.Equals(PROC_WRK))
                {
                    sQueryName = "SP_POP_WRK84_S02";
                }
                else if (strProcdureName.Equals(PROC_PRFM))
                {
                    sQueryName = "SP_POP_WRK84_S03";
                }
                else //if (strProcdureName.Equals(PROC_INP_PRFM))
                {
                    sQueryName = "SP_POP_WRK84_S04";    //공정투입
                }


                //버튼 목록 조회
                helper.ExecuteNoneQuery(sQueryName, CommandType.StoredProcedure
                                                               , helper.CreateParameter("P_WERKS", strPlantCode, DbType.String, ParameterDirection.Input)               // PLANT CODE
                                                               , helper.CreateParameter("P_OPCODE", strOpCode, DbType.String, ParameterDirection.Input)                 // 공정정보
                                                               //, helper.CreateParameter("P_MACH_CD", strMachineCode, DbType.String, ParameterDirection.Input)           // 설비코드
                                                               , helper.CreateParameter("P_WRK_ORDR_NO", strWrkOrdrNo, DbType.String, ParameterDirection.Input)         // 작업지시번호
                                                               , helper.CreateParameter("P_WRK_ORDR_SEQNO", strWrkOrdrSeqNo, DbType.String, ParameterDirection.Input)   // 작업지시순번
                                                               , helper.CreateParameter("P_IND_BCD", strIND_BCD, DbType.String, ParameterDirection.Input)               // 개별바코드
                                                               , helper.CreateParameter("P_WRK_INFO_01", DbType.String, ParameterDirection.Output, null, 4000)          // 작업지시 상세정보 1
                                                               , helper.CreateParameter("P_WRK_INFO_02", DbType.String, ParameterDirection.Output, null, 4000)          // 작업지시 상세정보 2
                                                               , helper.CreateParameter("P_WRK_RMK", DbType.String, ParameterDirection.Output, null, 1000)           // 작업지시비고
                                                               , helper.CreateParameter("P_RMK", DbType.String, ParameterDirection.Output, null, 1000));             // 비고

                if (helper.Parameters["RS_CODE"].Value.ToString().Equals("E"))
                {
                    new POPUP.MessageForm(helper.Parameters["RS_MSG"].Value.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);

                    this.Close();
                }
                else
                {
                    ////컬럼설정 정보
                    sWrkInfo1 = helper.Parameters["P_WRK_INFO_01"].Value.ToString();
                    sWrkInfo2 = helper.Parameters["P_WRK_INFO_02"].Value.ToString();
                    sWrkRemark = helper.Parameters["P_WRK_RMK"].Value.ToString();
                    sRemark = helper.Parameters["P_RMK"].Value.ToString();

                    string[] words = sWrkInfo1.Split('|');

                    string strInfo1 = "";
                    foreach (var word in words)
                    {
                        strInfo1 += word.Replace("^", " : ") + System.Environment.NewLine;
                    }
                    lblInfo1.Text = strInfo1;

                    words = sWrkInfo2.Split('|');
                    string strInfo2 = "";
                    foreach (var word in words)
                    {
                        strInfo2 += word.Replace("^", " : ") + System.Environment.NewLine;
                    }
                    lblInfo2.Text = strInfo2;


                    lblRemark.Text = sRemark.Trim().Replace("\n", "\r\n");
                    txtWrkRemark.Text = sWrkRemark.Trim().Replace("\n", "\r\n");

                }

            }
            catch (Exception ex)
            {
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                LogFile.WriteLog("POP_WRK08.SetGrid Error => " + ex.Message);
            }
        }
    }
}
