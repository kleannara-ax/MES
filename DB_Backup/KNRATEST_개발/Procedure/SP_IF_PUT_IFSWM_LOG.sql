--------------------------------------------------------
--  DDL for Procedure SP_IF_PUT_IFSWM_LOG
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_IF_PUT_IFSWM_LOG" 
(
     P_WERKS         IN        VARCHAR2        --플랜트
  	,P_SEQTYPE       IN        VARCHAR2        --SEQTYPE  개발서버 : T / 운영서버 : M
  	,P_DOCNO         IN        VARCHAR2        --이전 정보 조회용
  	,P_DOCSEQ        IN        VARCHAR2        --이전 정보 조회용
  	,P_IFID          IN        VARCHAR2        
	,P_JSONDATA      IN        CLOB        
  	,P_RESULT        IN        VARCHAR2        --결과값 Return( S:성공, E:오류 )
  	,P_MESSAGE       IN        VARCHAR2        --결과 메시지
    ,P_USERID        IN        VARCHAR2        --
	,RS_IF_MES_KEY    OUT       VARCHAR2        --리턴 I/F KEY  
    ,Lang            IN        VARCHAR2 DEFAULT 'KO'
    ,RS_CODE         OUT       VARCHAR2 
    ,RS_MSG          OUT       VARCHAR2
)
/*==============================================================================
 * PROGRAM ID    : SP_IF_PUT_IFSWM_LOG
 * PROGRAM NAME  : WMS 인터페이스-로그 저장
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : WMS 인터페이스-로그 저장
 *                  
 *                  
 * AUTHOR NAME   : 김병무{최초 작성자 명 기술}
 * CREATE DATE   : 2023/01/16 {최초 작성일자 기술}
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아위 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 *2023/01/16     1.0.0     김병무         WMS 인터페이스-로그 저장
 *==============================================================================
 *  관련 테이블    
 * - [TB_ITFRCVWMSLOG]  : (CRU.) 
 * - [TB_ITFMESLOG]     : (CRU.) 
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM            VARCHAR2(100)  := 'SP_IF_PUT_IFSWM_LOG';
    V_PLT_CD            VARCHAR2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID      VARCHAR2(20) := P_USERID;

    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER    EXCEPTION;
    E_SQL_ERR_CD        NUMBER(5) := 0;
    E_SQL_ERR_MSG       VARCHAR2(4000);

    --파리미터 처리
    --내부변수 처리
    V_IF_MES_KEY        VARCHAR(100);

    V_IS_UPDATE_LOG     VARCHAR(1);

    V_DOC_NO            TB_IFSWC007.DOC_NO%TYPE;
    V_DOC_SEQNO         TB_IFSWC007.DOC_NOSEQ%TYPE;
    V_LOT_NO            TB_INV001.LOT_NO%TYPE;
    V_WCS_WRK_CD        TB_MAS012.WCS_WRK_CD%TYPE;
    V_DATE              DATE := SYSDATE;
    V_DMY               NUMBER(5) := 0;
    V_MACH_CD           TB_INV003.MACH_CD%TYPE;
    V_MACH_NM           TB_MAS012.MACH_NM%TYPE;

BEGIN
    --예외처리 시작(try)
    BEGIN

        V_IS_UPDATE_LOG := 'C';

        BEGIN
            IF P_IFID = 'MES_IF_402' THEN
                SELECT IF_MES_KEY
                  INTO V_IF_MES_KEY
                  FROM TB_IFSWM005 
                        WHERE DOC_NO = P_DOCNO
                         AND  DOC_SEQNO = P_DOCSEQ;
            ELSIF P_IFID = 'MES_IF_201' AND P_WERKS = 'P500' THEN
                SELECT IF_MES_KEY
                  INTO V_IF_MES_KEY
                  FROM TB_IFSWM003 
                        WHERE DOC_NO = P_DOCNO
                         AND  DOC_SEQNO = P_DOCSEQ;
            ELSIF P_IFID = 'MES_IF_201' AND P_WERKS <> 'P500' THEN
                SELECT IF_MES_KEY
                  INTO V_IF_MES_KEY
                  FROM TB_IFSWM002 
                        WHERE DOC_NO = P_DOCNO
                         AND  DOC_SEQNO = P_DOCSEQ;
            ELSIF P_IFID = 'MES_IF_400' THEN
                SELECT IF_MES_KEY
                  INTO V_IF_MES_KEY
                  FROM TB_IFSWM004 
                        WHERE DOC_NO = P_DOCNO
                         AND  DOC_SEQNO = P_DOCSEQ;
            END IF;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                V_IS_UPDATE_LOG := 'U';

                --인터페이스 파라미터
                SELECT DECODE(P_SEQTYPE, 'M', 'M', 'T') || LTRIM(RTRIM(TO_CHAR(SEQ_GET_IFR_KEY.NEXTVAL, '00000000000000000000000000000'))) INTO V_IF_MES_KEY
                FROM dual;
        END;

        RS_IF_MES_KEY := V_IF_MES_KEY;
        
        IF V_IS_UPDATE_LOG = 'C' THEN
            INSERT INTO TB_ITFRCVWMSLOG (IFID, JSONDATA, LOGNO, SAVEYN) 
                    VALUES  (P_IFID, P_JSONDATA,  V_IF_MES_KEY, P_RESULT);

            --IF Log 등록
            BEGIN 
                INSERT INTO TB_ITFMESLOG (SEQNO, IFID, COMSTAT, ERRTXT, CREDAT, CRETIM, CDATE, CREUSR) 
                        VALUES  (V_IF_MES_KEY, P_IFID, P_RESULT, P_MESSAGE, TO_CHAR(V_DATE, 'YYYYMMDD'), TO_CHAR(V_DATE, 'HH24MISS'), V_DATE, P_IFID);
            EXCEPTION 
                WHEN DUP_VAL_ON_INDEX THEN
                    UPDATE TB_ITFMESLOG
                       SET COMSTAT = P_RESULT
                       , ERRTXT = P_MESSAGE
                       , CREDAT = TO_CHAR(V_DATE, 'YYYYMMDD')
                       , CRETIM = TO_CHAR(V_DATE, 'HH24MISS')
                       , CDATE = V_DATE
                     WHERE SEQNO = V_IF_MES_KEY 
                       AND IFID = P_IFID ;
            END;
        ELSE
            UPDATE TB_ITFMESLOG
               SET COMSTAT = P_RESULT
               , ERRTXT = P_MESSAGE
               , CREDAT = TO_CHAR(V_DATE, 'YYYYMMDD')
               , CRETIM = TO_CHAR(V_DATE, 'HH24MISS')
               , CDATE = V_DATE
             WHERE SEQNO = V_IF_MES_KEY 
               AND IFID = P_IFID ;
        END IF;

        --작업 정상 종료 코드 등록
        RS_CODE := 'S';
        COMMIT;

    --예외처리(catch)
    EXCEPTION
    WHEN dup_val_on_index THEN
         RS_CODE := 'E';
         RS_MSG  := SQLERRM;
         RETURN;
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
        RAISE;
        --RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);

        RS_CODE := 'E';
        RS_MSG  := SQLERRM;
        RETURN;
        --예외처리 종료
    END;
END;

/
