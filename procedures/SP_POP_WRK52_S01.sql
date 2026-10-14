
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK52_S01" SP_POP_WRK52_S01
(
    P_WERKS         IN VARCHAR2
    ,P_PROC_CD      IN VARCHAR2
    ,P_MACH_CD      IN VARCHAR2
    ,P_IOTYPE       IN VARCHAR2
    ,P_MACHINE      IN VARCHAR2
    ,P_PRD_STR_DATE IN VARCHAR2     --YYYYMMDD
    ,P_PRD_END_DATE IN VARCHAR2     --YYYYMMDD
    ,P_PCODE        IN VARCHAR2
    ,P_WEIGHT       IN VARCHAR2
    ,P_MATNR        IN VARCHAR2
    ,P_USERID       IN VARCHAR2
    ,Lang           IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE        OUT VARCHAR2 
    ,RS_MSG         OUT VARCHAR2
    ,CUR_1          OUT SYS_REFCURSOR
    ,CUR_2          OUT SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : POP_WRK52
 * PROGRAM NAME  : HL 화장지 판매용 원단 작업지시 목록조회
 * VERSION       : 1.0.0
 * DESCRIPTION   : 현재 설비의 작업지시 목록을 조회한다.
 *                 
 * AUTHOR NAME   : 백우종
 * CREATE DATE   : 2023/01/18
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------

 *==============================================================================
 *  관련 테이블
 * - [TB_SCH002] : (.R..) 화장지 합지기 생산오더
 * - [TB_SCH011] : (.R..) 화장지 합지기 작업지시
 * - [TB_MAS001] : (.R..) 자재 기준 정보
 * - [TB_WRK001] : (.R..) HL 생산실적 이력
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM        VARCHAR2(100)  := 'SP_POP_WRK52_S01';     -- PROCEDURE NAME
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
BEGIN
    --예외처리 시작(try)
    BEGIN

        --공정별 조회프로시저 변경
        --화장지 합지기
        IF P_PROC_CD = 'AA' THEN
            --grid 컬럼 정보 설정
            V_COLINFO := '선택@C^50|생산요청일@C^110|생산오더@H|작업지시번호@C^250|작업지시번호@H^200|순번@H|작업순번@R^90|자재코드@C^160|자재명@L^400|규격@R^100|계획량@R^100|단위@C^70|지시사항@C^300|상세보기@C^100';
            V_COLTYPE := 'CHK@Button|PRD_REQ_DT@varchar|ORDER_NO@varchar|WRK_ORDR_NO_SEQ@varchar|WRK_ORDR_NO@varchar|WRK_ORDR_SEQNO@varchar|WRK_SEQNO@varchar|MATNR@varchar|MATNR_NM@varchar|MATNR_SPEC@varchar|WRK_ORDR_QTY@varchar|UNIT@varchar|ORDER_RMK@varchar|DBTN@Button';
            --컬럼설정 반환 테이블 작성
            OPEN CUR_1 FOR
            SELECT RTN_VALUES FROM FN_SPLIT(V_COLINFO||','||V_COLTYPE,',');

            --지시목록 조회
            OPEN CUR_2 FOR
            SELECT '-' AS CHK
                 , TO_CHAR(TO_DATE(S011.PRD_REQ_DT,'YYYYMMDD'),'YYYY-MM-DD') AS PRD_REQ_DT       --생산요청일
                 , S011.ORDER_NO            --생산오더
                 , S011.WRK_ORDR_NO || '-' || LPAD(S011.WRK_ORDR_SEQNO,2,'0') AS WRK_ORDR_NO_SEQ --작업지시+순번
                 , S011.WRK_ORDR_NO         --작업지시
                 , S011.WRK_ORDR_SEQNO      --작업지시 순번
                 , S011.WRK_SEQNO           --작업순번
                 , S011.MATNR               --자재코드
                 , M001.MATNR_NM            --자재명
                 , S011.SPEC AS MATNR_SPEC  --규격
--                 , M001.MATNR_SPEC          --규격
                 , TO_CHAR(S011.WRK_ORDR_QTY, 'FM999,999,990') AS WRK_ORDR_QTY --지시수량
                 , S011.UNIT                --단위
                 , S011.WRK_ORDR_RMK AS ORDER_RMK --작업지시사항
                 , '상세보기' AS DBTN    --상세보기
              FROM TB_SCH011 S011, --화장지 합지기 작업지시
                   TB_MAS001 M001 --자재정보
             WHERE 1=1
               AND S011.WERKS = M001.WERKS(+)
               AND S011.MATNR = M001.MATNR(+)
               AND S011.WERKS = P_WERKS
               AND S011.MACH_CD = P_MACH_CD
               AND S011.PRD_REQ_DT >= P_PRD_STR_DATE
               AND S011.PRD_REQ_DT <= P_PRD_END_DATE
               AND NVL(M001.PCODE,' ') LIKE '%' || P_PCODE || '%'
               --AND TO_CHAR(NVL(M001.BS_WGT,0)) LIKE '%' || P_WEIGHT || '%'
               AND NVL(S011.MATNR,' ') LIKE '%' || P_MATNR || '%'
               AND S011.COMP_YN != 'Y'
               AND S011.USE_YN = 'Y'
               AND SUBSTR(S011.MATNR, -1) = 'M'
             ORDER BY S011.PRD_REQ_DT, S011.WRK_SEQNO, S011.WRK_ORDR_NO, S011.WRK_ORDR_SEQNO;
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
        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);

        RS_CODE := 'E';
        RS_MSG  := SQLERRM;
        RETURN;
    --예외처리 종료
    END;
END ;
/
