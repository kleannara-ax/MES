--------------------------------------------------------
--  DDL for Procedure SP_POP_WRK27_V01_BAK_230126
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK27_V01_BAK_230126" 
(
        P_WERKS          IN VARCHAR2,  --플랜트    
        P_MACH_CD        IN VARCHAR2,  --설비코드 
        P_WRK_LIST       IN CLOB    ,
        P_ABLE_QTY_MAX   IN VARCHAR2,  --INPUT ABLE QTY
        P_USERID         IN VARCHAR2,  --USER ID
        Lang             IN VARCHAR2 DEFAULT 'KO',
        RS_CODE          OUT VARCHAR2,
        RS_MSG           OUT VARCHAR2
)
/*==============================================================================
 * PROGRAM ID    : WRK27{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 포장 실적 투입자재 VALIDATION
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 포장 실적 투입자재 VALIDATION
 *                 
 * AUTHOR NAME   : 우상우{최초 작성자 명 기술}
 * CREATE DATE   : 2023/01/13 {최초 작성일자 기술}
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    DATE        VER       NAME          DESCRIPTION      
 * ------------ ------- ------------- ------------------------------------------
 * YYYY/MM/DD    1.0.0   우상우         INITIAL VERSION 
 *==============================================================================
 *  관련 테이블
 *       -                             
 *=============================================================================*/ 
AS 
        --프로그램 ID : 재단 실적등록
        V_PRG_NM            VARCHAR2(100) := 'SP_POP_WRK27_V01';     -- PROCEDURE NAME
        V_PLT_CD            VARCHAR2(2)   := '99'; --PLANTCODE TEST
        V_SESS_USER_ID      VARCHAR2(20)  := P_USERID; --USERID
        
        -- 오라클 에러 처리용 변수선언 영역
        E_EXCEPTION_USER EXCEPTION;
        E_SQL_ERR_CD        NUMBER(5) := 0;
        E_SQL_ERR_MSG       VARCHAR2(4000);

        -- JSON을 위한 변수선언 영역
        V_JSON              JSON_OBJECT_T;
        V_ARR_LIST          JSON_ARRAY_T;
        V_OBJ               JSON_OBJECT_T;
       
        V_IND_BCD_M          VARCHAR2(100);				--개별바코드
        V_IND_BCD_M_ALL      VARCHAR2(1000);	 
        V_IND_BCD_M_IDX      NUMBER;
        V_MATNR_M            VARCHAR2(100);
        V_ABLE_QTY_TOTAL     NUMBER;
        V_ABLE_QTY_TOTAL_FORMAT  NUMBER;
        V_ABLE_QTY_EACH      NUMBER;
        V_ABLE_QTY_EACH_CHAR VARCHAR2(100);
        
        V_RS_CODE              VARCHAR2(2);     --성공여부
        V_RS_MSG               VARCHAR2(300);   --결과메세지                                
        V_PACK_LABEL_TYPE      VARCHAR2(5);
        V_INFO            VARCHAR2(1000);     
    BEGIN

       BEGIN 
           --JSON 입력 데이터 수신
           V_JSON := JSON_OBJECT_T.PARSE(P_WRK_LIST);
           V_ARR_LIST := V_JSON.GET_ARRAY('list');
           V_ABLE_QTY_TOTAL := 0;
           V_ABLE_QTY_EACH := 0;
           V_IND_BCD_M_ALL := '';
           V_IND_BCD_M_IDX := 0;
           
           FOR I IN 0..V_ARR_LIST.GET_SIZE - 1 LOOP
                V_OBJ := TREAT(V_ARR_LIST.GET(I) AS JSON_OBJECT_T);
                V_OBJ := TREAT(V_OBJ.GET('map') AS JSON_OBJECT_T);

                V_IND_BCD_M         := V_OBJ.GET_STRING('IND_BCD');                   --재단 개별바코드
                V_MATNR_M           := V_OBJ.GET_STRING('MATNR');                     --재단 자재
                
                SELECT  SUM(ABLE_QTY) INTO V_ABLE_QTY_EACH       
                FROM 
                (
                    SELECT DISTINCT
                           ROUND(FN_CHG_UNIT (  I003.MATNR, 'P100', I003.UNIT, 'R', NVL(I003.IN_QTY,0) - NVL(I003.USE_QTY,0)) , 3) ABLE_QTY        --가용량
                      FROM TB_INV003 I003
                         , TB_INV001 I001
                     WHERE 1=1
                       AND I003.WERKS            = I001.WERKS(+)
                       AND I003.IND_BCD          = I001.IND_BCD(+)
                       AND I003.WERKS            = P_WERKS
--                           AND I003.MACH_CD          = P_MACH_CD
                       AND I003.IND_BCD          = V_IND_BCD_M
                       AND I003.MATNR            = V_MATNR_M
                       AND I003.STCK_QTY         > 0
                       AND ROUND(FN_CHG_UNIT (  I003.MATNR, 'P100', I003.UNIT, 'R', NVL(I003.IN_QTY,0) - NVL(I003.USE_QTY,0) ), 3) > 0
                    UNION ALL
                    SELECT DISTINCT
                            NVL(I003.IN_QTY,0) - NVL(I003.USE_QTY,0)  ABLE_QTY        --가용량
                      FROM TB_INV003 I003
                         , TB_SCH020 S020
                         , TB_SCH019 S019
                     WHERE 1=1
                       AND I003.WERKS            = S020.WERKS
                       AND I003.LOT_NO           = S020.LOT_NO
                       AND S020.WRK_ORDR_NO      = S019.WRK_ORDR_NO
                       AND S020.WRK_ORDR_SEQNO   = S019.WRK_ORDR_SEQNO
                       AND I003.WERKS            = P_WERKS
--                           AND I003.MACH_CD          = P_MACH_CD
                       AND I003.IND_BCD          = V_IND_BCD_M
                       AND I003.MATNR            = V_MATNR_M
                       AND NVL(I003.IN_QTY,0) - NVL(I003.USE_QTY,0)  > 0
                );
                
                V_ABLE_QTY_EACH_CHAR := TO_CHAR(V_ABLE_QTY_EACH);
                
                V_INFO := V_INFO || '(MATNR:' || V_MATNR_M || ',IND_BCD:' || V_IND_BCD_M|| ',ABLE_QTY:' || TO_CHAR(V_ABLE_QTY_EACH_CHAR, 'FM99990.00') || ')';
                V_INFO := V_INFO || ' ';
                
                V_ABLE_QTY_TOTAL := V_ABLE_QTY_TOTAL + NVL(V_ABLE_QTY_EACH,0);
                                                            
           END LOOP;   --FOR I IN 0..V_ARR_LIST.GET_SIZE - 1 LOOP
           
           IF P_ABLE_QTY_MAX > V_ABLE_QTY_TOTAL THEN
               RS_CODE := 'E';
--               SELECT TO_CHAR(V_ABLE_QTY_TOTAL, 'FM99990.00') INTO V_ABLE_QTY_TOTAL_FORMAT FROM DUAL;
               RS_MSG := '실행 할 수 없습니다.[처리 총 연수'||'('||P_ABLE_QTY_MAX||') > 가용 총 연수'||'('||TO_CHAR(V_ABLE_QTY_TOTAL, 'FM99990.00')||')]' ;
               RS_MSG := RS_MSG ||CHR(10)||CHR(13);
               RS_MSG := RS_MSG || V_INFO;
               RS_MSG := RS_MSG ||CHR(10)||CHR(13);
               RS_MSG := RS_MSG ||'화면을 새로 고침 합니다.';
               
               RETURN;
           END IF;
           
        RS_CODE := 'S';
        RS_MSG := 'SUCCESS';
        --COMMIT;      
        --예외처리(CATCH)
        EXCEPTION
            WHEN E_EXCEPTION_USER THEN
            -- 에러 내역 SET
                E_SQL_ERR_CD := SQLCODE;
                E_SQL_ERR_MSG := SUBSTRB(SQLERRM, 1, 300);
                ROLLBACK;

                SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
                RS_CODE := 'E';
                RS_MSG := SQLERRM;
                RETURN;
            WHEN OTHERS THEN
                E_SQL_ERR_CD := SQLCODE;
                E_SQL_ERR_MSG := 'EXCEPTION OTHER ERROR. ['
                                 || SUBSTR(SQLERRM, 1, 500)
                                 || ']';
                ROLLBACK;
    --            RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
                RAISE;
                RS_CODE := 'E';
                RS_MSG := SQLERRM;
                RETURN;
                --예외처리 종료
        END;
    END;

/
