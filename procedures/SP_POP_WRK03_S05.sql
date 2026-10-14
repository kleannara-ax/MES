
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK03_S05" 
(
    P_WERKS            IN VARCHAR2
,P_MACH_CD          IN VARCHAR2
,P_PRD_STR_DATE     IN VARCHAR2
,P_PRD_END_DATE     IN VARCHAR2
,Lang              IN VARCHAR2 DEFAULT 'KO'
,RS_CODE           OUT VARCHAR2
,RS_MSG            OUT VARCHAR2
)
/*==============================================================================
 * PROGRAM ID    : POP_WRK03
 * PROGRAM NAME  : 비가동 등록
 * VERSION       : 1.0.2
 * DESCRIPTION   : 비가동 사전 밸리데이션 체크 (접점 시간 허용)
 *==============================================================================*/
AS
    --프로그램 ID
    V_PRG_NM        VARCHAR2(100)  := 'SP_POP_WRK03_S05';
    V_PLT_CD        VARCHAR2(2)    := '99';
    V_SESS_USER_ID  VARCHAR2(20)   := 'TEST';

    -- 오라클 에러 처리용 변수
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5)    := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);

    -- 파라미터 처리
    V_PRD_STR_DATE  DATE := TO_DATE(P_PRD_STR_DATE, 'YYYY-MM-DD HH24:MI:SS');
    V_PRD_END_DATE  DATE := TO_DATE(P_PRD_END_DATE, 'YYYY-MM-DD HH24:MI:SS');

    -- 내부 변수
    V_STR_DATE      DATE;
    V_END_DATE      DATE;
    V_TIME_CHK      NUMBER := 0;

BEGIN
    BEGIN
        -- 1. 시작시간만 존재하거나, 완료시간까지 모두 입력된 경우 통합 체크
        -- 겹침 판정 기준: (기존 STR_DATE < 신규 END_DATE) AND (기존 END_DATE > 신규 STR_DATE)
        IF V_PRD_END_DATE IS NOT NULL THEN

            -- 신규 비가동 기간 [V_PRD_STR_DATE ~ V_PRD_END_DATE] 과 겹치는 기존 데이터 조회
            SELECT COUNT(STR_DATE), MIN(STR_DATE), MAX(END_DATE)
            INTO V_TIME_CHK, V_STR_DATE, V_END_DATE
            FROM TB_WRK003
            WHERE WERKS = P_WERKS
              AND MACH_CD = P_MACH_CD
              AND CNL_YN = 'N'
              AND STR_DATE < V_PRD_END_DATE
              AND END_DATE > V_PRD_STR_DATE;

            IF V_TIME_CHK > 0 THEN
                RS_CODE := 'E';
                RS_MSG  := '중복되는 비가동 시간이 있습니다. 재등록 해 주세요.' || CHR(10) ||
                           '아래 기간의 비가동실적을 확인바랍니다.' || CHR(10) ||
                           TO_CHAR(V_STR_DATE, 'YYYY-MM-DD HH24:MI') || ' ~ ' || TO_CHAR(V_END_DATE, 'YYYY-MM-DD HH24:MI');
                RETURN;
            END IF;

        ELSE
            -- 2. 종료시간 없이 시작시간만 입력된 경우 (진행 중인 비가동 등록 시)
            -- 입력된 시작시간이 기존 진행중/완료된 비가동 시간 '내부'에 위치하는지 검증
            SELECT COUNT(STR_DATE), MIN(STR_DATE), MAX(END_DATE)
            INTO V_TIME_CHK, V_STR_DATE, V_END_DATE
            FROM TB_WRK003
            WHERE WERKS = P_WERKS
              AND MACH_CD = P_MACH_CD
              AND CNL_YN = 'N'
              AND STR_DATE <= V_PRD_STR_DATE
              AND END_DATE > V_PRD_STR_DATE;

            IF V_TIME_CHK > 0 THEN
                RS_CODE := 'E';
                RS_MSG  := '비가동 시작시간이 이미 등록된 비가동 구간에 포함되어 있습니다.' || CHR(10) ||
                           '아래 기간 이후로 변경하여 주시기 바랍니다.' || CHR(10) ||
                           TO_CHAR(V_STR_DATE, 'YYYY-MM-DD HH24:MI') || ' ~ ' || TO_CHAR(V_END_DATE, 'YYYY-MM-DD HH24:MI');
                RETURN;
            END IF;
        END IF;

        -- 정상 완료
        RS_CODE := 'S';
        RS_MSG  := '성공';

    EXCEPTION
        WHEN E_EXCEPTION_USER THEN
            E_SQL_ERR_CD  := SQLCODE;
            E_SQL_ERR_MSG := SUBSTRB(SQLERRM, 1, 300);
            ROLLBACK;
            SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
            RS_CODE := 'E';
            RS_MSG  := SQLERRM;
            RETURN;

        WHEN OTHERS THEN
            E_SQL_ERR_CD  := SQLCODE;
            E_SQL_ERR_MSG := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM, 1, 500) || ']';
            ROLLBACK;
            RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
            RS_CODE := 'E';
            RS_MSG  := SQLERRM;
            RETURN;
    END;
END SP_POP_WRK03_S05;
/
