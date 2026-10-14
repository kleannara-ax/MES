
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_QLT02_S01" (
	P_TYPE           IN    varchar2, -- LIST, SUB_LIST, SUB_SAVE
	P_JSON_STR       IN    CLOB,
	P_SUCCESS       OUT    varchar2,
	P_RS_LIST       OUT    SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : QLT02{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 품질검사(수입검사)이력조회{호출 프로그램 명 기술}
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 품질검사(수입검사)이력을 조회한다.{프로그램에 대한 상세한 내용 기술}
 *                 
 * AUTHOR NAME   : 김성하{최초 작성자 명 기술}
 * CREATE DATE   : 2022/04/12 {최초 작성일자 기술}
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
 *       - [TB_MAS001] : (.R..) 자재 마스트                              
 *       - [TB_MAS015] : (.R..) 검사항목별 기준정보 등록 마스트                              
 *       - [TB_MAS016] : (.R..) 검사항목별 기준값 정보                                
 *       - [TB_QLT020] : (.R..) 검사항목별 판정결과 등록 마스트                              
 *       - [TB_QLT021] : (.R..) 검사항목별 판정결과 정보
 *=============================================================================*/

AS

    V_PRG_NM          VARCHAR2(100)  := 'SP_QLT02_S01';     -- PROCEDURE NAME

    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5)           := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);


   -- V_RTN_CLOB       CLOB;
   -- V_RTN_CURSOR     SYS_REFCURSOR;
   -- V_ERROR          CLOB;


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
    V_WERKS            TB_MAS015.WERKS%TYPE; -- 플랜트코드
    V_MATNR            VARCHAR2(4000); -- 자재코드
    V_MATNR_NM         TB_MAS001.MATNR_NM%TYPE; -- 자재명
    V_MATNR_GRP_CD     TB_MAS001.MATNR_GRP_CD%TYPE; -- 자재그룹
    V_INSP_YN          VARCHAR2(1);          -- 등록여부
    V_SUPY_CD          TB_QLT001.SUPY_CD%TYPE; --공급업체코드

    -- 리스트(그리드)의 값을 할당하기 위한 변수선언 영역        
    V_INSP_ITEM_GRP_CD TB_MAS015.INSP_ITEM_GRP_CD%TYPE; 
    V_INSP_ITEM_CD     TB_MAS016.INSP_ITEM_CD%TYPE;

    V_STD_VAL          TB_MAS016.STD_VAL%TYPE;
    V_UPP_VAL          TB_MAS016.UPP_VAL%TYPE;
    V_LOW_VAL          TB_MAS016.LOW_VAL%TYPE;
    V_STD_SEL          TB_MAS016.STD_SEL%TYPE;
    V_INSP_STD_1       TB_MAS016.INSP_STD_1%TYPE;
    V_INSP_STD_2       TB_MAS016.INSP_STD_2%TYPE;


    V_MSRM_DATE        TB_QLT020.MSRM_DATE%TYPE;
    V_PRC_SEQNO        TB_QLT020.PRC_SEQNO%TYPE;

    V_MSRM_DT          VARCHAR2(20) := '';
    V_SDATE            VARCHAR2(30);
    V_EDATE            VARCHAR2(30);
    V_MSRM_ID          TB_QLT020.MSRM_ID%TYPE;
    V_SMPL_AMT         TB_QLT020.SMPL_AMT%TYPE;
    V_FNL_JDGM         TB_QLT020.FNL_JDGM%TYPE;
    V_VND_LOT_NO       TB_QLT020.VND_LOT_NO%TYPE;
    V_SUPY_VND_BCD     TB_QLT020.SUPY_VND_BCD%TYPE;
    V_VGBEL            TB_QLT020.VGBEL%TYPE;
    V_VGPOS            TB_QLT020.VGPOS%TYPE;
    V_REQ_DIV          TB_QLT020.REQ_DIV%TYPE; 

    V_RST_VAL          TB_QLT021.RST_VAL%TYPE;
    V_RST_SEL          TB_QLT021.RST_SEL%TYPE;
    V_RST_TXT          TB_QLT021.RST_TXT%TYPE;
    V_RMK              TB_QLT021.RMK%TYPE;
    V_FIT_YN           TB_QLT021.FIT_YN%TYPE;
    V_INSP_REP_YN      TB_QLT021.INSP_REP_YN%TYPE;
    V_UUID             TB_QLT021.UUID%TYPE;

    --기타처리
    V_CREATE_FLG       CHAR(1)  := 'N';
    V_UPDATE_FLG       CHAR(1)  := 'N';    
    V_Q021_CNT         NUMBER   := 0;
    V_CHG_ACC          NUMBER   := 0;

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
   V_MATNR_NM           :=       V_JSON.get_string('MATNR_NM');     -- 자재명 
   V_INSP_YN            :=       V_JSON.get_string('INSP_YN');   -- 검사여부
   V_INSP_ITEM_GRP_CD   :=       V_JSON.get_string('INSP_ITEM_GRP_CD'); -- 검사항목그룹
   V_MATNR              :=       V_JSON.get_string('MATNR');            -- 자재코드
   V_SDATE              :=       V_JSON.get_string('SDATE');     -- 측정일시(시작)
   V_EDATE              :=       V_JSON.get_string('EDATE');     -- 측정일시(끝)
   V_SUPY_CD            :=       V_JSON.get_string('SUPY_CD');      --공급업체


   IF P_TYPE = 'LIST' THEN /*상단 조회 리스트*/

      V_SQL := '  SELECT   Q020.INSP_ITEM_GRP_CD AS "INSP_ITEM_GRP_CD"
--                         , SUBSTR(Q001.RCVGDS_DT,1,4) ||''-''|| SUBSTR(Q001.RCVGDS_DT,5,2) ||''-''|| SUBSTR(Q001.RCVGDS_DT,7,2)      AS "RCVGDS_DT"     --입고일자   
                         , TO_CHAR(TO_DATE(Q001.RCVGDS_DT,''YYYYMMDD''),''YYYY-MM-DD'')      AS "RCVGDS_DT"     --입고일자  
                         , Q020.MATNR          AS "MATNR"        -- 자재코드
                         , M001.MATNR_NM          AS "MATNR_NM"        -- 자재명
                         , Q020.WERKS          AS "WERKS"        -- 플랜트
                         , Q020.MSRM_DATE      AS "MSRM_DATE"    -- 측정일시
                         , Q020.PRC_SEQNO      AS "PRC_SEQNO"    -- 처리순번
                        -- , Q020.MSRM_ID          -- 측정자
                         ,  NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = Q020.MSRM_ID),'''') AS "MSRM_NM"   
                         , Q020.SMPL_AMT       AS "SMPL_AMT"     -- 시료량 
                        --   , Q020.FNL_JDGM       -- 최종판정
                         ,(SELECT CDESC1 FROM CMCDV WHERE CMCDKY = ''FNL_JDGM''  AND CMCDVL = Q020.FNL_JDGM) AS "FNL_JDGM_NM"      
                        -- , Q020.IND_BCD      AS "IND_BCD"      -- 개별바코드(공급업체 바코드)
                         , Q020.VND_LOT_NO     AS "VND_LOT_NO"   -- 공급업체 로트번호
                         , Q020.SUPY_VND_BCD   AS "SUPY_VND_BCD" -- 공급업체 바코드
                        --   , Q001.STOR_LOC_CD   AS "STOR_LOC"     -- 저장위치
                         , NVL((SELECT STOR_LOC_NM FROM TB_MAS003 WHERE WERKS = Q020.WERKS AND STOR_LOC_CD = Q001.STOR_LOC_CD),'''') AS "STOR_LOC_NM"   
                         , Q001.RCVGDS_QTY     AS "RCVGDS_QTY"   -- 입고수량
                         , Q001.UNIT             -- 단위
                         ,(SELECT CDESC1 FROM CMCDV WHERE CMCDKY = ''UNIT''      AND CMCDVL = Q001.UNIT) AS "UNIT_NM"   
                         , Q020.UCFMTY_AMT     AS "UCFMTY_AMT"   -- 부적합량
                        --   , Q001.STCK_STA     -- 재고상태
                         ,(SELECT CDESC1 FROM CMCDV WHERE CMCDKY = ''STCK_STA''  AND CMCDVL = Q001.STCK_STA) AS "STCK_STA_NM"
                        --   , Q001.NTN_CD     AS "NTN_CD"       -- 국가코드
                         ,(SELECT CDESC1 FROM CMCDV WHERE CMCDKY = ''NTN_CD''    AND CMCDVL = Q001.NTN_CD) AS "NTN_NM"
                         , Q001.SUPY_CD        AS "SUPY_CD"     --공급처 
                         ,(SELECT CUST_NM FROM TB_MAS009 WHERE CUST_DIV = ''V'' AND CUST_CD = Q001.SUPY_CD) AS "SUPY_NM"    
--                         , SUBSTR(Q001.PRDC_DT,1,4) ||''-''|| SUBSTR(Q001.PRDC_DT,5,2) ||''-''|| SUBSTR(Q001.PRDC_DT,7,2)      AS "PRDC_DT"     --제조일자
                         , TO_CHAR(TO_DATE(Q001.PRDC_DT,''YYYYMMDD''),''YYYY-MM-DD'')      AS "PRDC_DT"     --제조일자 
                         , Q020.REGDATE
                         , NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = Q020.REGID),'''') AS "REGNM"
                         , Q020.UPDDATE
                         , NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = Q020.UPDID),'''') AS "UPDNM"                         
                    FROM TB_QLT020 Q020,
                         TB_MAS001 M001, 
                         TB_QLT001 Q001     
                   WHERE Q020.MATNR    = M001.MATNR(+)
                     AND Q020.WERKS    = M001.WERKS(+)
                     AND Q020.VGBEL    = Q001.VGBEL(+)
                     AND Q020.VGPOS    = Q001.VGPOS(+)
                     AND Q020.REQ_DIV  = Q001.REQ_DIV(+) 
                     AND Q020.INSP_ITEM_GRP_CD = ''C1''';

        IF  V_WERKS IS NOT NULL OR TRIM(V_WERKS) != '' THEN -- 플랜트
            V_SQL := V_SQL || ' AND Q020.WERKS  = ''' || V_WERKS || '''';             
        END IF;

        IF  V_RANGE_SQL IS NOT NULL OR TRIM(V_RANGE_SQL) != '' THEN -- 입고일자, 제조일자, 자재코드, 공급업체, 측정일자
            V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'MATNR',  'Q020.MATNR');
            V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'SUPY_CD',  'Q001.SUPY_CD');
            V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'MSRM_DATE', 'TO_CHAR(Q020.MSRM_DATE, ''YYYYMMDD'')' );
            V_SQL := V_SQL || V_RANGE_SQL;
        END IF;                     

--        IF  V_MATNR IS NOT NULL OR TRIM(V_MATNR) != '' THEN -- 자재코드
--            V_SQL := V_SQL || ' AND REGEXP_LIKE(Q020.MATNR, ''' || V_MATNR || ''') ';
--        END IF; 
--
--        IF  V_SUPY_CD IS NOT NULL OR TRIM(V_SUPY_CD) != '' THEN -- 공급업체코드
--            V_SQL := V_SQL || ' AND REGEXP_LIKE(Q001.SUPY_CD, ''' || V_SUPY_CD || ''') ';
--        END IF; 
--
--        IF  ( V_SDATE IS NOT NULL OR TRIM(V_SDATE) != '' ) AND (V_EDATE IS NOT NULL OR TRIM(V_EDATE) != '')THEN -- 검사일시
--            V_SQL := V_SQL || ' AND Q020.MSRM_DATE >= TO_DATE(''' || V_SDATE || ''',''YYYY-MM-DD HH24:MI:SS'') AND Q020.MSRM_DATE < TO_DATE(''' || V_EDATE || ''',''YYYY-MM-DD HH24:MI:SS'') + 1';  
--        END IF;

--        IF  V_VND_LOT_NO IS NOT NULL OR TRIM(V_VND_LOT_NO) != '' THEN -- 공급업체 LOTNO
--            V_SQL := V_SQL || ' AND Q020.VND_LOT_NO  = ''' || V_VND_LOT_NO || '''';             
--        END IF;

		V_SQL := V_SQL || ' ORDER BY Q001.RCVGDS_DT';

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

        V_MSRM_DT            := V_JSON.get_string('MSRM_DATE');
        V_PRC_SEQNO          := V_JSON.get_number('PRC_SEQNO');

        V_SQL :=  '  SELECT Q021.INSP_ITEM_GRP_CD, Q021.MATNR, Q021.WERKS, 
                            Q021.INSP_ITEM_CD, --항목코드 
                            M016.INSP_ITEM_NM, --항목명
                            M016.MID_CAT_NM,   --중분류
                            M016.BIG_CAT_NM,   --대분류
                            M016.MSRM_CYC,     --측정주기
                            M016.MSRM_ACC,     --측정차수
                            M016.MSRM_MTD,     --측정방법
                            M016.MSRM_UNIT,    --측정단위
                            M016.INSP_SPEC,    --시험규격                
                            M016.STD_VAL,      --기준값
                            M016.UPP_VAL,      --상한값
                            M016.LOW_VAL,      --하한값
                            M016.STD_SEL,      --기준선택값
                            M016.INSP_STD_1,   --검사기준(1)
                            M016.INSP_STD_2,   --검사기준(2)
                            Q021.RST_VAL,      --결과값(숫자)
                            Q021.RST_SEL,      --결과값(선택)
                            Q021.RST_TXT,      --결과값(문자열)
                            Q021.RMK,          --특이사항
                            (SELECT CDESC1 FROM CMCDV WHERE CMCDKY = ''FITYN'' AND CMCDVL = Q021.FIT_YN) AS "FIT_YN",       --적합여부(Y/N)
                            Q021.INSP_REP_YN,  --성적서 항목여부(Y/N)
                            M016.DISP_SEQ,
                            DECODE(Q021.UUID, NULL, '''', Q021.UUID) AS "UUID",
                            SFILE.NAME AS "UUID_FILEVIEW", 
                            SFILE.RPATH, SFILE.FNAME,
                            Q021.REGDATE,
                            NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = Q021.REGID),'''') AS "REGNM",
                            Q021.UPDDATE,
                            NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = Q021.UPDID),'''') AS "UPDNM"                         
                       FROM TB_QLT021 Q021,
                            SYSFILE SFILE,
                            (SELECT M016.INSP_ITEM_GRP_CD, 
                                    M016.INSP_ITEM_CD, 
                                    M014.INSP_ITEM_NM,
                                    M014.PROD_GRP_CD,
                                    M014.MID_CAT_NM,
                                    M014.BIG_CAT_NM,
                                   (SELECT CDESC1 FROM CMCDV WHERE CMCDKY = ''INPTDIV'' AND CMCDVL = M014.INPT_DIV) AS "INPT_DIV",
                                   (SELECT CDESC1 FROM CMCDV WHERE CMCDKY = ''MSRMUNIT'' AND CMCDVL = M014.MSRM_CYC) AS "MSRM_CYC",
                                    M014.MSRM_ACC, --측정차수
                                    M014.NECSY_YN, -- 필수입력 여부
                                   (SELECT CDESC1 FROM CMCDV WHERE CMCDKY = ''INPTTYP'' AND CMCDVL = M014.INPT_TYP) AS "INPT_TYP",                           
                                   (SELECT CDESC1 FROM CMCDV WHERE CMCDKY = ''INPTMTD'' AND CMCDVL = M014.INPT_MTD) AS "INPT_MTD",          
                                    M014.MSRM_MTD, -- 측정방법
                                    M014.MSRM_UNIT,-- 측정단위
                                    M014.INSP_SPEC,
                                    M014.DISP_SEQ,
                                    M016.MATNR, 
                                    M016.WERKS, 
                                    M016.STD_VAL, 
                                    M016.UPP_VAL, 
                                    M016.LOW_VAL, 
                                    M016.STD_SEL, 
                                    M016.INSP_STD_1, 
                                    M016.INSP_STD_2
                               FROM TB_MAS016 M016,
                                    TB_MAS014 M014
                              WHERE M016.INSP_ITEM_GRP_CD =  M014.INSP_ITEM_GRP_CD(+)
                                AND M016.INSP_ITEM_CD     =  M014.INSP_ITEM_CD(+)
                                AND M014.PROD_GRP_CD  = FN_GET_PROD_GRP( '''|| V_WERKS || ''','''|| V_MATNR ||''' )
                                AND M016.INSP_ITEM_GRP_CD = ''C1''
                                AND M016.MATNR            = '''|| V_MATNR ||''' 
                                AND M016.WERKS            = '''|| V_WERKS ||''' ) M016            
                      WHERE Q021.UUID             = SFILE.UUID(+) 
                        AND Q021.INSP_ITEM_GRP_CD = M016.INSP_ITEM_GRP_CD(+) 
                        AND Q021.INSP_ITEM_CD     = M016.INSP_ITEM_CD(+) 
                        AND Q021.MATNR            = M016.MATNR(+) 
                        AND Q021.WERKS            = M016.WERKS(+)
                        AND Q021.INSP_ITEM_GRP_CD = ''C1'' 
                        AND Q021.MATNR            = '''|| V_MATNR ||''' 
                        AND Q021.WERKS            = '''|| V_WERKS ||'''
                        AND Q021.MSRM_DATE        = TO_DATE('''|| V_MSRM_DT ||''',''YYYY-MM-DD HH24:MI:SS'')
                        AND Q021.PRC_SEQNO        = TO_NUMBER(''' || V_PRC_SEQNO ||''')
                     ORDER BY  M016.DISP_SEQ ';  

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
          RETURN;

    END IF;

    P_SUCCESS := 'Y';

    COMMIT;

    EXCEPTION
    WHEN E_EXCEPTION_USER THEN

        -- 에러 내역 SET
	    P_SUCCESS           := 'N';
        E_SQL_ERR_CD        := -20000;
        E_SQL_ERR_MSG       := SQLCODE || ': EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';
        SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, V_SQL||E_SQL_ERR_MSG, V_SESS_USER_ID);

        ROLLBACK;
        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);

    WHEN OTHERS THEN
	    P_SUCCESS           := 'N';
        E_SQL_ERR_CD        := -20000;
        E_SQL_ERR_MSG       := SQLCODE || ': EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';
        SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);

        ROLLBACK;
        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
END;
/
