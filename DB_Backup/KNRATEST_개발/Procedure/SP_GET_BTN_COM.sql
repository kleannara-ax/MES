--------------------------------------------------------
--  DDL for Procedure SP_GET_BTN_COM
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_GET_BTN_COM" SP_GET_BTN_COM
(
    P_COMMPOPCD IN VARCHAR2
    ,Lang       IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE    OUT VARCHAR2 
    ,RS_MSG     OUT VARCHAR2
    ,CUR_1      OUT SYS_REFCURSOR
)
AS 
    --프로그램 ID
    V_PRG_NM          VARCHAR2(100) := 'SP_GET_BTN_COM';  -- PROCEDURE NAME
    V_PLT_CD          VARCHAR2(2)   := '99';   --PLANTCODE TEST
    V_SESS_USER_ID    VARCHAR2(20)  := 'TEST'; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);
    -- Parameter 변수처리
    V_COMMPOPCD       VARCHAR(20) := P_COMMPOPCD;

BEGIN
    --예외처리 시작(try)
    BEGIN
        BEGIN
            --결과 테이블 반환용 변수
            OPEN CUR_1 FOR
            --작업반 목록 조회
            SELECT CMCDVL --작업반코드
                 , CDESC1 --작업반명
                 , 'N' --초기 선택여부
                 , 'Y' --사용 여부
            FROM CMCDV
            WHERE CMCDKY = V_COMMPOPCD
            ORDER BY CMCDVL;
            --작업 정상 종료 코드 등록
            RS_CODE := 'S';
        END;
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
        E_SQL_ERR_CD        := SQLCODE;
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
