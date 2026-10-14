--------------------------------------------------------
--  DDL for Procedure SP_MAS14_S01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_MAS14_S01" (
	P_TYPE           IN    varchar2, -- LIST, SAVE
	P_JSON_STR       IN    CLOB ,
	P_SUCCESS       OUT    varchar2,
	P_RS_LIST       OUT    SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : MAS14{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 폐품(불량) 항목관리{호출 프로그램 명 기술}
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 폐품(불량) 항목을 관리한다.{프로그램에 대한 상세한 내용 기술}
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
 *       - [TB_MAS023] : (CRUD) 폐품(불량) 항목관리
 *       - [TB_MAS024] : (...D) 공정별 폐품(불량) 항목관리
 *=============================================================================*/

AS

    V_PRG_NM          VARCHAR2(100)  := 'SP_MAS14_S01';     -- PROCEDURE NAME

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
    V_DISPO_CD          TB_MAS023.DISPO_CD%TYPE;

    -- 리스트(그리드)의 값을 할당하기 위한 변수선언 영역
    V_WERKS         TB_MAS023.WERKS%TYPE;
    V_DISPO_DIV     TB_MAS023.DISPO_DIV%TYPE;
    V_DISPO_NM      TB_MAS023.DISPO_NM%TYPE;
    V_RMK           TB_MAS023.RMK%TYPE;

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
   V_DISPO_CD           :=      V_JSON.get_string('DISPO_CD');       -- 폐품코드
   V_DISPO_DIV          :=      V_JSON.get_string('DISPO_DIV');     --폐품유형
   V_WERKS          :=      V_JSON.get_string('WERKS');     --폐품유형

   IF P_TYPE = 'LIST' THEN /*상단 조회 리스트*/

        V_SQL := ' SELECT  M023.WERKS             AS WERKS,
                           M023.DISPO_CD          AS DISPO_CD,         -- 폐품코드
                           M023.DISPO_NM          AS DISPO_NM,         -- 폐품명
                           M023.DISPO_DIV         AS DISPO_DIV,        -- 폐품유형
                           M023.RMK               AS RMK,              -- 비고
                           M023.REGDATE           AS REGDATE,
                           NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = M023.REGID),'''') AS REGNM,
                           M023.UPDDATE           AS "UPDDATE",
                           NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = M023.UPDID),'''') AS UPDNM
                     FROM  TB_MAS023 M023 -- 폐품(불량) 항목
                    WHERE  1 = 1 ' ;

        V_SQL := V_SQL || V_RANGE_SQL;
        
        IF  V_WERKS IS NOT NULL OR TRIM(V_WERKS) != '' THEN                 -- 플랜트
            V_SQL := V_SQL || ' AND M023.WERKS LIKE ''%' || V_WERKS || '%''';        
        END IF;

        IF  V_DISPO_CD IS NOT NULL OR TRIM(V_DISPO_CD) != '' THEN                 -- 폐품코드
            V_SQL := V_SQL || ' AND M023.DISPO_CD LIKE ''%' || V_DISPO_CD || '%''';        
        END IF;

        IF  V_DISPO_DIV IS NOT NULL OR TRIM(V_DISPO_DIV) != '' THEN                 -- 폐품유형
            V_SQL := V_SQL || ' AND M023.DISPO_DIV = ''' || V_DISPO_DIV || '''';        
        END IF;

		V_SQL := V_SQL || ' ORDER BY M023.DISPO_CD';

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

            V_WERKS         := V_OBJ.get_string('WERKS');
            V_DISPO_CD      := V_OBJ.get_string('DISPO_CD');
            V_DISPO_NM      := V_OBJ.get_string('DISPO_NM');
            V_DISPO_DIV     := V_OBJ.get_string('DISPO_DIV');
            V_RMK           := V_OBJ.get_string('RMK');

            IF V_OBJ.get_string('GRowState') = 'C' THEN

                IF (V_RUN_SQL = 'Y') THEN

                    INSERT INTO TB_MAS023
                    (
                        WERKS,
                        DISPO_CD,
                        DISPO_NM,
                        DISPO_DIV,
                        RMK,
                        REGDATE,
                        REGID
                    ) VALUES (
                        V_WERKS,
                        V_DISPO_CD,
                        V_DISPO_NM,
                        V_DISPO_DIV,
                        V_RMK,
                        SYSDATE, 
                        V_SESS_USER_ID
                    );

                END IF;

            ELSIF V_OBJ.get_string('GRowState') = 'U' THEN

                IF (V_RUN_SQL = 'Y') THEN

                    UPDATE TB_MAS023
                       SET DISPO_DIV    = V_DISPO_DIV,
                           DISPO_NM     = V_DISPO_NM,
                           RMK          = V_RMK,
                           UPDDATE      = SYSDATE,
                           UPDID        = V_SESS_USER_ID
                     WHERE WERKS        = V_WERKS
                       AND DISPO_CD     = V_DISPO_CD;

                END IF;                   

            ELSIF V_OBJ.get_string('GRowState') = 'D' THEN

                DELETE FROM TB_MAS023 WHERE WERKS = V_WERKS AND DISPO_CD = V_DISPO_CD;
                DELETE FROM TB_MAS024 WHERE WERKS = V_WERKS AND DISPO_CD = V_DISPO_CD;

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
