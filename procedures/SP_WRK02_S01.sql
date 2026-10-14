
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_WRK02_S01" (
	P_TYPE           IN    varchar2, -- LIST, SUB_LIST
	P_JSON_STR       IN    CLOB ,
	P_SUCCESS       OUT    varchar2,
	P_RS_LIST       OUT    SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : MAS24{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 공정체크 이력{호출 프로그램 명 기술}
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 설비별 공정체크 검사 이력을 조회한다.{프로그램에 대한 상세한 내용 기술}
 *                 
 * AUTHOR NAME   : 여한진{최초 작성자 명 기술}
 * CREATE DATE   : 2022/05/26 {최초 작성일자 기술}
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * yyyy/mm/dd    1.0.0   여한진         Initial Version 
 *==============================================================================
 *  관련 테이블
 *       - [TB_MAS012] : (.R..) 설비마스터
 *       - [TB_MAS025] : (.R..) 공정체크항목
 *       - [TB_MAS026] : (.R..) 공정체크항목별 기준값관리
 *       - [TB_WRK014] : (.R..) 설비별 공정체크 이력
 *=============================================================================*/

AS

    V_PRG_NM          VARCHAR2(100)  := 'SP_WRK02_S01';     -- PROCEDURE NAME

    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5)           := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);


   -- V_RTN_CLOB       CLOB;
   -- V_RTN_CURSOR     SYS_REFCURSOR;
   -- V_ERROR          CLOB;


    -- JSON을 위한 변수선언 영역
    V_JSON          JSON_OBJECT_T;
    V_ARR_LIST      JSON_ARRAY_T;
    V_ARR_HEAD      JSON_OBJECT_T;
    V_OBJ           JSON_OBJECT_T;
    V_OBJ2          JSON_OBJECT_T; 

    -- 세션값 처리용 변수선언 영역
    V_SQL            CLOB;
    V_RUN_SQL        varchar2(1);
    V_RANGE_SQL      varchar2(4000);
    V_DEBUG          varchar2(1);

    -- 세션값 처리용 변수선언 영역
    V_PLT_CD         varchar2(4);
    V_SESS_USER_ID   varchar2(20);

    -- 조건절 처리용 변수선언 영역
    V_WERKS             TB_WRK014.WERKS%TYPE;       -- 플랜트
    V_MACH_CD           TB_WRK014.MACH_CD%TYPE;     -- 설비
    V_CHK_DT            TB_WRK014.CHK_DT%TYPE;      -- 체크일자
    V_CHK_SEQNO         TB_WRK014.CHK_SEQNO%TYPE;   -- 체크차수

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
   V_RANGE_SQL          :=      V_JSON.get_string('RANGE_SQL');     
   V_WERKS              :=      V_JSON.get_string('WERKS');         -- 플랜트

   IF P_TYPE = 'LIST' THEN /*상단 조회 리스트*/

        V_SQL := ' SELECT  DISTINCT
                           W014.WERKS,              -- 플랜트
                           W014.CHK_DT,             -- 체크일자
                           W014.MACH_CD,            -- 설비코드
                           M012.MACH_NM,            -- 설비명
                           W014.CHK_SEQNO,          -- 체크차수
                           NVL((SELECT NMLAST FROM USRMA WHERE USERID = W014.REGID),'' '')  AS REGNM         -- 작업자
                     FROM  TB_WRK014 W014,  -- 설비별 공정체크 이력
                           TB_MAS012 M012   -- 설비 마스터
                    WHERE  W014.MACH_CD = M012.MACH_CD(+) ' ;

        IF  V_WERKS IS NOT NULL OR TRIM(V_WERKS) != '' THEN                     -- 플랜트
            V_SQL := V_SQL || ' AND W014.WERKS = ''' || V_WERKS || '''';        
        END IF;

        IF V_RANGE_SQL IS NOT NULL OR TRIM(V_RANGE_SQL) != '' THEN
            V_SQL := V_SQL || V_RANGE_SQL;
        END IF;

		V_SQL := V_SQL || ' ORDER BY W014.WERKS, W014.CHK_DT, W014.MACH_CD, W014.CHK_SEQNO ';

		OPEN P_RS_LIST FOR V_SQL;

    ELSIF P_TYPE = 'SUB_LIST' THEN  /* 하부 상세 조회 리스트*/
        V_ARR_HEAD      :=      TREAT(V_JSON.get('head') AS json_object_t);
        V_OBJ           :=      TREAT(V_ARR_HEAD.get('map') AS json_object_t);

        V_WERKS         :=      V_OBJ.get_string('WERKS');
        V_MACH_CD       :=      V_OBJ.get_string('MACH_CD');
        V_CHK_DT        :=      V_OBJ.get_string('CHK_DT');
        V_CHK_SEQNO     :=      V_OBJ.get_string('CHK_SEQNO');

        V_SQL := ' SELECT  W014.CHK_ITEM_CD,        -- 체크항목코드
                           M025.CHK_ITEM_NM,        -- 체크항목명
                           M025.MID_CAT_NM,         -- 중분류명
                           M025.BIG_CAT_NM,         -- 대분류명
                           W014.MATNR,              -- 자재코드
                           W014.WRK_ORDR_NO,        -- 작업지시번호
                           W014.WRK_ORDR_SEQNO,     -- 작업지시순번
                           (SELECT CDESC1 FROM CMCDV WHERE CMCDKY = ''INPTTYP'' AND CMCDVL = W014.INPT_TYP) INPT_TYP_NM,   -- 입력타입
                           (SELECT CDESC1 FROM CMCDV WHERE CMCDKY = ''INPTMTD'' AND CMCDVL = W014.INPT_MTD) INPT_MTD_NM,   -- 입력방법
                           M026.STD_VAL1,           -- 기준값(숫자)
                           M026.STD_VAL2,           -- 기준값(문자)
                           W014.LOW_VAL,            -- 하한치
                           W014.UPP_VAL,            -- 상한치
                           W014.RST_VAL,            -- 결과값(숫자)
                           W014.RST_SEL,            -- 결과값(선택값)
                           W014.RST_TXT,            -- 결과값(문자열)
                           W014.CPK_YN,             -- CPK 여부
                           W014.RMK,                -- 비고
                           W014.REGDATE,
                           NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = W014.REGID),'' '') AS "REGNM",
                           W014.UPDDATE,
                           NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = W014.UPDID),'' '') AS "UPDNM"
                     FROM  TB_WRK014 W014,  -- 설비별 공정체크 이력
                           TB_MAS025 M025,  -- 공정체크항목
                           TB_MAS026 M026   -- 공정체크항목별 기준값관리
                    WHERE  W014.WERKS = M025.WERKS(+)
                      AND  W014.WERKS = M026.WERKS(+)
                      AND  W014.MACH_CD = M026.MACH_CD(+)
                      AND  W014.CHK_ITEM_CD = M025.CHK_ITEM_CD(+)
                      AND  W014.CHK_ITEM_CD = M026.CHK_ITEM_CD(+) 
                      AND  W014.WERKS = ''' || V_WERKS || ''' 
                      AND  W014.CHK_DT = ''' || V_CHK_DT || ''' 
                      AND  W014.MACH_CD = ''' || V_MACH_CD || ''' 
                      AND  W014.CHK_SEQNO = ''' || V_CHK_SEQNO || ''' '; 

        V_SQL := V_SQL || ' ORDER BY W014.CHK_ITEM_CD ';

        OPEN P_RS_LIST FOR V_SQL;                  

    ELSIF P_TYPE = 'SAVE' THEN

        RETURN;

    ELSIF P_TYPE = 'SUB_SAVE' THEN

        RETURN;

    END IF;    

    P_SUCCESS := 'Y';

--    EXCEPTION
--    WHEN E_EXCEPTION_USER THEN
--
--        -- 에러 내역 SET
--	    P_SUCCESS           := 'N';
--        E_SQL_ERR_CD        := SQLCODE;
--        E_SQL_ERR_MSG       := SUBSTRB(SQLERRM,1,300);
--
--        ROLLBACK;
--        SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
--
--    WHEN OTHERS THEN
--	    P_SUCCESS           := 'N';
--        E_SQL_ERR_CD        := -20990;
--        E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';
--
--        ROLLBACK;
--        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
END;
/
