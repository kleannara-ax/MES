--------------------------------------------------------
--  DDL for Procedure SP_WRK52_S01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_WRK52_S01" (
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
	V_PRG_NM          	VARCHAR2(100) 	:= 'SP_WRK52_S01';     -- PROCEDURE NAME

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
	V_MACH_CD        	TB_LAMI_PC.MACH_CD%TYPE;			--설비코드(호기)
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
				A.MACH_CD 			AS MACH_CD			--설비코드
            ,	C.MACH_NM 			AS MACH_NM			--설비명

			,	SUBSTR(A.PRD_END_DTM,1,8)			AS PRD_DT			--작업일
			,	A.ORDER_NO			AS PRD_NO			--생산번호
			,	A.IND_BCD			AS IND_BCD			--개별바코드
			,	NVL(D.DOMESTIC_NM,'''')	AS DOMESTIC_NM		--내수구분명

			,	A.PPCODE			AS PCODE			--지종코드
			,	D.PCODE_NM		AS PCODE_NM			--지종명
			,	D.BS_WGT			AS BS_WGT			--평량
			,	D.WLEN			AS WLEN				--가로길이
			,	D.VLEN			AS VLEN				--세로길이

            ,	E.STCK_QTY  as STCK_QTY
			,	A.WRK_ORDR_QTY 				AS WGT					--중량
			,	TO_CHAR(A.PRD_LAST_DATE,''YYYYMMDD'')			AS PRFM_DT
            ,	A.MACH_CD			AS MACHINE			--생산설비(생산호기)

			,	D.KUNNR_NM		AS CRSPD_NM			--거래처(판매처)
			,	D.NTN_NM			AS NTN_NM			--국가명
			,	A.MATNR			AS MATNR			--자재코드
			,	A.VBELN			AS VBELN			--판매오더
			FROM 
			TB_LAMI_PC A
--			LEFT JOIN TB_LAMI_RESULT B ON A.WRK_ORDR_SEQNO = B.WRK_ORDR_SEQNO
            LEFT JOIN TB_MAS012 C ON A.MACH_CD = C.MACH_CD
			LEFT JOIN V_WRK_ORDR D ON A.WRK_ORDR_NO = D.WRK_ORDR_NO AND A.WRK_ORDR_SEQNO = D.WRK_ORDR_SEQNO
            INNER JOIN TB_INV003 E ON A.WRK_ORDR_NO = E.WRK_ORDR_NO AND A.WRK_ORDR_SEQNO = E.WRK_ORDR_SEQNO
            WHERE 1=1
            AND A.MACH_CD = ''' || V_MACH_CD || '''
			';	

--            IF (V_MACH_CD IS NOT NULL OR TRIM(V_MACH_CD) != '') THEN
--                V_SQL := V_SQL || ' AND A.MACH_CD = ''' || V_MACH_CD || ''''; --설비코드(호기)				      
--            END IF;

--            IF (V_LOC_CD IS NOT NULL OR TRIM(V_LOC_CD) != '') THEN
--                V_SQL := V_SQL || ' AND A.LOC_CD = ''' || V_LOC_CD || ''''; --설비코드(호기)				      
--            END IF;

        V_SQL := V_SQL || '
            GROUP BY
				A.MACH_CD
            ,	C.MACH_NM
			,	SUBSTR(A.PRD_END_DTM,1,8)
			,	A.ORDER_NO
			,	A.IND_BCD
			,	NVL(D.DOMESTIC_NM,'''')
			,	A.PPCODE
			,	D.PCODE_NM
			,	D.BS_WGT
			,	D.WLEN
			,	D.VLEN
            ,	E.STCK_QTY
			,	A.WRK_ORDR_QTY
			,	TO_CHAR(A.PRD_LAST_DATE,''YYYYMMDD'')
            ,	A.MACH_CD
			,	D.KUNNR_NM
			,	D.NTN_NM
			,	A.MATNR
			,	A.VBELN

        ORDER BY A.MACH_CD';

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
        E_SQL_ERR_CD      := SQLCODE;
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
