--------------------------------------------------------
--  DDL for Procedure SP_GET_BARCODE_SEQ_220628
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_GET_BARCODE_SEQ_220628" 
(
  P_FTYPE   IN VARCHAR2,            --IND : 개별바코드, LOT : LOT NO
  P_WERKS   IN VARCHAR2,
  P_MACH_CD IN VARCHAR2,            --설비코드, 수입밀롤 = M
  P_MATNR   IN VARCHAR2,            --자재코드
  P_DATE    IN VARCHAR2,            -- 생산지시일(2022-05-14 12:00:00), 수입밀롤 : 20220514
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
    V_LOT_DIV   VARCHAR2(2);
    V_MAXSEQ    INT;
    V_STAMP     DATE := SYSDATE;

BEGIN
    BEGIN
        IF P_FTYPE = 'IND' THEN    
            SELECT BUSICD INTO V_BUSICD
              FROM TB_MAS001
             WHERE WERKS = P_WERKS
               AND MATNR = P_MATNR;

            IF P_MACH_CD = 'M' THEN
                V_HOGI := 'M0';
            ELSE
                SELECT M013.PROC_GRP_CD ||  TO_CHAR(M012.LINE) 
                       INTO
                       V_HOGI
                  FROM TB_MAS012 M012,
                       TB_MAS013 M013
                 WHERE M012.PROC_CD = M013.PROC_CD(+)
                   AND M012.MACH_CD = P_MACH_CD;
            END IF;

            SELECT FN_RECDATE(TO_DATE(P_DATE, 'YYYY-MM-DD HH24:MI:SS')) INTO V_BASIC
              FROM DUAL;

            V_FTYPE :=  V_BUSICD || V_HOGI;

            SELECT NVL(MAX(SEQ), 0) INTO V_MAXSEQ 
              FROM TB_WRK500 
             WHERE IFTYPE = V_FTYPE
               AND BASIC = V_BASIC;

            V_MAXSEQ := V_MAXSEQ + 1;
            P_SEQ := V_BUSICD || V_BASIC || V_HOGI || SUBSTR('0000' || TO_CHAR(V_MAXSEQ), -4);

            IF V_MAXSEQ = 1 THEN
                INSERT INTO TB_WRK500(IFTYPE, BASIC, SEQ, FULLSEQ, UPDDATE)
                            VALUES(V_FTYPE, V_BASIC, V_MAXSEQ, P_SEQ, V_STAMP);
                --기준일자 두번째 이후의 경우 기존항목을 마지막 순번으로 변경
            ELSE
                UPDATE TB_WRK500
                   SET SEQ = V_MAXSEQ
                     , FULLSEQ = P_SEQ
                     , UPDDATE = V_STAMP
                 WHERE IFTYPE = V_FTYPE
                   AND BASIC = V_BASIC;
            END IF;
        ELSIF P_FTYPE = 'LOT' THEN     
            IF P_WERKS = 'P100' THEN
                IF P_MACH_CD = 'M' OR P_MACH_CD = 'J' THEN  --(M: 수입밀롤, J: 점보롤 비계획생산) 
                    V_FTYPE := SUBSTR(P_DATE, 3,6) || P_MACH_CD;
                    V_BASIC := P_DATE;
                ELSE
                    SELECT FN_RECDATE(TO_DATE(P_DATE, 'YYYY-MM-DD HH24:MI:SS')) INTO V_BASIC
                      FROM DUAL;

                    V_YY := TO_CHAR(TO_DATE(V_BASIC, 'YYYY-MM-DD'), 'YY'); 
                    V_MM := TO_CHAR(TO_DATE(V_BASIC, 'YYYY-MM-DD'), 'MM'); 
                    V_DD := TO_CHAR(TO_DATE(V_BASIC, 'YYYY-MM-DD'), 'DD');

                    --년도
                    IF TO_NUMBER(V_YY) >= 30 THEN
                        V_YY := CHR(TO_NUMBER(V_YY) + 35);
                    ELSE
                        V_YY := SUBSTR(V_YY, 2,1);
                    END IF;

                    --월
                    IF TO_NUMBER(V_MM) >= 10 THEN
                        V_MM := CHR(TO_NUMBER(V_YY) + 55);
                    ELSE
                        V_MM := SUBSTR(V_MM, 2,1);
                    END IF;

                    SELECT M013.PROC_GRP_CD ||  TO_CHAR(M012.LINE) 
                           INTO
                           V_HOGI
                      FROM TB_MAS012 M012,
                           TB_MAS013 M013
                     WHERE M012.PROC_CD = M013.PROC_CD(+)
                       AND M012.MACH_CD = P_MACH_CD;

                    V_FTYPE := V_YY || V_MM || V_DD || V_HOGI;
                END IF;

                SELECT NVL(MAX(SEQ), 0) INTO V_MAXSEQ 
                  FROM TB_WRK500 
                 WHERE IFTYPE = V_FTYPE
                   AND BASIC = V_BASIC;

                V_MAXSEQ := V_MAXSEQ + 1;

                IF P_MACH_CD = 'M' OR P_MACH_CD = 'J' THEN
                    P_SEQ := V_FTYPE || SUBSTR('000' || TO_CHAR(V_MAXSEQ), -3);

                ELSE
                    P_SEQ := V_FTYPE || SUBSTR('0000' || TO_CHAR(V_MAXSEQ), -4);
                END IF;

                IF V_MAXSEQ = 1 THEN
                    INSERT INTO TB_WRK500(IFTYPE, BASIC, SEQ, FULLSEQ, UPDDATE)
                                VALUES(V_FTYPE, V_BASIC, V_MAXSEQ, P_SEQ, V_STAMP);
                    --기준일자 두번째 이후의 경우 기존항목을 마지막 순번으로 변경
                ELSE
                    UPDATE TB_WRK500
                       SET SEQ = V_MAXSEQ
                         , FULLSEQ = P_SEQ
                         , UPDDATE = V_STAMP
                     WHERE IFTYPE = V_FTYPE
                       AND BASIC = V_BASIC;
                END IF;
            ELSE        --HL
                SELECT TO_CHAR(M012.LINE) 
                       INTO
                       V_HOGI
                 FROM TB_MAS012 M012
                WHERE M012.MACH_CD = P_MACH_CD;

                SELECT FN_RECDATE(TO_DATE(P_DATE, 'YYYY-MM-DD HH24:MI:SS')) INTO V_BASIC
                  FROM DUAL;   

                V_YY := TO_CHAR(TO_DATE(V_BASIC, 'YYYY-MM-DD'), 'YY'); 
                V_MM := TO_CHAR(TO_DATE(V_BASIC, 'YYYY-MM-DD'), 'MM'); 
                V_DD := TO_CHAR(TO_DATE(V_BASIC, 'YYYY-MM-DD'), 'DD');

                IF SUBSTR(P_MATNR, 2, 2) = 'SN' OR SUBSTR(P_MATNR, 2, 2) = 'AD' OR  SUBSTR(P_MATNR, 2, 2) = 'BD' THEN          
                    --AD:성인기저귀, BD : 아기기저귀, SN : 생리대
                    V_LOT_DIV := SUBSTR(P_MATNR, 2, 1);
                ELSE                                --화장지
                    IF SUBSTR(P_MATNR, LENGTH(P_MATNR), 1) = 'M' THEN
                        V_LOT_DIV := SUBSTR(P_MATNR, 2, 1) || 'M';
                    ELSE
                        V_LOT_DIV := SUBSTR(P_MATNR, 1, 2);
                    END IF;

                    IF TO_NUMBER(V_MM) >=10 THEN
                        V_MM := CHR(TO_NUMBER(V_MM) + 55);
                    ELSE
                        V_MM := SUBSTR(V_MM, 2, 1);
                    END IF;
                END IF;

                V_FTYPE := V_LOT_DIV || V_HOGI;

                SELECT NVL(MAX(SEQ), 0) INTO V_MAXSEQ 
                  FROM TB_WRK500 
                 WHERE IFTYPE = V_FTYPE
                   AND BASIC = V_BASIC;

                V_MAXSEQ := V_MAXSEQ + 1;

                P_SEQ := V_LOT_DIV || V_YY || V_MM || V_DD || V_HOGI || SUBSTR('00' || TO_CHAR(V_MAXSEQ), -2);

                IF V_MAXSEQ = 1 THEN
                    INSERT INTO TB_WRK500(IFTYPE, BASIC, SEQ, FULLSEQ, UPDDATE)
                                VALUES(V_FTYPE, V_BASIC, V_MAXSEQ, P_SEQ, V_STAMP);
                    --기준일자 두번째 이후의 경우 기존항목을 마지막 순번으로 변경
                ELSE
                    UPDATE TB_WRK500
                       SET SEQ = V_MAXSEQ
                         , FULLSEQ = P_SEQ
                         , UPDDATE = V_STAMP
                     WHERE IFTYPE = V_FTYPE
                       AND BASIC = V_BASIC;
                END IF;
            END IF;
        END IF;                

        BARCODE_CD_RTN := P_SEQ;
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
