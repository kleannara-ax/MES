--------------------------------------------------------
--  DDL for Procedure MES_BM0000_S01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."MES_BM0000_S01" 
(
	P_TYPE           IN    varchar2, -- LIST, SAVE
	P_JSON_STR       IN    CLOB ,
	P_SUCCESS       OUT    varchar2,
	P_RS_LIST       OUT    SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : {호출 프로그램 ID 기술}
 * PROGRAM NAME  : {호출 프로그램 명 기술}
 * VERSION       : {최종 버전 기술}
 * DESCRIPTION   : {프로그램에 대한 상세한 내용 기술}
 *                 
 * AUTHOR NAME   : 홍길동{최초 작성자 명 기술}
 * CREATE DATE   : yyyy/mmdd {최초 작성일자 기술}
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * yyyy/mm/dd    1.0.0   홍길동         Initial Version
 * yyyy/mm/dd    1.0.1   홍판서         변경사유 기술
 *==============================================================================
 *  관련 테이블
 *       - [CMCDM] : (CRUD) 공통코드 마스트                                       
 *       - [CMCDV] : (CRUD) 공통코드 상세                                       
 *=============================================================================*/
AS
    V_PRG_NM          VARCHAR2(100)  := 'MES_BM0000_S01';     -- PROCEDURE NAME
    -- 오라클 에러 처리용 변수 선언
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5)           := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);

   -- V_RTN_CLOB       CLOB;
   -- V_RTN_CURSOR     SYS_REFCURSOR;
   -- V_ERROR          CLOB;

    -- JSON을 위한 변수 선언
    V_JSON           JSON_OBJECT_T;
    V_ARR_LIST       JSON_ARRAY_T;
    V_ARR_HEAD       JSON_ARRAY_T;
    V_OBJ            JSON_OBJECT_T;

    -- 세션값 처리용 변수 선언
    V_SQL            CLOB;
    V_RUN_SQL        varchar2(1);
    V_RANGE_SQL      varchar2(4000);
    V_DEBUG          varchar2(1);

    -- 세션값 처리용 변수 선언
    V_PLT_CD         varchar2(2);
    V_SESS_USER_ID   varchar2(20);

   -- N_7_THI          GMASTR007.SIZE_THI%TYPE;
    V_TMP            varchar2(100);
    V_TMP0           varchar2(100);
    V_TMP1           varchar2(100);
	V_TMP2           varchar2(100);
	V_TMP3           varchar2(100);
	V_TMP4           varchar2(100);
	V_TMP5           varchar2(100);
	V_TMP6           varchar2(100);
	V_TMP7           varchar2(100);
	V_TMP8           varchar2(100);
	V_TMP9           varchar2(100);
	V_TMP10          varchar2(100);
	V_TMP11          varchar2(100);
	V_TMP12          varchar2(100);
	V_TMP13          varchar2(100);
	V_TMP14          varchar2(100);

BEGIN

   OPEN P_RS_LIST FOR 
   SELECT NULL FROM DUAL WHERE ROWNUM = 0;

   V_DEBUG := 'N';
   V_RUN_SQL := 'Y';
    DBMS_OUTPUT.PUT_LINE('SQL1=========>' || P_JSON_STR);
   V_JSON := JSON_OBJECT_T.parse(P_JSON_STR);

   V_SESS_USER_ID:= V_JSON.get_string('SES_USER_ID');
   V_PLT_CD:= V_JSON.get_string('SES_PLNTKY');

   IF (P_TYPE = 'LIST') THEN /*상단 조회 리스트*/

        V_RANGE_SQL := V_JSON.get_string('RANGE_SQL');

        V_SQL := ' SELECT DISTINCT
                          CM.CMCDKY AS "CMCDKY"
                        , CM.SHORTX AS "SHORTX"
                        , CM.DBFILD AS "DBFILD"
                        , CM.USARL1 AS "USARL1"
                        , CM.USARL2 AS "USARL2"
                        , CM.USARL3 AS "USARL3"
                        , CM.USARL4 AS "USARL4"
                        , CM.USARL5 AS "USARL5"
                        , CM.SYONLY AS "SYONLY"
                        , CM.CREDAT || '' '' || CM.CRETIM AS "REGDATE"
                        , CM.CREUSR AS "REGID"
                        , NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = CM.CREUSR),'' '') AS "REGNM"
                        , CM.LMODAT || '' '' || CM.LMOTIM AS "UPDDATE"
                        , CM.LMOUSR AS "UPDID"
                        , NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = CM.LMOUSR),'' '') AS "UPDNM"
                        , CM.CMCDKY AS "KEY"
                        , '' '' AS GRowState
                  FROM CMCDM CM
                  INNER JOIN CMCDV CV
                    ON CM.CMCDKY = CV.CMCDKY
                 WHERE 1 = 1';

        V_SQL := V_SQL || V_RANGE_SQL;
		V_SQL := V_SQL || ' ORDER BY CM.CMCDKY';

--        V_DEBUG := 'Y';
--
--        IF (V_DEBUG = 'Y') THEN
--            INSERT INTO PROC_LOG(SQL_STR) VALUES (V_SQL);
--        END IF;

        DBMS_OUTPUT.PUT_LINE('SQL2=========>' || V_SQL);				

		OPEN P_RS_LIST FOR V_SQL;

   ELSIF (P_TYPE = 'SUB_LIST') THEN  /* 하부 상세 조회 리스트*/

        V_RANGE_SQL := V_JSON.get_string('RANGE_SQL');
		V_TMP       := V_JSON.get_string('CMCDKY');

        V_SQL := 'SELECT  CV.CMCDKY AS "CMCDKY"
  				        , CV.CMCDVL AS "CMCDVL"
						, CV.CDESC1 AS "CDESC1"
						, CV.CDESC2 AS "CDESC2"
						, CV.USARG1 AS "USARG1"
						, CV.USARG2 AS "USARG2"
						, CV.USARG3 AS "USARG3"
						, CV.USARG4 AS "USARG4"
						, CV.USARG5 AS "USARG5"
                        , CV.USE_YN AS "USE_YN"
						, CV.CREDAT || '' '' || CV.CRETIM AS "REGDATE"
						, CV.CREUSR AS "REGID"
						, NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = CV.CREUSR),'' '') AS "REGNM"
						, CV.LMODAT || '' '' || CV.LMOTIM AS "UPDDATE"
						, CV.LMOUSR AS "UPDID"
						, NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = CV.LMOUSR),'' '') AS "UPDNM"
						, CV.CMCDKY AS "KEY"
						, '' '' AS GRowState
                   FROM   CMCDV CV
                  WHERE   1 = 1';

        V_SQL := V_SQL || 'AND CV.CMCDKY = ''' || V_TMP || '''';
        V_SQL := V_SQL || V_RANGE_SQL;
		V_SQL := V_SQL || ' ORDER BY CV.CMCDKY, CV.CMCDVL ';

        IF (V_DEBUG = 'Y') THEN
            INSERT INTO PROC_LOG(SQL_STR) VALUES (V_SQL);
        END IF;

        DBMS_OUTPUT.PUT_LINE('SQL3=========>' || V_SQL);

		OPEN P_RS_LIST FOR V_SQL;

    ELSIF P_TYPE = 'SAVE' THEN

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


                IF V_OBJ.get_string('GRowState') = 'C' THEN

                    IF (V_RUN_SQL = 'Y') THEN

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
                            CREUSR
                        ) VALUES (
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
							V_SESS_USER_ID
					    );

                    END IF;

--                    IF (V_DEBUG = 'Y') THEN
--                        
--                        INSERT INTO PROC_LOG(SQL_STR) VALUES(V_SQL);
--                        
--                    END IF;

                ELSIF V_OBJ.get_string('GRowState') = 'U' THEN  

                    IF (V_DEBUG = 'Y') then
                        DBMS_OUTPUT.PUT_LINE('SQL====debug=====>' );
                    END IF;

                    IF (V_RUN_SQL = 'Y') THEN

                        UPDATE CMCDM 
                           SET SHORTX = V_TMP1,
                               DBFILD = V_TMP2,
                               USARL1 = V_TMP3,
                               USARL2 = V_TMP4,
                               USARL3 = V_TMP5,
                               USARL4 = V_TMP6,
                               USARL5 = V_TMP7,
                               SYONLY = V_TMP8,
                               LMODAT = TO_CHAR(SYSDATE, 'YYYYMMDD'),
                               LMOTIM = TO_CHAR(SYSDATE, 'HH24MISS'),
                               LMOUSR = V_SESS_USER_ID
                         WHERE CMCDKY = V_TMP0;

                    END IF;

                    IF (V_DEBUG = 'Y') THEN
                        DBMS_OUTPUT.PUT_LINE('SQL====debug=====>' );
                    END IF;

				ELSIF V_OBJ.get_string('GRowState') = 'D' THEN

					DELETE FROM CMCDV WHERE CMCDKY = V_TMP0;
					DELETE FROM CMCDM WHERE CMCDKY = V_TMP0;

                END IF;

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
				V_TMP9 := V_OBJ.get_string('USE_YN');				

                IF V_OBJ.get_string('GRowState') = 'C' THEN

                    IF (V_RUN_SQL = 'Y') THEN

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
                            USE_YN,
                            CREDAT,
                            CRETIM,
                            CREUSR
                       ) VALUES (
							V_TMP0,
							V_TMP1,
							V_TMP2,
							V_TMP3,
							V_TMP4,
							V_TMP5,
							V_TMP6,
							V_TMP7,
							V_TMP8,
                            V_TMP9,
							TO_CHAR(SYSDATE, 'YYYYMMDD'),
                            TO_CHAR(SYSDATE, 'HH24MISS'),
							V_SESS_USER_ID
                         );

                    END IF;

--                    IF (V_DEBUG = 'Y') THEN
--                        
--                        INSERT INTO PROC_LOG(SQL_STR) VALUES(V_SQL);
--                        
--                    END IF;

                ELSIF V_OBJ.get_string('GRowState') = 'U' THEN

                    IF (V_RUN_SQL = 'Y') THEN
                        V_TMP  := NVL(V_OBJ.get_string('CMCDKY'),'');
                        V_TMP1 := NVL(V_OBJ.get_string('CMCDVL'),'');

                    END IF;

                    IF (V_DEBUG = 'Y') THEN
                        DBMS_OUTPUT.PUT_LINE('SQL====debug=====>' );
                    END IF;

                    IF (V_RUN_SQL = 'Y') THEN

                        UPDATE CMCDV
                           SET CDESC1 = V_TMP2,
                               CDESC2 = V_TMP3,
                               USARG1 = V_TMP4,
                               USARG2 = V_TMP5,
                               USARG3 = V_TMP6,
                               USARG4 = V_TMP7,
                               USARG5 = V_TMP8,
                               USE_YN = V_TMP9,
                               LMODAT = TO_CHAR(SYSDATE, 'YYYYMMDD'),
                               LMOTIM = TO_CHAR(SYSDATE, 'HH24MISS'),
                               LMOUSR = V_SESS_USER_ID
                         WHERE CMCDKY = V_TMP0
                           AND CMCDVL = V_TMP1;

                    END IF;

                    IF (V_DEBUG = 'Y') THEN
                        DBMS_OUTPUT.PUT_LINE('SQL====debug=====>' );
                    END IF;

				ELSIF V_OBJ.get_string('GRowState') = 'D' THEN

				 	  DELETE FROM CMCDV WHERE CMCDKY = V_TMP0 AND CMCDVL = V_TMP1;

                END IF;

            END LOOP;
    END IF;

    P_SUCCESS := 'Y';

    COMMIT;

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
       -- RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
END;

/
