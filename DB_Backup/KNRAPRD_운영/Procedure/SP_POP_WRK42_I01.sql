--------------------------------------------------------
--  DDL for Procedure SP_POP_WRK42_I01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK42_I01" 
(
    P_WERKS         IN VARCHAR2         --플랜트
    ,P_MACH_CD      IN VARCHAR2         --설비코드
    ,P_IND_BCD      IN VARCHAR2         --개별바코드
    ,P_USERID       IN VARCHAR2         --
    ,Lang           IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE        OUT VARCHAR2 
    ,RS_MSG         OUT VARCHAR2
)
/*==============================================================================
 * PROGRAM ID    : POP_WRK42
 * PROGRAM NAME  : 공정투입 취소
 * VERSION       : 1.0.0
 * DESCRIPTION   : 선택된 작업자 정보를 저장한다.
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
 * 2022/06/03    1.0.0   김병무         Initial Version 
 *==============================================================================
 *  관련 테이블
 * - [TB_INV003] : (C...) 자재투입 (TB_INV001에 있는 반제품을 투입)
 * - [TB_INV001] : (.RU.) 창고별 재고 관리
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM            VARCHAR2(100)  := 'SP_POP_WRK01_I01';
    V_PLT_CD            VARCHAR2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID      VARCHAR2(20) := P_USERID;
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER    EXCEPTION;
    E_SQL_ERR_CD        NUMBER(5) := 0;
    E_SQL_ERR_MSG       VARCHAR2(4000);

    --파리미터 처리
    --내부변수 처리
    V_DATE      DATE := SYSDATE;
BEGIN
    --예외처리 시작(try)
    BEGIN
        -- I001.STCK_STA 재고상태 확인하여 이동 가능한지 확인.

        -- INV003에 있는 재고수량(STCK_QTY)을 INV001로 이동
        UPDATE TB_INV001 I001
           SET I001.STCK_QTY = (SELECT STCK_QTY 
                                    FROM TB_INV003 I003
                                    WHERE I003.WERKS = I001.WERKS
                                     AND I003.IND_BCD = I001.IND_BCD )
            , I001.STCK_STA = '00'
            , I001.UPDDATE = V_DATE
            , I001.UPDID = V_SESS_USER_ID
         WHERE I001.WERKS = P_WERKS
           AND I001.IND_BCD = P_IND_BCD;


        -- 공정투입 테이블 에서 공정취소 레코드 삭제
        --투입이력 삭제  
        DELETE TB_INV003
         WHERE 1=1
           AND WERKS = P_WERKS   
           --AND WRK_ORDR_NO = P_WRK_ORDR_NO 
           --AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO 
           AND IND_BCD = P_IND_BCD; 

        --작업 정상 종료 코드 등록
        RS_CODE := 'S';
        COMMIT;

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
END;

/
