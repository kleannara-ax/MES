--------------------------------------------------------
--  DDL for Procedure SP_BM0000_PROC_CRUD
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_BM0000_PROC_CRUD" (
P_TYPE IN varchar2, 
P_JSON_STR IN varchar2 ,
P_SUCCESS OUT varchar2,
P_RS_LIST OUT SYS_REFCURSOR
)
AS
		V_RTN_CLOB CLOB;
		V_RTN_CURSOR SYS_REFCURSOR;
		V_ERROR CLOB;

    V_SQL CLOB;
    V_RANGE_SQL varchar2(4000);
    V_JSON  JSON_OBJECT_T;
    V_ARR_LIST  JSON_ARRAY_T;
    V_ARR_HEAD  JSON_ARRAY_T;
    V_OBJ    json_object_t;
    V_SESS_USER_ID varchar2(20);
    V_DEBUG varchar2(1);
    V_RUN_SQL varchar2(1);
    V_TMP varchar(100);
		V_TMP0 varchar(100);
    V_TMP1 varchar(100);
		V_TMP2 varchar(100);
		V_TMP3 varchar(100);
		V_TMP4 varchar(100);
		V_TMP5 varchar(100);
		V_TMP6 varchar(100);
		V_TMP7 varchar(100);
		V_TMP8 varchar(100);
		V_TMP9 varchar(100);
		V_TMP10 varchar(100);
		V_TMP11 varchar(100);
		V_TMP12 varchar(100);
		V_TMP13 varchar(100);
		V_TMP14 varchar(100);
BEGIN

   OPEN P_RS_LIST FOR 
   SELECT NULL FROM DUAL WHERE ROWNUM = 0;

    V_DEBUG := 'N';
    V_RUN_SQL := 'Y';
    DBMS_OUTPUT.PUT_LINE('SQL=========>' || P_JSON_STR);
    V_JSON := JSON_OBJECT_T.parse(P_JSON_STR);
    V_SESS_USER_ID:= V_JSON.get_string('SES_USER_ID');

    IF(P_TYPE = 'LIST') THEN
        V_RANGE_SQL := V_JSON.get_string('RANGE_DATA_PARAM');

        V_SQL := 'SELECT DISTINCT
            CM.CMCDKY AS "CMCDKY"
            , CM.SHORTX AS "SHORTX"
            , CM.DBFILD AS "DBFILD"
            , CM.USARL1 AS "USARL1"
            , CM.USARL2 AS "USARL2"
            , CM.USARL3 AS "USARL3"
            , CM.USARL4 AS "USARL4"
            , CM.USARL5 AS "USARL5"
            , CM.SYONLY AS "SYONLY"
            , CM.CREDAT AS "CREDAT"
            , CM.CRETIM AS "CRETIM"
            , CM.CREUSR AS "CREUSR"
            , NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = CM.CREUSR),'' '') AS "CUSRNM"
            , CM.LMODAT AS "LMODAT"
            , CM.LMOTIM AS "LMOTIM"
            , CM.LMOUSR AS "LMOUSR"
            , NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = CM.LMOUSR),'' '') AS "LUSRNM"
            , CM.CMCDKY AS "KEY"
            , '' '' AS STATUS
            FROM CMCDM CM
            INNER JOIN CMCDV CV
            ON CM.CMCDKY = CV.CMCDKY
            WHERE 1 = 1
            ORDER BY CM.CMCDKY';


        V_SQL := V_SQL || V_RANGE_SQL;

        if (V_DEBUG = 'Y') then
            INSERT INTO PROC_LOG(SQL_STR) VALUES (V_SQL);
        end if;


        DBMS_OUTPUT.PUT_LINE('SQL=========>' || V_SQL);


				OPEN P_RS_LIST FOR V_SQL;


    ELSIF P_TYPE = 'SAVE' then
        V_ARR_HEAD := V_JSON.get_array('head');
        V_ARR_LIST := V_JSON.get_array('list');
        FOR i IN 0..V_ARR_HEAD.get_size-1 LOOP
                V_OBJ := TREAT (V_ARR_HEAD.get (i) AS json_object_t);
                V_OBJ := TREAT (V_OBJ.get ('map') AS json_object_t);

                IF(V_OBJ.get_string('USARL1') = ' ') THEN
                    DBMS_OUTPUT.PUT_LINE('abcdefg===');
                END IF;

                DBMS_OUTPUT.PUT_LINE('===[0]==='|| V_OBJ.get_string('CMCDKY')
                    ||'===[1]==='|| V_OBJ.get_string('CMCDKY')
                    ||'===[2]==='|| V_OBJ.get_string('SHORTX')
                    ||'===[3]==='|| V_OBJ.get_string('DBFILD')
                    ||'===[4]==='|| V_OBJ.get_string('USARL1')
                    ||'===[5]==='|| V_OBJ.get_string('USARL2')
                    ||'===[6]==='|| V_OBJ.get_string('USARL3')
                    ||'===[7]==='|| V_OBJ.get_string('USARL4')
                    ||'===[8]==='|| V_OBJ.get_string('USARL5')
                    ||'===[9]==='|| V_OBJ.get_string('SYONLY')
                    );
								V_TMP0 := V_OBJ.get_string('CMCDKY');
								V_TMP1 := V_OBJ.get_string('SHORTX');
								V_TMP2 := V_OBJ.get_string('DBFILD');
								V_TMP3 := V_OBJ.get_string('USARL1');
								V_TMP4 := V_OBJ.get_string('USARL2');
								V_TMP5 := V_OBJ.get_string('USARL3');
								V_TMP6 := V_OBJ.get_string('USARL4');
								V_TMP7 := V_OBJ.get_string('USARL5');
								V_TMP8 := V_OBJ.get_string('SYONLY');


                if V_OBJ.get_string('STATUS') = 'C' THEN
                    if (V_RUN_SQL = 'Y') then
                        INSERT INTO CMCDM
                        (
                            CMCDKY,
                            SHORTX,
                            DBFILD,
                            USARL1,
                            USARL2,
                            USARL3,
                            USARL4,
                            USARL5,
                            SYONLY,
                            CREDAT,
                            CRETIM,
                            CREUSR,
                            LMODAT,
                            LMOTIM,
                            LMOUSR
                        )VALUES(
														 V_TMP0,
														 V_TMP1,
														 V_TMP2,
														 V_TMP3,
														 V_TMP4,
														 V_TMP5,
														 V_TMP6,
														 V_TMP7,
														 V_TMP8,
														 TO_CHAR(SYSDATE, 'YYYYMMDD'),
														 TO_CHAR(SYSDATE, 'HH24MISS'),
														 V_SESS_USER_ID,
														 TO_CHAR(SYSDATE, 'YYYYMMDD'),
														 TO_CHAR(SYSDATE, 'HH24MISS'),
														 V_SESS_USER_ID
												 );
                    end if;
                    if (V_DEBUG = 'Y') then
                        INSERT INTO PROC_LOG(SQL_STR) VALUES(V_SQL);
                    end if;
                elsif V_OBJ.get_string('STATUS') = 'U' THEN
                    if (V_RUN_SQL = 'Y') THEN
                        V_TMP := V_OBJ.get_string('CMCDKY');
                        DELETE FROM CMCDM WHERE CMCDKY = V_TMP;
                    end if;
                    if (V_DEBUG = 'Y') then
                        DBMS_OUTPUT.PUT_LINE('SQL====debug=====>' );
                    end if;
                    if (V_RUN_SQL = 'Y') then
                        INSERT INTO CMCDM (
                            CMCDKY,
                            SHORTX,
                            DBFILD,
                            USARL1,
                            USARL2,
                            USARL3,
                            USARL4,
                            USARL5,
                            SYONLY,
                            CREDAT,
                            CRETIM,
                            CREUSR,
                            LMODAT,
                            LMOTIM,
                            LMOUSR
                        )VALUES(
                             V_TMP0,
														 V_TMP1,
														 V_TMP2,
														 V_TMP3,
														 V_TMP4,
														 V_TMP5,
														 V_TMP6,
														 V_TMP7,
														 V_TMP8,
														 TO_CHAR(SYSDATE, 'YYYYMMDD'),
														 TO_CHAR(SYSDATE, 'HH24MISS'),
														 V_SESS_USER_ID,
														 TO_CHAR(SYSDATE, 'YYYYMMDD'),
														 TO_CHAR(SYSDATE, 'HH24MISS'),
														 V_SESS_USER_ID
												 );
                    end if;
                    if (V_DEBUG = 'Y') then
                        DBMS_OUTPUT.PUT_LINE('SQL====debug=====>' );
                    end if;
                end if;
            END LOOP;

        FOR i IN 0..V_ARR_LIST.get_size-1 LOOP
                V_OBJ := TREAT (V_ARR_LIST.get (i) AS json_object_t);
                V_OBJ := TREAT (V_OBJ.get ('map') AS json_object_t);
								DBMS_OUTPUT.PUT_LINE('22222===[0]==='|| V_OBJ.get_string('CMCDKY')
                    ||'===[1]==='|| V_OBJ.get_string('CMCDVL')
                    ||'===[2]==='|| V_OBJ.get_string('CDESC1')
                    ||'===[3]==='|| V_OBJ.get_string('CDESC2')
                    ||'===[4]==='|| V_OBJ.get_string('USARG1')
                    ||'===[5]==='|| V_OBJ.get_string('USARG2')
                    ||'===[6]==='|| V_OBJ.get_string('USARG3')
                    ||'===[7]==='|| V_OBJ.get_string('USARG4')
                    ||'===[8]==='|| V_OBJ.get_string('USARG5')
                    );
								V_TMP0 := V_OBJ.get_string('CMCDKY');
								V_TMP1 := V_OBJ.get_string('CMCDVL');
								V_TMP2 := V_OBJ.get_string('CDESC1');
								V_TMP3 := V_OBJ.get_string('CDESC2');
								V_TMP4 := V_OBJ.get_string('USARG1');
								V_TMP5 := V_OBJ.get_string('USARG2');
								V_TMP6 := V_OBJ.get_string('USARG3');
								V_TMP7 := V_OBJ.get_string('USARG4');
								V_TMP8 := V_OBJ.get_string('USARG5');


                if V_OBJ.get_string('STATUS') = 'C' THEN
                    if (V_RUN_SQL = 'Y') then
                        INSERT INTO CMCDV
                        (
                            CMCDKY,
                            CMCDVL,
                            CDESC1,
                            CDESC2,
                            USARG1,
                            USARG2,
                            USARG3,
                            USARG4,
                            USARG5,
                            CREDAT,
                            CRETIM,
                            CREUSR,
                            LMODAT,
                            LMOTIM,
                            LMOUSR
                        )VALUES(
														V_TMP0,
														V_TMP1,
														V_TMP2,
														V_TMP3,
														V_TMP4,
														V_TMP5,
														V_TMP6,
														V_TMP7,
														V_TMP8,
													  TO_CHAR(SYSDATE, 'YYYYMMDD'),
													  TO_CHAR(SYSDATE, 'HH24MISS'),
													  V_SESS_USER_ID,
													  TO_CHAR(SYSDATE, 'YYYYMMDD'),
													  TO_CHAR(SYSDATE, 'HH24MISS'),
													  V_SESS_USER_ID
                         );
                    end if;
                    if (V_DEBUG = 'Y') then
                        INSERT INTO PROC_LOG(SQL_STR) VALUES(V_SQL);
                    end if;
                elsif V_OBJ.get_string('STATUS') = 'U' THEN
                    if (V_RUN_SQL = 'Y') THEN
                        V_TMP := NVL(V_OBJ.get_string('CMCDKY'),'');
                        V_TMP1 := NVL(V_OBJ.get_string('CMCDVL'),'');
                        DELETE FROM CMCDV WHERE CMCDKY = V_TMP  AND CMCDVL = V_TMP1;
                    end if;

                    if (V_DEBUG = 'Y') then
                        DBMS_OUTPUT.PUT_LINE('SQL====debug=====>' );
                    end if;
                    if (V_RUN_SQL = 'Y') then
                        INSERT INTO CMCDV
                        (
                            CMCDKY,
                            CMCDVL,
                            CDESC1,
                            CDESC2,
                            USARG1,
                            USARG2,
                            USARG3,
                            USARG4,
                            USARG5,
                            CREDAT,
                            CRETIM,
                            CREUSR,
                            LMODAT,
                            LMOTIM,
                            LMOUSR
                        )VALUES(
														V_TMP0,
														V_TMP1,
														V_TMP2,
														V_TMP3,
														V_TMP4,
														V_TMP5,
														V_TMP6,
														V_TMP7,
														V_TMP8,
													  TO_CHAR(SYSDATE, 'YYYYMMDD'),
													  TO_CHAR(SYSDATE, 'HH24MISS'),
													  V_SESS_USER_ID,
													  TO_CHAR(SYSDATE, 'YYYYMMDD'),
													  TO_CHAR(SYSDATE, 'HH24MISS'),
													  V_SESS_USER_ID
                         );
                    end if;
                    if (V_DEBUG = 'Y') then
                        DBMS_OUTPUT.PUT_LINE('SQL====debug=====>' );
                    end if;
                end if;
            END LOOP;
    END IF;

	  P_SUCCESS := 'Y';


    EXCEPTION
       WHEN OTHERS THEN
			 P_SUCCESS := 'N';
END;


/
