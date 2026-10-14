
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK24_S01" 
(
    P_MACH_CD   		IN VARCHAR2 	--설비코드
    ,RS_MACH_STA        OUT VARCHAR2    --가동상태(R :가동, S:비가동, N:대기중)
    ,Lang       		IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE     		OUT VARCHAR2 
    ,RS_MSG      		OUT VARCHAR2
    ,CUR_1       		OUT SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : POP_WRK24
 * PROGRAM NAME  : PS 점보롤 주 작업 화면 조회
 * VERSION       : 1.0.1
 * DESCRIPTION   : PS 투입정보와 작업지시정보 조회
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
 * - [TB_SCH015] : (.R..) PS 점보롤 작업지시
 * - [TB_SCH016] : (.R..) PS 밀롤 작업지시
 * - [TB_MAS001] : (.R..) 자재 기준 정보
 * - [TB_WRK002] : (.R..) PS 생산실적 이력
 * - [TB_WRK004] : (.R..) PS 폐품실적 이력
 * - [TB_WRK011] : (.R..) 작업장(설비)별 현재 진행현황
 *=============================================================================*/
AS 
    --프로그램 ID : 점보롤 작업지시 조회
    V_PRG_NM        VARCHAR2(100)  := 'SP_POP_WRK24_S01';     -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID   varchar2(20) := 'TEST'; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);
    --parameter변수 처리
    V_WERKS             VARCHAR2(10);
    V_WRK_ORDR_NO       VARCHAR2(20);
    V_WRK_ORDR_SEQNO    NUMBER;
    V_MATNR             VARCHAR2(20);
    V_MACH_STA          VARCHAR2(10);
    V_PRD_STR_DTM       VARCHAR2(15);
    V_PRE_ORDER_NO      VARCHAR2(20);
    V_TOT_MR_WIDTH      NUMBER;
    V_TSPEED            NUMBER;  --목표선속

    V_PRD_LAST_DATE     VARCHAR2(20);
BEGIN
    BEGIN
        SELECT WERKS, WRK_ORDR_NO, WRK_ORDR_SEQNO, MATNR, PRD_STR_DTM, MACH_STA
            INTO V_WERKS, V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_MATNR, V_PRD_STR_DTM, V_MACH_STA
          FROM TB_WRK011
        WHERE MACH_CD = P_MACH_CD; 
    EXCEPTION 
        WHEN NO_DATA_FOUND THEN 
            V_MACH_STA := 'N';
    END;

    RS_MACH_STA := V_MACH_STA;

    V_PRD_LAST_DATE := FN_GET_LAST_DATE('P100', P_MACH_CD);    -- 실적/폐품/비가동 입력 중 마지막  시간 가져오기 

    BEGIN
        SELECT TSPEED
            INTO V_TSPEED           --목표선속
          FROM TB_MAS001
        WHERE WERKS = V_WERKS
            AND MATNR = V_MATNR; 
        EXCEPTION WHEN NO_DATA_FOUND THEN
            V_TSPEED := 0;
    END;    

    BEGIN
        -- 22-05-23 : 밀롤 ORDER_NUM/ORDER_SEQ 별로 각각 sum 하여 가장큰 지폭합을 가져오도록 수정.
        BEGIN
            SELECT PRE_ORDER_NO, MWIDTH_INPUT
                INTO 
                V_PRE_ORDER_NO, V_TOT_MR_WIDTH
                FROM (SELECT PRE_ORDER_NO, SUM(NVL(MWIDTH_INPUT, 0)) AS MWIDTH_INPUT
                      FROM TB_SCH016
                     WHERE PRE_ORDER_NO = (SELECT NVL(ORDER_NO, '')
                                              FROM TB_SCH015
                                             WHERE WRK_ORDR_NO = V_WRK_ORDR_NO
                                               AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
                                            )   
                    GROUP BY  PRE_ORDER_NO, ORDER_NUM, ORDER_SEQ
                    ORDER BY MWIDTH_INPUT DESC)
            WHERE ROWNUM = 1;                    
        EXCEPTION 
            WHEN NO_DATA_FOUND THEN 
                V_TOT_MR_WIDTH := 0;
        END;

        OPEN CUR_1 FOR
        SELECT S015.ORDER_NO                AS ORDER_NO,           --생산오더번호
            S015.WRK_ORDR_NO                AS WRK_ORDR_NO,        --작업지시번호
            S015.WRK_ORDR_SEQNO             AS WRK_ORDR_SEQNO,     --작업지시순번
            --S015.COMP_YN,                                                       --작업완료여부
            S015.MATNR                      AS MATNR,              --자재코드 
            NVL(S015.JROLLCNT, '0')         AS JROLLCNT,           --계획 권치수
--            NVL(S015.WRK_ORDR_QTY, '0') AS ORDR_WGT,             --계획중량 (생산오더에서 내려오지 않아서 TOT_WGT로 변경)
            NVL(S015.TOT_WGT, '0')          AS ORDR_WGT,           --계획중량 (생산오더에서 내려오지 않아서 TOT_WGT로 변경)
            NVL(V_TSPEED, '0')              AS TSPEED,             --목표선속
            S015.PRD_REQ_DT                 AS PRD_REQ_DT,         --생산요청일자(8BYTE)
--            V_PRD_STR_DTM                   AS PRD_STR_DTM,        --생산시작일시(14BYTE)
            V_PRD_LAST_DATE                   AS PRD_STR_DTM,        --생산시작일시(14BYTE)
            NVL(S015.BS_WGT, '0')           AS BS_WGT,             --평량
            S015.UNIT                       AS UNIT,               --단위
            NVL(S015.JWIDTH, '0')           AS JWIDTH,             --지폭
            NVL(W002.PRFM_ROLLCNT, '0')     AS PRFM_ROLLCNT,       --실적 권치수
            NVL(W002.PRFM_WGT, '0')         AS PRFM_WGT,           --실적 중량
            NVL(W004.DISPO_QTY, '0')        AS DISPO_QTY,          --폐품 중량
            NVL(V_TOT_MR_WIDTH, '0')        AS TOT_MR_WIDTH,       --M/R 지폭합
            S015.ORDER_RMK                  AS ORDER_RMK,          --오더 비고
            S015.WRK_ORDR_RMK               AS WRK_ORDR_RMK,       --작업지시 비고
            M001.PCODE                      AS PCODE,
            M001.PCODE_NM                   AS PCODE_NM,
            V_MACH_STA                      AS MACH_STA            -- 'R'=진행중 , 'S'=비가동중, 'N'=대기중
--            CASE WHEN V_MACH_STA = 'R' THEN '진행중'       -- 'R'=진행중 , 'S'=비가동중, 'N'=대기중
--                WHEN V_MACH_STA = 'S' THEN '비가동 중'
--                ELSE '대기중' END  AS MACH_STA
          FROM TB_SCH015 S015,
            (SELECT WERKS,
                   MACH_CD,
                   WRK_ORDR_NO,
                   WRK_ORDR_SEQNO,
                   SUM(ROLLCNT)  AS PRFM_ROLLCNT,
                   SUM(PRFM_QTY)  AS PRFM_QTY,
                   SUM(WGT)  AS PRFM_WGT
                FROM TB_WRK002 
               WHERE WERKS = V_WERKS
                 AND MACH_CD = P_MACH_CD
                 AND WRK_ORDR_NO = V_WRK_ORDR_NO
                 AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
                 AND RUN_STA = '01'                                             -- 운전상태 01 : 정상생산, 08 : 비계획생산
                 AND NVL(CNL_YN,'N') = 'N'
               GROUP BY WERKS, MACH_CD, WRK_ORDR_NO, WRK_ORDR_SEQNO     
                  ) W002,
              (SELECT WERKS, 
                   MACH_CD,
                   WRK_ORDR_NO,
                   WRK_ORDR_SEQNO,
                   SUM(DISPO_QTY) AS DISPO_QTY
                 FROM TB_WRK004
                WHERE WERKS = V_WERKS
                 AND MACH_CD = P_MACH_CD
                 AND WRK_ORDR_NO = V_WRK_ORDR_NO
                 AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
                 AND NVL(CNL_YN,'N') = 'N'
               GROUP BY WERKS, MACH_CD, WRK_ORDR_NO, WRK_ORDR_SEQNO
               ) W004,
               TB_MAS001 M001     --자재코드 마스터
         WHERE S015.WERKS = W002.WERKS(+)
           AND S015.WRK_ORDR_NO = W002.WRK_ORDR_NO(+)
           AND S015.WRK_ORDR_SEQNO = W002.WRK_ORDR_SEQNO(+)
           AND S015.WERKS = W004.WERKS(+)
           AND S015.WRK_ORDR_NO = W004.WRK_ORDR_NO(+)
           AND S015.WRK_ORDR_SEQNO = W004.WRK_ORDR_SEQNO(+)
           AND M001.WERKS = S015.WERKS
           AND M001.MATNR = S015.MATNR
           AND S015.WRK_ORDR_NO = V_WRK_ORDR_NO
           AND S015.WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
         ORDER BY   S015.PRD_REQ_DT,S015.WRK_SEQNO, S015.WRK_SEQNO ,S015.WRK_ORDR_NO, S015.WRK_ORDR_SEQNO;

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
