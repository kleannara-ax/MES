--------------------------------------------------------
--  DDL for Procedure SP_POP_WRK39_S01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK39_S01" 
(
    P_WERKS         IN VARCHAR2 
    ,P_MACH_CD      IN VARCHAR2
    ,P_IOTYPE       IN VARCHAR2
    ,P_WRK_DT       IN VARCHAR2
    ,P_USERID       IN VARCHAR2
    ,Lang           IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE        OUT VARCHAR2 
    ,RS_MSG         OUT VARCHAR2
    ,CUR_1          OUT SYS_REFCURSOR
    ,CUR_2          OUT SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : POP_WRK39
 * PROGRAM NAME  : 비가동 이력조회
 * VERSION       : 1.0.0
 * DESCRIPTION   : 비가동 이력 목록을 조회한다.
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
 * - [TB_WRK003] : (.R..) 비가동 실적
 * - [TB_MAS020] : (.R..) 비가동 항목정보
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM        VARCHAR2(100)  := 'SP_POP_WRK39_S01';     -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID   varchar2(20) := P_USERID; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);
    --파라미터 처리
    --내부변수 관리
    V_COLINFO VARCHAR2(1000);
    V_COLTYPE VARCHAR2(1000);

BEGIN
    --예외처리 시작(try)
    BEGIN
        --컬럼설정
        V_COLINFO := '선택@C^60|설비@H|구분@H|시작일시@C^200|종료일시@C^200|비가동시간(분)@C^140|비가동사유@C^100|비고@L^400|등록자ID@H|등록자@C^150';
        V_COLTYPE := 'CHK@Button|MACH_CD@varchar|IN_OUT@varchar|PRD_STR_DATE@varchar|PRD_END_DATE@varchar|ABN_TIME@varchar|ABN_NM@varchar|RMK@varchar|USERID@varchar|USERNM@varchar';
        --컬럼설정 반환 테이블 작성
        OPEN CUR_1 FOR
        SELECT RTN_VALUES FROM FN_SPLIT(V_COLINFO||','||V_COLTYPE,',');

        --결과 테이블 반환용 변수
        OPEN CUR_2 FOR
        --비가동 이력목록 조회
        SELECT '-' AS CHK               --선택여부
        	 , W003.MACH_CD
        	 , W003.IN_OUT
             , TO_CHAR(W003.STR_DATE,'YYYY-MM-DD HH24:MI:SS') AS PRD_STR_DATE --시작시간
             , TO_CHAR(W003.END_DATE,'YYYY-MM-DD HH24:MI:SS') AS PRD_END_DATE   --종료시간
             , ROUND((W003.END_DATE - W003.STR_DATE) * 24 * 60) AS ABN_TIME    --비가동 시간
             , M020.ABN_NM              --비가동 사유
             , W003.RMK                 --비고
             , W003.REGID AS USERID     --등록자
             , U001.NMLAST AS USERNM
        FROM TB_WRK003 W003,            --비가동 이력
             TB_MAS020 M020,            --비가동항목 정보
             USRMA U001                 --사용자 정보
        WHERE 1=1
        AND W003.WERKS = M020.WERKS(+)
        AND W003.ABN_CD = M020.ABN_CD(+)
        AND W003.REGID = U001.USERID(+)
        AND W003.WERKS = P_WERKS
        AND W003.MACH_CD = P_MACH_CD
        AND W003.ABN_DT = P_WRK_DT
        --AND W003.IN_OUT = P_IOTYPE
--        AND (TO_CHAR(W003.STR_DATE,'YYYYMMDD') <= P_WRK_DT
--            AND NVL(TO_CHAR(W003.END_DATE,'YYYYMMDD'),TO_CHAR(W003.STR_DATE,'YYYYMMDD')) >= P_WRK_DT)
        AND NVL(W003.CNL_YN, 'N') = 'N'
        ORDER BY W003.STR_DATE;

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
END SP_POP_WRK39_S01;

/
