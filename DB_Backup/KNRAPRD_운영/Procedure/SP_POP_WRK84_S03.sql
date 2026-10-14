--------------------------------------------------------
--  DDL for Procedure SP_POP_WRK84_S03
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK84_S03" 
(
    P_WERKS             IN VARCHAR2 --plantcode
    ,P_OPCODE           IN VARCHAR2 --공정정보
    ,P_WRK_ORDR_NO      IN VARCHAR2 --작업지시번호
    ,P_WRK_ORDR_SEQNO   IN VARCHAR2 --작업지시순번
    ,P_IND_BCD          IN VARCHAR2 --개별바코드
    ,P_WRK_INFO_01      OUT VARCHAR2 --작업지시 상세정보 1
    ,P_WRK_INFO_02      OUT VARCHAR2 --작업지시 상세정보 2
    ,P_WRK_RMK          OUT VARCHAR2 --작업지시 비고
    ,P_RMK              OUT VARCHAR2 --비고
    ,Lang               IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE            OUT VARCHAR2 
    ,RS_MSG             OUT VARCHAR2
)
/*==============================================================================
 * PROGRAM ID    : SP_POP84_S03
 * PROGRAM NAME  : 실적현황 상세정보 조회
 * VERSION       : 1.0.0
 * DESCRIPTION   : 실적현황 화면에서 투입정보에 대한 상세정보 표시 기능
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
    --주작업화면에서 공정정보에 있는 작업지시번호, 순번으로 작업지시 상세보기 정보 전달
    V_PRG_NM         VARCHAR2(100)  := 'SP_POP_WRK84_S03';     -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID   varchar2(20) := 'TEST'; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);
    --parameter변수 처리

    --내부 변수 등록
    V_OPCODE    VARCHAR2(10) := P_OPCODE;
    V_RMK		TB_WRK002.RMK%TYPE;					--비고

    V_RUN_STA_PRFM  TB_WRK002.RUN_STA%TYPE;         --운전상태
    V_RUN_STA_DISPO TB_WRK004.RUN_STA%TYPE;         --운전상태 폐품

    V_RUN_STA       TB_WRK002.RUN_STA%TYPE;         --운전상태
    V_RUN_STA_NM    CMCDV.CDESC1%TYPE;      
BEGIN
    --예외처리 시작(try)
    BEGIN
        BEGIN
--			dbms_output.put_line(V_OPCODE);
            P_RMK := '';

            -- P_IND_BCD
            IF NVL(P_IND_BCD, '0') != '0' THEN
                IF P_WERKS = 'P100' THEN
                    BEGIN
                        SELECT RUN_STA, RMK 
                          INTO V_RUN_STA_PRFM, V_RMK 
                            FROM TB_WRK002 
                            WHERE 1=1
                                AND WERKS = P_WERKS
                                AND IND_BCD = P_IND_BCD;
                     EXCEPTION
                            WHEN NO_DATA_FOUND THEN
                                 V_RUN_STA_PRFM := '';
                                 V_RMK  := '';
                     END ;  

                     BEGIN
                        SELECT RUN_STA
                            INTO V_RUN_STA_DISPO
                        FROM TB_WRK004     --폐품실적
                        WHERE 1=1
                            AND WERKS = P_WERKS
                            AND IND_BCD = P_IND_BCD;
                     EXCEPTION
                            WHEN NO_DATA_FOUND THEN
                                 V_RUN_STA_DISPO := '';
                     END;

                     -- 운전상태 가져오기
                     IF NVL(V_RUN_STA_DISPO, '00') = '02' THEN
                        V_RUN_STA := V_RUN_STA_DISPO;
                     ELSE
                        V_RUN_STA := V_RUN_STA_PRFM;
                     END IF;

                     -- 운전상태명
                     IF NVL(V_RUN_STA, '00') != '00' THEN
                        BEGIN
                            SELECT CDESC1 INTO V_RUN_STA_NM
                            FROM CMCDV
                            WHERE 1=1
                              AND CMCDKY = 'RUN_STA'
                              AND CMCDVL = V_RUN_STA;
                         EXCEPTION
                                WHEN NO_DATA_FOUND THEN
                                     V_RUN_STA_NM := '';
                         END;
                     END IF;
                ELSE    -- HL 인경우는 운전상태가 없음
                     BEGIN
                        SELECT RMK
                          INTO V_RMK 
                            FROM TB_WRK001 
                            WHERE 1=1
                                AND WERKS = P_WERKS
                                AND IND_BCD = P_IND_BCD;
                     EXCEPTION
                            WHEN NO_DATA_FOUND THEN
                                 V_RMK  := '';
                     END;

                     V_RUN_STA_NM := '';
                END IF;
            END IF;

            --점보롤
            IF V_OPCODE = 'JA' THEN
                BEGIN
                    SELECT '작업지시^' || W002.WRK_ORDR_NO || '-' || W002.WRK_ORDR_SEQNO
                        || '|오더번호^' || W002.ORDER_NO
                        || '|점보롤 LOT번호^' || W002.LOT_NO
                        || '|점보롤 개별바코드^' || W002.IND_BCD                    
                        || '||지종^' || M001.PCODE
                        || '|지종명^' || M001.PCODE_NM
                        || '|평량(g/m²)^' || NVL(RTRIM(TO_CHAR(M001.BS_WGT, 'fm999,999,999,999,990.999'), '.'), '0')
                        || '|지폭(mm)^' || NVL(RTRIM(TO_CHAR(S015.JWIDTH, 'fm999,999,999,999,990.999'), '.'), '0')
                        || '|'
                        || '|운전상태^' || V_RUN_STA_NM     --'01'=정상, '02'=폐품, '09'=비계획생산
                        || '|시작^' || TO_CHAR(W002.PRD_STR_DATE, 'YYYY-MM-DD HH24:MI:SS')
                        || '|종료^' || TO_CHAR(W002.PRD_END_DATE, 'YYYY-MM-DD HH24:MI:SS')
                        || '|가동시간(분)^' || NVL(RTRIM(TO_CHAR(W002.TM, 'fm999,999,999,999,990.999'), '.'), '0')
                        || '|선속^' || NVL(RTRIM(TO_CHAR(W002.RSPEED, 'fm999,999,999,999,990.999'), '.'), '0')
                      ,    '계획권치수(M)^' || NVL(RTRIM(TO_CHAR(S015.JROLLCNT, 'fm999,999,999,999,990.999'), '.'), '0')
                        || '|계획중량(Kg)^' || NVL(RTRIM(TO_CHAR(S015.WRK_ORDR_QTY, 'fm999,999,999,999,990.999'), '.'), '0')
                        || '|실적권치수(M)^' || CASE WHEN W002.PRFM_GTHR_YN = 'Y' THEN NVL(RTRIM(TO_CHAR(W002.ROLLCNT, 'fm999,999,999,999,990.999'), '.'), '0') ELSE '0' END  --실적권치수
                        || '|실적중량(Kg)^' || CASE WHEN W002.PRFM_GTHR_YN = 'Y' THEN NVL(RTRIM(TO_CHAR(W002.WGT, 'fm999,999,999,999,990.999'), '.'), '0') ELSE '0' END       --실적중량
                        || '|'
                        || '|폐품코드^' || W004.DISPO_CD
                        || '|폐품원인^' || M023.DISPO_NM
                        || '|폐품량(M)^' || NVL(RTRIM(TO_CHAR(W004.ROLLCNT, 'fm999,999,999,999,990.999'), '.'), '0')
                        || '|폐품중량(Kg)^' || NVL(RTRIM(TO_CHAR(W004.WGT, 'fm999,999,999,999,990.999'), '.'), '0')
                        || '|'
                        || '|생산유형^' || CASE WHEN W002.MACHINE = 'PM2' THEN '라인교체' ELSE '자체생산' END
                        || '|생산호기^' || S015.MACHINE_NM
                        || '|이동호기^' || S015.TO_MACHINE_NM
                        || '|자재번호^' || W002.MATNR
                        || '|반^' || W002.WRK_CLASS
                        || '|작업자^' || USRMA.NMLAST
                      , S015.ORDER_RMK
                      , V_RMK 
                    INTO P_WRK_INFO_01, P_WRK_INFO_02, P_WRK_RMK, P_RMK
                    FROM TB_WRK002 W002    --PS실적
                       , TB_WRK004 W004    --PS폐품실적
                       , TB_SCH015 S015     -- 점보롤 작업지시
                       , TB_MAS001 M001     --자재코드 마스터
                       , TB_MAS023 M023     --폐품항목관리 마스터
                       , USRMA USRMA
                    WHERE 1=1
                       AND W002.WERKS = S015.WERKS(+)
                       AND W002.WRK_ORDR_NO = S015.WRK_ORDR_NO(+)
                       AND W002.WRK_ORDR_SEQNO = S015.WRK_ORDR_SEQNO(+)
                       AND W002.WERKS = W004.WERKS(+)
                       AND W002.IND_BCD = W004.IND_BCD(+)
                       AND W002.WRK_ORDR_NO = W004.WRK_ORDR_NO(+)
                       AND W002.WRK_ORDR_SEQNO = W004.WRK_ORDR_SEQNO(+)
                       AND W002.WERKS = M001.WERKS(+)
                       AND W002.MATNR = M001.MATNR(+)
                       AND W004.DISPO_CD = M023.DISPO_CD(+)
                       AND W002.REGID = USRMA.USERID(+)
                       AND W002.WERKS = P_WERKS
                       AND W002.IND_BCD = P_IND_BCD
                       AND W002.WRK_ORDR_NO = P_WRK_ORDR_NO
                       AND W002.WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
                       AND NVL(W002.CNL_YN,'N') = 'N';
                EXCEPTION
                      WHEN NO_DATA_FOUND THEN
                          RS_CODE := 'E';
                          RS_MSG := '작업지시 정보를 찾지 못했습니다.';
                          RETURN;
                END;

            --리와인더
            ELSIF V_OPCODE = 'MA'  THEN          --밀롤, 슬리터
                BEGIN
                    SELECT a, b,c,d 
                    INTO P_WRK_INFO_01, P_WRK_INFO_02, P_WRK_RMK, P_RMK
                    FROM
                    (
                            SELECT '작업지시^' || W002.WRK_ORDR_NO || '-' || W002.WRK_ORDR_SEQNO
                                || '|밀롤 오더번호^' || W002.ORDER_NO
                                || '|점보롤 오더번호^' || S016.PRE_ORDER_NO
                                || '|밀롤 LOT번호^' || W002.LOT_NO
                                || '|밀롤 개별바코드^' || W002.IND_BCD
                                || '|'
                                || '|지종^' || M001.PCODE
                                || '|지종명^' || M001.PCODE_NM
                                || '|평량(g/m²)^' || NVL(RTRIM(TO_CHAR(M001.BS_WGT, 'fm999,999,999,999,990.999'), '.'), '0')
                                || '|지폭(mm)^' || NVL(RTRIM(TO_CHAR(M001.WLEN, 'fm999,999,999,999,990.999'), '.'), '0')
                                || '|지관(inch)^' || W002.CORE
                                || '|폭수^' || S016.MRCNT
                                || '|'
                                || '|지폭순번^' || W002.WIDTH_NO
                                || '|실적순서^' || W002.PRD_SEQ
                                || '|밀롤적치^' || W002.MRLDCK
                                || '|재단번호^' || W002.CUTTER a
                                ,
                                   '계획권치수(M)^' || NVL(RTRIM(TO_CHAR(S016.MROLLCNT, 'fm999,999,999,999,990.999'), '.'), '0')
                                || '|계획중량(Kg)^' || NVL(RTRIM(TO_CHAR(S016.MBRGEW, 'fm999,999,999,999,990.999'), '.'), '0')
                                || '|실적권치수(M)^' || CASE WHEN W002.PRFM_GTHR_YN = 'Y' THEN NVL(RTRIM(TO_CHAR(W002.ROLLCNT, 'fm999,999,999,999,990.999'), '.'), '0') ELSE '0' END  --실적권치수
                                || '|실적중량(Kg)^' || CASE WHEN W002.PRFM_GTHR_YN = 'Y' THEN NVL(RTRIM(TO_CHAR(W002.WGT, 'fm999,999,999,999,990.999'), '.'), '0') ELSE '0' END       --실적중량
                                || '|'
                                || '|폐품코드^' || W004.DISPO_CD
                                || '|폐품원인^' || M023.DISPO_NM
                                || '|폐품량(M)^' || NVL(RTRIM(TO_CHAR(W004.ROLLCNT, 'fm999,999,999,999,990.999'), '.'), '0')
                                || '|폐품중량(Kg)^' || NVL(RTRIM(TO_CHAR(W004.WGT, 'fm999,999,999,999,990.999'), '.'), '0')
                                || '|'
                                || '|생산유형^' || CASE WHEN W002.MACHINE = 'PM2' THEN '라인교체' ELSE '자체생산' END
                                || '|생산호기^' || S016.MACHINE_NM
                                || '|이동호기^' || S016.TO_MACHINE_NM
                                || '|자재번호^' || W002.MATNR
                                || '|반^' || W002.WRK_CLASS
                                || '|작업자^' || USRMA.NMLAST 
                                || '|거래처^' || S016.KUNNRT  b
                              , S016.ORDER_RMK  c
                              , V_RMK           d
                            FROM TB_WRK002 W002    --PS실적
                               , TB_WRK004 W004    --PS폐품실적
                               , TB_SCH016 S016     --밀롤 작업지시
                               , TB_MAS001 M001     --자재코드 마스터
                               , TB_MAS023 M023     --폐품항목관리 마스터
                               , USRMA USRMA
                            WHERE 1=1
                               AND W002.WERKS = S016.WERKS(+)
                               AND W002.WRK_ORDR_NO = S016.WRK_ORDR_NO(+)
                               AND W002.WRK_ORDR_SEQNO = S016.WRK_ORDR_SEQNO(+)
                               AND W002.WERKS = W004.WERKS(+)
                               AND W002.IND_BCD = W004.IND_BCD(+)
                               AND W002.WRK_ORDR_NO = W004.WRK_ORDR_NO(+)
                               AND W002.WRK_ORDR_SEQNO = W004.WRK_ORDR_SEQNO(+)
                               AND W002.WERKS = M001.WERKS(+)
                               AND W002.MATNR = M001.MATNR(+)
                               AND W004.DISPO_CD = M023.DISPO_CD(+)
                               AND W002.REGID = USRMA.USERID(+)
                               AND W002.WERKS = P_WERKS
                               AND W002.IND_BCD = P_IND_BCD
                               AND W002.WRK_ORDR_NO = P_WRK_ORDR_NO
                               AND W002.WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
                               AND NVL(W002.CNL_YN,'N') = 'N'
                          UNION ALL
                            SELECT '작업지시^' || W004.WRK_ORDR_NO || '-' || W004.WRK_ORDR_SEQNO
                                || '|밀롤 오더번호^' || S016.ORDER_NO  /*W004.ORDER_NO*/
                                || '|점보롤 오더번호^' || S016.PRE_ORDER_NO
                                || '|밀롤 LOT번호^' || W004.LOT_NO
                                || '|밀롤 개별바코드^' || W004.IND_BCD
                                || '|'
                                || '|지종^' || M001.PCODE
                                || '|지종명^' || M001.PCODE_NM
                                || '|평량(g/m²)^' || NVL(RTRIM(TO_CHAR(M001.BS_WGT, 'fm999,999,999,999,990.999'), '.'), '0')
                                || '|지폭(mm)^' || NVL(RTRIM(TO_CHAR(S016.MWIDTH, 'fm999,999,999,999,990.999'), '.'), '0')
                                || '|지관(inch)^' || ''   /*W004.CORE*/
                                || '|폭수^' || S016.MRCNT
                                || '|'
                                || '|지폭순번^' || '' /*W002.WIDTH_NO*/
                                || '|실적순서^' || '' /*W002.PRD_SEQ*/
                                || '|밀롤적치^' || '' /*W002.MRLDCK*/
                                || '|재단번호^' || '' /*W002.CUTTER*/
                              ,    '계획권치수(M)^' || NVL(RTRIM(TO_CHAR(S016.MROLLCNT, 'fm999,999,999,999,990.999'), '.'), '0')
                                || '|계획중량(Kg)^' || NVL(RTRIM(TO_CHAR(S016.MBRGEW, 'fm999,999,999,999,990.999'), '.'), '0')
                                || '|실적권치수(M)^' || NULL /*CASE WHEN W002.PRFM_GTHR_YN = 'Y' THEN NVL(RTRIM(TO_CHAR(W002.ROLLCNT, 'fm999,999,999,999,990.999'), '.'), '0') ELSE '0' END*/  --실적권치수
                                || '|실적중량(Kg)^' || NULL /*CASE WHEN W002.PRFM_GTHR_YN = 'Y' THEN NVL(RTRIM(TO_CHAR(W002.WGT, 'fm999,999,999,999,990.999'), '.'), '0') ELSE '0' END*/       --실적중량
                                || '|'
                                || '|폐품코드^' || W004.DISPO_CD
                                || '|폐품원인^' || M023.DISPO_NM
                                || '|폐품량(M)^' || NVL(RTRIM(TO_CHAR(W004.ROLLCNT, 'fm999,999,999,999,990.999'), '.'), '0')
                                || '|폐품중량(Kg)^' || NVL(RTRIM(TO_CHAR(W004.WGT, 'fm999,999,999,999,990.999'), '.'), '0')
                                || '|'
                                || '|생산유형^' || '' /*CASE WHEN W002.MACHINE = 'PM2' THEN '라인교체' ELSE '자체생산' END*/
                                || '|생산호기^' || S016.MACHINE_NM
                                || '|이동호기^' || S016.TO_MACHINE_NM
                                || '|자재번호^' ||   W004.MATNR
                                || '|반^' ||  W004.WRK_CLASS
                               || '|작업자^' || USRMA.NMLAST
                               || '|거래처^' || S016.KUNNRT
                              , S016.ORDER_RMK
                              , V_RMK 
                            FROM TB_WRK004 W004    --PS폐품실적
                               , TB_SCH016 S016     --밀롤 작업지시
                               , TB_MAS001 M001     --자재코드 마스터
                               , TB_MAS023 M023     --폐품항목관리 마스터
                               , USRMA USRMA
                            WHERE 1=1
                               AND W004.WERKS = S016.WERKS(+)
                               AND W004.WRK_ORDR_NO = S016.WRK_ORDR_NO(+)
                               AND W004.WRK_ORDR_SEQNO = S016.WRK_ORDR_SEQNO(+)
                               AND W004.WERKS = M001.WERKS(+)
                               AND W004.MATNR = M001.MATNR(+)
                               AND W004.DISPO_CD = M023.DISPO_CD(+)
                               AND W004.REGID = USRMA.USERID(+)
                               AND W004.WERKS = P_WERKS
                               AND W004.IND_BCD = P_IND_BCD
                               AND W004.WRK_ORDR_NO = P_WRK_ORDR_NO
                               AND W004.WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
                               AND NVL(W004.CNL_YN,'N') = 'N'
                               AND NOT EXISTS (
                                    SELECT  'x'
                                    FROM   TB_WRK002  WRK002
                                    WHERE  W004.WRK_ORDR_NO     = WRK002.WRK_ORDR_NO
                                       AND W004.WRK_ORDR_SEQNO  = WRK002.WRK_ORDR_SEQNO
                                       AND W004.IND_BCD         = WRK002.IND_BCD
                               )              
                   );
                EXCEPTION
                      WHEN NO_DATA_FOUND THEN
                          RS_CODE := 'E';
                          RS_MSG := '작업지시 정보를 찾지 못했습니다.';
                          RETURN;
                END;

            ELSIF V_OPCODE = 'SA' THEN          --슬리터
                BEGIN
                    SELECT a, b,c,d 
                    INTO P_WRK_INFO_01, P_WRK_INFO_02, P_WRK_RMK, P_RMK
                    FROM
                    (
                            SELECT '작업지시^' || W002.WRK_ORDR_NO || '-' || W002.WRK_ORDR_SEQNO
                                || '|슬리터 오더번호^' || W002.ORDER_NO
                                || '|밀롤 오더번호^' || S016.PRE_ORDER_NO
                                || '|슬리터 LOT번호^' || W002.LOT_NO
                                || '|슬리터 개별바코드^' || W002.IND_BCD
                                || '|'
                                || '|지종^' || M001.PCODE
                                || '|지종명^' || M001.PCODE_NM
                                || '|평량(g/m²)^' || NVL(RTRIM(TO_CHAR(M001.BS_WGT, 'fm999,999,999,999,990.999'), '.'), '0')
                                || '|지폭(mm)^' || NVL(RTRIM(TO_CHAR(M001.WLEN, 'fm999,999,999,999,990.999'), '.'), '0')
                                || '|지관(inch)^' || W002.CORE
                                || '|폭수^' || S016.MRCNT a
                                ,
                                   '계획권치수(M)^' || NVL(RTRIM(TO_CHAR(S016.MROLLCNT, 'fm999,999,999,999,990.999'), '.'), '0')
                                || '|계획중량(Kg)^' || NVL(RTRIM(TO_CHAR(S016.MBRGEW, 'fm999,999,999,999,990.999'), '.'), '0')
                                || '|실적권치수(M)^' || CASE WHEN W002.PRFM_GTHR_YN = 'Y' THEN NVL(RTRIM(TO_CHAR(W002.ROLLCNT, 'fm999,999,999,999,990.999'), '.'), '0') ELSE '0' END  --실적권치수
                                || '|실적중량(Kg)^' || CASE WHEN W002.PRFM_GTHR_YN = 'Y' THEN NVL(RTRIM(TO_CHAR(W002.WGT, 'fm999,999,999,999,990.999'), '.'), '0') ELSE '0' END       --실적중량
                                || '|'
                                || '|폐품코드^' || W004.DISPO_CD
                                || '|폐품원인^' || M023.DISPO_NM
                                || '|폐품량(M)^' || NVL(RTRIM(TO_CHAR(W004.ROLLCNT, 'fm999,999,999,999,990.999'), '.'), '0')
                                || '|폐품중량(Kg)^' || NVL(RTRIM(TO_CHAR(W004.WGT, 'fm999,999,999,999,990.999'), '.'), '0')
                                || '|'
                                || '|생산유형^' || CASE WHEN W002.MACHINE = 'PM2' THEN '라인교체' ELSE '자체생산' END
                                || '|생산호기^' || S016.MACHINE_NM
                                || '|이동호기^' || S016.TO_MACHINE_NM
                                || '|자재번호^' || W002.MATNR
                                || '|반^' || W002.WRK_CLASS
                                || '|작업자^' || USRMA.NMLAST 
                                || '|거래처^' || S016.KUNNRT  b
                              , S016.ORDER_RMK  c
                              , V_RMK           d
                            FROM TB_WRK002 W002    --PS실적
                               , TB_WRK004 W004    --PS폐품실적
                               , TB_SCH016 S016     --밀롤 작업지시
                               , TB_MAS001 M001     --자재코드 마스터
                               , TB_MAS023 M023     --폐품항목관리 마스터
                               , USRMA USRMA
                            WHERE 1=1
                               AND W002.WERKS = S016.WERKS
                               AND W002.WRK_ORDR_NO = S016.WRK_ORDR_NO
                               AND W002.WRK_ORDR_SEQNO = S016.WRK_ORDR_SEQNO
                               AND W002.WERKS = W004.WERKS(+)
                               AND W002.IND_BCD = W004.IND_BCD(+)
                               AND W002.WRK_ORDR_NO = W004.WRK_ORDR_NO(+)
                               AND W002.WRK_ORDR_SEQNO = W004.WRK_ORDR_SEQNO(+)
                               AND W002.WERKS = M001.WERKS(+)
                               AND W002.MATNR = M001.MATNR(+)
                               AND W004.DISPO_CD = M023.DISPO_CD(+)
                               AND W002.REGID = USRMA.USERID(+)
                               AND W002.WERKS = P_WERKS
                               AND W002.IND_BCD = P_IND_BCD
                               AND W002.WRK_ORDR_NO = P_WRK_ORDR_NO
                               AND W002.WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
                               AND NVL(W002.CNL_YN,'N') = 'N'
                          UNION ALL
                            SELECT '작업지시^' || W004.WRK_ORDR_NO || '-' || W004.WRK_ORDR_SEQNO
                                || '|슬리터 오더번호^' || S016.ORDER_NO /*W004.ORDER_NO*/
                                || '|밀롤 오더번호^' || S016.PRE_ORDER_NO
                                || '|슬리터 LOT번호^' || W004.LOT_NO
                                || '|슬리터 개별바코드^' || W004.IND_BCD
                                || '|'
                                || '|지종^' || M001.PCODE
                                || '|지종명^' || M001.PCODE_NM
                                || '|평량(g/m²)^' || NVL(RTRIM(TO_CHAR(M001.BS_WGT, 'fm999,999,999,999,990.999'), '.'), '0')
                                || '|지폭(mm)^' || NVL(RTRIM(TO_CHAR(S016.MWIDTH, 'fm999,999,999,999,990.999'), '.'), '0')
                                || '|지관(inch)^' || ''   /*W004.CORE*/
                                || '|폭수^' || S016.MRCNT a
                              ,    '계획권치수(M)^' || NVL(RTRIM(TO_CHAR(S016.MROLLCNT, 'fm999,999,999,999,990.999'), '.'), '0')
                                || '|계획중량(Kg)^' || NVL(RTRIM(TO_CHAR(S016.MBRGEW, 'fm999,999,999,999,990.999'), '.'), '0')
                                || '|실적권치수(M)^' || NULL /*CASE WHEN W002.PRFM_GTHR_YN = 'Y' THEN NVL(RTRIM(TO_CHAR(W002.ROLLCNT, 'fm999,999,999,999,990.999'), '.'), '0') ELSE '0' END*/  --실적권치수
                                || '|실적중량(Kg)^' || NULL /*CASE WHEN W002.PRFM_GTHR_YN = 'Y' THEN NVL(RTRIM(TO_CHAR(W002.WGT, 'fm999,999,999,999,990.999'), '.'), '0') ELSE '0' END*/       --실적중량
                                || '|'
                                || '|폐품코드^' || W004.DISPO_CD
                                || '|폐품원인^' || M023.DISPO_NM
                                || '|폐품량(M)^' || NVL(RTRIM(TO_CHAR(W004.ROLLCNT, 'fm999,999,999,999,990.999'), '.'), '0')
                                || '|폐품중량(Kg)^' || NVL(RTRIM(TO_CHAR(W004.WGT, 'fm999,999,999,999,990.999'), '.'), '0')
                                || '|'
                                || '|생산유형^' || '' /*CASE WHEN W002.MACHINE = 'PM2' THEN '라인교체' ELSE '자체생산' END*/
                                || '|생산호기^' || S016.MACHINE_NM
                                || '|이동호기^' || S016.TO_MACHINE_NM
                                || '|자재번호^' ||   W004.MATNR
                                || '|반^' ||  W004.WRK_CLASS
                               || '|작업자^' || USRMA.NMLAST
                               || '|거래처^' || S016.KUNNRT
                              , S016.ORDER_RMK
                              , V_RMK 
                            FROM TB_WRK004 W004    --PS폐품실적
                               , TB_SCH016 S016     --밀롤 작업지시
                               , TB_MAS001 M001     --자재코드 마스터
                               , TB_MAS023 M023     --폐품항목관리 마스터
                               , USRMA USRMA
                            WHERE 1=1
                               AND W004.WERKS = S016.WERKS
                               AND W004.WRK_ORDR_NO = S016.WRK_ORDR_NO
                               AND W004.WRK_ORDR_SEQNO = S016.WRK_ORDR_SEQNO
                               AND W004.WERKS = M001.WERKS(+)
                               AND W004.MATNR = M001.MATNR(+)
                               AND W004.DISPO_CD = M023.DISPO_CD(+)
                               AND W004.REGID = USRMA.USERID(+)
                               AND W004.WERKS = P_WERKS
                               AND W004.IND_BCD = P_IND_BCD
                               AND W004.WRK_ORDR_NO = P_WRK_ORDR_NO
                               AND W004.WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
                               AND NVL(W004.CNL_YN,'N') = 'N'
                               AND NOT EXISTS (
                                    SELECT  'x'
                                    FROM   TB_WRK002  WRK002
                                    WHERE  W004.WRK_ORDR_NO     = WRK002.WRK_ORDR_NO
                                       AND W004.WRK_ORDR_SEQNO  = WRK002.WRK_ORDR_SEQNO
                                       AND W004.IND_BCD         = WRK002.IND_BCD
                               )              
                      UNION ALL
                            SELECT '작업지시^' || W002.WRK_ORDR_NO || '-' || W002.WRK_ORDR_SEQNO
                                || '|밀롤 오더번호^' || W002.ORDER_NO
                                || '|밀롤 LOT번호^' || W002.LOT_NO
                                || '|밀롤 개별바코드^' || W002.IND_BCD
                                || '|'
                                || '|지종^' || M001.PCODE
                                || '|지종명^' || M001.PCODE_NM
                                || '|평량(g/m²)^' || NVL(RTRIM(TO_CHAR(M001.BS_WGT, 'fm999,999,999,999,990.999'), '.'), '0')
                                || '|지폭(mm)^' || NVL(RTRIM(TO_CHAR(M001.WLEN, 'fm999,999,999,999,990.999'), '.'), '0')
                                || '|지관(inch)^' || W002.CORE
                                || '|폭수^' || 0 a
                                ,
                                   '계획권치수(M)^' || NVL(TO_CHAR((S016.WRK_ORDR_QTY / (S016.BS_WGT/1000) / (S016.WLEN / 1000)) , 'fm999,999,999,990'), '0')
                                || '|계획중량(Kg)^' || NVL(RTRIM(TO_CHAR(S016.WRK_ORDR_QTY, 'fm999,999,999,999,990.999'), '.'), '0')
                                || '|실적권치수(M)^' || CASE WHEN W002.PRFM_GTHR_YN = 'Y' THEN NVL(RTRIM(TO_CHAR(W002.ROLLCNT, 'fm999,999,999,999,990.999'), '.'), '0') ELSE '0' END  --실적권치수
                                || '|실적중량(Kg)^' || CASE WHEN W002.PRFM_GTHR_YN = 'Y' THEN NVL(RTRIM(TO_CHAR(W002.WGT, 'fm999,999,999,999,990.999'), '.'), '0') ELSE '0' END       --실적중량
                                || '|'
                                || '|폐품코드^' || W004.DISPO_CD
                                || '|폐품원인^' || M023.DISPO_NM
                                || '|폐품량(M)^' || NVL(RTRIM(TO_CHAR(W004.ROLLCNT, 'fm999,999,999,999,990.999'), '.'), '0')
                                || '|폐품중량(Kg)^' || NVL(RTRIM(TO_CHAR(W004.WGT, 'fm999,999,999,999,990.999'), '.'), '0')
                                || '|'
                                || '|생산유형^' || CASE WHEN W002.MACHINE = 'PM2' THEN '라인교체' ELSE '자체생산' END
                                || '|자재번호^' || W002.MATNR
                                || '|반^' || W002.WRK_CLASS
                                || '|작업자^' || USRMA.NMLAST 
                                || '|거래처^' || S016.KUNNRT  b
                              , NULL  c
                              , V_RMK           d
                            FROM TB_WRK002 W002    --PS실적
                               , TB_WRK004 W004    --PS폐품실적
                               , TB_SCH019 S016     --예외 작업지시
                               , TB_MAS001 M001     --자재코드 마스터
                               , TB_MAS023 M023     --폐품항목관리 마스터
                               , USRMA USRMA
                            WHERE 1=1
                               AND W002.WERKS = S016.WERKS
                               AND W002.WRK_ORDR_NO = S016.WRK_ORDR_NO
                               AND W002.WRK_ORDR_SEQNO = S016.WRK_ORDR_SEQNO
                               AND W002.WERKS = W004.WERKS(+)
                               AND W002.IND_BCD = W004.IND_BCD(+)
                               AND W002.WRK_ORDR_NO = W004.WRK_ORDR_NO(+)
                               AND W002.WRK_ORDR_SEQNO = W004.WRK_ORDR_SEQNO(+)
                               AND W002.WERKS = M001.WERKS(+)
                               AND W002.MATNR = M001.MATNR(+)
                               AND W004.DISPO_CD = M023.DISPO_CD(+)
                               AND W002.REGID = USRMA.USERID(+)
                               AND W002.WERKS = P_WERKS
                               AND W002.IND_BCD = P_IND_BCD
                               AND W002.WRK_ORDR_NO = P_WRK_ORDR_NO
                               AND W002.WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
                               AND NVL(W002.CNL_YN,'N') = 'N'
                          UNION ALL
                            SELECT '작업지시^' || W004.WRK_ORDR_NO || '-' || W004.WRK_ORDR_SEQNO
                                || '|밀롤 오더번호^' || '' /*W004.ORDER_NO*/
                                || '|밀롤 LOT번호^' || W004.LOT_NO
                                || '|밀롤 개별바코드^' || W004.IND_BCD
                                || '|'
                                || '|지종^' || M001.PCODE
                                || '|지종명^' || M001.PCODE_NM
                                || '|평량(g/m²)^' || NVL(RTRIM(TO_CHAR(M001.BS_WGT, 'fm999,999,999,999,990.999'), '.'), '0')
                                || '|지폭(mm)^' || NVL(RTRIM(TO_CHAR(0, 'fm999,999,999,999,990.999'), '.'), '0')
                                || '|지관(inch)^' || ''   /*W004.CORE*/
                                || '|폭수^' || 0 a
                              ,    '계획권치수(M)^' || NVL(TO_CHAR((S016.WRK_ORDR_QTY / (S016.BS_WGT/1000) / (S016.WLEN / 1000)) , 'fm999,999,999,990'), '0')
                                || '|계획중량(Kg)^' || NVL(RTRIM(TO_CHAR(S016.WRK_ORDR_QTY, 'fm999,999,999,999,990.999'), '.'), '0')
                                || '|실적권치수(M)^' || NULL /*CASE WHEN W002.PRFM_GTHR_YN = 'Y' THEN NVL(RTRIM(TO_CHAR(W002.ROLLCNT, 'fm999,999,999,999,990.999'), '.'), '0') ELSE '0' END*/  --실적권치수
                                || '|실적중량(Kg)^' || NULL /*CASE WHEN W002.PRFM_GTHR_YN = 'Y' THEN NVL(RTRIM(TO_CHAR(W002.WGT, 'fm999,999,999,999,990.999'), '.'), '0') ELSE '0' END*/       --실적중량
                                || '|'
                                || '|폐품코드^' || W004.DISPO_CD
                                || '|폐품원인^' || M023.DISPO_NM
                                || '|폐품량(M)^' || NVL(RTRIM(TO_CHAR(W004.ROLLCNT, 'fm999,999,999,999,990.999'), '.'), '0')
                                || '|폐품중량(Kg)^' || NVL(RTRIM(TO_CHAR(W004.WGT, 'fm999,999,999,999,990.999'), '.'), '0')
                                || '|'
                                || '|생산유형^' || '' /*CASE WHEN W002.MACHINE = 'PM2' THEN '라인교체' ELSE '자체생산' END*/
                                || '|자재번호^' ||   W004.MATNR
                                || '|반^' ||  W004.WRK_CLASS
                               || '|작업자^' || USRMA.NMLAST
                               || '|거래처^' || S016.KUNNRT
                              , NULL
                              , V_RMK 
                            FROM TB_WRK004 W004    --PS폐품실적
                               , TB_SCH019 S016     --예외 작업지시
                               , TB_MAS001 M001     --자재코드 마스터
                               , TB_MAS023 M023     --폐품항목관리 마스터
                               , USRMA USRMA
                            WHERE 1=1
                               AND W004.WERKS = S016.WERKS
                               AND W004.WRK_ORDR_NO = S016.WRK_ORDR_NO
                               AND W004.WRK_ORDR_SEQNO = S016.WRK_ORDR_SEQNO
                               AND W004.WERKS = M001.WERKS(+)
                               AND W004.MATNR = M001.MATNR(+)
                               AND W004.DISPO_CD = M023.DISPO_CD(+)
                               AND W004.REGID = USRMA.USERID(+)
                               AND W004.WERKS = P_WERKS
                               AND W004.IND_BCD = P_IND_BCD
                               AND W004.WRK_ORDR_NO = P_WRK_ORDR_NO
                               AND W004.WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
                               AND NVL(W004.CNL_YN,'N') = 'N'
                               AND NOT EXISTS (
                                    SELECT  'x'
                                    FROM   TB_WRK002  WRK002
                                    WHERE  W004.WRK_ORDR_NO     = WRK002.WRK_ORDR_NO
                                       AND W004.WRK_ORDR_SEQNO  = WRK002.WRK_ORDR_SEQNO
                                       AND W004.IND_BCD         = WRK002.IND_BCD
                               )                                    
                   );
                EXCEPTION
                      WHEN NO_DATA_FOUND THEN
                          RS_CODE := 'E';
                          RS_MSG := '작업지시 정보를 찾지 못했습니다.';
                          RETURN;
                END;

            --재단
            ELSIF V_OPCODE = 'CA'  THEN           --재단
                --재단 실적 상세보기
                IF NVL(V_RUN_STA_PRFM, '00') = '01' THEN
                    BEGIN
                        SELECT '작업지시^' || W002.WRK_ORDR_NO || '-' || W002.WRK_ORDR_SEQNO
                            || '|재단 오더번호^' || S017.ORDER_NO
                            || '|밀롤 오더번호^' || S017.PRE_ORDER_NO
                            || '|점보롤 오더번호^' || S016.PRE_ORDER_NO
                            || '|재단 LOT번호^' || W002.LOT_NO
                            || '|재단 개별바코드^' || W002.IND_BCD
                            || '|'
                            || '|운전상태^' || V_RUN_STA_NM     --'01'=정상, '02'=폐품, '09'=비계획생산
                            || '|지종^' || M001.PCODE
                            || '|지종명^' || M001.PCODE_NM
                            || '|평량(g/m²)^' || NVL(RTRIM(TO_CHAR(M001.BS_WGT, 'fm999,999,999,999,990.999'), '.'), '0')
                            || '|규격^' || SUBSTR(W002.MATNR, 10, 4) || '*' || SUBSTR(W002.MATNR, 14, 4)
                            ,  '계획연수(R)^' || NVL(RTRIM(TO_CHAR(S017.WRK_ORDR_QTY, 'fm999,999,999,999,990.999'), '.'), '0')
                            || '|계획중량(Kg)^' || NVL(RTRIM(TO_CHAR(S017.TOT_WGT, 'fm999,999,999,999,990.999'), '.'), '0')
                            || '|실적연수(R)^' || CASE WHEN W002.PRFM_GTHR_YN = 'Y' THEN NVL(RTRIM(TO_CHAR(ROUND(FN_CHG_UNIT (  W002.MATNR, P_WERKS, W002.UNIT, 'R', NVL(W002.PRFM_QTY,0)) ,3), 'fm999,999,999,999,990.999'), '.'), '0') ELSE '0' END  --실적연수
                            || '|실적중량(Kg)^' || CASE WHEN W002.PRFM_GTHR_YN = 'Y' THEN NVL(RTRIM(TO_CHAR(W002.WGT, 'fm999,999,999,999,990.999'), '.'), '0') ELSE '0' END       --실적중량
                            || '|'
                            || '|생산호기^' || S017.MACHINE_NM
                            || '|이동호기^' || S017.TO_MACHINE_NM
                            || '|자재번호^' || W002.MATNR
                            || '|반^' || W002.WRK_CLASS
                            || '|작업자^' || USRMA.NMLAST
                            || '|'
                            || '|거래처^' || S017.KUNNRT
                            || '|판매오더번호^' || S017.VBELN || '-' || S017.POSNR
                          , S017.ORDER_RMK
                          , V_RMK 
                        INTO P_WRK_INFO_01, P_WRK_INFO_02, P_WRK_RMK, P_RMK
                        FROM TB_WRK002 W002    --PS실적
                           , TB_SCH017 S017     --재단 작업지시
                           , TB_SCH016 S016     --밀롤 작업지시
                           , TB_MAS001 M001     --자재코드 마스터
                           , USRMA USRMA
                        WHERE 1=1
                           AND W002.WERKS = S017.WERKS
                           AND W002.WRK_ORDR_NO = S017.WRK_ORDR_NO
                           AND W002.WRK_ORDR_SEQNO = S017.WRK_ORDR_SEQNO
                           AND S017.PRE_ORDER_NO = S016.ORDER_NO(+)
                           AND W002.WERKS = M001.WERKS(+)
                           AND W002.MATNR = M001.MATNR(+)
                           AND W002.REGID = USRMA.USERID(+)
                           AND W002.WERKS = P_WERKS
                           AND W002.IND_BCD = P_IND_BCD
                           AND W002.WRK_ORDR_NO = P_WRK_ORDR_NO
                           AND W002.WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
                           AND NVL(W002.CNL_YN,'N') = 'N';
                    EXCEPTION
                          WHEN NO_DATA_FOUND THEN
                              RS_CODE := 'E';
                              RS_MSG := '작업지시 정보를 찾지 못했습니다.';
                              RETURN;
                    END;
                ELSE
                    --재단 페품 상세보기
                    BEGIN
                        SELECT '작업지시^' || W004.WRK_ORDR_NO || '-' || W004.WRK_ORDR_SEQNO
                            || '|재단 오더번호^' || S017.ORDER_NO
                            || '|재단 LOT번호^' || W004.LOT_NO
                            || '|재단 개별바코드^' || W004.IND_BCD
                            || '|'
                            || '|운전상태^' || V_RUN_STA_NM     --'01'=정상, '02'=폐품, '09'=비계획생산
                            || '|지종^' || M001.PCODE
                            || '|지종명^' || M001.PCODE_NM
                            || '|평량(g/m²)^' || NVL(RTRIM(TO_CHAR(M001.BS_WGT, 'fm999,999,999,999,990.999'), '.'), '0')
                            || '|규격^' || SUBSTR(W004.MATNR, 10, 4) || '*' || SUBSTR(W004.MATNR, 14, 4)
                            ,
                               '계획연수(R)^' || NVL(RTRIM(TO_CHAR(S017.WRK_ORDR_QTY, 'fm999,999,999,999,990.999'), '.'), '0')
                            || '|계획중량(Kg)^' || NVL(RTRIM(TO_CHAR(S017.TOT_WGT, 'fm999,999,999,999,990.999'), '.'), '0')
                            || '|'
                            || '|폐품코드^' || W004.DISPO_CD
                            || '|폐품원인^' || M023.DISPO_NM
                            || '|폐품량(M)^' || NVL(RTRIM(TO_CHAR(W004.ROLLCNT, 'fm999,999,999,999,990.999'), '.'), '0')
                            || '|폐품중량(Kg)^' || NVL(RTRIM(TO_CHAR(W004.WGT, 'fm999,999,999,999,990.999'), '.'), '0')
                            || '|'
                            || '|자재번호^' || W004.MATNR
                            || '|반^' || W004.WRK_CLASS
                            || '|작업자^' || USRMA.NMLAST
                            || '|'
                            || '|거래처^' || S017.KUNNRT
                            || '|판매오더번호^' || S017.VBELN || '-' || S017.POSNR
                          , S017.ORDER_RMK
                          , V_RMK 
                        INTO P_WRK_INFO_01, P_WRK_INFO_02, P_WRK_RMK, P_RMK
                        FROM TB_WRK004 W004    --PS폐품실적
                           , TB_SCH017 S017     --재단 작업지시
                           , TB_SCH016 S016     --밀롤 작업지시
                           , TB_MAS001 M001     --자재코드 마스터
                           , TB_MAS023 M023     --폐품항목관리 마스터
                           , USRMA USRMA
                        WHERE 1=1
                           AND W004.WERKS = S017.WERKS
                           AND W004.WRK_ORDR_NO = S017.WRK_ORDR_NO
                           AND W004.WRK_ORDR_SEQNO = S017.WRK_ORDR_SEQNO
                           AND S017.PRE_ORDER_NO = S016.ORDER_NO(+)
                           AND W004.WERKS = M001.WERKS(+)
                           AND W004.MATNR = M001.MATNR(+)
                           AND W004.DISPO_CD = M023.DISPO_CD(+)
                           AND W004.REGID = USRMA.USERID(+)
                           AND W004.WERKS = P_WERKS
                           AND W004.IND_BCD = P_IND_BCD
                           AND W004.WRK_ORDR_NO = P_WRK_ORDR_NO
                           AND W004.WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO;
                           --AND NVL(W004.CNL_YN,'N') = 'N';
                        EXCEPTION
                              WHEN NO_DATA_FOUND THEN
                                  RS_CODE := 'E';
                                  RS_MSG := '작업지시 정보를 찾지 못했습니다.';
                                  RETURN;
                    END;
                END IF;

            ELSIF V_OPCODE = 'CB' THEN           --수재단
                --재단 실적 상세보기
                IF NVL(V_RUN_STA_PRFM, '00') = '01' THEN
                    BEGIN
                        SELECT a, b,c,d 
                        INTO P_WRK_INFO_01, P_WRK_INFO_02, P_WRK_RMK, P_RMK
                        FROM
                        (
                            SELECT '작업지시^' || W002.WRK_ORDR_NO || '-' || W002.WRK_ORDR_SEQNO
                                || '|재단 오더번호^' || S017.ORDER_NO
                                --|| '|밀롤 오더번호^' || S017.PRE_ORDER_NO
                                --|| '|점보롤 오더번호^' || S016.PRE_ORDER_NO
                                || '|재단 LOT번호^' || W002.LOT_NO
                                || '|재단 개별바코드^' || W002.IND_BCD
                                || '|'
                                || '|운전상태^' || V_RUN_STA_NM     --'01'=정상, '02'=폐품, '09'=비계획생산
                                || '|지종^' || M001.PCODE
                                || '|지종명^' || M001.PCODE_NM
                                || '|평량(g/m²)^' || NVL(RTRIM(TO_CHAR(M001.BS_WGT, 'fm999,999,999,999,990.999'), '.'), '0')
                                || '|규격^' || SUBSTR(W002.MATNR, 10, 4) || '*' || SUBSTR(W002.MATNR, 14, 4) a
                                ,  '계획연수(R)^' || NVL(RTRIM(TO_CHAR(S017.WRK_ORDR_QTY, 'fm999,999,999,999,990.999'), '.'), '0')
                                || '|계획중량(Kg)^' || NVL(RTRIM(TO_CHAR(S017.TOT_WGT, 'fm999,999,999,999,990.999'), '.'), '0')
                                || '|실적연수(R)^' || CASE WHEN W002.PRFM_GTHR_YN = 'Y' THEN NVL(RTRIM(TO_CHAR(ROUND(FN_CHG_UNIT (  W002.MATNR, P_WERKS, W002.UNIT, 'R', NVL(W002.PRFM_QTY,0)) ,3), 'fm999,999,999,999,990.999'), '.'), '0') ELSE '0' END  --실적연수
                                || '|실적중량(Kg)^' || CASE WHEN W002.PRFM_GTHR_YN = 'Y' THEN NVL(RTRIM(TO_CHAR(W002.WGT, 'fm999,999,999,999,990.999'), '.'), '0') ELSE '0' END       --실적중량
                                || '|'
                                || '|생산호기^' || S017.MACHINE_NM
                                || '|이동호기^' || S017.TO_MACHINE_NM
                                || '|자재번호^' || W002.MATNR
                                || '|반^' || W002.WRK_CLASS
                                || '|작업자^' || USRMA.NMLAST
                                || '|'
                                || '|거래처^' || S017.KUNNRT
                                || '|판매오더번호^' || S017.VBELN || '-' || S017.POSNR b
                              , S017.ORDER_RMK c
                              , V_RMK    d
                            FROM TB_WRK002 W002    --PS실적
                               , TB_SCH017 S017     --재단 작업지시
                               , TB_SCH016 S016     --밀롤 작업지시
                               , TB_MAS001 M001     --자재코드 마스터
                               , USRMA USRMA
                            WHERE 1=1
                               AND W002.WERKS = S017.WERKS
                               AND W002.WRK_ORDR_NO = S017.WRK_ORDR_NO
                               AND W002.WRK_ORDR_SEQNO = S017.WRK_ORDR_SEQNO
                               AND S017.PRE_ORDER_NO = S016.ORDER_NO(+)
                               AND W002.WERKS = M001.WERKS(+)
                               AND W002.MATNR = M001.MATNR(+)
                               AND W002.REGID = USRMA.USERID(+)
                               AND W002.WERKS = P_WERKS
                               AND W002.IND_BCD = P_IND_BCD
                               AND W002.WRK_ORDR_NO = P_WRK_ORDR_NO
                               AND W002.WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
                               AND NVL(W002.CNL_YN,'N') = 'N'
                            UNION ALL
                            SELECT '작업지시^' || W002.WRK_ORDR_NO || '-' || W002.WRK_ORDR_SEQNO
                                || '|재단 오더번호^' || S017.ORDER_NO
                                || '|재단 LOT번호^' || W002.LOT_NO
                                || '|재단 개별바코드^' || W002.IND_BCD
                                || '|'
                                || '|운전상태^' || V_RUN_STA_NM     --'01'=정상, '02'=폐품, '09'=비계획생산
                                || '|지종^' || M001.PCODE
                                || '|지종명^' || M001.PCODE_NM
                                || '|평량(g/m²)^' || NVL(RTRIM(TO_CHAR(M001.BS_WGT, 'fm999,999,999,999,990.999'), '.'), '0')
                                || '|규격^' || SUBSTR(W002.MATNR, 10, 4) || '*' || SUBSTR(W002.MATNR, 14, 4) a
                                ,  '계획연수(R)^' || NVL(RTRIM(TO_CHAR(S017.WRK_ORDR_QTY, 'fm999,999,999,999,990.999'), '.'), '0')
                                || '|계획중량(Kg)^' || NVL(RTRIM(TO_CHAR(( S017.WRK_ORDR_QTY * 500 ) * ( S017.BS_WGT / 1000 ) * ( S017.WLEN / 1000 ) * ( S017.VLEN / 1000 ), 'fm999,999,999,999,990.999'), '.'), '0')
                                || '|실적연수(R)^' || CASE WHEN W002.PRFM_GTHR_YN = 'Y' THEN NVL(RTRIM(TO_CHAR(ROUND(FN_CHG_UNIT (  W002.MATNR, P_WERKS, W002.UNIT, 'R', NVL(W002.PRFM_QTY,0)) ,3), 'fm999,999,999,999,990.999'), '.'), '0') ELSE '0' END  --실적연수
                                || '|실적중량(Kg)^' || CASE WHEN W002.PRFM_GTHR_YN = 'Y' THEN NVL(RTRIM(TO_CHAR(W002.WGT, 'fm999,999,999,999,990.999'), '.'), '0') ELSE '0' END       --실적중량
                                || '|'
                                || '|자재번호^' || W002.MATNR
                                || '|반^' || W002.WRK_CLASS
                                || '|작업자^' || USRMA.NMLAST 
                                || '|'
                                || '|거래처^' || S017.KUNNRT
                                || '|판매오더번호^' || S017.VBELN || '-' || S017.POSNR b
                              , NULL c
                              , V_RMK    d
                            FROM TB_WRK002 W002    --PS실적
                               , TB_SCH019 S017     --재단 작업지시
                               , TB_MAS001 M001     --자재코드 마스터
                               , USRMA USRMA
                            WHERE 1=1
                               AND W002.WERKS = S017.WERKS
                               AND W002.WRK_ORDR_NO = S017.WRK_ORDR_NO
                               AND W002.WRK_ORDR_SEQNO = S017.WRK_ORDR_SEQNO
                               AND W002.WERKS = M001.WERKS(+)
                               AND W002.MATNR = M001.MATNR(+)
                               AND W002.REGID = USRMA.USERID(+)
                               AND W002.WERKS = P_WERKS
                               AND W002.IND_BCD = P_IND_BCD
                               AND W002.WRK_ORDR_NO = P_WRK_ORDR_NO
                               AND W002.WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
                               AND NVL(W002.CNL_YN,'N') = 'N'
                           ) 
                           ;
                           
                    EXCEPTION
                          WHEN NO_DATA_FOUND THEN
                              RS_CODE := 'E';
                              RS_MSG := '작업지시 정보를 찾지 못했습니다.';
                              RETURN;
                    END;
                ELSE
                    --재단 페품 상세보기
                    BEGIN
                        SELECT a, b,c,d 
                        INTO P_WRK_INFO_01, P_WRK_INFO_02, P_WRK_RMK, P_RMK
                        FROM
                        (
                            SELECT '작업지시^' || W004.WRK_ORDR_NO || '-' || W004.WRK_ORDR_SEQNO
                                || '|재단 오더번호^' || S017.ORDER_NO
                                || '|밀롤 오더번호^' || S017.PRE_ORDER_NO
                                || '|점보롤 오더번호^' || S016.PRE_ORDER_NO
                                || '|재단 LOT번호^' || W004.LOT_NO
                                || '|재단 개별바코드^' || W004.IND_BCD
                                || '|'
                                || '|운전상태^' || V_RUN_STA_NM     --'01'=정상, '02'=폐품, '09'=비계획생산
                                || '|지종^' || M001.PCODE
                                || '|지종명^' || M001.PCODE_NM
                                || '|평량(g/m²)^' || NVL(RTRIM(TO_CHAR(M001.BS_WGT, 'fm999,999,999,999,990.999'), '.'), '0')
                                || '|규격^' || SUBSTR(W004.MATNR, 10, 4) || '*' || SUBSTR(W004.MATNR, 14, 4) a
                                ,  '계획연수(R)^' || NVL(RTRIM(TO_CHAR(S017.WRK_ORDR_QTY, 'fm999,999,999,999,990.999'), '.'), '0')
                                || '|계획중량(Kg)^' || NVL(RTRIM(TO_CHAR(( S017.WRK_ORDR_QTY * 500 ) * ( S017.BS_WGT / 1000 ) * ( S017.WLEN / 1000 ) * ( S017.VLEN / 1000 ), 'fm999,999,999,999,990.999'), '.'), '0')
                                || '|'
                                || '|폐품코드^' || W004.DISPO_CD
                                || '|폐품원인^' || M023.DISPO_NM
                                || '|폐품량(M)^' || NVL(RTRIM(TO_CHAR(W004.ROLLCNT, 'fm999,999,999,999,990.999'), '.'), '0')
                                || '|폐품중량(Kg)^' || NVL(RTRIM(TO_CHAR(W004.WGT, 'fm999,999,999,999,990.999'), '.'), '0')
                                || '|'
                                || '|생산호기^' || S017.MACHINE_NM
                                || '|이동호기^' || S017.TO_MACHINE_NM
                                || '|자재번호^' || W004.MATNR
                                || '|반^' || W004.WRK_CLASS
                                || '|작업자^' || USRMA.NMLAST 
                                || '|'
                                || '|거래처^' || S017.KUNNRT
                                || '|판매오더번호^' || S017.VBELN || '-' || S017.POSNR b
                              , S017.ORDER_RMK  c
                              , V_RMK   d
                            FROM TB_WRK004 W004    --PS폐품실적
                               , TB_SCH017 S017     --재단 작업지시
                               , TB_SCH016 S016     --밀롤 작업지시
                               , TB_MAS001 M001     --자재코드 마스터
                               , TB_MAS023 M023     --폐품항목관리 마스터
                               , USRMA USRMA
                            WHERE 1=1
                               AND W004.WERKS = S017.WERKS
                               AND W004.WRK_ORDR_NO = S017.WRK_ORDR_NO
                               AND W004.WRK_ORDR_SEQNO = S017.WRK_ORDR_SEQNO
                               AND S017.PRE_ORDER_NO = S016.ORDER_NO(+)
                               AND W004.WERKS = M001.WERKS(+)
                               AND W004.MATNR = M001.MATNR(+)
                               AND W004.DISPO_CD = M023.DISPO_CD(+)
                               AND W004.REGID = USRMA.USERID(+)
                               AND W004.WERKS = P_WERKS
                               AND W004.IND_BCD = P_IND_BCD
                               AND W004.WRK_ORDR_NO = P_WRK_ORDR_NO
                               AND W004.WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
                             UNION ALL
                            SELECT '작업지시^' || W004.WRK_ORDR_NO || '-' || W004.WRK_ORDR_SEQNO
                                || '|재단 오더번호^' || S017.ORDER_NO
                                || '|재단 LOT번호^' || W004.LOT_NO
                                || '|재단 개별바코드^' || W004.IND_BCD
                                || '|'
                                || '|운전상태^' || V_RUN_STA_NM     --'01'=정상, '02'=폐품, '09'=비계획생산
                                || '|지종^' || M001.PCODE
                                || '|지종명^' || M001.PCODE_NM
                                || '|평량(g/m²)^' || NVL(RTRIM(TO_CHAR(M001.BS_WGT, 'fm999,999,999,999,990.999'), '.'), '0')
                                || '|규격^' || SUBSTR(W004.MATNR, 10, 4) || '*' || SUBSTR(W004.MATNR, 14, 4) a
                                ,  '계획연수(R)^' || NVL(RTRIM(TO_CHAR(S017.WRK_ORDR_QTY, 'fm999,999,999,999,990.999'), '.'), '0')
                                || '|계획중량(Kg)^' || NVL(RTRIM(TO_CHAR(0, 'fm999,999,999,999,990.999'), '.'), '0')
                                || '|'
                                || '|폐품코드^' || W004.DISPO_CD
                                || '|폐품원인^' || M023.DISPO_NM
                                || '|폐품량(M)^' || NVL(RTRIM(TO_CHAR(W004.ROLLCNT, 'fm999,999,999,999,990.999'), '.'), '0')
                                || '|폐품중량(Kg)^' || NVL(RTRIM(TO_CHAR(W004.WGT, 'fm999,999,999,999,990.999'), '.'), '0')
                                || '|'
                                || '|자재번호^' || W004.MATNR
                                || '|반^' || W004.WRK_CLASS
                                || '|작업자^' || USRMA.NMLAST  
                                || '|'
                                || '|거래처^' || S017.KUNNRT
                                || '|판매오더번호^' || S017.VBELN || '-' || S017.POSNR b
                              , NULL  c
                              , V_RMK   d
                            FROM TB_WRK004 W004    --PS폐품실적
                               , TB_SCH019 S017     --재단 작업지시
                               , TB_MAS001 M001     --자재코드 마스터
                               , TB_MAS023 M023     --폐품항목관리 마스터
                               , USRMA USRMA
                            WHERE 1=1
                               AND W004.WERKS = S017.WERKS
                               AND W004.WRK_ORDR_NO = S017.WRK_ORDR_NO
                               AND W004.WRK_ORDR_SEQNO = S017.WRK_ORDR_SEQNO
                               AND W004.WERKS = M001.WERKS(+)
                               AND W004.MATNR = M001.MATNR(+)
                               AND W004.DISPO_CD = M023.DISPO_CD(+)
                               AND W004.REGID = USRMA.USERID(+)
                               AND W004.WERKS = P_WERKS
                               AND W004.IND_BCD = P_IND_BCD
                               AND W004.WRK_ORDR_NO = P_WRK_ORDR_NO
                               AND W004.WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
                               --AND NVL(W004.CNL_YN,'N') = 'N';                             
                        );    
                        
                        EXCEPTION
                              WHEN NO_DATA_FOUND THEN
                                  RS_CODE := 'E';
                                  RS_MSG := '작업지시 정보를 찾지 못했습니다.';
                                  RETURN;
                    END;
                END IF;

            --포장
            ELSIF V_OPCODE = 'PB' OR V_OPCODE = 'PC' OR V_OPCODE = 'PD' THEN        --자동포장, 수축포장, 수작업 포장
                BEGIN
                    SELECT a, b,c,d 
                      INTO P_WRK_INFO_01, P_WRK_INFO_02, P_WRK_RMK, P_RMK
                      FROM
                        (
                            SELECT '작업지시번호^' || S018.WRK_ORDR_NO || '-' || S018.WRK_ORDR_SEQNO
                                || '|포장 오더번호^' || S018.ORDER_NO
                                || '|재단 오더 번호^' || S018.PRE_ORDER_NO
                                || '|'
                                || '|포장 LOT번호^' || W002.LOT_NO
                                || '|포장 개별바코드^' || W002.IND_BCD
                                || '|'
                                || '|지종^' || M001.PCODE
                                || '|지종명^' || M001.PCODE_NM
                                || '|평량(g/m²)^' || NVL(RTRIM(TO_CHAR(M001.BS_WGT, 'fm999,999,999,999,990.999'), '.'), '0')
                                || '|규격^' || SUBSTR(M001.MATNR, 10, 4) || '*' || SUBSTR(M001.MATNR, 14, 4)
                                || '|'
                                || '|계획연수(R)^' || NVL(RTRIM(TO_CHAR(S018.WRK_ORDR_QTY, 'fm999,999,999,999,990.999'), '.'), '0')
                                || '|계획중량(Kg)^' || NVL(RTRIM(TO_CHAR(S018.TOT_WGT, 'fm999,999,999,999,990.999'), '.'), '0')
                                || '|실적연수(R)^' || CASE WHEN W002.PRFM_GTHR_YN = 'Y' THEN NVL(RTRIM(TO_CHAR(ROUND(FN_CHG_UNIT (  W002.MATNR, P_WERKS, W002.UNIT, 'R', NVL(W002.PRFM_QTY,0)) ,3), 'fm999,999,999,999,990.999'), '.'), '0') ELSE '0' END  --실적연수
                                || '|실적중량(Kg)^' || CASE WHEN W002.PRFM_GTHR_YN = 'Y' THEN NVL(RTRIM(TO_CHAR(W002.WGT, 'fm999,999,999,999,990.999'), '.'), '0') ELSE '0' END  a     --실적중량
                               ,   '지시생성일자^' || NVL(TO_CHAR(TO_DATE(S018.ORDR_GEN_DT, 'YYYYMMDD'), 'YYYY-MM-DD'), '')  --ORDR_GEN_DT
                                || '|생산요청일자^' || NVL(TO_CHAR(TO_DATE(S018.PRD_REQ_DT, 'YYYYMMDD'), 'YYYY-MM-DD'), '') --PRD_REQ_DT
                                || '|'
                                || '|오더유형 텍스트^' || S018.ORDER_DIV_NM
                                || '|생산호기^' || S018.MACHINE_NM
                                || '|자재 코드^' || S018.MATNR
                                || '|팔레트당연수^' || NVL(RTRIM(TO_CHAR(S018.PLT_PER_CNT, 'fm999,999,999,999,990.999'), '.'), '0')    --PLT_PER_CNT
                                || '|속당매수^' || NVL(RTRIM(TO_CHAR(S018.IN_PER_CNT, 'fm999,999,999,999,990.999'), '.'), '0')   --IN_PER_CNT
                                || '|쌍팔레트^' || S018.DBL_FLAG
                                || '|컨테이너 타입^' || S018.CON_TYPE
                                || '|포장 타입^' || FN_CD_VAL('PACK_TYPE', S018.PACKTYPE)
                                || '|'
                                || '|거래처^' || S018.KUNNRT
--                                || '|판매문서 유형^' || S018.SAUART_NM
                                || '|판매오더번호^' || S018.VBELN || '-' || S018.POSNR b
                              , S018.ORDER_RMK	c		--P_WRK_RMK
                              , V_RMK			d		--P_RMK
                            FROM TB_WRK002 W002    --PS실적 
                               , TB_SCH018 S018
                               , TB_MAS001 M001     --자재코드 마스터
                            WHERE 1 = 1 
                                   AND W002.WERKS = S018.WERKS
                                   AND W002.WRK_ORDR_NO = S018.WRK_ORDR_NO
                                   AND W002.WRK_ORDR_SEQNO = S018.WRK_ORDR_SEQNO
                                   AND W002.WERKS = M001.WERKS(+)
                                   AND W002.MATNR = M001.MATNR(+)
                                   AND W002.WERKS = P_WERKS
                                   AND W002.IND_BCD = P_IND_BCD
                                   AND W002.WRK_ORDR_NO = P_WRK_ORDR_NO
                                   AND W002.WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
                             UNION ALL
                            SELECT '작업지시번호^' || S018.WRK_ORDR_NO || '-' || S018.WRK_ORDR_SEQNO
                                || '|포장 오더번호^' || S018.ORDER_NO
                                || '|'
                                || '|포장 LOT번호^' || W002.LOT_NO
                                || '|포장 개별바코드^' || W002.IND_BCD
                                || '|'
                                || '|지종^' || M001.PCODE
                                || '|지종명^' || M001.PCODE_NM
                                || '|평량(g/m²)^' || NVL(RTRIM(TO_CHAR(M001.BS_WGT, 'fm999,999,999,999,990.999'), '.'), '0')
                                || '|규격^' || SUBSTR(M001.MATNR, 10, 4) || '*' || SUBSTR(M001.MATNR, 14, 4)
                                || '|'
                                || '|계획연수(R)^' || NVL(RTRIM(TO_CHAR(S018.WRK_ORDR_QTY, 'fm999,999,999,999,990.999'), '.'), '0')
                                || '|계획중량(Kg)^' || NVL(RTRIM(TO_CHAR(( S018.WRK_ORDR_QTY * 500 ) * ( S018.BS_WGT / 1000 ) * ( S018.WLEN / 1000 ) * ( S018.VLEN / 1000 ), 'fm999,999,999,999,990.999'), '.'), '0')
                                || '|실적연수(R)^' || CASE WHEN W002.PRFM_GTHR_YN = 'Y' THEN NVL(RTRIM(TO_CHAR(ROUND(FN_CHG_UNIT (  W002.MATNR, P_WERKS, W002.UNIT, 'R', NVL(W002.PRFM_QTY,0)) ,3), 'fm999,999,999,999,990.999'), '.'), '0') ELSE '0' END  --실적연수
                                || '|실적중량(Kg)^' || CASE WHEN W002.PRFM_GTHR_YN = 'Y' THEN NVL(RTRIM(TO_CHAR(W002.WGT, 'fm999,999,999,999,990.999'), '.'), '0') ELSE '0' END  a     --실적중량
                               ,   '지시생성일자^' || NVL(TO_CHAR(TO_DATE(S018.ORDR_GEN_DT, 'YYYYMMDD'), 'YYYY-MM-DD'), '')  --ORDR_GEN_DT
                                || '|생산요청일자^' || NVL(TO_CHAR(TO_DATE(S018.PRD_REQ_DT, 'YYYYMMDD'), 'YYYY-MM-DD'), '') --PRD_REQ_DT
                                || '|'
                                || '|자재 코드^' || S018.MATNR
                                || '|팔레트당연수^' || NVL(RTRIM(TO_CHAR(S018.PLT_PER_CNT, 'fm999,999,999,999,990.999'), '.'), '0')    --PLT_PER_CNT
                                || '|속당매수^' || NVL(RTRIM(TO_CHAR(S018.IN_PER_CNT, 'fm999,999,999,999,990.999'), '.'), '0')   --IN_PER_CNT
                                || '|포장 타입^' || FN_CD_VAL('PACK_TYPE', S018.PACKTYPE)
                                || '|'
                                || '|거래처^' || S018.KUNNRT
                                || '|판매오더번호^' || S018.VBELN || '-' || S018.POSNR b
                              , NULL	c		--P_WRK_RMK
                              , V_RMK			d		--P_RMK
                            FROM TB_WRK002 W002    --PS실적 
                               , TB_SCH019 S018
                               , TB_MAS001 M001     --자재코드 마스터
                            WHERE 1 = 1 
                                   AND W002.WERKS = S018.WERKS
                                   AND W002.WRK_ORDR_NO = S018.WRK_ORDR_NO
                                   AND W002.WRK_ORDR_SEQNO = S018.WRK_ORDR_SEQNO
                                   AND W002.WERKS = M001.WERKS(+)
                                   AND W002.MATNR = M001.MATNR(+)
                                   AND W002.WERKS = P_WERKS
                                   AND W002.IND_BCD = P_IND_BCD
                                   AND W002.WRK_ORDR_NO = P_WRK_ORDR_NO
                                   AND W002.WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
                 ) ;                                            
                EXCEPTION
                      WHEN NO_DATA_FOUND THEN
                          RS_CODE := 'E';
                          RS_MSG := '작업지시 정보를 찾지 못했습니다.';
                          RETURN;
                END;

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
        E_SQL_ERR_CD        := -20001;
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
