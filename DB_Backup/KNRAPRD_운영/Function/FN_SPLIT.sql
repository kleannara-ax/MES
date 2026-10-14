--------------------------------------------------------
--  DDL for Function FN_SPLIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "KNRAMES"."FN_SPLIT" 
(
    StrValue    IN VARCHAR2 , --'5169,5170,5171,'
    SplitChar   IN VARCHAR2  -- ','
)
RETURN T_FUNC_SPLIT_VALUES PIPELINED --"PIPELINED" : 각 행단위로 반환처리
/*=============================================================================*
 * FUNCTION NAME: FN_SPLIT
 *   1)INPUT VALUE
 *      StrValue: 대상 문자열
 *      SplitChar:  분할 기준 문자
 *   2)OUTPUT VALUE
 *      FUNC_SPLIT_VALUES: 분할된 문자열 테이블
 * CREATE DATE  : 2022/04/29
 * DESCRIPTION  : 입력된 대상 문자열을 분할문자를 기준으로 Row로 저장하여 Table을 반환.                                                   
 * REVERSION HISTORY
 * ------------ ------- ------------- ----------------------------------------- 
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ----------------------------------------- 
 * 2022/04/29    1.0.0   김기연         Initial Version
==============================================================================*/
AS
    --"T_FUNC_SPLIT_VALUES"의 행 타입으로 "V_RESULT_ROW"를 행단위로 반환
    V_RESULT_ROW FUNC_SPLIT_VALUES;
    V_FULL_LEN NUMBER; --전체 문자열 길이
    V_STR_LEN NUMBER; --반환 문자열 길이
    V_STR_POS NUMBER; --문자열 시작 위치
    V_SPL_POS NUMBER; --문자열 구분문자 위치
    V_TMP_STR VARCHAR2(4000); --분할된 문자열
BEGIN
    --변수 초기설정
    V_STR_POS := 1;
    V_FULL_LEN := LENGTH(StrValue);
    LOOP
    --분할위치 조회
    V_SPL_POS := INSTR(StrValue,SplitChar,V_STR_POS);
    --마지막 항목 확인
    IF V_SPL_POS = 0 THEN
        V_SPL_POS := V_FULL_LEN + 1;
    END IF;
    --문자열 길이 조회
    V_STR_LEN := V_SPL_POS - V_STR_POS;
    --추출할 문자열이 없는 경우 종료
    EXIT WHEN V_STR_LEN <= 0;
    --문자열 분할
    V_TMP_STR := SUBSTR(StrValue,V_STR_POS,V_STR_LEN);
    --결과반환 변수에 추출된 문자열 저장
    V_RESULT_ROW := FUNC_SPLIT_VALUES(V_TMP_STR);
    --다음 시작위치 지정
    V_STR_POS := V_SPL_POS + 1;
    --분할된 문자열을 ROW단위로 반환
    PIPE ROW(V_RESULT_ROW);
    END LOOP;

    RETURN;
END;


/
