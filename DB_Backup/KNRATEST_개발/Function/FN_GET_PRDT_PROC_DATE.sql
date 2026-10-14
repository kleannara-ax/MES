--------------------------------------------------------
--  DDL for Function FN_GET_PRDT_PROC_DATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "KNRAMES"."FN_GET_PRDT_PROC_DATE" 
(
    P_PLANT       IN VARCHAR2,
    P_PROC        IN VARCHAR2,
    P_DATETIME    IN VARCHAR2
)
  RETURN CHAR 
 IS
/*=============================================================================*
 * FUNCTION NAME: FN_GET_PRDT_DATE_PROC
 *   1)INPUT VALUE
 *      P_PLANT: 공장
 *      P_PROC:  공정
 *      P_DATETIME: 실적 발생일자
 *   2)OUTPUT VALUE
 *      R_CODE: 생산일자
 * CREATE DATE  : 2022/02/23
 * DESCRIPTION  : 실적 발생일시에 따라 공정별로 계상일자값을 리턴 한다.                                                   
 * REVERSION HISTORY
 * ------------ ------- ------------- ----------------------------------------- 
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ----------------------------------------- 
 * 2022/02/23    1.0.0   김성하         Initial Version
 * yyyy/mm/dd    1.0.1   홍판서         변경사유 기술
==============================================================================*/
    R_CODE       VARCHAR2(100);
    R_DATE       VARCHAR2(8);
    V_PROC_TIME  VARCHAR2(4);

BEGIN

    R_CODE := ' ';
    V_PROC_TIME := '0600'; --기본 7시 처리.

    BEGIN
        /* KKK 의 경우 해당일 060000 부터 익일 055959 까지 같은 기준일자로 지정 
           060000 ~ 175959 까지가 주간조 180000 ~ 055959 까지가 야간조 */
        BEGIN
         /*   SELECT NVL(TRIM(PRD_SRT_TM),V_PROC_TIME)
              INTO V_PROC_TIME
              FROM GSTMTR023
             WHERE PLANT = P_PLANT
               AND PROC  = P_PROC; */

            V_PROC_TIME := '0600';

        EXCEPTION
        WHEN NO_DATA_FOUND THEN
            V_PROC_TIME := '0600';
        END;           

        IF P_PLANT = 'CP' OR P_PLANT = 'UP' THEN

            IF TO_DATE(P_DATETIME, 'YYYYMMDDHH24MISS') < TO_DATE(SUBSTR(P_DATETIME,1,8)|| V_PROC_TIME || '00', 'YYYYMMDDHH24MISS') THEN
                R_DATE := TO_CHAR(TO_DATE(SUBSTR(P_DATETIME,1,8),'YYYYMMDD')-1, 'YYYYMMDD');
            ELSIF TO_DATE(P_DATETIME, 'YYYYMMDDHH24MISS') >= TO_DATE(SUBSTR(P_DATETIME,1,8)|| V_PROC_TIME || '00', 'YYYYMMDDHH24MISS') 
                  AND TO_DATE(P_DATETIME, 'YYYYMMDDHH24MISS') < TO_DATE(SUBSTR(P_DATETIME,1,8)|| TO_CHAR(TO_NUMBER(V_PROC_TIME) + 1200, 'FM0000')|| '00', 'YYYYMMDDHH24MISS') THEN
                R_DATE := TO_CHAR(TO_DATE(SUBSTR(P_DATETIME,1,8),'YYYYMMDD'), 'YYYYMMDD');
            ELSE 
                R_DATE := TO_CHAR(TO_DATE(SUBSTR(P_DATETIME,1,8),'YYYYMMDD'), 'YYYYMMDD');
            END IF;            

        END IF;        

        R_CODE := R_DATE;    

        IF LTRIM(R_CODE) IS NULL THEN
            R_CODE := ' ';
        END IF;

    EXCEPTION
    WHEN OTHERS THEN
        R_CODE := ' ';
    END;

    RETURN R_CODE;  

END;

/
