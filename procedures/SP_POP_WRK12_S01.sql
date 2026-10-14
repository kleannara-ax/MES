
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK12_S01" 
(
    P_WERKS             IN VARCHAR2
    ,P_MACH_CD          IN VARCHAR2 
    ,P_IOTYPE           IN VARCHAR2 
    ,P_USERID           IN VARCHAR2 
    ,P_WRK_ORDR_NO      IN VARCHAR2 
    ,P_WRK_ORDR_SEQNO   IN VARCHAR2 
    ,P_PRD_STR_DATE     OUT VARCHAR2
    ,P_PRFM_QTY         OUT VARCHAR2
    ,P_DISPO_QTY        OUT VARCHAR2
    ,Lang               IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE            OUT VARCHAR2 
    ,RS_MSG             OUT VARCHAR2
)
/*==============================================================================
 * PROGRAM ID    : POP_WRK12
 * PROGRAM NAME  : 화장지 합지기 실적등록
 * VERSION       : 1.0.0
 * DESCRIPTION   : 현재 작업지시의 시작시간(실적, 폐품수량)을 조회한다.
 *                 
 * AUTHOR NAME   : 김기연
 * CREATE DATE   : 2022/05/21
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/05/21    1.0.0   김기연         Initial Version
 *==============================================================================
 *  관련 테이블
 * - [TB_SCH011] : (..U.) 화장지 합지기 작업지시
 * - [TB_WRK012] : (C.U.) 작업장별 가동 현황
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM         VARCHAR2(100)  := 'SP_POP_WRK12_S01';     -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID   varchar2(20) := P_USERID; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);
    --parameter변수 처리
    V_WRK_ORDR_SEQNO    NUMBER(5,0) := TO_NUMBER(P_WRK_ORDR_SEQNO);
    --내부 변수 등록
    V_TEMPDATE  DATE;
    V_TEMPDTM  VARCHAR2(15);
    V_PRFM_QTY NUMBER(10,3);
    V_DISPO_QTY NUMBER(10,3);

BEGIN
    --예외처리 시작(try)
    BEGIN
        BEGIN
            BEGIN
            --현재지시의 마지막 완료 실적일자 조회
            SELECT PRD_END_DATE INTO V_TEMPDATE
              FROM TB_WRK001
             WHERE 1=1
               AND WERKS = P_WERKS
               AND WRK_ORDR_NO = P_WRK_ORDR_NO
               AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
               AND REGDATE = (SELECT MAX(REGDATE) --해당 지시의 마지막 실적의 등록일자
                                FROM TB_WRK001
                               WHERE 1=1
                                 AND WERKS = P_WERKS
                                 AND WRK_ORDR_NO = P_WRK_ORDR_NO
                                 AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO);
            EXCEPTION WHEN NO_DATA_FOUND THEN 
                -- 조회된 항목이 없는 경우 작업지시의 시작일자 사용
                SELECT PRD_STR_DTM INTO V_TEMPDTM
                  FROM TB_WRK011
                 WHERE 1=1
                   AND WERKS = P_WERKS
                   AND MACH_CD = P_MACH_CD
                   AND IN_OUT = P_IOTYPE;
                V_TEMPDATE := TO_DATE(V_TEMPDTM,'YYYYMMDDHH24MISS');
            END;
            P_PRD_STR_DATE := TO_CHAR(V_TEMPDATE,'YYYY-MM-DD HH24:MI:SS');

            --실적수량 조회
            SELECT SUM(WGT)
              INTO V_PRFM_QTY
              FROM TB_WRK001
             WHERE 1=1
               AND WERKS = P_WERKS
               AND MACH_CD = P_MACH_CD
               AND WRK_ORDR_NO = P_WRK_ORDR_NO
               AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO;
            P_PRFM_QTY := TO_CHAR(V_PRFM_QTY);

            --폐품수량 조회
            SELECT SUM(DISPO_QTY)
              INTO V_DISPO_QTY
              FROM TB_WRK004
             WHERE 1=1
               AND WERKS = P_WERKS
               AND MACH_CD = P_MACH_CD
               AND WRK_ORDR_NO = P_WRK_ORDR_NO
               AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO;
            P_DISPO_QTY := TO_CHAR(V_DISPO_QTY);

            RS_CODE := 'S';
            DBMS_OUTPUT.PUT_LINE(P_PRD_STR_DATE);
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
        --RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);

        RS_CODE := 'E';
        RS_MSG  := SQLERRM;
        RETURN;
    --예외처리 종료
    END;
END SP_POP_WRK12_S01;
/
