
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK41_S01" 
(
    P_WERKS             IN VARCHAR2 
    ,P_PROC_CD          IN VARCHAR2 
    ,P_MACH_CD          IN VARCHAR2
    ,P_IOTYPE          IN VARCHAR2
    ,P_WRK_ORDR_NO      IN VARCHAR2
    ,P_WRK_ORDR_SEQ     IN VARCHAR2
    ,P_USERID           IN VARCHAR2
    ,Lang               IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE            OUT VARCHAR2 
    ,RS_MSG             OUT VARCHAR2
    ,CUR_1              OUT SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : POP_WRK41
 * PROGRAM NAME  : HL 작업지시 변경
 * VERSION       : 1.0.0
 * DESCRIPTION   : 진행중인 작업지시를 변경한다.
 *                 
 * AUTHOR NAME   : 김기연
 * CREATE DATE   : 2022/04/28
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
 * 2022/05/11    2.0.0   김기연         화장기 가공기, 생리대, 기저귀 추가
 *==============================================================================
 *  관련 테이블
 * - [TB_SCH011] : (.R..) 화장지 합지기 작업지시
 * - [TB_SCH012] : (.R..) 화장지 가공기 작업지시
 * - [TB_SCH013] : (.R..) 생리대 작업지시
 * - [TB_SCH014] : (.R..) 기저귀 작업지시
 * - [TB_MAS001] : (.R..) 자재 기준 정보
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM        VARCHAR2(100)  := 'SP_POP_WRK41_S01';     -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := P_PROC_CD; --OPCODE
    V_SESS_USER_ID   varchar2(20) := P_USERID; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);
    --parameter변수 처리
    V_WRK_ORDR_SEQ  NUMBER(5,0) := TO_NUMBER(P_WRK_ORDR_SEQ);
    V_IOTYPE        VARCHAR2(10) := CASE WHEN P_WERKS = 'P500' THEN 'N' ELSE P_IOTYPE END;
    --내부변수 처리
    V_DATE DATE := SYSDATE;
    V_STR_DTM VARCHAR2(14);
    V_PRFM_DT VARCHAR2(10);
    V_PRE_WRK_ORDR_NO VARCHAR2(20); 
    V_PRE_WRK_ORDR_SEQNO NUMBER;
    V_MACH_STA VARCHAR2(10); 

BEGIN
    --예외처리 시작(try)
    BEGIN  
        --초기 시작시간 조회(투입된 작업자의 근무방식 조회)
        BEGIN
        dbms_output.put_line('1');
        SELECT TO_CHAR(STR_DATE,'YYYYMMDDHH24MISS') INTO V_STR_DTM
          FROM TB_WRK013
         WHERE 1=1
           AND WERKS = P_WERKS
           AND MACH_CD = P_MACH_CD
           AND IN_OUT = V_IOTYPE
           AND END_DATE IS NULL;
        EXCEPTION WHEN NO_DATA_FOUND THEN
            --정보가 없는경우 07시를 기준으로 지정
            V_STR_DTM := TO_CHAR(V_DATE,'YYYYMMDD') || '070000';
        END;
        --상태에 따른 이전 문서 확인
        BEGIN
            SELECT CASE WHEN MACH_STA = 'N' THEN PRE_WRK_ORDR_NO ELSE WRK_ORDR_NO END,
                   CASE WHEN MACH_STA = 'N' THEN PRE_WRK_ORDR_SEQNO ELSE WRK_ORDR_SEQNO END,
                   MACH_STA
                   INTO V_PRE_WRK_ORDR_NO, V_PRE_WRK_ORDR_SEQNO, V_MACH_STA
              FROM TB_WRK011
             WHERE MACH_CD = P_MACH_CD
               AND IN_OUT = V_IOTYPE;
        EXCEPTION 
            WHEN NO_DATA_FOUND THEN NULL;
        END;

        --화장지 합지기
        IF P_PROC_CD = 'AA' THEN
            --결과 테이블 반환용 변수
            OPEN CUR_1 FOR
            --기존 작업 지시정보
            SELECT FN_DT_FORMAT(S011.PRD_REQ_DT,'YYYY-MM-DD') AS PRD_REQ_DT
                 , S011.ORDER_NO
                 , S011.WRK_ORDR_NO
                 , S011.WRK_ORDR_SEQNO
                 , M001.MATNR
                 , M001.MATNR_NM
                 , M001.MATNR_SPEC
                 , TO_CHAR(S011.SPEC,'FM999,999,990') AS SPEC
                 , S011.WRK_ORDR_RMK
                 , S011.ORDER_QTY
                 , TO_CHAR(TO_DATE(S011.PRD_STR_DTM,'YYYYMMDDHH24MISS'),'YYYY-MM-DD HH24:MI:SS') AS PRD_STR_DATE
                 --, TO_CHAR(TO_DATE(S011.PRD_END_DTM,'YYYYMMDDHH24MISS'),'YYYY-MM-DD HH24:MI:SS') AS PRD_END_DATE
                 --, TO_CHAR(S011.PRD_LAST_DATE,'YYYY-MM-DD HH24:MI:SS') AS PRD_END_DATE
                 , TO_CHAR(V_DATE,'YYYY-MM-DD HH24:MI:SS') AS PRD_END_DATE
                 , V_MACH_STA AS MACH_STA
                 , 'A' AS PRODTYPE -- A:합지기 / T:화장지 / P:생리대,기저귀 / E:예외생산
                 , '' AS TOTAL_QTY
				 , (SELECT TO_CHAR(SUM(W001.WGT))
					  FROM TB_WRK001 W001
					 WHERE 1=1
                       AND W001.WERKS = S011.WERKS
                       AND W001.MACH_CD = S011.MACH_CD
                       AND W001.WRK_ORDR_NO = S011.WRK_ORDR_NO
                       AND W001.WRK_ORDR_SEQNO = S011.WRK_ORDR_SEQNO
					   AND W001.PRFM_GTHR_YN = 'Y') AS PRD_QTY
                 --, TO_CHAR(S011.PRFM_QTY,'FM999,990') AS PRD_QTY
                 , '' AS DISPO_QTY
                 , (SELECT TO_CHAR(SUM(DISPO_QTY),'FM999,990') FROM TB_WRK004
                    WHERE 1=1
                      AND WERKS = S011.WERKS
                      AND MACH_CD = S011.MACH_CD
                      AND WRK_ORDR_NO = S011.WRK_ORDR_NO
                      AND WRK_ORDR_SEQNO = S011.WRK_ORDR_SEQNO) AS DISPO_LOG
            FROM TB_SCH011 S011, TB_MAS001 M001
            WHERE 1=1
            AND S011.WERKS = M001.WERKS(+)
            AND S011.MATNR = M001.MATNR(+)
            AND S011.WERKS = P_WERKS
            AND S011.MACH_CD = P_MACH_CD
            AND S011.WRK_ORDR_NO = V_PRE_WRK_ORDR_NO
            AND S011.WRK_ORDR_SEQNO = V_PRE_WRK_ORDR_SEQNO
            UNION ALL
            --신규 선택 지시정보
            SELECT FN_DT_FORMAT(S011.PRD_REQ_DT,'YYYY-MM-DD') AS PRD_REQ_DT
                 , S011.ORDER_NO
                 , S011.WRK_ORDR_NO
                 , S011.WRK_ORDR_SEQNO
                 , M001.MATNR
                 , M001.MATNR_NM
                 , M001.MATNR_SPEC
                 , TO_CHAR(S011.SPEC,'FM999,999,990') AS SPEC
                 , S011.WRK_ORDR_RMK
                 , S011.ORDER_QTY
                 --, TO_CHAR(TO_DATE(V_STR_DTM,'YYYYMMDDHH24MISS'),'YYYY-MM-DD HH24:MI:SS') AS PRD_STR_DATE
                 , TO_CHAR(V_DATE,'YYYY-MM-DD HH24:MI:SS') AS PRD_STR_DATE
                 , '' AS PRD_END_DATE
                 , '0' AS MACH_STA
                 , 'A' AS PRODTYPE -- A:합지기 / T:화장지 / P:생리대,기저귀 / E:예외생산
                 , '' AS TOTAL_QTY
                 , '' AS PRD_QTY
                 , '' AS DISPO_QTY
                 , '' AS DISPO_LOG
            FROM TB_SCH011 S011, TB_MAS001 M001
            WHERE 1=1
            AND S011.WERKS = M001.WERKS(+)
            AND S011.MATNR = M001.MATNR(+)
            AND S011.WERKS = P_WERKS
            AND S011.WRK_ORDR_NO = P_WRK_ORDR_NO
            AND S011.WRK_ORDR_SEQNO = V_WRK_ORDR_SEQ;
            --작업 정상 종료 코드 등록
            RS_CODE := 'S';
        --화장지 가공기
        ELSIF P_PROC_CD = 'RA' THEN
            --결과 테이블 반환용 변수
            OPEN CUR_1 FOR
            --기존 작업 지시정보
            SELECT FN_DT_FORMAT(S012.PRD_REQ_DT,'YYYY-MM-DD') AS PRD_REQ_DT
                 , S012.ORDER_NO
                 , S012.WRK_ORDR_NO
                 , S012.WRK_ORDR_SEQNO
                 , M001.MATNR
                 , M001.MATNR_NM
                 , M001.MATNR_SPEC
                 , S012.SPEC
                 , S012.WRK_ORDR_RMK
                 , S012.ORDER_QTY
                 , TO_CHAR(TO_DATE(S012.PRD_STR_DTM,'YYYYMMDDHH24MISS'),'YYYY-MM-DD HH24:MI:SS') AS PRD_STR_DATE
                 --, S012.PRD_END_DTM AS PRD_END_DATE
                 --, TO_CHAR(S012.PRD_LAST_DATE,'YYYY-MM-DD HH24:MI:SS') AS PRD_END_DATE
                 , TO_CHAR(V_DATE,'YYYY-MM-DD HH24:MI:SS') AS PRD_END_DATE
                 , V_MACH_STA AS MACH_STA
                 , 'T' AS PRODTYPE --T:화장지 / P:생리대,기저귀
                 , (SELECT TO_CHAR(SUM(FN_CHG_UNIT(I010.MATNR, I010.WERKS, I010.UNIT, 'KG', I010.USE_QTY)),'FM999,990') 
                      FROM TB_INV010 I010, TB_MAS001 M001
                     WHERE 1=1
                       AND I010.WERKS = M001.WERKS(+)
                       AND I010.MATNR_M = M001.MATNR(+)
                       AND I010.WERKS = W011.WERKS
                       AND I010.MACH_CD = W011.MACH_CD
                       AND I010.MATNR = W011.MATNR
                       AND I010.WRK_ORDR_NO = W011.WRK_ORDR_NO
                       AND I010.WRK_ORDR_SEQNO = W011.WRK_ORDR_SEQNO
                       AND M001.MATNR_DIV = 'HALB') AS TOTAL_QTY
                 --, TO_CHAR(S012.PRFM_QTY,'FM999,990') AS PRD_QTY
                 , (SELECT TO_CHAR(SUM(EA_QTY),'FM999,990') FROM TB_WRK001
                    WHERE 1=1
                      AND WERKS = W011.WERKS
                      AND MACH_CD = W011.MACH_CD
                      AND WRK_ORDR_NO = W011.WRK_ORDR_NO
                      AND WRK_ORDR_SEQNO = W011.WRK_ORDR_SEQNO
                      AND PRFM_GTHR_YN = 'Y') AS PRD_QTY
                 , '' AS DISPO_QTY
                 , (SELECT TO_CHAR(SUM(DISPO_QTY),'FM999,990') FROM TB_WRK016
                    WHERE 1=1
                      AND WERKS = W011.WERKS
                      AND MACH_CD = W011.MACH_CD
                      AND WRK_ORDR_NO = W011.WRK_ORDR_NO
                      AND WRK_ORDR_SEQNO = W011.WRK_ORDR_SEQNO) AS DISPO_LOG
            FROM TB_WRK011 W011, TB_SCH012 S012, TB_MAS001 M001
            WHERE 1=1
            AND W011.WERKS = S012.WERKS(+)
            AND W011.MACH_CD = S012.MACH_CD(+)
            AND S012.WERKS = M001.WERKS(+)
            AND S012.MATNR = M001.MATNR(+)
            AND S012.WERKS = P_WERKS
            AND S012.MACH_CD = P_MACH_CD
            AND S012.WRK_ORDR_NO = V_PRE_WRK_ORDR_NO
            AND S012.WRK_ORDR_SEQNO = V_PRE_WRK_ORDR_SEQNO
            AND W011.IN_OUT = V_IOTYPE
            UNION ALL
            --신규 선택 지시정보
            SELECT FN_DT_FORMAT(S012.PRD_REQ_DT,'YYYY-MM-DD') AS PRD_REQ_DT
                 , S012.ORDER_NO
                 , S012.WRK_ORDR_NO
                 , S012.WRK_ORDR_SEQNO
                 , M001.MATNR
                 , M001.MATNR_NM
                 , M001.MATNR_SPEC
                 , S012.SPEC
                 , S012.WRK_ORDR_RMK
                 , S012.ORDER_QTY
                 , TO_CHAR(V_DATE,'YYYY-MM-DD HH24:MI:SS') AS PRD_STR_DATE
                 , '' AS PRD_END_DATE
                 , '0' AS MACH_STA
                 , 'T' AS PRODTYPE -- A:합지기 / T:화장지 / P:생리대,기저귀 / E:예외생산
                 , '' AS TOTAL_QTY
                 , '' AS PRD_QTY
                 , '' AS DISPO_QTY
                 , '' AS DISPO_LOG
            FROM TB_SCH012 S012, TB_MAS001 M001
            WHERE 1=1
            AND S012.WERKS = M001.WERKS(+)
            AND S012.MATNR = M001.MATNR(+)
            AND S012.WERKS = P_WERKS
            AND S012.WRK_ORDR_NO = P_WRK_ORDR_NO
            AND S012.WRK_ORDR_SEQNO = V_WRK_ORDR_SEQ;
            --작업 정상 종료 코드 등록
            RS_CODE := 'S';
        --생리대
        ELSIF P_PROC_CD = 'RB' THEN
            --결과 테이블 반환용 변수
            OPEN CUR_1 FOR
            --기존 작업 지시정보
            SELECT FN_DT_FORMAT(S013.PRD_REQ_DT,'YYYY-MM-DD') AS PRD_REQ_DT
                 , S013.ORDER_NO
                 , S013.WRK_ORDR_NO
                 , S013.WRK_ORDR_SEQNO
                 , M001.MATNR
                 , M001.MATNR_NM
                 , M001.MATNR_SPEC
                 , S013.SPEC
                 , S013.WRK_ORDR_RMK
                 , S013.ORDER_QTY
                 , TO_CHAR(TO_DATE(S013.PRD_STR_DTM,'YYYYMMDDHH24MISS'),'YYYY-MM-DD HH24:MI:SS') AS PRD_STR_DATE
                 --, S013.PRD_END_DTM AS PRD_END_DATE
                 --, TO_CHAR(S013.PRD_LAST_DATE,'YYYY-MM-DD HH24:MI:SS') AS PRD_END_DATE
                 , TO_CHAR(V_DATE,'YYYY-MM-DD HH24:MI:SS') AS PRD_END_DATE
                 , V_MACH_STA AS MACH_STA
                 , 'P' AS PRODTYPE -- A:합지기 / T:화장지 / P:생리대,기저귀 / E:예외생산
                 , '' AS TOTAL_QTY
                 , (SELECT TO_CHAR(SUM(EA_QTY),'FM999,999,990') FROM TB_WRK001
                    WHERE 1=1
                      AND WERKS = W011.WERKS
                      AND MACH_CD = W011.MACH_CD
                      AND WRK_ORDR_NO = W011.WRK_ORDR_NO
                      AND WRK_ORDR_SEQNO = W011.WRK_ORDR_SEQNO
                      AND PRFM_GTHR_YN = 'Y') AS PRD_QTY
                 , '' AS DISPO_QTY
                 , TO_CHAR(FN_CHG_UNIT(W011.MATNR, W011.WERKS, W004.UNIT, 'EA', W004.ERR_QTY),'FM999,990') AS DISPO_LOG
            FROM TB_WRK011 W011, TB_SCH013 S013, TB_MAS001 M001
               , (SELECT WERKS, MACH_CD, WRK_ORDR_NO, WRK_ORDR_SEQNO
                       , DISPO_QTY AS ERR_QTY, UNIT
                    FROM TB_WRK016
                   WHERE 1=1
                     AND WERKS = P_WERKS
                     AND MACH_CD = P_MACH_CD
                     AND PRFM_DT = FN_RECDATE(V_DATE)) W004
            WHERE 1=1
            AND W011.WERKS = S013.WERKS(+)
            AND W011.MACH_CD = S013.MACH_CD(+)
            AND S013.WERKS = M001.WERKS(+)
            AND S013.MATNR = M001.MATNR(+)
            AND S013.WERKS = W004.WERKS(+)
            AND S013.MACH_CD = W004.MACH_CD(+)
            AND S013.WRK_ORDR_NO = W004.WRK_ORDR_NO(+)
            AND S013.WRK_ORDR_SEQNO = W004.WRK_ORDR_SEQNO(+)
            AND S013.WERKS = P_WERKS
            AND S013.MACH_CD = P_MACH_CD
            AND W011.IN_OUT = V_IOTYPE
            AND S013.WRK_ORDR_NO = V_PRE_WRK_ORDR_NO
            AND S013.WRK_ORDR_SEQNO = V_PRE_WRK_ORDR_SEQNO
            UNION ALL
            --신규 선택 지시정보
            SELECT FN_DT_FORMAT(S013.PRD_REQ_DT,'YYYY-MM-DD') AS PRD_REQ_DT
                 , S013.ORDER_NO
                 , S013.WRK_ORDR_NO
                 , S013.WRK_ORDR_SEQNO
                 , M001.MATNR
                 , M001.MATNR_NM
                 , M001.MATNR_SPEC
                 , S013.SPEC
                 , S013.WRK_ORDR_RMK
                 , S013.ORDER_QTY
                 , TO_CHAR(V_DATE,'YYYY-MM-DD HH24:MI:SS') AS PRD_STR_DATE
                 , '' AS PRD_END_DATE
                 , '0' AS MACH_STA
                 , 'P' AS PRODTYPE -- A:합지기 / T:화장지 / P:생리대,기저귀 / E:예외생산
                 , '' AS TOTAL_QTY
                 , '' AS PRD_QTY
                 , '' AS DISPO_QTY
                 , '' AS DISPO_LOG
            FROM TB_SCH013 S013, TB_MAS001 M001
            WHERE 1=1
            AND S013.WERKS = M001.WERKS(+)
            AND S013.MATNR = M001.MATNR(+)
            AND S013.WERKS = P_WERKS
            AND S013.WRK_ORDR_NO = P_WRK_ORDR_NO
            AND S013.WRK_ORDR_SEQNO = V_WRK_ORDR_SEQ;
            --작업 정상 종료 코드 등록
            RS_CODE := 'S';
        --기저귀
        ELSIF P_PROC_CD = 'RC' THEN
            --결과 테이블 반환용 변수
            OPEN CUR_1 FOR
            --기존 작업 지시정보
            SELECT FN_DT_FORMAT(S014.PRD_REQ_DT,'YYYY-MM-DD') AS PRD_REQ_DT
                 , S014.ORDER_NO
                 , S014.WRK_ORDR_NO
                 , S014.WRK_ORDR_SEQNO
                 , M001.MATNR
                 , M001.MATNR_NM
                 , M001.MATNR_SPEC
                 , S014.SPEC
                 , S014.WRK_ORDR_RMK
                 , S014.ORDER_QTY
                 , TO_CHAR(TO_DATE(S014.PRD_STR_DTM,'YYYYMMDDHH24MISS'),'YYYY-MM-DD HH24:MI:SS') AS PRD_STR_DATE
                 --, S014.PRD_END_DTM AS PRD_END_DATE
                 --, TO_CHAR(S014.PRD_LAST_DATE,'YYYY-MM-DD HH24:MI:SS') AS PRD_END_DATE
                 , TO_CHAR(V_DATE,'YYYY-MM-DD HH24:MI:SS') AS PRD_END_DATE
                 , V_MACH_STA AS MACH_STA
                 , 'P' AS PRODTYPE -- A:합지기 / T:화장지 / P:생리대,기저귀 / E:예외생산
                 , '' AS TOTAL_QTY
                 , (SELECT TO_CHAR(SUM(EA_QTY),'FM999,999,990') FROM TB_WRK001
                    WHERE 1=1
                      AND WERKS = W011.WERKS
                      AND MACH_CD = W011.MACH_CD
                      AND WRK_ORDR_NO = W011.WRK_ORDR_NO
                      AND WRK_ORDR_SEQNO = W011.WRK_ORDR_SEQNO
                      AND PRFM_GTHR_YN = 'Y') AS PRD_QTY
                 , '' AS DISPO_QTY
                 , TO_CHAR(FN_CHG_UNIT(W011.MATNR, W011.WERKS, W004.UNIT, 'EA', W004.ERR_QTY),'FM999,990') AS DISPO_LOG
            FROM TB_WRK011 W011, TB_SCH014 S014, TB_MAS001 M001
               , (SELECT WERKS, MACH_CD, WRK_ORDR_NO, WRK_ORDR_SEQNO
                       , DISPO_QTY AS ERR_QTY, UNIT
                    FROM TB_WRK016
                   WHERE 1=1
                     AND WERKS = P_WERKS
                     AND MACH_CD = P_MACH_CD
                     AND PRFM_DT = FN_RECDATE(V_DATE)) W004
            WHERE 1=1
            AND W011.WERKS = S014.WERKS(+)
            AND W011.MACH_CD = S014.MACH_CD(+)
            AND S014.WERKS = M001.WERKS(+)
            AND S014.MATNR = M001.MATNR(+)
            AND S014.WERKS = W004.WERKS(+)
            AND S014.MACH_CD = W004.MACH_CD(+)
            AND S014.WRK_ORDR_NO = W004.WRK_ORDR_NO(+)
            AND S014.WRK_ORDR_SEQNO = W004.WRK_ORDR_SEQNO(+)
            AND S014.WERKS = P_WERKS
            AND S014.MACH_CD = P_MACH_CD
            AND W011.IN_OUT = V_IOTYPE
            AND S014.WRK_ORDR_NO = V_PRE_WRK_ORDR_NO
            AND S014.WRK_ORDR_SEQNO = V_PRE_WRK_ORDR_SEQNO
            UNION ALL
            --신규 선택 지시정보
            SELECT FN_DT_FORMAT(S014.PRD_REQ_DT,'YYYY-MM-DD') AS PRD_REQ_DT
                 , S014.ORDER_NO
                 , S014.WRK_ORDR_NO
                 , S014.WRK_ORDR_SEQNO
                 , M001.MATNR
                 , M001.MATNR_NM
                 , M001.MATNR_SPEC
                 , S014.SPEC
                 , S014.WRK_ORDR_RMK
                 , S014.ORDER_QTY
                 , TO_CHAR(V_DATE,'YYYY-MM-DD HH24:MI:SS') AS PRD_STR_DATE
                 , '' AS PRD_END_DATE
                 , '0' AS MACH_STA
                 , 'P' AS PRODTYPE -- A:합지기 / T:화장지 / P:생리대,기저귀 / E:예외생산
                 , '' AS TOTAL_QTY
                 , '' AS PRD_QTY
                 , '' AS DISPO_QTY
                 , '' AS DISPO_LOG
            FROM TB_SCH014 S014, TB_MAS001 M001
            WHERE 1=1
            AND S014.WERKS = M001.WERKS(+)
            AND S014.MATNR = M001.MATNR(+)
            AND S014.WERKS = P_WERKS
            AND S014.WRK_ORDR_NO = P_WRK_ORDR_NO
            AND S014.WRK_ORDR_SEQNO = V_WRK_ORDR_SEQ;
            --작업 정상 종료 코드 등록
            RS_CODE := 'S';
        --생리대 예외생산
        ELSIF P_PROC_CD = 'PF' OR P_PROC_CD = 'PE' OR P_PROC_CD = 'PG' THEN
            --결과 테이블 반환용 변수
            OPEN CUR_1 FOR
            --기존 작업 지시정보
            SELECT FN_DT_FORMAT(S019.PRD_REQ_DT,'YYYY-MM-DD') AS PRD_REQ_DT
                 , S019.ORDER_NO
                 , S019.WRK_ORDR_NO
                 , S019.WRK_ORDR_SEQNO
                 , M001.MATNR
                 , M001.MATNR_NM
                 , M001.MATNR_SPEC
                 , '' AS SPEC
                 , '' AS WRK_ORDR_RMK
                 , S019.WRK_ORDR_QTY AS ORDER_QTY
                 , TO_CHAR(TO_DATE(S019.PRD_STR_DTM,'YYYYMMDDHH24MISS'),'YYYY-MM-DD HH24:MI:SS') AS PRD_STR_DATE
                 --, TO_CHAR(S019.UPDDATE,'YYYY-MM-DD HH24:MI:SS') AS PRD_END_DATE
                 , TO_CHAR(V_DATE,'YYYY-MM-DD HH24:MI:SS') AS PRD_END_DATE
                 , V_MACH_STA AS MACH_STA
                 , 'E' AS PRODTYPE -- A:합지기 / T:화장지 / P:생리대,기저귀 / E:예외생산
                 , '' AS TOTAL_QTY
                 , (SELECT TO_CHAR(SUM(EA_QTY),'FM999,999,990') FROM TB_WRK001
                    WHERE 1=1
                      AND WERKS = S019.WERKS
                      AND MACH_CD = S019.MACH_CD
                      AND WRK_ORDR_NO = S019.WRK_ORDR_NO
                      AND WRK_ORDR_SEQNO = S019.WRK_ORDR_SEQNO
                      AND PRFM_GTHR_YN = 'Y') AS PRD_QTY
                 --, TO_CHAR(S019.COMP_QTY,'FM999,999,990') AS PRD_QTY
                 , '' AS DISPO_QTY
                 , (SELECT TO_CHAR(SUM(DISPO_QTY),'FM999,990') FROM TB_WRK016
                    WHERE 1=1
                      AND WERKS = S019.WERKS
                      AND MACH_CD = S019.MACH_CD
                      AND WRK_ORDR_NO = S019.WRK_ORDR_NO
                      AND WRK_ORDR_SEQNO = S019.WRK_ORDR_SEQNO) AS DISPO_LOG
            FROM TB_SCH019 S019, TB_MAS001 M001
            WHERE 1=1
            AND S019.WERKS = M001.WERKS(+)
            AND S019.MATNR = M001.MATNR(+)
            AND S019.WERKS = P_WERKS
            AND S019.MACH_CD = P_MACH_CD
            AND S019.WRK_ORDR_NO = V_PRE_WRK_ORDR_NO
            AND S019.WRK_ORDR_SEQNO = V_PRE_WRK_ORDR_SEQNO
            UNION ALL
            --신규 선택 지시정보
            SELECT FN_DT_FORMAT(S019.PRD_REQ_DT,'YYYY-MM-DD') AS PRD_REQ_DT
                 , S019.ORDER_NO
                 , S019.WRK_ORDR_NO
                 , S019.WRK_ORDR_SEQNO
                 , M001.MATNR
                 , M001.MATNR_NM
                 , M001.MATNR_SPEC
                 , '' AS SPEC
                 , '' AS WRK_ORDR_RMK
                 , S019.WRK_ORDR_QTY AS ORDER_QTY
                 , TO_CHAR(V_DATE,'YYYY-MM-DD HH24:MI:SS') AS PRD_STR_DATE
                 , '' AS PRD_END_DATE
                 , '0' AS MACH_STA
                 , 'E' AS PRODTYPE -- A:합지기 / T:화장지 / P:생리대,기저귀 / E:예외생산
                 , '' AS TOTAL_QTY
                 , '' AS PRD_QTY
                 , '' AS DISPO_QTY
                 , '' AS DISPO_LOG
            FROM TB_SCH019 S019, TB_MAS001 M001
            WHERE 1=1
            AND S019.WERKS = M001.WERKS(+)
            AND S019.MATNR = M001.MATNR(+)
            AND S019.WERKS = P_WERKS
            AND S019.WRK_ORDR_NO = P_WRK_ORDR_NO
            AND S019.WRK_ORDR_SEQNO = V_WRK_ORDR_SEQ;
            --작업 정상 종료 코드 등록
            RS_CODE := 'S';
        END IF;
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
END SP_POP_WRK41_S01;
/
