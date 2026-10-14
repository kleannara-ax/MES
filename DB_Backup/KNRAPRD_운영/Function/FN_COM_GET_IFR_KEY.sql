--------------------------------------------------------
--  DDL for Function FN_COM_GET_IFR_KEY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "KNRAMES"."FN_COM_GET_IFR_KEY" 
  RETURN VARCHAR2
IS
  o_RETURN  VARCHAR2(30) ;

BEGIN

    SELECT 'M' || LPAD(seq_get_ifr_key.nextval,29,'0')
      INTO o_RETURN
      FROM dual ;

    RETURN nvl(o_RETURN,'M' || LPAD(0,29,'0')) ;

EXCEPTION
    WHEN OTHERS THEN 
        RETURN 'M' || LPAD(0,29,'0') ;

END;

/
