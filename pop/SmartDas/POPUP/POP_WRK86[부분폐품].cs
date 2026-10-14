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

namespace SmartDas.POPUP
{
    public partial class POP_WRK86 : Form
    {
        POPUP.MessageForm msgForm = null;
        DialogResult dr;
        private string sWrkOrdrNo = string.Empty;
        private string sWrkOrdrSeqNo = string.Empty;
        private string sPlantCode = string.Empty;
        private string sMachCode = string.Empty;

        // 플랜트코드, 작업지시번호, 작업지시순번, 업체/개별바코드, OperationType
        public POP_WRK86(string PlantCode, string WrkOrdrNo, string WrkOrdrSeqNo, string MachCode, string IndBcd)
        {
            InitializeComponent();

            sPlantCode = PlantCode;
            sWrkOrdrNo = WrkOrdrNo;
            sWrkOrdrSeqNo = WrkOrdrSeqNo;
            sMachCode = MachCode;
            lblIND_BCD.Text = IndBcd;

            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.Fixed3D;
        }

        public string LabelTitle
        {
            get { return labTitle.Text; }
            set { labTitle.Text = value; }
        }


        private void POP_WRK86_Load(object sender, EventArgs e)
        {
            DoFind();
        }

        private void DoFind()
        {
            DBHelper helper = new DBHelper();
            DataTable dtRtn;

            try
            {
                dtRtn = helper.FillTable("SP_POP_WRK86_S01", CommandType.StoredProcedure
                                                               , helper.CreateParameter("P_WERKS", sPlantCode, DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_WRK_ORDR_NO", sWrkOrdrNo, DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_WRK_ORDR_SEQ", sWrkOrdrSeqNo, DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_MACH_CD", sMachCode, DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_IND_BCD", lblIND_BCD.Text.ToString(), DbType.String, ParameterDirection.Input)
                                                               , helper.CreateParameter("P_USER_ID", Common.UserID, DbType.String, ParameterDirection.Input)
                                                               );
                if (dtRtn.Rows.Count < 1)
                {
                    new POPUP.MessageForm("조회된 작업지시가 없습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return;
                }
                else
                {
                    //자재정보
                    lblMATNR.Text = dtRtn.Rows[0]["MATNR"].ToString();       // 자재코드
                    lblMATNR_NM.Text = dtRtn.Rows[0]["MATNR_NM"].ToString(); // 자재명
                    lblLOT_NO.Text = dtRtn.Rows[0]["LOT_NO"].ToString();     // LotNo
                    lblIND_BCD.Text = dtRtn.Rows[0]["IND_BCD"].ToString();   // 개별바코드
                    //실적정보
                    lblPRFM_PLT.Text = dtRtn.Rows[0]["PRFM_PLT"].ToString(); // 팔레트
                    lblPRFM_BOX.Text = dtRtn.Rows[0]["PRFM_BOX"].ToString(); // 박스
                    lblPRFM_BAG.Text = dtRtn.Rows[0]["PRFM_BAG"].ToString(); // 폴리백
                    lblPRFM_EA.Text = dtRtn.Rows[0]["PRFM_EA"].ToString();   // 개별
                    //부적합정보
                    lblERR_PLT.Text = dtRtn.Rows[0]["DISPO_PLT"].ToString(); // 팔레트
                    lblERR_BOX.Text = dtRtn.Rows[0]["DISPO_BOX"].ToString(); // 박스
                    lblERR_BAG.Text = dtRtn.Rows[0]["DISPO_BAG"].ToString(); // 폴리백
                    lblERR_EA.Text = dtRtn.Rows[0]["DISPO_EA"].ToString();   // 개별
                    ////실적정보
                    //lblPRFM_PLT.Text = string.Format("{0:#,###}", dtRtn.Rows[0]["PRFM_PLT"]); // 팔레트
                    //lblPRFM_BOX.Text = string.Format("{0:#,###}", dtRtn.Rows[0]["PRFM_BOX"]); // 박스
                    //lblPRFM_BAG.Text = string.Format("{0:#,###}", dtRtn.Rows[0]["PRFM_BAG"]); // 폴리백
                    //lblPRFM_EA.Text = string.Format("{0:#,###}", dtRtn.Rows[0]["PRFM_EA"]);   // 개별
                    //변환정보
                    lblERR_PLT.Tag = dtRtn.Rows[0]["PLT_RATE"].ToString(); // 팔레트
                    lblERR_BOX.Tag = dtRtn.Rows[0]["BOX_RATE"].ToString(); // 박스
                    lblERR_BAG.Tag = dtRtn.Rows[0]["BAG_RATE"].ToString(); // 폴리백
                    lblERR_EA.Tag = dtRtn.Rows[0]["EA_RATE"].ToString();   // 개별
                }
            }
            catch (Exception ex)
            {
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                LogFile.WriteLog("POP_WRK08.WRK_ORDER Find Error => " + ex.Message);
            }
            finally
            {
                helper.Close();
                //lblERR_BOX.Text = "";
            }
        }

        // 2022-12-11 이성민
        // 부분폐품 구조 변경 시행
        // 버튼은 재팔래트 1개만 사용
        // 변경된 프로세스(최종) : 기존 실적 취소 -> 부분폐품양 만큼 실적등록 -> 자재이동(불용창고)
        // 구조 2차 변경(2022-12-12)으로 최하단 RFC함수인 양품실적은 작동하지 않음(프로시저 주석처리)
        // 라벨은 부분폐품 라벨 출력
        // 롤백은 트랜젝션 롤백 및 시행 RFC 역순으로 취소 RFC 시행
        // 이력 및 로그는 TB_WRK030(트랜젝션 롤백 로그체크용 테이블) 테이블을 조회해서 모니터링 할 것
        private void doUpdate(string PRFMProc)
        {
            DBHelper helper = new DBHelper(false, "", true);
            string sErrQty = PRFMProc != "R" ? lblERR_BAG.Text.ToString().Replace(",", "").Trim() : lblPRFM_BAG.Text.ToString().Replace(",", "").Trim();
            string sUserId = Common.UserID;
            string sPRFMCNLFunc = string.Empty;
            string sPRFMFunc = string.Empty;
            string sDISPOFunc = string.Empty;
            string sUSEFunc = string.Empty;
            string sMOVEFunc = string.Empty;
            string sResult = string.Empty;
            string sClickName = string.Empty;

            int iDispoQty;
            DataSet dsTemp_D = new DataSet(); ;
            DataSet dsTemp = new DataSet();
            DataTable dtTemp;
            DataSet dsLabel = new DataSet(); //라벨양식
            DataSet dsTemp_CNL = new DataSet(); //실적 취소 RFC Data
            DataSet dsDISPO = new DataSet(); //폐품 등록 RFC Data
            DataSet dsMOVE = new DataSet(); //재고이전 등록 RFC Data
            DataSet dsPRFM = new DataSet(); //양품ㅡ 등록 RFC Data
            DialogResult res = DialogResult.Cancel;


            if (PRFMProc.Equals("R"))
            {

            }
            else
            {
                sClickName = "폐품 등록이";
                if (sErrQty.Length == 0)
                {
                    return;
                }
                else if (int.TryParse(sErrQty, out iDispoQty) == false)
                {
                    new POPUP.MessageForm("폐품 수량 입력오류", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return;
                }
                else if (iDispoQty == 0)
                {
                    sClickName = "재팔레트가";
                    msgForm = new POPUP.MessageForm("재팔레트 시 대상 실적이 전량 취소됩니다." + Environment.NewLine + "진행하시겠습니까?", MessageBoxButtons.OKCancel, "알   림");
                    res = msgForm.ShowDialog(this);
                    if (res != DialogResult.OK)
                    {
                        return;
                    }
                    PRFMProc = "R";
                }
            }



            
            //rollback용 
            //SAP 롤백용 추가 CODE 범위 START
            DataTable sapTemp = new DataTable(); // 성공한 sap 정보 저장
            //SAP 롤백용 추가 CODE 범위 END
            //rollback용 end

            try
            {
                this.Cursor = Cursors.WaitCursor;   //Waitting

                //rollback용 
                //SAP 롤백용 추가 CODE 범위 START
                sapTemp = new DataTable();
                sapTemp.Columns.Add("SAP_TYPE", typeof(string));
                sapTemp.Columns.Add("IF_KEY", typeof(string));
                sapTemp.Columns.Add("MDOCNO", typeof(string));
                sapTemp.Columns.Add("MDOCSEQ", typeof(string));
                sapTemp.Columns.Add("SDOC_NO", typeof(string));
                sapTemp.Columns.Add("SDOC_SEQNO", typeof(string));
                //SAP 롤백용 추가 CODE 범위 END
                //rollback용 end

                //기존 실적 취소처리
                dsTemp_D = helper.FillDataSetN("SP_POP_WRK86_D01", CommandType.StoredProcedure, 2
                                                               , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)       // 플랜트코드
                                                               , helper.CreateParameter("P_WRK_ORDR_NO", sWrkOrdrNo, DbType.String, ParameterDirection.Input)     // 작업지시번호
                                                               , helper.CreateParameter("P_WRK_ORDR_SEQNO", sWrkOrdrSeqNo, DbType.String, ParameterDirection.Input)   // 작업지시순번
                                                               , helper.CreateParameter("P_MACH_CD", sMachCode, DbType.String, ParameterDirection.Input)    // 설비코드
                                                               , helper.CreateParameter("P_IND_BCD", lblIND_BCD.Text, DbType.String, ParameterDirection.Input)    // 업체/개별바코드
                                                               , helper.CreateParameter("P_USER_ID", sUserId, DbType.String, ParameterDirection.Input)  // 사용자ID
                                                               , helper.CreateParameter("P_PRFM_CNL_FUNC", DbType.String, ParameterDirection.Output, null, 30)
                                                                );
                if (helper.RSCODE == "S")
                {
                    sPRFMCNLFunc = helper.Parameters["P_PRFM_CNL_FUNC"].Value.ToString();
                    //실적취소 전송 Data
                    dtTemp = dsTemp_D.Tables[0].Copy();
                    dsTemp_CNL.Tables.Add(dtTemp);
                    dtTemp = dsTemp_D.Tables[1].Copy();
                    dsTemp_CNL.Tables.Add(dtTemp);
                }
                else
                {
                    msgForm = new POPUP.MessageForm(helper.RSMSG, MessageBoxButtons.OK, "알   림");
                    dr = msgForm.ShowDialog(this);
                    helper.Rollback();
                    return;
                }

                //실적 취소처리
                if (!dsTemp_CNL.Tables[0].Rows[0][0].ToString().Equals("1"))
                {
                    SAPHelper sapRFC_D = new SAPHelper();
                    if (!sapRFC_D.CallSAPFunc_HL(sPRFMCNLFunc, dsTemp_CNL.Tables[0], dsTemp_CNL.Tables[1], helper).Equals("S"))
                    {
                        throw new Exception("실적취소 SAP전송이 실패하였습니다.\n" + sapRFC_D.rtnMSG);
                    }
                    //rollback용
                    //SAP 롤백용 추가 CODE 범위 START
                    string sTempSAP_TYPE = string.Empty;
                    string sTempIF_KEY = string.Empty;
                    string sTempMDOC_NO = string.Empty;
                    string sTempMDOC_SEQNO = string.Empty;
                    sTempSAP_TYPE = "3.CANCLE_REG_SAP";

                    sTempIF_KEY = dsTemp_D.Tables[0].Rows[0]["I_IF_KEY"].ToString();

                    foreach (DataRow Rows in dsTemp_D.Tables[1].Rows)
                    {
                        sTempMDOC_NO = Rows["MDOCNO"].ToString();
                        sTempMDOC_SEQNO = Rows["MDOCSEQ"].ToString();
                        sapTemp.Rows.Add(sTempSAP_TYPE, sTempIF_KEY, sTempMDOC_NO, sTempMDOC_SEQNO, sapRFC_D.rtnTable.Rows[0]["RUECK"].ToString(), sapRFC_D.rtnTable.Rows[0]["RMZHL"].ToString()); // 후단 코드 실행시 EXCEPTION 상황 SAP CANCLE 정보 -- 실적등록
                    }
                    //SAP 롤백용 추가 CODE 범위 END
                    //rollback용 end
                }
                if (PRFMProc.Equals("A"))
                {

                    //부적합 실적 및 양품 실적 등록
                    dsTemp = helper.FillDataSetN("SP_POP_WRK86_U01", CommandType.StoredProcedure, 8
                                                                   , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)       // 플랜트코드
                                                                   , helper.CreateParameter("P_WRK_ORDR_NO", sWrkOrdrNo, DbType.String, ParameterDirection.Input)     // 작업지시번호
                                                                   , helper.CreateParameter("P_WRK_ORDR_SEQNO", sWrkOrdrSeqNo, DbType.String, ParameterDirection.Input)   // 작업지시순번
                                                                   , helper.CreateParameter("P_MACH_CD", sMachCode, DbType.String, ParameterDirection.Input)    // 설비코드
                                                                   , helper.CreateParameter("P_IND_BCD", lblIND_BCD.Text, DbType.String, ParameterDirection.Input)    // 업체/개별바코드
                                                                   , helper.CreateParameter("P_DISPO_QTY", sErrQty, DbType.String, ParameterDirection.Input)    // 부적합 수량
                                                                   , helper.CreateParameter("P_USER_ID", sUserId, DbType.String, ParameterDirection.Input)  // 사용자ID
                                                                   , helper.CreateParameter("P_TYPE", PRFMProc, DbType.String, ParameterDirection.Input)  // 전량 부분여부
                                                                   , helper.CreateParameter("P_PRFM_FUNC", DbType.String, ParameterDirection.Output, null, 30)
                                                                   , helper.CreateParameter("P_DISPO_FUNC", DbType.String, ParameterDirection.Output, null, 30)
                                                                   , helper.CreateParameter("P_MOVE_FUNC", DbType.String, ParameterDirection.Output, null, 30)
                                                                    );

                    if (helper.RSCODE == "S")
                    {
                        sPRFMFunc = helper.Parameters["P_PRFM_FUNC"].Value.ToString();
                        sDISPOFunc = helper.Parameters["P_DISPO_FUNC"].Value.ToString();
                        sMOVEFunc = helper.Parameters["P_MOVE_FUNC"].Value.ToString();

                        //라벨양식 Data
                        dtTemp = dsTemp.Tables[0].Copy();       // 폐품실적 라벨양식
                        dsLabel.Tables.Add(dtTemp);
                        dtTemp = dsTemp.Tables[1].Copy();       // 남은 양품실적 라벨양식
                        dsLabel.Tables.Add(dtTemp);
                        //부적합 실적 Data
                        dtTemp = dsTemp.Tables[4].Copy();
                        dsDISPO.Tables.Add(dtTemp);
                        dtTemp = dsTemp.Tables[5].Copy();
                        dsDISPO.Tables.Add(dtTemp);
                        //재고이전 Data
                        dtTemp = dsTemp.Tables[6].Copy();
                        dsMOVE.Tables.Add(dtTemp);
                        dtTemp = dsTemp.Tables[7].Copy();
                        dsMOVE.Tables.Add(dtTemp);
                        //양품실적 Data
                        dtTemp = dsTemp.Tables[2].Copy();
                        dsPRFM.Tables.Add(dtTemp);
                        dtTemp = dsTemp.Tables[3].Copy();
                        dsPRFM.Tables.Add(dtTemp);
                    }
                    else
                    {
                        msgForm = new POPUP.MessageForm(helper.RSMSG, MessageBoxButtons.OK, "알   림");
                        dr = msgForm.ShowDialog(this);
                        helper.Rollback();
                        return;
                    }

                    //부적합 실적 등록
                    if (!dsDISPO.Tables[0].Rows[0][0].ToString().Equals("1"))
                    {
                        //부적합실적 등록
                        SAPHelper sapRFC = new SAPHelper();
                        if (sapRFC.CallSAPFunc_HL(sDISPOFunc, dsDISPO.Tables[0], dsDISPO.Tables[1], helper).Equals("S"))
                        {
                            sapRFC.SaveResulttoWrk_HL(helper, "POP_WRK086", "0");
                            //rollback용
                            //SAP 롤백용 추가 CODE 범위 START
                            string sTempSAP_TYPE = string.Empty;
                            string sTempIF_KEY = string.Empty;
                            string sTempMDOC_NO = string.Empty;
                            string sTempMDOC_SEQNO = string.Empty;
                            sTempSAP_TYPE = "2.PROD_REG_SAP";
                            sTempIF_KEY = dsTemp.Tables[4].Rows[0]["I_IF_KEY"].ToString();

                            string sSDOC_ColunmName = string.Empty;
                            string sSDOCNO_ColunmName = string.Empty;
                            if (sapRFC.rtnTable.Columns.Contains("MBLNR"))
                            {
                                sSDOC_ColunmName = "MBLNR";
                                sSDOCNO_ColunmName = "MJAHR";
                            }
                            else
                            {
                                sSDOC_ColunmName = "RUECK";
                                sSDOCNO_ColunmName = "RMZHL";
                            }

                            if (!dsTemp.Tables[5].Columns.Contains("SDOC_NO") && !dsTemp.Tables[5].Columns.Contains("SDOC_SEQNO"))
                            {
                                dsTemp.Tables[5].Columns.Add("SDOC_NO", typeof(string));
                                dsTemp.Tables[5].Columns.Add("SDOC_SEQNO", typeof(string));
                            }
                            foreach (DataRow Rows in dsTemp.Tables[5].Rows)
                            {
                                sTempMDOC_NO = Rows["MDOCNO"].ToString();
                                sTempMDOC_SEQNO = Rows["MDOCSEQ"].ToString();
                                sapTemp.Rows.Add(sTempSAP_TYPE, sTempIF_KEY, sTempMDOC_NO, sTempMDOC_SEQNO, "", ""); // 후단 코드 실행시 EXCEPTION 상황 SAP CANCLE 정보 -- 실적등록
                                foreach (DataRow rfcRows in sapRFC.rtnTable.Rows)
                                {
                                    string sMBLNRtemp = string.Empty;
                                    string sMJAHRtemp = string.Empty;
                                    sMBLNRtemp = rfcRows[sSDOC_ColunmName].ToString();
                                    sMJAHRtemp = rfcRows[sSDOCNO_ColunmName].ToString();
                                    if (Rows["MDOCNO"].ToString() == rfcRows["MDOCNO"].ToString() && Convert.ToInt32(Rows["MDOCSEQ"].ToString()) == Convert.ToInt32(rfcRows["MDOCSEQ"].ToString()))
                                    {
                                        Rows["SDOC_NO"] = sMBLNRtemp;
                                        Rows["SDOC_SEQNO"] = sMJAHRtemp;
                                    }
                                }
                            }
                            //SAP 롤백용 추가 CODE 범위 END
                            //rollback용 end

                            //부적합 라벨 출력

                        }
                        else
                        {
                            throw new Exception("폐품실적 SAP전송이 실패하였습니다.\n" + sapRFC.rtnMSG);
                        }
                    }

                    //자재 이동
                    if (!dsMOVE.Tables[0].Rows[0][0].ToString().Equals("1"))//라벨, 실적헤더, 실적상세, 재고이전헤더, 재고이전상세, 자재소요량, 자재소요량상세
                    {
                        Thread.Sleep(1500);
                        SAPHelper sapRFC_M = new SAPHelper();
                        if (sapRFC_M.CallSAPFunc_HL(sMOVEFunc, dsMOVE.Tables[0], dsMOVE.Tables[1], helper).Equals("S"))
                        {
                            //rollback용
                            //SAP 롤백용 추가 CODE 범위 START
                            string sTempSAP_TYPE = string.Empty;
                            string sTempIF_KEY = string.Empty;
                            string sTempMDOC_NO = string.Empty;
                            string sTempMDOC_SEQNO = string.Empty;
                            sTempSAP_TYPE = "1.MOVE_REG_SAP";
                            sTempIF_KEY = dsTemp.Tables[6].Rows[0]["I_IF_KEY"].ToString();

                            string sSDOC_ColunmName = string.Empty;
                            string sSDOCNO_ColunmName = string.Empty;
                            if (sapRFC_M.rtnTable.Columns.Contains("MBLNR"))
                            {
                                sSDOC_ColunmName = "MBLNR";
                                sSDOCNO_ColunmName = "MJAHR";
                            }
                            else
                            {
                                sSDOC_ColunmName = "RUECK";
                                sSDOCNO_ColunmName = "RMZHL";
                            }
                            if (!dsTemp.Tables[7].Columns.Contains("SDOC_NO") && !dsTemp.Tables[7].Columns.Contains("SDOC_SEQNO"))
                            {
                                dsTemp.Tables[7].Columns.Add("SDOC_NO", typeof(string));
                                dsTemp.Tables[7].Columns.Add("SDOC_SEQNO", typeof(string));
                            }
                            foreach (DataRow Rows in dsTemp.Tables[7].Rows)
                            {
                                sTempMDOC_NO = Rows["MDOCNO"].ToString();
                                sTempMDOC_SEQNO = Rows["MDOCSEQ"].ToString();
                                sapTemp.Rows.Add(sTempSAP_TYPE, sTempIF_KEY, sTempMDOC_NO, sTempMDOC_SEQNO, "", ""); // 후단 코드 실행시 EXCEPTION 상황 SAP CANCLE 정보 -- 실적등록
                                foreach (DataRow rfcRows in sapRFC_M.rtnTable.Rows)
                                {
                                    string sMBLNRtemp = string.Empty;
                                    string sMJAHRtemp = string.Empty;
                                    sMBLNRtemp = rfcRows[sSDOC_ColunmName].ToString();
                                    sMJAHRtemp = rfcRows[sSDOCNO_ColunmName].ToString();
                                    if (Rows["MDOCNO"].ToString() == rfcRows["MDOCNO"].ToString() && Convert.ToInt32(Rows["MDOCSEQ"].ToString()) == Convert.ToInt32(rfcRows["MDOCSEQ"].ToString()))
                                    {
                                        Rows["SDOC_NO"] = sMBLNRtemp;
                                        Rows["SDOC_SEQNO"] = sMJAHRtemp;
                                    }
                                }
                            }
                            //SAP 롤백용 추가 CODE 범위 END
                            //rollback용 end
                        }
                        else
                        {
                            throw new Exception("자재이동 SAP전송이 실패하였습니다.\n" + sapRFC_M.rtnMSG);

                        }
                    }

                    //양품 실적 등록 -- 구조 2차변경 시행, 양품실적등록은 타지 않음
                    if (!dsPRFM.Tables[0].Rows[0][0].ToString().Equals("1"))//라벨, 실적헤더, 실적상세, 재고이전헤더, 재고이전상세, 자재소요량, 자재소요량 상세
                    {
                        //연속처리시 에러가 발생하여 지연 추가
                        Thread.Sleep(1000);
                        SAPHelper sapRFC_P = new SAPHelper();
                        if (sapRFC_P.CallSAPFunc_HL(sPRFMFunc, dsPRFM.Tables[0], dsPRFM.Tables[1], helper).Equals("S"))
                        {
                            sapRFC_P.SaveResulttoWrk_HL(helper, "POP_WRK086", "0");

                            //rollback용
                            //SAP 롤백용 추가 CODE 범위 START
                            string sTempSAP_TYPE = string.Empty;
                            string sTempIF_KEY = string.Empty;
                            string sTempMDOC_NO = string.Empty;
                            string sTempMDOC_SEQNO = string.Empty;
                            sTempSAP_TYPE = "2.PROD_REG_SAP";
                            sTempIF_KEY = dsTemp.Tables[2].Rows[0]["I_IF_KEY"].ToString();

                            string sSDOC_ColunmName = string.Empty;
                            string sSDOCNO_ColunmName = string.Empty;
                            if (sapRFC_P.rtnTable.Columns.Contains("MBLNR"))
                            {
                                sSDOC_ColunmName = "MBLNR";
                                sSDOCNO_ColunmName = "MJAHR";
                            }
                            else
                            {
                                sSDOC_ColunmName = "RUECK";
                                sSDOCNO_ColunmName = "RMZHL";
                            }

                            if (!dsTemp.Tables[3].Columns.Contains("SDOC_NO") && !dsTemp.Tables[3].Columns.Contains("SDOC_SEQNO"))
                            {
                                dsTemp.Tables[3].Columns.Add("SDOC_NO", typeof(string));
                                dsTemp.Tables[3].Columns.Add("SDOC_SEQNO", typeof(string));
                            }
                            foreach (DataRow Rows in dsTemp.Tables[3].Rows)
                            {
                                sTempMDOC_NO = Rows["MDOCNO"].ToString();
                                sTempMDOC_SEQNO = Rows["MDOCSEQ"].ToString();
                                sapTemp.Rows.Add(sTempSAP_TYPE, sTempIF_KEY, sTempMDOC_NO, sTempMDOC_SEQNO, "", ""); // 후단 코드 실행시 EXCEPTION 상황 SAP CANCLE 정보 -- 실적등록
                                foreach (DataRow rfcRows in sapRFC_P.rtnTable.Rows)
                                {
                                    string sMBLNRtemp = string.Empty;
                                    string sMJAHRtemp = string.Empty;
                                    sMBLNRtemp = rfcRows[sSDOC_ColunmName].ToString();
                                    sMJAHRtemp = rfcRows[sSDOCNO_ColunmName].ToString();
                                    if (Rows["MDOCNO"].ToString() == rfcRows["MDOCNO"].ToString() && Convert.ToInt32(Rows["MDOCSEQ"].ToString()) == Convert.ToInt32(rfcRows["MDOCSEQ"].ToString()))
                                    {
                                        Rows["SDOC_NO"] = sMBLNRtemp;
                                        Rows["SDOC_SEQNO"] = sMJAHRtemp;
                                    }
                                }
                            }
                            //SAP 롤백용 추가 CODE 범위 END
                            //rollback용 end
                        }
                        else
                        {
                            throw new Exception("양품실적 SAP전송이 실패하였습니다.\n" + sapRFC_P.rtnMSG);
                        }


                    }

                    if (dsLabel.Tables.Count != 0)
                    {
                        if (!dsLabel.Tables[1].Rows[0][0].ToString().Equals("1"))
                        {
                            doPrint(dsLabel.Tables[1]);
                        }
                        if (!dsLabel.Tables[0].Rows[0][0].ToString().Equals("1"))
                        {
                            doPrint(dsLabel.Tables[0]);
                        }
                    }
                }

                msgForm = new POPUP.MessageForm(sClickName + " 완료되었습니다.", MessageBoxButtons.OK, "알   림");
                dr = msgForm.ShowDialog(this);
                this.DialogResult = System.Windows.Forms.DialogResult.OK;

            }
            catch (Exception ex)
            {
                sResult = "ROLLBACK";
                RollbackLog(helper, dsTemp, dsTemp_D, ex.Message, sResult, false);
                ProdRollback_HL(helper, sapTemp, dsTemp);
                helper.Rollback();
                ProdRollback_HL_Prod(helper, sapTemp, dsTemp);
                helper.Commit();
                this.Cursor = Cursors.Default;   //Waitting

                string sRollBackMsg = ex.Message + Environment.NewLine + "MES ROLLBACK 부분폐품 취소되었습니다";
                new POPUP.MessageForm_ERR("알   림", sRollBackMsg, MessageBoxButtons.OK).ShowDialog(this);
            }
            finally
            {
                this.Cursor = Cursors.Default;   //Waitting
                helper.Close();
                DoFind();
                this.DialogResult = System.Windows.Forms.DialogResult.OK;
            }
        }


        private void ProdRollback_HL(DBHelper helper, DataTable sapTemp, DataSet dsTemp)
        {
            try
            {
                if (sapTemp.Rows.Count != 0)
                {
                    string sMSG_ERR = string.Empty;
                    string sResult = string.Empty;
                    sapTemp = sapTemp.Select("", "SAP_TYPE ASC").CopyToDataTable<DataRow>();
                    foreach (DataRow Rows in sapTemp.Rows)
                    {
                        switch (Rows["SAP_TYPE"].ToString())
                        {
                            case "1.MOVE_REG_SAP":
                                dsTemp = helper.FillDataSetN("SP_POP_WRK86_IFR02", CommandType.StoredProcedure, 2
                                       , helper.CreateParameter("P_DOC_NO", Rows["MDOCNO"].ToString(), DbType.String, ParameterDirection.Input)
                                       , helper.CreateParameter("P_DOC_SEQNO", Rows["MDOCSEQ"].ToString(), DbType.String, ParameterDirection.Input)
                                       , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input)
                                       , helper.CreateParameter("RS_RFCFN", DbType.String, ParameterDirection.Output, null, 30)
                                        );

                                if (helper.RSCODE == "S")
                                {
                                    string sRS_RFCFN_1 = helper.Parameters["RS_RFCFN"].Value.ToString();
                                    SAPHelper sapRFC_1 = new SAPHelper();
                                    if (sapRFC_1.CallSAPFunc_HL(sRS_RFCFN_1, dsTemp.Tables[0], dsTemp.Tables[1], helper).Equals("S"))
                                    {
                                        LogFile.WriteLog("HL 재고이동 ROLLBACK [" + helper.RSMSG.ToString() + "]");
                                        sMSG_ERR = "HL 재고이동 ROLLBACK [" + helper.RSMSG.ToString() + "]";

                                        sResult = "S";
                                    }
                                    else
                                    {
                                        LogFile.WriteLog("HL ROLLBACK 오류 - SAP전송 오류 [" + sapRFC_1.rtnMSG + "]");
                                        sMSG_ERR = "HL ROLLBACK 오류 : " + sapRFC_1.rtnMSG + Environment.NewLine;
                                        sResult = "E";
                                    }
                                }
                                else //if (helper.RSCODE == "E")
                                {
                                    LogFile.WriteLog("HL ROLLBACK 등록 - MES IF TABLE 등록 오류 [" + helper.RSMSG.ToString() + "]");
                                    sMSG_ERR = "ROLLBACK MES IF TABLE 등록 오류 : " + helper.RSMSG.ToString() + Environment.NewLine;
                                    sResult = "E";
                                }
                                
                                RollbackLog(helper, dsTemp, null, sMSG_ERR, sResult, true);
                                Thread.Sleep(1000);
                                break;
                            case "2.PROD_REG_SAP":
                                dsTemp = helper.FillDataSetN("SP_POP_WRK86_IFR01", CommandType.StoredProcedure, 2
                                       , helper.CreateParameter("P_DOC_NO", Rows["MDOCNO"].ToString(), DbType.String, ParameterDirection.Input)
                                       , helper.CreateParameter("P_DOC_SEQNO", Rows["MDOCSEQ"].ToString(), DbType.String, ParameterDirection.Input)
                                       , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input)
                                       , helper.CreateParameter("RS_RFCFN", DbType.String, ParameterDirection.Output, null, 30)
                                        );

                                if (helper.RSCODE == "S")
                                {
                                    string sRS_RFCFN_2 = helper.Parameters["RS_RFCFN"].Value.ToString();
                                    SAPHelper sapRFC_2 = new SAPHelper();
                                    if (sapRFC_2.CallSAPFunc_HL(sRS_RFCFN_2, dsTemp.Tables[0], dsTemp.Tables[1], helper).Equals("S"))
                                    {
                                        LogFile.WriteLog("HL 폐품실적등록 ROLLBACK [" + helper.RSMSG.ToString() + "]");
                                        sMSG_ERR = "HL 폐품실적등록 ROLLBACK [" + helper.RSMSG.ToString() + "]";
                                        sResult = "S";
                                    }
                                    else
                                    {
                                        LogFile.WriteLog("HL ROLLBACK 오류 - SAP전송 오류 [" + sapRFC_2.rtnMSG + "]");
                                        sMSG_ERR = "HL ROLLBACK 오류 : " + sapRFC_2.rtnMSG + Environment.NewLine;
                                        sResult = "E";
                                    }
                                }
                                else //if (helper.RSCODE == "E")
                                {
                                    LogFile.WriteLog("HL ROLLBACK 등록 - MES IF TABLE 등록 오류 [" + helper.RSMSG.ToString() + "]");
                                    sMSG_ERR = "ROLLBACK MES IF TABLE 등록 오류 : " + helper.RSMSG.ToString() + Environment.NewLine;
                                    sResult = "E";
                                }
                                RollbackLog(helper, dsTemp, null, sMSG_ERR, sResult, true);
                                Thread.Sleep(1000);
                                break;
                            default:
                                break;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                LogFile.WriteLog("HL ROLLBACK 에러 Exception 발생 [" + ex.Message + "]");
            }
        }


        private void ProdRollback_HL_Prod(DBHelper helper, DataTable sapTemp, DataSet dsTemp)// 실적 재등록 롤백용 트랜젝션 롤백 후 신규트랜젝션 시행
        {
            try
            {
                if (sapTemp.Rows.Count != 0)
                {
                    string sMSG_ERR = string.Empty;
                    string sResult = string.Empty;
                    sapTemp = sapTemp.Select("", "SAP_TYPE ASC").CopyToDataTable<DataRow>();
                    foreach (DataRow Rows in sapTemp.Rows)
                    {
                        switch (Rows["SAP_TYPE"].ToString())
                        {
                             case "3.CANCLE_REG_SAP":
                                dsTemp = helper.FillDataSetN("SP_POP_WRK86_IFR03", CommandType.StoredProcedure, 2
                                       , helper.CreateParameter("P_SDOC_NO", Rows["SDOC_NO"].ToString(), DbType.String, ParameterDirection.Input)
                                       , helper.CreateParameter("P_SDOC_SEQNO", Rows["SDOC_SEQNO"].ToString(), DbType.String, ParameterDirection.Input)
                                       , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input)
                                       , helper.CreateParameter("RS_RFCFN", DbType.String, ParameterDirection.Output, null, 30)
                                        );

                                if (helper.RSCODE == "S")
                                {
                                    string sRS_RFCFN_3 = helper.Parameters["RS_RFCFN"].Value.ToString();
                                    SAPHelper sapRFC_3 = new SAPHelper();
                                    if (sapRFC_3.CallSAPFunc_HL(sRS_RFCFN_3, dsTemp.Tables[0], dsTemp.Tables[1], helper).Equals("S"))
                                    {
                                        sapRFC_3.SaveResulttoWrk_HL(helper, "POP_WRK086", "0");

                                        LogFile.WriteLog("HL 실적취소 ROLLBACK [" + helper.RSMSG.ToString() + "]");
                                        sMSG_ERR = "HL 실적취소 ROLLBACK [" + helper.RSMSG.ToString() + "]";
                                        sResult = "S";
                                    }
                                    else
                                    {
                                        LogFile.WriteLog("HL ROLLBACK 오류 - SAP전송 오류 [" + sapRFC_3.rtnMSG + "]");
                                        sMSG_ERR = "HL ROLLBACK 오류 : " + sapRFC_3.rtnMSG + Environment.NewLine;
                                        sResult = "E";
                                    }
                                }
                                else //if (helper.RSCODE == "E")
                                {
                                    LogFile.WriteLog("HL ROLLBACK 등록 - MES IF TABLE 등록 오류 [" + helper.RSMSG.ToString() + "]");
                                    sMSG_ERR = "ROLLBACK MES IF TABLE 등록 오류 : " + helper.RSMSG.ToString() + Environment.NewLine;
                                    sResult = "E";
                                }

                                RollbackLog(helper, dsTemp, null, sMSG_ERR, sResult, true);
                                break;
                            default:
                                break;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                LogFile.WriteLog("HL ROLLBACK 에러 Exception 발생 [" + ex.Message + "]");
            }
        }

        private void RollbackLog(DBHelper helper, DataSet dsTemp, DataSet dsTemp_D, string sMSG_ERR, string sResult, bool sapRollbackLogFlag)
        {
            try
            {
                if (sapRollbackLogFlag)// sap 롤백에 대한 로그 저장
                {
                    if (dsTemp.Tables.Count == 0) return;
                    if (dsTemp.Tables[1] != null)
                    {
                        if (dsTemp.Tables[1].Rows.Count > 0) //롤백 수행 로그 저장(실적등록, 자재이동, 실적취소)
                        {
                            if (dsTemp.Tables[1].Rows[0][0].ToString() != "1") //롤백 수행 로그 저장(실적등록, 자재이동, 실적취소)
                            {
                                string sLOTColunmCHK = dsTemp.Tables[1].Columns.Contains("LOTNO") ? "LOTNO" : "CHARG";
                                foreach (DataRow Rows in dsTemp.Tables[1].Rows)
                                {
                                    helper.ExecuteNoneQuery("SP_HL_ROLLBACK_LOG", CommandType.StoredProcedure
                                        , helper.CreateParameter("P_DOC_NO", dsTemp.Tables[1].Columns.Contains("MDOCNO") ? Rows["MDOCNO"] : "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_DOC_SEQNO", dsTemp.Tables[1].Columns.Contains("MDOCSEQ") ? Rows["MDOCSEQ"] : "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_LOT_NO", dsTemp.Tables[1].Columns.Contains(sLOTColunmCHK) ? Rows[sLOTColunmCHK] : "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_ORDER_NO", dsTemp.Tables[1].Columns.Contains("AUFNR") ? Rows["AUFNR"] : "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_WORKCENTERCODE", dsTemp.Tables[1].Columns.Contains("WORKCENTERCODE") ? Rows["WORKCENTERCODE"] : "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_MACH_CD", "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_PRDCD", "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_QTY", dsTemp.Tables[1].Columns.Contains("PROQTY") ? Rows["PROQTY"] : "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_MATNR", dsTemp.Tables[1].Columns.Contains("MATNR") ? Rows["MATNR"] : "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_BUDAT", "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_RESULT", sResult, DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_REMARK", sMSG_ERR, DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_MBLNR", "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_MJAHR", "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_I_IF_ID", dsTemp.Tables[0].Rows[0]["I_IF_ID"].ToString(), DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input));
                                }
                            }
                        }
                    }
                }
                else  // sap 롤백발생원인에 대한 저장
                {
                    if (dsTemp.Tables.Count == 0) return;
                    if (dsTemp.Tables[3] != null)
                    {
                        if (dsTemp.Tables[3].Rows.Count > 0)
                        {
                            if (dsTemp.Tables[3].Rows[0][0].ToString() != "1")
                            {
                                foreach (DataRow Rows in dsTemp.Tables[3].Rows)//실적등록 및 자재이동, 실적취소 실패시 롤백 발생원인 저장 - 실적등록 로그
                                {
                                    helper.ExecuteNoneQuery("SP_HL_ROLLBACK_LOG", CommandType.StoredProcedure
                                    , helper.CreateParameter("P_DOC_NO", dsTemp.Tables[3].Columns.Contains("MDOCNO") ? Rows["MDOCNO"] : "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_DOC_SEQNO", dsTemp.Tables[3].Columns.Contains("MDOCSEQ") ? Rows["MDOCSEQ"] : "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_LOT_NO", dsTemp.Tables[3].Columns.Contains("LOTNO") ? Rows["LOTNO"] : "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_ORDER_NO", dsTemp.Tables[3].Columns.Contains("AUFNR") ? Rows["AUFNR"] : "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_WERKS", dsTemp.Tables[3].Columns.Contains("WERKS") ? Rows["WERKS"] : "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_WORKCENTERCODE", dsTemp.Tables[3].Columns.Contains("WORKCENTERCODE") ? Rows["WORKCENTERCODE"] : "".ToString(), DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_MACH_CD", dsTemp.Tables[3].Columns.Contains("MACHINE") ? Rows["MACHINE"] : "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_PRDCD", "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_QTY", dsTemp.Tables[3].Columns.Contains("PROQTY") ? Rows["PROQTY"] : "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_MATNR", dsTemp.Tables[3].Columns.Contains("MATNR") ? Rows["MATNR"] : "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_BUDAT", dsTemp.Tables[3].Columns.Contains("BUDAT") ? Rows["BUDAT"] : "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_RESULT", sResult, DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_REMARK", sMSG_ERR, DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_MBLNR", dsTemp.Tables[3].Columns.Contains("SDOC_NO") ? Rows["SDOC_NO"] : "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_MJAHR", dsTemp.Tables[3].Columns.Contains("SDOC_SEQNO") ? Rows["SDOC_SEQNO"] : "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_I_IF_ID", dsTemp.Tables[2].Rows[0]["I_IF_ID"].ToString(), DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input));
                                }
                            }
                        }

                    }
                    if (dsTemp.Tables.Count == 0) return;
                    if (dsTemp.Tables[5] != null)
                    {
                        if (dsTemp.Tables[5].Rows.Count > 0)
                        {
                            if (dsTemp.Tables[5].Rows[0][0].ToString() != "1")
                            {
                                foreach (DataRow Rows in dsTemp.Tables[5].Rows)//실적등록 및 자재이동, 실적취소 실패시 롤백 발생원인 저장 - 실적등록 로그
                                {
                                    helper.ExecuteNoneQuery("SP_HL_ROLLBACK_LOG", CommandType.StoredProcedure
                                    , helper.CreateParameter("P_DOC_NO", dsTemp.Tables[5].Columns.Contains("MDOCNO") ? Rows["MDOCNO"] : "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_DOC_SEQNO", dsTemp.Tables[5].Columns.Contains("MDOCSEQ") ? Rows["MDOCSEQ"] : "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_LOT_NO", dsTemp.Tables[5].Columns.Contains("LOTNO") ? Rows["LOTNO"] : "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_ORDER_NO", dsTemp.Tables[5].Columns.Contains("AUFNR") ? Rows["AUFNR"] : "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_WERKS", dsTemp.Tables[5].Columns.Contains("WERKS") ? Rows["WERKS"] : "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_WORKCENTERCODE", dsTemp.Tables[5].Columns.Contains("WORKCENTERCODE") ? Rows["WORKCENTERCODE"] : "".ToString(), DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_MACH_CD", dsTemp.Tables[5].Columns.Contains("MACHINE") ? Rows["MACHINE"] : "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_PRDCD", "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_QTY", dsTemp.Tables[5].Columns.Contains("PROQTY") ? Rows["PROQTY"] : "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_MATNR", dsTemp.Tables[5].Columns.Contains("MATNR") ? Rows["MATNR"] : "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_BUDAT", dsTemp.Tables[5].Columns.Contains("BUDAT") ? Rows["BUDAT"] : "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_RESULT", sResult, DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_REMARK", sMSG_ERR, DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_MBLNR", dsTemp.Tables[5].Columns.Contains("SDOC_NO") ? Rows["SDOC_NO"] : "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_MJAHR", dsTemp.Tables[5].Columns.Contains("SDOC_SEQNO") ? Rows["SDOC_SEQNO"] : "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_I_IF_ID", dsTemp.Tables[4].Rows[0]["I_IF_ID"].ToString(), DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input));
                                }
                            }
                        }

                    }
                    if (dsTemp.Tables[7] != null)
                    {
                        if (dsTemp.Tables[7].Rows.Count > 0)
                        {
                            if (dsTemp.Tables[7].Rows[0][0].ToString() != "1")
                            {
                                foreach (DataRow Rows in dsTemp.Tables[7].Rows)//실적등록 및 자재이동, 실적취소 실패시 롤백 발생원인 저장 - 자재이동 로그
                                {
                                    helper.ExecuteNoneQuery("SP_HL_ROLLBACK_LOG", CommandType.StoredProcedure
                                    , helper.CreateParameter("P_DOC_NO", dsTemp.Tables[7].Columns.Contains("MDOCNO") ? Rows["MDOCNO"] : "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_DOC_SEQNO", dsTemp.Tables[7].Columns.Contains("MDOCSEQ") ? Rows["MDOCSEQ"] : "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_LOT_NO", dsTemp.Tables[7].Columns.Contains("CHARG_TO") ? Rows["CHARG_TO"] : "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_ORDER_NO", dsTemp.Tables[7].Columns.Contains("AUFNR") ? Rows["AUFNR"] : "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_WERKS", dsTemp.Tables[7].Columns.Contains("WERKS_TO") ? Rows["WERKS_TO"] : "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_WORKCENTERCODE", "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_MACH_CD", dsTemp.Tables[7].Columns.Contains("MACHINE") ? Rows["MACHINE"] : "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_PRDCD", "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_QTY", dsTemp.Tables[7].Columns.Contains("MENGE") ? Rows["MENGE"] : "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_MATNR", dsTemp.Tables[7].Columns.Contains("MATNR_TO") ? Rows["MATNR_TO"] : "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_BUDAT", dsTemp.Tables[7].Columns.Contains("BUDAT") ? Rows["BUDAT"] : "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_RESULT", sResult, DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_REMARK", "MENGE : " + Rows["MENGE"].ToString() + " MEINS : " + Rows["MEINS"].ToString() + " " + sMSG_ERR, DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_MBLNR", dsTemp.Tables[7].Columns.Contains("SDOC_NO") ? Rows["SDOC_NO"] : "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_MJAHR", dsTemp.Tables[7].Columns.Contains("SDOC_SEQNO") ? Rows["SDOC_SEQNO"] : "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_I_IF_ID", dsTemp.Tables[6].Rows[0]["I_IF_ID"].ToString(), DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input));
                                }
                            }
                        }
                    }
                    if (dsTemp_D.Tables.Count != 0)
                    {
                        if (dsTemp_D.Tables[1] != null)
                        {
                            if (dsTemp_D.Tables[1].Rows.Count > 0)
                            {
                                if (dsTemp_D.Tables[1].Rows[0][0].ToString() != "1")
                                {
                                    foreach (DataRow Rows in dsTemp_D.Tables[1].Rows)//실적등록 및 자재이동, 실적취소 실패시 롤백 발생원인 저장 - 실적취소 로그
                                    {
                                        helper.ExecuteNoneQuery("SP_HL_ROLLBACK_LOG", CommandType.StoredProcedure
                                        , helper.CreateParameter("P_DOC_NO", dsTemp_D.Tables[1].Columns.Contains("MDOCNO") ? Rows["MDOCNO"] : "", DbType.String, ParameterDirection.Input)
                                        , helper.CreateParameter("P_DOC_SEQNO", dsTemp_D.Tables[1].Columns.Contains("MDOCSEQ") ? Rows["MDOCSEQ"] : "", DbType.String, ParameterDirection.Input)
                                        , helper.CreateParameter("P_LOT_NO", dsTemp_D.Tables[1].Columns.Contains("LOTNO") ? Rows["LOTNO"] : "", DbType.String, ParameterDirection.Input)
                                        , helper.CreateParameter("P_ORDER_NO", dsTemp_D.Tables[1].Columns.Contains("AUFNR") ? Rows["AUFNR"] : "", DbType.String, ParameterDirection.Input)
                                        , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)
                                        , helper.CreateParameter("P_WORKCENTERCODE", dsTemp_D.Tables[1].Columns.Contains("WORKCENTERCODE") ? Rows["WORKCENTERCODE"] : "".ToString(), DbType.String, ParameterDirection.Input)
                                        , helper.CreateParameter("P_MACH_CD", "", DbType.String, ParameterDirection.Input)
                                        , helper.CreateParameter("P_PRDCD", "", DbType.String, ParameterDirection.Input)
                                        , helper.CreateParameter("P_QTY", dsTemp_D.Tables[1].Columns.Contains("MERGECNC") ? Rows["MERGECNC"] : "", DbType.String, ParameterDirection.Input)
                                        , helper.CreateParameter("P_MATNR", dsTemp_D.Tables[1].Columns.Contains("MATNR") ? Rows["MATNR"] : "", DbType.String, ParameterDirection.Input)
                                        , helper.CreateParameter("P_BUDAT", "", DbType.String, ParameterDirection.Input)
                                        , helper.CreateParameter("P_RESULT", sResult, DbType.String, ParameterDirection.Input)
                                        , helper.CreateParameter("P_REMARK", sMSG_ERR, DbType.String, ParameterDirection.Input)
                                        , helper.CreateParameter("P_MBLNR", dsTemp_D.Tables[1].Columns.Contains("SDOC_NO") ? Rows["SDOC_NO"] : "", DbType.String, ParameterDirection.Input)
                                        , helper.CreateParameter("P_MJAHR", dsTemp_D.Tables[1].Columns.Contains("SDOC_SEQNO") ? Rows["SDOC_SEQNO"] : "", DbType.String, ParameterDirection.Input)
                                        , helper.CreateParameter("P_I_IF_ID", dsTemp_D.Tables[0].Rows[0]["I_IF_ID"].ToString(), DbType.String, ParameterDirection.Input)
                                        , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input));
                                    }
                                }
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                LogFile.WriteLog("HL 부분폐품 ROLLBACK LOG 기록 에러 Exception 발생 [" + ex.Message + "]");
            }
        }

        private void doPrint(DataTable dtTemp)
        {
            #region A4출력
            ////조회결과 입력용 Row생성
            //REPORT_ITEM HLitem = new REPORT_ITEM();

            //HLitem.PRD_DATE = dtTemp.Rows[0]["PRFM_DT"].ToString();      // 생산일자
            //HLitem.MACH_NM = dtTemp.Rows[0]["MACH_NM"].ToString();       // 설비호기 명
            //HLitem.WERKS_NM = dtTemp.Rows[0]["WERKS_NM"].ToString();     // 제품구분
            //HLitem.MATNR = dtTemp.Rows[0]["MATNR"].ToString();           // 제품코드
            //HLitem.MATNR_NM = dtTemp.Rows[0]["MATNR_NM"].ToString();     // 제품명
            //HLitem.KAN_CD = dtTemp.Rows[0]["KAN_CD"].ToString();         // KAN코드
            //HLitem.UNIT = dtTemp.Rows[0]["BAG2BOX"].ToString();          // 기본단위
            //HLitem.PLT_UNIT = dtTemp.Rows[0]["BOX2PLT"].ToString();      // 팔레트 단위
            //HLitem.IND_BCD = dtTemp.Rows[0]["IND_BCD"].ToString();       // 개별바코드

            //string pstrERR = "";
            //REPORT rp = CommonReport.GetReport();   // REPORT rp = new REPORT();
            //rp.HL_PRINT(HLitem, ref pstrERR);
            //if (pstrERR.Length > 0)
            //{
            //    return;
            //}
            #endregion

            #region 바코드 라벨 테스트
            string PrinterName = SAMMI.IniFile.GetValue("KLEANNARA", "PRINTER", null);
            string PrinterDPI = SAMMI.IniFile.GetValue("KLEANNARA", "PRINTERDPI", null);
            string sZPL = string.Empty;
            //제목(PRODUCT)
            string sTitle = string.Empty;
            //생산정보(일자, 호기)
            string sPRD_DT = string.Empty;
            string sMACH_NM = string.Empty;
            string sPRFM_QTY = string.Empty;
            //제품정보(종류, 코드, 명, KAN, 기본단위, 파렛트단위, LOT)
            string sMATNR_DIV = string.Empty;
            string sMATNR = string.Empty;
            string sMATNR_NM = string.Empty;
            string sKAN_CD = string.Empty;
            string sBS_UNIT = string.Empty;
            string sPLT_UNIT = string.Empty;
            string sLOT_NO = string.Empty;
            //바코드
            string sINDBCD = string.Empty;

            sTitle = "PRODUCT";
            //생산정보(일자, 호기)
            sPRD_DT = dtTemp.Rows[0]["PRFM_DT"].ToString();
            sMACH_NM = dtTemp.Rows[0]["MACH_NM"].ToString();
            sPRFM_QTY = dtTemp.Rows[0]["PRFM_QTY"].ToString();
            //제품정보(종류, 코드, 명, KAN, 기본단위, 파렛트단위, LOT)
            sMATNR_DIV = dtTemp.Rows[0]["MATNR_DIV_NM"].ToString();
            sMATNR = dtTemp.Rows[0]["MATNR"].ToString();
            sMATNR_NM = dtTemp.Rows[0]["MATNR_NM"].ToString();
            sKAN_CD = dtTemp.Rows[0]["KAN_CD"].ToString();
            sBS_UNIT = dtTemp.Rows[0]["BAG2BOX"].ToString();
            sPLT_UNIT = dtTemp.Rows[0]["BOX2PLT"].ToString();
            sLOT_NO = dtTemp.Rows[0]["LOT_NO"].ToString();
            //바코드
            sINDBCD = dtTemp.Rows[0]["IND_BCD"].ToString();

            DBHelper helper = new DBHelper(false);
            try
            {
                //ZPL코드 프로시저 호출
                helper.ExecuteNoneQuery("SP_INV_ZPL_HL", CommandType.StoredProcedure
                 , helper.CreateParameter("P_TYPE", "P" + PrinterDPI, DbType.String, ParameterDirection.Input) //라벨종류
                 , helper.CreateParameter("P_TITLE", sTitle, DbType.String, ParameterDirection.Input) //제목
                 , helper.CreateParameter("P_PRD_DT", sPRD_DT, DbType.String, ParameterDirection.Input) //생산일자
                 , helper.CreateParameter("P_MACH_NM", sMACH_NM, DbType.String, ParameterDirection.Input) //생산호기
                 , helper.CreateParameter("P_MATNR_DIV", sMATNR_DIV, DbType.String, ParameterDirection.Input) //품목구분
                 , helper.CreateParameter("P_MATNR", sMATNR, DbType.String, ParameterDirection.Input) //품목코드
                 , helper.CreateParameter("P_MATNR_NM", sMATNR_NM, DbType.String, ParameterDirection.Input) //품목명
                 , helper.CreateParameter("P_KAN_CD", sKAN_CD, DbType.String, ParameterDirection.Input) //KAN코드
                 , helper.CreateParameter("P_BS_UNIT", sBS_UNIT, DbType.String, ParameterDirection.Input) //기준단위
                 , helper.CreateParameter("P_PLT_UNIT", sPLT_UNIT, DbType.String, ParameterDirection.Input) //팔레트
                 , helper.CreateParameter("P_LOT_NO", sLOT_NO, DbType.String, ParameterDirection.Input) //LOT
                 , helper.CreateParameter("P_INDBCD", sINDBCD, DbType.String, ParameterDirection.Input) //바코드
                 , helper.CreateParameter("P_PRFM_QTY", sPRFM_QTY, DbType.String, ParameterDirection.Input) //적재수량
                 , helper.CreateParameter("P_ZPL", DbType.String, ParameterDirection.Output, null, 4000)
                   );

                if (helper.RSCODE == "E")
                {
                    new POPUP.MessageForm(helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    this.DialogResult = DialogResult.OK;
                    return;
                }
                else
                {
                    sZPL = helper.Parameters["P_ZPL"].Value.ToString();
                }

                foreach (string sPrinter in System.Drawing.Printing.PrinterSettings.InstalledPrinters)
                {
                    if (sPrinter.Contains(PrinterName))
                    {
                        SAMMI.RawPrinterHelper.SendStringToBytePrinter(sPrinter, sZPL);

                        break;
                    }
                }
            }
            catch (Exception ex)
            {
                LogFile.WriteLog("POP_WRK86.doPrint Error => " + ex.Message);
            }
            finally
            {
                helper.Close();
            }
            #endregion
        }


        private void lblERR_BOX_Click(object sender, EventArgs e)
        {

        }

        private void lblERR_BAG_Click(object sender, EventArgs e)
        {
            double dDimension;

            DAResultQty pop = new DAResultQty();
            pop.LabelTitle = "폐품수량 입력";
            pop.LabelHeader = "수량";
            pop.ContentMaxLength = 8;

            pop.ShowDialog(this);

            if (pop.DialogResult == DialogResult.OK)
            {
                dDimension = pop.ResultDouble;
                //폐품 수량 입력
                lblERR_BAG.Text = ((int)dDimension).ToString();
                //폐품수량 변환 입력
                if (lblERR_PLT.Tag != null)
                    lblERR_PLT.Text = string.Format("{0:#,###}", Common.GetChangeUnit(lblERR_PLT.Tag.ToString(), dDimension));
                if (lblERR_BOX.Tag != null)
                    lblERR_BOX.Text = string.Format("{0:#,###}", Common.GetChangeUnit(lblERR_BOX.Tag.ToString(), dDimension));
                if (lblERR_EA.Tag != null)
                    lblERR_EA.Text = string.Format("{0:#,###}", Common.GetChangeUnit(lblERR_EA.Tag.ToString(), dDimension));
            }
        }

        private void btnConfirm_Click(object sender, EventArgs e)
        {
            doUpdate("A");
        }

        private void btnRePLT_Click(object sender, EventArgs e)
        {
            doUpdate("R");
        }

        private void btnClose_Click(object sender, EventArgs e)
        {
            this.Close();
        }
    }
}
