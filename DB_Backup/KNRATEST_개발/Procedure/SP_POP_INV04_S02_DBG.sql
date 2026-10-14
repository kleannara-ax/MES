--------------------------------------------------------
--  DDL for Procedure SP_POP_INV04_S02_DBG
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_INV04_S02_DBG" 
(
    P_WERKS      IN VARCHAR2                --플랜트코드
    ,P_MACH_CD   IN VARCHAR2                --작업장
--    ,P_PCODE     IN VARCHAR2                --지종
--    ,P_WEIGHT    IN VARCHAR2                --평량
--    ,P_WLEN      IN VARCHAR2                --가로
--    ,P_VLEN      IN VARCHAR2                --세로
--    ,P_IND_BCD_LOTNO    IN VARCHAR2         --개별바코드 or LOT_NO  
    ,Lang        IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE     OUT VARCHAR2 
    ,RS_MSG      OUT VARCHAR2
    ,CUR_1       OUT SYS_REFCURSOR
    ,CUR_2       OUT SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : SP_POP_INV04_S02{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 재단 대기 창고 조회
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 재단 대기 창고 조회{프로그램에 대한 상세한 내용 기술}
 *                 
 * AUTHOR NAME   : 김병무{최초 작성자 명 기술}
 * CREATE DATE   : 2022/07/21 {최초 작성일자 기술}
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/07/20    1.0.0   김병무         Initial Version 
 *==============================================================================
 *  관련 테이블
 *       - [TB_INV001] : 공정 투입
 *       - [TB_MAS028] : 로케이션 관리
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM        VARCHAR2(100)  := 'SP_POP_INV04_S02';     -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID   varchar2(20) := 'TEST'; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);
    --parameter변수 처리

BEGIN
    --예외처리 시작(try)
    BEGIN
        BEGIN
            --결과 테이블 반환용 변수
            OPEN CUR_1 FOR
            SELECT LOC_CD   LOC_CD
                   , LOC_NM   LOC_NM
              FROM TB_MAS028
                WHERE WERKS   = P_WERKS 
                  AND MACH_CD = P_MACH_CD
                  AND USE_YN  = 'Y';

            OPEN CUR_2 FOR
            --재단 대기창고 조회
            SELECT *
              FROM (
            SELECT    I001.LOC_CD           LOC_CD
                    , I001.IND_BCD || '|' || 
                    CASE WHEN NVL(I001.IN_MR_YN, 'N') =  'N'  THEN 
                        CASE WHEN (SELECT COUNT(*)
                            FROM TB_SCH017
                           WHERE PRE_ORDER_NO = I001.ORDER_NO  AND USE_YN = 'Y') >0 THEN
                                (SELECT SUBSTR(S017.MATNR, 3, 3) || '/' || SUBSTR(S017.MATNR, 6, 3) || '|' || SUBSTR(S017.MATNR, 10, 4) || '*' || SUBSTR(S017.MATNR, 14, 4) 
                                FROM TB_SCH017 S017
                               WHERE S017.PRE_ORDER_NO = I001.ORDER_NO 
                                 AND S017.USE_YN = 'Y')
                           ELSE
                            SUBSTR(I001.MATNR, 3, 3) || '/' || SUBSTR(I001.MATNR, 6, 3) || '|' || SUBSTR(I001.MATNR, 10, 4) || '*' || SUBSTR(I001.MATNR, 14, 4) 
                           END
--                        ( SELECT SUBSTR(S017.MATNR, 3, 3) || '/' || SUBSTR(S017.MATNR, 6, 3) || '|' || SUBSTR(S017.MATNR, 10, 4) || '*' || SUBSTR(S017.MATNR, 14, 4) 
--                            FROM TB_SCH017 S017
--                           WHERE S017.PRE_ORDER_NO = I001.ORDER_NO 
--                             AND S017.USE_YN = 'Y'
--                        )
                    ELSE
                        CASE WHEN (SELECT COUNT(*)
                            FROM TB_SCH017
                           WHERE PRE_ORDER_NO = I001.LOT_NO AND USE_YN = 'Y') >0 THEN
                                (SELECT SUBSTR(S017.MATNR, 3, 3) || '/' || SUBSTR(S017.MATNR, 6, 3) || '|' || SUBSTR(S017.MATNR, 10, 4) || '*' || SUBSTR(S017.MATNR, 14, 4) 
                                FROM TB_SCH017 S017
                               WHERE S017.PRE_ORDER_NO = I001.LOT_NO
                                 AND S017.USE_YN = 'Y')
                           ELSE
                            SUBSTR(I001.MATNR, 3, 3) || '/' || SUBSTR(I001.MATNR, 6, 3) || '|' || SUBSTR(I001.MATNR, 10, 4) || '*' || SUBSTR(I001.MATNR, 14, 4) 
                           END
--                        ( SELECT SUBSTR(S017.MATNR, 3, 3) || '/' || SUBSTR(S017.MATNR, 6, 3) || '|' || SUBSTR(S017.MATNR, 10, 4) || '*' || SUBSTR(S017.MATNR, 14, 4) 
--                            FROM TB_SCH017 S017
--                           WHERE S017.PRE_ORDER_NO = I001.LOT_NO 
--                             AND S017.USE_YN = 'Y'
--                        )
                    END    
                    || '@' || I001.MACHINE
                    || '@' || NVL(I001.MR_WH_YN, 'N')     LOC_INFO
                    , ROW_NUMBER() OVER(PARTITION BY I001.LOC_CD ORDER BY WC001.IF_DATE) AS SEQ
                    FROM TB_INV001 I001
                        , TB_MAS001 M001
                        , TB_MAS028 M028
                        , TB_IFRWC001 WC001
                    WHERE I001.WERKS = P_WERKS
                    AND I001.LOC_CD = M028.LOC_CD(+)
                    AND I001.MATNR = M001.MATNR(+)
                    --AND I001.ORDER_NO = S017.PRE_ORDER_NO(+)
                    AND I001.STOR_LOC_CD = '2700'
                    AND I001.LOC_CD = WC001.TO_LOC(+)
                    AND I001.IND_BCD = WC001.BARCODE(+)
                    AND I001.LOT_NO  = WC001.LOT_ID(+)                    
                    AND M028.MACH_CD = P_MACH_CD
                    --AND M028.USE_YN  = 'Y'
                    --AND S017.USE_YN  = 'Y'
                    AND STCK_QTY > 0
                    AND STCK_STA = '00'     -- 재고상태(00:정상, 10:투입, 20:생산실적, 30:불용, 40:부적합, 50:폐기)
                    AND WC001.IF_SEQ||BARCODE IN (SELECT TO_CHAR(MAX(IF_SEQ)) || BARCODE FROM TB_IFRWC001 WHERE IF_DATE > SYSDATE - 120 GROUP BY BARCODE )
                    ORDER BY I001.LOC_CD)
                    PIVOT (
                     MAX(LOC_INFO)
                     FOR LOC_CD IN ('MR01' MR01, 'MR02' MR02, 'MR03' MR03, 'MR04' MR04, 'MR05' MR05, 'MR06' MR06, 'MR07' MR07, 'MR08' MR08, 'MR09' MR09, 'MR10' MR10, 
                                    'MR11' MR11, 'MR12' MR12, 'MR13' MR13, 'MR14' MR14, 'MR15' MR15, 'MR16' MR16, 'MR17' MR17, 'MR18' MR18, 'MR19' MR19, 'MR20' MR20,
                                    'MR21' MR21, 'MR22' MR22, 'MR23' MR23, 'MR24' MR24, 'MR25' MR25, 'MR26' MR26, 'MR27' MR27, 'MR28' MR28, 'MR29' MR29, 'MR30' MR30, 
                                    'MR31' MR31, 'MR32' MR32, 'MR33' MR33, 'MR34' MR34, 'MR35' MR35, 'MR36' MR36, 'MR37' MR37, 'MR38' MR38, 'MR39' MR39, 'MR40' MR40, 
                                    'MR41' MR41, 'MR42' MR42, 'MR43' MR43, 'MR44' MR44, 'MR45' MR45)
                   )
                   WHERE ROWNUM <= 200   --개수 제한 40개
                   ORDER BY SEQ ASC;

            --작업 정상 종료 코드 등록
            RS_CODE := 'S';
        END;
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
        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);

        RS_CODE := 'E';
        RS_MSG  := SQLERRM;
        RETURN;
    --예외처리 종료
    END;
END;

/
