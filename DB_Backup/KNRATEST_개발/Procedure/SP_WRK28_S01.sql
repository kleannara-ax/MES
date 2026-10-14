--------------------------------------------------------
--  DDL for Procedure SP_WRK28_S01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_WRK28_S01" (
	P_TYPE           IN    varchar2, -- LIST, SAVE
	P_JSON_STR       IN    CLOB,
	P_SUCCESS       OUT    varchar2,
	P_RS_LIST       OUT    SYS_REFCURSOR 
)
/*==============================================================================
 * PROGRAM ID    : WRK28
 * PROGRAM NAME  : 포장작업 현황 조회
 * VERSION       : 1.0.0
 * DESCRIPTION   : 포장작업 현황를 관리한다.
 *                 
 * AUTHOR NAME   : 김성하
 * CREATE DATE   : 2022/05/27
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}	<생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}		<생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}			<생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}	<생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/05/27    1.0.0   김성하         Initial Version 
 *==============================================================================
 *  관련 테이블
 *        - [TB_INV001] 	: ( R  ) 공정재고 테이블
 *        - [TB_WRK002] 	: ( R  ) 생산실적 테이블
 *        - [TB_MAS012] 	: ( R  ) 설비 마스터 테이블
 *        - [V_WRK_ORDR] 	: ( R  ) 작업지시 뷰(가상 테이블)
 *=============================================================================*/


AS
	V_PRG_NM          	VARCHAR2(100) 	:= 'SP_WRK28_S01';     -- PROCEDURE NAME

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
	V_MACH_CD        	TB_INV001.MACH_CD%TYPE;			--설비코드(호기)
	V_LOC_CD	 		TB_INV001.LOC_CD%TYPE;			--로케이션코드

	V_SQL				CLOB;

BEGIN
	OPEN P_RS_LIST FOR 

	SELECT NULL FROM DUAL WHERE ROWNUM = 0;

	V_JSON 				:= JSON_OBJECT_T.parse(P_JSON_STR);

	V_SESS_USER_ID		:= V_JSON.get_string('SES_USER_ID');
	V_PLT_CD			:= V_JSON.get_string('SES_PLNTKY');

	V_MACH_CD			:= V_JSON.get_string('MACH_CD');	--설비코드(호기)
	V_LOC_CD			:= V_JSON.get_string('LOC_CD');		--로케이션코드

	IF P_TYPE = 'LIST' THEN
		V_SQL := 
		' SELECT 
				INV001.MACH_CD 			AS MACH_CD			--설비코드
			,	MAS012.MACH_NM 			AS MACH_NM			--설비명
			,	WRK002.PRD_DT			AS PRD_DT			--작업일
			,	WRK002.PRD_NO			AS PRD_NO			--생산번호
			,	INV001.LOT_NO			AS LOT_NO			--LOT_NO
			,	INV001.IND_BCD			AS IND_BCD			--개별바코드
			,	WRK_ORDR.DOMESTIC_NM	AS DOMESTIC_NM		--내수구분명
			,	WRK_ORDR.PCODE			AS PCODE			--지종코드
			,	WRK_ORDR.PCODE_NM		AS PCODE_NM			--지종명
			,	WRK_ORDR.BS_WGT			AS BS_WGT			--평량
			,	WRK_ORDR.WLEN			AS WLEN				--가로길이
			,	WRK_ORDR.VLEN			AS VLEN				--세로길이
			,	INV001.ROLLCNT			AS ROLLCNT			--권치수
			,	
				(
				CASE WRK_ORDR.TABLE_NM 
				WHEN ''SCH017'' THEN INV001.STCK_QTY			-- 재단
				WHEN ''SCH018'' THEN INV001.STCK_QTY			-- 포장
				ELSE NULL
				END
				)						AS STCK_QTY			--연수(재고수량)
			,	INV001.WGT 				AS WGT				--중량
			,	WRK002.PRFM_DT			AS PRFM_DT			--생산실적일시
			,	WRK002.MACHINE			AS MACHINE			--생산설비(생산호기)
			,	WRK_ORDR.KUNNR_NM		AS CRSPD_NM			--거래처(판매처)
			,	WRK_ORDR.NTN_NM			AS NTN_NM			--국가명
			,	WRK002.MATNR			AS MATNR			--자재코드
			,	WRK002.VBELN			AS VBELN			--판매오더
			FROM 
				TB_INV001 INV001
			LEFT JOIN TB_WRK002 WRK002 ON (WRK002.IND_BCD = INV001.IND_BCD)
			LEFT JOIN TB_MAS012 MAS012 ON (MAS012.MACH_CD = INV001.MACH_CD)
			LEFT JOIN V_WRK_ORDR WRK_ORDR ON (WRK_ORDR.WRK_ORDR_NO = INV001.WRK_ORDR_NO)
			--LEFT JOIN TB_WRK015 WRK015 ON (WRK015.WERKS = INV001.WERKS AND WRK015.MATNR = INV001.MATNR AND WRK015.LOT_NO = INV001.LOT_NO AND WRK015.IND_BCD = INV001.IND_BCD)
			WHERE 1=1
			';	

			IF (V_MACH_CD IS NOT NULL OR TRIM(V_MACH_CD) != '') THEN
            	V_SQL := V_SQL || ' AND INV001.MACH_CD = ''' || V_MACH_CD || ''''; --설비코드(호기)				      
        	END IF;

        	IF (V_LOC_CD IS NOT NULL OR TRIM(V_LOC_CD) != '') THEN
            	V_SQL := V_SQL || ' AND INV001.LOC_CD = ''' || V_LOC_CD || ''''; --로케이션코드				      
        	END IF;

        	V_SQL := V_SQL || ' ORDER BY INV001.MACH_CD';

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
