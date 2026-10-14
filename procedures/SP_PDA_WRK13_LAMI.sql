
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_PDA_WRK13_LAMI" 
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
 * PROGRAM ID    : SP_PDA_WRK13_LAMI{호출 프로그램 ID 기술}
 * PROGRAM NAME  : PS PDA 재고이전 요청{호출 프로그램 명 기술}
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 라미네이팅 재고이전{프로그램에 대한 상세한 내용 기술}
 *                 
 * AUTHOR NAME   : 김지언 {최초 작성자 명 기술}
 * CREATE DATE   : 2025/01/22 {최초 작성일자 기술}
 * SYSTEM NAME   : PDA
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2025/01/22    1.0.0   김지언         Initial Version 
 *==============================================================================
 *  관련 테이블
 *       - [TB_INV017] : (.R..) 라미네이팅 품목 매칭 정보 ( 테이블명 임시 )
 *       - [TB_IFS009] : (.R..) 재고 이전
 *       - [TB_INV001] : (.R..) 재고 정보
    *=============================================================================*/
    --프로그램 ID
    V_PRG_NM          VARCHAR2(100)  := 'SP_PDA_WRK13_LAMI';     -- PROCEDURE NAME

    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5)           := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);

    -- JSON을 위한 변수선언 영역
    V_JSON           JSON_OBJECT_T;

    -- 세션값 처리용 변수선언 영역
    V_SQL            CLOB;
    V_RANGE_SQL      varchar2(4000);
    V_DEBUG          varchar2(1);

    -- 세션값 처리용 변수선언 영역
    V_PLT_CD         varchar2(2);
    V_SESS_USER_ID   varchar2(20);

    -- 조건절 처리용 변수선언 영역
    V_WERKS             TB_INV001.WERKS%TYPE;        --플랜트코드
    V_IND_BCD           TB_INV001.IND_BCD%TYPE;      --개별바코드
    V_MACH_CD           TB_INV001.MACH_CD%TYPE;      --개별바코드

    V_DOC_NO            TB_WRK015.DOC_NO%TYPE;          --MES 문서번호
    V_DOC_SEQNO         TB_WRK015.DOC_SEQNO%TYPE;       --MES 문서번호
    V_DOC_NO_1          TB_WRK015.DOC_NO%TYPE;          --MES 문서번호
    V_DOC_SEQNO_1       TB_WRK015.DOC_SEQNO%TYPE;       --MES 문서번호
    V_MATNR_FR          TB_WRK002.MATNR%TYPE; 
    V_STCK_QTY          TB_INV001.STCK_QTY%TYPE; 
    V_DATE              DATE := SYSDATE;
    

    V_SDOC_NO           TB_INV001.SDOC_NO%TYPE;
    V_SDOC_SEQNO        TB_INV001.SDOC_SEQNO%TYPE;
    
    V_BUDAT				VARCHAR2(10);

BEGIN
    OPEN P_RS_LIST FOR 
    SELECT NULL FROM DUAL WHERE ROWNUM = 0;    

--    V_JSON := JSON_OBJECT_T.parse('{"SES_WARENMKY":"","SES_PLNTKY":"P100","SES_USER_IP":"","WERKS":"P100","SES_PROC_CD":"LP","SES_MACH_CD":"PLP01","IND_BCD":"241006S002","SES_USER_GUBUN":"","commandKey":"PDA_INV00_LAMI","SES_USER_ID":"DEV","SES_USER_INFO_ID":"","SES_WAREKY":"CP","P_TYPE":"LIST","moduleKey":"Mobile","SES_USER_COMPANY":"KN","SES_SCHEMA":"kn","SES_USER_TYPE_ID":"","SES_LANGUAGE":"KR","SES_USER_EMPL_ID":""}');
    V_JSON := JSON_OBJECT_T.parse(P_JSON_STR);
    V_SESS_USER_ID      :=       V_JSON.get_string('SES_USER_ID');
    V_PLT_CD            :=       V_JSON.get_string('SES_WAREKY');

    /* 조건값 할당 */
    V_RANGE_SQL         :=       V_JSON.get_string('RANGE_SQL');                -- 작업지시 조회 시 일자

    V_MACH_CD           :=       V_JSON.get_string('SES_MACH_CD');              -- 설비코드
    V_WERKS             :=       V_JSON.get_string('WERKS');                    -- 플랜트코드
    V_IND_BCD           :=       V_JSON.get_string('IND_BCD');                  -- 개별바코드  
    V_MATNR_FR          :=       V_JSON.get_string('MATNR_FROM');               -- 자재코드
    V_BUDAT             :=       V_JSON.get_string('INP_DT');   	            -- 전기일

    IF P_TYPE = 'LIST' THEN -- 바코드스캔시 해당 품목 및 매칭 품목 조회(테스트 필요)
        V_SQL :='SELECT FN_CD_VAL(''STCK_STA'', I001.STCK_STA) || '' ('' || I001.STOR_LOC_CD || '')'' PRD_STA,  --실적상태
                           I001.IND_BCD,                                                                        --바코드
                           M001_FROM.MATNR      AS MATNR_FROM,                                                  --변경전 자재코드
                           M001_FROM.MATNR_NM   AS MATNR_NM_FROM,                                               --변경전 자재명
                           M001_FROM.PCODE_NM,                                                                  --지종
                           M001_FROM.BS_WGT,                                                                    --평량
                           SUBSTR(I001.MATNR, 10, 4) || '' * '' || SUBSTR(I001.MATNR, 14, 4) MATNR_SPEC,        --규격
                           TO_CHAR(I001.STCK_QTY, ''FM999,999,990'') || '' KG''  AS WGT,                             --중량
                           M001_TO.MATNR        AS MATNR_TO,                                                    --변경전 자재코드
                           M001_TO.MATNR_NM     AS MATNR_NM_TO                                                  --변경전 자재명
                           , STCK_QTY                                                                           --재고수량
                FROM TB_INV001 I001
                    LEFT OUTER JOIN TB_MAS033 M033 ON I001.WERKS = M033.WERKS_FROM AND I001.MATNR = M033.MATNR_FROM
                    LEFT OUTER JOIN TB_MAS001 M001_FROM ON M033.WERKS_FROM = M001_FROM.WERKS AND M033.MATNR_FROM = M001_FROM.MATNR
                    LEFT OUTER JOIN TB_MAS001 M001_TO ON M033.WERKS_TO = M001_TO.WERKS AND M033.MATNR_TO = M001_TO.MATNR
                    WHERE 1=1 
                       AND I001.IND_BCD = ''' || V_IND_BCD || '''
                       AND I001.WERKS = ''' || V_WERKS || ''' ';
        
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
    ELSIF P_TYPE = 'SAVE1' THEN       --변경요청(1. TB_IFS009 INSERT)
        BEGIN        
            --변경요청 I/F
            V_DOC_NO_1 := FN_GET_MDOCNO('M','IF131');
            V_DOC_SEQNO_1 := 1;
           
--            V_BUDAT := FN_RECDATE(V_DATE);

            INSERT INTO TB_IFS009(BWART, WERKS_FROM, WERKS_TO, MATNR_FROM, MATNR_TO, LGORT_FROM, LGORT_TO,
                                CHARG_FROM, CHARG_TO, AUFNR, MENGE, MEINS, FAULTY, MDOCNO, MDOCSEQ, ZRESULT,
                                MAKE_DATE, MAKER, BUDAT)
                        SELECT '309', -- 재고이전
                               M033.WERKS_FROM,
                               M033.WERKS_TO,
                               M033.MATNR_FROM,
                               M033.MATNR_TO,
                               M033.LGORT_FROM,
                               M033.LGORT_TO,
                               I001.LOT_NO,
                               I001.LOT_NO,
                               I001.ORDER_NO,
                               I001.STCK_QTY,
                               I001.UNIT,
                               NULL, --부적합 지시자
                               V_DOC_NO_1,
                               V_DOC_SEQNO_1, --MDOCSEQ
                               'N', --ZRESULT
                               SYSDATE,
                               'MES',
                               replace(V_BUDAT, '-', '')
                        FROM TB_INV001 I001
                            LEFT OUTER JOIN TB_MAS033 M033 ON WERKS_FROM = I001.WERKS AND M033.MATNR_FROM = I001.MATNR
                        WHERE WERKS = V_WERKS
                            AND IND_BCD = V_IND_BCD;
                            

            
            -- 변경요청 취소를 위한 정보(TB_WRK024) INSERT --SAP 전송 전 INV001 데이터 넣어주기
            INSERT INTO TB_WRK024(SEQ_WRK024, BUDAT, IND_BCD, WERKS_FROM, WERKS_TO, MATNR_FROM, MATNR_TO, LGORT_FROM, LGORT_TO,
                                    CHARG, MENGE, MEINS, REGID, REGDATE)
                        SELECT SEQ_WRK024.nextval, 
                               replace(V_BUDAT, '-', ''),
                               V_IND_BCD,
                               M033.WERKS_FROM,
                               M033.WERKS_TO,
                               M033.MATNR_FROM,
                               M033.MATNR_TO,
                               M033.LGORT_FROM,
                               M033.LGORT_TO,
                               I001.LOT_NO,
                               I001.STCK_QTY,
                               I001.UNIT,
                               V_SESS_USER_ID,
                               SYSDATE
                        FROM TB_INV001 I001
                            LEFT OUTER JOIN TB_MAS033 M033 ON WERKS_FROM = I001.WERKS AND M033.MATNR_FROM = I001.MATNR
                        WHERE WERKS = V_WERKS
                            AND IND_BCD = V_IND_BCD;

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
    ELSIF P_TYPE = 'SAVE2' THEN       --MES 재고 반영 (3. TB_INV001 UPDATE)
        -- 재고업데이트 
        -- 저장위치 변경 2810 -> 2999"
        -- STCK_QTY Update : 0
        UPDATE TB_INV001
        SET STCK_QTY    = 0,
            UPDDATE     = V_DATE,
            UPDID       = V_SESS_USER_ID
        WHERE WERKS = V_WERKS
            AND IND_BCD = V_IND_BCD;
            
        -- 변경요청 취소를 위한 정보(TB_WRK024) INSERT --SAP 전송 후 INV001 데이터 넣어주기
        SELECT A.MBLNR, A.MJAHR INTO V_SDOC_NO, V_SDOC_SEQNO
        FROM (
            SELECT ROW_NUMBER() OVER (ORDER BY IFS009.MAKE_DATE DESC) AS ROW_NUM
                , MBLNR
                , MJAHR
            from TB_IFS009 IFS009
            where WERKS_FROM = V_WERKS
                AND MATNR_FROM = V_MATNR_FR
              )A
        WHERE 1=1
        AND ROW_NUM = 1;

        UPDATE TB_WRK024 SET 
            SDOC_NO     = V_SDOC_NO,
            SDOC_SEQNO  = V_SDOC_SEQNO
        WHERE WERKS_FROM = V_WERKS
            AND IND_BCD = V_IND_BCD
            AND CNL_YN = 'N';
            
        
    ELSIF P_TYPE = 'DELETE1' THEN       --재고이전 취소(SAP 재고이전 취소) (1. TB_IFS009 INSERT) 
        BEGIN
            --재고이전 취소
            V_DOC_NO_1 := FN_GET_MDOCNO('M','IF131');
            V_DOC_SEQNO_1 := 1;
            
            --TB_IFS009 TABLE INSERT 변경요청취소
            --TB_IFS010 재고이전 취소 TABLE --변경요청한걸 '취소'(되돌림) 하는 것이기 때문에 FROM-TO 가 아니라 TO_FROM 으로 값을 넣어줌 헷갈리지않기!
            INSERT INTO TB_IFS009(BWART, WERKS_FROM, WERKS_TO, MATNR_FROM, MATNR_TO, LGORT_FROM, LGORT_TO,
                                CHARG_FROM, CHARG_TO, AUFNR, MENGE, MEINS, FAULTY, MDOCNO, MDOCSEQ, ZRESULT,
                                MAKE_DATE, MAKER, BUDAT)
                        SELECT '309', -- 재고이전
                               M033.WERKS_TO,
                               M033.WERKS_FROM,
                               M033.MATNR_TO,
                               M033.MATNR_FROM,
                               M033.LGORT_TO,
                               M033.LGORT_FROM,
                               I001.LOT_NO,
                               I001.LOT_NO,
                               I001.ORDER_NO,
                               W024.MENGE,
                               W024.MEINS,
                               NULL, --부적합 지시자
                               V_DOC_NO_1,
                               V_DOC_SEQNO_1, --MDOCSEQ
                               'N', --ZRESULT
                               SYSDATE,
                               'MES',
                               TO_CHAR(SYSDATE, 'yyyyMMdd')
                        FROM TB_INV001 I001
                            LEFT OUTER JOIN TB_MAS033 M033 ON WERKS_FROM = I001.WERKS AND M033.MATNR_FROM = I001.MATNR
                            LEFT OUTER JOIN TB_WRK024 W024 on I001.IND_BCD = W024.IND_BCD AND CNL_YN = 'N'
                        WHERE WERKS = V_WERKS
                            AND I001.IND_BCD = V_IND_BCD;
                                    
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
    ELSIF P_TYPE = 'DELETE2' THEN       --MES 재고 반영 취소 (1. TB_INV001 Update / TB_WRK021 UPDATE)
        -- 재고업데이트 
        -- 저장위치 변경 2999 -> 2810
        -- STCK_QTY Update : 실적중량 (TB_WRK024에 저장된 중량으로 다시 되살려주기)

--        SZP_MES_PLSQL_LOG(V_IND_BCD, 'V_IND_BCD DELETE2 V_SQL');
        
        -- 실적량 조회
        SELECT MENGE INTO V_STCK_QTY
        FROM TB_WRK024
        WHERE  IND_BCD = V_IND_BCD
            AND CNL_YN = 'N';
        
--        SZP_MES_PLSQL_LOG(V_STCK_QTY, 'V_STCK_QTY DELETE2 V_SQL');
--        SZP_MES_PLSQL_LOG(V_WERKS, 'V_WERKS DELETE2 V_SQL');
        
        UPDATE TB_INV001
        SET STCK_QTY    = V_STCK_QTY,
            UPDDATE     = V_DATE,
            UPDID       = V_SESS_USER_ID
        WHERE WERKS = V_WERKS
            AND IND_BCD = V_IND_BCD;
        
        UPDATE TB_WRK024 SET 
            CNL_YN     = 'Y',
            UPDDATE     = V_DATE,
            UPDID       = V_SESS_USER_ID
        WHERE WERKS_FROM = V_WERKS
            AND IND_BCD = V_IND_BCD
            AND CNL_YN = 'N';
            
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
