
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_WRK33_S01" (
	P_TYPE         IN    varchar2, -- LIST, SUB_LIST-A, SUB_LIST-B
	P_JSON_STR     IN    CLOB,
	P_SUCCESS      OUT   varchar2,
	P_RS_LIST      OUT   SYS_REFCURSOR 
)
/*==============================================================================
 * PROGRAM ID    : SP_WRK33_S01{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 판매문서 조회 {호출 프로그램 명 기술}
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 재공조회(호기 및 각 공정별 재공재고 정보 조회) {프로그램에 대한 상세한 내용 기술}
 *                 
 * AUTHOR NAME   : 박성철{최초 작성자 명 기술}
 * CREATE DATE   : 2022/07/22 {최초 작성일자 기술}
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * yyyy/mm/dd    1.0.0   박성철         Initial Version 
 *==============================================================================
 *  관련 테이블 - 모든 테이블 조회만 함
 *=============================================================================*/

AS

    V_PRG_NM          VARCHAR2(100)  := 'SP_WRK33_S01';     -- PROCEDURE NAME


    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5)           := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);

    -- JSON을 위한 변수선언 영역
    V_JSON           JSON_OBJECT_T;
    V_ARR_LIST       JSON_ARRAY_T;
    V_ARR_HEAD       JSON_ARRAY_T;
    V_OBJ            JSON_OBJECT_T;

    -- 세션값 처리용 변수선언 영역
    V_SQL            CLOB;
    V_RUN_SQL        varchar2(1);
    V_RANGE_SQL      varchar2(4000);
    V_DEBUG          varchar2(1);

    -- 세션값 처리용 변수선언 영역
    V_PLT_CD         varchar2(2);
    V_SESS_USER_ID   varchar2(20);

    -- 조건절 처리용 변수선언 영역
    V_VBELN			TB_WRK002.VBELN%TYPE;			-- 판매문서번호
    V_POSNR			TB_WRK002.POSNR%TYPE;			-- 판매문서번호순번

    V_WERKS			TB_WRK002.WERKS%TYPE;			-- 플랜트
    V_MACH_CD		TB_WRK002.MACH_CD%TYPE;			-- 설비코드
    V_PROC_NM       VARCHAR2(100);
    V_PRFM_DT       VARCHAR2(10);
    V_MATNR         VARCHAR2(20);
    -- 리스트(그리드)의 값을 할당하기 위한 변수선언 영역
BEGIN
    OPEN P_RS_LIST FOR 

    SELECT NULL FROM DUAL WHERE ROWNUM = 0;

    V_DEBUG := 'N';
    V_RUN_SQL := 'Y';

    V_JSON := JSON_OBJECT_T.parse(P_JSON_STR);

    V_SESS_USER_ID       :=      V_JSON.get_string('SES_USER_ID');
    V_PLT_CD             :=      V_JSON.get_string('SES_PLNTKY');

    /* 조건값 할당 */
   V_RANGE_SQL         :=      V_JSON.get_string('RANGE_SQL');

    V_VBELN			 	 := 		V_JSON.get_string('VBELN');		-- 판매문서번호  
    V_POSNR			 	 := 		V_JSON.get_string('OPOSNR');	-- 판매문서번호순번

    V_WERKS			 	 := 		V_JSON.get_string('WERKS');		-- 플랜트  
    V_MACH_CD			 := 		V_JSON.get_string('MACH_CD');	-- 설비코드
    V_PROC_NM            := 		V_JSON.get_string('PROC_NM');	-- 공정명
    V_PRFM_DT            := 		V_JSON.get_string('PRFM_DT');	-- 공정명
    V_MATNR              := 		V_JSON.get_string('MATNR');	-- 공정명
    
    IF P_TYPE = 'LIST' THEN /*좌측 메인 그리드*/
        V_SQL := 'SELECT A.WERKS
                    , A.VBELN                                   --판매문서번호  (추가)
                    , A.POSNR                                   --판매문서 품목 (추가)
                    , M013.PROC_NM                              --공정명
                    , A.PRFM_DT                                 --실적일자
                    , A.PRD_ROLLCNT         AS ROLLCNT          --권치수
                    , ''M''                   AS ROLLUNIT         --권치수 단위
                    , A.PRD_RQTY            AS PCNT             --연수
                    , ''R''                   AS RUNIT            --연수단위
                    , A.PRD_WGT             AS WGT              --중량
                    , ''KG''                  AS WUNIT            --중량단위
                    , A.DISPO_ROLLCNT               --폐품권치수
                    , ''M''                   AS DIROLLUNIT        --폐품권치수단위
                    , A.DISPO_RQTY          AS DISPO_PCNT        --폐품연수
                    , ''R''                   AS DISPO_RUNIT        --폐품연수단위
                    , DISPO_WGT                     --폐품중량
                    , ''KG''                  AS DISPO_WUNIT        --폐품중량단위
                    , A.MATNR                       --자재코드
                    , M001.PCODE                    --지종
                    , M001.BS_WGT                    --평량
                    , TO_CHAR(TO_NUMBER(SUBSTR(A.MATNR, 10, 4))) || ''*'' || DECODE(TO_NUMBER(SUBSTR(A.MATNR, 14, 4)), 0, ''0000'', TO_CHAR(TO_NUMBER(SUBSTR(A.MATNR, 14, 4))))  AS SPEC      --SIZE(SIZE) -> SPEC(규격) 변경
                    , A.KUNNR_NM            AS CUST_NM  --거래처명
                    , A.ROUTE                            --항차
                  FROM(
                        SELECT WRK000.WERKS, WRK000.PRFM_DT, WRK000.MATNR, WRK000.PROC_CD
                            , SUM(NVL(WRK000.PRD_ROLLCNT, 0)) AS PRD_ROLLCNT, SUM(NVL(WRK000.PRD_RQTY, 0)) AS PRD_RQTY, SUM(NVL(WRK000.PRD_WGT, 0)) AS PRD_WGT
                            , SUM(NVL(WRK000.DISPO_ROLLCNT, 0)) AS DISPO_ROLLCNT, SUM(NVL(WRK000.DISPO_RQTY, 0)) AS DISPO_RQTY, SUM(NVL(WRK000.DISPO_WGT, 0)) AS DISPO_WGT
                            , ORDR.VBELN, ORDR.POSNR, ORDR.ROUTE, ORDR.KUNNR_NM
                          FROM(
                                SELECT W000.WERKS, W000.PRFM_DT, W000.MATNR, M012.PROC_CD, W000.WRK_ORDR_NO, W000.WRK_ORDR_SEQNO      
                                    , SUM(NVL(W000.PRD_ROLLCNT, 0)) AS PRD_ROLLCNT, SUM(NVL(W000.PRD_RQTY, 0)) AS PRD_RQTY, SUM(NVL(W000.PRD_WGT, 0)) AS PRD_WGT
                                    , SUM(NVL(W000.DISPO_ROLLCNT, 0)) AS DISPO_ROLLCNT, SUM(NVL(W000.DISPO_RQTY, 0)) AS DISPO_RQTY, SUM(NVL(W000.DISPO_WGT, 0)) AS DISPO_WGT
                                  FROM(
                                        SELECT WERKS, PRFM_DT, MATNR, MACH_CD, WRK_ORDR_NO, WRK_ORDR_SEQNO
                                            , ROLLCNT AS PRD_ROLLCNT , DECODE(UNIT, ''KG'', NULL, ''EA'', ROUND(PRFM_QTY/ 500, 1), ''R'', PRFM_QTY) AS PRD_RQTY, WGT AS PRD_WGT
                                            , NULL AS DISPO_ROLLCNT, NULL AS DISPO_RQTY, NULL AS DISPO_WGT
                                          FROM TB_WRK002
                                         WHERE NVL(CNL_YN, ''N'') = ''N''
                                        UNION ALL
                                        SELECT WERKS, PRFM_DT, MATNR, MACH_CD, WRK_ORDR_NO, WRK_ORDR_SEQNO
                                            , NULL AS PRD_ROLLCNT , NULL AS PRD_RQTY, NULL AS PRD_WGT
                                            , ROLLCNT AS DISPO_ROLLCNT, DECODE(UNIT, ''KG'', NULL, ''EA'', ROUND(DISPO_QTY/ 500, 1), ''R'', DISPO_QTY) AS DISPO_RQTY, WGT AS DISPO_WGT
                                          FROM TB_WRK004
                                         WHERE NVL(CNL_YN, ''N'') = ''N'' 
                                        UNION ALL
                                        SELECT W002.WERKS, W002.PRFM_DT, W002.MATNR, W002.MACH_CD, W002.WRK_ORDR_NO, W002.WRK_ORDR_SEQNO
                                            , NULL AS PRD_ROLLCNT , NULL AS PRD_RQTY, NULL AS PRD_WGT
                                            , CASE WHEN SUBSTR(IND_BCD, 6, 1) IN (''M'', ''S'') 
                                                   THEN (SELECT ROUND(W002.WGT * (WGT / ROLLCNT))
                                                           FROM TB_WRK002
                                                          WHERE WERKS = W002.WERKS
                                                            AND IND_BCD = W002.IND_BCD) 
                                                ELSE NULL END AS DISPO_ROLLCNT
                                            --, ROLLCNT AS DISPO_ROLLCNT
                                            , DECODE(SUBSTR(W002.LOT_NO, 5, 1), ''M'', NULL, ''S'', NULL
                                                    , ''C'', ROUND((W002.WGT / (TO_NUMBER(SUBSTR(W002.MATNR, 10, 4)) / 1000 * TO_NUMBER(SUBSTR(W002.MATNR, 14, 4)) / 1000 * TO_NUMBER(SUBSTR(W002.MATNR, 6, 3)) / 1000)) / 500, 2)
                                                    , W002.DISPO_QTY) AS DISPO_RQTY
                                            , WGT AS DISPO_WGT
                                          FROM TB_WRK022 W002
                                         WHERE NVL(W002.CNL_YN, ''N'') = ''N'' 
                                     ) W000   
                                     LEFT JOIN TB_MAS012 M012
                                     ON W000.MACH_CD = M012.MACH_CD
                                GROUP BY W000.WERKS, W000.PRFM_DT, W000.MATNR, M012.PROC_CD, W000.WRK_ORDR_NO, W000.WRK_ORDR_SEQNO 
                             ) WRK000
                             LEFT JOIN V_WRK_ORDR ORDR
                             ON WRK000.WRK_ORDR_NO = ORDR.WRK_ORDR_NO
                             AND WRK000.WRK_ORDR_SEQNO = ORDR.WRK_ORDR_SEQNO
                         GROUP BY WRK000.WERKS, WRK000.PRFM_DT, WRK000.MATNR, WRK000.PROC_CD, ORDR.VBELN, ORDR.POSNR, ORDR.ROUTE, ORDR.KUNNR_NM
                      ) A 
                      LEFT JOIN TB_MAS013 M013
                      ON A.PROC_CD = M013.PROC_CD
                      LEFT JOIN TB_MAS001 M001
                      ON A.WERKS = M001.WERKS
                      AND A.MATNR = M001.MATNR
                   WHERE 1=1 ';
              
        IF V_VBELN IS NOT NULL OR TRIM(V_VBELN) != '' THEN
            V_SQL := V_SQL || ' AND A.VBELN = ''' || V_VBELN || '''';
        END IF;      
        
        IF V_RANGE_SQL IS NOT NULL OR TRIM(V_RANGE_SQL) != '' THEN
			V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'VBELN', 'A.VBELN');	--자재코드
			
            V_SQL := V_SQL || V_RANGE_SQL;
        END IF;      
        
        V_SQL := V_SQL || ' ORDER BY A.VBELN, M013.DISP_SEQ, A.PRFM_DT';  

--        V_SQL :=  ' SELECT 
--							       MAS013.PROC_NM   --공정명
--							     , MAS001.PCODE    --지종코드	
--							     --, MAS001.PCODE_NM --지종명	
--							     , MAS001.BS_WGT   --평량	
--							     , 	CASE WHEN BASE.WLEN IS NULL AND BASE.VLEN IS NULL THEN NULL
--							             ELSE BASE.WLEN || '' * '' || BASE.VLEN END "SIZE"
--							     , MAS009.CUST_NM
--							     , COALESCE(SCH016.ROUTE, SCH017.ROUTE, SCH018.ROUTE) ROUTE --항차
--							     --, MAS012.MACH_CD
--							--     , MAS012.MACH_NM
--							     , BASE.*
--							  FROM (
--								SELECT 
--								       WRK002.MACH_CD   --설비코드
--								     , WRK002.PRFM_DT   --실적일자 
--								     , SUM(WRK002.ROLLCNT) ROLLCNT  --SM_RLCNT          --권치수
--									 , ''M''				ROLLUNIT 			
--								     , SUM(WRK002.PCNT)    PCNT     --SM_PCNT           --연수
--									 , ''R''				RUNIT 		
--								     , SUM(WRK002.WGT)     WGT      --SM_WGT            --중량
-- 									 , ''KG''			 	WUNIT 		
--								     , SUM(WRK004.ROLLCNT)   DISPO_ROLLCNT   --SM_SCRP_RLCNT     --폐품권치수
--									 , ''M''				DIROLLUNIT 		
--								     , SUM(WRK004.DISPO_QTY) DISPO_PCNT      --SM_SCRP_DISPO_QTY --폐품수량
--									 , ''R''				DISPO_RUNIT 		
--								     , SUM(WRK004.WGT)       DISPO_WGT       --SM_SCRP_WGT       --폐품중량
--									 , ''KG''			 	DISPO_WUNIT 
--								     , WRK002.MATNR     --자재
--								     , WRK002.WERKS     --플랜트
--							--	     , WRK002.IND_BCD   --개별바코드
--								     , WRK002.WLEN      --가로			
--								     , WRK002.VLEN      --세로
--								     , WRK002.KUNNR     --판매처(거래처)
--								     , WRK002.VBELN     --판매문서번호
--								     , WRK002.POSNR     --판매문서번호순번
--								     , WRK002.WRK_ORDR_NO     --작업지시번호
--								     , WRK002.WRK_ORDR_SEQNO  --작업지시순번
--								  FROM TB_WRK002 WRK002       --실적테이블(PS)
--								  LEFT JOIN TB_WRK004 WRK004  --폐품 실적(PS)
--								    ON WRK004.WERKS = WRK002.WERKS
--								   AND WRK004.MACH_CD = WRK002.MACH_CD
--								   AND WRK004.IND_BCD = WRK002.IND_BCD
--								   AND WRK004.LOT_NO = WRK002.LOT_NO
--								   AND WRK004.MATNR = WRK002.MATNR ';
--
--		/*IF  V_VBELN IS NOT NULL OR TRIM(V_VBELN) != '' THEN 		--판매문서번호
--            V_SQL := V_SQL || ' AND WRK002.VBELN  LIKE ''%' || V_VBELN || '%''';             
--        END IF;								
--
--		IF  V_POSNR IS NOT NULL OR TRIM(V_POSNR) != '' THEN 		--판매문서번호순번
--            V_SQL := V_SQL || ' AND WRK002.POSNR  LIKE ''%' || V_POSNR || '%''';             
--        END IF;*/	
--
--       V_SQL := V_SQL || ' 	 GROUP BY WRK002.MACH_CD
--							        , WRK002.PRFM_DT
--							        , WRK002.MATNR
--							        , WRK002.WERKS
--						--	        , WRK002.IND_BCD
--							        , WRK002.WLEN			
--							        , WRK002.VLEN
--							        , WRK002.KUNNR
--							        , WRK002.VBELN
--							     	, WRK002.POSNR
--							        , WRK002.WRK_ORDR_NO
--							        , WRK002.WRK_ORDR_SEQNO
--						  ) BASE
--						  LEFT JOIN TB_MAS012 MAS012 --설비마스터
--							ON MAS012.MACH_CD = BASE.MACH_CD
--						  LEFT JOIN TB_MAS013 MAS013 --공정마스터
--							ON MAS013.PROC_CD = MAS012.PROC_CD
--						  LEFT JOIN TB_MAS001 MAS001 --자재기준정보
--						    ON MAS001.WERKS = BASE.WERKS
--						   AND MAS001.MATNR = BASE.MATNR
--						  LEFT JOIN TB_MAS009 MAS009 --거래선(업체)마스터
--						    ON MAS009.CUST_DIV = ''C''
--						   AND MAS009.CUST_CD = BASE.KUNNR
--						  LEFT JOIN TB_SCH016 SCH016 --작업지시 밀롤,슬리터
--						    ON SCH016.WRK_ORDR_NO = BASE.WRK_ORDR_NO
--						   AND SCH016.WRK_ORDR_SEQNO = BASE.WRK_ORDR_SEQNO
--						  LEFT JOIN TB_SCH017 SCH017 --작업지시 작업지시 재단
--						    ON SCH017.WRK_ORDR_NO = BASE.WRK_ORDR_NO
--						   AND SCH017.WRK_ORDR_SEQNO = BASE.WRK_ORDR_SEQNO
--						  LEFT JOIN TB_SCH018 SCH018 --작업지시 작업지시 포장
--						    ON SCH018.WRK_ORDR_NO = BASE.WRK_ORDR_NO
--						   AND SCH018.WRK_ORDR_SEQNO = BASE.WRK_ORDR_SEQNO
--						WHERE 1=1 ' ;
--					
--		IF V_RANGE_SQL IS NOT NULL OR TRIM(V_RANGE_SQL) != '' THEN
--			V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'MATNR', 'BASE.MATNR');	--자재코드
--			V_SQL := V_SQL || V_RANGE_SQL;
--        END IF;	
--       
--        V_SQL := V_SQL || ' ORDER BY MAS013.PROC_NM, BASE.PRFM_DT ';

        V_DEBUG := 'Y';

        IF (V_DEBUG = 'Y') THEN
            INSERT INTO PROC_LOG(SQL_STR) VALUES (V_SQL);
            COMMIT;
        END IF;

		OPEN P_RS_LIST FOR V_SQL;

	ELSIF P_TYPE = 'SUB_LIST1' THEN
        
        V_SQL := 'SELECT W000.WERKS 
                        , M013.PROC_NM                              --공정명
                        , W000.IND_BCD                              --개별바코드
                        , W000.LOT_NO                               --LOT 번호
                        , W000.REGDATE          AS WRK_DATE         --작업일시
                        , FN_CD_VAL(''STCK_STA'', I001.STCK_STA) AS STA  --상태
                        , M012.MACH_NM                              --설비명
                        , NVL(W000.PRD_ROLLCNT, 0) AS ROLLCNT       --권치수
                        , ''M''                   AS ROLLUNIT         --권치수 단위
                        , NVL(W000.PRD_RQTY, 0) AS PCNT             --연수
                        , ''R''                   AS RUNIT            --연수단위
                        , NVL(W000.PRD_WGT, 0)  AS WGT              --중량               
                        , ''KG''                  AS WUNIT          --중량단위
                        , W000.PRFM_DT            AS CREDAT                             --생성일자
                        , (SELECT NMLAST FROM USRMA WHERE USERID = W000.REGID) AS WRKNM   --작업자
                        , NVL(W000.DISPO_ROLLCNT, 0) AS DISPO_ROLLCNT   --폐품권치수
                        , ''M''                   AS DIROLLUNIT        --폐품권치수단위
                        , W000.DISPO_RQTY          AS DISPO_PCNT        --폐품연수
                        , ''R''                   AS DISPO_RUNIT       --폐품연수단위
                        , NVL(W000.DISPO_WGT, 0) AS DISPO_WGT
                        , ''KG''                  AS DISPO_WUNIT        --폐품중량단위
                      FROM(
                            SELECT WERKS, PRFM_DT, IND_BCD, LOT_NO, MATNR, MACH_CD, WRK_ORDR_NO, WRK_ORDR_SEQNO
                                , ROLLCNT AS PRD_ROLLCNT , DECODE(UNIT, ''KG'', NULL, ''EA'', ROUND(PRFM_QTY/ 500, 1), ''R'', PRFM_QTY) AS PRD_RQTY, WGT AS PRD_WGT
                                , NULL AS DISPO_ROLLCNT, NULL AS DISPO_RQTY, NULL AS DISPO_WGT, REGID, REGDATE 
                              FROM TB_WRK002
                             WHERE NVL(CNL_YN, ''N'') = ''N''
                            UNION ALL
                            SELECT WERKS, PRFM_DT, IND_BCD, LOT_NO, MATNR, MACH_CD, WRK_ORDR_NO, WRK_ORDR_SEQNO
                                , NULL AS PRD_ROLLCNT , NULL AS PRD_RQTY, NULL AS PRD_WGT
                                , ROLLCNT AS DISPO_ROLLCNT, DECODE(UNIT, ''KG'', NULL, ''EA'', ROUND(DISPO_QTY/ 500, 1), ''R'', DISPO_QTY) AS DISPO_RQTY, WGT AS DISPO_WGT
                                , REGID, REGDATE
                              FROM TB_WRK004
                             WHERE NVL(CNL_YN, ''N'') = ''N''
                            UNION ALL
                            SELECT W002.WERKS, W002.PRFM_DT, W002.IND_BCD, W002.LOT_NO, W002.MATNR, W002.MACH_CD, W002.WRK_ORDR_NO, W002.WRK_ORDR_SEQNO
                                , NULL AS PRD_ROLLCNT , NULL AS PRD_RQTY, NULL AS PRD_WGT
                                , CASE WHEN SUBSTR(IND_BCD, 6, 1) IN (''M'', ''S'') 
                                                   THEN (SELECT ROUND(W002.WGT * (WGT / ROLLCNT))
                                                           FROM TB_WRK002
                                                          WHERE WERKS = W002.WERKS
                                                            AND IND_BCD = W002.IND_BCD) 
                                                ELSE NULL END AS DISPO_ROLLCNT
                                , DECODE(SUBSTR(W002.LOT_NO, 5, 1), ''M'', NULL, ''S'', NULL
                                                    , ''C'', ROUND((W002.WGT / (TO_NUMBER(SUBSTR(W002.MATNR, 10, 4)) / 1000 * TO_NUMBER(SUBSTR(W002.MATNR, 14, 4)) / 1000 * TO_NUMBER(SUBSTR(W002.MATNR, 6, 3)) / 1000)) / 500, 2)
                                                    , W002.DISPO_QTY) AS DISPO_RQTY
                                --, DECODE(SUBSTR(W002.IND_BCD, 6, 1), ''M'', NULL, ''S'', NULL, ''C'', ROUND(W002.DISPO_QTY/ 500, 2), ''R'', W002.DISPO_QTY) AS DISPO_RQTY
                                , W002.WGT AS DISPO_WGT
                                , W002.REGID, W002.REGDATE
                              FROM TB_WRK022 W002
                             WHERE NVL(W002.CNL_YN, ''N'') = ''N'' 
                         ) W000   
                     LEFT JOIN V_WRK_ORDR ORDR
                     ON W000.WRK_ORDR_NO = ORDR.WRK_ORDR_NO
                     AND W000.WRK_ORDR_SEQNO = ORDR.WRK_ORDR_SEQNO
                     LEFT JOIN TB_MAS012 M012
                     ON W000.MACH_CD = M012.MACH_CD
                     LEFT JOIN TB_MAS013 M013
                     ON M012.PROC_CD = M013.PROC_CD
                     LEFT JOIN TB_INV001 I001
                     ON W000.IND_BCD = I001.IND_BCD
                     WHERE 1=1 ';
        
        IF  V_PROC_NM IS NOT NULL OR TRIM(V_PROC_NM) != '' THEN	   	   
            V_SQL := V_SQL || ' AND M013.PROC_NM = ''' || V_PROC_NM || '''';        
        END IF;
        
        IF  V_PRFM_DT IS NOT NULL OR TRIM(V_PRFM_DT) != '' THEN	   	   
            V_SQL := V_SQL || ' AND W000.PRFM_DT = ''' || V_PRFM_DT || '''';        
        END IF;
        
        IF  V_VBELN IS NOT NULL OR TRIM(V_VBELN) != '' THEN	   	   
            V_SQL := V_SQL || ' AND ORDR.VBELN = ''' || V_VBELN || '''';        
        END IF;
        
        IF  V_POSNR IS NOT NULL OR TRIM(V_POSNR) != '' THEN	   	   
            V_SQL := V_SQL || ' AND ORDR.POSNR = ''' || V_POSNR || '''';        
        END IF;
        
        IF  V_MATNR IS NOT NULL OR TRIM(V_MATNR) != '' THEN	   	   
            V_SQL := V_SQL || ' AND W000.MATNR = ''' || V_MATNR || '''';        
        END IF;
        
        V_SQL := V_SQL || ' ORDER BY W000.MACH_CD, W000.REGDATE ';
        
--        V_SQL :=  ' SELECT MAS013.PROC_NM  --공정명
--					     , WRK002.IND_BCD  --개별바코드
--					     , WRK002.LOT_NO   --LOT_NO
--					     , WRK002.PRFM_DT AS WRK_DATE  --실적일자
--					     --, WRK002.STA      --상태
--					     , FN_CD_VAL(''STATUS'', WRK002.STA) STA --상태명
--					     , MAS012.MACH_NM  --설비명
--					     , WRK002.ROLLCNT  --권치수
--						 , ''M''				ROLLUNIT 		
--					     , WRK002.PCNT     --연수
-- 						 , ''R''				RUNIT 
--					     , WRK002.WGT      --중량
--						 , ''KG''			 	WUNIT
--					     , WRK002.REGDATE AS CREDAT  --생성일
--					     , NVL(USR.NMLAST,'''') AS WRKNM  --작업자
--					     , WRK004.ROLLCNT   AS DISPO_ROLLCNT   --SCRP_RLCNT     --폐품권치수
--						 , ''M''				DIROLLUNIT 	
--					     , WRK004.DISPO_QTY AS DISPO_PCNT      --SCRP_DISPO_QTY --폐품수량
--						 , ''R''				DISPO_RUNIT 
--					     , WRK004.WGT       AS DISPO_WGT       --SCRP_WGT       --폐품중량
--						 , ''KG''			 	DISPO_WUNIT
--					  FROM TB_WRK002 WRK002       --실적테이블(PS)
--					  LEFT JOIN TB_WRK004 WRK004  --폐품 실적(PS)
--					    ON WRK004.WERKS = WRK002.WERKS
--					   AND WRK004.MACH_CD = WRK002.MACH_CD
--					   AND WRK004.IND_BCD = WRK002.IND_BCD
--					   AND WRK004.LOT_NO = WRK002.LOT_NO
--					   AND WRK004.MATNR = WRK002.MATNR
--					  LEFT JOIN TB_MAS012 MAS012 --설비마스터
--						ON MAS012.MACH_CD = WRK002.MACH_CD
--					  LEFT JOIN TB_MAS013 MAS013 --공정마스터
--						ON MAS013.PROC_CD = MAS012.PROC_CD
--					  LEFT JOIN USRMA USR        --사용자
--						ON USR.USERID = WRK002.REGID
--					 WHERE 1=1 ';
--
--
--		IF  V_WERKS IS NOT NULL OR TRIM(V_WERKS) != '' THEN	   	   -- 플랜트
--            V_SQL := V_SQL || ' AND WRK002.WERKS = ''' || V_WERKS || '''';        
--        END IF;
--
--		IF  V_MACH_CD IS NOT NULL OR TRIM(V_MACH_CD) != '' THEN	   -- 설비코드
--            V_SQL := V_SQL || ' AND WRK002.MACH_CD = ''' || V_MACH_CD || '''';        
--        END IF;
--
--
--       V_SQL := V_SQL || ' ORDER BY MAS013.PROC_NM, WRK002.IND_BCD, WRK002.LOT_NO, WRK002.PRFM_DT ';


		V_DEBUG := 'Y';

        IF (V_DEBUG = 'Y') THEN
            INSERT INTO PROC_LOG(SQL_STR) VALUES (V_SQL);
            COMMIT;
        END IF;


    	OPEN P_RS_LIST FOR V_SQL;

    END IF;


    P_SUCCESS := 'Y';


--    EXCEPTION
--    WHEN E_EXCEPTION_USER THEN
--
--        -- 에러 내역 SET
--	    P_SUCCESS           := 'N';
--        E_SQL_ERR_CD        := SQLCODE;
--        E_SQL_ERR_MSG       := SUBSTRB(SQLERRM,1,300);
--
--        ROLLBACK;
--        SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
--
--    WHEN OTHERS THEN
--	    P_SUCCESS           := 'N';
--        E_SQL_ERR_CD        := SQLCODE;
--        E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';
--
--        ROLLBACK;
--        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
END;
/
