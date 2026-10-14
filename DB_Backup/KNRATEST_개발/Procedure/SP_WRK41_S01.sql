--------------------------------------------------------
--  DDL for Procedure SP_WRK41_S01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_WRK41_S01" (
	P_TYPE         IN    varchar2, -- LIST, SUB_LIST-A, SUB_LIST-B
	P_JSON_STR     IN    CLOB,
	P_SUCCESS      OUT   varchar2,
	P_RS_LIST      OUT   SYS_REFCURSOR 
)
/*==============================================================================
 * PROGRAM ID    : SP_WRK41_S01{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 고지, 펄프 사용량 이력 {호출 프로그램 명 기술}
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 고지, 펄프 사용량 이력 {프로그램에 대한 상세한 내용 기술}
 *                 
 * AUTHOR NAME   : 박성철{최초 작성자 명 기술}
 * CREATE DATE   : 2022/05/27 {최초 작성일자 기술}
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * yyyy/mm/dd    1.0.0   박성철         Initial Version 
 *==============================================================================
 *  관련 테이블
 *        - [TB_MAS012] : (R) 호기
 *        - [CMCDV]     : (R) 공통코드 아이템
 *        - [TB_INV006] : (R) 고지,펄프 사용량이력                                 
 *        - [TB_MAS009] : (R) 거래처 마스터                                    
 *=============================================================================*/

AS

    V_PRG_NM          VARCHAR2(100)  := 'SP_WRK41_S01';     -- PROCEDURE NAME


    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5)           := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);

    -- JSON을 위한 변수선언 영역
    V_JSON           JSON_OBJECT_T;
    V_ARR_LIST       JSON_ARRAY_T;
    V_ARR_HEAD       JSON_ARRAY_T;
    V_OBJ            JSON_OBJECT_T;

    -- 세션값 처리용 변수선언 영역
    V_SQL            CLOB;
    V_RUN_SQL        varchar2(1);
    V_RANGE_SQL      varchar2(4000);
    V_DEBUG          varchar2(1);

    -- 세션값 처리용 변수선언 영역
    V_PLT_CD         varchar2(2);
    V_SESS_USER_ID   varchar2(20);

    -- 조건절 처리용 변수선언 영역
    V_MACHINE			TB_INV006.MACHINE%TYPE;			    -- 호기
    V_MAT_LINE_CD		TB_INV006.MAT_LINE_CD%TYPE;			-- 원료라인
    V_MATNR				TB_INV006.MATNR%TYPE;			    -- 자재코드

    -- 리스트(그리드)의 값을 할당하기 위한 변수선언 영역





BEGIN
    OPEN P_RS_LIST FOR 

    SELECT NULL FROM DUAL WHERE ROWNUM = 0;

    V_DEBUG := 'N';
    V_RUN_SQL := 'Y';

    V_JSON := JSON_OBJECT_T.parse(P_JSON_STR);

    V_SESS_USER_ID       :=      V_JSON.get_string('SES_USER_ID');
    V_PLT_CD             :=      V_JSON.get_string('SES_PLNTKY');

    /* 조건값 할당 */
    V_RANGE_SQL         :=      V_JSON.get_string('RANGE_SQL');
    V_MACHINE			:= 		V_JSON.get_string('MACHINE');		-- 호기  
    V_MAT_LINE_CD		:= 		V_JSON.get_string('MAT_LINE_CD');	-- 원료라인
    V_MATNR				:= 		V_JSON.get_string('MATNR');		    -- 자재코드

    IF P_TYPE = 'LIST' THEN /*상단 조회 리스트*/
        V_SQL :=  ' SELECT INV006.INP_DT        AS INP_DT           --투입일자(YYYYMMDD)
					     --, INV006.MACHINE       AS MACHINE        --호기
                         , FN_CD_VAL(''MACHINE'', INV006.MACHINE)      AS MACHINE  --호기명
					     --, INV006.MAT_LINE_CD   AS MAT_LINE_CD    --원료라인
                         , FN_CD_VAL(''MATLINECD'', INV006.MAT_LINE_CD) AS MAT_LINE_CD  --원료라인명
					     , INV006.MATNR         AS MATNR            --자재코드
					     , MAS001.MATNR_NM      AS MATNR_NM         --자재명
					     , INV006.SUPY_CD       AS SUPY_CD          --공급업체
					--     , MAS009.CUST_NM   AS SUPY_NM            --공급업체명
					     , (SELECT CUST_NM FROM TB_MAS009           
					         WHERE CUST_CD = INV006.SUPY_CD         
					           AND ROWNUM = 1)  AS SUPY_NM          --공급업체명
					--     , INV006.MAT_LINE_CD   AS WEIGHT_V       --베일당중량
					     , INV006.IN_QTY        AS IN_QTY           --베일수
					     , INV006.USE_QTY       AS USE_QTY          --사용량
					  FROM TB_INV006 INV006       --고지,펄프 사용량이력
					  LEFT JOIN TB_MAS001 MAS001  --자재마스터
					    ON MAS001.MATNR = INV006.MATNR
					   AND MAS001.WERKS = INV006.WERKS
					--  LEFT JOIN TB_MAS009 MAS009  --거래선(업체)마스터
					--    ON MAS009.CUST_CD = INV006.SUPY_CD
					 WHERE 1=1';


        IF  V_MACHINE IS NOT NULL OR TRIM(V_MACHINE) != '' THEN			   -- 호기
            V_SQL := V_SQL || ' AND INV006.MACHINE = ''' || V_MACHINE || '''';        
        END IF;

        IF  V_MAT_LINE_CD IS NOT NULL OR TRIM(V_MAT_LINE_CD) != '' THEN	   -- 원료라인
            V_SQL := V_SQL || ' AND INV006.MAT_LINE_CD = ''' || V_MAT_LINE_CD || '''';        
        END IF;

        IF  V_MATNR IS NOT NULL OR TRIM(V_MATNR) != '' THEN			       -- 자재코드
            V_SQL := V_SQL || ' AND INV006.MATNR = ''' || V_MATNR || '''';        
        END IF;

        IF V_RANGE_SQL IS NOT NULL OR TRIM(V_RANGE_SQL) != '' THEN
            V_SQL := V_SQL || V_RANGE_SQL;
        END IF;

        V_SQL := V_SQL || ' ORDER BY INP_DT, MACHINE, MAT_LINE_CD, MATNR, SUPY_CD';


--        V_DEBUG := 'Y';
--
--        IF (V_DEBUG = 'Y') THEN
--            INSERT INTO PROC_LOG(SQL_STR) VALUES (V_SQL);
--        END IF;


		OPEN P_RS_LIST FOR V_SQL;


--    ELSIF P_TYPE = 'SAVE' THEN
--    	RETURN;


    END IF;


    P_SUCCESS := 'Y';


    EXCEPTION
    WHEN E_EXCEPTION_USER THEN

        -- 에러 내역 SET
	    P_SUCCESS           := 'N';
        E_SQL_ERR_CD        := SQLCODE;
        E_SQL_ERR_MSG       := SUBSTRB(SQLERRM,1,300);

        ROLLBACK;
        SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);

    WHEN OTHERS THEN
	    P_SUCCESS           := 'N';
        E_SQL_ERR_CD        := SQLCODE;
        E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

        ROLLBACK;
        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
END;


/
