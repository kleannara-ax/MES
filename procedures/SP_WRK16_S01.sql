
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
	V_MACHINE           TB_WRK002.MACHINE%TYPE;

BEGIN
	OPEN P_RS_LIST FOR 

	SELECT NULL FROM DUAL WHERE ROWNUM = 0;


	V_JSON 				  := JSON_OBJECT_T.parse(P_JSON_STR);

	V_SESS_USER_ID	:= V_JSON.get_string('SES_USER_ID');
	V_PLT_CD			  := V_JSON.get_string('SES_PLNTKY');

--	V_WERKS				  := V_JSON.get_string('WERKS');			                            --플랜트코드	
	V_RANGE_SQL     := V_JSON.get_string('RANGE_SQL');	                            --지시일자
	
	V_MACHINE		    := V_JSON.get_string('MACHINE');	                              --생산호기
--	V_PROC_CD		    := V_JSON.get_string('PROC_CD');	                              --공정
--	V_LOT_NO		    := V_JSON.get_string('LOT_NO');	                                --LOT번호		
--	

	IF P_TYPE = 'LIST' THEN
		V_SQL := 'SELECT W002.WERKS                   --플랜트
                        , ORDR.PRD_REQ_DT
                        , W002.MATNR                    --자재코드
                        , W002.ORDER_NO                 --오더번호
                        , ''PM'' || SUBSTR(W002.MATNR, 2, 1)   AS MACHINE  --호기
                        --, W002.MACHINE                  --생산호기
                        --, ''''   AS TO_MACHINE
                        , SUBSTR(W002.MATNR, 3, 3)  AS PCODE --지종코드
                        , SUBSTR(W002.MATNR, 6, 3)  AS BS_WGT --평량
                        , ORDR.ORDR_QTY             AS WRK_ORDR_QTY          --지시수량(연수)
                        --, ''R''                     AS OUTUNIT		--수량단위		
                        , DECODE(SUBSTR(ORDR.WRK_ORDR_NO, 1, 4), ''WOCA'', ''R'', ORDR.UNIT) AS OUTUNIT
                       -- , ORDR.UNIT                 AS OUTUNIT		--수량단위		
                        , W002.PRFM_DT                  --실적일자
                        , W002.IND_BCD                  --개별바코드
                        , W002.LOT_NO                   --LOT NO
                        , M012.PROC_CD                  --공정코드
                        , M013.PROC_NM                  --공정명
                        , W002.MACH_CD                  --설비코드
                        , M012.MACH_NM                 --설비명
                        , W002.PRFM_QTY                 --실적수량
                        , W002.UNIT AS PRFM_UNIT        --실적단위
                        , W002.PCNT                     --연수
                        , ''R''     AS RUNIT              --연수단위
                        , W002.WGT                      -- 중량
                        , ''KG''     AS WUNIT              --중량단위
                        , NVL(W002.CNL_YN, ''N'') AS CNL_YN   --취소여부  --추가
                        , W002.CNL_RMK                      --취소 사유 --추가
                        , W002.SDOC_NO                      --SAP확정번호
                        , W002.SDOC_SEQNO                   --SAP확정순번
                      FROM TB_WRK002 W002
                      LEFT JOIN V_WRK_ORDR ORDR
                      ON W002.WRK_ORDR_NO = ORDR.WRK_ORDR_NO
                      AND W002.WRK_ORDR_SEQNO = ORDR.WRK_ORDR_SEQNO
                      JOIN TB_MAS012 M012
                      ON W002.MACH_CD = M012.MACH_CD
                      LEFT JOIN TB_MAS013 M013
                      ON M012.PROC_CD = M013.PROC_CD
                     WHERE W002.WERKS = ''P100'' 
                       AND NVL(W002.CNL_YN, ''N'') = ''N'' 
                       AND NVL(W002.PRFM_GTHR_YN, ''Y'') = ''Y''';
        
        IF (V_RANGE_SQL IS NOT NULL OR TRIM(V_RANGE_SQL) != '') THEN               
            V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'K.PRFM_DT', 'W002.PRFM_DT');
            V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'PROC_CD', 'M012.PROC_CD');
            V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'IND_BCD', 'W002.IND_BCD');
            
            V_SQL := V_SQL || V_RANGE_SQL; 
        END IF;                       
        
        IF (V_MACHINE IS NOT NULL OR TRIM(V_MACHINE) != '') THEN                   --설비코드(호기)
                IF TRIM(V_MACHINE) = 'PM2' OR TRIM(V_MACHINE) = 'PM3' THEN
                    V_SQL := V_SQL || ' AND SUBSTR(W002.MATNR, 2, 1) = ''' || SUBSTR(V_MACHINE, -1) || '''';            				      
                ELSE
                    V_SQL := V_SQL || ' AND W002.MACHINE = ''' || V_MACHINE || '''';            				      
                END IF;    
            END IF;  
            
        V_SQL := V_SQL || ' ORDER BY M012.PROC_CD, W002.MACH_CD, W002.PRFM_DT, W002.IND_BCD '; 
       
       V_DEBUG := 'Y';
       
        IF (V_DEBUG = 'Y') THEN
            INSERT INTO PROC_LOG (SQL_STR) VALUES (V_SQL);
            COMMIT;
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
