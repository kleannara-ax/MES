--------------------------------------------------------
--  DDL for Procedure SP_POP_WRK05_U01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK05_U01" 
(
     P_WERKS         IN VARCHAR2         --플랜트
    ,P_WRK_DT       IN VARCHAR2         --근무일자(YYYY-MM-DD)
    ,P_WRK_TIME     IN VARCHAR2         --근무방식
    ,P_WRK_CLASS    IN VARCHAR2         --작업반
    ,P_WORKER       IN VARCHAR2         --작업자
    ,P_WORKERCNT    IN VARCHAR2         --인원수
    ,P_MACH_CD      IN VARCHAR2         --설비코드
    ,P_IOTYPE       IN VARCHAR2         --구분자
    ,P_USERID       IN VARCHAR2         --
    ,Lang           IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE        OUT VARCHAR2 
    ,RS_MSG         OUT VARCHAR2
)
/*==============================================================================
 * PROGRAM ID    : POP_WRK05
 * PROGRAM NAME  : 작업자 선택
 * VERSION       : 1.0.0
 * DESCRIPTION   : 선택된 작업자 정보를 수정한다.
 *                 
 * AUTHOR NAME   : 김기연
 * CREATE DATE   : 2022/05/22
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/04/21    1.0.0   김기연         Initial Version 
 * 2022/05/12    1.0.1   김기연         저장항목 변경 및 가동현황 연동
 *==============================================================================
 *  관련 테이블
 * - [TB_WRK011] : (C.U.) 작업장 현황
 * - [TB_WRK012] : (C.U.) 작업장 가동현황
 * - [TB_WRK013] : (C.U.) 작업자 투입 현황
 *=============================================================================*/
AS 
    V_USERID    VARCHAR(20) := CASE WHEN P_USERID IS NULL 
                                    THEN P_WORKER ELSE P_USERID END;
    --프로그램 ID
    V_PRG_NM            VARCHAR2(100)  := 'SP_POP_WRK05_U01';
    V_PLT_CD            VARCHAR2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID      VARCHAR2(20) := V_USERID;
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER    EXCEPTION;
    E_SQL_ERR_CD        NUMBER(5) := 0;
    E_SQL_ERR_MSG       VARCHAR2(4000);

    --파리미터 처리
    V_WORKERCNT         NUMBER := TO_NUMBER(P_WORKERCNT);
    V_IOTYPE 			VARCHAR2(10) := CASE WHEN P_WERKS = 'P500' THEN 'N' ELSE P_IOTYPE END;
    --내부변수 처리
    V_DATE              DATE := SYSDATE;
    V_BEF_STR_DATE      DATE; --이전 시작시간
    V_BEF_END_DATE      DATE; --이전 완료시간
    V_BEF_FLAG          INT; --이전 이력 확인 플래그
    V_STR_DTM           VARCHAR2(20); --시작시간 문자열

BEGIN
    --예외처리 시작(try)
    BEGIN
        BEGIN
            --시작일시 조회
            BEGIN
            SELECT P_WRK_DT || STR_TM
              INTO V_STR_DTM 
              FROM TB_MAS027
             WHERE WERKS = P_WERKS
               AND MACH_CD = P_MACH_CD
               AND WRK_METH = P_WRK_TIME;
            --조회된 근무시간이없는 경우 처리
            EXCEPTION WHEN NO_DATA_FOUND THEN  
                V_STR_DTM := 'N/A';
            END;

            --시작일시 등록여부 확인
            IF NVL(V_STR_DTM,'N/A') = 'N/A' THEN
                RS_CODE := 'E';
                RS_MSG  := '설비별 작업시간 정보를 등록하여 주시기 바랍니다.';
                RETURN;
            ELSE 
                V_BEF_STR_DATE := TO_DATE(V_STR_DTM ||'00','YYYYMMDDHH24MISS');
            END IF;

            --기존이력 여부 확인
            SELECT COUNT(STR_DATE)--, ABN_CD 
              INTO V_BEF_FLAG--, V_ABN_CD
              FROM TB_WRK013
             WHERE 1=1
               AND WERKS = P_WERKS
               AND MACH_CD = P_MACH_CD
               AND IN_OUT = V_IOTYPE;
               DBMS_OUTPUT.PUT_LINE(V_BEF_FLAG);
            --기존의 작업자가 투입된 경우 투입자를 변경하여 가동이력 재생성   
            IF V_BEF_FLAG > 0 THEN                    
                -- 작업자 투입현황 수정
                UPDATE TB_WRK013
                   SET WRK_CLASS = P_WRK_CLASS
                     , EMPLY_NO = P_WORKER
                     , WRKER_CNT = V_WORKERCNT
                     , UPDDATE = V_DATE
                     , UPDID = V_USERID
                 WHERE 1=1
                   AND WERKS = P_WERKS
                   AND MACH_CD = P_MACH_CD
                   AND IN_OUT = V_IOTYPE
                   AND STR_DATE = V_BEF_STR_DATE;
                --설비별 가동현황 수정
                UPDATE TB_WRK011
                   SET WRK_CLASS = P_WRK_CLASS
                     , WRK_SHIFT = P_WRK_TIME
                     , EMPLY_NO = P_WORKER
                     , WRKER_CNT = V_WORKERCNT
                     , UPDDATE = V_DATE
                     , UPDID = P_WORKER
                 WHERE 1=1
                   AND WERKS = P_WERKS
                   AND MACH_CD = P_MACH_CD
                   AND IN_OUT = V_IOTYPE;
            ELSE 
                RS_CODE := 'E';
                RS_MSG  := '등록된 투입정보가 없습니다.';
                RETURN;
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
END;

/
