--------------------------------------------------------
--  DDL for Function FN_GET_MDOCNO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "KNRAMES"."FN_GET_MDOCNO" 
(
    P_PLANT             IN VARCHAR2,
    P_IFID              IN VARCHAR2
)
RETURN CHAR IS
/*=============================================================================*
 * FUNCTION NAME: FN_GET_MDOCSEQ
 *   1)INPUT VALUE
 *      P_PLANT:   공장
 *      P_IFID:    인터페이스ID 
 *   2)OUTPUT VALUE
 *      R_CODE: MES문서번호
 * CREATE DATE  : 2022/04/20
 * DESCRIPTION  : 공장별 인터페이스ID에 따른 문서번호를 채번해서 리턴 한다.                                                   
 * REVERSION HISTORY
 * ------------ ------- ------------- ----------------------------------------- 
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ----------------------------------------- 
 * 2022/04/20    1.0.0   김성하         Initial Version
 * 2022/05/14    1.0.0   유상호         자리숫 20자리로 변경
 * yyyy/mm/dd    1.0.1   홍판서         변경사유 기술
==============================================================================*/

R_CODE VARCHAR2(100);

BEGIN

    R_CODE := ' ';

    BEGIN
        /* MES(M - 1) + 인터페이스 ID(IF402 - 5) + 전송일시(10) + 순서(4) = 20  
           CPMES_IF_00922042012121200001                          */
        BEGIN
            SELECT  P_PLANT || P_IFID || TO_CHAR(SYSDATE,'YYMMDDHH24MI') || LPAD(SEQ_MDOCNO.NEXTVAL,4,'0')
              INTO  R_CODE
              FROM  DUAL ;

        EXCEPTION
        WHEN NO_DATA_FOUND THEN
            R_CODE := P_PLANT || P_IFID || TO_CHAR(SYSDATE,'YYMMDDHH24MISS') || '00001';
        END;           

        IF LTRIM(R_CODE) IS NULL THEN
            R_CODE := ' ';
        END IF;

    EXCEPTION
    WHEN OTHERS THEN
        R_CODE := ' ';
    END;

    RETURN R_CODE;  

END;


/
