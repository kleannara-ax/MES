--------------------------------------------------------
--  DDL for Procedure SP_POP_WRK40_S01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK40_S01" 
(
    P_WERKS             IN VARCHAR2 
    ,P_PROC_CD          IN VARCHAR2 
    ,P_MACH_CD          IN VARCHAR2
    ,P_WRK_ORDR_NO      IN VARCHAR2
    ,P_WRK_ORDR_SEQNO   IN VARCHAR2
    ,P_USERID           IN VARCHAR2
    ,Lang               IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE            OUT VARCHAR2 
    ,RS_MSG             OUT VARCHAR2
    ,CUR_1              OUT SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : POP_WRK40
 * PROGRAM NAME  : PS 작업지시 변경
 * VERSION       : 1.0.0
 * DESCRIPTION   : 진행중인 작업지시를 변경한다.
 *                 
 * AUTHOR NAME   : 김병무
 * CREATE DATE   : 2022/05/10
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/04/28    1.0.0   김기연         Initial Version
 *==============================================================================
 *  관련 테이블
 * - [TB_SCH015] : (.R..) PS 점보롤 작업지시
 * - [TB_MAS001] : (.R..) 자재 기준 정보
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM        VARCHAR2(100)  := 'SP_POP_WRK40_S01';     -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := P_PROC_CD; --OPCODE
    V_SESS_USER_ID   varchar2(20) := P_USERID; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);
    --parameter변수 처리
    V_WRK_ORDR_SEQNO  NUMBER(5,0) := TO_NUMBER(P_WRK_ORDR_SEQNO);
    V_PRE_WRK_ORDR_NO           TB_SCH015.WRK_ORDR_NO%TYPE;     
    V_PRE_WRK_ORDR_SEQNO        TB_SCH015.WRK_ORDR_SEQNO%TYPE;  
    V_MACH_STA                  TB_WRK011.MACH_STA%TYPE;
BEGIN
    --예외처리 시작(try)
    BEGIN
        BEGIN
            SELECT CASE WHEN MACH_STA = 'N' THEN PRE_WRK_ORDR_NO ELSE WRK_ORDR_NO END,
                   CASE WHEN MACH_STA = 'N' THEN PRE_WRK_ORDR_SEQNO ELSE WRK_ORDR_SEQNO END,
                   MACH_STA
                   INTO V_PRE_WRK_ORDR_NO, V_PRE_WRK_ORDR_SEQNO, V_MACH_STA
              FROM TB_WRK011
             WHERE MACH_CD = P_MACH_CD;
        EXCEPTION 
            WHEN NO_DATA_FOUND THEN NULL;
        END;

--        IF NVL(V_PRE_WRK_ORDR_NO, ' ' ) = ' ' THEN
--            RS_CODE := 'E';
--            RS_MSG := 'POP 단말기 정보가 없습니다.';
--            RETURN;
--        END IF;

        BEGIN                 
            --결과 테이블 반환용 변수
            OPEN CUR_1 FOR
            --기존 작업 지시정보
            SELECT NVL(TO_CHAR(TO_DATE(S015.PRD_REQ_DT,'YYYYMMDD'),'YYYY-MM-DD'), '') AS PRD_REQ_DT      --생산요청일자(8BYTE)
                 , S015.ORDER_NO            --오더번호
                 , S015.WRK_ORDR_NO         --작업지시번호
                 , S015.WRK_ORDR_SEQNO      --작업지시순번
                 , M001.MATNR               --자재코드
                 , M001.MATNR_NM            --자재명
                 , M001.MATNR_SPEC          --자재규격
                 , S015.BS_WGT              --평량
                 , S015.JWIDTH AS WIDTH     --J/R 지폭
                 , S015.JROLLCNT            --J/4 권치수
                 , S015.TOT_WGT              --계획 중량
                 , NVL(W002.PRFM_ROLLCNT, '0') AS PRFM_ROLLCNT                        --실적 권치수
                 , NVL(W002.PRFM_WGT, '0') AS PRFM_WGT                                --실적 중량
                 , NVL(W004.DISPO_QTY, '0') AS DISPO_QTY                              --폐품 중량
                 --, '' AS PRFM_ROLLCNT        --실적 권치수
                 --, '' AS PRFM_WGT            --실적 중량
                 --, '' AS DISPO_QTY           --폐품 중량
                 , S015.WRK_ORDR_RMK        --작업지시비고
                 , S015.PRD_STR_DTM AS PRD_STR_DATE     --생산시작일시
                 , S015.PRD_END_DTM AS PRD_END_DATE     --생산완료일시
                 , V_MACH_STA       AS MACH_STA         --설비상태
                 , 'P' AS ROW_STA       --ROW_STA 값이 'P'=기존작업지시, 'N'=신규작업지시
            FROM TB_SCH015 S015, 
                 TB_MAS001 M001,
                (SELECT WERKS,
                       MACH_CD,
                       WRK_ORDR_NO,
                       WRK_ORDR_SEQNO,
                       SUM(ROLLCNT)  AS PRFM_ROLLCNT,
                       SUM(PRFM_QTY)  AS PRFM_QTY,
                       SUM(WGT)  AS PRFM_WGT
                    FROM TB_WRK002 
                   WHERE WERKS = P_WERKS
                     AND MACH_CD = P_MACH_CD
                     AND WRK_ORDR_NO = V_PRE_WRK_ORDR_NO
                     AND WRK_ORDR_SEQNO = V_PRE_WRK_ORDR_SEQNO
                     AND RUN_STA = '01'                                             -- 운전상태 01 : 정상생산, 08 : 비계획생산
                   GROUP BY WERKS, MACH_CD, WRK_ORDR_NO, WRK_ORDR_SEQNO     
                      ) W002,
                  (SELECT WERKS, 
                       MACH_CD,
                       WRK_ORDR_NO,
                       WRK_ORDR_SEQNO,
                       SUM(DISPO_QTY) AS DISPO_QTY
                     FROM TB_WRK004
                    WHERE WERKS = P_WERKS
                     AND MACH_CD = P_MACH_CD
                     AND WRK_ORDR_NO = V_PRE_WRK_ORDR_NO
                     AND WRK_ORDR_SEQNO = V_PRE_WRK_ORDR_SEQNO
                   GROUP BY WERKS, MACH_CD, WRK_ORDR_NO, WRK_ORDR_SEQNO
                   ) W004
            WHERE 1=1
            AND S015.WERKS = M001.WERKS(+)
            AND S015.MATNR = M001.MATNR(+)
            AND S015.WERKS = W002.WERKS(+)
            AND S015.WRK_ORDR_NO = W002.WRK_ORDR_NO(+)
            AND S015.WRK_ORDR_SEQNO = W002.WRK_ORDR_SEQNO(+)
            AND S015.WERKS = W004.WERKS(+)
            AND S015.WRK_ORDR_NO = W004.WRK_ORDR_NO(+)
            AND S015.WRK_ORDR_SEQNO = W004.WRK_ORDR_SEQNO(+)
            AND S015.WERKS = P_WERKS
            AND S015.WRK_ORDR_NO = V_PRE_WRK_ORDR_NO
            AND S015.WRK_ORDR_SEQNO = V_PRE_WRK_ORDR_SEQNO
            UNION ALL
            --신규 선택 지시정보
            SELECT NVL(TO_CHAR(TO_DATE(S015.PRD_REQ_DT,'YYYYMMDD'),'YYYY-MM-DD'), '') AS PRD_REQ_DT      --생산요청일자(8BYTE)
                 , S015.ORDER_NO            --오더번호
                 , S015.WRK_ORDR_NO         --작업지시번호
                 , S015.WRK_ORDR_SEQNO      --작업지시순번
                 , M001.MATNR               --자재코드
                 , M001.MATNR_NM            --자재명
                 , M001.MATNR_SPEC          --자재규격
                 , S015.BS_WGT              --평량
                 , S015.JWIDTH AS WIDTH     --J/R 지폭
                 , S015.JROLLCNT            --J/R 권치수
                 , S015.TOT_WGT              --계획 중량
                 , NVL(W002.PRFM_ROLLCNT, '0') AS PRFM_ROLLCNT                        --실적 권치수
                 , NVL(W002.PRFM_WGT, '0') AS PRFM_WGT                                --실적 중량
                 , NVL(W004.DISPO_QTY, '0') AS DISPO_QTY                              --폐품 중량
                 --, '' AS PRFM_ROLLCNT        --실적 권치수
                 --, '' AS PRFM_WGT            --실적 중량
                 --, '' AS DISPO_QTY           --폐품 중량
                 , S015.WRK_ORDR_RMK        --작업지시비고
                 , '' AS PRD_STR_DATE       --생산시작일시
                 , '' AS PRD_END_DATE       --생산완료일시
                 , V_MACH_STA       AS MACH_STA     --설비상태
                 , 'N' AS ROW_STA           --ROW_STA 값이 'P'=기존작업지시, 'N'=신규작업지시
            FROM TB_SCH015 S015, 
                 TB_MAS001 M001,
                (SELECT WERKS,
                       MACH_CD,
                       WRK_ORDR_NO,
                       WRK_ORDR_SEQNO,
                       SUM(ROLLCNT)  AS PRFM_ROLLCNT,
                       SUM(PRFM_QTY)  AS PRFM_QTY,
                       SUM(WGT)  AS PRFM_WGT
                    FROM TB_WRK002 
                   WHERE WERKS = P_WERKS
                     AND MACH_CD = P_MACH_CD
                     AND WRK_ORDR_NO = P_WRK_ORDR_NO
                     AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
                     AND RUN_STA = '01'                                             -- 운전상태 01 : 정상생산, 08 : 비계획생산
                   GROUP BY WERKS, MACH_CD, WRK_ORDR_NO, WRK_ORDR_SEQNO     
                      ) W002,
                  (SELECT WERKS, 
                       MACH_CD,
                       WRK_ORDR_NO,
                       WRK_ORDR_SEQNO,
                       SUM(DISPO_QTY) AS DISPO_QTY
                     FROM TB_WRK004
                    WHERE WERKS = P_WERKS
                     AND MACH_CD = P_MACH_CD
                     AND WRK_ORDR_NO = P_WRK_ORDR_NO
                     AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
                   GROUP BY WERKS, MACH_CD, WRK_ORDR_NO, WRK_ORDR_SEQNO
                   ) W004
            WHERE 1=1
            AND S015.WERKS = M001.WERKS(+)
            AND S015.MATNR = M001.MATNR(+)
            AND S015.WERKS = W002.WERKS(+)
            AND S015.WRK_ORDR_NO = W002.WRK_ORDR_NO(+)
            AND S015.WRK_ORDR_SEQNO = W002.WRK_ORDR_SEQNO(+)
            AND S015.WERKS = W004.WERKS(+)
            AND S015.WRK_ORDR_NO = W004.WRK_ORDR_NO(+)
            AND S015.WRK_ORDR_SEQNO = W004.WRK_ORDR_SEQNO(+)
            AND S015.WERKS = P_WERKS
            AND S015.WRK_ORDR_NO = P_WRK_ORDR_NO
            AND S015.WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO;
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
END SP_POP_WRK40_S01;

/
