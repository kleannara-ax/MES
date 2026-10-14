--------------------------------------------------------
--  DDL for Procedure SP_MAS25_S01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_MAS25_S01" (
	P_TYPE           IN    varchar2, -- LIST, SAVE
	P_JSON_STR       IN    CLOB ,
	P_SUCCESS       OUT    varchar2,
	P_RS_LIST       OUT    SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : MAS25{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 공장지 정보 관리{호출 프로그램 명 기술}
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 공장지 정보를 관리한다.{프로그램에 대한 상세한 내용 기술}
 *                 
 * AUTHOR NAME   : 여한진{최초 작성자 명 기술}
 * CREATE DATE   : 2022/04/14 {최초 작성일자 기술}
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
 *       - [WAHMA] : (RU) 공장지 정보                                
 *=============================================================================*/

AS

    V_PRG_NM          VARCHAR2(100)  := 'SP_MAS25_S01';     -- PROCEDURE NAME

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

    -- 세션값 처리용 변수선언 영역
    V_SQL            CLOB;
    V_RUN_SQL        varchar2(1);
    V_RANGE_SQL      varchar2(4000);
    V_DEBUG          varchar2(1);

    -- 세션값 처리용 변수선언 영역
    V_PLT_CD         varchar2(4);
    V_SESS_USER_ID   varchar2(20);

    -- 조건절 처리용 변수선언 영역

    -- 리스트(그리드)의 값을 할당하기 위한 변수선언 영역
    V_COMPKY         WAHMA.COMPKY%TYPE;
    V_WAREKY         WAHMA.WAREKY%TYPE;
    V_DELMAK         WAHMA.DELMAK%TYPE;
    V_NAME02         WAHMA.NAME02%TYPE;
    V_ADDR01         WAHMA.ADDR01%TYPE;
    V_NAME01         WAHMA.NAME01%TYPE;
    V_POSTCD         WAHMA.POSTCD%TYPE;
    V_NATNKY         WAHMA.NATNKY%TYPE;
    V_VATREG         WAHMA.VATREG%TYPE;
    V_FAXTL1         WAHMA.FAXTL1%TYPE;
    V_TELN01         WAHMA.TELN01%TYPE;
    V_WADN01         WAHMA.WADN01%TYPE;
    V_WADT01         WAHMA.WADT01%TYPE;
    V_WADM01         WAHMA.WADM01%TYPE;

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

   IF P_TYPE = 'LIST' THEN /*상단 조회 리스트*/

        V_SQL := ' SELECT  A.WAREKY   AS "WAREKY",
                           A.COMPKY   AS "COMPKY",
                           A.NAME01   AS "NAME01",
                           A.NAME02   AS "NAME02",
                           A.ADDR01   AS "ADDR01",
                           A.POSTCD   AS "POSTCD",
                           A.NATNKY   AS "NATNKY",
                           A.VATREG   AS "VATREG",
                           A.FAXTL1   AS "FAXTL1",
                           A.TELN01   AS "TELN01",
                           A.WADM01   AS "WADM01",
                           A.WADN01   AS "WADN01",
                           A.TSPKEY   AS "TSPKEY",
                           A.DELMAK   AS "DELMAK",
                           A.CHKSHA   AS "CHKSHA",
                           A.NAME03   AS "NAME03",
                           A.ADDR02   AS "ADDR02",
                           A.ADDR03   AS "ADDR03",
                           A.ADDR04   AS "ADDR04",
                           A.ADDR05   AS "ADDR05",
                           A.CITY01   AS "CITY01",
                           A.REGN01   AS "REGN01",
                           A.TELN02   AS "TELN02",
                           A.TELN03   AS "TELN03",
                           A.FAXTL2   AS "FAXTL2",
                           A.TAXCD1   AS "TAXCD1",
                           A.TAXCD2   AS "TAXCD2",
                           A.POBOX1   AS "POBOX1",
                           A.POBPC1   AS "POBPC1",
                           A.WADT01   AS "WADT01",
                           A.WADT02   AS "WADT02",
                           A.EXCOMK   AS "EXCOMK",
                           A.INDOVA   AS "INDOVA",
                           A.PLOCOV   AS "PLOCOV",
                           A.DRECLO   AS "DRECLO",
                           A.INDUAC   AS "INDUAC",
                           A.DSORKY   AS "DSORKY",
                           A.DRECLO   AS "DRECLO",
                           TO_CHAR(TO_DATE(A.CREDAT,''YYYYMMDD''),''YYYY-MM-DD'') || '' '' || TO_CHAR(TO_DATE(A.CRETIM,''HH24MISS''),''HH24:MI:SS'') AS "REGDATE",
                           NVL((SELECT NMLAST FROM USRMA B WHERE B.USERID = A.CREUSR),'''') AS "REGNM",
                           TO_CHAR(TO_DATE(A.LMODAT,''YYYYMMDD''),''YYYY-MM-DD'') || '' '' || TO_CHAR(TO_DATE(A.LMOTIM,''HH24MISS''),''HH24:MI:SS'') AS "UPDDATE",
                           NVL((SELECT NMLAST FROM USRMA B WHERE B.USERID = A.LMOUSR),'''') AS "UPDNM"
                      FROM WAHMA A
                     WHERE 1 = 1 ' ;

        V_SQL := V_SQL || V_RANGE_SQL;

		V_SQL := V_SQL || ' ORDER BY A.COMPKY, A.WAREKY';

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

				V_COMPKY        := V_OBJ.get_string('COMPKY');
				V_WAREKY        := V_OBJ.get_string('WAREKY');
				V_NAME01        := V_OBJ.get_string('NAME01');
				V_DELMAK        := V_OBJ.get_string('DELMAK');
                V_NAME02        := V_OBJ.get_string('NAME02');
				V_ADDR01        := V_OBJ.get_string('ADDR01');
				V_POSTCD        := V_OBJ.get_string('POSTCD');
                V_NATNKY        := V_OBJ.get_string('NATNKY');
				V_VATREG        := V_OBJ.get_string('VATREG');
				V_FAXTL1        := V_OBJ.get_string('FAXTL1');
                V_TELN01        := V_OBJ.get_string('TELN01');
				V_WADN01        := V_OBJ.get_string('WADN01');
				V_WADT01        := V_OBJ.get_string('WADT01');
                V_WADM01         := V_OBJ.get_string('WADM01');

                IF V_OBJ.get_string('GRowState') = 'U' THEN

                    IF (V_RUN_SQL = 'Y') THEN

                        UPDATE WAHMA
                           SET NAME01       = V_NAME01,
                               DELMAK       = V_DELMAK,
                               NAME02       = V_NAME02,
                               ADDR01       = V_ADDR01,
                               POSTCD       = V_POSTCD,
                               NATNKY       = V_NATNKY,
                               VATREG       = V_VATREG,
                               FAXTL1       = V_FAXTL1,
                               TELN01       = V_TELN01,
                               WADN01       = V_WADN01,
                               WADT01       = V_WADT01,
                               WADM01       = V_WADM01,
                               LMODAT       = TO_CHAR(SYSDATE, 'YYYYMMDD'),
                               LMOUSR       = V_SESS_USER_ID
                         WHERE WAREKY       = V_WAREKY
                           AND COMPKY       = V_COMPKY ;

                    END IF;

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
