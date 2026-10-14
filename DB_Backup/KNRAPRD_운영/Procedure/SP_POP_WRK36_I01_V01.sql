--------------------------------------------------------
--  DDL for Procedure SP_POP_WRK36_I01_V01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK36_I01_V01" 
(
     P_WERKS             IN VARCHAR2         --플랜트
    ,P_MACH_CD          IN VARCHAR2         --작업장코드(설비코드)
    ,P_DISPO_CD         IN VARCHAR2         --폐품코드
    ,P_UNIT             IN VARCHAR2         --실적단위
    ,P_ROLLCNT          IN NUMBER           --폐품권치수
    ,P_DISPO_QTY        IN NUMBER           --폐품중량
    ,P_SPEED            IN NUMBER           --선속
    ,P_PRD_STR_DATE     IN VARCHAR2         --생산시작 일시(YYYYMMDDHH24MISS)
    ,P_PRD_END_DATE     IN VARCHAR2         --생산 종료 일시(YYYYMMDDHH24MISS)
    ,P_TM               IN VARCHAR2         --생산시간(분)
    ,P_PRFM_DT          IN VARCHAR2         --생산실적일자
    ,P_FINISH           IN VARCHAR2         --완료여부
    ,P_RMK              IN VARCHAR2         --비고
    ,P_USER_ID          IN VARCHAR2 --사용자ID
    ,RS_PRFM_RFCFN      OUT VARCHAR2                    --실적 RFCFN값
    ,RS_DISPO_RFCFN     OUT VARCHAR2                    --폐품 RFCFN값    
    ,RS_ZERO_RFCFN      OUT VARCHAR2                    --0 실적 RFCFN값    
    ,Lang               IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE            OUT VARCHAR2 
    ,RS_MSG             OUT VARCHAR2
    ,CUR_1              OUT SYS_REFCURSOR   --실적 리스트
    ,CUR_2              OUT SYS_REFCURSOR   --실적 데이터        
    ,CUR_3              OUT SYS_REFCURSOR   --폐품 리스트
    ,CUR_4              OUT SYS_REFCURSOR   --폐품 데이터
    ,CUR_5              OUT SYS_REFCURSOR   --0실적 리스트
    ,CUR_6              OUT SYS_REFCURSOR   --0실적 데이터
)
/*==============================================================================
 * PROGRAM ID    : SP_POP_WRK36_I01
 * PROGRAM NAME  : 점보롤 폐품실적 등록
 * VERSION       : 1.0.0
 * DESCRIPTION   : 점보롤 폐품실적 등록
 *                 
 * AUTHOR NAME   : 김병무
 * CREATE DATE   : 2022/05/04
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/05/02    1.0.0   김병무         Initial Version
 * 2022/11/25    1.0.1   김병무         점보롤 폐품등록시 완료처리 일때 0실적 추가
 *==============================================================================
 *  관련 테이블
 * - [TB_WRK004] : (C...) 폐품실적
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM        VARCHAR2(100)  := 'SP_POP_WRK36_I01';     -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID   varchar2(20) := P_USER_ID; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);
    --parameter변수 처리

    V_PRD_STR_DATE DATE := TO_DATE(P_PRD_STR_DATE, 'YYYYMMDDHH24MISS');
    V_PRD_END_DATE DATE := TO_DATE(P_PRD_END_DATE, 'YYYYMMDDHH24MISS');

    --내부 변수 등록
    V_WRK_ORDR_NO           TB_WRK011.WRK_ORDR_NO%TYPE;
    V_WRK_ORDR_SEQNO        TB_WRK011.WRK_ORDR_SEQNO%TYPE;
    V_ORDER_NO              TB_WRK011.ORDER_NO%TYPE;
    V_LOT_NO                TB_WRK011.LOT_NO%TYPE;    
    V_MATNR                 TB_WRK011.MATNR%TYPE;    
    V_DOC_NO                TB_WRK004.DOC_NO%TYPE;
    V_DOC_SEQNO             TB_WRK004.DOC_SEQNO%TYPE;
    V_DOC_ZERO_NO           TB_WRK004.DOC_NO%TYPE;
    V_DOC_ZERO_SEQNO        TB_WRK004.DOC_SEQNO%TYPE;
    V_DISPO_NM              TB_MAS023.DISPO_NM%TYPE;
    V_WRK_CLASS             TB_WRK002.WRK_CLASS%TYPE;
    V_WRK_SHIFT             TB_WRK002.WRK_SHIFT%TYPE;
    V_SDATE                 VARCHAR2(10);
    V_STIME                 VARCHAR2(8);
    V_EDATE                 VARCHAR2(10);
    V_ETIME                 VARCHAR2(8);
    V_DATE                  DATE := SYSDATE;
    V_MACHINE               TB_WRK004.MACHINE%TYPE;
    V_WRK_SEQ               TB_WRK002.WRK_SEQ%TYPE;
    V_PRD_NO                TB_WRK002.PRD_NO%TYPE;
    V_PRD_DT                TB_WRK002.PRD_DT%TYPE;
    V_IND_BCD               VARCHAR2(20);
    V_UNIT                  TB_MAS001.UNIT%TYPE;
    V_SAP_WRK_CD            TB_MAS012.SAP_WRK_CD%TYPE;          --실적전송 시 SAP 작업장
    V_SQL                   VARCHAR2(4000);    
BEGIN
    --예외처리 시작(try)
    BEGIN
        BEGIN
            SELECT WRK_ORDR_NO, WRK_ORDR_SEQNO, ORDER_NO, MATNR, WRK_CLASS, WRK_SHIFT
              INTO V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_ORDER_NO, V_MATNR, V_WRK_CLASS, V_WRK_SHIFT
              FROM TB_WRK011
             WHERE WERKS = P_WERKS
               AND MACH_CD = P_MACH_CD;

            SELECT LOT_NO_BUF INTO V_LOT_NO
              FROM TB_SCH015
             WHERE WRK_ORDR_NO = V_WRK_ORDR_NO
               AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO;

            SELECT SAP_WRK_CD, MACHINE
                INTO V_SAP_WRK_CD, V_MACHINE
              FROM TB_MAS012
             WHERE MACH_CD = P_MACH_CD;   

            SELECT UNIT
                INTO V_UNIT
              FROM TB_MAS001
             WHERE WERKS = P_WERKS
               AND MATNR = V_MATNR; 

            V_WRK_SEQ := NVL(V_WRK_SEQ, 0) + 1;

            V_PRD_NO := TO_CHAR(TO_DATE(P_PRFM_DT, 'YYYYMMDD'), 'YYYY-MM-DD') || '-' || V_MACHINE || '-' || TO_CHAR(V_WRK_SEQ);

            V_PRD_DT := TO_CHAR(V_DATE, 'YYYYMMDD');
            --I/F 문서번호
            V_DOC_NO := FN_GET_MDOCNO('M','IF125');
            V_DOC_SEQNO := 1;

             --개별바코드
            SP_GET_BARCODE_SEQ('IND', P_WERKS, 'J', V_MATNR, P_PRD_STR_DATE, V_IND_BCD);
            --SP_GET_BARCODE_SEQ('IND', P_WERKS, P_MACH_CD, V_MATNR, P_PRD_STR_DATE, V_IND_BCD);

            --LOT NO   
            SP_CHK_LOT_NO(NVL(V_LOT_NO, ' '), P_WERKS, P_MACH_CD, V_MATNR, P_PRD_STR_DATE, V_LOT_NO);

            UPDATE TB_SCH015
               SET LOT_NO_BUF = V_LOT_NO
             WHERE WRK_ORDR_NO = V_WRK_ORDR_NO  
               AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO;

            V_SDATE := TO_CHAR(TO_DATE(P_PRD_STR_DATE, 'YYYYMMDDHH24MISS'), 'YYYY-MM-DD');
            V_STIME := TO_CHAR(TO_DATE(P_PRD_STR_DATE, 'YYYYMMDDHH24MISS'), 'HH24:MI:SS');
            V_EDATE := TO_CHAR(TO_DATE(P_PRD_END_DATE, 'YYYYMMDDHH24MISS'), 'YYYY-MM-DD');
            V_ETIME := TO_CHAR(TO_DATE(P_PRD_END_DATE, 'YYYYMMDDHH24MISS'), 'HH24:MI:SS');

            --실적등록
            INSERT INTO TB_WRK002( WERKS, MACH_CD, IND_BCD, LOT_NO, MATNR, 
                            ORDER_NO, WRK_ORDR_NO, WRK_ORDR_SEQNO, PRD_NO,
                            UNIT, ROLLCNT, PRFM_QTY, WGT, RSPEED, MER_YN, GRD_YN,
                            PRD_STR_DATE, PRD_END_DATE, TM, PRFM_DT, PRD_DT,
                            DSTBT_DDLIN, WRK_CLASS, WRK_SHIFT, MACHINE, STA,
                            DOC_NO, DOC_SEQNO, RMK, REGDATE, REGID, RUN_STA, WRK_SEQ, PRFM_GTHR_YN)
                    VALUES(P_WERKS, P_MACH_CD, V_IND_BCD, V_LOT_NO, V_MATNR,  
                            V_ORDER_NO, V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_PRD_NO,
                            V_UNIT, P_ROLLCNT, P_DISPO_QTY, P_DISPO_QTY, P_SPEED, 'N', 'N',
--                            V_UNIT, P_ROLLCNT, P_DISPO_QTY, P_DISPO_QTY, P_SPEED, 'N', 'N',
                            TO_DATE(P_PRD_STR_DATE, 'YYYYMMDDHH24MISS'),
                            TO_DATE(P_PRD_END_DATE, 'YYYYMMDDHH24MISS'),
                            P_TM, P_PRFM_DT, V_PRD_DT,
                            '', V_WRK_CLASS, V_WRK_SHIFT, V_MACHINE, '00',
                            V_DOC_NO, V_DOC_SEQNO, P_RMK, V_DATE, P_USER_ID, '00', V_WRK_SEQ, 'N');

            INSERT INTO TB_IFS003( AUFNR, JRLOT, WERKS, WORKCENTERCODE, BUDAT, BUDAT_SAP, MACHINE,
                            WORKGROUP, JVERID, JMATNR, JROLLCNT, JBRGEW, JGEWEI, JRUNTIME,
                            CONF, JSDATE, JSTIME, JEDATE, JETIME, JSPEED, MDOCNO, MDOCSEQ,
                            MAKE_DATE, MAKER)
                     VALUES(V_ORDER_NO, V_LOT_NO, P_WERKS, V_SAP_WRK_CD, TO_CHAR(TO_DATE(P_PRFM_DT, 'YYYYMMDD'), 'YYYY-MM-DD'), TO_CHAR(TO_DATE(P_PRFM_DT, 'YYYYMMDD'), 'YYYY-MM-DD'), V_MACHINE,
                            NVL(V_WRK_CLASS, ' '), V_MACHINE, V_MATNR, P_ROLLCNT, P_DISPO_QTY, V_UNIT, TO_CHAR(P_TM),
                            '' /*(CASE WHEN P_FINISH = 'Y' THEN 'X' ELSE '' END)*/, V_SDATE, V_STIME, V_EDATE, V_ETIME, P_SPEED, V_DOC_NO, TO_CHAR(V_DOC_SEQNO),
                            V_DATE, P_USER_ID);
            --SAP FUNC ID
            SELECT RFCFN
              INTO RS_PRFM_RFCFN
              FROM TB_ITFMA
             WHERE 1=1
              AND IFID = 'MES_IF_125';   --생산오더별 실적 취소 TXN

            --인터페이스 파라미터
            OPEN CUR_1 FOR
            SELECT 'MES_IF_125' AS I_IF_ID
                 , 'M' || LTRIM(RTRIM(TO_CHAR(SEQ_GET_IFR_KEY.NEXTVAL, '00000000000000000000000000000'))) AS I_IF_KEY
             FROM dual;

             --인터페이스 상세 파라미터
             V_SQL := FN_IF_QUERY('MES_IF_125', V_DOC_NO);
             OPEN CUR_2 FOR V_SQL;

            --문서이력
            INSERT INTO TB_WRK021(DOC_NO, DOC_SEQNO, DOC_DIV, WERKS, MACH_CD, WRK_ORDR_NO, WRK_ORDR_SEQNO,
                                IND_BCD, LOT_NO, ORDER_NO, CNL_YN, REGDATE, REGID)
                        VALUES(V_DOC_NO, V_DOC_SEQNO, 1, P_WERKS, P_MACH_CD, V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO,
                                V_IND_BCD, V_LOT_NO, V_ORDER_NO, 'N', V_DATE, P_USER_ID);           
                                
            --I/F 폐품 문서번호
            V_DOC_NO := FN_GET_MDOCNO('M','IF134');
            V_DOC_SEQNO := 1;

            -- 폐품 등록
            INSERT INTO TB_WRK004 (WERKS, MACH_CD, IND_BCD, LOT_NO, MATNR, WRK_ORDR_NO, WRK_ORDR_SEQNO,
                                 DISPO_CD, UNIT, DISPO_QTY, ROLLCNT, MACHINE,WGT,
                                 PRD_STR_DATE, PRD_END_DATE, TM, PRFM_DT, RUN_STA, DOC_NO, DOC_SEQNO, RMK, REGDATE, REGID,RSPEED,WRK_CLASS)
                            VALUES(P_WERKS, P_MACH_CD, V_IND_BCD, V_LOT_NO, V_MATNR, V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO,
                                 P_DISPO_CD, P_UNIT, P_DISPO_QTY, P_ROLLCNT, V_MACHINE,P_DISPO_QTY,
                                 V_PRD_STR_DATE, V_PRD_END_DATE, P_TM, P_PRFM_DT, '02', V_DOC_NO, V_DOC_SEQNO, P_RMK, V_DATE, P_USER_ID,P_SPEED,V_WRK_CLASS);

            SELECT DISPO_NM INTO V_DISPO_NM
              FROM TB_MAS023
             WHERE WERKS = P_WERKS
               AND DISPO_CD = P_DISPO_CD;

            V_SDATE := TO_CHAR(TO_DATE(P_PRD_STR_DATE, 'YYYYMMDDHH24MISS'), 'YYYY-MM-DD');
            V_STIME := TO_CHAR(TO_DATE(P_PRD_STR_DATE, 'YYYYMMDDHH24MISS'), 'HH24:MI:SS');
            V_EDATE := TO_CHAR(TO_DATE(P_PRD_END_DATE, 'YYYYMMDDHH24MISS'), 'YYYY-MM-DD');
            V_ETIME := TO_CHAR(TO_DATE(P_PRD_END_DATE, 'YYYYMMDDHH24MISS'), 'HH24:MI:SS');

            INSERT INTO TB_IFS012( AUFNR, LOTNO, BUDAT, MATNR, SCRQTY, RSDQTY, SCRAPCODE,
                                    SCRAPREASON, FAULT, SCRQTY_OP, SCRAPCODE_OP, SCRAPREASON_OP, LGORT, CHARG,
                                    SDATE, STIME, EDATE, ETIME, MDOCNO, MDOCSEQ, ZRESULT, MAKE_DATE, MAKER,
                                    RUNTIME, JSPEED, JREMARK, VBELN, POSNR, WORKCENTERCODE, MRSCQTY)
                            VALUES( V_ORDER_NO, V_LOT_NO, TO_CHAR(TO_DATE(P_PRFM_DT, 'YYYYMMDD'), 'YYYY-MM-DD'), V_MATNR, P_DISPO_QTY, 0, P_DISPO_CD,
                                    V_DISPO_NM, 'N', 0, ' ', ' ', '2000', ' ',
                                    V_SDATE, V_STIME, V_EDATE, V_ETIME, V_DOC_NO, V_DOC_SEQNO, 'N', V_DATE, P_USER_ID,
                                    P_TM, P_SPEED, SUBSTRB(P_RMK, 1, 50), '', '', V_SAP_WRK_CD, 0);

            --SAP FUNC ID
            SELECT RFCFN
              INTO RS_DISPO_RFCFN
              FROM TB_ITFMA
             WHERE 1=1
              AND IFID = 'MES_IF_134';   --생산오더별 실적 취소 TXN

            --인터페이스 파라미터
            OPEN CUR_3 FOR
            SELECT 'MES_IF_134' AS I_IF_ID
                 , 'M' || LTRIM(RTRIM(TO_CHAR(SEQ_GET_IFR_KEY.NEXTVAL, '00000000000000000000000000000'))) AS I_IF_KEY
             FROM dual;

             --인터페이스 상세 파라미터
             V_SQL := FN_IF_QUERY('MES_IF_134', V_DOC_NO);
             OPEN CUR_4 FOR V_SQL;

            --문서이력
            INSERT INTO TB_WRK021(DOC_NO, DOC_SEQNO, DOC_DIV, WERKS, MACH_CD, WRK_ORDR_NO, WRK_ORDR_SEQNO,
                                IND_BCD, LOT_NO, ORDER_NO, CNL_YN, REGDATE, REGID)
                        VALUES(V_DOC_NO, V_DOC_SEQNO, 2, P_WERKS, P_MACH_CD, V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO,
                                V_IND_BCD, V_LOT_NO, V_ORDER_NO, 'N', V_DATE, P_USER_ID);   

            IF P_FINISH = 'Y' THEN
                --I/F 문서번호 (0 실적)
                V_DOC_ZERO_NO := FN_GET_MDOCNO('M','IF125');
                V_DOC_ZERO_SEQNO := 1;
                
                INSERT INTO TB_IFS003( AUFNR, JRLOT, WERKS, WORKCENTERCODE, BUDAT, BUDAT_SAP, MACHINE,
                                WORKGROUP, JVERID, JMATNR, JROLLCNT, JBRGEW, JGEWEI, JRUNTIME,
                                CONF, JSDATE, JSTIME, JEDATE, JETIME, JSPEED, MDOCNO, MDOCSEQ,
                                MAKE_DATE, MAKER)
                         VALUES(V_ORDER_NO, V_LOT_NO, P_WERKS, V_SAP_WRK_CD, TO_CHAR(TO_DATE(P_PRFM_DT, 'YYYYMMDD'), 'YYYY-MM-DD'), TO_CHAR(TO_DATE(P_PRFM_DT, 'YYYYMMDD'), 'YYYY-MM-DD'), V_MACHINE,
                                NVL(V_WRK_CLASS, ' '), V_MACHINE, V_MATNR, '0', '0', V_UNIT, '0' /*TO_CHAR(P_TM)*/,
                                'X' /*(CASE WHEN P_FINISH = 'Y' THEN 'X' ELSE '' END)*/, V_SDATE, V_STIME, V_EDATE, V_ETIME, '0', V_DOC_ZERO_NO, TO_CHAR(V_DOC_ZERO_SEQNO),
                                V_DATE, P_USER_ID);

                --SAP FUNC ID
                SELECT RFCFN
                  INTO RS_ZERO_RFCFN
                  FROM TB_ITFMA
                 WHERE 1=1
                  AND IFID = 'MES_IF_125';   --생산오더별 실적 TXN
                
                --인터페이스 파라미터
                OPEN CUR_5 FOR
                SELECT 'MES_IF_125' AS I_IF_ID
                     , 'M' || LTRIM(RTRIM(TO_CHAR(SEQ_GET_IFR_KEY.NEXTVAL, '00000000000000000000000000000'))) AS I_IF_KEY
                 FROM dual;
    
                 --인터페이스 상세 파라미터
                 V_SQL := FN_IF_QUERY('MES_IF_125', V_DOC_ZERO_NO);
                 OPEN CUR_6 FOR V_SQL;
            
                UPDATE TB_SCH015
                   SET PRD_END_DTM = P_PRD_END_DATE, 
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
                        PRD_STR_DTM = P_PRD_END_DATE,
                        MACH_STA = 'N',
                        RUN_STA = '02'
                WHERE MACH_CD = P_MACH_CD; 
            ELSE
                UPDATE TB_WRK011
                    SET PRD_STR_DTM = P_PRD_END_DATE
                      , LOT_NO = V_LOT_NO  
                      , RUN_STA = '02'
                WHERE MACH_CD = P_MACH_CD; 
            END IF;

            RS_CODE := 'S';
            COMMIT;
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
