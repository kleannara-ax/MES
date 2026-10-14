
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_WRK15_S01" (
	P_TYPE         IN    varchar2, -- LIST, SUB_LIST-A, SUB_LIST-B
	P_JSON_STR     IN    CLOB,
	P_SUCCESS      OUT   varchar2,
	P_RS_LIST      OUT   SYS_REFCURSOR 
)
/*==============================================================================
 * PROGRAM ID    : SP_WRK15_S01{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 재공 조회 {호출 프로그램 명 기술}
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 재공조회(호기 및 각 공정별 재공재고 정보 조회) {프로그램에 대한 상세한 내용 기술}
 *                 
 * AUTHOR NAME   : 안상현{최초 작성자 명 기술}
 * CREATE DATE   : 2022/05/31 {최초 작성일자 기술}
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * yyyy/mm/dd    1.0.0   안상현         Initial Version 
 *==============================================================================
 *  관련 테이블 - 모든 테이블 조회만 함
 *        재고테이블 			: ( R  ) TB_INV001
 *        실적테이블 			: ( R  ) TB_WRK002
 *        거래처    			: ( R  ) TB_MAS009                                 
 *        저장위치, 로케이션 	: ( R  ) TB_MAS028
 *        자재테이블 			: ( R  ) TB_MAS001
 *        설비코드 			: ( R  ) TB_MAS012
 *=============================================================================*/

AS

    V_PRG_NM          VARCHAR2(100)  := 'SP_WRK15_S01';     -- PROCEDURE NAME

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
    V_MACHINE		TB_INV001.MACHINE%TYPE;			-- 호기
    V_STOR_LOC_CD	TB_INV001.STOR_LOC_CD%TYPE;		-- 재공타입(로케이션)

BEGIN
    OPEN P_RS_LIST FOR 

    SELECT NULL FROM DUAL WHERE ROWNUM = 0;

    V_DEBUG 			:= 'N';
    V_RUN_SQL			:= 'Y';

    V_JSON := JSON_OBJECT_T.parse(P_JSON_STR);

    V_SESS_USER_ID      :=      V_JSON.get_string('SES_USER_ID');
    V_PLT_CD            :=      V_JSON.get_string('SES_PLNTKY');

    V_MACHINE			:= 		V_JSON.get_string('MACHINE');		-- 호기  
    V_STOR_LOC_CD		:= 		V_JSON.get_string('LOC_CD');		-- 재공타입(로케이션)

    IF P_TYPE = 'LIST' THEN /*상단 조회 리스트*/
        V_SQL :=  
        ' SELECT 
			   	FN_CD_VAL(''MACHINE'', INV001.MACHINE) 						AS MACHINE          --호기명
			,	INV001.PRD_DT                          						AS PRD_DT           --작업일
			,  	INV001.PRD_NO                          						AS PRD_NO			--생산번호
			,  	INV001.LOT_NO                          						AS LOT_NO			--LOT NO
			,  	INV001.IND_BCD                         						AS IND_BCD          --개별바코드
			,  	DECODE(SUBSTR(INV001.MATNR, 6, 7), ''2'',''수출'', ''내수'') 	AS DOMESTIC_NM		--내수,수출
			,  	MAS001.PCODE                           						AS PCODE            --지종
			,	MAS001.PCODE_NM												AS PCODE_NM			--지종명
			,  	MAS001.BS_WGT                         				 		AS BS_WGT           --평량
			,  	WRK002.WLEN                            						AS WLEN             --가로
			,  	WRK002.VLEN                            						AS VLEN             --세로
			,  	WRK002.ROLLCNT                         						AS ROLLCNT          --권치수
			,  	WRK002.PCNT                            						AS PCNT             --연수
			,  	WRK002.WGT                             						AS WGT              --중량
			,	WRK002.REGDATE                         						AS PRD_PRFM         --생산실적일시
			,  	MAS012.MACH_NM       				  						AS MACH_NM          --설비명
			,  	MAS009.CUST_NM       				  						AS CUST_NM          --거래처
			,  	MAS009.LAND1       				     	 					AS LAND1            --국가
			,  	INV001.MATNR       				      						AS MATNR            --자재코드
			, 	INV001.VBELN       				      						AS VBELN            --판매오더
			,	INV001.LOC_CD       				  						AS LOC_CD			--로케이션 코드
			,	MAS028.LOC_NM 												AS LOC_NM			--로케이션 명
			FROM 
			  	TB_INV001 INV001 --재고테이블
			LEFT JOIN TB_MAS001 MAS001 ON (MAS001.MATNR = INV001.MATNR AND MAS001.WERKS = INV001.WERKS) --자재마스터
			LEFT JOIN TB_WRK002 WRK002 ON (WRK002.WERKS = INV001.WERKS AND WRK002.MACH_CD = INV001.MACH_CD AND WRK002.IND_BCD = INV001.IND_BCD) --실적테이블(PS)
			LEFT JOIN TB_MAS012 MAS012 ON (MAS012.MACH_CD = INV001.MACH_CD) --설비코드
			LEFT JOIN TB_MAS009 MAS009 ON (MAS009.KUNNR = INV001.KUNNR) --거래선(업체)마스터
			LEFT JOIN TB_MAS028 MAS028 ON (MAS028.WERKS = INV001.WERKS AND MAS028.LOC_CD = INV001.LOC_CD) --저장위치 마스터(로케이션)
			WHERE 1=1
			AND INV001.WERKS = ''P100''
			AND INV001.STOR_LOC_CD = ''2000''
			AND INV001.STCK_QTY > 0 ';

        IF  V_MACHINE IS NOT NULL OR TRIM(V_MACHINE) != '' THEN	   -- 호기
            V_SQL := V_SQL || ' AND INV001.MACHINE = ''' || V_MACHINE || '''';        
        END IF;

        IF  V_STOR_LOC_CD IS NOT NULL OR TRIM(V_STOR_LOC_CD) != '' THEN	   -- 재공타입(로케이션)
            V_SQL := V_SQL || ' AND INV001.LOC_CD = ''' || V_STOR_LOC_CD || '''';        
        END IF;

        V_SQL := V_SQL || ' ORDER BY INV001.MACHINE, INV001.PRD_DT, INV001.PRD_NO, INV001.LOT_NO';

        V_DEBUG := 'Y';

        IF (V_DEBUG = 'Y') THEN
            INSERT INTO PROC_LOG(SQL_STR) VALUES (V_SQL);
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
	    P_SUCCESS           := 'N';
        E_SQL_ERR_CD        := SQLCODE;
        E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

        ROLLBACK;
        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
END;
/
