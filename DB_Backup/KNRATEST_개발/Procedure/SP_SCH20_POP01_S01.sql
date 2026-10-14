--------------------------------------------------------
--  DDL for Procedure SP_SCH20_POP01_S01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_SCH20_POP01_S01" (
	P_TYPE           IN    varchar2, -- LIST, SAVE
	P_JSON_STR       IN    CLOB,
	P_SUCCESS       OUT    varchar2,
	P_RS_LIST       OUT    SYS_REFCURSOR 
)
/*==============================================================================
 * PROGRAM ID    : SP_SCH20_POP01_S01
 * PROGRAM NAME  : 사업항목관리(복사)
 * VERSION       : 1.0.0
 * DESCRIPTION   : 사업항목관리(복사)를 관리한다.
 *                 
 * AUTHOR NAME   : 안상현
 * CREATE DATE   : 2022/05/22
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}	<생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}		<생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}			<생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}	<생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/05/22    1.0.0   안상현         Initial Version 
 *==============================================================================
 *  관련 테이블
 *        - [TB_MAS018] : ( R  ) 부서정보
 *        - [TB_MAS030] : ( R  ) 설비별 목표 항목정보 테이블
 *        - [TB_MAS012] : ( R  ) 설비 마스터 정보 테이블
 *        - [CMCDV] 	: ( R  ) 공통코드(ITEM) 테이블
 *=============================================================================*/

AS
	V_PRG_NM          	VARCHAR2(100) 	:= 'SP_SCH20_POP01_S01';     -- PROCEDURE NAME

	-- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  	EXCEPTION;
    E_SQL_ERR_CD      	NUMBER(5) 		:= 0;
    E_SQL_ERR_MSG		VARCHAR2(4000);

   -- JSON을 위한 변수선언 영역
    V_JSON				JSON_OBJECT_T;
    V_ARR_LIST       	JSON_ARRAY_T;
	V_OBJ            	JSON_OBJECT_T;

	-- 세션값 처리용 변수선언 영역
    V_SESS_USER_ID   	varchar2(20);
    V_PLT_CD         	varchar2(2);
   	V_DEBUG          	varchar2(1);

	-- 조건절 처리용 변수선언 영역
	V_PLN_YR        	TB_MAS030.PLN_YR%TYPE;			--계획년도
	V_CP_PLN_YR	 		TB_MAS030.PLN_YR%TYPE;			--복사계획년도

	-- 리스트(그리드)의 값을 할당하기 위한 변수선언 영역
	V_WERKS				TB_MAS030.WERKS%TYPE;			--플랜트코드
	V_MACH_CD			TB_MAS030.MACH_CD%TYPE;			--설비코드
	V_MGMT_ITEM_CD		TB_MAS030.MGMT_ITEM_CD%TYPE;	--관리항목코드
	V_MGMT_ITEM_NM		TB_MAS030.MGMT_ITEM_NM%TYPE;	--관리항목명
	V_UNIT				TB_MAS030.UNIT%TYPE;			--단위
	V_COMPKY			TB_MAS030.COMPKY%TYPE;			--회사코드
	V_MGMT_DEPT_ID		TB_MAS030.MGMT_DEPT_ID%TYPE;	--부서코드
	V_USE_YN			TB_MAS030.USE_YN%TYPE;			--사용여부

	V_SQL				CLOB;
BEGIN
	OPEN P_RS_LIST FOR 

	-- 이게 왜 필요한지 질문
	SELECT NULL FROM DUAL WHERE ROWNUM = 0;

	V_JSON 				:= JSON_OBJECT_T.parse(P_JSON_STR);

	V_SESS_USER_ID		:= V_JSON.get_string('SES_USER_ID');
	V_PLT_CD			:= V_JSON.get_string('SES_PLNTKY');

	V_PLN_YR			:= V_JSON.get_string('PLN_YR');	--계획년도
	V_CP_PLN_YR			:= V_JSON.get_string('CP_PLN_YR');	--복사년도

	IF P_TYPE = 'LIST' THEN

		-- = 와 :=의 차이 질문
		V_SQL := 
		' SELECT 
				MAS030.PLN_YR 			AS PLN_YR			--계획연도
			,	MAS030.WERKS 			AS WERKS			--플랜트
			,	MAS030.MACH_CD 			AS MACH_CD			--설비코드
			,	MAS012.MACH_NM 			AS MACH_NM			--설비명
			,	MAS030.MGMT_ITEM_CD 	AS MGMT_ITEM_CD 	--관리항목코드
			,	MAS030.MGMT_ITEM_NM 	AS MGMT_ITEM_NM		--관리항목명
			,	MAS030.UNIT				AS UNIT				--단위코드
			, 	CMCDV.CDESC1	        AS UNIT_NM	       	--단위명
			,	MAS030.COMPKY			AS COMPKY			--회사코드
			,	MAS030.USE_YN			AS USE_YN			--사용여부
			,	MAS030.MGMT_DEPT_ID		AS DEPT_CD			--부서코드
			,	MAS018.DEPT_KR_NM		AS DEPT_KR_NM 		--부서명(국문)
			FROM 
				TB_MAS030 MAS030
			,	TB_MAS018 MAS018
			,	TB_MAS012 MAS012
			, 	CMCDV CMCDV
			WHERE 1=1
			AND MAS030.MGMT_DEPT_ID = MAS018.DEPT_CD(+)
			AND MAS030.MACH_CD = MAS012.MACH_CD(+)
			AND CMCDV.CMCDVL = MAS030.UNIT(+)
			AND CMCDV.CMCDKY = ''UNIT'' 
			AND MAS030.USE_YN = ''Y'' ';	

			IF (V_PLN_YR IS NOT NULL OR TRIM(V_PLN_YR) != '') THEN
            	V_SQL := V_SQL || ' AND MAS030.PLN_YR = ''' || V_PLN_YR || '''';				   --플랜트   
        	END IF;

        	V_SQL := V_SQL || ' ORDER BY MAS030.MACH_CD';

        IF (V_DEBUG = 'Y') THEN
        	INSERT INTO PROC_LOG (SQL_STR) VALUES (V_SQL);
        END IF;

		OPEN P_RS_LIST FOR V_SQL;

	ELSIF P_TYPE = 'SAVE' THEN

		--기존의 복사년도 삭제
		DELETE FROM TB_MAS030 WHERE PLN_YR = V_CP_PLN_YR;

		V_ARR_LIST 			:= V_JSON.get_array('list');

		FOR i IN 0..V_ARR_LIST.get_size-1 LOOP
			V_OBJ			:= TREAT(V_ARR_LIST.get(i) AS json_object_t);  
			V_OBJ			:= TREAT(V_OBJ.get('map') AS json_object_t);

			V_WERKS	        := V_OBJ.get_string('WERKS'); 			--플랜트코드
          	V_MACH_CD		:= V_OBJ.get_string('MACH_CD'); 		--설비코드
          	V_MGMT_ITEM_CD	:= V_OBJ.get_string('MGMT_ITEM_CD'); 	--관리항목코드
          	V_MGMT_ITEM_NM	:= V_OBJ.get_string('MGMT_ITEM_NM'); 	--관리항목명
			V_UNIT			:= V_OBJ.get_string('UNIT'); 			--단위
			V_COMPKY		:= V_OBJ.get_string('COMPKY'); 			--회사코드
			V_MGMT_DEPT_ID	:= V_OBJ.get_string('DEPT_CD'); 		--부서코드
			V_USE_YN		:= V_OBJ.get_string('USE_YN'); 			--사용여부

			INSERT INTO TB_MAS030(
				PLN_YR				--계획년도(복사할년도)
			, 	WERKS				--플랜트코드
			,	MACH_CD				--설비코드 
			,	MGMT_ITEM_CD		--관리항목코드
			,	MGMT_ITEM_NM		--관리항목명
			,	UNIT				--단위
			,	COMPKY				--회사코드
			,	MGMT_DEPT_ID		--부서코드
			,	USE_YN				--사용여부
			,	REGDATE				--등록일자
			,	REGID				--등록자
			) 
			VALUES(
				V_CP_PLN_YR			--복사할년도
			, 	V_WERKS				--플랜트코드
			, 	V_MACH_CD			--설비코드
			,	V_MGMT_ITEM_CD		--관리항목코드
			, 	V_MGMT_ITEM_NM		--관리항목명
			, 	V_UNIT				--단위 
			, 	V_COMPKY			--회사코드
			, 	V_MGMT_DEPT_ID		--부서코드
			, 	V_USE_YN			--사용여부
			, 	SYSDATE				--등록일자
			, 	V_SESS_USER_ID		--등록자
			);

		END LOOP;

	END IF;

	P_SUCCESS := 'Y';	

	EXCEPTION
    WHEN E_EXCEPTION_USER THEN

    	-- 에러 내역 SET
    	P_SUCCESS           := 'N';
        E_SQL_ERR_CD        := SQLCODE;
		E_SQL_ERR_MSG       := SUBSTRB(SQLERRM,1,300);

		ROLLBACK;
		SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);

	WHEN OTHERS THEN
		P_SUCCESS			:= 'N';
        E_SQL_ERR_CD        := SQLCODE;
		E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

		ROLLBACK;
		RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
END;


/
