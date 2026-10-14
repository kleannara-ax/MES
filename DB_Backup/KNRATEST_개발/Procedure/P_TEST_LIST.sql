--------------------------------------------------------
--  DDL for Procedure P_TEST_LIST
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."P_TEST_LIST" (  v_number IN varchar2,p_rc OUT SYS_REFCURSOR )
as
begin
	open p_rc for 
		select '1' col1, v_number col2  from dual UNION ALL
		select '2' col1, v_number col2  from dual UNION ALL
		select '3' col1, v_number col2  from dual 
	;
END;


/
