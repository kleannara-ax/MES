--------------------------------------------------------
--  DDL for Procedure SP_POP_WRKLAMI_PC_I03
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRKLAMI_PC_I03" 
(
    P_WERKS     		IN VARCHAR2 	                --플랜트 --P100
    ,P_MACH_CD   		IN VARCHAR2 	                --설비코드 --PRD01
    ,P_ROLLCNT          IN NUMBER                       --권치수 --1
    ,P_WRK_ORDR_NO      IN VARCHAR2                     --작업지시번호 --HBLA202210110002
    ,P_WRK_ORDR_SEQNO   IN VARCHAR2                     --작업지시번호SEQ --2
    ,P_WGT              IN NUMBER                       --총중량 --3500
--    ,P_RSPEED           IN NUMBER                       --선속
    ,P_SDATE            IN VARCHAR2                     --작업시작시간(YYYYMMDDHHMMSS) : PRD_STR_DTM  --20221116162600
    ,P_EDATE            IN VARCHAR2                     --작업종료시간(YYYYMMDDHHMMSS) : PRD_END_DTM  --20221117162600
--    ,P_TM               IN NUMBER                       --작업시간
    ,P_PRFM_DT          IN VARCHAR2                     --생산실적일자(YYYYMMDD) : 20221117
    ,P_PRFM_QTY         IN NUMBER                     --실적중량 --3000
    ,P_SALCODE          IN VARCHAR2                     --폐품코드 --621
    ,P_SALWEIGHT        IN VARCHAR2                     --폐품중량 --500
    ,P_PPCODE           IN VARCHAR2                     --지종코드 --K11
    ,P_HEIGHT           IN VARCHAR2                     --길이 --10
    ,P_EQUIL            IN VARCHAR2                     --평형 --15
    ,P_STD              IN VARCHAR2                     --규격 --12
    ,P_FINISH           IN VARCHAR2                     --완료여부 --Y
--    ,P_MATNR            IN VARCHAR2                     --비계획 자재코드
    ,P_RMK              IN VARCHAR2                     --비고--TEST1
    ,P_SALRMK           IN VARCHAR2                     --폐품비고--TEST2
    ,P_WRK_CLASS        IN VARCHAR2                     --작업반 --1
    ,P_WRK_SHIFT        IN VARCHAR2                     --작업조 --A
    ,P_USERID           IN VARCHAR2                     --USER ID --TEST3
    ,P_PRFMMET_QTY        IN NUMBER                       --실중량미터 --50
    ,P_SALMETER           IN NUMBER                       --폐품미터 --10
    ,RS_IND_BCD   		OUT VARCHAR2                    --개별바코드
    ,RS_RFCFN           OUT VARCHAR2                    --RFCFN값
    ,Lang       		IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE     		OUT VARCHAR2 
    ,RS_MSG      		OUT VARCHAR2
    ,CUR_1          OUT SYS_REFCURSOR
    ,CUR_2          OUT SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : WRK073
 * PROGRAM NAME  : 인쇄/코팅
 * VERSION       : 1.0.0
 * DESCRIPTION   : 인쇄/코팅 작업완료를 하지않고 슬리팅 공정으로 이동.
 *                 
 * AUTHOR NAME   : 김수현
 * CREATE DATE   : 2022/11/17
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/05/10    1.0.0   김수현         Initial Version
 *==============================================================================
 *  관련 테이블
 * - [TB_LAMI_PC] : (.R..) 인쇄/코팅 작업지시
 *=============================================================================*/
AS 
    --프로그램 ID : 점보롤 실적등록
    V_PRG_NM        VARCHAR2(100)  := 'SP_POP_WRKLAMI_PC_I03';     -- PROCEDURE NAME
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
    V_PRD_NO                    TB_WRK002.PRD_NO%TYPE;
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
    V_SDATE                     VARCHAR2(10);
    V_STIME                     VARCHAR2(8);
    V_EDATE                     VARCHAR2(10);
    V_ETIME                     VARCHAR2(8);
    V_SAP_WRK_CD                TB_MAS012.SAP_WRK_CD%TYPE;          --실적전송 시 SAP 작업장
    V_LOC_CD                    TB_INV001.LOC_CD%TYPE;
    V_MACHINE                   TB_MAS012.MACHINE%TYPE;             --생산호기
    V_TOMACHINE                 TB_MAS012.MACHINE%TYPE;             --TO생산호기
    V_PRD_STR_DTM               VARCHAR2(15);           --작업시작일시 갱신용
    V_RUN_STA                   VARCHAR2(10);           -- 01 : 정상, 08 : 비계획생산
    V_RUN_STA_PRE               VARCHAR2(10);           -- 이전 운전상태 01 : 정상, 08 : 비계획생산
    V_WRK_SEQ                   TB_WRK002.WRK_SEQ%TYPE;
    V_WIDTH                     TB_WRK002.WIDTH%TYPE;
    V_STCK_STA                  VARCHAR2(10);
    V_IND_BCD_D1        		TB_WRK002.IND_BCD%TYPE;			    --개별바코드 (폐품1실적용)

    V_YMCHK                     TB_MAS011.YMCHK%TYPE;   --실적등록 가능 여부

    V_IF_ID                     VARCHAR2(20) := 'MES_IF_125'; --MES IF ID
    V_SQL                       VARCHAR2(4000);
    V_DOC_NO_INPUT              VARCHAR2(500) := '';

    V_LOT_NO_BUF                VARCHAR2(10);
    V_CYCLE_TIME                VARCHAR2(20);
    V_DOC_NO_SCR      			VARCHAR2(20);
    V_DOC_SEQNO_SCR     		NUMBER;
    V_PRFM_DT      			    VARCHAR2(10);
    V_REMAIN_QTY                NUMBER;
    V_CNT1                      NUMBER(13,0);
    V_PRFM_QTY                  NUMBER(13,0);
    V_CNT2                      NUMBER;
    V_CNT3                      NUMBER;

BEGIN

    BEGIN

		V_CYCLE_TIME := TO_CHAR(ROUND((TO_DATE(P_EDATE, 'YYYYMMDDHH24MISS') - TO_DATE(P_SDATE, 'YYYYMMDDHH24MISS')) * 24 * 60,0));

        IF TO_NUMBER(P_SALWEIGHT) > 0 AND TRIM(P_SALCODE) = '' THEN
            BEGIN
                ROLLBACK;
                RS_CODE := 'E';
                RS_MSG  := '폐품이 ' || P_SALWEIGHT || 'KG이 발생했으나 폐품코드가 없습니다. 폐품선택을 한후 폐품내용를 선택해 주세요 ';
                RETURN;

            END;
        END IF;

        SELECT MATNR, WRK_CLASS, WRK_SHIFT, LOT_NO, NVL(RUN_STA, '01')
            INTO V_MATNR, V_WRK_CLASS, V_WRK_SHIFT, V_LOT_NO, V_RUN_STA_PRE
          FROM TB_WRK011
        WHERE MACH_CD = P_MACH_CD
           AND WRK_ORDR_NO = P_WRK_ORDR_NO
           AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
           AND ROWNUM = 1
        ; 

        SELECT ORDER_NO, UNIT, TO_MACHINE, WLEN ,LOT_BUF, DOC_NO, IND_BCD, REMAIN_QTY, PRFM_QTY
          INTO V_ORDER_NO, V_UNIT, V_TOMACHINE, V_WIDTH, V_LOT_NO, V_DOC_NO, V_IND_BCD, V_REMAIN_QTY, V_PRFM_QTY
          FROM TB_LAMI_PC
         WHERE 1 = 1
           AND WRK_ORDR_NO = P_WRK_ORDR_NO
           AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
           AND NVL(USE_YN,'Y') = 'Y'
           AND ROWNUM = 1
           ;

        V_RUN_STA := '01';

        SELECT SAP_WRK_CD, MACHINE
            INTO V_SAP_WRK_CD, V_MACHINE
          FROM TB_MAS012
         WHERE MACH_CD = P_MACH_CD;   

        --생산순번 조회
        BEGIN
            SELECT NVL(MAX(WRK_SEQ),0) INTO V_WRK_SEQ
              FROM TB_LAMI_PC_RESULT
             WHERE WERKS = P_WERKS
               AND WRK_ORDR_NO = P_WRK_ORDR_NO
               AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
               ;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                V_WRK_SEQ := 0;
        END;

        SELECT NVL(COUNT(*),0)
        INTO V_CNT1
        FROM TB_LAMI_PC_RESULT
        WHERE 1 = 1
        AND WRK_ORDR_NO = P_WRK_ORDR_NO
        AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
        AND WERKS = P_WERKS
        ;

        V_WRK_SEQ := NVL(V_WRK_SEQ, 0) + 1;

        V_PRD_NO := TO_CHAR(TO_DATE(P_PRFM_DT, 'YYYYMMDD'), 'YYYY-MM-DD') || '-' || V_MACHINE || '-' || TO_CHAR(V_WRK_SEQ);

        V_PRD_DT := TO_CHAR(V_REGDATE, 'YYYYMMDD');

        V_DOC_SEQNO := 1;

        SP_GET_BARCODE_SEQ_LAMI('IND', P_WERKS, P_MACH_CD, V_MATNR, P_SDATE, V_IND_BCD);

        LOOP
            BEGIN

                SELECT COUNT(IND_BCD)
                INTO V_CNT2
                FROM TB_WRK002
                WHERE 1 = 1
                AND WERKS = P_WERKS
                AND MACH_CD = P_MACH_CD
                AND IND_BCD = V_IND_BCD
                ;

                SELECT COUNT(IND_BCD)
                INTO V_CNT3
                FROM TB_WRK008
                WHERE 1 = 1
                AND WERKS = P_WERKS
                AND MACH_CD = P_MACH_CD
                AND IND_BCD = V_IND_BCD;

                IF V_CNT2 = 0 AND V_CNT3 = 0 THEN
                    EXIT;
                ELSE
                    SP_GET_BARCODE_SEQ_LAMI('IND', P_WERKS, P_MACH_CD, V_MATNR, P_SDATE, V_IND_BCD);
                END IF;
            END;
        END LOOP;

        RS_IND_BCD := V_IND_BCD;

        --LOT NO(SAP저장 결과에 따라 바뀔수 있음 : 현재는 주석 처리)
         IF V_RUN_STA = '09' THEN
                    V_ORDER_NO :=' ';
                    V_STCK_STA := '60';

                    V_WRK_ORDR_SEQNO := 1;

        ELSE
                    V_STCK_STA := '00';

        END IF;

        IF V_REMAIN_QTY > 0 AND V_REMAIN_QTY - (P_PRFM_QTY + P_SALWEIGHT) >= 0 THEN
            BEGIN
                UPDATE TB_LAMI_PC
                   SET 
                  CYCLE_TIME = CYCLE_TIME + V_CYCLE_TIME
                  ,PRFM_QTY = PRFM_QTY + P_PRFM_QTY
                  ,SAPYN = 'N'
                  ,SALWEIGHT = SALWEIGHT + P_SALWEIGHT
                  ,REMAIN_QTY = REMAIN_QTY - (P_PRFM_QTY + P_SALWEIGHT)
                  ,SALMETER = SALMETER + P_SALMETER
                  ,PRFMMET_QTY = PRFMMET_QTY + P_PRFMMET_QTY
                 WHERE WRK_ORDR_NO = P_WRK_ORDR_NO  
                   AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
                   AND MACH_CD = P_MACH_CD
                   AND WERKS = P_WERKS
                   --AND NVL(DLFL,'N') = 'N'  --삭제지시자 X='삭제' , N=정상오더
                   AND NVL(USE_YN, 'Y') = 'Y'
--                   AND NVL(COMP_YN, 'I') = 'I'
                   ;
            END;


                --실적등록
                INSERT INTO TB_LAMI_PC_RESULT( WERKS, MACH_CD, IND_BCD, LOT_NO, MATNR, 
                                    ORDER_NO, WRK_ORDR_NO, WRK_ORDR_SEQNO, PRD_NO,
                                    UNIT, WIDTH, ROLLCNT, PRFM_QTY, WGT, RSPEED, MER_YN, GRD_YN,
                                    PRD_STR_DATE, PRD_END_DATE, TM, PRFM_DT, PRD_DT,
                                    DSTBT_DDLIN, WRK_CLASS, WRK_SHIFT, MACHINE, TO_MACHINE, STA,
                                    DOC_NO, DOC_SEQNO, RMK, REGDATE, REGID, RUN_STA, WRK_SEQ, USE_YN,SALCODE,SALWEIGHT,SL_MOVE_YN)
                            VALUES(P_WERKS, P_MACH_CD, V_IND_BCD, V_LOT_NO, V_MATNR,  
                                    V_ORDER_NO, P_WRK_ORDR_NO, P_WRK_ORDR_SEQNO, V_PRD_NO,
                                    V_UNIT, V_WIDTH, 1, P_PRFM_QTY, P_WGT, 0, 'N', 'N',
                                    TO_DATE(P_SDATE, 'YYYYMMDDHH24MISS'),
                                    TO_DATE(P_EDATE, 'YYYYMMDDHH24MISS'),
                                    TO_NUMBER(V_CYCLE_TIME), P_PRFM_DT, V_PRD_DT,
                                    '', V_WRK_CLASS, V_WRK_SHIFT, V_MACHINE, V_TOMACHINE, V_STCK_STA,
                                    V_DOC_NO, V_DOC_SEQNO, P_RMK, SYSDATE, P_USERID, V_RUN_STA, V_WRK_SEQ, 'Y',P_SALCODE,P_SALWEIGHT,'Y');

                UPDATE TB_WRK011
                   SET PRD_STR_DTM = P_SDATE
                       ,MACH_STA = 'R'
                 WHERE WERKS = P_WERKS
                   AND MACH_CD = P_MACH_CD
                   AND WRK_ORDR_NO = P_WRK_ORDR_NO
                   AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
                   ;

        ELSIF  V_REMAIN_QTY - (P_PRFM_QTY + P_SALWEIGHT) < 0 THEN
            BEGIN

                ROLLBACK;

                RS_CODE := 'E';
                RS_MSG  := '투입예정량 보다 현재 전체 투입량이 많습니다. 투입 가능한 량은 폐품량까지 포함하여' || V_REMAIN_QTY || 'KG 입니다.';
                RETURN;

            END;
        ELSIF  V_REMAIN_QTY = 0 THEN
            BEGIN

                ROLLBACK;

                RS_CODE := 'E';
                RS_MSG  := '잔량이 0 KG 입니다. 실적종료 버튼을 눌러 주세요.';
                RETURN;

            END;
        END IF;

        --재고 생성
--                V_STOR_LOC_CD := '2010';
--                V_LOC_CD := 'L2010';
--
--                V_SDATE := TO_CHAR(TO_DATE(P_SDATE, 'YYYYMMDDHH24MISS'), 'YYYY-MM-DD');
--                V_STIME := TO_CHAR(TO_DATE(P_SDATE, 'YYYYMMDDHH24MISS'), 'HH24:MI:SS');
--                V_EDATE := TO_CHAR(TO_DATE(P_EDATE, 'YYYYMMDDHH24MISS'), 'YYYY-MM-DD');
--                V_ETIME := TO_CHAR(TO_DATE(P_EDATE, 'YYYYMMDDHH24MISS'), 'HH24:MI:SS');
--
--                V_DOC_NO := FN_GET_MDOCNO('M','IF130'); 
--
--                V_DOC_NO_INPUT := V_DOC_NO_INPUT||V_DOC_NO||',' ;
--
--
--		V_DOC_NO_SCR := FN_GET_MDOCNO('M', 'IF134');
--		V_DOC_SEQNO_SCR := V_DOC_SEQNO_SCR + 1;
--
--        -- 개별바코드 전달
--        RS_IND_BCD := V_IND_BCD;
--
--        SELECT RFCFN
--          INTO RS_RFCFN
--          FROM TB_ITFMA
--         WHERE 1=1
--           AND IFID = V_IF_ID;

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
--        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);

        RS_CODE := 'E';
        RS_MSG  := SQLERRM;
        RETURN;
    --예외처리 종료
    END;
END;

/
