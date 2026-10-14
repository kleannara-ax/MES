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

namespace SmartDas.POPUP
{
    public partial class POP_WRK81 : Form
    {
        MESGrid GridMach = new MESGrid();
        MESGrid GridLoc = new MESGrid();

        string gsIND_BCD = string.Empty; // 개별바코드
        string gsLOC_CD = string.Empty;  // 재단 로케이션 코드
        string gsMACH_CD = string.Empty; // 설비호기 코드

        private string strPlantCode = "";
        private string strOpCode = "";
        private string strWrkOrdrNo = "";
        private string strWrkOrdrSeqNo = "";
        private string strIND_BCD = "";

        public POP_WRK81(string sPlantCode, string sOpCode, string sWrkOrdrNo, string sWrkOrdrSeqNo, string sIND_BCD)
        {
            InitializeComponent();

            strPlantCode = sPlantCode;
            strOpCode = sOpCode;
            strWrkOrdrNo = sWrkOrdrNo;
            strWrkOrdrSeqNo = sWrkOrdrSeqNo;

            strIND_BCD = sIND_BCD;


            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.Fixed3D;
        }

        //public POP_WRK81(string OrderNo, string ItemCode)
        //{
        //    InitializeComponent();
        //}

        public string LabelTitle
        {
            get { return labTitle.Text; }
            set { labTitle.Text = value; }
        }


        private void POP_WRK81_Load(object sender, EventArgs e)
        {
            txtIND_BCD.Text = strIND_BCD;

            DoFind();
        }


        private void DoFind()
        {
            DBHelper helper = new DBHelper();
            string sItemInfo1 = string.Empty;
            string sItemInfo2 = string.Empty;
            string sItemInfo3 = string.Empty;
            string sStatus = string.Empty;

            try
            {
                //버튼 목록 조회
                helper.ExecuteNoneQuery("SP_POP_WRK81_S01", CommandType.StoredProcedure
                                                               , helper.CreateParameter("P_WERKS", strPlantCode, DbType.String, ParameterDirection.Input)               // PLANT CODE
                                                               , helper.CreateParameter("P_OPCODE", strOpCode, DbType.String, ParameterDirection.Input)                 // 공정정보
                                                               , helper.CreateParameter("P_WRK_ORDR_NO", strWrkOrdrNo, DbType.String, ParameterDirection.Input)         // 작업지시번호
                                                               , helper.CreateParameter("P_WRK_ORDR_SEQNO", strWrkOrdrSeqNo, DbType.String, ParameterDirection.Input)   // 작업지시순번
                                                               , helper.CreateParameter("P_IND_BCD", strIND_BCD, DbType.String, ParameterDirection.Input)               // 개별바코드
                                                               , helper.CreateParameter("P_INFO_01", DbType.String, ParameterDirection.Output, null, 4000)          // 작업지시 상세정보 1
                                                               , helper.CreateParameter("P_INFO_02", DbType.String, ParameterDirection.Output, null, 4000)          // 작업지시 상세정보 2
                                                               , helper.CreateParameter("P_INFO_03", DbType.String, ParameterDirection.Output, null, 4000)           // 작업지시비고
                                                               , helper.CreateParameter("P_STATUS", DbType.String, ParameterDirection.Output, null, 1000));             // 비고

                if (helper.Parameters["RS_CODE"].Value.ToString().Equals("E"))
                {
                    new POPUP.MessageForm(helper.Parameters["RS_MSG"].Value.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);

                    this.Close();
                }
                else
                {
                    //lblIND_BCD.Text = strIND_BCD;

                    ////컬럼설정 정보
                    sItemInfo1 = helper.Parameters["P_INFO_01"].Value.ToString();
                    sItemInfo2 = helper.Parameters["P_INFO_02"].Value.ToString();
                    sItemInfo3 = helper.Parameters["P_INFO_03"].Value.ToString();
                    sStatus = helper.Parameters["P_STATUS"].Value.ToString();

                    string[] words = sItemInfo1.Split('|');

                    string strInfo1 = "";
                    foreach (var word in words)
                    {
                        strInfo1 += word.Replace("^", " : ") + System.Environment.NewLine;
                    }
                    lblItemInfo.Text = strInfo1;
                    //---------------------------------------------------
                    words = sItemInfo2.Split('|');
                    string strInfo2 = "";
                    foreach (var word in words)
                    {
                        strInfo2 += word.Replace("^", " : ") + System.Environment.NewLine;
                    }
                    lblItemInfo2.Text = strInfo2;
                    //---------------------------------------------------
                    words = sItemInfo3.Split('|');
                    string strInfo3 = "";
                    foreach (var word in words)
                    {
                        strInfo3 += word.Replace("^", " : ") + System.Environment.NewLine;
                    }
                    lblItemInfo3.Text = strInfo3;
                    //---------------------------------------------------
                    lblStatus.Text = sStatus.Trim().Replace("\n", "\r\n");
                }

            }
            catch (Exception ex)
            {
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                LogFile.WriteLog("POP_WRK81.SetGrid Error => " + ex.Message);
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
                                                               , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_STOR_LOC_CD", "2700", DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_COLINFO", DbType.String, ParameterDirection.Output, null, 1000)
                                                               , helper.CreateParameter("P_COLTYPE", DbType.String, ParameterDirection.Output, null, 1000));
                if (dtRtn.Rows.Count < 1)
                {
                    new POPUP.MessageForm("조회된 작업지시가 없습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
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

                    GridLoc.DoFind_Oracle(dsTemp);
                    //그리드 출력
                    //Grid1.DoFind_Oracle(dsTemp);
                    // 첫번째 행 선택
                    //Grid1.Rows[0].Selected = true;
                    //Grid1.Row = Grid1.Rows[0];
                    //resultMATNR = Grid1.Rows[0].Cells["MATNR"].Value.ToString();
                    //resultMAKTG = Grid1.Rows[0].Cells["MATNR_NM"].Value.ToString();
                    //lblMATNR.Text = resultMATNR;
                }

            }
            catch (Exception ex)
            {
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                LogFile.WriteLog("POP_WRK08.SetGrid Error => " + ex.Message);
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
                                                               , helper.CreateParameter("P_PROC_CD", Common.OpCode, DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_COLINFO", DbType.String, ParameterDirection.Output, null, 1000)
                                                               , helper.CreateParameter("P_COLTYPE", DbType.String, ParameterDirection.Output, null, 1000));
                if (dtRtn.Rows.Count < 1)
                {
                    new POPUP.MessageForm("조회된 작업지시가 없습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
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

                    GridMach.DoFind_Oracle(dsTemp);
                }

            }
            catch (Exception ex)
            {
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                LogFile.WriteLog("POP_WRK08.SetGrid Error => " + ex.Message);
            }
        }

        //// 재단대기창고 이동
        //private void doUpdateLocation()
        //{
        //    if (lblLocMach.Tag == null)
        //    {
        //        new POPUP.MessageForm("로케이션 선택은 필수 입니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
        //        return;
        //    }

        //    string Code = lblLocMach.Tag.ToString();
        //    string Name = lblLocMach.Text.ToString();
        //    if (sLOC_CD.Equals(Code))
        //    {
        //        new POPUP.MessageForm("이전 로케이션 위치와 동일 합니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
        //        return;
        //    }

        //    if (new POPUP.MessageForm(string.Format("재단대기창고를 변경 하시겠습니까?\r\n\r\n'{0}' 로 변경", Name), MessageBoxButtons.OKCancel, "알   림").ShowDialog(this) != DialogResult.OK)
        //    {
        //        return;
        //    }

        //    DBHelper helper = new DBHelper();

        //    try
        //    {
        //        helper.ExecuteNoneQuery("SP_POP_WRK81_U01", CommandType.StoredProcedure
        //                                                       , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)
        //                                                       , helper.CreateParameter("P_STOR_LOC_CD", "2700", DbType.String, ParameterDirection.Input)
        //                                                       , helper.CreateParameter("P_IND_BCD", sIND_BCD, DbType.String, ParameterDirection.Input)
        //                                                       , helper.CreateParameter("P_LOC_CD", Code, DbType.String, ParameterDirection.Input)
        //                                                       , helper.CreateParameter("P_USER_ID", Common.UserID, DbType.String, ParameterDirection.Input)
        //                                                        );

        //        if (helper.RSCODE == "S")
        //        {
        //            new POPUP.MessageForm("재단대기창고 이동 완료되었습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
        //        }
        //        else
        //        {
        //            new POPUP.MessageForm(helper.RSMSG, MessageBoxButtons.OK, "알   림").ShowDialog(this);
        //        }
        //    }
        //    catch (Exception ex)
        //    {
        //        new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
        //    }
        //    finally
        //    {
        //        helper.Close();
        //    }
        //}

        // 재단투입
        private void doInsertMach()
        {
/*
            if (lblLocMach.Tag == null)
            {
                new POPUP.MessageForm("투입할 재단 선택은 필수 입니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return;
            }

            string Code = lblLocMach.Tag.ToString();
            string Name = lblLocMach.Text.ToString();

            if (new POPUP.MessageForm(string.Format("재단투입 하시겠습니까?\r\n\r\n'{0}'에 투입", Name), MessageBoxButtons.OKCancel, "알   림").ShowDialog(this) != DialogResult.OK)
            {
                return;
            }
*/
            DBHelper helper = new DBHelper();
            try
            {
                //helper.ExecuteNoneQuery("SP_POP_WRK81_I01", CommandType.StoredProcedure
                //        , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)  //플랜트코드
                //        , helper.CreateParameter("P_MACH_CD", Code, DbType.String, ParameterDirection.Input)            //설비코드
                //        , helper.CreateParameter("P_STOR_LOC_CD", "2700", DbType.String, ParameterDirection.Input)      //저장위치코드
                //        , helper.CreateParameter("P_IND_BCD", strIND_BCD, DbType.String, ParameterDirection.Input)        //개별바코드
                //        , helper.CreateParameter("P_USER_ID", Common.UserID, DbType.String, ParameterDirection.Input)   //USERID
                //        );

                helper.ExecuteNoneQuery("SP_POP_WRK01_I01", CommandType.StoredProcedure
                    , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)               // 플랜트
                    , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)           // 작업장코드(설비코드)
                    , helper.CreateParameter("P_IND_BCD", strIND_BCD, DbType.String, ParameterDirection.Input)                    // 개별바코드
                    , helper.CreateParameter("P_STOR_LOC_CD", "2700", DbType.String, ParameterDirection.Input)                // 로케이션코드
                    , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input)                 // 사용자ID
                    , helper.CreateParameter("P_EXCEPTION", 'N', DbType.String, ParameterDirection.Input)                 // 예외인경우 : "E"로 전달
                    );


                if (helper.RSCODE == "S")
                {
                    new POPUP.MessageForm("재단투입 완료되었습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                }
                else
                {
                    new POPUP.MessageForm(helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    //gsRESULT = "";
                    // new POPUP.MessageForm("작업자를 서버에 저장하는 도중 에러가 발생했습니다. 다시 시도해주세요.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                }
            }
            catch (Exception ex)
            {
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
            }
            finally
            {
                helper.Close();
            }

        }


        //private void btnLocMach_Click(object sender, EventArgs e)
        //{
        //    //string sTitle = "";
        //    POPCombo combo_pop;

        //    if(rbLocation.Checked == true) {
        //        combo_pop = new POPCombo("재단대기창고 변경", Common.PlantCode, "SP_POP00_S03");
        //    } 
        //    else 
        //    {
        //        combo_pop = new POPCombo("재단투입", Common.OpCode, "SP_POP00_S04");
        //    }

        //    combo_pop.ShowDialog(this);
        //    if (combo_pop.DialogResult == DialogResult.OK)
        //    {
        //        lblLocMach.Tag = combo_pop.resultArray[0].ToString(); //code
        //        lblLocMach.Text = combo_pop.resultArray[1].ToString(); //name

        //        if (rbLocation.Checked == true)
        //        {
        //            GridLoc = combo_pop.resultGrid;
        //            //sLOC_CD = lblLocMach.Tag.ToString();
        //        }
        //        else
        //        {
        //            GridMach = combo_pop.resultGrid;
        //            //sMACH_CD = lblLocMach.Tag.ToString();
        //        }
        //    }
        //}

        private void rbLocation_Click(object sender, EventArgs e)
        {
            //try
            //{
            //    btnConfirm.Text = "창고이동";
            //    lblStatus.Visible = false;

            //    //lblLocMach.Tag = GridLoc.Rows[0].Cells[0].Value.ToString();
            //    //lblLocMach.Text = GridLoc.Rows[0].Cells["Display"].Value.ToString();
            //    // 로케이션명 구하기
            //    DataTable dt = (DataTable)GridLoc.DataSource;
            //    foreach (DataRow row in dt.Rows)
            //    {
            //        //string Code = row.ItemArray[0].ToString();
            //        //string Name = row.ItemArray[1].ToString();
            //        string Code = row["ItemCode"].ToString();
            //        string Name = row["Display"].ToString();
            //        //Console.WriteLine(string.Format("{0}, {1}", Code, Name));

            //        if (sLOC_CD.Equals(Code))
            //        {
            //            lblLocMach.Tag = Code;
            //            lblLocMach.Text = Name;
            //            break;
            //        }
            //    }

            //}
            //catch
            //{
            //}
        }

        private void rbMachne_Click(object sender, EventArgs e)
        {
            //try
            //{
            //    btnConfirm.Text = "재단투입";
            //    lblStatus.Visible = true;
            //    //lblLocMach.Tag = GridMach.Rows[0].Cells[0].Value.ToString();
            //    //lblLocMach.Text = GridMach.Rows[0].Cells["Display"].Value.ToString();

            //    DataTable dt = (DataTable)GridMach.DataSource;
            //    foreach (DataRow row in dt.Rows)
            //    {
            //        //string Code = row.ItemArray[0].ToString();
            //        //string Name = row.ItemArray[1].ToString();
            //        string Code = row["ItemCode"].ToString();
            //        string Name = row["Display"].ToString();
            //        //Console.WriteLine(string.Format("{0}, {1}", Code, Name));

            //        if (sMACH_CD.Equals(Code))
            //        {
            //            lblLocMach.Tag = Code;
            //            lblLocMach.Text = Name;
            //            break;
            //        }
            //    }

            //}
            //catch
            //{
            //}
        }

        private void btnConfirm_Click(object sender, EventArgs e)
        {
            //if (rbLocation.Checked == true)
            //{
            //    doUpdateLocation();
            //}
            //else  // 재단투입
            //{
                strIND_BCD = txtIND_BCD.Text.ToString();
                
                doInsertMach();

                DoFind();

            //}
        }

        private void btnClose_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        private void btnLocMach_Click(object sender, EventArgs e)
        {

        }

        private void txtIND_BCD_KeyPress(object sender, KeyPressEventArgs e)
        {
            //숫자만 입력되도록 필터링
            if (e.KeyChar == Convert.ToChar(Keys.Enter))
            {
                strIND_BCD = txtIND_BCD.Text.ToString();
                DoFind();
            }
        }

    }
}
