--------------------------------------------------------
--  DDL for Function FN_IF_QUERY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "KNRAMES"."FN_IF_QUERY" 
(
    P_IF_ID    IN VARCHAR2 , 
    P_DOCNO   IN VARCHAR2 
)
RETURN VARCHAR2
/*=============================================================================*
 * FUNCTION NAME: FN_SPLIT
 *   1)INPUT VALUE
 *      P_IF_ID: MES IF KEY
 *      P_DOCNO: 검색 조회조건
 *   2)OUTPUT VALUE
 *      FUNC_SPLIT_VALUES: 분할된 문자열 테이블
 * CREATE DATE  : 2022/04/29
 * DESCRIPTION  : 입력된 대상 문자열을 분할문자를 기준으로 Row로 저장하여 Table을 반환.                                                   
 * REVERSION HISTORY
 * ------------ ------- ------------- ----------------------------------------- 
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ----------------------------------------- 
 * 2022/06/29    1.0.0   김기연         Initial Version
==============================================================================*/
AS
    V_SQL VARCHAR2(4000);--조회 쿼리
    V_COL_LIST VARCHAR2(1000);--조회 테이블 컬럼
    V_TABLE_ID VARCHAR2(20);--조회 테이블
    V_FIND_COL VARCHAR2(20);--조회조건 항목
BEGIN
    --조회 테이블 검색
    SELECT IFTBL
      INTO V_TABLE_ID
      FROM TB_ITFMA
     WHERE 1=1
       AND IFID = P_IF_ID;
    --조회목록 검색
    SELECT LISTAGG(MESFLD || ' AS ' || TARFLD,',')
      INTO V_COL_LIST
      FROM (SELECT LISTAGG(A.MESFLD,'||') WITHIN GROUP(ORDER BY A.ORD) OVER(PARTITION BY A.TARFLD) AS MESFLD
                 , A.TARFLD
              FROM TB_ITFFLDMAP A JOIN TB_ITFMA B ON A.IFID = B.IFID
             WHERE 1=1 
               AND A.IFID = P_IF_ID
               AND A.USEYN = 'Y'
             ORDER BY A.ORD ASC
           ); 

    V_FIND_COL := CASE WHEN V_TABLE_ID LIKE '%WM%' THEN 'DOC_NO' ELSE 'MDOCNO' END;


    V_SQL := 'SELECT ' || V_COL_LIST;
    V_SQL := V_SQL || ' FROM ' || V_TABLE_ID;
    V_SQL := V_SQL || ' WHERE 1=1 ';
    --문서번호가 없는 경우 NULL 반환
    IF P_DOCNO IS NULL THEN
    	V_SQL := '';
    ELSE
        --V_SQL := V_SQL || ' AND MDOCNO = ''' || P_DOCNO || '''';
        V_SQL := V_SQL || ' AND ' || V_FIND_COL || ' IN (SELECT RTN_VALUES FROM FN_SPLIT(''' || P_DOCNO || ''','',''))';
    END IF;

    RETURN V_SQL;
END;

/
