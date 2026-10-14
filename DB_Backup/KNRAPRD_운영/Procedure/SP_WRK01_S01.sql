--------------------------------------------------------
--  DDL for Procedure SP_WRK01_S01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_WRK01_S01" (
	P_TYPE         IN    varchar2, -- LIST, SUB_LIST-A, SUB_LIST-B
	P_JSON_STR     IN    CLOB,
	P_SUCCESS      OUT    varchar2,
	P_RS_LIST      OUT    SYS_REFCURSOR 
)
/*==============================================================================
 * PROGRAM ID    : SP_WRK01_S01{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 비가동 이력조회 {호출 프로그램 명 기술}
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 비가동 현황 {프로그램에 대한 상세한 내용 기술}
 *                 
 * AUTHOR NAME   : 박성철{최초 작성자 명 기술}
 * CREATE DATE   : 2022/05/25 {최초 작성일자 기술}
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
 *        - [TB_MAS012] : (R) 설비마스터
 *        - [TB_WRK003] : (R) 비가동이력
 *        - [TB_MAS020] : (R) 비가동 항목                                     
 *        - [USRMA]     : (R) 사용자                                    
 *=============================================================================*/

AS

    V_PRG_NM          VARCHAR2(100)  := 'SP_WRK01_S01';     -- PROCEDURE NAME


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
    V_WERKS			TB_WRK003.WERKS%TYPE;			    -- 플랜트코드



    P_CHRT_TYPE      	VARCHAR2(200);		     --차트타입

    V_PROC_CD         	TB_MAS024.PROC_CD%TYPE; 	--공정코드
    V_ABN_CD         	TB_WRK003.ABN_CD%TYPE; 		--비가동 코드



BEGIN
    OPEN P_RS_LIST FOR 

    SELECT NULL FROM DUAL WHERE ROWNUM = 0;

    V_DEBUG := 'N';
    V_RUN_SQL := 'Y';

    V_JSON := JSON_OBJECT_T.parse(P_JSON_STR);

    V_SESS_USER_ID       :=      V_JSON.get_string('SES_USER_ID');
    V_PLT_CD             :=      V_JSON.get_string('SES_PLNTKY');

    /* 조건값 할당 */
    V_RANGE_SQL         :=      V_JSON.get_string('RANGE_SQL');
    V_WERKS				:= 		V_JSON.get_string('WERKS');		        -- 플랜트코드


    P_CHRT_TYPE         := V_JSON.get_string('P_CHRT_TYPE');  --차트타입


    IF P_TYPE = 'LIST' THEN /*상단 조회 리스트*/
        V_SQL :=  ' SELECT WRK003.WERKS         AS PLANT         --플랜트코드
					     , WRK003.ABN_DT        AS ABN_DT        --비가동일자
					     , MAS012.PROC_CD       AS PROC_CD       --공정명코드(공정코드)
						 , MAS013.PROC_NM       AS PROC_NM       --공정명
					     , MAS012.MACH_NM       AS MACH_NM       --설비명
						 , (SELECT CDESC1 FROM CMCDV WHERE CMCDVL = MAS020.RUN_STA AND CMCDKY = ''RUN_STA'') AS RUN_STA --운전상태
					     , WRK003.ABN_CD        AS ABN_CD        --비가동원인코드
					     , MAS020.ABN_NM        AS ABN_NM        --비가동원인명
					     , WRK003.STR_DATE      AS START_DATE    --시작일시(생산시작일시)
					     , WRK003.END_DATE      AS END_DATE      --종료일시
					     , WRK003.ABN_TM        AS ABN_TM        --비가동시간(분)
					     , WRK003.RMK           AS RMK           --비고
					     , WRK003.REGDATE       AS REGDATE       --등록일자
					     , (SELECT NMLAST FROM USRMA WHERE USERID = WRK003.REGID)       AS REGNM         --등록자
					     , WRK003.UPDDATE       AS UPDDATE       --수정일자
					     , (SELECT NMLAST FROM USRMA WHERE USERID = WRK003.UPDID)      AS UPDNM         --수정자
					  FROM TB_WRK003 WRK003       --비가동이력(비가동 실적)
					  LEFT JOIN TB_MAS012 MAS012  --설비코드
					    ON MAS012.MACH_CD = WRK003.MACH_CD
					  LEFT JOIN TB_MAS020 MAS020  --비가동 항목
					    ON MAS020.ABN_CD = WRK003.ABN_CD
					   AND MAS020.WERKS = WRK003.WERKS
					 LEFT JOIN TB_MAS013 MAS013 ON (MAS013.WERKS = WRK003.WERKS AND MAS013.PROC_CD = MAS012.PROC_CD)
					 WHERE 1=1 
                       AND NVL(WRK003.CNL_YN,''N'') != ''Y'' 
                       AND WRK003.IN_OUT IN (''I'',''N'')
                       ';


        IF  V_WERKS IS NOT NULL OR TRIM(V_WERKS) != '' THEN			    -- 플랜트코드
            V_SQL := V_SQL || ' AND WRK003.WERKS = ''' || V_WERKS || '''';        
        END IF;

        IF V_RANGE_SQL IS NOT NULL OR TRIM(V_RANGE_SQL) != '' THEN
            V_SQL := V_SQL || V_RANGE_SQL;
        END IF;
        --V_SQL := V_SQL || ' ORDER BY WRK003.STR_DATE';


		IF P_CHRT_TYPE = 'loadChrt1Bar' THEN  --공정별 비가동 현황

			V_SQL := ' WITH BASE AS ( ' || V_SQL ||  ' ) ';
			V_SQL := V_SQL || ' SELECT PROC_CD
								     , PROC_NM
								     , SUM(NVL(ABN_TM, 0) ) ABN_TM_SUM
								  FROM BASE
								 GROUP BY PROC_CD, PROC_NM
								 ORDER BY PROC_NM ';


		ELSIF P_CHRT_TYPE = 'loadChrt2Pie' THEN  --항목별 비가동 비율

			V_SQL := ' WITH BASE AS ( ' || V_SQL ||  ' ) ';
			V_SQL := V_SQL || ' , BASE_SM AS (
									SELECT ABN_CD
									     , ABN_NM
									     , SUM(NVL(ABN_TM, 0) ) ABN_TM_SUM
									  FROM BASE
									 WHERE 1=1 ';

			V_PROC_CD			:= V_JSON.get_string('CHRT_PRM'); 	--공정코드(차트파람)
			V_SQL := V_SQL ||  '	   AND PROC_CD = ''' || V_PROC_CD || ''' ';

			V_SQL := V_SQL ||   '	   AND ABN_NM IS NOT NULL
									 GROUP BY ABN_CD, ABN_NM
								)
								SELECT ABN_CD, ABN_NM
									 , CASE WHEN TOT.ABN_TM = 0 THEN 0
								            ELSE TRUNC(BSM.ABN_TM_SUM * 100 / TOT.ABN_TM, 2) END ABN_TM_SUM
								  FROM BASE_SM BSM
								  JOIN (SELECT SUM(NVL(ABN_TM_SUM, 0)) ABN_TM FROM BASE_SM) TOT ON 1=1
								 ORDER BY ABN_NM';		


		ELSIF P_CHRT_TYPE = 'loadChrt3Line' THEN  --일자별 비가동 발생 추이

			V_SQL := ' WITH BASE AS ( ' || V_SQL ||  ' ) ';		
			V_SQL := V_SQL || ' SELECT TO_CHAR(TO_DATE(ABN_DT), ''MM/DD/YYYY'') ABN_DT
								     , SUM(NVL(ABN_TM, 0) ) ABN_TM_SUM
								  FROM BASE
								 WHERE 1=1 ';

			V_PROC_CD			:= V_JSON.get_string('CHRT_PRM'); 	  --공정코드(차트파람)
			V_SQL := V_SQL || '   AND PROC_CD = ''' || V_PROC_CD || ''' ';

			v_ABN_CD          	:= V_JSON.get_string('CHRT_PRM2');    --비가동코드(차트파람)
			V_SQL := V_SQL || '   AND ABN_CD = ''' || v_ABN_CD || ''' ';

			V_SQL := V_SQL || '   AND LENGTH(ABN_DT) = 8
							    GROUP BY ABN_DT
							    ORDER BY ABN_DT ';       


        ELSE

        	V_SQL := V_SQL || ' ORDER BY WRK003.WERKS, WRK003.ABN_DT';

        END IF;





        V_DEBUG := 'Y';

        IF (V_DEBUG = 'Y') THEN
            INSERT INTO PROC_LOG(SQL_STR) VALUES (V_SQL);
        END IF;

		OPEN P_RS_LIST FOR V_SQL;


--    ELSIF P_TYPE = 'SAVE' THEN
--    	RETURN;


    END IF;


    P_SUCCESS := 'Y';


--    EXCEPTION
--    WHEN E_EXCEPTION_USER THEN
--
--        -- 에러 내역 SET
--	    P_SUCCESS           := 'N';
--        E_SQL_ERR_CD        := SQLCODE;
--        E_SQL_ERR_MSG       := SUBSTRB(SQLERRM,1,300);
--
--        ROLLBACK;
--        SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
--
--    WHEN OTHERS THEN
--	    P_SUCCESS           := 'N';
--        E_SQL_ERR_CD        := SQLCODE;
--        E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';
--
--        ROLLBACK;
--        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
END;

/
