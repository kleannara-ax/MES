--------------------------------------------------------
--  DDL for Procedure SP_GET_BARCODE_SEQ
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_GET_BARCODE_SEQ" SP_GET_BARCODE_SEQ
(
  P_FTYPE   IN VARCHAR2,            --IND : 개별바코드, LOT : LOT NO
  P_WERKS   IN VARCHAR2,
  P_MACH_CD IN VARCHAR2,            --HL : 설비코드, 개별바코드 --> PS : 점보롤 = J, 수입밀롤/밀롤 = M, 재단 = C, 수재단 = T, 포장 = P, 슬리터/슬리팅 = S, RE-CUTTING/RE-PACKING = Z  
  P_MATNR   IN VARCHAR2,            --자재코드(HL: 자재코드, PS : 수재단이동(T), 등급변경(Q), 그외 '')
  P_DATE    IN VARCHAR2,            -- 생산지시일(2022-05-14 12:00:00), 수입밀롤 : 20220514
  BARCODE_CD_RTN OUT VARCHAR2 
) 

/*==============================================================================
 * PROGRAM ID    : SP_GET_BARCODE_SEQ{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 개별바코드 채번 {호출 프로그램 명 기술}
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 공정별로 개별바코드를 채번한다.{프로그램에 대한 상세한 내용 기술}
 *                 
 * AUTHOR NAME   : 유상호{최초 작성자 명 기술}
 * CREATE DATE   : {최초 작성일자 기술}
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * yyyy/mm/dd    1.0.0   유상호         Initial Version 
 *==============================================================================
 *  관련 테이블
 *        - [TB_MAS013] : (.R..) 공정마스터
 *        - [TB_MAS012] : (.R..) 설비마스터
 * 	      - [TB_MAS001] : (.R..) 자재마스터
 * 		  - [TB_WRK500] : (CRU.) 바코드 채번 이력                         
 *=============================================================================*/

AS 

    PRAGMA AUTONOMOUS_TRANSACTION;

    --프로그램 ID
    V_PRG_NM         VARCHAR2(100)  := 'SP_GET_BARCODE_SEQ';     -- PROCEDURE NAME
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
    V_SEQ_NM    VARCHAR2(20);
    V_LOT_DIV   VARCHAR2(2);
    V_MAXSEQ    INT;
    V_STAMP     DATE := SYSDATE;

    C_WRK500_IND    SYS_REFCURSOR;              --IND
    C_WRK500_LOT    SYS_REFCURSOR;              --LOT

    V_SEQ_J_NEW VARCHAR2(1000);
    V_SEQ_M_NEW VARCHAR2(1000);
    V_SEQ_C_NEW VARCHAR2(1000);
    V_SEQ_T_NEW VARCHAR2(1000);
    V_SEQ_S_NEW VARCHAR2(1000);
    V_SEQ_P_NEW VARCHAR2(1000);

BEGIN

    BEGIN
        IF P_FTYPE = 'IND' THEN    
            --사업부
            IF P_MATNR = 'T' OR P_MATNR = 'Q' OR P_MATNR = 'P' THEN
                V_BUSICD := 'P';
            ELSE
                SELECT BUSICD INTO V_BUSICD
                  FROM TB_MAS001
                 WHERE WERKS = P_WERKS
                   AND MATNR = P_MATNR;
            END IF;

            IF P_WERKS = 'P100' THEN

                SELECT FN_RECDATE(TO_DATE(P_DATE, 'YYYY-MM-DD HH24:MI:SS')) INTO V_BASIC
                  FROM DUAL;

                -- 2022-10-16 김성하 : 개별바코드 중복을 위해 개선(비정상적 상황에서 LOCK을 유발할 수 있음.)

                    V_FTYPE := P_MACH_CD;

                    OPEN  C_WRK500_IND FOR
                      SELECT  SEQ  
                        FROM TB_WRK500 
                       WHERE IFTYPE = V_FTYPE
                         AND BASIC  = V_BASIC
                         FOR UPDATE OF SEQ 
                         SKIP LOCKED;

                    LOOP
                    FETCH C_WRK500_IND INTO V_MAXSEQ;
                         EXIT WHEN C_WRK500_IND%NOTFOUND;    
                    END LOOP;

                    IF NVL(V_MAXSEQ, 0) = 0 OR V_MAXSEQ IS NULL THEN
                       V_MAXSEQ  := 1;
                    ELSE
                       V_MAXSEQ  := V_MAXSEQ + 1;
                    END IF;

                    CLOSE C_WRK500_IND; 

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

                COMMIT;

                V_YY := SUBSTR(V_BASIC, 3, 2);

                V_MM := TO_CHAR(TO_DATE(V_BASIC, 'YYYY-MM-DD'), 'MM');
                --월
                IF TO_NUMBER(V_MM) >= 10 THEN
                    V_MM := CHR(TO_NUMBER(V_MM) + 55);
                ELSE
                    V_MM := SUBSTR(V_MM, 2,1);
                END IF;

                V_DD := SUBSTR(V_BASIC, -2);

                P_SEQ := V_YY || V_MM || V_DD || P_MACH_CD ||  SUBSTR('0000' || TO_CHAR(V_MAXSEQ), -4);

            ELSE        --HL
                SELECT TO_CHAR(M012.LINE) 
                       INTO
                       V_HOGI
                 FROM TB_MAS012 M012
                WHERE M012.MACH_CD = P_MACH_CD;

                SELECT FN_RECDATE(TO_DATE(P_DATE, 'YYYY-MM-DD HH24:MI:SS')) INTO V_BASIC
                  FROM DUAL;   

                IF SUBSTR(P_MATNR, 2, 2) = 'SN' OR SUBSTR(P_MATNR, 2, 2) = 'AD' OR  SUBSTR(P_MATNR, 2, 2) = 'BD' OR  SUBSTR(P_MATNR, 2, 2) = 'ET' THEN          
                    V_LOT_DIV := SUBSTR(P_MATNR, 2, 1);
                    V_FTYPE := V_LOT_DIV || V_HOGI;
                ELSE
                    IF SUBSTR(P_MATNR, 1, 2) = 'HR' THEN        --화장지 합지
                        IF SUBSTR(P_MATNR, LENGTH(P_MATNR), 1) = 'M' THEN
                            V_FTYPE := 'RM';
                        ELSE
                            V_LOT_DIV := 'H';
                            V_FTYPE := V_LOT_DIV || V_HOGI;
                        END IF;
                    ELSIF SUBSTR(P_MATNR, 1, 2) = 'HO' THEN        --화장지 포밍원단
                        IF SUBSTR(P_MATNR, LENGTH(P_MATNR), 1) = 'M' THEN
                            V_FTYPE := 'OM';
                        ELSE
                            V_LOT_DIV := 'H';
                            V_FTYPE := V_LOT_DIV || V_HOGI;
                        END IF;    
                    ELSIF SUBSTR(P_MATNR, 1, 2) = 'FR' THEN     --화장지 가공
                        V_LOT_DIV := 'R';
                        V_FTYPE := V_LOT_DIV || V_HOGI;
                    ELSIF SUBSTR(P_MATNR, 1, 2) = 'HF' THEN    --미용티슈 합지
                        IF SUBSTR(P_MATNR, LENGTH(P_MATNR), 1) = 'M' THEN
                            V_FTYPE := 'FM';
                        ELSE
                            V_LOT_DIV := 'T';
                            V_FTYPE := V_LOT_DIV || V_HOGI;
                        END IF;
                    ELSIF SUBSTR(P_MATNR, 1, 2) = 'FF' THEN    --미용티슈 가공
                        V_LOT_DIV := 'F';
                        V_FTYPE := V_LOT_DIV || V_HOGI;
                    ELSIF SUBSTR(P_MATNR, 1, 2) = 'HK' THEN    --키친타올 합지
                        IF SUBSTR(P_MATNR, LENGTH(P_MATNR), 1) = 'M' THEN
                            V_FTYPE := 'KM';
                        ELSE
                            V_LOT_DIV := 'G';
                            V_FTYPE := V_LOT_DIV || V_HOGI;
                        END IF;
                    ELSIF SUBSTR(P_MATNR, 1, 2) = 'FK' THEN    --키친타올 가공
                        V_LOT_DIV := 'K';
                        V_FTYPE := V_LOT_DIV || V_HOGI;
                    ELSIF SUBSTR(P_MATNR, 1, 2) = 'HW' THEN    --와딩티슈
                        V_FTYPE := 'HW';
--                    ELSE
--                        V_LOT_DIV := SUBSTR(P_MATNR, 2, 1);
--                        V_FTYPE := V_LOT_DIV || V_HOGI;
                    END IF;
                END IF;

                    OPEN  C_WRK500_IND FOR
                      SELECT  SEQ  
                        FROM TB_WRK500 
                       WHERE IFTYPE = V_FTYPE
                         AND BASIC  = V_BASIC
                         FOR UPDATE OF SEQ 
                         SKIP LOCKED;

                    LOOP
                    FETCH C_WRK500_IND INTO V_MAXSEQ;
                         EXIT WHEN C_WRK500_IND%NOTFOUND;    
                    END LOOP;

                    IF NVL(V_MAXSEQ, 0) = 0 OR V_MAXSEQ IS NULL THEN
                       V_MAXSEQ  := 1;
                    ELSE
                       V_MAXSEQ  := V_MAXSEQ + 1;
                    END IF;

                    CLOSE C_WRK500_IND; 

                --V_MAXSEQ := V_MAXSEQ + 1;

                P_SEQ := V_BUSICD || V_BASIC || V_FTYPE || SUBSTR('0000' || TO_CHAR(V_MAXSEQ), -4);

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

                COMMIT;

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
                        V_MM := CHR(TO_NUMBER(V_MM) + 55);
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

                    OPEN  C_WRK500_LOT FOR
                      SELECT  SEQ  
                        FROM TB_WRK500 
                       WHERE IFTYPE = V_FTYPE
                         AND BASIC  = V_BASIC
                         FOR UPDATE OF SEQ 
                         SKIP LOCKED;

                    LOOP
                    FETCH C_WRK500_LOT INTO V_MAXSEQ;
                         EXIT WHEN C_WRK500_LOT%NOTFOUND;    
                    END LOOP;

                    IF NVL(V_MAXSEQ, 0) = 0 OR V_MAXSEQ IS NULL THEN
                       V_MAXSEQ  := 1;
                    ELSE
                       V_MAXSEQ  := V_MAXSEQ + 1;
                    END IF;

                    CLOSE C_WRK500_LOT; 

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

                COMMIT;

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

                    OPEN  C_WRK500_LOT FOR
                      SELECT  SEQ  
                        FROM TB_WRK500 
                       WHERE IFTYPE = V_FTYPE
                         AND BASIC  = V_BASIC
                         FOR UPDATE OF SEQ 
                         SKIP LOCKED;

                    LOOP
                    FETCH C_WRK500_LOT INTO V_MAXSEQ;
                         EXIT WHEN C_WRK500_LOT%NOTFOUND;    
                    END LOOP;

                    IF NVL(V_MAXSEQ, 0) = 0 OR V_MAXSEQ IS NULL THEN
                       V_MAXSEQ  := 1;
                    ELSE
                       V_MAXSEQ  := V_MAXSEQ + 1;
                    END IF;

                    CLOSE C_WRK500_LOT; 

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

                COMMIT;
            END IF;
        END IF;                

        BARCODE_CD_RTN := P_SEQ;

        DBMS_OUTPUT.PUT_LINE(BARCODE_CD_RTN);

       -- COMMIT;

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
--        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
        RAISE;
        RETURN;
    --예외처리 종료
    END;
END;

/
