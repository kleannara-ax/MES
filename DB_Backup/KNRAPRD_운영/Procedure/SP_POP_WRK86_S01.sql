--------------------------------------------------------
--  DDL for Procedure SP_POP_WRK86_S01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK86_S01" 
(
    P_WERKS         IN VARCHAR2 
    ,P_WRK_ORDR_NO  IN VARCHAR2
    ,P_WRK_ORDR_SEQ IN VARCHAR2
    ,P_MACH_CD      IN VARCHAR2
    ,P_IND_BCD      IN VARCHAR2
    ,P_USERID       IN VARCHAR2
    ,Lang           IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE        OUT VARCHAR2 
    ,RS_MSG         OUT VARCHAR2
    ,CUR_1          OUT SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : POP_WRK86
 * PROGRAM NAME  : 부분폐품 조회
 * VERSION       : 1.0.0
 * DESCRIPTION   : 생산실적 정보를 조회한다.
 *                 
 * AUTHOR NAME   : 김기연
 * CREATE DATE   : 2022/05/26
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/05/09    1.0.0   김기연         Initial Version
 *==============================================================================
 *  관련 테이블
 * - [TB_WRK001] : (.R..) HL 생산실적
 * - [TB_SCH011] : (.R..) 합지기 작업지시
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM        VARCHAR2(100)  := 'SP_POP_WRK86_S01';     -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID   varchar2(20) := P_USERID; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);

BEGIN
    --예외처리 시작(try)
    BEGIN
        --결과 테이블 반환용 변수
        OPEN CUR_1 FOR
        --부분폐품 자재정보 조회
        SELECT W001.WERKS                   --플랜트 코드
             , W001.MATNR                   --생산제품
             , M001.MATNR_NM                --제품명
             , W001.LOT_NO                  --LOT 번호
             , W001.IND_BCD                 --개별 바코드
             , RTRIM(TO_CHAR(NVL(I001.PLT_QTY,0),'FM999,990.9'),'.') AS PRFM_PLT     --PLT실적
             , TO_CHAR(CEIL(NVL(I001.BOX_QTY,0)),'FM999,990') AS PRFM_BOX     --BOX실적
             , TO_CHAR(CEIL(NVL(I001.BAG_QTY,0)),'FM999,990') AS PRFM_BAG     --BAG실적
             , TO_CHAR(CEIL(NVL(I001.EA_QTY,0)),'FM999,990') AS PRFM_EA       --EA실적
             , RTRIM(TO_CHAR(FN_CHG_UNIT(W001.MATNR, W001.WERKS, M001.UNIT, 'PAL', NVL(I001.UCFMTY_AMT,0)),'FM999,990.9'),'.') AS DISPO_PLT --PLT부적합
             , TO_CHAR(CEIL(FN_CHG_UNIT(W001.MATNR, W001.WERKS, M001.UNIT, 'BOX', NVL(I001.UCFMTY_AMT,0))),'FM999,990') AS DISPO_BOX --BOX부적합
             , TO_CHAR(CEIL(FN_CHG_UNIT(W001.MATNR, W001.WERKS, M001.UNIT, 'BAG', NVL(I001.UCFMTY_AMT,0))),'FM999,990') AS DISPO_BAG --BAG부적합
             , TO_CHAR(CEIL(FN_CHG_UNIT(W001.MATNR, W001.WERKS, M001.UNIT, 'EA', NVL(I001.UCFMTY_AMT,0))),'FM999,990') AS DISPO_EA --EA부적합
             , FN_UNIT_RATE(W001.MATNR, W001.WERKS, 'BAG', 'PAL') AS PLT_RATE --박스/팔레트비율
             , FN_UNIT_RATE(W001.MATNR, W001.WERKS, 'BAG', 'BOX') AS BOX_RATE --박스/박스비율
             , FN_UNIT_RATE(W001.MATNR, W001.WERKS, 'BAG', 'BAG') AS BAG_RATE --박스/폴리백비율
             , FN_UNIT_RATE(W001.MATNR, W001.WERKS, 'BAG', 'EA') AS EA_RATE --박스/개수비율
        FROM TB_WRK001 W001,                --HL 실적
             TB_MAS001 M001,                --자재정보
             TB_INV001 I001                 --재고정보
        WHERE 1=1
        AND W001.WERKS = M001.WERKS(+)
        AND W001.MATNR = M001.MATNR(+)
        AND W001.WERKS = I001.WERKS(+)
        AND W001.MATNR = I001.MATNR(+)
        AND W001.IND_BCD = I001.IND_BCD(+)
        AND I001.STOR_LOC_CD = '3100'
        AND W001.WERKS = P_WERKS
        AND W001.WRK_ORDR_NO = P_WRK_ORDR_NO
        AND W001.WRK_ORDR_SEQNO = P_WRK_ORDR_SEQ
        AND W001.MACH_CD = P_MACH_CD
        AND W001.IND_BCD = P_IND_BCD;

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
END SP_POP_WRK86_S01;

/
