--------------------------------------------------------
--  DDL for Procedure SP_POP_WRK83_I01
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK83_I01" 
(
    P_WERKS          IN     VARCHAR2 	            ,        --플랜트    
    P_MACH_CD        IN     VARCHAR2 	            ,        --설비코드    
    P_WRK_ORDR_NO    IN     VARCHAR2                ,        --재단작업지시번호    
    P_WRK_ORDR_SEQNO IN     NUMBER                  ,        --재단작업지시번호순번
    P_WRK_LIST       IN     CLOB                    ,
    P_WRK_CLASS      IN     VARCHAR2                ,
    P_WRK_SHIFT      IN     VARCHAR2                ,
    P_USERID         IN     VARCHAR2                ,        --USER ID    
    RS_PRFM_RFCFN    OUT    VARCHAR2                ,        --실적 RFCFN값
    RS_IND_BCD       OUT    VARCHAR2                ,        --개별바코드    
    LANG             IN     VARCHAR2 DEFAULT 'KO'   ,
    RS_CODE          OUT    VARCHAR2                ,
    RS_MSG           OUT    VARCHAR2                ,
    CUR_1            OUT    SYS_REFCURSOR           ,        --실적
    CUR_2            OUT    SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : SP_POP_WRK83_I01{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 여유 실적등록
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 여유 실적등록
 *                 
 * AUTHOR NAME   : 유상호{최초 작성자 명 기술}
 * CREATE DATE   : 2022/05/24 {최초 작성일자 기술}
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    DATE        VER       NAME          DESCRIPTION      
 * ------------ ------- ------------- ------------------------------------------
 * YYYY/MM/DD    1.0.0   유상호         INITIAL VERSION 
 *==============================================================================
 *  관련 테이블
 *       - [TB_WRK011] : (..U.) 설비별 현재진행사항                            
 *=============================================================================*/
 AS 
    --프로그램 ID : 여유 실적등록
    V_PRG_NM            VARCHAR2(100) := 'SP_POP_WRK83_I01';     -- PROCEDURE NAME
    V_PLT_CD            VARCHAR2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID      VARCHAR2(20) := 'TEST'; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER EXCEPTION;
    E_SQL_ERR_CD        NUMBER(5) := 0;
    E_SQL_ERR_MSG       VARCHAR2(4000);
    V_JR_WRK_ORDR_NO    TB_WRK011.WRK_ORDR_NO%TYPE;			--점보롤작업지시번호
    V_JR_WRK_ORDR_SEQNO TB_WRK011.WRK_ORDR_SEQNO%TYPE;		--점보롤작업지시번호순번
    -- JSON을 위한 변수선언 영역
    V_JSON              JSON_OBJECT_T;
    V_ARR_LIST          JSON_ARRAY_T;
    V_OBJ               JSON_OBJECT_T;
    V_WRK_ORDR_NO       TB_WRK002.WRK_ORDR_NO%TYPE;			--작업지시번호
    V_WRK_ORDR_SEQNO    TB_WRK002.WRK_ORDR_SEQNO%TYPE;		--작업지시번호순번
    V_WGT               TB_WRK002.WGT%TYPE;					--중량
    V_EA                TB_WRK002.WGT%TYPE;					--갯수

    V_PRD_STR_DATE      TB_WRK002.PRD_STR_DATE%TYPE;		--시작시간   
    V_PRD_END_DATE      TB_WRK002.PRD_END_DATE%TYPE;		--시작시간   
    V_RMK               TB_WRK002.RMK%TYPE;					--비고

    --PARAMETER변수 처리
    V_DOC_NO            VARCHAR2(20);
    V_DOC_SEQNO         NUMBER;

    V_DOC_NO_PRFM       VARCHAR2(500) := '';

    V_ORDER_NO          TB_WRK002.ORDER_NO%TYPE;					--오더번호
    V_IND_BCD           TB_WRK002.IND_BCD%TYPE;					    --개별바코드
    V_LOT_NO            TB_WRK002.LOT_NO%TYPE;					    --LOT NO
    V_LOT_NO_PRE        TB_WRK002.LOT_NO%TYPE;					    --이전 LOT NO
    V_PRD_STR_DTM       VARCHAR2(20);
    V_PRD_END_DTM       VARCHAR2(20);
    V_ORD_PRD_STR_DTM   VARCHAR2(20);                               --작업지시 시작일시
    V_VBELN             TB_SCH017.VBELN%TYPE;					    --판매문서번호
    V_POSNR             TB_SCH017.POSNR%TYPE;					    --판매문서 아이템번호
    V_OVBELN            TB_SCH017.OVBELN%TYPE;					    --판매문서번호
    V_OPOSNR            TB_SCH017.OPOSNR%TYPE;					    --판매문서 아이템번호
    V_VBELN_M           TB_SCH016.VBELN%TYPE;					    --밀롤 판매문서번호
    V_POSNR_M           TB_SCH016.POSNR%TYPE;					    --밀롤 판매문서 아이템번호
    V_OVBELN_M          TB_SCH016.OVBELN%TYPE;					    --밀롤 판매문서번호
    V_OPOSNR_M          TB_SCH016.OPOSNR%TYPE;					    --밀롤 판매문서 아이템번호
    V_VBELN_SDISPO      TB_SCH017.VBELN%TYPE;					    --영업폐품시 사용할 판매문서번호
    V_POSNR_SDISPO      TB_SCH017.POSNR%TYPE;					    --영업폐품시 사용할 판매문서 아이템번호
    --V_ORDER_DIV         TB_SCH017.ORDER_DIV%TYPE;					--오더유형
    V_OAUART_DIV        TB_SCH017.OAUART_DIV%TYPE;					--판매문서번호
    V_MATNR             TB_WRK002.MATNR%TYPE;					    --자재코드
    V_WRK_SEQ           TB_WRK002.WRK_SEQ%TYPE;					    --생산순번
    V_MACHINE           TB_WRK002.MACHINE%TYPE;					    --생산회기
    V_TO_MACHINE        TB_WRK002.TO_MACHINE%TYPE;					--생산회기
    V_PRFM_DT           TB_WRK002.PRFM_DT%TYPE;					    --생산실적일
    V_PRD_DT            TB_WRK002.PRD_DT%TYPE;					    --생산일
    V_DSTBT_DDLIN       TB_WRK002.DSTBT_DDLIN%TYPE;					--유통기간    
    V_TM                TB_WRK002.TM%TYPE;					        --작업시간
    V_UNIT              TB_WRK002.UNIT%TYPE;					    --단위
    V_PRD_NO            TB_WRK002.PRD_NO%TYPE;					    --생산번호
    V_PRFM_QTY          TB_WRK002.PRFM_QTY%TYPE;
    V_PRFM_PLT          NUMBER;                                     -- 파렛트 수
    V_LOT_BUF           TB_SCH017.LOT_BUF%TYPE;					    --이전LOT NO
    V_IND_BCD_M         TB_WRK002.IND_BCD%TYPE;					    --밀롤 개별바코드
    V_MATNR_M           TB_WRK002.MATNR%TYPE;					    --밀롤 자재코드
    V_LOT_NO_M          TB_WRK002.LOT_NO%TYPE;					    --밀롤 LOT NO
    V_WRK_TM            NUMBER;                                     --작업시간(분)
    V_ORD_TM            NUMBER;                                     --오더 작업시간(분)
    V_ORD_ABN_TIME      NUMBER;                                     --비가동 시간(분)
    V_SAP_WRK_CD        TB_MAS012.SAP_WRK_CD%TYPE;                  --SAP작업장코드
    V_QTY               NUMBER;                                     --KG수량

    V_LINE              TB_MAS012.LINE%TYPE;                        --라인
    V_ORDER_NUM         VARCHAR2(10);                               --생산지시번호
    V_ORDER_SEQ         VARCHAR2(10);                               --생산지시순번
    V_PCODE             TB_SCH016.PCODE%TYPE;                       --지종
    V_PCODE_NM          VARCHAR2(50);                               --지종명
    V_BS_WGT            TB_SCH017.BS_WGT%TYPE;                      --평량
    V_ROUTE             TB_SCH017.ROUTE%TYPE;                       --항차
    V_KUNNR             TB_SCH017.KUNNR%TYPE;                       --거래처
    V_KUNNRT            TB_SCH017.KUNNRT%TYPE;                      --거래처명    
    V_REMARK            TB_SCH017.ORDER_RMK%TYPE;                   --오더비고
    V_VLEN              TB_SCH017.VLEN%TYPE;                        --세로길이
    V_WLEN              TB_SCH017.WLEN%TYPE;                        --가로길이
    V_PACKTYPE          TB_SCH018.PACKTYPE%TYPE;                    --포장방식
    V_PACKTYPE_NM       VARCHAR2(20);                               --포장방식
--    V_SIZE                  VARCHAR2(15);                         --규격(가로길이*세로길이)
    V_PLT_PER_CNT       TB_SCH017.PLT_PER_CNT%TYPE;                 --팔레트당연수
    V_IN_PER_CNT        TB_SCH017.IN_PER_CNT%TYPE;                  --속당매수
    V_IN_CNT            NUMBER;                                     --속수
    V_USER_NM           VARCHAR2(20);                               --작업자명
    V_NTN_NM            VARCHAR2(50);                               --국가명
    V_PRFM_GTHR_YN      VARCHAR2(1);                                --실적집계여부
    V_DATE              DATE := SYSDATE;
    V_JMACHINE          VARCHAR2(10);                               --점보롤 생산호기
    V_LOC_CD            VARCHAR2(10);                               --로케이션정보
    V_STOR_LOC_CD       VARCHAR2(10);
    V_STOR_LOC_CD_M     VARCHAR2(10);
    V_LOOP_CNT          NUMBER;

    V_CACOM_YN          VARCHAR2(1);                                --재단완료여부
    V_LAST_YN           VARCHAR2(1);                                --마지막품목여부
    V_MOVE_YN           VARCHAR2(1);                                --수재단이동여부    
    V_ORD_STR_DATE      VARCHAR2(10);
    V_ORD_STR_TIME      VARCHAR2(10);
    V_ORD_END_DATE      VARCHAR2(10);
    V_ORD_END_TIME      VARCHAR2(10);
    V_WRK_ORDR_NO_M     TB_SCH017.WRK_ORDR_NO%TYPE;
    V_WRK_ORDR_SEQNO_M  TB_SCH017.WRK_ORDR_SEQNO%TYPE;
    V_PKCNT             TB_SCH017.PKCNT%TYPE;                       --재단폭수
    V_MRCNT             TB_SCH016.MRCNT%TYPE;                       --밀롤폭수
    V_MWIDTH            TB_SCH016.MWIDTH_INPUT%TYPE;                --밀롤지폭
    
    V_YMCHK                     TB_MAS011.YMCHK%TYPE;   --실적등록 가능 여부

    V_SQL                VARCHAR2(4000);    

BEGIN
    BEGIN
        V_DOC_SEQNO       := 0 ;
        V_DOC_NO_PRFM     := '';

        V_WRK_ORDR_NO := P_WRK_ORDR_NO;
        V_WRK_ORDR_SEQNO := P_WRK_ORDR_SEQNO;

        --JSON 데이터 수신
        V_JSON := JSON_OBJECT_T.PARSE(P_WRK_LIST); -- 전체 데이터
        --V_PROC_CD := V_JSON.GET_STRING('PROC_CD'); -- 프로시저명

        V_ARR_LIST := V_JSON.GET_ARRAY('list');
        --작업시작일시, 작업종료일시, 가동시간, 가로길이, 세로길이
        --실적수량(연수), 중량, 폐품연수1, 폐품중량1, 폐품사유1, 폐품연수2, 폐품중량2, 폐품사유2
        --비고, 재단완료, 마지막(품목교체), 수재단이동, 밀롤개별바코드, 밀롤자재코드, 밀롤 LOTNO, 밀롤작업지시, 밀롤 작업지시순번

        SELECT
            S017.ORDER_NO,
            S017.MATNR,
            S017.VBELN,
            S017.POSNR,
            S017.OVBELN,
            S017.OPOSNR,
            S017.MACHINE,
            S017.TO_MACHINE,
            S017.LOT_BUF,
            S017.PRD_STR_DTM,
            S017.UNIT,
            --S017.ORDER_DIV,
            S017.OAUART_DIV,
            S017.PCODE,
            S017.BS_WGT,
            S017.KUNNR,
            S017.KUNNRT,
            S017.ORDER_RMK,
            S017.VLEN,
            S017.WLEN,
            S017.PKCNT,
            S017.PACKTYPE,
            S016.WRK_ORDR_NO,
            S016.WRK_ORDR_SEQNO            
        INTO
            V_ORDER_NO,
            V_MATNR,
            V_VBELN,
            V_POSNR,
            V_OVBELN,
            V_OPOSNR,
            V_MACHINE,
            V_TO_MACHINE,
            V_LOT_BUF,
            V_ORD_PRD_STR_DTM,
            V_UNIT,
            --V_ORDER_DIV,
            V_OAUART_DIV,
            V_PCODE,
            V_BS_WGT,
            V_KUNNR,
            V_KUNNRT,
            V_REMARK,
            V_VLEN,
            V_WLEN,
            V_PKCNT,
            V_PACKTYPE,
            V_JR_WRK_ORDR_NO,
            V_JR_WRK_ORDR_SEQNO
        FROM
            TB_SCH017 S017,    --작업지시 재단
            TB_SCH016 S016     --작업지시 밀롤
        WHERE
                S017.PRE_ORDER_NO  = S016.ORDER_NO (+)
            AND S017.WRK_ORDR_NO = P_WRK_ORDR_NO
            AND S017.WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO;


        V_LOOP_CNT := V_ARR_LIST.GET_SIZE;

        FOR I IN 0..V_ARR_LIST.GET_SIZE - 1 LOOP
            V_OBJ := TREAT(V_ARR_LIST.GET(I) AS JSON_OBJECT_T);
            V_OBJ := TREAT(V_OBJ.GET('map') AS JSON_OBJECT_T);
            V_PRD_STR_DTM := V_OBJ.GET_STRING('PRD_STR_DATE');            --작업시작일시 사용안함(프로시저에서 TB_WRK002에서 마지막 일시를 가져와서 사용)
            V_PRD_END_DTM := V_OBJ.GET_STRING('PRD_END_DATE');            --작업종료일시 사용안함(프로시저에서 V_PRD_STR_DTM + 가동시간으로 구함)
            --V_PRFM_DT := V_OBJ.GET_STRING('PRFM_DT');                     --생산실적일자
            
            V_PRFM_QTY := V_OBJ.GET_STRING('PRFM_QTY');                --실적수량(연수)
            V_PRFM_PLT := V_OBJ.GET_STRING('PRFM_PLT');                --팔레트수량            
            V_TM := TO_NUMBER(V_OBJ.GET_STRING('TM'));                --가동시간(분)
            V_WLEN := TO_NUMBER(V_OBJ.GET_STRING('WLEN'));         --가로길이
            V_VLEN := TO_NUMBER(V_OBJ.GET_STRING('VLEN'));         --세로길이
            V_BS_WGT := V_OBJ.GET_STRING('BS_WGT');                  --평량

            V_RMK := V_OBJ.GET_STRING('RMK');                           --비고
            V_CACOM_YN := V_OBJ.GET_STRING('CACOM_YN');                 --재단완료여부
            V_LAST_YN := V_OBJ.GET_STRING('LAST_YN');                   --마지막품목(품목교체)여부
            V_MOVE_YN := V_OBJ.GET_STRING('MOVE_YN');                   --수재단이동여부
            V_IND_BCD_M := V_OBJ.GET_STRING('IND_BCD_M');               --밀롤 개별바코드
            V_MATNR_M := V_OBJ.GET_STRING('MATRN_M');                   --밀롤자재코드
            V_LOT_NO_M := V_OBJ.GET_STRING('LOT_NO_M');                 --밀롤 LOT NO
            V_WRK_ORDR_NO_M := V_OBJ.GET_STRING('WRK_ORDR_NO_M');       --밀롤작업지시번호
            V_WRK_ORDR_SEQNO_M := V_OBJ.GET_STRING('WRK_ORDR_SEQNO_M'); --밀롤작업지시번호
/*
            SELECT
                MRCNT,
                MWIDTH_INPUT,
                VBELN,
                POSNR,
                OVBELN,
                OPOSNR
            INTO
                V_MRCNT,
                V_MWIDTH,
                V_VBELN_M,
                V_POSNR_M,
                V_OVBELN_M,
                V_OPOSNR_M
            FROM
                TB_SCH016
            WHERE
                    WRK_ORDR_NO = V_WRK_ORDR_NO_M
                AND WRK_ORDR_SEQNO = V_WRK_ORDR_SEQNO_M;
*/
            SELECT
                LINE,
                SAP_WRK_CD
            INTO
                V_LINE,
                V_SAP_WRK_CD
            FROM
                TB_MAS012
            WHERE
                MACH_CD = P_MACH_CD;

            --로케이션 정보
            BEGIN
                SELECT
                    LGPRO   --투입저장위치
                INTO V_STOR_LOC_CD
                FROM
                    TB_MAS001
                WHERE
                        WERKS = P_WERKS
                    AND MATNR = V_MATNR;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    V_STOR_LOC_CD := '';
                WHEN OTHERS THEN
                    V_STOR_LOC_CD := '';
            END;

            IF NVL(V_STOR_LOC_CD, '') = '' THEN
                RS_CODE := 'E';
                RS_MSG := '투입저장위치 정보를 확인해주세요'||' '||P_WERKS||' '||V_MATNR;
                ROLLBACK;
                RETURN;
            END IF;
 
            SELECT  MAX(TO_CHAR(PRD_END_DATE,'YYYYMMDDHH24MISS'))
              INTO  V_PRD_STR_DTM
              FROM  TB_WRK002  
             WHERE  WERKS =  P_WERKS
               AND  WRK_ORDR_NO = P_WRK_ORDR_NO
               AND  WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
               AND  NVL(CNL_YN,'N')  = 'N'
               ;
            --V_PRD_END_DTM := V_PRD_STR_DTM
            
            SELECT TO_CHAR(TO_DATE(V_PRD_STR_DTM,'YYYYMMDDHH24MISS') + V_TM/(24*60) ,'YYYYMMDDHH24MISS') 
              INTO V_PRD_END_DTM
              FROM DUAL;

/*
            SELECT
                STOR_LOC_CD
            INTO V_STOR_LOC_CD_M
            FROM
                TB_INV001
            WHERE
                    WERKS = P_WERKS
                AND IND_BCD = V_IND_BCD_M
                AND STOR_LOC_CD <> '2700';

            IF NVL(V_STOR_LOC_CD, '') = '' THEN
                RS_CODE := 'E';
                RS_MSG := '저장위치 정보를 확인해주세요';
                ROLLBACK;
                RETURN;
            END IF;
*/                                      
            -- 저장위치 2000 으로 고정으로 테스트
            -- 정상처리의 경우는 밀롤창고 에서 재고이전되면 '2700' 으로 전송해야함.
            V_STOR_LOC_CD_M := '2000';      

--            IF V_MOVE_YN = 'Y' THEN
--                V_LOC_CD := 'L2400';                --수재단 재고창고
--            ELSE
                V_LOC_CD := 'L2600';                --포장대기창고
--            END IF;

            --작업자명
            BEGIN
                SELECT
                    NMLAST
                INTO V_USER_NM
                FROM
                    USRMA
                WHERE
                    USERID = P_USERID;

            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    V_USER_NM := '';
                WHEN OTHERS THEN
                    V_USER_NM := '';
            END;

            --포장방식 
            BEGIN
                SELECT
                    NVL(FN_CD_VAL('PACK_TYPE', V_PACKTYPE), ' ')
                INTO V_PACKTYPE_NM
                FROM
                    DUAL;

            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    V_PACKTYPE_NM := '';
                WHEN OTHERS THEN
                    V_PACKTYPE_NM := '';
            END;

            --국가명
            BEGIN
                SELECT
                    NVL(FN_CD_VAL('NATNKY', LAND1), ' ')
                INTO V_NTN_NM
                FROM
                    TB_MAS009
                WHERE
                        CUST_CD = V_KUNNR
                    AND CUST_DIV = 'C';

            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    V_NTN_NM := '';
                WHEN OTHERS THEN
                    V_NTN_NM := '';
            END;

           --지종명
            BEGIN
                SELECT
                    PCODE_NM
                INTO V_PCODE_NM
                FROM
                    TB_MAS001
                WHERE
                        WERKS = P_WERKS
                    AND MATNR = V_MATNR
                    AND PCODE = V_PCODE;

            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    V_PCODE_NM := '';
                WHEN OTHERS THEN
                    V_PCODE_NM := '';
            END; 

--            SELECT MACHINE INTO V_MMACHINE
--              FROM TB_WRK002
--             WHERE WERKS = P_WERKS
--               AND IND_BCD = V_IND_BCD_M;

            --실적조회 시 수재단이동은 재단실적에서 집계하지 않음
--            IF V_MOVE_YN = 'Y' THEN
--                V_PRFM_GTHR_YN := 'N';
--            ELSE
                V_PRFM_GTHR_YN := 'Y';
--            END IF;

            BEGIN
                SELECT
                    LOT_NO
                INTO V_LOT_NO
                FROM
                    TB_WRK002
                WHERE
                        WRK_ORDR_NO = P_WRK_ORDR_NO
                    AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
                    AND ROWNUM = 1;

            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                     V_LOT_NO := NULL ;      
            END ;

            IF V_LOT_NO IS NULL OR TRIM(V_LOT_NO) = '' THEN
                SP_CHK_LOT_NO(V_LOT_BUF, P_WERKS, P_MACH_CD, V_MATNR, V_PRD_END_DTM,
                             V_LOT_NO);
            END IF;

            --실적일자, 생산일자, 유통기간
            V_PRFM_DT := FN_RECDATE(TO_DATE(V_PRD_END_DTM, 'YYYYMMDDHH24MISS'));
            V_PRD_DT := TO_CHAR(TO_DATE(V_PRD_END_DTM, 'YYYYMMDDHH24MISS'), 'YYYYMMDD');
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

--            V_WRK_TM := ROUND((V_PRD_END_DATE - V_PRD_STR_DATE) *24 * 60);
            V_WRK_TM := ROUND(V_TM / V_LOOP_CNT, 1);
            --생산순번 조회
            BEGIN
                SELECT
                    MAX(WRK_SEQ)
                INTO V_WRK_SEQ
                FROM
                    TB_WRK002
                WHERE
                        WERKS = P_WERKS
                    AND MACH_CD = P_MACH_CD
                    AND PRFM_DT = V_PRFM_DT;

            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    V_WRK_SEQ := 0;
            END;

            V_WRK_SEQ := NVL(V_WRK_SEQ, 0) + 1;

            --생산번호
            V_PRD_NO := TO_CHAR(TO_DATE(V_PRFM_DT, 'YYYYMMDD'), 'YYYY-MM-DD')
                        || '-'
                        || V_MACHINE
                        || '-'
                        || TO_CHAR(V_WRK_SEQ);

            V_ORD_STR_DATE := TO_CHAR(TO_DATE(V_PRD_STR_DTM, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD');
            V_ORD_STR_TIME := TO_CHAR(TO_DATE(V_PRD_STR_DTM, 'YYYY-MM-DD HH24:MI:SS'), 'HH24:MI:SS');
            V_ORD_END_DATE := TO_CHAR(TO_DATE(V_PRD_END_DTM, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD');
            V_ORD_END_TIME := TO_CHAR(TO_DATE(V_PRD_END_DTM, 'YYYY-MM-DD HH24:MI:SS'), 'HH24:MI:SS');
            V_WRK_TM := V_TM;

            V_WGT := 0;
            -- 재단 중량 = ( I/F 실적 수량(R ) * 500 ) * ( 평량 / 1000) * ( 가로길이 / 1000 ) * (세로 / 1000 )
            V_WGT := ( V_PRFM_QTY ) * 500 * ( V_BS_WGT / 1000 ) * ( V_WLEN / 1000 ) * ( V_VLEN / 1000 );
            V_EA  := ( V_PRFM_QTY ) * 500 ;

            IF NVL(V_WGT, 0) > 0 THEN
                FOR I IN 0..V_PRFM_PLT - 1 LOOP
                            --문서번호
                    V_DOC_NO := FN_GET_MDOCNO('M', 'IF126');
                    V_DOC_SEQNO := V_DOC_SEQNO + 1;

                    V_DOC_NO_PRFM := V_DOC_NO_PRFM || V_DOC_NO||',';

                    --개별바코드
                    SP_GET_BARCODE_SEQ('IND', P_WERKS, 'C', V_MATNR, V_PRD_END_DTM,
                                          V_IND_BCD);

                    IF I = 0     THEN
                        RS_IND_BCD := V_IND_BCD;    -- 개별 바코드 구분자 로 여러개 전달
                    ELSE
                        RS_IND_BCD := RS_IND_BCD
                              || '|'
                              || V_IND_BCD;    -- 개별 바코드 구분자 로 여러개 전달
                    END IF;

                    INSERT INTO TB_WRK002 (
                        WERKS,
                        MACH_CD,
                        IND_BCD,
                        LOT_NO,
                        MATNR,
                        ORDER_NO,
                        WRK_ORDR_NO,
                        WRK_ORDR_SEQNO,
                        PRD_NO,
                        UNIT,
                        PRFM_QTY,
                        PCNT,
                        WGT,
                        MER_YN,
                        GRD_YN,
                        PRD_STR_DATE,
                        PRD_END_DATE,
                        TM,
                        PRFM_DT,
                        PRD_DT,
                        DSTBT_DDLIN,
                        WRK_CLASS,
                        WRK_SHIFT,
                        MACHINE,
                        TO_MACHINE,
                        STA,
                        RUN_STA,
                        DOC_NO,
                        DOC_SEQNO,
                        RMK,
                        REGDATE,
                        REGID,
                        VBELN,
                        POSNR,
                        KUNNR,
                        WRK_SEQ,
                        PRFM_GTHR_YN
                    ) VALUES (
                        P_WERKS,
                        P_MACH_CD,
                        V_IND_BCD,
                        V_LOT_NO,
                        V_MATNR,
                        V_ORDER_NO,
                        P_WRK_ORDR_NO,
                        P_WRK_ORDR_SEQNO,
                        V_PRD_NO,
                        'EA',
                        V_EA,
                        V_PRFM_QTY,
                        V_WGT,
                        'N',
                        'N',
                        V_PRD_STR_DATE,
                        V_PRD_END_DATE,
                        V_WRK_TM,
                        V_PRFM_DT,
                        V_PRD_DT,
                        V_DSTBT_DDLIN,
                        P_WRK_CLASS,
                        P_WRK_SHIFT,
                        V_MACHINE,
                        V_TO_MACHINE,
                        '00',
                        '09',       --'01',         --"운전상태 01:정상생산, 09:비계획생산, 00: "폐품"
                        V_DOC_NO,
                        V_DOC_SEQNO,
                        V_RMK,
                        V_DATE,
                        P_USERID,
                        V_VBELN,
                        V_POSNR,
                        V_KUNNR,
                        V_WRK_SEQ,
                        V_PRFM_GTHR_YN
                    );

--                    IF  V_MOVE_YN = 'N'  THEN
                        --실적 I/F
                        INSERT INTO TB_IFS005 (
                            AUFNR,
                            CRLOT,
                            WERKS,
                            WORKCENTERCODE,
                            BUDAT,
                            MACHINE,
                            WORKGROUP,
                            PRDQTY,
                            MEINS,
                            CRUNTIME,
                            COPNAM,
                            CUTTER,
                            CONFM,
                            CONFC,
                            CSDATE,
                            CSTIME,
                            CEDATE,
                            CETIME,
                            MDOCNO,
                            MDOCSEQ,
                            MAKE_DATE,
                            MAKER,
                            MRLOT,
                            EXPROD
                        ) VALUES (
                            V_ORDER_NO,
                            V_LOT_NO,
                            P_WERKS,
                            V_SAP_WRK_CD,
                            TO_CHAR(TO_DATE(V_PRFM_DT, 'YYYYMMDD'), 'YYYY-MM-DD'),
                            V_MACHINE,
                            P_WRK_CLASS,
                            V_PRFM_QTY,         -- 2022-07-14 BMKIM : 실적 전송시 EA -> 연수로 변경하여 전달 하기로 함.
                            'R',
                            V_WRK_TM,        --NVL(V_ORD_TM, '0'),
                            SUBSTRB(V_USER_NM, 1, 10),      --V_USER_NM,
                            TO_CHAR(V_LINE),
                            (CASE WHEN V_CACOM_YN = 'Y' AND V_PRFM_PLT  = (I + 1) THEN 'X' ELSE '' END),          -- 밀롤완료, SAP 에 마지막생산 전송시 'Y'를 'X', 아닌경우는 빈값으로 전송
                            (CASE WHEN V_CACOM_YN = 'Y' AND V_PRFM_PLT  = (I + 1) THEN 'X' ELSE '' END),          -- 재단완료, SAP 에 마지막생산 전송시 'Y'를 'X', 아닌경우는 빈값으로 전송
--                            '',          -- 밀롤완료, SAP 에 마지막생산 전송시 'Y'를 'X', 아닌경우는 빈값으로 전송
--                            '',          -- 재단완료, SAP 에 마지막생산 전송시 'Y'를 'X', 아닌경우는 빈값으로 전송
                            V_ORD_STR_DATE,
                            V_ORD_STR_TIME,
                            V_ORD_END_DATE,
                            V_ORD_END_TIME,
                            V_DOC_NO,
                            V_DOC_SEQNO,
                            V_DATE,
                            P_USERID,
                            V_LOT_NO_M,
                            'X'
                        );
--                    END IF ;                          

                             --재고등록
                    INSERT INTO TB_INV001 (
                        WERKS,
                        STOR_LOC_CD,
                        IND_BCD,
                        MATNR,
                        LOC_CD,
                        LOT_NO,
                        MACH_CD,
                        MACHINE,
                        WRK_ORDR_NO,
                        WRK_ORDR_SEQNO,
                        ORDER_NO,
                        PRD_NO,
                        IN_MR_YN,
                        PRD_DT,
                        UNIT,
                        STCK_QTY,
                        WGT,
                        STCK_STA,
                        DOC_NO,
                        DOC_SEQNO,
                        DLFL,
                        REGDATE,
                        REGID
                    ) VALUES (
                        P_WERKS,
                        V_STOR_LOC_CD,
                        V_IND_BCD,
                        V_MATNR,
                        V_LOC_CD,
                        V_LOT_NO,
                        P_MACH_CD,
                        V_MACHINE,
                        P_WRK_ORDR_NO,
                        P_WRK_ORDR_SEQNO,
                        V_ORDER_NO,
                        '',
                        'N',
                        V_PRD_DT,
                        'EA',
                        V_EA,
                        V_WGT,
                        '00',
                        V_DOC_NO,
                        V_DOC_SEQNO,
                        'N',
                        V_DATE,
                        P_USERID
                    );

                             --문서이력
                    INSERT INTO TB_WRK021 (
                        DOC_NO,
                        DOC_SEQNO,
                        DOC_DIV,
                        WERKS,
                        MACH_CD,
                        WRK_ORDR_NO,
                        WRK_ORDR_SEQNO,
                        IND_BCD,
                        LOT_NO,
                        ORDER_NO,
                        CNL_YN,
                        REGDATE,
                        REGID
                    ) VALUES (
                        V_DOC_NO,
                        V_DOC_SEQNO,
                        1,
                        P_WERKS,
                        P_MACH_CD,
                        V_WRK_ORDR_NO,
                        V_WRK_ORDR_SEQNO,
                        V_IND_BCD,
                        V_LOT_NO,
                        V_ORDER_NO,
                        'N',
                        V_DATE,
                        P_USERID
                    );

                    --LOT 추적
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
                                        V_JR_WRK_ORDR_NO,
                                        V_JR_WRK_ORDR_SEQNO,
                                        P_MACH_CD,
                                        V_DATE,
                                        P_USERID);

                END LOOP;
            END IF;


--            --자재사용량 등록/LOT 추적이력
--            SP_REG_LOT_LOG_I01(P_WERKS, P_MACH_CD, V_MATNR, V_LOT_NO, V_IND_BCD, V_WRK_ORDR_NO, V_WRK_ORDR_SEQNO, V_PRFM_DT, V_WGT, '', P_USERID);

            --실적등록 시 영업폐품 계산

        END LOOP;



         --영업폐품 등록
    --    IF V_CACOM_YN = 'Y' THEN
    --        RETURN;
    --    END IF;

        -- 재단 작업완료 플래그 처리 

        V_DOC_NO_PRFM      := SUBSTR(V_DOC_NO_PRFM, 1,LENGTH(V_DOC_NO_PRFM)-1);


        IF LENGTH(V_DOC_NO_PRFM) > 0   AND V_MOVE_YN = 'N'  THEN   --실적

                 --SAP FUNC ID
                 SELECT RFCFN
                   INTO RS_PRFM_RFCFN
                   FROM TB_ITFMA
                  WHERE 1=1
                    AND IFID = 'MES_IF_127';   --생산오더별 재단 실적 

                 --인터페이스 파라미터
                 OPEN CUR_1 FOR
                 SELECT 'MES_IF_127' AS I_IF_ID
                      , 'M' || LTRIM(RTRIM(TO_CHAR(SEQ_GET_IFR_KEY.NEXTVAL, '00000000000000000000000000000'))) AS I_IF_KEY
                   FROM dual;

                 --인터페이스 상세 파라미터
                 V_SQL := FN_IF_QUERY('MES_IF_127', V_DOC_NO_PRFM);
                 OPEN CUR_2 FOR V_SQL;

        END IF ;  

        IF CUR_1%ISOPEN = FALSE THEN
            OPEN CUR_1 FOR SELECT 1 FROM dual;
        END IF;

        IF CUR_2%ISOPEN = FALSE THEN
            OPEN CUR_2 FOR SELECT 1 FROM dual;
        END IF;

        RS_CODE := 'S';
        COMMIT;      
    --예외처리(CATCH)
    EXCEPTION
        WHEN E_EXCEPTION_USER THEN
        -- 에러 내역 SET
            E_SQL_ERR_CD := SQLCODE;
            E_SQL_ERR_MSG := SUBSTRB(SQLERRM, 1, 300);
            ROLLBACK;
            SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
            RS_CODE := 'E';
            RS_MSG := SQLERRM;
            RETURN;
        WHEN OTHERS THEN
            E_SQL_ERR_CD := SQLCODE;
            E_SQL_ERR_MSG := 'EXCEPTION OTHER ERROR. ['
                             || SUBSTR(SQLERRM, 1, 500)
                             || ']';
            ROLLBACK;
--            RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
        RAISE;
            RS_CODE := 'E';
            RS_MSG := SQLERRM;
            RETURN;
    --예외처리 종료
    END;
END;

/
