
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_WRK28_S12" (
    P_TYPE IN varchar2, -- LIST, SAVE
    P_JSON_STR IN CLOB,
    P_SUCCESS OUT varchar2,
    P_RS_LIST OUT SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : SP_WRK28_S12
 * PROGRAM NAME  : 포장작업 현황 조회
 * VERSION       : 1.0.0
 * DESCRIPTION   : 포장작업 현황 및 원지 밀롤실적을 관리한다.
 *
 * AUTHOR NAME   : 백우종
 * CREATE DATE   : 2023/02/08
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}	<생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}		<생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}			<생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}	<생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description
 * ------------ ------- ------------- ------------------------------------------
 * 2023/02/08    1.0.1   백우종         원지롤 실적조회 쿼리 포함
 *==============================================================================
 *  관련 테이블
 *        - [TB_INV001] 	: ( R  ) 공정재고 테이블
 *        - [TB_WRK002] 	: ( R  ) 생산실적 테이블
 *        - [TB_MAS012] 	: ( R  ) 설비 마스터 테이블
 *        - [V_WRK_ORDR] 	: ( R  ) 작업지시 뷰(가상 테이블)
 * 		  - [TB_MAS028]     : (.R..) 로케이션
 *=============================================================================*/

AS
    V_PRG_NM VARCHAR2(100) := 'SP_WRK28_S12'; -- PROCEDURE NAME

-- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER EXCEPTION;
    E_SQL_ERR_CD   NUMBER(5) := 0;
    E_SQL_ERR_MSG  VARCHAR2(4000);

    -- JSON을 위한 변수선언 영역
    V_JSON         JSON_OBJECT_T;
    V_ARR_LIST     JSON_ARRAY_T;
    V_OBJ          JSON_OBJECT_T;

    -- 세션값 처리용 변수선언 영역
    V_SESS_USER_ID varchar2(20);
    V_PLT_CD       varchar2(2);
    V_DEBUG        varchar2(1);
    V_RANGE_SQL    varchar2(4000);

    -- 조건절 처리용 변수선언 영역
    V_MACH_CD      TB_INV001.MACH_CD%TYPE; --설비코드(호기)
    V_LOC_CD       TB_INV001.LOC_CD%TYPE; --로케이션코드

    V_SDATE        varchar2(8);
    V_EDATE        varchar2(8);
    V_PCODE        TB_SCH017.PCODE%TYPE; --지종
    V_BS_WGT       TB_SCH017.BS_WGT%TYPE; --평량
    V_WLEN         TB_SCH017.WLEN%TYPE; --가로길이
    V_VLEN         TB_SCH017.VLEN%TYPE; --세로길이
    V_IND_BCD      TB_WRK002.IND_BCD%TYPE; --개별바코드
    V_CNL_YN       TB_WRK002.CNL_YN%TYPE; --취소여부

    V_INOUT_GU     VARCHAR2(2);
    V_SQL          CLOB;
    V_CHKFG        VARCHAR2(10);

BEGIN
    OPEN P_RS_LIST FOR
        SELECT NULL FROM DUAL WHERE ROWNUM = 0;

    V_JSON := JSON_OBJECT_T.parse(P_JSON_STR);

    V_SESS_USER_ID := V_JSON.get_string('SES_USER_ID');
    V_PLT_CD := V_JSON.get_string('SES_PLNTKY');
    V_IND_BCD := V_JSON.get_string('IND_BCD');
    V_SDATE := V_JSON.get_string('SDATE'); --재단생산일자
    V_EDATE := V_JSON.get_string('EDATE');
    V_PCODE := V_JSON.get_string('PCODE'); --지종
    V_BS_WGT := V_JSON.get_string('BS_WGT'); --평량
    V_WLEN := V_JSON.get_string('WLEN'); --가로길이
    V_VLEN := V_JSON.get_string('VLEN'); --세로길이
    V_INOUT_GU := V_JSON.get_string('INOUT_GU');
    V_CNL_YN := V_JSON.get_string('CNL_YN'); --취소여부

    V_CHKFG := V_JSON.get_string('CHKFG'); --원지포함여부
    V_RANGE_SQL := V_JSON.get_string('RANGE_SQL');

    IF P_TYPE = 'LIST' THEN
        V_SQL := 'SELECT W000.WERKS
                    , M001.PCODE                                                                                    --지종코드
                    , M001.PCODE_NM                                                                                 --지종명
                    , M001.BS_WGT                                                                                   --평량
                    , W000.MACH_CD                                                              AS PMACH_CD         --포장설비코드
                    , M012.MACH_NM                                                              AS PMACH_NM         --포장설비명
                    , TO_CHAR(TO_NUMBER(SUBSTR(W000.MATNR, 10, 4))) AS WLEN                                         --가로길이
                    , DECODE(TO_NUMBER(SUBSTR(W000.MATNR, 14, 4)), 0, NULL, TO_CHAR(TO_NUMBER(SUBSTR(W000.MATNR, 14, 4)))) AS VLEN  --세로길이
                    , W000.MATNR                                                                                    --자재코드
                    , M001.MATNR_NM                                                                                 --자재명
                    , CASE WHEN SUBSTR(W000.MATNR, -1) IN (''A'', ''B'') THEN SUBSTR(W000.MATNR, -1)
                           ELSE DECODE(ORDR.PACKTYPE, NULL, NULL, ORDR.PACKTYPE) END PACKTYPE                                       --포장방법
                    , CASE WHEN SUBSTR(W000.MATNR, -1) IN (''A'', ''B'') THEN FN_CD_VAL(''PACK_TYPE'', SUBSTR(W000.MATNR, -1))
                           ELSE DECODE(ORDR.PACKTYPE, NULL, NULL, FN_CD_VAL(''PACK_TYPE'', ORDR.PACKTYPE)) END PACKTYPE_NM          --포장방법명
                    , ORDR.ORDER_NO                                                                                 --오더번호
                    , SUBSTR(W000.MATNR, 5, 1)                                                  AS DOMESTIC         --내수구분코드
                    , DECODE(SUBSTR(W000.MATNR, 5, 1), ''2'', ''수출'', ''내수'')                AS DOMESTIC_NM     --내수구분(명)
                    , ORDR.KUNNR                --판매처
                    , M009.CUST_NM              AS KUNNRT           --판매처명
                    , M009.LAND1                AS LAND1             --국가코드
                    , DECODE(M009.LAND1, NULL, NULL, FN_CD_VAL(''NTN_CD'', M009.LAND1))         AS LAND1_NM         --국가명
                    , DECODE(SUBSTR(W000.IND_BCD, 6, 1), ''M'', NULL, W002_C.LOT_NO)            AS CLOT_NO          --재단LOT_NO
                    , DECODE(SUBSTR(W000.IND_BCD, 6, 1), ''M'', NULL, W002_C.IND_BCD)           AS CIND_BCD         --재단개별바코드
                    , DECODE(SUBSTR(W000.IND_BCD, 6, 1), ''M'', NULL, W002_C.PRFM_DT)           AS CPRD_DT          --재단일
                    , DECODE(SUBSTR(W000.IND_BCD, 6, 1), ''M'', NULL, W002_C.MACH_CD)           AS CMACH_CD         --재단설비
                    , DECODE(SUBSTR(W000.IND_BCD, 6, 1), ''M'', NULL, M012_1.MACH_NM)           AS CMACH_NM         --재단설비명
                    , DECODE(SUBSTR(W000.IND_BCD, 6, 1), ''M'', NULL, W002_C.REGID)             AS CREGID           --재단작업자
                    , DECODE(SUBSTR(W000.IND_BCD, 6, 1), ''M'', NULL, W002.PRFM_QTY)	        AS PALETTECNT       --팔레트당연수
                    , DECODE(SUBSTR(W000.IND_BCD, 6, 1), ''M'', NULL, ROUND(W002_C.PRFM_QTY / 500, 1))   AS CPALETTECNT      --재단팔레트당연수
                    , DECODE(SUBSTR(W000.IND_BCD, 6, 1), ''M'', NULL, ''R'')                    AS CRUNIT           --재단연수 단위(추가)
                    , DECODE(SUBSTR(W000.IND_BCD, 6, 1), ''M'', NULL, W002_C.WGT)               AS CWGT             --재단중량
                    , DECODE(SUBSTR(W000.IND_BCD, 6, 1), ''M'', NULL, ''KG'')                   AS CWUNIT           --재단중량 단위(추가)
                    , DECODE(SUBSTR(W000.IND_BCD, 6, 1), ''M'', NULL, (SELECT NMLAST FROM USRMA WHERE USRMA.USERID = W002_C.REGID))  AS CREGNM    --재단작업자명
                    , ORDR.ORDER_DIV                                                            AS WRK_ORDR_DIV     --지시구분
                    , ORDR.ORDER_DIV_NM                                                         AS WRK_ORDR_DIV_NM  --지시구분명
                    , W000.PROD_DT                                                              AS PPRD_DT          --포장 생산일자
                    , W000.PRFM_DT                                                              AS PPRFM_DT         --포장 실적일자
                    , W000.LOT_NO                                                               AS PLOT_NO          --포장 LOT NO
                    , W000.IND_BCD                                                              AS PIND_BCD         --포장 개별바코드
                    , W000.USE_QTY                                                              AS PPCNT            --포장연수
                    , W000.UNIT                                                                 AS PRD_RUNIT        --포장연수단위(추가)
                    , DECODE(SUBSTR(W000.IND_BCD, 6, 1), ''M'', NULL, DECODE(NVL(W002.SCNT, 0), 0, 0, ROUND(W002.MCNT / W002.SCNT, 1)))  AS IN_PER_CNT       --속당매수
                    , DECODE(SUBSTR(W000.IND_BCD, 6, 1), ''M'', NULL, (W000.USE_QTY / W002.PRFM_QTY) * W002.SCNT)    AS SCNT             --속수
                    , DECODE(SUBSTR(W000.IND_BCD, 6, 1), ''M'', NULL, (W000.USE_QTY / W002.PRFM_QTY) * W002.MCNT)    AS MCNT             --매수
                    , W000.WGT                                                                  AS PWGT             --포장 중량
                    , ''KG''                                                                    AS PRD_WUNIT        --포장중량단위(추가)
                    , DECODE(SUBSTR(W000.IND_BCD, 6, 1), ''M'', NULL, W000.DISPO_CD)            AS DISPO_CD         --폐품코드
                    , DECODE(SUBSTR(W000.IND_BCD, 6, 1), ''M'', NULL, W000.DISPO_QTY)           AS DISPOPCNT        --폐품연수
                    , DECODE(SUBSTR(W000.IND_BCD, 6, 1), ''M'', NULL, ''R'')                    AS DISPO_RUNIT      --폐품연수단위(추가)
                    , DECODE(SUBSTR(W000.IND_BCD, 6, 1), ''M'', NULL, W000.DISPO_WGT)           AS DISPO_WGT        --폐품중량
                    , DECODE(SUBSTR(W000.IND_BCD, 6, 1), ''M'', NULL, ''KG'')                   AS DISPO_WUNIT      --폐품중량단위(추가)
                    , I001.STCK_STA                                                                                 --재고상태
                    , DECODE(I001.STCK_STA, NULL, ''폐품'', FN_CD_VAL(''STCK_STA'', I001.STCK_STA)) AS STA_NM        --재고상태명
                    , W000.REGID                                                                AS PREGID           --포장작업자
                    , (SELECT NMLAST FROM USRMA WHERE USRMA.USERID = W000.REGID)                AS PREGNM           --포장작업자명
                    , W000.WRK_CLASS                                                            AS WRK_CLASS        --반
                    , I001.CON_TYPE                                                             AS CONTAINER        --컨테이너
                    , ORDR.ROUTE                                                                AS HANG             --항차
                    , ORDR.ORDER_RMK                                                            AS RMK              --비고
                    , W000.CNL_YN                                                                                   --취소여부
                    , DECODE(SUBSTR(W000.IND_BCD, 6, 1), ''M'', S016.PRE_ORDER_NO, AUFNR_1.JAUFNR)  AS JORDER_NO    --점보롤 오더번호
                    , DECODE(SUBSTR(W000.IND_BCD, 6, 1), ''M'', S016.ORDER_NO, AUFNR_1.MAUFNR)      AS MORDER_NO    --밀롤 오더번호
                    , ORDR.VBELN                                                                                    --판매문서번호
                    , ORDR.POSNR                                                                                    --팜매문서 품목번호
                    , W000.SDOC_NO
                    , W000.SDOC_SEQNO
                    , I001.STOR_LOC_CD
                  FROM (SELECT I010.WERKS, I010.MACH_CD, I010.MATNR, I010.LOT_NO, I010.IND_BCD
                            , DECODE(SUBSTR(I010.LOT_NO_M, 5, 1), ''P'', FN_LOT_TRK(I010.LOT_NO_M, 1),I010.LOT_NO_M) AS LOT_NO_M
                            , DECODE(SUBSTR(I010.IND_BCD_M, 6, 1), ''P'', FN_IND_TRK(I010.IND_BCD_M, 1),I010.IND_BCD_M) AS IND_BCD_M
                            , I010.INP_DT AS PROD_DT, I010.PRFM_DT,  NVL(W002.CNL_YN, ''N'') AS CNL_YN
                            , TO_CHAR(I010.USE_QTY, ''FM9999990.00'') AS USE_QTY, I010.UNIT, I010.WGT
                            , '''' AS DISPO_CD, TO_NUMBER(0) AS DISPO_QTY, '''' AS DISPO_UNIT, TO_NUMBER(0) AS DISPO_WGT
                            , I010.SDOC_NO, I010.SDOC_SEQNO, I010.REGID, I010.WRK_ORDR_NO, I010.WRK_ORDR_SEQNO
                            , NVL(W002.PRFM_GTHR_YN, ''N'') AS PRFM_GTHR_YN, NVL(W002.GRD_YN, ''N'') AS GRD_YN, W002.WRK_CLASS
                          FROM TB_INV010 I010
                          INNER JOIN TB_WRK002 W002 ON I010.WERKS = W002.WERKS AND I010.IND_BCD = W002.IND_BCD
                         WHERE I010.WERKS = ''P100'' ';

        IF V_CHKFG = 'ON' THEN
            V_SQL := V_SQL ||
                     ' AND I010.MACH_CD IN (SELECT MACH_CD FROM TB_MAS012 WHERE PROC_CD IN (''PB'', ''PC'', ''MA'', ''SA'')) ';
        ELSE
            V_SQL := V_SQL || ' AND I010.MACH_CD IN (SELECT MACH_CD FROM TB_MAS012 WHERE PROC_CD IN (''PB'', ''PC'')) ';
        END IF;

        V_SQL := V_SQL || ' UNION ALL
                        SELECT WERKS, MACH_CD, MATNR, LOT_NO, IND_BCD, LOT_NO_M, IND_BCD_M, TO_CHAR(REGDATE, ''YYYYMMDD'') AS PROD_DT, PRFM_DT,  NVL(CNL_YN, ''N'') AS CNL_YN
                            , TO_CHAR(TO_NUMBER(0), ''FM9999990.00'') AS USE_QTY, ''R'' AS UNIT, TO_NUMBER(0) AS WGT
                            , DISPO_CD, DISPO_QTY, UNIT AS DISPO_UNIT, WGT AS DISPO_WGT
                            , SDOC_NO, SDOC_SEQNO, REGID, WRK_ORDR_NO, WRK_ORDR_SEQNO
                            , DECODE(NVL(CNL_YN, ''N''), ''N'', ''Y'', ''N'') AS PRFM_GTHR_YN, ''N'' AS GRD_YN, WRK_CLASS
                          FROM TB_WRK004
                         WHERE WERKS = ''P100''
                           AND MACH_CD IN (SELECT MACH_CD FROM TB_MAS012 WHERE PROC_CD IN (''PB'', ''PC''))
                        UNION ALL
                        SELECT WERKS, MACH_CD, MATNR, LOT_NO, IND_BCD, LOT_NO_M, IND_BCD_M, TO_CHAR(REGDATE, ''YYYYMMDD'') AS PROD_DT, PRFM_DT,  NVL(CNL_YN, ''N'') AS CNL_YN
                            , TO_CHAR(TO_NUMBER(0), ''FM9999990.00'') AS USE_QTY, '''' AS UNIT, TO_NUMBER(0) AS WGT
                            , DISPO_CD, DISPO_QTY, UNIT AS DISPO_UNIT, WGT AS DISPO_WGT
                            , SDOC_NO, SDOC_SEQNO, REGID, WRK_ORDR_NO, WRK_ORDR_SEQNO
                            , DECODE(NVL(CNL_YN, ''N''), ''N'', ''Y'', ''N'') AS PRFM_GTHR_YN, ''N'' AS GRD_YN, WRK_CLASS
                          FROM TB_WRK022
                         WHERE WERKS = ''P100''
                           AND MACH_CD IN (SELECT MACH_CD FROM TB_MAS012 WHERE PROC_CD IN (''PB'', ''PC''))
                        UNION ALL
                        SELECT W002.WERKS, W002.MACH_CD, W002.MATNR, W002.LOT_NO, W002.IND_BCD, FN_LOT_TRK(W010.IND_BCD_M, 1) AS LOT_NO_M, FN_IND_TRK(W010.IND_BCD_M, 1) AS IND_BCD_M
                            , W002.PRD_DT AS PROD_DT, W002.PRFM_DT,  NVL(W002.CNL_YN, ''N'') AS CNL_YN
                            , TO_CHAR(W002.PRFM_QTY, ''FM9999990.00'') AS USE_QTY, W002.UNIT, W002.WGT
                            , '''' AS DISPO_CD, TO_NUMBER(0) AS DISPO_QTY, '''' AS DISPO_UNIT, TO_NUMBER(0) AS DISPO_WGT
                            , W002.SDOC_NO, W002.SDOC_SEQNO, W002.REGID, W002.WRK_ORDR_NO, W002.WRK_ORDR_SEQNO
                            , W002.PRFM_GTHR_YN AS PRFM_GTHR_YN, NVL(W002.GRD_YN, ''N'') AS GRD_YN, W002.WRK_CLASS
                          FROM TB_WRK002 W002
                          INNER JOIN TB_WRK010 W010
                          ON W002.WERKS = W010.WERKS
                          AND W002.IND_BCD = W010.IND_BCD
                          AND W010.WRK_TYPE = ''1''
                         WHERE W002.WERKS = ''P100''
                           AND W002.MACH_CD IN (SELECT MACH_CD FROM TB_MAS012 WHERE PROC_CD IN (''PB'', ''PC''))
                           AND NVL(W002.GRD_YN, ''N'') = ''Y''
                     ) W000
                     INNER JOIN TB_MAS001 M001  ON W000.WERKS = M001.WERKS AND W000.MATNR = M001.MATNR
                     LEFT JOIN TB_WRK002 W002   ON W000.WERKS = W002.WERKS AND W000.IND_BCD = W002.IND_BCD
                     LEFT JOIN TB_WRK002 W002_C ON W000.WERKS = W002_C.WERKS AND W000.IND_BCD_M = W002_C.IND_BCD
                     LEFT JOIN V_WRK_ORDR ORDR  ON W000.WRK_ORDR_NO = ORDR.WRK_ORDR_NO AND W000.WRK_ORDR_SEQNO = ORDR.WRK_ORDR_SEQNO
                     LEFT JOIN TB_MAS009 M009   ON ORDR.KUNNR = M009.CUST_CD AND M009.CUST_DIV = ''C''
                     LEFT JOIN TB_MAS012 M012   ON W000.MACH_CD = M012.MACH_CD
                     LEFT JOIN TB_MAS012 M012_1 ON W002_C.MACH_CD = M012_1.MACH_CD
                     LEFT JOIN TB_INV001 I001   ON W000.WERKS = I001.WERKS AND W000.IND_BCD = I001.IND_BCD
                     LEFT JOIN V_AUFNR AUFNR_1  ON W002_C.ORDER_NO = AUFNR_1.CAUFNR
                     LEFT JOIN TB_SCH016 S016   ON ORDR.WRK_ORDR_NO = S016.WRK_ORDR_NO AND ORDR.WRK_ORDR_SEQNO = S016.WRK_ORDR_SEQNO
                    WHERE 1=1 ';
        IF V_RANGE_SQL IS NOT NULL OR TRIM(V_RANGE_SQL) != '' THEN
            V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'IND_BCD', 'W000.IND_BCD');
            V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'PRFM_DT', 'W000.PRFM_DT');
            V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'BS_WGT', 'M001.BS_WGT');
            V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'PCODE', 'M001.PCODE');
            V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'WLEN', 'TO_CHAR(TO_NUMBER(SUBSTR(W000.MATNR, 10, 4)))');
            V_RANGE_SQL := REPLACE(V_RANGE_SQL, 'VLEN', 'TO_CHAR(TO_NUMBER(SUBSTR(W000.MATNR, 14, 4)))');

            V_SQL := V_SQL || V_RANGE_SQL;
        END IF;

        IF V_CNL_YN IS NOT NULL OR TRIM(V_CNL_YN) != '' THEN
            V_SQL := V_SQL || ' AND W000.CNL_YN  = ''' || V_CNL_YN || '''';

            IF TRIM(V_CNL_YN) = 'N' THEN
                V_SQL := V_SQL || ' AND W000.PRFM_GTHR_YN  = ''Y''';
            ELSE
                V_SQL := V_SQL || ' AND W000.PRFM_GTHR_YN  = ''N''';
            END IF;
        END IF;

        IF V_INOUT_GU = 'E' THEN
            V_SQL := V_SQL || ' AND ORDR.WRK_ORDR_NO LIKE ''WOEX%''||''%''  ' ;
        ELSIF V_INOUT_GU = 'N' THEN
            V_SQL := V_SQL || ' AND ORDR.WRK_ORDR_NO NOT LIKE ''WOEX%''||''%''  ' ;
        END IF;

        IF V_CHKFG = 'ON' THEN
            V_SQL := V_SQL ||
                     ' AND ((SUBSTR(ORDR.WRK_ORDR_NO, 1, 4) = ''WOMA'' AND S016.SHEET <> ''X'') OR SUBSTR(ORDR.WRK_ORDR_NO, 1, 4) <> ''WOMA'') ';
        END IF;

        V_SQL := V_SQL || ' ORDER BY W000.MACH_CD DESC, W000.PRFM_DT, W000.LOT_NO_M, W000.IND_BCD_M ';


        V_DEBUG := 'Y';

        IF (V_DEBUG = 'Y') THEN
            INSERT INTO PROC_LOG (SQL_STR, SQL_PARAM1) VALUES (V_SQL, 'WRK28_S12');
        END IF;

        OPEN P_RS_LIST FOR V_SQL;

    END IF;

    P_SUCCESS := 'Y';

EXCEPTION
    WHEN E_EXCEPTION_USER THEN

        -- 에러 내역 SET
        P_SUCCESS := 'N';
        E_SQL_ERR_CD := SQLCODE;
        E_SQL_ERR_MSG := SUBSTRB(SQLERRM, 1, 300);

        ROLLBACK;
        SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);

    WHEN OTHERS THEN
        P_SUCCESS := 'N';
        E_SQL_ERR_CD := SQLCODE;
        E_SQL_ERR_MSG := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM, 1, 500) || ']';

        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20001, E_SQL_ERR_MSG);
END ;
/
