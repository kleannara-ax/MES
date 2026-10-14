--------------------------------------------------------
--  DDL for Procedure SP_POP_WRK25_S03
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK25_S03" 
(
    P_WERKS     		IN VARCHAR2 	    --플랜트
    ,P_MACH_CD   		IN VARCHAR2 	    --설비코드
    ,P_IND_BCD          IN VARCHAR2 	    --개별바코드
    ,Lang       		IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE     		OUT VARCHAR2 
    ,RS_MSG      		OUT VARCHAR2
    ,CUR_1       		OUT SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : WRK25{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 밀롤 인쇄용 조회
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 밀롤 인쇄용 조회
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
 * - [TB_SCH016] : (.R..) PS 밀롤 작업지시
 * - [TB_WRK002] : (.R..) PS 생산실적 이력
 * - [TB_MAS001] : (.R..) 자재 기준 정보
 * - [USRMA]     : (.R..) 사용자 정보
 *=============================================================================*/
AS 
    --프로그램 ID - 밀롤 인쇄용 조회
    V_PRG_NM        VARCHAR2(100)  := 'SP_POP_WRK25_S03';     -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID   varchar2(20) := 'TEST'; --USERID

    V_WRK_TYPE          varchar2(2);
    V_LINE              varchar2(10);
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);
    --parameter변수 처리
BEGIN
    BEGIN

        BEGIN
            SELECT DECODE(SUBSTR(WRK_ORDR_NO,1,4), 'WOEX', 'X', 'Y')   -- 작업유형 : 'Y'는 정규생산, 'X'는 예외생산
                INTO V_WRK_TYPE
                FROM TB_WRK002
                WHERE WERKS = P_WERKS
                   AND MACH_CD = P_MACH_CD
                   AND IND_BCD  = P_IND_BCD;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
            RS_CODE := 'E';
            RS_MSG := 'NO_DATA_FOUND';
            RETURN;            
        END;
    
        BEGIN
            SELECT LINE_NM || 'win'
                INTO V_LINE
            FROM TB_MAS012
            WHERE MACH_CD = P_MACH_CD;
        EXCEPTION 
            WHEN NO_DATA_FOUND THEN
            V_LINE := 'win';
        END;
    
        --작업유형 : 'Y'는 정규생산, 'X'는 예외생산
        IF V_WRK_TYPE = 'Y' THEN
            OPEN CUR_1 FOR
            SELECT M001.PCODE_NM,                                                   --지종
                NVL(W002.ROLLCNT, '0') AS ROLLCNT,                                  --실적권치수
                NVL(W002.PRFM_QTY, '0') AS PRFM_QTY,                                --실적중량
                NVL(S016.BS_WGT, '0') AS BS_WGT,                                    --평량
    --            SUBSTR(W002.MATNR, 10, 4) || '*' || SUBSTR(W002.MATNR, 14, 4) as MATNR_SPEC,  --규격
                SUBSTR(W002.MATNR, 10, 4) || '*0' AS MATNR_SPEC,                    --규격
                W002.WRK_SEQ,                                                       --생산순번
                W002.WIDTH_NO,                                                      --지폭순서
                S015.MACHINE        AS JR_MACHINE_NM,                                 --점보롤호기
    --            S016.MACHINE AS MR_MACHINE_NM,                                      --밀롤호기
                W002.MACH_CD        AS MR_MACHINE_NM,
                S016.TO_MACHINE     AS CT_MACHINE_NM,                                 --재단호기
                S016.MWIDTH_INPUT   AS MWIDTH_INPUT,                --작업지시의 실지폭
                W002.WIDTH          AS MWIDTH_USER,                --사용자 입력한 지폭
                W002.MATNR,                                                         --품목코드
                W002.CORE,                                                          --지관
                NVL(FN_CD_VAL('PACK_TYPE', W002.PACKTYPE), ' ')     PACKTYPE,       --포장타입
--                M009.CUST_NM,                                                       --거래처명
                S016.KUNNRT         CUST_NM,                 --bug fix : (원지 거래처 누락) MAS009에 누락된 거래처가 존재하여 작업지시의 거래처명 표시 
                TO_CHAR(W002.REGDATE, 'YYYY-MM-DD HH24:MI') AS WRK_DATE,            --생산일시
                W002.WRK_CLASS,                                                     -- 반
                USRMA.NMLAST AS WRK_NAME,                                           -- 작업자
                USRMA.USERID AS WRK_ID,                                             -- 작업자 ID
                V_LINE || USRMA.EMPLID as EMPLID,                                             -- 사원번호
                W002.LOT_NO AS LOT_NO,                                              -- LOT NO
                S016.ORDER_NO AS ORDER_NO,                                          -- 오더 번호
                S016.VBELN || LPAD(S016.POSNR, 6, '0') AS SALES_ORDR_NO,            --Sales Order No
                CASE WHEN NVL(S016.SHEET, ' ') = 'X' THEN 'SHEET' ELSE 'ROLL' END  AS NEXT_PROC,  --다음공정
                S016.REMARK AS ORDER_RMK,                     -- 생산오더 비고사항
                NVL(S016.SLITER, ' ') AS SLITER,                          --슬리터구분
                --'ORDER RMK X' AS ORDER_RMK,                 -- 생산오더 비고사항
                W002.RMK                                      -- 비고사항
              FROM TB_WRK002 W002,
                   TB_MAS001 M001,
--                   TB_MAS009 M009,
                   USRMA USRMA,
                   TB_SCH015 S015,
                   TB_SCH016 S016
             WHERE W002.WERKS = S016.WERKS(+)
               AND W002.WRK_ORDR_NO = S016.WRK_ORDR_NO(+)
               AND W002.WRK_ORDR_SEQNO = S016.WRK_ORDR_SEQNO(+)
               AND W002.WERKS = S015.WERKS(+)
               AND S016.PRE_ORDER_NO = S015.ORDER_NO(+)
               AND W002.WERKS = M001.WERKS(+)
               AND W002.MATNR = M001.MATNR(+)
--               AND M009.CUST_DIV = 'C'      -- 거래처구분(C:거래처, v=공급처)
--               AND W002.KUNNR = M009.CUST_CD(+)
               AND W002.REGID = USRMA.USERID(+)
               AND W002.WERKS = P_WERKS
               AND W002.MACH_CD = P_MACH_CD
               AND W002.IND_BCD = P_IND_BCD;
    --           AND W002.WRK_ORDR_NO = P_WRK_ORDR_NO
    --           AND W002.WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
        ELSE
            OPEN CUR_1 FOR
            SELECT M001.PCODE_NM,                                                   --지종
                NVL(W002.ROLLCNT, '0') AS ROLLCNT,                                  --실적권치수
                NVL(W002.PRFM_QTY, '0') AS PRFM_QTY,                                --실적중량
                NVL(S019.BS_WGT, '0') AS BS_WGT,                                    --평량
    --            SUBSTR(W002.MATNR, 10, 4) || '*' || SUBSTR(W002.MATNR, 14, 4) as MATNR_SPEC,  --규격
                SUBSTR(W002.MATNR, 10, 4) || '*0' AS MATNR_SPEC,                    --규격
                W002.WRK_SEQ,                                                       --생산순번
                W002.WIDTH_NO,                                                      --지폭순서
                ''      AS JR_MACHINE_NM,                                       --점보롤호기
                ''      AS MR_MACHINE_NM,                                   --밀롤호기
                ''      AS CT_MACHINE_NM,                                  --재단호기
                S019.WLEN           AS MWIDTH_INPUT,                                 --실지폭
                ''                  AS MWIDTH_USER,                         --사용자 입력한 지폭
                W002.MATNR,                                                         --품목코드
                W002.CORE,                                                          --지관
                NVL(FN_CD_VAL('PACK_TYPE', W002.PACKTYPE), ' ')     PACKTYPE,       --포장타입
                M009.CUST_NM,                                                       --거래처명
                TO_CHAR(W002.REGDATE, 'YYYY-MM-DD HH24:MI') AS WRK_DATE,            --생산일시
                W002.WRK_CLASS,                                                     -- 반
                USRMA.NMLAST AS WRK_NAME,                                           -- 작업자
                USRMA.USERID AS WRK_ID,                                             -- 작업자 ID
                V_LINE || USRMA.EMPLID as EMPLID,                                             -- 사원번호
                W002.LOT_NO AS LOT_NO,                                              -- LOT NO
                S019.ORDER_NO AS ORDER_NO,                                          -- 오더 번호
                S019.VBELN || LPAD(S019.POSNR, 6, '0') AS SALES_ORDR_NO,            --Sales Order No
                'ROLL'          AS NEXT_PROC,  --다음공정
                ' '             AS SLITER,                          --슬리터구분
                ''              AS ORDER_RMK,                     -- 생산오더 비고사항
                W002.RMK                                      -- 비고사항
              FROM TB_WRK002 W002,
                   TB_MAS001 M001,
                   TB_MAS009 M009,
                   USRMA USRMA,
                   TB_SCH019 S019
             WHERE W002.WERKS = S019.WERKS(+)
               AND W002.WRK_ORDR_NO = S019.WRK_ORDR_NO(+)
               AND W002.WRK_ORDR_SEQNO = S019.WRK_ORDR_SEQNO(+)
               AND W002.WERKS = M001.WERKS(+)
               AND W002.MATNR = M001.MATNR(+)
               AND M009.CUST_DIV = 'C'      -- 거래처구분(C:거래처, v=공급처)
               AND W002.KUNNR = M009.CUST_CD(+)
               AND W002.REGID = USRMA.USERID(+)
               AND W002.WERKS = P_WERKS
               AND W002.MACH_CD = P_MACH_CD
               AND W002.IND_BCD = P_IND_BCD;
        END IF;

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
        --RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
        RAISE;

        RS_CODE := 'E';
        RS_MSG  := SQLERRM;
        RETURN;
    --예외처리 종료
    END;
END;

/
