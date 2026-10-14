--------------------------------------------------------
--  DDL for Procedure SP_POP_WRK25_R01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK25_R01" 
(
     P_DOC_NO           IN VARCHAR2                     --문서번호
    ,P_DOC_SEQNO        IN VARCHAR2                     --문서번호 순번
    ,P_USERID           IN VARCHAR2                     --USER ID
    ,Lang       		IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE     		OUT VARCHAR2 
    ,RS_MSG      		OUT VARCHAR2
)
/*==============================================================================
 * PROGRAM ID    : SP_POP_WRK25_R01  {호출 프로그램 ID 기술}
 * PROGRAM NAME  : 밀롤 실적등록 롤백 [MES]
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 밀롤 실적등록 롤백 [MES]
 *                 
 * AUTHOR NAME   : 이성민{최초 작성자 명 기술}
 * CREATE DATE   : 2022/10/25 {최초 작성일자 기술}
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/10/25    1.0.0   이성민         Initial Version 
 *==============================================================================
 *  관련 테이블
 *=============================================================================*/

AS 
    --프로그램 ID : 점보롤 실적취소 
    V_PRG_NM        VARCHAR2(100)  := 'SP_POP_WRK25_R01';    -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := '99';                    --PLANTCODE TEST
    V_SESS_USER_ID   varchar2(20) := P_USERID;               --USERID

    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);

    -- JSON을 위한 변수선언 영역
    V_JSON           JSON_OBJECT_T;
    V_ARR_LIST       JSON_ARRAY_T;
    V_ARR_HEAD       JSON_OBJECT_T;
    V_OBJ            JSON_OBJECT_T;

    --parameter변수 처리
    
    V_DOC_NO            TB_WRK021.DOC_NO%TYPE;   
    V_DOC_SEQNO         TB_WRK021.DOC_SEQNO%TYPE;
    V_DOC_DIV           TB_WRK021.DOC_DIV%TYPE;
    V_WERKS             TB_WRK021.WERKS%TYPE;
    V_MACH_CD           TB_WRK021.MACH_CD%TYPE;
    V_IND_BCD           TB_WRK021.IND_BCD%TYPE;
    V_LOT_NO            TB_WRK021.LOT_NO%TYPE;
    V_ORDER_NO          TB_WRK021.ORDER_NO%TYPE;
    V_SDOC_NO           TB_WRK021.SDOC_NO%TYPE;
    V_SDOC_SEQNO        TB_WRK021.SDOC_SEQNO%TYPE;
    V_WRK_ORDR_NO       TB_WRK021.WRK_ORDR_NO%TYPE;
    V_WRK_ORDR_SEQNO    TB_WRK021.WRK_ORDR_SEQNO%TYPE;
    V_JR_WRK_ORDR_NO    TB_WRK021.WRK_ORDR_NO%TYPE;
    V_JR_WRK_ORDR_SEQNO TB_WRK021.WRK_ORDR_SEQNO%TYPE;   
    V_MACH_STA    		TB_WRK011.MACH_STA%TYPE;
    V_STOR_LOC_CD		TB_MAS001.LGPRO%TYPE;
    V_MATNR			    TB_SCH015.MATNR%TYPE;
    V_SHEET             TB_SCH016.SHEET%TYPE;         --판지구분
    V_SLITER            TB_SCH016.SLITER%TYPE;  
    V_SAP_WRK_CD        TB_MAS012.SAP_WRK_CD%TYPE;
    V_RUN_STA           TB_WRK011.RUN_STA%TYPE;
    V_TOT_QTY           TB_WRK002.PRFM_QTY%TYPE;
    V_ROLLCNT 			TB_WRK002.ROLLCNT%TYPE;
    V_PRFM_QTY	        TB_WRK002.PRFM_QTY%TYPE;
    V_DISPO_QTY         TB_WRK002.PRFM_QTY%TYPE;
    V_DISPO_WGT         TB_WRK004.WGT%TYPE;  
    V_LOT_NO_M			TB_INV010.LOT_NO_M%TYPE;
    V_MATNR_M			TB_INV010.MATNR_M%TYPE;
    V_INP_DT			TB_INV010.INP_DT%TYPE;
    V_IND_BCD_M			TB_INV010.IND_BCD_M%TYPE;
    V_DATE              DATE := SYSDATE;
    V_PRE_ORDER_NO      TB_WRK002.ORDER_NO%TYPE;
    V_JMATNR      		TB_SCH016.JMATNR%TYPE;
    V_PRFM_DT           VARCHAR2(20);  
    V_STR_DTM 			TB_WRK011.PRD_STR_DTM%TYPE;
   
    V_WRK_ORDR_NO1      TB_SCH015.WRK_ORDR_NO%TYPE;         
    V_WRK_ORDR_SEQNO1   TB_SCH015.WRK_ORDR_SEQNO%TYPE;      

    V_WRK_ORDR_NO2      TB_SCH015.WRK_ORDR_NO%TYPE;         
    V_WRK_ORDR_SEQNO2   TB_SCH015.WRK_ORDR_SEQNO%TYPE;      
   
   
   
   
BEGIN
  BEGIN


   

    -- ROLLBACK 문서번호 SELECT---------------------------------------------------------------------------------
    BEGIN
            SELECT   DOC_DIV,   WERKS,   MACH_CD,   IND_BCD,   LOT_NO,   ORDER_NO,   SDOC_NO,   SDOC_SEQNO
                    ,WRK_ORDR_NO    ,WRK_ORDR_SEQNO
            INTO   V_DOC_DIV, V_WERKS, V_MACH_CD, V_IND_BCD, V_LOT_NO, V_ORDER_NO, V_SDOC_NO, V_SDOC_SEQNO
                  ,V_WRK_ORDR_NO  ,V_WRK_ORDR_SEQNO
            FROM  TB_WRK021
            WHERE DOC_NO = P_DOC_NO
            AND   DOC_SEQNO = P_DOC_SEQNO;
    EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RS_CODE      := 'E';
                RS_MSG       := 'ROLLBACK[SP_POP_WRK25_R01] 문서번호가 조회되지 않습니다';
                ROLLBACK;
                RETURN;
            WHEN OTHERS THEN
                RS_CODE      := 'E';
                RS_MSG       := 'ROLLBACK[SP_POP_WRK25_R01] ERROR';
                ROLLBACK;
                RETURN;
    END;

    -- 실적 취소------------------------------------------------------------------------------------------
    BEGIN
    		SELECT   PRFM_QTY,   ROLLCNT  , TO_CHAR(PRD_STR_DATE, 'YYYYMMDDHHMISS')         
    		INTO   V_PRFM_QTY, V_ROLLCNT  , V_STR_DTM
    		FROM  TB_WRK002
    		WHERE WERKS   = V_WERKS
    		  AND MACH_CD = V_MACH_CD
    		  AND IND_BCD = V_IND_BCD
    		  AND NVL(CNL_YN,'N') = 'N'
    ;
    EXCEPTION
    		WHEN NO_DATA_FOUND THEN
    		V_ROLLCNT := 0;
    		WHEN OTHERS THEN
    		V_ROLLCNT := 0;
    END;
   
    BEGIN
            SELECT ORDER_NO   ,  MATNR,   PRE_ORDER_NO,   JMATNR
              INTO V_ORDER_NO ,V_MATNR, V_PRE_ORDER_NO, V_JMATNR
              FROM TB_SCH016
             WHERE WRK_ORDR_NO    = V_WRK_ORDR_NO
               AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
               ;
    EXCEPTION
            WHEN NO_DATA_FOUND THEN
                V_ORDER_NO := '';
            WHEN OTHERS THEN
                V_ORDER_NO := '';
    END;  
  
  
    IF V_ROLLCNT > 0 THEN   
            /*
            IF V_SDOC_NO IS NULL  THEN
               RS_CODE      := 'E';
               RS_MSG       := 'SAP 인터페이스 실패한 실적 입니다.';
               ROLLBACK;
               RETURN;
            END IF ;
            */
                      
            UPDATE TB_SCH016
               SET COMP_YN      = 'N'
            WHERE WRK_ORDR_NO    = V_WRK_ORDR_NO
              AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
              ;

            SELECT SAP_WRK_CD INTO V_SAP_WRK_CD
              FROM TB_MAS012
              WHERE MACH_CD = V_MACH_CD
              ;
 
            BEGIN
                    SELECT LOT_NO_M   --LOT_NO
                         , MATNR_M    --자재코드
                         , INP_DT     --투입일자
                         , SDOC_NO    --SAP 문서번호 
                         , SDOC_SEQNO --SAP 문서번호(년도)
                         , IND_BCD_M  -- 자재개별바코드
                      INTO V_LOT_NO_M 
                         , V_MATNR_M
                         , V_INP_DT
                         , V_SDOC_NO    --SAP 문서번호
                         , V_SDOC_SEQNO --SAP 문서번호(년도)
                         , V_IND_BCD_M  -- 자재개별바코드                             
                      FROM TB_INV010     --자재투입이력   
                     WHERE WERKS   = V_WERKS
                       AND MACH_CD = V_MACH_CD
                       AND IND_BCD = V_IND_BCD
                    ;
            EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            V_LOT_NO_M := '';
                        WHEN OTHERS THEN
                            V_LOT_NO_M := '';
            END;
            BEGIN 
                    --로케이션 정보
                    SELECT LGPRO INTO V_STOR_LOC_CD
                      FROM TB_MAS001
                     WHERE WERKS = V_WERKS
                       AND MATNR = V_MATNR_M;
            EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            V_STOR_LOC_CD := '';
                        WHEN OTHERS THEN
                            V_STOR_LOC_CD := '';
            END;
                
            UPDATE TB_WRK002     --실적테이블(PS)
               SET CNL_YN = 'Y',
                   ROL_YN = 'Y',
                   CNL_RMK = 'ROLLBACK '||P_DOC_NO|| ' '||TO_CHAR(DOC_SEQNO),    
                   --ROLLCNT = ROLLCNT - V_ROLLCNT ,
                   UPDDATE = SYSDATE,
                   UPDID   = P_USERID
            WHERE WERKS   = V_WERKS
              AND MACH_CD = V_MACH_CD
              AND IND_BCD = V_IND_BCD
              AND NVL(CNL_YN,'N') = 'N'
              ;

            UPDATE TB_INV001
               SET STCK_QTY = 0,
                   DLFL = 'Y',
                   ROL_YN = 'Y',
                   UPDDATE = SYSDATE,
                   UPDID   = P_USERID
             WHERE WERKS = V_WERKS
               AND MACH_CD = V_MACH_CD
               AND IND_BCD = V_IND_BCD;
              
            UPDATE TB_INV003
               SET STCK_QTY = NVL(STCK_QTY, 0) + V_PRFM_QTY
                 , USE_QTY  = NVL(USE_QTY, 0) - V_PRFM_QTY
             WHERE WERKS = V_WERKS
               AND MACH_CD = V_MACH_CD
               AND IND_BCD = V_IND_BCD_M;
              
            UPDATE  TB_INV010  SET CNL_YN = 'Y',    --자재투입이력
            					   ROL_YN = 'Y'
             WHERE WERKS   = V_WERKS
               AND MACH_CD = V_MACH_CD
               AND IND_BCD = V_IND_BCD ;
            DELETE FROM TB_WRK008     --LOT 추적
             WHERE WERKS   = V_WERKS
               AND IND_BCD   = V_IND_BCD
            ;
               
                   
            --WCS 삭제 정보(밀롤 창고
            IF V_STOR_LOC_CD = '2000' THEN
                V_DOC_NO := FN_GET_MDOCNO('M','IF406');
                V_DOC_SEQNO := 1;
                INSERT INTO TB_IFSWC005(DOC_NO,
                                        DOC_NOSEQ,
                                        IND_BCD,
                                        LOT_NO,
                                        DISCARD_CODE,
                                        DISCARD_RMK,
                                        REGDATE,
                                        REGID,
                                        REMARK1,
                                        REMARK2,
                                        REMARK3,
                                        REMARK4,
                                        REMARK5,
                                        REMARK6,
                                        REMARK7,
                                        REMARK8,
                                        REMARK9,
                                        REMARK10)
                               VALUES(  V_DOC_NO,
                                        V_DOC_SEQNO,
                                        V_IND_BCD,
                                        V_LOT_NO,
                                        '',
                                        'ROLLBACK '||P_DOC_NO|| ' '||TO_CHAR(P_DOC_SEQNO),
                                        V_DATE,
                                        P_USERID,
                                        '',
                                        '',
                                        '',
                                        '',
                                        '',
                                        '',
                                        '',
                                        '',
                                        '',
                                        '');
            END IF;
           
    END IF;     
   
       -- 폐품 취소------------------------------------------------------------------------------------------
    BEGIN
            SELECT DISPO_QTY,ROLLCNT,MMATNR,IND_BCD_M           , TO_CHAR(PRD_STR_DATE, 'YYYYMMDDHHMISS')
              INTO V_DISPO_QTY,V_ROLLCNT,V_MATNR_M,V_IND_BCD_M  , V_STR_DTM                    
              FROM TB_WRK004
             WHERE WERKS   = V_WERKS
               AND MACH_CD = V_MACH_CD
               AND IND_BCD = V_IND_BCD
               AND NVL(CNL_YN,'N') != 'Y';
               
    EXCEPTION
            WHEN NO_DATA_FOUND THEN
                V_ROLLCNT := 0;
                V_DISPO_QTY := 0;
            WHEN OTHERS THEN
                V_ROLLCNT := 0;
                V_DISPO_QTY := 0;
    END;
    BEGIN
            SELECT SHEET, SLITER
              INTO V_SHEET, V_SLITER
              FROM TB_SCH016
             WHERE WRK_ORDR_NO    = V_WRK_ORDR_NO
               AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
               ;
    EXCEPTION
            WHEN NO_DATA_FOUND THEN
                V_ORDER_NO := '';
            WHEN OTHERS THEN
                V_ORDER_NO := '';
    END;
    IF V_DISPO_QTY > 0 THEN   --폐품수량

            UPDATE TB_SCH016
               SET COMP_YN        = 'N'
             WHERE WRK_ORDR_NO    = V_WRK_ORDR_NO
               AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
                ;

            UPDATE TB_INV003
               SET STCK_QTY = NVL(STCK_QTY, 0)   + V_DISPO_QTY
                 , USE_QTY   = NVL(USE_QTY, 0)   - V_DISPO_QTY
                 , DISPO_QTY = NVL(DISPO_QTY, 0) - V_DISPO_QTY
             WHERE WERKS = V_WERKS
               AND MACH_CD = V_MACH_CD
               AND IND_BCD = V_IND_BCD_M;
            SELECT SAP_WRK_CD INTO V_SAP_WRK_CD
              FROM TB_MAS012
              WHERE MACH_CD = V_MACH_CD;
                 
                 
             UPDATE TB_WRK004     --폐품테이블(PS)
                SET CNL_YN = 'Y',
                    ROL_YN = 'Y',
                    UPDDATE = SYSDATE,
                    UPDID   = P_USERID
             WHERE WERKS   = V_WERKS
               AND MACH_CD = V_MACH_CD
               AND IND_BCD = V_IND_BCD
               --AND NVL(CNL_YN,'N') = 'N'
               ;
    END IF; 
    -- 잔량 취소------------------------------------------------------------------------------------------       
     BEGIN
            SELECT H016.PRE_ORDER_NO , H016.WRK_ORDR_NO, H016.WRK_ORDR_SEQNO,PRFM_DT           
              INTO V_PRE_ORDER_NO , V_WRK_ORDR_NO1,V_WRK_ORDR_SEQNO1,V_PRFM_DT           
              FROM TB_WRK002  K002
                 , TB_SCH016  H016
             WHERE K002.WRK_ORDR_NO    = H016.WRK_ORDR_NO
               AND K002.WRK_ORDR_SEQNO = H016.WRK_ORDR_SEQNO
               AND K002.WERKS   = V_WERKS
               AND K002.IND_BCD = V_IND_BCD
               --AND NVL(K002.CNL_YN,'N') = 'N'
               AND ROWNUM = 1
               ;
    EXCEPTION
            WHEN NO_DATA_FOUND THEN
                V_PRE_ORDER_NO := NULL;
            WHEN OTHERS THEN
                V_PRE_ORDER_NO := NULL;
    END;
     
    IF V_PRE_ORDER_NO IS  NULL  THEN
             BEGIN
                    SELECT H016.PRE_ORDER_NO , H016.WRK_ORDR_NO, H016.WRK_ORDR_SEQNO,PRFM_DT           
                      INTO V_PRE_ORDER_NO , V_WRK_ORDR_NO1,V_WRK_ORDR_SEQNO1,V_PRFM_DT           
                      FROM TB_WRK004  K004
                         , TB_SCH016  H016
                     WHERE K004.WRK_ORDR_NO    = H016.WRK_ORDR_NO
                       AND K004.WRK_ORDR_SEQNO = H016.WRK_ORDR_SEQNO
                       AND K004.WERKS   = V_WERKS
                       AND K004.IND_BCD = V_IND_BCD
                       --AND NVL(K004.CNL_YN,'N') = 'N'
                       AND ROWNUM = 1
                       ;
                       
            EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        V_PRE_ORDER_NO := NULL;
                    WHEN OTHERS THEN
                        V_PRE_ORDER_NO := NULL;
            END;
    END IF;
    BEGIN
            SELECT WRK_ORDR_NO, WRK_ORDR_SEQNO,SDOC_NO, SDOC_SEQNO, DISPO_QTY, WGT, ROLLCNT, MATNR_M, PRFM_DT, LOT_NO_M,ORDER_NO
              INTO V_WRK_ORDR_NO2, V_WRK_ORDR_SEQNO2,V_SDOC_NO, V_SDOC_SEQNO, V_DISPO_QTY, V_DISPO_WGT, V_ROLLCNT,V_MATNR,V_PRFM_DT,V_LOT_NO,V_ORDER_NO
              FROM TB_WRK022 
             WHERE WERKS   = V_WERKS
               AND MACH_CD = V_MACH_CD
               AND PRE_ORDER_NO = V_PRE_ORDER_NO
               AND IND_BCD = V_IND_BCD
               AND DISPO_CD= '910' 
               ;
    EXCEPTION
            WHEN NO_DATA_FOUND THEN
                V_ROLLCNT := 0;
                V_DISPO_WGT := 0;
            WHEN OTHERS THEN
                V_ROLLCNT := 0;
                V_DISPO_WGT := 0;
    END;
    IF V_DISPO_WGT > 0 THEN   --폐품수량

          UPDATE TB_SCH016
             SET COMP_YN      = 'N'
           WHERE WRK_ORDR_NO    = V_WRK_ORDR_NO2
             AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO2
          ;
    
           SELECT SAP_WRK_CD INTO V_SAP_WRK_CD
             FROM TB_MAS012
            WHERE MACH_CD = V_MACH_CD
           ;
           UPDATE TB_WRK022
              SET CNL_YN = 'Y',
              	  ROL_YN = 'Y'
            WHERE WERKS   = V_WERKS
              AND WRK_ORDR_NO      = V_WRK_ORDR_NO2
              AND WRK_ORDR_SEQNO   = V_WRK_ORDR_SEQNO2
              AND DISPO_CD         = '910'
           ;
    END IF;                   
    V_TOT_QTY := 0 ;
    SELECT
           SUM(QTY)
    INTO   V_TOT_QTY     
    FROM 
    (
                    SELECT NVL(PRFM_QTY,0)   QTY
                    FROM TB_WRK002 
                     WHERE WRK_ORDR_NO    = V_WRK_ORDR_NO
                       AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
                       AND NVL(CNL_YN, 'N') =  'N'
                    UNION ALL
                    SELECT NVL(DISPO_QTY,0)  QTY
                    FROM TB_WRK004 
                     WHERE WRK_ORDR_NO    = V_WRK_ORDR_NO
                       AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
                       AND NVL(CNL_YN, 'N') =  'N'
    ) ;
    UPDATE TB_SCH016
      SET PRFM_QTY = V_TOT_QTY,
    	  COMP_YN  = 'N'
    WHERE WRK_ORDR_NO    = V_WRK_ORDR_NO
      AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO 
    ;
   
    SELECT  MACH_STA
    INTO  V_MACH_STA
    FROM  TB_WRK011
    WHERE WERKS = V_WERKS
    AND   MACH_CD  = V_MACH_CD
    ;
   
    IF V_MACH_STA = 'N' THEN 
    	SELECT    WRK_ORDR_NO,       WRK_ORDR_SEQNO
    	INTO      V_JR_WRK_ORDR_NO, V_JR_WRK_ORDR_SEQNO
    	FROM 	TB_SCH015
    	WHERE   ORDER_NO = V_PRE_ORDER_NO
    	AND 	WERKS    = V_WERKS
    	;

		UPDATE TB_WRK011
		SET 	MATNR = V_JMATNR,
				WRK_ORDR_NO = V_JR_WRK_ORDR_NO, 
				WRK_ORDR_SEQNO = V_JR_WRK_ORDR_SEQNO,
				ORDER_NO = V_PRE_ORDER_NO,
				MACH_STA = 'R',
				PRD_STR_DTM = V_STR_DTM
		WHERE MACH_CD = V_MACH_CD
		AND   WERKS   = V_WERKS
		AND MATNR          IS NULL
		AND WRK_ORDR_NO    IS NULL
		AND WRK_ORDR_SEQNO IS NULL
		AND ORDER_NO       IS NULL; 
	END IF;
    UPDATE TB_WRK011
    SET PRD_STR_DTM = V_STR_DTM
    WHERE MACH_CD = V_MACH_CD
    AND   WERKS   = V_WERKS;
   
   

    RS_CODE := 'S';
    COMMIT;    

    --예외처리(catch)
    EXCEPTION
    WHEN E_EXCEPTION_USER THEN
        -- 에러 내역 SET
        E_SQL_ERR_CD        := SQLCODE;
        E_SQL_ERR_MSG       := SUBSTRB(SQLERRM,1,300);

        ROLLBACK;
        SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);

        RS_CODE := 'E';
        RS_MSG  := SQLERRM;
        RETURN;
    WHEN OTHERS THEN
        E_SQL_ERR_CD        := SQLCODE;
        E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

        ROLLBACK;
        --RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
        RAISE;

        RS_CODE := 'E';
        RS_MSG  := SQLERRM;
        RETURN;
    --예외처리 종료
    END;
END;

/
