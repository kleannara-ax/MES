
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_INV11_RB_S01" (
	P_TYPE           IN    varchar2, -- LIST, SAVE
	P_JSON_STR       IN    CLOB
)
/*==============================================================================
 * PROGRAM ID    : SP_INV11_RB_S01
 * PROGRAM NAME  : 완제품 불출요청(PS)
 * VERSION       : 1.0.0
 * DESCRIPTION   : 완제품 불출요청(PS) 성공 시, 호출하는 프로시저
 *                 
 * AUTHOR NAME   : 안상현
 * CREATE DATE   : 2023/02/21
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * 
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2023/02/21    1.0.0   안상현         Initial Version
 *==============================================================================
 *  관련 테이블
 *        - [V_WRK_ORDR] : (.R..) 작업지시 뷰
 * 		  - [TB_SCH020] : (.R..) 작업지시 BOM정보
 * 		  - [TB_MAS001] : (.R..) 자재마스터
 * 		  - [TB_MAS005] : (.R..) 자재 단위환산마스터
 * 		  - [TB_SCH019] : (.R..) 예외 작업지시
 *=============================================================================*/

AS
	V_PRG_NM			VARCHAR2(100)  := 'SP_INV11_RB_S01';     -- PROCEDURE NAME
	
	-- 오라클 에러 처리용 변수선언 영역
	E_EXCEPTION_USER	EXCEPTION;
	E_SQL_ERR_CD		NUMBER(5) := 0;
	E_SQL_ERR_MSG		VARCHAR2(4000);
	
	-- JSON을 위한 변수선언 영역
	V_JSON				JSON_OBJECT_T;
	V_ARR_HEAD			JSON_ARRAY_T;
	V_OBJ				JSON_OBJECT_T;

	V_PLT_CD			varchar2(2);
	V_SESS_USER_ID		varchar2(20);
	
	V_WERKS				TB_SCH008.WERKS%TYPE;				--플랜트
	V_DOC_NO			TB_IFRWM002.DOC_NO%TYPE;			--MES 문서번호
	V_SEQ               NUMBER(5);							--MES 문서순번(번호)
	V_WRK_ORDR_NO		TB_SCH019.WRK_ORDR_NO%TYPE;			--작업지시번호
	V_WRK_ORDR_SEQNO	TB_SCH019.WRK_ORDR_SEQNO%TYPE;		--작업지시순번
	V_LOT_NO			TB_INV001.LOT_NO%TYPE;				--LOT_NO
	V_DELIPOT			TB_SCH019.DELIPOT%TYPE;				--하역지점
	V_WRK_ORDR			TB_SCH019.WRK_ORDR_NO%TYPE;
	WRK_ORDR_CUR		SYS_REFCURSOR;
BEGIN
	
	V_JSON := JSON_OBJECT_T.parse(P_JSON_STR);
	V_SESS_USER_ID		:= V_JSON.get_string('SES_USER_ID');
	V_PLT_CD			:= V_JSON.get_string('SES_PLNTKY');

	IF P_TYPE = 'COMPLETE' THEN --1
		SELECT 'HAHA' INTO V_WERKS FROM DUAL;
		
	    V_WERKS			:= V_JSON.get_string('WERKS');			--플랜트
	    V_LOT_NO		:= V_JSON.get_string('LOT_NO');			--LOTNO
	    V_DELIPOT		:= V_JSON.get_string('DELIPOT');		--하역지점
	    V_DOC_NO		:= V_JSON.get_string('DOC_NO');			--문서번호
		V_SEQ			:= 1;
	
		V_ARR_HEAD		:=	V_JSON.get_array('head');
	
		IF V_WERKS = 'P100' THEN --2
			FOR i IN 0..V_ARR_HEAD.get_size-1 LOOP --3
				V_OBJ				:= TREAT(V_ARR_HEAD.get(i) AS json_object_t);
				V_OBJ				:= TREAT(V_OBJ.GET('map') AS json_object_t);
				V_WRK_ORDR_NO		:= V_OBJ.get_string('WRK_ORDR_NO');		--작업지시번호
				V_WRK_ORDR_SEQNO	:= V_OBJ.get_string('WRK_ORDR_SEQNO');	--작업지시순번 
					
				--제지 예외 생산인 경우
				IF SUBSTR(V_WRK_ORDR_NO, 3, 2) = 'EX' THEN --4
				
					OPEN WRK_ORDR_CUR FOR --5
						SELECT 
							S019.WRK_ORDR_NO 
						FROM 
							TB_SCH020 S020
						,	TB_SCH019 S019
						WHERE 1=1
						AND S020.ORDER_NO = S019.ORDER_NO 
						AND S020.LOT_NO = V_LOT_NO;
							
					LOOP
						FETCH WRK_ORDR_CUR INTO V_WRK_ORDR;
						EXIT WHEN WRK_ORDR_CUR%NOTFOUND;
								
						IF V_WRK_ORDR_NO = V_WRK_ORDR THEN --6
							UPDATE 
								TB_SCH019 
							SET 
								DELIPOT = V_DELIPOT
							,	UPDDATE = SYSDATE 
							,	UPDID = V_SESS_USER_ID
							WHERE 1=1
							AND WRK_ORDR_NO = V_WRK_ORDR_NO
							AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO;
							  
							--예외 생산 작업지시별 하역지점 이력  
							INSERT INTO TB_SCH021 
							(
								DOC_NO
							,	DOC_SEQNO
							,	WRK_ORDR_NO
							,	WRK_ORDR_SEQNO
							,	DELIPOT
							,	REGDATE
							,	REGID
							)
							VALUES
							(
								V_DOC_NO
							,	TO_CHAR(V_SEQ)
							,	V_WRK_ORDR_NO
							,	V_WRK_ORDR_SEQNO
							,	V_DELIPOT
							,	SYSDATE
							,	V_SESS_USER_ID
							);
						END IF; --6
					END LOOP; --5
					CLOSE WRK_ORDR_CUR; --5
				END IF; --4
			END LOOP; --3
		END IF; --2
		
    END IF; --1
    
    COMMIT;
   
	EXCEPTION
		WHEN E_EXCEPTION_USER THEN
		
		E_SQL_ERR_CD        := SQLCODE;
		E_SQL_ERR_MSG       := SUBSTRB(SQLERRM,1,300);

		ROLLBACK;
		SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);

		WHEN OTHERS THEN
		E_SQL_ERR_CD            := SQLCODE;
		E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

		ROLLBACK;
		RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
		RAISE;
END;
/
