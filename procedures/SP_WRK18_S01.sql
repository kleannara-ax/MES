
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_WRK18_S01" (
	P_TYPE           IN    varchar2,
	P_JSON_STR       IN    CLOB,
	P_SUCCESS       OUT    varchar2,
	P_RS_LIST       OUT    SYS_REFCURSOR 
)
/*==============================================================================
 * PROGRAM ID    : SP_WRK18_S01
 * PROGRAM NAME  : 폐품 항목별 중량
 * VERSION       : 1.0.0
 * DESCRIPTION   : 폐품 항목별 중량을 관리한다.
 *                 
 * AUTHOR NAME   : 안상현
 * CREATE DATE   : 2022/05/27
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}	<생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}		<생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}			<생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}	<생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/05/22    1.0.0   안상현         Initial Version 
 *==============================================================================
 *  관련 테이블
 *        - [TB_WRK004] 	: ( R  ) 생산실적 테이블
 *        - [CMCDV] 		: ( R  ) 공통코드 테이블	
 *        - [TB_MAS023] 	: ( R  ) 폐품(불량)항목 테이블
 *        - [V_WRK_ORDR] 	: ( R  ) 생산지시 뷰(가상테이블)	
 *=============================================================================*/


AS
	V_PRG_NM          	VARCHAR2(100) 	:= 'SP_WRK18_S01';     -- PROCEDURE NAME

	-- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  	EXCEPTION;
    E_SQL_ERR_CD      	NUMBER(5) 		:= 0;
    E_SQL_ERR_MSG		VARCHAR2(4000);

   -- JSON을 위한 변수선언 영역
    V_JSON				JSON_OBJECT_T;
    V_ARR_LIST       	JSON_ARRAY_T;
	V_OBJ            	JSON_OBJECT_T;

	-- 세션값 처리용 변수선언 영역
    V_SESS_USER_ID   	varchar2(20);
    V_PLT_CD         	varchar2(2);
   	V_DEBUG          	varchar2(1);

	-- 조건절 처리용 변수선언 영역
	V_DISPO_CD        	TB_WRK004.DISPO_CD%TYPE; 			--폐품코드
	V_RANGE_SQL      	varchar2(4000);						--실적일자, 폐품코드
    V_RANGE_SQL_1      	varchar2(4000);						
    V_RANGE_SQL_2      	varchar2(4000);						
	V_SQL				CLOB;
BEGIN
	OPEN P_RS_LIST FOR 

	SELECT NULL FROM DUAL WHERE ROWNUM = 0;

	V_JSON 				:= JSON_OBJECT_T.parse(P_JSON_STR);

	V_SESS_USER_ID		:= V_JSON.get_string('SES_USER_ID');
	V_PLT_CD			:= V_JSON.get_string('SES_PLNTKY');

	V_DISPO_CD			:= V_JSON.get_string('DISPO_CD'); 	--폐품코드
	V_RANGE_SQL         := V_JSON.get_string('RANGE_SQL');	--실적일자

	IF P_TYPE = 'LIST' THEN
        IF (V_RANGE_SQL IS NOT NULL OR TRIM(V_RANGE_SQL) != '') THEN
            V_RANGE_SQL_1 := REPLACE(REPLACE(V_RANGE_SQL, 'PRFM_DT', 'W004.PRFM_DT'), 'DISPO_CD', 'W004.DISPO_CD');
            V_RANGE_SQL_2 := REPLACE(REPLACE(V_RANGE_SQL, 'PRFM_DT', 'W022.PRFM_DT'), 'DISPO_CD', 'W022.DISPO_CD');
        END IF;
         
        V_SQL := ' SELECT DISPO_CD 							AS DISPO_CD		--폐품코드
                        , DISPO_NM 							AS DISPO_NM		--폐품명
                        , NVL(MA_2_JUM, 0)					AS MA_2_JUM 	--2호기 점보롤
                        , NVL(MA_2_MIL, 0)					AS MA_2_MIL 	--2호기 밀롤
                        , NVL(MA_2_SL, 0)					    AS MA_2_SL 	    --2호기 슬리터 -- 추가
                        , NVL(MA_2_JAE, 0)					AS MA_2_JAE 	--2호기 재단  --추가
                        , NVL(MA_2_JAEM, 0)					AS MA_2_JAEM 	--2호기 수재단  --추가
                        , NVL(MA_2_PO, 0)						AS MA_2_PO 		--2호기 포장  --추가
                        , NVL(MA_2_GYE, 0)					AS MA_2_GYE 	--2호기 계
                        , NVL(MA_3_JUM, 0)					AS MA_3_JUM 	--3호기 점보롤
                        , NVL(MA_3_MIL, 0)					AS MA_3_MIL 	--3호기 밀롤
                        , NVL(MA_3_SL, 0)					    AS MA_3_SL 	--3호기 슬리터   --추가
                        , NVL(MA_3_JAE, 0)					AS MA_3_JAE 	--3호기 재단
                        , NVL(MA_3_JAEM, 0)					AS MA_3_JAEM 	--3호기 수재단  --추가
                        , NVL(MA_3_PO, 0)						AS MA_3_PO 		--3호기 포장
                        , NVL(MA_3_GYE, 0)					AS MA_3_GYE 	--3호기 계
                        , NVL(TOT_JUM, 0)						AS TOT_JUM 		--점보롤 합계
                        , NVL(TOT_MIL, 0)						AS TOT_MIL 		--밀롤 합계
                        , NVL(TOT_SIL, 0)						AS TOT_SIL 		--슬리터 합계  --추가
                        , NVL(TOT_JAE, 0)						AS TOT_JAE 		--재단 합계
                        , NVL(TOT_SJAE, 0)						AS TOT_SJAE 	--수재단 합계
                        , NVL(TOT_PO, 0)						AS TOT_PO 		--포장 합계
                        , NVL(MA_2_GYE, 0) + NVL(MA_3_GYE, 0) AS TOT 			--총 합계
                      FROM(
                            SELECT AA.DISPO_CD
                                , M023.DISPO_NM
                                , AA.PROC_NM
                                , AA.DISPO_QTY
                              FROM(  
                                    SELECT A.DISPO_CD
                                        , CASE WHEN A.PROC_CD IS NOT NULL THEN CASE WHEN A.PROC_CD = ''PM2JA'' THEN ''2호기 점보롤''
                                                                                    WHEN A.PROC_CD = ''PM2MA'' THEN ''2호기 밀롤''
                                                                                    WHEN A.PROC_CD = ''PM2SA'' THEN ''2호기 슬리터''
                                                                                    WHEN A.PROC_CD = ''PM2CA'' THEN ''2호기 재단''
                                                                                    WHEN A.PROC_CD = ''PM2CB'' THEN ''2호기 수재단''
                                                                                    WHEN A.PROC_CD = ''PM2PC'' THEN ''2호기 포장''
                                                                                    WHEN A.PROC_CD = ''PM3JA'' THEN ''3호기 점보롤''
                                                                                    WHEN A.PROC_CD = ''PM3MA'' THEN ''3호기 밀롤''
                                                                                    WHEN A.PROC_CD = ''PM3SA'' THEN ''3호기 슬리터''
                                                                                    WHEN A.PROC_CD = ''PM3CA'' THEN ''3호기 재단''
                                                                                    WHEN A.PROC_CD = ''PM3CB'' THEN ''3호기 수재단''
                                                                                    WHEN A.PROC_CD = ''PM3PC'' THEN ''3호기 포장''
                                                                                    ELSE A.PROC_CD
                                                                                    END    
                                               WHEN A.CMCDVL IS NOT NULL THEN DECODE(A.CMCDVL, ''PM2'', ''2호기 계'', ''3호기 계'')
                                               WHEN A.TABLE_NM IS NOT NULL THEN
                                                    DECODE(A.TABLE_NM, ''SCH015'', ''점보롤 합계'', ''SCH016'', ''밀롤 합계'', ''SCH016_1'', ''슬리터 합계'', ''SCH017'', ''재단 합계'', ''SCH017_1'', ''수재단 합계'', ''SCH018'', ''포장 합계'')
                                               END  AS PROC_NM
                                        , SUM(A.WGT) AS DISPO_QTY
                                      FROM(      
                                            SELECT W004.DISPO_CD
                                                  , ''PM'' || DECODE(SUBSTR(W004.MATNR, 2, 1), ''0'', ''3'', SUBSTR(W004.MATNR, 2, 1)) AS CMCDVL
                                                  , ''PM'' || DECODE(SUBSTR(W004.MATNR, 2, 1), ''0'', ''3'', SUBSTR(W004.MATNR, 2, 1)) || CASE WHEN M012.PROC_CD IN (''PC'', ''PB'') THEN ''PC'' ELSE  M012.PROC_CD END  AS PROC_CD
                                                  , CASE WHEN M012.PROC_CD = ''JA'' THEN ''SCH015''
                                                          WHEN M012.PROC_CD = ''MA'' THEN ''SCH016''
                                                          WHEN M012.PROC_CD = ''SA'' THEN ''SCH016_1''
                                                          WHEN M012.PROC_CD = ''CA'' THEN ''SCH017''
                                                          WHEN M012.PROC_CD = ''CB'' THEN ''SCH017_1''
                                                          ELSE ''SCH018'' END AS TABLE_NM
                                                  
--                                                  , CASE WHEN SUBSTR(W004.WRK_ORDR_NO, 3, 2) = ''JA'' THEN ''SCH015''
--                                                          WHEN SUBSTR(W004.WRK_ORDR_NO, 3, 2) = ''MA'' AND M012.PROC_CD = ''MA'' THEN ''SCH016''
--                                                          WHEN SUBSTR(W004.WRK_ORDR_NO, 3, 2) = ''MA'' AND M012.PROC_CD = ''SA'' THEN ''SCH016_1''
--                                                          WHEN SUBSTR(W004.WRK_ORDR_NO, 3, 2) = ''CA'' AND M012.PROC_CD = ''CA'' THEN ''SCH017''
--                                                          WHEN SUBSTR(W004.WRK_ORDR_NO, 3, 2) = ''CA'' AND M012.PROC_CD = ''CB'' THEN ''SCH017_1''
--                                                          ELSE ''SCH018'' END AS TABLE_NM
                                                  , W004.WGT
                                              FROM TB_WRK004 W004
                                              LEFT JOIN TB_MAS012 M012
                                              ON W004.MACH_CD = M012.MACH_CD
                                             WHERE WERKS = ''P100'' ';

                    IF (V_RANGE_SQL_1 IS NOT NULL OR TRIM(V_RANGE_SQL_1) != '') THEN
                        V_SQL := V_SQL || V_RANGE_SQL_1; --실적일자
                    END IF;                                               
                    V_SQL := V_SQL || '            AND NVL(W004.CNL_YN, ''N'') = ''N''
                                            UNION ALL   
                                               SELECT W022.DISPO_CD
                                                  , ''PM'' || DECODE(SUBSTR(W022.MATNR, 2, 1), ''0'', ''3'', SUBSTR(W022.MATNR, 2, 1)) AS CMCDVL
                                                  , ''PM'' || DECODE(SUBSTR(W022.MATNR, 2, 1), ''0'', ''3'', SUBSTR(W022.MATNR, 2, 1)) || CASE WHEN M012.PROC_CD IN (''PC'', ''PB'') THEN ''PC'' ELSE  M012.PROC_CD END  AS PROC_CD
                                                  , CASE WHEN M012.PROC_CD = ''JA'' THEN ''SCH015''
                                                          WHEN M012.PROC_CD = ''MA'' THEN ''SCH016''
                                                          WHEN M012.PROC_CD = ''SA'' THEN ''SCH016_1''
                                                          WHEN M012.PROC_CD = ''CA'' THEN ''SCH017''
                                                          WHEN M012.PROC_CD = ''CB'' THEN ''SCH017_1''
                                                          ELSE ''SCH018'' END AS TABLE_NM
                                                          
--                                                  , CASE WHEN SUBSTR(W022.WRK_ORDR_NO, 3, 2) = ''JA'' THEN ''SCH015''
--                                                          WHEN SUBSTR(W022.WRK_ORDR_NO, 3, 2) = ''MA'' AND M012.PROC_CD = ''MA'' THEN ''SCH016''
--                                                          WHEN SUBSTR(W022.WRK_ORDR_NO, 3, 2) = ''MA'' AND M012.PROC_CD = ''SA'' THEN ''SCH016_1''
--                                                          WHEN SUBSTR(W022.WRK_ORDR_NO, 3, 2) = ''CA'' AND M012.PROC_CD = ''CA'' THEN ''SCH017''
--                                                          WHEN SUBSTR(W022.WRK_ORDR_NO, 3, 2) = ''CA'' AND M012.PROC_CD = ''CB'' THEN ''SCH017_1''
--                                                          ELSE ''SCH018'' END AS TABLE_NM
                                                  , W022.WGT
                                              FROM TB_WRK022 W022
                                              LEFT JOIN TB_MAS012 M012
                                              ON W022.MACH_CD = M012.MACH_CD
                                             WHERE W022.WERKS = ''P100''';
                    
                    IF (V_RANGE_SQL_2 IS NOT NULL OR TRIM(V_RANGE_SQL_2) != '') THEN
                        V_SQL := V_SQL || V_RANGE_SQL_2; --실적일자
                    END IF;                                                      
                                               
                    V_SQL := V_SQL || '            AND NVL(W022.CNL_YN, ''N'') = ''N''
                                               ) A
                                      GROUP BY GROUPING SETS((A.DISPO_CD, A.CMCDVL), (A.DISPO_CD, A.PROC_CD), (A.DISPO_CD, A.TABLE_NM))   
                                      ) AA
                                    LEFT JOIN TB_MAS023 M023 ON (M023.DISPO_CD = AA.DISPO_CD AND M023.WERKS = ''P100'')
                      )
                      PIVOT (
                                    SUM(DISPO_QTY)
                                    FOR PROC_NM IN (
                                        ''2호기 점보롤'' 		AS MA_2_JUM
                                    , 	''2호기 밀롤'' 		AS MA_2_MIL
                                    , 	''2호기 슬리터'' 		AS MA_2_SL
                                    , 	''2호기 재단'' 		AS MA_2_JAE
                                    , 	''2호기 수재단'' 		AS MA_2_JAEM
                                    , 	''2호기 포장'' 		AS MA_2_PO
                                    , 	''2호기 계'' 			AS MA_2_GYE
                                    ,	''3호기 점보롤'' 		AS MA_3_JUM
                                    , 	''3호기 밀롤'' 		AS MA_3_MIL
                                    , 	''3호기 슬리터'' 		AS MA_3_SL
                                    , 	''3호기 재단'' 		AS MA_3_JAE
                                    , 	''3호기 수재단'' 		AS MA_3_JAEM
                                    ,	''3호기 포장'' 		AS MA_3_PO
                                    , 	''3호기 계'' 			AS MA_3_GYE
                                    ,	''점보롤 합계'' 		AS TOT_JUM
                                    , 	''밀롤 합계'' 			AS TOT_MIL
                                    , 	''슬리터 합계'' 			AS TOT_SIL
                                    , 	''재단 합계'' 			AS TOT_JAE
                                    , 	''수재단 합계'' 			AS TOT_SJAE
                                    , 	''포장 합계'' 			AS TOT_PO
                                    )
                                )
                                ORDER BY DISPO_CD ';
        V_DEBUG := 'Y';
        IF (V_DEBUG = 'Y') THEN
        	INSERT INTO PROC_LOG (SQL_STR) VALUES (V_SQL);
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
		P_SUCCESS			:= 'N';
        E_SQL_ERR_CD        := SQLCODE;
		E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

		ROLLBACK;
		RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
END;
/
