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
    public partial class POP_WRK83 : Form
    {
        string sIND_BCD_M = "";             //밀롤 개별바코드
        string sLOT_NO_M = "";              //밀롤 LOTNO
        string sMATNR_M = "";               //밀롤 자재번호
        string sWRK_ORDR_NO_M = "";         //밀롤 작업지시 번호
        string sWRK_ORDR_SEQNO_M = "";      //밀롤 작업지시 순번

        string sWRK_ORDR_NO = "";           //재단 작업지시 번호
        string sWRK_ORDR_SEQNO = "";        //재단 작업지시 순번

        string sPCODE_NM = "";              //지종명
        string sPCODE = "";                 //지종코드
        string sBS_WGT = "";                //평량
        string sWLEN = "";                  //가로
        string sVLEN = "";                  //세로
        string sPRD_STR_DTM = "";           //마지막 작업종료시간을 생산시작일시 및, 시작 시간으로 사용
        private double dBasisWgt = 0;     // 평량
        private double dWidth = 0;       // 가로
        private double dLength = 0;       // 세로

        
        private string gsCA_IND_BCD = "";

        public POP_WRK83()
        {
            InitializeComponent();

            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.Fixed3D;
        }

        // sIND_BCD_CA = 재단개별바코드
        public POP_WRK83(string sCA_IND_BCD)
        {
            InitializeComponent();

            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.Fixed3D;

            gsCA_IND_BCD = sCA_IND_BCD;
        }

        private void POP_WRK83_Load(object sender, EventArgs e)
        {
            try
            {
                SetFind();
            }
            catch (Exception ex)
            {
                LogFile.WriteLog("POP_WRK83_Load Error => " + ex.Message);
            }            

        }

        private void SetFind()
        {
            if (string.IsNullOrEmpty(gsCA_IND_BCD))
            {
                new POPUP.MessageForm("재단 바코드를 찾지 못했습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);

                this.DialogResult = System.Windows.Forms.DialogResult.Cancel;
                //this.Close();
            }

            DBHelper helper = new DBHelper();
            DataTable dtRtn;

            try
            {
                dtRtn = helper.FillTable("SP_POP_WRK83_S01", CommandType.StoredProcedure
                                    , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)          // 플랜트코드
                                    , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)           // 작업장코드(설비코드)
                                    , helper.CreateParameter("P_CA_IND_BCD", gsCA_IND_BCD, DbType.String, ParameterDirection.Input)          // 재단 개별바코드
                                    );

                if (dtRtn.Rows.Count == 1)
                {
                    sIND_BCD_M = dtRtn.Rows[0]["IND_BCD_M"].ToString();
                    sLOT_NO_M = dtRtn.Rows[0]["LOT_NO_M"].ToString();
                    sMATNR_M = dtRtn.Rows[0]["MATNR_M"].ToString();
                    sWRK_ORDR_NO_M = dtRtn.Rows[0]["WRK_ORDR_NO_M"].ToString();
                    sWRK_ORDR_SEQNO_M = dtRtn.Rows[0]["WRK_ORDR_SEQNO_M"].ToString();

                    sWRK_ORDR_NO = dtRtn.Rows[0]["WRK_ORDR_NO"].ToString();
                    sWRK_ORDR_SEQNO = dtRtn.Rows[0]["WRK_ORDR_SEQNO"].ToString();

                    sPCODE_NM = dtRtn.Rows[0]["PCODE_NM"].ToString();
                    sPCODE = dtRtn.Rows[0]["PCODE"].ToString();
                    sBS_WGT = dtRtn.Rows[0]["BS_WGT"].ToString();
                    sWLEN = dtRtn.Rows[0]["WLEN"].ToString();
                    sVLEN = dtRtn.Rows[0]["VLEN"].ToString();

                    sPRD_STR_DTM = dtRtn.Rows[0]["PRD_STR_DTM"].ToString();

                    string sPopMsg = string.Format("여유생산을 위해 선택한 밀롤 정보\r\n\r\n밀롤 LOT ID : {0}\r\n지종 : {1}\r\n평량 : {2}\r\n밀롤 자재번호 : {3}\r\n여유생산등록을 실행 하시겠습니까?",
                                    sLOT_NO_M, sPCODE_NM, sBS_WGT, sMATNR_M);

                    if (new POPUP.MessageForm(sPopMsg, MessageBoxButtons.OKCancel, "알   림").ShowDialog(this) == DialogResult.OK)
                    {
                        //string sWORK_DATE = Common.GetRecDate(DateTime.Now);
                        string sWORK_DATE = Common.GetRecDate(Convert.ToDateTime(sPRD_STR_DTM));

                        DateTime dtTmp;
                        if (DateTime.TryParseExact(sWORK_DATE, "yyyyMMdd", null, System.Globalization.DateTimeStyles.AssumeLocal, out dtTmp))
                        {
                            dtpWorkDate.Value = dtTmp;
                        }
                        else
                        {
                            dtpWorkDate.Value = DateTime.Now;
                        }

                        lblPRFM_DT.Text = dtpWorkDate.Value.ToString("yyyy-MM-dd");

                        if (double.TryParse(sBS_WGT, out dBasisWgt) == false)
                        {
                            dBasisWgt = 0;
                        }

                        if (double.TryParse(sWLEN, out dWidth) == false)
                        {
                            dWidth = 0;
                        }

                        if (double.TryParse(sVLEN, out dLength) == false)
                        {
                            dLength = 0;
                        }

                        lblLOT_NO_M.Text = sLOT_NO_M;
                        lblPCODE.Text = sPCODE;

                        lblBS_WGT.Text = string.Format("{0:#,0.###}", dBasisWgt); //평량
                        lblWLEN.Text = string.Format("{0:#,0.###}", dWidth); //가로
                        lblVLEN.Text = string.Format("{0:#,0.###}", dLength); //세로
                    }
                    else
                    {
                        this.DialogResult = System.Windows.Forms.DialogResult.Cancel;
                    }

                }
            }
            catch (Exception ex)
            {
                LogFile.WriteLog("여유생산-SetFind Error => " + ex.Message);
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                this.DialogResult = System.Windows.Forms.DialogResult.Cancel;
            }
        }

        public string LabelTitle
        {
            get { return labTitle.Text; }
            set { labTitle.Text = value; }
        }

        private void lblPF_PLT_REAM_Click(object sender, EventArgs e)
        {
            DAResultNum pop = new DAResultNum();
            pop.LabelHeader = "팔레트 연수";
            pop.ShowDialog(this);
            if (pop.DialogResult == DialogResult.OK)
            {
                lblPF_PLT_REAM.Text = string.Format("{0:#,##0.###}", pop.ResultDouble);

                //중량 계산
                WgtCalculation();
            }
        }

        // 중량 계산
        private void WgtCalculation()
        {
            double dReam = 0;
            if (double.TryParse(lblPF_PLT_REAM.Text.ToString(), out dReam) == false)
            {
                dReam = 0;
            }

            if (dReam <= 0)
            {
                lblPalletWgt.Text = "";
                return;
            }

            double dValue = dReam * 500;                // 1Ream=500매

            dValue = dValue * dBasisWgt / 1000.0;       // 평량
            dValue = dValue * dWidth / 1000.0;          // 재단 가로
            dValue = dValue * dLength / 1000.0;         // 재단 세로

            lblPalletWgt.Text = string.Format("{0:#,0.###}", Math.Round(dValue, 3, MidpointRounding.AwayFromZero));
        }


        private void lblPF_WRK_ORDR_RMK_Click(object sender, EventArgs e)
        {
            DAResultText pop = new DAResultText("여유생산 비고입력");
            pop.ShowDialog(this);
            if (pop.DialogResult == DialogResult.OK)
            {
                lblPF_WRK_ORDR_RMK.Text = pop.ResultString;
            }
        }

        private void lblTM_Click(object sender, EventArgs e)
        {
            DAResultQty pop = new DAResultQty();
            pop.LabelHeader = "가동시간(분)";
            pop.ShowDialog(this);

            if (pop.DialogResult == DialogResult.OK)
            {
                lblTM.Text = string.Format("{0:#,##0}", pop.ResultDouble);
            }

        }

        private void butWorkDate_Click(object sender, EventArgs e)
        {
            DAResultDate pop = new DAResultDate(dtpWorkDate.Value);
            pop.ShowDialog(this);
            if (pop.DialogResult == DialogResult.OK)
            {
                string strDate = pop.ResultString.ToString();
                dtpWorkDate.Value = DateTime.Parse(strDate);
            }
        }

        #region <실적등록>
        private DataTable setReqWorkList()
        {
            DataTable dtRtn = new DataTable();
            DataRow dtTempRow;

            try
            {
                //테이블 컬럼명 작성
                dtRtn.Columns.Add(new DataColumn("PRD_STR_DATE", typeof(string)));      //작업시작일시
                dtRtn.Columns.Add(new DataColumn("PRD_END_DATE", typeof(string)));      //작업종료일시
                dtRtn.Columns.Add(new DataColumn("PRFM_DT", typeof(string)));          //생산실적일자

                dtRtn.Columns.Add(new DataColumn("PRFM_QTY", typeof(string)));         //실적수량(연수)
                dtRtn.Columns.Add(new DataColumn("PRFM_PLT", typeof(string)));         //실적수량(연수)
                dtRtn.Columns.Add(new DataColumn("TM", typeof(string)));                //가동시간(분)

                dtRtn.Columns.Add(new DataColumn("WLEN", typeof(string)));             //가로길이
                dtRtn.Columns.Add(new DataColumn("VLEN", typeof(string)));             //세로길이
                dtRtn.Columns.Add(new DataColumn("BS_WGT", typeof(string)));           //평량
                dtRtn.Columns.Add(new DataColumn("TT_WLEN", typeof(string)));          //가로길이(실재단규격) 수재단사용
                dtRtn.Columns.Add(new DataColumn("TT_VLEN", typeof(string)));          //세로길이(실재단규격) 수재단사용

                //dtRtn.Columns.Add(new DataColumn("WGT", typeof(string)));               //중량
                dtRtn.Columns.Add(new DataColumn("DISPO_QTY1", typeof(string)));        //폐품권치수
                dtRtn.Columns.Add(new DataColumn("DISPO_WGT1", typeof(string)));         //폐품중량
                dtRtn.Columns.Add(new DataColumn("DISPO_CD1", typeof(string)));          //폐품코드
                dtRtn.Columns.Add(new DataColumn("DISPO_NM1", typeof(string)));          //폐품코드

                dtRtn.Columns.Add(new DataColumn("DISPO_QTY2", typeof(string)));        //폐품권치수
                dtRtn.Columns.Add(new DataColumn("DISPO_WGT2", typeof(string)));         //폐품중량
                dtRtn.Columns.Add(new DataColumn("DISPO_CD2", typeof(string)));          //폐품코드
                dtRtn.Columns.Add(new DataColumn("DISPO_NM2", typeof(string)));          //폐품코드

                dtRtn.Columns.Add(new DataColumn("RMK", typeof(string)));               //비고
                dtRtn.Columns.Add(new DataColumn("CACOM_YN", typeof(string)));          //재단완료여부
                dtRtn.Columns.Add(new DataColumn("LAST_YN", typeof(string)));           //마지막품목(품목교체)여부
                dtRtn.Columns.Add(new DataColumn("MOVE_YN", typeof(string)));             //수재단이동여부
                dtRtn.Columns.Add(new DataColumn("IND_BCD_M", typeof(string)));             //밀롤 개별바코드
                dtRtn.Columns.Add(new DataColumn("MATRN_M", typeof(string)));             //밀롤 자재코드
                dtRtn.Columns.Add(new DataColumn("LOT_NO_M", typeof(string)));             //밀롤 LOT_NO
                dtRtn.Columns.Add(new DataColumn("WRK_ORDR_NO_M", typeof(string)));             //밀롤 작업지시번호
                dtRtn.Columns.Add(new DataColumn("WRK_ORDR_SEQNO_M", typeof(string)));             //밀롤 작업지시순번

                //조회결과 입력용 Row생성
                dtTempRow = dtRtn.NewRow();

                DateTime dtCurTime = DateTime.Now;
                string sStartDate = dtCurTime.ToString("yyyyMMddHHmm") + "00";
                string sEndDate = dtCurTime.ToString("yyyyMMddHHmm") + "01";

                dtTempRow["PRD_STR_DATE"] = sStartDate;                 //작업시작일시
                dtTempRow["PRD_END_DATE"] = sEndDate;                   //작업종료일시
                dtTempRow["PRFM_DT"] = dtpWorkDate.Value.ToString("yyyyMMdd");        //생산실적일자

                dtTempRow["TM"] = lblTM.Text.ToString().Replace(",", "");         //가동시간(분)

                dtTempRow["WLEN"] = sWLEN.Replace(",", "");                     //가로길이
                dtTempRow["VLEN"] = sVLEN.Replace(",", "");                     //세로길이

                dtTempRow["BS_WGT"] = sBS_WGT.Replace(",", "");                 //평량
                
                dtTempRow["PRFM_QTY"] = lblPF_PLT_REAM.Text.ToString().Replace(",", "");        //팔레트 연수
                dtTempRow["PRFM_PLT"] = "1";           //팔레트 개수

                dtTempRow["RMK"] = lblPF_WRK_ORDR_RMK.Text.ToString();                       // 비고

                //dtTempRow["CACOM_YN"] = "Y";
                dtTempRow["CACOM_YN"] = "Y";

                dtTempRow["LAST_YN"] = "N";       // 마지막품목교체
                dtTempRow["MOVE_YN"] = "N";       // 수재단이동 안함

                dtTempRow["IND_BCD_M"] = sIND_BCD_M;       //밀롤 개별바코드
                dtTempRow["MATRN_M"] = sMATNR_M;         //밀롤 자재코드
                dtTempRow["LOT_NO_M"] = sLOT_NO_M;         //밀롤 LOT 번호
                dtTempRow["WRK_ORDR_NO_M"] = sWRK_ORDR_NO_M;                             //밀롤 작업지시번호
                dtTempRow["WRK_ORDR_SEQNO_M"] = sWRK_ORDR_SEQNO_M;                         //밀롤 작업지시순번

                //결과 테이블에 저장
                dtRtn.Rows.Add(dtTempRow);
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return dtRtn;
        }

#if true
        /// <summary>
        /// 재단 여유생산 실적등록
        /// </summary>
        private bool doProduct()
        {
            DataTable dtList;

            Decimal dPLT_REAM;

            if (!Decimal.TryParse(lblPF_PLT_REAM.Text.ToString().Replace(",", ""), out dPLT_REAM))
            {
                dPLT_REAM = 0;
            }

            if (dPLT_REAM == 0)
            {
                new POPUP.MessageForm("팔레트 연수 입력을 확인하세요!", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return false;
            }

            //---------------------------------------------------------------------------------------------------
            int nTM;
            if (!int.TryParse(lblTM.Text.ToString().Replace(",", ""), out nTM))
            {
                nTM = 0;
            }

            if(nTM == 0)
            {
                new POPUP.MessageForm("가동시간 입력을 확인하세요!", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return false;
            }

            //---------------------------------------------------------------------------------------------------
            string sPopMsg = string.Format("여유생산 실적 등록 정보\r\n\r\n여유생산 연수 : {0:#,0.###}\r\n가동시간 : {1}\r\n여유생산 실적등록을 실행 하시겠습니까?",
                            dPLT_REAM, nTM);

            if (new POPUP.MessageForm(sPopMsg, MessageBoxButtons.OKCancel, "알   림").ShowDialog(this) == DialogResult.Cancel)
            {
                return false;
            }

            //---------------------------------------------------------------------------------------------------
            dtList = setReqWorkList();
            string sJsonWrkList = Common.toJsonFormat("POP_WRK083", dtList);

            DBHelper helper = new DBHelper(false, "", true);
            DataSet dsTemp;     //실적등록 결과 수신(0:실적 RFC ID, 1:실적 IF 변수, 2:실적 RFC ID, 3:실적 IF 변수)
            bool bReturn = false;       // 실적 처리 결과
            //bool bRetDISPO = false;     // 폐품 처리 결과
            //bool bRetINP = false;       // 투입량 처리 결과
            string sRES_IND_BCD = "";

            try
            {
                Cursor.Current = Cursors.WaitCursor;   //Waitting

                dsTemp = helper.FillDataSetN("SP_POP_WRK83_I01", CommandType.StoredProcedure, 2
                    , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)                              // 플랜트
                    , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)                          // 작업장코드(설비코드)
                    , helper.CreateParameter("P_WRK_ORDR_NO", sWRK_ORDR_NO, DbType.String, ParameterDirection.Input)                            // 재단 작업지시번호
                    , helper.CreateParameter("P_WRK_ORDR_SEQNO", sWRK_ORDR_SEQNO, DbType.String, ParameterDirection.Input)                      // 재단 작업지시순번
                    , helper.CreateParameterOracle("P_WRK_LIST", sJsonWrkList, OracleDbType.Clob, ParameterDirection.Input)                     // 밀롤 실적등록 리스트
                    , helper.CreateParameter("P_WRK_CLASS", Common.WorkClass, DbType.String, ParameterDirection.Input)                          // 작업반
                    , helper.CreateParameter("P_WRK_SHIFT", Common.WorkShift, DbType.String, ParameterDirection.Input)                          // 작업조
                    , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input)                                // 사용자ID
                    , helper.CreateParameter("RS_PRFM_RFCFN", DbType.String, ParameterDirection.Output, null, 200)                              // 실적 RFCFN
                    , helper.CreateParameter("RS_IND_BCD", DbType.String, ParameterDirection.Output, null, 2000)                                 //  RES 개별바코드 리스트
                    );

                if (helper.RSCODE == "S")
                {
                    sRES_IND_BCD = helper.Parameters["RS_IND_BCD"].Value.ToString();

                    string sRS_PRFM_RFCFN = helper.Parameters["RS_PRFM_RFCFN"].Value.ToString();      // 실적 RFCFN ID

                    //dsTemp.Tables[0];     // 실적 인터페이스 파라미터
                    //dsTemp.Tables[1];     // 실적 인터페이스 상세 파라미터
#if false
                    Cursor.Current = Cursors.Default;   //Waitting
                    helper.Rollback();
                    return false;
#endif

                    string sRfcData; //RFC결과 JSON 변환

                    bReturn = false;
                    // 1. 실적 등록 (밀롤 완료 플래그 때문에 마지막에 보냄)
                    if (string.IsNullOrEmpty(sRS_PRFM_RFCFN) == false)
                    {
                        // 문서번호, 문서순번으로  테이블 SORT 하여 전달
                        DataTable dtRFCData = new DataTable();
                        DataView dvPFRM = new DataView(dsTemp.Tables[1]);
                        dvPFRM.Sort = "MDOCNO, MDOCSEQ ASC";
                        dtRFCData = dvPFRM.ToTable();

                        //SAP 실적 등록
                        SAPHelper sapRFC_P = new SAPHelper();
                        // sapRFC.CallSAPFunc 호출시 helper를 사용하여 내용이 변경됨. 
                        // 필요한 정보는 sapRFC.CallSAPFunc 호출전에 처리해야함.
                        if (sapRFC_P.CallSAPFunc(sRS_PRFM_RFCFN, dsTemp.Tables[0], dtRFCData, helper).Equals("S"))
                        {
                            // ---- 전달시 MBLNR, MJAHR을 replace 처리하여 하나로 받도록함.
                            sRfcData = Common.toJsonFormat("PUT_WRKRTN", sapRFC_P.rtnTable).Replace("MBLNR", "RUECK").Replace("MJAHR", "RMZHL");

                            //실적등록 테이블에 확정문서 번호 갱신
                            helper.ExecuteNoneQuery("SP_IF_PUT_WRKRTN", CommandType.StoredProcedure
                                                                , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)          // 플랜트
                                                                , helper.CreateParameter("P_WRK_TYPE", "0", DbType.String, ParameterDirection.Input)                    // '0'= 실적테이블_비계획생산, '1'= 폐품테이블, '2'=소요량, '3'=비가동
                                                                , helper.CreateParameterOracle("P_RFC_DATA", sRfcData, OracleDbType.Clob, ParameterDirection.Input)
                                                                , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input));
                            if (helper.RSCODE == "S")
                            {
                                bReturn = true;
                            }
                            else if (helper.RSCODE == "E")
                            {
                                //helper.Rollback();
                                LogFile.WriteLog("재단 실적 등록 - SAP 확정문서 등록 오류 [" + helper.RSMSG.ToString());
                                new POPUP.MessageForm("실적 등록 - SAP 확정문서 등록 오류\r\n" + helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                            }
                        }
                        else
                        {
                            //helper.Rollback();

                            LogFile.WriteLog("재단 실적 등록 - SAP 전송 실패 [" + sapRFC_P.rtnMSG);
                            new POPUP.MessageForm("실적 - 등록 SAP전송이 실패하였습니다.\r\n" + sapRFC_P.rtnMSG, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                        }
                    }
                    else
                    {
                        bReturn = true;
                    }
                }
                else
                {
                    Cursor.Current = Cursors.Default;   //Waitting

                    //helper.Rollback();
                    LogFile.WriteLog("재단 실적 등록 실패 [" + helper.RSMSG.ToString());
                    new POPUP.MessageForm("실적 등록 실패\r\n" + helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);

                    return false;
                }

                if (bReturn == true)
                {
                    //helper.Commit();

                    PrinterManager.PrintCutter(sRES_IND_BCD);

                    Cursor.Current = Cursors.Default;   //Waitting

                    LogFile.WriteLog("재단 여유생산 실적 등록 성공");
                    new POPUP.MessageForm("실적등록 완료 되었습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                }
                //else
                //{
                //    helper.Rollback();
                //}
            }
            catch (Exception ex)
            {
                Cursor.Current = Cursors.Default;   //Waitting

                //if (bReturn == true)
                //{
                //    helper.Commit();
                //}
                //else
                //{
                //    helper.Rollback();
                //}

                LogFile.WriteLog("재단 실적 등록 예외 오류 [" + ex.Message + "]");
                new POPUP.MessageForm("실적 등록 예외 오류\r\n" + ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
            }
            finally
            {
                Cursor.Current = Cursors.Default;   //Waitting
                helper.Close();
            }

            return bReturn;
        }
#endif
        #endregion
        private void btnConfirm_Click(object sender, EventArgs e)
        {
            if (doProduct() == true)
            {
                this.Close();
            }
        }

        private void btnCancel_Click(object sender, EventArgs e)
        {
            this.Close();
        }


    }
}
