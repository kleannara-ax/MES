
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK08_S02" SP_POP_WRK08_S02
(
    P_WERKS      IN VARCHAR2 
    ,P_MACH_CD   IN VARCHAR2 
    ,P_IOTYPE    IN VARCHAR2 
    ,Lang        IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE	 OUT VARCHAR2
    ,RS_MSG		 OUT VARCHAR2
)
/*==============================================================================
 * PROGRAM ID    : POP_WRK08
 * PROGRAM NAME  : 화장지 합지기 주 작업 화면
 * VERSION       : 1.0.1
 * DESCRIPTION   : 현재 작업지시 및 대기 작업지시 목록을 조회한다.
 *                 
 * AUTHOR NAME   : 백우종
 * CREATE DATE   : 2023/05/22
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2023/05/22    1.0.0   백우종         Initial Version
 *==============================================================================
 *  관련 테이블
 * - [TB_WRK011] : (.R..) 작업장(설비)별 현재 진행현황
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM        VARCHAR2(100)  := 'SP_POP_WRK08_S02';     -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID   varchar2(20) := 'TEST'; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);

BEGIN
    --예외처리 시작(try)
    BEGIN
	    SELECT	COUNT(WRK_ORDR_NO)
	    	INTO RS_MSG
	    FROM	TB_WRK011
	    WHERE 	WERKS	= P_WERKS
	    AND		MACH_CD	= P_MACH_CD
	    AND		IN_OUT	= P_IOTYPE
		AND 	NVL(WRK_ORDR_NO, 'NODATA') <> 'NODATA';

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
END;
/
