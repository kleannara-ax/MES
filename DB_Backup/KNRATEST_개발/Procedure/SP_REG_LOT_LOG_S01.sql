--------------------------------------------------------
--  DDL for Procedure SP_REG_LOT_LOG_S01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_REG_LOT_LOG_S01" 
(
    P_WERKS             IN VARCHAR2         --플랜트
    ,P_MACH_CD          IN VARCHAR2         --설비코드
    ,P_MATNR            IN VARCHAR2         --자재코드(모품목)
    ,P_WRK_ORDR_NO      IN VARCHAR2         --지시번호
    ,P_WRK_ORDR_SEQNO   IN NUMBER           --지시순번
    ,P_PRFM_QTY         IN NUMBER           --실적수량
    ,P_USE_TYPE         IN NUMBER DEFAULT 1 --사용자재 구분(1:전체, 2:반제품, 3:그외)
    ,P_ERR_LIST         OUT VARCHAR2        --문제제품목록
)
/*==============================================================================
 * PROGRAM ID    : 
 * PROGRAM NAME  : ㅣLOT 추적
 * VERSION       : 1.0.0
 * DESCRIPTION   : 실적등록시 LOT의 사용수량을 확인한다.
 *                 
 * AUTHOR NAME   : 김기연
 * CREATE DATE   : 2022/06/13
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
    V_PRG_NM            VARCHAR2(100)  := 'SP_REG_LOT_LOG_S01';
    V_PLT_CD            VARCHAR2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID      VARCHAR2(20) := '';
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER    EXCEPTION;
    E_SQL_ERR_CD        NUMBER(5) := 0;
    E_SQL_ERR_MSG       VARCHAR2(4000);
    --내부변수 처리
    V_DATE      DATE := SYSDATE;
    V_UNIT      VARCHAR2(10); --자재 단위
    V_TEMP_QTY  NUMBER(16,3); --수량 실시간 관리
    V_STCK_QTY  NUMBER(16,3); --자재 재고량
    V_ORDR_QTY  NUMBER(13,3); --지시 수량
    V_MATNR_DIV VARCHAR2(4) := 'HALB'; --자재 타입
    V_PROC		VARCHAR(4) := 'N'; --공정구분
    V_BOM_DIV	VARCHAR2(4); --BOM 자재 타입
    --커서처리
    CURSOR BOM_CUR IS SELECT S020.MATNR, S020.ORDER_ITM_NO, S020.ORDER_BOM_QTY, S020.UNIT
                        FROM TB_SCH020 S020, TB_MAS001 M001
                       WHERE 1=1
                         AND S020.WERKS = M001.WERKS
                         AND S020.MATNR = M001.MATNR
                         AND S020.WERKS = P_WERKS
                         AND S020.WRK_ORDR_NO = P_WRK_ORDR_NO
                         AND S020.WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
                         AND (P_USE_TYPE = 1 
                                OR (P_USE_TYPE = 2 AND M001.MATNR_DIV = V_MATNR_DIV)
                                OR (P_USE_TYPE = 3 AND M001.MATNR_DIV != V_MATNR_DIV));
    V_MATNR		TB_MAS001.MATNR%TYPE; --자재코드
    V_MATNR_NM	TB_MAS001.MATNR_NM%TYPE; --자재명
    V_ITEM_SEQ	VARCHAR(10); --자재순번
    V_BOM_QTY	NUMBER(16,3); --예정수량
    V_BOM_UNIT	VARCHAR(3); --BOM단위
BEGIN
    --예외처리 시작(try)
    BEGIN
        --BOM수량에 따른 사용비율 조회 ->BOM 수량을 조회하여 개별처리
        --합지기
        IF SUBSTR(P_MACH_CD,1,3) = 'TAA' THEN
            SELECT WRK_ORDR_QTY INTO V_ORDR_QTY
              FROM TB_SCH011
             WHERE 1=1
               AND MATNR = P_MATNR
               AND WRK_ORDR_NO = P_WRK_ORDR_NO
               AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO;
            V_PROC := 'AA';
        --화장지
        ELSIF SUBSTR(P_MACH_CD,1,3) = 'TRA' THEN
            SELECT WRK_ORDR_QTY INTO V_ORDR_QTY
              FROM TB_SCH012
             WHERE 1=1
               AND MATNR = P_MATNR
               AND WRK_ORDR_NO = P_WRK_ORDR_NO
               AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO;
            V_PROC := 'RA';
        --생리대
        ELSIF SUBSTR(P_MACH_CD,1,3) = 'SRB' THEN
            SELECT WRK_ORDR_QTY INTO V_ORDR_QTY
              FROM TB_SCH013
             WHERE 1=1
               AND MATNR = P_MATNR
               AND WRK_ORDR_NO = P_WRK_ORDR_NO
               AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO;
            V_PROC := 'RB';
        --기저귀
        ELSIF SUBSTR(P_MACH_CD,1,3) = 'BRC' THEN
            SELECT WRK_ORDR_QTY INTO V_ORDR_QTY
              FROM TB_SCH014
             WHERE 1=1
               AND MATNR = P_MATNR
               AND WRK_ORDR_NO = P_WRK_ORDR_NO
               AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO;
            V_PROC := 'RC';
        --점보롤
        ELSIF SUBSTR(P_MACH_CD,1,3) = 'PJA' THEN
            SELECT WRK_ORDR_QTY INTO V_ORDR_QTY
              FROM TB_SCH015
             WHERE 1=1
               AND MATNR = P_MATNR
               AND WRK_ORDR_NO = P_WRK_ORDR_NO
               AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO;
        --리와인더/슬리터
        ELSIF SUBSTR(P_MACH_CD,1,3) = 'PMA' OR SUBSTR(P_MACH_CD,1,3) = 'PSA' THEN
            SELECT WRK_ORDR_QTY INTO V_ORDR_QTY
              FROM TB_SCH016
             WHERE 1=1
               AND MATNR = P_MATNR
               AND WRK_ORDR_NO = P_WRK_ORDR_NO
               AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO;
        --재단/수재단
        ELSIF SUBSTR(P_MACH_CD,1,3) = 'PCA' OR SUBSTR(P_MACH_CD,1,3) = 'PCB' THEN
            SELECT WRK_ORDR_QTY INTO V_ORDR_QTY
              FROM TB_SCH017
             WHERE 1=1
               AND MATNR = P_MATNR
               AND WRK_ORDR_NO = P_WRK_ORDR_NO
               AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO;
        --포장
        ELSIF SUBSTR(P_MACH_CD,1,3) = 'PBB' OR SUBSTR(P_MACH_CD,1,3) = 'PBC'THEN
            SELECT WRK_ORDR_QTY INTO V_ORDR_QTY
              FROM TB_SCH018
             WHERE 1=1
               AND MATNR = P_MATNR
               AND WRK_ORDR_NO = P_WRK_ORDR_NO
               AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO;
        --예외생산
        ELSE
            SELECT WRK_ORDR_QTY INTO V_ORDR_QTY
              FROM TB_SCH019
             WHERE 1=1
               AND MATNR = P_MATNR
               AND WRK_ORDR_NO = P_WRK_ORDR_NO
               AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO;
        END IF;

        --BOM별 투입자재 사용처리
        OPEN BOM_CUR;
        LOOP
            --커서 데이터 호출
            FETCH BOM_CUR INTO V_MATNR, V_ITEM_SEQ, V_BOM_QTY, V_BOM_UNIT;
        --완료시 탈출
        EXIT WHEN BOM_CUR %NOTFOUND;
            --실적 수량에 따른 사용 예정량 
            V_TEMP_QTY := V_BOM_QTY * (P_PRFM_QTY / V_ORDR_QTY);
            --자재정보 조회
            SELECT MATNR_NM, MATNR_DIV
              INTO V_MATNR_NM, V_BOM_DIV
              FROM TB_MAS001
             WHERE 1=1
               AND WERKS = P_WERKS
               AND MATNR = V_MATNR;
            --투입 자재 정보 조회 확인
            BEGIN
                SELECT MAX(UNIT)
                  INTO V_UNIT
                  FROM TB_INV003
                 WHERE 1=1
                   AND WERKS = P_WERKS
                   AND MACH_CD = P_MACH_CD
                   AND MATNR = V_MATNR
                   AND STCK_QTY > 0;
            EXCEPTION WHEN NO_DATA_FOUND THEN
            	--화장지 반제품 인 경우 필수 처리
            	IF P_WERKS = 'P200' AND V_PROC = 'RA' AND V_BOM_DIV = V_MATNR_DIV THEN
            		IF NVL(LENGTH(P_ERR_LIST),0) = 0 THEN
	                    P_ERR_LIST := V_MATNR || ':' || V_MATNR_NM || '\n소요량:' || TO_CHAR(V_TEMP_QTY) || '재고량:0';
	                ELSE
	                    P_ERR_LIST := P_ERR_LIST || ',' || V_MATNR || ':' || V_MATNR_NM || '\n소요량:' || TO_CHAR(V_TEMP_QTY) || '재고량:0';
	                END IF;
            	ELSE
	                --투입된 자재가 없는 경우 소진과정 무시
	                CONTINUE;
                END IF;    
            END;
            --조회된 항목이 없거나 단위정보가 없는 경우
            IF V_UNIT IS NULL THEN
                --화장지 반제품 인 경우 필수 처리
            	IF P_WERKS = 'P200' AND V_PROC = 'RA' AND V_BOM_DIV = V_MATNR_DIV THEN
            		IF NVL(LENGTH(P_ERR_LIST),0) = 0 THEN
	                    P_ERR_LIST := V_MATNR || ':' || V_MATNR_NM || '\n소요량:' || TO_CHAR(V_TEMP_QTY) || '재고량:0';
	                ELSE
	                    P_ERR_LIST := P_ERR_LIST || ',' || V_MATNR || ':' || V_MATNR_NM || '\n소요량:' || TO_CHAR(V_TEMP_QTY) || '재고량:0';
	                END IF;
            	ELSE
	                --투입된 자재가 없는 경우 소진과정 무시
	                CONTINUE;
                END IF;    
            ELSE
	            --수량 조회
	            SELECT NVL(SUM(STCK_QTY),0)
	              INTO V_STCK_QTY
	              FROM TB_INV003
	             WHERE 1=1
	               AND WERKS = P_WERKS
	               AND MACH_CD = P_MACH_CD
	               AND MATNR = V_MATNR
	             GROUP BY WERKS, MACH_CD, MATNR;
	            --BOM 수량을 재고의 단위로 변환
	            V_TEMP_QTY := FN_CHG_UNIT(V_MATNR, P_WERKS, V_BOM_UNIT, V_UNIT, V_TEMP_QTY);
	            --수량 비교
	            IF V_TEMP_QTY > V_STCK_QTY THEN
	                IF NVL(LENGTH(P_ERR_LIST),0) = 0 THEN
	                    P_ERR_LIST := V_MATNR || ':' || V_MATNR_NM || '\n소요량:' || TO_CHAR(V_TEMP_QTY) || '재고량:' || TO_CHAR(V_STCK_QTY);
	                ELSE
	                    P_ERR_LIST := P_ERR_LIST || ',' || V_MATNR || ':' || V_MATNR_NM || '\n소요량:' || TO_CHAR(V_TEMP_QTY) || '재고량:' || TO_CHAR(V_STCK_QTY);
	                END IF;
	            END IF;
            END IF;
        END LOOP;
        CLOSE BOM_CUR;

        IF LENGTH(P_ERR_LIST) > 0 THEN
            ROLLBACK;
        END IF;

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
