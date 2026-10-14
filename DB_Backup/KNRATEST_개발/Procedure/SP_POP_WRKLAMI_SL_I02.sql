--------------------------------------------------------
--  DDL for Procedure SP_POP_WRKLAMI_SL_I02
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRKLAMI_SL_I02" 
(
    P_WERKS     		IN VARCHAR2 	                --플랜트 --P100
    ,P_MACH_CD   		IN VARCHAR2 	                --설비코드 --PRD01
    ,P_ROLLCNT          IN NUMBER                       --권치수 --1
    ,P_WRK_ORDR_NO      IN VARCHAR2                     --작업지시번호 --HBLA202210110001
    ,P_WRK_ORDR_SEQNO   IN VARCHAR2                     --작업지시번호SEQ --1
--    ,P_WRK_SEQ          IN VARCHAR2 default null        --작업지시순번SEQ
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
    ,P_RMK              IN VARCHAR2                     --비고--TEST
    ,P_SALRMK           IN VARCHAR2                     --폐품비고
    ,P_WRK_CLASS        IN VARCHAR2                     --작업반 --1
    ,P_WRK_SHIFT        IN VARCHAR2                     --작업조 --A
    ,P_USERID           IN VARCHAR2                     --USER ID --TEST2
    ,P_PRFMMET_QTY        IN NUMBER                       --실중량미터 --50
    ,P_SALMETER           IN NUMBER                       --폐품미터 --10
    ,P_ROLL_QTY           IN NUMBER                       --폐품미터 --10
--    ,P_MATNR            IN VARCHAR2                       --선택된 자재 --10
--    ,P_MATNR_QTY        IN NUMBER                       --선택된 자재무게 --10
    ,RS_PRFM_RFCFN      OUT  VARCHAR2                      --실적 RFCFN값
    ,RS_DISPO_RFCFN      OUT  VARCHAR2                      --실적 RFCFN값
    ,RS_INPUT_RFCFN      OUT  VARCHAR2                      --실적 RFCFN값
    ,RS_IND_BCD   		OUT VARCHAR2                    --개별바코드
    ,RS_RFCFN           OUT VARCHAR2                    --RFCFN값
    ,Lang       		IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE     		OUT VARCHAR2 
    ,RS_MSG      		OUT VARCHAR2
    ,CUR_1            OUT SYS_REFCURSOR                 --실적
    ,CUR_2            OUT SYS_REFCURSOR         
    ,CUR_3            OUT SYS_REFCURSOR                 --폐품  
    ,CUR_4            OUT SYS_REFCURSOR         
    ,CUR_5            OUT SYS_REFCURSOR                 --투입량
    ,CUR_6            OUT SYS_REFCURSOR         
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
BEGIN

    BEGIN

    /*
        IF P_TM IS NULL  OR P_TM <= 0 THEN
            RS_CODE := 'E';
            RS_MSG := '작업시간을 등록 하십시오.';
            ROLLBACK;
            RETURN;
        END IF ;
    */
		V_CYCLE_TIME1 := TO_CHAR(ROUND((TO_DATE(P_EDATE, 'YYYYMMDDHH24MISS') - TO_DATE(P_SDATE, 'YYYYMMDDHH24MISS')) * 24 * 60,0));
        --실적등록 가능 월 검사                
        BEGIN
            SELECT YMCHK INTO  V_YMCHK
              FROM TB_MAS011
             WHERE WERKS = P_WERKS
               AND YMCHK = 'Y'
               AND YYMM  = SUBSTR(P_PRFM_DT, 1, 6);
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
        
--        IF P_MATNR_QTY <> V_REMAIN_QTY THEN
--            BEGIN
--                ROLLBACK;
--                RS_CODE := 'E';
--                RS_MSG  := '선택된 투입예정량과 생산오더 투입예정량은 서로 같아야 합니다. 선택된 투입예정량은 ' || TO_CHAR(P_MATNR_QTY) || ' 이고 생산오더 투입예정량은 ' || TO_CHAR(V_REMAIN_QTY) || ' 입니다.';
--                RETURN;
--            END;
--        END IF;
           
--       IF P_MATNR IS NOT NULL OR P_MATNR <> '' THEN
--           BEGIN
--
--                UPDATE TB_WRK011 
--                SET MATNR = P_MATNR
----                    ,ORDER_QTY = P_MATNR_QTY
----                    ,REMAIN_QTY = P_MATNR_QTY
--                WHERE MACH_CD = P_MACH_CD
--                AND WRK_ORDR_NO = P_WRK_ORDR_NO
--                AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
--                ;
--
--                UPDATE TB_LAMI_SL 
--                SET MATNR = P_MATNR
--                WHERE 1 = 1
--                AND WRK_ORDR_NO = P_WRK_ORDR_NO
--                AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
--                AND NVL(USE_YN,'Y') = 'Y'
--               ;
--               
--               V_MATNR := P_MATNR;
----               V_REMAIN_QTY := P_MATNR_QTY;
--
--           END;
--       END IF;

--        SELECT IND_BCD
--        INTO V_IND_BCD_M
--        FROM TB_INV010
--        WHERE 1 = 1
--        AND WERKS = P_WERKS
--        AND MACH_CD = P_MACH_CD
--        AND MATNR = V_MATNR
--        AND SEQNO = 1
--        AND ROWNUM = 1
--        ;

        SELECT TO_CHAR(SUM(NVL(ABN_TM,0)))
        INTO V_CYCLE_TIME2
        FROM TB_WRK003
        WHERE 1 = 1
        AND WERKS = P_WERKS
        AND WRK_ORDR_NO = P_WRK_ORDR_NO
        AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
        ;

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

--        IF NVL(P_MATNR, ' ' ) <> ' ' THEN
--            V_RUN_STA := '09';
--            V_MATNR := P_MATNR;
--        ELSE
--            V_RUN_STA := '01';
--        END IF;
          V_RUN_STA := '01';

        SELECT SAP_WRK_CD, MACHINE
            INTO V_SAP_WRK_CD, V_MACHINE
          FROM TB_MAS012
         WHERE MACH_CD = P_MACH_CD
         ;   

        --생산순번 조회
        BEGIN
            SELECT NVL(MAX(WRK_SEQ),0) INTO V_WRK_SEQ
              FROM TB_WRK002
             WHERE WERKS = P_WERKS
               AND MACH_CD = P_MACH_CD
               AND PRFM_DT = P_PRFM_DT
               AND WRK_ORDR_NO = P_WRK_ORDR_NO
               AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
               AND NVL(CNL_YN,'N') = 'N';
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                V_WRK_SEQ := 0;
        END;

        V_WRK_SEQ := NVL(V_WRK_SEQ, 0) + 1;

        V_PRD_NO := TO_CHAR(TO_DATE(P_PRFM_DT, 'YYYYMMDD'), 'YYYY-MM-DD') || '-' || V_MACHINE || '-' || TO_CHAR(V_WRK_SEQ);

        V_PRD_DT := TO_CHAR(V_REGDATE, 'YYYYMMDD');
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

                SELECT COUNT(IND_BCD)   
                INTO V_CNT3
                FROM TB_WRK008
                WHERE 1 = 1 
                AND WERKS = P_WERKS
                AND MACH_CD = P_MACH_CD
                AND IND_BCD = V_IND_BCD;


                SELECT COUNT(IND_BCD)
                INTO V_CNT4
                FROM TB_WRK022
                WHERE 1 = 1
                AND WERKS = P_WERKS
                AND MACH_CD = P_MACH_CD
                AND IND_BCD = V_IND_BCD;

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
            --SP_GET_BARCODE_SEQ('LOT', P_WERKS, 'J', V_MATNR, P_PRFM_DT, V_LOT_NO);
            IF V_LOT_NO_BUF IS NULL THEN
                BEGIN
                    SP_CHK_LOT_NO_LAMI(NVL(V_LOT_NO, ' '), P_WERKS, P_MACH_CD, V_MATNR, P_SDATE, V_LOT_NO);
                    V_ORDER_NO :=' ';
                    V_STCK_STA := '60';

                    SP_GET_DOC_SEQ('LS1', V_PRD_DT, V_WRK_ORDR_NO);
                    V_WRK_ORDR_SEQNO := 1;
                END;
            ELSIF V_LOT_NO_BUF IS NOT NULL THEN
                BEGIN
                    V_LOT_NO := V_LOT_NO_BUF;
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
                END;
            END IF;

        END IF;

    IF V_DLFL = 'N' THEN
        BEGIN
            UPDATE TB_LAMI_SL
               SET LOT_BUF = NVL(V_LOT_NO,V_LOT_NO_BUF)
                  ,IND_BCD = V_IND_BCD
                  ,PRFM_QTY = V_PRFM_QTY
                  ,CYCLE_TIME = V_CYCLE_TIME
                  ,SAPYN = 'N'
                  ,SALWEIGHT = V_SALWEIGHT
                  ,USE_YN = 'N'
                  ,COMP_YN = 'Y'
                  ,SALCODE = P_SALCODE
                  ,SALMETER = V_SALMETER
                  ,PRFMMET_QTY = V_PRFMMET_QTY
                  ,DOC_NO = V_DOC_NO
                  ,PRD_STR_DTM = V_SDATE
                  ,PRD_END_DTM = P_EDATE
                  ,PRD_END_DT = SUBSTR(P_EDATE,1,8)
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
        END;
    END IF;
    
		UPDATE TB_LAMI_SL
		   SET DLFL = 'N'
		 WHERE WRK_ORDR_NO = P_WRK_ORDR_NO  
		   AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
           AND WERKS = P_WERKS
           AND MACH_CD = P_MACH_CD
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

		UPDATE TB_INV003                -- 자재투입량 폐품 2
		   SET IND_BCD = V_IND_BCD
		 WHERE WERKS   = P_WERKS
		   AND MACH_CD = P_MACH_CD
		   AND WRK_ORDR_NO = P_WRK_ORDR_NO
		   AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
           ;

        --실적등록
/*
            MERGE INTO TB_WRK002 A
                USING DUAL
                ON (A.WRK_ORDR_NO = P_WRK_ORDR_NO AND A.WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO AND A.WERKS = P_WERKS AND DLFL = 'X')
                    WHEN MATCHED THEN
                        UPDATE SET 
                              USE_YN = 'Y'
                            , DLFL = 'N'
                    WHEN NOT MATCHED THEN
                        INSERT ( WERKS, MACH_CD, IND_BCD, LOT_NO, MATNR, 
                            ORDER_NO, WRK_ORDR_NO, WRK_ORDR_SEQNO, PRD_NO,
                            UNIT, WIDTH, ROLLCNT, PRFM_QTY, WGT, RSPEED, MER_YN, GRD_YN,
                            PRD_STR_DATE, PRD_END_DATE, TM, PRFM_DT, PRD_DT,
                            DSTBT_DDLIN, WRK_CLASS, WRK_SHIFT, MACHINE, TO_MACHINE, STA,
                            DOC_NO, DOC_SEQNO, RMK, REGDATE, REGID, RUN_STA, WRK_SEQ)
                    VALUES(P_WERKS, P_MACH_CD, V_IND_BCD, V_LOT_NO, V_MATNR,  
                            V_ORDER_NO, V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_PRD_NO,
                            V_UNIT, V_WIDTH, P_ROLLCNT, P_WGT, P_WGT, 0, 'N', 'N',
                            TO_DATE(P_SDATE, 'YYYYMMDDHH24MISS'),
                            TO_DATE(P_EDATE, 'YYYYMMDDHH24MISS'),
                            TO_NUMBER(V_CYCLE_TIME), P_PRFM_DT, V_PRD_DT,
                            '', V_WRK_CLASS, V_WRK_SHIFT, V_MACHINE, V_TOMACHINE, V_STCK_STA,
                            V_DOC_NO, V_DOC_SEQNO, P_RMK, V_REGDATE, P_USERID, V_RUN_STA, V_WRK_SEQ);
*/

        INSERT INTO TB_WRK002( WERKS, MACH_CD, IND_BCD, LOT_NO, MATNR, 
                            ORDER_NO, WRK_ORDR_NO, WRK_ORDR_SEQNO, PRD_NO,
                            UNIT, WIDTH, ROLLCNT, PRFM_QTY, WGT, RSPEED, MER_YN, GRD_YN,
                            PRD_STR_DATE, PRD_END_DATE, TM, PRFM_DT, PRD_DT,
                            DSTBT_DDLIN, WRK_CLASS, WRK_SHIFT, MACHINE, TO_MACHINE, STA,
                            DOC_NO, DOC_SEQNO, RMK, REGDATE, REGID, RUN_STA, WRK_SEQ)
                    VALUES(P_WERKS, P_MACH_CD, V_IND_BCD, V_LOT_NO, V_MATNR,  
                            V_ORDER_NO, P_WRK_ORDR_NO, TO_NUMBER(P_WRK_ORDR_SEQNO), V_PRD_NO,
                            V_UNIT, V_WIDTH, P_ROLLCNT, V_PRFM_QTY, V_PRFM_QTY + V_SALWEIGHT, 0, 'N', 'N',
                            TO_DATE(V_SDATE, 'YYYYMMDDHH24MISS'),
                            TO_DATE(P_EDATE, 'YYYYMMDDHH24MISS'),
                            TO_NUMBER(V_CYCLE_TIME), P_PRFM_DT, V_PRD_DT,
                            '', V_WRK_CLASS, V_WRK_SHIFT, V_MACHINE, V_TOMACHINE, V_STCK_STA,
                            V_DOC_NO, NVL(V_DOC_SEQNO,1), P_RMK, V_REGDATE, P_USERID, V_RUN_STA, V_WRK_SEQ);


        --재고 생성--(원래는 2010으로 하기로 했으나 권철상님의 요청으로 2810으로 변경)
        V_STOR_LOC_CD := '2810';
--        V_LOC_CD := 'L2100';
        V_LOC_CD := 'L2810'; --(창고이 경우 SAP에 따라 가야함 : 차 후에 변경)


--            MERGE INTO TB_INV001 A
--                USING DUAL
--                ON (A.WRK_ORDR_NO = P_WRK_ORDR_NO AND A.WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO AND A.WERKS = P_WERKS AND DLFL = 'D')
--                    WHEN MATCHED THEN
--                        UPDATE SET 
--                              DLFL = 'N'
--                    WHEN NOT MATCHED THEN
--                        INSERT ( WERKS, STOR_LOC_CD, IND_BCD, MATNR, LOC_CD, LOT_NO,
--                            MACH_CD, MACHINE, WRK_ORDR_NO, WRK_ORDR_SEQNO, ORDER_NO,
--                            PRD_NO, IN_MR_YN, PRD_DT, UNIT, STCK_QTY, ROLLCNT, WGT, STCK_STA,
--                            DOC_NO, DOC_SEQNO, DLFL, REGDATE, REGID)
--                    VALUES( P_WERKS, V_STOR_LOC_CD, V_IND_BCD, V_MATNR, V_LOC_CD, V_LOT_NO,
--                            P_MACH_CD, V_MACHINE, V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_ORDER_NO, 
--                            '', 'N', V_PRD_DT, V_UNIT, P_WGT, P_ROLLCNT, P_WGT, V_STCK_STA,
--                            V_DOC_NO, V_DOC_SEQNO, 'N', V_REGDATE, P_USERID);

        IF V_CNT1 > 0 THEN
            BEGIN
                INSERT INTO TB_INV001( WERKS, STOR_LOC_CD, IND_BCD, MATNR, LOC_CD, LOT_NO,
                                    MACH_CD, MACHINE, WRK_ORDR_NO, WRK_ORDR_SEQNO, ORDER_NO,
                                    PRD_NO, IN_MR_YN, PRD_DT, UNIT, STCK_QTY, ROLLCNT, WGT, STCK_STA,
                                    DOC_NO, DOC_SEQNO, DLFL, REGDATE, REGID)
                            SELECT P_WERKS, V_STOR_LOC_CD, IND_BCD, V_MATNR, V_LOC_CD, V_LOT_NO,
                                    P_MACH_CD, V_MACHINE, P_WRK_ORDR_NO, P_WRK_ORDR_SEQNO, V_ORDER_NO, 
                                    V_PRD_NO, 'N', V_PRD_DT, V_UNIT, PRFM_QTY , P_ROLLCNT, PRFM_QTY, V_STCK_STA,
                                    V_DOC_NO, NVL(V_DOC_SEQNO,1), 'N', V_REGDATE, P_USERID
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
                                    DOC_NO, DOC_SEQNO, DLFL, REGDATE, REGID)
                            VALUES( P_WERKS, V_STOR_LOC_CD, V_IND_BCD, V_MATNR, V_LOC_CD, V_LOT_NO,
                                    P_MACH_CD, V_MACHINE, P_WRK_ORDR_NO, P_WRK_ORDR_SEQNO, V_ORDER_NO, 
                                    V_PRD_NO, 'N', V_PRD_DT, V_UNIT, V_PRFM_QTY , P_ROLLCNT, V_PRFM_QTY, V_STCK_STA,
                                    V_DOC_NO, NVL(V_DOC_SEQNO,1), 'N', V_REGDATE, P_USERID);

            END;
        END IF;


--        INSERT INTO TB_INV001( WERKS, STOR_LOC_CD, IND_BCD, MATNR, LOC_CD, LOT_NO,
--                            MACH_CD, MACHINE, WRK_ORDR_NO, WRK_ORDR_SEQNO, ORDER_NO,
--                            PRD_NO, IN_MR_YN, PRD_DT, UNIT, STCK_QTY, ROLLCNT, WGT, STCK_STA,
--                            DOC_NO, DOC_SEQNO, DLFL, REGDATE, REGID)
--                    VALUES( P_WERKS, V_STOR_LOC_CD, V_IND_BCD, V_MATNR, V_LOC_CD, V_LOT_NO,
--                            P_MACH_CD, V_MACHINE, P_WRK_ORDR_NO, P_WRK_ORDR_SEQNO, V_ORDER_NO, 
--                            V_PRD_NO, 'N', V_PRD_DT, V_UNIT, V_PRFM_QTY , P_ROLLCNT, V_PRFM_QTY, V_STCK_STA,
--                            V_DOC_NO, NVL(V_DOC_SEQNO,1), 'N', V_REGDATE, P_USERID);

        V_STIME := TO_CHAR(TO_DATE(V_SDATE, 'YYYYMMDDHH24MISS'), 'HH24:MI:SS');
        V_SDATE := TO_CHAR(TO_DATE(V_SDATE, 'YYYYMMDDHH24MISS'), 'YYYY-MM-DD');
        V_ETIME := TO_CHAR(TO_DATE(P_EDATE, 'YYYYMMDDHH24MISS'), 'HH24:MI:SS');
        V_EDATE := TO_CHAR(TO_DATE(P_EDATE, 'YYYYMMDDHH24MISS'), 'YYYY-MM-DD');
		--V_PRD_NO := TO_CHAR(TO_DATE(V_PRFM_DT, 'YYYYMMDD'), 'YYYY-MM-DD') || '-' || V_MACHINE || '-' || TO_CHAR(V_WRK_SEQ);
        --SAP I/F
            INSERT INTO TB_LAMI_SL_IFS002(AUFNR,LOTNO,PRDCD,WERKS,WORKCENTERCODE,PRDDT,PRODT,MACHINE
            ,HMACHINE,WORKGROUP,PROQTY,MEINS,RUNTIME,OPNAM,CONF,SDATE,STIME,EDATE,ETIME
            ,MDOCNO,MDOCSEQ,MAKE_DATE,MAKER,HLOTNO1,HMATNR1,HMEINS1,INPQT1
            ,HLOTNO2,HMATNR2,HMEINS2,INPQT2,HLOTNO3,HMATNR3,HMEINS3,INPQT3,SEND_YN)
            VALUES(V_ORDER_NO, V_LOT_NO, V_MATNR, P_WERKS, V_SAP_WRK_CD, TO_CHAR(TO_DATE(P_PRFM_DT, 'YYYYMMDD'), 'YYYY-MM-DD'), V_SDATE, V_MACHINE
            ,NULL,NVL(V_WRK_CLASS, ' '), V_PRFM_QTY, V_UNIT, TO_CHAR(V_CYCLE_TIME), P_USERID, 'N', V_SDATE, V_STIME, V_EDATE, V_ETIME
            ,V_DOC_NO, TO_CHAR(V_DOC_SEQNO), SYSDATE, P_USERID, NULL, NULL, NULL, NULL         -- SAP 에 마지막생산 전송시 'Y'를 'X', 아닌경우는 빈값으로 전송
            , NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

--        INSERT INTO TB_LAMI_SL_IFS025( AUFNR, JRLOT, WERKS, WORKCENTERCODE, BUDAT, BUDAT_SAP, MACHINE,
--                            WORKGROUP, JVERID, JMATNR, JBRGEW, JGEWEI, JRUNTIME,
--                            CONF, JSDATE, JSTIME, JEDATE, JETIME, MDOCNO, MDOCSEQ,
--                            MAKE_DATE, MAKER, CGEWEW)
--                     VALUES(V_ORDER_NO, V_LOT_NO, P_WERKS, V_SAP_WRK_CD, TO_CHAR(TO_DATE(P_PRFM_DT, 'YYYYMMDD'), 'YYYY-MM-DD'), TO_CHAR(TO_DATE(P_PRFM_DT, 'YYYYMMDD'), 'YYYY-MM-DD'), P_MACH_CD,
--                            NVL(V_WRK_CLASS, ' '), V_MACHINE, V_MATNR, V_PRFM_QTY, V_UNIT, TO_CHAR(V_CYCLE_TIME),
--                            (CASE WHEN P_FINISH = 'Y' THEN 'X' ELSE '' END), V_SDATE, V_STIME, V_EDATE, V_ETIME, V_DOC_NO, TO_CHAR(V_DOC_SEQNO),         -- SAP 에 마지막생산 전송시 'Y'를 'X', 아닌경우는 빈값으로 전송
--                            V_REGDATE, P_USERID, V_PRFM_QTY + V_SALWEIGHT);

         --문서이력
         -- 1=실적, 2=생산폐품, 3=영업폐품, 4=잔량폐품, 5=투입자재 소요량, 6=재고이전(위치), 7=재고이전(자재변경), 8=재고이전(재고실사)
         -- 9=LOT변경, 10=등급변경, 11=LOT병합, 12=LIFT출고, 20=오더완료
        INSERT INTO TB_WRK021(DOC_NO, DOC_SEQNO, DOC_DIV, WERKS, MACH_CD, WRK_ORDR_NO, WRK_ORDR_SEQNO,
                            IND_BCD, LOT_NO, ORDER_NO, CNL_YN, REGDATE, REGID)
                    VALUES(V_DOC_NO, NVL(V_DOC_SEQNO,1), 1, P_WERKS, P_MACH_CD, P_WRK_ORDR_NO, P_WRK_ORDR_SEQNO,
                            V_IND_BCD, V_LOT_NO, V_ORDER_NO, 'N', V_REGDATE, P_USERID);           

        --[김병무:2022-07-19] 투입자재 추가 (점보롤의경우 투입자재가 없어서 투입자재 관련해서는 NULL로 입력)

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
                            '',
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

--                    V_DOC_NO := FN_GET_MDOCNO('M','IF130'); 

                    V_DOC_NO_INPUT := V_DOC_NO_INPUT||V_DOC_NO||',' ;

                    --자재 투입이력
                    INSERT INTO TB_INV010( WERKS, MACH_CD, MATNR, IND_BCD, SEQNO, WRK_ORDR_NO, WRK_ORDR_SEQNO,
                                        LOT_NO, IND_BCD_M, LOT_NO_M, MATNR_M, INP_DT, PRFM_DT,
                                        USE_QTY, UNIT, ROLLCNT, WGT, CHG_FLG, STCK_KY, LOT_NUM,
                                        REGDATE, REGID, USE_DIV, DOC_NO, DOC_SEQNO)
                                VALUES(P_WERKS, P_MACH_CD, V_MATNR, V_IND_BCD, 1, P_WRK_ORDR_NO, P_WRK_ORDR_SEQNO,
                                        V_LOT_NO, '', '', V_MATNR, V_PRD_DT, P_PRFM_DT,
                                        V_PRFM_QTY + V_SALWEIGHT, V_UNIT, P_ROLLCNT, V_PRFM_QTY + V_SALWEIGHT, 'N', '', '', 
                                        V_REGDATE, P_USERID, '1', V_DOC_NO, NVL(V_DOC_SEQNO,1));


		--폐품저장
		IF V_SALWEIGHT > 0 THEN
		BEGIN
            V_DOC_NO_SCR := FN_GET_MDOCNO('L', 'IF134');
            V_DOC_SEQNO_SCR := V_DOC_SEQNO_SCR + 1;
--                BEGIN                    
--                    SELECT DISPO_NM INTO V_DISPO_NM
--                      FROM TB_MAS023
--                     WHERE WERKS          = P_WERKS
--                       AND DISPO_CD    = P_SALCODE
--                       ;
--                EXCEPTION 
--                    WHEN NO_DATA_FOUND THEN
--                        V_ORDER_ITM_NO := ' ';
--                END;

			-- 폐품실적 등록(PS만 적용하기에 HL 주석처리)
/*			
			INSERT INTO TB_WRK004 (
				WERKS,
				MACH_CD,
				IND_BCD,
				LOT_NO,
				MATNR,
				DISPO_CD,
				WRK_ORDR_NO,
				WRK_ORDR_SEQNO,
				MMATNR,
				IND_BCD_M,
				LOT_NO_M,
				UNIT,
				DISPO_QTY,
				MACHINE,
				WGT,
				PRD_STR_DATE,
				PRD_END_DATE,
				TM,
				PRFM_DT,
				WRK_CLASS,
				WRK_SHIFT,
				RUN_STA,
				DOC_NO,
				DOC_SEQNO,
				RMK,
				REGDATE,
				REGID,
				CACOM_YN,
				MRCOM_YN,
				ORDER_NO
			) VALUES (
				P_WERKS,
				P_MACH_CD,
				V_IND_BCD_D1,
				V_LOT_NO,
				V_MATNR,
				V_DISPO_CD1,
				P_WRK_ORDR_NO,
				P_WRK_ORDR_SEQNO,
				V_MATNR_M,
				V_IND_BCD_M,
				V_LOT_NO_M,
				'EA',
				V_DISPO_QTY1 * 500,  -- 연수 * 500 => 갯수
				'',
				V_DISPO_WGT1,
				V_PRD_STR_DATE,
				V_PRD_END_DATE,
				'',
				V_PRFM_DT,
				P_WRK_CLASS,
				P_WRK_SHIFT,
				'02',
				V_DOC_NO_SCR,
				V_DOC_SEQNO_SCR,
				V_RMK,
				V_DATE,
				P_USERID,
				V_CACOM_YN,
				V_LAST_YN,
				V_ORDER_NO
			);
*/		
            IF V_CNT1 = 0 THEN
                BEGIN
                    INSERT INTO TB_WRK022 (
                        WERKS,
                        MACH_CD,
                        IND_BCD,
                        LOT_NO,
                        MATNR,
                        DISPO_CD,
                        WRK_ORDR_NO,
                        WRK_ORDR_SEQNO,
                        ORDER_NO,
                        MATNR_M,
                        IND_BCD_M,
                        LOT_NO_M,
                        ROLLCNT,
                        UNIT,
                        DISPO_QTY,
                        MACHINE,
                        WGT,
                        PRD_STR_DATE,
                        PRD_END_DATE,
                        TM,
                        PRFM_DT,
                        WRK_CLASS,
                        WRK_SHIFT,
                        RUN_STA,
                        DOC_NO,
                        DOC_SEQNO,
                        RMK,
                        REGDATE,
                        REGID
                    ) VALUES (
                        P_WERKS,
                        P_MACH_CD,
                        V_IND_BCD,
                        V_LOT_NO,
                        V_MATNR,
                        P_SALCODE,
                        P_WRK_ORDR_NO,
                        P_WRK_ORDR_SEQNO,
                        V_ORDER_NO,
                        V_MATNR,
                        '',
                        '',
                        0,
                        V_UNIT,
                        V_SALWEIGHT,
                        '',
                        V_PRFM_QTY + V_SALWEIGHT,
                        TO_DATE(P_SDATE,'YYYY-MM-DD HH24:MI:SS'),
                        TO_DATE(P_EDATE,'YYYY-MM-DD HH24:MI:SS'),
                        V_CYCLE_TIME,
                        P_PRFM_DT,
                        P_WRK_CLASS,
                        P_WRK_SHIFT,
                        '02',
                        V_DOC_NO_SCR,
                        NVL(V_DOC_SEQNO_SCR,1),
                        P_SALRMK,
                        V_REGDATE,
                        P_USERID
                    );

                    INSERT INTO TB_WRK021(DOC_NO, DOC_SEQNO, DOC_DIV, WERKS, MACH_CD, WRK_ORDR_NO, WRK_ORDR_SEQNO,
                                        IND_BCD, LOT_NO, ORDER_NO, CNL_YN, REGDATE, REGID)
                                VALUES(V_DOC_NO_SCR, NVL(V_DOC_SEQNO_SCR,1), 1, P_WERKS, P_MACH_CD, P_WRK_ORDR_NO, P_WRK_ORDR_SEQNO,
                                        V_IND_BCD, V_LOT_NO, V_ORDER_NO, 'N', V_REGDATE, P_USERID);           
                END;
            ELSIF V_CNT1 > 0 THEN
                BEGIN
                    INSERT INTO TB_WRK022 (
                        WERKS,
                        MACH_CD,
                        IND_BCD,
                        LOT_NO,
                        MATNR,
                        DISPO_CD,
                        WRK_ORDR_NO,
                        WRK_ORDR_SEQNO,
                        ORDER_NO,
                        MATNR_M,
                        IND_BCD_M,
                        LOT_NO_M,
                        ROLLCNT,
                        UNIT,
                        DISPO_QTY,
                        MACHINE,
                        WGT,
                        PRD_STR_DATE,
                        PRD_END_DATE,
                        TM,
                        PRFM_DT,
                        WRK_CLASS,
                        WRK_SHIFT,
                        RUN_STA,
                        DOC_NO,
                        DOC_SEQNO,
                        RMK,
                        REGDATE,
                        REGID
                    ) 
                    SELECT
                        P_WERKS,
                        P_MACH_CD,
                        IND_BCD,
                        V_LOT_NO,
                        V_MATNR,
                        SALCODE,
                        P_WRK_ORDR_NO,
                        P_WRK_ORDR_SEQNO,
                        V_ORDER_NO,
                        '',
                        '',
                        '',
                        0,
                        V_UNIT,
                        SALWEIGHT,
                        MACH_CD,
                        V_PRFM_QTY + V_SALWEIGHT,
                        PRD_STR_DATE,
                        PRD_END_DATE,
                        TM,
                        P_PRFM_DT,
                        P_WRK_CLASS,
                        P_WRK_SHIFT,
                        '02',
                        V_DOC_NO_SCR,
--                        NVL(V_DOC_SEQNO_SCR,1),
                        WRK_SEQ,
                        P_SALRMK,
                        V_REGDATE,
                        P_USERID
                        FROM (
                                SELECT
                                IND_BCD AS IND_BCD,
                                SALCODE AS SALCODE,
                                SALWEIGHT AS SALWEIGHT,
                                MACH_CD AS MACH_CD,
                                PRD_STR_DATE AS PRD_STR_DATE,
                                PRD_END_DATE AS PRD_END_DATE,
                                TM AS TM,
                                ROW_NUMBER() OVER (ORDER BY WRK_ORDR_NO) AS WRK_SEQ
                                FROM TB_LAMI_SL_RESULT
                                WHERE 1 = 1
                                AND WRK_ORDR_NO = P_WRK_ORDR_NO
                                AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
                                AND SALCODE IS NOT NULL
                                AND NVL(CNL_YN,'N') = 'N'
                            )
                    ;
                                INSERT INTO TB_WRK021(DOC_NO, DOC_SEQNO, DOC_DIV, WERKS, MACH_CD, WRK_ORDR_NO, WRK_ORDR_SEQNO,
                                        IND_BCD, LOT_NO, ORDER_NO, CNL_YN, REGDATE, REGID)
                                SELECT V_DOC_NO_SCR, WRK_SEQ, 1, P_WERKS, MACH_CD, P_WRK_ORDR_NO, P_WRK_ORDR_SEQNO,
                                        IND_BCD, V_LOT_NO, V_ORDER_NO, 'N', V_REGDATE, P_USERID
                                FROM (
                                        SELECT
                                        ROW_NUMBER() OVER (ORDER BY WRK_ORDR_NO) AS WRK_SEQ
                                        ,IND_BCD AS IND_BCD
                                        ,MACH_CD AS MACH_CD
                                        FROM TB_LAMI_SL_RESULT
                                        WHERE 1 = 1
                                        AND WRK_ORDR_NO = P_WRK_ORDR_NO
                                        AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
                                        AND SALCODE IS NOT NULL
                                        AND NVL(CNL_YN,'N') = 'N'
                                    );
                END;
            END IF;

			UPDATE TB_INV003                -- 자재투입량 폐품 2
			   SET DISPO_QTY = NVL(V_SALWEIGHT, 0),
				   USE_QTY   = NVL(V_PRFM_QTY, 0),
				   STCK_QTY  = NVL(STCK_QTY, 0)  - (NVL(V_SALWEIGHT,0) + NVL(V_PRFM_QTY,0))
			 WHERE WERKS   = P_WERKS
			   AND MACH_CD = P_MACH_CD
			   AND IND_BCD = V_IND_BCD;

                IF V_CNT1 = 0 THEN
                    BEGIN
                        INSERT INTO TB_IFS012 (
                            AUFNR,
                            LOTNO,
                            BUDAT,
                            MATNR,
                            SCRQTY,
                            RSDQTY,
                            MRSCQTY,
                            SCRAPCODE,
                            SCRAPREASON,
                            LGORT,
                            CHARG,
                            MDOCNO,
                            MDOCSEQ,
                            MAKE_DATE,
                            MAKER,
                            VBELN,
                            POSNR,
                            WORKCENTERCODE,
                            RUNTIME,
                            SCRQTY_OP,
                            SDATE,
                            STIME,
                            EDATE,
                            ETIME
                        ) VALUES (
                            V_ORDER_NO,
                            V_LOT_NO,
                            TO_CHAR(TO_DATE(P_PRFM_DT, 'YYYY-MM-DD'), 'YYYYMMDD'),
                            V_MATNR,
                            V_SALWEIGHT,
                            0,
                            0,
                            P_SALCODE,
                            P_SALRMK,
                            V_STOR_LOC_CD,
                            V_LOT_NO,
                            V_DOC_NO_SCR,
                            NVL(V_DOC_SEQNO_SCR,1),
                            TO_DATE(P_EDATE,'YYYY-MM-DD HH24:MI:SS'),
                            P_USERID,
                            '',
                            '',
                            V_SAP_WRK_CD,
                            V_CYCLE_TIME,
                            P_SALWEIGHT,
                            V_SDATE,
                            V_STIME,
                            V_EDATE,
                            V_ETIME
                        );
                    END;
                ELSIF V_CNT1 > 0 THEN
                    BEGIN
                        INSERT INTO TB_IFS012 (
                            AUFNR,
                            LOTNO,
                            BUDAT,
                            MATNR,
                            SCRQTY,
                            RSDQTY,
                            MRSCQTY,
                            SCRAPCODE,
                            SCRAPREASON,
                            LGORT,
                            CHARG,
                            MDOCNO,
                            MDOCSEQ,
                            MAKE_DATE,
                            MAKER,
                            VBELN,
                            POSNR,
                            WORKCENTERCODE,
                            RUNTIME,
                            SCRQTY_OP,
                            SDATE,
                            STIME,
                            EDATE,
                            ETIME
                        ) 
                                SELECT
                                    ORDER_NO,
                                    LOT_NO,
                                    PRFM_DT,
                                    MATNR,
                                    V_SALWEIGHT,
                                    0,
                                    0,
                                    SALCODE,
                                    RMK,
                                    V_STOR_LOC_CD,
                                    V_LOT_NO,
                                    V_DOC_NO_SCR,
                                    WRK_SEQ,
                                    PRD_END_DATE,
                                    REGID,
                                    '',
                                    '',
                                    V_SAP_WRK_CD,
                                    TM,
                                    SALWEIGHT,
                                    PRD_STR_DAY,
                                    PRD_STR_TM,
                                    PRD_END_DAY,
                                    PRD_END_TM
                                    FROM (
                                        SELECT
                                            ORDER_NO AS ORDER_NO,
                                            LOT_NO AS LOT_NO,
                                            TO_CHAR(TO_DATE(PRFM_DT, 'YYYY-MM-DD'), 'YYYYMMDD') AS PRFM_DT,
                                            V_MATNR AS MATNR,
                                            SALCODE AS SALCODE,
                                            RMK AS RMK,
                                            ROW_NUMBER() OVER (ORDER BY ORDER_NO) AS WRK_SEQ,
                                            PRD_END_DATE AS PRD_END_DATE,
                                            REGID AS REGID,
                                            TM AS TM,
                                            SALWEIGHT AS SALWEIGHT,
                                            TO_CHAR(PRD_STR_DATE,'YYYY-MM-DD') AS PRD_STR_DAY,
                                            TO_CHAR(PRD_STR_DATE,'HH24:MI:SS') AS PRD_STR_TM,
                                            TO_CHAR(PRD_END_DATE,'YYYY-MM-DD') AS PRD_END_DAY,
                                            TO_CHAR(PRD_END_DATE,'HH24:MI:SS') AS PRD_END_TM
                                            FROM TB_LAMI_SL_RESULT
                                            WHERE 1 = 1
                                            AND WRK_ORDR_NO = P_WRK_ORDR_NO
                                            AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
                                            AND SALCODE IS NOT NULL
                                            AND NVL(CNL_YN,'N') = 'N'
                                        )
                        ;
                    END;
                END IF;

		END;
		END IF;

        IF P_FINISH = 'Y' THEN
            UPDATE TB_LAMI_SL
                   SET COMP_YN = 'Y'
				   ,USE_YN = 'N'
             WHERE WRK_ORDR_NO = P_WRK_ORDR_NO
               AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
               --AND NVL(DLFL,'N') = 'N'  --삭제지시자 X='삭제' , N=정상오더
               AND NVL(USE_YN, 'Y') = 'Y'
               ;

            -- 점보롤 완료인경우 TB_WRK011(작업장(설비)별 현재 진행현황) 테이블 업데이트 진행
            -- 작업진행중인 작업지시번호 -> 이전작업지시번호, 작업지시순번 -> 이전작업지시순번으로 이동
            -- 자재번호, 작업지시번호, 작업지시순번 삭제
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


                INSERT INTO TB_IFS008(AUFNR, POSNR, BUDAT, MATNR, MENGE, LGORT, CHARG,
                                      MDOCNO, MDOCSEQ, MAKE_DATE, MAKER, WORKCENTERCODE, WERKS)
                            VALUES( V_ORDER_NO, V_ORDER_ITM_NO, V_PRFM_DT, V_MATNR, V_PRFM_QTY + V_SALWEIGHT, V_STOR_LOC_CD, V_LOT_NO,
                                    V_DOC_NO, V_DOC_SEQNO, SYSDATE, P_USERID, V_SAP_WRK_CD, P_WERKS);


        -- 개별바코드 전달
        RS_IND_BCD := V_IND_BCD;

        --SAP FUNC ID

        IF LENGTH(V_DOC_NO) > 0 THEN   --실적

             --SAP FUNC ID
--             SELECT RFCFN
--               INTO RS_PRFM_RFCFN
--               FROM TB_ITFMA
--              WHERE 1=1
--                AND IFID = 'MES_IF_127';   --생산오더별 재단 실적 

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

        IF LENGTH(V_DOC_NO_SCR) > 0 THEN   --폐품 ( MAX 2개까지 )

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
             V_SQL := FN_IF_QUERY('MES_IF_134', V_DOC_NO_SCR );
             OPEN CUR_4 FOR V_SQL;

        END IF ;  

        IF LENGTH(V_DOC_NO) > 0 THEN   --투입량

             --SAP FUNC ID
             SELECT RFCFN
               INTO RS_INPUT_RFCFN
               FROM TB_ITFMA
              WHERE 1=1
                AND IFID = 'MES_IF_130';   --생산오더별 실적 취소 TXN

             --인터페이스 파라미터
             OPEN CUR_5 FOR
             SELECT 'MES_IF_130' AS I_IF_ID
                  , 'M' || LTRIM(RTRIM(TO_CHAR(SEQ_GET_IFR_KEY.NEXTVAL, '00000000000000000000000000000'))) AS I_IF_KEY
               FROM dual;

             --인터페이스 상세 파라미터
             V_SQL := FN_IF_QUERY('MES_IF_130', V_DOC_NO);
             OPEN CUR_6 FOR V_SQL;

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

        IF CUR_5%ISOPEN = FALSE THEN
            OPEN CUR_5 FOR SELECT 1 FROM dual;
        END IF;

        IF CUR_6%ISOPEN = FALSE THEN
            OPEN CUR_6 FOR SELECT 1 FROM dual;
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
--        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);

        RS_CODE := 'E';
        RS_MSG  := SQLERRM;
        RETURN;
    --예외처리 종료
    END;
END;

/
