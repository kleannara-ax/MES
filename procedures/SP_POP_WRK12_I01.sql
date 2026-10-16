
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK12_I01" SP_POP_WRK12_I01
(
    P_WERKS             IN VARCHAR2
    ,P_MACH_CD          IN VARCHAR2 
    ,P_USERID           IN VARCHAR2 
    ,P_ORDER_NO         IN VARCHAR2 
    ,P_WRK_ORDR_NO      IN VARCHAR2 
    ,P_WRK_ORDR_SEQNO   IN VARCHAR2 
    ,P_MATNR            IN VARCHAR2 
    ,P_WRK_ROLLCNT      IN VARCHAR2
    ,P_WRK_WIDTH        IN VARCHAR2
    ,P_WRK_QTY          IN VARCHAR2
    ,P_PRD_STR_DATE     IN VARCHAR2
    ,P_PRD_END_DATE     IN VARCHAR2
    ,P_TM               IN VARCHAR2
    ,P_SPEED            IN VARCHAR2
    ,P_RMK              IN VARCHAR2
    ,P_WRK_DATE         IN VARCHAR2
    ,P_WDOC_NO          OUT VARCHAR2 
    ,P_USE_FUNC         OUT VARCHAR2 
    ,Lang               IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE            OUT VARCHAR2 
    ,RS_MSG             OUT VARCHAR2
    ,CUR_1          OUT SYS_REFCURSOR
    ,CUR_2          OUT SYS_REFCURSOR
    ,CUR_3          OUT SYS_REFCURSOR
    ,CUR_4          OUT SYS_REFCURSOR
    ,CUR_5          OUT SYS_REFCURSOR
    ,CUR_6          OUT SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : POP_WRK12
 * PROGRAM NAME  : 화장지 합지기 실적등록
 * VERSION       : 1.0.0
 * DESCRIPTION   : 조회된 지시의 입력된 생산정보를 처리한다.
 *                 
 * AUTHOR NAME   : 김기연
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
 * 2022/05/04    1.0.0   김기연         Initial Version
 *==============================================================================
 *  관련 테이블
 * - [TB_WRK001] : (C...) HL 생산실적
 * - [TB_WRK012] : (.R..) 작업장별 가동 현황
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM            VARCHAR2(100)  := 'SP_POP_WRK12_I01';     -- PROCEDURE NAME
    V_PLT_CD            VARCHAR2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID      VARCHAR2(20) := P_USERID; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER    EXCEPTION;
    E_SQL_ERR_CD        NUMBER(5) := 0;
    E_SQL_ERR_MSG       VARCHAR2(4000);
    --parameter변수 처리
    V_PRD_STR_DATE      DATE := TO_DATE(P_PRD_STR_DATE, 'yyyy-MM-dd HH24:mi:ss');
    V_PRD_END_DATE      DATE := TO_DATE(P_PRD_END_DATE, 'yyyy-MM-dd HH24:mi:ss');
    V_TM                NUMBER := TO_NUMBER(P_TM);
    V_SPEED             NUMBER := TO_NUMBER(P_SPEED);
    V_WRK_ORDR_SEQNO    NUMBER(5,0) := TO_NUMBER(P_WRK_ORDR_SEQNO);
    V_WRK_ROLLCNT       NUMBER := TO_NUMBER(REPLACE(P_WRK_ROLLCNT, ',',''));
    V_WRK_WIDTH         NUMBER := TO_NUMBER(REPLACE(P_WRK_WIDTH, ',',''));
    V_WRK_QTY           NUMBER := TO_NUMBER(P_WRK_QTY);
    --내부 변수 등록
    V_DATE              DATE := SYSDATE;
    V_MACH_STA          TB_WRK011.MACH_STA%TYPE; --설비상태 정보
    V_WRK_STA           VARCHAR2(1); --작업지시 상태정보
    V_MAT_STA			VARCHAR2(1); --생산버전 여부
    V_ENDFLG            VARCHAR2(1); --생산완료 여부
    V_YMCHK             TB_MAS011.YMCHK%TYPE;
    V_PRFM_DT           VARCHAR2(8) := REPLACE(FN_RECDATE(V_PRD_END_DATE),'-',''); --실적일자
    V_PRD_DT            VARCHAR2(8) := REPLACE(P_WRK_DATE,'-',''); --생산일자
    V_ORDER_SEQNO       VARCHAR2(5);
    V_WRK_CLASS         VARCHAR2(10); --작업반
    V_WRK_SHIFT         VARCHAR2(10); --작업조
    V_IND_BCD           VARCHAR2(20); --개별 바코드
    V_LOT_TEMP          VARCHAR2(15); --LOT NO 조회
    V_LOT_NO            VARCHAR2(15); --LOT NO
    V_UNIT              VARCHAR2(10); --실적단위
    V_CAP_RATE          NUMBER(13,3); --초과허용비율
    V_ORDR_QTY          NUMBER(13,3); --지시수량
    V_PRFM_SUM          NUMBER(13,3); --실적수량
    V_PLT_QTY           NUMBER(13,1); --PLT수량
    V_BOX_QTY           NUMBER(13,1); --BOX수량
    V_BAG_QTY           NUMBER(13,1); --BAG수량
    V_EA_QTY            NUMBER(13,1); --EA수량
    V_WGT               NUMBER(13,3); --중량
    V_PCODE             VARCHAR2(10); --지종
    V_DOC_NO            VARCHAR2(29); --MES문서번호
    V_DOC_REQ           VARCHAR2(29); --MES문서번호(완제품 입고요청)
    V_DOC_USE           VARCHAR2(29); --MES문서번호(자재 소요량)
    V_MATNR_NM          VARCHAR2(1000); --자재명
    V_KAN_CD            VARCHAR2(18); --KAN코드
    V_MACH_NM           VARCHAR2(100); --설비명
    V_DSTBT_DDLIN       VARCHAR(10); --유통기간 일자
    V_DSTBT_DAYS        NUMBER(4); --유통기간
    V_MACHINE           VARCHAR2(5); --설비호기
    V_SAP_WRK_CD        VARCHAR2(20); --SAP작업장
    V_PUPOS             VARCHAR2(1); --용도
    V_BS_WGT            NUMBER(9,3); --평량
    V_WRK_NM            VARCHAR2(60); --작업자명
    V_LOC_CD            VARCHAR2(4); --투입 저장위치
    V_MATNR_CHG         VARCHAR2(18) := P_MATNR; --변경된 와당티슈 품목코드(기본값으로 기존코드 사용)
    V_ERR_LIST          VARCHAR2(4000); --수량 부족항목목록
    V_HIND_BCD          VARCHAR(20); --투입 합지 개별바코드
    V_HWORKER           VARCHAR(20); --투입 합지 작업자
    V_WERKS_TO          VARCHAR2(4); --와딩티슈 입고정보
    V_LOC_CD_TO         VARCHAR2(4);
    V_IF_ID             VARCHAR2(20) := 'MES_IF_123'; --MES IF ID 실적등록 합지기
    V_IF_ID_USE         VARCHAR2(20) := 'MES_IF_130'; --자재소요량
    V_SQL               VARCHAR2(4000);
BEGIN
    --예외처리 시작(try)
    BEGIN
        BEGIN
            -- 지시정보 조회
            SELECT PUPOS, ORDER_SEQNO, USE_YN, ORDER_QTY
              INTO V_PUPOS, V_ORDER_SEQNO, V_WRK_STA, V_ORDR_QTY
              FROM TB_SCH011
             WHERE 1=1
               AND WRK_ORDR_NO = P_WRK_ORDR_NO
               AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO;
            -- 자재정보 조회
            SELECT MATNR_NM, KAN_NO, NVL(DSTBT_DDLIN,0), BS_WGT, LGPRO, PCODE
              INTO V_MATNR_NM, V_KAN_CD, V_DSTBT_DAYS, V_BS_WGT, V_LOC_CD, V_PCODE
              FROM TB_MAS001
             WHERE 1=1
               AND WERKS = P_WERKS
               AND MATNR = P_MATNR;
            -- 설비 정보 조회   
            SELECT MACH_NM, MACHINE, SAP_WRK_CD
              INTO V_MACH_NM, V_MACHINE, V_SAP_WRK_CD
              FROM TB_MAS012
             WHERE 1=1
               AND MACH_CD = P_MACH_CD;
            -- 작업반,조 정보조회
            SELECT WRK_CLASS, WRK_SHIFT, MACH_STA
              INTO V_WRK_CLASS, V_WRK_SHIFT, V_MACH_STA
              FROM TB_WRK011
             WHERE 1=1
               AND WERKS = P_WERKS
               AND MACH_CD = P_MACH_CD
               AND IN_OUT = 'N';
            --작업자 정보 조회
            SELECT NMLAST INTO V_WRK_NM
              FROM USRMA
             WHERE 1=1
               AND USERID = P_USERID;
            --현재 실적수량 조회
            SELECT NVL(SUM(PRFM_QTY),0)
              INTO V_PRFM_SUM
              FROM TB_WRK001
             WHERE 1=1
               AND WERKS = P_WERKS
               AND WRK_ORDR_NO = P_WRK_ORDR_NO
               AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
               AND PRFM_GTHR_YN = 'Y';

            IF V_MACH_STA = 'S' THEN --설비 비가동시
            	RS_CODE := 'E';
                RS_MSG := '합지기 설비가 비가동 중입니다.\n설비를 가동후 실적을 등록하여 주시기 바랍니다.';
                RETURN;
            END IF;
              
            --지시 가용여부 확인
            IF NVL(V_WRK_STA,'Y') = 'N' THEN
                RS_CODE := 'E';
                RS_MSG := '삭제 처리된 작업지시입니다.\n별도의 지시를 선택하여 생산을 진행하여 주시기 바랍니다.';
                RETURN;
            END IF;
           
           --실적 수량 확인
           IF NVL(V_WRK_QTY,0.0) <= 0.0 THEN
           		RS_CODE := 'E';
                RS_MSG := '입력된 실적수량을 확인하여 주시기 바랍니다.';
                RETURN;
           END IF;
          
           --생산버전 확인
            BEGIN
                SELECT USE_YN INTO V_MAT_STA
                  FROM TB_MAS007
                 WHERE WERKS = P_WERKS
                   AND PRCMC = V_MACHINE
                   AND MATNR = P_MATNR;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    V_MAT_STA := 'N';
            END;

            IF V_MAT_STA = 'N' THEN
                RS_CODE := 'E';
                RS_MSG := '제품의 생산버전이 존재하지 않습니다.\n생산버전을 등록후 진행하여주시기 바랍니다.';
                ROLLBACK;
                RETURN;
            END IF;
            
            BEGIN
                SELECT YMCHK INTO  V_YMCHK
                  FROM TB_MAS011
                 WHERE WERKS = P_WERKS
                   AND YYMM = SUBSTR(V_PRFM_DT, 0, 6)
                   AND USE_YN = 'Y';
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
           
---- 23-02-07(김병무) 실적 완료 여부가 되어 있어도 실적등록 가능 주석처리. 실적현황 확인요청(입고요청)시 완료플래그 SAP에 2회 전송시, 실적만 전송하도록 수정
--            --실적등록 완료여부 조회
--            SELECT MAX(NVL(COMP_YN,'N'))
--              INTO V_ENDFLG
--              FROM TB_WRK001
--             WHERE 1=1
--               AND WERKS = P_WERKS
--               AND WRK_ORDR_NO = P_WRK_ORDR_NO
--               AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
--               AND NVL(CNL_YN,'N') != 'Y'; --20230131         --  NVL 없이 체크 하면 실적 완료 체크 안됨 AND CNL_YN != 'Y';
--            IF V_ENDFLG = 'Y' THEN
--                RS_CODE := 'E';
--                RS_MSG := '실적등록이 완료된 지시입니다.';
--                ROLLBACK;
--                RETURN;
--            END IF;

            --현재 실적수량 조회
            SELECT NVL(SUM(PRFM_QTY),0)
              INTO V_PRFM_SUM
              FROM TB_WRK001
             WHERE 1=1
               AND WERKS = P_WERKS
               AND WRK_ORDR_NO = P_WRK_ORDR_NO
               AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
               AND PRFM_GTHR_YN = 'Y';
            
            --실적 제한수량 확인
            BEGIN
                SELECT USARG1
                  INTO V_CAP_RATE
                  FROM CMCDV
                 WHERE 1=1
                   AND CMCDKY = 'PRFMCAP'
                   AND CMCDVL = 'AA'
                   AND USE_YN = 'Y';
            EXCEPTION WHEN NO_DATA_FOUND THEN
               V_CAP_RATE := -1;
            END;
           
            IF V_CAP_RATE >= 0 THEN
                --제한수량 초과여부 확인
                V_ORDR_QTY := V_ORDR_QTY + V_ORDR_QTY * (V_CAP_RATE/100);
                V_PRFM_SUM := V_PRFM_SUM + P_WRK_QTY;
                IF V_ORDR_QTY < V_PRFM_SUM THEN
                    RS_CODE := 'E';
                    IF V_CAP_RATE = 0 THEN 
                        RS_MSG := '실적수량이 계획수량을 초과하여 등록이 불가능합니다.';
                    ELSE
                        RS_MSG := '계획대비 실적수량이 ' || V_CAP_RATE || '%이상 초과하여 등록이 불가능합니다.';
                    END IF;
                    RETURN;
                END IF;
            END IF;

            --문서번호 생성
            V_DOC_NO := FN_GET_MDOCNO('M','IF123');

            --개별 바코드 / LOTNO 작성
            --V_IND_BCD := 'TEST_BCD'; TO_CHAR(V_DATE,'YYYY-MM-DD HH24:MI:SS')
            SP_GET_BARCODE_SEQ('IND', P_WERKS, P_MACH_CD, P_MATNR, P_PRD_END_DATE, V_IND_BCD);

            --비가동 시간 처리 YSH 20221208
            --V_TM := V_TM - FN_NON_ACT_TM(V_PRD_STR_DATE, V_PRD_END_DATE, P_MACH_CD);
           
            --실적 수량 확인
            IF V_TM <= 0.0 THEN
           		RS_CODE := 'E';
                RS_MSG := '가동시간이 0으로 집계되었습니다.\n비가동 이력을 확인하여 실적시간 또는 비가동시간을 변경하여 주시기 바랍니다.';
                RETURN;
            END IF;
           
            --기존 Lot 조회
            SELECT NVL(LOT_NO,' ') INTO V_LOT_TEMP
              FROM TB_WRK011
             WHERE 1=1
               AND WERKS = P_WERKS
               AND MACH_CD = P_MACH_CD
               AND IN_OUT = 'N'; --합지기의 경우 N으로 고정
            --LOT_NO 작성
            --V_LOT_NO := 'test02';
--            SP_CHK_LOT_NO (V_LOT_TEMP, P_WERKS, P_MACH_CD, P_MATNR, P_PRD_END_DATE, V_LOT_NO);
            SP_CHK_LOT_NO ('', P_WERKS, P_MACH_CD, P_MATNR, P_PRD_END_DATE, V_LOT_NO);
            V_IND_BCD:= V_LOT_NO;
            --품질관리용 테이블 등록
            UPDATE TB_WRK501
               SET LOT_NO = V_LOT_NO
                 , WRK_ORDR_NO = P_WRK_ORDR_NO
                 , WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
                 , MATNR = P_MATNR
                 , UPDDATE = V_DATE
                 , UPDID = P_USERID
             WHERE 1=1
               AND WERKS = P_WERKS
               AND MACH_CD = P_MACH_CD;
            IF SQL%ROWCOUNT = 0 THEN
                INSERT INTO TB_WRK501 (LOT_NO, WERKS, MACH_CD, WRK_ORDR_NO, WRK_ORDR_SEQNO, REGDATE, REGID, MATNR)
                                VALUES(V_LOT_NO, P_WERKS, P_MACH_CD, P_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_DATE, P_USERID, P_MATNR);
            END IF;

            --기준 단위 및 단위변환 등록
            V_UNIT := 'KG';
            V_WGT := V_WRK_QTY;
            V_PLT_QTY := FN_CHG_UNIT(P_MATNR, P_WERKS, 'KG', 'PAL', V_WRK_QTY);
            V_BOX_QTY := FN_CHG_UNIT(P_MATNR, P_WERKS, 'KG', 'BOX', V_WRK_QTY);
            V_BAG_QTY := FN_CHG_UNIT(P_MATNR, P_WERKS, 'KG', 'BAG', V_WRK_QTY);
            V_EA_QTY := FN_CHG_UNIT(P_MATNR, P_WERKS, 'KG', 'EA', V_WRK_QTY);
            
            --유통기간 확인
            IF V_DSTBT_DAYS = 0 THEN
                V_DSTBT_DDLIN := '';
            ELSE
                V_DSTBT_DDLIN := TO_CHAR(TO_DATE(V_PRFM_DT,'YYYYMMDD') + V_DSTBT_DAYS,'YYYYMMDD');
            END IF;

            --HL 생산실적 등록
            INSERT INTO TB_WRK001 (WERKS, MACH_CD, IND_BCD, LOT_NO, MATNR,
                                    ORDER_NO, ORDER_SEQNO, WRK_ORDR_NO, WRK_ORDR_SEQNO,
                                    PRFM_QTY, UNIT, WGT, ROLLCNT, WIDTH, PLT_QTY, BOX_QTY, BAG_QTY, EA_QTY,
                                    PRD_STR_DATE, PRD_END_DATE, TM, PRFM_DT, PRD_DT, DSTBT_DDLIN,
                                    WRK_CLASS, WRK_SHIFT, STA, DOC_NO, DOC_SEQNO,
                                    RMK, CHK_PP_YN, REGDATE, REGID)
                           VALUES(P_WERKS, P_MACH_CD, V_IND_BCD, V_LOT_NO, P_MATNR,
                                    P_ORDER_NO, V_ORDER_SEQNO, P_WRK_ORDR_NO,P_WRK_ORDR_SEQNO,
                                    V_WGT, V_UNIT, V_WGT, V_WRK_ROLLCNT, V_WRK_WIDTH, V_PLT_QTY, V_BOX_QTY, V_BAG_QTY, V_EA_QTY,
                                    V_PRD_STR_DATE, V_PRD_END_DATE, V_TM, V_PRFM_DT, V_PRD_DT, V_DSTBT_DDLIN,
                                    V_WRK_CLASS, V_WRK_SHIFT, '00', V_DOC_NO, 1,
                                    P_RMK, 'N', V_DATE, P_USERID);
            --생산수량정보 작업지시에 저장
            UPDATE TB_SCH011
               SET PRFM_QTY = NVL(PRFM_QTY,0) + NVL(V_WRK_QTY,0)
                 , PRD_LAST_DATE = V_DATE
                 , UPDDATE = V_DATE
                 , UPDID = P_USERID
             WHERE 1=1
               AND WRK_ORDR_NO = P_WRK_ORDR_NO
               AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO;
            --작업장 현황 정보 변경
            UPDATE TB_WRK011
               SET LOT_NO = V_LOT_NO
                 , UPDDATE = V_DATE
                 , UPDID = P_USERID
             WHERE 1=1
               AND WERKS = P_WERKS
               AND MACH_CD = P_MACH_CD
               AND IN_OUT = 'N'; --합지기의 경우 N으로 고정
            --작업자 현황 정보추가
            UPDATE TB_WRK013
               SET PRFM_DT = V_PRFM_DT
             WHERE 1=1
               AND WERKS = P_WERKS
               AND MACH_CD = P_MACH_CD
               AND IN_OUT = 'N'
               AND END_DATE IS NULL;

            --가용수량 확인
            SP_REG_LOT_LOG_S01 (P_WERKS, P_MACH_CD, P_MATNR, P_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_WGT, 1, V_ERR_LIST);
            IF LENGTH(V_ERR_LIST) > 0 THEN
                ROLLBACK;
                RS_CODE := 'N';
                RS_MSG  := V_ERR_LIST;
                RETURN;
            END IF;
            --LOT추적정보 등록 
            --자재 소요량 SAP전송 문서번호 반환
            SP_REG_LOT_LOG_I01 (P_WERKS, P_MACH_CD, P_MATNR, V_LOT_NO, V_IND_BCD, P_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_PRFM_DT, V_WGT, V_UNIT, 'N', 1, P_USERID, RS_CODE, RS_MSG);
            IF RS_CODE = 'E' THEN
                ROLLBACK;
                RS_CODE := 'E';
                RS_MSG  := RS_MSG;
                RETURN;
            END IF;

            --투입된 자재정보 조회
            SELECT NVL(MAX(IND_BCD),'')
              INTO V_HIND_BCD
              FROM TB_INV010 I010, TB_MAS001 M001
             WHERE 1=1
               AND ROWNUM < 2
               AND I010.WERKS = M001.WERKS
               AND I010.MATNR_M = M001.MATNR
               AND I010.WERKS = P_WERKS
               AND I010.MACH_CD = P_MACH_CD
               AND I010.MATNR = P_MATNR
               AND I010.IND_BCD = V_IND_BCD
               AND M001.MATNR_DIV = 'HALB'
               AND NVL(I010.CNL_YN,'N') = 'N' ;
            --투입된 자재 실적정보 조회
            BEGIN
                SELECT REGID
                  INTO V_HWORKER 
                  FROM TB_WRK001
                 WHERE 1=1
                   AND WERKS = P_WERKS
                   --AND MACH_CD = ''
                   AND IND_BCD = V_HIND_BCD;
                EXCEPTION WHEN NO_DATA_FOUND THEN
                    V_HWORKER := '';
            END;

            --인터테이스 테이블 등록
            INSERT INTO TB_IFS001(AUFNR, LOTNO, PRDCD, WERKS, WORKCENTERCODE, MACHINE,
                                    PRDDT, PRODT, WORKGROUP, LEADER, WORKER, CW_WORKER, PUPOS,
                                    PROQTY, RUNTIME, SDATE, STIME, EDATE, ETIME, 
                                    SCPAP, SAIP, SCRQTY,
                                    MDOCNO, MDOCSEQ, MAKE_DATE, MAKER)
                            VALUES(P_ORDER_NO, V_LOT_NO, P_MATNR, P_WERKS, V_SAP_WRK_CD, V_MACHINE,
                                    V_PRFM_DT, V_PRD_DT, V_WRK_CLASS, P_USERID, P_USERID, V_HWORKER, V_PUPOS,
                                    V_WGT, V_TM, TO_CHAR(V_PRD_STR_DATE,'YYYYMMDD'), TO_CHAR(V_PRD_STR_DATE,'HH24MISS'), 
                                    TO_CHAR(V_PRD_END_DATE,'YYYYMMDD'), TO_CHAR(V_PRD_END_DATE,'HH24MISS'),
                                    'N', 'N', 0,
                                    V_DOC_NO, 1, V_DATE, P_USERID);
            --IF 전송이력(1:실적)
            INSERT INTO TB_WRK021(DOC_NO, DOC_SEQNO, DOC_DIV,
                                WERKS, MACH_CD, WRK_ORDR_NO, WRK_ORDR_SEQNO,
                                IND_BCD, LOT_NO, ORDER_NO, CNL_YN,
                                REGDATE, REGID)
                            VALUES(V_DOC_NO, 1, 1,
                                P_WERKS, P_MACH_CD, P_WRK_ORDR_NO, V_WRK_ORDR_SEQNO,
                                V_IND_BCD, V_LOT_NO, P_ORDER_NO, 'N',
                                V_DATE, P_USERID);

--            --와딩티슈 처리
--            IF P_MACH_CD = 'TAA02' THEN
--                --제품 출고요청 문서번호 작성
--                V_DOC_REQ := FN_GET_MDOCNO('M','IF402');
--                --완제품 출고 요청 정보
--                INSERT INTO TB_IFSWM005 (DOC_NO, DOC_SEQNO, DLFL, IND_BCD, LOT_NO
--                                        , WERKS, MATNR, QTY, UNIT, ORDER_NO, ORDER_SEQNO, STOR_LOC_FROM, STOR_LOC_TO
--                                        , MACHINE, PCODE, WEIGHT
--                                        , IF_GET_DATE, EMPLY_NO, EMPLY_NM, PRDC_DT, REQ_DT)
--                               VALUES (V_DOC_REQ, 1, 'C', V_IND_BCD, V_LOT_NO
--                                        , P_WERKS, V_MATNR_CHG, V_WGT, V_UNIT, P_ORDER_NO, 1, '2000', '3000'
--                                        , V_MACHINE, V_PCODE, V_BS_WGT
--                                        , V_DATE, P_USERID, V_WRK_NM, V_PRFM_DT, TO_CHAR(V_DATE,'YYYYMMDD')); 
--                --완제품 출고 이력                        
--                INSERT INTO TB_WRK015 (DOC_NO, DOC_SEQNO, DLFL, WERKS,
--                                        MATNR, QTY, UNIT, STOR_LOC_FR, 
--                                        IND_BCD, LOT_NO, MACHINE,
--                                        ORDER_NO, ORDER_SEQNO, WRK_ORDR_NO, WRK_ORDR_SEQNO,
--                                        EMPLY_NO, EMPLY_NM, PRD_DT, PRFM_DT,
--                                        REQ_STA, REGDATE,REGID)
--                                VALUES (V_DOC_REQ, 1, 'N', P_WERKS,
--                                        V_MATNR_CHG, V_WGT, V_UNIT, '2000', 
--                                        V_IND_BCD, V_LOT_NO, V_MACHINE,
--                                        P_ORDER_NO, V_ORDER_SEQNO, P_WRK_ORDR_NO, V_WRK_ORDR_SEQNO,
--                                        P_USERID, V_WRK_NM, FN_DT_FORMAT(V_PRD_DT,'YYYY-MM-DD'), FN_DT_FORMAT(V_PRFM_DT,'YYYY-MM-DD'),
--                                        'R', V_DATE, P_USERID);  
--            END IF;
            --재고 등록
            INSERT INTO TB_INV001 (WERKS, STOR_LOC_CD, 
                                    MATNR, LOT_NO, IND_BCD, UNIT, MACH_CD, MACHINE,
                                    WRK_ORDR_NO, WRK_ORDR_SEQNO, ORDER_NO, DOC_NO, DOC_SEQNO,
                                    STCK_QTY, ROLLCNT, WGT, STCK_STA, PLT_QTY, BOX_QTY, BAG_QTY, EA_QTY,
                                    PRD_DT, PRFM_DT, IN_MR_YN, DLFL,
                                    REGDATE, REGID)
                            VALUES(P_WERKS, '2000',
                                    V_MATNR_CHG, V_LOT_NO, V_IND_BCD, V_UNIT, P_MACH_CD, V_MACHINE,
                                    P_WRK_ORDR_NO, P_WRK_ORDR_SEQNO, P_ORDER_NO, V_DOC_NO, 1,
                                    V_WGT, V_WRK_ROLLCNT, V_WGT, '00', V_PLT_QTY, V_BOX_QTY, V_BAG_QTY, V_EA_QTY,
                                    V_PRFM_DT, V_PRFM_DT, 'N', 'N',
                                    V_DATE, P_USERID);

            --라벨정보 반환
            OPEN CUR_1 FOR
            SELECT V_MACH_NM AS MACH_NM --설비명
                 , V_LOT_NO AS LOT_NO
                 , V_MATNR_NM AS MATNR_NM
                 , P_WRK_ROLLCNT AS ROLLCNT
                 , TO_CHAR(V_BS_WGT) AS BS_WGT
                 , P_WRK_QTY AS PRFM_WGT
                 , 'W' AS COLOR --색상(W 흰색으로 고정)
                 , V_WRK_NM AS WRK_NAME
                 , '합격' AS QCJUD --판정확인
                 , V_IND_BCD AS IND_BCD
            FROM dual;
            --WMS 완제품 출고요청
            V_SQL := FN_IF_QUERY('MES_IF_402', V_DOC_REQ);
            IF V_SQL IS NOT NULL THEN
            	OPEN CUR_2 FOR V_SQL;
            END IF;

            --SAP FUNC ID 123
            SELECT RFCFN
              INTO RS_MSG
              FROM TB_ITFMA
             WHERE 1=1
               AND IFID = V_IF_ID;
            --인터페이스 파라미터
            OPEN CUR_3 FOR
            SELECT V_IF_ID AS I_IF_ID
                 , 'M' || LTRIM(RTRIM(TO_CHAR(SEQ_GET_IFR_KEY.NEXTVAL, '00000000000000000000000000000'))) AS I_IF_KEY
            FROM dual;
            --인터페이스 상세 파라미터
            PKG_WRK055.LOG_IF('SP_POP_WRK12_I01', P_WERKS, V_IF_ID, V_DOC_NO, P_USERID);   -- WRK55 RFC 전송로그
            V_SQL := FN_IF_QUERY(V_IF_ID, V_DOC_NO);
            IF V_SQL IS NOT NULL THEN
            	OPEN CUR_4 FOR V_SQL;
            END IF;

            --투입 사용량 존재시 RFC 처리진행
            IF V_DOC_USE IS NOT NULL THEN
                --SAP FUNC ID 130
                SELECT RFCFN
                  INTO P_USE_FUNC
                  FROM TB_ITFMA
                 WHERE 1=1
                   AND IFID = V_IF_ID_USE;
                --인터페이스 파라미터
                OPEN CUR_5 FOR
                SELECT V_IF_ID_USE AS I_IF_ID
                     , 'M' || LTRIM(RTRIM(TO_CHAR(SEQ_GET_IFR_KEY.NEXTVAL, '00000000000000000000000000000'))) AS I_IF_KEY
                FROM dual;
                --인터페이스 상세 파라미터
                PKG_WRK055.LOG_IF('SP_POP_WRK12_I01', P_WERKS, V_IF_ID_USE, V_DOC_USE, P_USERID);   -- WRK55 RFC 전송로그
                V_SQL := FN_IF_QUERY(V_IF_ID_USE, V_DOC_USE);
                IF V_SQL IS NOT NULL THEN
            		OPEN CUR_6 FOR V_SQL;
            	END IF;
            END IF;
            --작업 정상 종료 코드 등록
            RS_CODE := 'S';
            --RS_MSG := V_DOC_NO;
            P_WDOC_NO := V_DOC_REQ;
           
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
        --RS_MSG  := SQLERRM;
        RETURN;
--    WHEN OTHERS THEN
--        E_SQL_ERR_CD        := -20001;
--        E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';
--
--        ROLLBACK;
--        --RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
--
--        RS_CODE := 'E';
--        RS_MSG  := SQLERRM;
--        RETURN;
    --예외처리 종료
    END;
END ;
/
