--------------------------------------------------------
--  DDL for Procedure SP_POP_WRK21_U01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK21_U01" 
(
    P_WERKS             IN VARCHAR2
    ,P_MACH_CD          IN VARCHAR2 
    ,P_IOTYPE           IN VARCHAR2 
    ,P_USERID           IN VARCHAR2 
    ,P_ORDER_NO         IN VARCHAR2 
    ,P_WRK_ORDR_NO      IN VARCHAR2 
    ,P_WRK_ORDR_SEQNO   IN VARCHAR2 
    ,P_MATNR            IN VARCHAR2 
    ,P_STA              IN VARCHAR2 
    ,P_REGDATE          IN DATE 
    ,Lang               IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE            OUT VARCHAR2 
    ,RS_MSG             OUT VARCHAR2
)
/*==============================================================================
 * PROGRAM ID    : POP_WRK09
 * PROGRAM NAME  : 화장지 가공기 주 작업 화면
 * VERSION       : 1.0.0
 * DESCRIPTION   : 현재 작업지시의 작업시작 및 완료를 처리한다.
 *                 
 * AUTHOR NAME   : 김기연
 * CREATE DATE   : 2022/05/12
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/05/12    1.0.0   김기연         Initial Version
 *==============================================================================
 *  관련 테이블
 * - [TB_SCH012] : (..U.) 화장지 가공기 작업지시
 * - [TB_WRK012] : (C.U.) 작업장별 가동 현황
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM            VARCHAR2(100)  := 'SP_POP_WRK21_U01';     -- PROCEDURE NAME
    V_PLT_CD            VARCHAR2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID      VARCHAR2(20) := P_USERID; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER    EXCEPTION;
    E_SQL_ERR_CD        NUMBER(5) := 0;
    E_SQL_ERR_MSG       VARCHAR2(4000);
    --parameter변수 처리
    V_WRK_ORDR_SEQNO    NUMBER(5,0) := TO_NUMBER(P_WRK_ORDR_SEQNO);
    V_REGDATE           VARCHAR(20) := TO_CHAR(P_REGDATE, 'YYYYMMDDHH24MISS');
    --내부 변수 등록
    V_DATE              DATE := SYSDATE;
    V_WRK_STA           VARCHAR2(1); --작업지시 상태정보
    V_LOTNO             VARCHAR(15);
    V_LOT_TEMP          VARCHAR2(15); --LOT NO 조회
    V_WRK_CNT           NUMBER; --설비별 상태변경이력 확인
    V_PRFM_CNT			NUMBER(5,0); --실적등록확인

BEGIN
    --예외처리 시작(try)
    BEGIN
        BEGIN
            IF P_STA = 'S' THEN
                -- 지시정보 조회
                SELECT USE_YN
                  INTO V_WRK_STA
                  FROM TB_SCH012
                 WHERE 1=1
                   AND WRK_ORDR_NO = P_WRK_ORDR_NO
                   AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO;
                --지시 가용여부 확인
                IF NVL(V_WRK_STA,'Y') = 'N' THEN
                    RS_CODE := 'E';
                    RS_MSG := '삭제 처리된 작업지시입니다.\n별도의 지시를 선택하여 생산을 진행하여 주시기 바랍니다.';
                    RETURN;
                END IF;
                --기존 완료된 이력 조회
                SELECT COUNT(*)
                  INTO V_WRK_CNT
                  FROM TB_WRK012
                 WHERE 1=1
                   AND WERKS = P_WERKS
                   AND MACH_CD = P_MACH_CD
                   AND STR_DATE = P_REGDATE
                   AND END_DATE IS NOT NULL;
                IF V_WRK_CNT > 0 THEN
                    RS_CODE := 'E';
                    RS_MSG  := '기존에 작업이 진행된 시간입니다.\n시작시간을 변경후 등록하여 주시기 바랍니다.';
                    RETURN;
                END IF;
                --실적 등록여부 확인
                SELECT COUNT(*)
                  INTO V_PRFM_CNT
                  FROM TB_WRK001
                 WHERE 1=1
                   AND WERKS = P_WERKS
                   AND MACH_CD = P_MACH_CD 
                   AND WRK_ORDR_NO = P_WRK_ORDR_NO
                   AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
                   AND NVL(CNL_YN,'N') = 'N';
                --LOT번호 부여
                SELECT NVL(LOT_NO,' ') INTO V_LOT_TEMP
                  FROM TB_WRK011
                 WHERE 1=1
                   AND WERKS = P_WERKS
                   AND MACH_CD = P_MACH_CD
                   AND IN_OUT = 'I';
                SP_CHK_LOT_NO (V_LOT_TEMP, P_WERKS, P_MACH_CD, P_MATNR, TO_CHAR(V_DATE,'YYYY-MM-DD HH24:MI:SS'), V_LOTNO);
                -- 작업장 현황 가동처리(Run)
                UPDATE TB_WRK011
                   SET MACH_STA = 'R' 
                     , PRD_STR_DTM = V_REGDATE
                     , LOT_NO = V_LOTNO
                     , UPDDATE = V_DATE
                     , UPDID = P_USERID
                 WHERE 1=1
                   AND WERKS = P_WERKS
                   AND MACH_CD = P_MACH_CD
                   AND IN_OUT = P_IOTYPE;
                --작업장 가동현황 추가(대기->가동)
                UPDATE TB_WRK012
                   SET LINE_STA = 'R'
                     , UPDDATE = V_DATE
                     , UPDID = P_USERID
                 WHERE 1=1
                   AND WERKS = P_WERKS
                   AND MACH_CD = P_MACH_CD
                   AND IN_OUT = P_IOTYPE
                   AND STR_DATE = P_REGDATE
                   AND WRK_ORDR_NO = P_WRK_ORDR_NO
                   AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO;
                IF SQL%ROWCOUNT = 0 THEN
                	IF V_PRFM_CNT = 0 THEN
                		--실적이 없는 경우 해당 이력 덮어쓰기
                		UPDATE TB_WRK012
		                   SET LINE_STA = 'R'
		                     , END_DATE = '' 
		                   	 , WRK_ORDR_NO = P_WRK_ORDR_NO
		                   	 , WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
		                   	 , ORDER_NO = P_ORDER_NO
		                   	 , MATNR = P_MATNR
		                     , UPDDATE = V_DATE
		                     , UPDID = P_USERID
		                 WHERE 1=1
		                   AND WERKS = P_WERKS
		                   AND MACH_CD = P_MACH_CD
		                   AND IN_OUT = P_IOTYPE
		                   AND STR_DATE = P_REGDATE;
		            ELSE
	                    UPDATE TB_WRK012
	                       SET END_DATE = P_REGDATE
	                         , UPDDATE = V_DATE
	                         , UPDID = P_USERID
	                     WHERE 1=1
	                       AND WERKS = P_WERKS
	                       AND MACH_CD = P_MACH_CD
	                       AND IN_OUT = P_IOTYPE
	                       AND WRK_ORDR_NO = P_WRK_ORDR_NO
	                       AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
	                       AND END_DATE IS NULL;
	                    INSERT INTO TB_WRK012 (WERKS, MACH_CD, IN_OUT, STR_DATE, WRK_ORDR_NO, WRK_ORDR_SEQNO, ORDER_NO, MATNR, LINE_STA, BEF_LINE_STA, REGDATE, REGID)
	                                    VALUES(P_WERKS, P_MACH_CD, P_IOTYPE, P_REGDATE, P_WRK_ORDR_NO,V_WRK_ORDR_SEQNO, P_ORDER_NO, P_MATNR, 'R', 'N', V_DATE, P_USERID);
                    END IF;
                END IF;

            ELSE --P_STA = 'E'
                -- 작업장 현황 비가동처리(Stop)
                UPDATE TB_WRK011
                   SET MACH_STA = 'S'
                     , UPDDATE = V_DATE
                     , UPDID = P_USERID
                 WHERE 1=1
                   AND WERKS = P_WERKS
                   AND MACH_CD = P_MACH_CD
                   AND IN_OUT = P_IOTYPE;
                --작업장 가동현황 수정
                UPDATE TB_WRK012
                   SET END_DATE = P_REGDATE
                     , LINE_STA = 'S'
                     , UPDDATE = V_DATE
                     , UPDID = P_USERID
                 WHERE 1=1
                   AND WERKS = P_WERKS
                   AND MACH_CD = P_MACH_CD
                   AND IN_OUT = P_IOTYPE
                   AND WRK_ORDR_NO = P_WRK_ORDR_NO
                   AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
                   AND END_DATE IS NULL;

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
END SP_POP_WRK21_U01;

/
