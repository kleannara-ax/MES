
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK41_D01" 
(
    P_WERKS                 IN VARCHAR2
    ,P_MACH_CD              IN VARCHAR2 
    ,P_IOTYPE               IN VARCHAR2 
    ,P_USERID               IN VARCHAR2
    ,P_ORDER_NO             IN VARCHAR2 
    ,P_WRK_ORDR_NO          IN VARCHAR2 
    ,P_WRK_ORDR_SEQNO       IN VARCHAR2 
    ,P_PRD_STR_DATE         IN VARCHAR2
    ,P_PRD_END_DATE         IN VARCHAR2
    ,P_MATNR                IN VARCHAR2
    ,P_PROC_CD              IN VARCHAR2
    ,P_PRFM_QTY             IN VARCHAR2
    ,P_DISPO_QTY            IN VARCHAR2
    ,P_PRFM_DOC             OUT VARCHAR2 
    ,P_DISPO_DOC            OUT VARCHAR2
    ,P_WRK_FUNC             OUT VARCHAR2
    ,P_DISPO_FUNC           OUT VARCHAR2
    ,Lang                   IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE                OUT VARCHAR2 
    ,RS_MSG                 OUT VARCHAR2
    ,CUR_1                  OUT SYS_REFCURSOR
    ,CUR_2                  OUT SYS_REFCURSOR
    ,CUR_3                  OUT SYS_REFCURSOR
    ,CUR_4                  OUT SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : POP_WRK41
 * PROGRAM NAME  : HL 폐품등록
 * VERSION       : 1.0.0
 * DESCRIPTION   : 진행중인 작업지시를 변경시 폐품정보를 등록기능 분할.
 *                 
 * AUTHOR NAME   : 김기연
 * CREATE DATE   : 2022/07/29
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/07/29    1.0.0   김기연         Initial Version
 *==============================================================================
 *  관련 테이블
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM         VARCHAR2(100)  := 'SP_POP_WRK41_D01';     -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := P_PROC_CD;
    V_SESS_USER_ID   varchar2(20) := P_USERID; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);
    --parameter변수 처리
    V_WRK_ORDR_SEQNO        NUMBER(5,0) := TO_NUMBER(P_WRK_ORDR_SEQNO);
    V_PRD_STR_DATE          DATE := TO_DATE(P_PRD_STR_DATE, 'yyyy-MM-dd HH24:mi:ss');
    V_PRD_END_DATE          DATE := TO_DATE(P_PRD_END_DATE, 'yyyy-MM-dd HH24:mi:ss');
    V_PRFM_QTY              NUMBER(13,0) := TO_NUMBER(P_PRFM_QTY); --실적수량
    V_DISPO_QTY             NUMBER(13,3) := TO_NUMBER(P_DISPO_QTY); --폐품수량
    --내부 변수 등록
    V_DATE                  DATE := SYSDATE;
    --V_ORDER_SEQNO           NUMBER(5,0) := 1; --HL의 경우 해당 항목 미사용
    V_IOTYPE				VARCHAR2(10) := CASE WHEN P_WERKS = 'P500' THEN 'N' ELSE P_IOTYPE END;
    V_WRK_CLASS             VARCHAR2(10); --작업반
    V_WRK_SHIFT             VARCHAR2(10); --작업조
    V_EMPLY_NO              VARCHAR2(10); --메인작업자
    V_PRFM_LOC              VARCHAR2(4); --실적 위치
    V_LOT_NO                VARCHAR2(15); --이전 작업중 지시 상태
    V_HIND_BCD              VARCHAR2(20); --투입된 자재 바코드(합지)
    V_INP_LOT               VARCHAR2(15); --투입된 자재 LOT(합지)
    V_EA_MATNR              VARCHAR(18); --생리대 개수별 자재코드(폐품등록용)
    V_TEMP_MATNR            VARCHAR(18); --생리대 임시 자재코드(폐품등록용)
    V_DISPO_MATNR           VARCHAR(18); --폐품항목(합지,1P패드) 자재코드(폐품등록용)
    V_DISPO_LOT             VARCHAR2(20); --폐품 Lot(폐품등록용)
    V_IND_BCD               VARCHAR2(20); --개별바코드(폐품등록용)
    V_PRFM_DT               VARCHAR2(8); --실적일자
    V_PRD_DT                VARCHAR2(8); --생산일자
    V_DSTBT_DDLIN           VARCHAR(10); --유통기간 일자
    V_SAP_WRK_CD            VARCHAR(20); --SAP작업장코드
    V_MACHINE               VARCHAR2(5); --생산호기
    V_HMATNR                VARCHAR(20); --합지품목
    V_HLOTNO1               VARCHAR2(10); --합지LOT1
    V_INPQT1                VARCHAR2(10); --합지수량1
    V_HLOTNO2               VARCHAR2(10); --합지LOT2
    V_INPQT2                VARCHAR2(10); --합지수량2
    V_HLOTNO3               VARCHAR2(10); --합지LOT3
    V_INPQT3                VARCHAR2(10); --합지수량3
    V_RUNTIME               VARCHAR2(8); --가동시간(분)
    V_PLT_QTY               NUMBER(13,1); --PLT수량
    V_BOX_QTY               NUMBER(13,0); --BOX수량
    V_BAG_QTY               NUMBER(13,0); --BAG수량
    V_EA_QTY                NUMBER(13,0); --EA수량
    V_ERR_UNIT              VARCHAR2(10); --폐품 단위
    V_TOT_QTY               NUMBER(13,3); --총량
    V_TOT_WGT               NUMBER(13,3); --총중량
    V_PRFM_WGT              NUMBER(13,3); --실적중량
    V_DISPO_WGT             NUMBER(13,3); --폐품중량
    V_DOC_NO                VARCHAR2(29); --실적등록 문서번호
    V_DOC_DISPO             VARCHAR2(29); --폐품 문서번호 
    V_DOC_SEQ               VARCHAR2(6);
    V_FLAG_CNT              NUMBER; --반복문 처리용 변수
    V_PIF_ID				VARCHAR2(20); --MES IF ID
    V_SQL_P					VARCHAR2(4000);
    V_EIF_ID				VARCHAR2(20) := 'MES_IF_134'; --MES IF ID
    V_SQL_E					VARCHAR2(4000);
    V_SQL_U					VARCHAR2(4000);
    V_MATNR_STA				VARCHAR2(2); --자재 단종여부

BEGIN
    --예외처리 시작(try)
    BEGIN
        --투입된 작업자 정보 조회
        BEGIN
        SELECT WRK_SHIFT, EMPLY_NO
          INTO V_WRK_SHIFT, V_EMPLY_NO
          FROM TB_WRK013
         WHERE ROWNUM <= 1
           AND WERKS = P_WERKS
           AND MACH_CD = P_MACH_CD
           AND IN_OUT = V_IOTYPE
           AND END_DATE IS NULL
         ORDER BY STR_DATE DESC;
        EXCEPTION WHEN NO_DATA_FOUND THEN 
            RS_CODE := 'E';
            RS_MSG  := '작업자 현황을 확인하여 주시기 바랍니다.';
            RETURN;
        END;

        --현재 작업장 정보 조회
        SELECT LOT_NO
          INTO V_LOT_NO
          FROM TB_WRK011
         WHERE 1=1
           AND WERKS = P_WERKS
           AND MACH_CD = P_MACH_CD
           AND IN_OUT = V_IOTYPE;
        --설비정보 조회
        SELECT MACHINE, SAP_WRK_CD
          INTO V_MACHINE, V_SAP_WRK_CD
          FROM TB_MAS012
         WHERE 1=1
           AND MACH_CD = P_MACH_CD;   
        --작업자 정보 조회
        SELECT WRK_CLASS
          INTO V_WRK_CLASS
          FROM USRMA
         WHERE 1=1
           AND USERID = V_EMPLY_NO;
          
        SELECT LOT_NO
          INTO V_LOT_NO
          FROM TB_WRK011
         WHERE 1=1
           AND WERKS = P_WERKS
           AND MACH_CD = P_MACH_CD
           AND IN_OUT = V_IOTYPE;

--        --가동시간(기존 가동시간과 중복 처리되지 않도록 수정)
--        V_RUNTIME := CEIL((V_PRD_END_DATE - V_PRD_STR_DATE) * 24 * 60);--TO_CHAR((V_PRD_END_DATE-V_PRD_STR_DATE)*24*60);
--        --비가동 시간 처리
--        V_RUNTIME := V_RUNTIME - FN_NON_ACT_TM(V_PRD_STR_DATE, V_PRD_END_DATE, P_MACH_CD);
       
        V_RUNTIME := 0; --폐품등록시 0으로 처리

        --일괄 폐품 등록(이전에 작업중이던 지시가 존재하는 경우 해당 지시의 폐품을 등록)
        IF NVL(V_DISPO_QTY,0) > 0 /*AND P_WERKS = 'P300'*/ THEN
            IF P_WERKS = 'P200' THEN
                V_ERR_UNIT := 'KG';
                V_DOC_NO := FN_GET_MDOCNO('M','IF124');--생산실적
                V_PIF_ID := 'MES_IF_124';
            ELSE
                V_ERR_UNIT := 'EA';
                V_DOC_NO := FN_GET_MDOCNO('M','IF133');--생산실적
                V_PIF_ID := 'MES_IF_133';
            END IF;
            --이전 자재정보 조회
            --자재정보(유통기한 일자)
            SELECT TO_CHAR(TO_DATE(V_PRFM_DT,'YYYYMMDD') + NVL(DSTBT_DDLIN,365*3),'YYYYMMDD')
              INTO V_DSTBT_DDLIN
              FROM TB_MAS001
             WHERE 1=1
               AND WERKS = P_WERKS
               AND MATNR = P_MATNR;

            --폐품 등록정보
            IF P_WERKS = 'P200' THEN
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
                                      AND I010.MATNR = P_MATNR
                                      AND I010.WRK_ORDR_NO = P_WRK_ORDR_NO
                                      AND I010.WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
                                      AND M001.MATNR_DIV = 'HALB'
                                      AND NVL(I010.CNL_YN,'N') = 'N'
                                    GROUP BY LOT_NO_M)
                            ORDER BY SEQNO)
                     WHERE ROWNUM = 1;
                EXCEPTION WHEN NO_DATA_FOUND THEN
                    V_HLOTNO1 := '';
                    V_INPQT1 := '';
                    V_HLOTNO2 := '';
                    V_INPQT2 := '';
                    V_HLOTNO3 := '';
                    V_INPQT3 := '';
                    V_HIND_BCD := '';
                END;
                --투입된 자재 실적정보 조회
                BEGIN
                    SELECT MATNR, LOT_NO
                      INTO V_HMATNR, V_INP_LOT 
                      FROM TB_INV001
                     WHERE 1=1
                       AND ROWNUM < 2
                       AND WERKS = P_WERKS
                       AND IND_BCD = V_HIND_BCD;
                EXCEPTION WHEN NO_DATA_FOUND THEN
                    V_HMATNR := '';
                    V_INP_LOT := '';
                END;
                V_DISPO_MATNR := V_HMATNR;
            ELSE
                --생리대 폐품 등록시 EA단위 품목코드로 전송 필요
                V_EA_MATNR := P_MATNR;
                V_FLAG_CNT := 1;
                WHILE V_FLAG_CNT > 0 LOOP
                    SELECT COUNT(SUB_MATNR), MAX(SUB_MATNR)
                      INTO V_FLAG_CNT, V_TEMP_MATNR
                      FROM TB_MAS008 M008, TB_MAS001 M001
                     WHERE 1=1
                       AND M008.WERKS = M001.WERKS
                       AND M008.SUB_MATNR = M001.MATNR
                       AND M008.WERKS = P_WERKS
                       AND M008.MATNR = V_EA_MATNR
                       AND M008.USE_YN = 'Y'
                       AND M001.MATNR_DIV = 'HALB';
                    --하위 자재가 존재하는 경우 처리
                    IF V_TEMP_MATNR IS NOT NULL THEN
                        V_EA_MATNR := V_TEMP_MATNR;
                       --하위 반제품의 기본단위를 사용
                       SELECT UNIT, MATNR_STA
                         INTO V_ERR_UNIT, V_MATNR_STA
                         FROM TB_MAS001
                        WHERE 1=1
                          AND WERKS = P_WERKS
                          AND MATNR = V_EA_MATNR;
                        --사용여부확인(해당 컬럼에 데이터 존재시 단종처리된 항목임)
                         IF V_MATNR_STA IS NOT NULL THEN
                         	RS_CODE := 'E';
                    		RS_MSG  := V_EA_MATNR || ' 반제품은 단종되어 사용이 불가능합니다.\nBOM의 생산버전 또는 품목의 상태를 확인하여 주시기 바랍니다.';
                    		RETURN;
                         END IF;
                    END IF;
                END LOOP;
                V_DISPO_MATNR := V_EA_MATNR;
                --생리대 1P자재 조회 실패시 처리
                IF P_MATNR = V_DISPO_MATNR THEN
                    RS_CODE := 'E';
                    RS_MSG  := V_EA_MATNR || ' 제품의 하위 BOM정보가 없습니다.';
                    RETURN;
                END IF;
            END IF;
            --폐품 정보 작성
            --폐품 실적에 따른 사용량 등록(완제품 정보를 기준으로 등록)
            SP_GET_BARCODE_SEQ('LOT', P_WERKS, P_MACH_CD, V_DISPO_MATNR, TO_CHAR(V_DATE,'YYYY-MM-DD HH24:MI:SS'), V_DISPO_LOT);
            SP_GET_BARCODE_SEQ('IND', P_WERKS, P_MACH_CD, V_DISPO_MATNR, TO_CHAR(V_DATE,'YYYY-MM-DD HH24:MI:SS'), V_IND_BCD);
            V_TOT_QTY := V_PRFM_QTY + V_DISPO_QTY;
            V_PLT_QTY := CEIL(FN_CHG_UNIT(V_DISPO_MATNR, P_WERKS, V_ERR_UNIT, 'PAL', V_DISPO_QTY));
            V_BOX_QTY := CEIL(FN_CHG_UNIT(V_DISPO_MATNR, P_WERKS, V_ERR_UNIT, 'BOX', V_DISPO_QTY));
            V_BAG_QTY := CEIL(FN_CHG_UNIT(V_DISPO_MATNR, P_WERKS, V_ERR_UNIT, 'BAG', V_DISPO_QTY));
            V_EA_QTY := FN_CHG_UNIT(V_DISPO_MATNR, P_WERKS, V_ERR_UNIT, 'EA', V_DISPO_QTY);
            V_TOT_WGT := FN_CHG_UNIT(V_DISPO_MATNR, P_WERKS, V_ERR_UNIT, 'KG', V_TOT_QTY);
            V_PRFM_WGT := FN_CHG_UNIT(V_DISPO_MATNR, P_WERKS, V_ERR_UNIT, 'KG', V_PRFM_QTY);
            V_DISPO_WGT := FN_CHG_UNIT(V_DISPO_MATNR, P_WERKS, V_ERR_UNIT, 'KG', V_DISPO_QTY);
            V_PRFM_DT := FN_RECDATE(V_PRD_END_DATE);
            V_PRD_DT := TO_CHAR(V_PRD_END_DATE,'YYYYMMDD');
            --문서번호 생성
            V_DOC_SEQ := '1';

            --폐품정보 등록
            V_DOC_DISPO := FN_GET_MDOCNO('M','IF134');--폐품등록
            P_DISPO_DOC := V_DOC_DISPO;

            --폐품 등록 및 인터페이스
            IF P_WERKS = 'P200' THEN
                --폐품정보 등록 
                INSERT INTO TB_WRK016 (WERKS, MACH_CD, WRK_ORDR_NO, WRK_ORDR_SEQNO, IND_BCD, LOT_NO, MATNR
                                     , IND_BCD_M, LOT_NO_M, MATNR_M, UNIT, ORDER_NO, PRFM_DT
                                     , TOT_WGT, PRFM_WGT, DISPO_WGT, DISPO_CD
                                     , WRK_CLASS, WRK_SHIFT, DOC_NO, DOC_SEQNO, REGDATE, REGID)
                               VALUES (P_WERKS, P_MACH_CD, P_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_IND_BCD, V_LOT_NO, P_MATNR
                                     , V_HIND_BCD, V_INP_LOT, V_DISPO_MATNR, V_ERR_UNIT, P_ORDER_NO, V_PRFM_DT
                                     , V_TOT_WGT, V_PRFM_WGT, V_DISPO_WGT, '100'
                                     , V_WRK_CLASS, V_WRK_SHIFT, V_DOC_DISPO, '1', V_DATE, P_USERID);  
                --인터페이스
                INSERT INTO TB_IFS012 (AUFNR, LOTNO, BUDAT, MATNR, SCRQTY, RSDQTY, MRSCQTY, SCRQTY_OP,
                                        SCRAPCODE, SCRAPREASON, LGORT, CHARG, 
                                        SDATE, STIME, EDATE, ETIME, 
                                        RUNTIME, WORKCENTERCODE, MDOCNO, MDOCSEQ, MAKE_DATE, MAKER)
                                VALUES (P_ORDER_NO, V_LOT_NO, V_PRFM_DT, V_HMATNR, V_DISPO_QTY, 0, 0, 0,
                                        '100', '가공폐품', '3100', V_INP_LOT,
                                        FN_DT_FORMAT(P_PRD_END_DATE,'YYYYMMDD'), FN_DT_FORMAT(P_PRD_END_DATE,'HH24MISS'), 
                                        FN_DT_FORMAT(P_PRD_END_DATE,'YYYYMMDD'), FN_DT_FORMAT(P_PRD_END_DATE,'HH24MISS'), 
                                        V_RUNTIME, V_SAP_WRK_CD, V_DOC_DISPO, '1', V_DATE, P_USERID);
                --SAP FUNC ID
                SELECT RFCFN
                  INTO P_DISPO_FUNC
                  FROM TB_ITFMA
                 WHERE 1=1
                   AND IFID = V_EIF_ID;
                --인터페이스 파라미터
                OPEN CUR_1 FOR
                SELECT V_EIF_ID AS I_IF_ID
                     , 'M' || LTRIM(RTRIM(TO_CHAR(SEQ_GET_IFR_KEY.NEXTVAL, '00000000000000000000000000000'))) AS I_IF_KEY
                FROM dual;
                --인터페이스 상세 파라미터
                PKG_WRK055.LOG_IF('SP_POP_WRK41_D01', P_WERKS, V_EIF_ID, V_DOC_DISPO, P_USERID);   -- WRK55 RFC 전송로그
                V_SQL_E := FN_IF_QUERY(V_EIF_ID, V_DOC_DISPO);
                IF V_SQL_E IS NOT NULL THEN
                	OPEN CUR_2 FOR V_SQL_E;
                END IF;
            ELSE
                --생리대의 경우 폐품 처리시 하위제품 실적 등록 필요
                INSERT INTO TB_WRK001 (WERKS, MACH_CD, IND_BCD, LOT_NO, MATNR,
                                        ORDER_NO, WRK_ORDR_NO, WRK_ORDR_SEQNO, DOC_NO, DOC_SEQNO,
                                        UNIT, PLT_QTY, BOX_QTY, BAG_QTY, EA_QTY, STA,
                                        PRFM_DT, PRD_DT, DSTBT_DDLIN, WRK_CLASS, WRK_SHIFT,
                                        PRD_STR_DATE, PRD_END_DATE,
                                        CHK_QC_YN, CNL_YN, PRFM_GTHR_YN, REGDATE, REGID)
                               VALUES(P_WERKS, P_MACH_CD, V_IND_BCD, V_DISPO_LOT, V_EA_MATNR,
                                        P_ORDER_NO, P_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_DOC_NO, 1,
                                        V_ERR_UNIT, V_PLT_QTY, V_BOX_QTY, V_BAG_QTY, V_EA_QTY, '100',
                                        V_PRFM_DT, V_PRD_DT, V_DSTBT_DDLIN, V_WRK_CLASS, V_WRK_SHIFT,
                                        V_PRD_STR_DATE, V_PRD_END_DATE,
                                        'N', 'N', 'N', V_DATE, P_USERID);       

                --기존 설비 및 지시별 폐퓸이력 존재시 수정 처리
                UPDATE TB_WRK016
                   SET CNL_YN        = 'N'
                     , DISPO_QTY     = V_DISPO_QTY      
                     , DOC_NO        = V_DOC_DISPO
                     , DOC_SEQNO     = DOC_SEQNO + 1
                     , IND_BCD_M 	 = V_IND_BCD
                     , LOT_NO_M 	 = V_DISPO_LOT
				     , UPDDATE	     = SYSDATE          
				     , UPDID	     = P_USERID   		
				WHERE WERKS	         = P_WERKS          
				  AND MACH_CD        = P_MACH_CD        
				  --AND PRFM_DT        = V_PRFM_DT        
				  AND WRK_ORDR_NO    = P_WRK_ORDR_NO    
				  AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO;
				--신규 이력인 경우 추가처리
				IF SQL%ROWCOUNT = 0 THEN
	                INSERT INTO TB_WRK016 (WERKS, MACH_CD, WRK_ORDR_NO, WRK_ORDR_SEQNO, IND_BCD, LOT_NO, MATNR
	                                     , IND_BCD_M, LOT_NO_M, MATNR_M, UNIT, ORDER_NO, PRFM_DT
	                                     , TOT_QTY, PRFM_QTY, DISPO_QTY, DISPO_CD
	                                     , WRK_CLASS, WRK_SHIFT, DOC_NO, DOC_SEQNO, REGDATE, REGID)
	                               VALUES (P_WERKS, P_MACH_CD, P_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_IND_BCD, V_LOT_NO, P_MATNR
	                                     , V_IND_BCD, V_DISPO_LOT, V_DISPO_MATNR, V_ERR_UNIT, P_ORDER_NO, V_PRFM_DT
	                                     , V_TOT_QTY, V_PRFM_QTY, V_DISPO_QTY, '100'
	                                     , V_WRK_CLASS, V_WRK_SHIFT, V_DOC_DISPO, '1', V_DATE, P_USERID);
                END IF;
                --인터페이스 전송(하위 반제품 오더의 경우 SAP에서 생성하기에 해당란 공백으로 처리)
                INSERT INTO TB_IFS011(AUFNR, LOTNO, MATNR, WERKS, WORKCENTERCODE, MACHINE, 
                                      WORKGROUP, OPNAM, BUDAT, PROQTY, MEINS, RUNTIME,
                                      SDATE, STIME, EDATE, ETIME, 
                                      MDOCNO, MDOCSEQ, MAKE_DATE, MAKER)
                           VALUES('', V_DISPO_LOT, V_EA_MATNR, P_WERKS, V_SAP_WRK_CD, V_MACHINE, 
                                    V_WRK_CLASS, P_USERID, V_PRFM_DT, V_DISPO_QTY, V_ERR_UNIT, V_RUNTIME, 
                                    TO_CHAR(V_PRD_STR_DATE,'YYYYMMDD'), TO_CHAR(V_PRD_STR_DATE,'HH24MISS'), 
                                    TO_CHAR(V_PRD_END_DATE,'YYYYMMDD'), TO_CHAR(V_PRD_END_DATE,'HH24MISS'),
                                    V_DOC_NO, V_DOC_SEQ, V_DATE, P_USERID);
                --IF 전송이력(1:실적)
                INSERT INTO TB_WRK021(DOC_NO, DOC_SEQNO, DOC_DIV,
                                      WERKS, MACH_CD, WRK_ORDR_NO, WRK_ORDR_SEQNO,
                                      IND_BCD, LOT_NO, ORDER_NO, CNL_YN,
                                      REGDATE, REGID)
                           VALUES(V_DOC_NO, V_DOC_SEQ, 1,
                                    P_WERKS, P_MACH_CD, P_WRK_ORDR_NO, V_WRK_ORDR_SEQNO,
                                    V_IND_BCD, V_LOT_NO, P_ORDER_NO, 'N',
                                    V_DATE, P_USERID);  
                --SAP FUNC ID
                SELECT RFCFN
                  INTO P_WRK_FUNC
                  FROM TB_ITFMA
                 WHERE 1=1
                   AND IFID = V_PIF_ID;
                --인터페이스 파라미터
                OPEN CUR_3 FOR
                SELECT V_PIF_ID AS I_IF_ID
                     , 'M' || LTRIM(RTRIM(TO_CHAR(SEQ_GET_IFR_KEY.NEXTVAL, '00000000000000000000000000000'))) AS I_IF_KEY
                FROM dual;
                --인터페이스 상세 파라미터
                PKG_WRK055.LOG_IF('SP_POP_WRK41_D01', P_WERKS, V_PIF_ID, V_DOC_NO, P_USERID);   -- WRK55 RFC 전송로그
                V_SQL_P := FN_IF_QUERY(V_PIF_ID, V_DOC_NO);
                IF V_SQL_P IS NOT NULL THEN
                	OPEN CUR_4 FOR V_SQL_P;
                END IF;
                --폐품항목 실적등록 문서번호
                P_PRFM_DOC := V_DOC_NO;

                --실적 위치 확인
                BEGIN
                    SELECT NVL(LGPRO,'3100')
                      INTO V_PRFM_LOC
                      FROM TB_MAS001
                     WHERE 1=1
                       AND WERKS = P_WERKS
                       AND MATNR = V_EA_MATNR;
                EXCEPTION WHEN NO_DATA_FOUND THEN
                    V_PRFM_LOC:='3100';
                END;

                --폐품 IF 전송                    
                INSERT INTO TB_IFS012 (AUFNR, LOTNO, BUDAT, MATNR,  
                                        SCRQTY, RSDQTY, MRSCQTY, SCRAPCODE, SCRAPREASON, SCRQTY_OP, LGORT, CHARG, 
                                        SDATE, STIME, EDATE, ETIME, 
                                        RUNTIME, WORKCENTERCODE, MDOCNO, MDOCSEQ, MAKE_DATE, MAKER)
                                VALUES (P_ORDER_NO, V_LOT_NO, V_PRFM_DT, V_EA_MATNR, 
                                        V_DISPO_QTY, 0, 0, '100', '가공폐품', 0, V_PRFM_LOC/*'3100'*/, V_DISPO_LOT,
                                        FN_DT_FORMAT(P_PRD_END_DATE,'YYYYMMDD'), FN_DT_FORMAT(P_PRD_END_DATE,'HH24MISS'), 
                                        FN_DT_FORMAT(P_PRD_END_DATE,'YYYYMMDD'), FN_DT_FORMAT(P_PRD_END_DATE,'HH24MISS'), 
                                        V_RUNTIME, V_SAP_WRK_CD, V_DOC_DISPO, '1', V_DATE, P_USERID);                       
                --SAP FUNC ID
                SELECT RFCFN
                  INTO P_DISPO_FUNC
                  FROM TB_ITFMA
                 WHERE 1=1
                   AND IFID = V_EIF_ID;
                --인터페이스 파라미터
                OPEN CUR_1 FOR
                SELECT V_EIF_ID AS I_IF_ID
                     , 'M' || LTRIM(RTRIM(TO_CHAR(SEQ_GET_IFR_KEY.NEXTVAL, '00000000000000000000000000000'))) AS I_IF_KEY
                FROM dual;
                --인터페이스 상세 파라미터
                PKG_WRK055.LOG_IF('SP_POP_WRK41_D01', P_WERKS, V_EIF_ID, V_DOC_DISPO, P_USERID);   -- WRK55 RFC 전송로그
                V_SQL_E := FN_IF_QUERY(V_EIF_ID, V_DOC_DISPO);
                IF V_SQL_E IS NOT NULL THEN
                	OPEN CUR_2 FOR V_SQL_E;
                END IF;
            END IF;
            --폐품 실적 전송
            --IF 전송이력(2:생산폐품)
            INSERT INTO TB_WRK021(DOC_NO, DOC_SEQNO, DOC_DIV,
                                WERKS, MACH_CD, WRK_ORDR_NO, WRK_ORDR_SEQNO,
                                IND_BCD, LOT_NO, ORDER_NO, CNL_YN,
                                REGDATE, REGID)
                            VALUES(V_DOC_DISPO, TO_NUMBER(V_DOC_SEQ), 2,
                                P_WERKS, P_MACH_CD, P_WRK_ORDR_NO, V_WRK_ORDR_SEQNO,
                                V_IND_BCD, V_LOT_NO, P_ORDER_NO, 'N',
                                V_DATE, P_USERID);
        END IF;


        --작업 정상 종료 코드 등록
        RS_CODE := 'S';
        RS_MSG := '1';
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
END SP_POP_WRK41_D01;
/
