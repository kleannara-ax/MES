
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK32_LOT_MERGE_LIST" 
(
    P_WERKS         IN VARCHAR2             -- 플랜트 코드
,P_MACH_CD      IN VARCHAR2             -- 작업장코드(설비코드)
,P_PFROM_DT     IN VARCHAR2             -- 생산실적일자 (from)
,P_PTO_DT       IN VARCHAR2             -- 생산실적일자 (to)
,P_MATNR        IN VARCHAR2             -- 자재코드
,P_COLINFO      OUT VARCHAR2            -- grid 칼럼명
,P_COLTYPE      OUT VARCHAR2            -- grid 칼럼 데이터 타입
,Lang           IN VARCHAR2 DEFAULT 'KO'
,RS_CODE        OUT VARCHAR2
,RS_MSG         OUT VARCHAR2
,CUR_1          OUT SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : SP_POP_WRK32_LOT_MERGE_LIST
 * PROGRAM NAME  : 생산실적 이력 조회 (LOT병합)
 * VERSION       : 1.0.1
 * DESCRIPTION   : 생산실적 이력 조회 (LOT병합)
 *
 * AUTHOR NAME   : 김병무
 * CREATE DATE   : 2026/05/08
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description
 * ------------ ------- ------------- ------------------------------------------
 * 2026/05/08    1.0.0   김지언         Initial Version
 *==============================================================================
 *  관련 테이블
 * - [TB_WRK002] : (.R..) PS 생산실적 이력
 *=============================================================================*/
AS
    --프로그램 ID
    V_PRG_NM        VARCHAR2(100)  := 'SP_POP_WRK32_LOT_MERGE';     -- PROCEDURE NAME
    V_SESS_USER_ID   varchar2(20) := 'TEST'; --USERID
-- 오라클 에러 처리용 변수선언 영역
    E_EXCEPTION_USER  EXCEPTION;
    E_SQL_ERR_CD      NUMBER(5) := 0;
    E_SQL_ERR_MSG     VARCHAR2(4000);
    --내부변수 관리
BEGIN
    --예외처리 시작(try)
    BEGIN
        BEGIN
            -- 상단 grid 컬럼 정보 설정
            --컬럼설정
            P_COLINFO := '선택@C^50|설비호기@C^210|판매문서@C^130|판매문서항목번호@C^50|자재코드@C^260|LOT_NO@C^170|개별바코드@C^170|잔량@R^100|단위@R^80';
            P_COLTYPE := 'CHK@Button|MACH_NM@varchar|VBELN@varchar|POSNR@varchar|MATNR@varchar|LOT_NO@varchar|IND_BCD@varchar|SUM_STCK_QTY@varchar|UNIT@varchar';


            IF TRIM(P_PFROM_DT) IS NOT NULL
                AND TRIM(P_PTO_DT) IS NOT NULL THEN
                --결과 테이블 반환용 변수
                OPEN CUR_1 FOR
                    SELECT '-'                      AS CHK
                         , MAS012.MACH_NM           AS MACH_NM
    --                      , I003.MACH_CD             AS MACH_CD
                         , I001.VBELN               AS VBELN
                         , I001.POSNR               AS POSNR
                         , I003.MATNR               AS MATNR
                         , I003.LOT_NO              AS LOT_NO
                         , I003.IND_BCD             AS IND_BCD
                         , CASE
                               WHEN I003.UNIT = 'KG' AND SUBSTR(I003.MACH_CD, 1, 3) = 'PCB'
                                   THEN SUM(ROUND(I003.STCK_QTY / NULLIF((I003.WGT / NULLIF(I003.PRE_IN_QTY, 0)), 0), 3)) /
                                        500
                               WHEN I003.UNIT = 'R' THEN SUM(I003.STCK_QTY)
                               ELSE SUM(I003.STCK_QTY) / 500
                        END               AS SUM_STCK_QTY
                         , 'R'            AS UNIT
                    FROM TB_INV003 I003
                             INNER JOIN TB_INV001 I001 ON I001.LOT_NO = I003.LOT_NO
                        AND I001.IND_BCD = I003.IND_BCD
                        AND I001.MATNR = I003.MATNR
                        AND I001.WERKS = 'P100'
                        AND SUBSTR(I001.IND_BCD, 6, 1) = 'C'
                             LEFT OUTER JOIN TB_MAS001 M001 ON I003.MATNR = M001.MATNR
                             LEFT OUTER JOIN TB_MAS012 MAS012 ON I003.MACH_CD = MAS012.MACH_CD
                    WHERE 1 = 1
                      AND I003.REGDATE BETWEEN P_PFROM_DT AND TO_DATE(P_PTO_DT || ' 235959', 'YYYYMMDD HH24MISS')
                      AND I003.WERKS = P_WERKS
                      AND I003.MACH_CD = P_MACH_CD
                      AND SUBSTR(I003.IND_BCD, 6, 1) = 'C'
                      and I003.MATNR like '%' || P_MATNR || '%'
                      AND I003.STCK_QTY > 0
                    GROUP BY MAS012.MACH_NM, I001.VBELN, I001.POSNR, I003.MATNR, I003.LOT_NO, I003.IND_BCD, I003.UNIT, I003.MACH_CD
                    order by matnr, LOT_NO, IND_BCD;
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
            SP_PROC_ERROR(P_WERKS, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);

            RS_CODE := 'E';
            RS_MSG  := SQLERRM;
            RETURN;

        WHEN OTHERS THEN
            E_SQL_ERR_CD        := SQLCODE;
            E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';

            ROLLBACK;
            --RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
            RAISE;

            RS_CODE := 'E';
            RS_MSG  := SQLERRM;
            RETURN;
        --예외처리 종료
    END;
END SP_POP_WRK32_LOT_MERGE_LIST;
/
