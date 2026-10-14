
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK_MONITOR_SELECT" (
    P_WERKS         IN VARCHAR2
, P_WRK_DT      IN VARCHAR2
, Lang          IN VARCHAR2 DEFAULT 'KO'
, RS_CODE       OUT VARCHAR2
, RS_MSG        OUT VARCHAR2
, CUR_1         OUT SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : POP_WRK_MONITOR
 * PROGRAM NAME  : 원지포장실적조회
 * VERSION       : 1.0.0
 * DESCRIPTION   : 원지포장되어 나올 실적 조회...함
 *                 
 * AUTHOR NAME   : 김지언
 * CREATE DATE   : 2026/08/04
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2026/08/04    1.0.0   김지언         Initial Version
 *==============================================================================
 *  관련 테이블
 *=============================================================================*/
AS
    --프로그램 ID
    V_PRG_NM       VARCHAR2(100) := 'SP_POP_WRK_MONITOR_SELECT'; -- PROCEDURE NAME
-- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER EXCEPTION;
    E_SQL_ERR_CD  NUMBER(5) := 0;
    E_SQL_ERR_MSG VARCHAR2(4000);
    --파라미터 처리
    --내부변수 관리
    V_COLINFO     VARCHAR2(1000);
    V_COLTYPE     VARCHAR2(1000);
    V_MACHINE     VARCHAR2(10);

BEGIN
    RS_CODE := 'S';
    RS_MSG  := 'SUCCESS';
    --예외처리 시작(try)
--         --컬럼설정
--         V_COLINFO := '자재코드@C^150|자재명@L^300|LOTNO@C^120|개별바코드@C^180|작업지시번호@H|지시순번@H|작업지시번호@C^160|요청번호@C^220';
--         V_COLTYPE := 'MATNR@varchar|MATNR_NM@varchar|LOT_NO@varchar|IND_BCD@varchar|ORDER_NO@varchar|ORDER_SEQNO@varchar|WRK_ORDR@varchar|DOC_NO@varchar';
--         --컬럼설정 반환 테이블 작성
--         OPEN CUR_1 FOR
--             SELECT RTN_VALUES FROM FN_SPLIT(V_COLINFO||','||V_COLTYPE,',');

    OPEN CUR_1 FOR
        SELECT /*+ LEADING(I001) USE_HASH(MAS001) */
            I001.MATNR
             , MAS001.MATNR_NM
             , SUM(CASE
                       WHEN (MAS001.MATNR_DIV = 'FERT' AND I001.STOR_LOC_CD = '2600' AND I001.STCK_STA = '00')
                           OR (MAS001.MATNR_DIV = 'HALB' AND I001.STOR_LOC_CD = '2000' AND I001.STCK_STA = '00')
                           THEN 1
                       ELSE 0 END) AS PRFM_CNT
             , SUM(CASE
                       WHEN (MAS001.MATNR_DIV = 'FERT' AND I001.STOR_LOC_CD = '3100' AND I001.STCK_STA = '80')
                           OR (MAS001.MATNR_DIV = 'HALB' AND I001.STOR_LOC_CD = '2000' AND I001.STCK_STA = '80')
                           THEN 1
                       ELSE 0 END) AS REQUEST_CNT
        FROM TB_INV001 I001
                 INNER JOIN TB_MAS001 MAS001 ON I001.WERKS = MAS001.WERKS AND I001.MATNR = MAS001.MATNR
        WHERE I001.WERKS = P_WERKS
          AND I001.STOR_LOC_CD IN ('2000', '2600', '3100')
          AND I001.STCK_STA IN ('00', '80')
          AND I001.PRD_DT = P_WRK_DT
          AND (I001.DLFL = 'N' OR I001.DLFL IS NULL)
          AND MAS001.MATNR_DIV IN ('HALB', 'FERT')
        GROUP BY I001.MATNR, MAS001.MATNR_NM
        ORDER BY I001.MATNR;
    --예외처리(catch)
EXCEPTION
    WHEN E_EXCEPTION_USER THEN
        -- 에러 내역 SET
        E_SQL_ERR_CD := SQLCODE;
        E_SQL_ERR_MSG := SUBSTRB(SQLERRM, 1, 300);

        ROLLBACK;
        SP_PROC_ERROR(P_WERKS, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, 'WRK_MONITOR');

        RS_CODE := 'E';
        RS_MSG := SQLERRM;
        RETURN;
    WHEN OTHERS THEN
        E_SQL_ERR_CD := SQLCODE;
        E_SQL_ERR_MSG := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM, 1, 500) || ']';

        ROLLBACK;
        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);

        RS_CODE := 'E';
        RS_MSG := SQLERRM;
        RETURN;
    --예외처리 종료
END;
/
