--------------------------------------------------------
--  DDL for Function FN_GET_PRDT_DATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "KNRAMES"."FN_GET_PRDT_DATE" 
(
    P_DATETIME          IN CHAR
)
RETURN CHAR IS
/*=============================================================================*
 * FUNCTION NAME: FN_GET_PRDT_DATE
 *   1)INPUT VALUE
 *      P_DATETIME: 실적 발생일자
 *   2)OUTPUT VALUE
 *      R_PRDT_DTM: 생산일자
 * CREATE DATE  : 2022/02/23
 * DESCRIPTION  : 실적 발생일시에 따라 계상일자값을 리턴 한다.                                                   
 * REVERSION HISTORY
 * ------------ ------- ------------- ----------------------------------------- 
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ----------------------------------------- 
 * 2022/02/23    1.0.0   김성하         Initial Version
 * yyyy/mm/dd    1.0.1   홍판서         변경사유 기술
==============================================================================*/
R_PRDT_DTM    CHAR(8);       -- 계상일자값
N_CURR_HH     NUMBER(2);     -- 현재시간
V_DATE        DATE;


BEGIN
   V_DATE := TO_DATE(P_DATETIME,'YYYYMMDDHH24MISS');

    N_CURR_HH := TO_NUMBER(SUBSTR(P_DATETIME,9,2));       

    IF N_CURR_HH >= 0 AND N_CURR_HH <= 7 THEN     --  00시 ~ 08
         R_PRDT_DTM := TO_CHAR(V_DATE-1,'YYYYMMDD');       -- 이전 날짜
    ELSE
         R_PRDT_DTM := TO_CHAR(V_DATE,'YYYYMMDD');         -- 현재 날짜
    END IF;

    RETURN R_PRDT_DTM;   

END;


/
