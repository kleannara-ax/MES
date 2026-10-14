--------------------------------------------------------
--  DDL for Function FN_GET_CODE_NM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "KNRAMES"."FN_GET_CODE_NM" 
(
    P_TYPE      IN VARCHAR2,
    P_WERKS     IN VARCHAR2,
    P_CODE      IN VARCHAR2
)
    RETURN VARCHAR2 IS
/*=============================================================================*
 * FUNCTION NAME: FN_GET_CODE_NM
 *   1)INPUT VALUE
 *      P_TYPE : MATNR, MACH_CD
        P_WERKS: 플랜트
 *      P_CODE: 코드
 *   2)OUTPUT VALUE
 *      R_CD_NM: 코드명
 * CREATE DATE  : 2022/04/25
 * DESCRIPTION  :
 * REVERSION HISTORY
 * ------------ ------- ------------- -----------------------------------------
 *    Date        Ver       Name          Description
 * ------------ ------- ------------- -----------------------------------------
 * 2022/04/25    1.0.0   방청길        Initial Version
 * yyyy/mm/dd    1.0.1   홍판서         변경사유 기술
==============================================================================*/
    R_CD_NM        VARCHAR(100);    -- 코드명

BEGIN

    R_CD_NM := ' ';
    IF P_TYPE = 'MATNR' THEN
        SELECT MATNR_NM INTO R_CD_NM
          FROM TB_MAS001
         WHERE WERKS = P_WERKS
           AND MATNR = P_CODE;
    ELSIF P_TYPE = 'MACH_CD' THEN 
        SELECT MACH_NM INTO R_CD_NM
          FROM TB_MAS012
         WHERE MACH_CD = P_CODE; 
    END IF;
   
    RETURN R_CD_NM;

END;

/
