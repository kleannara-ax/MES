
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_PDA_QLT02_S01" (
    P_SEND_PARAM    IN CLOB,
    P_SUCCESS       OUT VARCHAR2, 
    P_ERR_MSG       OUT VARCHAR2
)
/*==============================================================================
 * PROGRAM ID    : SP_PDA_QLT02_S01{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 선별일지 결과/수정 등록{호출 프로그램 명 기술}
 * VERSION       : 1.0.2{최종 버전 기술}
 * DESCRIPTION   : 선별일지 결과/수정 등록{프로그램에 대한 상세한 내용 기술}
 *                 
 * AUTHOR NAME   : 강지선{최초 작성자 명 기술}
 * CREATE DATE   : 2024/05/10 {최초 작성일자 기술}
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {하 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>

 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2024/05/10    1.0.0     강지선         Initial Version 
 * 2024/06/05    1.0.1     강지선         JSON param 처리 수정
 * 2024/09/10    1.0.2     강지선         index 추가로 인한 무결성 오류 처리
 *==============================================================================
 *  관련 테이블
 *       - [TB_QLT031]  : (CRUD) 선별일지 Parent Table
 *       - [TB_QLT032]  : (CRUD) 선별일지 Detail Table
 *=============================================================================*/
AS
    -- JSON을 위한 변수선언 영역
    V_JSON         JSON_OBJECT_T;
    V_ARR_LIST     JSON_ARRAY_T;
    V_OBJ          JSON_OBJECT_T;
    V_OBJ_TEMP     JSON_OBJECT_T;
   
    V_INSPR_DT      VARCHAR2(8); 
    V_INSPR_TM      VARCHAR2(8); 
    V_INSPR_NM      VARCHAR2(100); 
    V_INSTD_CFG     VARCHAR2(1); 
    V_MARNR	        VARCHAR2(18);
    V_MACH_CD       VARCHAR2(10); 
    V_PART_DIV      VARCHAR2(5); 
    V_CREATEUSER    VARCHAR2(100); 
    V_UPDATEUSER    VARCHAR2(100); 
    V_RMK1L       	VARCHAR2(500); 
    V_RMK2L       	VARCHAR2(500); 
    V_RMK3L       	VARCHAR2(500); 
    V_CLSF_LARGE    VARCHAR2(100); 
    V_CLSF_SMALL    VARCHAR2(100); 
    V_CLSF_RST_VAL  VARCHAR2(20); 
    V_RMK1S       	VARCHAR2(500); 
    V_RMK2S       	VARCHAR2(500); 
    V_RMK3S       	VARCHAR2(500);

    P_SEQ_PT        NUMBER;  -- 해당 MATNR data 존재 여부(=부모 SEQ)
    
    NEW_SEQ_VAL     NUMBER;
    V_STR_TEMP		CLOB;

BEGIN

    -- P_SEND_PARAM parsing
    V_STR_TEMP := REPLACE(P_SEND_PARAM, '#', '"');
    DBMS_OUTPUT.PUT_LINE('## V_STR_TEMP = ' || V_STR_TEMP);

    V_JSON      := JSON_OBJECT_T.parse(V_STR_TEMP);
    V_ARR_LIST  := V_JSON.get_array('list');

    DBMS_OUTPUT.PUT_LINE('## V_ARR_LIST.get_size = ' || V_ARR_LIST.get_size);

    IF (V_ARR_LIST.get_size > 0) THEN
        FOR i IN 0..V_ARR_LIST.get_size-1 LOOP
            V_OBJ           := TREAT (V_ARR_LIST.get (i) AS json_object_t);
		
            V_INSPR_DT      := V_OBJ.get_string('P_INSPR_DT');
            V_INSPR_TM      := V_OBJ.get_string('P_INSPR_TM');
            V_INSPR_NM      := V_OBJ.get_string('P_INSPR_NM');
            V_INSTD_CFG     := V_OBJ.get_string('P_INSTD_CFG');
            V_MACH_CD       := V_OBJ.get_string('P_MACH_CD');
            V_MARNR	        := V_OBJ.get_string('P_MARNR');
            V_PART_DIV      := V_OBJ.get_string('P_PART_DIV');
            V_CREATEUSER    := V_OBJ.get_string('P_CREATEUSER');
            V_UPDATEUSER    := V_OBJ.get_string('P_UPDATEUSER');
            V_RMK1L       	:= V_OBJ.get_string('P_RMK1L');
            V_RMK2L       	:= V_OBJ.get_string('P_RMK2L');
            V_RMK3L       	:= V_OBJ.get_string('P_RMK3L');
            V_CLSF_LARGE    := V_OBJ.get_string('P_CLSF_LARGE');
            V_CLSF_SMALL    := V_OBJ.get_string('P_CLSF_SMALL');
            V_CLSF_RST_VAL  := V_OBJ.get_string('P_CLSF_RST_VAL');
            V_RMK1S       	:= V_OBJ.get_string('P_RMK1S');
            V_RMK2S       	:= V_OBJ.get_string('P_RMK2S');
            V_RMK3S       	:= V_OBJ.get_string('P_RMK3S');

            DBMS_OUTPUT.PUT_LINE('===================');
            DBMS_OUTPUT.PUT_LINE('## V_MARNR = ' || V_MARNR || ' | V_INSPR_DT = ' || V_INSPR_DT || ' | V_INSPR_TM = ' || V_INSPR_TM || ' | V_MACH_CD : ' || V_MACH_CD || ' | V_PART_DIV = ' || V_PART_DIV || ' ##');
            DBMS_OUTPUT.PUT_LINE('## V_INSPR_NM = ' || V_INSPR_NM || ' | V_INSTD_CFG = ' || V_INSTD_CFG || ' ##');
           
            -- 먼저 TB_QLT031에서 MATNR + INSPR_TM + MACH_CD + PART_DIV 찾아 해당 결과값이 있는지 확인
            SELECT NVL((
                SELECT SEQ
                FROM TB_QLT031
                WHERE MATNR = V_MARNR
                AND INSPR_DT = V_INSPR_DT
                AND INSPR_TM = V_INSPR_TM
                AND MACH_CD = V_MACH_CD
                AND PART_DIV = V_PART_DIV
                AND INSPR_NM = V_INSPR_NM
            ), 0) INTO P_SEQ_PT
            FROM DUAL;
            DBMS_OUTPUT.PUT_LINE('## P_SEQ_PT = ' || P_SEQ_PT);
            DBMS_OUTPUT.PUT_LINE('## NEW_SEQ_VAL = ' || NEW_SEQ_VAL);
            DBMS_OUTPUT.PUT_LINE('## NVL(NEW_SEQ_VAL, 0) = ' || NVL(NEW_SEQ_VAL, 0));
            DBMS_OUTPUT.PUT_LINE('===================');

            IF NVL(NEW_SEQ_VAL, 0) > 0 THEN
                IF i = 0 THEN
                DBMS_OUTPUT.PUT_LINE('===================');
                DBMS_OUTPUT.PUT_LINE('## HERE ##');
                
                    INSERT INTO TB_QLT031 (
                        SEQ, 
                        INSPR_DT, 
                        INSPR_TM, 
                        INSPR_NM,
                        INSTD_CFG,
                        MATNR, 
                        MACH_CD, 
                        PART_DIV, 
                        CREATEUSER, 
                        CREATEDATE
                    ) VALUES (
                        TB_QLT031_PK.NEXTVAL, 
                        V_INSPR_DT, 
                        V_INSPR_TM,
                        V_INSPR_NM,
                        V_INSTD_CFG,
                        V_MARNR,
                        V_MACH_CD,
                        V_PART_DIV,
                        V_CREATEUSER,
                        SYSDATE
                    )
                    RETURNING SEQ INTO NEW_SEQ_VAL;
                    DBMS_OUTPUT.PUT_LINE('## INSERT > NEW_SEQ_VAL = ' || NEW_SEQ_VAL);
                END IF;
                
                INSERT INTO TB_QLT032 (
                    SEQ, 
                    P_SEQ, 
                    CLSF_LARGE, 
                    CLSF_SMALL, 
                    CLSF_RST_VAL, 
                    RMK1, 
                    RMK2, 
                    RMK3
                ) VALUES (
                    TB_QLT032_PK.NEXTVAL, 
                    NEW_SEQ_VAL, 
                    V_CLSF_LARGE, 
                    V_CLSF_SMALL, 
                    V_CLSF_RST_VAL, 
                    V_RMK1S, 
                    V_RMK2S, 
                    V_RMK3S
                );

            ELSE
                DBMS_OUTPUT.PUT_LINE('===================');
                DBMS_OUTPUT.PUT_LINE('## P_SEQ_PT = ' || P_SEQ_PT);
                
                IF P_SEQ_PT > 0 THEN

                    UPDATE TB_QLT031 
                    SET
                        UPDATEUSER = V_UPDATEUSER, 
                        UPDATEDATE = SYSDATE, 
                        RMK1 = V_RMK1L, 
                        RMK2 = V_RMK2L, 
                        RMK3 = V_RMK3L
                    WHERE SEQ = P_SEQ_PT;

                    UPDATE TB_QLT032 
                    SET 
                        CLSF_RST_VAL = V_CLSF_RST_VAL, 
                        RMK1 = V_RMK1S, 
                        RMK2 = V_RMK2S, 
                        RMK3 = V_RMK3S
                    WHERE CLSF_LARGE = V_CLSF_LARGE
                    AND CLSF_SMALL = V_CLSF_SMALL
                    AND P_SEQ = P_SEQ_PT;

                ELSE
                    DBMS_OUTPUT.PUT_LINE('## ELSE P_SEQ_PT = ' || P_SEQ_PT);
                    -- 해당 자재코드가 존재하지 않으면 새로운 데이터 INSERT
                    IF i = 0 THEN
                    DBMS_OUTPUT.PUT_LINE('## TB_QLT031_PK.NEXTVAL = ' || TB_QLT031_PK.NEXTVAL);
                    
                        INSERT INTO TB_QLT031 (
                            SEQ, 
                            INSPR_DT, 
                            INSPR_TM, 
                            INSPR_NM, 
                            INSTD_CFG,
                            MATNR, 
                            MACH_CD, 
                            PART_DIV, 
                            CREATEUSER, 
                            CREATEDATE
                        ) VALUES (
                            TB_QLT031_PK.NEXTVAL, 
                            V_INSPR_DT, 
                            V_INSPR_TM,
                            V_INSPR_NM,
                            V_INSTD_CFG,
                            V_MARNR,
                            V_MACH_CD,
                            V_PART_DIV,
                            V_CREATEUSER,
                            SYSDATE
                        )
                        RETURNING SEQ INTO NEW_SEQ_VAL;
                        DBMS_OUTPUT.PUT_LINE('## INSERT > NEW_SEQ_VAL = ' || NEW_SEQ_VAL);
                    END IF;
                
                    DBMS_OUTPUT.PUT_LINE('## AFTER(' || i || ') INSERT > NEW_SEQ_VAL = ' || NEW_SEQ_VAL);
                    IF NEW_SEQ_VAL > 0 THEN
                        INSERT INTO TB_QLT032 (
                            SEQ, 
                            P_SEQ, 
                            CLSF_LARGE, 
                            CLSF_SMALL, 
                            CLSF_RST_VAL, 
                            RMK1, 
                            RMK2, 
                            RMK3
                        ) VALUES (
                            TB_QLT032_PK.NEXTVAL, 
                            NEW_SEQ_VAL, 
                            V_CLSF_LARGE, 
                            V_CLSF_SMALL, 
                            V_CLSF_RST_VAL, 
                            V_RMK1S, 
                            V_RMK2S, 
                            V_RMK3S
                        );
                    END IF;

                END IF;
            END IF;

        END LOOP;
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
