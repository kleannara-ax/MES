
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_WRK12_RB_S01" (
	P_TYPE           IN    varchar2, 		-- 실적취소, 재전송
	P_JSON_STR       IN    CLOB,
    P_CNL_RMK        IN    VARCHAR2,
    P_SUCCESS       OUT    VARCHAR2
)
/*==============================================================================
 * PROGRAM ID    : SP_WRK12_RB_S01
 * PROGRAM NAME  : 합지기 생산현황
 * VERSION       : 1.0.0
 * DESCRIPTION   : 합지기 생산현황의 실적취소 후 로직을 관리한다.
 * AUTHOR NAME   : 안상현
 * CREATE DATE   : 2023/01/05
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}	<생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}		<생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}			<생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}	<생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2023/01/05    1.0.0   안상현         Initial Version
 *==============================================================================
 *  관련 테이블
 *        - [TB_WRK001]  : ( R  ) HL 생산 실적 테이블
 *        - [TB_MAS001]  : ( R  ) 자재 기준정보 테이블
 *        - [V_WRK_ORDR] : ( R  ) 작업지시 전체 뷰 테이블
 *        - [USRMA] 	 : ( R  ) 사용자 테이블
 *=============================================================================*/

AS
	V_PRG_NM          	VARCHAR2(100) 	:= 'SP_WRK12_RB_S01';     -- PROCEDURE NAME

	-- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  	EXCEPTION;
    E_SQL_ERR_CD      	NUMBER(5) 		:= 0;
    E_SQL_ERR_MSG		VARCHAR2(4000);

   -- JSON을 위한 변수선언 영역
    V_JSON				JSON_OBJECT_T;
    V_ARR_LIST       	JSON_ARRAY_T;
	V_OBJ            	JSON_OBJECT_T;

	-- 세션값 처리용 변수선언 영역
    V_SESS_USER_ID   	varchar2(20);
    V_PLT_CD         	varchar2(2);
   	V_DEBUG          	varchar2(1);

	-- 조건절 처리용 변수선언 영역
	V_WERKS        		TB_WRK001.WERKS%TYPE;				-- 플랜트코드
	V_MACH_CD	 		TB_WRK001.MACH_CD%TYPE;				-- 설비코드
	V_SQL				CLOB;

    V_SDOC_NO           VARCHAR2(30);						
    V_SDOC_SEQNO        VARCHAR2(10);
    V_IND_BCD           VARCHAR2(20);
    V_WRK_ORDR_NO       VARCHAR2(20);
    V_WRK_ORDR_SEQNO    NUMBER;

    V_SAP_WRK_CD        TB_MAS012.SAP_WRK_CD%TYPE;
    V_DOC_NO            TB_WRK001.DOC_NO%TYPE;
    V_DOC_SEQNO         TB_WRK001.DOC_SEQNO%TYPE;
    V_ORDER_NO          TB_WRK001.ORDER_NO%TYPE;
    V_ROLLCNT           TB_WRK001.ROLLCNT%TYPE;
    V_STA               VARCHAR2(10);
    V_SEQNO_M           TB_INV003.SEQNO%TYPE;
    V_WRK_ORDR_NO_M     TB_INV003.WRK_ORDR_NO%TYPE;
    V_WRK_ORDR_SEQNO_M  TB_INV003.WRK_ORDR_SEQNO%TYPE;
    V_IND_BCD_M         TB_INV003.IND_BCD%TYPE;
    V_LOT_NO_M          TB_INV003.LOT_NO%TYPE;
    V_MATNR_M           TB_INV003.MATNR%TYPE;
    V_INP_DT_M          TB_INV003.INP_DT%TYPE;
    V_USE_QTY_M         TB_INV003.USE_QTY%TYPE;
    V_T_USE_QTY         TB_INV003.USE_QTY%TYPE;
    V_UNIT_M            TB_INV003.UNIT%TYPE;
    V_ROLLCNT_M         TB_INV003.ROLLCNT%TYPE;
    V_WGT_M             TB_INV003.WGT%TYPE;    
    V_CHG_FLG_M         TB_INV003.CHG_FLG%TYPE;    
    V_STCK_KY_M         TB_INV003.STCK_KY%TYPE;
    V_LOT_NUM_M         TB_INV003.LOT_NUM%TYPE;
    V_CHK_PP_YN         TB_WRK001.CHK_PP_YN%TYPE; 
    V_CHK_QC_YN         TB_WRK001.CHK_QC_YN%TYPE; 

    V_DATE              DATE := SYSDATE;
    V_RUNTIME			TB_WRK001.TM%TYPE; --실적 가동시간
	PROD_CUR            SYS_REFCURSOR;		

    V_CNL_RMK           TB_WRK001.CNL_RMK%TYPE;
    V_LOT_NO            TB_WRK001.LOT_NO%TYPE;

    V_CNT               NUMBER;
BEGIN

	V_JSON 				:= JSON_OBJECT_T.parse(P_JSON_STR);

	V_SESS_USER_ID		:= V_JSON.get_string('SES_USER_ID');
	V_PLT_CD			:= V_JSON.get_string('SES_PLNTKY');

	V_WERKS				:= V_JSON.get_string('WERKS');			-- 플랜트코드
	V_MACH_CD			:= V_JSON.get_string('MACH_CD');		-- 설비코드
	V_IND_BCD			:= V_JSON.get_string('IND_BCD');		-- 개별바코드

	V_CNL_RMK           := P_CNL_RMK;							-- 취소사유
	
	IF P_TYPE = '실적취소' THEN
		V_ARR_LIST        := V_JSON.get_array('list');

		FOR i IN 0..V_ARR_LIST.get_size-1 LOOP
            V_OBJ           := TREAT (V_ARR_LIST.get (i) AS json_object_t);
            V_OBJ           := TREAT (V_OBJ.get ('map') AS json_object_t);

            V_WERKS         		:= V_OBJ.get_string('WERKS'); 						-- 플랜트 코드
            V_MACH_CD       		:= V_OBJ.get_string('MACH_CD'); 					-- 설비 코드
            V_IND_BCD       		:= V_OBJ.get_string('IND_BCD'); 					-- 개별 바코드
            V_WRK_ORDR_NO           := V_OBJ.get_string('WRK_ORDR_NO');					-- 작업지시번호
            V_WRK_ORDR_SEQNO        := TO_NUMBER(V_OBJ.get_string('WRK_ORDR_SEQNO')); 	-- 작업지시순번

           SELECT SAP_WRK_CD INTO V_SAP_WRK_CD
              FROM TB_MAS012
             WHERE MACH_CD = V_MACH_CD;

            SELECT ORDER_NO, LOT_NO, ROLLCNT, DOC_NO, DOC_SEQNO, SDOC_NO, SDOC_SEQNO, TM
              INTO V_ORDER_NO, V_LOT_NO, V_ROLLCNT, V_DOC_NO, V_DOC_SEQNO, V_SDOC_NO, V_SDOC_SEQNO, V_RUNTIME
              FROM TB_WRK001
             WHERE WERKS = V_WERKS
               AND MACH_CD = V_MACH_CD
               AND IND_BCD = V_IND_BCD;

              
              --실적취소
            UPDATE TB_WRK001
               SET CNL_YN = 'Y',
                CNL_RMK = V_CNL_RMK,
                PRFM_GTHR_YN = 'N'
             WHERE WERKS = V_WERKS
               AND MACH_CD = V_MACH_CD
               AND IND_BCD = V_IND_BCD;

            --재고 삭제
            UPDATE TB_INV001
               SET STCK_QTY = 0,
                   DLFL = 'Y'
             WHERE WERKS = V_WERKS
               AND MACH_CD = V_MACH_CD
               AND IND_BCD = V_IND_BCD;      

            --작업지시 완료 FLAG 취소
            UPDATE TB_SCH011
               SET COMP_YN = CASE WHEN COMP_YN = 'Y' THEN 'N' ELSE 'I' END
             WHERE WRK_ORDR_NO = V_WRK_ORDR_NO
               AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO;

            --LOT 추적 이력 삭제    
            DELETE
              FROM TB_WRK008
             WHERE WERKS = V_WERKS
               AND IND_BCD = V_IND_BCD;

            UPDATE TB_WRK021
               SET CNL_YN = 'Y'
             WHERE DOC_NO = V_DOC_NO
               AND DOC_SEQNO = V_DOC_SEQNO;   

            --투입자재 취소   
            OPEN PROD_CUR FOR
                SELECT SEQNO, WRK_ORDR_NO, WRK_ORDR_SEQNO, IND_BCD_M, LOT_NO_M, MATNR_M, INP_DT, 
                        USE_QTY, UNIT, ROLLCNT, WGT, CHG_FLG, STCK_KY, LOT_NUM
                        INTO
                        V_SEQNO_M, V_WRK_ORDR_NO_M, V_WRK_ORDR_SEQNO_M, V_IND_BCD_M, V_LOT_NO_M, V_MATNR_M, V_INP_DT_M, 
                        V_USE_QTY_M, V_UNIT_M, V_ROLLCNT_M, V_WGT_M, V_CHG_FLG_M, V_STCK_KY_M, V_LOT_NUM_M
                  FROM TB_INV010
                 WHERE WERKS = V_WERKS 
                   AND MACH_CD = V_MACH_CD
                   AND IND_BCD = V_IND_BCD
                   AND NVL(CNL_YN, 'N') = 'N';
            LOOP
            FETCH PROD_CUR INTO V_SEQNO_M, V_WRK_ORDR_NO_M, V_WRK_ORDR_SEQNO_M, V_IND_BCD_M, V_LOT_NO_M, V_MATNR_M, V_INP_DT_M, 
                                V_USE_QTY_M, V_UNIT_M, V_ROLLCNT_M, V_WGT_M, V_CHG_FLG_M, V_STCK_KY_M, V_LOT_NUM_M;

            EXIT WHEN PROD_CUR %NOTFOUND;    
                UPDATE TB_INV003
                   SET USE_QTY = USE_QTY - V_USE_QTY_M,
                       STCK_QTY = STCK_QTY + V_USE_QTY_M,
                       ROLLCNT = NVL(ROLLCNT, 0) + NVL(V_ROLLCNT_M, 0),
                       WGT = CASE WHEN V_UNIT_M = 'KG' THEN WGT + V_USE_QTY_M ELSE 0 END,
                       UPDDATE = SYSDATE,
                       UPDID = V_SESS_USER_ID
                  WHERE WERKS = V_WERKS
                    AND MACH_CD = V_MACH_CD
                    AND IND_BCD = V_IND_BCD_M;

                IF SQL%ROWCOUNT =0 THEN    
                    SELECT SUM(USE_QTY)  INTO V_T_USE_QTY
                      FROM TB_INV010
                     WHERE WERKS = V_WERKS
                       AND MACH_CD = V_MACH_CD
                       AND IND_BCD_M = V_IND_BCD_M
                       AND USE_QTY > 0;
                      
                    --220825 KKY 자재투입이력 순번처리 수정
                    SELECT MAX(SEQNO) + 1
					  INTO V_SEQNO_M
					  FROM TB_INV003
					 WHERE WERKS = V_WERKS
                       AND MACH_CD = V_MACH_CD
                       AND MATNR = V_MATNR_M;

                    IF V_SEQNO_M IS NULL THEN
                        V_SEQNO_M := 1;
                    end if;
					  
                    INSERT INTO TB_INV003(WERKS, MACH_CD, MATNR, IND_BCD, SEQNO, WRK_ORDR_NO, WRK_ORDR_SEQNO,
                                        LOT_NO, INP_DT, IN_QTY, USE_QTY, STCK_QTY, 
                                        UNIT, ROLLCNT, WGT,
                                        CHG_FLG, STCK_KY, LOT_NUM, REGDATE, REGID)
                                VALUES(V_WERKS, V_MACH_CD, V_MATNR_M, V_IND_BCD_M, V_SEQNO_M, V_WRK_ORDR_NO_M, V_WRK_ORDR_SEQNO_M,
                                        V_LOT_NO_M, V_INP_DT_M, V_T_USE_QTY, V_T_USE_QTY - V_USE_QTY_M, V_T_USE_QTY -(V_T_USE_QTY - V_USE_QTY_M),
                                        V_UNIT_M, V_ROLLCNT_M, V_USE_QTY_M,
                                        V_CHG_FLG_M, V_STCK_KY_M, V_LOT_NUM_M, V_DATE, V_SESS_USER_ID);
                END IF;

                UPDATE TB_INV010
                   SET CNL_YN = 'Y',
                       UPDDATE = SYSDATE,
                       UPDID = V_SESS_USER_ID
                 WHERE WERKS = V_WERKS 
                   AND MACH_CD = V_MACH_CD
                   AND IND_BCD = V_IND_BCD
                   AND IND_BCD_M = V_IND_BCD_M
                   AND MATNR_M = V_MATNR_M;   

            END LOOP;
            CLOSE PROD_CUR;
        END LOOP;
    
	END IF;

	P_SUCCESS := 'Y';
    COMMIT;

	EXCEPTION
	WHEN E_EXCEPTION_USER THEN
		P_SUCCESS           := 'N';
		E_SQL_ERR_CD        := SQLCODE;
		E_SQL_ERR_MSG       := SUBSTRB(SQLERRM,1,300);

		ROLLBACK;
		SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
	WHEN OTHERS THEN
		P_SUCCESS			:= 'N';
		E_SQL_ERR_CD        := SQLCODE;
		E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

		ROLLBACK;
		RAISE_APPLICATION_ERROR(-20001, E_SQL_ERR_MSG);
END;
/
