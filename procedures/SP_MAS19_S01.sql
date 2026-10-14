
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_MAS19_S01" (
	P_TYPE           IN    varchar2, -- LIST
	P_JSON_STR       IN    CLOB ,
	P_SUCCESS       OUT    varchar2,
	P_RS_LIST       OUT    SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : MAS19{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 단위코드관리{호출 프로그램 명 기술}
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 단위 항목을 관리한다.{프로그램에 대한 상세한 내용 기술}
 *                 
 * AUTHOR NAME   : 여한진{최초 작성자 명 기술}
 * CREATE DATE   : 2022/04/14 {최초 작성일자 기술}
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
 *       - [TB_MAS004] : (R) 단위마스터                              
 *=============================================================================*/

AS

    V_PRG_NM          VARCHAR2(100)  := 'SP_MAS19_S01';     -- PROCEDURE NAME

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
    V_PLT_CD         varchar2(4);
    V_SESS_USER_ID   varchar2(20);

    -- 조건절 처리용 변수선언 영역
    V_UNIT         TB_MAS004.UNIT%TYPE;       -- 단위

    -- 리스트(그리드)의 값을 할당하기 위한 변수선언 영역

BEGIN

   OPEN P_RS_LIST FOR 
   SELECT NULL FROM DUAL WHERE ROWNUM = 0;

   V_DEBUG := 'N';
   V_RUN_SQL := 'Y';

   V_JSON := JSON_OBJECT_T.parse(P_JSON_STR);

   V_SESS_USER_ID       :=       V_JSON.get_string('SES_USER_ID');
   V_PLT_CD             :=       V_JSON.get_string('SES_PLNTKY');

   /* 조건값 할당 */
   V_RANGE_SQL          :=       V_JSON.get_string('RANGE_SQL');
   V_UNIT               :=       V_JSON.get_string('UNIT');

   IF P_TYPE = 'LIST' THEN /*상단 조회 리스트*/

        V_SQL := '  SELECT  m004.UNIT           AS "UNIT",        -- 단위
                            m004.USE_YN         AS "USE_YN",     -- 사용유무
                            m004.REGDATE        AS "REGDATE",
                            NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = m004.REGID),'''')      AS "REGNM",
                            m004.UPDDATE        AS "UPDDATE",
                            NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = m004.UPDID),'''')     AS "UPDNM"
                      FROM TB_MAS004 m004
                     WHERE 1 = 1 ' ;

        V_SQL := V_SQL || V_RANGE_SQL;

        IF V_UNIT IS NOT NULL OR TRIM(V_UNIT) != '' THEN
            V_SQL := V_SQL || ' AND m004.UNIT LIKE ''%' || V_UNIT || '%''';
        END IF;

		V_SQL := V_SQL || ' ORDER BY m004.UNIT';

        --V_DEBUG := 'Y';

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
