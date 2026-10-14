
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_WRK06_S01" (
	P_TYPE           IN    varchar2, -- LIST, SAVE
	P_JSON_STR       IN    CLOB ,
	P_SUCCESS       OUT    varchar2,
	P_RS_LIST       OUT    SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : {호출 프로그램 ID 기술}
 * PROGRAM NAME  : 재고실사지시관리
 * VERSION       : {최종 버전 기술}
 * DESCRIPTION   : {프로그램에 대한 상세한 내용 기술}
 *                 
 * AUTHOR NAME   : 유상호{최초 작성자 명 기술}
 * CREATE DATE   : 2022.08.30 {최초 작성일자 기술}
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * yyyy/mm/dd    1.0.0   홍길동         Initial Version
 * yyyy/mm/dd    1.0.1   홍판서         변경사유 기술
 *==============================================================================
 *  관련 테이블
 *       - [CMCDM] : (CRUD) 공통코드 마스트                                       
 *       - [CMCDV] : (CRUD) 공통코드 상세                                       
 *=============================================================================*/

AS

    V_PRG_NM          VARCHAR2(100)  := 'SP_WRK06_S01';     -- PROCEDURE NAME

    -- 오라클 에러 처리용 변수 선언
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5)           := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);

   -- V_RTN_CLOB       CLOB;
   -- V_RTN_CURSOR     SYS_REFCURSOR;
   -- V_ERROR          CLOB;

    -- JSON을 위한 변수 선언
    V_JSON           JSON_OBJECT_T;
    V_ARR_LIST       JSON_ARRAY_T;
    V_ARR_HEAD       JSON_ARRAY_T;
    V_OBJ            JSON_OBJECT_T;

    -- 세션값 처리용 변수 선언
    V_SQL            CLOB;
    V_RUN_SQL        varchar2(1);
    V_RANGE_SQL      varchar2(4000);
    V_DEBUG          varchar2(1);

    -- 세션값 처리용 변수 선언
    V_PLT_CD         varchar2(10);
    V_SESS_USER_ID   varchar2(20);

    V_WERKS             VARCHAR2(10);
    V_WRK_ORDR_NO       TB_INV008.WRK_ORDR_NO%TYPE;
    V_WRK_ORDR_NO_M     TB_INV008.WRK_ORDR_NO%TYPE;
    V_WRK_ORDR_SEQNO    TB_INV015.WRK_ORDR_SEQNO%TYPE;
    V_WRK_REQ_DT        TB_INV008.WRK_REQ_DT%TYPE;
    V_WRK_ORDR_RMK      TB_INV008.WRK_ORDR_RMK%TYPE;
    V_STOR_LOC_CD       TB_INV015.STOR_LOC_CD%TYPE;
    V_MATNR             TB_INV015.MATNR%TYPE;
    V_STOR_LOC_FLG      TB_INV015.STOR_LOC_FLG%TYPE;
    V_MATNR_FLG         TB_INV015.MATNR_FLG%TYPE;
    V_LOC_CD            TB_INV015.LOC_CD%TYPE;
    V_SEQ               NUMBER;
    V_DATE              DATE:= SYSDATE;
BEGIN

   OPEN P_RS_LIST FOR 
   SELECT NULL FROM DUAL WHERE ROWNUM = 0;

   V_DEBUG := 'N';
   V_RUN_SQL := 'Y';
    DBMS_OUTPUT.PUT_LINE('SQL1=========>' || P_JSON_STR);
   V_JSON := JSON_OBJECT_T.parse(P_JSON_STR);

   V_SESS_USER_ID:= V_JSON.get_string('SES_USER_ID');
   V_PLT_CD:= V_JSON.get_string('SES_PLNTKY');

   IF (P_TYPE = 'LIST') THEN /*상단 조회 리스트*/
        V_WERKS         := V_JSON.get_string('WERKS');
        V_RANGE_SQL     := V_JSON.get_string('RANGE_SQL');
        
        
        V_SQL := ' SELECT I008.WERKS,           --플랜트
                          I008.WRK_ORDR_NO,     --실사지시번호
                          I008.WRK_REQ_DT,      --실사지시일자(지시요요청일자)
                          I008.WRK_ORDR_RMK,    --비고
                          FN_CD_VAL(''APVR_STA'', I008.APVR_STA) AS APVR_STA,   --결재상태
                          NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = I008.APPRID),'' '') AS APPR_NM, --승인자
                          I008.APPR_DT,         --승인일자
                          I008.REGDATE,         --등록일자
                          NVL((SELECT NMLAST FROM USRMA WHERE USRMA.USERID = I008.REGID),'' '') AS REGNM   --등록자
                      FROM TB_INV008 I008
                     WHERE 1=1 
    					  --AND I008.WERKS = ''' || V_WERKS || '''
								';
                     
        V_SQL := V_SQL || V_RANGE_SQL;             
        V_SQL := V_SQL || ' ORDER BY I008.WRK_REQ_DT';
        
        INSERT INTO PROC_LOG(SQL_PARAM1) VALUES(V_SQL);
		OPEN P_RS_LIST FOR V_SQL;

   ELSIF (P_TYPE = 'SUB_LIST') THEN  /* 하부 상세 조회 리스트*/

        V_RANGE_SQL         := V_JSON.get_string('RANGE_SQL');
		V_WERKS             := V_JSON.get_string('WERKS');
        V_WRK_ORDR_NO       := V_JSON.get_string('WRK_ORDR_NO');
        
        V_SQL := ' SELECT I015.WERKS,
                          I015.WRK_ORDR_NO,  
                          I015.WRK_ORDR_SEQNO,  
                          NVL(I015.STOR_LOC_FLG, ''N'') AS STOR_LOC_FLG,        --전체선택(Y: 전체, N : 부분)
                          I015.STOR_LOC_CD,
                          M003.STOR_LOC_NM,
                          I015.LOC_CD,
                          M028.LOC_NM,
                          NVL(I015.MATNR_FLG, ''N'')    AS MATNR_FLG,        --전체선택(Y: 전체, N : 부분)
                          I015.MATNR, 
                          M001.MATNR_NM
                     FROM TB_INV015 I015,
                          TB_MAS001 M001,
                          TB_MAS003 M003,
                          TB_MAS028 M028
                    WHERE I015.WERKS = M001.WERKS(+)
                      AND I015.MATNR = M001.MATNR(+)
                      AND I015.WERKS = M003.WERKS(+)
                      AND I015.WERKS = M028.WERKS(+)
                      AND I015.STOR_LOC_CD = M028.STOR_LOC_CD(+)
                      AND I015.LOC_CD = M028.LOC_CD(+)
                      AND I015.STOR_LOC_CD = M003.STOR_LOC_CD(+)
                      AND I015.WERKS = ''' || V_WERKS || '''
                      AND I015.WRK_ORDR_NO = ''' || V_WRK_ORDR_NO || '''
                   ORDER BY I015.WRK_ORDR_NO';    

        IF (V_DEBUG = 'Y') THEN
            INSERT INTO PROC_LOG(SQL_STR) VALUES (V_SQL);
        END IF;

		OPEN P_RS_LIST FOR V_SQL;

    ELSIF P_TYPE = 'SAVE' THEN

        V_ARR_HEAD := V_JSON.get_array('head');
        V_ARR_LIST := V_JSON.get_array('list');

        FOR i IN 0..V_ARR_HEAD.get_size-1 LOOP

            V_OBJ := TREAT (V_ARR_HEAD.get (i) AS json_object_t);
            V_OBJ := TREAT (V_OBJ.get ('map') AS json_object_t);

            V_WERKS             := V_OBJ.get_string('WERKS');
            V_WRK_ORDR_NO       := V_OBJ.get_string('WRK_ORDR_NO');
            V_WRK_REQ_DT        := V_OBJ.get_string('WRK_REQ_DT');
            V_WRK_ORDR_RMK      := V_OBJ.get_string('WRK_ORDR_RMK');

            IF V_OBJ.get_string('GRowState') = 'C' THEN
                IF (V_RUN_SQL = 'Y') THEN
                    
                    BEGIN
                    SELECT TO_NUMBER(SUBSTR(A.WRK_ORDR_NO, -3)) INTO V_SEQ
                      FROM(
                            SELECT WRK_ORDR_NO
                              FROM TB_INV008
                             WHERE WERKS = V_WERKS
                               AND WRK_REQ_DT = V_WRK_REQ_DT
                            ORDER BY REGDATE DESC) A
                     WHERE ROWNUM = 1;
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            V_SEQ := 0;
                    END;
                    
                    V_SEQ := V_SEQ + 1;
                    
                    V_WRK_ORDR_NO := 'S' || V_WRK_REQ_DT || SUBSTR('000' || TO_CHAR(V_SEQ), -3);
                    
                    INSERT INTO TB_INV008( WERKS, WRK_ORDR_NO, WRK_REQ_DT,
                                            WRK_ORDR_RMK, REGDATE, REGID ) 
                                 VALUES (V_WERKS, V_WRK_ORDR_NO, V_WRK_REQ_DT,
                                            V_WRK_ORDR_RMK, V_DATE, V_SESS_USER_ID);
                    END IF;
            ELSIF V_OBJ.get_string('GRowState') = 'U' THEN  
                IF (V_RUN_SQL = 'Y') THEN

                    UPDATE TB_INV008 
                       SET WRK_REQ_DT = V_WRK_REQ_DT,
                           WRK_ORDR_RMK = V_WRK_ORDR_RMK,
                           UPDDATE = V_DATE,
                           UPDID = V_SESS_USER_ID
                     WHERE WERKS = V_WERKS
                       AND WRK_ORDR_NO = V_WRK_ORDR_NO;

                END IF;
            ELSIF V_OBJ.get_string('GRowState') = 'D' THEN
                DELETE 
                  FROM TB_INV008 
                 WHERE WERKS = V_WERKS
                   AND WRK_ORDR_NO = V_WRK_ORDR_NO;
                
                DELETE 
                  FROM TB_INV015 
                 WHERE WERKS = V_WERKS
                   AND WRK_ORDR_NO = V_WRK_ORDR_NO;
            END IF;

        END LOOP;
        
        V_WRK_ORDR_NO_M := V_WRK_ORDR_NO;
        
        FOR i IN 0..V_ARR_LIST.get_size-1 LOOP

            V_OBJ := TREAT (V_ARR_LIST.get (i) AS json_object_t);
            V_OBJ := TREAT (V_OBJ.get ('map') AS json_object_t);

            V_WERKS             := V_OBJ.get_string('WERKS');
            V_WRK_ORDR_NO       := V_OBJ.get_string('WRK_ORDR_NO');
            V_WRK_ORDR_SEQNO    := V_OBJ.get_number('WRK_ORDR_SEQNO');
            V_STOR_LOC_FLG      := V_OBJ.get_string('STOR_LOC_FLG');
            V_STOR_LOC_CD       := V_OBJ.get_string('STOR_LOC_CD');
            V_MATNR_FLG         := V_OBJ.get_string('MATNR_FLG');
            V_MATNR             := V_OBJ.get_string('MATNR');
            V_LOC_CD            := V_OBJ.get_string('LOC_CD');
            
            IF NVL(V_WRK_ORDR_NO, ' ') = ' ' THEN
                V_WRK_ORDR_NO := V_WRK_ORDR_NO_M;
            END IF;
            
            IF V_OBJ.get_string('GRowState') = 'C' THEN
                IF (V_RUN_SQL = 'Y') THEN
                    BEGIN
                    SELECT NVL(MAX(WRK_ORDR_SEQNO), 0) INTO V_WRK_ORDR_SEQNO
                      FROM TB_INV015
                     WHERE WERKS = V_WERKS
                       AND WRK_ORDR_NO = V_WRK_ORDR_NO;
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            V_WRK_ORDR_SEQNO := 0;
                    END;
                    
                    V_WRK_ORDR_SEQNO := V_WRK_ORDR_SEQNO + 1;
                    
                    INSERT INTO TB_INV015(WERKS, WRK_ORDR_NO, WRK_ORDR_SEQNO,
                                    STOR_LOC_CD, MATNR, REGDATE, REGID, MATNR_FLG, STOR_LOC_FLG, LOC_CD)
                            VALUES (V_WERKS, V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO,
                                    V_STOR_LOC_CD, V_MATNR, V_DATE, V_SESS_USER_ID, V_MATNR_FLG, V_STOR_LOC_FLG, V_LOC_CD);
                END IF;

            ELSIF V_OBJ.get_string('GRowState') = 'U' THEN
                IF (V_RUN_SQL = 'Y') THEN

                    UPDATE TB_INV015
                           SET STOR_LOC_CD = V_STOR_LOC_CD,
                               MATNR = V_MATNR,
                               MATNR_FLG = V_MATNR_FLG,
                               STOR_LOC_FLG = V_STOR_LOC_FLG,
                               LOC_CD = V_LOC_CD,
                               UPDDATE = V_DATE,
                               UPDID = V_SESS_USER_ID
                         WHERE WERKS = V_WERKS
                           AND WRK_ORDR_NO = V_WRK_ORDR_NO
                           AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO;

                    END IF;
            ELSIF V_OBJ.get_string('GRowState') = 'D' THEN

                DELETE 
                  FROM TB_INV015 
                 WHERE WERKS = V_WERKS
                   AND WRK_ORDR_NO = V_WRK_ORDR_NO
                   AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO;		 	  

            END IF;

        END LOOP;
    END IF;

    P_SUCCESS := 'Y';

    COMMIT;

--    EXCEPTION
--    WHEN E_EXCEPTION_USER THEN
--
--        -- 에러 내역 SET
--	    P_SUCCESS           := 'N';
--        E_SQL_ERR_CD        := SQLCODE;
--        E_SQL_ERR_MSG       := SUBSTRB(SQLERRM,1,300);
--
--        ROLLBACK;
--        SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
--
--    WHEN OTHERS THEN
--	    P_SUCCESS           := 'N';
--        E_SQL_ERR_CD        := -20990;
--        E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';
--
--        ROLLBACK;
--        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
END;
/
