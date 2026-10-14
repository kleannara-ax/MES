--------------------------------------------------------
--  DDL for Procedure SP_POP_WRK85_U01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK85_U01" 
(
    P_WERKS             IN VARCHAR2 --plantcode
    ,P_MACH_CD          IN VARCHAR2 --설비정보
    ,P_IND_BCD          IN VARCHAR2 --개별바코드
    ,P_LOT_NO     		IN VARCHAR2 --LOT_NO
    ,P_RMK              IN VARCHAR2 --변경할 비고내용
    ,P_USER_ID          IN VARCHAR2 --사용자ID
    ,Lang               IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE            OUT VARCHAR2 
    ,RS_MSG             OUT VARCHAR2
)
/*==============================================================================
 * PROGRAM ID    : SP_POP_WRK85_U01
 * PROGRAM NAME  : 비고내용 수정
 * VERSION       : 1.0.0
 * DESCRIPTION   : 실적현황에서 선택된 비고내용 수정
 *                 
 * AUTHOR NAME   : 김병무
 * CREATE DATE   : 2022/07/26
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/07/26    1.0.0   김병무         Initial Version
 *==============================================================================
 *  관련 테이블
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM         VARCHAR2(100)  := 'SP_POP_WRK85_U01';     -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID   varchar2(20) := 'TEST'; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);
    --parameter변수 처리
    --V_WERKS             VARCHAR2(4) := P_WERKS;
    --V_MACH_CD           VARCHAR2(10) := P_MACH_CD;
    --V_IND_BCD          	VARCHAR2(20) := P_IND_BCD;
    --V_LOT_NO       		VARCHAR2(10) := P_LOT_NO;
    --V_REMARK            VARCHAR(100) := P_REMARK;
    --내부 변수 등록
    V_DATE      DATE := SYSDATE;
    V_TABLE     VARCHAR2(10);
    V_SQL       CLOB;
    V_STCK_STA  VARCHAR2(5);
BEGIN
    --예외처리 시작(try)
    BEGIN
       BEGIN 
       SELECT STCK_STA
         INTO V_STCK_STA
         FROM TB_INV001
        WHERE WERKS   = P_WERKS
          AND IND_BCD = P_IND_BCD;
       EXCEPTION
         WHEN NO_DATA_FOUND THEN
            V_STCK_STA := '00';
       END;
       
       IF V_STCK_STA = '10'  THEN
                RS_CODE := 'E';
                RS_MSG  := '이미 투입된 자재입니다.';
                RETURN;
       END IF;
        
        
        BEGIN
			IF P_WERKS = 'P100' THEN
                UPDATE TB_WRK002
                    SET RMK = P_RMK, UPDDATE = V_DATE, UPDID = P_USER_ID
                WHERE 1=1
                    AND WERKS = P_WERKS
                    AND IND_BCD = P_IND_BCD
                    AND LOT_NO = P_LOT_NO;
			ELSE
                UPDATE TB_WRK001
                    SET RMK = P_RMK, UPDDATE = V_DATE, UPDID = P_USER_ID
                WHERE 1=1
                    AND WERKS = P_WERKS
                    AND IND_BCD = P_IND_BCD
                    AND LOT_NO = P_LOT_NO;
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
END SP_POP_WRK85_U01;

/
