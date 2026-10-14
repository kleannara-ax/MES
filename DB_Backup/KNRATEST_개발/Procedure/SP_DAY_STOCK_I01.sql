--------------------------------------------------------
--  DDL for Procedure SP_DAY_STOCK_I01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_DAY_STOCK_I01" 

/*==============================================================================
 * PROGRAM ID    : SP_DAY_STOCK_I01
 * PROGRAM NAME  : 일자별 재고생성(약품)
 * VERSION       : 1.0.0
 * DESCRIPTION   : 매일 7시 기준 일일재고생성
 *                 
 * AUTHOR NAME   : YSH
 * CREATE DATE   : 2022/06/29
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}	<생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}		<생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}			<생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}	<생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    DATE        VER       NAME          DESCRIPTION      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/06/29    1.0.0   유상호         INITIAL VERSION 
 *==============================================================================
 *  관련 테이블

 *=============================================================================*/ 
 AS
--변수선언
    V_DATE          DATE := SYSDATE;
BEGIN
    V_DATE := V_DATE -1;

    INSERT INTO TB_INV016(WERKS, PRFM_DT, MATNR, LOT_NO, STCK_QTY, UNIT, REGDATE)   
    SELECT WERKS, TO_CHAR(V_DATE, 'YYYYMMDD'), MATNR, ' ', STCK_QTY, UNIT, SYSDATE
      FROM TB_INV001
     WHERE MATNR IN(  
                    SELECT MATNR
                      FROM TB_MAS001
                     WHERE MATNR_GRP_CD LIKE '2%')
       AND STCK_QTY > 0   ;

END;

/
