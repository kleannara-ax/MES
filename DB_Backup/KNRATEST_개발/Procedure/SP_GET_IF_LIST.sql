--------------------------------------------------------
--  DDL for Procedure SP_GET_IF_LIST
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_GET_IF_LIST" 
(
    P_IF        IN VARCHAR2
    ,P_DOCNO    IN VARCHAR2
    ,Lang       IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE    OUT VARCHAR2 
    ,RS_MSG     OUT VARCHAR2
    ,CUR_1      OUT SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : 공통
 * PROGRAM NAME  : SAP 인터페이스 전송정보 조회
 * VERSION       : 1.0.0
 * DESCRIPTION   : SAP 인터페이스 전송시 정보 조회
 *                 
 * AUTHOR NAME   : 김기연
 * CREATE DATE   : 2022/06/28
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/05/11    1.0.0   김기연         Initial Version(재작업)
 *==============================================================================
 *  관련 테이블
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM        VARCHAR2(100)  := 'SP_GET_IF_LIST';     -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID   varchar2(20) := 'TEST'; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);
    --내부변수 관리
    V_SQL VARCHAR2(4000);
    V_COL_LIST VARCHAR2(1000);--조회 테이블
    V_TABLE_ID VARCHAR2(20);--조회 테이블
BEGIN
    --예외처리 시작(try)
    BEGIN
        --조회 테이블 검색
        SELECT IFTBL
          INTO V_TABLE_ID
          FROM TB_ITFMA
         WHERE 1=1
           AND IFID = P_IF;
        --조회목록 검색
        SELECT LISTAGG(A.TARFLD,',')
          INTO V_COL_LIST
          FROM TB_ITFFLDMAP A JOIN TB_ITFMA B ON A.IFID = B.IFID
         WHERE 1=1 
           AND A.IFID = P_IF
         ORDER BY A.ORD ASC; 

        V_SQL := 'SELECT ' || V_COL_LIST;
        V_SQL := V_SQL || ' FROM ' || V_TABLE_ID;
        V_SQL := V_SQL || ' WHERE 1=1 ';
        IF P_DOCNO IS NOT NULL THEN
            V_SQL := V_SQL || ' AND MDOCNO = ''' || P_DOCNO || '''';
        END IF;

        --OPEN CUR_1 FOR SELECT NULL FROM DUAL WHERE ROWNUM = 0;
        OPEN CUR_1 FOR 
        SELECT 'A' AS I_GUBUN
             , P_IF AS I_IF_ID
             , 'IFTEST202206290005' AS I_IF_KEY
          FROM DUAL;

        --작업 정상 종료 코드 등록
        RS_CODE := 'S';
        RS_MSG := V_SQL;
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
        E_SQL_ERR_CD        := -200001;
        E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

        ROLLBACK;
        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);

        RS_CODE := 'E';
        RS_MSG  := SQLERRM;
        RETURN;
    --예외처리 종료
    END;
END;

/
