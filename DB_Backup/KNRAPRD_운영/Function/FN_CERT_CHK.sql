--------------------------------------------------------
--  DDL for Function FN_CERT_CHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "KNRAMES"."FN_CERT_CHK" 
(
    P_USERID    IN VARCHAR2,
    P_CERT_NO   IN VARCHAR2
)
    RETURN CHAR IS
/*=============================================================================*
 * FUNCTION NAME: FN_GET_CM_VAL
 *   1)INPUT VALUE
 *      P_USERID: 사용자 ID
 *      P_CERT_NO: 인증번호
 *   2)OUTPUT VALUE
 *      R_CD_NM: 생산일자
 * CREATE DATE  : 2022/08/28
 * DESCRIPTION  :
 * REVERSION HISTORY
 * ------------ ------- ------------- -----------------------------------------
 *    Date        Ver       Name          Description
 * ------------ ------- ------------- -----------------------------------------
 * 2022/08/28    1.0.0   김기연        Initial Version
 * yyyy/mm/dd    1.0.1   홍판서         변경사유 기술
==============================================================================*/
    
    TEMP_STR	USRMA.USERG1%TYPE;--인증번호 임시저장
BEGIN
    --사용자 목록 조회
	BEGIN
	    SELECT USERG1
	      INTO TEMP_STR
	      FROM USRMA
	     WHERE 1=1
	       AND USERID = P_USERID;
    EXCEPTION WHEN NO_DATA_FOUND THEN
    	--사용자정보가 없는 경우 N 반환
    	RETURN 'N';
    END;
      
	IF TEMP_STR = P_CERT_NO THEN
		--인증완료시 S반환
		RETURN 'S';
	ELSE
		--인증 실패시 E 반환
		RETURN 'E';
	END IF;
END;

/
