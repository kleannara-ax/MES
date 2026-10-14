
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_QLT30_S01" (
    P_SEND_PARAM    IN CLOB,
    P_SUCCESS       OUT VARCHAR2, 
    P_ERR_MSG       OUT VARCHAR2
)
/*==============================================================================
 * PROGRAM ID    : SP_QLT30_S01{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 선별일지 > 자재코드 마스터 UPSERT{호출 프로그램 명 기술}
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 선별일지 > 자재코드 마스터 UPSERT{프로그램에 대한 상세한 내용 기술}
 *                 
 * AUTHOR NAME   : 강지선{최초 작성자 명 기술}
 * CREATE DATE   : 2024/07/25 {최초 작성일자 기술}
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {하 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>

 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2024/07/25    1.0.0     강지선         Initial Version 
 *==============================================================================
 *  관련 테이블
 *       - [TB_QLT030]  : (CRUD) 선별일지 자재코드 MASTER
 *=============================================================================*/
AS
    -- JSON을 위한 변수선언 영역
    V_JSON         JSON_OBJECT_T;
    V_ARR_LIST     JSON_ARRAY_T;
    V_OBJ          JSON_OBJECT_T;
    V_OBJ_TEMP     JSON_OBJECT_T;
   
    V_MATNR         VARCHAR2(18);
    V_MATNR_NM      VARCHAR2(150);
    V_MACH_CD       VARCHAR2(10);
    V_PART_DIV      VARCHAR2(5);
    V_BS_WGT        NUMBER(5,1);
    V_CLSF_STCNT    NUMBER(5,1);
    V_CLSF_MCNT     NUMBER(13,3);
    V_CLSF_CTCNT    NUMBER(5,1);
    V_CLSF_ROLL_CNT VARCHAR2(1000);
    V_CREATEUSER    VARCHAR2(100);
    V_UPDATEUSER    VARCHAR2(100);
    V_RMK1          VARCHAR2(500);
    V_RMK2          VARCHAR2(500);
    V_RMK3          VARCHAR2(500);
    V_STR_TEMP		CLOB;

    P_MATNR         VARCHAR2(18);  -- 해당 MATNR data 존재 여부

BEGIN

    -- P_SEND_PARAM parsing
    V_STR_TEMP := REPLACE(P_SEND_PARAM, '#', '"');
    DBMS_OUTPUT.PUT_LINE('## V_STR_TEMP = ' || V_STR_TEMP);

    V_JSON      := JSON_OBJECT_T.parse(V_STR_TEMP);
    
    IF (V_JSON IS NOT NULL) THEN
        V_MATNR := V_JSON.get_string('P_MATNR');
        V_MATNR_NM := V_JSON.get_string('P_MATNR_NM');
        V_MACH_CD := V_JSON.get_string('P_MACH_CD');
        V_PART_DIV := V_JSON.get_string('P_PART_DIV');
        V_BS_WGT := V_JSON.get_string('P_BS_WGT');
        V_CLSF_STCNT := V_JSON.get_string('P_CLSF_STCNT');
        V_CLSF_MCNT := V_JSON.get_string('P_CLSF_MCNT');
        V_CLSF_CTCNT := V_JSON.get_string('P_CLSF_CTCNT');
        V_CLSF_ROLL_CNT := V_JSON.get_string('P_CLSF_ROLL_CNT');
        V_CREATEUSER := V_JSON.get_string('P_CREATEUSER');
        V_UPDATEUSER := V_JSON.get_string('P_UPDATEUSER');
        V_RMK1 := V_JSON.get_string('P_RMK1');
        V_RMK2 := V_JSON.get_string('P_RMK2');
        V_RMK3 := V_JSON.get_string('P_RMK3');
        DBMS_OUTPUT.PUT_LINE('## V_MATNR = ' || V_MATNR);
        -- INSER/UPDATE 구분
        SELECT NVL((SELECT MATNR FROM TB_QLT030 WHERE MATNR = V_MATNR), 'N') INTO P_MATNR FROM DUAL;
        DBMS_OUTPUT.PUT_LINE('## P_MATNR = ' || P_MATNR);
        DBMS_OUTPUT.PUT_LINE('===================');

        -- INSERT
        IF (P_MATNR = 'N') THEN
            INSERT INTO TB_QLT030 
            (
                MATNR, 
                MATNR_NM,
                MACH_CD,
                PART_DIV,
                BS_WGT,
                CLSF_STCNT, 
                CLSF_MCNT, 
                CLSF_CTCNT, 
                CLSF_ROLL_CNT, 
                RMK1, 
                RMK2, 
                RMK3, 
                CREATEUSER
            ) VALUES (
                V_MATNR,
                V_MATNR_NM, 
                V_MACH_CD,
                V_PART_DIV,  
                V_BS_WGT, 
                V_CLSF_STCNT, 
                V_CLSF_MCNT, 
                V_CLSF_CTCNT, 
                V_CLSF_ROLL_CNT, 
                V_RMK1, 
                V_RMK2, 
                V_RMK3, 
                V_CREATEUSER
            );

        ELSE    

            -- UPDATE
            UPDATE TB_QLT030 SET 
                CREATEUSER = V_CREATEUSER,
                UPDATEUSER = V_UPDATEUSER,
                UPDATEDATE =  SYSDATE
            WHERE MATNR = V_MATNR
            AND (V_MATNR_NM IS NOT NULL OR V_BS_WGT IS NOT NULL OR V_BS_WGT IS NOT NULL OR V_CLSF_STCNT IS NOT NULL OR V_CLSF_MCNT IS NOT NULL OR V_CLSF_CTCNT IS NOT NULL OR V_CLSF_ROLL_CNT IS NOT NULL);

            IF V_MATNR_NM IS NOT NULL THEN
                UPDATE TB_QLT030 SET 
                    MATNR_NM = V_MATNR_NM
                WHERE MATNR = V_MATNR;
            END IF;
            
            IF V_MACH_CD IS NOT NULL THEN
                UPDATE TB_QLT030 SET 
                    MACH_CD = V_MACH_CD
                WHERE MATNR = V_MATNR;
            END IF;
           
            IF V_BS_WGT IS NOT NULL THEN
                UPDATE TB_QLT030 SET 
                    BS_WGT = V_BS_WGT
                WHERE MATNR = V_MATNR;
            END IF;

            IF V_CLSF_STCNT IS NOT NULL THEN
                UPDATE TB_QLT030 SET 
                    CLSF_STCNT = V_CLSF_STCNT
                WHERE MATNR = V_MATNR;
            END IF;

            IF V_CLSF_MCNT IS NOT NULL THEN
                UPDATE TB_QLT030 SET 
                    CLSF_MCNT = V_CLSF_MCNT
                WHERE MATNR = V_MATNR;
            END IF;

            IF V_CLSF_CTCNT IS NOT NULL THEN
                UPDATE TB_QLT030 SET 
                    CLSF_CTCNT = V_CLSF_CTCNT
                WHERE MATNR = V_MATNR;
            END IF;

            IF V_CLSF_ROLL_CNT IS NOT NULL THEN
                UPDATE TB_QLT030 SET 
                    CLSF_ROLL_CNT = V_CLSF_ROLL_CNT
                WHERE MATNR = V_MATNR;
            END IF;

            IF V_RMK1 IS NOT NULL THEN
                UPDATE TB_QLT030 SET 
                    RMK1 = V_RMK1
                WHERE MATNR = V_MATNR;
            END IF;

            IF V_RMK2 IS NOT NULL THEN
                UPDATE TB_QLT030 SET 
                    RMK2 = V_RMK2
                WHERE MATNR = V_MATNR;
            END IF;

            IF V_RMK3 IS NOT NULL THEN
                UPDATE TB_QLT030 SET 
                    RMK3 = V_RMK3
                WHERE MATNR = V_MATNR;
            END IF;

        END IF;
    END IF;
    
    -- 변경 사항을 커밋
    P_SUCCESS           := 'Y';

    COMMIT;

EXCEPTION
	
    WHEN OTHERS THEN
        -- 에러 발생시 롤백하고 에러 메시지 표시
        P_SUCCESS       := 'N';
        P_ERR_MSG       := SQLCODE || ': EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20002, 'An error occurred: ' || SQLERRM);
END;
/
