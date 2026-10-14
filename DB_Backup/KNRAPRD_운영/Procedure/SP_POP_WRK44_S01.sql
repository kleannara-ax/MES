--------------------------------------------------------
--  DDL for Procedure SP_POP_WRK44_S01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK44_S01" 
(
    P_WERKS     IN VARCHAR2 
    ,P_MACH_CD  IN VARCHAR2 
    ,P_IOTYPE   IN VARCHAR2 
    ,Lang       IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE    OUT VARCHAR2 
    ,RS_MSG     OUT VARCHAR2
    ,CUR_1      OUT SYS_REFCURSOR
    ,CUR_2      OUT SYS_REFCURSOR
    ,CUR_3      OUT SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : POP_WRK44
 * PROGRAM NAME  : 생리대 예외생산 주 작업 화면
 * VERSION       : 1.0.1
 * DESCRIPTION   : 현재 작업지시 및 대기 작업지시 목록을 조회한다.
 *                 
 * AUTHOR NAME   : 김기연
 * CREATE DATE   : 2022/07/08
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/05/16    1.0.0   김기연         Initial Version
 *==============================================================================
 *  관련 테이블
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM        VARCHAR2(100)  := 'SP_POP_WRK44_S01';     -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID   varchar2(20) := 'TEST'; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);
    --내부변수 관리
    V_MACH_CD VARCHAR2(10);
    V_COLINFO VARCHAR2(1000);
    V_COLTYPE VARCHAR2(1000);
BEGIN
    --예외처리 시작(try)
    BEGIN
        BEGIN
            V_MACH_CD := P_MACH_CD;
            
            --grid 컬럼 정보 설정
            V_COLINFO := '생산요청일@C^120|작업지시번호@H|순번@H|품목코드@C^160|품목명@L^400|계획량@R^100|단위@C^70|지시사항@L^310|상태@C^75|상세보기@C^100|표시순번@H';
            V_COLTYPE := 'PRD_REQ_DT@varchar|WRK_ORDR_NO@varchar|WRK_ORDR_SEQNO@varchar|MATNR@varchar|MATNR_NM@varchar|WRK_ORDR_QTY@varchar|UNIT@varchar|STA@varchar|WRK_ORDR_RMK@varchar|WRK_ORDR_DETAIL@Button|ROWSEQ@varchar';
            --컬럼설정 반환 테이블 작성
            OPEN CUR_1 FOR
            SELECT RTN_VALUES FROM FN_SPLIT(V_COLINFO||','||V_COLTYPE,',');

            --생리대 예외생산 지시목록 조회
            OPEN CUR_2 FOR
            SELECT TO_CHAR(TO_DATE(S019.PRD_REQ_DT,'YYYYMMDD'),'YYYY-MM-DD') AS PRD_REQ_DT       --생산지시일
                 , S019.WRK_ORDR_NO || '-' || LPAD(S019.WRK_ORDR_SEQNO,2,'0') AS WRK_ORDR_NO--작업지시
                 , S019.WRK_ORDR_SEQNO      --작업지시 순번
                 , S019.MATNR               --자재코드
                 , M001.MATNR_NM            --자재명
                 , TO_CHAR(S019.WRK_ORDR_QTY, 'FM999,999,990') AS WRK_ORDR_QTY --지시수량
                 , S019.UNIT                --단위
                 , S019.AUARTXT AS WRK_ORDR_RMK        --작업지시사항
                 , CASE WHEN S019.COMP_YN = 'N' THEN '대기'
                        WHEN S019.COMP_YN = 'I' THEN '가동중' 
                        WHEN S019.COMP_YN = 'Y' THEN '완료' END AS STA             --작업지시 상태
                 , '상세보기' AS WRK_ORDR_DETAIL    --상세보기
                 , CASE WHEN NVL(W011.WRK_ORDR_NO,'N/A') = 'N/A' THEN 1 ELSE 0 END AS ROWSEQ
            FROM TB_SCH019 S019, --화장지 가공기 작업지시
                 TB_MAS001 M001, --자재정보
                 (SELECT * FROM TB_WRK011 WHERE IN_OUT = 'N') W011
            WHERE 1=1
            AND S019.WERKS = M001.WERKS(+)
            AND S019.MATNR = M001.MATNR(+)
            AND S019.MACH_CD = W011.MACH_CD(+)
            AND S019.WRK_ORDR_NO = W011.WRK_ORDR_NO(+)
            AND S019.MACH_CD = V_MACH_CD
            AND S019.WERKS = P_WERKS
            AND S019.COMP_YN != 'Y'
            ORDER BY ROWSEQ, S019.PRD_REQ_DT, S019.WRK_ORDR_NO, S019.WRK_ORDR_SEQNO;

            --현재 작업지시 조회
            OPEN CUR_3 FOR
            SELECT S019.PRD_REQ_DT         --생산지시일
                 , W011.WRK_ORDR_NO         --작업지시
                 , W011.WRK_ORDR_SEQNO      --작업지시 순번
                 , S019.ORDER_NO            --생산오더
                 , S019.MATNR               --자재코드
                 , M001.MATNR_NM            --자재명
                 , M001.MATNR_SPEC          --규격
                 , M001.PCODE               --지종
                 , M001.PCODE_NM            --지종명
                 , '' AS SPEC                --지시규격
                 , S019.WRK_ORDR_QTY AS ORDER_QTY --계획수량
                 , S019.COMP_QTY AS PRFM_QTY --실적수량
                 , S019.UNIT                --단위
                 , CEIL(FN_CHG_UNIT(W011.MATNR, W011.WERKS, S019.UNIT, 'PAL', S019.WRK_ORDR_QTY)) AS PLTORDR --계획팔레트
                 , CEIL(FN_CHG_UNIT(W011.MATNR, W011.WERKS, S019.UNIT, 'BOX', S019.WRK_ORDR_QTY)) AS BOXORDR --계획박스
                 , CEIL(FN_CHG_UNIT(W011.MATNR, W011.WERKS, S019.UNIT, 'BAG', S019.WRK_ORDR_QTY)) AS BAGORDR --계획폴리백
                 , CEIL(FN_CHG_UNIT(W011.MATNR, W011.WERKS, S019.UNIT, 'EA', S019.WRK_ORDR_QTY)) AS EAORDR --계획개수
                 , CEIL(W001.PLT) AS PLTQTY       --실적(팔레트)
                 , CEIL(W001.BOX) AS BOXQTY       --실적(팔레트)
                 , CEIL(W001.BAG) AS BAGQTY       --실적(팔레트)
                 , CEIL(W001.EA) AS EAQTY       --실적(팔레트)
                 , FN_UNIT_RATE(W011.MATNR, W011.WERKS, 'BOX', 'PAL') AS PLT_RATE --박스/팔레트비율
                 , FN_UNIT_RATE(W011.MATNR, W011.WERKS, 'BOX', 'BOX') AS BOX_RATE --박스/박스비율
                 , FN_UNIT_RATE(W011.MATNR, W011.WERKS, 'BOX', 'BAG') AS BAG_RATE --박스/폴리백비율
                 , FN_UNIT_RATE(W011.MATNR, W011.WERKS, 'BOX', 'EA') AS EA_RATE --박스/개수비율
                 , FN_CHG_UNIT(W011.MATNR, W011.WERKS, 'PAL', 'BOX', 1) AS PLT2BOX --팔레트당 박스
                 , S019.AUARTXT AS WRK_ORDR_RMK   --작업지시사항
                 , W011.MACH_STA            --가동여부
                 , TO_DATE(W011.PRD_STR_DTM,'YYYYMMDDHH24MISS') AS PRD_STR_DATE --시작일시
                 , TO_DATE(S019.PRD_END_DTM,'YYYYMMDDHH24MISS') AS PRD_END_DATE --완료일시
                 , W001.WRK_STR_DATE AS WRK_STR_DATE
                 , W001.WRK_END_DATE AS WRK_END_DATE
            FROM TB_WRK011 W011,            --작업장 현황
                 TB_SCH019 S019,            --화장지 가공기 작업지시
                 TB_MAS001 M001,            --자재정보
                 (SELECT WERKS, ORDER_NO, WRK_ORDR_NO, WRK_ORDR_SEQNO, MAX(PRD_STR_DATE) AS WRK_STR_DATE, MAX(PRD_END_DATE) AS WRK_END_DATE
                       , SUM(W001.PLT_QTY) AS PLT, SUM(W001.BOX_QTY) AS BOX, SUM(W001.BAG_QTY) AS BAG, SUM(W001.EA_QTY) AS EA 
                    FROM TB_WRK001 W001
                   WHERE WERKS = P_WERKS
                     AND NVL(CNL_YN, 'N') = 'N'
                     AND NVL(PRFM_GTHR_YN, 'Y') = 'Y' 
                   GROUP BY WERKS, MACH_CD, ORDER_NO, WRK_ORDR_NO, WRK_ORDR_SEQNO) W001 --생산실적
            WHERE 1=1 
            AND W011.WERKS = S019.WERKS(+)
            AND W011.WRK_ORDR_NO = S019.WRK_ORDR_NO(+)
            AND W011.WRK_ORDR_SEQNO = S019.WRK_ORDR_SEQNO(+)
            AND W011.WERKS = M001.WERKS(+)
            AND W011.MATNR = M001.MATNR(+)
            AND W011.WERKS = W001.WERKS(+)
            AND W011.WRK_ORDR_NO = W001.WRK_ORDR_NO(+)
            AND W011.WRK_ORDR_SEQNO = W001.WRK_ORDR_SEQNO(+)
            AND W011.MACH_CD = V_MACH_CD
            AND W011.WERKS = P_WERKS
            AND W011.IN_OUT = P_IOTYPE;
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
        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);

        RS_CODE := 'E';
        RS_MSG  := SQLERRM;
        RETURN;
    --예외처리 종료
    END;
END SP_POP_WRK44_S01;

/
