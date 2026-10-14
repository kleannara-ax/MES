--------------------------------------------------------
--  DDL for Procedure SP_MAS32_S01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_MAS32_S01" (
	P_TYPE           IN    varchar2, -- LIST, SUB_LIST, SUB_SAVE
	P_JSON_STR       IN    CLOB,
	P_SUCCESS       OUT    varchar2,
	P_RS_LIST       OUT    SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : MAS32{호출 프로그램 ID 기술}
 * PROGRAM NAME  : HL 완제품 검사(물성)(검사 항목별 기준값 관리{호출 프로그램 명 기술}
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 품질검사(완제품 검사) 측정항목별 기준값을 관리한다.{프로그램에 대한 상세한 내용 기술}
 *                 
 * AUTHOR NAME   : 여한진{최초 작성자 명 기술}
 * CREATE DATE   : 2022/04/20 {최초 작성일자 기술}
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
 *       - [TB_MAS001] : (.R..) 자재 마스터                                
 *       - [TB_MAS015] : (CRUD) 검사항목별 기준정보 등록 마스트                              
 *       - [TB_MAS016] : (CRUD) 검사항목별 기준값 정보                                
 *=============================================================================*/

AS

    V_PRG_NM          VARCHAR2(100)  := 'SP_MAS32_S01';     -- PROCEDURE NAME

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
    V_WERKS            TB_MAS015.WERKS%TYPE;            -- 플랜트코드
    V_MATNR            TB_MAS015.MATNR%TYPE;            -- 자재코드
    V_MATNR_NM         TB_MAS001.MATNR_NM%TYPE;         -- 자재명
    V_MATNR_DIV        TB_MAS001.MATNR_DIV%TYPE;        -- 자재유형
    V_MATNR_GRP_CD     TB_MAS001.MATNR_GRP_CD%TYPE;     -- 자재그룹
    V_REG_YN           VARCHAR2(1);                     -- 등록여부

    -- 리스트(그리드)의 값을 할당하기 위한 변수선언 영역        
    V_INSP_ITEM_GRP_CD TB_MAS015.INSP_ITEM_GRP_CD%TYPE; 
    V_INSP_ITEM_CD     TB_MAS016.INSP_ITEM_CD%TYPE;

    V_STD_VAL          TB_MAS016.STD_VAL%TYPE;
    V_UPP_VAL          TB_MAS016.UPP_VAL%TYPE;
    V_LOW_VAL          TB_MAS016.LOW_VAL%TYPE;
    V_STD_SEL          TB_MAS016.STD_SEL%TYPE;
    V_INSP_STD_1       TB_MAS016.INSP_STD_1%TYPE;
    V_INSP_STD_2       TB_MAS016.INSP_STD_2%TYPE;

    --기타처리
    V_CREATE_FLG       CHAR(1)  := 'N';
    V_UPDATE_FLG       CHAR(1)  := 'N';    
    V_M016_CNT         NUMBER   := 0;

BEGIN
   OPEN P_RS_LIST FOR 
   SELECT NULL FROM DUAL WHERE ROWNUM = 0;

   V_DEBUG   := 'N';
   V_RUN_SQL := 'Y';

   V_JSON := JSON_OBJECT_T.parse(P_JSON_STR);

   V_SESS_USER_ID       :=       V_JSON.get_string('SES_USER_ID');
   V_PLT_CD             :=       V_JSON.get_string('SES_WAREKY');

   /* 조건값 할당 */
   V_RANGE_SQL          :=       V_JSON.get_string('RANGE_SQL'); -- 플랜트코드, 자재그룹, 자재코드

   V_WERKS              :=       V_JSON.get_string('WERKS');     -- 플랜트코드
   V_MATNR_NM           :=       V_JSON.get_string('MATNR_NM');     -- 자재명 
   V_REG_YN             :=       V_JSON.get_string('REG_YN');    -- 등록여부
   V_INSP_ITEM_GRP_CD   :=       V_JSON.get_string('INSP_ITEM_GRP_CD'); -- 검사항목그룹
   V_MATNR              :=       V_JSON.get_string('MATNR');            -- 자재코드
   V_MATNR_DIV          :=       V_JSON.get_string('MATNR_DIV');     -- 자재유형

   IF P_TYPE = 'LIST' THEN /*좌측 조회 리스트 HL 완제품 만*/

        V_SQL :=  ' SELECT M001.WERKS                                        AS "WERKS"
                         , M001.MATNR                                        AS "MATNR" 
                         , M001.MATNR_NM                                        AS "MATNR_NM"
                         , M015.INSP_ITEM_GRP_CD                             AS "INSP_ITEM_GRP_CD"
                         , DECODE(M015.INSP_ITEM_GRP_CD, NULL, ''N'', ''Y'') AS "REG_YN"
                         , M001.REGDATE
                         , NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = M015.REGID),'' '') AS "REGNM"
                         , M001.UPDDATE
                         , NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = M015.UPDID),'' '') AS "UPDNM"
                      FROM TB_MAS001 M001,
                           (SELECT * FROM TB_MAS015 WHERE INSP_ITEM_GRP_CD = ''H3'') M015
                     WHERE M001.MATNR = M015.MATNR(+)
                       AND M001.WERKS = M015.WERKS(+)
                       AND M001.WERKS NOT IN (''P400'', ''P100'' )
                       AND M001.MATNR_STA IS NULL
                       AND M001.MATNR_DIV = ''FERT'' ';

        IF  V_RANGE_SQL IS NOT NULL OR TRIM(V_RANGE_SQL) != '' THEN -- 자재그룹, 자재코드
            V_SQL := V_SQL || V_RANGE_SQL;
        END IF;                     

        IF V_WERKS IS NOT NULL OR TRIM(V_WERKS) != '' THEN          -- 플랜트
            V_SQL := V_SQL || ' AND M001.WERKS = ''' || V_WERKS || '''';
        END IF;

        IF  V_MATNR_DIV IS NOT NULL OR TRIM(V_MATNR_DIV) != '' THEN -- 자재유형
            V_SQL := V_SQL || ' AND M001.MATNR_DIV =''' || V_MATNR_DIV || '''';
        END IF;

        IF  V_MATNR_NM IS NOT NULL OR TRIM(V_MATNR_NM) != '' THEN -- 자재명
            V_SQL := V_SQL || ' AND M001.MATNR_NM  LIKE ''%' || V_MATNR_NM || '%''';             
        END IF;

        IF  V_REG_YN IS NOT NULL OR TRIM(V_REG_YN) != '' THEN -- 등록여부
            V_SQL := V_SQL || ' AND DECODE(M015.INSP_ITEM_GRP_CD, NULL, ''N'', ''Y'') = '''|| TRIM(V_REG_YN) || '''';
--        ELSE
--            V_SQL := V_SQL || ' AND M015.INSP_ITEM_GRP_CD IS NULL ';            
        END IF;

		V_SQL := V_SQL || ' ORDER BY M001.MATNR';


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


    ELSIF P_TYPE = 'SUB_LIST' THEN  /* 우측 상세 조회 리스트*/

		V_INSP_ITEM_GRP_CD   := V_JSON.get_string('INSP_ITEM_GRP_CD');
		V_INSP_ITEM_CD       := V_JSON.get_string('INSP_ITEM_CD'); 

        V_SQL :=  ' SELECT A.INSP_ITEM_GRP_CD,
                           A.INSP_ITEM_CD,
                           A.INSP_ITEM_NM,
                           A.PROD_GRP_CD, -- 제품군(ㅇㅇㅇㅇ)
                           A.MID_CAT_NM,
                           A.BIG_CAT_NM,
                --         A.INPT_DIV, -- 입력구분(CM)
                           (SELECT CDESC1 FROM CMCDV WHERE CMCDKY = ''INPTDIV'' AND CMCDVL = A.INPT_DIV) AS "INPT_DIV",
                --         A.MSRM_CYC, -- 측정주기(CM)
                           (SELECT CDESC1 FROM CMCDV WHERE CMCDKY = ''MSRMUNIT'' AND CMCDVL = A.MSRM_CYC) AS "MSRM_CYC",
                           A.MSRM_ACC,
                           A.NECSY_YN, -- 필수입력 여부
                --         A.INPT_TYP, -- 입력 타입(CM)
                           (SELECT CDESC1 FROM CMCDV WHERE CMCDKY = ''INPTTYP'' AND CMCDVL = A.INPT_TYP) AS "INPT_TYP",                           
                --         A.INPT_MTD, -- 입력방법(CM)
                           (SELECT CDESC1 FROM CMCDV WHERE CMCDKY = ''INPTMTD'' AND CMCDVL = A.INPT_MTD) AS "INPT_MTD",          
                           A.MSRM_MTD, -- 측정방법
                           A.MSRM_UNIT,-- 측정단위
                           A.INSP_SPEC,
                           A.CPK_YN , --CPK 여부 
                           B.MATNR, 
                           B.WERKS, 
                           B.STD_VAL, --기준값
                           B.UPP_VAL, --상한값H
                           B.LOW_VAL, --하한값
                           B.STD_SEL, --기준선택값
                           B.INSP_STD_1, --기준값(1)
                           B.INSP_STD_2, --기준값(2)
                           B.REGDATE,
                           B.REGNM,
                           B.UPDDATE,
                           B.UPDNM
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
                                CPK_YN,
                                DISP_SEQ,
                                USE_YN
                        FROM  TB_MAS014 M014 
                        WHERE  M014.INSP_ITEM_GRP_CD = ''H3''
                          AND  M014.PROD_GRP_CD  = FN_GET_PROD_GRP( '''|| V_WERKS || ''','''|| V_MATNR ||''' )
                              ) A, -- HL 완제품 검사(물성) 항목만 표시
                              (SELECT INSP_ITEM_GRP_CD, 
                                      INSP_ITEM_CD, 
                                      MATNR, 
                                      WERKS, 
                                      STD_VAL, 
                                      UPP_VAL, 
                                      LOW_VAL, 
                                      STD_SEL, 
                                      INSP_STD_1, 
                                      INSP_STD_2,
                                      REGDATE,
                                      NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = TB_MAS016.REGID),'''') AS "REGNM",
                                      UPDDATE,
                                      NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = TB_MAS016.UPDID),'''') AS "UPDNM"
                                 FROM TB_MAS016 
                                WHERE MATNR      = '''|| V_MATNR ||''' 
                                  AND WERKS      = '''|| V_WERKS ||''') B
                    WHERE A.INSP_ITEM_GRP_CD = B.INSP_ITEM_GRP_CD(+)
                      AND A.INSP_ITEM_CD     = B.INSP_ITEM_CD(+)
                      AND A.USE_YN           = ''Y''
                 ORDER BY A.DISP_SEQ  ';

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


    ELSIF P_TYPE = 'SAVE' THEN
          RETURN;            

    ELSIF P_TYPE = 'SUB_SAVE' THEN

        -- 상단의 선택된 그리드 맵에서 가져온다.
        V_ARR_HEAD           := V_JSON.get_array('head');    
  	 	V_INSP_ITEM_GRP_CD   := V_JSON.get_string('INSP_ITEM_GRP_CD'); /*품질측정그룹*/ 

        FOR i IN 0..V_ARR_HEAD.get_size-1 LOOP

              V_OBJ_HEAD           := TREAT (V_ARR_HEAD.get (i) AS json_object_t);
              V_OBJ_HEAD           := TREAT (V_OBJ_HEAD.get ('map') AS json_object_t);

              V_WERKS              := V_OBJ_HEAD.get_string('WERKS');   
              V_MATNR              := V_OBJ_HEAD.get_string('MATNR');        

              -- 하단의 선택된 그리드 맵에서 가져온다.
              V_ARR_LIST           := V_JSON.get_array('list'); 

              FOR j IN 0..V_ARR_LIST.get_size-1 LOOP

                    V_OBJ_LIST          := TREAT (V_ARR_LIST.get (j) AS json_object_t); 
                    V_OBJ_LIST          := TREAT (V_OBJ_LIST.get ('map') AS json_object_t);

                    V_INSP_ITEM_CD      := V_OBJ_LIST.get_string('INSP_ITEM_CD');
                    V_STD_VAL           := V_OBJ_LIST.get_number('STD_VAL');
                    V_UPP_VAL           := V_OBJ_LIST.get_number('UPP_VAL');
                    V_LOW_VAL           := V_OBJ_LIST.get_number('LOW_VAL');
                    V_STD_SEL           := V_OBJ_LIST.get_string('STD_SEL');
                    V_INSP_STD_1        := V_OBJ_LIST.get_string('INSP_STD_1');
                    V_INSP_STD_2        := V_OBJ_LIST.get_string('INSP_STD_2');
    
                    IF V_OBJ_LIST.get_string('GRowState') = 'C' THEN
    
                            BEGIN
                                INSERT INTO TB_MAS016 (
                                            INSP_ITEM_GRP_CD,
                                            INSP_ITEM_CD,
                                            MATNR,
                                            WERKS,
                                            STD_VAL,
                                            UPP_VAL,
                                            LOW_VAL,
                                            STD_SEL,
                                            INSP_STD_1,
                                            INSP_STD_2,
                                            REGDATE,
                                            REGID
                                ) VALUES (
                                            V_INSP_ITEM_GRP_CD,
                                            V_INSP_ITEM_CD,
                                            V_MATNR,
                                            V_WERKS,
                                            V_STD_VAL,
                                            V_UPP_VAL,
                                            V_LOW_VAL,
                                            V_STD_SEL,
                                            V_INSP_STD_1,
                                            V_INSP_STD_2,
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
    
                    ELSIF V_OBJ_LIST.get_string('GRowState') = 'U' THEN
    
                            BEGIN
                                  MERGE
                                      INTO  TB_MAS016 M016
                                     USING  DUAL
                                        ON  ( M016.INSP_ITEM_GRP_CD   =  V_INSP_ITEM_GRP_CD
                                       AND  INSP_ITEM_CD              =  V_INSP_ITEM_CD
                                       AND  M016.MATNR                =  V_MATNR
                                       AND  M016.WERKS                =  V_WERKS)
                                  WHEN MATCHED THEN
                                       UPDATE
                                           SET STD_VAL                =  V_STD_VAL
                                             , UPP_VAL                =  V_UPP_VAL
                                             , LOW_VAL                =  V_LOW_VAL
                                             , STD_SEL                =  V_STD_SEL
                                             , INSP_STD_1             =  V_INSP_STD_1
                                             , INSP_STD_2             =  V_INSP_STD_2
                                             , UPDDATE                =  SYSDATE
                                             , UPDID                  =  V_SESS_USER_ID                   
                                  WHEN NOT MATCHED THEN
                                       INSERT (
                                                INSP_ITEM_GRP_CD,
                                                INSP_ITEM_CD,
                                                MATNR,
                                                WERKS,
                                                STD_VAL,
                                                UPP_VAL,
                                                LOW_VAL,
                                                STD_SEL,
                                                INSP_STD_1,
                                                INSP_STD_2,
                                                REGDATE,
                                                REGID
                                        ) VALUES (
                                                V_INSP_ITEM_GRP_CD,
                                                V_INSP_ITEM_CD,
                                                V_MATNR,
                                                V_WERKS,
                                                V_STD_VAL,
                                                V_UPP_VAL,
                                                V_LOW_VAL,
                                                V_STD_SEL,
                                                V_INSP_STD_1,
                                                V_INSP_STD_2,
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
    
                    ELSIF V_OBJ_LIST.get_string('GRowState') = 'D' THEN
    
                          BEGIN                 
                               DELETE FROM TB_MAS016 
                                WHERE INSP_ITEM_GRP_CD = V_INSP_ITEM_GRP_CD AND   INSP_ITEM_CD     = V_INSP_ITEM_CD AND MATNR = V_MATNR AND WERKS = V_WERKS;
    
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
    
                        -- M016을 읽어서 1 개도 없으면 M015도 삭제
                        SELECT NVL(COUNT(*),0) INTO V_M016_CNT 
                          FROM TB_MAS016 
                         WHERE INSP_ITEM_GRP_CD = V_INSP_ITEM_GRP_CD AND   INSP_ITEM_CD     = V_INSP_ITEM_CD AND MATNR = V_MATNR AND WERKS = V_WERKS;
    
                        IF V_M016_CNT = 0 THEN
    
                           BEGIN
                               DELETE FROM TB_MAS015 
                                WHERE INSP_ITEM_GRP_CD = V_INSP_ITEM_GRP_CD AND   MATNR = V_MATNR AND WERKS = V_WERKS;
    
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
    
                        END IF;
    
                    END IF;
    
              END LOOP;
    
              BEGIN
                  MERGE
                      INTO  TB_MAS015 M015
                     USING  DUAL
                        ON (M015.INSP_ITEM_GRP_CD   =  V_INSP_ITEM_GRP_CD
                       AND  M015.MATNR              =  V_MATNR
                       AND  M015.WERKS              =  V_WERKS)
                  WHEN MATCHED THEN
                         UPDATE
                            SET  M015.CHG_CNT         =  M015.CHG_CNT  +  1
                               , M015.UPDDATE         =  SYSDATE                        /* 수정일자*/
                               , M015.UPDID           =  V_SESS_USER_ID                 /* 수정자 */
                  WHEN NOT MATCHED THEN
                        INSERT (
                                INSP_ITEM_GRP_CD,
                                MATNR,
                                WERKS,
                                CHG_CNT,
                                REGDATE,
                                REGID
                        ) VALUES (
                                V_INSP_ITEM_GRP_CD,
                                V_MATNR,
                                V_WERKS,
                                0,
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
        
        END LOOP;
        
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
        SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, V_STD_VAL||E_SQL_ERR_MSG, V_SESS_USER_ID);

        ROLLBACK;
        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
END;

/
