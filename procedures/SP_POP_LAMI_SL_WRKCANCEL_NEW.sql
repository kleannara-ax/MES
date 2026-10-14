
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_LAMI_SL_WRKCANCEL_NEW" SP_POP_LAMI_SL_WRKCANCEL_NEW
(
    P_WERKS     		IN VARCHAR2 	                --플랜트
    ,P_MACH_CD   		IN VARCHAR2 	                --설비코드
    ,P_WRK_ORDR_NO      IN VARCHAR2                     --작업지시번호
    ,P_WRK_ORDR_SEQNO   IN VARCHAR2                     --작업지시번호SEQ
    ,P_IND_BCD			IN VARCHAR2						--개별바코드
    ,P_CLN_RMK		    IN VARCHAR2  DEFAULT NULL                   --취소사유
    ,Lang       		IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE     		OUT VARCHAR2 
    ,RS_MSG      		OUT VARCHAR2
    
)
/*==============================================================================
 * PROGRAM ID    : WRK073
 * PROGRAM NAME  : 슬리팅 ROLLBACK
 * VERSION       : 1.0.0
 * DESCRIPTION   : 슬리팅 ROLLBACK을 하기 위한 SP.
 *                 
 * AUTHOR NAME   : 김수현
 * CREATE DATE   : 2022/11/17
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/05/10    1.0.0   김수현         Initial Version
 *==============================================================================
 *  관련 테이블
 * - [TB_LAMI_PC] : (.R..) 인쇄/코팅 작업지시
 *=============================================================================*/
AS 
    --프로그램 ID : 점보롤 작업시작
    V_PRG_NM        VARCHAR2(100)  := 'SP_POP_LAMI_SL_WRKCANCEL_NEW';     -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID   varchar2(20) := 'TEST'; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);
    --parameter변수 처리

    V_MATNR                     TB_WRK002.MATNR%TYPE;
    V_SAP_WRK_CD        TB_MAS012.SAP_WRK_CD%TYPE;
    V_CNT1                       NUMBER(13,0);
    V_CNT2                       NUMBER(13,0);
    V_CNT3                       NUMBER(13,0);
    V_CNT4                       NUMBER(13,0);
    V_ORDER_NO                  VARCHAR2(20);
    V_REGDATE                   DATE := SYSDATE;
    V_DOC_NO                    VARCHAR2(20);
    V_USE_YN                    CHAR(1);
    V_COMP_YN                   CHAR(1);
    V_REMAIN_QTY                NUMBER(13,0);
    V_IND_BCD                   VARCHAR2(20);
    V_LOT_NO                    VARCHAR2(20);
    V_REGID                    VARCHAR2(30);
    V_ORDER_QTY                 NUMBER(13,0);
    V_LOT_NO_M                 VARCHAR2(20);
    V_MATNR_M           TB_WRK004.MATNR%TYPE;        --자재코드
    V_INP_DT	        TB_INV003.INP_DT%TYPE;        --투입일자
    V_SDOC_NO           TB_WRK002.SDOC_NO%TYPE;
    V_SDOC_SEQNO        TB_WRK002.SDOC_SEQNO%TYPE;
    V_IND_BCD_M         TB_WRK002.IND_BCD%TYPE;       --자재개별바코드
    V_PRFM_QTY          TB_WRK002.PRFM_QTY%TYPE;       --자재개별바코드
    V_TM				TB_WRK002.TM%TYPE;				--생산시간
    V_RUN_STA           VARCHAR2(5);
    V_EXPROD            VARCHAR2(5);
    V_STA               TB_WRK002.STA%TYPE;
    V_SALWEIGHT         NUMBER(13,0);
    V_SQL               VARCHAR2(4000);
    V_DOC_NO_INPUT      VARCHAR2(20);
    V_DOC_SEQNO_INPUT   NUMBER;
    V_DOC_SEQNO         NUMBER;
    V_PRFM_DT           VARCHAR2(8);
    V_PRD_STR_DTM       VARCHAR2(20);
    V_WRK_ORDR_NO       VARCHAR2(30);
    V_WRK_ORDR_SEQNO    VARCHAR2(10);
    V_STCK_QTY          NUMBER(10,0);
    V_WERKS             VARCHAR2(10);
    V_MACH_CD           VARCHAR2(10);
    
    V_CNT				NUMBER;
    V_MAX_SEQ			NUMBER;

	C_WERKS				TB_WRK002.WERKS%TYPE;
	C_MACH_CD			TB_WRK002.MACH_CD%TYPE;
	C_MATNR				TB_WRK002.MATNR%TYPE;
	C_IND_BCD			TB_WRK002.IND_BCD%TYPE;
	C_SEQNO				TB_INV010.SEQNO%TYPE;
	C_MATNR_M			TB_INV010.MATNR_M%TYPE;
	C_LOT_NO_M			TB_INV010.LOT_NO_M%TYPE;
	C_IND_BCD_M			TB_INV010.IND_BCD_M%TYPE;
	C_USE_QTY			TB_INV010.USE_QTY%TYPE;
	C_WRK_ORDR_NO		TB_WRK002.WRK_ORDR_NO%TYPE;
	C_WRK_ORDR_SEQNO	TB_WRK002.WRK_ORDR_SEQNO%TYPE;

	CURSOR  CUR_INV010 IS
		SELECT	WERKS, MACH_CD, MATNR, IND_BCD, SEQNO, MATNR_M, LOT_NO_M, IND_BCD_M, USE_QTY, WRK_ORDR_NO, WRK_ORDR_SEQNO
		FROM	TB_INV010
		WHERE	WERKS = P_WERKS
		AND 	MACH_CD = P_MACH_CD
		AND 	WRK_ORDR_NO = P_WRK_ORDR_NO
		AND 	WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
		AND 	IND_BCD = P_IND_BCD
		AND		NVL(CNL_YN, 'N') = 'N'
		ORDER BY SEQNO;
BEGIN

    BEGIN
		SELECT	LOT_NO, IND_BCD, SDOC_NO, SDOC_SEQNO, PRFM_DT, PRFM_QTY, TM
			INTO	V_LOT_NO, V_IND_BCD, V_SDOC_NO, V_SDOC_SEQNO, V_PRFM_DT, V_PRFM_QTY, V_TM
		FROM	TB_WRK002
		WHERE	IND_BCD = P_IND_BCD;
		
		-- LOT 추적 테이블 취소 처리
        DELETE FROM TB_WRK008 WHERE WERKS = P_WERKS AND MACH_CD = P_MACH_CD AND IND_BCD = V_IND_BCD; --LOT 추적(DELETE)

		-- 실적 테이블 취소 처리
		UPDATE TB_WRK002     --실적테이블(PS)
			SET CNL_YN  = 'Y'
			   ,CNL_RMK = P_CLN_RMK
			   ,UPDDATE = SYSDATE
			   ,PRFM_GTHR_YN  = 'N'
			   ,UPDID   = V_REGID
		 WHERE WERKS   = P_WERKS
			AND MACH_CD = P_MACH_CD
			AND WRK_ORDR_NO = P_WRK_ORDR_NO
			AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
			AND IND_BCD = V_IND_BCD;

		-- 문서이력 테이블 취소 처리
		UPDATE  TB_WRK021
			SET CNL_YN = 'Y'
		WHERE WERKS   = P_WERKS
			AND MACH_CD = P_MACH_CD
			AND WRK_ORDR_NO = P_WRK_ORDR_NO
			AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
			AND IND_BCD = V_IND_BCD
			AND DOC_DIV = '1';

		-- 공정재고 테이블 취소 처리
		UPDATE TB_INV001
			SET STCK_QTY = 0,
				DLFL = 'Y',
				UPDDATE = SYSDATE,
				UPDID   = V_REGID
		WHERE WERKS = P_WERKS
			AND MACH_CD = P_MACH_CD
			AND WRK_ORDR_NO = P_WRK_ORDR_NO
			AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
			AND IND_BCD = V_IND_BCD;

DBMS_OUTPUT.PUT_LINE('P_WERKS = ' || P_WERKS);
DBMS_OUTPUT.PUT_LINE('P_MACH_CD = ' || P_MACH_CD);
DBMS_OUTPUT.PUT_LINE('P_WRK_ORDR_NO = ' || P_WRK_ORDR_NO);
DBMS_OUTPUT.PUT_LINE('P_WRK_ORDR_SEQNO = ' || P_WRK_ORDR_SEQNO);
DBMS_OUTPUT.PUT_LINE('P_IND_BCD = ' || P_IND_BCD);

		-- TB_INV003 재고 복원 시작
		BEGIN
			OPEN	CUR_INV010;
			LOOP
	            FETCH CUR_INV010 INTO C_WERKS, C_MACH_CD, C_MATNR, C_IND_BCD, C_SEQNO, C_MATNR_M, C_LOT_NO_M, C_IND_BCD_M, C_USE_QTY, C_WRK_ORDR_NO, C_WRK_ORDR_SEQNO;
		
			EXIT	WHEN	CUR_INV010 %NOTFOUND;
			    BEGIN
				    SELECT	COUNT(*)	INTO	V_CNT
				    FROM	TB_INV003
				    WHERE	WERKS = C_WERKS
				    AND		MACH_CD = C_MACH_CD
				    AND		IND_BCD = C_IND_BCD_M;
				END;
DBMS_OUTPUT.PUT_LINE('V_CNT = ' || V_CNT);
		    
		    	IF	V_CNT = 1	THEN
		    		UPDATE	TB_INV003
		    			SET STCK_QTY = STCK_QTY + C_USE_QTY
		    				, USE_QTY = USE_QTY - C_USE_QTY
		    				, UPDDATE = SYSDATE
				    WHERE	WERKS = C_WERKS
				    AND		MACH_CD = C_MACH_CD
				    AND		IND_BCD = C_IND_BCD_M;
		    	ELSIF	V_CNT = 0	THEN
		    		INSERT INTO TB_INV003 (WERKS, MACH_CD, MATNR, IND_BCD, SEQNO, WRK_ORDR_NO, WRK_ORDR_SEQNO, LOT_NO, INP_DT, IN_QTY, USE_QTY, STCK_QTY, UNIT, ROLLCNT, WGT, CHG_FLG, REGDATE, REGID, PRE_IN_QTY)
						SELECT	WERKS, MACH_CD, MATNR, IND_BCD, SEQNO, WRK_ORDR_NO, WRK_ORDR_SEQNO, LOT_NO, SYSDATE INP_DT, C_USE_QTY, 0, C_USE_QTY, UNIT, 0, C_USE_QTY, 'N', SYSDATE REGDATE, 'wjbaek' REGID, C_USE_QTY
						FROM	TB_INV010
						WHERE	WERKS = C_WERKS
					    AND		MACH_CD = C_MACH_CD
					    AND		WRK_ORDR_NO = C_WRK_ORDR_NO
					    AND		WRK_ORDR_SEQNO = C_WRK_ORDR_SEQNO
					    AND		MATNR = C_MATNR
					    AND		IND_BCD = C_IND_BCD
		    			AND		SEQNO	= C_SEQNO;
		    	ELSE
		    		SELECT	NVL(MAX(SEQNO), 0)	INTO	V_MAX_SEQ
		    		FROM	TB_INV003
				    WHERE	WERKS = C_WERKS
				    AND		MACH_CD = C_MACH_CD
				    AND		IND_BCD = C_IND_BCD_M;
		
		    		UPDATE	TB_INV003
		    			SET STCK_QTY = STCK_QTY + C_USE_QTY
		    				, USE_QTY = USE_QTY - C_USE_QTY
		    				, UPDDATE = SYSDATE
				    WHERE	WERKS = C_WERKS
				    AND		MACH_CD = C_MACH_CD
				    AND		IND_BCD = C_IND_BCD_M
		    		AND		SEQNO = V_MAX_SEQ;
		    	END IF;
			END LOOP;
	        CLOSE CUR_INV010;
		END;
		-- TB_INV003 재고 복원 끝

		-- 사용이력 테이블 데이터 취소처리
		UPDATE TB_INV010
			SET CNL_YN = 'Y',
				CNL_RMK = P_CLN_RMK
		WHERE 	WERKS = P_WERKS
		AND 	MACH_CD = P_MACH_CD
		AND 	WRK_ORDR_NO = P_WRK_ORDR_NO
		AND 	WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
		AND 	IND_BCD = P_IND_BCD;
		
		-- 작업지시 테이블 데이터 업데이트
		UPDATE TB_LAMI_SL
		   SET LOT_BUF = ''
		      ,PRFM_QTY = PRFM_QTY - V_PRFM_QTY				-- 실적수량
		      ,CYCLE_TIME = CYCLE_TIME + TO_NUMBER(V_TM)	-- 생산시간
		      ,SAPYN = 'N'									-- SAP I/F 여부
		      ,PPCODE = ''									-- 지종코드
		      ,HEIGHT = 0									-- 길이
		      ,EQUIL = 0									-- 평량
		      ,STD = 0										-- 규격
		      ,USE_YN = 'Y'									-- 사용여부
		      ,COMP_YN = 'I'								-- 완료여부
		      ,REMAIN_QTY = REMAIN_QTY + V_PRFM_QTY			-- 잔량
		      ,PRD_END_DTM = ''								-- 생산종료일시
		      ,PRD_END_DT = ''								-- 생산종료일자
		 WHERE WRK_ORDR_NO = P_WRK_ORDR_NO  
		   AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
		   AND WERKS = P_WERKS;

        RS_CODE := 'S';
        RS_MSG  := '실적완료를 ROLLBACK 했습니다.';
        COMMIT;      
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
        E_SQL_ERR_CD        := '-20000';  --SQLCODE;
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
