
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRKLAMI_SL_I02" SP_POP_WRKLAMI_SL_I02
(
    P_WERKS     		IN VARCHAR2 	                --플랜트 --P100
    ,P_MACH_CD   		IN VARCHAR2 	                --설비코드 --
    ,P_ROLLCNT          IN NUMBER                       --권치수 --1
    ,P_WRK_ORDR_NO      IN VARCHAR2                     --작업지시번호 --HBLA202210110001
    ,P_WRK_ORDR_SEQNO   IN VARCHAR2                     --작업지시번호SEQ --1
    ,P_LOT_NO           IN VARCHAR2                     --투입LOTNO
    ,P_WGT              IN NUMBER                       --총중량 --3500
    ,P_SDATE            IN VARCHAR2                     --작업시작시간(YYYYMMDDHHMMSS) : PRD_STR_DTM  --20221116162600
    ,P_EDATE            IN VARCHAR2                     --작업종료시간(YYYYMMDDHHMMSS) : PRD_END_DTM  --20221117162600
    ,P_PRFM_DT          IN VARCHAR2                     --생산실적일자(YYYYMMDD) : 20221117
    ,P_PRFM_QTY         IN NUMBER                     --실적중량 --3000
    ,P_SALCODE          IN VARCHAR2                     --폐품코드 --621
    ,P_SALWEIGHT        IN VARCHAR2                     --폐품중량 --500
    ,P_PPCODE           IN VARCHAR2                     --지종코드 --K11
    ,P_HEIGHT           IN VARCHAR2                     --길이 --10
    ,P_EQUIL            IN VARCHAR2                     --평형 --15
    ,P_STD              IN VARCHAR2                     --규격 --12
    ,P_FINISH           IN VARCHAR2                     --완료여부 --Y
    ,P_RMK              IN VARCHAR2                     --비고--TEST
    ,P_SALRMK           IN VARCHAR2                     --폐품비고
    ,P_WRK_CLASS        IN VARCHAR2                     --작업반 --1
    ,P_WRK_SHIFT        IN VARCHAR2                     --작업조 --A
    ,P_USERID           IN VARCHAR2                     --USER ID --TEST2
    ,P_PRFMMET_QTY        IN NUMBER                       --실중량미터 --50
    ,P_SALMETER           IN NUMBER                       --폐품미터 --10
    ,P_ROLL_QTY           IN NUMBER                       --폐품미터 --10
    ,RS_PRFM_RFCFN      OUT  VARCHAR2                      --실적 RFCFN값
    ,RS_INPUT_RFCFN      OUT  VARCHAR2                      --실적 RFCFN값
    ,RS_IND_BCD   		OUT VARCHAR2                    --개별바코드
    ,RS_RFCFN           OUT VARCHAR2                    --RFCFN값
    ,Lang       		IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE     		OUT VARCHAR2 
    ,RS_MSG      		OUT VARCHAR2
    ,CUR_1            OUT SYS_REFCURSOR                 --실적
    ,CUR_2            OUT SYS_REFCURSOR         
    ,CUR_3            OUT SYS_REFCURSOR                 --투입량  
    ,CUR_4            OUT SYS_REFCURSOR         
)
/*==============================================================================
 * PROGRAM ID    : WRK073
 * PROGRAM NAME  : 인쇄/코팅 작업완료
 * VERSION       : 1.0.0
 * DESCRIPTION   : 인쇄/코팅 작업완료를 하기 위한 SP.
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
 * - [TB_LAMI_SL] : (.R..) 슬리팅 작업지시
 *=============================================================================*/
AS 
    --프로그램 ID : 점보롤 실적등록
    V_PRG_NM        VARCHAR2(100)  := 'SP_POP_WRKLAMI_SL_I02';     -- PROCEDURE NAME
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
    V_SDATE                     VARCHAR2(20);
    V_STIME                     VARCHAR2(20);
    V_EDATE                     VARCHAR2(20);
    V_ETIME                     VARCHAR2(20);
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
    V_IND_BCD_M        		    TB_WRK002.IND_BCD%TYPE;			    --자재투입 개별바코드

    V_YMCHK                     TB_MAS011.YMCHK%TYPE;   --실적등록 가능 여부

    V_IF_ID                     VARCHAR2(20) := 'MES_IF_125'; --MES IF ID
    V_SQL                       VARCHAR2(4000);
    V_DOC_NO_INPUT              VARCHAR2(500) := '';

    V_LOT_NO_BUF                VARCHAR2(10);
    V_CYCLE_TIME                VARCHAR2(20);
    V_CYCLE_TIME1               VARCHAR2(20);
    V_CYCLE_TIME2               VARCHAR2(20);
    V_DOC_NO_SCR      			VARCHAR2(20);
    V_DOC_SEQNO_SCR     		NUMBER;
    V_DOC_NO_SCR2      			VARCHAR2(20);
    V_DOC_SEQNO_SCR2     		NUMBER;
    V_PRFM_DT      			    VARCHAR2(10);
    V_PRFM_QTY                  NUMBER;
    V_CNT1                      NUMBER;
    V_REMAIN_QTY         		NUMBER;
    V_SALWEIGHT         		NUMBER;
    V_SALMETER                  NUMBER;
    V_PRFMMET_QTY               NUMBER;
    V_ORDER_ITM_NO              VARCHAR2(20);
    V_DISPO_NM                  VARCHAR2(50);
    V_CNT2                      NUMBER;
    V_CNT3                      NUMBER;
    V_DLFL                      VARCHAR2(20);
    V_CNT4                      NUMBER;
    V_008_SUM                   NUMBER;
    V_008_MAT                   VARCHAR2(30);
    V_008_LOC                   VARCHAR2(20);
    V_PCODE                     VARCHAR2(100);
    V_BS_WGT                    VARCHAR2(100);
    V_WLEN                      VARCHAR2(100);
    V_VLEN                      VARCHAR2(100);
BEGIN

    BEGIN
		V_CYCLE_TIME1 := TO_CHAR(ROUND((TO_DATE(P_EDATE, 'YYYYMMDDHH24MISS') - TO_DATE(P_SDATE, 'YYYYMMDDHH24MISS')) * 24 * 60,0));
        --실적등록 가능 월 검사                
        
        V_PRFM_DT := FN_RECDATE(TO_DATE(P_EDATE, 'YYYYMMDDHH24MISS'));
        V_PRD_DT := TO_CHAR(TO_DATE(P_EDATE, 'YYYYMMDDHH24MISS'), 'YYYYMMDD');
        
        IF TO_NUMBER(NVL(P_SALWEIGHT,0)) > 0 THEN
            BEGIN
                ROLLBACK;
                RS_CODE := 'E';
                RS_MSG  := '슬리팅에서는 폐품을 저장할 수 없습니다 ';
                RETURN;
            
            END;
        END IF;
DBMS_OUTPUT.PUT_LINE( 'STEP 1');
        BEGIN
            SELECT YMCHK INTO  V_YMCHK
              FROM TB_MAS011
             WHERE WERKS = P_WERKS
               AND YMCHK = 'Y'
               AND YYMM  = SUBSTR(V_PRFM_DT, 1, 6);
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                V_YMCHK := 'N';
        END;

        IF V_YMCHK = 'N' THEN
            RS_CODE := 'E';
            RS_MSG := '실적등록 가능한 월이 아닙니다.';
            ROLLBACK;
            RETURN;
        END IF;
DBMS_OUTPUT.PUT_LINE( 'STEP 2');

        SELECT COUNT(*)
        INTO V_CNT1
        FROM TB_LAMI_SL_RESULT
        WHERE 1 = 1
        AND WRK_ORDR_NO = P_WRK_ORDR_NO
        AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
        AND WERKS = P_WERKS
        AND MACH_CD = P_MACH_CD
        AND NVL(CNL_YN,'N') = 'N'
        ;
DBMS_OUTPUT.PUT_LINE( 'STEP 3');

        IF V_CNT1 > 0 THEN
            BEGIN
                SELECT MIN(TO_CHAR(PRD_STR_DATE,'YYYYMMDDHH24MISS'))
                  INTO V_SDATE
                  FROM TB_LAMI_SL_RESULT
                 WHERE WRK_ORDR_NO = P_WRK_ORDR_NO
                   AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
                   AND WERKS = P_WERKS
                   AND MACH_CD = P_MACH_CD
                    AND NVL(CNL_YN,'N') = 'N'
--                   AND NVL(USE_YN,'Y') = 'Y'
                   ;
DBMS_OUTPUT.PUT_LINE( 'STEP 4');
                V_CYCLE_TIME1 := TO_CHAR(ROUND((TO_DATE(P_EDATE, 'YYYYMMDDHH24MISS') - TO_DATE(V_SDATE, 'YYYYMMDDHH24MISS')) * 24 * 60,0));
            END;
        ELSE
            BEGIN
                V_CYCLE_TIME1 := TO_CHAR(ROUND((TO_DATE(P_EDATE, 'YYYYMMDDHH24MISS') - TO_DATE(P_SDATE, 'YYYYMMDDHH24MISS')) * 24 * 60,0));
                V_SDATE := P_SDATE;
            END;
        END IF;

        SELECT WRK_ORDR_NO, WRK_ORDR_SEQNO, ORDER_NO, WRK_CLASS, WRK_SHIFT, LOT_NO, NVL(RUN_STA, '01') RUN_STA
            INTO V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_ORDER_NO, V_WRK_CLASS, V_WRK_SHIFT, V_LOT_NO, V_RUN_STA_PRE
          FROM TB_WRK011
        WHERE MACH_CD = P_MACH_CD
        AND WRK_ORDR_NO = P_WRK_ORDR_NO
        AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
        ; 
DBMS_OUTPUT.PUT_LINE( 'STEP 5');

        SELECT UNIT, TO_MACHINE, WLEN ,LOT_BUF, DOC_NO, IND_BCD, PRFM_QTY, MATNR, REMAIN_QTY, SALWEIGHT
        , CYCLE_TIME, SALMETER, PRFMMET_QTY, DLFL
          INTO V_UNIT, V_TOMACHINE, V_WIDTH,V_LOT_NO_BUF, V_DOC_NO, V_IND_BCD, V_PRFM_QTY, V_MATNR, V_REMAIN_QTY, V_SALWEIGHT
          , V_CYCLE_TIME2, V_SALMETER, V_PRFMMET_QTY, V_DLFL
          FROM TB_LAMI_SL
         WHERE WRK_ORDR_NO = P_WRK_ORDR_NO
           AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
           AND WERKS = P_WERKS
           AND MACH_CD = P_MACH_CD
           AND NVL(COMP_YN,'I') = 'I'
           AND NVL(USE_YN,'Y') = 'Y'
           ;
DBMS_OUTPUT.PUT_LINE( 'STEP 6');

        SELECT PCODE, TO_CHAR(BS_WGT), TO_CHAR(WLEN), TO_CHAR(VLEN)
        INTO V_PCODE, V_BS_WGT, V_WLEN, V_VLEN
        FROM TB_MAS001 
        WHERE 1 = 1 
        AND MATNR = V_MATNR
        ;
DBMS_OUTPUT.PUT_LINE( 'STEP 7');

--        SELECT TO_CHAR(SUM(NVL(ABN_TM,0)))		-- 20230703 백우종 수정
       SELECT TO_CHAR(NVL(SUM(ABN_TM), 0))
        INTO V_CYCLE_TIME2
        FROM TB_WRK003
        WHERE 1 = 1
        AND WERKS = P_WERKS
        AND WRK_ORDR_NO = P_WRK_ORDR_NO
        AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
        ;
DBMS_OUTPUT.PUT_LINE( 'STEP 8');

        V_IND_BCD_M := ' ';

        V_CYCLE_TIME := TO_CHAR(TO_NUMBER(V_CYCLE_TIME1) - TO_NUMBER(NVL(V_CYCLE_TIME2,0)));  
        V_PRFM_QTY := V_PRFM_QTY + P_PRFM_QTY;
        V_REMAIN_QTY := V_REMAIN_QTY - (P_PRFM_QTY + P_SALWEIGHT);
        V_SALWEIGHT := V_SALWEIGHT + P_SALWEIGHT;
        V_SALMETER := V_SALMETER + P_SALMETER;
        V_PRFMMET_QTY := V_PRFMMET_QTY + P_PRFMMET_QTY;


        IF P_WGT - (V_PRFM_QTY + V_SALWEIGHT) > 0 AND P_WGT > 0 THEN
            BEGIN
                ROLLBACK;
                RS_CODE := 'E';
                RS_MSG  := '잔량이 남아 있습니다. 잔량은' || TO_CHAR(P_WGT - (V_PRFM_QTY + V_SALWEIGHT)) || 'KG 입니다.';
                RETURN;

            END;
        ELSIF  P_WGT - (V_PRFM_QTY + V_SALWEIGHT) < 0 AND P_WGT > 0 THEN
            BEGIN
                ROLLBACK;
                RS_CODE := 'E';
                RS_MSG  := '투입예정량 보다 현재 전체 투입량이 많습니다. 투입 가능한 량은 폐품량까지 포함하여' || TO_CHAR(P_WGT - (P_PRFM_QTY + P_SALWEIGHT)) || 'KG 입니다.';
                RETURN;
            END;
        ELSIF  P_WGT - (V_PRFM_QTY + V_SALWEIGHT) = 0 AND V_CNT1 > 0 AND P_PRFM_QTY > 0 AND P_WGT > 0 THEN
            BEGIN
                ROLLBACK;
                RS_CODE := 'E';
                RS_MSG  := '슬리팅에서 분할 작업을 했을 때 마지막 분할 작업의 경우 슬리팅 분할 버튼을 누른 후 다시 작업지시를 선택하고 실적 종료 버튼을 눌러 주세요.';
                RETURN;

            END;
        END IF;

          V_RUN_STA := '01';
DBMS_OUTPUT.PUT_LINE( 'STEP 9');

        SELECT SAP_WRK_CD, MACHINE
            INTO V_SAP_WRK_CD, V_MACHINE
          FROM TB_MAS012
         WHERE MACH_CD = P_MACH_CD
         ;   
DBMS_OUTPUT.PUT_LINE( 'STEP 10');

        --생산순번 조회
        BEGIN
            SELECT NVL(MAX(WRK_SEQ),0) INTO V_WRK_SEQ
              FROM TB_WRK002
             WHERE WERKS = P_WERKS
               AND MACH_CD = P_MACH_CD
               AND PRFM_DT = V_PRFM_DT
               AND WRK_ORDR_NO = P_WRK_ORDR_NO
               AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
               AND NVL(CNL_YN,'N') = 'N';
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                V_WRK_SEQ := 0;
        END;
DBMS_OUTPUT.PUT_LINE( 'STEP 11');

        V_WRK_SEQ := NVL(V_WRK_SEQ, 0) + 1;

        V_PRD_NO := TO_CHAR(TO_DATE(V_PRFM_DT, 'YYYYMMDD'), 'YYYY-MM-DD') || '-' || V_MACHINE || '-' || TO_CHAR(V_WRK_SEQ);

--        V_PRD_DT := TO_CHAR(V_REGDATE, 'YYYYMMDD');
        --I/F 문서번호
        IF V_DOC_NO IS NULL THEN
            BEGIN
                V_DOC_NO := FN_GET_MDOCNO('L','IF974');
                V_DOC_SEQNO := 1;
            END;
        END IF;

        --개별바코드
        IF V_IND_BCD IS NULL THEN
            BEGIN
                SP_GET_BARCODE_SEQ_LAMI('IND', P_WERKS, P_MACH_CD, V_MATNR, P_SDATE, V_IND_BCD);
            END;
        END IF;

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
DBMS_OUTPUT.PUT_LINE( 'STEP 12');

                SELECT COUNT(IND_BCD)   
                INTO V_CNT3
                FROM TB_WRK008
                WHERE 1 = 1 
                AND WERKS = P_WERKS
                AND MACH_CD = P_MACH_CD
                AND IND_BCD = V_IND_BCD;
DBMS_OUTPUT.PUT_LINE( 'STEP 13');


                SELECT COUNT(IND_BCD)
                INTO V_CNT4
                FROM TB_WRK022
                WHERE 1 = 1
                AND WERKS = P_WERKS
                AND MACH_CD = P_MACH_CD
                AND IND_BCD = V_IND_BCD;
DBMS_OUTPUT.PUT_LINE( 'STEP 14');

                IF V_CNT2 = 0 AND V_CNT3 = 0 AND V_CNT4 = 0 THEN
                    EXIT;
                ELSE
                    SP_GET_BARCODE_SEQ_LAMI('IND', P_WERKS, P_MACH_CD, V_MATNR, P_SDATE, V_IND_BCD);
                END IF;
            END;
        END LOOP;

        V_DOC_SEQNO := 1;

        --LOT NO
        IF V_RUN_STA = '09' THEN
            IF V_LOT_NO_BUF IS NULL THEN
                BEGIN
                    SP_CHK_LOT_NO_LAMI(NVL(V_LOT_NO, ' '), P_WERKS, P_MACH_CD, V_MATNR, P_SDATE, V_LOT_NO);
                    V_ORDER_NO :=' ';
                    V_STCK_STA := '60';

                    SP_GET_DOC_SEQ('LS', V_PRD_DT, V_WRK_ORDR_NO);
                    V_WRK_ORDR_SEQNO := 1;
                END;
            ELSIF V_LOT_NO_BUF IS NOT NULL THEN
                BEGIN
                    V_LOT_NO := V_LOT_NO_BUF;
                    V_STCK_STA := '60';
                END;
            END IF;

        ELSE
            IF V_LOT_NO_BUF IS NULL THEN
                BEGIN
                    SP_CHK_LOT_NO_LAMI(NVL(V_LOT_NO_BUF, ' '), P_WERKS, P_MACH_CD, V_MATNR, P_SDATE, V_LOT_NO);
                    V_STCK_STA := '00';
                    V_LOT_NO_BUF := V_LOT_NO; 
                END;
            ELSIF V_LOT_NO_BUF IS NOT NULL THEN
                BEGIN
                    V_LOT_NO := V_LOT_NO_BUF;
                    V_STCK_STA := '00';
                END;
            END IF;

        END IF;

            UPDATE TB_LAMI_SL
               SET LOT_BUF = NVL(V_LOT_NO,V_LOT_NO_BUF)
                  ,IND_BCD = CASE WHEN V_CNT1 = 0 THEN V_IND_BCD ELSE NULL END
                  ,PRFM_QTY = V_PRFM_QTY
                  ,CYCLE_TIME = V_CYCLE_TIME
                  ,SAPYN = 'N'
                  ,SALWEIGHT = V_SALWEIGHT
                  ,PPCODE = V_PCODE
                  ,EQUIL = V_BS_WGT
--                  ,STD = V_WLEN || '*' || V_VLEN
                  ,USE_YN = 'N'
                  ,COMP_YN = 'Y'
                  ,SALCODE = P_SALCODE
                  ,SALMETER = V_SALMETER
                  ,PRFMMET_QTY = V_PRFMMET_QTY
                  ,DOC_NO = V_DOC_NO
                  ,PRD_STR_DTM = V_SDATE
                  ,PRD_END_DTM = P_EDATE
                  ,PRD_END_DT = V_PRFM_DT
                  ,REMAIN_QTY = V_REMAIN_QTY
                  ,ROLL_QTY = ROLL_QTY + P_ROLL_QTY
                  ,REGID = P_USERID
                  ,MATNR = V_MATNR
             WHERE WRK_ORDR_NO = P_WRK_ORDR_NO  
               AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
               AND WERKS = P_WERKS
               AND MACH_CD = P_MACH_CD
               AND NVL(COMP_YN,'I') = 'I'  
               AND NVL(USE_YN, 'Y') = 'Y'
               ;
    
		UPDATE TB_LAMI_SL
		   SET DLFL = 'N'
		 WHERE WRK_ORDR_NO = P_WRK_ORDR_NO  
		   AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
           AND WERKS = P_WERKS
           AND MACH_CD = P_MACH_CD
		   AND NVL(USE_YN, 'Y') = 'Y'
           ;

        --실적등록

--        INSERT INTO TB_WRK002( WERKS, MACH_CD, IND_BCD, LOT_NO, MATNR, 
--                            ORDER_NO, WRK_ORDR_NO, WRK_ORDR_SEQNO, PRD_NO,
--                            UNIT, WIDTH, ROLLCNT, PRFM_QTY, WGT, RSPEED, MER_YN, GRD_YN,
--                            PRD_STR_DATE, PRD_END_DATE, TM, PRFM_DT, PRD_DT,
--                            DSTBT_DDLIN, WRK_CLASS, WRK_SHIFT, MACHINE, TO_MACHINE, STA,
--                            DOC_NO, DOC_SEQNO, RMK, REGDATE, REGID, RUN_STA, WRK_SEQ)
--                    VALUES(P_WERKS, P_MACH_CD, V_IND_BCD, V_LOT_NO, V_MATNR,  
--                            V_ORDER_NO, P_WRK_ORDR_NO, TO_NUMBER(P_WRK_ORDR_SEQNO), V_PRD_NO,
--                            V_UNIT, V_WIDTH, P_ROLLCNT, V_PRFM_QTY, V_PRFM_QTY + V_SALWEIGHT, 0, 'N', 'N',
--                            TO_DATE(V_SDATE, 'YYYYMMDDHH24MISS'),
--                            TO_DATE(P_EDATE, 'YYYYMMDDHH24MISS'),
--                            TO_NUMBER(V_CYCLE_TIME), P_PRFM_DT, V_PRD_DT,
--                            '', V_WRK_CLASS, V_WRK_SHIFT, V_MACHINE, V_TOMACHINE, V_STCK_STA,
--                            V_DOC_NO, NVL(V_DOC_SEQNO,1), P_RMK, V_REGDATE, P_USERID, V_RUN_STA, V_WRK_SEQ);

        IF V_CNT1 = 0 THEN
            INSERT INTO TB_WRK002( WERKS, MACH_CD, IND_BCD, LOT_NO, MATNR, 
                                ORDER_NO, WRK_ORDR_NO, WRK_ORDR_SEQNO, PRD_NO,
                                UNIT, WIDTH, ROLLCNT, PRFM_QTY, WGT, RSPEED, MER_YN, GRD_YN,
                                PRD_STR_DATE, PRD_END_DATE, TM, PRFM_DT, PRD_DT,
                                DSTBT_DDLIN, WRK_CLASS, WRK_SHIFT, MACHINE, TO_MACHINE, STA,
                                DOC_NO, DOC_SEQNO, RMK, REGDATE, REGID, RUN_STA, WRK_SEQ, CNL_YN)
                VALUES(P_WERKS, P_MACH_CD, V_IND_BCD, V_LOT_NO, V_MATNR,  
                        V_ORDER_NO, P_WRK_ORDR_NO, TO_NUMBER(P_WRK_ORDR_SEQNO), V_PRD_NO,
                        V_UNIT, V_WIDTH, P_ROLLCNT, V_PRFM_QTY, V_PRFM_QTY + V_SALWEIGHT, 0, 'N', 'N',
                        TO_DATE(P_SDATE, 'YYYYMMDDHH24MISS'),
                        TO_DATE(P_EDATE, 'YYYYMMDDHH24MISS'),
                        TO_NUMBER(V_CYCLE_TIME), V_PRFM_DT, V_PRD_DT,
                        '', V_WRK_CLASS, V_WRK_SHIFT, V_MACHINE, V_TOMACHINE, V_STCK_STA,
                        V_DOC_NO, NVL(V_DOC_SEQNO,1), P_RMK, V_REGDATE, P_USERID, V_RUN_STA, V_WRK_SEQ, 'N');
                        
        ELSIF V_CNT1 > 0 THEN
            INSERT INTO TB_WRK002( WERKS, MACH_CD, IND_BCD, LOT_NO, MATNR, 
                                ORDER_NO, WRK_ORDR_NO, WRK_ORDR_SEQNO, PRD_NO,
                                UNIT, WIDTH, ROLLCNT, PRFM_QTY, WGT, RSPEED, MER_YN, GRD_YN,
                                PRD_STR_DATE, PRD_END_DATE, TM, PRFM_DT, PRD_DT,
                                DSTBT_DDLIN, WRK_CLASS, WRK_SHIFT, MACHINE, TO_MACHINE, STA,
                                DOC_NO, DOC_SEQNO, RMK, REGDATE, REGID, RUN_STA, WRK_SEQ, CNL_YN)
            SELECT WERKS, MACH_CD, IND_BCD, LOT_NO, MATNR,
                    ORDER_NO, WRK_ORDR_NO, WRK_ORDR_SEQNO, PRD_NO,
                    UNIT, WIDTH, ROLLCNT, PRFM_QTY, WGT, RSPEED, MER_YN, GRD_YN,
                    PRD_STR_DATE, PRD_END_DATE, TM, PRFM_DT, PRD_DT,
                    '', WRK_CLASS, WRK_SHIFT, MACHINE, TO_MACHINE, V_STCK_STA,
                    V_DOC_NO, NVL(V_DOC_SEQNO,1), RMK, REGDATE, REGID, RUN_STA, WRK_SEQ, 'N'            
            FROM TB_LAMI_SL_RESULT
            WHERE 1 = 1
    	    AND NVL(USE_YN, 'Y') = 'Y'
    	    AND NVL(CNL_YN, 'N') <> 'Y'
            AND WRK_ORDR_NO = P_WRK_ORDR_NO
            AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
            ;
        
        END IF;


        --재고 생성--(원래는 2010으로 하기로 했으나 권철상님의 요청으로 2810으로 변경)
        V_STOR_LOC_CD := '2810';
        V_LOC_CD := 'L2810'; --(창고이 경우 SAP에 따라 가야함 : 차 후에 변경)

        IF V_CNT1 > 0 THEN
            BEGIN
                INSERT INTO TB_INV001( WERKS, STOR_LOC_CD, IND_BCD, MATNR, LOC_CD, LOT_NO,
                                    MACH_CD, MACHINE, WRK_ORDR_NO, WRK_ORDR_SEQNO, ORDER_NO,
                                    PRD_NO, IN_MR_YN, PRD_DT, UNIT, STCK_QTY, ROLLCNT, WGT, STCK_STA,
                                    DOC_NO, DOC_SEQNO, DLFL, REGDATE, REGID, PRFM_DT)
                            SELECT P_WERKS, V_STOR_LOC_CD, IND_BCD, V_MATNR, V_LOC_CD, V_LOT_NO,
                                    P_MACH_CD, V_MACHINE, P_WRK_ORDR_NO, P_WRK_ORDR_SEQNO, V_ORDER_NO, 
                                    V_PRD_NO, 'N', V_PRD_DT, V_UNIT, PRFM_QTY , P_ROLLCNT, PRFM_QTY, V_STCK_STA,
                                    V_DOC_NO, NVL(V_DOC_SEQNO,1), 'N', V_REGDATE, P_USERID, PRFM_DT
                            FROM TB_LAMI_SL_RESULT
                            WHERE 1 = 1
                            AND WRK_ORDR_NO = P_WRK_ORDR_NO
                            AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
                            ;
            END;
        ELSIF V_CNT1 = 0 THEN
            BEGIN
                INSERT INTO TB_INV001( WERKS, STOR_LOC_CD, IND_BCD, MATNR, LOC_CD, LOT_NO,
                                    MACH_CD, MACHINE, WRK_ORDR_NO, WRK_ORDR_SEQNO, ORDER_NO,
                                    PRD_NO, IN_MR_YN, PRD_DT, UNIT, STCK_QTY, ROLLCNT, WGT, STCK_STA,
                                    DOC_NO, DOC_SEQNO, DLFL, REGDATE, REGID, PRFM_DT)
                            VALUES( P_WERKS, V_STOR_LOC_CD, V_IND_BCD, V_MATNR, V_LOC_CD, V_LOT_NO,
                                    P_MACH_CD, V_MACHINE, P_WRK_ORDR_NO, P_WRK_ORDR_SEQNO, V_ORDER_NO, 
                                    V_PRD_NO, 'N', V_PRD_DT, V_UNIT, V_PRFM_QTY , P_ROLLCNT, V_PRFM_QTY, V_STCK_STA,
                                    V_DOC_NO, NVL(V_DOC_SEQNO,1), 'N', V_REGDATE, P_USERID, V_PRFM_DT);

            END;
        END IF;

        V_STIME := TO_CHAR(TO_DATE(V_SDATE, 'YYYYMMDDHH24MISS'), 'HH24:MI:SS');
        V_SDATE := TO_CHAR(TO_DATE(V_SDATE, 'YYYYMMDDHH24MISS'), 'YYYY-MM-DD');
        V_ETIME := TO_CHAR(TO_DATE(P_EDATE, 'YYYYMMDDHH24MISS'), 'HH24:MI:SS');
        V_EDATE := TO_CHAR(TO_DATE(P_EDATE, 'YYYYMMDDHH24MISS'), 'YYYY-MM-DD');
        --SAP I/F
            INSERT INTO TB_LAMI_SL_IFS002(AUFNR,LOTNO,PRDCD,WERKS,WORKCENTERCODE,PRDDT,PRODT,MACHINE
            ,HMACHINE,WORKGROUP,PROQTY,MEINS,RUNTIME,OPNAM,CONF,SDATE,STIME,EDATE,ETIME
            ,MDOCNO,MDOCSEQ,MAKE_DATE,MAKER,HLOTNO1,HMATNR1,HMEINS1,INPQT1
            ,HLOTNO2,HMATNR2,HMEINS2,INPQT2,HLOTNO3,HMATNR3,HMEINS3,INPQT3,SEND_YN)
            VALUES(V_ORDER_NO, V_LOT_NO, V_MATNR, P_WERKS, V_SAP_WRK_CD, TO_CHAR(TO_DATE(V_PRFM_DT, 'YYYYMMDD'), 'YYYY-MM-DD'), V_SDATE, V_MACHINE
            ,NULL,NVL(V_WRK_CLASS, ' '), V_PRFM_QTY, V_UNIT, TO_CHAR(V_CYCLE_TIME), P_USERID, 'N', V_SDATE, V_STIME, V_EDATE, V_ETIME
            ,V_DOC_NO, TO_CHAR(V_DOC_SEQNO), SYSDATE, P_USERID, NULL, NULL, NULL, 0         -- SAP 에 마지막생산 전송시 'Y'를 'X', 아닌경우는 빈값으로 전송
            , NULL, NULL, NULL, 0, NULL, NULL, NULL, 0, NULL);

         --문서이력
        INSERT INTO TB_WRK021(DOC_NO, DOC_SEQNO, DOC_DIV, WERKS, MACH_CD, WRK_ORDR_NO, WRK_ORDR_SEQNO,
                            IND_BCD, LOT_NO, ORDER_NO, CNL_YN, REGDATE, REGID)
                    VALUES(V_DOC_NO, NVL(V_DOC_SEQNO,1), 1, P_WERKS, P_MACH_CD, P_WRK_ORDR_NO, P_WRK_ORDR_SEQNO,
                            V_IND_BCD, V_LOT_NO, V_ORDER_NO, 'N', V_REGDATE, P_USERID);           

        INSERT INTO TB_WRK008(WERKS,
                            IND_BCD,
                            IND_BCD_M,
                            SEQNO,
                            LOT_NO,
                            MATNR,
                            LOT_NO_M,
                            MATNR_M,
                            UNIT,
                            PRFM_QTY,
                            USE_QTY,
                            WRK_ORDR_NO,
                            WRK_ORDR_SEQNO,
                            SUB_WRK_ORDR_NO,
                            SUB_WRK_ORDR_SEQNO,
                            MACH_CD,
                            REGDATE,
                            REGID)
                   VALUES(P_WERKS,
                            V_IND_BCD,
                            '*',
                            1,
                            V_LOT_NO,
                            V_MATNR,
                            '',
                            V_MATNR,
                            V_UNIT,
                            V_PRFM_QTY,
                            V_PRFM_QTY + V_SALWEIGHT,
                            P_WRK_ORDR_NO,
                            P_WRK_ORDR_SEQNO,
                            '',
                            '',
                            P_MACH_CD,
                            V_REGDATE,
                            P_USERID);                            

                    V_DOC_NO_INPUT := V_DOC_NO_INPUT||V_DOC_NO||',' ;

                    --자재 투입이력
--                    INSERT INTO TB_INV010( WERKS, MACH_CD, MATNR, IND_BCD, SEQNO, WRK_ORDR_NO, WRK_ORDR_SEQNO,
--                                        LOT_NO, IND_BCD_M, LOT_NO_M, MATNR_M, INP_DT, PRFM_DT,
--                                        USE_QTY, UNIT, ROLLCNT, WGT, CHG_FLG, STCK_KY, LOT_NUM,
--                                        REGDATE, REGID, USE_DIV, DOC_NO, DOC_SEQNO)
--                                VALUES(P_WERKS, P_MACH_CD, V_MATNR, V_IND_BCD, 1, P_WRK_ORDR_NO, P_WRK_ORDR_SEQNO,
--                                        V_LOT_NO, '', '', V_MATNR, V_PRD_DT, P_PRFM_DT,
--                                        V_PRFM_QTY + V_SALWEIGHT, V_UNIT, P_ROLLCNT, V_PRFM_QTY + V_SALWEIGHT, 'N', '', '', 
--                                        V_REGDATE, P_USERID, '1', V_DOC_NO, NVL(V_DOC_SEQNO,1));

                    IF V_CNT1 = 0 THEN
                        INSERT INTO TB_INV010( WERKS, MACH_CD, MATNR, IND_BCD, SEQNO, WRK_ORDR_NO, WRK_ORDR_SEQNO,
                                            LOT_NO, IND_BCD_M, LOT_NO_M, MATNR_M, INP_DT, PRFM_DT,
                                            USE_QTY, UNIT, ROLLCNT, WGT, CHG_FLG, STCK_KY, LOT_NUM,
                                            REGDATE, REGID, USE_DIV, DOC_NO, DOC_SEQNO)
                        SELECT WERKS, P_MACH_CD, V_MATNR, V_IND_BCD, 1, WRK_ORDR_NO, WRK_ORDR_SEQNO
                              ,V_LOT_NO , IND_BCD, LOT_NO, MATNR, INP_DT, V_PRFM_DT
                              ,IN_QTY, UNIT, ROLLCNT, WGT, CHG_FLG, STCK_KY, LOT_NUM
                              ,REGDATE, REGID, 1, V_DOC_NO, V_DOC_SEQNO          
                        FROM TB_INV003
                        WHERE 1 = 1
                        AND WRK_ORDR_NO = P_WRK_ORDR_NO
                        AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
                        ;
                    ELSIF V_CNT1 > 0 THEN
                        INSERT INTO TB_INV010( WERKS, MACH_CD, MATNR, IND_BCD, SEQNO, WRK_ORDR_NO, WRK_ORDR_SEQNO,
                                            LOT_NO, IND_BCD_M, LOT_NO_M, MATNR_M, INP_DT, PRFM_DT,
                                            USE_QTY, UNIT, ROLLCNT, WGT, CHG_FLG, STCK_KY, LOT_NUM,
                                            REGDATE, REGID, USE_DIV, DOC_NO, DOC_SEQNO)
                        SELECT A.WERKS, B.MACH_CD, B.MATNR, B.IND_BCD, 1, A.WRK_ORDR_NO, A.WRK_ORDR_SEQNO
                              ,B.LOT_NO , A.IND_BCD, A.LOT_NO, A.MATNR, A.INP_DT, V_PRFM_DT
                              ,A.IN_QTY, A.UNIT, A.ROLLCNT, A.WGT, A.CHG_FLG, A.STCK_KY, A.LOT_NUM
                              ,A.REGDATE, A.REGID, 1, B.DOC_NO, B.DOC_SEQNO          
                        FROM TB_INV003 A
                        INNER JOIN TB_LAMI_SL_RESULT B ON A.WRK_ORDR_NO = B.WRK_ORDR_NO 
                        AND A.WRK_ORDR_SEQNO = B.WRK_ORDR_SEQNO AND B.CNL_YN = 'N' AND ROWNUM = 1
                        WHERE 1 = 1
                        AND A.WRK_ORDR_NO = P_WRK_ORDR_NO
                        AND A.WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
                        AND NVL(USE_YN, 'Y') = 'Y'
                        ;
                    END IF;


		--폐품저장

        UPDATE TB_INV003                -- 자재투입량 폐품 2
           SET DISPO_QTY = 0,
               USE_QTY   = NVL(STCK_QTY, 0),
               STCK_QTY  = 0
         WHERE WERKS   = P_WERKS
           AND MACH_CD = P_MACH_CD
           AND WRK_ORDR_NO = P_WRK_ORDR_NO
           AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
           ;

        IF P_FINISH = 'Y' THEN
        
            V_DOC_NO_SCR2 := FN_GET_MDOCNO('L', 'IF130');
            V_DOC_SEQNO_SCR2 := 1;

            UPDATE TB_LAMI_SL
                   SET COMP_YN = 'Y'
				   ,USE_YN = 'N'
             WHERE WRK_ORDR_NO = P_WRK_ORDR_NO
               AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
               --AND NVL(DLFL,'N') = 'N'  --삭제지시자 X='삭제' , N=정상오더
               AND NVL(USE_YN, 'Y') = 'Y'
               ;

            UPDATE TB_LAMI_SL_RESULT
               SET USE_YN = 'N'
                  ,LOT_NO = V_LOT_NO
             WHERE WRK_ORDR_NO = P_WRK_ORDR_NO  
               AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
               --AND NVL(DLFL,'N') = 'N'  --삭제지시자 X='삭제' , N=정상오더
               AND NVL(USE_YN, 'Y') = 'Y'
               AND NVL(CNL_YN,'N') = 'N'
               ;

            UPDATE TB_WRK011
                SET PRE_WRK_ORDR_NO = P_WRK_ORDR_NO,
                    PRE_WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO,
                    MATNR = '',
                    WRK_ORDR_NO = '', 
                    WRK_ORDR_SEQNO = '',
                    ORDER_NO = '',
                    LOT_NO = '',
                    PRD_STR_DTM = P_EDATE,
                    MACH_STA = 'N',
                    RUN_STA = V_RUN_STA
            WHERE MACH_CD = P_MACH_CD; 
        ELSE
            UPDATE TB_WRK011
                SET PRD_STR_DTM = P_EDATE,
                    LOT_NO = V_LOT_NO,  
                    RUN_STA = V_RUN_STA
            WHERE MACH_CD = P_MACH_CD; 
            END IF;
DBMS_OUTPUT.PUT_LINE( 'STEP 15');
            
            BEGIN                    
                SELECT ORDER_ITM_NO INTO V_ORDER_ITM_NO
                  FROM TB_SCH020
                 WHERE WERKS          = P_WERKS
                   AND WRK_ORDR_NO    = P_WRK_ORDR_NO
                   AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
                   AND NVL(DLFL,'N') = 'N'  --삭제지시자 X='삭제' , N=정상오더
                   
                   ;
            EXCEPTION 
                WHEN NO_DATA_FOUND THEN
                    V_ORDER_ITM_NO := ' ';
            END;
DBMS_OUTPUT.PUT_LINE( 'STEP 16');
            
            SELECT SUM(USE_QTY),MATNR 
            INTO V_008_SUM, V_008_MAT
            FROM TB_INV003
            WHERE 1 = 1
            AND WRK_ORDR_NO = P_WRK_ORDR_NO
            AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
            GROUP BY MATNR
            ;
DBMS_OUTPUT.PUT_LINE( 'STEP 17');
            
            SELECT STOR_LOC_CD
            INTO V_008_LOC
            FROM TB_SCH020
            WHERE 1 = 1
            AND NVL(LOT_NO, ' ') = NVL(P_LOT_NO, ' ')
--            AND LOT_NO = P_LOT_NO
            AND WRK_ORDR_NO = P_WRK_ORDR_NO
            AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
            GROUP BY STOR_LOC_CD
            ;
DBMS_OUTPUT.PUT_LINE( 'STEP 18');

                INSERT INTO TB_IFS008(AUFNR, POSNR, BUDAT, MATNR, MENGE, LGORT, CHARG,
                                      MDOCNO, MDOCSEQ, MAKE_DATE, MAKER, WORKCENTERCODE, WERKS)
                            VALUES( V_ORDER_NO, V_ORDER_ITM_NO, TO_CHAR(TO_DATE(P_EDATE, 'YYYYMMDDHH24MISS'), 'YYYYMMDD'), V_008_MAT, V_008_SUM, V_008_LOC, P_LOT_NO,
                                    V_DOC_NO_SCR2, V_DOC_SEQNO_SCR2, SYSDATE, P_USERID, V_SAP_WRK_CD, P_WERKS);

        -- 개별바코드 전달
        RS_IND_BCD := V_IND_BCD;

        --SAP FUNC ID

        IF LENGTH(V_DOC_NO) > 0 THEN   --실적

            RS_PRFM_RFCFN := 'Z_MES_LAMI2_CONF'; --라미네이팅 슬리팅 RFC FUNCTION으로 변경해야 함

             --인터페이스 파라미터
             OPEN CUR_1 FOR
             SELECT 'MES_IF_974' AS I_IF_ID
                  , 'M' || LTRIM(RTRIM(TO_CHAR(SEQ_GET_IFR_KEY.NEXTVAL, '00000000000000000000000000000'))) AS I_IF_KEY
               FROM dual;

             --인터페이스 상세 파라미터
             V_SQL := FN_IF_QUERY('MES_IF_974', V_DOC_NO);
             OPEN CUR_2 FOR V_SQL;

        END IF ;

        IF LENGTH(V_DOC_NO_SCR2) > 0 THEN   --투입량

             --SAP FUNC ID
             SELECT RFCFN
               INTO RS_INPUT_RFCFN
               FROM TB_ITFMA
              WHERE 1=1
                AND IFID = 'MES_IF_130';   --생산오더별 실적 취소 TXN
DBMS_OUTPUT.PUT_LINE( 'STEP 19');

             --인터페이스 파라미터
             OPEN CUR_3 FOR
             SELECT 'MES_IF_130' AS I_IF_ID
                  , 'M' || LTRIM(RTRIM(TO_CHAR(SEQ_GET_IFR_KEY.NEXTVAL, '00000000000000000000000000000'))) AS I_IF_KEY
               FROM dual;

             --인터페이스 상세 파라미터
             V_SQL := FN_IF_QUERY('MES_IF_130', V_DOC_NO_SCR2);
             OPEN CUR_4 FOR V_SQL;

        END IF ;  

        IF CUR_1%ISOPEN = FALSE THEN
            OPEN CUR_1 FOR SELECT 1 FROM dual;
        END IF;

        IF CUR_2%ISOPEN = FALSE THEN
            OPEN CUR_2 FOR SELECT 1 FROM dual;
        END IF;

        IF CUR_3%ISOPEN = FALSE THEN
            OPEN CUR_3 FOR SELECT 1 FROM dual;
        END IF;

        IF CUR_4%ISOPEN = FALSE THEN
            OPEN CUR_4 FOR SELECT 1 FROM dual;
        END IF;

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

        RS_CODE := 'E';
        RS_MSG  := SQLERRM;
        RETURN;
    --예외처리 종료
    END;
END;
/
