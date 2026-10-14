--------------------------------------------------------
--  DDL for Procedure SP_POP_INV01_I01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_INV01_I01" 
(
    P_WERKS         IN VARCHAR2 
    ,P_PROC_CD      IN VARCHAR2 
    ,P_WRK_ORDR     IN VARCHAR2 
    ,P_WRK_ORDR_SEQ IN VARCHAR2 
    ,P_WRK_LIST     IN CLOB
    ,P_USERID       IN VARCHAR2
    ,Lang           IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE        OUT VARCHAR2 
    ,RS_MSG         OUT VARCHAR2
    ,CUR_1          OUT SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : POP_INV01
 * PROGRAM NAME  : 자재불출요청
 * VERSION       : 1.0.1
 * DESCRIPTION   : 선택된 생산오더의 자재요청을 등록한다.
 *                 
 * AUTHOR NAME   : 김기연
 * CREATE DATE   : 2022/05/13
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/05/13    1.0.0   김기연         Initial Version
 *==============================================================================
 *  관련 테이블
 * - [TB_SCH002] : (.R..) 화장지 합지기 생산오더
 * - [TB_SCH011] : (.R..) 화장지 합지기 작업지시
 * - [TB_MAS001] : (.R..) 자재 기준 정보
 * - [TB_WRK001] : (.R..) HL 생산실적 이력
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM            VARCHAR2(100)  := 'SP_POP_INV01_I01';     -- PROCEDURE NAME
    V_PLT_CD            VARCHAR2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID      VARCHAR2(20) := P_USERID; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD        NUMBER(5) := 0;
    E_SQL_ERR_MSG       VARCHAR2(4000);
    --내부변수 관리
    V_DATE              DATE := SYSDATE;
    V_PROC_CD           VARCHAR2(20);
    V_DOC_NO            VARCHAR2(20); --불출요청 문서번호
    V_DOC_SEQ           VARCHAR2(6);
    V_SEQNO             NUMBER;
    V_STOR_LOC          VARCHAR2(4);
    V_WMS_QTY           NUMBER(28,3);
    V_MATNR_LIST        VARCHAR2(4000); --수량부족 품목 목록
    V_MATNR_NM          VARCHAR2(1000);
    V_DOC_LIST          VARCHAR2(4000);
    V_LOC_FLG           VARCHAR2(1); --저장위치 검사결과
    V_DIV_FLG           VARCHAR2(4); --자재구분 결과
    V_SQL               VARCHAR2(4000);
    --커서용 변수
    V_CHK               VARCHAR(1);
    --V_WERKS VARCHAR(4);
    V_MATNR             VARCHAR(20);
    V_REQ_QTY           NUMBER(28,3);
    V_UNIT              VARCHAR(10);
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
	    
        --JSON 데이터 수신
        V_JSON := JSON_OBJECT_T.parse(P_WRK_LIST); -- 전체 데이터
        V_PROC_CD := V_JSON.get_string('PROC_CD'); -- 프로시저명

        --대상데이터 일치여부 확인
        IF V_PROC_CD = 'POP_INV01' THEN
--            --불출요청 문서번호 작성
--            V_DOC_NO := FN_GET_MDOCNO('M','IF201');
--            V_DOC_SEQ := '1';
            --세부 데이터 목록 수신
            V_ARR_LIST := V_JSON.get_array('list');
            --각 항목별 처리
            V_SEQNO := 0;
            --문제 재고목록
            V_MATNR_LIST := '';
            --WMS 재고 확인
            FOR i IN 0..V_ARR_LIST.get_size-1 LOOP
                --행별 데이터 목록 조회
                V_OBJ := TREAT (V_ARR_LIST.get (i) AS json_object_t);
                V_OBJ := TREAT (V_OBJ.get ('map') AS json_object_t);
                --각 항목별 데이터 조회
                V_CHK := V_OBJ.get_string('CHK');
                --V_WERKS := V_OBJ.get_string('WERKS');
                V_MATNR := V_OBJ.get_string('MATNR');
                V_REQ_QTY := TO_NUMBER(REPLACE(V_OBJ.get_string('REQ_QTY'),','));
                V_UNIT := V_OBJ.get_string('UNIT');
                --요청수량 존재여부 확인
                IF V_REQ_QTY > 0 AND V_CHK = 'V' THEN
                    --자재정보 조회  
                    SELECT MATNR_DIV
                      INTO V_DIV_FLG
                      FROM TB_MAS001
                     WHERE 1=1
                       AND WERKS = P_WERKS
                       AND MATNR = V_MATNR;
                    IF V_DIV_FLG = 'HALB' THEN
                        RS_CODE := 'E';
                        RS_MSG := '반제품은 출고요청이 불가능 합니다.';
                        RETURN;
                    END IF;
                    SELECT DECODE(NVL(LGPRO,'X'),LGFSB,'E','X','N','Y')
                      INTO V_LOC_FLG
                      FROM TB_MAS001
                     WHERE 1=1
                       AND WERKS = P_WERKS
                       AND MATNR = V_MATNR;
                    IF V_LOC_FLG = 'E' AND V_DIV_FLG != 'FERT' AND V_DIV_FLG != 'HAWA' THEN
                        RS_CODE := 'E';
                        RS_MSG := '외부저장위치와 투입저장위치가 동일합니다.';
                        RETURN;
                    ELSIF V_LOC_FLG = 'N' AND V_DIV_FLG != 'FERT' AND V_DIV_FLG != 'HAWA' THEN
                        RS_CODE := 'E';
                        RS_MSG := '투입저장위치가 지정되지 않았습니다.\n품목기준정보를 확인하시기 바랍니다.';
                        RETURN;
                    END IF;
                    --WMS 수량 조회
                    SELECT SUM(FN_CHG_UNIT(SKUKEY, LOTA02, UOMKEY, V_UNIT, USEQTY)) 
                      INTO V_WMS_QTY
                      FROM V_WMS_STKKY@KNRAWMSLINK
                     WHERE 1=1
                       AND LOTA02 = P_WERKS
                       AND SKUKEY = V_MATNR;
                    --WMS 수량 확인
                    IF V_WMS_QTY IS NULL OR V_REQ_QTY > V_WMS_QTY THEN
                        IF V_MATNR_LIST IS NULL THEN
                            V_MATNR_LIST := V_MATNR;
                        ELSE
                            V_MATNR_LIST := V_MATNR_LIST || ',' || V_MATNR;
                        END IF;
                        --자재명 조회
                        SELECT MATNR_NM
                          INTO V_MATNR_NM
                          FROM TB_MAS001
                         WHERE 1=1
                           AND WERKS = P_WERKS
                           AND MATNR = V_MATNR;
                        V_MATNR_LIST := V_MATNR_LIST || ':' || V_MATNR_NM;
                    END IF;
                END IF;
            END LOOP;
            --수량 부족 여부 확인
            IF LENGTH(V_MATNR_LIST) IS NOT NULL THEN
                RS_CODE := 'Q';
                RS_MSG := V_MATNR_LIST;
                RETURN;
            END IF;
            --불출요청
            FOR i IN 0..V_ARR_LIST.get_size-1 LOOP
                --행별 데이터 목록 조회
                V_OBJ := TREAT (V_ARR_LIST.get (i) AS json_object_t);
                V_OBJ := TREAT (V_OBJ.get ('map') AS json_object_t);
                --각 항목별 데이터 조회
                --V_WERKS := V_OBJ.get_string('WERKS');
                V_CHK := V_OBJ.get_string('CHK');
                V_MATNR := V_OBJ.get_string('MATNR');
                V_REQ_QTY := TO_NUMBER(REPLACE(V_OBJ.get_string('REQ_QTY'),','));
                V_UNIT := V_OBJ.get_string('UNIT'); --'PAL';
                --요청수량 존재여부 확인
                IF V_REQ_QTY > 0 AND V_CHK = 'V' THEN
                    --불출요청 문서번호 작성
                    V_DOC_NO := FN_GET_MDOCNO('M','IF201');
                    V_DOC_SEQ := '1';
                    IF V_DOC_LIST IS NULL THEN
                        V_DOC_LIST := V_DOC_NO;
                    ELSE
                        V_DOC_LIST := V_DOC_LIST || ',' || V_DOC_NO;
                    END IF;
--                    --요청문서 내부순번 지정
--                    V_DOC_SEQ := TO_CHAR(V_SEQNO + 1);
                    --I/F 전송 자재마스터에 투입 저장위치로 조회
                    SELECT DECODE(MATNR_DIV,'FERT','2000','HAWA','2000',LGPRO) 
                      INTO V_STOR_LOC
                      FROM TB_MAS001
                     WHERE 1=1
                       AND WERKS = P_WERKS
                       AND MATNR = V_MATNR;

                    --불출요청 테이블에 추가
                    dbms_output.put_line(V_DOC_SEQ);
                    INSERT INTO TB_INV002 (DOC_NO, DOC_SEQ, DLFL, REQ_DIV, WERKS, MATNR, QTY, UNIT, STCK_STA
                                            , STOR_LOC_TO, IF_STA, ORDER_NO, ORDER_SEQNO, REGDATE, REGID)
                                   VALUES (V_DOC_NO, V_DOC_SEQ, 'C', '10', P_WERKS, V_MATNR, V_REQ_QTY, V_UNIT, '00'
                                            , V_STOR_LOC, 'N', P_WRK_ORDR, P_WRK_ORDR_SEQ, V_DATE, P_USERID);

                    INSERT INTO TB_IFSWM002(DOC_NO, DOC_SEQNO, DLFL, WERKS,
                                                MATNR, QTY, UNIT, STOR_LOC, STCK_STA, IF_STATUS,
                                                REQ_DTM, REQ_EXE_DT, IF_GET_DATE)
                                        VALUES(V_DOC_NO, V_DOC_SEQ, 'C', P_WERKS,
                                                V_MATNR, V_REQ_QTY, V_UNIT, V_STOR_LOC, '00', 'N',
                                                TO_CHAR(V_DATE,'YYYYMMDDHH24MISS'), TO_CHAR(V_DATE,'YYYYMMDD') ,V_DATE);
--                    IF P_WERKS = 'P500' THEN
--                        INSERT INTO TB_IFSWM003(DOC_NO, DOC_SEQNO, DLFL, WERKS,
--                                                MATNR, QTY, UNIT, STOR_LOC, STCK_STA, IF_STATUS,
--                                                REQ_DTM, REQ_EXE_DT, IF_GET_DATE)
--                                        VALUES(V_DOC_NO, V_DOC_SEQ, 'C', P_WERKS,
--                                                V_MATNR, V_REQ_QTY, V_UNIT, V_STOR_LOC, '00', 'N',
--                                                TO_CHAR(V_DATE,'YYYYMMDDHH24MISS'), TO_CHAR(V_DATE,'YYYYMMDD') ,V_DATE);
--                    ELSE
--                        INSERT INTO TB_IFSWM002(DOC_NO, DOC_SEQNO, DLFL, WERKS,
--                                                MATNR, QTY, UNIT, STOR_LOC, STCK_STA, IF_STATUS,
--                                                REQ_DTM, REQ_EXE_DT, IF_GET_DATE)
--                                        VALUES(V_DOC_NO, V_DOC_SEQ, 'C', P_WERKS,
--                                                V_MATNR, V_REQ_QTY, V_UNIT, V_STOR_LOC, '00', 'N',
--                                                TO_CHAR(V_DATE,'YYYYMMDDHH24MISS'), TO_CHAR(V_DATE,'YYYYMMDD') ,V_DATE);
--                    END IF;
                END IF;
            END LOOP;

            --자재 불출요청
            V_SQL := FN_IF_QUERY('MES_IF_201', V_DOC_LIST);
            IF V_SQL IS NOT NULL THEN
            	OPEN CUR_1 FOR V_SQL;
            END IF;

            --작업 정상 종료 코드 등록
            RS_CODE := 'S';
            RS_MSG := V_DOC_LIST;
        ELSE    
            RS_CODE := 'E';
            RS_MSG := 'PROCEDURE ERROR';
        END IF;

        --작업 정상 종료 코드 등록
        RS_CODE := 'S';
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
        --RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
        RAISE;

        RS_CODE := 'E';
        RS_MSG  := SQLERRM;
        RETURN;
    --예외처리 종료
    END;
END SP_POP_INV01_I01;

/
