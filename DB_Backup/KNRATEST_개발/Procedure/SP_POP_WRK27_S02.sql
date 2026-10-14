--------------------------------------------------------
--  DDL for Procedure SP_POP_WRK27_S02
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK27_S02" 
(
     P_WERKS         IN VARCHAR2 
    ,P_MACH_CD       IN VARCHAR2 
    ,P_IND_BCD_C     IN VARCHAR2             -- 1 : 투입된 재단 개별바코드 
    ,P_ORDER_NO_C    IN VARCHAR2             -- 2 : 투입된 재단 오더번호
    ,Lang            IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE         OUT VARCHAR2 
    ,RS_MSG          OUT VARCHAR2
    ,CUR_1           OUT SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : POP_WRK27
 * PROGRAM NAME  : PS 포장 주 작업 화면 (사용안함)
 * VERSION       : 1.0.1
 * DESCRIPTION   : 그리드 클릭했을 때 상세정보 조회
 *                 
 * AUTHOR NAME   : 박충식
 * CREATE DATE   : 2022/06/23
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/05/25    1.0.0   박충식         Initial Version
  *==============================================================================
 *  관련 테이블
 * - [TB_SCH016] : (.R..) 제지 밀롤 작업지시
 * - [TB_MAS001] : (.R..) 자재 기준 정보
 * - [TB_WRK001] : (.R..) 설비별 현재 진행현황
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM        VARCHAR2(100)  := 'SP_POP_WRK27_S02';     -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID   varchar2(20) := 'TEST'; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);
    --내부변수 관리

BEGIN
    BEGIN

        OPEN CUR_1 FOR
        SELECT NVL(W002.PRFM_QTY, 0)                                                    PRFM_QTY    --실적량
             , NVL(I010.USE_QTY, 0)                                                     USE_QTY     --사용량
             , NVL(W004.DISPO_QTY, 0)                                                   DISPO_QTY   --폐품량
             , NVL(W002.PRFM_QTY, 0) - (NVL(I010.USE_QTY, 0) + NVL(W004.DISPO_QTY, 0))  ABLE_QTY    --가용량
          FROM 
                (SELECT WERKS, PRFM_QTY             --실적수량
                  FROM TB_WRK002   --실적테이블(PS)
                 WHERE WERKS = P_WERKS
                   AND IND_BCD = P_IND_BCD_C
                )               W002,         --실적량
                (SELECT WERKS, SUM(USE_QTY) USE_QTY   --사용량
                  FROM TB_INV010   --자재투입이력
                 WHERE WERKS = P_WERKS
                   AND MACH_CD = P_MACH_CD
                   AND IND_BCD_M =  P_IND_BCD_C
                   AND NVL(CNL_YN,'N') = 'N'
                 GROUP BY WERKS, IND_BCD_M
                )               I010,         --사용량
                (SELECT WERKS, SUM(DISPO_QTY) DISPO_QTY  --폐품수량
                   FROM TB_WRK004   --폐품 실적
                  WHERE WERKS = P_WERKS
                    AND MACH_CD = P_MACH_CD
                    AND IND_BCD_M = P_IND_BCD_C
                 GROUP BY WERKS
                )               W004        --폐품량
        WHERE W002.WERKS = I010.WERKS(+)
          AND W002.WERKS = W004.WERKS(+);

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
END;

/
