--------------------------------------------------------
--  DDL for Procedure SP_WRK51_S01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_WRK51_S01" (
	P_TYPE           IN    VARCHAR2, -- LIST
	P_JSON_STR       IN    CLOB, 
	P_SUCCESS       OUT    VARCHAR2, 
	P_RS_LIST	    OUT    SYS_REFCURSOR  
)
/*==============================================================================
 * PROGRAM ID    : SP_WRK51_S01
 * PROGRAM NAME  : 저장위치별 재고추적(MES vs SAP)
 * VERSION       : 1.0.0
 * DESCRIPTION   : 저장위치별 재고추적(MES vs SAP)
 *                 
 * AUTHOR NAME   : 김성하
 * CREATE DATE   : 2022/11/12
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}	<생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}		<생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}			<생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}	<생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/11/12    1.0.0   김성하         Initial Version 
 *==============================================================================
 *  관련 테이블
 *=============================================================================*/
AS

  V_PRG_NM          	VARCHAR2(100) 	:= 'SP_WRK51_S01';     -- PROCEDURE NAME

  -- 오라클 에러 처리용 변수선언 영역
  E_EXCEPTION_USER  	EXCEPTION;
  E_SQL_ERR_CD      	NUMBER(5) 		:= 0;
  E_SQL_ERR_MSG		    VARCHAR2(4000);

  -- JSON을 위한 변수선언 영역
  V_JSON		      JSON_OBJECT_T;
  V_ARR_LIST       	  JSON_ARRAY_T;
  V_OBJ            	  JSON_OBJECT_T;

	-- 세션값 처리용 변수선언 영역
  V_SESS_USER_ID   	  varchar2(20);
  V_PLT_CD         	  varchar2(2);
  V_DEBUG          	  varchar2(1);

	-- 조건절 처리용 변수선언 영역	
  V_SQL				CLOB;

  V_WERKS        	TB_INV001.WERKS%TYPE;					                            --플랜트코드	
  V_STOR_LOC_CD   	TB_INV001.STOR_LOC_CD%TYPE;				                            --저장위치	
  V_MATNR        	TB_INV001.MATNR%TYPE;					                            --제품코드	
  V_LOT_NO        	TB_INV001.LOT_NO%TYPE;					                            --LOTNO	
  V_IND_BCD         VARCHAR(15);

BEGIN
	OPEN P_RS_LIST FOR 
	SELECT NULL FROM DUAL WHERE ROWNUM = 0;

	V_JSON 		    := JSON_OBJECT_T.parse(P_JSON_STR);

	V_SESS_USER_ID	:= V_JSON.get_string('SES_USER_ID');
	V_PLT_CD		:= V_JSON.get_string('SES_PLNTKY');

	V_WERKS			:= V_JSON.get_string('WERKS');			     -- 플랜트코드(필수)	
    V_LOT_NO  	    := V_JSON.get_string('LOT_NO');	             -- LOT_NO (선택)
    V_IND_BCD	    := V_JSON.get_string('IND_BCD');	         -- 개별바코드 (선택)
    V_MATNR  	    := V_JSON.get_string('MATNR');	             -- 개별바코드 (선택)

	IF P_TYPE = 'LIST' THEN
          -- MES(2000), SAP(2000), MES(2500), SAP(2500),...
          V_SQL := '
                    SELECT WERKS, LOT_NO, MATNR, UNIT, SUM(CNT) PRFM_CNT, SUM(PRFM_QTY) PRFM_QTY,
                           SUM(DECODE(STOR_LOC_CD, ''2000'', STCK_QTY, 0)) M_2000, SUM(DECODE(STOR_LOC_CD,''2000'', STQTY, 0)) S_2000, 
                           SUM(DECODE(STOR_LOC_CD, ''2500'', STCK_QTY, 0)) M_2500, SUM(DECODE(STOR_LOC_CD,''2500'', STQTY, 0)) S_2500,
                           SUM(DECODE(STOR_LOC_CD, ''2700'', STCK_QTY, 0)) M_2700, SUM(DECODE(STOR_LOC_CD,''2700'', STQTY, 0)) S_2700,
                           SUM(DECODE(STOR_LOC_CD, ''2600'', STCK_QTY, 0)) M_2600, SUM(DECODE(STOR_LOC_CD,''2600'', STQTY, 0)) S_2600, 
                           SUM(DECODE(STOR_LOC_CD, ''3100'', STCK_QTY, 0)) M_3100, SUM(DECODE(STOR_LOC_CD,''3100'', STQTY, 0)) S_3100, 
                           SUM(PRFM_70) M_3000, SUM(DECODE(STOR_LOC_CD,''3000'', STQTY, 0)) S_3000
                    FROM (
                          SELECT A.WERKS, A.LOT_NO, A.MATNR, A.UNIT, A.STOR_LOC_CD, A.CNT, A.PRFM_QTY, A.STCK_QTY, A.PRFM_70, B.STQTY
                            FROM (SELECT  A.WERKS,  A.LOT_NO, A.MATNR, A.UNIT, DECODE(B.STCK_STA, ''70'', ''3000'', B.STOR_LOC_CD) STOR_LOC_CD, COUNT(*) CNT, SUM(A.PRFM_QTY) PRFM_QTY, SUM(DECODE(B.STCK_STA, ''70'', A.PRFM_QTY, 0)) PRFM_70 , SUM(B.STCK_QTY) STCK_QTY
                                    FROM  TB_WRK002 A, TB_INV001 B
                                   WHERE  A.WERKS   = B.WERKS
                                     AND  A.LOT_NO  = B.LOT_NO
                                     AND  A.IND_BCD = B.IND_BCD
                                     AND  A.MATNR   = B.MATNR
                                     AND  NVL(A.CNL_YN, ''N'')  = ''N''
                                     AND  A.PRFM_GTHR_YN        = ''Y'' 
                                     AND  A.PRFM_DT   >= TO_CHAR(SYSDATE-120,''YYYYMMDD'') ';

          V_SQL := V_SQL || '        AND  A.LOT_NO IN ( SELECT LOT_NO FROM TB_INV001 WHERE WERKS = ''' || V_WERKS || ''' ';

          IF V_LOT_NO IS NOT NULL OR TRIM(V_LOT_NO) != '' THEN
             V_SQL := V_SQL || ' AND LOT_NO = ''' || V_LOT_NO || ''' ';  
          END IF ;

          IF V_IND_BCD IS NOT NULL OR TRIM(V_IND_BCD) != '' THEN
             V_SQL := V_SQL || ' AND IND_BCD = ''' || V_IND_BCD || ''' ';  
          END IF ;

          IF V_MATNR IS NOT NULL OR TRIM(V_MATNR) != '' THEN
             V_SQL := V_SQL || ' AND MATNR = ''' || V_MATNR || ''' ';  
          END IF ;

          V_SQL := V_SQL || ')';

          V_SQL := V_SQL || '    GROUP BY A.WERKS, A.LOT_NO, A.MATNR, A.UNIT, DECODE(B.STCK_STA, ''70'', ''3000'', B.STOR_LOC_CD) ) A,
                                (SELECT WERKS,  CHARG, MATNR, LGORT , STQTY FROM TB_IFR050) B
                            WHERE  A.WERKS       = B.WERKS
                              AND  A.LOT_NO      = B.CHARG
                              AND  A.MATNR       = B.MATNR
                              AND  A.STOR_LOC_CD = B.LGORT
                            )
                    GROUP BY WERKS, LOT_NO, MATNR, UNIT ' ;

-- 
--        V_DEBUG := 'Y';
--
--        IF (V_DEBUG = 'Y') THEN
--            INSERT INTO PROC_LOG(SQL_STR) VALUES (V_SQL);
--        END IF;
--        COMMIT;

          OPEN P_RS_LIST FOR V_SQL;

	END IF;

	P_SUCCESS := 'Y';
	COMMIT;

	EXCEPTION
    WHEN E_EXCEPTION_USER THEN

    -- 에러 내역 SET
        P_SUCCESS           := 'N';
        E_SQL_ERR_CD        := -20000;
		E_SQL_ERR_MSG       := SUBSTRB(SQLERRM,1,300);

		ROLLBACK;
		SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);

	WHEN OTHERS THEN
		P_SUCCESS			:= 'N';
        E_SQL_ERR_CD        := E_SQL_ERR_CD;
		E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

		ROLLBACK;
		RAISE;
END;

/
