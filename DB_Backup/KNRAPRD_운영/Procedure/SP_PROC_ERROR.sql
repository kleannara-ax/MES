--------------------------------------------------------
--  DDL for Procedure SP_PROC_ERROR
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_PROC_ERROR" 
(
    P_PLT_CD    IN  CHAR,
    P_PGM_NM    IN  VARCHAR2, 
    P_ERR_CD    IN  NUMBER        DEFAULT 0,
    P_ERR_MSG   IN  VARCHAR2      DEFAULT '',
    P_USR_ID    IN  VARCHAR2     
)
IS
/*==============================================================================
 * PROGRAM ID    : {}
 * PROGRAM NAME  : {프로시저 오류 저장}
 * VERSION       : {1.0.0}
 * DESCRIPTION   : {프로시저 오류정보를 에러 테이블에 저장한다.}
 *                 
 * AUTHOR NAME   : 김성하
 * CREATE DATE   : 2022.03.11 {최초 작성일자 기술}
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/03/11    1.0.0   김성하         Initial Version
 *==============================================================================
 *  관련 테이블
 *       - [TB_COM900] : (C...) 프로시저 오류 수집 테이블                                       
 *=============================================================================*/

V_PRG_NM                VARCHAR2(100)  := 'P_PROC_ERROR';     -- PROCEDURE NAME
V_ERR_MSG               VARCHAR2(4000);

BEGIN

   V_ERR_MSG := TRIM(SUBSTR(P_ERR_MSG,1,4000));

    INSERT INTO TB_COM900
         (PLANT,        OCCR_ID,        PGM_NAME,  ERR_CODE,      ERR_MSG,  ERR_DTM,  USR_ID )
    VALUES
         (P_PLT_CD,     TO_CHAR(SYSDATE,'YYMMDDHH24MISS') || LTRIM(TO_CHAR(SEQ_COM900.NEXTVAL,'0000000000')),
          P_PGM_NM,     P_ERR_CD,     V_ERR_MSG,  SYSDATE,  P_USR_ID);

  COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        NULL;
END;


/
