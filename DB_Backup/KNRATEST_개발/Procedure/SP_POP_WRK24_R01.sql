--------------------------------------------------------
--  DDL for Procedure SP_POP_WRK24_R01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK24_R01" 
(
     P_DOC_NO           IN VARCHAR2                     --문서번호
    ,P_DOC_SEQNO        IN VARCHAR2                     --문서번호 순번
    ,P_USERID           IN VARCHAR2                     --USER ID
    ,Lang       		IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE     		OUT VARCHAR2 
    ,RS_MSG      		OUT VARCHAR2
)
/*==============================================================================
 * PROGRAM ID    : SP_POP_WRK24_R02  {호출 프로그램 ID 기술}
 * PROGRAM NAME  : 점보롤 실적등록 롤백 
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 점보롤 실적등록 롤백용
 *                 
 * AUTHOR NAME   : 이성민{최초 작성자 명 기술}
 * CREATE DATE   : 2022/10/22 {최초 작성일자 기술}
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/10/22    1.0.0   이성민         Initial Version 
 *==============================================================================
 *  관련 테이블
 *=============================================================================*/

AS 
    --프로그램 ID : 점보롤 실적취소 
    V_PRG_NM        VARCHAR2(100)  := 'SP_POP_WRK24_R01';    -- PROCEDURE NAME
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
    V_MATNR			    TB_SCH015.MATNR%TYPE;
    V_SAP_WRK_CD        TB_MAS012.SAP_WRK_CD%TYPE;
    V_RUN_STA           TB_WRK011.RUN_STA%TYPE;
    V_TOT_QTY           TB_WRK002.PRFM_QTY%TYPE;
    V_ROLLCNT 			TB_WRK002.ROLLCNT%TYPE;
    V_STR_DTM 			TB_WRK011.PRD_STR_DTM%TYPE;
    
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
                RS_MSG       := 'ROLLBACK[SP_POP_WRK24_R01] 문서번호가 조회되지 않습니다';
                ROLLBACK;
                RETURN;
            WHEN OTHERS THEN
                RS_CODE      := 'E';
                RS_MSG       := 'ROLLBACK[SP_POP_WRK24_R01] ERROR';
                ROLLBACK;
                RETURN;
    END;


    BEGIN
            SELECT ROLLCNT    ,     TO_CHAR(PRD_STR_DATE, 'YYYYMMDDHHMISS')    
              INTO V_ROLLCNT  ,     V_STR_DTM  
              FROM TB_WRK002
             WHERE WERKS   = V_WERKS
               AND MACH_CD = V_MACH_CD
               AND IND_BCD = V_IND_BCD
               --AND NVL(CNL_YN,'N') = 'N'
               ;
    EXCEPTION
            WHEN NO_DATA_FOUND THEN
                V_ROLLCNT := 0;
            WHEN OTHERS THEN
                V_ROLLCNT := 0;
    END;


    BEGIN
            SELECT ORDER_NO   ,  MATNR 
              INTO V_ORDER_NO ,V_MATNR
              FROM TB_SCH015
             WHERE WRK_ORDR_NO    = V_WRK_ORDR_NO
               AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
               ;
    EXCEPTION
            WHEN NO_DATA_FOUND THEN
                V_ORDER_NO := '';
            WHEN OTHERS THEN
                V_ORDER_NO := '';
    END;
   
    IF NVL(V_MATNR, ' ' ) <> ' ' THEN
        V_RUN_STA := '09';
    ELSE
        V_RUN_STA := '01';
    END IF;

    IF V_ROLLCNT > 0 THEN  
    
        UPDATE  TB_SCH015   
           SET  COMP_YN = 'N'
         WHERE WRK_ORDR_NO   = V_WRK_ORDR_NO
          AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
          ;
        SELECT SAP_WRK_CD INTO V_SAP_WRK_CD
          FROM TB_MAS012
          WHERE MACH_CD = V_MACH_CD
          ;

        UPDATE TB_WRK002     --실적테이블(PS)
           SET CNL_YN = 'Y',
           	   ROL_YN = 'Y',
               CNL_RMK = 'ROLLBACK '||P_DOC_NO|| ' '||TO_CHAR(DOC_SEQNO)  ,
               --ROLLCNT = ROLLCNT - V_ROLLCNT ,
               UPDDATE = SYSDATE,
               UPDID   = P_USERID
          WHERE WERKS   = V_WERKS
            AND MACH_CD = V_MACH_CD
            AND IND_BCD = V_IND_BCD
            --AND NVL(CNL_YN,'N') = 'N'
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
        --[김병무:2022-07-19] 점보롤에서 투입자재 추가 하여 실적취소 시 삭제 기능 추가
        DELETE FROM TB_WRK008     --LOT 추적
         WHERE WERKS   = V_WERKS
           AND IND_BCD   = V_IND_BCD;



                -- 점보롤 완료인경우 TB_WRK011(작업장(설비)별 현재 진행현황) 테이블 업데이트 진행
                -- 작업진행중인 작업지시번호 -> 이전작업지시번호, 작업지시순번 -> 이전작업지시순번으로 이동
                -- 자재번호, 작업지시번호, 작업지시순번 삭제
        UPDATE TB_WRK011
           SET MATNR = V_MATNR,
               WRK_ORDR_NO = V_WRK_ORDR_NO, 
               WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO,
               ORDER_NO = V_ORDER_NO,
           	   PRE_WRK_ORDR_NO = V_WRK_ORDR_NO, 
               MACH_STA = 'R',
               RUN_STA = V_RUN_STA
         WHERE MACH_CD = V_MACH_CD
           AND WERKS   = V_WERKS
           AND MATNR          IS NULL
           AND WRK_ORDR_NO    IS NULL
           AND WRK_ORDR_SEQNO IS NULL
           AND ORDER_NO       IS NULL; 
    END IF;  
    UPDATE TB_WRK011
    SET PRD_STR_DTM = V_STR_DTM
    WHERE MACH_CD = V_MACH_CD
    AND   WERKS   = V_WERKS;

    BEGIN
            SELECT ROLLCNT          
              INTO V_ROLLCNT         
              FROM TB_WRK004
             WHERE WERKS   = V_WERKS
               AND MACH_CD = V_MACH_CD
               AND IND_BCD = V_IND_BCD
               --AND NVL(CNL_YN,'N') = 'N'
               ;
    EXCEPTION
            WHEN NO_DATA_FOUND THEN
                V_ROLLCNT := 0;
            WHEN OTHERS THEN
                V_ROLLCNT := 0;
    END;


    BEGIN
            SELECT ORDER_NO
              INTO V_ORDER_NO
              FROM TB_SCH015
             WHERE WRK_ORDR_NO   = V_WRK_ORDR_NO
               AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
               ;
    EXCEPTION
            WHEN NO_DATA_FOUND THEN
                V_ORDER_NO := '';
            WHEN OTHERS THEN
                V_ORDER_NO := '';
    END;

    IF V_ROLLCNT > 0 THEN   --폐품수량
    
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
    UPDATE  TB_SCH015
       SET  COMP_YN = 'N'
     WHERE WRK_ORDR_NO   = V_WRK_ORDR_NO
       AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
    ;  

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
