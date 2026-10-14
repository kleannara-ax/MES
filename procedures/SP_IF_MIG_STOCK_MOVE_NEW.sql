
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_IF_MIG_STOCK_MOVE_NEW" (
 i_WERKS            IN    VARCHAR2
,o_msg_CODE         OUT   VARCHAR2
,o_msg_MSG          OUT   VARCHAR2
) AS                                                                                     
/*==============================================================================
 * PROGRAM ID    : 마이그레이션
 * PROGRAM NAME  : 개발서버의 PIS 초기재고 -> 운영서버의 PIS원본 데이터로 생성
 * VERSION       : 1.0.0
 * DESCRIPTION   : PIS 초기재고 SETUP
 *                 
 * AUTHOR NAME   : 강현주
 * CREATE DATE   : 2022/09/21
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}	<생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}		<생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}			<생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}	<생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/09/21  1.0.0   강현주         Initial Version 
 *==============================================================================
 * 관련 테이블
 * - [TX_MES_MIG_BARCODE_1] : (.I..)PIS원본_재고데이타 생성        
 * - [TX_MES_MIG_BARCODE_2500] : (.I..)PIS원본_밀롤데이타 생성                         
 * - [TX_MES_MIG_BARCODE_U] : (.I..)PIS원본_재고병합데이타 생성
 * - [TX_PIS_INIT] : (.I..)PIS초기데이타 생성
 *=============================================================================*/
 
  V_CNT             NUMBER          := 0;             -- 카운트(존재여부체크) 
 
/*
  CURSOR  CUR_DATA IS 
    SELECT K.*                     
    FROM TX_MES_MIG_BARCODE_1 K
    WHERE K.LOTA11 BETWEEN TO_CHAR(sysdate-300,'YYYYMMDD') AND TO_CHAR(sysdate,'YYYYMMDD')
    AND   K.STATUS IN('0','1','2','3','4','6','7','B','C')
    AND  (K.LOTA15,K.LOTA14) NOT IN(SELECT LOTA15,LOTA14
                                    FROM TX_MES_MIG_BARCODE_U
                                    WHERE LOTA15 = K.LOTA15
                                    AND   LOTA14 = K.LOTA14)
    AND  (K.LOTA15,K.LOTA14) NOT IN(SELECT LOTA15,LOTA14
                                    FROM TX_MES_MIG_BARCODE_2500
                                    WHERE LOTA15 = K.LOTA15
                                    AND   LOTA14 = K.LOTA14)
    AND  (K.LOTA15,K.LOTA14) NOT IN(SELECT LOTA15,LOTA14
                                    FROM TX_MES_MIG_BARCODE_2700
                                    WHERE LOTA15 = K.LOTA15
                                    AND   LOTA14 = K.LOTA14)                                    
    AND   K.LOTA14 IN(SELECT LOTA14 
                       FROM TX_MES_MIG_BARCODE_1
                       GROUP BY LOTA14
                       HAVING count(1) > 1)                                                                
    AND K.PRCS_CD <> 'J'
    ORDER BY LOTA14,SEQNUM;
*/
  CURSOR  CUR_DATA IS 
    SELECT K.*                   
    FROM TX_MES_MIG_BARCODE_1 K
    WHERE K.LOTA11 BETWEEN TO_CHAR(sysdate-300,'YYYYMMDD') AND TO_CHAR(sysdate,'YYYYMMDD')
    AND   K.STATUS IN('0','1','2','3','4','6','7','B','C')                                                                                                  
    AND   K.PRCS_CD = 'T'
    AND  (SELECT count(1) FROM TX_MES_MIG_BARCODE_1 WHERE LOTA14 = K.LOTA14) > 1;
 
BEGIN

  -----------------------------------------------------------------------------------------------------------------------------
  --1.개발PIS정보->운영PIS원본으로 데이타 옮긴다.
  -----------------------------------------------------------------------------------------------------------------------------
  --        
  INSERT INTO TX_MES_MIG_BARCODE_1
  SELECT * FROM T_MES_MIG_BARCODE_1;

  DBMS_OUTPUT.PUT_LINE('TX_MES_MIG_BARCODE_1==>완료==>' || TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS'));
  SP_IF_MIG_LOG('SP_IF_MIG_STOCK_MOVE_NEW','0','TX_MES_MIG_BARCODE_1==>완료==>' || TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS'));
  COMMIT; 

  --    
  INSERT INTO TX_MES_MIG_BARCODE_U
  SELECT * FROM T_MES_MIG_BARCODE_U;
  
  DBMS_OUTPUT.PUT_LINE('TX_MES_MIG_BARCODE_U==>완료==>' || TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS'));
  SP_IF_MIG_LOG('SP_IF_MIG_STOCK_MOVE_NEW','0','TX_MES_MIG_BARCODE_U==>완료==>' || TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS'));
  COMMIT;  
  
  --    
  INSERT INTO TX_MES_MIG_BARCODE_2500
  SELECT * FROM T_MES_MIG_BARCODE_2500;
  
  DBMS_OUTPUT.PUT_LINE('TX_MES_MIG_BARCODE_2500==>완료==>' || TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS'));
  SP_IF_MIG_LOG('SP_IF_MIG_STOCK_MOVE_NEW','0','TX_MES_MIG_BARCODE_2500==>완료==>' || TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS'));
  COMMIT;  
  
    --    
  INSERT INTO TX_MES_MIG_BARCODE_2700
  SELECT * FROM T_MES_MIG_BARCODE_2700;
  
  DBMS_OUTPUT.PUT_LINE('TX_MES_MIG_BARCODE_2700==>완료==>' || TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS'));
  SP_IF_MIG_LOG('SP_IF_MIG_STOCK_MOVE_NEW','0','TX_MES_MIG_BARCODE_2700==>완료==>' || TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS'));
  COMMIT;  
 
    
  -----------------------------------------------------------------------------------------------------------------------------
  --2.운영 PIS원본_재고데아타 -> 운영 PIS초기데이타 생성 한다.
  --공정 J M S C T P    
  -----------------------------------------------------------------------------------------------------------------------------    
  --투입된 개별바코드는 제외하여 구성됨.(최종...)
  INSERT INTO TX_PIS_INIT(
     MACH_CD
    ,MATNR
    ,LOT_NO
    ,IND_BCD
    ,ORDER_NO
    ,MACHINE
    ,PROC_CD
    ,PRD_DT
    ,PCODE
    ,UNIT
    ,ROLLCNT
    ,PCNT
    ,SCNT
    ,MCNT
    ,WGT
    ,CORE
    ,BS_WGT
    ,PACKTYPE
    ,CONTYPE
    ,WLEN
    ,VLEN
    ,WIDTH
    ,VBELN
    ,POSNR
    ,KUNNR
    ,MRG_YN
    ,WRK_CLASS
    ,WRK_SHIFT
    ,STATUS
    ,PRFM_DT
    ,WERKS
    ,STK_FLAG
    ,STOR_LOC_CD
    ,LOC_CD
  ) --아래는 밀롤창고
  SELECT
     K.FCLT_CD        AS MACH_CD
    ,K.SKUKEY         AS MATNR
    ,K.LOTA15         AS LOT_NO
    ,K.LOTA14         AS IND_BCD
    ,K.AUFNR          AS ORDER_NO
    ,K.LOTA04         AS MACHINE
    ,K.PRCS_CD        AS PROC_CD
    ,K.LOTA11         AS PRD_DT
    ,K.PAPER_CD       AS PCODE 
    ,CASE WHEN K.PRCS_CD = 'C' THEN 'R'
          WHEN K.PRCS_CD = 'T' THEN 'R'             
          WHEN K.PRCS_CD = 'P' THEN 'R'
          ELSE 'KG'       
     END              AS UNIT
    ,K.QTYRCV_M       AS ROLLCNT
    ,K.QTYRCV_R       AS PCNT
    ,K.BUNDLE_CNT     AS SCNT
    ,K.NMRS_IN_BUNDLE AS MCNT 
    ,K.QTYRCV_KG      AS WGT 
    ,K.LOTA21         AS CORE
    ,K.LOTA16         AS BS_WGT
    ,K.LOTA03         AS PACKTYPE
    ,K.LOTA17         AS CONTYPE
    ,K.WIDTH_LEN      AS WLEN
    ,K.VRTICL_LEN     AS VLEN 
    ,CASE WHEN INSTR(K.PAPER_BT_PROD,'-') > 0 THEN '0' 
          ELSE K.PAPER_BT_PROD
     END              AS WIDTH 
    ,K.LOTA07         AS VBELN
    ,K.LOTA07_SEQ     AS POSNR
    ,K.CUST_CD        AS KUNNR
    ,''                AS MRG_YN
    ,K.CLS            AS WRK_CLASS
    ,''                AS WRK_SHIFT
    ,K.STATUS         AS STATUS
    ,K.LOTA11         AS PRFM_DT
    ,'P100'             AS WERKS
    ,CASE WHEN K.FCLT_CD = 'FCTEMP' THEN 'PS_WH_IN'
          ELSE 'PS_WH'
     END              AS STK_FLAG     
    ,'2500'             AS STOR_LOC_CD
    ,''                  AS LOC_CD
  FROM TX_MES_MIG_BARCODE_1 K
  WHERE K.LOTA11 BETWEEN TO_CHAR(sysdate-300,'YYYYMMDD') AND TO_CHAR(sysdate,'YYYYMMDD')
  AND   K.STATUS IN('0','1','2','3','4','6','7','B','C')
  AND  (K.LOTA15,K.LOTA14) NOT IN(SELECT LOTA15,LOTA14
                                  FROM TX_MES_MIG_BARCODE_U
                                  WHERE LOTA15 = K.LOTA15
                                  AND   LOTA14 = K.LOTA14)
  AND  (K.LOTA15,K.LOTA14) IN(SELECT LOTA15,LOTA14
                              FROM TX_MES_MIG_BARCODE_2500
                              WHERE LOTA15 = K.LOTA15
                              AND   LOTA14 = K.LOTA14)                                
  AND K.PRCS_CD <> 'J'                                   
  UNION --아래는 점보롤
  SELECT
     K.FCLT_CD        AS MACH_CD
    ,K.SKUKEY         AS MATNR
    ,K.LOTA15         AS LOT_NO
    ,K.LOTA14         AS IND_BCD
    ,K.LOTA15         AS ORDER_NO
    ,K.LOTA04         AS MACHINE
    ,K.PRCS_CD        AS PROC_CD
    ,K.LOTA11         AS PRD_DT
    ,K.PAPER_CD       AS PCODE 
    ,CASE WHEN K.PRCS_CD = 'C' THEN 'R'
          WHEN K.PRCS_CD = 'T' THEN 'R'             
          WHEN K.PRCS_CD = 'P' THEN 'R'
          ELSE 'KG'       
     END              AS UNIT
    ,K.QTYRCV_M       AS ROLLCNT
    ,K.QTYRCV_R       AS PCNT
    ,K.BUNDLE_CNT     AS SCNT
    ,K.NMRS_IN_BUNDLE AS MCNT 
    ,K.QTYRCV_KG      AS WGT 
    ,K.LOTA21         AS CORE
    ,K.LOTA16         AS BS_WGT
    ,K.LOTA03         AS PACKTYPE
    ,K.LOTA17         AS CONTYPE
    ,K.WIDTH_LEN      AS WLEN
    ,K.VRTICL_LEN     AS VLEN 
    ,CASE WHEN INSTR(K.PAPER_BT_PROD,'-') > 0 THEN '0' 
          ELSE K.PAPER_BT_PROD
     END              AS WIDTH 
    ,K.LOTA07         AS VBELN
    ,K.LOTA07_SEQ     AS POSNR
    ,K.CUST_CD        AS KUNNR
    ,(SELECT 'Y' FROM TX_MES_MIG_BARCODE_U WHERE ULOT15 = K.LOTA15 AND ULOT14 = K.LOTA14 AND ROWNUM = 1) AS MRG_YN
    ,K.CLS            AS WRK_CLASS
    ,''                AS WRK_SHIFT
    ,K.STATUS         AS STATUS
    ,K.LOTA11         AS PRFM_DT
    ,'P100'             AS WERKS
    ,'PS_JR'             AS STK_FLAG 
    ,'2000'             AS STOR_LOC_CD
    ,''                  AS LOC_CD    
  FROM TX_MES_MIG_BARCODE_1 K
  WHERE K.LOTA11 BETWEEN TO_CHAR(sysdate-300,'YYYYMMDD') AND TO_CHAR(sysdate,'YYYYMMDD')
  AND   K.STATUS IN('0','1','2','3','4','6','7','B','C')
  AND  (K.LOTA15,K.LOTA14) NOT IN(SELECT LOTA15,LOTA14
                                  FROM TX_MES_MIG_BARCODE_U
                                  WHERE LOTA15 = K.LOTA15
                                  AND   LOTA14 = K.LOTA14)
  AND K.PRCS_CD = 'J'                                  
  UNION --아래는 ETC(T바코드는 제외하고 아래에서 별도로 수행함.)
  SELECT
     K.FCLT_CD        AS MACH_CD
    ,K.SKUKEY         AS MATNR
    ,K.LOTA15         AS LOT_NO
    ,K.LOTA14         AS IND_BCD
    ,K.AUFNR          AS ORDER_NO
    ,K.LOTA04         AS MACHINE
    ,K.PRCS_CD        AS PROC_CD
    ,K.LOTA11         AS PRD_DT
    ,K.PAPER_CD       AS PCODE 
    ,CASE WHEN K.PRCS_CD = 'C' THEN 'R'
          WHEN K.PRCS_CD = 'T' THEN 'R'             
          WHEN K.PRCS_CD = 'P' THEN 'R'
          ELSE 'KG'       
     END              AS UNIT
    ,K.QTYRCV_M       AS ROLLCNT
    ,K.QTYRCV_R       AS PCNT
    ,K.BUNDLE_CNT     AS SCNT
    ,K.NMRS_IN_BUNDLE AS MCNT 
    ,K.QTYRCV_KG      AS WGT 
    ,K.LOTA21         AS CORE
    ,K.LOTA16         AS BS_WGT
    ,K.LOTA03         AS PACKTYPE
    ,K.LOTA17         AS CONTYPE
    ,K.WIDTH_LEN      AS WLEN
    ,K.VRTICL_LEN     AS VLEN 
    ,CASE WHEN INSTR(K.PAPER_BT_PROD,'-') > 0 THEN '0' 
          ELSE K.PAPER_BT_PROD
     END              AS WIDTH 
    ,K.LOTA07         AS VBELN
    ,K.LOTA07_SEQ     AS POSNR
    ,K.CUST_CD        AS KUNNR
    ,(SELECT 'Y' FROM TX_MES_MIG_BARCODE_U WHERE ULOT15 = K.LOTA15 AND ULOT14 = K.LOTA14 AND ROWNUM = 1) AS MRG_YN
    ,K.CLS            AS WRK_CLASS
    ,''                AS WRK_SHIFT
    ,K.STATUS         AS STATUS
    ,K.LOTA11         AS PRFM_DT
    ,'P100'             AS WERKS
    ,'PS_ETC'            AS STK_FLAG 
    ,'2000'             AS STOR_LOC_CD
    ,''                  AS LOC_CD     
  FROM TX_MES_MIG_BARCODE_1 K
  WHERE K.LOTA11 BETWEEN TO_CHAR(sysdate-300,'YYYYMMDD') AND TO_CHAR(sysdate,'YYYYMMDD')
  AND   K.STATUS IN('0','1','2','3','4','6','7','B','C')
  AND  (K.LOTA15,K.LOTA14) NOT IN(SELECT LOTA15,LOTA14
                                  FROM TX_MES_MIG_BARCODE_U
                                  WHERE LOTA15 = K.LOTA15
                                  AND   LOTA14 = K.LOTA14)
  AND  (K.LOTA15,K.LOTA14) NOT IN(SELECT LOTA15,LOTA14
                                  FROM TX_MES_MIG_BARCODE_2500
                                  WHERE LOTA15 = K.LOTA15
                                  AND   LOTA14 = K.LOTA14) 
  AND  (K.LOTA15,K.LOTA14) NOT IN(SELECT LOTA15,LOTA14
                                  FROM TX_MES_MIG_BARCODE_2700
                                  WHERE LOTA15 = K.LOTA15
                                  AND   LOTA14 = K.LOTA14)                                                                  
  AND   K.PRCS_CD <> 'J'
  AND   K.LOTA14 NOT IN(SELECT LOTA14 
                        FROM TX_MES_MIG_BARCODE_1
                        GROUP BY LOTA14
                        HAVING count(1) > 1)
  UNION --아래는 재단
  SELECT
     K.FCLT_CD        AS MACH_CD
    ,K.SKUKEY         AS MATNR
    ,K.LOTA15         AS LOT_NO
    ,K.LOTA14         AS IND_BCD
    ,K.AUFNR          AS ORDER_NO
    ,K.LOTA04         AS MACHINE
    ,K.PRCS_CD        AS PROC_CD
    ,K.LOTA11         AS PRD_DT
    ,K.PAPER_CD       AS PCODE 
    ,CASE WHEN K.PRCS_CD = 'C' THEN 'R'
          WHEN K.PRCS_CD = 'T' THEN 'R'             
          WHEN K.PRCS_CD = 'P' THEN 'R'
          ELSE 'KG'       
     END              AS UNIT
    ,K.QTYRCV_M       AS ROLLCNT
    ,K.QTYRCV_R       AS PCNT
    ,K.BUNDLE_CNT     AS SCNT
    ,K.NMRS_IN_BUNDLE AS MCNT 
    ,K.QTYRCV_KG      AS WGT 
    ,K.LOTA21         AS CORE
    ,K.LOTA16         AS BS_WGT
    ,K.LOTA03         AS PACKTYPE
    ,K.LOTA17         AS CONTYPE
    ,K.WIDTH_LEN      AS WLEN
    ,K.VRTICL_LEN     AS VLEN 
    ,CASE WHEN INSTR(K.PAPER_BT_PROD,'-') > 0 THEN '0' 
          ELSE K.PAPER_BT_PROD
     END              AS WIDTH 
    ,K.LOTA07         AS VBELN
    ,K.LOTA07_SEQ     AS POSNR
    ,K.CUST_CD        AS KUNNR
    ,(SELECT 'Y' FROM TX_MES_MIG_BARCODE_U WHERE ULOT15 = K.LOTA15 AND ULOT14 = K.LOTA14 AND ROWNUM = 1) AS MRG_YN
    ,K.CLS            AS WRK_CLASS
    ,''                AS WRK_SHIFT
    ,K.STATUS         AS STATUS
    ,K.LOTA11         AS PRFM_DT
    ,'P100'             AS WERKS
    ,'PS_JD'             AS STK_FLAG     
    ,'2700'             AS STOR_LOC_CD
    ,(SELECT LOC_CD FROM TX_MES_MIG_BARCODE_2700 WHERE LOTA15 = K.LOTA15 AND LOTA14 = K.LOTA14 AND ROWNUM = 1) AS LOC_CD
  FROM TX_MES_MIG_BARCODE_1 K
  WHERE K.LOTA11 BETWEEN TO_CHAR(sysdate-300,'YYYYMMDD') AND TO_CHAR(sysdate,'YYYYMMDD')
  AND   K.STATUS IN('0','1','2','3','4','6','7','B','C')
  AND  (K.LOTA15,K.LOTA14) NOT IN(SELECT LOTA15,LOTA14
                                  FROM TX_MES_MIG_BARCODE_U
                                  WHERE LOTA15 = K.LOTA15
                                  AND   LOTA14 = K.LOTA14)
  AND  (K.LOTA15,K.LOTA14) IN(SELECT LOTA15,LOTA14
                              FROM TX_MES_MIG_BARCODE_2700
                              WHERE LOTA15 = K.LOTA15
                              AND   LOTA14 = K.LOTA14)                                
  AND K.PRCS_CD <> 'J';   

                              
  
  DBMS_OUTPUT.PUT_LINE('TX_PIS_INIT==>완료==>' || TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS'));
  SP_IF_MIG_LOG('SP_IF_MIG_STOCK_MOVE_NEW','0','TX_PIS_INIT==>완료==>' || TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS'));
  COMMIT;   

  
  -----------------------------------------------------------------------------------------------------------------------------
  --T바코드처리(LOOT돌면서 PIS_INIT에 없으면 INSERT 있으면 UPDATE)-CUSOR사용해야 함.
  -----------------------------------------------------------------------------------------------------------------------------  
  FOR cur_row in CUR_DATA loop
    SELECT COUNT(1) INTO V_CNT 
    FROM TX_PIS_INIT
    WHERE IND_BCD = cur_row.LOTA14;
    
    --기존에 재고에 등록되어 있으면 수량,중량만 SUM한다.
    IF V_CNT > 0 THEN  
      UPDATE TX_PIS_INIT
      SET PCNT = NVL(PCNT,0) + cur_row.QTYRCV_R
         ,WGT  = NVL(WGT,0) + cur_row.QTYRCV_KG
      WHERE IND_BCD = cur_row.LOTA14; 
    ELSE
      INSERT INTO TX_PIS_INIT(
         MACH_CD
        ,MATNR
        ,LOT_NO
        ,IND_BCD
        ,ORDER_NO
        ,MACHINE
        ,PROC_CD
        ,PRD_DT
        ,PCODE
        ,UNIT
        ,ROLLCNT
        ,PCNT
        ,SCNT
        ,MCNT
        ,WGT
        ,CORE
        ,BS_WGT
        ,PACKTYPE
        ,CONTYPE
        ,WLEN
        ,VLEN
        ,WIDTH
        ,VBELN
        ,POSNR
        ,KUNNR
        ,MRG_YN
        ,WRK_CLASS
        ,WRK_SHIFT
        ,STATUS
        ,PRFM_DT
        ,WERKS
        ,STK_FLAG
        ,STOR_LOC_CD
      )      
      SELECT
         K.FCLT_CD        AS MACH_CD
        ,K.SKUKEY         AS MATNR
        ,K.LOTA15         AS LOT_NO
        ,K.LOTA14         AS IND_BCD
        ,K.AUFNR          AS ORDER_NO
        ,K.LOTA04         AS MACHINE
        ,K.PRCS_CD        AS PROC_CD
        ,K.LOTA11         AS PRD_DT
        ,K.PAPER_CD       AS PCODE 
        ,CASE WHEN K.PRCS_CD = 'C' THEN 'R'
              WHEN K.PRCS_CD = 'T' THEN 'R'             
              WHEN K.PRCS_CD = 'P' THEN 'R'
              ELSE 'KG'       
         END              AS UNIT
        ,K.QTYRCV_M       AS ROLLCNT
        ,K.QTYRCV_R       AS PCNT
        ,K.BUNDLE_CNT     AS SCNT
        ,K.NMRS_IN_BUNDLE AS MCNT 
        ,K.QTYRCV_KG      AS WGT 
        ,K.LOTA21         AS CORE
        ,K.LOTA16         AS BS_WGT
        ,K.LOTA03         AS PACKTYPE
        ,K.LOTA17         AS CONTYPE
        ,K.WIDTH_LEN      AS WLEN
        ,K.VRTICL_LEN     AS VLEN 
        ,CASE WHEN INSTR(K.PAPER_BT_PROD,'-') > 0 THEN '0' 
              ELSE K.PAPER_BT_PROD
         END              AS WIDTH 
        ,K.LOTA07         AS VBELN
        ,K.LOTA07_SEQ     AS POSNR
        ,K.CUST_CD        AS KUNNR
        ,'N'               AS MRG_YN
        ,K.CLS            AS WRK_CLASS
        ,''                AS WRK_SHIFT
        ,K.STATUS         AS STATUS
        ,K.LOTA11         AS PRFM_DT
        ,'P100'             AS WERKS
        ,'PS_T'             AS STK_FLAG 
        ,'2700'             AS STOR_LOC_CD     
      FROM TX_MES_MIG_BARCODE_1 K
      WHERE SEQNUM = cur_row.SEQNUM;            
    END IF;       
  END LOOP; 
                                  
  DBMS_OUTPUT.PUT_LINE('TX_PIS_INIT_T_BARCODE==>완료==>' || TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS'));
  SP_IF_MIG_LOG('SP_IF_MIG_STOCK_MOVE_NEW_T_BARCODE','0','TX_PIS_INIT_T_BARCODE==>완료==>' || TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS'));
  COMMIT; 
  
  
  -----------------------------------------------------------------------------------------------------------------------------
  --3.운영 PIS초기재고데이타 -> 운영 BASE초기재고데이타 생성 한다.(옵션이다....)  
  -----------------------------------------------------------------------------------------------------------------------------    
/*  PDA스캔하여 실사 안하는것은 재고실사후 이동시키자. 
  INSERT INTO TX_BASE_INIT_TEMP(
         WERKS
        ,MACH_CD
        ,STOR_LOC_CD
        ,LOC_CD
        ,MATNR
        ,LOT_NO
        ,IND_BCD
        ,ORDER_NO
        ,MACHINE
        ,PROC_CD
        ,PRD_DT
        ,PRFM_DT
        ,DSTBT_DDLIN
        ,PCODE
        ,UNIT
        ,ROLLCNT
        ,PCNT
        ,SCNT
        ,MCNT
        ,WGT
        ,CORE
        ,BS_WGT
        ,PACKTYPE
        ,CONTYPE
        ,WLEN
        ,VLEN
        ,WIDTH
        ,VBELN
        ,POSNR
        ,KUNNR
        ,MRG_YN
        ,WRK_CLASS
        ,WRK_SHIFT
        ,IF_YN
        ,INS_DT
        ,STK_FLAG
        ,ON_OFF
  )
  SELECT PIS.WERKS      				AS WERKS      			--플랜트       	  
        ,(SELECT MACH_CD FROM TB_MAS012 WHERE WCS_WRK_CD = PIS.MACH_CD) AS MACH_CD          --설비코드          
        ,STOR_LOC_CD            AS STOR_LOC_CD      --저장위치          
        ,PIS.LOC_CD			  AS LOC_CD           --로케이션          
        ,PIS.MATNR              AS MATNR            --자재코드          
        ,PIS.LOT_NO             AS LOT_NO           --LOT번호         
        ,PIS.IND_BCD            AS IND_BCD          --개별바코드         
        ,PIS.ORDER_NO           AS ORDER_NO         --오더번호          
        ,(SELECT MACHINE FROM TB_MAS012 WHERE WCS_WRK_CD = PIS.MACH_CD) AS MACHINE          --생산호기          
        ,(SELECT PROC_CD FROM TB_MAS012 WHERE WCS_WRK_CD = PIS.MACH_CD) AS PROC_CD          --공정            
        ,PIS.PRD_DT             AS PRD_DT           --생산일자          
        ,PIS.PRFM_DT            AS PRFM_DT          --제조일자          
        ,PIS.DSTBT_DDLIN        AS DSTBT_DDLIN      --유통기간          
        ,PIS.PCODE              AS PCODE            --지종            
        ,PIS.UNIT               AS UNIT             --단위            
        ,PIS.ROLLCNT            AS ROLLCNT          --실적_권치수        
        ,PIS.PCNT               AS PCNT             --실적_연수_REAM    
        ,PIS.SCNT               AS SCNT             --실적_속당매수       
        ,PIS.MCNT               AS MCNT             --실적_속수         
        ,PIS.WGT                AS WGT              --실적_중량         
        ,PIS.CORE               AS CORE             --지관            
        ,PIS.BS_WGT             AS BS_WGT           --평량            
        ,PIS.PACKTYPE           AS PACKTYPE         --포장타입          
        ,PIS.CONTYPE            AS CONTYPE          --컨테이너유형        
        ,PIS.WLEN               AS WLEN             --가로길이          
        ,PIS.VLEN               AS VLEN             --세로길이          
        ,PIS.WIDTH              AS WIDTH            --지폭            
        ,PIS.VBELN              AS VBELN            --판매문서번호        
        ,PIS.POSNR              AS POSNR            --판매문서항목번호      
        ,PIS.KUNNR              AS KUNNR            --판매처_MTO       
        ,PIS.MRG_YN             AS MRG_YN           --라벨병합여부        
        ,PIS.WRK_CLASS          AS WRK_CLASS        --작업반           
        ,PIS.WRK_SHIFT          AS WRK_SHIFT        --작업조   
        ,'N'
        ,sysdate
        ,STK_FLAG  
        ,'ON'      
  FROM TX_PIS_INIT PIS
  WHERE WERKS IN(i_WERKS);
 */                                                 


  DBMS_OUTPUT.PUT_LINE('TX_BASE_INIT_TEMP==>완료==>' || TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS'));
  SP_IF_MIG_LOG('SP_IF_MIG_STOCK_MOVE','0','TX_BASE_INIT_TEMP==>완료==>' || TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS'));
  COMMIT;                                     
                                                                  
    

  o_msg_code      := '0' ;
  o_msg_msg       := '정상처리 되었습니다.';
       
 EXCEPTION
    WHEN OTHERS THEN
      o_msg_code      := '-1' ;
      o_msg_msg       := 'Error: PIS->MES의 TX_BASE_INIT 데이타옮기기 MAIN에서 오류가 발생하였습니다.' || ',' || to_char(SQLCODE) || ',' || SQLERRM ;
      DBMS_OUTPUT.PUT_LINE(o_msg_msg);
      rollback ;

END;
/
