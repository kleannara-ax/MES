--------------------------------------------------------
--  DDL for Procedure SP_BM0000_PROC_JSON
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_BM0000_PROC_JSON" (P_STR IN varchar2 ,P_RS OUT SYS_REFCURSOR )
AS
	V_SQL  varchar2(4000);
	P_RANGE_SQL varchar2(4000);
    jo  JSON_OBJECT_T;
BEGIN 
    DBMS_OUTPUT.PUT_LINE('SQL=========>' || P_STR);
	jo := JSON_OBJECT_T.parse(P_STR);

	P_RANGE_SQL := jo.get_string('RANGE_DATA_PARAM');
   insert into quiretest(inpram,inkey,maketime) values(P_RANGE_SQL,null,null);

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
		WHERE 1 = 1';


        V_SQL := V_SQL || P_RANGE_SQL;


       --파라미터 테스트
    insert into quiretest(inpram,inkey,maketime) values(V_SQL,null,null);

    DBMS_OUTPUT.PUT_LINE('SQL=========>' || V_SQL);

    OPEN P_RS FOR V_SQL;

END;

/
