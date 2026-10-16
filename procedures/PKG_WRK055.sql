/*==============================================================================
 * PACKAGE NAME  : PKG_WRK055
 * DESCRIPTION   : 화장지(P200) 생산량/사용량/폐품/잔량 관련 RFC 전송 로그
 *
 *   LOG_IF(프로시저명, 플랜트, IF_ID, 문서번호)
 *     - TB_ITFMA 에서 RFC 함수명/I/F 테이블 조회
 *     - FN_IF_QUERY(IF_ID, 문서번호) 를 그대로 실행하여
 *       POP/WEB 이 RFC IT_DATA 로 보내는 파라미터 행을 그대로 캡처
 *     - TB_WRK055(헤더) / TB_WRK055_D(파라미터 행) 에 저장
 *
 *   ※ 캡처(조회)는 호출 프로시저 트랜잭션 안에서 수행한다.
 *     (I/F 행이 아직 COMMIT 전이므로 자율 트랜잭션에서는 보이지 않음)
 *     저장은 자율 트랜잭션 → 호출 프로시저가 ROLLBACK 되어도 로그는 남는다.
 *   ※ 로그 처리 중 어떤 오류가 나도 호출 프로시저로 예외를 올리지 않는다.
 *   ※ P200 이외 플랜트는 기록하지 않는다.
 *
 * CREATE DATE   : 2026/10/16
 *==============================================================================*/
CREATE OR REPLACE PACKAGE KNRAMES.PKG_WRK055 AS

    PROCEDURE LOG_IF (
        P_PRG_NM    IN VARCHAR2,                -- 로그를 남기는 프로시저명
        P_WERKS     IN VARCHAR2,                -- 플랜트
        P_IF_ID     IN VARCHAR2,                -- 인터페이스 ID (예: MES_IF_124)
        P_DOC_NO    IN VARCHAR2,                -- MES 문서번호 (콤마구분 가능)
        P_USERID    IN VARCHAR2 DEFAULT NULL
    );

    /* 문서번호(M + IFxxx + ...)로 IF_ID 를 유추하여 LOG_IF 호출 (웹 화면 프로시저용) */
    PROCEDURE LOG_DOC (
        P_PRG_NM    IN VARCHAR2,
        P_WERKS     IN VARCHAR2,
        P_DOC_NO    IN VARCHAR2,
        P_USERID    IN VARCHAR2 DEFAULT NULL
    );

    /* 조회용 : QTY_DIV 분류 */
    FUNCTION GET_QTY_DIV (P_IFTBL IN VARCHAR2) RETURN VARCHAR2;

    /* 조회용 : 현재 I/F 테이블 상태
     *   P_ITEM = 'STAT' : N(행 없음=롤백 추정) / S / E / W(미전송)
     *            'SDOC' : SAP 문서번호 (RUECK 또는 MBLNR)
     *            'MSG'  : ZMESSAGE                                   */
    FUNCTION GET_IF_RSLT (P_IFTBL IN VARCHAR2, P_MDOCNO IN VARCHAR2, P_MDOCSEQ IN VARCHAR2,
                          P_ITEM IN VARCHAR2) RETURN VARCHAR2;

END PKG_WRK055;
/

CREATE OR REPLACE PACKAGE BODY KNRAMES.PKG_WRK055 AS

    TYPE T_ROW IS RECORD (
        MDOCNO      VARCHAR2(30),
        MDOCSEQ     VARCHAR2(10),
        AUFNR       VARCHAR2(20),
        MATNR       VARCHAR2(40),
        LOTNO       VARCHAR2(30),
        IND_BCD     VARCHAR2(30),
        BUDAT       VARCHAR2(10),
        PRFM_QTY    NUMBER,
        USE_QTY     NUMBER,
        DISPO_QTY   NUMBER,
        RMD_QTY     NUMBER,
        UNIT        VARCHAR2(10),
        PARAM_JSON  CLOB
    );
    TYPE T_ROWS IS TABLE OF T_ROW INDEX BY PLS_INTEGER;

    /*--------------------------------------------------------------------------
     * I/F 테이블 → 수량 구분
     *------------------------------------------------------------------------*/
    FUNCTION GET_QTY_DIV (P_IFTBL IN VARCHAR2) RETURN VARCHAR2 IS
    BEGIN
        RETURN CASE
                 WHEN P_IFTBL IN ('TB_IFS001', 'TB_IFS002', 'TB_IFS011', 'TB_IFS019') THEN 'PRFM'      -- 생산실적
                 WHEN P_IFTBL = 'TB_IFS007'                                         THEN 'PRFM_CNL'  -- 실적취소
                 WHEN P_IFTBL = 'TB_IFS008'                                         THEN 'USE'       -- 자재투입(사용량)
                 WHEN P_IFTBL = 'TB_IFS014'                                         THEN 'USE_CNL'   -- 사용량 취소
                 WHEN P_IFTBL = 'TB_IFS012'                                         THEN 'DISPO'     -- 폐품
                 WHEN P_IFTBL = 'TB_IFS022'                                         THEN 'DISPO_CNL' -- 폐품취소
                 WHEN P_IFTBL = 'TB_IFS009'                                         THEN 'MOVE'      -- 재고이전
                 WHEN P_IFTBL = 'TB_IFSWM005'                                       THEN 'WMS_IN'    -- 완제품 입고요청
                 WHEN P_IFTBL = 'TB_IFSWM004'                                       THEN 'RMD'       -- 잔량 반납요청
                 ELSE 'ETC'
               END;
    END;

    /*--------------------------------------------------------------------------
     * JSON 에서 후보 컬럼 중 처음 값이 있는 항목 반환
     *------------------------------------------------------------------------*/
    FUNCTION PICK (P_OBJ IN JSON_OBJECT_T, P_KEYS IN VARCHAR2) RETURN VARCHAR2 IS
        V_KEY   VARCHAR2(50);
        V_VAL   VARCHAR2(4000);
        I       PLS_INTEGER := 1;
    BEGIN
        LOOP
            V_KEY := REGEXP_SUBSTR(P_KEYS, '[^,]+', 1, I);
            EXIT WHEN V_KEY IS NULL;
            IF P_OBJ.has(V_KEY) THEN
                V_VAL := TRIM(P_OBJ.get_string(V_KEY));
                IF V_VAL IS NOT NULL THEN
                    RETURN V_VAL;
                END IF;
            END IF;
            I := I + 1;
        END LOOP;
        RETURN NULL;
    END;

    FUNCTION TO_NUM (P_VAL IN VARCHAR2) RETURN NUMBER IS
    BEGIN
        RETURN TO_NUMBER(REPLACE(TRIM(P_VAL), ',', ''));
    EXCEPTION WHEN OTHERS THEN
        RETURN NULL;
    END;

    /*--------------------------------------------------------------------------
     * 저장 (자율 트랜잭션)
     *------------------------------------------------------------------------*/
    PROCEDURE SAVE_LOG (
        P_PRG_NM IN VARCHAR2, P_WERKS IN VARCHAR2, P_IF_ID IN VARCHAR2,
        P_RFCFN  IN VARCHAR2, P_IFTBL IN VARCHAR2, P_SYSFR IN VARCHAR2, P_SYSTO IN VARCHAR2,
        P_DOC_NO IN VARCHAR2, P_STA   IN VARCHAR2, P_MSG   IN VARCHAR2, P_SQL   IN VARCHAR2,
        P_USERID IN VARCHAR2, P_ROWS  IN T_ROWS
    ) IS
        PRAGMA AUTONOMOUS_TRANSACTION;
        V_SEQ     NUMBER;
        V_DIV     VARCHAR2(10) := GET_QTY_DIV(P_IFTBL);
    BEGIN
        SELECT KNRAMES.SEQ_WRK055.NEXTVAL INTO V_SEQ FROM DUAL;

        INSERT INTO TB_WRK055 (LOG_SEQ, LOG_DATE, PRG_NM, WERKS, IF_ID, RFCFN, IFTBL, SYSFR, SYSTO,
                               DOC_NO, ROW_CNT, LOG_STA, LOG_MSG, IF_SQL, REGID, REGDATE)
        VALUES (V_SEQ, SYSDATE, SUBSTR(P_PRG_NM, 1, 100), P_WERKS, P_IF_ID, P_RFCFN, P_IFTBL, P_SYSFR, P_SYSTO,
                SUBSTR(P_DOC_NO, 1, 400), P_ROWS.COUNT, P_STA, SUBSTR(P_MSG, 1, 4000), SUBSTR(P_SQL, 1, 4000),
                SUBSTR(P_USERID, 1, 20), SYSDATE);

        FOR I IN 1 .. P_ROWS.COUNT LOOP
            INSERT INTO TB_WRK055_D (LOG_SEQ, ROW_SEQ, MDOCNO, MDOCSEQ, AUFNR, MATNR, LOTNO, IND_BCD, BUDAT,
                                     QTY_DIV, PRFM_QTY, USE_QTY, DISPO_QTY, RMD_QTY, UNIT, PARAM_JSON)
            VALUES (V_SEQ, I, P_ROWS(I).MDOCNO, P_ROWS(I).MDOCSEQ, P_ROWS(I).AUFNR, P_ROWS(I).MATNR,
                    P_ROWS(I).LOTNO, P_ROWS(I).IND_BCD, P_ROWS(I).BUDAT,
                    V_DIV, P_ROWS(I).PRFM_QTY, P_ROWS(I).USE_QTY, P_ROWS(I).DISPO_QTY, P_ROWS(I).RMD_QTY,
                    P_ROWS(I).UNIT, P_ROWS(I).PARAM_JSON);
        END LOOP;

        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
    END;

    /*--------------------------------------------------------------------------
     * RFC 파라미터 캡처 + 로그
     *------------------------------------------------------------------------*/
    PROCEDURE LOG_IF (
        P_PRG_NM    IN VARCHAR2,
        P_WERKS     IN VARCHAR2,
        P_IF_ID     IN VARCHAR2,
        P_DOC_NO    IN VARCHAR2,
        P_USERID    IN VARCHAR2 DEFAULT NULL
    ) IS
        V_RFCFN     VARCHAR2(200);
        V_IFTBL     VARCHAR2(30);
        V_SYSFR     VARCHAR2(10);
        V_SYSTO     VARCHAR2(10);
        V_SQL       VARCHAR2(4000);
        V_DIV       VARCHAR2(10);

        V_CUR       INTEGER;
        V_CNT       INTEGER;
        V_DESC      DBMS_SQL.DESC_TAB2;
        V_VAL       VARCHAR2(4000);
        V_DUMMY     INTEGER;

        V_OBJ       JSON_OBJECT_T;
        V_ROWS      T_ROWS;
        V_R         T_ROW;
        V_QTY       NUMBER;
        V_SIGN      NUMBER;
    BEGIN
        IF NVL(P_WERKS, 'P200') <> 'P200' OR P_IF_ID IS NULL OR P_DOC_NO IS NULL THEN
            RETURN;
        END IF;

        BEGIN
            SELECT RFCFN, IFTBL, SYSFR, SYSTO
              INTO V_RFCFN, V_IFTBL, V_SYSFR, V_SYSTO
              FROM TB_ITFMA
             WHERE IFID = P_IF_ID;
        EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
        END;

        V_DIV  := GET_QTY_DIV(V_IFTBL);
        V_SIGN := CASE WHEN V_DIV LIKE '%_CNL' THEN -1 ELSE 1 END;
        V_SQL  := FN_IF_QUERY(P_IF_ID, P_DOC_NO);

        IF V_SQL IS NULL THEN
            SAVE_LOG(P_PRG_NM, NVL(P_WERKS, 'P200'), P_IF_ID, V_RFCFN, V_IFTBL, V_SYSFR, V_SYSTO,
                     P_DOC_NO, 'W', 'FN_IF_QUERY 결과 없음', NULL, P_USERID, V_ROWS);
            RETURN;
        END IF;

        V_CUR := DBMS_SQL.OPEN_CURSOR;
        DBMS_SQL.PARSE(V_CUR, V_SQL, DBMS_SQL.NATIVE);
        DBMS_SQL.DESCRIBE_COLUMNS2(V_CUR, V_CNT, V_DESC);
        FOR C IN 1 .. V_CNT LOOP
            DBMS_SQL.DEFINE_COLUMN(V_CUR, C, V_VAL, 4000);
        END LOOP;
        V_DUMMY := DBMS_SQL.EXECUTE(V_CUR);

        WHILE DBMS_SQL.FETCH_ROWS(V_CUR) > 0 LOOP
            V_OBJ := JSON_OBJECT_T();
            FOR C IN 1 .. V_CNT LOOP
                DBMS_SQL.COLUMN_VALUE(V_CUR, C, V_VAL);
                V_OBJ.put(UPPER(V_DESC(C).COL_NAME), V_VAL);
            END LOOP;

            V_R := NULL;
            V_R.MDOCNO   := SUBSTR(PICK(V_OBJ, 'MDOCNO,DOC_NO'), 1, 30);
            V_R.MDOCSEQ  := SUBSTR(PICK(V_OBJ, 'MDOCSEQ,DOC_SEQNO'), 1, 10);
            V_R.AUFNR    := SUBSTR(PICK(V_OBJ, 'AUFNR,ORDER_NO'), 1, 20);
            V_R.MATNR    := SUBSTR(PICK(V_OBJ, 'MATNR,PRDCD,MATNR_FROM'), 1, 40);
            V_R.LOTNO    := SUBSTR(PICK(V_OBJ, 'CHARG,LOTNO,LOT_NO,CHARG_FROM'), 1, 30);
            V_R.IND_BCD  := SUBSTR(PICK(V_OBJ, 'IND_BCD'), 1, 30);
            V_R.BUDAT    := SUBSTR(PICK(V_OBJ, 'BUDAT,PRDDT,PRFM_DT'), 1, 10);
            V_R.UNIT     := SUBSTR(PICK(V_OBJ, 'MEINS,ERFME,UNIT'), 1, 10);

            V_QTY := TO_NUM(PICK(V_OBJ, 'PROQTY,MENGE,SCRQTY,QTY')) * V_SIGN;

            IF V_DIV IN ('PRFM', 'PRFM_CNL') THEN
                V_R.PRFM_QTY  := V_QTY;
            ELSIF V_DIV IN ('USE', 'USE_CNL') THEN
                V_R.USE_QTY   := V_QTY;
            ELSIF V_DIV = 'DISPO' THEN
                V_R.DISPO_QTY := TO_NUM(PICK(V_OBJ, 'SCRQTY,MENGE'));
                V_R.RMD_QTY   := TO_NUM(PICK(V_OBJ, 'RSDQTY'));
            ELSIF V_DIV = 'DISPO_CNL' THEN
                V_R.DISPO_QTY := V_QTY;
            ELSIF V_DIV = 'RMD' THEN
                V_R.RMD_QTY   := V_QTY;
            END IF;

            V_R.PARAM_JSON := V_OBJ.to_clob;
            V_ROWS(V_ROWS.COUNT + 1) := V_R;
        END LOOP;
        DBMS_SQL.CLOSE_CURSOR(V_CUR);

        SAVE_LOG(P_PRG_NM, NVL(P_WERKS, 'P200'), P_IF_ID, V_RFCFN, V_IFTBL, V_SYSFR, V_SYSTO,
                 P_DOC_NO, CASE WHEN V_ROWS.COUNT = 0 THEN 'W' ELSE 'S' END,
                 CASE WHEN V_ROWS.COUNT = 0 THEN 'RFC 파라미터 행 없음' END,
                 V_SQL, P_USERID, V_ROWS);

    EXCEPTION
        WHEN OTHERS THEN
            IF V_CUR IS NOT NULL AND DBMS_SQL.IS_OPEN(V_CUR) THEN
                DBMS_SQL.CLOSE_CURSOR(V_CUR);
            END IF;
            BEGIN
                V_ROWS.DELETE;
                SAVE_LOG(P_PRG_NM, NVL(P_WERKS, 'P200'), P_IF_ID, V_RFCFN, V_IFTBL, V_SYSFR, V_SYSTO,
                         P_DOC_NO, 'E', SUBSTR(SQLERRM || ' ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, 1, 4000),
                         V_SQL, P_USERID, V_ROWS);
            EXCEPTION WHEN OTHERS THEN NULL;
            END;
    END LOG_IF;

    PROCEDURE LOG_DOC (
        P_PRG_NM    IN VARCHAR2,
        P_WERKS     IN VARCHAR2,
        P_DOC_NO    IN VARCHAR2,
        P_USERID    IN VARCHAR2 DEFAULT NULL
    ) IS
    BEGIN
        -- FN_GET_MDOCNO : 'M' || 'IF134' || YYMMDDHH24MI || 순번  →  MES_IF_134
        IF REGEXP_LIKE(P_DOC_NO, '^MIF[0-9]{3}') THEN
            LOG_IF(P_PRG_NM, P_WERKS, 'MES_IF_' || SUBSTR(P_DOC_NO, 4, 3), P_DOC_NO, P_USERID);
        END IF;
    EXCEPTION WHEN OTHERS THEN NULL;
    END LOG_DOC;

    FUNCTION GET_IF_RSLT (P_IFTBL IN VARCHAR2, P_MDOCNO IN VARCHAR2, P_MDOCSEQ IN VARCHAR2,
                          P_ITEM IN VARCHAR2) RETURN VARCHAR2 IS
        V_SQL    VARCHAR2(1000);
        V_ZR     VARCHAR2(10);
        V_SDOC   VARCHAR2(100);
        V_MSG    VARCHAR2(4000);
        V_SDCOL  VARCHAR2(30);
    BEGIN
        IF P_IFTBL IS NULL OR P_MDOCNO IS NULL OR NOT REGEXP_LIKE(P_IFTBL, '^TB_IFS[A-Z0-9_]+$') THEN
            RETURN NULL;
        END IF;

        IF P_IFTBL LIKE 'TB_IFSWM%' THEN
            V_SQL := 'SELECT ''S'', NULL, NULL FROM ' || P_IFTBL
                  || ' WHERE DOC_NO = :1 AND LTRIM(TO_CHAR(DOC_SEQNO), ''0'') = LTRIM(:2, ''0'') AND ROWNUM = 1';
        ELSE
            V_SDCOL := CASE WHEN P_IFTBL IN ('TB_IFS008', 'TB_IFS009', 'TB_IFS012', 'TB_IFS022') THEN 'MBLNR'
                            WHEN P_IFTBL IN ('TB_IFS007', 'TB_IFS014') THEN 'NULL'
                            ELSE 'RUECK' END;
            V_SQL := 'SELECT ZRESULT, ' || V_SDCOL || ', ZMESSAGE FROM ' || P_IFTBL
                  || ' WHERE MDOCNO = :1 AND LTRIM(TO_CHAR(MDOCSEQ), ''0'') = LTRIM(:2, ''0'') AND ROWNUM = 1';
        END IF;

        BEGIN
            EXECUTE IMMEDIATE V_SQL INTO V_ZR, V_SDOC, V_MSG USING P_MDOCNO, NVL(P_MDOCSEQ, '1');
        EXCEPTION WHEN NO_DATA_FOUND THEN
            RETURN CASE WHEN P_ITEM = 'STAT' THEN 'N' END;
        END;

        RETURN CASE P_ITEM
                 WHEN 'STAT' THEN CASE WHEN V_ZR IN ('S', 'E') THEN V_ZR ELSE 'W' END
                 WHEN 'SDOC' THEN V_SDOC
                 WHEN 'MSG'  THEN SUBSTR(V_MSG, 1, 1000)
               END;
    EXCEPTION WHEN OTHERS THEN
        RETURN NULL;
    END GET_IF_RSLT;

END PKG_WRK055;
/
