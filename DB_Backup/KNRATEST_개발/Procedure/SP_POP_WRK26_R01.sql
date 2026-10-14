--------------------------------------------------------
--  DDL for Procedure SP_POP_WRK26_R01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK26_R01" 
(
     P_DOC_NO           IN VARCHAR2                     --문서번호
    ,P_DOC_SEQNO        IN VARCHAR2                     --문서번호 순번
    ,P_USERID           IN VARCHAR2                     --USER ID
    ,Lang       		IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE     		OUT VARCHAR2 
    ,RS_MSG      		OUT VARCHAR2
)
/*==============================================================================
 * PROGRAM ID    : SP_POP_WRK30_I03{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 재단실적취소 롤백
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 재단실적취소 롤백
 *                 
 * AUTHOR NAME   : 이성민{최초 작성자 명 기술}
 * CREATE DATE   : 2022/10/28 {최초 작성일자 기술}
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/06/20    1.0.0   이성민         Initial Version 
 *==============================================================================
 *  관련 테이블
 *=============================================================================*/
AS 
    --프로그램 ID : 재단 ROLLBACK 
    V_PRG_NM         VARCHAR2(100) := 'SP_POP_WRK26_R01';  -- PROCEDURE NAME
    V_PLT_CD         VARCHAR2(2)   := '99';     --PLANTCODE TEST
    V_SESS_USER_ID   VARCHAR2(20)  := P_USERID; --USERID

    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);

    -- JSON을 위한 변수선언 영역
    V_JSON           JSON_OBJECT_T;
    V_ARR_LIST       JSON_ARRAY_T;
    V_OBJ            JSON_OBJECT_T;

    --parameter변수 처리
    V_YMCHK             TB_MAS011.YMCHK%TYPE;        --실적등록 가능 여부 
    
    V_IND_BCD           TB_WRK002.IND_BCD%TYPE;      --개별바코드
    V_ORDER_NO          TB_WRK002.ORDER_NO%TYPE;
    V_STA               TB_WRK002.STA%TYPE;
    V_SDOC_NO           TB_WRK002.SDOC_NO%TYPE;
    V_SDOC_SEQNO        TB_WRK002.SDOC_SEQNO%TYPE;
    V_PRFM_QTY	        TB_WRK002.PRFM_QTY%TYPE;      --실적수량
    V_MRLDCK            TB_WRK002.MRLDCK%TYPE;        --밀롤창고적치여부
    V_IND_BCD_M         TB_WRK002.IND_BCD%TYPE;       --자재개별바코드
    V_TOT_QTY           TB_WRK002.PRFM_QTY%TYPE;    
    V_DISPO_QTY	        TB_WRK004.DISPO_QTY%TYPE;    --폐품수량
    V_DISPO_WGT         TB_WRK004.WGT%TYPE;          --폐품중량
    V_MATNR_M           TB_WRK004.MATNR%TYPE;        --자재코드
    
    V_MACH_STA          TB_WRK011.MACH_STA%TYPE;
    V_PRE_ORDER_NO      TB_WRK002.ORDER_NO%TYPE;
    V_SAP_WRK_CD        TB_MAS012.SAP_WRK_CD%TYPE;
    V_WRK_ORDR_NO       TB_WRK021.WRK_ORDR_NO%TYPE;
    V_WRK_ORDR_SEQNO    TB_WRK021.WRK_ORDR_SEQNO%TYPE;
    V_WERKS             TB_WRK021.WERKS%TYPE;
    V_MACH_CD           TB_WRK021.MACH_CD%TYPE;
    V_MA_WRK_ORDR_NO    TB_WRK021.WRK_ORDR_NO%TYPE;
    V_MA_WRK_ORDR_SEQNO TB_WRK021.WRK_ORDR_SEQNO%TYPE;  

    V_STOR_LOC_CD       TB_INV001.STOR_LOC_CD%TYPE;
    V_IN_MR_YN          TB_INV001.IN_MR_YN%TYPE;
    V_INP_DT	        TB_INV003.INP_DT%TYPE;        --투입일자
    
    V_DOC_DIV           TB_WRK021.DOC_DIV%TYPE;
    V_DOC_NO_M          VARCHAR2(20);
    V_DOC_NO_INPUT      VARCHAR2(20);
    V_DOC_SEQNO         NUMBER;
    V_DOC_SEQNO_DISPO   NUMBER;
    V_PRFM_DT           TB_WRK002.PRFM_DT%TYPE;
    V_LOT_NO            TB_WRK002.LOT_NO%TYPE;
    V_LOT_NO_M          TB_WRK004.LOT_NO_M%TYPE;
    V_WGT               NUMBER(13,3);
    V_DMY               VARCHAR2(5);
    V_MAN_CUT_YN        VARCHAR2(1);
    V_RUN_STA           VARCHAR2(5);
    V_EXPROD            VARCHAR2(5);
    V_COUNT             NUMBER;
    V_SQL               VARCHAR2(4000);
    V_DATE              DATE := SYSDATE;
    V_STR_DTM 			TB_WRK011.PRD_STR_DTM%TYPE;
    
BEGIN
  BEGIN
    
    V_DOC_SEQNO       := 0;
    V_DOC_SEQNO_DISPO := 0;
   
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
                RS_MSG       := 'ROLLBACK[SP_POP_WRK26_R01] 문서번호가 조회되지 않습니다';
                ROLLBACK;
                RETURN;
            WHEN OTHERS THEN
                RS_CODE      := 'E';
                RS_MSG       := 'ROLLBACK[SP_POP_WRK26_R01] ERROR';
                ROLLBACK;
                RETURN;
    	END;
 
        BEGIN
            SELECT IND_BCD_M   --자재개별바코드                             
            INTO V_IND_BCD_M  -- 자재개별바코드
            FROM TB_INV010     --자재투입이력
            WHERE WERKS   = V_WERKS
            AND MACH_CD = V_MACH_CD
            AND IND_BCD = V_IND_BCD ;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                V_IND_BCD_M := '';
            WHEN OTHERS THEN
                V_IND_BCD_M := '';
        END;
        -- 실적 취소----------------------------------------------------------------------------
        BEGIN
            SELECT    	STA,  PRFM_QTY,   MRLDCK,   WGT,   PRFM_DT,   RUN_STA  ,     TO_CHAR(PRD_STR_DATE, 'YYYYMMDDHHMISS')
              INTO    V_STA,V_PRFM_QTY, V_MRLDCK, V_WGT, V_PRFM_DT, V_RUN_STA  ,     V_STR_DTM  
              FROM TB_WRK002
             WHERE WERKS   = V_WERKS
               AND MACH_CD = V_MACH_CD
               AND IND_BCD = V_IND_BCD ;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                V_PRFM_QTY := 0;
            WHEN OTHERS THEN
                V_PRFM_QTY := 0;
        END;
        
        BEGIN
            SELECT STCK_STA
              INTO V_DMY
              FROM TB_INV001
             WHERE WERKS   = V_WERKS
               AND MACH_CD = V_MACH_CD
               --AND IND_BCD = V_IND_BCD
               AND ORDER_NO  = V_ORDER_NO
               AND STCK_STA  = '10'
               AND ROWNUM  = 1 
               ;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                V_DMY := 'N';
            WHEN OTHERS THEN
                V_DMY := 'N';
        END;        

        BEGIN
            SELECT ORDER_NO, TRIM(MAN_CUT_YN), PRE_ORDER_NO
              INTO V_ORDER_NO, V_MAN_CUT_YN,  V_PRE_ORDER_NO
              FROM TB_SCH017
             WHERE WRK_ORDR_NO    = V_WRK_ORDR_NO
               AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO 
               AND NVL(USE_YN, 'Y') = 'Y';

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                V_ORDER_NO := '';
            WHEN OTHERS THEN
                V_ORDER_NO := '';
        END;

        IF V_MAN_CUT_YN = '' THEN
           V_MAN_CUT_YN := 'N';
        END IF ;

        IF V_RUN_STA = '09'  THEN
            V_EXPROD := 'X' ;
        ELSE
            V_EXPROD := '' ;
        END IF ;
        
        BEGIN
            SELECT SAP_WRK_CD INTO V_SAP_WRK_CD
              FROM TB_MAS012
             WHERE MACH_CD = V_MACH_CD ;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                V_SAP_WRK_CD := '';
            WHEN OTHERS THEN
                V_SAP_WRK_CD := '';
        END;
        
        -- 실적취소 수량이 있을 때
        IF V_PRFM_QTY > 0  THEN              
                    -- 투입정보 업데이트 ( 중량으로..)
                UPDATE TB_INV003         --자재투입
                   SET STCK_QTY = NVL(STCK_QTY, 0) + V_WGT
                     , USE_QTY  = NVL(USE_QTY, 0)  - V_WGT 
                 WHERE WERKS   = V_WERKS
                   AND MACH_CD = V_MACH_CD
                   AND IND_BCD = V_IND_BCD_M;

                    /*DELETE FROM TB_INV010     --자재투입이력
                     WHERE WERKS   = V_WERKS
                       AND MACH_CD = V_MACH_CD
                       AND IND_BCD = V_IND_BCD ;
                    */
                    
                UPDATE  TB_INV010  SET CNL_YN = 'Y',    --자재투입이력
                					   ROL_YN = 'Y'
                 WHERE WERKS   = V_WERKS
                   AND MACH_CD = V_MACH_CD
                   AND IND_BCD = V_IND_BCD ;


                DELETE FROM TB_WRK008     --LOT 추적
                 WHERE WERKS   = V_WERKS
                   AND MACH_CD = V_MACH_CD
                   AND IND_BCD = V_IND_BCD ;

                UPDATE TB_WRK002     --실적테이블(PS)
                   SET CNL_YN  = 'Y',
                       ROL_YN  = 'Y',
                       CNL_RMK = 'ROLLBACK '||P_DOC_NO|| ' '||TO_CHAR(P_DOC_SEQNO),
                       UPDDATE = SYSDATE,
                       UPDID   = P_USERID
                 WHERE WERKS   = V_WERKS
                   AND MACH_CD = V_MACH_CD
                   AND IND_BCD = V_IND_BCD ;
/*
                DELETE FROM TB_INV001     --창고별 재고정보 
                 WHERE WERKS   = V_WERKS
                   AND MACH_CD = V_MACH_CD
                   AND IND_BCD = V_IND_BCD ;
*/
                 UPDATE TB_INV001
                    SET STCK_QTY = 0,
                        DLFL = 'Y',
                        ROL_YN = 'Y',
                        UPDDATE = SYSDATE,
                        UPDID   = P_USERID
                  WHERE WERKS = V_WERKS
                    AND MACH_CD = V_MACH_CD
                    AND IND_BCD = V_IND_BCD;

            --WCS 삭제 정보(밀롤 창고)
            IF NVL(V_MRLDCK,'N') = 'Y' THEN

                V_DOC_NO_M := FN_GET_MDOCNO('M','IF406');
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
                                VALUES( V_DOC_NO_M,
                                        V_DOC_SEQNO,
                                        V_IND_BCD,
                                        V_LOT_NO,
                                        '',
                                        'ROLLBACK '||P_DOC_NO|| ' '||TO_CHAR(P_DOC_SEQNO),
                                        V_DATE,
                                        V_SESS_USER_ID,
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
     -------------------------------------------------------------------------------------    
        -- 폐품 취소 ( 폐품실적, 영업폐품, 잔량폐품 )            
        -- 폐품실적 취소 -----------------------------------------------------------------
        V_DISPO_WGT := 0 ;
        BEGIN
            SELECT WRK_ORDR_NO, WRK_ORDR_SEQNO, SDOC_NO, SDOC_SEQNO, DISPO_QTY
                 , WGT, MMATNR, PRFM_DT, LOT_NO_M, IND_BCD_M ,     TO_CHAR(PRD_STR_DATE, 'YYYYMMDDHHMISS')
              INTO V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_SDOC_NO, V_SDOC_SEQNO, V_DISPO_QTY
                 , V_DISPO_WGT, V_MATNR_M, V_PRFM_DT, V_LOT_NO_M, V_IND_BCD_M,     V_STR_DTM 
              FROM TB_WRK004
             WHERE WERKS   = V_WERKS
               AND MACH_CD = V_MACH_CD
               AND IND_BCD = V_IND_BCD 
               AND NVL(CNL_YN, 'N') != 'Y';
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                V_DISPO_WGT := 0;
            WHEN OTHERS THEN
                V_DISPO_WGT := 0;
        END;
        
        BEGIN
            SELECT ORDER_NO, TRIM(NVL(MAN_CUT_YN,'N'))
              INTO V_ORDER_NO, V_MAN_CUT_YN
              FROM TB_SCH017
             WHERE WRK_ORDR_NO    = V_WRK_ORDR_NO
               AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO 
               AND NVL(USE_YN, 'Y') = 'Y';
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                V_ORDER_NO := '';
            WHEN OTHERS THEN
                V_ORDER_NO := '';
        END;

        IF V_MAN_CUT_YN = '' THEN
           V_MAN_CUT_YN := 'N';
        END IF ;

        IF V_DISPO_WGT > 0 THEN   --폐품수량
            
            UPDATE TB_WRK004     --폐품테이블(PS)
               SET CNL_YN = 'Y',
                   ROL_YN = 'Y',
                   UPDDATE = SYSDATE,
                   UPDID   = P_USERID
             WHERE WERKS   = V_WERKS
               AND MACH_CD = V_MACH_CD
               AND IND_BCD = V_IND_BCD ;
            ------------------------------------------------------------
            UPDATE TB_INV003    --자재투입
               SET STCK_QTY  = NVL(STCK_QTY, 0)  + V_DISPO_WGT
                 , USE_QTY   = NVL(USE_QTY, 0)   - V_DISPO_WGT
                 , DISPO_QTY = NVL(DISPO_QTY, 0) - V_DISPO_WGT
             WHERE WERKS   = V_WERKS
               AND MACH_CD = V_MACH_CD
               AND IND_BCD = V_IND_BCD_M ;
               
        END IF;
        
        -- 잔량폐품 취소---------------------------------------------------------------------      
        V_DISPO_WGT := 0 ;
        BEGIN
            SELECT WRK_ORDR_NO, WRK_ORDR_SEQNO,SDOC_NO, SDOC_SEQNO, DISPO_QTY
                 , WGT, MATNR_M, PRFM_DT, LOT_NO_M, ORDER_NO
              INTO V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_SDOC_NO, V_SDOC_SEQNO, V_DISPO_QTY
                 , V_DISPO_WGT, V_MATNR_M, V_PRFM_DT, V_LOT_NO_M, V_ORDER_NO
              FROM TB_WRK022 
             WHERE WERKS     = V_WERKS
               AND MACH_CD   = V_MACH_CD
               AND IND_BCD   = V_IND_BCD
               AND DISPO_CD  = '910' ;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                V_DISPO_WGT := 0;
            WHEN OTHERS THEN
                V_DISPO_WGT := 0;
        END;
        BEGIN
            SELECT ORDER_NO, TRIM(NVL(MAN_CUT_YN,'N'))
              INTO V_ORDER_NO, V_MAN_CUT_YN
              FROM TB_SCH017
             WHERE WRK_ORDR_NO    = V_WRK_ORDR_NO
               AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO 
               AND NVL(USE_YN, 'Y') = 'Y';
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                V_ORDER_NO := '';
            WHEN OTHERS THEN
                V_ORDER_NO := '';
        END;

        IF V_MAN_CUT_YN = '' THEN
           V_MAN_CUT_YN := 'N';
        END IF ;
        
        -- 잔량폐품이 있을 경우
        IF V_DISPO_WGT > 0 THEN
                 
            DELETE FROM TB_WRK022     
            WHERE WERKS     = V_WERKS
              AND MACH_CD   = V_MACH_CD
              AND IND_BCD   = V_IND_BCD
              AND DISPO_CD  = '910' ;
            UPDATE TB_INV003     --자재투입 (잔량폐품)
               SET STCK_QTY  = NVL(STCK_QTY, 0)  + V_DISPO_WGT
                 , USE_QTY   = NVL(USE_QTY, 0)   - V_DISPO_WGT
                 , DISPO_QTY = NVL(DISPO_QTY, 0) - V_DISPO_WGT
             WHERE WERKS   = V_WERKS
               AND MACH_CD = V_MACH_CD
               AND IND_BCD = V_IND_BCD_M;
               
        END IF;
        
        -- 영업 폐품 취소---------------------------------------------------------------
        V_DISPO_WGT := 0 ;
        BEGIN
            SELECT WRK_ORDR_NO, WRK_ORDR_SEQNO, SDOC_NO, SDOC_SEQNO, DISPO_QTY
                 , WGT, MATNR_M, PRFM_DT, LOT_NO_M, IND_BCD_M
              INTO V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_SDOC_NO, V_SDOC_SEQNO, V_DISPO_QTY
                 , V_DISPO_WGT, V_MATNR_M, V_PRFM_DT, V_LOT_NO_M, V_IND_BCD_M
              FROM TB_WRK022 
             WHERE WERKS    = V_WERKS
               AND MACH_CD  = V_MACH_CD
               AND IND_BCD  = V_IND_BCD
               AND DISPO_CD = '900' ;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                V_DISPO_WGT := 0;
            WHEN OTHERS THEN
                V_DISPO_WGT := 0;
        END;

        BEGIN
            SELECT ORDER_NO, TRIM(NVL(MAN_CUT_YN,'N'))
              INTO V_ORDER_NO, V_MAN_CUT_YN
              FROM TB_SCH017
             WHERE WRK_ORDR_NO    = V_WRK_ORDR_NO
               AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO ;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                V_ORDER_NO := '';
            WHEN OTHERS THEN
                V_ORDER_NO := '';
        END;

        IF V_MAN_CUT_YN = '' THEN
           V_MAN_CUT_YN := 'N';
        END IF ;

        IF V_DISPO_WGT > 0 THEN   --영업폐품수량
                
            DELETE FROM TB_WRK022
             WHERE WERKS    = V_WERKS
               AND MACH_CD  = V_MACH_CD
               AND IND_BCD  = V_IND_BCD
               AND DISPO_CD = '900' ;
            UPDATE TB_INV003                         --자재투입
               SET STCK_QTY  = NVL(STCK_QTY, 0)  + V_DISPO_WGT
                 , USE_QTY   = NVL(USE_QTY, 0)   - V_DISPO_WGT
                 , DISPO_QTY = NVL(DISPO_QTY, 0) - V_DISPO_WGT
             WHERE WERKS   = V_WERKS
               AND MACH_CD = V_MACH_CD
               AND IND_BCD = V_IND_BCD_M ;

        END IF;        
    
        V_TOT_QTY := 0 ;
        SELECT     SUM(QTY)
        INTO    V_TOT_QTY     
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

        UPDATE TB_SCH017
           SET --PRFM_QTY = V_TOT_QTY, 기존 로직에 이 컬럼 업데이트가 없음
               COMP_YN = 'N'
               
         WHERE WRK_ORDR_NO    = V_WRK_ORDR_NO
           AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
           AND NVL(USE_YN, 'Y') = 'Y';    
    
    
        SELECT  MACH_STA
        INTO  V_MACH_STA
        FROM  TB_WRK011
        WHERE WERKS = V_WERKS
        AND   MACH_CD  = V_MACH_CD
        ;
   
        IF V_MACH_STA = 'N' THEN 
        
            SELECT    WRK_ORDR_NO,       WRK_ORDR_SEQNO     ,  MATNR
            INTO      V_MA_WRK_ORDR_NO, V_MA_WRK_ORDR_SEQNO ,V_MATNR_M
            FROM    TB_SCH016
            WHERE   ORDER_NO = V_PRE_ORDER_NO
            AND     WERKS    = V_WERKS
            ;
            
            -- 수입밀롤인경우 는 TB_WRK011에 WRK_ORDR_NO, WRK_ORDR_SEQNO 를 넣지 않는다.
            BEGIN
                SELECT IN_MR_YN  INTO V_IN_MR_YN
                  FROM TB_INV001
                 WHERE WERKS   = V_WERKS
                   AND MACH_CD = V_MACH_CD
                   AND ORDER_NO  = V_ORDER_NO
                   AND ROWNUM  = 1 
                   ;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    V_IN_MR_YN := 'N';
                WHEN OTHERS THEN
                    V_IN_MR_YN := 'N';
            END;        

            -- 수입밀롤인경우 는 TB_WRK011에 WRK_ORDR_NO, WRK_ORDR_SEQNO 를 넣지 않는다.
            IF V_IN_MR_YN = 'Y' THEN
                V_MA_WRK_ORDR_NO := '';
                V_MA_WRK_ORDR_SEQNO := '';
            END IF;
            
            UPDATE TB_WRK011
            SET     MATNR = V_MATNR_M,
                    WRK_ORDR_NO = V_MA_WRK_ORDR_NO, 
                    WRK_ORDR_SEQNO = V_MA_WRK_ORDR_SEQNO,
                    ORDER_NO = V_PRE_ORDER_NO,
                    LOT_NO = V_PRE_ORDER_NO,        --BMKIM 추가
                    MACH_STA = 'R'
            WHERE MACH_CD = V_MACH_CD
           AND WERKS      = V_WERKS
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
        E_SQL_ERR_CD  := SQLCODE;
        E_SQL_ERR_MSG := SUBSTRB(SQLERRM,1,300);

        ROLLBACK;
        SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);

        RS_CODE := 'E';
        RS_MSG  := SQLERRM;
        RETURN;

    WHEN OTHERS THEN

        E_SQL_ERR_CD  := SQLCODE;
        E_SQL_ERR_MSG := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

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
