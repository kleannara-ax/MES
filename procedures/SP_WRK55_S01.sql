
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_WRK55_S01" (
	P_TYPE           IN    varchar2, -- LIST
	P_JSON_STR       IN    CLOB ,
	P_SUCCESS       OUT    varchar2,
	P_ERR_MSG       OUT    varchar2,
	P_RS_LIST       OUT    SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : WRK55
 * PROGRAM NAME  : 화장지 실적 현황
 * VERSION       : 1.0.0
 * DESCRIPTION   : 화장지(P200) 투입자재 개별바코드 단위로
 *                 생산량 / 사용량 / 폐품 / 잔량 및 SAP I/F 전송결과를 조회한다.
 *                 선행조건 : 생산량 = 사용량 + 폐품  (불일치 시 CHK_RSLT = '불일치')
 *
 *                 - 조회 대상 : 조회기간(사용 실적일자)에 사용/폐품 이력이 있는 투입자재 바코드
 *                 - 수량 기준 : 바코드 전체(기간 무관) 누적값
 *                     생산량  : TB_WRK001.PRFM_QTY 합계 (원지 H000% 는 TB_INV001.RCV_WGT)
 *                     사용량  : TB_INV010.USE_QTY  (USE_DIV 1:정상, 2:보정)
 *                     폐품    : TB_INV010.USE_QTY  (USE_DIV 3:폐품)
 *                     잔량    : TB_INV001.STCK_QTY(STCK_STA='0') + TB_INV003.STCK_QTY
 *                   ※ SP_WRK10_S01(LIST3), SP_INV06_S01(LIST2) 계산 로직 준용
 *                 - I/F 결과 (S:성공 / E:오류 / N:미전송)
 *                     실적 : TB_WRK001.SDOC_NO (공백:미전송, 'E':오류, 그외:성공)
 *                     투입 : TB_INV013.SDOC_NO + TB_IFS008.ZRESULT (자재+LOT 단위)
 *                     폐품 : TB_WRK016.SDOC_NO + TB_IFS012.ZRESULT
 *
 * AUTHOR NAME   :
 * CREATE DATE   : 2026/10/15
 * SYSTEM NAME   : MES
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description
 * ------------ ------- ------------- ------------------------------------------
 * 2026/10/15    1.0.0                  Initial Version
 * 2026/10/16    1.1.0                  LOG_LIST : RFC 전송로그(프로시저/RFC/파라미터/수량) 조회 추가
 *==============================================================================
 *  관련 테이블
 *      - [TB_INV010]  : (.R..) 자재투입이력 (사용/보정/폐품)
 *      - [TB_WRK001]  : (.R..) HL 생산실적
 *      - [TB_INV001]  : (.R..) 창고별 재고
 *      - [TB_INV003]  : (.R..) 자재투입(공정재고)
 *      - [TB_INV013]  : (.R..) 일자별 자재사용량(일마감)
 *      - [TB_WRK016]  : (.R..) 폐품 등록정보(HL)
 *      - [TB_IFS002]  : (.R..) I/F 실적
 *      - [TB_IFS008]  : (.R..) I/F 자재투입량
 *      - [TB_IFS012]  : (.R..) I/F 폐품
 *      - [TB_MAS001]  : (.R..) 자재 마스터
 *      - [TB_MAS012]  : (.R..) 설비 마스터
 *      - [V_WRK_ORDR2]: (.R..) 작업지시 VIEW
 *      - [TB_WRK055]  : (.R..) 화장지 RFC 전송 로그(헤더)      - P_TYPE = 'LOG_LIST'
 *      - [TB_WRK055_D]: (.R..) 화장지 RFC 전송 로그(파라미터)
 *=============================================================================*/

AS

    V_PRG_NM          VARCHAR2(100)  := 'SP_WRK55_S01';     -- PROCEDURE NAME

    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5)           := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);

    -- JSON을 위한 변수선언 영역
    V_JSON           JSON_OBJECT_T;

    -- SQL 처리용 변수선언 영역
    V_SQL            CLOB;
    V_RANGE_SQL      varchar2(4000);
    V_DEBUG          varchar2(1);

    -- 세션값 처리용 변수선언 영역
    V_PLT_CD         varchar2(4);
    V_SESS_USER_ID   varchar2(20);

    -- 조건절 처리용 변수선언 영역
    V_WERKS          TB_INV010.WERKS%TYPE;
    V_SDATE          varchar2(10);         -- 사용 실적일자 From
    V_EDATE          varchar2(10);         -- 사용 실적일자 To
    V_PROC_DIV       varchar2(2);          -- 공정구분 (AA:합지, RA:가공, PG:예외생산)
    V_CHK_FILTER     varchar2(2);          -- 판정 (NG:불일치, OK:정상)
    V_IF_FILTER      varchar2(1);          -- 전송상태 (S:성공, E:오류, N:미전송)
    V_PRG_FILTER     varchar2(100);        -- 프로시저명 (LOG_LIST)
    V_QTY_DIV        varchar2(10);         -- 수량구분 (LOG_LIST)
    V_IF_ID          varchar2(30);         -- 인터페이스 ID (LOG_LIST)
    V_MATNR          varchar2(40);
    V_LOT_NO         varchar2(30);
    V_ORDER_NO       varchar2(20);
    V_DOC_NO         varchar2(40);

    -- JSON 키 존재 시에만 값 추출
    FUNCTION GET_STR(P_KEY IN VARCHAR2) RETURN VARCHAR2 IS
    BEGIN
        IF V_JSON.has(P_KEY) THEN
            RETURN TRIM(V_JSON.get_string(P_KEY));
        END IF;
        RETURN NULL;
    END;

BEGIN

   OPEN P_RS_LIST FOR
   SELECT NULL FROM DUAL WHERE ROWNUM = 0;

   V_DEBUG := 'N';

   V_JSON := JSON_OBJECT_T.parse(P_JSON_STR);

   V_SESS_USER_ID       :=      GET_STR('SES_USER_ID');
   V_PLT_CD             :=      GET_STR('SES_PLNTKY');

   /* 조건값 할당 */
   V_RANGE_SQL          :=      GET_STR('RANGE_SQL');       -- 실적일자/설비/오더/자재/LOT/바코드 (공통 RANGE)
   V_WERKS              :=      NVL(GET_STR('WERKS'), 'P200');
   V_SDATE              :=      REPLACE(GET_STR('SDATE'), '-', '');
   V_EDATE              :=      REPLACE(GET_STR('EDATE'), '-', '');
   V_PROC_DIV           :=      GET_STR('PROC_DIV');
   V_CHK_FILTER         :=      GET_STR('CHK_FILTER');
   V_IF_FILTER          :=      GET_STR('IF_FILTER');
   V_PRG_FILTER         :=      UPPER(GET_STR('PRG_NM'));
   V_QTY_DIV            :=      GET_STR('QTY_DIV');
   V_IF_ID              :=      GET_STR('IF_ID');
   V_MATNR              :=      GET_STR('MATNR');
   V_LOT_NO             :=      GET_STR('LOT_NO');
   V_ORDER_NO           :=      GET_STR('ORDER_NO');
   V_DOC_NO             :=      GET_STR('DOC_NO');

   IF P_TYPE = 'LIST' THEN

        /*----------------------------------------------------------------------
         * A : 조회 대상 사용이력 (RANGE_SQL 컬럼명과 동일한 별칭으로 구성)
         *     PRFM_DT / MACH_CD / ORDER_NO / MATNR / LOT_NO / IND_BCD
         *--------------------------------------------------------------------*/
        V_SQL := '
          SELECT I010.WERKS,
                 I010.MACH_CD,
                 SUBSTR(I010.MACH_CD, 2, 2)                                        AS PROC_DIV,
                 I010.PRFM_DT,
                 V000.ORDER_NO,
                 I010.WRK_ORDR_NO || ''-'' || LPAD(I010.WRK_ORDR_SEQNO, 2, ''0'')   AS WRK_ORDR_NO,
                 I010.IND_BCD_M                                                     AS IND_BCD,
                 I010.LOT_NO_M                                                      AS LOT_NO,
                 I010.MATNR_M                                                       AS MATNR,
                 I010.UNIT,
                 I010.REGDATE
            FROM TB_INV010 I010,
                 (SELECT DISTINCT WERKS, WRK_ORDR_NO, WRK_ORDR_SEQNO, ORDER_NO
                    FROM V_WRK_ORDR2
                   WHERE WERKS = ''' || V_WERKS || ''') V000
           WHERE I010.WERKS          = V000.WERKS(+)
             AND I010.WRK_ORDR_NO    = V000.WRK_ORDR_NO(+)
             AND I010.WRK_ORDR_SEQNO = V000.WRK_ORDR_SEQNO(+)
             AND I010.WERKS          = ''' || V_WERKS || '''
             AND NVL(I010.CNL_YN, ''N'') = ''N''
             AND I010.USE_DIV IN (''1'', ''2'', ''3'')';

        -- 사용 실적일자 사전필터 (RANGE_SQL 에도 포함되나 성능을 위해 선적용)
        IF REGEXP_LIKE(V_SDATE, '^[0-9]{8}$') AND REGEXP_LIKE(V_EDATE, '^[0-9]{8}$') THEN
            V_SQL := V_SQL || ' AND I010.PRFM_DT BETWEEN ''' || V_SDATE || ''' AND ''' || V_EDATE || '''';
        END IF;

        -- 공정구분 (SP_WRK05_S01 과 동일한 설비코드 규칙)
        IF V_PROC_DIV = 'AA' THEN                                   -- 합지
            V_SQL := V_SQL || ' AND I010.MACH_CD LIKE ''TAA%'' ';
        ELSIF V_PROC_DIV = 'RA' THEN                                -- 가공
            V_SQL := V_SQL || ' AND I010.MACH_CD LIKE ''TRA%'' ';
        ELSIF V_PROC_DIV = 'PG' THEN                                -- 예외생산
            V_SQL := V_SQL || ' AND I010.MACH_CD LIKE ''TPG%'' ';
        ELSE
            V_SQL := V_SQL || ' AND (I010.MACH_CD LIKE ''TAA%'' OR I010.MACH_CD LIKE ''TRA%'' OR I010.MACH_CD LIKE ''TPG%'') ';
        END IF;

        /*----------------------------------------------------------------------
         * B : 투입자재 바코드 단위 집계 (최종 사용 기준 설비/오더)
         *--------------------------------------------------------------------*/
        V_SQL := '
          SELECT A.WERKS,
                 MAX(A.MACH_CD)     KEEP (DENSE_RANK LAST ORDER BY A.PRFM_DT, A.REGDATE) AS MACH_CD,
                 MAX(A.PROC_DIV)    KEEP (DENSE_RANK LAST ORDER BY A.PRFM_DT, A.REGDATE) AS PROC_DIV,
                 MAX(A.ORDER_NO)    KEEP (DENSE_RANK LAST ORDER BY A.PRFM_DT, A.REGDATE) AS ORDER_NO,
                 MAX(A.WRK_ORDR_NO) KEEP (DENSE_RANK LAST ORDER BY A.PRFM_DT, A.REGDATE) AS WRK_ORDR_NO,
                 MAX(A.PRFM_DT)                                                          AS PRFM_DT,
                 A.IND_BCD,
                 A.LOT_NO,
                 A.MATNR,
                 MAX(A.UNIT)                                                             AS UNIT
            FROM (' || V_SQL || ') A
           WHERE 1=1 ';

        IF V_RANGE_SQL IS NOT NULL OR TRIM(V_RANGE_SQL) != '' THEN
            V_SQL := V_SQL || V_RANGE_SQL;
        END IF;

        V_SQL := V_SQL || '
           GROUP BY A.WERKS, A.IND_BCD, A.LOT_NO, A.MATNR';

        /*----------------------------------------------------------------------
         * X : 수량 / I/F 결과
         *--------------------------------------------------------------------*/
        V_SQL := '
          SELECT B.WERKS,
                 B.PROC_DIV,
                 B.MACH_CD,
                 M012.MACHINE,
                 M012.MACH_NM,
                 B.PRFM_DT,                                                 -- 최종 사용 실적일자
                 (SELECT MIN(W001.PRD_DT)
                    FROM TB_WRK001 W001
                   WHERE W001.WERKS   = B.WERKS
                     AND W001.MATNR   = B.MATNR
                     AND W001.IND_BCD = B.IND_BCD
                     AND W001.LOT_NO  = B.LOT_NO
                     AND NVL(W001.CNL_YN, ''N'') = ''N'')                   AS PRD_DT,  -- 투입자재 생산일자
                 B.ORDER_NO,
                 B.WRK_ORDR_NO,
                 B.IND_BCD,
                 B.LOT_NO,
                 B.MATNR,
                 M001.MATNR_NM,
                 NVL(B.UNIT, M001.UNIT)                                     AS UNIT,

                 /* 생산량 */
                 CASE WHEN B.MATNR LIKE ''H000%'' THEN
                           NVL((SELECT MAX(I001.RCV_WGT)
                                  FROM TB_INV001 I001
                                 WHERE I001.WERKS   = B.WERKS
                                   AND I001.MATNR   = B.MATNR
                                   AND I001.IND_BCD = B.IND_BCD
                                   AND I001.LOT_NO  = B.LOT_NO), 0)
                      ELSE
                           NVL((SELECT SUM(W001.PRFM_QTY)
                                  FROM TB_WRK001 W001
                                 WHERE W001.WERKS   = B.WERKS
                                   AND W001.MATNR   = B.MATNR
                                   AND W001.IND_BCD = B.IND_BCD
                                   AND W001.LOT_NO  = B.LOT_NO
                                   AND NVL(W001.CNL_YN, ''N'') = ''N''), 0)
                 END                                                        AS PRFM_QTY,

                 /* 사용량 (정상 + 보정) */
                 NVL((SELECT SUM(U.USE_QTY)
                        FROM TB_INV010 U
                       WHERE U.WERKS     = B.WERKS
                         AND U.MATNR_M   = B.MATNR
                         AND U.LOT_NO_M  = B.LOT_NO
                         AND U.IND_BCD_M = B.IND_BCD
                         AND NVL(U.CNL_YN, ''N'') = ''N''
                         AND U.USE_DIV IN (''1'', ''2'')), 0)               AS USE_QTY,

                 /* 폐품 */
                 NVL((SELECT SUM(U.USE_QTY)
                        FROM TB_INV010 U
                       WHERE U.WERKS     = B.WERKS
                         AND U.MATNR_M   = B.MATNR
                         AND U.LOT_NO_M  = B.LOT_NO
                         AND U.IND_BCD_M = B.IND_BCD
                         AND NVL(U.CNL_YN, ''N'') = ''N''
                         AND U.USE_DIV = ''3''), 0)                         AS DISPO_QTY,

                 /* 잔량 (창고재고 + 공정재고) */
                 NVL((SELECT SUM(I001.STCK_QTY)
                        FROM TB_INV001 I001
                       WHERE I001.WERKS    = B.WERKS
                         AND I001.MATNR    = B.MATNR
                         AND I001.IND_BCD  = B.IND_BCD
                         AND I001.LOT_NO   = B.LOT_NO
                         AND I001.STCK_STA = ''0''), 0)
               + NVL((SELECT SUM(I003.STCK_QTY)
                        FROM TB_INV003 I003
                       WHERE I003.WERKS    = B.WERKS
                         AND I003.MATNR    = B.MATNR
                         AND I003.IND_BCD  = B.IND_BCD
                         AND I003.LOT_NO   = B.LOT_NO), 0)                  AS RMD_QTY,

                 /* 실적 전송결과 (원지 H000% 는 MES 실적 없음) */
                 CASE WHEN B.MATNR LIKE ''H000%'' THEN NULL
                      ELSE (SELECT DECODE(MAX(CASE WHEN NVL(W001.SDOC_NO, '' '') = ''E'' THEN 3
                                                   WHEN NVL(W001.SDOC_NO, '' '') = '' '' THEN 2
                                                   ELSE 1 END), 1, ''S'', 2, ''N'', 3, ''E'')
                              FROM TB_WRK001 W001
                             WHERE W001.WERKS   = B.WERKS
                               AND W001.MATNR   = B.MATNR
                               AND W001.IND_BCD = B.IND_BCD
                               AND W001.LOT_NO  = B.LOT_NO
                               AND NVL(W001.CNL_YN, ''N'') = ''N'')
                 END                                                        AS IF_PRFM_RSLT,

                 /* 투입 전송결과 (일마감 사용량 TB_INV013, 자재+LOT 단위) */
                 (SELECT DECODE(MAX(CASE WHEN NVL(I013.SDOC_NO, '' '') NOT IN ('' '', ''E'') THEN 1
                                         WHEN F.MDOCNO IS NOT NULL THEN 3
                                         ELSE 2 END), 1, ''S'', 2, ''N'', 3, ''E'')
                    FROM TB_INV013 I013,
                         TB_IFS008 F
                   WHERE I013.WERKS   = B.WERKS
                     AND I013.MATNR   = B.MATNR
                     AND I013.LOT_NO  = B.LOT_NO
                     AND F.MDOCNO(+)  = I013.DOC_NO
                     AND F.MDOCSEQ(+) = TO_CHAR(I013.DOC_SEQNO)
                     AND F.ZRESULT(+) = ''E'')                               AS IF_USE_RSLT_RAW,

                 /* 폐품 전송결과 */
                 (SELECT DECODE(MAX(CASE WHEN NVL(W016.SDOC_NO, '' '') NOT IN ('' '', ''E'') THEN 1
                                         WHEN F.MDOCNO IS NOT NULL THEN 3
                                         ELSE 2 END), 1, ''S'', 2, ''N'', 3, ''E'')
                    FROM TB_WRK016 W016,
                         TB_IFS012 F
                   WHERE W016.WERKS     = B.WERKS
                     AND W016.IND_BCD_M = B.IND_BCD
                     AND NVL(W016.CNL_YN, ''N'') = ''N''
                     AND F.MDOCNO(+)    = W016.DOC_NO
                     AND F.MDOCSEQ(+)   = TO_CHAR(W016.DOC_SEQNO)
                     AND F.ZRESULT(+)   = ''E'')                             AS IF_DISPO_RSLT_RAW,

                 /* 오류 메시지 (최근) */
                 (SELECT MAX(F.ZMESSAGE) KEEP (DENSE_RANK LAST ORDER BY F.MAKE_DATE)
                    FROM TB_WRK001 W001, TB_IFS002 F
                   WHERE W001.WERKS   = B.WERKS
                     AND W001.MATNR   = B.MATNR
                     AND W001.IND_BCD = B.IND_BCD
                     AND W001.LOT_NO  = B.LOT_NO
                     AND F.MDOCNO     = W001.DOC_NO
                     AND F.ZRESULT    = ''E'')                               AS MSG_PRFM,
                 (SELECT MAX(F.ZMESSAGE) KEEP (DENSE_RANK LAST ORDER BY F.MAKE_DATE)
                    FROM TB_INV013 I013, TB_IFS008 F
                   WHERE I013.WERKS   = B.WERKS
                     AND I013.MATNR   = B.MATNR
                     AND I013.LOT_NO  = B.LOT_NO
                     AND F.MDOCNO     = I013.DOC_NO
                     AND F.MDOCSEQ    = TO_CHAR(I013.DOC_SEQNO)
                     AND F.ZRESULT    = ''E'')                               AS MSG_USE,
                 (SELECT MAX(F.ZMESSAGE) KEEP (DENSE_RANK LAST ORDER BY F.MAKE_DATE)
                    FROM TB_WRK016 W016, TB_IFS012 F
                   WHERE W016.WERKS     = B.WERKS
                     AND W016.IND_BCD_M = B.IND_BCD
                     AND NVL(W016.CNL_YN, ''N'') = ''N''
                     AND F.MDOCNO       = W016.DOC_NO
                     AND F.MDOCSEQ      = TO_CHAR(W016.DOC_SEQNO)
                     AND F.ZRESULT      = ''E'')                             AS MSG_DISPO

            FROM (' || V_SQL || ') B,
                 TB_MAS012 M012,
                 TB_MAS001 M001
           WHERE B.MACH_CD = M012.MACH_CD(+)
             AND B.WERKS   = M001.WERKS(+)
             AND B.MATNR   = M001.MATNR(+)';

        /*----------------------------------------------------------------------
         * Y : 판정 (생산량 = 사용량 + 폐품)
         *--------------------------------------------------------------------*/
        V_SQL := '
          SELECT X.WERKS, X.PROC_DIV, X.MACH_CD, X.MACHINE, X.MACH_NM,
                 X.PRFM_DT, X.PRD_DT, X.ORDER_NO, X.WRK_ORDR_NO,
                 X.IND_BCD, X.LOT_NO, X.MATNR, X.MATNR_NM, X.UNIT,
                 X.PRFM_QTY, X.USE_QTY, X.DISPO_QTY, X.RMD_QTY,
                 ROUND(X.PRFM_QTY - (X.USE_QTY + X.DISPO_QTY), 3)          AS DIFF_QTY,
                 CASE WHEN ABS(ROUND(X.PRFM_QTY - (X.USE_QTY + X.DISPO_QTY), 3)) < 0.001
                      THEN ''정상'' ELSE ''불일치'' END                       AS CHK_RSLT,
                 X.IF_PRFM_RSLT,
                 CASE WHEN X.IF_USE_RSLT_RAW IS NULL AND X.USE_QTY <> 0 THEN ''N''
                      ELSE X.IF_USE_RSLT_RAW END                            AS IF_USE_RSLT,
                 CASE WHEN X.IF_DISPO_RSLT_RAW IS NULL AND X.DISPO_QTY <> 0 THEN ''N''
                      ELSE X.IF_DISPO_RSLT_RAW END                          AS IF_DISPO_RSLT,
                 SUBSTR(  NVL2(X.MSG_PRFM,  ''[실적] '' || X.MSG_PRFM  || '' '', NULL)
                       || NVL2(X.MSG_USE,   ''[투입] '' || X.MSG_USE   || '' '', NULL)
                       || NVL2(X.MSG_DISPO, ''[폐품] '' || X.MSG_DISPO, NULL), 1, 1000) AS IF_MSG
            FROM (' || V_SQL || ') X';

        /*----------------------------------------------------------------------
         * Z : 판정 / 전송상태 필터
         *--------------------------------------------------------------------*/
        V_SQL := 'SELECT Z.* FROM (' || V_SQL || ') Z WHERE 1=1 ';

        IF V_CHK_FILTER = 'NG' THEN
            V_SQL := V_SQL || ' AND Z.CHK_RSLT = ''불일치'' ';
        ELSIF V_CHK_FILTER = 'OK' THEN
            V_SQL := V_SQL || ' AND Z.CHK_RSLT = ''정상'' ';
        END IF;

        IF V_IF_FILTER = 'E' THEN
            V_SQL := V_SQL || ' AND (Z.IF_PRFM_RSLT = ''E'' OR Z.IF_USE_RSLT = ''E'' OR Z.IF_DISPO_RSLT = ''E'') ';
        ELSIF V_IF_FILTER = 'N' THEN
            V_SQL := V_SQL || ' AND (Z.IF_PRFM_RSLT = ''N'' OR Z.IF_USE_RSLT = ''N'' OR Z.IF_DISPO_RSLT = ''N'') ';
        ELSIF V_IF_FILTER = 'S' THEN
            V_SQL := V_SQL || ' AND NVL(Z.IF_PRFM_RSLT, ''S'') = ''S'' AND NVL(Z.IF_USE_RSLT, ''S'') = ''S'' AND NVL(Z.IF_DISPO_RSLT, ''S'') = ''S'' ';
        END IF;

        V_SQL := V_SQL || ' ORDER BY Z.PRFM_DT DESC, Z.MACH_CD, Z.MATNR, Z.LOT_NO, Z.IND_BCD';

        IF (V_DEBUG = 'Y') THEN
            INSERT INTO PROC_LOG(SQL_STR, SQL_PARAM1) VALUES (V_SQL, 'WRK55');
        END IF;

        OPEN P_RS_LIST FOR V_SQL;

    ELSIF P_TYPE = 'LOG_LIST' THEN  /* RFC 전송로그 : 파라미터 행 단위 */

        V_SQL := '
          SELECT H.LOG_SEQ,
                 D.ROW_SEQ,
                 TO_CHAR(H.LOG_DATE, ''YYYY-MM-DD HH24:MI:SS'')            AS LOG_DATE,
                 H.PRG_NM,
                 H.IF_ID,
                 H.RFCFN,
                 H.IFTBL,
                 D.QTY_DIV,
                 DECODE(D.QTY_DIV, ''PRFM'', ''생산'', ''PRFM_CNL'', ''생산취소'',
                                   ''USE'', ''사용'', ''USE_CNL'', ''사용취소'',
                                   ''DISPO'', ''폐품'', ''DISPO_CNL'', ''폐품취소'',
                                   ''MOVE'', ''재고이전'', ''WMS_IN'', ''입고요청'',
                                   ''RMD'', ''잔량반납'', NVL(D.QTY_DIV, ''-''))    AS QTY_DIV_NM,
                 NVL(D.MDOCNO, H.DOC_NO)                                    AS MDOCNO,
                 D.MDOCSEQ,
                 D.AUFNR                                                    AS ORDER_NO,
                 D.MATNR,
                 M001.MATNR_NM,
                 D.LOTNO                                                    AS LOT_NO,
                 D.IND_BCD,
                 D.BUDAT,
                 D.PRFM_QTY,
                 D.USE_QTY,
                 D.DISPO_QTY,
                 D.RMD_QTY,
                 D.UNIT,
                 H.LOG_STA,
                 H.LOG_MSG,
                 PKG_WRK055.GET_IF_RSLT(H.IFTBL, D.MDOCNO, D.MDOCSEQ, ''STAT'') AS IF_STAT,
                 PKG_WRK055.GET_IF_RSLT(H.IFTBL, D.MDOCNO, D.MDOCSEQ, ''SDOC'') AS SAP_DOC_NO,
                 PKG_WRK055.GET_IF_RSLT(H.IFTBL, D.MDOCNO, D.MDOCSEQ, ''MSG'')  AS IF_MSG,
                 DBMS_LOB.SUBSTR(D.PARAM_JSON, 3800, 1)                     AS PARAM_JSON,
                 H.REGID
            FROM TB_WRK055   H,
                 TB_WRK055_D D,
                 TB_MAS001   M001
           WHERE H.LOG_SEQ   = D.LOG_SEQ(+)
             AND H.WERKS     = M001.WERKS(+)
             AND D.MATNR     = M001.MATNR(+)
             AND H.WERKS     = ''' || V_WERKS || '''';

        -- 로그일자 (실적일자 검색조건 재사용)
        IF REGEXP_LIKE(V_SDATE, '^[0-9]{8}$') AND REGEXP_LIKE(V_EDATE, '^[0-9]{8}$') THEN
            V_SQL := V_SQL || ' AND H.LOG_DATE >= TO_DATE(''' || V_SDATE || ''', ''YYYYMMDD'')'
                           || ' AND H.LOG_DATE <  TO_DATE(''' || V_EDATE || ''', ''YYYYMMDD'') + 1';
        END IF;

        IF V_PRG_FILTER IS NOT NULL THEN
            V_SQL := V_SQL || ' AND H.PRG_NM LIKE ''%' || REPLACE(V_PRG_FILTER, '''', '') || '%''';
        END IF;
        IF V_IF_ID IS NOT NULL THEN
            V_SQL := V_SQL || ' AND H.IF_ID = ''' || REPLACE(V_IF_ID, '''', '') || '''';
        END IF;
        IF V_QTY_DIV IS NOT NULL THEN
            V_SQL := V_SQL || ' AND D.QTY_DIV LIKE ''' || REPLACE(V_QTY_DIV, '''', '') || '%''';
        END IF;
        IF V_MATNR IS NOT NULL THEN
            V_SQL := V_SQL || ' AND D.MATNR = ''' || REPLACE(V_MATNR, '''', '') || '''';
        END IF;
        IF V_LOT_NO IS NOT NULL THEN
            V_SQL := V_SQL || ' AND D.LOTNO = ''' || REPLACE(V_LOT_NO, '''', '') || '''';
        END IF;
        IF V_ORDER_NO IS NOT NULL THEN
            V_SQL := V_SQL || ' AND D.AUFNR = ''' || REPLACE(V_ORDER_NO, '''', '') || '''';
        END IF;
        IF V_DOC_NO IS NOT NULL THEN
            V_SQL := V_SQL || ' AND (D.MDOCNO = ''' || REPLACE(V_DOC_NO, '''', '') || ''' OR H.DOC_NO LIKE ''%'
                           || REPLACE(V_DOC_NO, '''', '') || '%'')';
        END IF;

        V_SQL := 'SELECT Z.* FROM (' || V_SQL || ') Z WHERE 1=1 ';
        IF V_IF_FILTER IN ('S', 'E', 'N', 'W') THEN
            V_SQL := V_SQL || ' AND Z.IF_STAT = ''' || V_IF_FILTER || '''';
        END IF;
        V_SQL := V_SQL || ' ORDER BY Z.LOG_SEQ DESC, Z.ROW_SEQ';

        IF (V_DEBUG = 'Y') THEN
            INSERT INTO PROC_LOG(SQL_STR, SQL_PARAM1) VALUES (V_SQL, 'WRK55_LOG');
        END IF;

        OPEN P_RS_LIST FOR V_SQL;

    ELSIF P_TYPE = 'SAP_LIST' THEN  /* SAP 데이터 연동 (B안 예정) */

        RETURN;

    END IF;

    P_SUCCESS := 'Y';

    EXCEPTION
    WHEN E_EXCEPTION_USER THEN

	    P_SUCCESS           := 'N';
        E_SQL_ERR_CD        := SQLCODE;
        E_SQL_ERR_MSG       := SUBSTRB(SQLERRM,1,300);
        P_ERR_MSG           := E_SQL_ERR_MSG;

        ROLLBACK;
        SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);

    WHEN OTHERS THEN
	    P_SUCCESS           := 'N';
        E_SQL_ERR_CD        := -20990;
        E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';
        P_ERR_MSG           := E_SQL_ERR_MSG;

        ROLLBACK;
        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
END;
/
