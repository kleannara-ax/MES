
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_INV02_S01" 
(
    P_WERKS       IN VARCHAR2 
    ,P_MACH_CD     IN VARCHAR2 
    ,P_WORKDATE   IN VARCHAR2 
    ,P_WRK_ORDER  IN VARCHAR2 
    ,P_MATNR      IN VARCHAR2 
    ,P_COLINFO    OUT VARCHAR2
    ,P_COLTYPE    OUT VARCHAR2
    ,Lang         IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE      OUT VARCHAR2 
    ,RS_MSG       OUT VARCHAR2
    ,CUR_1        OUT SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : POP_INV02
 * PROGRAM NAME  : 자재투입 이력 조회
 * VERSION       : 1.0.0
 * DESCRIPTION   : 공정에 자재를 투입한 이력을 조회한다.
 *                 
 * AUTHOR NAME   : 김기연
 * CREATE DATE   : 2022/05/02
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/05/02    1.0.0   김기연         Initial Version 
 *==============================================================================
 *  관련 테이블
 * - [TB_INV003] : (.R..) 자재 투입 이력
 * - [TB_MAS001] : (.R..) 자재 기준 정보
 * - [TB_SCH011] : (.R..) 화장지 합지기 작업지시
 * - [] (이후 각 작업지시 테이블 추가 예정
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM        VARCHAR2(100)  := 'SP_POP_INV02_S01';     -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID   varchar2(20) := 'TEST'; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);
    --내부 파라미터
    V_WORKDATE  DATE := TO_DATE(P_WORKDATE,'YYYY-MM-DD');

BEGIN
    --예외처리 시작(try)
    BEGIN
        BEGIN

            P_COLINFO := '순번@R^50|작업지시번호@C^200|순번@H^60|품목코드@C^120|품목명@L^330|LOT번호@H|개별바코드@C^180|투입량@R^100|사용량@R^100|잔량@R^100|단위@C^60';
            P_COLTYPE := 'SEQ@varchar|WRK_ORDR_NO@varchar|WRK_ORDR_SEQNO@varchar|MATNR@varchar|MATNR_NM@varchar|LOT_NO@varchar|IND_BCD@varchar|IN_QTY@varchar|USE_QTY@varchar|STCK_QTY@varchar|UNIT@varchar';

            --결과 테이블 반환용 변수
            IF P_WERKS = 'P100' THEN    --YSH 2022.09.14
                OPEN CUR_1 FOR
                SELECT ROW_NUMBER() OVER(ORDER BY I003.WRK_ORDR_NO, I003.WRK_ORDR_SEQNO)AS SEQ
                     , I003.WRK_ORDR_NO         --작업지시
                     , I003.WRK_ORDR_SEQNO      --작업지시 순번
                     , I003.MATNR               --자재코드
                     , M001.MATNR_NM            --자재명
                     , I003.LOT_NO				--Lot번호
                     , I003.IND_BCD             --개별바코드
                     , RTRIM(TO_CHAR(NVL(I003.IN_QTY,0), 'FM999,999,990.999'),'.') AS IN_QTY --투입수량
                     , RTRIM(TO_CHAR(NVL(I003.USE_QTY,0), 'FM999,999,990.999'),'.') AS USE_QTY --사용수량
                     , RTRIM(TO_CHAR(NVL(I003.STCK_QTY,0), 'FM999,999,990.999'),'.') AS STCK_QTY --재고수량
                     , M001.UNIT                --단위
                FROM TB_INV003 I003, --자재투입이력
                     TB_MAS001 M001 --자재정보
                WHERE 1=1
                AND I003.WERKS = M001.WERKS
                AND I003.MATNR = M001.MATNR
                AND I003.WERKS = P_WERKS
                AND I003.MACH_CD = P_MACH_CD
                --AND NVL(I003.WRK_ORDR_NO, '') = '' 
                AND I003.REGDATE BETWEEN TO_DATE(V_WORKDATE) AND TO_DATE(V_WORKDATE) + (INTERVAL '24' HOUR) --투입이력 생성일자
                AND I003.WRK_ORDR_NO LIKE '%' || P_WRK_ORDER || '%'
                AND I003.MATNR LIKE '%' || P_MATNR || '%'
                AND M001.MATNR_DIV = 'ROH7'
                ORDER BY I003.WRK_ORDR_NO, I003.WRK_ORDR_SEQNO;
            ELSE
                OPEN CUR_1 FOR
                --자재투입이력 목록조회
                SELECT ROW_NUMBER() OVER(ORDER BY I003.WRK_ORDR_NO, I003.WRK_ORDR_SEQNO)AS SEQ
                     , I003.WRK_ORDR_NO         --작업지시
                     , I003.WRK_ORDR_SEQNO      --작업지시 순번
                     , I003.MATNR               --자재코드
                     , M001.MATNR_NM            --자재명
                     , I003.LOT_NO				--Lot번호
                     , I003.IND_BCD             --개별바코드
    --                 , TO_CHAR(I003.IN_QTY,'FM999,999') AS IN_QTY --투입수량
    --                 , TO_CHAR(I003.USE_QTY,'FM999,999') AS USE_QTY --사용수량
    --                 , TO_CHAR(I003.STCK_QTY,'FM999,999') AS STCK_QTY --재고수량
                     , RTRIM(TO_CHAR(NVL(I003.IN_QTY,0), 'FM999,999,990.999'),'.') AS IN_QTY --투입수량
                     , RTRIM(TO_CHAR(NVL(I003.USE_QTY,0), 'FM999,999,990.999'),'.') AS USE_QTY --사용수량
                     , RTRIM(TO_CHAR(NVL(I003.STCK_QTY,0), 'FM999,999,990.999'),'.') AS STCK_QTY --재고수량
                     , M001.UNIT                --단위
                FROM TB_INV003 I003, --자재투입이력
                     --TB_SCH011 S011, --화장지 합지기 작업지시
                     TB_MAS001 M001 --자재정보
                WHERE 1=1
    --            AND I003.WERKS = S011.WERKS(+)
    --            AND I003.WRK_ORDR_NO = S011.WRK_ORDR_NO(+)
    --            AND I003.WRK_ORDR_SEQNO = S011.WRK_ORDR_SEQNO(+)
                AND I003.WERKS = M001.WERKS(+)
                AND I003.MATNR = M001.MATNR(+)
                AND I003.WERKS = P_WERKS
                AND I003.MACH_CD = P_MACH_CD
                AND I003.REGDATE BETWEEN TO_DATE(V_WORKDATE) AND TO_DATE(V_WORKDATE) + (INTERVAL '24' HOUR) --투입이력 생성일자
                AND I003.WRK_ORDR_NO LIKE '%' || P_WRK_ORDER || '%'
                AND I003.MATNR LIKE '%' || P_MATNR || '%'
              --ORDER BY I003.REGDATE;
                ORDER BY I003.WRK_ORDR_NO, I003.WRK_ORDR_SEQNO;
            END IF;
            --작업 정상 종료 코드 등록
            RS_CODE := 'S';
        END;
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
END SP_POP_INV02_S01;
/
