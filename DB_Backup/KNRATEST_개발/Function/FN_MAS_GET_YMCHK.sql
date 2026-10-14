--------------------------------------------------------
--  DDL for Function FN_MAS_GET_YMCHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "KNRAMES"."FN_MAS_GET_YMCHK" 
(  i_WERKS   IN  VARCHAR2 ,
   i_YYMM    IN  VARCHAR2  
 )
  RETURN  VARCHAR2
IS
  o_RETURN     VARCHAR2(1) ;
  v_VALID_DATE VARCHAR2(100);

BEGIN

    v_VALID_DATE := f_valid_date(P_STR_DATE => substr(i_YYMM,1,6), P_DATE_FORMAT =>'yyyymm' ) ;

    IF v_VALID_DATE = 'TRUE' THEN
        SELECT  YMCHK
          INTO  o_RETURN
          FROM  TB_MAS011
         WHERE  WERKS = i_WERKS
          AND   YYMM  = i_YYMM ;
    ELSE
        o_RETURN := 'N' ;
    END IF ;

    RETURN(nvl(o_RETURN,'Y'));

EXCEPTION
    WHEN OTHERS THEN 
        RETURN 'Y' ;

END;

/
