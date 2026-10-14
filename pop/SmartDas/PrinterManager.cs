using System;
using System.Management;
using System.Data;
using SAMMI;
using System.Windows.Forms;

using SmartDas.POPUP;
using System.Threading;
using System.Configuration;
using QRCoder;
using System.Drawing;
using System.Text;
using Oracle.ManagedDataAccess.Client;

namespace SmartDas
{

    public static class PrinterManager
    {
        #region < 점보롤 인쇄 영역 >

        public static void PrintJumboRoll(string sRES_IND_BCD)
        {
            string[] sARR_IND_BCD = sRES_IND_BCD.Split('|');

            DBHelper helper = new DBHelper();
            DataTable dtRtn;

            REPORT rp = new REPORT();

            try
            {
                rp.EXCEL_OPEN(Common.PlantCode);

                foreach (string sIND_BCD in sARR_IND_BCD)
                {
                    if (sIND_BCD.Length > 0)
                    {
                        // 점보롤 인쇄용 정보 조회
                        dtRtn = helper.FillTable("SP_POP_WRK24_S02", CommandType.StoredProcedure
                                                            , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)              // 플랜트
                                                            , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)          //작업장코드(설비코드)
                                                            , helper.CreateParameter("P_IND_BCD", sIND_BCD, DbType.String, ParameterDirection.Input)                    //개별바코드
                                                            );
                        if (helper.RSCODE == "S")
                        {
                            if (dtRtn.Rows.Count == 1)
                            {
                                //조회결과 입력용 Row생성
                                REPORT_ITEM JRitem = new REPORT_ITEM();

                                JRitem.IND_BCD = sIND_BCD;     // 개별바코드
                                JRitem.PCODE_NM = dtRtn.Rows[0]["PCODE_NM"].ToString();     // 지종
                                //JRitem.BS_WGT = dtRtn.Rows[0]["BS_WGT"].ToString();         // 평량
                                JRitem.BS_WGT = Common.StrFormatInteger(dtRtn.Rows[0]["BS_WGT"].ToString());          // 평량
                                JRitem.JROLLCNT = Common.StrFormatInteger(dtRtn.Rows[0]["JROLLCNT"].ToString());     // 계획권치수
                                JRitem.PRFM_ROLLCNT = Common.StrFormatInteger(dtRtn.Rows[0]["ROLLCNT"].ToString());         // 실적권치수
                                JRitem.PRFM_WGT = Common.StrFormatDouble(dtRtn.Rows[0]["WGT"].ToString());          // 실적중량
                                JRitem.RSPEED = Common.StrFormatInteger(dtRtn.Rows[0]["RSPEED"].ToString());         // 선속

                                JRitem.JR_MACHINE = dtRtn.Rows[0]["MACHINE_NM"].ToString();   // J/R 호기
                                JRitem.MR_MACHINE = dtRtn.Rows[0]["TO_MACHINE_NM"].ToString();// M/R 지시호기
                                JRitem.STM_TM = dtRtn.Rows[0]["PRD_STR_DATE"].ToString();       // 생산시간 : 시작
                                JRitem.END_TM = dtRtn.Rows[0]["PRD_END_DATE"].ToString();       // 생산시간 : 종료
                                JRitem.WRK_TM = Common.StrFormatInteger(dtRtn.Rows[0]["TM"].ToString());       // 가동시간
                                JRitem.PRD_DIV = dtRtn.Rows[0]["WRK_TYPE"].ToString();      // 생산유형
                                JRitem.PRD_DATE = dtRtn.Rows[0]["WRK_DATE"].ToString();     // 생산일시

                                JRitem.WRK_SHIFT = dtRtn.Rows[0]["WRK_CLASS"].ToString();    // 반
                                JRitem.WRK_NAME = dtRtn.Rows[0]["WRK_NAME"].ToString();     // 작업자
                                JRitem.LOT_NO = dtRtn.Rows[0]["LOT_NO"].ToString();       // LOT_NO (10자리)

                                JRitem.ORDER_NO = dtRtn.Rows[0]["ORDER_NO"].ToString();       // ORDER_NO (10자리)

                                JRitem.RUN_STA = dtRtn.Rows[0]["RUN_STA"].ToString(); // dtRtn.Rows[0][""].ToString();     // 비계획 유무
                                JRitem.PRD_NO = dtRtn.Rows[0]["PRD_NO"].ToString();       // 생산번호
                                JRitem.ORDER_RMK = dtRtn.Rows[0]["ORDER_RMK"].ToString();    // 지시사항
                                JRitem.WRK_ORDR_RMK = dtRtn.Rows[0]["RMK"].ToString();      // 비고

                                string pstrERR = "";
                                //REPORT rp = new REPORT();
                                //rp.EXCEL_OPEN(Common.PlantCode);
                                rp.JR_PRINT(JRitem, ref pstrERR);

                                LogFile.WriteLog(string.Format("점보롤 바코드 발행 : {0}", sIND_BCD), LogType.PROC);
                                //if (pstrERR.Length > 0)
                                //{
                                //    //rp.EXCEL_CLOSE();
                                //    //return;
                                //}
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                //CleanOrderLabel();
                //                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                LogFile.WriteLog("SP_POP_WRK24_S02.ReportPrintJumboRoll Error => " + ex.Message);
                //SetMessage(ex.Message);
                throw ex;
            }
            finally
            {
                rp.EXCEL_CLOSE();
            }
        }
        #endregion

        #region < 밀롤 인쇄 영역 >

        public static bool PrintMillRoll(string sRES_IND_BCD, bool bRePrint, bool qrDiv, int nPrtRollCnt = 1, int nPrtSheetCnt = 1)
        {
            string[] sARR_IND_BCD = sRES_IND_BCD.Split('|');

            DBHelper helper = new DBHelper();
            DataTable dtRtn;

            REPORT rp = new REPORT();

            try
            {
                foreach (string sIND_BCD in sARR_IND_BCD)
                {
                    if (sIND_BCD.Length > 0)
                    {
                        Console.WriteLine("IND_BCD = [" + sIND_BCD + "]");

                        // 밀롤 인쇄용 정보 조회
                        dtRtn = helper.FillTable("SP_POP_WRK25_S03", CommandType.StoredProcedure
                                                            , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)              // 플랜트
                                                            , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)          //작업장코드(설비코드)
                                                            , helper.CreateParameter("P_IND_BCD", sIND_BCD, DbType.String, ParameterDirection.Input)                    //개별바코드
                                                            );
                        if (helper.RSCODE == "S")
                        {
                            if (dtRtn.Rows.Count == 1)
                            {
                                //LogFile.WriteLog(string.Format("NEXT_PROC = {0}, SLITER{1}", dtRtn.Rows[0]["NEXT_PROC"].ToString(), dtRtn.Rows[0]["SLITER"].ToString()));

                                //슬리터이동
                                if (dtRtn.Rows[0]["SLITER"].ToString() == "Y")
                                {
                                    if (qrDiv)
                                    {
                                        nPrtRollCnt = 2;

                                        //QR코드
                                        LogFile.WriteLog(string.Format("밀롤 (슬리터이동) QR 발행[{0}매] : {1}", nPrtSheetCnt, sIND_BCD), LogType.PROC);
                                        if (PrintMillRoll_QR(dtRtn, sIND_BCD, nPrtRollCnt) == false)
                                        {
                                            return false;
                                        }
                                    }
                                    else
                                    {
                                        //기존 슬리터이동 라벨(A4)
                                        if (rp.ReadyCheck() == false)
                                        {
                                            rp.EXCEL_OPEN(Common.PlantCode);
                                        }
                                        LogFile.WriteLog(string.Format("밀롤 (슬리터이동) 발행[{0}매] : {1}", nPrtSheetCnt, sIND_BCD), LogType.PROC);
                                        PrintMillRoll_SHEET(rp, dtRtn, sIND_BCD, nPrtSheetCnt);
                                    }
                                }
                                //시트
                                else if (dtRtn.Rows[0]["NEXT_PROC"].ToString().Equals("SHEET"))
                                {
                                    if (bRePrint == true)
                                    {
                                        if (rp.ReadyCheck() == false)
                                        {
                                            rp.EXCEL_OPEN(Common.PlantCode);
                                        }
                                        LogFile.WriteLog(string.Format("밀롤 판지 재발행[{0}매] : {1}", nPrtSheetCnt, sIND_BCD), LogType.PROC);
                                        PrintMillRoll_SHEET(rp, dtRtn, sIND_BCD, nPrtSheetCnt);
                                    }
                                    else
                                    {
                                        LogFile.WriteLog(string.Format("밀롤 판지 발행(오토라벨) : {0}", sIND_BCD), LogType.PROC);
                                    }
                                }
                                //원지
                                else
                                {
                                    //밀롤창고적치용
                                    if (qrDiv)
                                    {
                                        nPrtRollCnt = 2;

                                        //QR코드
                                        LogFile.WriteLog(string.Format("밀롤 원지 QR 발행[{0}매] : {1}", nPrtSheetCnt, sIND_BCD), LogType.PROC);
                                        if (PrintMillRoll_QR(dtRtn, sIND_BCD, nPrtRollCnt) == false)
                                        {
                                            return false;
                                        }
                                    }
                                    else
                                    {
                                        //최종라벨
                                        LogFile.WriteLog(string.Format("밀롤 원지 발행[{0}매] : {1}", nPrtRollCnt, sIND_BCD), LogType.PROC);
                                        if (PrintMillRoll_ROLL(dtRtn, sIND_BCD, nPrtRollCnt) == false)
                                        {
                                        return false;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                //CleanOrderLabel();
                //                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                LogFile.WriteLog("SP_POP_WRK25_S03.DoFind Error => " + ex.Message);
                throw ex;
            }
            finally
            {
                rp.EXCEL_CLOSE();
            }

            return true;
        }

        public static bool PrintSliter(string sRES_IND_BCD, bool qrDiv, int nPrtRollCnt = 1)
        {
            string[] sARR_IND_BCD = sRES_IND_BCD.Split('|');

            DBHelper helper = new DBHelper();
            DataTable dtRtn;

            try
            {
                foreach (string sIND_BCD in sARR_IND_BCD)
                {
                    if (sIND_BCD.Length > 0)
                    {
                        Console.WriteLine("IND_BCD = [" + sIND_BCD + "]");

                        // 밀롤 / 슬리터 인쇄용 정보 조회
                        dtRtn = helper.FillTable("SP_POP_WRK25_S03", CommandType.StoredProcedure
                                                            , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)              // 플랜트
                                                            , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)          //작업장코드(설비코드)
                                                            , helper.CreateParameter("P_IND_BCD", sIND_BCD, DbType.String, ParameterDirection.Input)          //개별바코드
                                                            );
                        if (helper.RSCODE == "S")
                        {
                            if (dtRtn.Rows.Count == 1)
                            {
                                if (qrDiv)
                                {
                                    //QR코드
                                    LogFile.WriteLog(string.Format("슬리터 원지 QR발행[{0}매] : {1}", nPrtRollCnt, sIND_BCD), LogType.PROC);
                                    if (PrintMillRoll_QR(dtRtn, sIND_BCD, nPrtRollCnt) == false)
                                    {
                                        return false;
                                    }
                                }
                                else
                                {
                                    //최종라벨
                                    LogFile.WriteLog(string.Format("슬리터 원지 발행[{0}매] : {1}", nPrtRollCnt, sIND_BCD), LogType.PROC);
                                    if (PrintMillRoll_ROLL(dtRtn, sIND_BCD, nPrtRollCnt) == false)
                                    {
                                        return false;
                                    }
                                }
                            }
                        }
                    }
                }
                
            }
            catch (Exception ex)
            {
                //CleanOrderLabel();
                //                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                LogFile.WriteLog("PrintSliter.DoFind Error => " + ex.Message);
                throw ex;
            }
            finally
            {
                
            }

            return true;
        }

        /// <summary>
        /// 라미네이팅 인쇄/코팅, 슬리팅
        /// </summary>
        /// <param name="sRES_IND_BCD"></param>
        /// <param name="nPrtRollCnt"></param>
        /// <returns></returns>
        public static bool PrintLami_3B(string sRES_IND_BCD, int nPrtRollCnt = 1)
        {
            string[] sARR_IND_BCD = sRES_IND_BCD.Split('|');

            DBHelper helper = new DBHelper();
            DataTable dtRtn = null;

            try
            {
                foreach (string sIND_BCD in sARR_IND_BCD)
                {
                    if (sIND_BCD.Length > 0)
                    {
                        Console.WriteLine("IND_BCD = [" + sIND_BCD + "]");

                        // 밀롤 / 슬리터 인쇄용 정보 조회
                        dtRtn = helper.FillTable("SP_POP_LAMI_PRT_3B", CommandType.StoredProcedure
                                                            , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)              // 플랜트
                                                            , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)          //작업장코드(설비코드)
                                                            , helper.CreateParameter("P_IND_BCD", sIND_BCD, DbType.String, ParameterDirection.Input)          //개별바코드
                                                            );
                        if (helper.RSCODE == "S")
                        {
                            if (dtRtn.Rows.Count == 1)
                            {
                                LogFile.WriteLog(string.Format("라미네이팅 원지 발행[{0}매] : {1}", nPrtRollCnt, sIND_BCD), LogType.PROC);
                                PrintLami_SHEET(dtRtn, nPrtRollCnt);
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                //CleanOrderLabel();
                //                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                LogFile.WriteLog("PrintLami.DoFind Error => " + ex.Message);
                throw ex;
            }
            finally
            {

            }

            return true;
        }

        /// <summary>
        /// 라미네이팅 인쇄/코팅, 슬리팅
        /// </summary>
        /// <param name="sRES_IND_BCD"></param>
        /// <param name="nPrtRollCnt"></param>
        /// <returns></returns>
        public static bool PrintLami(string sRES_IND_BCD, int nPrtRollCnt = 1)
        {
            string[] sARR_IND_BCD = sRES_IND_BCD.Split('|');

            DBHelper helper = new DBHelper();
            DataTable dtRtn = null;

            try
            {
                foreach (string sIND_BCD in sARR_IND_BCD)
                {
                    if (sIND_BCD.Length > 0)
                    {
                        Console.WriteLine("IND_BCD = [" + sIND_BCD + "]");

                        // 밀롤 / 슬리터 인쇄용 정보 조회
                        dtRtn = helper.FillTable("SP_POP_LAMI_PRT", CommandType.StoredProcedure
                                                            , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)              // 플랜트
                                                            , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)          //작업장코드(설비코드)
                                                            , helper.CreateParameter("P_IND_BCD", sIND_BCD, DbType.String, ParameterDirection.Input)          //개별바코드
                                                            );
                        if (helper.RSCODE == "S")
                        {
                            if (dtRtn.Rows.Count == 1)
                            {
                                LogFile.WriteLog(string.Format("라미네이팅 원지 발행[{0}매] : {1}", nPrtRollCnt, sIND_BCD), LogType.PROC);
                                PrintLami_SHEET(dtRtn, nPrtRollCnt);
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                //CleanOrderLabel();
                //                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                LogFile.WriteLog("PrintLami.DoFind Error => " + ex.Message);
                throw ex;
            }
            finally
            {

            }

            return true;
        }

        public static void PrintLami_SHEET(DataTable dtTemp, int nPrtRollCnt)
        {
            //조회결과 입력용 Row생성
            REPORT_ITEM LAMIitem = new REPORT_ITEM();

            LAMIitem.TITLE_NAME = dtTemp.Rows[0]["TITLE_NAME"].ToString();          // 제조사명
            LAMIitem.PRD_DATE = dtTemp.Rows[0]["PRD_DATE"].ToString();            // 생산일자
            LAMIitem.SPEC = dtTemp.Rows[0]["SPEC"].ToString();               // 규격
            LAMIitem.PRFM_WGT = dtTemp.Rows[0]["PRFM_WGT"].ToString();     		// 중량
            LAMIitem.HEIGHT = dtTemp.Rows[0]["HEIGHT"].ToString();            // 길이
            LAMIitem.PCODE_NM = dtTemp.Rows[0]["PCODE_NM"].ToString();        // 지종
            LAMIitem.BS_WGT = dtTemp.Rows[0]["BS_WGT"].ToString();              // 평량
            LAMIitem.WRK_NAME = dtTemp.Rows[0]["WRK_NAME"].ToString();        // 작업자
            LAMIitem.LOT_NO = dtTemp.Rows[0]["LOT_NO"].ToString();              // LOT NO
            LAMIitem.IND_BCD = dtTemp.Rows[0]["IND_BCD"].ToString();          // 개별바코드(번호)
            LAMIitem.BAR_CODE = dtTemp.Rows[0]["BAR_CODE"].ToString();          // 개별바코드(바코드)

            string pstrERR = "";

            REPORT rp = new REPORT();
            rp.EXCEL_OPEN(Common.PlantCode);
            rp.LAMI_PRINT(LAMIitem, ref pstrERR, nPrtRollCnt);
            if (pstrERR.Length > 0)
            {
                rp.EXCEL_CLOSE();
                return;
            }
            rp.EXCEL_CLOSE();
        }
        
        public static void PrintMillRoll_SHEET(REPORT rp, DataTable dtRtn, string sIND_BCD, int nPrtSheetCnt)
        {
            //string[] sARR_IND_BCD = sRES_IND_BCD.Split('|');

            DBHelper helper = new DBHelper();
            //DataTable dtRtn;

            try
            {
                //foreach (string sIND_BCD in sARR_IND_BCD)
                {
                    //Console.WriteLine("IND_BCD = [" + sIND_BCD + "]");

                    //// 밀롤 인쇄용 정보 조회
                    //dtRtn = helper.FillTable("SP_POP_WRK25_S03", CommandType.StoredProcedure
                    //                                    , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)              // 플랜트
                    //                                    , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)          //작업장코드(설비코드)
                    //                                    , helper.CreateParameter("P_IND_BCD", sIND_BCD, DbType.String, ParameterDirection.Input)          //개별바코드
                    //                                    );

                    //if (dtRtn.Rows.Count == 1)
                    {
                        //조회결과 입력용 Row생성
                        REPORT_ITEM MRitem = new REPORT_ITEM();

                        MRitem.IND_BCD = sIND_BCD;                                                          // 개별바코드
                        MRitem.PCODE_NM = dtRtn.Rows[0]["PCODE_NM"].ToString();                             // 지종

                        MRitem.PRFM_ROLLCNT = Common.StrFormatInteger(dtRtn.Rows[0]["ROLLCNT"].ToString());         // 실적권치수
                        MRitem.PRFM_WGT = Common.StrFormatDouble(dtRtn.Rows[0]["PRFM_QTY"].ToString());         // 실적중량

                        MRitem.BS_WGT = Common.StrFormatInteger(dtRtn.Rows[0]["BS_WGT"].ToString());          // 평량

                        // ReWinder 규격 , 규격 처리
                        string spec = dtRtn.Rows[0]["MATNR_SPEC"].ToString();
                        /*
                        string[] rw_spec = spec.Split('*');

                        int nSpec = 0;
                        string REWIND_SPEC = "";

                        if (string.IsNullOrEmpty(rw_spec[0]) == false)
                        {
                            int.TryParse(rw_spec[0], out nSpec);

                            REWIND_SPEC = nSpec.ToString();
                        }
                        //MRitem.REWIND_SPEC = REWIND_SPEC;           // ReWinder 규격
                        */
                        string sMWIDTH_INPUT = Common.StrFormatInteger(dtRtn.Rows[0]["MWIDTH_INPUT"].ToString());  // 작업지시의 실지폭 
                        string sMWIDTH_USER = Common.StrFormatInteger(dtRtn.Rows[0]["MWIDTH_USER"].ToString()).Trim();   // 사용자 입력 실지폭

                        string sREWIND_SPEC = sMWIDTH_INPUT;
 
                        if (sMWIDTH_USER.Length > 0)
                        {
                            if (sMWIDTH_INPUT != sMWIDTH_USER)
                            {
                                sREWIND_SPEC += "(" + sMWIDTH_USER + ")";
                            }
                        }
                        
                        //MRitem.REWIND_SPEC = Common.StrFormatInteger(dtRtn.Rows[0]["MWIDTH_INPUT"].ToString());          // 실지폭 (Rewinder규격)
                        MRitem.REWIND_SPEC = sREWIND_SPEC;

                        MRitem.SPEC = spec;                         // 규격

                        MRitem.SEQ = dtRtn.Rows[0]["WRK_SEQ"].ToString();           // 생산순번
                        MRitem.WIDTH_NO = dtRtn.Rows[0]["WIDTH_NO"].ToString();     // 지폭순번

                        MRitem.JR_MACHINE = dtRtn.Rows[0]["JR_MACHINE_NM"].ToString();  // 점보롤호기
                        MRitem.MR_MACHINE = dtRtn.Rows[0]["MR_MACHINE_NM"].ToString();  // 밀롤호기
                        MRitem.CT_MACHINE = dtRtn.Rows[0]["CT_MACHINE_NM"].ToString();  // 재단호기

                        MRitem.PACKTYPE = dtRtn.Rows[0]["PACKTYPE"].ToString();  // 포장타입
                        MRitem.CUST_NM = dtRtn.Rows[0]["CUST_NM"].ToString();   // 거래처명

                        MRitem.PRD_DATE = dtRtn.Rows[0]["WRK_DATE"].ToString();     // 생산일시

                        MRitem.WRK_SHIFT = dtRtn.Rows[0]["WRK_CLASS"].ToString();    // 반
                        MRitem.WRK_NAME = dtRtn.Rows[0]["WRK_NAME"].ToString();     // 작업자

                        MRitem.LOT_NO = dtRtn.Rows[0]["LOT_NO"].ToString();       // LOT_NO (10자리)

                        MRitem.SALES_ORDR_NO = dtRtn.Rows[0]["SALES_ORDR_NO"].ToString();       // LOT_NO (10자리)

                        MRitem.ORDER_RMK = dtRtn.Rows[0]["ORDER_RMK"].ToString();    // 지시사항
                        MRitem.WRK_ORDR_RMK = dtRtn.Rows[0]["RMK"].ToString();      // 비고

                        string pstrERR = "";
                        //REPORT rp = new REPORT();
                        //rp.EXCEL_OPEN(Common.PlantCode);
                        rp.MR_PRINT(MRitem, ref pstrERR, nPrtSheetCnt);
                        //if (pstrERR.Length > 0)
                        //{
                        //    rp.EXCEL_CLOSE();
                        //    return;
                        //}
                        //rp.EXCEL_CLOSE();
                    }
                    //else
                    //{
                    //    //CleanOrderLabel();
                    //}
                }
            }
            catch (Exception ex)
            {
                //CleanOrderLabel();
                //                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                LogFile.WriteLog("SP_POP_WRK24_S03.DoFind Error => " + ex.Message);
                throw ex;
            }
        }


        private static bool doPrinter()
        {
            try
            {
                POP_Printer popPrinter = new POP_Printer();
                popPrinter.ShowDialog();
                if (popPrinter.DialogResult == DialogResult.OK)
                {
                    string PrinterName = Common.getConfig("PRINTER");//"ZT421";
                    if (!PrinterName.Contains("ZDesigner"))
                    {
                        new POPUP.MessageForm("선택된 프린터를 확인하여 주시기 바랍니다.", MessageBoxButtons.OK, "알   림").ShowDialog();
                        return false;
                    }
                }
                else
                {
                    return false;
                }
            }
            catch (Exception ex)
            {
                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog();
            }

            return true;
        }

        public static bool PrintMillRoll_ROLL(DataTable dtRtn, string sIND_BCD, int nPrnCnt=1)
        {
            //string[] sARR_IND_BCD = sRES_IND_BCD.Split('|');

            DBHelper helper = new DBHelper(false);
            //DataTable dtRtn;
            
            try
            {

                //string PrinterName = "ZT420";
                string PrinterName = SAMMI.IniFile.GetValue("KLEANNARA", "PRINTER", "");

                string sGapY = SAMMI.IniFile.GetValue("KLEANNARA", "PRT_GAP_Y", "0");

                string sZPL = "";
                string sTitle = "";       // 지종
                string sWeight = "";      // 평량
                string sWVLen = "";       // 규격
                string sReam = "";        // 연수
                string sTotWeight = "";   // 중량
                string sScnt = "";        // 속
                string sMcnt = "";        // 매수
                string sLength = "";      // 길이
                string sCore = "";        // 지관
                string sSPItemNo = "";    // 특별재고번호
                string sCustName = "";    // 고객명
                string sCustEx = "";      // 고객명추가정보
                string sLineCd = "";      // 생산호기
                string sLotNo = "";       // LOT NO
                string sWorker = "";      // 작업자
                string sOrderNo = "";     // ORDERNO
                //string sCINDBCD = "";      //재단개별바코드
                string sINDBCD = "";      // 개별바코드

                //foreach (string sIND_BCD in sARR_IND_BCD)
                {
                    // 밀롤 인쇄용 정보 조회
                    //dtRtn = helper.("SP_POP_WRK25_S03", CommandType.StoredProcedure
                    //                                    , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)              // 플랜트
                    //                                    , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)          //작업장코드(설비코드)
                    //                                    , helper.CreateParameter("P_IND_BCD", sIND_BCD, DbType.String, ParameterDirection.Input)          //개별바코드
                    //                                    );

                    //if (dtRtn.Rows.Count == 1)
                    {
                        //string sOrderNo = Grid1.Rows[i].Cells["OrderNo"].Value.ToString();
                        sTitle = dtRtn.Rows[0]["PCODE_NM"].ToString();                              //지종
                        sWeight = Common.StrFormatInteger(dtRtn.Rows[0]["BS_WGT"].ToString());      //평량
                        sWVLen = dtRtn.Rows[0]["MATNR_SPEC"].ToString();   //규격(가로세로)
                        sReam = "0";                                                                //연수 (원지포장 = 0)
                        sTotWeight = Common.StrFormatDouble(dtRtn.Rows[0]["PRFM_QTY"].ToString());  // 실적중량
                        sScnt = "0";                                                                // 속 (원지포장 = 0)
                        sMcnt = "0";                                                                // 매수 (원지포장 = 0)
                        sLength = Common.StrFormatInteger(dtRtn.Rows[0]["ROLLCNT"].ToString());     // 실적권치수
                        sCore = Common.StrFormatInteger(dtRtn.Rows[0]["CORE"].ToString());          // 지관
                        sSPItemNo = dtRtn.Rows[0]["SALES_ORDR_NO"].ToString();                      // ****************** 특별재고번호 가 세일즈오더 와 같은지 확인 *****************
                        sCustName = ""; // dtRtn.Rows[0]["CUST_NM"].ToString();                            // 고객명 (거래처명)
                        //sCustName = dtRtn.Rows[0]["CUST_NM"].ToString();                            // 고객명 (거래처명)
                        sCustEx = "";                                                               // 

                        //// 내수이면  작업자, 수출이면 작업자ID 를 출력함.
                        //// 품목코드의 5번째 자리가 2이면 수출, 1이면 내수 구분
                        //string sMATNR = dtRtn.Rows[0]["MATNR"].ToString();
                        //if (sMATNR.Length == 17)
                        //{
                        //    if (sMATNR.Substring(4, 1) == "1")
                        //        sWorker = dtRtn.Rows[0]["WRK_NAME"].ToString();                     // 내수이면 작업자이름
                        //    else
                        //        sWorker = dtRtn.Rows[0]["WRK_ID"].ToString();                       // 수출이면 작업자 ID 
                        //}
                        //else
                        //{
                        //    sWorker = dtRtn.Rows[0]["WRK_NAME"].ToString();                         // 폼목코드가 17자리가 아닌경우는 
                        //}
                        // 국가 코드 확인 *******************************************************************

                        sLineCd = dtRtn.Rows[0]["WIDTH_NO"].ToString();             //지폭 순번
                        sLotNo = dtRtn.Rows[0]["LOT_NO"].ToString();
                        sWorker = dtRtn.Rows[0]["EMPLID"].ToString();               //호기+win+사원번호
                        sINDBCD = sIND_BCD;
                        sOrderNo = dtRtn.Rows[0]["ORDER_NO"].ToString();            // 오더 번호

                        //    ,P_TITLE        IN VARCHAR2 --지종
                        //    ,P_WEIGHT       IN VARCHAR2 --평량
                        //    ,P_WVLEN        IN VARCHAR2 --규격
                        //    ,P_REAM         IN VARCHAR2 --연수
                        //    ,P_PGEWEW       IN VARCHAR2 --중량
                        //    ,P_SCNT         IN VARCHAR2 --속
                        //    ,P_MCNT         IN VARCHAR2 --매수
                        //    ,P_LENGTH       IN VARCHAR2 --길이
                        //    ,P_CORE         IN VARCHAR2 --지관
                        //    ,P_SPITEMNO     IN VARCHAR2 --특별재고번호
                        //    ,P_CUSTNM       IN VARCHAR2 --고객명
                        //    ,P_CUSTEX       IN VARCHAR2 --고객추가정보
                        //    ,P_LINECD       IN VARCHAR2 --생산호기
                        //    ,P_LOTNO        IN VARCHAR2 --LOT NO
                        //    ,P_WORKER       IN VARCHAR2 --작업자
                        //    ,P_ORDERNO      IN VARCHAR2 --ORDERNO
                        //    ,P_CINDBCD      IN VARCHAR2 --재단개별바코드
                        //    ,P_INDBCD       IN VARCHAR2 --개별바코드

                        //ZPL코드 프로시저 호출
                        helper.ExecuteNoneQuery("SP_INV_ZPL_PS", CommandType.StoredProcedure
                             , helper.CreateParameter("P_TYPE", "", DbType.String, ParameterDirection.Input) //라벨종류
                             , helper.CreateParameter("P_GAP_X", "0", DbType.String, ParameterDirection.Input) // 왼쪽여백
                             , helper.CreateParameter("P_GAP_Y", sGapY, DbType.String, ParameterDirection.Input) // 위쪽여백
                             , helper.CreateParameter("P_PRT_SPEED", "0", DbType.String, ParameterDirection.Input) // 속도
                             , helper.CreateParameter("P_PRT_STRENGTH", "0", DbType.String, ParameterDirection.Input) // 강도
                             , helper.CreateParameter("P_TITLE", sTitle, DbType.String, ParameterDirection.Input) //지종
                             , helper.CreateParameter("P_WEIGHT", sWeight, DbType.String, ParameterDirection.Input) //평량
                             , helper.CreateParameter("P_WVLEN", sWVLen, DbType.String, ParameterDirection.Input) //규격(가로세로)
                             , helper.CreateParameter("P_REAM", sReam, DbType.String, ParameterDirection.Input) //연수
                             , helper.CreateParameter("P_PGEWEW", sTotWeight, DbType.String, ParameterDirection.Input) //총중량
                             , helper.CreateParameter("P_SCNT", sScnt, DbType.String, ParameterDirection.Input) //속
                             , helper.CreateParameter("P_MCNT", sMcnt, DbType.String, ParameterDirection.Input) //매수
                             , helper.CreateParameter("P_LENGTH", sLength, DbType.String, ParameterDirection.Input) //길이
                             , helper.CreateParameter("P_CORE", sCore, DbType.String, ParameterDirection.Input) //지관
                             , helper.CreateParameter("P_SPITEMNO", sSPItemNo, DbType.String, ParameterDirection.Input) //특별재고번호
                             , helper.CreateParameter("P_CUSTNM", sCustName, DbType.String, ParameterDirection.Input) //고객명
                             , helper.CreateParameter("P_CUSTEX", sCustEx, DbType.String, ParameterDirection.Input) //고객추가정보
                             , helper.CreateParameter("P_LINECD", sLineCd, DbType.String, ParameterDirection.Input) //생산호기
                             , helper.CreateParameter("P_LOTNO", sLotNo, DbType.String, ParameterDirection.Input) //LotNo
                             , helper.CreateParameter("P_WORKER", sWorker, DbType.String, ParameterDirection.Input) //작업자
                             , helper.CreateParameter("P_ORDERNO", sOrderNo, DbType.String, ParameterDirection.Input) //지시번호
                             , helper.CreateParameter("P_CINDBCD", "", DbType.String, ParameterDirection.Input) //바코드
                             , helper.CreateParameter("P_INDBCD", sINDBCD, DbType.String, ParameterDirection.Input) //바코드
                             , helper.CreateParameter("P_ZPL", DbType.String, ParameterDirection.Output, null, 4000)
                           );

                        if (helper.RSCODE == "E")
                        {
                            return false;
                        }
                        else
                        {
                            sZPL = helper.Parameters["P_ZPL"].Value.ToString();
                        }

                        foreach (string sPrinter in System.Drawing.Printing.PrinterSettings.InstalledPrinters)
                        {
                            if (sPrinter.Contains(PrinterName))
                            {
                                if (nPrnCnt > 1)
                                {
                                    string rtnMsg = CheckPrinterState(sPrinter);

                                    if (rtnMsg == "OK")
                                    {
                                        for (int i = 0; i < nPrnCnt; i++)
                                        {
                                            SAMMI.RawPrinterHelper.SendStringToBytePrinter(sPrinter, sZPL);
                                        }
                                    }
                                    else
                                    {
                                        new POPUP.MessageForm(rtnMsg, MessageBoxButtons.OK, "알   림").ShowDialog();
                                        return false;
                                    }
                                }
                                else
                                {
                                    string rtnMsg = CheckPrinterState(sPrinter);
                                    if (rtnMsg == "OK")
                                    {
                                        SAMMI.RawPrinterHelper.SendStringToBytePrinter(sPrinter, sZPL);
                                    }
                                    else
                                    {
                                        new POPUP.MessageForm(rtnMsg, MessageBoxButtons.OK, "알   림").ShowDialog();
                                        return false;
                                    }
                                }

                                break;
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                LogFile.WriteLog("PrintMillRoll_ROLL.doPrint Error => " + ex.Message);
            }
            finally
            {
                helper.Close();
            }

            return true;
        }
        
        public static bool PrintMillRoll_QR(DataTable dtRtn, string sIND_BCD, int nPrnCnt=1)
        {
            DBHelper helper = new DBHelper(false);
            
            try
            {

                string PrinterName = SAMMI.IniFile.GetValue("KLEANNARA", "PRINTER", "");

                string sGapY = SAMMI.IniFile.GetValue("KLEANNARA", "PRT_GAP_Y", "0");
                string sZPL = "";
                string sTitle = "";       // 지종
                string sWeight = "";      // 평량
                string sWVLen = "";       // 규격
                string sWidthSL = "";     // 슬리터지폭
                string sTotWeight = "";   // 중량
                string sLength = "";      // 길이
                string sCore = "";        // 지관
                string sWidthNo = "";     // 지폭순서
                string sMachNm = "";      // 설비명
                string sLotNo = "";       // LOT NO
                string sWrkNm = "";       // 작업자
                string sRoute = "";       // 항차번호
                string sINDBCD = "";      // 개별바코드

                sTitle       = dtRtn.Rows[0]["PCODE_NM"].ToString();                             // 지종
                sWeight      = Common.StrFormatInteger(dtRtn.Rows[0]["BS_WGT"].ToString());      // 평량
                sWVLen       = dtRtn.Rows[0]["MATNR_SPEC"].ToString();                           // 규격(가로세로)
                sWidthSL     = dtRtn.Rows[0]["SLITER_WIDTH"].ToString();                         // 슬리터지폭
                sTotWeight   = Common.StrFormatDouble(dtRtn.Rows[0]["PRFM_QTY"].ToString());     // 중량
                sLength      = Common.StrFormatInteger(dtRtn.Rows[0]["ROLLCNT"].ToString());     // 길이
                sCore        = Common.StrFormatInteger(dtRtn.Rows[0]["CORE"].ToString());        // 지관
                sWidthNo     = dtRtn.Rows[0]["WIDTH_NO"].ToString();                             // 지폭순서
                sMachNm      = dtRtn.Rows[0]["MACH_NM"].ToString();                              // 설비명
                //sCustName    = dtRtn.Rows[0][""].ToString();                                   // 고객명 (거래처명)
                sLotNo       = dtRtn.Rows[0]["LOT_NO"].ToString();                               // LOT NO
                sWrkNm       = dtRtn.Rows[0]["WRK_NAME"].ToString();                             // 작업자
                sRoute       = dtRtn.Rows[0]["ROUTE"].ToString();                                // 항차번호
                sINDBCD      = sIND_BCD;                                                         // 개별바코드

                //QR코드 이미지생성
                QRCodeGenerator qrGenerator = new QRCodeGenerator();
                QRCodeData qrCodeData = qrGenerator.CreateQrCode(sINDBCD, QRCodeGenerator.ECCLevel.Q);
                QRCode qrCode = new QRCode(qrCodeData);
                Bitmap qrCodeImg = qrCode.GetGraphic(
                        40,             //픽셀당 모듈 크기(100mm 기준 - 40), (50mm 기준 - 20)
                        Color.Black,
                        Color.White,
                        false           // Quiet Zone 제거
                    );
                int padding = 10;
                var qrWithMargin = new Bitmap(qrCodeImg.Width + padding * 2, qrCodeImg.Height + padding * 2);

                //qrWithMargin.SetResolution(203, 203); //dpi 에 따라 맞추기 qr흐릿하면 

                using (var g = Graphics.FromImage(qrWithMargin))
                {
                    g.Clear(Color.White);                       //바탕 흰색
                    g.DrawImage(qrCodeImg, padding, padding);   //가운데 배치
                }
                string qrImgStr= ConvertBitmapToGFA(qrWithMargin);


                helper.ExecuteNoneQuery("SP_INV_ZPL_PS_QR", CommandType.StoredProcedure
                        , helper.CreateParameter("P_GAP_Y",     sGapY,      DbType.String, ParameterDirection.Input)        //위쪽여백
                        , helper.CreateParameter("P_TITLE",     sTitle,     DbType.String, ParameterDirection.Input)        //지종
                        , helper.CreateParameter("P_WEIGHT",    sWeight,    DbType.String, ParameterDirection.Input)        //평량
                        , helper.CreateParameter("P_WVLEN",     sWVLen,     DbType.String, ParameterDirection.Input)        //규격(가로세로)
                        , helper.CreateParameter("P_WIDTH_SL",  sWidthSL,   DbType.String, ParameterDirection.Input)        //지폭(슬리터)
                        , helper.CreateParameter("P_PGEWEW",    sTotWeight, DbType.String, ParameterDirection.Input)        //총중량
                        , helper.CreateParameter("P_LENGTH",    sLength,    DbType.String, ParameterDirection.Input)        //길이
                        , helper.CreateParameter("P_CORE",      sCore,      DbType.String, ParameterDirection.Input)        //지관
                        , helper.CreateParameter("P_WIDTH_NO",  sWidthNo,   DbType.String, ParameterDirection.Input)        //지폭순서
                        , helper.CreateParameter("P_MACH_NM",   sMachNm,    DbType.String, ParameterDirection.Input)        //고객명
                        , helper.CreateParameter("P_LOTNO",     sLotNo,     DbType.String, ParameterDirection.Input)        //Lot No
                        , helper.CreateParameter("P_WRK_NM",    sWrkNm,     DbType.String, ParameterDirection.Input)        //작업자
                        , helper.CreateParameter("P_ROUTE",     sRoute,     DbType.String, ParameterDirection.Input)        //항차번호
                        , helper.CreateParameter("P_INDBCD",    sINDBCD,    DbType.String, ParameterDirection.Input)        //바코드

                        , helper.CreateParameterOracle("P_INDBCD_QR",   qrImgStr,   OracleDbType.Clob, ParameterDirection.Input)     //QR코드 이미지 텍스트
                        , helper.CreateParameterOracle("P_ZPL",         null,       OracleDbType.Clob, ParameterDirection.Output)
                    );

                if (helper.RSCODE == "E")
                {
                    return false;
                }
                else
                {
                    sZPL = ((Oracle.ManagedDataAccess.Types.OracleClob)((OracleParameter)helper.Parameters["P_ZPL"]).Value).Value;
                }

                foreach (string sPrinter in System.Drawing.Printing.PrinterSettings.InstalledPrinters)
                {
                    if (sPrinter.Contains(PrinterName))
                    {
                        if (nPrnCnt > 1)
                        {
                            string rtnMsg = CheckPrinterState(sPrinter);

                            if (rtnMsg == "OK")
                            {
                                for (int i = 0; i < nPrnCnt; i++)
                                {
                                    SAMMI.RawPrinterHelper.SendStringToBytePrinter(sPrinter, sZPL);
                                }
                            }
                            else
                            {
                                new POPUP.MessageForm(rtnMsg, MessageBoxButtons.OK, "알   림").ShowDialog();
                                return false;
                            }
                        }
                        else
                        {
                            string rtnMsg = CheckPrinterState(sPrinter);
                            if (rtnMsg == "OK")
                            {
                                SAMMI.RawPrinterHelper.SendStringToBytePrinter(sPrinter, sZPL);
                            }
                            else
                            {
                                new POPUP.MessageForm(rtnMsg, MessageBoxButtons.OK, "알   림").ShowDialog();
                                return false;
                            }
                        }

                        break;
                    }
                }
            }
            catch (Exception ex)
            {
                LogFile.WriteLog("PrintMillRoll_QR.doPrint Error => " + ex.Message);
            }
            finally
            {
                helper.Close();
            }

            return true;
        }

        #endregion

        public static void PrintCutter(string sRES_IND_BCD)
        {
            string[] sARR_IND_BCD = sRES_IND_BCD.Split('|');

            // 바코드가 없으면 인쇄 하지 않고 리턴
            if (sARR_IND_BCD.Length == 1)
            {
                if (sARR_IND_BCD[0].Length == 0)
                {
                    return;
                }
            }

            DBHelper helper = new DBHelper();
            DataTable dtRtn;

            REPORT rp = new REPORT();

            try
            {
                rp.EXCEL_OPEN(Common.PlantCode);

                foreach (string sIND_BCD in sARR_IND_BCD)
                {
                    Console.WriteLine("IND_BCD = [" + sIND_BCD + "]");

                    if (sIND_BCD.Length == 0)
                        continue;

                    // 재단 인쇄용 정보 조회
                    dtRtn = helper.FillTable("SP_POP_WRK26_S03", CommandType.StoredProcedure
                                                        , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)              // 플랜트
                                                        , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)          //작업장코드(설비코드)
                                                        , helper.CreateParameter("P_IND_BCD", sIND_BCD, DbType.String, ParameterDirection.Input)                    //개별바코드
                                                        );

                    if (helper.RSCODE == "S")
                    {
                        if (dtRtn.Rows.Count == 1)
                        {
                            //조회결과 입력용 Row생성
                            REPORT_ITEM CTitem = new REPORT_ITEM();

                            if (Common.OpCode.Contains("CB"))
                                CTitem.TITLE_NAME = "수재단";
                            else
                                CTitem.TITLE_NAME = "재단";

                            CTitem.IND_BCD = sIND_BCD;                                                          // 개별바코드
                            CTitem.PCODE_NM = dtRtn.Rows[0]["PCODE_NM"].ToString();                             // 지종
                            CTitem.BS_WGT = Common.StrFormatInteger(dtRtn.Rows[0]["BS_WGT"].ToString());          // 평량

                            // ReWinder 규격 , 규격 처리
                            CTitem.SPEC = dtRtn.Rows[0]["MATNR_SPEC"].ToString();

                            CTitem.REAM_CNT = Common.StrFormatDouble(dtRtn.Rows[0]["PRFM_REAM"].ToString(), "{0:#,##0.00}");       // 실적연수
                            CTitem.PRFM_WGT = Common.StrFormatDouble(dtRtn.Rows[0]["PRFM_WGT"].ToString());         // 실적중량

                            string sMAN_CUT_YN = dtRtn.Rows[0]["MAN_CUT_YN"].ToString();                        // 수재단 이동여부

                            if (sMAN_CUT_YN == "Y")
                            {
                                CTitem.PCODE_NM += "(수재단이동)";
//                                CTitem.SPEC += "(수재단이동)";
                            }

                            double dPltPerCnt;
                            double.TryParse(dtRtn.Rows[0]["PLT_PER_CNT"].ToString(), out dPltPerCnt);            // 팔레트당 연수

                            int nInPerCnt;
                            int.TryParse(dtRtn.Rows[0]["IN_PER_CNT"].ToString(), out nInPerCnt);                // 속당매수

                            CTitem.PLT_PER_CNT = Common.StrFormatDouble(dtRtn.Rows[0]["PLT_PER_CNT"].ToString(), "{0:#,##0.0}");         // 팔레트당 연수
                            CTitem.IN_PER_CNT = Common.StrFormatInteger(dtRtn.Rows[0]["IN_PER_CNT"].ToString());         // 속당매수

                            // 속수
                            if (nInPerCnt > 0)
                            {
                                CTitem.IN_CNT = Common.StrFormatDouble((dPltPerCnt * 500 / nInPerCnt).ToString(), "{0:#,##0.#}");        // 속수=(팔레트당연수*500)/속당매수
                            }
                            else
                            {
                                CTitem.IN_CNT = "0";
                            }

                            CTitem.SEQ = dtRtn.Rows[0]["WRK_SEQ"].ToString();           // 생산순번
                            CTitem.WIDTH_NO = dtRtn.Rows[0]["WIDTH_NO"].ToString();     // 지폭순번

                            CTitem.JR_MACHINE = dtRtn.Rows[0]["JR_MACHINE_NM"].ToString();  // 점보롤호기
                            CTitem.MR_MACHINE = dtRtn.Rows[0]["MR_MACHINE_NM"].ToString();  // 밀롤호기
                            CTitem.CT_MACHINE = dtRtn.Rows[0]["CT_MACHINE_NM"].ToString();  // 재단호기

                            CTitem.PACKTYPE = dtRtn.Rows[0]["PACKTYPE"].ToString();  // 포장타입
                            CTitem.CUST_NM = dtRtn.Rows[0]["CUST_NM"].ToString();   // 거래처명

                            CTitem.LAND_CD = "";
                            CTitem.LAND_NM = "";
                            if (dtRtn.Columns.Contains("LAND_CD"))
                            {
                                CTitem.LAND_CD = dtRtn.Rows[0]["LAND_CD"].ToString();   // 국가코드
                            }

                            if (dtRtn.Columns.Contains("LAND_NM"))
                            {
                                CTitem.LAND_NM = dtRtn.Rows[0]["LAND_NM"].ToString();   // 국가명
                            }

                            CTitem.PRD_DATE = dtRtn.Rows[0]["WRK_DATE"].ToString();     // 생산일시

                            CTitem.WRK_SHIFT = dtRtn.Rows[0]["WRK_CLASS"].ToString();    // 반
                            CTitem.WRK_NAME = dtRtn.Rows[0]["WRK_NAME"].ToString();     // 작업자

                            CTitem.LOT_NO = dtRtn.Rows[0]["LOT_NO"].ToString();       // LOT_NO (10자리)

                            CTitem.SALES_ORDR_NO = dtRtn.Rows[0]["SALES_ORDR_NO"].ToString();       // LOT_NO (10자리)

                            CTitem.RUN_STA = dtRtn.Rows[0]["RUN_STA"].ToString();       // "09" = 여유생산유무

                            CTitem.ORDER_RMK = dtRtn.Rows[0]["ORDER_RMK"].ToString();    // 지시사항
                            CTitem.WRK_ORDR_RMK = dtRtn.Rows[0]["RMK"].ToString();      // 비고

                            string pstrERR = "";
                            //REPORT rp = new REPORT();
                            //rp.EXCEL_OPEN(Common.PlantCode);
                            rp.CT_PRINT(CTitem, ref pstrERR);

                            LogFile.WriteLog(string.Format("재단 바코드 발행 : {0}", sIND_BCD), LogType.PROC);
                            //if (pstrERR.Length > 0)
                            //{
                            //    rp.EXCEL_CLOSE();
                            //    return;
                            //}
                            //rp.EXCEL_CLOSE();
                        }
                        //else
                        //{
                        //    //CleanOrderLabel();
                        //}
                    }
                }
            }
            catch (Exception ex)
            {
                //CleanOrderLabel();
                //                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                LogFile.WriteLog("SP_POP_WRK26_S03.DoFind Error => " + ex.Message);
                throw ex;
            }
            finally
            {
                rp.EXCEL_CLOSE();
            }
        }

        // 수재단 인쇄 방식에 따라서 A4, LABEL 선택
        public static bool PrintMCutter(string sRES_IND_BCD, string sLABEL_TYPE, int nPrtCnt = 1)
        {
            string[] sARR_IND_BCD = sRES_IND_BCD.Split('|');

            DBHelper helper = new DBHelper();
            DataTable dtRtn;

            REPORT rp = new REPORT();

            try
            {
                foreach (string sIND_BCD in sARR_IND_BCD)
                {
                    if (sIND_BCD.Length > 0)
                    {
                        //LogFile.WriteLog("IND_BCD = [" + sIND_BCD + "]");
                        
                        // 밀롤 인쇄용 정보 조회
                        dtRtn = helper.FillTable("SP_POP_WRK26_S03", CommandType.StoredProcedure
                                                            , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)              // 플랜트
                                                            , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)          //작업장코드(설비코드)
                                                            , helper.CreateParameter("P_IND_BCD", sIND_BCD, DbType.String, ParameterDirection.Input)          //개별바코드
                                                            );
                        if (helper.RSCODE == "S")
                        {
                            if (dtRtn.Rows.Count == 1)
                            {
                                //LogFile.WriteLog(string.Format("NEXT_PROC = {0}, SLITER{1}", dtRtn.Rows[0]["NEXT_PROC"].ToString(), dtRtn.Rows[0]["SLITER"].ToString()));

                                if (dtRtn.Rows[0]["WRK_TYPE"].ToString() == "Y")
                                {
                                    if (rp.ReadyCheck() == false)
                                    {
                                        rp.EXCEL_OPEN(Common.PlantCode);
                                    }
                                    PrintManualCutter(rp, dtRtn, sIND_BCD);
                                    LogFile.WriteLog(string.Format("수재단 바코드 발행 : {0}", sIND_BCD), LogType.PROC);
                                }
                                else
                                {
                                    LogFile.WriteLog(string.Format("수재단(예외생산) 바코드 발행[{0}매] : {1}", nPrtCnt, sIND_BCD), LogType.PROC);
                                    // 예외생산 라벨출력
                                    if (PrintManualExCutter(dtRtn, sIND_BCD, sLABEL_TYPE, nPrtCnt) == false)
                                    {
                                        return false;
                                    }
                                }
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                LogFile.WriteLog("SP_POP_WRK25_S03.DoFind Error => " + ex.Message);
                throw ex;
            }
            finally
            {
                rp.EXCEL_CLOSE();
            }

            return true;
        }

        // 수제단 정규 생산 (C바코드 출력)
        public static void PrintManualCutter(REPORT rp, DataTable dtRtn, string sIND_BCD)
        {
            DBHelper helper = new DBHelper();

            try
            {
                {
                    //Console.WriteLine("IND_BCD = [" + sIND_BCD + "]");

                    //if (sIND_BCD.Length == 0)
                    //    continue;

                    //// 재단 인쇄용 정보 조회
                    //dtRtn = helper.FillTable("SP_POP_WRK26_S03", CommandType.StoredProcedure
                    //                                    , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)              // 플랜트
                    //                                    , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)          //작업장코드(설비코드)
                    //                                    , helper.CreateParameter("P_IND_BCD", sIND_BCD, DbType.String, ParameterDirection.Input)                    //개별바코드
                    //                                    );

                    //if (helper.RSCODE == "S")
                    {
                        if (dtRtn.Rows.Count == 1)
                        {
                            //조회결과 입력용 Row생성
                            REPORT_ITEM CTitem = new REPORT_ITEM();

                            CTitem.TITLE_NAME = "수재단";

                            CTitem.IND_BCD = sIND_BCD;                                                          // 개별바코드
                            CTitem.PCODE_NM = dtRtn.Rows[0]["PCODE_NM"].ToString();                             // 지종
                            CTitem.BS_WGT = Common.StrFormatInteger(dtRtn.Rows[0]["BS_WGT"].ToString());          // 평량

                            // ReWinder 규격 , 규격 처리
                            CTitem.SPEC = dtRtn.Rows[0]["MATNR_SPEC"].ToString();

                            CTitem.REAM_CNT = Common.StrFormatDouble(dtRtn.Rows[0]["PRFM_REAM"].ToString(), "{0:#,##0.00}");       // 실적연수
                            CTitem.PRFM_WGT = Common.StrFormatDouble(dtRtn.Rows[0]["PRFM_WGT"].ToString());         // 실적중량

                            //string sMAN_CUT_YN = dtRtn.Rows[0]["MAN_CUT_YN"].ToString();                        // 수재단 이동여부

                            //if (sMAN_CUT_YN == "Y")
                            //{
                            //    CTitem.PCODE_NM += "(수재단이동)";
                            //    //                                CTitem.SPEC += "(수재단이동)";
                            //}

                            double dPltPerCnt;
                            double.TryParse(dtRtn.Rows[0]["PLT_PER_CNT"].ToString(), out dPltPerCnt);            // 팔레트당 연수

                            int nInPerCnt;
                            int.TryParse(dtRtn.Rows[0]["IN_PER_CNT"].ToString(), out nInPerCnt);                // 속당매수

                            CTitem.PLT_PER_CNT = Common.StrFormatDouble(dtRtn.Rows[0]["PLT_PER_CNT"].ToString(), "{0:#,##0.0}");         // 팔레트당 연수
                            CTitem.IN_PER_CNT = Common.StrFormatInteger(dtRtn.Rows[0]["IN_PER_CNT"].ToString());         // 속당매수

                            // 속수
                            if (nInPerCnt > 0)
                            {
                                CTitem.IN_CNT = Common.StrFormatDouble((dPltPerCnt * 500 / nInPerCnt).ToString(), "{0:#,##0.#}");        // 속수=(팔레트당연수*500)/속당매수
                            }
                            else
                            {
                                CTitem.IN_CNT = "0";
                            }

                            CTitem.SEQ = dtRtn.Rows[0]["WRK_SEQ"].ToString();           // 생산순번
                            CTitem.WIDTH_NO = dtRtn.Rows[0]["WIDTH_NO"].ToString();     // 지폭순번

                            CTitem.JR_MACHINE = dtRtn.Rows[0]["JR_MACHINE_NM"].ToString();  // 점보롤호기
                            CTitem.MR_MACHINE = dtRtn.Rows[0]["MR_MACHINE_NM"].ToString();  // 밀롤호기
                            CTitem.CT_MACHINE = dtRtn.Rows[0]["CT_MACHINE_NM"].ToString();  // 재단호기

                            CTitem.PACKTYPE = dtRtn.Rows[0]["PACKTYPE"].ToString();  // 포장타입
                            CTitem.CUST_NM = dtRtn.Rows[0]["CUST_NM"].ToString();   // 거래처명

                            CTitem.LAND_CD = "";
                            CTitem.LAND_NM = "";
                            if (dtRtn.Columns.Contains("LAND_CD"))
                            {
                                CTitem.LAND_CD = dtRtn.Rows[0]["LAND_CD"].ToString();   // 국가코드
                            }

                            if (dtRtn.Columns.Contains("LAND_NM"))
                            {
                                CTitem.LAND_NM = dtRtn.Rows[0]["LAND_NM"].ToString();   // 국가명
                            }


                            CTitem.PRD_DATE = dtRtn.Rows[0]["WRK_DATE"].ToString();     // 생산일시

                            CTitem.WRK_SHIFT = dtRtn.Rows[0]["WRK_CLASS"].ToString();    // 반
                            CTitem.WRK_NAME = dtRtn.Rows[0]["WRK_NAME"].ToString();     // 작업자

                            CTitem.LOT_NO = dtRtn.Rows[0]["LOT_NO"].ToString();       // LOT_NO (10자리)

                            CTitem.SALES_ORDR_NO = dtRtn.Rows[0]["SALES_ORDR_NO"].ToString();       // LOT_NO (10자리)

                            CTitem.RUN_STA = dtRtn.Rows[0]["RUN_STA"].ToString();       // "09" = 여유생산유무

                            CTitem.ORDER_RMK = dtRtn.Rows[0]["ORDER_RMK"].ToString();    // 지시사항
                            CTitem.WRK_ORDR_RMK = dtRtn.Rows[0]["RMK"].ToString();      // 비고

                            string pstrERR = "";
                            //REPORT rp = new REPORT();
                            //rp.EXCEL_OPEN(Common.PlantCode);
                            rp.CT_PRINT(CTitem, ref pstrERR);
                            //if (pstrERR.Length > 0)
                            //{
                            //    rp.EXCEL_CLOSE();
                            //    return;
                            //}
                            //rp.EXCEL_CLOSE();
                        }
                        //else
                        //{
                        //    //CleanOrderLabel();
                        //}
                    }
                }
            }
            catch (Exception ex)
            {
                //CleanOrderLabel();
                //                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                LogFile.WriteLog("SP_POP_WRK26_S03.DoFind Error => " + ex.Message);
                throw ex;
            }
            finally
            {
                //rp.EXCEL_CLOSE();
            }
        }

        // 수재단 예외생산 
        public static bool PrintManualExCutter(DataTable dtRtn, string sIND_BCD, string sLabelType, int nPrtCnt = 1)
        {
            DBHelper helper = new DBHelper();

            try
            {
                //string PrinterName = "ZT420";
                string PrinterName = SAMMI.IniFile.GetValue("KLEANNARA", "PRINTER", "");

                string sGapY = SAMMI.IniFile.GetValue("KLEANNARA", "PRT_GAP_Y", "0");

                //foreach (string sIND_BCD in sARR_IND_BCD)
                {
                    string sZPL = "";
                    string sTitle = "";       // 지종
                    string sWeight = "";      // 평량
                    string sWVLen = "";       // 규격
                    string sReam = "";        // 연수
                    string sTotWeight = "";   // 중량
                    string sScnt = "";        // 속
                    //string sInPerCnt = "";    // 속당매수
                    string sMcnt = "";        // 속당매수
                    string sLength = "0";      // 길이
                    string sCore = "0";        // 지관
                    string sSPItemNo = "";    // 특별재고번호
                    string sCustName = "";    // 고객명
                    string sCustEx = "";      // 고객명추가정보
                    string sLineCd = "";      // 생산호기
                    string sLotNo = "";       // LOT NO
                    string sWorker = "";      // 작업자
                    string sOrderNo = "";     // ORDERNO
                    string sINDBCD_M = "";      //재단개별바코드
                    string sINDBCD = "";      // 개별바코드

                    //Console.WriteLine("IND_BCD = [" + sIND_BCD + "]");

                    if (sIND_BCD.Length == 0)
                        return false;

                    // 재단 인쇄용 정보 조회
                    //dtRtn = helper.FillTable("SP_POP_WRK26_S03", CommandType.StoredProcedure
                    //                                    , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)              // 플랜트
                    //                                    , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)          //작업장코드(설비코드)
                    //                                    , helper.CreateParameter("P_IND_BCD", sIND_BCD, DbType.String, ParameterDirection.Input)                    //개별바코드
                    //                                    );

                    //if (helper.RSCODE == "S")
                    {
                        if (dtRtn.Rows.Count == 1)
                        {
                            sTitle = dtRtn.Rows[0]["PCODE_NM"].ToString();                              //지종
                            sWeight = Common.StrFormatInteger(dtRtn.Rows[0]["BS_WGT"].ToString());      //평량
                            sWVLen = dtRtn.Rows[0]["MATNR_SPEC"].ToString();                            //규격(가로세로)
                            
                            sReam = Common.StrFormatDouble(dtRtn.Rows[0]["PRFM_REAM"].ToString(), "{0:#,##0.00}");       //연수 (원지포장 = 0)
                            sTotWeight = Common.StrFormatDouble(dtRtn.Rows[0]["PRFM_WGT"].ToString());  // 실적충량

                            double dPltPerCnt;
                            double.TryParse(dtRtn.Rows[0]["PLT_PER_CNT"].ToString(), out dPltPerCnt);            // 팔레트당 연수

                            int nInPerCnt;
                            int.TryParse(dtRtn.Rows[0]["IN_PER_CNT"].ToString(), out nInPerCnt);                // 속당매수

                            sMcnt = Common.StrFormatInteger(dtRtn.Rows[0]["IN_PER_CNT"].ToString());         // 속당매수

                            // 속수
                            if (dtRtn.Columns.Contains("SCNT"))
                            {
                                sScnt = Common.StrFormatInteger(dtRtn.Rows[0]["SCNT"].ToString());         // 속수
                            }
                            else
                            {
                                // 속수
                                if (nInPerCnt > 0)
                                {
                                    sScnt = Common.StrFormatDouble((dPltPerCnt * 500 / nInPerCnt).ToString(), "{0:#,##0.#}");        // 속수=(팔레트당연수*500)/속당매수
                                }
                                else
                                {
                                    sScnt = "0";
                                }
                            }

                            sLength = "0";     // 실적권치수
                            sCore = "0";          // 지관
                            sSPItemNo = ""; // dtRtn.Rows[0]["SALES_ORDR_NO"].ToString();                      // ****************** 특별재고번호 가 세일즈오더 와 같은지 확인 *****************
                            sCustName = "";  //dtRtn.Rows[0]["CUST_NM"].ToString();                            // 고객명 (거래처명)  ????????????????????????????

                            sINDBCD_M = ""; //dtRtn.Rows[0]["IND_BCD_M"].ToString();      // 재단바코0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000드

                            // 포장 라벨 유형 -----------------
                            // 01 : 내수 페이퍼
                            // 02 : 내수 스티커
                            // 03 : 수출 페이퍼
                            // 04 : 수출 스티커
                            if (sLabelType == "03" || sLabelType == "04")
                            {
                                sWorker = dtRtn.Rows[0]["WRK_ID"].ToString();                       // 수출이면 작업자 ID 
                            }
                            else
                            {
                                sWorker = dtRtn.Rows[0]["WRK_NAME"].ToString();                     // 내수이면 작업자이름
                            }

                            sWorker = dtRtn.Rows[0]["WRK_ID"].ToString();                       // 수출이면 작업자 ID 


                            if (dtRtn.Columns.Contains("LOT_NO"))
                            {
                                sLotNo = dtRtn.Rows[0]["LOT_NO"].ToString();                    //  LOT번호
                            }

                            if (dtRtn.Columns.Contains("MACHINE_NM"))
                            {
                                sLineCd = dtRtn.Rows[0]["MACHINE_NM"].ToString();           // 생산호기
                            }

                            if (dtRtn.Columns.Contains("ORDER_NO"))
                            {
                                sOrderNo = dtRtn.Rows[0]["ORDER_NO"].ToString();                 // 오더 번호
                            }

                            //ZPL코드 프로시저 호출
                            helper.ExecuteNoneQuery("SP_INV_ZPL_PS", CommandType.StoredProcedure
                                 , helper.CreateParameter("P_TYPE", sLabelType, DbType.String, ParameterDirection.Input) //라벨종류
                                 , helper.CreateParameter("P_GAP_X", "0", DbType.String, ParameterDirection.Input) // 왼쪽여백
                                 , helper.CreateParameter("P_GAP_Y", sGapY, DbType.String, ParameterDirection.Input) // 위쪽여백
                                 , helper.CreateParameter("P_PRT_SPEED", "0", DbType.String, ParameterDirection.Input) // 속도
                                 , helper.CreateParameter("P_PRT_STRENGTH", "0", DbType.String, ParameterDirection.Input) // 강도
                                 , helper.CreateParameter("P_TITLE", sTitle, DbType.String, ParameterDirection.Input) //지종
                                 , helper.CreateParameter("P_WEIGHT", sWeight, DbType.String, ParameterDirection.Input) //평량
                                 , helper.CreateParameter("P_WVLEN", sWVLen, DbType.String, ParameterDirection.Input) //규격(가로세로)
                                 , helper.CreateParameter("P_REAM", sReam, DbType.String, ParameterDirection.Input) //연수
                                 , helper.CreateParameter("P_PGEWEW", sTotWeight, DbType.String, ParameterDirection.Input) //총중량
                                 , helper.CreateParameter("P_SCNT", sScnt, DbType.String, ParameterDirection.Input) //속
                                 , helper.CreateParameter("P_MCNT", sMcnt, DbType.String, ParameterDirection.Input) //매수
                                 , helper.CreateParameter("P_LENGTH", sLength, DbType.String, ParameterDirection.Input) //길이
                                 , helper.CreateParameter("P_CORE", sCore, DbType.String, ParameterDirection.Input) //지관
                                 , helper.CreateParameter("P_SPITEMNO", sSPItemNo, DbType.String, ParameterDirection.Input) //특별재고번호
                                 , helper.CreateParameter("P_CUSTNM", sCustName, DbType.String, ParameterDirection.Input) //고객명
                                 , helper.CreateParameter("P_CUSTEX", sCustEx, DbType.String, ParameterDirection.Input) //고객추가정보
                                 , helper.CreateParameter("P_LINECD", sLineCd, DbType.String, ParameterDirection.Input) //생산호기
                                 , helper.CreateParameter("P_LOTNO", sLotNo, DbType.String, ParameterDirection.Input) //LotNo
                                 , helper.CreateParameter("P_WORKER", sWorker, DbType.String, ParameterDirection.Input) //작업자
                                 , helper.CreateParameter("P_ORDERNO", sOrderNo, DbType.String, ParameterDirection.Input) //지시번호
                                 , helper.CreateParameter("P_CINDBCD", sINDBCD_M, DbType.String, ParameterDirection.Input) //바코드
                                 , helper.CreateParameter("P_INDBCD", sIND_BCD, DbType.String, ParameterDirection.Input) //바코드
                                 , helper.CreateParameter("P_ZPL", DbType.String, ParameterDirection.Output, null, 4000)
                               );

                            if (helper.RSCODE == "E")
                            {
                                //new POPUP.MessageForm(helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                                //this.DialogResult = DialogResult.OK;
                                return false;
                            }
                            else
                            {
                                sZPL = helper.Parameters["P_ZPL"].Value.ToString();
                            }

                            foreach (string sPrinter in System.Drawing.Printing.PrinterSettings.InstalledPrinters)
                            {
                                if (sPrinter.Contains(PrinterName))
                                {
                                    if (nPrtCnt > 1)
                                    {
                                        string rtnMsg = CheckPrinterState(sPrinter);

                                        if (rtnMsg == "OK")
                                        {
                                            for (int i = 0; i < nPrtCnt; i++)
                                            {
                                                SAMMI.RawPrinterHelper.SendStringToBytePrinter(sPrinter, sZPL);
                                            }
                                        }
                                        else
                                        {
                                            new POPUP.MessageForm(rtnMsg, MessageBoxButtons.OK, "알   림").ShowDialog();
                                            return false;
                                        }
                                    }
                                    else
                                    {
                                        string rtnMsg = CheckPrinterState(sPrinter);
                                        if (rtnMsg == "OK")
                                        {
                                            SAMMI.RawPrinterHelper.SendStringToBytePrinter(sPrinter, sZPL);
                                        }
                                        else
                                        {
                                            new POPUP.MessageForm(rtnMsg, MessageBoxButtons.OK, "알   림").ShowDialog();
                                            return false;
                                        }
                                    }

                                    break;  //인쇄완료
                                }
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                //CleanOrderLabel();
                //                new POPUP.MessageForm(ex.Message, MessageBoxButtons.OK, "알   림").ShowDialog(this);
                LogFile.WriteLog("SP_POP_WRK26_S03.DoFind Error => " + ex.Message);
                throw ex;
            }
            finally
            {
            }
            return true;
        }


        public static bool PrintPackaging(string sRES_IND_BCD, string sLabelType, int nPrnCnt = 1)
        {
            //Configuration appConfig = ConfigurationManager.OpenExeConfiguration(ConfigurationUserLevel.None);

            string[] sARR_IND_BCD = sRES_IND_BCD.Split('|');

            DBHelper helper = new DBHelper();
            DataTable dtRtn;

            try
            {
                //string PrinterName = "ZT420";
                string PrinterName = SAMMI.IniFile.GetValue("KLEANNARA", "PRINTER", "");

                
                
                //string sGapY = appConfig.AppSettings.Settings["PRT_GAP_Y"].Value;
                string sGapY = SAMMI.IniFile.GetValue("KLEANNARA", "PRT_GAP_Y", "0");

                foreach (string sIND_BCD in sARR_IND_BCD)
                {
                    string sZPL = "";
                    string sTitle = "";       // 지종
                    string sWeight = "";      // 평량
                    string sWVLen = "";       // 규격
                    string sReam = "";        // 연수
                    string sTotWeight = "";   // 중량
                    string sScnt = "";        // 속
                    //string sInPerCnt = "";    // 속당매수
                    string sMcnt = "";        // 속당매수
                    string sLength = "0";      // 길이
                    string sCore = "0";        // 지관
                    string sSPItemNo = "";    // 특별재고번호
                    string sCustName = "";    // 고객명
                    string sCustEx = "";      // 고객명추가정보
                    string sLineCd = "";      // 생산호기
                    string sLotNo = "";       // LOT NO
                    string sWorker = "";      // 작업자
                    string sOrderNo = "";     // ORDERNO
                    string sINDBCD_M = "";      //재단개별바코드
                    string sINDBCD = "";      // 개별바코드

                    Console.WriteLine("IND_BCD = [" + sIND_BCD + "]");

                    // 포장 인쇄용 정보 조회
                    dtRtn = helper.FillTable("SP_POP_WRK27_S05", CommandType.StoredProcedure
                                                        , helper.CreateParameter("P_WERKS", Common.PlantCode, DbType.String, ParameterDirection.Input)              // 플랜트
                                                        , helper.CreateParameter("P_MACH_CD", Common.MachineCode, DbType.String, ParameterDirection.Input)          //작업장코드(설비코드)
                                                        , helper.CreateParameter("P_IND_BCD", sIND_BCD, DbType.String, ParameterDirection.Input)                    //개별바코드
                                                        );
                    if (dtRtn.Rows.Count == 1)
                    {
                        //string sOrderNo = Grid1.Rows[i].Cells["OrderNo"].Value.ToString();
                        sTitle = dtRtn.Rows[0]["PCODE_NM"].ToString();                              //지종
                        sWeight = Common.StrFormatInteger(dtRtn.Rows[0]["BS_WGT"].ToString());      //평량
                        sWVLen = dtRtn.Rows[0]["MATNR_SPEC"].ToString();   //규격(가로세로)
                        //if(원지포장인지....확인하여 )
                        //{
                        //    sReam = "0";       //연수 (원지포장 = 0)
                        //    sTotWeight  = "0";
                        //    sScnt = "0";                                                                // 속 (원지포장 = 0)
                        //    sMcnt = "0";                                                            // 속당매수 (원지포장 = 0)
                        //}
                        //else
                        {
                            sReam = Common.StrFormatDouble(dtRtn.Rows[0]["PRFM_REAM"].ToString(), "{0:#,##0.00}");       //연수 (원지포장 = 0)
                            sTotWeight = Common.StrFormatDouble(dtRtn.Rows[0]["PRFM_WGT"].ToString());  // 실적충량
                            sScnt = Common.StrFormatInteger(dtRtn.Rows[0]["SCNT"].ToString());           // 속 (원지포장 = 0)
                            sMcnt = Common.StrFormatInteger(dtRtn.Rows[0]["IN_PER_CNT"].ToString()); // 속당매수 (원지포장 = 0)
                        }

                        sLength = "0";     // 실적권치수
                        sCore = "0";          // 지관
                        sSPItemNo = ""; // dtRtn.Rows[0]["SALES_ORDR_NO"].ToString();                      // ****************** 특별재고번호 가 세일즈오더 와 같은지 확인 *****************
                        sCustName = dtRtn.Rows[0]["CUST_NM"].ToString();                            // 고객명 (거래처명)  ????????????????????????????
                        //sCustEx = "";                                                               // 

                        sINDBCD_M = dtRtn.Rows[0]["IND_BCD_M"].ToString();      // 재단바코드

#if true
                        // 포장 라벨 유형 -----------------
                        // 01 : 내수 페이퍼
                        // 02 : 내수 스티커
                        // 03 : 수출 페이퍼
                        // 04 : 수출 스티커
                        if (sLabelType == "03" || sLabelType == "04")
                        {
                            sWorker = dtRtn.Rows[0]["WRK_ID"].ToString();                       // 수출이면 작업자 사원번호 (고유번호)
                        }
                        else
                        {
                            sWorker = dtRtn.Rows[0]["WRK_NAME"].ToString();                     // 내수이면 작업자이름
                        }
#else
                        // 내수이면  작업자, 수출이면 작업자ID 를 출력함.
                        // 품목코드의 5번째 자리가 2이면 수출, 1이면 내수 구분
                        string sMATNR = dtRtn.Rows[0]["MATNR"].ToString();
                        if (sMATNR.Length == 17 || sMATNR.Length == 18)
                        {
                            if (sMATNR.Substring(4, 1) == "1")
                                sWorker = dtRtn.Rows[0]["WRK_NAME"].ToString();                     // 내수이면 작업자이름
                            else
                                sWorker = dtRtn.Rows[0]["WRK_ID"].ToString();                       // 수출이면 작업자 ID 
                        }
                        else
                        {
                            sWorker = dtRtn.Rows[0]["WRK_NAME"].ToString();                         // 폼목코드가 17자리가 아닌경우는 
                        }
#endif
                        // 국가 코드 확인 *******************************************************************

                        sLotNo = dtRtn.Rows[0]["LOT_NO"].ToString();
                        sLineCd = dtRtn.Rows[0]["MACHINE_NM"].ToString();           // 생산호기
                        sINDBCD = sIND_BCD;
                        sOrderNo = dtRtn.Rows[0]["ORDER_NO"].ToString();                 // 오더 번호

                        //    ,P_TITLE        IN VARCHAR2 --지종
                        //    ,P_WEIGHT       IN VARCHAR2 --평량
                        //    ,P_WVLEN        IN VARCHAR2 --규격
                        //    ,P_REAM         IN VARCHAR2 --연수
                        //    ,P_PGEWEW       IN VARCHAR2 --중량
                        //    ,P_SCNT         IN VARCHAR2 --속
                        //    ,P_MCNT         IN VARCHAR2 --매수
                        //    ,P_LENGTH       IN VARCHAR2 --길이
                        //    ,P_CORE         IN VARCHAR2 --지관
                        //    ,P_SPITEMNO     IN VARCHAR2 --특별재고번호
                        //    ,P_CUSTNM       IN VARCHAR2 --고객명
                        //    ,P_CUSTEX       IN VARCHAR2 --고객추가정보
                        //    ,P_LINECD       IN VARCHAR2 --생산호기
                        //    ,P_LOTNO        IN VARCHAR2 --LOT NO
                        //    ,P_WORKER       IN VARCHAR2 --작업자
                        //    ,P_ORDERNO      IN VARCHAR2 --ORDERNO
                        //    ,P_CINDBCD      IN VARCHAR2 --재단개별바코드
                        //    ,P_INDBCD       IN VARCHAR2 --개별바코드

                        // 포장 라벨 유형 -----------------
                        // 01 : 내수 페이퍼
                        // 02 : 내수 스티커
                        // 03 : 수출 페이퍼
                        // 04 : 수출 스티커
                        //ZPL코드 프로시저 호출
                        helper.ExecuteNoneQuery("SP_INV_ZPL_PS", CommandType.StoredProcedure
                             , helper.CreateParameter("P_TYPE", sLabelType, DbType.String, ParameterDirection.Input) //라벨종류
                             , helper.CreateParameter("P_GAP_X", "0", DbType.String, ParameterDirection.Input) // 왼쪽여백
                             , helper.CreateParameter("P_GAP_Y", sGapY, DbType.String, ParameterDirection.Input) // 위쪽여백
                             , helper.CreateParameter("P_PRT_SPEED", "0", DbType.String, ParameterDirection.Input) // 속도
                             , helper.CreateParameter("P_PRT_STRENGTH", "0", DbType.String, ParameterDirection.Input) // 강도
                             , helper.CreateParameter("P_TITLE", sTitle, DbType.String, ParameterDirection.Input) //지종
                             , helper.CreateParameter("P_WEIGHT", sWeight, DbType.String, ParameterDirection.Input) //평량
                             , helper.CreateParameter("P_WVLEN", sWVLen, DbType.String, ParameterDirection.Input) //규격(가로세로)
                             , helper.CreateParameter("P_REAM", sReam, DbType.String, ParameterDirection.Input) //연수
                             , helper.CreateParameter("P_PGEWEW", sTotWeight, DbType.String, ParameterDirection.Input) //총중량
                             , helper.CreateParameter("P_SCNT", sScnt, DbType.String, ParameterDirection.Input) //속
                             , helper.CreateParameter("P_MCNT", sMcnt, DbType.String, ParameterDirection.Input) //매수
                             , helper.CreateParameter("P_LENGTH", sLength, DbType.String, ParameterDirection.Input) //길이
                             , helper.CreateParameter("P_CORE", sCore, DbType.String, ParameterDirection.Input) //지관
                             , helper.CreateParameter("P_SPITEMNO", sSPItemNo, DbType.String, ParameterDirection.Input) //특별재고번호
                             , helper.CreateParameter("P_CUSTNM", sCustName, DbType.String, ParameterDirection.Input) //고객명
                             , helper.CreateParameter("P_CUSTEX", sCustEx, DbType.String, ParameterDirection.Input) //고객추가정보
                             , helper.CreateParameter("P_LINECD", sLineCd, DbType.String, ParameterDirection.Input) //생산호기
                             , helper.CreateParameter("P_LOTNO", sLotNo, DbType.String, ParameterDirection.Input) //LotNo
                             , helper.CreateParameter("P_WORKER", sWorker, DbType.String, ParameterDirection.Input) //작업자
                             , helper.CreateParameter("P_ORDERNO", sOrderNo, DbType.String, ParameterDirection.Input) //지시번호
                             , helper.CreateParameter("P_CINDBCD", sINDBCD_M, DbType.String, ParameterDirection.Input) //바코드
                             , helper.CreateParameter("P_INDBCD", sINDBCD, DbType.String, ParameterDirection.Input) //바코드
                             , helper.CreateParameter("P_ZPL", DbType.String, ParameterDirection.Output, null, 4000)
                           );

                        if (helper.RSCODE == "E")
                        {
                            //new POPUP.MessageForm(helper.RSMSG.ToString(), MessageBoxButtons.OK, "알   림").ShowDialog(this);
                            //this.DialogResult = DialogResult.OK;
                            return false;
                        }
                        else
                        {
                            sZPL = helper.Parameters["P_ZPL"].Value.ToString();
                        }


                        bool bPrintContain = false;
                        foreach (string sPrinter in System.Drawing.Printing.PrinterSettings.InstalledPrinters)
                        {
                            if (sPrinter.Contains(PrinterName))
                            {
                                LogFile.WriteLog(string.Format("포장 바코드 발행[{0}매] : {1}", nPrnCnt, sIND_BCD), LogType.PROC);
                                bPrintContain = true;

                                if (nPrnCnt > 1)
                                {
                                    string rtnMsg = CheckPrinterState(sPrinter);

                                    if (rtnMsg == "OK")
                                    {
                                        for (int i = 0; i < nPrnCnt; i++)
                                        {
                                            SAMMI.RawPrinterHelper.SendStringToBytePrinter(sPrinter, sZPL);
                                        }
                                    }
                                    else
                                    {
                                        LogFile.WriteLog(rtnMsg.Replace("\r\n", " "), LogType.PROC);
                                        new POPUP.MessageForm(rtnMsg, MessageBoxButtons.OK, "알   림").ShowDialog();
                                        return false;
                                    }
                                }
                                else
                                {
                                    string rtnMsg = CheckPrinterState(sPrinter);
                                    if (rtnMsg == "OK")
                                    {
                                        SAMMI.RawPrinterHelper.SendStringToBytePrinter(sPrinter, sZPL);
                                    }
                                    else
                                    {
                                        LogFile.WriteLog(rtnMsg.Replace("\r\n", " "), LogType.PROC);
                                        new POPUP.MessageForm(rtnMsg, MessageBoxButtons.OK, "알   림").ShowDialog();
                                        return false;
                                    }
                                }

                                break;
                            }
                        }

                        if (bPrintContain == false)
                        {
                            LogFile.WriteLog(string.Format("라벨 프린터 찾지 못함"), LogType.PROC);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                LogFile.WriteLog("PrintPackaging.DoFind Error => " + ex.Message);
                throw ex;
            }
            finally
            {
            }

            return true;
        }

        public static string CheckPrinterState(string printerName)
        {
            string rtnMsg = string.Empty;
            // Select Printers from WMI Object Collections
            ManagementObjectSearcher searcher = new ManagementObjectSearcher("SELECT * FROM Win32_Printer");

            string prtName = string.Empty;
            foreach (ManagementObject printer in searcher.Get())
            {
                prtName = printer["Name"].ToString();

                if (prtName.Equals(printerName))
                {
                    if (printer["WorkOffline"].ToString().ToLower().Equals("true"))
                    {
                        rtnMsg =  "라벨 프린터가 연결되어 있지 않습니다.\r\n라벨 프린터를 연결하고 다시 시도하세요.";
                    }
                    else
                    {
                        rtnMsg = "OK";
                    }
                    break;
                }
            }

            return rtnMsg;
        }

        public static DataTable GetPrinterList()
        {
            DataTable dtprt = new DataTable();
            dtprt.Columns.Add("PRINTER");

            foreach (string printer in System.Drawing.Printing.PrinterSettings.InstalledPrinters)
            {
                DataRow dr = dtprt.NewRow();
                dr["PRINTER"] = printer;
                dtprt.Rows.Add(dr);
            }

            return dtprt;
        }

        public static string ConvertBitmapToGFA(Bitmap bitmap)
        {
            int width = bitmap.Width;
            int height = bitmap.Height;

            // ZPL은 가로 8픽셀 단위로 계산
            int widthBytes = (int)Math.Ceiling(width / 8.0);
            int totalBytes = widthBytes * height;

            byte[] imageData = new byte[totalBytes];
            int index = 0;

            for (int y = 0; y < height; y++)
            {
                int bitIndex = 0;
                byte currentByte = 0;

                for (int x = 0; x < width; x++)
                {
                    Color pixel = bitmap.GetPixel(x, y);

                    // White = 1, Black = 0 규칙으로 변경 (ZPL 표준)
                    int bit = (pixel.R + pixel.G + pixel.B) / 3 > 128 ? 1 : 0;

                    currentByte = (byte)((currentByte << 1) | bit);
                    bitIndex++;

                    // 8비트 완성되었으면 저장
                    if (bitIndex == 8)
                    {
                        imageData[index++] = currentByte;
                        currentByte = 0;
                        bitIndex = 0;
                    }
                }

                // 남는 비트 처리
                if (bitIndex > 0)
                {
                    currentByte = (byte)(currentByte << (8 - bitIndex));
                    imageData[index++] = currentByte;
                }
            }

            // HEX 변환
            StringBuilder hex = new StringBuilder(imageData.Length * 2);
            foreach (byte b in imageData)
            {
                hex.Append(b.ToString("X2"));
            }

            // ★ 오직 ^GFA 명령만 반환 ★
            // 사용처에서 ^FO, ^XA, ^XZ를 직접 조립 가능하도록
            string gfa =
                $"^GFA,{totalBytes},{totalBytes},{widthBytes},{hex}";

            return gfa;
        }
    }
}
