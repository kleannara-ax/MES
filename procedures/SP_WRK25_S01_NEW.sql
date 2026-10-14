
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
		V_SQL := 'SELECT /*+ PK_TB_SCH015 */                                  
                     ORDR.JWRK_ORDR_NO          AS JWRK_ORDR_NO         --JR작업지시번호(추가)
                    , ORDR.JWRK_ORDR_SEQNO      AS JWRK_ORDR_SEQNO      --JR작업지시번호순번(추가)
                    , W002_J.LOT_NO            AS JJOB_IND_BCD         --JRLOT
                    , SUBSTR(W002_J.MATNR, 3,3) AS PCODE
                    , ORDR.PRDTYPETXT                                   --생산라인구분
                    , ORDR.JROLLCNT             AS JPLNROLLCNT          --JR계획권치수
                    , W002_J.ROLLCNT            AS JROLLCNT             --JR실적권치수
                    , ''M''                       AS JROLLUNIT            --JR권치수단위    
                    , W002_M.LOT_NO             AS MJOB_IND_BCD         --MRLOT
                    , ORDR.MWRK_ORDR_NO         AS MJOB_WRK_ORDR_NO     --MR작업지시번호
                    , ORDR.MWRK_ORDR_SEQNO      AS MJOB_WRK_ORDR_SEQNO  --MR작업지시번호순번
                    , ORDR.VBELN
                    , ORDR.MATNR_MR             AS MATNR                --SD자재번호 -> 자재코드(변경)
                    , ORDR.VDATU                AS VDATU                --납품요청일
                    , SUBSTR(ORDR.MATNR_MR, 6, 3)  AS BS_WGT            --평량
                    , ORDR.WLEN                 AS CT_WGT               --CT지폭
                    , SUBSTR(ORDR.MATNR_MR, 10, 4)  AS MWIDTH           --MR지폭
                    , ORDR.MRCNT        AS MRCNT                        --폭수  --> PKCNT(폭수) --> MRCNT(MR폭수) 로 변경
                    , ORDR.SLITER       AS SLITER                       --슬리터  --> ZCOR(슬리터) --> SLITER(슬리터 여부) 로 변경
                    , (SELECT COUNT(ORDER_NO) FROM TB_SCH016 WHERE PRE_ORDER_NO = ORDR.MORDER_NO AND USE_YN = ''Y'')   AS CUTTER   --슬리터 개수  
                    , ORDR.MROLLCNT     AS MPLNROLLCNT                  --MR계획권치수
                    , W002_M.ROLLCNT    AS MROLLCNT                     --MR실적권치수
                    , W002_M.PRFM_QTY   AS MRWGT                        --MR중량  -> MBRGEW(MR중량) --> MRWGT(MR 실적중량)으로 변경
                    , ''KG''              AS MRWUNIT                      --MR중량단위 (추가)
                    , DECODE(TO_CHAR(ORDR.WLEN), NULL, NULL, TO_CHAR(ORDR.WLEN) || ''*'' || TO_CHAR(ORDR.WLEN))   AS CSPEC    --규격
                    , ORDR.PLT_PER_CNT  AS CPLT_PER_CNT                 --연수(팔레트당연수) --> CT계획팔레트당연수(컬럼명 변경)
--                    , (SELECT PCNT
--                         FROM(SELECT ORDER_NO, PCNT, COUNT(PCNT)
--                                FROM TB_WRK002
--                               WHERE WERKS = ''P100''
--                                 AND MACH_CD IN (SELECT MACH_CD FROM TB_MAS012 WHERE PROC_CD = ''CA'')
--                                 AND ORDER_NO = ORDR.CORDER_NO
--                              GROUP BY ORDER_NO, PCNT 
--                              ORDER BY COUNT(PCNT)DESC)
--                        WHERE ROWNUM = 1) AS CP_CNT                   --연수(팔레트당연수)1 --> CT실적팔레트당연수(컬럼명 변경)
                    , W002_C2.PCNT     AS CP_CNT 
                    , ''R''               AS CPLUNIT                     --CT연수단위(추가)
--                    , (SELECT COUNT(IND_BCD) 
--                         FROM TB_WRK002
--                        WHERE WERKS = ''P100''
--                          AND MACH_CD IN (SELECT MACH_CD FROM TB_MAS012 WHERE PROC_CD = ''CA'')
--                          AND ORDER_NO = ORDR.CORDER_NO
--                          AND NVL(CNL_YN, ''N'') = ''N''
--                       GROUP BY ORDER_NO)  AS CPLT_CNT                 --팔레트 수 --> PPLT_CNT(팔레트수) -CPLT_CNT(CT팔레트수) 변경
                    , W002_C1.CPLT_CNT    AS CPLT_CNT
                    , ''EA''                AS CPLTUNIT     -- CT팔레트수 단위(추가)
                    , ORDR.MKUNNR        AS PKUNNR           --판매처
                    , M009.CUST_NM      AS PKUNNR_NM        --판매처명
                    , ORDR.WRK_ORDR_QTY     AS PPLANQTY     --포장계획연수(추가)
--                    , (SELECT SUM(PRFM_QTY) 
--                         FROM TB_WRK002
--                        WHERE WERKS = ''P100''
--                          AND MACH_CD IN (SELECT MACH_CD FROM TB_MAS012 WHERE PROC_CD IN (''PB'', ''PC'', ''ZA''))
--                          AND ORDER_NO = ORDR.PORDER_NO
--                          AND NVL(CNL_YN, ''N'') = ''N''
--                       GROUP BY ORDER_NO)   PPRD_QTY          --포장실적연수(추가)
                    , W002_P.PPRD_QTY   AS PPRD_QTY  
                    , ''R''               AS PPRUNIT          --포장연수단위(추가)
                    , CASE WHEN ORDR.PACKTYPE IS NULL THEN NULL ELSE FN_CD_VAL(''PACK_TYPE'', ORDR.PACKTYPE) END  AS PPACKTYPE      --포장타입
                    , DECODE(ORDR.SHEET, ''X'', ''SHEET'', ''ROLL'') AS MSHEET          --Roll/Sheet
                    , ORDR.ORDER_RMK    AS PORDER_RMK      --비고
                  FROM( 
                        SELECT S015.ORDER_NO AS JORDER_NO, S015.WRK_ORDR_NO AS JWRK_ORDR_NO, S015.WRK_ORDR_SEQNO AS JWRK_ORDR_SEQNO
                            , S015.PRDTYPETXT, S015.JROLLCNT, S015.PRD_REQ_DT   										
                            , S016.ORDER_NO AS MORDER_NO, S016.WRK_ORDR_NO AS MWRK_ORDR_NO, S016.WRK_ORDR_SEQNO AS MWRK_ORDR_SEQNO
                            , S016.VBELN, S016.MATNR AS MATNR_MR, S016.VDATU, S016.MROLLCNT, S016.SLITER, S016.MRCNT, S016.SHEET
                            , S016.KUNNR AS MKUNNR
                            , S017.ORDER_NO AS CORDER_NO, S017.WRK_ORDR_NO AS CWRK_ORDR_NO, S017.WRK_ORDR_SEQNO AS CWRK_ORDR_SEQNO
                            , S017.WLEN, S017.VLEN, S017.PLT_PER_CNT, S017.WRK_ORDR_QTY AS CORDER_QTY
                            , S018.ORDER_NO AS PORDER_NO, S018.WRK_ORDR_NO AS PWRK_ORDR_NO, S018.WRK_ORDR_SEQNO AS PWRK_ORDR_SEQNO
                            , S018.PACKTYPE, S018.KUNNR AS PKUNNR, S018.WRK_ORDR_QTY, S018.ORDER_RMK
                          FROM TB_SCH015 S015
                          LEFT JOIN TB_SCH016 S016
                          ON S015.ORDER_NO = S016.PRE_ORDER_NO
                          LEFT JOIN TB_SCH017 S017
                          ON S016.ORDER_NO = S017.PRE_ORDER_NO
                          LEFT JOIN TB_SCH009 S009
                          ON S017.ORDER_NO = S009.FRAUFNR
                          LEFT JOIN TB_SCH018 S018
                          ON S009.AUFNR = S018.ORDER_NO
                         WHERE 1=1 ';
        IF (V_RANGE_SQL IS NOT NULL OR TRIM(V_RANGE_SQL) != '') THEN                --생산요청일자
            V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'SCH015', 'S015');

            V_SQL := V_SQL || V_RANGE_SQL; 
        END IF;   

        IF (V_MACHINE IS NOT NULL OR TRIM(V_MACHINE) != '') THEN                    --설비코드(호기)
            V_SQL := V_SQL || ' AND S015.MACHINE = ''' || V_MACHINE || '''';            				      
        END IF;          

        V_SQL := V_SQL || ' AND S015.USE_YN = ''Y''
                         ORDER BY JORDER_NO
                        ) ORDR   
                        LEFT JOIN TB_WRK002 W002_J
                        ON ORDR.JWRK_ORDR_NO = W002_J.WRK_ORDR_NO
                        AND ORDR.JWRK_ORDR_SEQNO= W002_J.WRK_ORDR_SEQNO 
                        LEFT JOIN TB_WRK002 W002_M
                        ON ORDR.MWRK_ORDR_NO = W002_M.WRK_ORDR_NO
                        AND ORDR.MWRK_ORDR_SEQNO= W002_M.WRK_ORDR_SEQNO 
                        LEFT JOIN TB_MAS009 M009
                        ON ORDR.MKUNNR = M009.CUST_CD
                        AND M009.CUST_DIV = ''C''
                        LEFT JOIN(SELECT ORDER_NO, SUM(PRFM_QTY) PPRD_QTY
                                     FROM TB_WRK002
                                    WHERE WERKS = ''P100''
                                      AND MACH_CD IN (SELECT MACH_CD FROM TB_MAS012 WHERE PROC_CD IN (''PB'', ''PC'', ''ZA''))
                                      AND NVL(CNL_YN, ''N'') = ''N''
                                   GROUP BY ORDER_NO) W002_P           
                        ON ORDR.PORDER_NO = W002_P.ORDER_NO       
                        LEFT JOIN (SELECT ORDER_NO, COUNT(IND_BCD) CPLT_CNT
                                     FROM TB_WRK002
                                    WHERE WERKS = ''P100''
                                      AND MACH_CD IN (SELECT MACH_CD FROM TB_MAS012 WHERE PROC_CD = ''CA'')
                                      AND NVL(CNL_YN, ''N'') = ''N''
                                   GROUP BY ORDER_NO)  W002_C1
                        ON ORDR.CORDER_NO = W002_C1.ORDER_NO  
                        LEFT JOIN(SELECT A.ORDER_NO, A.PCNT
                                     FROM(SELECT ORDER_NO, PCNT, COUNT(PCNT) CNT
                                                ,DENSE_RANK() OVER ( PARTITION BY  ORDER_NO ORDER BY ORDER_NO ASC,  COUNT(PCNT) DESC ) AS RANKS
                                            FROM TB_WRK002
                                           WHERE WERKS = ''P100''
                                             AND MACH_CD IN (SELECT MACH_CD FROM TB_MAS012 WHERE PROC_CD = ''CA'')
                                          GROUP BY ORDER_NO, PCNT
                                          ) A
                                   WHERE A.RANKS = 1) W002_C2
                        ON ORDR.CORDER_NO = W002_C2.ORDER_NO     
                ORDER BY ORDR.JWRK_ORDR_NO ';       

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

		ROLLBACK;
		RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
END;
/
