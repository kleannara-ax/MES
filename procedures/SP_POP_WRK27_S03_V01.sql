
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK27_S03_V01" 
(
     P_WERKS        IN VARCHAR2                 --P100
    ,P_ALL_SEARCH   IN VARCHAR2                 --Y:전체  N     N
    ,P_MACH_CD      IN VARCHAR2                 --PPB05 
    ,P_PRD_STR_DATE IN VARCHAR2     --YYYYMMDD  20220706
    ,P_PRD_END_DATE IN VARCHAR2     --YYYYMMDD  20220802
    ,P_VBELN        IN VARCHAR2                -- NULL  
    ,P_POSNR        IN VARCHAR2                -- NULL          
    ,Lang           IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE        OUT VARCHAR2 
    ,RS_MSG         OUT VARCHAR2
    ,CUR_1          OUT SYS_REFCURSOR
    ,CUR_2          OUT SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : POP_WRK27
 * PROGRAM NAME  : PS 포장 작업지시 목록조회화면
 * VERSION       : 1.0.0
 * DESCRIPTION   : PS 포장 작업지시 목록을 조회한다.
 *                 
 * AUTHOR NAME   : 박충식
 * CREATE DATE   : 2022/07/28
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/05/31    1.0.0   김병무         HL과 PS의 작업지시 조회를 분리함. (SP_POP_WRK07_S01=HL, SP_POP_WRK07_S02=PS)
 * 2022/01/09    1.0.2   김병무         자동포장도 SF포장과 동일하게 판매문서/품목으로 묶어서 실적등록 가능하게 수정
 *==============================================================================
 *  관련 테이블
 * - [TB_SCH015] : (.R..) 제지 점보롤작업지시
 * - [TB_SCH016] : (.R..) 제지 밀롤작업지시
 * - [TB_MAS001] : (.R..) 자재 기준 정보
 * - [TB_WRK002] : (.R..) PS 생산실적 이력
 * - [TB_INV003] : (.R..) 자재 투입 정보 (공정투입된 반제품)
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM        VARCHAR2(100)  := 'SP_POP_WRK27_S03';     -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := '99'; --PLANTCODE TEST
    V_SESS_USER_ID   varchar2(20) := 'TEST'; --USERID
    -- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);
    --내부변수 관리
    V_COLINFO VARCHAR2(1000);--컬럼설정1
    V_COLTYPE VARCHAR2(1000);--컬럼설정2
    V_WRK_CD VARCHAR2(8);--설비별 작업장코드

    V_WRK_ORDR_NO       TB_WRK011.WRK_ORDR_NO%TYPE;
    V_WRK_ORDR_SEQNO    TB_WRK011.WRK_ORDR_SEQNO%TYPE;
    V_MATNR             TB_WRK011.MATNR%TYPE;
BEGIN
    --예외처리 시작(try)
    BEGIN

        --공정별 조회프로시저 변경

         --grid 컬럼 정보 설정
--         V_COLINFO := '선택@C^60|오더구분@C^100|작업지시번호@C^200|순번@C^50|지종@C^70|지종명@H|평량@R^80|가로@R^80|세로@R^80|계획연수@R^100|실적연수@R^100|계획중량@R^100|실적중량@R^100|상세보기@C^100|오더번호@C^130|지시사항@H|자재코드@C^200';
--         V_COLTYPE := 'CHK@Button|ORDER_DIV@varchar|WRK_ORDR_NO@varchar|WRK_ORDR_SEQNO@varchar|PCODE@varchar|PCODE_NM@varchar|BS_WGT@varchar|WLEN@varchar|VLEN@varchar|WRK_ORDR_QTY@varchar|PCNT@varchar|TOT_WGT@varchar|WGT@varchar|DBTN@Button|ORDER_NO@varchar|ORDER_RMK@varchar|MATNR@varchar';
         V_COLINFO := '선택@C^60|작업지시번호@C^200|순번@C^50|지종@C^70|지종명@H|평량@R^80|가로@R^80|세로@R^80|단위@C^80|계획지시량@R^100|계획중량@R^100|상세보기@H|오더번호@C^130|지시사항@H|자재코드@C^200|자재코드명@C^300';
         V_COLTYPE := 'CHK@Button|WRK_ORDR_NO@varchar|WRK_ORDR_SEQNO@varchar|PCODE@varchar|PCODE_NM@varchar|BS_WGT@varchar|WLEN@varchar|VLEN@varchar|UNIT@varchar|WRK_ORDR_QTY@varchar|TOT_WGT@varchar|DBTN@Button|ORDER_NO@varchar|ORDER_RMK@varchar|MATNR@varchar|MATNR_NM@varchar';


         --컬럼설정 반환 테이블 작성
         OPEN CUR_1 FOR
         SELECT RTN_VALUES FROM FN_SPLIT(V_COLINFO||','||V_COLTYPE,',');

         IF P_ALL_SEARCH = 'Y'    THEN --설비전체
                 OPEN CUR_2 FOR
                 SELECT   DISTINCT
                          CHK              --선택
                         ,WRK_ORDR_NO      --포장 작업지시번호
                         ,WRK_ORDR_SEQNO   --포장 작업지시번호 순번
                         ,PCODE            --지종
                         ,PCODE_NM         --지종명
                         ,BS_WGT           --평량
                         ,WLEN             --가로길
                         ,VLEN             --세로길
                         ,UNIT             --단위 
                         ,WRK_ORDR_QTY     --포장 생산지시량
                         ,TOT_WGT          --포장 계획중량
                         ,DBTN             --상세보기
                         ,ORDER_NO         --오더번호
                         ,ORDER_RMK        --작업지시사항
                         ,MATNR            --포장 자재코드
                 FROM
                 (
                         SELECT          '-'                                                                CHK              --선택
                                       , W000.WRK_ORDR_NO                                                   WRK_ORDR_NO      --포장 작업지시번호
                                       , W000.WRK_ORDR_SEQNO                                                WRK_ORDR_SEQNO   --포장 작업지시번호 순번
                                       , W000.PCODE                                                         PCODE            --지종
                                       , W000.PCODE_NM                                                      PCODE_NM         --지종명
                                       , TO_CHAR(S017.BS_WGT, 'fm999,999,999,990')                          BS_WGT           --평량
                                       , TO_CHAR(S017.WLEN, 'fm9,990')                                      WLEN             --가로길
                                       , TO_CHAR(S017.VLEN, 'fm9,990')                                      VLEN             --세로길
                                       , S017.UNIT                                                          UNIT             --단위 
                                       , TO_CHAR(S017.WRK_ORDR_QTY, 'fm999,999,999,990')                    WRK_ORDR_QTY     --포장 생산지시량
                                       , TO_CHAR(S017.TOT_WGT, 'fm999,999,999,990')                         TOT_WGT          --포장 계획중량
                                       , '상세보기'                                                           DBTN             --상세보기
                                       , S017.ORDER_NO                                                      ORDER_NO         --오더번호
                                       , S017.ORDER_RMK                                                     ORDER_RMK        --작업지시사항
                                       , W000.MATNR                                                         MATNR            --포장 자재코드
                                       --, M001.MATNR_NM                                                      MATNR_NM         --포장 자재코드명
                                  FROM  (SELECT W002.WERKS, W002.WRK_ORDR_NO, W002.WRK_ORDR_SEQNO,
                                                W002.MATNR,  I003.PCODE, I003.PCODE_NM, /*W002.PRFM_DT,*/ W002.LOT_NO, W002.WLEN, W002.VLEN,
                                                SUM(W002.PCNT) PCNT, SUM(W002.WGT) WGT
                                            FROM(
                                                SELECT I003.WERKS, I003.WRK_ORDR_NO, I003.WRK_ORDR_SEQNO, M001.PCODE, M001.PCODE_NM
                                                  FROM TB_INV003 I003,
                                                       TB_MAS001 M001
                                                 WHERE I003.WERKS = M001.WERKS
                                                    AND I003.MATNR = M001.MATNR
                                                    AND I003.WERKS = P_WERKS
--                                                    AND I003.MACH_CD LIKE 'PPC%'      -- 김병무 230105 : 자동포장도 수축포장과 동일하게 처리하도록 수정(자동포장도 문서번호로 묶어서 실적등록 다른 호기도 조회가능)
                                                    AND I003.MACH_CD LIKE SUBSTR(P_MACH_CD, 1, 3) || '%'
                                                    AND I003.INP_DT BETWEEN P_PRD_STR_DATE AND P_PRD_END_DATE
                                                    AND I003.STCK_QTY > 0
                                                    AND M001.MATNR_DIV IN ('FERT', 'HALB')
                                                    --AND NVL(M001.PCODE,' ') LIKE '%' || P_PCODE || '%'
                                                    --AND TO_CHAR(NVL(M001.BS_WGT,0)) LIKE '%' || P_WEIGHT || '%'
                                                 GROUP BY I003.WERKS, I003.WRK_ORDR_NO, I003.WRK_ORDR_SEQNO, I003.MATNR, M001.PCODE, M001.PCODE_NM
                                                ) I003,
                                                TB_WRK002 W002
                                             WHERE I003.WERKS = W002.WERKS(+)
                                               AND I003.WRK_ORDR_NO = W002.WRK_ORDR_NO(+)
                                               AND I003.WRK_ORDR_SEQNO = W002.WRK_ORDR_SEQNO(+)  
                                               --AND W002.MACH_CD = P_MACH_CD
                                               AND NVL(W002.CNL_YN,'N') ='N'
                                            GROUP BY W002.WERKS, W002.WRK_ORDR_NO, W002.WRK_ORDR_SEQNO, W002.MATNR, W002.LOT_NO, /*W002.PRFM_DT,*/
                                                W002.WLEN, W002.VLEN, I003.PCODE, I003.PCODE_NM
                                         ) W000,
                                       TB_SCH017 S017
                                 WHERE W000.WERKS = S017.WERKS(+)
                                   AND W000.WRK_ORDR_NO     = S017.WRK_ORDR_NO(+)
                                   AND W000.WRK_ORDR_SEQNO  = S017.WRK_ORDR_SEQNO(+)
                                   --AND S017.COMP_YN         = 'Y'
                                   AND S017.VBELN           = P_VBELN
                                   AND S017.POSNR           = P_POSNR 
                                   --AND NVL(S017.USE_YN,'Y') ='Y'
                )                   
                ORDER BY WRK_ORDR_NO DESC, WRK_ORDR_SEQNO DESC;

         ELSE
                 OPEN CUR_2 FOR
                 SELECT   DISTINCT
                          CHK              --선택
                         ,WRK_ORDR_NO      --포장 작업지시번호
                         ,WRK_ORDR_SEQNO   --포장 작업지시번호 순번
                         ,PCODE            --지종
                         ,PCODE_NM         --지종명
                         ,BS_WGT           --평량
                         ,WLEN             --가로길
                         ,VLEN             --세로길
                         ,UNIT             --단위 
                         ,WRK_ORDR_QTY     --포장 생산지시량
                         ,TOT_WGT          --포장 계획중량
                         ,DBTN             --상세보기
                         ,ORDER_NO         --오더번호
                         ,ORDER_RMK        --작업지시사항
                         ,MATNR            --포장 자재코드
                 FROM
                 (
                         SELECT          '-'                                                                CHK              --선택
                                       , W000.WRK_ORDR_NO                                                   WRK_ORDR_NO      --포장 작업지시번호
                                       , W000.WRK_ORDR_SEQNO                                                WRK_ORDR_SEQNO   --포장 작업지시번호 순번
                                       , W000.PCODE                                                         PCODE            --지종
                                       , W000.PCODE_NM                                                      PCODE_NM         --지종명
                                       , TO_CHAR(S017.BS_WGT, 'fm999,999,999,990')                          BS_WGT           --평량
                                       , TO_CHAR(S017.WLEN, 'fm9,990')                                      WLEN             --가로길
                                       , TO_CHAR(S017.VLEN, 'fm9,990')                                      VLEN             --세로길
                                       , S017.UNIT                                                          UNIT             --단위 
                                       , TO_CHAR(S017.WRK_ORDR_QTY, 'fm999,999,999,990')                    WRK_ORDR_QTY     --포장 생산지시량
                                       , TO_CHAR(S017.TOT_WGT, 'fm999,999,999,990')                         TOT_WGT          --포장 계획중량
                                       , '상세보기'                                                           DBTN             --상세보기
                                       , S017.ORDER_NO                                                      ORDER_NO         --오더번호
                                       , S017.ORDER_RMK                                                     ORDER_RMK        --작업지시사항
                                       , W000.MATNR                                                         MATNR            --포장 자재코드
                                       --, M001.MATNR_NM                                                      MATNR_NM         --포장 자재코드명
                                  FROM  (SELECT W002.WERKS, W002.WRK_ORDR_NO, W002.WRK_ORDR_SEQNO,
                                                W002.MATNR,  I003.PCODE, I003.PCODE_NM, /*W002.PRFM_DT,*/ W002.LOT_NO, W002.WLEN, W002.VLEN,
                                                SUM(W002.PCNT) PCNT, SUM(W002.WGT) WGT
                                            FROM(
                                                SELECT I003.WERKS, I003.WRK_ORDR_NO, I003.WRK_ORDR_SEQNO, M001.PCODE, M001.PCODE_NM
                                                  FROM TB_INV003 I003,
                                                       TB_MAS001 M001
                                                 WHERE I003.WERKS = M001.WERKS
                                                    AND I003.MATNR = M001.MATNR
                                                    AND I003.WERKS = P_WERKS
                                                    AND I003.MACH_CD = P_MACH_CD
                                                    AND I003.INP_DT BETWEEN P_PRD_STR_DATE AND P_PRD_END_DATE
                                                    AND I003.STCK_QTY > 0
                                                    AND M001.MATNR_DIV IN ('FERT', 'HALB')
                                                    --AND NVL(M001.PCODE,' ') LIKE '%' || P_PCODE || '%'
                                                    --AND TO_CHAR(NVL(M001.BS_WGT,0)) LIKE '%' || P_WEIGHT || '%'
                                                 GROUP BY I003.WERKS, I003.WRK_ORDR_NO, I003.WRK_ORDR_SEQNO, I003.MATNR, M001.PCODE, M001.PCODE_NM
                                                ) I003,
                                                TB_WRK002 W002
                                             WHERE I003.WERKS = W002.WERKS(+)
                                               AND I003.WRK_ORDR_NO = W002.WRK_ORDR_NO(+)
                                               AND I003.WRK_ORDR_SEQNO = W002.WRK_ORDR_SEQNO(+)  
                                               --AND W002.MACH_CD = P_MACH_CD
                                               AND NVL(W002.CNL_YN,'N') ='N'
                                            GROUP BY W002.WERKS, W002.WRK_ORDR_NO, W002.WRK_ORDR_SEQNO, W002.MATNR, W002.LOT_NO, /*W002.PRFM_DT,*/
                                                W002.WLEN, W002.VLEN, I003.PCODE, I003.PCODE_NM
                                         ) W000,
                                       TB_SCH017 S017
                                 WHERE W000.WERKS = S017.WERKS(+)
                                   AND W000.WRK_ORDR_NO     = S017.WRK_ORDR_NO(+)
                                   AND W000.WRK_ORDR_SEQNO  = S017.WRK_ORDR_SEQNO(+)
                                   --AND S017.COMP_YN         = 'Y'
                                   AND S017.VBELN           = P_VBELN
                                   AND S017.POSNR           = P_POSNR
                                   --AND NVL(S017.USE_YN,'Y') ='Y'
                )                   
                ORDER BY WRK_ORDR_NO DESC, WRK_ORDR_SEQNO DESC;

         END IF;
        --작업 정상 종료 코드 등록
        RS_CODE := 'S';
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
        --RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
       RAISE ;
        RS_CODE := 'E';
        RS_MSG  := SQLERRM;
        RETURN;
        --예외처리 종료
    END;
END;
/
