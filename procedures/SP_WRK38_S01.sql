
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_WRK38_S01" (
	P_TYPE         IN    varchar2, -- LIST, SUB_LIST-A, SUB_LIST-B
	P_JSON_STR     IN    CLOB,
	P_SUCCESS      OUT    varchar2,
	P_RS_LIST      OUT    SYS_REFCURSOR 
)
/*==============================================================================
 * PROGRAM ID    : SP_WRK38_S01{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 창고 재고 현황(PS) {호출 프로그램 명 기술}
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 창고재고현황조회 {프로그램에 대한 상세한 내용 기술}
 *                 
 * AUTHOR NAME   : 안상현{최초 작성자 명 기술}
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
 * yyyy/mm/dd    1.0.0   박성철         Initial Version 
 *==============================================================================
 *  관련 테이블
 *=============================================================================*/

AS

    V_PRG_NM          VARCHAR2(100)  := 'SP_WRK38_S01';     -- PROCEDURE NAME

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
   V_PCODE          TB_MAS001.PCODE%TYPE;       --지종코드 
   V_BS_WGT         TB_MAS001.BS_WGT%TYPE;      --평량 
   V_WIDTHW         TB_WRK002.WLEN%TYPE;        --가로 
   V_WIDTHH         TB_WRK002.VLEN%TYPE;        --세로 
   V_MATNR        TB_INV001.MATNR%TYPE;     --자재 
   V_STOR_LOC_CD        TB_INV001.STOR_LOC_CD%TYPE;     --자재 
   V_LOC_CD         VARCHAR(20);  

    -- 리스트(그리드)의 값을 할당하기 위한 변수선언 영역

BEGIN
    OPEN P_RS_LIST FOR 

    SELECT NULL FROM DUAL WHERE ROWNUM = 0;

    V_DEBUG := 'Y';
    V_RUN_SQL := 'Y';

    V_JSON := JSON_OBJECT_T.parse(P_JSON_STR);

    V_SESS_USER_ID       :=      V_JSON.get_string('SES_USER_ID');
    V_PLT_CD             :=      V_JSON.get_string('SES_PLNTKY');

   /* 조건값 할당 */
   V_RANGE_SQL 		    :=       V_JSON.get_string('RANGE_SQL');   	--작업지시번호, 작업지시번호 순번

--   V_PROC_NM   		:=       V_JSON.get_string('PROC_NM');	    --공정명  
   --V_PCODE          :=       V_JSON.get_string('PCODE');      	--지종코드 
   V_STOR_LOC_CD          :=       V_JSON.get_string('STOR_LOC_CD');      	--저장위치코드 
--   V_BS_WGT 	    :=       V_JSON.get_string('BS_WGT');   	--평량   
--   V_WIDTHW  		:=       V_JSON.get_string('WIDTHW');		--가로   
--   V_WIDTHH  		:=       V_JSON.get_string('WIDTHH'); 		--세로  
   V_MATNR  		:=       V_JSON.get_string('MATNR'); 		--자재     
   V_LOC_CD         :=       V_JSON.get_string('LOC_CD'); 		

   IF P_TYPE = 'LIST' THEN /*상단 조회 리스트*/

   		V_SQL := 'SELECT I001.WERKS       
                    , I001.MATNR            --자재코드
                    , M001.MATNR_NM         --자재명
                    , I001.LOT_NO           --LOT NO
                    , I001.IND_BCD          --개별바코드
                    , W002.PRD_NO       AS PRD_NO          --생산번호
                    , I001.STOR_LOC_CD      --저장위치
                    , M003.STOR_LOC_NM  AS STOR_LOC_CD_NM  --저장위치명
                    , I001.LOC_CD           --로케이션
                    , M028.LOC_NM       AS LOC_CD_NM       --로케이션명
                    --, I001.STCK_QTY + I003.STCK_QTY AS STCK_QTY     -- 재고량
                    , I001.STCK_QTY                                 -- 재고량
                    , I001.UNIT  AS STCKUNIT                        --재고단위
                    , I001.ROLLCNT      AS ROLLCNT                  --권치수
                    , ''M''               AS ROLLUNIT                 --권치수단위
                    --, I001.WGT          AS WGT                      --중량
                    , CASE WHEN I001.UNIT = ''R'' THEN TO_NUMBER(SUBSTR(I001.MATNR, 10, 4)) / 1000 * TO_NUMBER(SUBSTR(I001.MATNR, 14, 4)) / 1000 * TO_NUMBER(SUBSTR(I001.MATNR, 6, 3)) / 1000 * (I001.STCK_QTY * 500)
                           WHEN I001.UNIT = ''EA'' THEN TO_NUMBER(SUBSTR(I001.MATNR, 10, 4)) / 1000 * TO_NUMBER(SUBSTR(I001.MATNR, 14, 4)) / 1000 * TO_NUMBER(SUBSTR(I001.MATNR, 6, 3)) / 1000 * I001.STCK_QTY
                           ELSE I001.WGT END          AS WGT                      --중량
                    , ''KG''              AS WUNIT                    --중량단위
                    , DECODE(SUBSTR(I001.MATNR, 5, 1), ''2'', ''수출'', ''내수'') AS DOMESTIC     --내수구분
                    , M001.PCODE                                    --지종
                    , M001.PCODE_NM                                 --지종명
                    , M001.BS_WGT                                   --평량
                    , TO_NUMBER(SUBSTR(I001.MATNR, 10, 4)) AS WLEN     --가로길이
                    , CASE
                           WHEN NVL(I001.IN_MR_YN, ''N'') = ''N'' THEN
                               CASE
                                   WHEN (SELECT COUNT(*)
                                         FROM TB_SCH017
                                         WHERE PRE_ORDER_NO = I001.ORDER_NO
                                           AND USE_YN = ''Y'') > 0
                                       THEN
                                       (SELECT TO_NUMBER(SUBSTR(S017.MATNR, 14, 4))
                                        FROM TB_SCH017 S017
                                        WHERE S017.PRE_ORDER_NO = I001.ORDER_NO
                                          AND S017.USE_YN = ''Y''
                                          AND ROWNUM = 1)
                                   ELSE
                                       TO_NUMBER(SUBSTR(I001.MATNR, 14, 4))
                                   END
                           ELSE
                               CASE
                                   WHEN (SELECT COUNT(*)
                                         FROM TB_SCH017
                                         WHERE PRE_ORDER_NO = I001.LOT_NO
                                           AND USE_YN = ''Y'') > 0
                                       THEN
                                       (SELECT TO_NUMBER(SUBSTR(S017.MATNR, 14, 4))
                                        FROM TB_SCH017 S017
                                        WHERE S017.PRE_ORDER_NO = I001.LOT_NO
                                          AND S017.USE_YN = ''Y'')
                                   ELSE
                                       TO_NUMBER(SUBSTR(I001.MATNR, 14, 4))
                                   END
                    END  VLEN
                    , TO_NUMBER(SUBSTR(I001.MATNR, 10, 4)) AS O_WIDTH  --(지시)실지폭
                    , TO_NUMBER(NVL(W002.WIDTH, ''0''))    AS P_WIDTH   --(생산)실지폭    
                    , CASE WHEN SUBSTR(I001.MATNR, -1) IN (''A'', ''B'') THEN FN_CD_VAL(''PACK_TYPE'', SUBSTR(I001.MATNR, -1))
                           ELSE NULL END                            AS PACKTYPE        --포장방식
                    --, FN_CD_VAL(''PACK_TYPE'', ORDR.PACKTYPE)                 AS PACKTYPE        --포장방식
                    , I001.PRD_DT                                   --생산일자
                    , I001.PRFM_DT                                  --실적일자
                    , I001.REGDATE                                  --창고입고일시
                    , FN_CD_VAL(''STCK_STA'', I001.STCK_STA) AS STCK_STA    --재고상태
                    , I001.MACH_CD                                  --설비코드
                    , M012.MACH_NM                                  --설비명
                    , W002.VBELN                                    --판매문서번호
                    , W002.POSNR                                    --판매문서번호 품목
                    , M009.CUST_NM AS KUNNR_NM                      --거래처명
                    , FN_CD_VAL(''NTN_CD'', M009.LAND1)  AS NTN_NM                         --국가명
                    , (SELECT NMLAST FROM USRMA WHERE USERID = I001.REGID) AS WRKNM     --작업자
                  FROM TB_INV001 I001
--                  LEFT JOIN TB_INV003 I003
--                  ON I001.WERKS = I003.WERKS
--                  AND I001.IND_BCD = I003.IND_BCD
                  LEFT JOIN TB_WRK002 W002
                  ON I001.WERKS = W002.WERKS
                  AND I001.IND_BCD = W002.IND_BCD
                  JOIN TB_MAS001 M001
                  ON I001.WERKS = M001.WERKS
                  AND I001.MATNR = M001.MATNR
                  LEFT JOIN TB_MAS012 M012
                  ON I001.MACH_CD = M012.MACH_CD
                  LEFT JOIN TB_MAS009 M009
                  --ON I001.KUNNR = M009.CUST_CD
                  ON SUBSTR(W002.KUNNR, -6) = M009.CUST_CD
                  AND M009.CUST_DIV = ''C''
                  LEFT JOIN TB_MAS003 M003
                  ON I001.WERKS = M003.WERKS
                  AND I001.STOR_LOC_CD = M003.STOR_LOC_CD
                  LEFT JOIN TB_MAS028 M028
                  ON I001.WERKS = M028.WERKS
                  AND I001.STOR_LOC_CD = M028.STOR_LOC_CD
                  AND I001.LOC_CD = M028.LOC_CD
                  LEFT JOIN V_WRK_ORDR ORDR
                  ON I001.WRK_ORDR_NO = ORDR.WRK_ORDR_NO
                  AND I001.WRK_ORDR_SEQNO = ORDR.WRK_ORDR_SEQNO
                 WHERE I001.WERKS = ''P100'' 
                   AND NVL(I001.DLFL, ''N'') = ''N''
                   AND I001.STCK_QTY > 0';

        IF  V_RANGE_SQL IS NOT NULL OR TRIM(V_RANGE_SQL) != '' THEN
            V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'WRHS_RCV_DATE', 'TO_CHAR(I001.REGDATE,''YYYYMMDD'')');        -- 창고입고일시
            V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'MATNR', 'I001.MATNR');                     -- 자재코드
            V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'STOR_LOC_CD', 'I001.STOR_LOC_CD');         --저장위치
            V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'LOC_CD', 'I001.LOC_CD');                   --로케이션
            V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'I001.STOR_I001.LOC_CD', 'I001.STOR_LOC_CD');                   --저장위치 다시 변경 (2023-04-05 백우종 추가)
            V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'MACH_CD', 'I001.MACH_CD');                 --설비코드
            V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'IND_BCD', 'I001.IND_BCD');                 --개별바코드
            V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'PCODE', 'M001.PCODE');                     --지종코드
            V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'BS_WGT', 'M001.BS_WGT');                   --평량
            V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'MACHINE', 'M012.MACHINE');                 --생산호기
            V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'WIDTH', 'TO_NUMBER(SUBSTR(I001.MATNR, 10, 4))');      --지폭
            
            V_SQL := V_SQL || V_RANGE_SQL ;			        
        END IF;
        
        V_SQL := V_SQL || ' ORDER BY I001.STOR_LOC_CD, I001.LOC_CD, I001.LOT_NO, I001.IND_BCD';  

    		V_DEBUG :='Y';
        IF (V_DEBUG = 'Y') THEN
            INSERT INTO PROC_LOG(SQL_STR, SQL_PARAM1) VALUES (V_SQL, 'WRK38_S01');
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
