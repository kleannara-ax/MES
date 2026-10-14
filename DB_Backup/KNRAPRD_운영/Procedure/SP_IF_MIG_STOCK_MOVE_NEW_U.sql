--------------------------------------------------------
--  DDL for Procedure SP_IF_MIG_STOCK_MOVE_NEW_U
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_IF_MIG_STOCK_MOVE_NEW_U" (
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
 
  CURSOR  CUR_DATA IS 
    SELECT K.*                   
    FROM TX_MES_MIG_BARCODE_1 K
    WHERE K.LOTA11 BETWEEN TO_CHAR(sysdate-300,'YYYYMMDD') AND TO_CHAR(sysdate,'YYYYMMDD')
    AND   K.STATUS IN('0','1','2','3','4','6','7','B','C')                                                                                                  
    AND  (SELECT count(1) FROM TX_MES_MIG_BARCODE_U WHERE LOTA14 = K.LOTA14) > 0;
 
BEGIN
  
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
        ,'U'               AS MRG_YN
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
