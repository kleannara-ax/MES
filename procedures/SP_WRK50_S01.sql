
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_WRK50_S01" (
	P_TYPE           IN    VARCHAR2, -- LIST
	P_JSON_STR       IN    CLOB,
    P_DECISION_RTN   IN    VARCHAR2,
	P_SUCCESS       OUT    VARCHAR2,
    P_RS_MSG        OUT    VARCHAR2,
	P_RS_LIST_01    OUT    SYS_REFCURSOR, 
	P_RS_LIST_02    OUT    SYS_REFCURSOR 
)
/*==============================================================================
 * PROGRAM ID    : SP_WRK50_S01
 * PROGRAM NAME  : 재고대사 검증
 * VERSION       : 1.0.0
 * DESCRIPTION   : 재고대사 검증
 *                 
 * AUTHOR NAME   : 김성하
 * CREATE DATE   : 2022/11/01
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}	<생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}		<생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}			<생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}	<생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/11/01    1.0.0   김성하         Initial Version 
 *==============================================================================
 *  관련 테이블
 *=============================================================================*/
AS

  V_PRG_NM          	VARCHAR2(100) 	:= 'SP_WRK50_S01';     -- PROCEDURE NAME

  -- 오라클 에러 처리용 변수선언 영역
  E_EXCEPTION_USER  	EXCEPTION;
  E_SQL_ERR_CD      	NUMBER(5) 		:= 0;
  E_SQL_ERR_MSG		    VARCHAR2(4000);

  -- JSON을 위한 변수선언 영역
  V_JSON		      JSON_OBJECT_T;
  V_ARR_LIST       	  JSON_ARRAY_T;
  V_OBJ            	  JSON_OBJECT_T;

	-- 세션값 처리용 변수선언 영역
  V_SESS_USER_ID   	  varchar2(20);
  V_PLT_CD         	  varchar2(2);
  V_DEBUG          	  varchar2(1);
  V_RANGE_SQL         varchar2(4000);

	-- 조건절 처리용 변수선언 영역	
  V_SQL				CLOB;

  V_WERKS        	TB_INV001.WERKS%TYPE;					                            --플랜트코드	
  V_STOR_LOC_CD   	TB_INV001.STOR_LOC_CD%TYPE;				                            --저장위치	
  V_MATNR        	TB_INV001.MATNR%TYPE;					                            --제품코드	
  V_LOT_NO        	TB_INV001.LOT_NO%TYPE;					                            --LOTNO	

  V_DOC_NO          TB_IFR050.MDOCNO%TYPE;     

  V_FROM_PRD_DT		VARCHAR(8);
  V_TO_PRD_DT		VARCHAR(8);
  V_WKDT		    VARCHAR(6);
  V_SAP_DIFF_QTY    NUMBER(9,3);
  V_TOT_CNT         NUMBER(9);
  V_SND_CNT         NUMBER(9);
  V_IND_BCD         VARCHAR(15);
  V_RANGE_DT_SQL    VARCHAR2(50);
  V_RANGE_DT        VARCHAR2(200);
  V_RANGE_DT_1      VARCHAR2(200);
BEGIN
	OPEN P_RS_LIST_01 FOR 
	SELECT NULL FROM DUAL WHERE ROWNUM = 0;

	OPEN P_RS_LIST_02 FOR 
	SELECT NULL FROM DUAL WHERE ROWNUM = 0;

	V_JSON 		    := JSON_OBJECT_T.parse(P_JSON_STR);

	V_SESS_USER_ID	:= V_JSON.get_string('SES_USER_ID');
	V_PLT_CD		:= V_JSON.get_string('SES_PLNTKY');

    V_RANGE_SQL     := V_JSON.get_string('RANGE_SQL');

	V_WERKS			:= V_JSON.get_string('WERKS');			     -- 플랜트코드(필수)	
    V_LOT_NO  	    := V_JSON.get_string('LOT_NO');	             -- LOT_NO (선택)
	V_FROM_PRD_DT	:= V_JSON.get_string('FROM_PRD_DT');	     -- 실적일자 (필수)	
    V_TO_PRD_DT		:= V_JSON.get_string('TO_PRD_DT');	         -- 실적일자 (필수)
    V_STOR_LOC_CD	:= V_JSON.get_string('STOR_LOC_CD');	     -- 저장위치 (선택)
    V_WKDT      	:= V_JSON.get_string('WKDT');	             -- 마감월   (선택)
    V_MATNR         := V_JSON.get_string('MATNR');	             -- 자재코드   (선택)

	IF P_TYPE = 'LIST' THEN
        UPDATE TB_IFR050
           SET MATNR = SUBSTR(MATNR, 12, LENGTH(MATNR) - 11)  
          WHERE WERKS = V_WERKS
            AND SUBSTR(MATNR, 1, 11) = '00000000000';

--        V_RANGE_DT_SQL := SUBSTR(V_RANGE_SQL, 6, 64);
--
--        V_RANGE_DT := 'AND ' || REPLACE(V_RANGE_DT_SQL, '  AND', '');
--        V_RANGE_DT_1 := REPLACE(V_RANGE_DT, 'PRFM_DT', 'INP_DT');
--
--        IF INSTR(V_RANGE_SQL, 'STOR_LOC_CD') + INSTR(V_RANGE_SQL, 'LOT_NO') + INSTR(V_RANGE_SQL, 'MATNR') > 0 THEN
--           V_RANGE_SQL := REPLACE(V_RANGE_SQL, V_RANGE_DT_SQL, '') ;
--        ELSE
--           V_RANGE_SQL := NULL;
--        END IF;

	    IF V_WERKS = 'P100' THEN
             V_SQL := 'WITH INV001 AS (
                            SELECT WERKS
                                 , STOR_LOC_CD
                                 , LOT_NO
                                 , MATNR
                                 , UNIT
                                 , SUM(STCK_QTY) AS STCK_QTY
                            FROM TB_INV001
                            WHERE 1=1
                                AND WERKS = ''' || V_WERKS || '''
                                AND SUBSTR(IND_BCD, 6, 1) != ''T''
                                AND NVL(DLFL, ''N'') IN (''N'', ''A'') ';

                IF V_STOR_LOC_CD IS NOT NULL OR TRIM(V_STOR_LOC_CD) != '' THEN
                    V_SQL := V_SQL || ' AND STOR_LOC_CD = ''' || V_STOR_LOC_CD || '''';
                END IF;

                IF V_LOT_NO IS NOT NULL OR TRIM(V_LOT_NO) != '' THEN
                    V_SQL := V_SQL || ' AND LOT_NO = ''' || V_LOT_NO || '''';
                END IF;

                IF V_MATNR IS NOT NULL OR TRIM(V_MATNR) != '' THEN
                    V_SQL := V_SQL || ' AND MATNR = ''' || V_MATNR || '''';
                END IF;

             V_SQL := V_SQL || ' GROUP BY WERKS, STOR_LOC_CD, LOT_NO, MATNR, UNIT
                        )
                        , INV003 AS (
                            SELECT WERKS
                                   , LOT_NO
                                   , UNIT
                                   , SUM(STCK_QTY)   AS STCK_QTY
                                   , SUM(WGT)        AS WGT
                                   , SUM(PRE_IN_QTY) AS PRE_IN_QTY
                            FROM TB_INV003
                            WHERE 1=1
                                AND WERKS = ''' || V_WERKS || '''
                                AND STCK_QTY > 0
                                AND IND_BCD IN (
                                    SELECT DISTINCT IND_BCD
                                    FROM TB_INV001
                                    WHERE 1=1
                                        AND WERKS = ''' || V_WERKS || '''
                                        AND SUBSTR(IND_BCD, 6, 1) != ''T''
                                        AND NVL(DLFL, ''N'') IN (''N'', ''A'') ';
                                     IF V_STOR_LOC_CD IS NOT NULL OR TRIM(V_STOR_LOC_CD) != '' THEN
                                        V_SQL := V_SQL || ' AND STOR_LOC_CD = ''' || V_STOR_LOC_CD || '''';
                                     END IF;
                        V_SQL := V_SQL || ')';

                IF V_LOT_NO IS NOT NULL OR TRIM(V_LOT_NO) != '' THEN
                    V_SQL := V_SQL || ' AND LOT_NO = ''' || V_LOT_NO || '''';
                END IF;

                IF V_MATNR IS NOT NULL OR TRIM(V_MATNR) != '' THEN
                    V_SQL := V_SQL || ' AND MATNR = ''' || V_MATNR || '''';
                END IF;

             V_SQL := V_SQL || ' GROUP BY WERKS, LOT_NO, MATNR, UNIT
                        )
                        , TB_STOCK AS (
                            SELECT I001.WERKS
                                  , I001.STOR_LOC_CD
                                  , REPLACE(I001.LOT_NO, '' '', '''') AS LOT_NO
                                  , I001.MATNR
                                  , I001.UNIT
                                  , (NVL(I001.STCK_QTY, 0) +
                                   SUM(NVL(CASE
                                               WHEN I001.UNIT = I003.UNIT THEN NVL(I003.STCK_QTY, 0)
                                               ELSE CASE
                                                        WHEN I003.UNIT = ''EA'' THEN I003.STCK_QTY /
                                                                                   ((SUBSTR(I001.MATNR, 10, 4) / 1000) *
                                                                                    (SUBSTR(I001.MATNR, 14, 4) / 1000) *
                                                                                    (SUBSTR(I001.MATNR, 6, 3) / 1000))
                                                        WHEN I003.UNIT = ''R'' THEN NVL(I003.STCK_QTY, 0) * 500
                                                        WHEN I003.UNIT = ''KG'' AND SUBSTR(I003.LOT_NO, 5, 1) = ''P''
                                                                             THEN ROUND(I003.STCK_QTY / (I003.WGT / I003.PRE_IN_QTY), 3)
                                                        ELSE 0 END
                                               END, 0))
                                      ) AS STCK_QTY
                                FROM INV001 I001
                                    LEFT OUTER JOIN INV003 I003 ON I001.WERKS = I003.WERKS AND I001.LOT_NO = I003.LOT_NO
                                WHERE 1=1
                                GROUP BY I001.WERKS, I001.STOR_LOC_CD, I001.LOT_NO, I001.MATNR, I001.UNIT, I001.STCK_QTY
                        )
                        , IFR050 AS (
                            SELECT WERKS
                                 , LGORT
                                 , CHARG
                                 , MATNR
                                 , MEINS
                                 , LGORT
                                 , STQTY
                            FROM TB_IFR050
                            WHERE 1=1
                                AND WERKS = ''' || V_WERKS || '''
                                AND WKDT = ''202303''
                                AND LGORT = ''' || V_STOR_LOC_CD || '''
                        )
                        , WMS AS (
                            SELECT LOTA02
                                 , LOTA15
                                 , SUM(USEQTY) AS WMS_STCK_QTY
                            FROM V_WMS_STKKY@KNRAWMSLINK
                            WHERE LOTA02 = ''' || V_WERKS || '''
                            GROUP BY LOTA02, LOTA15
                        )
                        , FINAL_DATA AS (
                        SELECT
                            CASE WHEN STOCK.WERKS IS NULL THEN IFR050.WERKS ELSE STOCK.WERKS END                    AS WERKS
                                , CASE WHEN STOCK.STOR_LOC_CD IS NULL THEN IFR050.LGORT ELSE STOCK.STOR_LOC_CD END  AS STOR_LOC_CD
                                , CASE WHEN STOCK.LOT_NO IS NULL THEN IFR050.CHARG ELSE STOCK.LOT_NO END            AS LOT_NO
                                , CASE WHEN STOCK.MATNR IS NULL THEN IFR050.MATNR ELSE STOCK.MATNR END              AS MATNR
                                , M001.MATNR_NM
                                , CASE WHEN STOCK.UNIT IS NULL THEN IFR050.MEINS ELSE STOCK.UNIT END                AS UNIT
                                , NVL(STOCK.STCK_QTY, 0)                                                            AS STCK_QTY
                                , IFR050.LGORT                                                                      AS LGORT
                                , NVL(IFR050.STQTY, 0)                                                              AS SAP_STCK_QTY
                                , CASE WHEN (NVL(STOCK.STCK_QTY, 0) - NVL(IFR050.STQTY, 0)) = 0.001
                                         OR  (NVL(STOCK.STCK_QTY, 0) - NVL(IFR050.STQTY, 0)) = 0.002
                                     THEN 0
                                     ELSE (NVL(STOCK.STCK_QTY, 0) - NVL(IFR050.STQTY, 0)) END                       AS SAP_DIFF_QTY
                                , NVL(WMS.WMS_STCK_QTY, 0)                                                          AS WMS_STCK_QTY
                        FROM TB_STOCK STOCK
                            FULL OUTER JOIN TB_IFR050 IFR050    ON STOCK.WERKS = IFR050.WERKS AND NVL(STOCK.LOT_NO, '' - '') = NVL(IFR050.CHARG, '' - '')
                            LEFT JOIN WMS                       ON STOCK.WERKS = WMS.LOTA02 AND STOCK.LOT_NO = WMS.LOTA15
                            LEFT JOIN TB_MAS001 M001            ON STOCK.WERKS = M001.WERKS AND STOCK.MATNR = M001.MATNR
                 )
                    SELECT * FROM FINAL_DATA
                    WHERE 1=1
                        AND NVL(STCK_QTY, 0) + NVL(SAP_STCK_QTY, 0) > 0';

            IF V_STOR_LOC_CD IS NOT NULL OR TRIM(V_STOR_LOC_CD) != '' THEN
                V_SQL := V_SQL || ' AND STOR_LOC_CD = ''' || V_STOR_LOC_CD || '''';
            END IF;

            IF V_LOT_NO IS NOT NULL OR TRIM(V_LOT_NO) != '' THEN
                V_SQL := V_SQL || ' AND LOT_NO = ''' || V_LOT_NO || '''';
            END IF;

            IF V_MATNR IS NOT NULL OR TRIM(V_MATNR) != '' THEN
                V_SQL := V_SQL || ' AND MATNR = ''' || V_MATNR || '''';
            END IF;

            V_SQL := V_SQL || ' ORDER BY STOR_LOC_CD, LOT_NO' ;


        ELSIF V_WERKS = 'P100_OLD' THEN
             V_SQL := 'SELECT F.WERKS
                        , F.STOR_LOC_CD
                        , F.LOT_NO
                        , F.MATNR
                        , M001.MATNR_NM
                        , F.UNIT
                        , F.STCK_QTY
                        , F.LGORT
                        , F.SAP_STCK_QTY
                        , F.SAP_DIFF_QTY
                        , F.WMS_STCK_QTY
                      FROM( SELECT CASE WHEN A.WERKS IS NULL THEN IF050.WERKS ELSE A.WERKS END WERKS,
                               DECODE(A.STOR_LOC_CD, NULL, IF050.LGORT, A.STOR_LOC_CD) STOR_LOC_CD,
                               CASE WHEN A.LOT_NO IS NULL THEN IF050.CHARG ELSE A.LOT_NO END LOT_NO,
                               CASE WHEN A.MATNR IS NULL THEN IF050.MATNR ELSE A.MATNR END MATNR,
                               CASE WHEN A.UNIT IS NULL THEN IF050.MEINS ELSE A.UNIT END UNIT,
                               NVL(A.STCK_QTY, 0) AS STCK_QTY,
                               IF050.LGORT,
                               NVL(IF050.STQTY, 0) AS SAP_STCK_QTY,
                               NVL(A.STCK_QTY, 0) - NVL(IF050.STQTY, 0) AS SAP_DIFF_QTY,
                               NVL(WMS.WMS_STCK_QTY, 0) AS WMS_STCK_QTY
                          FROM(
                                SELECT I001.WERKS, I001.STOR_LOC_CD, I001.LOT_NO, I001.MATNR, I001.UNIT,
                                        (SUM(NVL(I001.STCK_QTY, 0)) +
                                            SUM(NVL(CASE WHEN I001.UNIT = I003.UNIT THEN NVL(I003.STCK_QTY, 0)
                                                 ELSE CASE WHEN I003.UNIT = ''EA'' THEN I003.STCK_QTY / ((SUBSTR(I001.MATNR, 10, 4) / 1000) * (SUBSTR(I001.MATNR, 14, 4) / 1000) * (SUBSTR(I001.MATNR, 6, 3) / 1000))
                                                           WHEN I003.UNIT = ''R'' THEN NVL(I003.STCK_QTY, 0) * 500
                                                           WHEN I003.UNIT = ''KG'' AND SUBSTR(I003.LOT_NO, 5,1) = ''P'' THEN TRUNC(I003.STCK_QTY / (I003.WGT / I003.PRE_IN_QTY), 3)
                                                           ELSE 0 END
                                                 END, 0))
                                            ) AS STCK_QTY
                                  FROM TB_INV001 I001
                                    LEFT JOIN (SELECT WERKS, LOT_NO, UNIT, SUM(STCK_QTY) AS STCK_QTY, SUM(WGT) AS WGT, SUM(PRE_IN_QTY) AS PRE_IN_QTY
                                                     FROM TB_INV003
                                                    WHERE TB_INV003.WERKS = ''' || V_WERKS || '''
                                                    GROUP BY WERKS, LOT_NO, UNIT
                                                ) I003 ON I001.WERKS = I003.WERKS AND I001.LOT_NO = I003.LOT_NO
                                 WHERE I001.WERKS = ''' || V_WERKS || '''
--                                   AND I001.STOR_LOC_CD IN (SELECT DISTINCT(LGPRO)
--                                                              FROM TB_MAS001
--                                                             WHERE WERKS = ''' || V_WERKS || '''
--                                                               AND LGPRO IS NOT NULL)
                                   AND NVL(I001.DLFL, ''N'') = ''N''
--                                 GROUP BY I001.WERKS, I001.STOR_LOC_CD, I001.LOT_NO, I001.MATNR, I001.UNIT, I003.UNIT ) A
                                 GROUP BY I001.WERKS, I001.STOR_LOC_CD, I001.LOT_NO, I001.MATNR, I001.UNIT ) A
                           FULL OUTER JOIN (SELECT *
                                              FROM TB_IFR050
                                             WHERE WERKS = ''' || V_WERKS || '''
                                               AND WKDT = ''202303''
--                                               AND LGORT IN (SELECT DISTINCT(LGPRO)
--                                                               FROM TB_MAS001
--                                                              WHERE WERKS = ''' || V_WERKS || '''
--                                                              AND LGPRO IS NOT NULL)
                                                              ) IF050
                          ON A.WERKS = IF050.WERKS
                          AND NVL(REPLACE(A.LOT_NO, '' '', ''''), ''-'') = NVL(IF050.CHARG, ''-'')
                          LEFT JOIN (SELECT LOTA02, LOTA15, SUM(USEQTY) AS WMS_STCK_QTY
                                       FROM V_WMS_STKKY@KNRAWMSLINK
                                      WHERE LOTA02 = ''' || V_WERKS || '''
                                     GROUP BY LOTA02, LOTA15) WMS
                          ON A.WERKS = WMS.LOTA02
                          AND A.LOT_NO = WMS.LOTA15
                          ) F
                      LEFT JOIN TB_MAS001 M001
                      ON F.WERKS = M001.WERKS
                      AND F.MATNR = M001.MATNR
                     WHERE NVL(F.STCK_QTY, 0) +  NVL(F.SAP_STCK_QTY, 0) > 0 ';

            IF V_STOR_LOC_CD IS NOT NULL OR TRIM(V_STOR_LOC_CD) != '' THEN
                V_SQL := V_SQL || ' AND F.STOR_LOC_CD = ''' || V_STOR_LOC_CD || '''';
            END IF;

            IF V_LOT_NO IS NOT NULL OR TRIM(V_LOT_NO) != '' THEN
                V_SQL := V_SQL || ' AND F.LOT_NO = ''' || V_LOT_NO || '''';
            END IF;

            IF V_MATNR IS NOT NULL OR TRIM(V_MATNR) != '' THEN
                V_SQL := V_SQL || ' AND F.MATNR = ''' || V_MATNR || '''';
            END IF;

--            IF V_RANGE_SQL IS NOT NULL OR TRIM(V_RANGE_SQL) != '' THEN
--                V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'STOR_LOC_CD', 'F.STOR_LOC_CD');
--                V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'MATNR', 'F.MATNR');
--                V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'LOT_NO', 'F.LOT_NO');
--
--                V_SQL := V_SQL || V_RANGE_SQL;
--            END IF;

            V_SQL := V_SQL || ' ORDER BY F.STOR_LOC_CD, F.LOT_NO'  ;
        ELSE
            V_RANGE_DT := V_RANGE_SQL;
            V_RANGE_DT_1 := REPLACE(V_RANGE_SQL, 'PRFM_DT', 'INP_DT');

            V_SQL := 'SELECT F.WERKS
                            , F.STOR_LOC_CD
                            , F.LOT_NO
                            , F.MATNR
                            , M001.MATNR_NM
                            , F.UNIT
                            , F.STCK_QTY
                            , F.USE_QTY
                            , F.LGORT
                            , F.SAP_STCK_QTY
                            , F.SAP_DIFF_QTY
                            , NVL(F.USE_QTY, 0) + NVL(F.SAP_DIFF_QTY, 0) AS DIFF_QTY
--                            , F.WMS_STCK_QTY
                          FROM(SELECT DECODE(A.WERKS, NULL, DECODE(IF050.WERKS, NULL, I010.WERKS, IF050.WERKS), A.WERKS) WERKS,
                                       DECODE(A.STOR_LOC_CD, NULL, IF050.LGORT, A.STOR_LOC_CD) STOR_LOC_CD,
                                       DECODE(A.LOT_NO, NULL, DECODE(IF050.CHARG, NULL, I010.LOT_NO, IF050.CHARG), A.LOT_NO) LOT_NO,
                                       DECODE(A.MATNR, NULL, DECODE(IF050.MATNR, NULL, I010.MATNR, IF050.MATNR), A.MATNR) MATNR,
                                       DECODE(A.UNIT, NULL, DECODE(IF050.MEINS, NULL, I010.UNIT, IF050.MEINS), A.UNIT) UNIT,
                                       NVL(A.STCK_QTY, 0) AS STCK_QTY,
                                       NVL(I010.USE_QTY, 0) AS USE_QTY,
                                       IF050.LGORT,
                                       NVL(IF050.STQTY, 0) AS SAP_STCK_QTY,
                                       NVL(A.STCK_QTY, 0) - NVL(IF050.STQTY, 0) AS SAP_DIFF_QTY
                                  FROM(
                                        SELECT I001.WERKS, I001.STOR_LOC_CD, I001.LOT_NO, I001.MATNR, I001.UNIT, SUM(NVL(I001.STCK_QTY, 0) + NVL(I003.STCK_QTY, 0)) AS STCK_QTY
                                          FROM TB_INV001 I001
                                          LEFT JOIN TB_INV003 I003
                                          ON I001.WERKS = I003.WERKS
                                          AND I001.MATNR = I003.MATNR
                                          AND I001.IND_BCD = I003.IND_BCD
                                         WHERE I001.WERKS = ''' || V_WERKS || '''
                                            AND I001.STOR_LOC_CD IN (SELECT DISTINCT(LGPRO)
                                                                       FROM TB_MAS001
                                                                      WHERE WERKS = ''' || V_WERKS || '''
                                                                        AND LGPRO IS NOT NULL
                                                                        AND LGPRO <> ''3000'')
                                            AND NVL(I001.DLFL, ''N'') IN (''N'', ''A'')
                                         GROUP BY I001.WERKS, I001.STOR_LOC_CD, I001.LOT_NO, I001.MATNR, I001.UNIT) A
                                   FULL OUTER JOIN (SELECT *
                                                      FROM TB_IFR050
                                                     WHERE WERKS = ''' || V_WERKS || '''
                                                       AND WKDT = ''202303''
                                                       AND LGORT IN (SELECT DISTINCT(LGPRO)
                                                                       FROM TB_MAS001
                                                                      WHERE WERKS = ''' || V_WERKS || '''
                                                                        AND LGPRO IS NOT NULL
                                                                        AND LGPRO <> ''3000'')) IF050
                                  ON A.WERKS = IF050.WERKS
                                  AND A.STOR_LOC_CD = IF050.LGORT
                                  AND NVL(REPLACE(A.LOT_NO, '' '', ''''), ''-'') = NVL(IF050.CHARG, ''-'')
                                  AND A.MATNR = IF050.MATNR
                                  FULL OUTER JOIN(SELECT WERKS, LOT_NO_M AS LOT_NO, MATNR_M AS MATNR, UNIT, SUM(USE_QTY) AS USE_QTY
                                              FROM TB_INV010
                                             WHERE WERKS = ''' || V_WERKS || '''';

            V_SQL := V_SQL ||  V_RANGE_DT;


            V_SQL := V_SQL || ' AND NVL(CNL_YN, ''N'') = ''N'' AND USE_DIV <> ''3''
                                            GROUP BY WERKS, LOT_NO_M, MATNR_M, UNIT
                                            UNION ALL
                                            SELECT WERKS, REPLACE(LOT_NO, ''*'', '''') AS LOT_NO, MATNR, UNIT, SUM(INP_QTY) AS USE_QTY
                                              FROM TB_INV005
                                             WHERE WERKS = ''' || V_WERKS || '''';

            V_SQL := V_SQL || V_RANGE_DT_1 ;
            V_SQL := V_SQL || ' GROUP BY WERKS, LOT_NO, MATNR, UNIT) I010
                                  ON A.WERKS = I010.WERKS
                                  AND A.MATNR = I010.MATNR
                                  AND NVL(REPLACE(A.LOT_NO, '' '', ''''), ''-'') = NVL(REPLACE(I010.LOT_NO, '' '', ''''), ''-'')
--                                  AND A.LOT_NO = I010.LOT_NO
--                                  AND A.MATNR = I010.MATNR
--                                  LEFT JOIN (SELECT LOTA02, LOTA15, SUM(USEQTY) AS WMS_STCK_QTY
--                                               FROM V_WMS_STKKY@KNRAWMSLINK
--                                              WHERE LOTA02 = ''' || V_WERKS || '''
--                                             GROUP BY LOTA02, LOTA15) WMS
--                                  ON A.WERKS = WMS.LOTA02
--                                  AND A.LOT_NO = WMS.LOTA15
                                  LEFT JOIN TB_MAS001 M001_1
                                  ON I010.WERKS = M001_1.WERKS
                                  AND I010.MATNR = M001_1.MATNR
                              )F
                          LEFT JOIN TB_MAS001 M001
                          ON F.WERKS = M001.WERKS
                          AND F.MATNR = M001.MATNR
                         WHERE NVL(F.STCK_QTY, 0) +  NVL(F.SAP_STCK_QTY, 0) <> 0 ';

            IF V_STOR_LOC_CD IS NOT NULL OR TRIM(V_STOR_LOC_CD) != '' THEN
                V_SQL := V_SQL || ' AND F.STOR_LOC_CD = ''' || V_STOR_LOC_CD || '''';
            END IF;

            IF V_LOT_NO IS NOT NULL OR TRIM(V_LOT_NO) != '' THEN
                V_SQL := V_SQL || ' AND F.LOT_NO = ''' || V_LOT_NO || '''';
            END IF;

            IF V_MATNR IS NOT NULL OR TRIM(V_MATNR) != '' THEN
                V_SQL := V_SQL || ' AND F.MATNR = ''' || V_MATNR || '''';
            END IF;

--            IF V_RANGE_SQL IS NOT NULL OR TRIM(V_RANGE_SQL) != '' THEN
--                V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'STOR_LOC_CD', 'F.STOR_LOC_CD');	
--                V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'MATNR', 'F.MATNR');	
--                V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'LOT_NO', 'F.LOT_NO');	
--			
--                V_SQL := V_SQL || V_RANGE_SQL;
--            END IF;      

            V_SQL := V_SQL || ' ORDER BY F.STOR_LOC_CD, F.LOT_NO'  ;

        END IF;

        V_DEBUG := 'Y';
        IF (V_DEBUG = 'Y') THEN
            INSERT INTO PROC_LOG(SQL_STR, SQL_PARAM1) VALUES (V_SQL, 'WRK_50');
        END IF;

          OPEN P_RS_LIST_01 FOR V_SQL;

	END IF;

	P_SUCCESS := 'Y';
	COMMIT;

	EXCEPTION
    WHEN E_EXCEPTION_USER THEN

    -- 에러 내역 SET
        P_SUCCESS           := 'N';
        E_SQL_ERR_CD        := -20000;
		E_SQL_ERR_MSG       := SUBSTRB(SQLERRM,1,300);

		ROLLBACK;
		SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);

	WHEN OTHERS THEN
		P_SUCCESS			:= 'N';
        E_SQL_ERR_CD        := E_SQL_ERR_CD;
		E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

		ROLLBACK;
		RAISE;
END;
/
