--------------------------------------------------------
--  DDL for Procedure SP_LOOP_EXAM
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_LOOP_EXAM" 
(
KK VARCHAR2 
) AS 
    --프로그램 ID
    V_PRG_NM         VARCHAR2(100)  := 'SP_LOOP_EXAM';     -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := '00'; --PLANTCODE TEST
    V_SESS_USER_ID   varchar2(20) := 'SYSTEM'; --USERID

    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);
    --parameter변수 처리
    l_counter NUMBER := 0;
    
    P_WERKS VARCHAR2(4) := 'P100';
    V_MATNR VARCHAR2(25) := 'H2S12250-06400915';
    V_PRD_END_DTM VARCHAR2(28) := '20221020051000';
    V_IND_BCD VARCHAR2(15) := '';
    
BEGIN

  LOOP
    l_counter := l_counter + 1;

    SP_GET_BARCODE_SEQ_00('IND', P_WERKS, 'C', V_MATNR, V_PRD_END_DTM, V_IND_BCD);

    IF l_counter > 100 THEN

 
       dbms_output.put_line( 'IND_BCD : ' || V_IND_BCD )  ;

      EXIT;
    END IF;
    
  END LOOP;

    --예외처리(catch)
    EXCEPTION
    WHEN E_EXCEPTION_USER THEN
        -- 에러 내역 SET
        E_SQL_ERR_CD        := SQLCODE;
        E_SQL_ERR_MSG       := SUBSTRB(SQLERRM,1,300);

        ROLLBACK;
        RAISE;
        RETURN;

    WHEN OTHERS THEN
        E_SQL_ERR_CD        := SQLCODE;
        E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

        ROLLBACK; 
        RAISE;

        RETURN;
    --예외처리 종료
    END;

/
