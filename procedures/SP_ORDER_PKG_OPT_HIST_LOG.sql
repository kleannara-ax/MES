
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_ORDER_PKG_OPT_HIST_LOG" (
    P_WRK_ORDR_NO    IN VARCHAR2,  -- 지시번호
    P_WRK_ORDR_SEQ   IN NUMBER,    -- 지시순번
    P_CORE_INCH      IN VARCHAR2,  -- [NEW] 코어
    P_COVER_YN       IN VARCHAR2,  -- [NEW] 커버여부
    P_CORR_YN        IN VARCHAR2,  -- [NEW] 코너여부
    P_PACK_YN        IN VARCHAR2,  -- [NEW] 포장여부
    P_USER_ID        IN VARCHAR2,  -- 수정자 ID
    -- 기존 데이터 (R_OLD 값들)
    P_OLD_CORE       IN VARCHAR2,  -- [OLD] 코어
    P_OLD_COVER      IN VARCHAR2,  -- [OLD] 커버여부
    P_OLD_CORR       IN VARCHAR2,  -- [OLD] 코너여부
    P_OLD_PACK       IN VARCHAR2,   -- [OLD] 포장여부

    P_DIV           IN VARCHAR2    -- 입력 구분값
) IS
    V_HIST_CNT NUMBER := 0;
    V_IS_CHG   BOOLEAN := FALSE;
BEGIN
    -- 1. 변경 여부 판단 (NVL 처리로 NULL 데이터 비교 가능하게 함)
    IF NVL(P_OLD_CORE,  '-') <> NVL(P_CORE_INCH, '-') OR
       NVL(P_OLD_COVER, '-') <> NVL(P_COVER_YN,  '-') OR
       NVL(P_OLD_CORR,  '-') <> NVL(P_CORR_YN,   '-') OR
       NVL(P_OLD_PACK,  '-') <> NVL(P_PACK_YN,   '-')
    THEN
        V_IS_CHG := TRUE;
    END IF;

    -- 2. 변경사항이 있을 때만 히스토리 기록
    IF V_IS_CHG THEN
        -- [최초 1회] 해당 지시에 ORIGINAL 데이터가 있는지 확인
        SELECT COUNT(*) INTO V_HIST_CNT
        FROM TB_ORDER_PKG_OPT_HIST
        WHERE WRK_ORDR_NO  = P_WRK_ORDR_NO
          AND WRK_ORDR_SEQ = P_WRK_ORDR_SEQ
          AND DATA_TYPE    = 'ORIGINAL';

        -- ORIGINAL이 없으면 OLD 데이터를 먼저 저장
        IF V_HIST_CNT = 0 THEN
            INSERT INTO TB_ORDER_PKG_OPT_HIST (
                WRK_ORDR_NO, WRK_ORDR_SEQ, CORE_INCH, COVER_YN, CORR_YN, PACK_YN, DATA_TYPE, REGID, REGDATE, DIV
            ) VALUES (
                P_WRK_ORDR_NO, P_WRK_ORDR_SEQ, P_OLD_CORE, P_OLD_COVER, P_OLD_CORR, P_OLD_PACK, 'ORIGINAL', P_USER_ID, SYSDATE, P_DIV
            );
        END IF;

        -- [매 변경시] 현재 값(AFTER) 저장
        INSERT INTO TB_ORDER_PKG_OPT_HIST (
            WRK_ORDR_NO, WRK_ORDR_SEQ, CORE_INCH, COVER_YN, CORR_YN, PACK_YN, DATA_TYPE, REGID, REGDATE, DIV
        ) VALUES (
            P_WRK_ORDR_NO, P_WRK_ORDR_SEQ, P_CORE_INCH, P_COVER_YN, P_CORR_YN, P_PACK_YN, 'AFTER', P_USER_ID, SYSDATE, P_DIV
        );
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        -- 에러 발생 시 공통 로그 프로시저 호출 및 에러 전달
        SZP_MES_PLSQL_LOG('SP_ORDER_PKG_OPT_HIST_LOG ERROR: ' || SQLERRM, 'INV06_S01');
        RAISE;
END;
/
