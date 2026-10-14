--------------------------------------------------------
--  DDL for Procedure SP_WRK28_S12
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_WRK28_S12" (
	P_TYPE           IN    varchar2, -- LIST, SAVE
	P_JSON_STR       IN    CLOB,
	P_SUCCESS       OUT    varchar2,
	P_RS_LIST       OUT    SYS_REFCURSOR 
)
/*==============================================================================
 * PROGRAM ID    : SP_WRK28_S12   
 * PROGRAM NAME  : 포장작업 현황 조회
 * VERSION       : 1.0.0
 * DESCRIPTION   : 포장작업 현황 및 원지 밀롤실적을 관리한다.
 *                 
 * AUTHOR NAME   : 백우종
 * CREATE DATE   : 2023/02/08
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}	<생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}		<생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}			<생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}	<생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2023/02/08    1.0.1   백우종         원지롤 실적조회 쿼리 포함 
 *==============================================================================
 *  관련 테이블
 *        - [TB_INV001] 	: ( R  ) 공정재고 테이블
 *        - [TB_WRK002] 	: ( R  ) 생산실적 테이블
 *        - [TB_MAS012] 	: ( R  ) 설비 마스터 테이블
 *        - [V_WRK_ORDR] 	: ( R  ) 작업지시 뷰(가상 테이블)
 * 		  - [TB_MAS028]     : (.R..) 로케이션
 *=============================================================================*/

AS
	V_PRG_NM          	VARCHAR2(100) 	:= 'SP_WRK28_S12';     -- PROCEDURE NAME

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

	-- 조건절 처리용 변수선언 영역
	V_MACH_CD        	TB_INV001.MACH_CD%TYPE;			--설비코드(호기)
	V_LOC_CD	 		TB_INV001.LOC_CD%TYPE;			--로케이션코드

    V_SDATE             varchar2(8);  
    V_EDATE             varchar2(8);
    V_PCODE             TB_SCH017.PCODE%TYPE;           --지종
    V_BS_WGT            TB_SCH017.BS_WGT%TYPE;          --평량
    V_WLEN              TB_SCH017.WLEN%TYPE;            --가로길이 
    V_VLEN              TB_SCH017.VLEN%TYPE;            --세로길이 
    V_IND_BCD           TB_WRK002.IND_BCD%TYPE;           --개별바코드
	V_CNL_YN			TB_WRK002.CNL_YN%TYPE;			--취소여부

    V_INOUT_GU             VARCHAR2(2); 
	V_SQL				CLOB;


	V_CHKFG				VARCHAR2(10);

BEGIN
	OPEN P_RS_LIST FOR 

	SELECT NULL FROM DUAL WHERE ROWNUM = 0;

	V_JSON 				:= JSON_OBJECT_T.parse(P_JSON_STR);

	V_SESS_USER_ID		:= V_JSON.get_string('SES_USER_ID');
	V_PLT_CD			:= V_JSON.get_string('SES_PLNTKY');
    V_IND_BCD			:= V_JSON.get_string('IND_BCD');
    V_SDATE             := V_JSON.get_string('SDATE');           --재단생산일자
    V_EDATE             := V_JSON.get_string('EDATE');
    V_PCODE             := V_JSON.get_string('PCODE');           --지종
    V_BS_WGT            := V_JSON.get_string('BS_WGT');          --평량
    V_WLEN              := V_JSON.get_string('WLEN');            --가로길이 
    V_VLEN              := V_JSON.get_string('VLEN');            --세로길이 
    V_INOUT_GU 		    := V_JSON.get_string('INOUT_GU');   	
 	V_CNL_YN			:= V_JSON.get_string('CNL_YN');			--취소여부

 	V_CHKFG				:= V_JSON.get_string('CHKFG');			--원지포함여부

	IF P_TYPE = 'LIST' THEN
		IF V_CHKFG = 'ON' THEN
--			V_SQL := 'SELECT SYSDATE FROM DUAL';
			V_SQL := ' SELECT DISTINCT
	               SCH018.PCODE	                                PCODE           --지종
	             , MAS001.PCODE_NM                              PCODE_NM        --지종명
	             , SCH018.BS_WGT	                            BS_WGT          --평량
	             , SCH018.WLEN	                                WLEN            --가로길
	             , SCH018.VLEN	                                VLEN            --세로길
	             , SCH018.MATNR	                                MATNR           --자재코드
	             , MAS001.MATNR_NM	                            MATNR_NM        --자재명
	             , SCH018.PACKTYPE                              PACKTYPE        --포장타입
	             , FN_CMCDV (''PACK_TYPE'', SCH018.PACKTYPE)      PACKTYPE_NM     --포장타입명
	             , SCH018.ORDER_NO                              ORDER_NO        --오더번호 
	             , NVL(MAS001.DOMESTIC,''Y'')                     DOMESTIC        --내수구분
	             , CASE WHEN NVL(MAS001.DOMESTIC,''Y'') = ''Y'' THEN ''내수''
	                        ELSE                                 ''외자''
	                END                                         DOMESTIC_NM     --내수구분명
	             , SCH018.KUNNR                                 KUNNR           --판매처 
	             , SCH018.KUNNRT                               	KUNNRT          --판매처명 
	             , MAS009.LAND1                                 LAND1           --국가
	             , FN_CMCDV (''NTN_CD'', MAS009.LAND1)            LAND1_NM        --국가명
	             , CWRK002.LOT_NO	                            CLOT_NO         --재단LOT_NO 
	             , CWRK002.IND_BCD	                            CIND_BCD        --재단개별바코드
	             , CWRK002.PRD_DT                                CPRD_DT         --재단일
	             , CWRK002.MACH_CD                               CMACH_CD        --재단설비
	             , CMAS012.MACH_NM                               CMACH_NM        --재단설비명     
	             , CWRK002.REGID                                 CREGID          --재단작업자
	             , NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = CWRK002.REGID),'''')
	                                                              CREGNM          --재단작업명
	             , NVL(SCH015.WRK_ORDR_DIV,''1'')                   WRK_ORDR_DIV    --작업지시구분   
	             , CASE WHEN NVL(SCH015.WRK_ORDR_DIV,''1'') = ''1'' THEN  ''정상지시''
	                    ELSE                                          ''비계획생산지시''   
	                 END                                         WRK_ORDR_DIV_NM  --작업지시구분명 
	             , SCH018.PALETTECNT	                        PALETTECNT       --팔레트당연수
	             , SCH017.PLT_PER_CNT	                        CPALETTECNT      --재단팔레트당연수
	             , CWRK002.WGT	                                CWGT             --재단중량    
	             , I001.STCK_STA	                            STCK_STA         --재고상태
	             , FN_CMCDV (''STCK_STA'', I001.STCK_STA)	  	STA_NM           --재고상태명     
	             , M028.LOC_NM                                  LOC_NM	         --로케이션 명
	             , PWRK002.PRD_DT	                            PPRD_DT          --포장생산일자
	             , PWRK002.PRFM_DT	                            PPRFM_DT         --포장실적일자
	             , PWRK002.LOT_NO	                            PLOT_NO          --포장LOT_NO
	             , PWRK002.IND_BCD	                            PIND_BCD         --포장개별바코드
	             --, DECODE(CWRK002.LOT_NO, PWRK002.LOT_NO_M1, PWRK002.USE_REAM_M1, PWRK002.LOT_NO_M2, PWRK002.USE_REAM_M2, 
	             --                         PWRK002.LOT_NO_M3, PWRK002.USE_REAM_M3, PWRK002.LOT_NO_M4, PWRK002.USE_REAM_M4, PWRK002.USE_REAM_M5)       PPCNT            --포장연수
				 , PINV010.USE_QTY								PPCNT			 --포장연수
	             , CASE WHEN PWRK002.STA IN (''30'', ''40'', ''50'') THEN  PWRK002.PCNT
	                    ELSE                                         0 
	                END                                         DISPOPCNT        --폐품 연수(RE)
	             , NULL                                         DISPO_WGT        --폐품 중량(RE)    
	             , SCH018.IN_PER_CNT	                        IN_PER_CNT       --속당매수
	             , PWRK002.SCNT                                 SCNT             --속수
	             , PWRK002.MCNT                                 MCNT             --매수
	             , PWRK002.WGT	                                PWGT             --포장중량
	             , PWRK002.MACH_CD                              PMACH_CD         --포장설비
	             , PMAS012.MACH_NM                              PMACH_NM         --포장설비명       
	             , PWRK002.WRK_CLASS	                        WRK_CLASS        --반
	             , PWRK002.REGID                                PREGID          --포장작업자
	             , NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = PWRK002.REGID),'''')
	                                                            PREGNM           --포장작업명
	             , SCH018.CON_TYPE                              CONTAINER        --컨테이너
	             , SCH018.ROUTE                                 HANG             --항차
	             , PWRK002.RMK                                  RMK              --비고
	             , /*JWRK002*/ SCH015.ORDER_NO                             JORDER_NO        --점보롤오더번호
	             , SCH016.ORDER_NO                              MORDER_NO        --밀롤오더번호
				 , NVL(PWRK002.CNL_YN, ''N'')					CNL_YN			--취소여부
				 , PWRK002.VBELN								VBELN			--판매문서번호
				 , PWRK002.POSNR								POSNR			--판매문서항목번호
				 , PWRK002.SDOC_NO								SDOC_NO			--SAP확정문서번호
				 , PWRK002.SDOC_SEQNO							SDOC_SEQNO		--SAP문서번호순번
				 , I001.STOR_LOC_CD								STOR_LOC_CD		--저장위치코드
	        FROM TB_WRK002    PWRK002   --포장실적테이블(PS)
	           , TB_MAS001    MAS001    --플랜트별 제품/자재 마스터
	           , TB_INV010    PINV010   --포장투입실적테이블(PS)
	           , TB_MAS012    PMAS012   --포장설비 마스터 
	           , TB_MAS009    MAS009    --거래처(고객사/공급사) 마스터 
	           , TB_INV010    CINV010   --재단투입실적테이블(PS)
	           , TB_WRK002    CWRK002   --재단실적테이블(PS)
	           , TB_MAS012    CMAS012   --재단설비 마스터    
	           , TB_INV010    MINV010   --밀롤투입실적테이블(PS)     
	           , TB_WRK002    MWRK002   --밀롤실적테이블(PS) 
	           , TB_MAS012    MMAS012   --밀롤설비 마스터    
	           --, TB_INV010    JINV010   --점보롤투입실적테이블(PS)
	           , TB_WRK002    JWRK002   --점보롤실적테이블(PS)
	           , TB_MAS012    JMAS012   --점보롤설비 마스터 
	           , TB_SCH018    SCH018    --작업지시 포장
	           , TB_SCH017    SCH017    --작업지시 재단
	           , TB_SCH016    SCH016    --작업지시 밀롤,슬리터
	           , TB_SCH015    SCH015    --작업지시 점보롤
			   , TB_INV001	  I001		--공정재고
			   , TB_MAS028	  M028		--로케이션
	        WHERE PWRK002.WERKS           = MAS001.WERKS
	          AND PWRK002.MATNR           = MAS001.MATNR
	          AND PWRK002.WERKS           = PINV010.WERKS   (+)
	          AND PWRK002.IND_BCD         = PINV010.IND_BCD (+)      
	          AND PWRK002.MACH_CD         = PMAS012.MACH_CD(+)
	          AND PWRK002.KUNNR            = MAS009.CUST_CD(+) 
	          AND MAS009.CUST_DIV(+)       = ''C''
			  AND PWRK002.IND_BCD	 	  =	I001.IND_BCD(+)
		  	  AND I001.WERKS			  = M028.WERKS(+)
			  AND I001.STOR_LOC_CD		  = M028.STOR_LOC_CD(+)
			  AND I001.LOC_CD			  = M028.LOC_CD(+)  
	          AND PINV010.WERKS           = CINV010.WERKS(+)
	          AND PINV010.IND_BCD_M       = CINV010.IND_BCD(+)
	          AND CINV010.WERKS           = CWRK002.WERKS(+)
	          AND CINV010.IND_BCD         = CWRK002.IND_BCD(+)
	          AND CWRK002.MACH_CD         = CMAS012.MACH_CD(+)  
	          AND CINV010.WERKS           = MINV010.WERKS(+)
	          AND CINV010.IND_BCD_M       = MINV010.IND_BCD(+)
	          AND MINV010.WERKS           = MWRK002.WERKS(+)
	          AND MINV010.IND_BCD         = MWRK002.IND_BCD(+)
	          AND MWRK002.MACH_CD         = MMAS012.MACH_CD(+)   
	          AND MINV010.WERKS           = JWRK002.WERKS(+)
	          AND MINV010.IND_BCD_M       = JWRK002.IND_BCD(+)
	          --AND JINV010.WERKS           = JWRK002.WERKS(+)
	          --AND JINV010.IND_BCD         = JWRK002.IND_BCD(+)
	          AND JWRK002.MACH_CD         = JMAS012.MACH_CD(+)
	          AND PWRK002.WRK_ORDR_NO     = SCH018.WRK_ORDR_NO
	          AND PWRK002.WRK_ORDR_SEQNO  = SCH018.WRK_ORDR_SEQNO
	          AND CWRK002.WRK_ORDR_NO     = SCH017.WRK_ORDR_NO(+)
	          AND CWRK002.WRK_ORDR_SEQNO  = SCH017.WRK_ORDR_SEQNO(+)
	          AND MWRK002.WRK_ORDR_NO     = SCH016.WRK_ORDR_NO(+)
	          AND MWRK002.WRK_ORDR_SEQNO  = SCH016.WRK_ORDR_SEQNO(+)
	          AND JWRK002.WRK_ORDR_NO     = SCH015.WRK_ORDR_NO(+)
	          AND JWRK002.WRK_ORDR_SEQNO  = SCH015.WRK_ORDR_SEQNO(+)
	          AND PMAS012.PROC_CD        IN (''PB'',''PC'',''ZA'')   
	          AND NVL(CWRK002.CNL_YN, ''N'') = ''N''
			  AND NVL(MWRK002.CNL_YN, ''N'') = ''N''
	 		  AND NVL(JWRK002.CNL_YN, ''N'') = ''N''
	          --AND SUBSTR(PWRK002.WRK_ORDR_NO,1,4) <> ''WOEX''
	               ';	
	
	            V_SQL := V_SQL || ' AND PWRK002.PRFM_DT BETWEEN ''' || V_SDATE || ''' AND ''' || V_EDATE || ''''; --포장생산일자			      
	
	        	IF (V_IND_BCD IS NOT NULL OR TRIM(V_IND_BCD) != '') THEN
	            	V_SQL := V_SQL || ' AND PWRK002.IND_BCD = ''' || V_IND_BCD || '''';  --개별바코드				      
	        	END IF;
	
	        	IF (V_PCODE IS NOT NULL OR TRIM(V_PCODE) != '') THEN
	            	V_SQL := V_SQL || ' AND SCH017.PCODE = ''' || V_PCODE || '''';  --지종				      
	        	END IF;
	
	        	IF (V_BS_WGT IS NOT NULL OR TRIM(V_BS_WGT) != '') THEN
	            	V_SQL := V_SQL || ' AND SCH017.BS_WGT = ''' || V_BS_WGT || ''''; ----평량				      
	        	END IF;
	
	        	IF (V_WLEN IS NOT NULL OR TRIM(V_WLEN) != '') THEN
	            	V_SQL := V_SQL || ' AND SCH017.WLEN =  ''' || V_WLEN || ''''; ----가로길이 				      
	        	END IF;
	
	        	IF (V_VLEN IS NOT NULL OR TRIM(V_VLEN) != '') THEN
	            	V_SQL := V_SQL || ' AND SCH017.VLEN =  ''' || V_VLEN || ''''; ----세로길이 
	        	END IF;
	
	            IF    V_INOUT_GU = 'E' THEN
	                V_SQL := V_SQL ||' AND PWRK002.WRK_ORDR_NO LIKE ''WOEX%''||''%''  ' ;  
	            ELSIF V_INOUT_GU = 'N' THEN
	                V_SQL := V_SQL ||' AND PWRK002.WRK_ORDR_NO NOT LIKE ''WOEX%''||''%''  ' ;
	            END IF;
				
	            --20221121 여한진 취소여부 검색조건 추가
	            IF (V_CNL_YN IS NOT NULL OR TRIM(V_CNL_YN) != '') THEN                          --취소여부
	            	IF V_CNL_YN = 'N' THEN 
	            		V_SQL := V_SQL || ' AND NVL(PWRK002.PRFM_GTHR_YN, ''N'') = ''Y''';
	            	ELSE
	            		V_SQL := V_SQL || ' AND NVL(PWRK002.PRFM_GTHR_YN, ''N'') = ''N''';
	            	END IF;
	            	V_SQL := V_SQL || ' AND NVL(PWRK002.CNL_YN, ''N'') =  ''' || V_CNL_YN || '''';
	        	END IF;


				V_SQL := V_SQL || ' UNION ';

				V_SQL := V_SQL || ' SELECT    DISTINCT SCH016.PCODE                              PCODE               -- 지종
						        , MAS001.PCODE_NM                           PCODE_NM            -- 지종명
						        , SCH016.BS_WGT                             BS_WGT              -- 평량
						        , TO_NUMBER(SUBSTR(MWRK002.MATNR, LENGTH(MWRK002.MATNR)-7, 4))
																			WLEN                -- 가로길이
						        , TO_NUMBER(SUBSTR(MWRK002.MATNR, LENGTH(MWRK002.MATNR)-3, 4))
																			VLEN                -- 세로길이
						        , MWRK002.MATNR                             MATNR               -- 자재코드
						        , MAS001.MATNR_NM                           MATNR_NM            -- 자재명
						        , ''''                                        PACKTYPE            -- 포장타입
						        , ''''                                        PACKTYPE_NM         -- 포장타입명
						        , SCH016.ORDER_NO                           ORDER_NO            -- 오더번호
						        , NVL(MAS001.DOMESTIC, ''Y'')                 DOMESTIC            -- 내수구분
						        , CASE    WHEN    NVL(MAS001.DOMESTIC, ''Y'') = ''Y'' THEN    ''내수''
						                  ELSE                                            ''외자''
						          END                                       DOMESTIC_NM         -- 내수구분명
						        , SCH016.KUNNR                              KUNNR               -- 판매처
						        , SCH016.KUNNRT                             KUNNRT              -- 판매처명
						        , MAS009.LAND1                              LAND1               -- 국가코드
						        , FN_CMCDV(''NTN_CD'', MAS009.LAND1)          LAND1_NM            -- 국가명
						        , ''''                                        CLOT_NO             -- 재단 LOT_NO
						        , ''''                                        CIND_BCD            -- 재단 개별바코드
						        , NULL                                        CPRD_DT             -- 재단일
						        , ''''                                        CMACH_CD            -- 재단 설비
						        , ''''                                        CMACH_NM            -- 재단 설비명
						        , ''''                                        CREGID              -- 재단 작업자
						        , ''''                                        CREGNM              -- 재단 작업자명
						        , ''''                                        WRK_ORDR_DIV
						        , ''''                                        WRK_ORDR_DIV_NM
						--        , NVL(SCH016.WRK_ORDR_DIV,''1'')              WRK_ORDR_DIV        -- 작업지시 구분
						--        , CASE WHEN NVL(SCH015.WRK_ORDR_DIV,''1'') = ''1'' THEN  ''정상지시''
						--            ELSE                                          ''비계획생산지시''
						--          END                                       WRK_ORDR_DIV_NM     -- 작업지시구분명
						        , 0                                        PALETTECNT          -- 팔레트당 연수
						        , 0                                        CPALETTECNT         -- 재단팔레트당 연수
						        , 0                                        CWGT                -- 재단중량
						        , I001.STCK_STA	                            STCK_STA            -- 재고상태
						        , FN_CMCDV (''STCK_STA'', I001.STCK_STA)	  	STA_NM              -- 재고상태명
						         , MAS028.LOC_NM                              LOC_NM	         -- 로케이션 명
						         , MWRK002.PRD_DT                             PPRD_DT          -- 포장생산일자
					             , MWRK002.PRFM_DT	                          PPRFM_DT         -- 포장실적일자
						         , MWRK002.LOT_NO							  PLOT_NO          -- 포장LOT_NO
						         , MWRK002.IND_BCD							  PIND_BCD         -- 포장개별바코드
						         , 0	                                      PPCNT			 -- 포장연수
						         , CASE WHEN MWRK002.STA IN (''30'', ''40'', ''50'') THEN  MWRK002.PCNT
						                ELSE                                         0 
						            END                                     DISPOPCNT        -- 폐품 연수(RE)
						        , NULL                                      DISPO_WGT        -- 폐품 중량(RE)    
						        , 0                                         IN_PER_CNT       -- 속당매수
						        , MWRK002.SCNT                              SCNT             -- 속수
						        , MWRK002.MCNT                              MCNT             -- 매수
						        , MWRK002.WGT	                            PWGT             -- 중량
						        , MWRK002.MACH_CD                           PMACH_CD         -- 설비
						        , MAS012.MACH_NM                            PMACH_NM         -- 설비명       
						        , MWRK002.WRK_CLASS	                        WRK_CLASS        -- 반
						        , MWRK002.REGID                             PREGID           -- 포장작업자
						        , NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = MWRK002.REGID),'''')
						                                                    PREGNM           -- 포장작업명
						        , 0                                        CONTAINER
						--        , SCH016.CON_TYPE                              CONTAINER        --컨테이너
						        , SCH016.ROUTE                              HANG             -- 항차
						        , MWRK002.RMK                               RMK              -- 비고
						        , SCH016.PRE_ORDER_NO                       JORDER_NO        -- 점보롤오더번호
						        , SCH016.ORDER_NO                           MORDER_NO        -- 밀롤오더번호
						        , NVL(MWRK002.CNL_YN, ''N'')				CNL_YN			-- 취소여부
						        , MWRK002.VBELN								VBELN			-- 판매문서번호
						        , MWRK002.POSNR								POSNR			-- 판매문서항목번호
						        , MWRK002.SDOC_NO							SDOC_NO			-- SAP확정문서번호
						        , MWRK002.SDOC_SEQNO						SDOC_SEQNO		-- SAP문서번호순번
						        , I001.STOR_LOC_CD							STOR_LOC_CD		-- 저장위치코드
						FROM    TB_WRK002 MWRK002
						            INNER   JOIN    TB_SCH016 SCH016
						                ON  MWRK002.WERKS = SCH016.WERKS
						                AND MWRK002.WRK_ORDR_NO = SCH016.WRK_ORDR_NO
						                AND MWRK002.WRK_ORDR_SEQNO = SCH016.WRK_ORDR_SEQNO
						            INNER   JOIN    TB_MAS001 MAS001
						                ON  MWRK002.WERKS = MAS001.WERKS
						                AND MWRK002.MATNR = MAS001.MATNR
						            LEFT OUTER   JOIN   TB_MAS009 MAS009
						                ON  MWRK002.KUNNR = MAS009.CUST_CD
						            LEFT OUTER  JOIN    TB_INV001 I001
						                ON  MWRK002.WERKS = I001.WERKS
						                AND MWRK002.IND_BCD = I001.IND_BCD
						                AND MWRK002.MATNR = I001.MATNR
						            LEFT OUTER  JOIN    TB_MAS012 MAS012
						                ON  MWRK002.MACH_CD = MAS012.MACH_CD
						            LEFT OUTER  JOIN    TB_MAS028 MAS028
						                ON  I001.WERKS = MAS028.WERKS
						                AND I001.STOR_LOC_CD = MAS028.STOR_LOC_CD
						                AND I001.LOC_CD = MAS028.LOC_CD
						WHERE   MWRK002.WERKS = ''P100''
						AND     SCH016.SHEET <> ''X''
						AND     MAS009.CUST_DIV = ''C''
					';

				
	            V_SQL := V_SQL || ' AND MWRK002.PRFM_DT BETWEEN ''' || V_SDATE || ''' AND ''' || V_EDATE || ''''; --포장생산일자			      
	
	        	IF (V_IND_BCD IS NOT NULL OR TRIM(V_IND_BCD) != '') THEN
	            	V_SQL := V_SQL || ' AND MWRK002.IND_BCD = ''' || V_IND_BCD || '''';  --개별바코드				      
	        	END IF;
--	
--	        	IF (V_PCODE IS NOT NULL OR TRIM(V_PCODE) != '') THEN
--	            	V_SQL := V_SQL || ' AND SCH017.PCODE = ''' || V_PCODE || '''';  --지종				      
--	        	END IF;
--	
--	        	IF (V_BS_WGT IS NOT NULL OR TRIM(V_BS_WGT) != '') THEN
--	            	V_SQL := V_SQL || ' AND SCH017.BS_WGT = ''' || V_BS_WGT || ''''; ----평량				      
--	        	END IF;
--	
--	        	IF (V_WLEN IS NOT NULL OR TRIM(V_WLEN) != '') THEN
--	            	V_SQL := V_SQL || ' AND SCH017.WLEN =  ''' || V_WLEN || ''''; ----가로길이 				      
--	        	END IF;
--	
--	        	IF (V_VLEN IS NOT NULL OR TRIM(V_VLEN) != '') THEN
--	            	V_SQL := V_SQL || ' AND SCH017.VLEN =  ''' || V_VLEN || ''''; ----세로길이 
--	        	END IF;
	
	            IF    V_INOUT_GU = 'E' THEN
	                V_SQL := V_SQL ||' AND MWRK002.WRK_ORDR_NO LIKE ''WOEX%''||''%''  ' ;  
	            ELSIF V_INOUT_GU = 'N' THEN
	                V_SQL := V_SQL ||' AND MWRK002.WRK_ORDR_NO NOT LIKE ''WOEX%''||''%''  ' ;
	            END IF;
				
	            --20221121 여한진 취소여부 검색조건 추가
	            IF (V_CNL_YN IS NOT NULL OR TRIM(V_CNL_YN) != '') THEN                          --취소여부
	            	IF V_CNL_YN = 'N' THEN 
	            		V_SQL := V_SQL || ' AND NVL(MWRK002.PRFM_GTHR_YN, ''N'') = ''Y''';
	            	ELSE
	            		V_SQL := V_SQL || ' AND NVL(MWRK002.PRFM_GTHR_YN, ''N'') = ''N''';
	            	END IF;
	            	V_SQL := V_SQL || ' AND NVL(MWRK002.CNL_YN, ''N'') =  ''' || V_CNL_YN || '''';
	        	END IF;
				
				
--	        	V_SQL := V_SQL || ' ORDER BY PWRK002.PRD_DT,PWRK002.IND_BCD';
	        	V_SQL := V_SQL || ' ORDER BY PPRD_DT, PIND_BCD';
	
	        IF (V_DEBUG = 'Y') THEN
	        	INSERT INTO PROC_LOG (SQL_STR) VALUES (V_SQL);
	        END IF;
	
			OPEN P_RS_LIST FOR V_SQL;
		ELSE
			V_SQL := 'SELECT SYSDATE FROM DUAL';
			V_SQL := 
			' SELECT DISTINCT
	               SCH018.PCODE	                                PCODE           --지종
	             , MAS001.PCODE_NM                              PCODE_NM        --지종명
	             , SCH018.BS_WGT	                            BS_WGT          --평량
	             , SCH018.WLEN	                                WLEN            --가로길
	             , SCH018.VLEN	                                VLEN            --세로길
	             , SCH018.MATNR	                                MATNR           --자재코드
	             , MAS001.MATNR_NM	                            MATNR_NM        --자재명
	             , SCH018.PACKTYPE                              PACKTYPE        --포장타입
	             , FN_CMCDV (''PACK_TYPE'', SCH018.PACKTYPE)      PACKTYPE_NM     --포장타입명
	             , SCH018.ORDER_NO                              ORDER_NO        --오더번호 
	             , NVL(MAS001.DOMESTIC,''Y'')                     DOMESTIC        --내수구분
	             , CASE WHEN NVL(MAS001.DOMESTIC,''Y'') = ''Y'' THEN ''내수''
	                        ELSE                                 ''외자''
	                END                                         DOMESTIC_NM     --내수구분명
	             , SCH018.KUNNR                                 KUNNR           --판매처 
	             , SCH018.KUNNRT                               	KUNNRT          --판매처명 
	             , MAS009.LAND1                                 LAND1           --국가
	             , FN_CMCDV (''NTN_CD'', MAS009.LAND1)            LAND1_NM        --국가명
	             , CWRK002.LOT_NO	                            CLOT_NO         --재단LOT_NO 
	             , CWRK002.IND_BCD	                            CIND_BCD        --재단개별바코드
	             , CWRK002.PRD_DT                                CPRD_DT         --재단일
	             , CWRK002.MACH_CD                               CMACH_CD        --재단설비
	             , CMAS012.MACH_NM                               CMACH_NM        --재단설비명     
	             , CWRK002.REGID                                 CREGID          --재단작업자
	             , NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = CWRK002.REGID),'''')
	                                                              CREGNM          --재단작업명
	             , NVL(SCH015.WRK_ORDR_DIV,''1'')                   WRK_ORDR_DIV    --작업지시구분   
	             , CASE WHEN NVL(SCH015.WRK_ORDR_DIV,''1'') = ''1'' THEN  ''정상지시''
	                    ELSE                                          ''비계획생산지시''   
	                 END                                         WRK_ORDR_DIV_NM  --작업지시구분명 
	             , SCH018.PALETTECNT	                        PALETTECNT       --팔레트당연수
	             , SCH017.PLT_PER_CNT	                        CPALETTECNT      --재단팔레트당연수
	             , CWRK002.WGT	                                CWGT             --재단중량    
	             , I001.STCK_STA	                            STCK_STA         --재고상태
	             , FN_CMCDV (''STCK_STA'', I001.STCK_STA)	  	STA_NM           --재고상태명     
	             , M028.LOC_NM                                  LOC_NM	         --로케이션 명
	             , PWRK002.PRD_DT	                            PPRD_DT          --포장생산일자
	             , PWRK002.PRFM_DT	                            PPRFM_DT         --포장실적일자
	             , PWRK002.LOT_NO	                            PLOT_NO          --포장LOT_NO
	             , PWRK002.IND_BCD	                            PIND_BCD         --포장개별바코드
	             --, DECODE(CWRK002.LOT_NO, PWRK002.LOT_NO_M1, PWRK002.USE_REAM_M1, PWRK002.LOT_NO_M2, PWRK002.USE_REAM_M2, 
	             --                         PWRK002.LOT_NO_M3, PWRK002.USE_REAM_M3, PWRK002.LOT_NO_M4, PWRK002.USE_REAM_M4, PWRK002.USE_REAM_M5)       PPCNT            --포장연수
				 , PINV010.USE_QTY								PPCNT			 --포장연수
	             , CASE WHEN PWRK002.STA IN (''30'', ''40'', ''50'') THEN  PWRK002.PCNT
	                    ELSE                                         0 
	                END                                         DISPOPCNT        --폐품 연수(RE)
	             , NULL                                         DISPO_WGT        --폐품 중량(RE)    
	             , SCH018.IN_PER_CNT	                        IN_PER_CNT       --속당매수
	             , PWRK002.SCNT                                 SCNT             --속수
	             , PWRK002.MCNT                                 MCNT             --매수
	             , PWRK002.WGT	                                PWGT             --포장중량
	             , PWRK002.MACH_CD                              PMACH_CD         --포장설비
	             , PMAS012.MACH_NM                              PMACH_NM         --포장설비명       
	             , PWRK002.WRK_CLASS	                        WRK_CLASS        --반
	             , PWRK002.REGID                                PREGID          --포장작업자
	             , NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = PWRK002.REGID),'''')
	                                                            PREGNM           --포장작업명
	             , SCH018.CON_TYPE                              CONTAINER        --컨테이너
	             , SCH018.ROUTE                                 HANG             --항차
	             , PWRK002.RMK                                  RMK              --비고
	             , /*JWRK002*/ SCH015.ORDER_NO                             JORDER_NO        --점보롤오더번호
	             , SCH016.ORDER_NO                              MORDER_NO        --밀롤오더번호
				 , NVL(PWRK002.CNL_YN, ''N'')					CNL_YN			--취소여부
				 , PWRK002.VBELN								VBELN			--판매문서번호
				 , PWRK002.POSNR								POSNR			--판매문서항목번호
				 , PWRK002.SDOC_NO								SDOC_NO			--SAP확정문서번호
				 , PWRK002.SDOC_SEQNO							SDOC_SEQNO		--SAP문서번호순번
				 , I001.STOR_LOC_CD								STOR_LOC_CD		--저장위치코드
	        FROM TB_WRK002    PWRK002   --포장실적테이블(PS)
	           , TB_MAS001    MAS001    --플랜트별 제품/자재 마스터
	           , TB_INV010    PINV010   --포장투입실적테이블(PS)
	           , TB_MAS012    PMAS012   --포장설비 마스터 
	           , TB_MAS009    MAS009    --거래처(고객사/공급사) 마스터 
	           , TB_INV010    CINV010   --재단투입실적테이블(PS)
	           , TB_WRK002    CWRK002   --재단실적테이블(PS)
	           , TB_MAS012    CMAS012   --재단설비 마스터    
	           , TB_INV010    MINV010   --밀롤투입실적테이블(PS)     
	           , TB_WRK002    MWRK002   --밀롤실적테이블(PS) 
	           , TB_MAS012    MMAS012   --밀롤설비 마스터    
	           --, TB_INV010    JINV010   --점보롤투입실적테이블(PS)
	           , TB_WRK002    JWRK002   --점보롤실적테이블(PS)
	           , TB_MAS012    JMAS012   --점보롤설비 마스터 
	           , TB_SCH018    SCH018    --작업지시 포장
	           , TB_SCH017    SCH017    --작업지시 재단
	           , TB_SCH016    SCH016    --작업지시 밀롤,슬리터
	           , TB_SCH015    SCH015    --작업지시 점보롤
			   , TB_INV001	  I001		--공정재고
			   , TB_MAS028	  M028		--로케이션
	        WHERE PWRK002.WERKS           = MAS001.WERKS
	          AND PWRK002.MATNR           = MAS001.MATNR
	          AND PWRK002.WERKS           = PINV010.WERKS   (+)
	          AND PWRK002.IND_BCD         = PINV010.IND_BCD (+)      
	          AND PWRK002.MACH_CD         = PMAS012.MACH_CD(+)
	          AND PWRK002.KUNNR            = MAS009.CUST_CD(+) 
	          AND MAS009.CUST_DIV(+)       = ''C''
			  AND PWRK002.IND_BCD	 	  =	I001.IND_BCD(+)
		  	  AND I001.WERKS			  = M028.WERKS(+)
			  AND I001.STOR_LOC_CD		  = M028.STOR_LOC_CD(+)
			  AND I001.LOC_CD			  = M028.LOC_CD(+)  
	          AND PINV010.WERKS           = CINV010.WERKS(+)
	          AND PINV010.IND_BCD_M       = CINV010.IND_BCD(+)
	          AND CINV010.WERKS           = CWRK002.WERKS(+)
	          AND CINV010.IND_BCD         = CWRK002.IND_BCD(+)
	          AND CWRK002.MACH_CD         = CMAS012.MACH_CD(+)  
	          AND CINV010.WERKS           = MINV010.WERKS(+)
	          AND CINV010.IND_BCD_M       = MINV010.IND_BCD(+)
	          AND MINV010.WERKS           = MWRK002.WERKS(+)
	          AND MINV010.IND_BCD         = MWRK002.IND_BCD(+)
	          AND MWRK002.MACH_CD         = MMAS012.MACH_CD(+)   
	          AND MINV010.WERKS           = JWRK002.WERKS(+)
	          AND MINV010.IND_BCD_M       = JWRK002.IND_BCD(+)
	          --AND JINV010.WERKS           = JWRK002.WERKS(+)
	          --AND JINV010.IND_BCD         = JWRK002.IND_BCD(+)
	          AND JWRK002.MACH_CD         = JMAS012.MACH_CD(+)
	          AND PWRK002.WRK_ORDR_NO     = SCH018.WRK_ORDR_NO
	          AND PWRK002.WRK_ORDR_SEQNO  = SCH018.WRK_ORDR_SEQNO
	          AND CWRK002.WRK_ORDR_NO     = SCH017.WRK_ORDR_NO(+)
	          AND CWRK002.WRK_ORDR_SEQNO  = SCH017.WRK_ORDR_SEQNO(+)
	          AND MWRK002.WRK_ORDR_NO     = SCH016.WRK_ORDR_NO(+)
	          AND MWRK002.WRK_ORDR_SEQNO  = SCH016.WRK_ORDR_SEQNO(+)
	          AND JWRK002.WRK_ORDR_NO     = SCH015.WRK_ORDR_NO(+)
	          AND JWRK002.WRK_ORDR_SEQNO  = SCH015.WRK_ORDR_SEQNO(+)
	          AND PMAS012.PROC_CD        IN (''PB'',''PC'',''ZA'')   
	          AND NVL(CWRK002.CNL_YN, ''N'') = ''N''
			  AND NVL(MWRK002.CNL_YN, ''N'') = ''N''
	 		  AND NVL(JWRK002.CNL_YN, ''N'') = ''N''
	          --AND SUBSTR(PWRK002.WRK_ORDR_NO,1,4) <> ''WOEX''
	               ';	
	
	            V_SQL := V_SQL || ' AND PWRK002.PRFM_DT BETWEEN ''' || V_SDATE || ''' AND ''' || V_EDATE || ''''; --포장생산일자			      
	
	        	IF (V_IND_BCD IS NOT NULL OR TRIM(V_IND_BCD) != '') THEN
	            	V_SQL := V_SQL || ' AND PWRK002.IND_BCD = ''' || V_IND_BCD || '''';  --개별바코드				      
	        	END IF;
	
	        	IF (V_PCODE IS NOT NULL OR TRIM(V_PCODE) != '') THEN
	            	V_SQL := V_SQL || ' AND SCH017.PCODE = ''' || V_PCODE || '''';  --지종				      
	        	END IF;
	
	        	IF (V_BS_WGT IS NOT NULL OR TRIM(V_BS_WGT) != '') THEN
	            	V_SQL := V_SQL || ' AND SCH017.BS_WGT = ''' || V_BS_WGT || ''''; ----평량				      
	        	END IF;
	
	        	IF (V_WLEN IS NOT NULL OR TRIM(V_WLEN) != '') THEN
	            	V_SQL := V_SQL || ' AND SCH017.WLEN =  ''' || V_WLEN || ''''; ----가로길이 				      
	        	END IF;
	
	        	IF (V_VLEN IS NOT NULL OR TRIM(V_VLEN) != '') THEN
	            	V_SQL := V_SQL || ' AND SCH017.VLEN =  ''' || V_VLEN || ''''; ----세로길이 
	        	END IF;
	
	            IF    V_INOUT_GU = 'E' THEN
	                V_SQL := V_SQL ||' AND PWRK002.WRK_ORDR_NO LIKE ''WOEX%''||''%''  ' ;  
	            ELSIF V_INOUT_GU = 'N' THEN
	                V_SQL := V_SQL ||' AND PWRK002.WRK_ORDR_NO NOT LIKE ''WOEX%''||''%''  ' ;
	            END IF;
				
	            --20221121 여한진 취소여부 검색조건 추가
	            IF (V_CNL_YN IS NOT NULL OR TRIM(V_CNL_YN) != '') THEN                          --취소여부
	            	IF V_CNL_YN = 'N' THEN 
	            		V_SQL := V_SQL || ' AND NVL(PWRK002.PRFM_GTHR_YN, ''N'') = ''Y''';
	            	ELSE
	            		V_SQL := V_SQL || ' AND NVL(PWRK002.PRFM_GTHR_YN, ''N'') = ''N''';
	            	END IF;
	            	V_SQL := V_SQL || ' AND NVL(PWRK002.CNL_YN, ''N'') =  ''' || V_CNL_YN || '''';
	        	END IF;
	
	        	V_SQL := V_SQL || ' ORDER BY PWRK002.PRD_DT,PWRK002.IND_BCD';
	
	        IF (V_DEBUG = 'Y') THEN
	        	INSERT INTO PROC_LOG (SQL_STR) VALUES (V_SQL);
	        END IF;
	
			OPEN P_RS_LIST FOR V_SQL;
		END IF;
	
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
		RAISE_APPLICATION_ERROR(-20001, E_SQL_ERR_MSG);
END SP_WRK28_S12;

/
