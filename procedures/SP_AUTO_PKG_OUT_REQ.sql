
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_AUTO_PKG_OUT_REQ" (
    P_WRAP_CD IN VARCHAR2,  --랩핑호기
    P_IND_BCD IN VARCHAR2,
    RS_CODE OUT VARCHAR2,
    RS_MSG OUT VARCHAR2
)
AS
    /*==============================================================================
     * PROGRAM ID    : SP_AUTO_PKG_OUT_REQ
     * PROGRAM NAME  : PS 원지자동포장 후 생산출고 요청
     * VERSION       : 1.0.0
     * DESCRIPTION   : WMS로 출고요청
     *
     * AUTHOR NAME   : 김지언
     * CREATE DATE   : 2025/11/13
     * SYSTEM NAME   : 원지포장자동화 MES
     * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
     * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
     * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
     * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
     * REVERSION HISTORY
     * ------------ ------- ------------- ------------------------------------------
     *    Date        Ver       Name          Description
     * ------------ ------- ------------- ------------------------------------------
     * 2025/11/13    1.0.0   김지언         Initial Version
     *==============================================================================
     *  관련 테이블
     *       - [TB_INV001] : (.R..) 재고 정보
     *       - [TB_WRK002] : (.R..) PS 실적정보
     *       - [TB_SCH018] : (.R..) 포장작업지시
     *       - [TB_WRK015] : (.R..) 완제품 출고요청
     *       - [TB_IFSWM005] : (.R..) 완제품 출고요청 인터페이스
     *       - [TB_MAS009] : (.R..) 거래처 정보
       *=============================================================================*/
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER EXCEPTION;

    -- 세션값 처리용 변수선언 영역
    V_SESS_USER_ID    varchar2(20);

    -- 조건절 처리용 변수선언 영역
    V_WERKS           TB_INV001.WERKS%TYPE   := 'P100';     --플랜트코드
    V_IND_BCD         TB_INV001.IND_BCD%TYPE := P_IND_BCD;  --개별바코드
    V_MACH_CD         TB_INV001.MACH_CD%TYPE;               --설비코드

    V_DOC_NO_WMS      TB_WRK015.DOC_NO%TYPE;                --wms 입고요청 V_DOC_NO_WMS
    V_DOC_SEQNO_WMS   TB_WRK015.DOC_SEQNO%TYPE;             --wms 입고요청 V_DOC_SEQNO_WMS

    V_DOC_NO_WMS_C    TB_WRK015.DOC_NO%TYPE;                --wms 입고요청 V_DOC_NO_WMS_CANC
    V_DOC_SEQNO_WMS_C TB_WRK015.DOC_SEQNO%TYPE;             --wms 입고요청 V_DOC_SEQNO_WMS_CANC

    V_VGBEL           TB_WRK015.VGBEL%TYPE;                 --WMS문서번호
    V_USER_NM_EN      VARCHAR2(20);
    V_USER_NM         USRMA.NMLAST%TYPE;                    --사원명
    V_MATNR           TB_WRK002.MATNR%TYPE;
    V_PRFM_QTY        TB_WRK002.PRFM_QTY%TYPE;
    V_UNIT            TB_WRK002.UNIT%TYPE;
    V_STOR_LOC_FR     VARCHAR2(10);
    V_STOR_LOC_TO     VARCHAR2(10);
    V_WGT             TB_WRK002.WGT%TYPE;
    V_LOT_NO          TB_WRK002.LOT_NO%TYPE;
    V_MACHINE         TB_WRK002.MACHINE%TYPE;
    V_ORDER_NO        TB_WRK002.ORDER_NO%TYPE;
    V_WRK_ORDR_NO     TB_WRK002.WRK_ORDR_NO%TYPE;
    V_WRK_ORDR_SEQNO  TB_WRK002.WRK_ORDR_SEQNO%TYPE;
    V_PACKTYPE        TB_WRK002.PACKTYPE%TYPE;
    V_VBELN           TB_WRK002.VBELN%TYPE;
    V_POSNR           TB_WRK002.POSNR%TYPE;
    V_KUNNR           TB_WRK002.KUNNR%TYPE;
    V_REGID           TB_WRK002.REGID%TYPE;
    V_GRD_YN          TB_WRK002.GRD_YN%TYPE;
    V_PRFM_DT         VARCHAR2(10);
    V_PRD_DT          VARCHAR2(10);
    V_RCVGDS_DT       VARCHAR2(10);
    V_DSTBT_DDLIN     TB_WRK002.DSTBT_DDLIN%TYPE;
    V_VLEN            TB_SCH018.VLEN%TYPE;
    V_WLEN            TB_SCH018.WLEN%TYPE;
    V_CON_TYPE        TB_SCH018.CON_TYPE%TYPE;
    V_PCODE           TB_SCH018.PCODE%TYPE;
    V_BS_WGT          TB_SCH018.BS_WGT%TYPE;
    V_DATE            DATE                   := SYSDATE;
    V_POSNR_N         VARCHAR2(10);
    V_STOCK_NO        VARCHAR2(20);
    V_NTN_CD          VARCHAR2(20);
    V_SDOC_NO         TB_INV001.SDOC_NO%TYPE;
    V_SDOC_SEQNO      TB_INV001.SDOC_SEQNO%TYPE;
    V_WDOC_NO         TB_INV001.WDOC_NO%TYPE;
    V_WDOC_SEQNO      TB_INV001.WDOC_SEQNO%TYPE;
    V_OAUART_DIV      TB_SCH018.OAUART_DIV%TYPE;
    V_CORE            TB_WRK002.CORE%TYPE;
    V_CNL_YN          TB_WRK002.CNL_YN%TYPE;
    V_STCK_STA        TB_INV001.STCK_STA%TYPE;
    V_PACK_TYPE       TB_INV001.PACK_TYPE%TYPE;
    V_DLFL            VARCHAR2(1);
    V_STOR_LOC_CD     TB_INV001.STOR_LOC_CD%TYPE;
    V_STRGR           VARCHAR2(10);
    V_REQ_DT          VARCHAR2(10);
    V_PARAM_LIST      VARCHAR2(4000);
    V_ERR_CODE        VARCHAR2(3);
    V_ERR_MSG         VARCHAR2(4000);
    V_IF_MES_KEY      VARCHAR2(100);
    V_PROC_CD         VARCHAR2(30);
    V_REQ_DATE        VARCHAR2(8);

    V_STAGE           VARCHAR2(20) := 'PRE'; /* 롤백시점 */
BEGIN
    --------------------------------------------------------------------
    -- 0. 초기값
    --------------------------------------------------------------------
    RS_CODE := 'E';
    RS_MSG := NULL;

    /*==================================================================
      1. 기본 정보 조회
    ==================================================================*/
    BEGIN
        SELECT W002.MACH_CD,
               W002.MATNR,
               I001.STCK_QTY,
               W002.UNIT,
               W002.WGT,
               W002.MACH_CD,
               W002.LOT_NO,
               W002.MACHINE,
               W002.ORDER_NO,
               W002.WRK_ORDR_NO,
               W002.WRK_ORDR_SEQNO,
               W002.CORE,
               W002.PACKTYPE,
               W002.VBELN,
               W002.POSNR,
               W002.KUNNR,
               W002.REGID,
               W002.VLEN,
               W002.WLEN,
               W002.GRD_YN,
               U001.NMLAST,
               W002.PRFM_DT,
               W002.PRD_DT,
               W002.DSTBT_DDLIN,
               W002.SDOC_NO,
               W002.SDOC_SEQNO,
               I001.STCK_STA,
               I001.WDOC_NO,
               I001.WDOC_SEQNO,
               I001.PACK_TYPE,
               I001.STOR_LOC_CD,
               NVL(W002.CNL_YN, 'N') AS CNL_YN
        INTO V_MACH_CD, V_MATNR, V_PRFM_QTY, V_UNIT, V_WGT, V_MACH_CD,
            V_LOT_NO, V_MACHINE, V_ORDER_NO, V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO,
            V_CORE, V_PACKTYPE, V_VBELN, V_POSNR, V_KUNNR, V_REGID,
            V_VLEN, V_WLEN, V_GRD_YN,
            V_USER_NM, V_PRFM_DT, V_PRD_DT, V_DSTBT_DDLIN, V_SDOC_NO, V_SDOC_SEQNO,
            V_STCK_STA, V_WDOC_NO, V_WDOC_SEQNO, V_PACK_TYPE, V_STOR_LOC_CD, V_CNL_YN
        FROM TB_WRK002 W002,
             TB_INV001 I001,
             USRMA U001
        WHERE W002.WERKS = I001.WERKS(+)
          AND W002.IND_BCD = I001.IND_BCD(+)
          AND W002.REGID = U001.USERID(+)
          AND W002.WERKS = V_WERKS
          AND W002.IND_BCD = V_IND_BCD;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RS_CODE := 'E';
            RS_MSG := '생산실적/재고 데이터가 존재하지 않습니다.';
            insert into PROC_LOG(SQL_STR, SQL_PARAM1) values (RS_CODE || ' - ' || RS_MSG, 'SP_AUTO_PKG_OUT_REQ');
            RETURN;
        WHEN OTHERS THEN
            RS_CODE := 'E';
            RS_MSG := SQLERRM;
            insert into PROC_LOG(SQL_STR, SQL_PARAM1) values (RS_CODE || ' - ' || SUBSTRB(RS_MSG,1,300), 'SP_AUTO_PKG_OUT_REQ');
            RETURN;
    END;

    IF V_CNL_YN = 'Y' THEN
        RS_CODE := 'N';
        RS_MSG := P_IND_BCD || ' / ' || V_MATNR || ' 는 실적취소된 바코드입니다.';
        insert into PROC_LOG(SQL_STR, SQL_PARAM1) values (RS_CODE || ' - ' || RS_MSG, 'SP_AUTO_PKG_OUT_REQ');
        RETURN;
    END IF;

    /*==================================================================
      2. 사전 검증 (M/C, 재고상태 등)
    ==================================================================*/
    IF SUBSTR(V_MACH_CD, 1, 3) = 'PCA' OR SUBSTR(V_MACH_CD, 1, 3) = 'PCB' THEN
        IF SUBSTR(V_WRK_ORDR_NO, 0, 4) != 'WOEX' THEN
            RS_CODE := 'N';
            RS_MSG := V_MATNR || ' 는 반제품 생산출고 할 수 없습니다.';
            insert into PROC_LOG(SQL_STR, SQL_PARAM1) values (RS_CODE || ' - ' || SUBSTRB(RS_MSG,1,300), 'SP_AUTO_PKG_OUT_REQ');
            RETURN;
        END IF;
    END IF;

    IF V_STCK_STA = '70' THEN
        RS_CODE := 'N';
        RS_MSG := P_IND_BCD || ' / ' || V_MATNR || ' 는 이미 생산출고 되었습니다.';
        insert into PROC_LOG(SQL_STR, SQL_PARAM1) values (RS_CODE || ' - ' || SUBSTRB(RS_MSG,1,300), 'SP_AUTO_PKG_OUT_REQ');
        RETURN;
    ELSIF V_STCK_STA = '80' THEN
        RS_CODE := 'N';
        RS_MSG := P_IND_BCD || ' / ' || V_MATNR || ' 는 이미 생산출고요청 되었습니다.';
        insert into PROC_LOG(SQL_STR, SQL_PARAM1) values (RS_CODE || ' - ' || SUBSTRB(RS_MSG,1,300), 'SP_AUTO_PKG_OUT_REQ');
        RETURN;
    END IF;

    /*==================================================================
      3. 문서번호, PCODE/BS_WGT, 국가코드, MTO/MTS 구분 등
         (원본 SELECT/IF 로직을 그대로 유지)
    ==================================================================*/

    --완제품 입고요청 I/F
    V_DOC_NO_WMS := FN_GET_MDOCNO('M', 'IF402');
    V_DOC_SEQNO_WMS := 1;

    BEGIN
        SELECT PCODE, BS_WGT, SAUART_DIV AS OAUART_DIV, CON_TYPE
        INTO V_PCODE, V_BS_WGT, V_OAUART_DIV, V_CON_TYPE
        FROM (SELECT PCODE, BS_WGT, SAUART_DIV, NULL AS CON_TYPE
              FROM TB_SCH016 --밀롤 작업지시
              WHERE WRK_ORDR_NO = V_WRK_ORDR_NO
                AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
              UNION ALL
              SELECT PCODE, BS_WGT, ORDER_DIV AS SAUART_DIV, NULL AS CON_TYPE
              FROM TB_SCH019 --예외 작업지시(슬리터?)
              WHERE WRK_ORDR_NO = V_WRK_ORDR_NO
                AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            V_PCODE := '';
    END;

    IF NVL(V_PCODE, ' ') = ' ' THEN
        SELECT M001.PCODE, M001.BS_WGT, '' AS SAUART_DIV, I001.CON_TYPE
            INTO V_PCODE, V_BS_WGT, V_OAUART_DIV, V_CON_TYPE
        FROM TB_INV001 I001
                 LEFT JOIN TB_MAS001 M001 ON I001.WERKS = M001.WERKS AND I001.MATNR = M001.MATNR
        WHERE 1 = 1
          AND I001.IND_BCD = V_IND_BCD;
    END IF;

    BEGIN
        --국가코드
        SELECT LAND1
            INTO V_NTN_CD
        FROM TB_MAS009 M009
        WHERE M009.CUST_CD = V_KUNNR
          AND CUST_DIV = 'C';
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            V_NTN_CD := '';
    END;

    --자재코드 5번째 자리 2 = 수출, 그외 = 내수
    V_USER_NM_EN := SUBSTR(V_USER_NM_EN, 1, INSTR(V_USER_NM_EN, '@') - 1);

    IF SUBSTR(V_MATNR, 5, 1) = '2' THEN
        V_USER_NM := V_USER_NM_EN;
    END IF;

    V_POSNR_N := SUBSTR('000000' || TO_CHAR(V_POSNR), -6);
    V_STOCK_NO := SUBSTR('0000' || V_VBELN, -10) || V_POSNR_N;
    V_RCVGDS_DT := V_PRFM_DT;

    IF V_STOR_LOC_CD <> '3100' THEN
        V_STOR_LOC_FR := '2000'; --원지제품
        V_STOR_LOC_TO := '3000';
    END IF;

    --완제품 출고 요청(이력)
    --MTO/MTS 구분
    BEGIN
        SELECT STRGR
            INTO V_STRGR
        FROM TB_MAS001
        WHERE WERKS = V_WERKS
          AND MATNR = V_MATNR;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            V_STRGR := '00';
    END;

    IF V_STRGR = '20' OR V_STRGR = '50' THEN --MTO
        V_VBELN := SUBSTR('0000' || V_VBELN, -10);
        V_POSNR := SUBSTR('000000' || V_POSNR, -6);
    ELSE --MTS
        V_VBELN := '';
        V_POSNR := '';
        V_POSNR_N := '';
        V_STOCK_NO := '';
        V_KUNNR := '';
    END IF;

    IF NVL(V_GRD_YN, ' ') = 'Y' THEN
        V_VBELN := '';
        V_POSNR := '';
        V_POSNR_N := '';
        V_STOCK_NO := '';
        V_KUNNR := '';
    END IF;

    /*==================================================================
    4. TB_WRK015 INSERT (완제품 출고요청 이력)
    ==================================================================*/
    BEGIN
        INSERT INTO TB_WRK015(DOC_NO, DOC_SEQNO, DLFL,
                              WERKS, MATNR, QTY, UNIT, STOR_LOC_FR, STOR_LOC_TO, WGT,
                              IND_BCD, LOT_NO, MACHINE, ORDER_NO, WRK_ORDR_NO, WRK_ORDR_SEQNO,
                              PCODE, BS_WGT, WLEN, VLEN, CON_TYPE, PACKTYPE, VBELN, POSNR, SAUART, KUNNR,
                              CORE, EMPLY_NO, EMPLY_NM, NTN_CD, PRD_DT, RCVGDS_DT, PRFM_DT, DSTBT_DDLIN,
                              STCK_NO, REQ_STA, REGDATE, REGID)
        VALUES (V_DOC_NO_WMS, V_DOC_SEQNO_WMS, 'C',
                V_WERKS, V_MATNR, V_PRFM_QTY, V_UNIT, DECODE(NVL(V_PACKTYPE, ' '), ' ', V_STOR_LOC_FR, '3100'),
                DECODE(NVL(V_PACKTYPE, ' '), ' ', V_STOR_LOC_TO, '3000'), V_WGT,
                V_IND_BCD, V_LOT_NO, V_MACHINE, V_ORDER_NO, V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO,
                V_PCODE, V_BS_WGT, V_WLEN, V_VLEN, V_CON_TYPE, V_PACKTYPE, V_VBELN, V_POSNR, '', V_KUNNR,
                V_CORE, V_REGID, V_USER_NM, V_NTN_CD, V_PRD_DT, V_RCVGDS_DT, V_PRFM_DT, V_DSTBT_DDLIN,
                V_STOCK_NO, 'R', V_DATE, V_SESS_USER_ID);
    EXCEPTION
        WHEN OTHERS THEN
            SZP_MES_PLSQL_LOG('INSERT ERR', '(ERR)TB_WRK015 INSERT');
            V_ERR_CODE := 'E1';
            V_ERR_MSG := 'TB_WRK015 INSERT 오류: ' || SUBSTR(SQLERRM, 1, 500);
            insert into PROC_LOG(SQL_STR, SQL_PARAM1) values (V_ERR_CODE || ' - ' || SUBSTRB(V_ERR_MSG,1,300), 'SP_AUTO_PKG_OUT_REQ');
            RAISE E_EXCEPTION_USER;
    END;

    /*==================================================================
      5. TB_IFSWM005 INSERT (WMS 출고요청 I/F 데이터)
    ==================================================================*/
    V_REQ_DT := TO_CHAR(V_DATE, 'YYYYMMDD');

    BEGIN
        INSERT INTO TB_IFSWM005(DOC_NO, DOC_SEQNO, DLFL,
                                WERKS, MATNR, QTY, UNIT, STOR_LOC_FROM, STOR_LOC_TO,
                                IND_BCD, LOT_NO, MACHINE, ORDER_NO, ORDER_SEQNO,
                                PCODE, WEIGHT, WLEN, VLEN, CON_TYPE, PACK_TYPE, OVBELN, OPOSNR, SAUART, KUNNR,
                                CORE, EMPLY_NO, EMPLY_NM, NTN_CD, PRDC_DT, RCVGDS_DT, DSTBT_DDLIN, STCK_NO,
                                IF_STATUS, IF_GET_DATE, REQ_DT)
        VALUES (V_DOC_NO_WMS, V_DOC_SEQNO_WMS, 'C',
                V_WERKS, V_MATNR, V_PRFM_QTY, V_UNIT, DECODE(NVL(V_PACKTYPE, ' '), ' ', V_STOR_LOC_FR, '3100'),
                DECODE(NVL(V_PACKTYPE, ' '), ' ', V_STOR_LOC_TO, '3000'),
                V_IND_BCD, V_LOT_NO, V_MACHINE, V_ORDER_NO, '000000',
                V_PCODE, V_BS_WGT, V_WLEN, V_VLEN, V_CON_TYPE, V_PACKTYPE, V_VBELN, V_POSNR_N, V_OAUART_DIV,
                V_KUNNR,
                V_CORE, V_REGID, V_USER_NM, V_NTN_CD, V_PRFM_DT, V_PRFM_DT, V_DSTBT_DDLIN, V_STOCK_NO,
                'N', V_DATE, V_REQ_DT);
    EXCEPTION
        WHEN OTHERS THEN
            SZP_MES_PLSQL_LOG('INSERT ERR', '(ERR)TB_IFSWM005 INSERT');
            V_ERR_CODE := 'E1';
            V_ERR_MSG := 'TB_IFSWM005 INSERT 오류: ' || SUBSTR(SQLERRM, 1, 500);
            insert into PROC_LOG(SQL_STR, SQL_PARAM1) values (V_ERR_CODE || ' - ' || SUBSTRB(V_ERR_MSG,1,300), 'SP_AUTO_PKG_OUT_REQ');
            RAISE E_EXCEPTION_USER;
    END;

    /*==================================================================
    6. DBLINK 호출 (WMS 출고요청)
    ==================================================================*/
    V_PROC_CD := 'POP_WRK20';
    V_REQ_DATE := TO_CHAR(V_DATE, 'YYYYMMDD');
    V_PARAM_LIST := '{"CON_TYPE":"' || V_CON_TYPE || '","CORE":"","SAUART":"","STOR_LOC_TO":"' || V_STOR_LOC_TO ||
                    '","EMPLY_NM":"' || V_USER_NM || '","OVBELN":"' || V_VBELN || '","WERKS": "' || V_WERKS ||
                    '","EMPLY_NO": "' || V_REGID || '","IND_BCD":"' || V_IND_BCD || '","DOC_NO":"' || V_DOC_NO_WMS ||
                    '","ORDER_NO":"' || V_ORDER_NO || '","PACK_TYPE":"' || V_PACKTYPE || '","OPOSNR":"' || V_POSNR_N ||
                    '","WLEN":"","QTY":"' || V_PRFM_QTY || '","MACHINE":"' || V_MACHINE || '","WEIGHT":"' || V_BS_WGT ||
                    '","IF_GET_DATE":"' || V_DATE || '","STOR_LOC_FROM":"' || V_STOR_LOC_FR || '","MATNR":"' ||
                    V_MATNR || '","IF_SET_DATE":"","KUNNR":"' || V_KUNNR || '","RCVGDS_DT":"' || V_REQ_DATE ||
                    '","DOC_SEQNO":"' || V_DOC_SEQNO_WMS || '","UNIT":"' || V_UNIT ||
                    '","SEND_YN":"N","NTN_CD":"KR","ORDER_SEQNO":"1","IF_MES_KEY":"","DLFL":"C","REQ_DT":"' ||
                    V_REQ_DATE || '","PRDC_DT":"' || V_PRFM_DT ||
                    '","IF_STATUS":"N","VLEN":"","STCK_NO":"","IF_ERR_MESS":"","PCODE":"","LOT_NO":"' || V_LOT_NO ||
                    '","DSTBT_DDLIN":"' || V_DSTBT_DDLIN || '"}';

    V_STAGE := 'WMS';
    BEGIN
        DBLINK_WMSIF205@KNRAWMSLINK(V_PARAM_LIST, V_ERR_CODE, V_ERR_MSG);
    EXCEPTION
        WHEN OTHERS THEN
            SZP_MES_PLSQL_LOG('ERR', '(ERR)DBLINK_WMSIF205');
            IF SQLCODE IN ( -2063, -12170, -12154, -12541, -12545, -12514, -3113, -3135 ) THEN
                V_ERR_CODE := 'E_NETWORK';
                V_ERR_MSG  := '네트워크 오류(Oracle↔WMS): ' || SUBSTR(SQLERRM, 1, 500);
            ELSE
                V_ERR_CODE := 'E2';
                V_ERR_MSG  := 'DBLINK_WMSIF205 호출 실패: ' || SUBSTR(SQLERRM, 1, 500);
            END IF;
            RAISE E_EXCEPTION_USER;
    END;

    /*==================================================================
      7. WMS 응답코드에 따른 처리
    ==================================================================*/
    IF V_ERR_CODE <> 'S' THEN
        V_ERR_CODE := 'E2';
        V_ERR_MSG := 'DBLINK_WMSIF205 응답 실패 : ' || V_ERR_MSG;
        insert into PROC_LOG(SQL_STR, SQL_PARAM1) values (V_ERR_CODE || ' - ' || SUBSTRB(V_ERR_MSG,1,300), 'SP_AUTO_PKG_OUT_REQ');
        RAISE E_EXCEPTION_USER;
    ELSE
        V_STAGE := 'POST';

        --출고요청시 상태 변경
        SELECT 'M' || LTRIM(RTRIM(TO_CHAR(SEQ_GET_IFR_KEY.NEXTVAL, '00000000000000000000000000000')))
            INTO V_IF_MES_KEY
        FROM DUAL;

        BEGIN
            UPDATE TB_INV001
            SET STCK_STA    = '80',
                STOR_LOC_CD = V_STOR_LOC_FR,
                UPDDATE     = SYSDATE,
                UPDID       = V_REGID
            WHERE 1 = 1
              AND WERKS = V_WERKS
              AND MATNR = V_MATNR
              AND IND_BCD = V_IND_BCD;

            -- 출고요청 테이블 상태 변경
            UPDATE TB_IFSWM005
            SET IF_STATUS   = V_ERR_CODE
              , IF_ERR_MESS = V_ERR_MSG
              , IF_SET_DATE = SYSDATE
              , IF_MES_KEY  = V_IF_MES_KEY
            WHERE IND_BCD = V_IND_BCD
              AND IF_STATUS = 'N'
              AND DOC_NO = V_DOC_NO_WMS;

            -- 공정재고 테이블 업데이트
            UPDATE TB_INV001
            SET CHK_PP_YN   = 'Y'
              , CHK_PP_DATE = V_DATE
              , CHK_PP_ID   = V_REGID
            WHERE WERKS = V_WERKS
              AND MACH_CD = V_MACH_CD
              AND IND_BCD = V_IND_BCD;
        EXCEPTION
        WHEN OTHERS THEN
            -- [핵심] WMS 호출은 성공했지만, MES 업데이트가 실패함
            V_ERR_CODE := 'E'; -- 내부일반오류
            V_ERR_MSG := 'WMS 성공 후 MES UPDATE 실패: ' || SUBSTR(SQLERRM, 1, 500);
            V_STAGE := 'WMS_SUCCESS_FAIL_MES'; -- 새로운 롤백 시점 정의
            insert into PROC_LOG(SQL_STR, SQL_PARAM1) values (V_ERR_CODE || ' - ' || SUBSTRB(V_ERR_MSG,1,300), 'SP_AUTO_PKG_OUT_REQ');
            RAISE E_EXCEPTION_USER;
        END;

        /* 포장실적등록 */
        INSERT INTO TB_AUTO_PKG_PRFM (PRFM_SEQ, PRFM_DT, WRAP_CD, IND_BCD, PRFM_QTY, REGDATE)
        VALUES (
            SEQ_TB_AUTO_PKG_PRFM.NEXTVAL
            , FN_RECDATE(SYSDATE)    -- 실적일자(오전 7시 기준)
            , P_WRAP_CD                        -- 랩핑 호기
            , V_IND_BCD                         -- 개별 바코드
            , V_PRFM_QTY                       -- 실적수량
            ,SYSDATE                            -- 등록 일시
        );

        RS_CODE := V_ERR_CODE;
        RS_MSG := V_ERR_MSG;

        insert into PROC_LOG(SQL_STR, SQL_PARAM1) values (RS_CODE || ' - ' || SUBSTRB(RS_MSG,1,300), 'SP_AUTO_PKG_OUT_REQ');
    END IF;

    --------------------------------------------------------------------
    -- 논리적으로 여기까지 오지 않지만, 방어용
    --------------------------------------------------------------------
    RS_CODE := NVL(RS_CODE, 'E');
    IF RS_CODE <> 'S' THEN
        RAISE E_EXCEPTION_USER;
    END IF;

EXCEPTION
    /*==============================================================
    8. 사용자 정의 예외 (업무상 롤백 필요)
    ===============================================================*/
    WHEN E_EXCEPTION_USER THEN
        DECLARE
            V_OLD_MSG VARCHAR2(4000);
            V_OLD_CODE VARCHAR2(20);
        BEGIN
            V_OLD_MSG  := NVL(V_ERR_MSG, RS_MSG);
            V_OLD_CODE := NVL(V_ERR_CODE, RS_CODE);
            IF V_STAGE = 'PRE' THEN
                -- 롤백 처리 (모든 INSERT/UPDATE 되돌림)
                ROLLBACK;
            ELSE
                BEGIN
                    select I001.STCK_STA
                        INTO V_STCK_STA
                    FROM TB_INV001 I001
                    WHERE 1 = 1
                      AND I001.WERKS = V_WERKS
                      AND I001.IND_BCD = V_IND_BCD;

                    IF V_STCK_STA = '70' THEN
                        RS_CODE := 'N';
                        RS_MSG := V_OLD_CODE || ' - ' || V_OLD_MSG || ' => ' || V_MATNR || ' / ' || V_IND_BCD || ' 는 이미 생산출고 완료되어 생산출고 취소를 할수 없습니다.';
                        insert into PROC_LOG(SQL_STR, SQL_PARAM1) values (RS_CODE || ' - ' || SUBSTRB(RS_MSG,1,300), 'SP_AUTO_PKG_OUT_REQ');
                        RETURN;
                    END IF;

                    --WMS 입고취소
                    BEGIN
                        SELECT DOC_NO, DOC_SEQNO, DLFL, VGBEL
                            INTO V_DOC_NO_WMS_C, V_DOC_SEQNO_WMS_C, V_DLFL, V_VGBEL
                        FROM TB_WRK015
                        WHERE 1 = 1
                          AND WERKS = V_WERKS
                          AND IND_BCD = V_IND_BCD
                          AND DLFL = 'C'
                        ORDER BY REGDATE DESC
                            FETCH FIRST 1 row ONLY; -- 서비쿼리없이 최신 데이터 1개만 가져옴
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            V_DOC_NO_WMS_C := '';
                    END;


                    IF NVL(V_DLFL, ' ') = 'C' THEN
                        BEGIN
                            INSERT INTO TB_IFSWM005(DOC_NO, DOC_SEQNO, DLFL,
                                                WERKS, MATNR, QTY, UNIT, STOR_LOC_FROM, STOR_LOC_TO,
                                                IND_BCD, LOT_NO, MACHINE, ORDER_NO, ORDER_SEQNO,
                                                PCODE, WEIGHT, WLEN, VLEN, CON_TYPE, PACK_TYPE, OVBELN, OPOSNR, SAUART,
                                                KUNNR,
                                                CORE, EMPLY_NO, EMPLY_NM, NTN_CD, PRDC_DT, RCVGDS_DT, DSTBT_DDLIN,
                                                STCK_NO,
                                                IF_STATUS, IF_GET_DATE, REQ_DT)
                            SELECT DOC_NO,
                                   DOC_SEQNO,
                                   'D',
                                   WERKS,
                                   MATNR,
                                   QTY,
                                   UNIT,
                                   STOR_LOC_FROM,
                                   STOR_LOC_TO,
                                   IND_BCD,
                                   LOT_NO,
                                   MACHINE,
                                   ORDER_NO,
                                   ORDER_SEQNO,
                                   PCODE,
                                   WEIGHT,
                                   WLEN,
                                   VLEN,
                                   CON_TYPE,
                                   PACK_TYPE,
                                   OVBELN,
                                   OPOSNR,
                                   SAUART,
                                   KUNNR,
                                   CORE,
                                   EMPLY_NO,
                                   EMPLY_NM,
                                   NTN_CD,
                                   PRDC_DT,
                                   RCVGDS_DT,
                                   DSTBT_DDLIN,
                                   STCK_NO,
                                   'N',
                                   V_DATE,
                                   REQ_DT
                            FROM TB_IFSWM005
                            WHERE DOC_NO = V_DOC_NO_WMS_C
                              AND DOC_SEQNO = V_DOC_SEQNO_WMS_C
                              AND DLFL = 'C';
                        EXCEPTION
                        WHEN OTHERS THEN
                            SZP_MES_PLSQL_LOG('ROLLBACK INSERT ERR', '(ERR_ROLLBACK)TB_IFSWM005 INSERT');
                            V_ERR_CODE := 'E_R_CANC';
                            V_ERR_MSG := V_OLD_CODE || ' - ' || V_OLD_MSG || ' => ROLLBACK TB_IFSWM005 INSERT 오류: ' || SUBSTR(SQLERRM, 1, 500);
                            insert into PROC_LOG(SQL_STR, SQL_PARAM1) values (V_ERR_CODE || ' - ' || SUBSTRB(V_ERR_MSG,1,300), 'SP_AUTO_PKG_OUT_REQ');
                            RAISE E_EXCEPTION_USER;
                        END;

                        BEGIN
                            /* 출고요청정보 취소 */
                            UPDATE TB_WRK015
                            SET DLFL    = 'D',
                                UPDDATE = V_DATE,
                                UPDID   = V_SESS_USER_ID
                            WHERE 1 = 1
                              AND DOC_NO = V_DOC_NO_WMS_C
                              AND DOC_SEQNO = V_DOC_SEQNO_WMS_C;

                        EXCEPTION
                        WHEN OTHERS THEN
                            SZP_MES_PLSQL_LOG('ROLLBACK UPDATE ERR', '(ERR_ROLLBACK)TB_WRK015 UPDATE');
                            V_ERR_CODE := 'E_R_CANC';
                            V_ERR_MSG := V_OLD_CODE || ' - ' || V_OLD_MSG || ' => ROLLBACK TB_WRK015 UPDATE 오류: ' || SUBSTR(SQLERRM, 1, 500);
                            insert into PROC_LOG(SQL_STR, SQL_PARAM1) values (V_ERR_CODE || ' - ' || SUBSTRB(V_ERR_MSG,1,300), 'SP_AUTO_PKG_OUT_REQ');
                            RAISE E_EXCEPTION_USER;
                        END;
                    END IF;

                    -- DB Link
                    V_PROC_CD := 'POP_WRK20';
                    V_REQ_DATE := TO_CHAR(V_DATE, 'YYYYMMDD');
                    V_PARAM_LIST := '{"CON_TYPE":""' ||
                                    ',"CORE":""' ||
                                    ',"SAUART":""' ||
                                    ',"STOR_LOC_TO":"' || V_STOR_LOC_TO ||'"' ||
                                    ',"EMPLY_NM":"' || V_USER_NM || '"' ||
                                    ',"OVBELN":"' || V_VBELN || '"' ||
                                    ',"WERKS": "' || V_WERKS || '"' ||
                                    ',"EMPLY_NO": "' || V_REGID || '"' ||
                                    ',"IND_BCD":"' || V_IND_BCD || '"' ||
                                    ',"DOC_NO":"' || V_DOC_NO_WMS || '"' ||
                                    ',"ORDER_NO":"' || V_ORDER_NO || '"' ||
                                    ',"PACK_TYPE":"' || V_PACKTYPE || '"' ||
                                    ',"OPOSNR":"' || V_POSNR_N || '"' ||
                                    ',"WLEN":""' ||
                                    ',"QTY":"' || V_PRFM_QTY || '"' ||
                                    ',"MACHINE":"' || V_MACHINE || '"' ||
                                    ',"WEIGHT":""' ||
                                    ',"IF_GET_DATE":"' || V_DATE || '"' ||
                                    ',"STOR_LOC_FROM":"' || V_STOR_LOC_FR || '"' ||
                                    ',"MATNR":"' || V_MATNR || '"' ||
                                    ',"IF_SET_DATE":""' ||
                                    ',"KUNNR":""' ||
                                    ',"RCVGDS_DT":"' || V_REQ_DATE || '"' ||
                                    ',"DOC_SEQNO":"' || V_DOC_SEQNO_WMS || '"' ||
                                    ',"UNIT":"' || V_UNIT || '"' ||
                                    ',"SEND_YN":"N"' ||
                                    ',"NTN_CD":"KR"' ||
                                    ',"ORDER_SEQNO":"1"' ||
                                    ',"IF_MES_KEY":""' ||
                                    ',"DLFL":"D"' ||
                                    ',"REQ_DT":"' || V_REQ_DATE || '"' ||
                                    ',"PRDC_DT":"' || V_PRFM_DT || '"' ||
                                    ',"IF_STATUS":"N"' ||
                                    ',"VLEN":""' ||
                                    ',"STCK_NO":""' ||
                                    ',"IF_ERR_MESS":""' ||
                                    ',"PCODE":""' ||
                                    ',"LOT_NO":"' || V_LOT_NO || '"' ||
                                    ',"DSTBT_DDLIN":"' || V_DSTBT_DDLIN || '"}';

                    DBLINK_WMSIF205@KNRAWMSLINK(V_PARAM_LIST, V_ERR_CODE, V_ERR_MSG);

                    IF V_ERR_CODE <> 'S' THEN
                        V_ERR_CODE := 'E_R_CANC';
                        V_ERR_MSG := V_OLD_CODE || ' - ' || V_OLD_MSG || ' => ' || V_ERR_MSG;
                        insert into PROC_LOG(SQL_STR, SQL_PARAM1) values (V_ERR_CODE || ' - ' || SUBSTRB(V_ERR_MSG,1,300), 'SP_AUTO_PKG_OUT_REQ');
                        RAISE E_EXCEPTION_USER;
                    ELSE
                        --출고요청시 상태 변경
                        SELECT 'M' || LTRIM(RTRIM(TO_CHAR(SEQ_GET_IFR_KEY.NEXTVAL, '00000000000000000000000000000')))
                        INTO V_IF_MES_KEY
                        FROM DUAL;

                        UPDATE TB_INV001
                        SET STCK_STA    = '00',
                            STOR_LOC_CD = V_STOR_LOC_FR,
                            UPDDATE     = SYSDATE,
                            UPDID       = V_REGID
                        WHERE 1 = 1
                          AND WERKS = V_WERKS
                          AND MATNR = V_MATNR
                          AND IND_BCD = V_IND_BCD;

                        -- 출고요청 테이블 상태 변경
                        UPDATE TB_IFSWM005
                        SET IF_STATUS   = V_ERR_CODE
                          , IF_ERR_MESS = V_ERR_MSG
                          , IF_SET_DATE = SYSDATE
                          , IF_MES_KEY  = V_IF_MES_KEY
                        WHERE IND_BCD = V_IND_BCD
                          AND IF_STATUS = 'N'
                          AND DOC_NO = V_DOC_NO_WMS;

                        -- 공정 테이블 업데이트
                        UPDATE TB_INV001
                        SET CHK_PP_YN   = 'Y'
                          , CHK_PP_DATE = V_DATE
                          , CHK_PP_ID   = V_REGID
                        WHERE WERKS = V_WERKS
                          AND MACH_CD = V_MACH_CD
                          AND IND_BCD = V_IND_BCD;

                        RS_CODE := 'S';
                        RS_MSG := V_OLD_CODE || ' - ' || V_OLD_MSG || ' => 롤백성공';

                        insert into PROC_LOG(SQL_STR, SQL_PARAM1) values (RS_CODE || ' - ' || SUBSTRB(RS_MSG,1,300), 'SP_AUTO_PKG_OUT_REQ');
                    END IF;
                END;
            END IF;

            -- 이미 위 단계에서 V_ERR_CODE, V_ERR_MSG 셋팅됨
            RS_CODE := NVL(RS_CODE, 'E');
            RS_MSG := NVL(RS_MSG, '오류가 발생하였습니다.');

            insert into PROC_LOG(SQL_STR, SQL_PARAM1) values (RS_CODE || ' - ' || SUBSTRB(RS_MSG,1,300), 'SP_AUTO_PKG_OUT_REQ');

            RETURN;
        END;
    /*==============================================================
        9. 일반 예외
    ===============================================================*/
    WHEN NO_DATA_FOUND THEN
        ROLLBACK;
        RS_CODE := 'E';
        RS_MSG := '데이터가 존재하지 않습니다.';

        insert into PROC_LOG(SQL_STR, SQL_PARAM1) values (RS_CODE || ' - ' || SUBSTRB(RS_MSG,1,300), 'SP_AUTO_PKG_OUT_REQ');
        RETURN;
    WHEN TOO_MANY_ROWS THEN
        ROLLBACK;
        RS_CODE := 'E';
        RS_MSG := '조회 결과가 두 건 이상입니다.';

        insert into PROC_LOG(SQL_STR, SQL_PARAM1) values (RS_CODE || ' - ' || SUBSTRB(RS_MSG,1,300), 'SP_AUTO_PKG_OUT_REQ');
        RETURN;
    WHEN OTHERS THEN
        ROLLBACK;
        RS_CODE := 'E';
        RS_MSG := SQLERRM;

        insert into PROC_LOG(SQL_STR, SQL_PARAM1) values (RS_CODE || ' - ' || SUBSTRB(RS_MSG,1,300), 'SP_AUTO_PKG_OUT_REQ');
        RETURN;
END;
/
