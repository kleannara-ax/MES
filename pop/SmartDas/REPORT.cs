using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows.Forms;

using Excel = Microsoft.Office.Interop.Excel;
using System.IO;
using System.Threading;

namespace SmartDas
{
    public class REPORT_ITEM
    {
        public string IND_BCD { get; set; }     // 개별바코드
        public string PCODE_NM { get; set; }    // 지종
        public string BS_WGT { get; set; }      // 평량
        public string WIDTH { get; set; }       // 지폭
        public string JROLLCNT { get; set; }        // 계획권치수
        public string PRFM_ROLLCNT { get; set; }    // 실적권치수
        public string PRFM_WGT { get; set; }     // 실적중량
        public string JR_MACHINE { get; set; }   // J/R 호기
        public string MR_MACHINE { get; set; }   // M/R 지시호기
        public string STM_TM { get; set; }       // 생산시작시간
        public string END_TM { get; set; }       // 생산종료시간
        public string WRK_TM { get; set; }       // 가동시간
        public string PRD_DIV { get; set; }      // 생산유형
        public string PRD_DATE { get; set; }     // 생산일시
        public string WRK_SHIFT { get; set; }    // 반
        public string WRK_NAME { get; set; }     // 작업자
        public string LOT_NO { get; set; }       // LOT_NO (10자리)
        public string ORDER_NO { get; set; }     // ORDER_NO (10자리)
        public string RUN_STA { get; set; }      // 운전상태 01 : 정상, 08 : 비계획생산
        public string PRD_NO { get; set; }       // 생산번호
        public string RSPEED { get; set; }    // 선속
        public string ORDER_RMK { get; set; }    // 지시사항
        public string WRK_ORDR_RMK { get; set; } // 비고
        
        // 밀롤 추가
        public string REWIND_SPEC { get; set; }     // ReWinder 규격
        
        // 재단 추가
        public string TITLE_NAME { get; set; }        // 재단, 수재단 표시 (PCB로 시작되면 수재단, 나머지는 재단) 
        public string REAM_CNT { get; set; }        // 연수 
        public string SPEC { get; set; }            // 규격
        public string PLT_PER_CNT { get; set; }     // 팔레트당 연수 
        public string IN_PER_CNT { get; set; }      // 속당매수
        public string IN_CNT { get; set; }          // 속수
        public string SEQ { get; set; }             // 순번
        public string CT_MACHINE { get; set; }      // 재단(슬리터) 호기
        public string PACKTYPE { get; set; }        // 포장타입
        public string CUST_NM { get; set; }         // 거래처명
        public string LAND_CD { get; set; }         // 국가코드
        public string LAND_NM { get; set; }         // 국가명
        public string ROUTE { get; set; }           // 항차

        public string WIDTH_NO { get; set; }     // 지폭순번
        public string SALES_ORDR_NO { get; set; }   // Sales Order No

        // 수재단
        public int MAN_CUT_YN { get; set; }            // 수재단여부
        public int nMOVE_CNT { get; set; }          // 이동건수
        public string MOVE_REAM_CNT { get; set; }   // 이동연수
        public MOVE_LIST[] movList = new MOVE_LIST[10];     //  수재단에서 이동할 개별 항목들

        //HL공통 추가
        public string MACH_NM { get; set; }         //생산호기 명칭
        public string WERKS_NM { get; set; }        //제품(플랜트)구분 명칭
        public string MATNR { get; set; }           //제품코드
        public string MATNR_NM { get; set; }        //제품명
        public string KAN_CD { get; set; }          //KAN 코드
        public string UNIT { get; set; }            //기본단위(BAG/BOX)
        public string PLT_UNIT { get; set; }        //팔레트 단위(BOX/PLT)

        //합지기 추가
        public string QCJUD { get; set; }           //합부판정
        public string COLOR { get; set; }           //색상

        //자재 추가
        public string POCUST { get; set; }           //납품업체
        public string POCUST_NM { get; set; }           //납품업체명
        public string PO_NO { get; set; }           //PO번호
        public string QCREQ_NO { get; set; }           //검수요청번호
        public string QCREQ_DT { get; set; }           //검수요청일
        public string QCREQ_QTY { get; set; }           //검수요청수량
        public string QCPAL_QTY { get; set; }           //Pallet적치수량

        //라미네이팅 추가
        public string HEIGHT { get; set; }           //길이
        public string BAR_CODE { get; set; }         // 개별바코드(바코드)

    }

    /// <summary>
    /// 수재단에서 이동할 개별 항목
    /// </summary>
    public class MOVE_LIST
    {
        public string IND_BCD { get; set; }    // 개별바코드
        public string REAM_CNT { get; set; }    // 실적연수
        public string PRFM_WGT { get; set; }    // 실적중량
        public string SPEC { get; set; }    // 규격
        public string WIDTH { get; set; }    // 지폭
    }

    public class REPORT
    {
        private Excel.Application gxlApp = null;
        private Excel.Workbook gwb = null;
        
//        private string strLocalPath = Application.ExecutablePath.Substring(0, Application.ExecutablePath.LastIndexOf('\\'));

        private bool isExcelOpenning = false;
        private bool isReady = false;

        public bool ReadyCheck()
        {
            return isReady;
        }

        public void EXCEL_COPY(string sPlantCode)
        {
            try
            {
                //if (isReady == true)
                //{
                //    return;
                //}

                string strExcelPath = System.IO.Path.GetTempPath() + "SmartDAS\\";
                if (Directory.Exists(strExcelPath) == false)
                {
                    Directory.CreateDirectory(strExcelPath);
                }

                string strExcelFile;

                strExcelFile = strExcelPath + "ps.xlsx";

                if (File.Exists(strExcelFile))
                {
                    System.IO.File.Delete(strExcelFile);
                }
                System.IO.File.WriteAllBytes(strExcelFile, Properties.Resources.PS_XLSX);


                strExcelFile = strExcelPath + "hl.xlsx";
                if (File.Exists(strExcelFile))
                {
                    System.IO.File.Delete(strExcelFile);
                }
                System.IO.File.WriteAllBytes(strExcelFile, Properties.Resources.HL_XLSX);
            }
            catch (Exception ex)
            {
                LogFile.WriteLog("REPORT.EXCEL_COPY Error => " + ex.Message);
            }
            finally
            {
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="XLSX_RES"></param>
        public void EXCEL_OPEN(string sPlantCode)
        {
            try
            {
                if (isReady == true)
                {
                    return;
                }

                isExcelOpenning = true;  // 엑셀 열기 시작
                isReady = false;        // 엑셀 파일 열기 성공하여 인쇄 가능 상태

                //string tempPath = System.IO.Path.GetTempFileName();

                string strExcelFile;

                if (sPlantCode.Equals("P100"))
                {
                    strExcelFile = System.IO.Path.GetTempPath() + "SmartDAS\\ps.xlsx";
                    if (!File.Exists(strExcelFile))
                    {
                        System.IO.File.WriteAllBytes(strExcelFile, Properties.Resources.PS_XLSX);
                    }
                }
                else
                {
                    strExcelFile = System.IO.Path.GetTempPath() + "SmartDAS\\hl.xlsx";
                    if (!File.Exists(strExcelFile))
                    {
                        System.IO.File.WriteAllBytes(strExcelFile, Properties.Resources.HL_XLSX);
                    }
                }

//                DateTime dtPreTime = DateTime.Now;
//                Console.WriteLine("excel open start!");
                gxlApp = new Excel.Application();
                gxlApp.Visible = false;
                gxlApp.DisplayAlerts = false;
                gxlApp.ScreenUpdating = false;
                gxlApp.DisplayStatusBar = false;
                gxlApp.EnableEvents = false;

                //gwb = gxlApp.Workbooks.Open(strExcelFile);
                gwb = gxlApp.Workbooks.Open(strExcelFile,
                                            0,
                                            true,
                                            5,
                                            "",
                                            "",
                                            true,
                                            Excel.XlPlatform.xlWindows,
                                            "\t",
                                            false,
                                            false,
                                            0,
                                            true,
                                            1,
                                            0);
                
                //gwb.EnableAutoRecover = false;

                isReady = true;        // 엑셀 파일 열기 성공하여 인쇄 가능 상태
//                Console.WriteLine("excel open end!");
            }
            catch (Exception ex)
            {
                isExcelOpenning = false;  // 엑셀 열기 시작
                isReady = false;

                ReleaseExcelObject(gwb);
                ReleaseExcelObject(gxlApp);

                GC.Collect();

                LogFile.WriteLog("REPORT.EXCEL_OPEN Error => " + ex.Message);
            }
            finally
            {
            }
        }

        public void EXCEL_CLOSE()
        {
            if (isReady == false)
            {
                return;
            }

            try
            {
                // 파일 닫기..
                gwb.Close(false, Type.Missing, Type.Missing);
                gwb = null;
                gxlApp.Quit();
                gxlApp = null;
            }
            catch (Exception ex)
            {
                LogFile.WriteLog("REPORT.EXCEL_CLOSE Error => " + ex.Message);
            }
            finally
            {
                ReleaseExcelObject(gwb);
                ReleaseExcelObject(gxlApp);

                GC.Collect();

                isExcelOpenning = false;  // 엑셀 열기 시작
                isReady = false;
            }
        }

        private bool CheckReady()
        {
#if true
            return true;
#else
            bool bReturn = false;

            if (isReady == false && isExcelOpenning == false)
            {
                EXCEL_OPEN(Common.PlantCode);

                if (isReady == true)
                {
                    bReturn = true;
                }
            }
            else if (isReady == true && isExcelOpenning == true)
            {
                bReturn = true;
            }
            else
            {
                for(int i=0; i< 10; i++)
                {
                    if (isReady == true)
                    {
                        bReturn = true;
                        break;
                    }
                    Thread.Sleep(1000);
                }
            }

            if (bReturn == false)
            {
                new POPUP.MessageForm("인쇄 오류가 발생했습니다.", MessageBoxButtons.OK, "알   림").ShowDialog(this);
            }

            return bReturn;
#endif
        }

        /// <summary>
        /// 점보롤 A4 인쇄
        /// </summary>
        /// <param name="item"></param>
        /// <param name="pstrERR"></param>
        public void JR_PRINT(REPORT_ITEM JRitem, ref string pstrERR)
        {
            //Excel.Application xlApp = null;
            //Excel.Workbook wb = null;
            Excel.Worksheet ws = null;

            if (CheckReady() == false)
            {
                return;
            }

            try
            {
                ws = gwb.Worksheets["JRSheet"] as Excel.Worksheet;  // 사용할 Sheet 가져오기

                //------------------------------------------------------
                // WordkSheet 사용한 Cell 초기화
                //------------------------------------------------------
                ws.Cells[1, 2] = "";        // 개별바코드
                ws.Cells[1, 5] = "";
                ws.Cells[3, 1] = "";        // 지종               "Grayback";
                ws.Cells[5, 1] = "";        // 평량               "440";
                ws.Cells[5, 4] = "";        // 길이(M)  실적권치수  "18,000";
                ws.Cells[7, 1] = "";        // 계획권치수            "18,000";
                ws.Cells[7, 4] = "";        // 실적중량             "33,333";
                ws.Cells[9, 1] = "";        // J/R 호기       "PM3";
                ws.Cells[9, 4] = "";        // M/R 호기       "PM3";
                ws.Cells[11, 1] = "";       // 생산시작시간
                ws.Cells[12, 1] = "";       // 생산종료시간
                ws.Cells[11, 3] = "";       // 가동시간
                ws.Cells[11, 4] = "";       // 생산유형   "라인교체";               
                ws.Cells[14, 1] = "";       // 생산일시
                ws.Cells[14, 4] = "";       // 작업반      "A조";
                ws.Cells[14, 5] = "";       // 작업자      "김병무";
                ws.Cells[16, 1] = "";       // LOT_NO + 비계획생산유무;
                ws.Cells[16, 4] = "";       // ORDER_NO + 비계획생산유무;
                ws.Cells[18, 1] = "";       // 생산번호     "2022-04-14-PM3-1";
                ws.Cells[18, 6] = "";       // 선속        "600";
                ws.Cells[20, 1] = "";       // 작업지시사항 "점보롤 테스트용 지시사항";
                ws.Cells[22, 1] = "";       // 오더비고 "점보롤 테스트용 비고사항";
                ws.Cells[23, 1] = "";       // 개별바코드
                ws.Cells[24, 1] = "";       // 개별바코드
                //------------------------------------------------------

                string sIND_BCD = JRitem.IND_BCD.ToUpper();
                string sIND_BCD_BARCODE = "";

                ws.Cells[1, 2] = sIND_BCD;      // 개별바코드

                try
                {
                    //string strBARCODE = "";
                    //string strERR = "";
                    //strBARCODE = strLotNo;
                    BARCODE bc = new BARCODE();
                    sIND_BCD_BARCODE = bc.CODE128(sIND_BCD, "A", ref pstrERR);

                    if (pstrERR.Length > 0)
                    {
                        return;
                    }
                }
                catch (Exception ex)
                {
                    LogFile.WriteLog("REPORT.JR_PRINT IND_BCD Error => " + ex.Message);
                    //txtERROR.Text = ex.Message.ToString();
                }

                if (JRitem.RUN_STA.Equals("08"))
                {
                    JRitem.JROLLCNT = "0";
                }


                ws.Cells[1, 5] = sIND_BCD_BARCODE;

                ws.Cells[3, 1] = JRitem.PCODE_NM;       // 지종               "Grayback";

                ws.Cells[5, 1] = JRitem.BS_WGT;         // 평량               "440";
                ws.Cells[5, 4] = JRitem.PRFM_ROLLCNT;   // 길이(M)  실적권치수  "18,000";

                ws.Cells[7, 1] = JRitem.JROLLCNT;     // 계획권치수            "18,000";
                ws.Cells[7, 4] = JRitem.PRFM_WGT;     // 실적중량             "33,333";

                ws.Cells[9, 1] = JRitem.JR_MACHINE;   // J/R 호기       "PM3";
                ws.Cells[9, 4] = JRitem.MR_MACHINE;   // M/R 호기       "PM3";

                ws.Cells[11, 1] = "시작  " + JRitem.STM_TM; // 생산시작시간
                ws.Cells[12, 1] = "종료  " + JRitem.END_TM; // 생산종료시간
                ws.Cells[11, 3] = JRitem.WRK_TM + "분";     // 가동시간
                ws.Cells[11, 4] = JRitem.PRD_DIV;          // 생산유형   "라인교체";               

                ws.Cells[14, 1] = JRitem.PRD_DATE;        // 생산일시
                ws.Cells[14, 4] = JRitem.WRK_SHIFT;       // 작업반      "A조";
                ws.Cells[14, 5] = JRitem.WRK_NAME;        // 작업자      "김병무";

                string sNON_ORDR = "";
                if (JRitem.RUN_STA.Equals("09"))
                {
                    sNON_ORDR = "비계획생산";
                }

                ws.Cells[16, 1] = JRitem.LOT_NO;                        // LOT_NO;

                string strORDR = JRitem.ORDER_NO + " " + sNON_ORDR;     // 오더번호 + 비계획생산유무
                ws.Cells[16, 4] = strORDR.Trim();                       // 오더번호 + 비계획생산유무


                ws.Cells[18, 1] = JRitem.PRD_NO;          // 생산번호     "2022-04-14-PM3-1";
                ws.Cells[18, 6] = JRitem.RSPEED;          // 선속        "600";

                ws.Cells[20, 1] = JRitem.ORDER_RMK;       // 작업지시사항 "점보롤 테스트용 지시사항";

                ws.Cells[22, 1] = JRitem.WRK_ORDR_RMK;    // 오더비고 "점보롤 테스트용 비고사항";

                ws.Cells[23, 1] = sIND_BCD_BARCODE;          // 개별바코드

                ws.Cells[24, 1] = sIND_BCD;             // 개별바코드

                ws.PrintOutEx();
    
            }
            catch (Exception ex)
            {
                LogFile.WriteLog("REPORT.JR_PRINT Error => " + ex.Message);
            }
            finally
            {
                ReleaseExcelObject(ws);
                GC.Collect();
            }
        }


        /// <summary>
        /// 밀롤 A4 인쇄
        /// </summary>
        /// <param name="CTitem"></param>
        /// <param name="pstrERR"></param>
        public void MR_PRINT(REPORT_ITEM MRitem, ref string pstrERR, int nPrtCnt=1)
        {
            //Excel.Application xlApp = null;
            //Excel.Workbook wb = null;
            Excel.Worksheet ws = null;

            if (CheckReady() == false)
            {
                return;
            }

            try
            {
                ws = gwb.Worksheets["MRSheet"] as Excel.Worksheet;  // 사용할 Sheet 가져오기

                //------------------------------------------------------
                // WordkSheet 사용한 Cell 초기화
                //------------------------------------------------------
                ws.Cells[1, 2] = "";        // 개별바코드
                ws.Cells[1, 5] = "";
                ws.Cells[3, 1] = "";        // 지종               "Grayback";
                ws.Cells[5, 1] = "";        // 실적권치수  "18,000";
                ws.Cells[5, 4] = "";        // 실적중량             "33,333";
                ws.Cells[7, 1] = "";        // 평량               "440";
                ws.Cells[7, 3] = "";        // ReWinder 규격
                ws.Cells[7, 5] = "";        // 규격          "0660*0000"
                ws.Cells[9, 1] = "";        // 팔레트 당 연수  "4.4";
                ws.Cells[9, 3] = "";        // 속당매수 / 속수
                ws.Cells[9, 5] = "";        // SEQ "2"
                ws.Cells[9, 6] = "";        // 지폭순번       "21-1";
                ws.Cells[11, 1] = "";       // J/R 호기       "PM3";
                ws.Cells[11, 3] = "";       // M/R 호기       "PM3";
                ws.Cells[11, 5] = "";       // 재단(슬리터)호기       "3호기 재단기 #7";
                ws.Cells[13, 1] = "";       // 포장타입       "속포장";
                ws.Cells[13, 3] = "";       // 거래처명       "(주)한일상사";
                ws.Cells[15, 1] = "";       // 생산일시
                ws.Cells[15, 4] = "";       // 작업반      "A조";
                ws.Cells[15, 5] = "";       // 작업자      "김병무";
                ws.Cells[17, 1] = "";       // LOT_NO
                ws.Cells[17, 4] = "";       // Sales Order NO.
                ws.Cells[19, 1] = "";       // 작업지시사항 "점보롤 테스트용 지시사항";
                ws.Cells[21, 1] = "";       // 오더비고 "점보롤 테스트용 비고사항";
                ws.Cells[22, 1] = "";       // 개별바코드
                ws.Cells[23, 1] = "";       // 개별바코드
                //------------------------------------------------------
                string sIND_BCD = MRitem.IND_BCD.ToUpper();
                string sIND_BCD_BARCODE = "";

                ws.Cells[1, 2] = sIND_BCD;      // 개별바코드

                try
                {
                    BARCODE bc = new BARCODE();
                    sIND_BCD_BARCODE = bc.CODE128(sIND_BCD, "A", ref pstrERR);

                    if (pstrERR.Length > 0)
                    {
                        return;
                    }
                }
                catch (Exception ex)
                {
                    LogFile.WriteLog("REPORT.MR_PRINT IND_BCD Error => " + ex.Message);
                    //txtERROR.Text = ex.Message.ToString();
                }

                ws.Cells[1, 5] = sIND_BCD_BARCODE;

                ws.Cells[3, 1] = MRitem.PCODE_NM;           // 지종               "Grayback";

                ws.Cells[5, 1] = MRitem.PRFM_ROLLCNT;       // 실적권치수  "18,000";
                ws.Cells[5, 4] = MRitem.PRFM_WGT;           // 실적중량             "33,333";


                ws.Cells[7, 1] = MRitem.BS_WGT;             // 평량               "440";
                ws.Cells[7, 3] = MRitem.REWIND_SPEC;        // ReWinder 규격
                ws.Cells[7, 5] = MRitem.SPEC;               // 규격          "0660*0000"

                ws.Cells[9, 1] = MRitem.PLT_PER_CNT;   // 팔레트 당 연수  "4.4";
                ws.Cells[9, 3] = MRitem.IN_PER_CNT + " / " + MRitem.IN_CNT;   // 속당매수 / 속수
                ws.Cells[9, 5] = MRitem.SEQ;                                  // SEQ "2"
                ws.Cells[9, 6] = MRitem.WIDTH_NO;   // 지폭순번       "21-1";

                ws.Cells[11, 1] = MRitem.JR_MACHINE;   // J/R 호기       "PM3";
                ws.Cells[11, 3] = MRitem.MR_MACHINE;   // M/R 호기       "PM3";
                ws.Cells[11, 5] = MRitem.CT_MACHINE;   // 재단(슬리터)호기       "3호기 재단기 #7";

                ws.Cells[13, 1] = MRitem.PACKTYPE;      // 포장타입       "속포장";
                ws.Cells[13, 3] = MRitem.CUST_NM;       // 거래처명       "(주)한일상사";

                ws.Cells[15, 1] = MRitem.PRD_DATE;        // 생산일시
                ws.Cells[15, 4] = MRitem.WRK_SHIFT;       // 작업반      "A조";
                ws.Cells[15, 5] = MRitem.WRK_NAME;        // 작업자      "김병무";

                ws.Cells[17, 1] = MRitem.LOT_NO;          // LOT_NO
                ws.Cells[17, 4] = MRitem.SALES_ORDR_NO;          // Sales Order NO.

                ws.Cells[19, 1] = MRitem.ORDER_RMK;       // 작업지시사항 "점보롤 테스트용 지시사항";

                ws.Cells[21, 1] = MRitem.WRK_ORDR_RMK;          // 오더비고 "점보롤 테스트용 비고사항";

                ws.Cells[22, 1] = sIND_BCD_BARCODE;          // 개별바코드

                ws.Cells[23, 1] = sIND_BCD;             // 개별바코드

                if (nPrtCnt > 1)
                {
                    for (int i = 0; i < nPrtCnt; i++)
                    {
                        ws.PrintOutEx();
                    }
                }
                else
                {
                    ws.PrintOutEx();
                }
            }
            catch (Exception ex)
            {
                LogFile.WriteLog("REPORT.MR_PRINT Error => " + ex.Message);
            }
            finally
            {
                ReleaseExcelObject(ws);

                GC.Collect();
            }

        }

        /// <summary>
        /// 재단 A4 인쇄
        /// </summary>
        /// <param name="CTitem"></param>
        /// <param name="pstrERR"></param>
        public void CT_PRINT(REPORT_ITEM CTitem, ref string pstrERR, int nPrtCnt = 1)
        {
            //Excel.Application xlApp = null;
            //Excel.Workbook wb = null;
            Excel.Worksheet ws = null;

            if (CheckReady() == false)
            {
                return;
            }


            try
            {
                ws = gwb.Worksheets["CTSheet"] as Excel.Worksheet;  // 사용할 Sheet 가져오기

                //------------------------------------------------------
                // WordkSheet 사용한 Cell 초기화
                //------------------------------------------------------
                ws.Cells[1, 2] = "";        // 개별바코드
                ws.Cells[1, 5] = "";
                ws.Cells[3, 1] = "";        // 지종               "Grayback";
                ws.Cells[5, 1] = "";        // 평량               "440";
                ws.Cells[5, 4] = "";        // 규격          "660x490"
                ws.Cells[7, 1] = "";        // 연수            "9.6";
                ws.Cells[7, 4] = "";        // 실적중량         "33,333";
                ws.Cells[9, 1] = "";        // 팔레트 당 연수  "4.4";
                ws.Cells[9, 3] = "";        // 속당매수 / 속수
                ws.Cells[9, 5] = "";        // SEQ "2"
                ws.Cells[9, 6] = "";        // 지폭순번       "21-1";
                ws.Cells[11, 1] = "";       // J/R 호기       "PM3";
                ws.Cells[11, 3] = "";       // M/R 호기       "PM3";
                ws.Cells[11, 5] = "";       // 재단(슬리터)호기       "3호기 재단기 #7";
//                ws.Cells[12, 3] = "";       // 거래처 : 항차
                ws.Cells[12, 5] = "";       // 국가명       "오스트레일리아";

                ws.Cells[13, 1] = "";       // 포장타입       "속포장";
                ws.Cells[13, 3] = "";       // 거래처명       "(주)한일상사";
                ws.Cells[15, 1] = "";       // 생산일시
                ws.Cells[15, 4] = "";       // 작업반      "A조";
                ws.Cells[15, 5] = "";       // 작업자      "김병무";
                ws.Cells[17, 1] = "";       // LOT_NO
                ws.Cells[17, 4] = "";       // Sales Order NO.
                ws.Cells[19, 1] = "";       // 작업지시사항 "점보롤 테스트용 지시사항";
                ws.Cells[21, 1] = "";       // 오더비고 "점보롤 테스트용 비고사항";
                ws.Cells[22, 1] = "";       // 개별바코드
                ws.Cells[23, 1] = "";       // 개별바코드
                //------------------------------------------------------

                string sIND_BCD = CTitem.IND_BCD.ToUpper();
                string sIND_BCD_BARCODE = "";

                ws.Cells[1, 1] = CTitem.TITLE_NAME;  // 타이틀명

                ws.Cells[1, 2] = sIND_BCD;      // 개별바코드명

                try
                {
                    BARCODE bc = new BARCODE();
                    sIND_BCD_BARCODE = bc.CODE128(sIND_BCD, "A", ref pstrERR);

                    if (pstrERR.Length > 0)
                    {
                        return;
                    }
                }
                catch (Exception ex)
                {
                    LogFile.WriteLog("REPORT.CT_PRINT IND_BCD Error => " + ex.Message);
                    //txtERROR.Text = ex.Message.ToString();
                }

                ws.Cells[1, 5] = sIND_BCD_BARCODE;

                ws.Cells[3, 1] = CTitem.PCODE_NM;     // 지종               "Grayback";

                ws.Cells[5, 1] = CTitem.BS_WGT;       // 평량               "440";
                ws.Cells[5, 4] = CTitem.SPEC;         // 규격          "660x490"

                ws.Cells[7, 1] = CTitem.REAM_CNT;     // 연수            "9.6";
                ws.Cells[7, 4] = CTitem.PRFM_WGT;     // 실적중량         "33,333";

                ws.Cells[9, 1] = CTitem.PLT_PER_CNT;   // 팔레트 당 연수  "4.4";
                ws.Cells[9, 3] = CTitem.IN_PER_CNT + " / " + CTitem.IN_CNT;   // 속당매수 / 속수
                ws.Cells[9, 5] = CTitem.SEQ;                                  // SEQ "2"
                ws.Cells[9, 6] = CTitem.WIDTH_NO;   // 지폭순번       "21-1";

                ws.Cells[11, 1] = CTitem.JR_MACHINE;   // J/R 호기       "PM3";
                ws.Cells[11, 3] = CTitem.MR_MACHINE;   // M/R 호기       "PM3";
                ws.Cells[11, 5] = CTitem.CT_MACHINE;   // 재단(슬리터)호기       "3호기 재단기 #7";

//                ws.Cells[12, 3] = "거래처 :   " + CTitem.ROUTE;       // 거래처 : 항차

                if (CTitem.LAND_CD != "KR")
                {
                    ws.Cells[12, 5] = CTitem.LAND_NM;       // 국가명       "오스트레일리아";
                }

                ws.Cells[13, 1] = CTitem.PACKTYPE;      // 포장타입       "속포장";
                ws.Cells[13, 3] = CTitem.CUST_NM;       // 거래처명       "(주)한일상사";

                ws.Cells[15, 1] = CTitem.PRD_DATE;        // 생산일시
                ws.Cells[15, 4] = CTitem.WRK_SHIFT;       // 작업반      "A조";
                ws.Cells[15, 5] = CTitem.WRK_NAME;        // 작업자      "김병무";

                string sNON_ORDR = "";
                if (CTitem.RUN_STA.Equals("09"))
                {
                    sNON_ORDR = "여유";
                }
                ws.Cells[17, 1] = CTitem.LOT_NO + " " + sNON_ORDR;          // LOT_NO + 여유생산
                ws.Cells[17, 4] = CTitem.SALES_ORDR_NO;          // Sales Order NO.

                ws.Cells[19, 1] = CTitem.ORDER_RMK;       // 작업지시사항 "점보롤 테스트용 지시사항";

                ws.Cells[21, 1] = CTitem.WRK_ORDR_RMK;          // 오더비고 "점보롤 테스트용 비고사항";

                ws.Cells[22, 1] = sIND_BCD_BARCODE;          // 개별바코드

                ws.Cells[23, 1] = sIND_BCD;             // 개별바코드

                if (nPrtCnt > 1)
                {
                    for (int i = 0; i < nPrtCnt; i++)
                    {
                        ws.PrintOutEx();
                    }
                }
                else
                {
                    ws.PrintOutEx();
                }

            }
            catch (Exception ex)
            {
                LogFile.WriteLog("REPORT.CT_PRINT Error => " + ex.Message);
            }
            finally
            {
                ReleaseExcelObject(ws);

                GC.Collect();
            }
        }


        /// <summary>
        /// 수재단 A4 인쇄
        /// </summary>
        /// <param name="CTitem"></param>
        /// <param name="pstrERR"></param>
        public void TT_PRINT(REPORT_ITEM  TTitem, ref string pstrERR)
        {
            //Excel.Application xlApp = null;
            //Excel.Workbook wb = null;
            Excel.Worksheet ws = null;

            if (CheckReady() == false)
            {
                return;
            }

            try
            {
                int rowIdx = 7;

                ws = gwb.Worksheets["TTSheet"] as Excel.Worksheet;  // 사용할 Sheet 가져오기

                //------------------------------------------------------
                // WordkSheet 사용한 Cell 초기화
                //------------------------------------------------------
                ws.Cells[1, 2] = "";        // 개별바코드
                ws.Cells[1, 5] = "";        // 개별바코드 
                ws.Cells[2, 4] = "";        // 작업자      "김병무";
                ws.Cells[3, 1] = "";        // 생산일시
                ws.Cells[3, 4] = "";        // 재단(스리터)호기
                ws.Cells[3, 7] = "";        // 이동건수
                ws.Cells[5, 1] = "";        // 지종   "Grayback";
                ws.Cells[5, 6] = "";        // 평량   "440";
                ws.Cells[5, 7] = "";        // 이동연수 "9.6"

                rowIdx = 7;
                for (int i = 0; i < TTitem.nMOVE_CNT; i++)
                {
                    ws.Cells[rowIdx, 1] = "";
                    ws.Cells[rowIdx, 3] = "";
                    ws.Cells[rowIdx, 4] = "";
                    ws.Cells[rowIdx, 6] = "";
                    ws.Cells[rowIdx, 7] = "";
                    rowIdx++;
                }

                ws.Cells[16, 1] = "";       // 작업지시사항 "점보롤 테스트용 지시사항";
                ws.Cells[17, 1] = "";       // 개별바코드
                ws.Cells[18, 1] = "";       // 개별바코드
                //------------------------------------------------------
                string sIND_BCD = TTitem.IND_BCD.ToUpper();     // 개별바코드
                string sIND_BCD_BARCODE = "";

                ws.Cells[1, 2] = sIND_BCD;      // 개별바코드

                try
                {
                    BARCODE bc = new BARCODE();
                    sIND_BCD_BARCODE = bc.CODE128(sIND_BCD, "A", ref pstrERR);

                    if (pstrERR.Length > 0)
                    {
                        return;
                    }
                }
                catch (Exception ex)
                {
                    LogFile.WriteLog("REPORT.TT_PRINT IND_BCD Error => " + ex.Message);
                    //txtERROR.Text = ex.Message.ToString();
                }

                ws.Cells[1, 5] = sIND_BCD_BARCODE;              // 개별바코드 

                ws.Cells[2, 4] = "설비 : " + TTitem.WRK_NAME;    // 작업자      "김병무";

                ws.Cells[3, 1] = TTitem.PRD_DATE;               // 생산일시
                ws.Cells[3, 4] = TTitem.CT_MACHINE;             // 재단(스리터)호기
                ws.Cells[3, 7] = TTitem.nMOVE_CNT.ToString();               // 이동건수


                ws.Cells[5, 1] = TTitem.PCODE_NM;       // 지종   "Grayback";
                ws.Cells[5, 6] = TTitem.BS_WGT;         // 평량   "440";
                ws.Cells[5, 7] = TTitem.MOVE_REAM_CNT;  // 이동연수 "9.6"

                rowIdx = 7;
                for (int i = 0; i < TTitem.nMOVE_CNT; i++)
                {
                    ws.Cells[rowIdx, 1] = TTitem.movList[i].IND_BCD;
                    ws.Cells[rowIdx, 3] = TTitem.movList[i].REAM_CNT;
                    ws.Cells[rowIdx, 4] = TTitem.movList[i].PRFM_WGT;
                    ws.Cells[rowIdx, 6] = TTitem.movList[i].SPEC;
                    ws.Cells[rowIdx, 7] = TTitem.movList[i].WIDTH;
                    rowIdx++;
                }

                ws.Cells[16, 1] = TTitem.WRK_ORDR_RMK;       // 작업지시사항 "점보롤 테스트용 지시사항";

                ws.Cells[17, 1] = sIND_BCD_BARCODE;          // 개별바코드

                ws.Cells[18, 1] = sIND_BCD;                  // 개별바코드

                ws.PrintOutEx();
            }
            catch (Exception ex)
            {
                LogFile.WriteLog("REPORT.TT_PRINT Error => " + ex.Message);
            }
            finally
            {
                ReleaseExcelObject(ws);

                GC.Collect();
            }

        }

        /// <summary>
        /// HL A4 인쇄
        /// </summary>
        /// <param name="item"></param>
        /// <param name="pstrERR"></param>
        public void HL_PRINT(REPORT_ITEM HLitem, ref string pstrERR)
        {
            //Excel.Application xlApp = null;
            //Excel.Workbook wb = null;
            Excel.Worksheet ws = null;

            if (CheckReady() == false)
            {
                return;
            }

            try
            {
                ws = gwb.Worksheets["HLSheet"] as Excel.Worksheet;

                //------------------------------------------------------
                // WordkSheet 사용한 Cell 초기화
                //------------------------------------------------------
                ws.Cells[1, 2] = "";    // 개별바코드
                ws.Cells[2, 3] = "";    // 입고일자
                ws.Cells[3, 3] = "";    // 생산호기
                ws.Cells[4, 3] = "";    // 제품목록
                ws.Cells[5, 3] = "";    // 제품코드
                ws.Cells[6, 3] = "";    // 제품명
                ws.Cells[7, 3] = "";    // KAN코드
                ws.Cells[8, 3] = "";    // 기본단위
                ws.Cells[10, 3] = "";   // 팔레트 단위

                ws.Cells[12, 2] = "";   // 개별바코드
                ws.Cells[13, 2] = "";   // 개별바코드 텍스트
                //------------------------------------------------------

                string sIND_BCD = HLitem.IND_BCD.ToUpper();
                string sIND_BCD_BARCODE = "";

                ws.Cells[1, 2] = sIND_BCD;      // 개별바코드

                try
                {
                    BARCODE bc = new BARCODE();
                    sIND_BCD_BARCODE = bc.CODE128(sIND_BCD, "A", ref pstrERR);

                    if (pstrERR.Length > 0)
                    {
                        return;
                    }
                }
                catch (Exception ex)
                {
                    LogFile.WriteLog("REPORT.HL_PRINT IND_BCD Error => " + ex.Message);
                    //txtERROR.Text = ex.Message.ToString();
                }

                ws.Cells[2, 3] = HLitem.PRD_DATE; //입고일자
                ws.Cells[3, 3] = HLitem.MACH_NM; //생산호기
                ws.Cells[4, 3] = HLitem.WERKS_NM; //제품목록
                ws.Cells[5, 3] = HLitem.MATNR; //제품코드
                ws.Cells[6, 3] = HLitem.MATNR_NM; //제품명
                ws.Cells[7, 3] = HLitem.KAN_CD; //KAN코드
                ws.Cells[8, 3] = HLitem.UNIT; //기본단위
                ws.Cells[10, 3] = HLitem.PLT_UNIT; //팔레트 단위

                ws.Cells[12, 2] = sIND_BCD_BARCODE; //개별바코드
                ws.Cells[13, 2] = sIND_BCD; //개별바코드 텍스트

                ws.PrintOutEx();

            }
            catch (Exception ex)
            {
                LogFile.WriteLog("REPORT.HL_PRINT Error => " + ex.Message);
            }
            finally
            {
                ReleaseExcelObject(ws);
                GC.Collect();
            }
        }

        /// <summary>
        /// HL 합지기 A4 인쇄
        /// </summary>
        /// <param name="item"></param>
        /// <param name="pstrERR"></param>
        public void AA_PRINT(REPORT_ITEM HLitem, ref string pstrERR)
        {
            //Excel.Application xlApp = null;
            //Excel.Workbook wb = null;
            Excel.Worksheet ws = null;

            if (CheckReady() == false)
            {
                return;
            }

            try
            {
                ws = gwb.Worksheets["AASheet"] as Excel.Worksheet;

                //------------------------------------------------------
                // WordkSheet 사용한 Cell 초기화
                //------------------------------------------------------
                ws.Cells[1, 2] = "";        // 개별바코드
                ws.Cells[1, 3] = "";        // 설비호기 명
                ws.Cells[2, 3] = "";        // LOT NO
                ws.Cells[4, 3] = "";        // 제품규격
                ws.Cells[1, 7] = "";        // 길이
                ws.Cells[5, 3] = "";        // 평량
                ws.Cells[5, 6] = "";        // 중량
                ws.Cells[6, 3] = "";        // 색
                ws.Cells[6, 6] = "";        // 작업자
                ws.Cells[7, 3] = "";        // 판정
                ws.Cells[8, 3] = "";        //개별바코드
                ws.Cells[9, 3] = "";        //개별바코드 텍스트
                //------------------------------------------------------

                string sIND_BCD = HLitem.IND_BCD.ToUpper();
                string sIND_BCD_BARCODE = "";

                //ws.Cells[1, 2] = sIND_BCD;      // 개별바코드

                try
                {
                    BARCODE bc = new BARCODE();
                    sIND_BCD_BARCODE = bc.CODE128(sIND_BCD, "A", ref pstrERR);

                    if (pstrERR.Length > 0)
                    {
                        return;
                    }
                }
                catch (Exception ex)
                {
                    LogFile.WriteLog("REPORT.AA_PRINT IND_BCD Error => " + ex.Message);
                    //txtERROR.Text = ex.Message.ToString();
                }

                ws.Cells[1, 3] = HLitem.MACH_NM;        // 설비호기 명
                ws.Cells[2, 3] = HLitem.LOT_NO;         // LOT NO
                ws.Cells[4, 3] = HLitem.SPEC;           // 제품규격
                ws.Cells[1, 7] = HLitem.PRFM_ROLLCNT;   // 길이
                ws.Cells[5, 3] = HLitem.BS_WGT;         // 평량
                ws.Cells[5, 6] = HLitem.PRFM_WGT;       // 중량
                ws.Cells[6, 3] = HLitem.COLOR;          // 색
                ws.Cells[6, 6] = HLitem.WRK_NAME;       // 작업자
                ws.Cells[7, 3] = HLitem.QCJUD;          // 판정

                ws.Cells[8, 3] = sIND_BCD_BARCODE;      //개별바코드
                ws.Cells[9, 3] = sIND_BCD;              //개별바코드 텍스트

                ws.PageSetup.Orientation = Excel.XlPageOrientation.xlLandscape;
                ws.PrintOutEx();
            }
            catch (Exception ex)
            {
                LogFile.WriteLog("REPORT.AA_PRINT Error => " + ex.Message);
            }
            finally
            {
                ReleaseExcelObject(ws);
                GC.Collect();
            }
        }

        /// <summary>
        /// RM A4 인쇄
        /// </summary>
        /// <param name="item"></param>
        /// <param name="pstrERR"></param>
        public void RM_PRINT(REPORT_ITEM RMitem, ref string pstrERR)
        {
            //Excel.Application xlApp = null;
            //Excel.Workbook wb = null;
            Excel.Worksheet ws = null;

            if (CheckReady() == false)
            {
                return;
            }

            try
            {
                ws = gwb.Worksheets["RMSheet"] as Excel.Worksheet;

                //------------------------------------------------------
                // WordkSheet 사용한 Cell 초기화
                //------------------------------------------------------
                ws.Cells[2, 2] = "";    // 납품업체
                ws.Cells[3, 2] = "";    // 납품업체명
                ws.Cells[4, 2] = "";    // PO번호
                ws.Cells[5, 2] = "";    // 검수요청번호
                ws.Cells[6, 2] = "";    // 검수요청일
                ws.Cells[7, 2] = "";    // ERP품목코드
                ws.Cells[8, 2] = "";    // 품목명
                ws.Cells[9, 2] = "";    // 검수요청수량
                ws.Cells[10, 2] = "";    // 입고단위
                ws.Cells[11, 2] = "";   // 검수 Pallet수
                ws.Cells[12, 2] = "";   // Pallet 적치수량
                ws.Cells[13, 2] = "";   // 생산일자
                ws.Cells[14, 2] = "";   // LOT번호
                ws.Cells[15, 2] = "";   // 개별바코드 텍스트
                ws.Cells[16, 2] = "";   // 개별바코드
                //------------------------------------------------------

                string sIND_BCD = RMitem.IND_BCD.ToUpper();
                string sIND_BCD_BARCODE = "";

                try
                {
                    BARCODE bc = new BARCODE();
                    sIND_BCD_BARCODE = bc.CODE128(sIND_BCD, "A", ref pstrERR);

                    if (pstrERR.Length > 0)
                    {
                        return;
                    }
                }
                catch (Exception ex)
                {
                    LogFile.WriteLog("REPORT.RM_PRINT IND_BCD Error => " + ex.Message);
                    //txtERROR.Text = ex.Message.ToString();
                }

                ws.Cells[2, 2] = RMitem.POCUST;         // 납품업체
                ws.Cells[3, 2] = RMitem.POCUST_NM;      // 납품업체명
                ws.Cells[4, 2] = RMitem.PO_NO;          // PO번호
                ws.Cells[5, 2] = RMitem.QCREQ_NO;       // 검수요청번호
                ws.Cells[6, 2] = RMitem.QCREQ_DT;       // 검수요청일
                ws.Cells[7, 2] = RMitem.MATNR;          // ERP 제품코드
                ws.Cells[8, 2] = RMitem.MATNR_NM;       // 제품명
                ws.Cells[9, 2] = RMitem.QCREQ_QTY;      // 검수요청수량
                ws.Cells[10, 2] = RMitem.UNIT;          // 입고단위
                ws.Cells[11, 2] = RMitem.QCPAL_QTY;     // 검수 Pallet수
                ws.Cells[12, 2] = RMitem.QCREQ_QTY;     // Pallet 적치수량
                ws.Cells[13, 2] = RMitem.PRD_DATE;      // 생산일자
                ws.Cells[14, 2] = RMitem.LOT_NO;        // LOT번호
                ws.Cells[15, 2] = sIND_BCD;             // 개별바코드 텍스트
                ws.Cells[16, 2] = sIND_BCD_BARCODE;     // 개별바코드

                ws.PrintOutEx();

            }
            catch (Exception ex)
            {
                LogFile.WriteLog("REPORT.RM_PRINT Error => " + ex.Message);
            }
            finally
            {
                ReleaseExcelObject(ws);
                GC.Collect();
            }
        }

        /// <summary>
        /// 라미네이팅 A5 인쇄
        /// </summary>
        /// <param name="CTitem"></param>
        /// <param name="pstrERR"></param>
        public void LAMI_PRINT(REPORT_ITEM MRitem, ref string pstrERR, int nPrtCnt = 1)
        {
            //Excel.Application xlApp = null;
            //Excel.Workbook wb = null;
            Excel.Worksheet ws = null;

            if (CheckReady() == false)
            {
                return;
            }

            try
            {
                ws = gwb.Worksheets["LAMIsheet"] as Excel.Worksheet;  // 사용할 Sheet 가져오기

                //------------------------------------------------------
                // WordkSheet 사용한 Cell 초기화
                //------------------------------------------------------
                ws.Cells[1, 3] = "";        // 제조사명
                ws.Cells[2, 3] = "";        // 생산일자
                ws.Cells[3, 3] = "";        // 규격
                ws.Cells[4, 3] = "";        // 중량
                ws.Cells[5, 3] = "";        // 길이
                ws.Cells[6, 3] = "";        // 지종
                ws.Cells[7, 3] = "";        // 평량
                ws.Cells[8, 3] = "";        // 반장/작업자
                ws.Cells[9, 3] = "";        // LOT NO
                ws.Cells[10, 3] = "";        // 개별바코드(번호)
                ws.Cells[11, 3] = "";        // 개별바코드(바코드)
                //------------------------------------------------------
                string sBAR_CODE = MRitem.BAR_CODE.ToUpper();
                string sIND_BCD_BARCODE = "";

                try
                {
                    BARCODE bc = new BARCODE();
                    sIND_BCD_BARCODE = bc.CODE128(sBAR_CODE, "A", ref pstrERR);

                    if (pstrERR.Length > 0)
                    {
                        return;
                    }
                }
                catch (Exception ex)
                {
                    LogFile.WriteLog("REPORT.LAMI_PRINT IND_BCD Error => " + ex.Message);
                    //txtERROR.Text = ex.Message.ToString();
                }

                ws.Cells[1, 3] = MRitem.TITLE_NAME;      // 제조사명
                ws.Cells[2, 3] = MRitem.PRD_DATE;       // 생산일자
                ws.Cells[3, 3] = MRitem.SPEC;           // 규격
                ws.Cells[4, 3] = MRitem.PRFM_WGT;       // 중량    
                ws.Cells[5, 3] = MRitem.HEIGHT;         // 길이;
                ws.Cells[6, 3] = MRitem.PCODE_NM;       // 지종
                ws.Cells[7, 3] = MRitem.BS_WGT;           // 평량
                ws.Cells[8, 3] = MRitem.WRK_NAME;       // 번/작업자
                ws.Cells[9, 3] = MRitem.LOT_NO;         // LOTNO
                ws.Cells[10, 3] = MRitem.IND_BCD;       // 개별바코드
                ws.Cells[11, 3] = sIND_BCD_BARCODE;     // 개별바코드(바코드)
                //ws.Cells[11, 3] = MRitem.IND_BCD;     // 개별바코드(바코드)

                if (nPrtCnt > 1)
                {
                    for (int i = 0; i < nPrtCnt; i++)
                    {
                        ws.PrintOutEx();
                    }
                }
                else
                {
                    ws.PrintOutEx();
                }
            }
            catch (Exception ex)
            {
                LogFile.WriteLog("REPORT.LAMI_PRINT Error => " + ex.Message);
            }
            finally
            {
                ReleaseExcelObject(ws);

                GC.Collect();
            }

        }

        private void ReleaseExcelObject(object obj)
        {
            try
            {
                if (obj != null)
                {
                    System.Runtime.InteropServices.Marshal.ReleaseComObject(obj);
                    obj = null;
                }
            }
            catch (Exception ex)
            {
                obj = null;
                throw ex;
            }
            finally
            {
                GC.Collect();
            }
        }
    }
}
