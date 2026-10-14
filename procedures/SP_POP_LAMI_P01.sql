
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_LAMI_P01" 
(
     P_WERKS        IN VARCHAR2
    ,P_PROC_CD      IN VARCHAR2
    ,P_MACH_CD      IN VARCHAR2
    ,P_IOTYPE       IN VARCHAR2
    ,P_MACHINE      IN VARCHAR2
    ,P_PRD_STR_DATE IN VARCHAR2     --YYYYMMDD
    ,P_PRD_END_DATE IN VARCHAR2     --YYYYMMDD
    ,P_PCODE        IN VARCHAR2     --지종
    ,P_WEIGHT       IN VARCHAR2     --평량
    ,P_MATNR        IN VARCHAR2     --자재코드
    ,P_WLEN         IN VARCHAR2     --가로
    ,P_VLEN         IN VARCHAR2     --세로
    ,P_USERID       IN VARCHAR2
    ,Lang           IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE        OUT VARCHAR2
    ,RS_MSG         OUT VARCHAR2
    ,CUR_1          OUT SYS_REFCURSOR
    ,CUR_2          OUT SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : POP_WRK07
 * PROGRAM NAME  : PS 작업지시 목록조회
 * VERSION       : 1.0.0
 * DESCRIPTION   : 현재 설비의 작업지시 목록을 조회한다.
 *                 
 * AUTHOR NAME   : 김병무
 * CREATE DATE   : 2022/05/11
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/05/31    1.0.0   김병무         HL과 PS의 작업지시 조회를 분리함. (SP_POP_WRK07_S01=HL, SP_POP_WRK07_S02=PS)
 *==============================================================================
 *  관련 테이블
 * - [TB_SCH015] : (.R..) 제지 점보롤작업지시
 * - [TB_SCH016] : (.R..) 제지 밀롤작업지시
 * - [TB_MAS001] : (.R..) 자재 기준 정보
 * - [TB_WRK002] : (.R..) PS 생산실적 이력
 * - [TB_INV003] : (.R..) 자재 투입 정보 (공정투입된 반제품)
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM        VARCHAR2(100)  := 'SP_POP_LAMI_P01';     -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID   varchar2(20) := 'TEST'; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);
    --내부변수 관리
    V_COLINFO VARCHAR2(1000);--컬럼설정1
    V_COLTYPE VARCHAR2(1000);--컬럼설정2
    V_WRK_CD VARCHAR2(8);--설비별 작업장코드
    V_SQL VARCHAR2(5000) := '';

    V_WRK_ORDR_NO       TB_WRK011.WRK_ORDR_NO%TYPE;
    V_WRK_ORDR_SEQNO    TB_WRK011.WRK_ORDR_SEQNO%TYPE;
    V_MATNR             TB_WRK011.MATNR%TYPE;
    TSQL VARCHAR2(5000) := '';

BEGIN
    --예외처리 시작(try)
    BEGIN

        --공정별 조회프로시저 변경
        IF P_PROC_CD = 'LP' THEN     -- PS 투입정보(ZA : 문재적재소)
            --grid 컬럼 정보 설정
            V_COLINFO := '선택@C^60|작업지시번호@C^200|오더번호@C^130|지종@H|지종명@H|평량@H|가로@H|세로@H|생산지시중량@R^120|총사용중량@R^120|실중량@R^120|폐품중량@H|오더유형@C^250|순번@H|상세보기@H|지시사항@H|자재코드@C^200';
            V_COLTYPE := 'CHK@Button|WRK_ORDR_NO@varchar|ORDER_NO@varchar|PCODE@varchar|PCODE_NM@varchar|BS_WGT@varchar|WLEN@varchar|VLEN@varchar|WRK_ORDR_QTY@varchar|TOT_WGT@varchar|PCNT@varchar|WGT@varchar|ORDER_DIV@varchar|WRK_ORDR_SEQNO@varchar|DBTN@Button|ORDER_RMK@varchar|MATNR@varchar';

            --컬럼설정 반환 테이블 작성
            OPEN CUR_1 FOR
            SELECT RTN_VALUES FROM FN_SPLIT(V_COLINFO||','||V_COLTYPE,',');

            BEGIN
                TSQL := TSQL || 'SELECT ';
                TSQL := TSQL || '''-'' AS CHK';
                TSQL := TSQL || ',A.WRK_ORDR_NO';        --재단 작업지시번호
--                TSQL := TSQL || ',''라미네이팅 인쇄코팅'' AS ORDER_GB';        --오더구분
                TSQL := TSQL || ',A.ORDER_NO         --오더번호
                                   ,B.PCODE            --지종
                                   ,B.PCODE_NM';         --지종명
                TSQL := TSQL || ',TO_CHAR(B.BS_WGT, ''fm999,999,999,990'') AS BS_WGT';           --평량
                TSQL := TSQL || ',TO_CHAR(B.WLEN, ''fm999,990'') AS WLEN';             --가로길
                TSQL := TSQL || ',TO_CHAR(B.VLEN, ''fm999,990'') AS VLEN';             --세로길
                TSQL := TSQL || ',RTRIM(TO_CHAR(A.WRK_ORDR_QTY, ''fm999,999,999,990.999''), ''.'') AS WRK_ORDR_QTY';     --생산 지시량
                TSQL := TSQL || ',RTRIM(TO_CHAR(A.PRFM_QTY + A.SALWEIGHT, ''fm999,999,999,990.999''), ''.'') AS TOT_WGT';          --재단 계획중량
                TSQL := TSQL || ',RTRIM(TO_CHAR(A.PRFM_QTY, ''fm999,999,999,990.999''), ''.'')  AS PCNT';	         --투입 실적연수
                TSQL := TSQL || ',RTRIM(TO_CHAR(A.SALWEIGHT, ''fm999,999,999,990.999''), ''.'') AS WGT';	             --폐품 중량
                TSQL := TSQL || ',B.MATNR_NM AS ORDER_DIV       --오더유형
                                   ,A.WRK_ORDR_SEQNO AS WRK_ORDR_SEQNO   --재단 작업지시번호 순번
                                   ,''상세보기'' AS DBTN             --상세보기
                                   ,A.ORDER_RMK        --작업지시사항
                                   ,A.MATNR            --재단 자재코드
                            FROM TB_LAMI_PC A
                            INNER JOIN TB_MAS001 B ON A.MATNR = B.MATNR AND A.WERKS = B.WERKS
                             WHERE 1 = 1';
                TSQL := TSQL || ' AND A.USE_YN = ''Y''';
                IF P_PCODE IS NOT NULL THEN
                    BEGIN
                        TSQL := TSQL || ' AND B.PCODE = ''' || P_PCODE || '''';
                    END;
                END IF;
                IF P_WLEN IS NOT NULL AND P_VLEN IS NOT NULL THEN
                    BEGIN
                        TSQL := TSQL || ' AND B.WLEN = ''' || P_WLEN || '''';
                        TSQL := TSQL || ' AND B.VLEN = ''' || P_VLEN || '''';
                    END;
                END IF;
                IF P_PRD_STR_DATE IS NOT NULL THEN
                    BEGIN
                        TSQL := TSQL || ' AND TO_CHAR(A.REGDATE,''YYYYMMDD'') >= ''' || P_PRD_STR_DATE || '''';
                    END;
                END IF;
                IF P_PRD_END_DATE IS NOT NULL THEN
                    BEGIN
                        TSQL := TSQL || ' AND TO_CHAR(A.REGDATE,''YYYYMMDD'') <= ''' || P_PRD_END_DATE || '''';
                    END;
                END IF;
                TSQL := TSQL || ' ORDER BY A.REGDATE ASC, A.WRK_ORDR_NO ASC,A.WRK_ORDR_SEQNO ASC';
            END;
            DBMS_OUTPUT.PUT_LINE(TSQL);
            BEGIN
                OPEN CUR_2 FOR TSQL;
            END;
        ELSIF P_PROC_CD = 'LS' THEN     -- PS 투입정보(ZA : 문재적재소)
            --grid 컬럼 정보 설정
            V_COLINFO := '선택@C^60|작업지시번호@C^200|오더번호@C^130|지종@H|지종명@H|평량@H|가로@H|세로@H|생산지시중량@R^100|총사용중량@R^120|실중량@R^120|폐품중량@H|오더유형@L^310|순번@H|상세보기@H|지시사항@H|자재코드@C^200';
            V_COLTYPE := 'CHK@Button|WRK_ORDR_NO@varchar|ORDER_NO@varchar|PCODE@varchar|PCODE_NM@varchar|BS_WGT@varchar|WLEN@varchar|VLEN@varchar|WRK_ORDR_QTY@varchar|TOT_WGT@varchar|PCNT@varchar|WGT@varchar|ORDER_DIV@varchar|WRK_ORDR_SEQNO@varchar|DBTN@Button|ORDER_RMK@varchar|MATNR@varchar';

            --컬럼설정 반환 테이블 작성
            OPEN CUR_1 FOR
            SELECT RTN_VALUES FROM FN_SPLIT(V_COLINFO||','||V_COLTYPE,',');

            BEGIN
                TSQL := TSQL || 'SELECT ';
                TSQL := TSQL || 'CHK';
                TSQL := TSQL || ',WRK_ORDR_NO';     --재단 작업지시번호
--                TSQL := TSQL || ',ORDER_GB';        --오더구분
                TSQL := TSQL || ',ORDER_NO         --오더번호
                                   ,PCODE            --지종
                                   ,PCODE_NM';         --지종명
                TSQL := TSQL || ',BS_WGT';           --평량
                TSQL := TSQL || ',WLEN';             --가로길
                TSQL := TSQL || ',VLEN';             --세로길
                TSQL := TSQL || ',WRK_ORDR_QTY';     --생산 지시량
                TSQL := TSQL || ',TOT_WGT';          --계획중량
                TSQL := TSQL || ',PCNT';	         --재단 실적연수
                TSQL := TSQL || ',WGT';	             --재단 중량
                TSQL := TSQL || ',ORDER_DIV       --오더유형
                                   ,WRK_ORDR_SEQNO   --재단 작업지시번호 순번
                                   ,DBTN             --상세보기
                                   ,ORDER_RMK        --작업지시사항
                                   ,MATNR            --재단 자재코드
                            FROM (';
                TSQL := TSQL || 'SELECT ';
                TSQL := TSQL || '''-'' AS CHK';
--                TSQL := TSQL || ',TO_CHAR(A.REGDATE,''YYYY-MM-DD HH24:MI'') AS INP_DT';     --투입일시
                TSQL := TSQL || ',A.WRK_ORDR_NO';        --재단 작업지시번호
                TSQL := TSQL || ',''라미네이팅 슬리팅'' AS ORDER_GB';        --오더구분
                TSQL := TSQL || ',A.ORDER_NO         --오더번호
                                   ,B.PCODE            --지종
                                   ,B.PCODE_NM';         --지종명
                TSQL := TSQL || ',TO_CHAR(B.BS_WGT, ''fm999,999,999,990'') AS BS_WGT';           --평량
                TSQL := TSQL || ',TO_CHAR(B.WLEN, ''fm999,990'') AS WLEN';             --가로길
                TSQL := TSQL || ',TO_CHAR(B.VLEN, ''fm999,990'') AS VLEN';             --세로길
                TSQL := TSQL || ',RTRIM(TO_CHAR(A.WRK_ORDR_QTY, ''fm999,999,999,990.999''), ''.'') AS WRK_ORDR_QTY';     --생산 지시량
                TSQL := TSQL || ',RTRIM(TO_CHAR(A.PRFM_QTY + A.SALWEIGHT, ''fm999,999,999,990.999''), ''.'') AS TOT_WGT';          --총사용중량
                TSQL := TSQL || ',RTRIM(TO_CHAR(A.PRFM_QTY, ''fm999,999,999,990.999''), ''.'')  AS PCNT';	         --실중량
                TSQL := TSQL || ',RTRIM(TO_CHAR(A.SALWEIGHT, ''fm999,999,999,990.999''), ''.'') AS WGT';	             --폐품 중량
                TSQL := TSQL || ',B.MATNR_NM AS ORDER_DIV       --오더유형
                                   ,A.WRK_ORDR_SEQNO AS WRK_ORDR_SEQNO   --재단 작업지시번호 순번
                                   ,''상세보기'' AS DBTN             --상세보기
                                   ,A.ORDER_RMK        --작업지시사항
                                   ,A.MATNR            --재단 자재코드
                            FROM TB_LAMI_SL A
                            INNER JOIN TB_MAS001 B ON A.MATNR = B.MATNR AND A.WERKS = B.WERKS
                             WHERE 1 = 1
                             AND NVL(A.COMP_YN,''N'') IN (''N'',''I'')';
                TSQL := TSQL || ' AND A.USE_YN = ''Y''';
                IF P_PCODE IS NOT NULL THEN
                    BEGIN
                        TSQL := TSQL || ' AND B.PCODE = ''' || P_PCODE || '''';
                    END;
                END IF;
                IF P_WLEN IS NOT NULL AND P_VLEN IS NOT NULL THEN
                    BEGIN
                        TSQL := TSQL || ' AND B.WLEN = ''' || P_WLEN || '''';
                        TSQL := TSQL || ' AND B.VLEN = ''' || P_VLEN || '''';
                    END;
                END IF;
                IF P_PRD_STR_DATE IS NOT NULL THEN
                    BEGIN
                        TSQL := TSQL || ' AND TO_CHAR(A.REGDATE,''YYYYMMDD'') >= ''' || P_PRD_STR_DATE || '''';
                    END;
                END IF;
                IF P_PRD_END_DATE IS NOT NULL THEN
                    BEGIN
                        TSQL := TSQL || ' AND TO_CHAR(A.REGDATE,''YYYYMMDD'') <= ''' || P_PRD_END_DATE || '''';
                    END;
                END IF;

                TSQL := TSQL || ') A 
	                ORDER BY WRK_ORDR_NO ASC,WRK_ORDR_SEQNO ASC';
            END;
            DBMS_OUTPUT.PUT_LINE(TSQL);
            BEGIN
                OPEN CUR_2 FOR TSQL;
            END;


        END IF;

        --작업 정상 종료 코드 등록
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
END SP_POP_LAMI_P01;
/
