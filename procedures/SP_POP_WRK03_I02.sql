
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK03_I02" 
(
    P_WERKS             IN VARCHAR2
,P_MACH_CD          IN VARCHAR2
,P_IOTYPE           IN VARCHAR2
,P_USERID           IN VARCHAR2
,P_ORDER_NO         IN VARCHAR2
,P_WRK_ORDR_NO      IN VARCHAR2
,P_WRK_ORDR_SEQNO   IN VARCHAR2
,P_MATNR            IN VARCHAR2
,P_LOT_NO           IN VARCHAR2
,P_PRD_STR_DATE     IN VARCHAR2
,P_PRD_END_DATE     IN VARCHAR2
,P_ABN_CD           IN VARCHAR2
,P_RMK              IN VARCHAR2
,P_ABN_FUNC         OUT VARCHAR2
,Lang               IN VARCHAR2 DEFAULT 'KO'
,RS_CODE            OUT VARCHAR2
,RS_MSG             OUT VARCHAR2
,CUR_1          OUT SYS_REFCURSOR
,CUR_2          OUT SYS_REFCURSOR
)
/*======================================================================================
 * PROGRAM ID    : POP_WRK03
 * PROGRAM NAME  : 비가동 등록(P200)
 * VERSION       : 1.0.1
 * DESCRIPTION   : 작성된 비가동 이력을 저장한다.
 *
 * AUTHOR NAME   : 김지언
 * CREATE DATE   : 2026/09/08
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- -------------------------------------------------
 *    Date        Ver       Name          Description
 * ------------ ------- ------------- -------------------------------------------------
 * 2026/09/08    1.0.0   김지언         Initial Version
 *======================================================================================
 *  관련 테이블
 * - [TB_WRK003] : (C.U.) 비가동 실적
 * - [TB_WRK011] : (..U.) 작업장 현황
 * - [TB_WRK012] : (..U.) 작업장 가동현황
 *======================================================================================*/
AS
    --프로그램 ID
    V_PRG_NM			VARCHAR2(100)  := 'SP_POP_WRK03_I02';     -- PROCEDURE NAME
    V_SESS_USER_ID		VARCHAR2(20) := P_USERID; --USERID
-- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER	EXCEPTION;
    E_SQL_ERR_CD		NUMBER(5) := 0;
    E_SQL_ERR_MSG		VARCHAR2(4000);
    --파라미터 처리
    V_WRK_ORDR_SEQ_NO	NUMBER := TO_NUMBER(P_WRK_ORDR_SEQNO);
    V_PRD_STR_DATE		DATE := TO_DATE(P_PRD_STR_DATE, 'YYYY-MM-DD HH24:MI:SS');
    V_PRD_END_DATE		DATE := TO_DATE(P_PRD_END_DATE, 'YYYY-MM-DD HH24:MI:SS');
    V_IOTYPE			VARCHAR2(10) := P_IOTYPE;
    --내부 변수 등록
    V_PROC_CD			TB_MAS012.PROC_CD%TYPE;

    V_DATE				DATE := SYSDATE;
    V_REC_DATE			VARCHAR2(10) := FN_RECDATE(V_DATE);
    V_PRFM_DATE			VARCHAR2(10) := FN_RECDATE(V_PRD_STR_DATE);
    V_BEF_STR_DATE		DATE; --이전 가동이력 시작시간
    V_DOC_NO			VARCHAR2(29); --MES문서번호
    V_DOC_SEQNO			NUMBER;
    V_WRK_CLASS			VARCHAR2(10);
    V_WRK_SHIFT			VARCHAR2(10);
    V_ABN_TM			NUMBER;
    V_ABN_NM			VARCHAR2(30);
    V_STR_DATE			DATE;
    V_END_DATE			DATE;
    V_RUN_STA			VARCHAR2(10);
    V_RUN_STA_NM		VARCHAR2(30);
    V_MACHINE			VARCHAR2(4);
    V_ORDR_STA			VARCHAR(1); --지시상태
    V_RTN_STA			VARCHAR(1); --복구시 상태
    V_IFMC				VARCHAR2(1);
    V_SAP_WRK_CD		VARCHAR2(20);
    V_TIME_CHK_2		NUMBER := 0;
    V_TIME_CHK			NUMBER;
    V_IF_ID				VARCHAR2(20) := 'MES_IF_136'; --비가동 등록
    V_SQL				VARCHAR2(4000);
    V_DMY               VARCHAR2(1);
    V_CHKSTR			VARCHAR2(6);
    V_CHG_END_DTM		VARCHAR(6);
BEGIN
    --예외처리 시작(try)
    BEGIN
        BEGIN
            -- 종료시간 000000을 240000으로 변경
            V_CHKSTR := REPLACE(SUBSTR(P_PRD_END_DATE, 12, 8), ':', '');

            BEGIN
                SELECT PROC_CD
                INTO V_PROC_CD
                FROM TB_MAS012
                WHERE MACH_CD = P_MACH_CD;
            EXCEPTION WHEN NO_DATA_FOUND THEN
                RS_CODE := 'E';
                RS_MSG  := '해당 설비의 공정이 지정되지 않았습니다.\n기준정보를 확인하여 주시기 바랍니다.';
                RETURN;
            END;

            --시간입력시 분단위로 입력되며 시작시간을 01초로 지정
            IF SUBSTR(P_PRD_STR_DATE,-2) = '00' THEN
                V_PRD_STR_DATE := V_PRD_STR_DATE + (INTERVAL '1' SECOND);
            END IF;

            IF V_PRD_END_DATE IS NOT NULL THEN
                IF P_WERKS = 'P200' THEN
                    BEGIN
                        -- 합지랑 가공만 같은 MDOC NO로 가야할 듯 SEQ만 카운트하고
                        SELECT DOC_NO, DOC_SEQNO + 1
                        INTO V_DOC_NO, V_DOC_SEQNO
                        FROM TB_WRK003
                        WHERE 1=1
                          AND WERKS = P_WERKS
                          AND MACH_CD = P_MACH_CD
                          AND ABN_DT = FN_RECDATE(V_PRD_STR_DATE);
--                           AND CNL_YN = 'N';
                        SZP_MES_PLSQL_LOG(V_DOC_SEQNO, 'POP_WRK03_I02 V_DOC_SEQNO');
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            SZP_MES_PLSQL_LOG('NO_DATA_FOUND TEST', 'POP_WRK03_I01 DEBUG EXCEPTION');

                            -- [실무 팁] 데이터가 없을 때 채워줄 기본 세팅 정의 (예: 일련번호 1번으로 시작)
                            V_DOC_SEQNO := 1;
                            -- V_DOC_NO 채번 로직을 여기에 작성...
                            V_DOC_NO := FN_GET_MDOCNO('M','IF136');
                        WHEN OTHERS THEN
                            DBMS_OUTPUT.PUT_LINE('기타 에러 발생: ' || SQLERRM);
                    END;
                end if;

                IF V_DOC_NO IS NULL THEN
                    --문서번호 생성
                    V_DOC_NO := FN_GET_MDOCNO('M','IF136');
                    V_DOC_SEQNO := 1;
                end if;

                --비가동 시간 계산
                V_ABN_TM := CEIL((V_PRD_END_DATE - V_PRD_STR_DATE) * 24 * 60);
            ELSE
                V_DOC_NO := ' ';
                V_ABN_TM := 0;
            END IF;

            IF P_WRK_ORDR_NO IS NULL THEN
                V_ORDR_STA := 'N'; --COMP_YN => N : 대기, I : 진행, Y : 완료
            ELSE
                --지시정보
                IF P_WERKS = 'P200' THEN
                    IF V_PROC_CD = 'AA' THEN --화장지 합지기
                        SELECT COMP_YN
                        INTO V_ORDR_STA
                        FROM TB_SCH011
                        WHERE 1=1
                          AND WRK_ORDR_NO = P_WRK_ORDR_NO
                          AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO;
                    ELSIF V_PROC_CD = 'RA' THEN --화장지 가공기
                        SELECT COMP_YN
                        INTO V_ORDR_STA
                        FROM TB_SCH012
                        WHERE 1=1
                          AND WRK_ORDR_NO = P_WRK_ORDR_NO
                          AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO;
                    ELSE
                        V_ORDR_STA := '';
                    END IF;
                ELSE  --Default
                    V_ORDR_STA := 'I';
                END IF;
            END IF;

            V_RTN_STA := CASE WHEN V_ORDR_STA = 'I' THEN 'R' ELSE 'N' END;

            --설비정보
            SELECT MACHINE, SAP_WRK_CD, IFMC
            INTO V_MACHINE, V_SAP_WRK_CD, V_IFMC
            FROM TB_MAS012
            WHERE 1=1
              AND MACH_CD = P_MACH_CD;

            --비가동 정보
            SELECT ABN_NM, RUN_STA
            INTO V_ABN_NM, V_RUN_STA
            FROM TB_MAS020
            WHERE 1=1
              AND WERKS = P_WERKS
              AND ABN_CD = P_ABN_CD;

            --운전상태 명칭 조회
            SELECT CDESC1
            INTO V_RUN_STA_NM
            FROM CMCDV
            WHERE 1=1
              AND CMCDKY = 'RUNSTA'
              AND CMCDVL = V_RUN_STA;

            --현재 작업자 정보
            BEGIN
                SELECT WRK_CLASS, WRK_SHIFT
                INTO V_WRK_CLASS, V_WRK_SHIFT
                FROM TB_WRK011
                WHERE 1=1
                  AND WERKS = P_WERKS
                  AND MACH_CD = P_MACH_CD
                  AND IN_OUT = V_IOTYPE;
            EXCEPTION WHEN NO_DATA_FOUND THEN
                V_WRK_CLASS := '';
                V_WRK_SHIFT := '';
                dbms_output.put_line('작업장정보 확인');
            --RETURN;
            END;

            --------------------------------------------------------------------
            -- 비가동 중복여부 확인 (표준 구간 교차 검증)
            -- 1초라도 겹치면 중복 차단 / 맞닿는 경계 시간은 정상이용 허용
            --------------------------------------------------------------------
            IF V_PRD_END_DATE IS NOT NULL THEN
                SELECT COUNT(1), MIN(STR_DATE), MAX(END_DATE)
                INTO V_TIME_CHK, V_STR_DATE, V_END_DATE
                FROM TB_WRK003
                WHERE 1=1
                  AND WERKS = P_WERKS
                  AND MACH_CD = P_MACH_CD
                  AND CNL_YN = 'N'
                  AND STR_DATE < V_PRD_END_DATE
                  AND END_DATE > V_PRD_STR_DATE;

                IF V_TIME_CHK > 0 THEN
                    RS_CODE := 'E';
                    RS_MSG  := '입력한 비가동 기간이 기존 비가동 이력과 중복됩니다.\n아래의 기간을 확인하여 주시기 바랍니다.\n';
                    RS_MSG  := RS_MSG || TO_CHAR(V_STR_DATE,'YYYY-MM-DD HH24:MI') || ' ~ ';
                    RS_MSG  := RS_MSG || TO_CHAR(V_END_DATE,'YYYY-MM-DD HH24:MI');
                    RETURN;
                END IF;
            END IF;
            --------------------------------------------------------------------

            V_PRFM_DATE := FN_RECDATE(V_PRD_STR_DATE);

            -- 추가             
            IF V_PROC_CD = 'RA' THEN
                V_PRD_STR_DATE := TO_DATE(P_PRD_STR_DATE, 'YYYY-MM-DD HH24:MI:SS');
            END IF;

            -- 비가동 이력 수정
            UPDATE TB_WRK003
            SET END_DATE = V_PRD_END_DATE
              , ABN_TM = ROUND((V_PRD_END_DATE - STR_DATE) * 24 * 60) --시간차이 분단위 계산
              , RUN_STA = V_RUN_STA
              , ABN_CD = P_ABN_CD
              , ABN_DT = V_PRFM_DATE --TO_CHAR(V_PRD_END_DATE,'YYYYMMDD')
              , RMK = P_RMK
              , CNL_YN = 'N'
              , DOC_NO = V_DOC_NO
              , DOC_SEQNO = V_DOC_SEQNO
              , UPDDATE = V_DATE
              , UPDID = P_USERID
            WHERE 1=1
              AND WERKS = P_WERKS
              AND MACH_CD = P_MACH_CD
              AND IN_OUT = P_IOTYPE
              AND STR_DATE = V_PRD_STR_DATE;
            -- 신규 비가동 이력 등록
            IF SQL%ROWCOUNT = 0 OR V_PRD_END_DATE IS NULL THEN
                IF SQL%ROWCOUNT = 0 THEN
                    --비가동 이력 등록
                    INSERT INTO TB_WRK003 (WERKS, MACH_CD, IN_OUT, STR_DATE, END_DATE, RUN_STA, ABN_CD, ABN_TM, ABN_DT,
                                           WRK_CLASS, WRK_SHIFT, WRK_ORDR_NO, WRK_ORDR_SEQNO, RMK, DOC_NO, DOC_SEQNO,
                                           CNL_YN, REGDATE, REGID)
                    VALUES(P_WERKS, P_MACH_CD, P_IOTYPE, V_PRD_STR_DATE, V_PRD_END_DATE, V_RUN_STA, P_ABN_CD, V_ABN_TM,
                           V_PRFM_DATE,
                           V_WRK_CLASS, V_WRK_SHIFT, P_WRK_ORDR_NO, V_WRK_ORDR_SEQ_NO, P_RMK, V_DOC_NO, V_DOC_SEQNO,
                           'N', V_DATE, P_USERID);
                END IF;
                --작업장 현황 상태 변경(비가동 등록시 정지)
                UPDATE TB_WRK011
                SET MACH_STA = CASE WHEN V_PRD_END_DATE IS NULL
                                        THEN 'S' ELSE V_RTN_STA END
                  , ABN_DTM = CASE WHEN V_PRD_END_DATE IS NULL
                                       THEN V_PRD_STR_DATE ELSE NULL END
                  , ABN_CD = CASE WHEN V_PRD_END_DATE IS NULL
                                      THEN P_ABN_CD ELSE NULL END
                  , UPDDATE = V_DATE
                  , UPDID = P_USERID
                WHERE 1=1
                  AND WERKS = P_WERKS
                  AND MACH_CD = P_MACH_CD;
                --이전 작업 시작 시간 조회
                BEGIN
                    SELECT MAX(STR_DATE) INTO V_BEF_STR_DATE
                    FROM TB_WRK012
                    WHERE 1=1
                      AND WERKS = P_WERKS
                      AND MACH_CD = P_MACH_CD
                      AND IN_OUT = V_IOTYPE
                      AND END_DATE IS NULL;
                EXCEPTION WHEN NO_DATA_FOUND THEN
                    V_BEF_STR_DATE := V_PRD_STR_DATE;
                END;
                --기존 작업장 가동 현황 변경(가동중 이력 완료처리)
                UPDATE TB_WRK012
                SET END_DATE = V_PRD_STR_DATE
                  , UPDDATE = V_DATE
                  , UPDID = P_USERID
                WHERE 1=1
                  AND WERKS = P_WERKS
                  AND MACH_CD = P_MACH_CD
                  AND IN_OUT = V_IOTYPE
                  AND STR_DATE = V_BEF_STR_DATE;
                --신규 작업장 가동 현황 등록(비가동 이력 추가)
                BEGIN
                    INSERT INTO TB_WRK012 (WERKS, MACH_CD, IN_OUT, STR_DATE, END_DATE,
                                           WRK_ORDR_NO, WRK_ORDR_SEQNO, ORDER_NO, --ORDER_SEQNO,
                                           MATNR, LINE_STA, BEF_LINE_STA, ABN_CD, RMK,
                                           REGDATE, REGID)
                    VALUES(P_WERKS, P_MACH_CD, V_IOTYPE, V_PRD_STR_DATE, V_PRD_END_DATE,
                           P_WRK_ORDR_NO, V_WRK_ORDR_SEQ_NO, P_ORDER_NO,
                           P_MATNR, 'S', 'R', P_ABN_CD, P_RMK,
                           V_DATE, P_USERID);
                EXCEPTION
                    WHEN OTHERS THEN
                        V_PRD_STR_DATE := V_PRD_STR_DATE + (INTERVAL '2' SECOND);
                        INSERT INTO TB_WRK012 (WERKS, MACH_CD, IN_OUT, STR_DATE, END_DATE,
                                               WRK_ORDR_NO, WRK_ORDR_SEQNO, ORDER_NO, --ORDER_SEQNO,
                                               MATNR, LINE_STA, BEF_LINE_STA, ABN_CD, RMK,
                                               REGDATE, REGID)
                        VALUES(P_WERKS, P_MACH_CD, V_IOTYPE, V_PRD_STR_DATE, V_PRD_END_DATE,
                               P_WRK_ORDR_NO, V_WRK_ORDR_SEQ_NO, P_ORDER_NO,
                               P_MATNR, 'S', 'R', P_ABN_CD, P_RMK,
                               V_DATE, P_USERID);
                END;
                -- 비가동 종료시 작업장 현황 수정
            ELSE
                IF V_PRD_END_DATE IS NULL THEN
                    RS_CODE := 'E';
                    RS_MSG  := '비가동 완료시간을 확인하여 주시기 바랍니다.';
                    RETURN;
                ELSE
                    -- 작업장 현황 가동처리(Run)
                    UPDATE TB_WRK011
                    SET MACH_STA = V_RTN_STA
                      , RMK = V_ORDR_STA
                      , ABN_DTM = NULL
                      , ABN_CD= NULL
                      , UPDDATE = V_DATE
                      , UPDID = P_USERID
                    WHERE 1=1
                      AND WERKS = P_WERKS
                      AND MACH_CD = P_MACH_CD;
                    --작업장 가동현황 수정
                    UPDATE TB_WRK012
                    SET END_DATE = V_PRD_END_DATE
                      , UPDDATE = V_DATE
                      , UPDID = P_USERID
                    WHERE 1=1
                      AND WERKS = P_WERKS
                      AND MACH_CD = P_MACH_CD
                      AND IN_OUT = V_IOTYPE
                      AND STR_DATE = V_PRD_STR_DATE;
                END IF;
            END IF;

            --비가동 완료 등록시 I/F 전송
            IF V_PRD_END_DATE IS NOT NULL THEN
                --작업자 그룹조회
                BEGIN
                    SELECT WRK_CLASS INTO V_WRK_CLASS
                    FROM USRMA
                    WHERE 1=1
                      AND USERID = P_USERID;
                EXCEPTION WHEN NO_DATA_FOUND THEN
                    V_WRK_CLASS := '';
                END;

                --비가동 I/F 전송
                IF V_CHKSTR = '000000' THEN
                    IF V_RUN_STA = '99' THEN
                        V_CHG_END_DTM := '240001';
                    ELSE
                        V_CHG_END_DTM := '240000';
                    END IF;
                ELSE
                    -- P300 > 비가동 이력 누락 대응 처리 START - 2024/10/08 강지선
                    -- 계획운휴(99) 일 경우 : 초를 무조건 01로 지정 =>  ex.) 07:00:01
                    IF V_RUN_STA = '99' THEN
                        V_PRD_END_DATE := V_PRD_END_DATE + (INTERVAL '1' SECOND);
                    END IF;

                    V_CHG_END_DTM := TO_CHAR(V_PRD_END_DATE,'HH24MISS');
                END IF;

                --BUDAT = 생산일자
                --PRODT = 실적일자(전기일자)로 변경
                INSERT INTO TB_IFS013 (WERKS, BUDAT, PRODT, MACHINE, IFMC,
                                       STATM, ENDTM, RUNTIME,
                                       STSCODE, STSTEXT, RSNCODE, RSNTEXT, MDOCNO, MDOCSEQ,
                                       MAKE_DATE, MAKER, WORKGROUP, ARBPL,
                                       REMARK, ENDDT)
                VALUES(P_WERKS, TO_CHAR(V_PRD_STR_DATE,'YYYYMMDD'), V_PRFM_DATE, V_MACHINE, V_IFMC,
                       TO_CHAR(V_PRD_STR_DATE,'HH24MISS'), V_CHG_END_DTM, V_ABN_TM,
                       V_RUN_STA, V_RUN_STA_NM, P_ABN_CD, V_ABN_NM, V_DOC_NO, V_DOC_SEQNO,
                       V_DATE, P_USERID, V_WRK_CLASS, V_SAP_WRK_CD,
                       SUBSTRB(P_RMK, 1, 100), TO_CHAR(V_PRD_END_DATE,'YYYYMMDD'));

                --SAP FUNC ID
                SELECT RFCFN
                INTO P_ABN_FUNC
                FROM TB_ITFMA
                WHERE 1=1
                  AND IFID = V_IF_ID;
                --인터페이스 파라미터
                OPEN CUR_1 FOR
                    SELECT V_IF_ID AS I_IF_ID
                         , 'M' || LTRIM(RTRIM(TO_CHAR(SEQ_GET_IFR_KEY.NEXTVAL, '00000000000000000000000000000'))) AS I_IF_KEY
                    FROM dual;
                --인터페이스 상세 파라미터
                V_SQL := FN_IF_QUERY(V_IF_ID, V_DOC_NO);
                IF V_SQL IS NOT NULL THEN
                    OPEN CUR_2 FOR V_SQL;
                END IF;
            END IF;
            --작업 정상 종료 코드 등록
            RS_CODE := 'S';
        END;
        --예외처리(catch)
--    EXCEPTION
--    WHEN E_EXCEPTION_USER THEN
--        -- 에러 내역 SET
--        E_SQL_ERR_CD        := SQLCODE;
--        E_SQL_ERR_MSG       := SUBSTRB(SQLERRM,1,300);
--
--        ROLLBACK;
--        SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
--
--        RS_CODE := 'E';
--        RS_MSG  := SQLERRM;
--        RETURN;
--    WHEN OTHERS THEN
--        E_SQL_ERR_CD        := -20001;
--        E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';
--
--        ROLLBACK;
--        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
--
--        RS_CODE := 'E';
--        RS_MSG  := SQLERRM;
--        RETURN;
        --예외처리 종료
    END;
END ;
/
