
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK40_U01" SP_POP_WRK40_U01
(
    P_WERKS                 IN VARCHAR2             --플랜트 
    ,P_MACH_CD              IN VARCHAR2             --설비코드
    ,P_IOTYPE               IN VARCHAR2             --구분
    ,P_WRK_ORDR_NO          IN VARCHAR2             --신규 작업지시 번호
    ,P_WRK_ORDR_SEQNO       IN VARCHAR2             --신규 작업지시 순번    
    ,P_ORDER_NO             IN VARCHAR2             --신규 오더번호
--    ,P_PRD_STR_DATE         IN VARCHAR2             --이전 작업시작시간
    ,P_PRD_END_DATE         IN VARCHAR2             --이전 작업종료시간('yyyyMMddHH24miss')
--    ,P_NEW_ORDER_NO         IN VARCHAR2             --신규 오더번호
--    ,P_NEW_WRK_ORDR_NO      IN VARCHAR2             --신규 작업지시
--    ,P_NEW_WRK_ORDR_SEQNO   IN VARCHAR2             --신규 작업지시 순번
    ,P_MATNR                IN VARCHAR2             --신규 자재코드
    ,P_PROC_CD              IN VARCHAR2             --공정코드
    ,P_USERID               IN VARCHAR2 
    ,Lang                   IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE                OUT VARCHAR2 
    ,RS_MSG                 OUT VARCHAR2
)
/*==============================================================================
 * PROGRAM ID    : POP_WRK40
 * PROGRAM NAME  : PS 작업지시 변경
 * VERSION       : 1.0.0
 * DESCRIPTION   : 진행중인 작업지시를 변경한다.
 *                 
 * AUTHOR NAME   : 김병무
 * CREATE DATE   : 2022/05/10
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/04/28    1.0.0   김기연         Initial Version
 *==============================================================================
 *  관련 테이블
 * - [TB_SCH015] : (.R..) PS 점보롤 작업지시
 * - [TB_MAS001] : (.R..) 자재 기준 정보
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM        VARCHAR2(100)  := 'SP_POP_WRK40_U01';     -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := P_PROC_CD; --OPCODE
    V_SESS_USER_ID   varchar2(20) := P_USERID; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);
    --parameter변수 처리
    V_PRE_WRK_ORDR_NO           TB_SCH015.WRK_ORDR_NO%TYPE;     
    V_PRE_WRK_ORDR_SEQNO        TB_SCH015.WRK_ORDR_SEQNO%TYPE;  
    V_MACH_STA                  TB_WRK011.MACH_STA%TYPE;
    V_PRD_END_DATE              DATE;    
    V_DATE                      DATE := SYSDATE;    
BEGIN
    BEGIN
        SELECT CASE WHEN MACH_STA = 'N' THEN PRE_WRK_ORDR_NO ELSE WRK_ORDR_NO END,
               CASE WHEN MACH_STA = 'N' THEN PRE_WRK_ORDR_SEQNO ELSE WRK_ORDR_SEQNO END,
               MACH_STA
               INTO V_PRE_WRK_ORDR_NO, V_PRE_WRK_ORDR_SEQNO, V_MACH_STA
          FROM TB_WRK011
         WHERE MACH_CD = P_MACH_CD;
        --EXCEPTION 
        --    WHEN NO_DATA_FOUND THEN NULL;
    END;

    --dbms_output.put_line('V_PRE_WRK_ORDR_NO [' || V_PRE_WRK_ORDR_NO || ']');
    --dbms_output.put_line('V_PRE_WRK_ORDR_SEQNO [' || V_PRE_WRK_ORDR_SEQNO || ']');

    BEGIN

        UPDATE TB_WRK011
           SET PRE_WRK_ORDR_NO = V_PRE_WRK_ORDR_NO,
               PRE_WRK_ORDR_SEQNO = V_PRE_WRK_ORDR_SEQNO,
               MATNR = P_MATNR,
               WRK_ORDR_NO = P_WRK_ORDR_NO,
               WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO,
               ORDER_NO = P_ORDER_NO,
               PRD_STR_DTM = P_PRD_END_DATE,
               MACH_STA = 'N'
         WHERE WERKS = P_WERKS
           AND MACH_CD = P_MACH_CD;

        --가동현황
-- [2022-06-15:bmkim] 작업지시 시작(SP_POP_WRK24_I01)에서 가동현황 처리하여 작업지시 변경시는 주석처리함.
--        V_PRD_END_DATE := TO_DATE(P_PRD_END_DATE, 'yyyyMMddHH24miss');
--        UPDATE TB_WRK012
--           SET END_DATE = V_PRD_END_DATE
--         WHERE WERKS = P_WERKS
--           AND MACH_CD = P_MACH_CD
--           AND END_DATE IS NULL;
--            
--         INSERT INTO TB_WRK012( WERKS,
--                                MACH_CD,
--                                IN_OUT,
--                                STR_DATE,
--                                WRK_ORDR_NO,
--                                WRK_ORDR_SEQNO,
--                                ORDER_NO,
--                                MATNR,
--                                LINE_STA,
--                                REGDATE,
--                                REGID)
--                        VALUES( P_WERKS,
--                                P_MACH_CD,
--                                'N',
--                                V_PRD_END_DATE,
--                                P_WRK_ORDR_NO,
--                                P_WRK_ORDR_SEQNO,
--                                P_ORDER_NO,
--                                P_MATNR,
--                                V_MACH_STA,
--                                V_DATE,
--                                P_USERID);
        COMMIT;  
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

END ;
/
