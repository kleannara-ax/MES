--------------------------------------------------------
--  DDL for Procedure SP_POP_WRK86_U01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK86_U01" 
(
    P_WERKS             IN VARCHAR2 --plantcode
    ,P_WRK_ORDR_NO      IN VARCHAR2 --작업지시번호
    ,P_WRK_ORDR_SEQNO   IN VARCHAR2 --작업지시순번
    ,P_MACH_CD          IN VARCHAR2 --설비코드
    ,P_IND_BCD          IN VARCHAR2 --업체/개별바코드
    ,P_DISPO_QTY        IN VARCHAR2 --부적합 수량
    ,P_USER_ID          IN VARCHAR2 --사용자ID
    ,P_TYPE             IN VARCHAR2 --작업구분(실적등록, 재팔레트)
    ,P_PRFM_FUNC        OUT VARCHAR2 
    ,P_MOVE_FUNC        OUT VARCHAR2 
    ,Lang               IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE            OUT VARCHAR2 
    ,RS_MSG             OUT VARCHAR2
    ,CUR_1              OUT SYS_REFCURSOR
    ,CUR_2              OUT SYS_REFCURSOR
    ,CUR_3              OUT SYS_REFCURSOR
    ,CUR_4              OUT SYS_REFCURSOR
    ,CUR_5              OUT SYS_REFCURSOR
    ,CUR_6              OUT SYS_REFCURSOR
    ,CUR_7              OUT SYS_REFCURSOR
    ,CUR_8              OUT SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : SP_POP_WRK86_U01{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 부분폐품 등록
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : HL실적에서 부분폐품 등록.
 *                 
 * AUTHOR NAME   : 김기연
 * CREATE DATE   : 2022/06/02
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/05/30    1.0.0   김기연         Initial Version 
 *==============================================================================
 *  관련 테이블
 *       - [TB_INV003] : (CRUD)자재투입 -자재관리 정보
 *=============================================================================*/

AS 
    --프로그램 ID
    V_PRG_NM            VARCHAR2(100)  := 'SP_POP_WRK86_U01';     -- PROCEDURE NAME
    V_PLT_CD            VARCHAR2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID      VARCHAR2(20) := P_USER_ID; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER EXCEPTION;
    E_SQL_ERR_CD        NUMBER(5) := 0;
    E_SQL_ERR_MSG       VARCHAR2(4000);
    --parameter변수 처리
    V_IND_BCD           VARCHAR2(20) := P_IND_BCD;
    V_WRK_ORDR_SEQNO    NUMBER := TO_NUMBER(P_WRK_ORDR_SEQNO);
    --내부 변수 등록
    V_DATE              DATE := SYSDATE;
    V_ALLFLG            VARCHAR2(1); --전체폐품여부
    V_SAPFLG            VARCHAR2(1); --SAP전송여부
    V_MATNR             VARCHAR2(20);
    V_LOT_NO            VARCHAR2(10);
    V_TEMP_BCD          VARCHAR2(20);
    V_UNIT              VARCHAR2(10);
    V_ORDER_NO          VARCHAR2(10); --생산오더
    V_ORDER_SEQNO       VARCHAR2(5); --생산오더 순번
    V_MACHINE           VARCHAR2(5); --생산호기
    V_SAP_WRK_CD        VARCHAR(20); --SAP작업장코드
    V_PRFM_DT           VARCHAR2(8); --실적일자
    V_PRD_DT            VARCHAR2(8); --생산일자
    V_WRK_CLASS         VARCHAR2(10); --작업반
    V_WRK_SHIFT         VARCHAR2(10); --작업조
    V_HMACHINE          VARCHAR2(10); --합지생산호기
    V_HIND_BCD          VARCHAR(20); --합지 개별바코드
    V_HMATNR            VARCHAR(20); --합지품목
    V_HUNIT             VARCHAR(10); --합지단위
    V_HLOTNO1           VARCHAR2(10); --합지LOT1
    V_INPQT1            VARCHAR2(10); --합지수량1
    V_HLOTNO2           VARCHAR2(10); --합지LOT2
    V_INPQT2            VARCHAR2(10); --합지수량2
    V_HLOTNO3           VARCHAR2(10); --합지LOT3
    V_INPQT3            VARCHAR2(10); --합지수량3
    V_USERID            VARCHAR2(10); --작업자
    V_PRFM_QTY          NUMBER(13,3); --실적수량
    V_DISPO_QTY         NUMBER(13,3); --폐품수량
    V_PRFM_BOX          NUMBER(13,3); --실적박스수량
    V_DISPO_BOX         NUMBER(13,3); --폐품박스수량
    V_PLT_QTY           NUMBER(13,1); --PLT수량
    V_BOX_QTY           NUMBER(13,0); --BOX수량
    V_BAG_QTY           NUMBER(13,0); --BAG수량
    V_EA_QTY            NUMBER(13,0); --EA수량
    V_ROLLCNT           NUMBER(13,0); --권치수
    V_WGT               NUMBER(13,0); --중량
    V_STR_DATE          DATE; --시작일자
    V_END_DATE          DATE; --완료일자
    V_RUNTIME           VARCHAR2(8); --가동시간(분)
    V_DSTBT_DDLIN       VARCHAR2(10); --유통기간
    V_DOC_NO            VARCHAR2(20); --부적합실적 등록 문서번호
    V_DOC_NO_PRFM       VARCHAR2(20); --양품실적 등록 문서번호
    V_DOC_MOVE          VARCHAR2(20); --재고이전 문서번호
    V_DOC_SEQ           VARCHAR2(6) := '1';
    V_LOC_FROM          VARCHAR2(4) := '3100'; --제품입고전 창고
    V_LOC_TO            VARCHAR2(4) := '2020'; --불용창고
    V_MATNR_NM          VARCHAR2(1000); --자재명
    V_PART_DIV			VARCHAR2(10); --제품종류
    V_KAN_CD            VARCHAR2(18); --KAN코드
    V_MACH_NM           VARCHAR2(100); --설비명
    V_DOC_USE           VARCHAR2(29); --MES문서번호(자재 소요량)
    V_IF_ID_PRFM        VARCHAR2(20); --MES IF ID 실적등록
    V_IF_ID_MOVE        VARCHAR2(20); --자재이전
    V_SQL               VARCHAR2(4000);

BEGIN
    --예외처리 시작(try)
    BEGIN
        --실적정보 조회
        SELECT ORDER_NO, LOT_NO, MATNR, PRFM_DT, PRD_DT, WRK_CLASS, REGID
             , TM, PRD_STR_DATE, PRD_END_DATE, DSTBT_DDLIN, V_WRK_SHIFT, NVL2(SDOC_NO,'Y','N')
          INTO V_ORDER_NO, V_LOT_NO, V_MATNR, V_PRFM_DT, V_PRD_DT, V_WRK_CLASS, V_USERID
             , V_RUNTIME, V_STR_DATE, V_END_DATE, V_DSTBT_DDLIN, V_WRK_SHIFT, V_SAPFLG
          FROM TB_WRK001
         WHERE 1=1
           AND WERKS = P_WERKS
           AND MACH_CD = P_MACH_CD
           AND IND_BCD = V_IND_BCD;
        --재고정보 조회
        SELECT STCK_QTY, UNIT --, UCFMTY_AMT, PLT_QTY, BOX_QTY, BAG_QTY, EA_QTY, ROLLCNT, WGT
          INTO V_PRFM_QTY, V_UNIT--, V_DISPO_QTY, V_PLT_QTY, V_BOX_QTY, V_BAG_QTY, V_EA_QTY, V_ROLLCNT, V_WGT
          FROM TB_INV001
         WHERE 1=1
           AND WERKS = P_WERKS
           AND STOR_LOC_CD = '3100'
           AND MACH_CD = P_MACH_CD
           AND IND_BCD = V_IND_BCD;
        --부적합 수량 입력
        V_DISPO_QTY := TO_NUMBER(P_DISPO_QTY);
        --부적합 수량 적용후 잔량에 따른 구분
        V_ALLFLG := CASE WHEN V_PRFM_QTY = 0 THEN 'Y' ELSE 'N' END;
        --설비정보 조회
        SELECT MACHINE, MACH_NM, SAP_WRK_CD
          INTO V_MACHINE, V_MACH_NM, V_SAP_WRK_CD
          FROM TB_MAS012
         WHERE 1=1
           AND MACH_CD = P_MACH_CD;
        --자재정보 조회
        SELECT MATNR_NM, KAN_NO, PART_DIV
          INTO V_MATNR_NM, V_KAN_CD, V_PART_DIV
          FROM TB_MAS001
         WHERE 1=1
           AND WERKS = P_WERKS
           AND MATNR = V_MATNR;
        -- 지시정보 조회(화장지 가공기, 생리대, 기저귀)
        BEGIN
            IF P_WERKS = 'P200' THEN
                SELECT ORDER_SEQNO
                  INTO V_ORDER_SEQNO
                  FROM TB_SCH012
                 WHERE 1=1
                   AND WRK_ORDR_NO = P_WRK_ORDR_NO
                   AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO;
            ELSIF P_WERKS = 'P300' THEN
                SELECT ORDER_SEQNO
                  INTO V_ORDER_SEQNO
                  FROM TB_SCH013
                 WHERE 1=1
                   AND WRK_ORDR_NO = P_WRK_ORDR_NO
                   AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO;
            ELSIF P_WERKS = 'P500' THEN
                SELECT ORDER_SEQNO
                  INTO V_ORDER_SEQNO
                  FROM TB_SCH014
                 WHERE 1=1
                   AND WRK_ORDR_NO = P_WRK_ORDR_NO
                   AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO;
            END IF;
        EXCEPTION WHEN NO_DATA_FOUND THEN
            RS_CODE := 'E';
            RS_MSG  := '작업지시 정보를 찾을수 없습니다.\n예외생산의 경우 부분폐품의 진행이 불가능 합니다.';
            RETURN;
        END;

        --기존 실적재고 폐품처리여부 변경
        UPDATE TB_INV001
           SET UCFMTY_FLG = 'Y' 
             , UPDDATE = V_DATE
             , UPDID = P_USER_ID
        WHERE 1=1
          AND WERKS = P_WERKS
          AND MACH_CD = P_MACH_CD
          AND IND_BCD = V_IND_BCD;
        
        --폐품 등록수량
        V_PLT_QTY := FN_CHG_UNIT(V_MATNR, P_WERKS, V_UNIT, 'PAL', V_DISPO_QTY);
        V_BOX_QTY := FN_CHG_UNIT(V_MATNR, P_WERKS, V_UNIT, 'BOX', V_DISPO_QTY);
        V_BAG_QTY := FN_CHG_UNIT(V_MATNR, P_WERKS, V_UNIT, 'BAG', V_DISPO_QTY);
        V_EA_QTY := FN_CHG_UNIT(V_MATNR, P_WERKS, V_UNIT, 'EA', V_DISPO_QTY);
        V_ROLLCNT := FN_CHG_UNIT(V_MATNR, P_WERKS, V_UNIT, 'M', V_DISPO_QTY);
        V_WGT := FN_CHG_UNIT(V_MATNR, P_WERKS, V_UNIT, 'KG', V_DISPO_QTY);
        V_DISPO_BOX := V_BOX_QTY;
        
        --실적등록(전송완료) -> 폐품 수량 만큼 재고이전
        IF P_TYPE = 'A' AND V_SAPFLG = 'Y' THEN
            --재고이전  
            V_DOC_MOVE := FN_GET_MDOCNO('M','IF131');
            V_IF_ID_MOVE := 'MES_IF_131';
            INSERT INTO TB_IFS009(BWART, AUFNR, WERKS_FROM, WERKS_TO, MATNR_FROM, MATNR_TO, LGORT_FROM, LGORT_TO,
                                    CHARG_FROM, CHARG_TO, MENGE, MEINS, FAULTY, MDOCNO, MDOCSEQ, MAKE_DATE, MAKER)
                            VALUES('311', V_ORDER_NO, P_WERKS, P_WERKS, V_MATNR, V_MATNR, V_LOC_FROM, V_LOC_TO,
                                    V_LOT_NO, V_LOT_NO, V_DISPO_QTY, V_UNIT, 'Y', V_DOC_MOVE, 1, V_DATE, P_USER_ID);
            --재고이전 이력
            INSERT INTO TB_WRK017(DOC_NO, DOC_SEQNO, MOVE_DIV, WERKS_FR, MATNR_FR, MATNR_TO, STOR_LOC_FR, STOR_LOC_TO,
                                    CHARG_FR, CHARG_TO, MOVE_QTY, UNIT, UCFMTY_YN, REGDATE, REGID)
                            VALUES(V_DOC_MOVE, 1, '311', P_WERKS, V_MATNR, V_MATNR, V_LOC_FROM, V_LOC_TO,
                                    V_LOT_NO, V_LOT_NO, V_DISPO_QTY, V_UNIT, 'Y', V_DATE, P_USER_ID);
            --IF 전송이력(6:재고이전(위치))
            INSERT INTO TB_WRK021(DOC_NO, DOC_SEQNO, DOC_DIV,
                                    WERKS, MACH_CD, WRK_ORDR_NO, WRK_ORDR_SEQNO,
                                    IND_BCD, LOT_NO, ORDER_NO,
                                    REGDATE, REGID)
                            VALUES(V_DOC_MOVE, TO_NUMBER(V_DOC_SEQ), 6,
                                    P_WERKS, P_MACH_CD, P_WRK_ORDR_NO, P_WRK_ORDR_SEQNO,
                                    V_IND_BCD, V_LOT_NO, V_ORDER_NO,
                                    V_DATE, P_USER_ID);
            --실적수량 차감처리
            UPDATE TB_WRK001
               SET PRFM_QTY = PRFM_QTY - V_DISPO_QTY
                 , PLT_QTY = PLT_QTY - V_PLT_QTY
                 , BOX_QTY = BOX_QTY - V_BOX_QTY
                 , BAG_QTY = BAG_QTY - V_BAG_QTY
                 , EA_QTY = EA_QTY - V_EA_QTY
                 , ROLLCNT = ROLLCNT - V_ROLLCNT
                 , WGT = WGT -V_WGT
                 , UPDDATE = V_DATE
                 , UPDID = P_USER_ID
             WHERE 1=1
               AND WERKS = P_WERKS
               AND MACH_CD = P_MACH_CD
               AND IND_BCD = V_IND_BCD;
            --기존 재고수량 변경 및 이동
            UPDATE TB_INV001
               SET STCK_QTY = STCK_QTY - V_DISPO_QTY
                 , PLT_QTY = PLT_QTY - V_PLT_QTY
                 , BOX_QTY = BOX_QTY - V_BOX_QTY
                 , BAG_QTY = BAG_QTY - V_BAG_QTY
                 , EA_QTY = EA_QTY - V_EA_QTY
                 , ROLLCNT = ROLLCNT - V_ROLLCNT
                 , WGT = WGT -V_WGT
                 , STCK_STA = '00'
                 , UPDDATE = V_DATE
                 , UPDID = P_USER_ID
             WHERE 1=1
               AND WERKS = P_WERKS
               AND STOR_LOC_CD = '3100'
               AND MATNR = V_MATNR
               AND IND_BCD = V_IND_BCD;
            --폐품 개별 바코드
            SP_GET_BARCODE_SEQ('IND', P_WERKS, P_MACH_CD, V_MATNR, TO_CHAR(V_DATE,'YYYY-MM-DD HH24:MI:SS'), V_IND_BCD);
            --불용창고 재고등록
            INSERT INTO TB_INV001 (WERKS, STOR_LOC_CD, 
                                    MATNR, LOT_NO, IND_BCD, UNIT,
                                    MACH_CD, MACHINE, WRK_ORDR_NO, WRK_ORDR_SEQNO, ORDER_NO, DOC_NO, DOC_SEQNO, PRE_IND_BCD,
                                    PRFM_DT, PRD_DT, STCK_QTY, PLT_QTY, BOX_QTY, BAG_QTY, EA_QTY, ROLLCNT, WGT, STCK_STA,
                                    DLFL, REGDATE, REGID)
                            VALUES(P_WERKS, '2020',
                                    V_MATNR, V_LOT_NO, V_IND_BCD, V_UNIT,
                                    P_MACH_CD, V_MACHINE, P_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_ORDER_NO, V_DOC_NO, 1, P_IND_BCD,
                                    V_PRFM_DT, TO_CHAR(V_DATE,'YYYYMMDD'), V_DISPO_QTY, V_PLT_QTY, V_BOX_QTY, V_BAG_QTY, V_EA_QTY, V_ROLLCNT, V_WGT, '30',
                                    'N', V_DATE, P_USER_ID);
        --재팔레트, 실적등록(전량폐품) -> 기존 바코드로 실적등록후 재고이전
        ELSIF P_TYPE = 'R' OR V_ALLFLG = 'Y' THEN
            --폐품 등록용 실적문서번호 생성
            IF P_WERKS = 'P200' THEN  
                V_DOC_NO := FN_GET_MDOCNO('M','IF124');
                V_IF_ID_PRFM := 'MES_IF_124';
            ELSE
                V_DOC_NO := FN_GET_MDOCNO('M','IF133');
                V_IF_ID_PRFM := 'MES_IF_133';
            END IF;
            
            --기존 재고수량 변경 및 이동
            UPDATE TB_INV001
               SET STOR_LOC_CD = '2020'
                 , STCK_QTY = V_DISPO_QTY
                 , PLT_QTY = V_PLT_QTY
                 , BOX_QTY = V_BOX_QTY
                 , BAG_QTY = V_BAG_QTY
                 , EA_QTY = V_EA_QTY
                 , ROLLCNT = V_ROLLCNT
                 , WGT = V_WGT
                 , STCK_STA = '30'
                 , DLFL = 'N'
                 , PRD_DT = TO_CHAR(V_DATE,'YYYYMMDD')
                 , UPDDATE = V_DATE
                 , UPDID = P_USER_ID
             WHERE 1=1
               AND WERKS = P_WERKS
               AND STOR_LOC_CD = '3100'
               AND MATNR = V_MATNR
               AND IND_BCD = V_IND_BCD;
            IF SQL%ROWCOUNT = 0 THEN
                --실적수량 재고등록
                INSERT INTO TB_INV001 (WERKS, STOR_LOC_CD, 
                                        MATNR, LOT_NO, IND_BCD, UNIT,
                                        MACH_CD, MACHINE, WRK_ORDR_NO, WRK_ORDR_SEQNO, ORDER_NO, DOC_NO, DOC_SEQNO,
                                        PRFM_DT, PRD_DT, STCK_QTY, PLT_QTY, BOX_QTY, BAG_QTY, EA_QTY, ROLLCNT, WGT, STCK_STA,
                                        DLFL, REGDATE, REGID)
                                VALUES(P_WERKS, '2020',
                                        V_MATNR, V_LOT_NO, V_IND_BCD, V_UNIT,
                                        P_MACH_CD, V_MACHINE, P_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_ORDER_NO, V_DOC_NO, 1,
                                        V_PRFM_DT, TO_CHAR(V_DATE,'YYYYMMDD'), V_DISPO_QTY, V_PLT_QTY, V_BOX_QTY, V_BAG_QTY, V_EA_QTY, V_ROLLCNT, V_WGT, '30',
                                        'N', V_DATE, P_USER_ID);
            END IF;
            --실적이 전송되지 않은 경우 실적 전송
            IF V_SAPFLG = 'N' THEN
                IF P_WERKS = 'P200' THEN  
                    --화장지 가공기(포장기) 실적 (생산된 실적을 전송후 불용으로 재고이동처리)
                    --투입 합지 정보 조회
                    BEGIN
                        SELECT LOT1, NVL(QTY1,0), LOT2, NVL(QTY2,0), LOT3, NVL(QTY3,0), NVL(BCD3,NVL(BCD2,BCD1))
                          INTO V_HLOTNO1, V_INPQT1, V_HLOTNO2, V_INPQT2, V_HLOTNO3, V_INPQT3, V_HIND_BCD
                          FROM (SELECT FIRST_VALUE(LOT_NO_M) OVER() AS LOT1
                                    , FIRST_VALUE(USE_QTY) OVER() AS QTY1
                                    , FIRST_VALUE(IND_BCD) OVER() AS BCD1
                                    , LEAD(LOT_NO_M) OVER(ORDER BY SEQNO) AS LOT2
                                    , LEAD(USE_QTY) OVER(ORDER BY SEQNO) AS QTY2
                                    , LEAD(IND_BCD) OVER(ORDER BY SEQNO) AS BCD2
                                    , LEAD(LOT_NO_M,2) OVER(ORDER BY SEQNO) AS LOT3
                                    , LEAD(USE_QTY,2) OVER(ORDER BY SEQNO) AS QTY3
                                    , LEAD(IND_BCD,2) OVER(ORDER BY SEQNO) AS BCD3
                                 FROM (SELECT MIN(SEQNO) AS SEQNO, LOT_NO_M, MAX(IND_BCD_M) AS IND_BCD, SUM(USE_QTY) AS USE_QTY 
                                         FROM TB_INV010 I010, TB_MAS001 M001
                                        WHERE 1=1
                                          AND I010.WERKS = M001.WERKS
                                          AND I010.MATNR_M = M001.MATNR
                                          AND I010.WERKS = P_WERKS
                                          AND I010.MACH_CD = P_MACH_CD
                                          AND I010.MATNR = V_MATNR
                                          AND I010.IND_BCD = P_IND_BCD
                                          AND M001.MATNR_DIV = 'HALB'
                                          AND NVL(I010.CNL_YN,'N') = 'N'
                                        GROUP BY LOT_NO_M)
                                ORDER BY SEQNO)
                         WHERE ROWNUM = 1;
                    EXCEPTION WHEN NO_DATA_FOUND THEN
                        RS_CODE := 'E';
                        RS_MSG  := '투입된 합지정보를 찾을수 없습니다.\n합지투입 후 폐품실적을 등록하여 주시기 바랍니다.';
                        RETURN;
                    END;
                    --투입된 자재 생산호기 확인
                    BEGIN
                        SELECT MACHINE
                          INTO V_HMACHINE
                          FROM TB_INV001
                         WHERE 1=1
                           AND ROWNUM < 2
                           AND IND_BCD = V_HIND_BCD
                         ORDER BY MACHINE;
                    EXCEPTION WHEN NO_DATA_FOUND THEN
                        V_HMACHINE := '';
                    END;
                    --실적 전송정보 등록    
                    INSERT INTO TB_IFS002(AUFNR, LOTNO, PRDCD, WERKS, WORKCENTERCODE, MACHINE, HMACHINE,
                                            HLOTNO1, HMATNR1, HMEINS1, INPQT1,
                                            HLOTNO2, HMATNR2, HMEINS2, INPQT2,
                                            HLOTNO3, HMATNR3, HMEINS3, INPQT3,
                                            PRDDT, PRODT, WORKGROUP, OPNAM,
                                            PROQTY, MEINS, RUNTIME, 
                                            SDATE, STIME, EDATE, ETIME, 
                                            MDOCNO, MDOCSEQ, MAKE_DATE, MAKER)
                                    VALUES(V_ORDER_NO, V_LOT_NO, V_MATNR, P_WERKS, V_SAP_WRK_CD, V_MACHINE, V_HMACHINE,
                                            V_HLOTNO1, V_HMATNR, V_HUNIT, V_INPQT1,
                                            V_HLOTNO2, V_HMATNR, V_HUNIT, V_INPQT2,
                                            V_HLOTNO3, V_HMATNR, V_HUNIT, V_INPQT3,
                                            FN_DT_FORMAT(V_PRFM_DT,'YYYYMMDD'), FN_DT_FORMAT(V_PRD_DT,'YYYYMMDD'), V_WRK_CLASS, V_USERID,
                                            V_DISPO_QTY, V_UNIT, V_RUNTIME, 
                                            TO_CHAR(V_DATE,'YYYYMMDD'), TO_CHAR(V_DATE,'HH24MISS'), 
                                            TO_CHAR(V_DATE,'YYYYMMDD'), TO_CHAR(V_DATE,'HH24MISS'),
                                            V_DOC_NO, V_DOC_SEQ, V_DATE, P_USER_ID);
                ELSE
                    --패드 가공기(포장기) 실적 (생산된 실적을 전송후 불용으로 재고이동처리)
                    INSERT INTO TB_IFS011(AUFNR, LOTNO, MATNR, WERKS, WORKCENTERCODE, MACHINE, 
                                          WORKGROUP, OPNAM, BUDAT, PROQTY, MEINS, RUNTIME,
                                          SDATE, STIME, EDATE, ETIME, 
                                          MDOCNO, MDOCSEQ, MAKE_DATE, MAKER)
                               VALUES(V_ORDER_NO, V_LOT_NO, V_MATNR, P_WERKS, V_SAP_WRK_CD, V_MACHINE, 
                                        V_WRK_CLASS, V_USERID, FN_DT_FORMAT(V_PRD_DT,'YYYYMMDD'), V_DISPO_QTY, V_UNIT, V_RUNTIME, 
                                        TO_CHAR(V_DATE,'YYYYMMDD'), TO_CHAR(V_DATE,'HH24MISS'), 
                                        TO_CHAR(V_DATE,'YYYYMMDD'), TO_CHAR(V_DATE,'HH24MISS'),
                                        V_DOC_NO, V_DOC_SEQ, V_DATE, V_USERID);
                END IF;
                --IF 전송이력(1:실적)
                INSERT INTO TB_WRK021(DOC_NO, DOC_SEQNO, DOC_DIV,
                                        WERKS, MACH_CD, WRK_ORDR_NO, WRK_ORDR_SEQNO,
                                        IND_BCD, LOT_NO, ORDER_NO,
                                        REGDATE, REGID)
                                VALUES(V_DOC_NO, V_DOC_SEQ, 1,
                                        P_WERKS, P_MACH_CD, P_WRK_ORDR_NO, V_WRK_ORDR_SEQNO,
                                        V_IND_BCD, V_LOT_NO, V_ORDER_NO,
                                        V_DATE, V_USERID);  
            END IF;
            --재고이전  
            V_DOC_MOVE := FN_GET_MDOCNO('M','IF131');
            V_IF_ID_MOVE := 'MES_IF_131';
            INSERT INTO TB_IFS009(BWART, AUFNR, WERKS_FROM, WERKS_TO, MATNR_FROM, MATNR_TO, LGORT_FROM, LGORT_TO,
                                    CHARG_FROM, CHARG_TO, MENGE, MEINS, FAULTY, MDOCNO, MDOCSEQ, MAKE_DATE, MAKER)
                            VALUES('311', V_ORDER_NO, P_WERKS, P_WERKS, V_MATNR, V_MATNR, V_LOC_FROM, V_LOC_TO,
                                    V_LOT_NO, V_LOT_NO, V_DISPO_QTY, V_UNIT, 'Y', V_DOC_MOVE, 1, V_DATE, P_USER_ID);
            --재고이전 이력
            INSERT INTO TB_WRK017(DOC_NO, DOC_SEQNO, MOVE_DIV, WERKS_FR, MATNR_FR, MATNR_TO, STOR_LOC_FR, STOR_LOC_TO,
                                    CHARG_FR, CHARG_TO, MOVE_QTY, UNIT, UCFMTY_YN, REGDATE, REGID)
                            VALUES(V_DOC_MOVE, 1, '311', P_WERKS, V_MATNR, V_MATNR, V_LOC_FROM, V_LOC_TO,
                                    V_LOT_NO, V_LOT_NO, V_DISPO_QTY, V_UNIT, 'Y', V_DATE, P_USER_ID);
            --IF 전송이력(6:재고이전(위치))
            INSERT INTO TB_WRK021(DOC_NO, DOC_SEQNO, DOC_DIV,
                                    WERKS, MACH_CD, WRK_ORDR_NO, WRK_ORDR_SEQNO,
                                    IND_BCD, LOT_NO, ORDER_NO,
                                    REGDATE, REGID)
                            VALUES(V_DOC_MOVE, TO_NUMBER(V_DOC_SEQ), 6,
                                    P_WERKS, P_MACH_CD, P_WRK_ORDR_NO, P_WRK_ORDR_SEQNO,
                                    V_IND_BCD, V_LOT_NO, V_ORDER_NO,
                                    V_DATE, P_USER_ID);
        --실적등록(부분폐품) -> 기존 바코드로 실적 등록, 폐품 바코드로 실적등록후 재고이전
        ELSE
            --폐품 등록용 실적문서번호 생성
            IF P_WERKS = 'P200' THEN  
                V_DOC_NO := FN_GET_MDOCNO('M','IF124');
                V_IF_ID_PRFM := 'MES_IF_124';
            ELSE
                V_DOC_NO := FN_GET_MDOCNO('M','IF133');
                V_IF_ID_PRFM := 'MES_IF_133';
            END IF;
            --폐품 개별 바코드
            SP_GET_BARCODE_SEQ('IND', P_WERKS, P_MACH_CD, V_MATNR, TO_CHAR(V_DATE,'YYYY-MM-DD HH24:MI:SS'), V_IND_BCD);
            --실적 등록(실적일자 : 양품 실적 등록일자, 등록일자 : 폐품 등록일자)
            INSERT INTO TB_WRK001 (WERKS, MACH_CD, IND_BCD, LOT_NO, MATNR,
                                    ORDER_NO, ORDER_SEQNO, WRK_ORDR_NO, WRK_ORDR_SEQNO, DOC_NO, DOC_SEQNO,
                                    PRFM_QTY, UNIT, PLT_QTY, BOX_QTY, BAG_QTY, EA_QTY, ROLLCNT, WGT, STA,
                                    PRFM_DT, PRD_DT, DSTBT_DDLIN, WRK_CLASS, WRK_SHIFT,
                                    PRD_STR_DATE, PRD_END_DATE,
                                    CHK_PP_YN, PRFM_GTHR_YN, REGDATE, REGID)
                            VALUES(P_WERKS, P_MACH_CD, V_IND_BCD, V_LOT_NO, V_MATNR,
                                    V_ORDER_NO, V_ORDER_SEQNO, P_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_DOC_NO, 1,
                                    V_DISPO_QTY, V_UNIT, V_PLT_QTY, V_BOX_QTY, V_BAG_QTY, V_EA_QTY, V_ROLLCNT, V_WGT, '30',
                                    V_PRFM_DT, TO_CHAR(V_DATE,'YYYYMMDD'), V_DSTBT_DDLIN, V_WRK_CLASS, V_WRK_SHIFT,
                                    V_STR_DATE, V_END_DATE,
                                    'Y', 'N', V_DATE, P_USER_ID);
            --재고 등록
            --실적수량 재고등록
            INSERT INTO TB_INV001 (WERKS, STOR_LOC_CD, 
                                    MATNR, LOT_NO, IND_BCD, UNIT,
                                    MACH_CD, MACHINE, WRK_ORDR_NO, WRK_ORDR_SEQNO, ORDER_NO, DOC_NO, DOC_SEQNO, PRE_IND_BCD,
                                    PRFM_DT, PRD_DT, STCK_QTY, PLT_QTY, BOX_QTY, BAG_QTY, EA_QTY, ROLLCNT, WGT, STCK_STA,
                                    DLFL, REGDATE, REGID)
                            VALUES(P_WERKS, '2020',
                                    V_MATNR, V_LOT_NO, V_IND_BCD, V_UNIT,
                                    P_MACH_CD, V_MACHINE, P_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_ORDER_NO, V_DOC_NO, 1, P_IND_BCD,
                                    V_PRFM_DT, TO_CHAR(V_DATE,'YYYYMMDD'), V_DISPO_QTY, V_PLT_QTY, V_BOX_QTY, V_BAG_QTY, V_EA_QTY, V_ROLLCNT, V_WGT, '30',
                                    'N', V_DATE, P_USER_ID);
            
            IF P_WERKS = 'P200' THEN  
                --화장지 가공기(포장기) 실적 (생산된 실적을 전송후 불용으로 재고이동처리)
                --투입 합지 정보 조회
                BEGIN
                    SELECT LOT1, NVL(QTY1,0), LOT2, NVL(QTY2,0), LOT3, NVL(QTY3,0), NVL(BCD3,NVL(BCD2,BCD1))
                      INTO V_HLOTNO1, V_INPQT1, V_HLOTNO2, V_INPQT2, V_HLOTNO3, V_INPQT3, V_HIND_BCD
                      FROM (SELECT FIRST_VALUE(LOT_NO_M) OVER() AS LOT1
                                , FIRST_VALUE(USE_QTY) OVER() AS QTY1
                                , FIRST_VALUE(IND_BCD) OVER() AS BCD1
                                , LEAD(LOT_NO_M) OVER(ORDER BY SEQNO) AS LOT2
                                , LEAD(USE_QTY) OVER(ORDER BY SEQNO) AS QTY2
                                , LEAD(IND_BCD) OVER(ORDER BY SEQNO) AS BCD2
                                , LEAD(LOT_NO_M,2) OVER(ORDER BY SEQNO) AS LOT3
                                , LEAD(USE_QTY,2) OVER(ORDER BY SEQNO) AS QTY3
                                , LEAD(IND_BCD,2) OVER(ORDER BY SEQNO) AS BCD3
                             FROM (SELECT MIN(SEQNO) AS SEQNO, LOT_NO_M, MAX(IND_BCD_M) AS IND_BCD, SUM(USE_QTY) AS USE_QTY 
                                     FROM TB_INV010 I010, TB_MAS001 M001
                                    WHERE 1=1
                                      AND I010.WERKS = M001.WERKS
                                      AND I010.MATNR_M = M001.MATNR
                                      AND I010.WERKS = P_WERKS
                                      AND I010.MACH_CD = P_MACH_CD
                                      AND I010.MATNR = V_MATNR
                                      AND I010.IND_BCD = P_IND_BCD
                                      AND M001.MATNR_DIV = 'HALB'
                                      AND NVL(I010.CNL_YN,'N') = 'N'
                                    GROUP BY LOT_NO_M)
                            ORDER BY SEQNO)
                     WHERE ROWNUM = 1;
                EXCEPTION WHEN NO_DATA_FOUND THEN
                    RS_CODE := 'E';
                    RS_MSG  := '투입된 합지정보를 찾을수 없습니다.\n합지투입 후 폐품실적을 등록하여 주시기 바랍니다.';
                    RETURN;
                END;
                --투입된 자재 생산호기 확인
                BEGIN
                    SELECT MACHINE
                      INTO V_HMACHINE
                      FROM TB_INV001
                     WHERE 1=1
                       AND ROWNUM < 2
                       AND IND_BCD = V_HIND_BCD
                     ORDER BY MACHINE;
                EXCEPTION WHEN NO_DATA_FOUND THEN
                    V_HMACHINE := '';
                END;
                --실적 전송정보 등록    
                INSERT INTO TB_IFS002(AUFNR, LOTNO, PRDCD, WERKS, WORKCENTERCODE, MACHINE, HMACHINE,
                                        HLOTNO1, HMATNR1, HMEINS1, INPQT1,
                                        HLOTNO2, HMATNR2, HMEINS2, INPQT2,
                                        HLOTNO3, HMATNR3, HMEINS3, INPQT3,
                                        PRDDT, PRODT, WORKGROUP, OPNAM,
                                        PROQTY, MEINS, RUNTIME, 
                                        SDATE, STIME, EDATE, ETIME, 
                                        MDOCNO, MDOCSEQ, MAKE_DATE, MAKER)
                                VALUES(V_ORDER_NO, V_LOT_NO, V_MATNR, P_WERKS, V_SAP_WRK_CD, V_MACHINE, V_HMACHINE,
                                        V_HLOTNO1, V_HMATNR, V_HUNIT, V_INPQT1,
                                        V_HLOTNO2, V_HMATNR, V_HUNIT, V_INPQT2,
                                        V_HLOTNO3, V_HMATNR, V_HUNIT, V_INPQT3,
                                        FN_DT_FORMAT(V_PRFM_DT,'YYYYMMDD'), FN_DT_FORMAT(V_PRD_DT,'YYYYMMDD'), V_WRK_CLASS, V_USERID,
                                        V_DISPO_QTY, V_UNIT, V_RUNTIME, 
                                        TO_CHAR(V_DATE,'YYYYMMDD'), TO_CHAR(V_DATE,'HH24MISS'), 
                                        TO_CHAR(V_DATE,'YYYYMMDD'), TO_CHAR(V_DATE,'HH24MISS'),
                                        V_DOC_NO, V_DOC_SEQ, V_DATE, P_USER_ID);
            ELSE
                --패드 가공기(포장기) 실적 (생산된 실적을 전송후 불용으로 재고이동처리)
                INSERT INTO TB_IFS011(AUFNR, LOTNO, MATNR, WERKS, WORKCENTERCODE, MACHINE, 
                                      WORKGROUP, OPNAM, BUDAT, PROQTY, MEINS, RUNTIME,
                                      SDATE, STIME, EDATE, ETIME, 
                                      MDOCNO, MDOCSEQ, MAKE_DATE, MAKER)
                           VALUES(V_ORDER_NO, V_LOT_NO, V_MATNR, P_WERKS, V_SAP_WRK_CD, V_MACHINE, 
                                    V_WRK_CLASS, V_USERID, FN_DT_FORMAT(V_PRD_DT,'YYYYMMDD'), V_DISPO_QTY, V_UNIT, V_RUNTIME, 
                                    TO_CHAR(V_DATE,'YYYYMMDD'), TO_CHAR(V_DATE,'HH24MISS'), 
                                    TO_CHAR(V_DATE,'YYYYMMDD'), TO_CHAR(V_DATE,'HH24MISS'),
                                    V_DOC_NO, V_DOC_SEQ, V_DATE, V_USERID);
            END IF;
            --IF 전송이력(1:실적)
            INSERT INTO TB_WRK021(DOC_NO, DOC_SEQNO, DOC_DIV,
                                    WERKS, MACH_CD, WRK_ORDR_NO, WRK_ORDR_SEQNO,
                                    IND_BCD, LOT_NO, ORDER_NO,
                                    REGDATE, REGID)
                            VALUES(V_DOC_NO, V_DOC_SEQ, 1,
                                    P_WERKS, P_MACH_CD, P_WRK_ORDR_NO, V_WRK_ORDR_SEQNO,
                                    V_IND_BCD, V_LOT_NO, V_ORDER_NO,
                                    V_DATE, V_USERID);  
    
            --재고이전  
            V_DOC_MOVE := FN_GET_MDOCNO('M','IF131');
            V_IF_ID_MOVE := 'MES_IF_131';
            INSERT INTO TB_IFS009(BWART, AUFNR, WERKS_FROM, WERKS_TO, MATNR_FROM, MATNR_TO, LGORT_FROM, LGORT_TO,
                                    CHARG_FROM, CHARG_TO, MENGE, MEINS, FAULTY, MDOCNO, MDOCSEQ, MAKE_DATE, MAKER)
                            VALUES('311', V_ORDER_NO, P_WERKS, P_WERKS, V_MATNR, V_MATNR, V_LOC_FROM, V_LOC_TO,
                                    V_LOT_NO, V_LOT_NO, V_DISPO_QTY, V_UNIT, 'Y', V_DOC_MOVE, 1, V_DATE, P_USER_ID);
            --재고이전 이력
            INSERT INTO TB_WRK017(DOC_NO, DOC_SEQNO, MOVE_DIV, WERKS_FR, MATNR_FR, MATNR_TO, STOR_LOC_FR, STOR_LOC_TO,
                                    CHARG_FR, CHARG_TO, MOVE_QTY, UNIT, UCFMTY_YN, REGDATE, REGID)
                            VALUES(V_DOC_MOVE, 1, '311', P_WERKS, V_MATNR, V_MATNR, V_LOC_FROM, V_LOC_TO,
                                    V_LOT_NO, V_LOT_NO, V_DISPO_QTY, V_UNIT, 'Y', V_DATE, P_USER_ID);
            --IF 전송이력(6:재고이전(위치))
            INSERT INTO TB_WRK021(DOC_NO, DOC_SEQNO, DOC_DIV,
                                    WERKS, MACH_CD, WRK_ORDR_NO, WRK_ORDR_SEQNO,
                                    IND_BCD, LOT_NO, ORDER_NO,
                                    REGDATE, REGID)
                            VALUES(V_DOC_MOVE, TO_NUMBER(V_DOC_SEQ), 6,
                                    P_WERKS, P_MACH_CD, P_WRK_ORDR_NO, P_WRK_ORDR_SEQNO,
                                    V_IND_BCD, V_LOT_NO, V_ORDER_NO,
                                    V_DATE, P_USER_ID);
                                
            --양품 등록수량
            V_PLT_QTY := FN_CHG_UNIT(V_MATNR, P_WERKS, V_UNIT, 'PAL', V_PRFM_QTY - V_DISPO_QTY);
            V_BOX_QTY := FN_CHG_UNIT(V_MATNR, P_WERKS, V_UNIT, 'BOX', V_PRFM_QTY - V_DISPO_QTY);
            V_BAG_QTY := FN_CHG_UNIT(V_MATNR, P_WERKS, V_UNIT, 'BAG', V_PRFM_QTY - V_DISPO_QTY);
            V_EA_QTY := FN_CHG_UNIT(V_MATNR, P_WERKS, V_UNIT, 'EA', V_PRFM_QTY - V_DISPO_QTY);
            V_ROLLCNT := FN_CHG_UNIT(V_MATNR, P_WERKS, V_UNIT, 'M', V_PRFM_QTY - V_DISPO_QTY);
            V_WGT := FN_CHG_UNIT(V_MATNR, P_WERKS, V_UNIT, 'KG', V_PRFM_QTY - V_DISPO_QTY);
            V_PRFM_BOX := V_BOX_QTY;
               
            --재고정보 수정
            UPDATE TB_INV001
               SET STCK_STA = '00'
               	 , PLT_QTY = V_PLT_QTY
               	 , BOX_QTY = V_BOX_QTY
               	 , BAG_QTY = V_BAG_QTY
               	 , EA_QTY = V_EA_QTY
               	 , ROLLCNT = V_ROLLCNT
               	 , WGT = V_WGT
               	 , UCFMTY_AMT = 0
                 , UPDDATE = SYSDATE
                 , UPDID = P_USER_ID
             WHERE 1=1
               AND WERKS = P_WERKS
               AND STOR_LOC_CD = '3100'
               AND MATNR = V_MATNR
               AND IND_BCD = P_IND_BCD;
              
            --실적정보 수정
            UPDATE TB_WRK001
               SET PRFM_QTY = V_BAG_QTY
               	 , PLT_QTY = V_PLT_QTY
               	 , BOX_QTY = V_BOX_QTY
               	 , BAG_QTY = V_BAG_QTY
               	 , EA_QTY = V_EA_QTY
               	 , ROLLCNT = V_ROLLCNT
               	 , WGT = V_WGT
                 , UPDDATE = SYSDATE
                 , UPDID = P_USER_ID
             WHERE 1=1
               AND WERKS = P_WERKS
               AND MATNR = V_MATNR
               AND IND_BCD = P_IND_BCD;

        END IF;

        --라벨출력정보 반환
        OPEN CUR_1 FOR
        SELECT FN_DT_FORMAT(V_PRFM_DT,'YYYY-MM-DD') AS PRFM_DT --실적일자
             , V_MACH_NM AS MACH_NM --설비명
             , CASE WHEN P_WERKS = 'P200' THEN '화장지'
                    WHEN P_WERKS = 'P300' THEN '생리대'
                    WHEN P_WERKS = 'P500' THEN '기저귀'
                    END AS WERKS_NM         --제품종류
            , FN_CD_VAL('PART_DIV', V_PART_DIV) AS MATNR_DIV_NM
            , V_MATNR AS MATNR
            , V_MATNR_NM AS MATNR_NM
            , V_KAN_CD AS KAN_CD         --KAN코드
            , FN_CHG_UNIT(V_MATNR, P_WERKS, 'BAG', 'EA', 1) || 'x' 
                || FN_CHG_UNIT(V_MATNR, P_WERKS, 'BOX', 'BAG', 1) AS BAG2BOX
            , FN_CHG_UNIT(V_MATNR, P_WERKS, 'PAL', 'BOX', 1) AS BOX2PLT
            , V_LOT_NO AS LOT_NO
            , V_IND_BCD AS IND_BCD
            , V_DISPO_BOX AS PRFM_QTY
         FROM dual; 
        --양품 등록시 라벨정보
        OPEN CUR_2 FOR
        SELECT FN_DT_FORMAT(V_PRFM_DT,'YYYY-MM-DD') AS PRFM_DT --실적일자
             , V_MACH_NM AS MACH_NM --설비명
             , CASE WHEN P_WERKS = 'P200' THEN '화장지'
                    WHEN P_WERKS = 'P300' THEN '생리대'
                    WHEN P_WERKS = 'P500' THEN '기저귀'
                    END AS WERKS_NM         --제품종류
            , FN_CD_VAL('PART_DIV', V_PART_DIV) AS MATNR_DIV_NM
            , V_MATNR AS MATNR
            , V_MATNR_NM AS MATNR_NM
            , V_KAN_CD AS KAN_CD         --KAN코드
            , FN_CHG_UNIT(V_MATNR, P_WERKS, 'BAG', 'EA', 1) || 'x' 
                || FN_CHG_UNIT(V_MATNR, P_WERKS, 'BOX', 'BAG', 1) AS BAG2BOX
            , FN_CHG_UNIT(V_MATNR, P_WERKS, 'PAL', 'BOX', 1) AS BOX2PLT
            , V_LOT_NO AS LOT_NO
            , V_TEMP_BCD AS IND_BCD
            , V_PRFM_BOX AS PRFM_QTY
         FROM dual;  

        --SAP FUNC ID
        IF V_IF_ID_PRFM IS NOT NULL THEN
            SELECT RFCFN
              INTO P_PRFM_FUNC
              FROM TB_ITFMA
             WHERE 1=1
               AND IFID = V_IF_ID_PRFM;
        
            --인터페이스 파라미터(부적합등록)
            OPEN CUR_3 FOR
            SELECT V_IF_ID_PRFM AS I_IF_ID
                 , 'M' || LTRIM(RTRIM(TO_CHAR(SEQ_GET_IFR_KEY.NEXTVAL, '00000000000000000000000000000'))) AS I_IF_KEY
              FROM dual;
            --인터페이스 상세 파라미터
            V_SQL := FN_IF_QUERY(V_IF_ID_PRFM, V_DOC_NO);
            IF V_SQL IS NOT NULL THEN
            	OPEN CUR_4 FOR V_SQL;
            END IF;
        END IF;
        --SAP FUNC ID 130
        SELECT RFCFN
          INTO P_MOVE_FUNC
          FROM TB_ITFMA
         WHERE 1=1
           AND IFID = V_IF_ID_MOVE;
        --인터페이스 파라미터(재고이전)
        OPEN CUR_5 FOR
        SELECT V_IF_ID_MOVE AS I_IF_ID
             , 'M' || LTRIM(RTRIM(TO_CHAR(SEQ_GET_IFR_KEY.NEXTVAL, '00000000000000000000000000000'))) AS I_IF_KEY
          FROM dual;
        --인터페이스 상세 파라미터
        V_SQL := FN_IF_QUERY(V_IF_ID_MOVE, V_DOC_MOVE);
        IF V_SQL IS NOT NULL THEN
        	OPEN CUR_6 FOR V_SQL;
        END IF;

        --인터페이스 파라미터(양품등록)
        IF V_DOC_NO_PRFM IS NOT NULL THEN
            OPEN CUR_7 FOR
            SELECT V_IF_ID_PRFM AS I_IF_ID
                 , 'M' || LTRIM(RTRIM(TO_CHAR(SEQ_GET_IFR_KEY.NEXTVAL, '00000000000000000000000000000'))) AS I_IF_KEY
              FROM dual;
            --인터페이스 상세 파라미터
            V_SQL := FN_IF_QUERY(V_IF_ID_PRFM, V_DOC_NO_PRFM);
           	IF V_SQL IS NOT NULL THEN
            	OPEN CUR_8 FOR V_SQL;
            END IF;
        END IF;

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
        IF CUR_6%ISOPEN = FALSE THEN
            OPEN CUR_6 FOR SELECT 1 FROM dual;
        END IF;
        IF CUR_7%ISOPEN = FALSE THEN
            OPEN CUR_7 FOR SELECT 1 FROM dual;
        END IF;
        IF CUR_8%ISOPEN = FALSE THEN
            OPEN CUR_8 FOR SELECT 1 FROM dual;
        END IF;

    --ROLLBACK;
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
END SP_POP_WRK86_U01;

/
