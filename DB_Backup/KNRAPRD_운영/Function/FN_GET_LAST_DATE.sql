--------------------------------------------------------
--  DDL for Function FN_GET_LAST_DATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "KNRAMES"."FN_GET_LAST_DATE" 
(
    P_WERKS    IN VARCHAR2,
    P_MACH_CD  IN VARCHAR2
)
  RETURN VARCHAR2 IS
/*=============================================================================*
 * FUNCTION NAME: FN_GET_LAST_DATE
 *   1)INPUT VALUE
 *      P_WERKS:      플랜트
 *      P_MACH_CD:    설비코드
 *   2)OUTPUT VALUE
 *      마지막 작업 일시 DATE 
 * CREATE DATE  : 2022/04/20
 * DESCRIPTION  : 공장별 인터페이스ID에 따른 문서번호를 채번해서 리턴 한다.                                                   
 * REVERSION HISTORY
 * ------------ ------- ------------- ----------------------------------------- 
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ----------------------------------------- 
 * 2022/05/14    1.0.0   유상호         자리숫 20자리로 변경
 * yyyy/mm/dd    1.0.1   홍판서         변경사유 기술
==============================================================================*/

    R_CODE VARCHAR2(20);

BEGIN

    R_CODE := TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS');

    BEGIN
        BEGIN
            IF P_WERKS = 'P100' THEN

                SELECT CASE WHEN MAX(END_DATE) IS NULL THEN TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS') 
                            ELSE TO_CHAR(MAX(END_DATE), 'YYYYMMDDHH24MISS') END 
                  INTO R_CODE
                  FROM (
                        SELECT MAX(PRD_END_DATE) AS END_DATE
                          FROM TB_WRK002
                         WHERE WERKS = P_WERKS
                           AND MACH_CD = P_MACH_CD
                           AND PRD_END_DATE <= SYSDATE
                           AND NVL(CNL_YN, 'N') = 'N'
                        UNION ALL
                        SELECT MAX(END_DATE) AS END_DATE
                          FROM TB_WRK003
                         WHERE WERKS = P_WERKS
                           AND MACH_CD = P_MACH_CD
                           AND IN_OUT = 'N'
                           AND NVL(CNL_YN, 'N') = 'N'
                           AND END_DATE <= SYSDATE
--                        UNION ALL
--                        SELECT MAX(STR_DATE)  AS END_DATE
--                          FROM TB_WRK013
--                         WHERE WERKS = P_WERKS
--                           AND MACH_CD = P_MACH_CD
--                           AND IN_OUT = 'N'  
                        );

            ELSE
                SELECT CASE WHEN MAX(END_DATE) IS NULL THEN TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS') 
                            ELSE TO_CHAR(MAX(END_DATE), 'YYYYMMDDHH24MISS')  END 
                  INTO R_CODE
                  FROM (
                        SELECT MAX(PRD_END_DATE)  AS END_DATE
                          FROM TB_WRK001
                         WHERE WERKS = P_WERKS
                           AND MACH_CD = P_MACH_CD
                           AND NVL(CNL_YN, 'N') = 'N'
                        UNION ALL
                        SELECT MAX(END_DATE)  AS END_DATE
                          FROM TB_WRK003
                         WHERE WERKS = P_WERKS
                           AND MACH_CD = P_MACH_CD
                           --AND IN_OUT = 'N'
                           AND NVL(CNL_YN, 'N') = 'N'
--                        UNION ALL
--                        SELECT MAX(STR_DATE)  AS END_DATE
--                          FROM TB_WRK013
--                         WHERE WERKS = P_WERKS
--                           AND MACH_CD = P_MACH_CD
--                           AND IN_OUT = 'N'  
                        );
            END IF;

        EXCEPTION
        WHEN NO_DATA_FOUND THEN
            R_CODE := TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS');
        END;           

        IF LTRIM(R_CODE) IS NULL THEN
            R_CODE := TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS');
        END IF;

    EXCEPTION
    WHEN OTHERS THEN
        R_CODE := TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS');
    END;

    RETURN R_CODE;  

END;

/
