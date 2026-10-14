
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_DBLINK_IFRWM006" (
	P_JSON_STR       IN    varchar2 ,
	P_ERR_CODE       OUT    varchar2,
    P_ERR_MSG       OUT    varchar2
)
/*==============================================================================
 * PROGRAM ID    : IFRWM006{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 자재사용이력{호출 프로그램 명 기술}
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 생산출고처리 DBLINK
 *                 
 * AUTHOR NAME   : 백우종{최초 작성자 명 기술}
 * CREATE DATE   : 2022/11/18 {최초 작성일자 기술}
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * yyyy/mm/dd    1.0.0   백우종         Initial Version 
 *==============================================================================
 *  관련 테이블
 *      - [TB_IFRWM006] : (.R..) 생산출고처리 I/F Table
 *      - [TB_INV001] : (.R..) 공정재고 테이블
 *=============================================================================*/

AS
    PRAGMA AUTONOMOUS_TRANSACTION; 
    
    V_PRG_NM          VARCHAR2(100)  := 'SP_DBLINK_IFRWM006';     -- PROCEDURE NAME

    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5)           := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);


   -- V_RTN_CLOB       CLOB;
   -- V_RTN_CURSOR     SYS_REFCURSOR;
   -- V_ERROR          CLOB;


    -- JSON을 위한 변수선언 영역
    V_JSON           JSON_OBJECT_T;
    V_ARR_LIST       JSON_ARRAY_T;
    V_ARR_HEAD       JSON_OBJECT_T;
    V_OBJ            JSON_OBJECT_T;

    -- 세션값 처리용 변수선언 영역
    V_SQL            CLOB;
    V_RUN_SQL        varchar2(1);
    V_RANGE_SQL      varchar2(4000);
    V_DEBUG          varchar2(1);

    -- 세션값 처리용 변수선언 영역
    V_PLT_CD         varchar2(4);
    V_SESS_USER_ID   varchar2(20);

    -- 프로시져 사용 변수
    V_WERKS     		TB_IFRWM006.WERKS%TYPE;				--플랜트
    V_MATNR      		TB_IFRWM006.MATNR%TYPE;				--자재코드
    V_LOT_NO			TB_IFRWM006.LOT_NO%TYPE;			--LOT번호
	V_IND_BCD    		TB_IFRWM006.IND_BCD%TYPE;			--개별 바코드
    V_UNIT   			TB_IFRWM006.UNIT%TYPE;				--단위
    V_DOC_NO			TB_IFRWM006.DOC_NO%TYPE;			--문서번호
	V_DOC_SEQNO			TB_IFRWM006.DOC_SEQNO%TYPE;			--문서순번
	V_VGBEL				TB_IFRWM006.VGBEL%TYPE;				--VGBEL
	V_VGPOS				TB_IFRWM006.VGPOS%TYPE;				--VGPOS
	V_STOK_KY           TB_IFRWM006.STOK_KY%TYPE;			--STOK_KY
    V_LOT_NUM           TB_IFRWM006.LOT_NUM%TYPE;			--LOT_NUM
    V_DLFL	    		TB_IFRWM006.DLFL%TYPE;				--DLFL
	V_QTY		   		TB_IFRWM006.QTY%TYPE;				--수량
	V_STOR_LOC_FROM		TB_IFRWM006.STOR_LOC_FROM%TYPE;		--FROM 저장위치
	V_STOR_LOC_TO		TB_IFRWM006.STOR_LOC_TO%TYPE;		--TO 저장위치
	V_IF_MES_KEY		TB_IFRWM006.IF_MES_KEY%TYPE;		-- IF_MES_KEY
	V_IF_MES_ID			TB_IFRWM006.IF_MES_ID%TYPE;			-- IF_MES_ID
	V_ERR_CODE			VARCHAR2(2);						-- ERR CODE
	V_ERR_MSG			VARCHAR2(2000);						-- ERR MSG
	V_ERR_CODE_IFR		VARCHAR2(2);						-- ERR CODE IF_GET_IFRWM006
	V_ERR_MSG_IFR		VARCHAR2(2000);						-- ERR MSG IF_GET_IFRWM006
    V_JSONSTR				VARCHAR(2000);

BEGIN

	V_JSONSTR := REPLACE(P_JSON_STR, '^', '"');

	DBMS_OUTPUT.PUT_LINE('V_JSONSTR = ' || V_JSONSTR);
    V_DEBUG := 'N';
    V_RUN_SQL := 'Y';

    V_IF_MES_ID := 'MES_IF_403';

    V_JSON := JSON_OBJECT_T.parse(V_JSONSTR);

   	DBMS_OUTPUT.PUT_LINE('STEP 1');

    V_SESS_USER_ID       :=      V_JSON.get_string('SES_USER_ID');
    V_PLT_CD             :=      V_JSON.get_string('SES_PLNTKY');

    V_ARR_LIST              := V_JSON.get_array ('list');
   	DBMS_OUTPUT.PUT_LINE('STEP 2');

        FOR i IN 0..V_ARR_LIST.get_size-1 LOOP
            V_OBJ					:= TREAT (V_ARR_LIST.get (i) AS json_object_t);
--            V_OBJ					:= TREAT (V_OBJ.get ('map') AS json_object_t);
   	DBMS_OUTPUT.PUT_LINE('STEP 3');
            
            V_WERKS     			:= V_OBJ.get_string('WERKS');    				--플랜트
            V_MATNR      			:= V_OBJ.get_string('MATNR');      				--자재코드
            V_LOT_NO				:= V_OBJ.get_string('LOT_NO');					--LOT번호
			V_IND_BCD    			:= V_OBJ.get_string('IND_BCD');    				--개별 바코드
            V_UNIT   				:= V_OBJ.get_string('UNIT');   					--단위
            V_DOC_NO				:= V_OBJ.get_string('DOC_NO');					--문서번호
			V_DOC_SEQNO				:= V_OBJ.get_string('DOC_SEQNO');				--문서순번
			V_VGBEL					:= V_OBJ.get_string('VGBEL');					--VGBEL
			V_VGPOS					:= V_OBJ.get_string('VGPOS');					--VGPOS
			V_STOK_KY               := V_OBJ.get_string('STOK_KY');				    --STOK_KY
            V_LOT_NUM               := V_OBJ.get_string('LOT_NUM');			        --LOT_NUM
            V_DLFL	    			:= V_OBJ.get_string('DLFL');    				--DLFL
			V_QTY		   			:= TO_NUMBER(V_OBJ.get_string('QTY'));			--수량
			V_STOR_LOC_FROM			:= V_OBJ.get_string('STOR_LOC_FROM');    		--FROM 저장위치
			V_STOR_LOC_TO			:= V_OBJ.get_string('STOR_LOC_TO');    			--TO 저장위치

			SELECT 'M' || LTRIM(RTRIM(TO_CHAR(SEQ_GET_IFR_KEY.NEXTVAL, '00000000000000000000000000000')))	INTO	V_IF_MES_KEY
			FROM DUAL FOR UPDATE;

			-- Step 0. 기 입고된 개별바코드인지 확인 -- 필요없음
			-- Step 1. LOG Table Data Insert
				-- TB_ITFMESLOG INSERT
				INSERT INTO TB_ITFMESLOG
					(SEQNO, IFID, COMSTAT, ERRTXT, CREDAT, CRETIM, CDATE, CREUSR, REMARK)
				SELECT V_IF_MES_KEY, 'MES_IF_403', NVL('C',' '), '', TO_CHAR(SYSDATE, 'YYYYMMDD'), TO_CHAR(SYSDATE, 'HH24MISS'), SYSDATE, NVL(TRIM(''),'MES_IF_403'), ''
				FROM DUAL;
	
				-- TB_ITFMA UPDATE
				UPDATE TB_ITFMA SET LASTLOG = V_IF_MES_KEY WHERE IFID = 'MES_IF_403';
			
				-- TB_ITFMESLOG UPDATE
				UPDATE TB_ITFMESLOG
					SET COMSTAT = NVL('R',' ')
					  , ERRTXT  = SUBSTR(NVL('수신 1개',' '),1,4000)
				WHERE SEQNO = V_IF_MES_KEY;
			
				-- TB_ITFMA UPDATE
				UPDATE TB_ITFMA SET LASTCNT = '1' WHERE IFID = V_IF_MES_ID AND LASTLOG = V_IF_MES_KEY;

			-- Step 2. TB_IFRWM006 Table Insert
				INSERT INTO TB_IFRWM006 (
					VGBEL, VGPOS, DLFL, DOC_NO, DOC_SEQNO, WERKS, MATNR, QTY, UNIT, STOR_LOC_FROM
					, STOR_LOC_TO, IND_BCD, LOT_NO, STOK_KY, LOT_NUM, IF_STATUS, IF_GET_DATE, IF_SET_DATE, IF_ERR_MESS, IF_MES_ID, IF_MES_KEY)
				VALUES (
					V_VGBEL, V_VGPOS, V_DLFL, V_DOC_NO, V_DOC_SEQNO, V_WERKS, V_MATNR, V_QTY, V_UNIT, V_STOR_LOC_FROM
					, V_STOR_LOC_TO, V_IND_BCD, V_LOT_NO, V_STOK_KY, V_LOT_NUM, 'N', SYSDATE, NULL, NULL, V_IF_MES_ID, V_IF_MES_KEY);

			-- Step 3. Call SP_GET_IFRWM006
				SP_IF_GET_IFRWM006 (V_IF_MES_ID, V_IF_MES_KEY, V_ERR_CODE_IFR, V_ERR_MSG_IFR);

				IF V_ERR_CODE_IFR = 'S' OR	V_ERR_CODE_IFR = '0' THEN
					P_ERR_CODE := 'S';
					P_ERR_MSG := V_ERR_MSG_IFR;
				ELSE
   	DBMS_OUTPUT.PUT_LINE('STEP 5');
   	DBMS_OUTPUT.PUT_LINE('V_ERR_CODE_IFR : ' || V_ERR_CODE_IFR);
   	DBMS_OUTPUT.PUT_LINE('V_ERR_MSG_IFR : ' || V_ERR_MSG_IFR);
					P_ERR_CODE := V_ERR_CODE_IFR;
					P_ERR_MSG := V_ERR_MSG_IFR;
					RAISE E_EXCEPTION_USER;
				END IF;
        END LOOP;


    P_ERR_CODE := 'S';
    COMMIT;

    EXCEPTION
    WHEN E_EXCEPTION_USER THEN

        -- 에러 내역 SET
	    P_ERR_CODE           := 'N';
        E_SQL_ERR_CD        := SQLCODE;
        E_SQL_ERR_MSG       := SUBSTRB(SQLERRM,1,300);

        ROLLBACK;
        SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);

    WHEN OTHERS THEN
	    P_ERR_CODE           := 'N';
        E_SQL_ERR_CD        := -20990;
        E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

        ROLLBACK;
        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
END SP_DBLINK_IFRWM006;
/
