--------------------------------------------------------
--  DDL for Procedure SP_WRK04_POP01_S01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_WRK04_POP01_S01" (
	P_TYPE           IN    varchar2, -- LIST, SAVE
	P_JSON_STR       IN    CLOB,
	P_SUCCESS       OUT    varchar2,
	P_RS_LIST       OUT    SYS_REFCURSOR 
)
/*==============================================================================
 * PROGRAM ID    : SP_WRK04_POP01_S01
 * PROGRAM NAME  : 폐품코드팝업
 * VERSION       : 1.0.0
 * DESCRIPTION   : 폐품코드팝업
 *                 
 * AUTHOR NAME   : 강동호
 * CREATE DATE   : 2022/06/15
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}	<생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}		<생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}			<생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}	<생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/05/22    1.0.0   강동호         Initial Version 
 *==============================================================================
 *  관련 테이블
 *        - [TB_MAS023] : ( R  ) 폐품항목 테이블
 *=============================================================================*/

AS
	V_PRG_NM          	VARCHAR2(100) 	:= 'SP_WRK04_POP01_S01';     -- PROCEDURE NAME

	-- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  	EXCEPTION;
    E_SQL_ERR_CD      	NUMBER(5) 		:= 0;
    E_SQL_ERR_MSG		VARCHAR2(4000);

   -- JSON을 위한 변수선언 영역
    V_JSON				JSON_OBJECT_T;
    V_ARR_LIST       	JSON_ARRAY_T;
	V_OBJ            	JSON_OBJECT_T;

	-- 세션값 처리용 변수선언 영역
    V_SESS_USER_ID   	varchar2(20);
    V_PLT_CD         	varchar2(2);
   	V_DEBUG          	varchar2(1);



	-- 리스트(그리드)의 값을 할당하기 위한 변수선언 영역
	V_WERKS				TB_MAS023.WERKS%TYPE;			--플랜트코드
	V_DISPO_CD			TB_MAS023.DISPO_CD%TYPE;		--폐품코드

	V_SQL				CLOB;
BEGIN
	OPEN P_RS_LIST FOR 

	SELECT NULL FROM DUAL WHERE ROWNUM = 0;

	V_JSON 				:= JSON_OBJECT_T.parse(P_JSON_STR);

	V_SESS_USER_ID		:= V_JSON.get_string('SES_USER_ID');
	V_PLT_CD			:= V_JSON.get_string('SES_PLNTKY');

	V_WERKS			    := V_JSON.get_string('WERKS'); 	    --플랜트코드
	V_DISPO_CD			:= V_JSON.get_string('DISPO_CD');	--폐품코드

	IF P_TYPE = 'LIST' THEN

		V_SQL := 
		' SELECT
                MAS023.WERKS        AS WERKS
            ,   MAS023.DISPO_CD     AS DISPO_CD
            ,   MAS023.DISPO_NM     AS DISPO_NM
            ,   MAS023.DISPO_DIV    AS DISPO_DIV
            FROM
                TB_MAS023 MAS023
            WHERE 1=1 ';	

			IF (V_WERKS IS NOT NULL OR TRIM(V_WERKS) != '') THEN
            	V_SQL := V_SQL || ' AND MAS023.WERKS = ''' || V_WERKS || '''';				   --플랜트   
        	END IF;

            IF (V_DISPO_CD IS NOT NULL OR TRIM(V_DISPO_CD) != '') THEN
            	V_SQL := V_SQL || ' AND MAS023.DISPO_CD = ''' || V_DISPO_CD || '''';		    --폐품코드   
        	END IF;

        	V_SQL := V_SQL || ' ORDER BY WERKS, DISPO_CD';

        IF (V_DEBUG = 'Y') THEN
        	INSERT INTO PROC_LOG (SQL_STR) VALUES (V_SQL);
        END IF;

		OPEN P_RS_LIST FOR V_SQL;

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
		P_SUCCESS			:= 'N';
        E_SQL_ERR_CD        := SQLCODE;
		E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

		ROLLBACK;
		RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
END;


/
