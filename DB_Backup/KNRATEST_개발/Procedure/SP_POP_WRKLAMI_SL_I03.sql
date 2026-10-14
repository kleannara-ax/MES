--------------------------------------------------------
--  DDL for Procedure SP_POP_WRKLAMI_SL_I03
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRKLAMI_SL_I03" 
(
    P_WERKS     		IN VARCHAR2 	                --플랜트
    ,P_MACH_CD   		IN VARCHAR2 	                --설비코드
    ,P_ROLLCNT          IN NUMBER                       --권치수
    ,P_WRK_ORDR_NO      IN VARCHAR2                     --작업지시번호
    ,P_WRK_ORDR_SEQNO   IN VARCHAR2                     --작업지시번호SEQ
    ,P_WRK_SEQ          IN VARCHAR2                     --작업지시순번SEQ
    ,P_WGT              IN NUMBER                       --중량
--    ,P_RSPEED           IN NUMBER                       --선속
    ,P_SDATE            IN VARCHAR2                     --작업시작시간(YYYYMMDDHHMMSS) : PRD_STR_DTM
    ,P_EDATE            IN VARCHAR2                     --작업종료시간(YYYYMMDDHHMMSS) : PRD_END_DTM
--    ,P_TM               IN NUMBER                       --작업시간
    ,P_PRFM_DT          IN NUMBER                     --생산실적일자(YYYYMMDD)
--    ,P_WRK_ORDR_QTY     IN VARCHAR2                 --총중량
    ,P_PRFM_QTY         IN VARCHAR2                   --실적중량
    ,P_SALCODE          IN VARCHAR2                    --폐품코드
    ,P_SALWEIGHT        IN VARCHAR2                     --폐품중량
    ,P_PPCODE           IN VARCHAR2                     --지종코드
    ,P_HEIGHT           IN VARCHAR2                     --길이
    ,P_EQUIL            IN VARCHAR2                     --평형
    ,P_STD              IN VARCHAR2                     --규격
    ,P_FINISH           IN VARCHAR2                     --완료여부
--    ,P_MATNR            IN VARCHAR2                     --비계획 자재코드
    ,P_RMK              IN VARCHAR2                     --비고
    ,P_SALRMK           IN VARCHAR2                     --폐품비고
    ,P_WRK_CLASS        IN VARCHAR2                     --작업반
    ,P_WRK_SHIFT        IN VARCHAR2                     --작업조
    ,P_USERID           IN VARCHAR2                     --USER ID
--    ,P_DOC_NO           IN VARCHAR2                     --문서번호
    ,P_PRFMMET_QTY      IN NUMBER                     --미터
    ,P_SALMETER      IN NUMBER                     --폐품미터
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
 * DESCRIPTION   : 인쇄/코팅 작업완료를 하지않고 이동한 것에 대해 슬리팅 작업.
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
 * - [TB_LAMI_SL] : (.R..) 인쇄/코팅 작업지시
 *=============================================================================*/
AS 
    --프로그램 ID : 점보롤 실적등록
    V_PRG_NM        VARCHAR2(100)  := 'SP_POP_WRKLAMI_SL_I03';     -- PROCEDURE NAME
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
    V_CNT1                       NUMBER(13,0);
BEGIN

    BEGIN

		V_CYCLE_TIME := TO_CHAR(ROUND((TO_DATE(P_EDATE, 'YYYYMMDDHH24MISS') - TO_DATE(P_SDATE, 'YYYYMMDDHH24MISS')) * 24 * 60,0));

        SELECT MATNR, WRK_CLASS, WRK_SHIFT, LOT_NO, NVL(RUN_STA, '01') RUN_STA,WRK_ORDR_SEQNO
            INTO V_MATNR, V_WRK_CLASS, V_WRK_SHIFT, V_LOT_NO, V_RUN_STA, V_WRK_ORDR_SEQNO
          FROM TB_LAMI_PC_RESULT
        WHERE MACH_CD = 'PRD01'
           AND WRK_ORDR_NO = P_WRK_ORDR_NO
           AND WRK_SEQ = P_WRK_ORDR_SEQNO
           AND NVL(USE_YN,'Y') = 'Y'
           AND NVL(SL_MOVE_YN,'Y') = 'Y'
        ; 

        SELECT ORDER_NO, UNIT, TO_MACHINE, EQUIL ,LOT_BUF, DOC_NO, IND_BCD, REMAIN_QTY
          INTO V_ORDER_NO, V_UNIT, V_TOMACHINE, V_WIDTH,V_LOT_NO_BUF, V_DOC_NO, V_IND_BCD, V_REMAIN_QTY
          FROM TB_LAMI_PC
         WHERE 1 = 1
           AND WRK_ORDR_NO = P_WRK_ORDR_NO
           AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
           AND NVL(USE_YN,'Y') = 'Y';

           V_MACHINE := 'PRD01';

        --생산순번 조회
        BEGIN
            SELECT NVL(MAX(WRK_SEQ),0) INTO V_WRK_SEQ
              FROM TB_LAMI_PC_RESULT
             WHERE WERKS = P_WERKS
               AND WRK_ORDR_NO = P_WRK_ORDR_NO
               AND ORDER_NO = V_ORDER_NO
               AND NVL(USE_YN,'Y') = 'Y'
               AND NVL(SL_MOVE_YN,'Y') = 'Y'
               ;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                V_WRK_SEQ := 0;
        END;


--        SELECT NVL(COUNT(*),0)
--        INTO V_CNT1
--        FROM TB_LAMI_SL_RESULT
--        WHERE 1 = 1
--        AND WRK_ORDR_NO = P_WRK_ORDR_NO
--        AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
--        AND WERKS = P_WERKS
--        ;

--        V_WRK_SEQ := NVL(V_WRK_SEQ, 0) + 1;

--        V_PRD_NO := TO_CHAR(TO_DATE(P_PRFM_DT, 'YYYYMMDD'), 'YYYY-MM-DD') || '-' || V_MACHINE || '-' || TO_CHAR(V_WRK_SEQ);
--
--        V_PRD_DT := TO_CHAR(V_REGDATE, 'YYYYMMDD');

		--I/F 문서번호(SAP저장 결과에 따라 바뀔수 있음 : 현재는 주석 처리)
--         IF V_DOC_NO IS NULL THEN
--            BEGIN
--                V_DOC_NO := FN_GET_MDOCNO('M','IF125');
--                V_DOC_SEQNO := 1;
--            END;
--        END IF;


        --개별바코드(SAP저장 결과에 따라 바뀔수 있음 : 현재는 주석 처리)
/*         IF V_IND_BCD IS NULL THEN
            BEGIN
                SP_GET_BARCODE_SEQ('IND', P_WERKS, 'J', V_MATNR, P_SDATE, V_IND_BCD);
            END;
        END IF;
 */
        --LOT NO(SAP저장 결과에 따라 바뀔수 있음 : 현재는 주석 처리)
         IF V_RUN_STA = '09' THEN
--            IF V_LOT_NO_BUF IS NULL THEN
--                BEGIN
--                    SP_CHK_LOT_NO(NVL(V_LOT_NO, ' '), P_WERKS, P_MACH_CD, V_MATNR, P_SDATE, V_LOT_NO);
                    V_ORDER_NO :=' ';
                    V_STCK_STA := '60';

--                    SP_GET_DOC_SEQ('WTJA', V_PRD_DT, V_WRK_ORDR_NO);
                    V_WRK_ORDR_SEQNO := 1;
--                END;
--            END IF;

        ELSE
--            IF V_LOT_NO_BUF IS NULL THEN
--                BEGIN
--                    SP_CHK_LOT_NO(NVL(V_LOT_NO_BUF, ' '), P_WERKS, P_MACH_CD, V_MATNR, P_SDATE, V_LOT_NO);
                    V_STCK_STA := '00';
--                    V_LOT_NO_BUF := V_LOT_NO; 
--                END;
--            END IF;

        END IF;

        IF V_REMAIN_QTY = 0 THEN
            BEGIN
                UPDATE TB_LAMI_PC
                   SET USE_YN = 'N'
                 WHERE WRK_ORDR_NO = P_WRK_ORDR_NO
                   AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
                   AND WERKS = P_WERKS
                   --AND NVL(DLFL,'N') = 'N'  --삭제지시자 X='삭제' , N=정상오더
                   AND NVL(USE_YN, 'Y') = 'Y'
                   ;
            END;
        END IF;

        IF P_WGT - (P_PRFM_QTY + P_SALWEIGHT) >= 0 THEN
            BEGIN

                UPDATE TB_LAMI_PC_RESULT
                   SET USE_YN = 'N'
                 WHERE WRK_ORDR_NO = P_WRK_ORDR_NO
                   AND WERKS = P_WERKS
                   AND WRK_SEQ = V_WRK_SEQ
                   --AND NVL(DLFL,'N') = 'N'  --삭제지시자 X='삭제' , N=정상오더
                   AND NVL(USE_YN, 'Y') = 'Y'
                   AND NVL(SL_MOVE_YN,'Y') = 'Y'
                   ;

--                IF V_CNT1 > 0 THEN
--                    BEGIN
--                        DELETE FROM TB_LAMI_SL_RESULT
--                         WHERE WRK_ORDR_NO = P_WRK_ORDR_NO  
--                           AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
--                           AND WERKS = P_WERKS
--                           ;
--                    END;
--                END IF;


                    --실적등록
                INSERT INTO TB_LAMI_SL_RESULT( WERKS, MACH_CD, IND_BCD, LOT_NO, MATNR, 
                                    ORDER_NO, WRK_ORDR_NO, WRK_ORDR_SEQNO, PRD_NO,
                                    UNIT, WIDTH, ROLLCNT, PRFM_QTY, WGT, RSPEED, MER_YN, GRD_YN,
                                    PRD_STR_DATE, PRD_END_DATE, TM, PRFM_DT, PRD_DT,
                                    DSTBT_DDLIN, WRK_CLASS, WRK_SHIFT, MACHINE, TO_MACHINE, STA,
                                    DOC_NO, DOC_SEQNO, RMK, REGDATE, REGID, RUN_STA, WRK_SEQ, USE_YN,SALWEIGHT)
                            VALUES(P_WERKS, P_MACH_CD, ' ', '', V_MATNR,  
                                    V_ORDER_NO, P_WRK_ORDR_NO, P_WRK_ORDR_SEQNO, V_PRD_NO,
                                    V_UNIT, V_WIDTH, P_ROLLCNT, P_PRFM_QTY, P_WGT, 0, 'N', 'N',
                                    TO_DATE(P_SDATE, 'YYYYMMDDHH24MISS'),
                                    TO_DATE(P_EDATE, 'YYYYMMDDHH24MISS'),
                                    TO_NUMBER(V_CYCLE_TIME), P_PRFM_DT, V_PRD_DT,
                                    '', V_WRK_CLASS, V_WRK_SHIFT, V_MACHINE, V_TOMACHINE, V_STCK_STA,
                                    '', 0, P_RMK, V_REGDATE, P_USERID, V_RUN_STA, P_WRK_SEQ, 'N',P_SALWEIGHT);
            END;
        ELSIF  P_WGT - (P_PRFM_QTY + P_SALWEIGHT) < 0 THEN
            BEGIN

                ROLLBACK;

                RS_CODE := 'E';
                RS_MSG  := '투입예정량 보다 현재 전체 투입량이 많습니다. 투입 가능한 량은 폐품량까지 포함하여' || P_WGT || 'KG 입니다.';
                RETURN;

            END;
        END IF;

        --재고 생성
                V_STOR_LOC_CD := '1000';
--        V_LOC_CD := 'L2100';
                V_LOC_CD := '1000';
--        INSERT INTO TB_INV001( WERKS, STOR_LOC_CD, IND_BCD, MATNR, LOC_CD, LOT_NO,
--                            MACH_CD, MACHINE, WRK_ORDR_NO, WRK_ORDR_SEQNO, ORDER_NO,
--                            PRD_NO, IN_MR_YN, PRD_DT, UNIT, STCK_QTY, ROLLCNT, WGT, STCK_STA,
--                            DOC_NO, DOC_SEQNO, DLFL, REGDATE, REGID)
--                    VALUES( P_WERKS, V_STOR_LOC_CD, V_IND_BCD, V_MATNR, V_LOC_CD, V_LOT_NO,
--                            P_MACH_CD, V_MACHINE, V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_ORDER_NO, 
--                            '', 'N', V_PRD_DT, V_UNIT, P_WGT, P_ROLLCNT, P_WGT, V_STCK_STA,
--                            V_DOC_NO, V_DOC_SEQNO, 'N', V_REGDATE, P_USERID);

                V_SDATE := TO_CHAR(TO_DATE(P_SDATE, 'YYYYMMDDHH24MISS'), 'YYYY-MM-DD');
                V_STIME := TO_CHAR(TO_DATE(P_SDATE, 'YYYYMMDDHH24MISS'), 'HH24:MI:SS');
                V_EDATE := TO_CHAR(TO_DATE(P_EDATE, 'YYYYMMDDHH24MISS'), 'YYYY-MM-DD');
                V_ETIME := TO_CHAR(TO_DATE(P_EDATE, 'YYYYMMDDHH24MISS'), 'HH24:MI:SS');
		--V_PRD_NO := TO_CHAR(TO_DATE(V_PRFM_DT, 'YYYYMMDD'), 'YYYY-MM-DD') || '-' || V_MACHINE || '-' || TO_CHAR(V_WRK_SEQ);
        --SAP I/F
		/*
        INSERT INTO TB_IFS003( AUFNR, JRLOT, WERKS, WORKCENTERCODE, BUDAT, BUDAT_SAP, MACHINE,
                            WORKGROUP, JVERID, JMATNR, JROLLCNT, JBRGEW, JGEWEI, JRUNTIME,
                            CONF, JSDATE, JSTIME, JEDATE, JETIME, JSPEED, MDOCNO, MDOCSEQ,
                            MAKE_DATE, MAKER)
                     VALUES(V_ORDER_NO, V_LOT_NO, P_WERKS, V_SAP_WRK_CD, TO_CHAR(TO_DATE(P_PRFM_DT, 'YYYYMMDD'), 'YYYY-MM-DD'), TO_CHAR(TO_DATE(P_PRFM_DT, 'YYYYMMDD'), 'YYYY-MM-DD'), V_MACHINE,
                            NVL(V_WRK_CLASS, ' '), V_MACHINE, V_MATNR, P_ROLLCNT, P_WGT, V_UNIT, TO_CHAR(P_TM),
                            (CASE WHEN P_FINISH = 'Y' THEN 'X' ELSE '' END), V_SDATE, V_STIME, V_EDATE, V_ETIME, P_RSPEED, V_DOC_NO, TO_CHAR(V_DOC_SEQNO),         -- SAP 에 마지막생산 전송시 'Y'를 'X', 아닌경우는 빈값으로 전송
                            V_REGDATE, P_USERID);
		*/

         --문서이력
         -- 1=실적, 2=생산폐품, 3=영업폐품, 4=잔량폐품, 5=투입자재 소요량, 6=재고이전(위치), 7=재고이전(자재변경), 8=재고이전(재고실사)
         -- 9=LOT변경, 10=등급변경, 11=LOT병합, 12=LIFT출고, 20=오더완료
/*                 INSERT INTO TB_WRK021(DOC_NO, DOC_SEQNO, DOC_DIV, WERKS, MACH_CD, WRK_ORDR_NO, WRK_ORDR_SEQNO,
                                    IND_BCD, LOT_NO, ORDER_NO, CNL_YN, REGDATE, REGID)
                            VALUES(V_DOC_NO, V_DOC_SEQNO, 1, P_WERKS, P_MACH_CD, V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO,
                                    V_IND_BCD, V_LOT_NO, V_ORDER_NO, 'N', V_REGDATE, P_USERID);           
 */

                    V_DOC_NO := FN_GET_MDOCNO('M','IF130'); 

                    V_DOC_NO_INPUT := V_DOC_NO_INPUT||V_DOC_NO||',' ;

                    --자재 투입이력
/*                     INSERT INTO TB_INV010( WERKS, MACH_CD, MATNR, IND_BCD, SEQNO, WRK_ORDR_NO, WRK_ORDR_SEQNO,
                                        LOT_NO, IND_BCD_M, LOT_NO_M, MATNR_M, INP_DT, PRFM_DT,
                                        USE_QTY, UNIT, ROLLCNT, WGT, CHG_FLG, STCK_KY, LOT_NUM,
                                        REGDATE, REGID, USE_DIV, DOC_NO, DOC_SEQNO)
                                VALUES(P_WERKS, P_MACH_CD, V_MATNR, V_IND_BCD, 1, V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO,
                                        V_LOT_NO, V_IND_BCD, V_LOT_NO, V_MATNR, V_PRD_DT, P_PRFM_DT,
                                        P_WGT, V_UNIT, 1, P_WGT, 'N', '', '', 
                                        V_REGDATE, P_USERID, '1', V_DOC_NO, V_DOC_SEQNO);
 */

		V_DOC_NO_SCR := FN_GET_MDOCNO('M', 'IF134');
		V_DOC_SEQNO_SCR := V_DOC_SEQNO_SCR + 1;
		--폐품저장
--		IF P_SALWEIGHT > 0 THEN
--		BEGIN

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
/* 			INSERT INTO TB_WRK022 (
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
				'900',
				P_WRK_ORDR_NO,
				P_WRK_ORDR_SEQNO,
				V_ORDER_NO,
				V_MATNR,
				'',
				'',
				0,
				V_UNIT,
				P_SALWEIGHT,
				'',
				P_SALWEIGHT,
				'',
				'',
				'',
				P_PRFM_DT,
				P_WRK_CLASS,
				P_WRK_SHIFT,
				'02',
				V_DOC_NO_SCR,
				V_DOC_SEQNO_SCR,
				P_SALRMK,
				V_REGDATE,
				P_USERID
			);

			UPDATE TB_INV003                -- 자재투입량 폐품 2
			   SET DISPO_QTY = NVL(DISPO_QTY,0) + NVL(P_SALWEIGHT, 0),
				   USE_QTY   = NVL(USE_QTY,0) + NVL(P_WGT, 0),
				   STCK_QTY  = NVL(STCK_QTY, 0)  - (NVL(P_SALWEIGHT,0) + NVL(P_WGT,0))
			 WHERE WERKS   = P_WERKS
			   AND MACH_CD = P_MACH_CD
			   AND IND_BCD = V_IND_BCD;
 */
--		END;
--		END IF;

--        IF P_FINISH = 'Y' THEN
--            UPDATE TB_LAMI_PC
--                   SET COMP_YN = 'Y'
--             WHERE WRK_ORDR_NO = V_WRK_ORDR_NO
--               AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
--               --AND NVL(DLFL,'N') = 'N'  --삭제지시자 X='삭제' , N=정상오더
--               AND NVL(COMP_YN, 'Y') = 'N'
--               ;
--
--            -- 점보롤 완료인경우 TB_WRK011(작업장(설비)별 현재 진행현황) 테이블 업데이트 진행
--            -- 작업진행중인 작업지시번호 -> 이전작업지시번호, 작업지시순번 -> 이전작업지시순번으로 이동
--            -- 자재번호, 작업지시번호, 작업지시순번 삭제
--            UPDATE TB_WRK011
--                SET PRE_WRK_ORDR_NO = V_WRK_ORDR_NO,
--                    PRE_WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO,
--                    MATNR = '',
--                    WRK_ORDR_NO = '', 
--                    WRK_ORDR_SEQNO = '',
--                    ORDER_NO = '',
--                    LOT_NO = '',
--                    PRD_STR_DTM = P_EDATE,
--                    MACH_STA = 'N',
--                    RUN_STA = V_RUN_STA
--            WHERE MACH_CD = P_MACH_CD; 
--        ELSE
--            UPDATE TB_WRK011
--                SET PRD_STR_DTM = P_EDATE,
--                    LOT_NO = V_LOT_NO,  
--                    RUN_STA = V_RUN_STA
--            WHERE MACH_CD = P_MACH_CD; 
--        END IF;

        -- 개별바코드 전달
        RS_IND_BCD := V_IND_BCD;

        --SAP FUNC ID
--        SELECT RFCFN
--          INTO RS_RFCFN
--          FROM TB_ITFMA
--         WHERE 1=1
--           AND IFID = V_IF_ID;

        --인터페이스 파라미터
/*         OPEN CUR_1 FOR
         SELECT V_IF_ID AS I_IF_ID
              , 'M' || LTRIM(RTRIM(TO_CHAR(SEQ_GET_IFR_KEY.NEXTVAL, '00000000000000000000000000000'))) AS I_IF_KEY
         FROM dual;
 */ 
        --인터페이스 상세 파라미터
/*         V_SQL := FN_IF_QUERY(V_IF_ID, V_DOC_NO);
        OPEN CUR_2 FOR V_SQL;
 */
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
