
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_WRK22_S01" (
	P_TYPE         IN    varchar2, -- LIST, SUB_LIST-A, SUB_LIST-B
	P_JSON_STR     IN    CLOB,
	P_SUCCESS      OUT    varchar2,
	P_RS_LIST      OUT    SYS_REFCURSOR 
)
/*==============================================================================
 * PROGRAM ID    : SP_WRK22_S01{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 창고재고현황조회 {호출 프로그램 명 기술}
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 창고재고현황조회 {프로그램에 대한 상세한 내용 기술}
 *                 
 * AUTHOR NAME   : 박성철{최초 작성자 명 기술}
 * CREATE DATE   : 2022/07/15 {최초 작성일자 기술}
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

    V_PRG_NM          VARCHAR2(100)  := 'SP_WRK22_S01';     -- PROCEDURE NAME


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
   V_WERKS        	TB_INV001.WERKS%TYPE;       --플랜트 
   V_STOR_LOC_CD    TB_INV001.STOR_LOC_CD%TYPE; --저장위치 
   V_MATNR          TB_MAS001.MATNR%TYPE;       --자재코드 
   V_MATNR_NM       TB_MAS001.MATNR_NM%TYPE;    --자재명


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

   V_WERKS   		:=       V_JSON.get_string('WERKS');	     --플랜트   
   V_STOR_LOC_CD    :=       V_JSON.get_string('STOR_LOC_CD');   --저장위치 
--   V_MATNR 	    	:=       V_JSON.get_string('MATNR');   	     --자재코드  
   V_MATNR_NM  		:=       V_JSON.get_string('MATNR_NM');		 --자재명    


   IF P_TYPE = 'LIST' THEN /*상단 조회 리스트*/

   		V_SQL :=  ' SELECT
					       INV001.STOR_LOC_CD   -- 저장위치		
					     , MAS003.STOR_LOC_NM   -- 저장위치명		
					     , INV001.STCK_STA   -- 재고상태		
					     , INV001.UCFMTY_AMT   -- 부적합량				
					     , INV001.REGDATE     AS WRHS_RCV_DATE -- 창고입고일시				
					     , WRK001.REGID       AS WRKNM --작업자(->)					
					     , INV001.LOT_NO               --LOT번호					
					     , INV001.MACH_CD              --설비코드					
					     , INV001.MACHINE              --생산호기					
					     , INV001.ORDER_NO             -- 생산오더번호			
					     , INV001.WRK_ORDR_NO          --작업지시번호			
					     , INV001.WRK_ORDR_SEQNO       --작업지시순번		
					     , INV001.IND_BCD  --개별바코드				
					     , INV001.MATNR    --자재코드					
					     , MAS001.MATNR_NM --자재명					
					     , INV001.PRFM_DT  --실적일자					
					     , INV001.PRD_DT   --생산일자					
					     , INV001.UNIT     --단위							
					     , INV001.STCK_QTY --재고량					
					     , INV001.PLT_QTY  AS PALETTE -- 팔래트					
					     , INV001.BOX_QTY  --BOX						
					     , INV001.BAG_QTY  --BAG						
					     , INV001.EA_QTY   --EA							
					     , INV001.ROLLCNT  --ROLL						
					     , INV001.WGT      --중량						
					     , MAS001.PCODE    --지종코드					
					     , MAS001.PCODE_NM --지종명					
					     , V_SCH.KUNNR_NM  -- 거래처명					
					     , V_SCH.NTN_NM    --국가명						
					     , WRK001.RMK   AS PRFM_RMK --비고(실적)					
					     , V_SCH.ORDER_RMK --비고(오더)    			
					     , V_SCH.WRK_ORDR_REMARK --비고(지시)     		
					  FROM TB_INV001 INV001  --공정재고
					  LEFT JOIN TB_WRK001 WRK001  --실적테이블(HL)
					    ON WRK001.WERKS = INV001.WERKS
					   AND WRK001.IND_BCD = INV001.IND_BCD
					  LEFT JOIN TB_MAS001 MAS001  --자재기준정보
					    ON MAS001.MATNR = INV001.MATNR
					   AND MAS001.WERKS	 = INV001.WERKS
					  LEFT JOIN TB_MAS003 MAS003  --저장위치 마스터
					    ON MAS003.WERKS = INV001.WERKS
					   AND MAS003.STOR_LOC_CD = INV001.STOR_LOC_CD
					  LEFT JOIN V_WRK_ORDR V_SCH  --뷰
					    ON V_SCH.WERKS = INV001.WERKS
					   AND V_SCH.WRK_ORDR_NO = INV001.WRK_ORDR_NO
					   AND V_SCH.WRK_ORDR_SEQNO = INV001.WRK_ORDR_SEQNO
					 WHERE 1=1
					   AND NVL(INV001.STCK_QTY, 0) > 0
					   AND INV001.WERKS != ''P100'' ';




		IF  V_WERKS IS NOT NULL OR TRIM(V_WERKS) != '' THEN
            V_SQL := V_SQL || ' AND INV001.WERKS = ''' || V_WERKS || '''';	            --플랜트   
        END IF;

		/*IF  V_STOR_LOC_CD IS NOT NULL OR TRIM(V_STOR_LOC_CD) != '' THEN
            V_SQL := V_SQL || ' AND INV001.STOR_LOC_CD = ''' || V_STOR_LOC_CD || '''';	--저장위치   
        END IF;*/

--		IF  V_MATNR IS NOT NULL OR TRIM(V_MATNR) != '' THEN                             --자재코드
--            V_SQL := V_SQL || ' AND MAS013.PROC_NM  LIKE ''%' || V_MATNR || '%''';             
--        END IF;

		/*IF  V_MATNR_NM IS NOT NULL OR TRIM(V_MATNR_NM) != '' THEN                       -- 자재명
            V_SQL := V_SQL || ' AND MAS001.MATNR_NM  LIKE ''%' || V_MATNR_NM || '%''';             
        END IF;*/


        IF  V_RANGE_SQL IS NOT NULL OR TRIM(V_RANGE_SQL) != '' THEN
        	V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'STOR_LOC_CD', 'INV001.STOR_LOC_CD');		--저장위치
        	V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'MATNR', 'MAS001.MATNR');		--자재코드
            V_SQL := V_SQL || V_RANGE_SQL ;			        
        END IF;

--        V_SQL := V_SQL || ' ORDER BY INV005.WERKS, INV005.INP_DT, INV005.MACH_CD';  


        V_DEBUG := 'Y';

        IF (V_DEBUG = 'Y') THEN
            INSERT INTO PROC_LOG(SQL_STR) VALUES (V_SQL);
        END IF;


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
