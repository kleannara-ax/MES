--------------------------------------------------------
--  DDL for Procedure SP_POP_WRK51_S01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK51_S01" SP_POP_WRK51_S01
(
    P_MACH_CD    IN VARCHAR2 
    ,Lang       IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE     OUT VARCHAR2 
    ,RS_MSG      OUT VARCHAR2
    ,CUR_1       OUT SYS_REFCURSOR
    ,CUR_2       OUT SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : POP_WRK51
 * PROGRAM NAME  : 화장지 합지기 판매용 원단 주 작업 화면
 * VERSION       : 1.0.1
 * DESCRIPTION   : 현재 작업지시 및 대기 작업지시 목록을 조회한다.
 *                 
 * AUTHOR NAME   : 백우종
 * CREATE DATE   : 2023/01/18
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 
 * 
 *==============================================================================
 *  관련 테이블
 * - [TB_SCH002] : (.R..) 화장지 합지기 생산오더
 * - [TB_SCH011] : (.R..) 화장지 합지기 작업지시
 * - [TB_MAS001] : (.R..) 자재 기준 정보
 * - [TB_WRK001] : (.R..) HL 생산실적 이력
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM        VARCHAR2(100)  := 'SP_POP_WRK51_S01';     -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID   varchar2(20) := 'TEST'; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);
    --내부변수 관리
    V_COLINFO VARCHAR2(1000);--컬럼설정1
    V_COLTYPE VARCHAR2(1000);--컬럼설정2
--    V_WRK_CD VARCHAR2(8);--설비별 작업장코드
    V_DATE DATE := SYSDATE;
BEGIN
    --예외처리 시작(try)
    BEGIN
        --grid 컬럼 정보 설정
--        V_COLINFO := '생산요청일@C^120|작업지시번호@L^220|순번@R^80|품목코드@C^160|품목명@L^320|규격@H^100|지폭@R^80|계획량@R^80|실적량@R^80|입력량@R^80|단위@C^70|지시사항@L^340|상태@C^70|상세보기@C^100|표시순번@H|작업순번@H';
--        V_COLTYPE := 'PRD_REQ_DT@varchar|WRK_ORDR_NO@varchar|WRK_ORDR_SEQNO@varchar|MATNR@varchar|MATNR_NM@varchar|MATNR_SPEC@varchar|WIDTH@varchar|WRK_ORDR_QTY@varchar|PRFM_QTY@varchar|INS_QTY@varchar|UNIT@varchar|WRK_ORDR_RMK@varchar|STA@varchar|WRK_ORDR_DETAIL@Button|ROWSEQ@varchar|WRK_SEQNO@varchar';
        V_COLINFO := '선택@C^50|생산요청일@C^120|작업지시번호@L^200|순번@R^60|생산오더@H|품목코드@C^160|품목명@L^320|규격@H|평량@H|지폭@R^80|계획량@R^80|실적량@R^80|입력량@R^80|단위@C^70|지시사항@L^340|상태@C^70|시작일자@C^120|종료일자@C^120|순번@H|작업순번@H|권치수@R^100|선속@R^100';
        V_COLTYPE := 'CHK@Button|PRD_REQ_DT@varchar|WRK_ORDR_NO@varchar|WRK_ORDR_SEQNO@varchar|ORDER_NO@varchar|MATNR@varchar|MATNR_NM@varchar|MATNR_SPEC@varchar|BS_WGT@varchar|WIDTH@varchar|ORDER_QTY@varchar|PRFM_QTY@varchar|INS_QTY@varchar|UNIT@varchar|WRK_ORDR_RMK@varchar|MACH_STA@varchar|PRD_STR_DATE@varchar|PRD_END_DATE@varchar|ROWSEQ@varchar|WRK_SEQNO@varchar|ROLLCNT@varchar|SPEED@varchar';
        --컬럼설정 반환 테이블 작성
        OPEN CUR_1 FOR
        SELECT RTN_VALUES FROM FN_SPLIT(V_COLINFO||','||V_COLTYPE,',');

        --합지기 지시목록 조회
        OPEN CUR_2 FOR
        SELECT '-' AS CHK
        	 , S011.PRD_REQ_DT        --생산지시일
             , W011.WRK_ORDR_NO         --작업지시
             , W011.WRK_ORDR_SEQNO      --작업지시 순번
             , S011.ORDER_NO            --생산오더
             , S011.MATNR               --자재코드
             , M001.MATNR_NM            --자재명
             , M001.MATNR_SPEC          --규격
             , M001.BS_WGT AS BS_WGT    --평량
             , TO_CHAR(S011.SPEC, 'FM999,990') AS WIDTH       --지폭
             , S011.WRK_ORDR_QTY AS ORDER_QTY --계획권치수
             , NVL((SELECT SUM(W001.WGT) FROM TB_WRK001 W001
                 WHERE W001.WERKS = S011.WERKS
                   AND W001.MACH_CD = W011.MACH_CD
                   AND W001.WRK_ORDR_NO = S011.WRK_ORDR_NO
                   AND W001.WRK_ORDR_SEQNO = S011.WRK_ORDR_SEQNO
                   AND W001.PRFM_GTHR_YN = 'Y'), 0) AS PRFM_QTY --실적수량
             , 0 AS INS_QTY		--입력량
             , S011.UNIT                --단위
             , S011.WRK_ORDR_RMK AS WRK_ORDR_RMK   --작업지시사항
             , W011.MACH_STA                 --가동여부
             , TO_DATE(W011.PRD_STR_DTM,'YYYYMMDDHH24MISS') AS PRD_STR_DATE --시작시간
             , V_DATE AS PRD_END_DATE --완료시간
             , CASE WHEN NVL(W011.WRK_ORDR_NO,'N/A') = 'N/A' THEN 1 ELSE 0 END AS ROWSEQ
             , S011.WRK_SEQNO
             , '0' AS ROLLCNT
             , '0' AS SPEED
          FROM TB_WRK011 W011,            --작업장 현황
               TB_SCH011 S011,            --화장지 합지기 작업지시
               TB_MAS001 M001             --자재정보
         WHERE 1=1
           AND W011.MACH_CD = P_MACH_CD
           AND W011.WRK_ORDR_NO = S011.WRK_ORDR_NO(+)
           AND S011.WERKS = M001.WERKS(+)
           AND S011.MATNR = M001.MATNR(+)
           AND SUBSTR(W011.MATNR, -1) = 'M'
          
        UNION
        
        SELECT '-' AS CHK
        	 , S011.PRD_REQ_DT        --생산지시일
             , S011.WRK_ORDR_NO         --작업지시
             , S011.WRK_ORDR_SEQNO      --작업지시 순번
             , S011.ORDER_NO            --생산오더
             , S011.MATNR               --자재코드
             , M001.MATNR_NM            --자재명
             , M001.MATNR_SPEC          --규격
             , M001.BS_WGT AS BS_WGT    --평량
             , TO_CHAR(S011.SPEC, 'FM999,990') AS WIDTH       --지폭
             , S011.WRK_ORDR_QTY AS ORDER_QTY --계획권치수
             , NVL((SELECT SUM(W001.WGT) FROM TB_WRK001 W001
                 WHERE W001.WERKS = S011.WERKS
                   AND W001.WRK_ORDR_NO = S011.WRK_ORDR_NO
                   AND W001.WRK_ORDR_SEQNO = S011.WRK_ORDR_SEQNO
                   AND W001.PRFM_GTHR_YN = 'Y'), 0) AS PRFM_QTY --실적수량
             , 0 AS INS_QTY		--입력량
             , S011.UNIT                --단위
             , S011.WRK_ORDR_RMK AS WRK_ORDR_RMK   --작업지시사항
             , W011.MACH_STA                 --가동여부
             , TO_DATE(W011.PRD_STR_DTM,'YYYYMMDDHH24MISS') AS PRD_STR_DATE --시작시간
             , V_DATE AS PRD_END_DATE --완료시간
             , CASE WHEN NVL(W011.WRK_ORDR_NO,'N/A') = 'N/A' THEN 1 ELSE 0 END AS ROWSEQ
             , S011.WRK_SEQNO
             , '0' AS ROLLCNT
             , '0' AS SPEED
          FROM TB_SCH011 S011,            --화장지 합지기 작업지시
          	   TB_WRK011 W011,			  --작업장현황
               TB_MAS001 M001             --자재정보
         WHERE 1=1
           AND S011.WRK_ORDR_NO = W011.WRK_ORDR_NO(+)
           AND S011.WERKS = M001.WERKS(+)
           AND S011.MATNR = M001.MATNR(+)
		   AND S011.WRK_ORDR_RMK IN
		   		(
		   			SELECT WRK_ORDR_NO
		   			FROM   TB_WRK011
		   			WHERE  MACH_CD = P_MACH_CD
		   		)
           AND SUBSTR(S011.MATNR, -1) = 'M'
         ORDER BY 1, 2, 3;

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
