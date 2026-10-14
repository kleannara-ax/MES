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

using Oracle.ManagedDataAccess.Client;

namespace SmartDas.POPUP
{
    public partial class POP_WRK82 : Form
    {
        POPUP.MessageForm msgForm = null;
        private string sOperType = string.Empty;
        private string strPlantCode = string.Empty;
        private string sInpDt = string.Empty;
        string sStckQty = string.Empty;

        // 플랜트코드, 작업지시번호, 작업지시순번, 업체/개별바코드, OperationType
        public POP_WRK82(string PlantCode, string WrkOrdrNo, string WrkOrdrSeqNo, string InpDT, string IndBcd, string OperType)
        {
            InitializeComponent();

            strPlantCode = PlantCode;
            sInpDt = InpDT;
            lblWrkOrdrNo.Text = WrkOrdrNo;
            lblWrkOrdrSeqNo.Text = WrkOrdrSeqNo;
            lblIndBcd.Text = IndBcd;

            sOperType = OperType;

            if (sOperType.Equals("REMAIN"))
            {
                labTitle.Text = "잔량처리";
                btnConfirm.Text = "잔량처리";
            }
            else
            {
                labTitle.Text = "잔량 및 반납요청";
                btnConfirm.Text = "반납요청";
            }

            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.Fixed3D;
        }

        public string LabelTitle
        {
            get { return labTitle.Text; }
            set { labTitle.Text = value; }
        }

        public string StckQty_Get
        {
            get { return sStckQty; }
        }

        private void POP_WRK82_Load(object sender, EventArgs e)
        {
            DoFind();
        }

        private void DoFind()
        {
            DBHelper helper = new DBHelper();
            DataTable dtRtn;

            try
            {
                dtRtn = helper.FillTable("SP_POP_WRK82_S01", CommandType.StoredProcedure
                                                               , helper.CreateParameter("P_WERKS", strPlantCode, DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_WRK_ORDR_NO", lblWrkOrdrNo.Text.ToString(), DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_WRK_ORDR_SEQNO", lblWrkOrdrSeqNo.Text.ToString(), DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_IND_BCD", lblIndBcd.Text.ToString(), DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_INP_DT", sInpDt, DbType.String, ParameterDirection.Input)
                                                               );
                if (dtRtn.Rows.Count < 1)
                {
                    new POPUP.MessageForm("조회된 작업지시가 없습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return;
                }
                else
                {
                    lblMatnr.Text = dtRtn.Rows[0]["MATNR"].ToString();   // 자재코드
                    lblMatnr_NM.Text = dtRtn.Rows[0]["MATNR_NM"].ToString();   // 자재명
                    lblMachNm.Tag = dtRtn.Rows[0]["MACH_CD"].ToString();   // 설비코드
                    lblMachNm.Text = dtRtn.Rows[0]["MACH_NM"].ToString();   // 설비명
                    lblStockQty.Text = string.Format("{0:#,##0.###}", dtRtn.Rows[0]["STCK_QTY"]);   // 재고량
                    lblStockQtyNew.Text = string.Format("{0:#,##0.###}", dtRtn.Rows[0]["STCK_QTY"]);   // 재고량
                    lblUnit1.Text = dtRtn.Rows[0]["UNIT"].ToString();   // 단위
                    lblUnit2.Text = dtRtn.Rows[0]["UNIT"].ToString();   // 단위


                }
            }
            catch (Exception ex)
            {
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                LogFile.WriteLog("POP_WRK08.WRK_ORDER Find Error\r\n" + ex.Message);
            }
            finally
            {
                helper.Close();
            }
        }


        private void doUpdate()
        {
            DBHelper helper = new DBHelper(false, "", true);
            DataSet dsTemp;
            DialogResult res = DialogResult.Cancel;
            string sUseFunc = string.Empty;
            string sStockQtyUpdate = lblStockQtyNew.Text.ToString().Replace(",", "").Trim();
            string sUserId = Common.UserID;
            string pURL; //restful 전송주소
            string rtnData; //전송결과 메세지
            string sRtnCode; //전송성공여부
            double dStckQty;
            bool bActFlag = true;


            if (sStockQtyUpdate.Length == 0)
            {
                return;
            }

            if (!double.TryParse(lblStockQtyNew.Text, out dStckQty))
            {
                new POPUP.MessageForm("실재고 입력내용을 확인하여 주시기 바랍니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return;
            }

            try
            {
                //실잔량 수량 확인
                if (dStckQty == 0.0)
                {
                    if (sOperType.Equals("RETURN"))
                    {
                        new POPUP.MessageForm("실잔량이 0인 경우 반납요청이 불가능 합니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                        return;
                    }
                    else
                    {
                        msgForm = new POPUP.MessageForm("실잔량이 0으로 입력되었습니다.\n재고를 소진처리 하시겠습니까?", MessageBoxButtons.OKCancel, "알   림");
                        res = msgForm.ShowDialog(this);
                        if (res != System.Windows.Forms.DialogResult.OK)
                            bActFlag = false;
                    }
                }
                //잔량처리 및 반납요청 진행
                if (bActFlag)
                {
                    sStckQty = sStockQtyUpdate;
                    dsTemp = helper.FillDataSetN("SP_POP_WRK82_U01", CommandType.StoredProcedure, 3
                                                                   , helper.CreateParameter("P_WERKS", strPlantCode, DbType.String, ParameterDirection.Input)       // 플랜트코드
                                                                   , helper.CreateParameter("P_WRK_ORDR_NO", lblWrkOrdrNo.Text.ToString(), DbType.String, ParameterDirection.Input)     // 작업지시번호
                                                                   , helper.CreateParameter("P_WRK_ORDR_SEQNO", lblWrkOrdrSeqNo.Text.ToString(), DbType.String, ParameterDirection.Input)   // 작업지시순번
                                                                   , helper.CreateParameter("P_MACH_CD", lblMachNm.Tag.ToString(), DbType.String, ParameterDirection.Input)    // 설비코드
                                                                   , helper.CreateParameter("P_MATNR", lblMatnr.Text, DbType.String, ParameterDirection.Input)    // 자재코드
                                                                   , helper.CreateParameter("P_IND_BCD", lblIndBcd.Text, DbType.String, ParameterDirection.Input)    // 업체/개별바코드
                                                                   , helper.CreateParameter("P_STCK_QTY", sStockQtyUpdate, DbType.String, ParameterDirection.Input) // 실재고량
                                                                   , helper.CreateParameter("P_USER_ID", sUserId, DbType.String, ParameterDirection.Input)  // 사용자ID
                                                                   , helper.CreateParameter("P_TYPE", sOperType, DbType.String, ParameterDirection.Input)  // 반납처리 구분
                                                                   , helper.CreateParameter("P_INP_DT", sInpDt, DbType.String, ParameterDirection.Input)
                        //, helper.CreateParameter("P_USE_FUNC", DbType.String, ParameterDirection.Output, null, 30)
                                                                   , helper.CreateParameter("P_WDOC_NO", DbType.String, ParameterDirection.Output, null, 30)
                                                                    );

                    if (helper.RSCODE == "S")
                    {
                        //반납요청 필요시 WMS 전송
                        if (sOperType.Equals("REMAIN"))
                        {
                            new POPUP.MessageForm("실재고 수정 완료되었습니다.\n" + helper.RSMSG + "로 이동되었습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                            this.DialogResult = DialogResult.OK;
                        }
                        else
                        {
                            //restful 전송
                            string sJsonData = Common.toJsonFormat_List("list", dsTemp.Tables[0]);
                            pURL = Common.WMS_IF_URL.Replace("IFID", "WMS_IF_207");
                            rtnData = Common.GetRestToString(pURL, sJsonData, "POST");

                            sRtnCode = rtnData.Contains("SUCCESS") ? "S" : "E";

                            //결과저장
                            Common.GetRestSaveResult("MES_IF_400", sJsonData, helper.Parameters["P_WDOC_NO"].Value.ToString(), "1", sRtnCode, rtnData).Equals("S");

                            if (rtnData.Contains("result"))
                            {
                                if (rtnData.Contains("SUCCESS"))
                                {
                                    new POPUP.MessageForm("자재 반납요청이 정상적으로 완료되었습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                    this.DialogResult = DialogResult.OK;
                                    helper.Commit();
                                }
                                else
                                {
                                    new POPUP.MessageForm("자재 반납요청이 실패하였습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                    helper.Rollback();
                                }
                            }
                            else
                            {
                                new POPUP.MessageForm("요청 전송이 실패하였습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                helper.Rollback();
                            }
                        }
                    }
                    else
                    {
                        new POPUP.MessageForm(helper.RSMSG, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                        helper.Rollback();
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                helper.Close();

                this.Close();
            }

        }

        private void btnConfirm_Click(object sender, EventArgs e)
        {
            doUpdate();
        }

        private void btnClose_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        private void lblStockQtyNew_Click(object sender, EventArgs e)
        {
            DAResultNum pop = new DAResultNum();
            pop.LabelTitle = "잔량 입력";
            pop.LabelHeader = "잔량";
            pop.ContentMaxLength = 8;

            pop.ShowDialog(this);

            if (pop.DialogResult == DialogResult.OK)
            {
                lblStockQtyNew.Text = string.Format("{0:#,##0.###}", pop.ResultDouble);
            }

        }


    }
}
