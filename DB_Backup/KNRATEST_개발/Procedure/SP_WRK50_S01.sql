--------------------------------------------------------
--  DDL for Procedure SP_WRK50_S01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_WRK50_S01" (
	P_TYPE           IN    VARCHAR2, -- LIST
	P_JSON_STR       IN    CLOB,
    P_DECISION_RTN   IN    VARCHAR2,
	P_SUCCESS       OUT    VARCHAR2,
    P_RS_MSG        OUT    VARCHAR2,
	P_RS_LIST_01    OUT    SYS_REFCURSOR, 
	P_RS_LIST_02    OUT    SYS_REFCURSOR 
)
/*==============================================================================
 * PROGRAM ID    : SP_WRK50_S01
 * PROGRAM NAME  : 재고대사 검증
 * VERSION       : 1.0.0
 * DESCRIPTION   : 재고대사 검증
 *                 
 * AUTHOR NAME   : 김성하
 * CREATE DATE   : 2022/11/01
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}	<생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}		<생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}			<생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}	<생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/11/01    1.0.0   김성하         Initial Version 
 *==============================================================================
 *  관련 테이블
 *=============================================================================*/
AS

  V_PRG_NM          	VARCHAR2(100) 	:= 'SP_WRK50_S01';     -- PROCEDURE NAME

  -- 오라클 에러 처리용 변수선언 영역
  E_EXCEPTION_USER  	EXCEPTION;
  E_SQL_ERR_CD      	NUMBER(5) 		:= 0;
  E_SQL_ERR_MSG		    VARCHAR2(4000);

  -- JSON을 위한 변수선언 영역
  V_JSON		      JSON_OBJECT_T;
  V_ARR_LIST       	  JSON_ARRAY_T;
  V_OBJ            	  JSON_OBJECT_T;

	-- 세션값 처리용 변수선언 영역
  V_SESS_USER_ID   	  varchar2(20);
  V_PLT_CD         	  varchar2(2);
  V_DEBUG          	  varchar2(1);

	-- 조건절 처리용 변수선언 영역	
  V_SQL				CLOB;

  V_WERKS        	TB_INV001.WERKS%TYPE;					                            --플랜트코드	
  V_STOR_LOC_CD   	TB_INV001.STOR_LOC_CD%TYPE;				                            --저장위치	
  V_MATNR        	TB_INV001.MATNR%TYPE;					                            --제품코드	
  V_LOT_NO        	TB_INV001.LOT_NO%TYPE;					                            --LOTNO	

  V_DOC_NO          TB_IFR050.MDOCNO%TYPE;     
  
  V_FROM_PRD_DT		VARCHAR(8);
  V_TO_PRD_DT		VARCHAR(8);
  V_WKDT		    VARCHAR(6);
  V_SAP_DIFF_QTY    NUMBER(9,3);
  V_TOT_CNT         NUMBER(9);
  V_SND_CNT         NUMBER(9);
  V_IND_BCD         VARCHAR(15);
  
BEGIN
	OPEN P_RS_LIST_01 FOR 
	SELECT NULL FROM DUAL WHERE ROWNUM = 0;
    
	OPEN P_RS_LIST_02 FOR 
	SELECT NULL FROM DUAL WHERE ROWNUM = 0;
   
	V_JSON 		    := JSON_OBJECT_T.parse(P_JSON_STR);

	V_SESS_USER_ID	:= V_JSON.get_string('SES_USER_ID');
	V_PLT_CD		:= V_JSON.get_string('SES_PLNTKY');

	V_WERKS			:= V_JSON.get_string('WERKS');			     -- 플랜트코드(필수)	
    V_LOT_NO  	    := V_JSON.get_string('LOT_NO');	             -- LOT_NO (선택)
	V_FROM_PRD_DT	:= V_JSON.get_string('FROM_PRD_DT');	     -- 실적일자 (필수)	
    V_TO_PRD_DT		:= V_JSON.get_string('TO_PRD_DT');	         -- 실적일자 (필수)
    V_STOR_LOC_CD	:= V_JSON.get_string('STOR_LOC_CD');	     -- 저장위치 (선택)
    V_WKDT      	:= V_JSON.get_string('WKDT');	             -- 마감월   (선택)
 
	IF P_TYPE = 'LIST' THEN

            V_SQL := ' 
                                SELECT
                                       A.WERKS                    WERKS           -- 플랜트
                                     , A.STOR_LOC_CD              STOR_LOC_CD     -- 저장위치
                                     , A.LOT_NO                   LOT_NO          -- LOT_NO
                                     , A.MATNR                    MATNR           -- 품목코드
                                     , A.MATNR_NM                 MATNR_NM        -- 품목명
                                     , A.UNIT                     UNIT            -- 단위
                                     , COUNT(A.IND_BCD)           PRFM_CNT        -- 실적건수
                                     , SUM(A.PRFM_QTY)            PRFM_QTY        -- 실적량
                                     , SUM(A.STCK_QTY)            STCK_QTY        -- 재고량
                                     , SUM(A.CNL_PRFM_QTY)        CNL_PRFM_QTY    -- 취소량
                                     , SUM(A.WMS_SUCC_CNT)        WMS_SUCC_CNT    -- WMS성공건수
                                     , SUM(A.WMS_SUCC_QTY)        WMS_SUCC_QTY    -- WMS성공전송
                                     , SUM(A.WMS_FAIL_CNT)        WMS_FAIL_CNT    -- WMS실폐건수
                                     , SUM(A.WMS_FAIL_QTY)        WMS_FAIL_QTY    -- WMS실폐전송
                                     , SUM(NVL(A.WMS_STCK_QTY,0)) WMS_STCK_QTY    -- WMS재고량
--                                     , SUM(A.WMS_ALCT_QTY)        WMS_ALCT_QTY    -- WMS할당량
--                                     , SUM(A.WMS_IN_QTY)          WMS_IN_QTY      -- WMS(IN)수량
--                                     , SUM(A.WMS_OUT_QTY)         WMS_OUT_QTY     -- WMS(OUT)수량
--                                     , SUM(A.WMS_QLT_QTY)         WMS_QLT_QTY     -- WMS품질수량
--                                     , SUM(A.WMS_WAT_QTY)         WMS_WAT_QTY     -- WMS보류수량
--                                     , SUM(A.WMS_UNCM_QTY)        WMS_UNCM_QTY    -- WMS불용수량
--                                     , SUM(A.WMS_PAS_QTY)         WMS_PAS_QTY     -- WMS폐기수량
                                     , SUM(NVL(A.WMS_USE_QTY,0))    WMS_USE_QTY     -- WMS가용수량
                                     , SUM(NVL(A.PRFM_QTY,0)) - SUM(NVL(A.WMS_IN_SUCC,0)) WMS_DIFF_QTY -- WMS재고차이
                                     , SUM(A.SAP_SUCC_CNT)        SAP_SUCC_CNT     -- SAP성공건수
                                     , SUM(A.SAP_SUCC_QTY)        SAP_SUCC_QTY    -- SAP성공전송
                                     , SUM(A.SAP_FAIL_CNT)        SAP_FAIL_CNT    -- SAP실폐건수
                                     , SUM(A.SAP_FAIL_QTY)        SAP_FAIL_QTY    -- SAP실폐전송
                                     , NVL(B.STQTY,0)        SAP_STCK_QTY    -- SAP재고량
                                     , SUM(NVL(A.STCK_QTY, 0)) - NVL(B.STQTY,0) SAP_DIFF_QTY -- SAP재고차이 
--                                     , B.IF_STATUS       -- 수신상태
--                                     , B.IF_GET_DATE     -- 수신일자
--                                     , B.IF_SET_DATE     -- 이관일시
--                                     , B.IF_ERR_MESS     -- 수신오류
--                                     , B.IF_MES_ID       -- MES I/F ID
--                                     , B.IF_RCV_MES_KEY  -- MES 수신 KEY  
--                                     , B.MAKER           -- 처리자
--                                     , B.MBLNR           -- SAP확정문서
--                                     , B.MJAHR           -- SAP확정문서순번
--                                     , B.ZRESULT         -- 전송결과
--                                     , B.ZMESSAGE        -- 전송메시지
--                                     , B.ZRESULT_DATE    -- 전송일시
                                FROM (
                                        SELECT A.PRFM_DT        PRFM_DT          -- 전기일자
                                             , A.WERKS          WERKS           -- 플랜트
                                             , A.STOR_LOC_CD    STOR_LOC_CD     -- 저장위치
                                             , A.LOT_NO         LOT_NO          -- LOT_NO
                                             , B.IND_BCD        IND_BCD         -- 개별바코드
                                             , A.MATNR          MATNR           -- 품목코드
                                             , Z.MATNR_NM       MATNR_NM        -- 품목명
                                             , B.UNIT           UNIT            -- 단위
                                             , A.STCK_QTY       STCK_QTY          ';
                                 
                    IF V_WERKS = 'P100' THEN
                       V_SQL := V_SQL || '   , CASE WHEN NVL(B.CNL_YN, ''N'')  = ''N''  AND SUBSTR(A.LOT_NO, 5, 1)  = ''C'' THEN  B.PCNT
                                                  WHEN NVL(B.CNL_YN, ''N'')  = ''N''  AND SUBSTR(A.LOT_NO, 5, 1) != ''C'' THEN  B.PRFM_QTY
                                                  ELSE                                 0
                                                END             PRFM_QTY        -- 실적량
                                             , CASE WHEN NVL(B.CNL_YN, ''N'')  = ''Y''  AND SUBSTR(A.LOT_NO, 5, 1)  = ''C'' THEN  B.PCNT
                                                  WHEN NVL(B.CNL_YN, ''N'')  = ''Y''  AND SUBSTR(A.LOT_NO, 5, 1) != ''C'' THEN  B.PRFM_QTY
                                                  ELSE                                 0
                                                END             CNL_PRFM_QTY    -- 취소량 ';
                    ELSE
                       V_SQL := V_SQL || ' 
                                            , CASE WHEN NVL(B.CNL_YN, ''N'')  = ''N''   THEN  B.PRFM_QTY
                                                    ELSE                                 0
                                                END             PRFM_QTY        -- 실적량
                                            , CASE WHEN NVL(B.CNL_YN, ''N'')  = ''Y''  THEN  B.PRFM_QTY
                                                    ELSE                                 0
                                                END             CNL_PRFM_QTY    -- 취소량 ';
                    
                    END IF;
                      
                    V_SQL := V_SQL || '    
                                            , CASE WHEN X.W_SUCC > 0  THEN  1
                                                ELSE                                 0
                                                END            WMS_SUCC_CNT     -- WMS성공건수
                                            , CASE WHEN X.W_SUCC > 0 THEN  X.W_SUM
                                                    ELSE                                 0
                                                END            WMS_SUCC_QTY     -- WMS성공전송
                                            , CASE WHEN X.W_FAIL > 0 THEN  1
                                                    ELSE                                 0
                                                END            WMS_FAIL_CNT     -- WMS실폐건수
                                            , CASE WHEN X.W_FAIL > 0 THEN  X.W_SUM
                                                    ELSE                                 0
                                                END            WMS_FAIL_QTY     -- WMS실폐전송
                                            , X.W_IN_SUCC      WMS_IN_SUCC      -- WMS 입고 성공량    
                                            , X.W_3000_SUCC    WMS_3000_SUCC    -- WMS 3000번 재고량
                                            , Y.QTSIWH         WMS_STCK_QTY     -- WMS재고량
                                            , Y.QTSALO         WMS_ALCT_QTY     -- WMS할당량
                                            , Y.QTSPMI         WMS_IN_QTY       -- WMS(IN)수량
                                            , Y.QTSPMO         WMS_OUT_QTY      -- WMS(OUT)수량
                                            , Y.QTSIQT         WMS_QLT_QTY      -- WMS품질수량
                                            , Y.QTSHQT         WMS_WAT_QTY      -- WMS보류수량
                                            , Y.QTSCNU         WMS_UNCM_QTY     -- WMS불용수량
                                            , Y.QTSWQT         WMS_PAS_QTY      -- WMS폐기수량
                                            , Y.USEQTY         WMS_USE_QTY      -- WMS가용수량
                                            , CASE WHEN NVL(B.CNL_YN,''N'')  = ''N'' AND (W.RUECK IS NOT NULL OR W.ZRESULT = ''S'' ) AND W.RUECK != ''E'' THEN  1
                                                    ELSE                                 0
                                                END             SAP_SUCC_CNT    -- SAP성공 건수
                                            , CASE WHEN NVL(B.CNL_YN,''N'')  = ''N'' AND (W.RUECK IS NOT NULL OR W.ZRESULT = ''S'' )  AND W.RUECK != ''E'' THEN  W.SQTY
                                                    ELSE                                 0
                                                END            SAP_SUCC_QTY     -- SAP성공 전송량
                                            , CASE WHEN NVL(B.CNL_YN,''N'')  = ''N'' AND (W.RUECK IS NULL  OR W.ZRESULT = ''E'' ) THEN  1
                                                    ELSE                                 0
                                                END             SAP_FAIL_CNT    -- SAP실폐건수
                                            , CASE WHEN NVL(B.CNL_YN,''N'')  = ''N'' AND (W.RUECK IS NULL OR W.ZRESULT = ''E'' ) THEN  W.SQTY
                                                    ELSE                                 0
                                                END             SAP_FAIL_QTY    -- SAP실폐 전송량
                                          FROM TB_INV001 A ';
 
                    IF V_WERKS = 'P100' THEN
                         V_SQL := V_SQL || ' , TB_WRK002 B ';
                    ELSE
                         V_SQL := V_SQL || ' , TB_WRK001 B ';                   
                    END IF;
                    
                    V_SQL :=      V_SQL || ' , TB_MAS001 Z 
                                             , ( '  ;
                                             
                    IF V_WERKS = 'P100' THEN
                        V_SQL := V_SQL ||     ' SELECT AUFNR ORDER_NO,MDOCNO DOC_NO, MDOCSEQ  DOC_SEQNO , JRLOT LOT_NO, JBRGEW SQTY, RUECK RUECK, ZRESULT ZRESULT FROM TB_IFS003 --점보롤
                                                 UNION ALL
                                                 SELECT AUFNR ORDER_NO,MDOCNO DOC_NO, MDOCSEQ  DOC_SEQNO , MRLOT LOT_NO, RBRGEW SQTY, RUECK RUECK, ZRESULT ZRESULT FROM TB_IFS004 --밀롤
                                                 UNION ALL
                                                 SELECT AUFNR ORDER_NO,MDOCNO DOC_NO, MDOCSEQ  DOC_SEQNO , CRLOT LOT_NO, PRDQTY SQTY, RUECK RUECK, ZRESULT ZRESULT FROM TB_IFS005 --재단
                                                 UNION ALL
                                                 SELECT AUFNR ORDER_NO,MDOCNO DOC_NO, MDOCSEQ  DOC_SEQNO , PKLOT LOT_NO,   PCNT SQTY, RUECK RUECK, ZRESULT ZRESULT FROM TB_IFS006 --포장
                                              ' ;  
                    ELSE
                        V_SQL := V_SQL ||     ' SELECT AUFNR ORDER_NO,MDOCNO DOC_NO, MDOCSEQ  DOC_SEQNO , LOTNO LOT_NO,   PROQTY SQTY, RUECK RUECK, ZRESULT ZRESULT FROM TB_IFS001 --합지
                                                 UNION ALL
                                                 SELECT AUFNR ORDER_NO,MDOCNO DOC_NO, MDOCSEQ  DOC_SEQNO , LOTNO LOT_NO,   PROQTY SQTY, RUECK RUECK, ZRESULT ZRESULT FROM TB_IFS002 --가공
                                                 UNION ALL
                                                 SELECT AUFNR ORDER_NO,MDOCNO DOC_NO, MDOCSEQ  DOC_SEQNO , LOTNO LOT_NO,   PROQTY SQTY, RUECK RUECK, ZRESULT ZRESULT FROM TB_IFS011 --패드
                                                 UNION ALL
                                                 SELECT AUFNR ORDER_NO,MDOCNO DOC_NO, MDOCSEQ  DOC_SEQNO , LOTNO LOT_NO,   PROQTY SQTY, RUECK RUECK, ZRESULT ZRESULT FROM TB_IFS019 --예외생산
                                              ' ;  
                    END IF; 
         
                    V_SQL := V_SQL ||   ' )        W -- SAP 실적전송이력
                                         , (
                                              SELECT WERKS, LOT_NO, IND_BCD, MATNR, DLFL, SUM(DECODE(NVL(STCK_KY,''N''), ''N'', 0, 1)) W_SUCC, SUM(DECODE(NVL(STCK_KY,''N''), ''N'', 1, TRIM(STCK_KY),'''', 1, 0 )) W_FAIL, SUM(QTY) W_SUM, SUM(DECODE(REQ_STA,''O'', QTY, 0)) W_IN_SUCC, SUM(DECODE(STOR_LOC_TO,''3000'', QTY, 0)) W_3000_SUCC	 FROM TB_WRK015   WHERE DLFL =''C'' GROUP BY WERKS, LOT_NO, IND_BCD, MATNR, DLFL 
                                           )        X -- WMS 전송이력
                                         , (
                                              SELECT LOTA02 LOTA02, LOTA01 LOTA01, SKUKEY SKUKEY, LOTA15 LOTA15, LOTA14 LOTA14, SUM(QTSIWH) QTSIWH, SUM(QTSALO) QTSALO, SUM(QTSPMI) QTSPMI, SUM(QTSPMO) QTSPMO, SUM(QTSIQT) QTSIQT, SUM(QTSHQT) QTSHQT, SUM(QTSCNU) QTSCNU, SUM(QTSWQT) QTSWQT, SUM(USEQTY) USEQTY  FROM V_WMS_STKKY@KNRAWMSLINK  GROUP BY LOTA02, LOTA01, SKUKEY, LOTA15, LOTA14
                                           )        Y -- WMS 재고현황
                                     WHERE A.WERKS      = B.WERKS       
                                       AND A.IND_BCD    = B.IND_BCD     
                                       AND A.WERKS      = Z.WERKS       (+)
                                       AND A.MATNR      = Z.MATNR       (+)
                                       AND B.ORDER_NO   = W.ORDER_NO    (+)
                                       AND B.DOC_NO     = W.DOC_NO      (+)
                                       AND B.DOC_SEQNO  = W.DOC_SEQNO   (+)
                                       AND B.LOT_NO     = W.LOT_NO      (+)                               
                                       AND B.WERKS      = X.WERKS       (+)
                                       AND B.LOT_NO     = X.LOT_NO      (+)
                                       AND B.IND_BCD    = X.IND_BCD     (+)
                                       AND B.MATNR      = X.MATNR       (+)
                                       AND A.WERKS      = Y.LOTA02      (+)
                                       AND A.MATNR      = Y.SKUKEY      (+)
                                       AND A.LOT_NO     = Y.LOTA15      (+)
                                       AND A.IND_BCD    = Y.LOTA14      (+)
                                       AND B.PRFM_GTHR_YN = ''Y''
                                       AND A.STOR_LOC_CD IS NOT NULL
                                       AND A.WERKS   =  ''' || V_WERKS || '''
                                ) A, 
                                -- LGORT, DECODE(LGORT,''3000'', ''3100'',LGORT) LGORTT, 
                                (SELECT WERKS, DECODE(LGORT,''3000'', ''3100'',LGORT) LGORT, CHARG, MATNR, SUM(STQTY) STQTY FROM TB_IFR050 WHERE WKDT = ''' || V_WKDT || ''' AND WERKS = ''' || V_WERKS || ''' AND LGORT <= ''3100'' GROUP BY WERKS, DECODE(LGORT,''3000'', ''3100'',LGORT), CHARG, MATNR) B
                              WHERE A.WERKS        = B.WERKS(+)          -- 플랜트
                                AND A.STOR_LOC_CD  = B.LGORT(+)         -- 저장위치
                                AND A.LOT_NO       = B.CHARG(+)          -- LOT_NO
                                AND A.MATNR        = B.MATNR(+)          -- 품목코드
                            ';
     
            V_SQL := V_SQL || ' AND A.PRFM_DT  BETWEEN  ''' || V_FROM_PRD_DT || ''' AND ''' || V_TO_PRD_DT || '''';  
            V_SQL := V_SQL || ' AND A.WERKS   =  ''' || V_WERKS || ''' ';  

            IF V_LOT_NO IS NOT NULL OR TRIM(V_LOT_NO) != '' THEN
                V_SQL := V_SQL || 'AND A.LOT_NO = ''' || V_LOT_NO || ''' ';  
            END IF ;

            IF V_STOR_LOC_CD IS NOT NULL OR TRIM(V_STOR_LOC_CD) != '' THEN
                V_SQL := V_SQL || 'AND A.STOR_LOC_CD = ''' || V_STOR_LOC_CD || ''' ';  
            END IF ;
 
            V_SQL := V_SQL || ' 
                           GROUP BY
                                 A.WERKS                    -- 플랜트
                               , A.STOR_LOC_CD              -- 저장위치
                               , A.LOT_NO                   -- LOT_NO
                               , A.MATNR                    -- 품목코드
                               , A.MATNR_NM                 -- 품목명
                               , A.UNIT                     -- 단위
                               , NVL(B.STQTY,0)
--                               , B.IF_STATUS       -- 수신상태
--                               , B.IF_GET_DATE     -- 수신일자
--                               , B.IF_SET_DATE     -- 이관일시
--                               , B.IF_ERR_MESS     -- 수신오류
--                               , B.IF_MES_ID       -- MES I/F ID
--                               , B.IF_RCV_MES_KEY  -- MES 수신 KEY  
--                               , B.MAKER           -- 처리자
--                               , B.MBLNR           -- SAP확정문서
--                               , B.MJAHR           -- SAP확정문서순번
--                               , B.ZRESULT         -- 전송결과
--                               , B.ZMESSAGE        -- 전송메시지
--                               , B.ZRESULT_DATE    -- 전송일시
                           ORDER BY
                                 A.STOR_LOC_CD              -- 저장위치
                               , A.LOT_NO                   -- LOT_NO
                               , A.MATNR                    -- 품목코드    ';  
 
        V_DEBUG := 'Y';

        IF (V_DEBUG = 'Y') THEN
            INSERT INTO PROC_LOG(SQL_STR) VALUES (V_SQL);
        END IF;
        COMMIT;

          OPEN P_RS_LIST_01 FOR V_SQL;

	ELSIF P_TYPE = 'SAVE' THEN
    
          V_ARR_LIST        := V_JSON.get_array('list');

         BEGIN
               SELECT COUNT(WKDT), SUM(DECODE(ZRESULT, 'S', 1, 0))
                 INTO V_TOT_CNT, V_SND_CNT
                 FROM TB_IFR050            
                WHERE WKDT    =  V_WKDT 
                GROUP BY WKDT;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
                V_TOT_CNT := 0; 
                V_SND_CNT := 0; 
         END;
        
         IF  (V_SND_CNT = 0  OR V_SND_CNT IS NULL) AND NVL(P_DECISION_RTN,'N') = 'N' THEN
            P_SUCCESS := 'P';
            P_RS_MSG := '해당월에 재고 대사를 이미 진행한 내역이 있습니다!~r~n이전작업을 무시하고 다시 전송하시겠습니까?';
            RETURN;
         ELSIF (V_SND_CNT = 0  OR V_SND_CNT IS NULL) AND NVL(P_DECISION_RTN,'') = 'Y' THEN
            P_SUCCESS := 'S';
         ELSE  -- P_DECISION_RTN = 'C'
            P_SUCCESS := 'E';
            P_RS_MSG := '해당월의 재고 조정작업을 취소하셨습니다!';
            RETURN;            
         END IF;
         
         FOR i IN 0..V_ARR_LIST.get_size-1 LOOP
                V_OBJ           := TREAT (V_ARR_LIST.get (i) AS json_object_t);
                V_OBJ           := TREAT (V_OBJ.get ('map') AS json_object_t);
    
                V_WERKS         := V_OBJ.get_string('WERKS');
                V_STOR_LOC_CD   := V_OBJ.get_string('STOR_LOC_CD');     -- 저장위치
                V_LOT_NO        := V_OBJ.get_string('LOT_NO');          -- LOT_NO
                V_MATNR         := V_OBJ.get_string('MATNR');           -- 품목코드
                V_SAP_DIFF_QTY  := V_OBJ.get_string('SAP_DIFF_QTY');    -- MES-SAP 재고차이
                
                V_DOC_NO        := FN_GET_MDOCNO(V_PLT_CD, 'MES_IF_906'); /*SAP 전송 문서번호 생성*/

                UPDATE TB_IFR050
                    SET  MDOCNO    = V_DOC_NO 
                      ,  MDOCSEQ   = i + 1
                      ,  TOSTQTY   = NULL
                      ,  TOSPEME   = NVL(V_SAP_DIFF_QTY,0)
                      ,  MAKE_DATE = SYSDATE
                      ,  MAKER     = V_SESS_USER_ID
                      ,  ZRESULT   = 'N' 
                 WHERE WKDT    = V_WKDT 
                   AND WERKS   = V_WERKS
                   AND LGORT   = V_STOR_LOC_CD
                   AND MATNR   = V_MATNR
                   AND CHARG   = V_LOT_NO ;

                
         END LOOP;

	ELSIF P_TYPE = 'SEND' THEN

            IF V_WKDT IS NULL OR trim(V_WKDT) = '' THEN
               P_SUCCESS := 'E';
               P_RS_MSG := '재고 대사를 진행할 기준월을 선택하십시오!';
               RETURN;
            ELSE
               IF V_WKDT !=  to_char(add_months(sysdate,-1),'yyyymm')  THEN
                  P_SUCCESS := 'E';
                  P_RS_MSG := '재고 대사는 반드시 전월을 기준으로 작업을 진행할 수 있습니다!~r~n 재고 대사 기준월을 다시 확인하시기 바랍니다.';
                  RETURN;
               END IF;         
            END IF;

            BEGIN
               SELECT COUNT(WKDT), SUM(DECODE(ZRESULT, 'N', 1, 0))
                 INTO V_TOT_CNT, V_SND_CNT
                 FROM TB_IFR050            
                WHERE WKDT    =  V_WKDT 
                GROUP BY WKDT;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    V_TOT_CNT := 0; 
                    V_SND_CNT := 0; 
            END;
            
            IF  V_TOT_CNT = 0  OR V_TOT_CNT IS NULL THEN
                P_SUCCESS := 'E';
                P_RS_MSG := '재고 대사를 진행할 SAP 현재고를 수신받지 못하였습니다!~r~n 다운로드 버튼을 통해 현재고를 수신 받으시기 바랍니다.';
                RETURN;
            END IF;

            IF  V_SND_CNT = 0  OR V_SND_CNT IS NULL THEN
                P_SUCCESS := 'E';
                P_RS_MSG := '현재고를 조정하고 SAP 전송할 대상 데이터가 존재하지 않습니다!~r~n 재고차이를 확인하시고 조정 후 전송하시기 바랍니다.';
                RETURN;
            END IF;
         
            V_SQL := ' 
                   SELECT   
                           WERKS
                         , LGORT
                         , MATNR
                         , CHARG
                         , TOSPEME
                         , MDOCNO
                         , MDOCSEQNO
                    FROM TB_IFR050            
                   WHERE WKDT     = ''' || V_WKDT || '''
                     AND ZRESULT  = ''N''';
                     
            IF V_WERKS IS NOT NULL OR trim(V_WERKS) != '' THEN
                 V_SQL := V_SQL || ' AND WERKS   = ''' || V_WERKS || '''';
            END IF;
             
            IF V_STOR_LOC_CD IS NOT NULL OR trim(V_STOR_LOC_CD) != '' THEN
                 V_SQL := V_SQL || ' AND LGORT   = ''' || V_STOR_LOC_CD || '''';
            END IF;
             
            IF V_MATNR IS NOT NULL OR trim(V_MATNR) != '' THEN
                 V_SQL := V_SQL || ' AND MATNR   = ''' || V_MATNR || '''';
            END IF;
             
            IF V_LOT_NO IS NOT NULL OR trim(V_LOT_NO) != '' THEN
                 V_SQL := V_SQL || ' AND CHARG   = ''' || V_LOT_NO || '''';
            END IF;
             
            OPEN P_RS_LIST_02 FOR V_SQL;

	END IF;

	P_SUCCESS := 'Y';
	COMMIT;

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
