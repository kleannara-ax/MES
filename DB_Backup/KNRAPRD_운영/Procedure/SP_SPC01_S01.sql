--------------------------------------------------------
--  DDL for Procedure SP_SPC01_S01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_SPC01_S01" (
	P_TYPE         IN    varchar2, 
	P_JSON_STR     IN    CLOB,
	P_SUCCESS      OUT   varchar2,
	P_RS_LIST      OUT   SYS_REFCURSOR 
)
/*==============================================================================
 * PROGRAM ID    : SP_SPC01_S01{호출 프로그램 ID 기술}
 * PROGRAM NAME  : SPC {호출 프로그램 명 기술}
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 자재별, 품질검사 항목별 SPC내역 조회 {프로그램에 대한 상세한 내용 기술}
 *                 
 * AUTHOR NAME   : 안상현{최초 작성자 명 기술}
 * CREATE DATE   : 2022/07/25 {최초 작성일자 기술}
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * yyyy/mm/dd    1.0.0   안상현         Initial Version 
 * yyyy/mm/dd    1.0.1   박성철          
 * yyyy/mm/dd    1.0.2   김성하          
 *==============================================================================
 *  관련 테이블 - 모든 테이블 조회만 함
 *        - [TB_MAS014] : ( R  ) 검사항목그룹별 항목관리 테이블
 *        - [TB_MAS016] : ( R  ) 검사항목별 기준값 정보 테이블
 *        - [USRMA] 	: ( R  ) 사용자 정보 테이블
 *=============================================================================*/

AS

    V_PRG_NM          VARCHAR2(100)  := 'SP_SPC01_S01';     -- PROCEDURE NAME

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
    V_PLT_CD         varchar2(30);
    V_SESS_USER_ID   varchar2(20);

    -- 조건절 처리용 변수선언 영역
    V_WERKS				TB_MAS016.WERKS%TYPE;				--플랜트코드
    V_INSP_ITEM_GRP_CD	TB_MAS016.INSP_ITEM_GRP_CD%TYPE;	--검사항목그룹코드
    V_INSP_ITEM_CD		TB_MAS014.INSP_ITEM_CD%TYPE;		--검사항목코드
    V_INSP_ITEM_NM		TB_MAS014.INSP_ITEM_NM%TYPE;		--검사항목명
    V_MSRM_DATE_ST		TB_QLT020.MSRM_DATE%TYPE;			--측정일자(시작)
    V_MSRM_DATE_ED		TB_QLT020.MSRM_DATE%TYPE;			--측정일자(끝)
    V_MATNR				TB_MAS016.MATNR%TYPE;				--자재코드

BEGIN


	OPEN P_RS_LIST FOR 

    SELECT NULL FROM DUAL WHERE ROWNUM = 0;


    V_DEBUG := 'N';
    V_RUN_SQL := 'Y';

    V_JSON := JSON_OBJECT_T.parse(P_JSON_STR);

    V_SESS_USER_ID       :=      V_JSON.get_string('SES_USER_ID');
    V_PLT_CD             :=      V_JSON.get_string('SES_PLNTKY');

    /* 조건값 할당 */
--    V_RANGE_SQL         :=      V_JSON.get_string('RANGE_SQL');
    V_WERKS			 	 := 		V_JSON.get_string('WERKS');				-- 플랜트코드  
    V_INSP_ITEM_GRP_CD	 := 		V_JSON.get_string('INSP_ITEM_GRP_CD');	-- 검사항목그룹코드 
    V_INSP_ITEM_CD		 := 		V_JSON.get_string('INSP_ITEM_CD');		-- 검사항목코드
    V_INSP_ITEM_NM		 := 		V_JSON.get_string('INSP_ITEM_NM');		-- 검사항목명    
    V_MSRM_DATE_ST		 := 		V_JSON.get_string('MSRM_DATE_ST');		-- 측정일자(시작) 
    V_MSRM_DATE_ED		 := 		V_JSON.get_string('MSRM_DATE_ED');		-- 측정일자(끝)  
    V_MATNR			 	 := 		V_JSON.get_string('MATNR');				-- 자재코드     



    IF P_TYPE = 'LIST1' THEN /*상단 그리드*/


        V_SQL :=  V_SQL || ' WITH BASE AS (
								SELECT 
								       QLT020.WERKS
								     , QLT020.MATNR
								     , QLT020.LOT_NO
								     , QLT020.IND_BCD
								     , QLT020.FNL_JDGM
								     , QLT020.UCFMTY_AMT
								     , MAS016.INSP_ITEM_CD
								     , QLT020.INSP_ITEM_GRP_CD
								     , MAS014.INSP_ITEM_NM
								  FROM TB_QLT020 QLT020
								  JOIN TB_MAS016 MAS016
								    ON MAS016.INSP_ITEM_GRP_CD = QLT020.INSP_ITEM_GRP_CD
								   --AND MAS016.INSP_ITEM_CD = QLT020.INSP_ITEM_CD
								   AND MAS016.MATNR = QLT020.MATNR
								   AND MAS016.WERKS = QLT020.WERKS
								  JOIN TB_MAS014 MAS014
								    ON MAS014.INSP_ITEM_GRP_CD = MAS016.INSP_ITEM_GRP_CD
								   AND MAS014.INSP_ITEM_CD = MAS016.INSP_ITEM_CD
								 WHERE 1=1 ';


        IF  V_INSP_ITEM_GRP_CD IS NOT NULL OR TRIM(V_INSP_ITEM_GRP_CD) != '' THEN	   -- 검사항목그룹코드
            V_SQL := V_SQL || ' AND QLT020.INSP_ITEM_GRP_CD = ''' || V_INSP_ITEM_GRP_CD || '''';        
        END IF;

        IF  V_MATNR IS NOT NULL OR TRIM(V_MATNR) != '' THEN	   -- 자재코드
            V_SQL := V_SQL || ' AND QLT020.MATNR = ''' || V_MATNR || '''';        
        END IF;

        IF  V_WERKS IS NOT NULL OR TRIM(V_WERKS) != '' THEN	   -- 플랜트
            V_SQL := V_SQL || ' AND QLT020.WERKS = ''' || V_WERKS || '''';        
        END IF;

        IF  V_MSRM_DATE_ST IS NOT NULL OR TRIM(V_MSRM_DATE_ST) != '' THEN	-- 측정일자(시작)
            V_SQL := V_SQL || ' AND QLT020.MSRM_DATE >= TO_DATE(''' || V_MSRM_DATE_ST || ''')';        
        END IF;

        IF  V_MSRM_DATE_ED IS NOT NULL OR TRIM(V_MSRM_DATE_ED) != '' THEN	-- 측정일자(끝)
            V_SQL := V_SQL || ' AND QLT020.MSRM_DATE < TO_DATE(''' || V_MSRM_DATE_ED || ''') + 1';        
        END IF;

        IF  V_INSP_ITEM_NM IS NOT NULL OR TRIM(V_INSP_ITEM_NM) != '' THEN	 -- 검사항목명
            V_SQL := V_SQL || ' AND MAS014.INSP_ITEM_NM  LIKE ''%' || V_INSP_ITEM_NM || '%''';
        END IF;

--        IF V_RANGE_SQL IS NOT NULL OR TRIM(V_RANGE_SQL) != '' THEN
--            V_SQL := V_SQL || V_RANGE_SQL;
--        END IF;



        V_SQL :=  V_SQL || ' 	   AND MAS014.CPK_YN = ''Y''
								   AND MAS014.USE_YN = ''Y''
								/*ORDER BY MAS016.INSP_ITEM_CD*/
							)
							--SELECT * FROM BASE;
							SELECT MAIN.WERKS
							     , MAIN.MACH_CD
							     , MAS012.MACH_NM
							     , MAIN.MATNR
							     , MAS001.MATNR_NM
							     , SUM(DECODE(MAIN.FNL_JDGM, ''PASS'', 1, 0)) PASS_CNT -- 합격수량 		
							     , SUM(DECODE(MAIN.FNL_JDGM, ''FAIL'', 1, 0)) FAIL_CNT -- 불합격수량 		
							     , SUM(MAIN.UCFMTY_AMT) UCFMTY_AMT  -- 부적합량  
							  FROM (
								SELECT WRK001.MACH_CD, BASE.*
								  FROM BASE BASE
								  JOIN TB_WRK001 WRK001
								    ON WRK001.WERKS = BASE.WERKS
								   AND WRK001.LOT_NO = BASE.LOT_NO    
								   AND WRK001.IND_BCD = BASE.IND_BCD
								UNION ALL
								SELECT WRK002.MACH_CD, BASE.*
								  FROM BASE BASE
								  JOIN TB_WRK002 WRK002
								    ON WRK002.WERKS = BASE.WERKS
								   AND WRK002.LOT_NO = BASE.LOT_NO    
								   AND WRK002.IND_BCD = BASE.IND_BCD
							  ) MAIN
							  LEFT JOIN TB_MAS001 MAS001
							    ON MAS001.MATNR = MAIN.MATNR
							   AND MAS001.WERKS = MAIN.WERKS
							  LEFT JOIN TB_MAS012 MAS012
							    ON MAS012.MACH_CD = MAIN.MACH_CD
							--  LEFT JOIN TB_MAS014 MAS014
							--     ON MAS014.INSP_ITEM_GRP_CD = MAIN.INSP_ITEM_GRP_CD 
							--    AND MAS014.INSP_ITEM_CD = MAIN.INSP_ITEM_CD
							 GROUP BY MAIN.WERKS
							        , MAIN.MACH_CD
							        , MAS012.MACH_NM
							        , MAIN.MATNR
							        , MAS001.MATNR_NM
							 ORDER BY 1,2,3,4,5 ';


--
--        V_DEBUG := 'Y';
--
--        IF (V_DEBUG = 'Y') THEN
--            INSERT INTO PROC_LOG(SQL_STR) VALUES (V_SQL);
--        END IF;

		OPEN P_RS_LIST FOR V_SQL;

	ELSIF P_TYPE = 'LIST2' THEN   --좌하단 그리드


        V_SQL :=  V_SQL || ' SELECT  
							        MAS016.INSP_ITEM_GRP_CD
							      , MAS016.MATNR
							      , MAS016.WERKS
							      , MAS016.INSP_ITEM_CD
							      , MAS014.INSP_ITEM_NM AS INSP_ITEM
							      , MAS016.STD_VAL AS STD_VAL_SPEC
							      , MAS016.UPP_VAL AS UPP_VAL_USL
							      , MAS016.LOW_VAL AS LOW_VAL_LSL
							      , (
							           SELECT COUNT(*)
							             FROM TB_QLT021 QLT021
							             JOIN TB_MAS014 MAS014
							               ON MAS014.INSP_ITEM_GRP_CD = QLT021.INSP_ITEM_GRP_CD
							              AND MAS014.INSP_ITEM_CD = QLT021.INSP_ITEM_CD
							            WHERE QLT021.INSP_ITEM_GRP_CD = MAS016.INSP_ITEM_GRP_CD
							              AND QLT021.MATNR = MAS016.MATNR
							              AND QLT021.WERKS = MAS016.WERKS ';


        IF  V_MSRM_DATE_ST IS NOT NULL OR TRIM(V_MSRM_DATE_ST) != '' THEN	-- 측정일자(시작)
            V_SQL := V_SQL || ' AND QLT021.MSRM_DATE >= TO_DATE(''' || V_MSRM_DATE_ST || ''')';        
        END IF;

        IF  V_MSRM_DATE_ED IS NOT NULL OR TRIM(V_MSRM_DATE_ED) != '' THEN	-- 측정일자(끝)
            V_SQL := V_SQL || ' AND QLT021.MSRM_DATE < TO_DATE(''' || V_MSRM_DATE_ED || ''') + 1';        
        END IF;


		V_SQL :=  V_SQL || '              AND QLT021.INSP_ITEM_CD = MAS016.INSP_ITEM_CD
							              AND MAS014.CPK_YN = ''Y''
							              AND MAS014.USE_YN = ''Y''
							        ) MSRM_CNT
							   FROM TB_MAS016 MAS016
							   JOIN TB_MAS014 MAS014
							     ON MAS014.INSP_ITEM_GRP_CD = MAS016.INSP_ITEM_GRP_CD 
							    AND MAS014.INSP_ITEM_CD = MAS016.INSP_ITEM_CD
							  WHERE 1=1 ';				             


		IF  V_INSP_ITEM_GRP_CD IS NOT NULL OR TRIM(V_INSP_ITEM_GRP_CD) != '' THEN	   -- 검사항목그룹코드
            V_SQL := V_SQL || ' AND MAS016.INSP_ITEM_GRP_CD = ''' || V_INSP_ITEM_GRP_CD || '''';        
        END IF;					             

        IF  V_INSP_ITEM_NM IS NOT NULL OR TRIM(V_INSP_ITEM_NM) != '' THEN	 -- 검사항목명
            V_SQL := V_SQL || ' AND MAS014.INSP_ITEM_NM  LIKE ''%' || V_INSP_ITEM_NM || '%''';
        END IF;

        IF  V_MATNR IS NOT NULL OR TRIM(V_MATNR) != '' THEN	   -- 자재코드
            V_SQL := V_SQL || ' AND MAS016.MATNR = ''' || V_MATNR || '''';        
        END IF;

        IF  V_WERKS IS NOT NULL OR TRIM(V_WERKS) != '' THEN	   -- 플랜트
            V_SQL := V_SQL || ' AND MAS016.WERKS = ''' || V_WERKS || '''';        
        END IF;


       V_SQL :=  V_SQL || '    AND MAS014.CPK_YN = ''Y''
							   AND MAS014.USE_YN = ''Y''
							 ORDER BY MAS014.INSP_ITEM_NM ';


--		V_DEBUG := 'Y';
--
--        IF (V_DEBUG = 'Y') THEN
--            INSERT INTO PROC_LOG(SQL_STR) VALUES (V_SQL);
--        END IF;


    	OPEN P_RS_LIST FOR V_SQL;

	ELSIF P_TYPE = 'LIST3' THEN   --우하단 1줄 그리드


        V_SQL :=  ' WITH PRM AS (
						SELECT ';


        IF  V_INSP_ITEM_GRP_CD IS NOT NULL OR TRIM(V_INSP_ITEM_GRP_CD) != '' THEN	-- 검사항목그룹코드
            V_SQL := V_SQL || '''' || V_INSP_ITEM_GRP_CD || ''' INSP_ITEM_GRP_CD ';       
        END IF;

        IF  V_INSP_ITEM_CD IS NOT NULL OR TRIM(V_INSP_ITEM_CD) != '' THEN	 		-- 검사항목코드
            V_SQL := V_SQL || ', ''' || V_INSP_ITEM_CD || ''' INSP_ITEM_CD ';
        END IF;

        IF  V_MATNR IS NOT NULL OR TRIM(V_MATNR) != '' THEN	   -- 자재코드
            V_SQL := V_SQL || ', ''' || V_MATNR || ''' MATNR ';        
        END IF;

        IF  V_WERKS IS NOT NULL OR TRIM(V_WERKS) != '' THEN	   -- 플랜트
            V_SQL := V_SQL || ', ''' || V_WERKS || ''' WERKS ';
        END IF;

        IF  V_MSRM_DATE_ST IS NOT NULL OR TRIM(V_MSRM_DATE_ST) != '' THEN	-- 측정일자(시작)
            V_SQL := V_SQL || ', ''' || V_MSRM_DATE_ST || ''' MSRM_DATE_ST ';       
        END IF;

        IF  V_MSRM_DATE_ED IS NOT NULL OR TRIM(V_MSRM_DATE_ED) != '' THEN	-- 측정일자(끝)
            V_SQL := V_SQL || ', ''' || V_MSRM_DATE_ED || ''' MSRM_DATE_ED ';      
        END IF;


       V_SQL :=  V_SQL || '	  FROM DUAL
				)
				, T1 (ACTVALUE) AS (			
				   SELECT QLT022.RST_VAL
				     --FROM TB_QLT021 QLT022  --*****테스트용
				     FROM TB_QLT022 QLT022  --실적용용
				     JOIN PRM PRM ON 1=1
				    WHERE 1=1
				      AND QLT022.INSP_ITEM_GRP_CD = PRM.INSP_ITEM_GRP_CD
				      AND QLT022.MATNR            = PRM.MATNR
				      AND QLT022.WERKS            = PRM.WERKS
				      --AND MSRM_DATE BETWEEN TO_DATE(''2020-01-01'') AND TO_DATE(''2022-12-31'')
				      AND QLT022.MSRM_DATE >= TO_DATE(PRM.MSRM_DATE_ST)
				      AND QLT022.MSRM_DATE < TO_DATE(PRM.MSRM_DATE_ED) + 1
				      AND QLT022.INSP_ITEM_CD = PRM.INSP_ITEM_CD
				)
				, T2 AS (
					SELECT MAS016.STD_VAL AS SPECVAL
					     , MAS016.UPP_VAL AS SPEC_USL
					     , MAS016.LOW_VAL AS SPEC_LSL
					     --, MAS016.UPP_VAL + MAS016.LOW_VAL AS SPEC_USL_PLS_LSL
					  FROM TB_MAS016 MAS016
					  JOIN TB_MAS014 MAS014
					    ON MAS014.INSP_ITEM_GRP_CD = MAS016.INSP_ITEM_GRP_CD
					   AND MAS014.INSP_ITEM_CD     = MAS016.INSP_ITEM_CD
					  JOIN PRM PRM ON 1=1
					 WHERE 1=1
					   AND MAS016.INSP_ITEM_GRP_CD = PRM.INSP_ITEM_GRP_CD
					   AND MAS016.INSP_ITEM_CD     = PRM.INSP_ITEM_CD
					   AND MAS016.MATNR            = PRM.MATNR 
					   AND MAS016.WERKS            = PRM.WERKS
					   AND MAS014.CPK_YN           = ''Y''
					   AND MAS014.USE_YN           = ''Y''
				)
				, T3 (STDDEV_WITHIN) AS (
					SELECT
					       ROUND(SQRT(SUM(AA.B) / 
                                    CASE WHEN (COUNT(*) - (COUNT(*) / AA.MSRM_ACC )) = 0 THEN 1
                                         ELSE (COUNT(*) - (COUNT(*) / AA.MSRM_ACC )) END
                                 ) / 0.996880, 7)
 				    FROM (		
						SELECT 
						       POWER(ACTVALUE - AVG(ACTVALUE) OVER(PARTITION BY CEIL(ROWNUM / M014.MSRM_ACC)), 2) B
						     , M014.MSRM_ACC
						  FROM DUAL		
						     , ( SELECT DECODE(MAS014.MSRM_ACC, NULL, 1, 0, 1, MAS014.MSRM_ACC) AS MSRM_ACC
						               --NVL(MSRM_ACC, 1) AS MSRM_ACC			
						          FROM TB_MAS014 MAS014
						          JOIN PRM PRM ON 1=1
						         WHERE 1=1
						           AND MAS014.INSP_ITEM_GRP_CD = PRM.INSP_ITEM_GRP_CD
						           AND MAS014.INSP_ITEM_CD     = PRM.INSP_ITEM_CD
						       ) M014, T1			
				    ) AA
 				    GROUP BY MSRM_ACC			
				)
				SELECT			
				      SPECVAL  --기준값			
				    , SPEC_USL --상한값			
				    , SPEC_LSL --하한값 			
				    , TRUNC(AVG(ACTVALUE),5) AVG --평균			
				    , TRUNC(VAR_POP(ACTVALUE),5) POP --VAR --분산			
				    , TRUNC(T3.STDDEV_WITHIN,5) STDDEV_WITHIN	--표준편차		
				    , TRUNC(ROUND(STDDEV_SAMP(ACTVALUE),7),5) STDDEV_OVERALL --표본 표준편차    
				    , TRUNC(ABS( (SPEC_USL+SPEC_LSL)/ DECODE(2-AVG(ACTVALUE), NULL,1, 0,1, 2-AVG(ACTVALUE)) )
				      / DECODE( ((SPEC_USL-SPEC_LSL)/2), NULL,1, 0,1, ((SPEC_USL-SPEC_LSL)/2) ), 5) K --치우침			
				--    , TRUNC(ABS( (SPEC_USL+SPEC_LSL)/2-AVG(ACTVALUE) ) / ( (SPEC_USL-SPEC_LSL)/2 ),5) K --치우침			
				    , TRUNC((SPEC_USL-SPEC_LSL)
					        / CASE WHEN (6*ROUND(STDDEV_SAMP(ACTVALUE),4)) = 0 THEN 1
					               WHEN (6*ROUND(STDDEV_SAMP(ACTVALUE),4)) IS NULL THEN 1
					               ELSE (6*ROUND(STDDEV_SAMP(ACTVALUE),4)) END
					  , 2) PP        			
				--    , TRUNC((SPEC_USL-SPEC_LSL)/(6*ROUND(STDDEV_SAMP(ACTVALUE),4)),2) PP        			
				    , TRUNC((AVG(ACTVALUE)-SPEC_LSL)
				            / CASE WHEN (3*ROUND(STDDEV_SAMP(ACTVALUE),4)) = 0 THEN 1
				                   WHEN (3*ROUND(STDDEV_SAMP(ACTVALUE),4)) IS NULL THEN 1
				                   ELSE (3*ROUND(STDDEV_SAMP(ACTVALUE),4)) END
				      , 2) PPL			
				--    , TRUNC((AVG(ACTVALUE)-SPEC_LSL)/(3*ROUND(STDDEV_SAMP(ACTVALUE),4)),2) PPL			
				    , TRUNC((SPEC_USL-AVG(ACTVALUE))
				          / CASE WHEN (3*ROUND(STDDEV_SAMP(ACTVALUE),4)) = 0 THEN 1
				                 WHEN (3*ROUND(STDDEV_SAMP(ACTVALUE),4)) IS NULL THEN 1
				                 ELSE (3*ROUND(STDDEV_SAMP(ACTVALUE),4)) END
				      , 2) PPU
				--    , TRUNC((SPEC_USL-AVG(ACTVALUE))/(3 * ROUND(STDDEV_SAMP(ACTVALUE),4)),2) PPU			
				    , TRUNC((1-ABS( (SPEC_USL+SPEC_LSL) / DECODE(2-AVG(ACTVALUE), NULL,1, 0,1, 2-AVG(ACTVALUE)) )
				             / ( (SPEC_USL-SPEC_LSL)/2 )) * ROUND((SPEC_USL-SPEC_LSL)
				                                                  / CASE WHEN (6*ROUND(STDDEV_SAMP(ACTVALUE),4)) = 0 THEN 1
				                                                         WHEN (6*ROUND(STDDEV_SAMP(ACTVALUE),4)) IS NULL THEN 1
				                                                         ELSE (6*ROUND(STDDEV_SAMP(ACTVALUE),4)) END
				                                            , 4), 2) PPK
				--    , TRUNC((1-ABS( (SPEC_USL+SPEC_LSL)/2-AVG(ACTVALUE) ) / ( (SPEC_USL-SPEC_LSL)/2 ))*ROUND((SPEC_USL-SPEC_LSL)/(6 * ROUND(STDDEV_SAMP(ACTVALUE),4)),4),2) PPK			
				--    , TRUNC(LEAST((SPEC_USL-AVG(ACTVALUE))/(3 * ROUND(STDDEV_SAMP(ACTVALUE),4)),(AVG(ACTVALUE)-SPEC_LSL)/(3 * ROUND(STDDEV_SAMP(ACTVALUE),4))),2) PPK2    			
				    , TRUNC((SPEC_USL-SPEC_LSL)
				          / CASE WHEN (6*ROUND(T3.STDDEV_WITHIN,4)) = 0 THEN 1
				                 WHEN (6*ROUND(T3.STDDEV_WITHIN,4)) IS NULL THEN 1
				                 ELSE (6*ROUND(T3.STDDEV_WITHIN,4)) END
				      , 2) CP
				--    , TRUNC((SPEC_USL-SPEC_LSL)/(6*ROUND(T3.STDDEV_WITHIN,4)),2) CP    			
				    , TRUNC((AVG(ACTVALUE)-SPEC_LSL)
				          / CASE WHEN (3*ROUND(T3.STDDEV_WITHIN,4)) = 0 THEN 1
				                 WHEN (3*ROUND(T3.STDDEV_WITHIN,4)) IS NULL THEN 1
				                 ELSE (3*ROUND(T3.STDDEV_WITHIN,4)) END
				      , 2) CPL
				--    , TRUNC((AVG(ACTVALUE)-SPEC_LSL)/(3 * ROUND(T3.STDDEV_WITHIN,4)),2) CPL			
				    , TRUNC((SPEC_USL-AVG(ACTVALUE))
				          / CASE WHEN (3*ROUND(T3.STDDEV_WITHIN,4)) = 0 THEN 1
				                 WHEN (3*ROUND(T3.STDDEV_WITHIN,4)) IS NULL THEN 1
				                 ELSE (3*ROUND(T3.STDDEV_WITHIN,4)) END
				      , 2) CPU			
				--    , TRUNC((SPEC_USL-AVG(ACTVALUE))/(3 * ROUND(T3.STDDEV_WITHIN,4)),2) CPU			
				    , TRUNC((1 - ABS( (SPEC_USL+SPEC_LSL)/ DECODE(2 - AVG(ACTVALUE), NULL, 1, 0, 1, 2 - AVG(ACTVALUE)) )
				             / CASE WHEN ( (SPEC_USL-SPEC_LSL)/2 ) = 0 THEN 1
				                    WHEN ( (SPEC_USL-SPEC_LSL)/2 ) IS NULL THEN 1
				                    ELSE ( (SPEC_USL-SPEC_LSL)/2 ) END
				          ) * ROUND((SPEC_USL - SPEC_LSL)
				                    / CASE WHEN (6*ROUND(T3.STDDEV_WITHIN,4)) = 0 THEN 1
				                           WHEN (6*ROUND(T3.STDDEV_WITHIN,4)) IS NULL THEN 1
				                           ELSE (6*ROUND(T3.STDDEV_WITHIN,4)) END
				              , 4)
				      , 2) CPK
				--    , TRUNC((1-ABS( (SPEC_USL+SPEC_LSL)/2-AVG(ACTVALUE) ) / ( (SPEC_USL-SPEC_LSL)/2 ))*ROUND((SPEC_USL-SPEC_LSL)/(6*ROUND(T3.STDDEV_WITHIN,4)),4),2) CPK
				--    , TRUNC(LEAST((SPEC_USL-AVG(ACTVALUE))/(3*ROUND(T3.STDDEV_WITHIN,4)),(AVG(ACTVALUE)-SPEC_LSL)/(3 * ROUND(T3.STDDEV_WITHIN,4))),2) CPK2 			
				--    , TRUNC(SUM(CASE WHEN ACTVALUE BETWEEN SPEC_LSL AND SPEC_USL THEN 1 ELSE 0 END) / DECODE(COUNT(1)*100, NULL,1, 0,1, COUNT(1)*100), 2) PASS_RATE			
				    , TRUNC(SUM(CASE WHEN ACTVALUE BETWEEN SPEC_LSL AND SPEC_USL THEN 1 ELSE 0 END)/COUNT(1) * 100, 2) PASS_RATE			
				    , COUNT(*) OBS			
				FROM T1,T2,T3 GROUP BY T3.STDDEV_WITHIN, SPECVAL, SPEC_USL, SPEC_LSL ';

		 V_DEBUG := 'Y';
--
--        IF (V_DEBUG = 'Y') THEN
--            INSERT INTO PROC_LOG(SQL_STR) VALUES (V_SQL);
--        END IF;

    	OPEN P_RS_LIST FOR V_SQL;

	ELSIF P_TYPE = 'CHRT1' THEN   --상단차트


       V_SQL :=  ' WITH PRM AS (
						SELECT ';


        IF  V_INSP_ITEM_GRP_CD IS NOT NULL OR TRIM(V_INSP_ITEM_GRP_CD) != '' THEN	-- 검사항목그룹코드
            V_SQL := V_SQL || '''' || V_INSP_ITEM_GRP_CD || ''' INSP_ITM_GRP_CD ';       
        END IF;

        IF  V_INSP_ITEM_CD IS NOT NULL OR TRIM(V_INSP_ITEM_CD) != '' THEN	 		-- 검사항목코드
            V_SQL := V_SQL || ', ''' || V_INSP_ITEM_CD || ''' INSP_ITM_CD ';
        END IF;


        V_SQL :=  V_SQL || '	  FROM DUAL
							)
							--SELECT * FROM PRM;
							, BASE AS (
							   SELECT TO_CHAR(MSRM_DATE, ''YYYY/MM/DD'') MSRM_DAY
							        , NVL(A.RST_VAL, 0) RST_VAL
							--        , A.*
							     --FROM TB_QLT021 A  --테스트용
							     FROM TB_QLT022 A  --실적용용
							     JOIN PRM PRM ON 1=1
							    WHERE 1=1
							      AND INSP_ITEM_GRP_CD = PRM.INSP_ITM_GRP_CD ';      


        IF  V_MATNR IS NOT NULL OR TRIM(V_MATNR) != '' THEN	   -- 자재코드
            V_SQL := V_SQL || ' AND MATNR = ''' || V_MATNR || '''';        
        END IF;

        IF  V_WERKS IS NOT NULL OR TRIM(V_WERKS) != '' THEN	   -- 플랜트
            V_SQL := V_SQL || ' AND WERKS = ''' || V_WERKS || '''';        
        END IF;


        IF  V_MSRM_DATE_ST IS NOT NULL OR TRIM(V_MSRM_DATE_ST) != '' THEN	-- 측정일자(시작)
            V_SQL := V_SQL || ' AND MSRM_DATE >= TO_DATE(''' || V_MSRM_DATE_ST || ''')';        
        END IF;

        IF  V_MSRM_DATE_ED IS NOT NULL OR TRIM(V_MSRM_DATE_ED) != '' THEN	-- 측정일자(끝)
            V_SQL := V_SQL || ' AND MSRM_DATE < TO_DATE(''' || V_MSRM_DATE_ED || ''') + 1';        
        END IF;


       V_SQL :=  V_SQL || '      AND INSP_ITEM_CD = PRM.INSP_ITM_CD
							)
							--SELECT * FROM BASE;
							SELECT 
							       --B.MSRM_DATE, 			
							       B.MSRM_DAY
							     , TRUNC(B.AG,2)                         AS X
							     , TRUNC(B.TOT_AVG,2)                    AS X_CL
							     , TRUNC(B.TOT_AVG + (B.A2 * B.R_CL), 2) AS X_UCL
							     , TRUNC(B.TOT_AVG - B.R_CL,2)           AS X_LCL
							FROM			
							(			
							    SELECT 
							           --A.MSRM_DATE
							           A.MSRM_DAY
							         , A.MN       AS "MN"
							         , A.MX       AS "MX", A.AG AS "AG"
							         , A.RNGE     AS "RNGE"
							         , D.MSRM_ACC AS "MSRM_ACC"
							         , D.A2 AS "A2", AVG(A.RNGE) AS "R_BAR"
							         , STDDEV(A.AG)   AS "STDEV"
							         , SUM(B.TOT_AVG) AS "TOT_AVG"
							         , SUM(C.R_CL)    AS "R_CL"			
							      FROM (                        			
							            SELECT  
							                    --MSRM_DATE
							                    MSRM_DAY
							                  , MIN(RST_VAL) AS MN
							                  , MAX(RST_VAL) AS MX
							                  , AVG(RST_VAL) AS AG
							                  , MAX(RST_VAL) - MIN(RST_VAL) AS RNGE 			
							              FROM BASE			
							             GROUP BY MSRM_DAY
							             --GROUP BY MSRM_DATE
							           ) A
							         , ( SELECT AVG(RST_VAL) TOT_AVG FROM BASE ) B
							         , ( SELECT AVG(RNGE) AS "R_CL"			
							              FROM ( SELECT MSRM_DAY, MAX(RST_VAL) - MIN(RST_VAL) AS RNGE 			
							                       FROM BASE		
							                   GROUP BY MSRM_DAY ) ) C
							--         , ( SELECT AVG(RNGE) AS "R_CL"			
							--              FROM ( SELECT MSRM_DATE, MAX(RST_VAL) - MIN(RST_VAL) AS RNGE 			
							--                       FROM BASE		
							--                   GROUP BY MSRM_DATE ) ) C
							         , ( SELECT MSRM_ACC AS "MSRM_ACC"
							                  ,	(SELECT NVL(A2,0) FROM TB_MAS032 WHERE SUBGRP_SIZE = MSRM_ACC) AS "A2"			
							              FROM TB_MAS014 JOIN PRM PRM ON 1=1	
							             WHERE INSP_ITEM_GRP_CD = PRM.INSP_ITM_GRP_CD
							               AND INSP_ITEM_CD     = PRM.INSP_ITM_CD
							          ) D			
							  GROUP BY MSRM_DAY, MN, MX, AG, RNGE, MSRM_ACC, A2			
							--  GROUP BY MSRM_DATE, MN, MX, AG, RNGE, MSRM_ACC, A2			
							) B ORDER BY MSRM_DAY ';


		 V_DEBUG := 'Y';

        IF (V_DEBUG = 'Y') THEN
            INSERT INTO PROC_LOG(SQL_STR) VALUES (V_SQL);
        END IF;


    	OPEN P_RS_LIST FOR V_SQL;












	ELSIF P_TYPE = 'CHRT2' THEN   --하단차트


      V_SQL :=  ' WITH PRM AS (
						SELECT ';


        IF  V_INSP_ITEM_GRP_CD IS NOT NULL OR TRIM(V_INSP_ITEM_GRP_CD) != '' THEN	-- 검사항목그룹코드
            V_SQL := V_SQL || '''' || V_INSP_ITEM_GRP_CD || ''' INSP_ITM_GRP_CD ';       
        END IF;

        IF  V_INSP_ITEM_CD IS NOT NULL OR TRIM(V_INSP_ITEM_CD) != '' THEN	 		-- 검사항목코드
            V_SQL := V_SQL || ', ''' || V_INSP_ITEM_CD || ''' INSP_ITM_CD ';
        END IF;


        V_SQL :=  V_SQL || '	  FROM DUAL
							)
							--SELECT * FROM PRM;
							, BASE AS (
							   SELECT TO_CHAR(MSRM_DATE, ''YYYY/MM/DD'') MSRM_DAY
							        , NVL(A.RST_VAL, 0) RST_VAL
							--        , A.*
							     --FROM TB_QLT021 A  --테스트용
							     FROM TB_QLT022 A  --실적용용
							     JOIN PRM PRM ON 1=1
							    WHERE 1=1
							      AND INSP_ITEM_GRP_CD = PRM.INSP_ITM_GRP_CD ';      


        IF  V_MATNR IS NOT NULL OR TRIM(V_MATNR) != '' THEN	   -- 자재코드
            V_SQL := V_SQL || ' AND MATNR = ''' || V_MATNR || '''';        
        END IF;

        IF  V_WERKS IS NOT NULL OR TRIM(V_WERKS) != '' THEN	   -- 플랜트
            V_SQL := V_SQL || ' AND WERKS = ''' || V_WERKS || '''';        
        END IF;


        IF  V_MSRM_DATE_ST IS NOT NULL OR TRIM(V_MSRM_DATE_ST) != '' THEN	-- 측정일자(시작)
            V_SQL := V_SQL || ' AND MSRM_DATE >= TO_DATE(''' || V_MSRM_DATE_ST || ''')';        
        END IF;

        IF  V_MSRM_DATE_ED IS NOT NULL OR TRIM(V_MSRM_DATE_ED) != '' THEN	-- 측정일자(끝)
            V_SQL := V_SQL || ' AND MSRM_DATE < TO_DATE(''' || V_MSRM_DATE_ED || ''') + 1';        
        END IF;


       V_SQL :=  V_SQL || '      AND INSP_ITEM_CD = PRM.INSP_ITM_CD
							)
							--SELECT * FROM BASE;
							SELECT 
							       --A.MSRM_DATE         AS "MSRM_DATE", 			
							       A.MSRM_DAY          AS "MSRM_DAY", 			
							       A.MN                AS "MN", 			
							       A.MX                AS "MX", 			
							       A.RNGE              AS "R", 			
							       TRUNC(A.AG,2)                 AS "AG",   			
							       TRUNC(B.AVG_RNGE,2)           AS R_CL,  --"R-CL", 			
							       TRUNC(B.AVG_RNGE  * C.D4, 2)  AS R_UCL, --"R-UCL", 			
							       B.AVG_RNGE  * 0               AS R_LCL --"R-LCL"			
							  FROM ( 
							         SELECT 
							                --MSRM_DATE
							                MSRM_DAY
							              , MIN(RST_VAL) AS MN
							              , MAX(RST_VAL) AS MX
							              , MAX(RST_VAL) - MIN(RST_VAL) AS RNGE
							              , AVG(RST_VAL) AS AG 			
							           FROM BASE		
							          GROUP BY MSRM_DAY
							          --GROUP BY MSRM_DATE
							       ) A
							     , ( SELECT AVG(RNGE) AS "AVG_RNGE"			
							           FROM ( SELECT MSRM_DAY
							                       , MAX(RST_VAL) - MIN(RST_VAL) AS RNGE 			
							                    FROM BASE		
							                GROUP BY MSRM_DAY )
							       ) B
							--     , ( SELECT AVG(RNGE) AS "AVG_RNGE"			
							--           FROM ( SELECT MSRM_DATE
							--                       , MAX(RST_VAL) - MIN(RST_VAL) AS RNGE 			
							--                    FROM BASE		
							--                GROUP BY MSRM_DATE )
							--       ) B
							     , ( SELECT MSRM_ACC AS "MSRM_ACC",			
							               (SELECT NVL(D4,0) FROM TB_MAS032 WHERE SUBGRP_SIZE = MSRM_ACC) AS "D4"			
							          FROM TB_MAS014 JOIN PRM PRM ON 1=1
							         WHERE INSP_ITEM_GRP_CD = PRM.INSP_ITM_GRP_CD	
							           AND INSP_ITEM_CD = PRM.INSP_ITM_CD ) C ';


		 V_DEBUG := 'Y';

        IF (V_DEBUG = 'Y') THEN
            INSERT INTO PROC_LOG(SQL_STR) VALUES (V_SQL);
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
        RAISE;
END;

/
