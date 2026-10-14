
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK90_S01" 
(
    P_WERKS         IN VARCHAR2 
    ,P_MACH_CD      IN VARCHAR2
    ,P_WRKDATE      IN VARCHAR2
    ,P_USERID       IN VARCHAR2
    ,Lang           IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE        OUT VARCHAR2 
    ,RS_MSG         OUT VARCHAR2
    ,CUR_1          OUT SYS_REFCURSOR
    ,CUR_2          OUT SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : POP_WRK90
 * PROGRAM NAME  : WMS 전송실패 이력조회
 * VERSION       : 1.0.0
 * DESCRIPTION   : WMS 재전송 대상 목록을 조회한다.
 *                 
 * AUTHOR NAME   : 김기연
 * CREATE DATE   : 2022/10/02
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/10/02    1.0.0   김기연         Initial Version
 *==============================================================================
 *  관련 테이블
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM			VARCHAR2(100)  := 'SP_POP_WRK90_S01';     -- PROCEDURE NAME
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
    V_MACHINE			VARCHAR2(10);

BEGIN
    --예외처리 시작(try)
    BEGIN
	    -- 설비 정보 조회    
        SELECT MACHINE
          INTO V_MACHINE
          FROM TB_MAS012
         WHERE 1=1
           AND MACH_CD = P_MACH_CD;
        --컬럼설정
        V_COLINFO := '자재코드@C^150|자재명@L^300|LOTNO@C^120|개별바코드@C^180|작업지시번호@H|지시순번@H|작업지시번호@C^160|요청번호@C^220';
        V_COLTYPE := 'MATNR@varchar|MATNR_NM@varchar|LOT_NO@varchar|IND_BCD@varchar|ORDER_NO@varchar|ORDER_SEQNO@varchar|WRK_ORDR@varchar|DOC_NO@varchar';
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
			SELECT WM005.MATNR
				 , M001.MATNR_NM 
				 , WM005.LOT_NO 
				 , WM005.IND_BCD 
				 , WM005.ORDER_NO 
				 , WM005.ORDER_SEQNO 
				 , WM005.ORDER_NO || '-' || WM005.ORDER_SEQNO  AS WRK_ORDR
				 , WM005.DOC_NO 
			  FROM TB_IFSWM005 WM005
				 , TB_INV001 I001
			  	 , TB_MAS001 M001
			 WHERE 1=1
			   AND WM005.WERKS = P_WERKS
			   AND WM005.MACHINE = V_MACHINE
			   AND WM005.WERKS = I001.WERKS
			   AND WM005.MATNR = I001.MATNR 
			   AND WM005.LOT_NO = I001.LOT_NO
			   AND WM005.IND_BCD = I001.IND_BCD 
			   AND NVL(I001.CHK_PP_YN,'N') = 'Y'
			   AND WM005.WERKS = M001.WERKS
			   AND WM005.MATNR = M001.MATNR
			   AND WM005.REQ_DT = P_WRKDATE
			   AND NVL(WM005.DOC_NO ,'SUCCESS') != 'SUCCESS' 
			 ORDER BY WM005.IND_BCD ;
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
END SP_POP_WRK90_S01;
/
