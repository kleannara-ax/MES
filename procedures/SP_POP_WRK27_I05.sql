
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK27_I05" 
(
     P_WERKS            IN VARCHAR2         --플랜트
    ,P_MACH_CD          IN VARCHAR2         --설비코드
    ,P_MATNR            IN VARCHAR2         --자재코드(모품목)
    ,P_LOT_NO           IN VARCHAR2         --LOT번호(모품목)
    ,P_IND_BCD          IN VARCHAR2         --개별바코드(모품목)
    ,P_WRK_ORDR_NO      IN VARCHAR2         --지시번호
    ,P_WRK_ORDR_SEQNO   IN NUMBER           --지시순번
    ,P_PRFM_DT          IN VARCHAR2         --실적일자
    ,P_PRFM_QTY         IN NUMBER           --실적수량
    ,P_PRFM_UNIT        IN VARCHAR2         --실적단위
    ,P_CHG_FLG          IN VARCHAR2         --대체여부
    ,P_USE_TYPE         IN NUMBER DEFAULT 1 --사용자재 구분(1:실적등록, 3:폐품등록)
    ,P_USERID           IN VARCHAR2         --작업자
    ,P_RS_CODE          OUT VARCHAR2        --성공여부
    ,P_RS_MSG           OUT VARCHAR2        --결과메세지
)
/*==============================================================================
 * PROGRAM ID    : 
 * PROGRAM NAME  : ㅣLOT 추적
 * VERSION       : 1.0.0
 * DESCRIPTION   : 포장 지 투입자재등록.
 *                 
 * AUTHOR NAME   : 김기연
 * CREATE DATE   : 2022/05/28
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/05/23    1.0.0   김병무         Initial Version 
 *==============================================================================
 *  관련 테이블
 * - [TB_INV003] : (C...) 자재투입 (TB_INV001에 있는 반제품을 투입)
 * - [TB_INV001] : (.RU.) 창고별 재고 관리
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM            VARCHAR2(100)  := 'SP_POP_WRK27_I05';
    V_PLT_CD            VARCHAR2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID      VARCHAR2(20) := P_USERID;
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER    EXCEPTION;
    E_SQL_ERR_CD        NUMBER(5) := 0;
    E_SQL_ERR_MSG       VARCHAR2(4000);
    --내부변수 처리
    V_DATE              DATE := SYSDATE;
    V_SEQNO_REG         NUMBER; --등록 이력 순번
    V_STCK_UNIT         VARCHAR2(10); --자재 단위
    V_ORDR_UNIT         VARCHAR2(10); --지시 단위
    V_STD_UNIT          VARCHAR2(10); --기본단위
    V_TEMP_QTY          NUMBER(16,3); --수량 실시간 관리
    V_TEMP_LOT          VARCHAR2(10); --사용될 LOT
    V_TEMP_BCD          VARCHAR2(20); --사용될 개별바코드
    V_SUB_ORDR_NO       VARCHAR2(20); --사용될 자재 작업지시
    V_SUB_ORDR_SEQNO    NUMBER; --사용될 자재 작업지시 순번
    V_INP_DT            VARCHAR2(10); --자재 투입 일자
    V_SEQNO             NUMBER; --사용될 자재의 투입순번
    V_PRFM_QTY          NUMBER(13,3); --실적 수량
    V_STCK_QTY          NUMBER(16,3); --자재 재고량
    V_USE_CALC          NUMBER(16,3); --자재 사용량
    V_USE_STD           NUMBER(16,3); --자재 사용량(기준단위)
    V_ROLL_QTY          NUMBER(13,3); --권치수
    V_WGT_QTY           NUMBER(13,3); --중량
    V_ORDER_NO          VARCHAR2(10); --생산오더
    V_ORDR_QTY          NUMBER(13,3); --지시 수량
    V_MATNR_DIV         VARCHAR2(4) := 'HALB'; --자재 타입
    V_TEMP_DIV          VARCHAR2(4); --투입자재 타입
    V_MATNR_LOC         VARCHAR(4); --자재저장위치
    V_SAP_WRK_CD        VARCHAR(20); --SAP 작업장 코드
    V_DOC_NO            VARCHAR(30); --사용량 IF 문서번호
    V_DOC_SEQ           VARCHAR(6) := '1'; --사용량 IF 문서번호
    --커서처리
    CURSOR BOM_CUR IS SELECT S020.MATNR            --자품목자재
                           , S020.ORDER_ITM_NO     --오더Item번호 
                           , S020.ORDER_BOM_QTY    --오더BOM 수량 
                           , S020.UNIT             --오더BOM 수량단위 
                        FROM TB_SCH020 S020, TB_MAS001 M001
                       WHERE 1=1
                         AND S020.WERKS = M001.WERKS
                         AND S020.MATNR = M001.MATNR
                         AND S020.WERKS = P_WERKS
                         AND S020.WRK_ORDR_NO = P_WRK_ORDR_NO
                         AND S020.WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
	                     AND M001.MATNR_DIV != 'HALB'   --반제품(깨끗한나라)
                         ;
                         
    V_MATNR             VARCHAR(20); --자재코드
    V_ITEM_SEQ          VARCHAR(10); --자재순번
    V_BOM_QTY           NUMBER(16,3); --예정수량
    V_BOM_UNIT          VARCHAR(3); --BOM단위
BEGIN
    --예외처리 시작(try)
    BEGIN
        P_RS_CODE := 'S';
        P_RS_MSG := '';

        --BOM수량에 따른 사용비율 조회 ->BOM 수량을 조회하여 개별처리
          --IF SUBSTR(P_MACH_CD,1,3) = 'PPB' OR SUBSTR(P_MACH_CD,1,3) = 'PPC'THEN
        IF SUBSTR(P_MACH_CD,1,3) = 'PPB' THEN   -- 자동포장

            SELECT WRK_ORDR_QTY, ORDER_NO, UNIT
              INTO V_ORDR_QTY, V_ORDER_NO, V_ORDR_UNIT
              FROM TB_SCH018  -- 포장 작업지시
             WHERE 1=1
               AND MATNR = P_MATNR
               AND WRK_ORDR_NO    = P_WRK_ORDR_NO
               AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO;
        --예외생산

        ELSE
--            SELECT WRK_ORDR_QTY, ORDER_NO, UNIT
--              INTO V_ORDR_QTY, V_ORDER_NO, V_ORDR_UNIT
--              FROM TB_SCH019
--             WHERE 1=1
--               AND MATNR = P_MATNR
--               AND WRK_ORDR_NO = P_WRK_ORDR_NO
--               AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO;
            
            RETURN;                           
        END IF;

        --기존정보 확인(순번 조회)
        BEGIN
            SELECT NVL(MAX(SEQNO),0) + 1 INTO V_SEQNO_REG
              FROM TB_INV010
             WHERE 1=1
               AND WERKS = P_WERKS
               AND MACH_CD = P_MACH_CD
               AND MATNR = P_MATNR
               AND IND_BCD = P_IND_BCD
               AND WRK_ORDR_NO = P_WRK_ORDR_NO
               AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
               AND NVL(CNL_YN,'N') = 'N'
               ;
        EXCEPTION WHEN NO_DATA_FOUND THEN
            V_SEQNO_REG := 1;
        END;
        
        --설비정보 확인
        BEGIN
            SELECT SAP_WRK_CD
              INTO V_SAP_WRK_CD
              FROM TB_MAS012
             WHERE 1=1
               AND MACH_CD = P_MACH_CD;
        EXCEPTION WHEN NO_DATA_FOUND THEN
            V_SAP_WRK_CD := P_MACH_CD;
        END;

        --BOM별 투입자재 사용처리
        OPEN BOM_CUR;
        LOOP
            --커서 데이터 호출
            FETCH BOM_CUR INTO V_MATNR, V_ITEM_SEQ, V_BOM_QTY, V_BOM_UNIT;
            dbms_output.put_line('bom list ok');
        --완료시 탈출
           EXIT WHEN BOM_CUR %NOTFOUND;
            --실적 수량에 따른 사용 예정량 
            V_PRFM_QTY := FN_CHG_UNIT(P_MATNR, P_WERKS, P_PRFM_UNIT, V_ORDR_UNIT, P_PRFM_QTY);
            V_TEMP_QTY := V_BOM_QTY * (V_PRFM_QTY / V_ORDR_QTY);
            --예정량 순차적 사용처리
            WHILE(V_TEMP_QTY > 0)
            LOOP
                --수량이 남은 투입자재 조회(순번으로 비교하여 사용)
                SELECT NVL(MIN(SEQNO),-1) INTO V_SEQNO
                  FROM TB_INV003
                 WHERE 1=1
                   AND WERKS = P_WERKS
                   AND MACH_CD = P_MACH_CD
                   AND MATNR = V_MATNR
                   AND WRK_ORDR_NO = P_WRK_ORDR_NO
               	   AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
                   AND STCK_QTY > 0;

                --남은 투입재고가 없는 경우 마지막 순번을 초과사용
                IF V_SEQNO < 0 THEN
                    --수량 부족시 마지막 항목 음수 처리
                    SELECT NVL(MAX(SEQNO),-1) INTO V_SEQNO
                      FROM TB_INV003
                     WHERE 1=1
                       AND WERKS = P_WERKS
                       AND MACH_CD = P_MACH_CD
                       AND MATNR = V_MATNR;
                END IF;

                --투입 자재 정보 조회 확인
                BEGIN
                    SELECT IND_BCD, NVL(STCK_QTY,0), UNIT, INP_DT, LOT_NO
                      INTO V_TEMP_BCD, V_STCK_QTY, V_STCK_UNIT, V_INP_DT, V_TEMP_LOT
                      FROM TB_INV003
                     WHERE 1=1
                       AND WERKS = P_WERKS
                       AND MACH_CD = P_MACH_CD
                       AND MATNR = V_MATNR
                       AND SEQNO = V_SEQNO;
                EXCEPTION 
                    WHEN NO_DATA_FOUND THEN
                        --투입된 자재가 없는 경우 소진과정 무시
                        EXIT;
                    WHEN TOO_MANY_ROWS THEN
                        RAISE_APPLICATION_ERROR(-20000, V_MATNR || '품목에 동일한 순번이 존재합니다.');  
                        P_RS_CODE := 'E';
                        P_RS_MSG := V_MATNR || '품목에 동일한 순번이 존재합니다.';
                        RETURN;
                END;

                --투입자재 실적정보 조회
                BEGIN
                    SELECT WRK_ORDR_NO, WRK_ORDR_SEQNO
                      INTO V_SUB_ORDR_NO, V_SUB_ORDR_SEQNO
                      FROM TB_WRK002
                     WHERE 1=1
                       AND WERKS = P_WERKS
                       AND MACH_CD = P_MACH_CD
                       AND IND_BCD = V_TEMP_BCD;
                EXCEPTION WHEN NO_DATA_FOUND THEN
                    V_SUB_ORDR_NO := '';
                    V_SUB_ORDR_SEQNO := 0;
                END;

                --BOM 수량을 재고의 단위로 변환
                V_TEMP_QTY := FN_CHG_UNIT(V_MATNR, P_WERKS, V_BOM_UNIT, V_STCK_UNIT, V_TEMP_QTY);
                --자재 사용량 확정
                V_USE_CALC := CASE --자재수량이 예정량 보다 많은 경우 예정량 사용
                                   WHEN V_STCK_QTY >= V_TEMP_QTY THEN V_TEMP_QTY
                                   --자재 수량이 없는 경우 초과사용처리
                                   WHEN V_STCK_QTY = 0 THEN V_TEMP_QTY
                                   --자재 수량이 부족한 경우 자재수량 사용
                                   ELSE V_STCK_QTY END;

                --권치수 및 중량 확인
                V_ROLL_QTY := FN_CHG_UNIT(V_MATNR, P_WERKS, V_STCK_UNIT, 'RL', V_USE_CALC);
                V_WGT_QTY := FN_CHG_UNIT(V_MATNR, P_WERKS, V_STCK_UNIT, 'KG', V_USE_CALC);

                -- 투입자재 사용처리
                UPDATE TB_INV003
                   SET USE_QTY = NVL(USE_QTY,0) + V_USE_CALC
                     , STCK_QTY = NVL(STCK_QTY,0) - V_USE_CALC
                     , ROLLCNT = NVL(ROLLCNT,0) - V_ROLL_QTY
                     , WGT = NVL(WGT,0) - V_WGT_QTY
                     , UPDDATE = V_DATE
                     , UPDID = P_USERID
                 WHERE 1=1
                   AND WERKS = P_WERKS
                   AND MACH_CD = P_MACH_CD
                   AND MATNR = V_MATNR
--                   AND WRK_ORDR_NO = P_WRK_ORDR_NO
--                   AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
                   AND SEQNO = V_SEQNO;

                --사용완료 자재 목록에서 삭제
                DELETE TB_INV003
                 WHERE 1=1
                   AND WERKS = P_WERKS
                   AND MACH_CD = P_MACH_CD
                   AND MATNR = V_MATNR
                   AND STCK_QTY <= 0;

                --lot 사용이력 등록
                INSERT INTO TB_INV010 (WERKS, MACH_CD, MATNR, LOT_NO, IND_BCD,
                                        WRK_ORDR_NO, WRK_ORDR_SEQNO, SEQNO, PRFM_DT,
                                        MATNR_M, LOT_NO_M, IND_BCD_M, INP_DT, UNIT, USE_QTY, ROLLCNT, WGT,
                                        DOC_NO, DOC_SEQNO,  REGDATE, REGID, USE_DIV)
                                VALUES (P_WERKS, P_MACH_CD, P_MATNR, P_LOT_NO, P_IND_BCD,
                                        P_WRK_ORDR_NO, P_WRK_ORDR_SEQNO, V_SEQNO_REG, P_PRFM_DT,
                                        V_MATNR, V_TEMP_LOT, V_TEMP_BCD, V_INP_DT, V_STCK_UNIT, V_USE_CALC, V_ROLL_QTY, V_WGT_QTY,
                                        V_DOC_NO, V_DOC_SEQ, V_DATE, P_USERID, P_USE_TYPE);

                --LOT추적 테이블 추가
                INSERT INTO TB_WRK008 (WERKS, IND_BCD, LOT_NO, MATNR,
                                       IND_BCD_M, LOT_NO_M, MATNR_M, 
                                       UNIT, PRFM_QTY, USE_QTY, MACH_CD,
                                       WRK_ORDR_NO, WRK_ORDR_SEQNO, SUB_WRK_ORDR_NO, SUB_WRK_ORDR_SEQNO,
                                       SEQNO, REGDATE, REGID)
                                VALUES(P_WERKS, P_IND_BCD, P_LOT_NO, P_MATNR,
                                       V_TEMP_BCD, V_TEMP_LOT, V_MATNR,
                                       V_STCK_UNIT, V_PRFM_QTY, V_USE_CALC, P_MACH_CD,
                                       P_WRK_ORDR_NO, P_WRK_ORDR_SEQNO, V_SUB_ORDR_NO, V_SUB_ORDR_SEQNO,
                                       V_SEQNO_REG, V_DATE, P_USERID);
                --이력 순번 추가
                V_SEQNO_REG := V_SEQNO_REG + 1;

                --잔여 수량 처리
                --(사용예정량(자재단위) - 사용량(자재단위)) => 단위변환(자재단위 -> BOM단위)
                V_TEMP_QTY := FN_CHG_UNIT(V_MATNR, P_WERKS, V_STCK_UNIT, V_BOM_UNIT, (V_TEMP_QTY - V_USE_CALC));
            END LOOP;
        END LOOP;
        CLOSE BOM_CUR;

        P_RS_CODE := 'S';
        
    --예외처리(catch)
    EXCEPTION
    WHEN E_EXCEPTION_USER THEN
        -- 에러 내역 SET
        E_SQL_ERR_CD        := SQLCODE;
        E_SQL_ERR_MSG       := SUBSTRB(SQLERRM,1,300);

        ROLLBACK;
        SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
        RETURN;
    WHEN OTHERS THEN
        E_SQL_ERR_CD        := -20001;
        E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

        ROLLBACK;
        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
        RETURN;
    --예외처리 종료
    END;
END;
/
