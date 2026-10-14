--------------------------------------------------------
--  DDL for Procedure SP_WRK44_S01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_WRK44_S01" (
	P_TYPE           IN    varchar2, -- LIST, SAVE
	P_JSON_STR       IN    CLOB,
	P_SUCCESS       OUT    varchar2,
	P_RS_LIST       OUT    SYS_REFCURSOR 
)
/*==============================================================================
 * PROGRAM ID    : WRK44
 * PROGRAM NAME  : 포장대기창고 현황 조회
 * VERSION       : 1.0.0
 * DESCRIPTION   : 포장대기창고 현황 조회
 *                 
 * AUTHOR NAME   : 강현주
 * CREATE DATE   : 2022/07/21
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}	<생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}		<생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}			<생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}	<생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/07/21    1.0.0   강현주         Initial Version 
 *==============================================================================
 *  관련 테이블
 *        - [TB_INV001] 	: ( R  ) 공정재고 테이블 
 *        - [TB_WRK002] 	: ( R  ) 생산실적(PS) 테이블 
 *        - [TB_MAS001] 	: ( R  ) 자재마스타 테이블
 *=============================================================================*/


AS
	V_PRG_NM          	VARCHAR2(100) 	:= 'SP_WRK44_S01';     -- PROCEDURE NAME

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
		


	V_PCODE	 		        TB_MAS001.PCODE%TYPE;			                                --지종
	V_BS_WGT	 		    TB_INV001.BS_WGT%TYPE;			                              --평량
	V_WLEN	 		        TB_WRK002.WLEN%TYPE;			                                --가로길이
	V_VLEN	 		        TB_WRK002.VLEN%TYPE;			                                --세로길이
	V_IND_BCD               TB_WRK002.IND_BCD%TYPE;			                              --개별바코드



BEGIN
	OPEN P_RS_LIST FOR 

	SELECT NULL FROM DUAL WHERE ROWNUM = 0;

	V_JSON 				  := JSON_OBJECT_T.parse(P_JSON_STR);

	V_SESS_USER_ID	:= V_JSON.get_string('SES_USER_ID');
 	V_PLT_CD			  := V_JSON.get_string('SES_PLNTKY');

-- 	V_WERKS				  := V_JSON.get_string('WERKS');			                            --플랜트코드
	
-- 	V_RANGE_SQL     := V_JSON.get_string('RANGE_SQL');	                            --실적일자
	--V_MACH_CD			  := V_JSON.get_string('MACH_CD');	                              --설비코드(호기)
	--V_PROC_CD			  := V_JSON.get_string('PROC_CD');	                              --공정코드
	--V_PCODE			    := V_JSON.get_string('PCODE');		                              --지종
  V_RANGE_SQL     := V_JSON.get_string('RANGE_SQL');                              --지종	
	V_BS_WGT			  := V_JSON.get_string('BS_WGT');		                              --평량
	V_WLEN			    := V_JSON.get_string('WLEN');		                              --가로길이
	V_VLEN			    := V_JSON.get_string('VLEN');		                                --세로길이			
	V_IND_BCD		    := V_JSON.get_string('IND_BCD');		                            --개별바코드	

	IF P_TYPE = 'LIST' THEN
		V_SQL :=' 
                SELECT ''X''                                                                                  AS RKEY  
                   ,CASE WHEN K.MACH_CD = ''PCB01'' THEN K.MANR_NM END        AS PCB01  
                   ,CASE WHEN K.MACH_CD = ''PCB02'' THEN K.MANR_NM END        AS PCB02   
                   ,CASE WHEN K.MACH_CD = ''PCB03'' THEN K.MANR_NM END        AS PCB03  
                   ,CASE WHEN K.MACH_CD = ''PCB04'' THEN K.MANR_NM END        AS PCB04
                   ,CASE WHEN K.MACH_CD = ''PSA01'' THEN K.MANR_NM END        AS PSA01    
                   ,CASE WHEN K.MACH_CD = ''PZA01'' THEN K.MANR_NM END        AS PZA01
                   ,CASE WHEN K.MACH_CD = ''PPB04'' THEN K.MANR_NM END        AS PPB04
                   ,CASE WHEN K.MACH_CD = ''PPB05'' THEN K.MANR_NM END        AS PPB05 
                   ,CASE WHEN K.MACH_CD = ''PPB06'' THEN K.MANR_NM END        AS PPB06   
                   ,CASE WHEN K.MACH_CD = ''PPC01'' THEN K.MANR_NM END        AS PPC01
                   ,CASE WHEN K.MACH_CD = ''PPC02'' THEN K.MANR_NM END        AS PPC02  
                   ,CASE WHEN K.MACH_CD = ''PPC03'' THEN K.MANR_NM END        AS PPC03     
                FROM(
                    SELECT INV001.MACH_CD
                          ,MAS001.PCODE||''/''||INV001.STCK_QTY||''/''||NVL(WRK002.WLEN,0)||''*''||NVL(WRK002.VLEN,0) AS MANR_NM 
                    FROM TB_INV001 INV001
                        ,TB_MAS001 MAS001
                        ,TB_WRK002 WRK002
                    WHERE INV001.MATNR = MAS001.MATNR
                    AND INV001.WERKS  = WRK002.WERKS
                    AND INV001.MACH_CD = WRK002.MACH_CD
                    AND INV001.IND_BCD = WRK002.IND_BCD 
                     AND INV001.WERKS = ''P100''
                     AND INV001.STOR_LOC_CD = ''2000''
                     AND INV001.LOC_CD IN(''L2300'',''L2600'')
                    AND INV001.STCK_QTY > 0
                    AND INV001.MACH_CD IN(
                        ''PCB01''
                        ,''PCB02''
                        ,''PCB03''
                        ,''PCB04''
                        ,''PSA01''
                        ,''PZA01''
                        ,''PPB04''
                        ,''PPB05''
                        ,''PPB06''
                        ,''PPC01''
                        ,''PPC02''
                        ,''PPC03''        
                    )                    
			';
        
      IF (V_RANGE_SQL IS NOT NULL OR TRIM(V_RANGE_SQL) != '') THEN               --지종
        V_SQL := V_SQL || V_RANGE_SQL; 
      END IF;      			
			IF (V_BS_WGT IS NOT NULL OR TRIM(V_BS_WGT) != '') THEN
            	V_SQL := V_SQL || ' AND INV001.BS_WGT = ''' || V_BS_WGT || '''';           --평량				      
      END IF;		
			IF (V_WLEN IS NOT NULL OR TRIM(V_WLEN) != '') THEN
            	V_SQL := V_SQL || ' AND WRK002.WLEN = ''' || V_PCODE || '''';             --가로				      
      END IF;		
			IF (V_VLEN IS NOT NULL OR TRIM(V_VLEN) != '') THEN
            	V_SQL := V_SQL || ' AND WRK002.VLEN = ''' || V_VLEN || '''';              --세로				      
      END IF;		
			IF (V_IND_BCD IS NOT NULL OR TRIM(V_IND_BCD) != '') THEN
            	V_SQL := V_SQL || ' AND INV001.IND_BCD = ''' || V_IND_BCD || '''';         --개별바코드				      
      END IF;		                  				
   
      V_SQL := V_SQL || '   ) K';                    



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
		RAISE_APPLICATION_ERROR(-20000, E_SQL_ERR_MSG);
END;

/
