--------------------------------------------------------
--  DDL for Procedure SP_WRK18_S01
--------------------------------------------------------
set define off;

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
   	V_DEBUG          	varchar2(1) :='Y';

	-- 조건절 처리용 변수선언 영역
	V_DISPO_CD        	TB_WRK004.DISPO_CD%TYPE; 			--폐품코드
	V_RANGE_SQL      	varchar2(4000);						--실적일자
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
		V_SQL := 
		' SELECT 
				DISPO_CD 							AS DISPO_CD		--폐품코드
			,	DISPO_NM 							AS DISPO_NM		--폐품명
			,	NVL(MA_2_JUM, 0)					AS MA_2_JUM 	--2호기 점보롤
			,	NVL(MA_2_MIL, 0)					AS MA_2_MIL 	--2호기 밀롤
            ,	NVL(MA_2_JAE, 0)					AS MA_2_JAE 	--2호기 재단
			,	NVL(MA_2_PO, 0)						AS MA_2_PO 		--2호기 포장
			,	NVL(MA_2_GYE, 0)					AS MA_2_GYE 	--2호기 계
			,	NVL(MA_3_JUM, 0)					AS MA_3_JUM 	--3호기 점보롤
			,	NVL(MA_3_MIL, 0)					AS MA_3_MIL 	--3호기 밀롤
            ,	NVL(MA_3_JAE, 0)					AS MA_3_JAE 	--3호기 재단            
			,	NVL(MA_3_PO, 0)						AS MA_3_PO 		--3호기 포장
			,	NVL(MA_3_GYE, 0)					AS MA_3_GYE 	--3호기 계
			,	NVL(TOT_JUM, 0)						AS TOT_JUM 		--점보롤 합계
			,	NVL(TOT_MIL, 0)						AS TOT_MIL 		--밀롤 합계
			,	NVL(TOT_JAE, 0)						AS TOT_JAE 		--재단 합계
			,	NVL(TOT_PO, 0)						AS TOT_PO 		--포장 합계
			,	NVL(MA_2_GYE, 0) + NVL(MA_3_GYE, 0) AS TOT 			--총 합계
			FROM 
				(
				SELECT 
					A.DISPO_CD 						AS DISPO_CD		--폐품코드
				,	MAS023.DISPO_NM 				AS DISPO_NM		--폐품명
				,	A.CDESC1						AS CDESC1 		--유형코드
				,	A.DISPO_QTY						AS DISPO_QTY 	--폐품수량
				FROM
				(	
					SELECT 
						A.DISPO_CD					AS DISPO_CD		--폐품코드
					,
					(
						CASE NVL(A.CDESC1, ''0'') 
						WHEN ''0'' THEN 
							CASE
							WHEN NVL(A.CMCDVL, ''0'') != ''0'' THEN DECODE(A.CMCDVL, ''PM2'', ''2호기 계'', ''3호기 계'')
							ELSE DECODE(NVL(A.TABLE_NM, ''0''), ''SCH015'', ''점보롤 합계'', ''SCH016'', ''밀롤 합계'', ''SCH017'', ''재단 합계'', ''포장 합계'')
							END
						ELSE A.CDESC1
						END
					) 								AS CDESC1		--유형코드
					,	SUM(A.DISPO_QTY) 			AS DISPO_QTY	--폐품수량 합계
					FROM 
					(
					SELECT 
						WRK004.DISPO_CD				AS DISPO_CD		--폐품코드
					,	MAS012.MACHINE				AS CMCDVL		--유형코드
					,   CASE WHEN SUBSTR(WRK004.WRK_ORDR_NO, 3, 2) = ''JA'' THEN ''SCH015''
                              WHEN SUBSTR(WRK004.WRK_ORDR_NO, 3, 2) = ''MA'' THEN ''SCH016''
                              WHEN SUBSTR(WRK004.WRK_ORDR_NO, 3, 2) = ''CA'' THEN ''SCH017''
                              ELSE ''SCH018'' END AS TABLE_NM
					,	
						(
						CMCDV.CDESC1 ||
							CASE CASE WHEN SUBSTR(WRK004.WRK_ORDR_NO, 3, 2) = ''JA'' THEN ''SCH015''
                                      WHEN SUBSTR(WRK004.WRK_ORDR_NO, 3, 2) = ''MA'' THEN ''SCH016''
                                      WHEN SUBSTR(WRK004.WRK_ORDR_NO, 3, 2) = ''CA'' THEN ''SCH017''
                                      ELSE ''SCH018'' END 
							WHEN ''SCH015'' THEN '' 점보롤''
							WHEN ''SCH016'' THEN '' 밀롤''
							WHEN ''SCH017'' THEN '' 재단''
							ELSE '' 포장''
							END
						)							AS CDESC1		--생산호기		
					,	WRK004.WGT					AS DISPO_QTY	--폐품수량
					FROM 
						TB_WRK004 WRK004
					LEFT JOIN TB_MAS012 MAS012 ON (MAS012.MACH_CD = WRK004.MACH_CD)
					--LEFT JOIN V_WRK_ORDR WRK_ORDR ON (WRK004.WRK_ORDR_NO = WRK_ORDR.WRK_ORDR_NO AND WRK004.WRK_ORDR_SEQNO = WRK_ORDR.WRK_ORDR_SEQNO)
					LEFT JOIN CMCDV CMCDV ON (MAS012.MACHINE = CMCDV.CMCDVL AND CMCDV.CMCDKY = ''MACHINE'')
					WHERE 1=1
					--AND WRK_ORDR.TABLE_NM IN (''SCH015'',''SCH016'',''SCH017'',''SCH018'')
					--AND NVL(WRK_ORDR.SLITER_SET, ''0'') != ''X'' 
                    AND NVL(WRK004.CNL_YN,''N'')  = ''N''  
                     '
                    ;

					IF (V_DISPO_CD IS NOT NULL OR TRIM(V_DISPO_CD) != '') THEN
		           		V_SQL := V_SQL || ' AND WRK004.DISPO_CD = ''' || V_DISPO_CD || ''''; --폐품코드				      
		        	END IF;

		        	IF (V_RANGE_SQL IS NOT NULL OR TRIM(V_RANGE_SQL) != '') THEN
			        	V_SQL := V_SQL || V_RANGE_SQL; --실적일자
			        END IF;
            V_SQL := V_SQL ||
					' ) A
					GROUP BY GROUPING SETS((DISPO_CD,CMCDVL), (DISPO_CD,CDESC1), (DISPO_CD, TABLE_NM)) ' ;
					--ORDER BY TABLE_NM DESC, DISPO_CD, CDESC1

           
              V_SQL := V_SQL ||
                 '   
                  UNION ALL
					SELECT 
						A.DISPO_CD					AS DISPO_CD		--폐품코드
					,
					(
						CASE NVL(A.CDESC1, ''0'') 
						WHEN ''0'' THEN 
							CASE
							WHEN NVL(A.CMCDVL, ''0'') != ''0'' THEN DECODE(A.CMCDVL, ''PM2'', ''2호기 계'', ''3호기 계'')
							ELSE DECODE(NVL(A.TABLE_NM, ''0''), ''SCH015'', ''점보롤 합계'', ''SCH016'', ''밀롤 합계'', ''SCH017'', ''재단 합계'', ''포장 합계'')
							END
						ELSE A.CDESC1
						END
					) 								AS CDESC1		--유형코드
					,	SUM(A.DISPO_QTY) 			AS DISPO_QTY	--폐품수량 합계
					FROM 
					(
					SELECT 
						WRK022.DISPO_CD				AS DISPO_CD		--폐품코드
					,	MAS012.MACHINE				AS CMCDVL		--유형코드
					,   CASE WHEN SUBSTR(WRK022.WRK_ORDR_NO, 3, 2) = ''JA'' THEN ''SCH015''
                              WHEN SUBSTR(WRK022.WRK_ORDR_NO, 3, 2) = ''MA'' THEN ''SCH016''
                              WHEN SUBSTR(WRK022.WRK_ORDR_NO, 3, 2) = ''CA'' THEN ''SCH017''
                              ELSE ''SCH018'' END AS TABLE_NM
					,	
						(
						CMCDV.CDESC1 ||
							CASE CASE WHEN SUBSTR(WRK022.WRK_ORDR_NO, 3, 2) = ''JA'' THEN ''SCH015''
                                      WHEN SUBSTR(WRK022.WRK_ORDR_NO, 3, 2) = ''MA'' THEN ''SCH016''
                                      WHEN SUBSTR(WRK022.WRK_ORDR_NO, 3, 2) = ''CA'' THEN ''SCH017''
                                      ELSE ''SCH018'' END 
							WHEN ''SCH015'' THEN '' 점보롤''
							WHEN ''SCH016'' THEN '' 밀롤''
							WHEN ''SCH017'' THEN '' 재단''
							ELSE '' 포장''
							END
						)							AS CDESC1		--생산호기		
					,	WRK022.WGT					AS DISPO_QTY	--폐품수량
					FROM 
						TB_WRK022 WRK022
					LEFT JOIN TB_MAS012 MAS012 ON (MAS012.MACH_CD = WRK022.MACH_CD)
					--LEFT JOIN V_WRK_ORDR WRK_ORDR ON (WRK022.WRK_ORDR_NO = WRK_ORDR.WRK_ORDR_NO AND WRK022.WRK_ORDR_SEQNO = WRK_ORDR.WRK_ORDR_SEQNO)
					LEFT JOIN CMCDV CMCDV ON (MAS012.MACHINE = CMCDV.CMCDVL AND CMCDV.CMCDKY = ''MACHINE'')
					WHERE 1=1
					--AND WRK_ORDR.TABLE_NM IN (''SCH015'',''SCH016'',''SCH017'',''SCH018'')
					--AND NVL(WRK_ORDR.SLITER_SET, ''0'') != ''X''
					AND NVL(WRK022.CNL_YN,''N'')  = ''N''                      
                    AND NVL(WRK022.PRFM_GTHR_YN,''Y'')  = ''Y''  '                     
                    ;
					IF (V_DISPO_CD IS NOT NULL OR TRIM(V_DISPO_CD) != '') THEN
		           		V_SQL := V_SQL || ' AND WRK022.DISPO_CD = ''' || V_DISPO_CD || ''''; --폐품코드				      
		        	END IF;

		        	IF (V_RANGE_SQL IS NOT NULL OR TRIM(V_RANGE_SQL) != '') THEN
			        	V_SQL := V_SQL || V_RANGE_SQL; --실적일자
			        END IF;

		        	V_SQL := V_SQL || '
					) A
					GROUP BY GROUPING SETS((DISPO_CD,CMCDVL), (DISPO_CD,CDESC1), (DISPO_CD, TABLE_NM))
					--ORDER BY TABLE_NM DESC, DISPO_CD, CDESC1
				) A
				LEFT JOIN TB_MAS023 MAS023 ON (MAS023.DISPO_CD = A.DISPO_CD AND MAS023.WERKS = ''P100'')
			)

			PIVOT (
				SUM(DISPO_QTY)
				FOR CDESC1 IN (
					''2호기 점보롤'' 		AS MA_2_JUM
				, 	''2호기 밀롤'' 		AS MA_2_MIL
				, 	''2호기 재단'' 		AS MA_2_JAE
				, 	''2호기 포장'' 		AS MA_2_PO
				, 	''2호기 계'' 			AS MA_2_GYE
				,	''3호기 점보롤'' 		AS MA_3_JUM
				, 	''3호기 밀롤'' 		AS MA_3_MIL
				, 	''3호기 재단'' 		AS MA_3_JAE
				,	''3호기 포장'' 		AS MA_3_PO
				, 	''3호기 계'' 			AS MA_3_GYE
				,	''점보롤 합계'' 		AS TOT_JUM
				, 	''밀롤 합계'' 			AS TOT_MIL
				, 	''재단 합계'' 			AS TOT_JAE
				, 	''포장 합계'' 			AS TOT_PO
				)
			)
			ORDER BY DISPO_CD ';	

        IF (V_DEBUG = 'Y') THEN
        	INSERT INTO PROC_LOG (SQL_STR) VALUES (V_SQL);
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
