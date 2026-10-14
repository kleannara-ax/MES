--------------------------------------------------------
--  DDL for Procedure SP_POP_WRK26_I09
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK26_I09" 
(
    P_WERKS             IN VARCHAR2 --plantcode
    ,P_MACH_CD          IN VARCHAR2 --설비코드
    ,P_IND_BCD          IN VARCHAR2 --업체/개별바코드(투입 밀롤바코드)
    ,P_USER_ID          IN VARCHAR2 --사용자ID
    ,P_MOVE_FUNC        OUT VARCHAR2 --재고이전
    ,Lang               IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE            OUT VARCHAR2 
    ,RS_MSG             OUT VARCHAR2
    ,CUR_1              OUT SYS_REFCURSOR
    ,CUR_2              OUT SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : SP_POP_WRK26_I09{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 밀롤 재고이전
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 재단 실적 등록하기 전에 2700으로 이동되어 있지 않은 밀롤바코드를 이동시킨다.
 *                 
 * AUTHOR NAME   : 여한진
 * CREATE DATE   : 2022/10/28
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/10/28    1.0.0   여한진         Initial Version 
 *==============================================================================
 *  관련 테이블
 *       - [TB_INV001] : (.R..) 공정재고
 *       - [TB_WRK002] : (.R..) PS실적
 *       - [TB_IFS009] : (CR..) 재고이전
 *=============================================================================*/

AS 
    --프로그램 ID
    V_PRG_NM            VARCHAR2(100)  := 'SP_POP_WRK26_I09';     -- PROCEDURE NAME
    V_PLT_CD            VARCHAR2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID      VARCHAR2(20) := P_USER_ID; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER EXCEPTION;
    E_SQL_ERR_CD        NUMBER(5) := 0;
    E_SQL_ERR_MSG       VARCHAR2(4000);
    --parameter변수 처리
    V_WERKS             VARCHAR2(10) := P_WERKS;
    V_MACH_CD           VARCHAR2(10) := P_MACH_CD;
    V_IND_BCD           VARCHAR2(20) := P_IND_BCD;
    --내부 변수 등록
    V_CNT               NUMBER;

    V_LOT_NO            TB_INV001.LOT_NO%TYPE;
    V_STOR_LOC_FROM     TB_INV001.STOR_LOC_CD%TYPE;
    V_STOR_LOC_TO       TB_INV001.STOR_LOC_CD%TYPE;
    V_MATNR             TB_INV001.MATNR%TYPE;
    V_ORDER_NO          TB_INV001.ORDER_NO%TYPE;
    V_WRK_ORDR_NO       TB_WRK002.WRK_ORDR_NO%TYPE;
    V_WRK_ORDR_SEQNO    TB_WRK002.WRK_ORDR_SEQNO%TYPE;
    V_PRFM_QTY          TB_WRK002.PRFM_QTY%TYPE;
    V_UNIT              TB_WRK002.UNIT%TYPE;
    V_VBELN             TB_INV001.VBELN%TYPE;
    V_POSNR             TB_INV001.POSNR%TYPE;

    V_TO_STK            TB_IFRWC001.TO_STK%TYPE;

    V_PRFM_DT           TB_IFS009.BUDAT%TYPE;					    --전기일

    V_DATE              DATE := SYSDATE;
    V_DOC_MOVE          VARCHAR2(20); --재고이전 문서번호
    V_DOC_SEQ           VARCHAR2(6) := '1';
    V_IF_ID_MOVE        VARCHAR2(20); --자재이전
    V_SQL               VARCHAR2(4000);

BEGIN
    BEGIN
        V_STOR_LOC_FROM := '2000';
        V_STOR_LOC_TO := '2700';

        SELECT I001.MATNR, I001.ORDER_NO, I001.LOT_NO, W002.WRK_ORDR_NO, W002.WRK_ORDR_SEQNO, W002.PRFM_QTY, W002.UNIT, SUBSTR(I001.VBELN, 3), I001.POSNR
          INTO V_MATNR, V_ORDER_NO, V_LOT_NO, V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_PRFM_QTY, V_UNIT, V_VBELN, V_POSNR
          FROM TB_INV001 I001, TB_WRK002 W002
         WHERE I001.IND_BCD = W002.IND_BCD(+)
           AND I001.WERKS = V_WERKS
           AND I001.IND_BCD = V_IND_BCD;

        --재고이전  
        V_DOC_MOVE := FN_GET_MDOCNO('M','IF131');
        V_IF_ID_MOVE := 'MES_IF_131';

        -- 전기일 추가
        V_PRFM_DT := FN_RECDATE(V_DATE);

        INSERT INTO TB_IFS009 
                    (BWART, WERKS_FROM, WERKS_TO, MATNR_FROM, MATNR_TO, LGORT_FROM, LGORT_TO, CHARG_FROM, CHARG_TO,
                    AUFNR, MENGE, MEINS, MDOCNO, MDOCSEQ, ZRESULT, MAKE_DATE, MAKER, VBELN_FROM, POSNR_FROM, VBELN_TO, POSNR_TO, BUDAT)
              VALUES('311', V_WERKS, V_WERKS, V_MATNR, V_MATNR, V_STOR_LOC_FROM, V_STOR_LOC_TO, V_LOT_NO, V_LOT_NO,
                    V_ORDER_NO, V_PRFM_QTY, V_UNIT, V_DOC_MOVE, 1, 'N', V_DATE, V_SESS_USER_ID, V_VBELN, V_POSNR, V_VBELN, V_POSNR, V_PRFM_DT
                    );

        --재고이전 이력
        INSERT INTO TB_WRK017(DOC_NO, DOC_SEQNO, MOVE_DIV, WERKS_FR, MATNR_FR, MATNR_TO, STOR_LOC_FR, STOR_LOC_TO, BUDAT,
                                CHARG_FR, CHARG_TO, MOVE_QTY, UNIT, UCFMTY_YN, REGDATE, REGID)
                        VALUES(V_DOC_MOVE, 1, '311', P_WERKS, V_MATNR, V_MATNR, V_STOR_LOC_FROM, V_STOR_LOC_TO, V_PRFM_DT,
                                V_LOT_NO, V_LOT_NO, V_PRFM_QTY, V_UNIT, 'N', V_DATE, V_SESS_USER_ID);
        
        --IF 전송이력(6:재고이전(위치))
        INSERT INTO TB_WRK021(DOC_NO, DOC_SEQNO, DOC_DIV, WERKS, MACH_CD, WRK_ORDR_NO, WRK_ORDR_SEQNO, IND_BCD, LOT_NO, ORDER_NO, REGDATE, REGID)
                        VALUES(V_DOC_MOVE, 1, 6, V_WERKS, P_MACH_CD, V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_IND_BCD, V_LOT_NO, V_ORDER_NO, V_DATE, V_SESS_USER_ID);

        --SAP FUNC ID 130
        SELECT RFCFN
          INTO P_MOVE_FUNC
          FROM TB_ITFMA
         WHERE 1=1
           AND IFID = V_IF_ID_MOVE;
        --인터페이스 파라미터(재고이전)
        OPEN CUR_1 FOR
        SELECT V_IF_ID_MOVE AS I_IF_ID
             , 'M' || LTRIM(RTRIM(TO_CHAR(SEQ_GET_IFR_KEY.NEXTVAL, '00000000000000000000000000000'))) AS I_IF_KEY
             , V_PRFM_DT AS I_DATE
          FROM dual;
        --인터페이스 상세 파라미터
        V_SQL := FN_IF_QUERY(V_IF_ID_MOVE, V_DOC_MOVE);
        IF V_SQL IS NOT NULL THEN
        	OPEN CUR_2 FOR V_SQL;
        END IF;

        --작업 정상 종료 코드 등록
        RS_CODE := 'S';
        COMMIT;
        --RFC 미사용 항목에 대하여 기본값 등록
        IF CUR_1%ISOPEN = FALSE THEN
            OPEN CUR_1 FOR SELECT 1 FROM dual;
        END IF;
        IF CUR_2%ISOPEN = FALSE THEN
            OPEN CUR_2 FOR SELECT 1 FROM dual;
        END IF;

    --ROLLBACK;
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
        E_SQL_ERR_CD        := -20001;
        E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

        ROLLBACK;
        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);

        RS_CODE := 'E';
        RS_MSG  := SQLERRM;
        RETURN;
    --예외처리 종료
    END;
END SP_POP_WRK26_I09;

/
