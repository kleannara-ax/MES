--------------------------------------------------------
--  DDL for Procedure SP_POP_INV04_S03
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_INV04_S03" 
(
    P_WERKS             IN VARCHAR2                --플랜트코드
    --,P_MACH_CD          IN VARCHAR2                --작업장
    ,P_IND_BCD          IN VARCHAR2                --개별바코드
    ,RS_WRK_ORDR_NO     OUT VARCHAR2 
    ,RS_WRK_ORDR_SEQNO  OUT VARCHAR2 
    ,Lang               IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE            OUT VARCHAR2 
    ,RS_MSG             OUT VARCHAR2
)
/*==============================================================================
 * PROGRAM ID    : SP_POP_INV04_S03{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 개별바코드로 작업지시번호 조회
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 개별바코드로 작업지시번호 조회{프로그램에 대한 상세한 내용 기술}
 *                 
 * AUTHOR NAME   : 김병무{최초 작성자 명 기술}
 * CREATE DATE   : 2022/07/20 {최초 작성일자 기술}
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/07/20    1.0.0   김병무         Initial Version 
 *==============================================================================
 *  관련 테이블
 *       - [TB_INV001] : 창고별 재고 관리에서 개별바코드로 작업지시번호 조회
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM        VARCHAR2(100)  := 'SP_POP_INV04_S03';     -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID   varchar2(20) := 'TEST'; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);
    --parameter변수 처리
    V_IN_MR_YN      VARCHAR2(1);
    V_LOT_NO        TB_INV001.LOT_NO%TYPE;
    
BEGIN
    --예외처리 시작(try)
    BEGIN
        BEGIN
            --수입밀롤 여부 확인
            SELECT  NVL(IN_MR_YN, 'N'), LOT_NO
                INTO  V_IN_MR_YN, V_LOT_NO
                FROM TB_INV001 
                WHERE WERKS=P_WERKS
                  AND STOR_LOC_CD = '2700'
                  AND IND_BCD = P_IND_BCD;
                  
            IF V_IN_MR_YN = 'N' THEN
                SELECT  MAX(WRK_ORDR_NO), MAX(WRK_ORDR_SEQNO)
                    INTO  RS_WRK_ORDR_NO, RS_WRK_ORDR_SEQNO
                    FROM TB_INV001 
                    WHERE WERKS=P_WERKS
                      --AND MACH_CD = P_MACH_CD
                      AND STOR_LOC_CD = '2700'
                      AND IND_BCD = P_IND_BCD;
            ELSE
                SELECT  MAX(WRK_ORDR_NO), MAX(WRK_ORDR_SEQNO)
                    INTO  RS_WRK_ORDR_NO, RS_WRK_ORDR_SEQNO
                    FROM TB_SCH016
                    WHERE WERKS=P_WERKS
                      AND ORDER_NO = V_LOT_NO;
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
