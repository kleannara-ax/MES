
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_PDA_WRK06_LAMI" SP_PDA_WRK06_LAMI
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
 * PROGRAM ID    : SP_PDA_WRK06_LAMI{호출 프로그램 ID 기술}
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
 *       - [TB_LAMI_SL] : (.R..) 포장작업지시
 *       - [TB_WRK015] : (.R..) 완제품 출고요청
 *       - [TB_IFSWM005] : (.R..) 완제품 출고요청 인터페이스
 *       - [TB_MAS009] : (.R..) 거래처 정보
   *=============================================================================*/
    --프로그램 ID
    V_PRG_NM          VARCHAR2(100)  := 'SP_PDA_WRK06_LAMI';     -- PROCEDURE NAME

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
    V_VLEN              TB_LAMI_SL.VLEN%TYPE;
    V_WLEN              TB_LAMI_SL.WLEN%TYPE; 
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
                       TB_LAMI_SL S018,
                       TB_MAS001 M001
                 WHERE I001.WERKS = W002.WERKS(+)
                   AND I001.IND_BCD = W002.IND_BCD(+)
                   AND I001.WRK_ORDR_NO = S018.WRK_ORDR_NO(+)
                   AND I001.WRK_ORDR_SEQNO = S018.WRK_ORDR_SEQNO(+) 
                   AND I001.WERKS = M001.WERKS(+)
                   AND I001.MATNR = M001.MATNR(+)
                   AND I001.WERKS = ''' || V_WERKS || ''' 
                   AND I001.STOR_LOC_CD IN (''2810'') ';

        V_SQL := V_SQL || ' AND I001.IND_BCD = ''' || V_IND_BCD || '''';               
        --V_SQL := V_SQL || ' AND I001.DOC_NO IS NULL';               

        BEGIN           
     		OPEN P_RS_LIST FOR V_SQL;

        END;
    ELSIF P_TYPE = 'SAVE1' THEN       --출고요청(WMS 출고요청)
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
	            V_PCODE := '';
	            V_BS_WGT := '';
	            V_OAUART_DIV := '';
	            V_CON_TYPE := '';
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

            V_STOR_LOC_FR := '2810';
            V_STOR_LOC_TO := '3000';        

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
            V_REQ_DATE := TO_CHAR(V_DATE, 'YYYYMMDD');
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
	    END;
    ELSIF P_TYPE = 'DELETE1' THEN       --출고요청(WMS 출고요청)
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
--						STOR_LOC_CD = V_STOR_LOC_FR,
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
	END IF;

    P_SUCCESS := 'Y';

    COMMIT;
END;
/
