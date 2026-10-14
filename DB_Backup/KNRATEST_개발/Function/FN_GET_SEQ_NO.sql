--------------------------------------------------------
--  DDL for Function FN_GET_SEQ_NO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "KNRAMES"."FN_GET_SEQ_NO" 
(
    P_SEQ_CD             IN VARCHAR2
)
RETURN VARCHAR2 IS
/*=============================================================================*
 * FUNCTION NAME: FN_GET_SEQ_NO
 *   1)INPUT VALUE
 *      P_SEQ_CD:      시퀀스명
 *   2)OUTPUT VALUE
 *      시퀀스 마지막 순번 VARCHAR2 
 * CREATE DATE  : 2022/09/23
 * DESCRIPTION  : 입력된 시퀀스명에 따라 신규번호를 채번해서 리턴 한다.                                                   
 * REVERSION HISTORY
 * ------------ ------- ------------- ----------------------------------------- 
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ----------------------------------------- 
 * 2022/09/23    1.0.0   김기연         최초생성
==============================================================================*/

R_CODE VARCHAR2(20);

BEGIN

    BEGIN
        BEGIN
	        --요청된 시퀀스 이름에 따라 다음 순번을 조회하여 반환
			EXECUTE IMMEDIATE 'SELECT ' || P_SEQ_CD || '.nextval from dual' INTO R_CODE;
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
        	--조회된 값이 없는 경우
            R_CODE := '';
        END;           

    EXCEPTION
    WHEN OTHERS THEN
        R_CODE := '';
    END;

    RETURN R_CODE;  

END;

/
