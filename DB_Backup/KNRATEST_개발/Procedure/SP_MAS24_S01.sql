--------------------------------------------------------
--  DDL for Procedure SP_MAS24_S01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_MAS24_S01" (
	P_TYPE           IN    varchar2, -- LIST, SUB_LIST, SUB_SAVE
	P_JSON_STR       IN    CLOB ,
	P_SUCCESS       OUT    varchar2,
	P_RS_LIST       OUT    SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : MAS24{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 설비별 공정체크 스펙 관리{호출 프로그램 명 기술}
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 설비별로 공정체크 항목의 스펙을 관리한다.{프로그램에 대한 상세한 내용 기술}
 *                 
 * AUTHOR NAME   : 여한진{최초 작성자 명 기술}
 * CREATE DATE   : 2022/04/20 {최초 작성일자 기술}
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * yyyy/mm/dd    1.0.0   여한진         Initial Version 
 *==============================================================================
 *  관련 테이블
 *       - [TB_MAS012] : (.R..) 설비마스터
 *       - [TB_MAS013] : (.R..) 공정 관리
 *       - [TB_MAS025] : (.R..) 공정체크항목관리                            
 *       - [TB_MAS026] : (CRU.) 공정체크항목별 기준값관리  
 *=============================================================================*/

AS

    V_PRG_NM          VARCHAR2(100)  := 'SP_MAS24_S01';     -- PROCEDURE NAME

    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5)           := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);


   -- V_RTN_CLOB       CLOB;
   -- V_RTN_CURSOR     SYS_REFCURSOR;
   -- V_ERROR          CLOB;


    -- JSON을 위한 변수선언 영역
    V_JSON          JSON_OBJECT_T;
    V_ARR_LIST      JSON_ARRAY_T;
    V_ARR_HEAD      JSON_OBJECT_T;
    V_OBJ           JSON_OBJECT_T;
    V_OBJ2          JSON_OBJECT_T; 

    -- 세션값 처리용 변수선언 영역
    V_SQL            CLOB;
    V_RUN_SQL        varchar2(1);
    V_RANGE_SQL      varchar2(4000);
    V_DEBUG          varchar2(1);

    -- 세션값 처리용 변수선언 영역
    V_PLT_CD         varchar2(4);
    V_SESS_USER_ID   varchar2(20);

    -- 조건절 처리용 변수선언 영역
    V_WERKS             TB_MAS013.WERKS%TYPE;   -- 플랜트
    V_PROC_CD           TB_MAS012.PROC_CD%TYPE; -- 공정
    V_MACH_CD           TB_MAS012.MACH_CD%TYPE; -- 설비

    -- 리스트(그리드)의 값을 할당하기 위한 변수선언 영역
    V_CHK_ITEM_CD       TB_MAS026.CHK_ITEM_CD%TYPE;
    V_STD_VAL1          TB_MAS026.STD_VAL1%TYPE;
    V_STD_VAL2          TB_MAS026.STD_VAL2%TYPE;
    V_UPP_VAL           TB_MAS026.UPP_VAL%TYPE;
    V_LOW_VAL           TB_MAS026.LOW_VAL%TYPE;
    V_USE_YN            TB_MAS026.USE_YN%TYPE;
    V_RMK               TB_MAS026.RMK%TYPE;

BEGIN

   OPEN P_RS_LIST FOR 
   SELECT NULL FROM DUAL WHERE ROWNUM = 0;

   V_DEBUG := 'N';
   V_RUN_SQL := 'Y';

   V_JSON := JSON_OBJECT_T.parse(P_JSON_STR);

   V_SESS_USER_ID       :=      V_JSON.get_string('SES_USER_ID');
   V_PLT_CD             :=      V_JSON.get_string('SES_PLNTKY');

   /* 조건값 할당 */
   V_RANGE_SQL          :=      V_JSON.get_string('RANGE_SQL');     -- 공정, 설비
   V_WERKS              :=      V_JSON.get_string('WERKS');         -- 플랜트

   IF P_TYPE = 'LIST' THEN /*상단 조회 리스트*/

        V_SQL := ' SELECT  M013.WERKS               AS "WERKS",             -- 플랜트
                           M012.MACH_CD             AS "MACH_CD",       -- 설비코드
                           M012.MACH_NM             AS "MACH_NM" 		-- 설비명
                     FROM  TB_MAS012 M012, -- 설비 마스터
                           TB_MAS013 M013  -- 공정
                    WHERE  M012.PROC_CD = M013.PROC_CD(+) ' ;

        V_SQL := V_SQL || V_RANGE_SQL;

        IF  V_WERKS IS NOT NULL OR TRIM(V_WERKS) != '' THEN                     -- 플랜트
            V_SQL := V_SQL || ' AND M013.WERKS = ''' || V_WERKS || '''';        
        END IF;

		V_SQL := V_SQL || ' ORDER BY M013.WERKS, M012.MACH_CD';

		OPEN P_RS_LIST FOR V_SQL;

    ELSIF P_TYPE = 'SUB_LIST' THEN  /* 하부 상세 조회 리스트*/

    	V_MACH_CD		:= 		V_JSON.get_string('MACH_CD');

   		V_SQL := ' SELECT M025.CHK_ITEM_CD,		-- 체크항목코드
                           M025.CHK_ITEM_NM,		-- 체크항목명
                           M025.MID_CAT_NM,			-- 중분류명
                           M025.BIG_CAT_NM,			-- 대분류명
						   M025.INSP_STD_1,			-- 검사기준(1)
						   M025.INSP_STD_2,			-- 검사기준(2)
                	       M025.INPT_DIV, 			-- 입력구분
                           (SELECT CDESC1 FROM CMCDV WHERE CMCDKY = ''INPTDIV'' AND CMCDVL = M025.INPT_DIV) AS "INPT_DIV_NM",		-- 입력구분(명)
                           M025.MSRM_CYC, 			-- 측정주기
                           (SELECT CDESC1 FROM CMCDV WHERE CMCDKY = ''MSRMUNIT'' AND CMCDVL = M025.MSRM_CYC) AS "MSRM_CYC_NM",		-- 측정주기(명)
                           M025.INPT_TYP, 			-- 입력타입
                           (SELECT CDESC1 FROM CMCDV WHERE CMCDKY = ''INPTTYP'' AND CMCDVL = M025.INPT_TYP) AS "INPT_TYP_NM",     	-- 입력타입(명)                     
                           M025.INPT_MTD, 			-- 입력방법
                           (SELECT CDESC1 FROM CMCDV WHERE CMCDKY = ''INPTMTD'' AND CMCDVL = M025.INPT_MTD) AS "INPT_MTD_NM",   	-- 입력방법(명)       
                           M025.MSRM_MTD, 			-- 측정방법
                           M025.MSRM_UNIT,			-- 측정단위
                           M025.CPK_YN, 			-- CPK 여부 
                           M026.MACH_CD, 			-- 설비
                           M026.WERKS, 				-- 플랜트
                           M026.STD_VAL1, 			-- 기준값(숫자)
						   M026.STD_VAL2, 			-- 기준값(문자)
                           M026.UPP_VAL, 			-- 상한값
                           M026.LOW_VAL, 			-- 하한값
						   M026.USE_YN,				-- 사용여부(Y/N)
						   M026.RMK,				-- 비고
                           M026.REGDATE,
                           NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = M026.REGID),'''')	AS	REGNM,
                           M026.UPDDATE,
                           NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = M026.UPDID),'''')	AS	UPDNM
                    FROM   TB_MAS025 M025,	-- 공정체크항목
						   TB_MAS026 M026	-- 공정체크항목별 기준값관리
                    WHERE  M026.CHK_ITEM_CD = M025.CHK_ITEM_CD(+)
   					  AND  M026.MACH_CD = '''|| V_MACH_CD ||'''
					  AND  M026.WERKS = '''|| V_WERKS ||''' 
				   ORDER BY M026.CHK_ITEM_CD ';

		OPEN P_RS_LIST FOR V_SQL; 								

    ELSIF P_TYPE = 'POP_LIST' THEN

        V_SQL := ' SELECT  M025.WERKS             AS "WERKS",             -- 플랜트
                           M025.CHK_ITEM_CD       AS "CHK_ITEM_CD",       -- 검사항목(공정체크항목)
                           M025.CHK_ITEM_NM       AS "CHK_ITEM_NM",       -- 검사항목명
                           M025.MID_CAT_NM        AS "MID_CAT_NM",        -- 중분류명
                           M025.BIG_CAT_NM        AS "BIG_CAT_NM",        -- 대분류명
                           M025.INSP_STD_1        AS "INSP_STD_1",        -- 검사기준(1)
                           M025.INSP_STD_2        AS "INSP_STD_2",        -- 검사기준(2)
                           M025.INPT_DIV          AS "INPT_DIV",          -- 입력구분
                           (SELECT CDESC1 FROM CMCDV WHERE CMCDKY = ''INPTDIV'' AND CMCDVL = M025.INPT_DIV) AS "INPT_DIV_NM",		-- 입력구분(명)
                           M025.MSRM_CYC          AS "MSRM_CYC",          -- 측정주기
                           (SELECT CDESC1 FROM CMCDV WHERE CMCDKY = ''MSRMUNIT'' AND CMCDVL = M025.MSRM_CYC) AS "MSRM_CYC_NM",		-- 측정주기(명)
                          M025.INPT_TYP, 			-- 입력타입
                           (SELECT CDESC1 FROM CMCDV WHERE CMCDKY = ''INPTTYP'' AND CMCDVL = M025.INPT_TYP) AS "INPT_TYP_NM",     	-- 입력타입(명)                     
                           M025.INPT_MTD, 			-- 입력방법
                           (SELECT CDESC1 FROM CMCDV WHERE CMCDKY = ''INPTMTD'' AND CMCDVL = M025.INPT_MTD) AS "INPT_MTD_NM",   	-- 입력방법(명)
                           M025.MSRM_MTD          AS "MSRM_MTD",          -- 측정방법
                           M025.MSRM_UNIT         AS "MSRM_UNIT",         -- 측정단위
                           M025.CPK_YN            AS "CPK_YN",            -- CPK_YN
                           M025.USE_YN            AS "USE_YN",            -- 사용여부(Y/N)
                           M025.REGDATE           AS "REGDATE",
                           NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = M025.REGID),'''') AS "REGNM",
                           M025.UPDDATE           AS "UPDDATE",
                           NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = M025.UPDID),'''') AS "UPDNM"
                     FROM  TB_MAS025 M025 -- 공정체크 항목
                    WHERE  M025.WERKS = ''' || V_WERKS || '''
                      AND  M025.USE_YN = ''Y'' ';

        OPEN P_RS_LIST FOR V_SQL;

    ELSIF P_TYPE = 'SAVE' THEN

        RETURN;

    ELSIF P_TYPE = 'SUB_SAVE' THEN
        V_ARR_HEAD          := TREAT(V_JSON.get ('head') AS json_object_t);
        V_ARR_LIST          := V_JSON.get_array('list');

        V_OBJ2              := TREAT (V_ARR_HEAD.get ('map') AS json_object_t);
        V_MACH_CD           := V_OBJ2.get_string('MACH_CD');

        FOR i IN 0..V_ARR_LIST.get_size-1 LOOP

            V_OBJ               := TREAT (V_ARR_LIST.get (i) AS json_object_t);
            V_OBJ               := TREAT (V_OBJ.get ('map') AS json_object_t);

            V_WERKS             := V_OBJ.get_string('WERKS');
            V_CHK_ITEM_CD       := V_OBJ.get_string('CHK_ITEM_CD');
            V_STD_VAL1          := V_OBJ.get_number('STD_VAL1');
            V_STD_VAL2          := V_OBJ.get_string('STD_VAL2');
            V_UPP_VAL           := V_OBJ.get_number('UPP_VAL');
            V_LOW_VAL           := V_OBJ.get_number('LOW_VAL');
            V_USE_YN            := V_OBJ.get_string('USE_YN');
            V_RMK               := V_OBJ.get_string('RMK');

            IF V_OBJ.get_string('GRowState') = 'C' THEN

                INSERT INTO TB_MAS026
                (
                    MACH_CD,
                    CHK_ITEM_CD,
                    WERKS,
                    LOW_VAL,
                    UPP_VAL,
                    STD_VAL1,
                    STD_VAL2,
                    USE_YN,
                    RMK,
                    REGDATE,
                    REGID
                ) VALUES (
                    V_MACH_CD,
                    V_CHK_ITEM_CD,
                    V_WERKS,
                    V_LOW_VAL,
                    V_UPP_VAL,
                    V_STD_VAL1,
                    V_STD_VAL2,
                    V_USE_YN,
                    V_RMK,
                    SYSDATE,
                    V_SESS_USER_ID
                );

            ELSIF V_OBJ.get_string('GRowState') = 'U' THEN

                UPDATE TB_MAS026
                   SET LOW_VAL = V_LOW_VAL,
                       UPP_VAL = V_UPP_VAL,
                       STD_VAL1 = V_STD_VAL1,
                       STD_VAL2 = V_STD_VAL2,
                       RMK = V_RMK,
                       UPDDATE = SYSDATE,
                       UPDID = V_SESS_USER_ID
                 WHERE MACH_CD = V_MACH_CD
                   AND CHK_ITEM_CD = V_CHK_ITEM_CD;

            ELSIF V_OBJ.get_string('GRowState') = 'D' THEN

                DELETE TB_MAS026 WHERE MACH_CD = V_MACH_CD AND CHK_ITEM_CD = V_CHK_ITEM_CD;

            END IF;

        END LOOP;

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
        E_SQL_ERR_CD        := -20990;
        E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

        ROLLBACK;
        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
END;


/
