
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_WRK23_POP01_S01" (
	P_TYPE           IN    varchar2, -- LIST, SAVE
	P_JSON_STR       IN    CLOB,
	P_SUCCESS       OUT    varchar2,
	P_RS_LIST       OUT    SYS_REFCURSOR 
)
/*==============================================================================
 * PROGRAM ID    : SP_WRK23_POP01_S01
 * PROGRAM NAME  : 바코드팝업
 * VERSION       : 1.0.0
 * DESCRIPTION   : 바코드팝업
 *                 
 * AUTHOR NAME   : 강동호
 * CREATE DATE   : 2022/06/15
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}	<생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}		<생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}			<생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}	<생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/05/22    1.0.0   강동호         Initial Version 
 *==============================================================================
 *  관련 테이블
 *        - [TB_WRK01] : ( R  ) 
 *        - [TB_WRK02] : ( R  ) 
 *=============================================================================*/

AS
	V_PRG_NM          	VARCHAR2(100) 	:= 'SP_WRK23_POP01_S01';     -- PROCEDURE NAME

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

	-- 리스트(그리드)의 값을 할당하기 위한 변수선언 영역
	V_WERKS				TB_WRK001.WERKS%TYPE;			--플랜트코드
	V_PROC_GRP_CD		TB_MAS013.PROC_GRP_CD%TYPE;		--공정그룹코드
	V_MACH_CD			TB_MAS012.MACH_CD%TYPE;			--설비코드
	V_MATNR				TB_MAS001.MATNR%TYPE;			--자재코드
	V_MATNR_NM			TB_MAS001.MATNR_NM%TYPE;		--자재명
	V_IND_BCD			TB_WRK001.IND_BCD%TYPE;			--개별바코드
    V_RANGE_SQL      	varchar2(4000);					--실적일자, 생산일자

	V_SQL				CLOB;
BEGIN
	OPEN P_RS_LIST FOR 

	SELECT NULL FROM DUAL WHERE ROWNUM = 0;

	V_JSON 				:= JSON_OBJECT_T.parse(P_JSON_STR);
	V_SESS_USER_ID		:= V_JSON.get_string('SES_USER_ID');
	V_PLT_CD			:= V_JSON.get_string('SES_PLNTKY');

	V_WERKS			    := V_JSON.get_string('WERKS'); 	   		--플랜트코드
	V_PROC_GRP_CD		:= V_JSON.get_string('PROC_GRP_CD'); 	--공정그룹코드
	V_MACH_CD			:= V_JSON.get_string('MACH_CD'); 	    --설비코드
	V_MATNR				:= V_JSON.get_string('MATNR'); 	    	--자재코드
	V_MATNR_NM			:= V_JSON.get_string('MATNR_NM'); 	    --자재명
	V_IND_BCD			:= V_JSON.get_string('IND_BCD'); 	    --개별바코드

    V_RANGE_SQL         := V_JSON.get_string('RANGE_SQL');	--실적일자

	IF P_TYPE = 'LIST' THEN

		V_SQL := 
		'	SELECT
				A.WERKS					AS WERKS		--플랜트코드
			,   A.PRFM_DT  				AS PRFM_DT 		--실적일자               				           
			,   A.MACH_CD 				AS MACH_CD		--설비코드
			,	MAS012.MACH_NM			AS MACH_NM		--설비명
			,	MAS012.PROC_CD 			AS PROC_CD		--공정코드
			,	MAS013.PROC_NM			AS PROC_NM		--공정명
			,	MAS013.PROC_GRP_CD 		AS PROC_GRP_CD	--공정그룹코드        			   			      
			,   A.MATNR					AS MATNR		--자재코드
			,	MAS001.MATNR_NM 		AS MATNR_NM		--자재명            				    
			,   A.LOT_NO				AS LOT_NO		--LOT NO            				  
			,   A.IND_BCD 				AS IND_BCD		--개별바코드                  				    		     
			,   A.PRD_DT				AS PRD_DT		--생산일자               				    
			,	A.WRK_SHIFT				AS WRK_SHIFT	--작업반
			,	A.WRK_CLASS				AS WRK_CLASS	--작업조											
			,	A.REGID					AS REGID		--작업자ID
			,	USR.NMLAST 				AS REGNM		--작업자명
			FROM
			(
				SELECT
					WRK001.WERKS
				,   WRK001.PRFM_DT                     			          
				,   WRK001.MACH_CD                   			          
				,   WRK001.MATNR               			     
				,   WRK001.LOT_NO            			 
				,   WRK001.IND_BCD                   			          
				,   WRK001.PRD_DT               				   
				,	WRK001.WRK_SHIFT									
				,	WRK001.WRK_CLASS									
				,	WRK001.REGID										
				FROM
				    TB_WRK001 WRK001
				WHERE 1=1

				UNION ALL

				SELECT
					WRK002.WERKS
				,   WRK002.PRFM_DT                     				            
				,   WRK002.MACH_CD                   				
				,   WRK002.MATNR               				     
				,   WRK002.LOT_NO            				  
				,   WRK002.IND_BCD                   				         
				,   WRK002.PRD_DT               				     
				,	WRK002.WRK_SHIFT									
				,	WRK002.WRK_CLASS									
				,	WRK002.REGID											
				FROM
				    TB_WRK002 WRK002
				WHERE 1=1
			) A
			LEFT JOIN TB_MAS001 MAS001 ON (MAS001.WERKS = A.WERKS AND MAS001.MATNR = A.MATNR)
			LEFT JOIN TB_MAS012 MAS012 ON (MAS012.MACH_CD = A.MACH_CD)
			LEFT JOIN TB_MAS013 MAS013 ON (MAS013.PROC_CD = MAS012.PROC_CD) 
			LEFT JOIN USRMA USR ON (USR.USERID = A.REGID)
			WHERE 1=1 ';	

			IF (V_WERKS IS NOT NULL OR TRIM(V_WERKS) != '') THEN
            	V_SQL := V_SQL || ' AND A.WERKS = ''' || V_WERKS || '''';					--플랜트   
        	END IF;

			IF (V_MACH_CD IS NOT NULL OR TRIM(V_MACH_CD) != '') THEN
            	V_SQL := V_SQL || ' AND A.MACH_CD LIKE ''%' || V_MACH_CD || '%''';				--설비코드   
        	END IF;

        	IF (V_PROC_GRP_CD IS NOT NULL OR TRIM(V_PROC_GRP_CD) != '') THEN
            	V_SQL := V_SQL || ' AND MAS013.PROC_GRP_CD = ''' || V_PROC_GRP_CD || '''';	--공정그룹코드   
        	END IF;

       	 	IF (V_MATNR IS NOT NULL OR TRIM(V_MATNR) != '') THEN
            	V_SQL := V_SQL || ' AND A.MATNR = ''' || V_MATNR || '''';					--자재코드   
        	END IF;

        	IF (V_MATNR_NM IS NOT NULL OR TRIM(V_MATNR_NM) != '') THEN
            	V_SQL := V_SQL || ' AND MAS001.MATNR_NM = ''' || V_MATNR_NM || '''';		--자재명
        	END IF;

        	IF (V_IND_BCD IS NOT NULL OR TRIM(V_IND_BCD) != '') THEN
            	V_SQL := V_SQL || ' AND A.IND_BCD = ''' || V_IND_BCD || '''';				--개별바코드
        	END IF;

        	IF  V_RANGE_SQL IS NOT NULL OR TRIM(V_RANGE_SQL) != '' THEN
            V_SQL := V_SQL || V_RANGE_SQL ;			                       					--실적일자, 생산일자  
            END IF;

        	V_SQL := V_SQL || ' ORDER BY A.WERKS, A.MATNR';

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
