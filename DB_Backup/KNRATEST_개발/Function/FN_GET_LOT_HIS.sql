--------------------------------------------------------
--  DDL for Function FN_GET_LOT_HIS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "KNRAMES"."FN_GET_LOT_HIS" 
(
    P_WERKS       IN VARCHAR2,
    P_ORDER_NO    IN VARCHAR2
)
  RETURN VARCHAR2 
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
    R_LOT        VARCHAR2(100);
    V_PROC_TIME  VARCHAR2(4);
    V_LOT_NO        VARCHAR2(20);
    V_LOT_HIS        VARCHAR2(100);
    PROD_CUR            SYS_REFCURSOR;		-- 커서 정의
BEGIN
    R_CODE := ' ';
    BEGIN
        OPEN PROD_CUR FOR
            SELECT DISTINCT(LOT_NO)   INTO V_LOT_NO
              FROM TB_WRK002
             WHERE WERKS = P_WERKS
               AND ORDER_NO = P_ORDER_NO;
        LOOP
        FETCH PROD_CUR INTO V_LOT_NO;
        EXIT WHEN PROD_CUR %NOTFOUND;
            
            IF NVL(V_LOT_HIS, ' ') = ' ' THEN
                V_LOT_HIS := V_LOT_NO;
            ELSE    
                V_LOT_HIS := V_LOT_HIS || ',' || V_LOT_NO;
            END IF; 
                
        END LOOP;
        CLOSE PROD_CUR; 
        
    EXCEPTION
    WHEN OTHERS THEN
        V_LOT_HIS := ' ';
    END;

    RETURN V_LOT_HIS;  

END;

/
