
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK29_S04" 
(
     P_WERKS            IN VARCHAR2 
    ,P_MACH_CD          IN VARCHAR2 
    ,P_WRK_ORDR_NO      IN VARCHAR2             
    ,P_WRK_ORDR_SEQNO   IN VARCHAR2             
    ,P_IND_BCD			IN VARCHAR2
    ,Lang           	IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE            OUT VARCHAR2 
    ,RS_MSG             OUT VARCHAR2
)
/*==============================================================================
 * PROGRAM ID    : POP_WRK29
 * PROGRAM NAME  : PS 수재단 완료 처리하여 실적 등록시 남은 연수가 있는지 검사
 * VERSION       : 1.0.1
 * DESCRIPTION   : 수재단 완료 여부 체크
 *                 
 * AUTHOR NAME   : 백우종
 * CREATE DATE   : 2023/12/26
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
  *==============================================================================
 *  관련 테이블
 * - [TB_SCH016] : (.R..) 제지 수재단 작업지시
 * - [TB_MAS001] : (.R..) 자재 기준 정보
 * - [TB_WRK001] : (.R..) 설비별 현재 진행현황
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM        VARCHAR2(100)  := 'SP_POP_WRK29_S04';     -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID   varchar2(20) := 'TEST'; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);
    --내부변수 관리

    V_IN_PCNT         NUMBER;
    V_PCNT            NUMBER;
    V_WRK_ORDR_QTY    NUMBER;   --계획 연수

	V_REMAIN_QTY	  NUMBER(13, 3);
BEGIN
    BEGIN
        -- 수재단 완료가 아닌 경우 현재 투입되어 있는 재고와 실적을 확인하여 일치할 때(가용이 0이 될 때) 수재단 완료 처리
        V_REMAIN_QTY := 0;

--        SELECT	NVL(SUM(STCK_QTY), 0)	INTO	V_REMAIN_QTY
--    	FROM	TB_INV003
--    	WHERE	WERKS = P_WERKS
--    	AND		MACH_CD = P_MACH_CD
--    	AND		WRK_ORDR_NO = P_WRK_ORDR_NO
--    	AND		WRK_ORDR_SEQNO = TO_NUMBER(P_WRK_ORDR_SEQNO);

DBMS_OUTPUT.PUT_LINE ('P_WERKS = ' || P_WERKS);
DBMS_OUTPUT.PUT_LINE ('P_MACH_CD = ' || P_MACH_CD);
DBMS_OUTPUT.PUT_LINE ('P_WRK_ORDR_NO = ' || P_WRK_ORDR_NO);
DBMS_OUTPUT.PUT_LINE ('P_WRK_ORDR_SEQNO = ' || P_WRK_ORDR_SEQNO);
DBMS_OUTPUT.PUT_LINE ('P_IND_BCD = ' || P_IND_BCD);
        SELECT NVL(COUNT(*), 0)	INTO	V_REMAIN_QTY
        FROM	TB_INV003
        WHERE	WERKS = P_WERKS
    	AND		MACH_CD = P_MACH_CD
    	AND		WRK_ORDR_NO = P_WRK_ORDR_NO
    	AND		WRK_ORDR_SEQNO = TO_NUMBER(P_WRK_ORDR_SEQNO)
        AND		IND_BCD	<>	P_IND_BCD
        AND		USE_QTY = 0;

DBMS_OUTPUT.PUT_LINE ('V_REMAIN_QTY = ' || V_REMAIN_QTY);
        IF	V_REMAIN_QTY > 0	THEN
	    	RS_MSG := V_REMAIN_QTY;
	        RS_CODE := 'S';
        ELSE
	    	RS_MSG := V_REMAIN_QTY;
	        RS_CODE := 'E';		-- 임시로 S 로 변경
        END IF;
--    	RS_MSG := V_REMAIN_QTY;
--        RS_CODE := 'S';
--        RS_MSG := '';
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
        --RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
        RAISE;
        RS_CODE := 'E';
        RS_MSG  := SQLERRM;
        RETURN;
    --예외처리 종료
    END;
END;
/
