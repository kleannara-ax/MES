--------------------------------------------------------
--  DDL for Procedure SP_PDA_WRK02_S01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_PDA_WRK02_S01" 
(
    P_TYPE           IN    varchar2, -- LIST, SUB_LIST, SUB_SAVE
	P_JSON_STR       IN    CLOB,
	P_SUCCESS       OUT    varchar2,
    P_ERR_MSG       OUT    varchar2,        
	P_RS_LIST       OUT    SYS_REFCURSOR
)
AS 
/*==============================================================================
 * PROGRAM ID    : PDA_WRK01{호출 프로그램 ID 기술}
 * PROGRAM NAME  : PDA 공정투입{호출 프로그램 명 기술}
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
    V_WERKS             TB_WRK011.WERKS%TYPE;        -- 플랜트코드
    V_MATNR             TB_WRK011.MATNR%TYPE;        -- 자재코드
    V_MACH_CD           TB_WRK011.MACH_CD%TYPE;      -- 설비코드
    V_IND_BCD           TB_INV001.IND_BCD%TYPE;      -- 업체/개별바코드
    V_STOR_LOC_CD       TB_INV001.STOR_LOC_CD%TYPE;      -- 저장위치
    V_LOC_CD            TB_INV001.LOC_CD%TYPE;      -- 로케이션
    V_PROC_CD           TB_MAS012.PROC_CD%TYPE;      -- 공정코드
    V_MACH_NM           TB_MAS012.MACH_NM%TYPE;     --설비명
    V_WRK_ORDR_NO       TB_WRK011.WRK_ORDR_NO%TYPE;  -- 작업지시번호
    V_WRK_ORDR_SEQNO    TB_WRK011.WRK_ORDR_SEQNO%TYPE;  -- 작업지시번호 순번
    V_ORDER_NO          TB_WRK011.ORDER_NO%TYPE; 
    V_STCK_QTY          TB_INV001.STCK_QTY%TYPE;
    V_PRE_IN_QTY        TB_INV003.PRE_IN_QTY%TYPE;
    V_MACH_CD_PRE       TB_INV003.MACH_CD%TYPE;

    V_DATE              DATE := SYSDATE;
    V_WCS_WRK_CD        VARCHAR2(10);
    V_LOT_NO            VARCHAR2(10);
    V_DOC_NO            VARCHAR2(20);
    V_DOC_SEQNO         NUMBER;
    --V_MAKTX            TB_MAS001.MAKTX%TYPE; -- 자재명
    V_CHK_PERF             VARCHAR2(1) ;  --실적체크
    V_COMP_YN           VARCHAR2(1);        --완료여부

    V_CNT              VARCHAR2(1);
    V_COUNT             NUMBER;
BEGIN
    OPEN P_RS_LIST FOR 
    SELECT NULL FROM DUAL WHERE ROWNUM = 0;    

    V_JSON := JSON_OBJECT_T.parse(P_JSON_STR);
    V_SESS_USER_ID      :=       V_JSON.get_string('SES_USER_ID');
    V_PLT_CD            :=       V_JSON.get_string('SES_WAREKY');

    /* 조건값 할당 */
    V_RANGE_SQL         :=      V_JSON.get_string('RANGE_SQL');                 

    V_WERKS             :=      V_JSON.get_string('WERKS');         -- 플랜트
    V_MACH_CD           :=      V_JSON.get_string('MACH_CD');       -- 설비코드
    V_IND_BCD           :=      V_JSON.get_string('IND_BCD');       -- 개별바코드
    V_PROC_CD           :=      V_JSON.get_string('PROC_CD');       -- 공정
    V_MATNR             :=      V_JSON.get_string('MATNR');         -- 자재코드

--    SELECT PROC_CD INTO V_PROC_CD
--      FROM TB_MAS012
--     WHERE MACH_CD = V_MACH_CD;

    V_STOR_LOC_CD := '2000';
    IF V_PROC_CD = 'MA' THEN                            --밀롤 공정
        V_LOC_CD := 'L2100';
    ELSIF V_PROC_CD = 'SA' THEN                         --슬리터 공정
        V_LOC_CD := 'L2200';
    ELSIF V_PROC_CD = 'CA' THEN                         --재단 공정
        V_STOR_LOC_CD := '2700';
    ELSIF V_PROC_CD = 'CB' THEN                         --수재단 공정
        V_LOC_CD := 'L2400';   
    ELSIF V_PROC_CD = 'PB' OR V_PROC_CD = 'PC' THEN     --포장 공정
        V_LOC_CD := 'L2600';    
    END IF;

    --V_STOR_LOC_CD := '2000';

    IF P_TYPE = 'LIST' THEN /*업체/개별바코드 조회 리스트*/
        IF V_PROC_CD = 'MA' THEN                            -- 밀롤 공정
            V_SQL := 'SELECT DISTINCT 
                            I001.IND_BCD,                      --점보롤 바코드
                            I001.LOT_NO,                        --점보롤 LOT NO
                            I001.WRK_ORDR_NO,                   --작업지시 번호
                            I001.WRK_ORDR_SEQNO,                --작업지시 순번
                            I001.ORDER_NO,                      --오더번호
                            I001.MATNR,                         --자재(제품)코드
                            I001.PRD_DT,                        --생산일자
                            U001.NMLAST,                        --작업자
                            CASE WHEN I001.ROLLCNT = 0 THEN TO_CHAR(I003.ROLLCNT, ''FM999,999,999,990.09'') ELSE TO_CHAR(I001.ROLLCNT, ''FM999,999,999,990.09'') END ROLLCNT,  --권치수
                            CASE WHEN I001.STCK_QTY = 0 THEN TO_CHAR(I003.STCK_QTY, ''FM999,999,999,990.09'') ELSE TO_CHAR(I001.STCK_QTY, ''FM999,999,999,990.09'') END STCK_QTY,  --중량 
                            W002.MACHINE,                       --생산호기 
                            W002.TO_MACHINE,                    --투입호기
                            CASE WHEN I001.STCK_STA = ''00'' AND NVL(I001.STCK_QTY, 0) > 0 AND NVL(S015.COMP_YN, ''N'') != ''N'' AND NVL(S015.COMP_YN, ''N'') != ''I'' THEN ''투입가능''
                                WHEN I001.STCK_STA = ''00'' AND NVL(I001.STCK_QTY, 0) <= 0 THEN ''투입불가(재고부족)''
                                WHEN I001.STCK_STA = ''10'' THEN ''투입중''
                                WHEN I001.STCK_STA = ''40'' THEN ''투입불가(보류재고)''
                                ELSE ''투입불가'' END STCK_STA   --재고상태
                          FROM TB_INV001 I001,
                               TB_SCH015 S015,
                                TB_WRK002 W002,
                                TB_INV003 I003,
                                USRMA U001
                         WHERE I001.WERKS = W002.WERKS(+)
                           AND I001.IND_BCD = W002.IND_BCD(+)
                           AND I001.WRK_ORDR_NO = S015.WRK_ORDR_NO(+)
                           AND I001.WRK_ORDR_SEQNO = S015.WRK_ORDR_SEQNO(+)
                           AND I001.WERKS = I003.WERKS(+)
                           AND I001.MACH_CD = I003.MACH_CD(+)
                           AND I001.IND_BCD = I003.IND_BCD(+)
                           AND W002.REGID = U001.USERID(+)
                           AND I001.WERKS = ''' || V_WERKS || '''
                           AND I001.STOR_LOC_CD = ''' || V_STOR_LOC_CD || '''
                           AND I001.LOC_CD = ''' || V_LOC_CD || '''
                           AND I001.IND_BCD = ''' || V_IND_BCD || ''' ';
        ELSIF V_PROC_CD = 'SA' THEN                         --슬리터 공정
            --정규
            V_SQL := 'SELECT DISTINCT 
                            ''정규''      FLAG,
                            I001.IND_BCD,                      --상위밀롤 바코드
                            I001.LOT_NO,                        --상위밀롤 LOT NO
                            I001.WRK_ORDR_NO,                   --작업지시 번호
                            I001.WRK_ORDR_SEQNO,                --작업지시 순번
                            I001.ORDER_NO,                      --오더번호
                            I001.MATNR,                         --자재(제품)코드
                            M001.PCODE_NM,                      --지종명
                            S016.BS_WGT,                        --평량    
                            I001.PRD_DT,                        --생산일자
                            U001.NMLAST,                        --작업자
                            CASE WHEN I001.ROLLCNT = 0 THEN TO_CHAR(I003.ROLLCNT, ''FM999,999,999,990.09'') ELSE TO_CHAR(I001.ROLLCNT, ''FM999,999,999,990.09'') END ROLLCNT,  --권치수
                            W002.CORE,                          --지관
                            CASE WHEN I001.STCK_QTY = 0 THEN TO_CHAR(I003.STCK_QTY, ''FM999,999,999,990.09'') ELSE TO_CHAR(I001.STCK_QTY, ''FM999,999,999,990.09'') END STCK_QTY,  --중량 
                            SUBSTR(I001.MATNR, 10, 4) || '' * '' || SUBSTR(I001.MATNR, 14, 4) MATNR_SPEC,                    --규격
                            M009.CUST_NM,                       --거래처
                            CASE WHEN I001.STCK_STA = ''00'' AND NVL(I001.STCK_QTY, 0) > 0 AND NVL(S016.COMP_YN, ''N'') != ''N'' AND NVL(S016.COMP_YN, ''N'') != ''I'' THEN ''투입가능''
                                WHEN I001.STCK_STA = ''00'' AND NVL(I001.STCK_QTY, 0) <= 0 THEN ''투입불가(재고부족)''
                                WHEN I001.STCK_STA = ''10'' THEN ''투입중''
                                WHEN I001.STCK_STA = ''40'' THEN ''투입불가(보류재고)''
                                ELSE ''투입불가'' END STCK_STA   --재고상태
                          FROM TB_INV001 I001,
                                TB_WRK002 W002,
                                TB_SCH016 S016,
                                TB_INV003 I003,
                                TB_MAS009 M009,
                                TB_MAS001 M001,
                                USRMA U001
                         WHERE I001.WERKS = W002.WERKS(+)
                           AND I001.IND_BCD = W002.IND_BCD(+)
                           --AND I001.ORDER_NO = S016.ORDER_NO(+)
                           AND I001.WRK_ORDR_NO = S016.WRK_ORDR_NO(+)
                           AND I001.WRK_ORDR_SEQNO = S016.WRK_ORDR_SEQNO(+)
                           AND I001.MACH_CD = I003.MACH_CD(+)
                           AND I001.IND_BCD = I003.IND_BCD(+)
                           AND I001.WERKS = M001.WERKS(+)
                           AND I001.MATNR = M001.MATNR(+)
                           AND W002.REGID = U001.USERID(+)
                           AND S016.KUNNR = M009.KUNNR(+)
                           AND I001.WERKS = ''' || V_WERKS || '''
                           AND I001.STOR_LOC_CD = ''' || V_STOR_LOC_CD || '''
                           AND I001.LOC_CD = ''' || V_LOC_CD || '''
                           AND I001.IND_BCD = ''' || V_IND_BCD || '''
                           AND I001.STCK_KY IS NULL
        --예외                   
                UNION ALL
                    SELECT DISTINCT 
                            ''예외''      FLAG,
                            I001.IND_BCD,                      --밀롤 바코드(포장 바코드)
                            I001.LOT_NO,                        --포장 LOT NO
                            I001.WRK_ORDR_NO,                   --작업지시 번호
                            I001.WRK_ORDR_SEQNO,                --작업지시 순번
                            I001.ORDER_NO,                      --오더번호
                            I001.MATNR,                         --자재(제품)코드
                            M001.PCODE_NM,                      --지종명
                            S019.BS_WGT,                        --평량
							I001.PRD_DT,                        --생산일자
							U001.NMLAST,                        --작업자
                            CASE WHEN I001.ROLLCNT = 0 THEN TO_CHAR(I003.ROLLCNT, ''FM999,999,999,990.09'') ELSE TO_CHAR(I001.ROLLCNT, ''FM999,999,999,990.09'') END ROLLCNT,  --권치수
							--TO_CHAR(S019.IN_PER_CNT) || '' / '' || CASE WHEN NVL(S019.IN_PER_CNT, 0) = 0 THEN 0 ELSE (NVL(S019.PLT_PER_CNT, 0) * 500) / S019.IN_PER_CNT END S_MCNT,    --속/매
							NULL,                          --지관
                            CASE WHEN I001.WGT = 0 THEN TO_CHAR(I003.WGT, ''FM999,999,999,990.099'') ELSE TO_CHAR(I001.WGT, ''FM999,999,999,990.099'') END WGT,  --중량
                            --DECODE(S019.PACKTYPE, ''A'', ''자동'', ''B'', ''수축'')     PACKTYPE,                      --포장타입
							SUBSTR(I001.MATNR, 10, 4) || '' * '' || SUBSTR(I001.MATNR, 14, 4) MATNR_SPEC,                    --규격        
                            M009.CUST_NM,                       --거래처   
                            CASE WHEN I001.STCK_STA = ''00'' AND NVL(I001.STCK_QTY, 0) > 0 AND NVL(S019.COMP_YN, ''N'') != ''Y'' THEN ''투입가능''
                                WHEN I001.STCK_STA = ''00'' AND NVL(I001.STCK_QTY, 0) <= 0 THEN ''투입불가(재고부족)''
                                WHEN I001.STCK_STA = ''10'' THEN ''투입중'' || '' ('' || M012.MACH_NM || '')''
                                WHEN I001.STCK_STA = ''40'' THEN ''투입불가(보류재고)''
                                WHEN I001.STCK_STA = ''70'' THEN ''투입불가(출고)''
                                WHEN I001.STCK_STA = ''80'' THEN ''투입불가(출고요청)''
                                ELSE ''투입불가'' END STCK_STA   --재고상태   
                          FROM TB_INV001 I001,
                                TB_SCH019 S019,
                                TB_SCH020 S020,
                                TB_MAS001 M001,
                                TB_MAS009 M009,
                                TB_INV003 I003,
                                TB_MAS012 M012,
                                USRMA U001
                         WHERE S019.WRK_ORDR_NO = S020.WRK_ORDR_NO(+)
                           AND S019.WRK_ORDR_SEQNO = S020.WRK_ORDR_SEQNO(+)
                           AND S019.ORDER_DIV = ''ZP14''
                           --AND S020.LOT_NO = I001.LOT_NO(+)
						   AND S019.ORDER_NO = I001.ORDER_NO(+)
                           AND I001.WERKS = M001.WERKS(+)
                           AND I001.MATNR = M001.MATNR(+)
                           AND I001.IND_BCD = I003.IND_BCD(+)
                           AND I003.MACH_CD = M012.MACH_CD(+)
                           AND I001.REGID = U001.USERID(+)
                           AND S019.KUNNR = M009.KUNNR(+)
                           AND I001.WERKS = ''' || V_WERKS || '''
                           AND I001.STOR_LOC_CD = ''' || V_STOR_LOC_CD || '''
                           AND I001.LOC_CD = ''' || V_LOC_CD || '''
                           AND I001.IND_BCD = ''' || V_IND_BCD || '''
                           AND I001.STCK_KY IS NOT NULL
						   AND S019.COMP_YN = ''N'' ';

        ELSIF V_PROC_CD = 'CA' THEN                         --재단 공정
            V_STOR_LOC_CD := '2700';
            V_SQL := 'SELECT DISTINCT 
                            I001.IND_BCD,                      --밀롤 바코드
                            I001.LOT_NO,                        --밀롤 LOT NO
                            I001.WRK_ORDR_NO,                   --작업지시 번호
                            I001.WRK_ORDR_SEQNO,                --작업지시 순번
                            I001.ORDER_NO,                      --오더번호
                            I001.MATNR,                         --자재(제품)코드
                            S016.PCODE,                         --지종
                            S016.BS_WGT,                        --평량    
                            I001.PRD_DT,                        --생산일자
                            U001.NMLAST,                        --작업자
                            CASE WHEN I001.ROLLCNT = 0 THEN TO_CHAR(I003.ROLLCNT, ''FM999,999,999,990.09'') ELSE TO_CHAR(I001.ROLLCNT, ''FM999,999,999,990.09'') END ROLLCNT,  --권치수
                            W002.CORE,                          --지관
                            CASE WHEN I001.STCK_QTY = 0 THEN TO_CHAR(I003.STCK_QTY, ''FM999,999,999,990.09'') ELSE TO_CHAR(I001.STCK_QTY, ''FM999,999,999,990.09'') END STCK_QTY,  --중량 
                            SUBSTR(I001.MATNR, 10, 4) || '' * '' || SUBSTR(I001.MATNR, 14, 4) MATNR_SPEC,                    --규격
                            M009.CUST_NM,                       --거래처
                            CASE WHEN I001.STCK_STA = ''00'' AND NVL(I001.STCK_QTY, 0) > 0 AND NVL(S016.COMP_YN, ''N'') != ''N'' AND NVL(S016.COMP_YN, ''N'') != ''I'' THEN ''투입가능''
                                WHEN I001.STCK_STA = ''00'' AND NVL(I001.STCK_QTY, 0) <= 0 THEN ''투입불가(재고부족)''
                                WHEN I001.STCK_STA = ''10'' THEN ''투입중''
                                WHEN I001.STCK_STA = ''40'' THEN ''투입불가(보류재고)''
                                ELSE ''투입불가'' END STCK_STA   --재고상태
                          FROM TB_INV001 I001,
                                TB_WRK002 W002,
                                TB_SCH016 S016,
                                TB_INV003 I003,
                                TB_MAS009 M009,
                                USRMA U001
                         WHERE I001.WERKS = W002.WERKS(+)
                           AND I001.IND_BCD = W002.IND_BCD(+)
                           AND I001.ORDER_NO = S016.ORDER_NO(+)
                           AND I001.WRK_ORDR_NO = S016.WRK_ORDR_NO(+)
                           AND I001.WRK_ORDR_SEQNO = S016.WRK_ORDR_SEQNO(+)
                           AND I001.MACH_CD = I003.MACH_CD(+)
                           AND I001.IND_BCD = I003.IND_BCD(+)
                           AND W002.REGID = U001.USERID(+)
                           AND S016.KUNNR = M009.KUNNR(+)
                           AND I001.WERKS = ''' || V_WERKS || '''
                           AND I001.STOR_LOC_CD = ''' || V_STOR_LOC_CD || '''
                           AND I001.IND_BCD = ''' || V_IND_BCD || ''' ';

        ELSIF V_PROC_CD = 'CB' THEN                         --수재단 공정
            --정규
            V_SQL := 'SELECT DISTINCT 
                            ''정규''      FLAG,
                            I001.IND_BCD,                      --재단 바코드(T 바코드)
                            I001.LOT_NO,                        --재단 LOT NO
                            I001.WRK_ORDR_NO,                   --작업지시 번호
                            I001.WRK_ORDR_SEQNO,                --작업지시 순번
                            I001.ORDER_NO,                      --오더번호
                            I001.MATNR,                         --자재(제품)코드
                            I001.PRD_DT,                        --생산일자
                            U001.NMLAST,                        --작업자
                            M001.PCODE_NM,                      --지종명
                            S017.BS_WGT,                        --평량
                            SUBSTR(I001.MATNR, 10, 4) || '' * '' || SUBSTR(I001.MATNR, 14, 4) MATNR_SPEC,                    --규격
                            W002.PCNT                   STCK_QTY,  --연수 
                            CASE WHEN I001.WGT = 0 THEN TO_CHAR(I003.WGT, ''FM999,999,999,990.099'') ELSE TO_CHAR(I001.WGT, ''FM999,999,999,990.099'') END WGT,  --중량
                            DECODE(S017.PACKTYPE, ''A'', ''자동'', ''B'', ''수축'')     PACKTYPE,                      --포장타입        
                            M009.CUST_NM,                       --거래처   
                            CASE WHEN I001.STCK_STA = ''00'' AND NVL(I001.STCK_QTY, 0) > 0 AND NVL(S017.COMP_YN, ''N'') != ''N'' AND NVL(S017.COMP_YN, ''N'') != ''I'' THEN ''투입가능''
                                WHEN I001.STCK_STA = ''00'' AND NVL(I001.STCK_QTY, 0) <= 0 THEN ''투입불가(재고부족)''
                                WHEN I001.STCK_STA = ''10'' THEN ''투입중'' || '' ('' || M012.MACH_NM || '')''
                                WHEN I001.STCK_STA = ''40'' THEN ''투입불가(보류재고)''
                                ELSE ''투입불가'' END STCK_STA   --재고상태
                          FROM TB_INV001 I001,
                                TB_WRK002 W002,
                                TB_SCH017 S017,
                                TB_MAS001 M001,
                                TB_MAS009 M009,
                                TB_INV003 I003,
                                TB_MAS012 M012,
                                USRMA U001
                         WHERE I001.WERKS = W002.WERKS(+)
                           AND I001.IND_BCD = W002.IND_BCD(+)
                           --AND I001.ORDER_NO = S017.ORDER_NO(+)
                           AND I001.WRK_ORDR_NO = S017.WRK_ORDR_NO(+)
                           AND I001.WRK_ORDR_SEQNO = S017.WRK_ORDR_SEQNO(+)
                           AND I001.WERKS = M001.WERKS(+)
                           AND I001.MATNR = M001.MATNR(+)
                           --AND I001.MACH_CD = I003.MACH_CD(+)
                           AND I001.IND_BCD = I003.IND_BCD(+)
                           AND I003.MACH_CD = M012.MACH_CD(+)
                           AND W002.REGID = U001.USERID(+)
                           AND S017.KUNNR = M009.KUNNR(+)
                           AND I001.WERKS = ''' || V_WERKS || '''
                           AND I001.STOR_LOC_CD = ''' || V_STOR_LOC_CD || '''
                           --AND I001.LOC_CD = ''' || V_LOC_CD || '''
                           AND I001.IND_BCD = ''' || V_IND_BCD || '''
                           AND I001.STCK_KY IS NULL
                    --예외                   
                    UNION ALL
                        SELECT DISTINCT 
                                ''예외''      FLAG,
                                I001.IND_BCD,                      --재단 바코드(포장 바코드)
                                I001.LOT_NO,                        --포장 LOT NO
                                I001.WRK_ORDR_NO,                   --작업지시 번호
                            	I001.WRK_ORDR_SEQNO,                --작업지시 순번
                            	I001.ORDER_NO,                      --오더번호
                                I001.MATNR,                         --자재(제품)코드
                                I001.PRD_DT,                        --생산일자
                                U001.NMLAST,                        --작업자
                                M001.PCODE_NM,                      --지종명
                                S019.BS_WGT,                        --평량
                                SUBSTR(I001.MATNR, 10, 4) || '' * '' || SUBSTR(I001.MATNR, 14, 4) MATNR_SPEC,                    --규격
                                I001.STCK_QTY,                      --연수 
                                CASE WHEN I001.WGT = 0 THEN TO_CHAR(I003.WGT, ''FM999,999,999,990.099'') ELSE TO_CHAR(I001.WGT, ''FM999,999,999,990.099'') END WGT,  --중량
                                DECODE(S019.PACKTYPE, ''A'', ''자동'', ''B'', ''수축'')     PACKTYPE,                      --포장타입        
                                M009.CUST_NM,                       --거래처   
                                CASE WHEN I001.STCK_STA = ''00'' AND NVL(I001.STCK_QTY, 0) > 0 AND NVL(S019.COMP_YN, ''N'') != ''Y'' THEN ''투입가능''
                                    WHEN I001.STCK_STA = ''00'' AND NVL(I001.STCK_QTY, 0) <= 0 THEN ''투입불가(재고부족)''
                                    WHEN I001.STCK_STA = ''10'' THEN ''투입중'' || '' ('' || M012.MACH_NM || '')''
                                    WHEN I001.STCK_STA = ''40'' THEN ''투입불가(보류재고)''
                                    WHEN I001.STCK_STA = ''70'' THEN ''투입불가(출고)''
                                    WHEN I001.STCK_STA = ''80'' THEN ''투입불가(출고요청)''
                                    ELSE ''투입불가'' END STCK_STA   --재고상태
                              FROM TB_INV001 I001,
                                    TB_SCH019 S019,
                                    TB_SCH020 S020,
                                    TB_MAS001 M001,
                                    TB_MAS009 M009,
                                    TB_INV003 I003,
                                    TB_MAS012 M012,
                                    USRMA U001
                             WHERE S019.WRK_ORDR_NO = S020.WRK_ORDR_NO(+)
                               AND S019.WRK_ORDR_SEQNO = S020.WRK_ORDR_SEQNO(+)
                               AND S019.ORDER_DIV = ''ZP12''
                               --AND S020.LOT_NO = I001.LOT_NO(+)
							   AND S019.ORDER_NO = I001.ORDER_NO(+)
                               AND I001.WERKS = M001.WERKS(+)
                               AND I001.MATNR = M001.MATNR(+)
                               AND I001.IND_BCD = I003.IND_BCD(+)
                               AND I003.MACH_CD = M012.MACH_CD(+)
                               AND I001.REGID = U001.USERID(+)
                               AND S019.KUNNR = M009.KUNNR(+)
                               AND I001.WERKS = ''' || V_WERKS || '''
                               AND I001.STOR_LOC_CD = ''' || V_STOR_LOC_CD || '''
                               AND I001.LOC_CD = ''' || V_LOC_CD || '''
                               AND I001.IND_BCD = ''' || V_IND_BCD || '''
                               AND I001.STCK_KY IS NOT NULL
							   AND S019.COMP_YN = ''N'' ';

        ELSIF V_PROC_CD = 'PB' OR V_PROC_CD = 'PC' THEN     --포장 공정
            --정규
            V_SQL := 'SELECT DISTINCT 
                            I001.IND_BCD,                      --재단 바코드
                            I001.LOT_NO,                        --재단 LOT NO
                            I001.WRK_ORDR_NO,                   --작업지시 번호
                            I001.WRK_ORDR_SEQNO,                --작업지시 순번
                            I001.ORDER_NO,                      --오더번호
                            I001.MATNR,                         --자재(제품)코드
                            M001.PCODE_NM,                      --지종명
                            M001.BS_WGT,                        --평량
                            SUBSTR(I001.MATNR, 10, 4) || '' * '' || SUBSTR(I001.MATNR, 14, 4) MATNR_SPEC,                    --규격
                            TO_CHAR(S017.IN_PER_CNT) || '' / '' || CASE WHEN NVL(S017.IN_PER_CNT, 0) = 0 THEN 0 ELSE (NVL(S017.PLT_PER_CNT, 0) * 500) / S017.IN_PER_CNT END S_MCNT,    --속/매
                            TO_CHAR(W002.PCNT, ''FM999,999,999,990.0'')                STCK_QTY,  --연수 
                            CASE WHEN I001.WGT = 0 THEN TO_CHAR(I003.WGT, ''FM999,999,999,990.099'') ELSE TO_CHAR(I001.WGT, ''FM999,999,999,990.099'') END WGT,  --중량
                            I001.PRD_DT,                        --생산일자
                            U001.NMLAST,                        --작업자
                            DECODE(W002.PACKTYPE, ''A'', ''자동'', ''B'', ''수축'') PACKTYPE,       --포장타입        
                            M009.CUST_NM,                       --거래처  
                            CASE WHEN I001.STCK_STA = ''00'' AND NVL(I001.STCK_QTY, 0) > 0 THEN ''투입가능''
                                WHEN I001.STCK_STA = ''00'' AND NVL(I001.DLFL,''N'') = ''Y'' THEN ''투입불가(실적취소)''
                                WHEN I001.STCK_STA = ''00'' AND NVL(I001.STCK_QTY, 0) <= 0 THEN ''투입불가(재고부족)''
                                WHEN I001.STCK_STA = ''10'' THEN ''투입중'' || '' ('' || M012.MACH_NM || '')''
                                WHEN I001.STCK_STA = ''40'' THEN ''투입불가(보류재고)''
                                WHEN I001.STCK_STA = ''70'' THEN ''투입불가(출고)''
                                WHEN I001.STCK_STA = ''80'' THEN ''투입불가(출고요청)''
                                ELSE ''투입불가'' END STCK_STA   --재고상태
                            ,(SELECT DISTINCT DECODE(NVL(ZRESULT, ''S''), ''S'', ''Y'', ''N'') FROM TB_IFS005 I005 WHERE I005.AUFNR = I001.ORDER_NO AND I005.CONFM = ''X'' AND ROWNUM =1 )    FLAG 
                          FROM TB_INV001 I001,
                                TB_WRK002 W002,
                                TB_MAS001 M001,
                                TB_SCH017 S017,
                                TB_MAS009 M009,
                                TB_INV003 I003,
                                TB_MAS012 M012,
                                USRMA U001
                         WHERE I001.WERKS = W002.WERKS(+)
                           AND I001.IND_BCD = W002.IND_BCD(+)
                           AND I001.MACH_CD = W002.MACH_CD(+)
                           AND I001.WERKS = M001.WERKS(+)
                           AND I001.MATNR = M001.MATNR(+)
                           AND I001.WRK_ORDR_NO = S017.WRK_ORDR_NO(+)
                           AND I001.WRK_ORDR_SEQNO = S017.WRK_ORDR_SEQNO(+)
                           --AND I001.MACH_CD = I003.MACH_CD(+)
                           AND I001.IND_BCD = I003.IND_BCD(+)
                           AND I003.MACH_CD = M012.MACH_CD(+)
                           AND W002.REGID = U001.USERID(+)
                           AND W002.KUNNR = M009.KUNNR(+)
                           AND I001.WERKS = ''' || V_WERKS || '''
                           AND I001.STOR_LOC_CD = ''' || V_STOR_LOC_CD || '''
                           AND I001.LOC_CD = ''' || V_LOC_CD || '''
                           AND I001.IND_BCD = ''' || V_IND_BCD || '''
                           AND I001.STCK_KY IS NULL
            --예외                   
                    UNION ALL
                        SELECT DISTINCT 
                                I001.IND_BCD,                      --재단 바코드(포장 바코드)
                                I001.LOT_NO,                        --포장 LOT NO
                                I001.WRK_ORDR_NO,                   --작업지시 번호
                            	I001.WRK_ORDR_SEQNO,                --작업지시 순번
                            	I001.ORDER_NO,                      --오더번호
                                I001.MATNR,                         --자재(제품)코드
                                M001.PCODE_NM,                      --지종명
                                S019.BS_WGT,                        --평량
                                SUBSTR(I001.MATNR, 10, 4) || '' * '' || SUBSTR(I001.MATNR, 14, 4) MATNR_SPEC,                    --규격
                                TO_CHAR(S019.IN_PER_CNT) || '' / '' || CASE WHEN NVL(S019.IN_PER_CNT, 0) = 0 THEN 0 ELSE (NVL(S019.PLT_PER_CNT, 0) * 500) / S019.IN_PER_CNT END S_MCNT,    --속/매
                                 TO_CHAR(I001.STCK_QTY, ''FM999,999,999,990.0'') STCK_QTY,                      --연수
                                CASE WHEN I001.WGT = 0 THEN TO_CHAR(I003.WGT, ''FM999,999,999,990.099'') ELSE TO_CHAR(I001.WGT, ''FM999,999,999,990.099'') END WGT,  --중량
                                I001.PRD_DT,                        --생산일자
                                U001.NMLAST,                        --작업자
                                DECODE(S019.PACKTYPE, ''A'', ''자동'', ''B'', ''수축'')     PACKTYPE,                      --포장타입        
                                M009.CUST_NM,                       --거래처   
                                CASE WHEN I001.STCK_STA = ''00'' AND NVL(I001.STCK_QTY, 0) > 0 AND NVL(S019.COMP_YN, ''N'') != ''Y'' THEN ''투입가능''
                                    WHEN I001.STCK_STA = ''00'' AND NVL(I001.STCK_QTY, 0) <= 0 THEN ''투입불가(재고부족)''
                                    WHEN I001.STCK_STA = ''10'' THEN ''투입중'' || '' ('' || M012.MACH_NM || '')''
                                    WHEN I001.STCK_STA = ''40'' THEN ''투입불가(보류재고)''
                                    WHEN I001.STCK_STA = ''70'' THEN ''투입불가(출고)''
                                    WHEN I001.STCK_STA = ''80'' THEN ''투입불가(출고요청)''
                                    ELSE ''투입불가'' END STCK_STA   --재고상태
                              ,(SELECT DISTINCT DECODE(NVL(ZRESULT, ''S''), ''S'', ''Y'', ''N'') FROM TB_IFS006 I006 WHERE I006.AUFNR = I001.ORDER_NO AND I006.CONF = ''X'' AND ROWNUM =1 )    FLAG       
                              FROM TB_INV001 I001,
                                    TB_SCH019 S019,
                                    TB_SCH020 S020,
                                    TB_MAS001 M001,
                                    TB_MAS009 M009,
                                    TB_INV003 I003,
                                    TB_MAS012 M012,
                                    USRMA U001
                             WHERE S019.WRK_ORDR_NO = S020.WRK_ORDR_NO(+)
                               AND S019.WRK_ORDR_SEQNO = S020.WRK_ORDR_SEQNO(+)
                               AND S019.ORDER_DIV = ''ZP13''
                               --AND S020.LOT_NO = I001.LOT_NO(+)
							   AND S019.ORDER_NO = I001.ORDER_NO(+)
                               AND I001.WERKS = M001.WERKS(+)
                               AND I001.MATNR = M001.MATNR(+)
                               AND I001.IND_BCD = I003.IND_BCD(+)
                               AND I003.MACH_CD = M012.MACH_CD(+)
                               AND I001.REGID = U001.USERID(+)
                               AND S019.KUNNR = M009.KUNNR(+)
                               AND I001.WERKS = ''' || V_WERKS || '''
                               AND I001.STOR_LOC_CD = ''' || V_STOR_LOC_CD || '''
                               AND I001.LOC_CD = ''' || V_LOC_CD || '''
                               AND I001.IND_BCD = ''' || V_IND_BCD || '''
                               AND I001.STCK_KY IS NOT NULL
							   AND S019.COMP_YN = ''N'' ';

        ELSIF V_PROC_CD = 'ZA' THEN     --문제적재소 공정
            V_LOC_CD := 'L2500';

            V_SQL := 'SELECT DISTINCT 
                            I001.IND_BCD,                      --재단 바코드
                            I001.LOT_NO,                        --재단 LOT NO
                            I001.WRK_ORDR_NO,                   --작업지시 번호
                            I001.WRK_ORDR_SEQNO,                --작업지시 순번
                            I001.ORDER_NO,                      --오더번호
                            I001.MATNR,                         --자재(제품)코드
                            M001.PCODE_NM,                      --지종명
                            M001.BS_WGT,                        --평량
                            SUBSTR(I001.MATNR, 10, 4) || '' * '' || SUBSTR(I001.MATNR, 14, 4) MATNR_SPEC,                    --규격
                            TO_CHAR(S017.IN_PER_CNT) || '' / '' || CASE WHEN NVL(S017.IN_PER_CNT, 0) = 0 THEN 0 ELSE (NVL(S017.PLT_PER_CNT, 0) * 500) / S017.IN_PER_CNT END S_MCNT,    --속/매
                            TO_CHAR(W002.PCNT, ''FM999,999,999,990.0'')                STCK_QTY,  --연수 
                            CASE WHEN I001.WGT = 0 THEN TO_CHAR(I003.WGT, ''FM999,999,999,990.099'') ELSE TO_CHAR(I001.WGT, ''FM999,999,999,990.099'') END WGT,  --중량
                            I001.PRD_DT,                        --생산일자
                            U001.NMLAST,                        --작업자
                            DECODE(W002.PACKTYPE, ''A'', ''자동'', ''B'', ''수축'') PACKTYPE,       --포장타입        
                            M009.CUST_NM,                       --거래처  
                            CASE WHEN I001.STCK_STA = ''40'' AND NVL(I001.STCK_QTY, 0) > 0 THEN ''투입가능''
                                WHEN I001.STCK_STA = ''40'' AND NVL(I001.DLFL,''N'') = ''Y'' THEN ''투입불가(실적취소)''
                                WHEN I001.STCK_STA = ''40'' AND NVL(I001.STCK_QTY, 0) <= 0 THEN ''투입불가(재고부족)''
                                WHEN I001.STCK_STA = ''10'' THEN ''투입중'' || '' ('' || M012.MACH_NM || '')''
                                WHEN I001.STCK_STA = ''70'' THEN ''투입불가(출고)''
                                WHEN I001.STCK_STA = ''80'' THEN ''투입불가(출고요청)''
                                ELSE ''투입불가'' END STCK_STA   --재고상태
                            ,(SELECT DISTINCT DECODE(NVL(ZRESULT, ''S''), ''S'', ''Y'', ''N'') FROM TB_IFS005 I005 WHERE I005.AUFNR = I001.ORDER_NO AND I005.CONFM = ''X'' AND ROWNUM =1 )    FLAG 
                          FROM TB_INV001 I001,
                                TB_WRK002 W002,
                                TB_MAS001 M001,
                                TB_SCH017 S017,
                                TB_MAS009 M009,
                                TB_INV003 I003,
                                TB_MAS012 M012,
                                USRMA U001
                         WHERE I001.WERKS = W002.WERKS(+)
                           AND I001.IND_BCD = W002.IND_BCD(+)
                           AND I001.MACH_CD = W002.MACH_CD(+)
                           AND I001.WERKS = M001.WERKS(+)
                           AND I001.MATNR = M001.MATNR(+)
                           AND I001.WRK_ORDR_NO = S017.WRK_ORDR_NO(+)
                           AND I001.WRK_ORDR_SEQNO = S017.WRK_ORDR_SEQNO(+)
                           --AND I001.MACH_CD = I003.MACH_CD(+)
                           AND I001.IND_BCD = I003.IND_BCD(+)
                           AND I003.MACH_CD = M012.MACH_CD(+)
                           AND W002.REGID = U001.USERID(+)
                           AND W002.KUNNR = M009.KUNNR(+)
                           AND I001.WERKS = ''' || V_WERKS || '''
                           AND I001.STOR_LOC_CD = ''' || V_STOR_LOC_CD || '''
                           AND I001.LOC_CD = ''' || V_LOC_CD || '''
                           AND I001.IND_BCD = ''' || V_IND_BCD || ''' ';    
        END IF;

        BEGIN           
     		OPEN P_RS_LIST FOR V_SQL;
--            
--            LOOP
--            FETCH P_RS_LIST INTO V_LOT_NO, V_IND_BCD, V_FLAG;
--            EXIT WHEN P_RS_LIST%NOTFOUND;
--            
--            IF V_FLAG = 'N' THEN
--                INSERT INTO TEMP_IND_BCD VALUES(V_IND_BCD, V_LOT_NO, SYSDATE);
--            END IF;
--            
--            END LOOP;
--            CLOSE P_RS_LIST;

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

    ELSIF P_TYPE = 'SUB_LIST1' THEN  /* 작업지시 조회(폼 LOAD 시, 작업지시 새로고침)*/
        RETURN;  

    ELSIF P_TYPE = 'SAVE' THEN      /* 공정투입*/
     BEGIN
        SELECT STCK_QTY INTO V_STCK_QTY
          FROM TB_INV001
         WHERE WERKS = V_WERKS
           AND IND_BCD = V_IND_BCD;

        IF NVL(V_STCK_QTY, 0) = 0 THEN
            SELECT MACH_CD INTO V_MACH_CD
              FROM TB_INV003
             WHERE WERKS = V_WERKS
               AND IND_BCD = V_IND_BCD;

            SELECT MACH_NM INTO V_MACH_NM
              FROM TB_MAS012
             WHERE MACH_CD = V_MACH_CD;

            P_SUCCESS := 'N';
            P_ERR_MSG := V_MACH_NM || '에 투입된 개별바코드이므로 투입할 수 없습니다.';
            ROLLBACK;
            RETURN;
        END IF;

        IF V_PROC_CD = 'PB' OR V_PROC_CD = 'PC' OR V_PROC_CD = 'ZA' THEN     --포장 공정
            BEGIN
            SELECT COUNT(*) INTO V_COUNT
              FROM TB_INV003
             WHERE WERKS = V_WERKS
               AND IND_BCD = V_IND_BCD;  
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    V_COUNT := 0;
            END;
            
            IF V_COUNT > 0 THEN
                UPDATE TB_INV003
                   SET USE_QTY = 0,
                       STCK_QTY = IN_QTY
                 WHERE WERKS = V_WERKS
                   AND IND_BCD = V_IND_BCD;      
            ELSE
                INSERT INTO TB_INV003( WERKS,
                                        MACH_CD,
                                        MATNR,
                                        IND_BCD,
                                        WRK_ORDR_NO,
                                        WRK_ORDR_SEQNO,
                                        SEQNO,
                                        INP_DT,     -- 투입일자 추가 2022-06-03
                                        IN_QTY,
                                        USE_QTY,
                                        STCK_QTY,
                                        UNIT,
                                        ROLLCNT,
                                        WGT,
                                        CHG_FLG,
                                        STCK_KY,
                                        LOT_NUM,
                                        LOT_NO,
                                        REGDATE,
                                        REGID,
                                        PRE_IN_QTY )
                SELECT I001.WERKS,
                    V_MACH_CD,
                    I001.MATNR,
                    V_IND_BCD,
                    I001.WRK_ORDR_NO,
                    I001.WRK_ORDR_SEQNO,
                    1,
                    TO_CHAR(V_DATE, 'YYYYMMDD'),     -- 투입일자 추가 2022-06-03
                    DECODE(I001.UNIT ,'R', I001.STCK_QTY, I001.STCK_QTY/500),
                    0,
                    DECODE(I001.UNIT ,'R', I001.STCK_QTY, I001.STCK_QTY/500),
                    DECODE(I001.UNIT ,'R', 'R', 'R'),
                    I001.ROLLCNT,
                    I001.WGT,
                    'N',
                    I001.STCK_KY,
                    I001.LOT_NUM,
                    I001.LOT_NO,
                    V_DATE,
                    V_SESS_USER_ID,
                    DECODE(I001.UNIT ,'R', I001.STCK_QTY, I001.STCK_QTY/500)
                  FROM TB_INV001 I001
                 WHERE I001.WERKS = V_WERKS
                   AND I001.IND_BCD = V_IND_BCD;
            END IF;
        ELSIF V_PROC_CD = 'CB' THEN                         --수재단 공정
            INSERT INTO TB_INV003( WERKS,
                                    MACH_CD,
                                    MATNR,
                                    IND_BCD,
                                    WRK_ORDR_NO,
                                    WRK_ORDR_SEQNO,
                                    SEQNO,
                                    INP_DT,     -- 투입일자 추가 2022-06-03
                                    IN_QTY,
                                    USE_QTY,
                                    STCK_QTY,
                                    UNIT,
                                    ROLLCNT,
                                    WGT,
                                    CHG_FLG,
                                    STCK_KY,
                                    LOT_NUM,
                                    LOT_NO,
                                    REGDATE,
                                    REGID,
                                    PRE_IN_QTY )
            SELECT I001.WERKS,
                V_MACH_CD,
                I001.MATNR,
                V_IND_BCD,
                I001.WRK_ORDR_NO,
                I001.WRK_ORDR_SEQNO,
                1,
                TO_CHAR(V_DATE, 'YYYYMMDD'),     -- 투입일자 추가 2022-06-03
                --I001.STCK_QTY,
                I001.WGT,
                0,
                --I001.STCK_QTY,
                I001.WGT,
                'KG',
                I001.ROLLCNT,
                I001.WGT,
                'N',
                I001.STCK_KY,
                I001.LOT_NUM,
                I001.LOT_NO,
                V_DATE,
                V_SESS_USER_ID,
                I001.STCK_QTY
                --I001.EA_QTY
              FROM TB_INV001 I001
             WHERE I001.WERKS = V_WERKS
               AND I001.IND_BCD = V_IND_BCD;
        ELSE
            INSERT INTO TB_INV003( WERKS,
                                    MACH_CD,
                                    MATNR,
                                    IND_BCD,
                                    WRK_ORDR_NO,
                                    WRK_ORDR_SEQNO,
                                    SEQNO,
                                    INP_DT,     -- 투입일자 추가 2022-06-03
                                    IN_QTY,
                                    USE_QTY,
                                    STCK_QTY,
                                    UNIT,
                                    ROLLCNT,
                                    WGT,
                                    CHG_FLG,
                                    STCK_KY,
                                    LOT_NUM,
                                    LOT_NO,
                                    REGDATE,
                                    REGID,
                                    PRE_IN_QTY )
            SELECT I001.WERKS,
                V_MACH_CD,
                I001.MATNR,
                V_IND_BCD,
                I001.WRK_ORDR_NO,
                I001.WRK_ORDR_SEQNO,
                1,
                TO_CHAR(V_DATE, 'YYYYMMDD'),     -- 투입일자 추가 2022-06-03
                I001.STCK_QTY,
                0,
                I001.STCK_QTY,
                I001.UNIT,
                I001.ROLLCNT,
                I001.WGT,
                'N',
                I001.STCK_KY,
                I001.LOT_NUM,
                I001.LOT_NO,
                V_DATE,
                V_SESS_USER_ID,
                I001.STCK_QTY
              FROM TB_INV001 I001
             WHERE I001.WERKS = V_WERKS
               AND I001.IND_BCD = V_IND_BCD;
        END IF;

        --재고 수량 업데이트
        IF  V_PROC_CD = 'ZA' THEN
            UPDATE TB_INV001 I001
               SET I001.STCK_QTY = 0
                , I001.STCK_STA = '10'
                , I001.UCFMTY_FLG = 'Y'     -- 문제제품 적재소 인경우 부적합처리여부(UCFMTY_FLG) 에 'Y' 처리함.
                , I001.UPDDATE = V_DATE
                , I001.UPDID = V_SESS_USER_ID
             WHERE I001.WERKS = V_WERKS
               AND I001.IND_BCD = V_IND_BCD; 
        ELSE
            UPDATE TB_INV001 I001
               SET I001.STCK_QTY = 0
                , I001.STCK_STA = '10'
                , I001.UPDDATE = V_DATE
                , I001.UPDID = V_SESS_USER_ID
             WHERE I001.WERKS = V_WERKS
               AND I001.IND_BCD = V_IND_BCD; 
        END IF;

        UPDATE TB_WRK002
           SET STA = '10'
         WHERE IND_BCD = V_IND_BCD ;

        IF  V_PROC_CD = 'CA' THEN
            SELECT WCS_WRK_CD INTO V_WCS_WRK_CD
              FROM TB_MAS012
             WHERE MACH_CD = V_MACH_CD;

            SELECT LOT_NO INTO V_LOT_NO
              FROM TB_INV001
             WHERE WERKS = V_WERKS
               AND IND_BCD = V_IND_BCD;

            V_DOC_NO := FN_GET_MDOCNO('M','IF207');
            V_DOC_SEQNO := 1;

            INSERT INTO TB_IFSWC007(DOC_NO, DOC_NOSEQ, IND_BCD, LOT_NO, CT_LOT_NO, WERKS, MCHN_NO, PRCS_NO,
                                    FCLT_CD, WORK_DT, STA, REGDATE, REGID, 
                                    REMARK1, REMARK2, REMARK3, REMARK4, REMARK5, REMARK6, REMARK7, REMARK8, REMARK9, REMARK10,
                                    IF_STATUS, IF_GET_DATE)
                           VALUES( V_DOC_NO, V_DOC_SEQNO, V_IND_BCD, V_LOT_NO, '', V_WERKS, 'PM3', 'C',
                                    V_WCS_WRK_CD, TO_CHAR(V_DATE, 'YYYYMMDD'),  'I', V_DATE, V_SESS_USER_ID,
                                    '', '', '', '', '', '', '', '', '', '', 
                                    'N', V_DATE);
        END IF;

--        EXCEPTION           
--        WHEN OTHERS THEN 
--             P_SUCCESS           := 'N';
--             E_SQL_ERR_CD        := SQLCODE;
--             E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';
--             ROLLBACK;
--
--             SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
--             RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);           
--             RETURN;           
        END;   

    ELSIF P_TYPE = 'SUB_SAVE1' THEN  /* 공정투입취소*/

        -- 실적이 있는경우 취소 못하도록 처리해야함.
        V_CHK_PERF := '0' ;
        BEGIN
            SELECT '1'
              INTO V_CHK_PERF  
              FROM TB_INV010  INV010    --자재투입이력		
             WHERE WERKS        =  V_WERKS
               AND IND_BCD_M    =  V_IND_BCD
               AND NVL(CNL_YN, 'N') = 'N'
               --AND SDOC_NO      IS NOT NULL
               AND ROWNUM = 1;  
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                V_CHK_PERF := '0';
            WHEN OTHERS THEN
                V_CHK_PERF := '0';
        END;

        IF V_CHK_PERF = '1'  THEN
            P_SUCCESS   := 'N';
            P_ERR_MSG   := V_IND_BCD || '는 사용된 이력이 있으므로 투입 취소할 수 없습니다.';
            RETURN;
        END IF;

        BEGIN
            SELECT STCK_QTY, PRE_IN_QTY INTO V_STCK_QTY, V_PRE_IN_QTY
              FROM TB_INV003
             WHERE MACH_CD = V_MACH_CD
               AND IND_BCD = V_IND_BCD;
        EXCEPTION WHEN NO_DATA_FOUND THEN
            V_STCK_QTY := 0;
        END;

        IF V_STCK_QTY = 0 THEN
            P_SUCCESS := 'N';
            P_ERR_MSG := '투입한 이력이 없습니다.';
            RETURN;
        END IF;

        SELECT I003.MACH_CD, M012.MACH_NM INTO V_MACH_CD_PRE, V_MACH_NM 
          FROM TB_INV003 I003
             , TB_MAS012 M012
         WHERE I003.MACH_CD = M012.MACH_CD(+)
           AND I003.IND_BCD = V_IND_BCD;

        IF V_MACH_CD != V_MACH_CD_PRE THEN      
            P_SUCCESS := 'N';
            P_ERR_MSG := V_MACH_NM || '에 투입되어 있으므로 취소할 수 없습니다. ' || V_MACH_NM || '에서 투입 취소 가능합니다.';
            ROLLBACK;
            RETURN;
        END IF;

        IF  V_PROC_CD = 'CA' THEN
            --207
            SELECT WCS_WRK_CD INTO V_WCS_WRK_CD
              FROM TB_MAS012
             WHERE MACH_CD = V_MACH_CD;

            SELECT LOT_NO INTO V_LOT_NO
              FROM TB_INV001
             WHERE WERKS = V_WERKS
               AND IND_BCD = V_IND_BCD;

            V_DOC_NO := FN_GET_MDOCNO('M','IF207');
            V_DOC_SEQNO := 1;

            INSERT INTO TB_IFSWC007(DOC_NO, DOC_NOSEQ, IND_BCD, LOT_NO, CT_LOT_NO, WERKS, MCHN_NO, PRCS_NO,
                                    FCLT_CD, WORK_DT, STA, REGDATE, REGID,
                                    REMARK1, REMARK2, REMARK3, REMARK4, REMARK5, REMARK6, REMARK7, REMARK8, REMARK9, REMARK10,
                                    IF_STATUS, IF_GET_DATE)
                           VALUES( V_DOC_NO, V_DOC_SEQNO, V_IND_BCD, V_LOT_NO, '', V_WERKS, 'PM3', 'C',
                                    V_WCS_WRK_CD, TO_CHAR(V_DATE, 'YYYYMMDD'), 'R', V_DATE, V_SESS_USER_ID,
                                    '', '', '', '', '', '', '', '', '', '', 
                                    'N', V_DATE);
        END IF;    

        IF V_PROC_CD = 'ZA' THEN     --문제제품 적재소 포장 공정
            UPDATE TB_INV001
               SET STCK_QTY = DECODE(UNIT, 'R', V_STCK_QTY, V_STCK_QTY * 500)
                , STCK_STA = '40'
                , UCFMTY_FLG = 'N'     -- 문제재기 적재소 인경우 부적합처리여부(UCFMTY_FLG) 에 'N' 처리함.
                , UPDDATE = V_DATE
             WHERE WERKS = V_WERKS
               --AND STOR_LOC_CD = V_STOR_LOC_CD
               --AND LOC_CD = V_LOC_CD
               AND IND_BCD = V_IND_BCD
               AND MATNR = V_MATNR;
        ELSIF V_PROC_CD = 'PB' OR V_PROC_CD = 'PC' THEN     --포장 공정
            UPDATE TB_INV001
               SET STCK_QTY = DECODE(UNIT, 'R', V_STCK_QTY,   V_STCK_QTY * 500)
                 , STCK_STA = '00'
                 , UPDDATE = V_DATE
             WHERE WERKS = V_WERKS
               --AND STOR_LOC_CD = V_STOR_LOC_CD
               --AND LOC_CD = V_LOC_CD
               AND IND_BCD = V_IND_BCD
               AND MATNR = V_MATNR;

        ELSIF V_PROC_CD = 'CB' THEN                         --수재단 공정
            UPDATE TB_INV001
               SET STCK_QTY = V_PRE_IN_QTY
                 , STCK_STA = '00'
                 , UPDDATE = V_DATE
                 , UPDID = V_SESS_USER_ID
             WHERE WERKS = V_WERKS
               --AND STOR_LOC_CD = V_STOR_LOC_CD
               --AND LOC_CD = V_LOC_CD
               AND IND_BCD = V_IND_BCD
               AND MATNR = V_MATNR;
        ELSE
            UPDATE TB_INV001
               SET STCK_QTY = V_STCK_QTY
                , STCK_STA = '00'
                , UPDDATE = V_DATE
             WHERE WERKS = V_WERKS
               --AND STOR_LOC_CD = V_STOR_LOC_CD
               --AND LOC_CD = V_LOC_CD
               AND IND_BCD = V_IND_BCD
               AND MATNR = V_MATNR;
        END IF;

        UPDATE TB_WRK002
           SET STA = '00'
         WHERE IND_BCD = V_IND_BCD  ;

        DELETE
          FROM TB_INV003
         WHERE WERKS = V_WERKS
           AND MACH_CD = V_MACH_CD
           AND IND_BCD = V_IND_BCD
           AND MATNR = V_MATNR; 

        --TB_INV010  삭제
        UPDATE TB_INV010
           SET CNL_YN = 'Y'
             , UPDDATE = SYSDATE
             , UPDID = V_SESS_USER_ID
         WHERE WERKS        =  V_WERKS
           AND IND_BCD_M    =  V_IND_BCD
           AND NVL(CNL_YN, 'N') = 'N';  
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
--        SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
--        
--        ROLLBACK;
--        RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
END;

/
