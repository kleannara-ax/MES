
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_WCS_HISTORY_SAVE" 
(
     P_ORDER_NO         IN VARCHAR2     /* 작업요청번호 (KEY) */
    ,P_ORDER_TYPE	    IN VARCHAR2     /* 작업요청 타입 'IN' */
    ,P_PLANT_CD	        IN VARCHAR2     /* 작업장 코드 */
    ,P_MATNR	        IN VARCHAR2     /* 자재 코드 */
    ,P_MATNR_NM	        IN VARCHAR2     /* 자재명 */
    ,P_LOT_NO	        IN VARCHAR2     /* LOT_NO */
    ,P_IND_BCD	        IN VARCHAR2     /* 개별 바코드 */
    ,P_UNIT	            IN VARCHAR2     /* 단위 */
    ,P_QTY	            IN VARCHAR2     /* 수량 */
    ,P_MACH_CD	        IN VARCHAR2     /* 호기 정보 */
    ,P_SUCCESS_CHK	    IN VARCHAR2     /* 호출 성공 유무 (S, E) */
    ,P_SUCCESS_CHK_MSG  IN VARCHAR2     /* 호출 RETURN 메세지 */
    ,P_USER_ID	        IN VARCHAR2     /* 등록자 */
    ,P_RESULT           OUT VARCHAR2    /* 결과값 */
)
/*==============================================================================
 * PROGRAM ID    : SP_WCS_HISTORY_SAVE
 * PROGRAM NAME  : SAP
 * VERSION       : 1.0.0
 * DESCRIPTION   : WCS 호출 이력 저장
 *
 * AUTHOR NAME   : 김지언
 * CREATE DATE   : 2025/02/26
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description
 * ------------ ------- ------------- ------------------------------------------
 * 2025/02/20    1.0.0   김지언         WCS 호출
 *==============================================================================
 *  관련 테이블
 * - [TB_WRK025] : (.R..) WCS 호출 이력 테이블
 *=============================================================================*/
AS
    --프로그램 ID
    V_PRG_NM                VARCHAR2(100)  := 'SP_WCS_HISTORY_SAVE';     -- PROCEDURE NAME
    V_SESS_USER_ID          VARCHAR2(20) := P_USER_ID;

    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER        EXCEPTION;
    E_SQL_ERR_CD            NUMBER(5) := 0;
    E_SQL_ERR_MSG           VARCHAR2(4000);

    --내부변수 관리
    V_ORDER_NO              TB_WRK025.ORDER_NO%TYPE;
    V_ORDER_NO_SEQ          TB_WRK025.ORDER_NO_SEQ%TYPE;
BEGIN
    BEGIN
        /* 작업요청번호의 SEQ 채번 */
        SELECT NVL(MAX(ORDER_NO_SEQ), 0) + 1
            INTO V_ORDER_NO_SEQ
        FROM TB_WRK025
        WHERE 1=1
            AND ORDER_NO = P_ORDER_NO;

        SZP_MES_PLSQL_LOG(P_ORDER_NO, 'WCS_HIST_SAV-E');
        SZP_MES_PLSQL_LOG(V_ORDER_NO_SEQ, 'WCS_HIST_SAVE');

        INSERT INTO TB_WRK025 (ORDER_NO,
                               ORDER_NO_SEQ,
                               PLANT_CD,
                               MATNR,
                               MATNR_NM,
                               LOT_NO,
                               IND_BCD,
                               UNIT,
                               QTY,
                               MACH_CD,
                               SUCCESS_CHK,
                               SUCCESS_CHK_MSG,
                               REGDATE,
                               REGID)
        VALUES (P_ORDER_NO, V_ORDER_NO_SEQ, P_PLANT_CD,
                P_MATNR, P_MATNR_NM, P_LOT_NO, P_IND_BCD,
                P_UNIT, P_QTY, P_MACH_CD, P_SUCCESS_CHK,
                P_SUCCESS_CHK_MSG, SYSDATE, V_SESS_USER_ID);

        IF SQL%ROWCOUNT = 0 THEN
            SZP_MES_PLSQL_LOG('4', 'SP_WCS_HISTORY_SAVE');
            RAISE E_EXCEPTION_USER;
        end if;

        P_RESULT := 'S';
    EXCEPTION
        WHEN E_EXCEPTION_USER THEN
            E_SQL_ERR_MSG := SQLERRM;
            DBMS_OUTPUT.PUT_LINE('예외발생 INSERT 실패 : ' || SQLERRM);
            SZP_MES_PLSQL_LOG('예외발생 : ' || E_SQL_ERR_MSG, 'WCS_HISTORY_SAVE');
            ROLLBACK;
        WHEN OTHERS THEN
            E_SQL_ERR_MSG := SQLERRM;
            DBMS_OUTPUT.PUT_LINE('예외발생 : ' || E_SQL_ERR_MSG);
            SZP_MES_PLSQL_LOG('예외발생 : ' || E_SQL_ERR_MSG, 'WCS_HISTORY_SAVE');
            ROLLBACK;
            RAISE;
    END;
END SP_WCS_HISTORY_SAVE;
/
