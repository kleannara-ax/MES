--------------------------------------------------------
--  DDL for Procedure SP_WRK31_S01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_WRK31_S01" (
	P_TYPE         IN    varchar2, -- LIST, SUB_LIST-A, SUB_LIST-B
	P_JSON_STR     IN    CLOB,
	P_SUCCESS      OUT    varchar2,
	P_RS_LIST      OUT    SYS_REFCURSOR 
)
/*==============================================================================
 * PROGRAM ID    : SP_WRK31_S01{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 창고 재고 현황(PS) {호출 프로그램 명 기술}
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 바코드별 실적 조회 {프로그램에 대한 상세한 내용 기술}
 *                 
 * AUTHOR NAME   : 박성철{최초 작성자 명 기술}
 * CREATE DATE   : 2022/07/22 {최초 작성일자 기술}
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

    V_PRG_NM          VARCHAR2(100)  := 'SP_WRK31_S01';     -- PROCEDURE NAME

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
   V_MACHINE         TB_MAS012.MACHINE%TYPE;    --생산호기
   V_PROC_CD         TB_MAS013.PROC_CD%TYPE;    --공정
--   V_PCODE          TB_MAS001.PCODE%TYPE;       --지종코드 
--   V_BS_WGT         TB_MAS001.BS_WGT%TYPE;      --평량 
   V_WLEN        	 TB_WRK002.WLEN%TYPE;    	--가로 
   V_VLEN        	 TB_WRK002.VLEN%TYPE;    	--세로
   V_NTN_NM        	 TB_MAS009.LAND1%TYPE;    	--국가명

   V_ROUTE        	 TB_SCH016.ROUTE%TYPE;    	--항차
   V_IND_BCD         TB_WRK002.IND_BCD%TYPE;    --바코드
   V_LOT_NO          TB_WRK002.LOT_NO%TYPE;     --LOT_NO


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
   V_RANGE_SQL 		    :=       V_JSON.get_string('RANGE_SQL');   	--작업지시번호, 작업지시번호 순번

   V_MACHINE         :=       V_JSON.get_string('MACHINE');	    --생산호기
   V_PROC_CD         :=       V_JSON.get_string('PROC_CD');	    --공정
--   V_PCODE          :=       V_JSON.get_string('PCODE');      	--지종코드 
    --   V_BS_WGT 	    :=       V_JSON.get_string('BS_WGT');   		--평량   
   V_WLEN        	 :=       V_JSON.get_string('WLEN');	    --가로 
   V_VLEN        	 :=       V_JSON.get_string('VLEN');	    --세로 
   V_NTN_NM        	 :=       V_JSON.get_string('NTN_NM');	    --국가명
   V_ROUTE        	 :=       V_JSON.get_string('ROUTE');	    --항차    
   V_IND_BCD         :=       V_JSON.get_string('IND_BCD');	    --바코드   
   V_LOT_NO          :=       V_JSON.get_string('LOT_NO');	    --LOT_NO   


   IF P_TYPE = 'LIST' THEN /*상단 조회 리스트*/

   		V_SQL :=  ' SELECT DISTINCT
                   WRK002.WERKS      --플랜트
                 , WRK002.MACH_CD    --작업장코드(설비코드)
                 , WRK002.IND_BCD    --개별바코드
                 , MAS013.PROC_NM    --공정명
                 , WRK002.MACHINE    --호기
                 , MAS012.MACH_NM    --설비명
                 , WRK002.LOT_NO     --LOT_NO
                 , WRK002.MATNR      --자재코드
                 , WRK002.PRFM_DT    --실적일자
                 , WRK002.WRK_CLASS  --반
                 , WRK002.WLEN       --가로			
                 , WRK002.WIDTH      --실지폭
                 , WRK002.WIDTH_NO   --지폭순서
                 , WRK002.VLEN       --세로	
                 , WRK002.CORE       --지관	
                 , WRK002.PACKTYPE   --포장타입
                 , WRK002.ROLLCNT AS PRFM_ROLLCNT  --실적권치수
                 , WRK002.PCNT    AS PRFM_PCNT     --실적연수
                 , WRK002.WGT     AS PRFM_WGT      --실적중량
			     , INV001.UNIT		--단위
                 , WRK002.RUN_STA    --운전상태
                 , WRK002.PRD_DT  AS WRK_DATE     --작업일시
                 , WRK002.REGID      --작업자ID
                 , DECODE(MAS001.DOMESTIC, ''Y'',''내수'', ''N'',''수출'') DOMESTIC --내수/수출
                 , MAS001.PCODE      --지종코드	
                 , MAS001.PCODE_NM   --지종명	
                 , MAS001.BS_WGT     --평량	
                 , MAS009.LAND1   AS NTN_NM --국가명	
                 , WRK002.WRK_ORDR_NO     --작업지시번호
                 , WRK002.WRK_ORDR_SEQNO  --작업지시순번
                 , WRK004.DISPO_CD   --폐품코드
                 , MAS023.DISPO_NM   DISPO_CAUSE --폐품원인 컬럼위치 문의
                 , WRK004.ROLLCNT   AS DISPO_ROLLCNT --폐품권치수
                 , WRK004.DISPO_QTY AS DISPO_PCNT    --폐품연수
                 , WRK004.WGT       AS DISPO_WGT     --폐품중량
                 , WRK004.RSPEED    AS CUTTR_RSPEED  --커터선속
                 , WRK004.TM        AS RUN_TM        --가동시간
                 , FN_CD_VAL(''RUN_STA'', WRK004.RUN_STA) RUN_STA_NM --운전상태
                 , NVL(USR.NMLAST,'''') AS WRKNM  --작업자
                 , MAS028.LOC_NM     --로케이션명
                 , WRK002A.MACHINE AS PST_INPT_MACHINE_NM  --후공정 투입호기명
                 , MAS012A.MACH_NM AS PST_INPT_MACH_NM     --후공정 투입설비명
                 , WRK002A.ROLLCNT AS PST_PRFM_RLCNT       --후공정 실적권치수 
                 , WRK002A.PCNT    AS PST_PRFM_PCNT        --후공정 실적연수
                 , WRK002A.WGT     AS PST_PRFM_WGT         --후공정 실적중량 
                 , 0  AS PST_DISPO_RLCNT  --후공정 폐품권치수
                 , 0    AS PST_DISPO_PCNT   --후공정 폐품연수
                 , 0    AS PST_DISPO_WGT    --후공정 폐품중량 
                 , 0    ROUTE --항차
             FROM TB_WRK002  WRK002
                , TB_MAS001  MAS001 --자재기준정보
                , TB_MAS013  MAS013 --공정마스터
                , TB_MAS012  MAS012 --설비마스터
                , TB_MAS009  MAS009 --거래선(업체)마스터
                , TB_WRK004  WRK004
                , USRMA      USR        --사용자
                , TB_INV001  INV001   --공정재고
                , TB_MAS028  MAS028 --로케이션관리
                , TB_INV010  INV010 --
                , TB_MAS012  MAS012A --설비마스터
                , TB_WRK002  WRK002A
                , TB_MAS023  MAS023
            WHERE  WRK002.WERKS   = MAS001.WERKS (+)
              AND  WRK002.MATNR   = MAS001.MATNR (+)
              AND  WRK002.MACH_CD = MAS012.MACH_CD(+)
              AND  MAS012.PROC_CD = MAS013.PROC_CD (+) 
              AND  MAS009.CUST_DIV (+)= ''C''
              AND  WRK002.KUNNR  = MAS009.CUST_CD(+) 
              AND  WRK002.WERKS  = WRK004.WERKS(+)
              AND  WRK002.IND_BCD  = WRK004.IND_BCD(+)
              AND  WRK002.REGID = USR.USERID (+)
              AND  WRK002.WERKS  = INV001.WERKS (+)
              AND  WRK002.IND_BCD = INV001.IND_BCD (+)
              AND  WRK002.MATNR =  INV001.MATNR (+)
              AND  INV001.WERKS = MAS028.WERKS (+)
              AND  INV001.STOR_LOC_CD = MAS028.STOR_LOC_CD (+)
              AND  INV001.LOC_CD = MAS028.LOC_CD (+)
              AND WRK002.WERKS  = INV010.WERKS (+)
              AND WRK002.IND_BCD = INV010.IND_BCD_M (+)
              AND INV010.MACH_CD = MAS012A.MACH_CD(+)
              AND INV010.WERKS   =  WRK002A.WERKS (+)
              AND INV010.IND_BCD  = WRK002A.IND_BCD (+)
              AND WRK004.WERKS    = MAS023.WERKS (+)
              AND WRK004.DISPO_CD = MAS023.DISPO_CD (+)
              AND NVL(WRK002.CNL_YN, ''N'')= ''N''
              AND NVL(WRK004.CNL_YN, ''N'')= ''N''
              AND NVL(INV010.CNL_YN, ''N'')= ''N''
              AND NVL(WRK002A.CNL_YN, ''N'')= ''N''
         ';


		IF  V_MACHINE IS NOT NULL OR TRIM(V_MACHINE) != '' THEN
            V_SQL := V_SQL || ' AND WRK002.MACHINE = ''' || V_MACHINE || '''';	--생산호기   
        END IF;

		IF  V_PROC_CD IS NOT NULL OR TRIM(V_PROC_CD) != '' THEN
            V_SQL := V_SQL || ' AND MAS013.PROC_CD = ''' || V_PROC_CD || '''';	--공정   
        END IF;

		IF  V_WLEN IS NOT NULL OR TRIM(V_WLEN) != '' THEN
            V_SQL := V_SQL || ' AND WRK002.WLEN = '|| V_WLEN ;		--가로
        END IF;

		IF  V_VLEN IS NOT NULL OR TRIM(V_VLEN) != '' THEN
            V_SQL := V_SQL || ' AND WRK002.VLEN = '|| V_VLEN ;		--세로   
        END IF;

		IF  V_NTN_NM IS NOT NULL OR TRIM(V_NTN_NM) != '' THEN 		--국가
            V_SQL := V_SQL || ' AND MAS009.LAND1  LIKE ''%' || V_NTN_NM || '%''';             
        END IF;

		IF  V_IND_BCD IS NOT NULL OR TRIM(V_IND_BCD) != '' THEN 	--바코드
            V_SQL := V_SQL || ' AND WRK002.IND_BCD  LIKE ''%' || V_IND_BCD || '%''';             
        END IF;

		IF  V_LOT_NO IS NOT NULL OR TRIM(V_LOT_NO) != '' THEN 		--LOT_NO
            V_SQL := V_SQL || ' AND WRK002.LOT_NO  LIKE ''%' || V_LOT_NO || '%''';             
        END IF;


        IF  V_RANGE_SQL IS NOT NULL OR TRIM(V_RANGE_SQL) != '' THEN
            V_SQL := V_SQL || V_RANGE_SQL ;			        
        END IF;

 --      IF  V_ROUTE IS NOT NULL OR TRIM(V_ROUTE) != '' THEN 	--항차
 --          V_SQL := V_SQL || ' AND ROUTE = ''' || V_ROUTE || '''';   
--           V_SQL := V_SQL || ' AND ROUTE  LIKE ''%' || V_ROUTE || '%''';             
 --      END IF;

       V_SQL := V_SQL || ' ORDER BY WRK002.IND_BCD ' ;	

        V_DEBUG := 'N';

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
