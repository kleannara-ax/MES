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
 *        - [TB_WRK002] 	: ( R  ) 생산실적(PS) 테이블
 *        - [TB_MAS012] 	: ( R  ) 설비 마스터 테이블
 * 		  - [V_WRK_ORDR]	: (.R..) 작업지시 뷰
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

	V_SESS_USER_ID		:= V_JSON.get_string('SES_USER_ID');
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
        V_SQL :=' 
              SELECT  WRK002.IND_BCD                AS	IND_BCD										--ST_BARCODE    
                     ,WRK002.LOT_NO                 AS	LOT_NO								        --LOT NO 
                     ,WRK002.MACH_CD                AS	ST_MACH_CD						            --ST투입설비
                     ,WRK_ORDR.COMP_YN                 AS	COMP_YN								        --작업상태
                     ,(SELECT DECODE(LAND1,''KR'',''내수'',''수출'') FROM TB_MAS009 WHERE CUST_DIV = ''C'' AND CUST_CD = WRK002.KUNNR) AS	INOUT_DIV		--내수/수출
                     ,WRK_ORDR.KUNNR_NM	             AS	KUNNRT								        --거래처
                     ,(SELECT LAND1 FROM TB_MAS009 WHERE CUST_DIV = ''C'' AND CUST_CD = WRK_ORDR.KUNNR) AS KUNNR_NM						              --국가      
                     ,WRK_ORDR.PCODE                   AS	PCODE								        --지종 
                     ,(SELECT MAS001.PCODE_NM FROM TB_MAS001 MAS001 WHERE MAS001.MATNR = WRK_ORDR.MATNR) AS	PCODE_NM								            --지종명
                     ,WRK_ORDR.BS_WGT                  AS	BS_WGT								        --평량
                     ,WRK002.WLEN                   AS	WLEN								        --가로
                     ,WRK002.VLEN                   AS	VLEN								        --세로
                     ,WRK002.WIDTH                  AS	WIDTH								        --실지폭
					 ,WRK002.UNIT					 AS UNIT										--단위
					 ,WRK002.PRFM_QTY				 AS PRFM_QTY									--실적수량   
                     ,WRK002.WGT                    AS	WGT								            --중량 
                     ,(SELECT SUM(DISPO_QTY)  FROM TB_WRK004 MWRK004
                       WHERE WRK002.WERKS =  MWRK004.WERKS
                       AND  WRK002.IND_BCD =  MWRK004.IND_BCD
                       )                              AS	BAD_MRE								        --폐품M/RE
                     ,(SELECT SUM(WGT)  FROM TB_WRK004 MWRK004
                       WHERE WRK002.WERKS =  MWRK004.WERKS
                       AND  WRK002.IND_BCD =  MWRK004.IND_BCD
                       )                              AS	BAD_WGT								        --폐품중량
                     ,WRK002.RMK                   AS	RMK								            --비고
                     ,WRK002.MACH_CD                AS	MACH_CD								        --실적호기
                     ,(SELECT MACH_NM FROM TB_MAS012 WHERE MACH_CD = WRK002.MACH_CD)  AS	MACH_NM								                        --생산실적설비
                     ,WRK002.PRFM_DT                AS	PRFM_DT								        --생산실적일시
                     ,WRK002.PRD_NO                 AS	PRD_NO								        --생산번호
                     ,WRK002.CORE                   AS	CORE								        --지관 
                     ,WRK002.WIDTH                  AS	PKCNT								        --폭수
                     ,WRK002.SCNT                   AS	SCNT								        --속당매/속수
                     ,WRK002.PCNT                   AS	PCNT								        --팔레트당연수
                     ,WRK002.PACKTYPE               AS	PACKTYPE								    --포장타입
                     ,WRK_ORDR.ORDER_RMK               AS	ORDER_RMK								    --지시사항
                     ,WRK002.MATNR                  AS	MATNR								        --자재코드   
                     ,WRK002.VBELN                   AS	VBELN								        --판매오더 
                     ,NVL(WRK002.CNL_YN, ''N'')     AS	CNL_YN								        --취소여부
                     --,DECODE(WRK002.CNL_YN,''Y'',''취소'','''')                    CNL_YN                        --취소여부
                     ,DECODE(WRK_ORDR.TABLE_NM, ''SCH016'', ''슬리터''
											  , ''SCH017'', ''수재단''
											  , DECODE(WRK_ORDR.PROC_CD, ''SA'', ''슬리터 예외생산'', ''수재단 예외생산''))  AS	FILD31   --구분                                                                                                                                        
                     ,WRK002.TM                AS      TM     --생산시간(분) 221103 진승화 생산시간(분)추가
                     ,WRK002.POSNR                AS      POSNR     --판매문서번호순번 221103 진승화 판매문서번호순번추가					         
                     ,WRK002.SDOC_NO                AS      SDOC_NO     --SAP확정문서번호 221103 진승화 SAP확정문서번호
                     ,WRK002.SDOC_SEQNO                AS      SDOC_SEQNO     --SAP확정문서번호순번 221103 진승화 SAP확정문서번호순번
              FROM TB_WRK002 WRK002        --PS실적
                  ,TB_MAS012 MAS012        --설비마스터
				  ,V_WRK_ORDR WRK_ORDR		--작업지시 뷰
              WHERE WRK002.WRK_ORDR_NO = WRK_ORDR.WRK_ORDR_NO(+)
                AND WRK002.WRK_ORDR_SEQNO = WRK_ORDR.WRK_ORDR_SEQNO(+)
                AND ((WRK_ORDR.TABLE_NM = ''SCH016'' AND WRK_ORDR.SLITER_SET = ''X'') OR (WRK_ORDR.TABLE_NM = ''SCH017'' AND WRK_ORDR.PROC_CD = ''CB'') OR (WRK_ORDR.TABLE_NM = ''SCH019''))
                AND WRK002.MACH_CD = MAS012.MACH_CD
 				AND MAS012.PROC_CD IN (''SA'', ''CB'') ';
        
      	IF (V_WERKS IS NOT NULL OR TRIM(V_WERKS) != '') THEN
        	V_SQL := V_SQL || ' AND WRK_ORDR.WERKS = ''' || V_WERKS || '''';            --플랜트코드				      
      	END IF;				
                
      	IF (V_RANGE_SQL IS NOT NULL OR TRIM(V_RANGE_SQL) != '') THEN               --실적일자
        	V_SQL := V_SQL || V_RANGE_SQL; 
      	END IF;   
          
      	IF (V_PROC_CD IS NOT NULL OR TRIM(V_PROC_CD) != '') THEN                   --공정코드
          	V_SQL := V_SQL || ' AND MAS012.PROC_CD = ''' || V_PROC_CD || '''';            				      
      	END IF;

      	IF (V_PCODE IS NOT NULL OR TRIM(V_PCODE) != '') THEN                       --지종
          	V_SQL := V_SQL || ' AND WRK_ORDR.PCODE = ''' || V_PCODE || ''''; 				      
      	END IF;
      
      	IF (V_BS_WGT IS NOT NULL OR TRIM(V_BS_WGT) != '') THEN                     --평량
          	V_SQL := V_SQL || ' AND WRK_ORDR.BS_WGT = ''' || V_BS_WGT || ''''; 				      
      	END IF;
      
      	IF (V_WLEN IS NOT NULL OR TRIM(V_WLEN) != '') THEN                         --가로길이
          	V_SQL := V_SQL || ' AND WRK002.WLEN = ''' || V_WLEN || ''''; 				      
      	END IF;
      
      	IF (V_VLEN IS NOT NULL OR TRIM(V_VLEN) != '') THEN                         --세로길이
          	V_SQL := V_SQL || ' AND WRK002.VLEN = ''' || V_VLEN || ''''; 				      
      	END IF;               
	  
	    IF (V_INOUT_GU IS NOT NULL OR TRIM(V_INOUT_GU) != '') THEN 
		    IF V_INOUT_GU = 'E' THEN
			    V_SQL := V_SQL ||' AND WRK002.WRK_ORDR_NO LIKE ''WOEX%''||''%''  ' ;  
		    ELSIF V_INOUT_GU = 'N' THEN
		        V_SQL := V_SQL ||' AND WRK002.WRK_ORDR_NO NOT LIKE ''WOEX%''||''%''  ' ;
		    END IF;
		END IF;
	  
      	V_SQL := V_SQL || ' AND NVL(WRK002.CNL_YN, ''N'') =  ''' || V_CNL_YN || '''';

      	V_SQL := V_SQL || ' ORDER BY WRK002.MACH_CD, WRK002.IND_BCD';
      
	  	OPEN P_RS_LIST FOR V_SQL;

	END IF;

	P_SUCCESS := 'Y';

	/*EXCEPTION
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
		RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);*/
END;

/
