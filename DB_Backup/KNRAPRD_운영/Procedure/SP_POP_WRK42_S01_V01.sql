--------------------------------------------------------
--  DDL for Procedure SP_POP_WRK42_S01_V01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK42_S01_V01" 
(
    P_WERKS         IN VARCHAR2     -- 플랜트코드
    ,P_MACH_CD      IN VARCHAR2     -- 설비코드 (PMA01, PCA01 ...)
    ,P_STR_DATE     IN VARCHAR2     -- 조회 시작일 
    ,P_END_DATE     IN VARCHAR2     -- 조회 종료일
    ,P_ORDER_NO     IN VARCHAR2             
    ,P_IND_BCD      IN VARCHAR2  
    ,P_PCODE        IN VARCHAR2
    ,P_BS_WGT       IN VARCHAR2 
    ,P_WLEN         IN VARCHAR2
    ,P_VLEN         IN VARCHAR2
    ,Lang           IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE        OUT VARCHAR2 
    ,RS_MSG         OUT VARCHAR2
    ,CUR_1          OUT SYS_REFCURSOR
    ,CUR_2          OUT SYS_REFCURSOR
)
-- *****************************************************************************
-- ****************************** 문제점 ****************************************
-- *****************************************************************************
-- 현재 설비코드에 공정투입된 모든 반제품이 보임.
-- INV003 테이블에 상태 칼럼을 추가여 투입후 상태변경이 없는것들만 공정투입취소 가능하도록 수정필요
/*==============================================================================
 * PROGRAM ID    : POP_WRK42
 * PROGRAM NAME  : 공정투입 이력조회
 * VERSION       : 1.0.0
 * DESCRIPTION   : 공정투입 이력 목록을 조회한다.
 *                 
 * AUTHOR NAME   : 김병무
 * CREATE DATE   : 2022/06/03
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/05/04    1.0.0   김병무         Initial Version
 *==============================================================================
 *  관련 테이블
 * - [TB_INV003] : (.R..) 자재투입
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM        VARCHAR2(100)  := 'SP_POP_WRK42_S01';     -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID   varchar2(20) := 'TEST'; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);
    --파라미터 처리
    --내부변수 관리
    V_COLINFO VARCHAR2(1000);
    V_COLTYPE VARCHAR2(1000);

BEGIN
    --예외처리 시작(try)
    BEGIN
        --컬럼설정
        V_COLINFO := '선택@H|투입일시@C^180|오더번호@C^120|개별 바코드@C^180|자재코드@C^230|투입량@R^120|사용량@R^120|재고량@H|단위@C^80|중량@H|상세보기@C^100|작업지시번호@H|작업지시순번@H';
        V_COLTYPE := 'CHK@Button|INP_DT@varchar|ORDER_NO@varchar|IND_BCD@varchar|MATNR@varchar|IN_QTY@varchar|USE_QTY@varchar|STCK_QTY@varchar|UNIT@varchar|WGT@varchar|DBTN@Button|WRK_ORDR_NO@varchar|WRK_ORDR_SEQNO@varchar';
        --컬럼설정 반환 테이블 작성
        OPEN CUR_1 FOR
        SELECT RTN_VALUES FROM FN_SPLIT(V_COLINFO||','||V_COLTYPE,',');

        --결과 테이블 반환용 변수
        OPEN CUR_2 FOR
        --공정투입 이력 조회
        SELECT '-' AS CHK                   --선택
            , TO_CHAR(I003.REGDATE, 'YYYY-MM-DD HH24:MI') INP_DT -- 투입일시
            , I001.ORDER_NO                 ORDER_NO
            , I003.IND_BCD                 IND_BCD --개별바코드
            , I003.MATNR                   MATNR
            , RTRIM(TO_CHAR(I003.IN_QTY, 'fm999,999,999,990.999'), '.')        IN_QTY   --투입량
            , RTRIM(TO_CHAR(I003.USE_QTY, 'fm999,999,999,990.999'), '.')        USE_QTY   --사용량
            , RTRIM(TO_CHAR(I003.STCK_QTY, 'fm999,999,999,990.999'), '.')        STCK_QTY   --재고량
            , I003.UNIT                   UNIT
            , RTRIM(TO_CHAR(I003.WGT, 'fm999,999,999,990.999'), '.')        WGT   --중량
             ,'상세보기'                    DBTN                --상세보기
             , I003.WRK_ORDR_NO           WRK_ORDR_NO         --작업지시번호
             , I003.WRK_ORDR_SEQNO        WRK_ORDR_SEQNO      --작업지시순번
        FROM TB_INV003 I003
           , TB_INV001 I001
           , TB_MAS001 M001    --플랜트별 제품/자재 마스터
        WHERE 1=1
           AND I003.IND_BCD = I001.IND_BCD(+)
           AND I001.WERKS = M001.WERKS
           AND I001.MATNR = M001.MATNR
           AND I003.WERKS = P_WERKS
           AND I003.MACH_CD = P_MACH_CD
           AND NVL(I003.IND_BCD,' ') LIKE '%' || P_IND_BCD || '%'
           AND NVL(I001.ORDER_NO,' ') LIKE '%' || P_ORDER_NO || '%'
           AND NVL(M001.PCODE   ,' ') LIKE '%' || P_PCODE || '%'
           AND TO_CHAR(NVL(M001.BS_WGT,0)) LIKE '%' || P_BS_WGT || '%'
           AND TO_CHAR(NVL(M001.WLEN,0)) LIKE '%' || P_WLEN || '%'
           AND TO_CHAR(NVL(M001.VLEN,0)) LIKE '%' || P_VLEN || '%'
           AND I003.STCK_QTY > 0
        ORDER BY I003.REGDATE DESC;

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
--        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
        RAISE;

        RS_CODE := 'E';
        RS_MSG  := SQLERRM;
        RETURN;
    --예외처리 종료
    END;
END;

/
