--------------------------------------------------------
--  DDL for Procedure SP_MAS11_S01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_MAS11_S01" (
	P_TYPE           IN    varchar2, -- LIST, SUB_LIST, SUB_SAVE
	P_JSON_STR       IN    CLOB,
	P_SUCCESS       OUT    varchar2,
	P_RS_LIST       OUT    SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : MAS11{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 설비 마스터 관리{호출 프로그램 명 기술}
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 공장별, 플랜트별 공정별 설비정보를 관리한다.{프로그램에 대한 상세한 내용 기술}
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
 *       - [CMCDV]     : (.R..) 공통코드 상세정보                       
 *       - [TB_MAS002] : (.R..) 플랜트 정보                              
 *       - [TB_MAS012] : (CRUD) 설미 마스터 정보                                
 *       - [TB_MAS013] : (.R..) 공정 정보                              
 *=============================================================================*/

AS

    V_PRG_NM          VARCHAR2(100)  := 'SP_MAS11_S01';     -- PROCEDURE NAME

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
    V_WERKS            TB_MAS015.WERKS%TYPE; -- 플랜트코드

    -- 리스트(그리드)의 값을 할당하기 위한 변수선언 영역        
    V_INSP_ITEM_GRP_CD TB_MAS015.INSP_ITEM_GRP_CD%TYPE; 
    V_INSP_ITEM_CD     TB_MAS016.INSP_ITEM_CD%TYPE;

    V_STD_VAL          TB_MAS016.STD_VAL%TYPE;
    V_UPP_VAL          TB_MAS016.UPP_VAL%TYPE;
    V_LOW_VAL          TB_MAS016.LOW_VAL%TYPE;
    V_STD_SEL          TB_MAS016.STD_SEL%TYPE;
    V_INSP_STD_1       TB_MAS016.INSP_STD_1%TYPE;
    V_INSP_STD_2       TB_MAS016.INSP_STD_2%TYPE;

    V_MACH_CD          TB_MAS012.MACH_CD%TYPE;
    V_MACH_NM          TB_MAS012.MACH_NM%TYPE;
    V_MACH_SHRT_NM     TB_MAS012.MACH_SHRT_NM%TYPE;
    V_PROC_CD          TB_MAS012.PROC_CD%TYPE;
    V_LINE             TB_MAS012.LINE%TYPE;
    V_IFMC             TB_MAS012.IFMC%TYPE;
    V_INST_DT          TB_MAS012.INST_DT%TYPE;
    V_ASST_NO          TB_MAS012.ASST_NO%TYPE;
    V_PRD_UNIT         TB_MAS012.PRD_UNIT%TYPE;
    V_DISPO_DT         TB_MAS012.DISPO_DT%TYPE;
    V_SAP_WRK_CD       TB_MAS012.SAP_WRK_CD%TYPE;
    V_SAP_WRK_NM       TB_MAS012.SAP_WRK_NM%TYPE;
    V_SAP_COST_CD      TB_MAS012.SAP_COST_CD%TYPE;
    V_WCS_WRK_CD       TB_MAS012.WCS_WRK_CD%TYPE;
    V_WCS_WRK_NM       TB_MAS012.WCS_WRK_NM%TYPE;
    V_PRFM_GTHR_YN     TB_MAS012.PRFM_GTHR_YN%TYPE;
    V_ABN_STD_TM       TB_MAS012.ABN_STD_TM%TYPE;
    V_CYCLE_TM         TB_MAS012.CYCLE_TM%TYPE;
    V_WRK_CD           TB_MAS012.WRK_CD%TYPE;
    V_MACHINE          TB_MAS012.MACHINE%TYPE;
    V_DISP_SEQ         TB_MAS012.DISP_SEQ%TYPE;

    V_PROC_NM          TB_MAS013.PROC_NM%TYPE;
    V_BUSICD           TB_MAS002.BUSICD%TYPE;

    --기타처리
    V_CREATE_FLG       CHAR(1)  := 'N';
    V_UPDATE_FLG       CHAR(1)  := 'N';    
    V_M016_CNT         NUMBER   := 0;

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

   V_WERKS              :=       V_JSON.get_string('WERKS');      -- 플랜트 코드
   V_MACH_NM            :=       V_JSON.get_string('MACH_NM');    -- 설비명
   V_PROC_NM            :=       V_JSON.get_string('PROC_NM');    -- 공정명 
   V_BUSICD             :=       V_JSON.get_string('BUSICD');     -- 사업부

   IF P_TYPE = 'LIST' THEN /*조회 리스트*/

        V_SQL :=  ' SELECT  M012.MACH_CD      --(입력)
                          , M012.MACH_NM      --(입력)
                          , M012.MACH_SHRT_NM --(입력)
                          , M012.PROC_CD      --(선택:서치핼프)
                          , M013.WERKS        --플랜트코드  
                          , M013.PROC_NM      --공정명
                          , M013.PROC_GRP_CD  --공정그룹코드
                          , M013.PROC_GRP_NM  --공정그룹명
                          , M013.PLANTNM      --플랜트명
                          , M013.BUSICD       --사업부코드
                          , M013.BUSINM      --사업부명
                          , M013.PROD_GRP_CD  --제품군코드
                          , M013.PROD_GRP_NM  --제품군명
                          , M012.LINE         --(입력)
                          , M012.IFMC         --(입력)
                          , M012.INST_DT      --(입력:YYYYMM)
                          , M012.ASST_NO      --(입력)
                          , M012.PRD_UNIT     --(선택: 콤보)
                          , M012.DISPO_DT     --(입력:YYYYMMDD)
                          , M012.SAP_WRK_CD   --(입력)
                          , M012.SAP_WRK_NM   --(입력)
                          , M012.SAP_COST_CD  --(입력)
                          , M012.WCS_WRK_CD   --(입력)
                          , M012.WCS_WRK_NM   --(입력)
                          , M012.PRFM_GTHR_YN --(입력)
                          , M012.ABN_STD_TM   --(입력)
                          , M012.CYCLE_TM     --(입력)
						  , M012.DISP_SEQ	  --(자동/수동 입력)
                          , M012.WRK_CD       --SAP작업장코드(지시)
                          , M012.MACHINE      --설비호기
                          , M012.REGDATE
                          , NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = M012.REGID),'''') AS "REGNM"
                          , M012.UPDDATE
                          , NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = M012.UPDID),'''') AS "UPDNM"
                      FROM TB_MAS012 M012,
                           (
                            SELECT  M013.PROC_CD          AS "PROC_CD",     
                                    M013.PROC_NM          AS "PROC_NM",
                                    M013.PROC_GRP_CD      AS "PROC_GRP_CD",
                                    CMDV_A.CDESC1         AS "PROC_GRP_NM",
                                    M013.WERKS            AS "WERKS",
                                    M002.PLANTNM          AS "PLANTNM",
                                    M013.PROD_GRP_CD      AS "PROD_GRP_CD",
                                    CMDV_B.CDESC1         AS "PROD_GRP_NM",
                                    M002.BUSICD           AS "BUSICD",
                                    CMDV_C.CDESC1         AS "BUSINM"
                             FROM  TB_MAS013 M013,  
                                   TB_MAS002 M002, 
                                   (SELECT CMCDVL, CDESC1 FROM CMCDV WHERE CMCDKY = ''PROCGRP'') CMDV_A, 
                                   (SELECT CMCDVL, CDESC1 FROM CMCDV WHERE CMCDKY = ''PRODGRP'') CMDV_B, 
                                   (SELECT CMCDVL, CDESC1 FROM CMCDV WHERE CMCDKY = ''BUSICD'')  CMDV_C  
                            WHERE  M013.PROC_GRP_CD = CMDV_A.CMCDVL(+)
                              AND  M013.WERKS       = M002.WERKS(+)
                              AND  M013.PROD_GRP_CD = CMDV_B.CMCDVL(+)
                              AND  M002.BUSICD      = CMDV_C.CMCDVL(+)                           
                           ) M013
                     WHERE M012.PROC_CD = M013.PROC_CD(+)';

        IF  V_WERKS IS NOT NULL OR TRIM(V_WERKS) != '' THEN -- 플랜트
            V_SQL := V_SQL || ' AND M013.WERKS  = ''' || V_WERKS || '''';             
        END IF;

        IF  V_RANGE_SQL IS NOT NULL OR TRIM(V_RANGE_SQL) != '' THEN -- skip(미사용:삭제금지)
            V_SQL := V_SQL || V_RANGE_SQL;
        END IF;                     

        IF  V_MACH_NM IS NOT NULL OR TRIM(V_MACH_NM) != '' THEN -- 설비명
            V_SQL := V_SQL || ' AND ( M012.MACH_NM  LIKE ''%' || V_MACH_NM || '%''';             
            V_SQL := V_SQL || '  OR M012.MACH_SHRT_NM  LIKE ''%' || V_MACH_NM || '%'' )';             
        END IF;

        IF  V_PROC_NM IS NOT NULL OR TRIM(V_PROC_NM) != '' THEN -- 공정명
            V_SQL := V_SQL || ' AND M013.PROC_NM  LIKE ''%' || V_PROC_NM || '%''';             
        END IF;

        IF  V_BUSICD IS NOT NULL OR TRIM(V_BUSICD) != '' THEN -- 사업부 코드
            V_SQL := V_SQL || ' AND M013.BUSICD  = ''' || V_BUSICD || '''';             
        END IF;

		V_SQL := V_SQL || ' ORDER BY M012.MACH_CD, M013.WERKS, M013.PROC_CD ';

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
          RETURN;

    ELSIF P_TYPE = 'SAVE' THEN
        --V_ARR_HEAD        := V_JSON.get_array('head');
        V_ARR_LIST        := V_JSON.get_array('list');

        FOR i IN 0..V_ARR_LIST.get_size-1 LOOP

                V_OBJ               := TREAT (V_ARR_LIST.get (i) AS json_object_t);
                V_OBJ               := TREAT (V_OBJ.get ('map') AS json_object_t);

                V_MACH_CD           := V_OBJ.get_string('MACH_CD');
                V_MACH_NM           := V_OBJ.get_string('MACH_NM');
                V_MACH_SHRT_NM      := V_OBJ.get_string('MACH_SHRT_NM');
                V_PROC_CD           := V_OBJ.get_string('PROC_CD');
                V_LINE              := V_OBJ.get_number('LINE');
                V_IFMC              := V_OBJ.get_string('IFMC');
                V_INST_DT           := V_OBJ.get_string('INST_DT');
                V_ASST_NO           := V_OBJ.get_string('ASST_NO');
                V_PRD_UNIT          := V_OBJ.get_string('PRD_UNIT');
                V_DISPO_DT          := V_OBJ.get_string('DISPO_DT');
                V_SAP_WRK_CD        := V_OBJ.get_string('SAP_WRK_CD');
                V_SAP_WRK_NM        := V_OBJ.get_string('SAP_WRK_NM');
                V_SAP_COST_CD       := V_OBJ.get_string('SAP_COST_CD');
                V_WCS_WRK_CD        := V_OBJ.get_string('WCS_WRK_CD');
                V_WCS_WRK_NM        := V_OBJ.get_string('WCS_WRK_NM');
                V_PRFM_GTHR_YN      := V_OBJ.get_string('PRFM_GTHR_YN');
                V_ABN_STD_TM        := V_OBJ.get_number('ABN_STD_TM');
                V_CYCLE_TM          := V_OBJ.get_number('CYCLE_TM');
                V_WRK_CD          := V_OBJ.get_number('WRK_CD');
                V_MACHINE          := V_OBJ.get_string('MACHINE');
                V_INSP_ITEM_GRP_CD  := V_OBJ.get_string('INSP_ITEM_GRP_CD');
                V_INSP_ITEM_CD      := V_OBJ.get_string('INSP_ITEM_CD');
--                V_MATNR             := V_OBJ.get_string('MATNR');
--                V_WERKS             := V_OBJ.get_string('WERKS');
                V_STD_VAL           := V_OBJ.get_number('STD_VAL');
                V_UPP_VAL           := V_OBJ.get_number('UPP_VAL');
                V_LOW_VAL           := V_OBJ.get_number('LOW_VAL');
                V_STD_SEL           := V_OBJ.get_string('STD_SEL');
                V_INSP_STD_1        := V_OBJ.get_string('INSP_STD_1');
                V_INSP_STD_2        := V_OBJ.get_string('INSP_STD_2');
                V_DISP_SEQ        	:= V_OBJ.get_number('DISP_SEQ');

                IF V_OBJ.get_string('GRowState') = 'C' THEN

                    IF (V_RUN_SQL = 'Y') THEN
                        BEGIN

                            INSERT INTO TB_MAS012 (
                                     MACH_CD
                                   , MACH_NM
                                   , MACH_SHRT_NM
                                   , PROC_CD
                                   , LINE
                                   , IFMC
                                   , INST_DT
                                   , ASST_NO
                                   , PRD_UNIT
                                   , DISPO_DT
                                   , SAP_WRK_CD
                                   , SAP_WRK_NM
                                   , SAP_COST_CD
                                   , WCS_WRK_CD
                                   , WCS_WRK_NM
                                   , PRFM_GTHR_YN
                                   , ABN_STD_TM
                                   , CYCLE_TM
                                   , WRK_CD
                                   , MACHINE
                                   , REGDATE
                                   , REGID
                                   , DISP_SEQ
                            ) VALUES (
                                     V_MACH_CD
                                   , V_MACH_NM
                                   , V_MACH_SHRT_NM
                                   , V_PROC_CD
                                   , V_LINE
                                   , V_IFMC
                                   , V_INST_DT
                                   , V_ASST_NO
                                   , V_PRD_UNIT
                                   , V_DISPO_DT
                                   , V_SAP_WRK_CD
                                   , V_SAP_WRK_NM
                                   , V_SAP_COST_CD
                                   , V_WCS_WRK_CD
                                   , V_WCS_WRK_NM
                                   , V_PRFM_GTHR_YN
                                   , V_ABN_STD_TM
                                   , V_CYCLE_TM
                                   , V_WRK_CD
                                   , V_MACHINE
                                   , SYSDATE
                                   , V_SESS_USER_ID
                                   , V_DISP_SEQ
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


                    END IF;

                ELSIF V_OBJ.get_string('GRowState') = 'U' THEN

                    IF (V_RUN_SQL = 'Y') THEN

                        BEGIN
                              MERGE
                                  INTO  TB_MAS012 M012
                                 USING  DUAL
                                    ON  ( M012.MACH_CD   =  V_MACH_CD )
                              WHEN MATCHED THEN
                                   UPDATE
                                       SET  MACH_NM       = V_MACH_NM
                                          , MACH_SHRT_NM  = V_MACH_SHRT_NM
                                          , PROC_CD       = V_PROC_CD
                                          , LINE          = V_LINE
                                          , IFMC          = V_IFMC
                                          , INST_DT       = V_INST_DT
                                          , ASST_NO       = V_ASST_NO
                                          , PRD_UNIT      = V_PRD_UNIT
                                          , DISPO_DT      = V_DISPO_DT
                                          , SAP_WRK_CD    = V_SAP_WRK_CD
                                          , SAP_WRK_NM    = V_SAP_WRK_NM
                                          , SAP_COST_CD   = V_SAP_COST_CD
                                          , WCS_WRK_CD    = V_WCS_WRK_CD
                                          , WCS_WRK_NM    = V_WCS_WRK_NM
                                          , PRFM_GTHR_YN  = V_PRFM_GTHR_YN
                                          , ABN_STD_TM    = V_ABN_STD_TM
                                          , CYCLE_TM      = V_CYCLE_TM
                                          , WRK_CD        = V_WRK_CD
                                          , MACHINE       = V_MACHINE
                                          , UPDDATE       = SYSDATE
                                          , UPDID         = V_SESS_USER_ID
                                          , DISP_SEQ	  = V_DISP_SEQ
                              WHEN NOT MATCHED THEN
                                    INSERT  (
                                             MACH_CD
                                           , MACH_NM
                                           , MACH_SHRT_NM
                                           , PROC_CD
                                           , LINE
                                           , IFMC
                                           , INST_DT
                                           , ASST_NO
                                           , PRD_UNIT
                                           , DISPO_DT
                                           , SAP_WRK_CD
                                           , SAP_WRK_NM
                                           , SAP_COST_CD
                                           , WCS_WRK_CD
                                           , WCS_WRK_NM
                                           , PRFM_GTHR_YN
                                           , ABN_STD_TM
                                           , CYCLE_TM
                                           , WRK_CD
                                           , MACHINE
                                           , REGDATE
                                           , REGID
                                           , DISP_SEQ
                                    ) VALUES (
                                             V_MACH_CD
                                           , V_MACH_NM
                                           , V_MACH_SHRT_NM
                                           , V_PROC_CD
                                           , V_LINE
                                           , V_IFMC
                                           , V_INST_DT
                                           , V_ASST_NO
                                           , V_PRD_UNIT
                                           , V_DISPO_DT
                                           , V_SAP_WRK_CD
                                           , V_SAP_WRK_NM
                                           , V_SAP_COST_CD
                                           , V_WCS_WRK_CD
                                           , V_WCS_WRK_NM
                                           , V_PRFM_GTHR_YN
                                           , V_ABN_STD_TM
                                           , V_CYCLE_TM
                                           , V_WRK_CD
                                           , V_MACHINE
                                           , SYSDATE
                                           , V_SESS_USER_ID
                                           , V_DISP_SEQ
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

                    END IF;                   

				ELSIF V_OBJ.get_string('GRowState') = 'D' THEN
                      BEGIN                 
					       DELETE FROM TB_MAS012 
                            WHERE MACH_CD = V_MACH_CD;

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

            END LOOP;

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
