
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP00_S02" (
    P_CBOTYPE IN VARCHAR2
    , P_FILTER IN VARCHAR2
    , P_COLINFO OUT VARCHAR2
    , P_COLTYPE OUT VARCHAR2
    , Lang IN VARCHAR2 DEFAULT 'KO'
    , RS_CODE OUT VARCHAR2
    , RS_MSG OUT VARCHAR2
    , CUR_1 OUT SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : POP_Combo
 * PROGRAM NAME  : 콤보박스 팝업
 * VERSION       : 1.0.0
 * DESCRIPTION   : 지정된 항목의 콤보박스 목록을 조회한다.
 *
 * AUTHOR NAME   : 김기연
 * CREATE DATE   : 2022/04/28
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description
 * ------------ ------- ------------- ------------------------------------------
 * 2022/04/28    1.0.0   김기연         Initial Version
 *==============================================================================
 *  관련 테이블
 * - [TB_MAS027] : (.R..) 근무시간 관리
 * - [CMCDV] : (.R..) 공통코드 세부항목 관리
 *=============================================================================*/
AS
    --프로그램 ID
    V_PRG_NM       VARCHAR2(100) := 'SP_POP00_S02'; -- PROCEDURE NAME
    V_PLT_CD       varchar2(2)   := '99'; --PLANTCODE TEST
    V_SESS_USER_ID varchar2(20)  := 'TEST'; --USERID
-- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER EXCEPTION;
    E_SQL_ERR_CD  NUMBER(5)    := 0;
    E_SQL_ERR_MSG VARCHAR2(4000);
    --parameter변수 처리
    V_CBOTYPE     VARCHAR2(10) := P_CBOTYPE;

BEGIN
    --예외처리 시작(try)
    BEGIN
        BEGIN

            P_COLINFO := '항목코드@H|항목명@H|조회결과@C^350|시작시간@H|종료시간@H';
            P_COLTYPE := 'ItemCode@varchar|ItemName@varchar|Display@varchar|STR_TM@varchar|END_TM@varchar';
            --근무시간 목록 조회
            IF V_CBOTYPE = 'WORKTIME' THEN
                --결과 테이블 반환용 변수
                OPEN CUR_1 FOR
                    --합지기 지시목록 조회
                    SELECT M027.WRK_METH                                                               AS ItemCode
                         , C001.CDESC1                                                                 AS ItemName
--                 , '[' || C001.CDESC1 || '] ' || M027.STR_TM || ' ~ ' || M027.END_TM AS Display
                         , REGEXP_REPLACE(M027.STR_TM, '(^.{2})', '\1:') || ' ~ ' ||
                           REGEXP_REPLACE(M027.END_TM, '(^.{2})', '\1:') || ' [' || C001.CDESC1 || ']' AS Display
                         , M027.STR_TM                                                                 AS STR_TM
                         , M027.END_TM                                                                 AS END_TM
                    FROM TB_MAS027 M027,
                         CMCDV C001,
                         TB_MAS012 M012
                    WHERE 1 = 1
                      AND M027.WRK_METH = C001.CMCDVL(+)
                      AND M027.MACH_CD = M012.MACH_CD(+)
                      AND C001.CMCDKY = 'WRKMETH'
                      AND M012.MACH_CD LIKE P_FILTER || '%'
                    ORDER BY M027.WRK_METH; --M027.STR_TM;
            --저장위치 목록조회
            ELSIF V_CBOTYPE = 'STORLOC' THEN
                --결과 테이블 반환용 변수
                OPEN CUR_1 FOR
                    SELECT STOR_LOC_CD                               AS ItemCode
                         , STOR_LOC_NM                               AS ItemName
                         , '[' || STOR_LOC_CD || '] ' || STOR_LOC_NM AS Display
                    FROM TB_MAS003
                    WHERE 1 = 1
                      AND WERKS LIKE P_FILTER || '%'
                      AND STOR_LOC_CD LIKE '2%'
                      AND STOR_LOC_CD NOT IN ('2010', '2020');
                -- 라미네이팅 원부재 마스터 조회
            ELSIF V_CBOTYPE = 'LAMI' THEN
                OPEN CUR_1 FOR
                    SELECT MATNR    AS ItemCode,
                           MATNR_NM AS ItemName
                    FROM TB_MAS001
                    WHERE WERKS = P_FILTER
                      AND MATNR LIKE '3B00%'
                    ORDER BY MATNR;
                --재고상태조회
            ELSIF V_CBOTYPE = 'STCKSTA' THEN
                --결과 테이블 반환용 변수
                OPEN CUR_1 FOR
                    SELECT ''         AS ItemCode
                         , 'ALL'      AS ItemName
                         , '[ALL] 전체' AS Display
                    FROM DUAL
                    UNION
                    SELECT CMCDVL                          AS ItemCode
                         , CDESC1                          AS ItemName
                         , '[' || CMCDVL || '] ' || CDESC1 AS Display
                    FROM CMCDV
                    WHERE 1 = 1
                      AND CMCDKY = 'STCK_STA'
                      AND CMCDVL IN (SELECT RTN_VALUES FROM FN_SPLIT(P_FILTER, ','))
                    ORDER BY ItemCode;
            -- 가공 재고 자재코드 조회
            ELSIF V_CBOTYPE = 'MATNRTRA' THEN
                --결과 테이블 반환용 변수
                OPEN CUR_1 FOR
                    SELECT ''             AS ItemCode
                         , 'ALL'          AS ItemName
                         , '[ALL] 전체'   AS Display
                    FROM DUAL
                    UNION
                    SELECT MATNR                            AS ItemCode
                         , MATNR_NM                         AS ItemName
                         , '[' || MATNR || '] ' || MATNR_NM AS Display
                    FROM TB_MAS001
                    WHERE  1=1
                        AND WERKS = 'P200'
                        AND MATNR_DIV = 'HALB'
                        AND USE_YN = 'Y'
                        AND MATNR_STA IS NULL
                        AND PROD_GRP_CD = '20'
                        AND MATNR NOT LIKE '%W'
                        AND MATNR NOT LIKE '%M'
                    ORDER BY ItemCode DESC;
                --기타 공통코드 목록
            ELSE
                --결과 테이블 반환용 변수
                OPEN CUR_1 FOR
                    SELECT ''    AS ItemCode
                         , 'ALL' AS ItemName
                         , 'ALL' AS Display
                    FROM DUAL
                    UNION
                    SELECT CMCDVL AS ItemCode
                         , CDESC1 AS ItemName
                         , CDESC1 AS Display
                    FROM CMCDV
                    WHERE 1 = 1
                      AND CMCDKY = P_FILTER;
            END IF;
            --작업 정상 종료 코드 등록
            RS_CODE := 'S';
        END;
        --예외처리(catch)
    EXCEPTION
        WHEN E_EXCEPTION_USER THEN
            -- 에러 내역 SET
            E_SQL_ERR_CD := SQLCODE;
            E_SQL_ERR_MSG := SUBSTRB(SQLERRM, 1, 300);

            ROLLBACK;
            SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);

            RS_CODE := 'E';
            RS_MSG := SQLERRM;
            RETURN;
        WHEN OTHERS THEN
            E_SQL_ERR_CD := SQLCODE;
            E_SQL_ERR_MSG := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM, 1, 500) || ']';

            ROLLBACK;
            RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);

            RS_CODE := 'E';
            RS_MSG := SQLERRM;
            RETURN;
        --예외처리 종료
    END;
END SP_POP00_S02;
/
