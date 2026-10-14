--------------------------------------------------------
--  DDL for Procedure SP_POP_WRK05_S03
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK05_S03" 
(
    P_WERKS    IN VARCHAR2 
    ,P_MACH_CD   IN VARCHAR2
    ,P_IOTYPE    IN VARCHAR2 
    ,Lang       IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE     OUT VARCHAR2 
    ,RS_MSG      OUT VARCHAR2
    ,CUR_1       OUT SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : POP_WRK05
 * PROGRAM NAME  : 작업자 선택
 * VERSION       : 1.0.1
 * DESCRIPTION   : 현재 투입중인 작업자 정보를 조회한다.
 *                 
 * AUTHOR NAME   : 김기연
 * CREATE DATE   : 2022/05/22
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/05/22    1.0.0   김기연         Initial Version
 *==============================================================================
 *  관련 테이블
 * - [TB_SCH002] : (.R..) 화장지 합지기 생산오더
 * - [TB_SCH011] : (.R..) 화장지 합지기 작업지시
 * - [TB_MAS001] : (.R..) 자재 기준 정보
 * - [TB_WRK001] : (.R..) HL 생산실적 이력
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM			VARCHAR2(100)  := 'SP_POP_WRK05_S03';     -- PROCEDURE NAME
    V_PLT_CD			VARCHAR2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID		VARCHAR2(20) := 'TEST'; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER	EXCEPTION;
    E_SQL_ERR_CD		NUMBER(5) := 0;
    E_SQL_ERR_MSG		VARCHAR2(4000);
    --내부변수 관리
    V_STR_DATE			DATE; --작업투입시간
    V_IOTYPE 			VARCHAR2(10) := CASE WHEN P_WERKS = 'P500' THEN 'N' ELSE P_IOTYPE END;
BEGIN
    --예외처리 시작(try)
    BEGIN
        BEGIN
            --현재 진행중인 투입이력 조회(없을경우 현재시간)
            BEGIN
            SELECT STR_DATE INTO V_STR_DATE
              FROM TB_WRK013
             WHERE 1=1
               AND WERKS = P_WERKS
               AND MACH_CD = P_MACH_CD
               AND IN_OUT = V_IOTYPE
               AND END_DATE IS NULL;
            EXCEPTION WHEN NO_DATA_FOUND THEN  
                V_STR_DATE := SYSDATE;
            END;

            --현재 투입현황 조회
            OPEN CUR_1 FOR
            SELECT WRK_CLASS
                 , EMPLY_NO
                 , WRKER_CNT
                 , V_STR_DATE AS PRD_STR_DATE
                 , WRK_SHIFT
                 , C001.CDESC1 AS WRK_SHIFT_NM
                 , '[' || C001.CDESC1 || '] ' || M027.STR_TM || ' ~ ' || M027.END_TM AS Display
              FROM TB_WRK011 W011, TB_MAS027 M027, CMCDV C001
             WHERE 1=1
               AND W011.MACH_CD = M027.MACH_CD(+)
               AND W011.WRK_SHIFT = M027.WRK_METH(+)
               AND W011.WRK_SHIFT = C001.CMCDVL(+)
               AND C001.CMCDKY = 'WRKMETH'
               AND W011.WERKS = P_WERKS
               AND W011.MACH_CD = P_MACH_CD
               AND W011.IN_OUT = V_IOTYPE;
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
        E_SQL_ERR_CD        := -20001;
        E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

        ROLLBACK;
        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);

        RS_CODE := 'E';
        RS_MSG  := SQLERRM;
        RETURN;
    --예외처리 종료
    END;
END SP_POP_WRK05_S03;


/
