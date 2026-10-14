--------------------------------------------------------
--  DDL for Procedure SP_WRK24_S01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_WRK24_S01" (
	P_TYPE           IN    varchar2,
	P_JSON_STR       IN    CLOB,
	P_SUCCESS       OUT    varchar2,
	P_RS_LIST       OUT    SYS_REFCURSOR 
)
/*==============================================================================
 * PROGRAM ID    : SP_WRK24_S01
 * PROGRAM NAME  : 생산 출고 현황 조회
 * VERSION       : 1.0.0
 * DESCRIPTION   : 생산 출고 현황 조회를 관리한다.
 *                 
 * AUTHOR NAME   : 강동호
 * CREATE DATE   : 2022/07/06
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}	<생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}		<생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}			<생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}	<생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/05/22    1.0.0   강동호         Initial Version 
 *==============================================================================
 *  관련 테이블
 *        - [TB_WRK015] 	: ( R  ) 완제품입고요청 테이블	
 *        - [TB_MAS009] 	: ( R  ) 거래처마스터 테이블		
 *        - [TB_MAS001] 	: ( R  ) 자재마스터 테이블	
 *=============================================================================*/

AS
	V_PRG_NM          	VARCHAR2(100) 	:= 'SP_WRK24_S01';     -- PROCEDURE NAME

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
	V_WERKS         	TB_WRK015.WERKS%TYPE; 			--
    V_MACHINE        	TB_WRK015.MACHINE%TYPE; 			--
	V_PCODE         	TB_WRK015.PCODE%TYPE; 			--
	V_MATNR         	TB_WRK015.MATNR%TYPE; 			--
	V_EMPLY_NM         	TB_WRK015.EMPLY_NM%TYPE; 			--
	V_RANGE_SQL      	varchar2(4000);						--실적일자
    V_SDATE 		TB_WRK015.PRFM_DT%TYPE;   --시작투입일자
    V_EDATE 		TB_WRK015.PRFM_DT%TYPE;   --종료투입일자

	V_SQL				CLOB;
BEGIN
	OPEN P_RS_LIST FOR 

	SELECT NULL FROM DUAL WHERE ROWNUM = 0;

	V_JSON 				:= JSON_OBJECT_T.parse(P_JSON_STR);

	V_SESS_USER_ID		:= V_JSON.get_string('SES_USER_ID');
	V_PLT_CD			:= V_JSON.get_string('SES_PLNTKY');

	V_WERKS			    := V_JSON.get_string('WERKS');
    V_MACHINE			:= V_JSON.get_string('MACHINE'); 	--
    V_PCODE			    := V_JSON.get_string('PCODE'); 	--
    V_MATNR			    := V_JSON.get_string('MATNR');
    V_EMPLY_NM			:= V_JSON.get_string('EMPLY_NM'); --
    
    
    V_SDATE			    :=       V_JSON.get_string('SDATE');		--
    V_EDATE			    :=       V_JSON.get_string('EDATE');        --
    
	V_RANGE_SQL         := V_JSON.get_string('RANGE_SQL');	--실적일자

	IF P_TYPE = 'LIST' THEN
		V_SQL := 
		' SELECT
                WRK015.WERKS            --플랜트
            ,   WRK015.MACHINE   -- 설비호기
            ,   WRK015.ORDER_NO         --오더번호
            ,   WRK015.ORDER_SEQNO      --오더순번
            ,   WRK015.LOT_NO           --lot번호
            ,   WRK015.WRK_ORDR_NO      --작업지시번호
            ,   WRK015.WRK_ORDR_SEQNO   --작업지시순번
            ,   WRK015.MATNR            --자재코드
            ,   MAS001.MATNR_NM         --자재명
            ,   WRK015.STOR_LOC_FR      --저장위치from
            ,   WRK015.STOR_LOC_TO      --저장위치to
            ,   WRK015.IND_BCD          --개별바코드
            ,   WRK015.UNIT             --단위
            ,   WRK015.WGT              --중량
            
            ,   WRK015.PLT_QTY 
            ,   WRK015.BOX_QTY
            ,   WRK015.BAG_QTY
            ,   WRK015.EA_QTY
            
            ,   WRK015.QTY              --수량
            ,   MAS001.PCODE            --지종
            ,   MAS001.PCODE_NM         --지종명
            ,   WRK015.BS_WGT           --평량
            ,   WRK015.WLEN             --가로
            ,   WRK015.VLEN             --세로
            ,   WRK015.CON_TYPE         --컨테이너타입
            ,   DECODE(NVL(FN_CD_VAL(''PACK_TYPE'',WRK015.PACKTYPE), ''FALSE''), ''FALSE'', NULL, ''['' || WRK015.PACKTYPE || '']'' || FN_CD_VAL(''PACK_TYPE'',WRK015.PACKTYPE))    AS PACKTYPE   -- 포장타입
            ,   WRK015.VBELN            --판매문서
            ,   WRK015.POSNR            --판매문서항목번호
            ,   WRK015.SAUART           --판매문서유형
            ,   MAS009.KUNNRT AS KUNNR  --판매처코드
            ,   WRK015.CORE             --지관
            ,   WRK015.EMPLY_NO         --사원id
            --,   WRK015.EMPLY_NM
            ,(SELECT NMLAST FROM USRMA WHERE USERID = WRK015.EMPLY_NO)  AS EMPLY_NM         --사원명
            ,   DECODE(NVL(FN_CD_VAL(''NTN_CD'',WRK015.NTN_CD), ''FALSE''), ''FALSE'', NULL, ''['' || WRK015.NTN_CD || '']'' || FN_CD_VAL(''NTN_CD'',WRK015.NTN_CD))    AS NTN_CD   -- 국가(명)
            ,   WRK015.PRD_DT           --입고일자
            ,   WRK015.PRFM_DT          --실적일자
            ,   WRK015.DSTBT_DDLIN      --유통기한
            ,   WRK015.STCK_NO          --재고번호
            ,   DECODE(NVL(FN_CD_VAL(''REQ_STA'',WRK015.REQ_STA), ''FALSE''), ''FALSE'', NULL, ''['' || WRK015.REQ_STA || '']'' || FN_CD_VAL(''REQ_STA'',WRK015.REQ_STA))    AS REQ_STA   -- 운전상태(명)
             FROM
                TB_WRK015 WRK015
            LEFT JOIN TB_MAS001 MAS001 ON (MAS001.MATNR = WRK015.MATNR AND MAS001.WERKS = WRK015.WERKS)
            LEFT JOIN TB_MAS009 MAS009 ON (MAS009.KUNNR = WRK015.KUNNR) 
            WHERE 1=1
            AND WRK015.WERKS != ''P100'' ';

        IF  V_WERKS IS NOT NULL OR TRIM(V_WERKS) != '' THEN
            V_SQL := V_SQL || ' AND WRK015.WERKS = ''' || V_WERKS || '''';			   --
        END IF;
        
        IF (V_MACHINE IS NOT NULL OR TRIM(V_MACHINE) != '') THEN
            V_SQL := V_SQL || ' AND WRK015.MACHINE = ''' || V_MACHINE || '''';       --				      
        END IF;
		/* 2022-08-17(수요일) 안상현, 지종 코드 검색 조건 제거
        IF  V_PCODE IS NOT NULL OR TRIM(V_PCODE) != '' THEN
            V_SQL := V_SQL || ' AND WRK015.PCODE = ''' || V_PCODE || '''';			   --
        END IF;
        */
        IF  V_MATNR IS NOT NULL OR TRIM(V_MATNR) != '' THEN
            V_SQL := V_SQL || ' AND WRK015.MATNR = ''' || V_MATNR || '''';			   --
        END IF;
        
         IF  V_EMPLY_NM IS NOT NULL OR TRIM(V_EMPLY_NM) != '' THEN
            V_SQL := V_SQL || ' AND WRK015.EMPLY_NM = ''' || V_EMPLY_NM || '''';			   --
        END IF;

        V_SQL := V_SQL || ' AND WRK015.PRFM_DT  BETWEEN ''' || V_SDATE || '''  AND ''' || V_EDATE || '''';	  -- 
        V_SQL := V_SQL || ' AND NVL(WRK015.DLFL, ''C'') != ''D''';
        V_SQL := V_SQL || ' ORDER BY WRK015.MACHINE, WRK015.PRFM_DT ';

        IF (V_DEBUG = 'Y') THEN
        	INSERT INTO PROC_LOG (SQL_STR) VALUES (V_SQL);
        END IF;

		OPEN P_RS_LIST FOR V_SQL;

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
		P_SUCCESS			:= 'N';
        E_SQL_ERR_CD        := SQLCODE;
		E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

		ROLLBACK;
		RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
END;

/
