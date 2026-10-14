--------------------------------------------------------
--  DDL for Procedure SP_POP_WRK86_IFR04
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK86_IFR04" SP_POP_WRK86_IFR04
(
     P_SDOC_NO      IN VARCHAR2
    ,P_SDOC_SEQNO   IN VARCHAR2     --  
    ,P_DOC_NO       IN VARCHAR2     --  
    ,P_DOC_SEQNO    IN VARCHAR2     --
    ,P_IND_BCD      IN VARCHAR2
    ,P_USERID       IN VARCHAR2
    ,Lang           IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE     OUT VARCHAR2 
    ,RS_MSG      OUT VARCHAR2
)
/*==============================================================================
 * PROGRAM ID    : SP_POP_WRK86_IFR04
 * PROGRAM NAME  : 실적취소에 대한 롤백 후 확정문서 번호 보정 시행
 * VERSION       : 1.0.1
 * DESCRIPTION   : 실적취소에 대한 롤백 후 확정문서 번호 보정 시행
 *                 
 * AUTHOR NAME   : 이성민
 * CREATE DATE   : 2022/11/22
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/11/22    1.0.0   이성민         Initial Version
 *==============================================================================
 *  관련 테이블
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM            VARCHAR2(100)  := 'SP_POP_WRK86_IFR04';     -- PROCEDURE NAME
    V_PLT_CD            VARCHAR2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID      VARCHAR2(20) := P_USERID; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD        NUMBER(5) := 0;
    E_SQL_ERR_MSG       VARCHAR2(4000);
    --내부변수 관리
    V_DATE              DATE := SYSDATE;
BEGIN
    --예외처리 시작(try)
    BEGIN
		UPDATE TB_WRK001
           SET SDOC_NO      = P_SDOC_NO
              ,SDOC_SEQNO   = P_SDOC_SEQNO
              ,DOC_NO       = P_DOC_NO
              ,DOC_SEQNO 	= P_DOC_SEQNO
              ,UPDDATE   = V_DATE
         WHERE IND_BCD 	 = P_IND_BCD; 
                    	
		UPDATE TB_WRK021
           SET SDOC_NO      = P_SDOC_NO
              ,SDOC_SEQNO   = P_SDOC_SEQNO
              ,UPDDATE   = V_DATE
         WHERE DOC_NO    = P_DOC_NO
           AND DOC_SEQNO = TO_CHAR(TO_NUMBER(P_DOC_SEQNO));      
          

        --작업 정상 종료 코드 등록
        RS_CODE := 'S';
        COMMIT;
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
        --RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
        RAISE;

        RS_CODE := 'E';
        RS_MSG  := SQLERRM;
        RETURN;
    --예외처리 종료
    END;
END ;

/
