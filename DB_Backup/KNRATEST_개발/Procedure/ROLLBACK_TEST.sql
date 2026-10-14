--------------------------------------------------------
--  DDL for Procedure ROLLBACK_TEST
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."ROLLBACK_TEST" 
(
            P_DOC_NO        IN VARCHAR2
            ,P_DOC_SEQNO    IN VARCHAR2
            ,p_cursor       out sys_refcursor

)


AS


    --parameter변수 처리
    
    V_DOC_NO            TB_WRK021.DOC_NO%TYPE;   
    V_DOC_SEQNO         TB_WRK021.DOC_SEQNO%TYPE;
    V_DOC_DIV           TB_WRK021.DOC_DIV%TYPE;
    V_WERKS             TB_WRK021.WERKS%TYPE;
    V_MACH_CD           TB_WRK021.MACH_CD%TYPE;
    V_IND_BCD           TB_WRK021.IND_BCD%TYPE;
    V_LOT_NO            TB_WRK021.LOT_NO%TYPE;
    V_ORDER_NO          TB_WRK021.ORDER_NO%TYPE;
    V_SDOC_NO           TB_WRK021.SDOC_NO%TYPE;
    V_SDOC_SEQNO        TB_WRK021.SDOC_SEQNO%TYPE;
    V_WRK_ORDR_NO       TB_WRK021.WRK_ORDR_NO%TYPE;
    V_WRK_ORDR_SEQNO    TB_WRK021.WRK_ORDR_SEQNO%TYPE := 1;
    V_STOR_LOC_CD		TB_MAS001.LGPRO%TYPE;
    V_MATNR			    TB_SCH015.MATNR%TYPE;
    V_SHEET             TB_SCH016.SHEET%TYPE;         --판지구분
    V_SLITER            TB_SCH016.SLITER%TYPE;  
    V_SAP_WRK_CD        TB_MAS012.SAP_WRK_CD%TYPE;
    V_RUN_STA           TB_WRK011.RUN_STA%TYPE;
    V_TOT_QTY           TB_WRK002.PRFM_QTY%TYPE;
    V_ROLLCNT 			TB_WRK002.ROLLCNT%TYPE;
    V_PRFM_QTY	        TB_WRK002.PRFM_QTY%TYPE;
    V_DISPO_QTY         TB_WRK002.PRFM_QTY%TYPE;
    V_DISPO_WGT         TB_WRK004.WGT%TYPE;  
    V_LOT_NO_M			TB_INV010.LOT_NO_M%TYPE;
    V_MATNR_M			TB_INV010.MATNR_M%TYPE;
    V_INP_DT			TB_INV010.INP_DT%TYPE;
    V_IND_BCD_M			TB_INV010.IND_BCD_M%TYPE;
    V_DATE              DATE := SYSDATE;
    V_PRE_ORDER_NO      TB_WRK002.ORDER_NO%TYPE;
    V_MACH_STA          TB_WRK011.MACH_STA%TYPE;    
    V_PRFM_DT           VARCHAR2(20);



BEGIN


            SELECT   DOC_DIV,   WERKS,   MACH_CD,   IND_BCD,   LOT_NO,   ORDER_NO,   SDOC_NO,   SDOC_SEQNO
                    ,WRK_ORDR_NO    ,WRK_ORDR_SEQNO
            INTO   V_DOC_DIV, V_WERKS, V_MACH_CD, V_IND_BCD, V_LOT_NO, V_ORDER_NO, V_SDOC_NO, V_SDOC_SEQNO
                  ,V_WRK_ORDR_NO  ,V_WRK_ORDR_SEQNO
            FROM  TB_WRK021
            WHERE DOC_NO = P_DOC_NO
            AND   DOC_SEQNO = P_DOC_SEQNO;
            


  OPEN  p_cursor FOR
  SELECT 'WRK002' AS 테이블명
        ,WERKS
        ,MACH_CD
        ,IND_BCD
        ,LOT_NO
        ,MATNR
        ,ORDER_NO
        ,ORDER_SEQNO
        ,WRK_ORDR_NO
        ,WRK_ORDR_SEQNO
        ,PRFM_QTY
        ,ROLLCNT
        ,WGT
        ,REGDATE
        ,TO_NUMBER('')             AS 재고량
        ,'' 	                AS DOC_NO
        ,TO_NUMBER('') 	        AS DOC_SEQNO
        ,'' 	                AS SDOC_NO
        ,'' 	                AS SDO_SEQNO         
        ,CNL_YN
        ,CNL_RMK        
    FROM TB_WRK002
   WHERE WERKS = V_WERKS
   AND   MACH_CD = V_MACH_CD
   AND   WRK_ORDR_NO = V_WRK_ORDR_NO
   AND   WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
   AND   ORDER_NO        = V_ORDER_NO
   AND   IND_BCD         = V_IND_BCD
   --AND   LOT_NO        = '2B01J30003'
   --AND   NVL(CNL_YN,'N') <> 'Y'
 UNION ALL
  SELECT 'WRK011'  AS 테이블명
        ,WERKS
        ,MACH_CD
        ,''             AS IND_BCD
        ,LOT_NO
        ,MATNR
        ,ORDER_NO
        ,TO_NUMBER('')             AS ORDER_SEQNO
        ,WRK_ORDR_NO
        ,WRK_ORDR_SEQNO
        ,TO_NUMBER('')             AS PRFM_QTY
        ,TO_NUMBER('')             AS ROLLCNT
        ,TO_NUMBER('')             AS WGT
        ,REGDATE
        ,TO_NUMBER('')             AS 재고량  
        ,'' 	AS DOC_NO
        ,TO_NUMBER('') 	AS DOC_SEQNO
        ,'' 	AS SDOC_NO
        ,'' 	AS SDO_SEQNO         
        ,''             AS CNL_YN
        ,''             AS CNL_RMK        
    FROM TB_WRK011 
   WHERE WERKS = V_WERKS
     AND MACH_CD = V_MACH_CD
 UNION ALL
  SELECT 'INV001'   AS 테이블명
        ,WERKS
        ,MACH_CD
        ,IND_BCD
        ,LOT_NO
        ,MATNR
        ,ORDER_NO
        ,TO_NUMBER('')              AS ORDER_SEQNO
        ,WRK_ORDR_NO
        ,WRK_ORDR_SEQNO
        ,STCK_QTY       AS PRFM_QTY
        ,TO_NUMBER('')              AS ROLLCNT
        ,TO_NUMBER('')              AS WGT
        ,REGDATE
        ,TO_NUMBER('')              AS 재고량   
        ,'' 	                    AS DOC_NO
        ,TO_NUMBER('') 	            AS DOC_SEQNO
        ,'' 	                AS SDOC_NO
        ,'' 	                AS SDO_SEQNO         
        ,''             AS CNL_YN
        ,''             AS CNL_RMK          
    FROM TB_INV001
   WHERE WERKS = V_WERKS
     AND MACH_CD = V_MACH_CD
     AND WRK_ORDR_NO = V_WRK_ORDR_NO
     AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
     AND ORDER_NO = V_ORDER_NO
     AND IND_BCD  = V_IND_BCD
 UNION ALL
  SELECT 'INV003'       AS 테이블명
        ,WERKS
        ,MACH_CD
        ,IND_BCD
        ,LOT_NO
        ,MATNR
        ,''             AS ORDER_NO
        ,TO_NUMBER('')              AS ORDER_SEQNO
        ,WRK_ORDR_NO
        ,WRK_ORDR_SEQNO
        ,USE_QTY       AS PRFM_QTY
        ,TO_NUMBER('')              AS ROLLCNT
        ,TO_NUMBER('')              AS WGT
        ,REGDATE
        ,STCK_QTY       AS 재고량
        ,'' 	        AS DOC_NO
        ,TO_NUMBER('') 	AS DOC_SEQNO
        ,'' 	        AS SDOC_NO
        ,'' 	        AS SDO_SEQNO         
        ,''             AS CNL_YN
        ,''             AS CNL_RMK          
    FROM TB_INV003
   WHERE WERKS = V_WERKS
     AND MACH_CD = V_MACH_CD
     AND WRK_ORDR_NO = V_WRK_ORDR_NO
     AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
     --AND ORDER_NO = V_ORDER_NO
     AND IND_BCD  = V_IND_BCD
 UNION ALL
  SELECT 'INV010'       AS 테이블명
        ,WERKS
        ,MACH_CD
        ,IND_BCD
        ,LOT_NO
        ,MATNR
        ,''             AS ORDER_NO
        ,TO_NUMBER('')              AS ORDER_SEQNO
        ,WRK_ORDR_NO
        ,WRK_ORDR_SEQNO
        ,USE_QTY       AS PRFM_QTY
        ,ROLLCNT              AS ROLLCNT
        ,WGT             AS WGT
        ,REGDATE
        ,TO_NUMBER('')              AS 재고량
        ,'' 	        AS DOC_NO
        ,TO_NUMBER('') 	AS DOC_SEQNO
        ,'' 	        AS SDOC_NO
        ,'' 	        AS SDO_SEQNO         
        ,''             AS CNL_YN
        ,''             AS CNL_RMK          
    FROM TB_INV010
   WHERE WERKS = V_WERKS
     AND MACH_CD = V_MACH_CD
     AND WRK_ORDR_NO = V_WRK_ORDR_NO
     AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
     --AND ORDER_NO = V_ORDER_NO
     AND IND_BCD  = V_IND_BCD
 UNION ALL
  SELECT 'WRK004'       AS 테이블명
        ,WERKS
        ,MACH_CD
        ,IND_BCD
        ,LOT_NO
        ,MATNR
        ,''             AS ORDER_NO
        ,TO_NUMBER('')              AS ORDER_SEQNO
        ,WRK_ORDR_NO
        ,WRK_ORDR_SEQNO
        ,DISPO_QTY       AS PRFM_QTY
        ,ROLLCNT         AS ROLLCNT
        ,WGT             AS WGT
        ,REGDATE
        ,TO_NUMBER('')              AS 재고량
        ,'' 	AS DOC_NO
        ,TO_NUMBER('') 	AS DOC_SEQNO
        ,'' 	AS SDOC_NO
        ,'' 	AS SDO_SEQNO 
        ,''             AS CNL_YN
        ,''             AS CNL_RMK          
    FROM TB_WRK004
   WHERE WERKS = V_WERKS
     AND MACH_CD = V_MACH_CD
     AND WRK_ORDR_NO = V_WRK_ORDR_NO
     AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
     AND ORDER_NO = V_ORDER_NO
     AND IND_BCD  = V_IND_BCD
 UNION ALL
  SELECT 'WRK008'       AS 테이블명
        ,WERKS
        ,MACH_CD
        ,IND_BCD
        ,LOT_NO
        ,MATNR
        ,''             AS ORDER_NO
        ,TO_NUMBER('')              AS ORDER_SEQNO
        ,WRK_ORDR_NO
        ,WRK_ORDR_SEQNO
        ,PRFM_QTY       AS PRFM_QTY
        ,TO_NUMBER('')              AS ROLLCNT
        ,TO_NUMBER('')             AS WGT
        ,REGDATE
        ,USE_QTY        AS 재고량
        ,'' 	AS DOC_NO
        ,TO_NUMBER('') 	AS DOC_SEQNO
        ,'' 	AS SDOC_NO
        ,'' 	AS SDO_SEQNO        
        ,''             AS CNL_YN
        ,''             AS CNL_RMK          
    FROM TB_WRK008
   WHERE WERKS = V_WERKS
     AND WRK_ORDR_NO = V_WRK_ORDR_NO
     AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
     AND IND_BCD  = V_IND_BCD
 UNION ALL
  SELECT 'WRK021'       AS 테이블명
        ,WERKS
        ,MACH_CD
        ,IND_BCD
        ,LOT_NO
        ,''             AS MATNR
        ,ORDER_NO             AS ORDER_NO
        ,TO_NUMBER('')              AS ORDER_SEQNO
        ,WRK_ORDR_NO
        ,WRK_ORDR_SEQNO
        ,TO_NUMBER('')              AS PRFM_QTY
        ,TO_NUMBER('')              AS ROLLCNT
        ,TO_NUMBER('')              AS WGT
        ,REGDATE
        ,TO_NUMBER('')              AS 재고량
        ,DOC_NO
        ,DOC_SEQNO
        ,SDOC_NO
        ,SDOC_SEQNO
        ,CNL_YN         AS CNL_YN
        ,''             AS CNL_RMK          
    FROM TB_WRK021
   WHERE WERKS = V_WERKS
     AND MACH_CD = V_MACH_CD
     AND WRK_ORDR_NO = V_WRK_ORDR_NO
     AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
     AND IND_BCD  = V_IND_BCD
 UNION ALL
  SELECT 'WRK022'       AS 테이블명
        ,WERKS
        ,MACH_CD
        ,IND_BCD
        ,LOT_NO
        ,MATNR             AS MATNR
        ,ORDER_NO             AS ORDER_NO
        ,TO_NUMBER('')              AS ORDER_SEQNO
        ,WRK_ORDR_NO
        ,WRK_ORDR_SEQNO
        ,DISPO_QTY              AS PRFM_QTY
        ,ROLLCNT              AS ROLLCNT
        ,WGT              AS WGT
        ,REGDATE
        ,TO_NUMBER('')              AS 재고량
        ,DOC_NO
        ,DOC_SEQNO
        ,SDOC_NO
        ,SDOC_SEQNO
        ,''             AS CNL_YN
        ,''             AS CNL_RMK          
    FROM TB_WRK022
   WHERE WERKS = V_WERKS
     AND MACH_CD = V_MACH_CD
     AND WRK_ORDR_NO = V_WRK_ORDR_NO
     AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
     AND IND_BCD  = V_IND_BCD;     



    --DBMS_SQL.RETURN_RESULT(TB_WRK011_CUR);

END;

/
