--------------------------------------------------------
--  DDL for Procedure SP_CRE_SCHEDULE_SEQ
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_CRE_SCHEDULE_SEQ" 
/*==============================================================================
 * PROGRAM ID    : SP_CRE_SCHEDULE_SEQ{호출 프로그램 ID 기술}
 * PROGRAM NAME  : PS 일자별로 공정별로 시퀀스 생성 {호출 프로그램 명 기술}
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : PS 일자별로 공정별로 시퀀스 생성한다.
 *                 
 * AUTHOR NAME   : 여한진{최초 작성자 명 기술}
 * CREATE DATE   : 2022/09/23 {최초 작성일자 기술}
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * yyyy/mm/dd    1.0.0   여한진         Initial Version 
 *==============================================================================*/

AS
    V_PRG_NM        VARCHAR2(100)  := 'SP_CRE_SCHEDULE_SEQ';     -- PROCEDURE NAME

    --시퀀스 삭제
    V_SEQ_J         VARCHAR(1000);      --점보롤
    V_SEQ_M         VARCHAR(1000);      --밀롤
    V_SEQ_C         VARCHAR(1000);      --재단
    V_SEQ_T         VARCHAR(1000);      --수재단
    V_SEQ_S         VARCHAR(1000);      --슬리터
    V_SEQ_P         VARCHAR(1000);      --포장

    --시퀀스 생성
    V_SEQ_J_NEW         VARCHAR(1000);      --점보롤
    V_SEQ_M_NEW         VARCHAR(1000);      --밀롤
    V_SEQ_C_NEW         VARCHAR(1000);      --재단
    V_SEQ_T_NEW         VARCHAR(1000);      --수재단
    V_SEQ_S_NEW         VARCHAR(1000);      --슬리터
    V_SEQ_P_NEW         VARCHAR(1000);      --포장

    --년월일
    V_DAY           VARCHAR(8);
    V_DATE          VARCHAR(8);         --현재 날짜 - 2

    V_CNT           NUMBER;
    V_LEN           NUMBER;

    V_SEQNUM_J      VARCHAR2(1000);     --점보롤 시퀀스
    V_SEQNUM_M      VARCHAR2(1000);     --밀롤 시퀀스
    V_SEQNUM_C      VARCHAR2(1000);     --재단 시퀀스
    V_SEQNUM_T      VARCHAR2(1000);     --수재단 시퀀스
    V_SEQNUM_S      VARCHAR2(1000);     --슬리터 시퀀스
    V_SEQNUM_P      VARCHAR2(1000);     --포장 시퀀스
BEGIN

    --SELECT TO_CHAR(SYSDATE, 'YYYYMMDD') INTO V_DAY FROM DUAL;
    --SELECT TO_CHAR(ADD_MONTHS(SYSDATE, -1) , 'YYYYMMDD') INTO V_DATE FROM DUAL;  --한 달 기준으로 검색

    --SELECT TO_CHAR(LAST_DAY(SYSDATE),'YYYYMMDD') - TO_CHAR(TRUNC(SYSDATE,'MM'), 'YYYYMMDD') INTO V_LEN FROM DUAL;   --한 달 마지막 일부터 1일 차이

    SELECT TO_CHAR(LAST_DAY(TO_CHAR(ADD_MONTHS(SYSDATE, 1), 'YYYYMMDD')), 'YYYYMMDD') - TO_CHAR(TRUNC(ADD_MONTHS(SYSDATE, 1), 'MM'), 'YYYYMMDD') INTO V_LEN FROM DUAL;  -- 다음 달의 마지막 일부터 1일 차이

    --SELECT TO_CHAR(TRUNC(ADD_MONTHS(SYSDATE, 1), 'MM'), 'YYYYMMDD') FROM DUAL;    --다음 달의 1일

--    SELECT COUNT(*) INTO V_CNT
--      FROM user_sequences
--     WHERE sequence_name LIKE 'SEQ_' || V_DATE || '%';
--
--    IF V_CNT = 6 THEN
--        SELECT FN_GET_SEQ_NO('SEQ_' || V_DATE || '_J') INTO V_SEQNUM_J FROM DUAL;
--        SELECT FN_GET_SEQ_NO('SEQ_' || V_DATE || '_M') INTO V_SEQNUM_M FROM DUAL;
--        SELECT FN_GET_SEQ_NO('SEQ_' || V_DATE || '_C') INTO V_SEQNUM_C FROM DUAL;
--        SELECT FN_GET_SEQ_NO('SEQ_' || V_DATE || '_T') INTO V_SEQNUM_T FROM DUAL;
--        SELECT FN_GET_SEQ_NO('SEQ_' || V_DATE || '_S') INTO V_SEQNUM_S FROM DUAL;
--        SELECT FN_GET_SEQ_NO('SEQ_' || V_DATE || '_P') INTO V_SEQNUM_P FROM DUAL;
--        
--        --점보롤
--        MERGE 
--            INTO TB_WRK500 W500
--           USING DUAL
--              ON (W500.IFTYPE = 'J'
--             AND W500.BASIC = V_DATE)
--        WHEN MATCHED THEN
--             UPDATE 
--                SET SEQ = V_SEQNUM_J
--                  , UPDDATE = SYSDATE
--        WHEN NOT MATCHED THEN
--            INSERT (IFTYPE, BASIC, SEQ, UPDDATE)
--            VALUES ('J', V_DATE, V_SEQNUM_J, SYSDATE);
--        
--        --밀롤
--        MERGE 
--            INTO TB_WRK500 W500
--           USING DUAL
--              ON (W500.IFTYPE = 'M'
--             AND W500.BASIC = V_DATE)
--        WHEN MATCHED THEN
--             UPDATE 
--                SET SEQ = V_SEQNUM_M
--                  , UPDDATE = SYSDATE
--        WHEN NOT MATCHED THEN
--            INSERT (IFTYPE, BASIC, SEQ, UPDDATE)
--            VALUES ('M', V_DATE, V_SEQNUM_M, SYSDATE);
--            
--        --재단                
--        MERGE 
--            INTO TB_WRK500 W500
--           USING DUAL
--              ON (W500.IFTYPE = 'C'
--             AND W500.BASIC = V_DATE)
--        WHEN MATCHED THEN
--             UPDATE 
--                SET SEQ = V_SEQNUM_C
--                  , UPDDATE = SYSDATE
--        WHEN NOT MATCHED THEN
--            INSERT (IFTYPE, BASIC, SEQ, UPDDATE)
--            VALUES ('C', V_DATE, V_SEQNUM_C, SYSDATE);
--            
--        --수재단                
--        MERGE 
--            INTO TB_WRK500 W500
--           USING DUAL
--              ON (W500.IFTYPE = 'T'
--             AND W500.BASIC = V_DATE)
--        WHEN MATCHED THEN
--             UPDATE 
--                SET SEQ = V_SEQNUM_T
--                  , UPDDATE = SYSDATE
--        WHEN NOT MATCHED THEN
--            INSERT (IFTYPE, BASIC, SEQ, UPDDATE)
--            VALUES ('T', V_DATE, V_SEQNUM_T, SYSDATE);
--            
--        --슬리터                
--        MERGE 
--            INTO TB_WRK500 W500
--           USING DUAL
--              ON (W500.IFTYPE = 'S'
--             AND W500.BASIC = V_DATE)
--        WHEN MATCHED THEN
--             UPDATE 
--                SET SEQ = V_SEQNUM_S
--                  , UPDDATE = SYSDATE
--        WHEN NOT MATCHED THEN
--            INSERT (IFTYPE, BASIC, SEQ, UPDDATE)
--            VALUES ('S', V_DATE, V_SEQNUM_S, SYSDATE);
--            
--        --포장
--        MERGE 
--            INTO TB_WRK500 W500
--           USING DUAL
--              ON (W500.IFTYPE = 'P'
--             AND W500.BASIC = V_DATE)
--        WHEN MATCHED THEN
--             UPDATE 
--                SET SEQ = V_SEQNUM_P
--                  , UPDDATE = SYSDATE
--        WHEN NOT MATCHED THEN
--            INSERT (IFTYPE, BASIC, SEQ, UPDDATE)
--            VALUES ('P', V_DATE, V_SEQNUM_P, SYSDATE);
--            
--        --한 달 기준으로 삭제
--        V_SEQ_J := 'DROP SEQUENCE SEQ_' || V_DATE || '_J';
--        V_SEQ_M := 'DROP SEQUENCE SEQ_' || V_DATE || '_M';
--        V_SEQ_C := 'DROP SEQUENCE SEQ_' || V_DATE || '_C';
--        V_SEQ_T := 'DROP SEQUENCE SEQ_' || V_DATE || '_T';
--        V_SEQ_S := 'DROP SEQUENCE SEQ_' || V_DATE || '_S';
--        V_SEQ_P := 'DROP SEQUENCE SEQ_' || V_DATE || '_P';
--
--        EXECUTE IMMEDIATE V_SEQ_J;
--        EXECUTE IMMEDIATE V_SEQ_M;
--        EXECUTE IMMEDIATE V_SEQ_C;
--        EXECUTE IMMEDIATE V_SEQ_T;
--        EXECUTE IMMEDIATE V_SEQ_S;
--        EXECUTE IMMEDIATE V_SEQ_P;
--    END IF;

    FOR i IN 0..V_LEN
    LOOP
        --SELECT TO_CHAR(SYSDATE,'YYYYMMDD') + i INTO V_DAY FROM DUAL;
        SELECT TO_CHAR(TRUNC(ADD_MONTHS(SYSDATE, 1), 'MM'), 'YYYYMMDD') + i INTO V_DAY FROM DUAL;
        --점보롤
        V_SEQ_J_NEW := 'CREATE SEQUENCE "SEQ_' || V_DAY || '_J"
                        INCREMENT BY 1
                        MINVALUE 1
                        MAXVALUE 9999
                        CYCLE
                        NOCACHE';
        --밀롤                
        V_SEQ_M_NEW := 'CREATE SEQUENCE "SEQ_' || V_DAY || '_M"
                        INCREMENT BY 1
                        MINVALUE 1
                        MAXVALUE 9999
                        CYCLE
                        NOCACHE';
        --재단                
        V_SEQ_C_NEW := 'CREATE SEQUENCE "SEQ_' || V_DAY || '_C"
                        INCREMENT BY 1
                        MINVALUE 1
                        MAXVALUE 9999
                        CYCLE
                        NOCACHE';
        --수재단
        V_SEQ_T_NEW := 'CREATE SEQUENCE "SEQ_' || V_DAY || '_T"
                        INCREMENT BY 1
                        MINVALUE 1
                        MAXVALUE 9999
                        CYCLE
                        NOCACHE';
        --슬리터
        V_SEQ_S_NEW := 'CREATE SEQUENCE "SEQ_' || V_DAY || '_S"
                        INCREMENT BY 1
                        MINVALUE 1
                        MAXVALUE 9999
                        CYCLE
                        NOCACHE';                
        --포장                
        V_SEQ_P_NEW := 'CREATE SEQUENCE "SEQ_'|| V_DAY || '_P"
                        INCREMENT BY 1
                        MINVALUE 1
                        MAXVALUE 9999
                        CYCLE
                        NOCACHE';

        EXECUTE IMMEDIATE V_SEQ_J_NEW;
        EXECUTE IMMEDIATE V_SEQ_M_NEW;
        EXECUTE IMMEDIATE V_SEQ_C_NEW;
        EXECUTE IMMEDIATE V_SEQ_T_NEW;
        EXECUTE IMMEDIATE V_SEQ_S_NEW;
        EXECUTE IMMEDIATE V_SEQ_P_NEW;
    END LOOP;
END;

/
