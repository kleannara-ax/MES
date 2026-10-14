--------------------------------------------------------
--  DDL for Procedure SP_POP_WRK03_S04
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK03_S04" 
(
    P_WERKS     		IN VARCHAR2 
    ,P_MACH_CD          IN VARCHAR2
    ,P_PRD_STR_DATE     IN VARCHAR2
    ,P_PRD_END_DATE     IN VARCHAR2
    ,Lang       		IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE     		OUT VARCHAR2 
    ,RS_MSG      		OUT VARCHAR2
)
/*==============================================================================
 * PROGRAM ID    : POP_WRK03
 * PROGRAM NAME  : 비가동 등록
 * VERSION       : 1.0.1
 * DESCRIPTION   : 비가동 사전 밸리데이션 체크.
 *                 
 * AUTHOR NAME   : 이성민
 * CREATE DATE   : 2022/12/06
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 *==============================================================================
 *  관련 테이블
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM        VARCHAR2(100)  := 'SP_POP_WRK03_S04';     -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID   varchar2(20) := 'TEST'; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);
    --파라미터 처리
    V_PRD_STR_DATE		DATE := TO_DATE(P_PRD_STR_DATE, 'YYYY-MM-DD HH24:MI:SS');
    V_PRD_END_DATE		DATE := TO_DATE(P_PRD_END_DATE, 'YYYY-MM-DD HH24:MI:SS');
    --내부 변수 등록
    V_PROC_CD			TB_MAS012.PROC_CD%TYPE;
    
    V_DATE				DATE := SYSDATE;
    V_REC_DATE			VARCHAR2(10) := FN_RECDATE(V_DATE);
    V_PRFM_DATE			VARCHAR2(10) := FN_RECDATE(V_PRD_STR_DATE);
    V_BEF_STR_DATE		DATE; --이전 가동이력 시작시간
    V_DOC_NO			VARCHAR2(29); --MES문서번호
    V_DOC_SEQNO			NUMBER;
    V_WRK_CLASS			VARCHAR2(10);
    V_WRK_SHIFT			VARCHAR2(10);
    V_ABN_TM			NUMBER;
    V_ABN_NM			VARCHAR2(30);
    V_STR_DATE			DATE;
    V_END_DATE			DATE;
    V_RUN_STA			VARCHAR2(10);
    V_RUN_STA_NM		VARCHAR2(30);
    V_MACHINE			VARCHAR2(4);
    V_ORDR_STA			VARCHAR(1); --지시상태
    V_RTN_STA			VARCHAR(1); --복구시 상태
    V_IFMC				VARCHAR2(1);
    V_SAP_WRK_CD		VARCHAR2(20);
    V_TIME_CHK			NUMBER;
    V_TIME_CHK_2		NUMBER := 0;   
    V_IF_ID				VARCHAR2(20) := 'MES_IF_136'; --비가동 등록
    V_SQL				VARCHAR2(4000);
    V_DMY               VARCHAR2(1);    

BEGIN
    --예외처리 시작(try)
    BEGIN
        BEGIN
	        IF SUBSTR(P_PRD_STR_DATE,-2) = '00' THEN
	        	V_PRD_STR_DATE := V_PRD_STR_DATE + (INTERVAL '1' SECOND);
	        END IF;
	        
            -- 비가동 중복여부 확인
            SELECT COUNT(STR_DATE), MIN(STR_DATE), MAX(END_DATE)
              INTO V_TIME_CHK, V_STR_DATE, V_END_DATE
              FROM TB_WRK003
             WHERE 1=1
               AND WERKS = P_WERKS
               AND MACH_CD = P_MACH_CD
               --AND IN_OUT = P_IOTYPE
               AND NVL(CNL_YN, 'N') = 'N'
               AND V_PRD_STR_DATE BETWEEN STR_DATE AND END_DATE;
            --시작시간이 범위에 포함되는 경우
            IF V_TIME_CHK > 0 THEN
                RS_CODE := 'E';
                RS_MSG  := '비가동 시작시간이 이미 비가동 상태입니다.\n아래의 기간 이후로 변경하여 주시기 바랍니다.\n';
                RS_MSG  := RS_MSG || TO_CHAR(V_STR_DATE,'YYYY-MM-DD HH24:MI') || ' ~ ';
                RS_MSG  := RS_MSG || TO_CHAR(V_END_DATE,'YYYY-MM-DD HH24:MI');
                dbms_output.put_line('start time');
                RETURN;
            --완료시간이 입력된 경우 추가확인
            ELSIF LENGTH(P_PRD_END_DATE) > 0 THEN
                SELECT COUNT(STR_DATE), MIN(STR_DATE), MAX(END_DATE)
                  INTO V_TIME_CHK, V_STR_DATE, V_END_DATE
                  FROM TB_WRK003
                 WHERE 1=1
                   AND WERKS = P_WERKS
                   AND MACH_CD = P_MACH_CD
                   --AND IN_OUT = P_IOTYPE
                   AND NVL(CNL_YN, 'N') = 'N'
                   AND V_PRD_END_DATE BETWEEN STR_DATE AND END_DATE;
                  
                IF V_TIME_CHK > 0 THEN
                    RS_CODE := 'E';
                    RS_MSG  := '비가동 완료시간이 이미 비가동 상태입니다.\n아래의 기간 이전으로 변경하여 주시기 바랍니다.\n';
                    RS_MSG  := RS_MSG || TO_CHAR(V_STR_DATE,'YYYY-MM-DD HH24:MI') || ' ~ ';
                    RS_MSG  := RS_MSG || TO_CHAR(V_END_DATE,'YYYY-MM-DD HH24:MI');
                    dbms_output.put_line('end time');
                    RETURN;
                END IF;
               
           		-- 비가동 실적 중복여부 범위 체크
				SELECT COUNT(*), MIN(STR_DATE), MAX(END_DATE)
				INTO V_TIME_CHK_2, V_STR_DATE, V_END_DATE
				FROM TB_WRK003 
				WHERE 1=1
				AND WERKS = P_WERKS
				AND MACH_CD = P_MACH_CD
				AND NVL(CNL_YN, 'N') = 'N'
				AND (STR_DATE BETWEEN V_PRD_END_DATE AND V_PRD_STR_DATE OR
					 END_DATE BETWEEN V_PRD_STR_DATE AND V_PRD_END_DATE)
                  ;

                IF V_TIME_CHK_2 > 0 THEN
               		RS_CODE := 'E';
               		RS_MSG  := '중복되는 비가동 시간이 있습니다. 재등록 해 주세요.\n아래 기간의 비가동실적을 확인바랍니다.\n';
                    RS_MSG  := RS_MSG || TO_CHAR(V_STR_DATE,'YYYY-MM-DD HH24:MI') || ' ~ ';
                    RS_MSG  := RS_MSG || TO_CHAR(V_END_DATE,'YYYY-MM-DD HH24:MI');  
               		RETURN;
            	END IF;	 
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
END SP_POP_WRK03_S04;

/
