
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK18_I01" 
(
    P_WERKS             IN VARCHAR2
    ,P_MACH_CD          IN VARCHAR2 
    ,P_USERID           IN VARCHAR2 
    ,P_ORDER_NO         IN VARCHAR2
    ,P_WRK_ORDR_NO      IN VARCHAR2 
    ,P_WRK_ORDR_SEQNO   IN VARCHAR2 
    ,P_MATNR            IN VARCHAR2 
    ,P_PRFM_QTY         IN VARCHAR2
    ,P_PRFM_DT          IN VARCHAR2
    ,P_COMP_YN          IN VARCHAR2
    ,P_PRFM_FUNC        OUT VARCHAR2
    ,Lang               IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE            OUT VARCHAR2 
    ,RS_MSG             OUT VARCHAR2
    ,CUR_1              OUT SYS_REFCURSOR
    ,CUR_2              OUT SYS_REFCURSOR
    ,CUR_3              OUT SYS_REFCURSOR
    ,CUR_4              OUT SYS_REFCURSOR
    ,CUR_5              OUT SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : POP_WRK18
 * PROGRAM NAME  : 기저귀 가공기 실적등록
 * VERSION       : 1.0.0
 * DESCRIPTION   : 조회된 지시의 입력된 생산정보를 처리한다.
 *                 
 * AUTHOR NAME   : 김기연
 * CREATE DATE   : 2022/05/17
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/05/17    1.0.0   김기연         Initial Version
 *==============================================================================
 *  관련 테이블
 * - [TB_WRK001] : (C...) HL 생산실적
 * - [TB_WRK012] : (.R..) 작업장별 가동 현황
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM            VARCHAR2(100)  := 'SP_POP_WRK18_I01';     -- PROCEDURE NAME
    V_PLT_CD            VARCHAR2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID      VARCHAR2(20) := P_USERID; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD        NUMBER(5) := 0;
    E_SQL_ERR_MSG       VARCHAR2(4000);
    --parameter변수 처리
    V_WRK_ORDR_SEQNO    NUMBER(5,0) := TO_NUMBER(P_WRK_ORDR_SEQNO);
    V_PRFM_QTY          NUMBER := TO_NUMBER(P_PRFM_QTY);
    --내부 변수 등록
    V_DATE              DATE := SYSDATE;
    V_MACH_STA          TB_WRK011.MACH_STA%TYPE; --설비상태 정보
    V_WRK_STA           VARCHAR2(1); --작업지시 상태정보
    V_MAT_STA			VARCHAR2(1); --생산버전 여부
    V_ENDFLG            VARCHAR2(1); --생산완료 여부
    V_BOMCNT            NUMBER;--사용자재목록
    V_YMCHK             TB_MAS011.YMCHK%TYPE;
    V_PRFM_DT           VARCHAR2(8) := REPLACE(P_PRFM_DT,'-',''); --실적일자
    V_PRD_DT            VARCHAR(8) := TO_CHAR(V_DATE,'YYYYMMDD'); --등록일자
    V_ORDER_SEQNO       VARCHAR2(5);
    V_ORDR_COMP         VARCHAR2(1);--작업지시 완료여부
    V_WRK_CLASS         VARCHAR2(10); --작업조
    V_IND_BCD           VARCHAR2(20); --개별 바코드
    V_LOT_TEMP          VARCHAR2(15); --LOT NO 조회
    V_LOT_NO            VARCHAR2(10); --LOT NO
    V_UNIT              VARCHAR2(10); --실적단위
    V_CAP_RATE          NUMBER(13,3); --초과허용비율
    V_ORDR_QTY          NUMBER(13,3); --지시수량
    V_PRFM_SUM          NUMBER(13,3); --실적누적수량
    V_REG_QTY           NUMBER(13,1); --기준단위 실적수량(실적 등록수량)
    V_PLT_QTY           NUMBER(13,1); --PLT수량
    V_BOX_QTY           NUMBER(13,0); --BOX수량
    V_BAG_QTY           NUMBER(13,0); --BAG수량
    V_EA_QTY            NUMBER(13,0); --EA수량
    V_WGT               NUMBER(13,0); --KG중량
    V_ROLLCNT           NUMBER(13,0); --M길이
    V_MATNR_NM          VARCHAR2(1000); --자재명
    V_PART_DIV			VARCHAR2(10); --제품종류
    V_KAN_CD            VARCHAR2(18); --KAN코드
    V_MACH_NM           VARCHAR2(100); --설비명
    V_MACHINE           VARCHAR2(5); --설비호기
    V_LOC_CD            VARCHAR2(4); --저장위치
    V_SAP_WRK_CD        VARCHAR2(20); --SAP 작업장 코드
    V_DSTBT_DDLIN       VARCHAR(10); --유통기간 일자
    V_DSTBT_DAYS        NUMBER(4); --유통기간
    V_PRD_STR_DATE      DATE; --작업지시 시작시간
    V_WRK_STR_DATE      DATE; --실적 시작시간
    V_RUNTIME           NUMBER; --가동시간
    V_ERR_LIST          VARCHAR2(4000); --수량 부족항목목록
    V_IF_ID             VARCHAR2(20) := 'MES_IF_133'; --MES IF ID
    V_IF_ID_USE         VARCHAR2(20) := 'MES_IF_130'; --자재소요량
    V_DOC_PRFM          VARCHAR2(20); --실적등록 문서번호
    V_DOC_ORDR          VARCHAR2(20); --오더완료 문서번호
    V_DOC_SEQ           VARCHAR2(6) := '1';
    V_DOC_NO            VARCHAR2(29); --MES문서번호
    V_SQL               VARCHAR2(4000);
    V_CNT               NUMBER;

	V_STTIME_CNT		NUMBER;
BEGIN
    --예외처리 시작(try)
    BEGIN
        BEGIN
            -- 지시정보 조회
            SELECT ORDER_SEQNO, USE_YN, ORDER_QTY
              INTO V_ORDER_SEQNO, V_WRK_STA, V_ORDR_QTY
              FROM TB_SCH014
             WHERE 1=1
               AND WRK_ORDR_NO = P_WRK_ORDR_NO
               AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO;
              
            --가공기 정보 조회
			SELECT NVL(LOT_NO,' '), TO_DATE(PRD_STR_DTM, 'YYYYMMDDHH24MISS'), MACH_STA
              INTO V_LOT_TEMP, V_PRD_STR_DATE, V_MACH_STA
              FROM TB_WRK011
             WHERE 1=1
               AND WERKS = P_WERKS
               AND MACH_CD = P_MACH_CD
               AND IN_OUT != 'O';
              
            --자재정보 조회
            SELECT MATNR_NM, KAN_NO,NVL(DSTBT_DDLIN,0), UNIT, LGPRO, PART_DIV
              INTO V_MATNR_NM, V_KAN_CD, V_DSTBT_DAYS, V_UNIT, V_LOC_CD, V_PART_DIV
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

            -- 작업조 정보조회
            SELECT WRK_CLASS INTO V_WRK_CLASS
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
                RS_MSG := '가공기 설비가 비가동 중입니다.\n설비를 가동후 실적을 등록하여 주시기 바랍니다.';
                RETURN;
            END IF;  
              
            --생산오더 BOM 확인
            SELECT COUNT(*)
              INTO V_BOMCNT
              FROM TB_SCH020
             WHERE 1=1
               AND WERKS = P_WERKS
               AND WRK_ORDR_NO = P_WRK_ORDR_NO
               AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO;
            IF V_BOMCNT = 0 THEN
                RS_CODE := 'E';
                RS_MSG := '생산오더 BOM이 존재하지 않습니다.\n확인후 생산을 진행하여 주시기 바랍니다.';
                RETURN;
            END IF;

            --저장위치여부 확인
            IF V_LOC_CD IS NULL THEN
                RS_CODE := 'E';
                RS_MSG := '제품의 저장위치가 설정되지 않았습니다.\n품목정보를 확인하여 주시기 바랍니다.';
                RETURN;
            END IF;
            
            --지시 가용여부 확인
            IF NVL(V_WRK_STA,'Y') = 'N' THEN
                RS_CODE := 'E';
                RS_MSG := '삭제 처리된 작업지시입니다.\n별도의 지시를 선택하여 생산을 진행하여 주시기 바랍니다.';
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
--               AND NVL(CNL_YN, 'N') != 'Y';         --  NVL 없이 체크 하면 실적 완료 체크 안됨 AND CNL_YN != 'Y';
--            IF V_ENDFLG = 'Y' THEN
--                RS_CODE := 'E';
--                RS_MSG := '실적등록이 완료된 지시입니다.';
--                ROLLBACK;
--                RETURN;
--            END IF;

            --실적 제한수량 확인
            V_REG_QTY := FN_CHG_UNIT(P_MATNR, P_WERKS, 'BOX', V_UNIT, V_PRFM_QTY);
            BEGIN
                SELECT USARG1
                  INTO V_CAP_RATE
                  FROM CMCDV
                 WHERE 1=1
                   AND CMCDKY = 'PRFMCAP'
                   AND CMCDVL = 'RC'
                   AND USE_YN = 'Y';
            EXCEPTION WHEN NO_DATA_FOUND THEN
               V_CAP_RATE := -1;
            END;
            IF V_CAP_RATE >= 0 THEN
                --제한수량 초과여부 확인
                V_ORDR_QTY := V_ORDR_QTY + V_ORDR_QTY * (V_CAP_RATE/100);
                V_PRFM_SUM := V_PRFM_SUM + V_REG_QTY;
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

            --개별 바코드
            SP_GET_BARCODE_SEQ('IND', P_WERKS, P_MACH_CD, P_MATNR, TO_CHAR(V_DATE,'YYYY-MM-DD HH24:MI:SS'), V_IND_BCD);
            --LOT NO
            --기존 Lot 조회
            SELECT NVL(LOT_NO,' ') INTO V_LOT_TEMP
              FROM TB_WRK011
             WHERE 1=1
               AND WERKS = P_WERKS
               AND MACH_CD = P_MACH_CD
               AND IN_OUT = 'N';
            SP_CHK_LOT_NO (V_LOT_TEMP, P_WERKS, P_MACH_CD, P_MATNR, TO_CHAR(V_DATE,'YYYY-MM-DD HH24:MI:SS'), V_LOT_NO);
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

            --작업장 현황 LOT 정보 변경
            UPDATE TB_WRK011
               SET LOT_NO = V_LOT_NO
                 , UPDDATE = V_DATE
                 , UPDID = P_USERID
             WHERE 1=1
               AND WERKS = P_WERKS
               AND MACH_CD = P_MACH_CD;

            --작업시간 확인
            --등록된 마지막 실적 조회
            SELECT COUNT(*) INTO V_CNT
              FROM TB_WRK001
             WHERE WERKS = P_WERKS
               AND MACH_CD = P_MACH_CD
               AND PRFM_DT = V_PRFM_DT
               AND NVL(CNL_YN, 'N') = 'N';
            IF V_CNT > 0 THEN   
                BEGIN
                SELECT NVL(MAX(PRD_END_DATE),V_PRD_STR_DATE) INTO V_WRK_STR_DATE
                  FROM TB_WRK001
                 WHERE 1=1
                   AND WERKS = P_WERKS
                   AND MACH_CD = P_MACH_CD;
                   --AND WRK_ORDR_NO = P_WRK_ORDR_NO
                   --AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO;
                EXCEPTION WHEN NO_DATA_FOUND THEN
                    --이전 실적이  없는 경우 지시 시작시간 적용
                    V_WRK_STR_DATE := V_PRD_STR_DATE;
                END;
            ELSE
                V_WRK_STR_DATE := TO_DATE(FN_GET_LAST_DATE( P_WERKS, P_MACH_CD), 'YYYY-MM-DD HH24:MI:SS');
            END IF;
            
            --기준 단위 및 단위변환 등록
            V_PLT_QTY := FN_CHG_UNIT(P_MATNR, P_WERKS, 'BOX', 'PAL', V_PRFM_QTY);
            V_BOX_QTY := FN_CHG_UNIT(P_MATNR, P_WERKS, 'BOX', 'BOX', V_PRFM_QTY);
            V_BAG_QTY := FN_CHG_UNIT(P_MATNR, P_WERKS, 'BOX', 'BAG', V_PRFM_QTY);
            V_EA_QTY := FN_CHG_UNIT(P_MATNR, P_WERKS, 'BOX', 'EA', V_PRFM_QTY);
            V_WGT := FN_CHG_UNIT(P_MATNR, P_WERKS, 'BOX', 'KG', V_PRFM_QTY);
            V_ROLLCNT := FN_CHG_UNIT(P_MATNR, P_WERKS, 'BOX', 'M', V_PRFM_QTY);
            --가동시간 확인
            --V_RUNTIME := CEIL((V_DATE - V_WRK_STR_DATE) * 24 * 60);
             --YSH 20221208
            SELECT TRUNC((TO_DATE(TO_CHAR(V_DATE,'YYYY-MM-DD HH24:MI'), 'YYYY-MM-DD HH24:MI:SS') - TO_DATE(TO_CHAR(V_WRK_STR_DATE, 'YYYY-MM-DD HH24:MI'), 'YYYY-MM-DD HH24:MI:SS'))*1440)
                INTO V_RUNTIME
              FROM DUAL;
           --비가동 시간 처리
            --V_RUNTIME := V_RUNTIME - FN_NON_ACT_TM(V_WRK_STR_DATE, V_DATE, P_MACH_CD);
            --유통기간 확인
            IF V_DSTBT_DAYS = 0 THEN
                V_DSTBT_DDLIN := '';
            ELSE
                V_DSTBT_DDLIN := TO_CHAR(TO_DATE(V_PRFM_DT,'YYYYMMDD') + V_DSTBT_DAYS,'YYYYMMDD');
            END IF;
            
            V_STTIME_CNT := 0;
            -- 실적일자의 해당 설비 첫 실적일 경우 실적 시작일시 변경 처리
            SELECT	COUNT(*)	INTO	V_STTIME_CNT
            FROM	TB_WRK001
            WHERE	WERKS = P_WERKS
            AND		MACH_CD = P_MACH_CD
            AND		PRFM_DT = V_PRFM_DT
            AND		NVL(CNL_YN, 'N') = 'N';
            
            IF V_STTIME_CNT = 0	THEN
            	-- 시작시간
            	V_WRK_STR_DATE := TO_TIMESTAMP(TO_CHAR(SYSDATE, 'YYYYMMDD HH24') || ':00:00.000');
            
            	-- 가동시간(분)
	            SELECT TRUNC((TO_DATE(TO_CHAR(V_DATE,'YYYY-MM-DD HH24:MI'), 'YYYY-MM-DD HH24:MI:SS') - TO_DATE(TO_CHAR(V_WRK_STR_DATE, 'YYYY-MM-DD HH24:MI'), 'YYYY-MM-DD HH24:MI:SS'))*1440)
	                INTO V_RUNTIME
	              FROM DUAL;
            END IF;
            
            --HL 생산실적 등록
            INSERT INTO TB_WRK001 (WERKS, MACH_CD, IND_BCD, LOT_NO, MATNR,
                                    ORDER_NO, ORDER_SEQNO, WRK_ORDR_NO, WRK_ORDR_SEQNO,
                                    PRFM_QTY, UNIT, PLT_QTY, BOX_QTY, BAG_QTY, EA_QTY, WGT, ROLLCNT,
                                    PRFM_DT, PRD_DT, DSTBT_DDLIN, WRK_CLASS, CHK_PP_YN,
                                    PRD_STR_DATE, PRD_END_DATE, TM, STA,
                                    COMP_YN, REGDATE, REGID)
                           VALUES(P_WERKS, P_MACH_CD, V_IND_BCD, V_LOT_NO, P_MATNR,
                                    P_ORDER_NO, V_ORDER_SEQNO, P_WRK_ORDR_NO,P_WRK_ORDR_SEQNO,
                                    V_REG_QTY, V_UNIT, V_PLT_QTY, V_BOX_QTY, V_BAG_QTY, V_EA_QTY, V_WGT, V_ROLLCNT,
                                    V_PRFM_DT, V_PRD_DT, V_DSTBT_DDLIN, V_WRK_CLASS, 'N',
                                    V_WRK_STR_DATE, V_DATE, V_RUNTIME, '00',
                                    P_COMP_YN, V_DATE, P_USERID);
            --실적수량 재고등록
            INSERT INTO TB_INV001 (WERKS, STOR_LOC_CD, 
                                    MATNR, LOT_NO, IND_BCD, UNIT, MACH_CD, MACHINE,
                                    WRK_ORDR_NO, WRK_ORDR_SEQNO, ORDER_NO,
                                    PRD_DT, PRFM_DT, STCK_QTY, PLT_QTY, BOX_QTY, BAG_QTY, EA_QTY, WGT, ROLLCNT, STCK_STA,
                                    REGDATE, REGID)
                            VALUES(P_WERKS, V_LOC_CD,
                                    P_MATNR, V_LOT_NO, V_IND_BCD, V_UNIT, P_MACH_CD, V_MACHINE,
                                    P_WRK_ORDR_NO, P_WRK_ORDR_SEQNO, P_ORDER_NO,
                                    V_PRFM_DT, V_PRFM_DT, V_REG_QTY, V_PLT_QTY, V_BOX_QTY, V_BAG_QTY, V_EA_QTY, V_WGT, V_ROLLCNT, '00',
                                    V_DATE, P_USERID);
            --생산수량정보 작업지시에 저장(제품의 기준단위인 BAG으로 저장?)
            UPDATE TB_SCH014
               SET PRFM_QTY = NVL(PRFM_QTY,0) + NVL(V_REG_QTY,0)
                 , PRD_LAST_DATE = V_DATE
                 , UPDDATE = V_DATE
                 , UPDID = P_USERID
             WHERE 1=1
               AND WRK_ORDR_NO = P_WRK_ORDR_NO
               AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO;
            --작업자 현황 정보추가
            UPDATE TB_WRK013
               SET PRFM_DT = V_PRFM_DT
             WHERE 1=1
               AND WERKS = P_WERKS
               AND MACH_CD = P_MACH_CD
               AND IN_OUT != 'O'
               AND END_DATE IS NULL;   

            --가용수량 확인
            SP_REG_LOT_LOG_S01 (P_WERKS, P_MACH_CD, P_MATNR, P_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_REG_QTY, 1, V_ERR_LIST);
            IF LENGTH(V_ERR_LIST) > 0 THEN
                ROLLBACK;
                RS_CODE := 'N';
                RS_MSG  := V_ERR_LIST;
                RETURN;
            END IF;
            --LOT추적정보 등록
            --자재 소요량 SAP전송 문서번호 반환
            SP_REG_LOT_LOG_I01 (P_WERKS, P_MACH_CD, P_MATNR, V_LOT_NO, V_IND_BCD, P_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_PRFM_DT, V_REG_QTY, V_UNIT, 'N', 1, P_USERID, RS_CODE, RS_MSG);
            IF RS_CODE = 'E' THEN
                ROLLBACK;
                RS_CODE := 'E';
                RS_MSG  := RS_MSG;
                RETURN;
            END IF;

           --기저귀 실적등록시 생리대와 동일하도록 수정 2022-09-22
           /*
            --인터페이스 처리(실적전송)
            V_DOC_PRFM := FN_GET_MDOCNO('M','IF133');
            --지시정보 조회
            SELECT COMP_YN
              INTO V_ORDR_COMP
              FROM TB_SCH014
             WHERE 1=1
               AND WERKS = P_WERKS
               AND WRK_ORDR_NO = P_WRK_ORDR_NO
               AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO;
            --기저귀 실적
            INSERT INTO TB_IFS011(AUFNR, LOTNO, MATNR, WERKS, WORKCENTERCODE, MACHINE, 
                                WORKGROUP, OPNAM, BUDAT, PROQTY, MEINS, RUNTIME,
                                SDATE, STIME, EDATE, ETIME, 
                                MDOCNO, MDOCSEQ, MAKE_DATE, MAKER)
                            VALUES(P_ORDER_NO, V_LOT_NO, P_MATNR, P_WERKS, V_SAP_WRK_CD, V_MACHINE, 
                                V_WRK_CLASS, P_USERID, FN_DT_FORMAT(V_PRFM_DT,'YYYYMMDD'), V_REG_QTY, V_UNIT, V_RUNTIME, 
                                TO_CHAR(V_WRK_STR_DATE,'YYYYMMDD'), TO_CHAR(V_WRK_STR_DATE,'HH24MISS'), 
                                TO_CHAR(V_DATE,'YYYYMMDD'), TO_CHAR(V_DATE,'HH24MISS'),
                                V_DOC_PRFM, V_DOC_SEQ, V_DATE, P_USERID);
            --IF 전송이력(1:실적)
            INSERT INTO TB_WRK021(DOC_NO, DOC_SEQNO, DOC_DIV,
                                WERKS, MACH_CD, WRK_ORDR_NO, WRK_ORDR_SEQNO,
                                IND_BCD, LOT_NO, ORDER_NO, CNL_YN,
                                REGDATE, REGID)
                            VALUES(V_DOC_PRFM, V_DOC_SEQ, 1,
                                P_WERKS, P_MACH_CD, P_WRK_ORDR_NO, V_WRK_ORDR_SEQNO,
                                V_IND_BCD, V_LOT_NO, P_ORDER_NO, 'N',
                                V_DATE, P_USERID); 
            --실적 정보에 문서정보 추가
            UPDATE TB_WRK001
               SET DOC_NO = V_DOC_PRFM
                 , DOC_SEQNO = V_DOC_SEQ
                 , COMP_YN = P_COMP_YN
             WHERE 1=1
               AND WERKS = P_WERKS
               AND MACH_CD = P_MACH_CD
               AND IND_BCD = V_IND_BCD;
            --재고 정보에 문서정보 추가
            UPDATE TB_INV001
               SET DOC_NO = V_DOC_PRFM
                 , DOC_SEQNO = V_DOC_SEQ
             WHERE 1=1
               AND WERKS = P_WERKS
               AND MATNR = P_MATNR
               AND IND_BCD = V_IND_BCD;
            --오더 완료 확인
            IF P_COMP_YN = 'Y' THEN
                --작업지시가 이미 완료된 경우 IF처리
                IF V_ORDR_COMP = 'Y' THEN
                    --실적 전송시 시간구분 추가
                    V_DATE := V_DATE + (INTERVAL '1' SECOND);
                    --오더 완료 실적 문서번호 생성
                    V_DOC_ORDR := FN_GET_MDOCNO('M','IF133');
                    INSERT INTO TB_IFS011(AUFNR, LOTNO, MATNR, WERKS, WORKCENTERCODE, MACHINE, 
                                          WORKGROUP, OPNAM, BUDAT, PROQTY, MEINS, RUNTIME, CONF,
                                          SDATE, STIME, EDATE, ETIME, 
                                          MDOCNO, MDOCSEQ, MAKE_DATE, MAKER)
                               VALUES(P_ORDER_NO, V_LOT_NO, P_MATNR, P_WERKS, V_SAP_WRK_CD, V_MACHINE, 
                                        V_WRK_CLASS, P_USERID, FN_DT_FORMAT(V_PRFM_DT,'YYYYMMDD'), 0, V_UNIT, V_RUNTIME, 'X',
                                        TO_CHAR(V_DATE,'YYYYMMDD'), TO_CHAR(V_DATE,'HH24MISS'), 
                                        TO_CHAR(V_DATE,'YYYYMMDD'), TO_CHAR(V_DATE,'HH24MISS'),
                                        V_DOC_ORDR, V_DOC_SEQ, V_DATE, P_USERID);
                    --IF 전송이력(20:오더 완료)
                    INSERT INTO TB_WRK021(DOC_NO, DOC_SEQNO, DOC_DIV,
                                          WERKS, MACH_CD, WRK_ORDR_NO, WRK_ORDR_SEQNO,
                                          IND_BCD, LOT_NO, ORDER_NO, CNL_YN,
                                          REGDATE, REGID)
                                    VALUES(V_DOC_ORDR, V_DOC_SEQ, 20,
                                          P_WERKS, P_MACH_CD, P_WRK_ORDR_NO, V_WRK_ORDR_SEQNO,
                                          V_IND_BCD, V_LOT_NO, P_ORDER_NO, 'N',
                                          V_DATE, P_USERID);   
                END IF;
            END IF;
			*/
            --라벨출력정보 반환   
            OPEN CUR_1 FOR
            SELECT V_PRFM_DT AS PRFM_DT --실적일자
             , V_MACH_NM AS MACH_NM --설비명
             , CASE WHEN P_WERKS = 'P200' THEN '화장지'
                    WHEN P_WERKS = 'P300' THEN '생리대'
                    WHEN P_WERKS = 'P500' THEN '기저귀'
                    END AS WERKS_NM         --제품종류
            , FN_CD_VAL('PART_DIV', V_PART_DIV) AS MATNR_DIV_NM
            , P_MATNR AS MATNR
            , V_MATNR_NM AS MATNR_NM
            , V_KAN_CD AS KAN_CD         --KAN코드
            , FN_CHG_UNIT(P_MATNR, P_WERKS, 'BAG', 'EA', 1) || 'x' 
                || FN_CHG_UNIT(P_MATNR, P_WERKS, 'BOX', 'BAG', 1) AS BAG2BOX
            , FN_CHG_UNIT(P_MATNR, P_WERKS, 'PAL', 'BOX', 1) AS BOX2PLT
            , V_LOT_NO AS LOT_NO
            , V_IND_BCD AS IND_BCD
            , V_BOX_QTY AS PRFM_QTY
            FROM dual;
			
           --기저귀 실적등록시 생리대와 동일하도록 수정 2022-09-22
           /*
            --실적 등록
            SELECT RFCFN
              INTO P_PRFM_FUNC
              FROM TB_ITFMA
             WHERE 1=1
               AND IFID = V_IF_ID;
            --인터페이스 파라미터
            OPEN CUR_2 FOR
            SELECT V_IF_ID AS I_IF_ID
                 , 'M' || LTRIM(RTRIM(TO_CHAR(SEQ_GET_IFR_KEY.NEXTVAL, '00000000000000000000000000000'))) AS I_IF_KEY
            FROM dual;
            --인터페이스 상세 파라미터
            V_SQL := FN_IF_QUERY(V_IF_ID, V_DOC_PRFM);
            OPEN CUR_3 FOR V_SQL;

            --오더완료 실적
            IF V_DOC_ORDR IS NOT NULL THEN
                OPEN CUR_4 FOR
                SELECT V_IF_ID AS I_IF_ID
                     , 'M' || LTRIM(RTRIM(TO_CHAR(SEQ_GET_IFR_KEY.NEXTVAL, '00000000000000000000000000000'))) AS I_IF_KEY
                FROM dual;
                --인터페이스 상세 파라미터
                V_SQL := FN_IF_QUERY(V_IF_ID, V_DOC_ORDR);
                OPEN CUR_5 FOR V_SQL;
            END IF;
			*/
           
            --작업 정상 종료 코드 등록
            RS_CODE := 'S';
            --RFC 미사용 항목에 대하여 기본값 등록
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
        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);

        RS_CODE := 'E';
        RS_MSG  := SQLERRM;
        RETURN;
    --예외처리 종료
    END;
END SP_POP_WRK18_I01;
/
