--------------------------------------------------------
--  DDL for Procedure SP_POP_WRK89_S01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK89_S01" 
(
    P_WERKS         IN VARCHAR2 
    ,P_MACH_CD      IN VARCHAR2
    ,P_USERID       IN VARCHAR2
    ,Lang           IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE        OUT VARCHAR2 
    ,RS_MSG         OUT VARCHAR2
    ,CUR_1          OUT SYS_REFCURSOR
    ,CUR_2          OUT SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : POP_WRK89
 * PROGRAM NAME  : SAP 전송실패 이력조회
 * VERSION       : 1.0.0
 * DESCRIPTION   : SAP 재전송 대상 목록을 조회한다.
 *                 
 * AUTHOR NAME   : 김기연
 * CREATE DATE   : 2022/09/17
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/09/17    1.0.0   김기연         Initial Version
 *==============================================================================
 *  관련 테이블
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM			VARCHAR2(100)  := 'SP_POP_WRK89_S01';     -- PROCEDURE NAME
    V_PLT_CD			VARCHAR2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID		VARCHAR2(20) := P_USERID; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER	EXCEPTION;
    E_SQL_ERR_CD		NUMBER(5) := 0;
    E_SQL_ERR_MSG		VARCHAR2(4000);
    --파라미터 처리
    --내부변수 관리
    V_COLINFO			VARCHAR2(1000);
    V_COLTYPE			VARCHAR2(1000);

BEGIN
    --예외처리 시작(try)
    BEGIN
        --컬럼설정
        V_COLINFO := '구분코드@H|구분@C^150|자재코드@C^150|자재명@L^200|LOTNO@C^120|개별바코드@C^180|작업지시번호@H|지시순번@H|작업지시번호@C^200|오더번호@C^130';
        V_COLTYPE := 'DOC_DIV@varchar|DIV_NM@varchar|MATNR@varchar|MATNR_NM@varchar|LOT_NO@varchar|IND_BCD@varchar|WRK_ORDR_NO@varchar|WRK_ORDR_SEQNO@varchar|WRK_ORDR@varchar|ORDER_NO@varchar';
        --컬럼설정 반환 테이블 작성
        OPEN CUR_1 FOR
        SELECT RTN_VALUES FROM FN_SPLIT(V_COLINFO||','||V_COLTYPE,',');

       	--PS 조회
       	IF P_WERKS = 'P100' THEN
       		RETURN;
       	--HL 조회
       	ELSE
	        --결과 테이블 반환용 변수
	        OPEN CUR_2 FOR
	        --SAP 전송목록 조회
			SELECT W021.DOC_DIV AS DOC_DIV
				 , CMCDV.CDESC1 AS DIV_NM
				 , W001.MATNR
				 , M001.MATNR_NM 
				 , W021.LOT_NO 
				 , W021.IND_BCD 
				 , W021.WRK_ORDR_NO 
				 , W021.WRK_ORDR_SEQNO 
				 , W021.WRK_ORDR_NO || '-' || W021.WRK_ORDR_SEQNO  AS WRK_ORDR
				 , W021.ORDER_NO 
			  FROM TB_WRK021 W021
			  	 , CMCDV CMCDV
			  	 , TB_WRK001 W001
			  	 , TB_MAS001 M001
			 WHERE 1=1
			   AND CMCDV.CMCDKY = 'DOC_DIV'
			   AND W021.DOC_DIV = CMCDV.CMCDVL 
			   AND W021.WERKS = W001.WERKS
			   AND W021.MACH_CD = W001.MACH_CD
			   AND W021.IND_BCD = W001.IND_BCD
			   AND W001.WERKS = M001.WERKS
			   AND W001.MATNR = M001.MATNR
			   AND W021.WERKS = P_WERKS
			   AND W021.MACH_CD  = P_MACH_CD
			   AND NVL(W021.SDOC_NO,'E') = 'E' 
			 ORDER BY W021.REGDATE, W021.DOC_DIV;
		END IF;
	
        --작업 정상 종료 코드 등록
        RS_CODE := 'S';
    --예외처리(catch)
    EXCEPTION
    WHEN E_EXCEPTION_USER THEN
        -- 에러 내역 SET
        E_SQL_ERR_CD        := SQLCODE;
        E_SQL_ERR_MSG       := SUBSTRB(SQLERRM,1,300);

        ROLLBACK;
        SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);

        RS_CODE := 'E';
        RS_MSG  := SQLERRM;
        RETURN;
    WHEN OTHERS THEN
        E_SQL_ERR_CD        := SQLCODE;
        E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

        ROLLBACK;
        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);

        RS_CODE := 'E';
        RS_MSG  := SQLERRM;
        RETURN;
    --예외처리 종료
    END;
END SP_POP_WRK89_S01;

/
