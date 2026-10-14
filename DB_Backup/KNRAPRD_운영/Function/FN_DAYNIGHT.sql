--------------------------------------------------------
--  DDL for Function FN_DAYNIGHT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "KNRAMES"."FN_DAYNIGHT" 
( pdatetime IN VARCHAR2 ) 
 RETURN VARCHAR2 
 AS
    v_datetime  VARCHAR2(30);
    v_rtn       VARCHAR2(30);
    v_vstime    VARCHAR2(10);
    v_vetime    VARCHAR2(10);
    v_vttime    VARCHAR2(10);
BEGIN
/******************************************************************************
1. 작성자 : 김기연
2. 최초 작성 날짜 : 2022년 2월 16일
3. 최종 수정 날짜 :  
4. 기능 : 주야 구분
5. 연관 테이블 :
6. 연관 폼 : 없음
7. 입력 데이터 : 
*******************************************************************************/
    v_datetime := pdatetime;
    v_vttime := TO_CHAR(SYSDATE, 'HH24-MI-SS');

    SELECT USARG3
      INTO v_vstime
      FROM CMCDV
     WHERE CMCDKY = 'DAYNIGHT'
       AND CMCDVL = 'N';

    SELECT USARG3
      INTO v_vetime
      FROM CMCDV
     WHERE CMCDKY = 'DAYNIGHT'
       AND CMCDVL = 'D';

    v_rtn := CASE WHEN v_vttime >= v_vstime AND v_vttime < v_vetime
                  THEN 'D' ELSE 'N' END;

    RETURN v_rtn;

END;

/
