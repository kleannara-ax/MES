--------------------------------------------------------
--  DDL for Procedure SP_POP_WRK26_S02_221028
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK26_S02_221028" SP_POP_WRK26_S02_221028
(
    P_WERKS         IN VARCHAR2 
    ,P_MACH_CD      IN VARCHAR2 
    ,P_IND_BCD_M     IN VARCHAR2             -- 1 : 투입된 밀롤 개별바코드 
    ,P_ORDER_NO_M    IN VARCHAR2             -- 2 : 투입된 밀롤 오더번호
    ,P_WRK_ORDR_NO_CA       IN VARCHAR2      -- 재단 작업지시 번호
    ,P_WRK_ORDR_SEQNO_CA    IN VARCHAR2      -- 재단 작업지시 순번
    ,Lang           IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE        OUT VARCHAR2 
    ,RS_MSG         OUT VARCHAR2
    ,CUR_1          OUT SYS_REFCURSOR
    ,CUR_2          OUT SYS_REFCURSOR
   
)
/*==============================================================================
 * PROGRAM ID    : POP_WRK26
 * PROGRAM NAME  : PS 재단 주 작업 화면
 * VERSION       : 1.0.1
 * DESCRIPTION   : 그리드 클릭했을 때 상세정보 조회
 *                 
 * AUTHOR NAME   : 유상호
 * CREATE DATE   : 2022/05/25
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/05/25    1.0.0   유상호         Initial Version
  *==============================================================================
 *  관련 테이블
 * - [TB_SCH016] : (.R..) 제지 밀롤 작업지시
 * - [TB_MAS001] : (.R..) 자재 기준 정보
 * - [TB_WRK001] : (.R..) 설비별 현재 진행현황
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM        VARCHAR2(100)  := 'SP_POP_WRK26_S02_221028';     -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID   varchar2(20) := 'TEST'; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);
    --내부변수 관리

    V_WRK_ORDR_NO           TB_WRK011.WRK_ORDR_NO%TYPE;
    V_WRK_ORDR_SEQNO        TB_WRK011.WRK_ORDR_SEQNO%TYPE;
    V_ORDER_NO              TB_WRK011.ORDER_NO%TYPE;
    V_MATNR                 TB_WRK011.MATNR%TYPE;
    V_PRD_STR_DTM           TB_WRK011.PRD_STR_DTM%TYPE;
    V_IND_BCD               TB_INV003.IND_BCD%TYPE;

    V_COLINFO VARCHAR2(1000);--컬럼설정1
    V_COLTYPE VARCHAR2(1000);--컬럼설정1
BEGIN
    BEGIN
        --재단 작업지시번호 순번  -> 실적량  폐품량 실적연수량  폐품연수량 
        OPEN CUR_1 FOR
        SELECT
                PRFM_QTY
               ,USE_QTY
               ,DISPO_QTY
               ,ABLE_QTY
               ,RMK
               ,WO_QTY_CA       -- 재단 작업지시 실적+폐품 연수
               ,WO_WGT_CA      -- 재단 작업지시 실적+폐품 중량
        FROM (
                SELECT NVL(W002.PRFM_QTY, 0)                            PRFM_QTY
                     , NVL(I010.USE_QTY, 0)                             USE_QTY
                     , NVL(W004.DISPO_QTY, 0)+ NVL(W022.DISPO_QTY, 0)   DISPO_QTY
                     , NVL(W002.PRFM_QTY, 0) - (NVL(I010.USE_QTY, 0) + NVL(W004.DISPO_QTY, 0)+ NVL(W022.DISPO_QTY, 0) )  
                                                                        ABLE_QTY
                     , W002.RMK                                         RMK
                     , (NVL(W002_CA.PRFM_QTY_CA / 500, 0) + NVL(W004_CA.DISPO_QTY_CA / 500, 0)) 
                                                                        WO_QTY_CA       -- 재단 작업지시 실적+폐품 연수
                     , (NVL(W002_CA.PRFM_WGT_CA, 0) + NVL(W004_CA.DISPO_WGT_CA, 0)) 
                                                                        WO_WGT_CA      -- 재단 작업지시 실적+폐품 중량
                  FROM
                        (SELECT WERKS, PRFM_QTY, RMK
                          FROM TB_WRK002
                         WHERE WERKS = P_WERKS
                           AND IND_BCD = P_IND_BCD_M) W002,
                        (SELECT WERKS, SUM(USE_QTY) USE_QTY
                          FROM TB_INV010
                         WHERE WERKS = P_WERKS
                           AND MACH_CD = P_MACH_CD
                           AND IND_BCD_M = P_IND_BCD_M
                           AND NVL(CNL_YN,'N') = 'N'
                         GROUP BY WERKS) I010,
                        (SELECT WERKS, SUM(WGT) DISPO_QTY
                           FROM TB_WRK004
                          WHERE WERKS = P_WERKS
                            AND MACH_CD = P_MACH_CD
                            AND IND_BCD_M = P_IND_BCD_M
                            AND NVL(CNL_YN,'N')  = 'N'
                         GROUP BY WERKS) W004 ,
                        (SELECT WERKS, SUM(WGT) DISPO_QTY
                           FROM TB_WRK022
                          WHERE WERKS = P_WERKS
                            AND MACH_CD = P_MACH_CD
                            AND IND_BCD_M = P_IND_BCD_M
                         GROUP BY WERKS) W022 ,                 
                        (SELECT WERKS, SUM(PRFM_QTY) PRFM_QTY_CA, SUM(WGT) PRFM_WGT_CA
                          FROM TB_WRK002
                         WHERE WERKS = P_WERKS
                           AND MACH_CD = P_MACH_CD
                           AND WRK_ORDR_NO = P_WRK_ORDR_NO_CA
                           AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO_CA 
                           AND NVL(CNL_YN,'N')  = 'N'
                         GROUP BY WERKS) W002_CA,
                        (SELECT WERKS, SUM(DISPO_QTY) DISPO_QTY_CA, SUM(WGT) AS DISPO_WGT_CA
                           FROM TB_WRK004
                          WHERE WERKS = P_WERKS
                            AND MACH_CD = P_MACH_CD
                           AND WRK_ORDR_NO = P_WRK_ORDR_NO_CA
                           AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO_CA 
                           AND NVL(CNL_YN,'N')  = 'N'
                         GROUP BY WERKS) W004_CA
                WHERE W002.WERKS = I010.WERKS(+)
                  AND W002.WERKS = W004.WERKS(+)
                  AND W002.WERKS = W022.WERKS(+)
                  AND W002.WERKS = W002_CA.WERKS(+)
                  AND W002.WERKS = W004_CA.WERKS(+)
          UNION ALL                  
                SELECT NVL(W002.PRFM_QTY, 0)                            PRFM_QTY
                     , NVL(I010.USE_QTY, 0)                             USE_QTY
                     , NVL(W004.DISPO_QTY, 0)+ NVL(W022.DISPO_QTY, 0)   DISPO_QTY
                     , NVL(W002.PRFM_QTY, 0) - (NVL(I010.USE_QTY, 0) + NVL(W004.DISPO_QTY, 0)+ NVL(W022.DISPO_QTY, 0))  
                                                                        ABLE_QTY
                     , W002.RMK                                         RMK
                     , (NVL(W002_CA.PRFM_QTY_CA / 500, 0) + NVL(W004_CA.DISPO_QTY_CA / 500, 0)) 
                                                                        WO_QTY_CA       -- 재단 작업지시 실적+폐품 연수
                     , (NVL(W002_CA.PRFM_WGT_CA, 0) + NVL(W004_CA.DISPO_WGT_CA, 0)) 
                                                                        WO_WGT_CA       -- 재단 작업지시 실적+폐품 중량
                  FROM
                        (SELECT WERKS, IN_QTY PRFM_QTY, NULL RMK
                          FROM TB_INV003
                         WHERE WERKS = P_WERKS
                           AND IND_BCD = P_IND_BCD_M) W002,
--                        (SELECT WERKS, SUM(USE_QTY) USE_QTY
--                          FROM TB_INV003
--                         WHERE WERKS = P_WERKS
--                           AND MACH_CD = P_MACH_CD
--                           AND IND_BCD  = P_IND_BCD_M
--                         GROUP BY WERKS) I010,
                        (SELECT WERKS, SUM(USE_QTY) USE_QTY
                          FROM TB_INV010
                         WHERE WERKS = P_WERKS
                           AND MACH_CD = P_MACH_CD
                           AND IND_BCD_M = P_IND_BCD_M
                           AND NVL(CNL_YN,'N') = 'N'
                         GROUP BY WERKS) I010,
                        (SELECT WERKS, SUM(WGT) DISPO_QTY
                           FROM TB_WRK004
                          WHERE WERKS = P_WERKS
                            AND MACH_CD = P_MACH_CD
                            AND IND_BCD_M = P_IND_BCD_M
                            AND NVL(CNL_YN,'N')  = 'N'
                         GROUP BY WERKS) W004 ,
                        (SELECT WERKS, SUM(WGT) DISPO_QTY
                           FROM TB_WRK022
                          WHERE WERKS = P_WERKS
                            AND MACH_CD = P_MACH_CD
                            AND IND_BCD_M = P_IND_BCD_M
                         GROUP BY WERKS) W022 ,                 
                        (SELECT WERKS, SUM(PRFM_QTY) PRFM_QTY_CA, SUM(WGT) PRFM_WGT_CA
                          FROM TB_WRK002
                         WHERE WERKS = P_WERKS
                           AND MACH_CD = P_MACH_CD
                           AND WRK_ORDR_NO = P_WRK_ORDR_NO_CA
                           AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO_CA 
                           AND NVL(CNL_YN,'N')  = 'N'
                         GROUP BY WERKS) W002_CA,
                        (SELECT WERKS, SUM(DISPO_QTY) DISPO_QTY_CA, SUM(WGT) AS DISPO_WGT_CA
                           FROM TB_WRK004
                          WHERE WERKS = P_WERKS
                            AND MACH_CD = P_MACH_CD
                           AND WRK_ORDR_NO = P_WRK_ORDR_NO_CA
                           AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO_CA 
                           AND NVL(CNL_YN,'N')  = 'N'
                         GROUP BY WERKS) W004_CA
                WHERE W002.WERKS = I010.WERKS(+)
                  AND W002.WERKS = W004.WERKS(+)
                  AND W002.WERKS = W022.WERKS(+)
                  AND W002.WERKS = W002_CA.WERKS(+)
                  AND W002.WERKS = W004_CA.WERKS(+)
          
          )                  
          ;

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
