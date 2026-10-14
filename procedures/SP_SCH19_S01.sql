
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_SCH19_S01" (
	P_TYPE         IN    varchar2, -- LIST, SUB_LIST-A, SUB_LIST-B
	P_JSON_STR     IN    CLOB,
	P_SUCCESS      OUT    varchar2,
	P_RS_LIST      OUT    SYS_REFCURSOR 
)
/*==============================================================================
 * PROGRAM ID    : SP_SCH19_S01{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 공정투입대비 실적 {호출 프로그램 명 기술}
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 공정투입대비 실적현황 {프로그램에 대한 상세한 내용 기술}
 *                 
 * AUTHOR NAME   : 박성철{최초 작성자 명 기술}
 * CREATE DATE   : 2022/07/18 {최초 작성일자 기술}
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * yyyy/mm/dd    1.0.0   박성철         Initial Version 
 *==============================================================================
 *  관련 테이블
 *=============================================================================*/

AS

    V_PRG_NM          VARCHAR2(100)  := 'SP_SCH19_S01';     -- PROCEDURE NAME


    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5)           := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);

    -- JSON을 위한 변수선언 영역
    V_JSON           JSON_OBJECT_T;
    V_ARR_LIST       JSON_ARRAY_T;
    V_ARR_HEAD       JSON_ARRAY_T;
    V_OBJ            JSON_OBJECT_T;

    -- 세션값 처리용 변수선언 영역
    V_SQL            CLOB;
    V_RUN_SQL        varchar2(1);
    V_RANGE_SQL      varchar2(4000);
    V_DEBUG          varchar2(1);

    -- 세션값 처리용 변수선언 영역
    V_PLT_CD         varchar2(2);
    V_SESS_USER_ID   varchar2(20);

   -- 조건절 처리용 변수선언 영역
   V_WERKS        	TB_MAS001.WERKS%TYPE;       --플랜트 
   V_MACH_CD    	TB_MAS012.MACH_CD%TYPE; 	--설비코드 
   V_PROC_CD        TB_MAS013.PROC_CD%TYPE;     --공정코드
   V_ORDER_NO		TB_WRK002.ORDER_NO%TYPE;	--오더번호
   V_LOT_NO			TB_INV003.LOT_NO%TYPE;		--LOT번호 


    -- 리스트(그리드)의 값을 할당하기 위한 변수선언 영역

BEGIN
    OPEN P_RS_LIST FOR 

    SELECT NULL FROM DUAL WHERE ROWNUM = 0;

    V_DEBUG := 'N';
    V_RUN_SQL := 'Y';

    V_JSON := JSON_OBJECT_T.parse(P_JSON_STR);

    V_SESS_USER_ID       :=      V_JSON.get_string('SES_USER_ID');
    V_PLT_CD             :=      V_JSON.get_string('SES_PLNTKY');

   /* 조건값 할당 */
   V_RANGE_SQL 		    :=       V_JSON.get_string('RANGE_SQL');   	--작업지시번호, 작업지시번호 순번

   V_WERKS   		:=       V_JSON.get_string('WERKS');	     --플랜트   
   V_MACH_CD    	:=       V_JSON.get_string('MACH_CD');   	 --설비코드 
   V_PROC_CD  		:=       V_JSON.get_string('PROC_CD');		 --공정코드
   V_ORDER_NO		:=		V_JSON.get_string('ORDER_NO');		--오더번호
   V_LOT_NO			:=		V_JSON.get_string('LOT_NO');		--LOT번호    


    IF P_TYPE = 'LIST' THEN /*상단 조회 리스트*/
        V_SQL :='SELECT W002.WERKS
					, M012.PROC_CD		--공정코드
                    , M013.PROC_NM     --공정명
                    , W002.MACH_CD      --설비코드
                    , M012.MACH_NM      --설비명
                    , W002.MATNR       --자재코드
                    , M001.MATNR_NM     --자재명
                    , W002.ORDER_NO     --오더번호
                    , W002.PRFM_DT      --생산일자
                    , W002.WRK_ORDR_NO  --작업지시번호
                    , W002.WRK_ORDR_SEQNO  --작업지시순번
                    , DECODE(TO_NUMBER(SUBSTR(W002.MATNR, 14, 4)), 0, TO_CHAR(TO_NUMBER(SUBSTR(W002.MATNR, 10, 4))) || ''*0000'', TO_CHAR(TO_NUMBER(SUBSTR(W002.MATNR, 10, 4))) || ''*'' || TO_CHAR(TO_NUMBER(SUBSTR(W002.MATNR, 14, 4)))) AS SPEC      --규격
                    , W002.LOT_NO       AS PRD_LOT_NO       --LOT_NO(LOT번호) --> PRD_LOT_NO(실적LOT번호) 변경
                    , DECODE(M013.PROC_CD, ''CA'', W002.PRD_QTY * 500, W002.PRD_QTY) AS PRD_QTY       --실적량
                    , DECODE(M013.PROC_CD, ''CA'', ''EA'', W002.PRD_UNIT) AS PRD_UNIT     --실적단위
                    , W002.PCNT         AS PCNT     --연수
                    , ''R''               AS RUNT     --연수단위
                    , W002.SCNT         AS SCNT     --속수
                    , DECODE(M013.PROC_CD, ''CA'', W002.PRD_QTY * 500, ''CB'', W002.PRD_QTY * 500, ''PC'', W002.PRD_QTY * 500, ''PB'', W002.PRD_QTY * 500, W002.MCNT)         AS MCNT     --매수
                    , W002.PRD_WGT                  --실적중량
                    , ''KG''      AS PRD_WUNIT        -- 실적중량단위 (추가)
                    , W002.PRD_ROLLCNT              --실적권치수
                    , ''M''      AS PRD_ROLLUNIT      -- 실적권치수단위 (추가)
                    , W000.LOT_NO_M                 --투입LOT번호 
                    , I003.IN_QTY                   -- 투입량
                    , I003.IN_UNIT                  --투입량단위
                    , DECODE(SUBSTR(W000.LOT_NO_M, 5, 1), ''M'',  W000.USE_WGT + W000.DISPO_WGT, W000.USE_QTY + W000.DISPO_QTY) AS USE_QTY  -- 사용량
                    , DECODE(SUBSTR(W000.LOT_NO_M, 5, 1), ''M'', ''KG'', W000.USE_UNIT) AS USE_UNIT  --사용량단위
                    , I003.STCK_QTY AS REM_QTY  -- 잔량
                    --, I003.IN_QTY - (DECODE(SUBSTR(W000.LOT_NO_M, 5, 1), ''M'',  W000.USE_WGT + W000.DISPO_WGT, W000.USE_QTY + W000.DISPO_QTY)) AS REM_QTY  -- 잔량
                    , I003.IN_UNIT  AS REM_UNIT   --잔량단위
                    , ROUND(DECODE(SUBSTR(W000.LOT_NO_M, 5, 1), ''M'',  W000.USE_WGT, W000.USE_QTY) / I003.IN_QTY, 1) * 100 AS PERCENT        --달성율
                  FROM (SELECT WERKS, MACH_CD, PRFM_DT, MATNR, WRK_ORDR_NO, WRK_ORDR_SEQNO, ORDER_NO, LOT_NO
                            , UNIT, DECODE(UNIT, ''EA'', SUM(PRFM_QTY)/ 500, SUM(PRFM_QTY)) AS PRD_QTY, DECODE(UNIT, ''EA'', ''R'', UNIT) AS PRD_UNIT
                            , SUM(WGT) AS PRD_WGT, SUM(ROLLCNT) AS PRD_ROLLCNT, SUM(PCNT) AS PCNT, SUM(SCNT) AS SCNT, SUM(MCNT) AS MCNT 
                          FROM TB_WRK002
                         WHERE WERKS = ''P100''
                           AND NVL(CNL_YN, ''N'') = ''N''
                           AND NVL(PRFM_GTHR_YN, ''Y'') = ''Y''
                        GROUP BY WERKS, MACH_CD, PRFM_DT, WRK_ORDR_NO, WRK_ORDR_SEQNO, ORDER_NO, MATNR, LOT_NO, UNIT   
                        ) W002
                  LEFT JOIN (
                            SELECT A.WERKS, A.WRK_ORDR_NO, A.WRK_ORDR_SEQNO, A.LOT_NO, A.LOT_NO_M, A.USE_UNIT
                                    , SUM(A.USE_QTY) AS USE_QTY, SUM(A.USE_WGT) AS USE_WGT
                                    , A.DISPO_UNIT, SUM(A.DISPO_QTY) AS DISPO_QTY, SUM(A.DISPO_WGT) AS DISPO_WGT
                              FROM( 
                                    SELECT WERKS, WRK_ORDR_NO, WRK_ORDR_SEQNO, LOT_NO, LOT_NO_M, UNIT AS USE_UNIT, UNIT AS DISPO_UNIT
                                        , SUM(USE_QTY) AS USE_QTY, SUM(WGT) AS USE_WGT
                                        --, DECODE(UNIT, ''KG'', 0, SUM(USE_QTY)) AS USE_QTY, SUM(WGT) AS USE_WGT
                                        , 0 AS DISPO_QTY, 0 AS DISPO_WGT
                                      FROM TB_INV010
                                     WHERE WERKS = ''P100''
                                       AND NVL(CNL_YN, ''N'') = ''N''
                                    GROUP BY WERKS, WRK_ORDR_NO, WRK_ORDR_SEQNO, LOT_NO, LOT_NO_M, UNIT 
                                    UNION ALL
                                    SELECT WERKS, WRK_ORDR_NO, WRK_ORDR_SEQNO, LOT_NO, LOT_NO_M, DECODE(UNIT, ''R'', UNIT, ''KG'') AS USE_UNIT, DECODE(UNIT, ''R'', UNIT, ''KG'') AS DISPO_UNIT
                                        ,0 AS USE_QTY, 0 AS USE_WGT
                                        , DECODE(UNIT, ''R'', SUM(DISPO_QTY), 0) AS DISPO_QTY, SUM(WGT) AS DISPO_WGT
                                      FROM TB_WRK004
                                     WHERE WERKS = ''P100''
                                       AND NVL(CNL_YN, ''N'') = ''N''
                                    GROUP BY WERKS, WRK_ORDR_NO, WRK_ORDR_SEQNO, LOT_NO, LOT_NO_M, UNIT 
                                    UNION ALL
                                    SELECT WERKS, WRK_ORDR_NO, WRK_ORDR_SEQNO, LOT_NO, LOT_NO_M, DECODE(UNIT, ''R'', UNIT, ''KG'') AS USE_UNIT, DECODE(UNIT, ''R'', UNIT, ''KG'') AS DISPO_UNIT
                                        ,0 AS USE_QTY, 0 AS USE_WGT
                                        , DECODE(UNIT, ''R'', SUM(DISPO_QTY), 0) AS DISPO_QTY, SUM(WGT) AS DISPO_WGT
                                      FROM TB_WRK022
                                     WHERE WERKS = ''P100''
                                       AND NVL(CNL_YN, ''N'') = ''N''
                                    GROUP BY WERKS, WRK_ORDR_NO, WRK_ORDR_SEQNO, LOT_NO, LOT_NO_M, UNIT 
                                   ) A 
                            GROUP BY A.WERKS, A.WRK_ORDR_NO, A.WRK_ORDR_SEQNO, A.LOT_NO, A.LOT_NO_M, A.USE_UNIT, A.DISPO_UNIT 
                            ) W000
                  ON W002.WERKS = W000.WERKS        
                  AND W002.WRK_ORDR_NO = W000.WRK_ORDR_NO
                  AND W002.WRK_ORDR_SEQNO = W000.WRK_ORDR_SEQNO
                  AND W002.LOT_NO = W000.LOT_NO   
                  LEFT JOIN (SELECT WERKS, MACH_CD, WRK_ORDR_NO, WRK_ORDR_SEQNO, LOT_NO, UNIT AS IN_UNIT, SUM(IN_QTY) AS IN_QTY, SUM(STCK_QTY) AS STCK_QTY
                               FROM TB_INV003
                              WHERE WERKS = ''P100''
                             GROUP BY WERKS, MACH_CD, WRK_ORDR_NO, WRK_ORDR_SEQNO, LOT_NO, UNIT) I003
                  ON W002.WERKS = I003.WERKS
                  AND W002.MACH_CD = I003.MACH_CD
                  AND W002.WRK_ORDR_NO = I003.WRK_ORDR_NO
                  AND W002.WRK_ORDR_SEQNO = I003.WRK_ORDR_SEQNO
                  AND W000.LOT_NO_M = I003.LOT_NO
                  INNER JOIN TB_MAS001 M001
                  ON W002.WERKS = M001.WERKS
                  AND W002.MATNR = M001.MATNR
                  INNER JOIN TB_MAS012 M012
                  ON W002.MACH_CD = M012.MACH_CD
                  INNER JOIN TB_MAS013 M013
                  ON M012.PROC_CD = M013.PROC_CD
                 WHERE 1=1 ';

        IF V_WERKS IS NOT NULL OR TRIM(V_WERKS) != '' THEN     --플랜트
            V_SQL := V_SQL || ' AND W002.WERKS = ''' || V_WERKS || ''' ';        
        END IF;        

        IF  V_RANGE_SQL IS NOT NULL OR TRIM(V_RANGE_SQL) != '' THEN
            --V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'WERKS', 'W002.WERKS');
            V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'PRD_DT', 'W002.PRFM_DT');
            V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'PROC_CD', 'M013.PROC_CD');
            V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'MACH_CD', 'M012.MACH_CD');
            V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'ORDER_NO', 'W002.ORDER_NO');
            V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'LOT_NO', 'W002.LOT_NO');

            V_SQL := V_SQL || V_RANGE_SQL ;			        
        END IF;       

        V_SQL := V_SQL || ' ORDER BY W002.PRFM_DT, W002.MACH_CD, W002.WRK_ORDR_NO, W002.WRK_ORDR_SEQNO, W002.LOT_NO, W000.LOT_NO_M';        

        V_DEBUG := 'Y';

        IF (V_DEBUG = 'Y') THEN
            INSERT INTO PROC_LOG(SQL_STR) VALUES (V_SQL);
            COMMIT;
        END IF;

		OPEN P_RS_LIST FOR V_SQL;
    END IF;

    P_SUCCESS := 'Y';

    EXCEPTION
    WHEN E_EXCEPTION_USER THEN

        -- 에러 내역 SET
	    P_SUCCESS           := 'N';
        E_SQL_ERR_CD        := SQLCODE;
        E_SQL_ERR_MSG       := SUBSTRB(SQLERRM,1,300);

        ROLLBACK;
        SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);

    WHEN OTHERS THEN
	    P_SUCCESS           := 'N';
        E_SQL_ERR_CD        := SQLCODE;
        E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

        ROLLBACK;
        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
END;
/
