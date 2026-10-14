--------------------------------------------------------
--  DDL for Function FN_GET_DSTBT_DDLIN_DT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "KNRAMES"."FN_GET_DSTBT_DDLIN_DT" 
(
    P_WERKS     IN VARCHAR2
   ,P_MATNR     IN VARCHAR2
   ,P_PRD_DT    IN VARCHAR2      --생산일자
)
  RETURN VARCHAR2 
IS
/*=============================================================================*
 * FUNCTION NAME: FN_GET_DSTBT_DDLIN_DATE
 *   1)INPUT VALUE
 *      P_PRD_DT: 생산일자
 *   2)OUTPUT VALUE
 *      R_PRDT_DTM: 유통일자
 * CREATE DATE  : 2022/02/23
 * DESCRIPTION  :                                                  
 * REVERSION HISTORY
 * ------------ ------- ------------- ----------------------------------------- 
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ----------------------------------------- 
 * 2022/02/23    1.0.0   김성하         Initial Version
 * yyyy/mm/dd    1.0.1   홍판서         변경사유 기술
==============================================================================*/
  R_PRDT_DTM      VARCHAR2(10);  --계상일자값
  V_DSTBT_DDLIN   NUMBER;        --유통기간(일수)
  V_DATE          DATE;
  
BEGIN
    BEGIN
        SELECT DSTBT_DDLIN INTO V_DSTBT_DDLIN
          FROM TB_MAS001
         WHERE WERKS = P_WERKS
           AND MATNR = P_MATNR;
           
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
         V_DSTBT_DDLIN := 1095;
    END;

    IF V_DSTBT_DDLIN IS NULL THEN
        V_DSTBT_DDLIN := 1095;
    END IF;

    V_DATE := TO_DATE(P_PRD_DT,'YYYY-MM-DD');
    R_PRDT_DTM := TO_CHAR(V_DATE + V_DSTBT_DDLIN, 'YYYY-MM-DD');

    RETURN R_PRDT_DTM;   

END;

/
