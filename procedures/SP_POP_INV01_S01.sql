
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_INV01_S01" 
(
    P_WERKS         IN VARCHAR2 
    ,P_PROC_CD      IN VARCHAR2 
    ,P_WRK_LIST     IN VARCHAR2
    ,P_USERID       IN VARCHAR2
    ,Lang           IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE     OUT VARCHAR2 
    ,RS_MSG      OUT VARCHAR2
    ,CUR_1       OUT SYS_REFCURSOR
    ,CUR_2       OUT SYS_REFCURSOR
    ,CUR_3       OUT SYS_REFCURSOR
    ,CUR_4       OUT SYS_REFCURSOR
    ,CUR_5       OUT SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : POP_INV01
 * PROGRAM NAME  : 자재불출요청
 * VERSION       : 1.0.1
 * DESCRIPTION   : 선택된 생산오더의 자재목록을 조회한다.
 *                 
 * AUTHOR NAME   : 김기연
 * CREATE DATE   : 2022/05/12
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/05/12    1.0.0   김기연         Initial Version
 *==============================================================================
 *  관련 테이블
 * - [TB_SCH002] : (.R..) 화장지 합지기 생산오더
 * - [TB_SCH011] : (.R..) 화장지 합지기 작업지시
 * - [TB_MAS001] : (.R..) 자재 기준 정보
 * - [TB_WRK001] : (.R..) HL 생산실적 이력
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM        VARCHAR2(100)  := 'SP_POP_INV01_S01';     -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID   varchar2(20) := P_USERID; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);
    --내부변수 관리
    V_COLINFO VARCHAR2(1000);--컬럼설정1
    V_COLTYPE VARCHAR2(1000);--컬럼설정2
    V_SQL VARCHAR(4000);
    V_UNIT VARCHAR(3);

BEGIN
    --예외처리 시작(try)
    BEGIN
        --grid 컬럼 정보 설정
        V_COLINFO := '품목코드@H|품목명@L^280|계획량@R^80|단위@C^60';
        V_COLTYPE := 'MATNR@varchar|MATNR_NM@varchar|WRK_ORDR_QTY@varchar|UNIT@varchar';
        --컬럼설정 반환 테이블 작성
        OPEN CUR_1 FOR
        SELECT RTN_VALUES FROM FN_SPLIT(V_COLINFO||','||V_COLTYPE,',');
        --품목정보 목록 반환
        IF P_PROC_CD = 'AA' THEN 
        OPEN CUR_2 FOR
            SELECT M001.MATNR
                 , M001.MATNR_NM
                 , S011.WRK_ORDR_QTY
                 , M001.UNIT
              FROM TB_SCH011 S011
                 , TB_MAS001 M001
             WHERE 1=1
               AND S011.WERKS = M001.WERKS(+)
               AND S011.MATNR = M001.MATNR(+)
               AND WRK_ORDR_NO || LPAD(TO_CHAR(WRK_ORDR_SEQNO),5,'0') 
                    IN (SELECT RTN_VALUES FROM FN_SPLIT(P_WRK_LIST,','))
             ORDER BY MATNR;
         ELSIF P_PROC_CD = 'RA' THEN 
         OPEN CUR_2 FOR
            SELECT M001.MATNR
                 , M001.MATNR_NM
                 , S012.WRK_ORDR_QTY
                 , M001.UNIT
              FROM TB_SCH012 S012
                 , TB_MAS001 M001
             WHERE 1=1
               AND S012.WERKS = M001.WERKS(+)
               AND S012.MATNR = M001.MATNR(+)
               AND WRK_ORDR_NO || LPAD(TO_CHAR(WRK_ORDR_SEQNO),5,'0') 
                    IN (SELECT RTN_VALUES FROM FN_SPLIT(P_WRK_LIST,','))
             ORDER BY MATNR;
         ELSIF P_PROC_CD = 'RB' THEN 
         OPEN CUR_2 FOR
            SELECT M001.MATNR
                 , M001.MATNR_NM
                 , S013.WRK_ORDR_QTY
                 , M001.UNIT
              FROM TB_SCH013 S013
                 , TB_MAS001 M001
             WHERE 1=1
               AND S013.WERKS = M001.WERKS(+)
               AND S013.MATNR = M001.MATNR(+)
               AND WRK_ORDR_NO || LPAD(TO_CHAR(WRK_ORDR_SEQNO),5,'0') 
                    IN (SELECT RTN_VALUES FROM FN_SPLIT(P_WRK_LIST,','))
             ORDER BY MATNR;
         ELSE
         OPEN CUR_2 FOR
            SELECT M001.MATNR
                 , M001.MATNR_NM
                 , TO_CHAR(S014.WRK_ORDR_QTY, 'FM999,999,990') AS WRK_ORDR_QTY
                 , M001.UNIT
              FROM TB_SCH014 S014
                 , TB_MAS001 M001
             WHERE 1=1
               AND S014.WERKS = M001.WERKS(+)
               AND S014.MATNR = M001.MATNR(+)
               AND WRK_ORDR_NO || LPAD(TO_CHAR(WRK_ORDR_SEQNO),5,'0') 
                    IN (SELECT RTN_VALUES FROM FN_SPLIT(P_WRK_LIST,','))
             ORDER BY MATNR;

         END IF;

        --합지기 지시목록 조회
        V_COLINFO := '선택@C^50|순번@H|플랜트@H|자재명@L^310|WMS재고량@R^110|현재고량@R^110|소요량@R^100|요청수량@R^100|단위@H|자재코드@C^200';
        V_COLTYPE := 'CHK@Button|SEQ@varchar|WERKS@varchar|MATNR_NM@varchar|WMS_QTY@varchar|STCK_QTY@varchar|WRK_ORDR_QTY@varchar|REQ_QTY@varchar|UNIT@varchar|MATNR@varchar';
        --컬럼설정 반환 테이블 작성
        OPEN CUR_3 FOR
        SELECT RTN_VALUES FROM FN_SPLIT(V_COLINFO||','||V_COLTYPE,',');

        OPEN CUR_4 FOR
        SELECT '-' AS CHK
             , ROW_NUMBER() OVER(ORDER BY M001.MATNR) AS Seq
             , M001.WERKS
             --, M001.MATNR
             , M001.MATNR_NM 
             , RTRIM(TO_CHAR(NVL(WMS.WMS_QTY,0), 'FM999,999,990.999'),'.') AS WMS_QTY
             , RTRIM(TO_CHAR(NVL(I001.STCK_QTY,0), 'FM999,999,990.999'),'.') AS STCK_QTY
             , RTRIM(TO_CHAR(SUM(S020.ORDER_BOM_QTY), 'FM999,999,990.999'),'.') AS WRK_ORDR_QTY 
             , RTRIM(TO_CHAR(GREATEST(SUM(S020.ORDER_BOM_QTY)-NVL(I001.STCK_QTY,0),0), 'FM999,999,990.999'),'.') AS REQ_QTY 
             , M001.UNIT
             , M001.MATNR
          FROM (SELECT WERKS, MATNR , STOR_LOC_CD, ORDER_BOM_QTY
                     --, FN_CHG_UNIT(MATNR, WERKS, UNIT, 'PAL', ORDER_BOM_QTY) AS PLT_QTY
                  FROM TB_SCH020
                 WHERE 1=1
                   AND WRK_ORDR_NO || LPAD(TO_CHAR(WRK_ORDR_SEQNO),5,'0') 
                        IN (SELECT RTN_VALUES FROM FN_SPLIT(P_WRK_LIST,','))) S020
             , (SELECT WERKS, MATNR, STOR_LOC_CD, SUM(NVL(STCK_QTY,0)) AS STCK_QTY, UNIT
                  FROM TB_INV001
                 WHERE 1=1
                   AND WERKS = P_WERKS
                 GROUP BY WERKS, MATNR, STOR_LOC_CD, UNIT) I001
             , (SELECT SKUKEY AS MATNR
                     , SUM(USEQTY) AS WMS_QTY
                  FROM V_WMS_STKKY@KNRAWMSLINK
                 WHERE 1=1
                   AND LOTA02 = P_WERKS
                 GROUP BY SKUKEY) WMS
             , TB_MAS001 M001
         WHERE 1=1
           AND S020.WERKS = M001.WERKS(+)
           AND S020.MATNR = M001.MATNR(+)
           AND S020.WERKS = I001.WERKS(+)
           AND S020.MATNR = I001.MATNR(+)
           AND S020.STOR_LOC_CD = I001.STOR_LOC_CD(+)
           AND S020.MATNR = WMS.MATNR(+)
         GROUP BY '-', M001.WERKS, M001.MATNR, M001.MATNR_NM, WMS.WMS_QTY, I001.STCK_QTY, M001.UNIT
         ORDER BY M001.MATNR;

        --단위변환 정보
        OPEN CUR_5 FOR
        SELECT S020.MATNR
             , FN_UNIT_RATE(S020.MATNR, P_WERKS, M001.UNIT, 'PAL') AS PLT_RATE
             , FN_UNIT_RATE(S020.MATNR, P_WERKS, M001.UNIT, 'BOX') AS BOX_RATE
             , FN_UNIT_RATE(S020.MATNR, P_WERKS, M001.UNIT, 'BAG') AS BAG_RATE
             , FN_UNIT_RATE(S020.MATNR, P_WERKS, M001.UNIT, 'EA') AS EA_RATE
             , FN_UNIT_RATE(S020.MATNR, P_WERKS, M001.UNIT, 'RL') AS RL_RATE
             , FN_UNIT_RATE(S020.MATNR, P_WERKS, M001.UNIT, 'M') AS M_RATE
             , FN_UNIT_RATE(S020.MATNR, P_WERKS, M001.UNIT, 'KG') AS KG_RATE
          FROM TB_SCH020 S020, TB_MAS001 M001
         WHERE 1=1
           AND S020.WERKS = M001.WERKS
           AND S020.MATNR = M001.MATNR
           AND S020.WRK_ORDR_NO || LPAD(TO_CHAR(S020.WRK_ORDR_SEQNO),5,'0') 
                IN (SELECT RTN_VALUES FROM FN_SPLIT(P_WRK_LIST,','));

        --작업 정상 종료 코드 등록
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
        E_SQL_ERR_CD        := -20001;
        E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

        ROLLBACK;
        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);

        RS_CODE := 'E';
        RS_MSG  := SQLERRM;
        RETURN;
    --예외처리 종료
    END;
END SP_POP_INV01_S01;
/
