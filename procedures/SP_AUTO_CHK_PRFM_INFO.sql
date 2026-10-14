
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_AUTO_CHK_PRFM_INFO" SP_AUTO_CHK_PRFM_INFO
(
	P_WERKS   IN  VARCHAR2,
	P_PRFM_DT IN  VARCHAR2,
	P_IND_BCD IN  VARCHAR2,
	CREATE_YN OUT VARCHAR2
)

/*==============================================================================
 * PROGRAM ID    : SP_AUTO_CHK_PRFM_INFO{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 자재정보 전송 {호출 프로그램 명 기술}
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 오토라벨러에 자재정보를 전달한다.{프로그램에 대한 상세한 내용 기술}
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
 * yyyy/mm/dd    1.0.0   백우종         Initial Version 
 *==============================================================================
 *  관련 테이블
 * - [TB_MAS001] : (.R..) 화장지 합지기 생산오더
 * - [TB_SCH012] : (.R..) 화장지 합지기 작업지시
 *=============================================================================*/

AS
    --프로그램 ID
    V_PRG_NM			VARCHAR2(100)  := 'SP_AUTO_CHK_PRFM_INFO';     -- PROCEDURE NAME
    V_PLT_CD			VARCHAR2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID		VARCHAR2(20) := 'TEST'; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD		NUMBER(5) := 0;
    E_SQL_ERR_MSG		VARCHAR2(4000);
    --내부변수 관리
    V_DATE				DATE := SYSDATE;
    V_COLINFO			VARCHAR2(1000);
    V_COLTYPE			VARCHAR2(1000);
    V_CNT				NUMBER := 0;
BEGIN
	BEGIN
		BEGIN
			SELECT	COUNT(*) INTO V_CNT
			FROM	TB_WRK001
			WHERE	WERKS = P_WERKS
--			AND		PRFM_DT = P_PRFM_DT
			AND 	IND_BCD = P_IND_BCD;
--			AND		NVL(CNL_YN, 'N') = 'N';
			
			EXCEPTION WHEN NO_DATA_FOUND	THEN
				V_CNT := -1;
		END;

		IF V_CNT > 0	THEN
			CREATE_YN := 'Y';
		ELSE
			CREATE_YN := 'N';
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
			RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
	
			RETURN;
	    --예외처리 종료
	END;
END;
/
