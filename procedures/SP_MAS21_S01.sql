
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_MAS21_S01" (
	P_TYPE           IN    varchar2, -- LIST, SAVE
	P_JSON_STR       IN    CLOB,
	P_SUCCESS       OUT    varchar2,
	P_RS_LIST       OUT    SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : MAS21{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 측정그룹별 검사항목관리{호출 프로그램 명 기술}
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 품질검사 측정그룹별 항목을 관리한다.{프로그램에 대한 상세한 내용 기술}
 *                 
 * AUTHOR NAME   : 김성하{최초 작성자 명 기술}
 * CREATE DATE   : 2022/03/31 {최초 작성일자 기술}
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
 *       - [TB_MAS014] : (CRUD) 품질검사 측정 항목정보                                
 *=============================================================================*/

AS

    V_PRG_NM          VARCHAR2(100)  := 'SP_MAS21_S01';     -- PROCEDURE NAME

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
    V_INSP_ITEM_GRP_CD TB_MAS014.INSP_ITEM_GRP_CD%TYPE;
    V_INSP_ITEM_NM     TB_MAS014.INSP_ITEM_NM%TYPE;

    -- 리스트(그리드)의 값을 할당하기 위한 변수선언 영역    
    V_INSP_ITEM_CD     TB_MAS014.INSP_ITEM_CD%TYPE;
    V_PROD_GRP_CD      TB_MAS014.PROD_GRP_CD%TYPE;
    V_MID_CAT_NM       TB_MAS014.MID_CAT_NM%TYPE;
    V_BIG_CAT_NM       TB_MAS014.BIG_CAT_NM%TYPE;
--    V_INSP_STD_1       TB_MAS014.INSP_STD_1%TYPE;
--    V_INSP_STD_2       TB_MAS014.INSP_STD_2%TYPE;
    V_INPT_DIV         TB_MAS014.INPT_DIV%TYPE;
    V_MSRM_CYC         TB_MAS014.MSRM_CYC%TYPE;
    V_MSRM_ACC         TB_MAS014.MSRM_ACC%TYPE;
    V_NECSY_YN         TB_MAS014.NECSY_YN%TYPE;
    V_INPT_TYP         TB_MAS014.INPT_TYP%TYPE;
    V_INPT_MTD         TB_MAS014.INPT_MTD%TYPE;
    V_MSRM_MTD         TB_MAS014.MSRM_MTD%TYPE;
    V_MSRM_UNIT        TB_MAS014.MSRM_UNIT%TYPE;
    V_INSP_SPEC        TB_MAS014.INSP_SPEC%TYPE;
    V_INSP_REP_YN      TB_MAS014.INSP_REP_YN%TYPE;
    V_CPK_YN           TB_MAS014.CPK_YN%TYPE;
    V_DISP_SEQ         TB_MAS014.DISP_SEQ%TYPE;
    V_USE_YN           TB_MAS014.USE_YN%TYPE;

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
   V_INSP_ITEM_GRP_CD   :=       V_JSON.get_string('INSP_ITEM_GRP_CD');
   --V_INSP_ITEM_NM       :=       V_JSON.get_string('INSP_ITEM_NM');
   V_PROD_GRP_CD       :=       V_JSON.get_string('PROD_GRP_CD');


   IF P_TYPE = 'LIST' THEN /*상단 조회 리스트*/

        V_SQL :=  ' SELECT   M014.INSP_ITEM_GRP_CD AS "INSP_ITEM_GRP_CD"
                          ,  M014.INSP_ITEM_CD     AS "INSP_ITEM_CD"
                          ,  M014.INSP_ITEM_NM     AS "INSP_ITEM_NM"
                          ,  M014.PROD_GRP_CD      AS "PROD_GRP_CD"
                          ,  M014.MID_CAT_NM       AS "MID_CAT_NM"
                          ,  M014.BIG_CAT_NM       AS "BIG_CAT_NM"
--                          ,  M014.INSP_STD_1       AS "INSP_STD_1"
--                          ,  M014.INSP_STD_2       AS "INSP_STD_2"
                          ,  M014.INPT_DIV         AS "INPT_DIV"
                          ,  M014.MSRM_CYC         AS "MSRM_CYC"
                          ,  M014.MSRM_ACC         AS "MSRM_ACC"
                          ,  M014.NECSY_YN         AS "NECSY_YN"
                          ,  M014.INPT_TYP         AS "INPT_TYP"
                          ,  M014.INPT_MTD         AS "INPT_MTD"
                          ,  M014.MSRM_MTD         AS "MSRM_MTD"
                          ,  M014.MSRM_UNIT        AS "MSRM_UNIT"
                          ,  M014.INSP_SPEC        AS "INSP_SPEC"
                          ,  M014.INSP_REP_YN      AS "INSP_REP_YN"
                          ,  M014.CPK_YN           AS "CPK_YN"
                          ,  M014.DISP_SEQ         AS "DISP_SEQ"
                          ,  M014.USE_YN           AS "USE_YN"
                          ,  M014.REGDATE
                          ,  NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = M014.REGID),'''') AS "REGNM"
                          ,  M014.UPDDATE
                          ,  NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = M014.UPDID),'''') AS "UPDNM"
                    FROM TB_MAS014 M014 
                   WHERE 1 = 1 ';

        IF V_RANGE_SQL IS NOT NULL OR TRIM(V_RANGE_SQL) != '' THEN
        	V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'INSP_ITEM_NM', 'M014.INSP_ITEM_NM');	--검사항목명
            V_SQL := V_SQL || V_RANGE_SQL;
        END IF;

        IF  V_INSP_ITEM_GRP_CD IS NOT NULL OR TRIM(V_INSP_ITEM_GRP_CD) != '' THEN
            V_SQL := V_SQL || 'AND M014.INSP_ITEM_GRP_CD = ''' || V_INSP_ITEM_GRP_CD || '''';        
        END IF;

        /*IF  V_INSP_ITEM_NM IS NOT NULL OR TRIM(V_INSP_ITEM_NM) != '' THEN
            V_SQL := V_SQL || 'AND M014.INSP_ITEM_NM LIKE ''%' || V_INSP_ITEM_NM || '%''';        
        END IF;*/

        IF  V_PROD_GRP_CD IS NOT NULL OR TRIM(V_PROD_GRP_CD) != '' THEN
            V_SQL := V_SQL || 'AND M014.PROD_GRP_CD = ''' || V_PROD_GRP_CD || '''';        
        END IF;

		V_SQL := V_SQL || ' ORDER BY M014.INSP_ITEM_GRP_CD, M014.DISP_SEQ';

        BEGIN           
   	    	OPEN P_RS_LIST FOR V_SQL;

        EXCEPTION           
        WHEN OTHERS THEN 
            P_SUCCESS           := 'N';
            E_SQL_ERR_CD        := SQLCODE;
            E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

            SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
            RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);           
            RETURN;           
        END;    

    ELSIF P_TYPE = 'SUB_LIST' THEN  /* 하부 상세 조회 리스트*/
          RETURN;								

    ELSIF P_TYPE = 'SAVE' THEN
        --V_ARR_HEAD        := V_JSON.get_array('head');
        V_ARR_LIST        := V_JSON.get_array('list');

        FOR i IN 0..V_ARR_LIST.get_size-1 LOOP


                V_OBJ               := TREAT (V_ARR_LIST.get (i) AS json_object_t);
                V_OBJ               := TREAT (V_OBJ.get ('map') AS json_object_t);

                V_INSP_ITEM_GRP_CD  := V_OBJ.get_string('INSP_ITEM_GRP_CD');
                V_INSP_ITEM_CD      := V_OBJ.get_string('INSP_ITEM_CD');
                V_INSP_ITEM_NM      := V_OBJ.get_string('INSP_ITEM_NM');
                V_PROD_GRP_CD       := V_OBJ.get_string('PROD_GRP_CD');
                V_MID_CAT_NM        := V_OBJ.get_string('MID_CAT_NM');
                V_BIG_CAT_NM        := V_OBJ.get_string('BIG_CAT_NM');
  --              V_INSP_STD_1        := V_OBJ.get_string('INSP_STD_1');
  --              V_INSP_STD_2        := V_OBJ.get_string('INSP_STD_2');
                V_INPT_DIV          := V_OBJ.get_string('INPT_DIV');
                V_MSRM_CYC          := V_OBJ.get_string('MSRM_CYC');
                V_MSRM_ACC          := V_OBJ.get_string('MSRM_ACC');
                V_NECSY_YN          := V_OBJ.get_string('NECSY_YN');
                V_INPT_TYP          := V_OBJ.get_string('INPT_TYP');
                V_INPT_MTD          := V_OBJ.get_string('INPT_MTD');
                V_MSRM_MTD          := V_OBJ.get_string('MSRM_MTD');
                V_MSRM_UNIT         := V_OBJ.get_string('MSRM_UNIT');
                V_INSP_SPEC         := V_OBJ.get_string('INSP_SPEC');
                V_INSP_REP_YN       := V_OBJ.get_string('INSP_REP_YN');
                V_CPK_YN            := V_OBJ.get_string('CPK_YN');
                V_DISP_SEQ          := V_OBJ.get_number('DISP_SEQ');
                V_USE_YN            := V_OBJ.get_string('USE_YN');

                IF V_OBJ.get_string('GRowState') = 'C' THEN


                   BEGIN                    
                        INSERT INTO TB_MAS014 (
                                INSP_ITEM_GRP_CD,
                                INSP_ITEM_CD,
                                INSP_ITEM_NM,
                                PROD_GRP_CD,
                                MID_CAT_NM,
                                BIG_CAT_NM,
--                                INSP_STD_1,
--                                INSP_STD_2,
                                INPT_DIV,
                                MSRM_CYC,
                                MSRM_ACC,
                                NECSY_YN,
                                INPT_TYP,
                                INPT_MTD,
                                MSRM_MTD,
                                MSRM_UNIT,
                                INSP_SPEC,
                                INSP_REP_YN,
                                CPK_YN,
                                DISP_SEQ,
                                USE_YN,
                                REGDATE,
                                REGID
                            ) VALUES (
                                V_INSP_ITEM_GRP_CD,
                                V_INSP_ITEM_CD,
                                V_INSP_ITEM_NM,
                                V_PROD_GRP_CD,
                                V_MID_CAT_NM,
                                V_BIG_CAT_NM,
--                                V_INSP_STD_1,
--                                V_INSP_STD_2,
                                V_INPT_DIV,
                                V_MSRM_CYC,
                                V_MSRM_ACC,
                                V_NECSY_YN,
                                V_INPT_TYP,
                                V_INPT_MTD,
                                V_MSRM_MTD,
                                V_MSRM_UNIT,
                                V_INSP_SPEC,
                                V_INSP_REP_YN,
                                V_CPK_YN,
                                V_DISP_SEQ,
                                V_USE_YN,
                                SYSDATE,
                                V_SESS_USER_ID 
                            ); 

                         EXCEPTION           
                        WHEN OTHERS THEN 
                            P_SUCCESS           := 'N';
                            E_SQL_ERR_CD        := SQLCODE;
                            E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';
                            ROLLBACK;

                            SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
                            RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);           
                            RETURN;           
                        END; 

                ELSIF V_OBJ.get_string('GRowState') = 'U' THEN

                      BEGIN   
                          UPDATE TB_MAS014
                            SET INSP_ITEM_NM     = V_INSP_ITEM_NM,
                                PROD_GRP_CD      = V_PROD_GRP_CD,
                                MID_CAT_NM       = V_MID_CAT_NM,
                                BIG_CAT_NM       = V_BIG_CAT_NM,
  --                              INSP_STD_1       = V_INSP_STD_1,
  --                              INSP_STD_2       = V_INSP_STD_2,
                                INPT_DIV         = V_INPT_DIV,
                                MSRM_CYC         = V_MSRM_CYC,
                                MSRM_ACC         = V_MSRM_ACC,
                                NECSY_YN         = V_NECSY_YN,
                                INPT_TYP         = V_INPT_TYP,
                                INPT_MTD         = V_INPT_MTD,
                                MSRM_MTD         = V_MSRM_MTD,
                                MSRM_UNIT        = V_MSRM_UNIT,
                                INSP_SPEC        = V_INSP_SPEC,
                                INSP_REP_YN      = V_INSP_REP_YN,
                                CPK_YN           = V_CPK_YN,
                                DISP_SEQ         = V_DISP_SEQ,
                                USE_YN           = V_USE_YN,
                                UPDDATE          = SYSDATE,
                                UPDID            = V_SESS_USER_ID                   
                          WHERE INSP_ITEM_GRP_CD = V_INSP_ITEM_GRP_CD
                            AND INSP_ITEM_CD     = V_INSP_ITEM_CD;                            
                        EXCEPTION           
                        WHEN OTHERS THEN 
                            P_SUCCESS           := 'N';
                            E_SQL_ERR_CD        := SQLCODE;
                            E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';
                            ROLLBACK;

                            SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
                            RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);           
                            RETURN;           
                        END; 

				ELSIF V_OBJ.get_string('GRowState') = 'D' THEN

					DELETE FROM TB_MAS014 WHERE  INSP_ITEM_GRP_CD = V_INSP_ITEM_GRP_CD AND   INSP_ITEM_CD     = V_INSP_ITEM_CD; 
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
