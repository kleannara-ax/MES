
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK52_U01" SP_POP_WRK52_U01
(
    P_WERKS                 IN VARCHAR2
    ,P_MACH_CD              IN VARCHAR2 
    ,P_IOTYPE               IN VARCHAR2 
    ,P_USERID               IN VARCHAR2
    ,P_ORDER_NO             IN VARCHAR2 
    ,P_WRK_ORDR_NO          IN VARCHAR2 
    ,P_WRK_ORDR_SEQNO       IN VARCHAR2 
    ,P_PRD_STR_DATE         IN VARCHAR2
    ,P_PRD_END_DATE         IN VARCHAR2
    ,P_NEW_ORDER_NO         IN VARCHAR2
    ,P_NEW_WRK_ORDR_NO      IN VARCHAR2 
    ,P_NEW_WRK_ORDR_SEQNO   IN VARCHAR2 
    ,P_NEW_PRD_STR_DATE     IN VARCHAR2
    ,P_MATNR                IN VARCHAR2
    ,P_NEW_MATNR            IN VARCHAR2
    ,P_PROC_CD              IN VARCHAR2
    ,P_SEQ_NO               IN VARCHAR2
    ,P_CHIN_WRK_ORDR_NO     IN VARCHAR2
    ,P_ORDER_DOC            OUT VARCHAR2 
    ,P_WRK_FUNC             OUT VARCHAR2
    ,Lang                   IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE                OUT VARCHAR2 
    ,RS_MSG                 OUT VARCHAR2
    ,CUR_1                  OUT SYS_REFCURSOR
    ,CUR_2                  OUT SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : POP_WRK52
 * PROGRAM NAME  : HL 작업지시 변경
 * VERSION       : 1.0.0
 * DESCRIPTION   : 진행중인 작업지시를 변경한다.
 *                 
 * AUTHOR NAME   : 백우종
 * CREATE DATE   : 2023/01/25
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 
 *==============================================================================
 *  관련 테이블
 * - [TB_WRK011] : (C.U.) 작업장 현황
 * - [TB_WRK012] : (C.U.) 작업장 가동현황
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM         VARCHAR2(100)  := 'SP_POP_WRK52_U01';     -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := P_PROC_CD;
    V_SESS_USER_ID   varchar2(20) := P_USERID; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);
    --parameter변수 처리
    V_WRK_ORDR_SEQNO        NUMBER(5,0) := TO_NUMBER(P_WRK_ORDR_SEQNO);
    V_PRD_STR_DATE          DATE := TO_DATE(P_PRD_STR_DATE, 'yyyy-MM-dd HH24:mi:ss');
    V_PRD_END_DATE          DATE := TO_DATE(P_PRD_END_DATE, 'yyyy-MM-dd HH24:mi:ss');
    V_NEW_WRK_ORDR_SEQNO    NUMBER(5,0) := TO_NUMBER(P_NEW_WRK_ORDR_SEQNO);
    V_NEW_PRD_STR_DATE      DATE := TO_DATE(P_NEW_PRD_STR_DATE, 'yyyy-MM-dd HH24:mi:ss');
    V_IOTYPE				VARCHAR2(10) := CASE WHEN P_WERKS = 'P500' THEN 'N' ELSE P_IOTYPE END;
    --내부 변수 등록
    V_DATE                  DATE := SYSDATE;
    V_WRK_CLASS             VARCHAR2(10); --작업반
    V_WRK_SHIFT             VARCHAR2(10); --작업조
    V_EMPLY_NO              VARCHAR2(10); --메인작업자
    V_WRKER_CNT             NUMBER(5,0); --작업인원수
    V_NOW_LOT               VARCHAR2(15); --이전 선택된 지시(기저귀)
    V_NOW_STA               VARCHAR2(10); --이전 지시 상태
    V_BEF_LOT               VARCHAR2(15); --이전 작업중 지시 상태
    V_HIND_BCD              VARCHAR2(20); --투입된 자재 바코드(합지)
    V_PRFM_DT               VARCHAR2(8); --실적일자
    V_PRD_DT                VARCHAR2(8); --생산일자
    V_SAP_WRK_CD            VARCHAR(20); --SAP작업장코드
    V_MACHINE               VARCHAR2(5); --생산호기
    V_HMACHINE              VARCHAR2(10); --합지생산호기
    V_HMATNR                VARCHAR(20); --합지품목
    V_HUNIT                 VARCHAR(10); --합지단위
    V_HLOTNO1               VARCHAR2(10); --합지LOT1
    V_INPQT1                VARCHAR2(10); --합지수량1
    V_HLOTNO2               VARCHAR2(10); --합지LOT2
    V_INPQT2                VARCHAR2(10); --합지수량2
    V_HLOTNO3               VARCHAR2(10); --합지LOT3
    V_INPQT3                VARCHAR2(10); --합지수량3
    V_RUNTIME               VARCHAR2(8); --가동시간(분)
    V_RUN_TM                NUMBER; --가동 시간
    V_ABN_TM                NUMBER; --비가동 시간
    V_UNIT                  VARCHAR2(10);
    V_DOC_NO                VARCHAR2(29); --실적등록 문서번호
    V_DOC_SEQ               VARCHAR2(6);
    V_COMP_CNT              NUMBER; --지시 생산 완료여부
    V_SAP_CNT               NUMBER; --SAP전송 완료여부
    V_WRK_CNT               NUMBER; --설비별 상태변경이력 확인
    V_ORDR_END_DATE         DATE;--오더 완료 시간
    V_PUPOS                 VARCHAR2(1);
    V_PRE_WRK_ORDR_NO       VARCHAR2(20); 
    V_PRE_WRK_ORDR_SEQNO    NUMBER;
    V_OIF_ID VARCHAR2(20); --MES IF ID
    V_SQL_O VARCHAR2(4000);

BEGIN
    --예외처리 시작(try)
    BEGIN
	    IF P_SEQ_NO = '1'	THEN
	        --투입된 작업자 정보 조회
	        BEGIN
	        SELECT WRK_SHIFT, EMPLY_NO, WRKER_CNT
	          INTO V_WRK_SHIFT, V_EMPLY_NO, V_WRKER_CNT
	          FROM TB_WRK013
	         WHERE ROWNUM <= 1
	           AND WERKS = P_WERKS
	           AND MACH_CD = P_MACH_CD
	           AND IN_OUT = V_IOTYPE
	           --AND END_DATE IS NULL
	         ORDER BY STR_DATE DESC;
	        EXCEPTION WHEN NO_DATA_FOUND THEN 
	            RS_CODE := 'E';
	            RS_MSG  := '작업자 현황을 확인하여 주시기 바랍니다.';
	            RETURN;
	        END;
	
	        --상태에 따른 이전 문서 확인
	        BEGIN
	            SELECT CASE WHEN MACH_STA = 'N' THEN PRE_WRK_ORDR_NO ELSE WRK_ORDR_NO END,
	                   CASE WHEN MACH_STA = 'N' THEN PRE_WRK_ORDR_SEQNO ELSE WRK_ORDR_SEQNO END
	                   INTO V_PRE_WRK_ORDR_NO, V_PRE_WRK_ORDR_SEQNO
	              FROM TB_WRK011
	             WHERE MACH_CD = P_MACH_CD
	               AND IN_OUT = V_IOTYPE;
	        EXCEPTION 
	            WHEN NO_DATA_FOUND THEN NULL;
	        END;
	
	        --포장기 처리시 가공기 LOT확인
	        BEGIN
	            SELECT LOT_NO, MACH_STA
	              INTO V_NOW_LOT, V_NOW_STA
	              FROM TB_WRK011
	             WHERE 1=1
	               AND WERKS = P_WERKS
	               AND MACH_CD = P_MACH_CD
	               AND WRK_ORDR_NO = P_NEW_WRK_ORDR_NO
	               AND WRK_ORDR_SEQNO = V_NEW_WRK_ORDR_SEQNO
	               AND IN_OUT != 'O';
	        EXCEPTION WHEN NO_DATA_FOUND THEN 
	            V_NOW_LOT := '';
	            V_NOW_STA := '';
	        END;
	        --현재 작업장 정보 조회
	        SELECT LOT_NO
	          INTO V_BEF_LOT
	          FROM TB_WRK011
	         WHERE 1=1
	           AND WERKS = P_WERKS
	           AND MACH_CD = P_MACH_CD
	           AND IN_OUT = V_IOTYPE;
	        --자재정보
	        BEGIN
	            SELECT UNIT
	              INTO V_UNIT
	              FROM TB_MAS001
	             WHERE 1=1
	               AND WERKS = P_WERKS
	               AND MATNR = P_MATNR;
	        EXCEPTION WHEN NO_DATA_FOUND THEN
	            V_UNIT := '';
	        END;
	        --설비정보 조회
	        SELECT MACHINE, SAP_WRK_CD
	          INTO V_MACHINE, V_SAP_WRK_CD
	          FROM TB_MAS012
	         WHERE 1=1
	           AND MACH_CD = P_MACH_CD;   
	        --작업자 정보 조회
	        BEGIN
	            SELECT WRK_CLASS
	              INTO V_WRK_CLASS
	              FROM USRMA
	             WHERE 1=1
	               AND USERID = V_EMPLY_NO;
	        EXCEPTION WHEN NO_DATA_FOUND THEN 
	            RS_CODE := 'E';
	            RS_MSG  := '작업자 정보를 확인하여 주시기 바랍니다.';
	            RETURN;
	        END;
	
	        --가동시간
	        V_RUN_TM := (V_PRD_END_DATE-V_PRD_STR_DATE)*24*60;
	        --비가동 시간 합계
	        SELECT NVL((SUM(END_DATE - STR_DATE)*24*60),0)
	          INTO V_ABN_TM
	          FROM TB_WRK003 --비가동 이력
	         WHERE 1=1
	           AND WERKS = P_WERKS
	           AND MACH_CD = P_MACH_CD
	           AND IN_OUT != 'O'
	           AND WRK_ORDR_NO = P_WRK_ORDR_NO
	           AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
	           AND END_DATE IS NOT NULL;
	        V_RUNTIME := CEIL(V_RUN_TM - V_ABN_TM);
	
	        -- 작업장 현황관리 신규 지시 등록
	        UPDATE TB_WRK011
	           SET MATNR = P_NEW_MATNR
	             , WRK_ORDR_NO = P_NEW_WRK_ORDR_NO
	             , WRK_ORDR_SEQNO = V_NEW_WRK_ORDR_SEQNO
	             , PRE_WRK_ORDR_NO =  V_PRE_WRK_ORDR_NO --P_WRK_ORDR_NO
	             , PRE_WRK_ORDR_SEQNO = V_PRE_WRK_ORDR_SEQNO --V_WRK_ORDR_SEQNO
	             , PRD_STR_DTM = TO_CHAR(V_NEW_PRD_STR_DATE,'YYYYMMDDHH24MISS')
	             , ORDER_NO = P_NEW_ORDER_NO
	             , LOT_NO = V_NOW_LOT
	             , MACH_STA = CASE WHEN P_WERKS = 'P500' 
	                               THEN NVL(V_NOW_STA,'N') ELSE 'N' END 
	             , UPDDATE = V_DATE
	             , UPDID = P_USERID
	         WHERE 1=1
	           AND WERKS = P_WERKS
	           AND MACH_CD = P_MACH_CD
	           --AND IN_OUT LIKE CASE WHEN P_WERKS = 'P500' THEN '' ELSE P_IOTYPE END || '%';
	           AND IN_OUT = V_IOTYPE;
	        --설비에 이력이 없는 경우 신규 생성
	        IF SQL%ROWCOUNT = 0 THEN
	            INSERT INTO TB_WRK011 (WERKS, MACH_CD, IN_OUT, MATNR, 
	                                    WRK_ORDR_NO, WRK_ORDR_SEQNO, ORDER_NO, MACH_STA, 
	                                    WRK_CLASS, WRK_SHIFT, EMPLY_NO, WRKER_CNT,
	                                    REGDATE, REGID)
	                            VALUES(P_WERKS, P_MACH_CD, V_IOTYPE, P_NEW_MATNR, 
	                                    P_NEW_WRK_ORDR_NO,V_NEW_WRK_ORDR_SEQNO, P_NEW_ORDER_NO, 'N', 
	                                    V_WRK_CLASS, V_WRK_SHIFT, V_EMPLY_NO, V_WRKER_CNT,
	                                    V_DATE, P_USERID);
	        END IF;     
	        --기존 작업장 가동현황 수정(시작/완료시간 변경 가능:완료되지 않은 가동현황수정)
	        --기존 완료된 이력 조회
	        SELECT COUNT(*)
	          INTO V_WRK_CNT
	          FROM TB_WRK012
	         WHERE 1=1
	           AND WERKS = P_WERKS
	           AND MACH_CD = P_MACH_CD
	           AND STR_DATE = V_NEW_PRD_STR_DATE
	           AND END_DATE IS NOT NULL;
	        IF V_WRK_CNT > 0 THEN
	            RS_CODE := 'E';
	            RS_MSG  := '기존에 작업이 진행된 시간입니다.\n시작시간을 변경후 등록하여 주시기 바랍니다.';
	            RETURN;
	        END IF;
	        --이전 가동 현황중 미완료 항목 완료처리
	        UPDATE TB_WRK012
	           SET END_DATE = V_PRD_END_DATE
	             , UPDDATE = V_DATE
	             , UPDID = P_USERID
	         WHERE 1=1
	           AND WERKS = P_WERKS
	           AND MACH_CD = P_MACH_CD
	           AND IN_OUT = V_IOTYPE --LIKE CASE WHEN P_WERKS = 'P500' THEN '' ELSE P_IOTYPE END || '%'
	           AND STR_DATE < V_NEW_PRD_STR_DATE
	           AND END_DATE IS NULL;
	        --신규 가동 현황 등록(대기중인 경우 가동현황 미등록)
	        UPDATE TB_WRK012
	           SET WRK_ORDR_NO = P_NEW_WRK_ORDR_NO
	             , WRK_ORDR_SEQNO = V_NEW_WRK_ORDR_SEQNO
	             , ORDER_NO = P_NEW_ORDER_NO
	             , MATNR = P_MATNR
	             , LINE_STA = 'N'
	             , RMK = '품목변경'
	             , UPDDATE = V_DATE
	             , UPDID = P_USERID
	         WHERE 1=1
	           AND WERKS = P_WERKS
	           AND MACH_CD = P_MACH_CD
	           AND STR_DATE = V_NEW_PRD_STR_DATE
	           AND END_DATE IS NULL;
	        IF SQL%ROWCOUNT = 0 THEN
	            INSERT INTO TB_WRK012 (WERKS, MACH_CD, IN_OUT, STR_DATE, 
	                                   WRK_ORDR_NO, WRK_ORDR_SEQNO, ORDER_NO, 
	                                   MATNR, LINE_STA, 
	                                   REGDATE, REGID, RMK)
	                            VALUES(P_WERKS, P_MACH_CD, V_IOTYPE, V_NEW_PRD_STR_DATE, 
	                                   P_NEW_WRK_ORDR_NO,V_NEW_WRK_ORDR_SEQNO, P_NEW_ORDER_NO, 
	                                   P_MATNR, 'N', 
	                                   V_DATE, P_USERID, '품목변경');   
	        END IF;
	        --투입된 작업자 정보 변경
	        UPDATE TB_WRK013
	           SET WRK_ORDR_NO = P_NEW_WRK_ORDR_NO
	             , WRK_ORDR_SEQNO = V_NEW_WRK_ORDR_SEQNO
	             , UPDDATE = V_DATE
	             , UPDID = P_USERID
	         WHERE 1=1
	           AND WERKS = P_WERKS
	           AND MACH_CD = P_MACH_CD
	           AND IN_OUT = V_IOTYPE --LIKE CASE WHEN P_WERKS = 'P500' THEN '' ELSE P_IOTYPE END || '%'
	           AND STR_DATE = V_NEW_PRD_STR_DATE
	           AND END_DATE IS NULL;

			-- 작업지시 테이블 연결고리 UPDATE
	        UPDATE	TB_SCH011
		        SET	WRK_ORDR_RMK = P_CHIN_WRK_ORDR_NO
	             , UPDDATE = V_DATE
	             , UPDID = P_USERID
		    WHERE 1=1
		    	AND WRK_ORDR_NO = P_NEW_WRK_ORDR_NO
	            AND WRK_ORDR_SEQNO = V_NEW_WRK_ORDR_SEQNO;
	    ELSE
			-- P_SEQ_NO가 1이 아닌 경우는 작업지시 테이블의 연결고리 컬럼만 Update		          
			-- 작업지시 테이블 연결고리 UPDATE
	        UPDATE	TB_SCH011
		        SET	WRK_ORDR_RMK = P_CHIN_WRK_ORDR_NO
	             , UPDDATE = V_DATE
	             , UPDID = P_USERID
		    WHERE 1=1
		    	AND WRK_ORDR_NO = P_NEW_WRK_ORDR_NO
	            AND WRK_ORDR_SEQNO = V_NEW_WRK_ORDR_SEQNO;
	    END IF;

        --작업 정상 종료 코드 등록
        RS_CODE := 'S';
        RS_MSG := '1';
        --ROLLBACK;
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
END ;
/
