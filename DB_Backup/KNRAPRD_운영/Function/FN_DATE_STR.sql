--------------------------------------------------------
--  DDL for Function FN_DATE_STR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "KNRAMES"."FN_DATE_STR" 
(
    P_DATE   IN DATE,
    P_FORMAT IN CHAR := 'YYYYMMDD'
)
    RETURN CHAR IS
/*=============================================================================*
 * FUNCTION NAME: FN_GET_CM_VAL
 *   1)INPUT VALUE
 *      P_DATE: 날짜
 *      P_FORMAT: YYYYMMDDHH24MISS
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
    RTN_DATE   VARCHAR(100);    -- 날짜

BEGIN

   RTN_DATE := '';
   SELECT TO_CHAR(P_DATE, P_FORMAT) INTO RTN_DATE  FROM DUAL;
   
   RETURN RTN_DATE;

END;

/
