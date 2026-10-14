--------------------------------------------------------
--  DDL for Procedure SP_WRK09_S01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_WRK09_S01" (
	P_TYPE           IN    varchar2, -- LIST, SAVE
	P_JSON_STR       IN    CLOB,
	P_SUCCESS       OUT    varchar2,
	P_RS_LIST       OUT    SYS_REFCURSOR 
)
/*==============================================================================
 * PROGRAM ID    : SP_WRK09_S01
 * PROGRAM NAME  : 공정창고 재고 현황
 * VERSION       : 1.0.0
 * DESCRIPTION   : 공정창고 재고 현황를 관리한다.
 *                 
 * AUTHOR NAME   : 안상현
 * CREATE DATE   : 2022/05/23
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
 *        - [TB_INV001] : ( R  ) 공정재고 테이블
 *        - [TB_MAS003] : ( R  ) 저장위치 테이블
 *        - [TB_MAS001] : ( R  ) 자재 기준정보 테이블	
 *=============================================================================*/


AS
	V_PRG_NM          	VARCHAR2(100) 	:= 'SP_WRK09_S01';     -- PROCEDURE NAME

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
    V_RANGE_SQL         varchar2(4000);

	-- 조건절 처리용 변수선언 영역
	V_WERKS        		TB_INV001.WERKS%TYPE;			--플랜트코드
	V_STOR_LOC_CD	 	TB_INV001.STOR_LOC_CD%TYPE;		--저장위치코드
	V_IND_BCD	 		TB_INV001.IND_BCD%TYPE;			--개별바코드

	V_SQL				CLOB;
BEGIN
	OPEN P_RS_LIST FOR 

	SELECT NULL FROM DUAL WHERE ROWNUM = 0;

	V_JSON 				:= JSON_OBJECT_T.parse(P_JSON_STR);

	V_SESS_USER_ID		:= V_JSON.get_string('SES_USER_ID');
	V_PLT_CD			:= V_JSON.get_string('SES_PLNTKY');

	V_WERKS				:= V_JSON.get_string('WERKS');			--플랜트코드
	V_STOR_LOC_CD		:= V_JSON.get_string('STOR_LOC_CD');	--저장위치코드
	V_IND_BCD			:= V_JSON.get_string('IND_BCD');		--개별바코드
	V_RANGE_SQL         := V_JSON.get_string('RANGE_SQL');      --자재코드

	IF P_TYPE = 'LIST' THEN
		V_SQL := 
		' SELECT 
				INV001.WERKS 			AS WERKS			--플랜트코드
			,	INV001.STOR_LOC_CD		AS STOR_LOC_CD		--저장위치코드
			,	MAS003.STOR_LOC_NM		AS STOR_LOC_NM		--저장위치명
			,	INV001.MATNR 			AS MATNR			--자재코드
			,	MAS001.MATNR_NM			AS MATNR_NM			--자재명
			,	INV001.IND_BCD			AS IND_BCD			--개별바코드
			,	INV001.LOT_NO			AS LOT_NO			--LOT번호
			,	INV001.UNIT 			AS UNIT				--단위
			,	FN_CD_VAL(''UNIT'', INV001.UNIT) 			AS UNIT_NM			--단위명
			,	INV001.STCK_QTY 		AS STCK_QTY			--재고수량
			,   FN_CD_VAL(''STCK_STA'', INV001.STCK_STA)	STCK_STA			--재고상태
            ,   INV001.UCFMTY_AMT       AS UCFMTY_AMT       --부적합수량
			,	INV001.REGDATE			AS REGDATE			--등록일시
			FROM 
				TB_INV001 INV001
			LEFT JOIN TB_MAS003 MAS003 ON (INV001.STOR_LOC_CD = MAS003.STOR_LOC_CD AND INV001.WERKS = MAS003.WERKS)
			LEFT JOIN TB_MAS001 MAS001 ON (INV001.MATNR = MAS001.MATNR AND INV001.WERKS = MAS001.WERKS)
			--LEFT JOIN CMCDV CMCDV ON (INV001.UNIT = CMCDV.CMCDVL)
			WHERE 1=1
			  --AND CMCDV.CMCDKY = ''UNIT''
			  AND NVL(INV001.STCK_QTY, 0) > 0
   			  AND NVL(INV001.DLFL, ''N'') IN (''N'', ''A'') ';
              

			IF (V_WERKS IS NOT NULL OR TRIM(V_WERKS) != '') THEN
            	V_SQL := V_SQL || ' AND INV001.WERKS = ''' || V_WERKS || ''''; 				--플랜트코드				      
        	END IF;

        	IF (V_STOR_LOC_CD IS NOT NULL OR TRIM(V_STOR_LOC_CD) != '') THEN
            	V_SQL := V_SQL || ' AND INV001.STOR_LOC_CD = ''' || V_STOR_LOC_CD || ''''; 	--저장위치코드				      
        	END IF;

        	IF (V_IND_BCD IS NOT NULL OR TRIM(V_IND_BCD) != '') THEN
            	V_SQL := V_SQL || ' AND INV001.IND_BCD = ''' || V_IND_BCD || ''''; 			--개별바코드				      
        	END IF;

            IF V_RANGE_SQL IS NOT NULL OR TRIM(V_RANGE_SQL) != '' THEN      				--자재코드
                V_SQL := V_SQL || V_RANGE_SQL;
            END IF;

        	V_SQL := V_SQL || ' ORDER BY MATNR';

        IF (V_DEBUG = 'Y') THEN
        	INSERT INTO PROC_LOG (SQL_STR) VALUES (V_SQL);
        END IF;

		OPEN P_RS_LIST FOR V_SQL;

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
