--------------------------------------------------------
--  DDL for Procedure SP_GET_BARCODE_SEQ_220520
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_GET_BARCODE_SEQ_220520" 
(
  P_FTYPE   IN VARCHAR2,            --IND : 개별바코드, LOT : LOT NO
  P_WERKS   IN VARCHAR2,
  P_MACH_CD IN VARCHAR2,            --설비코드, 수입밀롤 = M
  P_MATNR   IN VARCHAR2,            --자재코드
  P_DATE    IN VARCHAR2,            -- 생산지시일(2022-05-14 12:00:00), 수입밀롤 : 20220514
  P_AA      IN VARCHAR2 := 'OK',
  
  BARCODE_CD_RTN OUT VARCHAR2 
) AS 
    --프로그램 ID
    V_PRG_NM        VARCHAR2(100)  := 'SP_GET_DOC_SEQ';     -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := '00'; --PLANTCODE TEST
    V_SESS_USER_ID   varchar2(20) := 'SYSTEM'; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);
    --parameter변수 처리

    --내부처리변수 추가
    V_FTYPE     VARCHAR2(20); 
    V_BUSICD    VARCHAR2(1);                --사업부
    V_HOGI      VARCHAR(20);
    P_SEQ       VARCHAR2(25);
    V_BASIC     VARCHAR2(20);
    V_YY        VARCHAR2(2);
    V_MM        VARCHAR2(2);
    V_DD        VARCHAR2(2);
    V_LOT_DIV   VARCHAR2(1);
    V_MAXSEQ    INT;
    V_STAMP     DATE := SYSDATE;

BEGIN
    BEGIN


        BARCODE_CD_RTN := 'OK';
    --예외처리(catch)
    EXCEPTION
    WHEN E_EXCEPTION_USER THEN
        -- 에러 내역 SET
        E_SQL_ERR_CD        := SQLCODE;
        E_SQL_ERR_MSG       := SUBSTRB(SQLERRM,1,300);

        ROLLBACK;
        SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
        RETURN;
    WHEN OTHERS THEN
        E_SQL_ERR_CD        := SQLCODE;
        E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

        ROLLBACK;
        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
        RETURN;
    --예외처리 종료
    END;
END;


/
