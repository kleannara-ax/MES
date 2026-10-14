
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRKLAMI_SL_I01" SP_POP_WRKLAMI_SL_I01
(
    P_WERKS     		IN VARCHAR2 	                --플랜트
    ,P_MACH_CD   		IN VARCHAR2 	                --설비코드
    ,P_SDATE            IN VARCHAR2                     --작업시작시간(YYYYMMDDHHMMSS)
    ,P_USERID           IN VARCHAR2                     --USER ID
    ,P_WRK_ORDR_NO      IN VARCHAR2                     --작업지시번호
    ,P_WRK_ORDR_SEQNO   IN VARCHAR2                     --작업지시번호SEQ
    ,Lang       		IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE     		OUT VARCHAR2 
    ,RS_MSG      		OUT VARCHAR2
    
)
/*==============================================================================
 * PROGRAM ID    : WRK073
 * PROGRAM NAME  : 슬리팅 작업시작
 * VERSION       : 1.0.0
 * DESCRIPTION   : 인쇄/코팅 작업시작을 하기 위한 SP.
 *                 
 * AUTHOR NAME   : 김수현
 * CREATE DATE   : 2022/11/17
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/05/10    1.0.0   김수현         Initial Version
 *==============================================================================
 *  관련 테이블
 * - [TB_LAMI_SL] : (.R..) 슬리팅 작업지시
 *=============================================================================*/
AS 
    --프로그램 ID : 점보롤 작업시작
    V_PRG_NM        VARCHAR2(100)  := 'SP_POP_WRKLAMI_SL_I01';     -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID   varchar2(20) := 'TEST'; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);
    --parameter변수 처리

    V_MATNR                     TB_WRK002.MATNR%TYPE;
    V_WRK_ORDR_NO               TB_WRK002.WRK_ORDR_NO%TYPE;
    V_WRK_ORDR_SEQNO            TB_WRK002.WRK_ORDR_SEQNO%TYPE;
    V_ORDER_NO                  TB_WRK002.ORDER_NO%TYPE;
    V_PRD_STR_DTM               VARCHAR2(20);
    V_REGDATE                   DATE := SYSDATE;
    V_CNL_CNT                   NUMBER;
    V_LOT_NO                    VARCHAR2(20);
    V_LOT_NO_N                  VARCHAR2(20);
    V_PRD_STR_DTM_N             VARCHAR2(20);

BEGIN

    BEGIN
        SELECT COUNT(NVL(CNL_YN,0))
        INTO V_CNL_CNT
        FROM TB_WRK003
        WHERE 1 = 1
        AND MACH_CD = P_MACH_CD
--        AND WRK_ORDR_NO = P_WRK_ORDR_NO
--        AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
        AND SYSDATE BETWEEN STR_DATE AND END_DATE
        AND CNL_YN = 'N'
        ;
        IF V_CNL_CNT > 0 THEN
            BEGIN
                RS_CODE := 'E';
                RS_MSG := '설비가 비가동으로 되어 있습니다. 가동으로 변경해 주세요';
                ROLLBACK;
                RETURN;
            END;
        END IF;

        UPDATE TB_WRK011
           SET PRD_STR_DTM = P_SDATE
			   ,MACH_STA = 'R'
         WHERE WERKS = P_WERKS
           AND MACH_CD = P_MACH_CD
           AND WRK_ORDR_NO = P_WRK_ORDR_NO
           AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
           AND IN_OUT = 'N';

        SELECT WRK_ORDR_NO, WRK_ORDR_SEQNO, ORDER_NO, MATNR, PRD_STR_DTM
            INTO V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_ORDER_NO, V_MATNR, V_PRD_STR_DTM
          FROM TB_WRK011
         WHERE WERKS = P_WERKS
           AND MACH_CD = P_MACH_CD
           AND WRK_ORDR_NO = P_WRK_ORDR_NO
           AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
           AND IN_OUT = 'N';

        SELECT WRK_ORDR_NO, WRK_ORDR_SEQNO, ORDER_NO, MATNR, LOT_BUF, PRD_STR_DTM
            INTO V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_ORDER_NO, V_MATNR, V_LOT_NO_N, V_PRD_STR_DTM_N
          FROM TB_LAMI_SL
         WHERE WERKS = P_WERKS
           AND MACH_CD = P_MACH_CD
           AND WRK_ORDR_NO = P_WRK_ORDR_NO
           AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
           AND NVL(COMP_YN,'N') IN ('N','I');

--        SP_CHK_LOT_NO_LAMI(NVL(V_LOT_NO, ' '), P_WERKS, P_MACH_CD, V_MATNR, P_SDATE, V_LOT_NO);
           
           IF V_LOT_NO_N IS NULL OR V_LOT_NO_N = '' THEN
               BEGIN
                SP_CHK_LOT_NO_LAMI(NVL(V_LOT_NO, ' '), P_WERKS, P_MACH_CD, V_MATNR, P_SDATE, V_LOT_NO);

                UPDATE TB_LAMI_SL
                   SET PRD_STR_DTM = V_PRD_STR_DTM
                     , COMP_YN = 'I'
--                     , LOT_BUF = V_LOT_NO
                 WHERE WRK_ORDR_NO = V_WRK_ORDR_NO
                   AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO;
                
               END;
           ELSE
               BEGIN

                UPDATE TB_LAMI_SL
                   SET PRD_STR_DTM = V_PRD_STR_DTM_N
                     , COMP_YN = 'I'
                 WHERE WRK_ORDR_NO = V_WRK_ORDR_NO
                   AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO;
               
               END;
           END IF;

--        UPDATE TB_LAMI_SL
--           SET PRD_STR_DTM = V_PRD_STR_DTM
--             , COMP_YN = 'I'
--             , LOT_BUF = V_LOT_NO
--         WHERE WRK_ORDR_NO = V_WRK_ORDR_NO
--           AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO;

        UPDATE TB_WRK012
           SET STR_DATE = TO_DATE(V_PRD_STR_DTM, 'YYYYMMDDHH24MISS')        
         WHERE WERKS = P_WERKS
           AND MACH_CD = P_MACH_CD
           AND WRK_ORDR_NO = P_WRK_ORDR_NO
           AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
           AND END_DATE IS NULL
           ;

        RS_CODE := 'S';
        COMMIT;      
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
        E_SQL_ERR_CD        := '-20000';  --SQLCODE;
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
