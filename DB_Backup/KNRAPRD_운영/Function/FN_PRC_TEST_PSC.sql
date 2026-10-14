--------------------------------------------------------
--  DDL for Function FN_PRC_TEST_PSC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "KNRAMES"."FN_PRC_TEST_PSC" 
(
	P_TYPE           IN    varchar2, -- LIST, SUB_LIST-A, SUB_LIST-B
	P_JSON_STR       IN    CLOB
--    P_SUCCESS       OUT    varchar2,
--	P_RS_LIST       OUT    SYS_REFCURSOR 
)
RETURN VARCHAR
AS
--IS
    
--    P_RS_LIST SYS_REFCURSOR;

    V_PRG_NM          VARCHAR2(100)  := 'SP_WRK10_S01';     -- PROCEDURE NAME


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
    V_SQL            VARCHAR2(4000);
    V_RUN_SQL        varchar2(1);
    V_RANGE_SQL      varchar2(4000);
    V_DEBUG          varchar2(1);

    -- 세션값 처리용 변수선언 영역
    V_PLT_CD         varchar2(2);
    V_SESS_USER_ID   varchar2(20);

    -- 조건절 처리용 변수선언 영역
    V_WERKS					TB_WRK016.WERKS%TYPE;			    -- 플랜트코드
    V_PROC_CD				TB_MAS013.PROC_CD%TYPE;			    -- 플랜트코드
--        V_MATNR					TB_MAS001.MATNR%TYPE;			    -- 자재코드
--		V_WERKS					TB_MAS001.WERKS%TYPE;			    -- 플랜트코드
--		V_MATNR_NM				TB_MAS001.MATNR_NM%TYPE;		    -- 품명
--        V_MATNR_DIV             TB_MAS001.MATNR_DIV%TYPE;           -- 자재유형
--        V_MATNR_GRP_CD			TB_MAS001.MATNR_GRP_CD%TYPE;	    -- 자재그룹
--        V_PROD_GRP_CD           TB_MAS001.PROD_GRP_CD%TYPE;         -- 제품군
--        V_BUSICD                TB_MAS001.BUSICD%TYPE;              -- 사업부

    -- 리스트(그리드)의 값을 할당하기 위한 변수선언 영역

BEGIN
--    OPEN P_RS_LIST FOR 
--   
--    SELECT NULL FROM DUAL WHERE ROWNUM = 0;

    V_DEBUG := 'N';
    V_RUN_SQL := 'Y';

    V_JSON := JSON_OBJECT_T.parse(P_JSON_STR);

    V_SESS_USER_ID       :=      V_JSON.get_string('SES_USER_ID');
    V_PLT_CD             :=      V_JSON.get_string('SES_PLNTKY');

    /* 조건값 할당 */
    V_RANGE_SQL         :=      V_JSON.get_string('RANGE_SQL');
    V_WERKS				:= 		V_JSON.get_string('WERKS');		        -- 플랜트
    V_PROC_CD			:= 		V_JSON.get_string('PROC_CD');		    -- 공정
--    V_RANGE_SQL         :=      V_JSON.get_string('RANGE_SQL');
--    V_WERKS				:= 		V_JSON.get_string('WERKS');		        -- 플랜트
--    V_MATNR				:= 		V_JSON.get_string('MATNR');		        -- 자재코드
--    V_MATNR_NM			:= 		V_JSON.get_string('MATNR_NM');		    -- 자재명
--    V_MATNR_DIV         :=      V_JSON.get_string('MATNR_DIV');         -- 자재유형
--    V_MATNR_GRP_CD      := 		V_JSON.get_string('MATNR_GRP_CD');      -- 자재그룹 
--    V_PROD_GRP_CD       :=      V_JSON.get_string('PROD_GRP_CD');       -- 제품군
--    V_BUSICD            :=      V_JSON.get_string('BUSICD');            -- 사업부

--    IF P_TYPE = 'LIST' THEN /*상단 조회 리스트*/
--        V_SQL :=  ' SELECT WRK016.WERKS       AS PLANT        --플랜트     
--                         , WRK016.PRFM_DT     AS PRFM_DT      --실적일자    
--                         , WRK016.MACH_CD     AS MACH_CD      --설비코드    
--                         , MAS012.MACH_NM     AS MACH_NM      --설비명     
--                         , WRK016.WRK_SHIFT   AS WRK_SHIFT    --작업조     
--                         , WRK016.WRK_CLASS   AS WRK_CLSS_NM  --작업반     
--                         , WRK016.IN_MATNR    AS IN_MATNR     --투입자재코드  
--                         , MAS001.MATNR_NM    AS MATNR_NM     --자재명     
--                         , WRK016.WRK_ORDR_NO AS WRK_ORDR_NO  --작업지시번호  
--                         , WRK016.LOT_NO      AS LOT_NO       --LOT번호   
--                         , WRK016.UNIT        AS UNIT         --단위      
--                         , WRK016.TOT_WGT     AS TOT_WGT      --투입중량    
--                         , WRK016.PRFM_WGT    AS PRFM_WGT     --완제품생산중량 
--                    	 , WRK016.DISPO_WGT   AS DISPO_WGT    --폐품중량    
--                      FROM TB_WRK016 WRK016       --폐품 등록정보               
--                     LEFT JOIN TB_MAS012 MAS012   --설비마스터
--                       ON MAS012.MACH_CD = WRK016.MACH_CD         
--                     LEFT JOIN TB_MAS001 MAS001   --자재마스터      
--                       ON MAS001.MATNR = WRK016.IN_MATNR          
--                    WHERE 1=1';                                  
----                      AND WRK016.WERKS = 'P200'     --화장지 플랜트     
----                      AND EXISTS (                                
----   	                	SELECT 1 FROM TB_MAS013  --공정 마스터 정보   
----   	                	WHERE PROC_CD = 'AB'                   
----   	                	  AND WERKS = WRK016.WERKS             
----                      )
----                    ;
--                   
----        IF V_RANGE_SQL IS NOT NULL OR TRIM(V_RANGE_SQL) != '' THEN
----            V_SQL := V_SQL || V_RANGE_SQL;
----        END IF;
----        
----        IF  V_WERKS IS NOT NULL OR TRIM(V_WERKS) != '' THEN			    -- 플랜트
----            V_SQL := V_SQL || ' AND WRK016.WERKS = ''' || V_WERKS || '''';        
----        END IF;
----       
------        IF  V_PROC_CD IS NOT NULL OR TRIM(V_PROC_CD) != '' THEN			-- 공정
------            V_SQL := V_SQL || '   AND EXISTS (                                
------									  	  SELECT 1 FROM TB_MAS013  --공정 마스터 정보   
------   	                					  WHERE PROC_CD =  ''' || V_PROC_CD || '''' || '
------                                            AND WERKS = WRK016.WERKS) ';        
------        END IF;
--        
--        V_SQL := V_SQL || ' ORDER BY WRK016.WERKS, WRK016.PRFM_DT';
--        
--
--        --V_DEBUG := 'Y';
--
--        IF (V_DEBUG = 'Y') THEN
--            INSERT INTO PROC_LOG(SQL_STR) VALUES (V_SQL);
--        END IF;
--
----		OPEN P_RS_LIST FOR V_SQL;
--        
--
--    ELSIF P_TYPE = 'SAVE' THEN
--    
--        RETURN V_SQL;
--          
--    END IF;

--    P_SUCCESS := 'Y';

    RETURN V_SQL;

--    EXCEPTION
--    WHEN E_EXCEPTION_USER THEN
--
--        -- 에러 내역 SET
----	    P_SUCCESS           := 'N';
--        E_SQL_ERR_CD        := SQLCODE;
--        E_SQL_ERR_MSG       := SUBSTRB(SQLERRM,1,300);
--
--        ROLLBACK;
--        SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
--
--    WHEN OTHERS THEN
----	    P_SUCCESS           := 'N';
--        E_SQL_ERR_CD        := SQLCODE;
--        E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';
--
--        ROLLBACK;
--        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
END;


/
