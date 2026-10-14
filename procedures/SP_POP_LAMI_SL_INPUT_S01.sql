
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_LAMI_SL_INPUT_S01" SP_POP_LAMI_SL_INPUT_S01
(
     P_WERKS    IN  VARCHAR2             -- 플랜트 코드
    ,P_PROC_CD  IN  VARCHAR2             -- 공정코드 (JA, MA, CA, PB_PC ...)
    ,P_PRFM_DT  IN  VARCHAR2             -- 생산실적일자
    ,P_ORDER_NO IN  VARCHAR2             
    ,P_IND_BCD  IN  VARCHAR2  
    ,P_PCODE    IN  VARCHAR2
    ,P_BS_WGT   IN  VARCHAR2 
    ,P_WRK_ORDR_NO IN  VARCHAR2             
    ,P_COLINFO  OUT TB_LAMI_PC_IFR015.AUFNR%TYPE        -- grid 칼럼명
    ,P_COLTYPE  OUT TB_LAMI_PC_IFR015.AUFNR%TYPE        -- grid 칼럼 데이터 타입
--    ,P_COLINFO  OUT VARCHAR2        -- grid 칼럼명
--    ,P_COLTYPE  OUT VARCHAR2        -- grid 칼럼 데이터 타입
    ,Lang       IN  VARCHAR2 DEFAULT 'KO'
    ,RS_CODE    OUT VARCHAR2 
    ,RS_MSG     OUT VARCHAR2 
    ,CUR_1      OUT SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : SP_POP_LAMI_CANCEL_S01
 * PROGRAM NAME  : 생산실적 이력 조회
 * VERSION       : 1.0.1
 * DESCRIPTION   : 자재투입 이력 조회
 *                 
 * AUTHOR NAME   : 김수현
 * CREATE DATE   : 2022/12/09
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/12/09    1.0.0   김수현         Initial Version
 *==============================================================================
 *  관련 테이블
 * - [TB_LAMI_PC] : (.R..) 라미네이팅 생산실적 이력
 * - [TB_LAMI_SL] : (.R..) 슬리팅 생산실적 이력
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM        VARCHAR2(100)  := 'SP_POP_LAMI_CANCEL_S01';     -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID   varchar2(20) := 'TEST'; --USERID
    TSQL VARCHAR2(4000) := '';
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);
    --내부변수 관리
BEGIN
    --예외처리 시작(try)
    BEGIN
        BEGIN
--        IF P_PROC_CD = 'LP' THEN     -- PS 투입정보(ZA : 문재적재소)
--            --grid 컬럼 정보 설정
----            P_COLINFO := '선택@C^60|투입일시@C^170|오더구분@C^120|오더번호@C^130|지종@C^70|지종명@H|평량@R^80|가로@R^80|세로@R^80|생산지시중량@R^100|계획중량@R^120|오더중량@R^100|투입중량@R^120|오더유형@C^80|작업지시번호@C^200|순번@C^50|상세보기@C^100|지시사항@H|자재코드@C^200';
--            P_COLINFO := '선택@C^60|생산일시@C^170|투입일시@C^170|오더구분@C^180|오더번호@C^130|지종@H|지종명@H|평량@H|가로@H|세로@H|생산지시중량@R^120|총사용중량@R^120|실중량@R^120|폐품중량@R^120|오더유형@C^80|작업지시번호@C^200|순번@C^50|상세보기@H|지시사항@H|자재코드@C^200|실적문서번호@H|실적폐품문서번호@H|폐품문서번호@H|바코드@H|LOTNO@H|REMARK@H';
--            P_COLTYPE := 'CHK@Button|PRD_DT@varchar|INP_DT@varchar|ORDER_GB@varchar|ORDER_NO@varchar|PCODE@varchar|PCODE_NM@varchar|BS_WGT@varchar|WLEN@varchar|VLEN@varchar|WRK_ORDR_QTY@varchar|TOT_WGT@varchar|PCNT@varchar|WGT@varchar|ORDER_DIV@varchar|WRK_ORDR_NO@varchar|WRK_ORDR_SEQNO@varchar|DBTN@Button|ORDER_RMK@varchar|MATNR@varchar|SDOC_NO@varchar|MDOCNO@varchar|DOC_NO@varchar|IND_BCD@varchar|LOT_NO@varchar|RMK@varchar';
--
--            BEGIN
--                TSQL := TSQL || 'SELECT ';
--                TSQL := TSQL || '''-'' AS CHK';
--                --TSQL := TSQL || 'PRD_DT';
--                TSQL := TSQL || ' ,TO_CHAR(TO_DATE(SUBSTR(A.PRD_END_DTM,1,12),''YYYYMMDDHH24MI''),''YYYY-MM-DD HH24:MI'')   AS PRD_DT';       --생산일시
--                TSQL := TSQL || ' ,TO_CHAR(A.REGDATE, ''YYYY-MM-DD HH24:MI'') AS INP_DT';     --투입일시
--                TSQL := TSQL || ' ,''라미네이팅 인쇄코팅'' AS ORDER_GB';        --오더구분
--                TSQL := TSQL || ' ,A.ORDER_NO         --오더번호
--                                   ,B.PCODE            --지종
--                                   ,B.PCODE_NM';         --지종명
--                TSQL := TSQL || ' ,TO_CHAR(B.BS_WGT, ''fm999,999,999,990'') AS BS_WGT';           --평량
--                TSQL := TSQL || ' ,TO_CHAR(B.WLEN, ''fm999,990'') AS WLEN';             --가로길
--                TSQL := TSQL || ' ,TO_CHAR(B.VLEN, ''fm999,990'') AS VLEN';             --세로길
--                TSQL := TSQL || ' ,RTRIM(TO_CHAR(A.WRK_ORDR_QTY, ''fm999,999,999,990.999''), ''.'') AS WRK_ORDR_QTY';     --생산 지시량
--                TSQL := TSQL || ' ,RTRIM(TO_CHAR(A.PRFM_QTY + A.SALWEIGHT, ''fm999,999,999,990.999''), ''.'') AS TOT_WGT';          --재단 계획중량
--                TSQL := TSQL || ' ,RTRIM(TO_CHAR(A.PRFM_QTY, ''fm999,999,999,990.999''), ''.'')  AS PCNT';	         --투입 실적연수
--                TSQL := TSQL || ' ,RTRIM(TO_CHAR(A.SALWEIGHT, ''fm999,999,999,990.999''), ''.'') AS WGT';	             --폐품 중량
--                TSQL := TSQL || ' ,A.ORDER_DIV       --오더유형
--                                   ,A.WRK_ORDR_NO      --작업지시번호
--                                   ,A.WRK_ORDR_SEQNO AS WRK_ORDR_SEQNO   --작업지시번호 순번
--                                   ,''상세보기'' AS DBTN             --상세보기
--                                   ,A.ORDER_RMK AS ORDER_RMK        --작업지시사항
--                                   ,A.MATNR            --자재코드
--                                   ,A.DOC_NO AS SDOC_NO            --실적문서번호
--                                   ,D.MDOCNO AS MDOCNO            --실적폐품문서번호
--                                   ,E.DOC_NO AS DOC_NO            --폐품문서번호
--                                   ,A.IND_BCD             --바코드
--                                   ,A.LOT_BUF AS LOT_NO             --LOTNO
--                                   ,C.RMK
--                            FROM TB_LAMI_PC A
--                            INNER JOIN TB_MAS001 B ON A.MATNR = B.MATNR AND A.WERKS = B.WERKS
--                            INNER JOIN TB_WRK002 C ON A.WRK_ORDR_NO = C.WRK_ORDR_NO AND A.WRK_ORDR_SEQNO = C.WRK_ORDR_SEQNO AND A.WERKS = C.WERKS AND A.ORDER_NO = C.ORDER_NO AND A.MACH_CD = C.MACH_CD
--                            LEFT JOIN TB_LAMI_PC_IFS001 D ON A.ORDER_NO = D.AUFNR AND A.DOC_NO <> D.MDOCNO
--                            LEFT JOIN TB_WRK004 E ON A.WRK_ORDR_NO = E.WRK_ORDR_NO AND A.ORDER_NO = E.ORDER_NO
--                             WHERE 1 = 1';
--                TSQL := TSQL || ' AND A.USE_YN = ''N'' AND A.COMP_YN = ''Y''';
--                IF P_PCODE IS NOT NULL THEN
--                    BEGIN
--                        TSQL := TSQL || ' AND B.PCODE = ''' || P_PCODE || '''';
--                    END;
--                END IF;
--                IF P_BS_WGT IS NOT NULL THEN
--                    BEGIN
--                        TSQL := TSQL || ' AND B.BS_WGT = ' || P_BS_WGT;
--                    END;
--                END IF;
--                IF P_PRFM_DT IS NOT NULL THEN
--                    BEGIN
--                        TSQL := TSQL || ' AND ''' || P_PRFM_DT || ''' BETWEEN SUBSTR(A.PRD_STR_DTM,1,8) AND SUBSTR(A.PRD_END_DTM,1,8) ';
--                    END;
--                END IF;
--                IF P_IND_BCD IS NOT NULL THEN
--                    BEGIN
--                        TSQL := TSQL || ' AND A.IND_BCD = ''' || P_IND_BCD || '''';
--                    END;
--                END IF;
--                TSQL := TSQL || ' ORDER BY A.REGDATE ASC, A.WRK_ORDR_NO ASC,A.WRK_ORDR_SEQNO ASC';
--            END;
----            DBMS_OUTPUT.PUT_LINE(TSQL);
--            BEGIN
--                OPEN CUR_1 FOR TSQL;
--            END;
--        ELSIF P_PROC_CD = 'LS' THEN     -- PS 투입정보(ZA : 문재적재소)
--            --grid 컬럼 정보 설정
----            P_COLINFO := '선택@C^60|투입일시@C^170|오더구분@C^120|오더번호@C^130|지종@C^70|지종명@H|평량@R^80|가로@R^80|세로@R^80|생산지시중량@R^100|계획중량@R^120|오더중량@R^100|투입중량@R^120|오더유형@C^80|작업지시번호@C^200|순번@C^50|상세보기@C^100|지시사항@H|자재코드@C^200';
--            P_COLINFO := '선택@C^60|생산일시@C^170|투입일시@C^170|오더구분@C^180|오더번호@C^130|지종@H|지종명@H|평량@H|가로@H|세로@H|생산지시중량@R^100|총사용중량@R^120|실중량@R^120|폐품중량@R^120|오더유형@C^80|작업지시번호@C^200|순번@C^50|상세보기@H|지시사항@H|자재코드@C^200|문서번호@H|REMARK@H|바코드@H|LOTNO@H';
--            P_COLTYPE := 'CHK@Button|PRD_DT@varchar|INP_DT@varchar|ORDER_GB@varchar|ORDER_NO@varchar|PCODE@varchar|PCODE_NM@varchar|BS_WGT@varchar|WLEN@varchar|VLEN@varchar|WRK_ORDR_QTY@varchar|TOT_WGT@varchar|PCNT@varchar|WGT@varchar|ORDER_DIV@varchar|WRK_ORDR_NO@varchar|WRK_ORDR_SEQNO@varchar|DBTN@Button|ORDER_RMK@varchar|MATNR@varchar|SDOC_NO@varchar|RMK@varchar|IND_BCD@varchar|LOT_BUF@varchar';
--
--            BEGIN
--                TSQL := TSQL || 'SELECT ';
--                TSQL := TSQL || 'CHK,';
--                TSQL := TSQL || 'PRD_DT';
--                TSQL := TSQL || ',INP_DT';     --투입일시
--                TSQL := TSQL || ',ORDER_GB';        --오더구분
--                TSQL := TSQL || ',ORDER_NO         --오더번호
--                                   ,PCODE            --지종
--                                   ,PCODE_NM';         --지종명
--                TSQL := TSQL || ',BS_WGT';           --평량
--                TSQL := TSQL || ',WLEN';             --가로길
--                TSQL := TSQL || ',VLEN';             --세로길
--                TSQL := TSQL || ',WRK_ORDR_QTY';     --생산 지시량
--                TSQL := TSQL || ',TOT_WGT';          --계획중량
--                TSQL := TSQL || ',PCNT';	         --재단 실적연수
--                TSQL := TSQL || ',WGT';	             --재단 중량
--                TSQL := TSQL || ',ORDER_DIV       --오더유형
--                                   ,WRK_ORDR_NO      --재단 작업지시번호
--                                   ,WRK_ORDR_SEQNO   --재단 작업지시번호 순번
--                                   ,DBTN             --상세보기
--                                   ,ORDER_RMK        --작업지시사항
--                                   ,MATNR            --재단 자재코드
--                                   ,RMK
--                                   ,SDOC_NO
--                                   ,IDOC_NO
--                                   ,DOC_NO
--                                   ,IND_BCD
--                                   ,LOT_BUF AS LOT_NO
--                            FROM (';
--                TSQL := TSQL || 'SELECT ';
--                TSQL := TSQL || '''-'' AS CHK';
--                TSQL := TSQL || ',TO_CHAR(A.REGDATE, ''YYYY-MM-DD HH24:MI'') AS INP_DT';     --투입일시
--                TSQL := TSQL || ',''라미네이팅 슬리팅'' AS ORDER_GB';        --오더구분
--                TSQL := TSQL || ',A.ORDER_NO         --오더번호
--                                   ,B.PCODE            --지종
--                                   ,B.PCODE_NM';         --지종명
--                TSQL := TSQL || ',TO_CHAR(B.BS_WGT, ''fm999,999,999,990'') AS BS_WGT';           --평량
--                TSQL := TSQL || ',TO_CHAR(B.WLEN, ''fm999,990'') AS WLEN';             --가로길
--                TSQL := TSQL || ',TO_CHAR(B.VLEN, ''fm999,990'') AS VLEN';             --세로길
--                TSQL := TSQL || ',RTRIM(TO_CHAR(A.WRK_ORDR_QTY, ''fm999,999,999,990.999''), ''.'') AS WRK_ORDR_QTY';     --생산 지시량
--                TSQL := TSQL || ',RTRIM(TO_CHAR(A.PRFM_QTY + A.SALWEIGHT, ''fm999,999,999,990.999''), ''.'') AS TOT_WGT';          --총사용중량
--                TSQL := TSQL || ',RTRIM(TO_CHAR(A.PRFM_QTY, ''fm999,999,999,990.999''), ''.'')  AS PCNT';	         --실중량
--                TSQL := TSQL || ',RTRIM(TO_CHAR(A.SALWEIGHT, ''fm999,999,999,990.999''), ''.'') AS WGT';	             --폐품 중량
--                TSQL := TSQL || ',A.ORDER_DIV       --오더유형
--                                   ,A.WRK_ORDR_NO      --재단 작업지시번호
--                                   ,A.WRK_ORDR_SEQNO AS WRK_ORDR_SEQNO   --재단 작업지시번호 순번
--                                   ,''상세보기'' AS DBTN             --상세보기
--                                   ,A.ORDER_RMK        --작업지시사항
--                                   ,A.MATNR            --재단 자재코드
--                                   ,C.RMK
--                                   ,A.DOC_NO AS SDOC_NO            --실적문서번호
--                                   ,D.MDOCNO AS IDOC_NO            --투입문서번호
--                                   ,E.DOC_NO AS DOC_NO            --폐품문서번호
--                                   ,A.IND_BCD
--                                   ,A.LOT_BUF
--                                   ,TO_CHAR(TO_DATE(SUBSTR(A.PRD_END_DTM,1,12),''YYYYMMDDHH24MI''),''YYYY-MM-DD HH24:MI'')   AS PRD_DT       --생산일시
--                            FROM TB_LAMI_SL A
--                            INNER JOIN TB_MAS001 B ON A.MATNR = B.MATNR AND A.WERKS = B.WERKS
--                            INNER JOIN TB_WRK002 C ON A.WRK_ORDR_NO = C.WRK_ORDR_NO AND A.WRK_ORDR_SEQNO = C.WRK_ORDR_SEQNO AND A.WERKS = C.WERKS AND A.ORDER_NO = C.ORDER_NO AND A.MACH_CD = C.MACH_CD
--                            LEFT JOIN TB_IFS008 D ON A.ORDER_NO = D.AUFNR
--                            LEFT JOIN TB_WRK004 E ON A.WRK_ORDR_NO = E.WRK_ORDR_NO AND A.ORDER_NO = E.ORDER_NO
--                             WHERE 1 = 1
--                             AND A.COMP_YN = ''Y''';
--                TSQL := TSQL || ' AND A.USE_YN = ''N''';
--                IF P_PCODE IS NOT NULL THEN
--                    BEGIN
--                        TSQL := TSQL || ' AND B.PCODE = ''' || P_PCODE || '''';
--                    END;
--                END IF;
--                IF P_BS_WGT IS NOT NULL AND P_BS_WGT IS NOT NULL THEN
--                    BEGIN
--                        TSQL := TSQL || ' AND B.BS_WGT = ' || P_BS_WGT;
--                    END;
--                END IF;
--                IF P_PRFM_DT IS NOT NULL THEN
--                    BEGIN
--                        TSQL := TSQL || ' AND ''' || P_PRFM_DT || ''' BETWEEN SUBSTR(A.PRD_STR_DTM,1,8) AND SUBSTR(A.PRD_END_DTM,1,8) ';
--                    END;
--                END IF;
--                IF P_IND_BCD IS NOT NULL THEN
--                    BEGIN
--                        TSQL := TSQL || ' AND A.IND_BCD = ''' || P_IND_BCD || '''';
--                    END;
--                END IF;
--
--                TSQL := TSQL || ') A 
--                ORDER BY INP_DT ASC, WRK_ORDR_NO ASC,WRK_ORDR_SEQNO ASC';
--            END;
----            DBMS_OUTPUT.PUT_LINE(TSQL);
--            BEGIN
--                OPEN CUR_1 FOR TSQL;
--            END;
--        ELSIF P_PROC_CD = 'LS1_CLN_LIST' THEN     -- PS 투입정보(ZA : 문재적재소)
            --grid 컬럼 정보 설정
--            P_COLINFO := '선택@C^60|투입일시@C^170|오더구분@C^120|오더번호@C^130|지종@C^70|지종명@H|평량@R^80|가로@R^80|세로@R^80|생산지시중량@R^100|계획중량@R^120|오더중량@R^100|투입중량@R^120|오더유형@C^80|작업지시번호@C^200|순번@C^50|상세보기@C^100|지시사항@H|자재코드@C^200';
            P_COLINFO := '선택@C^60|투입일시@C^170|투입량@R^100|작업지시번호@C^180|오더번호@C^130|자재번호@C^180|바코드@C^130';
            P_COLTYPE := 'CHK@Button|INP_DT@varchar|IN_QTY@varchar|WRK_ORDR_NO@varchar|ORDER_NO@varchar|MATNR@varchar|IND_BCD@varchar';

            BEGIN
                TSQL := TSQL || 'SELECT ';
                TSQL := TSQL || 'CHK,';
                TSQL := TSQL || ',INP_DT';     --투입일시
                TSQL := TSQL || ',WRK_ORDR_NO';        --오더구분
                TSQL := TSQL || ',ORDER_NO';         --오더번호
                TSQL := TSQL || ',MATNR';         --자재번호
                TSQL := TSQL || ',IND_BCD';         --바코드번호
                TSQL := TSQL || ',IN_QTY';           --투입량
                TSQL := TSQL || ' FROM TB_INV003';
                TSQL := TSQL || ' WHERE 1 = 1';
                TSQL := TSQL || ' AND WRK_ORDR_NO = ''' || P_WRK_ORDR_NO || '''';
                TSQL := TSQL || ' AND WRK_ORDR_SEQNO = 1';
            END;
--            DBMS_OUTPUT.PUT_LINE(TSQL);
            BEGIN
                OPEN CUR_1 FOR TSQL;
            END;
--        END IF;

            --작업 정상 종료 코드 등록
            RS_CODE := 'S';
        END;
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
END ;
/
