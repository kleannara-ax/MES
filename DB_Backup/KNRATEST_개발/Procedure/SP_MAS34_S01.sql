--------------------------------------------------------
--  DDL for Procedure SP_MAS34_S01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_MAS34_S01" (
	P_TYPE           IN    varchar2, -- LIST, SUB_LIST, SUB_SAVE
	P_JSON_STR       IN    CLOB,
	P_SUCCESS       OUT    varchar2,
	P_RS_LIST       OUT    SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : MAS34{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 거래처정보{호출 프로그램 명 기술}
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : NextHR에서의 거래처정보를 조회한다.{프로그램에 대한 상세한 내용 기술}
 *                 
 * AUTHOR NAME   : 강동호{최초 작성자 명 기술}
 * CREATE DATE   : 2022/04/18 {최초 작성일자 기술}
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
 *       - [TB_MAS022] : (.R..) 일자별 베일 중량 정보                                
 *=============================================================================*/

AS

    V_PRG_NM          VARCHAR2(100)  := 'SP_MAS34_S01';     -- PROCEDURE NAME

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
    V_WERKS         TB_MAS022.WERKS%TYPE;      
    V_DT            TB_MAS022.DT%TYPE;
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

   V_WERKS              :=       V_JSON.get_string('WERKS');       -- 플랜트
   V_DT           :=       V_JSON.get_string('DT');       -- 일자 



   IF P_TYPE = 'LIST' THEN /*좌측 조회 리스트*/


        V_SQL :=  ' SELECT M022.WERKS       AS "WERKS"
                         , TO_CHAR(TO_DATE(M022.DT),''YYYY-MM-DD'')       AS "DT"
                         , M022.WEIGHT_V       AS "WEIGHT_V"
                    FROM  TB_MAS022 M022 
                    WHERE 1=1 ';

        IF  V_RANGE_SQL IS NOT NULL OR TRIM(V_RANGE_SQL) != '' THEN -- Skip(미사용:삭제금지)
            V_SQL := V_SQL || V_RANGE_SQL;
        END IF;                

        IF  V_WERKS IS NOT NULL OR TRIM(V_WERKS) != '' THEN -- 플랜트
            V_SQL := V_SQL || ' AND M022.WERKS = ''' || V_WERKS || '''';             
        END IF;

        IF  V_DT IS NOT NULL OR TRIM(V_DT) != '' THEN -- 일자
            V_SQL := V_SQL || ' AND M022.DT  LIKE ''%' || V_DT || '%''';             
        END IF;

		V_SQL := V_SQL || ' ORDER BY M022.DT';

       -- V_DEBUG := 'Y';

        IF (V_DEBUG = 'Y') THEN
            INSERT INTO PROC_LOG(SQL_STR) VALUES (V_SQL);
        END IF;

       INSERT INTO PROC_LOG(SQL_STR) VALUES (V_SQL);

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
