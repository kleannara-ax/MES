--------------------------------------------------------
--  DDL for Procedure SP_PDA_INV02_S01_20220825
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_PDA_INV02_S01_20220825" 
(
    P_TYPE           IN    varchar2, -- LIST, SUB_LIST, SUB_SAVE
	P_JSON_STR       IN    varchar2,
	P_RS_CODE       OUT    varchar2,    
    P_RS_MSG        OUT    varchar2,    
    P_DOC_NO        OUT    varchar2,    
    P_DOC_SEQNO     OUT    NUMBER,    
    P_SUCCESS       OUT    varchar2,
	P_RS_LIST       OUT    SYS_REFCURSOR
)
AS 
/*==============================================================================
 * PROGRAM ID    : PDA_INV02{호출 프로그램 ID 기술}
 * PROGRAM NAME  : PDA 자재투입{호출 프로그램 명 기술}
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 자재 투입관리{프로그램에 대한 상세한 내용 기술}
 *                 
 * AUTHOR NAME   : 유상호{최초 작성자 명 기술}
 * CREATE DATE   : 2022/05/04 {최초 작성일자 기술}
 * SYSTEM NAME   : PDA
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/05/04    1.0.0   유상호         Initial Version 
 * 2022/07/27    1.0.1   여한진         작업지시 조회 (팝업) 삭제 오더는 안 보이도록 수정
 * 2022/07/27    1.0.1   여한진         바코드 스캔 시 단종아닌 것만 조회되도록 수정
 * 2022/08/03    1.0.2   여한진         투입자재정보목록 조회수정(해당 작업지시에 자재가 투입됬는지 확인여부판단)
 *==============================================================================
 *  관련 테이블
 *       - [TB_MAS001] : (.R..) 자재 마스터                                
 *       - [TB_MAS015] : (CRUD) 검사항목별 기준정보 등록 마스트                              
 *       - [TB_MAS016] : (CRUD) 검사항목별 기준값 정보                                
 *=============================================================================*/
    --프로그램 ID
    V_PRG_NM          VARCHAR2(100)  := 'SP_PDA_INV02_S01';     -- PROCEDURE NAME

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
    V_WERKS            TB_WRK011.WERKS%TYPE;        -- 플랜트코드
    V_MATNR            TB_WRK011.MATNR%TYPE;        -- 자재코드
    V_MATNR_M            TB_WRK011.MATNR%TYPE;        -- 투입자재코드
    V_MMATNR           TB_WRK011.MATNR%TYPE;        -- BOM하위자재코드
    V_INMATNR          TB_WRK011.MATNR%TYPE;        -- 투입하위자재코드
    V_MACH_CD          TB_WRK011.MACH_CD%TYPE;      -- 설비코드
    V_IND_BCD          TB_INV001.IND_BCD%TYPE;      -- 업체/개별바코드
    V_IND_BCD_M          TB_INV001.IND_BCD%TYPE;      -- 업체/개별바코드
    V_PROC_CD          TB_MAS012.PROC_CD%TYPE;      -- 공정코드
    V_WRK_CD           TB_MAS012.WRK_CD%TYPE;        -- 작업장코드
    V_WRK_ORDR_NO      TB_WRK011.WRK_ORDR_NO%TYPE;  -- 작업지시번호
    V_WRK_ORDR_SEQNO   TB_WRK011.WRK_ORDR_SEQNO%TYPE;  -- 작업지시번호 순번
    V_ORDER_NO         TB_WRK011.ORDER_NO%TYPE; 
    V_INPUT_QTY        TB_INV003.IN_QTY%TYPE;           --투입수량
    V_STCK_QTY         TB_INV003.STCK_QTY%TYPE;         --재고수량
    V_LOT_NO           TB_INV001.LOT_NO%TYPE;           --LOT NO
    V_LOT_NO_M           TB_INV001.LOT_NO%TYPE;           --LOT NO
    V_SDATE             VARCHAR2(10);
    V_EDATE             VARCHAR2(10);
    V_CHG_BOM           VARCHAR2(10);
    V_CONTIN_FLG         VARCHAR2(20);
    V_DATE              DATE := SYSDATE;
    V_SEQNO             NUMBER;
    V_DOC_NO            VARCHAR2(20);
    V_DOC_SEQNO         NUMBER;
    V_SAP_WRK_CD        TB_MAS012.SAP_WRK_CD%TYPE;
    V_ORDER_ITM_NO      TB_SCH020.ORDER_ITM_NO%TYPE;
    V_PRFM_DT           VARCHAR2(10);
    V_PRD_DT            VARCHAR2(10);
    V_STOR_LOC_CD_M     VARCHAR2(10);
    V_UNIT              VARCHAR2(10);
    V_CHG_FLG           VARCHAR2(10);
    V_STCK_KY           TB_INV001.STCK_KY%TYPE;
    V_LOT_NUM           TB_INV001.LOT_NUM%TYPE;
    --V_MAKTX            TB_MAS001.MAKTX%TYPE; -- 자재명
    V_ROW_COUNT         NUMBER;
    V_SEARCH_FL         VARCHAR2(1);
    V_STOR_LOC_CD       VARCHAR2(10);
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
    V_PROC_CD            :=       V_JSON.get_string('SES_PROC_CD');                 -- 공정코드
    V_IND_BCD            :=       V_JSON.get_string('IND_BCD');                     -- 업체/개별바코드
    V_MATNR              :=       V_JSON.get_string('MATNR');                       -- 투입자재코드
    V_WRK_ORDR_NO        :=       V_JSON.get_string('WRK_ORDR_NO');                 -- 생산품에 대한 작업지시번호
    V_WRK_ORDR_SEQNO     :=       V_JSON.get_string('WRK_ORDR_SEQNO');              -- 생산품에 대한 작업지시번호 순번
    V_ORDER_NO           :=       V_JSON.get_string('ORDER_NO');                    -- 생산품에 대한 오더번호
    V_INPUT_QTY          :=       V_JSON.get_string('INPUT_QTY');                   -- 투입수량
    V_STCK_KY          :=       V_JSON.get_string('STCK_KEY');                   -- WMS 재고키
    V_LOT_NUM          :=       V_JSON.get_string('LOT_NUM');                   -- WMS 로트번호
    V_UNIT                :=       V_JSON.get_string('UNIT');              -- 단위

    V_DOC_NO :='';
    V_DOC_SEQNO := 0;
    V_SEARCH_FL := 'Y';

    IF P_TYPE = 'LIST' THEN /*업체/개별바코드 조회 리스트*/
        P_RS_CODE := 'S';
        IF V_WERKS = 'P500' THEN
            IF NVL(V_STCK_KY, ' ') <> ' ' OR NVL(V_LOT_NUM, ' ') <> ' ' THEN
                P_RS_CODE := 'U';
                V_SEARCH_FL := 'N';
                V_SQL := 'SELECT STOKKY    AS STCK_KEY,
                               LOTNUM       AS LOT_NUM,
                               SKUKEY       AS MATNR,
                               DESC01       AS MATNR_NM,
                               LOTA14       AS IND_BCD,
                               LOTA01       AS STOR_LOC_CD,              --저장위치
                               USEQTY       AS STCK_QTY,               --가용수량(재고량)
                               CASE WHEN LOTA06 = ''00'' THEN ''투입가능''
                                    WHEN LOTA06 = ''05'' THEN ''품질재고 자재입니다.''
                                    WHEN LOTA06 = ''10'' THEN ''보류재고 자재입니다.''
                                    WHEN LOTA06 = ''30'' THEN ''불용재고 자재입니다.''
                                    WHEN LOTA06 = ''50'' THEN ''폐기재고 자재입니다.'' END AS STCK_STA
                          FROM V_WMS_STKKY@KNRAWMSLINK' ;
                V_SQL := V_SQL || ' WHERE STOKKY = ''' || V_STCK_KY || '''';
                V_SQL := V_SQL || ' AND LOTNUM = ''' || V_LOT_NUM || '''';
                V_SQL := V_SQL || ' AND USEQTY > 0';
            ELSE
                BEGIN
                    SELECT STCK_QTY INTO V_STCK_QTY
                      FROM TB_INV001
                     WHERE WERKS = V_WERKS
                       AND IND_BCD = V_IND_BCD;
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        V_STCK_QTY := 0;
                END;

                IF V_STCK_QTY = 0 THEN      --MES 재고가 없을 경우
                    V_ROW_COUNT := 1;
                    BEGIN
                        SELECT LOTNUM INTO V_LOT_NUM
                          FROM V_WMS_STKKY@KNRAWMSLINK
                         WHERE LOTA02 = 'P500'
                           AND LOTA14 = V_IND_BCD
                           AND USEQTY > 0;
                    EXCEPTION
                        WHEN TOO_MANY_ROWS THEN
                            V_ROW_COUNT :=2;        
                    END;

                    IF V_ROW_COUNT > 1 THEN
                        P_RS_CODE := 'P';
                        V_SEARCH_FL := 'N';
                        V_SQL := 'SELECT STOKKY,
                                       LOTNUM,
                                       LOTA01,              --저장위치
                                       LOTA01_NM,            --저장위치명              
                                       USEQTY               --가용수량(재고량)
                                  FROM V_WMS_STKKY@KNRAWMSLINK' ;

                        V_SQL := V_SQL || ' WHERE LOTA02 = ''' || V_WERKS || '''';
                        V_SQL := V_SQL || ' AND LOTA14 = ''' || V_IND_BCD || '''';
                        V_SQL := V_SQL || ' AND USEQTY > 0';
                    ELSE
                        P_RS_CODE := 'U';
                        V_SEARCH_FL := 'N';
                        V_SQL := 'SELECT STOKKY    AS STCK_KEY,
                                       LOTNUM       AS LOT_NUM,
                                       SKUKEY       AS MATNR,
                                       DESC01       AS MATNR_NM,
                                       LOTA14       AS IND_BCD,
                                       LOTA15       AS LOT_NO,
                                       LOTA01       AS STOR_LOC_CD,              --저장위치
                                       USEQTY       AS STCK_QTY,               --가용수량(재고량)
                                       UOMKEY           AS UNIT,
                                       CASE WHEN LOTA06 = ''00'' THEN ''투입가능''
                                            WHEN LOTA06 = ''05'' THEN ''품질재고 자재입니다.''
                                            WHEN LOTA06 = ''10'' THEN ''보류재고 자재입니다.''
                                            WHEN LOTA06 = ''30'' THEN ''불용재고 자재입니다.''
                                            WHEN LOTA06 = ''50'' THEN ''폐기재고 자재입니다.'' END AS STCK_STA
                                  FROM V_WMS_STKKY@KNRAWMSLINK' ;
                        V_SQL := V_SQL || ' WHERE LOTA02 = ''' || V_WERKS || '''';
                        V_SQL := V_SQL || ' AND LOTA14 = ''' || V_IND_BCD || '''';
                        V_SQL := V_SQL || ' AND USEQTY > 0';
                    END IF;
                ELSE
                    V_SEARCH_FL := 'Y';
                END IF;
            END IF;
        END IF;

        IF V_SEARCH_FL = 'Y' THEN
            V_SQL := 'SELECT 
                           --''        AS STCK_KEY,         --WMS 
                           --''          AS LOT_NUM,          --WMS
                           I001.MATNR,                     --자재코드
                           M001.MATNR_NM,                   --자재명
                           I001.IND_BCD,                    --개별바코드
                           I001.LOT_NO,                     --LOT NO
                           I001.STOR_LOC_CD,                --저장위치코드
                           I001.STCK_QTY,                    --재고수량
                           I001.UNIT,                       --단위
                           CASE WHEN I001.STCK_STA = ''00'' AND I001.STCK_QTY > 0 AND S000.MATNR = I001.MATNR THEN ''투입가능''
                                WHEN I001.STCK_STA = ''00'' AND NVL(S000.MATNR, '' '') <> I001.MATNR THEN ''투입가능한 하위자재가 아닙니다.''
                                WHEN I001.STCK_STA = ''10'' AND I001.STCK_QTY <= 0 THEN ''이미 투입된 자재입니다.''
                                WHEN I001.STCK_STA = ''10'' AND I001.STCK_QTY > 0 THEN ''투입가능''
                                WHEN I001.STCK_STA = ''20''  THEN ''생산중인 자재입니다.''
                                WHEN I001.STCK_STA = ''30''  THEN ''불용재고 자재입니다.''
                                WHEN I001.STCK_STA = ''40''  THEN ''부적합 자재입니다.''
                                WHEN I001.STCK_STA = ''50''  THEN ''폐기재고 자재입니다.'' 
								WHEN I001.STCK_QTY = 0 THEN ''재고가 없는 자재입니다.''	END AS STCK_STA
                      FROM TB_INV001 I001,
                           TB_MAS001 M001,
                           (SELECT S020.MATNR ';

            IF V_PROC_CD = 'AA' THEN                --화장지 합지기 공정
                V_SQL := V_SQL || ' FROM TB_SCH011 S00,';
            ELSIF V_PROC_CD = 'RA' THEN            --화장지 가공기 공정
                V_SQL := V_SQL || ' FROM TB_SCH012 S00,';
            ELSIF V_PROC_CD = 'RB' THEN            --생리대 가공기 공정
                V_SQL := V_SQL || ' FROM TB_SCH013 S00,';
            ELSIF V_PROC_CD = 'RC' THEN            --기저귀 가공기 공정
                V_SQL := V_SQL || ' FROM TB_SCH014 S00,';
            ELSIF V_PROC_CD = 'PG' OR V_PROC_CD = 'PH' OR V_PROC_CD = 'PF' OR V_PROC_CD = 'PI' OR V_PROC_CD = 'PE' THEN            --예외생산 공정
                V_SQL := V_SQL || ' FROM TB_SCH019 S00,';
            END IF;                       

            V_SQL := V_SQL || ' TB_SCH020 S020
                             WHERE S00.WRK_ORDR_NO = S020.WRK_ORDR_NO(+)
                               AND S00.WRK_ORDR_SEQNO = S020.WRK_ORDR_SEQNO(+) '; 

            V_SQL := V_SQL || ' AND S00.WRK_ORDR_NO = ''' || V_WRK_ORDR_NO || '''';                  
            V_SQL := V_SQL || ' AND S00.WRK_ORDR_SEQNO = ''' || V_WRK_ORDR_SEQNO || ''') S000';                  
            V_SQL := V_SQL || ' WHERE I001.WERKS = M001.WERKS(+)
                                  AND I001.MATNR = M001.MATNR(+)
                                  AND I001.MATNR = S000.MATNR(+)';
            V_SQL := V_SQL || ' AND I001.WERKS = ''' || V_WERKS|| '''';                  
            V_SQL := V_SQL || ' AND I001.IND_BCD = ''' || V_IND_BCD || '''';                  
            --V_SQL := V_SQL || ' AND I001.STCK_QTY > 0';
            V_SQL := V_SQL || ' AND M001.MATNR_STA IS NULL ';

        END IF;

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

    ELSIF P_TYPE = 'SUB_LIST1' THEN  /* 작업지시 조회(폼 LOAD 시, 작업지시 새로고침)*/
        V_SQL :='SELECT W011.WRK_ORDR_NO        --작업지시번호
                    , W011.WRK_ORDR_SEQNO       --작업지시번호 순번
                    , W011.ORDER_NO             --오더번호
                    , W011.MATNR                --자재코드
                    , M001.MATNR_NM                --자재명
                  FROM TB_WRK011 W011,
                       TB_MAS001 M001
                 WHERE W011.WERKS = M001.WERKS(+)
                   AND W011.MATNR = M001.MATNR(+)
                   AND W011.WRK_ORDR_NO IS NOT NULL ';

         IF  V_RANGE_SQL IS NOT NULL OR TRIM(V_RANGE_SQL) != '' THEN 
            V_SQL := V_SQL || V_RANGE_SQL;
        END IF;                     

        IF V_WERKS IS NOT NULL OR TRIM(V_WERKS) != '' THEN          -- 플랜트
            V_SQL := V_SQL || ' AND W011.WERKS = ''' || V_WERKS || '''';
        END IF;

        IF V_MACH_CD IS NOT NULL OR TRIM(V_MACH_CD) != '' THEN      -- 설비코드
            V_SQL := V_SQL || ' AND W011.MACH_CD = ''' || V_MACH_CD || '''';
        END IF;    

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

    ELSIF P_TYPE = 'SUB_LIST2' THEN  /* 작업지시 조회(팝업)*/

        V_SDATE     := V_JSON.get_string('SDATE');
        V_EDATE     := V_JSON.get_string('EDATE');

--        SELECT WRK_CD INTO V_WRK_CD
--          FROM TB_MAS012
--         WHERE MACH_CD = V_MACH_CD;

        V_SQL := 'SELECT S00.WRK_SEQNO         --작업순서
                    , S00.WRK_ORDR_NO           --작업지시번호
                    , S00.WRK_ORDR_SEQNO        --작업지시번호 순번 
                    , S00.ORDER_NO              --오더번호
                    , S00.MATNR                 --자재코드
                    , M001.MATNR_NM             --자재명
                    , S00.WRK_ORDR_QTY          --생산지시수량(계획수량)
                    , S00.UNIT';                --단위

        IF V_PROC_CD = 'AA' THEN                --화장지 합지기 공정
            V_SQL := V_SQL || ' FROM TB_SCH011 S00,';
        ELSIF V_PROC_CD = 'RA' THEN            --화장지 가공기 공정
            V_SQL := V_SQL || ' FROM TB_SCH012 S00,';
        ELSIF V_PROC_CD = 'RB' THEN            --생리대 가공기 공정
            V_SQL := V_SQL || ' FROM TB_SCH013 S00,';
        ELSIF V_PROC_CD = 'RC' THEN            --기저귀 가공기 공정
            V_SQL := V_SQL || ' FROM TB_SCH014 S00,';
        ELSIF V_PROC_CD = 'PG' OR V_PROC_CD = 'PH' OR V_PROC_CD = 'PF' OR V_PROC_CD = 'PI' OR V_PROC_CD = 'PE' THEN            --예외생산 공정
            V_SQL := V_SQL || ' FROM TB_SCH019 S00,';
        END IF;

        V_SQL := V_SQL || 'TB_MAS001 M001';            
        V_SQL := V_SQL || ' WHERE S00.WERKS = M001.WERKS(+)
                    AND S00.MATNR = M001.MATNR(+)
                    AND S00.MACH_CD = ''' || V_MACH_CD || '''';

        IF (V_SDATE IS NOT NULL OR TRIM(V_SDATE) != '') AND (V_EDATE IS NOT NULL OR TRIM(V_EDATE) !='') THEN                               
            V_SQL := V_SQL || ' AND S00.ORDR_GEN_DT BETWEEN ''' || V_SDATE || ''' AND ''' || V_EDATE || '''';
        END IF;

        V_SQL := V_SQL || ' AND NVL(S00.USE_YN,''N'') = ''Y'' ';

        IF V_PROC_CD = 'PG' OR V_PROC_CD = 'PH' OR V_PROC_CD = 'PF' OR V_PROC_CD = 'PI' OR V_PROC_CD = 'PE' THEN            --예외생산 공정
            V_SQL := V_SQL || ' ORDER BY S00.PRD_REQ_DT, S00.SEQ'; 
        ELSE
            V_SQL := V_SQL || ' ORDER BY S00.PRD_REQ_DT, S00.ORDER_SEQNO'; 
        END IF;
       -- INSERT INTO PROC_LOG(SQL_STR) VALUES (V_SQL);
        BEGIN           
     		OPEN P_RS_LIST FOR V_SQL;

--        EXCEPTION           
--        WHEN OTHERS THEN 
--            P_SUCCESS           := 'N';
--            E_SQL_ERR_CD        := SQLCODE;
--            E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';
--
--            SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
--            --RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);           
--            RETURN;           
        END;                                
    ELSIF P_TYPE = 'SUB_LIST3' THEN  /* 자재투입이력 조회(팝업)*/
        V_SQL :='SELECT I003.MATNR,         --자재코드
                     M001.MATNR_NM,         --자재명
                     I003.IND_BCD,          --업체/개별바코드
                     I003.IN_QTY,           --투입수량
                     I003.USE_QTY,          --사용수량
                     I003.STCK_QTY,         --재고수량
                     I003.UNIT              --단위    
                  FROM TB_INV003 I003,
                       TB_MAS001 M001
                 WHERE I003.WERKS = M001.WERKS(+)
                   AND I003.MATNR = M001.MATNR(+)';
        V_SQL := V_SQL || ' AND I003.WERKS = ''' || V_WERKS || '''
                            AND I003.MACH_CD = ''' || V_MACH_CD || '''
                            AND I003.STCK_QTY > 0';

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
    ELSIF P_TYPE = 'SUB_LIST4' THEN  /* BOM 정보 조회*/
        V_SQL :='SELECT DISTINCT
                        S020.MATNR,             --하위자재코드
                        M001.MATNR_NM,          --하위자재명
                        S020.ORDER_BOM_QTY,     --오더BOM 수량     
                        S020.UNIT,              --단위
                        DECODE(NVL(I003.WRK_ORDR_NO, ''N''), ''N'', ''N'', ''Y'') USE_YN
                   FROM TB_SCH020 S020, --생산오더 BOM
                        TB_MAS001 M001, --자재마스터
                        TB_INV003 I003  --자재투입
                  WHERE S020.WERKS = M001.WERKS(+)
                    AND S020.MATNR = M001.MATNR(+)
                    AND S020.WERKS = I003.WERKS(+)
                    AND S020.MATNR = I003.MATNR(+)
                    AND S020.WRK_ORDR_NO = I003.WRK_ORDR_NO(+)
                    AND S020.WRK_ORDR_NO = ''' || V_WRK_ORDR_NO || '''
                    AND S020.WRK_ORDR_SEQNO = ''' || V_WRK_ORDR_SEQNO || '''
                 ORDER BY S020.MATNR ';   
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
    ELSIF P_TYPE = 'SAVE' THEN      /* 자재투입*/
        V_MMATNR              :=       V_JSON.get_string('MMATNR');               -- BOM 하위자재코드
        V_INMATNR             :=       V_JSON.get_string('INMATNR');              -- 투입하위자재코드  
        V_CONTIN_FLG          :=       V_JSON.get_string('CONTIN_FLG');              -- 연속투입여부 

        V_CHG_BOM := 'N';

        IF NVL(V_MMATNR, ' ') <> ' '  THEN      --강제투입일 경우
            V_CHG_BOM := 'Y';

            INSERT INTO TB_SCH020( WERKS,
                                   WRK_ORDR_NO,
                                   WRK_ORDR_SEQNO,
                                   MATNR,
                                   ORDER_NO,
                                   ORDER_ITM_NO,
                                   ORDER_BOM_QTY,
                                   UNIT,
                                   STOR_LOC_CD,
                                   LOT_NO,
                                   CHGFL,
                                   EMPLY_NO,
                                   DLFL,
                                   REGDATE,
                                   REGID)

            SELECT WERKS,
                   WRK_ORDR_NO,
                   WRK_ORDR_SEQNO,
                   V_INMATNR,
                   ORDER_NO,
                   ORDER_ITM_NO,
                   ORDER_BOM_QTY,
                   UNIT,
                   STOR_LOC_CD,
                   LOT_NO,
                   V_CHG_BOM,
                   V_SESS_USER_ID,
                   DLFL,
                   V_DATE,
                   V_SESS_USER_ID
              FROM TB_SCH020
             WHERE WRK_ORDR_NO = V_WRK_ORDR_NO
               AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
               AND MATNR = V_MMATNR;
        END IF;

        BEGIN
            IF V_CONTIN_FLG = 'Y' THEN
                BEGIN
                    SELECT NVL(MAX(SEQNO),0) INTO V_SEQNO
                      FROM TB_INV003
                     WHERE WERKS = V_WERKS
                       AND MACH_CD = V_MACH_CD
                       AND MATNR = V_INMATNR;
                 EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                    V_SEQNO := 0;
                 END;
                V_SEQNO := V_SEQNO + 1;
            ELSE
                V_SEQNO := 1;
                OPEN PROD_CUR FOR
                    SELECT MATNR, IND_BCD, LOT_NO, STCK_QTY, UNIT, CHG_FLG, STCK_KY, LOT_NUM 
                        INTO V_MATNR, V_IND_BCD_M, V_LOT_NO, V_STCK_QTY, V_UNIT, V_CHG_FLG, V_STCK_KY, V_LOT_NUM
                      FROM TB_INV003
                     WHERE WERKS = V_WERKS
                       AND MACH_CD = V_MACH_CD
                       AND MATNR = V_INMATNR; 
                LOOP
                FETCH PROD_CUR INTO V_MATNR, V_IND_BCD_M, V_LOT_NO, V_STCK_QTY, V_UNIT, V_CHG_FLG, V_STCK_KY, V_LOT_NUM;
                EXIT WHEN PROD_CUR %NOTFOUND;   

                    INSERT INTO TB_INV010(WERKS, MACH_CD, MATNR, IND_BCD, SEQNO, WRK_ORDR_NO, WRK_ORDR_SEQNO,
                                    LOT_NO, IND_BCD_M, LOT_NO_M, MATNR_M,               
                                    INP_DT,PRFM_DT, USE_QTY, UNIT,
                                    WGT, CHG_FLG, STCK_KY, LOT_NUM, REGDATE, REGID, USE_DIV )

                            SELECT WERKS, MACH_CD, MATNR, IND_BCD, SEQNO + 1, WRK_ORDR_NO, WRK_ORDR_SEQNO,
                                    LOT_NO, V_IND_BCD_M, LOT_NO, V_MATNR,               
                                    INP_DT,PRFM_DT, V_STCK_QTY, V_UNIT,
                                    V_STCK_QTY, V_CHG_FLG, V_STCK_KY, V_LOT_NUM, V_DATE, V_SESS_USER_ID, '2'
                              FROM TB_INV010 
                             WHERE WERKS = V_WERKS
                              AND MACH_CD = V_MACH_CD
                              AND IND_BCD_M = V_IND_BCD_M
                              AND MATNR_M = V_MATNR
                              AND ROWNUM = 1
                           ORDER BY REGDATE DESC; 

                    DELETE
                      FROM TB_INV003
                     WHERE WERKS = V_WERKS
                      AND MACH_CD = V_MACH_CD
                      AND MATNR = V_MATNR
                      AND IND_BCD = V_IND_BCD_M;            
                END LOOP;
                 CLOSE PROD_CUR; 
            END IF;

            INSERT INTO TB_INV003( WERKS,
                                    MACH_CD,
                                    MATNR,
                                    IND_BCD,
                                    WRK_ORDR_NO,
                                    WRK_ORDR_SEQNO,
                                    SEQNO,
                                    LOT_NO,
                                    INP_DT,     -- 투입일자 추가 2022-06-03
                                    IN_QTY,
                                    USE_QTY,
                                    STCK_QTY,
                                    UNIT,
                                    CHG_FLG,
                                    STCK_KY,
                                    LOT_NUM,
                                    REGDATE,
                                    REGID)
            SELECT I001.WERKS,
                V_MACH_CD,
                I001.MATNR,
                V_IND_BCD,
                V_WRK_ORDR_NO,
                V_WRK_ORDR_SEQNO,
                V_SEQNO,
                LOT_NO,
                TO_CHAR(V_DATE, 'YYYYMMDD'),     -- 투입일자 추가 2022-06-03
                V_INPUT_QTY,
                0,
                V_INPUT_QTY,
                I001.UNIT,
                V_CHG_BOM,
                I001.STCK_KY,
                I001.LOT_NUM,
                V_DATE,
                V_SESS_USER_ID
              FROM TB_INV001 I001
             WHERE I001.WERKS = V_WERKS
               AND I001.IND_BCD = V_IND_BCD;

            --재고 수량 업데이트
            UPDATE TB_INV001 I001
               SET I001.STCK_QTY = CASE WHEN I001.STCK_QTY <=0 THEN 0 ELSE I001.STCK_QTY - V_INPUT_QTY END 
                 , I001.STCK_STA = '10'
                 , I001.UPDDATE = SYSDATE
                 , I001.UPDID = V_SESS_USER_ID
             WHERE I001.WERKS = V_WERKS
               AND I001.IND_BCD = V_IND_BCD; 
            
            IF V_WERKS = 'P100' THEN
                UPDATE TB_WRK002
                   SET STA = '10'
                 WHERE WERKS = V_WERKS
                   AND IND_BCD = V_IND_BCD;
            ELSE
                UPDATE TB_WRK001
                   SET STA = '10'
                 WHERE WERKS = V_WERKS
                   AND IND_BCD = V_IND_BCD;
            END IF;
            
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
    ELSIF P_TYPE = 'SUB_SAVE1' THEN  /* 자재투입취소*/
        V_ARR_LIST        := V_JSON.get_array('list');

        FOR i IN 0..V_ARR_LIST.get_size-1 LOOP
            V_OBJ           := TREAT (V_ARR_LIST.get (i) AS json_object_t);
            V_OBJ           := TREAT (V_OBJ.get ('map') AS json_object_t);

            V_MATNR         := V_OBJ.get_string('MATNR');
            V_IND_BCD       := V_OBJ.get_string('IND_BCD');
            V_STCK_QTY      := V_OBJ.get_string('STCK_QTY');

            UPDATE TB_INV001
               SET STCK_QTY = V_STCK_QTY
                , STCK_STA = '00'
                , UPDDATE = V_DATE
             WHERE WERKS = V_WERKS
               AND IND_BCD = V_IND_BCD
               AND MATNR = V_MATNR;

            DELETE
              FROM TB_INV003
             WHERE WERKS = V_WERKS
               AND MACH_CD = V_MACH_CD
               AND IND_BCD = V_IND_BCD
               AND MATNR = V_MATNR; 

        END LOOP;
    ELSIF P_TYPE = 'SUB_SAVE2' THEN  /* 자재불출요청*/    
        IF V_WERKS = 'P500' AND NVL(V_STCK_KY, ' ') <> ' ' THEN
            BEGIN
                SELECT LGPRO INTO V_STOR_LOC_CD
                  FROM TB_MAS001
                 WHERE WERKS = V_WERKS
                   AND MATNR = V_MATNR;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    V_STOR_LOC_CD := '';
            END;

            IF NVL(V_STOR_LOC_CD, ' ') = ' ' THEN
                P_RS_CODE := 'E';
                P_RS_MSG := V_MATNR || ' 자재의 저장위치 정보가 없습니다.';
                ROLLBACK;
                RETURN;
            END IF;

            V_DOC_NO := FN_GET_MDOCNO('M','IF203'); 
            V_DOC_SEQNO := 1;

            INSERT INTO TB_IFSWM003(DOC_NO, DOC_SEQNO, DLFL, WERKS, MATNR, QTY, UNIT,
                                    STOR_LOC, STCK_STA, NTN_CD, CRSPD_CD, PRDC_DT, RCVGDS_DT, DSTBT_DDLIN, IND_BCD, LOT_NO,
                                    STOK_KY, LOT_NUM, IF_STATUS, IF_GET_DATE, REQ_DTM, REQ_EXE_DT)
            SELECT V_DOC_NO, V_DOC_SEQNO, 'C', V_WERKS, SKUKEY, V_INPUT_QTY, V_UNIT,
                V_STOR_LOC_CD, '00', LOTA08, LOTA09, LOTA11, LOTA12, LOTA13, V_IND_BCD, LOTA15,
                V_STCK_KY, V_LOT_NUM, 'N', V_DATE, TO_CHAR(V_DATE, 'YYYYMMDDHH24MISS'), TO_CHAR(V_DATE, 'YYYYMMDD')
              FROM V_WMS_STKKY@KNRAWMSLINK
             WHERE STOKKY = V_STCK_KY
               AND LOTNUM = V_LOT_NUM;

            P_DOC_NO := V_DOC_NO;
            P_DOC_SEQNO := V_DOC_SEQNO;
        END IF;
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
        --RAISE;
END;

/
