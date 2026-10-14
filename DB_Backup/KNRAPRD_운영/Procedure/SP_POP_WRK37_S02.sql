--------------------------------------------------------
--  DDL for Procedure SP_POP_WRK37_S02
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK37_S02" 
(
     P_WERKS    IN VARCHAR2             -- 플랜트 코드
    ,P_MACH_CD  IN VARCHAR2             -- 작업장코드(설비코드)
    ,P_IND_BCD  IN VARCHAR2             -- 개별바코드
    ,Lang       IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE    OUT VARCHAR2 
    ,RS_MSG     OUT VARCHAR2 
    ,CUR_1      OUT SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : SP_POP_WRK37_S02
 * PROGRAM NAME  : 등급변경 취소할 바코드 조회
 * VERSION       : 1.0.0
 * DESCRIPTION   : 등급변경 취소할 바코드 조회
 *                 
 * AUTHOR NAME   : 김병무
 * CREATE DATE   : 2022/08/09
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/08/09    1.0.0   김병무         Initial Version
 *==============================================================================
 *  관련 테이블
 * - [TB_WRK002] : (.R..) 등급변경 취소할 바코드 조회
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM        VARCHAR2(100)  := 'SP_POP_WRK37_S02';     -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID   varchar2(20) := 'TEST'; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);
    --내부변수 관리
    V_GRD_YN            TB_WRK002.GRD_YN%TYPE;          -- 등급변경 유무
    V_IND_BCD_M         TB_WRK002.IND_BCD%TYPE;         -- 등급변경 전 개별바코드
    
BEGIN
    --예외처리 시작(try)
    BEGIN
        BEGIN
            SELECT GRD_YN INTO V_GRD_YN
              FROM TB_WRK002
             WHERE WERKS = P_WERKS
               AND IND_BCD = P_IND_BCD;    
               
            IF NVL(V_GRD_YN, 'N') = 'N' THEN
                    RS_CODE := 'E';
                    RS_MSG := '등급변경된 바코드(Q)가 아닙니다.';
                    RETURN;
            END IF;
        
        
            SELECT IND_BCD_M INTO V_IND_BCD_M 
              FROM TB_WRK010
             WHERE WERKS = P_WERKS
               AND IND_BCD = P_IND_BCD
             GROUP BY IND_BCD_M;
               
            --개별바코드로 조회
                OPEN CUR_1 FOR
                SELECT IND_BCD
                     , WRK_TYPE
                     , PCNT
--                SELECT IND_BCD, WRK_TYPE, LOT_NO, MATNR, PCNT, WGT, CHG_DT, 
--                       MATNR_M, LOT_NO_M, DOC_NO, DOC_SEQNO, SDOC_NO, SDOC_SEQNO
                  FROM TB_WRK010
                 WHERE WERKS = P_WERKS
                   AND IND_BCD_M = V_IND_BCD_M
                ORDER BY IND_BCD, WRK_TYPE;                 
                
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
        --RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
        RAISE;

        RS_CODE := 'E';
        RS_MSG  := SQLERRM;
        RETURN;
    --예외처리 종료
    END;
END;

/
