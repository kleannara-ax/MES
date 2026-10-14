--------------------------------------------------------
--  DDL for Procedure P_TEST1
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."P_TEST1" ( V_P1 IN varchar2)
IS
BEGIN
	 DBMS_OUTPUT.PUT_LINE('PARA1 = ' || V_P1 || '00001');
END ;


/
