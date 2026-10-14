
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_WRK17_POP01_S01" (
	P_TYPE           IN    varchar2, -- LIST, SAVE
	P_JSON_STR       IN    CLOB,
	P_SUCCESS       OUT    varchar2,
	P_RS_LIST       OUT    SYS_REFCURSOR 
)
/*==============================================================================
 * PROGRAM ID    : WRK17
 * PROGRAM NAME  : 바코드 계층 조회
 * VERSION       : 1.0.0
 * DESCRIPTION   : 바코드 계층 조회
 *                 
 * AUTHOR NAME   : 강현주
 * CREATE DATE   : 2022/07/20
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}	<생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}		<생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}			<생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}	<생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/07/20    1.0.0   강현주         Initial Version 
 *==============================================================================
 *  관련 테이블
 *        - [TB_WRK008] 	: ( R  ) 트랙킹 뷰(가상 테이블) 
 *        - [TB_WRK002] 	: ( R  ) 생산실적(PS) 테이블
 *        - [TB_MAS012] 	: ( R  ) 설비 마스터 테이블
 *        - [TB_MAS013] 	: ( R  ) 공정 마스터 테이블 
 *=============================================================================*/


AS
	V_PRG_NM          	VARCHAR2(100) 	:= 'SP_WRK17_POP01_S01';     -- PROCEDURE NAME

	-- 오라클 에러 처리용 변수선언 영역
  E_EXCEPTION_USER  	EXCEPTION;
  E_SQL_ERR_CD      	NUMBER(5) 		:= 0;
  E_SQL_ERR_MSG		    VARCHAR2(4000);

  -- JSON을 위한 변수선언 영역
  V_JSON				      JSON_OBJECT_T;
  V_ARR_LIST       	  JSON_ARRAY_T;
	V_OBJ            	  JSON_OBJECT_T;

	-- 세션값 처리용 변수선언 영역
  V_SESS_USER_ID   	  varchar2(20);
  V_PLT_CD         	  varchar2(2);
  V_DEBUG          	  varchar2(1);

	-- 조건절 처리용 변수선언 영역	
	V_SQL				        CLOB;
		
		
	-- 리스트(그리드)의 값을 할당하기 위한 변수선언 영역
	V_WERKS				TB_WRK008.WERKS%TYPE;			  --플랜트코드
	V_PROC_CD		  TB_MAS013.PROC_CD%TYPE;		  --공정코드
	V_MACH_CD			TB_MAS012.MACH_CD%TYPE;			--설비코드
	V_MATNR				TB_MAS001.MATNR%TYPE;			  --자재코드
	V_MATNR_NM		TB_MAS001.MATNR_NM%TYPE;		--자재명
	V_IND_BCD			TB_WRK008.IND_BCD%TYPE;			--개별바코드
	V_LOT_NO      TB_WRK008.IND_BCD%TYPE;			--LOT NO
  V_RANGE_SQL   varchar2(4000);					    --실적일자, 생산일자	


BEGIN
	OPEN P_RS_LIST FOR 

	SELECT NULL FROM DUAL WHERE ROWNUM = 0;

	V_JSON 				  := JSON_OBJECT_T.parse(P_JSON_STR);

	V_SESS_USER_ID	:= V_JSON.get_string('SES_USER_ID');
	V_PLT_CD			  := V_JSON.get_string('SES_PLNTKY');

		
	V_WERKS			    := V_JSON.get_string('WERKS'); 	   		--플랜트코드
	V_PROC_CD		    := V_JSON.get_string('PROC_CD'); 	    --공정코드
	V_MACH_CD			  := V_JSON.get_string('MACH_CD'); 	  --설비코드
	V_MATNR				  := V_JSON.get_string('MATNR'); 	    --자재코드
	V_MATNR_NM			:= V_JSON.get_string('MATNR_NM'); 	  --자재명
	V_IND_BCD			  := V_JSON.get_string('IND_BCD'); 	    --개별바코드
	V_LOT_NO			  := V_JSON.get_string('LOT_NO'); 	    --LOT NO	        
  V_RANGE_SQL     := V_JSON.get_string('RANGE_SQL');	  --실적일자,생산일자
	

	IF P_TYPE = 'LIST' THEN			
		V_SQL :=' 
                SELECT WRK002.PRFM_DT         AS  PRFM_DT
                      ,WRK008.MACH_CD         AS  MACH_CD
                      ,MAS012.MACH_NM         AS  MACH_NM
                      ,WRK008.MATNR           AS  MATNR
                      ,MAS001.MATNR_NM        AS  MATNR_NM
                      ,WRK008.LOT_NO          AS  LOT_NO      
                      ,WRK008.IND_BCD         AS  IND_BCD
                      ,WRK002.PRD_DT          AS  PRD_DT
                      ,WRK002.WRK_CLASS       AS  WRK_CLASS
                      ,WRK002.WRK_SHIFT       AS  WRK_SHIFT
                      ,WRK002.REGID           AS  REGID 
                FROM (SELECT L.* 
                      FROM TB_WRK008 L        
                      CONNECT BY PRIOR L.IND_BCD = L.IND_BCD_M
                      START WITH L.IND_BCD_M = ''*'') WRK008         --LOT추적
                    ,TB_WRK002 WRK002         --실적(PS)
                    ,TB_MAS012 MAS012         --설비
                    ,TB_MAS013 MAS013         --공정                    
                    ,TB_MAS001 MAS001         --자재마스타
                WHERE WRK008.WERKS    = WRK002.WERKS
                AND   WRK008.IND_BCD  = WRK002.IND_BCD
                AND   WRK008.MACH_CD  = WRK002.MACH_CD
                AND   WRK002.MACH_CD  = MAS012.MACH_CD
                AND   MAS012.PROC_CD  = MAS013.PROC_CD             
                AND   WRK008.MATNR    = MAS001.MATNR                     
			';
         
          
			IF (V_WERKS IS NOT NULL OR TRIM(V_WERKS) != '') THEN
          V_SQL := V_SQL || ' AND WRK008.WERKS = ''' || V_WERKS || '''';					      --플랜트   
      END IF;
        
			IF (V_MACH_CD IS NOT NULL OR TRIM(V_MACH_CD) != '') THEN
          V_SQL := V_SQL || ' AND WRK002.MACH_CD LIKE ''%' || V_MACH_CD || '%''';				--설비코드   
      END IF;
    
      IF (V_PROC_CD IS NOT NULL OR TRIM(V_PROC_CD) != '') THEN
          V_SQL := V_SQL || ' AND MAS013.PROC_GRP_CD = ''' || V_PROC_CD || '''';	      --공정코드   
      END IF;
    
      IF (V_MATNR IS NOT NULL OR TRIM(V_MATNR) != '') THEN
          V_SQL := V_SQL || ' AND WRK008.MATNR LIKE ''' || V_MATNR || '%''';					      --자재코드   
      END IF;
    
      IF (V_MATNR_NM IS NOT NULL OR TRIM(V_MATNR_NM) != '') THEN
          V_SQL := V_SQL || ' AND MAS001.MATNR_NM LIKE ''' || V_MATNR_NM || '%''';		      --자재명
      END IF;
    
      IF (V_IND_BCD IS NOT NULL OR TRIM(V_IND_BCD) != '') THEN
          V_SQL := V_SQL || ' AND WRK008.IND_BCD LIKE ''' || V_IND_BCD || '%''';				      --개별바코드
      END IF;
      
      IF (V_LOT_NO IS NOT NULL OR TRIM(V_LOT_NO) != '') THEN
          V_SQL := V_SQL || ' AND WRK008.LOT_NO LIKE ''' || V_LOT_NO || '%''';				      --개별바코드
      END IF;      

      IF  V_RANGE_SQL IS NOT NULL OR TRIM(V_RANGE_SQL) != '' THEN
        V_SQL := V_SQL || V_RANGE_SQL ;			                       					    --실적일자, 생산일자  
      END IF;

      V_SQL := V_SQL || ' ORDER BY WRK002.PRFM_DT, WRK008.IND_BCD, WRK008.LOT_NO';

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
    E_SQL_ERR_CD        := -20000;
		E_SQL_ERR_MSG       := SUBSTRB(SQLERRM,1,300);

		ROLLBACK;
		SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);

	WHEN OTHERS THEN
		P_SUCCESS			:= 'N';
    E_SQL_ERR_CD        := E_SQL_ERR_CD;
		E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

		ROLLBACK;
		RAISE_APPLICATION_ERROR(-2000, E_SQL_ERR_MSG);
END;
/
