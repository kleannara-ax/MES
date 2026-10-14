
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_MAS23_S01" (
	P_TYPE           IN    varchar2, -- LIST, SAVE
	P_JSON_STR       IN    CLOB ,
	P_SUCCESS       OUT    varchar2,
	P_RS_LIST       OUT    SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : MAS23{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 공정체크 항목관리{호출 프로그램 명 기술}
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 공정체크 항목을 관리한다.{프로그램에 대한 상세한 내용 기술}
 *                 
 * AUTHOR NAME   : 여한진{최초 작성자 명 기술}
 * CREATE DATE   : 2022/04/19 {최초 작성일자 기술}
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
         - [TB_MAS012] : (C)    설비마스터
 *       - [TB_MAS025] : (CRUD) 공정체크 항목관리
 *=============================================================================*/

AS

    V_PRG_NM          VARCHAR2(100)  := 'SP_MAS23_S01';     -- PROCEDURE NAME

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

    -- 조건절 처리용 변수선언 영역
    V_WERKS             TB_MAS025.WERKS%TYPE;
    V_CHK_ITEM_CD       TB_MAS025.CHK_ITEM_CD%TYPE;
    V_CHK_ITEM_NM       TB_MAS025.CHK_ITEM_NM%TYPE;

    -- 리스트(그리드)의 값을 할당하기 위한 변수선언 영역
    V_MID_CAT_NM        TB_MAS025.MID_CAT_NM%TYPE;
    V_BIG_CAT_NM        TB_MAS025.BIG_CAT_NM%TYPE;
    V_INSP_STD_1        TB_MAS025.INSP_STD_1%TYPE;
    V_INSP_STD_2        TB_MAS025.INSP_STD_2%TYPE;
    V_INPT_DIV          TB_MAS025.INPT_DIV%TYPE;
    V_MSRM_CYC          TB_MAS025.MSRM_CYC%TYPE;
    V_INPT_TYP          TB_MAS025.INPT_TYP%TYPE;
    V_INPT_MTD          TB_MAS025.INPT_MTD%TYPE;
    V_MSRM_MTD          TB_MAS025.MSRM_MTD%TYPE;
    V_MSRM_UNIT         TB_MAS025.MSRM_UNIT%TYPE;
    V_CPK_YN            TB_MAS025.CPK_YN%TYPE;
    V_USE_YN            TB_MAS025.USE_YN%TYPE;

BEGIN

   OPEN P_RS_LIST FOR 
   SELECT NULL FROM DUAL WHERE ROWNUM = 0;

   V_DEBUG := 'N';
   V_RUN_SQL := 'Y';

   V_JSON := JSON_OBJECT_T.parse(P_JSON_STR);

   V_SESS_USER_ID       :=      V_JSON.get_string('SES_USER_ID');
   V_PLT_CD             :=      V_JSON.get_string('SES_PLNTKY');

   /* 조건값 할당 */
   V_RANGE_SQL          :=      V_JSON.get_string('RANGE_SQL');
   V_WERKS              :=      V_JSON.get_string('WERKS');             -- 플랜트
   --V_CHK_ITEM_NM        :=      V_JSON.get_string('CHK_ITEM_NM');       -- 체크항목명

   IF P_TYPE = 'LIST' THEN /*상단 조회 리스트*/

        V_SQL := ' SELECT  M025.WERKS             AS "WERKS",             -- 플랜트
                           M025.CHK_ITEM_CD       AS "CHK_ITEM_CD",       -- 검사항목(공정체크항목)
                           M025.CHK_ITEM_NM       AS "CHK_ITEM_NM",       -- 검사항목명
                           M025.MID_CAT_NM        AS "MID_CAT_NM",        -- 중분류명
                           M025.BIG_CAT_NM        AS "BIG_CAT_NM",        -- 대분류명
                           M025.INSP_STD_1        AS "INSP_STD_1",        -- 검사기준(1)
                           M025.INSP_STD_2        AS "INSP_STD_2",        -- 검사기준(2)
                           M025.INPT_DIV          AS "INPT_DIV",          -- 입력구분 
                           M025.MSRM_CYC          AS "MSRM_CYC",          -- 측정주기
                           M025.INPT_TYP          AS "INPT_TYP",          -- 입력타입
                           M025.INPT_MTD          AS "INPT_MTD",          -- 입력방법
                           M025.MSRM_MTD          AS "MSRM_MTD",          -- 측정방법
                           M025.MSRM_UNIT         AS "MSRM_UNIT",         -- 측정단위
                           M025.CPK_YN            AS "CPK_YN",            -- CPK_YN
                           M025.USE_YN            AS "USE_YN",            -- 사용여부(Y/N)
                           M025.REGDATE           AS "REGDATE",
                           NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = M025.REGID),'''') AS "REGNM",
                           M025.UPDDATE           AS "UPDDATE",
                           NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = M025.UPDID),'''') AS "UPDNM"
                     FROM  TB_MAS025 M025 -- 공정체크 항목
                    WHERE  1 = 1 ' ;

        IF V_RANGE_SQL IS NOT NULL OR TRIM(V_RANGE_SQL) != '' THEN
        	V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'CHK_ITEM_NM', 'M025.CHK_ITEM_NM');	--체크항목명
            V_SQL := V_SQL || V_RANGE_SQL;
        END IF;


        IF  V_WERKS IS NOT NULL OR TRIM(V_WERKS) != '' THEN                     -- 플랜트
            V_SQL := V_SQL || ' AND M025.WERKS = ''' || V_WERKS || '''';        
        END IF;

        /*IF  V_CHK_ITEM_NM IS NOT NULL OR TRIM(V_CHK_ITEM_NM) != '' THEN                 -- 체크항목명
            V_SQL := V_SQL || ' AND M025.CHK_ITEM_NM LIKE ''%' || V_CHK_ITEM_NM || '%''';        
        END IF;*/

		V_SQL := V_SQL || ' ORDER BY M025.WERKS, M025.CHK_ITEM_CD';

        --V_DEBUG := 'Y';

        IF (V_DEBUG = 'Y') THEN
            INSERT INTO PROC_LOG(SQL_STR) VALUES (V_SQL);
        END IF;

		OPEN P_RS_LIST FOR V_SQL;

    ELSIF P_TYPE = 'SUB_LIST' THEN  /* 하부 상세 조회 리스트*/

        RETURN;								

    ELSIF P_TYPE = 'SAVE' THEN
        --V_ARR_HEAD        := V_JSON.get_array('head');
        V_ARR_LIST        := V_JSON.get_array('list');

        FOR i IN 0..V_ARR_LIST.get_size-1 LOOP

            V_OBJ           := TREAT (V_ARR_LIST.get (i) AS json_object_t);
            V_OBJ           := TREAT (V_OBJ.get ('map') AS json_object_t);

            V_WERKS             := V_OBJ.get_string('WERKS');
            V_CHK_ITEM_CD       := V_OBJ.get_string('CHK_ITEM_CD');
            V_CHK_ITEM_NM       := V_OBJ.get_string('CHK_ITEM_NM');
            V_MID_CAT_NM        := V_OBJ.get_string('MID_CAT_NM');
            V_BIG_CAT_NM        := V_OBJ.get_string('BIG_CAT_NM');
            V_INSP_STD_1        := V_OBJ.get_string('INSP_STD_1');
            V_INSP_STD_2        := V_OBJ.get_string('INSP_STD_2');
            V_INPT_DIV          := V_OBJ.get_string('INPT_DIV');
            V_MSRM_CYC          := V_OBJ.get_string('MSRM_CYC');
            V_INPT_TYP          := V_OBJ.get_string('INPT_TYP');
            V_INPT_MTD          := V_OBJ.get_string('INPT_MTD');
            V_MSRM_MTD          := V_OBJ.get_string('MSRM_MTD');
            V_MSRM_UNIT         := V_OBJ.get_string('MSRM_UNIT');
            V_CPK_YN            := V_OBJ.get_string('CPK_YN');
            V_USE_YN            := V_OBJ.get_string('USE_YN');

            IF V_OBJ.get_string('GRowState') = 'C' THEN

                IF (V_RUN_SQL = 'Y') THEN

					BEGIN

	                    INSERT INTO TB_MAS025
	                    (
	                        WERKS,             
	                        CHK_ITEM_CD,       
	                        CHK_ITEM_NM,       
	                        MID_CAT_NM,        
	                        BIG_CAT_NM,        
	                        INSP_STD_1,        
	                        INSP_STD_2,        
	                        INPT_DIV,          
	                        MSRM_CYC,          
	                        INPT_TYP,          
	                        INPT_MTD,
                            MSRM_MTD,
	                        MSRM_UNIT,         
	                        CPK_YN,            
	                        USE_YN,
	                        REGDATE,
	                        REGID
	                    ) VALUES (
	                        V_WERKS,      
	                        V_CHK_ITEM_CD,
	                        V_CHK_ITEM_NM,
	                        V_MID_CAT_NM, 
	                        V_BIG_CAT_NM, 
	                        V_INSP_STD_1, 
	                        V_INSP_STD_2, 
	                        V_INPT_DIV,   
	                        V_MSRM_CYC,   
	                        V_INPT_TYP,   
	                        V_INPT_MTD,
                            V_MSRM_MTD,
	                        V_MSRM_UNIT,  
	                        V_CPK_YN,     
	                        V_USE_YN,
	                        SYSDATE,
	                        V_SESS_USER_ID
	                    );

					EXCEPTION           
                    WHEN OTHERS THEN 
                          P_SUCCESS           := 'N';
                          E_SQL_ERR_CD        := SQLCODE;
                          E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR(I001). [' || SUBSTR(SQLERRM,1,500) || ']';
                          ROLLBACK;

                          SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
                          RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);           
                          RETURN;           
                	END; 

                END IF;

            ELSIF V_OBJ.get_string('GRowState') = 'U' THEN

                IF (V_RUN_SQL = 'Y') THEN

                	BEGIN

	                    UPDATE TB_MAS025
	                       SET CHK_ITEM_NM  = V_CHK_ITEM_NM,
	                           MID_CAT_NM	= V_MID_CAT_NM,       
	                           BIG_CAT_NM	= V_BIG_CAT_NM,        
	                           INSP_STD_1	= V_INSP_STD_1,        
	                           INSP_STD_2	= V_INSP_STD_2,        
	                           INPT_DIV  	= V_INPT_DIV,          
	                           MSRM_CYC  	= V_MSRM_CYC,          
	                           INPT_TYP  	= V_INPT_TYP,          
	                           INPT_MTD  	= V_INPT_MTD,
                               MSRM_MTD     = V_MSRM_MTD,
	                           MSRM_UNIT 	= V_MSRM_UNIT,         
	                           CPK_YN    	= V_CPK_YN,            
	                           USE_YN		= V_USE_YN,
	                           UPDDATE      = SYSDATE,
	                           UPDID        = V_SESS_USER_ID
	                     WHERE WERKS        = V_WERKS
	                       AND CHK_ITEM_CD  = V_CHK_ITEM_CD;

					EXCEPTION           
                    WHEN OTHERS THEN 
                          P_SUCCESS           := 'N';
                          E_SQL_ERR_CD        := SQLCODE;
                          E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR(I001). [' || SUBSTR(SQLERRM,1,500) || ']';
                          ROLLBACK;

                          SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
                          RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);           
                          RETURN;           
                    END; 

                END IF;                   

            ELSIF V_OBJ.get_string('GRowState') = 'D' THEN

				BEGIN

                	DELETE FROM TB_MAS025 WHERE WERKS = V_WERKS AND CHK_ITEM_CD = V_CHK_ITEM_CD;

                EXCEPTION           
                WHEN OTHERS THEN 
                      P_SUCCESS           := 'N';
                      E_SQL_ERR_CD        := SQLCODE;
                      E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR(I001). [' || SUBSTR(SQLERRM,1,500) || ']';
                      ROLLBACK;

                      SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
                      RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);           
                      RETURN;           
           		END; 

            END IF;

        END LOOP;

    ELSIF P_TYPE = 'SUB_SAVE' THEN

        RETURN;

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
