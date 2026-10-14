--------------------------------------------------------
--  DDL for Procedure P_NW_LIST
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."P_NW_LIST" P_NW_LIST
( 
  P_WAREKY    IN varchar2 , 
  P_RANGE_SQL IN varchar2 , 
  P_AREATY    IN varchar2 , 
  p_rc        OUT SYS_REFCURSOR 
)
AS
	V_SQL  varchar2(4000);
BEGIN 

	V_SQL := 'SELECT WAREKY
		, AREAKY
		, AREATY
		,(SELECT CDESC1 FROM CMCDV C WHERE CMCDKY = ''AREATY'' AND C.CMCDVL = A.AREATY)
		AS AREATYT
		, SHORTX
		, NEGSTK
		, INDCDO
		, INDAES
		, INDSHW
		, INDULT
		, RDDALL
		, CREDAT
		, CRETIM
		, CREUSR
		, NVL((SELECT NMLAST FROM USRMA B WHERE B.USERID = A.CREUSR),'' '') AS CUSRNM
		, LMODAT
		, LMOTIM
		, LMOUSR
		, NVL((SELECT NMLAST FROM USRMA B WHERE B.USERID = A.LMOUSR),'' '') AS LUSRNM
		, INDBZL
		, INDARC
		, UPDCHK
		FROM AREMA A
		WHERE 1 = 1';

	IF P_WAREKY IS NULL AND P_WAREKY <> '' THEN
        V_SQL := V_SQL||' AND WAREKY = '|| P_WAREKY;
    END IF;   

	IF P_RANGE_SQL IS NULL AND P_RANGE_SQL <> '' THEN
        V_SQL := V_SQL||' '|| P_RANGE_SQL;
    END IF; 

	IF P_AREATY IS NULL AND P_AREATY <> '' THEN
        V_SQL := V_SQL||' AND AREATY = '|| P_AREATY;
    END IF;  

    DBMS_OUTPUT.PUT_LINE('SQL=========>' || V_SQL);

    OPEN p_rc FOR V_SQL;

END;

/
