--------------------------------------------------------
--  DDL for Procedure SP_CHK_LOT_NO
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_CHK_LOT_NO" 
(
  P_LOT_NO   IN VARCHAR2,       --기존 LOT NO
  P_WERKS    IN VARCHAR2,
  P_MACH_CD  IN VARCHAR2,       --설비코드, 수입밀롤 = M
  P_MATNR    IN VARCHAR2,       --자재코드
  P_DATE     IN VARCHAR2,       --생산지시일(20220514120000), 수입밀롤 : 20220514
  BARCODE_CD_RTN OUT VARCHAR2 
) 

/*==============================================================================
 * PROGRAM ID    : SP_CHK_LOT_NO{호출 프로그램 ID 기술}
 * PROGRAM NAME  : LOT번호 채번 {호출 프로그램 명 기술}
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : HL, PS별로 LOT번호를 채번한다.{프로그램에 대한 상세한 내용 기술}
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
 *=============================================================================*/

AS 
    --프로그램 ID
    V_PRG_NM         VARCHAR2(100):= 'SP_CHK_LOT_NO';     -- PROCEDURE NAME
    V_PLT_CD         VARCHAR2(2)  := '00'; --PLANTCODE TEST
    V_SESS_USER_ID   VARCHAR2(20) := 'SYSTEM'; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER EXCEPTION;
    E_SQL_ERR_CD     NUMBER(5) := 0;
    E_SQL_ERR_MSG    VARCHAR2(4000);
    --parameter변수 처리
    --내부처리변수 추가
    V_FTYPE         VARCHAR2(20); 
    V_HOGI          VARCHAR(20);
    V_BASIC         VARCHAR2(20);
    V_YY            VARCHAR2(2);
    V_MM            VARCHAR2(2);
    V_DD            VARCHAR2(2);
    V_LOT_DIV       VARCHAR2(2);

BEGIN
    BEGIN
        IF P_WERKS = 'P100' THEN
            IF NVL(P_LOT_NO, ' ') = ' ' THEN
                SP_GET_BARCODE_SEQ('LOT', P_WERKS, P_MACH_CD, P_MATNR, P_DATE, BARCODE_CD_RTN);
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
                  INTO V_HOGI
                  FROM TB_MAS012 M012,
                       TB_MAS013 M013
                 WHERE M012.PROC_CD = M013.PROC_CD(+)
                   AND M012.MACH_CD = P_MACH_CD;

                V_FTYPE := V_YY || V_MM || V_DD || V_HOGI;

                IF SUBSTR(P_LOT_NO,1, 6) <> V_FTYPE THEN
                    SP_GET_BARCODE_SEQ('LOT', P_WERKS, P_MACH_CD, P_MATNR, P_DATE, BARCODE_CD_RTN);
                ELSE
                    BARCODE_CD_RTN := P_LOT_NO;
                END IF;

            END IF;            
        ELSE        --HL
            IF NVL(P_LOT_NO, ' ') = ' ' THEN
                SP_GET_BARCODE_SEQ('LOT', P_WERKS, P_MACH_CD, P_MATNR, P_DATE, BARCODE_CD_RTN);
            ELSE
                SELECT TO_CHAR(M012.LINE) 
                  INTO V_HOGI
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

                V_FTYPE := V_LOT_DIV || V_YY || V_MM || V_DD || V_HOGI;

                IF SUBSTR(P_LOT_NO, 1, 8) <> V_FTYPE THEN
                    SP_GET_BARCODE_SEQ('LOT', P_WERKS, P_MACH_CD, P_MATNR, P_DATE, BARCODE_CD_RTN);
                ELSE
                    BARCODE_CD_RTN := P_LOT_NO;
                END IF;
            END IF;        
        END IF;

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
        --RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
        RAISE;
        RETURN;
    --예외처리 종료
    END;
END;

/
