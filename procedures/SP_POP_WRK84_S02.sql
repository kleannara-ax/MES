
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK84_S02" 
(
    P_WERKS             IN VARCHAR2 --plantcode
    ,P_OPCODE           IN VARCHAR2 --공정정보
    ,P_WRK_ORDR_NO      IN VARCHAR2 --작업지시번호
    ,P_WRK_ORDR_SEQNO   IN VARCHAR2 --작업지시순번
    ,P_IND_BCD          IN VARCHAR2 --개별바코드
    ,P_WRK_INFO_01      OUT VARCHAR2 --작업지시 상세정보 1
    ,P_WRK_INFO_02      OUT VARCHAR2 --작업지시 상세정보 2
    ,P_WRK_RMK          OUT VARCHAR2 --작업지시 비고
    ,P_RMK              OUT VARCHAR2 --비고
    ,Lang               IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE            OUT VARCHAR2 
    ,RS_MSG             OUT VARCHAR2
)
/*==============================================================================
 * PROGRAM ID    : SP_POP84_S02
 * PROGRAM NAME  : 주작업 화면 상세정보 조회
 * VERSION       : 1.0.0
 * DESCRIPTION   : 주작업화면에서 공정정보에 있는 작업지시번호, 순번으로 작업지시 상세보기 정보 전달
 *                 
 * AUTHOR NAME   : 김병무
 * CREATE DATE   : 2022/07/26
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/07/26    1.0.0   김병무         Initial Version
 *==============================================================================
 *  관련 테이블
 *=============================================================================*/
AS 
    --프로그램 ID
    --주작업화면에서 공정정보에 있는 작업지시번호, 순번으로 작업지시 상세보기 정보 전달
    V_PRG_NM         VARCHAR2(100)  := 'SP_POP_WRK84_S02';     -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID   varchar2(20) := 'TEST'; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);
    --parameter변수 처리

    --내부 변수 등록
    V_OPCODE    VARCHAR2(10) := P_OPCODE;
    V_RMK		TB_WRK002.RMK%TYPE;					--비고

BEGIN
    --예외처리 시작(try)
    BEGIN
        BEGIN
--			dbms_output.put_line(V_OPCODE);
            P_RMK := '';

            -- P_IND_BCD
            IF NVL(P_IND_BCD, '0') != '0' THEN
                IF P_WERKS = 'P100' THEN
                    SELECT MAX(RMK) INTO V_RMK 
                        FROM TB_WRK002 
                        WHERE 1=1
                            AND WERKS = P_WERKS
                            AND IND_BCD = P_IND_BCD;
                ELSE
                    SELECT MAX(RMK) INTO V_RMK 
                        FROM TB_WRK001 
                        WHERE 1=1
                            AND WERKS = P_WERKS
                            AND IND_BCD = P_IND_BCD;
                END IF;
            END IF;


            --점보롤
            IF V_OPCODE = 'JA' THEN
                BEGIN
                    SELECT '작업지시번호^' || WRK_ORDR_NO
                        || '|작업지시순번^' || WRK_ORDR_SEQNO
                        || '|작업지시구분^' || WRK_ORDR_DIV
                        || '|오더번호^' || ORDER_NO
                        --|| '|지시수량^' || NVL(RTRIM(TO_CHAR(WRK_ORDR_QTY, 'fm999,999,999,999,990.999'), '.'), '0')
                        || '|지시생성일자^' || NVL(TO_CHAR(TO_DATE(ORDR_GEN_DT, 'YYYYMMDD'), 'YYYY-MM-DD'), '')    --ORDR_GEN_DT
                        || '|생산요청일자^' || NVL(TO_CHAR(TO_DATE(PRD_REQ_DT, 'YYYYMMDD'), 'YYYY-MM-DD'), '')    --PRD_REQ_DT
                        || '|'
                        || '|생산호기^' || MACHINE
                        || '|제품코드^' || MATNR
                        --|| '|BOM순번^' || BOM_SEQNO
                        || '|지종코드^' || PCODE
                        || '|평량(g/m²)^' || NVL(RTRIM(TO_CHAR(BS_WGT, 'fm999,999,999,999,990.999'), '.'), '0')
                        || '|지폭(mm)^' || NVL(RTRIM(TO_CHAR(JWIDTH, 'fm999,999,999,999,990.999'), '.'), '0')
                        , 
                           '계획권치수(M)^' || NVL(RTRIM(TO_CHAR(JROLLCNT, 'fm999,999,999,999,990.999'), '.'), '0')
                        || '|계획중량(Kg)^' || NVL(RTRIM(TO_CHAR(TOT_WGT, 'fm999,999,999,999,990.999'), '.'), '0') 
                        || '|J/R 개수^' || JRCNT
                        --|| '|완료여부^' || COMP_YN
                        --|| '|시작일자^' || NVL(TO_CHAR(TO_DATE(PRD_STR_DTM, 'YYYYMMDDHH24MISS'), 'YYYY-MM-DD HH24:MI:SS'), '') --PRD_STR_DTM
                        || '|'
                        --|| '|생산라인구분^' || PRDTYPE
                        || '|생산라인구분명^' || PRDTYPETXT
                        --|| '|생산지시단위^' || UNIT
                        --|| '|판지구분자^' || (CASE WHEN SHEET = 'X' THEN 'SHEET' ELSE 'ROLL' END)
                        --|| '|작업지시자^' || WORK_ORDER
                        ,
                        ORDER_RMK,
                        V_RMK 
                        INTO P_WRK_INFO_01, P_WRK_INFO_02, P_WRK_RMK, P_RMK
                    FROM TB_SCH015 WHERE 1 = 1 AND WRK_ORDR_NO = P_WRK_ORDR_NO AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO;
                    --FROM TB_SCH015 WHERE 1 = 1 AND  WERKS = P_WERKS AND WRK_ORDR_NO = P_WRK_ORDR_NO;
                EXCEPTION
                      WHEN NO_DATA_FOUND THEN
                          RS_CODE := 'E';
                          RS_MSG := '작업지시 정보를 찾지 못했습니다.';
                          RETURN;
                END;
            --리와인더
            ELSIF V_OPCODE = 'MA' OR  V_OPCODE = 'SA' THEN          --밀롤, 슬리터
                BEGIN
                    SELECT WRK_INFO_01, WRK_INFO_02, WRK_RMK, RMK
                    INTO P_WRK_INFO_01, P_WRK_INFO_02, P_WRK_RMK, P_RMK
                    FROM (
                            SELECT '작업지시번호^' || WRK_ORDR_NO
                                || '|작업지시순번^' || WRK_ORDR_SEQNO
                                --|| '|작업지시구분^' || WRK_ORDR_DIV
                                || '|오더번호^' || ORDER_NO
                                --|| '|지시수량^' || NVL(RTRIM(TO_CHAR(WRK_ORDR_QTY, 'fm999,999,999,999,990.999'), '.'), '0')
                                || '|지시생성일자^' || NVL(TO_CHAR(TO_DATE(ORDR_GEN_DT, 'YYYYMMDD'), 'YYYY-MM-DD'), '')    --ORDR_GEN_DT
                                || '|생산요청일자^' || NVL(TO_CHAR(TO_DATE(PRD_REQ_DT, 'YYYYMMDD'), 'YYYY-MM-DD'), '') --PRD_REQ_DT
                                || '|밀롤창고적치여부^' || MRLDCK
                                --|| '|완료여부^' || COMP_YN
                                || '|' 
                                || '|점보롤 오더 번호^' || PRE_ORDER_NO
                                --|| '|시작일자^' || NVL(TO_CHAR(TO_DATE(PRD_STR_DTM, 'YYYYMMDDHH24MISS'), 'YYYY-MM-DD HH24:MI:SS'), '')
                                || '|오더유형 텍스트^' || ORDER_DIV_NM
                                --|| '|생산라인구분^' || PRDTYPE
                                --|| '|생산라인구분명^' || PRDTYPETXT
                                --|| '|생산 호기^' || MACHINE
                                || '|생산호기^' || MACHINE_NM
                                || '|밀롤 자재 코드^' || MATNR
                                --|| '|TO 생산 호기^' || TO_MACHINE
                                || '|이동호기^' || TO_MACHINE_NM
                                || '|점보롤 자재 코드^' || JMATNR
                                || '|지종코드^' || PCODE
                                || '|평량(g/m²)^' || NVL(RTRIM(TO_CHAR(BS_WGT, 'fm999,999,999,999,990.999'), '.'), '0')   WRK_INFO_01             --BS_WGT
                                ,
                                'M/R 지폭(mm)^' || NVL(RTRIM(TO_CHAR(MWIDTH, 'fm999,999,999,999,990.999'), '.'), '0')     --MWIDTH
                                --|| '|M/R 지폭_INPUT^' || NVL(RTRIM(TO_CHAR(MWIDTH_INPUT, 'fm999,999,999,999,990.999'), '.'), '0') 
                                --|| '|M/R 지폭_SLITER^' || NVL(RTRIM(TO_CHAR(MWIDTH_SLITER, 'fm999,999,999,999,990.999'), '.'), '0')  
                                || '|M/R 권치수(M)^' || NVL(RTRIM(TO_CHAR(MROLLCNT, 'fm999,999,999,999,990.999'), '.'), '0')    --MROLLCNT
                                || '|M/R 폭수^' || NVL(RTRIM(TO_CHAR(MRCNT, 'fm999,999,999,999,990.999'), '.'), '0')  --MRCNT
                                || '|M/R 중량^' || NVL(RTRIM(TO_CHAR(MBRGEW, 'fm999,999,999,999,990.999'), '.'), '0')  --MBRGEW
                                || '|단위^' || UNIT
                                || '|J/R 개수^' || JRCNT
                                || '|' 
        --                        || '|판매문서^' || OVBELN
        --                        || '|판매문서 항목번호^' || OPOSNR
        --                        || '|판매문서 유형^' || OAUART_NM
                                || '|판매문서^' || VBELN || '-' || POSNR
        --                        || '|판매문서 항목번호^' || POSNR
                                || '|판매문서 유형^' || SAUART_NM
                                || '|판지구분자^' || (CASE WHEN SHEET = 'X' THEN 'SHEET' ELSE 'ROLL' END)
                                || '|슬리터 구분^' || (CASE WHEN SLITER = 'Y' THEN '슬리터 생산용' ELSE '밀롤 생산용' END)      WRK_INFO_02
            --                    || '|카터^' || CUTTER
                                ,
                                ORDER_RMK WRK_RMK,
                                V_RMK     RMK
                                --INTO P_WRK_INFO_01, P_WRK_INFO_02, P_WRK_RMK, P_RMK
                            FROM TB_SCH016 WHERE 1 = 1 AND  WRK_ORDR_NO = P_WRK_ORDR_NO AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
                           UNION ALL
                            SELECT '작업지시번호^' || WRK_ORDR_NO
                                || '|작업지시순번^' || WRK_ORDR_SEQNO
                                --|| '|작업지시구분^' || WRK_ORDR_DIV
                                || '|오더번호^' || ORDER_NO
                                --|| '|지시수량^' || NVL(RTRIM(TO_CHAR(WRK_ORDR_QTY, 'fm999,999,999,999,990.999'), '.'), '0')
                                || '|지시생성일자^' || NVL(TO_CHAR(TO_DATE(ORDR_GEN_DT, 'YYYYMMDD'), 'YYYY-MM-DD'), '')    --ORDR_GEN_DT
                                || '|생산요청일자^' || NVL(TO_CHAR(TO_DATE(PRD_REQ_DT, 'YYYYMMDD'), 'YYYY-MM-DD'), '') --PRD_REQ_DT
                                || '|밀롤창고적치여부^' || NULL
                                --|| '|완료여부^' || COMP_YN
                                || '|' 
                                || '|점보롤 오더 번호^' || NULL
                                --|| '|시작일자^' || NVL(TO_CHAR(TO_DATE(PRD_STR_DTM, 'YYYYMMDDHH24MISS'), 'YYYY-MM-DD HH24:MI:SS'), '')
                                || '|오더유형 텍스트^' || NULL
                                --|| '|생산라인구분^' || PRDTYPE
                                --|| '|생산라인구분명^' || PRDTYPETXT
                                --|| '|생산 호기^' || MACHINE
                                || '|생산호기^' || NULL
                                || '|밀롤 자재 코드^' || MATNR
                                --|| '|TO 생산 호기^' || TO_MACHINE
                                || '|이동호기^' || NULL
                                || '|점보롤 자재 코드^' || NULL
                                || '|지종코드^' || PCODE
                                || '|평량(g/m²)^' || NVL(RTRIM(TO_CHAR(BS_WGT, 'fm999,999,999,999,990.999'), '.'), '0')   WRK_INFO_01             --BS_WGT
                                ,
                                'M/R 지폭(mm)^' || NVL(RTRIM(TO_CHAR(0, 'fm999,999,999,999,990.999'), '.'), '0')     --MWIDTH
                                --|| '|M/R 지폭_INPUT^' || NVL(RTRIM(TO_CHAR(MWIDTH_INPUT, 'fm999,999,999,999,990.999'), '.'), '0') 
                                --|| '|M/R 지폭_SLITER^' || NVL(RTRIM(TO_CHAR(MWIDTH_SLITER, 'fm999,999,999,999,990.999'), '.'), '0')  
                                || '|M/R 권치수(M)^' || NVL(RTRIM(TO_CHAR(0, 'fm999,999,999,999,990.999'), '.'), '0')    --MROLLCNT
                                || '|M/R 폭수^' || NVL(RTRIM(TO_CHAR(0, 'fm999,999,999,999,990.999'), '.'), '0')  --MRCNT
                                || '|M/R 중량^' || NVL(RTRIM(TO_CHAR(0, 'fm999,999,999,999,990.999'), '.'), '0')  --MBRGEW
                                || '|단위^' || UNIT
                                || '|J/R 개수^' || NULL
                                || '|' 
        --                        || '|판매문서^' || OVBELN
        --                        || '|판매문서 항목번호^' || OPOSNR
        --                        || '|판매문서 유형^' || OAUART_NM
                                || '|판매문서^' || VBELN || '-' || POSNR
        --                        || '|판매문서 항목번호^' || POSNR
                                || '|판매문서 유형^' || NULL
                                || '|판지구분자^' || NULL
                                || '|슬리터 구분^' || NULL      WRK_INFO_02
            --                    || '|카터^' || CUTTER
                                ,
                                NULL WRK_RMK,
                                V_RMK     RMK
                                --INTO P_WRK_INFO_01, P_WRK_INFO_02, P_WRK_RMK, P_RMK
                            FROM TB_SCH019 WHERE 1 = 1 AND  WRK_ORDR_NO = P_WRK_ORDR_NO AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
                           
                   ) 
                   ;

                EXCEPTION
                      WHEN NO_DATA_FOUND THEN
                          RS_CODE := 'E';
                          RS_MSG := '작업지시 정보를 찾지 못했습니다.';
                          RETURN;
                END;
            --재단
            ELSIF V_OPCODE = 'CA' OR V_OPCODE = 'CB' THEN           --재단, 수재단
                BEGIN
                    SELECT WRK_INFO_01, WRK_INFO_02, WRK_RMK, RMK
                    INTO P_WRK_INFO_01, P_WRK_INFO_02, P_WRK_RMK, P_RMK
                    FROM (
                            SELECT '작업지시번호^' || WRK_ORDR_NO
                                || '|작업지시순번^' || WRK_ORDR_SEQNO
                                --|| '|작업지시구분^' || WRK_ORDR_DIV
                                || '|오더번호^' || ORDER_NO
                                --|| '|지시수량^' || NVL(RTRIM(TO_CHAR(WRK_ORDR_QTY, 'fm999,999,999,999,990.999'), '.'), '0') --WRK_ORDR_QTY
                                || '|지시생성일자^' || NVL(TO_CHAR(TO_DATE(ORDR_GEN_DT, 'YYYYMMDD'), 'YYYY-MM-DD'), '')  --ORDR_GEN_DT
                                || '|생산요청일자^' || NVL(TO_CHAR(TO_DATE(PRD_REQ_DT, 'YYYYMMDD'), 'YYYY-MM-DD'), '') --PRD_REQ_DT
                                --|| '|완료여부^' || COMP_YN
                                || '|'
                                || '|밀롤 오더 번호^' || PRE_ORDER_NO
                                || '|시작일자^' || NVL(TO_CHAR(TO_DATE(PRD_STR_DTM, 'YYYYMMDDHH24MISS'), 'YYYY-MM-DD HH24:MI:SS'), '')
                                || '|오더유형^' || ORDER_DIV
                                || '|오더유형 텍스트^' || ORDER_DIV_NM
                                || '|생산호기^' || MACHINE_NM
                                || '|이동호기^' || TO_MACHINE_NM
                                --|| '|생산 호기명^' || CVERIDTXT
                                || '|재단 자재 코드^' || MATNR
                                || '|지종^' || PCODE
                                || '|평량(g/m²)^' || NVL(RTRIM(TO_CHAR(BS_WGT, 'fm999,999,999,999,990.999'), '.'), '0')     --BS_WGT
                                || '|가로길이(mm)^' || NVL(RTRIM(TO_CHAR(WLEN, 'fm999,999,999,999,990.999'), '.'), '0')  --WLEN
                                || '|세로길이(mm)^' || NVL(RTRIM(TO_CHAR(VLEN, 'fm999,999,999,999,990.999'), '.'), '0') WRK_INFO_01   --VLEN
                                ,'계획연수(R)^' || NVL(RTRIM(TO_CHAR(WRK_ORDR_QTY, 'fm999,999,999,999,990.999'), '.'), '0') --WRK_ORDR_QTY
                                || '|계획중량(Kg)^' || NVL(RTRIM(TO_CHAR(TOT_WGT, 'fm999,999,999,999,990.999'), '.'), '0')
                                || '|'
                                || '|폭수^' || PKCNT
                                || '|실적수량^' || NVL(RTRIM(TO_CHAR(PRFM_QTY, 'fm999,999,999,999,990.999'), '.'), '0')  -- PRFM_QTY
                                || '|총중량^' || NVL(RTRIM(TO_CHAR(TOT_WGT, 'fm999,999,999,999,990.999'), '.'), '0')  --TOT_WGT
                                || '|단위^' || UNIT                 --P_WRK_INFO_01
                                || '|팔레트당연수^' || NVL(RTRIM(TO_CHAR(PLT_PER_CNT, 'fm999,999,999,999,990.999'), '.'), '0')   --PLT_PER_CNT
                                || '|속당매수^' || NVL(RTRIM(TO_CHAR(IN_PER_CNT, 'fm999,999,999,999,990.999'), '.'), '0')  --IN_PER_CNT
                                || '|쌍팔레트^' || DBL_FLAG
                                || '|'
        --                        || '|판매문서^' || OVBELN
        --                        || '|판매문서 항목번호^' || OPOSNR
        --                        --|| '|판매문서 유형^' || OAUART_DIV
        --                        || '|판매문서 오더 유형 텍스트^' || OAUART_NM
                                || '|판매문서^' || VBELN || '-' || POSNR
        --                        || '|판매문서 항목번호^' || POSNR
                                --|| '|판매문서 유형^' || SAUART_DIV
                                || '|판매문서 오더 유형 텍스트^' || SAUART_NM   WRK_INFO_02
            --                    || '|카터^' || CUTTER
                                , 
                                ORDER_RMK  WRK_RMK,
                                V_RMK  RMK
                                --INTO P_WRK_INFO_01, P_WRK_INFO_02, P_WRK_RMK, P_RMK
                            FROM TB_SCH017 WHERE 1 = 1 AND  WRK_ORDR_NO = P_WRK_ORDR_NO AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
                          UNION ALL
                            SELECT '작업지시번호^' || WRK_ORDR_NO
                                || '|작업지시순번^' || WRK_ORDR_SEQNO
                                --|| '|작업지시구분^' || WRK_ORDR_DIV
                                || '|오더번호^' || ORDER_NO
                                --|| '|지시수량^' || NVL(RTRIM(TO_CHAR(WRK_ORDR_QTY, 'fm999,999,999,999,990.999'), '.'), '0') --WRK_ORDR_QTY
                                || '|지시생성일자^' || NVL(TO_CHAR(TO_DATE(ORDR_GEN_DT, 'YYYYMMDD'), 'YYYY-MM-DD'), '')  --ORDR_GEN_DT
                                || '|생산요청일자^' || NVL(TO_CHAR(TO_DATE(PRD_REQ_DT, 'YYYYMMDD'), 'YYYY-MM-DD'), '') --PRD_REQ_DT
                                --|| '|완료여부^' || COMP_YN
                                || '|'
                                || '|밀롤 오더 번호^' || NULL
                                || '|시작일자^' || NVL(TO_CHAR(TO_DATE(PRD_STR_DTM, 'YYYYMMDDHH24MISS'), 'YYYY-MM-DD HH24:MI:SS'), '')
                                || '|오더유형^' || ORDER_DIV
                                || '|오더유형 텍스트^' || NULL
                                || '|생산호기^' || NULL
                                || '|이동호기^' || NULL
                                --|| '|생산 호기명^' || CVERIDTXT
                                || '|재단 자재 코드^' || MATNR
                                || '|지종^' || PCODE
                                || '|평량(g/m²)^' || NVL(RTRIM(TO_CHAR(BS_WGT, 'fm999,999,999,999,990.999'), '.'), '0')     --BS_WGT
                                || '|가로길이(mm)^' || NVL(RTRIM(TO_CHAR(WLEN, 'fm999,999,999,999,990.999'), '.'), '0')  --WLEN
                                || '|세로길이(mm)^' || NVL(RTRIM(TO_CHAR(VLEN, 'fm999,999,999,999,990.999'), '.'), '0') WRK_INFO_01   --VLEN
                                ,
                                '|폭수^' || NULL
                                || '|실적수량^' || NVL(RTRIM(TO_CHAR(0, 'fm999,999,999,999,990.999'), '.'), '0')  -- PRFM_QTY
                                || '|총중량^' || NVL(RTRIM(TO_CHAR(0, 'fm999,999,999,999,990.999'), '.'), '0')  --TOT_WGT
                                || '|단위^' || UNIT                 --P_WRK_INFO_01
                                || '|팔레트당연수^' || NVL(RTRIM(TO_CHAR(PLT_PER_CNT, 'fm999,999,999,999,990.999'), '.'), '0')   --PLT_PER_CNT
                                || '|속당매수^' || NVL(RTRIM(TO_CHAR(IN_PER_CNT, 'fm999,999,999,999,990.999'), '.'), '0')  --IN_PER_CNT
                                || '|쌍팔레트^' || NULL
                                || '|'
        --                        || '|판매문서^' || OVBELN
        --                        || '|판매문서 항목번호^' || OPOSNR
        --                        --|| '|판매문서 유형^' || OAUART_DIV
        --                        || '|판매문서 오더 유형 텍스트^' || OAUART_NM
                                || '|판매문서^' || VBELN || '-' || POSNR
        --                        || '|판매문서 항목번호^' || POSNR
                                --|| '|판매문서 유형^' || SAUART_DIV
                                || '|판매문서 오더 유형 텍스트^' || NULL   WRK_INFO_02
            --                    || '|카터^' || CUTTER
                                , 
                                NULL  WRK_RMK,
                                V_RMK  RMK
                                --INTO P_WRK_INFO_01, P_WRK_INFO_02, P_WRK_RMK, P_RMK
                            FROM TB_SCH019 WHERE 1 = 1 AND  WRK_ORDR_NO = P_WRK_ORDR_NO AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO                          
                    );

                EXCEPTION
                      WHEN NO_DATA_FOUND THEN
                          RS_CODE := 'E';
                          RS_MSG := '작업지시 정보를 찾지 못했습니다.';
                          RETURN;
                END;
            --포장
            ELSIF V_OPCODE = 'PB' OR V_OPCODE = 'PC' OR V_OPCODE = 'PD' OR V_OPCODE = 'ZA' THEN        --자동포장, 수축포장, 수작업 포장
                BEGIN
                    SELECT WRK_INFO_01, WRK_INFO_02, WRK_RMK, RMK
                    INTO P_WRK_INFO_01, P_WRK_INFO_02, P_WRK_RMK, P_RMK
                    FROM (
                            SELECT '작업지시번호^' || WRK_ORDR_NO
                                || '|작업지시순번^' || WRK_ORDR_SEQNO
        --                        || '|작업지시구분^' || WRK_ORDR_DIV
                                || '|오더번호^' || ORDER_NO
                                || '|지시생성일자^' || NVL(TO_CHAR(TO_DATE(ORDR_GEN_DT, 'YYYYMMDD'), 'YYYY-MM-DD'), '')  --ORDR_GEN_DT
                                || '|생산요청일자^' || NVL(TO_CHAR(TO_DATE(PRD_REQ_DT, 'YYYYMMDD'), 'YYYY-MM-DD'), '') --PRD_REQ_DT
        --                        || '|완료여부^' || COMP_YN
                                || '|'
                                --|| '|재단 오더 번호^' || PRE_ORDER_NO
                                --|| '|시작일자^' || NVL(TO_CHAR(TO_DATE(PRD_STR_DTM, 'YYYYMMDDHH24MISS'), 'YYYY-MM-DD HH24:MI:SS'), '')
                                || '|오더유형^' || ORDER_DIV_NM
                                || '|생산호기^' || MACHINE_NM
                                || '|이동호기^' || TO_MACHINE_NM
                                --|| '|생산 호기명^' || PVERIDTXT
                                || '|포장 자재 코드^' || MATNR
                                || '|'
                                || '|지종^' || PCODE
                                || '|평량(g/m²)^' || NVL(RTRIM(TO_CHAR(BS_WGT, 'fm999,999,999,999,990.999'), '.'), '0')     --BS_WGT
                                || '|가로길이(mm)^' || NVL(RTRIM(TO_CHAR(WLEN, 'fm999,999,999,999,990.999'), '.'), '0')  --WLEN
                                || '|세로길이(mm)^' || NVL(RTRIM(TO_CHAR(VLEN, 'fm999,999,999,999,990.999'), '.'), '0')  WRK_INFO_01,  --VLEN
                                --'수량^' || NVL(RTRIM(TO_CHAR(PCNT, 'fm999,999,999,999,990.999'), '.'), '0')
                                '계획연수(R)^' || NVL(RTRIM(TO_CHAR(WRK_ORDR_QTY, 'fm999,999,999,999,990.999'), '.'), '0') --WRK_ORDR_QTY
                                || '|계획중량(Kg)^' || NVL(RTRIM(TO_CHAR(TOT_WGT, 'fm999,999,999,999,990.999'), '.'), '0')
                                || '|'
        --                        || '|단위^' || UNIT
                                || '|팔레트당연수(R)^' || NVL(RTRIM(TO_CHAR(PLT_PER_CNT, 'fm999,999,999,999,990.999'), '.'), '0')    --PLT_PER_CNT
                                || '|속당매수^' || NVL(RTRIM(TO_CHAR(IN_PER_CNT, 'fm999,999,999,999,990.999'), '.'), '0')   --IN_PER_CNT
                                || '|쌍팔레트^' || DBL_FLAG
                                --|| '|팔레트당연수^' || PALETTECNT
                                || '|컨테이너 타입^' || CON_TYPE
                                || '|포장 타입^' || FN_CD_VAL('PACK_TYPE', PACKTYPE)
                                || '|'
                                --|| '|판매문서^' || OVBELN         --견적문서
                                --|| '|판매문서 항목번호^' || OPOSNR
                                --|| '|판매 문서 유형^' || OAUART_NM
                                || '|판매문서^' || VBELN || '-' || POSNR
        --                        || '|판매문서 항목번호^' || POSNR
                                || '|판매문서 유형^' || SAUART_NM
                                || '|'
                                || '|판매처^' || KUNNR
                                || '|판매처명^' || KUNNRT  WRK_INFO_02,
                                ORDER_RMK  WRK_RMK ,			--P_WRK_RMK
                                V_RMK		RMK
                     --           INTO P_WRK_INFO_01, P_WRK_INFO_02, P_WRK_RMK, P_RMK
                            FROM TB_SCH018 
                            WHERE 1 = 1 AND  WRK_ORDR_NO = P_WRK_ORDR_NO AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO
                         UNION ALL
                            SELECT '작업지시번호^' || WRK_ORDR_NO
                                || '|작업지시순번^' || WRK_ORDR_SEQNO
        --                        || '|작업지시구분^' || WRK_ORDR_DIV
                                || '|오더번호^' || ORDER_NO
                                || '|지시생성일자^' || NVL(TO_CHAR(TO_DATE(ORDR_GEN_DT, 'YYYYMMDD'), 'YYYY-MM-DD'), '')  --ORDR_GEN_DT
                                || '|생산요청일자^' || NVL(TO_CHAR(TO_DATE(PRD_REQ_DT, 'YYYYMMDD'), 'YYYY-MM-DD'), '') --PRD_REQ_DT
        --                        || '|완료여부^' || COMP_YN
                                || '|'
                                --|| '|재단 오더 번호^' || PRE_ORDER_NO
                                --|| '|시작일자^' || NVL(TO_CHAR(TO_DATE(PRD_STR_DTM, 'YYYYMMDDHH24MISS'), 'YYYY-MM-DD HH24:MI:SS'), '')
                                || '|오더유형^' || NULL
                                || '|생산호기^' || NULL
                                || '|이동호기^' || NULL
                                --|| '|생산 호기명^' || PVERIDTXT
                                || '|포장 자재 코드^' || MATNR
                                || '|'
                                || '|지종^' || PCODE
                                || '|평량(g/m²)^' || NVL(RTRIM(TO_CHAR(BS_WGT, 'fm999,999,999,999,990.999'), '.'), '0')     --BS_WGT
                                || '|가로길이(mm)^' || NVL(RTRIM(TO_CHAR(WLEN, 'fm999,999,999,999,990.999'), '.'), '0')  --WLEN
                                || '|세로길이(mm)^' || NVL(RTRIM(TO_CHAR(VLEN, 'fm999,999,999,999,990.999'), '.'), '0')  WRK_INFO_01,  --VLEN
                                --'수량^' || NVL(RTRIM(TO_CHAR(PCNT, 'fm999,999,999,999,990.999'), '.'), '0')
                                '계획연수(R)^' || NVL(RTRIM(TO_CHAR(WRK_ORDR_QTY, 'fm999,999,999,999,990.999'), '.'), '0') --WRK_ORDR_QTY
                                || '|계획중량(Kg)^' || NVL(RTRIM(TO_CHAR(0, 'fm999,999,999,999,990.999'), '.'), '0')
                                || '|'
        --                        || '|단위^' || UNIT
                                || '|팔레트당연수(R)^' || NVL(RTRIM(TO_CHAR(PLT_PER_CNT, 'fm999,999,999,999,990.999'), '.'), '0')    --PLT_PER_CNT
                                || '|속당매수^' || NVL(RTRIM(TO_CHAR(IN_PER_CNT, 'fm999,999,999,999,990.999'), '.'), '0')   --IN_PER_CNT
                                || '|쌍팔레트^' || NULL
                                --|| '|팔레트당연수^' || PALETTECNT
                                || '|컨테이너 타입^' || NULL
                                || '|포장 타입^' || FN_CD_VAL('PACK_TYPE', PACKTYPE)
                                || '|'
                                --|| '|판매문서^' || OVBELN         --견적문서
                                --|| '|판매문서 항목번호^' || OPOSNR
                                --|| '|판매 문서 유형^' || OAUART_NM
                                || '|판매문서^' || VBELN || '-' || POSNR
        --                        || '|판매문서 항목번호^' || POSNR
                                || '|판매문서 유형^' || NULL
                                || '|'
                                || '|판매처^' || KUNNR
                                || '|판매처명^' || KUNNRT  WRK_INFO_02,
                                NULL  WRK_RMK ,			--P_WRK_RMK
                                V_RMK		RMK
                     --           INTO P_WRK_INFO_01, P_WRK_INFO_02, P_WRK_RMK, P_RMK
                            FROM TB_SCH019 
                            WHERE 1 = 1 AND  WRK_ORDR_NO = P_WRK_ORDR_NO AND WRK_ORDR_SEQNO = P_WRK_ORDR_SEQNO                         
                    );
                    --FROM TB_SCH018 WHERE 1 = 1 AND WERKS = P_WERKS AND WRK_ORDR_NO = P_WRK_ORDR_NO;
                EXCEPTION
                      WHEN NO_DATA_FOUND THEN
                          RS_CODE := 'E';
                          RS_MSG := '작업지시 정보를 찾지 못했습니다.';
                          RETURN;
                END;

            END IF;

            --작업 정상 종료 코드 등록
            RS_CODE := 'S';
        END;
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
        E_SQL_ERR_CD        := -20001;
        E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

        ROLLBACK;
        --RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
        RAISE;

        RS_CODE := 'E';
        RS_MSG  := SQLERRM;
        RETURN;
    --예외처리 종료
    END;
END SP_POP_WRK84_S02;
/
