--------------------------------------------------------
--  DDL for Procedure SP_POP_WRK02_U01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK02_U01" 
(
    P_IPADDR    IN VARCHAR2 
    ,P_WERKS    IN VARCHAR2 
    ,P_MACH_CD  IN VARCHAR2 
    --,P_IOTYPE   IN VARCHAR2 
    ,Lang       IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE     OUT VARCHAR2 
    ,RS_MSG      OUT VARCHAR2
)
/*==============================================================================
 * PROGRAM ID    : POP_WRK02
 * PROGRAM NAME  : 설비호기 선택
 * VERSION       : 1.0.0
 * DESCRIPTION   : 선택된 설비를 IP별 작업장 관리목록에 저장한다.
 *                 
 * AUTHOR NAME   : 김기연
 * CREATE DATE   : 2022/04/19
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/04/19    1.0.0   김기연         Initial Version 
 *==============================================================================
 *  관련 테이블
 * - [TB_MAS029] : (..U.) 작업장 관리
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM        VARCHAR2(100)  := 'SP_POP_WRK02_U01';     -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID   varchar2(20) := 'TEST'; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);
    --parameter변수 처리
    V_IPADDR   VARCHAR2(20) := P_IPADDR;
    V_WERKS   VARCHAR2(10) := P_WERKS;
    V_MACH_CD   VARCHAR2(10) := P_MACH_CD;
    --V_IOTYPE   VARCHAR2(10) := P_IOTYPE;

BEGIN
    --예외처리 시작(try)
    BEGIN
        BEGIN
            --작업장 선택 초기화
            UPDATE TB_MAS029
               SET USE_YN = 'N'
             WHERE 1=1
               AND IP_ADDRESS = V_IPADDR;
            --진행중인 작업장 선택
            UPDATE TB_MAS029
               SET USE_YN = 'Y'
             WHERE 1=1
               AND IP_ADDRESS = V_IPADDR
--               AND WERKS = P_WERKS
               AND MACH_CD = V_MACH_CD;
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
END SP_POP_WRK02_U01;

/
