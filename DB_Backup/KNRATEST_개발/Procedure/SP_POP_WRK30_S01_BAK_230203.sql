--------------------------------------------------------
--  DDL for Procedure SP_POP_WRK30_S01_BAK_230203
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_POP_WRK30_S01_BAK_230203" 
(
     P_WERKS    IN  VARCHAR2             -- 플랜트 코드
    ,P_PROC_CD  IN  VARCHAR2             -- 공정코드 (JA, MA, CA, PB_PC ...)
    ,P_MACH_CD  IN  VARCHAR2             -- 작업장코드(설비코드)
    ,P_SPRFM_DT	IN  VARCHAR2             -- 실적시작일자
    ,P_EPRFM_DT	IN	VARCHAR2			 --실적종료일자
    ,P_ORDER_NO IN  VARCHAR2             
    ,P_IND_BCD  IN  VARCHAR2  
    ,P_PCODE    IN  VARCHAR2
    ,P_BS_WGT   IN  VARCHAR2 
    ,P_WLEN     IN  VARCHAR2
    ,P_VLEN     IN  VARCHAR2
    ,P_COLINFO  OUT VARCHAR2        -- grid 칼럼명
    ,P_COLTYPE  OUT VARCHAR2        -- grid 칼럼 데이터 타입
    ,Lang       IN  VARCHAR2 DEFAULT 'KO'
    ,RS_CODE    OUT VARCHAR2 
    ,RS_MSG     OUT VARCHAR2 
    ,CUR_1      OUT SYS_REFCURSOR
)
/*==============================================================================
 * PROGRAM ID    : SP_POP_WRK30_S01
 * PROGRAM NAME  : 생산실적 이력 조회
 * VERSION       : 1.0.1
 * DESCRIPTION   : 생산실적 이력 조회
 *                 
 * AUTHOR NAME   : 김병무
 * CREATE DATE   : 2022/04/25
 * SYSTEM NAME   : POP
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}
 * SUB PROCEDURE : {하위 프로시저 명칭 기술}
 * SUB PACKAGES  : {하위 패키지 기술}
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/04/06    1.0.0   김병무         Initial Version
 * 2022/12/14    1.0.1   여한진         날짜 기간 추가
 *==============================================================================
 *  관련 테이블
 * - [TB_WRK001] : (.R..) HL 생산실적 이력
 * - [TB_WRK002] : (.R..) PS 생산실적 이력
 *=============================================================================*/
AS 
    --프로그램 ID
    V_PRG_NM        VARCHAR2(100)  := 'SP_POP_WRK30_S01';     -- PROCEDURE NAME
    V_PLT_CD         varchar2(2) := '99'; --PLANTCODE TEST
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
        IF P_PROC_CD = 'JA' THEN      -- 점보롤
            --grid 컬럼 정보 설정
            P_COLINFO := '선택@C^50|생산일시@C^190|개별바코드@C^130|오더번호@C^115|LOT_NO@H|자재코드@H|지종@C^90|지종명@H|평량@R^80|순번@H|작업지시번호@H|순번@H|단위@H|재고상태@C^80|재고상태@H|실적권치수@R^100|실적중량(KG)@R^110|폐품권치수@R^100|폐품중량(KG)@R^110|실지폭@H|선속(M/분)@R^90|반@C^50|상세보기@C^100|운전@C^110|생산시작일시@C^190|생산종료일시@C^190|가동시간(분)@R^100|실적일자@H|상태@H|비고@L^500|문서번호@H';
            P_COLTYPE := 'CHK@Button|PRD_DT@varchar|IND_BCD@varchar|ORDER_NO@varchar|LOT_NO@varchar|MATNR@varchar|PCODE@varchar|PCODE_NM@varchar|BS_WGT@varchar|ORDER_SEQNO@varchar|WRK_ORDR_NO@varchar|WRK_ORDR_SEQNO@varchar|UNIT@varchar|STCK_STA_NM@varchar|STCK_STA@varchar|ROLLCNT@varchar|WGT@varchar|DISPO_ROLLCNT@varchar|DISPO_WGT@varchar|WIDTH@varchar|SPM@varchar|WRK_CLASS@varchar|DBTN@Button|RUN_STA_NM@varchar|PRD_STR_DATE@varchar|PRD_END_DATE@varchar|TM@varchar|PRFM_DT@varchar|STA@varchar|RMK@varchar|SDOC_NO@varchar';
            --실적현황 조회
            OPEN CUR_1 FOR
            SELECT 
                  '-' AS CHK            --체크버튼
                , TO_CHAR(W002.REGDATE, 'YYYY-MM-DD HH24:MI:SS') AS PRD_DT -- 생산일자
                , W002.IND_BCD         --개별바코드
                , W002.ORDER_NO        --오더번호
                , W002.LOT_NO          --LOT_NO
                , W002.MATNR           --자재코드
                , M001.PCODE            --지종
                , M001.PCODE_NM         --지종명
                , TO_CHAR(M001.BS_WGT, 'fm999,999,999,990')              AS BS_WGT   --평량
                , W002.ORDER_SEQNO     --오더번호 순번
                , W002.WRK_ORDR_NO     --작업지시번호
                , W002.WRK_ORDR_SEQNO  --작업지시 순번
                , W002.UNIT            --실적단위
                --, (SELECT CDESC1 FROM CMCDV WHERE CMCDKY = 'STCK_STA' AND CMCDVL = I001.STCK_STA) AS STCK_STA_NM
                , NVL((SELECT CDESC1 FROM CMCDV WHERE CMCDKY = 'STCK_STA' AND CMCDVL = I001.STCK_STA), '폐품') AS STCK_STA_NM
                , I001.STCK_STA                                                 AS STCK_STA
                , CASE WHEN PRFM_GTHR_YN = 'Y' THEN NVL(RTRIM(TO_CHAR(W002.ROLLCNT, 'fm999,999,999,999,990.999'), '.'), '0') ELSE '0' END  AS ROLLCNT	        --실적권치수
                , CASE WHEN PRFM_GTHR_YN = 'Y' THEN NVL(RTRIM(TO_CHAR(W002.WGT, 'fm999,999,999,999,990.999'), '.'), '0') ELSE '0' END      AS WGT	            --실적중량
                , NVL(RTRIM(TO_CHAR(W004.ROLLCNT, 'fm999,999,999,999,990.999'), '.'), '0')   AS DISPO_ROLLCNT	--폐품권치수
                , NVL(RTRIM(TO_CHAR(W004.WGT, 'fm999,999,999,999,990.999'), '.'), '0')       AS DISPO_WGT	    --폐품중량
                , NVL(RTRIM(TO_CHAR(W002.WIDTH, 'fm999,999,999,999,990.999'), '.'), '0')     AS WIDTH	        --실지폭
                --, NVL(TO_CHAR(ROUND(W002.ROLLCNT / W002.TM), 'fm999,999,999,990'), '0')  AS SPM	        --선속(분)
                , TO_CHAR(W002.RSPEED, 'fm999,999,999,990')              AS SPM                    --선속(분)
                , W002.WRK_CLASS || '반'     AS WRK_CLASS     --반
                , '상세보기' AS DBTN      --상세보기 버튼
                , CASE WHEN W002.RUN_STA = '00' THEN ( SELECT CDESC1 FROM CMCDV WHERE CMCDKY = 'RUN_STA' AND CMCDVL = W004.RUN_STA ) 
                                            ELSE ( SELECT CDESC1 FROM CMCDV WHERE CMCDKY = 'RUN_STA' AND CMCDVL = W002.RUN_STA )END AS RUN_STA_NM       --운전상태
                , TO_CHAR(W002.PRD_STR_DATE,'YYYY-MM-DD HH24:MI:SS') AS PRD_STR_DATE    --생산시작 일시
                , TO_CHAR(W002.PRD_END_DATE,'YYYY-MM-DD HH24:MI:SS') AS PRD_END_DATE    --생산 종료 일시
                , TO_CHAR(W002.TM, 'fm999,999,999,990')              AS TM                    --생산시간(분)
                , TO_CHAR(TO_DATE(W002.PRFM_DT,'YYYYMMDD'),'YYYY-MM-DD') AS PRFM_DT         --실적일자
                , W002.RUN_STA                                       AS STA     --, W002.STA             --상태 (점보롤의경우 W002.STA값이 항상 '00' 이여서 RUN_STA 값을 확인 하도록 수정)
                , W002.RMK             --비고
                , 'DUMMY'    SDOC_NO
            FROM  TB_WRK002 W002    --PS실적
                , (SELECT SUM(ROLLCNT) AS ROLLCNT, SUM(WGT) AS WGT, IND_BCD, WERKS, MACH_CD, RUN_STA FROM TB_WRK004
                        WHERE WERKS = P_WERKS
                        AND MACH_CD = P_MACH_CD
                        AND NVL(CNL_YN,'N') = 'N'
                    GROUP BY WERKS, MACH_CD, IND_BCD, RUN_STA) W004    --PS폐품실적            
                , TB_INV001 I001    --창고별 재고관리
                , TB_MAS001 M001    --자재마스터
            WHERE 1=1
            AND W002.WERKS = W004.WERKS(+)         
            AND W002.MACH_CD = W004.MACH_CD(+)         
            AND W002.IND_BCD = W004.IND_BCD(+)         
            AND W002.MACH_CD = I001.MACH_CD(+)         
            AND W002.IND_BCD = I001.IND_BCD(+)         
            AND W002.WERKS = M001.WERKS(+)         
            AND W002.MATNR = M001.MATNR(+)         
            AND W002.WERKS = P_WERKS            --플랜트코드
            AND W002.MACH_CD = P_MACH_CD        --작업장코드(설비코드)
            AND W002.PRFM_DT BETWEEN P_SPRFM_DT AND P_EPRFM_DT       --실적일자
            AND NVL(W002.CNL_YN,'N') = 'N'
            AND NVL(W002.IND_BCD,' ') LIKE '%' || P_IND_BCD || '%'
            AND NVL(W002.ORDER_NO,' ') LIKE '%' || P_ORDER_NO || '%'
            AND NVL(M001.PCODE   ,' ') LIKE '%' || P_PCODE || '%'
            AND TO_CHAR(NVL(M001.BS_WGT,0)) LIKE '%' || P_BS_WGT || '%'
            AND TO_CHAR(NVL(M001.WLEN,0)) LIKE '%' || P_WLEN || '%'
            AND TO_CHAR(NVL(M001.VLEN,0)) LIKE '%' || P_VLEN || '%'
            ORDER BY PRD_DT DESC, W002.PRD_STR_DATE DESC, W002.PRD_END_DATE DESC, W002.WRK_ORDR_NO DESC, W002.WRK_ORDR_SEQNO DESC;
        ELSIF P_PROC_CD = 'MA' THEN      -- 리와인더
            --grid 컬럼 정보 설정
            P_COLINFO := '선택@C^50|생산일시@C^190|개별바코드@C^130|오더번호@C^130|LOT_NO@H|재고상태@C^80|순번@H|지종@C^90|지종명@H|평량@R^80|규격@C^100|작업지시번호@H|순번@H|단위@H|실적권치수@R^100|실적중량(KG)@R^110|폐품권치수@R^100|폐품중량(KG)@R^110|실지폭@H|상세보기@C^100|자재코드@C^190|생산시작 일시@H|생산 종료 일시@H|가동시간(분)@H|실적일자@H|반@H|상태@H|비고@L^500|문서번호@H';
            P_COLTYPE := 'CHK@Button|PRD_DT@varchar|IND_BCD@varchar|ORDER_NO@varchar|LOT_NO@varchar|STCK_STA_NM@varchar|ORDER_SEQNO@varchar|PCODE@varchar|PCODE_NM@varchar|BS_WGT@varchar|MATNR_SPEC@varchar|WRK_ORDR_NO@varchar|WRK_ORDR_SEQNO@varchar|UNIT@varchar|ROLLCNT@varchar|WGT@varchar|DISPO_ROLLCNT@varchar|DISPO_WGT@varchar|WIDTH@varchar|DBTN@Button|MATNR@varchar|PRD_STR_DATE@varchar|PRD_END_DATE@varchar|TM@varchar|PRFM_DT@varchar|WRK_CLASS@varchar|STA@varchar|RMK@varchar|SDOC_NO@varchar';
            --실적현황 조회
            OPEN CUR_1 FOR
            SELECT
                          CHK            --체크버튼
                         ,PRD_DT
                         ,IND_BCD  --개별바코드
                         ,ORDER_NO  --오더번호
                         ,LOT_NO  --LOT_NO
                         ,STCK_STA_NM   --재고상태
                         ,ORDER_SEQNO  --오더번호 순번
                         ,PCODE   --지종
                         ,PCODE_NM   --지종명
                         ,BS_WGT   --평량
                         ,MATNR_SPEC     --규격
                         ,WRK_ORDR_NO  --작업지시번호
                         ,WRK_ORDR_SEQNO --작업지시 순번
                         ,UNIT --실적단위
                         ,NVL(ROLLCNT,0) AS ROLLCNT	        --실적권치수
                         ,NVL(WGT,0)    AS WGT	            --실적중량
                         ,DISPO_ROLLCNT	--폐품권치수
                         ,DISPO_WGT	    --폐품중량
                         ,WIDTH	        --실지폭
                        , DBTN      --상세보기 버튼
                         ,MATNR  --자재코드
                        , PRD_STR_DATE    --생산시작 일시
                        , PRD_END_DATE    --생산 종료 일시
                        , TM              --생산시간(분)
                        , PRFM_DT         --실적일자
                        , WRK_CLASS  --반
                        , STA  --상태
                        , RMK   --비고      
                        , SDOC_NO
            FROM
            (
                    SELECT
                          '-' AS CHK            --체크버튼
                         , TO_CHAR(W002.REGDATE, 'YYYY-MM-DD HH24:MI:SS') AS PRD_DT -- 생산일자 
                         , W002.IND_BCD       IND_BCD  --개별바코드
                         , W002.LOT_NO        LOT_NO  --LOT_NO
                         , (SELECT CDESC1 FROM CMCDV WHERE CMCDKY = 'STCK_STA' AND CMCDVL = I001.STCK_STA) AS STCK_STA_NM
                         , W002.ORDER_NO      ORDER_NO  --오더번호
                         , W002.ORDER_SEQNO   ORDER_SEQNO  --오더번호 순번
                         , M001.PCODE         PCODE   --지종
                         , M001.PCODE_NM      PCODE_NM   --지종명
                         , TO_CHAR(M001.BS_WGT, 'fm999,999,999,990')              AS BS_WGT   --평량
                         , SUBSTR(M001.MATNR, 10, 4) || '*0'                    AS MATNR_SPEC                    --규격
                         , W002.WRK_ORDR_NO   WRK_ORDR_NO  --작업지시번호
                         , W002.WRK_ORDR_SEQNO  WRK_ORDR_SEQNO --작업지시 순번
                         , W002.UNIT           UNIT --실적단위
                         ,NVL(RTRIM(TO_CHAR(W002.ROLLCNT, 'fm999,999,999,999,990.999'), '.'), '0')   AS ROLLCNT	        --실적권치수
                         ,NVL(RTRIM(TO_CHAR(W002.WGT, 'fm999,999,999,999,990.999'), '.'), '0')       AS WGT	            --실적중량
                         ,NVL(RTRIM(TO_CHAR(W004.ROLLCNT, 'fm999,999,999,999,990.999'), '.'), '0')   AS DISPO_ROLLCNT	--폐품권치수
                         ,NVL(RTRIM(TO_CHAR(W004.WGT, 'fm999,999,999,999,990.999'), '.'), '0')       AS DISPO_WGT	    --폐품중량
                         ,NVL(RTRIM(TO_CHAR(W002.WIDTH, 'fm999,999,999,999,990.999'), '.'), '0')     AS WIDTH	        --실지폭
                        , '상세보기' AS DBTN      --상세보기 버튼
                        , W002.MATNR         MATNR  --자재코드
                        , TO_CHAR(W002.PRD_STR_DATE,'YYYY-MM-DD HH24:MI:SS') AS PRD_STR_DATE    --생산시작 일시
                        , TO_CHAR(W002.PRD_END_DATE,'YYYY-MM-DD HH24:MI:SS') AS PRD_END_DATE    --생산 종료 일시
                        , TO_CHAR(W002.TM, 'fm999,999,999,990')              AS TM                    --생산시간(분)
                        , TO_CHAR(TO_DATE(W002.PRFM_DT,'YYYYMMDD'),'YYYY-MM-DD') AS PRFM_DT         --실적일자
                        , W002.WRK_CLASS     WRK_CLASS  --반
                        , W002.STA           STA  --상태
                        , W002.RMK           RMK   --비고
                        , 'DUMMY'           SDOC_NO
                    FROM  TB_WRK002 W002    --PS실적
                        , (SELECT SUM(ROLLCNT) AS ROLLCNT, SUM(WGT) AS WGT, IND_BCD, WERKS, MACH_CD FROM TB_WRK004
                                WHERE WERKS = P_WERKS
                                AND MACH_CD = P_MACH_CD
                                AND NVL(CNL_YN,'N') = 'N'
                            GROUP BY WERKS, MACH_CD, IND_BCD) W004    --PS폐품실적
                        , TB_INV001 I001    --창고별 재고관리
                        , TB_MAS001 M001    --자재마스터
                        , TB_SCH016 S016
                    WHERE 1=1
                    AND W002.WERKS = W004.WERKS(+)         
                    AND W002.MACH_CD = W004.MACH_CD(+)         
                    AND W002.IND_BCD = W004.IND_BCD(+)         
                    AND W002.MACH_CD = I001.MACH_CD(+)         
                    AND W002.IND_BCD = I001.IND_BCD(+)         
                    AND W002.WERKS   = M001.WERKS(+)         
                    AND W002.MATNR   = M001.MATNR(+)         
                    AND W002.WRK_ORDR_NO = S016.WRK_ORDR_NO(+)
                    AND W002.WRK_ORDR_SEQNO = S016.WRK_ORDR_SEQNO(+)
                    AND W002.WERKS   = P_WERKS            --플랜트코드
                    AND W002.MACH_CD = P_MACH_CD        --작업장코드(설비코드)
                    AND W002.PRFM_DT BETWEEN P_SPRFM_DT AND P_EPRFM_DT       --실적일자
                    AND NVL(W002.CNL_YN,'N') = 'N'
                    AND NVL(W002.IND_BCD,' ') LIKE '%' || P_IND_BCD || '%'
                    AND NVL(W002.ORDER_NO,' ') LIKE '%' || P_ORDER_NO || '%'
                    AND NVL(M001.PCODE   ,' ') LIKE '%' || P_PCODE || '%'
                    AND TO_CHAR(NVL(M001.BS_WGT,0)) LIKE '%' || P_BS_WGT || '%'
                    AND TO_CHAR(NVL(M001.WLEN,0)) LIKE '%' || P_WLEN || '%'
                    AND TO_CHAR(NVL(M001.VLEN,0)) LIKE '%' || P_VLEN || '%'
                    UNION ALL
                    SELECT
                          '-' AS CHK            --체크버튼
                         , TO_CHAR(W004.REGDATE, 'YYYY-MM-DD HH24:MI:SS') AS PRD_DT -- 생산일자 
                         , W004.IND_BCD       IND_BCD  --개별바코드
                         , W004.LOT_NO        LOT_NO  --LOT_NO
                         , NVL((SELECT CDESC1 FROM CMCDV WHERE CMCDKY = 'STCK_STA' AND CMCDVL = I001.STCK_STA),'폐품') AS STCK_STA_NM
                         , NULL               ORDER_NO  --오더번호
                         , NULL   ORDER_SEQNO  --오더번호 순번
                         , M001.PCODE         PCODE   --지종
                         , M001.PCODE_NM      PCODE_NM   --지종명
                         , TO_CHAR(M001.BS_WGT, 'fm999,999,999,990')              AS BS_WGT   --평량
                         , SUBSTR(M001.MATNR, 10, 4) || '*0'                    AS MATNR_SPEC                    --규격
                         , W004.WRK_ORDR_NO   WRK_ORDR_NO  --작업지시번호
                         , W004.WRK_ORDR_SEQNO  WRK_ORDR_SEQNO --작업지시 순번
                         , W004.UNIT           UNIT --실적단위
                         ,NULL   AS ROLLCNT	        --실적권치수
                         ,NULL   AS WGT	            --실적중량
                         ,NVL(RTRIM(TO_CHAR(W004_1.ROLLCNT, 'fm999,999,999,999,990.999'), '.'), '0')   AS DISPO_ROLLCNT	--폐품권치수
                         ,NVL(RTRIM(TO_CHAR(W004_1.WGT, 'fm999,999,999,999,990.999'), '.'), '0')       AS DISPO_WGT	    --폐품중량
                         ,NULL     AS WIDTH	        --실지폭
                        , '상세보기' AS DBTN      --상세보기 버튼
                        , W004.MATNR         MATNR  --자재코드
                        , TO_CHAR(W004.PRD_STR_DATE,'YYYY-MM-DD HH24:MI:SS') AS PRD_STR_DATE    --생산시작 일시
                        , TO_CHAR(W004.PRD_END_DATE,'YYYY-MM-DD HH24:MI:SS') AS PRD_END_DATE    --생산 종료 일시
                        , TO_CHAR(W004.TM, 'fm999,999,999,990')              AS TM                    --생산시간(분)
                        , TO_CHAR(TO_DATE(W004.PRFM_DT,'YYYYMMDD'),'YYYY-MM-DD') AS PRFM_DT         --실적일자
                        , W004.WRK_CLASS    WRK_CLASS  --반
                        , NULL              STA  --상태
                        , W004.RMK          RMK   --비고
                        , 'DUMMY'           SDOC_NO
                    FROM  TB_WRK004 W004    --PS실적
                        , (SELECT SUM(WRK004.ROLLCNT) AS ROLLCNT, SUM(WRK004.WGT) AS WGT, WRK004.IND_BCD, WRK004.WERKS, WRK004.MACH_CD FROM TB_WRK004 WRK004
                                WHERE  1=1
                                AND WERKS = P_WERKS
                                AND MACH_CD = P_MACH_CD
                                AND NVL(CNL_YN,'N') = 'N'
                            GROUP BY WRK004.WERKS, WRK004.MACH_CD, WRK004.IND_BCD) W004_1    --PS폐품실적
                        , TB_INV001 I001    --창고별 재고관리
                        , TB_MAS001 M001    --자재마스터
                        , TB_SCH016 S016
                    WHERE 1=1
                    AND W004.WERKS = W004_1.WERKS(+)         
                    AND W004.MACH_CD = W004_1.MACH_CD(+)         
                    AND W004.IND_BCD = W004_1.IND_BCD(+)         
                    AND W004.MACH_CD = I001.MACH_CD(+)         
                    AND W004.IND_BCD = I001.IND_BCD(+)         
                    AND W004.WERKS   = M001.WERKS(+)         
                    AND W004.MATNR   = M001.MATNR(+)         
                    AND W004.WRK_ORDR_NO = S016.WRK_ORDR_NO(+)
                    AND W004.WRK_ORDR_SEQNO = S016.WRK_ORDR_SEQNO(+)
                    AND W004.WERKS   = P_WERKS            --플랜트코드
                    AND W004.MACH_CD = P_MACH_CD        --작업장코드(설비코드)
                    AND W004.PRFM_DT BETWEEN P_SPRFM_DT AND P_EPRFM_DT       --실적일자
                    AND NVL(W004.CNL_YN,'N') = 'N'
                    AND NVL(W004.IND_BCD,' ') LIKE '%' || P_IND_BCD || '%'
                    AND NVL(W004.ORDER_NO,' ') LIKE '%' || P_ORDER_NO || '%'
                    AND NVL(M001.PCODE   ,' ') LIKE '%' || P_PCODE || '%'
                    AND TO_CHAR(NVL(M001.BS_WGT,0)) LIKE '%' || P_BS_WGT || '%'
                    AND TO_CHAR(NVL(M001.WLEN,0)) LIKE '%' || P_WLEN || '%'
                    AND TO_CHAR(NVL(M001.VLEN,0)) LIKE '%' || P_VLEN || '%'
                    AND NOT EXISTS
                        ( SELECT  'X'
                            FROM TB_WRK002 WRK002 
                            WHERE WRK002.WERKS    = W004.WERKS
                              AND WRK002.MACH_CD  = W004.MACH_CD
                              AND WRK002.IND_BCD  = W004.IND_BCD
                              AND NVL(WRK002.CNL_YN,'N') = 'N'
                        )  

            )         
            ORDER BY PRD_DT DESC, PRD_STR_DATE DESC, PRD_END_DATE DESC, IND_BCD DESC, WRK_ORDR_NO DESC, WRK_ORDR_SEQNO DESC;

        ELSIF P_PROC_CD = 'SA' THEN      -- 슬리터
            --grid 컬럼 정보 설정
            P_COLINFO := '선택@C^50|생산일시@C^190|개별바코드@C^130|LOT_NO@C^130|재고상태@C^80|지종@C^90|지종명@H|평량@R^80|규격@C^100|오더번호@C^120|순번@H|작업지시번호@H|순번@H|단위@H|실적권치수@R^100|실적중량(KG)@R^110|폐품권치수@R^100|폐품중량(KG)@R^110|실지폭@H|상세보기@C^100|자재코드@C^190|생산시작 일시@H|생산 종료 일시@H|가동시간(분)@R^100|실적일자@H|반@H|상태@H|비고@L^500|문서번호@H';
            P_COLTYPE := 'CHK@Button|PRD_DT@varchar|IND_BCD@varchar|LOT_NO@varchar|STCK_STA_NM@varchar|PCODE@varchar|PCODE_NM@varchar|BS_WGT@varchar|MATNR_SPEC@varchar|ORDER_NO@varchar|ORDER_SEQNO@varchar|WRK_ORDR_NO@varchar|WRK_ORDR_SEQNO@varchar|UNIT@varchar|ROLLCNT@varchar|WGT@varchar|DISPO_ROLLCNT@varchar|DISPO_WGT@varchar|WIDTH@varchar|DBTN@Button|MATNR@varchar|PRD_STR_DATE@varchar|PRD_END_DATE@varchar|TM@varchar|PRFM_DT@varchar|WRK_CLASS@varchar|STA@varchar|RMK@varchar|SDOC_NO@varchar';
            --실적현황 조회
            OPEN CUR_1 FOR
            SELECT  
                   CHK              --체크버튼
                 , PRD_DT
                 , IND_BCD          --개별바코드
                 , LOT_NO           --LOT_NO
                 , STCK_STA_NM      --반제품 상태
                 , PCODE            --지종
                 , PCODE_NM         --지종명
                 , BS_WGT           --평량
                 , MATNR_SPEC     --규격
                 , ORDER_NO         --오더번호
                 , ORDER_SEQNO      --오더번호 순번
                 , WRK_ORDR_NO      --작업지시번호
                 , WRK_ORDR_SEQNO   --작업지시 순번
                 , UNIT             --실적단위
                 , ROLLCNT	        --실적권치수
                 , WGT	            --실적중량
                 , DISPO_ROLLCNT	--폐품권치수
                 , DISPO_WGT	    --폐품중량
                 , WIDTH	        --실지폭
                 , DBTN             --상세보기 버튼
                 , MATNR            --자재코드
                 , PRD_STR_DATE     --생산시작 일시
                 , PRD_END_DATE     --생산 종료 일시
                 , TM               --생산시간(분)
                 , PRFM_DT          --실적일자
                 , WRK_CLASS        --반
                 , STA              --상태
                 , RMK              --비고
                 , SDOC_NO          --SAP 확정문서
            FROM 
              (
                SELECT
                      '-' AS CHK                    --체크버튼
                     , TO_CHAR(W002.REGDATE, 'YYYY-MM-DD HH24:MI:SS') AS PRD_DT -- 생산일자
                     , W002.IND_BCD        IND_BCD  --개별바코드
                     , W002.LOT_NO         LOT_NO   --LOT_NO
                     , (SELECT CDESC1 FROM CMCDV WHERE CMCDKY = 'STCK_STA' AND CMCDVL = I001.STCK_STA) AS STCK_STA_NM
                     , M001.PCODE          PCODE      --지종
                     , M001.PCODE_NM       PCODE_NM   --지종명
                     , TO_CHAR(M001.BS_WGT, 'fm999,999,999,990')  BS_WGT   --평량
                     , SUBSTR(M001.MATNR, 10, 4) || '*0'          MATNR_SPEC                    --규격
                     , W002.ORDER_NO       ORDER_NO        --오더번호
                     , W002.ORDER_SEQNO    ORDER_SEQNO     --오더번호 순번
                     , W002.WRK_ORDR_NO    WRK_ORDR_NO     --작업지시번호
                     , W002.WRK_ORDR_SEQNO WRK_ORDR_SEQNO  --작업지시 순번
                     , W002.UNIT           UNIT            --실적단위
                     ,NVL(RTRIM(TO_CHAR(W002.ROLLCNT, 'fm999,999,999,999,990.999'), '.'), '0')   AS ROLLCNT	        --실적권치수
                     ,NVL(RTRIM(TO_CHAR(W002.WGT, 'fm999,999,999,999,990.999'), '.'), '0')       AS WGT	            --실적중량
                     ,NVL(RTRIM(TO_CHAR(W004.ROLLCNT, 'fm999,999,999,999,990.999'), '.'), '0')   AS DISPO_ROLLCNT	--폐품권치수
                     ,NVL(RTRIM(TO_CHAR(W004.WGT, 'fm999,999,999,999,990.999'), '.'), '0')       AS DISPO_WGT	    --폐품중량
                     ,NVL(RTRIM(TO_CHAR(W002.WIDTH, 'fm999,999,999,999,990.999'), '.'), '0')     AS WIDTH	        --실지폭
                    , '상세보기'         AS DBTN      --상세보기 버튼
                    , W002.MATNR          MATNR    --자재코드
                    , TO_CHAR(W002.PRD_STR_DATE,'YYYY-MM-DD HH24:MI:SS') AS PRD_STR_DATE    --생산시작 일시
                    , TO_CHAR(W002.PRD_END_DATE,'YYYY-MM-DD HH24:MI:SS') AS PRD_END_DATE    --생산 종료 일시
                    , TO_CHAR(W002.TM, 'fm999,999,999,990')              AS TM              --생산시간(분)
                    , TO_CHAR(TO_DATE(W002.PRFM_DT,'YYYYMMDD'),'YYYY-MM-DD') AS PRFM_DT     --실적일자
                    , W002.WRK_CLASS    WRK_CLASS   --반
                    , W002.STA          STA         --상태
                    , W002.RMK          RMK         --비고
                    , 'DUMMY'    SDOC_NO
                FROM  TB_WRK002 W002    --PS실적
                    , ( SELECT SUM(ROLLCNT) AS ROLLCNT, SUM(WGT) AS WGT, IND_BCD, WERKS, MACH_CD 
                          FROM TB_WRK004
                         WHERE WERKS   = P_WERKS
                           AND MACH_CD = P_MACH_CD
                           AND NVL(CNL_YN,'N') = 'N'
                         GROUP BY WERKS, MACH_CD, IND_BCD) W004    --PS폐품실적
                    , TB_INV001 I001    --창고별 재고관리
                    , TB_MAS001 M001    --자재마스터
                WHERE 1=1
                AND W002.WERKS = W004.WERKS(+)         
                AND W002.MACH_CD = W004.MACH_CD(+)         
                AND W002.IND_BCD = W004.IND_BCD(+)         
                AND W002.MACH_CD = I001.MACH_CD(+)         
                AND W002.IND_BCD = I001.IND_BCD(+)         
                AND W002.WERKS = M001.WERKS(+)         
                AND W002.MATNR = M001.MATNR(+)         
                AND W002.WERKS = P_WERKS            --플랜트코드
                AND W002.MACH_CD = P_MACH_CD        --작업장코드(설비코드)
                AND W002.PRFM_DT BETWEEN P_SPRFM_DT AND P_EPRFM_DT       --실적일자
                AND NVL(W002.CNL_YN,'N') = 'N'
                AND NVL(W002.IND_BCD,' ') LIKE '%' || P_IND_BCD || '%'
                AND NVL(W002.ORDER_NO,' ') LIKE '%' || P_ORDER_NO || '%'
                AND NVL(M001.PCODE   ,' ') LIKE '%' || P_PCODE || '%'
                AND TO_CHAR(NVL(M001.BS_WGT,0)) LIKE '%' || P_BS_WGT || '%'
                AND TO_CHAR(NVL(M001.WLEN,0)) LIKE '%' || P_WLEN || '%'
                AND TO_CHAR(NVL(M001.VLEN,0)) LIKE '%' || P_VLEN || '%'
               UNION ALL   -- 폐품만 등록된 폐품 실적 추가
                SELECT
                      '-'                  CHK             --체크버튼
                     , TO_CHAR(W004.REGDATE, 'YYYY-MM-DD HH24:MI:SS') AS PRD_DT -- 생산일자
                     , W004.IND_BCD        IND_BCD         --개별바코드
                     , W004.LOT_NO         LOT_NO          --LOT_NO
                     , '폐품'              STCK_STA_NM
                     , M001.PCODE          PCODE           --지종
                     , M001.PCODE_NM       PCODE_NM        --지종명
                     , TO_CHAR(M001.BS_WGT, 'fm999,999,999,990')  BS_WGT   --평량
                     , SUBSTR(M001.MATNR, 10, 4) || '*0'          MATNR_SPEC                    --규격
                     , W004.ORDER_NO       ORDER_NO        --오더번호
                     , null                ORDER_SEQNO     --오더번호 순번
                     , W004.WRK_ORDR_NO    WRK_ORDR_NO     --작업지시번호
                     , W004.WRK_ORDR_SEQNO WRK_ORDR_SEQNO  --작업지시 순번
                     , W004.UNIT           UNIT            --실적단위
                     , null                ROLLCNT	       --실적권치수
                     , null                WGT	           --실적중량
                     , NVL(RTRIM(TO_CHAR(W004.ROLLCNT, 'fm999,999,999,999,990.999'), '.'), '0')   AS DISPO_ROLLCNT	--폐품권치수
                     , NVL(RTRIM(TO_CHAR(W004.WGT, 'fm999,999,999,999,990.999'), '.'), '0')       AS DISPO_WGT	    --폐품중량
                     , null                WIDTH	       --실지폭
                     , '상세보기'           DBTN            --상세보기 버튼
                     , W004.MATNR          MATNR           --자재코드
                     , TO_CHAR(W004.PRD_STR_DATE,'YYYY-MM-DD HH24:MI:SS') AS PRD_STR_DATE    --생산시작 일시
                     , TO_CHAR(W004.PRD_END_DATE,'YYYY-MM-DD HH24:MI:SS') AS PRD_END_DATE    --생산 종료 일시
                     , TO_CHAR(W004.TM, 'fm999,999,999,990')              AS TM              --생산시간(분)
                     , TO_CHAR(TO_DATE(W004.PRFM_DT,'YYYYMMDD'),'YYYY-MM-DD') AS PRFM_DT     --실적일자
                     , W004.WRK_CLASS       --반
                     , null  as STA         --상태
                     , W004.RMK             --비고
                     , 'DUMMY'    SDOC_NO
                FROM TB_WRK004 W004
                   , TB_MAS001 M001    --자재마스터
                WHERE 1=1             
                AND W004.WERKS   = M001.WERKS(+)         
                AND W004.MATNR   = M001.MATNR(+)         
                AND W004.WERKS   = P_WERKS            --플랜트코드
                AND W004.MACH_CD = P_MACH_CD        --작업장코드(설비코드)
                AND W004.PRFM_DT BETWEEN P_SPRFM_DT AND P_EPRFM_DT       --실적일자
                AND NVL(W004.CNL_YN,'N') = 'N'
                AND NVL(W004.IND_BCD,' ') LIKE '%' || P_IND_BCD || '%'
                AND NVL(W004.ORDER_NO,' ') LIKE '%' || P_ORDER_NO || '%'
                AND NVL(M001.PCODE   ,' ') LIKE '%' || P_PCODE || '%'
                AND TO_CHAR(NVL(M001.BS_WGT,0)) LIKE '%' || P_BS_WGT || '%'
                AND TO_CHAR(NVL(M001.WLEN,0)) LIKE '%' || P_WLEN || '%'
                AND TO_CHAR(NVL(M001.VLEN,0)) LIKE '%' || P_VLEN || '%'
                AND NOT EXISTS ( SELECT 1
                                   FROM TB_WRK002
                                  WHERE WERKS   = W004.WERKS
                                    AND MACH_CD = W004.MACH_CD
                                    AND IND_BCD = W004.IND_BCD 
                                    AND NVL(CNL_YN,'N') = 'N'
                                    )
             )
            ORDER BY PRD_DT DESC, PRD_STR_DATE DESC, PRD_END_DATE DESC, IND_BCD DESC, WRK_ORDR_NO DESC, WRK_ORDR_SEQNO DESC;

        ELSIF P_PROC_CD = 'CA' THEN      -- 재단
            --grid 컬럼 정보 설정
            P_COLINFO := '선택@C^50|생산일시@C^190|개별바코드@C^130|LOT_NO@C^130|재고상태@C^80|지종@C^80|지종명@H|평량@C^80|규격@C^110|생산순번@R^80|오더번호@H|순번@H|작업지시번호@H|순번@H|단위@H|실적연수@R^100|실적중량(KG)@R^120|폐품연수@R^100|폐품중량(KG)@R^120|상세보기@C^100|운전@C^90|자재코드@C^200|생산시작일시@H|생산종료일시@H|가동시간(분)@H|실적일자@H|반@H|상태@H|비고@L^500|완료여부@H|라벨병합@H|문서번호@C^100';
            P_COLTYPE := 'CHK@Button|PRD_DT@varchar|IND_BCD@varchar|LOT_NO@varchar|STCK_STA_NM@varchar|PCODE@varchar|PCODE_NM@varchar|BS_WGT@varchar|MATNR_SPEC@varchar|WRK_SEQ@varchar|ORDER_NO@varchar|ORDER_SEQNO@varchar|WRK_ORDR_NO@varchar|WRK_ORDR_SEQNO@varchar|UNIT@varchar|PRFM_QTY@varchar|WGT@varchar|DISPO_QTY@varchar|DISPO_WGT@varchar|DBTN@Button|MATNR@varchar|RUN_STA_NM@varchar|PRD_STR_DATE@varchar|PRD_END_DATE@varchar|TM@varchar|PRFM_DT@varchar|WRK_CLASS@varchar|STA@varchar|RMK@varchar|COMP_YN@varchar|MER_YN@varchar|SDOC_NO@varchar';
            --실적현황 조회
            OPEN CUR_1 FOR
            SELECT
                CHK              --체크버튼
               , PRD_DT
               , IND_BCD         --개별바코드
               , LOT_NO          --LOT_NO
               , STCK_STA_NM   --재고상태
               , PCODE           --지종
               , PCODE_NM        --지종명
               , BS_WGT          --평량
               , MATNR_SPEC     --규격
               , WRK_SEQ             --생산순번
               , ORDER_NO        --오더번호
               , ORDER_SEQNO     --오더번호 순번
               , WRK_ORDR_NO     --작업지시번호
               , WRK_ORDR_SEQNO  --작업지시 순번
               , UNIT            --실적단위
               , PRFM_QTY	     --실적연수
               , WGT	         --실적중량
               , DISPO_QTY	     --폐품연수
               , DISPO_WGT	     --폐품수량
               , DBTN            --상세보기 버튼
               , RUN_STA_NM      --운전상태
               , MATNR           --자재코드
               , PRD_STR_DATE    --생산시작 일시
               , PRD_END_DATE    --생산 종료 일시
               , TM              --생산시간(분)
               , PRFM_DT         --실적일자
               , WRK_CLASS       --반
               , STA             --상태
               --, DOC_NO          --MES 문서번호
               --, DOC_SEQNO       --MES 문서번호 순번
               --, SDOC_NO         --SAP 확정문서번호
               , RMK             --비고
               , COMP_YN         --작업완료
               , MER_YN          --라벨병합
               , SDOC_NO
            FROM
            (
                        SELECT 
                              '-'                               CHK             --체크버튼
                            , TO_CHAR(W002.REGDATE, 'YYYY-MM-DD HH24:MI:SS') AS PRD_DT -- 생산일자
                            , W002.IND_BCD                      IND_BCD         --개별바코드
                            , W002.LOT_NO                       LOT_NO          --LOT_NO
                            , (SELECT CDESC1 FROM CMCDV WHERE CMCDKY = 'STCK_STA' AND CMCDVL = I001.STCK_STA) AS STCK_STA_NM    --재고상태
                            , M001.PCODE                        PCODE           --지종
                            , M001.PCODE_NM                     PCODE_NM        --지종명
                            , TO_CHAR(M001.BS_WGT, 'fm999,999,999,990')              AS BS_WGT   --평량
                            , SUBSTR(M001.MATNR, 10, 4) || '*' || SUBSTR(M001.MATNR, 14, 4)       MATNR_SPEC
                            , W002.WRK_SEQ                      WRK_SEQ             --생산순번
                            , W002.ORDER_NO                     ORDER_NO        --오더번호
                            , W002.ORDER_SEQNO                  ORDER_SEQNO     --오더번호 순번
                            , W002.WRK_ORDR_NO                  WRK_ORDR_NO     --작업지시번호
                            , W002.WRK_ORDR_SEQNO               WRK_ORDR_SEQNO  --작업지시 순번
                            , W002.UNIT                         UNIT            --실적단위
                            --, ROUND(FN_CHG_UNIT (  W002.MATNR, P_WERKS, W002.UNIT, 'R', NVL(W002.PRFM_QTY, 0)),3)      PRFM_QTY         --사용량               
                            , NVL(RTRIM(TO_CHAR(W002.PRFM_QTY/500, 'fm999,999,999,999,990.999'), '.'), '0')   AS PRFM_QTY	    --실적연수

                            --,ROUND(FN_CHG_UNIT (  MATNR, P_WERKS, UNIT, 'R', NVL(W002.WGT,0)) ,3)           WGT          --투입량
                            , NVL(RTRIM(TO_CHAR(W002.WGT, 'fm999,999,999,999,990.999'), '.'), '0')       AS WGT	            --실적중량
                            , '0' --NVL(REGEXP_REPLACE(REVERSE(REGEXP_REPLACE(REVERSE(TO_CHAR(W004.DISPO_QTY)), '(\d{3})','\1,')), '^,',''), '0')  
                                                                DISPO_QTY	    --폐품연수
                            , '0' --NVL(REGEXP_REPLACE(REVERSE(REGEXP_REPLACE(REVERSE(TO_CHAR(W004.WGT)), '(\d{3})','\1,')), '^,',''), '0')  
                                                                DISPO_WGT	    --폐품수량
                            , '상세보기'                          DBTN            --상세보기 버튼
--                            , (SELECT CDESC1 FROM CMCDV WHERE CMCDKY = 'RUN_STA' AND CMCDVL = W002.RUN_STA) AS RUN_STA_NM      --운전상태
                            , CASE WHEN W002.RUN_STA = '09' THEN '여유생산'
                                            ELSE ( SELECT CDESC1 FROM CMCDV WHERE CMCDKY = 'RUN_STA' AND CMCDVL = W002.RUN_STA )END AS RUN_STA_NM       --운전상태
                            , W002.MATNR                        MATNR           --자재코드
                            , TO_CHAR(W002.PRD_STR_DATE,'YYYY-MM-DD HH24:MI:SS')  
                                                                PRD_STR_DATE    --생산시작 일시
                            , TO_CHAR(W002.PRD_END_DATE,'YYYY-MM-DD HH24:MI:SS')  
                                                                PRD_END_DATE    --생산 종료 일시
                            , TO_CHAR(W002.TM, 'fm999,999,999,990') TM                    --생산시간(분)
                            --, W002.TM                           TM   --생산시간(분)
                            , TO_CHAR(TO_DATE(W002.PRFM_DT,'YYYYMMDD'),'YYYY-MM-DD')  
                                                                PRFM_DT         --실적일자
                            , W002.WRK_CLASS                    WRK_CLASS       --반
                            , W002.STA                          STA             --상태
                            --, W002.DOC_NO                       DOC_NO          --MES 문서번호
                            --, W002.DOC_SEQNO                    DOC_SEQNO       --MES 문서번호 순번
                            --, W002.SDOC_NO                      SDOC_NO         --SAP 확정문서번호
                            , W002.RMK                          RMK             --비고
                            , S017.COMP_YN                      COMP_YN
                            , W002.MER_YN                       MER_YN
                            , CASE WHEN W002.SDOC_NO  IS NULL  THEN 'E'
                                   WHEN W002.SDOC_NO  = 'E'    THEN 'E'
                                   ELSE                             W002.SDOC_NO  
                               END                            SDOC_NO         --SAP 확정문서번호                                  
                        FROM  TB_WRK002 W002    --PS실적
                            --, (SELECT SUM(DISPO_QTY) AS DISPO_QTY, SUM(WGT) AS WGT, IND_BCD, WERKS, MACH_CD 
                            --        FROM TB_WRK004
                            --        WHERE WERKS = P_WERKS
                            --        AND MACH_CD = P_MACH_CD
                            --    GROUP BY WERKS, MACH_CD, IND_BCD) W004    --PS폐품실적
                            , TB_SCH017 S017
                            , TB_INV001 I001    --창고별 재고관리
                            , TB_MAS001 M001    --자재마스터
                        WHERE 1=1
                        --AND W002.WERKS = W004.WERKS(+)         
                        --AND W002.MACH_CD = W004.MACH_CD(+)         
                        --AND W002.IND_BCD = W004.IND_BCD(+)         
                        AND W002.WERKS = M001.WERKS(+)         
                        AND W002.MATNR = M001.MATNR(+)         
                        AND W002.MACH_CD = I001.MACH_CD(+)         
                        AND W002.IND_BCD = I001.IND_BCD(+)         
                        AND W002.WRK_ORDR_NO = S017.WRK_ORDR_NO(+)
                        AND W002.WRK_ORDR_SEQNO = S017.WRK_ORDR_SEQNO(+)
                        AND W002.WERKS = P_WERKS            --플랜트코드
                        AND W002.MACH_CD = P_MACH_CD        --작업장코드(설비코드)
                        AND W002.PRFM_DT BETWEEN P_SPRFM_DT AND P_EPRFM_DT       --실적일자
                        AND W002.PRFM_GTHR_YN  = 'Y'        --실적조회여부   
                        AND NVL(W002.CNL_YN,'N') = 'N'
                        AND NVL(W002.IND_BCD,' ') LIKE '%' || P_IND_BCD || '%'
                        AND NVL(W002.ORDER_NO,' ') LIKE '%' || P_ORDER_NO || '%'
                        AND NVL(M001.PCODE   ,' ') LIKE '%' || P_PCODE || '%'
                        AND TO_CHAR(NVL(M001.BS_WGT,0)) LIKE '%' || P_BS_WGT || '%'
                        AND TO_CHAR(NVL(M001.WLEN,0)) LIKE '%' || P_WLEN || '%'
                        AND TO_CHAR(NVL(M001.VLEN,0)) LIKE '%' || P_VLEN || '%'
                        UNION ALL
                        SELECT 
                              '-'                               CHK             --체크버튼
                            , TO_CHAR(W004.REGDATE, 'YYYY-MM-DD HH24:MI:SS') AS PRD_DT -- 생산일자
                            , W004.IND_BCD                      IND_BCD         --개별바코드
                            , W004.LOT_NO                       LOT_NO          --LOT_NO
                            , NVL((SELECT CDESC1 FROM CMCDV WHERE CMCDKY = 'STCK_STA' AND CMCDVL = I001.STCK_STA),'폐품') AS STCK_STA_NM    --재고상태
                            , M001.PCODE                        PCODE           --지종
                            , M001.PCODE_NM                     PCODE_NM        --지종명
                            , TO_CHAR(M001.BS_WGT, 'fm999,999,999,990')              AS BS_WGT   --평량
                            , SUBSTR(M001.MATNR, 10, 4) || '*' || SUBSTR(M001.MATNR, 14, 4)       MATNR_SPEC
                            , NULL                      WRK_SEQ         --생산순번
                            , NULL                     ORDER_NO        --오더번호
                            , NULL                  ORDER_SEQNO     --오더번호 순번
                            , W004.WRK_ORDR_NO                  WRK_ORDR_NO     --작업지시번호
                            , W004.WRK_ORDR_SEQNO               WRK_ORDR_SEQNO  --작업지시 순번
                            , W004.UNIT                         UNIT            --실적단위
                            , NVL(RTRIM(TO_CHAR('0', 'fm999,999,999,999,990.999'), '.'), '0')      AS PRFM_QTY	    --실적연수
                            , NVL(RTRIM(TO_CHAR('0', 'fm999,999,999,999,990.999'), '.'), '0')          AS WGT	            --중량
                            , NVL(RTRIM(TO_CHAR(W004.DISPO_QTY/500, 'fm999,999,999,999,990.999'), '.'), '0')    AS DISPO_QTY	    --폐품연수
                            , NVL(RTRIM(TO_CHAR(W004.WGT, 'fm999,999,999,999,990.999'), '.'), '0')          AS DISPO_WGT	    --폐품중량
                            , '상세보기'                          DBTN            --상세보기 버튼
                            --, CMCDV.CDESC1                      RUN_STA_NM      --운전상태
                            , (SELECT CDESC1 FROM CMCDV WHERE CMCDKY = 'RUN_STA' AND CMCDVL = W004.RUN_STA) AS RUN_STA_NM      --운전상태
                            , W004.MATNR                        MATNR           --자재코드
                            , TO_CHAR(W004.PRD_STR_DATE,'YYYY-MM-DD HH24:MI:SS')  
                                                                PRD_STR_DATE    --생산시작 일시
                            , TO_CHAR(W004.PRD_END_DATE,'YYYY-MM-DD HH24:MI:SS')  
                                                                PRD_END_DATE    --생산 종료 일시
                            , TO_CHAR(W004.TM, 'fm999,999,999,990') TM                    --생산시간(분)
                            --, W004.TM                           TM   --생산시간(분)
                            , TO_CHAR(TO_DATE(W004.PRFM_DT,'YYYYMMDD'),'YYYY-MM-DD')  
                                                                PRFM_DT         --실적일자
                            , W004.WRK_CLASS                    WRK_CLASS       --반
                            , ''                                STA             --상태
                            --, W004.DOC_NO                       DOC_NO          --MES 문서번호
                            --, W004.DOC_SEQNO                    DOC_SEQNO       --MES 문서번호 순번
                            --, W004.SDOC_NO                      SDOC_NO         --SAP 확정문서번호
                            , W004.RMK                          RMK             --비고
                            , S017.COMP_YN                      COMP_YN
                            , NULL                              MER_YN
                            , CASE WHEN W004.SDOC_NO  IS NULL  THEN 'E'
                                   WHEN W004.SDOC_NO  = 'E'    THEN 'E'
                                   ELSE                             W004.SDOC_NO  
                               END                            SDOC_NO         --SAP 확정문서번호                                  
                        FROM  TB_WRK004 W004    --폐품실적
                            , TB_SCH017 S017
                            , TB_INV001 I001    --창고별 재고관리
                            , TB_MAS001 M001    --자재마스터
                        WHERE 1=1
                        AND W004.WERKS = M001.WERKS(+)         
                        AND W004.MATNR = M001.MATNR(+)         
                        AND W004.MACH_CD = I001.MACH_CD(+)         
                        AND W004.IND_BCD = I001.IND_BCD(+)         
                        AND W004.WRK_ORDR_NO = S017.WRK_ORDR_NO(+)
                        AND W004.WRK_ORDR_SEQNO = S017.WRK_ORDR_SEQNO(+)
                        AND W004.WERKS = P_WERKS            --플랜트코드
                        AND W004.MACH_CD = P_MACH_CD        --작업장코드(설비코드)
                        AND W004.PRFM_DT BETWEEN P_SPRFM_DT AND P_EPRFM_DT       --실적일자
                        AND NVL(W004.CNL_YN,'N') = 'N'
                        AND NVL(W004.IND_BCD,' ') LIKE '%' || P_IND_BCD || '%'
                        AND NVL(W004.ORDER_NO,' ') LIKE '%' || P_ORDER_NO || '%'
                        AND NVL(M001.PCODE   ,' ') LIKE '%' || P_PCODE || '%'
                        AND TO_CHAR(NVL(M001.BS_WGT,0)) LIKE '%' || P_BS_WGT || '%'
                        AND TO_CHAR(NVL(M001.WLEN,0)) LIKE '%' || P_WLEN || '%'
                        AND TO_CHAR(NVL(M001.VLEN,0)) LIKE '%' || P_VLEN || '%'
            )            
            ORDER BY PRD_DT DESC, PRD_STR_DATE  DESC, PRD_END_DATE DESC, IND_BCD  DESC, WRK_ORDR_NO DESC, WRK_ORDR_SEQNO DESC;

        ELSIF P_PROC_CD = 'CB' THEN      -- 수재단
            --grid 컬럼 정보 설정
            P_COLINFO := '선택@C^50|구분@C^80|생산일시@C^190|개별바코드@C^130|LOT_NO@C^130|재고상태@C^80|오더번호@H|순번@H|작업지시번호@H|순번@H|단위@H|실적연수@R^100|실적중량(KG)@R^110|폐품연수@R^100|폐품중량(KG)@R^110|상세보기@C^100|자재코드@C^200|운전상태@C^100|지종@C^90|지종명@H|평량@R^90|생산시작일시@H|생산종료일시@H|가동시간(분)@H|실적일자@H|반@H|상태@H|비고@L^500|문서번호@H';
            P_COLTYPE := 'CHK@Button|GB@varchar|PRD_DT@varchar|IND_BCD@varchar|LOT_NO@varchar|STCK_STA_NM@varchar|ORDER_NO@varchar|ORDER_SEQNO@varchar|WRK_ORDR_NO@varchar|WRK_ORDR_SEQNO@varchar|UNIT@varchar|PRFM_QTY@varchar|WGT@varchar|DISPO_QTY@varchar|DISPO_WGT@varchar|DBTN@Button|MATNR@varchar|RUN_STA_NM@varchar|PCODE@varchar|PCODE_NM@varchar|BS_WGT@varchar|PRD_STR_DATE@varchar|PRD_END_DATE@varchar|TM@varchar|PRFM_DT@varchar|WRK_CLASS@varchar|STA@varchar|RMK@varchar|SDOC_NO@varchar';
            --실적현황 조회
            OPEN CUR_1 FOR
            SELECT
                 CHK             --체크버튼
               , CASE WHEN GB = '예외' THEN '예외'  ELSE '정상'   END  AS GB
               , PRD_DT
               , IND_BCD         --개별바코드
               , LOT_NO          --LOT_NO
               , STCK_STA_NM     --재고상태
               , ORDER_NO        --오더번호
               , ORDER_SEQNO     --오더번호 순번
               , WRK_ORDR_NO     --작업지시번호
               , WRK_ORDR_SEQNO  --작업지시 순번
               , UNIT            --실적단위
               , CASE WHEN GB = '예외'  THEN  NVL(RTRIM(TO_CHAR(PRFM_QTY, 'fm999,999,999,999,990.999'), '.'), '0') 
                      ELSE                    NVL(RTRIM(TO_CHAR(PRFM_QTY / 500, 'fm999,999,999,999,990.999'), '.'), '0')   
                  END   AS  PRFM_QTY 	     --실적연수
               , WGT	         --실적중량
               , CASE WHEN GB = '예외'  THEN  NVL(RTRIM(TO_CHAR(DISPO_QTY /* * 500*/, 'fm999,999,999,999,990.999'), '.'), '0')  
                      ELSE                    NVL(RTRIM(TO_CHAR(DISPO_QTY /*/ 500*/, 'fm999,999,999,999,990.999'), '.'), '0')  
                  END   AS  DISPO_QTY       --폐품연수
               , DISPO_WGT	     --폐품수량
               , DBTN            --상세보기 버튼
               , MATNR           --자재코드
               , RUN_STA_NM      --운전상태
               , PCODE           --지종
               , PCODE_NM        --지종명
               , BS_WGT          --평량
               , PRD_STR_DATE    --생산시작 일시
               , PRD_END_DATE    --생산 종료 일시
               , TM              --생산시간(분)
               , PRFM_DT         --실적일자
               , WRK_CLASS       --반
               , STA             --상태
               , RMK             --비고
               , SDOC_NO
            FROM
            (
                        SELECT 
                              '-'                               CHK             --체크버튼
                            , (
                                SELECT '예외'
                                  FROM TB_SCH019 H019
                                  WHERE W002.WRK_ORDR_NO    = H019.WRK_ORDR_NO
                                    AND W002.WRK_ORDR_SEQNO = H019.WRK_ORDR_SEQNO
                              )                             GB              --구분    
                            , TO_CHAR(W002.REGDATE, 'YYYY-MM-DD HH24:MI:SS') AS PRD_DT -- 생산일자
                            , W002.IND_BCD                      IND_BCD         --개별바코드
                            , W002.LOT_NO                       LOT_NO          --LOT_NO
                            , (SELECT CDESC1 FROM CMCDV WHERE CMCDKY = 'STCK_STA' AND CMCDVL = I001.STCK_STA) AS STCK_STA_NM    --재고상태
                            , W002.ORDER_NO                     ORDER_NO        --오더번호
                            , W002.ORDER_SEQNO                  ORDER_SEQNO     --오더번호 순번
                            , W002.WRK_ORDR_NO                  WRK_ORDR_NO     --작업지시번호
                            , W002.WRK_ORDR_SEQNO               WRK_ORDR_SEQNO  --작업지시 순번
                            , W002.UNIT                         UNIT            --실적단위
                            --, ROUND(FN_CHG_UNIT (  W002.MATNR, P_WERKS, W002.UNIT, 'R', NVL(W002.PRFM_QTY, 0)),3)      PRFM_QTY         --사용량               
                            , W002.PRFM_QTY    AS PRFM_QTY	    --실적연수

                            --,ROUND(FN_CHG_UNIT (  MATNR, P_WERKS, UNIT, 'R', NVL(W002.WGT,0)) ,3)           WGT          --투입량
                            , NVL(RTRIM(TO_CHAR(W002.WGT, 'fm999,999,999,999,990.999'), '.'), '0')       AS WGT	            --실적중량
                            , 0               DISPO_QTY	    --폐품연수
                            , '0' --NVL(REGEXP_REPLACE(REVERSE(REGEXP_REPLACE(REVERSE(TO_CHAR(W004.WGT)), '(\d{3})','\1,')), '^,',''), '0')  
                                                                DISPO_WGT	    --폐품수량
                            , '상세보기'                          DBTN            --상세보기 버튼
                            , W002.MATNR                        MATNR           --자재코드
                            , (SELECT CDESC1 FROM CMCDV WHERE CMCDKY = 'RUN_STA' AND CMCDVL = W002.RUN_STA) AS RUN_STA_NM      --운전상태
                            , M001.PCODE                        PCODE           --지종
                            , M001.PCODE_NM                     PCODE_NM        --지종명
                            , TO_CHAR(M001.BS_WGT, 'fm999,999,999,990')              AS BS_WGT   --평량
                            , TO_CHAR(W002.PRD_STR_DATE,'YYYY-MM-DD HH24:MI:SS')  
                                                                PRD_STR_DATE    --생산시작 일시
                            , TO_CHAR(W002.PRD_END_DATE,'YYYY-MM-DD HH24:MI:SS')  
                                                                PRD_END_DATE    --생산 종료 일시
                            , TO_CHAR(W002.TM, 'fm999,999,999,990') TM                    --생산시간(분)
                            --, W002.TM                           TM   --생산시간(분)
                            , TO_CHAR(TO_DATE(W002.PRFM_DT,'YYYYMMDD'),'YYYY-MM-DD')  
                                                                PRFM_DT         --실적일자
                            , W002.WRK_CLASS                    WRK_CLASS       --반
                            , W002.STA                          STA             --상태
--                            , W002.DOC_NO                       DOC_NO          --MES 문서번호
--                            , W002.DOC_SEQNO                    DOC_SEQNO       --MES 문서번호 순번
--                            , W002.SDOC_NO                      SDOC_NO         --SAP 확정문서번호
                            , W002.RMK                          RMK             --비고
                            , CASE WHEN W002.SDOC_NO  IS NULL  THEN 'E'
                                   WHEN W002.SDOC_NO  = 'E'    THEN 'E'
                                   ELSE                             W002.SDOC_NO  
                               END                            SDOC_NO         --SAP 확정문서번호                                  
                        FROM  TB_WRK002 W002    --PS실적
                            --, (SELECT SUM(DISPO_QTY) AS DISPO_QTY, SUM(WGT) AS WGT, IND_BCD, WERKS, MACH_CD 
                            --        FROM TB_WRK004
                            --        WHERE WERKS = P_WERKS
                            --        AND MACH_CD = P_MACH_CD
                            --    GROUP BY WERKS, MACH_CD, IND_BCD) W004    --PS폐품실적
                            , TB_MAS001 M001    --자재마스터
                            , TB_INV001 I001    --창고별 재고관리
                        WHERE 1=1
                        --AND W002.WERKS = W004.WERKS(+)         
                        --AND W002.MACH_CD = W004.MACH_CD(+)         
                        --AND W002.IND_BCD = W004.IND_BCD(+)         
                        AND W002.WERKS = M001.WERKS(+)         
                        AND W002.MATNR = M001.MATNR(+)         
                        AND W002.MACH_CD = I001.MACH_CD(+)         
                        AND W002.IND_BCD = I001.IND_BCD(+)         
                        AND W002.WERKS = P_WERKS            --플랜트코드
                        AND W002.MACH_CD = P_MACH_CD        --작업장코드(설비코드)
                        AND W002.PRFM_DT BETWEEN P_SPRFM_DT AND P_EPRFM_DT       --실적일자
                        AND W002.PRFM_GTHR_YN  = 'Y'        --실적조회여부   
                        AND NVL(W002.CNL_YN,'N') = 'N'
                        AND NVL(W002.MER_YN,'N')  = 'N'
                        AND NVL(W002.IND_BCD,' ') LIKE '%' || P_IND_BCD || '%'
                        AND NVL(W002.ORDER_NO,' ') LIKE '%' || P_ORDER_NO || '%'
                        AND NVL(M001.PCODE   ,' ') LIKE '%' || P_PCODE || '%'
                        AND TO_CHAR(NVL(M001.BS_WGT,0)) LIKE '%' || P_BS_WGT || '%'
                        AND TO_CHAR(NVL(M001.WLEN,0)) LIKE '%' || P_WLEN || '%'
                        AND TO_CHAR(NVL(M001.VLEN,0)) LIKE '%' || P_VLEN || '%'
                        UNION ALL
                        SELECT 
                              '-'                               CHK             --체크버튼
                            , (
                                SELECT '예외'
                                  FROM TB_SCH019 H019
                                  WHERE W002.WRK_ORDR_NO    = H019.WRK_ORDR_NO
                                    AND W002.WRK_ORDR_SEQNO = H019.WRK_ORDR_SEQNO
                              )                             GB              --구분    
                            , TO_CHAR(W002.REGDATE, 'YYYY-MM-DD HH24:MI:SS') AS PRD_DT -- 생산일자
                            , W002.MER_IND_BCD                  IND_BCD         --개별바코드
                            , W002.LOT_NO                       LOT_NO          --LOT_NO
                            , (SELECT CDESC1 FROM CMCDV WHERE CMCDKY = 'STCK_STA' AND CMCDVL = I001.STCK_STA) AS STCK_STA_NM    --재고상태
                            --, I001.STCK_STA                                                 AS STCK_STA
                            , W002.ORDER_NO                     ORDER_NO        --오더번호
                            , W002.ORDER_SEQNO                  ORDER_SEQNO     --오더번호 순번
                            , W002.WRK_ORDR_NO                  WRK_ORDR_NO     --작업지시번호
                            , W002.WRK_ORDR_SEQNO               WRK_ORDR_SEQNO  --작업지시 순번
                            , W002.UNIT                         UNIT            --실적단위
                            --, ROUND(FN_CHG_UNIT (  W002.MATNR, P_WERKS, W002.UNIT, 'R', NVL(W002.PRFM_QTY, 0)),3)      PRFM_QTY         --사용량               
                            , W002.PRFM_QTY    AS PRFM_QTY	    --실적연수

                            --,ROUND(FN_CHG_UNIT (  MATNR, P_WERKS, UNIT, 'R', NVL(W002.WGT,0)) ,3)           WGT          --투입량
                            , NVL(RTRIM(TO_CHAR(W002.WGT, 'fm999,999,999,999,990.999'), '.'), '0')       AS WGT	            --실적중량
                            , 0                   DISPO_QTY	    --폐품연수
                            , '0' --NVL(REGEXP_REPLACE(REVERSE(REGEXP_REPLACE(REVERSE(TO_CHAR(W004.WGT)), '(\d{3})','\1,')), '^,',''), '0')  
                                                                DISPO_WGT	    --폐품수량
                            , '상세보기'                          DBTN            --상세보기 버튼
                            , W002.MATNR                        MATNR           --자재코드
                            , (SELECT CDESC1 FROM CMCDV WHERE CMCDKY = 'RUN_STA' AND CMCDVL = W002.RUN_STA) AS RUN_STA_NM      --운전상태
                            , M001.PCODE                        PCODE           --지종
                            , M001.PCODE_NM                     PCODE_NM        --지종명
                            , TO_CHAR(M001.BS_WGT, 'fm999,999,999,990')              AS BS_WGT   --평량
                            , TO_CHAR(W002.PRD_STR_DATE,'YYYY-MM-DD HH24:MI:SS')  
                                                                PRD_STR_DATE    --생산시작 일시
                            , TO_CHAR(W002.PRD_END_DATE,'YYYY-MM-DD HH24:MI:SS')  
                                                                PRD_END_DATE    --생산 종료 일시
                            , TO_CHAR(W002.TM, 'fm999,999,999,990') TM                    --생산시간(분)
                            --, W002.TM                           TM   --생산시간(분)
                            , TO_CHAR(TO_DATE(W002.PRFM_DT,'YYYYMMDD'),'YYYY-MM-DD')  
                                                                PRFM_DT         --실적일자
                            , W002.WRK_CLASS                    WRK_CLASS       --반
                            , W002.STA                          STA             --상태
--                            , W002.DOC_NO                       DOC_NO          --MES 문서번호
--                            , W002.DOC_SEQNO                    DOC_SEQNO       --MES 문서번호 순번
--                            , W002.SDOC_NO                      SDOC_NO         --SAP 확정문서번호
                            , W002.RMK                          RMK             --비고
                            , CASE WHEN W002.SDOC_NO  IS NULL  THEN 'E'
                                   WHEN W002.SDOC_NO  = 'E'    THEN 'E'
                                   ELSE                             W002.SDOC_NO  
                               END                            SDOC_NO         --SAP 확정문서번호                                  
                        FROM  TB_WRK002 W002    --PS실적
                            --, (SELECT SUM(DISPO_QTY) AS DISPO_QTY, SUM(WGT) AS WGT, IND_BCD, WERKS, MACH_CD 
                            --        FROM TB_WRK004
                            --        WHERE WERKS = P_WERKS
                            --        AND MACH_CD = P_MACH_CD
                            --    GROUP BY WERKS, MACH_CD, IND_BCD) W004    --PS폐품실적
                            , TB_MAS001 M001    --자재마스터
                            , TB_INV001 I001    --창고별 재고관리
                        WHERE 1=1
                        --AND W002.WERKS = W004.WERKS(+)         
                        --AND W002.MACH_CD = W004.MACH_CD(+)         
                        --AND W002.IND_BCD = W004.IND_BCD(+)         
                        AND W002.WERKS = M001.WERKS(+)         
                        AND W002.MATNR = M001.MATNR(+)         
                        AND W002.MACH_CD = I001.MACH_CD(+)         
                        AND W002.IND_BCD = I001.IND_BCD(+)         
                        AND W002.WERKS = P_WERKS            --플랜트코드
                        AND W002.MACH_CD = P_MACH_CD        --작업장코드(설비코드)
                        AND W002.PRFM_DT BETWEEN P_SPRFM_DT AND P_EPRFM_DT       --실적일자
                        AND W002.PRFM_GTHR_YN  = 'Y'        --실적조회여부   
                        AND NVL(W002.CNL_YN,'N') = 'N'
                        AND NVL(W002.MER_YN,'N')  = 'Y'
                        AND NVL(W002.IND_BCD,' ') LIKE '%' || P_IND_BCD || '%'
                        AND NVL(W002.ORDER_NO,' ') LIKE '%' || P_ORDER_NO || '%'
                        AND NVL(M001.PCODE   ,' ') LIKE '%' || P_PCODE || '%'
                        AND TO_CHAR(NVL(M001.BS_WGT,0)) LIKE '%' || P_BS_WGT || '%'
                        AND TO_CHAR(NVL(M001.WLEN,0)) LIKE '%' || P_WLEN || '%'
                        AND TO_CHAR(NVL(M001.VLEN,0)) LIKE '%' || P_VLEN || '%'
                        UNION ALL
                        SELECT 
                              '-'                               CHK             --체크버튼
                            , (
                                SELECT '예외'
                                  FROM TB_SCH019 H019
                                  WHERE W004.WRK_ORDR_NO    = H019.WRK_ORDR_NO
                                    AND W004.WRK_ORDR_SEQNO = H019.WRK_ORDR_SEQNO
                              )                             GB              --구분    
                            , TO_CHAR(W004.REGDATE, 'YYYY-MM-DD HH24:MI:SS') AS PRD_DT -- 생산일자
                            , W004.IND_BCD                      IND_BCD         --개별바코드
                            , W004.LOT_NO                       LOT_NO          --LOT_NO
                            , NVL((SELECT CDESC1 FROM CMCDV WHERE CMCDKY = 'STCK_STA' AND CMCDVL = I001.STCK_STA), '폐품') AS STCK_STA_NM    --재고상태
                            , NULL                     ORDER_NO        --오더번호
                            , NULL                  ORDER_SEQNO     --오더번호 순번
                            , W004.WRK_ORDR_NO                  WRK_ORDR_NO     --작업지시번호
                            , W004.WRK_ORDR_SEQNO               WRK_ORDR_SEQNO  --작업지시 순번
                            , W004.UNIT                         UNIT            --실적단위
                            , 0      AS PRFM_QTY	    --실적연수
                            , NVL(RTRIM(TO_CHAR('0', 'fm999,999,999,999,990.999'), '.'), '0')          AS WGT	            --중량
                            , W004.DISPO_QTY    AS DISPO_QTY	    --폐품연수
                            , NVL(RTRIM(TO_CHAR(W004.WGT, 'fm999,999,999,999,990.099'), '.'), '0')          AS DISPO_WGT	    --폐품중량
                            , '상세보기'                          DBTN            --상세보기 버튼
                            , W004.MATNR                        MATNR           --자재코드
                            , (SELECT CDESC1 FROM CMCDV WHERE CMCDKY = 'RUN_STA' AND CMCDVL = W004.RUN_STA) AS RUN_STA_NM      --운전상태
                            , M001.PCODE                        PCODE           --지종
                            , M001.PCODE_NM                     PCODE_NM        --지종명
                            , TO_CHAR(M001.BS_WGT, 'fm999,999,999,990')              AS BS_WGT   --평량
                            , TO_CHAR(W004.PRD_STR_DATE,'YYYY-MM-DD HH24:MI:SS')  
                                                                PRD_STR_DATE    --생산시작 일시
                            , TO_CHAR(W004.PRD_END_DATE,'YYYY-MM-DD HH24:MI:SS')  
                                                                PRD_END_DATE    --생산 종료 일시
                            , TO_CHAR(W004.TM, 'fm999,999,999,990') TM                    --생산시간(분)
                            --, W004.TM                           TM   --생산시간(분)
                            , TO_CHAR(TO_DATE(W004.PRFM_DT,'YYYYMMDD'),'YYYY-MM-DD')  
                                                                PRFM_DT         --실적일자
                            , W004.WRK_CLASS                    WRK_CLASS       --반
                            , ''                                STA             --상태
--                            , W004.DOC_NO                       DOC_NO          --MES 문서번호
--                            , W004.DOC_SEQNO                    DOC_SEQNO       --MES 문서번호 순번
--                            , W004.SDOC_NO                      SDOC_NO         --SAP 확정문서번호
                            , W004.RMK                          RMK             --비고
                            , CASE WHEN W004.SDOC_NO  IS NULL  THEN 'E'
                                   WHEN W004.SDOC_NO  = 'E'    THEN 'E'
                                   ELSE                             W004.SDOC_NO  
                               END                            SDOC_NO         --SAP 확정문서번호                                  
                        FROM  TB_WRK004 W004    --폐품실적
                            , TB_MAS001 M001    --자재마스터
                            , TB_INV001 I001    --창고별 재고관리
                        WHERE 1=1
                        AND W004.WERKS = M001.WERKS(+)         
                        AND W004.MATNR = M001.MATNR(+)         
                        AND W004.MACH_CD = I001.MACH_CD(+)         
                        AND W004.IND_BCD = I001.IND_BCD(+)         
                        AND W004.WERKS   = P_WERKS            --플랜트코드
                        AND W004.MACH_CD = P_MACH_CD        --작업장코드(설비코드)
                        AND W004.PRFM_DT BETWEEN P_SPRFM_DT AND P_EPRFM_DT       --실적일자
                        AND NVL(W004.CNL_YN,'N') = 'N'
                        AND NVL(W004.IND_BCD,' ') LIKE '%' || P_IND_BCD || '%'
                        AND NVL(W004.ORDER_NO,' ') LIKE '%' || P_ORDER_NO || '%'
                        AND NVL(M001.PCODE   ,' ') LIKE '%' || P_PCODE || '%'
                        AND TO_CHAR(NVL(M001.BS_WGT,0)) LIKE '%' || P_BS_WGT || '%'
                        AND TO_CHAR(NVL(M001.WLEN,0)) LIKE '%' || P_WLEN || '%'
                        AND TO_CHAR(NVL(M001.VLEN,0)) LIKE '%' || P_VLEN || '%'
            )
            ORDER BY PRD_DT DESC, PRD_STR_DATE  DESC, PRD_END_DATE DESC, IND_BCD  DESC, WRK_ORDR_NO DESC, WRK_ORDR_SEQNO DESC;        
        ELSE   -- 포장 실적현황
            --grid 컬럼 정보 설정
            P_COLINFO := '선택@C^50|생산일시@C^190|개별바코드@C^130|오더번호@C^130|LOT_NO@C^130|재고상태@C^90|지종@C^80|지종명@H|평량@C^80|규격@C^120|실적연수@R^80|실적중량(KG)@R^120|폐품연수@R^80|폐품중량(KG)@R^120|상세보기@C^100|운전상태@C^50|자재코드@C^200|실적일자@H|반@H|순번@H|작업지시번호@H|순번@H|단위@H|재단LOT1@C^120|재단연수1@C^90|재단LOT2@C^120|재단연수2@C^90|재단LOT3@C^120|재단연수3@C^90|재단LOT4@C^120|재단연수4@C^90|재단LOT5@C^120|재단연수5@C^90|상태@H|비고@L^500|문서번호@L^100';
            P_COLTYPE := 'CHK@Button|PRD_DT@varchar|IND_BCD@varchar|ORDER_NO@varchar|LOT_NO@varchar|STCK_STA_NM@varchar|PCODE@varchar|PCODE_NM@varchar|BS_WGT@varchar|MATNR_SPEC@varchar|PCNT@varchar|WGT@varchar|PCNT_DISPO@varchar|WGT_DISPO@varchar|DBTN@Button|RUN_STA_NM@varchar|MATNR@varchar|PRFM_DT@varchar|WRK_CLASS@varchar|ORDER_SEQNO@varchar|WRK_ORDR_NO@varchar|WRK_ORDR_SEQNO@varchar|UNIT@varchar|LOT_NO_M1@varchar|USE_REAM_M1@varchar|LOT_NO_M2@varchar|USE_REAM_M2@varchar|LOT_NO_M3@varchar|USE_REAM_M3@varchar|LOT_NO_M4@varchar|USE_REAM_M4@varchar|LOT_NO_M5@varchar|USE_REAM_M5@varchar|STA@varchar|RMK@varchar|SDOC_NO@varchar';
            --실적현황 조회
            OPEN CUR_1 FOR
            SELECT
                 CHK             --체크버튼
               , PRD_DT
               , IND_BCD         --개별바코드
               , ORDER_NO        --오더번호
               , LOT_NO          --LOT_NO
               , STCK_STA_NM   --재고상태
               , PCODE           --지종
               , PCODE_NM        --지종명
               , BS_WGT          --평량
               , MATNR_SPEC     --규격
               , PCNT	     --실적연수
               , WGT	         --실적중량
               , PCNT_DISPO	     --폐품연수
               , WGT_DISPO       --폐품중량
               , DBTN            --상세보기 버튼
               , RUN_STA_NM      --운전상태
               , MATNR           --자재코드
--               , WIDTH	         --실지폭
--               , TM              --생산시간(분)
               , PRFM_DT         --실적일자
               , WRK_CLASS       --반
               , ORDER_SEQNO     --오더번호 순번
               , WRK_ORDR_NO     --작업지시번호
               , WRK_ORDR_SEQNO  --작업지시 순번
               , UNIT            --실적단위
               , LOT_NO_M1
               , USE_REAM_M1
               , LOT_NO_M2
               , USE_REAM_M2
               , LOT_NO_M3
               , USE_REAM_M3
               , LOT_NO_M4
               , USE_REAM_M4
               , LOT_NO_M5
               , USE_REAM_M5
               , STA            --상태
               , RMK             --비고            
               , SDOC_NO               
            FROM
            (
                    SELECT 
                          '-'                       CHK             --체크버튼
                        , TO_CHAR(W002.REGDATE, 'YYYY-MM-DD HH24:MI:SS') AS PRD_DT -- 생산일자
                        , W002.IND_BCD              IND_BCD         --개별바코드
                        , W002.LOT_NO               LOT_NO          --LOT_NO
                        , (SELECT CDESC1 FROM CMCDV WHERE CMCDKY = 'STCK_STA' AND CMCDVL = I001.STCK_STA) AS STCK_STA_NM
                        , M001.PCODE                PCODE           --지종
                        , M001.PCODE_NM             PCODE_NM        --지종명
                        , M001.BS_WGT               BS_WGT          --평량
                        , SUBSTR(M001.MATNR, 10, 4) || '*' || SUBSTR(M001.MATNR, 14, 4)       MATNR_SPEC
                        , NVL(RTRIM(TO_CHAR(W002.PCNT, 'fm999,999,999,999,990.999'), '.'), '0')         AS PCNT	        --실적연수
                        , NVL(RTRIM(TO_CHAR(W002.WGT, 'fm999,999,999,999,990.999'), '.'), '0')          AS WGT	            --실적중량
                        , '0'       PCNT_DISPO      --폐품연수
                        , '0'       WGT_DISPO       --폐품중량
                        , '상세보기'                  DBTN            --상세보기 버튼
                        , (SELECT CDESC1 FROM CMCDV WHERE CMCDKY = 'RUN_STA' AND CMCDVL = W002.RUN_STA) AS RUN_STA_NM      --운전상태
                        , W002.MATNR                MATNR           --자재코드
--                        , NVL(RTRIM(TO_CHAR(W002.WIDTH, 'fm999,999,999,999,990.999'), '.'), '0')        AS WIDTH	        --실지폭
--                        , W002.TM                   TM              --생산시간(분)
                        , TO_CHAR(TO_DATE(W002.PRFM_DT,'YYYYMMDD'),'YYYY-MM-DD')  
                                                    PRFM_DT         --실적일자
                        , W002.WRK_CLASS            WRK_CLASS       --반
                        , W002.ORDER_NO             ORDER_NO        --오더번호
                        , W002.ORDER_SEQNO          ORDER_SEQNO     --오더번호 순번
                        , W002.WRK_ORDR_NO          WRK_ORDR_NO     --작업지시번호
                        , W002.WRK_ORDR_SEQNO       WRK_ORDR_SEQNO  --작업지시 순번
                        , W002.UNIT                 UNIT            --실적단위
                        , W002.LOT_NO_M1                                         LOT_NO_M1
                        , NVL(RTRIM(TO_CHAR(W002.USE_REAM_M1, 'fm999,999,999,999,990.999'), '.'), '0')  USE_REAM_M1
                        , W002.LOT_NO_M2                                         LOT_NO_M2
                        , NVL(RTRIM(TO_CHAR(W002.USE_REAM_M2, 'fm999,999,999,999,990.999'), '.'), '0')  USE_REAM_M2
                        , W002.LOT_NO_M3                                         LOT_NO_M3
                        , NVL(RTRIM(TO_CHAR(W002.USE_REAM_M3, 'fm999,999,999,999,990.999'), '.'), '0')  USE_REAM_M3
                        , W002.LOT_NO_M4                                         LOT_NO_M4
                        , NVL(RTRIM(TO_CHAR(W002.USE_REAM_M4, 'fm999,999,999,999,990.999'), '.'), '0')  USE_REAM_M4
                        , W002.LOT_NO_M5                                         LOT_NO_M5
                        , NVL(RTRIM(TO_CHAR(W002.USE_REAM_M5, 'fm999,999,999,999,990.999'), '.'), '0')  USE_REAM_M5
                        , W002.STA                  STA             --상태
                        , W002.RMK                  RMK             --비고
                        , CASE WHEN W002.SDOC_NO  IS NULL  THEN 'E'
                               WHEN W002.SDOC_NO  = 'E'    THEN 'E'
                               ELSE                             W002.SDOC_NO  
                           END                            SDOC_NO         --SAP 확정문서번호                                  
                    FROM  TB_WRK002 W002    --PS실적
                        , (SELECT SUM(ROLLCNT) AS ROLLCNT, SUM(DISPO_QTY) AS DISPO_QTY, IND_BCD, WERKS, MACH_CD FROM TB_WRK004
                                WHERE WERKS = P_WERKS
                                AND MACH_CD = P_MACH_CD
                                AND NVL(CNL_YN,'N') = 'N'
                            GROUP BY WERKS, MACH_CD, IND_BCD) W004    --PS폐품실적            
                        , TB_MAS001 M001    --자재마스터
                        , TB_INV001 I001    --창고별 재고관리
                    WHERE 1=1
                    AND W002.WERKS = M001.WERKS(+)         
                    AND W002.MATNR = M001.MATNR(+)         
                    AND W002.MACH_CD = I001.MACH_CD(+)         
                    AND W002.IND_BCD = I001.IND_BCD(+)         
                    AND W002.WERKS = P_WERKS            --플랜트코드
                    AND W002.MACH_CD = P_MACH_CD        --작업장코드(설비코드)
                    AND W002.PRFM_DT BETWEEN P_SPRFM_DT AND P_EPRFM_DT       --실적일자
                    AND W002.PRFM_GTHR_YN  = 'Y'        --실적조회여부 
                    AND NVL(W002.CNL_YN,'N') = 'N'
                    AND W002.WERKS   = W004.WERKS  (+)
                    AND W002.IND_BCD = W004.IND_BCD(+)
                    AND W002.MACH_CD = W004.MACH_CD(+)
                    AND NVL(W002.IND_BCD,' ') LIKE '%' || P_IND_BCD || '%'
                    AND NVL(W002.ORDER_NO,' ') LIKE '%' || P_ORDER_NO || '%'
                    AND NVL(M001.PCODE   ,' ') LIKE '%' || P_PCODE || '%'
                    AND TO_CHAR(NVL(M001.BS_WGT,0)) LIKE '%' || P_BS_WGT || '%'
                    AND TO_CHAR(NVL(M001.WLEN,0)) LIKE '%' || P_WLEN || '%'
                    AND TO_CHAR(NVL(M001.VLEN,0)) LIKE '%' || P_VLEN || '%'
                    UNION ALL
                    SELECT 
                              '-'                               CHK             --체크버튼
                            , TO_CHAR(W004.REGDATE, 'YYYY-MM-DD HH24:MI:SS') AS PRD_DT -- 생산일자
                            , W004.IND_BCD                      IND_BCD         --개별바코드
                            , W004.LOT_NO                       LOT_NO          --LOT_NO
                            , NVL((SELECT CDESC1 FROM CMCDV WHERE CMCDKY = 'STCK_STA' AND CMCDVL = I001.STCK_STA),'폐품') AS STCK_STA_NM
                            --, I001.STCK_STA                                                 AS STCK_STA
                            , M001.PCODE                        PCODE           --지종
                            , M001.PCODE_NM                     PCODE_NM        --지종명
                            , M001.BS_WGT                       BS_WGT          --평량
                            , SUBSTR(M001.MATNR, 10, 4) || '*' || SUBSTR(M001.MATNR, 14, 4)       MATNR_SPEC
                            , NVL(RTRIM(TO_CHAR(0, 'fm999,999,999,999,990.999'), '.'), '0')         AS PCNT	        --실적연수
                            , NVL(RTRIM(TO_CHAR(0, 'fm999,999,999,999,990.999'), '.'), '0')          AS WGT	            --실적중량
                            , NVL(RTRIM(TO_CHAR(W004.DISPO_QTY, 'fm999,999,999,999,990.999'), '.'), '0')       PCNT_DISPO      --폐품연수
                            , NVL(RTRIM(TO_CHAR(W004.WGT, 'fm999,999,999,999,990.999'), '.'), '0')        WGT_DISPO       --폐품중량
                            , '상세보기'                          DBTN            --상세보기 버튼    
                            , (SELECT CDESC1 FROM CMCDV WHERE CMCDKY = 'RUN_STA' AND CMCDVL = W004.RUN_STA) AS RUN_STA_NM      --운전상태
                            , W004.MATNR                        MATNR           --자재코드
                            , TO_CHAR(TO_DATE(W004.PRFM_DT,'YYYYMMDD'),'YYYY-MM-DD')  
                                                                PRFM_DT         --실적일자
                            , W004.WRK_CLASS                    WRK_CLASS       --반                                                                
                            , NULL /*W004.ORDER_NO*/             ORDER_NO        --오더번호
                            , NULL /*W004.WRK_ORDR_NO*/          ORDER_SEQNO     --오더번호 순번
                            , W004.WRK_ORDR_NO          WRK_ORDR_NO     --작업지시번호
                            , W004.WRK_ORDR_SEQNO       WRK_ORDR_SEQNO  --작업지시 순번
                            , W004.UNIT                 UNIT            --실적단위
                            , W004.LOT_NO_M                                LOT_NO_M1
                            , NVL(RTRIM(TO_CHAR(W004.DISPO_QTY, 'fm999,999,999,999,990.999'), '.'), '0')  USE_REAM_M1
                            , NULL                                         LOT_NO_M2
                            , NVL(RTRIM(TO_CHAR(0, 'fm999,999,999,999,990.999'), '.'), '0')  USE_REAM_M2
                            , NULL                                         LOT_NO_M3
                            , NVL(RTRIM(TO_CHAR(0, 'fm999,999,999,999,990.999'), '.'), '0')  USE_REAM_M3
                            , NULL                                         LOT_NO_M4
                            , NVL(RTRIM(TO_CHAR(0, 'fm999,999,999,999,990.999'), '.'), '0')  USE_REAM_M4
                            , NULL                                         LOT_NO_M5
                            , NVL(RTRIM(TO_CHAR(0, 'fm999,999,999,999,990.999'), '.'), '0')  USE_REAM_M5
                            , ''                                STA             --상태
                            , W004.RMK                          RMK             --비고
                        , CASE WHEN W004.SDOC_NO  IS NULL  THEN 'E'
                               WHEN W004.SDOC_NO  = 'E'    THEN 'E'
                               ELSE                             W004.SDOC_NO  
                           END                            SDOC_NO         --SAP 확정문서번호                                  
                    FROM  TB_WRK004 W004    --폐품실적
                            , TB_MAS001 M001    --자재마스터
                            , TB_INV001 I001    --창고별 재고관리
                    WHERE 1=1
                        AND W004.WERKS = M001.WERKS(+)         
                        AND W004.MATNR = M001.MATNR(+)         
                        AND W004.MACH_CD = I001.MACH_CD(+)         
                        AND W004.IND_BCD = I001.IND_BCD(+)         
                        AND W004.WERKS = P_WERKS            --플랜트코드
                        AND W004.MACH_CD = P_MACH_CD        --작업장코드(설비코드)
                        AND W004.PRFM_DT BETWEEN P_SPRFM_DT AND P_EPRFM_DT       --실적일자
                        AND NVL(W004.CNL_YN,'N') = 'N'
                        AND NVL(W004.IND_BCD,' ') LIKE '%' || P_IND_BCD || '%'
                        AND NVL(W004.ORDER_NO,' ') LIKE '%' || P_ORDER_NO || '%'
                        AND NVL(M001.PCODE   ,' ') LIKE '%' || P_PCODE || '%'
                        AND TO_CHAR(NVL(M001.BS_WGT,0)) LIKE '%' || P_BS_WGT || '%'
                        AND TO_CHAR(NVL(M001.WLEN,0)) LIKE '%' || P_WLEN || '%'
                        AND TO_CHAR(NVL(M001.VLEN,0)) LIKE '%' || P_VLEN || '%'
            )
            ORDER BY PRD_DT DESC, IND_BCD DESC, WRK_ORDR_NO DESC, WRK_ORDR_SEQNO DESC;
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
END;

/
