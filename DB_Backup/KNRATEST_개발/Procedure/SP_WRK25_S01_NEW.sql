--------------------------------------------------------
--  DDL for Procedure SP_WRK25_S01_NEW
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_WRK25_S01_NEW" (
	P_TYPE           IN    varchar2, -- LIST, SAVE
	P_JSON_STR       IN    CLOB,
	P_SUCCESS       OUT    varchar2,
	P_RS_LIST       OUT    SYS_REFCURSOR 
)
/*==============================================================================
 * PROGRAM ID    : WRK25
 * PROGRAM NAME  : 제지 일별 생산 지시 조회
 * VERSION       : 1.0.0
 * DESCRIPTION   : 제지 일별 생산 지시 조회
 *                 
 * AUTHOR NAME   : 강현주
 * CREATE DATE   : 2022/07/18
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}	<생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}		<생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}			<생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}	<생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/07/18    1.0.0   강현주         Initial Version 
 *==============================================================================
 *  관련 테이블
 *        - [V_TRCKING] 	: ( R  ) 트랙킹 뷰(가상 테이블) 
 *        - [TB_SCH015] 	: ( R  ) 점보롤 작업지시 테이블
 *        - [TB_SCH016] 	: ( R  ) 밀롤 작업지시 테이블
 *        - [TB_SCH017] 	: ( R  ) 재단 작업지시 테이블
 *        - [TB_SCH018] 	: ( R  ) 포장 작업지시 테이블  
 *        - [TB_WRK002] 	: ( R  ) 생산실적(PS) 테이블
 *=============================================================================*/


AS
	V_PRG_NM          	VARCHAR2(100) 	:= 'SP_WRK25_S01_NEW';     -- PROCEDURE NAME

	-- 오라클 에러 처리용 변수선언 영역
  E_EXCEPTION_USER  	EXCEPTION;
  E_SQL_ERR_CD      	NUMBER(5) 		:= 0;
  E_SQL_ERR_MSG		    VARCHAR2(4000);

  -- JSON을 위한 변수선언 영역
  V_JSON				      JSON_OBJECT_T;
  V_ARR_LIST       	  JSON_ARRAY_T;
	V_OBJ            	  JSON_OBJECT_T;

	-- 세션값 처리용 변수선언 영역
  V_SESS_USER_ID   	  varchar2(20);
  V_PLT_CD         	  varchar2(2);
  V_DEBUG          	  varchar2(1);

	-- 조건절 처리용 변수선언 영역

	V_SQL				        CLOB;
		
	V_WERKS        		  TB_WRK002.WERKS%TYPE;					                            --플랜트코드	
	V_RANGE_SQL      	  varchar2(4000);						                                --실적일자		
	V_MACHINE        	  TB_WRK002.MACHINE%TYPE;			                              --설비코드(호기)
		



BEGIN
	OPEN P_RS_LIST FOR 

	SELECT NULL FROM DUAL WHERE ROWNUM = 0;

	V_JSON 				  := JSON_OBJECT_T.parse(P_JSON_STR);

	V_SESS_USER_ID	:= V_JSON.get_string('SES_USER_ID');
	V_PLT_CD			  := V_JSON.get_string('SES_PLNTKY');

	V_WERKS				  := V_JSON.get_string('WERKS');			                            --플랜트코드
	V_RANGE_SQL     := V_JSON.get_string('RANGE_SQL');	                            --실적일자
	V_MACHINE			  := V_JSON.get_string('MACHINE');	                              --설비코드(호기)
		

	IF P_TYPE = 'LIST' THEN
		V_SQL :=' 
              SELECT  TRCKING.JJOB_IND_BCD           AS JJOB_IND_BCD                --JRLOT
                     ,SCH015.PCODE                   AS	PCODE												--지종
                     ,SCH015.PRDTYPETXT              AS	PRDTYPETXT									--생산라인구분
                     ,SCH015.JROLLCNT                AS	JPLNROLLCNT									--JR계획권치수
                     ,JWRK002.ROLLCNT                AS	JROLLCNT										--JR실적권치수
                     ,TRCKING.MJOB_IND_BCD           AS	MJOB_IND_BCD								--MRLOT
                     ,TRCKING.MJOB_WRK_ORDR_NO       AS	MJOB_WRK_ORDR_NO						--MR작업지시번호
                     ,TRCKING.MJOB_WRK_ORDR_SEQNO    AS	MJOB_WRK_ORDR_SEQNO					--MR작업지시순번
                     ,SCH016.VBELN                   AS	VBELN												--판매문서번호
                     ,SCH016.MATNR                   AS	MATNR												--SD자재번호
                     ,SCH016.VDATU                   AS	VDATU												--납품요청일
                     ,SCH016.BS_WGT                  AS	BS_WGT											--평량       
                     ,0                              AS	CT_WGT											--CT지폭     
                     ,SCH016.MWIDTH                  AS	MWIDTH											--MR지폭            
                     ,SCH017.PKCNT                   AS	PKCNT											  --폭수    
                     ,SCH017.ZCOR                    AS	ZCOR											  --슬리터
                     ,SCH017.CUTTER                  AS	CUTTER											--슬리터개수     
                     ,SCH016.MROLLCNT                AS	MPLNROLLCNT									--MR계획권치수  
                     ,MWRK002.ROLLCNT                AS	MROLLCNT										--MR실적권치수       
                     ,SCH016.MBRGEW                  AS	MBRGEW										  --MR중량   
                     ,SCH017.WLEN*SCH017.VLEN        AS	CSPEC									      --규격
                     ,SCH017.PLT_PER_CNT             AS	CPLT_PER_CNT								--연수(팔레트당연수)
                     ,SWRK002.PCNT                   AS	CP_CNT									    --연수(팔레트당연수)                
                     ,SCH018.KUNNR                   AS	PKUNNR								      --판매처 
                     ,SCH018.KUNNR                   AS PKUNNR_NM                   --판매처명
                     ,0                              AS PPLT_QTY                    --팔레트수
                     ,SCH018.PACKTYPE                AS PPACKTYPE                   --포장타입   
                     ,SCH016.SHEET                   AS MSHEET                      --Roll/Sheet
                     ,SCH018.ORDER_RMK               AS PORDER_RMK                  --비고                                                                        
              FROM V_TRCKING TRCKING
                  ,TB_SCH015 SCH015         --점보롤작업지시
                  ,TB_WRK002 JWRK002        --점보롤실적
                  ,TB_SCH016 SCH016         --밀롤작업지시
                  ,TB_WRK002 MWRK002        --밀롤실적
                  ,TB_SCH017 SCH017         --재단작업지시
                  ,TB_WRK002 SWRK002        --재단실적
                  ,TB_SCH018 SCH018         --포장작업지시
                  ,TB_WRK002 PWRK002        --포장실적    
              WHERE TRCKING.JJOB_WRK_ORDR_NO    = SCH015.WRK_ORDR_NO
              AND   TRCKING.JJOB_WRK_ORDR_SEQNO = SCH015.WRK_ORDR_SEQNO
              AND   TRCKING.JJOB_IND_BCD        = JWRK002.IND_BCD
              AND   TRCKING.JJOB_MACH_CD        = JWRK002.MACH_CD
              AND   TRCKING.MJOB_WRK_ORDR_NO    = SCH016.WRK_ORDR_NO(+)
              AND   TRCKING.MJOB_WRK_ORDR_SEQNO = SCH016.WRK_ORDR_SEQNO(+)
              AND   TRCKING.MJOB_IND_BCD        = MWRK002.IND_BCD(+)
              AND   TRCKING.MJOB_MACH_CD        = MWRK002.MACH_CD(+)
              AND   TRCKING.CJOB_WRK_ORDR_NO    = SCH017.WRK_ORDR_NO(+)
              AND   TRCKING.CJOB_WRK_ORDR_SEQNO = SCH017.WRK_ORDR_SEQNO(+)
              AND   TRCKING.CJOB_IND_BCD        = SWRK002.IND_BCD(+)
              AND   TRCKING.CJOB_MACH_CD        = SWRK002.MACH_CD(+)
              AND   TRCKING.PJOB_WRK_ORDR_NO    = SCH018.WRK_ORDR_NO(+)
              AND   TRCKING.PJOB_WRK_ORDR_SEQNO = SCH018.WRK_ORDR_SEQNO(+)
              AND   TRCKING.PJOB_IND_BCD        = PWRK002.IND_BCD(+)
              AND   TRCKING.PJOB_MACH_CD        = PWRK002.MACH_CD(+)
			 ';
        
			IF (V_WERKS IS NOT NULL OR TRIM(V_WERKS) != '') THEN
            	V_SQL := V_SQL || ' AND JWRK002.WERKS = ''' || V_WERKS || '''';            --플랜트코드				      
      END IF;
        				 
      IF (V_RANGE_SQL IS NOT NULL OR TRIM(V_RANGE_SQL) != '') THEN                --생산요청일자
        V_SQL := V_SQL || V_RANGE_SQL; 
      END IF;   
          
	  IF (V_MACHINE IS NOT NULL OR TRIM(V_MACHINE) != '') THEN                    --설비코드(호기)
          V_SQL := V_SQL || ' AND JWRK002.MACHINE = ''' || V_MACHINE || '''';            				      
      END IF;             

      V_SQL := V_SQL || ' ORDER BY TRCKING.JJOB_IND_BCD';

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
