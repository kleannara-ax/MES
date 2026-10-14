--------------------------------------------------------
--  DDL for Procedure SP_POP_WRK27_R01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK27_R01" 
(
     P_DOC_NO           IN VARCHAR2                     --문서번호
    ,P_DOC_SEQNO        IN VARCHAR2                     --문서번호 순번
    ,P_USERID           IN VARCHAR2                     --USER ID
    ,Lang               IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE            OUT VARCHAR2 
    ,RS_MSG             OUT VARCHAR2
)
/*==============================================================================
 * PROGRAM ID    : SP_POP_WRK27_R01{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 포장 MES ROLLBACK 
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 포장 MES ROLLBACK 
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
    V_PRG_NM         VARCHAR2(100) := 'SP_POP_WRK27_R01';  -- PROCEDURE NAME
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
    V_PRFM_QTY          TB_WRK002.PRFM_QTY%TYPE;      --실적수량
    V_MRLDCK            TB_WRK002.MRLDCK%TYPE;        --밀롤창고적치여부
    V_IND_BCD_M         TB_WRK002.IND_BCD%TYPE;       --자재개별바코드
    V_TOT_QTY           TB_WRK002.PRFM_QTY%TYPE;    
    V_DISPO_QTY         TB_WRK004.DISPO_QTY%TYPE;    --폐품수량
    V_DISPO_WGT         TB_WRK004.WGT%TYPE;          --폐품중량
    V_MATNR_M           TB_WRK004.MATNR%TYPE;        --자재코드
    V_ROLLCNT           TB_WRK002.ROLLCNT%TYPE;     
    
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
    V_INP_DT            TB_INV003.INP_DT%TYPE;        --투입일자
    
    V_DOC_DIV           TB_WRK021.DOC_DIV%TYPE;
    V_DOC_NO_M          VARCHAR2(20);
    V_DOC_NO_INPUT      VARCHAR2(20);
    V_DOC_SEQNO         NUMBER;
    V_DOC_SEQNO_DISPO   NUMBER;
    V_PRFM_DT           TB_WRK002.PRFM_DT%TYPE;
    V_LOT_NO            TB_WRK002.LOT_NO%TYPE;
    V_LOT_NO_M          TB_WRK004.LOT_NO_M%TYPE;
    V_WGT               NUMBER(13,3);
    V_DMY               VARCHAR2(1);          
    V_GRD_YN            VARCHAR2(5);  
    V_MAN_CUT_YN        VARCHAR2(1);
    V_RUN_STA           VARCHAR2(5);
    V_EXPROD            VARCHAR2(5);
    V_COUNT             NUMBER;
    V_SQL               VARCHAR2(4000);
    V_DATE              DATE := SYSDATE;
    
BEGIN
  BEGIN
    
    V_DOC_SEQNO       := 0;
    V_DOC_SEQNO_DISPO := 0;
   
    -- ROLLBACK 문서번호 SELECT---------------------------------------------------------------------------------
 
        -- 실적 취소----------------------------------------------------------------------------
        BEGIN
                SELECT WRK_ORDR_NO, WRK_ORDR_SEQNO, ORDER_NO, STA, SDOC_NO, SDOC_SEQNO, 
                       PRFM_QTY, ROLLCNT, LOT_NO,WGT,PRFM_DT,GRD_YN,
                       WERKS, MACH_CD, IND_BCD
                  INTO V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_ORDER_NO, V_STA, V_SDOC_NO, V_SDOC_SEQNO,
                       V_PRFM_QTY, V_ROLLCNT, V_LOT_NO,V_WGT,V_PRFM_DT,V_GRD_YN, 
                       V_WERKS, V_MACH_CD, V_IND_BCD
                  FROM TB_WRK002
                 WHERE DOC_NO   = P_DOC_NO
                   AND DOC_SEQNO = P_DOC_SEQNO
                   AND NVL(CNL_YN,'N') != 'Y'
                   ;
        EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    V_ROLLCNT := 0;
                    V_PRFM_QTY := 0;
                WHEN OTHERS THEN
                    V_ROLLCNT := 0;
                    V_PRFM_QTY := 0;
        END;
        
        BEGIN
                SELECT ORDER_NO  
                  INTO V_ORDER_NO 
                  FROM TB_SCH018
                 WHERE WRK_ORDR_NO    = V_WRK_ORDR_NO
                   AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
                   ;

        EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    V_ORDER_NO := '';
                WHEN OTHERS THEN
                    V_ORDER_NO := '';
        END;
        
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
        FOR INV010 IN (
                    SELECT I010.IND_BCD_M   V_IND_BCD_M  -- 자재개별바코드    
                         , I010.USE_QTY     V_USE_QTY    
                      FROM TB_INV010 I010  --자재투입이력   
                     WHERE I010.WERKS   = V_WERKS
                       AND I010.MACH_CD = V_MACH_CD
                       AND I010.IND_BCD = V_IND_BCD
                  )
            LOOP
                
                UPDATE TB_INV003                         --자재투입
                       SET STCK_QTY = NVL(STCK_QTY, 0) + (INV010.V_USE_QTY /* * 500 */)
                         , USE_QTY  = NVL(USE_QTY, 0)  - (INV010.V_USE_QTY /* * 500 */)
                 WHERE WERKS = V_WERKS
                 AND IND_BCD = INV010.V_IND_BCD_M;
            END LOOP ;
        
            UPDATE TB_SCH018
               SET COMP_YN      = 'N'
            WHERE WRK_ORDR_NO    = V_WRK_ORDR_NO
              AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO;

            UPDATE  TB_INV010  SET CNL_YN = 'Y',    --자재투입이력
            					   ROL_YN = 'Y'
             WHERE WERKS   = V_WERKS
               AND MACH_CD = V_MACH_CD
               AND IND_BCD = V_IND_BCD ;
           
            DELETE FROM TB_WRK008     --LOT 추적
             WHERE WERKS   = V_WERKS
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
           
             UPDATE TB_INV001
                SET STCK_QTY = 0,
                    DLFL = 'Y',
                    ROL_YN = 'Y',
                    UPDDATE = SYSDATE,
                    UPDID   = P_USERID
              WHERE WERKS = V_WERKS
                AND MACH_CD = V_MACH_CD
                AND IND_BCD = V_IND_BCD;
               
        END IF;
        -------------------------------------------------------------------------------------    
        -- 폐품 취소 ( 폐품실적, 영업폐품, 잔량폐품 )            
        -- 폐품실적 취소 -----------------------------------------------------------------
        V_DISPO_WGT := 0 ;
        BEGIN
                SELECT WRK_ORDR_NO, WRK_ORDR_SEQNO, SDOC_NO, SDOC_SEQNO, DISPO_QTY, WGT, ROLLCNT, PRFM_DT, LOT_NO_M,IND_BCD_M,GRD_YN,
                       WERKS, MACH_CD, IND_BCD
                  INTO V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_SDOC_NO, V_SDOC_SEQNO, V_DISPO_QTY, V_DISPO_WGT, V_ROLLCNT,V_PRFM_DT,V_LOT_NO,V_IND_BCD_M,V_GRD_YN,
                       V_WERKS, V_MACH_CD, V_IND_BCD
                  FROM TB_WRK004
                WHERE DOC_NO   = P_DOC_NO
                AND DOC_SEQNO = P_DOC_SEQNO
                AND NVL(CNL_YN,'N') != 'Y';
        EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    V_ROLLCNT := 0;
                    V_DISPO_WGT := 0;
                WHEN OTHERS THEN
                    V_ROLLCNT := 0;
                    V_DISPO_WGT := 0;
        END;
        
        BEGIN
                SELECT ORDER_NO 
                  INTO V_ORDER_NO 
                  FROM TB_SCH018
                 WHERE WRK_ORDR_NO    = V_WRK_ORDR_NO
                   AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
                   ;

        EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    V_ORDER_NO := '';
                WHEN OTHERS THEN
                    V_ORDER_NO := '';
        END;

        IF V_DISPO_WGT > 0 THEN   --폐품수량
        
            UPDATE TB_SCH018
               SET COMP_YN      = 'N'
             WHERE WRK_ORDR_NO    = V_WRK_ORDR_NO
               AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO;        
            
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
               AND IND_BCD = V_IND_BCD ;
            ------------------------------------------------------------
            UPDATE TB_INV003    --자재투입
               SET STCK_QTY  = NVL(STCK_QTY, 0)  + V_DISPO_QTY
                 , USE_QTY   = NVL(USE_QTY, 0)   - V_DISPO_QTY
                 , DISPO_QTY = NVL(DISPO_QTY, 0) - V_DISPO_QTY
             WHERE WERKS   = V_WERKS
               AND IND_BCD = V_IND_BCD_M ;
               
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

        UPDATE TB_SCH018
           SET COMP_YN      = 'N', PRFM_QTY = V_TOT_QTY
        WHERE WRK_ORDR_NO    = V_WRK_ORDR_NO
          AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO;
        
        --YSH 2022.09.22
        UPDATE TB_WRK502
           SET PROC_YN = 'N',
               CNL_YN = 'Y',
               ROL_YN = 'Y'
         WHERE WERKS = V_WERKS
           AND MACH_CD = V_MACH_CD
           AND IND_BCD = V_IND_BCD;
       
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
