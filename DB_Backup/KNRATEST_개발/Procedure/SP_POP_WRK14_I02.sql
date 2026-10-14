--------------------------------------------------------
--  DDL for Procedure SP_POP_WRK14_I02
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK14_I02" 
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
    ,P_STR_DT           IN VARCHAR2
    ,P_END_DT           IN VARCHAR2
    ,P_COMP_YN          IN VARCHAR2
    ,Lang               IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE            OUT VARCHAR2 
    ,RS_MSG             OUT VARCHAR2
    ,CUR_1              OUT SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : POP_WRK14
 * PROGRAM NAME  : 화장지 가공기 실적등록
 * VERSION       : 1.0.0
 * DESCRIPTION   : 조회된 지시의 입력된 생산정보를 처리한다.
 *                 
 * AUTHOR NAME   : 김기연
 * CREATE DATE   : 2022/10/25
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
    V_PRG_NM            VARCHAR2(100)  := 'SP_POP_WRK14_I01';     -- PROCEDURE NAME
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
    V_PRD_DT            VARCHAR2(8) := TO_CHAR(V_DATE,'YYYYMMDD'); --등록일자
    V_ORDER_SEQNO       VARCHAR2(5);
    V_WRK_CLASS         VARCHAR2(10); --작업반
    V_WRK_SHIFT         VARCHAR2(10); --작업조
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
    V_DSTBT_DDLIN       VARCHAR(10); --유통기간 일자
    V_DSTBT_DAYS        NUMBER(4); --유통기간
    V_MACHINE           VARCHAR2(5); --설비호기
    V_LOC_CD            VARCHAR2(4); --저장위치
    --V_PRD_STR_DATE      DATE; --작업지시 시작시간
    --V_WRK_STR_DATE      DATE; --실적 시작시간
    V_RUNTIME           NUMBER; --가동시간
    V_STR_DATE          DATE := TO_DATE(P_STR_DT,'YYYY-MM-DD HH24:MI:SS');
    V_END_DATE          DATE := TO_DATE(P_END_DT,'YYYY-MM-DD HH24:MI:SS');
    V_ERR_LIST          VARCHAR2(4000); --수량 부족항목목록
    V_IF_ID_USE         VARCHAR2(20) := 'MES_IF_130'; --자재소요량
    V_DOC_NO            VARCHAR2(29); --MES문서번호
    V_SQL               VARCHAR2(4000);

BEGIN
    --예외처리 시작(try)
    BEGIN
        BEGIN
            -- 지시정보 조회
            SELECT ORDER_SEQNO, USE_YN, ORDER_QTY
              INTO V_ORDER_SEQNO, V_WRK_STA, V_ORDR_QTY
              FROM TB_SCH012
             WHERE 1=1
               AND WRK_ORDR_NO = P_WRK_ORDR_NO
               AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO;

            -- 자재정보 조회
            SELECT MATNR_NM, KAN_NO, NVL(DSTBT_DDLIN,0), UNIT, LGPRO, PART_DIV
              INTO V_MATNR_NM, V_KAN_CD, V_DSTBT_DAYS, V_UNIT, V_LOC_CD, V_PART_DIV
              FROM TB_MAS001
             WHERE 1=1
               AND WERKS = P_WERKS
               AND MATNR = P_MATNR;

            -- 설비 정보 조회    
            SELECT MACH_NM, MACHINE
              INTO V_MACH_NM, V_MACHINE
              FROM TB_MAS012
             WHERE 1=1
               AND MACH_CD = P_MACH_CD;

            -- 작업반,조 정보조회
            SELECT WRK_CLASS, WRK_SHIFT
              INTO V_WRK_CLASS, V_WRK_SHIFT
              FROM TB_WRK011
             WHERE 1=1
               AND WERKS = P_WERKS
               AND MACH_CD = P_MACH_CD
               AND IN_OUT = 'O';

            -- 가공기조회
            SELECT MACH_STA
              INTO V_MACH_STA
              FROM TB_WRK011
             WHERE 1=1
               AND WERKS = P_WERKS
               AND MACH_CD = P_MACH_CD
               AND IN_OUT != 'O';

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
                   AND YYMM = SUBSTR(V_PRFM_DT, 0, 6);
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

            --실적등록 완료여부 조회
            SELECT MAX(NVL(COMP_YN,'N'))
              INTO V_ENDFLG
              FROM TB_WRK001
             WHERE 1=1
               AND WERKS = P_WERKS
               AND WRK_ORDR_NO = P_WRK_ORDR_NO
               AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
               AND NVL(CNL_YN, 'N') != 'Y' ;
            IF V_ENDFLG = 'Y' THEN
                RS_CODE := 'E';
                RS_MSG := '실적등록이 완료된 지시입니다.';
                ROLLBACK;
                RETURN;
            END IF;

            --실적 제한수량 확인
            V_REG_QTY := FN_CHG_UNIT(P_MATNR, P_WERKS, 'BOX', V_UNIT, V_PRFM_QTY);
            BEGIN
                SELECT USARG1
                  INTO V_CAP_RATE
                  FROM CMCDV
                 WHERE 1=1
                   AND CMCDKY = 'PRFMCAP'
                   AND CMCDVL = 'RA'
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

            --개별 바코드 / LOTNO 작성
            SP_GET_BARCODE_SEQ('IND', P_WERKS, P_MACH_CD, P_MATNR, TO_CHAR(V_END_DATE,'YYYY-MM-DD HH24:MI:SS'), V_IND_BCD);
            --V_IND_BCD := 'TEST_BARCODE1'; --SP_GET_BARCODE_SEQ

            --기존 Lot 조회
            SELECT NVL(LOT_NO,' ') INTO V_LOT_TEMP
              FROM TB_WRK011
             WHERE 1=1
               AND WERKS = P_WERKS
               AND MACH_CD = P_MACH_CD
               AND IN_OUT = 'O';
            SP_CHK_LOT_NO (V_LOT_TEMP, P_WERKS, P_MACH_CD, P_MATNR, TO_CHAR(V_END_DATE,'YYYY-MM-DD HH24:MI:SS'), V_LOT_NO);
            --V_LOT_NO := 'TEST_LOT1';
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

            --기준 단위 및 단위변환 등록
            V_PLT_QTY := FN_CHG_UNIT(P_MATNR, P_WERKS, 'BOX', 'PAL', V_PRFM_QTY);
            V_BOX_QTY := FN_CHG_UNIT(P_MATNR, P_WERKS, 'BOX', 'BOX', V_PRFM_QTY);
            V_BAG_QTY := FN_CHG_UNIT(P_MATNR, P_WERKS, 'BOX', 'BAG', V_PRFM_QTY);
            V_EA_QTY := FN_CHG_UNIT(P_MATNR, P_WERKS, 'BOX', 'EA', V_PRFM_QTY);
            V_WGT := FN_CHG_UNIT(P_MATNR, P_WERKS, 'BOX', 'KG', V_PRFM_QTY);
            V_ROLLCNT := FN_CHG_UNIT(P_MATNR, P_WERKS, 'BOX', 'M', V_PRFM_QTY);
            --가동시간 확인
            V_RUNTIME := ROUND((V_END_DATE - V_STR_DATE) * 24 * 60, 0);
            --비가동 시간 처리
            V_RUNTIME := V_RUNTIME - FN_NON_ACT_TM(V_STR_DATE, V_END_DATE, P_MACH_CD);
            --유통기간 확인
            IF V_DSTBT_DAYS = 0 THEN
                V_DSTBT_DDLIN := '';
            ELSE
                V_DSTBT_DDLIN := TO_CHAR(TO_DATE(V_PRFM_DT,'YYYYMMDD') + V_DSTBT_DAYS,'YYYYMMDD');
            END IF;
            --HL 생산실적 등록
            INSERT INTO TB_WRK001 (WERKS, MACH_CD, IND_BCD, LOT_NO, MATNR,
                                    ORDER_NO, ORDER_SEQNO, WRK_ORDR_NO, WRK_ORDR_SEQNO,
                                    PRFM_QTY, UNIT, PLT_QTY, BOX_QTY, BAG_QTY, EA_QTY, WGT, ROLLCNT, TM, STA,
                                    PRFM_DT, PRD_DT, DSTBT_DDLIN, WRK_CLASS, WRK_SHIFT,
                                    PRD_STR_DATE, PRD_END_DATE,
                                    COMP_YN, CHK_PP_YN, REGDATE, REGID)
                           VALUES(P_WERKS, P_MACH_CD, V_IND_BCD, V_LOT_NO, P_MATNR,
                                    P_ORDER_NO, V_ORDER_SEQNO, P_WRK_ORDR_NO,P_WRK_ORDR_SEQNO,
                                    V_REG_QTY, V_UNIT, V_PLT_QTY, V_BOX_QTY, V_BAG_QTY, V_EA_QTY, V_WGT, V_ROLLCNT, V_RUNTIME, '00',
                                    V_PRFM_DT, V_PRD_DT, V_DSTBT_DDLIN, V_WRK_CLASS, V_WRK_SHIFT,
                                    V_STR_DATE, V_END_DATE,
                                    P_COMP_YN, 'N', V_DATE, P_USERID);
            --실적수량 재고등록
            INSERT INTO TB_INV001 (WERKS, STOR_LOC_CD, 
                                    MATNR, LOT_NO, IND_BCD, UNIT, MACH_CD, MACHINE,
                                    WRK_ORDR_NO, WRK_ORDR_SEQNO, ORDER_NO,
                                    PRD_DT, PRFM_DT, STCK_QTY, PLT_QTY, BOX_QTY, BAG_QTY, EA_QTY, WGT, ROLLCNT, STCK_STA,
                                    DLFL, REGDATE, REGID)
                            VALUES(P_WERKS, V_LOC_CD,
                                    P_MATNR, V_LOT_NO, V_IND_BCD, V_UNIT, P_MACH_CD, V_MACHINE,
                                    P_WRK_ORDR_NO, P_WRK_ORDR_SEQNO, P_ORDER_NO,
                                    V_PRFM_DT, V_PRFM_DT, V_REG_QTY, V_PLT_QTY, V_BOX_QTY, V_BAG_QTY, V_EA_QTY, V_WGT, V_ROLLCNT, '00',
                                    'N', V_DATE, P_USERID);
            --생산수량정보 작업지시에 저장(제품의 기준단위수량으로 저장)
            UPDATE TB_SCH012
               SET PRFM_QTY = NVL(PRFM_QTY,0) + NVL(V_REG_QTY,0)
                 , PRD_LAST_DATE = V_END_DATE
                 , PRD_END_DTM = CASE WHEN P_COMP_YN = 'Y' THEN TO_CHAR(V_END_DATE,'YYYYMMDDHH24MISS') ELSE '' END
                 , PRD_END_DT = CASE WHEN P_COMP_YN = 'Y' THEN V_PRD_DT ELSE '' END
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
               AND IN_OUT = 'O'
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

            --작업 정상 종료 코드 등록
            RS_CODE := 'S';
        END;
    --예외처리(catch)
    EXCEPTION
    WHEN E_EXCEPTION_USER THEN
        -- 에러 내역 SET
        E_SQL_ERR_CD        := SQLCODE;
        E_SQL_ERR_MSG       := V_IND_BCD || SUBSTRB(SQLERRM,1,300);

        ROLLBACK;
        SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);

        RS_CODE := 'E';
        RS_MSG  := SQLERRM;
        RETURN;
    WHEN OTHERS THEN
        E_SQL_ERR_CD        := -20001;
        E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || V_IND_BCD || SUBSTR(SQLERRM,1,500) || ']';

        ROLLBACK;
        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);

        RS_CODE := 'E';
        RS_MSG  := SQLERRM;
        RETURN;
    --예외처리 종료
    END;
END SP_POP_WRK14_I02;

/
