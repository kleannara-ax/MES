--------------------------------------------------------
--  DDL for Procedure SP_QLT13_S01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_QLT13_S01" (
	P_TYPE           IN    varchar2, -- LIST, SUB_LIST, SUB_SAVE
	P_JSON_STR       IN    CLOB,
    P_WDOC_NO       OUT    varchar2,
	P_SUCCESS       OUT    varchar2,
	P_RS_LIST       OUT    SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : QLT13{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 품질검사(출하반품검사)등록(검사 항목별 기준값 관리{호출 프로그램 명 기술}
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 품질검사(출하반품검사)결과값을 관리한다.{프로그램에 대한 상세한 내용 기술}
 *                 
 * AUTHOR NAME   : 김성하{최초 작성자 명 기술}
 * CREATE DATE   : 2022/05/23 {최초 작성일자 기술}
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
 *       - [TB_QLT001]  : (.RU.) 출하반품 검사대상정보(WMS->MES)                                
 *       - [TB_QLT020]  : (CRUD) 검사항목별 판정결과 등록 마스트                              
 *       - [TB_QLT021]  : (CRUD) 검사항목별 판정결과 정보                                
 *       - [TB_QLT022]  : (CRUD) 검사항목별 판정결과 세부정보
 *       - [TB_QLT023]  : (C...) 검사항목별 판정결과 변경이력
 *       - [TB_QLT024]  : (C...) 부적합 발생이력
 *       - [TB_IFSWM006]: (C...) 품질검사(출하반품검사 결과)(MES -> WMS) 
 *=============================================================================*/

AS

    V_PRG_NM          VARCHAR2(100)  := 'SP_QLT13_S01';     -- PROCEDURE NAME

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

    V_OBJ_HEAD_H       JSON_OBJECT_T;
    V_OBJ_LIST_L       JSON_OBJECT_T;

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
    V_MATNR            VARCHAR2(4000); -- 자재코드
    V_MATNR_NM         TB_MAS001.MATNR_NM%TYPE; -- 자재명
    V_MATNR_GRP_CD     TB_MAS001.MATNR_GRP_CD%TYPE; -- 자재그룹
    V_INSP_YN          VARCHAR2(1);          -- 등록여부
    V_CUST_CD           TB_QLT001.CRSPD_CD%TYPE;    --거래처코드
    V_MSRM_CYC         TB_MAS014.MSRM_CYC%TYPE; --측정주기

    -- 리스트(그리드)의 값을 할당하기 위한 변수선언 영역        
    V_INSP_ITEM_GRP_CD TB_MAS015.INSP_ITEM_GRP_CD%TYPE; 
    V_INSP_ITEM_CD     TB_MAS016.INSP_ITEM_CD%TYPE;

    V_STD_VAL          TB_MAS016.STD_VAL%TYPE;
    V_UPP_VAL          TB_MAS016.UPP_VAL%TYPE;
    V_LOW_VAL          TB_MAS016.LOW_VAL%TYPE;
    V_STD_SEL          TB_MAS016.STD_SEL%TYPE;
    V_INSP_STD_1       TB_MAS016.INSP_STD_1%TYPE;
    V_INSP_STD_2       TB_MAS016.INSP_STD_2%TYPE;

    V_ORDER_NO         TB_QLT001.ORDER_NO%TYPE;
    V_ORDER_SEQNO      TB_QLT001.ORDER_SEQNO%TYPE;
    V_RCVGDS_QTY       TB_QLT001.RCVGDS_QTY%TYPE;
    V_UNIT             TB_QLT001.UNIT%TYPE;
    V_STOR_KY          TB_QLT001.STOR_KY%TYPE;
    V_STOR_LOC_CD      TB_QLT001.STOR_LOC_CD%TYPE;
    V_SUPY_CD          TB_QLT001.SUPY_CD%TYPE; 
    V_STCK_STA         TB_QLT001.STCK_STA%TYPE;
    V_NTN_CD           TB_QLT001.NTN_CD%TYPE;
    V_CRSPD_CD         TB_QLT001.CRSPD_CD%TYPE;
    V_PRDC_DT          TB_QLT001.PRDC_DT%TYPE;
    V_RCVGDS_DT        TB_QLT001.RCVGDS_DT%TYPE;
    V_DSTBT_DDLIN      TB_QLT001.DSTBT_DDLIN%TYPE;
    V_IND_BCD          TB_QLT001.IND_BCD%TYPE;
    V_LOT_NUM          TB_QLT001.LOT_NUM%TYPE;

    V_MSRM_DATE        TB_QLT020.MSRM_DATE%TYPE;
    V_MSRM_DT          VARCHAR2(21) := '';
    V_NEW_MSRM_DT      VARCHAR2(21) := '';
    
    V_SDATE            VARCHAR2(30);
    V_EDATE            VARCHAR2(30);

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
    V_PRC_DIV          TB_QLT020.PRC_DIV%TYPE;

    V_DOC_NEW_NO       TB_QLT020.DOC_NO%TYPE;
    V_DOC_NEW_SEQNO    TB_QLT020.DOC_SEQNO%TYPE;


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
  --  V_REG_ID           TB_QLT024.REG_ID%TYPE;

--    V_CHKRST           TB_IFSWM001.CHKRST%TYPE; --검사진행상태(QR:품질검사완료, QF:상태변경완료)
--    V_QTYGOD           TB_IFSWM001.QTYGOD%TYPE; --정상수량
--    V_QTYBAD           TB_IFSWM001.QTYBAD%TYPE; --불량수량(시료량)
    V_BADRSN           TB_IFSWM006.BADRSN%TYPE; --불량사유(???)
--
--    V_QTY              TB_IFSWM006.QTY%TYPE;              
--    V_STOR_LOC         TB_IFSWM001.STOR_LOC%TYPE;
--    V_STOK_KY          TB_IFSWM006.STOK_KY%TYPE;
--    V_LOT_NUM          TB_IFSWM006.LOT_NUM%TYPE;
    V_LOT_NO           TB_IFSWM006.LOT_NO%TYPE;
--    V_BADRSNNM         TB_IFSWM001.BADRSNNM%TYPE;
 
    --기타처리
    V_Q020_CNT         NUMBER   := 0;
    V_I001_CNT         NUMBER   := 0;
    V_CHG_ACC          NUMBER   := 0;

BEGIN
   OPEN P_RS_LIST FOR 
   SELECT NULL FROM DUAL WHERE ROWNUM = 0;

   V_DEBUG   := 'N';
   V_RUN_SQL := 'Y';

   V_JSON               :=       JSON_OBJECT_T.parse(P_JSON_STR);

   V_SESS_USER_ID       :=       V_JSON.get_string('SES_USER_ID');
   V_PLT_CD             :=       V_JSON.get_string('SES_WAREKY');

   /* 조건값 할당 */
   V_RANGE_SQL          :=       V_JSON.get_string('RANGE_SQL'); -- 플랜트코드, 자재그룹, 자재코드

   V_WERKS              :=       V_JSON.get_string('WERKS');     -- 플랜트코드
   V_MATNR_NM           :=       V_JSON.get_string('MATNR_NM');     -- 자재명 
   V_INSP_YN            :=       V_JSON.get_string('INSP_YN');   -- 검사여부
   V_INSP_ITEM_GRP_CD   :=       V_JSON.get_string('INSP_ITEM_GRP_CD'); -- 검사항목그룹
   V_MATNR              :=       V_JSON.get_string('MATNR');            -- 자재코드
   V_SDATE              :=       V_JSON.get_string('SDATE');     -- 측정일시(시작)
   V_EDATE              :=       V_JSON.get_string('EDATE');     -- 측정일시(끝)


   IF P_TYPE = 'LIST' THEN /*상단 조회 리스트*/

      V_SQL := '  SELECT Q001.VGBEL        AS "VGBEL"           --WMS 참조번호
                       , Q001.VGPOS        AS "VGPOS"           --WMS 참조아이템
                       , Q001.REQ_DIV      AS "REQ_DIV"         --요청구분
                       , Q001.REQ_DATE     AS "REQ_DATE"        --요청일시(반품일시)
                       , Q001.REQ_ID       AS "REQ_ID"          --요청자
                       , Q001.WERKS        AS "WERKS"           --플랜트
                       ,(SELECT PLANTNM FROM TB_MAS002 WHERE WERKS = Q001.WERKS) AS "PLANTNM"                       
                       , Q001.STOR_KY      AS "STOR_KY"         --저장키
                       , Q001.STOR_LOC_CD  AS "STOR_LOC_CD"     --저장위치
                       , Q001.VND_LOT_NO   AS "VND_LOT_NO"      --공급업체 LOT_NO 
                       , Q001.IND_BCD      AS "SUPY_VND_BCD"    --공급업체 바코드
                       , Q001.ORDER_NO     AS "ORDER_NO"
                       , Q001.ORDER_SEQNO  AS "ORDER_SEQNO"
                       , Q001.MATNR        AS "MATNR"           --자재코드
                       , M001.MATNR_NM     AS "MATNR_NM"        --자재명                      
                       , Q001.UNIT         AS "UNIT"            --단위(HIDDEN)
                       ,(SELECT CDESC1 FROM CMCDV WHERE CMCDKY = ''UNIT''      AND CMCDVL = Q001.UNIT) AS "UNIT_NM"
                       , Q001.RCVGDS_QTY   AS "RCVGDS_QTY"      --반품량
                       , Q001.STCK_STA     AS "STCK_STA"        --재고상태(00정상  10보류 20합격 30불합격 05검사대기 50폐기)
                       ,(SELECT CDESC1 FROM CMCDV WHERE CMCDKY = ''STCK_STA''  AND CMCDVL = Q001.STCK_STA) AS "STCK_STA_NM"
                       , Q001.NTN_CD       AS "NTN_CD"          --국가
                       ,(SELECT CDESC1 FROM CMCDV WHERE CMCDKY = ''NTN_CD''    AND CMCDVL = Q001.NTN_CD) AS "NTN_NM"
                       , Q001.SUPY_CD      AS "SUPY_CD"         --공급처(M009 V)
                       ,(SELECT CUST_NM FROM TB_MAS009 WHERE CUST_DIV = ''V'' AND CUST_CD = Q001.SUPY_CD) AS "SUPY_NM"                       
                       , Q001.CRSPD_CD     AS "CUST_CD"         --거래처(M009 C)
                       ,(SELECT CUST_NM FROM TB_MAS009 WHERE CUST_DIV = ''C'' AND CUST_CD = Q001.CRSPD_CD) AS "CUST_NM"                                              
                       , Q001.PRDC_DT      AS "PRDC_DT"
                       , Q001.RCVGDS_DT    AS "RCVGDS_DT"
                       , Q001.DSTBT_DDLIN  AS "DSTBT_DDLIN"
                       , Q001.LOT_NUM      AS "LOT_NUM"
                       , Q001.INSPR_ID     AS "INSPR_ID" -- 검사자
                       , NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = Q001.INSPR_ID),'''') AS "INSPR_NM"
                       , Q001.INSP_DATE    AS "INSP_DATE"
                       , Q001.INSP_YN      AS "INSP_YN"
                       , Q020.PRC_DIV      AS "PRC_DIV"   --처리구분(H)
                       ,(SELECT CDESC1 FROM CMCDV WHERE CMCDKY = ''PRC_DIV''  AND CMCDVL = Q020.PRC_DIV) AS "PRC_DIV_NM"
                       , Q020.UCFMTY_AMT   AS "UCFMTY_AMT"
                       , Q020.INSP_ITEM_GRP_CD  AS "INSP_ITEM_GRP_CD"  --HIDDEN 
                       , Q020.MSRM_DATE         AS "MSRM_DATE"         --HIDDEN
                       , NVL(Q020.PRC_SEQNO,0)  AS "PRC_SEQNO"         --처리순번(H)
                       , Q020.DOC_NO            AS "DOC_NO"            --HIDDEN
                       , Q020.DOC_SEQNO         AS "DOC_SEQNO"         --HIDDEN
                       , DECODE(Q024.MSRM_DATE, NULL, ''N'', '' '', ''N'', ''Y'')         AS "UCFMTY_YN"         -- HIDDEN(부적합 결과 존재유무)
					   , (SELECT COUNT(*) FROM TB_MAS015 MAS015 WHERE MAS015.WERKS = M001.WERKS AND MAS015.MATNR = M001.MATNR AND MAS015.INSP_ITEM_GRP_CD = ''C2'') AS CHK_CNT --출하검사 기준 등록 여부 
                    FROM TB_QLT001 Q001,
                         TB_MAS001 M001,
                         TB_QLT020 Q020,
                         TB_QLT024 Q024
                   WHERE Q001.WERKS        = M001.WERKS(+)
                     AND Q001.MATNR        = M001.MATNR(+)
                     AND Q001.VGBEL        = Q020.VGBEL(+)                     
                     AND Q001.VGPOS        = Q020.VGPOS(+)
                     AND Q001.REQ_DIV      = Q020.REQ_DIV(+)
                     AND Q020.MSRM_DATE    = Q024.MSRM_DATE(+)
                     AND Q020.PRC_SEQNO    = Q024.PRC_SEQNO(+)
                     AND Q001.DLFL         <> ''D''
                     AND M001.MATNR_DIV    IN (''FERT'', ''HAWA'')
                     AND Q001.REQ_DIV      = ''03'' ' ;

        IF  V_WERKS IS NOT NULL OR TRIM(V_WERKS) != '' THEN -- 플랜트
            V_SQL := V_SQL || ' AND Q001.WERKS  = ''' || V_WERKS || '''';             
        END IF;

        IF  V_RANGE_SQL IS NOT NULL OR TRIM(V_RANGE_SQL) != '' THEN
            V_SQL := V_SQL || V_RANGE_SQL;
        END IF;                     

        IF  ( V_SDATE IS NOT NULL OR TRIM(V_SDATE) != '' ) AND (V_EDATE IS NOT NULL OR TRIM(V_EDATE) != '')THEN -- 반품일시
            V_SQL := V_SQL || ' AND Q001.REQ_DATE >= TO_DATE(''' || V_SDATE || ''',''YYYY-MM-DD HH24:MI:SS'') AND Q001.REQ_DATE < TO_DATE(''' || V_EDATE || ''',''YYYY-MM-DD HH24:MI:SS'') + 1';  
        END IF;

        IF  V_MATNR IS NOT NULL OR TRIM(V_MATNR) != '' THEN -- 자재코드
            V_SQL := V_SQL || ' AND REGEXP_LIKE(Q020.MATNR, ''' || V_MATNR || ''') ';
        END IF; 
        
        IF  V_CUST_CD IS NOT NULL OR TRIM(V_CUST_CD) != '' THEN -- 거래처코드
            V_SQL := V_SQL || ' AND REGEXP_LIKE(Q001.CRSPD_CD, ''' || V_CUST_CD || ''') ';
        END IF; 

--        IF  V_INSP_YN IS NOT NULL OR TRIM(V_INSP_YN) != '' THEN -- 검사여부
--            V_SQL := V_SQL || ' AND DECODE(Q001.INSP_YN, NULL, ''N'', ''Y'') = '''|| TRIM(V_INSP_YN) || '''';
--        END IF;

		V_SQL := V_SQL || ' ORDER BY Q001.REQ_DATE';

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
        V_VGBEL              := V_JSON.get_string('VGBEL'); 
        V_VGPOS              := V_JSON.get_string('VGPOS');
        V_REQ_DIV            := V_JSON.get_string('REQ_DIV');
        V_MSRM_DATE          := V_JSON.get_date('MSRM_DATE');
        V_PRC_SEQNO          := V_JSON.get_number('PRC_SEQNO');
        V_MSRM_CYC           := V_JSON.get_string('MSRM_CYC');

        V_MSRM_DT            := V_JSON.get_string('MSRM_DATE');

        V_SQL :=  ' SELECT A.INSP_ITEM_GRP_CD,
                           A.INSP_ITEM_CD,
                           A.INSP_ITEM_NM,
                           A.PROD_GRP_CD,
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
                       WHERE  M014.INSP_ITEM_GRP_CD = ''C2''
                         AND  M014.PROD_GRP_CD  = FN_GET_PROD_GRP( '''|| V_WERKS || ''','''|| V_MATNR ||''' ) ';
                         IF V_MSRM_CYC IS NOT NULL OR TRIM(V_MSRM_CYC) != '' THEN
                            V_SQL := V_SQL || 'AND M014.MSRM_CYC = ''' || V_MSRM_CYC || ''' ';
                         END IF;
                         V_SQL := V_SQL || ') A, -- 수입검사 항목만 표시
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
                                WHERE INSP_ITEM_GRP_CD = ''C2''
                                  AND MATNR      = '''|| V_MATNR ||''' 
                                  AND WERKS      = '''|| V_WERKS ||''') B,
                              (SELECT Q021.INSP_ITEM_GRP_CD, Q021.MATNR, Q021.WERKS, Q021.INSP_ITEM_CD, Q021.RST_VAL, Q021.RST_SEL, Q021.RST_TXT, Q021.RMK, Q021.FIT_YN, Q021.INSP_REP_YN, Q021.REGID, Q021.REGDATE, 
                                      Q021.UUID, SYSF.RPATH, SYSF.NAME, SYSF.FNAME 
                                 FROM TB_QLT021 Q021, SYSFILE SYSF 
                                WHERE Q021.UUID             = SYSF.UUID(+) 
                                  AND Q021.INSP_ITEM_GRP_CD = ''C2'' 
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
                    ORDER BY A.BIG_CAT_NM, A.MID_CAT_NM, A.DISP_SEQ ';

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
        V_SMPL_AMT           := V_JSON.get_number('SMPL_AMT');         /*시료량*/
        V_FNL_JDGM           := V_JSON.get_string('FNL_JDGM');         /*최종판정*/   

        V_DOC_NEW_NO         := FN_GET_MDOCNO(V_PLT_CD, 'MES_IF_901'); /*WMS 전송 문서번호 생성*/

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
                V_VGBEL              := V_OBJ_HEAD.get_string('VGBEL');
                V_VGPOS              := V_OBJ_HEAD.get_string('VGPOS');
                V_ORDER_NO           := V_OBJ_HEAD.get_string('ORDER_NO');
                V_ORDER_SEQNO        := V_OBJ_HEAD.get_string('ORDER_SEQNO');
                V_UNIT               := V_OBJ_HEAD.get_string('UNIT');
                V_STOR_KY            := V_OBJ_HEAD.get_string('STOR_KY');          /*저장키*/
                V_STOR_LOC_CD        := V_OBJ_HEAD.get_string('STOR_LOC_CD');      /*저장위치*/
                V_VND_LOT_NO         := V_OBJ_HEAD.get_string('VND_LOT_NO');       /*공급업체 LOTNO*/    
                V_SUPY_VND_BCD       := V_OBJ_HEAD.get_string('SUPY_VND_BCD');     /*공급업체 바코드(IND_BCD)*/ 
                V_SUPY_CD            := V_OBJ_HEAD.get_string('SUPY_CD');          /*공급업체코드*/
                V_MSRM_DATE          := V_OBJ_HEAD.get_date('MSRM_DATE');          /*측정일시*/
                V_LOT_NUM            := V_OBJ_HEAD.get_string('LOT_NUM');          /*WMS 입고LOT번호*/
                V_DOC_NO             := V_OBJ_HEAD.get_string('DOC_NO');           /*MES 문서번호*/
                V_DOC_SEQNO          := V_OBJ_HEAD.get_number('DOC_SEQNO');        /*MES 문서순번*/

                V_MSRM_DT            := V_OBJ_HEAD.get_string('MSRM_DATE');
                V_REQ_DIV            := V_OBJ_HEAD.get_string('REQ_DIV');          /*요청구분*/   
                V_RCVGDS_QTY         := V_OBJ_HEAD.get_number('RCVGDS_QTY');       /*입고수량*/
       	 	    V_UCFMTY_AMT         := V_OBJ_HEAD.get_number('UCFMTY_AMT');       /*부적합량*/
                V_RCVGDS_DT          := V_OBJ_HEAD.get_string('RCVGDS_DT');     --입고일자
                V_PRDC_DT            := V_OBJ_HEAD.get_string('PRDC_DT');       --제조일자
                V_STCK_STA           := V_OBJ_HEAD.get_string('STCK_STA');      --재고상태
                
                V_NEW_MSRM_DT         := TO_CHAR(SYSDATE,'YYYY-MM-DD HH24:MI:SS'); 

                IF TRIM(V_MSRM_DT) IS NULL OR TRIM(V_MSRM_DT) = ' ' THEN
                   V_MSRM_DT             := V_NEW_MSRM_DT; 
                END IF;


                IF TRIM(V_DOC_NO) IS NULL OR TRIM(V_DOC_NO) = ' ' THEN             /*이미 등록된 문서번호가 없으면 신규 번호를 할당한다.*/
                   V_DOC_NO          := V_DOC_NEW_NO; 
                   V_DOC_SEQNO       := i + 1; 
                END IF;

--                IF V_WERKS <> 'P100' THEN
--                    -- 품질검사(측정) 항목별 기준등록를 등록 및 업데이트 한다.(HL는 출하반품검사를 외관검사만 진행하기 때문에 규격별로 관리하지 않아 강제로 등록한다.) 
--                    BEGIN
--                        MERGE
--                              INTO  TB_MAS015 M015
--                             USING  DUAL
--                                ON  ( M015.INSP_ITEM_GRP_CD   =  V_INSP_ITEM_GRP_CD
--                               AND  M015.MATNR                =  V_MATNR
--                               AND  M015.WERKS                =  V_WERKS )
--                        WHEN MATCHED THEN
--                               UPDATE
--                                   SET UPDDATE                =  SYSDATE
--                                     , UPDID                  =  V_SESS_USER_ID                   
--                        WHEN NOT MATCHED THEN
--                                INSERT  (
--                                        INSP_ITEM_GRP_CD,
--                                        MATNR,
--                                        WERKS,
--                                        REGDATE,
--                                        REGID
--                                ) VALUES (
--                                        V_INSP_ITEM_GRP_CD,
--                                        V_MATNR,
--                                        V_WERKS,
--                                        SYSDATE,
--                                        V_SESS_USER_ID 
--                                );
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
--
--                END IF;
                
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
                       E_SQL_ERR_CD        := -20000;
                       E_SQL_ERR_MSG       := SQLCODE || ': EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';
                       ROLLBACK;

                       SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
                       RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);           
                       RETURN;           
                END; 

                IF V_Q020_CNT = 0 THEN
                   V_MSRM_DT   := TO_CHAR(SYSDATE,'YYYY-MM-DD HH24:MI:SS'); 
                END IF;

                -- 품검사 측정 마스터를 등록 또는 업데이트 한다.     
                BEGIN
                      MERGE
                          INTO  TB_QLT020 Q020
                         USING  DUAL
                            ON (Q020.INSP_ITEM_GRP_CD   =  V_INSP_ITEM_GRP_CD
                           AND  Q020.MATNR              =  V_MATNR
                           AND  Q020.WERKS              =  V_WERKS
                           AND  Q020.MSRM_DATE          =  TO_DATE(V_MSRM_DT,'YYYY-MM-DD HH24:MI:SS')
                           AND  Q020.PRC_SEQNO          =  V_PRC_SEQNO)
                      WHEN MATCHED THEN
                             UPDATE
                                SET  Q020.MSRM_ID            =  V_SESS_USER_ID     /*판정자*/
                                   , Q020.SMPL_AMT           =  V_SMPL_AMT         /*시료량*/
                                   , Q020.UCFMTY_AMT         =  V_UCFMTY_AMT       /*부적합량*/
                                   , Q020.FNL_JDGM           =  V_FNL_JDGM         /*최종판정*/
                                   , Q020.DOC_NO             =  V_DOC_NO           /*MES 전송문서번호*/
                                   , Q020.DOC_SEQNO          =  V_DOC_SEQNO        /*MES 전송문서번호순번*/ 
                                   , Q020.PRC_DIV            =  V_PRC_DIV          /*처리구분*/
                                   , Q020.UPDDATE            =  SYSDATE            /*수정일자*/
                                   , Q020.UPDID              =  V_SESS_USER_ID     /*수정자 */
                      WHEN NOT MATCHED THEN
                            INSERT (
                                    INSP_ITEM_GRP_CD,
                                    MATNR,
                                    WERKS,
                                    MSRM_DATE,
                                    PRC_SEQNO,
                                    MSRM_ID,
                                    SMPL_AMT,
                                    UCFMTY_AMT,
                                    FNL_JDGM,
                                    VND_LOT_NO,
                                    SUPY_VND_BCD,
                                    VGBEL,
                                    VGPOS,
                                    REQ_DIV,
                                    DOC_NO,
                                    DOC_SEQNO,
                                    PRC_DIV,
                                    REGDATE,
                                    REGID
                            ) VALUES (
                                    V_INSP_ITEM_GRP_CD,
                                    V_MATNR,
                                    V_WERKS,
                                    TO_DATE(V_MSRM_DT,'YYYY-MM-DD HH24:MI:SS'),
                                    i + 1,
                                    V_SESS_USER_ID,
                                    V_SMPL_AMT,
                                    V_UCFMTY_AMT,
                                    V_FNL_JDGM,
                                    V_VND_LOT_NO,
                                    V_SUPY_VND_BCD,
                                    V_VGBEL,
                                    V_VGPOS,
                                    V_REQ_DIV,
                                    V_DOC_NO,
                                    V_DOC_SEQNO,
                                    V_PRC_DIV,
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

                        ELSIF  V_OBJ_LIST.get_string('GRowState') = 'U' THEN


                               -- 품질검사(측정) 항목별 세부결과를 등록 및 업데이트 한다. 
                               BEGIN
                                    MERGE
                                          INTO  TB_QLT021 Q021
                                         USING  DUAL
                                            ON  ( Q021.INSP_ITEM_GRP_CD   =  V_INSP_ITEM_GRP_CD
                                           AND  Q021.MATNR                =  V_MATNR
                                           AND  Q021.WERKS                =  V_WERKS
                                           AND  Q021.MSRM_DATE            =  TO_DATE(V_MSRM_DT,'YYYY-MM-DD HH24:MI:SS')
                                           AND  Q021.PRC_SEQNO            =  V_PRC_SEQNO
                                           AND  Q021.INSP_ITEM_CD         =  V_INSP_ITEM_CD)
                                    WHEN MATCHED THEN
                                           UPDATE
                                               SET INSP_REP_YN            =  V_INSP_REP_YN
                                                 , RST_VAL                =  V_RST_VAL
                                                 , RST_SEL                =  V_RST_SEL                                         
                                                 , RST_TXT                =  V_RST_TXT
                                                 , RMK                    =  V_RMK
                                                 , FIT_YN                 =  V_FIT_YN
                                                 , UUID                   =  V_UUID
                                                 , UPDDATE                =  SYSDATE
                                                 , UPDID                  =  V_SESS_USER_ID                   
                                    WHEN NOT MATCHED THEN
                                            INSERT  (
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
                                                    TO_DATE(V_MSRM_DT,'YYYY-MM-DD HH24:MI:SS'),
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
                                                AND Q023.IND_BCD            =  V_SUPY_VND_BCD
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
                                       AND Q023.IND_BCD            =  V_SUPY_VND_BCD
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
                                                V_ORDER_NO,
                                                V_ORDER_SEQNO,
                                                V_VND_LOT_NO,
                                                V_SUPY_VND_BCD,
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
                                                V_ORDER_NO,
                                                V_ORDER_SEQNO,
                                                V_VND_LOT_NO,
                                                V_SUPY_VND_BCD, 
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
                               
                               V_RMK := V_RMK || ',' || V_RMK;
                               
                        ELSIF V_OBJ_LIST.get_string('GRowState') = 'D' THEN  -- 삭제가 있나?
                              RETURN;              

                        END IF;

                    END LOOP;

                    IF  V_FNL_JDGM = 'FAIL' THEN

--                        IF TRIM(V_IND_BCD) <> '' OR V_IND_BCD IS NOT NULL THEN -- 부적합이면서 실적이 있는 제품이면..
--                    
--                            -- 최종판정 결과가 부적합 이면 부적합 정보에...
--                            BEGIN
--                                UPDATE TB_INV001 I001
--                                   SET I001.STOR_LOC_CD        = '2010'
--                                     , I001.STCK_STA           = '40'  -- 00:정상, 40: 부적합                               
--                                     , I001.FNL_JDGM           =  V_FNL_JDGM 
--                                     , I001.STCK_QTY           =  I001.STCK_QTY - NVL(V_UCFMTY_AMT,0)                             
--                                     , I001.MSRM_DATE               =  SYSDATE
--                                     , I001.INSPR_ID                =  V_SESS_USER_ID
--                                     , I001.UPDDATE                 =  SYSDATE
--                                     , I001.UPDID                   =  V_SESS_USER_ID                                 
--                                 WHERE ( I001.WERKS               =  V_WERKS
--                                   AND  I001.STOR_LOC_CD          =  V_STOR_LOC_CD
--                                   AND  I001.IND_BCD              =  V_IND_BCD   -- WMS를 통해 출하 반품되는 개별바코드 정보(중복되면 큰일)
--                                   AND  I001.MATNR                =  V_MATNR );
--                                EXCEPTION           
--                                WHEN OTHERS THEN 
--                                      P_SUCCESS           := 'N';
--                                      E_SQL_ERR_CD        := -20000;
--                                      E_SQL_ERR_MSG       := SQLCODE || ': EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';
--                                      ROLLBACK;
--    
--                                      SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
--                                      RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);           
--                                      RETURN;           
--                            END;
--                        END IF;

                        BEGIN
                              MERGE
                                  INTO  TB_QLT024 Q024
                                 USING  DUAL
                                    ON  ( Q024.INSP_ITEM_GRP_CD   =  V_INSP_ITEM_GRP_CD
                                   AND    Q024.MATNR              =  V_MATNR
                                   AND    Q024.WERKS              =  V_WERKS
                                   AND    Q024.MSRM_DATE          =  TO_DATE(V_MSRM_DT,'YYYY-MM-DD HH24:MI:SS')
                                   AND    Q024.PRC_SEQNO          =  V_PRC_SEQNO)
                        WHEN MATCHED THEN
                                UPDATE
                                    SET FNL_JDGM       =  V_FNL_JDGM
                                      , PRC_MTD        =  V_PRC_MTD
                                      , UCFMTY_AMT     =  V_UCFMTY_AMT 
                                      , RMK            =  RMK || ','||V_RMK
--                                      , STOR_LOC_CD    =  '2010'
                                      , UPDDATE        =  SYSDATE
                                      , UPDID          =  V_SESS_USER_ID                   
                        WHEN NOT MATCHED THEN
                                INSERT (
                                        INSP_ITEM_GRP_CD,
                                        MATNR,
                                        WERKS,
                                        MSRM_DATE,
                                        PRC_SEQNO,
                                        PRC_MTD,
                                        UCFMTY_AMT,
                                        FNL_JDGM,
                                        RMK,
                                        LOT_NO,
                                        IND_BCD,
                                        VND_LOT_NO,
                                        SUPY_VND_BCD,
                                        STOR_LOC_CD,
                                        REGDATE,
                                        REGID
                                ) VALUES (
                                        V_INSP_ITEM_GRP_CD,
                                        V_MATNR,
                                        V_WERKS,
                                        TO_DATE(V_MSRM_DT,'YYYY-MM-DD HH24:MI:SS'),
                                        i + 1,
                                        V_PRC_MTD,
                                        V_UCFMTY_AMT,
                                        V_FNL_JDGM,
                                        V_RMK,
                                        V_LOT_NO,
                                        V_IND_BCD,
                                        V_VND_LOT_NO,
                                        V_SUPY_VND_BCD,
                                        V_STOR_LOC_CD, 
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

--                    ELSE 

--                        IF TRIM(V_IND_BCD) <> '' OR V_IND_BCD IS NOT NULL THEN -- 합격이면서 실적이 있는 제품이면..
--
--                           -- 최종 판정이 적합이면....
--                           SELECT COUNT(*)
--                             INTO V_I001_CNT
--                             FROM TB_INV001 I001
--                            WHERE I001.WERKS               =  V_WERKS
--                              AND I001.STOR_LOC_CD          =  '2010'
--                              AND I001.IND_BCD              =  V_IND_BCD
--                              AND I001.MATNR                =  V_MATNR;
--
--                            IF  V_I001_CNT  >= 1 THEN     -- 과거에 부적합이었다면 적합으로 전환
--
--                               BEGIN
--                                    UPDATE TB_INV001 I001
--                                       SET I001.STOR_LOC_CD        = '2000'
--                                         , STCK_STA                = '00'  -- 00:정상, 40: 부적합
--                                         , I001.FNL_JDGM           =  V_FNL_JDGM 
--                                         , MSRM_DATE               =  SYSDATE
--                                         , INSPR_ID                =  V_SESS_USER_ID
--                                         , UPDDATE                 =  SYSDATE
--                                         , UPDID                   =  V_SESS_USER_ID                                 
--                                     WHERE ( I001.WERKS               =  V_WERKS
--                                       AND  I001.STOR_LOC_CD          =  '2010'
--                                       AND  I001.IND_BCD              =  V_IND_BCD
--                                       AND  I001.MATNR                =  V_MATNR );
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
--                               END; 
-- 
--                            END IF;
--
--                        END IF;
                                               
                    END IF;

                    -- 수입검사대상에서 검사진행 내용을 기록 한다.
                    BEGIN
                        UPDATE  TB_QLT001
                            SET  INSPR_ID            =  V_SESS_USER_ID
                               , INSP_DATE           =  TO_DATE(V_MSRM_DT,'YYYY-MM-DD HH24:MI:SS')
                               , INSP_YN             = 'Y' 
                          WHERE VGBEL = V_VGBEL AND   VGPOS = V_VGPOS AND REQ_DIV = V_REQ_DIV;
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

                    -- 적합, 부적합 모두 판정결과를 WMS로 전송처리 진행
                    BEGIN
                          MERGE
                              INTO  TB_IFSWM006 WM006
                             USING  DUAL
                                ON  ( DOC_NO      = V_DOC_NO
                               AND    DOC_SEQNO   = V_DOC_SEQNO )
                    WHEN MATCHED THEN
                             UPDATE
                                SET IF_STATUS     = NULL,    --WMS 결과값 리턴(S,성공, E:오류)
                                    IF_GET_DATE   = SYSDATE, --MES 등록일시
                                    IF_SET_DATE   = NULL,    --WMS 전송일시
                                    IF_ERR_MESS   = NULL     --WMS 결과 메시지
                    WHEN NOT MATCHED THEN                 
                            INSERT  (
                                    DOC_NO,      --MES 문서번호
                                    DOC_SEQNO,   --MES 문서순번
                                    ORDER_NO,    --오더번호
                                    ORDER_SEQNO, --오더순번
                                    SUPY_CD,     --공급자
                                    MATNR,       --품목코드
                                    QTY,         --입고수량
                                    UNIT,        --입고단위
                                    VGBEL,       --참조번호(WMS문서번호)
                                    VGPOS,       --참조번호 아이템(WMS 문서아이템 번호
                                    STOK_KY,     --STOCK_KEY
                                    LOT_NUM,     --WMS LOT 속성코드
                                    STOR_LOC,    --저장위치(WMS 저장위치)
                                    WERKS,       --플랜트
                                    STCK_STA,    --재고상태(00정상 30불용 05품질 50폐기 10보류)
                                    NTN_CD,      --국가코드
                                    CRSPD_CD,    --거래처코드
                                    PRDC_DT,     --제조일자
                                    RCVGDS_DT,   --입고일자
                                    DSTBT_DDLIN, --유통기한
                                    IND_BCD,     --개별바코드(협력업체바코드)
                                    LOT_NO,      --업체LOT NO/SAP 배치번호)
                                    CHKRST,      --검사진행상태
                                    QTYGOD,      --정상수량
                                    QTYBAD,      --불량수량
                                    BADRSN,      --불량사유
                                    BADRSNNM,    --불량사유명칭
                                    IF_STATUS,   --WMS 결과값 리턴(S,성공, E:오류)
                                    IF_GET_DATE, --MES 등록일시
                                    IF_SET_DATE, --WMS 전송일시
                                    IF_ERR_MESS  --WMS 결과 메시지
                            ) VALUES (
                                    V_DOC_NO,
                                    V_DOC_SEQNO,
                                    V_ORDER_NO,
                                    V_ORDER_SEQNO,
                                    V_SUPY_CD,
                                    V_MATNR,
                                    V_RCVGDS_QTY,
                                    V_UNIT,
                                    V_VGBEL,
                                    V_VGPOS,
                                    V_STOR_KY,
                                    V_LOT_NUM,
                                    V_STOR_LOC_CD,
                                    V_WERKS,
                                    V_STCK_STA,
                                    V_NTN_CD,
                                    V_CRSPD_CD,
                                    V_PRDC_DT,
                                    V_RCVGDS_DT,
                                    V_DSTBT_DDLIN,
                                    V_SUPY_VND_BCD,
                                    V_VND_LOT_NO,
                                    'QR',
                                    NVL(V_RCVGDS_QTY,0) - NVL(V_UCFMTY_AMT,0),
                                    NVL(V_UCFMTY_AMT,0),
                                    V_BADRSN,
                                    V_RMK,
                                    'N',
                                    SYSDATE,
                                    NULL,
                                    NULL
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

        END LOOP;
        
        P_WDOC_NO := V_DOC_NO;

    END IF;
    
--    call_restful();
--    
--    if err <> '' then
--       commit
--       else
--       rollback
--       end if;
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
