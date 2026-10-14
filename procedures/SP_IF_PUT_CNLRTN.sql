
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_IF_PUT_CNLRTN" 
(
    P_WERKS         IN VARCHAR2
    ,P_WRK_TYPE     IN VARCHAR2     --'0'= 실적취소테이블, '1'= 폐품취소테이블, '2'=소요량취소, '3'=비가동취소
    ,P_RFC_DATA     IN CLOB
    ,P_USERID       IN VARCHAR2
    ,Lang           IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE     OUT VARCHAR2 
    ,RS_MSG      OUT VARCHAR2
)
/*==============================================================================
 * PROGRAM ID    : SP_IF_PUT_CNLRTN
 * PROGRAM NAME  : SAP 실적 취소 전송결과 실적 테이블에 확정문서 삭제
 * VERSION       : 1.0.1
 * DESCRIPTION   : 실적의 SAP전송결과를 등록한다.
 *                 
 * AUTHOR NAME   : 김병무
 * CREATE DATE   : 2022/07/04
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/07/04    1.0.0   김병무         Initial Version
 *==============================================================================
 *  관련 테이블
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM        VARCHAR2(100)  := 'SP_IF_PUT_CNLRTN';     -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID   varchar2(20) := P_USERID; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);
    --내부변수 관리
    V_DATE DATE := SYSDATE;
    V_PROC_CD VARCHAR2(20);
    V_MDOC_NO VARCHAR2(30);
    V_MDOC_SEQ VARCHAR2(6);
    V_SQL VARCHAR(1000);
    --커서용 변수
    V_CHK VARCHAR(1);
    -- JSON을 위한 변수선언 영역
    V_JSON           JSON_OBJECT_T;
    V_ARR_LIST       JSON_ARRAY_T;
    V_OBJ            JSON_OBJECT_T;
BEGIN
    --예외처리 시작(try)
    BEGIN
        --JSON 데이터 수신
        V_JSON := JSON_OBJECT_T.parse(P_RFC_DATA); -- 전체 데이터
        V_PROC_CD := V_JSON.get_string('PROC_CD'); -- 프로시저명

        --세부 데이터 목록 수신
        V_ARR_LIST := V_JSON.get_array('list');
        --각 항목별 처리
        --SAP 결과 등록
        FOR i IN 0..V_ARR_LIST.get_size-1 LOOP
            --행별 데이터 목록 조회
            V_OBJ := TREAT (V_ARR_LIST.get (i) AS json_object_t);
            V_OBJ := TREAT (V_OBJ.get ('map') AS json_object_t);
            --각 항목별 데이터 조회
            V_MDOC_NO := V_OBJ.get_string('MDOCNO');
            V_MDOC_SEQ := V_OBJ.get_string('MDOCSEQ');

            -- 전달시 MBLNR, MJAHR을 replace 처리하여 하나로 받도록함.

            --P_WRK_TYPE  '0'= 실적테이블, '1'= 폐품테이블, '2'=소요량, '3'=비가동, '4'=비계획생산  
            IF P_WRK_TYPE = '1' THEN
                UPDATE TB_WRK004
                   SET SDOC_NO      = NULL
                     , SDOC_SEQNO   = NULL
                     , UPDDATE = SYSDATE
                     , UPDID   = P_USERID
                 WHERE DOC_NO = V_MDOC_NO
                   AND LPAD(DOC_SEQNO,6,'0') = V_MDOC_SEQ;  
            ELSIF P_WRK_TYPE = '2' THEN --소요량
                UPDATE TB_INV010
                   SET SDOC_NO      = NULL
                     , SDOC_SEQNO   = NULL
                     , UPDDATE = SYSDATE
                     , UPDID   = P_USERID
                 WHERE DOC_NO = V_MDOC_NO
                   AND LPAD(DOC_SEQNO,6,'0') = V_MDOC_SEQ;
            ELSIF P_WRK_TYPE = '3' THEN --비가동
                UPDATE TB_WRK003
                   SET SDOC_NO      = NULL
                     , SDOC_SEQNO   = NULL
                     , UPDDATE = SYSDATE
                     , UPDID   = P_USERID
                 WHERE DOC_NO = V_MDOC_NO
                   AND LPAD(DOC_SEQNO,6,'0') = V_MDOC_SEQ;
            ELSE
                IF P_WERKS = 'P100' THEN  -- PS인경우
                    IF P_WRK_TYPE = '0' THEN       -- '0' 이면 실적테이블, 비계획생산 실적
                        UPDATE TB_WRK002
                          SET  SDOC_NO      = NULL
                              ,SDOC_SEQNO   = NULL
                              ,UPDDATE = SYSDATE
                              ,UPDID   = P_USERID
                        WHERE DOC_NO = V_MDOC_NO
                          AND LPAD(DOC_SEQNO,6,'0') = V_MDOC_SEQ;
                    END IF;
                ELSE
                    -- HL은 폐품 테이블이 없어서 WRK001 실적테이블만 업데이트 처리함.
                    IF P_WRK_TYPE = '0' THEN  --실적
                        UPDATE TB_WRK001
                          SET  SDOC_NO      = NULL
                              ,SDOC_SEQNO   = NULL
                              ,UPDDATE = SYSDATE
                              ,UPDID   = P_USERID
                        WHERE DOC_NO = V_MDOC_NO
                          AND LPAD(DOC_SEQNO,6,'0') = V_MDOC_SEQ; 
                    END IF;
                END IF;
            END IF;
        END LOOP;

        --작업 정상 종료 코드 등록
        RS_CODE := 'S';
        --RS_MSG := V_SMESSAGE;
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
END SP_IF_PUT_CNLRTN;
/
