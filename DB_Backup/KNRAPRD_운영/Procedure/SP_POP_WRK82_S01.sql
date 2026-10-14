--------------------------------------------------------
--  DDL for Procedure SP_POP_WRK82_S01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK82_S01" 
(
    P_WERKS    			IN VARCHAR2 	--플랜트코드
    ,P_WRK_ORDR_NO      IN VARCHAR2 	--작업지시번호
    ,P_WRK_ORDR_SEQNO   IN VARCHAR2 	--작업지시순번
    ,P_IND_BCD          IN VARCHAR2     --업체/개별바코드
    ,P_INP_DT           IN VARCHAR2     --투입일자
    ,Lang       		IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE     		OUT VARCHAR2 
    ,RS_MSG      		OUT VARCHAR2
    ,CUR_1       		OUT SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : SP_POP_WRK82_S01
 * PROGRAM NAME  : 잔량 처리할 정보
 * VERSION       : 1.0.0
 * DESCRIPTION   : 잔량 처리할 정보 조회
 *                 
 * AUTHOR NAME   : 김기연
 * CREATE DATE   : 2022/07/26
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/08/26    1.0.0   김기연         Initial Version
 *==============================================================================
 *  관련 테이블
 * - [TB_INV003] : (.R..) 자재투입
 * - [TB_MAS001] : (.R..) 자재 마스터
 * - [TB_MAS012] : (.R..) 설비 마스터
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM        VARCHAR2(100)  := 'SP_POP_WRK82_S01';     -- PROCEDURE NAME
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
            IF P_WERKS = 'P100' THEN    --YSH 2022.09.14
                OPEN CUR_1 FOR
                SELECT I003.WRK_ORDR_NO    --지시번호
                     , I003.WRK_ORDR_SEQNO --지시순번
                     , I003.MATNR      --자재코드
                     , M001.MATNR_NM	--자재명
                     , I003.IND_BCD     --개별 바코드
                     , I003.MACH_CD     --설비코드
                     , M012.MACH_NM     --설비명
                     , I003.STCK_QTY	--재고량
                     --, NVL(RTRIM(TO_CHAR(I003.STCK_QTY, 'fm999,999,999,999,990.999'), '.'), '0') AS STCK_QTY	--재고량
                     , I003.UNIT	    --단위
                FROM TB_INV003 I003 	--자재투입
                   , TB_MAS001 M001		--자재 마스터
                   , TB_MAS012 M012		--설비 마스터
                WHERE 1=1
                AND I003.MACH_CD = M012.MACH_CD(+)
                AND I003.WERKS = M001.WERKS
                AND I003.MATNR = M001.MATNR
                AND I003.WERKS = P_WERKS                        -- 플랜트
                --AND I003.INP_DT = P_INP_DT                      --투입일자
                --AND I003.WRK_ORDR_NO = P_WRK_ORDR_NO            -- 작업지시번호
                --AND I003.WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO      -- 작업지시순번
                AND I003.IND_BCD = P_IND_BCD;                   -- 업체/개별바코드
            ELSE
                OPEN CUR_1 FOR
                --합지기 지시목록 조회
                SELECT I003.WRK_ORDR_NO    --지시번호
                     , I003.WRK_ORDR_SEQNO --지시순번
                     , I003.MATNR      --자재코드
                     , M001.MATNR_NM	--자재명
                     , I003.IND_BCD     --개별 바코드
                     , I003.MACH_CD     --설비코드
                     , M012.MACH_NM     --설비명
                     , I003.STCK_QTY	--재고량
                     --, NVL(RTRIM(TO_CHAR(I003.STCK_QTY, 'fm999,999,999,999,990.999'), '.'), '0') AS STCK_QTY	--재고량
                     , I003.UNIT	    --단위
                FROM TB_INV003 I003 	--자재투입
                   , TB_MAS001 M001		--자재 마스터
                   , TB_MAS012 M012		--설비 마스터
                WHERE 1=1
                AND I003.MACH_CD = M012.MACH_CD(+)
                AND I003.WERKS = M001.WERKS
                AND I003.MATNR = M001.MATNR
                AND I003.WERKS = P_WERKS                        -- 플랜트
                --AND I003.INP_DT = P_INP_DT                      --투입일자
                AND I003.WRK_ORDR_NO = P_WRK_ORDR_NO            -- 작업지시번호
                AND I003.WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO      -- 작업지시순번
                AND I003.IND_BCD = P_IND_BCD;                   -- 업체/개별바코드
            END IF;
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
END SP_POP_WRK82_S01;

/
