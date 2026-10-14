--------------------------------------------------------
--  DDL for Procedure SP_POP_LAMI_PC_PRT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_LAMI_PC_PRT" 
(
    P_WERKS     		IN VARCHAR2 	    --플랜트
    ,P_MACH_CD   		IN VARCHAR2 	    --설비코드
    ,P_IND_BCD          IN VARCHAR2 	    --개별바코드
    ,Lang       		IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE     		OUT VARCHAR2 
    ,RS_MSG      		OUT VARCHAR2
    ,CUR_1       		OUT SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : WRK073
 * PROGRAM NAME  : 인쇄/코팅 라벨 프린팅
 * VERSION       : 1.0.0
 * DESCRIPTION   : 인쇄/코팅 라벨 프린팅을 하기 위한 SP.
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
 * - [TB_LAMI_PC] : (.R..) 인쇄/코팅 작업지시
 *=============================================================================*/
AS 
    --프로그램 ID - 밀롤 인쇄용 조회
    V_PRG_NM        VARCHAR2(100)  := 'SP_POP_LAMI_PC_PRT';     -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID   varchar2(20) := 'TEST'; --USERID

    V_WRK_TYPE          varchar2(2);
    V_LINE              varchar2(10);
    V_PROC_CD           varchar2(20);
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);
    --parameter변수 처리
BEGIN
    BEGIN

    SELECT PROC_CD
    INTO V_PROC_CD
    FROM TB_MAS012
    WHERE 1 = 1
    AND MACH_CD = P_MACH_CD
    AND ROWNUM = 1
    ;

    IF V_PROC_CD = 'LP1' THEN
        BEGIN
                BEGIN
                    SELECT DECODE(SUBSTR(WRK_ORDR_NO,1,4), 'WOEX', 'X', 'Y')   -- 작업유형 : 'Y'는 정규생산, 'X'는 예외생산
                        INTO V_WRK_TYPE
                        FROM TB_WRK002
                        WHERE WERKS = P_WERKS
                           AND MACH_CD = P_MACH_CD
                           AND IND_BCD  = P_IND_BCD;
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                    RS_CODE := 'E';
                    RS_MSG := 'NO_DATA_FOUND';
                    RETURN;            
                END;

                --라미네이팅의 경우 정규생산만 있다는 전제로 작성
                V_WRK_TYPE := 'Y';

                BEGIN
                    SELECT LINE || 'win'
                        INTO V_LINE
                    FROM TB_MAS012
                    WHERE MACH_CD = P_MACH_CD;
                EXCEPTION 
                    WHEN NO_DATA_FOUND THEN
                    V_LINE := 'win';
                END;

                --작업유형 : 'Y'는 정규생산, 'X'는 예외생산
                IF V_WRK_TYPE = 'Y' THEN
                    OPEN CUR_1 FOR
                    SELECT '깨끗한 나라 CI' AS MAKER
                        ,S016.PRD_END_DTM AS END_DATE --생산일자
                        ,NVL(S016.STD,'') AS STD --규격
                        ,TO_CHAR(NVL(S016.PRFM_QTY, 0)) || 'KG' AS PRFM_QTY --중량                                --
--                        ,NVL(S16.HEIGHT,0) AS HEIGHT
                        ,M001.PCODE_NM                                                   --지종
                        ,TO_CHAR(NVL(S016.EQUIL, 0)) + 'g/㎡' AS BS_WGT                                    --평량
                        ,W002.WRK_CLASS || ' ' || USRMA.NMLAST  AS WRK_NAME                 -- 반, 작업자
                        ,NVL(S016.LOT_BUF,' ') AS LOT_NO
                        ,TO_NUMBER(SUBSTR(NVL(S016.IND_BCD,' ') , -4)) AS BAR_NUM
                        ,NVL(S016.IND_BCD,' ') AS BAR_CODE
                      FROM TB_WRK002 W002,
                           TB_MAS001 M001,
                           TB_MAS009 M009,
                           USRMA USRMA,
        --                   TB_SCH015 S015,
                           TB_LAMI_PC S016
                     WHERE W002.WERKS = S016.WERKS(+)
                       AND W002.WRK_ORDR_NO = S016.WRK_ORDR_NO(+)
                       AND W002.WRK_ORDR_SEQNO = S016.WRK_ORDR_SEQNO(+)
        --               AND W002.WERKS = S015.WERKS(+)
        --               AND S016.PRE_ORDER_NO = S015.ORDER_NO(+)
                       AND W002.WERKS = M001.WERKS(+)
                       AND W002.MATNR = M001.MATNR(+)
                       AND M009.CUST_DIV = 'C'      -- 거래처구분(C:거래처, v=공급처)
                       AND W002.KUNNR = M009.CUST_CD(+)
                       AND W002.REGID = USRMA.USERID(+)
                       AND W002.WERKS = P_WERKS
                       AND W002.MACH_CD = P_MACH_CD
                       AND W002.IND_BCD = P_IND_BCD;
            --           AND W002.WRK_ORDR_NO = P_WRK_ORDR_NO
            --           AND W002.WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
        --        ELSE
        --            OPEN CUR_1 FOR
        --            SELECT M001.PCODE_NM,                                                   --지종
        --                NVL(W002.ROLLCNT, '0') AS ROLLCNT,                                  --실적권치수
        --                NVL(W002.PRFM_QTY, '0') AS PRFM_QTY,                                --실적중량
        --                NVL(S019.BS_WGT, '0') AS BS_WGT,                                    --평량
        --    --            SUBSTR(W002.MATNR, 10, 4) || '*' || SUBSTR(W002.MATNR, 14, 4) as MATNR_SPEC,  --규격
        --                SUBSTR(W002.MATNR, 10, 4) || '*0' AS MATNR_SPEC,                    --규격
        --                W002.WRK_SEQ,                                                       --생산순번
        --                W002.WIDTH_NO,                                                      --지폭순서
        --                ''      AS JR_MACHINE_NM,                                       --점보롤호기
        --                ''      AS MR_MACHINE_NM,                                   --밀롤호기
        --                ''      AS CT_MACHINE_NM,                                  --재단호기
        --                S019.WLEN           AS MWIDTH_INPUT,                                 --실지폭
        --                ''                  AS MWIDTH_USER,                         --사용자 입력한 지폭
        --                W002.MATNR,                                                         --품목코드
        --                W002.CORE,                                                          --지관
        --                NVL(FN_CD_VAL('PACK_TYPE', W002.PACKTYPE), ' ')     PACKTYPE,       --포장타입
        --                M009.CUST_NM,                                                       --거래처명
        --                TO_CHAR(W002.REGDATE, 'YYYY-MM-DD HH24:MI') AS WRK_DATE,            --생산일시
        --                W002.WRK_CLASS,                                                     -- 반
        --                USRMA.NMLAST AS WRK_NAME,                                           -- 작업자
        --                USRMA.USERID AS WRK_ID,                                             -- 작업자 ID
        --                W002.LOT_NO AS LOT_NO,                                              -- LOT NO
        --                S019.ORDER_NO AS ORDER_NO,                                          -- 오더 번호
        --                S019.VBELN || LPAD(S019.POSNR, 6, '0') AS SALES_ORDR_NO,            --Sales Order No
        --                'ROLL'          AS NEXT_PROC,  --다음공정
        --                ' '             AS SLITER,                          --슬리터구분
        --                ''              AS ORDER_RMK,                     -- 생산오더 비고사항
        --                W002.RMK                                      -- 비고사항
        --              FROM TB_WRK002 W002,
        --                   TB_MAS001 M001,
        --                   TB_MAS009 M009,
        --                   USRMA USRMA,
        --                   TB_SCH019 S019
        --             WHERE W002.WERKS = S019.WERKS(+)
        --               AND W002.WRK_ORDR_NO = S019.WRK_ORDR_NO(+)
        --               AND W002.WRK_ORDR_SEQNO = S019.WRK_ORDR_SEQNO(+)
        --               AND W002.WERKS = M001.WERKS(+)
        --               AND W002.MATNR = M001.MATNR(+)
        --               AND M009.CUST_DIV = 'C'      -- 거래처구분(C:거래처, v=공급처)
        --               AND W002.KUNNR = M009.CUST_CD(+)
        --               AND W002.REGID = USRMA.USERID(+)
        --               AND W002.WERKS = P_WERKS
        --               AND W002.MACH_CD = P_MACH_CD
        --               AND W002.IND_BCD = P_IND_BCD;
                END IF;
        END;
    ELSIF V_PROC_CD = 'LS1' THEN
        BEGIN
            BEGIN
                SELECT DECODE(SUBSTR(WRK_ORDR_NO,1,4), 'WOEX', 'X', 'Y')   -- 작업유형 : 'Y'는 정규생산, 'X'는 예외생산
                    INTO V_WRK_TYPE
                    FROM TB_WRK002
                    WHERE WERKS = P_WERKS
                       AND MACH_CD = P_MACH_CD
                       AND IND_BCD  = P_IND_BCD;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                RS_CODE := 'E';
                RS_MSG := 'NO_DATA_FOUND';
                RETURN;            
            END;

            --라미네이팅의 경우 정규생산만 있다는 전제로 작성
            V_WRK_TYPE := 'Y';

            BEGIN
                SELECT LINE || 'win'
                    INTO V_LINE
                FROM TB_MAS012
                WHERE MACH_CD = P_MACH_CD;
            EXCEPTION 
                WHEN NO_DATA_FOUND THEN
                V_LINE := 'win';
            END;

            --작업유형 : 'Y'는 정규생산, 'X'는 예외생산
            IF V_WRK_TYPE = 'Y' THEN
                OPEN CUR_1 FOR
                    SELECT '깨끗한 나라 CI' AS MAKER
                        ,S016.PRD_END_DTM AS END_DATE --생산일자
                        ,NVL(S016.STD,'') AS STD --규격
                        ,TO_CHAR(NVL(S016.PRFM_QTY, 0)) || 'KG' AS PRFM_QTY --중량                                --
                        ,NVL(S016.HEIGHT,0) AS HEIGHT
                        ,M001.PCODE_NM                                                   --지종
                        ,TO_CHAR(NVL(S016.EQUIL, 0)) + 'g/㎡' AS BS_WGT                                    --평량
                        ,W002.WRK_CLASS || ' ' || USRMA.NMLAST  AS WRK_NAME                 -- 반, 작업자
                        ,NVL(S016.LOT_BUF,' ') AS LOT_NO
                        ,TO_NUMBER(SUBSTR(NVL(S016.IND_BCD,' ') , -4)) AS BAR_NUM
                        ,NVL(S016.IND_BCD,' ') AS BAR_CODE
                  FROM TB_WRK002 W002,
                       TB_MAS001 M001,
                       TB_MAS009 M009,
                       USRMA USRMA,
    --                   TB_SCH015 S015,
                       TB_LAMI_SL S016
                 WHERE W002.WERKS = S016.WERKS(+)
                   AND W002.WRK_ORDR_NO = S016.WRK_ORDR_NO(+)
                   AND W002.WRK_ORDR_SEQNO = S016.WRK_ORDR_SEQNO(+)
    --               AND W002.WERKS = S015.WERKS(+)
    --               AND S016.PRE_ORDER_NO = S015.ORDER_NO(+)
                   AND W002.WERKS = M001.WERKS(+)
                   AND W002.MATNR = M001.MATNR(+)
                   AND M009.CUST_DIV = 'C'      -- 거래처구분(C:거래처, v=공급처)
                   AND W002.KUNNR = M009.CUST_CD(+)
                   AND W002.REGID = USRMA.USERID(+)
                   AND W002.WERKS = P_WERKS
                   AND W002.MACH_CD = P_MACH_CD
                   AND W002.IND_BCD = P_IND_BCD;
        --           AND W002.WRK_ORDR_NO = P_WRK_ORDR_NO
        --           AND W002.WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
    --        ELSE
    --            OPEN CUR_1 FOR
    --            SELECT M001.PCODE_NM,                                                   --지종
    --                NVL(W002.ROLLCNT, '0') AS ROLLCNT,                                  --실적권치수
    --                NVL(W002.PRFM_QTY, '0') AS PRFM_QTY,                                --실적중량
    --                NVL(S019.BS_WGT, '0') AS BS_WGT,                                    --평량
    --    --            SUBSTR(W002.MATNR, 10, 4) || '*' || SUBSTR(W002.MATNR, 14, 4) as MATNR_SPEC,  --규격
    --                SUBSTR(W002.MATNR, 10, 4) || '*0' AS MATNR_SPEC,                    --규격
    --                W002.WRK_SEQ,                                                       --생산순번
    --                W002.WIDTH_NO,                                                      --지폭순서
    --                ''      AS JR_MACHINE_NM,                                       --점보롤호기
    --                ''      AS MR_MACHINE_NM,                                   --밀롤호기
    --                ''      AS CT_MACHINE_NM,                                  --재단호기
    --                S019.WLEN           AS MWIDTH_INPUT,                                 --실지폭
    --                ''                  AS MWIDTH_USER,                         --사용자 입력한 지폭
    --                W002.MATNR,                                                         --품목코드
    --                W002.CORE,                                                          --지관
    --                NVL(FN_CD_VAL('PACK_TYPE', W002.PACKTYPE), ' ')     PACKTYPE,       --포장타입
    --                M009.CUST_NM,                                                       --거래처명
    --                TO_CHAR(W002.REGDATE, 'YYYY-MM-DD HH24:MI') AS WRK_DATE,            --생산일시
    --                W002.WRK_CLASS,                                                     -- 반
    --                USRMA.NMLAST AS WRK_NAME,                                           -- 작업자
    --                USRMA.USERID AS WRK_ID,                                             -- 작업자 ID
    --                W002.LOT_NO AS LOT_NO,                                              -- LOT NO
    --                S019.ORDER_NO AS ORDER_NO,                                          -- 오더 번호
    --                S019.VBELN || LPAD(S019.POSNR, 6, '0') AS SALES_ORDR_NO,            --Sales Order No
    --                'ROLL'          AS NEXT_PROC,  --다음공정
    --                ' '             AS SLITER,                          --슬리터구분
    --                ''              AS ORDER_RMK,                     -- 생산오더 비고사항
    --                W002.RMK                                      -- 비고사항
    --              FROM TB_WRK002 W002,
    --                   TB_MAS001 M001,
    --                   TB_MAS009 M009,
    --                   USRMA USRMA,
    --                   TB_SCH019 S019
    --             WHERE W002.WERKS = S019.WERKS(+)
    --               AND W002.WRK_ORDR_NO = S019.WRK_ORDR_NO(+)
    --               AND W002.WRK_ORDR_SEQNO = S019.WRK_ORDR_SEQNO(+)
    --               AND W002.WERKS = M001.WERKS(+)
    --               AND W002.MATNR = M001.MATNR(+)
    --               AND M009.CUST_DIV = 'C'      -- 거래처구분(C:거래처, v=공급처)
    --               AND W002.KUNNR = M009.CUST_CD(+)
    --               AND W002.REGID = USRMA.USERID(+)
    --               AND W002.WERKS = P_WERKS
    --               AND W002.MACH_CD = P_MACH_CD
    --               AND W002.IND_BCD = P_IND_BCD;
            END IF;

        END;
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
        --RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
        RAISE;

        RS_CODE := 'E';
        RS_MSG  := SQLERRM;
        RETURN;
    --예외처리 종료
    END;
END;

/
