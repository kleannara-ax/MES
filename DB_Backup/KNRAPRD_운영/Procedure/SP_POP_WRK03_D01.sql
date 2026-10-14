--------------------------------------------------------
--  DDL for Procedure SP_POP_WRK03_D01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK03_D01" 
(
    P_WERKS     IN VARCHAR2
    ,P_MACH_CD  IN VARCHAR2
    ,P_LIST     IN VARCHAR2
    ,P_USERID   IN VARCHAR2
    ,Lang       IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE    OUT VARCHAR2 
    ,RS_MSG     OUT VARCHAR2
)
/*==============================================================================
 * PROGRAM ID    : POP_WRK03
 * PROGRAM NAME  : 비가동 이력 조회
 * VERSION       : 1.0.0
 * DESCRIPTION   : 선택된 비가동 이력을 취소처리한다.
 *                 
 * AUTHOR NAME   : 김기연
 * CREATE DATE   : 2022/05/04
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/05/04    1.0.0   김기연         Initial Version 
 *==============================================================================
 *  관련 테이블
 * - [TB_WRK011] : (..U.) 작업장 현황
 * - [TB_WRK013] : (..U.) 작업자 투입 현황
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM        VARCHAR2(100)  := 'SP_POP_WRK03_D01';     -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID   varchar2(20) := P_USERID; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);
    --내부 변수 등록
    V_DATE      DATE := SYSDATE;

BEGIN
    --예외처리 시작(try)
    BEGIN
        BEGIN
            -- 비가동 이력 수정
            UPDATE TB_WRK003
               SET RMK = RMK || '/ 취소처리' 
                 , UPDDATE = V_DATE
                 , UPDID = P_USERID
             WHERE 1=1
               AND WERKS = P_WERKS
               AND MACH_CD = P_MACH_CD
               AND STR_DATE IN (SELECT TO_DATE(RTN_VALUES,'YYYY-MM-DD HH24:MI:SS') FROM FN_SPLIT(P_LIST,','));

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
END SP_POP_WRK03_D01;


/
