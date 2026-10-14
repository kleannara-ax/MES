--------------------------------------------------------
--  DDL for Function FN_DT_FORMAT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "KNRAMES"."FN_DT_FORMAT" 
(
    P_DATE   IN VARCHAR2,
    P_FORMAT IN CHAR := 'YYYYMMDD'
)
    RETURN CHAR IS
/*=============================================================================*
 * FUNCTION NAME: FN_GET_CM_VAL
 *   1)INPUT VALUE
 *      P_DATE: 날짜
 *      P_FORMAT: FN_DATE_STR_FORMAT
 *   2)OUTPUT VALUE
 *      R_CD_NM: 생산일자
 * CREATE DATE  : 2022/05/30
 * DESCRIPTION  :
 * REVERSION HISTORY
 * ------------ ------- ------------- -----------------------------------------
 *    Date        Ver       Name          Description
 * ------------ ------- ------------- -----------------------------------------
 * 2022/05/30    1.0.0   김기연        Initial Version
 * yyyy/mm/dd    1.0.1   홍판서         변경사유 기술
==============================================================================*/
    RTN_DATE     VARCHAR(100);  -- 날짜
    TEMP_DATE    DATE;          --일자타입
    TEMP_STR     VARCHAR2(20);  --문자열 타입
BEGIN
    --결과값 초기화
    RTN_DATE := '';
    --입력된 일자양식 통일
    TEMP_STR := REPLACE(REPLACE(REPLACE(P_DATE,'-',''),':',''),' ','');
    --날짜 타입으로 변경
    --일자만 있는경우
    IF LENGTH(TEMP_STR) = 8 THEN
        TEMP_DATE := TO_DATE(TEMP_STR,'YYYYMMDD');
    --일자 및 시간이 있는 경우
    ELSIF LENGTH(TEMP_STR) = 14 THEN
        TEMP_DATE := TO_DATE(TEMP_STR,'YYYYMMDDHH24MISS');
    --양식이 맞지 않는 경우 반환
    ELSE
        RETURN P_DATE;
    END IF;
    --요청된 양식으로 반환
    SELECT TO_CHAR(TEMP_DATE, P_FORMAT) INTO RTN_DATE  FROM DUAL;
    
    RETURN RTN_DATE;
    
END;

/
