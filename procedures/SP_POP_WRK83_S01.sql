
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK83_S01" 
(
    P_WERKS         IN VARCHAR2         --플래트코드
    ,P_MACH_CD       IN VARCHAR2         --작업장코드
    ,P_CA_IND_BCD   IN VARCHAR2         --재단 개별바코드
    ,Lang        IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE     OUT VARCHAR2 
    ,RS_MSG      OUT VARCHAR2
    ,CUR_1       OUT SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : SP_POP83_S01
 * PROGRAM NAME  : 여유생산용 밀롤 정보 조회
 * VERSION       : 1.0.0
 * DESCRIPTION   : 여유생산용 밀롤 정보 조회
 *                 
 * AUTHOR NAME   : 김병무
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
 * 2022/07/26    1.0.0   김병무         Initial Version
 *==============================================================================
 *  관련 테이블
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM        VARCHAR2(100)  := 'SP_POP_WRK83_S01';     -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID   varchar2(20) := 'TEST'; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);
    --parameter변수 처리
    V_PRD_STR_DTM           VARCHAR2(30);
    V_WRK_ORDR_NO           TB_WRK002.WRK_ORDR_NO%TYPE;
    V_WRK_ORDR_SEQNO        TB_WRK002.WRK_ORDR_SEQNO%TYPE;
    
    --내부 변수 처리
BEGIN
    --예외처리 시작(try)
    BEGIN
        BEGIN
            BEGIN
                SELECT  WRK_ORDR_NO, WRK_ORDR_SEQNO
                  INTO  V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO
                  FROM  TB_WRK002  
                 WHERE  WERKS =  P_WERKS
                   AND  IND_BCD = P_CA_IND_BCD;
                 
                SELECT  MAX(TO_CHAR(PRD_END_DATE,'YYYY-MM-DD HH24:MI:SS'))
                  INTO  V_PRD_STR_DTM
                  FROM  TB_WRK002  W002
                 WHERE  W002.WERKS = P_WERKS
                   AND  W002.WRK_ORDR_NO = V_WRK_ORDR_NO
                   AND  W002.WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO;
            EXCEPTION 
                WHEN NO_DATA_FOUND THEN
                    V_PRD_STR_DTM := TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS');
            END;

            --결과 테이블 반환용 변수
            OPEN CUR_1 FOR
            SELECT W008.IND_BCD_M           IND_BCD_M           --밀롤 개별바코드
                , W008.LOT_NO_M             LOT_NO_M            --밀롤 LOT NO
                , W008.MATNR_M              MATNR_M             --밀롤 자재번호
                , W008.SUB_WRK_ORDR_NO      WRK_ORDR_NO_M       --밀롤 작업지시 번호
                , W008.SUB_WRK_ORDR_SEQNO   WRK_ORDR_SEQNO_M    --밀롤 작업지시 순번
                , W008.WRK_ORDR_NO          WRK_ORDR_NO         --재단 작업지시 번호
                , W008.WRK_ORDR_SEQNO       WRK_ORDR_SEQNO      --재단 작업지시 순번
                , W008.MATNR                MATNR               --재단 자재번호
                , M001.PCODE_NM             PCODE_NM            --지종명
                , M001.PCODE                PCODE               --지종코드
                , M001.BS_WGT               BS_WGT              --평량
                , S017.WLEN                 WLEN                --가로
                , S017.VLEN                 VLEN                --세로
                , V_PRD_STR_DTM             PRD_STR_DTM         --마지막 작업종료시간을 시작시간으로 사용
                FROM TB_WRK008 W008
                    , TB_MAS001 M001
                    , TB_SCH017 S017
                WHERE 1=1 
                AND W008.MATNR_M = M001.MATNR(+)
                AND W008.WRK_ORDR_NO = S017.WRK_ORDR_NO(+)
                AND W008.WRK_ORDR_SEQNO = S017.WRK_ORDR_SEQNO(+)
                AND W008.WERKS = P_WERKS
                AND W008.MACH_CD = P_MACH_CD
                AND W008.IND_BCD = P_CA_IND_BCD;
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
END;
/
