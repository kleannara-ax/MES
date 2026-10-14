--------------------------------------------------------
--  DDL for Function FN_RECDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "KNRAMES"."FN_RECDATE" 
( pDateTime DATE )
  RETURN VARCHAR2 
AS 
    RTN       VARCHAR2(30);
	vTime     VARCHAR2(10);
	dDateTime DATE;
	vtTime    VARCHAR2(10);
BEGIN
 /******************************************************************************
1. 작성자 : 김기연
2. 최초 작성 날짜 : 2022년 2월 16일
3. 최종 수정 날짜 : 
4. 기능 : 작업일자 조회
5. 연관 테이블 : TBM0000
6. 연관 폼 : 없음
7. 입력 데이터 :
********************************************************************************/

--	dDateTime := SYSDATE; -- TO_DATE(TO_CHAR( pDateTime, 'YYYY-MM-DD HH24:MI:SS'));
--	vtTime := TO_CHAR(dDateTime, 'HH24:MI:SS'); 

	vtTime := TO_CHAR(pDateTime, 'HH24:MI:SS'); 

	IF ( vtTime < '07:00:00' ) THEN
        dDateTime := pDateTime - 1;
    ELSE
        dDateTime := pDateTime;
    END IF;

	RTN := TO_CHAR(dDateTime, 'YYYYMMDD');

	RETURN RTN ;
	
END FN_RECDATE;

/
