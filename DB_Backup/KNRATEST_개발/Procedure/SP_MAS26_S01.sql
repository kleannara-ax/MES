--------------------------------------------------------
--  DDL for Procedure SP_MAS26_S01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_MAS26_S01" (
	P_TYPE           IN    varchar2, -- LIST, SAVE
	P_JSON_STR       IN    CLOB,
	P_SUCCESS       OUT    varchar2,
	P_RS_LIST       OUT    SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : MAS26{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 플랜트 정보관리{호출 프로그램 명 기술}
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : SAP에서 내려온 플랜트 정보를 관리한다.{프로그램에 대한 상세한 내용 기술}
 *                 
 * AUTHOR NAME   : 김성하{최초 작성자 명 기술}
 * CREATE DATE   : 2022/03/29 {최초 작성일자 기술}
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
 *       - [TB_MAS002] : (CRUD) 플랜트 정보                                
 *=============================================================================*/

AS

    V_PRG_NM          VARCHAR2(100)  := 'SP_MAS26_S01';     -- PROCEDURE NAME

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
    V_BUSICD         TB_MAS002.BUSICD%TYPE;

    -- 리스트(그리드)의 값을 할당하기 위한 변수선언 영역
    V_WERKS          TB_MAS002.WERKS%TYPE;
    V_PLANTNM        TB_MAS002.PLANTNM%TYPE;
    V_COMPKY         TB_MAS002.COMPKY%TYPE;
    V_WAREKY         TB_MAS002.WAREKY%TYPE;
	V_USE_YN         TB_MAS002.USE_YN%TYPE; 

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
   V_WERKS              :=       V_JSON.get_string('WERKS');
   V_BUSICD             :=       V_JSON.get_string('BUSICD');
   V_PLANTNM            :=       V_JSON.get_string('PLANTNM');

   IF P_TYPE = 'LIST' THEN /*상단 조회 리스트*/

        V_SQL := ' SELECT M002.WERKS      AS "WERKS"   -- 입력
                        , M002.PLANTNM    AS "PLANTNM" -- 입력
                        , M002.COMPKY     AS "COMPKY"  -- 선택(서치핼프:OWNER)
                        , OWN.NAME01      AS "COMPNM"                        
                        , M002.WAREKY     AS "WAREKY"  -- 선택(서치핼프:WAHMA)
                        , WMA.NAME01      AS "WARENM"                        
                        , M002.BUSICD     AS "BUSICD"  -- 선택(콤보-공통코드)
                        , CM.CDESC1       AS "BUSINM"                        
                        , M002.USE_YN     AS "USE_YN"  -- 입력
                        , M002.REGDATE    AS "REGDATE"
                        , NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = M002.REGID),'''') AS "REGNM"
                        , M002.UPDDATE    AS "UPDDATE" 
                        , NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = M002.UPDID),'''') AS "UPDNM" 
                  FROM TB_MAS002 M002,
                       OWNER OWN,
                       WAHMA WMA,
                       CMCDV CM
                 WHERE M002.COMPKY = OWN.COMPKY(+)
                   AND M002.COMPKY = WMA.COMPKY(+)
                   AND M002.WAREKY = WMA.WAREKY(+)
                   AND M002.BUSICD = CM.CMCDVL(+)
                   AND OWN.OWNRKY = ''KN''
                   AND WMA.COMPKY IN (SELECT COMPKY FROM OWNER WHERE OWNRKY = ''KN'' ) 
                   AND CM.CMCDKY =  ''BUSICD'' ';

        V_SQL := V_SQL || V_RANGE_SQL;

        IF  V_WERKS IS NOT NULL OR TRIM(V_WERKS) != '' THEN
            V_SQL := V_SQL || 'AND M002.WERKS = ''' || V_WERKS || '''';        
        END IF;

        IF  V_PLANTNM IS NOT NULL OR TRIM(V_PLANTNM) != '' THEN
            V_SQL := V_SQL || 'AND M002.PLANTNM LIKE ''%' || V_PLANTNM || '%''';        
        END IF;

        IF  V_BUSICD IS NOT NULL THEN
            V_SQL := V_SQL || 'AND M002.BUSICD = ''' || V_BUSICD || '''';        
        END IF;

        IF  TRIM(V_BUSICD) = '' THEN
            V_SQL := V_SQL;        
        END IF;

		V_SQL := V_SQL || ' ORDER BY M002.WERKS';

        --V_DEBUG := 'Y';

        IF (V_DEBUG = 'Y') THEN
            INSERT INTO PROC_LOG(SQL_STR) VALUES (V_SQL);
        END IF;

        DBMS_OUTPUT.PUT_LINE('SQL2=========>' || V_SQL);				

		OPEN P_RS_LIST FOR V_SQL;

    ELSIF P_TYPE = 'SUB_LIST' THEN  /* 하부 상세 조회 리스트*/
          RETURN;								

    ELSIF P_TYPE = 'SAVE' THEN
        --V_ARR_HEAD        := V_JSON.get_array('head');
        V_ARR_LIST        := V_JSON.get_array('list');

        FOR i IN 0..V_ARR_LIST.get_size-1 LOOP

                V_OBJ         := TREAT (V_ARR_LIST.get (i) AS json_object_t);
                V_OBJ         := TREAT (V_OBJ.get ('map') AS json_object_t);

				V_WERKS       := V_OBJ.get_string('WERKS');
                V_PLANTNM     := V_OBJ.get_string('PLANTNM');
				V_COMPKY      := V_OBJ.get_string('COMPKY');
				V_WAREKY      := V_OBJ.get_string('WAREKY');
				V_BUSICD      := V_OBJ.get_string('BUSICD');
				--V_USE_YN      := V_OBJ.get_string('USE_YN');

                IF V_OBJ.get_string('GRowState') = 'C' THEN
                    IF (V_RUN_SQL = 'Y') THEN
                        INSERT INTO TB_MAS002
                        (
                            WERKS,
                            PLANTNM,
                            COMPKY,
                            WAREKY,
                            BUSICD,
                            USE_YN,
                            REGDATE,
                            REGID
                        ) VALUES (
							V_WERKS,
							V_PLANTNM,
							V_COMPKY,
							V_WAREKY,
							V_BUSICD,
                            'Y',
							SYSDATE, 
							V_SESS_USER_ID
					    );

                    END IF;

                ELSIF V_OBJ.get_string('GRowState') = 'U' THEN
                    IF (V_RUN_SQL = 'Y') THEN 
                        DELETE FROM TB_MAS002 WHERE WERKS = V_WERKS;
                    END IF;

                    IF (V_RUN_SQL = 'Y') THEN
                        INSERT INTO TB_MAS002
                        (
                            WERKS,
                            PLANTNM,
                            COMPKY,
                            WAREKY,
                            BUSICD,
                            USE_YN,
                            REGDATE,
                            REGID,
                            UPDDATE,
                            UPDID
                        ) VALUES (
							V_WERKS,
							V_PLANTNM,
							V_COMPKY,
							V_WAREKY,
							V_BUSICD,
                            'Y',
							SYSDATE, 
							V_SESS_USER_ID,
                            SYSDATE,
                            V_SESS_USER_ID
					    );                             

                    END IF;                   

				ELSIF V_OBJ.get_string('GRowState') = 'D' THEN
					DELETE FROM TB_MAS002 WHERE WERKS = V_WERKS; 
                END IF;
            END LOOP;

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
        E_SQL_ERR_CD        := SQLCODE;
        E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

        ROLLBACK;
        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
END;


/
