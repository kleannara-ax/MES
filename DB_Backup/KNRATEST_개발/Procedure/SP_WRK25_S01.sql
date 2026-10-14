--------------------------------------------------------
--  DDL for Procedure SP_WRK25_S01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_WRK25_S01" (
	P_TYPE         IN    varchar2, -- LIST, SUB_LIST-A, SUB_LIST-B
	P_JSON_STR     IN    CLOB,
	P_SUCCESS      OUT    varchar2,
	P_RS_LIST      OUT    SYS_REFCURSOR 
)
/*==============================================================================
 * PROGRAM ID    : SP_WRK25_S01{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 비가동 이력조회 {호출 프로그램 명 기술}
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 비가동 현황 {프로그램에 대한 상세한 내용 기술}
 *                 
 * AUTHOR NAME   : 박성철{최초 작성자 명 기술}
 * CREATE DATE   : 2022/07/13 {최초 작성일자 기술}
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * yyyy/mm/dd    1.0.0   박성철         Initial Version 
 *==============================================================================
 *  관련 테이블
 *=============================================================================*/

AS

    V_PRG_NM          VARCHAR2(100)  := 'SP_WRK25_S01';     -- PROCEDURE NAME


    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5)           := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);

    -- JSON을 위한 변수선언 영역
    V_JSON           JSON_OBJECT_T;
    V_ARR_LIST       JSON_ARRAY_T;
    V_ARR_HEAD       JSON_ARRAY_T;
    V_OBJ            JSON_OBJECT_T;

    -- 세션값 처리용 변수선언 영역
    V_SQL            CLOB;
    V_RUN_SQL        varchar2(1);
    V_RANGE_SQL      varchar2(4000);
    V_DEBUG          varchar2(1);

    -- 세션값 처리용 변수선언 영역
    V_PLT_CD         varchar2(2);
    V_SESS_USER_ID   varchar2(20);

    -- 조건절 처리용 변수선언 영역
    V_MACHINE			TB_SCH016.MACHINE%TYPE;			    -- 생산호기

    -- 리스트(그리드)의 값을 할당하기 위한 변수선언 영역

BEGIN
    OPEN P_RS_LIST FOR 

    SELECT NULL FROM DUAL WHERE ROWNUM = 0;

    V_DEBUG := 'N';
    V_RUN_SQL := 'Y';

    V_JSON := JSON_OBJECT_T.parse(P_JSON_STR);

    V_SESS_USER_ID       :=      V_JSON.get_string('SES_USER_ID');
    V_PLT_CD             :=      V_JSON.get_string('SES_PLNTKY');

    /* 조건값 할당 */
    V_RANGE_SQL         :=      V_JSON.get_string('RANGE_SQL');
    V_MACHINE			:= 		V_JSON.get_string('MACHINE');		-- 생산호기

    IF P_TYPE = 'LIST' THEN /*상단 조회 리스트*/
        V_SQL :=  ' SELECT DISTINCT 
					--	   WRK002.LOT_NO
					--	 , MAS001.PCODE
					--	 , MAS001.PCODE_NM
					--	 , SCH015.MACHINE
					--	 , SCH015.MACHINE_NM
					--	 , WRK002.ROLLCNT
						   SCH016.LOT_NO_M AS MR_LOT_NO
						 , SCH016.ROLLCNT  AS MR_ROLLCNT
						 , SCH016.MBRGEW
						 , SCH016.ORDER_NUM AS WRK_ORDR_NO
					     , SCH016.ORDER_SEQ
					     --, SCH016.JROLLCNT -> 문의
					     , SCH016.SALES_MGT_DOC
					     , SCH016.SAUART_NM AS OPOSNR
					     , SCH016.VDATU
					     , SCH016.BS_WGT
					     , SCH016.MROLLCNT
					     , SCH016.MWIDTH
					     , SCH016.MRCNT  AS PKCNT
					     --, SCH016.SLITER
					     , SCH016.SLITER_SET
					     , SCH017.WLEN AS CT_WLEN
					--     , SCH017.SLITER -> 문의
					     , SCH018.MATNR_SPEC
					     , SCH018.MATNR_NM
					     , SCH018.TOT_WGT AS WGT
					     , SCH018.PCNT AS PCNT_LIM
					     , SCH018.PALETTECNT AS PALETTE
					     , SCH018.PACKTYPE
					     , SCH018.RLL_SHT
					     , SCH018.WRK_ORDR_RMK
					FROM (
						SELECT 
						       NVL(OVBELN, VBELN) SALES_MGT_DOC
					--	     , OVBELN, VBELN
					--	     , WERKS
					--	     , WRK_ORDR_NO
					--	     , WRK_ORDR_SEQNO
						     , INV010.LOT_NO_M
						     , INV010.ROLLCNT
						     , SCH016.MBRGEW
						     , SCH016.ORDER_NUM
						     , SCH016.ORDER_SEQ
					--	     , SCH016.JROLLCNT -> 문의
					--	     , SCH016.VBELN
						     , SCH016.SAUART_NM
						     , SCH016.VDATU
						     , SCH016.BS_WGT
						     , SCH016.MROLLCNT
						     , SCH016.MWIDTH
						     , SCH016.MRCNT
						     , SCH016.SLITER
						     , SCH016.SLITER_SET
						  FROM TB_SCH016 SCH016  --작업지시 밀롤,슬리터
						  LEFT JOIN TB_INV010 INV010   --자재투입이력
					        ON INV010.WERKS = SCH016.WERKS
					       AND INV010.WRK_ORDR_NO = SCH016.WRK_ORDR_NO
					       AND INV010.WRK_ORDR_SEQNO = SCH016.WRK_ORDR_SEQNO
						 WHERE 1=1 REPLACE_PART
					) SCH016
					JOIN (
						SELECT 
						       NVL(OVBELN, VBELN) SALES_MGT_DOC
					--	     , OVBELN, VBELN
						     , WLEN
					--	     , WERKS
					--	     , WRK_ORDR_NO
					--	     , WRK_ORDR_SEQNO
					--	     , MATNR
					--	     , MACHINE
					--	     , MACHINE_NM
						  FROM TB_SCH017  --작업지시 작업지시 재단
					     WHERE 1=1 REPLACE_PART
					) SCH017 ON SCH017.SALES_MGT_DOC = SCH016.SALES_MGT_DOC
					JOIN (
						SELECT 
						       NVL(OVBELN, VBELN) SALES_MGT_DOC
					--	     , OVBELN, VBELN
						     , MAS001.MATNR_SPEC
						     , MAS001.MATNR_NM
						     , SCH018.TOT_WGT
						     , SCH018.PCNT
						     , SCH018.PALETTECNT
						     , SCH018.PACKTYPE
						     , DECODE(SCH018.VLEN, 0,''ROLL'', ''SHEET'') RLL_SHT
						     , SCH018.WRK_ORDR_RMK
					--	     , WERKS
					--	     , WRK_ORDR_NO
					--	     , WRK_ORDR_SEQNO
					--	     , MATNR
					--	     , MACHINE
					--	     , MACHINE_NM
						  FROM TB_SCH018 SCH018  --작업지시 작업지시 포장
					      LEFT JOIN TB_MAS001 MAS001   --자재기준정보
					        ON MAS001.MATNR = SCH018.MATNR
					       AND MAS001.WERKS = SCH018.WERKS
						 WHERE 1=1 REPLACE_PART
					) SCH018 ON SCH018.SALES_MGT_DOC = SCH017.SALES_MGT_DOC ';


--		 V_SQL := REGEXP_REPLACE(V_SQL, 'REPLACE_PART', V_RANGE_SQL);
		 V_SQL := REGEXP_REPLACE(V_SQL, 'REPLACE_PART', ' AND MACHINE = ''' || V_MACHINE || '''' || V_RANGE_SQL);


--        IF  V_MACHINE IS NOT NULL OR TRIM(V_MACHINE) != '' THEN			    -- 생산호기
--            V_SQL := V_SQL || ' AND MACHINE = ''' || V_MACHINE || '''';        
--        END IF;
--
--        IF V_RANGE_SQL IS NOT NULL OR TRIM(V_RANGE_SQL) != '' THEN
--            V_SQL := V_SQL || V_RANGE_SQL;
--        END IF;

--        V_SQL := V_SQL || ' ORDER BY WRK003.WERKS, WRK003.ABN_DT';


--        V_DEBUG := 'Y';
--
--        IF (V_DEBUG = 'Y') THEN
            INSERT INTO PROC_LOG(SQL_STR) VALUES (V_SQL);
--        END IF;


		OPEN P_RS_LIST FOR V_SQL;


--    ELSIF P_TYPE = 'SAVE' THEN
--    	RETURN;


    END IF;


    P_SUCCESS := 'Y';


    EXCEPTION
    WHEN E_EXCEPTION_USER THEN

        -- 에러 내역 SET
	    P_SUCCESS           := 'N';
        E_SQL_ERR_CD        := SQLCODE;
        E_SQL_ERR_MSG       := SUBSTRB(SQLERRM,1,300);

        ROLLBACK;
        SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);

    WHEN OTHERS THEN
	    P_SUCCESS           := 'N';
        E_SQL_ERR_CD        := SQLCODE;
        E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

        ROLLBACK;
        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
END;

/
