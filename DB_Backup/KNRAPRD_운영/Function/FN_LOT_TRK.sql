--------------------------------------------------------
--  DDL for Function FN_LOT_TRK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "KNRAMES"."FN_LOT_TRK" 
(
    P_IND_BCD    IN VARCHAR2,
    P_LEVEL   	 IN NUMBER
)
    RETURN VARCHAR2 IS
/*=============================================================================*
 * FUNCTION NAME: FN_GET_CM_VAL
 *   1)INPUT VALUE
 *      P_CM_KEY: 코드 그룹
 *      P_CD_KEY: 공통코드
 *   2)OUTPUT VALUE
 *      R_CD_NM: 생산일자
 * CREATE DATE  : 2022/04/25
 * DESCRIPTION  :
 * REVERSION HISTORY
 * ------------ ------- ------------- -----------------------------------------
 *    Date        Ver       Name          Description
 * ------------ ------- ------------- -----------------------------------------
 * 2022/04/25    1.0.0   방청길        Initial Version
 * yyyy/mm/dd    1.0.1   홍판서         변경사유 기술
==============================================================================*/
    R_LOT_NO        VARCHAR(100);    -- 코드명

BEGIN

    R_LOT_NO := ' ';
	BEGIN
		SELECT T2.LOT_NO_M INTO R_LOT_NO
		  FROM(
				SELECT LEVEL AS SEQ,
						T1.WERKS,
						T1.IND_BCD,
						T1.IND_BCD_M,
						T1.LOT_NO_M,
						T1.MATNR_M
						--CAST(T1.IND_BCD ||T1.IND_BCD_M) SORTCOL
					   --LPAD(' ', (LEVEL-1)*2, ' ') || T1.IND_BCD AS AA 
				 FROM TB_WRK008 T1
				-- WHERE 1=1
				START WITH T1.IND_BCD = P_IND_BCD
				CONNECT BY  T1.IND_BCD =  PRIOR T1.IND_BCD_M) T2,
				TB_MAS001 M001
		  WHERE T2.WERKS = M001.WERKS(+)
			AND T2.MATNR_M = M001.MATNR(+)
			AND M001.MATNR_DIV = 'HALB'
			AND T2.SEQ = P_LEVEL
			AND ROWNUM = 1;
	EXCEPTION
        WHEN NO_DATA_FOUND THEN
            R_LOT_NO := ' ';
        WHEN OTHERS THEN
			R_LOT_NO := ' ';	
		END;           

        IF LTRIM(R_LOT_NO) IS NULL THEN
            R_LOT_NO := ' ';
        END IF;
    RETURN R_LOT_NO;

END;


/
