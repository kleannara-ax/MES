
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_WRK31_S01" (
	P_TYPE         IN    varchar2, -- LIST, SUB_LIST-A, SUB_LIST-B
	P_JSON_STR     IN    CLOB,
	P_SUCCESS      OUT    varchar2,
	P_RS_LIST      OUT    SYS_REFCURSOR 
)
/*==============================================================================
 * PROGRAM ID    : SP_WRK31_S01{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 바코드별 실적조회 {호출 프로그램 명 기술}
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
        V_SQL := 'SELECT WRK002.WERKS
                        , MAS013.PROC_NM
                        , WRK002.MACH_CD
                        , MAS012.MACH_NM
                        , MAS012.MACHINE
                        , WRK002.LOT_NO
                        , WRK002.IND_BCD
                        , WRK002.MATNR      --자재코드	            추가
                        , MAS001.MATNR_NM   --자재명                추가
                        , WRK002.PRFM_DT    --실적일자	
                        , WRK002.WRK_CLASS  --반
                        , TO_CHAR(TO_NUMBER(SUBSTR(WRK002.MATNR, 10, 4)))   AS WLEN       --가로
                        , DECODE(TO_NUMBER(SUBSTR(WRK002.MATNR, 14, 4)), 0, 0, TO_CHAR(TO_NUMBER(SUBSTR(WRK002.MATNR, 14, 4))))   AS VLEN       --세로
                        , DECODE(MAS013.PROC_CD, ''MA'', TO_CHAR(TO_NUMBER(SUBSTR(WRK002.MATNR, 10, 4))), DECODE(WRK002.WIDTH, NULL, TO_CHAR(TO_NUMBER(SUBSTR(WRK002.MATNR, 10, 4))),WRK002.WIDTH)) AS WIDTH 
                        --, CASE WHEN WRK002.WIDTH IS NULL THEN  TO_CHAR(TO_NUMBER(SUBSTR(WRK002.MATNR, 10, 4))) ELSE WRK002.WIDTH END AS WIDTH     --지폭
                        , WRK002.WIDTH_NO   --지폭순서
                        , WRK002.CORE       --지관	
                        , FN_CD_VAL(''PACK_TYPE'', WRK002.PACKTYPE) AS PACKTYPE    --포장타입
                        , WRK002.ROLLCNT        AS PRFM_ROLLCNT  --실적권치수
                        , ''M''                 AS ROLLUNIT      --권치수 단위 (추가)
                        , WRK002.PCNT           AS PRFM_PCNT     --실적연수
                        , ''R''                 AS RUNIT         --연수 단위 (추가)
                        , WRK002.WGT            AS PRFM_WGT      --실적중량
                        , ''KG''                AS WUNIT         --중량 단위 (추가)
                        , FN_CD_VAL(''RUN_STA'',WRK002.RUN_STA) AS RUN_STA_NM        --운전상태
                        , MAS028.LOC_NM         AS LOC_NM       --로케이션명
                        , WRK002.PRD_DT         AS WRK_DATE     --작업일시
                        , (SELECT NMLAST FROM USRMA WHERE USERID = WRK002.REGID)        AS WRKNM     --작업자명
                        , DECODE(SUBSTR(WRK002.MATNR, 5, 1), ''2'',''수출'',''내수'')    AS DOMESTIC --내수/수출
                        , MAS001.PCODE      --지종코드	
                        , MAS001.PCODE_NM   --지종명	
                        , MAS001.BS_WGT     --평량	
                        , WRK002.WRK_ORDR_NO     --작업지시번호
                        , WRK002.WRK_ORDR_SEQNO  --작업지시순번
                        , MAS009.LAND1      AS NTN_NM --국가명	
                        , DECODE(SUBSTR(WRK002.IND_BCD, 6, 1), ''C'', DECODE(NVL(WRK002.TM, 0), 0, 1, 
                                   ROUND((I010_1.WGT/ TO_NUMBER(SUBSTR(I010_1.MATNR_M, 10, 4)) / 1000 * TO_NUMBER(SUBSTR(I010_1.MATNR_M, 6, 3)) *1000) / WRK002.TM)) 
                                 , 2) AS CUTTR_RSPEED  --커터선속 - 확인필요
                        , ''m/min''             AS  SPEEDUNIT    --선속단위(추가)
                        , WRK002.TM             AS RUN_TM        --가동시간
                        , WRK002.DISPO_CD
                        , MAS023.DISPO_NM       AS DISPO_CAUSE
                        , WRK002.DISPO_ROLLCNT
                        , ''M''                 AS DISPO_ROLLUNIT      --폐품 권치수단위 (추가)
                        , WRK002.DISPO_PCNT
                        , ''R''                 AS DISPO_RUNIT      --폐품 연수단위 (추가)
                        , WRK002.DISPO_WGT
                        , ''KG''                AS DISPO_WUNIT      --폐품 연수단위 (추가)
                        , MAS012A.MACHINE       AS PST_INPT_MACHINE_NM
                        , I010.MACH_CD          AS PST_INPT_MACH_CD
                        , MAS012A.MACH_NM       AS PST_INPT_MACH_NM
                        , I010.AF_ROLLCNT       AS PST_PRFM_RLCNT          --후공정 실적권치수
                        , ''M''                 AS AF_ROLLUNIT             --후공정 권치수단위 (추가)
                        , I010.AF_USE_QTY       AS PST_PRFM_PCNT           --후공정 실적연수
                        , ''R''                 AS AF_RUNIT                --후 연수단위 (추가)
                        , I010.AF_WGT           AS PST_PRFM_WGT            --후공정 중량
                        , ''KG''                AS AF_WUNIT                --후공정 중량단위 (추가)
                        , W004_A.AF_DISPO_ROLLCNT   AS PST_DISPO_RLCNT
                        , ''M''                     AS AF_DISPO_ROLLUNIT    --후공정 폐품권치수단위 (추가)
                        , W004_A.AF_DISPO_QTY       AS PST_DISPO_PCNT
                        , ''R''                     AS AF_DISPO_RUNIT       --후공정 폐품연수단위 (추가)
                        , W004_A.AF_DISPO_WGT       AS PST_DISPO_WGT
                        , ''KG''                    AS AF_DISPO_WUNIT       --후공정 중량단위 (추가)
                        , FN_CD_VAL(''STCK_STA'', I001.STCK_STA) AS STCK_STA       --재고상태(추가)
                      FROM (SELECT WERKS, MACH_CD, LOT_NO, IND_BCD, MATNR, PRFM_DT, WRK_CLASS, TO_CHAR(WIDTH) AS WIDTH, WIDTH_NO
                                , CORE, PACKTYPE, ROLLCNT, PCNT, WGT
                                , 0 AS DISPO_ROLLCNT, 0 AS DISPO_PCNT
                                , 0 AS DISPO_WGT, RUN_STA, PRD_DT, REGID, WRK_ORDR_NO, WRK_ORDR_SEQNO
                                , TM, KUNNR, CNL_YN, '''' AS DISPO_CD, PRFM_GTHR_YN
                              FROM TB_WRK002
                            UNION ALL
                            SELECT WERKS, MACH_CD, LOT_NO, IND_BCD, MATNR, PRFM_DT, WRK_CLASS, '''' AS WIDTH, '''' AS WIDTH_NO
                                , '''' AS CORE, '''' AS PACKTYPE, 0 AS ROLLCNT, 0 AS PCNT, 0 AS WGT
                                , ROLLCNT AS DISPO_ROLLCNT, CASE WHEN UNIT = ''EA'' THEN DISPO_QTY / 500 WHEN UNIT = ''R'' THEN DISPO_QTY ELSE 0 END AS DISPO_PCNT
                                , WGT AS DISPO_WGT, RUN_STA, TO_CHAR(REGDATE, ''YYYYMMDD'') AS PRD_DT, REGID, WRK_ORDR_NO, WRK_ORDR_SEQNO
                                , TM, '''' AS KUNNR, CNL_YN, DISPO_CD, ''Y'' AS PRFM_GTHR_YN
                              FROM TB_WRK004
                            )WRK002
                      INNER JOIN TB_MAS001 MAS001
                      ON WRK002.WERKS = MAS001.WERKS
                      AND WRK002.MATNR = MAS001.MATNR
                      LEFT JOIN(SELECT WERKS, MACH_CD, IND_BCD_M, UNIT
                                    , CASE WHEN UNIT = ''EA'' THEN SUM(NVL(USE_QTY, 0)) / 500 WHEN UNIT = ''R'' THEN SUM(NVL(USE_QTY, 0)) ELSE 0 END AS AF_USE_QTY
                                    , SUM(NVL(ROLLCNT, 0)) AF_ROLLCNT, SUM(NVL(WGT, 0)) AS AF_WGT
                                  FROM TB_INV010
                                 WHERE WERKS = ''P100'' 
                                   AND NVL(CNL_YN, ''N'') = ''N''
                                GROUP BY WERKS, MACH_CD, IND_BCD_M, UNIT ) I010
                      ON WRK002.WERKS = I010.WERKS
                      AND WRK002.IND_BCD = I010.IND_BCD_M
                      LEFT JOIN (SELECT WERKS, MACH_CD, IND_BCD_M, UNIT, SUM(NVL(DISPO_QTY, 0)) AS AF_DISPO_QTY, SUM(NVL(ROLLCNT, 0)) AF_DISPO_ROLLCNT, SUM(NVL(WGT, 0)) AS AF_DISPO_WGT
                                   FROM TB_WRK004
                                  WHERE WERKS = ''P100''
                                    AND NVL(CNL_YN, ''N'') = ''N''
                                 GROUP BY WERKS, MACH_CD, IND_BCD_M, UNIT) W004_A
                      ON WRK002.WERKS = W004_A.WERKS
                      AND WRK002.IND_BCD = W004_A.IND_BCD_M
                      INNER JOIN TB_MAS012 MAS012
                      ON WRK002.MACH_CD = MAS012.MACH_CD
                      INNER JOIN TB_MAS013 MAS013
                      ON MAS013.PROC_CD = MAS012.PROC_CD
                      LEFT JOIN TB_MAS009 MAS009
                      ON MAS009.CUST_CD = WRK002.KUNNR
                      AND MAS009.CUST_DIV = ''C''
                      LEFT JOIN TB_MAS023 MAS023
                      ON WRK002.WERKS = MAS023.WERKS
                      AND WRK002.DISPO_CD = MAS023.DISPO_CD
                      LEFT JOIN TB_MAS012 MAS012A
                      ON I010.MACH_CD = MAS012A.MACH_CD
                      LEFT JOIN TB_INV001 I001
                      ON WRK002.WERKS = I001.WERKS
                      AND WRK002.IND_BCD = I001.IND_BCD
                      LEFT JOIN TB_MAS028 MAS028
                      ON I001.WERKS = MAS028.WERKS
                      AND I001.STOR_LOC_CD = MAS028.STOR_LOC_CD
                      AND I001.LOC_CD = MAS028.LOC_CD
                      INNER JOIN (SELECT WERKS, IND_BCD, MATNR_M, SUM(WGT) AS WGT 
                                    FROM TB_INV010
                                  GROUP BY WERKS, IND_BCD, MATNR_M)  I010_1
                      ON WRK002.WERKS = I010_1.WERKS
                      AND WRK002.IND_BCD = I010_1.IND_BCD
                     WHERE WRK002.WERKS = ''P100'' 
                       AND NVL(WRK002.PRFM_GTHR_YN, ''Y'') = ''Y''
                       AND NVL(WRK002.CNL_YN, ''N'') = ''N'' ';

        IF  V_RANGE_SQL IS NOT NULL OR TRIM(V_RANGE_SQL) != '' THEN
            V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'PRFM_DT','WRK002.PRFM_DT');
            V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'PROC_CD','MAS013.PROC_CD');
            V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'PCODE','MAS001.PCODE');
            V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'VLEN','TO_CHAR(TO_NUMBER(SUBSTR(WRK002.MATNR, 14, 4)))');
            V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'WLEN','TO_CHAR(TO_NUMBER(SUBSTR(WRK002.MATNR, 10, 4)))');
            V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'NTN_NM','MAS009.LAND1');
            V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'BS_WGT','MAS001.BS_WGT');
            V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'IND_BCD','WRK002.IND_BCD');
            V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'LOT_NO','WRK002.LOT_NO');

            V_SQL := V_SQL || V_RANGE_SQL ;			        
        END IF;
        
        IF (V_MACHINE IS NOT NULL OR TRIM(V_MACHINE) != '') THEN                   --설비코드(호기)
            V_SQL := V_SQL || ' AND MAS012.MACHINE = ''' || V_MACHINE || '''';            				      
        END IF;  
            
        V_SQL := V_SQL || ' ORDER BY WRK002.MACH_CD, WRK002.IND_BCD ' ;	
        
        V_DEBUG := 'Y';
        IF (V_DEBUG = 'Y') THEN
            INSERT INTO PROC_LOG(SQL_STR) VALUES (V_SQL);
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
	    P_SUCCESS           := 'N';
        E_SQL_ERR_CD        := SQLCODE;
        E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

        ROLLBACK;
        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
END;
/
