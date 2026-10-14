--------------------------------------------------------
--  DDL for Procedure SP_QLT05_S01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_QLT05_S01" (
	P_TYPE           IN    varchar2, -- LIST, SUB_LIST, SUB_SAVE
	P_JSON_STR       IN    CLOB,
    P_DOC_NO1       OUT    varchar2, 
    P_DOC_NO2       OUT    varchar2, 
	P_SUCCESS       OUT    varchar2,
	P_RS_LIST       OUT    SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : QLT05{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 품질검사(HL 완제품 검사)등록{호출 프로그램 명 기술}
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 품질검사(HL 완제품 검사)결과값을 관리한다.{프로그램에 대한 상세한 내용 기술}
 *                 
 * AUTHOR NAME   : 김성하{최초 작성자 명 기술}
 * CREATE DATE   : 2022/05/03 {최초 작성일자 기술}
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
 *       - [CMCDV]      : (.R..) 공통코드
 *       - [USRMA]      : (.R..) 사용자 정보               
 *       - [TB_MAS001]  : (.R..) 자재 마스트                              
 *       - [TB_MAS009]  : (.R..) 거래처 정보                              
 *       - [TB_MAS015]  : (.R..) 검사항목별 기준정보 등록 마스트                              
 *       - [TB_MAS016]  : (.R..) 검사항목별 기준값 정보                                
 *       - [TB_QLT001]  : (.RU.) HL 완제품 검사(물성)검사 대상정보(WMS->MES)                                
 *       - [TB_QLT020]  : (CRUD) 검사항목별 판정결과 등록 마스트                              
 *       - [TB_QLT021]  : (CRUD) 검사항목별 판정결과 정보                                
 *       - [TB_QLT022]  : (CRUD) 검사항목별 판정결과 세부정보
 *       - [TB_QLT023]  : (C...) 검사항목별 판정결과 변경이력
 *       - [TB_QLT024]  : (C...) 부적합 발생이력
 *       - [TB_IFS009]  : (C...) 품질검사(HL 완제품 결과)(MES -> SAP) 
 *=============================================================================*/

AS

    V_PRG_NM          VARCHAR2(100)  := 'SP_QLT05_S01';     -- PROCEDURE NAME

    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5)           := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);


   -- V_RTN_CLOB       CLOB;
   -- V_RTN_CURSOR     SYS_REFCURSOR;
   -- V_ERROR          CLOB;


    -- JSON을 위한 변수선언 영역
    V_JSON           JSON_OBJECT_T;

    V_OBJ_HEAD       JSON_OBJECT_T;
    V_OBJ_LIST       JSON_OBJECT_T;

    V_OBJ_HEAD_H     JSON_OBJECT_T;
    V_OBJ_LIST_L     JSON_OBJECT_T;

    V_ARR_HEAD       JSON_ARRAY_T;
    V_ARR_LIST       JSON_ARRAY_T;


    -- 세션값 처리용 변수선언 영역
    V_SQL            CLOB;
    V_RUN_SQL        varchar2(1);
    V_RANGE_SQL      varchar2(4000);
    V_DEBUG          varchar2(1);

    -- 세션값 처리용 변수선언 영역
    V_PLT_CD         varchar2(2);
    V_SESS_USER_ID   varchar2(20);

    -- 조건절 처리용 변수선언 영역
    V_WERKS            TB_MAS015.WERKS%TYPE; -- 플랜트코드
    V_MATNR_NM         TB_MAS001.MATNR_NM%TYPE; -- 자재명
    V_MATNR_GRP_CD     TB_MAS001.MATNR_GRP_CD%TYPE; -- 자재그룹
    V_INSP_YN          VARCHAR2(1);          -- 등록여부

    -- 리스트(그리드)의 값을 할당하기 위한 변수선언 영역        
    V_INSP_ITEM_GRP_CD TB_MAS015.INSP_ITEM_GRP_CD%TYPE; 
    V_INSP_ITEM_CD     TB_MAS016.INSP_ITEM_CD%TYPE;

    V_STD_VAL          TB_MAS016.STD_VAL%TYPE;
    V_UPP_VAL          TB_MAS016.UPP_VAL%TYPE;
    V_LOW_VAL          TB_MAS016.LOW_VAL%TYPE;
    V_STD_SEL          TB_MAS016.STD_SEL%TYPE;
    V_INSP_STD_1       TB_MAS016.INSP_STD_1%TYPE;
    V_INSP_STD_2       TB_MAS016.INSP_STD_2%TYPE;

    V_MACH_CD          TB_WRK001.MACH_CD%TYPE;
    V_IND_BCD          TB_WRK001.IND_BCD%TYPE;
    V_LOT_NO           TB_WRK001.LOT_NO%TYPE;
    V_MATNR            TB_WRK001.MATNR%TYPE;
    V_ORDER_NO         TB_WRK001.ORDER_NO%TYPE;
    V_ORDER_SEQNO      TB_WRK001.ORDER_NO%TYPE;
    V_WRK_ORDR_NO      TB_WRK001.WRK_ORDR_NO%TYPE;
    V_WRK_ORDR_SEQNO   TB_WRK001.WRK_ORDR_SEQNO%TYPE;
    V_UNIT             TB_WRK001.UNIT%TYPE;
    V_PRFM_DT          TB_WRK001.PRFM_DT%TYPE;

    V_MSRM_DATE        TB_QLT020.MSRM_DATE%TYPE;
    V_MSRM_DT          VARCHAR2(21) := '';
    V_NEW_MSRM_DT      VARCHAR2(21) := '';

    V_MSRM_ID          TB_QLT020.MSRM_ID%TYPE;
    V_SMPL_AMT         TB_QLT020.SMPL_AMT%TYPE;
    V_UCFMTY_AMT       TB_QLT020.UCFMTY_AMT%TYPE;
    V_FNL_JDGM         TB_QLT020.FNL_JDGM%TYPE;
    V_VND_LOT_NO       TB_QLT020.VND_LOT_NO%TYPE;
    V_SUPY_VND_BCD     TB_QLT020.SUPY_VND_BCD%TYPE;
    V_VGBEL            TB_QLT020.VGBEL%TYPE;
    V_VGPOS            TB_QLT020.VGPOS%TYPE;
    V_REQ_DIV          TB_QLT020.REQ_DIV%TYPE;

    V_DOC_NO           TB_QLT020.DOC_NO%TYPE;
    V_DOC_SEQNO        TB_QLT020.DOC_SEQNO%TYPE;
    V_DOC_NO_1         TB_QLT020.DOC_NO%TYPE;
    V_DOC_SEQNO_1      TB_QLT020.DOC_SEQNO%TYPE;
    V_DOC_NO_2         TB_QLT020.DOC_NO%TYPE;
    V_DOC_SEQNO_2      TB_QLT020.DOC_SEQNO%TYPE;

    V_DOC_NEW_NO_1     TB_QLT020.DOC_NO%TYPE;
    V_DOC_NEW_SEQNO_1  TB_QLT020.DOC_SEQNO%TYPE;
    V_DOC_NEW_NO_2     TB_QLT020.DOC_NO%TYPE;
    V_DOC_NEW_SEQNO_2  TB_QLT020.DOC_SEQNO%TYPE;

    V_PRC_DIV          TB_QLT020.PRC_DIV%TYPE;

    V_PRC_SEQNO        TB_QLT021.PRC_SEQNO%TYPE;
    V_RST_VAL          TB_QLT021.RST_VAL%TYPE;
    V_RST_SEL          TB_QLT021.RST_SEL%TYPE;
    V_RST_TXT          TB_QLT021.RST_TXT%TYPE;
    V_RMK              TB_QLT021.RMK%TYPE;
    V_FIT_YN           TB_QLT021.FIT_YN%TYPE;
    V_INSP_REP_YN      TB_QLT021.INSP_REP_YN%TYPE;
    V_UUID             TB_QLT021.UUID%TYPE;

    V_BEF_RST_VAL      TB_QLT023.BEF_RST_VAL%TYPE;
    V_BEF_RST_SEL      TB_QLT023.BEF_RST_SEL%TYPE;
    V_BEF_RST_TXT      TB_QLT023.BEF_RST_TXT%TYPE;
    V_BEF_RMK          TB_QLT023.BEF_RMK%TYPE;
    V_BEF_FIT_YN       TB_QLT023.BEF_FIT_YN%TYPE;
    V_BEF_INSP_REP_YN  TB_QLT023.BEF_INSP_REP_YN%TYPE;
    V_BEF_UUID         TB_QLT023.BEF_UUID%TYPE;
    V_AFT_RST_VAL      TB_QLT023.AFT_RST_VAL%TYPE;
    V_AFT_RST_SEL      TB_QLT023.AFT_RST_SEL%TYPE;
    V_AFT_RST_TXT      TB_QLT023.AFT_RST_TXT%TYPE;
    V_AFT_RMK          TB_QLT023.AFT_RMK%TYPE;
    V_AFT_FIT_YN       TB_QLT023.AFT_FIT_YN%TYPE;
    V_AFT_INSP_REP_YN  TB_QLT023.AFT_INSP_REP_YN%TYPE;
    V_AFT_UUID         TB_QLT023.AFT_UUID%TYPE;

    V_PRC_MTD          TB_QLT024.PRC_MTD%TYPE;

    V_STCK_STA         TB_INV001.STCK_STA%TYPE;
    V_STOR_LOC_CD      TB_INV001.STOR_LOC_CD%TYPE;
    V_PLT_QTY          TB_INV001.PLT_QTY%TYPE;
    V_BOX_QTY          TB_INV001.BOX_QTY%TYPE;
    V_BAG_QTY          TB_INV001.BAG_QTY%TYPE;
    V_EA_QTY           TB_INV001.EA_QTY%TYPE;
    V_STCK_QTY         TB_INV001.STCK_QTY%TYPE;
    V_WGT              TB_INV001.WGT%TYPE;

    V_MATNR_DIV        TB_MAS001.MATNR_DIV%TYPE;

    V_LGORT_FROM       TB_IFS009.LGORT_FROM%TYPE;   --저장위치(From)
    V_LGORT_TO         TB_IFS009.LGORT_TO%TYPE;     --저장위치(To)


    V_QTY              TB_IFSWM001.QTY%TYPE;              
    V_STCK_KY          TB_IFSWM001.STOK_KY%TYPE;
    V_LOT_NUM          TB_IFSWM001.LOT_NUM%TYPE;
    V_BADRSNNM         TB_IFSWM001.BADRSNNM%TYPE;

    V_DLFL                      TB_WRK015.DLFL%TYPE;          --
    V_STOR_LOC_FR               TB_WRK015.STOR_LOC_FR%TYPE;   --
    V_STOR_LOC_TO               TB_WRK015.STOR_LOC_TO%TYPE;   --
    V_MACHINE                   TB_WRK015.MACHINE%TYPE;       --
    V_PCODE                     TB_WRK015.PCODE%TYPE;         --
    V_BS_WGT                    TB_WRK015.BS_WGT%TYPE;        --
    V_WLEN                      TB_WRK015.WLEN%TYPE;          --
    V_VLEN                      TB_WRK015.VLEN%TYPE;          --
    V_CON_TYPE                  TB_WRK015.CON_TYPE%TYPE;      --
    V_PACKTYPE                  TB_WRK015.PACKTYPE%TYPE;      --
    V_VBELN                     TB_WRK015.VBELN%TYPE;         --
    V_POSNR                     TB_WRK015.POSNR%TYPE;         --
    V_SAUART                    TB_WRK015.SAUART%TYPE;        --
    V_KUNNR                     TB_WRK015.KUNNR%TYPE;         --
    V_CORE                      TB_WRK015.CORE%TYPE;          --
    V_EMPLY_NO                  TB_WRK015.EMPLY_NO%TYPE;      --
    V_EMPLY_NM                  TB_WRK015.EMPLY_NM%TYPE;      --
    V_NTN_CD                    TB_WRK015.NTN_CD%TYPE;        --
    V_PRDC_DT                    TB_WRK015.PRD_DT%TYPE;        --
    V_RCVGDS_DT                 TB_WRK015.RCVGDS_DT%TYPE;     --
    V_DSTBT_DDLIN               TB_WRK015.DSTBT_DDLIN%TYPE;   --
    V_STCK_NO                   TB_WRK015.STCK_NO%TYPE;       --

    --기타처리
    V_Q020_CNT         NUMBER   := 0;
    V_Q024_CNT         NUMBER   := 0;
    V_Q026_CNT         NUMBER   := 0;
    V_CHG_ACC          NUMBER   := 0;
    V_UCFMTY_YN        CHAR     := 'N';
   
   --2022-10-30(일요일) 안상현, 처리순번 변수
  	V_AN_SEQNO			NUMBER := 0;
  
  	--2022-10-30(일요일) 안상현, 검사일시 변수
  	V_AN_MSRM_DT      	VARCHAR2(21) := '';

BEGIN
   OPEN P_RS_LIST FOR 
   SELECT NULL FROM DUAL WHERE ROWNUM = 0;

   V_DEBUG := 'N';
   V_RUN_SQL := 'Y';

   V_JSON := JSON_OBJECT_T.parse(P_JSON_STR);

   V_SESS_USER_ID       :=       V_JSON.get_string('SES_USER_ID');
   V_PLT_CD             :=       V_JSON.get_string('SES_WAREKY');

   /* 조건값 할당 */
   V_RANGE_SQL          :=       V_JSON.get_string('RANGE_SQL'); -- 플랜트코드, 자재그룹, 자재코드
   V_WERKS              :=       V_JSON.get_string('WERKS');     -- 플랜트코드 
   V_IND_BCD            :=       V_JSON.get_string('IND_BCD');   -- 개별 바코드

   --2022-08-25(목요일) 안상현, LOT 검색 조건 추가
   V_LOT_NO             :=       V_JSON.get_string('LOT_NO');    --LOT번호

   IF P_TYPE = 'LIST-A' THEN /*상단 조회 리스트(화장지 가공)*/

      V_SQL := '  SELECT
                     Q020.PRC_DIV         AS "PRC_DIV"       --처리구분(H)
                   ,(SELECT CDESC1 FROM CMCDV WHERE CMCDKY = ''PRC_DIV''  AND CMCDVL = Q020.PRC_DIV) AS "PRC_DIV_NM"
                   , W001.WERKS           AS "WERKS"         -- 플랜트
                   , W001.MACH_CD         AS "MACH_CD"       -- 설비코드
                   , W001.WRK_ORDR_NO     AS "WRK_ORDR_NO"   -- 작업지시번호
                   , W001.WRK_ORDR_SEQNO  AS "WRK_ORDR_SEQNO"  -- 작업지시순번
                   , W001.LOT_NO          AS "LOT_NO"        -- LOT번호
                   , W001.IND_BCD         AS "IND_BCD"       -- 개별바코드
                   , W001.PLT_QTY         AS "PLT_QTY"       -- 팔래트수량
                   , W001.BOX_QTY         AS "BOX_QTY"       -- 박스수량
                   , W001.BAG_QTY         AS "BAG_QTY"       -- 백수량
                   , W001.EA_QTY          AS "EA_QTY"        -- 개수량
                   , I001.STCK_QTY        AS "STCK_QTY"      -- 재고량
                   , Q020.UCFMTY_AMT      AS "UCFMTY_AMT"    -- 부적합량
                   , I001.WGT             AS "WGT"           -- 중량
                   , W001.REGDATE         AS "PRD_PRFM_DT"       -- 생산일시
                   , W001.PRD_DT          AS "PRD_DT"        -- 제조(생산)일자
                   , I001.STOR_LOC_CD     AS "STOR_LOC_CD"   -- 저장위치 
                   , I001.STCK_STA        AS "STCK_STA"      -- 재고상태
                   , I001.CHK_PP_YN       AS "CHK_PP_YN"     -- 생산팀 확인요청 
                   , FN_CD_VAL(''STCK_STA'', I001.STCK_STA) AS STCK_STA_NM  --재고상태(명)
                   , I001.STCK_KY         AS "STCK_KY"       -- (H)  
                   , I001.LOT_NUM         AS "LOT_NUM"       -- (H)
                   , M012.MACH_CD         AS "MACH_CD"       -- 설비코드
                   , M012.MACH_NM         AS "MACH_NM"       -- 설비명
                   , W001.MATNR           AS "MATNR"         -- 제품코드         
                   , M001.MATNR_NM        AS "MATNR_NM"      -- 제품명
                   , M001.BRAND_DESCR     AS "BRAND_DESCR"   -- 브랜드
                   , W001.UNIT            AS "UNIT"          -- 단위(H)
                   ,(SELECT CDESC1 FROM CMCDV WHERE CMCDKY = ''UNIT''  AND CMCDVL = W001.UNIT) AS "UNIT_NM"
                   , Q020.MSRM_DATE          AS "MSRM_DATE"         -- 측정일시(H)
                   , Q020.INSP_ITEM_GRP_CD   AS "INSP_ITEM_GRP_CD"  -- (H) 
                   , NVL(Q020.PRC_SEQNO,0)   AS "PRC_SEQNO"         --처리순번(H)
                   , Q020.DOC_NO             AS "DOC_NO"            -- (H)
                   , Q020.DOC_SEQNO          AS "DOC_SEQNO"         -- (H)
                   , DECODE(Q020.PRC_DIV, NULL, ''N'', '''', ''N'', ''Y'')        AS "INSP_YN"     -- 검사여부
                   , DECODE(Q024.MSRM_DATE, NULL, ''N'', '''', ''N'', ''Y'')      AS "UCFMTY_YN"   -- HIDDEN(부적합 결과 존재유무)
                   , M001.MATNR_DIV AS "MATNR_DIV"  -- 자재구분(HALB, FERT, 그외)
                   , Q020.REGDATE   --(H)
                   , NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = Q020.REGID),'''') AS "REGNM"
                   , Q020.UPDDATE
                   , NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = Q020.UPDID),'''') AS "UPDNM"
				   , (SELECT COUNT(*) FROM TB_MAS015 MAS015 WHERE MAS015.WERKS = M001.WERKS AND MAS015.MATNR = M001.MATNR AND MAS015.INSP_ITEM_GRP_CD = ''H3'') AS CHK_CNT --화장지 완제품검사 기준 등록 여부                       
                FROM TB_WRK001 W001,  --작업실적
                     TB_MAS001 M001,  --자재마스터
                     TB_INV001 I001,  --공정재고
                     TB_MAS012 M012,  --설비마스터
                     TB_QLT020 Q020,  --검사 마스터
                     TB_QLT024 Q024   --부적합
                WHERE 1 = 1
                  AND W001.MACH_CD        = M012.MACH_CD(+)                              
                  AND W001.WERKS          = M001.WERKS(+)
                  AND W001.MATNR          = M001.MATNR(+)            
                  AND W001.WERKS          = I001.WERKS(+)
                  AND W001.LOT_NO         = I001.LOT_NO(+)
                  AND W001.IND_BCD        = I001.IND_BCD(+)
                  AND W001.MATNR          = I001.MATNR(+)
                  AND I001.MSRM_DATE      = Q020.MSRM_DATE(+)
                  AND I001.PRC_SEQNO      = Q020.PRC_SEQNO(+)
                  AND Q020.MSRM_DATE      = Q024.MSRM_DATE(+)
                  AND Q020.PRC_SEQNO      = Q024.PRC_SEQNO(+)
                  AND M001.MATNR_DIV      = ''FERT''
                  AND I001.STOR_LOC_CD    = ''3100''
                  AND I001.STCK_STA      IN (''00'', ''40'', ''80'', ''70'')
                  AND NVL(W001.CNL_YN, ''N'') = ''N'' ';

        IF  V_WERKS IS NOT NULL OR TRIM(V_WERKS) != '' THEN -- 플랜트
            V_SQL := V_SQL || ' AND W001.WERKS  = ''' || V_WERKS || '''';             
        END IF;

        --2022-08-25(목요일) 안상현, LOT 검색 조건 추가
        IF  V_LOT_NO IS NOT NULL OR TRIM(V_LOT_NO) != '' THEN
            V_SQL := V_SQL || ' AND W001.LOT_NO  = ''' || V_LOT_NO || '''';             
        END IF;

        IF  V_RANGE_SQL IS NOT NULL OR TRIM(V_RANGE_SQL) != '' THEN -- 플랜트, 입고일자, 제조일자, 자재코드, 공급업체
            V_SQL := V_SQL || V_RANGE_SQL;
        END IF;                     

        IF  V_IND_BCD IS NOT NULL OR TRIM(V_IND_BCD) != '' THEN -- 개별바코드
            V_SQL := V_SQL || ' AND W001.IND_BCD  = ''' || V_IND_BCD || '''';             
        END IF;

		V_SQL := V_SQL || ' ORDER BY W001.PRFM_DT ';

        BEGIN           
     		OPEN P_RS_LIST FOR V_SQL;

        EXCEPTION           
        WHEN OTHERS THEN 
            P_SUCCESS           := 'N';
            E_SQL_ERR_CD        := -20000;
			E_SQL_ERR_MSG       := SQLCODE || ': EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

            SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
            RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);           
            RETURN;           
        END;    

   ELSIF P_TYPE = 'LIST-B' THEN /*상단 조회 리스트(생리대)*/

       V_SQL := '  SELECT
                     Q020.PRC_DIV         AS "PRC_DIV"       --처리구분(H)
                   ,(SELECT CDESC1 FROM CMCDV WHERE CMCDKY = ''PRC_DIV''  AND CMCDVL = Q020.PRC_DIV) AS "PRC_DIV_NM"
                   , W001.WERKS           AS "WERKS"         -- 플랜트
                   , W001.WRK_ORDR_NO     AS "WRK_ORDR_NO"   -- 작업지시번호
                   , W001.WRK_ORDR_SEQNO  AS "WRK_ORDR_SEQNO"  -- 작업지시순번
                   , W001.LOT_NO          AS "LOT_NO"        -- LOT번호
                   , W001.IND_BCD         AS "IND_BCD"       -- 개별바코드
                   , I001.PLT_QTY         AS "PLT_QTY"       -- 팔래트수량(H)
                   , I001.BOX_QTY         AS "BOX_QTY"       -- 박스수량(H)
                   , I001.BAG_QTY         AS "BAG_QTY"       -- 백수량(H)
                   , I001.EA_QTY          AS "EA_QTY"        -- 개수량(H)
                   , I001.STCK_QTY        AS "STCK_QTY"      -- 재고량
                   , I001.WGT             AS "WGT"           -- 중량(H)
                   , I001.STOR_LOC_CD     AS "STOR_LOC_CD"   -- 저장위치
                   , M012.MACH_CD         AS "MACH_CD"       -- 설비코드
                   , M012.MACH_NM         AS "MACH_NM"       -- 설비명
                   , W001.MATNR           AS "MATNR"         -- 제품코드         
                   , M001.MATNR_NM        AS "MATNR_NM"      -- 제품명
                   , M001.BRAND_DESCR     AS "BRAND_DESCR"   -- 브랜드
                   , W001.UNIT            AS "UNIT"          -- 단위
                   ,(SELECT CDESC1 FROM CMCDV WHERE CMCDKY = ''UNIT''  AND CMCDVL = W001.UNIT) AS "UNIT_NM"     
                   , W001.REGDATE         AS "PRD_PRFM_DT"       -- 생산일시
                   , W001.PRD_DT          AS "PRD_DT"        -- 제조(생산)일자
                   , I001.STOR_LOC_CD     AS "STOR_LOC_CD"   -- 저장위치 
                   , I001.STCK_STA        AS "STCK_STA"      -- 재고상태
                   , I001.CHK_PP_YN       AS "CHK_PP_YN"     -- 생산팀 확인요청 
                   , FN_CD_VAL(''STCK_STA'', I001.STCK_STA) AS STCK_STA_NM  --재고상태(명)
                   , I001.STCK_KY         AS "STCK_KY"       -- (H)  
                   , I001.LOT_NUM         AS "LOT_NUM"       -- (H)
                   , Q020.MSRM_DATE          AS "MSRM_DATE"         -- 측정일시(H)
                   , Q020.UCFMTY_AMT         AS "UCFMTY_AMT"        -- 부적합량
                   , Q020.INSP_ITEM_GRP_CD   AS "INSP_ITEM_GRP_CD"  -- HIDDEN 
                   , NVL(Q020.PRC_SEQNO,0)   AS "PRC_SEQNO"         -- 처리순번(H)
                   , Q020.DOC_NO             AS "DOC_NO"            -- HIDDEN
                   , Q020.DOC_SEQNO          AS "DOC_SEQNO"         -- HIDDEN
                   , DECODE(Q020.PRC_DIV, NULL, ''N'', '''', ''N'', ''Y'')        AS "INSP_YN"     -- 검사여부
                   , DECODE(Q024.MSRM_DATE, NULL, ''N'', '''', ''N'', ''Y'')      AS "UCFMTY_YN"   -- HIDDEN(부적합 결과 존재유무)
                   , Q020.REGDATE
                   , NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = Q020.REGID),'''') AS "REGNM"
                   , Q020.UPDDATE
                   , NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = Q020.UPDID),'''') AS "UPDNM"
				   , (SELECT COUNT(*) FROM TB_MAS015 MAS015 WHERE MAS015.WERKS = M001.WERKS AND MAS015.MATNR = M001.MATNR AND MAS015.INSP_ITEM_GRP_CD = ''H3'') AS CHK_CNT --생리대 완제품검사 기준 등록 여부                   
                FROM TB_WRK001 W001,  --작업실적
                     TB_MAS001 M001,  --자재마스터
                     TB_INV001 I001,  --공정재고
                     TB_MAS012 M012,  --설비마스터
                     TB_QLT020 Q020,  --검사 마스터
                     TB_QLT024 Q024   --부적합
                WHERE 1 = 1
                  AND W001.MACH_CD        = M012.MACH_CD(+)                              
                  AND W001.WERKS          = M001.WERKS(+)
                  AND W001.MATNR          = M001.MATNR(+)            
                  AND W001.WERKS          = I001.WERKS(+)
                  AND W001.LOT_NO         = I001.LOT_NO(+)
                  AND W001.IND_BCD        = I001.IND_BCD(+)
                  AND W001.MATNR          = I001.MATNR(+)
                  AND I001.MSRM_DATE      = Q020.MSRM_DATE(+)
                  AND I001.PRC_SEQNO      = Q020.PRC_SEQNO(+)
                  AND Q020.MSRM_DATE      = Q024.MSRM_DATE(+)
                  AND Q020.PRC_SEQNO      = Q024.PRC_SEQNO(+)
                  AND INSTR(M001.MATNR_NM, ''*'') = 0      
                  AND I001.STOR_LOC_CD    = ''3100''
                  AND I001.STCK_STA      IN (''00'', ''40'', ''80'', ''70'')
                  AND M001.MATNR_DIV      = ''FERT''
                  AND W001.WERKS          = ''P300''
                  AND NVL(W001.CNL_YN, ''N'') = ''N'' ';

        IF  V_WERKS IS NOT NULL OR TRIM(V_WERKS) != '' THEN -- 플랜트
            V_SQL := V_SQL || ' AND W001.WERKS  = ''' || V_WERKS || '''';             
        END IF;

        --2022-08-25(목요일) 안상현, LOT 검색 조건 추가
        IF  V_LOT_NO IS NOT NULL OR TRIM(V_LOT_NO) != '' THEN
            V_SQL := V_SQL || ' AND W001.LOT_NO  = ''' || V_LOT_NO || '''';             
        END IF;

        IF  V_RANGE_SQL IS NOT NULL OR TRIM(V_RANGE_SQL) != '' THEN -- 플랜트, 입고일자, 제조일자, 자재코드, 공급업체
            V_SQL := V_SQL || V_RANGE_SQL;
        END IF;                     

        IF  V_IND_BCD IS NOT NULL OR TRIM(V_IND_BCD) != '' THEN -- 개별바코드
            V_SQL := V_SQL || ' AND W001.IND_BCD  = ''' || V_IND_BCD || '''';             
        END IF;

		V_SQL := V_SQL || ' ORDER BY W001.PRFM_DT ';

        BEGIN           
     		OPEN P_RS_LIST FOR V_SQL;

        EXCEPTION           
        WHEN OTHERS THEN 
            P_SUCCESS           := 'N';
            E_SQL_ERR_CD        := -20000;
       		E_SQL_ERR_MSG       := SQLCODE || ': EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

            SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
            RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);           
            RETURN;           
        END;    

   ELSIF P_TYPE = 'LIST-C' THEN /*상단 조회 리스트(기저귀)*/

       V_SQL := '  SELECT
                     Q020.PRC_DIV         AS "PRC_DIV"       --처리구분(H)
                   ,(SELECT CDESC1 FROM CMCDV WHERE CMCDKY = ''PRC_DIV''  AND CMCDVL = Q020.PRC_DIV) AS "PRC_DIV_NM"
                   , W001.WERKS           AS "WERKS"         -- 플랜트
                   , W001.WRK_ORDR_NO     AS "WRK_ORDR_NO"   -- 작업지시번호
                   , W001.WRK_ORDR_SEQNO  AS "WRK_ORDR_SEQNO"  -- 작업지시순번
                   , W001.LOT_NO          AS "LOT_NO"        -- LOT번호
                   , W001.IND_BCD         AS "IND_BCD"       -- 개별바코드
                   , I001.PLT_QTY         AS "PLT_QTY"       -- 팔래트수량(H)
                   , I001.BOX_QTY         AS "BOX_QTY"       -- 박스수량(H)
                   , I001.BAG_QTY         AS "BAG_QTY"       -- 백수량(H)
                   , I001.EA_QTY          AS "EA_QTY"        -- 개수량(H)
                   , I001.STCK_QTY        AS "STCK_QTY"      -- 재고량
                   , I001.WGT             AS "WGT"           -- 중량(H)
                   , I001.STOR_LOC_CD     AS "STOR_LOC_CD"   -- 저장위치
                   , M012.MACH_CD         AS "MACH_CD"       -- 설비코드
                   , M012.MACH_NM         AS "MACH_NM"       -- 설비명
                   , W001.MATNR           AS "MATNR"         -- 제품코드         
                   , M001.MATNR_NM        AS "MATNR_NM"      -- 제품명
                   , M001.BRAND_DESCR     AS "BRAND_DESCR"   -- 브랜드
                   , W001.UNIT            AS "UNIT"          -- 단위
                   ,(SELECT CDESC1 FROM CMCDV WHERE CMCDKY = ''UNIT''  AND CMCDVL = W001.UNIT) AS "UNIT_NM"     
                   , W001.REGDATE         AS "PRD_PRFM_DT"      -- 생산일시
                   , W001.PRD_DT          AS "PRD_DT"        -- 제조(생산)일자
                   , I001.STOR_LOC_CD     AS "STOR_LOC_CD"   -- 저장위치 
                   , I001.STCK_STA        AS "STCK_STA"      -- 재고상태
                   , I001.CHK_PP_YN       AS "CHK_PP_YN"     -- 생산팀 확인요청 
                   , FN_CD_VAL(''STCK_STA'', I001.STCK_STA) AS STCK_STA_NM  --재고상태(명)
                   , I001.STCK_KY         AS "STCK_KY"       -- (H)  
                   , I001.LOT_NUM         AS "LOT_NUM"       -- (H)
                   , Q020.MSRM_DATE          AS "MSRM_DATE"         -- 측정일시(H)
                   , Q020.UCFMTY_AMT         AS "UCFMTY_AMT"        -- 부적합량
                   , Q020.INSP_ITEM_GRP_CD   AS "INSP_ITEM_GRP_CD"  -- HIDDEN 
                   , NVL(Q020.PRC_SEQNO,0)   AS "PRC_SEQNO"         -- 처리순번(H)
                   , Q020.DOC_NO             AS "DOC_NO"            -- HIDDEN
                   , Q020.DOC_SEQNO          AS "DOC_SEQNO"         -- HIDDEN
                   , DECODE(Q020.PRC_DIV, NULL, ''N'', '''', ''N'', ''Y'')        AS "INSP_YN"     -- 검사여부
                   , DECODE(Q024.MSRM_DATE, NULL, ''N'', '''', ''N'', ''Y'')      AS "UCFMTY_YN"   -- HIDDEN(부적합 결과 존재유무)
                   , Q020.REGDATE
                   , NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = Q020.REGID),'''') AS "REGNM"
                   , Q020.UPDDATE
                   , NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = Q020.UPDID),'''') AS "UPDNM"
				   , (SELECT COUNT(*) FROM TB_MAS015 MAS015 WHERE MAS015.WERKS = M001.WERKS AND MAS015.MATNR = M001.MATNR AND MAS015.INSP_ITEM_GRP_CD = ''H3'') AS CHK_CNT --기저귀 완제품검사 기준 등록 여부                   
                FROM TB_WRK001 W001,  --작업실적
                     TB_MAS001 M001,  --자재마스터
                     TB_INV001 I001,  --공정재고
                     TB_MAS012 M012,  --설비마스터
                     TB_QLT020 Q020,  --검사 마스터
                     TB_QLT024 Q024   --부적합
                WHERE 1 = 1
                  AND W001.MACH_CD        = M012.MACH_CD(+)                              
                  AND W001.WERKS          = M001.WERKS(+)
                  AND W001.MATNR          = M001.MATNR(+)            
                  AND W001.WERKS          = I001.WERKS(+)
                  AND W001.LOT_NO         = I001.LOT_NO(+)
                  AND W001.IND_BCD        = I001.IND_BCD(+)
                  AND W001.MATNR          = I001.MATNR(+)
                  AND I001.MSRM_DATE      = Q020.MSRM_DATE(+)
                  AND I001.PRC_SEQNO      = Q020.PRC_SEQNO(+)
                  AND Q020.MSRM_DATE      = Q024.MSRM_DATE(+)
                  AND Q020.PRC_SEQNO      = Q024.PRC_SEQNO(+)
                  AND I001.STOR_LOC_CD    = ''3100''
                  AND I001.STCK_STA      IN (''00'', ''40'', ''80'', ''70'')
                  AND M001.MATNR_DIV      = ''FERT''
                  AND W001.WERKS          = ''P500''
                  AND NVL(W001.CNL_YN, ''N'') = ''N'' ';

        IF  V_WERKS IS NOT NULL OR TRIM(V_WERKS) != '' THEN -- 플랜트
            V_SQL := V_SQL || ' AND W001.WERKS  = ''' || V_WERKS || '''';             
        END IF;

        --2022-08-25(목요일) 안상현, LOT 검색 조건 추가
        IF  V_LOT_NO IS NOT NULL OR TRIM(V_LOT_NO) != '' THEN
            V_SQL := V_SQL || ' AND W001.LOT_NO  = ''' || V_LOT_NO || '''';             
        END IF;

        IF  V_RANGE_SQL IS NOT NULL OR TRIM(V_RANGE_SQL) != '' THEN -- 플랜트, 입고일자, 제조일자, 자재코드, 공급업체
            V_SQL := V_SQL || V_RANGE_SQL;
        END IF;                     

        IF  V_IND_BCD IS NOT NULL OR TRIM(V_IND_BCD) != '' THEN -- 개별바코드
            V_SQL := V_SQL || ' AND W001.IND_BCD  = ''' || V_IND_BCD || '''';             
        END IF;

		V_SQL := V_SQL || ' ORDER BY W001.PRFM_DT ';

        BEGIN           
     		OPEN P_RS_LIST FOR V_SQL;

        EXCEPTION           
        WHEN OTHERS THEN 
            P_SUCCESS           := 'N';
            E_SQL_ERR_CD        := -20000;
       		E_SQL_ERR_MSG       := SQLCODE || ': EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

            SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
            RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);           
            RETURN;           
        END;    

    ELSIF P_TYPE = 'SUB_LIST' THEN  /* 하단 상세 조회 리스트*/

		V_MATNR              := V_JSON.get_string('MATNR');
		V_WERKS              := V_JSON.get_string('WERKS'); 
        V_MSRM_DATE          := V_JSON.get_date('MSRM_DATE');
        V_PRC_SEQNO          := V_JSON.get_number('PRC_SEQNO');

        V_MSRM_DT            := V_JSON.get_string('MSRM_DATE');

        V_SQL :=  ' SELECT A.INSP_ITEM_GRP_CD,
                           A.INSP_ITEM_CD,
                           A.INSP_ITEM_NM,
                           A.MID_CAT_NM,
                           A.BIG_CAT_NM,
                           (SELECT CDESC1 FROM CMCDV WHERE CMCDKY = ''INPTDIV'' AND CMCDVL = A.INPT_DIV) AS "INPT_DIV",
                           (SELECT CDESC1 FROM CMCDV WHERE CMCDKY = ''MSRMUNIT'' AND CMCDVL = A.MSRM_CYC) AS "MSRM_CYC",
                           A.MSRM_ACC,            -- 측정차수
                           A.NECSY_YN,            -- 필수입력 여부
                           (SELECT CDESC1 FROM CMCDV WHERE CMCDKY = ''INPTTYP'' AND CMCDVL = A.INPT_TYP) AS "INPT_TYP",                           
                           (SELECT CDESC1 FROM CMCDV WHERE CMCDKY = ''INPTMTD'' AND CMCDVL = A.INPT_MTD) AS "INPT_MTD",          
                           A.MSRM_MTD,            -- 측정방법
                           A.MSRM_UNIT,           -- 측정단위
                           A.INSP_SPEC,           -- 시험규격
                           B.STD_VAL,             -- 기준값
                           B.UPP_VAL,             -- 상한값
                           B.LOW_VAL,             -- 하한값
                           B.STD_SEL,             -- 기준선택값
                           B.INSP_STD_1,          -- 기준값(1)
                           B.INSP_STD_2,          -- 기준값(2)
                           DECODE(B.STD_VAL, NULL, ''X'', DECODE(B.STD_SEL, NULL, ''X'', DECODE(B.INSP_STD_1, NULL, ''X'', ''O''))) AS  STD_REG_YN,
                           DECODE(A.INPT_TYP, ''N'', C.RST_VAL, NULL) AS "RST_VAL",      -- 결과값(숫자)
                           DECODE(A.INPT_TYP, ''N'', '''', C.RST_SEL) AS "RST_SEL",      -- 결과값(선택)
                           C.RST_TXT                                  AS "RST_TXT",      -- 결과값(문자열)
                           C.RMK                                      AS "RMK",          -- 결과값(특이사항)
                           C.FIT_YN                                   AS "FIT_YN",       -- 적합여부
                           C.INSP_REP_YN                              AS "INSP_REP_YN",  -- 성적서 출력여부
                           DECODE(C.UUID, NULL, '''', C.UUID)         AS "UUID",         -- 파일 ID(저장)
                           C.NAME                                     AS "UUID_FILEVIEW",-- 파일명
                           C.REGDATE                                  AS "REGDATE",
                           NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = C.REGID),'''') AS "REGNM"                           
                    FROM
                         (SELECT
                                INSP_ITEM_GRP_CD,
                                INSP_ITEM_CD,
                                INSP_ITEM_NM,
                                PROD_GRP_CD,
                                MID_CAT_NM,
                                BIG_CAT_NM,
                                INPT_DIV,
                                MSRM_CYC,
                                MSRM_ACC,
                                NECSY_YN,
                                INPT_TYP,
                                INPT_MTD,
                                MSRM_MTD,
                                MSRM_UNIT,
                                INSP_SPEC,
                                DISP_SEQ,
                                USE_YN
                        FROM  TB_MAS014 M014 
                       WHERE  M014.INSP_ITEM_GRP_CD = ''H3''
                         AND  M014.PROD_GRP_CD  = FN_GET_PROD_GRP( '''|| V_WERKS || ''','''|| V_MATNR ||''' )                       
                       ) A, -- 완제품 물성검사 항목만 표시
                              (SELECT INSP_ITEM_GRP_CD, 
                                      INSP_ITEM_CD, 
                                      MATNR, 
                                      WERKS, 
                                      STD_VAL, 
                                      UPP_VAL, 
                                      LOW_VAL, 
                                      STD_SEL, 
                                      INSP_STD_1, 
                                      INSP_STD_2
                                 FROM TB_MAS016 
                                WHERE INSP_ITEM_GRP_CD = ''H3''
                                  AND MATNR      = '''|| V_MATNR ||''' 
                                  AND WERKS      = '''|| V_WERKS ||''') B,
                              (SELECT Q021.INSP_ITEM_GRP_CD, Q021.MATNR, Q021.WERKS, Q021.INSP_ITEM_CD, Q021.RST_VAL, Q021.RST_SEL, Q021.RST_TXT, Q021.RMK, Q021.FIT_YN, Q021.INSP_REP_YN, Q021.REGID, Q021.REGDATE, 
                                      Q021.UUID, SYSF.RPATH, SYSF.NAME, SYSF.FNAME 
                                 FROM TB_QLT021 Q021, SYSFILE SYSF 
                                WHERE Q021.UUID             = SYSF.UUID(+) 
                                  AND Q021.INSP_ITEM_GRP_CD = ''H3'' 
                                  AND Q021.MATNR            = '''|| V_MATNR ||''' 
                                  AND Q021.WERKS            = '''|| V_WERKS ||''' 
                                  AND Q021.MSRM_DATE        = TO_DATE('''|| V_MSRM_DT ||''',''YYYY-MM-DD HH24:MI:SS'') 
                                  AND Q021.PRC_SEQNO        = TO_NUMBER(''' || V_PRC_SEQNO ||''')) C
                    WHERE A.INSP_ITEM_GRP_CD = B.INSP_ITEM_GRP_CD(+)
                      AND A.INSP_ITEM_CD     = B.INSP_ITEM_CD(+) 
                      AND A.USE_YN           = ''Y''
                      AND A.INSP_ITEM_GRP_CD = B.INSP_ITEM_GRP_CD(+)
                      AND A.INSP_ITEM_CD     = B.INSP_ITEM_CD(+)
                      AND A.INSP_ITEM_GRP_CD IS NOT NULL
                      AND A.INSP_ITEM_GRP_CD = C.INSP_ITEM_GRP_CD(+)
                      AND A.INSP_ITEM_CD     = C.INSP_ITEM_CD(+) 
                    ORDER BY A.DISP_SEQ  ';

        BEGIN           
   	    	OPEN P_RS_LIST FOR V_SQL;

        EXCEPTION           
        WHEN OTHERS THEN 
            P_SUCCESS           := 'N';
            E_SQL_ERR_CD        := -20000;
       		E_SQL_ERR_MSG       := SQLCODE || ': EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

            SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
            RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);           
            RETURN;           
        END;    


    ELSIF P_TYPE = 'SAVE' THEN
          RETURN;            

    ELSIF P_TYPE = 'SUB_SAVE' THEN

        -- 상단의 선택된 그리드 맵에서 가져온다.
        V_ARR_HEAD           := V_JSON.get_array('head');    

        -- 상단의 입력된 맵에서 가져온다.
 	 	V_INSP_ITEM_GRP_CD   := V_JSON.get_string('INSP_ITEM_GRP_CD'); /*품질측정그룹*/
        V_SMPL_AMT           := V_JSON.get_number('SMPL_AMT');       /*시료량 BAG 단위*/
        V_FNL_JDGM           := V_JSON.get_string('FNL_JDGM');         /*최종판정*/   

        V_DOC_NEW_NO_1       := FN_GET_MDOCNO(V_PLT_CD, 'MES_IF_402'); /*WMS 전송 문서번호 생성(출고요청 취소)*/
        V_DOC_NEW_NO_2       := FN_GET_MDOCNO(V_PLT_CD, 'MES_IF_906'); /*WMS 전송 문서번호 생성(완제품 검사)*/
        
        V_AN_SEQNO			 := V_JSON.get_number('AN_SEQNO');

        --ㅡ여러개가 선택된 경우 멀티로 선택했다는 내용을 기록으로 남김.
        IF V_ARR_HEAD.get_size > 1 THEN
           V_PRC_DIV   := 'M';
        ELSE
           V_PRC_DIV   := 'I';
        END IF;

        FOR i IN 0..V_ARR_HEAD.get_size-1 LOOP -- 상단 그리드 개수 만큼

                V_OBJ_HEAD               := TREAT (V_ARR_HEAD.get (i) AS json_object_t);
                V_OBJ_HEAD               := TREAT (V_OBJ_HEAD.get ('map') AS json_object_t);

                -- 상단의 선택된 리스트 맵에서 가져온다. 	 	
                V_MATNR              := V_OBJ_HEAD.get_string('MATNR');        
                V_WERKS              := V_OBJ_HEAD.get_string('WERKS');   
                V_ORDER_NO           := V_OBJ_HEAD.get_string('ORDER_NO');
                V_ORDER_SEQNO        := V_OBJ_HEAD.get_string('ORDER_SEQNO');
                V_WRK_ORDR_NO        := V_OBJ_HEAD.get_string('WRK_ORDR_NO');
                V_WRK_ORDR_SEQNO     := V_OBJ_HEAD.get_number('WRK_ORDR_SEQNO');
                V_UNIT               := V_OBJ_HEAD.get_string('UNIT');
                V_LOT_NO             := V_OBJ_HEAD.get_string('LOT_NO');       /*LOTNO*/    
                V_IND_BCD            := V_OBJ_HEAD.get_string('IND_BCD');      /*개별바코드*/ 
                V_MSRM_DATE          := V_OBJ_HEAD.get_date('MSRM_DATE');      /*측정일시*/
                V_PRC_SEQNO          := V_OBJ_HEAD.get_number('PRC_SEQNO');    /*처리차수*/
                V_DOC_NO             := V_OBJ_HEAD.get_string('DOC_NO');       /*MES 문서번호*/
                V_DOC_SEQNO          := V_OBJ_HEAD.get_number('DOC_SEQNO');    /*MES 문서순번*/
                V_STOR_LOC_CD        := V_OBJ_HEAD.get_string('STOR_LOC_CD');  /*저장위치*/
                V_STCK_STA           := V_OBJ_HEAD.get_string('STCK_STA');     /*재고상태*/                
                V_STCK_KY            := V_OBJ_HEAD.get_string('STCK_KY');      /*저장키*/
                V_LOT_NUM            := V_OBJ_HEAD.get_string('LOT_NUM');      /*LOT NUM*/

                V_MSRM_DT            := V_OBJ_HEAD.get_string('MSRM_DATE');
                V_PLT_QTY            := V_OBJ_HEAD.get_number('PLT_QTY');        /*팔래트수량*/
                V_BOX_QTY            := V_OBJ_HEAD.get_number('BOX_QTY');        /*뱍스수량*/
                V_BAG_QTY            := V_OBJ_HEAD.get_number('BAG_QTY');        /*백수량*/
                V_EA_QTY             := V_OBJ_HEAD.get_number('EA_QTY');         /*개수량*/
                V_WGT                := V_OBJ_HEAD.get_number('WGT_QTY');        /*중량*/
       	 	    V_UCFMTY_AMT         := V_OBJ_HEAD.get_number('UCFMTY_AMT');     /*부적합량*/        
                V_STCK_QTY           := V_OBJ_HEAD.get_number('STCK_QTY');       /*재고량*/
                V_MATNR_DIV          := V_OBJ_HEAD.get_string('MATNR_DIV');      /*자재구분*/

                V_NEW_MSRM_DT         := TO_CHAR(SYSDATE,'YYYY-MM-DD HH24:MI:SS'); 
				IF(i = 0) THEN
                	V_AN_MSRM_DT 	:= V_NEW_MSRM_DT;
                END IF;
               
                IF TRIM(V_MSRM_DT) IS NULL OR TRIM(V_MSRM_DT) = ' ' THEN
                   V_MSRM_DT             := V_NEW_MSRM_DT; 
                END IF;

                IF TRIM(V_DOC_NO) IS NULL OR TRIM(V_DOC_NO) = ' ' THEN          /*이미 등록된 문서번호가 없으면 신규 번호를 할당한다.*/
                   V_DOC_NO_1          := V_DOC_NEW_NO_1; 
                   V_DOC_NO_2          := V_DOC_NEW_NO_2;                     
                END IF;

                BEGIN 
                    SELECT NVL(COUNT(*),0)
                      INTO V_Q020_CNT
                      FROM TB_QLT020 Q020
                     WHERE Q020.INSP_ITEM_GRP_CD   =  V_INSP_ITEM_GRP_CD
                       AND Q020.MATNR              =  V_MATNR
                       AND Q020.WERKS              =  V_WERKS
                       AND Q020.MSRM_DATE          =  TO_DATE(V_MSRM_DT, 'YYYY-MM-DD HH24:MI:SS')
                       AND Q020.PRC_SEQNO          =  V_PRC_SEQNO;
                EXCEPTION           
                WHEN OTHERS THEN 
                       P_SUCCESS           := 'N';
                       E_SQL_ERR_CD        := SQLCODE;
                       E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR(select QLT020). [' || SUBSTR(SQLERRM,1,500) || ']';
                       ROLLBACK;

                       SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
                       RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);           
                       RETURN;           
                END; 


                IF V_Q020_CNT = 0 THEN

                   BEGIN
                        INSERT INTO  TB_QLT020 (
                                INSP_ITEM_GRP_CD,
                                MATNR,
                                WERKS,
                                MSRM_DATE,
                                PRC_SEQNO,
                                MSRM_ID,
                                SMPL_AMT,
    --                                    UCFMTY_AMT,
                                FNL_JDGM,
                                LOT_NO,
                                IND_BCD,
                                DOC_NO,
                                DOC_SEQNO,
                                PRC_DIV,
                                REGDATE,
                                REGID
                        ) VALUES (
                                V_INSP_ITEM_GRP_CD,
                                V_MATNR,
                                V_WERKS,
                                TO_DATE(V_NEW_MSRM_DT,'YYYY-MM-DD HH24:MI:SS'),
                                i + 1,
                                V_SESS_USER_ID,
                                V_SMPL_AMT,
    --                                    NVL(V_UCFMTY_AMT, V_WGT),
                                V_FNL_JDGM,
                                V_LOT_NO,
                                V_IND_BCD,
                                V_DOC_NO,
                                V_DOC_SEQNO,
                                V_PRC_DIV,
                                SYSDATE,
                                V_SESS_USER_ID );
                   EXCEPTION           
                   WHEN OTHERS THEN 
                          P_SUCCESS           := 'N';
                          E_SQL_ERR_CD        := -20000;
                          E_SQL_ERR_MSG       := SQLCODE || ': EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';
                          ROLLBACK;

                          SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
                          RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);           
                          RETURN;           
                   END; 

                ELSE

                   BEGIN
                       DELETE FROM TB_QLT024 Q024                    
                        WHERE Q024.INSP_ITEM_GRP_CD   =  V_INSP_ITEM_GRP_CD
                          AND Q024.MATNR              =  V_MATNR
                          AND Q024.WERKS              =  V_WERKS
                          AND Q024.MSRM_DATE          =  TO_DATE(V_MSRM_DT,'YYYY-MM-DD HH24:MI:SS')
                          AND Q024.PRC_SEQNO          =  V_PRC_SEQNO;
                   EXCEPTION           
                   WHEN OTHERS THEN 
                       P_SUCCESS           := 'N';
                       E_SQL_ERR_CD        := -20000;
                       E_SQL_ERR_MSG       := SQLCODE || ': EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';
                       ROLLBACK;

                       SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
                       RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);           
                       RETURN;           
                   END; 

                   BEGIN
                     DELETE FROM TB_QLT021 Q021                    
                      WHERE Q021.INSP_ITEM_GRP_CD   =  V_INSP_ITEM_GRP_CD
                        AND Q021.MATNR              =  V_MATNR
                        AND Q021.WERKS              =  V_WERKS
                        AND Q021.MSRM_DATE          =  TO_DATE(V_MSRM_DT,'YYYY-MM-DD HH24:MI:SS')
                        AND Q021.PRC_SEQNO          =  V_PRC_SEQNO;
                   EXCEPTION           
                   WHEN OTHERS THEN 
                       P_SUCCESS           := 'N';
                       E_SQL_ERR_CD        := -20000;
                       E_SQL_ERR_MSG       := SQLCODE || ': EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';
                       ROLLBACK;

                       SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
                       RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);           
                       RETURN;           
                   END; 

                   BEGIN
                        UPDATE TB_QLT020 Q020
                            SET  Q020.MSRM_ID            =  V_SESS_USER_ID     /*판정자*/
                               , Q020.MSRM_DATE          =  TO_DATE(V_NEW_MSRM_DT,'YYYY-MM-DD HH24:MI:SS')
                               , Q020.PRC_SEQNO          =  i + 1
                               , Q020.SMPL_AMT           =  V_SMPL_AMT         /*시료량*/
                               , Q020.FNL_JDGM           =  V_FNL_JDGM         /*최종판정*/
                               , Q020.DOC_NO             =  V_DOC_NO           /*MES 전송문서번호*/
                               , Q020.DOC_SEQNO          =  V_DOC_SEQNO        /*MES 전송문서번호순번*/ 
                               , Q020.PRC_DIV            =  V_PRC_DIV          /*처리구분*/
                               , Q020.UPDDATE            =  SYSDATE            /*수정일자*/
                               , Q020.UPDID              =  V_SESS_USER_ID     /*수정자 */
                             WHERE (Q020.INSP_ITEM_GRP_CD   =  V_INSP_ITEM_GRP_CD
                               AND  Q020.MATNR              =  V_MATNR
                               AND  Q020.WERKS              =  V_WERKS
                               AND  Q020.MSRM_DATE          =  TO_DATE(V_MSRM_DT,'YYYY-MM-DD HH24:MI:SS')
                               AND  Q020.PRC_SEQNO          =  V_PRC_SEQNO);
                        EXCEPTION           
                        WHEN OTHERS THEN 
                              P_SUCCESS           := 'N';
                              E_SQL_ERR_CD        := -20000;
                              E_SQL_ERR_MSG       := SQLCODE || ': EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';
                              ROLLBACK;

                              SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
                              RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);           
                              RETURN;           
                   END; 

                END IF;
               
               --2022-11-01(화요일) 안상현, 검사결과 저장 후 삭제
                BEGIN
	                
	              	INSERT INTO TB_QLT022
					(
						INSP_ITEM_GRP_CD	--검사항목그룹코드
					,	MATNR				--자재코드
					,	WERKS				--플랜트코드
					,	MSRM_DATE			--측정일시(검사일시)
					,	PRC_SEQNO			--처리순번
					,	INSP_ITEM_CD		--검사항목코드
					,	INSP_SEQNO			--검사차수
					,	RST_VAL				--측정값(숫자)
					,	REGDATE				--등록일시
					,	REGID				--등록자ID
					) 
					SELECT
						QLT022.INSP_ITEM_GRP_CD
					,	QLT022.MATNR
					,	QLT022.WERKS
					,	TO_DATE(V_NEW_MSRM_DT,'YYYY-MM-DD HH24:MI:SS')
					,	i + 1
					,	QLT022.INSP_ITEM_CD
					,	QLT022.INSP_SEQNO
					,	QLT022.RST_VAL
					,	SYSDATE
					,	V_SESS_USER_ID
					FROM 
						TB_QLT022 QLT022
					WHERE 1=1
					AND QLT022.INSP_ITEM_GRP_CD   =  V_INSP_ITEM_GRP_CD
					AND QLT022.MATNR              =  V_MATNR
					AND QLT022.WERKS              =  V_WERKS
					AND QLT022.MSRM_DATE          =  DECODE(i, 0, TO_DATE(V_MSRM_DT,'YYYY-MM-DD HH24:MI:SS'), TO_DATE(V_AN_MSRM_DT,'YYYY-MM-DD HH24:MI:SS'))
					AND QLT022.PRC_SEQNO          =  DECODE(i, 0, V_AN_SEQNO, i);
				
	                --이전 검사결과 삭제
                    DELETE FROM TB_QLT022 QLT022
                    WHERE 1=1
                    AND QLT022.INSP_ITEM_GRP_CD   =  V_INSP_ITEM_GRP_CD
                    AND QLT022.MATNR              =  V_MATNR
                    AND QLT022.WERKS              =  V_WERKS
                    AND QLT022.MSRM_DATE          =  TO_DATE(V_MSRM_DT,'YYYY-MM-DD HH24:MI:SS')
                    AND QLT022.PRC_SEQNO          =  V_PRC_SEQNO;
                    
                   EXCEPTION           
                   WHEN OTHERS THEN 
                       P_SUCCESS           := 'N';
                       E_SQL_ERR_CD        := -20000;
                       E_SQL_ERR_MSG       := SQLCODE || ': EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';
                       ROLLBACK;

                       SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
                       RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);           
                       RETURN;           
                   END;

               -- 하단의 선택된 그리드 맵에서 가져온다.
                V_ARR_LIST           := V_JSON.get_array('list');    

                FOR j IN 0..V_ARR_LIST.get_size-1 LOOP

                    V_OBJ_LIST               := TREAT (V_ARR_LIST.get (j) AS json_object_t);
                    V_OBJ_LIST               := TREAT (V_OBJ_LIST.get ('map') AS json_object_t);

                    V_INSP_ITEM_GRP_CD  := V_OBJ_LIST.get_string('INSP_ITEM_GRP_CD');
                    V_INSP_ITEM_CD      := V_OBJ_LIST.get_string('INSP_ITEM_CD');
                    V_STD_VAL           := V_OBJ_LIST.get_number('STD_VAL');
                    V_UPP_VAL           := V_OBJ_LIST.get_number('UPP_VAL');
                    V_LOW_VAL           := V_OBJ_LIST.get_number('LOW_VAL');
                    V_STD_SEL           := V_OBJ_LIST.get_string('STD_SEL');
                    V_INSP_STD_1        := V_OBJ_LIST.get_string('INSP_STD_1');
                    V_INSP_STD_2        := V_OBJ_LIST.get_string('INSP_STD_2');                    
                    V_RST_VAL           := V_OBJ_LIST.get_number('RST_VAL');
                    V_RST_SEL           := V_OBJ_LIST.get_string('RST_SEL');
                    V_RST_TXT           := V_OBJ_LIST.get_string('RST_TXT');
                    V_RMK               := V_OBJ_LIST.get_string('RMK');
                    V_FIT_YN            := V_OBJ_LIST.get_string('FIT_YN');
                    V_INSP_REP_YN       := V_OBJ_LIST.get_string('INSP_REP_YN');
                    V_UUID              := V_OBJ_LIST.get_string('UUID');

                    IF V_OBJ_LIST.get_string('GRowState') = 'C' THEN  --추가가 있나?
                          RETURN; 

                    ELSIF  V_OBJ_LIST.get_string('GRowState') = 'U' OR V_OBJ_LIST.get_string('GRowState') = 'R' THEN

                           -- 품질검사(측정) 항목별 세부결과를 등록 및 업데이트 한다. 
                               BEGIN
                                    INSERT INTO  TB_QLT021 (
                                            INSP_ITEM_GRP_CD,
                                            MATNR,
                                            WERKS,
                                            MSRM_DATE,
                                            PRC_SEQNO,
                                            INSP_ITEM_CD,
                                            INSP_REP_YN,
                                            RST_VAL,
                                            RST_SEL,
                                            RST_TXT,
                                            RMK,
                                            FIT_YN,
                                            UUID,
                                            REGDATE,
                                            REGID
                                    ) VALUES (
                                            V_INSP_ITEM_GRP_CD,
                                            V_MATNR,
                                            V_WERKS,
                                            TO_DATE(V_NEW_MSRM_DT,'YYYY-MM-DD HH24:MI:SS'),
                                            i + 1,
                                            V_INSP_ITEM_CD,
                                            V_INSP_REP_YN,
                                            V_RST_VAL,
                                            V_RST_SEL,
                                            V_RST_TXT,
                                            V_RMK,
                                            V_FIT_YN,
                                            V_UUID,
                                            SYSDATE,
                                            V_SESS_USER_ID );
                               EXCEPTION           
                               WHEN OTHERS THEN 
                                      P_SUCCESS           := 'N';
                                      E_SQL_ERR_CD        := -20000;
                                      E_SQL_ERR_MSG       := SQLCODE || ': EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';
                                      ROLLBACK;

                                      SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
                                      RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);           
                                      RETURN;           
                               END; 

--                                   -- 품질검사(측정) 항목별 세부결과를 등록 및 업데이트 한다. 
--                                   BEGIN
--                                        UPDATE TB_QLT021 Q021
--                                           SET MSRM_DATE              =  TO_DATE(V_NEW_MSRM_DT,'YYYY-MM-DD HH24:MI:SS')
--                                             , PRC_SEQNO              =  i + 1
--                                             , INSP_REP_YN            =  V_INSP_REP_YN
--                                             , RST_VAL                =  V_RST_VAL
--                                             , RST_SEL                =  V_RST_SEL                                         
--                                             , RST_TXT                =  V_RST_TXT
--                                             , RMK                    =  V_RMK
--                                             , FIT_YN                 =  V_FIT_YN
--                                             , UUID                   =  V_UUID
--                                             , UPDDATE                =  SYSDATE
--                                             , UPDID                  =  V_SESS_USER_ID                   
--                                         WHERE (Q021.INSP_ITEM_GRP_CD   =  V_INSP_ITEM_GRP_CD
--                                           AND  Q021.MATNR              =  V_MATNR
--                                           AND  Q021.WERKS              =  V_WERKS
--                                           AND  Q021.MSRM_DATE          =  TO_DATE(V_MSRM_DT,'YYYY-MM-DD HH24:MI:SS')
--                                           AND  Q021.PRC_SEQNO          =  V_PRC_SEQNO
--                                           AND  Q021.INSP_ITEM_CD       =  V_INSP_ITEM_CD);
--                                    EXCEPTION           
--                                    WHEN OTHERS THEN 
--                                          P_SUCCESS           := 'N';
--                                          E_SQL_ERR_CD        := -20000;
--                                          E_SQL_ERR_MSG       := SQLCODE || ': EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';
--                                          ROLLBACK;
--            
--                                          SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
--                                          RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);           
--                                          RETURN;           
--                                   END; 

--                               END IF;
--                               
                               -- 품질 측정결과에 대해 계속 수정하면 변경이력를 등록 및 업데이트 한다. 
                               BEGIN
                                     SELECT Q023.INSP_ITEM_GRP_CD , Q023.MATNR, Q023.WERKS, Q023.MSRM_DATE, Q023.PRC_SEQNO, Q023.INSP_ITEM_CD, Q023.CHG_ACC, 
                                            Q023.BEF_RST_VAL, Q023.BEF_RST_SEL, Q023.BEF_RST_TXT, Q023.BEF_RMK, Q023.BEF_INSP_REP_YN, Q023.BEF_FIT_YN, Q023.BEF_UUID,
                                            Q023.AFT_RST_VAL, Q023.AFT_RST_SEL, Q023.AFT_RST_TXT, Q023.AFT_RMK, Q023.AFT_INSP_REP_YN, Q023.AFT_FIT_YN, Q023.AFT_UUID       
                                      INTO  V_INSP_ITEM_GRP_CD , V_MATNR, V_WERKS, V_MSRM_DATE, V_PRC_SEQNO, V_INSP_ITEM_CD, V_CHG_ACC, 
                                            V_BEF_RST_VAL, V_BEF_RST_SEL, V_BEF_RST_TXT, V_BEF_RMK, V_BEF_INSP_REP_YN, V_BEF_FIT_YN, V_BEF_UUID,
                                            V_AFT_RST_VAL, V_AFT_RST_SEL, V_AFT_RST_TXT, V_AFT_RMK, V_AFT_INSP_REP_YN, V_AFT_FIT_YN, V_AFT_UUID           
                                      FROM  TB_QLT023 Q023,
                                            (SELECT Q023.INSP_ITEM_GRP_CD , Q023.MATNR, Q023.WERKS, Q023.IND_BCD, Q023.INSP_ITEM_CD, NVL(MAX(Q023.CHG_ACC), 1) AS MAX_CHG_ACC
                                               FROM TB_QLT023 Q023
                                              WHERE Q023.INSP_ITEM_GRP_CD   =  V_INSP_ITEM_GRP_CD
                                                AND Q023.MATNR              =  V_MATNR
                                                AND Q023.WERKS              =  V_WERKS
                                                AND Q023.IND_BCD            =  V_IND_BCD
                                                AND Q023.INSP_ITEM_CD       =  V_INSP_ITEM_CD                
                                           GROUP BY Q023.INSP_ITEM_GRP_CD , Q023.MATNR, Q023.WERKS, Q023.IND_BCD, Q023.INSP_ITEM_CD) GR_Q023
                                     WHERE Q023.INSP_ITEM_GRP_CD   =  GR_Q023.INSP_ITEM_GRP_CD 
                                       AND Q023.MATNR              =  GR_Q023.MATNR 
                                       AND Q023.WERKS              =  GR_Q023.WERKS 
                                       AND Q023.IND_BCD            =  GR_Q023.IND_BCD
                                       AND Q023.INSP_ITEM_CD       =  GR_Q023.INSP_ITEM_CD
                                       AND Q023.CHG_ACC            =  GR_Q023.MAX_CHG_ACC
                                       AND Q023.INSP_ITEM_GRP_CD   =  V_INSP_ITEM_GRP_CD
                                       AND Q023.MATNR              =  V_MATNR
                                       AND Q023.WERKS              =  V_WERKS
                                       AND Q023.IND_BCD            =  V_IND_BCD
                                       AND Q023.INSP_ITEM_CD       =  V_INSP_ITEM_CD;
                               EXCEPTION
                                    WHEN NO_DATA_FOUND THEN
                                         NULL;
                               END;        

                               IF  SQL%NOTFOUND THEN 
                                   BEGIN
                                        INSERT  INTO TB_QLT023 (
                                                INSP_ITEM_GRP_CD,
                                                MATNR,
                                                WERKS,
                                                MSRM_DATE,
                                                PRC_SEQNO,
                                                INSP_ITEM_CD,
                                                CHG_ACC,
                                                WRK_ORDR_NO,
                                                WRK_ORDR_SEQ,
                                                LOT_NO,
                                                IND_BCD, 
                                                STD_VAL,
                                                UPP_VAL,
                                                LOW_VAL,
                                                STD_SEL,
                                                INSP_STD_1,
                                                INSP_STD_2,
                                                AFT_INSP_REP_YN,
                                                AFT_RST_VAL,
                                                AFT_RST_SEL,
                                                AFT_RST_TXT,
                                                AFT_RMK,
                                                AFT_FIT_YN,
                                                AFT_UUID, 
                                                REGDATE,
                                                REGID
                                        ) VALUES (
                                                V_INSP_ITEM_GRP_CD,
                                                V_MATNR,
                                                V_WERKS,
                                                TO_DATE(V_NEW_MSRM_DT,'YYYY-MM-DD HH24:MI:SS'),
                                                i + 1,
                                                V_INSP_ITEM_CD,
                                                1,
                                                V_WRK_ORDR_NO,
                                                V_WRK_ORDR_SEQNO,
                                                V_LOT_NO,
                                                V_IND_BCD,
                                                V_STD_VAL,
                                                V_UPP_VAL,
                                                V_LOW_VAL,
                                                V_STD_SEL,
                                                V_INSP_STD_1,
                                                V_INSP_STD_2,
                                                V_INSP_REP_YN,
                                                V_RST_VAL,
                                                V_RST_SEL,
                                                V_RST_TXT,
                                                V_RMK,
                                                V_FIT_YN,
                                                V_UUID,
                                                SYSDATE,
                                                V_SESS_USER_ID 
                                            );
                                       EXCEPTION           
                                       WHEN OTHERS THEN 
                                             P_SUCCESS           := 'N';
                                             E_SQL_ERR_CD        := -20000;
										  	 E_SQL_ERR_MSG       := SQLCODE || ': EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';
                                             ROLLBACK;

                                             SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
                                             RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);           
                                             RETURN;           
                                     END;

                               ELSIF SQL%FOUND THEN                        

                                     BEGIN
                                        INSERT INTO TB_QLT023 (
                                                INSP_ITEM_GRP_CD,
                                                MATNR,
                                                WERKS,
                                                MSRM_DATE,
                                                PRC_SEQNO,
                                                INSP_ITEM_CD,
                                                CHG_ACC,
                                                WRK_ORDR_NO,
                                                WRK_ORDR_SEQ,
                                                LOT_NO,
                                                IND_BCD, 
                                                STD_VAL,
                                                UPP_VAL,
                                                LOW_VAL,
                                                STD_SEL,
                                                INSP_STD_1,
                                                INSP_STD_2,
                                                BEF_INSP_REP_YN,
                                                BEF_RST_VAL,
                                                BEF_RST_SEL,
                                                BEF_RST_TXT,
                                                BEF_RMK,
                                                BEF_FIT_YN,
                                                BEF_UUID,
                                                AFT_INSP_REP_YN,
                                                AFT_RST_VAL,
                                                AFT_RST_SEL,
                                                AFT_RST_TXT,
                                                AFT_RMK,
                                                AFT_FIT_YN,
                                                AFT_UUID,
                                                REGDATE,
                                                REGID
                                        ) VALUES (
                                                V_INSP_ITEM_GRP_CD,
                                                V_MATNR,
                                                V_WERKS,
                                                TO_DATE(V_NEW_MSRM_DT,'YYYY-MM-DD HH24:MI:SS'),
                                                i + 1,
                                                V_INSP_ITEM_CD,
                                                V_CHG_ACC + 1,
                                                V_WRK_ORDR_NO,
                                                V_WRK_ORDR_SEQNO,
                                                V_LOT_NO,
                                                V_IND_BCD, 
                                                V_STD_VAL,
                                                V_UPP_VAL,
                                                V_LOW_VAL,
                                                V_STD_SEL,
                                                V_INSP_STD_1,
                                                V_INSP_STD_2,
                                                V_AFT_INSP_REP_YN,
                                                V_AFT_RST_VAL,
                                                V_AFT_RST_SEL,
                                                V_AFT_RST_TXT,
                                                V_AFT_RMK,
                                                V_AFT_FIT_YN,
                                                V_AFT_UUID,
                                                V_INSP_REP_YN,
                                                V_RST_VAL,
                                                V_RST_SEL,
                                                V_RST_TXT,
                                                V_RMK,
                                                V_FIT_YN,
                                                V_UUID,
                                                SYSDATE,
                                                V_SESS_USER_ID 
                                            );
                                     EXCEPTION           
                                     WHEN OTHERS THEN 
                                          P_SUCCESS           := 'N';
                                          E_SQL_ERR_CD        := -20000;
										  E_SQL_ERR_MSG       := SQLCODE || ': EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';
                                          ROLLBACK;

                                          SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
                                          RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);           
                                          RETURN;           
                                     END;

                               END IF;

                    ELSIF V_OBJ_LIST.get_string('GRowState') = 'D' THEN  -- 삭제가 있나?
                          RETURN;              

                    END IF;

                    IF V_FIT_YN = 'N' THEN
                       --V_BADRSNNM := V_BADRSNNM || V_RMK || ',';
                       V_BADRSNNM := '-';
                    END IF;

                END LOOP;


                IF  V_FNL_JDGM = 'FAIL' THEN

                     BEGIN
                        UPDATE TB_INV001 I001
                           SET STCK_STA                = '40'  -- 00:정상, 40: 부적합
                             , I001.FNL_JDGM           =  V_FNL_JDGM 
                             , I001.MSRM_DATE          =  TO_DATE(V_NEW_MSRM_DT,'YYYY-MM-DD HH24:MI:SS')
                             , I001.PRC_SEQNO          =  i + 1
                             , I001.INSPR_ID           =  V_SESS_USER_ID
                             , I001.UPDDATE            =  SYSDATE
                             , I001.UPDID              =  V_SESS_USER_ID                                 
                         WHERE ( I001.WERKS            =  V_WERKS
                           AND   I001.STOR_LOC_CD      =  V_STOR_LOC_CD
                           AND   I001.IND_BCD          =  V_IND_BCD
                           AND   I001.MATNR            =  V_MATNR );
                        EXCEPTION           
                        WHEN OTHERS THEN 
                              P_SUCCESS           := 'N';
                              E_SQL_ERR_CD        := -20000;
                              E_SQL_ERR_MSG       := SQLCODE || ': EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';
                              ROLLBACK;

                              SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
                              RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);           
                              RETURN;           
                     END; 

                     BEGIN 
                        SELECT NVL(COUNT(*),0)
                          INTO V_Q024_CNT
                          FROM TB_QLT024 Q024
                         WHERE Q024.INSP_ITEM_GRP_CD   =  V_INSP_ITEM_GRP_CD
                           AND Q024.MATNR              =  V_MATNR
                           AND Q024.WERKS              =  V_WERKS
                           AND Q024.MSRM_DATE          =  TO_DATE(V_MSRM_DT, 'YYYY-MM-DD HH24:MI:SS')
                           AND Q024.PRC_SEQNO          =  V_PRC_SEQNO;
                     EXCEPTION           
                     WHEN OTHERS THEN 
                           P_SUCCESS           := 'N';
                           E_SQL_ERR_CD        := -20000;
                           E_SQL_ERR_MSG       := SQLCODE || ': EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';
                           ROLLBACK;

                           SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
                           RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);           
                           RETURN;           
                     END; 

                     IF  V_Q024_CNT = 0 THEN

                         BEGIN
                            INSERT INTO TB_QLT024(
                                    INSP_ITEM_GRP_CD,
                                    MATNR,
                                    WERKS,
                                    MSRM_DATE,
                                    PRC_SEQNO,
                                    PRC_MTD,
--                                            UCFMTY_AMT,
                                    FNL_JDGM,
                                    RMK,
                                    LOT_NO,
                                    IND_BCD,
                                    STOR_LOC_CD,
                                    REGDATE,
                                    REGID
                            ) VALUES (
                                    V_INSP_ITEM_GRP_CD,
                                    V_MATNR,
                                    V_WERKS,
                                    TO_DATE(V_NEW_MSRM_DT,'YYYY-MM-DD HH24:MI:SS'),
                                    i + 1,
                                    V_PRC_MTD,
--                                            NVL(V_UCFMTY_AMT, 0),
                                    V_FNL_JDGM,
                                    V_RMK,
                                    V_LOT_NO,
                                    V_IND_BCD,
                                    NULL,  -- 부적합창고로 강제로 보낸다.
                                    SYSDATE,
                                    V_SESS_USER_ID
                                ); 
                         EXCEPTION           
                         WHEN OTHERS THEN 
                               P_SUCCESS           := 'N';
                               E_SQL_ERR_CD        := -20000;
                               E_SQL_ERR_MSG       := SQLCODE || ': EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';
                               ROLLBACK;

                               SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
                               RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);           
                               RETURN;           
                         END; 

                     ELSE
                         BEGIN

                            INSERT INTO TB_QLT024(
                                    INSP_ITEM_GRP_CD,
                                    MATNR,
                                    WERKS,
                                    MSRM_DATE,
                                    PRC_SEQNO,
                                    PRC_MTD,
--                                            UCFMTY_AMT,
                                    FNL_JDGM,
                                    RMK,
                                    LOT_NO,
                                    IND_BCD,
                                    STOR_LOC_CD,
                                    REGDATE,
                                    REGID
                            ) VALUES (
                                    V_INSP_ITEM_GRP_CD,
                                    V_MATNR,
                                    V_WERKS,
                                    TO_DATE(V_NEW_MSRM_DT,'YYYY-MM-DD HH24:MI:SS'),
                                    i + 1,
                                    V_PRC_MTD,
--                                            NVL(V_UCFMTY_AMT, 0),
                                    V_FNL_JDGM,
                                    V_RMK,
                                    V_LOT_NO,
                                    V_IND_BCD,
                                    NULL,  -- 부적합창고로 강제로 보낸다.
                                    SYSDATE,
                                    V_SESS_USER_ID
                                ); 
                         EXCEPTION           
                         WHEN OTHERS THEN 
                               P_SUCCESS           := 'N';
                               E_SQL_ERR_CD        := -20000;
                               E_SQL_ERR_MSG       := SQLCODE || ': EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';
                               ROLLBACK;

                               SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
                               RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);           
                               RETURN;           
                         END; 

                     END IF;

                     IF V_STCK_STA = '80' THEN     

                        BEGIN
                            SELECT  W015.DOC_NO     
                                  , W015.DOC_SEQNO  
                                  , W015.DLFL       
                                  , W015.WERKS      
                                  , W015.MATNR      
                                  , W015.QTY        
                                  , W015.UNIT       
                                  , W015.STOR_LOC_FR
                                  , W015.STOR_LOC_TO
                                  , W015.IND_BCD    
                                  , W015.LOT_NO     
                                  , W015.MACHINE    
                                  , W015.ORDER_NO   
                                  , W015.ORDER_SEQNO
                                  , W015.PCODE      
                                  , W015.BS_WGT     
                                  , W015.WLEN       
                                  , W015.VLEN       
                                  , W015.CON_TYPE   
                                  , W015.PACKTYPE   
                                  , W015.VBELN      
                                  , W015.POSNR      
                                  , W015.SAUART     
                                  , W015.KUNNR      
                                  , W015.CORE       
                                  , W015.EMPLY_NO   
                                  , W015.EMPLY_NM   
                                  , W015.NTN_CD     
                                  , W015.PRD_DT     
                                  , W015.RCVGDS_DT  
                                  , W015.DSTBT_DDLIN
                                  , W015.STCK_NO
                            INTO    V_DOC_NO_1     
                                  , V_DOC_SEQNO_1  
                                  , V_DLFL       
                                  , V_WERKS      
                                  , V_MATNR      
                                  , V_QTY        
                                  , V_UNIT       
                                  , V_STOR_LOC_FR
                                  , V_STOR_LOC_TO
                                  , V_IND_BCD    
                                  , V_LOT_NO     
                                  , V_MACHINE    
                                  , V_ORDER_NO   
                                  , V_ORDER_SEQNO
                                  , V_PCODE      
                                  , V_BS_WGT     
                                  , V_WLEN       
                                  , V_VLEN       
                                  , V_CON_TYPE   
                                  , V_PACKTYPE   
                                  , V_VBELN      
                                  , V_POSNR      
                                  , V_SAUART     
                                  , V_KUNNR      
                                  , V_CORE       
                                  , V_EMPLY_NO   
                                  , V_EMPLY_NM   
                                  , V_NTN_CD     
                                  , V_PRDC_DT     
                                  , V_RCVGDS_DT  
                                  , V_DSTBT_DDLIN
                                  , V_STCK_NO                              
                            FROM TB_WRK015 W015,        
                                  (SELECT W015.WERKS, W015.DOC_NO, W015.DLFL, TO_NUMBER(MAX(W015.DOC_SEQNO)) AS MAX_DOC_SEQNO  
                                    FROM  TB_WRK015 W015 
                                   WHERE W015.WERKS     = V_WERKS 
                                     AND W015.IND_BCD   = V_IND_BCD
                                     AND W015.LOT_NO    = V_LOT_NO
                                     AND W015.DLFL      = 'C'
                                GROUP BY  W015.WERKS, W015.DOC_NO, W015.DLFL ) W015_MAX
                            WHERE W015.DOC_NO    = W015_MAX.DOC_NO
                              AND W015.DOC_SEQNO = W015_MAX.MAX_DOC_SEQNO
                              AND W015.DLFL      = W015_MAX.DLFL; 

                        EXCEPTION
                            WHEN NO_DATA_FOUND THEN
                                 NULL;
                        END;

                         -- 실적 테이블의 재고상태 및 입고 요청정보를 수정한다.(2022-08-07) 
                        BEGIN
                            UPDATE TB_WRK001 W001
                               SET W001.CHK_QC_YN          =  'N'   -- 입고요청정보를 N으로 변경한다.
                                 , W001.UPDDATE            =  SYSDATE
                                 , W001.UPDID              =  V_SESS_USER_ID                                 
                             WHERE ( W001.WERKS            =  V_WERKS
                               AND  W001.MACH_CD           =  V_MACH_CD
                               AND  W001.IND_BCD           =  V_IND_BCD  );
                            EXCEPTION           
                            WHEN OTHERS THEN 
                                  P_SUCCESS           := 'N';
                                  E_SQL_ERR_CD        := -20000;
                                  E_SQL_ERR_MSG       := SQLCODE || ': EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';
                                  ROLLBACK;

                                  SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
                                  RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);           
                                  RETURN;           
                        END;

                        -- 부적합인 완제품이 입고 요청상태라면 "출고요청 취소"를 전송한다.
                        BEGIN
                        INSERT INTO TB_IFSWM005 ( 
                            DOC_NO, DOC_SEQNO, DLFL,
                            WERKS,  MATNR,     QTY,    UNIT,    STOR_LOC_FROM, STOR_LOC_TO,
                            IND_BCD,           LOT_NO, MACHINE, ORDER_NO,      ORDER_SEQNO,
                            PCODE,          --지종
                            WEIGHT,          --평량
                            WLEN,
                            VLEN,
                            CON_TYPE,
                            PACK_TYPE,
                            OVBELN,         --판매문서번호
                            OPOSNR,         --판매문서 항목번호
                            SAUART,         --판매문서유형
                            KUNNR,          --판매처
                            CORE,           --지관
                            EMPLY_NO,
                            EMPLY_NM,
                            NTN_CD,         --국가코드
                            PRDC_DT,        --제조일자 
                            RCVGDS_DT,      --입고일자
                            DSTBT_DDLIN,    --유통기간
                            STCK_NO,       --특별재고번호(판매문서번호 + 판매문서 항목번호)
                            IF_GET_DATE
                            )
                        VALUES( V_DOC_NO_1, V_DOC_SEQNO_1, 'D',
                            V_WERKS, V_MATNR, V_QTY, V_UNIT, '3000', '3100',
                            V_IND_BCD, V_LOT_NO, V_MACHINE, V_ORDER_NO, V_ORDER_SEQNO,
                            V_PCODE,
                            V_BS_WGT,
                            V_WLEN,
                            V_VLEN,
                            V_CON_TYPE,
                            V_PACKTYPE,
                            V_VBELN,         --판매문서번호
                            V_POSNR,         --판매문서 항목번호
                            V_SAUART,        --판매문서유형
                            V_KUNNR,         --판매처
                            V_CORE,          --지관
                            V_EMPLY_NO,
                            V_EMPLY_NM,
                            V_NTN_CD,        --국가코드
                            V_PRDC_DT,       --제조일자 
                            V_RCVGDS_DT,     --입고일자
                            V_DSTBT_DDLIN,   --유통기간
                            V_STCK_NO,       --특별재고번호(판매문서번호 + 판매문서 항목번호)
                            SYSDATE
                            );

                        EXCEPTION           
                        WHEN OTHERS THEN 
                               P_SUCCESS           := 'N';
                               E_SQL_ERR_CD        := -20000;
                               E_SQL_ERR_MSG       := SQLCODE || ': EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';
                               ROLLBACK;

                               SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
                               RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);           
                               RETURN;           
                        END;
                        P_DOC_NO1   := V_DOC_NO_1;

                     ELSIF V_STCK_STA = '70' THEN  -- WMS로 입고 완료된 건이라면.. 
                           -- 이미 WMS 창고로 입고가 되었다면 순회 외관검사 결과를 WMS로 보낸다.   
                           INSERT INTO TB_IFSWM007 (
                                    DOC_NO,
                                    DOC_SEQNO,
                                    WERKS,
                                    MATNR,
                                    QTY,
                                    UNIT,
                                    STOR_LOC,
                                    STCK_STA,
                                    IND_BCD,
                                    LOT_NO,
                                    CHKRST,
                                    QTYGOD,
                                    QTYBAD,
                                    BADRSN,
                                    STOK_KY,
                                    LOT_NUM,
                                    IF_STATUS,
                                    IF_GET_DATE,
                                    IF_SET_DATE,
                                    IF_ERR_MESS,
                                    IF_MES_KEY
                            ) VALUES (
                                    V_DOC_NO,
                                    V_DOC_SEQNO,
                                    V_WERKS,
                                    V_MATNR,
                                    V_STCK_QTY,
                                    V_UNIT,
                                    V_STOR_LOC_CD,
                                    '40',
                                    V_IND_BCD,
                                    V_LOT_NO,
                                    'QR',
                                    V_STCK_QTY - V_UCFMTY_AMT,
                                    V_UCFMTY_AMT,
                                    V_BADRSNNM,
                                    V_STCK_KY,
                                    V_LOT_NUM,
                                    'N',
                                    SYSDATE,
                                    NULL,
                                    ' ',
                                    ' ' 
                            );      

                            P_DOC_NO2   := V_DOC_NO;

                     END IF;

--                   -- 공정창고 재고를 양품 - 부적합품 양으로 산정 
--                    BEGIN
--                        UPDATE TB_INV001 I001
--                           SET I001.STCK_STA           = '40'  -- 00:정상, 40: 부적합
--                             , I001.STCK_QTY           =  I001.STCK_QTY - V_UCFMTY_AMT -- 부적합이 있으면 재고에 차감한다.(기본단위로 입력한다는 전재)
----                                 , I001.PLT_QTY            =  FN_CHG_UNIT(V_MATNR, V_WERKS, V_UNIT, 'PAL', I001.STCK_QTY  - V_UCFMTY_AMT)
----                                 , I001.BOX_QTY            =  FN_CHG_UNIT(V_MATNR, V_WERKS, V_UNIT, 'BOX', I001.STCK_QTY  - V_UCFMTY_AMT)
----                                 , I001.BAG_QTY            =  FN_CHG_UNIT(V_MATNR, V_WERKS, V_UNIT, 'BAG', I001.STCK_QTY  - V_UCFMTY_AMT)
----                                 , I001.EA_QTY             =  FN_CHG_UNIT(V_MATNR, V_WERKS, V_UNIT, 'EA', I001.STCK_QTY  - V_UCFMTY_AMT)
----                                 , I001.WGT                =  FN_CHG_UNIT(V_MATNR, V_WERKS, V_UNIT, 'KG', I001.STCK_QTY  - V_UCFMTY_AMT)
--                             , I001.UCFMTY_AMT         =  V_UCFMTY_AMT
--                             , I001.UCFMTY_FLG         = 'Y'
--                             , I001.FNL_JDGM           =  V_FNL_JDGM 
--                             , I001.MSRM_DATE          =  TO_DATE(V_MSRM_DT,'YYYY-MM-DD HH24:MI:SS')
--                             , I001.PRC_SEQNO          =  i + 1
--                             , I001.INSPR_ID           =  V_SESS_USER_ID
--                             , I001.UPDDATE            =  SYSDATE
--                             , I001.UPDID              =  V_SESS_USER_ID                                 
--                         WHERE ( I001.WERKS               =  V_WERKS
--                           AND  I001.STOR_LOC_CD          =  V_STOR_LOC_CD
--                           AND  I001.IND_BCD              =  V_IND_BCD
--                           AND  I001.MATNR                =  V_MATNR );
--                        EXCEPTION           
--                        WHEN OTHERS THEN 
--                              P_SUCCESS           := 'N';
--                              E_SQL_ERR_CD        := -20000;
--                              E_SQL_ERR_MSG       := SQLCODE || ': EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';
--                              ROLLBACK;
--
--                              SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
--                              RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);           
--                              RETURN;           
--                    END; 

                ELSE 
                     -- 최종 판정이 적합이면....
                     BEGIN
                        UPDATE TB_INV001 I001
                           SET STCK_STA                = '00'  -- 00:정상, 40: 부적합
                             , I001.FNL_JDGM           =  V_FNL_JDGM 
                             , MSRM_DATE               =  TO_DATE(V_NEW_MSRM_DT,'YYYY-MM-DD HH24:MI:SS')
                             , I001.PRC_SEQNO          =  i + 1
                             , INSPR_ID                =  V_SESS_USER_ID
                             , UPDDATE                 =  SYSDATE
                             , UPDID                   =  V_SESS_USER_ID          
                         WHERE (I001.WERKS          =  V_WERKS
                           AND  I001.STOR_LOC_CD    =  V_STOR_LOC_CD
                           AND  I001.IND_BCD        =  V_IND_BCD
                           AND  I001.MATNR          =  V_MATNR );
                        EXCEPTION           
                        WHEN OTHERS THEN 
                              P_SUCCESS           := 'N';
                              E_SQL_ERR_CD        := -20000;
                              E_SQL_ERR_MSG       := SQLCODE || ': EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';
                              ROLLBACK;

                              SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
                              RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);           
                              RETURN;           
                   END; 

                   IF  V_UCFMTY_YN = 'Y' THEN
                       -- 이전에 최종판정 결과가 부적합이었다면 합격이므로 삭제한다. 
                       BEGIN
                           DELETE  FROM TB_QLT024 Q024  
                            WHERE ( Q024.INSP_ITEM_GRP_CD   =  V_INSP_ITEM_GRP_CD
                              AND   Q024.MATNR              =  V_MATNR
                              AND   Q024.WERKS              =  V_WERKS
                              AND   Q024.MSRM_DATE          =  TO_DATE(V_MSRM_DT,'YYYY-MM-DD HH24:MI:SS')
                              AND   Q024.PRC_SEQNO          =  V_PRC_SEQNO );   
                      EXCEPTION           
                      WHEN OTHERS THEN 
                               P_SUCCESS           := 'N';
                               E_SQL_ERR_CD        := -20000;
                               E_SQL_ERR_MSG       := SQLCODE || ': EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';
                               ROLLBACK;

                               SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
                               RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);           
                               RETURN;           
                      END;             

                   END IF;
--
--                     -- 실적 테이블의 재고상태 및 입고 요청정보를 수정한다.(2022-08-07) 
--                    BEGIN
--                        UPDATE TB_WRK001 W001
--                           SET W001.STA                =  '00'  -- 00:정상, 40: 부적합
--                             , W001.UPDDATE            =  SYSDATE
--                             , W001.UPDID              =  V_SESS_USER_ID                                 
--                         WHERE ( W001.WERKS            =  V_WERKS
--                           AND  W001.MACH_CD           =  V_MACH_CD
--                           AND  W001.IND_BCD           =  V_IND_BCD  );
--                    EXCEPTION           
--                    WHEN OTHERS THEN 
--                              P_SUCCESS           := 'N';
--                              E_SQL_ERR_CD        := -20000;
--                              E_SQL_ERR_MSG       := SQLCODE || ': EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';
--                              ROLLBACK;
--
--                              SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
--                              RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);           
--                              RETURN;           
--                   END; 

                END IF;               

        END LOOP;

    END IF;

    P_SUCCESS := 'Y';

    COMMIT;

    EXCEPTION
    WHEN E_EXCEPTION_USER THEN

        -- 에러 내역 SET
	    P_SUCCESS           := 'N';
        E_SQL_ERR_CD        := -20000;
       	E_SQL_ERR_MSG       := SQLCODE || ': EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';
        SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);

        ROLLBACK;

    WHEN OTHERS THEN
	    P_SUCCESS           := 'N';
        E_SQL_ERR_CD        := -20000;
		E_SQL_ERR_MSG       := SQLCODE || ': EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';
        SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);

        ROLLBACK;
        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
END

;

/
