
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_WRK39_S01" (
	P_TYPE         IN    varchar2, -- LIST, SUB_LIST-A, SUB_LIST-B
	P_JSON_STR     IN    CLOB,
	P_SUCCESS      OUT    varchar2,
	P_RS_LIST      OUT    SYS_REFCURSOR 
)
/*==============================================================================
 * PROGRAM ID    : SP_WRK39_S01{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 밀롤창고 재고 현황(PS) {호출 프로그램 명 기술}
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 창고재고현황조회 {프로그램에 대한 상세한 내용 기술}
 *                 
 * AUTHOR NAME   : 김성하{최초 작성자 명 기술}
 * CREATE DATE   : 2022/07/18 {최초 작성일자 기술}
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * yyyy/mm/dd    1.0.0   김성하         Initial Version 
 *==============================================================================
 *  관련 테이블
 *=============================================================================*/

AS

    V_PRG_NM          VARCHAR2(100)  := 'SP_WRK39_S01';     -- PROCEDURE NAME

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
   V_PROC_NM        TB_MAS013.PROC_NM%TYPE;     --공정명 
   V_MATNR        TB_INV001.MATNR%TYPE;     --자재 
   V_PCODE          TB_MAS001.PCODE%TYPE;       --지종코드 
   V_BS_WGT         TB_MAS001.BS_WGT%TYPE;      --평량 
   V_WIDTHW         TB_WRK002.WLEN%TYPE;        --가로 
   V_WIDTHH         TB_WRK002.VLEN%TYPE;        --세로 


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

--   V_PROC_NM   		:=       V_JSON.get_string('PROC_NM');	    --공정명  
   V_MATNR  		:=       V_JSON.get_string('MATNR'); 		--자재   
   V_PCODE          :=       V_JSON.get_string('PCODE');      	--지종코드 
   V_BS_WGT 	    :=       V_JSON.get_string('BS_WGT');   	--평량   
   V_WIDTHW  		:=       V_JSON.get_string('WIDTHW');		--가로   
   V_WIDTHH  		:=       V_JSON.get_string('WIDTHH'); 		--세로   


   IF P_TYPE = 'LIST' THEN /*상단 조회 리스트*/

   		V_SQL :=  'SELECT INV001.STOR_LOC_CD  --저장위치
					     , INV001.REGDATE AS WRHS_RCV_DATE  --창고입고일시
					     , (SELECT NMLAST FROM USRMA WHERE USERID = WRK002.REGID) AS WRKNM     --작업자
					     , WRK002.PRD_NO   --생산번호	
					     , INV001.LOT_NO   --LOT번호	
					     , INV001.IND_BCD  --개별바코드
                         , DECODE(SUBSTR(INV001.MATNR, 5, 1), ''2'', ''수출'', ''내수'')  AS DOMESTIC --내수/수출
					     , MAS001.PCODE    --지종코드	
					     , MAS001.PCODE_NM --지종명	
					     , MAS001.BS_WGT   --평량		
					     , TO_CHAR(TO_NUMBER(SUBSTR(INV001.MATNR, 10, 4))) AS WLEN  --가로길이
					    -- , WRK002.VLEN     --세로 --삭제			
					     , V_SCH.WLEN   AS ORDR_WIDTH --(지시)실지폭
					     , WRK002.WIDTH AS PRD_WIDTH --(생산)실지폭		
					     , FN_CD_VAL(''PACK_TYPE'', S017.PACKTYPE) AS PACKTYPE    -- 포장타입		
					     , WRK002.ROLLCNT  -- 권치수			
                         , ''M''        AS ROLLUNIT     --권치수단위 --추가
					     --, WRK002.PCNT     --연수	 --삭제				
					     , CASE WHEN INV001.UNIT = ''KG'' THEN INV001.STCK_QTY ELSE WRK002.WGT END WGT      --중량	
                         , ''KG''        AS WUNIT     --중량단위 --추가
					     , WRK002.PRFM_DT AS PRD_PRFM_DT  --생산실적일시 
					     , CASE WHEN INV001.IN_MR_YN = ''Y'' THEN ''수입밀롤'' ELSE MAS012.MACH_NM END  PRD_MACH_NM  --생산실적설비- 얘기나올시 문의		
					     , WRK002.KUNNR  -- 거래처코드	
					     , M009.CUST_NM AS KUNNR_NM       --거래처명
                         , M009.LAND1 AS NTN_NM           --국가명
					     , INV001.MATNR --자재코드	
					     , MAS001.MATNR_NM --자재명	
					     , WRK002.VBELN --판매오더		
					     , V_SCH.WRK_ORDR_REMARK --비고(지시)
                         , WRK002.WRK_ORDR_NO
                         , WRK002.WRK_ORDR_SEQNO
                         , WRK002.ORDER_NO
                         , V_SCH.ORDER_RMK                                                                       AS ORDER_RMK        --밀롤 오더 비고
                         , I010.LOT_NO_M                                                                         AS JR_LOT_NO        --점보롤 LOT_NO
                         , I010.IND_BCD_M                                                                        AS JR_IND_BCD       --점보롤 IND_BCD
                    FROM TB_INV001 INV001      --공정재고
                        LEFT JOIN TB_WRK002 WRK002 ON WRK002.WERKS = INV001.WERKS AND WRK002.IND_BCD = INV001.IND_BCD
                        JOIN TB_MAS001 MAS001 ON MAS001.WERKS = INV001.WERKS AND MAS001.MATNR = INV001.MATNR
                        LEFT JOIN TB_MAS012 MAS012 ON MAS012.MACH_CD = INV001.MACH_CD
                        LEFT JOIN V_WRK_ORDR V_SCH ON V_SCH.WERKS = INV001.WERKS
                                                    AND V_SCH.WRK_ORDR_NO = INV001.WRK_ORDR_NO
                                                    AND V_SCH.WRK_ORDR_SEQNO = INV001.WRK_ORDR_SEQNO
                        LEFT JOIN TB_MAS009 M009 ON WRK002.KUNNR = M009.CUST_CD AND M009.CUST_DIV = ''C''
                        LEFT JOIN TB_SCH017 S017 ON WRK002.ORDER_NO = S017.PRE_ORDER_NO AND S017.USE_YN = ''Y''
                        LEFT JOIN TB_SCH015 S015 ON S015.WERKS = V_SCH.WERKS AND S015.ORDER_NO = V_SCH.PRE_ORDER_NO AND S015.USE_YN = ''Y''
                        LEFT JOIN TB_INV010 I010 ON INV001.LOT_NO = I010.LOT_NO AND INV001.IND_BCD = I010.IND_BCD
                                                    AND V_SCH.WRK_ORDR_NO = I010.WRK_ORDR_NO
                                                    AND V_SCH.WRK_ORDR_SEQNO = I010.WRK_ORDR_SEQNO
                    WHERE 1=1
                        AND INV001.WERKS = ''P100''
                        AND INV001.STOR_LOC_CD IN (''2500'')
                        AND INV001.STCK_QTY > 0';
                        
        IF  V_RANGE_SQL IS NOT NULL OR TRIM(V_RANGE_SQL) != '' THEN
            V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'WLEN', 'TO_CHAR(TO_NUMBER(SUBSTR(INV001.MATNR, 10, 4)))');
            
            V_SQL := V_SQL || V_RANGE_SQL ;			        
        END IF;
--        V_DEBUG := 'Y';
        IF (V_DEBUG = 'Y') THEN
            INSERT INTO PROC_LOG(SQL_STR) VALUES (V_SQL);
            commit;
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
