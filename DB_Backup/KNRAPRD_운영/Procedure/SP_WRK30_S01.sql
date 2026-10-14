--------------------------------------------------------
--  DDL for Procedure SP_WRK30_S01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_WRK30_S01" (
	P_TYPE           IN    varchar2, -- LIST, SAVE
	P_JSON_STR       IN    CLOB,
	P_SUCCESS       OUT    varchar2,
	P_RS_LIST       OUT    SYS_REFCURSOR 
)
/*==============================================================================
 * PROGRAM ID    : WRK30
 * PROGRAM NAME  : 수재단, 슬리터 작업현황 조회
 * VERSION       : 1.0.0
 * DESCRIPTION   : 수재단, 슬리터 작업현황 조회
 *                 
 * AUTHOR NAME   : 강현주
 * CREATE DATE   : 2022/07/18
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}	<생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}		<생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}			<생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}	<생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/07/18    1.0.0   강현주         Initial Version 
 *==============================================================================
 *  관련 테이블
 *        - [V_TRCKING] 	: ( R  ) 트랙킹 뷰(가상 테이블) 
 *        - [TB_SCH016] 	: ( R  ) 밀롤/슬리터작업지시 테이블
 *        - [TB_SCH017] 	: ( R  ) 재단작업지시 테이블 
 *        - [TB_WRK002] 	: ( R  ) 생산실적(PS) 테이블
 *        - [TB_MAS012] 	: ( R  ) 설비 마스터 테이블

 *=============================================================================*/


AS
	V_PRG_NM          	VARCHAR2(100) 	:= 'SP_WRK30_S01';     -- PROCEDURE NAME

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
		

	V_PROC_CD        	  TB_MAS012.PROC_CD%TYPE;			                              --공정	
	V_MACH_CD        	  TB_WRK002.MACH_CD%TYPE;			                              --설비코드(호기)
	V_PCODE	 		        TB_SCH018.PCODE%TYPE;			                                --지종
	V_BS_WGT	 		      TB_SCH018.BS_WGT%TYPE;			                              --평량
	V_WLEN	 		        TB_SCH018.WLEN%TYPE;			                                --가로길이
	V_VLEN	 		        TB_SCH018.VLEN%TYPE;			                                --세로길이			

    V_INOUT_GU             VARCHAR2(2); 
    
    V_CNL_YN                TB_WRK002.CNL_YN%TYPE;
    
    

BEGIN
	OPEN P_RS_LIST FOR 

	SELECT NULL FROM DUAL WHERE ROWNUM = 0;

	V_JSON 				  := JSON_OBJECT_T.parse(P_JSON_STR);

	V_SESS_USER_ID	:= V_JSON.get_string('SES_USER_ID');
	V_PLT_CD			  := V_JSON.get_string('SES_PLNTKY');

	V_WERKS				  := V_JSON.get_string('WERKS');			                            --플랜트코드
	
	V_RANGE_SQL     := V_JSON.get_string('RANGE_SQL');	                            --실적일자
	--V_MACH_CD			  := V_JSON.get_string('MACH_CD');	                              --설비코드(호기)
	V_PROC_CD			  := V_JSON.get_string('PROC_CD');	                              --공정코드
	V_PCODE			    := V_JSON.get_string('PCODE');		                              --지종
	V_BS_WGT			  := V_JSON.get_string('BS_WGT');		                              --평량
	V_WLEN			    := V_JSON.get_string('WLEN');		                              --가로길이
	V_VLEN			    := V_JSON.get_string('VLEN');		                                --세로길이			
    V_INOUT_GU 		    := V_JSON.get_string('INOUT_GU');   	

    V_CNL_YN            := V_JSON.get_string('CNL_YN'); 

	IF P_TYPE = 'LIST' THEN
        IF V_PROC_CD = 'SA'  THEN
                V_SQL :=' 
                      SELECT  ''''                           AS MOVE_DT                                     --공정이동일시
                             ,''''                           AS	EMPLY_NO								    --이동작업자
                             ,MWRK002.IND_BCD                AS	IND_BCD										--ST_BARCODE    
                             ,MWRK002.LOT_NO                 AS	LOT_NO								        --LOT NO 
                             ,MWRK002.MACH_CD                AS	ST_MACH_CD						            --ST투입설비
                             ,SCH016.COMP_YN                 AS	COMP_YN								        --작업상태
                             ,''''                           AS	BCD_STA								        --원BCD상태
                             ,(SELECT DECODE(LAND1,''KR'',''내수'',''수출'') FROM TB_MAS009 WHERE CUST_DIV = ''C'' AND CUST_CD = MWRK002.KUNNR) AS	INOUT_DIV		--내수/수출
                             ,SCH016.KUNNRT                  AS	KUNNRT								        --거래처
                             ,(SELECT LAND1 FROM TB_MAS009 WHERE CUST_DIV = ''C'' AND CUST_CD = SCH016.KUNNR) AS KUNNR_NM						              --국가      
                             ,SCH016.PCODE                   AS	PCODE								        --지종 
                             ,(SELECT MAS001.PCODE_NM FROM TB_MAS001 MAS001 WHERE MAS001.MATNR = SCH016.MATNR) AS	PCODE_NM								            --지종명
                             ,SCH016.BS_WGT                  AS	BS_WGT								        --평량
                             ,MWRK002.WLEN                   AS	WLEN								        --가로
                             ,MWRK002.VLEN                   AS	VLEN								        --세로
                             ,MWRK002.WIDTH                  AS	WIDTH								        --실지폭
                             ,NULL                           AS	MBRGEW								        --M/RE
							 ,MWRK002.UNIT					 AS UNIT										--단위
							 ,MWRK002.PRFM_QTY				 AS PRFM_QTY									--실적수량   
                             ,MWRK002.WGT                    AS	WGT								            --중량 
                             ,(SELECT SUM(DISPO_QTY)  FROM TB_WRK004 MWRK004
                               WHERE MWRK002.WERKS =  MWRK004.WERKS
                               AND  MWRK002.IND_BCD =  MWRK004.IND_BCD
                               )                              AS	BAD_MRE								        --폐품M/RE
                             ,(SELECT SUM(WGT)  FROM TB_WRK004 MWRK004
                               WHERE MWRK002.WERKS =  MWRK004.WERKS
                               AND  MWRK002.IND_BCD =  MWRK004.IND_BCD
                               )                              AS	BAD_WGT								        --폐품중량
                             ,MWRK002.RMK                   AS	RMK								            --비고
                             ,MWRK002.MACH_CD                AS	MACH_CD								        --실적호기
                             ,(SELECT MACH_NM FROM TB_MAS012 WHERE MACH_CD = MWRK002.MACH_CD)  AS	MACH_NM								                        --생산실적설비
                             ,MWRK002.PRFM_DT                AS	PRFM_DT								        --생산실적일시
                             ,MWRK002.PRD_NO                 AS	PRD_NO								        --생산번호
                             ,MWRK002.CORE                   AS	CORE								        --지관 
                             ,MWRK002.WIDTH                  AS	PKCNT								        --폭수
                             ,MWRK002.SCNT                   AS	SCNT								        --속당매/속수
                             ,MWRK002.PCNT                   AS	PCNT								        --팔레트당연수
                             ,MWRK002.PACKTYPE               AS	PACKTYPE								    --포장타입
                             ,SCH016.ORDER_RMK               AS	ORDER_RMK								    --지시사항
                             ,MWRK002.MATNR                  AS	MATNR								        --자재코드   
                             ,SCH016.VBELN                   AS	VBELN								        --판매오더 
                             ,NVL(MWRK002.CNL_YN, ''N'')     AS	CNL_YN								        --취소여부
                             --,DECODE(MWRK002.CNL_YN,''Y'',''취소'','''')                    CNL_YN                        --취소여부
                             ,''슬리터''                       AS	FILD31								    --구분                                                                                                                                        
                             ,MWRK002.TM                AS      TM     --생산시간(분) 221103 진승화 생산시간(분)추가
                             ,MWRK002.POSNR                AS      POSNR     --판매문서번호순번 221103 진승화 판매문서번호순번추가					         
                             ,MWRK002.SDOC_NO                AS      SDOC_NO     --SAP확정문서번호 221103 진승화 SAP확정문서번호
                             ,MWRK002.SDOC_SEQNO                AS      SDOC_SEQNO     --SAP확정문서번호순번 221103 진승화 SAP확정문서번호순번
                      FROM TB_SCH016 SCH016         --밀롤/슬리터작업지시
                          ,TB_WRK002 MWRK002        --밀롤/슬리터실적
                          ,TB_MAS012 MMAS012        --밀롤/슬리터공정 
                      WHERE 
                            SCH016.WERKS         = MWRK002.WERKS
                      AND   SCH016.WRK_ORDR_NO   = MWRK002.WRK_ORDR_NO
                      AND   SCH016.WRK_ORDR_SEQNO = MWRK002.WRK_ORDR_SEQNO
                      AND   SCH016.SLITER        = ''X''
                      --AND   SUBSTR(MWRK002.WRK_ORDR_NO,1,4)    <> ''WOEX''
                      AND   MWRK002.MACH_CD             = MMAS012.MACH_CD 
                      --AND NVL(MWRK002.CNL_YN,''N'') = ''N''   --취소 여부 y 출력시 주석 필요
                    ';
                
              IF (V_WERKS IS NOT NULL OR TRIM(V_WERKS) != '') THEN
                        V_SQL := V_SQL || ' AND SCH016.WERKS = ''' || V_WERKS || '''';            --플랜트코드				      
              END IF;				
                        
              IF (V_RANGE_SQL IS NOT NULL OR TRIM(V_RANGE_SQL) != '') THEN               --실적일자
                V_SQL := V_SQL || V_RANGE_SQL; 
              END IF;   
                  
              IF (V_PROC_CD IS NOT NULL OR TRIM(V_PROC_CD) != '') THEN                   --공정코드
                  V_SQL := V_SQL || ' AND MMAS012.PROC_CD = ''' || V_PROC_CD || '''';            				      
              END IF;
        
              IF (V_PCODE IS NOT NULL OR TRIM(V_PCODE) != '') THEN                       --지종
                  V_SQL := V_SQL || ' AND SCH016.PCODE = ''' || V_PCODE || ''''; 				      
              END IF;
              
              IF (V_BS_WGT IS NOT NULL OR TRIM(V_BS_WGT) != '') THEN                     --평량
                  V_SQL := V_SQL || ' AND SCH016.BS_WGT = ''' || V_BS_WGT || ''''; 				      
              END IF;
              
              IF (V_WLEN IS NOT NULL OR TRIM(V_WLEN) != '') THEN                         --가로길이
                  V_SQL := V_SQL || ' AND MWRK002.WLEN = ''' || V_WLEN || ''''; 				      
              END IF;
              
              IF (V_VLEN IS NOT NULL OR TRIM(V_VLEN) != '') THEN                         --세로길이
                  V_SQL := V_SQL || ' AND MWRK002.VLEN = ''' || V_VLEN || ''''; 				      
              END IF;               
        
              IF    V_INOUT_GU = 'E' THEN
                    V_SQL := V_SQL ||' AND MWRK002.WRK_ORDR_NO LIKE ''WOEX%''||''%''  ' ;  
              ELSIF V_INOUT_GU = 'N' THEN
                    V_SQL := V_SQL ||' AND MWRK002.WRK_ORDR_NO NOT LIKE ''WOEX%''||''%''  ' ;
              END IF;
        
              V_SQL := V_SQL || ' AND NVL(MWRK002.CNL_YN, ''N'') =  ''' || V_CNL_YN || '''';
        
              V_SQL := V_SQL || ' ORDER BY MWRK002.IND_BCD';
       END IF ;
        --20220927 여한진 수재단 예외생산 작업지시 조회 추가
        IF V_PROC_CD = 'CB'  THEN
                V_SQL :=' 
                      SELECT  ''''                           AS MOVE_DT                                     --공정이동일시
                             ,''''                           AS	EMPLY_NO								    --이동작업자     
                             ,MWRK002.IND_BCD                AS	IND_BCD										--BARCODE       
                             ,MWRK002.LOT_NO                 AS	LOT_NO								        --LOT NO 
                             ,MWRK002.MACH_CD                AS	ST_MACH_CD						            --ST투입설비
                             ,DECODE(SUBSTR(MWRK002.WRK_ORDR_NO,1,4), ''WOEX'', SCH019.COMP_YN, SCH017.COMP_YN)                 AS	COMP_YN								        --작업상태
                             ,''''                           AS	BCD_STA								        --원BCD상태
                             ,(SELECT DECODE(LAND1,''KR'',''내수'',''수출'') FROM TB_MAS009 WHERE CUST_DIV = ''C'' AND CUST_CD = MWRK002.KUNNR) AS	INOUT_DIV		--내수/수출
                             ,DECODE(SUBSTR(MWRK002.WRK_ORDR_NO,1,4), ''WOEX'', SCH019.KUNNRT, SCH017.KUNNRT)                  AS	KUNNRT								        --거래처
                             ,DECODE(SUBSTR(MWRK002.WRK_ORDR_NO,1,4), ''WOEX'', (SELECT LAND1 FROM TB_MAS009 WHERE CUST_DIV = ''C'' AND CUST_CD = SCH019.KUNNR)
                                                                              , (SELECT LAND1 FROM TB_MAS009 WHERE CUST_DIV = ''C'' AND CUST_CD = SCH017.KUNNR))  AS KUNNR_NM						              --국가      
                             ,DECODE(SUBSTR(MWRK002.WRK_ORDR_NO,1,4), ''WOEX'', SCH019.PCODE, SCH017.PCODE)                   AS	PCODE								        --지종 
                             ,DECODE(SUBSTR(MWRK002.WRK_ORDR_NO,1,4), ''WOEX'', (SELECT MAS001.PCODE_NM FROM TB_MAS001 MAS001 WHERE MAS001.MATNR = SCH019.MATNR)
                                                                              , (SELECT MAS001.PCODE_NM FROM TB_MAS001 MAS001 WHERE MAS001.MATNR = SCH017.MATNR))   AS	PCODE_NM		--지종명
                             ,DECODE(SUBSTR(MWRK002.WRK_ORDR_NO,1,4), ''WOEX'', SCH019.BS_WGT, SCH017.BS_WGT)                  AS	BS_WGT								        --평량
                             ,MWRK002.WLEN                   AS	WLEN								        --가로
                             ,MWRK002.VLEN                   AS	VLEN								        --세로
                             ,MWRK002.WIDTH                  AS	WIDTH								        --실지폭
                             ,NULL                           AS	MBRGEW								        --M/RE
							 ,MWRK002.UNIT					 AS UNIT										--단위
							 ,MWRK002.PRFM_QTY				 AS PRFM_QTY									--실적수량      
                             ,MWRK002.WGT                    AS	WGT								            --중량 
                             ,(SELECT SUM(DISPO_QTY)  FROM TB_WRK004 MWRK004
                               WHERE MWRK002.WERKS =  MWRK004.WERKS
                               AND  MWRK002.IND_BCD =  MWRK004.IND_BCD
                               )                              AS	BAD_MRE								        --폐품M/RE
                             ,(SELECT SUM(WGT)  FROM TB_WRK004 MWRK004
                               WHERE MWRK002.WERKS =  MWRK004.WERKS
                               AND  MWRK002.IND_BCD =  MWRK004.IND_BCD
                               )                              AS	BAD_WGT								        --폐품중량
                             ,MWRK002.RMK                   AS	RMK								            --비고
                             ,MWRK002.MACH_CD                AS	MACH_CD								        --실적호기
                             ,(SELECT MACH_NM FROM TB_MAS012 WHERE MACH_CD = MWRK002.MACH_CD)  AS	MACH_NM								                        --생산실적설비
                             ,MWRK002.PRFM_DT                AS	PRFM_DT								        --생산실적일시
                             ,MWRK002.PRD_NO                 AS	PRD_NO								        --생산번호
                             ,MWRK002.CORE                   AS	CORE								        --지관 
                             ,MWRK002.WIDTH                  AS	PKCNT								        --폭수
                             ,MWRK002.SCNT                   AS	SCNT								        --속당매/속수
                             ,MWRK002.PCNT                   AS	PCNT								        --팔레트당연수
                             ,MWRK002.PACKTYPE               AS	PACKTYPE								    --포장타입
                             ,DECODE(SUBSTR(MWRK002.WRK_ORDR_NO,1,4), ''WOEX'', SCH019.WRK_ORDR_REMARK, SCH017.ORDER_RMK)               AS	ORDER_RMK								    --지시사항
                             ,MWRK002.MATNR                  AS	MATNR								        --자재코드   
                             ,DECODE(SUBSTR(MWRK002.WRK_ORDR_NO,1,4), ''WOEX'', SCH019.VBELN, SCH017.VBELN)                   AS	VBELN								        --판매오더 
                             ,NVL(MWRK002.CNL_YN, ''N'')	 AS	CNL_YN								        --취소여부
                             --,DECODE(MWRK002.CNL_YN,''Y'',''취소'','''')                    CNL_YN                        --취소여부
                             ,DECODE(SUBSTR(MWRK002.WRK_ORDR_NO,1,4), ''WOEX'', ''수재단 예외'', ''수재단'')                       AS	FILD31							    --구분            
                             ,MWRK002.TM                AS      TM     --생산시간(분) 221103 진승화 생산시간(분)추가					               
                             ,MWRK002.POSNR                AS      POSNR     --판매문서번호순번 221103 진승화 판매문서번호순번추가					         
                             ,MWRK002.SDOC_NO                AS      SDOC_NO     --SAP확정문서번호 221103 진승화 SAP확정문서번호
                             ,MWRK002.SDOC_SEQNO                AS      SDOC_SEQNO     --SAP확정문서번호순번 221103 진승화 SAP확정문서번호순번
                      FROM TB_WRK002 MWRK002        --밀롤/슬리터실적
                          ,TB_SCH017 SCH017         --밀롤/슬리터작업지시
                          ,TB_SCH019 SCH019         --수재단 예외생산
                          ,TB_MAS012 MMAS012        --밀롤/슬리터공정
                      WHERE MWRK002.WERKS          = SCH017.WERKS(+)
                        AND MWRK002.WRK_ORDR_NO    = SCH017.WRK_ORDR_NO(+)
                        AND MWRK002.WRK_ORDR_SEQNO = SCH017.WRK_ORDR_SEQNO(+)
                        AND MWRK002.WERKS          = SCH019.WERKS(+)
                        AND MWRK002.WRK_ORDR_NO    = SCH019.WRK_ORDR_NO(+)
                        AND MWRK002.WRK_ORDR_SEQNO  = SCH019.WRK_ORDR_SEQNO(+)
                      --AND   SUBSTR(MWRK002.WRK_ORDR_NO,1,4)    <> ''WOEX''
                      AND   MWRK002.MACH_CD             = MMAS012.MACH_CD 
                      --AND NVL(MWRK002.CNL_YN,''N'') = ''N''     --취소 여부 y 출력시 주석 필요
                    ';
                
              IF (V_WERKS IS NOT NULL OR TRIM(V_WERKS) != '') THEN
                        V_SQL := V_SQL || ' AND SCH017.WERKS = ''' || V_WERKS || '''';            --플랜트코드				      
              END IF;				
                        
              IF (V_RANGE_SQL IS NOT NULL OR TRIM(V_RANGE_SQL) != '') THEN               --실적일자
                V_SQL := V_SQL || V_RANGE_SQL; 
              END IF;   
                  
              IF (V_PROC_CD IS NOT NULL OR TRIM(V_PROC_CD) != '') THEN                   --공정코드
                  V_SQL := V_SQL || ' AND MMAS012.PROC_CD = ''' || V_PROC_CD || '''';            				      
              END IF;
        
              IF (V_PCODE IS NOT NULL OR TRIM(V_PCODE) != '') THEN                       --지종
                  V_SQL := V_SQL || ' AND SCH017.PCODE = ''' || V_PCODE || ''''; 				      
              END IF;
              
              IF (V_BS_WGT IS NOT NULL OR TRIM(V_BS_WGT) != '') THEN                     --평량
                  V_SQL := V_SQL || ' AND SCH017.BS_WGT = ''' || V_BS_WGT || ''''; 				      
              END IF;
              
              IF (V_WLEN IS NOT NULL OR TRIM(V_WLEN) != '') THEN                         --가로길이
                  V_SQL := V_SQL || ' AND MWRK002.WLEN = ''' || V_WLEN || ''''; 				      
              END IF;
              
              IF (V_VLEN IS NOT NULL OR TRIM(V_VLEN) != '') THEN                         --세로길이
                  V_SQL := V_SQL || ' AND MWRK002.VLEN = ''' || V_VLEN || ''''; 				      
              END IF;               
        
              IF    V_INOUT_GU = 'E' THEN
                    V_SQL := V_SQL ||' AND MWRK002.WRK_ORDR_NO LIKE ''WOEX%''||''%''  ' ;  
              ELSIF V_INOUT_GU = 'N' THEN
                    V_SQL := V_SQL ||' AND MWRK002.WRK_ORDR_NO NOT LIKE ''WOEX%''||''%''  ' ;
              END IF;
             
              V_SQL := V_SQL || ' AND NVL(MWRK002.CNL_YN, ''N'') =  ''' || V_CNL_YN || '''';
        
              V_SQL := V_SQL || ' ORDER BY MWRK002.IND_BCD';
      END IF ;


      
     -- IF (V_DEBUG = 'Y') THEN
        INSERT INTO PROC_LOG (SQL_STR) VALUES (V_SQL);
     -- END IF;

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
--		RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
        RAISE;
END;

/
