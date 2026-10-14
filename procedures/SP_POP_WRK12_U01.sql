
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK12_U01" 
(
    P_IF_KEY        IN VARCHAR2 
    ,P_WRK_LIST     IN CLOB
    ,P_USERID       IN VARCHAR2
    ,Lang           IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE     OUT VARCHAR2 
    ,RS_MSG      OUT VARCHAR2
)
/*==============================================================================
 * PROGRAM ID    : POP_WRK12
 * PROGRAM NAME  : 화장지 합지기 실적 전송결과 등록
 * VERSION       : 1.0.1
 * DESCRIPTION   : 화장지 합지기 실적의 SAP전송결과를 등록한다.
 *                 
 * AUTHOR NAME   : 김기연
 * CREATE DATE   : 2022/06/30
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/06/30    1.0.0   김기연         Initial Version
 *==============================================================================
 *  관련 테이블
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM        VARCHAR2(100)  := 'SP_POP_WRK12_U01';     -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID   varchar2(20) := P_USERID; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);
    --내부변수 관리
    V_DATE DATE := SYSDATE;
    V_PROC_CD VARCHAR2(20);
    V_ORDER_NO VARCHAR2(10);
    V_MDOC_NO VARCHAR2(30);
    V_MDOC_SEQ VARCHAR2(6);
    V_SDOC_NO VARCHAR2(30);
    V_SDOC_SEQ VARCHAR2(6);
    V_SRESULT VARCHAR2(1);
    V_SMESSAGE VARCHAR2(1000);
    V_SEQNO NUMBER;
    --커서용 변수
    V_CHK VARCHAR(1);
    --V_WERKS VARCHAR(4);
    V_MATNR VARCHAR(20);
    V_REQ_QTY NUMBER(28,3);
    V_UNIT VARCHAR(10);
    -- JSON을 위한 변수선언 영역
    V_JSON           JSON_OBJECT_T;
    V_ARR_LIST       JSON_ARRAY_T;
    V_OBJ            JSON_OBJECT_T;
BEGIN
    --예외처리 시작(try)
    BEGIN
        --JSON 데이터 수신
        V_JSON := JSON_OBJECT_T.parse(P_WRK_LIST); -- 전체 데이터
        V_PROC_CD := V_JSON.get_string('PROC_CD'); -- 프로시저명

        --대상데이터 일치여부 확인
        IF V_PROC_CD = 'POP_WRK12' THEN
            --세부 데이터 목록 수신
            V_ARR_LIST := V_JSON.get_array('list');
            --각 항목별 처리
            V_SEQNO := 0;
            --SAP 결과 등록
            FOR i IN 0..V_ARR_LIST.get_size-1 LOOP
                --행별 데이터 목록 조회
                V_OBJ := TREAT (V_ARR_LIST.get (i) AS json_object_t);
                V_OBJ := TREAT (V_OBJ.get ('map') AS json_object_t);
                --각 항목별 데이터 조회
                V_ORDER_NO := V_OBJ.get_string('AUFNR');
                V_MDOC_NO := V_OBJ.get_string('MDOCNO');
                V_MDOC_SEQ := V_OBJ.get_string('MDOCSEQ');
                V_SDOC_NO := V_OBJ.get_string('MBLNR');
                V_SDOC_SEQ := V_OBJ.get_string('MJAHR');
                V_SRESULT := V_OBJ.get_string('TYPE');
                V_SMESSAGE := V_OBJ.get_string('MESSAGE');
                --결과 정보 저장
                UPDATE TB_IFS001
                   SET RUECK = V_SDOC_NO
                     , RMZHL = V_SDOC_SEQ
                     , ZRESULT = V_SRESULT
                     , ZMESSAGE = V_SMESSAGE
                     , ZRESULT_DATE = V_DATE
                     , IF_MES_KEY = P_IF_KEY
                 WHERE 1=1
                   AND AUFNR = V_ORDER_NO
                   AND MDOCNO = V_MDOC_NO
                   AND LPAD(MDOCSEQ,6,'0') = V_MDOC_SEQ;

                V_SEQNO := V_SEQNO+1;
            END LOOP;
            --작업 정상 종료 코드 등록
            RS_CODE := 'S';
            RS_MSG := V_SMESSAGE;
        ELSE    
            RS_CODE := 'E';
            RS_MSG := 'PROCEDURE ERROR';
        END IF;

        --작업 정상 종료 코드 등록
        RS_CODE := 'S';
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
END SP_POP_WRK12_U01;
/
