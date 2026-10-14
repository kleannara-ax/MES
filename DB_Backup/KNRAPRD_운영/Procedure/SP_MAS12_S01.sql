--------------------------------------------------------
--  DDL for Procedure SP_MAS12_S01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_MAS12_S01" (
	P_TYPE           IN    varchar2, -- LIST, SUB_LIST, SUB_SAVE
	P_JSON_STR       IN    CLOB ,
	P_SUCCESS       OUT    varchar2,
	P_RS_LIST       OUT    SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : MAS12{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 저장위치{호출 프로그램 명 기술}
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 저장위치, 저장위치별 로케이션을 관리한다.{프로그램에 대한 상세한 내용 기술}
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
 *       - [TB_MAS003] : (R) 저장위치 마스터
         - [TB_MAS028] : (CRUD) 로케이션 관리
 *=============================================================================*/

AS

    V_PRG_NM          VARCHAR2(100)  := 'SP_MAS12_S01';     -- PROCEDURE NAME

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
    V_ARR_HEAD       JSON_ARRAY_T;
    V_OBJ            JSON_OBJECT_T;
    V_OBJ2           JSON_OBJECT_T;

    -- 세션값 처리용 변수선언 영역
    V_SQL            CLOB;
    V_RUN_SQL        varchar2(1);
    V_RANGE_SQL      varchar2(4000);
    V_DEBUG          varchar2(1);

    -- 세션값 처리용 변수선언 영역
    V_PLT_CD         varchar2(4);
    V_SESS_USER_ID   varchar2(20);

    -- 조건절 처리용 변수선언 영역
    V_WERKS         TB_MAS003.WERKS%TYPE;

    -- 리스트(그리드)의 값을 할당하기 위한 변수선언 영역
    V_WCS_STOR_LOC_CD   TB_MAS003.WCS_STOR_LOC_CD%TYPE;
    V_STOR_LOC_CD   TB_MAS028.STOR_LOC_CD%TYPE;
    V_LOC_CD        TB_MAS028.LOC_CD%TYPE;
    V_LOC_NM        TB_MAS028.LOC_NM%TYPE;
    V_MACH_CD       TB_MAS028.MACH_CD%TYPE;
    V_USE_YN        TB_MAS028.USE_YN%TYPE;
BEGIN

   OPEN P_RS_LIST FOR 
   SELECT NULL FROM DUAL WHERE ROWNUM = 0;

   V_DEBUG := 'N';
   V_RUN_SQL := 'Y';

   V_JSON := JSON_OBJECT_T.parse(P_JSON_STR);

   V_SESS_USER_ID       :=       V_JSON.get_string('SES_USER_ID');
   V_PLT_CD             :=       V_JSON.get_string('SES_PLNTKY');

   /* 조건값 할당 */
   V_RANGE_SQL          :=       V_JSON.get_string('RANGE_SQL');
   V_WERKS              :=       V_JSON.get_string('WERKS');        -- 플랜트

   IF P_TYPE = 'LIST' THEN /*상단 조회 리스트*/

        V_SQL := ' SELECT  mas003.WERKS             AS "WERKS",             -- 플랜트
                           mas003.STOR_LOC_CD       AS "STOR_LOC_CD",       -- 저장위치
                           mas003.STOR_LOC_NM       AS "STOR_LOC_NM",       -- 저장위치명
                           mas003.WCS_STOR_LOC_CD,       --WCS저장위치
                           mas003.RMK               AS "RMK",               -- 비고
                           mas003.USE_YN            AS "USE_YN",            -- 사용유무
                           mas003.REGDATE           AS "REGDATE",
                           NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = mas003.REGID),'''') AS "REGNM",
                           mas003.UPDDATE           AS "UPDDATE",
                           NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = mas003.UPDID),'''') AS "UPDNM"
                     FROM  TB_MAS003 mas003 -- 저장위치
                    WHERE  1 = 1 ' ;

        V_SQL := V_SQL || V_RANGE_SQL;

        IF  V_WERKS IS NOT NULL OR TRIM(V_WERKS) != '' THEN
            V_SQL := V_SQL || ' AND mas003.WERKS = ''' || V_WERKS || '''';        
        END IF;

		V_SQL := V_SQL || ' ORDER BY mas003.WERKS, mas003.STOR_LOC_CD';

        --V_DEBUG := 'Y';

        IF (V_DEBUG = 'Y') THEN
            INSERT INTO PROC_LOG(SQL_STR) VALUES (V_SQL);
        END IF;

		OPEN P_RS_LIST FOR V_SQL;

    ELSIF P_TYPE = 'SUB_LIST' THEN  /* 하부 상세 조회 리스트*/

        V_WERKS               := V_JSON.get_string('WERKS');        -- 플랜트
        V_STOR_LOC_CD         := V_JSON.get_string('STOR_LOC_CD'); 

        V_SQL := ' SELECT  mas028.WERKS             AS "WERKS",             -- 플랜트
                           mas028.STOR_LOC_CD       AS "STOR_LOC_CD",       -- 저장위치
                           mas028.LOC_CD            AS "LOC_CD",            -- 로케이션 코드
                           mas028.LOC_NM            AS "LOC_NM",            -- 로케이션 명
                           mas028.MACH_CD           AS "MACH_CD",           -- 설비코드
                           mas012.MACH_NM           AS "MACH_NM",           -- 설비명
                           mas028.USE_YN            AS "USE_YN",            -- 사용유무
                           mas028.REGDATE           AS "REGDATE",
                           NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = mas028.REGID),'''') AS "REGNM",
                           mas028.UPDDATE           AS "UPDDATE",
                           NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = mas028.UPDID),'''') AS "UPDNM"
                     FROM  TB_MAS028 mas028,    -- 로케이션
                           TB_MAS003 mas003,    -- 저장위치
                           TB_MAS012 mas012     -- 설비 마스터
                    WHERE  mas028.WERKS = mas003.WERKS(+)
                      AND  mas028.STOR_LOC_CD = mas003.STOR_LOC_CD(+)
                      AND  mas028.MACH_CD = mas012.MACH_CD(+)
                      AND  mas028.WERKS = ''' || V_WERKS || '''
                      AND  mas028.STOR_LOC_CD = '''|| V_STOR_LOC_CD ||'''
                 ORDER BY  mas028.WERKS, mas028.STOR_LOC_CD, mas028.LOC_CD ';

        OPEN P_RS_LIST FOR V_SQL;								

    ELSIF P_TYPE = 'SAVE' THEN
        RETURN;

    ELSIF P_TYPE = 'SUB_SAVE' THEN
        V_ARR_HEAD        := V_JSON.get_array('head');
        V_ARR_LIST        := V_JSON.get_array('list');

        FOR i IN 0..V_ARR_HEAD.get_size-1 LOOP
            V_OBJ2          := TREAT (V_ARR_HEAD.get (i) AS json_object_t);
            V_OBJ2          := TREAT (V_OBJ2.get ('map') AS json_object_t);

            V_WERKS         := V_OBJ2.get_string('WERKS');
			V_STOR_LOC_CD   := V_OBJ2.get_string('STOR_LOC_CD');
            V_WCS_STOR_LOC_CD   := V_OBJ2.get_string('WCS_STOR_LOC_CD');

            IF V_OBJ2.get_string('GRowState') = 'U' THEN
                UPDATE TB_MAS003
                   SET WCS_STOR_LOC_CD = V_WCS_STOR_LOC_CD,
                       UPDDATE      = SYSDATE,
                       UPDID        = V_SESS_USER_ID
                 WHERE WERKS        = V_WERKS
                   AND STOR_LOC_CD  = V_STOR_LOC_CD;
            END IF;
        END LOOP;

        FOR i IN 0..V_ARR_LIST.get_size-1 LOOP

                V_OBJ           := TREAT (V_ARR_LIST.get (i) AS json_object_t);
                V_OBJ           := TREAT (V_OBJ.get ('map') AS json_object_t);

				V_WERKS         := V_OBJ.get_string('WERKS');
				V_STOR_LOC_CD   := V_OBJ.get_string('STOR_LOC_CD');
                V_LOC_CD        := V_OBJ.get_string('LOC_CD');
                V_LOC_NM        := V_OBJ.get_string('LOC_NM');
                V_MACH_CD       := V_OBJ.get_string('MACH_CD');
                V_USE_YN      := V_OBJ.get_string('USE_YN');

                IF V_OBJ.get_string('GRowState') = 'C' THEN

                    IF (V_RUN_SQL = 'Y') THEN

                        INSERT INTO TB_MAS028
                        (
                            WERKS,
                            STOR_LOC_CD,
                            LOC_CD,
                            LOC_NM,
                            MACH_CD,
                            USE_YN,
                            REGDATE,
                            REGID
                        ) VALUES (
                            V_WERKS,
                            V_STOR_LOC_CD,
                            V_LOC_CD,
                            V_LOC_NM,
                            V_MACH_CD,
                            'Y',
							SYSDATE, 
							V_SESS_USER_ID
					    );

                    END IF;

                ELSIF V_OBJ.get_string('GRowState') = 'U' THEN

                    IF (V_RUN_SQL = 'Y') THEN

                        UPDATE TB_MAS028
                           SET LOC_NM       = V_LOC_NM,
                               MACH_CD      = V_MACH_CD,
                               UPDDATE      = SYSDATE,
                               UPDID        = V_SESS_USER_ID
                         WHERE WERKS        = V_WERKS
                           AND STOR_LOC_CD  = V_STOR_LOC_CD
                           AND LOC_CD       = V_LOC_CD;

                    END IF;                   

				ELSIF V_OBJ.get_string('GRowState') = 'D' THEN

					DELETE FROM TB_MAS028 WHERE WERKS = V_WERKS AND STOR_LOC_CD = V_STOR_LOC_CD AND LOC_CD = V_LOC_CD;

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
