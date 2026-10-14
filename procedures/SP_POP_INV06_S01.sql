
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_INV06_S01" 
(
    P_WERKS         IN VARCHAR2 
    ,P_MACH_CD      IN VARCHAR2
    ,P_PRD_STR_DT   IN VARCHAR2
    ,P_PRD_END_DT   IN VARCHAR2
    ,P_MATNR        IN VARCHAR2
    ,P_USERID       IN VARCHAR2
    ,Lang           IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE        OUT VARCHAR2 
    ,RS_MSG         OUT VARCHAR2
    ,CUR_1          OUT SYS_REFCURSOR
    ,CUR_2          OUT SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : POP_INV06
 * PROGRAM NAME  : 자재반납 이력조회
 * VERSION       : 1.0.0
 * DESCRIPTION   : 자재반납 이력 목록을 조회한다.
 *                 
 * AUTHOR NAME   : 김기연
 * CREATE DATE   : 2022/05/14
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/05/14    1.0.0   김기연         Initial Version
 *==============================================================================
 *  관련 테이블
 * - [TB_WRK003] : (.R..) 비가동 실적
 * - [TB_MAS020] : (.R..) 비가동 항목정보
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM        VARCHAR2(100)  := 'SP_POP_INV06_S01';     -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID   varchar2(20) := P_USERID; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);
    --파라미터 처리
    V_PRD_STR_DT DATE := TO_DATE(P_PRD_STR_DT,'YYYYMMDD');
    V_PRD_END_DT DATE := TO_DATE(P_PRD_END_DT,'YYYYMMDD') + INTERVAL '1' DAY; --시간정보 누락으로 인한 보정
    --내부변수 관리
    V_COLINFO VARCHAR2(1000);
    V_COLTYPE VARCHAR2(1000);

BEGIN
    --예외처리 시작(try)
    BEGIN
        --컬럼설정
        V_COLINFO := '순번@R^60|문서번호@C^220|자재순번@R^80|자재코드@C^160|자재명@L^460|반납수량@R^100|단위@C^60|진행상태@C^80';
        V_COLTYPE := 'SEQ@varchar|DOC_NO@varchar|DOC_SEQ@varchar|MATNR@varchar|MATNR_NM@varchar|RTN_QTY@varchar|UNIT@varchar|IF_STA@varchar';
        --컬럼설정 반환 테이블 작성
        OPEN CUR_1 FOR
        SELECT RTN_VALUES FROM FN_SPLIT(V_COLINFO||','||V_COLTYPE,',');

        --결과 테이블 반환용 변수
        OPEN CUR_2 FOR
        --자재 불출요청 목록 조회
        SELECT ROW_NUMBER() OVER (ORDER BY I002.DOC_NO, I002.DOC_SEQ) AS SEQ --순번
             , I002.DOC_NO              --불출요청 문서
             , I002.DOC_SEQ             --불출요청 문서별 순번
             , M001.MATNR               --자재코드
             , M001.MATNR_NM            --자재명
             , RTRIM(TO_CHAR(I002.QTY, 'FM999,999,990.999'),'.') AS RTN_QTY      --요청수량
             , I002.UNIT                --단위
             , CASE WHEN NVL(I002.IF_STA,'N') = 'N' 
                    THEN '요청' 
                    ELSE '완료' END AS IF_STA --IF 상태
        FROM TB_INV002 I002,            --불출요청
             TB_MAS001 M001             --자재정보
        WHERE 1=1
        AND I002.WERKS = M001.WERKS(+)
        AND I002.MATNR = M001.MATNR(+)
        AND I002.WERKS = P_WERKS
        AND I002.REQ_DIV = '20'
        AND I002.DLFL != 'D'
        AND I002.REGDATE BETWEEN V_PRD_STR_DT AND V_PRD_END_DT
        AND M001.MATNR LIKE P_MATNR || '%'
        ORDER BY I002.DOC_NO, I002.DOC_SEQ;

        --작업 정상 종료 코드 등록
        RS_CODE := 'S';
    --예외처리(catch)
    EXCEPTION
    WHEN E_EXCEPTION_USER THEN
        -- 에러 내역 SET
        E_SQL_ERR_CD        := -20000;
        E_SQL_ERR_MSG       := SQLCODE || ': EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

        ROLLBACK;
        SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);

        RS_CODE := 'E';
        RS_MSG  := SQLERRM;
        RETURN;
    WHEN OTHERS THEN
        E_SQL_ERR_CD        := -20000;
        E_SQL_ERR_MSG       := SQLCODE || ': EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

        ROLLBACK;
        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);

        RS_CODE := 'E';
        RS_MSG  := SQLERRM;
        RETURN;
    --예외처리 종료
    END;
END SP_POP_INV06_S01;
/
