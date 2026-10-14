
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_QLT01_POP02_S01" (
	P_TYPE           IN    varchar2, -- LIST, SAVE
	P_JSON_STR       IN    CLOB,
	P_SUCCESS       OUT    varchar2,
	P_RS_LIST       OUT    SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : QLT01_POP02{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 품질검사 항목별 세부결과 입력 POP-UP{호출 프로그램 명 기술}
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 품질검사 항목별 세부결과 입력을 위해 팝업창을 열어 
 *                 세부결과을 입력처리한다.{프로그램에 대한 상세한 내용 기술}
 *                 
 * AUTHOR NAME   : 김성하{최초 작성자 명 기술}
 * CREATE DATE   : 2022/04/28 {최초 작성일자 기술}
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
 *       - [CMCDV]      : (.R..) 공통코드
 *       - [USRMA]      : (.R..) 사용자 정보               
 *       - [TB_MAS014]  : (.R..) 검사항목그룹별 항목관리                              
 *       - [TB_MAS016]  : (.R..) 검사항목별 기준값 정보                              
 *       - [TB_QLT022]  : (C.U.) 검사항목별 측정결과(세부) 
 *=============================================================================*/

AS

    V_PRG_NM          VARCHAR2(100)  := 'SP_QLT01_POP02_S01';     -- PROCEDURE NAME

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
    V_ARR_HEAD       JSON_OBJECT_T;
    V_OBJ            JSON_OBJECT_T;
    V_OBJ_HEAD       JSON_OBJECT_T;

    -- 세션값 처리용 변수선언 영역
    V_SQL            CLOB;
    V_RUN_SQL        varchar2(1);
    V_RANGE_SQL      varchar2(4000);
    V_DEBUG          varchar2(1);

    -- 세션값 처리용 변수선언 영역
    V_PLT_CD         varchar2(2);
    V_SESS_USER_ID   varchar2(20);

    -- 조건절 처리용 변수선언 영역


    V_MSRM_ACC         TB_MAS014.MSRM_ACC%TYPE;

    V_INSP_ITEM_GRP_CD TB_QLT022.INSP_ITEM_GRP_CD%TYPE;
    V_WERKS            TB_QLT022.WERKS%TYPE; -- 플랜트코드
    V_MATNR            TB_QLT022.MATNR%TYPE; -- 자재코드
    V_MSRM_DATE        TB_QLT022.MSRM_DATE%TYPE;
    V_PRC_SEQNO        TB_QLT022.PRC_SEQNO%TYPE;
    V_INSP_ITEM_CD     TB_QLT022.INSP_ITEM_CD%TYPE;
    V_INSP_SEQNO       TB_QLT022.INSP_SEQNO%TYPE;    
    V_RST_VAL          TB_QLT022.RST_VAL%TYPE;

    V_MSRM_DT          VARCHAR2(20) := '';
    V_AVG_RST_VAL      TB_QLT021.RST_VAL%TYPE;

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
   V_RANGE_SQL          :=       V_JSON.get_string('RANGE_SQL');     -- 플랜트코드, 자재그룹, 자재코드

   V_INSP_ITEM_GRP_CD   :=       V_JSON.get_string('INSP_ITEM_GRP_CD'); 

   V_MSRM_ACC           :=       V_JSON.get_number('MSRM_ACC');      -- 측정차수
   V_INSP_ITEM_CD       :=       V_JSON.get_string('INSP_ITEM_CD');  -- 플랜트코드
   V_WERKS              :=       V_JSON.get_string('WERKS');         -- 플랜트코드
   V_MATNR              :=       V_JSON.get_string('MATNR');         -- 자재코드
   V_PRC_SEQNO          :=       V_JSON.get_number('PRC_SEQNO');
   V_MSRM_DT            :=       V_JSON.get_string('MSRM_DATE');

   IF P_TYPE = 'LIST' THEN /*상단 조회 리스트*/

      V_SQL := '  SELECT A.INSP_ITEM_GRP_CD AS "INSP_ITEM_GRP_CD",
                         C.INSP_ITEM_CD     AS "INSP_ITEM_CD",
                         C.INSP_ITEM_NM     AS "INSP_ITEM_NM",
                         C.MID_CAT_NM       AS "MID_CAT_NM",
                         C.BIG_CAT_NM       AS "BIG_CAT_NM",
                         (SELECT CDESC1 FROM CMCDV WHERE CMCDKY = ''INPTDIV'' AND CMCDVL = C.INPT_DIV) AS "INPT_DIV",
                         (SELECT CDESC1 FROM CMCDV WHERE CMCDKY = ''INPTTYP'' AND CMCDVL = C.INPT_TYP) AS "INPT_TYP",                           
                         (SELECT CDESC1 FROM CMCDV WHERE CMCDKY = ''INPTMTD'' AND CMCDVL = C.INPT_MTD) AS "INPT_MTD",          
                         C.MSRM_UNIT        AS "MSRM_UNIT",           -- 측정단위
                         C.STD_VAL          AS "STD_VAL",             -- 기준값
                         C.UPP_VAL          AS "UPP_VAL",             -- 상한값
                         C.LOW_VAL          AS "LOW_VAL",             -- 하한값                         
                         B.RST_VAL          AS "RST_VAL",             -- 결과값
                         A.MATNR            AS "MATNR",
                         A.WERKS            AS "WERKS",
                         A.MSRM_DATE        AS "MSRM_DATE",
                         A.PRC_SEQNO        AS "PRC_SEQNO",
                         A.INSP_SEQNO       AS "INSP_SEQNO",
                         B.REGDATE          AS "REGDATE",
                         NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = B.REGID),'' '') AS "REGNM",
                         B.UPDDATE          AS "UPDDATE",
                         NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = B.UPDID),'' '') AS "UPDNM"
                   FROM 
                       ( SELECT LEVEL                 AS "INSP_SEQNO",
                                '''|| V_INSP_ITEM_GRP_CD ||'''                AS "INSP_ITEM_GRP_CD",
                                '''|| V_MATNR ||'''   AS "MATNR",
                                '''|| V_WERKS ||'''   AS "WERKS",
                                TO_DATE('''|| V_MSRM_DT ||''',''YYYY-MM-DD HH24:MI:SS'') AS "MSRM_DATE",
                                TO_NUMBER(''' || V_PRC_SEQNO ||''')                      AS "PRC_SEQNO",
                                '''|| V_INSP_ITEM_CD ||'''                               AS "INSP_ITEM_CD" 
                           FROM DUAL
                        CONNECT BY LEVEL <= TO_NUMBER(''' || V_MSRM_ACC ||''')) A,
                       ( SELECT INSP_ITEM_GRP_CD,
                                MATNR,
                                WERKS,
                                MSRM_DATE,
                                PRC_SEQNO,
                                INSP_ITEM_CD,
                                INSP_SEQNO,
                                RST_VAL,
                                REGDATE,
                                REGID,
                                UPDDATE,
                                UPDID
                           FROM  TB_QLT022
                          WHERE  INSP_ITEM_GRP_CD  = '''|| V_INSP_ITEM_GRP_CD ||'''
                            AND  MATNR             = '''|| V_MATNR ||'''
                            AND  WERKS             = '''|| V_WERKS ||'''
                            AND  MSRM_DATE         = TO_DATE('''|| V_MSRM_DT ||''',''YYYY-MM-DD HH24:MI:SS'')
                            AND  PRC_SEQNO         = TO_NUMBER(''' || V_PRC_SEQNO ||''')
                            AND  INSP_ITEM_CD      = '''|| V_INSP_ITEM_CD ||''' ) B,
                       ( SELECT M014.INSP_ITEM_GRP_CD,
                                M014.INSP_ITEM_CD,
                                M014.INSP_ITEM_NM,
                                M014.PROD_GRP_CD,
                                M014.MID_CAT_NM,
                                M014.BIG_CAT_NM,
                                M014.MSRM_UNIT,
                                M016.STD_VAL,             -- 기준값
                                M016.UPP_VAL,             -- 상한값
                                M016.LOW_VAL,             -- 하한값                         
                                M014.INPT_DIV,
                                M014.MSRM_ACC, 
                                M014.INPT_TYP,
                                M014.INPT_MTD,
                                M014.MSRM_MTD
                           FROM TB_MAS014 M014,
                                TB_MAS016 M016
                          WHERE M014.INSP_ITEM_GRP_CD  = M016.INSP_ITEM_GRP_CD(+)
                            AND M014.INSP_ITEM_CD      = M016.INSP_ITEM_CD(+)
                            AND M016.MATNR             = '''|| V_MATNR ||'''
                            AND M016.WERKS             = '''|| V_WERKS ||'''
                            AND M014.INSP_ITEM_GRP_CD  = '''|| V_INSP_ITEM_GRP_CD ||''' 
                            AND M014.INSP_ITEM_CD      = '''|| V_INSP_ITEM_CD ||'''  ) C 
                WHERE  A.INSP_ITEM_GRP_CD  = B.INSP_ITEM_GRP_CD(+)
                  AND  A.MATNR             = B.MATNR(+)
                  AND  A.WERKS             = B.WERKS(+) 
                  AND  A.MSRM_DATE         = B.MSRM_DATE(+)
                  AND  A.PRC_SEQNO         = B.PRC_SEQNO(+)
                  AND  A.INSP_ITEM_CD      = B.INSP_ITEM_CD(+)
                  AND  A.INSP_SEQNO        = B.INSP_SEQNO(+) 
                  AND  A.INSP_ITEM_GRP_CD  = C.INSP_ITEM_GRP_CD(+)
                  AND  A.INSP_ITEM_CD      = C.INSP_ITEM_CD(+)';

		V_SQL := V_SQL || ' ORDER BY A.INSP_SEQNO';

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
          RETURN;

    ELSIF P_TYPE = 'SAVE' THEN
        V_ARR_HEAD           := TREAT(V_JSON.get ('head') AS json_object_t);
        V_ARR_LIST           := V_JSON.get_array('list');

        FOR i IN 0..V_ARR_LIST.get_size-1 LOOP

                V_OBJ           := TREAT (V_ARR_LIST.get (i) AS json_object_t);
                V_OBJ           := TREAT (V_OBJ.get ('map') AS json_object_t);

                V_INSP_ITEM_GRP_CD  := V_OBJ.get_string('INSP_ITEM_GRP_CD');
                V_INSP_ITEM_CD      := V_OBJ.get_string('INSP_ITEM_CD');
                V_WERKS             := V_OBJ.get_string('WERKS');
                V_MATNR             := V_OBJ.get_string('MATNR');
                V_MSRM_DATE         := V_OBJ.get_date('MSRM_DATE');          /*측정일시*/
                V_PRC_SEQNO         := V_OBJ.get_number('PRC_SEQNO');
                V_INSP_SEQNO        := V_OBJ.get_number('INSP_SEQNO');
                V_MSRM_DT           := V_OBJ.get_string('MSRM_DATE');
                V_RST_VAL           := V_OBJ.get_number('RST_VAL');

                IF V_OBJ.get_string('GRowState') = 'C' THEN  --추가가 있나?
                      RETURN; 

                ELSIF  V_OBJ.get_string('GRowState') = 'U' THEN

                       -- 공정창고 재고를 위치를 부적합창고로 이전 시킨다.(2010) 
                       BEGIN
                            MERGE
                                  INTO  TB_QLT022 Q022
                                 USING  DUAL
                                    ON  ( INSP_ITEM_GRP_CD  = V_INSP_ITEM_GRP_CD 
                                     AND  MATNR             = V_MATNR 
                                     AND  WERKS             = V_WERKS  
                                     AND  MSRM_DATE         = TO_DATE( V_MSRM_DT ,'YYYY-MM-DD HH24:MI:SS') 
                                     AND  PRC_SEQNO         = V_PRC_SEQNO 
                                     AND  INSP_ITEM_CD      = V_INSP_ITEM_CD 
                                     AND  INSP_SEQNO        = V_INSP_SEQNO )
                            WHEN MATCHED THEN
                                   UPDATE
                                       SET RST_VAL                =  V_RST_VAL
                                         , UPDDATE                =  SYSDATE
                                         , UPDID                  =  V_SESS_USER_ID             
                            WHEN NOT MATCHED THEN
                                    INSERT (
                                            INSP_ITEM_GRP_CD,
                                            MATNR,
                                            WERKS,
                                            MSRM_DATE,
                                            PRC_SEQNO,
                                            INSP_ITEM_CD,
                                            INSP_SEQNO, 
                                            RST_VAL,
                                            REGDATE,
                                            REGID
                                    ) VALUES (
                                            V_INSP_ITEM_GRP_CD,
                                            V_MATNR,
                                            V_WERKS,
                                            TO_DATE( V_MSRM_DT ,'YYYY-MM-DD HH24:MI:SS'),
                                            V_PRC_SEQNO,
                                            V_INSP_ITEM_CD,
                                            V_INSP_SEQNO, 
                                            V_RST_VAL,
                                            SYSDATE,
                                            V_SESS_USER_ID);
                            EXCEPTION           
                            WHEN OTHERS THEN 
                                  P_SUCCESS           := 'N';
                                  E_SQL_ERR_CD        := SQLCODE;
                                  E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR(I001). [' || SUBSTR(SQLERRM,1,500) || ']';
                                  ROLLBACK;

                                  SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
                                  RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);           
                                  RETURN;           
                       END; 
                        
				ELSIF V_OBJ.get_string('GRowState') = 'D' THEN  -- 삭제가 있나?
                      RETURN;              

                END IF;

            END LOOP;

            BEGIN  
               SELECT AVG(RST_VAL)  
                 INTO V_AVG_RST_VAL
                 FROM TB_QLT022 Q022
               WHERE  INSP_ITEM_GRP_CD  = V_INSP_ITEM_GRP_CD 
                 AND  MATNR             = V_MATNR 
                 AND  WERKS             = V_WERKS  
                 AND  MSRM_DATE         = TO_DATE( V_MSRM_DT ,'YYYY-MM-DD HH24:MI:SS') 
                 AND  PRC_SEQNO         = V_PRC_SEQNO 
                 AND  INSP_ITEM_CD      = V_INSP_ITEM_CD;
            EXCEPTION           
            WHEN OTHERS THEN 
                  P_SUCCESS           := 'N';
                  E_SQL_ERR_CD        := SQLCODE;
                  E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR(Q022). [' || SUBSTR(SQLERRM,1,500) || ']';
                  ROLLBACK;

                  SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
                  RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);           
                  RETURN;           
            END; 
                                                         
            BEGIN
                MERGE
                      INTO  TB_QLT021 Q021
                     USING  DUAL
                        ON  ( INSP_ITEM_GRP_CD  = V_INSP_ITEM_GRP_CD 
                         AND  MATNR             = V_MATNR 
                         AND  WERKS             = V_WERKS  
                         AND  MSRM_DATE         = TO_DATE( V_MSRM_DT ,'YYYY-MM-DD HH24:MI:SS') 
                         AND  PRC_SEQNO         = V_PRC_SEQNO 
                         AND  INSP_ITEM_CD      = V_INSP_ITEM_CD )
                WHEN MATCHED THEN
                       UPDATE
                           SET RST_VAL                =  V_AVG_RST_VAL
                             , UPDDATE                =  SYSDATE
                             , UPDID                  =  V_SESS_USER_ID             
                WHEN NOT MATCHED THEN
                        INSERT (
                                INSP_ITEM_GRP_CD,
                                MATNR,
                                WERKS,
                                MSRM_DATE,
                                PRC_SEQNO,
                                INSP_ITEM_CD,
                                RST_VAL,
                                REGDATE,
                                REGID
                        ) VALUES (
                                V_INSP_ITEM_GRP_CD,
                                V_MATNR,
                                V_WERKS,
                                TO_DATE( V_MSRM_DT ,'YYYY-MM-DD HH24:MI:SS'),
                                V_PRC_SEQNO,
                                V_INSP_ITEM_CD,
                                V_AVG_RST_VAL,
                                SYSDATE,
                                V_SESS_USER_ID);
                EXCEPTION           
                WHEN OTHERS THEN 
                      P_SUCCESS           := 'N';
                      E_SQL_ERR_CD        := SQLCODE;
                      E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR(I001). [' || SUBSTR(SQLERRM,1,500) || ']';
                      ROLLBACK;

                      SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
                      RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);           
                      RETURN;           
            END; 

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
        SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);

        ROLLBACK;

    WHEN OTHERS THEN
	    P_SUCCESS           := 'N';
        E_SQL_ERR_CD        := -20000;
       	E_SQL_ERR_MSG       := SQLCODE || ': EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';
        SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);

        ROLLBACK;
        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
END

;
/
