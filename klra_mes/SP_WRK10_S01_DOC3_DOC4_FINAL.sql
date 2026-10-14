/*
 * SP_WRK10_S01 - DOC3/DOC4 최종 추가안
 * 수량 기준: WERKS + LOT_NO_M 배치 누계
 * SAP 변경 기준: 기존 SAP 투입문서 수량 + (기존 폐품 - 새 폐품)
 */

/* ================================================================
 * 1. 프로시저 파라미터: P_DOC_NO2 다음에 추가
 * ================================================================ */
-- P_DOC_NO3 OUT VARCHAR2,  -- MES_IF_143 자재투입 취소
-- P_DOC_NO4 OUT VARCHAR2,  -- MES_IF_130 자재투입 등록


/* ================================================================
 * 2. 변수 선언부에 추가
 * ================================================================ */
V_DOC_NO_3          VARCHAR2(30);
V_DOC_SEQNO_3       NUMBER;
V_DOC_NO_4          VARCHAR2(30);
V_DOC_SEQNO_4       NUMBER;

V_USE_QTY_P         TB_INV013.USE_QTY%TYPE;  -- 기존 SAP 문서 사용량
V_USE_QTY_C         TB_INV013.USE_QTY%TYPE;  -- 새 SAP 문서 사용량
V_BATCH_USE_QTY_C   TB_INV010.USE_QTY%TYPE;  -- 변경 후 배치 전체 사용량
V_USE_DIFF_QTY      TB_INV010.USE_QTY%TYPE;  -- 사용량 증감분
V_INV013_EXISTS     VARCHAR2(1);


/* ================================================================
 * 3. SAVE 시작 부분: 기존 DOC1/2 초기화 다음에 추가
 *    이미 있으면 중복 추가하지 않는다.
 * ================================================================ */
-- V_DOC_NO_3 := FN_GET_MDOCNO('M', 'IF143');
-- V_DOC_SEQNO_3 := 0;
-- V_DOC_NO_4 := FN_GET_MDOCNO('M', 'IF130');
-- V_DOC_SEQNO_4 := 0;

/*
 * 기존 SAVE의 폐품 인터페이스 커서는 마지막 선택 행의 조건을 사용한다.
 * 같은 배치 누계가 여러 화면 행에 반복될 수도 있으므로, 현재 구조에서는
 * 한 번에 한 배치만 저장하도록 제한해야 중복 차감/전송을 막을 수 있다.
 * V_ARR_LIST := V_JSON.get_array('list'); 바로 다음에 추가한다.
 */
IF V_ARR_LIST.get_size <> 1 THEN
    P_SUCCESS := 'N';
    P_ERR_MSG := '폐품 보정은 한 번에 한 배치만 처리할 수 있습니다.';
    ROLLBACK;
    RETURN;
END IF;


/* ================================================================
 * 4. 현재 추가한 DOC3/DOC4 블록(기존 610~760행)을 전부 지우고
 *    같은 위치에 아래 블록을 넣는다.
 * ================================================================ */

/* 폐품 증감에 따라 실제 사용량은 반대로 증감한다. */
V_USE_DIFF_QTY := NVL(V_DISPO_QTY, 0) - NVL(V_CHG_QTY, 0);

/* 화면 수량은 모두 배치 기준이므로 배치 전체 변경 후 사용량도 검증한다. */
V_BATCH_USE_QTY_C := NVL(V_USE_QTY, 0) + V_USE_DIFF_QTY;

IF V_BATCH_USE_QTY_C < 0 THEN
    P_SUCCESS := 'N';
    P_ERR_MSG := '폐품 변경 후 배치 사용량이 0보다 작아질 수 없습니다.';
    ROLLBACK;
    RETURN;
END IF;

IF NVL(V_CHG_QTY, 0) >= NVL(V_BATCH_USE_QTY_C, 0) THEN
    P_SUCCESS := 'N';
    P_ERR_MSG := '폐품량은 변경 후 배치 사용량보다 작아야 합니다.';
    ROLLBACK;
    RETURN;
END IF;

SELECT ORDER_NO
  INTO V_ORDER_NO
  FROM TB_SCH012
 WHERE WRK_ORDR_NO = V_WRK_ORDR_NO
   AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO;

SELECT SAP_WRK_CD
  INTO V_SAP_WRK_CD
  FROM TB_MAS012
 WHERE MACH_CD = V_MACH_CD;

SELECT CASE
           WHEN MATNR_DIV IN ('FERT', 'HAWA') THEN '2000'
           ELSE LGPRO
       END
  INTO V_STOR_LOC_CD
  FROM TB_MAS001
 WHERE WERKS = V_WERKS
   AND MATNR = V_MATNR_M;

V_INV013_EXISTS := 'Y';

BEGIN
    SELECT USE_QTY,
           DOC_NO,
           DOC_SEQNO,
           SDOC_NO,
           SDOC_SEQNO
      INTO V_USE_QTY_P,
           V_DOC_NO,
           V_DOC_SEQNO,
           V_SDOC_NO,
           V_SDOC_SEQNO
      FROM TB_INV013
     WHERE WERKS = V_WERKS
       AND MACH_CD = V_MACH_CD
       AND PRFM_DT = V_PRFM_DT
       AND MATNR = V_MATNR_M
       AND ORDER_NO = V_ORDER_NO
       AND LOT_NO = V_LOT_NO_M
       FOR UPDATE;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        V_INV013_EXISTS := 'N';
        V_USE_QTY_P := 0;
        V_DOC_NO := NULL;
        V_DOC_SEQNO := NULL;
        V_SDOC_NO := NULL;
        V_SDOC_SEQNO := NULL;
END;

/*
 * 기존 SAP 문서가 있으면 그 문서 수량에 폐품 증감분만 반영한다.
 * 기존 SAP 문서가 없으면 배치 전체 변경 사용량으로 최초 등록한다.
 */
IF V_INV013_EXISTS = 'Y' THEN
    V_USE_QTY_C := NVL(V_USE_QTY_P, 0) + V_USE_DIFF_QTY;
ELSE
    V_USE_QTY_C := V_BATCH_USE_QTY_C;
END IF;

IF V_USE_QTY_C < 0 THEN
    P_SUCCESS := 'N';
    P_ERR_MSG := 'SAP 자재투입 변경 수량이 0보다 작아질 수 없습니다.';
    ROLLBACK;
    RETURN;
END IF;

IF NVL(V_USE_QTY_P, 0) <> NVL(V_USE_QTY_C, 0) THEN

    /*
     * 기존 전송은 존재하지만 SAP 결과가 확정되지 않은 상태에서
     * 새 문서를 만들면 동일 사용량이 중복 전송될 수 있으므로 차단한다.
     */
    IF V_INV013_EXISTS = 'Y'
       AND NVL(V_DOC_NO, ' ') <> ' '
       AND NVL(V_SDOC_NO, ' ') IN (' ', 'E') THEN
        P_SUCCESS := 'N';
        P_ERR_MSG := '기존 자재투입 SAP 전송이 미완료 상태입니다. 인터페이스 처리 결과를 먼저 확인해 주세요.';
        ROLLBACK;
        RETURN;
    END IF;

    /* 기존 SAP 확정문서 취소: DOC3 / MES_IF_143 */
    IF V_INV013_EXISTS = 'Y'
       AND NVL(V_USE_QTY_P, 0) > 0
       AND NVL(V_SDOC_NO, ' ') NOT IN (' ', 'E') THEN

        V_DOC_SEQNO_3 := V_DOC_SEQNO_3 + 1;

        INSERT INTO TB_IFS014
        (
            AUFNR, POSNR, BUDAT, MATNR, MENGE, WERKS,
            LGORT, CHARG, WORKCENTERCODE,
            MDOCNO, MDOCSEQ, MBLNR, MJAHR,
            ZRESULT, MAKE_DATE, MAKER
        )
        VALUES
        (
            V_ORDER_NO, '10', V_PRFM_DT, V_MATNR_M,
            V_USE_QTY_P, V_WERKS,
            V_STOR_LOC_CD, REPLACE(V_LOT_NO_M, '*', ''), V_SAP_WRK_CD,
            V_DOC_NO_3, TO_CHAR(V_DOC_SEQNO_3),
            V_SDOC_NO, V_SDOC_SEQNO,
            'N', V_DATE, V_SESS_USER_ID
        );
    END IF;

    /* 변경된 자재투입 등록: DOC4 / MES_IF_130 */
    IF V_USE_QTY_C > 0 THEN
        V_DOC_SEQNO_4 := V_DOC_SEQNO_4 + 1;

        INSERT INTO TB_IFS008
        (
            AUFNR, POSNR, BUDAT, MATNR, MENGE,
            LGORT, CHARG, MDOCNO, MDOCSEQ,
            ZRESULT, MAKE_DATE, MAKER,
            WORKCENTERCODE, WERKS
        )
        VALUES
        (
            V_ORDER_NO, '10', V_PRFM_DT, V_MATNR_M, V_USE_QTY_C,
            V_STOR_LOC_CD, REPLACE(V_LOT_NO_M, '*', ''),
            V_DOC_NO_4, TO_CHAR(V_DOC_SEQNO_4),
            'N', V_DATE, V_SESS_USER_ID,
            V_SAP_WRK_CD, V_WERKS
        );

        IF V_INV013_EXISTS = 'Y' THEN
            UPDATE TB_INV013
               SET USE_QTY = V_USE_QTY_C,
                   UNIT = V_UNIT,
                   DOC_NO = V_DOC_NO_4,
                   DOC_SEQNO = V_DOC_SEQNO_4,
                   SDOC_NO = NULL,
                   SDOC_SEQNO = NULL
             WHERE WERKS = V_WERKS
               AND MACH_CD = V_MACH_CD
               AND PRFM_DT = V_PRFM_DT
               AND MATNR = V_MATNR_M
               AND ORDER_NO = V_ORDER_NO
               AND LOT_NO = V_LOT_NO_M;
        ELSE
            INSERT INTO TB_INV013
            (
                WERKS, MACH_CD, PRFM_DT, MATNR,
                ORDER_NO, LOT_NO, USE_QTY, UNIT,
                DOC_NO, DOC_SEQNO, REGDATE, REGID
            )
            VALUES
            (
                V_WERKS, V_MACH_CD, V_PRFM_DT, V_MATNR_M,
                V_ORDER_NO, V_LOT_NO_M, V_USE_QTY_C, V_UNIT,
                V_DOC_NO_4, V_DOC_SEQNO_4, V_DATE, V_SESS_USER_ID
            );
        END IF;
    ELSE
        IF V_INV013_EXISTS = 'Y' THEN
            DELETE FROM TB_INV013
             WHERE WERKS = V_WERKS
               AND MACH_CD = V_MACH_CD
               AND PRFM_DT = V_PRFM_DT
               AND MATNR = V_MATNR_M
               AND ORDER_NO = V_ORDER_NO
               AND LOT_NO = V_LOT_NO_M;
        END IF;
    END IF;
END IF;


/* ================================================================
 * 5. SAVE 끝의 OUT 반환 부분. 이미 있으면 중복 추가하지 않는다.
 * ================================================================ */
-- IF V_DOC_SEQNO_3 > 0 THEN
--     P_DOC_NO3 := V_DOC_NO_3;
-- END IF;
--
-- IF V_DOC_SEQNO_4 > 0 THEN
--     P_DOC_NO4 := V_DOC_NO_4;
-- END IF;


/* ================================================================
 * 6. 기존 폐품 조회 REF CURSOR의 INTO는 반드시 삭제한다.
 * ================================================================ */
-- 잘못된 형태:
-- OPEN PROD_CUR FOR SELECT ... INTO 변수들 FROM ...;
--
-- 올바른 형태:
-- OPEN PROD_CUR FOR SELECT ... FROM ...;
-- FETCH PROD_CUR INTO 변수들;
