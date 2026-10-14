
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
        
        V_SQL :='SELECT CASE WHEN ORDR.ORDER_DIV = ''ZP12'' THEN ''수재단 예외생산''
                            WHEN ORDR.ORDER_DIV = ''ZP13'' THEN ''포장 예외생산''
                            WHEN ORDR.ORDER_DIV = ''ZP14'' THEN ''슬리터 예외생산''
                            WHEN ORDR.ORDER_DIV = ''ZP11'' AND SUBSTR(W002.WRK_ORDR_NO, 1, 4) = ''WOMA'' THEN ''슬리터''
                            ELSE ''수재단'' END  AS FILD31       --구분
                    , W002.PRFM_DT                         --실적일자
                    , W002.MACH_CD                         --설비코드
                    , M012.MACH_NM                          --설비명
                    , W002.MATNR
                    , M001.MATNR_NM
                    , DECODE(SUBSTR(W002.MATNR, 5, 1), ''2'', ''수출'', ''내수'')   AS	INOUT_DIV		--내수/수출 --변경
                    , M001.PCODE
                    , M001.PCODE_NM                     --지종명
                    , M001.BS_WGT
                    , TO_CHAR(TO_NUMBER(SUBSTR(W002.MATNR, 10, 4)))         AS WLEN     --가로길이
                    , DECODE(TO_NUMBER(SUBSTR(W002.MATNR, 14, 4)),0, NULL,TO_CHAR(TO_NUMBER(SUBSTR(W002.MATNR, 14, 4)))) AS VLEN     --세로길이
                    , TO_CHAR(TO_NUMBER(SUBSTR(W002.MATNR, 10, 4)))         AS WIDTH     --실지폭
                    , ORDR.COMP_YN              AS COMP_YN      --작업상태
                    , ORDR.KUNNR_NM             AS KUNNRT       --거래처명
                    , FN_CD_VAL(''NTN_CD'', (SELECT LAND1 FROM TB_MAS009 WHERE CUST_DIV = ''C'' AND CUST_CD = ORDR.KUNNR)) AS KUNNR_NM
                    , W002.LOT_NO
                    , W002.IND_BCD
                    , W002.ROLLCNT                  --권치수
                    , ''M''          AS ROLLUNIT     --권치수 단위
                    , W002.PCNT                     --연수
                    , ''R''           AS RUNIT     --연수 단위
                    , W002.WGT                      --중량
                    , ''KG''           AS WUNIT     --중량 단위
                    , W002.DISPO_CD                 --폐품코드
                    , W002.DISPO_ROLLCNT            --폐품권치수
                    , ''M''           AS DISPO_ROLLUNIT     --폐품권치수 단위
                    , W002.DISPO_PCNT               --폐품연수
                    , ''R''           AS DISPO_RUNIT  --폐품연수 단위
                    , W002.DISPO_WGT                --폐품중량
                    , ''KG''           AS DISPO_WUNIT  --폐품중량 단위
                    , W002.TM                        --생산시간(분)
                    , W002.CORE                      --지관
                    , W002.SCNT                      --속당매수/속수
                    , W002.PLT_QTY                  --팔레트당연수
                    , DECODE(ORDR.PACKTYPE, ''A'', ''자동포장'', ''B'', ''SF포장'') AS PACKTYPE                 --포장방법
                    , ORDR.VBELN                     --판매문서번호
                    , ORDR.POSNR                     --판매문서품목번호
                    , ORDR.ORDER_RMK       AS	ORDER_RMK	--지시사항
                    , W002.SDOC_NO                  --SAP 확정문서번호
                    , W002.SDOC_SEQNO               --SAP 확정문서번호순번
                    , W002.CNL_YN                   --취소여부
                  FROM(
                        SELECT WERKS, MACH_CD, MATNR, LOT_NO, IND_BCD, PRD_NO, PRFM_DT
                            , CORE, WIDTH, DECODE(NVL(PCNT, 0), 0, NULL, DECODE(MCNT, NULL, NULL, MCNT || ''/'' || SCNT)) AS SCNT, NVL(PCNT, NULL) AS PLT_QTY 
                            , NVL(ROLLCNT, 0) AS ROLLCNT, NVL(PCNT, 0) AS PCNT, WGT
                            , NULL AS DISPO_CD, 0 AS DISPO_ROLLCNT, 0 AS DISPO_PCNT, 0 AS DISPO_WGT
                            , WRK_ORDR_NO, WRK_ORDR_SEQNO, NVL(CNL_YN, ''N'') AS CNL_YN, SDOC_NO, SDOC_SEQNO, NVL(TM, 0) AS TM
                          FROM TB_WRK002
                         WHERE WERKS = ''P100''
                           AND MACH_CD IN (SELECT MACH_CD FROM TB_MAS012 WHERE PROC_CD IN (''SA'', ''CB''))
                        UNION
                        SELECT WERKS, MACH_CD, MATNR, LOT_NO, IND_BCD, NULL AS PRD_NO, PRFM_DT
                            , NULL AS CORE, NULL AS WIDTH, NULL AS SCNT, NULL AS PLT_QTY 
                            , 0 AS ROLLCNT, 0 AS PCNT, 0 AS WGT
                            , DISPO_CD, DECODE(UNIT, ''KG'', NVL(ROLLCNT, 0), 0) AS DISPO_ROLLCNT, DECODE(UNIT, ''KG'', 0, DISPO_QTY) AS DISPO_PCNT, NVL(WGT, 0) AS DISPO_WGT
                            , WRK_ORDR_NO, WRK_ORDR_SEQNO, NVL(CNL_YN, ''N'') AS CNL_YN, SDOC_NO, SDOC_SEQNO, NVL(TM, 0) AS TM
                          FROM TB_WRK004
                         WHERE WERKS = ''P100''
                           AND MACH_CD IN (SELECT MACH_CD FROM TB_MAS012 WHERE PROC_CD IN (''SA'', ''CB''))
                        UNION
                        SELECT WERKS, MACH_CD, MATNR, LOT_NO, IND_BCD, NULL AS PRD_NO, PRFM_DT
                            , NULL AS CORE, NULL AS WIDTH, NULL AS SCNT, NULL AS PLT_QTY 
                            , 0 AS ROLLCNT, 0 AS PCNT, 0 AS WGT
--                            , DISPO_CD, DECODE(SUBSTR(IND_BCD, 6, 1), ''S'', NVL(ROLLCNT, 0), 0) AS DISPO_ROLLCNT
                            , DISPO_CD, DECODE(SUBSTR(IND_BCD, 6, 1), ''S'', ROUND((WGT / (TO_NUMBER(SUBSTR(MATNR, 10, 4)) / 1000 * TO_NUMBER(SUBSTR(MATNR, 6, 3)) / 1000)), 3), 0) AS DISPO_ROLLCNT
                            , DECODE(SUBSTR(IND_BCD, 6, 1), ''S'',0 , ROUND((WGT / (TO_NUMBER(SUBSTR(MATNR, 10, 4)) / 1000 * TO_NUMBER(SUBSTR(MATNR, 14, 4)) / 1000 * TO_NUMBER(SUBSTR(MATNR, 6, 3)) / 1000)) / 500, 3)) AS DISPO_PCNT
                            , NVL(WGT, 0) AS DISPO_WGT
                            , WRK_ORDR_NO, WRK_ORDR_SEQNO, NVL(CNL_YN, ''N'') AS CNL_YN, SDOC_NO, SDOC_SEQNO, NVL(TM, 0) AS TM
                          FROM TB_WRK022
                         WHERE WERKS = ''P100''
                           AND MACH_CD IN (SELECT MACH_CD FROM TB_MAS012 WHERE PROC_CD IN (''SA'', ''CB''))
                        ) W002
                  INNER JOIN TB_MAS001 M001
                  ON W002.WERKS = M001.WERKS
                  AND W002.MATNR = M001.MATNR
                  LEFT JOIN V_WRK_ORDR ORDR
                  ON W002.WRK_ORDR_NO = ORDR.WRK_ORDR_NO
                  AND W002.WRK_ORDR_SEQNO = ORDR.WRK_ORDR_SEQNO
                  LEFT JOIN TB_MAS012 M012
                  ON W002.MACH_CD = M012.MACH_CD
                 WHERE 1=1 ';
                 
        IF (V_RANGE_SQL IS NOT NULL OR TRIM(V_RANGE_SQL) != '') THEN               --실적일자
        	V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'MAS012', 'M012');
            V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'WRK002', 'W002');
            V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'PCODE', 'M001.PCODE');
            V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'BS_WGT', 'M001.BS_WGT');
            V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'W002.WLEN', 'TO_CHAR(TO_NUMBER(SUBSTR(W002.MATNR, 10, 4)))');
            V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'W002.VLEN', 'TO_CHAR(TO_NUMBER(SUBSTR(W002.MATNR, 14, 4)))');
            
            V_SQL := V_SQL || V_RANGE_SQL; 
      	END IF;         
        
        IF (V_INOUT_GU IS NOT NULL OR TRIM(V_INOUT_GU) != '') THEN 
		    IF V_INOUT_GU = 'E' THEN
			    V_SQL := V_SQL ||' AND W002.WRK_ORDR_NO LIKE ''WOEX%''||''%''  ' ;  
		    ELSIF V_INOUT_GU = 'N' THEN
		        V_SQL := V_SQL ||' AND W002.WRK_ORDR_NO NOT LIKE ''WOEX%''||''%''  ' ;
		    END IF;
		END IF;
	  
      	V_SQL := V_SQL || ' AND NVL(W002.CNL_YN, ''N'') =  ''' || V_CNL_YN || '''';

      	V_SQL := V_SQL || ' ORDER BY W002.MACH_CD, W002.PRFM_DT, W002.IND_BCD';
        
        V_DEBUG := 'Y';
            
        IF (V_DEBUG = 'Y') THEN
            INSERT INTO PROC_LOG (SQL_STR) VALUES (V_SQL);
        END IF;
        
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
