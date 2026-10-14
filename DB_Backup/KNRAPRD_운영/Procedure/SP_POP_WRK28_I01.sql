--------------------------------------------------------
--  DDL for Procedure SP_POP_WRK28_I01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK28_I01" 
(
     P_WERKS     		IN VARCHAR2 	                --플랜트
    ,P_MACH_CD   		IN VARCHAR2 	                --설비코드
    ,P_SDATE        IN VARCHAR2                   --작업시작시간(YYYYMMDDHHMMSS)
    ,P_USERID       IN VARCHAR2                   --USER ID
    ,Lang       		IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE     		OUT VARCHAR2 
    ,RS_MSG      		OUT VARCHAR2
)
/*==============================================================================
 * PROGRAM ID    : WRK28{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 슬리터예외작업시작
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : .{프로그램에 대한 상세한 내용 기술}
 *                 
 * AUTHOR NAME   : 강현주{최초 작성자 명 기술}
 * CREATE DATE   : 2022/06/20 {최초 작성일자 기술}
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/06/20    1.0.0   강현주         Initial Version 
 *==============================================================================
 *  관련 테이블
 *       - [TB_WRK011] : (.RU.) 설비별 현재진행사항 
 *       - [TB_WRK012] : (C.U.) 설비별 현재진행사항 
 *       - [TB_SCH016] : (.R..) 밀롤,슬리터 작업지지서
 *=============================================================================*/

AS 
    --프로그램 ID : 슬리터예외 작업시작
    V_PRG_NM        VARCHAR2(100)  := 'SP_POP_WRK28_I01';     -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID   varchar2(20) := 'TEST'; --USERID

    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);

    --parameter변수 처리
    V_MATNR                     TB_WRK002.MATNR%TYPE;
    V_WRK_ORDR_NO               TB_WRK002.WRK_ORDR_NO%TYPE;
    V_WRK_ORDR_SEQNO            TB_WRK002.WRK_ORDR_SEQNO%TYPE;
    V_ORDER_NO                  TB_WRK002.ORDER_NO%TYPE;
    V_ORDER_NO_MR               TB_WRK002.ORDER_NO%TYPE;

    V_UDTM              VARCHAR2(2);    --업데이트하는경우
    V_REGDATE           DATE := SYSDATE;
BEGIN

    BEGIN
        SELECT ORDER_NO INTO  V_ORDER_NO 
        FROM TB_WRK011
        WHERE WERKS = P_WERKS
        AND MACH_CD = P_MACH_CD;

        SELECT
                WRK_ORDR_NO      WRK_ORDR_NO    
              , WRK_ORDR_SEQNO   WRK_ORDR_SEQNO
              , MATNR            MATNR
              , ORDER_NO         ORDER_NO 
        INTO V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_MATNR, V_ORDER_NO_MR
        FROM 
        (
            SELECT WRK_ORDR_NO      WRK_ORDR_NO    
                 , WRK_ORDR_SEQNO   WRK_ORDR_SEQNO
                 , MATNR            MATNR
                 , ORDER_NO         ORDER_NO 
                 , ORDER_NUM        ORDER_NUM
                 , ORDER_SEQ        ORDER_SEQ 
            FROM TB_SCH016
            WHERE WERKS = P_WERKS
            AND PRE_ORDER_NO = V_ORDER_NO
            AND COMP_YN IN ('N', 'I')
            AND ROWNUM = 1
            UNION ALL
            SELECT WRK_ORDR_NO      WRK_ORDR_NO    
                 , WRK_ORDR_SEQNO   WRK_ORDR_SEQNO
                 , MATNR            MATNR
                 , ORDER_NO         ORDER_NO 
                 , NULL             ORDER_NUM
                 , NULL             ORDER_SEQ 
            FROM TB_SCH019
            WHERE WERKS = P_WERKS
              AND ORDER_NO = V_ORDER_NO
              AND COMP_YN IN ('N', 'I')
              AND ROWNUM = 1
        )    
        ORDER BY ORDER_NUM, ORDER_SEQ;


        BEGIN
            SELECT '1' INTO V_UDTM
              FROM TB_WRK012
             WHERE WERKS = P_WERKS
               AND MACH_CD = P_MACH_CD
               AND STR_DATE = TO_DATE(P_SDATE, 'YYYYMMDDHH24MISS')
               AND END_DATE IS NULL;
        EXCEPTION 
            WHEN NO_DATA_FOUND THEN 
                V_UDTM := '0';
        END;


                  
        IF V_UDTM = '1' THEN
            UPDATE TB_WRK012
               SET  WRK_ORDR_NO = V_WRK_ORDR_NO, 
                    WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO, 
                    ORDER_NO = V_ORDER_NO_MR, 
                    MATNR = V_MATNR, 
                    LINE_STA = 'R',
                    REGDATE = V_REGDATE, 
                    REGID = P_USERID
             WHERE WERKS = P_WERKS
               AND MACH_CD = P_MACH_CD
               AND END_DATE IS NULL;
        ELSE
            UPDATE TB_WRK012
            SET END_DATE = TO_DATE(P_SDATE, 'YYYYMMDDHH24MISS')
            WHERE WERKS = P_WERKS
            AND MACH_CD = P_MACH_CD
            AND END_DATE IS NULL;
    
            BEGIN
                INSERT INTO TB_WRK012 ( WERKS, MACH_CD, IN_OUT, STR_DATE, 
                                        WRK_ORDR_NO, WRK_ORDR_SEQNO, ORDER_NO, MATNR, LINE_STA,
                                        REGDATE, REGID)
                              VALUES( P_WERKS, P_MACH_CD, 'N', TO_DATE(P_SDATE, 'YYYYMMDDHH24MISS'),
                                      V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_ORDER_NO_MR, V_MATNR, 'R',
                                      V_REGDATE, P_USERID);   
            EXCEPTION 
                WHEN DUP_VAL_ON_INDEX THEN 
                    RS_CODE := 'E';
                    RS_MSG := '작업시작 일시가 이미 등록되어 있습니다.\n작업시작 일시를 변경 후 작업 시작을 진행하세요';
                    ROLLBACK;
                    RETURN;
            END;
        END IF;
        
        -- 설비 상태를 진행중으로 변경      
        UPDATE TB_WRK011
        SET PRD_STR_DTM = P_SDATE
           ,MACH_STA = 'R'
        WHERE WERKS = P_WERKS
        AND MACH_CD = P_MACH_CD;


        UPDATE TB_SCH016
        SET COMP_YN = 'I'
        WHERE WERKS      = P_WERKS
        AND PRE_ORDER_NO = V_ORDER_NO
        ;

        UPDATE TB_SCH019
        SET COMP_YN = 'I'
        WHERE WERKS    = P_WERKS
        AND   ORDER_NO = V_ORDER_NO
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
