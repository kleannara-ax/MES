--------------------------------------------------------
--  DDL for Procedure SP_POP_WRK81_I01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK81_I01" 
(
    P_WERKS             IN VARCHAR2 --플랜트코드
    ,P_MACH_CD          IN VARCHAR2 --설비코드
    ,P_STOR_LOC_CD      IN VARCHAR2 --저장위치코드
    ,P_IND_BCD          IN VARCHAR2 --개별바코드
    ,P_USERID           IN VARCHAR2 --USERID
    ,Lang               IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE            OUT VARCHAR2 
    ,RS_MSG             OUT VARCHAR2
)
/*==============================================================================
 * PROGRAM ID    : SP_POP_WRK81_I01
 * PROGRAM NAME  : 로케이션(LOC) -> 공정투입
 * VERSION       : 1.0.0
 * DESCRIPTION   : 
 *                 
 * AUTHOR NAME   : 김병무
 * CREATE DATE   : 2022/05/04
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
 * - [TB_INV001] : (..U.) 창고별 재고현황
 * - [TB_INV003] : (C...) 자재투입
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM         VARCHAR2(100)  := 'SP_POP_WRK81_I01';     -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID   varchar2(20) := 'TEST'; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);
    --parameter변수 처리

    --내부 변수 등록
    V_DATE      DATE := SYSDATE;
    V_COUNT     NUMBER;

BEGIN
    --예외처리 시작(try)
    BEGIN
        BEGIN
               SELECT COUNT(WERKS) INTO V_COUNT
                 FROM TB_INV001
                 WHERE 1=1
                   AND WERKS = P_WERKS          -- 플랜트코드
                   AND STOR_LOC_CD = P_STOR_LOC_CD    -- 저장위치
                   AND IND_BCD = P_IND_BCD;     -- 개별바코드
                                                -- ***** 재고상태로 조회해야하는지 확인 필요
                IF V_COUNT = 1 THEN

                    -- 설비별 작업자 투입현황 등록
                    INSERT INTO TB_INV003(WERKS, MACH_CD, MATNR, IND_BCD, WRK_ORDR_NO, WRK_ORDR_SEQNO, SEQNO, INP_DT, IN_QTY, USE_QTY, STCK_QTY
                                         , UNIT, CHG_FLG, STCK_KY, LOT_NUM, REGDATE, REGID)
                       SELECT WERKS, P_MACH_CD, MATNR, IND_BCD, WRK_ORDR_NO, WRK_ORDR_SEQNO, 0, TO_CHAR(V_DATE, 'YYYYMMDD'), STCK_QTY, 0, STCK_QTY
                            , UNIT, '', STCK_KY, LOT_NUM, V_DATE, P_USERID
                         FROM TB_INV001
                         WHERE 1=1
                           AND WERKS = P_WERKS          -- 플랜트코드
                           AND STOR_LOC_CD = P_STOR_LOC_CD    -- 저장위치코드
                           AND IND_BCD = P_IND_BCD;     -- 개별바코드

                    ---- 창고별 재고현황 테이블에서 선택한 정보를 재고상태, 현재고 수량 변경
                    UPDATE TB_INV001
                       SET STCK_QTY = 0        -- 재고수량
                         , STCK_STA = '01'      -- 재고상태
                         , UPDDATE = V_DATE
                         , UPDID = P_USERID
                     WHERE 1=1
                       AND WERKS = P_WERKS              -- 플랜트코드
                       AND STOR_LOC_CD = P_STOR_LOC_CD  -- 저장위치코드
                       AND IND_BCD = P_IND_BCD;         -- 개별바코드
                ELSE
                    RS_CODE := 'E';
                    RS_MSG  := '공정재고를 확인해 주시기 바랍니다.';
                END IF;
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
        E_SQL_ERR_CD        := -20001;
        E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

        ROLLBACK;
        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);

        RS_CODE := 'E';
        RS_MSG  := SQLERRM;
        RETURN;
    --예외처리 종료
    END;
END SP_POP_WRK81_I01;

/
