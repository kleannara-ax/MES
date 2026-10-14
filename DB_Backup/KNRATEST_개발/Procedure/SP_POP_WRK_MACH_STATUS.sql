--------------------------------------------------------
--  DDL for Procedure SP_POP_WRK_MACH_STATUS
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK_MACH_STATUS" 
(
     P_MACH_CD    IN VARCHAR2 
    ,Lang        IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE     OUT VARCHAR2 
    ,RS_MSG      OUT VARCHAR2
    ,CUR_1       OUT SYS_REFCURSOR
)
AS
    --프로그램 ID
    V_PRG_NM        VARCHAR2(100)  := 'SP_POP_WRK_MACH_STATUS';     -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID   varchar2(20) := 'TEST'; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);
    V_ABN_STA NUMBER;
BEGIN
    BEGIN    
        BEGIN
        --비가동 여부 확인
        SELECT COUNT(*)
          INTO V_ABN_STA
          FROM TB_WRK003
         WHERE MACH_CD  = P_MACH_CD
           AND CNL_YN = 'N'
           AND SYSDATE BETWEEN STR_DATE AND NVL(END_DATE,SYSDATE);
        END;
        
        OPEN CUR_1 FOR	
            SELECT DECODE(V_ABN_STA, 0, '', 'S') MACH_STA FROM DUAL;

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
END SP_POP_WRK_MACH_STATUS;

/
