
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK28_S02" 
(
     P_WERKS        IN VARCHAR2
    ,P_MACH_CD      IN VARCHAR2
    ,P_JIND_BCD     IN VARCHAR2
    ,Lang           IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE        OUT VARCHAR2 
    ,RS_MSG         OUT VARCHAR2
    ,CUR_1          OUT SYS_REFCURSOR
    ,CUR_2          OUT SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : POP_WRK25
 * PROGRAM NAME  : PS 슬리터 주 작업 화면
 * VERSION       : 1.0.1
 * DESCRIPTION   : 그리드 클릭했을 때 상세정보 조회
 *                 
 * AUTHOR NAME   : 유상호
 * CREATE DATE   : 2022/05/25
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/05/25    1.0.0   유상호         Initial Version
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM         VARCHAR2(100) := 'SP_POP_WRK08_S01';   -- PROCEDURE NAME
    V_PLT_CD         VARCHAR2(2)   := '99';         --PLANTCODE TEST
    V_SESS_USER_ID   VARCHAR2(20)  := 'TEST';       --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);
    
BEGIN
    BEGIN
        -- 투입자재에 투입량 , 실적량 정보
        OPEN CUR_1 FOR
         SELECT PRFM_QTY
               , USE_QTY
               , TUSE_QTY
               , DISPO_QTY
               , ABLE_QTY
               , RMK
          FROM
              (
                 SELECT NVL(I003.IN_QTY, 0)        PRFM_QTY
                        , NVL(I003.USE_QTY, 0) - NVL(I003.DISPO_QTY, 0) USE_QTY   --( 현재는 실적 + 폐품 모두 포함 된 값임 => USE_QTY - DISPO_QTY )
                        , NVL(I003.USE_QTY, 0)     TUSE_QTY
                        , NVL(I003.DISPO_QTY, 0)   DISPO_QTY
                        , NVL(I003.STCK_QTY, 0)    ABLE_QTY
                        , W002.RMK                 RMK  -- 밀롤 실적시 등록된 비고
                   FROM TB_INV003 I003,
                        TB_WRK002 W002
                  WHERE I003.WERKS   = W002.WERKS(+)
                    AND I003.MACH_CD = P_MACH_CD
                    AND I003.MATNR   = W002.MATNR(+)
                    AND I003.IND_BCD = W002.IND_BCD(+)
                    AND I003.WERKS   = P_WERKS
                    AND I003.IND_BCD = P_JIND_BCD
              );
              
        -- 실적 정보 ( 투입자재에 대한 사용권치수 구하기)
        -- 1개 바코드 투입하여 1개 또는 2개의 작지 실적 생성, 취소는 1개의 작지에 대하여 발생 할 수 있음
        -- 결론 : 작지별 SUM 한다. 2개의 작지 중 Max 권치수가 최종 사용 권치수 임
        OPEN CUR_2 FOR
         SELECT  MAX(ROLLCNT)       AS ROLLCNT
               , MAX(DISPO_ROLLCNT) AS DISPO_ROLLCNT
           FROM 
               (
                 SELECT  WRK_ORDR_NO
                       , WRK_ORDR_SEQNO
                       , SUM(ROLLCNT)       AS ROLLCNT
                       , SUM(DISPO_ROLLCNT) AS DISPO_ROLLCNT
                   FROM 
                       (
                          SELECT   I010.WRK_ORDR_NO
                                 , I010.WRK_ORDR_SEQNO
                                 , I010.ROLLCNT
                                 , 0   AS DISPO_ROLLCNT	
                            FROM TB_INV010 I010
                           WHERE I010.WERKS     = P_WERKS
                             AND I010.MACH_CD   = P_MACH_CD
                             AND I010.IND_BCD_M = P_JIND_BCD
                             AND NVL(I010.CNL_YN,'N') = 'N'
                        UNION ALL
                          SELECT  W004.WRK_ORDR_NO
                                , W004.WRK_ORDR_SEQNO
                                , 0             AS ROLLCNT
                                , W004.ROLLCNT  AS DISPO_ROLLCNT
                           FROM TB_WRK004 W004
                          WHERE W004.WERKS     = P_WERKS
                            AND W004.MACH_CD   = P_MACH_CD
                            AND W004.IND_BCD_M = P_JIND_BCD
                            AND NVL(W004.CNL_YN,'N') = 'N' 
                       )
                  GROUP BY WRK_ORDR_NO, WRK_ORDR_SEQNO
              );

        RS_CODE := 'S';
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
END SP_POP_WRK28_S02;
/
