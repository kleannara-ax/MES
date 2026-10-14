
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK03_S02" 
(
    P_WERKS             IN VARCHAR2 
    ,P_MACH_CD          IN VARCHAR2
    --,P_INOUT			IN VARCHAR2
    ,P_WRK_ORDR_NO      IN VARCHAR2
    ,P_WRK_ORDR_SEQ     IN VARCHAR2
    ,P_USERID           IN VARCHAR2
    ,Lang               IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE            OUT VARCHAR2 
    ,RS_MSG             OUT VARCHAR2
    ,CUR_1              OUT SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : POP_WRK03
 * PROGRAM NAME  : 비가동 등록
 * VERSION       : 1.0.0
 * DESCRIPTION   : 비가동 화면 호출시 비가동 정보를 조회한다.
 *                 
 * AUTHOR NAME   : 김기연
 * CREATE DATE   : 2022/05/06
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/05/06    1.0.0   김기연         Initial Version
 *==============================================================================
 *  관련 테이블
 * - [TB_WRK003] : (.R..) 비가동 이력
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM        VARCHAR2(100)  := 'SP_POP_WRK03_S02';     -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := '99'; --OPCODE
    V_SESS_USER_ID   varchar2(20) := P_USERID; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);
    --parameter변수 처리
    V_WRK_ORDR_SEQ  NUMBER(5,0) := TO_NUMBER(P_WRK_ORDR_SEQ);

BEGIN
    --예외처리 시작(try)
    BEGIN
        BEGIN
            --결과 테이블 반환용 변수
            OPEN CUR_1 FOR
            --비가동 작업정보
            SELECT W003.STR_DATE
                 , W003.END_DATE
                 , M020.RUN_STA
                 , W003.ABN_CD
                 , W003.RMK
                 , W003.IN_OUT
            FROM TB_WRK003 W003
                , TB_MAS020 M020
            WHERE 1=1
            AND W003.WERKS = M020.WERKS(+)
            AND W003.ABN_CD = M020.ABN_CD(+)
            AND W003.WERKS = P_WERKS
            AND W003.MACH_CD = P_MACH_CD
--            AND W003.IN_OUT = P_INOUT
--            AND W003.WRK_ORDR_NO = P_WRK_ORDR_NO
--            AND W003.WRK_ORDR_SEQNO = P_WRK_ORDR_SEQ
            AND W003.END_DATE IS NULL;
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
END SP_POP_WRK03_S02;
/
