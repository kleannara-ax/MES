
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK51_U02" SP_POP_WRK51_U02
(
    P_WERKS             IN VARCHAR2
    ,P_MACH_CD          IN VARCHAR2 
    ,P_IOTYPE           IN VARCHAR2 
    ,P_USERID           IN VARCHAR2 
    ,P_WRK_ORDR_NO      IN VARCHAR2 
    ,P_WRK_ORDR_SEQNO   IN VARCHAR2 
    ,Lang               IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE            OUT VARCHAR2 
    ,RS_MSG             OUT VARCHAR2
)
/*==============================================================================
 * PROGRAM ID    : POP_WRK51
 * PROGRAM NAME  : 판매용 원단 에서 합지기 화면으로 화면전환 시 대표 작업지시를 TB_WRK011에서 해제
 * VERSION       : 1.0.0
 * DESCRIPTION   : 화면전환 시 (판매용 -> 합지가) 설비에 선택되어 있는 작업지시를 클리어 한다.
 *                 
 * AUTHOR NAME   : 백우종
 * CREATE DATE   : 2023/05/01
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2023/05/01    1.0.0   백우종         Initial Version
 *==============================================================================
 *  관련 테이블
 * - [TB_SCH011] : (..U.) 화장지 합지기 작업지시
 * - [TB_WRK012] : (C.U.) 작업장별 가동 현황
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM            VARCHAR2(100)  := 'SP_POP_WRK51_U02';     -- PROCEDURE NAME
    V_PLT_CD            VARCHAR2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID      VARCHAR2(20) := P_USERID; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD        NUMBER(5) := 0;
    E_SQL_ERR_MSG       VARCHAR2(4000);
    --parameter변수 처리
    V_WRK_ORDR_SEQNO    NUMBER(5,0) := TO_NUMBER(P_WRK_ORDR_SEQNO);
    --내부 변수 등록
    V_DATE              DATE := SYSDATE;

BEGIN
    --예외처리 시작(try)
    BEGIN
        BEGIN
	        -- TB_WRK011 작업지시 번호 수정
	        UPDATE	TB_WRK011
	        	SET	MACH_STA = 'S'
	        	  , PRE_WRK_ORDR_NO = P_WRK_ORDR_NO
	        	  , PRE_WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
	        	  , WRK_ORDR_NO = ''
	        	  , WRK_ORDR_SEQNO = ''
	              , UPDDATE = V_DATE
	              , UPDID = P_USERID
	         WHERE 1=1
	           AND WERKS = P_WERKS
	           AND MACH_CD = P_MACH_CD
	           AND IN_OUT = P_IOTYPE
	           AND WRK_ORDR_NO = P_WRK_ORDR_NO
	           AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO; 
            --작업 정상 종료 코드 등록
            RS_CODE := 'S';
        END;
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
        E_SQL_ERR_CD        := -20001;
        E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

        ROLLBACK;
        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);

        RS_CODE := 'E';
        RS_MSG  := SQLERRM;
        RETURN;
    --예외처리 종료
    END;
END ;
/
