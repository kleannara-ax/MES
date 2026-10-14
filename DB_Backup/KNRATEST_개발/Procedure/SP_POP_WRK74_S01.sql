--------------------------------------------------------
--  DDL for Procedure SP_POP_WRK74_S01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK74_S01" 
(
    P_WERKS     IN VARCHAR2 
    ,P_PROC_CD    IN VARCHAR2 
    ,P_RUN_STA   IN VARCHAR2
    ,Lang        IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE     OUT VARCHAR2 
    ,RS_MSG      OUT VARCHAR2
    ,CUR_1       OUT SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : POP_WRK74
 * PROGRAM NAME  : 라미네이팅 비가동 등록
 * VERSION       : 1.0.1
 * DESCRIPTION   : 비가동 항목목록을 조회한다.
 *                 
 * AUTHOR NAME   : 김기연
 * CREATE DATE   : 2022/04/20
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/04/20    1.0.0   김기연         Initial Version
 * 2022/05/03    1.0.1   김기연         관련 테이블 변경(TB_MAS017->USRMA)
 *==============================================================================
 *  관련 테이블
 * - [USRMA] : (.R..) 사용자 관리
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM        VARCHAR2(100)  := 'SP_POP_WRK74_S01';     -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID   varchar2(20) := 'TEST'; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);
    --parameter변수 처리
    V_PROC_CD   VARCHAR2(10) := P_PROC_CD;

BEGIN
    --예외처리 시작(try)
    BEGIN
        BEGIN
            --결과 테이블 반환용 변수
            OPEN CUR_1 FOR
            --설비호기 목록 조회
            SELECT DISTINCT
                   M021.ABN_CD --비가동 코드
                 , M020.ABN_NM --비가동 명
                 , 'N' --초기 선택여부
                 , 'Y' --사용 여부
            FROM TB_MAS020 M020, TB_MAS021 M021
            WHERE 1=1
              AND M020.WERKS = P_WERKS
              AND M021.ABN_CD = M020.ABN_CD(+)
              AND M021.PROC_CD = V_PROC_CD
              AND M020.RUN_STA = P_RUN_STA
            ORDER BY M021.ABN_CD;
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
        E_SQL_ERR_CD        := SQLCODE;
        E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

        ROLLBACK;
        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);

        RS_CODE := 'E';
        RS_MSG  := SQLERRM;
        RETURN;
    --예외처리 종료
    END;
END SP_POP_WRK74_S01;

/
