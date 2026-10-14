#region [ USING AREA ]
using System;
using System.Configuration;
using System.Data;
using System.Windows.Forms;


using SmartDas.Components;
using SmartDas.POPUP;
using SAMMI;
using Infragistics.Win.UltraWinGrid;
using Oracle.ManagedDataAccess.Client;
using System.Threading;

#endregion

namespace SmartDas
{
    public partial class POP_WRK37 : BaseForm
    {
        #region < MEMBER AREA >

        private SAMMI.Common _common = new SAMMI.Common();

        private string gsIND_BCD = string.Empty;

        private string gsWRK_ORDR_NO = string.Empty;
        private string gsWRK_ORDR_SEQ = string.Empty;

        private string gsLABEL_TYPE = string.Empty;
        private int gnPrtCnt = 1;

        private Decimal gdBS_WGT = 0;       // 평량
        private Decimal gdWLEN = 0;         // 가로길이
        private Decimal gdVLEN = 0;         // 세로길이

        private Decimal gdDISPO_REAM = 0;     // 파지연수
        private Decimal gdDISPO_WGT = 0;     // 파지연수
        #endregion

        #region < CONSTRUCTOR >

        public POP_WRK37()
        {
            InitializeComponent();

            Common.SetMessageList();
        }

        public POP_WRK37(string ind_bcd, string wrk_ordr_no, string wrk_ordr_seq, string label_type, int nprt_cnt)
        {
            InitializeComponent();

            Common.SetMessageList();

            gsIND_BCD = ind_bcd;
            gsWRK_ORDR_NO = wrk_ordr_no;
            gsWRK_ORDR_SEQ = wrk_ordr_seq;
            gsLABEL_TYPE = label_type;
            gnPrtCnt = nprt_cnt;
        }
        #endregion

        #region < POP_WRK37_Load >
        private void POP_WRK37_Load(object sender, EventArgs e)
        {
            try
            {
                #region --- 언어 설정 → 모듈별로 화면 첫 화면 분기되는 화면에 해당 코드 삽입 ---
                Configuration appConfig = ConfigurationManager.OpenExeConfiguration(ConfigurationUserLevel.None);

                SAMMI.Common.SystemID = appConfig.AppSettings.Settings["SystemID"].Value.ToString();
                SAMMI.Common.Lang = appConfig.AppSettings.Settings["LANGUAGE"].Value.ToString();


                DataTable rtnDtTemp = _common.GET_TBM0000_CODE("LANGKY");

                SAMMI.Common.FontName = Convert.ToString(((DataRow[])rtnDtTemp.Select("CODE_ID = '" + SAMMI.Common.Lang + "'"))[0]["RelCode1"]);

                #endregion

                this.lblTitle.Text = "등급변경";

                SetMenuButtons();

                DoFind();
                InitGrid();
            }
            catch (Exception ex)
            {
                LogFile.WriteLog("[등급변경]POP_WRK37_Load Error => " + ex.Message);
                SetMessage("POP_WRK37_Load_ Error!");
            }

            //현재 메시지큐에 있는 모든 메시지 처리함수 
            SendKeys.Flush();
        }
        #endregion

        #region < METHOD AREA >

        private void DoFind()
        {
            DBHelper helper = new DBHelper();
            DataTable dtRtn;

            try
            {
                dtRtn = helper.FillTable("SP_POP_WRK37_S01", CommandType.StoredProcedure
                                                    , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)                     // 플랜트코드
                                                    , helper.CreateParameter("P_MACHCD", Common.MachineCode, DbType.String, ParameterDirection.Input)
                                                    , helper.CreateParameter("P_IND_BCD", gsIND_BCD, DbType.String, ParameterDirection.Input));
                if (helper.RSCODE.Equals("S"))
                {
                    if (dtRtn.Rows.Count < 1)
                    {
                        new POPUP.MessageForm("조회된 개별바코드 정보가 없습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    }
                    else
                    {
                        lblLOT_NO.Text = dtRtn.Rows[0]["LOT_NO"].ToString();       //
                        lblIND_BCD.Text = dtRtn.Rows[0]["IND_BCD"].ToString();       //
                        lblPRFM_DT.Text = dtRtn.Rows[0]["PRFM_DT"].ToString();       //
                        lblMATNR.Text = dtRtn.Rows[0]["MATNR"].ToString();       //
                        //lblPCODE.Text = dtRtn.Rows[0]["PCODE"].ToString();       // 지종코드
                        lblPCODE.Text = dtRtn.Rows[0]["PCODE_NM"].ToString();       // 지종명
                        lblBS_WGT.Text = dtRtn.Rows[0]["BS_WGT"].ToString();       //
                        lblWLEN.Text = dtRtn.Rows[0]["WLEN"].ToString();       //
                        lblVLEN.Text = dtRtn.Rows[0]["VLEN"].ToString();       //
                        lblPACK_TYPE.Text = dtRtn.Rows[0]["PACKTYPE_NM"].ToString();       //

                        lblIN_PER_CNT.Text = dtRtn.Rows[0]["IN_PER_CNT"].ToString();       //
                        lblPROD_REAM.Text = lblINPUT_REAM.Text = dtRtn.Rows[0]["PCNT"].ToString();       //
                        lblKUNNRT.Text = dtRtn.Rows[0]["KUNNRT"].ToString();       //
                        
                        lblREMAIN_REAM.Text = "0";

                        
                        InitControl();
                    }
                }
            }
            catch (Exception ex)
            {
                LogFile.WriteLog("[등급변경] 개별바코드 조회 에러 => " + ex.Message);
                new POPUP.MessageForm("조회된 개별바코드 정보가 없습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
            }
        }

        private void InitGrid()
        {
            DataSet dsTemp = new DataSet();
            DataTable dtTemp = new DataTable();
            DataTable dtDummy = new DataTable();
            DataRow rTemp = null;

            dtDummy.Columns.Add("IND_BCD", typeof(string));     // 개별바코드
            dtDummy.Columns.Add("REAM", typeof(string));        // 연수
            dtDummy.Columns.Add("WGT", typeof(string));         // 중량
            dtDummy.Columns.Add("MATNR", typeof(string));       // 자재코드
            dtDummy.Columns.Add("IN_PER_CNT", typeof(string));  // 속당매수
            dtDummy.Columns.Add("SCNT", typeof(string));      // 속수
            dtDummy.Columns.Add("REMARK", typeof(string));      // 비고

            string sColInfo = "새 바코드@C^100|연수(R)@R^80|중량(kg)@R^100|자재코드@L^190|속당매수@R^80|속수@C^80|비고@L^180";
            string sColType = "IND_BCD@varchar|REAM@varchar|WGT@varchar|MATNR@varchar|IN_PER_CNT@varchar|SCNT@varchar|REMARK@varchar";
            Grid1.HeaderFontSize = 12;
            Grid1.FontSize = 12;
            Grid1.CountRows = 4;
            Grid1.AutoScroll = true;
            Grid1.DisplayLayout.Scrollbars = Scrollbars.Automatic;

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
            dsTemp.Tables.Add(dtDummy);
            //그리드 출력
            Grid1.DoFind_Oracle(dsTemp);

        }


        private void SetMenuButtons()
        {
            try
            {
                //메인버튼 설정
                bBox1.ButtonBoxType = ButtonBox.ButtonBoxTypeEnum.Buttons;
                bBox1.SelectionMode = ButtonBox.SelectionModeEnum.Single;

                bBox1.CountX = 11;
                bBox1.CountY = 1;

                bBox1.SetButtons();

                bBox1[0, 0].Text = "등급변경";
                bBox1[0, 0].Tag = "Confirm";
                bBox1[0, 0].MappingButton.FontSize = 14;
                bBox1[0, 1].Text = "";
                bBox1[0, 1].Tag = "";
                bBox1[0, 1].MappingButton.FontSize = 14;
                bBox1[0, 2].Text = "";
                bBox1[0, 2].Tag = "";
                bBox1[0, 2].MappingButton.FontSize = 14;
                bBox1[0, 3].Text = "";
                bBox1[0, 3].Tag = "";
                bBox1[0, 3].MappingButton.FontSize = 14;
                bBox1[0, 4].Text = "";
                bBox1[0, 4].Tag = "";
                bBox1[0, 4].MappingButton.FontSize = 14;
                bBox1[0, 5].Text = "";
                bBox1[0, 5].Tag = "";
                bBox1[0, 5].MappingButton.FontSize = 14;
                bBox1[0, 6].Text = "";
                bBox1[0, 6].Tag = "";
                bBox1[0, 6].MappingButton.FontSize = 14;
                bBox1[0, 7].Text = "";
                bBox1[0, 7].Tag = "";
                bBox1[0, 7].MappingButton.FontSize = 14;
                bBox1[0, 8].Text = "";
                bBox1[0, 8].Tag = "";
                bBox1[0, 8].MappingButton.FontSize = 14;
                bBox1[0, 9].Text = "";
                bBox1[0, 9].Tag = "";
                bBox1[0, 9].MappingButton.FontSize = 14;
                bBox1[0, 10].Text = "닫기";
                bBox1[0, 10].Tag = "Close";
                bBox1[0, 10].MappingButton.FontSize = 14;

                bBox1.RedrawButtons();
            }
            catch (Exception ex)
            {
                SetMessage("SetButtons Error!");
                LogFile.WriteLog("DA0100.SetButtons Error => " + ex.Message);
            }
        }



        private DataTable setReqWorkList(DataTable dtSrc, string sCHG_DT, string sCHG_DIV)
        {
            DataTable dtRtn = new DataTable();
            DataRow dtTempRow;

            try
            {
                //테이블 컬럼명 작성
                dtRtn.Columns.Add(new DataColumn("NO", typeof(int)));                   //순서

                dtRtn.Columns.Add(new DataColumn("CCNT", typeof(string)));              //연수From
                dtRtn.Columns.Add(new DataColumn("MATNR", typeof(string)));             //등급변경할 자재코드
                dtRtn.Columns.Add(new DataColumn("PRFM_QTY", typeof(string)));          //연수To
                dtRtn.Columns.Add(new DataColumn("WGT", typeof(string)));               //중량To
                dtRtn.Columns.Add(new DataColumn("ZZATT1", typeof(string)));            //속당매수
                dtRtn.Columns.Add(new DataColumn("SCNT", typeof(string)));              //속수
                

                dtRtn.Columns.Add(new DataColumn("CHG_DT", typeof(string)));            //등급변경일자
                dtRtn.Columns.Add(new DataColumn("CHG_DIV", typeof(string)));           //등급변경사유((01: 규격변경, 02, 수입입고변경, 03: 잔량입고변경, 04:품질입고변경)
                dtRtn.Columns.Add(new DataColumn("DISPO_QTY", typeof(string)));         //파지연수
                dtRtn.Columns.Add(new DataColumn("DISPO_WGT", typeof(string)));         //파지중량
                dtRtn.Columns.Add(new DataColumn("RMK", typeof(string)));               //비고

                /*
                 * 
                            dtDummy.Columns.Add("IND_BCD", typeof(string));     // 개별바코드
                            dtDummy.Columns.Add("REAM", typeof(string));        // 연수
                            dtDummy.Columns.Add("WGT", typeof(string));         // 중량
                            dtDummy.Columns.Add("MATNR", typeof(string));       // 자재코드
                            dtDummy.Columns.Add("IN_PER_CNT", typeof(string));  // 속당매수
                            dtDummy.Columns.Add("SCNT", typeof(string));      // 속수
                            dtDummy.Columns.Add("REMARK", typeof(string));      // 비고
                */

                Decimal dPROD_REAM = 0;                    // 실적연수
                Decimal.TryParse(lblPROD_REAM.Text.ToString().Replace(",", ""), out dPROD_REAM);             // 실적연수
                
                Decimal dREAM_FROM = 0;

                for (int i = 0; i < dtSrc.Rows.Count; i++)
                {
                    //조회결과 입력용 Row생성
                    dtTempRow = dtRtn.NewRow();

                    dtTempRow["NO"] = (i + 1).ToString();         //순서

                    dtTempRow["CCNT"] = string.Format("{0:#0.###}", dPROD_REAM);  //등급변경 연 수량 - From
                    dtTempRow["MATNR"] = dtSrc.Rows[i]["MATNR"].ToString();         //등급변경할 자재코드

                    Decimal.TryParse(dtSrc.Rows[i]["REAM"].ToString().Replace(",", ""), out dREAM_FROM);             // 연수To
                    dtTempRow["PRFM_QTY"] = string.Format("{0:#0.###}", dREAM_FROM);       //등급변경 연 수량 - To
                    // dtTempRow["PRFM_QTY"] = dtSrc.Rows[i]["REAM"].ToString();       //등급변경 연 수량 - To

                    dtTempRow["WGT"] = dtSrc.Rows[i]["WGT"].ToString().Replace(",", "");             //중량
                    dtTempRow["ZZATT1"] = dtSrc.Rows[i]["IN_PER_CNT"].ToString().Replace(",", "");   //속당매수
                    dtTempRow["SCNT"] = dtSrc.Rows[i]["SCNT"].ToString().Replace(",", "");          //속수

                    dtTempRow["CHG_DT"] = sCHG_DT;                                  //등급변경일자
                    dtTempRow["CHG_DIV"] = sCHG_DIV;                                //등급변경사유((01: 규격변경, 02, 수입입고변경, 03: 잔량입고변경, 04:품질입고변경)

                    if (i == (dtSrc.Rows.Count-1))
                    {
                        if (gdDISPO_REAM > 0 && gdDISPO_WGT > 0)
                        {
                            dtTempRow["DISPO_QTY"] = string.Format("{0:#0.###}", gdDISPO_REAM);                      //폐품연수
                            dtTempRow["DISPO_WGT"] = string.Format("{0:#0.###}", gdDISPO_WGT);                      //폐품중량
                        }
                        else
                        {
                            dtTempRow["DISPO_QTY"] = "0";                                //폐품연수
                            dtTempRow["DISPO_WGT"] = "0";                                //폐품중량
                        }
                    }
                    else
                    {
                        dtTempRow["DISPO_QTY"] = "0";                                //폐품연수
                        dtTempRow["DISPO_WGT"] = "0";                                //폐품중량
                    }
                    dtTempRow["RMK"] = dtSrc.Rows[i]["REMARK"].ToString();       //중량

                    //결과 테이블에 저장
                    dtRtn.Rows.Add(dtTempRow);

                    dPROD_REAM = dPROD_REAM - dREAM_FROM;
                }
                
                DataView dv = new DataView(dtRtn);
                dv.Sort = "NO ASC";
                dtRtn = dv.ToTable();
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return dtRtn;
        }

        private bool doConfirm()
        {
            string sCHG_DT  = string.Empty;
            string sCHG_DIV = string.Empty;
            string sResult = string.Empty;


            if (Grid1.Rows.Count == 0)
            {
                new POPUP.MessageForm("등급변경할 데이터가 없습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return false;
            }

            //등급변경사유((01: 규격변경, 02, 수입입고변경, 03: 잔량입고변경, 04:품질입고변경)
            if (rbCHG_REASON01.Checked == true) sCHG_DIV = "01";
            else if (rbCHG_REASON02.Checked == true) sCHG_DIV = "02";
            else if (rbCHG_REASON03.Checked == true) sCHG_DIV = "03";
            else if (rbCHG_REASON04.Checked == true) sCHG_DIV = "04";
            else
            {
                new POPUP.MessageForm("등급변경 사유를 선택 해 주세요.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                return false;
            }
                
            if (new POPUP.MessageForm(string.Format("{0}건의 등급변경을 일괄 실행하겠습니까?", Grid1.Rows.Count), MessageBoxButtons.YesNo, "알   림").ShowDialog(this) == DialogResult.No)
            {
                return  false;
            }

            sCHG_DT = dtpWorkDate.Value.ToString("yyyyMMdd");

            DataTable dtList = setReqWorkList(Grid1.DataSource, sCHG_DT, sCHG_DIV);

            string sJsonWrkList = Common.toJsonFormat("POP_WRK037", dtList);


            //LOTNO_FROM      // 이전 포장 LOT 번호
            //BUDAT           // 전기일
            //CCNT            // 등급변경 연 수량 - From   - 0 으로 전달
                
            //MATNR           // 자재번호 To
            //CTCNT           // 등급변경 연 수량 - To
            //PCNT            // 팔레트당 연수            - 0 으로 전달
            //REMARK            //비고

            DBHelper helper = new DBHelper(false, "", true);
            DataSet dsTemp = new DataSet();     //실적등록 결과 수신(0:실적 RFC ID, 1:실적 IF 변수, 2:실적 RFC ID, 3:실적 IF 변수)
            bool bReturn = false;           // 실적
            bool bRetDISPO = false;         // 폐품
            bool bRetSALES_DISPO = false;   // 영업폐품
            bool bRetINP = false;     // 투입량

            string sRES_IND_BCD = "";

            //rollback용 
            //SAP 롤백용 추가 CODE 범위 START
            DataTable sapTemp = new DataTable();
            DataTable gradeTemp = new DataTable();
            DataTable dispoTemp = new DataTable();
            DataTable[] tableGroup = new DataTable[2] { gradeTemp, dispoTemp };
            sapTemp.Columns.Add("SAP_TYPE", typeof(string));
            sapTemp.Columns.Add("IF_KEY", typeof(string));
            sapTemp.Columns.Add("MDOCNO", typeof(string));
            sapTemp.Columns.Add("MDOCSEQ", typeof(string));
            sapTemp.Columns.Add("SDOC_NO", typeof(string));
            sapTemp.Columns.Add("SDOC_SEQNO", typeof(string));

            //SAP 롤백용 추가 CODE 범위 END
            //rollback용 end

            try
            {
                this.Cursor = Cursors.WaitCursor;   //Waitting

                dsTemp = helper.FillDataSetN("SP_POP_WRK37_I01", CommandType.StoredProcedure, 4
                            , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)                  // 플랜트
                            , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)              // 작업장코드(설비코드)
                            , helper.CreateParameterOracle("P_WRK_LIST", sJsonWrkList, OracleDbType.Clob, ParameterDirection.Input)         // 등급변할 리스트
                            , helper.CreateParameter("P_IND_BCD", gsIND_BCD, DbType.String, ParameterDirection.Input)                       // 등급변경전 개별바코드
                            , helper.CreateParameter("P_MATNR", lblMATNR.Text, DbType.String, ParameterDirection.Input)                     // 등급변경전 자재코드
                            , helper.CreateParameter("P_LOT_NO", lblLOT_NO.Text, DbType.String, ParameterDirection.Input)                   // 등급변경전 LOT NO
                            , helper.CreateParameter("P_WRK_ORDR_NO", gsWRK_ORDR_NO, DbType.String, ParameterDirection.Input)               // 등급변경전 작업지시번호
                            , helper.CreateParameter("P_WRK_ORDR_SEQNO", gsWRK_ORDR_SEQ, DbType.String, ParameterDirection.Input)           // 등급변경전 작업지시번호 순번
                            , helper.CreateParameter("P_WRK_CLASS", Common.WorkClass, DbType.String, ParameterDirection.Input)              // 작업반
                            , helper.CreateParameter("P_WRK_SHIFT", Common.WorkShift, DbType.String, ParameterDirection.Input)              // 작업조
                            , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input)                    // 사용자ID
                            , helper.CreateParameter("RS_GRD_RFCFN", DbType.String, ParameterDirection.Output, null, 200)                   // 등급변경 RFCFN
                            , helper.CreateParameter("RS_DISPO_RFCFN", DbType.String, ParameterDirection.Output, null, 200)                 // 폐품 RFCFN
                            , helper.CreateParameter("RS_IND_BCD", DbType.String, ParameterDirection.Output, null, 2000)                    //  RES 개별바코드 
                        );

                if (helper.RSCODE == "S")
                {
                    sRES_IND_BCD = helper.Parameters["RS_IND_BCD"].Value.ToString();

                    string sRS_GRD_RFCFN = helper.Parameters["RS_GRD_RFCFN"].Value.ToString();          // 등급변경 RFCFN ID
                    string sRS_DISPO_RFCFN = helper.Parameters["RS_DISPO_RFCFN"].Value.ToString();      // 폐품 RFCFN ID

                    //dsTemp.Tables[0];     // 등급변경 인터페이스 파라미터
                    //dsTemp.Tables[1];     // 등급변경 인터페이스 상세 파라미터
                    //dsTemp.Tables[2];     // 폐품 인터페이스 파라미터
                    //dsTemp.Tables[3];     // 폐품 인터페이스 상세 파라미터
#if false
                    helper.Rollback();
                    return false;
#endif
                    string sRfcData; //RFC결과 JSON 변환

                    bReturn = false;

                    tableGroup[0] = dsTemp.Tables[1];
                    tableGroup[1] = dsTemp.Tables[3];

                    // 1. 실적 등록 (밀롤 완료 플래그 때문에 마지막에 보냄)
                    if (string.IsNullOrEmpty(sRS_GRD_RFCFN) == false)
                    {
                        // 문서번호, 문서순번으로  테이블 SORT 하여 전달
                        DataTable dtRFCData = new DataTable();
                        DataView dvPFRM = new DataView(dsTemp.Tables[1]);
                        dvPFRM.Sort = "MDOCNO, MDOCSEQ ASC";
                        dtRFCData = dvPFRM.ToTable();

                        //SAP 실적 등록
                        SAPHelper sapRFC_P = new SAPHelper();
                        // sapRFC.CallSAPFunc_HL 호출시 helper를 사용하여 내용이 변경됨. 
                        // 필요한 정보는 sapRFC.CallSAPFunc_HL 호출전에 처리해야함.
                        if (sapRFC_P.CallSAPFunc_HL(sRS_GRD_RFCFN, dsTemp.Tables[0], dtRFCData, helper).Equals("S"))
                        {
                            // ---- 전달시 MBLNR, MJAHR을 replace 처리하여 하나로 받도록함.
                            sRfcData = Common.toJsonFormat("PUT_WRKRTN", sapRFC_P.rtnTable).Replace("MBLNR", "RUECK").Replace("MJAHR", "RMZHL");

                            //실적등록 테이블에 확정문서 번호 갱신
                            helper.ExecuteNoneQuery("SP_IF_PUT_WRKRTN_HL", CommandType.StoredProcedure
                                                                , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)          // 플랜트
                                                                , helper.CreateParameter("P_WRK_TYPE", "GR5", DbType.String, ParameterDirection.Input)                    // '0'= 실적테이블, '1'= 폐품테이블, '2'=소요량, '3'=비가동, '4'=비계획생산, 'GR5'=등급변경, 'GR6'=등급변경폐품, '9'=PS 영업폐품, 잔량폐품 실적  
                                                                , helper.CreateParameterOracle("P_RFC_DATA", sRfcData, OracleDbType.Clob, ParameterDirection.Input)
                                                                , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input));


                            bool bPART_ERROR = false;
                            // 여러건중 오류가 있는지 확인
                            foreach (DataRow rtnRows in sapRFC_P.rtnTable.Rows)
                            {
                                if (rtnRows["TYPE"].ToString() == "E")
                                {
                                    bPART_ERROR = true;
                                    break;
                                }
                            }

                            if (bPART_ERROR == true)
                            {
                                string sTempSAP_TYPE = string.Empty;
                                string sTempIF_KEY = string.Empty;
                                string sTempMDOC_NO = string.Empty;
                                string sTempMDOC_SEQNO = string.Empty;

                                sTempSAP_TYPE = "2.GRADE_REG_SAP";
                                sTempIF_KEY = dsTemp.Tables[0].Rows[0]["I_IF_KEY"].ToString();

                                foreach (DataRow rtnRows in sapRFC_P.rtnTable.Rows)
                                {
                                    if (rtnRows["TYPE"].ToString() == "S")
                                    {
                                        //sapTemp.Rows.Add(sTempSAP_TYPE, sTempIF_KEY, rtnRows["MDOCNO"].ToString(), rtnRows["MDOCSEQ"].ToString()); // 후단 코드 실행시 EXCEPTION 상황 SAP CANCLE 정보 -- 실적등록
                                        sapTemp.Rows.Add(sTempSAP_TYPE, sTempIF_KEY, rtnRows["MDOCNO"].ToString(), rtnRows["MDOCSEQ"].ToString(), rtnRows["MBLNR"].ToString(), rtnRows["MJAHR"].ToString()); // 후단 코드 실행시 EXCEPTION 상황 SAP CANCLE 정보 -- 실적등록
                                    }
                                }
                                //SAP 롤백용 추가 CODE 범위 END

                                LogFile.WriteLog("등급변경 - SAP 전송 실패 [" + sapRFC_P.rtnMSG + "]");
                                throw new Exception("등급변경 - SAP전송이 실패하였습니다.\r\n" + sapRFC_P.rtnMSG + Environment.NewLine);
                            }
                            else
                            {
                                //rollback 적용 정보수집 start
                                SaveRfcSuccesData("2.GRADE_REG_SAP", sRS_GRD_RFCFN, sapRFC_P, ref tableGroup[0], ref sapTemp);
                                //end
                            }

                            if (helper.RSCODE == "S")
                            {
                                bReturn = true;
                            }
                            else if (helper.RSCODE == "E")
                            {
                                LogFile.WriteLog("등급변경 - SAP 확정문서 등록 오류 [" + helper.RSMSG.ToString() + "]");
                                throw new Exception("등급변경 - SAP 확정문서 등록 오류\r\n" + helper.RSMSG.ToString());
                            }
                            else
                            {
                                LogFile.WriteLog("등급변경 - SAP 확정문서 등록 오류 [" + helper.RSMSG.ToString() + "]");
                                throw new Exception("등급변경 - SAP 확정문서 등록 오류\r\n" + helper.RSMSG.ToString());
                            }
                        }
                        else
                        {
                            LogFile.WriteLog("등급변경 - SAP 전송 실패 [" + sapRFC_P.rtnMSG + "]");
                            throw new Exception("등급변경 - SAP전송이 실패하였습니다.\r\n" + sapRFC_P.rtnMSG + Environment.NewLine);
                        }
                        Thread.Sleep(Common.SLEEP_DELAY);

                        System.Windows.Forms.Application.DoEvents();        // 반복작업중 응답없음 안뜨게 하기
                        this.Cursor = Cursors.WaitCursor;   //Waitting
                    }
                    else
                    {
                        bReturn = true;
                    }


                    // 2. 폐품 등록
                    if ((bReturn == true) && (string.IsNullOrEmpty(sRS_DISPO_RFCFN) == false))
                    {
                        bRetDISPO = false;

                        // 문서번호, 문서순번으로  테이블 SORT 하여 전달
                        DataTable dtRFCData = new DataTable();
                        DataView dvPFRM = new DataView(dsTemp.Tables[3]);
                        dvPFRM.Sort = "MDOCNO, MDOCSEQ ASC";
                        dtRFCData = dvPFRM.ToTable();

                        SAPHelper sapRFC_D = new SAPHelper();
                        // sapRFC.CallSAPFunc_HL 호출시 helper를 사용하여 내용이 변경됨. 
                        // 필요한 정보는 sapRFC.CallSAPFunc_HL 호출전에 처리해야함.
                        if (sapRFC_D.CallSAPFunc_HL(sRS_DISPO_RFCFN, dsTemp.Tables[2], dtRFCData, helper).Equals("S"))
                        {
                            // ---- 전달시 MBLNR, MJAHR을 replace 처리하여 하나로 받도록함.
                            sRfcData = Common.toJsonFormat("PUT_WRKRTN", sapRFC_D.rtnTable).Replace("MBLNR", "RUECK").Replace("MJAHR", "RMZHL");


                            //rollback 적용 정보수집 start
                            SaveRfcSuccesData("1.DISPO_REG_SAP", sRS_GRD_RFCFN, sapRFC_D, ref tableGroup[1], ref sapTemp);
                            //end

                            //실적등록 테이블에 확정문서 번호 갱신
                            helper.ExecuteNoneQuery("SP_IF_PUT_WRKRTN_HL", CommandType.StoredProcedure
                                                                , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)          // 플랜트
                                                                , helper.CreateParameter("P_WRK_TYPE", "GR6", DbType.String, ParameterDirection.Input)                    // '0'= 실적테이블, '1'= 폐품테이블, '2'=소요량, '3'=비가동, '4'=비계획생산, '5'=등급변경, '9'=PS 영업폐품, 잔량폐품 실적  
                                                                , helper.CreateParameterOracle("P_RFC_DATA", sRfcData, OracleDbType.Clob, ParameterDirection.Input)
                                                                , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input));

                            if (helper.RSCODE == "S")
                            {
                                bRetDISPO = true;
                            }
                            else //if (helper.RSCODE == "E")
                            {
                                //helper.Rollback();    // 실적이 성공이면 rollback 처리 안함.
                                LogFile.WriteLog("등급변경(폐품) - SAP 확정문서 등록 오류 [" + helper.RSMSG.ToString() + "]");
                                throw new Exception("등급변경(폐품) - SAP 확정문서 등록 오류\r\n" + helper.RSMSG.ToString());
                           
                            }
                        }
                        else
                        {
                            //helper.Rollback();    // 실적이 성공이면 rollback 처리 안함.
                            LogFile.WriteLog("등급변경 실적 등록(폐품) - SAP전송 오류 [" + sapRFC_D.rtnMSG + "]");
                            throw new Exception("등급변경 등록(폐품) - SAP전송이 실패하였습니다.\r\n" + sapRFC_D.rtnMSG);
                        }
                    }



                    if (bReturn == true)
                    {
                        helper.Commit();

                        PrinterManager.PrintPackaging(sRES_IND_BCD, gsLABEL_TYPE, gnPrtCnt);

                        this.Cursor = Cursors.Default;   //Waitting

                        LogFile.WriteLog("등급변경 성공");

                        new POPUP.MessageForm("등급변경 완료 되었습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);

                    }
                }

            }
            catch (Exception ex)
            {
                Thread.Sleep(Common.SLEEP_DELAY);

                System.Windows.Forms.Application.DoEvents();        // 반복작업중 응답없음 안뜨게 하기
                this.Cursor = Cursors.WaitCursor;   //Waitting

                LogFile.WriteLog("POP_WRK37.doConfirm Error => " + ex.Message);
                sResult = "ROLLBACK";
                RollbackLog(helper, dsTemp, tableGroup, ex.Message, sResult, false);
                ProdRollback_PS(helper, sapTemp, dsTemp);
                helper.Rollback();

                this.Cursor = Cursors.Default;   //Waitting
                //new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                new POPUP.MessageForm_ERR("등급변경 오류", "등급변경 오류\r\n" + ex.ToString(), MessageBoxButtons.OK).ShowDialog(this);
            }
            finally
            {
                this.Cursor = Cursors.Default;   //Waitting
                helper.Close();
            }

            return bReturn;
        }
        #endregion

        private void ProdRollback_PS(DBHelper helper, DataTable sapTemp, DataSet dsTemp)
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
                            case "2.GRADE_REG_SAP":
                                dsTemp = helper.FillDataSetN("SP_POP_WRK37_IFR01", CommandType.StoredProcedure, 2
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
                                        LogFile.WriteLog("등급변경 ROLLBACK [" + helper.RSMSG.ToString() + "]");
                                        sMSG_ERR = "등급변경 ROLLBACK [" + helper.RSMSG.ToString() + "]";

                                        sResult = "S";
                                    }
                                    else
                                    {
                                        LogFile.WriteLog("등급변경 ROLLBACK 오류 - SAP전송 오류 [" + sapRFC_1.rtnMSG + "]");
                                        sMSG_ERR = "등급변경 ROLLBACK 오류 : " + sapRFC_1.rtnMSG + Environment.NewLine;
                                        sResult = "E";
                                    }
                                }
                                else //if (helper.RSCODE == "E")
                                {
                                    LogFile.WriteLog("등급변경 ROLLBACK 등록 - MES IF TABLE 등록 오류 [" + helper.RSMSG.ToString() + "]");
                                    sMSG_ERR = "ROLLBACK MES IF TABLE 등록 오류 : " + helper.RSMSG.ToString() + Environment.NewLine;
                                    sResult = "E";
                                }
                                RollbackLog(helper, dsTemp, null, sMSG_ERR, sResult, true);
                                Thread.Sleep(Common.SLEEP_DELAY);
                                break;
                            case "1.DISPO_REG_SAP":
                                dsTemp = helper.FillDataSetN("SP_POP_WRK37_IFR02", CommandType.StoredProcedure, 2
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
                                        LogFile.WriteLog("폐품등록 ROLLBACK [" + helper.RSMSG.ToString() + "]");
                                        sMSG_ERR = "폐품등록 ROLLBACK [" + helper.RSMSG.ToString() + "]";

                                        sResult = "S";
                                    }
                                    else
                                    {
                                        LogFile.WriteLog("폐품등록 ROLLBACK 오류 - SAP전송 오류 [" + sapRFC_2.rtnMSG + "]");
                                        sMSG_ERR = "폐품등록 ROLLBACK 오류 : " + sapRFC_2.rtnMSG + Environment.NewLine;
                                        sResult = "E";
                                    }
                                }
                                else //if (helper.RSCODE == "E")
                                {
                                    LogFile.WriteLog("폐품등록 ROLLBACK 등록 - MES IF TABLE 등록 오류 [" + helper.RSMSG.ToString() + "]");
                                    sMSG_ERR = "ROLLBACK MES IF TABLE 등록 오류 : " + helper.RSMSG.ToString() + Environment.NewLine;
                                    sResult = "E";
                                }

                                RollbackLog(helper, dsTemp, null, sMSG_ERR, sResult, true);
                                Thread.Sleep(Common.SLEEP_DELAY);
                                break;
                            default:
                                break;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                LogFile.WriteLog("폐품등록 ROLLBACK 에러 Exception 발생 [" + ex.Message + "]");
            }
        }

        private void SaveRfcSuccesData(string sTempSAP_TYPE, string sTempIF_KEY, SAPHelper sapRFC,ref DataTable dsTempTable, ref DataTable sapTemp) 
        {
            //rollback용
            //SAP 롤백용 추가 CODE 범위 START
            string sTempMDOC_NO = string.Empty;
            string sTempMDOC_SEQNO = string.Empty;

            string sSDOC_ColunmName = string.Empty;
            string sSDOCNO_ColunmName = string.Empty;
            if (sapRFC.rtnTable.Columns.Contains("MBLNR") && sapRFC.rtnTable.Columns.Contains("MJAHR"))
            {
                sSDOC_ColunmName = "MBLNR";
                sSDOCNO_ColunmName = "MJAHR";
            }
            else
            {
                sSDOC_ColunmName = "RUECK";
                sSDOCNO_ColunmName = "RMZHL";
            }

            if (!dsTempTable.Columns.Contains("SDOC_NO") && !dsTempTable.Columns.Contains("SDOC_SEQNO"))
            {
                dsTempTable.Columns.Add("SDOC_NO", typeof(string));
                dsTempTable.Columns.Add("SDOC_SEQNO", typeof(string));
            }
            foreach (DataRow Rows in dsTempTable.Rows)
            {
                sTempMDOC_NO = Rows["MDOCNO"].ToString();
                sTempMDOC_SEQNO = Rows["MDOCSEQ"].ToString();
                sapTemp.Rows.Add(sTempSAP_TYPE, sTempIF_KEY, sTempMDOC_NO, sTempMDOC_SEQNO); // 후단 코드 실행시 EXCEPTION 상황 SAP CANCLE 정보 -- 실적등록
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
        
        }

        private void RollbackLog(DBHelper helper, DataSet dsTemp, DataTable[] tableGroup, string sMSG_ERR, string sResult, bool sapRollbackLogFlag)
        {
            try
            {
                if (sapRollbackLogFlag)// sap 롤백에 대한 로그 저장
                {
                    if (dsTemp.Tables.Count == 0) return;

                    if (dsTemp.Tables[1] != null)
                    {
                        if (dsTemp.Tables[1].Rows.Count > 0)
                        {
                            if (dsTemp.Tables[1].Rows[0][0].ToString() != "1")
                            {
                                foreach (DataRow Rows in dsTemp.Tables[1].Rows) //실적전송 롤백 수행 로그 저장
                                {
                                    helper.ExecuteNoneQuery("SP_HL_ROLLBACK_LOG", CommandType.StoredProcedure
                                    , helper.CreateParameter("P_DOC_NO", dsTemp.Tables[1].Columns.Contains("MDOCNO") ? Rows["MDOCNO"] : "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_DOC_SEQNO", dsTemp.Tables[1].Columns.Contains("MDOCSEQ") ? Rows["MDOCSEQ"] : "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_LOT_NO", "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_ORDER_NO", dsTemp.Tables[1].Columns.Contains("AUFNR") ? Rows["AUFNR"] : "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_WORKCENTERCODE", dsTemp.Tables[1].Columns.Contains("WORKCENTERCODE") ? Rows["WORKCENTERCODE"] : "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_MACH_CD", "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_PRDCD", "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_QTY", "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_MATNR", "", DbType.String, ParameterDirection.Input)
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
                    if (tableGroup.Length == 0) return;
                    if (tableGroup[0] != null)
                    {
                        if (tableGroup[0].Rows.Count > 0)
                        {
                            if (tableGroup[0].Rows[0][0].ToString() != "1")
                            {
                                foreach (DataRow Rows in tableGroup[0].Rows) //실적등록 및 폐품등록 실패시 롤백 발생원인 저장 - 실적등록 로그
                                {
                                    helper.ExecuteNoneQuery("SP_HL_ROLLBACK_LOG", CommandType.StoredProcedure
                                    , helper.CreateParameter("P_DOC_NO", tableGroup[0].Columns.Contains("MDOCNO") ? Rows["MDOCNO"] : "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_DOC_SEQNO", tableGroup[0].Columns.Contains("MDOCSEQ") ? Rows["MDOCSEQ"] : "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_LOT_NO", tableGroup[0].Columns.Contains("LOTNO_FROM") ? Rows["LOTNO_FROM"] : "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_ORDER_NO", tableGroup[0].Columns.Contains("AUFNR") ? Rows["AUFNR"] : "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_WERKS", tableGroup[0].Columns.Contains("WERKS") ? Rows["WERKS"] : "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_WORKCENTERCODE", "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_MACH_CD", "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_PRDCD", "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_QTY", tableGroup[0].Columns.Contains("CCNT") ? Rows["CCNT"] : "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_MATNR", tableGroup[0].Columns.Contains("MATNR") ? Rows["MATNR"] : "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_BUDAT", tableGroup[0].Columns.Contains("BUDAT") ? Rows["BUDAT"] : "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_RESULT", sResult, DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_REMARK", "LOTNO_FROM : " + (tableGroup[0].Columns.Contains("LOTNO_FROM") ? Rows["LOTNO_FROM"].ToString() : "") + " "
                                                                         + "LOTNO_TO : " + (tableGroup[0].Columns.Contains("LOTNO_TO") ? Rows["LOTNO_TO"].ToString() : "") + " "
                                                                         + sMSG_ERR, DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_MBLNR", tableGroup[0].Columns.Contains("SDOC_NO") ? Rows["SDOC_NO"] : "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_MJAHR", tableGroup[0].Columns.Contains("SDOC_SEQNO") ? Rows["SDOC_SEQNO"] : "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_I_IF_ID", dsTemp.Tables[0].Rows[0]["I_IF_ID"].ToString(), DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input));
                                }
                            }
                        }
                    }
                    if (tableGroup[1] != null)
                    {
                        if (tableGroup[1].Rows.Count > 0)
                        {
                            if (tableGroup[1].Rows[0][0].ToString() != "1")
                            {
                                foreach (DataRow Rows in tableGroup[1].Rows)//실적등록 및 폐품등록 실패시 롤백 발생원인 저장 - 폐품등록 로그
                                {
                                    helper.ExecuteNoneQuery("SP_HL_ROLLBACK_LOG", CommandType.StoredProcedure
                                    , helper.CreateParameter("P_DOC_NO", tableGroup[1].Columns.Contains("MDOCNO") ? Rows["MDOCNO"] : "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_DOC_SEQNO", tableGroup[1].Columns.Contains("MDOCSEQ") ? Rows["MDOCSEQ"] : "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_LOT_NO", tableGroup[1].Columns.Contains("LOTNO") ? Rows["LOTNO"] : "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_ORDER_NO", tableGroup[1].Columns.Contains("AUFNR") ? Rows["AUFNR"] : "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_WORKCENTERCODE", tableGroup[1].Columns.Contains("WORKCENTERCODE") ? Rows["WORKCENTERCODE"].ToString() : "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_MACH_CD", "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_PRDCD", "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_QTY", tableGroup[1].Columns.Contains("SCRQTY") ? Rows["SCRQTY"] : "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_MATNR", tableGroup[1].Columns.Contains("MATNR") ? Rows["MATNR"] : "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_BUDAT", tableGroup[1].Columns.Contains("BUDAT") ? Rows["BUDAT"] : "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_RESULT", sResult, DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_REMARK", (tableGroup[1].Columns.Contains("SCRAPREASON") ? Rows["SCRAPREASON"].ToString() : "") + " " + sMSG_ERR, DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_MBLNR", tableGroup[1].Columns.Contains("SDOC_NO") ? Rows["SDOC_NO"] : "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_MJAHR", tableGroup[1].Columns.Contains("SDOC_SEQNO") ? Rows["SDOC_SEQNO"] : "", DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_I_IF_ID", dsTemp.Tables[2].Rows[0]["I_IF_ID"].ToString(), DbType.String, ParameterDirection.Input)
                                    , helper.CreateParameter("P_USERID", Common.UserID, DbType.String, ParameterDirection.Input));
                                }
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                LogFile.WriteLog("PS 등급변경 ROLLBACK LOG 기록 에러 Exception 발생 [" + ex.Message + "]");
            }
        }

        #region FUNCTION
        private void InitControl()
        {
            lblCHG_IN_PER_CNT.Text = lblIN_PER_CNT.Text;      //속당매수

            lblCHG_REAM.Text = "0";      //변경연수
            lblCHG_WGT.Text = "0";      //변경중량
            lblCHG_SCNT.Text = "0";      //속수

            lblSUM_REAM.Text = "0";      //연수합
            lblIN_REAM.Text = lblINPUT_REAM.Text;      //투입연수
            lblDISPO_REAM.Text = lblINPUT_REAM.Text;      //파지연수
        }

        private void AutoCalculation()
        {
            Decimal dCHANGE_REAM = 0;     // 변경연수
            Decimal dIN_PER_CNT = 0;      // 팔레트당 연수
            Decimal dDISPO_REAM = 0;     // 파지연수

            Decimal.TryParse(lblCHG_REAM.Text.ToString().Replace(",", ""), out dCHANGE_REAM);         // 변경연수
            Decimal.TryParse(lblCHG_IN_PER_CNT.Text.ToString().Replace(",", ""), out dIN_PER_CNT);        // 팔레트당 연수

            Decimal.TryParse(lblDISPO_REAM.Text.ToString().Replace(",", ""), out dDISPO_REAM);        // 팔레트당 연수

            gdDISPO_REAM = dDISPO_REAM;

            // 속수
            if (dCHANGE_REAM <= 0 || dIN_PER_CNT <= 0)
            {
                lblCHG_SCNT.Text = "0";      //속수
            }
            else
            {
                Decimal dCNT = (dCHANGE_REAM * 500) / dIN_PER_CNT;
                lblCHG_SCNT.Text = string.Format("{0:#,##0}", (int)Math.Ceiling(dCNT));
            }

            // 변경중량
            if (gdBS_WGT <= 0 || gdWLEN <= 0 || gdVLEN <= 0)
            {
                lblCHG_WGT.Text = "0";
                gdDISPO_WGT = 0;
            }
            else
            {
                Decimal dValue = (dCHANGE_REAM * 500) * ((Decimal)gdBS_WGT / 1000) * ((Decimal)gdWLEN / 1000) * ((Decimal)gdVLEN / 1000);

                lblCHG_WGT.Text = string.Format("{0:#,0.###}", dValue);

                if(dDISPO_REAM > 0)
                    gdDISPO_WGT = (dDISPO_REAM * 500) * ((Decimal)gdBS_WGT / 1000) * ((Decimal)gdWLEN / 1000) * ((Decimal)gdVLEN / 1000);
                else
                    gdDISPO_WGT  = 0;
            }
        }

        private void POPUP_FIND_MATNR()
        {
            POP_WRK80 pop = new POP_WRK80(lblMATNR.Text);
            pop.ShowDialog(this);
            if (pop.DialogResult == DialogResult.OK)
            {
                if (lblMATNR.Text == pop.ResultMATNR)
                {
                    string sMsg = string.Format("변경전 자재코드 : {0}\r\n선택한 자재코드 : {1}\r\n\r\n변경전 자재코드와 동일한 자재코드는 등급변경 할수 없습니다.\r\n다른 자재코드를 선택 하세요.", lblMATNR.Text, pop.ResultMATNR);
                    new POPUP.MessageForm(sMsg, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return;
                }

                lblMATNR_NEW.Text = pop.ResultMATNR;
                lblMATNR_NEW_NM.Text = pop.ResultMATNR_NM;
                lblPCODE_NEW_NM.Text = pop.ResultPCODE_NM;

                gdBS_WGT = Convert.ToDecimal(pop.ResultDoubleBS_WGT);
                gdWLEN = Convert.ToDecimal(pop.ResultDoubleWLEN);
                gdVLEN = Convert.ToDecimal(pop.ResultDoubleVLEN);
            }

            lblCHG_REAM.Text = "0";      //변경연수
            lblCHG_WGT.Text = "0";      //변경중량
            lblCHG_SCNT.Text = "0";      //속수
        }
        #endregion

        #region < EVNET >

        private void bBox1_buttonClickEvent(MESButton sender, ButtonBox.ButtonClickEventArg e)
        {
            try
            {
                if (!this.bUseNetwork)
                {
                    SetMessage("네트워크 상태를 확인하시기 바랍니다.");
                    return;
                }

                MESButton btn = sender;

                switch (btn.Tag.ToString())
                {
                    case "Confirm":  //등급변경
                        if (doConfirm() == true)
                        {
                            this.Close();
                        }
                        break;

                    case "Close": //이전화면
                        this.Close();
                        break;
                }
            }
            catch (Oracle.ManagedDataAccess.Client.OracleException oe)
            {
                SetMessage(oe.Message);
            }

            catch (Exception ex)
            {
                SetMessage(ex.Message);
                LogFile.WriteLog("POP_WRK37.bBox1_buttonClickEvent Error => " + ex.Message);
            }
            finally
            {

            }
        }

        private void btnCancel_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        private void btnItem_Click(object sender, EventArgs e)
        {
            POPUP_FIND_MATNR();
            //POP_WRK80 pop = new POP_WRK80(lblMATNR.Text);
            //pop.ShowDialog(this);
            //if (pop.DialogResult == DialogResult.OK)
            //{
            //    lblMATNR_NEW.Text = pop.ResultMATNR;
            //    lblMATNR_NEW_NM.Text = pop.ResultMATNR_NM;
            //    lblPCODE_NEW_NM.Text = pop.ResultPCODE_NM;
            //    //Decimal dBS_WGT = 0;       // 평량
            //    //Decimal dWLEN = 0;         // 가로길이
            //    //Decimal dVLEN = 0;         // 세로길이

            //    gdBS_WGT = Convert.ToDecimal(pop.ResultDoubleBS_WGT);
            //    gdWLEN = Convert.ToDecimal(pop.ResultDoubleWLEN);
            //    gdVLEN = Convert.ToDecimal(pop.ResultDoubleVLEN);
            //}
        }

        #endregion
        private void lblINPUT_REAM_Click(object sender, EventArgs e)
        {
            DAResultNum pop = new DAResultNum();
            pop.LabelTitle = "투입 연수 입력 ";
            pop.LabelHeader = "투입 연수";
            pop.ContentMaxLength = 4;

            pop.ShowDialog(this);

            if (pop.DialogResult == DialogResult.OK)
            {
                Decimal dPROD_REAM = Convert.ToDecimal(lblPROD_REAM.Text.Replace(",",""));                    

                if (dPROD_REAM >= Convert.ToDecimal(pop.ResultDouble))
                {
                    lblINPUT_REAM.Text = string.Format("{0:#,0.###}", pop.ResultDouble);

                    lblREMAIN_REAM.Text = string.Format("{0:#,0.###}", dPROD_REAM - Convert.ToDecimal(pop.ResultDouble));

                    // 초기화
                    // --------------------------------------------------------
                    InitGrid();

                    lblSUM_REAM.Text = "0";      //연수합
                    lblIN_REAM.Text = lblINPUT_REAM.Text;           //투입연수
                    lblDISPO_REAM.Text = lblINPUT_REAM.Text;        //파지연수
                    lblCHG_REAM.Text = "0";
                    // --------------------------------------------------------

                    AutoCalculation();
                }
                else
                {
                    new POPUP.MessageForm("투입량이 실적량을 초과할 수없습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                }
            }
        }

        private void lblCHANGE_REAM_Click(object sender, EventArgs e)
        {
            DAResultNum pop = new DAResultNum();
            pop.LabelTitle = "변경 연수 입력 ";
            pop.LabelHeader = "변경 연수";
            pop.ContentMaxLength = 4;

            pop.ShowDialog(this);

            if (pop.DialogResult == DialogResult.OK)
            {
                // 파지연수가 등록 가능한 연수
                Decimal dREMAIN_REAM = Convert.ToDecimal(lblDISPO_REAM.Text.Replace(",", ""));

                if (dREMAIN_REAM >= Convert.ToDecimal(pop.ResultDouble))
                {
                    lblCHG_REAM.Text = string.Format("{0:#,0.###}", Convert.ToDecimal(pop.ResultDouble));

                    AutoCalculation();
                }
                else
                {
                    new POPUP.MessageForm("변경 연수가 가용 연수를 초과 합니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                }
            }
        }

        private void lblPF_IN_PER_CNT_Click(object sender, EventArgs e)
        {
            DAResultQty pop = new DAResultQty();
            pop.LabelTitle = "속당 매수 입력 ";
            pop.LabelHeader = "속당 매수";
            pop.ContentMaxLength = 4;

            pop.ShowDialog(this);

            if (pop.DialogResult == DialogResult.OK)
            {
                lblCHG_IN_PER_CNT.Text = string.Format("{0:#,0}", Convert.ToDecimal(pop.ResultDouble));
                AutoCalculation();
            }

        }

        private void lblWRK_ORDR_RMK_Click(object sender, EventArgs e)
        {
            DAResultText pop = new DAResultText("등급변경 비고입력", lblCHG_ORDR_RMK.Text.ToString());
            pop.ContentMaxLength = 100;

            pop.ShowDialog(this);
            if (pop.DialogResult == DialogResult.OK)
            {
                lblCHG_ORDR_RMK.Text = pop.ResultString;
            }
        }

        private void btnAdd_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(lblMATNR_NEW.Text))
            {
                POPUP_FIND_MATNR();
                return;
            }

            try
            {
                Decimal dIN_REAM = 0;          // 투입연수
                Decimal dSUM_REAM = 0;         // 연수합
                Decimal dCHANGE_REAM = 0;      // 변경연수
                Decimal dWGT = 0;        // 중량

                Decimal.TryParse(lblIN_REAM.Text.ToString().Replace(",", ""), out dIN_REAM);             // 투입연수
                Decimal.TryParse(lblSUM_REAM.Text.ToString().Replace(",", ""), out dSUM_REAM);           // 연수합
                Decimal.TryParse(lblCHG_REAM.Text.ToString().Replace(",", ""), out dCHANGE_REAM);     // 변경연수
                Decimal.TryParse(lblCHG_WGT.Text.ToString().Replace(",", ""), out dWGT);     // 중량

                if (dCHANGE_REAM <= 0)
                {
                    new POPUP.MessageForm("변경 연수를 입력 하십시오.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return;
                }

                if ((dIN_REAM - dSUM_REAM) < dCHANGE_REAM)
                {
                    new POPUP.MessageForm("연수값이 가용량을 초과합니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return;
                }

                if (dIN_REAM <= 0)
                {
                    new POPUP.MessageForm("투입 연수를 확인 바랍니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
                    return;
                }

                DataRow dr = Grid1.DataSource.NewRow();
                dr["IND_BCD"] = "채번예정";
                dr["REAM"] = string.Format("{0:#0.###}", dCHANGE_REAM);     // 연수
                dr["WGT"] = string.Format("{0:#0.###}", dWGT);              // 중량
                dr["MATNR"] = lblMATNR_NEW.Text;                            // 자재코드
                dr["IN_PER_CNT"] = lblCHG_IN_PER_CNT.Text.Replace(",", ""); // 속당매수
                dr["SCNT"] = lblCHG_SCNT.Text.Replace(",", "");             // 속수
                dr["REMARK"] = lblCHG_ORDR_RMK.Text;                           // 비고
                Grid1.DataSource.Rows.Add(dr);

                dSUM_REAM = dSUM_REAM + dCHANGE_REAM;

                lblSUM_REAM.Text = string.Format("{0:#0.###}", dSUM_REAM);                      //연수합

                lblDISPO_REAM.Text = string.Format("{0:#0.###}", dIN_REAM - dSUM_REAM);         //파지연수

                AutoCalculation();
            }
            catch (Exception ex)
            {

            }
        }

        private void btnDelete_Click(object sender, EventArgs e)
        {
            try
            {
                if (Grid1.Row == null)
                {
                    return;
                }

                if (Grid1.Rows.Count > 0)
                {
                    Grid1.Row.Delete(false);
                }

                DataTable dt = Grid1.DataSource;
                if (dt.Rows.Count > 0)
                {
                    Decimal dIN_REAM = 0;          // 투입연수
                    Decimal dSUM_REAM = 0;

                    Decimal.TryParse(lblIN_REAM.Text.ToString().Replace(",", ""), out dIN_REAM);             // 투입연수

                    foreach (DataRow dr in dt.Rows)
                    {
                        Decimal dREAM = 0;
                        Decimal.TryParse(dr["REAM"].ToString().Replace(",", ""), out dREAM);             // 투입연수

                        dSUM_REAM += dREAM;
                    }

                    lblSUM_REAM.Text = string.Format("{0:#0.###}", dSUM_REAM);                      //연수합
                    lblDISPO_REAM.Text = string.Format("{0:#0.###}", dIN_REAM - dSUM_REAM);         //파지연수

                    AutoCalculation();
                }
                else
                {
                    lblSUM_REAM.Text = "0";      //연수합
                    lblIN_REAM.Text = lblINPUT_REAM.Text;      //투입연수
                    lblDISPO_REAM.Text = lblINPUT_REAM.Text;      //파지연수
                }

            }
            catch (Exception ex)
            {
            }
        }

        private void btnInit_Click(object sender, EventArgs e)
        {
            InitGrid();

            lblSUM_REAM.Text = "0";      //연수합
            lblIN_REAM.Text = lblINPUT_REAM.Text;      //투입연수
            lblDISPO_REAM.Text = lblINPUT_REAM.Text;      //파지연수
        }

        private void lblMATNR_NEW_Click(object sender, EventArgs e)
        {
            POPUP_FIND_MATNR();
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
    }
}
