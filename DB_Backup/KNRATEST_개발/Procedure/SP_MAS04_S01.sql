--------------------------------------------------------
--  DDL for Procedure SP_MAS04_S01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_MAS04_S01" (
	P_TYPE           IN    varchar2, -- LIST, SAVE
	P_JSON_STR       IN    CLOB,
	P_SUCCESS       OUT    varchar2,
	P_RS_LIST       OUT    SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : SP_MAS04_S01{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 직원정보관리{호출 프로그램 명 기술}
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 직원정보 관리한다.{프로그램에 대한 상세한 내용 기술}
 *                 
 * AUTHOR NAME   : 공진우{최초 작성자 명 기술}
 * CREATE DATE   : 2022/04/08 {최초 작성일자 기술}
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * yyyy/mm/dd    1.0.0   공진우         Initial Version 
 * 2022/05/09    1.0.1   김성하         공장지명, 부서명, 공정명 추가  
 *==============================================================================
 *  관련 테이블
 *       - [TB_MAS017] : (CRUD) 직원정보 정보                                
 *=============================================================================*/

AS

    V_PRG_NM          VARCHAR2(100)  := 'SP_MAS04_S01';     -- PROCEDURE NAME

    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5)           := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);


   -- V_RTN_CLOB       CLOB;
   -- V_RTN_CURSOR     SYS_REFCURSOR;
   -- V_ERROR          CLOB;


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

    -- 리스트(그리드)의 값을 할당하기 위한 변수선언 영역    
	V_EMPLY_NO				TB_MAS017.EMPLY_NO%TYPE;		--사원번호
	V_EMPLY_KR_NM			TB_MAS017.EMPLY_KR_NM%TYPE;		--사원명(한글)
	V_EMPLY_EN_NM			TB_MAS017.EMPLY_EN_NM%TYPE;		--사원명(영문)
	V_WAREKY				TB_MAS017.WAREKY%TYPE;			--소속공장(CP,UP)
	V_DEPT_CD				TB_MAS017.DEPT_CD%TYPE;			--부서코드
	V_PROC_CD				TB_MAS017.PROC_CD%TYPE;			--공정코드
	V_WRK_TEAM_NM			TB_MAS017.WRK_TEAM_NM%TYPE;		--작업팀명
	V_WRK_CLSS_NM			TB_MAS017.WRK_CLSS_NM%TYPE;		--작업반명
	V_EMAIL					TB_MAS017.EMAIL%TYPE;			--이메일
	V_WRK_SHIFT				TB_MAS017.WRK_SHIFT%TYPE;		--작업조
	V_RETR_YN				TB_MAS017.RETR_YN%TYPE;			--퇴직여부(Y/N)
	V_EMPLY_DIV				TB_MAS017.EMPLY_DIV%TYPE;		--직원구분
	V_DUT_CD				TB_MAS017.DUT_CD%TYPE;			--직책코드
	V_DUT_NM				TB_MAS017.DUT_NM%TYPE;			--직책명
	V_PST_CD				TB_MAS017.PST_CD%TYPE;			--직위코드
	V_PST_NM				TB_MAS017.PST_NM%TYPE;			--직위명
	V_SYNC_SEQNO 			TB_MAS017.SYNC_SEQNO%TYPE;		--동기화차수

BEGIN
   OPEN P_RS_LIST FOR 
   SELECT NULL FROM DUAL WHERE ROWNUM = 0;

   V_DEBUG := 'N';
   V_RUN_SQL := 'Y';

   V_JSON := JSON_OBJECT_T.parse(P_JSON_STR);

   V_SESS_USER_ID       :=       V_JSON.get_string('SES_USER_ID');
   V_PLT_CD             :=       V_JSON.get_string('SES_PLNTKY');

   /* 조건값 할당 */
   V_RANGE_SQL          :=       V_JSON.get_string('RANGE_SQL');
   V_EMPLY_NO   		:=       V_JSON.get_string('EMPLY_NO');
   V_EMPLY_KR_NM       	:=       V_JSON.get_string('EMPLY_KR_NM');
   V_DEPT_CD            :=       V_JSON.get_string('DEPT_CD');

   IF P_TYPE = 'LIST' THEN /*상단 조회 리스트*/

 	V_SQL :=  ' SELECT	  
					  M017.EMPLY_NO		    AS EMPLY_NO			-- 사원번호                   
					, M017.EMPLY_KR_NM	    AS EMPLY_KR_NM		-- 사원명(한글)                
					, M017.EMPLY_EN_NM	    AS EMPLY_EN_NM		-- 사원명(영문)                
					, M017.WAREKY			AS WAREKY			-- 소속공장(CP,UP) HIDDEN           
                    , (SELECT NAME01 FROM WAHMA WHERE WAREKY = NVL(M017.WAREKY, ''''))       AS WARE_NM        -- 공장지명
					, M017.DEPT_CD		    AS DEPT_CD			-- 부서코드 HIDDEN
                    , M018.DEPT_KR_NM       AS DEPT_NM          -- 부서명
					, M017.PROC_CD		    AS PROC_CD			-- 공정코드 (EDIT)                 
                    , M013.PROC_NM          AS PROC_NM          -- 공정명   
					, M017.WRK_TEAM_NM	    AS WRK_TEAM 		-- 작업팀명                    
					, M017.WRK_CLSS_NM	    AS WRK_CLASS		-- 작업반명               
					, M017.EMAIL			AS EMAIL			-- 이메일                     
					, M017.WRK_SHIFT		AS WRK_SHIFT		-- 작업조                     
					, M017.RETR_YN		    AS RETR_YN			-- 퇴직여부(Y/N)              
					, M017.EMPLY_DIV		AS EMPLY_DIV		-- 직원구분                   
					, M017.DUT_CD			AS DUT_CD			-- 직책코드                   
					, M017.DUT_NM			AS DUT_NM			-- 직책명                     
					, M017.PST_CD			AS PST_CD			-- 직위코드                   
					, M017.PST_NM			AS PST_NM			-- 직위명                     
					, M017.SYNC_SEQNO 	    AS SYNC_SEQNO		-- 동기화차수  
					, M017.REGDATE		    AS REGDATE			-- 등록일시
					, (SELECT NMLAST FROM USRMA WHERE USERID = NVL(M017.REGID, ''''))         AS REGNM        -- 등록자
					, M017.UPDDATE		    AS UPDDATE			-- 수정일시
					, (SELECT NMLAST FROM USRMA WHERE USERID = NVL(M017.UPDID, ''''))         AS UPDNM  	  -- 수정자
			FROM   TB_MAS017 M017,   -- 직원정보
                   TB_MAS018 M018,   -- 부서
                   TB_MAS013 M013    -- 공정
			WHERE  M017.DEPT_CD = M018.DEPT_CD(+)
              AND  M017.PROC_CD = M013.PROC_CD(+) ';

        V_SQL := V_SQL || V_RANGE_SQL;

        IF  V_EMPLY_NO IS NOT NULL OR TRIM(V_EMPLY_NO) != '' THEN			--사원번호
            V_SQL := V_SQL || 'AND M017.EMPLY_NO LIKE ''%' || V_EMPLY_NO || '%''';        
        END IF;

        IF  V_EMPLY_KR_NM IS NOT NULL OR TRIM(V_EMPLY_KR_NM) != '' THEN		-- 사원명
            V_SQL := V_SQL || 'AND M017.EMPLY_KR_NM LIKE ''%' || V_EMPLY_KR_NM || '%''';        
        END IF;

        IF  V_DEPT_CD IS NOT NULL OR TRIM(V_DEPT_CD) != '' THEN			    -- 부서
            V_SQL := V_SQL || 'AND M017.DEPT_CD = ''' || V_DEPT_CD || ''' ';        
        END IF;

		V_SQL := V_SQL || ' ORDER BY M017.EMPLY_NO';		

		OPEN P_RS_LIST FOR V_SQL;

    ELSIF P_TYPE = 'SUB_LIST' THEN  /* 하부 상세 조회 리스트*/
          RETURN;								

    ELSIF P_TYPE = 'SAVE' THEN

    	V_ARR_LIST        := V_JSON.get_array('list');

        FOR i IN 0..V_ARR_LIST.get_size-1 LOOP

                V_OBJ					:= TREAT (V_ARR_LIST.get (i) AS json_object_t);
                V_OBJ					:= TREAT (V_OBJ.get ('map') AS json_object_t);

				V_EMPLY_NO				:= V_OBJ.get_string('EMPLY_NO');		--사원번호       
                V_EMPLY_KR_NM			:= V_OBJ.get_string('EMPLY_KR_NM');		--사원명(한글)   
                V_EMPLY_EN_NM			:= V_OBJ.get_string('EMPLY_EN_NM');		--사원명(영문)   
                V_WAREKY				:= V_OBJ.get_string('WAREKY');			--소속공장(CP,UP)
                V_DEPT_CD				:= V_OBJ.get_string('DEPT_CD');			--부서코드       
                V_PROC_CD				:= V_OBJ.get_string('PROC_CD');			--공정코드       
                V_WRK_TEAM_NM			:= V_OBJ.get_string('WRK_TEAM');		--작업팀명       
                V_WRK_CLSS_NM			:= V_OBJ.get_string('WRK_CLASS');		--작업반명       
                V_EMAIL					:= V_OBJ.get_string('EMAIL');			--이메일         
                V_WRK_SHIFT				:= V_OBJ.get_string('WRK_SHIFT');		--작업조         
                V_RETR_YN				:= V_OBJ.get_string('RETR_YN');			--퇴직여부(Y/N)  
                V_EMPLY_DIV				:= V_OBJ.get_string('EMPLY_DIV');		--직원구분       
                V_DUT_CD				:= V_OBJ.get_string('DUT_CD');			--직책코드       
                V_DUT_NM				:= V_OBJ.get_string('DUT_NM');			--직책명         
                V_PST_CD				:= V_OBJ.get_string('PST_CD');			--직위코드       
                V_PST_NM				:= V_OBJ.get_string('PST_NM');			--직위명         
                V_SYNC_SEQNO 			:= V_OBJ.get_string('SYNC_SEQNO');		--동기화차수   

                IF V_OBJ.get_string('GRowState') = 'C' THEN
 
                     INSERT INTO TB_MAS017 (
					     EMPLY_NO			--사원번호       
					   , EMPLY_KR_NM		--사원명(한글)   
					   , EMPLY_EN_NM		--사원명(영문)   
					   , WAREKY				--소속공장(CP,UP)
					   , DEPT_CD			--부서코드       
					   , PROC_CD			--공정코드       
					   , WRK_TEAM_NM		--작업팀명       
					   , WRK_CLSS_NM		--작업반명       
					   , EMAIL				--이메일         
					   , WRK_SHIFT			--작업조         
					   , RETR_YN			--퇴직여부(Y/N)  
					   , EMPLY_DIV			--직원구분       
					   , DUT_CD				--직책코드       
					   , DUT_NM				--직책명         
					   , PST_CD				--직위코드       
					   , PST_NM				--직위명         
					   , SYNC_SEQNO			--동기화차수 
					   , REGDATE			-- 등록일
					   , REGID				-- 등록자
					) VALUES (
					    V_EMPLY_NO	
					  , V_EMPLY_KR_NM	
					  , V_EMPLY_EN_NM	
					  , V_WAREKY	
					  , V_DEPT_CD	
					  , V_PROC_CD	
					  , V_WRK_TEAM_NM	
					  , V_WRK_CLSS_NM	
					  , V_EMAIL		
					  , V_WRK_SHIFT	
					  , V_RETR_YN	
					  , V_EMPLY_DIV	
					  , V_DUT_CD	
					  , V_DUT_NM	
					  , V_PST_CD	
					  , V_PST_NM	
					  , V_SYNC_SEQNO
					  , SYSDATE
					  , V_SESS_USER_ID
					); 

  
                ELSIF V_OBJ.get_string('GRowState') = 'U' THEN

                     UPDATE TB_MAS017
                        SET PROC_CD		    = V_PROC_CD	 		-- 공정코드       
                           , WRK_TEAM_NM	= V_WRK_TEAM_NM		-- 작업팀명       
                           , WRK_CLSS_NM	= V_WRK_CLSS_NM		-- 작업반명       
                           , EMAIL			= V_EMAIL			-- 이메일         	
                           , WRK_SHIFT		= V_WRK_SHIFT	 	-- 작업조         
                           , RETR_YN		= V_RETR_YN	 		-- 퇴직여부(Y/N)  
                           , SYNC_SEQNO		= V_SYNC_SEQNO      -- 동기화차수 
                           , UPDDATE		= SYSDATE			-- 수정일
                           , UPDID			= V_SESS_USER_ID	-- 수정자             
                     WHERE  EMPLY_NO 		= V_EMPLY_NO;  		-- 사원번호  
                     --사용자정보 연동
                     UPDATE USRMA
                        SET PROC_CD         = V_PROC_CD         -- 공정코드
                          , WRK_CLASS       = V_WRK_CLSS_NM     --작업반명
                      WHERE EMPLID          = V_EMPLY_NO;       --사원번호

		ELSIF V_OBJ.get_string('GRowState') = 'D' THEN

			DELETE FROM TB_MAS017 WHERE EMPLY_NO = V_EMPLY_NO;

		END IF;

    END LOOP;

    ELSIF P_TYPE = 'SUB_SAVE' THEN
          RETURN;
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
