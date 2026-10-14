
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SZP_MES_PLSQL_LOG" 
( 
	v_message IN VARCHAR2,
    v_div IN VARCHAR2
) AS
  PRAGMA AUTONOMOUS_TRANSACTION;

  v_sortnum       number(10);

BEGIN

  SELECT SEQ_PLLOG.NEXTVAL INTO v_sortnum FROM DUAL;

  --DBMS_OUTPUT.PUT_LINE( to_char(sysdate, 'HH24MISS') || '-v_message:' ||v_message);
  INSERT INTO PLLOG (LOGSEQ, CREDAT, CRETIM, MESSGE, DIV)
  VALUES (v_sortnum, to_char(sysdate, 'YYYYMMDD'), to_char(sysdate, 'HH24MISS'), v_message, v_div);

  COMMIT;

END;
/
