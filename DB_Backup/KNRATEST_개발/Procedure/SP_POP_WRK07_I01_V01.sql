--------------------------------------------------------
--  DDL for Procedure SP_POP_WRK07_I01_V01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK07_I01_V01" 
(
    P_WERKS             IN VARCHAR2
    ,P_MACH_CD          IN VARCHAR2
    ,P_WRK_ORDR_NO      IN VARCHAR2
    ,P_WRK_ORDR_SEQNO   IN VARCHAR2
    ,P_ORDER_NO         IN VARCHAR2
    ,P_MATNR            IN VARCHAR2
    ,P_LOT_NO			IN VARCHAR2
    ,P_USERID           IN VARCHAR2
    ,Lang               IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE            OUT VARCHAR2 
    ,RS_MSG             OUT VARCHAR2
)
/*==============================================================================
 * PROGRAM ID    : POP_WRK07
 * PROGRAM NAME  : 작업지시 선택
 * VERSION       : 1.0.0
 * DESCRIPTION   : 현재 설비의 작업지시 선택
 *                 
 * AUTHOR NAME   : 유상호
 * CREATE DATE   : 2022/05/25
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/05/11    1.0.0   유상호         Initial Version(재작업)
 * 2023/01/14    1.0.1   여한진         예외생산을 위해서 P_LOT_NO 추가
 *==============================================================================
 *  관련 테이블
 * - [TB_SCH002] : (.R..) 화장지 합지기 생산오더
 * - [TB_SCH011] : (.R..) 화장지 합지기 작업지시
 * - [TB_MAS001] : (.R..) 자재 기준 정보
 * - [TB_WRK001] : (.R..) HL 생산실적 이력
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM         VARCHAR2(100) := 'SP_POP_WRK07_I01';  -- PROCEDURE NAME
    V_PLT_CD         VARCHAR2(2)   := '99';    --PLANTCODE TEST
    V_SESS_USER_ID   VARCHAR2(20)  := 'TEST';  --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);
    --내부변수 관리
    V_PRD_STR_DTM     VARCHAR2(20);
BEGIN

    V_PRD_STR_DTM := FN_GET_LAST_DATE(P_WERKS, P_MACH_CD);        

    UPDATE TB_WRK011
       SET WRK_ORDR_NO    = P_WRK_ORDR_NO,
           WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO,
           ORDER_NO       = P_ORDER_NO,
           MATNR          = P_MATNR,
           MACH_STA = 'N',
           PRD_STR_DTM    = V_PRD_STR_DTM,
           LOT_NO  = P_LOT_NO,
           				/*(  SELECT LOT_NO
                          FROM TB_SCH020
                         WHERE WERKS    = P_WERKS
                           AND MATNR    = P_MATNR
                           AND ORDER_NO = P_ORDER_NO
                           AND LOT_NO  IS NOT NULL 
                           AND ROWNUM = 1*/
                         /*UNION ALL 
                        SELECT LOT_NO
                          FROM TB_INV001
                         WHERE WERKS    = P_WERKS
                           AND MATNR    = P_MATNR
                           AND ORDER_NO = P_ORDER_NO
                           AND LOT_NO  IS NOT NULL 
                           AND ROWNUM = 1
                         ) ,*/
            UPDDATE  = SYSDATE,
            UPDID    = P_USERID
      WHERE WERKS   = P_WERKS
        AND MACH_CD = P_MACH_CD;
        --AND IN_OUT = 'N';

    -- 재단공정 중 수입밀롤을 재단시 필요
    IF P_MACH_CD LIKE 'PCA%' THEN
        UPDATE TB_WRK011
           SET LOT_NO  = ORDER_NO
         WHERE WERKS   = P_WERKS
           AND MACH_CD = P_MACH_CD
           AND LOT_NO IS NULL;
            --AND IN_OUT = 'N';
    END IF;

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
 --   RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
    RAISE;
    RS_CODE := 'E';
    RS_MSG  := SQLERRM;
    RETURN;
--예외처리 종료
END;

/
