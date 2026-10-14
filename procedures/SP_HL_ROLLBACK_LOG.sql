
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_HL_ROLLBACK_LOG" 
(
     P_DOC_NO           IN VARCHAR2                     --문서번호
    ,P_DOC_SEQNO        IN VARCHAR2                     --문서번호 순번
    ,P_LOT_NO			IN VARCHAR2
    ,P_ORDER_NO			IN VARCHAR2
    ,P_WERKS			IN VARCHAR2
    ,P_WORKCENTERCODE	IN VARCHAR2
    ,P_MACH_CD			IN VARCHAR2
    ,P_PRDCD			IN VARCHAR2
    ,P_QTY			    IN NUMBER  
    ,P_MATNR			IN VARCHAR2
    ,P_BUDAT			IN VARCHAR2 
    ,P_RESULT			IN VARCHAR2
    ,P_REMARK			IN VARCHAR2
    ,P_MBLNR			IN VARCHAR2
    ,P_MJAHR			IN VARCHAR2
    ,P_I_IF_ID			IN VARCHAR2 
    ,P_USERID           IN VARCHAR2                     --USER ID
    ,Lang       		IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE     		OUT VARCHAR2 
    ,RS_MSG      		OUT VARCHAR2
)
/*==============================================================================
 * PROGRAM ID    : SP_HL_ROLLBACK_LOG  {호출 프로그램 ID 기술}
 * PROGRAM NAME  : HL 실적등록 롤백 [I/F]
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : .{프로그램에 대한 상세한 내용 기술}
 *                 
 * AUTHOR NAME   : 이성민{최초 작성자 명 기술}
 * CREATE DATE   : 2022/10/25 {최초 작성일자 기술}
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/10/25    1.0.0   이성민         Initial Version 
 *==============================================================================
 *  관련 테이블
 *
 *=============================================================================*/

AS 
	PRAGMA AUTONOMOUS_TRANSACTION; -- 독립 트렌젝션 오픈
    --프로그램 ID : HL ROLLBACK 
    V_PRG_NM        VARCHAR2(100)  := 'SP_HL_ROLLBACK_LOG';    -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := '99';                    --PLANTCODE TEST
    V_SESS_USER_ID   varchar2(20) := P_USERID;               --USERID

    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);


    --parameter변수 처리
    V_REGDATE        DATE := SYSDATE;

BEGIN
  BEGIN

	INSERT INTO TB_WRK030
        (
         DOC_NO,
         DOC_SEQNO,
         WERKS,
         MACH_CD,
         QTY,
         LOT_NO,
         ORDER_NO,
         PRDCD,
         MATNR,
         WORKCENTERCODE,
         BUDAT,
         RESULT,
         SDOC_NO,
         SDOC_SEQNO,
         REGDATE,
         REGID,
         REMARK,
         I_IF_ID)
	VALUES  
		(
         P_DOC_NO,        
         P_DOC_SEQNO,      
         P_WERKS,         
         P_MACH_CD,  
         P_QTY,
         P_LOT_NO,
         P_ORDER_NO, 
         P_PRDCD,
         P_MATNR,
         P_WORKCENTERCODE,
         TO_CHAR(TO_DATE(P_BUDAT),'YYYYMMDD'),
         P_RESULT,
         P_MBLNR,
         P_MJAHR,
         V_REGDATE,       
         P_USERID,            
         SUBSTRB(P_REMARK, 1, 1000) ,
         P_I_IF_ID
        );           


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
