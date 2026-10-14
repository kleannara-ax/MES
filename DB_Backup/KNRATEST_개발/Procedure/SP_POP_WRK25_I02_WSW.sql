--------------------------------------------------------
--  DDL for Procedure SP_POP_WRK25_I02_WSW
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK25_I02_WSW" 
(
     P_WERKS     		IN VARCHAR2 	                --플랜트
    ,P_MACH_CD   		IN VARCHAR2 	                --설비코드
    ,P_WRK_LIST         IN CLOB
    ,P_WRK_CLASS        IN VARCHAR2
    ,P_WRK_SHIFT        IN VARCHAR2
    ,P_USERID           IN VARCHAR2                     --USER ID
    ,RS_PRFM_RFCFN      OUT VARCHAR2                    --실적 RFCFN값
    ,RS_DISPO_RFCFN     OUT VARCHAR2                    --폐품 RFCFN값    
    ,RS_INPUT_RFCFN     OUT VARCHAR2                    --투입량 RFCFN값  
    ,RS_SDISPO_RFCFN    OUT VARCHAR2                    --영업폐품 RFCFN값    
    ,RS_IND_BCD   		OUT VARCHAR2                    --개별바코드
    ,Lang       		IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE     		OUT VARCHAR2 
    ,RS_MSG      		OUT VARCHAR2
    ,CUR_1              OUT SYS_REFCURSOR              --실적
    ,CUR_2              OUT SYS_REFCURSOR
    ,CUR_3              OUT SYS_REFCURSOR              --폐품  
    ,CUR_4              OUT SYS_REFCURSOR
    ,CUR_5              OUT SYS_REFCURSOR              --투입량
    ,CUR_6              OUT SYS_REFCURSOR    
    ,CUR_7              OUT SYS_REFCURSOR              --영업폐품
    ,CUR_8              OUT SYS_REFCURSOR    
    
)
/*==============================================================================
 * PROGRAM ID    : WRK25{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 밀롤 실적등록
 * VERSION       : 1.0.1{최종 버전 기술}
 * DESCRIPTION   : .{프로그램에 대한 상세한 내용 기술}
 *                 
 * AUTHOR NAME   : 박충식{최초 작성자 명 기술}
 * CREATE DATE   : 2022/07/12 {최초 작성일자 기술}
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * yyyy/mm/dd    1.0.0   유상호         Initial Version 
 * 2022-11-11    1.0.1   김병무         실적없이 폐품만 있는경우 0 실적등록 하여 완료플래그 전달
 *==============================================================================
 *  관련 테이블
 *       - [TB_WRK011] : (..U.) 설비별 현재진행사항                            
 *=============================================================================*/

AS 
    --프로그램 ID : 점보롤 실적등록
    V_PRG_NM        VARCHAR2(100)  := 'SP_POP_WRK25_I02_WSW';     -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID   varchar2(20) := P_USERID;  --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);

    V_JR_WRK_ORDR_NO  	    TB_WRK011.WRK_ORDR_NO%TYPE;			--점보롤작업지시번호
    V_JR_WRK_ORDR_SEQNO		TB_WRK011.WRK_ORDR_SEQNO%TYPE;		--점보롤작업지시번호순번
    -- JSON을 위한 변수선언 영역
    V_JSON           JSON_OBJECT_T;
    V_ARR_LIST       JSON_ARRAY_T;
    V_OBJ            JSON_OBJECT_T;

    V_WRK_ORDR_NO			TB_WRK002.WRK_ORDR_NO%TYPE;			--작업지시번호
    V_WRK_ORDR_SEQNO		TB_WRK002.WRK_ORDR_SEQNO%TYPE;		--작업지시번호순번
    V_WIDTH					TB_WRK002.WIDTH%TYPE;				--실지폭
    V_WIDTH_NO				TB_WRK002.WIDTH_NO%TYPE;			--지폭순서
    V_PRD_SEQ				TB_WRK002.PRD_SEQ%TYPE;				--실적순서
    V_MRLDCK				TB_WRK002.MRLDCK%TYPE;				--밀롤적치여부
    V_CUTTER				TB_WRK002.CUTTER%TYPE;				--카타
    V_ROLLCNT				TB_WRK002.ROLLCNT%TYPE;				--권치수
    V_WGT					TB_WRK002.WGT%TYPE;					--중량
    V_WGT_M					TB_WRK002.WGT%TYPE;					--중량
    V_DISPO_CD				TB_WRK004.DISPO_CD%TYPE;			--폐품코드
    V_DISPO_NM              VARCHAR2(100);
    V_DISPO_ROLLCNT			TB_WRK004.ROLLCNT%TYPE;				--폐품권치수
    V_DISPO_WGT				TB_WRK004.WGT%TYPE;					--폐품중량
    V_CORE					TB_WRK002.CORE%TYPE;				--지관
    V_PRD_STR_DATE          TB_WRK002.PRD_STR_DATE%TYPE;		--시작시간   
    V_PRD_END_DATE          TB_WRK002.PRD_END_DATE%TYPE;		--시작시간   
    V_RMK					TB_WRK002.RMK%TYPE;					--비고
    V_JRCOM_YN				VARCHAR2(10);
    V_MRCOM_YN				VARCHAR2(10);
    --parameter변수 처리
    V_DOC_NO                VARCHAR2(20);
    V_DOC_SEQNO             NUMBER;
    V_DOC_SEQNO1            NUMBER;
    V_DOC_NO_SCR            VARCHAR2(20);
    V_DOC_SEQNO_SCR         NUMBER;
    V_DOC_NO_WCS            VARCHAR2(20);
    V_DOC_SEQNO_WCS         NUMBER;
    V_DOC_NO_DISPO          VARCHAR2(200) := '';
    V_DOC_NO_PRFM           VARCHAR2(200) := '';
    V_DOC_NO_INPUT          VARCHAR2(200) := '';
    V_DOC_NO_SDISPO         VARCHAR2(200) := '';    
    V_ORDER_NO              TB_WRK002.ORDER_NO%TYPE;			--오더번호
    V_IND_BCD               TB_WRK002.IND_BCD%TYPE;				--개별바코드
    V_LOT_NO                TB_WRK002.LOT_NO%TYPE;				--LOT NO
    V_PRD_STR_DTM           VARCHAR2(20);                       --시작시간
    V_PRD_END_DTM           VARCHAR2(20);                       --종료시간
    V_ORD_PRD_STR_DTM       VARCHAR2(20);                       --작업지시 시작일시
    V_VBELN                 TB_SCH016.VBELN%TYPE;				--판매문서번호
    V_POSNR                 TB_SCH016.POSNR%TYPE;				--판매문서 아이템번호
    V_OVBELN                TB_SCH016.OVBELN%TYPE;				--판매문서번호
    V_OPOSNR                TB_SCH016.OPOSNR%TYPE;				--판매문서 아이템번호
    V_MATNR                 TB_WRK002.MATNR%TYPE;				--자재코드
    V_WRK_SEQ               TB_WRK002.WRK_SEQ%TYPE;				--생산순번
    V_MACHINE               TB_WRK002.MACHINE%TYPE;				--생산회기
    V_TO_MACHINE            TB_WRK002.TO_MACHINE%TYPE;			--생산회기
    V_PRFM_DT               TB_WRK002.PRFM_DT%TYPE;				--생산실적일
    V_PRD_DT                TB_WRK002.PRD_DT%TYPE;				--생산일
    V_DSTBT_DDLIN           TB_WRK002.DSTBT_DDLIN%TYPE;			--유통기간    
    V_TM                    TB_WRK002.TM%TYPE;					--작업시간
    V_UNIT                  TB_WRK002.UNIT%TYPE;				--단위
    V_PRD_NO                TB_WRK002.PRD_NO%TYPE;				--생산번호
    V_LOT_BUF               TB_SCH016.LOT_BUF%TYPE;				--이전LOT NO
    V_IND_BCD_M             TB_WRK002.IND_BCD%TYPE;				--점보롤 개별바코드
    V_MATNR_M               TB_WRK002.MATNR%TYPE;				--점보롤 자재코드
    V_LOT_NO_M              TB_WRK002.LOT_NO%TYPE;				--점보롤 LOT NO
    V_ORDER_NO_M            TB_WRK002.ORDER_NO%TYPE;			--점보롤 오더번호
    V_ORD_TM                NUMBER := 0 ;                       --오더 작업시간(분)
    V_WGT_RMD               NUMBER;                             --잔량(영업폐품) 중량
    V_SAP_WRK_CD            TB_MAS012.SAP_WRK_CD%TYPE;          --SAP작업장코드
    V_WCS_WRK_CD            TB_MAS012.WCS_WRK_CD%TYPE;          --WCS작업장코드
    V_LINE                  TB_MAS012.LINE%TYPE;                --라인
    V_ORDER_NUM             VARCHAR2(10);                       --생산지시번호
    V_ORDER_SEQ             VARCHAR2(10);                       --생산지시순번
    V_PCODE                 TB_SCH016.PCODE%TYPE;               --지종
    V_PCODE_NM              VARCHAR2(50);                       --지종명
    V_BS_WGT                TB_SCH016.BS_WGT%TYPE;              --평량
    V_MWIDTH                TB_SCH016.MWIDTH%TYPE;              --MR지폭
    V_SHEET                 TB_SCH016.SHEET%TYPE;               --시트판지구분
    V_SLITER                TB_SCH016.SLITER%TYPE;              --슬리터구분
    V_SPECIAL_NO            VARCHAR2(20);                       --특별재고번호
    V_ROUTE                 TB_SCH016.ROUTE%TYPE;               --항차
    V_KUNNR                 TB_SCH016.KUNNR%TYPE;               --거래처
    V_KUNNRT                TB_SCH016.KUNNRT%TYPE;              --거래처명    
    V_REMARK                TB_SCH016.REMARK%TYPE;              --오더비고
    V_VLEN                  TB_SCH017.VLEN%TYPE;                --세로길이
    V_WLEN                  TB_SCH017.WLEN%TYPE;                --가로길이
    V_PACKTYPE              TB_SCH018.PACKTYPE%TYPE;            --포장방식
    V_PACKTYPE_NM           VARCHAR2(20);                       --포장방식
    V_SIZE                  VARCHAR2(15);                       --규격(가로길이*세로길이)
    V_PLT_PER_CNT           TB_SCH017.PLT_PER_CNT%TYPE;         --팔레트당연수
    V_IN_PER_CNT            TB_SCH017.IN_PER_CNT%TYPE;          --속당매수
    V_IN_CNT                NUMBER;                             --속수
    V_USER_NM               VARCHAR2(20);                       --작업자명
    V_NTN_NM                VARCHAR2(50);                       --국가명
    V_PRFM_GTHR_YN          VARCHAR2(1);                        --실적집계여부
    V_DATE                  DATE := SYSDATE;
    V_JMACHINE              VARCHAR2(10);                       --점보롤 생산호기
    V_LOC_CD                VARCHAR2(10);                       --로케이션정보
    V_STOR_LOC_CD           VARCHAR2(10);    
    V_STOR_LOC_CD_M         VARCHAR2(10);    
    V_LOOP_CNT              NUMBER;
    V_DISPO_QTY            NUMBER(13,3);                      --밀롤 누적생산량
    V_ORDER_ITM_NO          VARCHAR2(10);
    V_SQL                   VARCHAR2(4000);    
    V_IND_BCD_PRE           TB_WRK002.IND_BCD%TYPE;
    V_REPROD_YN             VARCHAR2(1);
    V_WCS_WRK_CD_C         VARCHAR2(10);
    V_ORDER_RMK             TB_SCH016.ORDER_RMK%TYPE;
    V_YMCHK                     TB_MAS011.YMCHK%TYPE;   --실적등록 가능 여부
    V_LINE_NM               VARCHAR2(10);
    V_LINE_NM2              VARCHAR2(10);
    V_MMACHINE              VARCHAR2(10);

    V_WRK_ORDR_NO_M     TB_SCH015.WRK_ORDR_NO%TYPE;         --점보롤 작업지시번호
    V_WRK_ORDR_SEQNO_M  TB_SCH015.WRK_ORDR_SEQNO%TYPE;      --작업지시번호순번
    V_TOT_QTY           NUMBER(13,3);
BEGIN
    BEGIN

        V_DOC_NO_DISPO    := '';
        V_DOC_NO_PRFM     := '';
        V_DOC_NO_INPUT    := '';
        V_DOC_NO_SDISPO   := '';    

        V_DOC_SEQNO_SCR := 0;
        V_DOC_SEQNO     := 0;
        V_DOC_SEQNO1    := 0;
        V_DOC_SEQNO_WCS := 0;


        --JSON 데이터 수신
        V_JSON := JSON_OBJECT_T.parse(P_WRK_LIST); -- 전체 데이터

        V_ARR_LIST := V_JSON.get_array('list');
        --작업지시번호, 작업지시번호순번, 생산실지폭, 지폭순번, 실적순서, 밀롤적치여부, 재단
        --권치수, 중량, 폐품코드, 폐품권치수, 폐품중량, 지관, 작업시작일시, 작업종료일시, 가동시간(분)
        --비고, 점보롤 완료여부, 밀롤 완료여부, 점보롤 개별바코드, 점보롤 자재코드

        V_LOOP_CNT := V_ARR_LIST.get_size -1 ;
        FOR i IN 0..V_ARR_LIST.get_size-1 LOOP
            V_OBJ := TREAT (V_ARR_LIST.get (i) AS json_object_t);
            V_OBJ := TREAT (V_OBJ.get ('map') AS json_object_t);

            V_WRK_ORDR_NO			:= V_OBJ.get_string('WRK_ORDR_NO');
            V_WRK_ORDR_SEQNO		:= TO_NUMBER(V_OBJ.get_string('WRK_ORDR_SEQNO'));
            V_WIDTH					:= TO_NUMBER(V_OBJ.get_string('WIDTH'));
            V_WIDTH_NO				:= V_OBJ.get_string('WIDTH_NO');
            V_PRD_SEQ				:= TO_NUMBER(V_OBJ.get_string('PRD_SEQ'));  --밀롤생산순번(작업자입력)
            V_MRLDCK				:= V_OBJ.get_string('MRLDCK');
            V_CUTTER				:= V_OBJ.get_string('CUTTER');
            V_ROLLCNT				:= TO_NUMBER(V_OBJ.get_string('ROLLCNT'));
            V_WGT					:= TO_NUMBER(V_OBJ.get_string('WGT'));
            V_DISPO_CD				:= V_OBJ.get_string('DISPO_CD');
            V_DISPO_ROLLCNT			:= TO_NUMBER(V_OBJ.get_string('DISPO_ROLLCNT'));
            V_DISPO_WGT				:= TO_NUMBER(V_OBJ.get_string('DISPO_WGT'));
            V_CORE					:= V_OBJ.get_string('CORE');
            V_PRD_STR_DTM			:= V_OBJ.get_string('PRD_STR_DATE');
            V_PRD_END_DTM			:= V_OBJ.get_string('PRD_END_DATE');
            V_TM			        := TO_NUMBER(V_OBJ.get_string('TM'));
            V_RMK					:= V_OBJ.get_string('RMK');
            V_JRCOM_YN				:= V_OBJ.get_string('JRCOM_YN');
            V_MRCOM_YN				:= V_OBJ.get_string('MRCOM_YN');
            V_IND_BCD_M             := V_OBJ.get_string('IND_BCD_M');           --점보롤 개별바코드
            V_MATNR_M               := V_OBJ.get_string('MATRN_M');
            V_LOT_NO_M              := V_OBJ.get_string('LOT_NO_M');            --점보롤 LOT NO
            V_LOT_BUF               := ' '  ;            

            --실적일자, 생산일자, 유통기간
            V_PRFM_DT := FN_RECDATE(TO_DATE(V_PRD_END_DTM, 'YYYYMMDDHH24MISS'));
            V_PRD_DT := TO_CHAR(TO_DATE(V_PRD_END_DTM,'YYYYMMDDHH24MISS'), 'YYYYMMDD');
            V_DSTBT_DDLIN := ''; --FN_GET_DSTBT_DDLIN_DT(P_WERKS, V_MATNR, V_PRD_DT);

            V_PRD_STR_DATE := TO_DATE(V_PRD_STR_DTM, 'YYYYMMDDHH24MISS');
            V_PRD_END_DATE := TO_DATE(V_PRD_END_DTM, 'YYYYMMDDHH24MISS');

            --실적등록 가능 월 검사                
            BEGIN
                SELECT  YMCHK INTO  V_YMCHK
                  FROM TB_MAS011
                 WHERE WERKS = P_WERKS
                   AND YMCHK = 'Y'
                   AND YYMM  = SUBSTR(V_PRFM_DT, 1, 6);
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    V_YMCHK := 'N';
            END;
    
            IF V_YMCHK = 'N' THEN
                RS_CODE := 'E';
                RS_MSG := '실적등록 가능한 월이 아닙니다.';
                ROLLBACK;
                RETURN;
            END IF;


            SELECT      S016.ORDER_NO, S016.MATNR, S016.VBELN, S016.POSNR, S016.OVBELN, S016.OPOSNR, 
                        S016.MACHINE, S016.TO_MACHINE, S016.LOT_BUF, S016.PRD_STR_DTM, S016.UNIT,
                        TO_CHAR(S016.ORDER_NUM), TO_CHAR(S016.ORDER_SEQ), S016.PCODE, S016.BS_WGT, S016.MWIDTH, 
                        S016.SHEET, S016.SLITER, S016.ROUTE, S016.KUNNR, S016.KUNNRT, S016.REMARK,
                        S017.VLEN, S017.WLEN, S017.PLT_PER_CNT, S017.IN_PER_CNT,
                        S017.PACKTYPE, S016.ORDER_RMK
                        INTO
                        V_ORDER_NO, V_MATNR, V_VBELN, V_POSNR, V_OVBELN, V_OPOSNR,
                        V_MACHINE,  V_TO_MACHINE, V_LOT_BUF, V_ORD_PRD_STR_DTM, V_UNIT,
                        V_ORDER_NUM, V_ORDER_SEQ, V_PCODE, V_BS_WGT, V_MWIDTH, 
                        V_SHEET, V_SLITER, V_ROUTE, V_KUNNR, V_KUNNRT, V_REMARK,
                        V_VLEN, V_WLEN, V_PLT_PER_CNT, V_IN_PER_CNT,
                        V_PACKTYPE, V_ORDER_RMK
                  FROM TB_SCH016 S016,
                       TB_SCH017 S017 
                 WHERE S016.ORDER_NO = S017.PRE_ORDER_NO(+)
                   AND S016.WRK_ORDR_NO = V_WRK_ORDR_NO
                   AND S016.WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO                  
                   AND NVL(S016.USE_YN,'Y') = 'Y'
                   AND NVL(S017.USE_YN,'Y') = 'Y'
                   AND ROWNUM =1
                   ;

            SELECT LINE, SAP_WRK_CD, WCS_WRK_CD 
               INTO V_LINE, V_SAP_WRK_CD, V_WCS_WRK_CD
              FROM TB_MAS012
            WHERE MACH_CD = P_MACH_CD;

            V_MRLDCK := CASE WHEN NVL(V_MRLDCK, ' ') <> 'Y' THEN 'N' ELSE 'Y' END;

            --속수 = (팔레트당연수 * 500) / 속당매수
            V_IN_CNT := CASE WHEN NVL(V_IN_PER_CNT, 0) = 0 THEN 0 ELSE (V_PLT_PER_CNT * 500) / V_IN_PER_CNT END;
            --판지(Y)/원지(N)구분
            V_SHEET := CASE WHEN NVL(V_SHEET, ' ') = 'X' THEN 'Y' ELSE 'N' END;
            --슬리터구분
            V_SLITER := CASE WHEN NVL(V_SLITER, ' ') ='Y' THEN 'Y' ELSE 'N' END;
            --특별재고번호
            V_SPECIAL_NO := V_VBELN || SUBSTR('0000' || TO_CHAR(V_POSNR), -6);

            --로케이션 정보
            SELECT LGPRO INTO V_STOR_LOC_CD
              FROM TB_MAS001
             WHERE WERKS = P_WERKS
               AND MATNR = V_MATNR;

            IF  NVL(V_STOR_LOC_CD, '') = '' THEN
                RS_CODE := 'E';
                RS_MSG := '저장위치 정보를 확인해주세요';
                ROLLBACK;
                RETURN;
            END IF;

            BEGIN
            SELECT STOR_LOC_CD INTO V_STOR_LOC_CD_M
              FROM TB_INV001
             WHERE WERKS = P_WERKS
               AND IND_BCD = V_IND_BCD_M;
            EXCEPTION 
            WHEN NO_DATA_FOUND THEN
                V_STOR_LOC_CD_M := '2000';
            END;

            IF V_SLITER = 'Y' THEN
                V_LOC_CD := 'L2200';                --슬리터 대기창고
            ELSIF V_SLITER = 'N' AND  V_SHEET = 'N' THEN        
                V_LOC_CD := 'L2300';                --원지포장 대기창고
            ELSE
                V_LOC_CD := 'L2900';                --밀롤창고 입고대기 창고
            END IF;

            --규격(가로길이*세로길이)
            IF NVL(V_WLEN, 0) = 0 OR NVL(V_VLEN, 0) = 0 THEN
                V_SIZE := SUBSTR(V_MATNR, 10, 4)  || '*' || SUBSTR(V_MATNR, -4);
            ELSE
                V_SIZE := TO_CHAR(V_WLEN) || '*' || TO_CHAR(V_VLEN);
            END IF;
            
            --작업자명
            BEGIN
                SELECT NMLAST INTO V_USER_NM
                  FROM USRMA
                 WHERE USERID = P_USERID; 
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    V_USER_NM := '';
                 WHEN OTHERS THEN
                    V_USER_NM := '';
            END;

            --포장방식
            V_PACKTYPE_NM := ''; 
            /*BEGIN
                SELECT NVL(FN_CD_VAL('PACK_TYPE', V_PACKTYPE), ' ') INTO V_PACKTYPE_NM
                  FROM DUAL;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    V_PACKTYPE_NM := '';
                 WHEN OTHERS THEN
                    V_PACKTYPE_NM := '';    
            END;*/

            --국가명
            BEGIN
                SELECT NVL(FN_CD_VAL('NATNKY', LAND1), ' ') INTO V_NTN_NM
                  FROM TB_MAS009
                 WHERE CUST_CD = V_KUNNR
                   AND CUST_DIV = 'C'; 
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    V_NTN_NM := '';
                WHEN OTHERS THEN
                    V_NTN_NM := '';
            END;

           --지종명
           BEGIN
               SELECT PCODE_NM INTO V_PCODE_NM
                 FROM TB_MAS001
                WHERE WERKS = P_WERKS
                  AND MATNR = V_MATNR
                  AND PCODE = V_PCODE;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    V_PCODE_NM := '';
                WHEN OTHERS THEN
                    V_PCODE_NM := '';    
            END; 

            SELECT MACHINE INTO V_JMACHINE
              FROM TB_WRK002
             WHERE WERKS = P_WERKS
               AND IND_BCD = V_IND_BCD_M
               AND NVL(CNL_YN,'N') = 'N';

            IF NVL(V_CUTTER, 0)  <> '0' THEN
                SELECT WCS_WRK_CD  INTO V_WCS_WRK_CD_C
                  FROM TB_MAS012
                 WHERE PROC_CD = 'CA'
                   AND LINE = TO_NUMBER(NVL(V_CUTTER, 0));
            ELSE
                V_WCS_WRK_CD_C := '0';
            END IF;

            V_PRFM_GTHR_YN := 'Y';

            --개별바코드
            SP_GET_BARCODE_SEQ('IND', P_WERKS, 'M', V_MATNR, V_PRD_END_DTM, V_IND_BCD);
            --LOT NO
            SP_CHK_LOT_NO(V_LOT_BUF, P_WERKS, P_MACH_CD, V_MATNR, V_PRD_END_DTM, V_LOT_NO);
            V_LOT_BUF := V_LOT_NO ;
            --IF V_LOT_BUF IS NULL  THEN
                UPDATE  TB_SCH016  SET LOT_BUF = V_LOT_NO
                 WHERE WRK_ORDR_NO    = V_WRK_ORDR_NO
                   AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
                   --AND NVL(DLFL,'N') = 'N'  --삭제지시자 X='삭제' , N=정상오더
                   AND NVL(USE_YN,'Y') = 'Y'
                   ;
            --END IF ;

            --생산순번 조회
            BEGIN
                SELECT MAX(WRK_SEQ) INTO V_WRK_SEQ
                  FROM TB_WRK002
                 WHERE WERKS = P_WERKS
                   AND MACH_CD = P_MACH_CD
                   AND PRFM_DT = V_PRFM_DT
                   AND NVL(CNL_YN,'N') = 'N';
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    V_WRK_SEQ := 0;
            END;

            V_WRK_SEQ := NVL(V_WRK_SEQ, 0) + 1;

            --생산번호
            V_PRD_NO := TO_CHAR(TO_DATE(V_PRFM_DT, 'YYYYMMDD'), 'YYYY-MM-DD') || '-' || V_MACHINE || '-' || TO_CHAR(V_WRK_SEQ);

            --밀롤완료시

            IF V_MRCOM_YN = 'Y' THEN
                V_TOT_QTY := 0 ;
                SELECT
                       SUM(QTY)
                INTO   V_TOT_QTY     
                FROM 
                (
                        SELECT NVL(PRFM_QTY,0)   QTY
                        FROM TB_WRK002 
                         WHERE WRK_ORDR_NO    = V_WRK_ORDR_NO
                           AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
                           AND NVL(CNL_YN, 'N') =  'N'
                        UNION ALL
                        SELECT NVL(DISPO_QTY,0)  QTY
                        FROM TB_WRK004 
                         WHERE WRK_ORDR_NO    = V_WRK_ORDR_NO
                           AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
                           AND NVL(CNL_YN, 'N') =  'N'
                ) ;

                V_ORD_TM := ROUND((V_PRD_END_DATE - TO_DATE(V_ORD_PRD_STR_DTM, 'YYYY-MM-DD HH24:MI:SS')) *24 * 60);

                UPDATE TB_SCH016
                   SET PRD_END_DTM = V_PRD_END_DTM,
                       PRFM_QTY = V_TOT_QTY,
                       COMP_YN  = 'Y'
                 WHERE WRK_ORDR_NO    = V_WRK_ORDR_NO
                   AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
                   --AND NVL(DLFL,'N') = 'N'  --삭제지시자 X='삭제' , N=정상오더
                   AND NVL(USE_YN,'Y') = 'Y'
                   ;

            END IF;

            --폐품등록
            IF NVL(V_DISPO_ROLLCNT, 0) > 0 THEN
                V_DOC_NO_SCR := FN_GET_MDOCNO('M','IF134');
                V_DOC_SEQNO_SCR := V_DOC_SEQNO_SCR +1;

                V_DOC_NO_DISPO := V_DOC_NO_DISPO || V_DOC_NO_SCR||',' ;

                INSERT INTO TB_WRK004(WERKS, MACH_CD, IND_BCD, LOT_NO, MATNR, DISPO_CD, WRK_ORDR_NO, WRK_ORDR_SEQNO, ORDER_NO,
                                     MMATNR, IND_BCD_M, LOT_NO_M, UNIT, ROLLCNT, DISPO_QTY, MACHINE, WGT,
                                     PRD_STR_DATE, PRD_END_DATE, TM, PRFM_DT, WRK_CLASS, WRK_SHIFT, RUN_STA,
                                     DOC_NO, DOC_SEQNO, RMK, REGDATE, REGID,
                                     JRCOM_YN,MRCOM_YN)
                             VALUES( P_WERKS, P_MACH_CD, V_IND_BCD, V_LOT_NO, V_MATNR, V_DISPO_CD, V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_ORDER_NO,
                                    V_MATNR_M, V_IND_BCD_M, V_LOT_NO_M, V_UNIT, V_DISPO_ROLLCNT, V_DISPO_WGT, '', V_DISPO_WGT,
                                    V_PRD_STR_DATE, V_PRD_END_DATE, V_TM, V_PRFM_DT,P_WRK_CLASS, P_WRK_SHIFT, '02',
                                    V_DOC_NO_SCR, V_DOC_SEQNO_SCR, V_RMK, V_DATE, P_USERID,
                                    V_JRCOM_YN,V_MRCOM_YN);

                 SELECT DISPO_NM INTO V_DISPO_NM
                   FROM TB_MAS023
                  WHERE WERKS = P_WERKS
                    AND DISPO_CD = V_DISPO_CD;

                --폐품이력 전송
                INSERT INTO TB_IFS012( AUFNR, LOTNO, BUDAT, MATNR, SCRQTY, RSDQTY, SCRAPCODE, SCRAPREASON,
                                     LGORT, CHARG,
                                     SDATE, STIME, EDATE, ETIME, MDOCNO, MDOCSEQ, 
                                     MAKE_DATE, MAKER, RUNTIME, VBELN, POSNR, WORKCENTERCODE, MRSCQTY, SCRQTY_OP)
                            VALUES( V_ORDER_NO, V_LOT_NO, TO_CHAR(TO_DATE(V_PRFM_DT, 'YYYY-MM-DD'), 'YYYYMMDD'), V_MATNR_M, V_DISPO_WGT, 0,  V_DISPO_CD, V_DISPO_NM,
                                    V_STOR_LOC_CD_M, V_LOT_NO_M,
                                    TO_CHAR(V_PRD_STR_DATE,'YYYY-MM-DD'), TO_CHAR(V_PRD_STR_DATE,'HH24:MI:SS'),
                                    TO_CHAR(V_PRD_END_DATE,'YYYY-MM-DD'), TO_CHAR(V_PRD_END_DATE,'HH24:MI:SS'),
                                    V_DOC_NO_SCR, V_DOC_SEQNO_SCR,
                                    V_DATE, P_USERID, V_TM, V_VBELN, V_POSNR, V_SAP_WRK_CD, 0, 0);

                 -- 생산폐품 문서이력
                 -- 1=실적, 2=생산폐품, 3=영업폐품, 4=잔량폐품, 5=투입자재 소요량, 6=재고이전(위치), 7=재고이전(자재변경), 8=재고이전(재고실사), 9=LOT변경, 10=등급변경, 11=LOT병합, 12=LIFT출고, 20=오더완료
                INSERT INTO TB_WRK021(DOC_NO, DOC_SEQNO, DOC_DIV, WERKS, MACH_CD,
                                    WRK_ORDR_NO, WRK_ORDR_SEQNO, IND_BCD, LOT_NO, ORDER_NO,
                                    CNL_YN, REGDATE, REGID)
                            VALUES(V_DOC_NO_SCR, V_DOC_SEQNO_SCR, 2, P_WERKS, P_MACH_CD,
                                    V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_IND_BCD, V_LOT_NO, V_ORDER_NO,
                                    'N', V_DATE, P_USERID);           

                UPDATE TB_INV003
                   SET DISPO_QTY = NVL(DISPO_QTY, 0) + V_DISPO_WGT,
                       USE_QTY   = NVL(USE_QTY, 0)   + V_DISPO_WGT,
                       STCK_QTY  = NVL(STCK_QTY, 0)  - V_DISPO_WGT
                 WHERE WERKS = P_WERKS
                   AND MACH_CD = P_MACH_CD
                   AND IND_BCD = V_IND_BCD_M;

            END IF;

            SELECT  SCH015.WRK_ORDR_NO  ,  SCH015.WRK_ORDR_SEQNO
                  INTO V_WRK_ORDR_NO_M, V_WRK_ORDR_SEQNO_M  --점보롤 작업지시번호 작업지시번호순번
                  FROM TB_SCH016  SCH016 
                     , TB_SCH015  SCH015 
            WHERE SCH016.PRE_ORDER_NO   =  SCH015.ORDER_NO
              AND SCH016.WRK_ORDR_NO     = V_WRK_ORDR_NO
              AND SCH016.WRK_ORDR_SEQNO  = V_WRK_ORDR_SEQNO
              --AND NVL(SCH016.DLFL,'N') = 'N'  --삭제지시자 X='삭제' , N=정상오더
              --AND NVL(SCH015.DLFL,'N')= 'N'  --삭제지시자 X='삭제' , N=정상오더
              AND NVL(SCH016.USE_YN, 'Y') = 'Y'
              AND NVL(SCH015.USE_YN, 'Y') = 'Y'
              AND ROWNUM = 1
                 ;

            --실적등록
            IF NVL(V_ROLLCNT, 0) > 0 THEN
                --문서번호
                V_DOC_NO := FN_GET_MDOCNO('M','IF126');
                V_DOC_SEQNO := V_DOC_SEQNO + 1;

                INSERT INTO TB_WRK002( WERKS, MACH_CD, IND_BCD, LOT_NO, MATNR, ORDER_NO, WRK_ORDR_NO, WRK_ORDR_SEQNO, PRD_NO,
                                    UNIT, PRFM_QTY, WIDTH, ROLLCNT, WGT, CORE, WIDTH_NO, MRLDCK, CUTTER, MER_YN, GRD_YN,
                                    PRD_STR_DATE, PRD_END_DATE, TM, 
                                    PRFM_DT, PRD_DT, DSTBT_DDLIN, WRK_CLASS, WRK_SHIFT, MACHINE, TO_MACHINE, STA, RUN_STA,
                                    DOC_NO, DOC_SEQNO, RMK, REGDATE, REGID, VBELN, POSNR, KUNNR, WRK_SEQ, PRD_SEQ, PRFM_GTHR_YN, PACKTYPE,
                                    JRCOM_YN, MRCOM_YN,UPDDATE
                                    )
                            VALUES( P_WERKS, P_MACH_CD, V_IND_BCD, V_LOT_NO, V_MATNR, V_ORDER_NO, V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_PRD_NO,
                                    V_UNIT, V_WGT, V_WIDTH, V_ROLLCNT, V_WGT, V_CORE, V_WIDTH_NO, V_MRLDCK, V_CUTTER, 'N', 'N',
                                    V_PRD_STR_DATE, V_PRD_END_DATE, V_TM,
                                    V_PRFM_DT, V_PRD_DT, V_DSTBT_DDLIN, P_WRK_CLASS, P_WRK_SHIFT, V_MACHINE, V_TO_MACHINE, '00', '01',
                                    V_DOC_NO, V_DOC_SEQNO, V_RMK, V_DATE, P_USERID, V_VBELN, V_POSNR, V_KUNNR, V_WRK_SEQ, V_PRD_SEQ, V_PRFM_GTHR_YN,V_PACKTYPE,
                                    V_JRCOM_YN, V_MRCOM_YN,V_DATE
                );

                --I/F 테이블 등록
                /*IF NVL(V_ROLLCNT, 0) > 0 AND V_PRFM_GTHR_YN = 'Y' THEN 
                    V_DOC_NO_PRFM := V_DOC_NO_PRFM || V_DOC_NO||',' ;      

                    IF  V_MRCOM_YN = 'Y' THEN
                    
                        SELECT MIN(W002.PRD_STR_DATE)
                          INTO V_PRD_STR_DATE
                          FROM TB_WRK002     W002
                         WHERE 1=1
                           AND W002.WRK_ORDR_NO     = V_WRK_ORDR_NO
                           AND W002.WRK_ORDR_SEQNO  = V_WRK_ORDR_SEQNO
                           AND NVL(W002.CNL_YN,'N')  = 'N'
                         ;  

                    END IF ;
                   
                    
                    INSERT INTO TB_IFS004(AUFNR, MRLOT, WERKS, WORKCENTERCODE, BUDAT, MACHINE, WORKGROUP,
                                         MROLLCNT, MRSCRCNT, RBRGEW, CORESIZE,
                                         REWINDER, MRUNTIME, CONFM, CONFJ, MSDATE, MSTIME, MEDATE, METIME,
                                         MDOCNO, MDOCSEQ, MAKE_DATE, MAKER, JRLOT)
                                VALUES( V_ORDER_NO
                                      , V_LOT_NO
                                      , P_WERKS
                                      , V_SAP_WRK_CD
                                      , TO_CHAR(TO_DATE(V_PRFM_DT, 'YYYYMMDD'), 'YYYYMMDD')
                                      , V_MACHINE
                                      , P_WRK_CLASS
                                      , V_ROLLCNT
                                      , V_WGT_RMD
                                      , V_WGT
                                      , V_CORE||' 인치'
                                      ,TO_CHAR(V_LINE)
                                      , TO_CHAR(V_TM) 
                                      , (CASE WHEN V_MRCOM_YN = 'Y' THEN 'X' ELSE '' END)
                                      , (CASE WHEN V_JRCOM_YN = 'Y' THEN 'X' ELSE '' END),   -- SAP 에 마지막생산 전송시 'Y'를 'X', 아닌경우는 빈값으로 전송
                                      --  TO_CHAR(TO_DATE(V_ORD_PRD_STR_DTM, 'YYYY-MM-DD HH24:MI:SS'),'YYYY-MM-DD')
                                      --, TO_CHAR(TO_DATE(V_ORD_PRD_STR_DTM, 'YYYY-MM-DD HH24:MI:SS'),'HH24:MI:SS')
                                        TO_CHAR(V_PRD_STR_DATE,'YYYY-MM-DD')
                                      , TO_CHAR(V_PRD_STR_DATE,'HH24:MI:SS')
                                      , TO_CHAR(V_PRD_END_DATE,'YYYY-MM-DD')
                                      , TO_CHAR(V_PRD_END_DATE,'HH24:MI:SS')
                                      , V_DOC_NO
                                      , V_DOC_SEQNO
                                      , V_DATE
                                      , P_USERID
                                      , V_LOT_NO_M);

                 END IF;

                 -- 실적 문서이력
                 -- 1=실적, 2=생산폐품, 3=영업폐품, 4=잔량폐품, 5=투입자재 소요량, 6=재고이전(위치), 7=재고이전(자재변경), 8=재고이전(재고실사), 9=LOT변경, 10=등급변경, 11=LOT병합, 12=LIFT출고, 20=오더완료
                 INSERT INTO TB_WRK021(DOC_NO, DOC_SEQNO, DOC_DIV, WERKS, MACH_CD,
                                WRK_ORDR_NO, WRK_ORDR_SEQNO, IND_BCD, LOT_NO, ORDER_NO,
                                CNL_YN, REGDATE, REGID)
                        VALUES(V_DOC_NO, V_DOC_SEQNO, 1, P_WERKS, P_MACH_CD,
                                V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_IND_BCD, V_LOT_NO, V_ORDER_NO,
                                'N', V_DATE, P_USERID);      

                --재고등록
                INSERT INTO TB_INV001( WERKS, STOR_LOC_CD, IND_BCD, MATNR, LOC_CD, LOT_NO,
                                    MACH_CD, MACHINE, WRK_ORDR_NO, WRK_ORDR_SEQNO, ORDER_NO,
                                    PRD_NO, IN_MR_YN, PRD_DT, UNIT, STCK_QTY, ROLLCNT, WGT, STCK_STA,
                                    DOC_NO, DOC_SEQNO, DLFL, REGDATE, REGID,VBELN,POSNR,KUNNR)
                    VALUES( P_WERKS, V_STOR_LOC_CD, V_IND_BCD, V_MATNR, V_LOC_CD, V_LOT_NO,
                                    P_MACH_CD, V_MACHINE, V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_ORDER_NO, 
                                    '', 'N', V_PRD_DT, V_UNIT, V_WGT, V_ROLLCNT, V_WGT, '00',
                                    V_DOC_NO, V_DOC_SEQNO, 'N', V_DATE, P_USERID,V_VBELN,V_POSNR,V_KUNNR);

                --자재소요량
                UPDATE TB_INV003
                   SET USE_QTY = NVL(USE_QTY, 0) + V_WGT,
                        STCK_QTY = NVL(STCK_QTY, 0) - V_WGT
                 WHERE WERKS = P_WERKS
                   AND MACH_CD = P_MACH_CD
                   AND IND_BCD = V_IND_BCD_M;

                V_DOC_NO := FN_GET_MDOCNO('M','IF130'); 
                V_DOC_SEQNO1 := V_DOC_SEQNO1 + 1; 

                IF V_PRFM_GTHR_YN = 'Y' THEN
                    V_DOC_NO_INPUT := V_DOC_NO_INPUT||V_DOC_NO||',' ;
                END IF;

                --자재 투입이력
                INSERT INTO TB_INV010( WERKS, MACH_CD, MATNR, IND_BCD, SEQNO, WRK_ORDR_NO, WRK_ORDR_SEQNO,
                                    LOT_NO, IND_BCD_M, LOT_NO_M, MATNR_M, INP_DT, PRFM_DT,
                                    USE_QTY, UNIT, ROLLCNT, WGT, CHG_FLG, STCK_KY, LOT_NUM,
                                    REGDATE, REGID, USE_DIV, DOC_NO, DOC_SEQNO) 
                            VALUES(P_WERKS, P_MACH_CD, V_MATNR, V_IND_BCD, 1, V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO,
                                    V_LOT_NO, V_IND_BCD_M, V_LOT_NO_M, V_MATNR_M, V_PRD_DT, V_PRFM_DT,
                                    V_WGT, V_UNIT, V_ROLLCNT, V_WGT, 'N', '', '', 
                                    V_DATE, P_USERID, '1', V_DOC_NO, V_DOC_SEQNO1);   

                --자재투입이력 전송
                SELECT SAP_WRK_CD, LINE_NM  INTO V_SAP_WRK_CD, V_LINE_NM
                  FROM TB_MAS012
                 WHERE MACH_CD = P_MACH_CD;

                BEGIN                    
                    SELECT ORDER_ITM_NO INTO V_ORDER_ITM_NO
                      FROM TB_SCH020
                     WHERE WERKS = P_WERKS
                       AND WRK_ORDR_NO = V_WRK_ORDR_NO
                       AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO
                       AND MATNR = V_MATNR_M
                       ;
                EXCEPTION WHEN NO_DATA_FOUND THEN
                    V_ORDER_ITM_NO := ' ';
                END;

                --오더별 자재투입량 전송
--                IF V_PRFM_GTHR_YN = 'Y' THEN
                    INSERT INTO TB_IFS008(AUFNR, POSNR, BUDAT, MATNR, MENGE, LGORT, CHARG,
                                        MDOCNO, MDOCSEQ, MAKE_DATE, MAKER, WORKCENTERCODE, WERKS)
                                VALUES( V_ORDER_NO, V_ORDER_ITM_NO, V_PRFM_DT, V_MATNR_M, V_WGT, V_STOR_LOC_CD_M, V_LOT_NO_M,
                                        V_DOC_NO, V_DOC_SEQNO1, V_DATE, P_USERID, V_SAP_WRK_CD, P_WERKS);
--                ELSE
--                    INSERT INTO TB_IFS008_TMP(IND_BCD, AUFNR, POSNR, BUDAT, MATNR, MENGE, LGORT, CHARG,
--                                        MDOCNO, MDOCSEQ, MAKE_DATE, MAKER, WORKCENTERCODE, WERKS)
--                                VALUES( V_IND_BCD, V_ORDER_NO, V_ORDER_ITM_NO, V_PRFM_DT, V_MATNR_M, V_WGT, V_STOR_LOC_CD_M, V_LOT_NO_M,
--                                        V_DOC_NO, V_DOC_SEQNO1, V_DATE, P_USERID, V_SAP_WRK_CD, P_WERKS);
--                END IF;

                 -- 투입자재 소요량 문서이력
                 -- 1=실적, 2=생산폐품, 3=영업폐품, 4=잔량폐품, 5=투입자재 소요량, 6=재고이전(위치), 7=재고이전(자재변경), 8=재고이전(재고실사), 9=LOT변경, 10=등급변경, 11=LOT병합, 12=LIFT출고, 20=오더완료
                INSERT INTO TB_WRK021(DOC_NO, DOC_SEQNO, DOC_DIV, WERKS, MACH_CD,
                                    WRK_ORDR_NO, WRK_ORDR_SEQNO, IND_BCD, LOT_NO, ORDER_NO,
                                    CNL_YN, REGDATE, REGID)
                            VALUES(V_DOC_NO, V_DOC_SEQNO1, 5, P_WERKS, P_MACH_CD,
                                    V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_IND_BCD, V_LOT_NO, V_ORDER_NO,
                                    'N', V_DATE, P_USERID);              

                INSERT INTO TB_WRK008(WERKS,
                                    IND_BCD,
                                    IND_BCD_M,
                                    SEQNO,
                                    LOT_NO,
                                    MATNR,
                                    LOT_NO_M,
                                    MATNR_M,
                                    UNIT,
                                    PRFM_QTY,
                                    USE_QTY,
                                    WRK_ORDR_NO,
                                    WRK_ORDR_SEQNO,
                                    SUB_WRK_ORDR_NO,
                                    SUB_WRK_ORDR_SEQNO,
                                    MACH_CD,
                                    REGDATE,
                                    REGID)
                           VALUES(P_WERKS,
                                    V_IND_BCD,
                                    V_IND_BCD_M,
                                    1,
                                    V_LOT_NO,
                                    V_MATNR,
                                    V_LOT_NO_M,
                                    V_MATNR_M,
                                    V_UNIT,
                                    V_WGT,
                                    V_WGT,
                                    V_WRK_ORDR_NO,
                                    V_WRK_ORDR_SEQNO,
                                    V_WRK_ORDR_NO_M,
                                    V_WRK_ORDR_SEQNO_M,
                                    P_MACH_CD,
                                    V_DATE,
                                    P_USERID);*/
            END  IF;

            --WCS 인터페이스 등록(모든 실적은 WCS로 전송)
            /*IF NVL(V_ROLLCNT, 0) > 0 THEN   --AND V_PRFM_GTHR_YN = 'Y' AND V_SHEET = 'Y' THEN
                IF V_SHEET = 'Y' THEN
                    BEGIN
                    SELECT IND_BCD INTO V_IND_BCD_PRE
                      FROM TB_WRK002
                     WHERE WERKS = P_WERKS
                       AND ORDER_NO = V_ORDER_NO
                       AND NVL(CNL_YN, 'N') = 'Y'
                       AND ROWNUM = 1;
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            V_IND_BCD_PRE := ' ';
                            --V_REPROD_YN := 'N';
                    END;

                    IF  NVL(V_IND_BCD_PRE, ' ') = ' ' THEN
                        V_REPROD_YN := 'N';
                    ELSE
                        V_REPROD_YN := 'Y';
                    END IF;
                ELSE
                    V_REPROD_YN := 'N';
                    V_IND_BCD_PRE := '';
                END IF;

                V_DOC_NO_WCS := FN_GET_MDOCNO('M','IF405');
                V_DOC_SEQNO_WCS := 1; 
                V_ORDER_RMK := REPLACE(V_ORDER_RMK, CHR(39),'`');
                
                V_LINE_NM2 := CASE WHEN INSTR(V_LINE_NM, '-') > 0 THEN SUBSTR(V_LINE_NM, INSTR(V_LINE_NM, '-') + 1, 1) ELSE '' END;
                
                IF NVL(V_LINE_NM2, ' ') = ' ' THEN
                    V_MMACHINE := V_MACHINE;
                ELSE
                    V_MMACHINE := V_MACHINE || '-' || V_LINE_NM2;
                END IF;
                
                INSERT INTO TB_IFSWC004(DOC_NO, DOC_NOSEQ, IND_BCD, LOT_NO, JRLOT_NO, WERKS, MACH_NO, PROC_CD, FCLT_CD,
                                     ORDER_NO, ORDER_NO_SEQ, PRFM_DT, PROD_SEQ, PROD_DT, WORK_GRP, SAT,
                                     MTART, PCODE, PCODE_NM, RELIMP, STD_SIZE, PAPER_BT, PAPER_BT_REAL,
                                     WEIGHT, LENGTH, SHEET_YN, SLITTER_YN, PACKING_TP_NM,
                                     JR_MCHN_CD, MR_MCHN_CD, CT_MCHN_CD, WRKORD, SPECIAL_NO,
                                     BCNC_CD, BCNC_NM, EXPORT_EXT, VOYAGE, CNTRY_NM, REAM_PER_PALLET, NMRS_IN_BUNDLE,
                                     BUNDLE_CNT, ZPPCOD, CORE_SIZE, BT_SEQ, USER_ID, USER_NM,
                                     WORK_DRCT, PRD_RMK1, MR_STK_YN, PLAN_CT_NO, REPROD_YN, PRE_BARCODE, CRAT_DATE,
                                     CRAT_ID, REMARK1, REMARK2, REMARK3, REMARK4, REMARK5, REMARK6, REMARK7, REMARK8, REMARK9, REMARK10)
                             VALUES( V_DOC_NO_WCS, V_DOC_SEQNO_WCS, V_IND_BCD, V_LOT_NO, V_LOT_NO_M, P_WERKS, V_MACHINE, 'M', V_WCS_WRK_CD,
                                    V_ORDER_NUM, V_ORDER_SEQ, V_PRFM_DT, V_WRK_SEQ, V_PRD_DT, P_WRK_CLASS, '0',
                                    V_MATNR, V_PCODE, V_PCODE_NM, V_BS_WGT, V_SIZE, V_MWIDTH, V_WIDTH, 
                                    V_WGT, V_ROLLCNT, V_SHEET, V_SLITER, V_PACKTYPE_NM,
                                    V_JMACHINE, V_MMACHINE, V_TO_MACHINE, V_ORDER_NO, V_SPECIAL_NO,
                                    V_KUNNR, SUBSTRB(V_KUNNRT, 1, 50), '', SUBSTRB(V_ROUTE, 1, 40), SUBSTRB(V_NTN_NM, 1, 20), TO_CHAR(V_PLT_PER_CNT), V_IN_PER_CNT ,    -- V_KUNNRT 문자열 50바이트 까지만 잘라서 전달
                                    V_IN_CNT, ' ', V_CORE || ' 인치', NVL(V_WIDTH_NO, '-'), P_USERID, V_USER_NM,
                                    NVL(V_ORDER_RMK, ' '), NVL(V_RMK, ' '), V_MRLDCK, V_WCS_WRK_CD_C, V_REPROD_YN, V_IND_BCD_PRE, V_DATE,
                                    P_USERID, ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ');
            END IF;

            IF i = 0 THEN
                RS_IND_BCD := V_IND_BCD;    -- 개별 바코드 구분자 로 여러개 전달
            ELSE
                RS_IND_BCD := RS_IND_BCD  || '|' || V_IND_BCD;    -- 개별 바코드 구분자 로 여러개 전달
            END IF;*/
         END LOOP;

         --잔량 폐품 등록
        /* IF V_JRCOM_YN = 'Y' THEN
             -- 실적없이 폐품만 있는경우 0 실적등록 하여 완료플래그 전달
             IF NVL(V_ROLLCNT, 0) = 0  AND NVL(V_DISPO_ROLLCNT, 0) > 0 THEN
                --문서번호
                V_DOC_NO := FN_GET_MDOCNO('M','IF126');
                V_DOC_SEQNO := V_DOC_SEQNO + 1;
                V_DOC_NO_PRFM := V_DOC_NO_PRFM || V_DOC_NO||',' ;      

                INSERT INTO TB_IFS004(AUFNR, MRLOT, WERKS, WORKCENTERCODE, BUDAT, MACHINE, WORKGROUP,
                                         MROLLCNT, MRSCRCNT, RBRGEW, CORESIZE,
                                         REWINDER, MRUNTIME, CONFM, CONFJ, MSDATE, MSTIME, MEDATE, METIME,
                                         MDOCNO, MDOCSEQ, MAKE_DATE, MAKER, JRLOT)
                                VALUES( V_ORDER_NO
                                      , V_LOT_NO
                                      , P_WERKS
                                      , V_SAP_WRK_CD
                                      , TO_CHAR(TO_DATE(V_PRFM_DT, 'YYYYMMDD'), 'YYYYMMDD')
                                      , V_MACHINE
                                      , P_WRK_CLASS
                                      , 0
                                      , 0
                                      , 0
                                      , V_CORE||' 인치'
                                      , TO_CHAR(V_LINE)
                                      , TO_CHAR(V_TM) 
                                      , (CASE WHEN V_MRCOM_YN = 'Y' THEN 'X' ELSE '' END)
                                      , (CASE WHEN V_JRCOM_YN = 'Y' THEN 'X' ELSE '' END)   -- SAP 에 마지막생산 전송시 'Y'를 'X', 아닌경우는 빈값으로 전송
                                      , TO_CHAR(V_PRD_STR_DATE,'YYYY-MM-DD')
                                      , TO_CHAR(V_PRD_STR_DATE,'HH24:MI:SS')
                                      , TO_CHAR(V_PRD_END_DATE,'YYYY-MM-DD')
                                      , TO_CHAR(V_PRD_END_DATE,'HH24:MI:SS')
                                      , V_DOC_NO
                                      , V_DOC_SEQNO
                                      , V_DATE
                                      , P_USERID
                                      , V_LOT_NO_M);

             END IF ;

             SELECT ORDER_NO INTO V_ORDER_NO_M
                  FROM TB_SCH015
                 WHERE WERKS            = P_WERKS
                   AND WRK_ORDR_NO      = V_WRK_ORDR_NO_M
                   AND WRK_ORDR_SEQNO   = V_WRK_ORDR_SEQNO_M
                   --AND NVL(DLFL,'N') = 'N'  --삭제지시자 X='삭제' , N=정상오더
                   AND NVL(USE_YN, 'Y') = 'Y'
               ;    

            --점보롤 생산실적
            V_WGT_M := 0 ;
            BEGIN               
                SELECT NVL(SUM(PRFM_QTY), 0)  INTO V_WGT_M					
                  FROM TB_WRK002
                 WHERE WERKS            = P_WERKS
                   AND WRK_ORDR_NO      = V_WRK_ORDR_NO_M
                   AND WRK_ORDR_SEQNO   = V_WRK_ORDR_SEQNO_M
                   AND NVL(CNL_YN,'N')  = 'N'
                   AND RUN_STA IN ( '01','09')
                   --AND STA = '10'
               ;    
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    V_WGT_M := 0;
                WHEN OTHERS THEN
                    V_WGT_M := 0;
            END;

            --밀롤 생산실적
            V_WGT := 0 ;
            BEGIN       
                SELECT NVL(SUM(W002.PRFM_QTY), 0) INTO V_WGT
                       FROM TB_WRK002     W002
                          , TB_SCH016     S016
                        WHERE 1=1
                        AND S016.WRK_ORDR_NO = W002.WRK_ORDR_NO(+)
                        AND S016.WRK_ORDR_SEQNO = W002.WRK_ORDR_SEQNO(+)
                        AND S016.PRE_ORDER_NO = V_ORDER_NO_M
                        AND NVL(CNL_YN,'N')  = 'N'
                        AND NVL(S016.USE_YN,'Y') = 'Y'
                        --AND NVL(S016.DLFL,'N')= 'N'  --삭제지시자 X='삭제' , N=정상오더
                        ;   
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    V_WGT := 0;
                WHEN OTHERS THEN
                    V_WGT := 0;
            END;

            --밀롤폐품실적
            V_DISPO_QTY := 0 ;
            BEGIN               
                SELECT NVL(SUM(W004.DISPO_QTY), 0) INTO V_DISPO_QTY
                       FROM TB_WRK004     W004
                          , TB_SCH016     S016
                        WHERE 1=1
                        AND S016.WRK_ORDR_NO = W004.WRK_ORDR_NO(+)
                        AND S016.WRK_ORDR_SEQNO = W004.WRK_ORDR_SEQNO(+)
                        AND S016.PRE_ORDER_NO = V_ORDER_NO_M
                        AND NVL(CNL_YN,'N')  = 'N'
                        AND NVL(S016.DLFL,'N') = 'N'  --삭제지시자 X='삭제' , N=정상오더
                        AND NVL(S016.USE_YN, 'Y') = 'Y'
                        ;   
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    V_DISPO_QTY := 0;
                WHEN OTHERS THEN
                    V_DISPO_QTY := 0;
            END;

            V_WGT_RMD := V_WGT_M -  V_WGT - V_DISPO_QTY;

              --  RS_CODE := 'E';
              --  RS_MSG := '확인하세요.'||' 점보롤 생산실적 '||TO_CHAR(V_WGT_M)||' 밀롤 생산실적 '||TO_CHAR(V_WGT)||' 밀롤 폐품실적 '||TO_CHAR(V_DISPO_QTY)||' 잔량 '||TO_CHAR(V_WGT_RMD);
              --  ROLLBACK;
              --  RETURN;

            V_DOC_NO_SCR    := FN_GET_MDOCNO('M','IF134');
            V_DOC_SEQNO_SCR := V_DOC_SEQNO_SCR + 1;

            IF V_PRFM_GTHR_YN = 'Y' THEN
                V_DOC_NO_SDISPO := V_DOC_NO_SDISPO || V_DOC_NO_SCR||',';
                INSERT INTO TB_IFS012( AUFNR, LOTNO, BUDAT, MATNR, SCRQTY, RSDQTY, SCRAPCODE, SCRAPREASON,
                                         LGORT, CHARG,
                                         SDATE, STIME, EDATE, ETIME, MDOCNO, MDOCSEQ, 
                                         MAKE_DATE, MAKER, RUNTIME, VBELN, POSNR, WORKCENTERCODE, MRSCQTY, SCRQTY_OP)
                                VALUES( V_ORDER_NO, V_LOT_NO, TO_CHAR(TO_DATE(V_PRFM_DT, 'YYYYMMDD'), 'YYYYMMDD'), V_MATNR_M, 0, V_WGT_RMD,  '910', '잔량폐품',
                                        V_STOR_LOC_CD_M, V_LOT_NO_M,
                                        '', '', '', '', V_DOC_NO_SCR, V_DOC_SEQNO_SCR,
                                        V_DATE, P_USERID, 0, V_VBELN, V_POSNR, V_SAP_WRK_CD, 0, 0);  
            END IF;

            INSERT INTO TB_WRK022(WERKS, MACH_CD, IND_BCD, LOT_NO, MATNR, DISPO_CD, WRK_ORDR_NO, WRK_ORDR_SEQNO,
                                  ORDER_NO, MATNR_M, IND_BCD_M, LOT_NO_M, UNIT, ROLLCNT, DISPO_QTY, MACHINE, WGT,
                                  PRFM_DT, WRK_CLASS, WRK_SHIFT, RUN_STA, DOC_NO, DOC_SEQNO, RMK, REGDATE, REGID,PRE_ORDER_NO)
                         VALUES( P_WERKS, P_MACH_CD, V_IND_BCD, V_LOT_NO, V_MATNR, '910', V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO,
                                 V_ORDER_NO, V_MATNR_M, V_IND_BCD_M, V_LOT_NO_M, V_UNIT, 0, V_WGT_RMD, '', V_WGT_RMD,
                                 V_PRFM_DT,P_WRK_CLASS, P_WRK_SHIFT, '02', V_DOC_NO_SCR, V_DOC_SEQNO_SCR, V_RMK, V_DATE, P_USERID,V_ORDER_NO_M);
            --문서이력
            -- 1=실적, 2=생산폐품, 3=영업폐품, 4=잔량폐품, 5=투입자재 소요량, 6=재고이전(위치), 7=재고이전(자재변경), 8=재고이전(재고실사), 9=LOT변경, 10=등급변경, 11=LOT병합, 12=LIFT출고, 20=오더완료
            INSERT INTO TB_WRK021(DOC_NO, DOC_SEQNO, DOC_DIV, WERKS, MACH_CD, WRK_ORDR_NO, WRK_ORDR_SEQNO,
                                IND_BCD, LOT_NO, ORDER_NO, CNL_YN, REGDATE, REGID)
                        VALUES(V_DOC_NO_SCR, V_DOC_SEQNO_SCR, 4, P_WERKS, P_MACH_CD, V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO,
                                V_IND_BCD, V_LOT_NO, V_ORDER_NO, 'N', V_DATE, P_USERID);                               
         END IF;*/

         -- 점보롤 작업완료 플래그 처리 
        /* IF V_JRCOM_YN = 'Y' THEN
                SELECT WRK_ORDR_NO, WRK_ORDR_SEQNO  --, ORDER_NO, MATNR, WRK_CLASS, WRK_SHIFT, LOT_NO, NVL(RUN_STA, '01') RUN_STA
                    INTO V_JR_WRK_ORDR_NO, V_JR_WRK_ORDR_SEQNO  --, V_ORDER_NO, V_MATNR, V_WRK_CLASS, V_WRK_SHIFT, V_LOT_NO, V_RUN_STA_PRE
                  FROM TB_WRK011
                WHERE MACH_CD = P_MACH_CD; 
    
                -- 점보롤 완료인경우 TB_WRK011(작업장(설비)별 현재 진행현황) 테이블 업데이트 진행
                -- 작업진행중인 작업지시번호 -> 이전작업지시번호, 작업지시순번 -> 이전작업지시순번으로 이동
                -- 자재번호, 작업지시번호, 작업지시순번 삭제
                UPDATE TB_WRK011
                    SET 
                        MATNR = ''
                        ,WRK_ORDR_NO = ''
                        ,WRK_ORDR_SEQNO = ''
                        ,ORDER_NO = ''
                        ,LOT_NO = ''
                        ,PRD_STR_DTM = V_PRD_END_DTM
                        ,MACH_STA = 'N'
                WHERE MACH_CD = P_MACH_CD; 
        ELSE
                UPDATE TB_WRK011
                    SET PRD_STR_DTM = V_PRD_END_DTM
                WHERE MACH_CD = P_MACH_CD; 
        END IF;

        V_DOC_NO_DISPO     := SUBSTR(V_DOC_NO_DISPO, 1,LENGTH(V_DOC_NO_DISPO)-1);
        V_DOC_NO_PRFM      := SUBSTR(V_DOC_NO_PRFM, 1,LENGTH(V_DOC_NO_PRFM)-1);
        V_DOC_NO_INPUT     := SUBSTR(V_DOC_NO_INPUT, 1,LENGTH(V_DOC_NO_INPUT)-1);
        V_DOC_NO_SDISPO    := SUBSTR(V_DOC_NO_SDISPO, 1,LENGTH(V_DOC_NO_SDISPO)-1);

        IF LENGTH(V_DOC_NO_DISPO) > 0   THEN   --폐품
                 --SAP FUNC ID
                 SELECT RFCFN
                   INTO RS_DISPO_RFCFN
                   FROM TB_ITFMA
                  WHERE 1=1
                    AND IFID = 'MES_IF_134';   --생산오더별 실적 취소 TXN

                 --인터페이스 파라미터
                 OPEN CUR_3 FOR
                 SELECT 'MES_IF_134' AS I_IF_ID
                      , 'M' || LTRIM(RTRIM(TO_CHAR(SEQ_GET_IFR_KEY.NEXTVAL, '00000000000000000000000000000'))) AS I_IF_KEY
                   FROM dual;

                 --인터페이스 상세 파라미터
                 V_SQL := FN_IF_QUERY('MES_IF_134', V_DOC_NO_DISPO );
                 OPEN CUR_4 FOR V_SQL;

        END IF ;  

        IF LENGTH(V_DOC_NO_PRFM) > 0   THEN   --실적

                 --SAP FUNC ID
                 SELECT RFCFN
                   INTO RS_PRFM_RFCFN
                   FROM TB_ITFMA
                  WHERE 1=1
                    AND IFID = 'MES_IF_126';   --생산오더별 실적 취소 TXN

                 --인터페이스 파라미터
                 OPEN CUR_1 FOR
                 SELECT 'MES_IF_126' AS I_IF_ID
                      , 'M' || LTRIM(RTRIM(TO_CHAR(SEQ_GET_IFR_KEY.NEXTVAL, '00000000000000000000000000000'))) AS I_IF_KEY
                   FROM dual;

                 --인터페이스 상세 파라미터
                 V_SQL := FN_IF_QUERY('MES_IF_126', V_DOC_NO_PRFM);
                 OPEN CUR_2 FOR V_SQL;

        END IF ;  

        IF LENGTH(V_DOC_NO_INPUT) > 0   THEN   --투입량

                     --SAP FUNC ID
                     SELECT RFCFN
                       INTO RS_INPUT_RFCFN
                       FROM TB_ITFMA
                      WHERE 1=1
                        AND IFID = 'MES_IF_130';   --생산오더별 실적 취소 TXN

                     --인터페이스 파라미터
                     OPEN CUR_5 FOR
                     SELECT 'MES_IF_130' AS I_IF_ID
                          , 'M' || LTRIM(RTRIM(TO_CHAR(SEQ_GET_IFR_KEY.NEXTVAL, '00000000000000000000000000000'))) AS I_IF_KEY
                       FROM dual;

                     --인터페이스 상세 파라미터
                     V_SQL := FN_IF_QUERY('MES_IF_130', V_DOC_NO_INPUT);
                     OPEN CUR_6 FOR V_SQL;

        END IF ;  

        IF LENGTH(V_DOC_NO_SDISPO) > 0   THEN    --영업폐품
            --SAP FUNC ID
            SELECT RFCFN
              INTO RS_SDISPO_RFCFN
              FROM TB_ITFMA
             WHERE 1=1
               AND IFID = 'MES_IF_134';   --생산오더별 실적 취소 TXN

            --인터페이스 파라미터
            OPEN CUR_7 FOR
            SELECT 'MES_IF_134' AS I_IF_ID
                 , 'M' || LTRIM(RTRIM(TO_CHAR(SEQ_GET_IFR_KEY.NEXTVAL, '00000000000000000000000000000'))) AS I_IF_KEY
              FROM dual;

            --인터페이스 상세 파라미터
            V_SQL := FN_IF_QUERY('MES_IF_134', V_DOC_NO_SDISPO);
            OPEN CUR_8 FOR V_SQL;
        END IF ;  */

        IF CUR_1%ISOPEN = FALSE THEN
            OPEN CUR_1 FOR SELECT 1 FROM dual;
        END IF;

        IF CUR_2%ISOPEN = FALSE THEN
            OPEN CUR_2 FOR SELECT 1 FROM dual;
        END IF;

        IF CUR_3%ISOPEN = FALSE THEN
            OPEN CUR_3 FOR SELECT 1 FROM dual;
        END IF;

        IF CUR_4%ISOPEN = FALSE THEN
            OPEN CUR_4 FOR SELECT 1 FROM dual;
        END IF;

        IF CUR_5%ISOPEN = FALSE THEN
            OPEN CUR_5 FOR SELECT 1 FROM dual;
        END IF;

        IF CUR_6%ISOPEN = FALSE THEN
            OPEN CUR_6 FOR SELECT 1 FROM dual;
        END IF;

        IF CUR_7%ISOPEN = FALSE THEN
            OPEN CUR_7 FOR SELECT 1 FROM dual;
        END IF;

        IF CUR_8%ISOPEN = FALSE THEN
            OPEN CUR_8 FOR SELECT 1 FROM dual;
        END IF;

        RS_CODE := 'S';
        COMMIT;      --개별바코드 중복 오류로 인해서 프로시져에서 COMMIT 처리함
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
        E_SQL_ERR_CD        := SQLCODE;
        E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

        ROLLBACK;

        RAISE;
        --RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);

        RS_CODE := 'E';
        RS_MSG  := SQLERRM;
        RETURN;
       --예외처리 종료
    END;
END;

/
