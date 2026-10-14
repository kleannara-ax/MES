
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_GET_NO" SP_GET_NO
(
	P_LOT_TEMP		IN VARCHAR2
	,P_WERKS		IN VARCHAR2
	,P_MACH_CD		IN VARCHAR2
	,P_MATNR		IN VARCHAR2
	,P_BARCODE_SEQ	OUT VARCHAR2
	,P_LOT_NO		OUT VARCHAR2
)

/*==============================================================================
 * PROGRAM ID    : SP_GET_NO{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 개별바코드 채번 {호출 프로그램 명 기술}
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 공정별로 LOT_NO, 개별바코드를 채번한다.{프로그램에 대한 상세한 내용 기술}
 *                 
 * AUTHOR NAME   : 백우종{최초 작성자 명 기술}
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
 * 2023/09/07    1.0.0   백우종         Initial Version 
 *==============================================================================
 *  관련 테이블
 *        - [TB_MAS013] : (.R..) 공정마스터
 *        - [TB_MAS012] : (.R..) 설비마스터
 * 	      - [TB_MAS001] : (.R..) 자재마스터
 * 		  - [TB_WRK500] : (CRU.) 바코드 채번 이력                         
 *=============================================================================*/

AS

    --프로그램 ID
    V_PRG_NM         VARCHAR2(100)  := 'SP_GET_NO';     -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := '00'; --PLANTCODE TEST
    V_SESS_USER_ID   varchar2(20) := 'SYSTEM'; --USERID

    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);
    --parameter변수 처리

    --내부처리변수 추가
    V_DATE              DATE := SYSDATE;

BEGIN
	BEGIN
		-- LOT_NO
		SP_CHK_LOT_NO (P_LOT_TEMP, P_WERKS, P_MACH_CD, P_MATNR, TO_CHAR(V_DATE,'YYYY-MM-DD HH24:MI:SS'), P_LOT_NO);

		-- IND_BCD
        SP_GET_BARCODE_SEQ('IND', P_WERKS, P_MACH_CD, P_MATNR, TO_CHAR(V_DATE,'YYYY-MM-DD HH24:MI:SS'), P_BARCODE_SEQ);

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
	        RAISE;
	        RETURN;
	    --예외처리 종료
	END;
END ;
/
