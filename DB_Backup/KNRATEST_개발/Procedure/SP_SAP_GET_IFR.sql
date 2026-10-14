--------------------------------------------------------
--  DDL for Procedure SP_SAP_GET_IFR
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_SAP_GET_IFR" (    i_IF_MES_ID        IN    VARCHAR2
                                                       ,i_IF_MES_KEY       IN    VARCHAR2
                                                       ,i_SAP_INV_LIST     IN    CLOB
                                                       ,o_msg_CODE         OUT   VARCHAR2
                                                       ,o_msg_MSG          OUT   VARCHAR2
) AS

/*==============================================================================
 * PROGRAM ID    : 인터페이스
 * PROGRAM NAME  : SAP 재고정보 수신
 * VERSION       : 1.0.0
 * DESCRIPTION   : 재고대사용 SAP 재고정보를 수신한다.
 *                 
 * AUTHOR NAME   : 김성하
 * CREATE DATE   : 2022/11/03
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}	<생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}		<생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}			<생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}	<생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/11/03    1.0.0   김성하         Initial Version 
 *==============================================================================
 *  관련 테이블
 *        인터페이스설계서(총괄표) 참조
 *=============================================================================*/

    --프로그램 ID : --슬리터예외 실적취소
    V_PRG_NM        VARCHAR2(100)  := 'SP_SAP_GET_IFR';     -- PROCEDURE NAME
    -- 세션값 처리용 변수선언 영역
    V_PLT_CD         varchar2(2);
    V_SESS_USER_ID   varchar2(20);

    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);

    V_JSON              JSON_OBJECT_T;
    V_ARR_LIST          JSON_ARRAY_T;
    V_OBJ               JSON_OBJECT_T;

    V_WKDT              TB_IFR050.WKDT%TYPE;
    V_WERKS             TB_IFR050.WERKS%TYPE;
    V_LGORT             TB_IFR050.LGORT%TYPE;
    V_MATNR             TB_IFR050.MATNR%TYPE;
    V_CHARG             TB_IFR050.CHARG%TYPE;
    V_SOBKZ             TB_IFR050.SOBKZ%TYPE;
    V_KDAUF             TB_IFR050.KDAUF%TYPE;
    V_KDPOS             TB_IFR050.KDPOS%TYPE;
    V_KUNNR             TB_IFR050.KUNNR%TYPE;
    V_LIFNR             TB_IFR050.LIFNR%TYPE;
    V_STQTY             TB_IFR050.STQTY%TYPE;
    V_SPEME             TB_IFR050.SPEME%TYPE;
    V_MEINS             TB_IFR050.MEINS%TYPE;


    V_CNT               NUMBER    DEFAULT 0;
 
BEGIN


/* ------- TB_IFR050 : SAP 재고 Begin -------------------------------- */
    IF  i_IF_MES_ID  = 'MES_IF_148'  THEN

        DBMS_OUTPUT.PUT_LINE('MES_IF_148==>START');

        --JSON 데이터 수신
        V_JSON     := JSON_OBJECT_T.PARSE(i_SAP_INV_LIST); -- 전체 데이터
        V_ARR_LIST := V_JSON.GET_ARRAY('list');

        V_SESS_USER_ID       :=       V_JSON.get_string('SES_USER_ID');
        V_PLT_CD             :=       V_JSON.get_string('SES_WAREKY');

        FOR i IN 0..V_ARR_LIST.GET_SIZE - 1 LOOP

            V_OBJ := TREAT(V_ARR_LIST.GET(I) AS JSON_OBJECT_T);
            V_OBJ := TREAT(V_OBJ.GET('map') AS JSON_OBJECT_T);

            V_WKDT        := V_OBJ.GET_STRING('WKDT');
            V_WERKS       := V_OBJ.GET_STRING('WERKS');
            V_LGORT       := V_OBJ.GET_STRING('LGORT');
            V_MATNR       := V_OBJ.GET_STRING('MATNR');
            V_CHARG       := V_OBJ.GET_STRING('CHARG');
            V_SOBKZ       := V_OBJ.GET_STRING('SOBKZ');
            V_KDAUF       := V_OBJ.GET_STRING('KDAUF');
            V_KDPOS       := V_OBJ.GET_STRING('KDPOS');
            V_KUNNR       := V_OBJ.GET_STRING('KUNNR');
            V_LIFNR       := V_OBJ.GET_STRING('LIFNR'); 
            V_STQTY       := V_OBJ.GET_STRING('STQTY');
            V_SPEME       := V_OBJ.GET_STRING('SPEME');
            V_MEINS       := V_OBJ.GET_STRING('MEINS');

            --데이트량증가로 인한 속도저하 개선
            SELECT COUNT(WERKS) INTO V_CNT 
            FROM TB_IFR050 
            WHERE WKDT  = V_WKDT 
              AND WERKS = V_WERKS
              AND LGORT = V_LGORT
              AND MATNR = V_MATNR
              AND CHARG = V_CHARG; 
        
            IF V_CNT > 0 THEN
                UPDATE TB_IFR050
                SET  SOBKZ = V_SOBKZ
                   , KDAUF = V_KDAUF
                   , KDPOS = V_KDPOS
                   , KUNNR = V_KUNNR
                   , LIFNR = V_LIFNR
                   , STQTY = V_STQTY
                   , SPEME = V_SPEME
                   , MEINS = V_MEINS
                   , IF_STATUS      = 'N'
                   , IF_GET_DATE    = SYSDATE
                   , IF_SET_DATE    = SYSDATE
                   , IF_ERR_MESS    = NULL
                   , IF_MES_ID      = i_IF_MES_ID
                   , IF_RCV_MES_KEY = i_IF_MES_KEY
                WHERE   WKDT  = V_WKDT
                    AND WERKS = V_WERKS
                    AND LGORT = V_LGORT
                    AND MATNR = V_MATNR
                    AND CHARG = V_CHARG;
                    
             ELSE
                 INSERT INTO TB_IFR050 (
                        WKDT,
                        WERKS,
                        LGORT,
                        MATNR,
                        CHARG,
                        SOBKZ,
                        KDAUF,
                        KDPOS,
                        KUNNR,
                        LIFNR,
                        STQTY,
                        SPEME,
                        MEINS,
                        IF_STATUS,
                        IF_GET_DATE,
                        IF_SET_DATE,
                        IF_ERR_MESS,
                        IF_MES_ID,
                        IF_RCV_MES_KEY
                    ) VALUES (
                        V_WKDT,
                        V_WERKS,
                        V_LGORT,
                        V_MATNR,
                        V_CHARG,
                        V_SOBKZ,
                        V_KDAUF,
                        V_KDPOS,
                        V_KUNNR,
                        V_LIFNR,
                        V_STQTY,
                        V_SPEME,
                        V_MEINS,
                        'N',
                        SYSDATE,
                        SYSDATE,
                        NULL,
                        i_IF_MES_ID,
                        i_IF_MES_KEY
                    );
            END IF;
        
        
            o_msg_MSG  :=  'TB_IFR050, SAP 재고 수신되었습니다.1'; -- || ',' || SQLERRM ;
            o_msg_code := '0' ;
        
            IF o_msg_CODE <> '0' THEN
               --DBMS_OUTPUT.PUT_LINE('MES_IF_148 개별처리중 ERROR==>'|| ifr050.aufnr || ',' || ifr050.posnr || ',' || o_msg_MSG) ;
               rollback;
               return;
            END IF ;
       
        END LOOP;
       
        Commit ;

        DBMS_OUTPUT.PUT_LINE('MES_IF_148==>END');        

    END IF ;
/* ------- TB_IFR050 : SAP 재고 End ---------------------------------- */

--    P_SUCCESS := 'Y';

    EXCEPTION
    WHEN E_EXCEPTION_USER THEN

        o_msg_MSG         :=  'TB_IFR050, SAP 재고 수신 중 오류가 발생하였습니다.' || ',' || SQLERRM ;
	    o_msg_code        := '-1';
        E_SQL_ERR_CD      := SQLCODE;
        E_SQL_ERR_MSG     := SUBSTRB(SQLERRM,1,300);

        ROLLBACK;
        SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);

    WHEN OTHERS THEN
	    o_msg_code        := '-1';
        E_SQL_ERR_CD      := SQLCODE;
        E_SQL_ERR_MSG     := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

        ROLLBACK;
        RAISE;
    END;

/
