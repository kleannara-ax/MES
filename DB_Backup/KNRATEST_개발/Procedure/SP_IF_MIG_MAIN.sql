--------------------------------------------------------
--  DDL for Procedure SP_IF_MIG_MAIN
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_IF_MIG_MAIN" (
 i_IF_OPT           IN    VARCHAR2
,o_msg_CODE         OUT   VARCHAR2
,o_msg_MSG          OUT   VARCHAR2
) AS                                                                                     
/*==============================================================================
 * PROGRAM ID    : 마이그레이션
 * PROGRAM NAME  : PIS 초기재고 SETUP
 * VERSION       : 1.0.0
 * DESCRIPTION   : PIS 초기재고 SETUP
 *                 
 * AUTHOR NAME   : 강현주
 * CREATE DATE   : 2022/08/09
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}	<생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}		<생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}			<생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}	<생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/08/09    1.0.0   강현주         Initial Version 
 *==============================================================================
 * 관련 테이블
 * - [TN_BARCODE] : (.R..)바코드                                
 * - [TN_BARCODE_LOT_ACTRSLT] : (.R..)바코드_LOT별 실적
 * - [TN_JUMBOROLL] : (.R..)점보롤 실적
 * - [TN_MILLROLL] : (.R..)밀롤 실적
 * - [TN_SLITTER] : (.R..)밀롤슬리터 실적
 * - [TN_CUTTER] : (.R..)재단(커터) 실적
 * - [TN_PACKING] : (.R..)포장 실적
 * - [TN_IMPORTED_MR] : (.R..)수입밀롤 실적
 *=============================================================================*/
 
  V_CNT             NUMBER          := 0;             -- 카운트(존재여부체크) 
 
 
BEGIN

  -----------------------------------------------------------------------------------------------------------------------------
  --0.데이타 초기화 한다.
  -----------------------------------------------------------------------------------------------------------------------------

  execute immediate 'truncate table TB_MIG_LOG';
/*      
  execute immediate 'truncate table TN_BARCODE';
  execute immediate 'truncate table TN_BARCODE_LOT_ACTRSLT';
  execute immediate 'truncate table TN_JUMBOROLL';
  execute immediate 'truncate table TN_MILLROLL';
  execute immediate 'truncate table TN_SLITTER';
  execute immediate 'truncate table TN_CUTTER';
  execute immediate 'truncate table TN_PACKING';
*/ 
  
  --execute immediate 'truncate table TN_IMPORTED_MR';              
               

  -----------------------------------------------------------------------------------------------------------------------------
  --1.데이타 복사 한다.
  -----------------------------------------------------------------------------------------------------------------------------  
/*  
  --바코드 복사
  DBMS_OUTPUT.PUT_LINE('TN_BARCODE 복사==>START==>' || TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS'));
  SP_IF_MIG_LOG('SP_IF_MIG_MAIN','0','TN_BARCODE 복사==>START==>' || TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS'));
  COMMIT;
  
  INSERT INTO TN_BARCODE(  
     BARCODE
    ,PLNT_CD
    ,MCHN_CD
    ,PRCS_CD
    ,FCLT_CD
    ,LOC_GB_CD
    ,LOC_CD
    ,INPT_MCHN_CD
    ,INPT_PRCS_CD
    ,INPT_FCLT_CD
    ,INPT_USER_ID
    ,FCLT_INPT_DT
    ,WORK_DT
    ,CLASS
    ,CHND_LINE
    ,STATUS
    ,SCRAP_CD
    ,BEGIN_TIME
    ,END_TIME
    ,TOT_OPR_TIME
    ,ADD_TIME
    ,SPEED
    ,RUN_STATUS_CD
    ,ACTUAL_SEQ
    ,REJECT_CD
    ,CNFRM_NO
    ,CNFRM_NO_SEQ
    ,RMK1
    ,RMK2
    ,RMK3
    ,ERP_IF_SEQ
    ,LOG_SEQ
    ,CRAT_DATE
    ,CRAT_ID
    ,UPDT_DATE
    ,UPDT_ID
    ,ACTION_CD
    ,MAKE_DT
    ,PAPER_BT_PROD
    ,CORE_SIZE
    ,IS_ME_COMPLETE
    ,IS_UP_COMPLETE
    ,PP_ERR_CD
    ,PP_ERR_MSG
    ,LE_ERR_CD
    ,LE_ERR_MSG
    ,RMK4
    ,RMK5
    ,RMK6
    ,OVERWEIGHT 
    ,IF_STATUS   
  )
  SELECT 
     BARCODE
    ,PLNT_CD
    ,MCHN_CD
    ,PRCS_CD
    ,FCLT_CD
    ,LOC_GB_CD
    ,LOC_CD
    ,INPT_MCHN_CD
    ,INPT_PRCS_CD
    ,INPT_FCLT_CD
    ,INPT_USER_ID
    ,FCLT_INPT_DT
    ,WORK_DT
    ,CLASS
    ,CHND_LINE
    ,STATUS
    ,SCRAP_CD
    ,BEGIN_TIME
    ,END_TIME
    ,TOT_OPR_TIME
    ,ADD_TIME
    ,SPEED
    ,RUN_STATUS_CD
    ,ACTUAL_SEQ
    ,REJECT_CD
    ,CNFRM_NO
    ,CNFRM_NO_SEQ
    ,RMK1
    ,RMK2
    ,RMK3
    ,ERP_IF_SEQ
    ,LOG_SEQ
    ,CRAT_DATE
    ,CRAT_ID
    ,UPDT_DATE
    ,UPDT_ID
    ,ACTION_CD
    ,MAKE_DT
    ,PAPER_BT_PROD
    ,CORE_SIZE
    ,IS_ME_COMPLETE
    ,IS_UP_COMPLETE
    ,PP_ERR_CD
    ,PP_ERR_MSG
    ,LE_ERR_CD
    ,LE_ERR_MSG
    ,RMK4
    ,RMK5
    ,RMK6
    ,OVERWEIGHT 
    ,'N'     
  FROM TN_BARCODE@LNK_PIS
  WHERE WORK_DT BETWEEN TO_CHAR(SYSDATE-300,'YYYYMMDD')  AND TO_CHAR(SYSDATE,'YYYYMMDD')
  AND STATUS IN('0','1','2','3','4','6','7','9','B','C');  

         
  SP_IF_MIG_LOG('SP_IF_MIG_MAIN','0','TN_BARCODE 복사==>END==>' || TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS'));  
  DBMS_OUTPUT.PUT_LINE('TN_BARCODE 복사==>END==>' || TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS'));
  COMMIT;
  


  --바코드_LOT별 실적 복사 
  DBMS_OUTPUT.PUT_LINE('TN_BARCODE_LOT_ACTRSLT 복사==>START==>' || TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS'));
  SP_IF_MIG_LOG('SP_IF_MIG_MAIN','0','TN_BARCODE_LOT_ACTRSLT 복사==>START==>' || TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS'));
  COMMIT;
    
  INSERT INTO TN_BARCODE_LOT_ACTRSLT(  
     BARCODE
    ,LOT_ID
    ,ACTRSLT_M
    ,ACTRSLT_REAM
    ,ACTRSLT_NMBOFSHT
    ,ACTRSLT_KG
    ,ACTRSLT_SCRAP_M
    ,ACTRSLT_SCRAP_REAM
    ,ACTRSLT_SCRAP_KG
    ,LOG_SEQ
    ,CRAT_DATE
    ,CRAT_ID
    ,UPDT_DATE
    ,UPDT_ID
    ,CNFRM_NO
    ,CNFRM_NO_SEQ 
    ,IF_STATUS 
  )
  SELECT 
     K.BARCODE
    ,K.LOT_ID
    ,K.ACTRSLT_M
    ,K.ACTRSLT_REAM
    ,K.ACTRSLT_NMBOFSHT
    ,K.ACTRSLT_KG
    ,K.ACTRSLT_SCRAP_M
    ,K.ACTRSLT_SCRAP_REAM
    ,K.ACTRSLT_SCRAP_KG
    ,K.LOG_SEQ
    ,K.CRAT_DATE
    ,K.CRAT_ID
    ,K.UPDT_DATE
    ,K.UPDT_ID
    ,K.CNFRM_NO
    ,K.CNFRM_NO_SEQ 
    ,'N'     
  FROM TN_BARCODE_LOT_ACTRSLT@LNK_PIS K
  WHERE K.BARCODE IN (SELECT BARCODE FROM TN_BARCODE@LNK_PIS
                      WHERE WORK_DT BETWEEN TO_CHAR(SYSDATE-300,'YYYYMMDD') AND TO_CHAR(SYSDATE,'YYYYMMDD')
                      AND STATUS IN('0','1','2','3','4','6','7','9','B','C')
                      );  
       
  SP_IF_MIG_LOG('SP_IF_MIG_MAIN','0','TN_BARCODE_LOT_ACTRSLT 복사==>END==>' || TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS'));   
  DBMS_OUTPUT.PUT_LINE('TN_BARCODE_LOT_ACTRSLT 복사==>END==>' || TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS'));  
  COMMIT;  


  
  --점보롤 실적 복사 
  DBMS_OUTPUT.PUT_LINE('TN_JUMBOROLL 복사==>START==>' || TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS'));
  SP_IF_MIG_LOG('SP_IF_MIG_MAIN','0','TN_JUMBOROLL 복사==>START==>' || TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS'));
  COMMIT;
  
  INSERT INTO TN_JUMBOROLL(  
     LOT_ID
    ,PRDCTN_DT
    ,WRK_PRIORT
    ,PRDCTN_MCHN
    ,INPT_PRDCTN_MCHN
    ,MTRIL_NO
    ,PRDCTN_VER
    ,PAPER_CD
    ,PAPER_NM
    ,RELIMP
    ,PAPER_BT
    ,ACTRSLT_M
    ,PLAN_M
    ,TOT_ACTRSLT_KG
    ,TOT_PLAN_KG
    ,SCRAP_KG
    ,SCRAP_GB
    ,SALE_SCRAP_KG
    ,PRDCTN_SCRAP_KG
    ,ORMPM
    ,NEW_CTTR
    ,PRDCTN_LN_CD
    ,PRDCTN_LN_NM
    ,SHEET_YN
    ,WRKORD
    ,INPUT_YN
    ,CLOSED_YN
    ,WORK_DRCT
    ,ERP_IF_SEQ
    ,LOG_SEQ
    ,CRAT_DATE
    ,CRAT_ID
    ,UPDT_DATE
    ,UPDT_ID
    ,ACTION_CD
    ,PRCS_CD 
    ,IF_STATUS
  )
  SELECT 
     K.LOT_ID
    ,K.PRDCTN_DT
    ,K.WRK_PRIORT
    ,K.PRDCTN_MCHN
    ,K.INPT_PRDCTN_MCHN
    ,K.MTRIL_NO
    ,K.PRDCTN_VER
    ,K.PAPER_CD
    ,K.PAPER_NM
    ,K.RELIMP
    ,K.PAPER_BT
    ,K.ACTRSLT_M
    ,K.PLAN_M
    ,K.TOT_ACTRSLT_KG
    ,K.TOT_PLAN_KG
    ,K.SCRAP_KG
    ,K.SCRAP_GB
    ,K.SALE_SCRAP_KG
    ,K.PRDCTN_SCRAP_KG
    ,K.ORMPM
    ,K.NEW_CTTR
    ,K.PRDCTN_LN_CD
    ,K.PRDCTN_LN_NM
    ,K.SHEET_YN
    ,K.WRKORD
    ,K.INPUT_YN
    ,K.CLOSED_YN
    ,K.WORK_DRCT
    ,K.ERP_IF_SEQ
    ,K.LOG_SEQ
    ,K.CRAT_DATE
    ,K.CRAT_ID
    ,K.UPDT_DATE
    ,K.UPDT_ID
    ,K.ACTION_CD
    ,K.PRCS_CD   
    ,'N'  
  FROM TN_JUMBOROLL@LNK_PIS K
  WHERE K.PRDCTN_DT BETWEEN TO_CHAR(SYSDATE-300,'YYYYMMDD')  AND TO_CHAR(SYSDATE,'YYYYMMDD');   
        
  SP_IF_MIG_LOG('SP_IF_MIG_MAIN','0','TN_JUMBOROLL 복사==>END==>' || TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS'));   
  DBMS_OUTPUT.PUT_LINE('TN_JUMBOROLL COPY==>복사==>' || TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS'));    
  COMMIT;  
  
  
  
  --밀롤 실적 복사    
  DBMS_OUTPUT.PUT_LINE('TN_MILLROLL 복사==>START==>' || TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS'));
  SP_IF_MIG_LOG('SP_IF_MIG_MAIN','0','TN_MILLROLL 복사==>START==>' || TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS'));
  COMMIT;
    
  INSERT INTO TN_MILLROLL(  
     LOT_ID
    ,PRDCTN_DT
    ,JR_LOT_ID
    ,PRDCTN_ORD_NO
    ,PRDCTN_ORD_SEQ
    ,PRDCTN_MCHN
    ,INPT_PRDCTN_MCHN
    ,PRDCTN_VER
    ,MTRIL_NO
    ,PAPER_CD
    ,PAPER_NM
    ,RELIMP
    ,PAPER_BT
    ,PAPER_BT_REAL
    ,BT_CNT
    ,ACTRSLT_M
    ,PLAN_M
    ,TOT_ACTRSLT_KG
    ,TOT_PLAN_KG
    ,SCRAP_KG
    ,SALE_SCRAP_KG
    ,PRDCTN_SCRAP_KG
    ,CUT_SCRAP_REAM
    ,STD_SIZE
    ,WIDTH_LEN
    ,VRTICL_LEN
    ,WRKORD
    ,PRDCTN_LN_CD
    ,PRDCTN_LN_NM
    ,SHEET_YN
    ,SLTR_YN
    ,INPUT_YN
    ,CLOSED_YN
    ,SALES_DOC_NO
    ,SALES_DOC_NO_SEQ
    ,ZPP_COD
    ,CORE_SIZE
    ,CNTNR_TP
    ,CNTNR_TP_CNTNTS
    ,IMP_EXP_GB
    ,IMP_EXP_GB_CNTNTS
    ,VOYAGE
    ,PORT_CNTRY_KEY
    ,CNTRY_NM
    ,WORK_DRCT
    ,BCNC_CD
    ,BCNC_NM
    ,PACKING_TP_CD
    ,PACKING_TP_NM
    ,NMRS_IN_BUNDLE
    ,ERP_IF_SEQ
    ,LOG_SEQ
    ,CRAT_DATE
    ,CRAT_ID
    ,UPDT_DATE
    ,UPDT_ID
    ,ACTION_CD
    ,REAM_PER_PALLET
    ,NMBOFSHT_CNT
    ,BUNDLE_CNT
    ,PRCS_CD
    ,IF_STATUS
  )
  SELECT 
     K.LOT_ID
    ,K.PRDCTN_DT
    ,K.JR_LOT_ID
    ,K.PRDCTN_ORD_NO
    ,K.PRDCTN_ORD_SEQ
    ,K.PRDCTN_MCHN
    ,K.INPT_PRDCTN_MCHN
    ,K.PRDCTN_VER
    ,K.MTRIL_NO
    ,K.PAPER_CD
    ,K.PAPER_NM
    ,K.RELIMP
    ,K.PAPER_BT
    ,K.PAPER_BT_REAL
    ,K.BT_CNT
    ,K.ACTRSLT_M
    ,K.PLAN_M
    ,K.TOT_ACTRSLT_KG
    ,K.TOT_PLAN_KG
    ,K.SCRAP_KG
    ,K.SALE_SCRAP_KG
    ,K.PRDCTN_SCRAP_KG
    ,K.CUT_SCRAP_REAM
    ,K.STD_SIZE
    ,K.WIDTH_LEN
    ,K.VRTICL_LEN
    ,K.WRKORD
    ,K.PRDCTN_LN_CD
    ,K.PRDCTN_LN_NM
    ,K.SHEET_YN
    ,K.SLTR_YN
    ,K.INPUT_YN
    ,K.CLOSED_YN
    ,K.SALES_DOC_NO
    ,K.SALES_DOC_NO_SEQ
    ,K.ZPP_COD
    ,K.CORE_SIZE
    ,K.CNTNR_TP
    ,K.CNTNR_TP_CNTNTS
    ,K.IMP_EXP_GB
    ,K.IMP_EXP_GB_CNTNTS
    ,K.VOYAGE
    ,K.PORT_CNTRY_KEY
    ,K.CNTRY_NM
    ,K.WORK_DRCT
    ,K.BCNC_CD
    ,K.BCNC_NM
    ,K.PACKING_TP_CD
    ,K.PACKING_TP_NM
    ,K.NMRS_IN_BUNDLE
    ,K.ERP_IF_SEQ
    ,K.LOG_SEQ
    ,K.CRAT_DATE
    ,K.CRAT_ID
    ,K.UPDT_DATE
    ,K.UPDT_ID
    ,K.ACTION_CD
    ,K.REAM_PER_PALLET
    ,K.NMBOFSHT_CNT
    ,K.BUNDLE_CNT
    ,K.PRCS_CD 
    ,'N' 
  FROM TN_MILLROLL@LNK_PIS K
  WHERE K.PRDCTN_DT BETWEEN TO_CHAR(SYSDATE-300,'YYYYMMDD')  AND TO_CHAR(SYSDATE,'YYYYMMDD');

         
  SP_IF_MIG_LOG('SP_IF_MIG_MAIN','0','TN_MILLROLL 복사==>END==>' || TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS'));   
  DBMS_OUTPUT.PUT_LINE('TN_MILLROLL 복사==>END==>' || TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS'));    
  COMMIT;  
  
  
 
  --밀롤슬리터 실적 복사
  DBMS_OUTPUT.PUT_LINE('TN_SLITTER 복사==>START==>' || TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS'));
  SP_IF_MIG_LOG('SP_IF_MIG_MAIN','0','TN_SLITTER 복사==>START==>' || TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS'));
  COMMIT;
    
  INSERT INTO TN_SLITTER(  
     LOT_ID
    ,PRDCTN_DT
    ,MR_LOT_ID
    ,PRDCTN_ORD_NO
    ,PRDCTN_ORD_SEQ
    ,PRDCTN_MCHN
    ,INPT_PRDCTN_MCHN
    ,PRDCTN_VER
    ,MTRIL_NO
    ,PAPER_CD
    ,PAPER_NM
    ,RELIMP
    ,PAPER_BT
    ,PAPER_BT_REAL
    ,BT_CNT
    ,ACTRSLT_M
    ,PLAN_M
    ,TOT_ACTRSLT_KG
    ,TOT_PLAN_KG
    ,SCRAP_KG
    ,SALE_SCRAP_KG
    ,PRDCTN_SCRAP_KG
    ,CUT_SCRAP_REAM
    ,STD_SIZE
    ,WIDTH_LEN
    ,VRTICL_LEN
    ,WRKORD
    ,PRDCTN_LN_CD
    ,PRDCTN_LN_NM
    ,SHEET_YN
    ,SLTR_YN
    ,INPUT_YN
    ,CLOSED_YN
    ,SALES_DOC_NO
    ,SALES_DOC_NO_SEQ
    ,ZPP_COD
    ,CORE_SIZE
    ,CNTNR_TP
    ,CNTNR_TP_CNTNTS
    ,IMP_EXP_GB
    ,IMP_EXP_GB_CNTNTS
    ,VOYAGE
    ,PORT_CNTRY_KEY
    ,CNTRY_NM
    ,WORK_DRCT
    ,BCNC_CD
    ,BCNC_NM
    ,PACKING_TP_CD
    ,PACKING_TP_NM
    ,NMRS_IN_BUNDLE
    ,ERP_IF_SEQ
    ,LOG_SEQ
    ,CRAT_DATE
    ,CRAT_ID
    ,UPDT_DATE
    ,UPDT_ID
    ,ACTION_CD
    ,REAM_PER_PALLET
    ,NMBOFSHT_CNT
    ,BUNDLE_CNT
    ,PRCS_CD
    ,IF_STATUS
  )
  SELECT 
     K.LOT_ID
    ,K.PRDCTN_DT
    ,K.MR_LOT_ID
    ,K.PRDCTN_ORD_NO
    ,K.PRDCTN_ORD_SEQ
    ,K.PRDCTN_MCHN
    ,K.INPT_PRDCTN_MCHN
    ,K.PRDCTN_VER
    ,K.MTRIL_NO
    ,K.PAPER_CD
    ,K.PAPER_NM
    ,K.RELIMP
    ,K.PAPER_BT
    ,K.PAPER_BT_REAL
    ,K.BT_CNT
    ,K.ACTRSLT_M
    ,K.PLAN_M
    ,K.TOT_ACTRSLT_KG
    ,K.TOT_PLAN_KG
    ,K.SCRAP_KG
    ,K.SALE_SCRAP_KG
    ,K.PRDCTN_SCRAP_KG
    ,K.CUT_SCRAP_REAM
    ,K.STD_SIZE
    ,K.WIDTH_LEN
    ,K.VRTICL_LEN
    ,K.WRKORD
    ,K.PRDCTN_LN_CD
    ,K.PRDCTN_LN_NM
    ,K.SHEET_YN
    ,K.SLTR_YN
    ,K.INPUT_YN
    ,K.CLOSED_YN
    ,K.SALES_DOC_NO
    ,K.SALES_DOC_NO_SEQ
    ,K.ZPP_COD
    ,K.CORE_SIZE
    ,K.CNTNR_TP
    ,K.CNTNR_TP_CNTNTS
    ,K.IMP_EXP_GB
    ,K.IMP_EXP_GB_CNTNTS
    ,K.VOYAGE
    ,K.PORT_CNTRY_KEY
    ,K.CNTRY_NM
    ,K.WORK_DRCT
    ,K.BCNC_CD
    ,K.BCNC_NM
    ,K.PACKING_TP_CD
    ,K.PACKING_TP_NM
    ,K.NMRS_IN_BUNDLE
    ,K.ERP_IF_SEQ
    ,K.LOG_SEQ
    ,K.CRAT_DATE
    ,K.CRAT_ID
    ,K.UPDT_DATE
    ,K.UPDT_ID
    ,K.ACTION_CD
    ,K.REAM_PER_PALLET
    ,K.NMBOFSHT_CNT
    ,K.BUNDLE_CNT
    ,K.PRCS_CD
    ,'N'
  FROM TN_SLITTER@LNK_PIS K
  WHERE K.PRDCTN_DT BETWEEN TO_CHAR(SYSDATE-300,'YYYYMMDD')  AND TO_CHAR(SYSDATE,'YYYYMMDD');
        
  SP_IF_MIG_LOG('SP_IF_MIG_MAIN','0','TN_SLITTER 복사==>END==>' || TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS'));   
  DBMS_OUTPUT.PUT_LINE('TN_SLITTER 복사==>END==>' || TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS'));       
  COMMIT;


  
  --재단(커터) 실적 복사
  DBMS_OUTPUT.PUT_LINE('TN_CUTTER 복사==>START==>' || TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS'));
  SP_IF_MIG_LOG('SP_IF_MIG_MAIN','0','TN_CUTTER 복사==>START==>' || TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS'));
  COMMIT;
    
  INSERT INTO TN_CUTTER(  
     LOT_ID
    ,MR_LOT_ID
    ,JR_LOT_ID
    ,PRDCTN_DT
    ,PRDCTN_MCHN
    ,INPT_PRDCTN_MCHN
    ,PRDCTN_VER
    ,MTRIL_NO
    ,PAPER_CD
    ,PAPER_NM
    ,PLAN_QTY
    ,ACTRSLT_REAM
    ,TOT_ACTRSLT_KG
    ,PLAN_KG
    ,TOT_SCRAP_KG
    ,ORER_SCRAP_KG
    ,PACK_SCRAP_KG
    ,MR_CNT
    ,PAPER_BT
    ,RELIMP
    ,WIDTH_LEN
    ,VRTICL_LEN
    ,ORMPM
    ,NOPLAN_PRDCTN_YN
    ,INPUT_YN
    ,CLOSED_YN
    ,SALES_DOC_NO
    ,SALES_DOC_NO_SEQ
    ,WRKORD
    ,MR_MTRIL_NO
    ,CNTNR_TP
    ,CNTNR_TP_CNTNTS
    ,IMP_EXP_GB
    ,IMP_EXP_GB_CNTNTS
    ,VOYAGE
    ,PORT_CNTRY_KEY
    ,CNTRY_NM
    ,WORK_DRCT
    ,BCNC_CD
    ,BCNC_NM
    ,PACKING_TP_CD
    ,PACKING_TP_NM
    ,NMRS_IN_BUNDLE
    ,ERP_IF_SEQ
    ,LOG_SEQ
    ,CRAT_DATE
    ,CRAT_ID
    ,UPDT_DATE
    ,UPDT_ID
    ,ACTION_CD
    ,REAM_PER_PALLET
    ,STD_SIZE
    ,NMBOFSHT_CNT
    ,BUNDLE_CNT
    ,DBL_PLT_YN
    ,CUTTER
    ,PRCS_CD
    ,IF_STATUS
  )
  SELECT 
     K.LOT_ID
    ,K.MR_LOT_ID
    ,K.JR_LOT_ID
    ,K.PRDCTN_DT
    ,K.PRDCTN_MCHN
    ,K.INPT_PRDCTN_MCHN
    ,K.PRDCTN_VER
    ,K.MTRIL_NO
    ,K.PAPER_CD
    ,K.PAPER_NM
    ,K.PLAN_QTY
    ,K.ACTRSLT_REAM
    ,K.TOT_ACTRSLT_KG
    ,K.PLAN_KG
    ,K.TOT_SCRAP_KG
    ,K.ORER_SCRAP_KG
    ,K.PACK_SCRAP_KG
    ,K.MR_CNT
    ,K.PAPER_BT
    ,K.RELIMP
    ,K.WIDTH_LEN
    ,K.VRTICL_LEN
    ,K.ORMPM
    ,K.NOPLAN_PRDCTN_YN
    ,K.INPUT_YN
    ,K.CLOSED_YN
    ,K.SALES_DOC_NO
    ,K.SALES_DOC_NO_SEQ
    ,K.WRKORD
    ,K.MR_MTRIL_NO
    ,K.CNTNR_TP
    ,K.CNTNR_TP_CNTNTS
    ,K.IMP_EXP_GB
    ,K.IMP_EXP_GB_CNTNTS
    ,K.VOYAGE
    ,K.PORT_CNTRY_KEY
    ,K.CNTRY_NM
    ,K.WORK_DRCT
    ,K.BCNC_CD
    ,K.BCNC_NM
    ,K.PACKING_TP_CD
    ,K.PACKING_TP_NM
    ,K.NMRS_IN_BUNDLE
    ,K.ERP_IF_SEQ
    ,K.LOG_SEQ
    ,K.CRAT_DATE
    ,K.CRAT_ID
    ,K.UPDT_DATE
    ,K.UPDT_ID
    ,K.ACTION_CD
    ,K.REAM_PER_PALLET
    ,K.STD_SIZE
    ,K.NMBOFSHT_CNT
    ,K.BUNDLE_CNT
    ,K.DBL_PLT_YN
    ,K.CUTTER
    ,K.PRCS_CD
    ,'N'
  FROM TN_CUTTER@LNK_PIS K
  WHERE K.PRDCTN_DT BETWEEN TO_CHAR(SYSDATE-300,'YYYYMMDD')  AND TO_CHAR(SYSDATE,'YYYYMMDD');
        
  SP_IF_MIG_LOG('SP_IF_MIG_MAIN','0','TN_CUTTER 복사==>END==>' || TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS'));   
  DBMS_OUTPUT.PUT_LINE('TN_CUTTER 복사==>END==>' || TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS'));        
  COMMIT;


 
  --포장 실적 복사
  DBMS_OUTPUT.PUT_LINE('TN_PACKING 복사==>START==>' || TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS'));
  SP_IF_MIG_LOG('SP_IF_MIG_MAIN','0','TN_PACKING 복사==>START==>' || TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS'));
  COMMIT;
    
  INSERT INTO TN_PACKING(  
     LOT_ID
    ,PRDCTN_DT
    ,CUT_LOT_ID1
    ,CUT_LOT_ID2
    ,CUT_LOT_ID3
    ,CUT_LOT_ID4
    ,CUT_LOT_ID5
    ,ACTRSLT_REAM1
    ,ACTRSLT_REAM2
    ,ACTRSLT_REAM3
    ,ACTRSLT_REAM4
    ,ACTRSLT_REAM5
    ,TOT_ACTRSLT_REAM
    ,MR_LOT_ID
    ,JR_LOT_ID
    ,PRDCTN_MCHN
    ,INPT_PRDCTN_MCHN
    ,PAPER_CD
    ,PAPER_NM
    ,RELIMP
    ,WIDTH_LEN
    ,VRTICL_LEN
    ,TOT_KG
    ,NMBOFSHT_CNT
    ,BUNDLE_CNT
    ,PRDCTN_VER
    ,MTRIL_NO
    ,WRKORD
    ,DBL_PLT_YN
    ,PLT_CNT
    ,CNTAINR_TP
    ,PCKNG_TP
    ,CUSTOMER
    ,ZPP_COD
    ,INPUT_YN
    ,CLOSED_YN
    ,PCKNG_FCLT_CD
    ,PCKNG_FCLT_NM
    ,CNTNR_TP
    ,CNTNR_TP_CNTNTS
    ,IMP_EXP_GB
    ,IMP_EXP_GB_CNTNTS
    ,VOYAGE
    ,PORT_CNTRY_KEY
    ,CNTRY_NM
    ,WORK_DRCT
    ,BCNC_CD
    ,BCNC_NM
    ,PACKING_TP_CD
    ,PACKING_TP_NM
    ,NMRS_IN_BUNDLE
    ,ERP_IF_SEQ
    ,LOG_SEQ
    ,CRAT_DATE
    ,CRAT_ID
    ,UPDT_DATE
    ,UPDT_ID
    ,ACTION_CD
    ,REAM_PER_PALLET
    ,PRCS_CD
    ,IF_STATUS
  )
  SELECT 
     K.LOT_ID
    ,K.PRDCTN_DT
    ,K.CUT_LOT_ID1
    ,K.CUT_LOT_ID2
    ,K.CUT_LOT_ID3
    ,K.CUT_LOT_ID4
    ,K.CUT_LOT_ID5
    ,K.ACTRSLT_REAM1
    ,K.ACTRSLT_REAM2
    ,K.ACTRSLT_REAM3
    ,K.ACTRSLT_REAM4
    ,K.ACTRSLT_REAM5
    ,K.TOT_ACTRSLT_REAM
    ,K.MR_LOT_ID
    ,K.JR_LOT_ID
    ,K.PRDCTN_MCHN
    ,K.INPT_PRDCTN_MCHN
    ,K.PAPER_CD
    ,K.PAPER_NM
    ,K.RELIMP
    ,K.WIDTH_LEN
    ,K.VRTICL_LEN
    ,K.TOT_KG
    ,K.NMBOFSHT_CNT
    ,K.BUNDLE_CNT
    ,K.PRDCTN_VER
    ,K.MTRIL_NO
    ,K.WRKORD
    ,K.DBL_PLT_YN
    ,K.PLT_CNT
    ,K.CNTAINR_TP
    ,K.PCKNG_TP
    ,K.CUSTOMER
    ,K.ZPP_COD
    ,K.INPUT_YN
    ,K.CLOSED_YN
    ,K.PCKNG_FCLT_CD
    ,K.PCKNG_FCLT_NM
    ,K.CNTNR_TP
    ,K.CNTNR_TP_CNTNTS
    ,K.IMP_EXP_GB
    ,K.IMP_EXP_GB_CNTNTS
    ,K.VOYAGE
    ,K.PORT_CNTRY_KEY
    ,K.CNTRY_NM
    ,K.WORK_DRCT
    ,K.BCNC_CD
    ,K.BCNC_NM
    ,K.PACKING_TP_CD
    ,K.PACKING_TP_NM
    ,K.NMRS_IN_BUNDLE
    ,K.ERP_IF_SEQ
    ,K.LOG_SEQ
    ,K.CRAT_DATE
    ,K.CRAT_ID
    ,K.UPDT_DATE
    ,K.UPDT_ID
    ,K.ACTION_CD
    ,K.REAM_PER_PALLET
    ,K.PRCS_CD
    ,'N'
  FROM TN_PACKING@LNK_PIS K
  WHERE K.PRDCTN_DT BETWEEN TO_CHAR(SYSDATE-300,'YYYYMMDD')  AND TO_CHAR(SYSDATE,'YYYYMMDD');
  
       
  SP_IF_MIG_LOG('SP_IF_MIG_MAIN','0','TN_PACKING 복사==>END==>' || TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS'));    
  DBMS_OUTPUT.PUT_LINE('TN_PACKING 복사==>END==>' || TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS'));     
  COMMIT;

*/
  

  
  
   
  -----------------------------------------------------------------------------------------------------------------------------
  --2.데이타 이관 한다.
  -----------------------------------------------------------------------------------------------------------------------------
/*  
  --데이타이관후 정합성 조건체크하여 문제있으면 데이타이관 취소 한다.
  --2.1 로트병합건수 체크
  SELECT count(1) INTO V_CNT
  FROM (
    SELECT K.WORK_DT,K.BARCODE,(SELECT count(*) FROM TN_BARCODE_LOT_ACTRSLT WHERE BARCODE = K.BARCODE) CNT
    FROM TN_BARCODE K
    WHERE K.STATUS IN('0','1','2','3','4','6','7','B','C')
    AND WORK_DT BETWEEN TO_CHAR(SYSDATE-300,'YYYYMMDD')  AND TO_CHAR(SYSDATE,'YYYYMMDD')
    ) X
  WHERE X.CNT > 1;  
  
  IF V_CNT > 0 THEN
    SP_IF_MIG_LOG('SP_IF_MIG_MAIN','0','정합성체크==>로트병합건수발견==>' || TO_CHAR(V_CNT,'999,990') || '=>'  || TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS'));  
    COMMIT;  
    
    o_msg_code      := '-1' ;
    o_msg_msg       := 'Error: 정합성체크==>로트병합건수발견==>' || TO_CHAR(V_CNT,'999,990') || '=>' || to_char(SQLCODE) || ',' || SQLERRM ;
    DBMS_OUTPUT.PUT_LINE(o_msg_msg);
    rollback ; 
        
    RETURN;
  END IF;
  
  --2.2 품목존재하지 않는것 체크
  SELECT count(1) INTO V_CNT
  FROM(
    SELECT '점보롤' AS JM
          ,K.WERKS
          ,K.BARCODE
          ,K.LOT_ID
          ,K.MATNR
          ,K.MATNR_NM
    FROM (
      SELECT BAR.PLNT_CD    AS WERKS
            ,BAR.BARCODE    AS BARCODE
            ,SIL.LOT_ID     AS LOT_ID
            ,SIL.MTRIL_NO   AS MATNR
            ,(SELECT MATNR_NM FROM TB_MAS001 WHERE WERKS = BAR.PLNT_CD AND MATNR = SIL.MTRIL_NO) MATNR_NM
      FROM TN_BARCODE BAR
          ,TN_BARCODE_LOT_ACTRSLT BARLOT
          ,TN_JUMBOROLL SIL
      WHERE BAR.BARCODE = BARLOT.BARCODE
      AND   BARLOT.LOT_ID = SIL.LOT_ID
      AND   BAR.STATUS IN('0','1','2','3','4','6','7','B','C')
      AND   BAR.WORK_DT BETWEEN TO_CHAR(SYSDATE-300,'YYYYMMDD')  AND TO_CHAR(SYSDATE,'YYYYMMDD')
    ) K 
    WHERE MATNR_NM IS NULL
    UNION
    SELECT '밀롤' AS JM
          ,K.WERKS
          ,K.BARCODE
          ,K.LOT_ID
          ,K.MATNR
          ,K.MATNR_NM
    FROM (
      SELECT BAR.PLNT_CD    AS WERKS
            ,BAR.BARCODE    AS BARCODE
            ,SIL.LOT_ID     AS LOT_ID
            ,SIL.MTRIL_NO   AS MATNR
            ,(SELECT MATNR_NM FROM TB_MAS001 WHERE WERKS = BAR.PLNT_CD AND MATNR = SIL.MTRIL_NO) MATNR_NM
      FROM TN_BARCODE BAR
          ,TN_BARCODE_LOT_ACTRSLT BARLOT
          ,TN_MILLROLL SIL
      WHERE BAR.BARCODE = BARLOT.BARCODE
      AND   BARLOT.LOT_ID = SIL.LOT_ID
      AND   BAR.STATUS IN('0','1','2','3','4','6','7','B','C')
      AND   BAR.WORK_DT BETWEEN TO_CHAR(SYSDATE-300,'YYYYMMDD')  AND TO_CHAR(SYSDATE,'YYYYMMDD')
    ) K 
    WHERE MATNR_NM IS NULL
    UNION
    SELECT '슬리터' AS JM
          ,K.WERKS
          ,K.BARCODE
          ,K.LOT_ID
          ,K.MATNR
          ,K.MATNR_NM
    FROM (
      SELECT BAR.PLNT_CD    AS WERKS
            ,BAR.BARCODE    AS BARCODE
            ,SIL.LOT_ID     AS LOT_ID
            ,SIL.MTRIL_NO   AS MATNR
            ,(SELECT MATNR_NM FROM TB_MAS001 WHERE WERKS = BAR.PLNT_CD AND MATNR = SIL.MTRIL_NO) MATNR_NM
      FROM TN_BARCODE BAR
          ,TN_BARCODE_LOT_ACTRSLT BARLOT
          ,TN_SLITTER SIL
      WHERE BAR.BARCODE = BARLOT.BARCODE
      AND   BARLOT.LOT_ID = SIL.LOT_ID
      AND   BAR.STATUS IN('0','1','2','3','4','6','7','B','C')
      AND   BAR.WORK_DT BETWEEN TO_CHAR(SYSDATE-300,'YYYYMMDD')  AND TO_CHAR(SYSDATE,'YYYYMMDD')
    ) K 
    WHERE MATNR_NM IS NULL
    UNION
    SELECT '재단(커터)' AS JM
          ,K.WERKS
          ,K.BARCODE
          ,K.LOT_ID
          ,K.MATNR
          ,K.MATNR_NM
    FROM (
      SELECT BAR.PLNT_CD    AS WERKS
            ,BAR.BARCODE    AS BARCODE
            ,SIL.LOT_ID     AS LOT_ID
            ,SIL.MTRIL_NO   AS MATNR
            ,(SELECT MATNR_NM FROM TB_MAS001 WHERE WERKS = BAR.PLNT_CD AND MATNR = SIL.MTRIL_NO) MATNR_NM
      FROM TN_BARCODE BAR
          ,TN_BARCODE_LOT_ACTRSLT BARLOT
          ,TN_CUTTER SIL
      WHERE BAR.BARCODE = BARLOT.BARCODE
      AND   BARLOT.LOT_ID = SIL.LOT_ID
      AND   BAR.STATUS IN('0','1','2','3','4','6','7','B','C')
      AND   BAR.WORK_DT BETWEEN TO_CHAR(SYSDATE-300,'YYYYMMDD')  AND TO_CHAR(SYSDATE,'YYYYMMDD')
    ) K 
    WHERE MATNR_NM IS NULL
    UNION
    SELECT '포장' AS JM
          ,K.WERKS
          ,K.BARCODE
          ,K.LOT_ID
          ,K.MATNR
          ,K.MATNR_NM
    FROM (
      SELECT BAR.PLNT_CD    AS WERKS
            ,BAR.BARCODE    AS BARCODE
            ,SIL.LOT_ID     AS LOT_ID
            ,SIL.MTRIL_NO   AS MATNR
            ,(SELECT MATNR_NM FROM TB_MAS001 WHERE WERKS = BAR.PLNT_CD AND MATNR = SIL.MTRIL_NO) MATNR_NM
      FROM TN_BARCODE BAR
          ,TN_BARCODE_LOT_ACTRSLT BARLOT
          ,TN_PACKING SIL
      WHERE BAR.BARCODE = BARLOT.BARCODE
      AND   BARLOT.LOT_ID = SIL.LOT_ID
      AND   BAR.STATUS IN('0','1','2','3','4','6','7','B','C')
      AND   BAR.WORK_DT BETWEEN TO_CHAR(SYSDATE-300,'YYYYMMDD')  AND TO_CHAR(SYSDATE,'YYYYMMDD')
    ) K 
    WHERE MATNR_NM IS NULL
  )X;    
  
  IF V_CNT > 0 THEN
    SP_IF_MIG_LOG('SP_IF_MIG_MAIN','0','정합성체크==>자재마스타부재건수발견==>' || TO_CHAR(V_CNT,'999,990') || '=>'  || TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS'));  
    COMMIT;
    
    o_msg_code      := '-1' ;
    o_msg_msg       := 'Error: 정합성체크==>자재마스타부재건수발견==>' || TO_CHAR(V_CNT,'999,990') || '=>' || to_char(SQLCODE) || ',' || SQLERRM ;
    DBMS_OUTPUT.PUT_LINE(o_msg_msg);
    rollback ;      
    
    RETURN;
  END IF;  
 */ 
  --***************************************************************************************************************************
  
  
  
  
  
  
  --점보롤 재고 처리 
  DBMS_OUTPUT.PUT_LINE('JUMBOROLL 이관==>START==>' || TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS'));
  SP_IF_MIG_LOG('SP_IF_MIG_MAIN','0','JUMBOROLL 이관==>START==>' || TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS'));  
  COMMIT;
    
  SP_IF_MIG_JUMBOROLL(
     i_CMDKY        => 'SP_MIG_JUMBOROLL'                       	                 
    ,o_msg_CODE     => o_msg_CODE
    ,o_msg_MSG      => o_msg_MSG    
  );
  
  DBMS_OUTPUT.PUT_LINE('JUMBOROLL 이관==>END==>' || TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS'));
  SP_IF_MIG_LOG('SP_IF_MIG_MAIN','0','JUMBOROLL 이관==>END==>' || TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS'));
  COMMIT;  


  --밀롤 재고 처리 
  DBMS_OUTPUT.PUT_LINE('MILLROLL 이관==>START==>' || TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS'));
  SP_IF_MIG_LOG('SP_IF_MIG_MAIN','0','MILLROLL 이관==>START==>' || TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS'));  
  COMMIT;
    
  SP_IF_MIG_MILLROLL(
     i_CMDKY        => 'SP_MIG_MILLROLL'                       	                 
    ,o_msg_CODE     => o_msg_CODE
    ,o_msg_MSG      => o_msg_MSG    
  );   

  DBMS_OUTPUT.PUT_LINE('MILLROLL 이관==>END==>' || TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS'));
  SP_IF_MIG_LOG('SP_IF_MIG_MAIN','0','MILLROLL 이관==>END==>' || TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS'));
  COMMIT;  
 


  --밀롤슬리터 재고 처리
  DBMS_OUTPUT.PUT_LINE('SLITTER 이관==>START==>' || TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS'));
  SP_IF_MIG_LOG('SP_IF_MIG_MAIN','0','SLITTER 이관==>START==>' || TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS'));  
  COMMIT;
    
  SP_IF_MIG_SLITTER(
     i_CMDKY        => 'SP_MIG_SLITTER'                       	                 
    ,o_msg_CODE     => o_msg_CODE
    ,o_msg_MSG      => o_msg_MSG    
  );     
  
  DBMS_OUTPUT.PUT_LINE('SLITTER 이관==>END==>' || TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS'));
  SP_IF_MIG_LOG('SP_IF_MIG_MAIN','0','SLITTER 이관==>END==>' || TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS'));
  COMMIT;    
  

  --재단(커터) 재고 처리
  DBMS_OUTPUT.PUT_LINE('CUTTER 이관==>START==>' || TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS'));
  SP_IF_MIG_LOG('SP_IF_MIG_MAIN','0','CUTTER 이관==>START==>' || TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS'));  
  COMMIT;
    
  SP_IF_MIG_CUTTER(
     i_CMDKY        => 'SP_MIG_CUTTER'                       	                 
    ,o_msg_CODE     => o_msg_CODE
    ,o_msg_MSG      => o_msg_MSG    
  );
  
  DBMS_OUTPUT.PUT_LINE('CUTTER 이관==>END==>' || TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS'));
  SP_IF_MIG_LOG('SP_IF_MIG_MAIN','0','CUTTER 이관==>END==>' || TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS'));
  COMMIT;   
           
  --포장 재고 처리 
  DBMS_OUTPUT.PUT_LINE('PACKING 이관==>START==>' || TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS'));
  SP_IF_MIG_LOG('SP_IF_MIG_MAIN','0','PACKING 이관==>START==>' || TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS'));  
  COMMIT;
     
  SP_IF_MIG_PACKING(
     i_CMDKY        => 'SP_MIG_PACKING'                       	                 
    ,o_msg_CODE     => o_msg_CODE
    ,o_msg_MSG      => o_msg_MSG    
  );
  
  DBMS_OUTPUT.PUT_LINE('PACKING 이관==>END==>' || TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS'));
  SP_IF_MIG_LOG('SP_IF_MIG_MAIN','0','PACKING 이관==>END==>' || TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS'));
  COMMIT;  
    



  o_msg_code      := '0' ;
  o_msg_msg       := '정상처리 되었습니다.';
  COMMIT;
       
 EXCEPTION
    WHEN OTHERS THEN
      o_msg_code      := '-1' ;
      o_msg_msg       := 'Error: PIS Migration MAIN에서 오류가 발생하였습니다.' || ',' || to_char(SQLCODE) || ',' || SQLERRM ;
      DBMS_OUTPUT.PUT_LINE(o_msg_msg);
      rollback ;

END;

/
