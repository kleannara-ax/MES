--------------------------------------------------------
--  DDL for Procedure P_TEST
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."P_TEST" ( V_P1 IN varchar2, V_P2 OUT varchar2)
IS 
BEGIN
	 V_P2 := V_P1 || '00001';
	 -- DBMS_OUTPUT.PUT_LINE('PARA1 = ' || V_P2);
END P_TEST;


/
