--------------------------------------------------------
--  DDL for Procedure SP_POP_WRK30_I01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK30_I01" 
(
     P_WERKS             IN VARCHAR2 --플랜트코드
    ,P_JSON_STR         IN CLOB
    ,P_USERID           IN VARCHAR2
    ,RS_MER_IND_BCD     OUT VARCHAR2    
    ,Lang               IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE            OUT VARCHAR2 
    ,RS_MSG             OUT VARCHAR2
    
)
/*==============================================================================
 * PROGRAM ID    : SP_POP_WRK30_I01
 * PROGRAM NAME  : 라벨 병합 처리
 * VERSION       : 1.0.0
 * DESCRIPTION   : 라벨 병합 처리
 *                 
 * AUTHOR NAME   : 김병무
 * CREATE DATE   : 2022/05/04
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/05/04    1.0.0   김병무         Initial Version
 *==============================================================================
 *  관련 테이블
 * - [TB_WRK009] : (C...) LOT 병합
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM         VARCHAR2(100)  := 'SP_POP_WRK30_I01';     -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID   varchar2(20) := P_USERID; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);
    --parameter변수 처리

    V_PROC_CD       varchar2(20);

    -- JSON을 위한 변수선언 영역
    V_JSON           JSON_OBJECT_T;
    V_ARR_LIST       JSON_ARRAY_T;
    V_OBJ            JSON_OBJECT_T;

    V_WERKS	        TB_WRK002.RMK%TYPE;     --플랜트
    V_MACH_CD	    TB_WRK002.RMK%TYPE;     --작업장코드(설비코드)
    V_IND_BCD	    TB_WRK002.RMK%TYPE;     --개별바코드
    V_LOT_NO        TB_WRK002.LOT_NO%TYPE;  --LOT_NO
    V_LOT_NO_B      TB_WRK002.LOT_NO%TYPE;  --이전LOT_NO  
    V_MER_IND_BCD   TB_WRK002.MER_IND_BCD%TYPE;  --병합개별바코드

    V_MATNR         TB_WRK002.MATNR%TYPE;
    V_PRD_END_DTM   varchar(16); 

    --내부 변수 등록
    V_DATE      DATE := SYSDATE;

BEGIN
    BEGIN
    --예외처리 시작(try)
        BEGIN
            V_JSON := JSON_OBJECT_T.parse(P_JSON_STR);

            V_ARR_LIST        := V_JSON.get_array('list');

            FOR i IN 0..V_ARR_LIST.get_size-1 LOOP
                    V_OBJ           := TREAT (V_ARR_LIST.get (i) AS json_object_t);
                    V_OBJ           := TREAT (V_OBJ.get ('map') AS json_object_t);

                    V_IND_BCD       := V_OBJ.get_string('IND_BCD');

                    -- 같은 LOT 인지 체크
                    SELECT LOT_NO, MACH_CD, MATNR, TO_CHAR(PRD_END_DATE, 'YYYYMMDDHH24MISS') ,MER_IND_BCD
                      INTO V_LOT_NO, V_MACH_CD, V_MATNR, V_PRD_END_DTM,V_MER_IND_BCD
                      FROM TB_WRK002   --실적테이블(PS)
                     WHERE WERKS   = P_WERKS
                       AND IND_BCD = V_IND_BCD
                       AND ROWNUM =1 ;

                    IF V_LOT_NO_B IS NOT NULL  AND V_LOT_NO_B <> V_LOT_NO THEN
                            RS_CODE := 'E';
                            RS_MSG := 'LOT 정보를 확인해주세요';
                            ROLLBACK;
                            RETURN;
                    END IF;

                    IF V_MER_IND_BCD IS NOT NULL   THEN
                            RS_CODE := 'E';
                            RS_MSG := '이미 병합된 LOT 정보입니다';
                            ROLLBACK;
                            RETURN;
                    END IF;

                    -- 병합바코드 생성
                    IF i = 0 THEN
                        SP_GET_BARCODE_SEQ('IND', P_WERKS, 'C', V_MATNR, V_PRD_END_DTM,V_MER_IND_BCD);
                        --SP_GET_BARCODE_SEQ('IND', P_WERKS, V_MACH_CD, V_MATNR, V_PRD_END_DTM,V_MER_IND_BCD);
                    END IF;

                    -- UPDATE  TB_WRK002
                    UPDATE TB_WRK002  SET
                      MER_IND_BCD = V_MER_IND_BCD,      
                      MER_YN  = 'Y'
                     WHERE WERKS   = P_WERKS
                       AND IND_BCD = V_IND_BCD;

                    V_LOT_NO_B := V_LOT_NO ;                    

            END LOOP;
                --작업 정상 종료 코드 등록
            RS_MER_IND_BCD := V_MER_IND_BCD;

            RS_CODE := 'S';
        END;

        COMMIT;
    --예외처리(catch)
    EXCEPTION
    WHEN E_EXCEPTION_USER THEN
        -- 에러 내역 SET
        E_SQL_ERR_CD        := SQLCODE;
        E_SQL_ERR_MSG       := SUBSTRB(SQLERRM,1,300);

        ROLLBACK;
        SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);

        RS_CODE := 'E';
        RS_MSG  := SQLERRM;
        RETURN;
    WHEN OTHERS THEN
        E_SQL_ERR_CD        := -20001;
        E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

        ROLLBACK;
        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);

        RS_CODE := 'E';
        RS_MSG  := SQLERRM;
        RETURN;
    --예외처리 종료
    END;
END SP_POP_WRK30_I01;

/
