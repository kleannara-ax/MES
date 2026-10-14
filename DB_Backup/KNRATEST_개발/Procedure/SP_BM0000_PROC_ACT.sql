--------------------------------------------------------
--  DDL for Procedure SP_BM0000_PROC_ACT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_BM0000_PROC_ACT" (P_TYPE IN varchar2, P_JSON_STR IN varchar2 ,P_RS OUT SYS_REFCURSOR )
AS
    V_SQL  varchar2(4000);
    V_RANGE_SQL varchar2(4000);
    V_JSON  JSON_OBJECT_T;
BEGIN
    DBMS_OUTPUT.PUT_LINE('SQL=========>' || P_JSON_STR);
    V_JSON := JSON_OBJECT_T.parse(P_JSON_STR);


    IF(P_TYPE = 'LIST') THEN
        V_RANGE_SQL := V_JSON.get_string('RANGE_DATA_PARAM');
        insert into quiretest(inpram,inkey,maketime) values(V_RANGE_SQL,null,null);

        V_SQL := 'SELECT DISTINCT
            CM.CMCDKY AS "CMCDKY"
            , CM.SHORTX AS "SHORTX"
            , CM.DBFILD AS "DBFILD"
            , CM.USARL1 AS "USARL1"
            , CM.USARL2 AS "USARL2"
            , CM.USARL3 AS "USARL3"
            , CM.USARL4 AS "USARL4"
            , CM.USARL5 AS "USARL5"
            , CM.SYONLY AS "SYONLY"
            , CM.CREDAT AS "CREDAT"
            , CM.CRETIM AS "CRETIM"
            , CM.CREUSR AS "CREUSR"
            , NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = CM.CREUSR),'' '') AS "CUSRNM"
            , CM.LMODAT AS "LMODAT"
            , CM.LMOTIM AS "LMOTIM"
            , CM.LMOUSR AS "LMOUSR"
            , NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = CM.LMOUSR),'' '') AS "LUSRNM"
            , CM.CMCDKY AS "KEY"
            , '' '' AS STATUS
            FROM CMCDM CM
            INNER JOIN CMCDV CV
            ON CM.CMCDKY = CV.CMCDKY
            WHERE 1 = 1';


        V_SQL := V_SQL || V_RANGE_SQL;


        --파라미터 테스트
        insert into quiretest(inpram,inkey,maketime) values(V_SQL,null,null);

        DBMS_OUTPUT.PUT_LINE('SQL=========>' || V_SQL);

        OPEN P_RS FOR V_SQL;

    ELSIF P_TYPE = 'SAVE' then
        OPEN P_RS FOR SELECT 'OK' RESULT FROM DUAL;
    END IF;

END;


/
