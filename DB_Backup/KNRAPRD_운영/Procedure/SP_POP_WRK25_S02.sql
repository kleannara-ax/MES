--------------------------------------------------------
--  DDL for Procedure SP_POP_WRK25_S02
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK25_S02" 
(
     P_WERKS         IN VARCHAR2 
    ,P_MACH_CD      IN VARCHAR2 
    ,P_LIST_NO      IN VARCHAR2             -- 1 : 점보롤 바코드 정보, 2 : 작업지시정보
    ,P_JIND_BCD     IN VARCHAR2             -- 1 : 점보롤 바코드 정보 조회시
    ,P_JORDER_NO    IN VARCHAR2             -- 2 : 작업지시정보 조회 시
    ,P_ORDER_NUM    IN NUMBER             -- 2 : 작업지시정보 조회 시
    ,P_ORDER_SEQ    IN NUMBER             -- 2 : 작업지시정보 조회 시
    ,Lang           IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE        OUT VARCHAR2 
    ,RS_MSG         OUT VARCHAR2
    ,CUR_1          OUT SYS_REFCURSOR
    ,CUR_2          OUT SYS_REFCURSOR
   
)
/*==============================================================================
 * PROGRAM ID    : POP_WRK25
 * PROGRAM NAME  : PS 밀롤 주 작업 화면
 * VERSION       : 1.0.1
 * DESCRIPTION   : PS 밀롤 주 작업 화면 그리드 클릭했을 때 상세정보 조회
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
    V_PRG_NM        VARCHAR2(100)  := 'SP_POP_WRK08_S01';     -- PROCEDURE NAME
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
        IF P_LIST_NO = '1' THEN
--            V_COLINFO := '실적량@H|사용량@H|폐품량@H|가용량@H';
--            V_COLTYPE := 'PRFM_QTY@varchar|USE_QTY@varchar|DISPO_QTY@varchar|ABLE_QTY@varchar';
--            
--            --컬럼설정 반환 테이블 작성
--            OPEN CUR_1 FOR
--            SELECT RTN_VALUES FROM FN_SPLIT(V_COLINFO || ',' || V_COLTYPE, ',');

            OPEN CUR_1 FOR
            SELECT
                    PRFM_QTY
                   ,USE_QTY
                   ,DISPO_QTY
                   ,ABLE_QTY
                   ,RMK
            FROM
            (
                    SELECT NVL(W002.PRFM_QTY, 0) AS PRFM_QTY
                        , NVL(I010.USE_QTY, 0) AS USE_QTY
                        , NVL(W004.DISPO_QTY, 0) AS DISPO_QTY
                        , NVL(W002.PRFM_QTY, 0) - (NVL(I010.USE_QTY, 0) + NVL(W004.DISPO_QTY, 0)) AS ABLE_QTY
                        , W002.RMK AS RMK
                      FROM 
                            (SELECT WERKS, PRFM_QTY, RMK
                              FROM TB_WRK002
                             WHERE WERKS = P_WERKS
                               AND IND_BCD = P_JIND_BCD
                               AND NVL(CNL_YN,'N')  = 'N'
                             ) W002,
                            (SELECT WERKS, SUM(USE_QTY) USE_QTY
                              FROM TB_INV010
                             WHERE WERKS = P_WERKS
                               AND IND_BCD_M = P_JIND_BCD
                               AND NVL(CNL_YN,'N') = 'N'
                             GROUP BY WERKS) I010,
                            (SELECT WERKS, SUM(DISPO_QTY) DISPO_QTY
                               FROM TB_WRK004
                              WHERE WERKS = P_WERKS
                                AND IND_BCD_M = P_JIND_BCD
                                AND NVL(CNL_YN,'N')  = 'N'
                             GROUP BY WERKS
                             ) W004
                    WHERE W002.WERKS = I010.WERKS(+)
                      AND W002.WERKS = W004.WERKS(+)
                UNION ALL
                       SELECT NVL(IN_QTY, 0)     PRFM_QTY
                            , NVL(USE_QTY, 0)    USE_QTY
                            , NVL(DISPO_QTY, 0)  DISPO_QTY
                            , NVL(IN_QTY, 0) - NVL(USE_QTY, 0) /*+ NVL(DISPO_QTY, 0)*/ AS ABLE_QTY
                            , NULL                RMK
                        FROM TB_INV003
                       WHERE WERKS   = P_WERKS
                         AND IND_BCD = P_JIND_BCD
              )         ;
        ELSE
            --grid1 컬럼 정보 설정
            V_COLINFO := '선택@C^40|작업지시번호@C^170|순번@C^40|다음공정@H|슬리터@C^60|지폭@C^60|폭수@C^40|실지폭@C^80|지폭순번@C^65|실적순서@C^65|계획권치수@C^85|실적권치수@C^85|폐품권치수@C^85|밀롤적치@C^65|밀롤적치_FROM@H|재단번호@C^65|보기@C^50|자재코드@C^200|비고@L^500|작업시작일시@H|작업종료일시@H';
            V_COLTYPE := 'CHK@Button|WRK_ORDR_NO@varchar|WRK_ORDR_SEQNO@varchar|NEXT_PROC@varchar|SLITER@varchar|MWIDTH@Integer|MRCNT@Integer|MWIDTH_INPUT@Integer|WIDTH_NO@varchar|PRD_SEQ@varchar|MROLLCNT@varchar|PRD_MROLLCNT@varchar|DISPO_MROLLCNT@varchar|MRLDCK@varchar|MRLDCK_FROM@varchar|CUTTER@varchar|DETAIL_BTN@Button|MATNR@varchar|ORDER_RMK@varchar|PRD_STR_DATE@varchar|PRD_END_DATE@varchar';

            --컬럼설정 반환 테이블 작성
            OPEN CUR_1 FOR
            SELECT RTN_VALUES FROM FN_SPLIT(V_COLINFO || ',' || V_COLTYPE, ',');

            OPEN CUR_2 FOR
            SELECT 'V' AS CHK,                          --선택
                  S016.WRK_ORDR_NO,                     --작업지시번호
                  S016.WRK_ORDR_SEQNO,                  --작업지시순번
                  CASE WHEN NVL(S016.SHEET, ' ') = 'X' THEN 'SHEET' ELSE 'ROLL' END  AS NEXT_PROC,  --다음공정
                  S016.SLITER,                          --슬리터
--                  TO_CHAR(S016.MWIDTH_INPUT, 'fm999,999,999,990') AS MWIDTH,	        --밀롤 지폭
--                  TO_CHAR(S016.MRCNT, 'fm999,999,999,990') AS MRCNT,	        --밀롤 폭수
--                  TO_CHAR(S016.MWIDTH_INPUT, 'fm999,999,999,990') AS MWIDTH_INPUT,                        --실지폭
                  S016.MWIDTH_INPUT AS MWIDTH,	        --밀롤 지폭
                  S016.MRCNT AS MRCNT,	        --밀롤 폭수
                  S016.MWIDTH_INPUT AS MWIDTH_INPUT,                        --실지폭
                  '' AS WIDTH_NO,                       --지폭순번
                  '' AS PRD_SEQ,                        --실적순서
                  TO_CHAR(S016.MROLLCNT, 'fm999,999,999,990') AS MROLLCNT,	        --계획권치수
                  TO_CHAR(W002.ROLLCNT, 'fm999,999,999,990')  AS PRD_MROLLCNT,                  --실적권치수
                  TO_CHAR(W004.ROLLCNT, 'fm999,999,999,990')  AS DISPO_MROLLCNT,                  --폐품권치수
                  CASE WHEN NVL(S016.MRLDCK, ' ') = 'X' THEN 'Y' ELSE 'N' END  AS MRLDCK,  --밀롤적치여부
                  CASE WHEN NVL(S016.MRLDCK, ' ') = 'X' THEN 'Y' ELSE 'N' END  AS MRLDCK_FROM,  --밀롤적치여부 가 N인만 Y로 수정 가능한게 처리하기위해 추가( 밀롤 작업지시 수정 시 밀롤적치 여부 N에서 Y로 수정가능 (Y에서 N은 불가능))
                  REPLACE(S016.CUTTER, '00', 0) AS CUTTER, --재단번호
                  '버튼' AS DETAIL_BTN,                   --상세정보
                  S016.MATNR,                            --자재코드
                  S016.ORDER_RMK,                        --생산오더비고
                  TO_CHAR(W002.PRD_STR_DATE, 'YYYYMMDDHH24MISS') AS PRD_STR_DATE,
                  TO_CHAR(W002.PRD_END_DATE, 'YYYYMMDDHH24MISS') AS PRD_END_DATE
                  FROM TB_SCH016 S016 
                       ,(SELECT W002.WERKS, W002.MACH_CD, W002.WRK_ORDR_NO, W002.WRK_ORDR_SEQNO
                                , SUM(W002.ROLLCNT) ROLLCNT, MAX(W002.PRD_STR_DATE) PRD_STR_DATE, MAX(W002.PRD_END_DATE) PRD_END_DATE
                           FROM TB_WRK002 W002,
                                TB_SCH016 S016
                         WHERE W002.WERKS = S016.WERKS(+)
                           AND W002.WRK_ORDR_NO = S016.WRK_ORDR_NO(+)
                           AND W002.WRK_ORDR_SEQNO = S016.WRK_ORDR_SEQNO(+)
                           AND S016.WERKS = P_WERKS
                           AND S016.PRE_ORDER_NO = P_JORDER_NO
                           AND S016.ORDER_NUM = P_ORDER_NUM
                           AND S016.ORDER_SEQ = P_ORDER_SEQ
                           --AND W002.PRFM_GTHR_YN = 'Y'
                           AND COMP_YN IN ('N', 'I')
                           AND NVL(W002.CNL_YN,'N')  = 'N'
                        GROUP BY W002.WERKS, W002.MACH_CD, W002.WRK_ORDR_NO, W002.WRK_ORDR_SEQNO) W002
                       ,(SELECT W004.WERKS, W004.MACH_CD, W004.WRK_ORDR_NO, W004.WRK_ORDR_SEQNO
                                , SUM(W004.ROLLCNT) ROLLCNT
                           FROM TB_WRK004 W004,
                                TB_SCH016 S016
                         WHERE W004.WERKS = S016.WERKS(+)
                           AND W004.WRK_ORDR_NO = S016.WRK_ORDR_NO(+)
                           AND W004.WRK_ORDR_SEQNO = S016.WRK_ORDR_SEQNO(+)
                           AND S016.WERKS = P_WERKS
                           AND S016.PRE_ORDER_NO = P_JORDER_NO
                           AND S016.ORDER_NUM = P_ORDER_NUM
                           AND S016.ORDER_SEQ = P_ORDER_SEQ
                           --AND W002.PRFM_GTHR_YN = 'Y'
                           AND COMP_YN IN ('N', 'I')
                           AND NVL(W004.CNL_YN,'N')  = 'N'
                        GROUP BY W004.WERKS, W004.MACH_CD, W004.WRK_ORDR_NO, W004.WRK_ORDR_SEQNO) W004

             WHERE 1=1
               AND S016.WERKS = W002.WERKS(+)
               --AND P_MACH_CD = W002.MACH_CD(+)
               AND S016.WRK_ORDR_NO = W002.WRK_ORDR_NO(+)
               AND S016.WRK_ORDR_SEQNO = W002.WRK_ORDR_SEQNO(+)
               AND S016.WRK_ORDR_NO = W004.WRK_ORDR_NO(+)
               AND S016.WRK_ORDR_SEQNO = W004.WRK_ORDR_SEQNO(+)
               AND S016.WERKS = P_WERKS
               AND S016.PRE_ORDER_NO = P_JORDER_NO
               AND S016.ORDER_NUM = P_ORDER_NUM
               AND S016.ORDER_SEQ = P_ORDER_SEQ
               AND COMP_YN IN ('N', 'I')
            ORDER BY S016.ORDER_NO;
        END IF;

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
