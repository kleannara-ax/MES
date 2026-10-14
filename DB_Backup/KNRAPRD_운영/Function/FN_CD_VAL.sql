--------------------------------------------------------
--  DDL for Function FN_CD_VAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "KNRAMES"."FN_CD_VAL" 
(
    P_CM_KEY    IN CHAR,
    P_CD_KEY    IN CHAR
)
    RETURN CHAR IS
/*=============================================================================*
 * FUNCTION NAME: FN_GET_CM_VAL
 *   1)INPUT VALUE
 *      P_CM_KEY: 코드 그룹
 *      P_CD_KEY: 공통코드
 *   2)OUTPUT VALUE
 *      R_CD_NM: 생산일자
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

    SELECT CDESC1 INTO R_CD_NM 
      FROM CMCDV 
     WHERE CMCDKY = P_CM_KEY 
       AND CMCDVL = P_CD_KEY 
       AND ROWNUM <= 1;

    RETURN R_CD_NM;

END;

/
