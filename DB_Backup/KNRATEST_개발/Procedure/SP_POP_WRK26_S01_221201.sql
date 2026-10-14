--------------------------------------------------------
--  DDL for Procedure SP_POP_WRK26_S01_221201
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK26_S01_221201" 
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
)
/*==============================================================================
 * PROGRAM ID    : POP_WRK26
 * PROGRAM NAME  : PS 재단 주 작업 화면
 * VERSION       : 1.0.1
 * DESCRIPTION   : 투입정보와 작업지시정보 조회
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
 *                                     union 제거 테스트용
  *==============================================================================
 *  관련 테이블
 * - [] : (.R..) 
 * - [] : (.R..) 
 * - [] : (.R..) 
 * - [] : (.R..) 
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM        VARCHAR2(100)  := 'SP_POP_WRK26_S01';     -- PROCEDURE NAME
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
    V_LOT_NO              TB_WRK011.LOT_NO%TYPE;
    V_MATNR                 TB_WRK011.MATNR%TYPE;
    V_MACH_STA              TB_WRK011.MACH_STA%TYPE;
    V_PRD_STR_DTM           TB_WRK011.PRD_STR_DTM%TYPE;
    V_IND_BCD               TB_INV003.IND_BCD%TYPE;
    V_MWIDTH                TB_SCH016.MWIDTH%TYPE;
    V_MWIDTH_INPUT          TB_SCH016.MWIDTH_INPUT%TYPE;
    V_MRCNT                 TB_SCH016.MRCNT%TYPE;
    V_WLEN                  TB_SCH017.WLEN%TYPE;
    
    V_COLINFO1 VARCHAR2(1000);--컬럼설정1
    V_COLTYPE1 VARCHAR2(1000);--컬럼설정1
--    V_WRK_CD VARCHAR2(8);--설비별 작업장코드
BEGIN
    BEGIN
        --투입정보(투입된 밀롤 정보)
        BEGIN
            SELECT WRK_ORDR_NO, WRK_ORDR_SEQNO, ORDER_NO, MATNR, PRD_STR_DTM, MACH_STA,LOT_NO
                INTO V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_ORDER_NO, V_MATNR, V_PRD_STR_DTM, V_MACH_STA, V_LOT_NO
              FROM TB_WRK011   --작업장(설비)별 현재 진행현황
             WHERE WERKS = P_WERKS
               AND MACH_CD = P_MACH_CD;
        EXCEPTION 
            WHEN NO_DATA_FOUND THEN 
                V_MACH_STA := 'N';
        END;
            
        RS_MACH_STA := V_MACH_STA;

        OPEN CUR_1 FOR   
        SELECT   I003.LOT_NO                                LOT_NO
--                ( SELECT LOT_NO   LOT_NO
--                   FROM TB_WRK002  WRK002
--                   WHERE WRK_ORDR_NO     = V_WRK_ORDR_NO
--                     AND WRK_ORDR_SEQNO  = V_WRK_ORDR_SEQNO
--                     AND ROWNUM  = 1
--                 )                                              LOT_NO
                ,S016.PCODE                                     PCODE           --지종코드
                ,S016.BS_WGT                                    BS_WGT	        --밀롤 평량
                ,S016.MWIDTH                                    MWIDTH	        --밀롤 지폭
                ,S016.MWIDTH_INPUT                              MWIDTH_INPUT	--밀롤 실지폭
                ,S016.REMARK                                    REMARK          --작업지시 비고
                ,S016.ORDER_RMK                                 ORDER_RMK       --생산오더 비고
                --,W002.LOT_NO                                                    --LOT NO(2개일수 있음)
                ,S016.WRK_ORDR_NO                               WRK_ORDR_NO
                ,S016.WRK_ORDR_SEQNO                            WRK_ORDR_SEQNO
                ,S016.ORDER_NO                                  ORDER_NO
                ,S016.MATNR                                     MATNR
                ,V_PRD_STR_DTM                                  PRD_STR_DTM     --생산시작일시(YYYYMMDDHH24MISS)
                ,V_MACH_STA                                     MACH_STA        --상태(R :가동중, S:비가동중, N:대기중)
                ,I001.IN_MR_YN                                  IN_MR_YN        --수입밀롤 여부 (Y : 수입밀롤, N : 정규생산) 
          FROM TB_SCH016 S016
               --TB_WRK002 W002
              ,TB_SCH017 S017
              ,TB_INV001 I001
              ,TB_INV003 I003
         WHERE 1=1
           AND S016.WRK_ORDR_NO  = V_WRK_ORDR_NO
           AND S016.WRK_ORDR_SEQNO  = V_WRK_ORDR_SEQNO
           AND S016.WERKS           = P_WERKS
           AND S016.ORDER_NO        = V_ORDER_NO
           AND S016.WRK_ORDR_NO  = I003.WRK_ORDR_NO
           AND S016.WRK_ORDR_SEQNO  = I003.WRK_ORDR_SEQNO
           AND I003.IND_BCD = I001.IND_BCD
           AND S016.ORDER_NO        = S017.PRE_ORDER_NO(+)
           AND S017.COMP_YN != 'Y'
           AND S017.USE_YN = 'Y'
--        UNION ALL
--        SELECT   V_LOT_NO                                              LOT_NO
--                ,S001.PCODE                                     PCODE           --지종코드
--                ,S001.BS_WGT                                    BS_WGT	        --밀롤 평량
--                ,S001.WLEN                                      MWIDTH	        --밀롤 지폭
--                ,S001.WLEN                                      MWIDTH_INPUT	--밀롤 실지폭
--                ,S016.REMARK                                    REMARK          --작업지시 비고
--                ,S016.ORDER_RMK                                 ORDER_RMK       --생산오더 비고
--                ,S016.WRK_ORDR_NO                               WRK_ORDR_NO
--                ,S016.WRK_ORDR_SEQNO                            WRK_ORDR_SEQNO
--                ,V001.ORDER_NO                                  ORDER_NO
--                ,V001.MATNR                                     MATNR
--                ,V_PRD_STR_DTM                                  PRD_STR_DTM     --생산시작일시(YYYYMMDDHH24MISS)
--                ,V_MACH_STA                                     MACH_STA        --상태(R :가동중, S:비가동중, N:대기중)
--                ,'Y'                                            IN_MR_YN        --수입밀롤 여부 (Y : 수입밀롤, N : 정규생산)
--          FROM TB_INV001 V001 
--             , TB_MAS001 S001
--             , TB_SCH016 S016
--             , TB_SCH017 S017
--         WHERE 1=1
--           AND S016.WERKS    = P_WERKS
--           AND S016.ORDER_NO = V_ORDER_NO
--           AND S016.ORDER_NO = S017.PRE_ORDER_NO(+)
--           AND S017.COMP_YN != 'Y'
--           AND S017.USE_YN = 'Y'
--           AND V001.WERKS   = S001.WERKS
--           AND V001.MATNR   = S001.MATNR
--           AND V001.LOT_NO  = V_LOT_NO
--           AND V001.MATNR   = V_MATNR
--           AND V001.WERKS   = P_WERKS 
           ;
        
        --grid1 컬럼 정보 설정
        V_COLINFO1 := '밀롤바코드@C^230|투입권치수@C^160|오더번호@H|자재코드@H|작업지시번호@H|작업지시순번@H|LOT_NO@H';
        V_COLTYPE1 := 'IND_BCD@varchar|ROLLCNT@varchar|ORDER_NO@varchar|MATNR@varchar|WRK_ORDR_NO@varchar|WRK_ORDR_SEQNO@varchar|LOT_NO@varchar';
        --컬럼설정 반환 테이블 작성
        OPEN CUR_2 FOR
        SELECT RTN_VALUES FROM FN_SPLIT(V_COLINFO1 || ',' || V_COLTYPE1, ',');

        --GRID1 데이터
        OPEN CUR_3 FOR
        SELECT IND_BCD                                          IND_BCD,           --밀롤 바코드
               NVL(TO_CHAR(ROLLCNT, 'fm999,999,999,999'), '0')  ROLLCNT,           --실적권치수
               V_ORDER_NO                                       ORDER_NO,          --오더번호
               MATNR                                            MATNR,             --밀롤 자재코드
               V_WRK_ORDR_NO                                    WRK_ORDR_NO,
               V_WRK_ORDR_SEQNO                                 WRK_ORDR_SEQNO,
               LOT_NO                                           LOT_NO
          FROM TB_INV003
         WHERE WERKS = P_WERKS
           AND MACH_CD = P_MACH_CD
           AND WRK_ORDR_NO = V_WRK_ORDR_NO
           AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
           AND STCK_QTY > 0
--        UNION ALL
--        SELECT V003.IND_BCD                                          IND_BCD,               --밀롤 바코드
--               NVL(TO_CHAR(V003.ROLLCNT, 'fm999,999,999,999'), '0')  ROLLCNT,               --실적권치수
--               V_ORDER_NO                                       ORDER_NO,              --오더번호
--               V003.MATNR                                            MATNR,                 --밀롤 자재코드
--               V_WRK_ORDR_NO                                    WRK_ORDR_NO,
--               V_WRK_ORDR_SEQNO                                 WRK_ORDR_SEQNO,
--               V003.LOT_NO                                           LOT_NO
--          FROM TB_INV003 V003
--         WHERE V003.WERKS = P_WERKS
--           AND V003.MACH_CD = P_MACH_CD
--           AND V003.LOT_NO = V_LOT_NO
--           --AND H020.ORDER_NO  = V_ORDER_NO
--           --AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
--           AND V003.STCK_QTY > 0
           
           ;

        --작업지시정보
        BEGIN
            SELECT
                 MWIDTH, MWIDTH_INPUT
            INTO V_MWIDTH, V_MWIDTH_INPUT
            FROM
            (
                    -- 밀롤
                    SELECT MWIDTH MWIDTH, MWIDTH_INPUT MWIDTH_INPUT
                      FROM TB_SCH016
                     WHERE WERKS = P_WERKS
                       AND WRK_ORDR_NO = V_WRK_ORDR_NO
                       AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
--                     UNION ALL
--                     -- 수입밀롤
--                    SELECT S001.WLEN MWIDTH, S001.WLEN MWIDTH_INPUT
--                      FROM TB_INV001 V001
--                         , TB_MAS001 S001
--                     WHERE V001.WERKS = S001.WERKS
--                       AND V001.MATNR = S001.MATNR
--                       AND V001.WERKS = P_WERKS
--                       AND V001.LOT_NO = V_LOT_NO
--                       AND NVL(V001.IN_MR_YN,'N') = 'Y'
               ) 
               ;
         EXCEPTION
                WHEN NO_DATA_FOUND THEN
                     V_MWIDTH := NULL ;   
                     V_MWIDTH_INPUT := NULL;
         END ;
         
         
        BEGIN
            SELECT MRCNT, WLEN
            INTO  V_MRCNT, V_WLEN         --밀롤지폭, 가로길이
            FROM TB_SCH017 S017  --재단
            WHERE S017.WERKS = P_WERKS
               AND S017.PRE_ORDER_NO = V_ORDER_NO
               AND S017.COMP_YN IN ('N', 'I')
               AND S017.USE_YN = 'Y'
               ;
         EXCEPTION
                WHEN NO_DATA_FOUND THEN
                     V_MRCNT := 0; 
                WHEN TOO_MANY_ROWS THEN
                    RS_CODE := 'E';
                    RS_MSG := '재단 작업지시가 1개 이상입니다.\n시스템 담당자에게 문의 하시기 바랍니다.';
                    RETURN;
         END ;

        IF V_MRCNT <= 0 THEN
            V_MRCNT := TRUNC(V_MWIDTH_INPUT / V_WLEN);

            IF V_MRCNT <= 0 THEN
                V_MRCNT := 1;
            END IF;
        END IF;
        
        OPEN CUR_4 FOR
        SELECT S017.WRK_ORDR_NO WRK_ORDR_NO, 
            S017.WRK_ORDR_SEQNO  , 
            S017.PRD_REQ_DT,                                                         --생산요청일자
            NVL(S017.PLT_PER_CNT, 0) AS PLT_PER_CNT,                                    --팔레트당 연수
            CASE WHEN NVL(S017.PLT_PER_CNT, 0) = 0 THEN 0
                ELSE TRUNC( S017.WRK_ORDR_QTY  / S017.PLT_PER_CNT * 1.0, 1) END AS PLT_CNT,             --팔레트 수량
            S009.CONTYPE        CON_TYPE,                                                                --컨테이너 유형
            CASE WHEN SUBSTR(S017.MATNR, 5, 1) = '2' THEN '수출' ELSE '내수' END AS DOMTC_DIV,      --내수구분
            S017.MATNR,                                                              --자재코드
            S017.KUNNRT,                                                             --거래처명            
            V_MWIDTH AS MWIDTH,                                                           --밀롤지폭
            NVL(V_MRCNT, 1) AS MRCNT,                                           --밀롤폭수   
            --NVL(V_MRCNT, S017.MRCNT) AS MRCNT,                                           --밀롤폭수   
            S017.PKCNT  AS PKCNT,                                                        --재단폭수
            S017.OAUART_DIV AS OAUART_DIV,                                            -- 판매문서
            S017.WLEN,    --가로길이
            S017.VLEN,   --세로길이
            S017.IN_PER_CNT,  --속당매수
            CASE WHEN NVL(S017.IN_PER_CNT, 0) = 0 THEN 0 
                ELSE (NVL(S017.PLT_PER_CNT, 0) * 500) / S017.IN_PER_CNT END  SHEET_CNT,        --속수
            S017.WRK_ORDR_QTY,                                              --계획연수    
            S017.TOT_WGT,                                                   --계획중량
            S017.WRK_ORDR_QTY * 500 AS MCNT,                                --매수   
            S017.MAN_CUT_YN,                                                --수재단여부
            (  SELECT W002.WLEN 
                 FROM TB_WRK002 W002
                WHERE S017.WERKS = W002.WERKS
                  AND S017.ORDER_NO = W002.ORDER_NO
                  AND W002.MAN_CUT_YN = 'Y'
                  AND NVL(W002.CNL_YN, 'N') = 'N'
                  AND ROWNUM = 1
            )                       TT_WLEN,                              --수재단 규격 가로
            (  SELECT W002.VLEN 
                 FROM TB_WRK002 W002
                WHERE S017.WERKS = W002.WERKS
                  AND S017.ORDER_NO = W002.ORDER_NO
                  AND W002.MAN_CUT_YN = 'Y'
                  AND NVL(W002.CNL_YN, 'N') = 'N'
                  AND ROWNUM = 1
            )                       TT_VLEN,                                --수재단 규격 세로
            FN_CD_VAL('PACK_TYPE', S017.PACKTYPE)  PACKTYPE,                 --포장타입
            S017.ORDER_RMK              ORDER_RMK
          FROM TB_SCH017 S017,  --재단
               TB_SCH009 S009   --포장
         WHERE S017.WERKS = S009.WERKS(+)
           AND S017.ORDER_NO = S009.FRAUFNR(+)
          -- AND S017.WERKS = W002.WERKS(+)
          -- AND S017.ORDER_NO = W002.ORDER_NO(+)
           AND S017.WERKS = P_WERKS
           AND S017.PRE_ORDER_NO = V_ORDER_NO
           AND S017.COMP_YN IN ('N', 'I')
           AND S017.USE_YN = 'Y';

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
   --     RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
        RAISE ;
        RS_CODE := 'E';
        RS_MSG  := SQLERRM;
        RETURN;
    --예외처리 종료
    END;
END;

/
