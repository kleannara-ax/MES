
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_WRK03_S01" (
	P_TYPE           IN    varchar2, -- LIST
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
 *       - [TB_WRK013] : (.R..) 작업장(설비별)투입작업자 관리
 *       - [TB_MAS012] : (.R..) 설비마스터                          
 *=============================================================================*/

AS

    V_PRG_NM          VARCHAR2(100)  := 'SP_WRK03_S01';     -- PROCEDURE NAME

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
    V_WERKS             TB_WRK013.WERKS%TYPE;       -- 플랜트

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

        V_SQL := ' SELECT  W013.WERKS,              -- 플랜트
                           W013.MACH_CD,            -- 설비코드
                           M012.MACH_NM,            -- 설비명
                           W013.STR_DATE,           -- 시작일시
                           W013.END_DATE,           -- 작업종료일시
                           (SELECT NMLAST FROM USRMA WHERE USERID = W013.EMPLY_NO)  AS EMPLY_NM,        -- 작업자
                           W013.WRKER_CNT,          -- 작업인원
                           W013.PRFM_DT,            -- 실적일자
                           W013.LINE_TM,            -- 시간
                           W013.WRK_CLASS,          -- 작업반
                           (SELECT CDESC1 FROM CMCDV WHERE CMCDKY= ''WRKMETH'' AND CMCDVL = W013.WRK_SHIFT)     AS  WRK_SHIFT   -- 작업조
                     FROM  TB_WRK013 W013,  -- 작업장(설비별)투입작업자 관리
                           TB_MAS012 M012   -- 설비 마스터
                    WHERE  W013.MACH_CD = M012.MACH_CD(+) ' ;

        IF  V_WERKS IS NOT NULL OR TRIM(V_WERKS) != '' THEN                     -- 플랜트
            V_SQL := V_SQL || ' AND W013.WERKS = ''' || V_WERKS || ''' ';        
        END IF;

        IF V_RANGE_SQL IS NOT NULL OR TRIM(V_RANGE_SQL) != '' THEN
            V_SQL := V_SQL || V_RANGE_SQL;
        END IF;

		V_SQL := V_SQL || ' ORDER BY W013.WERKS, W013.MACH_CD ';
        
        V_DEBUG := 'Y';
        IF (V_DEBUG = 'Y') THEN
            INSERT INTO PROC_LOG(SQL_STR) VALUES (V_SQL);
        END IF;      
        
		OPEN P_RS_LIST FOR V_SQL;

    ELSIF P_TYPE = 'SUB_LIST' THEN  /* 하부 상세 조회 리스트*/

        RETURN;	

    ELSIF P_TYPE = 'SAVE' THEN

        RETURN;

    ELSIF P_TYPE = 'SUB_SAVE' THEN

        RETURN;

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
        E_SQL_ERR_CD        := -20990;
        E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

        ROLLBACK;
        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
END;
/
