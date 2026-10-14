
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_PDA_WRK06_IF" SP_PDA_WRK06_IF
(
    P_TYPE           IN    varchar2, -- LIST, SUB_LIST, SUB_SAVE
	P_JSON_STR       IN    CLOB,
	P_SUCCESS       OUT    varchar2,
    P_ERR_MSG       OUT     VARCHAR2,
    P_DOC_NO1       OUT     VARCHAR2,       --재고이전 문서번호
    P_DOC_NO2       OUT     VARCHAR2,       --완제품입고요청 문서번호
	P_RS_LIST       OUT    SYS_REFCURSOR
)
AS 
/*==============================================================================
 * PROGRAM ID    : SP_PDA_WRK06_IF{호출 프로그램 ID 기술}
 * PROGRAM NAME  : PS PDA 생산출고 요청{호출 프로그램 명 기술}
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : WMS로 출고요청{프로그램에 대한 상세한 내용 기술}
 *                 
 * AUTHOR NAME   : 유상호 {최초 작성자 명 기술}
 * CREATE DATE   : 2022/05/22 {최초 작성일자 기술}
 * SYSTEM NAME   : PDA
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/05/22    1.0.0   유상호         Initial Version 
 *==============================================================================
 *  관련 테이블
 *       - [TB_INV001] : (.R..) 재고 정보
 *       - [TB_WRK002] : (.R..) PS 실적정보
 *       - [TB_SCH018] : (.R..) 포장작업지시
 *       - [TB_WRK015] : (.R..) 완제품 출고요청
 *       - [TB_IFSWM005] : (.R..) 완제품 출고요청 인터페이스
 *       - [TB_MAS009] : (.R..) 거래처 정보
   *=============================================================================*/
    --프로그램 ID
    V_PRG_NM          VARCHAR2(100)  := 'SP_PDA_WRK06_IF';     -- PROCEDURE NAME

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
    V_WERKS             TB_INV001.WERKS%TYPE;        --플랜트코드
    V_IND_BCD           TB_INV001.IND_BCD%TYPE;     --개별바코드
    V_MACH_CD           TB_INV001.MACH_CD%TYPE;     --개별바코드

    V_DOC_NO            TB_WRK015.DOC_NO%TYPE;          --MES 문서번호
    V_DOC_SEQNO         TB_WRK015.DOC_SEQNO%TYPE;       --MES 문서번호
    V_DOC_NO_1            TB_WRK015.DOC_NO%TYPE;          --MES 문서번호
    V_DOC_SEQNO_1         TB_WRK015.DOC_SEQNO%TYPE;       --MES 문서번호
    V_DOC_NO_2            TB_WRK015.DOC_NO%TYPE;          --MES 문서번호
    V_DOC_SEQNO_2         TB_WRK015.DOC_SEQNO%TYPE;       --MES 문서번호
    V_VGBEL             TB_WRK015.VGBEL%TYPE;          --WMS문서번호
    V_VGPOS             TB_WRK015.VGPOS%TYPE;          --WMS 문서번호
    --V_USER_NM           VARCHAR2(20); 
    V_USER_NM_EN        VARCHAR2(20);
    V_USER_NM           USRMA.NMLAST%TYPE;              --사원명V_MATNR, V_PRFM_QTY, V_UINT, V_STOR_LOC_FR, V_STOR_LOC_TO, V_WGT,
    V_MATNR             TB_WRK002.MATNR%TYPE; 
    V_PRFM_QTY          TB_WRK002.PRFM_QTY%TYPE; 
    V_UNIT              TB_WRK002.UNIT%TYPE; 
    V_STOR_LOC_FR       VARCHAR2(10);
    V_STOR_LOC_TO       VARCHAR2(10);
    V_WGT               TB_WRK002.WGT%TYPE; 
    V_LOT_NO            TB_WRK002.LOT_NO%TYPE; 
    V_MACHINE           TB_WRK002.MACHINE%TYPE; 
    V_ORDER_NO          TB_WRK002.ORDER_NO%TYPE; 
    V_WRK_ORDR_NO       TB_WRK002.WRK_ORDR_NO%TYPE; 
    V_WRK_ORDR_SEQNO    TB_WRK002.WRK_ORDR_SEQNO%TYPE; 
    V_PACKTYPE          TB_WRK002.PACKTYPE%TYPE; 
    V_VBELN             TB_WRK002.VBELN%TYPE; 
    V_POSNR             TB_WRK002.POSNR%TYPE; 
    V_KUNNR             TB_WRK002.KUNNR%TYPE; 
    V_REGID             TB_WRK002.REGID%TYPE; 
    V_GRD_YN            TB_WRK002.GRD_YN%TYPE;
    V_PRFM_DT           VARCHAR2(10);
    V_PRD_DT            VARCHAR2(10);
    V_RCVGDS_DT         VARCHAR2(10);
    V_DSTBT_DDLIN       TB_WRK002.DSTBT_DDLIN%TYPE; 
    V_VLEN              TB_SCH018.VLEN%TYPE;
    V_WLEN              TB_SCH018.WLEN%TYPE; 
    V_CON_TYPE          TB_SCH018.CON_TYPE%TYPE;
    V_PCODE             TB_SCH018.PCODE%TYPE;
    V_BS_WGT            TB_SCH018.BS_WGT%TYPE;
    --V_NTN_CD            TB_MAS009.LAND1%TYPE;
    V_DATE              DATE := SYSDATE;
    V_POSNR_N           VARCHAR2(10);
    V_STOCK_NO          VARCHAR2(20);
    V_NTN_CD            VARCHAR2(20);

    V_SDOC_NO           TB_INV001.SDOC_NO%TYPE;
    V_SDOC_SEQNO        TB_INV001.SDOC_SEQNO%TYPE;
    V_WDOC_NO           TB_INV001.WDOC_NO%TYPE;
    V_WDOC_SEQNO        TB_INV001.WDOC_SEQNO%TYPE;
    V_OAUART_DIV        TB_SCH018.OAUART_DIV%TYPE;     
    V_CORE              TB_WRK002.CORE%TYPE;
    V_STCK_STA          TB_INV001.STCK_STA%TYPE;
    V_PACK_TYPE         TB_INV001.PACK_TYPE%TYPE;
    V_DLFL              VARCHAR2(1);
    V_MATNR_SPEC        VARCHAR2(10);
    V_SAP_WRK_CD        TB_MAS012.SAP_WRK_CD%TYPE;
    V_DOC_NO_PRE        TB_WRK021.DOC_NO%TYPE;
    V_DOC_SEQNO_PRE     TB_WRK021.DOC_SEQNO%TYPE;
    V_SDOC_NO_PRE       TB_WRK021.SDOC_NO%TYPE;
    V_SDOC_SEQNO_PRE    TB_WRK021.SDOC_SEQNO%TYPE;
    V_STOR_LOC_CD       TB_INV001.STOR_LOC_CD%TYPE;
    V_CNL_YN            TB_WRK002.CNL_YN%TYPE;
    V_STRGR             VARCHAR2(10);
    V_REQ_DT            VARCHAR2(10);
    V_CNT               NUMBER;
    V_BUDAT				VARCHAR2(10);
   
    V_PARAM_LIST		VARCHAR2(4000);
    V_ERR_CODE 			VARCHAR2(3);
    V_ERR_MSG			VARCHAR2(4000);
    V_IF_MES_KEY		VARCHAR2(100);
    V_ERR_CODE_WMS		VARCHAR2(3);
    V_ERR_MSG_WMS		VARCHAR2(4000);
    V_RS_LIST			SYS_REFCURSOR;
   
    V_PROC_CD			VARCHAR2(30);
    V_JSONSTR			VARCHAR2(4000);
    V_REQ_DATE				VARCHAR2(8);			-- 프로시저 호출 변수
BEGIN
    OPEN P_RS_LIST FOR 
    SELECT NULL FROM DUAL WHERE ROWNUM = 0;    

    V_JSONSTR := REPLACE(P_JSON_STR, '^', '"');

    V_JSON := JSON_OBJECT_T.parse(V_JSONSTR);

DBMS_OUTPUT.PUT_LINE ('V_JSON = ' || V_JSON.to_string()); 
    V_SESS_USER_ID       :=       V_JSON.get_string('SES_USER_ID');
    V_PLT_CD             :=       V_JSON.get_string('SES_WAREKY');

    /* 조건값 할당 */
    V_RANGE_SQL          :=       V_JSON.get_string('RANGE_SQL');                   -- 작업지시 조회 시 일자

    V_WERKS              :=       V_JSON.get_string('WERKS');                   -- 플랜트코드
    V_IND_BCD            :=       V_JSON.get_string('IND_BCD');                 -- 개별바코드  

    IF P_TYPE = 'LIST' THEN 
        V_SQL :='SELECT I001.IND_BCD, 
                        I001.LOT_NO,
                        I001.MATNR,
                        M001.MATNR_NM,
                        CASE WHEN W002.PACKTYPE = ''A'' OR W002.PACKTYPE = ''B''  THEN ''SHEET 판지제품''
                           ELSE ''ROLL 원지제품'' END  PROD_TYPE,                          --제품타입
                        M001.PCODE_NM,                                                  --지종
                        M001.BS_WGT,                                                    --평량
                        SUBSTR(W002.MATNR, 10, 4) || '' * '' || SUBSTR(W002.MATNR, 14, 4) MATNR_SPEC,                                                --규격
                        TO_CHAR(NVL(W002.SCNT, 0)) || ''/'' || TO_CHAR(NVL(W002.MCNT, 0))   AS SMCNT,   --속/매
                        CASE WHEN W002.PACKTYPE = ''A'' OR W002.PACKTYPE = ''B''  THEN TO_CHAR(I001.STCK_QTY, ''FM9990.09'') || '' R''
                             ELSE TO_CHAR(I001.ROLLCNT, ''FM999,999,990'') || '' M'' END AS PRFM_QTY,      --권치수/연수
                        TO_CHAR(W002.WGT, ''FM999,999,990'') || '' KG''  AS WGT,                --중량
                        FN_CD_VAL(''PACK_TYPE'', W002.PACKTYPE)  AS PACKTYPE,   --포장타입
                        (SELECT NVL(CUST_NM, '' '') FROM TB_MAS009 WHERE CUST_DIV = ''C'' AND CUST_CD = W002.KUNNR ) KUNNR,                             --거래처
                        FN_CD_VAL(''STCK_STA'', I001.STCK_STA) || '' ('' || I001.STOR_LOC_CD || '')''   PRD_STA                              --포장실적상태
                  FROM TB_INV001 I001,
                       TB_WRK002 W002,
                       TB_SCH018 S018,
                       TB_MAS001 M001
                 WHERE I001.WERKS = W002.WERKS(+)
                   AND I001.IND_BCD = W002.IND_BCD(+)
                   AND I001.WRK_ORDR_NO = S018.WRK_ORDR_NO(+)
                   AND I001.WRK_ORDR_SEQNO = S018.WRK_ORDR_SEQNO(+) 
                   AND I001.WERKS = M001.WERKS(+)
                   AND I001.MATNR = M001.MATNR(+)
                   AND I001.WERKS = ''' || V_WERKS || ''' 
                   AND (I001.STOR_LOC_CD IN (''2600'',''3100'')  
                   OR I001.STOR_LOC_CD = ''2000'' AND I001.LOC_CD IN(''L2600'', ''L2300'')) ';

        V_SQL := V_SQL || ' AND I001.IND_BCD = ''' || V_IND_BCD || '''';               
        --V_SQL := V_SQL || ' AND I001.DOC_NO IS NULL';               

        BEGIN           
     		OPEN P_RS_LIST FOR V_SQL;

--        EXCEPTION           
--        WHEN OTHERS THEN 
--            P_SUCCESS           := 'N';
--            E_SQL_ERR_CD        := SQLCODE;
--            E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';
--
--            SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
--            RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);           
--            RETURN;           
        END;        
    ELSIF P_TYPE = 'SAVE1' THEN       --출고요청(SAP 재고이전)
        BEGIN        
            SELECT W002.MACH_CD, W002.MATNR, I001.STCK_QTY, W002.UNIT, W002.WGT,
                    W002.LOT_NO, W002.MACHINE, W002.ORDER_NO, W002.WRK_ORDR_NO, W002.WRK_ORDR_SEQNO,
                    W002.CORE, W002.PACKTYPE, W002.VBELN, W002.POSNR, W002.KUNNR, W002.REGID, 
                    W002.VLEN, W002.WLEN, W002.GRD_YN, W002.CNL_YN,
                    U001.NMLAST, W002.PRFM_DT, W002.PRD_DT, W002.DSTBT_DDLIN, W002.SDOC_NO, W002.SDOC_SEQNO, 
                    I001.STCK_STA, I001.WDOC_NO, I001.WDOC_SEQNO, I001.PACK_TYPE, I001.STOR_LOC_CD
                INTO V_MACH_CD, V_MATNR, V_PRFM_QTY, V_UNIT, V_WGT,
                     V_LOT_NO, V_MACHINE, V_ORDER_NO, V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO,
                     V_CORE, V_PACKTYPE, V_VBELN, V_POSNR, V_KUNNR, V_REGID, 
                     V_VLEN, V_WLEN, V_GRD_YN, V_CNL_YN,
                     V_USER_NM, V_PRFM_DT, V_PRD_DT, V_DSTBT_DDLIN, V_SDOC_NO, V_SDOC_SEQNO, 
                     V_STCK_STA, V_WDOC_NO, V_WDOC_SEQNO, V_PACK_TYPE, V_STOR_LOC_CD
              FROM TB_WRK002 W002,
                   TB_INV001 I001,
                    USRMA U001
             WHERE W002.WERKS = I001.WERKS(+)
               AND W002.IND_BCD = I001.IND_BCD(+)
               AND W002.REGID = U001.USERID(+)
               AND W002.WERKS = V_WERKS
               AND W002.IND_BCD = V_IND_BCD;

            IF NVL(V_CNL_YN, 'N') = 'Y' THEN
                P_SUCCESS := 'N';
                P_ERR_MSG := V_IND_BCD || '는 실적 취소된 바코드입니다.';
                ROLLBACK;
                RETURN;
            END IF;

            IF NVL(V_SDOC_NO, ' ') = ' ' OR NVL(V_SDOC_NO, ' ') = 'E' THEN
                P_SUCCESS := 'N';
                P_ERR_MSG := V_MATNR || ' 는 실적등록이 되지 않아 생산출고 요청할 수 없습니다.';  
                ROLLBACK;
                RETURN;
            END IF;

            IF SUBSTR(V_MACH_CD, 1, 3) = 'PCA' OR SUBSTR(V_MACH_CD, 1, 3) = 'PCB' THEN
            	IF SUBSTR(V_WRK_ORDR_NO, 0, 4) != 'WOEX' THEN
	                P_SUCCESS := 'N';
	                P_ERR_MSG := V_MATNR || ' 는 반제품 생산출고 할 수 없습니다.';
	                ROLLBACK;
	                RETURN;
	            END IF;
            END IF;

            IF V_STCK_STA = '70' THEN
                P_SUCCESS := 'N';
                P_ERR_MSG := V_MATNR || ' 는 이미 생산출고 되었습니다.';
                ROLLBACK;
                RETURN;
            END IF;

            IF V_STCK_STA = '80' THEN
                P_SUCCESS := 'N';
                P_ERR_MSG := V_MATNR || ' 는 이미 생산출고요청 되었습니다.';
                ROLLBACK;
                RETURN;
            END IF;

            --재고수량체크
            IF NVL(V_PACK_TYPE, ' ') = 'A' OR NVL(V_PACK_TYPE, ' ') = 'B' THEN  --시트일경우
                IF NVL(V_STOR_LOC_CD, ' ') <> '2600' THEN
                    P_SUCCESS := 'N';
                    P_ERR_MSG := V_STOR_LOC_CD || ' 시트일 경우 저장위치가 2600입니다.';
                    ROLLBACK;
                    RETURN;
                END IF;
            ELSE                                                                --원지일경우
                IF NVL(V_STOR_LOC_CD, ' ') <> '2000' THEN
                    P_SUCCESS := 'N';
                    P_ERR_MSG := V_STOR_LOC_CD || ' 저장위치의 재고가 없습니다.';
                    ROLLBACK;
                    RETURN;
                END IF;
            END IF;

            IF NVL(V_PRFM_QTY, 0) <= 0 THEN
                P_SUCCESS := 'N';
                P_ERR_MSG := V_MATNR || ' 는 재고가 없습니다.';
                ROLLBACK;
                RETURN;
            END IF;

            IF NVL(V_PACK_TYPE, ' ') = 'A' OR NVL(V_PACK_TYPE, ' ') = 'B' THEN
                --재고이전 I/F
                V_DOC_NO_1 := FN_GET_MDOCNO('M','IF131');
                V_DOC_SEQNO_1 := 1;

                V_STOR_LOC_FR := '2600';            --판지제품
                V_STOR_LOC_TO := '3100';
               
				--20230203 여한진 전기일자 추가
                V_BUDAT := FN_RECDATE(V_DATE); 
               
--                V_BUDAT := '20240131';
                --재고이전처리(저장위치 2600 --> 3100)
                INSERT INTO TB_WRK017(DOC_NO, DOC_SEQNO, MOVE_DIV, WERKS_FR, WERKS_TO,
                                    MATNR_FR, MATNR_TO, STOR_LOC_FR, STOR_LOC_TO, CHARG_FR, CHARG_TO, MOVE_QTY, UNIT,
                                    AUFNR, WRK_ORDR_NO_FR, WRK_ORDR_SEQNO_FR, WRK_ORDR_NO_TO, WRK_ORDR_SEQNO_TO, UCFMTY_YN,
                                    RMK, REGDATE, REGID, IND_BCD, VBELN_FROM, POSNR_FROM, VBELN_TO, POSNR_TO, BUDAT)
                            VALUES(V_DOC_NO_1, V_DOC_SEQNO_1, '311', V_WERKS, V_WERKS,
                                    V_MATNR, V_MATNR, V_STOR_LOC_FR, V_STOR_LOC_TO, V_LOT_NO, V_LOT_NO, V_PRFM_QTY, V_UNIT,
                                    '', V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, 'N',
                                    '', V_DATE, V_SESS_USER_ID, V_IND_BCD, V_VBELN, V_POSNR, V_VBELN, V_POSNR, V_BUDAT);

                INSERT INTO TB_IFS009(BWART, WERKS_FROM, WERKS_TO, MATNR_FROM, MATNR_TO,
                                    LGORT_FROM, LGORT_TO, CHARG_FROM, CHARG_TO, AUFNR, MENGE, MEINS, FAULTY,
                                    MDOCNO, MDOCSEQ, ZRESULT, MAKE_DATE, MAKER, LTCHG,
                                    VBELN_FROM, POSNR_FROM, VBELN_TO, POSNR_TO, BUDAT)
                            VALUES('311', V_WERKS, V_WERKS, V_MATNR, V_MATNR,
                                    V_STOR_LOC_FR, V_STOR_LOC_TO, V_LOT_NO, V_LOT_NO, '', V_PRFM_QTY, V_UNIT, '',
                                    V_DOC_NO_1, V_DOC_SEQNO_1, 'N', V_DATE, V_SESS_USER_ID, '',
                                    V_VBELN, V_POSNR , V_VBELN, V_POSNR, V_BUDAT);

                INSERT INTO TB_WRK021(DOC_NO, DOC_SEQNO, DOC_DIV, WERKS, MACH_CD, WRK_ORDR_NO, WRK_ORDR_SEQNO,
                                        IND_BCD, LOT_NO, ORDER_NO, CNL_YN, REGDATE, REGID)
                                VALUES(V_DOC_NO_1, V_DOC_SEQNO_1, '6', V_WERKS, V_MACH_CD, V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO,
                                        V_IND_BCD, V_LOT_NO, V_ORDER_NO, 'N', V_DATE, V_SESS_USER_ID);                   
            END IF;

            P_DOC_NO1 := V_DOC_NO_1;

--        EXCEPTION           
--        WHEN OTHERS THEN 
--            P_SUCCESS           := 'N';
--            E_SQL_ERR_CD        := SQLCODE;
--            E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';
--
--            SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
--            RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);           
--            ROLLBACK;
--            RETURN;           
        END;      
    ELSIF P_TYPE = 'SAVE2' THEN       --출고요청(WMS 입고요청)
        BEGIN        
            SELECT W002.MACH_CD, W002.MATNR, I001.STCK_QTY, W002.UNIT, W002.WGT, W002.MACH_CD,
                    W002.LOT_NO, W002.MACHINE, W002.ORDER_NO, W002.WRK_ORDR_NO, W002.WRK_ORDR_SEQNO,
                    W002.CORE, W002.PACKTYPE, W002.VBELN, W002.POSNR, W002.KUNNR, W002.REGID, 
                    W002.VLEN, W002.WLEN, W002.GRD_YN, 
                    U001.NMLAST, W002.PRFM_DT, W002.PRD_DT, W002.DSTBT_DDLIN, W002.SDOC_NO, W002.SDOC_SEQNO, 
                    I001.STCK_STA, I001.WDOC_NO, I001.WDOC_SEQNO, I001.PACK_TYPE, I001.STOR_LOC_CD
                INTO V_MACH_CD, V_MATNR, V_PRFM_QTY, V_UNIT, V_WGT, V_MACH_CD,
                     V_LOT_NO, V_MACHINE, V_ORDER_NO, V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO,
                     V_CORE, V_PACKTYPE, V_VBELN, V_POSNR, V_KUNNR, V_REGID, 
                     V_VLEN, V_WLEN, V_GRD_YN,
                     V_USER_NM, V_PRFM_DT, V_PRD_DT, V_DSTBT_DDLIN, V_SDOC_NO, V_SDOC_SEQNO, 
                     V_STCK_STA, V_WDOC_NO, V_WDOC_SEQNO, V_PACK_TYPE, V_STOR_LOC_CD
              FROM TB_WRK002 W002,
                   TB_INV001 I001,
                    USRMA U001
             WHERE W002.WERKS = I001.WERKS(+)
               AND W002.IND_BCD = I001.IND_BCD(+)
               AND W002.REGID = U001.USERID(+)
               AND W002.WERKS = V_WERKS
               AND W002.IND_BCD = V_IND_BCD;

            IF SUBSTR(V_MACH_CD, 1, 3) = 'PCA' OR SUBSTR(V_MACH_CD, 1, 3) = 'PCB' THEN
            	IF SUBSTR(V_WRK_ORDR_NO, 0 ,4) != 'WOEX' THEN
	            	P_SUCCESS := 'N';
	                P_ERR_MSG := V_MATNR || ' 는 반제품 생산출고 할 수 없습니다.';
	                ROLLBACK;
	                RETURN;
                END IF;
            END IF;

            IF V_STCK_STA = '70' THEN
                P_SUCCESS := 'N';
                P_ERR_MSG := V_MATNR || ' 는 이미 생산출고 되었습니다.';
                ROLLBACK;
                RETURN;
            END IF;

            IF V_STCK_STA = '80' THEN
                P_SUCCESS := 'N';
                P_ERR_MSG := V_MATNR || ' 는 이미 생산출고요청 되었습니다.';
                ROLLBACK;
                RETURN;
            END IF;

            --완제품 입고요청 I/F
            V_DOC_NO_2 := FN_GET_MDOCNO('M','IF402');
            V_DOC_SEQNO_2 := 1;

            BEGIN
            SELECT PCODE, BS_WGT, SAUART_DIV AS OAUART_DIV, CON_TYPE 
                INTO V_PCODE, V_BS_WGT, V_OAUART_DIV, V_CON_TYPE
              FROM(
                    SELECT PCODE, BS_WGT, SAUART_DIV, CON_TYPE 
                      FROM TB_SCH018        --포장 작업지시
                     WHERE WRK_ORDR_NO = V_WRK_ORDR_NO
                       AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
                    UNION ALL
                    SELECT PCODE, BS_WGT, SAUART_DIV, NULL AS CON_TYPE 
                      FROM TB_SCH016        --밀롤 작업지시
                     WHERE WRK_ORDR_NO = V_WRK_ORDR_NO
                       AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
                    UNION ALL
                    SELECT PCODE, BS_WGT, ORDER_DIV AS SAUART_DIV,  NULL AS CON_TYPE 
                      FROM TB_SCH019        --예외 작업지시
                     WHERE WRK_ORDR_NO = V_WRK_ORDR_NO
                       AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO   
                    );
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    V_PCODE := '';
            END;

            IF NVL(V_PCODE, ' ' ) = ' ' THEN
                SELECT M001.PCODE, M001.BS_WGT, '' AS SAUART_DIV, I001.CON_TYPE
                  INTO V_PCODE, V_BS_WGT, V_OAUART_DIV, V_CON_TYPE
                  FROM TB_INV001 I001,
                       TB_MAS001 M001
                 WHERE I001.WERKS = M001.WERKS(+)
                   AND I001.MATNR = M001.MATNR(+)
                   AND I001.IND_BCD = V_IND_BCD;
            END IF;

            BEGIN

            --국가코드
            SELECT LAND1 INTO V_NTN_CD
              FROM TB_MAS009 M009
             WHERE M009.CUST_CD = V_KUNNR
               AND CUST_DIV = 'C'; 
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    V_NTN_CD := '';
            END;
             --자재코드 5번째 자리 2 = 수출, 그외 = 내수
            V_USER_NM_EN := SUBSTR(V_USER_NM_EN, 1, INSTR(V_USER_NM_EN , '@') -1 ) ;

            IF SUBSTR(V_MATNR, 5, 1) = '2' THEN
                V_USER_NM := V_USER_NM_EN;
            END IF;

            V_POSNR_N := SUBSTR('000000' || TO_CHAR(V_POSNR), -6);
            V_STOCK_NO := SUBSTR('0000' || V_VBELN, -10) || V_POSNR_N;
            V_RCVGDS_DT := V_PRFM_DT; 

            IF V_STOR_LOC_CD <> '3100' THEN
                IF NVL(V_PACK_TYPE, ' ') = 'A' OR NVL(V_PACK_TYPE, ' ') = 'B' THEN
                    V_STOR_LOC_FR := '3100';
                    V_STOR_LOC_TO := '3000';        
                 ELSE
                    V_STOR_LOC_FR := '2000';            --원지제품
                    V_STOR_LOC_TO := '3000';
                END IF;
            END IF;

            --완제품 출고 요청(이력)   
            --MTO/MTS 구분
            BEGIN
            SELECT STRGR INTO V_STRGR 
              FROM TB_MAS001
             WHERE WERKS = V_WERKS
               AND MATNR = V_MATNR;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    V_STRGR := '00';
            END;

            IF V_STRGR = '20' OR V_STRGR = '50' THEN    --MTO
                V_VBELN := SUBSTR('0000'|| V_VBELN, -10);
                V_POSNR := SUBSTR('000000' || V_POSNR, -6);
            ELSE                                        --MTS
                V_VBELN := '';
                V_POSNR := '';
                V_POSNR_N :='';
                V_STOCK_NO := '';
                V_KUNNR :='';
            END IF;

            IF NVL(V_GRD_YN, ' ') = 'Y' THEN
                V_VBELN := '';
                V_POSNR := '';
                V_POSNR_N :='';
                V_STOCK_NO := '';
                V_KUNNR :='';
            END IF;
            
            INSERT INTO TB_WRK015( DOC_NO, DOC_SEQNO, DLFL,
                                    WERKS, MATNR, QTY, UNIT, STOR_LOC_FR, STOR_LOC_TO, WGT,
                                    IND_BCD, LOT_NO, MACHINE, ORDER_NO, WRK_ORDR_NO, WRK_ORDR_SEQNO,
                                    PCODE, BS_WGT, WLEN, VLEN, CON_TYPE, PACKTYPE, VBELN, POSNR, SAUART, KUNNR,
                                    CORE, EMPLY_NO, EMPLY_NM, NTN_CD, PRD_DT, RCVGDS_DT, PRFM_DT, DSTBT_DDLIN,
                                    STCK_NO, REQ_STA, REGDATE, REGID)
                            VALUES( V_DOC_NO_2, V_DOC_SEQNO_2, 'C',
                                    V_WERKS, V_MATNR, V_PRFM_QTY, V_UNIT, DECODE(NVL(V_PACKTYPE, ' '), ' ', V_STOR_LOC_FR , '3100'), DECODE(NVL(V_PACKTYPE, ' '), ' ', V_STOR_LOC_TO, '3000'), V_WGT,
                                    V_IND_BCD, V_LOT_NO, V_MACHINE, V_ORDER_NO, V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO,
                                    V_PCODE, V_BS_WGT, V_WLEN, V_VLEN, V_CON_TYPE, V_PACKTYPE, V_VBELN, V_POSNR, '', V_KUNNR,
                                    V_CORE, V_REGID, V_USER_NM, V_NTN_CD, V_PRD_DT, V_RCVGDS_DT, V_PRFM_DT, V_DSTBT_DDLIN,
                                    V_STOCK_NO, 'R', V_DATE, V_SESS_USER_ID);
            --IF 테이블에 등록
            V_REQ_DT := TO_CHAR(V_DATE, 'YYYYMMDD');
            INSERT INTO TB_IFSWM005( DOC_NO, DOC_SEQNO, DLFL,
                                    WERKS, MATNR, QTY, UNIT, STOR_LOC_FROM, STOR_LOC_TO,
                                    IND_BCD, LOT_NO, MACHINE, ORDER_NO, ORDER_SEQNO, 
                                    PCODE, WEIGHT, WLEN, VLEN, CON_TYPE, PACK_TYPE, OVBELN, OPOSNR, SAUART, KUNNR,
                                    CORE, EMPLY_NO, EMPLY_NM, NTN_CD, PRDC_DT, RCVGDS_DT, DSTBT_DDLIN, STCK_NO,
                                    IF_STATUS, IF_GET_DATE, REQ_DT)
                             VALUES( V_DOC_NO_2, V_DOC_SEQNO_2, 'C',
                                    V_WERKS, V_MATNR, V_PRFM_QTY, V_UNIT, DECODE(NVL(V_PACKTYPE, ' '), ' ', V_STOR_LOC_FR , '3100'), DECODE(NVL(V_PACKTYPE, ' '), ' ', V_STOR_LOC_TO, '3000'),
                                    V_IND_BCD, V_LOT_NO, V_MACHINE, V_ORDER_NO, '000000',
                                    V_PCODE, V_BS_WGT, V_WLEN, V_VLEN, V_CON_TYPE, V_PACKTYPE, V_VBELN, V_POSNR_N, V_OAUART_DIV, V_KUNNR,
                                    V_CORE, V_REGID, V_USER_NM, V_NTN_CD, V_PRFM_DT, V_PRFM_DT, V_DSTBT_DDLIN, V_STOCK_NO,
                                    'N', V_DATE, V_REQ_DT);

			P_DOC_NO2 := V_DOC_NO_2;

			-- DB Link
            V_PROC_CD := 'POP_WRK20'; 
--			V_PARAM_LIST:= '{''PROC_CD'': ''' || V_PROC_CD || '''' || ', ''list'': [{''map'' : {''WERKS'': ''' || V_WERKS || '''' || ', ''MACH_CD'' : ''' || V_MACH_CD || '''' || ', ''PROC_CD'': ''' || V_PROC_CD || '''' || ', ''MATNR'' : ''' || V_MATNR || '''' || ', ''IND_BCD'' : ''' || V_IND_BCD || '''' || ', ''LOT_NO'' : ''' || V_LOT_NO || '''' || ', ''PRFM_QTY'' : ''' || V_PRFM_QTY || '''' || ', ''UNIT'' : ''' || V_UNIT || '''' || ', ''PRFM_DT'' : ''' || V_PRFM_DT || '''}}]}';
            V_REQ_DATE := TO_CHAR(V_DATE, 'YYYYMMDD');
--			V_PARAM_LIST := '{"CON_TYPE":"","CORE":"","SAUART":"","STOR_LOC_TO":"' || V_STOR_LOC_TO || '","EMPLY_NM":"' || V_USER_NM || '","OVBELN":"' || V_VBELN || '","WERKS": "' ||V_WERKS || '","EMPLY_NO": "' || V_REGID || '","IND_BCD":"' || V_IND_BCD || '","DOC_NO":"' || V_DOC_NO_2 || '","ORDER_NO":"' || V_ORDER_NO || '","PACK_TYPE":"' || V_PACKTYPE || '","OPOSNR":"' || V_POSNR_N || '","WLEN":"","QTY":"' ||V_PRFM_QTY || '","MACHINE":"' || V_MACHINE || '","WEIGHT":"","IF_GET_DATE":"' || V_DATE || '","STOR_LOC_FROM":"' || V_STOR_LOC_FR || '","MATNR":"' || V_MATNR || '","IF_SET_DATE":"","KUNNR":"","RCVGDS_DT":"' || V_REQ_DATE || '","DOC_SEQNO":"' || V_DOC_SEQNO_2 || '","UNIT":"' || V_UNIT || '","SEND_YN":"N","NTN_CD":"KR","ORDER_SEQNO":"1","IF_MES_KEY":"","DLFL":"C","REQ_DT":"' || V_REQ_DATE || '","PRDC_DT":"' || V_PRFM_DT || '","IF_STATUS":"N","VLEN":"","STCK_NO":"","IF_ERR_MESS":"","PCODE":"","LOT_NO":"' || V_LOT_NO || '","DSTBT_DDLIN":"' || V_DSTBT_DDLIN || '"}';
			V_PARAM_LIST := '{"CON_TYPE":"' || V_CON_TYPE || '","CORE":"","SAUART":"","STOR_LOC_TO":"' || V_STOR_LOC_TO || '","EMPLY_NM":"' || V_USER_NM || '","OVBELN":"' || V_VBELN || '","WERKS": "' ||V_WERKS || '","EMPLY_NO": "' || V_REGID || '","IND_BCD":"' || V_IND_BCD || '","DOC_NO":"' || V_DOC_NO_2 || '","ORDER_NO":"' || V_ORDER_NO || '","PACK_TYPE":"' || V_PACKTYPE || '","OPOSNR":"' || V_POSNR_N || '","WLEN":"","QTY":"' ||V_PRFM_QTY || '","MACHINE":"' || V_MACHINE || '","WEIGHT":"' || V_BS_WGT || '","IF_GET_DATE":"' || V_DATE || '","STOR_LOC_FROM":"' || V_STOR_LOC_FR || '","MATNR":"' || V_MATNR || '","IF_SET_DATE":"","KUNNR":"' || V_KUNNR || '","RCVGDS_DT":"' || V_REQ_DATE || '","DOC_SEQNO":"' || V_DOC_SEQNO_2 || '","UNIT":"' || V_UNIT || '","SEND_YN":"N","NTN_CD":"KR","ORDER_SEQNO":"1","IF_MES_KEY":"","DLFL":"C","REQ_DT":"' || V_REQ_DATE || '","PRDC_DT":"' || V_PRFM_DT || '","IF_STATUS":"N","VLEN":"","STCK_NO":"","IF_ERR_MESS":"","PCODE":"","LOT_NO":"' || V_LOT_NO || '","DSTBT_DDLIN":"' || V_DSTBT_DDLIN || '"}';

DBMS_OUTPUT.PUT_LINE ('V_PARAM_LIST : ' || V_PARAM_LIST);		
			DBLINK_WMSIF205@KNRAWMSLINK (V_PARAM_LIST, V_ERR_CODE, V_ERR_MSG); 

			IF V_ERR_CODE <> 'S'	THEN
				P_SUCCESS := V_ERR_CODE;
				P_ERR_MSG := V_ERR_MSG;
				RAISE E_EXCEPTION_USER;
			ELSE
			    --출고요청시 상태 변경
				SELECT 'M' || LTRIM(RTRIM(TO_CHAR(SEQ_GET_IFR_KEY.NEXTVAL, '00000000000000000000000000000')))	INTO V_IF_MES_KEY FROM DUAL;
			
				UPDATE	TB_INV001
			       SET	STCK_STA = '80',
						STOR_LOC_CD = V_STOR_LOC_FR,
						UPDDATE = SYSDATE,
						UPDID = V_REGID
			     WHERE	1=1
			       AND	WERKS = V_WERKS
			       AND	MATNR = V_MATNR
			       AND	IND_BCD = V_IND_BCD;
			
				-- 출고요청 테이블 상태 변경
			    UPDATE	TB_IFSWM005
			    	SET   IF_STATUS = V_ERR_CODE
			    		, IF_ERR_MESS = V_ERR_MSG
			    		, IF_SET_DATE = SYSDATE
			    		, IF_MES_KEY = V_IF_MES_KEY
			    WHERE	IND_BCD = V_IND_BCD
			    AND 	IF_STATUS = 'N'
			    AND 	DOC_NO = V_DOC_NO_2;
			   
				-- 실적 테이블 업데이트
			    UPDATE	TB_WRK001
			    	SET   CHK_PP_YN = 'Y'
			    		, CHK_PP_DATE = V_DATE
			    		, CHK_PP_ID = V_REGID
			    WHERE 	WERKS = V_WERKS
			    AND 	MACH_CD = V_MACH_CD
			    AND 	IND_BCD = V_IND_BCD;
			   
				P_SUCCESS := V_ERR_CODE;
				P_ERR_MSG := V_ERR_MSG;
			END IF;
		
--        EXCEPTION           
--        WHEN OTHERS THEN 
--            P_SUCCESS           := 'N';
--            E_SQL_ERR_CD        := SQLCODE;
--            E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';
--
--            SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
--            RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);           
--            ROLLBACK;
--            RETURN;           
        END;
    ELSIF P_TYPE = 'DELETE1' THEN       --출고요청취소(재고이전 취소 데이터 생성)
    	BEGIN
			SELECT W002.MACH_CD, W002.MATNR, SUBSTR(W002.MATNR, 14, 4),
			        W002.REGID, 
			        U001.NMLAST, W002.SDOC_NO, W002.SDOC_SEQNO, 
			        I001.STCK_STA, I001.WDOC_NO, I001.WDOC_SEQNO, I001.PACK_TYPE,
			        I001.STCK_QTY, I001.LOT_NO
			    INTO V_MACH_CD, V_MATNR, V_MATNR_SPEC,
			         V_REGID, 
			         V_USER_NM, V_SDOC_NO, V_SDOC_SEQNO, 
			         V_STCK_STA, V_WDOC_NO, V_WDOC_SEQNO, V_PACK_TYPE,
			         V_PRFM_QTY, V_LOT_NO
			  FROM TB_WRK002 W002,
			       TB_INV001 I001,
			        USRMA U001
			 WHERE W002.WERKS = I001.WERKS(+)
			   AND W002.IND_BCD = I001.IND_BCD(+)
			   AND W002.REGID = U001.USERID(+)
			   AND W002.WERKS = V_WERKS
			   AND W002.IND_BCD = V_IND_BCD;
	
--	        IF V_STCK_STA = '70' THEN
--	            P_SUCCESS           := 'N';
--	            P_ERR_MSG := V_MATNR || ' 는 이미 생산출고 완료되어 생산출고 취소를 할수 없습니다.';
--	            ROLLBACK;
--	            RETURN;
--	        END IF;
--	
--	        IF V_STCK_STA = '00' THEN
--	            P_SUCCESS           := 'N';
--	            P_ERR_MSG := V_MATNR || ' 는 생산출고 요청되지 않은 제품으로  생산출고 취소를 할수 없습니다.';
--	            ROLLBACK;
--	            RETURN;
--	        END IF;
	
	        V_CNT := 1;
	        BEGIN
	        SELECT DOC_NO, DOC_SEQNO, SDOC_NO, SDOC_SEQNO    
	            INTO V_DOC_NO_PRE, V_DOC_SEQNO_PRE, V_SDOC_NO_PRE, V_SDOC_SEQNO_PRE
	          FROM(
	            SELECT DOC_NO, DOC_SEQNO, SDOC_NO, SDOC_SEQNO
	              FROM TB_WRK021
	             WHERE DOC_DIV = '6'
	               AND WERKS = V_WERKS
	               AND IND_BCD = V_IND_BCD
	               AND NVL(CNL_YN, 'N') = 'N'
	             ORDER BY REGDATE DESC)
	         WHERE ROWNUM = 1;    
	        EXCEPTION
	            WHEN NO_DATA_FOUND THEN
	                V_CNT := 0; 
	        END;
	
--	        IF V_CNT > 0 AND NVL(V_SDOC_NO_PRE, ' ' ) <> ' '  AND NVL(V_SDOC_NO_PRE, ' ' ) <> 'E' THEN
	            --재고이전 취소
	            V_DOC_NO_1 := FN_GET_MDOCNO('M','IF132');
	            V_DOC_SEQNO_1 := 1;
	
	            SELECT MENGE INTO V_PRFM_QTY
	              FROM TB_IFS009
	             WHERE MDOCNO = V_DOC_NO_PRE;
	
	            SELECT SAP_WRK_CD  INTO V_SAP_WRK_CD
	              FROM TB_MAS012
	             WHERE MACH_CD = V_MACH_CD; 
	
	            V_PRFM_DT := FN_RECDATE(V_DATE);
	
	            INSERT INTO TB_IFS010(AUFNR, POSNR, BUDAT, MATNR, MENGE,
	                                    WERKS, LGORT, CHARG, WORKCENTERCODE, 
	                                    MDOCNO, MDOCSEQ, MBLNR, MJAHR, 
	                                    ZRESULT, MAKE_DATE, MAKER, GRCHK)
	                           VALUES('', '10', V_PRFM_DT, V_MATNR, V_PRFM_QTY,
	                                    V_WERKS, '3100', V_LOT_NO, V_SAP_WRK_CD,
	                                    V_DOC_NO_1, TO_CHAR(V_DOC_SEQNO_1), V_SDOC_NO_PRE, V_SDOC_SEQNO_PRE, 
	                                    'N', V_DATE, V_REGID, '');   
--	        END IF;
	
	        P_DOC_NO1 := V_DOC_NO_1;
	    END;
    ELSIF	P_TYPE = 'DELETE2' THEN       --출고요청취소(MES Data Rollback, WMS Data Rollback)
    	BEGIN
            SELECT W002.MACH_CD, W002.MATNR, SUBSTR(W002.MATNR, 14, 4),
                    W002.REGID, 
                    U001.NMLAST, W002.SDOC_NO, W002.SDOC_SEQNO, 
                    I001.STCK_STA, I001.WDOC_NO, I001.WDOC_SEQNO, I001.PACK_TYPE,
                    I001.STCK_QTY, I001.LOT_NO
                INTO V_MACH_CD, V_MATNR, V_MATNR_SPEC,
                     V_REGID, 
                     V_USER_NM, V_SDOC_NO, V_SDOC_SEQNO, 
                     V_STCK_STA, V_WDOC_NO, V_WDOC_SEQNO, V_PACK_TYPE,
                     V_PRFM_QTY, V_LOT_NO
              FROM TB_WRK002 W002,
                   TB_INV001 I001,
                    USRMA U001
             WHERE W002.WERKS = I001.WERKS(+)
               AND W002.IND_BCD = I001.IND_BCD(+)
               AND W002.REGID = U001.USERID(+)
               AND W002.WERKS = V_WERKS
               AND W002.IND_BCD = V_IND_BCD;

            IF V_STCK_STA = '70' THEN
                P_SUCCESS           := 'N';
                P_ERR_MSG := V_MATNR || ' 는 이미 생산출고 완료되어 생산출고 취소를 할수 없습니다.';
                ROLLBACK;
                RETURN;
            END IF;

            IF V_STCK_STA = '00' THEN
                P_SUCCESS           := 'N';
                P_ERR_MSG := V_MATNR || ' 는 생산출고 요청되지 않은 제품으로  생산출고 취소를 할수 없습니다.';
                ROLLBACK;
                RETURN;
            END IF;

            --WMS 입고취소  
            SELECT W015.DOC_NO, W015.DOC_SEQNO
                INTO V_DOC_NO, V_DOC_SEQNO
              FROM(
                    SELECT DOC_NO, DOC_SEQNO
                      FROM TB_WRK015
                     WHERE WERKS = V_WERKS
                       AND IND_BCD = V_IND_BCD
                       AND DLFL = 'C'
                    ORDER BY REGDATE DESC
                    ) W015
              WHERE ROWNUM = 1;       

            INSERT INTO TB_IFSWM005( DOC_NO, DOC_SEQNO, DLFL,
                                    WERKS, MATNR, QTY, UNIT, STOR_LOC_FROM, STOR_LOC_TO,
                                    IND_BCD, LOT_NO, MACHINE, ORDER_NO, ORDER_SEQNO, 
                                    PCODE, WEIGHT, WLEN, VLEN, CON_TYPE, PACK_TYPE, OVBELN, OPOSNR, SAUART, KUNNR,
                                    CORE, EMPLY_NO, EMPLY_NM, NTN_CD, PRDC_DT, RCVGDS_DT, DSTBT_DDLIN, STCK_NO,
                                    IF_STATUS, IF_GET_DATE, REQ_DT)    
            SELECT DOC_NO, DOC_SEQNO, 'D',
                WERKS, MATNR, QTY, UNIT, STOR_LOC_FROM, STOR_LOC_TO,
                IND_BCD, LOT_NO, MACHINE, ORDER_NO, ORDER_SEQNO, 
                PCODE, WEIGHT, WLEN, VLEN, CON_TYPE, PACK_TYPE, OVBELN, OPOSNR, SAUART, KUNNR,
                CORE, EMPLY_NO, EMPLY_NM, NTN_CD, PRDC_DT, RCVGDS_DT, DSTBT_DDLIN, STCK_NO,
                'N', V_DATE, REQ_DT
              FROM TB_IFSWM005     
             WHERE DOC_NO = V_DOC_NO
               AND DOC_SEQNO = V_DOC_SEQNO
               AND DLFL = 'C';

			P_DOC_NO2 := V_DOC_NO_2;

			-- DB Link
            V_PROC_CD := 'POP_WRK20'; 
--			V_PARAM_LIST:= '{''PROC_CD'': ''' || V_PROC_CD || '''' || ', ''list'': [{''map'' : {''WERKS'': ''' || V_WERKS || '''' || ', ''MACH_CD'' : ''' || V_MACH_CD || '''' || ', ''PROC_CD'': ''' || V_PROC_CD || '''' || ', ''MATNR'' : ''' || V_MATNR || '''' || ', ''IND_BCD'' : ''' || V_IND_BCD || '''' || ', ''LOT_NO'' : ''' || V_LOT_NO || '''' || ', ''PRFM_QTY'' : ''' || V_PRFM_QTY || '''' || ', ''UNIT'' : ''' || V_UNIT || '''' || ', ''PRFM_DT'' : ''' || V_PRFM_DT || '''}}]}';
            V_REQ_DATE := TO_CHAR(V_DATE, 'YYYYMMDD');
			V_PARAM_LIST := '{"CON_TYPE":"","CORE":"","SAUART":"","STOR_LOC_TO":"' || V_STOR_LOC_TO || '","EMPLY_NM":"' || V_USER_NM || '","OVBELN":"' || V_VBELN || '","WERKS": "' ||V_WERKS || '","EMPLY_NO": "' || V_REGID || '","IND_BCD":"' || V_IND_BCD || '","DOC_NO":"' || V_DOC_NO_2 || '","ORDER_NO":"' || V_ORDER_NO || '","PACK_TYPE":"' || V_PACKTYPE || '","OPOSNR":"' || V_POSNR_N || '","WLEN":"","QTY":"' ||V_PRFM_QTY || '","MACHINE":"' || V_MACHINE || '","WEIGHT":"","IF_GET_DATE":"' || V_DATE || '","STOR_LOC_FROM":"' || V_STOR_LOC_FR || '","MATNR":"' || V_MATNR || '","IF_SET_DATE":"","KUNNR":"","RCVGDS_DT":"' || V_REQ_DATE || '","DOC_SEQNO":"' || V_DOC_SEQNO_2 || '","UNIT":"' || V_UNIT || '","SEND_YN":"N","NTN_CD":"KR","ORDER_SEQNO":"1","IF_MES_KEY":"","DLFL":"D","REQ_DT":"' || V_REQ_DATE || '","PRDC_DT":"' || V_PRFM_DT || '","IF_STATUS":"N","VLEN":"","STCK_NO":"","IF_ERR_MESS":"","PCODE":"","LOT_NO":"' || V_LOT_NO || '","DSTBT_DDLIN":"' || V_DSTBT_DDLIN || '"}';

DBMS_OUTPUT.PUT_LINE ('V_PARAM_LIST : ' || V_PARAM_LIST);		
			DBLINK_WMSIF205@KNRAWMSLINK (V_PARAM_LIST, V_ERR_CODE, V_ERR_MSG); 

			IF V_ERR_CODE <> 'S'	THEN
				P_SUCCESS := V_ERR_CODE;
				P_ERR_MSG := V_ERR_MSG;
				RAISE E_EXCEPTION_USER;
			ELSE
			    --출고요청시 상태 변경
				SELECT 'M' || LTRIM(RTRIM(TO_CHAR(SEQ_GET_IFR_KEY.NEXTVAL, '00000000000000000000000000000')))	INTO V_IF_MES_KEY FROM DUAL;
			
				UPDATE	TB_INV001
			       SET	STCK_STA = '00',
						STOR_LOC_CD = V_STOR_LOC_FR,
						UPDDATE = SYSDATE,
						UPDID = V_REGID
			     WHERE	1=1
			       AND	WERKS = V_WERKS
			       AND	MATNR = V_MATNR
			       AND	IND_BCD = V_IND_BCD;
			
				-- 출고요청 테이블 상태 변경
			    UPDATE	TB_IFSWM005
			    	SET   IF_STATUS = V_ERR_CODE
			    		, IF_ERR_MESS = V_ERR_MSG
			    		, IF_SET_DATE = SYSDATE
			    		, IF_MES_KEY = V_IF_MES_KEY
			    WHERE	IND_BCD = V_IND_BCD
			    AND 	IF_STATUS = 'N'
			    AND 	DOC_NO = V_DOC_NO_2;
			   
				-- 실적 테이블 업데이트
			    UPDATE	TB_WRK001
			    	SET   CHK_PP_YN = 'Y'
			    		, CHK_PP_DATE = V_DATE
			    		, CHK_PP_ID = V_REGID
			    WHERE 	WERKS = V_WERKS
			    AND 	MACH_CD = V_MACH_CD
			    AND 	IND_BCD = V_IND_BCD;
			   
				P_SUCCESS := V_ERR_CODE;
				P_ERR_MSG := V_ERR_MSG;
			END IF;
	    END;
	ELSIF P_TYPE = 'DELETE3' THEN       --출고요청취소(MES Data Rollback)
		BEGIN
            SELECT W002.MACH_CD, W002.MATNR, SUBSTR(W002.MATNR, 14, 4),
                    W002.REGID, 
                    U001.NMLAST, W002.SDOC_NO, W002.SDOC_SEQNO, 
                    I001.STCK_STA, I001.WDOC_NO, I001.WDOC_SEQNO, I001.PACK_TYPE,
                    I001.STCK_QTY, I001.LOT_NO
                INTO V_MACH_CD, V_MATNR, V_MATNR_SPEC,
                     V_REGID, 
                     V_USER_NM, V_SDOC_NO, V_SDOC_SEQNO, 
                     V_STCK_STA, V_WDOC_NO, V_WDOC_SEQNO, V_PACK_TYPE,
                     V_PRFM_QTY, V_LOT_NO
              FROM TB_WRK002 W002,
                   TB_INV001 I001,
                    USRMA U001
             WHERE W002.WERKS = I001.WERKS(+)
               AND W002.IND_BCD = I001.IND_BCD(+)
               AND W002.REGID = U001.USERID(+)
               AND W002.WERKS = V_WERKS
               AND W002.IND_BCD = V_IND_BCD;

            V_CNT := 1;
	        BEGIN
		        SELECT DOC_NO, DOC_SEQNO   
		            INTO V_DOC_NO_PRE, V_DOC_SEQNO_PRE
		          FROM(
		            SELECT DOC_NO, DOC_SEQNO
		              FROM TB_WRK021
		             WHERE DOC_DIV = '6'
		               AND WERKS = V_WERKS
		               AND IND_BCD = V_IND_BCD
		               AND NVL(CNL_YN, 'N') = 'N'
		             ORDER BY REGDATE DESC)
		         WHERE ROWNUM = 1;    
	        EXCEPTION
	            WHEN NO_DATA_FOUND THEN
	                V_CNT := 0;
	        END;

	        SELECT PACK_TYPE INTO V_PACK_TYPE
	          FROM TB_INV001
	         WHERE WERKS = V_WERKS
	           AND IND_BCD = V_IND_BCD;

			UPDATE	TB_INV001
		       SET	STCK_STA = '00',
					STOR_LOC_CD = CASE WHEN NVL(V_PACK_TYPE, ' ') = 'A'  OR NVL(V_PACK_TYPE, ' ') = 'B' THEN '2600' ELSE '2000' END,
					LOC_CD = CASE WHEN NVL(V_PACK_TYPE, ' ') = 'A'  OR NVL(V_PACK_TYPE, ' ') = 'B' THEN 'L2800' ELSE 'L2300' END,
					UPDDATE = SYSDATE,
					UPDID = V_REGID
		     WHERE	1=1
		       AND	WERKS = V_WERKS
		       AND	MATNR = V_MATNR
		       AND	IND_BCD = V_IND_BCD;

	        IF V_CNT > 0 THEN
	            UPDATE TB_WRK021
	               SET CNL_YN = 'Y',
	                   UPDDATE = V_DATE,
	                   UPDID = V_REGID
	             WHERE DOC_NO = V_DOC_NO_PRE
	               AND DOC_SEQNO = V_DOC_SEQNO_PRE;
	        END IF;
		   
			P_SUCCESS := V_ERR_CODE;
			P_ERR_MSG := V_ERR_MSG;
		END;
	END IF;

    P_SUCCESS := 'S';

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
