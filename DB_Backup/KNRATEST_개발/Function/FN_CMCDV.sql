--------------------------------------------------------
--  DDL for Function FN_CMCDV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "KNRAMES"."FN_CMCDV" 
( 
    v_CMCDKY IN VARCHAR2, 
    v_CMCDVL IN VARCHAR2
) 
  RETURN VARCHAR2 AS
    
  v_rtn  VARCHAR2(180);
BEGIN
/******************************************************************************
1. 작성자 : 박충식
2. 최초 작성 날짜 : 2022년 4월 28일
3. 최종 수정 날짜 :  
4. 기능 : 공통코드 세부명칭 조회
5. 연관 테이블 :
6. 연관 폼 : 없음
7. 입력 데이터 : 
******************************************************************************/
    SELECT CDESC1
      INTO v_rtn
      FROM CMCDV
     WHERE CMCDKY = v_CMCDKY
       AND CMCDVL = v_CMCDVL;

    RETURN v_rtn;
    
END;

/
