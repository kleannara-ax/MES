--------------------------------------------------------
--  DDL for Procedure SP_POP_WRK24_I02_220607
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK24_I02_220607" 
(
    P_WERKS     		IN VARCHAR2 	                --플랜트
    ,P_MACH_CD   		IN VARCHAR2 	                --설비코드
    ,P_ROLLCNT          IN NUMBER                       --권치수
    ,P_WGT              IN NUMBER                       --중량
    ,P_RSPEED           IN NUMBER                       --선속
    ,P_SDATE            IN VARCHAR2                     --작업시작시간(YYYYMMDDHHMMSS)
    ,P_EDATE            IN VARCHAR2                     --작업종료시간(YYYYMMDDHHMMSS)
    ,P_TM               IN NUMBER                       --작업시간
    ,P_PRFM_DT          IN VARCHAR2                     --생산실적일자(YYYYMMDD)
    ,P_FINISH           IN VARCHAR2                     --완료여부
    ,P_MATNR            IN VARCHAR2                     --비계획 자재코드
    ,P_RMK              IN VARCHAR2                     --비고
    ,P_USERID           IN VARCHAR2                     --USER ID
    ,RS_IND_BCD   		OUT VARCHAR2                    --개별바코드
    ,Lang       		IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE     		OUT VARCHAR2 
    ,RS_MSG      		OUT VARCHAR2
    
)
AS 
    --프로그램 ID : 점보롤 실적등록
    V_PRG_NM        VARCHAR2(100)  := 'SP_POP_WRK24_I02';     -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID   varchar2(20) := 'TEST'; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);
    --parameter변수 처리
    V_WERKS                     TB_WRK002.WERKS%TYPE;
    V_MATNR                     TB_WRK002.MATNR%TYPE;
    V_WRK_ORDR_NO               TB_WRK002.WRK_ORDR_NO%TYPE;
    V_WRK_ORDR_SEQNO            TB_WRK002.WRK_ORDR_SEQNO%TYPE;
    V_ORDER_NO                  TB_WRK002.ORDER_NO%TYPE;
    V_WRK_CLASS                 TB_WRK002.WRK_CLASS%TYPE;
    V_WRK_SHIFT                 TB_WRK002.WRK_SHIFT%TYPE;
    V_PRD_DT                    TB_WRK002.PRD_DT%TYPE;
    V_UNIT                      TB_MAS001.UNIT%TYPE;
    V_REGDATE                   DATE := SYSDATE;
    V_DOC_NO                    VARCHAR2(20);
    V_DOC_SEQNO                 NUMBER;
    V_IND_BCD                   VARCHAR2(20);
    V_LOT_NO                    VARCHAR2(10);
    V_STOR_LOC_CD               TB_INV001.STOR_LOC_CD%TYPE;
    V_LOC_CD                    TB_INV001.LOC_CD%TYPE;
    V_SDATE                     VARCHAR2(10);
    V_STIME                     VARCHAR2(8);
    V_EDATE                     VARCHAR2(10);
    V_ETIME                     VARCHAR2(8);
    V_SAP_WRK_CD                TB_MAS012.SAP_WRK_CD%TYPE;          --실적전송 시 SAP 작업장
    V_MACHINE                   TB_MAS012.MACHINE%TYPE;             --생산호기
    V_TOMACHINE                 TB_MAS012.MACHINE%TYPE;             --TO생산호기
    V_PRD_STR_DTM               VARCHAR2(15);           --작업시작일시 갱신용
    V_RUN_STA                   VARCHAR2(10);           -- 01 : 정상, 08 : 비계획생산
    V_RUN_STA_PRE               VARCHAR2(10);           -- 이전 운전상태 01 : 정상, 08 : 비계획생산
    V_WRK_SEQ                   TB_WRK002.WRK_SEQ%TYPE;
    V_PRD_NO                    TB_WRK002.PRD_NO%TYPE;
    V_STCK_STA                  VARCHAR2(10);
BEGIN

    BEGIN
        SELECT WRK_ORDR_NO, WRK_ORDR_SEQNO, ORDER_NO, MATNR, WRK_CLASS, WRK_SHIFT, LOT_NO, NVL(RUN_STA, '01') RUN_STA
            INTO V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_ORDER_NO, V_MATNR, V_WRK_CLASS, V_WRK_SHIFT, V_LOT_NO, V_RUN_STA_PRE
          FROM TB_WRK011
        WHERE MACH_CD = P_MACH_CD; 

        SELECT TO_MACHINE INTO V_TOMACHINE
          FROM TB_SCH015
         WHERE WRK_ORDR_NO = V_WRK_ORDR_NO
           AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO;

        IF NVL(P_MATNR, ' ' ) <> ' ' THEN
            V_RUN_STA := '08';
            V_MATNR := P_MATNR;
        ELSE
            V_RUN_STA := '01';
        END IF;

        SELECT UNIT
            INTO V_UNIT
          FROM TB_MAS001
         WHERE WERKS = P_WERKS
           AND MATNR = V_MATNR;

         SELECT SAP_WRK_CD, MACHINE
            INTO V_SAP_WRK_CD, V_MACHINE
          FROM TB_MAS012
         WHERE MACH_CD = P_MACH_CD;   

        --생산순번 조회
        BEGIN
            SELECT MAX(WRK_SEQ) INTO V_WRK_SEQ
              FROM TB_WRK002
             WHERE WERKS = P_WERKS
               AND MACH_CD = P_MACH_CD
               AND PRFM_DT = P_PRFM_DT;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                V_WRK_SEQ := 0;
        END;

        V_WRK_SEQ := NVL(V_WRK_SEQ, 0) + 1;

        V_PRD_NO := TO_CHAR(TO_DATE(P_PRFM_DT, 'YYYYMMDD'), 'YYYY-MM-DD') || '-' || V_MACHINE || '-' || TO_CHAR(V_WRK_SEQ);

        V_PRD_DT := TO_CHAR(V_REGDATE, 'YYYYMMDD');
        --I/F 문서번호
        V_DOC_NO := FN_GET_MDOCNO('M','IF125');
        V_DOC_SEQNO := 1;

        --개별바코드
        SP_GET_BARCODE_SEQ('IND', P_WERKS, P_MACH_CD, V_MATNR, P_SDATE, V_IND_BCD);

        --LOT NO
        IF V_RUN_STA = '08' THEN
            SP_GET_BARCODE_SEQ('LOT', P_WERKS, 'J', V_MATNR, P_SDATE, V_LOT_NO);
            V_ORDER_NO :=' ';
            V_STCK_STA := '60';
        ELSE
            SP_CHK_LOT_NO(NVL(V_LOT_NO, ' '), P_WERKS, P_MACH_CD, V_MATNR, P_SDATE, V_LOT_NO);
            V_STCK_STA := '00';
--            IF V_RUN_STA <> V_RUN_STA_PRE THEN
--                SP_GET_BARCODE_SEQ('LOT', P_WERKS, P_MACH_CD, V_MATNR, P_SDATE, V_LOT_NO);
--            ELSE
--                
--            END IF;
        END IF;

        --실적등록
        INSERT INTO TB_WRK002( WERKS, MACH_CD, IND_BCD, LOT_NO, MATNR, 
                            ORDER_NO, WRK_ORDR_NO, WRK_ORDR_SEQNO, PRD_NO,
                            UNIT, ROLLCNT, PRFM_QTY, WGT, RSPEED, MER_YN, GRD_YN,
                            PRD_STR_DATE, PRD_END_DATE, TM, PRFM_DT, PRD_DT,
                            DSTBT_DDLIN, WRK_CLASS, WRK_SHIFT, MACHINE, STA,
                            DOC_NO, DOC_SEQNO, RMK, REGDATE, REGID, RUN_STA, WRK_SEQ)
                    VALUES(P_WERKS, P_MACH_CD, V_IND_BCD, V_LOT_NO, V_MATNR,  
                            V_ORDER_NO, V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_PRD_NO,
                            V_UNIT, P_ROLLCNT, P_WGT, P_WGT, P_RSPEED, 'N', 'N',
                            TO_DATE(P_SDATE, 'YYYYMMDDHH24MISS'),
                            TO_DATE(P_EDATE, 'YYYYMMDDHH24MISS'),
                            P_TM, P_PRFM_DT, V_PRD_DT,
                            '', V_WRK_CLASS, V_WRK_SHIFT, V_MACHINE, V_STCK_STA,
                            V_DOC_NO, V_DOC_SEQNO, P_RMK, V_REGDATE, P_USERID, V_RUN_STA, V_WRK_SEQ);

        --재고 생성
        V_STOR_LOC_CD := '2000';
        V_LOC_CD := 'L2100';
        INSERT INTO TB_INV001( WERKS, STOR_LOC_CD, IND_BCD, MATNR, LOC_CD, LOT_NO,
                            MACH_CD, MACHINE, WRK_ORDR_NO, WRK_ORDR_SEQNO, ORDER_NO,
                            PRD_NO, IN_MR_YN, PRD_DT, UNIT, STCK_QTY, ROLLCNT, WGT, STCK_STA,
                            DOC_NO, DOC_SEQNO, DLFL, REGDATE, REGID)
                    VALUES( P_WERKS, V_STOR_LOC_CD, V_IND_BCD, V_MATNR, V_LOC_CD, V_LOT_NO,
                            P_MACH_CD, V_MACHINE, V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_ORDER_NO, 
                            '', 'N', V_PRD_DT, V_UNIT, P_WGT, P_ROLLCNT, P_WGT, V_STCK_STA,
                            V_DOC_NO, V_DOC_SEQNO, 'N', V_REGDATE, P_USERID);


        V_PRD_STR_DTM := P_EDATE; --TO_CHAR(TO_DATE(P_EDATE, 'YYYYMMDDHH24MISS'), 'YYYYMMDDHH24MISS');

        IF P_FINISH = 'Y' THEN
            UPDATE TB_SCH015
               SET PRD_END_DTM = P_EDATE, 
                   COMP_YN = 'Y'
             WHERE WRK_ORDR_NO = V_WRK_ORDR_NO
               AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO;

            -- 점보롤 완료인경우 TB_WRK011(작업장(설비)별 현재 진행현황) 테이블 업데이트 진행
            -- 작업진행중인 작업지시번호 -> 이전작업지시번호, 작업지시순번 -> 이전작업지시순번으로 이동
            -- 자재번호, 작업지시번호, 작업지시순번 삭제
            UPDATE TB_WRK011
                SET PRE_WRK_ORDR_NO = V_WRK_ORDR_NO,
                    PRE_WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO,
                    MATNR = '',
                    WRK_ORDR_NO = '', 
                    WRK_ORDR_SEQNO = '',
                    ORDER_NO = '',
                    LOT_NO = '',
                    PRD_STR_DTM = V_PRD_STR_DTM,
                    MACH_STA = 'N',
                    RUN_STA = V_RUN_STA
            WHERE MACH_CD = P_MACH_CD; 
        ELSE
            UPDATE TB_WRK011
                SET PRD_STR_DTM = V_PRD_STR_DTM,
                    LOT_NO = V_LOT_NO,  
                    RUN_STA = V_RUN_STA
            WHERE MACH_CD = P_MACH_CD; 
        END IF;

        --I/F 데이터 생성
        IF P_FINISH = 'Y' THEN
            V_SDATE := TO_CHAR(TO_DATE(P_SDATE, 'YYYYMMDDHH24MISS'), 'YYYY-MM-DD');
            V_STIME := TO_CHAR(TO_DATE(P_SDATE, 'YYYYMMDDHH24MISS'), 'HH24:MI:SS');
            V_EDATE := TO_CHAR(TO_DATE(P_EDATE, 'YYYYMMDDHH24MISS'), 'YYYY-MM-DD');
            V_ETIME := TO_CHAR(TO_DATE(P_EDATE, 'YYYYMMDDHH24MISS'), 'HH24:MI:SS');
        ELSE
            V_SDATE := ' ';
            V_STIME := ' ';
            V_EDATE := ' ';
            V_ETIME := ' ';
        END IF;

        INSERT INTO TB_IFS003( AUFNR, JRLOT, WERKS, WORKCENTERCODE, BUDAT, BUDAT_SAP, MACHINE,
                            WORKGROUP, JVERID, JMATNR, JROLLCNT, JBRGEW, JGEWEI, JRUNTIME,
                            CONF, JSDATE, JSTIME, JEDATE, JETIME, JSPEED, MDOCNO, MDOCSEQ,
                            MAKE_DATE, MAKER)
                     VALUES(V_ORDER_NO, V_LOT_NO, P_WERKS, V_SAP_WRK_CD, TO_CHAR(TO_DATE(P_PRFM_DT, 'YYYYMMDD'), 'YYYY-MM-DD'), TO_CHAR(TO_DATE(P_PRFM_DT, 'YYYYMMDD'), 'YYYY-MM-DD'), V_MACHINE,
                            NVL(V_WRK_CLASS, ' '), V_MACHINE, V_MATNR, P_ROLLCNT, P_WGT, V_UNIT, TO_CHAR(P_TM),
                            P_FINISH, V_SDATE, V_STIME, V_EDATE, V_ETIME, P_RSPEED, V_DOC_NO, TO_CHAR(V_DOC_SEQNO),
                            V_REGDATE, P_USERID);

        RS_IND_BCD := V_IND_BCD;
        RS_CODE := 'S';
        COMMIT;      
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
