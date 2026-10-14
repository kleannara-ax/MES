--------------------------------------------------------
--  DDL for Procedure SP_GET_DOC_SEQ
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_GET_DOC_SEQ" SP_GET_DOC_SEQ
(
  P_FTYPE   IN  VARCHAR2,    -- 공정코드(2) I/F ID, WOJ
  P_DATE    IN  VARCHAR2,    -- 생산지시일(20220514)
  DOCNO_RTN OUT VARCHAR2 
) 

/*==============================================================================
 * PROGRAM ID    : SP_GET_DOC_SEQ{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 작업지시번호 채번 {호출 프로그램 명 기술}
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 작업지시번호를 채번한다.{프로그램에 대한 상세한 내용 기술}
 *                 
 * AUTHOR NAME   : 강현주{최초 작성자 명 기술}
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
 * yyyy/mm/dd    1.0.0      강현주       Initial Version 
 *==============================================================================
 *  관련 테이블
 *        - [TB_WRK500] : (CRU.) 채번 이력                   
 *=============================================================================*/

AS 
    --프로그램 ID
    V_PRG_NM          VARCHAR2(100) := 'SP_GET_DOC_SEQ';  -- PROCEDURE NAME
    V_PLT_CD          VARCHAR2(2)   := '00';     --PLANTCODE TEST
    V_SESS_USER_ID    VARCHAR2(20)  := 'SYSTEM'; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);
    --parameter변수 처리
    V_FTYPE           VARCHAR2(20) := P_FTYPE;
    --내부처리변수 추가
    P_SEQ             VARCHAR2(25);
    V_BASIC           VARCHAR2(20);
    V_MAXSEQ          INT;
    V_STAMP           DATE := SYSDATE;
BEGIN
    BEGIN
        BEGIN
           /* 'WO'(2) + 공정코드(2) + 생산지시일(8) + 순서(4) = 16  
           WOJA202205140001                          */

            --날짜정보 기준지정
            IF P_DATE = '' THEN
                V_BASIC := TO_CHAR(SYSDATE, 'YYYYMMDD');
            ELSE
                V_BASIC := TO_CHAR(TO_DATE(P_DATE,'YYYYMMDD'), 'YYYYMMDD');
            END IF;

            V_FTYPE := V_FTYPE;

            --지정된 일자에 등록된 마지막 순번 조회
            SELECT NVL(MAX(SEQ), 0) INTO V_MAXSEQ 
              FROM TB_WRK500 
             WHERE IFTYPE = V_FTYPE
               AND BASIC = V_BASIC;
            --신규 등록 순번 지정
            V_MAXSEQ := V_MAXSEQ + 1;
            --순번정보 작성
            P_SEQ := V_FTYPE || V_BASIC || SUBSTR('0000' || TO_CHAR(V_MAXSEQ), -4);
            --기준일자 첫항목의 경우 테이블에 추가
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
            --작성된 전체순번 반환
            DOCNO_RTN := P_SEQ;
        END;
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
        RAISE_APPLICATION_ERROR(-20000, E_SQL_ERR_MSG);
        RETURN;
    --예외처리 종료
    END;
END;

/
