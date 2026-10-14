
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK04_I01" 
(
    P_WERKS         IN VARCHAR2 
    ,P_MACH_CD      IN VARCHAR2
    ,P_IOTYPE      IN VARCHAR2
    ,P_PROC_CD      IN VARCHAR2 
    ,P_CHK_DT       IN VARCHAR2
    ,P_CHK_SEQ      IN VARCHAR2
    ,P_CHK_TM       IN VARCHAR2
    ,P_WRK_LIST     IN CLOB
    ,P_USERID       IN VARCHAR2
    ,Lang           IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE     OUT VARCHAR2 
    ,RS_MSG      OUT VARCHAR2
)
/*==============================================================================
 * PROGRAM ID    : POP_WR04
 * PROGRAM NAME  : 공정검사 결과등록
 * VERSION       : 1.0.0
 * DESCRIPTION   : 공정검사 결과 목록을 등록한다.
 *                 
 * AUTHOR NAME   : 김기연
 * CREATE DATE   : 2022/05/20
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/05/14    1.0.0   김기연         Initial Version
 *==============================================================================
 *  관련 테이블
 * - [TB_SCH002] : (.R..) 화장지 합지기 생산오더
 * - [TB_SCH011] : (.R..) 화장지 합지기 작업지시
 * - [TB_MAS001] : (.R..) 자재 기준 정보
 * - [TB_WRK001] : (.R..) HL 생산실적 이력
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM        VARCHAR2(100)  := 'SP_POP_WR04_I01';     -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID   varchar2(20) := P_USERID; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);
    --내부변수 관리
    V_DATE DATE := SYSDATE;
    V_PROC_CD VARCHAR2(20);
    V_RST_VAL NUMBER(9,1);
    V_RST_SEL VARCHAR2(10);
    V_RST_TXT VARCHAR2(1000);
    V_MATNR VARCHAR2(20);
    V_WRK_ORDR_NO VARCHAR2(20);
    V_WRK_ORDR_SEQNO NUMBER(5);
    V_FLAG NUMBER(2);
    --커서용 변수
    V_WERKS VARCHAR2(4);
    V_CHK_ITEM_CD VARCHAR2(10);
    V_INPT_TYP VARCHAR2(10);
    V_INPT_MTD VARCHAR2(10);
    V_LOW_VAL NUMBER(13,1);
    V_UPP_VAL NUMBER(13,1);
    V_TMP_VAL VARCHAR2(1000);
    -- JSON을 위한 변수선언 영역
    V_JSON           JSON_OBJECT_T;
    V_ARR_LIST       JSON_ARRAY_T;
    V_OBJ            JSON_OBJECT_T;
BEGIN
    --예외처리 시작(try)
    BEGIN
        --현재 작업정보 조회
        SELECT MATNR, WRK_ORDR_NO, WRK_ORDR_SEQNO
          INTO V_MATNR, V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO
          FROM TB_WRK011
         WHERE 1=1
           AND WERKS = P_WERKS
           AND MACH_CD = P_MACH_CD
           AND IN_OUT = P_IOTYPE;

        --등록여부 확인
        SELECT COUNT(P_CHK_DT)
          INTO V_FLAG
          FROM TB_WRK014
         WHERE 1=1
           AND WERKS = P_WERKS
           AND MACH_CD = P_MACH_CD
           AND CHK_DT = P_CHK_DT
           AND CHK_SEQNO = P_CHK_SEQ;
        IF V_FLAG > 0 THEN
            RS_CODE := 'E';
            RS_MSG := '이미 등록된 검사차수 입니다.\n';
            RETURN;
    END IF;

        --JSON 데이터 수신
        V_JSON := JSON_OBJECT_T.parse(P_WRK_LIST); -- 전체 데이터
        V_PROC_CD := V_JSON.get_string('PROC_CD'); -- 프로시저명
        --대상데이터 일치여부 확인
        IF V_PROC_CD = 'POP_WRK04' THEN
            --세부 데이터 목록 수신
            V_ARR_LIST := V_JSON.get_array('list');
            --각 항목별 처리
            FOR i IN 0..V_ARR_LIST.get_size-1 LOOP
                --행별 데이터 목록 조회
                V_OBJ := TREAT (V_ARR_LIST.get (i) AS json_object_t);
                V_OBJ := TREAT (V_OBJ.get ('map') AS json_object_t);
                --각 항목별 데이터 조회
                V_CHK_ITEM_CD := V_OBJ.get_string('ITEM_CD');
                V_INPT_TYP := V_OBJ.get_string('INPT_TYP');
                V_INPT_MTD := V_OBJ.get_string('INPT_MTD');
                V_LOW_VAL := TO_NUMBER(V_OBJ.get_string('LOW_VAL'));
                V_UPP_VAL := TO_NUMBER(V_OBJ.get_string('UPP_VAL'));
                V_TMP_VAL := V_OBJ.get_string('RES_VAL');
                --입력 방식에 따라 각 결과값에 등록
                IF(V_INPT_TYP = 'N') THEN
                    V_RST_VAL := TO_NUMBER(V_TMP_VAL);
                    V_RST_SEL := '';
                    V_RST_TXT := '';
                ELSIF (V_INPT_TYP = 'A') THEN
                    V_RST_VAL := '';
                    V_RST_SEL := V_TMP_VAL;
                    V_RST_TXT := '';
                ELSE
                    V_RST_VAL := '';
                    V_RST_SEL := '';
                    V_RST_TXT := V_TMP_VAL;
                END IF;
                --검사결과 테이블에 추가
                INSERT INTO TB_WRK014 (WERKS, MACH_CD, CHK_DT, CHK_TM, CHK_SEQNO
                                        , MATNR, WRK_ORDR_NO, WRK_ORDR_SEQNO
                                        , CHK_ITEM_CD, INPT_TYP, INPT_MTD, LOW_VAL, UPP_VAL
                                        , RST_VAL, RST_SEL, RST_TXT, CPK_YN
                                        , REGDATE, REGID)
                               VALUES (P_WERKS, P_MACH_CD, P_CHK_DT, P_CHK_TM, P_CHK_SEQ
                                        , V_MATNR, V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO
                                        , V_CHK_ITEM_CD, V_INPT_TYP, V_INPT_MTD, V_LOW_VAL, V_UPP_VAL
                                        , V_RST_VAL, V_RST_SEL, V_RST_TXT, 'N'
                                        , V_DATE, P_USERID); 
                IF SQL%ROWCOUNT > 0 THEN
                    RS_MSG := RS_MSG || TO_CHAR(i) || ' OK';
                ELSE
                    RS_MSG := RS_MSG || TO_CHAR(i) || ' NG';
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
END SP_POP_WRK04_I01;
/
