--------------------------------------------------------
--  DDL for Function FN_CHG_UNIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "KNRAMES"."FN_CHG_UNIT" 
(
      P_MATNR    IN VARCHAR2 
    , P_WERKS    IN VARCHAR2
    , P_BEF_UNIT IN VARCHAR2
    , P_AFT_UNIT IN VARCHAR2 
    , P_QTY      IN NUMBER 
) 
 RETURN NUMBER AS 
/*=============================================================================*
 * FUNCTION NAME: FN_UNIT_CHG
 *   1)INPUT VALUE
 *      P_MATNR: 단위 변환 자재코드
 *      P_BEF_UNIT: 변환 전 단위
 *      P_AFT_UNIT: 변환 후 단위
 *      P_QTY: 변환 수량
 *   2)OUTPUT VALUE
 *      FN_UNIT_CHG: 변환된 자재수량
 * CREATE DATE  : 2022/05/10
 * DESCRIPTION  : 자재 및 단위, 수량을 입력받아 요청된 단위의 수량으로 변환하여 반환.                                                   
 * REVERSION HISTORY
 * ------------ ------- ------------- ----------------------------------------- 
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ----------------------------------------- 
 * 2022/05/10    1.0.0   김기연         Initial Version
==============================================================================*/
    V_RTN_QTY   NUMBER;      --반환값
    V_CHG_RATE  NUMBER;      --변환비율
    V_BASE_UNIT VARCHAR2(3); --기준단위
    V_UNIT_FLAG NUMBER;      --단위여부 
BEGIN
    --기준단위 확인
    SELECT UNIT INTO V_BASE_UNIT
      FROM TB_MAS001 
     WHERE 1=1
       AND WERKS = P_WERKS
       AND MATNR = P_MATNR;
    --기준단위 여부 확인
    SELECT COUNT(UNIT) INTO V_UNIT_FLAG 
      FROM TB_MAS005 
     WHERE MATNR = P_MATNR 
       AND UNIT = P_BEF_UNIT
       AND USE_YN = 'Y';
    --기존단위가 기준단위와 일치시 입력수량 사용
    IF V_BASE_UNIT = P_BEF_UNIT THEN
        V_RTN_QTY := P_QTY;
    --기존 단위가 없는 경우 에러여부 반환 -> 0츠로 처리
    ELSIF V_UNIT_FLAG = 0 THEN
        V_RTN_QTY := 0;---1; --P_QTY;
    --기존단위가 기준단위와 불일치시 기준단위로 변환
    ELSE  -- 입력수량 * (분자 / 분모)
        SELECT P_QTY * (UMREZ / UMREN) INTO V_RTN_QTY
        --SELECT P_QTY * (UMREN / UMREZ) INTO V_RTN_QTY
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

    --기준단위와 변환단위가 같은 경우 기준수량으로 진행
    IF V_BASE_UNIT = P_AFT_UNIT THEN
        V_RTN_QTY := V_RTN_QTY;
    -- 요청된 단위가 없는 경우 -1 반환 ->0으로 처리
    ELSIF V_UNIT_FLAG = 0 THEN
        V_RTN_QTY := 0;---1;
    -- 요청된 단위 존재시
    ELSE
        --기준 수량을 변환단위의 수량으로 처리 
        --입력수량 * (분모 / 분자)
        SELECT V_RTN_QTY * (UMREN / UMREZ) INTO V_RTN_QTY
        --SELECT V_RTN_QTY * (UMREZ / UMREN) INTO V_RTN_QTY
          FROM TB_MAS005
         WHERE 1=1
           AND MATNR = P_MATNR
           AND UNIT = P_AFT_UNIT;
    END IF;
    --변환수량 반환(소수점 3자리 올림처리 해당 자리수가 0인경우 버림 ex> 1.0 )
    RETURN ROUND(V_RTN_QTY + 0.0004,3);
END FN_CHG_UNIT;

/
