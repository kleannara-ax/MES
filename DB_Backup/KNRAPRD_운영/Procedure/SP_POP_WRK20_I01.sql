--------------------------------------------------------
--  DDL for Procedure SP_POP_WRK20_I01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK20_I01" 
(
    P_WERKS         IN VARCHAR2 
    ,P_PROC_CD      IN VARCHAR2 
    ,P_WRK_LIST     IN CLOB
    ,P_USERID       IN VARCHAR2
    ,P_PRFM_FUNC    OUT VARCHAR2
    ,P_USE_FUNC    OUT VARCHAR2
    ,P_WDOC_NO      OUT VARCHAR2 
    ,Lang           IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE        OUT VARCHAR2 
    ,RS_MSG         OUT VARCHAR2
    ,CUR_1          OUT SYS_REFCURSOR
    ,CUR_2          OUT SYS_REFCURSOR
    ,CUR_3          OUT SYS_REFCURSOR
    ,CUR_4          OUT SYS_REFCURSOR
    ,CUR_5          OUT SYS_REFCURSOR
    ,CUR_6          OUT SYS_REFCURSOR
    ,CUR_7          OUT SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : POP_WRK20
 * PROGRAM NAME  : HL 실적 조회
 * VERSION       : 1.0.0
 * DESCRIPTION   : 선택된 실적의 입고요청 또는 품질검사 요청을 등록한다.
 *                 
 * AUTHOR NAME   : 김기연
 * CREATE DATE   : 2022/05/19
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/05/19    1.0.0   김기연         Initial Version
 *==============================================================================
 *  관련 테이블
 * - [TB_SCH002] : (.R..) 화장지 합지기 생산오더
 * - [TB_SCH011] : (.R..) 화장지 합지기 작업지시
 * - [TB_MAS001] : (.R..) 자재 기준 정보
 * - [TB_WRK001] : (.R..) HL 생산실적 이력
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM                VARCHAR2(100)  := 'SP_POP_WRK20_I01';     -- PROCEDURE NAME
    V_PLT_CD                VARCHAR2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID          VARCHAR2(20) := P_USERID; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD            NUMBER(5) := 0;
    E_SQL_ERR_MSG           VARCHAR2(4000);
    --내부변수 관리
    V_DATE                  DATE := SYSDATE;
    V_PROC_CD               VARCHAR2(20);
    V_DOC_PRFM              VARCHAR2(20); --실적등록 문서번호
    V_DOC_ORDR              VARCHAR2(20); --오더완료 문서번호
    V_DOC_USE               VARCHAR2(20); --자재소요량 문서번호
    V_DOC_NO                VARCHAR2(20); --불출요청 문서번호
    V_DOC_SEQ               VARCHAR2(6);
    V_STOR_LOC_FROM         VARCHAR2(20); --MES 위치
    V_STOR_LOC_TO           VARCHAR2(20); --WMS위치
    V_PLT_QTY               NUMBER(13,1); --PLT수량
    V_BOX_QTY               NUMBER(13,1); --BOX수량
    V_BAG_QTY               NUMBER(13,1); --BAG수량
    V_EA_QTY                NUMBER(13,1); --EA수량
    V_WGT                   NUMBER(13,1); --중량
    V_ORDER_NO              VARCHAR2(20); --생산오더
    V_ORDER_SEQNO           NUMBER;
    V_WRK_ORDR_NO           VARCHAR2(20); --작업지시
    V_WRK_ORDR_SEQNO        NUMBER;
    V_EMPLY_NO              VARCHAR(20); --작업자번호
    V_EMPLY_NM              VARCHAR(20); --작업자명
    V_WRK_CLASS             VARCHAR2(10); --작업조
    V_PRFM_DT               VARCHAR(10); --실적일자
    V_PRD_DT                VARCHAR(10); --생산일자
    V_DSTBT_DDLIN           VARCHAR(10); --유통기간 일자
    V_DSTBT_DAYS            NUMBER(4); --유통기간
    V_ORDR_DATE             DATE; --오더 완료일자
    V_PRFM_STR_DTM          VARCHAR(20); --실적 시작일자
    V_PRFM_END_DTM          VARCHAR(20); --실적 완료일자
    V_RUNTIME               NUMBER; --가동시간
    V_ABNTIME               NUMBER; --비가동시간
    V_COMP_YN               VARCHAR2(1); --완료여부
    V_ORDR_COMP             VARCHAR2(1); --지시 완료여부
    V_MACHINE               VARCHAR2(10); --생산호기
    V_HMACHINE              VARCHAR2(10); --합지생산호기
    V_HMATNR                VARCHAR(20); --합지품목
    V_HUNIT                 VARCHAR(10); --합지단위
    V_HLOTNO1               VARCHAR2(10); --합지LOT1
    V_INPQT1                VARCHAR2(10); --합지수량1
    V_HLOTNO2               VARCHAR2(10); --합지LOT2
    V_INPQT2                VARCHAR2(10); --합지수량2
    V_HLOTNO3               VARCHAR2(10); --합지LOT3
    V_INPQT3                VARCHAR2(10); --합지수량3
    V_SAP_WRK_CD            VARCHAR2(20); --SAP 작업장 코드
    V_HIND_BCD              VARCHAR(20); --합지 개별바코드
    V_IF_ID                 VARCHAR2(20); --MES IF ID
    V_IF_ID_USE             VARCHAR2(20) := 'MES_IF_130'; --자재소요량
    V_SDOC_NO               VARCHAR2(30);
    V_SDOC_NO_CHK           VARCHAR2(30);
    V_SDOC_NO_O             VARCHAR2(30);
    V_SQL                   VARCHAR2(4000);
    --커서용 변수
    V_WERKS                 VARCHAR(4);
    V_MATNR                 VARCHAR(20);
    V_MACH_CD               VARCHAR(10);
    V_IND_BCD               VARCHAR(20);
    V_LOT_NO                VARCHAR(20); --I/F의 경우 14byte
    V_PRFM_QTY              NUMBER(20,0);
    V_UNIT                  VARCHAR(10);
    V_FINISH_CNT            NUMBER;
    -- JSON을 위한 변수선언 영역
    V_JSON           JSON_OBJECT_T;
    V_ARR_LIST       JSON_ARRAY_T;
    V_OBJ            JSON_OBJECT_T;
    
    V_DISTRIBUTE_YN         CMCDV.USE_YN%TYPE;     -- WMS 배포 확인 
BEGIN
    --예외처리 시작(try)
    BEGIN
        -- WMS 배포중인경우 메뉴얼로 CMCDV의 USE_YN을 'Y'로 변경 함.
        SELECT USE_YN
          INTO V_DISTRIBUTE_YN
		  FROM CMCDV
 		 WHERE CMCDKY='SYSTEMCHECK';
         
        IF V_DISTRIBUTE_YN = 'Y' THEN
            RS_CODE := 'E';
            RS_MSG := '시스템 점검 중입니다. 1~5분 동안 잠시만 기다려 주세요.';
            RETURN;
        END IF;
        
        -- 작업조 정보조회
        SELECT WRK_CLASS INTO V_WRK_CLASS
          FROM USRMA
         WHERE 1=1
           AND USERID = P_USERID;

        --JSON 데이터 수신
        V_JSON := JSON_OBJECT_T.parse(P_WRK_LIST); -- 전체 데이터
        V_PROC_CD := V_JSON.get_string('PROC_CD'); -- 프로시저명

        --대상데이터 일치여부 확인
        IF V_PROC_CD = 'POP_WRK20' THEN
            --불출요청 문서번호 작성
            IF P_WERKS = 'P200' THEN
                V_IF_ID := 'MES_IF_124';
                V_DOC_PRFM := FN_GET_MDOCNO('M','IF124');
                --화장지 가공기의 경우 WMS 입고요청 추가진행
                V_DOC_NO := FN_GET_MDOCNO('M','IF402');
                P_WDOC_NO := V_DOC_NO;
            ELSE
                --생리대 일반
                IF P_PROC_CD = 'RB' THEN
                    V_IF_ID := 'MES_IF_133';
                    V_DOC_PRFM := FN_GET_MDOCNO('M','IF133');
                --기저귀 일반
                ELSIF P_PROC_CD = 'RC' THEN
                    V_IF_ID := 'MES_IF_133';
                    V_DOC_PRFM := FN_GET_MDOCNO('M','IF133');
                --생리대 예외생산
                ELSE    
                    V_IF_ID := 'MES_IF_141';
                    V_DOC_PRFM := FN_GET_MDOCNO('M','IF141');
                END IF;
            END IF;
            V_SDOC_NO := V_DOC_PRFM;
            V_DOC_SEQ := '0';
            V_STOR_LOC_FROM := '3100';
            V_STOR_LOC_TO := '3000';
            --세부 데이터 목록 수신
            V_ARR_LIST := V_JSON.get_array('list');
            --각 항목별 처리
            FOR i IN 0..V_ARR_LIST.get_size-1 LOOP
                --행별 데이터 목록 조회
                V_OBJ := TREAT (V_ARR_LIST.get (i) AS json_object_t);
                V_OBJ := TREAT (V_OBJ.get ('map') AS json_object_t);
                --각 항목별 데이터 조회
                V_WERKS := V_OBJ.get_string('WERKS');
                V_MATNR := V_OBJ.get_string('MATNR');
                V_MACH_CD := V_OBJ.get_string('MACH_CD');
                V_IND_BCD := V_OBJ.get_string('IND_BCD');
                V_LOT_NO := V_OBJ.get_string('LOT_NO');
                V_PRFM_QTY := TO_NUMBER(REPLACE(V_OBJ.get_string('PRFM_QTY'),',',''));
                V_UNIT := V_OBJ.get_string('UNIT');
                V_PRFM_DT := V_OBJ.get_string('PRFM_DT');

                --YSH 2022.12.28 SAP 전송여부 체크
                BEGIN
                SELECT SDOC_NO  INTO V_SDOC_NO_CHK
                  FROM TB_WRK001
                 WHERE WERKS = V_WERKS
                   AND IND_BCD = V_IND_BCD;
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        V_SDOC_NO_CHK := '';
                END ;
                
                --SAP 전송이력이 있으면 RETURN
                IF NVL(V_SDOC_NO_CHK, ' ') <> ' ' THEN 
                    RS_CODE := 'E';
                    RS_MSG := V_IND_BCD || ' 는 이미 SAP으로 전송되었습니다. \n다시 조회 후 작업해주시기 바랍니다.';
                    RETURN;
                END IF;
                
                -- 자재정보 조회
                SELECT NVL(DSTBT_DDLIN,0) --DECODE(NVL(DSTBT_DDLIN,0),0,365*3,DSTBT_DDLIN)
                  INTO V_DSTBT_DAYS
                  FROM TB_MAS001
                 WHERE 1=1
                   AND WERKS = P_WERKS
                   AND MATNR = V_MATNR;
                --설비정보 조회
                SELECT MACHINE, SAP_WRK_CD
                  INTO V_MACHINE, V_SAP_WRK_CD
                  FROM TB_MAS012
                 WHERE 1=1
                   AND MACH_CD = V_MACH_CD;

                IF V_WERKS = 'P200' THEN
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
                                      AND I010.MACH_CD = V_MACH_CD
                                      AND I010.MATNR = V_MATNR
                                      AND I010.IND_BCD = V_IND_BCD
                                      AND M001.MATNR_DIV = 'HALB'
                                      AND NVL(I010.CNL_YN,'N') = 'N'
                                    GROUP BY LOT_NO_M)
                            ORDER BY SEQNO)
                     WHERE ROWNUM = 1;
                    EXCEPTION WHEN NO_DATA_FOUND THEN
                        V_HLOTNO1 := '';
                        V_INPQT1 := 0;
                        V_HLOTNO2 := '';
                        V_INPQT2 := 0;
                        V_HLOTNO3 := '';
                        V_INPQT3 := 0;
                        V_HIND_BCD := '';
                        IF P_WERKS = 'P200' THEN
                            RS_CODE := 'E';
                            RS_MSG  := '투입된 합지정보를 찾을수 없습니다.\n합지투입 후 실적을 등록하여 주시기 바랍니다.';
                            RETURN;
                        END IF;
                    END;
                    --투입된 자재 생산호기 확인
                    BEGIN
                        SELECT MACHINE, MATNR, UNIT
                          INTO V_HMACHINE, V_HMATNR, V_HUNIT
                          FROM TB_INV001
                         WHERE 1=1
                           AND ROWNUM < 2
                           AND IND_BCD = V_HIND_BCD
                         ORDER BY MACHINE;
                    EXCEPTION WHEN NO_DATA_FOUND THEN
                        V_HMACHINE := '';
                    END;
                END IF;  
                --유통기간 확인
                IF V_DSTBT_DAYS = 0 THEN
                    V_DSTBT_DDLIN := '';
                ELSE
                    V_DSTBT_DDLIN := TO_CHAR(TO_DATE(V_PRFM_DT,'YYYYMMDD') + V_DSTBT_DAYS,'YYYYMMDD');
                END IF;
                --실적 정보 수정
                UPDATE TB_WRK001
                   SET CHK_PP_YN = 'Y'
                     , CHK_PP_DATE = V_DATE
                     , CHK_PP_ID = p_USERID
                     , UPDDATE = V_DATE
                     , UPDID = P_USERID
                 WHERE 1=1
                   AND WERKS = P_WERKS
                   AND MACH_CD = V_MACH_CD
                   AND IND_BCD = V_IND_BCD;
                --재고 정보 수정
               UPDATE TB_INV001
                  SET CHK_PP_YN = 'Y'
                    , CHK_PP_DATE = V_DATE
                    , CHK_PP_ID = p_USERID
                    , UPDDATE = V_DATE
                    , UPDID = p_USERID
                WHERE 1=1
                  AND WERKS = P_WERKS
                  AND MATNR = V_MATNR
                  AND IND_BCD = V_IND_BCD;

                --요청문서 내부순번 지정
                V_DOC_SEQ := TO_CHAR(i + 1);

                -- 실적정보 조회
                SELECT ORDER_NO, WRK_ORDR_NO, WRK_ORDR_SEQNO, PRD_DT,
                        TO_CHAR(PRD_STR_DATE,'YYYYMMDDHH24MISS'), TO_CHAR(PRD_END_DATE,'YYYYMMDDHH24MISS'), TM,
                        PLT_QTY, BOX_QTY, BAG_QTY, EA_QTY, REGID, COMP_YN
                  INTO V_ORDER_NO, V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_PRD_DT,
                        V_PRFM_STR_DTM , V_PRFM_END_DTM, V_RUNTIME,
                        V_PLT_QTY, V_BOX_QTY, V_BAG_QTY, V_EA_QTY, V_EMPLY_NO, V_COMP_YN
                  FROM TB_WRK001
                 WHERE 1=1
                   AND WERKS = P_WERKS
                   AND MACH_CD = V_MACH_CD
                   AND IND_BCD = V_IND_BCD;

                -- 작업자 정보
                SELECT NMLAST
                  INTO V_EMPLY_NM
                  FROM USRMA
                 WHERE 1=1
                   AND USERID = V_EMPLY_NO;

--                --작업시간계산
--                V_RUNTIME := TO_DATE(V_PRFM_END_DTM,'YYYYMMDDHH24MISS') - TO_DATE(V_PRFM_STR_DTM,'YYYYMMDDHH24MISS');
--                --분단위로 변환
--                V_RUNTIME := CEIL(V_RUNTIME * 24 * 60);
--                V_RUNTIME := CASE WHEN V_RUNTIME = 0 THEN 1 ELSE V_RUNTIME END;
--                --비가동 시간 처리
--                V_RUNTIME := V_RUNTIME - FN_NON_ACT_TM(TO_DATE(V_PRFM_STR_DTM,'YYYYMMDDHH24MISS'),TO_DATE(V_PRFM_END_DTM,'YYYYMMDDHH24MISS'), V_MACH_CD);

                --화장지 가공/포장 완제품 입고요청시 실적 및 입고요청
                IF V_WERKS = 'P200' THEN
                    --지시정보 조회
                    SELECT COMP_YN, TO_DATE(PRD_END_DTM,'YYYYMMDDHH24MISS')
                      INTO V_ORDR_COMP, V_ORDR_DATE
                      FROM TB_SCH012
                     WHERE 1=1
                       AND WERKS = P_WERKS
                       AND WRK_ORDR_NO = V_WRK_ORDR_NO
                       AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO;
                    --화장지 실적
                    INSERT INTO TB_IFS002(AUFNR, LOTNO, PRDCD, WERKS, WORKCENTERCODE, MACHINE, HMACHINE, 
                                            HLOTNO1, HMATNR1, HMEINS1, INPQT1,
                                            HLOTNO2, HMATNR2, HMEINS2, INPQT2,
                                            HLOTNO3, HMATNR3, HMEINS3, INPQT3,
                                            PRDDT, PRODT, WORKGROUP, OPNAM,
                                            PROQTY, MEINS, RUNTIME, 
                                            SDATE, STIME, EDATE, ETIME, 
                                            MDOCNO, MDOCSEQ, MAKE_DATE, MAKER)
                                    VALUES(V_ORDER_NO, V_LOT_NO, V_MATNR, V_WERKS, V_SAP_WRK_CD, V_MACHINE, V_HMACHINE, 
                                            V_HLOTNO1, V_HMATNR, V_HUNIT, V_INPQT1,
                                            V_HLOTNO2, V_HMATNR, V_HUNIT, V_INPQT2,
                                            V_HLOTNO3, V_HMATNR, V_HUNIT, V_INPQT3,
                                            FN_DT_FORMAT(V_PRFM_DT,'YYYYMMDD'), FN_DT_FORMAT(V_PRD_DT,'YYYYMMDD'), V_WRK_CLASS, P_USERID,
                                            V_PRFM_QTY, V_UNIT, V_RUNTIME, 
                                            FN_DT_FORMAT(V_PRFM_STR_DTM,'YYYYMMDD'), FN_DT_FORMAT(V_PRFM_STR_DTM,'HH24MISS'), 
                                            FN_DT_FORMAT(V_PRFM_END_DTM,'YYYYMMDD'), FN_DT_FORMAT(V_PRFM_END_DTM,'HH24MISS'),
                                            V_DOC_PRFM, V_DOC_SEQ, V_DATE, P_USERID);
                    --IF 전송이력(1:실적)
                    INSERT INTO TB_WRK021(DOC_NO, DOC_SEQNO, DOC_DIV,
                                        WERKS, MACH_CD, WRK_ORDR_NO, WRK_ORDR_SEQNO,
                                        IND_BCD, LOT_NO, ORDER_NO, CNL_YN,
                                        REGDATE, REGID)
                                    VALUES(V_DOC_PRFM, V_DOC_SEQ, 1,
                                        V_WERKS, V_MACH_CD, V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO,
                                        V_IND_BCD, V_LOT_NO, V_ORDER_NO, 'N',
                                        V_DATE, P_USERID);                        
                    --완제품 출고 요청 정보
                    INSERT INTO TB_IFSWM005 (DOC_NO, DOC_SEQNO, DLFL, IND_BCD, LOT_NO, MACHINE
                                            , WERKS, MATNR, QTY, UNIT, ORDER_NO, ORDER_SEQNO, NTN_CD
                                            , STOR_LOC_FROM, STOR_LOC_TO, DSTBT_DDLIN
                                            , REQ_DT, RCVGDS_DT, IF_GET_DATE, EMPLY_NO, EMPLY_NM, PRDC_DT)
                                   VALUES (V_DOC_NO, V_DOC_SEQ, 'C', V_IND_BCD, V_LOT_NO, V_MACHINE
                                            , V_WERKS, V_MATNR, V_PRFM_QTY, V_UNIT, V_ORDER_NO, 1, 'KR'
                                            , V_STOR_LOC_FROM, V_STOR_LOC_TO, V_DSTBT_DDLIN
                                            , TO_CHAR(V_DATE,'YYYYMMDD'), TO_CHAR(V_DATE,'YYYYMMDD'), V_DATE,V_EMPLY_NO, V_EMPLY_NM, V_PRFM_DT); 
                    --완제품 출고 이력                        
                    INSERT INTO TB_WRK015 (DOC_NO, DOC_SEQNO, DLFL, WERKS,
                                            MATNR, QTY, UNIT, STOR_LOC_FR, STOR_LOC_TO,
                                            PLT_QTY, BOX_QTY, BAG_QTY, EA_QTY,
                                            IND_BCD, LOT_NO, MACHINE,
                                            ORDER_NO, ORDER_SEQNO, WRK_ORDR_NO, WRK_ORDR_SEQNO,
                                            EMPLY_NO, EMPLY_NM, PRD_DT, PRFM_DT, RCVGDS_DT, DSTBT_DDLIN,
                                            REQ_STA, REGDATE, REGID)
                                    VALUES (V_DOC_NO, V_DOC_SEQ, 'C', V_WERKS,
                                            V_MATNR, V_PRFM_QTY, V_UNIT, V_STOR_LOC_FROM, V_STOR_LOC_TO,
                                            V_PLT_QTY, V_BOX_QTY, V_BAG_QTY, V_EA_QTY,
                                            V_IND_BCD, V_LOT_NO, V_MACHINE,
                                            V_ORDER_NO, 1, V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO,
                                            V_EMPLY_NO, V_EMPLY_NM, V_PRD_DT, V_PRFM_DT, TO_CHAR(V_DATE,'YYYYMMDD'), V_DSTBT_DDLIN,
                                            'R', V_DATE, P_USERID);  
                    --출고요청시 상태 변경
                    UPDATE TB_INV001
                       SET STCK_STA = '80'
                     WHERE 1=1
                       AND WERKS = P_WERKS
                       AND MATNR = V_MATNR
                       AND IND_BCD = V_IND_BCD;
                ELSE
                    IF SUBSTR(V_MACH_CD,1,3) = 'SRB' THEN
                        --지시정보 조회
                        SELECT COMP_YN, TO_DATE(PRD_END_DTM,'YYYYMMDDHH24MISS')
                          INTO V_ORDR_COMP, V_ORDR_DATE
                          FROM TB_SCH013
                         WHERE 1=1
                           AND WERKS = P_WERKS
                           AND WRK_ORDR_NO = V_WRK_ORDR_NO
                           AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO;
                         --생리대 실적
                        INSERT INTO TB_IFS011(AUFNR, LOTNO, MATNR, WERKS, WORKCENTERCODE, MACHINE, 
                                              WORKGROUP, OPNAM, BUDAT, PROQTY, MEINS, RUNTIME,
                                              SDATE, STIME, EDATE, ETIME, 
                                              MDOCNO, MDOCSEQ, MAKE_DATE, MAKER)
                                   VALUES(V_ORDER_NO, V_LOT_NO, V_MATNR, V_WERKS, V_SAP_WRK_CD, V_MACHINE, 
                                            V_WRK_CLASS, P_USERID, FN_DT_FORMAT(V_PRFM_DT,'YYYYMMDD'), V_PRFM_QTY, V_UNIT, V_RUNTIME, 
                                            FN_DT_FORMAT(V_PRFM_STR_DTM,'YYYYMMDD'), FN_DT_FORMAT(V_PRFM_STR_DTM,'HH24MISS'), 
                                            FN_DT_FORMAT(V_PRFM_END_DTM,'YYYYMMDD'), FN_DT_FORMAT(V_PRFM_END_DTM,'HH24MISS'),
                                            V_DOC_PRFM, TO_CHAR(V_DOC_SEQ), V_DATE, P_USERID);
                        --IF 전송이력(1:실적)
                        INSERT INTO TB_WRK021(DOC_NO, DOC_SEQNO, DOC_DIV,
                                            WERKS, MACH_CD, WRK_ORDR_NO, WRK_ORDR_SEQNO,
                                            IND_BCD, LOT_NO, ORDER_NO, CNL_YN,
                                            REGDATE, REGID)
                                        VALUES(V_DOC_PRFM, V_DOC_SEQ, 1,
                                            V_WERKS, V_MACH_CD, V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO,
                                            V_IND_BCD, V_LOT_NO, V_ORDER_NO, 'N',
                                            V_DATE, P_USERID);
                    --기저귀 공정 생리대와 동일하게 완제품 실적 등록처리 20220922
                    ELSIF SUBSTR(V_MACH_CD,1,3) = 'BRC' THEN
                    	--지시정보 조회
                        SELECT COMP_YN, TO_DATE(PRD_END_DTM,'YYYYMMDDHH24MISS')
                          INTO V_ORDR_COMP, V_ORDR_DATE
                          FROM TB_SCH014
                         WHERE 1=1
                           AND WERKS = P_WERKS
                           AND WRK_ORDR_NO = V_WRK_ORDR_NO
                           AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO;
                         --생리대 실적
                        INSERT INTO TB_IFS011(AUFNR, LOTNO, MATNR, WERKS, WORKCENTERCODE, MACHINE, 
                                              WORKGROUP, OPNAM, BUDAT, PROQTY, MEINS, RUNTIME,
                                              SDATE, STIME, EDATE, ETIME, 
                                              MDOCNO, MDOCSEQ, MAKE_DATE, MAKER)
                                   VALUES(V_ORDER_NO, V_LOT_NO, V_MATNR, V_WERKS, V_SAP_WRK_CD, V_MACHINE, 
                                            V_WRK_CLASS, P_USERID, FN_DT_FORMAT(V_PRFM_DT,'YYYYMMDD'), V_PRFM_QTY, V_UNIT, V_RUNTIME, 
                                            FN_DT_FORMAT(V_PRFM_STR_DTM,'YYYYMMDD'), FN_DT_FORMAT(V_PRFM_STR_DTM,'HH24MISS'), 
                                            FN_DT_FORMAT(V_PRFM_END_DTM,'YYYYMMDD'), FN_DT_FORMAT(V_PRFM_END_DTM,'HH24MISS'),
                                            V_DOC_PRFM, TO_CHAR(V_DOC_SEQ), V_DATE, P_USERID);
                        --IF 전송이력(1:실적)
                        INSERT INTO TB_WRK021(DOC_NO, DOC_SEQNO, DOC_DIV,
                                            WERKS, MACH_CD, WRK_ORDR_NO, WRK_ORDR_SEQNO,
                                            IND_BCD, LOT_NO, ORDER_NO, CNL_YN,
                                            REGDATE, REGID)
                                        VALUES(V_DOC_PRFM, V_DOC_SEQ, 1,
                                            V_WERKS, V_MACH_CD, V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO,
                                            V_IND_BCD, V_LOT_NO, V_ORDER_NO, 'N',
                                            V_DATE, P_USERID); 
                    ELSE
                        --지시정보 조회
                        SELECT COMP_YN, TO_DATE(PRD_END_DTM,'YYYYMMDDHH24MISS')
                          INTO V_ORDR_COMP, V_ORDR_DATE
                          FROM TB_SCH019
                         WHERE 1=1
                           AND WERKS = P_WERKS
                           AND WRK_ORDR_NO = V_WRK_ORDR_NO
                           AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO;
                        --예외생산 실적
                        INSERT INTO TB_IFS019(AUFNR, LOTNO, WERKS, BUDAT, MATNR, 
                                        PROQTY, MEINS, RUNTIME, OPNAM, SDATE, STIME, EDATE, ETIME, 
                                        MDOCNO, MDOCSEQ, MAKE_DATE, MAKER)
                                VALUES(V_ORDER_NO, V_LOT_NO, V_WERKS, FN_DT_FORMAT(V_PRFM_DT,'YYYYMMDD'), V_MATNR, 
                                        V_PRFM_QTY, V_UNIT, V_RUNTIME, P_USERID,
                                        FN_DT_FORMAT(V_PRFM_STR_DTM,'YYYYMMDD'), FN_DT_FORMAT(V_PRFM_STR_DTM,'HH24MISS'), 
                                        FN_DT_FORMAT(V_PRFM_END_DTM,'YYYYMMDD'), FN_DT_FORMAT(V_PRFM_END_DTM,'HH24MISS'),
                                        V_DOC_PRFM, TO_CHAR(V_DOC_SEQ), V_DATE, P_USERID);  
                        --IF 전송이력(1:실적)
                        INSERT INTO TB_WRK021(DOC_NO, DOC_SEQNO, DOC_DIV,
                                            WERKS, MACH_CD, WRK_ORDR_NO, WRK_ORDR_SEQNO,
                                            IND_BCD, LOT_NO, ORDER_NO, CNL_YN,
                                            REGDATE, REGID)
                                        VALUES(V_DOC_PRFM, V_DOC_SEQ, 1,
                                            V_WERKS, V_MACH_CD, V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO,
                                            V_IND_BCD, V_LOT_NO, V_ORDER_NO, 'N',
                                            V_DATE, P_USERID); 
                    END IF;
                END IF;    
                --실적 정보에 문서정보 추가
                UPDATE TB_WRK001
                   SET DOC_NO = V_DOC_PRFM--V_DOC_NO
                     , DOC_SEQNO = V_DOC_SEQ
                     , COMP_YN = V_COMP_YN
                 WHERE 1=1
                   AND WERKS = P_WERKS
                   AND MACH_CD = V_MACH_CD
                   AND IND_BCD = V_IND_BCD;
                --재고 정보에 문서정보 추가
                UPDATE TB_INV001
                   SET DOC_NO = V_DOC_PRFM--V_DOC_NO
                     , DOC_SEQNO = V_DOC_SEQ
                 WHERE 1=1
                   AND WERKS = P_WERKS
                   AND MATNR = V_MATNR
                   AND IND_BCD = V_IND_BCD;
                --자재 사용량 IF정보 조회
                SELECT MAX(DOC_NO)
                  INTO V_DOC_USE
                  FROM TB_INV010
                 WHERE 1=1
                   AND WERKS = P_WERKS
                   AND MACH_CD = V_MACH_CD
                   AND MATNR = V_MATNR
                   AND IND_BCD = V_IND_BCD
                   AND NVL(CNL_YN,'N') = 'N'
                   ;

                    --인터페이스
                IF V_COMP_YN = 'Y' THEN
                    --작업지시가 이미 완료된 경우 IF처리
                    V_ORDR_DATE := V_ORDR_DATE + (INTERVAL '1' SECOND);
                    
                    IF V_ORDR_COMP = 'Y' THEN
                    	V_FINISH_CNT := 0;
                        
                        IF V_WERKS = 'P200' THEN
                            BEGIN
                                SELECT COUNT(AUFNR) INTO V_FINISH_CNT
                                  FROM TB_IFS002
                                 WHERE AUFNR = V_ORDER_NO
                                   AND CONF = 'X';
                                EXCEPTION
                                    WHEN NO_DATA_FOUND THEN
                                        V_FINISH_CNT := 0;
                                END;   
                        ELSE
                            IF SUBSTR(V_MACH_CD,1,3) = 'SRB' OR SUBSTR(V_MACH_CD,1,3) = 'BRC' THEN
                                BEGIN
                                SELECT COUNT(AUFNR) INTO V_FINISH_CNT
                                  FROM TB_IFS011
                                 WHERE AUFNR = V_ORDER_NO
                                   AND CONF = 'X';
                                EXCEPTION
                                    WHEN NO_DATA_FOUND THEN
                                        V_FINISH_CNT := 0;
                                END;   
                            ELSE
                                BEGIN
                                SELECT COUNT(AUFNR) INTO V_FINISH_CNT
                                  FROM TB_IFS019
                                 WHERE AUFNR = V_ORDER_NO
                                   AND CONF = 'X';
                                EXCEPTION
                                    WHEN NO_DATA_FOUND THEN
                                        V_FINISH_CNT := 0;
                                END;
                            END IF;
                        END IF;
                        
                        IF V_FINISH_CNT = 0 THEN
                            --오더 완료시 순번 추가
                            V_DOC_SEQ := TO_CHAR(TO_NUMBER(V_DOC_SEQ) + 1);
                            --실적 문서 번호 생성
                            IF V_WERKS = 'P200' THEN
                                V_DOC_ORDR := FN_GET_MDOCNO('M','IF124');
    
                                --지시 완료실적 SAP전송             
                                INSERT INTO TB_IFS002(AUFNR, LOTNO, PRDCD, WERKS, WORKCENTERCODE, MACHINE, HMACHINE,
                                                    HLOTNO1, HMATNR1, HMEINS1, INPQT1,
                                                    HLOTNO2, HMATNR2, HMEINS2, INPQT2,
                                                    HLOTNO3, HMATNR3, HMEINS3, INPQT3,
                                                    PRDDT, PRODT, WORKGROUP, OPNAM, CONF, PROQTY, MEINS,
                                                    RUNTIME, SDATE, STIME, EDATE, ETIME, 
                                                    MDOCNO, MDOCSEQ, MAKE_DATE, MAKER)
                                            VALUES(V_ORDER_NO, V_LOT_NO, V_MATNR, V_WERKS, V_SAP_WRK_CD, V_MACHINE, V_HMACHINE, --합지호기 추후 수정필요
                                                    V_HLOTNO1, V_HMATNR, V_HUNIT, 0,
                                                    V_HLOTNO2, V_HMATNR, V_HUNIT, 0,
                                                    V_HLOTNO3, V_HMATNR, V_HUNIT, 0,
                                                    TO_CHAR(V_ORDR_DATE,'YYYYMMDD'), TO_CHAR(V_ORDR_DATE,'YYYYMMDD'), V_WRK_CLASS, P_USERID, 'X', 0, V_UNIT,
                                                    0, TO_CHAR(V_ORDR_DATE,'YYYYMMDD'), TO_CHAR(V_ORDR_DATE,'HH24MISS'), 
                                                    TO_CHAR(V_ORDR_DATE,'YYYYMMDD'), TO_CHAR(V_ORDR_DATE,'HH24MISS'),
                                                    V_DOC_ORDR, '1', V_DATE, P_USERID);
                                    --IF 전송이력(20:오더완료)
                                    INSERT INTO TB_WRK021(DOC_NO, DOC_SEQNO, DOC_DIV,
                                                        WERKS, MACH_CD, WRK_ORDR_NO, WRK_ORDR_SEQNO,
                                                        IND_BCD, LOT_NO, ORDER_NO, CNL_YN,
                                                        REGDATE, REGID)
                                                    VALUES(V_DOC_PRFM, TO_NUMBER(V_DOC_SEQ), 20,
                                                        P_WERKS, V_MACH_CD, V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO,
                                                        ' ', V_LOT_NO, V_ORDER_NO, 'N',
                                                        V_DATE, P_USERID);
                            ELSE
                                IF SUBSTR(V_MACH_CD,1,3) = 'SRB' THEN
                                    V_DOC_ORDR := FN_GET_MDOCNO('M','IF133');
    
                                    --지시 완료실적 SAP전송             
                                    INSERT INTO TB_IFS011(AUFNR, LOTNO, MATNR, WERKS, WORKCENTERCODE, MACHINE, 
                                                        WORKGROUP, OPNAM, BUDAT, PROQTY, MEINS, CONF, RUNTIME,
                                                        SDATE, STIME, EDATE, ETIME, 
                                                        MDOCNO, MDOCSEQ, MAKE_DATE, MAKER)
                                                    VALUES(V_ORDER_NO, V_LOT_NO, V_MATNR, V_WERKS, V_SAP_WRK_CD, V_MACHINE, 
                                                        V_WRK_CLASS, P_USERID, FN_DT_FORMAT(V_PRFM_DT,'YYYYMMDD'), 0, V_UNIT, 'X', 0, 
                                                        TO_CHAR(V_ORDR_DATE,'YYYYMMDD'), TO_CHAR(V_ORDR_DATE,'HH24MISS'), 
                                                        TO_CHAR(V_ORDR_DATE,'YYYYMMDD'), TO_CHAR(V_ORDR_DATE,'HH24MISS'),
                                                        V_DOC_ORDR, TO_CHAR(V_DOC_SEQ), V_DATE, P_USERID);
                                    --IF 전송이력(20:오더완료)
                                    INSERT INTO TB_WRK021(DOC_NO, DOC_SEQNO, DOC_DIV,
                                                        WERKS, MACH_CD, WRK_ORDR_NO, WRK_ORDR_SEQNO,
                                                        IND_BCD, LOT_NO, ORDER_NO, CNL_YN,
                                                        REGDATE, REGID)
                                                    VALUES(V_DOC_PRFM, TO_NUMBER(V_DOC_SEQ), 20,
                                                        P_WERKS, V_MACH_CD, V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO,
                                                        ' ', V_LOT_NO, V_ORDER_NO, 'N',
                                                        V_DATE, P_USERID);
                                --기저귀 공정 생리대와 동일하게 완제품 실적 등록처리 20220922
                                ELSIF SUBSTR(V_MACH_CD,1,3) = 'BRC' THEN
                                    V_DOC_ORDR := FN_GET_MDOCNO('M','IF133');
    
                                    --지시 완료실적 SAP전송             
                                    INSERT INTO TB_IFS011(AUFNR, LOTNO, MATNR, WERKS, WORKCENTERCODE, MACHINE, 
                                                        WORKGROUP, OPNAM, BUDAT, PROQTY, MEINS, CONF, RUNTIME,
                                                        SDATE, STIME, EDATE, ETIME, 
                                                        MDOCNO, MDOCSEQ, MAKE_DATE, MAKER)
                                                    VALUES(V_ORDER_NO, V_LOT_NO, V_MATNR, V_WERKS, V_SAP_WRK_CD, V_MACHINE, 
                                                        V_WRK_CLASS, P_USERID, FN_DT_FORMAT(V_PRFM_DT,'YYYYMMDD'), 0, V_UNIT, 'X', 0, 
                                                        TO_CHAR(V_ORDR_DATE,'YYYYMMDD'), TO_CHAR(V_ORDR_DATE,'HH24MISS'), 
                                                        TO_CHAR(V_ORDR_DATE,'YYYYMMDD'), TO_CHAR(V_ORDR_DATE,'HH24MISS'),
                                                        V_DOC_ORDR, TO_CHAR(V_DOC_SEQ), V_DATE, P_USERID);
                                    --IF 전송이력(20:오더완료)
                                    INSERT INTO TB_WRK021(DOC_NO, DOC_SEQNO, DOC_DIV,
                                                        WERKS, MACH_CD, WRK_ORDR_NO, WRK_ORDR_SEQNO,
                                                        IND_BCD, LOT_NO, ORDER_NO, CNL_YN,
                                                        REGDATE, REGID)
                                                    VALUES(V_DOC_PRFM, TO_NUMBER(V_DOC_SEQ), 20,
                                                        P_WERKS, V_MACH_CD, V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO,
                                                        ' ', V_LOT_NO, V_ORDER_NO, 'N',
                                                        V_DATE, P_USERID);
                                ELSE
                                    V_DOC_ORDR := FN_GET_MDOCNO('M','IF141');
    
                                    --예외생산 실적
                                    INSERT INTO TB_IFS019(AUFNR, LOTNO, WERKS, BUDAT, MATNR, 
                                                    PROQTY, MEINS, CONF, RUNTIME, OPNAM, SDATE, STIME, EDATE, ETIME, 
                                                    MDOCNO, MDOCSEQ, MAKE_DATE, MAKER)
                                            VALUES(V_ORDER_NO, V_LOT_NO, V_WERKS, FN_DT_FORMAT(V_PRFM_DT,'YYYYMMDD'), V_MATNR, 
                                                    0, V_UNIT, 'X', '0', P_USERID,
                                                    TO_CHAR(V_ORDR_DATE,'YYYYMMDD'), TO_CHAR(V_ORDR_DATE,'HH24MI'), 
                                                    TO_CHAR(V_ORDR_DATE,'YYYYMMDD'), TO_CHAR(V_ORDR_DATE,'HH24MI'),
                                                    V_DOC_ORDR, TO_CHAR(V_DOC_SEQ), V_DATE, P_USERID);  
                                    --IF 전송이력(20:오더완료)
                                    INSERT INTO TB_WRK021(DOC_NO, DOC_SEQNO, DOC_DIV,
                                                        WERKS, MACH_CD, WRK_ORDR_NO, WRK_ORDR_SEQNO,
                                                        IND_BCD, LOT_NO, ORDER_NO, CNL_YN,
                                                        REGDATE, REGID)
                                                    VALUES(V_DOC_PRFM, TO_NUMBER(V_DOC_SEQ), 20,
                                                        P_WERKS, V_MACH_CD, V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO,
                                                        ' ', V_LOT_NO, V_ORDER_NO, 'N',
                                                        V_DATE, P_USERID);
                                END IF;
                            END IF;
                            V_SDOC_NO_O := V_DOC_ORDR;
                            V_DOC_SEQ := '1';
    
                            --IF 전송이력(20:오더 완료)
                            INSERT INTO TB_WRK021(DOC_NO, DOC_SEQNO, DOC_DIV,
                                                WERKS, MACH_CD, WRK_ORDR_NO, WRK_ORDR_SEQNO,
                                                IND_BCD, LOT_NO, ORDER_NO, CNL_YN,
                                                REGDATE, REGID)
                            VALUES(V_DOC_ORDR, V_DOC_SEQ, 20,
                                                V_WERKS, V_MACH_CD, V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO,
                                                V_IND_BCD, V_LOT_NO, V_ORDER_NO, 'N',
                                                V_DATE, P_USERID);     
                        END IF;                        
                    END IF;
                END IF;

            END LOOP;

            --SAP FUNC ID
            --실적 등록
            SELECT RFCFN
              INTO P_PRFM_FUNC
              FROM TB_ITFMA
             WHERE 1=1
               AND IFID = V_IF_ID;
            --인터페이스 파라미터
            OPEN CUR_1 FOR
            SELECT V_IF_ID AS I_IF_ID
                 , 'M' || LTRIM(RTRIM(TO_CHAR(SEQ_GET_IFR_KEY.NEXTVAL, '00000000000000000000000000000'))) AS I_IF_KEY
            FROM dual;
            --인터페이스 상세 파라미터
            V_SQL := FN_IF_QUERY(V_IF_ID, V_DOC_PRFM);
            IF V_SQL IS NOT NULL THEN
            	OPEN CUR_2 FOR V_SQL;
            END IF;

            --완제품 입고요청
            V_SQL := FN_IF_QUERY('MES_IF_402', V_DOC_NO);
            IF V_SQL IS NOT NULL THEN
            	OPEN CUR_3 FOR V_SQL;
            END IF;

            --자재 사용량
            IF V_DOC_NO IS NOT NULL THEN
                --SAP FUNC ID 130
                SELECT RFCFN
                  INTO P_USE_FUNC
                  FROM TB_ITFMA
                 WHERE 1=1
                   AND IFID = V_IF_ID_USE;
                --인터페이스 파라미터
                OPEN CUR_4 FOR
                SELECT V_IF_ID_USE AS I_IF_ID
                     , 'M' || LTRIM(RTRIM(TO_CHAR(SEQ_GET_IFR_KEY.NEXTVAL, '00000000000000000000000000000'))) AS I_IF_KEY
                FROM dual;
                --인터페이스 상세 파라미터
                V_SQL := FN_IF_QUERY(V_IF_ID_USE, V_DOC_USE);
                IF V_SQL IS NOT NULL THEN
                	OPEN CUR_5 FOR V_SQL;
                END IF;
            END IF;

            --오더완료 실적
            IF V_DOC_ORDR IS NOT NULL THEN
                OPEN CUR_6 FOR
                SELECT V_IF_ID AS I_IF_ID
                     , 'M' || LTRIM(RTRIM(TO_CHAR(SEQ_GET_IFR_KEY.NEXTVAL, '00000000000000000000000000000'))) AS I_IF_KEY
                FROM dual;
                --인터페이스 상세 파라미터
                V_SQL := FN_IF_QUERY(V_IF_ID, V_DOC_ORDR);
                IF V_SQL IS NOT NULL THEN
                	OPEN CUR_7 FOR V_SQL;
                END IF;
            END IF;

            --작업 정상 종료 코드 등록
            RS_CODE := 'S';
        ELSE    
            RS_CODE := 'E';
            RS_MSG := 'PROCEDURE ERROR';
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
--    WHEN OTHERS THEN
--        E_SQL_ERR_CD        := -20001;
--        E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';
--
--        ROLLBACK;
--        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
--
--        RS_CODE := 'E';
--        RS_MSG  := SQLERRM;
--        RETURN;
    --예외처리 종료
    END;
END SP_POP_WRK20_I01;

/
