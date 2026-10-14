
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_AUTO_PKG_PRFM_INFO" (
    P_IND_BCD           IN VARCHAR2
    ,RS_CODE     		OUT VARCHAR2
    ,RS_MSG      		OUT VARCHAR2
    ,CUR_1       		OUT SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : POP_WRK07
 * PROGRAM NAME  : PS 실적 정보조회
 * VERSION       : 1.0.0
 * DESCRIPTION   : 원지자동포장에 필요한 실적 라벨 정보를 조회.
 *
 * AUTHOR NAME   : 김지언
 * CREATE DATE   : 2025/11/14
 * SYSTEM NAME   : 원지포장자동화 MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description
 * ------------ ------- ------------- ------------------------------------------
 * 2025/11/14    1.0.0   김지언         (PS)개별바코드를 조건으로 실적정보 조회
 *==============================================================================
 *  관련 테이블
 * - [TB_WRK002] : (.R..) PS 생산실적 이력
 * - [TB_SCH016] : (.R..) 제지 밀롤작업지시
 * - [TB_MAS001] : (.R..) 자재 기준 정보
 *=============================================================================*/
AS
    --프로그램 ID - 밀롤 인쇄용 조회
    V_PRG_NM            VARCHAR2(100)  := 'SP_AUTO_PKG_PRFM_INFO';     -- PROCEDURE NAME
    V_PLT_CD            VARCHAR2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID      VARCHAR2(20) := 'TEST'; --USERID

    V_WRK_TYPE          VARCHAR2(2);
    V_LINE              VARCHAR2(10);
    V_MACH_CD           VARCHAR2(10);
    V_WERKS             TB_WRK002.WERKS%TYPE := 'P100';

    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);

    --parameter변수 처리
BEGIN
    BEGIN
        BEGIN
            SELECT DECODE(SUBSTR(WRK_ORDR_NO,1,4), 'WOEX', 'X', 'Y')   -- 작업유형 : 'Y'는 정규생산, 'X'는 예외생산
                , MACH_CD
                INTO V_WRK_TYPE, V_MACH_CD
            FROM TB_WRK002
            WHERE WERKS = V_WERKS
               AND IND_BCD  = P_IND_BCD;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
            RS_CODE := 'E';
            RS_MSG := 'NO_DATA_FOUND';

            INSERT INTO PROC_LOG(SQL_STR, SQL_PARAM1) VALUES (RS_CODE || ' - ' || P_IND_BCD, 'SP_AUTO_PKG_PRFM_INFO');
            RETURN;
        END;

        BEGIN
            SELECT LINE_NM || 'win'
                INTO V_LINE
            FROM TB_MAS012
            WHERE MACH_CD = V_MACH_CD;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
            V_LINE := 'win';
        END;

        --작업유형 : 'Y'는 정규생산, 'X'는 예외생산
        IF V_WRK_TYPE = 'Y' THEN
            OPEN CUR_1 FOR
            SELECT M001.PCODE_NM                                                                                AS PCODE_NM,        -- 지종명
                   M001.PCODE                                                                                        AS PCODE,      -- 지종코드
                   NVL(W002.ROLLCNT, '0')                                                                            AS ROLLCNT,    -- 실적권치수
                   NVL(W002.PRFM_QTY, '0')                                                                           AS PRFM_QTY,   -- 실적중량
                   NVL(S016.BS_WGT, '0')                                                                             AS BS_WGT,     -- 평량
                   SUBSTR(W002.MATNR, 10, 4) || '*0'                                                                 AS MATNR_SPEC, -- 규격
                   W002.WRK_SEQ                                                                                      AS WRK_SEQ,    -- 생산순번
                   W002.WIDTH_NO                                                                                     AS WIDTH_NO,   -- 지폭순서
                   S015.MACHINE                                                                                      AS JR_MACHINE_NM, -- 점보롤호기
                   W002.MACH_CD                                                                                      AS MR_MACHINE_NM, -- 밀롤호기
                   S016.TO_MACHINE                                                                                   AS CT_MACHINE_NM, -- 재단호기
                   S016.MWIDTH_INPUT                                                                                 AS MWIDTH_INPUT, -- 작업지시의 실지폭
                   W002.WIDTH                                                                                        AS MWIDTH_USER, -- 사용자 입력한 지폭
                   W002.MATNR                                                                                        AS MATNR, -- 품목코드
                   W002.CORE                                                                                         AS CORE, -- 지관
                   NVL(FN_CD_VAL('PACK_TYPE', W002.PACKTYPE), ' ')                                                   AS PACKTYPE, -- 포장타입
                   S016.KUNNRT                                                                                       AS CUST_NM, -- bug fix : (원지 거래처 누락) MAS009에 누락된 거래처가 존재하여 작업지시의 거래처명 표시
                   TO_CHAR(W002.REGDATE, 'YYYY-MM-DD HH24:MI')                                                       AS WRK_DATE, -- 생산일시
                   W002.WRK_CLASS                                                                                    AS WRK_CLASS, -- 반
                   USRMA.NMLAST                                                                                      AS WRK_NAME, -- 작업자
                   USRMA.USERID                                                                                      AS WRK_ID, -- 작업자 ID
                   V_LINE || USRMA.EMPLID                                                                            as EMPLID, -- 사원번호
                   W002.LOT_NO                                                                                       AS LOT_NO, -- LOT NO
                   S016.ORDER_NO                                                                                     AS ORDER_NO, -- 오더 번호
                   M009.LAND1                                                                                        AS LAND1, -- 국가
                   S016.VBELN || LPAD(S016.POSNR, 6, '0')                                                            AS SALES_ORDR_NO, -- Sales Order No
                   CASE WHEN NVL(S016.SHEET, ' ') = 'X' THEN 'SHEET' ELSE 'ROLL' END                                 AS NEXT_PROC, -- 다음공정
                   S016.REMARK                                                                                       AS ORDER_RMK, -- 생산오더 비고사항
                   NVL(S016.SLITER, 'X')                                                                             AS SLITER, -- 슬리터구분

                   /*원지포장자동화 바코드 정보*/
                   NVL(W002.MRLDCK, 'N')                                                                             AS MR_STOCK_YN, -- 밀롤적치여부

                   /* 지관마개 여부 */
--                    CASE
--                        WHEN S016.CORE_INCH IS NULL THEN /* NULL = 지관인치여부 로 판단*/
                           CASE
                               WHEN W002.CORE IN (12, 6) THEN '1' -- 12인치, 6인치는 항상 O, 3인치는 X
                               ELSE '0'
--                                END
--                        WHEN S016.COVER_YN = 'X' THEN '1'
--                        WHEN S016.COVER_YN IS NULL THEN '0'
--                        ELSE '0'
                   END                                                                                               AS AUTO_COVER_YN, -- 지관마개여부(1자리)

                   /* 골판지 여부 */
                   CASE
                       WHEN S016.CORE_INCH IS NULL THEN /* NULL = 지관인치여부 로 판단*/
                           CASE
                               WHEN W002.CORE = 12 THEN '1' -- 12인치 : O
                               WHEN W002.CORE = 6 THEN '0' -- 6인치 : X
                               WHEN W002.CORE = 3 AND (SELECT USARG2
                                                       FROM CMCDV
                                                       WHERE 1 = 1
                                                         AND CMCDKY = 'P100_PROD'
                                                         AND CMCDVL = M001.PCODE) = '1'
                                   THEN '1' -- 3인치 + 금은박 : O
                               ELSE '0' -- 나머지 3인치 : X
                               END
                       WHEN S016.CORR_YN = 'X' THEN '1'
                       WHEN S016.CORR_YN IS NULL THEN '0'
                       ELSE '0'
                   END                                                                                               AS AUTO_CORR_YN, -- 골판지여부(1자리) CORRUGATED

                   CASE V_MACH_CD
                        WHEN 'PSA01' THEN '2' /*신형 슬리터 #1 역방향*/
                        WHEN 'PMA03' THEN '2' /*신형 리와인더 #3-2 역방향*/
                        WHEN 'PMA02' THEN '1' /*구형 리와인더 #3-1 정방향*/
                        ELSE '2' /*리와인더 #2 역방향*/
                   END                                                                                               AS AUTO_MACH_NEWOLD, -- 신형/구형(1자리)

                   /* 포장 여부 */
                   CASE
                       WHEN S016.CORE_INCH IS NULL THEN '1' /* NULL = 지관인치여부 로 판단*/
                       WHEN S016.PACK_YN = 'X' THEN '1'
                       WHEN S016.PACK_YN IS NULL THEN '0'
                       ELSE '0'
                   END                                                                                               AS AUTO_PACK_YN, -- 포장여부

                   /* 지관인치 */
                   CASE
                       WHEN S016.CORE_INCH IS NULL THEN LPAD(TO_CHAR(NVL(CORE, '0')), 2, '0') /* NULL = 지관인치여부 로 판단*/
                       WHEN S016.CORE_INCH IS NOT NULL THEN S016.CORE_INCH
                       ELSE S016.CORE_INCH
                   END                                                                                                AS AUTO_CORE, -- 지관인치(2자리)
--                  LPAD(TO_CHAR(NVL(CORE, '0')), 2, '0')                                                               AS AUTO_CORE,         -- 지관인치(2자리)

                   LPAD(TO_CHAR(NVL(S016.BS_WGT, '0')), 3, '0')                                                      AS AUTO_BS_WGT, -- 평량(3자리)
                   LPAD(TO_CHAR(NVL(ROLLCNT, '0')), 5, '0')                                                          AS AUTO_ROLLCNT, -- 권치수(5자리)
                   W002.RMK                                                                                          AS RMK, -- 비고사항
                   NVL((SELECT USARG1 FROM CMCDV WHERE 1 = 1 AND CMCDKY = 'P100_PROD' AND CMCDVL = S016.PCODE), '5') AS AUTO_PRTGBN -- CI 프린트 구분 값
--                 CASE P_IND_BCD
--                     WHEN '25B19M0001' THEN '1'  /* 테스트 */
--                     WHEN '25901M0354' THEN '2'  /* 테스트 */
--                     WHEN '25901M0358' THEN '3'  /* 테스트 */
--                     WHEN '24908M0282' THEN '4'  /* 테스트 */
--                     WHEN '23925M0076' THEN '5'  /* 테스트 */
--                     ELSE NVL((SELECT USARG1 FROM CMCDV WHERE 1 = 1 AND CMCDKY = 'P100_PROD' AND CMCDVL = S016.PCODE), '5')
--                 END AS AUTO_PRTGBN      -- CI 프린트 구분 값
            FROM TB_WRK002 W002
                LEFT OUTER JOIN TB_MAS001 M001  ON W002.WERKS = M001.WERKS      AND W002.MATNR = M001.MATNR
                LEFT OUTER JOIN USRMA USRMA     ON W002.REGID = USRMA.USERID
                LEFT OUTER JOIN TB_SCH016 S016  ON W002.WERKS = S016.WERKS      AND W002.WRK_ORDR_NO = S016.WRK_ORDR_NO
                                                                                AND W002.WRK_ORDR_SEQNO = S016.WRK_ORDR_SEQNO
                LEFT OUTER JOIN TB_SCH015 S015  ON W002.WERKS = S015.WERKS      AND S016.PRE_ORDER_NO = S015.ORDER_NO
                LEFT OUTER JOIN TB_MAS009 M009  ON S016.KUNNR = M009.KUNNR      AND M009.CUST_DIV = 'C' -- 거래처구분(C:거래처, v=공급처)
            WHERE 1=1
                AND W002.WERKS = V_WERKS
                AND W002.MACH_CD = V_MACH_CD
                AND W002.IND_BCD = P_IND_BCD;
        ELSE
            OPEN CUR_1 FOR
            SELECT M001.PCODE_NM                                                                                    AS PCODE_NM,        -- 지종명
                M001.PCODE                                                                                          AS PCODE,           -- 지종코드
                NVL(W002.ROLLCNT, '0')                                                                              AS ROLLCNT,         -- 실적권치수
                NVL(W002.PRFM_QTY, '0')                                                                             AS PRFM_QTY,        -- 실적중량
                NVL(S019.BS_WGT, '0')                                                                               AS BS_WGT,          -- 평량
                SUBSTR(W002.MATNR, 10, 4) || '*0'                                                                   AS MATNR_SPEC,      -- 규격
                W002.WRK_SEQ                                                                                        AS WRK_SEQ,         -- 생산순번
                W002.WIDTH_NO                                                                                       AS WIDTH_NO,        -- 지폭순서
                ''                                                                                                  AS JR_MACHINE_NM,   -- 점보롤호기
                ''                                                                                                  AS MR_MACHINE_NM,   -- 밀롤호기
                ''                                                                                                  AS CT_MACHINE_NM,   -- 재단호기
                S019.WLEN                                                                                           AS MWIDTH_INPUT,    -- 실지폭
                ''                                                                                                  AS MWIDTH_USER,     -- 사용자 입력한 지폭
                W002.MATNR                                                                                          AS MATNR,           -- 품목코드
                W002.CORE                                                                                           AS CORE,            -- 지관
                NVL(FN_CD_VAL('PACK_TYPE', W002.PACKTYPE), ' ')                                 AS PACKTYPE,        -- 포장타입
                M009.CUST_NM                                                                                        AS CUST_NM,         -- 거래처명
                TO_CHAR(W002.REGDATE, 'YYYY-MM-DD HH24:MI')                                                         AS WRK_DATE,        -- 생산일시
                W002.WRK_CLASS                                                                                      AS WRK_CLASS,       -- 반
                USRMA.NMLAST                                                                                        AS WRK_NAME,        -- 작업자
                USRMA.USERID                                                                                        AS WRK_ID,          -- 작업자 ID
                V_LINE || USRMA.EMPLID                                                                              AS EMPLID,          -- 사원번호
                W002.LOT_NO                                                                                         AS LOT_NO,          -- LOT NO
                S019.ORDER_NO                                                                                       AS ORDER_NO,        -- 오더 번호
                S019.VBELN || LPAD(S019.POSNR, 6, '0')                                                              AS SALES_ORDR_NO,   -- Sales Order No
                'ROLL'                                                                                              AS NEXT_PROC,       -- 다음공정
                'X'                                                                                                 AS SLITER,          -- 슬리터구분
                ''                                                                                                  AS ORDER_RMK,       -- 생산오더 비고사항

                /*원지포장자동화 바코드 정보*/
                NVL(MRLDCK, 'N')                                                                                    AS MR_STOCK_YN,     -- 밀롤적치여부

                /* 지관마개 여부 */
--                CASE
--                    WHEN S019.CORE_INCH IS NULL THEN /* NULL = 지관인치여부 로 판단*/
                        CASE
                            WHEN W002.CORE IN (12, 6) THEN '1' -- 12인치, 6인치는 항상 O, 3인치는 X
                            ELSE '0'
--                        END
--                    WHEN S019.COVER_YN = 'X'    THEN '1'
--                    WHEN S019.COVER_YN IS NULL  THEN '0'
--                    ELSE '0'
                END                                                                                                 AS AUTO_COVER_YN,     -- 지관마개여부(1자리)

                /* 골판지 여부 */
                CASE
                    WHEN S019.CORE_INCH IS NULL THEN /* NULL = 지관인치여부 로 판단*/
                        CASE
                           WHEN W002.CORE = 12  THEN '1' -- 12인치 : O
                           WHEN W002.CORE = 6   THEN '0' -- 6인치 : X
                           WHEN W002.CORE = 3 AND (SELECT USARG2
                                                   FROM CMCDV
                                                   WHERE 1 = 1
                                                     AND CMCDKY = 'P100_PROD'
                                                     AND CMCDVL = M001.PCODE) = '1'
                                                THEN '1' -- 3인치 + 금은박 : O
                           ELSE '0' -- 나머지 3인치 : X
                        END
                    WHEN S019.CORR_YN = 'X'     THEN '1'
                    WHEN S019.CORR_YN IS NULL   THEN '0'
                    ELSE '0'
                END                                                                                                 AS AUTO_CORR_YN,        -- 골판지여부(1자리) CORRUGATED

                CASE V_MACH_CD
                    WHEN 'PSA01' THEN '2' /*신형 슬리터 #1 역방향*/
                    WHEN 'PMA03' THEN '2' /*신형 리와인더 #3-2 역방향*/
                    WHEN 'PMA02' THEN '1' /*구형 리와인더 #3-1 정방향*/
                    ELSE '2' /*리와인더 #2 역방향*/
                END                                                                                                 AS AUTO_MACH_NEWOLD,    -- 신형/구형(1자리)

                /* 포장 여부 */
                CASE
                   WHEN S019.CORE_INCH IS NULL  THEN '1' /* NULL = 지관인치여부 로 판단*/
                   WHEN S019.PACK_YN = 'X'      THEN '1'
                   WHEN S019.PACK_YN IS NULL    THEN '0'
                   ELSE '0'
                END                                                                                                 AS AUTO_PACK_YN,        -- 포장여부

                /* 지관인치 */
                CASE
                   WHEN S019.CORE_INCH IS NULL      THEN LPAD(TO_CHAR(NVL(CORE, '0')), 2, '0') /* NULL = 지관인치여부 로 판단*/
                   WHEN S019.CORE_INCH IS NOT NULL  THEN S019.CORE_INCH
                   ELSE S019.CORE_INCH
                END                                                                                                 AS AUTO_CORE,           -- 지관인치(2자리)
--                        LPAD(TO_CHAR(NVL(CORE, '0')), 2, '0')                                                          AS AUTO_CORE,         -- 지관인치(2자리)
                LPAD(TO_CHAR(NVL(S019.BS_WGT, '0')), 3, '0')                                                        AS AUTO_BS_WGT,         -- 평량(3자리)
                LPAD(TO_CHAR(NVL(ROLLCNT, '0')), 5, '0')                                                            AS AUTO_ROLLCNT,        -- 권치수(5자리)

                W002.RMK                                                                                            AS RMK,                 -- 비고사항
                NVL((SELECT USARG1 FROM CMCDV WHERE 1 = 1 AND CMCDKY = 'P100_PROD' AND CMCDVL = S019.PCODE), '5')   AS AUTO_PRTGBN          -- CI 프린트 구분 값
            FROM TB_WRK002 W002
                LEFT OUTER JOIN TB_MAS001 M001  ON W002.WERKS = M001.WERKS      AND W002.MATNR = M001.MATNR
                LEFT OUTER JOIN TB_MAS009 M009  ON W002.KUNNR = M009.CUST_CD    AND M009.CUST_DIV = 'C' -- 거래처구분(C:거래처, v=공급처)
                LEFT OUTER JOIN USRMA USRMA     ON W002.REGID = USRMA.USERID
                LEFT OUTER JOIN TB_SCH019 S019  ON W002.WERKS = S019.WERKS      AND W002.WRK_ORDR_NO = S019.WRK_ORDR_NO
                                                                                AND W002.WRK_ORDR_SEQNO = S019.WRK_ORDR_SEQNO
            WHERE 1=1
                AND W002.WERKS = V_WERKS
                AND W002.MACH_CD = V_MACH_CD
                AND W002.IND_BCD = P_IND_BCD;
        END IF;

        RS_CODE := 'S';

        INSERT INTO PROC_LOG(SQL_STR, SQL_PARAM1) VALUES (RS_CODE || ' - ' || P_IND_BCD, 'SP_AUTO_PKG_PRFM_INFO');
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
