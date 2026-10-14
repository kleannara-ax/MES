--------------------------------------------------------
--  DDL for Function FN_UNIT_RATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "KNRAMES"."FN_UNIT_RATE" 
(
  P_MATNR IN VARCHAR2 
, P_WERKS IN VARCHAR2
, P_BEF_UNIT IN VARCHAR2
, P_AFT_UNIT IN VARCHAR2 
) RETURN VARCHAR2 AS 
/*=============================================================================*
 * FUNCTION NAME: FN_UNIT_RATE
 *   1)INPUT VALUE
 *      P_MATNR: 단위 변환 자재코드
 *      P_BEF_UNIT: 변환 전 단위
 *      P_AFT_UNIT: 변환 후 단위
 *   2)OUTPUT VALUE
 *      FN_UNIT_RATE: 자재수량 변환 비율
 * CREATE DATE  : 2022/05/10
 * DESCRIPTION  : 자재 및 단위, 수량을 입력받아 요청된 단위의 수량으로 변환하여 반환.                                                   
 * REVERSION HISTORY
 * ------------ ------- ------------- ----------------------------------------- 
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ----------------------------------------- 
 * 2022/05/10    1.0.0   김기연         Initial Version
==============================================================================*/
    V_RTN_RATE VARCHAR(20); --반환값
    V_MUL NUMBER; --곱할수량
    V_DIV NUMBER; --나눌수량
    V_BASE_UNIT VARCHAR2(3); --기준단위
    V_UNIT_FLAG NUMBER; --단위여부 
BEGIN
    --기준단위 확인
    SELECT UNIT INTO V_BASE_UNIT
      FROM TB_MAS001 
     WHERE 1=1
       AND WERKS = P_WERKS
       AND MATNR = P_MATNR;
    --기존단위 여부 확인
    SELECT COUNT(UNIT) INTO V_UNIT_FLAG 
      FROM TB_MAS005 
     WHERE MATNR = P_MATNR 
       AND UNIT = P_BEF_UNIT
       AND USE_YN = 'Y';
    --기존단위가 기준단위와 일치시 입력수량 사용
    IF V_BASE_UNIT = P_BEF_UNIT THEN
        V_MUL := 1;
        V_DIV := 1;
    --기존 단위가 없는 경우 
    ELSIF V_UNIT_FLAG = 0 THEN
        V_RTN_RATE := '0,1'; --계산값이 0이 되도록 반환
        RETURN V_RTN_RATE;
    --기존단위가 기준단위와 불일치시 BEF -> BASE 변환정보 조회
    ELSE
        SELECT UMREN, UMREZ  INTO V_DIV, V_MUL
        --SELECT UMREN, UMREZ  INTO V_MUL, V_DIV
          FROM TB_MAS005
         WHERE 1=1
           AND MATNR = P_MATNR
           AND UNIT = P_BEF_UNIT;
    END IF;

    --요청단위 여부 확인
    SELECT COUNT(UNIT) INTO V_UNIT_FLAG 
      FROM TB_MAS005 
     WHERE MATNR = P_MATNR 
       AND UNIT = P_AFT_UNIT
       AND USE_YN = 'Y';
    --요청한 단위가 없는 경우 
    IF V_UNIT_FLAG = 0 THEN
        V_RTN_RATE := '0,1'; --계산값이 0이 되도록 반환
        RETURN V_RTN_RATE;
    -- 요청된 단위 존재시
    ELSE
        --단위가 존재하는 경우 BASE -> AFT 변환정보 추가
        SELECT V_DIV * UMREZ, V_MUL * UMREN  INTO V_DIV, V_MUL
        --SELECT V_MUL * UMREZ, V_DIV * UMREN  INTO V_MUL, V_DIV
          FROM TB_MAS005
         WHERE 1=1
           AND MATNR = P_MATNR
           AND UNIT = P_AFT_UNIT;
    END IF;
    RETURN TO_CHAR(V_MUL) || ',' || TO_CHAR(V_DIV);
END FN_UNIT_RATE;


/
