--------------------------------------------------------
--  DDL for Procedure SP_WRK16_S01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_WRK16_S01" (
	P_TYPE           IN    varchar2, -- LIST, SAVE
	P_JSON_STR       IN    CLOB,
	P_SUCCESS       OUT    varchar2,
	P_RS_LIST       OUT    SYS_REFCURSOR 
)
/*==============================================================================
 * PROGRAM ID    : WRK16
 * PROGRAM NAME  : 공정별 ERP/PDA 생산실적 조회
 * VERSION       : 1.0.0
 * DESCRIPTION   : 공정별 ERP/PDA 생산실적 조회
 *                 
 * AUTHOR NAME   : 강현주
 * CREATE DATE   : 2022/07/26
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}	<생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}		<생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}			<생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}	<생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/07/26    1.0.0   강현주         Initial Version 
 *==============================================================================
 *  관련 테이블
 *        - [TB_SCH015] 	: ( R  ) 점보롤작업지시 테이블 
 *        - [TB_SCH016] 	: ( R  ) 밀롤작업지시 테이블
 *        - [TB_SCH017] 	: ( R  ) 재단작업지시 테이블
 *        - [TB_SCH018] 	: ( R  ) 포장작업지시 테이블
 *        - [TB_SCH019] 	: ( R  ) 예외생산작업지시 테이블   
 *        - [TB_WRK002]  : ( R  ) 생산실적(PS) 테이블 
 *        - [TB_MAS001]  : ( R  ) 자재마스타 테이블
 *        - [TB_MAS012]  : ( R  ) 설비 마스터 테이블

 *=============================================================================*/


AS
	V_PRG_NM          	VARCHAR2(100) 	:= 'SP_WRK43_S01';     -- PROCEDURE NAME

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
		

	V_MACH_CD           TB_WRK002.MACH_CD%TYPE;			                              --생산호기
	V_PROC_CD           TB_MAS012.PROC_CD%TYPE;			                              --공정
	V_LOT_NO            TB_WRK002.LOT_NO%TYPE;			                              --LOT번호		
	

BEGIN
	OPEN P_RS_LIST FOR 

	SELECT NULL FROM DUAL WHERE ROWNUM = 0;


	V_JSON 				  := JSON_OBJECT_T.parse(P_JSON_STR);

	V_SESS_USER_ID	:= V_JSON.get_string('SES_USER_ID');
	V_PLT_CD			  := V_JSON.get_string('SES_PLNTKY');

	V_WERKS				  := V_JSON.get_string('WERKS');			                            --플랜트코드	
	V_RANGE_SQL     := V_JSON.get_string('RANGE_SQL');	                            --지시일자
	
	V_MACH_CD		    := V_JSON.get_string('MACH_CD');	                              --생산호기
	V_PROC_CD		    := V_JSON.get_string('PROC_CD');	                              --공정
	V_LOT_NO		    := V_JSON.get_string('LOT_NO');	                                --LOT번호		
	

	IF P_TYPE = 'LIST' THEN
		V_SQL :=' 
            SELECT
               K.PRD_REQ_DT                   --생산요청일자
              ,K.MATNR                        --자재코드
              ,K.ORDER_NO                     --오더번호
              ,K.MACHINE                      --FROM생산호기
              ,K.TO_MACHINE                   --TO생산호기
              ,K.PCODE                        --지종
              ,K.BS_WGT                       --평량
              ,K.WRK_ORDR_QTY                 --지시수량
              ,K.PRFM_DT                      --실적일자
              ,K.IND_BCD                      --개별바코드
              ,K.LOT_NO                       --LOT번호
              ,K.PROC_CD                      --공정코드
              ,K.MACH_CD                      --실적설비
              ,K.MACH_NM                      --실적설비명
              ,K.PRFM_QTY                     --실적수량
              ,K.PCNT                         --연수  
              ,K.WGT                          --중량
              ,K.SDOC_NO                      --SAP확정번호
              ,K.SDOC_SEQNO                   --SAP확정순번
              ,K.WERKS                        --플랜트
            FROM (
              SELECT SCH015.PRD_REQ_DT        AS PRD_REQ_DT
                    ,SCH015.MATNR             AS MATNR     
                    ,SCH015.ORDER_NO          AS ORDER_NO    
                    ,SCH015.MACHINE           AS MACHINE   
                    ,SCH015.TO_MACHINE        AS TO_MACHINE
                    ,SCH015.PCODE             AS PCODE  
                    ,SCH015.BS_WGT            AS BS_WGT
                    ,SCH015.WRK_ORDR_QTY      AS WRK_ORDR_QTY  
                    ,WRK002.PRFM_DT           AS PRFM_DT   
                    ,WRK002.IND_BCD           AS IND_BCD   
                    ,WRK002.LOT_NO            AS LOT_NO    
                    ,MAS012.PROC_CD           AS PROC_CD   
                    ,WRK002.MACH_CD           AS MACH_CD   
                    ,MAS012.MACH_NM           AS MACH_NM   
                    ,WRK002.PRFM_QTY          AS PRFM_QTY   
                    ,WRK002.PCNT              AS PCNT      
                    ,WRK002.WGT               AS WGT       
                    ,WRK002.SDOC_NO           AS SDOC_NO   
                    ,WRK002.SDOC_SEQNO        AS SDOC_SEQNO
                    ,WRK002.WERKS             AS WERKS
              FROM TB_WRK002 WRK002
                  ,TB_SCH015 SCH015
                  ,TB_MAS012 MAS012
              WHERE WRK002.WRK_ORDR_NO      = SCH015.WRK_ORDR_NO
              AND   WRK002.WRK_ORDR_SEQNO   = SCH015.WRK_ORDR_SEQNO
              AND   WRK002.MACH_CD          = MAS012.MACH_CD
              UNION
              SELECT SCH016.PRD_REQ_DT        AS PRD_REQ_DT
                    ,SCH016.MATNR             AS MATNR     
                    ,SCH016.ORDER_NO          AS ORDER_NO    
                    ,SCH016.MACHINE           AS MACHINE   
                    ,SCH016.TO_MACHINE        AS TO_MACHINE
                    ,SCH016.PCODE             AS PCODE  
                    ,SCH016.BS_WGT            AS BS_WGT
                    ,SCH016.WRK_ORDR_QTY      AS WRK_ORDR_QTY     
                    ,WRK002.PRFM_DT           AS PRFM_DT   
                    ,WRK002.IND_BCD           AS IND_BCD   
                    ,WRK002.LOT_NO            AS LOT_NO    
                    ,MAS012.PROC_CD           AS PROC_CD   
                    ,WRK002.MACH_CD           AS MACH_CD   
                    ,MAS012.MACH_NM           AS MACH_NM   
                    ,WRK002.PRFM_QTY          AS PRFM_QTY   
                    ,WRK002.PCNT              AS PCNT      
                    ,WRK002.WGT               AS WGT       
                    ,WRK002.SDOC_NO           AS SDOC_NO   
                    ,WRK002.SDOC_SEQNO        AS SDOC_SEQNO
                    ,WRK002.WERKS             AS WERKS      
              FROM TB_WRK002 WRK002
                  ,TB_SCH016 SCH016
                  ,TB_MAS012 MAS012
              WHERE WRK002.WRK_ORDR_NO      = SCH016.WRK_ORDR_NO
              AND   WRK002.WRK_ORDR_SEQNO   = SCH016.WRK_ORDR_SEQNO
              AND   WRK002.MACH_CD          = MAS012.MACH_CD
              UNION
              SELECT SCH017.PRD_REQ_DT        AS PRD_REQ_DT
                    ,SCH017.MATNR             AS MATNR     
                    ,SCH017.ORDER_NO          AS ORDER_NO    
                    ,SCH017.MACHINE           AS MACHINE   
                    ,SCH017.TO_MACHINE        AS TO_MACHINE
                    ,SCH017.PCODE             AS PCODE  
                    ,SCH017.BS_WGT            AS BS_WGT
                    ,SCH017.WRK_ORDR_QTY      AS WRK_ORDR_QTY     
                    ,WRK002.PRFM_DT           AS PRFM_DT   
                    ,WRK002.IND_BCD           AS IND_BCD   
                    ,WRK002.LOT_NO            AS LOT_NO    
                    ,MAS012.PROC_CD           AS PROC_CD   
                    ,WRK002.MACH_CD           AS MACH_CD   
                    ,MAS012.MACH_NM           AS MACH_NM   
                    ,WRK002.PRFM_QTY          AS PRFM_QTY   
                    ,WRK002.PCNT              AS PCNT      
                    ,WRK002.WGT               AS WGT       
                    ,WRK002.SDOC_NO           AS SDOC_NO   
                    ,WRK002.SDOC_SEQNO        AS SDOC_SEQNO
                    ,WRK002.WERKS             AS WERKS      
              FROM TB_WRK002 WRK002
                  ,TB_SCH017 SCH017
                  ,TB_MAS012 MAS012
              WHERE WRK002.WRK_ORDR_NO      = SCH017.WRK_ORDR_NO
              AND   WRK002.WRK_ORDR_SEQNO   = SCH017.WRK_ORDR_SEQNO
              AND   WRK002.MACH_CD          = MAS012.MACH_CD 
              UNION
              SELECT SCH018.PRD_REQ_DT        AS PRD_REQ_DT
                    ,SCH018.MATNR             AS MATNR     
                    ,SCH018.ORDER_NO          AS ORDER_NO    
                    ,SCH018.MACHINE           AS MACHINE   
                    ,SCH018.TO_MACHINE        AS TO_MACHINE
                    ,SCH018.PCODE             AS PCODE  
                    ,SCH018.BS_WGT            AS BS_WGT
                    ,SCH018.WRK_ORDR_QTY      AS WRK_ORDR_QTY     
                    ,WRK002.PRFM_DT           AS PRFM_DT   
                    ,WRK002.IND_BCD           AS IND_BCD   
                    ,WRK002.LOT_NO            AS LOT_NO    
                    ,MAS012.PROC_CD           AS PROC_CD   
                    ,WRK002.MACH_CD           AS MACH_CD   
                    ,MAS012.MACH_NM           AS MACH_NM   
                    ,WRK002.PRFM_QTY          AS PRFM_QTY   
                    ,WRK002.PCNT              AS PCNT      
                    ,WRK002.WGT               AS WGT       
                    ,WRK002.SDOC_NO           AS SDOC_NO   
                    ,WRK002.SDOC_SEQNO        AS SDOC_SEQNO
                    ,WRK002.WERKS             AS WERKS      
              FROM TB_WRK002 WRK002
                  ,TB_SCH018 SCH018
                  ,TB_MAS012 MAS012
              WHERE WRK002.WRK_ORDR_NO      = SCH018.WRK_ORDR_NO
              AND   WRK002.WRK_ORDR_SEQNO   = SCH018.WRK_ORDR_SEQNO
              AND   WRK002.MACH_CD          = MAS012.MACH_CD    
              UNION
              SELECT SCH019.PRD_REQ_DT        AS PRD_REQ_DT
                    ,SCH019.MATNR             AS MATNR     
                    ,SCH019.ORDER_NO          AS ORDER_NO    
                    ,''''                        AS MACHINE   
                    ,''''                        AS TO_MACHINE
                    ,SCH019.PCODE             AS PCODE  
                    ,SCH019.BS_WGT            AS BS_WGT
                    ,SCH019.GAMNG             AS WRK_ORDR_QTY     
                    ,WRK002.PRFM_DT           AS PRFM_DT   
                    ,WRK002.IND_BCD           AS IND_BCD   
                    ,WRK002.LOT_NO            AS LOT_NO    
                    ,MAS012.PROC_CD           AS PROC_CD   
                    ,WRK002.MACH_CD           AS MACH_CD   
                    ,MAS012.MACH_NM           AS MACH_NM   
                    ,WRK002.PRFM_QTY          AS PRFM_QTY  
                    ,WRK002.PCNT              AS PCNT      
                    ,WRK002.WGT               AS WGT       
                    ,WRK002.SDOC_NO           AS SDOC_NO   
                    ,WRK002.SDOC_SEQNO        AS SDOC_SEQNO
                    ,WRK002.WERKS             AS WERKS      
              FROM TB_WRK002 WRK002
                  ,TB_SCH019 SCH019
                  ,TB_MAS012 MAS012
              WHERE WRK002.WRK_ORDR_NO      = SCH019.WRK_ORDR_NO
              AND   WRK002.WRK_ORDR_SEQNO   = SCH019.WRK_ORDR_SEQNO
              AND   WRK002.MACH_CD          = MAS012.MACH_CD )K
            WHERE 1=1
			';
        
			IF (V_WERKS IS NOT NULL OR TRIM(V_WERKS) != '') THEN
        V_SQL := V_SQL || ' AND K.WERKS = ''' || V_WERKS || '''';                       --플랜트코드				      
      END IF;
            								
      IF (V_RANGE_SQL IS NOT NULL OR TRIM(V_RANGE_SQL) != '') THEN               --실적일자
        V_SQL := V_SQL || V_RANGE_SQL; 
      END IF;
      
			IF (V_MACH_CD IS NOT NULL OR TRIM(V_MACH_CD) != '') THEN
            	V_SQL := V_SQL || ' AND K.MACH_CD = ''' || V_MACH_CD || '''';             --호기				      
      END IF;	 
      
			IF (V_PROC_CD IS NOT NULL OR TRIM(V_PROC_CD) != '') THEN
            	V_SQL := V_SQL || ' AND K.PROC_CD = ''' || V_PROC_CD || '''';             --공정				      
      END IF;  
      
			IF (V_LOT_NO IS NOT NULL OR TRIM(V_LOT_NO) != '') THEN
            	V_SQL := V_SQL || ' AND K.LOT_NO LIKE ''%' || V_LOT_NO || '%''';           --공정				      
      END IF;                  
                    

      V_SQL := V_SQL || ' ORDER BY K.PRD_REQ_DT, K.MACH_CD, K.LOT_NO';

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

    --INSERT INTO PROC_LOG (SQL_STR) VALUES (V_SQL); 
    --COMMIT;

		ROLLBACK;
		RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
END;

/
