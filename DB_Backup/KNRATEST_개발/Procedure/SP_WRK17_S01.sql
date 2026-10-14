--------------------------------------------------------
--  DDL for Procedure SP_WRK17_S01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_WRK17_S01" (
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
	V_PRG_NM          	VARCHAR2(100) 	:= 'SP_WRK17_S01';     -- PROCEDURE NAME

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
  V_DEBUG          	  varchar2(1) :='Y';

	-- 조건절 처리용 변수선언 영역	
	V_SQL				        CLOB;
		
	V_WERKS        		  TB_WRK002.WERKS%TYPE;					                            --플랜트코드	
	V_RANGE_SQL      	  varchar2(4000);						                                --실적일자
		
	V_OPT      	        varchar2(10);			                                        --조회조건(J/R,포장)
	V_IN_BARLOT      	  TB_WRK008.IND_BCD%TYPE;			                              --조회조건(개별바코드/LOT NO)
	--V_FROM_DT           VARCHAR2(8);                                              --시작일자
	--V_TO_DT             VARCHAR2(8);                                              --종료일자
	

	V_FIND_DATA         TB_WRK008.IND_BCD%TYPE;			                              --추적할 개별바코드/LOT NO	
		
    V_CNT      	        NUMBER 		:= 0;
    V_CNT_LOT_NO 	    NUMBER 		:= 0;
    V_CNT_IND_BCD 	    NUMBER 		:= 0;

BEGIN
	OPEN P_RS_LIST FOR 

	SELECT NULL FROM DUAL WHERE ROWNUM = 0;

	V_JSON 				  := JSON_OBJECT_T.parse(P_JSON_STR);

	V_SESS_USER_ID	:= V_JSON.get_string('SES_USER_ID');
	V_PLT_CD			  := V_JSON.get_string('SES_PLNTKY');

	V_WERKS				  := V_JSON.get_string('WERKS');			                            --플랜트코드		
	V_IN_BARLOT			:= V_JSON.get_string('IND_BCD');	                              --조회조건(개별바코드/LOT NO)	
		

	IF P_TYPE = 'LIST' THEN
	
	
    --BARCODE, LOT 자동판단    
        V_CNT_LOT_NO := 0 ;
        
        BEGIN  
            SELECT COUNT(LOT_NO)
              INTO V_CNT_LOT_NO
              FROM(
                    SELECT level,A.*
                    FROM TB_WRK008 A
                    CONNECT BY PRIOR A.IND_BCD_M = A.IND_BCD  
                    START WITH A.LOT_NO = V_IN_BARLOT) X
              WHERE /*X.IND_BCD_M = '*'
               AND*/ ROWNUM = 1;
               
        EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    V_CNT_LOT_NO := 0 ;
                WHEN OTHERS THEN
                    V_CNT_LOT_NO := 0 ;
        END;
        
        V_CNT_IND_BCD := 0 ;
        BEGIN  
              SELECT COUNT(IND_BCD) 
              INTO V_CNT_IND_BCD
              FROM(
                SELECT level,A.*
                FROM TB_WRK008 A
                CONNECT BY PRIOR A.IND_BCD_M = A.IND_BCD  
                START WITH A.IND_BCD = V_IN_BARLOT) X
              WHERE /*X.IND_BCD_M = '*'
              AND*/ ROWNUM = 1;        

               
        EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    V_CNT_IND_BCD := 0 ;
                WHEN OTHERS THEN
                    V_CNT_IND_BCD := 0 ;
        END;

	
        --BARCODE, LOT 자동판단    
        IF V_CNT_LOT_NO > 0 THEN
              V_OPT := 'LOT';
                 
                SELECT NVL(LOT_NO,' ') INTO V_FIND_DATA
                FROM(
                  SELECT level,A.*
                  FROM TB_WRK008 A
                  CONNECT BY PRIOR A.IND_BCD_M = A.IND_BCD  
                  START WITH A.LOT_NO = V_IN_BARLOT) X
                WHERE /*X.IND_BCD_M = '*'
                AND*/ ROWNUM = 1;   
          --    END IF;   
        ELSIF V_CNT_IND_BCD > 0  THEN
              V_OPT := 'BARCODE';     
             
                SELECT NVL(IND_BCD,' ') INTO V_FIND_DATA
                FROM(
                  SELECT level,A.*
                  FROM TB_WRK008 A
                  CONNECT BY PRIOR A.IND_BCD_M = A.IND_BCD  
                  START WITH A.IND_BCD = V_IN_BARLOT) X
                WHERE /*X.IND_BCD_M = '*'
                AND*/ ROWNUM = 1;
             -- END IF;          
        ELSE
             V_OPT := 'NONE'; 
             V_FIND_DATA := ' ';
        END IF;
	
	
		V_SQL :='             
            SELECT WRK008.LEV             AS  "LEVEL"
                  ,WRK008.IND_BCD         AS  IND_BCD
                  ,WRK008.LOT_NO          AS  LOT_NO
                  ,WRK008.IND_BCD_M       AS  IND_BCD_M
                  ,WRK008.LOT_NO_M        AS  LOT_NO_M                      
                  ,MAS013.PROC_NM         AS  PROC_NM
                  ,WRK002.STA             AS  STA
                  ,WRK002.NAUFNR          AS  NAUFNR
                  ,WRK002.ROLLCNT         AS  ROLLCNT
                  ,WRK002.PCNT            AS  PCNT
                  ,WRK002.WGT             AS  WGT
                  ,0                      AS  DISP_QTY
                  ,0                      AS  DISP_ROLLCNT
                  ,0                      AS  DISP_WGT
                  ,''''                   AS  CNFRM_NO
                  ,''''                   AS  PP_ERR
                  ,WRK008.WRK_ORDR_NO     AS  WRK_ORDR_NO
                  ,WRK008.WRK_ORDR_SEQNO  AS  WRK_ORDR_SEQNO
                  ,WRK008.MATNR           AS  MATNR
                  ,WRK008.REGID           AS  REGID
                  ,WRK008.REGDATE         AS  REGDATE       
            FROM (
                    SELECT  LEVEL             AS  LEV          
                           ,A.WERKS           AS  WERKS
                           ,A.IND_BCD         AS  IND_BCD
                           ,A.LOT_NO          AS  LOT_NO
                           ,A.IND_BCD_M       AS  IND_BCD_M
                           ,A.LOT_NO_M        AS  LOT_NO_M
                           ,A.WRK_ORDR_NO     AS  WRK_ORDR_NO
                           ,A.WRK_ORDR_SEQNO  AS  WRK_ORDR_SEQNO
                           ,A.MACH_CD         AS  MACH_CD
                           ,A.MATNR           AS  MATNR 
                           ,A.REGID           AS  REGID
                           ,A.REGDATE         AS  REGDATE        
                     FROM (
                               SELECT * FROM TB_WRK008 WRK008   ';
                               
        IF V_OPT = 'BARCODE' THEN                  
            V_SQL := V_SQL || ' START WITH IND_BCD = ''' || V_FIND_DATA || '''';  
        ELSIF V_OPT = 'LOT' THEN
            V_SQL := V_SQL || ' START WITH LOT_NO = ''' || V_FIND_DATA || ''''; 
        END IF;
                          
        V_SQL :=  V_SQL ||  '  CONNECT BY PRIOR IND_BCD_M = IND_BCD 
                            UNION
                               SELECT * FROM TB_WRK008 ';
                               
        IF  V_OPT = 'LOT' THEN
            V_SQL := V_SQL || ' START WITH LOT_NO = ''' || V_FIND_DATA || ''''; 
        ELSIF V_OPT = 'BARCODE' THEN
            V_SQL := V_SQL || ' START WITH IND_BCD_M = ''' || V_FIND_DATA || '''';      				      
        END IF;
                                
        V_SQL :=  V_SQL ||  '     CONNECT BY PRIOR IND_BCD = IND_BCD_M
                          ) A  START WITH IND_BCD_M = ''*'' CONNECT BY  PRIOR IND_BCD = IND_BCD_M) WRK008
                ,TB_WRK002 WRK002         --실적(PS)
                ,TB_MAS012 MAS012         --설비
                ,TB_MAS013 MAS013         --공정
            WHERE WRK008.WERKS    = WRK002.WERKS
            AND   WRK008.IND_BCD  = WRK002.IND_BCD
            AND   WRK008.MACH_CD  = WRK002.MACH_CD
            AND   WRK002.MACH_CD  = MAS012.MACH_CD
            AND   MAS012.PROC_CD  = MAS013.PROC_CD ';
         
          
      --V_SQL := V_SQL || ' ORDER BY TRCKING.CJOB_IND_BCD';

--      IF (V_DEBUG = 'Y') THEN
--        INSERT INTO PROC_LOG (SQL_STR) VALUES (V_SQL);
--        COMMIT;
--      END IF;

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
		RAISE;
END;

/
