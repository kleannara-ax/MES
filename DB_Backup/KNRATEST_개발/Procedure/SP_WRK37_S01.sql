--------------------------------------------------------
--  DDL for Procedure SP_WRK37_S01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_WRK37_S01" (
	P_TYPE         IN    varchar2, -- LIST, SUB_LIST-A, SUB_LIST-B
	P_JSON_STR     IN    CLOB,
	P_SUCCESS      OUT    varchar2,
	P_RS_LIST      OUT    SYS_REFCURSOR 
)
/*==============================================================================
 * PROGRAM ID    : SP_WRK37_S01{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 창고 재고 현황(PS) {호출 프로그램 명 기술}
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 로케이션 현황조회 {프로그램에 대한 상세한 내용 기술}
 *                 
 * AUTHOR NAME   : 박성철{최초 작성자 명 기술}
 * CREATE DATE   : 2022/07/20 {최초 작성일자 기술}
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

    V_PRG_NM          VARCHAR2(100)  := 'SP_WRK37_S01';     -- PROCEDURE NAME

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
   V_LOC_CD          TB_MAS028.LOC_CD%TYPE;     --로케이션 코드 
   V_PCODE          TB_MAS001.PCODE%TYPE;       --지종코드 
   V_BS_WGT         TB_MAS001.BS_WGT%TYPE;      --평량 
   V_MATNR_NM        TB_MAS001.MATNR_NM%TYPE;   --자재명 
   V_MACH_CD         TB_MAS012.MACH_CD%TYPE;    --생산설비 
   V_WLEN        	 TB_SCH019.WLEN%TYPE;    	--실지폭 
   V_SDATE           VARCHAR(8);
   V_EDATE           VARCHAR(8);

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

   V_LOC_CD   		:=       V_JSON.get_string('LOC_CD');	    --로케이션 코드  
   V_PCODE          :=       V_JSON.get_string('PCODE');      	--지종코드 
   V_BS_WGT 	    :=       V_JSON.get_string('BS_WGT');   		--평량   
   V_MATNR_NM  		:=       V_JSON.get_string('MATNR_NM');		--자재명   
   V_MACH_CD  		:=       V_JSON.get_string('MACH_CD'); 		--생산설비   
   V_WLEN  			:=       V_JSON.get_string('WLEN'); 		--실지폭   
   V_SDATE  		:=       V_JSON.get_string('SDATE'); 	
   V_EDATE  		:=       V_JSON.get_string('EDATE'); 	


   IF P_TYPE = 'LIST' THEN /*상단 조회 리스트*/

   		V_SQL :=  ' SELECT 
					       MAS028.LOC_CD                    --로케이션코드
					     , MAS028.LOC_NM                    --로케이션명	
					     , INV001.STOR_LOC_CD               --저장위치
					     , INV001.REGDATE AS WRHS_RCV_DATE  --창고입고일시
					     , WRK002.REGID   AS WRKNM          --작업자(->)	
					     , WRK002.PRD_NO                    --생산번호	
                         --, INV001.PRD_NO                    --생산번호	
					     , INV001.LOT_NO                    --LOT번호	
					     , INV001.IND_BCD                   --개별바코드
					     , INV001.MATNR                     --자재코드	
					     , MAS001.MATNR_NM                  --자재명
					     , DECODE(MAS001.DOMESTIC, ''Y'',''내수'', ''N'',''수출'', NULL, ''내수'') DOMESTIC --내수/수출
					     --, V_SCH.DOMESTIC_NM
					     , MAS001.PCODE    --지종코드	
					     , MAS001.PCODE_NM --지종명	
					     , MAS001.BS_WGT   --평량		
					     , WRK002.WLEN     --가로			
					     , WRK002.VLEN     --세로			
					     , V_SCH.WLEN   AS ORDR_WIDTH --(지시)실지폭
					     , WRK002.WIDTH AS PRD_WIDTH --(생산)실지폭		
					     , WRK002.PACKTYPE -- 포장타입		
					     , WRK002.ROLLCNT  -- 권치수			
					     , WRK002.PCNT     --연수					
					     , WRK002.WGT      --중량			
					     , INV001.PRFM_DT AS PRD_PRFM_DT  --생산실적일시 - 얘기나올시 문의		
					     , MAS012.MACH_NM AS PRD_MACH_NM  --생산실적설비- 얘기나올시 문의		
					     , V_SCH.KUNNR_NM  --거래처명		
					     , V_SCH.NTN_NM    --국가명			
					--     , WRK002.PRFM_DT  --생산실적일시 - 얘기나올시 문의
					--     , WRK002.PRD_DT   --생산실적일시 - 얘기나올시 문의
					--     , V_SCH.PRD_STR_DTM   --생산실적일시 - 얘기나올시 문의
					     --밀롤호기- 얘기나올시 문의
					     --, INV001.MACH_CD   --생산실적설비- 얘기나올시 문의		
					     --, WRK002.KUNNR  -- 거래처코드	
					     , WRK002.VBELN --판매오더		
					     --, WRK002.POSNR --판오더번호순번	
					     --구분(리와인더)- 얘기나올시 문의	
					     --비고컬럼 어떤컬럼인지 - 얘기나올시 문의
					     --LOT별 비고 - 얘기나올시 문의
					--     , WRK002.RMK -- 비고(실적)		
					--     , V_SCH.ORDER_RMK --비고(오더)    
					     --, INV001.WRK_ORDR_NO --작업지시번호	
					     --, INV001.WRK_ORDR_SEQNO --작업지시순번
					     , V_SCH.WRK_ORDR_REMARK --비고(지시)
					--     , INV001.STOR_LOC_CD -- 저장위치
					--     , WRK002.REGDATE --실적등록일시		
					--     , INV001.MACH_CD --설비코드			
					--     , INV001.MACHINE --생산호기			
					--     , INV001.ORDER_NO  -- 생산오더번호
					  FROM TB_INV001 INV001      --공정재고
					  JOIN TB_MAS028 MAS028      --로케이션관리
					    ON MAS028.WERKS = INV001.WERKS
					   AND MAS028.STOR_LOC_CD = INV001.STOR_LOC_CD
					   AND MAS028.LOC_CD = INV001.LOC_CD
					  JOIN TB_WRK002 WRK002      --실적테이블(PS)
					    ON WRK002.WERKS = INV001.WERKS
					   AND WRK002.IND_BCD = INV001.IND_BCD
					  JOIN TB_MAS001 MAS001      --자재기준정보
					    ON MAS001.WERKS = INV001.WERKS
					   AND MAS001.MATNR = INV001.MATNR
					  JOIN TB_MAS012 MAS012      --설비 마스트 정보
					    ON MAS012.MACH_CD = INV001.MACH_CD
--					  JOIN TB_MAS013 MAS013      --공정 마스터 정보
--					    ON MAS013.PROC_CD = MAS012.PROC_CD
--					   AND MAS013.PROC_GRP_CD IN (''M'',''P'')
					  LEFT JOIN V_WRK_ORDR V_SCH --뷰
					    ON V_SCH.WERKS = INV001.WERKS
					   AND V_SCH.WRK_ORDR_NO = INV001.WRK_ORDR_NO
					   AND V_SCH.WRK_ORDR_SEQNO = INV001.WRK_ORDR_SEQNO
					 WHERE 1=1													
					   AND INV001.WERKS = ''P100'' 														
					   AND ( (INV001.STOR_LOC_CD IN (''2700''))
					         OR ( INV001.STOR_LOC_CD IN (''2000'')
					              AND INV001.LOC_CD IN (''L2100'', ''L2200'', ''L2300'',''L2400'',''L2500'', ''L2600'', ''L2800'')
					         )
					       ) ';


		IF  V_LOC_CD IS NOT NULL OR TRIM(V_LOC_CD) != '' THEN
            V_SQL := V_SQL || ' AND MAS028.LOC_CD = ''' || V_LOC_CD || '''';	--로케이션 코드   
        END IF;

		IF  V_MATNR_NM IS NOT NULL OR TRIM(V_MATNR_NM) != '' THEN 				--자재명
            V_SQL := V_SQL || ' AND MAS001.MATNR_NM  LIKE ''%' || V_MATNR_NM || '%''';             
        END IF;

		IF  V_MACH_CD IS NOT NULL OR TRIM(V_MACH_CD) != '' THEN
            V_SQL := V_SQL || ' AND INV001.MACH_CD = ''' || V_MACH_CD || '''';	--생산설비   
        END IF;

		IF  V_WLEN IS NOT NULL OR TRIM(V_WLEN) != '' THEN
            V_SQL := V_SQL || ' AND V_SCH.WLEN = '|| V_WLEN ;		--(지시)실지폭   
        END IF;
        
		IF  V_BS_WGT IS NOT NULL OR TRIM(V_BS_WGT) != '' THEN
            V_SQL := V_SQL || ' AND MAS001.BS_WGT = '|| V_BS_WGT ;		--평량
        END IF;

		IF  V_PCODE IS NOT NULL OR TRIM(V_PCODE) != '' THEN
            V_SQL := V_SQL || ' AND MAS001.PCODE = ''' || V_PCODE || '''' ;		--
        END IF;

        V_SQL := V_SQL || ' AND TO_CHAR(INV001.REGDATE,''YYYYMMDD'') >= ''' || V_SDATE || '''';	
        V_SQL := V_SQL || ' AND TO_CHAR(INV001.REGDATE,''YYYYMMDD'') <= ''' || V_EDATE || '''';	
        
        --V_SQL := V_SQL || ' AND INV001.REGDATE BETWEEN ''' || V_SDATE || ''' AND || V_EDATE || '''';

      /*  IF  V_RANGE_SQL IS NOT NULL OR TRIM(V_RANGE_SQL) != '' THEN
            V_SQL := V_SQL || V_RANGE_SQL ;			        
        END IF;*/
        

       V_SQL := V_SQL || ' ORDER BY MAS028.LOC_CD, MAS028.LOC_NM, INV001.STOR_LOC_CD ' ;	



--        V_DEBUG := 'Y';
--
--        IF (V_DEBUG = 'Y') THEN
            INSERT INTO PROC_LOG(SQL_STR) VALUES (V_SQL);
--        END IF;


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
