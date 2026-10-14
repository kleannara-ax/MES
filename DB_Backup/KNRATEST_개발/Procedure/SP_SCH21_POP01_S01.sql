--------------------------------------------------------
--  DDL for Procedure SP_SCH21_POP01_S01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_SCH21_POP01_S01" (
	P_TYPE           IN    varchar2, -- LIST, SAVE
	P_JSON_STR       IN    CLOB,
	P_SUCCESS       OUT    varchar2,
	P_RS_LIST       OUT    SYS_REFCURSOR 
)
/*==============================================================================
 * PROGRAM ID    : SP_SCH21_POP01_S01
 * PROGRAM NAME  : 사업목표관리(복사)
 * VERSION       : 1.0.0
 * DESCRIPTION   : 사업목표관리(복사)를 관리한다.
 *                 
 * AUTHOR NAME   : 안상현
 * CREATE DATE   : 2022/06/17
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
 *        - [TB_MAS031] : (CRU ) 설비별 사업목표정보 테이블
 *        - [TB_MAS030] : ( R  ) 설비별 사업항목정보 테이블
 *        - [TB_MAS012] : ( R  ) 설비 마스트 정보 테이블
 *        - [TB_MAS018] : ( R  ) 부서정보 테이블
 *        - [CMCDV] 	: ( R  ) 공통코드(ITEM) 테이블
 *=============================================================================*/

AS
	V_PRG_NM          	VARCHAR2(100) 	:= 'SP_SCH21_POP01_S01';     -- PROCEDURE NAME

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
	V_PLN_YR        	TB_MAS030.PLN_YR%TYPE;				--계획년도
	V_PLN_MM        	TB_MAS031.PLN_MM%TYPE;				--계획월
	V_CP_PLN_MM	 		TB_MAS031.PLN_MM%TYPE;				--복사계획월

	-- 저장 유효성 검사를 위한 변수
	/*
	V_CNT				NUMBER;								--복사할 계획년도의 사업항목 개수
	V_REST_CNT			NUMBER;								--복사할 계획년도와 계획년도의 사업항목 개수 일치하는지 여부
	*/
	V_YN				CHAR;								--구분자

	-- 리스트(그리드)의 값을 할당하기 위한 변수선언 영역
	V_MACH_CD			TB_MAS030.MACH_CD%TYPE;				--설비코드
	V_SQL				CLOB;
BEGIN
	OPEN P_RS_LIST FOR 
	SELECT NULL FROM DUAL WHERE ROWNUM = 0;

	V_JSON 				:= JSON_OBJECT_T.parse(P_JSON_STR);

	V_SESS_USER_ID		:= V_JSON.get_string('SES_USER_ID');
	V_PLT_CD			:= V_JSON.get_string('SES_PLNTKY');

	V_PLN_YR			:= V_JSON.get_string('PLN_YR');		--계획년도
	V_PLN_MM			:= V_JSON.get_string('PLN_MM');		--계획월
	V_CP_PLN_MM			:= V_JSON.get_string('CP_PLN_MM');	--복사계획월
	V_YN				:= V_JSON.get_string('YN');			--데이터를 판별할 구분자

	IF P_TYPE = 'LIST' THEN

		V_SQL := 
		' SELECT 
				MAS031.WERKS 					AS WERKS			--플랜트
			,	MAS031.MACH_CD 					AS MACH_CD 			--설비코드
			,	MAS012.MACH_NM 					AS MACH_NM			--설비명
			, 	MAS012.MACH_SHRT_NM         	AS MACH_SHRT_NM    	--설비명(단축)
			,	MAS031.MGMT_ITEM_CD 			AS MGMT_ITEM_CD		--관리항목코드
			,	MAS030.MGMT_ITEM_NM				AS MGMT_ITEM_NM		--관리항목명
			,	MAS030.MGMT_DEPT_ID 			AS MGMT_DEPT_ID		--부서코드
			,	MAS018.DEPT_KR_NM 				AS DEPT_NM			--부서명
			, 	MAS030.UNIT                 	AS UNIT           	--단위코드
			, 	CMCDV.CDESC1	           		AS UNIT_NM	       	--단위명
			, 	NVL(MAS031.BUSI_PLN_AMT,0)  	AS BUSI_PLN_AMT    	--사업계획량        
			, 	NVL(MAS031.EXCTN_PLN_AMT,0) 	AS EXCTN_PLN_AMT   	--실행계획량
			FROM 
				TB_MAS031 MAS031
			INNER JOIN TB_MAS030 MAS030 ON (MAS030.PLN_YR = MAS031.PLN_YR AND MAS030.MACH_CD = MAS031.MACH_CD AND MAS030.MGMT_ITEM_CD = MAS031.MGMT_ITEM_CD)
			LEFT JOIN TB_MAS012 MAS012 ON (MAS012.MACH_CD = MAS031.MACH_CD)
			LEFT JOIN TB_MAS018 MAS018 ON (MAS018.DEPT_CD = MAS030.MGMT_DEPT_ID)
			LEFT JOIN CMCDV CMCDV ON (CMCDV.CMCDVL = MAS030.UNIT)
			WHERE 1=1
			AND CMCDV.CMCDKY = ''UNIT'' ';

		IF V_PLN_YR IS NOT NULL OR TRIM(V_PLN_YR) != '' THEN
            V_SQL := V_SQL || ' AND MAS031.PLN_YR = ''' || V_PLN_YR || ''''; --계획년도   
        END IF;

		IF V_PLN_MM IS NOT NULL OR TRIM(V_PLN_MM) != '' THEN
            V_SQL := V_SQL || ' AND MAS031.PLN_MM = ''' || V_PLN_MM || ''''; --계획월 
        END IF;

       	V_SQL := V_SQL || ' ORDER BY MAS031.MACH_CD';  

        IF (V_DEBUG = 'Y') THEN
        	INSERT INTO PROC_LOG (SQL_STR) VALUES (V_SQL);
        END IF;

		OPEN P_RS_LIST FOR V_SQL;

	ELSIF P_TYPE = 'SAVE' THEN

		V_ARR_LIST 			:= V_JSON.get_array('list');

		FOR i IN 0..V_ARR_LIST.get_size-1 LOOP
			V_OBJ				:= TREAT(V_ARR_LIST.get(i) AS json_object_t);  
			V_OBJ				:= TREAT(V_OBJ.get('map') AS json_object_t);

			V_MACH_CD			:= V_OBJ.get_string('MACH_CD'); 		--설비코드

            BEGIN
	            IF V_YN = 'N' THEN
	            	-- 설비별 사업항목 존재여부
	            	/*
					SELECT 
						DECODE(COUNT(*), 0, 'Y', 'N') INTO P_SUCCESS 
					FROM 
						TB_MAS030 MAS030 
					WHERE 1=1
					AND MAS030.PLN_YR = V_PLN_YR
					AND MAS030.MACH_CD = V_MACH_CD;

					IF P_SUCCESS = 'N' THEN
						RETURN;
					END IF;
					*/
					-- 설비별 월별 사업목표 존재여부
					SELECT 
						DECODE(COUNT(*), 0, 'Y', 'N') INTO P_SUCCESS 
					FROM 
						TB_MAS031 MAS031
					WHERE 1=1
					AND MAS031.PLN_YR = V_PLN_YR
					AND MAS031.PLN_MM = V_CP_PLN_MM
					AND MAS031.MACH_CD = V_MACH_CD;

					IF P_SUCCESS = 'N' THEN
						RETURN;
					END IF;

				ELSIF V_YN = 'Y' THEN
					/*
					-- 복사계획월 사업항목 삭제
					DELETE 
					FROM 
						TB_MAS030 MAS030
					WHERE 1=1
					AND MAS030.PLN_YR = V_PLN_YR
					AND MAS030.MACH_CD = V_MACH_CD;

					-- 복사계획월 사업항목 등록
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
					SELECT 
						MAS030.PLN_YR				--계획년도(복사할년도)
					, 	MAS030.WERKS				--플랜트코드
					,	V_MACH_CD					--설비코드 
					,	MAS030.MGMT_ITEM_CD			--관리항목코드
					,	MAS030.MGMT_ITEM_NM			--관리항목명
					,	MAS030.UNIT					--단위
					,	MAS030.COMPKY				--회사코드
					,	MAS030.MGMT_DEPT_ID			--부서코드
					,	MAS030.USE_YN				--사용여부
					,	MAS030.REGDATE				--등록일자
					,	MAS030.REGID				--등록자
					FROM 
						TB_MAS030 MAS030
					WHERE 1=1
					AND MAS030.PLN_YR = V_PLN_YR
					AND MAS030.MACH_CD = V_MACH_CD;
					*/
					-- 복사계획월 사업목표 DELETE
		            DELETE 
		            FROM 
		            	TB_MAS031 MAS031 
		            WHERE 1=1
		            AND MAS031.PLN_YR = V_PLN_YR
		            AND MAS031.PLN_MM = V_CP_PLN_MM
		            AND MAS031.MACH_CD = V_MACH_CD;

		           	-- 복사계획월 사업목표 INSERT
		            INSERT INTO TB_MAS031
					(               
						PLN_YR	        	--계획년도
					,	WERKS	        	--플랜트
					,	MACH_CD	    		--설비코드
					,	MGMT_ITEM_CD		--관리항목코드
					,	PLN_MM	        	--계획월
					,	BUSI_PLN_AMT		--사업계획량
					,	EXCTN_PLN_AMT		--실행계획량
					,	REGDATE	    		--등록일시
					,	REGID	        	--등록자ID
					,	UPDDATE	    		--수정일시
					,	UPDID	        	--수정자ID
					)
					SELECT
						MAS031.PLN_YR 
					,	MAS031.WERKS
					,	V_MACH_CD
					,	MAS031.MGMT_ITEM_CD
					,	V_CP_PLN_MM
					,	MAS031.BUSI_PLN_AMT
					,	MAS031.EXCTN_PLN_AMT
					,	SYSDATE	        	
					,	V_SESS_USER_ID	    
					,	NULL	            
					,	NULL	            
					FROM 
						TB_MAS031 MAS031
					WHERE 1=1
					AND MAS031.PLN_YR = V_PLN_YR
					AND MAS031.PLN_MM = V_PLN_MM
					AND MAS031.MACH_CD = V_MACH_CD;

				END IF;

			END; 

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
