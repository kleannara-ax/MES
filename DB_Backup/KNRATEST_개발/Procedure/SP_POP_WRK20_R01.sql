--------------------------------------------------------
--  DDL for Procedure SP_POP_WRK20_R01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK20_R01" 
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
    -- JSON을 위한 변수선언 영역
    V_JSON           JSON_OBJECT_T;
    V_ARR_LIST       JSON_ARRAY_T;
    V_OBJ            JSON_OBJECT_T;
    
    V_DISTRIBUTE_YN         CMCDV.USE_YN%TYPE;     -- WMS 배포 확인 
BEGIN
    --예외처리 시작(try)
    BEGIN
        --JSON 데이터 수신
        V_JSON := JSON_OBJECT_T.parse(P_WRK_LIST); -- 전체 데이터
        V_PROC_CD := V_JSON.get_string('PROC_CD'); -- 프로시저명

        --대상데이터 일치여부 확인
        IF V_PROC_CD = 'POP_WRK20' THEN
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
                
                IF V_WERKS = 'P200' THEN
                    --실적 정보 수정
                    UPDATE TB_WRK001
                       SET CHK_PP_YN = 'N'  -- Y => N
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
                      SET CHK_PP_YN = 'N'  -- Y => N
                        , CHK_PP_DATE = V_DATE
                        , CHK_PP_ID = p_USERID
                        , UPDDATE = V_DATE
                        , UPDID = p_USERID
                    WHERE 1=1
                      AND WERKS = P_WERKS
                      AND MATNR = V_MATNR
                      AND IND_BCD = V_IND_BCD;
                      
                    --출고요청시 상태 변경
                    UPDATE TB_INV001
                       SET STCK_STA = '00' -- 80 => 00
                     WHERE 1=1
                       AND WERKS = P_WERKS
                       AND MATNR = V_MATNR
                       AND IND_BCD = V_IND_BCD;
                END IF;         
            END LOOP;

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
END SP_POP_WRK20_R01;

/
