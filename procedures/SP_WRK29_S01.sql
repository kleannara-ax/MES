
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_WRK29_S01" (
	P_TYPE           IN    varchar2, -- LIST, SAVE
	P_JSON_STR       IN    CLOB,
	P_SUCCESS       OUT    varchar2,
	P_RS_LIST       OUT    SYS_REFCURSOR 
)
/*==============================================================================
 * PROGRAM ID    : SP_WRK29_S01
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
		V_SQL :='SELECT A.MATNR              AS MATNR               --자재코드 (추가)
                    , A.MATNR_NM          AS MATNR_NM            --자재명 (추가)
                    , A.IND_BCD              AS IND_BCD             -- BARCODE -> IND_BCD(개별바코드) (변경)
                    , A.LOT_NO               AS LOT_NO              --LOT ID -> LOT_NO (LOT번호) (변경)
                    , SUBSTR(A.MATNR, 3, 3)  AS PCODE       --지종
                    , SUBSTR(A.MATNR, 6, 3)  AS BS_WGT      --평량
                    , TO_NUMBER(A.WLEN)     AS WLEN                                --가로길이
                    , TO_NUMBER(A.VLEN)     AS VLEN                               --세로길이
                    , A.SPEC                 AS MATNR_SPEC  --규격
                    --, FN_CD_VAL(''PACK_TYPE'', DECODE(SUBSTR(A.IND_BCD, 6, 1), ''Q'', SUBSTR(A.MATNR, -1), A.PACKTYPE)) AS PACKTYPE     --포장방법
                    , FN_CD_VAL(''PACK_TYPE'', SUBSTR(A.MATNR, -1)) AS PACKTYPE     --포장방법
                    , A.PRFM_QTY             AS PCNT     --연수
                    , A.RUNIT                            --연수단위
                    , A.WGT                             --중량   (추가) 
                    , A.WUNIT                           --중량단위 (추가)         
                    , DECODE(SUBSTR(A.VBELN, 1, 2), ''00'', SUBSTR(A.VBELN, 3, 8),A.VBELN)      AS VBELN    --판매문서번호
                    , A.ROUTE                           --항차
                    , A.PRFM_DT             AS PRD_DT   --생산일자
                    , ''PM'' || SUBSTR(MATNR, 2, 1)   AS MACHINE  --호기
                    --, A.MACHINE                         --호기
                    , CASE WHEN SUBSTR(A.IND_BCD, 6, 1) IN (''M'', ''S'') THEN NULL 
                           WHEN SUBSTR(A.IND_BCD, 6, 1) IN (''Q'') THEN (SELECT FN_LOT_TRK(IND_BCD_M, 1) FROM TB_WRK010 WHERE IND_BCD = A.IND_BCD AND ROWNUM = 1)
                           WHEN SUBSTR(A.IND_BCD, 6, 1) IN (''Z'') THEN FN_LOT_TRK(A.IND_BCD, 2)
                           ELSE FN_LOT_TRK(A.IND_BCD, 1) END   AS CJOB_IND_BCD    
                    , CASE WHEN SUBSTR(A.IND_BCD, 6, 1) = ''M'' THEN A.LOT_NO
                           WHEN SUBSTR(A.IND_BCD, 6, 1) = ''S'' THEN FN_LOT_TRK(A.IND_BCD, 1)
                           WHEN SUBSTR(A.IND_BCD, 6, 1) IN (''Q'') 
                                 THEN DECODE(SUBSTR((SELECT FN_LOT_TRK(IND_BCD_M, 2) FROM TB_WRK010 WHERE IND_BCD = A.IND_BCD AND ROWNUM = 1), 5, 1)
                                            , ''M'', (SELECT FN_LOT_TRK(IND_BCD_M, 2) FROM TB_WRK010 WHERE IND_BCD = A.IND_BCD AND ROWNUM = 1)
                                            , ''C'', (SELECT FN_LOT_TRK(IND_BCD_M, 3) FROM TB_WRK010 WHERE IND_BCD = A.IND_BCD AND ROWNUM = 1))
                           ELSE DECODE(SUBSTR(FN_LOT_TRK(A.IND_BCD, 2), 5, 1)
                                      , ''C'', FN_LOT_TRK(A.IND_BCD, 3)
                                      , FN_LOT_TRK(A.IND_BCD, 2)) END   AS MJOB_IND_BCD    
                    , CASE WHEN SUBSTR(A.IND_BCD, 6, 1) = ''M'' THEN FN_LOT_TRK(A.IND_BCD, 1)
                           WHEN SUBSTR(A.IND_BCD, 6, 1) = ''S'' THEN FN_LOT_TRK(A.IND_BCD, 2)
                           WHEN SUBSTR(A.IND_BCD, 6, 1) IN (''Q'') 
                                THEN DECODE(SUBSTR((SELECT FN_LOT_TRK(IND_BCD_M, 3) FROM TB_WRK010 WHERE IND_BCD = A.IND_BCD AND ROWNUM = 1), 5, 1)
                                     , ''J'', (SELECT FN_LOT_TRK(IND_BCD_M, 3) FROM TB_WRK010 WHERE IND_BCD = A.IND_BCD AND ROWNUM = 1)
                                     , ''M'', (SELECT FN_LOT_TRK(IND_BCD_M, 4) FROM TB_WRK010 WHERE IND_BCD = A.IND_BCD AND ROWNUM = 1))
                           ELSE DECODE(SUBSTR(FN_LOT_TRK(A.IND_BCD, 3), 5, 1)
                                      , ''M'', FN_LOT_TRK(A.IND_BCD, 4)
                                      , FN_LOT_TRK(A.IND_BCD, 3)) END   AS JJOB_IND_BCD    
                    , A.ORDER_RMK           AS RMK      --비고
                  FROM(SELECT W002.IND_BCD      AS IND_BCD
                            , W002.LOT_NO       AS LOT_NO    
                            , W002.MATNR
                            , M001.MATNR_NM
                            , SUBSTR(W002.MATNR, 10, 4) AS WLEN
                            , SUBSTR(W002.MATNR, 14, 4) AS VLEN
                            , TO_CHAR(TO_NUMBER(SUBSTR(W002.MATNR, 10, 4))) || ''*'' || TO_CHAR(TO_NUMBER(SUBSTR(W002.MATNR, 14, 4))) AS SPEC
                            , S018.PACKTYPE     AS PACKTYPE
                            , W002.PRFM_QTY     AS PRFM_QTY     --연수
                            , ''R''               AS RUNIT        --연수단위
                            , W002.WGT          AS WGT          --중량    
                            , ''KG''              AS WUNIT        --중량단위
                            , W002.VBELN        AS VBELN        --판매문서번호
                            , S018.ROUTE        AS ROUTE        --항차
                            , W002.PRFM_DT      AS PRFM_DT      --생산일자
                            , W002.MACHINE      AS MACHINE      --호기
                            , s018.ORDER_RMK    AS ORDER_RMK    --비고
                          FROM TB_WRK002 W002
                          LEFT JOIN TB_SCH018 S018
                          ON W002.WRK_ORDR_NO = S018.WRK_ORDR_NO
                          AND W002.WRK_ORDR_SEQNO = S018.WRK_ORDR_SEQNO
                          INNER JOIN TB_MAS001 M001
                          ON W002.WERKS = M001.WERKS
                          AND W002.MATNR = M001.MATNR
                         WHERE W002.WERKS = ''P100''
                           AND W002.MACH_CD IN (SELECT MACH_CD FROM TB_MAS012 WHERE PROC_CD IN (''PB'', ''PC'', ''ZA''))
                           AND NVL(W002.CNL_YN, ''N'') = ''N''
                           AND NVL(W002.PRFM_GTHR_YN, ''Y'') = ''Y'' ';
            
            IF (V_RANGE_SQL IS NOT NULL OR TRIM(V_RANGE_SQL) != '') THEN               --실적일자
                V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'PRFM_DT', 'W002.PRFM_DT');
                V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'BS_WGT', 'M001.BS_WGT');
                V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'WLEN', 'TO_CHAR(TO_NUMBER(SUBSTR(W002.MATNR, 10, 4)))');
                V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'VLEN', 'TO_CHAR(TO_NUMBER(SUBSTR(W002.MATNR, 14, 4)))');
                V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'PCODE', 'M001.PCODE');
                
                V_SQL := V_SQL || V_RANGE_SQL; 
            END IF;   
            
            IF (V_MACHINE IS NOT NULL OR TRIM(V_MACHINE) != '') THEN                   --설비코드(호기)
                IF TRIM(V_MACHINE) = 'PM2' OR TRIM(V_MACHINE) = 'PM3' THEN
                    V_SQL := V_SQL || ' AND SUBSTR(W002.MATNR, 2, 1) = ''' || SUBSTR(V_MACHINE, -1) || '''';            				      
                ELSE
                    V_SQL := V_SQL || ' AND W002.MACHINE = ''' || V_MACHINE || '''';            				      
                END IF;    
            END IF;                           
            
            V_SQL := V_SQL || ' UNION ALL
                                SELECT W002.IND_BCD         AS IND_BCD
                                    , W002.LOT_NO           AS LOT_NO
                                    , W002.MATNR
                                    , M001.MATNR_NM
                                    , SUBSTR(W002.MATNR, 10, 4) AS WLEN
                                    , NULL                      AS VLEN
                                    , SUBSTR(W002.MATNR, 10, 4) || ''*'' || SUBSTR(W002.MATNR, 14, 4) AS SPEC
                                    , NULL              AS PACKTYPE     --포장방법
                                    , NULL              AS PRFM_QTY     --연수
                                    , ''R''               AS RUNIT        --연수단위
                                    , W002.PRFM_QTY     AS WGT          --중량    
                                    , ''KG''              AS WUNIT        --중량단위
                                    , W002.VBELN        AS VBELN        --판매문서번호
                                    , S016.ROUTE        AS ROUTE        --항차
                                    , W002.PRFM_DT      AS PRFM_DT      --생산일자
                                    , W002.MACHINE      AS MACHINE       --호기
                                    , S016.ORDER_RMK    AS ORDER_RMK    --비고
                                  FROM TB_WRK002 W002
                                  LEFT JOIN TB_SCH016 S016
                                  ON W002.WRK_ORDR_NO = S016.WRK_ORDR_NO
                                  AND W002.WRK_ORDR_SEQNO = S016.WRK_ORDR_SEQNO
                                  INNER JOIN TB_MAS001 M001
                                  ON W002.WERKS = M001.WERKS
                                  AND W002.MATNR = M001.MATNR
                                 WHERE W002.WERKS = ''P100''
                                   AND W002.MACH_CD IN (SELECT MACH_CD FROM TB_MAS012 WHERE PROC_CD IN (''MA'', ''SA''))
                                   AND NVL(W002.CNL_YN, ''N'') = ''N''
                                   AND NVL(W002.PRFM_GTHR_YN, ''Y'') = ''Y''
                                   AND ((SUBSTR(W002.IND_BCD, 6, 1) = ''M'' AND S016.SHEET = ''-'' AND S016.SLITER IS NULL)
                                       OR (SUBSTR(W002.IND_BCD, 6, 1) = ''S'' AND S016.SLITER = ''X'')) ';
                                       
            IF (V_RANGE_SQL IS NOT NULL OR TRIM(V_RANGE_SQL) != '') THEN               --실적일자
--                V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'PRFM_DT', 'W002.PRFM_DT');
--                V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'BS_WGT', 'M001.BS_WGT');
--                V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'WLEN', 'TO_CHAR(TO_NUMBER(SUBSTR(W002.MATNR, 10, 4)))');
--                V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'VLEN', 'TO_CHAR(TO_NUMBER(SUBSTR(W002.MATNR, 14, 4)))');
--                V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'PCODE', 'M001.PCODE');
                
                V_SQL := V_SQL || V_RANGE_SQL; 
            END IF;   
            
            IF (V_MACHINE IS NOT NULL OR TRIM(V_MACHINE) != '') THEN                   --설비코드(호기)
                IF TRIM(V_MACHINE) = 'PM2' OR TRIM(V_MACHINE) = 'PM3' THEN
                    V_SQL := V_SQL || ' AND SUBSTR(W002.MATNR, 2, 1) = ''' || SUBSTR(V_MACHINE, -1) || '''';            				      
                ELSE
                    V_SQL := V_SQL || ' AND W002.MACHINE = ''' || V_MACHINE || '''';            				      
                END IF;   
                --V_SQL := V_SQL || ' AND W002.MACHINE = ''' || V_MACHINE || '''';            				      
            END IF;                                              

            V_SQL := V_SQL || '   ) A 
                                ORDER BY A.PRFM_DT, A.IND_BCD';
            
        V_DEBUG := 'Y';
        
        IF (V_DEBUG = 'Y') THEN
            INSERT INTO PROC_LOG (SQL_STR) VALUES (V_SQL);
            COMMIT;
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
