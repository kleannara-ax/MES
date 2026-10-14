--------------------------------------------------------
--  DDL for Procedure SP_POP_WRK25_S01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK25_S01" 
(
    P_WERKS         IN VARCHAR2 
    ,P_MACH_CD      IN VARCHAR2 
    ,RS_MACH_STA    OUT VARCHAR2    --가동상태(R :가동, S:비가동, N:대기중)
    ,Lang           IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE        OUT VARCHAR2 
    ,RS_MSG         OUT VARCHAR2
    ,CUR_1          OUT SYS_REFCURSOR
    ,CUR_2          OUT SYS_REFCURSOR
    ,CUR_3          OUT SYS_REFCURSOR
    ,CUR_4          OUT SYS_REFCURSOR
    ,CUR_5          OUT SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : POP_WRK25
 * PROGRAM NAME  : PS 밀롤 주 작업 화면
 * VERSION       : 1.0.1
 * DESCRIPTION   : PS 밀롤 주 작업 화면, 투입정보와 작업지시정보 조회
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
 * - [TB_SCH002] : (.R..) 화장지 합지기 생산오더
 * - [TB_SCH011] : (.R..) 화장지 합지기 작업지시
 * - [TB_MAS001] : (.R..) 자재 기준 정보
 * - [TB_WRK001] : (.R..) HL 생산실적 이력
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM        VARCHAR2(100)  := 'SP_POP_WRK25_S01';     -- PROCEDURE NAME
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
    V_MACH_STA              TB_WRK011.MACH_STA%TYPE;
    V_PRD_STR_DTM           TB_WRK011.PRD_STR_DTM%TYPE;
    V_IND_BCD               TB_INV003.IND_BCD%TYPE;

    V_COLINFO1 VARCHAR2(1000);--컬럼설정1
    V_COLTYPE1 VARCHAR2(1000);--컬럼설정1
    V_COLINFO2 VARCHAR2(1000);--컬럼설정2
    V_COLTYPE2 VARCHAR2(1000);--컬럼설정2
--    V_WRK_CD VARCHAR2(8);--설비별 작업장코드
BEGIN
    BEGIN
        --투입정보(투입된 점보롤 정보)
        BEGIN
            SELECT WRK_ORDR_NO, WRK_ORDR_SEQNO, ORDER_NO, MATNR, PRD_STR_DTM, MACH_STA
                INTO V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_ORDER_NO, V_MATNR, V_PRD_STR_DTM, V_MACH_STA
              FROM TB_WRK011
             WHERE WERKS = P_WERKS
               AND MACH_CD = P_MACH_CD;
        EXCEPTION 
            WHEN NO_DATA_FOUND THEN 
                V_MACH_STA := 'N';
        END;
            
        RS_MACH_STA := V_MACH_STA;
        
        OPEN CUR_1 FOR   
        SELECT S015.PCODE              --지종코드
               ,TO_CHAR(S015.BS_WGT, 'fm999,999,999,990') AS BS_WGT	        --점보롤 평량
               ,TO_CHAR(S015.JWIDTH, 'fm999,999,999,990') AS JWIDTH	        --점보롤 지폭
               --,W002.RMK AS RMK          --작업자 비고
               --,S015.ORDER_RMK           --생산오더 비고
               --,W002.LOT_NO              --LOT NO(2개일수 있음)
               ,S015.ORDER_NO                   AS ORDER_NO           --생산오더번호
               ,S015.WRK_ORDR_NO                AS WRK_ORDR_NO        --작업지시번호
               ,S015.WRK_ORDR_SEQNO             AS WRK_ORDR_SEQNO     --작업지시순번
               ,S015.MATNR                      AS MATNR              --자재코드                
               ,V_PRD_STR_DTM     AS PRD_STR_DTM        --생산시작일시(YYYYMMDDHH24MISS)
               ,V_MACH_STA        AS MACH_STA                  --상태(R :가동, S:비가동, N:대기중)
          FROM TB_SCH015 S015  
         WHERE 1=1
           AND S015.WRK_ORDR_NO = V_WRK_ORDR_NO
           AND S015.WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
           AND S015.WERKS = P_WERKS;

        --grid1 컬럼 정보 설정
        V_COLINFO1 := '점보롤바코드@C^230|투입권치수@C^160|오더번호@H|자재코드@H|LOT_NO@C^200';
        V_COLTYPE1 := 'IND_BCD@varchar|ROLLCNT@varchar|ORDER_NO@varchar|MATNR@varchar|LOT_NO@varchar';
        --컬럼설정 반환 테이블 작성
        OPEN CUR_2 FOR
        SELECT RTN_VALUES FROM FN_SPLIT(V_COLINFO1 || ',' || V_COLTYPE1, ',');

        --GRID1 데이터
        OPEN CUR_3 FOR
        SELECT IND_BCD,                         --점보롤 바코드
               --ROLLCNT  ROLLCNT,                --실적권치수
               TO_CHAR(ROLLCNT , 'fm999,999,999,990') ROLLCNT,	        --실적권치수
               V_ORDER_NO AS ORDER_NO,          --오더번호
               MATNR,                           --점보롤 자재코드
               LOT_NO AS LOT_NO
          FROM TB_INV003
         WHERE WERKS = P_WERKS
           AND MACH_CD = P_MACH_CD
           AND WRK_ORDR_NO = V_WRK_ORDR_NO
           AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
           AND STCK_QTY > 0
        ORDER BY IND_BCD;


        --grid1 컬럼 정보 설정
        V_COLINFO2 := '생산지시번호@H|생산지시순번@H|점보롤오더번호@H|지시번호@C^80';
        V_COLTYPE2 := 'ORDER_NUM@varchar|ORDER_SEQ@varchar|PRE_ORDER_NO@varchar|ORDER_SEQNO@varchar';

        OPEN CUR_4 FOR
        SELECT RTN_VALUES FROM FN_SPLIT(V_COLINFO2 || ',' || V_COLTYPE2, ',');

        --작업지시정보
        OPEN CUR_5 FOR
        SELECT ORDER_NUM, ORDER_SEQ, PRE_ORDER_NO, TO_CHAR(ORDER_NUM) || '-' || TO_CHAR(ORDER_SEQ) AS ORDER_SEQNO
          FROM TB_SCH016
         WHERE WERKS = P_WERKS
           AND PRE_ORDER_NO = V_ORDER_NO
           AND COMP_YN IN ('N', 'I')
        GROUP BY ORDER_NUM, ORDER_SEQ, PRE_ORDER_NO   
        ORDER BY ORDER_NUM, ORDER_SEQ;

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
        RAISE;  --_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);

        RS_CODE := 'E';
        RS_MSG  := SQLERRM;
        RETURN;
    --예외처리 종료
    END;
END;

/
