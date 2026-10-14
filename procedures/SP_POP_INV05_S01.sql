
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_INV05_S01" 
(
    P_WERKS         IN VARCHAR2 
    ,P_STOR_LOC     IN VARCHAR2
    ,P_MATNR		IN VARCHAR2 DEFAULT ''
    ,P_USERID       IN VARCHAR2
    ,P_WRK_ORDR_NO  IN VARCHAR2
    ,P_IND_BCD      IN VARCHAR2
    ,Lang           IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE        OUT VARCHAR2 
    ,RS_MSG         OUT VARCHAR2
    ,CUR_1          OUT SYS_REFCURSOR
    ,CUR_2          OUT SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : POP_INV05
 * PROGRAM NAME  : 공정재고 목록 조회
 * VERSION       : 1.0.0
 * DESCRIPTION   : 현재설비의 공정재고 목록을 조회한다.
 *                 
 * AUTHOR NAME   : 김기연
 * CREATE DATE   : 2022/05/14
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/05/14    1.0.0   김기연         Initial Version
 *==============================================================================
 *  관련 테이블
 * - [TB_WRK003] : (.R..) 비가동 실적
 * - [TB_MAS020] : (.R..) 비가동 항목정보
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM        VARCHAR2(100)  := 'SP_POP_INV05_S01';     -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID   varchar2(20) := P_USERID; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);
    --파라미터 처리
    --내부변수 관리
    V_COLINFO VARCHAR2(1000);
    V_COLTYPE VARCHAR2(1000);
    V_SQL            CLOB;
    V_DEBUG          varchar2(1);

BEGIN
    --예외처리 시작(try)
    BEGIN
        --컬럼설정
        V_COLINFO := '순번@H^60|선택@C^60|저장위치@H^80|저장위치명@H^100|자재그룹@L^150|자재코드@C^200|자재명@L^340|공급/개별바코드@C^180|LOT_NO@H|재고량@R^120|반납요청량@R^120|단위@C^70|품목구분@H|평량@H|호기@H|색상@H|작업자@H|판정@H';
        V_COLTYPE := 'SEQ@varchar|CHK@Button|STOR_LOC_CD@varchar|STOR_LOC_NM@varchar|MATNR_DIV_NM@varchar|MATNR@varchar|MATNR_NM@varchar|IND_BCD@varchar|LOT_NO@varchar|STCK_QTY@varchar|RTN_QTY@Button|UNIT@varchar|MATNR_DIV@varchar|BS_WGT@varchar|MACH_NM@varchar|COLOR@varchar|QCJUD@varchar';
        --컬럼설정 반환 테이블 작성
        OPEN CUR_1 FOR
        SELECT RTN_VALUES FROM FN_SPLIT(V_COLINFO||','||V_COLTYPE,',');

        INSERT INTO PROC_LOG (SQL_STR,SQL_PARAM1, SQL_PARAM2) VALUES (P_WRK_ORDR_NO, '반납요청조회쿼리', 'SP_POP_INV05_S01');
        
        --재고목록 조회
        OPEN CUR_2 FOR
        SELECT ROW_NUMBER() OVER (ORDER BY I001.MATNR)                                           AS SEQ
             , '-'                                                                               AS CHK     --선택여부
             , I001.STOR_LOC_CD
             , M003.STOR_LOC_NM
             , M001.MATNR_DIV_NM
             , I001.MATNR
             , M001.MATNR_NM
             , I001.IND_BCD
             , I001.LOT_NO
             , RTRIM(TO_CHAR(NVL(I001.STCK_QTY, 0) + NVL(CASE
                                                             WHEN I001.UNIT = I003.UNIT THEN NVL(I003.STCK_QTY, 0)
                                                             ELSE CASE
                                                                      WHEN I003.UNIT = 'EA' THEN I003.STCK_QTY /
                                                                                                 ((SUBSTR(I001.MATNR, 10, 4) / 1000) *
                                                                                                  (SUBSTR(I001.MATNR, 14, 4) / 1000) *
                                                                                                  (SUBSTR(I001.MATNR, 6, 3) / 1000))
                                                                      WHEN I003.UNIT = 'R'
                                                                          THEN NVL(I003.STCK_QTY, 0) * 500
                                                                      WHEN I003.UNIT = 'KG' AND SUBSTR(I003.LOT_NO, 5, 1) = 'P'
                                                                          THEN ROUND(I003.STCK_QTY / (I003.WGT / I003.PRE_IN_QTY), 3)
                                                                      ELSE 0 END
                                                             END, 0), 'FM999,999,990.999'), '.') AS STCK_QTY
             , RTRIM(TO_CHAR(NVL(I001.STCK_QTY, 0) + NVL(CASE
                                                             WHEN I001.UNIT = I003.UNIT THEN NVL(I003.STCK_QTY, 0)
                                                             ELSE CASE
                                                                      WHEN I003.UNIT = 'EA' THEN I003.STCK_QTY /
                                                                                                 ((SUBSTR(I001.MATNR, 10, 4) / 1000) *
                                                                                                  (SUBSTR(I001.MATNR, 14, 4) / 1000) *
                                                                                                  (SUBSTR(I001.MATNR, 6, 3) / 1000))
                                                                      WHEN I003.UNIT = 'R'
                                                                          THEN NVL(I003.STCK_QTY, 0) * 500
                                                                      WHEN I003.UNIT = 'KG' AND SUBSTR(I003.LOT_NO, 5, 1) = 'P'
                                                                          THEN ROUND(I003.STCK_QTY / (I003.WGT / I003.PRE_IN_QTY), 3)
                                                                      ELSE 0 END
                                                             END, 0), 'FM999,999,990.999'), '.') AS RTN_QTY
             , M001.UNIT
             , M001.MATNR_DIV
             , I001.BS_WGT                                                                                  --평량
             , (SELECT MACH_NM FROM TB_MAS012 WHERE MACH_CD = I001.MACH_CD)                      AS MACH_NM --설비명
             , 'W'                                                                               AS COLOR   --색상(W 흰색으로 고정)
             , (SELECT NMLAST FROM USRMA WHERE USERID = I001.REGID)                              AS WRK_NAME
             , '합격'                                                                              AS QCJUD   --판정확인
        FROM TB_INV001 I001
                 LEFT OUTER JOIN TB_MAS001 M001 ON I001.WERKS = M001.WERKS AND I001.MATNR = M001.MATNR
                 LEFT OUTER JOIN TB_MAS003 M003 ON I001.WERKS = M003.WERKS AND I001.STOR_LOC_CD = M003.STOR_LOC_CD
                 LEFT OUTER JOIN TB_INV003 I003 ON I001.WERKS = I003.WERKS AND I001.IND_BCD = I003.IND_BCD AND NVL(I003.STCK_QTY, 0) > 0.002
        WHERE 1 = 1
          AND I001.WERKS = P_WERKS
          AND I001.STOR_LOC_CD = P_STOR_LOC
          AND I001.MATNR LIKE P_MATNR || '%'
          AND I001.IND_BCD LIKE P_IND_BCD || '%'
          AND (NVL(I001.STCK_QTY, 0) + NVL(I003.STCK_QTY, 0)) > 0
        ORDER BY I001.IND_BCD DESC, M001.MATNR DESC;

--         V_DEBUG := 'Y';
--         IF (V_DEBUG = 'Y') THEN
--         	INSERT INTO PROC_LOG (SQL_STR,SQL_PARAM1, SQL_PARAM2) VALUES (V_SQL, '반납요청조회쿼리', 'SP_POP_INV05_S01');
--         END IF;

        --작업 정상 종료 코드 등록
        RS_CODE := 'S';
    --예외처리(catch)
    EXCEPTION
    WHEN E_EXCEPTION_USER THEN
        -- 에러 내역 SET
        E_SQL_ERR_CD        := -20000;
        E_SQL_ERR_MSG       := SQLCODE || ': EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

        ROLLBACK;
        SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);

        RS_CODE := 'E';
        RS_MSG  := SQLERRM;
        RETURN;
    WHEN OTHERS THEN
        E_SQL_ERR_CD        := -20000;
        E_SQL_ERR_MSG       := SQLCODE || ': EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

        ROLLBACK;
        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);

        RS_CODE := 'E';
        RS_MSG  := SQLERRM;
        RETURN;
    --예외처리 종료
    END;
END SP_POP_INV05_S01;
/
