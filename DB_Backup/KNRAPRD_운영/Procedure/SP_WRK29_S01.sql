--------------------------------------------------------
--  DDL for Procedure SP_WRK29_S01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_WRK29_S01" (
	P_TYPE           IN    varchar2, -- LIST, SAVE
	P_JSON_STR       IN    CLOB,
	P_SUCCESS       OUT    varchar2,
	P_RS_LIST       OUT    SYS_REFCURSOR 
)
/*==============================================================================
 * PROGRAM ID    : WRK29
 * PROGRAM NAME  : 포장작업일지
 * VERSION       : 1.0.0
 * DESCRIPTION   : 포장작업일지
 *                 
 * AUTHOR NAME   : 강현주
 * CREATE DATE   : 2022/07/14
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}	<생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}		<생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}			<생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}	<생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/07/14    1.0.0   강현주         Initial Version 
 *==============================================================================
 *  관련 테이블
 *        - [V_TRCKING] 	: ( R  ) 트랙킹 뷰(가상 테이블) 
 *        - [TB_SCH018] 	: ( R  ) 포장 작업지시 테이블
 *        - [TB_WRK002] 	: ( R  ) 생산실적(PS) 테이블
 *        - [TB_MAS001] 	: ( R  ) 자재 마스터 테이블

 *=============================================================================*/


AS
	V_PRG_NM          	VARCHAR2(100) 	:= 'SP_WRK28_S01';     -- PROCEDURE NAME

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
		
	V_WERKS        		  TB_WRK002.WERKS%TYPE;					                            --플랜트코드	
	V_RANGE_SQL      	  varchar2(4000);						                                --실적일자
		
	
	V_MACHINE        	  TB_INV001.MACHINE%TYPE;			                              --설비코드(호기)
	V_PCODE	 		        TB_SCH018.PCODE%TYPE;			                                --지종
	V_BS_WGT	 		      TB_SCH018.BS_WGT%TYPE;			                              --평량
	V_WLEN	 		        TB_SCH018.WLEN%TYPE;			                                --가로길이
	V_VLEN	 		        TB_SCH018.VLEN%TYPE;			                                --세로길이			



BEGIN
	OPEN P_RS_LIST FOR 

	SELECT NULL FROM DUAL WHERE ROWNUM = 0;

	V_JSON 				  := JSON_OBJECT_T.parse(P_JSON_STR);

	V_SESS_USER_ID	:= V_JSON.get_string('SES_USER_ID');
	V_PLT_CD			  := V_JSON.get_string('SES_PLNTKY');

	V_WERKS				  := V_JSON.get_string('WERKS');			                            --플랜트코드
	
	V_RANGE_SQL     := V_JSON.get_string('RANGE_SQL');	                            --실적일자
	V_MACHINE			  := V_JSON.get_string('MACHINE');	                              --설비코드(호기)
	V_PCODE			    := V_JSON.get_string('PCODE');		                              --지종
	V_BS_WGT			  := V_JSON.get_string('BS_WGT');		                              --평량
	V_WLEN			    := V_JSON.get_string('WLEN');		                              --가로길이
	V_VLEN			    := V_JSON.get_string('VLEN');		                                --세로길이			

	IF P_TYPE = 'LIST' THEN
		V_SQL :=' 
				SELECT
						 TRCKING.PJOB_IND_BCD		AS BARCOD						--BARCODE        
						,WRK002.LOT_NO          	AS LOT_ID          				--LOT ID
						,SCH018.PCODE           	AS PCODE       						--지종
						,SCH018.BS_WGT          	AS BS_WGT      						--평량
						,SCH018.WLEN						 	AS WLEN                   --가로길이
						,SCH018.VLEN  					 	AS VLEN									  --세로길이						       
						,MAS001.MATNR_SPEC      	AS MATNR_SPEC  						--규격
						,SCH018.PACKTYPE        	AS PACKTYPE    						--포장방법
						,WRK002.PCNT            	AS PCNT        						--연수
						,SCH018.VBELN           	AS VBELN       						--판매오더
						,SCH018.ROUTE           	AS ROUTE       						--항차
						,WRK002.PRD_DT          	AS PRD_DT      						--생산일자
						,WRK002.MACHINE         	AS MACHINE     						--호기
						,TRCKING.CJOB_IND_BCD    	AS CJOB_IND_BCD			
						,TRCKING.MJOB_IND_BCD    	AS MJOB_IND_BCD
						,TRCKING.JJOB_IND_BCD    	AS JJOB_IND_BCD
						,WRK002.RMK             	AS RMK                 
				FROM V_TRCKING TRCKING
				    ,TB_SCH018 SCH018
				    ,TB_WRK002 WRK002
				    ,TB_MAS001 MAS001
				WHERE TRCKING.PJOB_WRK_ORDR_NO    = SCH018.WRK_ORDR_NO
				AND   TRCKING.PJOB_WRK_ORDR_SEQNO = SCH018.WRK_ORDR_SEQNO    
				AND   TRCKING.WERKS               = WRK002.WERKS
				AND   TRCKING.PJOB_MACH_CD        = WRK002.MACH_CD
				AND   TRCKING.PJOB_IND_BCD        = WRK002.IND_BCD
				AND   WRK002.MATNR               	= MAS001.MATNR             
			';
        
			IF (V_WERKS IS NOT NULL OR TRIM(V_WERKS) != '') THEN
            	V_SQL := V_SQL || ' AND WRK002.WERKS = ''' || V_WERKS || '''';            --플랜트코드				      
      END IF;				
				
      IF (V_RANGE_SQL IS NOT NULL OR TRIM(V_RANGE_SQL) != '') THEN               --실적일자
        V_SQL := V_SQL || V_RANGE_SQL; 
      END IF;   
          
			IF (V_MACHINE IS NOT NULL OR TRIM(V_MACHINE) != '') THEN                   --설비코드(호기)
          V_SQL := V_SQL || ' AND WRK002.MACHINE = ''' || V_MACHINE || '''';            				      
      END IF;

      IF (V_PCODE IS NOT NULL OR TRIM(V_PCODE) != '') THEN                       --지종
          V_SQL := V_SQL || ' AND SCH018.PCODE = ''' || V_PCODE || ''''; 				      
      END IF;
      
      IF (V_BS_WGT IS NOT NULL OR TRIM(V_BS_WGT) != '') THEN                     --평량
          V_SQL := V_SQL || ' AND SCH018.BS_WGT = ''' || V_BS_WGT || ''''; 				      
      END IF;
      
      IF (V_WLEN IS NOT NULL OR TRIM(V_WLEN) != '') THEN                         --가로길이
          V_SQL := V_SQL || ' AND SCH018.WLEN = ''' || V_WLEN || ''''; 				      
      END IF;
      
      IF (V_VLEN IS NOT NULL OR TRIM(V_VLEN) != '') THEN                         --세로길이
          V_SQL := V_SQL || ' AND SCH018.VLEN = ''' || V_VLEN || ''''; 				      
      END IF;               

      V_SQL := V_SQL || ' ORDER BY TRCKING.PJOB_IND_BCD';

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
