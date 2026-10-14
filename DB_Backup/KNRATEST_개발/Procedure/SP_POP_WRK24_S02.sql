--------------------------------------------------------
--  DDL for Procedure SP_POP_WRK24_S02
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK24_S02" 
(
    P_WERKS     		IN VARCHAR2 	    --플랜트
    ,P_MACH_CD   		IN VARCHAR2 	    --설비코드
    ,P_IND_BCD           IN VARCHAR2 	    --개별바코드
--    ,P_WRK_ORDR_NO       IN VARCHAR2 	    --작업지시번호
--    ,P_WRK_ORDR_SEQNO    IN VARCHAR2 	    --작업지시순번
    ,Lang       		IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE     		OUT VARCHAR2 
    ,RS_MSG      		OUT VARCHAR2
    ,CUR_1       		OUT SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : WRK24{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 점보롤 인쇄용 조회
 * VERSION       : 1.0.1{최종 버전 기술}
 * DESCRIPTION   : 점보롤 인쇄용 조회
 *                 
 * AUTHOR NAME   : 유상호{최초 작성자 명 기술}
 * CREATE DATE   : 2022/05/12 {최초 작성일자 기술}
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * yyyy/mm/dd    1.0.0   유상호         Initial Version 
 *==============================================================================
 *  관련 테이블
 * - [TB_SCH015] : (.R..) PS 점보롤 작업지시
 * - [TB_WRK002] : (.R..) PS 생산실적 이력
 * - [TB_MAS001] : (.R..) 자재 기준 정보
 * - [USRMA]     : (.R..) 사용자 정보
 *=============================================================================*/
AS 
    --프로그램 ID - 점보롤 인쇄용 조회
    V_PRG_NM        VARCHAR2(100)  := 'SP_POP_WRK24_S02';     -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID   varchar2(20) := 'TEST'; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);
    --parameter변수 처리

BEGIN
    BEGIN
        BEGIN    
            OPEN CUR_1 FOR
            SELECT M001.PCODE_NM,
                NVL(M001.BS_WGT, '0') AS BS_WGT,                                    --평량
                NVL(S015.JROLLCNT, '0') AS JROLLCNT,                                --계획 권치수
                NVL(W002.ROLLCNT, '0') AS ROLLCNT,                                 --실적권치수
                NVL(W002.WGT, '0') AS WGT,                                          --중량
                NVL(W002.RSPEED, '0') AS RSPEED,                                    --선속
                S015.MACHINE AS MACHINE_NM,                            -- J/R 호기
                S015.TO_MACHINE  AS TO_MACHINE_NM,                         -- M/R 호기
                TO_CHAR(W002.PRD_STR_DATE, 'HH24:MI') AS PRD_STR_DATE, -- 생산시작일시 DATE
                TO_CHAR(W002.PRD_END_DATE, 'HH24:MI') AS PRD_END_DATE, -- 생산종료일시 DATE
                W002.TM,                                    -- 생산시간    NUMBER
               -- '자체생산' AS WRK_TYPE,                                    -- 생산유형
                S015.PRDTYPETXT AS WRK_TYPE,                                -- 생산유형
                TO_CHAR(W002.REGDATE, 'YYYY-MM-DD HH24:MI') AS WRK_DATE,    -- 생산일시
                USRMA.NMLAST AS WRK_NAME,    -- 작업자
                W002.WRK_CLASS,             -- 반
                W002.LOT_NO,                -- LOT NO
                W002.ORDER_NO,              -- ORDER NO
                W002.PRD_NO,                -- 생산번호
                S015.ORDER_RMK,          -- 생산오더 비고사항
                W002.RUN_STA,               --운전상태 01 : 정상, 09 : 비계획생산
                W002.RMK                   -- 비고사항
              FROM TB_WRK002 W002,
                   TB_MAS001 M001,
                   USRMA USRMA,
                   TB_SCH015 S015
             WHERE W002.WERKS = S015.WERKS(+)
               AND W002.WRK_ORDR_NO = S015.WRK_ORDR_NO(+)
               AND W002.WRK_ORDR_SEQNO = S015.WRK_ORDR_SEQNO(+)
               AND W002.WERKS = M001.WERKS(+)
               AND W002.MATNR = M001.MATNR(+)
               AND W002.REGID = USRMA.USERID(+)
               AND W002.WERKS = P_WERKS
               AND W002.MACH_CD = P_MACH_CD
               AND W002.IND_BCD = P_IND_BCD
               --AND W002.WRK_ORDR_NO = P_WRK_ORDR_NO
               --AND W002.WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
               AND NVL(W002.CNL_YN,'N') = 'N'
               ;

            RS_CODE := 'S';
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
            RS_CODE := 'E';
            RS_MSG := 'NO_DATA_FOUND';
            RETURN;            
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
