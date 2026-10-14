--------------------------------------------------------
--  DDL for Procedure SP_POP_WRK37_S01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK37_S01" 
(
     P_WERKS    IN VARCHAR2             -- 플랜트 코드
    ,P_MACH_CD  IN VARCHAR2             -- 작업장코드(설비코드)
    ,P_IND_BCD  IN VARCHAR2             -- 개별바코드
    ,Lang       IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE    OUT VARCHAR2 
    ,RS_MSG     OUT VARCHAR2 
    ,CUR_1      OUT SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : SP_POP_WRK37_S01
 * PROGRAM NAME  : 등급변경용 이력 조회
 * VERSION       : 1.0.0
 * DESCRIPTION   : 등급변경용 이력 조회
 *                 
 * AUTHOR NAME   : 김병무
 * CREATE DATE   : 2022/08/09
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/08/09    1.0.0   김병무         Initial Version
 *==============================================================================
 *  관련 테이블
 * - [TB_WRK002] : (.R..) 등급변경용 이력 조회
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM        VARCHAR2(100)  := 'SP_POP_WRK37_S01';     -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID   varchar2(20) := 'TEST'; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);
    --내부변수 관리
BEGIN
    --예외처리 시작(try)
    BEGIN
        BEGIN
            --개별바코드로 조회
            OPEN CUR_1 FOR
            SELECT 
                  W002.LOT_NO          LOT_NO   --LOT_NO
                , W002.IND_BCD         IND_BCD   --개별바코드
                , TO_CHAR(TO_DATE(W002.PRFM_DT,'YYYYMMDD'),'YYYY-MM-DD') PRFM_DT  --실적일자
                , W002.MATNR           MATNR     --자재코드
                , M001.PCODE           PCODE     --지종
                , M001.PCODE_NM        PCODE_NM --지종명
                , TO_CHAR(M001.BS_WGT, 'fm999,999,999,990')     BS_WGT      --평량
                , TO_CHAR(S018.WLEN, 'fm999,999,999,990')       WLEN        --가로
                , TO_CHAR(S018.VLEN, 'fm999,999,999,990')       VLEN        --세로
                , FN_CD_VAL('PACK_TYPE', W002.PACKTYPE)         PACKTYPE_NM --포장타입
                , W002.IN_PER_CNT                               IN_PER_CNT  --속당매수
                --, S018.IN_PER_CNT                               IN_PER_CNT  --속당매수
                , W002.PCNT                                     PCNT          --실적연수
                , S018.KUNNRT                                   KUNNRT        --거래처명
            FROM  TB_WRK002 W002    --PS실적
                , TB_MAS001 M001    --자재마스터
                , TB_SCH018 S018
            WHERE 1=1
            AND W002.WERKS = M001.WERKS(+)         
            AND W002.MATNR = M001.MATNR(+)         
            AND W002.WERKS = S018.WERKS(+)         
            AND W002.WRK_ORDR_NO = S018.WRK_ORDR_NO(+)         
            AND W002.WRK_ORDR_SEQNO = S018.WRK_ORDR_SEQNO(+)         
            AND W002.WERKS = P_WERKS            --플랜트코드
            AND W002.MACH_CD = P_MACH_CD        --작업장코드(설비코드)
            AND W002.IND_BCD = P_IND_BCD        --개별바코드
            ;

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
        --RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
        RAISE;

        RS_CODE := 'E';
        RS_MSG  := SQLERRM;
        RETURN;
    --예외처리 종료
    END;
END;

/
