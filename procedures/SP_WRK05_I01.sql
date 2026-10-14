
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_WRK05_I01" 
(
    P_TYPE           IN    varchar2, -- LIST, SUB_LIST, SUB_SAVE
	P_JSON_STR       IN    CLOB,
	P_SUCCESS       OUT    varchar2,
    P_ERR_MSG       OUT    VARCHAR2,
    P_DOC_NO1       OUT    varchar2,        
	P_RS_LIST       OUT    SYS_REFCURSOR
)
AS 
/*==============================================================================
 * PROGRAM ID    : WRK05{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 완제품 입고요청{호출 프로그램 명 기술}
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : WMS로 완제품 입고요청{프로그램에 대한 상세한 내용 기술}
 *                 
 * AUTHOR NAME   : 유상호{최초 작성자 명 기술}
 * CREATE DATE   : 2022/05/13 {최초 작성일자 기술}
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/05/13    1.0.0   유상호         Initial Version 
 *==============================================================================
 *  관련 테이블
 *       - [TB_MAS001] : (.R..) 자재 마스터                                
 *       - [TB_MAS015] : (CRUD) 검사항목별 기준정보 등록 마스트                              
 *       - [TB_MAS016] : (CRUD) 검사항목별 기준값 정보                                
 *=============================================================================*/
    --프로그램 ID
    V_PRG_NM          VARCHAR2(100)  := 'SP_WRK05_I01';     -- PROCEDURE NAME

    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5)           := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);

    -- JSON을 위한 변수선언 영역
    V_JSON           JSON_OBJECT_T;
    V_ARR_LIST       JSON_ARRAY_T;
    V_ARR_HEAD       JSON_OBJECT_T;
    V_OBJ            JSON_OBJECT_T;
    V_OBJ2           JSON_OBJECT_T;

    -- 세션값 처리용 변수선언 영역
    V_SQL            CLOB;
    V_RUN_SQL        varchar2(1);
    V_RANGE_SQL      varchar2(4000);
    V_DEBUG          varchar2(1);

    -- 세션값 처리용 변수선언 영역
    V_PLT_CD         varchar2(2);
    V_SESS_USER_ID   varchar2(20);

    -- 조건절 처리용 변수선언 영역
    V_WERKS             TB_INV001.WERKS%TYPE;        -- 플랜트코드
    V_MACH_CD           TB_INV001.MACH_CD%TYPE;      -- 설비코드
    V_MATNR             TB_INV001.MATNR%TYPE;        -- 자재코드
    V_CHK_PP_YN         TB_WRK001.CHK_PP_YN%TYPE;        -- 생산확인여부
    V_CHK_QC_YN         TB_WRK001.CHK_QC_YN%TYPE;        -- 품질확인여부
    V_DOC_NO_1            VARCHAR2(200);
    V_DOC_SEQNO_1           NUMBER;
    V_DOC_NO_PRE        VARCHAR2(20);
    V_DOC_SEQNO_PRE     TB_WRK015.DOC_SEQNO%TYPE;
    V_IND_BCD           TB_INV001.IND_BCD%TYPE;      -- 업체/개별바코드
    V_PROC_CD           TB_MAS012.PROC_CD%TYPE;      -- 공정코드
    V_WRK_CD            TB_MAS012.WRK_CD%TYPE;        -- 작업장코드
    V_WRK_ORDR_NO       TB_WRK011.WRK_ORDR_NO%TYPE;  -- 작업지시번호
    V_WRK_ORDR_SEQNO    TB_WRK011.WRK_ORDR_SEQNO%TYPE;  -- 작업지시번호 순번
    V_ORDER_NO          TB_WRK011.ORDER_NO%TYPE; 

    V_QTY               TB_WRK001.WGT%TYPE;     
    V_UNIT              TB_WRK001.UNIT%TYPE; 
    V_STOR_LOC_FR       VARCHAR2(20); 
    V_STOR_LOC_TO       VARCHAR2(20); 
    V_PLT_QTY           TB_WRK001.PLT_QTY%TYPE;       
    V_BOX_QTY           TB_WRK001.BOX_QTY%TYPE;     
    V_BAG_QTY           TB_WRK001.BAG_QTY%TYPE;     
    V_EA_QTY            TB_WRK001.EA_QTY%TYPE;     
    V_WGT               TB_WRK001.WGT%TYPE;     
    V_LOT_NO            TB_WRK001.LOT_NO%TYPE;     
    V_MACH_NM           VARCHAR2(50);
    V_ORDER_SEQNO	    VARCHAR2(10);
    V_PRD_DT            TB_WRK001.PRD_DT%TYPE;              --생산일자
    V_RCVGDS_DT         VARCHAR2(10);                       --입고일자
    V_PRFM_DT           TB_WRK001.PRFM_DT%TYPE;             --실적일자
    V_DSTBT_DDLIN       VARCHAR2(10);                       --유통기간
    V_REQ_STA           VARCHAR2(10);                       --요청상태
    V_DATE              DATE := SYSDATE;
    V_MACHINE           VARCHAR2(5);
    V_DOC_NO            VARCHAR2(4000);  --TB_WRK015.DOC_NO%TYPE; 
    V_DOC_SEQNO         TB_WRK015.DOC_SEQNO%TYPE;            
    V_VGBEL             TB_WRK015.VGBEL%TYPE;
    V_EMPLY_NO			TB_WRK015.EMPLY_NO%TYPE;
    V_SAP_DOC_NO        TB_WRK001.SDOC_NO%TYPE;
    V_SAP_WRK_CD        VARCHAR2(10);
    V_WDOC_NO           TB_INV001.WDOC_NO%TYPE;
    V_STCK_STA          TB_INV001.STCK_STA%TYPE;
    PROD_CUR            SYS_REFCURSOR;		-- 커서 정의
BEGIN
    OPEN P_RS_LIST FOR 
    SELECT NULL FROM DUAL WHERE ROWNUM = 0;

    V_JSON := JSON_OBJECT_T.parse(P_JSON_STR);
    V_SESS_USER_ID       :=       V_JSON.get_string('SES_USER_ID');
    V_PLT_CD             :=       V_JSON.get_string('SES_WAREKY');

    /* 조건값 할당 */
    V_RANGE_SQL          :=       V_JSON.get_string('RANGE_SQL');                   -- 작업지시 조회 시 일자
    V_WERKS              :=       V_JSON.get_string('WERKS');                       -- 플랜트코드
    V_MACH_CD            :=       V_JSON.get_string('MACH_CD');                     -- 설비코드
    V_MATNR              :=       V_JSON.get_string('MATNR');                       -- 자재코드
    V_CHK_PP_YN          :=       V_JSON.get_string('CHK_PP_YN');                   -- 생산확인여부(Y/N)
    V_CHK_QC_YN          :=       V_JSON.get_string('CHK_QC_YN');                   -- 품질확인여부(Y/N)

--    V_PRFM_DOC_NO        :=       V_JSON.get_string('DOC_NO');
--    V_PRFM_DOC_SEQNO     :=       V_JSON.get_string('DOC_SEQNO');

    IF P_TYPE = 'SAVE' THEN  /* 입고요청*/
        V_ARR_LIST        := V_JSON.get_array('list');

        --완제품 입고요청 문서번호
        --V_DOC_NO_1 := FN_GET_MDOCNO('M','IF402');
        V_DOC_SEQNO_1 := 0;
        --입고일자
        V_RCVGDS_DT := TO_CHAR(V_DATE, 'YYYYMMDD');
        V_ORDER_SEQNO := '000000';

        FOR i IN 0..V_ARR_LIST.get_size-1 LOOP
            V_OBJ           := TREAT (V_ARR_LIST.get (i) AS json_object_t);
            V_OBJ           := TREAT (V_OBJ.get ('map') AS json_object_t);

            V_WERKS         := V_OBJ.get_string('WERKS');
            V_MACH_CD       := V_OBJ.get_string('MACH_CD');
            V_MACH_NM       := V_OBJ.get_string('MACH_NM');
            V_IND_BCD       := V_OBJ.get_string('IND_BCD');
            V_MATNR         := V_OBJ.get_string('MATNR');
            V_CHK_PP_YN     := V_OBJ.get_string('CHK_PP_YN');
            V_CHK_QC_YN     := V_OBJ.get_string('CHK_QC_YN');

            SELECT  CASE WHEN W001.UNIT = 'PLT' THEN W001.PLT_QTY
                        WHEN W001.UNIT = 'BOX' THEN W001.BOX_QTY
                        WHEN W001.UNIT = 'BAG' THEN W001.BAG_QTY
                        WHEN W001.UNIT = 'EA' THEN W001.EA_QTY 
                        WHEN W001.UNIT = 'KG' THEN W001.WGT END QTY, 
                    W001.UNIT, CASE WHEN SUBSTR(V_MACH_CD, 1, 3) = 'TAA' THEN '2000' ELSE '3100' END, '3000',
                    W001.PLT_QTY, W001.BOX_QTY, W001.BAG_QTY, W001.EA_QTY, W001.WGT,		
                    W001.IND_BCD, W001.LOT_NO, W001.ORDER_NO, W001.ORDER_SEQNO,		
                    W001.WRK_ORDR_NO, W001.WRK_ORDR_SEQNO, W001.REGID,
                    W001.PRD_DT, W001.PRFM_DT, W001.DSTBT_DDLIN, W001.SDOC_NO,
                    M012.SAP_WRK_CD, M012.MACHINE, 'R', I001.WDOC_NO, I001.STCK_STA
                    INTO
                    V_QTY, 
                    V_UNIT, V_STOR_LOC_FR, V_STOR_LOC_TO,
                    V_PLT_QTY, V_BOX_QTY, V_BAG_QTY, V_EA_QTY, V_WGT,		
                    V_IND_BCD, V_LOT_NO, V_ORDER_NO, V_ORDER_SEQNO,		
                    V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_EMPLY_NO,
                    V_PRD_DT, V_PRFM_DT, V_DSTBT_DDLIN, V_SAP_DOC_NO,
                    V_SAP_WRK_CD, V_MACHINE, V_REQ_STA, V_WDOC_NO, V_STCK_STA
              FROM TB_WRK001 W001,
                   TB_INV001 I001,
                   TB_MAS012 M012
             WHERE W001.WERKS = I001.WERKS(+)
               AND W001.MACH_CD = I001.MACH_CD(+)
               AND W001.IND_BCD = I001.IND_BCD(+)
               AND W001.MACH_CD = M012.MACH_CD(+)
               AND W001.WERKS = V_WERKS
               AND W001.MACH_CD = V_MACH_CD
               AND W001.IND_BCD = V_IND_BCD;

            IF NVL(V_SAP_DOC_NO,' ') <> ' '  AND NVL(V_SAP_DOC_NO,' ') <> 'E' AND V_STCK_STA = '00' THEN
            -- IF NVL(V_SAP_DOC_NO,' ') <> 'E' AND V_STCK_STA = '00' THEN
                V_DOC_NO_1 := FN_GET_MDOCNO('M','IF402');

                IF NVL(V_DOC_NO, ' ') = ' ' THEN
                    V_DOC_NO := V_DOC_NO_1;
                ELSE
                    V_DOC_NO := V_DOC_NO || ',' || V_DOC_NO_1;
                END IF;

                V_DOC_SEQNO_1 :=  1;
                INSERT INTO TB_WRK015( DOC_NO, DOC_SEQNO, DLFL,			
                                    WERKS, MATNR, QTY, UNIT, STOR_LOC_FR, STOR_LOC_TO,
                                    PLT_QTY, BOX_QTY, BAG_QTY, EA_QTY, WGT,		
                                    IND_BCD, LOT_NO, MACHINE, ORDER_NO, ORDER_SEQNO, EMPLY_NO,
                                    WRK_ORDR_NO, WRK_ORDR_SEQNO, PRD_DT, RCVGDS_DT, PRFM_DT, DSTBT_DDLIN,
                                    REQ_STA, REGDATE, REGID) 
                           VALUES(V_DOC_NO_1, V_DOC_SEQNO_1, 'C',
                                    V_WERKS, V_MATNR, V_QTY, V_UNIT, V_STOR_LOC_FR, V_STOR_LOC_TO,
                                    V_PLT_QTY, V_BOX_QTY, V_BAG_QTY, V_EA_QTY, V_WGT,
                                    V_IND_BCD, V_LOT_NO, V_MACHINE, V_ORDER_NO, V_ORDER_SEQNO, V_EMPLY_NO,
                                    V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_PRD_DT, V_RCVGDS_DT, V_PRFM_DT, V_DSTBT_DDLIN,
                                    'R', V_DATE, V_SESS_USER_ID);
                --I/F테이블에 등록
                INSERT INTO TB_IFSWM005( DOC_NO, DOC_SEQNO, DLFL,
                                        WERKS, MATNR, QTY, UNIT, STOR_LOC_FROM, STOR_LOC_TO,
                                        IND_BCD, LOT_NO, MACHINE, ORDER_NO, ORDER_SEQNO,
                                        REQ_DT, PRDC_DT, RCVGDS_DT, DSTBT_DDLIN, IF_GET_DATE)
                           VALUES( V_DOC_NO_1, V_DOC_SEQNO_1, 'C',
                                    V_WERKS, V_MATNR, V_QTY, V_UNIT, V_STOR_LOC_FR, V_STOR_LOC_TO,
                                    V_IND_BCD, V_LOT_NO, V_MACHINE, V_ORDER_NO, V_ORDER_SEQNO,
--                                    V_RCVGDS_DT,
                                    CASE WHEN V_SESS_USER_ID = 'hnw.shyou' THEN V_PRD_DT ELSE V_RCVGDS_DT END, 
                                    V_PRD_DT, 
--                                    V_RCVGDS_DT,
                                    CASE WHEN V_SESS_USER_ID = 'hnw.shyou' THEN V_PRD_DT ELSE V_RCVGDS_DT END, 
                                    V_DSTBT_DDLIN, V_DATE);

                IF SUBSTR(V_MACH_CD, 1, 3) = 'TAA' OR SUBSTR(V_MACH_CD, 1, 3) = 'TRA' OR SUBSTR(V_MACH_CD, 1, 3) = 'TPG' THEN
                    UPDATE TB_WRK001
                       SET CHK_PP_YN = 'Y',
                           CHK_PP_DATE = V_DATE,
                           CHK_PP_ID = V_SESS_USER_ID
                     WHERE WERKS = V_WERKS
                       AND MACH_CD = V_MACH_CD
                       AND IND_BCD = V_IND_BCD;
                ELSE
                    UPDATE TB_WRK001
                       SET CHK_QC_YN = 'Y',
                           CHK_QC_DATE = V_DATE,
                           CHK_QC_ID = V_SESS_USER_ID
                     WHERE WERKS = V_WERKS
                       AND MACH_CD = V_MACH_CD
                       AND IND_BCD = V_IND_BCD;
                END IF;

                UPDATE TB_INV001
                   SET STCK_STA = '80'
                 WHERE WERKS = V_WERKS
                   AND MACH_CD = V_MACH_CD
                   AND IND_BCD = V_IND_BCD;

            END IF;
        END LOOP;
    ELSIF P_TYPE = 'DELETE' THEN  /* 입고요청취소*/
        V_ARR_LIST        := V_JSON.get_array('list');
        V_DOC_NO_PRE := '';

        FOR i IN 0..V_ARR_LIST.get_size-1 LOOP
            V_OBJ           := TREAT (V_ARR_LIST.get (i) AS json_object_t);
            V_OBJ           := TREAT (V_OBJ.get ('map') AS json_object_t);

            V_WERKS         := V_OBJ.get_string('WERKS');
            V_MACH_CD       := V_OBJ.get_string('MACH_CD');
            V_MACH_NM       := V_OBJ.get_string('MACH_NM');
            V_IND_BCD       := V_OBJ.get_string('IND_BCD');
            V_MATNR         := V_OBJ.get_string('MATNR');
            V_CHK_PP_YN     := V_OBJ.get_string('CHK_PP_YN');
            V_CHK_QC_YN     := V_OBJ.get_string('CHK_QC_YN');

            SELECT DOC_NO, DOC_SEQNO, VGBEL
                   INTO
                   V_DOC_NO_PRE, V_DOC_SEQNO_PRE, V_VGBEL
              FROM (SELECT *
                      FROM TB_WRK015
                     WHERE WERKS = V_WERKS
                       AND IND_BCD = V_IND_BCD
                       AND DLFL = 'C'
                     ORDER BY REGDATE DESC)
              WHERE ROWNUM = 1;       

            IF NVL(V_VGBEL, ' ') <> ' ' AND NVL(V_VGBEL, ' ') <> 'E' THEN
                P_SUCCESS := 'N';
                P_ERR_MSG := V_MATNR || ' 은 이미 완제품창고로 입고되어 입고취소를 할 수 없습니다.';
                ROLLBACK;
                RETURN;
            END IF;

            SELECT STCK_STA
                INTO 
                   V_STCK_STA
              FROM TB_INV001
             WHERE WERKS = V_WERKS
               AND MACH_CD = V_MACH_CD
               AND IND_BCD = V_IND_BCD;

            IF  V_STCK_STA = '80' THEN      --완제품 입고요청한 것만 취소할수 있음
                IF NVL(V_DOC_NO, ' ') = ' ' THEN 
                    V_DOC_NO :=  V_DOC_NO_PRE;
                ELSE
                    V_DOC_NO :=  V_DOC_NO || ',' || V_DOC_NO_PRE;
                END IF;

                INSERT INTO TB_IFSWM005( DOC_NO, DOC_SEQNO, DLFL,
                                         WERKS, MATNR, QTY, UNIT, STOR_LOC_FROM, STOR_LOC_TO, IND_BCD,
                                         LOT_NO, MACHINE, ORDER_NO, ORDER_SEQNO, PRDC_DT, RCVGDS_DT, DSTBT_DDLIN,
                                         IF_GET_DATE)
                SELECT DOC_NO, DOC_SEQNO, 'D',
                       WERKS, MATNR, QTY, UNIT, STOR_LOC_FROM, STOR_LOC_TO, IND_BCD,
                       LOT_NO, MACHINE, ORDER_NO, ORDER_SEQNO, PRDC_DT, RCVGDS_DT, DSTBT_DDLIN,
                       V_DATE
                  FROM TB_IFSWM005
                 WHERE DOC_NO = V_DOC_NO_PRE
                   AND DOC_SEQNO = V_DOC_SEQNO_PRE
                   AND DLFL = 'C'
                   --AND ROWNUM = 1
                ORDER BY IF_GET_DATE DESC;
				/* 입고요청 ROLLBACK을 위한 주석
                IF SUBSTR(V_MACH_CD, 1, 3) = 'TAA' THEN
                    UPDATE TB_WRK001
                       SET STA = '00',
                           CHK_PP_YN = 'N',
                           CHK_PP_DATE = '',
                           CHK_PP_ID = ''
                     WHERE WERKS = V_WERKS
                       AND MACH_CD = V_MACH_CD
                       AND IND_BCD = V_IND_BCD;
                ELSE
                    UPDATE TB_WRK001
                       SET STA = '00',
                           CHK_QC_YN = 'N',
                           CHK_QC_DATE = '',
                           CHK_QC_ID = ''
                     WHERE WERKS = V_WERKS
                       AND MACH_CD = V_MACH_CD
                       AND IND_BCD = V_IND_BCD;
                END IF;

--                BEGIN
                UPDATE TB_INV001
                       SET STCK_STA = '00'
                     WHERE WERKS = V_WERKS
                       AND MACH_CD = V_MACH_CD
                       AND IND_BCD = V_IND_BCD;
                
                UPDATE TB_WRK015
                   SET DLFL = 'D'
                 WHERE WERKS = V_WERKS
                   AND IND_BCD = V_IND_BCD
                   AND DLFL = 'C'; 
*/
               
--                IF SQL%ROWCOUNT = 0 THEN
--                    P_SUCCESS := 'N';
--                    P_ERR_MSG := 'UPDATE ERROR';
--                    ROLLBACK;
--                    RETURN;
--                ELSE
--                    P_SUCCESS := 'N';
--                    P_ERR_MSG := 'UPDATE OK';
--                END IF;
--                EXCEPTION
--                    WHEN  OTHERS THEN
--                     RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
--                         P_SUCCESS := 'N';
--                            P_ERR_MSG := 'UPDATE ERROR';
--                            ROLLBACK;
--                            RETURN;
--                END;
            END IF;    
        END LOOP;    

    END IF;

    IF NVL(V_DOC_NO, ' ') <> ' ' THEN
        P_DOC_NO1 := V_DOC_NO;
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
--        SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
--
--        ROLLBACK;
--
--    WHEN OTHERS THEN
--	    P_SUCCESS           := 'N';
--        E_SQL_ERR_CD        := SQLCODE;
--        E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';
--
--        ROLLBACK;
--        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
END;
/
