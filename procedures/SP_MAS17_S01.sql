
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_MAS17_S01" (
	P_TYPE           IN    varchar2, -- LIST
	P_JSON_STR       IN    CLOB ,
	P_SUCCESS       OUT    varchar2,
	P_RS_LIST       OUT    SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : MAS17{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 공정별 비가동항목관리{호출 프로그램 명 기술}
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 각 플랜트별 공정별 비가동항목을 관리한다.{프로그램에 대한 상세한 내용 기술}
 *                 
 * AUTHOR NAME   : 여한진{최초 작성자 명 기술}
 * CREATE DATE   : 2022/04/13 {최초 작성일자 기술}
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
         - [TB_MAS013] : (R) 공정 정보
         - [TB_MAS020] : (R) 비가동항목
 *       - [TB_MAS021] : (CRUD) 공정별 비가동항목                                
 *=============================================================================*/

AS

    V_PRG_NM          VARCHAR2(100)  := 'SP_MAS17_S01';     -- PROCEDURE NAME

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
    V_WERKS           TB_MAS021.WERKS%TYPE;
    V_PROC_CD         TB_MAS021.PROC_CD%TYPE;
    V_ABN_CD          TB_MAS021.ABN_CD%TYPE;
    V_ABN_NM          TB_MAS020.ABN_NM%TYPE;

    -- 리스트(그리드)의 값을 할당하기 위한 변수선언 영역
    V_USE_YN          TB_MAS021.USE_YN%TYPE;

BEGIN

   OPEN P_RS_LIST FOR 
   SELECT NULL FROM DUAL WHERE ROWNUM = 0;

   V_DEBUG := 'N';
   V_RUN_SQL := 'Y';

   V_JSON := JSON_OBJECT_T.parse(P_JSON_STR);

   V_SESS_USER_ID       :=       V_JSON.get_string('SES_USER_ID');
   V_PLT_CD             :=       V_JSON.get_string('SES_PLNTKY');

   /* 조건값 할당 */
   V_RANGE_SQL          :=       V_JSON.get_string('RANGE_SQL');    -- 공정코드, 비가동항목코드,비가동항목명
   V_WERKS              :=       V_JSON.get_string('WERKS');        -- 플랜트
   --V_ABN_NM             :=       V_JSON.get_string('ABN_NM');       -- 비가동항목명

   IF P_TYPE = 'LIST' THEN /*상단 조회 리스트*/

        V_SQL := ' SELECT  M021.WERKS            AS "WERKS",           -- 플랜트
                           M021.PROC_CD          AS "PROC_CD",         -- 공정코드
                           M013.PROC_NM          AS "PROC_NM",         -- 공정명
                           M021.ABN_CD           AS "ABN_CD",          -- 비가동 항목코드
                           M020.ABN_NM           AS "ABN_NM",          -- 비가동 항목명
                           NVL((SELECT CDESC1 FROM CMCDV WHERE CMCDKY = ''RUNSTA'' AND CMCDVL = M020.RUN_STA), '''')   AS RUN_STA_NM,   -- 운전상태(명)
                           M021.USE_YN           AS "USE_YN",          -- 사용유무
                           M021.REGDATE          AS "REGDATE",
                           NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = M021.REGID),'''') AS "REGNM",
                           M021.UPDDATE          AS "UPDDATE",
                           NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = M021.UPDID),'''') AS "UPDNM"
                     FROM  TB_MAS021 M021, -- 공정별 비가동항목
                           TB_MAS013 M013, -- 공정코드
                           TB_MAS020 M020 -- 비가동항목
                    WHERE  M021.PROC_CD = M013.PROC_CD(+)
                      AND  M021.ABN_CD = M020.ABN_CD(+)
                      AND  M021.WERKS = M020.WERKS(+)' ;

        IF V_RANGE_SQL IS NOT NULL OR TRIM(V_RANGE_SQL) != '' THEN
        	V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'WERKS', 'M021.WERKS');			--플랜트
        	V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'PROC_CD', 'M021.PROC_CD');		--공정코드
        	V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'ABN_CD', 'M021.ABN_CD');		--비가동항목코드
        	V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'ABN_NM', 'M020.ABN_NM');		--비가동항목명
            V_SQL := V_SQL || V_RANGE_SQL;
        END IF;

--        IF  V_WERKS IS NOT NULL OR TRIM(V_WERKS) != '' THEN     -- 플랜트
--            V_SQL := V_SQL || ' AND M021.WERKS = ''' || V_WERKS || '''';        
--        END IF;

        /*IF  V_ABN_NM IS NOT NULL OR TRIM(V_ABN_NM) != '' THEN   -- 비가동항목명
            V_SQL := V_SQL || ' AND M020.ABN_NM LIKE ''%' || V_ABN_NM || '%''';        
        END IF;*/

		V_SQL := V_SQL || ' ORDER BY M021.WERKS, M021.PROC_CD, M021.ABN_CD';

        --V_DEBUG := 'Y';

        IF (V_DEBUG = 'Y') THEN
            INSERT INTO PROC_LOG(SQL_STR) VALUES (V_SQL);
        END IF;

		OPEN P_RS_LIST FOR V_SQL;

    ELSIF P_TYPE = 'SUB_LIST' THEN  /* 하부 상세 조회 리스트*/
          RETURN;								

    ELSIF P_TYPE = 'SAVE' THEN
          --V_ARR_HEAD        := V_JSON.get_array('head');
        V_ARR_LIST        := V_JSON.get_array('list');

        FOR i IN 0..V_ARR_LIST.get_size-1 LOOP

                V_OBJ               := TREAT (V_ARR_LIST.get (i) AS json_object_t);
                V_OBJ               := TREAT (V_OBJ.get ('map') AS json_object_t);

                V_WERKS             := V_OBJ.get_string('WERKS');
                V_PROC_CD           := V_OBJ.get_string('PROC_CD');
				V_ABN_CD            := V_OBJ.get_string('ABN_CD');
                V_USE_YN            := V_OBJ.get_string('USE_YN');

                IF V_OBJ.get_string('GRowState') = 'C' THEN

                    IF (V_RUN_SQL = 'Y') THEN

                        INSERT INTO TB_MAS021
                        (
                            WERKS,
                            PROC_CD,
                            ABN_CD,
                            USE_YN,
                            REGDATE,
                            REGID
                        ) VALUES (
                            V_WERKS,
                            V_PROC_CD,
                            V_ABN_CD,
                            V_USE_YN,
							SYSDATE, 
							V_SESS_USER_ID
					    );

                    END IF;

                ELSIF V_OBJ.get_string('GRowState') = 'U' THEN

                    IF (V_RUN_SQL = 'Y') THEN

                        UPDATE TB_MAS021
                           SET USE_YN       = V_USE_YN,
                               UPDDATE      = SYSDATE,
                               UPDID        = V_SESS_USER_ID
                         WHERE WERKS        = V_WERKS
                           AND PROC_CD      = V_PROC_CD
                           AND ABN_CD       = V_ABN_CD ;

                    END IF;                   

				ELSIF V_OBJ.get_string('GRowState') = 'D' THEN

					DELETE FROM TB_MAS021 WHERE WERKS = V_WERKS AND PROC_CD = V_PROC_CD AND ABN_CD = V_ABN_CD;

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
        E_SQL_ERR_CD        := -20990;
        E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

        ROLLBACK;
        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
END;
/
