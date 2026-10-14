--------------------------------------------------------
--  DDL for Procedure SP_SET_LOT_NO
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_SET_LOT_NO" 
(
    P_WERKS                 IN VARCHAR2
    ,P_MACH_CD              IN VARCHAR2 
    ,P_IOTYPE               IN VARCHAR2 
    ,Lang                   IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE                OUT VARCHAR2 
    ,RS_MSG                 OUT VARCHAR2
)
/*==============================================================================
 * PROGRAM ID    : 
 * PROGRAM NAME  : HL LOT_NO재설정
 * VERSION       : 1.0.0
 * DESCRIPTION   : 07시를 기주능로 LOT_NO를 신규생성하여 변경한다.
 *                 
 * AUTHOR NAME   : 김기연
 * CREATE DATE   : 2022/07/13
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/07/13    1.0.0   김기연         Initial Version
 *==============================================================================
 *  관련 테이블
 * - [TB_WRK011] : (C.U.) 작업장 현황
 * - [TB_WRK012] : (C.U.) 작업장 가동현황
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM        VARCHAR2(100)  := 'SP_SET_LOT_NO';     -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID   varchar2(20) := 'TEST'; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);
    --내부 변수 처리
    V_DATE      DATE := SYSDATE;
    V_MATNR     VARCHAR(20); --자재 코드
    V_LOT_NO    VARCHAR(15); --LOT번호
    V_TEMP_LOT  VARCHAR(15); --현재 LOT번호
    V_LAST_DATE DATE; --마지막 변경시간

BEGIN
    --예외처리 시작(try)
    BEGIN
        --변경여부 초기설정
        RS_CODE := 'E'; 

        --설비정보 조회 -- 현재 설비의 정보가 없는 경우 종료
        BEGIN
            SELECT MATNR, LOT_NO, NVL(UPDDATE, REGDATE)
              INTO V_MATNR, V_LOT_NO, V_LAST_DATE
              FROM TB_WRK011
             WHERE 1=1
               AND WERKS = P_WERKS
               AND MACH_CD = P_MACH_CD
               AND IN_OUT = P_IOTYPE;
        EXCEPTION WHEN NO_DATA_FOUND THEN
            RETURN;
        END;
        --현재 LOT가 없는 경우 종료
        IF V_LOT_NO = '' THEN
            RETURN;
        END IF;

        --LOT 변경 필요여부 확인 
        IF TO_NUMBER(TO_CHAR(V_LAST_DATE,'YYYYMMDD')) = TO_NUMBER(TO_CHAR(V_DATE,'YYYYMMDD')) THEN
            IF TO_NUMBER(TO_CHAR(V_LAST_DATE,'HH24MISS')) > TO_NUMBER('070000') THEN
                --마지막 수정일자가 금일 07시 이후인 경우 LOT_NO 유지
                RETURN;
            END IF;
        END IF;

        --현재 LOT_NO 저장
        V_TEMP_LOT := V_LOT_NO;
        --신규 LOT_NO 생성
        SP_CHK_LOT_NO (V_TEMP_LOT, P_WERKS, P_MACH_CD, V_MATNR, V_DATE, V_LOT_NO);
        --통합 설비의 경우 처리 진행
        UPDATE TB_WRK011
           SET LOT_NO = V_LOT_NO
             , UPDDATE = V_DATE
             , UPDID = 'SYSTEM'
         WHERE 1=1
           AND WERKS = P_WERKS
           AND MACH_CD = P_MACH_CD
           AND IN_OUT = P_IOTYPE;
        IF SQL%ROWCOUNT > 0 THEN
            --변경 완료시 
            RS_CODE := 'S';
        END IF;
    --예외처리(catch)
    EXCEPTION
    WHEN E_EXCEPTION_USER THEN
        -- 에러 내역 SET
        E_SQL_ERR_CD        := SQLCODE;
        E_SQL_ERR_MSG       := SUBSTRB(SQLERRM,1,300);

        ROLLBACK;
        SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);

        RETURN;
    WHEN OTHERS THEN
        E_SQL_ERR_CD        := -20001;
        E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

        ROLLBACK;
        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);

        RETURN;
    --예외처리 종료
    END;
END SP_SET_LOT_NO;

/
