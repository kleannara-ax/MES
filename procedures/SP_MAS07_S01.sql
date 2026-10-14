
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_MAS07_S01" (
	P_TYPE           IN    varchar2, -- LIST, SUB_LIST, SUB_SAVE
	P_JSON_STR       IN    CLOB,
	P_SUCCESS       OUT    varchar2,
	P_RS_LIST       OUT    SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : MAS07{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 거래처정보{호출 프로그램 명 기술}
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : NextHR에서의 거래처정보를 조회한다.{프로그램에 대한 상세한 내용 기술}
 *                 
 * AUTHOR NAME   : 강동호{최초 작성자 명 기술}
 * CREATE DATE   : 2022/04/11 {최초 작성일자 기술}
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * yyyy/mm/dd    1.0.0   강동호         Initial Version 
 *==============================================================================
 *  관련 테이블
 *       - [TB_MAS009] : (.R..) 거래처정보                                
 *=============================================================================*/

AS

    V_PRG_NM          VARCHAR2(100)  := 'SP_MAS07_S01';     -- PROCEDURE NAME

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
    V_CUST_DIV      TB_MAS009.CUST_DIV%TYPE;      
    V_CUST_CD       TB_MAS009.CUST_CD%TYPE;
    V_CUST_NM       TB_MAS009.CUST_NM%TYPE;
    -- 리스트(그리드)의 값을 할당하기 위한 변수선언 영역        

    --기타처리
    V_CREATE_FLG       CHAR(1)  := 'N';
    V_UPDATE_FLG       CHAR(1)  := 'N';    

BEGIN
   OPEN P_RS_LIST FOR 
   SELECT NULL FROM DUAL WHERE ROWNUM = 0;

   V_DEBUG := 'N';
   V_RUN_SQL := 'Y';

   V_JSON := JSON_OBJECT_T.parse(P_JSON_STR);

   V_SESS_USER_ID       :=       V_JSON.get_string('SES_USER_ID');
   V_PLT_CD             :=       V_JSON.get_string('SES_WAREKY');

   /* 조건값 할당 */
   V_RANGE_SQL          :=       V_JSON.get_string('RANGE_SQL'); 

   V_CUST_DIV           :=       V_JSON.get_string('CUST_DIV');     -- 거래처구분
   /*V_CUST_CD            :=       V_JSON.get_string('CUST_CD');       -- 거래처코드 
   V_CUST_NM            :=       V_JSON.get_string('CUST_NM');       -- 거래처명*/



   IF P_TYPE = 'LIST' THEN /*좌측 조회 리스트*/


        V_SQL :=  ' SELECT 
                           (SELECT CDESC1 FROM CMCDV WHERE CMCDKY=''CUSTTYPE'' AND CMCDVL = M009.CUST_DIV)     AS "CUST_DIV"      -- 거래처구분
                         , M009.CUST_CD         AS "CUST_CD"        -- 납풉처
                         , M009.CUST_NM         AS "CUST_NM"        -- 납품처명
                         , M009.PSTLZ           AS "PSTLZ"          -- 우편번호
                         , M009.LAND1           AS "LAND1"          -- 국가키
                         , M009.TELF1           AS "TELF1"          -- 전화번호
                         , M009.TELF2           AS "TELF2"          -- 휴대폰번호
                         , M009.TELFX           AS "TELFX"          -- 팩스번호
                         , M009.SMTP_ADDR       AS "SMTP_ADDR"      -- 거래처담당자 email주소
                         , M009.STCD2           AS "STCD2"          -- 사업자등록번호
                         , M009.J_1KFREPRE      AS "J_1KFREPRE"     -- 대표자명
                         , M009.DL_YN           AS "DL_YN"          -- 삭제여부
                         , M009.ADDR1           AS "ADDR1"          -- 도시
                         , M009.ADDR2           AS "ADDR2"          -- 번지 및 상세 주소
                         , M009.KUNNR           AS "KUNNR"          -- 판매처
                         , M009.KUNNRT          AS "KUNNRT"         -- 판매처명
                         , M009.KUNZP           AS "KUNZP"          -- 영업자ID
                         , M009.KUNZPT          AS "KUNZPT"         -- 영업사원명
                         , M009.TELFZP          AS "TELFZP"         -- 영업사원 휴대폰 번호
                         , M009.J_1KFTIND       AS "J_1KFTIND"      -- 업태
                         , M009.J_1KFTBUS       AS "J_1KFTBUS"      -- 업종
                         , M009.CNAME           AS "CNAME"          -- 거래처 담당자명
                         , M009.CPHON           AS "CPHON"          -- 거래처 담당자 휴대폰 번호1
                         , M009.PTNG01          AS "PTNG01"         -- 거래처메모
                         , (SELECT CDESC1 FROM CMCDV WHERE CMCDKY=''PTNL01'' AND CMCDVL = M009.PTNL01)           AS "PTNL01"         -- 공급처구분
                         , (SELECT CDESC1 FROM CMCDV WHERE CMCDKY=''USEYN'' AND CMCDVL = M009.USE_YN)            AS "USE_YN"         -- 사용유무
                         , REGDATE              AS "REGDATE"
                         , NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = M009.REGID),'''')                 AS "REGNM"
                         , UPDDATE              AS "UPDDATE"
                         , NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = M009.UPDID),'''')                 AS "UPDNM"
                    FROM  TB_MAS009 M009 
                    WHERE 1=1 ';

        IF  V_RANGE_SQL IS NOT NULL OR TRIM(V_RANGE_SQL) != '' THEN
        	V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'CUST_CD', 'M009.CUST_CD');	-- 거래처코드
        	V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'CUST_NM', 'M009.CUST_NM');	-- 거래처명
            V_SQL := V_SQL || V_RANGE_SQL;
        END IF;                

        IF  V_CUST_DIV IS NOT NULL OR TRIM(V_CUST_DIV) != '' THEN -- 거래처구분
            V_SQL := V_SQL || ' AND M009.CUST_DIV = ''' || V_CUST_DIV || '''';             
        END IF;

       /* IF  V_CUST_CD IS NOT NULL OR TRIM(V_CUST_CD) != '' THEN -- 거래처코드
            V_SQL := V_SQL || ' AND M009.CUST_CD  LIKE ''%' || V_CUST_CD || '%''';             
        END IF;

        IF  V_CUST_NM IS NOT NULL OR TRIM(V_CUST_NM) != '' THEN -- 거래처명
            V_SQL := V_SQL || ' AND M009.CUST_NM  LIKE ''%' || V_CUST_NM || '%''';             
        END IF;*/

		V_SQL := V_SQL || ' ORDER BY M009.CUST_CD';

        V_DEBUG := 'Y';

        IF (V_DEBUG = 'Y') THEN
            INSERT INTO PROC_LOG(SQL_STR) VALUES (V_SQL);
        END IF;

        OPEN P_RS_LIST FOR V_SQL;

    ELSIF P_TYPE = 'SUB_LIST' THEN  /* 우측 상세 조회 리스트*/
          RETURN;

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
        E_SQL_ERR_CD        := SQLCODE;
        E_SQL_ERR_MSG       := SUBSTRB(SQLERRM,1,300);
        SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);

        ROLLBACK;

    WHEN OTHERS THEN
	    P_SUCCESS           := 'N';
        E_SQL_ERR_CD        := SQLCODE;
        E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';
        SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);

        ROLLBACK;
        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
END;
/
