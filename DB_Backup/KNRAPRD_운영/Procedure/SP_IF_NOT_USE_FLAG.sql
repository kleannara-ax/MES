--------------------------------------------------------
--  DDL for Procedure SP_IF_NOT_USE_FLAG
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_IF_NOT_USE_FLAG" SP_IF_NOT_USE_FLAG
(
     P_MES_IF_ID        IN VARCHAR2
    ,P_DOC_NO           IN VARCHAR2                     --문서번호
    ,P_DOC_SEQNO        IN VARCHAR2                     --문서번호 순번
    ,P_USERID           IN VARCHAR2                     --USER ID
    ,Lang       		IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE     		OUT VARCHAR2 
    ,RS_MSG      		OUT VARCHAR2
)
/*==============================================================================
 * PROGRAM ID    : SP_IF_NOT_USE_FLAG  {호출 프로그램 ID 기술}
 * PROGRAM NAME  : 미사용 IF 플래그 변경 [I/F]
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : .{프로그램에 대한 상세한 내용 기술}
 *                 
 * AUTHOR NAME   : 이성민{최초 작성자 명 기술}
 * CREATE DATE   : 2022/11/11 {최초 작성일자 기술}
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/11/11    1.0.0   이성민         Initial Version 
 *==============================================================================
 *  관련 테이블
 *
 *=============================================================================*/

AS 
    --프로그램 ID : 재단 ROLLBACK 
    V_PRG_NM        VARCHAR2(100)  := 'SP_IF_NOT_USE_FLAG';    -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := '99';                    --PLANTCODE TEST
    V_SESS_USER_ID   varchar2(20) := P_USERID;               --USERID

    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);
    
BEGIN
  BEGIN


	IF P_MES_IF_ID = 'MES_IF_125' THEN
		UPDATE TB_IFS003
		   SET ZRESULT = 'R'
		 WHERE MDOCNO = P_DOC_NO
		   AND MDOCSEQ = P_DOC_SEQNO
		   AND ZRESULT = 'N';
    END IF;
	IF P_MES_IF_ID = 'MES_IF_126' THEN
		UPDATE TB_IFS004
		   SET ZRESULT = 'R'
		 WHERE MDOCNO = P_DOC_NO
		   AND MDOCSEQ = P_DOC_SEQNO
		   AND ZRESULT = 'N';
    END IF;
	IF P_MES_IF_ID = 'MES_IF_127' THEN
		UPDATE TB_IFS005
		   SET ZRESULT = 'R'
		 WHERE MDOCNO = P_DOC_NO
		   AND MDOCSEQ = P_DOC_SEQNO
		   AND ZRESULT = 'N';
    END IF;
	IF P_MES_IF_ID = 'MES_IF_128' THEN
		UPDATE TB_IFS006
		   SET ZRESULT = 'R'
		 WHERE MDOCNO = P_DOC_NO
		   AND MDOCSEQ = P_DOC_SEQNO
		   AND ZRESULT = 'N';
    END IF;
	IF P_MES_IF_ID = 'MES_IF_125' THEN
		UPDATE TB_IFS003
		   SET ZRESULT = 'R'
		 WHERE MDOCNO = P_DOC_NO
		   AND MDOCSEQ = P_DOC_SEQNO
		   AND ZRESULT = 'N';
    END IF;
	IF P_MES_IF_ID = 'MES_IF_134' THEN
		UPDATE TB_IFS012
		   SET ZRESULT = 'R'
		 WHERE MDOCNO = P_DOC_NO
		   AND MDOCSEQ = P_DOC_SEQNO
		   AND ZRESULT = 'N';
    END IF;
	IF P_MES_IF_ID = 'MES_IF_130' THEN
		UPDATE TB_IFS008
		   SET ZRESULT = 'R'
		 WHERE MDOCNO = P_DOC_NO
		   AND MDOCSEQ = P_DOC_SEQNO
		   AND ZRESULT = 'N';
    END IF;
   
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
        E_SQL_ERR_CD        := SQLCODE;
        E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

        ROLLBACK;
        --RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
        RAISE;

        RS_CODE := 'E';
        RS_MSG  := SQLERRM;
        RETURN;
    --예외처리 종료
    END;
END;

/
