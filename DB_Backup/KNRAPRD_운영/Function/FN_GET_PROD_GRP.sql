--------------------------------------------------------
--  DDL for Function FN_GET_PROD_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "KNRAMES"."FN_GET_PROD_GRP" 
(
    P_WERKS    IN VARCHAR2,
    P_MATNR    IN VARCHAR2
)
    RETURN CHAR IS
/*=============================================================================*
 * FUNCTION NAME: FN_GET_PROD_GRP
 *   1)INPUT VALUE
 *      P_WERKS: 플랜트 
 *   2)OUTPUT VALUE
 *      R_PROD_GRP: 제품군 코드
 * CREATE DATE  : 2022/05/13
 * DESCRIPTION  :
 * REVERSION HISTORY
 * ------------ ------- ------------- -----------------------------------------
 *    Date        Ver       Name          Description
 * ------------ ------- ------------- -----------------------------------------
 * 2022/05/13    1.0.0   김성하        Initial Version
 * yyyy/mm/dd    1.0.1   홍판서         변경사유 기술
==============================================================================*/
    R_PROD_GRP        VARCHAR2(10);    -- 제품군 코드

BEGIN

    R_PROD_GRP := '';

    IF P_WERKS = 'P100' THEN  -- 제지 플랜트
        R_PROD_GRP  :=  'P';  -- 제지
        RETURN R_PROD_GRP;

    ELSIF P_WERKS = 'P200' THEN -- 화장지 플랜트
        R_PROD_GRP  :=  'T';  -- 화장지
        RETURN R_PROD_GRP;

    ELSIF P_WERKS = 'P300' THEN  -- 패드 플랜트
        R_PROD_GRP  :=  'S';  -- 패드
        RETURN R_PROD_GRP;

    ELSIF P_WERKS = 'P400' THEN

        R_PROD_GRP  :=  'S';  -- 패드
        RETURN R_PROD_GRP;

    ELSIF P_WERKS = 'P500' THEN -- 음성 플랜트
        R_PROD_GRP  :=  'B';  -- 기저귀
        RETURN R_PROD_GRP;

    END IF;


END;


/
